--------------------------------------------------------
--  DDL for Package IGS_UC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_UTILS" AUTHID CURRENT_USER AS
/* $Header: IGSUC26S.pls 115.10 2003/07/16 16:12:48 pmarada noship $ */


  PROCEDURE format_app_no (p_app_no              IN     NUMBER,
                           p_check_digit         IN     NUMBER,
                           r_app_no_9            OUT NOCOPY    CHAR,
                           r_app_no_11           OUT NOCOPY    CHAR);


  PROCEDURE generate_pers_no (r_person_number    OUT NOCOPY    CHAR);


  FUNCTION is_ucas_hesa_enabled RETURN BOOLEAN;

  PROCEDURE admission_residency_dtls (
     p_interface_res_id       IN  NUMBER
    ,p_residency_status_cd    IN  CHAR
    ,p_residency_class_cd     IN  CHAR
    ,p_start_dt               IN  DATE
    ,p_person_id              IN  NUMBER
    ,p_process_residency_status OUT NOCOPY CHAR );


     TYPE step_rec IS RECORD(
     APPNO        NUMBER,
     CHECKDIGIT   NUMBER,
     SURNAME      VARCHAR2(150),
     FORENAMES    VARCHAR2(150),
     BIRTHDATE    DATE,
     SEX          VARCHAR2(30),
     TITLE        VARCHAR2(60)
      );

 TYPE cur_step_def IS REF CURSOR;

 PROCEDURE cvname_references( p_type      IN VARCHAR2,
                              p_appno     IN NUMBER,
                              p_surname   IN VARCHAR2,
                              p_birthdate IN DATE,
                              l_result   OUT NOCOPY igs_uc_utils.cur_step_def);


END igs_uc_utils;

 

/
