--------------------------------------------------------
--  DDL for Package IGS_UC_PROC_UCAS_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PROC_UCAS_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC43S.pls 120.0 2005/06/02 04:19:07 appldev noship $  */

  PROCEDURE process_ucas_data (
     errbuf               OUT NOCOPY   VARCHAR2
    ,retcode              OUT NOCOPY   NUMBER
    ,p_proc_ref_data      IN  VARCHAR2
    ,p_proc_appl_data     IN  VARCHAR2);


  PROCEDURE log_proc_complete(
      p_view_name VARCHAR2,
      p_success_cnt NUMBER,
      p_error_cnt NUMBER);


  PROCEDURE log_error_msg(p_error_code igs_uc_uinst_ints.error_code%TYPE);

END igs_uc_proc_ucas_data;

 

/
