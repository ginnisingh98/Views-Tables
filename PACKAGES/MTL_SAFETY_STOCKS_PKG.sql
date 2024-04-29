--------------------------------------------------------
--  DDL for Package MTL_SAFETY_STOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_SAFETY_STOCKS_PKG" AUTHID CURRENT_USER as
/* $Header: INVDDFSS.pls 120.1.12000000.1 2007/01/17 16:13:29 appldev ship $ */

procedure SafetyStock(X_ORGANIZATION_ID NUMBER,
                      X_SELECTION NUMBER,
                      X_INVENTORY_ITEM_ID NUMBER,
		      X_SAFETY_STOCK_CODE NUMBER,
                      X_FORECAST_NAME VARCHAR2,
                      X_CATEGORY_SET_ID NUMBER,
                      X_CATEGORY_ID NUMBER,
                      X_PERCENT NUMBER,
                      X_SERVICE_LEVEL NUMBER,
                      X_START_DATE DATE,
                      login_id NUMBER,
                      user_id NUMBER);

procedure Init(org_id IN NUMBER,
               srv_level IN NUMBER,
               srv_factor OUT NOCOPY NUMBER,
               cal_code OUT NOCOPY VARCHAR2,
               except_id OUT NOCOPY NUMBER);

procedure Main(org_id NUMBER,
               item_id NUMBER,
	       ss_code NUMBER,
               forc_name VARCHAR2,
               ss_percent NUMBER,
               srv_level NUMBER,
               effect_date DATE,
               srv_factor NUMBER,
               cal_code VARCHAR2,
               except_id NUMBER,
               login_id NUMBER,
               user_id NUMBER);

procedure Insert_Safety_Stocks (org_id NUMBER,
	    		        item_id NUMBER,
				ss_code NUMBER,
				forc_name VARCHAR2,
                      		ss_percent NUMBER,
                      		srv_level NUMBER,
                      		ss_date DATE,
                                ss_qty NUMBER,
                                login_id NUMBER,
                                user_id NUMBER);

FUNCTION CalSF(service_level NUMBER) RETURN NUMBER;

/********************************************
 *Enhancement bug#2231655   GLOBAL VARIABLES*
 ********************************************/

 g_debug_level NUMBER := FND_PROFILE.VALUE('INV_DEBUG_LEVEL');

END MTL_SAFETY_STOCKS_PKG;

 

/
