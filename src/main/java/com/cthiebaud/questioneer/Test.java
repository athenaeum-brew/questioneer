package com.cthiebaud.questioneer;

import java.util.ArrayList;
import java.util.List;

public class Test {
    List<?> list = new ArrayList<String>();
    List<? extends Number> list2 = new ArrayList<Integer>();
    List<String> list3 = new ArrayList<>();
    List<? super Integer> list4 = new ArrayList<Number>();
}
