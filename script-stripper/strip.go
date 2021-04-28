package main

// script stripper

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	"golang.org/x/net/html" // go get -u golang.org etc...

	"github.com/gorilla/mux"
)

func enableCors(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		h.ServeHTTP(w, r)
	})
}

// https://www.washingtonpost.com/immigration/ed-gonzalez-ice/2021/04/27/3c25c7c6-a785-11eb-bca5-048b2759a489_story.html
func stripFromURL(w http.ResponseWriter, r *http.Request) {
	url := r.URL.Query().Get("url")
	// fmt.Println("GET", url)

	resp, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	w.Write(removeScript(string(body)))
}

// TODO: read from request body, not url
func stripFromData(w http.ResponseWriter, r *http.Request) {
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	defer r.Body.Close()

	w.Write(removeScript(string(data)))
}

func removeScript(s string) []byte {
	doc, err := html.Parse(strings.NewReader(s))
	if err != nil {
		log.Fatal(err)
	}
	removeScriptFromNode(doc)
	buf := bytes.NewBufferString("")
	if err := html.Render(buf, doc); err != nil {
		log.Fatal(err)
	}
	return buf.Bytes()
}

func removeScriptFromNode(n *html.Node) {
	// traverse DOM
	next := n.FirstChild
	for next != nil {
		c := next
		next = next.NextSibling
		if c.Type == html.ElementNode && c.Data == "script" {
			n.RemoveChild(c)
		} else {
			removeScriptFromNode(c)
		}
	}
}

// curl http://localhost:8080/data/ --data '<div>bbbbbb<script>console.log("AAAAAAA")</script><script>alert("A")</script><script>alert("A")</script>AAAAAAAaaaaaaaAAAAA</div>'
// curl 'http://localhost:8080/url/?url=https://www.washingtonpost.com/immigration/ed-gonzalez-ice/2021/04/27/3c25c7c6-a785-11eb-bca5-048b2759a489_story.html'
func main() {
	srv := flag.Bool("serve", false, "run server")
	file := flag.String("file", "", "strip from file")
	stdin := flag.Bool("stdin", false, "read from stdin")
	flag.Parse()

	if *srv {
		r := mux.NewRouter()
		r.Use(enableCors)
		r.HandleFunc("/url/", stripFromURL)
		r.HandleFunc("/data/", stripFromData)
		http.ListenAndServe(":8080", r)
	} else if *stdin {
		stdin := bufio.NewReader(os.Stdin)
		a, err := ioutil.ReadAll(stdin)
		if err != nil {
			panic(err)
		}
		fmt.Println(string(removeScript(string(a))))
	} else if *file != "" {
		a, err := ioutil.ReadFile(*file)
		if err != nil {
			panic(err)
		}
		fmt.Println(string(removeScript(string(a))))
	} else {
		flag.Usage()
	}
}
