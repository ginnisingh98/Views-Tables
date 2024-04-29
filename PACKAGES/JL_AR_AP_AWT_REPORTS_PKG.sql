--------------------------------------------------------
--  DDL for Package JL_AR_AP_AWT_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AP_AWT_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlarpwrs.pls 120.3 2005/09/01 18:11:31 rguerrer ship $ */

	-- This function will insert lines in the table JL_AR_AP_AWT_CERTIF.
	-- This table will contain the AWT
	-- Certificates

 		FUNCTION JL_AR_AP_GEN_CERTIFICATES(
  		    p_payment_instruction_id  	 IN		NUMBER,
  		    p_calling_module             IN     VARCHAR2,
			p_errmsg		 IN OUT NOCOPY		VARCHAR2) RETURN BOOLEAN;

	-- This procedure will change the certificate status to 'VOID'

		PROCEDURE JL_AR_AP_VOID_CERTIFICATES(
        		P_payment_id            IN     Number,
        		P_Calling_Sequence      IN     Varchar2);

END JL_AR_AP_AWT_REPORTS_PKG;

 

/
