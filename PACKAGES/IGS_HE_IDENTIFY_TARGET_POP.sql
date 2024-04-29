--------------------------------------------------------
--  DDL for Package IGS_HE_IDENTIFY_TARGET_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_IDENTIFY_TARGET_POP" AUTHID CURRENT_USER AS
/* $Header: IGSHE25S.pls 115.1 2003/05/07 13:05:47 pmarada noship $ */

PROCEDURE dlhe_identify_population (errbuf          OUT NOCOPY     VARCHAR2,
                                    retcode         OUT NOCOPY     NUMBER,
                                    p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                                    p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                                    p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE
                                   );

PROCEDURE Dlhe_identify_spa (p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                             p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                             p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                             p_qual_type       IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                     	     p_qual_start_date IN  igs_he_sub_rtn_qual.qual_period_start_date%TYPE,
			     p_qual_end_date   IN  igs_he_sub_rtn_qual.qual_period_end_date%TYPE,
			     p_closed_ind      IN  igs_he_sub_rtn_qual.closed_ind%TYPE
                            );

PROCEDURE Dlhe_Process_spa (p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                            p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                            p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                            p_qual_type       IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                            p_person_id       IN  igs_he_st_spa.person_id%TYPE,
                            p_course_cd       IN  igs_he_st_spa.course_cd%TYPE,
                            p_version_number  IN  igs_he_st_spa.version_number%TYPE,
                            P_cre_upd_dlhe    OUT NOCOPY VARCHAR2
			   );

PROCEDURE Dlhe_review_spa ( p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                            p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                            p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                            p_qual_type       IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                            p_qual_start_dt   IN  igs_he_sub_rtn_qual.qual_period_start_date%TYPE,
                            p_qual_end_dt     IN  igs_he_sub_rtn_qual.qual_period_end_date%TYPE,
                            p_person_id       IN  igs_he_st_spa.person_id%TYPE,
                            p_course_cd       IN  igs_he_st_spa.course_cd%TYPE,
                            p_version_number  IN  igs_he_st_spa.version_number%TYPE,
                            p_include           OUT NOCOPY  VARCHAR2,
                            p_qualified_teacher OUT NOCOPY  VARCHAR2,
                            p_pt_study          OUT NOCOPY  VARCHAR2
                          );

END igs_he_identify_target_pop;

 

/
