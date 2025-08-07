// 监听键盘快捷键命令
browser.commands.onCommand.addListener(async (command) => {
  if (command === "clone-tab") {
    await cloneCurrentTab();
  }
});

// 克隆当前标签页的函数
async function cloneCurrentTab() {
  try {
    // 获取当前活动标签页
    const [activeTab] = await browser.tabs.query({
      active: true,
      currentWindow: true
    });
    
    if (!activeTab) {
      console.error("No active tab found");
      return;
    }
    
    // 创建新标签页，复制当前标签页的URL
    const newTab = await browser.tabs.create({
      url: activeTab.url,
      active: true, // 激活新标签页
      index: activeTab.index + 1 // 在当前标签页后面创建
    });
    
    console.log("Tab cloned successfully:", newTab.id);
    
    // 可选：显示通知
    if (browser.notifications) {
      browser.notifications.create({
        type: "basic",
        iconUrl: "icons/icon-48.png",
        title: "Tab Cloned",
        message: `Successfully cloned tab: ${activeTab.title}`
      });
    }
    
  } catch (error) {
    console.error("Error cloning tab:", error);
  }
}

// 扩展安装时的处理
browser.runtime.onInstalled.addListener((details) => {
  if (details.reason === "install") {
    console.log("Tab Cloner extension installed");
  }
});
