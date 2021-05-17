import re
import speech_recognition as sr


class Rule:
    cb = None
    expr = None

    def __init__(self, expr, callback):
        t = type(expr)
        if t == str:
            self.expr = re.compile(expr)
        elif t == re.Match:
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

    def sr_callback_(self, rcvr, audio):
        try:
            inp = None
            if rec_mode == 'sphinx':
                inp = rcvr.recognize_sphinx(audio)
            elif rec_mode == 'google':
                inp = rcvr.recognize_google(audio)
            if self.verbose:
                print("AUDIO:", inp)

            for name, rule in self.rule_dict:
                match = rule.expr.search(inp)
                if not match:
                    continue
                groups = match.groups()

                if self.verbose:
                    print("name:", name)
                    print("groups:", groups)
                    print("cmd:", cmd)
                rule.cb(*groups)

        except Exception as e:
            if self.verbose:
                print('EXCEPTION:', e)

    def add_rule(self, name, expr, callback):
        r = Rule(expr, callback)
        self.rule_dict[name] = r

    def remove_rule(self, name):
        del(self.rule_dict[name])

    def run(self, verbose=False, recognizer='sphinx', device_index=None, phrase_time_limit=10):
        self.verbose = verbose
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
