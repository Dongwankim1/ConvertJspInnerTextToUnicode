package com.company.util;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import java.io.*;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

/**
 * \* Created with IntelliJ IDEA.
 * \* @author: kim-dong-wan
 * \* Date: 2022/05/18
 * \* Time: 1:52 오후
 * \* To change this template use File | Settings | File Templates.
 * \* Description:
 * \
 */

public class JspParser {
    private File file ;
    private List<File> files ;
    public JspParser(File file) {
        this.file = file;
    }

    public JspParser(List<File> files) {
        this.files = files;
    }


    public List<File> allConvertJspToUnicode(String startRgx,String endRgx){
        Stack<String> htmlStack = new Stack<>();
        Stack<String> textStack = new Stack<>();
        for(File file : this.files){
            try {
                FileReader br = new FileReader(file);
                String line = "";
                String innerText= "";
                String allText = "";
                boolean isStartCheck = false;
                boolean isStartText = false;
                int i;
                while((i=br.read())!=-1) {

                    char word = (char) i;
                    allText+=word;
                    //find < or >
                    if(word=='<' || isStartCheck){
                        if(innerText.length()>0){
                            isStartText = false;
                            textStack.push(innerText);
                            innerText="";
                        }

                        line+=word;
                        //if line variable is '<%' , reset line variable
                        if(line.equals("<%")){
                            line = "";
                            isStartCheck = false;
                        }

                        isStartCheck = true;


                        if(word=='>'){
                            isStartCheck = false;
                            isStartText = true;
                            htmlStack.push(line);
                            line="";
                            continue;
                        }


                    }

                    if(isStartText){
                        innerText += word;

                    }

                }

                br.close();
                System.out.println(line);
                for(String h : htmlStack){
                    System.out.println(h);
                }

                for(String h : textStack){
                    System.out.println(h);
                }

                System.out.println(allText);
                break;
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }

        }



        return files;
    }




}
