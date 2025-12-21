#!/usr/bin/env node

const { chromium } = require('playwright-core');

// Accept the specific keyword cluster passed from the Bash script
const blockedKeywordsStr = process.argv[2];
if (!blockedKeywordsStr) process.exit(1);

const blockedKeywords = new RegExp(blockedKeywordsStr, 'i');
const DEBUG_PORT = 9222;

async function run() {
  let browser;
  let retries = 3; 
  while (retries > 0) {
    try {
      browser = await chromium.connectOverCDP(`http://localhost:${DEBUG_PORT}`);
      break; 
    } catch (err) {
      retries--;
      if (retries === 0) process.exit(1);
      await new Promise(r => setTimeout(r, 500));
    }
  }

  try {
    const pages = (await browser.contexts()).flatMap(c => c.pages());

    for (const page of pages) {
      const title = await page.title();
      const url = page.url();

      // Only close if it matches the specific keywords for THIS browser cluster
      if (blockedKeywords.test(title) || blockedKeywords.test(url)) {
        console.log(`[CDP] Closing tab: ${title}`);
        await page.close();
      }
    }
  } catch (err) {
    // Silent fail
  } finally {
    if (browser) await browser.close();
    process.exit(0);
  }
}

run();
