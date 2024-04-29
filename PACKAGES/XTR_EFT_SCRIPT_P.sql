--------------------------------------------------------
--  DDL for Package XTR_EFT_SCRIPT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_EFT_SCRIPT_P" AUTHID CURRENT_USER as
/* $Header: xtreftss.pls 120.4 2005/07/29 15:05:36 csutaria ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE CALL_SCRIPTS(l_company IN VARCHAR2,
			     l_cparty  IN VARCHAR2,
                       l_account IN VARCHAR2,
                       l_currency IN VARCHAR2,
			     l_script_name IN VARCHAR2,
                       paydate IN VARCHAR2,
			    l_prev_run IN VARCHAR2,
                        l_transmit_payment IN VARCHAR2,
			l_transmit_config_id IN VARCHAR2,
			retcode OUT nocopy   NUMBER);
PROCEDURE BNZ_EFT (l_company IN VARCHAR2,
			     l_cparty  IN VARCHAR2,
                          l_account IN VARCHAR2,
                          l_currency IN VARCHAR2,
                          l_eft_script_name IN VARCHAR2,
                          paydate  IN VARCHAR2,
                          sett IN VARCHAR2,
                          l_file_name IN VARCHAR2);
PROCEDURE SWT_EFT (l_company IN VARCHAR2,
			     l_cparty  IN VARCHAR2,
                          l_account IN VARCHAR2,
                          l_currency IN VARCHAR2,
                          l_eft_script_name IN VARCHAR2,
                          paydate  IN VARCHAR2,
                          sett IN VARCHAR2,
			  l_file_name IN VARCHAR2,
			  retcode OUT nocopy   NUMBER);
PROCEDURE X12_EFT (l_company IN VARCHAR2,
			     l_cparty  IN VARCHAR2,
                          l_account IN VARCHAR2,
                          l_currency IN VARCHAR2,
                          l_eft_script_name IN VARCHAR2,
                          paydate  IN VARCHAR2,
                          sett IN VARCHAR2,
			  l_file_name IN VARCHAR2,
			  retcode OUT nocopy   NUMBER);
---------------------------------------------------------------------------------------------------------------
end XTR_EFT_SCRIPT_P;

 

/
