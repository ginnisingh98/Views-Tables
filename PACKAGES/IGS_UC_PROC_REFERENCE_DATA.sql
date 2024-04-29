--------------------------------------------------------
--  DDL for Package IGS_UC_PROC_REFERENCE_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PROC_REFERENCE_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC67S.pls 120.1 2006/08/21 06:15:46 jbaber noship $  */

  PROCEDURE process_cvrefcodes        ;
  PROCEDURE process_cvrefawardbody    ;
  PROCEDURE process_cvrefapr          ;
  PROCEDURE process_cvrefkeyword      ;
  PROCEDURE process_cvrefpocc         ;
  PROCEDURE process_cvrefofferabbrev  ;
  PROCEDURE process_cvrefsubj         ;
  PROCEDURE process_cvreftariff       ;
  PROCEDURE process_cvjointadmissions ;
  PROCEDURE process_cvrefcountry      ;

END igs_uc_proc_reference_data;

 

/
