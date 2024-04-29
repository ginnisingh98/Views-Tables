--------------------------------------------------------
--  DDL for Package Body AP_EXPENSE_FEED_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_EXPENSE_FEED_LINES_PKG" AS
/* $Header: apiwtrxb.pls 120.1 2005/06/24 21:14:38 hchacko ship $ */

PROCEDURE SELECT_SUMMARY(X_FEED_LINE_ID IN NUMBER,
	         	 X_TOTAL         IN OUT NOCOPY NUMBER,
                         X_TOTAL_RTOT_DB IN OUT NOCOPY NUMBER,
			 X_CALLING_SEQUENCE IN VARCHAR2) IS

  l_current_calling_sequence  VARCHAR2(2000);
  l_debug_info		      VARCHAR2(100);

BEGIN
  l_current_calling_sequence := 'AP_EXPENSE_FEED_LINES_PKG.SELECT_SUMMARY<-' ||
                                 X_calling_sequence;

  ----------------------------------------
  l_debug_info := 'Get Sum of Amounts';
  ----------------------------------------
  SELECT NVL(SUM(AMOUNT), 0), NVL(SUM(AMOUNT), 0)
  INTO   X_TOTAL, X_TOTAL_RTOT_DB
  FROM   AP_EXPENSE_FEED_DISTS
  WHERE  FEED_LINE_ID = X_FEED_LINE_ID;

  X_TOTAL_RTOT_DB := X_TOTAL;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (SQLCODE = -54) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
      ELSE
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                  l_current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'X_FEED_LINE_ID = '||X_FEED_LINE_ID
            ||', X_TOTAL = '||X_TOTAL
            ||', X_TOTAL_RTOT_DB = '||X_TOTAL_RTOT_DB
                                 );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

END AP_EXPENSE_FEED_LINES_PKG;

/
