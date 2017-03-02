package com.xsdlr.rnjmessage;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

/**
 * Created by xsdlr on 2016/12/16.
 */
public class Utils {
    public static <T> T defaultValue(T value, T defaultValue) {
        return value == null ? defaultValue : value;
    }
    public static String base64Encode(File file){
        String encodedFile = null;
        try {
            FileInputStream fileInputStreamReader = new FileInputStream(file);
            byte[] bytes = new byte[(int)file.length()];
            fileInputStreamReader.read(bytes);
            encodedFile = Base64.encodeToString(bytes, Base64.DEFAULT);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return encodedFile;
    }
    public static String base64Encode(File image, Bitmap.CompressFormat format) {
        Bitmap bm = BitmapFactory.decodeFile(image.getAbsolutePath());
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bm.compress(format, 100, baos);
        byte[] byteArray = baos.toByteArray();
        return Base64.encodeToString(byteArray, Base64.DEFAULT);
    }
    public static String base64Encode(String string) {
        return Base64.encodeToString(string.getBytes(), Base64.DEFAULT);
    }
    public static String base64Decode(String string) {
        return new String(Base64.decode(string.getBytes(), Base64.DEFAULT));
    }
    public static boolean isEmpty(String str) {
        return str == null || str.trim().length() == 0;
    }
}
