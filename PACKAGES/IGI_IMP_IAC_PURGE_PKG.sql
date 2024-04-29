--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_PURGE_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimpus.pls 120.5.12000000.1 2007/08/01 16:21:51 npandya ship $

PROCEDURE PURGE_IMP_DATA(ERRBUF OUT NOCOPY VARCHAR2,
                         RETCODE OUT NOCOPY NUMBER,
                         p_book_type_code IN VARCHAR2,
			 p_category_struct_id IN NUMBER,
                         p_category_id IN NUMBER,
                         p_asset_id IN NUMBER);

END;

 

/
