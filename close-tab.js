#!/usr/bin/env node

const { chromium } = require('playwright');

// Get the keywords from the command-line argument
// The Bash script will pass "YouTube|Twitter|Reddit..."
const blockedKeywords = new RegExp(process.argv[2], 'i'); // 'i' = case-insensitive
const DEBUG_PORT = 9222;

(async () => {
  let browser;
  try {
    // Connect to the already-running browser
    browser = await chromium.connectOverCDP(`http://localhost:${DEBUG_PORT}`);
    const contexts = browser.contexts();
    if (contexts.length === 0) {
      console.log('No browser contexts found.');
      return;
    }

    // Check all pages in all contexts (e.g., main window, incognito)
    const pages = contexts.flatMap(context => context.pages());

    for (const page of pages) {
      const title = await page.title();
      const url = page.url();

      // Check if the title OR URL matches the blocked keywords
      if (blockedKeywords.test(title) || blockedKeywords.test(url)) {
        console.log(`Closing tab: ${title}`);
        await page.close();
      }
    }
  } catch (err) {
    // Log errors, e.g., "Connection refused" if browser isn't running with the flag
    console.error(`Error connecting to browser: ${err.message}`);
  } finally {
    // We don't close the browser connection, just exit the script
    process.exit(0);
  }
})();
