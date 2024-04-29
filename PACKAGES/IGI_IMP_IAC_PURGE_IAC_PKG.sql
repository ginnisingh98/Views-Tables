--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_PURGE_IAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_PURGE_IAC_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimpis.pls 120.4.12000000.1 2007/08/01 16:21:42 npandya ship $
   Procedure  Purge_Iac_Data (
			   errbuf     OUT NOCOPY    VARCHAR2 ,
			   retcode    OUT NOCOPY    NUMBER   ,
			   p_book_type_code  VARCHAR2 ,
			   p_cat_struct_id   NUMBER   ,
			   p_category_id     NUMBER );

END;

 

/
