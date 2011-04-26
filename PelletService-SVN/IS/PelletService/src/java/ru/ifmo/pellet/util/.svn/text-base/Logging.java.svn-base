package ru.ifmo.pellet.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Stack;

/**
 * Created Nov 30, 2010 7:24:05 PM by podtelkin
 *
 * @author Fedor Podtelkin
 */
public class Logging {

    private static ThreadLocal<SimpleDateFormat> DF = new ThreadLocal<SimpleDateFormat>() {
        protected SimpleDateFormat initialValue() {
            return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        }
    };

    private static class TimeAndMsg {
        private final long enter;
        private final String msg;

        private TimeAndMsg(String msg) {
            this.enter = System.currentTimeMillis();
            this.msg = msg;
        }
    }

    private static ThreadLocal<Stack<TimeAndMsg>> INV_STACK = new ThreadLocal<Stack<TimeAndMsg>>() {
        protected Stack<TimeAndMsg> initialValue() {
            return new Stack<TimeAndMsg>();
        }
    };

    private final String clazz;

    public Logging(Class clazz) {
        this.clazz = clazz.getName();
    }

    public void enter(String msg) {
        debug("E: " + msg);
        INV_STACK.get().push(new TimeAndMsg(msg));
    }

    public void debug(String msg) {
        System.out.println("[" + DF.get().format(new Date()) + "] DEBUG " + clazz + " - " + msg);
    }

    public void leave() {
        TimeAndMsg tm = INV_STACK.get().pop();
        debug("L[" + (System.currentTimeMillis() - tm.enter) + "ms]: " + tm.msg);
    }

    public void error(String msg, Throwable e) {
        System.err.println("[" + DF.get().format(new Date()) + "] ERROR " + clazz + " - " + msg);
        if (e != null)
            e.printStackTrace();
    }

}
