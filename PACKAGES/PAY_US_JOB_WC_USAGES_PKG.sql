--------------------------------------------------------
--  DDL for Package PAY_US_JOB_WC_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_JOB_WC_USAGES_PKG" AUTHID CURRENT_USER as
/* $Header: pyuswcdf.pkh 115.0 99/07/17 06:48:20 porting ship $ */

PROCEDURE run (errbuf              	OUT 	VARCHAR2,
  		            retcode              	OUT 	NUMBER,
  		            p_business_group_id 	IN      NUMBER,
  		            p_state_code              	IN      VARCHAR2,
			    p_default_wc_code		IN  	NUMBER);

END pay_us_job_wc_usages_pkg;

 

/
