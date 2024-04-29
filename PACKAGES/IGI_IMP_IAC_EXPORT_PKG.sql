--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_EXPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_EXPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: igiimeps.pls 120.5.12000000.1 2007/08/01 16:20:59 npandya ship $*/

   PROCEDURE  Export_data_process(
   	errbuf OUT NOCOPY  varchar2 ,
   	retcode OUT NOCOPY  number,
	p_book IN IGI_IMP_IAC_INTERFACE.book_type_code%type,
	p_category_id IN IGI_IMP_IAC_INTERFACE.category_id%type,
	category_name IN varchar2);

   FUNCTION trim_invalid_chars (p_validation_string varchar2) return varchar2;		-- Bug 2843747 (Tpradhan) - Included the function in the spec since it is called by
   											--			    igi_imp_iac_import_pkg.import_imp_data_process
END igi_imp_iac_export_pkg;

 

/
