package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"regexp"
	"strings"

	"gopkg.in/yaml.v2"

	"github.com/fsnotify/fsnotify"
)

type Config struct {
	Rules []Rule `yaml:"rules,flow"`
}

type Rule struct {
	Name      string   `yaml:"name"`
	Filenames []string `yaml:"targets"`
	Ignored   []string `yaml:"ignore"`
	Cmd       string   `yaml:"cmd"`
	Args      []string `yaml:"args"`
	Stdout    string   `yaml:"stdout"`
	Stderr    string   `yaml:"stderr"`
}

func interfacesToStrs(is []interface{}) []string {
	ss := []string{}
	for _, i := range is {
		ss = append(ss, i.(string))
	}
	return ss
}

func configFromYAML(fn string) (Config, error) {
	data, err := ioutil.ReadFile(fn)
	if err != nil {
		return Config{}, err
	}

	p := Config{}
	err = yaml.Unmarshal([]byte(data), &p)
	if err != nil {
		return Config{}, err
	}

	return p, nil
}

// write to doneCh to kill goroutine
func (r Rule) run(doneCh chan interface{}) {
	fmt.Printf(`Launching         `+"`%s`"+`
Script:            %v
Watching files:    %+v
Ignoring patterns: %+v
Logging stdout:    %s
        stderr:    %s
`, r.Name, r.Cmd+" "+strings.Join(r.Args, " "), r.Filenames, r.Ignored, r.Stdout, r.Stderr)

	l := log.New(os.Stdout, r.Name+" ", log.LstdFlags)

	// fsnotify setup
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		l.Fatal(r.Name, err)
	}
	defer func() {
		l.Println("DONE")
	}()
	defer watcher.Close()

	for _, fn := range r.Filenames {
		err = watcher.Add(fn)
		if err != nil {
			l.Fatal("`"+fn+"`: ", err)
		}
	}

	lockCh := make(chan interface{}, 1)
	lockCh <- 1

	// fsnotify select loop
	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			go func() {
				_ = <-lockCh
				defer func() {
					lockCh <- 1
				}()
				l.Println("event:", event.Op, event.Name)

				if event.Op&fsnotify.Write == fsnotify.Write {
					// check if need to ignore
					for _, v := range r.Ignored {
						if ok, _ := regexp.MatchString(v, event.Name); ok {
							l.Println("event ignored")
							return
						}
					}

					// create log file streams
					var stdout *os.File
					var stderr *os.File

					if len(r.Stdout) > 0 {
						stdout, err = os.OpenFile(r.Stdout, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
						if err != nil {
							l.Fatal(err)
						}
						defer stdout.Close()
					}
					if len(r.Stderr) > 0 {
						if r.Stdout == r.Stderr {
							stderr = stdout
						} else {
							stderr, err = os.OpenFile(r.Stderr, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
							if err != nil {
								l.Fatal(err)
							}
							defer stderr.Close()
						}
					}

					// run script
					l.Println("modified file:", event.Name)
					cmd := exec.Command(r.Cmd, r.Args...)
					cmd.Stdout = stdout
					cmd.Stderr = stderr
					l.Println("running script")
					if err := cmd.Run(); err != nil {
						l.Println("Error:", err)
					}
					l.Println("script done")
				}
			}()
		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			l.Println("error:", err)
		case _ = <-doneCh:
			_ = <-lockCh
			return
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

	killChs := []chan interface{}{}
	for _, arg := range args {
		p, err := configFromYAML(arg)
		if err != nil {
			log.Fatal(err)
		}

		for _, t := range p.Rules {
			doneCh := make(chan interface{})
			killChs = append(killChs, doneCh)
			go t.run(doneCh)
		}
	}

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	sig := <-c

	fmt.Println("Received", sig, "signal.  Shutting down...")

	for _, c := range killChs {
		close(c)
	}
}
