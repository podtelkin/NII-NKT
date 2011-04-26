package ru.ifmo.pellet.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Created Dec 20, 2010 8:32:30 PM by podtelkin
 *
 * @author Fedor Podtelkin
 */
public class GUID {

    private static final int LEN = 16;
    private static final List<Character> CHARS;
    static {
        CHARS = new ArrayList<Character>();
        for (char c = '0'; c <= '9'; c++)
            CHARS.add(c);
        for (char c = 'A'; c <= 'Z'; c++)
            CHARS.add(c);
    }
    private static final Random RND = new Random();

    public static String newID() {
        char[] result = new char[LEN];
        for (int i = 0; i < LEN; i++)
            result[i] = CHARS.get(RND.nextInt(CHARS.size()));
        return new String(result);
    }

}
