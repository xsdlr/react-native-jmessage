package com.xsdlr.rnjmessage.model;

/**
 * Created by xsdlr on 2017/3/8.
 */

public class ConversationIDJSONModel {
    public String id;
    public Integer type;
    public String appkey;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getAppkey() {
        return appkey;
    }

    public void setAppkey(String appkey) {
        this.appkey = appkey;
    }
}
