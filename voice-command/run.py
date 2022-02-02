#!/usr/bin/python3

import argparse
import re
import sys
import threading
from os import system

import speech_recognition as sr
import yaml

import listener as lst

# https://github.com/Uberi/speech_recognition/blob/master/reference/library-reference.rst

parser = argparse.ArgumentParser()
parser.add_argument(
    '--config-file',
    help='file specifying rules and commands',
    default='config.yaml')
parser.add_argument(
    '--recognizer',
    help='specify method of speech recognition',
    default='sphinx',
    choices=[
        'sphinx',
         'google'])
parser.add_argument(
    '-v',
    '--verbose',
    help='verbose output',
    action='store_true')
parser.add_argument(
    '-l',
    '--list-mic',
    help='list available microphones',
    action='store_true')
parser.add_argument(
    '-i',
    '--device-index',
    help='microphone index (see `--list-mic`) to use',
    default=None,
    type=int)
parser.add_argument(
    '-t',
    '--phrase-time-limit',
    default=10,
    type=int)

rule_list = []
verbose = False
rec_mode = 'sphinx'


def parse_rules(file):
    try:
        with open(file, 'r') as stream:
            try:
                return yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print('Error parsing file:', exc)
                return None
    except FileNotFoundError as e:
        print("File not found:", e)
        return None


def main():
    args = parser.parse_args()

    if args.list_mic:
        mic_names = sr.Microphone.list_microphone_names()
        [print(str(n) + ": " + mic_names[n]) for n in range(len(mic_names))]
        return

    rules = parse_rules(args.config_file)
    global rule_list
    rule_list = [(re.compile(r['reg']), r['cmd']) for r in rules['rules']]
    if args.verbose:
        global verbose
        verbose = True
    global rec_mode
    rec_mode = args.recognizer

    print("----------------RULES----------------")
    [print(a.pattern + (' ' * max(39 - len(a.pattern), 0)) + ' =  ' + b)
     for (a, b) in rule_list]

    print("-----------------MIC-----------------")

    l = lst.Listener()
    i = 0
    for exp, cmd in rule_list:
        def thing(c):
            return lambda x: system(c.format(*x))
        l.add_rule(i, exp, thing(cmd))
        i += 1
    stop_listening = l.run(verbose=args.verbose, recognizer=args.recognizer,
                           device_index=args.device_index, phrase_time_limit=args.phrase_time_limit)

    print("-------------------------------------")

    e = threading.Event()

    try:
        e.wait()
    except KeyboardInterrupt:
        print("Interrupt...")
        stop_listening()


if __name__ == "__main__":
    main()
