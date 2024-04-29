--------------------------------------------------------
--  DDL for Package IGS_UC_PROC_COM_INST_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PROC_COM_INST_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC66S.pls 120.1 2006/08/21 06:15:24 jbaber noship $  */

  PROCEDURE common_data_setup (errbuf  OUT NOCOPY   VARCHAR2,
                               retcode OUT NOCOPY   NUMBER);

  PROCEDURE process_uvinstitution     ;
  PROCEDURE process_uvofferabbrev     ;
  PROCEDURE process_cvinstitution     ;
  PROCEDURE process_cveblsubject      ;
  PROCEDURE process_cvschool          ;
  PROCEDURE process_cvschoolcontact   ;
  PROCEDURE process_cvcourse          ;
  PROCEDURE process_uvcourse          ;
  PROCEDURE process_uvcoursekeyword   ;

END igs_uc_proc_com_inst_data;

 

/
