// Extend Electron app with custom properties
declare global {
  namespace Electron {
    interface App {
      isQuitting?: boolean;
    }
  }
}

export {};
