--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_IMPORT_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimips.pls 120.4.12000000.1 2007/08/01 16:21:25 npandya ship $

   --
   -- Spawn the Loader process for a file
   --
   PROCEDURE Spawn_Loader ( p_file_name IN  VARCHAR2
                          );

   --
   -- Validate and Update intermediate records to interface
   --
   PROCEDURE Validate_Update_IMP_Data ( p_file_name      IN  VARCHAR2
                                      , p_book_type_code IN  VARCHAR2
                                      , p_category_id    IN  NUMBER
                                      );

   --
   -- Implementation Import Data Process
   --
   PROCEDURE Import_IMP_Data_Process ( errbuf            OUT NOCOPY VARCHAR2
                                     , retcode           OUT NOCOPY NUMBER
                                     , p_book_type_code  IN  VARCHAR2
                                     , p_category_id     IN  NUMBER
                                     , p_category_name   IN  VARCHAR2
                                     ) ;

END igi_imp_iac_import_pkg;

 

/
