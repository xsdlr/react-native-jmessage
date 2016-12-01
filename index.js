import {
  NativeModules, 
  Platform, 
  NativeEventEmitter,
} from 'react-native';
import Base64 from 'base-64';
import {requsetMediaURL} from './lib/restApi';

const JMessageModule = NativeModules.JMessageModule;

export default class JMessage {
  static eventEmitter = new NativeEventEmitter(JMessageModule);
  static appKey = JMessageModule.AppKey;
  static masterSecret = JMessageModule.MasterSecret;
  static authKey = Base64.encode(`${JMessage.appKey}:${JMessage.masterSecret}`);
  static defaultEventNames = ['onReceiveMessage'];

  static addReceiveMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onReceiveMessage', (message) => {
      const {content = {}} = message;
      if (content.media_id) {
        requsetMediaURL(JMessage.authKey, content.media_id).then((data) => {
          message.content.media_link = data.url;
          cb(message);
        }).catch(() => cb(message));
      } else {
        cb(message);
      }
    });
  }
  static removeAllListener(eventNames = JMessage.defaultEventNames) {
    JMessage.eventEmitter.removeAllListeners(eventNames);
  }
  static login(username, password) {
    return JMessageModule.login(username, password);
  }
  static logout() {
    return JMessageModule.logout();
  }
}