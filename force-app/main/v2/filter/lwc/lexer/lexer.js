const Kind = {
  WHITESPACE: "WHITESPACE",
  NUM: "NUM",
  LPAREN: "LPAREN",
  RPAREN: "RPAREN",
  LOGICALAND: "LOGICALAND",
  LOGICALOR: "LOGICALOR"
};
const State = {
  START: "START",
  ZERO: "ZERO",
  NUM: "NUM",
  WHITESPACE: "WHITESPACE",
  LPAREN: "LPAREN",
  RPAREN: "RPAREN",
  A: "A",
  AN: "AN",
  LOGICALAND: "LOGICALAND",
  O: "O",
  LOGICALOR: "LOGICALOR"
};
class Transition {
  fromState;
  chars;
  toState;
  constructor(fromState, chars, toState) {
    this.fromState = fromState;
    this.chars = chars;
    this.toState = toState;
  }
}
class DFA {
  curState;
  transition;
  stateKindMap = {
    [State.ZERO]: Kind.NUM,
    [State.NUM]: Kind.NUM,
    [State.WHITESPACE]: Kind.WHITESPACE,
    [State.LPAREN]: Kind.LPAREN,
    [State.RPAREN]: Kind.RPAREN,
    [State.LOGICALAND]: Kind.LOGICALAND,
    [State.LOGICALOR]: Kind.LOGICALOR
  };
  table = [
    new Transition(State.START, " \t\n", State.WHITESPACE),
    new Transition(State.START, "0", State.ZERO),
    new Transition(State.START, "123456789", State.NUM),
    new Transition(State.NUM, "0123456789", State.NUM),
    new Transition(State.START, "(", State.LPAREN),
    new Transition(State.START, ")", State.RPAREN),
    new Transition(State.START, "Aa", State.A),
    new Transition(State.A, "Nn", State.AN),
    new Transition(State.AN, "Dd", State.LOGICALAND),
    new Transition(State.START, "Oo", State.O),
    new Transition(State.O, "Rr", State.LOGICALOR)
  ];
  constructor() {
    this.curState = State.START;
  }
  nextChar(next) {
    const t = this.findTransition(this.curState, next);
    if (t !== null) this.curState = t.toState;
    return t !== null;
  }
  isAccepting() {
    return !!this.stateKindMap[this.curState];
  }
  reset() {
    this.curState = State.START;
  }
  getKind() {
    return this.stateKindMap[this.curState];
  }
  findTransition(state, c) {
    for (let t of this.table) if (t.fromState === state && t.chars.indexOf(c) !== -1) return t;
    return null;
  }
}

export class Lexer {
  static tokenize(input) {
    const tokens = [];
    if (!input) {
      return tokens;
    }
    const dfa = new DFA();
    dfa.reset();
    let lexemeBeginIndex = 0,
      curIndex = 0,
      lastAcceptedIndex = 0;
    let lastAcceptedKind = null;
    let eof = false;
    while (true) {
      if (!eof && dfa.nextChar(input.substr(curIndex, 1))) {
        if (dfa.isAccepting()) {
          lastAcceptedIndex = curIndex;
          lastAcceptedKind = dfa.getKind();
        }
        curIndex++;
      } else {
        if (lastAcceptedKind !== null && lastAcceptedKind !== Kind.WHITESPACE) {
          const lexeme = input.substring(lexemeBeginIndex, lastAcceptedIndex + 1);
          const t = {kind: lastAcceptedKind, lexeme};
          tokens.push(t);
        } else if (eof || lastAcceptedKind === null) {
          if (curIndex > lexemeBeginIndex) throw new Error("Lexer threw an error while reading '" + input.substring(lexemeBeginIndex) + "'");
          break;
        }
        curIndex = lexemeBeginIndex = ++lastAcceptedIndex;
        dfa.reset();
        lastAcceptedKind = null;
      }
      eof = curIndex >= input.length;
    }
    return tokens;
  }
}
