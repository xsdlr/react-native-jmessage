import {
  NativeModules, 
  Platform, 
  NativeEventEmitter,
} from 'react-native';
import Base64 from 'base-64';
import { requsetMediaURL } from './lib/restApi';
import camelcaseKeys from 'camelcase-keys';
import _ from 'lodash';

const JMessageModule = NativeModules.JMessageModule;

export default class JMessage {
  static eventEmitter = new NativeEventEmitter(JMessageModule);
  static appKey = JMessageModule.AppKey;
  static masterSecret = JMessageModule.MasterSecret;
  static authKey = Base64.encode(`${JMessage.appKey}:${JMessage.masterSecret}`);
  static defaultEventNames = ['onReceiveMessage', 'onSendMessage'];

  static addReceiveMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onReceiveMessage', (message) => {
      const _message = formatMessage(message);
      // console.log("JMessage.authKey", JMessageModule.AppKey, JMessageModule.MasterSecret);
      supportMessageMediaURL(_message).then((message) => cb(message));
    });
  }

  static addSendMessageListener(cb) {
    return JMessage.eventEmitter.addListener('onSendMessage', (message) => {
      const _message = formatMessage(message);
      supportMessageMediaURL(_message).then((message) => cb(message));
    });
  }
  static removeAllListener(eventNames = JMessage.defaultEventNames) {
    JMessage.eventEmitter.removeAllListeners(eventNames);
  }
  static init() {
    if (Platform.OS === 'android') {
      JMessageModule.setupJMessage();
    }
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
  static sendSingleMessage({name, type, data={}}) {
    return JMessageModule.sendSingleMessage(name, type, data);
  }
  static allConversations() {
    return JMessageModule.allConversations();
  }
  static historyMessages(cid, offset=0, limit=0) {
    return JMessageModule.historyMessages(cid, offset, limit)
      .then(messages => Promise.all(messages.map((message) => supportMessageMediaURL(message))));
  }
}

const supportMessageMediaURL = (message) => {
  return new Promise((resolve, reject) => {
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

const formatMessage = (message) => {
  const _message = _.cloneDeep(message)
  try {
    _message.content = JSON.parse(_message.content);
  } catch (ex) {
    _message.contentJSONString = _message.content;
    _message.content = {};
  }
  return camelcaseKeys(_message, {deep: true});
};