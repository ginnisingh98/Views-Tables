--------------------------------------------------------
--  DDL for Package PSP_NON_ORCL_RLBK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_NON_ORCL_RLBK_PKG" AUTHID CURRENT_USER as
--$Header: PSPNORBS.pls 115.8 2002/11/18 11:53:43 ddubey ship $

 PROCEDURE check_rollback( errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_Batch_Name IN VARCHAR2,
				p_business_group_id IN NUMBER,p_set_of_bks_id IN NUMBER);

-- PROCEDURE change_records(c_Batch_Name IN VARCHAR2,c_payroll_control_id IN NUMBER,
--				c_business_group_id IN NUMBER,c_set_of_bks_id IN NUMBER);

END;

 

/
