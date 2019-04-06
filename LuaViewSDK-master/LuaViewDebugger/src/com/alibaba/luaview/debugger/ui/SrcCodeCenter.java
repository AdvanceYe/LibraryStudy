package com.alibaba.luaview.debugger.ui;

import java.util.Hashtable;

import javax.swing.JTabbedPane;

import com.alibaba.luaview.debugger.Center;

public class SrcCodeCenter {
	public final Center center;

	public SrcCodeCenter(Center center) {
		this.center = center;
	}

	final Hashtable<String, SrcCodeViewer> table = new Hashtable<String, SrcCodeViewer>();

	public void showHelpTab() {
		String s = "h             help info" + "\n" + //
				"c             continue run" + "\n" + //
				"s             trace" + "\n" + //
				"n             next" + "\n" + //
				"p var         print variable" + "\n" + //
				"b src:line    add breakpoint" + "\n" + //
				"rb src:line   remove breakpoint" + "\n" + //
				"bl            list breakpoint" + "\n" + //
				"bt            print traceback" + "\n";
		loadfile("帮助信息", s).canBreakPoint = false;
	}

	public SrcCodeViewer loadfile(String fileName, String content) {
		content = content.replace("\t", "    ");
		JTabbedPane tabbedPane = center.frame.getTabbedPane();
		if (fileName != null) {
			SrcCodeViewer temp = table.get(fileName);
			tabbedPane.remove(temp);
			table.remove(fileName);
		}
		SrcCodeViewer viewer = new SrcCodeViewer(fileName, content, this.center);
		this.addToTabbedPane(tabbedPane, fileName, viewer);
		table.put(fileName, viewer);
		return viewer;
	}

	private void addToTabbedPane(JTabbedPane tabbedPane, String fileName, SrcCodeViewer viewer) {
		int num = tabbedPane.getTabCount();
		String newTitle = this.shortName(fileName);
		for (int i = 0; i < num; i++) {
			String title = tabbedPane.getTitleAt(i);
			if (newTitle.compareTo(title) > 0) {
				tabbedPane.insertTab(newTitle, null, viewer, null, i);
				return;
			}
		}
		tabbedPane.addTab(newTitle, viewer);
	}

	private String shortName(String s) {
		int index = s.lastIndexOf('/');
		if (index >= 0) {
			s = s.substring(index + 1);
		}
		s = s.trim();
		if (s.endsWith(".lua")) {
			s = s.substring(0, s.length() - 4);
		}
		if (s.endsWith(".lv")) {
			s = s.substring(0, s.length() - 3);
		}
		return s.trim();
	}

	public void running(String fileName, String lineNumber) {
		try {
			if (fileName != null) {
				SrcCodeViewer viewer = table.get(fileName);
				if (viewer != null) {
					viewer.gotoLine(Integer.parseInt(lineNumber.trim()));

					JTabbedPane tabbedPane = center.frame.getTabbedPane();
					tabbedPane.setSelectedComponent(viewer);
					if (center.frame.isAlwaysOnTop()) {
						center.frame.setAlwaysOnTop(true);
					}
					if (center.frame.isVisible()) {
						center.frame.setVisible(true);
					}
					center.frame.setIsDebugging(true);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		// System.out.println(fileName + lineNumber);
	}

	public void clearGotoLine() {
		try {
			JTabbedPane tabbedPane = center.frame.getTabbedPane();
			SrcCodeViewer viewer = (SrcCodeViewer) tabbedPane.getSelectedComponent();
			if (viewer != null) {
				viewer.clearGotoLine();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
