import { NativeModules, DeviceEventEmitter, Platform, EmitterSubscription } from "react-native";

const { Orientation: OrientationNativeModule } = NativeModules;

type OrientationType = 'PORTRAIT' | 'LANDSCAPE' | 'PORTRAITUPSIDEDOWN' | 'UNKNOWN';
type OrientationCallbackWithError = (error: any, orientation: OrientationType) => void;
type OrientationCallback = (orientation: OrientationType) => void;
const LINKING_ERROR =
    `The package 'react-native-cocos2dx' doesn't seem to be linked. Make sure: \n\n` +
    Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
    '- You rebuilt the app after installing the package\n' +
    '- You are not using Expo managed workflow\n';
export const Orientation: {
  getOrientation(cb: OrientationCallbackWithError): void;
  getSpecificOrientation(cb: OrientationCallbackWithError): void;
  lockToPortrait(): void;
  lockToLandscape(): void;
  lockToLandscapeRight(): void;
  lockToLandscapeLeft(): void;
  unlockAllOrientations(): void;
  initialOrientation: OrientationType;
} =
    OrientationNativeModule ||
    new Proxy(
        {},
        {
          get() {
            throw new Error(LINKING_ERROR);
          },
        }
    );

var listeners: { [index: string]: EmitterSubscription | null } = {};
var orientationDidChangeEvent = 'orientationDidChange';
var specificOrientationDidChangeEvent = 'specificOrientationDidChange';
var uiOrientationDidChangeEvent = 'uiOrientationDidChange';

var id = 0;
var META = '__listener_id';

interface KeyListener extends Function {
  [key: string]: any;
}
function getKey(listener: KeyListener) {
  if (!listener.hasOwnProperty(META)) {
    if (!Object.isExtensible(listener)) {
      return 'F';
    }

    Object.defineProperty(listener, META, {
      value: 'L' + ++id,
    });
  }

  return listener[META];
};


export default {
  getOrientation(cb: OrientationCallbackWithError) {
    Orientation.getOrientation((error,orientation) =>{
      cb(error, orientation);
    });
  },

  getSpecificOrientation(cb: OrientationCallbackWithError) {
    Orientation.getSpecificOrientation((error,orientation) =>{
      cb(error, orientation);
    });
  },

  lockToPortrait() {
    Orientation.lockToPortrait();
  },

  lockToLandscape() {
    Orientation.lockToLandscape();
  },

  lockToLandscapeRight() {
    Orientation.lockToLandscapeRight();
  },

  lockToLandscapeLeft() {
    Orientation.lockToLandscapeLeft();
  },

  unlockAllOrientations() {
    Orientation.unlockAllOrientations();
  },

  addOrientationListener(cb: OrientationCallback) {
    var key = getKey(cb);
    listeners[key] = DeviceEventEmitter.addListener(orientationDidChangeEvent,
        (body) => {
          cb(body.orientation);
        });
  },

  removeOrientationListener(cb: OrientationCallback | OrientationCallbackWithError) {
    var key = getKey(cb);

    listeners[key]?.remove();
    listeners[key] = null;
  },

  addSpecificOrientationListener(cb: OrientationCallback) {
    var key = getKey(cb);

    listeners[key] = DeviceEventEmitter.addListener(specificOrientationDidChangeEvent,
        (body) => {
          cb(body.specificOrientation);
        });
  },

  removeSpecificOrientationListener(cb: OrientationCallback | OrientationCallbackWithError) {
    var key = getKey(cb);

    listeners[key]?.remove();
    listeners[key] = null;
  },

  addUiOrientationListener(cb: OrientationCallback) {
    var key = getKey(cb);

    listeners[key] = DeviceEventEmitter.addListener(uiOrientationDidChangeEvent,
        (body) => {
          cb(body.uiOrientation);
        });
  },

  removeUiOrientationListener(cb: OrientationCallback | OrientationCallbackWithError) {
    var key = getKey(cb);

    listeners[key]?.remove();
    listeners[key] = null;
  },

  getInitialOrientation() {
    return Orientation.initialOrientation;
  }
}
