import re

import speech_recognition as sr


def mic_names():
    return sr.Microphone.list_microphone_names()


class Rule:
    cb = None
    expr = None

    def __init__(self, expr, callback):
        '''
        expr:     string or re.Pattern
        callback: something callable() idk
        '''
        t = type(expr)
        if t == str:
            self.expr = re.compile(expr)
        elif t == re.Pattern:
            self.expr = expr
        else:
            raise ValueError('Expr invalid')
        if callable(callback):
            self.cb = callback
        else:
            raise ValueError('Callback not callable')


class Listener:
    def __init__(self):
        self.rule_dict = {}
        self.mode = 'sphinx'

    def sr_callback_(self, rcvr, audio):
        inp = None
        try:
            if self.mode == 'sphinx':
                inp = rcvr.recognize_sphinx(audio)
            elif self.mode == 'google':
                inp = rcvr.recognize_google(audio)
            if self.verbose:
                print("AUDIO:", inp)
        except Exception as e:
            if self.verbose:
                print("RECOGNIZE EXCEPTION:", e)
            return

        for name in self.rule_dict:
            try:
                rule = self.rule_dict[name]
                match = rule.expr.search(inp)
                if not match:
                    continue
                groups = match.groups()

                if self.verbose:
                    print("name:", name)
                    print("groups:", groups)
                    print("cmd:", rule.cb)
                rule.cb(groups)
            except Exception as e:
                if self.verbose:
                    print('EXCEPTION IN', name+':', e)

    def add_rule(self, name, expr, callback):
        '''
        name:     arbitrary name, can be anything really
        expr:     string or re.Pattern
        callback: something callable() idk
        '''
        r = Rule(expr, callback)
        self.rule_dict[name] = r

    def remove_rule(self, name):
        del(self.rule_dict[name])

    def run(self, verbose=False, recognizer='sphinx', device_index=None, phrase_time_limit=10):
        '''
        recognizer:   one of 'google','sphinx'
        device_index: device index as illustrated by `mic_names()`
        '''
        self.verbose = verbose
        if recognizer not in ['google', 'sphinx']:
            raise ValueError(
                'Unsupported recognizer; must be one of: google,sphinx')
        self.mode = recognizer
        m = None

        r = sr.Recognizer()
        device_count = sr.Microphone.get_pyaudio().PyAudio().get_device_count()
        if device_index is not None:
            if device_index > device_count - 1 or device_index < 0:
                raise ValueError('Invalid device index')
            m = sr.Microphone(device_index=device_index)
        else:
            m = sr.Microphone()

        with m as source:
            r.adjust_for_ambient_noise(source)  # reduce noise

        stop_listening = r.listen_in_background(
            source, self.sr_callback_, phrase_time_limit=phrase_time_limit)

        return stop_listening


if __name__ == '__main__':
    import sys

    l = Listener()
    l.add_rule('a', '(?i:(a\\w+))', lambda x: print("A:", x))
    l.add_rule('b', '(?i:wow) (\\w+) (\\w+)', lambda x: print("B:", x))
    print("GOIN")
    stop = l.run(True, 'google')
    sys.stdin.read(1)
