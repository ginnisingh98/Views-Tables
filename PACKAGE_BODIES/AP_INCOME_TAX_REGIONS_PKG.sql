--------------------------------------------------------
--  DDL for Package Body AP_INCOME_TAX_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INCOME_TAX_REGIONS_PKG" AS
/* $Header: apiincrb.pls 120.3 2004/10/28 00:04:59 pjena noship $ */

PROCEDURE CHECK_UNIQUE (X_ROWID             VARCHAR2,
		        X_REGION_SHORT_NAME VARCHAR2,
		        X_REGION_CODE       NUMBER,
			X_calling_sequence	IN	VARCHAR2) IS
  dummy number;
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);

begin
--Update the calling sequence
--
  current_calling_sequence := 'AP_INCOME_TAX_REGIONS_PKG.CHECK_UNIQUE<-' ||
                               X_calling_sequence;

  debug_info := 'Count income tax regions';
  select count(1)
  into   dummy
  from   ap_income_tax_regions
  where  (region_short_name = X_REGION_SHORT_NAME OR
          region_code = X_REGION_CODE)
  and    ((X_ROWID is null) or (rowid <> X_ROWID));

  if (dummy >= 1) then
    fnd_message.set_name('SQLAP','AP_ALL_DUPLICATE_VALUE');
    app_exception.raise_exception;
  end if;
  EXCEPTION
       WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_ROWID ||
		        	', REGION_SHORT_NAME = ' || X_REGION_SHORT_NAME ||
		        	', REGION_CODE = ' || X_REGION_CODE);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end CHECK_UNIQUE;

END AP_INCOME_TAX_REGIONS_PKG;

/
