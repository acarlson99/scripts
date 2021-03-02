#!/usr/bin/python3

import yaml
import argparse
import speech_recognition as sr
import threading
from os import system
import re
import time

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

rule_list = []
verbose = False
rec_mode = 'sphinx'


def callback(rcvr, audio):
    try:
        inp = None
        if rec_mode == 'sphinx':
            inp = rcvr.recognize_sphinx(audio)
        elif rec_mode == 'google':
            inp = rcvr.recognize_google(audio)
        if verbose:
            print("AUDIO:", inp)
        handle_input(inp, rule_list)
    except Exception as e:
        if verbose:
            print('EXCEPTION:', e)


def exec_command(match, cmd):
    if verbose:
        print("match:", match)
        print("cmd:", cmd)
        print('executing:', cmd.format(*match))
    system(cmd.format(*match))
    return match


def handle_input(txt, rule_list):
    for (reg, cmd) in rule_list:
        match = re.search(reg, txt)
        if not match:
            continue
        return exec_command(match.groups(), cmd)


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
    device_count = sr.Microphone.get_pyaudio().PyAudio().get_device_count()

    r = sr.Recognizer()
    m = None

    if args.device_index is not None:
        if args.device_index > device_count - 1 or args.device_index < 0:
            print("WARNING: invalid device index")
        m = sr.Microphone(device_index=args.device_index)
    else:
        m = sr.Microphone()

    e = threading.Event()

    with m as source:
        r.adjust_for_ambient_noise(source)  # reduce noise

    stop_listening = r.listen_in_background(
        source, callback, phrase_time_limit=10)

    print("-------------------------------------")
    try:
        e.wait()
    except KeyboardInterrupt:
        print("Interrupt...")
        stop_listening()


if __name__ == "__main__":
    main()
