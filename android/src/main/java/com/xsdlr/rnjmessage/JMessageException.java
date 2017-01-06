package com.xsdlr.rnjmessage;

/**
 * Created by xsdlr on 2016/12/15.
 */
public class JMessageException extends Exception {
    final static JMessageException ACTIVITY_NOT_EXIST = new JMessageException("1800001", "activity不存在");
    final static JMessageException ILLEGAL_ARGUMENT_EXCEPTION = new JMessageException("1800002", "参数不正确");
    // Message (1865xxx)
    final static JMessageException MESSAGE_CONTENT_INVALID = new JMessageException("1865001", "无效的消息内容");
    final static JMessageException MESSAGE_CONTENT_NULL = new JMessageException("1865002", "内容资源不存在");
    final static JMessageException MESSAGE_CONTENT_NOT_PREPARED = new JMessageException("1865003", "消息不符合发送的基本条件检查");
    final static JMessageException MESSAGE_CONTENT_TYPE_NOT_SUPPORT = new JMessageException("1865100", "收到不支持消息内容类型(目前只支持文本和图片)");
    final static JMessageException MESSAGE_SEND_TIMEOUT = new JMessageException("1865101", "消息发送超时");
    // Conversation (1866xxx)
    final static JMessageException CONVERSATION_ID_EMPTY = new JMessageException("1866001", "空会话id");
    final static JMessageException CONVERSATION_INVALID = new JMessageException("1866002", "会话无效");

    private String code;
    protected JMessageException(String code, String detailMessage) {
        super(detailMessage);
        this.code = code;
    }
    public String getCode() {
        return code;
    }
}
