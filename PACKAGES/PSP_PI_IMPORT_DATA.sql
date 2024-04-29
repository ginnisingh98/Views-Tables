--------------------------------------------------------
--  DDL for Package PSP_PI_IMPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PI_IMPORT_DATA" AUTHID CURRENT_USER AS
  /* $Header: PSPPII2S.pls 120.0.12000000.1 2007/01/18 12:24:52 appldev noship $ */
  Procedure Imp_Rec(errBuf OUT NOCOPY varchar2, retCode OUT NOCOPY varchar2,
		    v_Batch_Name IN varchar2, v_business_group_id IN NUMBER,
		    v_set_of_books_id IN NUMBER);
END;

 

/
