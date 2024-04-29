--------------------------------------------------------
--  DDL for Package AP_R11_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_R11_PREPAY_PKG" AUTHID CURRENT_USER AS
/*$Header: apr11pps.pls 120.1 2003/06/13 19:45:56 isartawi noship $*/

PROCEDURE ap_r11_prepay(X_prepay_id		IN	NUMBER,
                        X_invoice_id     	IN	NUMBER,
                        X_amount_apply    	IN	NUMBER,
	                X_user_id      	 	IN	NUMBER,
		        X_last_update_login  	IN 	NUMBER,
		        X_gl_date    	 	IN	DATE,
		        X_period_name	 	IN   	VARCHAR2,
		        X_calling_from	     	IN	VARCHAR2,
		        X_calling_sequence   	IN	VARCHAR2);


END AP_R11_PREPAY_PKG;

 

/
