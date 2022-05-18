package com.company;

import com.company.util.FileCheck;
import com.company.util.JspParser;

import java.io.File;
import java.util.List;

public class Main {

    public static void main(String[] args) {
	// write your code here
        List<File> jspList = FileCheck.findJspFile("/Users/jd-gimdong-wan/project/ConvertJspInnerTextToUnicode/beforeParsingData","jsp");
        JspParser jspParser = new JspParser(jspList);
        jspParser.allConvertJspToUnicode("k","g");

    }
}
