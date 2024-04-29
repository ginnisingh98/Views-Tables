--------------------------------------------------------
--  DDL for Package IGS_UC_EXT_MARVIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXT_MARVIN" AUTHID CURRENT_USER AS
/* $Header: IGSUC33S.pls 115.3 2002/12/26 06:19:09 ayedubat noship $ */
/* HISTORY
 WHO         WHEN         WHAT
 ayedubat    24-DEC-2002  Removed the parameter,p_directory from the create_file
                          procedure, for bug # 2711256
*/
PROCEDURE  create_file( errbuf   OUT NOCOPY  VARCHAR2,
                        retcode  OUT NOCOPY  NUMBER );

END igs_uc_ext_marvin ;

 

/
