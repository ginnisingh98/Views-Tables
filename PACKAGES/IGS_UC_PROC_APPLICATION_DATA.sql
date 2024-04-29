--------------------------------------------------------
--  DDL for Package IGS_UC_PROC_APPLICATION_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PROC_APPLICATION_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC68S.pls 120.0 2005/06/01 21:50:04 appldev noship $  */

   PROCEDURE appl_data_setup (errbuf  OUT NOCOPY   VARCHAR2,
                              retcode OUT NOCOPY   NUMBER);
   PROCEDURE  process_ivstarn         ;
   PROCEDURE  process_ivstark         ;
   PROCEDURE  process_ivstarc         ;
   PROCEDURE  process_ivstarg         ;
   PROCEDURE  process_ivstart         ;
   PROCEDURE  process_ivstara         ;
   PROCEDURE  process_ivqualification ;
   PROCEDURE  process_ivstatement     ;
   PROCEDURE  process_ivreference     ;
   PROCEDURE  process_ivoffer         ;
   PROCEDURE  process_ivstarx         ;
   PROCEDURE  process_ivstarh         ;
   PROCEDURE  process_ivstarpqr       ;
   PROCEDURE  process_ivformquals     ;
   PROCEDURE  process_ivstarz1        ;
   PROCEDURE  process_ivstarz2        ;
   PROCEDURE  process_ivstarw         ;


END igs_uc_proc_application_data;

 

/
