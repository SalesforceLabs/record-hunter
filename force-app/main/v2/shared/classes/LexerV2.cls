public class LexerV2 {
  public class LexerException extends Exception {
  }
  public enum Kind {
    WHITESPACE,
    NUM,
    LPAREN,
    RPAREN,
    LOGICALAND,
    LOGICALOR
  }
  public class Token {
    public Kind kind;
    public String lexeme;
    public Token(Kind kind, String lexeme) {
      this.kind = kind;
      this.lexeme = lexeme;
    }
  }
  public static List<Token> tokenize(String input) {
    List<Token> tokens = new List<Token>();
    if (String.isBlank(input))
      return tokens;

    DFA dfa = new DFA();
    dfa.reset();

    Integer lexemeBeginIndex = 0, curIndex = 0, lastAcceptedIndex = 0;
    Kind lastAcceptedKind = null;
    boolean eof = false;
    while (true) {
      if (!eof && dfa.nextChar(input.mid(curIndex, 1))) {
        if (dfa.isAccepting()) {
          lastAcceptedIndex = curIndex;
          lastAcceptedKind = dfa.getKind();
        }
        curIndex++;
      } else {
        if (lastAcceptedKind != null && lastAcceptedKind != Kind.WHITESPACE) {
          String lexeme = input.substring(lexemeBeginIndex, lastAcceptedIndex + 1);
          Token t = new Token(lastAcceptedKind, lexeme);
          tokens.add(t);
        } else if (eof) {
          if (curIndex > lexemeBeginIndex)
            throw new LexerException('Lexer threw an error while reading \'' + input.substring(lexemeBeginIndex) + '\'');
          break;
        }
        curIndex = lexemeBeginIndex = ++lastAcceptedIndex;
        dfa.reset();
        lastAcceptedKind = null;
      }
      eof = curIndex >= input.length();
    }
    return tokens;
  }

  /*
   * DFA
   */
  private class Transition {
    State fromState;
    String chars;
    State toState;
    Transition(State fromState, String chars, State toState) {
      this.fromState = fromState;
      this.chars = chars;
      this.toState = toState;
    }
  }
  private enum State {
    START,
    ZERO,
    NUM,
    WHITESPACE,
    LPAREN,
    RPAREN,
    A,
    AN,
    LOGICALAND,
    O,
    LOGICALOR
  }
  private class DFA {
    private State curState;
    private Map<State, Kind> stateKindMap;
    private List<Transition> table;
    private Map<Set<Object>, State> transition = new Map<Set<Object>, State>();
    public DFA() {
      this.stateKindMap = new Map<State, Kind>();
      this.stateKindMap.put(State.ZERO, Kind.NUM);
      this.stateKindMap.put(State.NUM, Kind.NUM);
      this.stateKindMap.put(State.WHITESPACE, Kind.WHITESPACE);
      this.stateKindMap.put(State.LPAREN, Kind.LPAREN);
      this.stateKindMap.put(State.RPAREN, Kind.RPAREN);
      this.stateKindMap.put(State.LOGICALAND, Kind.LOGICALAND);
      this.stateKindMap.put(State.LOGICALOR, Kind.LOGICALOR);

      this.table = new List<Transition>();
      this.table.add(new Transition(State.START, ' \t\n', State.WHITESPACE));
      this.table.add(new Transition(State.START, '0', State.ZERO));
      this.table.add(new Transition(State.START, '123456789', State.NUM));
      this.table.add(new Transition(State.NUM, '0123456789', State.NUM));
      this.table.add(new Transition(State.START, '(', State.LPAREN));
      this.table.add(new Transition(State.START, ')', State.RPAREN));
      this.table.add(new Transition(State.START, 'Aa', State.A));
      this.table.add(new Transition(State.A, 'Nn', State.AN));
      this.table.add(new Transition(State.AN, 'Dd', State.LOGICALAND));
      this.table.add(new Transition(State.START, 'Oo', State.O));
      this.table.add(new Transition(State.O, 'Rr', State.LOGICALOR));

      this.curState = State.START;
    }
    public Boolean nextChar(String next) {
      Transition t = findTransition(curState, next);
      if (t != null)
        curState = t.toState;
      return t != null;
    }
    public Boolean isAccepting() {
      return this.stateKindMap.get(curState) != null;
    }
    public Void reset() {
      curState = State.START;
    }
    public Kind getKind() {
      return stateKindMap.get(curState);
    }
    private Transition findTransition(State state, String c) {
      for (Transition t : table)
        if (t.fromState == state && t.chars.contains(c))
          return t;
      return null;
    }
  }
}
