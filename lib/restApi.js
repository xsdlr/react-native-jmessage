
import * as Utils from './utils';

const baseApiURL = 'https://api.im.jpush.cn';

const fecthJiguangApi = ({authKey, method = 'get', query, data, url}) => {
  return fetch(`${baseApiURL}${url}${Utils.queryTransform(query)}`, {
    method: method,
    headers: {
      'Authorization': `Basic ${authKey}`,
      'Content-Type': 'application/json; charset=utf-8'
    },
    body: data
  }).then(function(response) {
    return response.json()
  }).then((json) => {
    const error = json.error;
    if (error) {
      console.error('api error', error);
      throw new Error(error.message, error.code);
    } else {
      return json;
    }
  });
};

export const requsetMediaURL = (authKey, mediaID) => {
  const query = {
    mediaId: mediaID,
  };
  const url = '/v1/resource';
  return fecthJiguangApi({authKey, query, url});
};
