import {
  NativeModules, 
  Platform, 
  NativeEventEmitter,
} from 'react-native';
import Base64 from 'base-64';
import { requsetMediaURL } from './lib/restApi';
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
      supportMessageMediaURL(_message).then((message) => cb(message));
    });
  }

  static addSendMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onSendMessage', (_message) => {
      suppleMessgaeMediaURL(_message).then((message) => cb(message));
    });
  }
  static removeAllListener(eventNames = JMessage.defaultEventNames) {
    JMessage.eventEmitter.removeAllListeners(eventNames);
  }
  static login(username, password) {
    return JMessageModule.login(username, password).then((info) => {
      const {avatar} = info;
      if(avatar) {
        return requsetMediaURL(JMessage.authKey, avatar).then((data) => {
          return {...info, ...{avatar: data.url}};
        })
      } else {
        return info;
      }
    });
  }
  static logout() {
    return JMessageModule.logout();
  }
  static sendSingleMessage({name, type, data={}, timeout=30000}) {
    return JMessageModule.sendSingleMessage(name, type, data, timeout);
  }
  static allConversations() {
    return JMessageModule.allConversations();
  }
  static historyMessages(cid, offset=0, limit=0) {
    return JMessageModule.historyMessages(cid, offset, limit)
      .then(messages => Promise.all(messages.map((message) => supportMessageMediaURL(message))));
  }
}

const supportMessageMediaURL = (_message) => {
  return new Promise((resolve, reject) => {
    const message = camelcaseKeys(_message, {deep: true});
    const {content = {}} = message;
    if (content.mediaId) {
      requsetMediaURL(JMessage.authKey, content.mediaId).then((data) => {
        message.content.mediaLink = data.url;
        resolve(message);
      }).catch(() => resolve(message));
    } else {
      resolve(message);
    }
  });
};