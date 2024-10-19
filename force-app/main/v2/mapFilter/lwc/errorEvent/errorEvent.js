class BaseErrorEvent extends CustomEvent {
  constructor(type, error) {
    super("error", {
      detail: {
        type,
        message: error.message,
        stack: error.stack,
        timestamp: new Date().toISOString()
      },
      bubbles: true,
      composed: true
    });
  }
}

export class ConfigErrorEvent extends BaseErrorEvent {
  constructor(error) {
    super("CONFIG_ERROR", error);
  }
}

export class RuntimeErrorEvent extends BaseErrorEvent {
  constructor(error) {
    super("RUNTIME_ERROR", error);
  }
}

// 型定義用の定数（オプション）
export const ErrorType = {
  CONFIG: "CONFIG_ERROR",
  RUNTIME: "RUNTIME_ERROR"
};
