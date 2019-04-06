package com.alibaba.luaview.debugger.ui;

/**
 * AWT Sample application
 *
 * @author 
 * @version 1.00 05/09/22
 */

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.util.Vector;

import com.alibaba.luaview.debugger.Center;
import com.alibaba.luaview.debugger.ClientCmd;

// 类的作用：树结构的浏览器
/**
 * 
 * @author dongxicheng
 * 
 */
public final class SrcCodeViewer extends SrcCodeScrollPanel {

	private static final long serialVersionUID = -196018687886621L;

	private static final Color currentLineColor = new Color(221, 234, 207);
	private static final Color breakPointBGColor = null;
	// new Color(251, 238, 235);

	public boolean canBreakPoint = true;

	public final String fileName;

	private final Vector<Line> lines = new Vector<Line>();

	private FontMetrics fontMetrics;

	private Center center;

	private Font font16 = new Font("黑体", Font.PLAIN, 13);
	private Font font12 = new Font("黑体", Font.PLAIN, 10);

	SrcCodeViewer(String fileName, String content, Center center) {
		super();
		this.center = center;
		this.setFont(font16);
		fontMetrics = getFontMetrics(getFont());

		addKeyListener(new KeyListener() {
			public void keyPressed(KeyEvent arg0) {
				if (arg0.getKeyCode() == KeyEvent.VK_W) {
				} else if (arg0.getKeyCode() == KeyEvent.VK_S) {
				} else if (arg0.getKeyCode() == KeyEvent.VK_A) {
				} else if (arg0.getKeyCode() == KeyEvent.VK_D) {
				}
				updateUI();
			}

			public void keyReleased(KeyEvent arg0) {
			}

			public void keyTyped(KeyEvent arg0) {
			}
		});
		this.fileName = fileName;
		this.setFileSting(content);
		int len = (this.lines.size() + "").length();
		if (len < 2) {
			len = 2;
		}
		this.X0_TAG = (int) (LINE_H * 0.5) * len;
		this.X0 = this.X0_TAG + LINE_H;
	}

	private void setFileSting(String s) {
		this.lines.removeAllElements();
		String[] arr = s.split("\n");
		for (int i = 0; i < arr.length; i++) {
			Line line = new Line(arr[i]);
			line.index = i + 1;// 设置行号
			this.lines.add(line);
		}
	}

	private final int X0_TAG;// LINE_H * 5 / 2;
	private final int X0;// LINE_H * 5 / 2;
	private final int Y0 = LINE_H * 2;

	public void myPaint(Graphics2D g) {
		g.setColor(new Color(0xf0f0f0));
		{
			int h = (this.lines.size() + 5) * LINE_H;
			if (h < this.getHeight()) {
				h = this.getHeight();
			}
			g.fillRect(0, 0, X0, h);
			g.setColor(new Color(217, 217, 217));
			g.drawLine(X0, 0, X0, h);
		}
		resetMaxWH();
		try {
			setNodeX(X0);
			setNodeY(Y0);
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (int i = 0; i < this.lines.size(); i++) {
			Line line = this.lines.elementAt(i);
			line.tag = "" + (i + 1);
			drawOneLine(true, line, g, line.x, line.y);
		}
		this.clearPoint();
	}

	BasicStroke stroke = new BasicStroke(1);

	/**
	 * 显示root
	 * 
	 * @param line
	 * @param g
	 * @param topX
	 * @param topY
	 */
	private void drawOneLine(boolean yes, Line line, Graphics2D g, int topX, int topY) {
		if (line == null)
			return;
		int x = line.x;
		int y = line.y;

		if (isYOnView(y - LINE_H) || isYOnView(y + LINE_H)) {
			if (line.isBreakPoint && breakPointBGColor != null) {
				g.setColor(breakPointBGColor);
				g.fillRect(X0 + 1, y - LINE_H, this.getWidth(), LINE_H);
			}

			if (line.isCurrentLine) {
				g.setColor(currentLineColor);
				g.fillRect(X0 + 1, y - LINE_H, this.getWidth(), LINE_H);
			}

			g.setColor(Color.BLACK);

			line.draw(g, x + 2, y - 3);

			if (line.isBreakPoint) {// 断点
				int dx = 2;
				g.setColor(Color.red);
				g.fillArc(this.X0_TAG + 3, y - LINE_H + dx, LINE_H - dx * 2, LINE_H - dx * 2, 0, 360);
			}

			g.setColor(Color.GRAY);
			g.setFont(font12);
			int w = g.getFontMetrics().stringWidth(line.tag);
			g.drawString(line.tag, X0_TAG - w, y - 3);
			g.setFont(font16);
		}
		if (this.pressedPointX() < X0 && this.canBreakPoint && isPressTheLine(x, y, LINE_H)) {
			line.isBreakPoint = !line.isBreakPoint;
			updateUI();
			if (line.isBreakPoint) {
				String s = "b " + this.fileName + ":" + line.index;
				center.cmdBuffer.pushCmd(new ClientCmd(s));
			} else {
				String s = "rb " + this.fileName + ":" + line.index;
				center.cmdBuffer.pushCmd(new ClientCmd(s));
			}
		}

		if (X0 < this.pressedPointX() && isPressTheLine(x, y, LINE_H)) {
			String s = line.getPressedString(this.pressedPointX(), this.pressedPointY());
			if (s != null && s.length() > 0) {
				if (s.indexOf('.') < 0) {
					center.cmdBuffer.pushCmd(new ClientCmd("p " + s));
				} else {
					center.cmdBuffer.pushCmd(new ClientCmd("run print(\"" + s + " =\" , " + s + ")"));
				}
			}
		}
	}

	/**
	 * 设置x坐标
	 * 
	 * @param node
	 * @param x0
	 * @param PER_WIDTH
	 */
	private void setNodeX(int x0) {
		for (int i = 0; i < this.lines.size(); i++) {
			Line node = this.lines.elementAt(i);
			if (node == null) {
				return;
			}
			node.x = x0;

			node.width = fontMetrics.stringWidth(node.text) + 16;

			int tempX = node.x + node.width + 100;
			this.setMaxW(tempX);
		}
	}

	/**
	 * 设置y坐标
	 * 
	 * @param node
	 * @return
	 */
	private void setNodeY(int y0) {
		for (int i = 0; i < this.lines.size(); i++) {
			Line obj = this.lines.elementAt(i);
			obj.y = y0 + i * LINE_H;
			setMaxH(obj.y + 50);
		}
	}

	public void gotoLine(int lineNumber) {
		lineNumber -= 1;
		for (int i = 0; i < this.lines.size(); i++) {
			Line line = this.lines.elementAt(i);
			if (lineNumber == i) {
				line.isCurrentLine = true;
			} else {
				line.isCurrentLine = false;
			}
		}
		this.setNextYOnView(lineNumber * LINE_H + Y0);
		this.updateUI();
	}

	public void clearGotoLine() {
		this.gotoLine(-100);
	}

}
