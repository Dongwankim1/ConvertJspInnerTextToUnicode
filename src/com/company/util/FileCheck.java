package com.company.util;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * \* Created with IntelliJ IDEA.
 * \* @author: kim-dong-wan
 * \* Date: 2022/05/18
 * \* Time: 2:50 오후
 * \* To change this template use File | Settings | File Templates.
 * \* Description:
 * \
 */

public class FileCheck {
    public static List<File> findJspFile(String path, String ext){

        List<File> result = new ArrayList<File>();
        result = TreeParser(path,result,ext);

        for(File item : result){
            System.out.println(item.toPath().toString());
        }
        return result;
    }

    private static List<File> TreeParser(String path,List<File> result,String ext){
        File dir = new File(path);

        if(dir.isFile()){
            String fileName = dir.getName();
            String extDummy = fileName.substring(fileName.lastIndexOf(".") + 1);
            if(extDummy.equals(ext)){
                result.add(dir);
            }
            return result;

        }else if(dir.isDirectory()){
            File files[] = dir.listFiles();

            for(File item : files){
                TreeParser(item.toPath().toString(),result,ext);
            }


        }



        return result;
    }
}
