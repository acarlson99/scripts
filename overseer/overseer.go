package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"

	"gopkg.in/yaml.v2"

	"github.com/fsnotify/fsnotify"
)

type Config struct {
	Filenames []string `yaml:"filenames"`
	Cmd       string   `yaml:"cmd"`
	Args      []string `yaml:"args"`
	lockCh    chan interface{}
	doneCh    chan interface{} // close to kill thread
}

func interfacesToStrs(is []interface{}) []string {
	ss := []string{}
	for _, i := range is {
		ss = append(ss, i.(string))
	}
	return ss
}

func makeConfig(fns []string, e string, args []string) Config {
	return Config{
		Filenames: fns,
		Cmd:       e,
		Args:      args,
		lockCh:    make(chan interface{}, 1),
		doneCh:    make(chan interface{}),
	}
}

func configFromYAML(fn string) ([]Config, error) {
	ymap := make(map[interface{}]interface{})

	data, err := ioutil.ReadFile(fn)
	if err != nil {
		return nil, err
	}

	err = yaml.Unmarshal([]byte(data), &ymap)
	if err != nil {
		return nil, err
	}

	cs := []Config{}
	for _, a := range ymap["programs"].([]interface{}) {
		n := a.(map[interface{}]interface{})
		c := makeConfig(interfacesToStrs(n["targets"].([]interface{})),
			n["cmd"].(string),
			interfacesToStrs(n["args"].([]interface{})))
		cs = append(cs, c)
	}

	return cs, nil
}

func (t Config) run() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		fmt.Println("DONE")
	}()
	fmt.Println("START")
	defer watcher.Close()

	for _, fn := range t.Filenames {
		err = watcher.Add(fn)
		if err != nil {
			log.Fatal("`"+fn+"`: ", err)
		}
	}

	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			go func() {
				t.lockCh <- 1
				log.Println("event:", event.Op, event.Name)
				if event.Op&fsnotify.Write == fsnotify.Write {
					// run script
					log.Println("modified file:", event.Name)
					cmd := exec.Command(t.Cmd, t.Args...)
					fmt.Println(cmd)
					log.Println("running script")
					if err := cmd.Run(); err != nil {
						fmt.Println("Error:", err)
					}
					log.Println("script done")
				}
				_ = <-t.lockCh
			}()
		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			log.Println("error:", err)
		case _, ok := <-t.doneCh:
			if !ok {
				return
			}
		}
	}
}

func main() {
	flag.Usage = func() {
		fmt.Println("usage:", os.Args[0], " config.yaml")
		flag.PrintDefaults()
	}

	flag.Parse()
	if flag.NArg() < 1 {
		flag.Usage()
		os.Exit(1)
	}
	args := flag.Args()

	for _, arg := range args {
		ts, err := configFromYAML(arg)
		if err != nil {
			log.Fatal(err)
		}

		for _, t := range ts {
			fmt.Printf("%+v\n", t)
			go t.run()
		}
	}

	done := make(chan bool)
	<-done
}
