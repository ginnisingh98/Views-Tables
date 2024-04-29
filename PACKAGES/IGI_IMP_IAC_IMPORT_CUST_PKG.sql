--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_IMPORT_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_IMPORT_CUST_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimias.pls 120.4.12000000.1 2007/08/01 16:21:08 npandya ship $

   --
   -- Implementation Customized Import Data Process
   --
   PROCEDURE Import_Cust_Data_Process ( errbuf            OUT NOCOPY VARCHAR2
                                      , retcode           OUT NOCOPY NUMBER
                                      , p_full_file_name  IN  VARCHAR2
                                      ) ;

END igi_imp_iac_import_cust_pkg;

 

/
