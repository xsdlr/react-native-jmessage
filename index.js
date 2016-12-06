import {
  NativeModules, 
  Platform, 
  NativeEventEmitter,
} from 'react-native';
import Base64 from 'base-64';
import {requsetMediaURL} from './lib/restApi';
import camelcaseKeys from 'camelcase-keys';

const JMessageModule = NativeModules.JMessageModule;

export default class JMessage {
  static eventEmitter = new NativeEventEmitter(JMessageModule);
  static appKey = JMessageModule.AppKey;
  static masterSecret = JMessageModule.MasterSecret;
  static authKey = Base64.encode(`${JMessage.appKey}:${JMessage.masterSecret}`);
  static defaultEventNames = ['onReceiveMessage', 'onSendMessage'];

  static addReceiveMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onReceiveMessage', (_message) => {
      const message = camelcaseKeys(_message, {deep: true});
      const {content = {}} = message;
      if (content.mediaId) {
        requsetMediaURL(JMessage.authKey, content.mediaId).then((data) => {
          message.content.mediaLink = data.url;
          cb(message);
        }).catch(() => cb(message));
      } else {
        cb(message);
      }
    });
  }
  static addSendMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onSendMessage', (_message) => {
      const message = camelcaseKeys(_message, {deep: true});
      cb(message);
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
  static sendSingleMessage({name, type, data={}}) {
    return JMessageModule.sendSingleMessage(name, type, data);
  }
}