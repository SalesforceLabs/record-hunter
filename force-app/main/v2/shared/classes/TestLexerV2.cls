@isTest
public class TestLexerV2 {
  @isTest
  static void tokenizeEmpty() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('');
    System.assertEquals(0, tokens.size());
  }
  @isTest
  static void tokenizeZero() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.NUM, tokens[0].kind);
    System.assertEquals('0', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeNum() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('1');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.NUM, tokens[0].kind);
    System.assertEquals('1', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeNumLarge() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('123456789');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.NUM, tokens[0].kind);
    System.assertEquals('123456789', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeNumBeginWithZero() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0123456789');
    System.assertEquals(2, tokens.size());
    System.assertEquals(LexerV2.Kind.NUM, tokens[0].kind);
    System.assertEquals('0', tokens[0].lexeme);
    System.assertEquals(LexerV2.Kind.NUM, tokens[1].kind);
    System.assertEquals('123456789', tokens[1].lexeme);
  }
  @isTest
  static void tokenizeWhitespace() {
    List<LexerV2.Token> tokens = LexerV2.tokenize(' ');
    System.assertEquals(0, tokens.size());
  }
  @isTest
  static void tokenizeLParen() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('(');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LPAREN, tokens[0].kind);
    System.assertEquals('(', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeRParen() {
    List<LexerV2.Token> tokens = LexerV2.tokenize(')');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.RPAREN, tokens[0].kind);
    System.assertEquals(')', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalAndUppercase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('AND');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALAND, tokens[0].kind);
    System.assertEquals('AND', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalAndLowercase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('and');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALAND, tokens[0].kind);
    System.assertEquals('and', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalAndRandomcase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('aNd');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALAND, tokens[0].kind);
    System.assertEquals('aNd', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalOrUppercase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('OR');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALOR, tokens[0].kind);
    System.assertEquals('OR', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalOrLowercase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('or');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALOR, tokens[0].kind);
    System.assertEquals('or', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeLogicalOrRandomcase() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('Or');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALOR, tokens[0].kind);
    System.assertEquals('Or', tokens[0].lexeme);
  }
  @isTest
  static void tokenizeInvalidCharacter() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('b');
    System.assertEquals(0, tokens.size());
  }
  @isTest
  static void tokenizeInvalidSymbol() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('@');
    System.assertEquals(0, tokens.size());
  }
  @isTest
  static void tokenizeSequence() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0AND (1OR2 )');
    System.assertEquals(7, tokens.size());
    System.assertEquals(LexerV2.Kind.Num, tokens[0].kind);
    System.assertEquals(LexerV2.Kind.LOGICALAND, tokens[1].kind);
    System.assertEquals(LexerV2.Kind.LPAREN, tokens[2].kind);
    System.assertEquals(LexerV2.Kind.NUM, tokens[3].kind);
    System.assertEquals(LexerV2.Kind.LOGICALOR, tokens[4].kind);
    System.assertEquals(LexerV2.Kind.NUM, tokens[5].kind);
    System.assertEquals(LexerV2.Kind.RPAREN, tokens[6].kind);
  }
  @isTest
  static void tokenizeSequenceInvalid() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('HELLO WORLD');
    System.assertEquals(1, tokens.size());
    System.assertEquals(LexerV2.Kind.LOGICALOR, tokens[0].kind);
  }
}
