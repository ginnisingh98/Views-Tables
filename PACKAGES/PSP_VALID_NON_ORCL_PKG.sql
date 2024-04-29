--------------------------------------------------------
--  DDL for Package PSP_VALID_NON_ORCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_VALID_NON_ORCL_PKG" AUTHID CURRENT_USER AS
  /* $Header: PSPNONS.pls 115.6 2003/07/24 12:11:00 tbalacha ship $ */
  -- package created by Al for validating Non Oracle Sub lines
  Procedure All_Records(v_Batch_Name         IN varchar2,
			v_business_group_id  IN NUMBER,
			v_set_of_books_id    IN NUMBER,
			v_precision          IN NUMBER,
			v_ext_precision      IN NUMBER,
                        v_currency_code      IN VARCHAR2);

END;

 

/
