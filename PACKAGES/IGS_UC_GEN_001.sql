--------------------------------------------------------
--  DDL for Package IGS_UC_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSUC01S.pls 120.2 2006/08/21 03:51:15 jbaber noship $  */

     TYPE step_rec IS RECORD(
     appno        NUMBER,
     checkdigit   NUMBER,
     surname      VARCHAR2(150),
     forenames    VARCHAR2(150),
     birthdate    DATE,
     sex          VARCHAR2(30),
     title        VARCHAR2(60)
      );

 TYPE cur_step_def IS REF CURSOR;

 PROCEDURE cvname_references( p_type        IN  VARCHAR2,
                              p_appno       IN  NUMBER,
                              p_surname     IN  VARCHAR2,
                              p_birthdate   IN  DATE,
                              p_system_code IN  igs_uc_ucas_control.system_code%TYPE,
                              l_result      OUT NOCOPY igs_uc_gen_001.cur_step_def);

 PROCEDURE ss_identify_trans_page(p_uc_tran_id IN VARCHAR2,
                                  p_page_function  OUT NOCOPY VARCHAR2) ;

 PROCEDURE get_transaction_toy(p_system_code     IN  VARCHAR2,
                               p_ucas_cycle      IN  NUMBER,
                               p_transaction_toy OUT NOCOPY VARCHAR2 );

 FUNCTION validate_personal_id(p_personal_id  IN VARCHAR2) RETURN BOOLEAN;

END igs_uc_gen_001;

 

/
