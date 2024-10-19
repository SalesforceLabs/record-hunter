class RuntimeError extends Error {
  constructor(errorCode, ...params) {
    super(...params);
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, RuntimeError);
    }

    this.name = "RecordHunterRuntimeError";
    // Custom debugging information
    this.code = errorCode;
  }
}

class ConfigurationError extends Error {
  constructor(errorCode, ...params) {
    super(...params);
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, ConfigurationError);
    }

    this.name = "RecordHunterConfigurationError";
    this.code = errorCode;
  }
}

const throwConfigurationError = (error, errorCode) => {
  let errorMessage = "";
  if (typeof error === "string") {
    errorMessage = error;
  } else if (Array.isArray(error.body)) {
    errorMessage = error.body.map((e) => e.message).join(", ");
  } else if (typeof error.body?.message === "string") {
    errorMessage = error.body.message;
  }
  throw new ConfigurationError(errorCode, errorMessage);
};

const throwRuntimeError = (error, errorCode) => {
  let errorMessage = "";
  if (typeof error === "string") {
    errorMessage = error;
  } else if (Array.isArray(error.body)) {
    errorMessage = error.body.map((e) => e.message).join(", ");
  } else if (typeof error.body.message === "string") {
    errorMessage = error.body.message;
  }
  throw new RuntimeError(errorCode, errorMessage);
};

export {
  RuntimeError,
  ConfigurationError,
  throwConfigurationError,
  throwRuntimeError
};
