--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_LGCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_LGCY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS85S.pls 120.1 2005/06/29 04:17:55 appldev ship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Shirish Tatiko, Saravana Kumar
    Date Created By:  11-NOV-2002
    Purpose        :  This package has the 8 sub processes, which will be called from
                      PSP Unit API.
                      process 1 : create_unit_version
                                    Imports Unit Version and its associated Subtitle and Curriculum
                      process 2 : create_teach_resp
                                    Imports Teaching Reponsibility.
                      process 3 : create_unit_discip
                                    Imports Unit Discipline.
                      process 4 : create_unit_grd_sch
                                    Imports Unit Grading Schema.
                                : validate_unit_dtls
                                     Validations performed across different sub process at unil level.
                      process 5 : create_unit_section
                                    Imports Unit Section and its associated Credits Point and Referrence
                      process 6 : create_usec_grd_sch
                                    Imports Unit Section Grading Schema
                      process 7 : create_usec_occur
                                    Imports Unit Section Occurrence
                      process 8 : create_unit_ref_code
                                    Imports Unit / Unit Section / Unit Section Occurrence Referrences
                      process 9 : create_uso_ins
                                    Imports Unit Section Occurrence instructors and creates unit
                                    section teaching responsibilites record if current instructor
                                    getting imported does not already exists.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who              When          What
    smvk          07-Nov-2003    Bug # 3138353. Added new procedure validate_unit_dtls to do unit level cross subprocesses validation.
    jbegum        2-June-2003    Bug # 2972950. Created Sub process create_uso_ins to import unit section occurrence
                               instructors and instructor details, as mentioned in TD.
  ********************************************************************************************** */

  --This procedure is a sub process to insert records of Unit Version and its associated Subtitle and Curriculum
  PROCEDURE create_unit_version(p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
                                p_rec_status   OUT NOCOPY    VARCHAR2);

  --This procedure is a sub process to insert records of Teaching Responsibility.
  PROCEDURE create_teach_resp (
         p_tab_teach_resp IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type,
         p_c_rec_status OUT NOCOPY VARCHAR2
  );

  --This procedure is a sub process to insert records of Unit Discipline.
  PROCEDURE create_unit_discip (
          p_tab_unit_dscp IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2
  ) ;

  --This procedure is a sub process to insert records of Unit Grading Schema.
  PROCEDURE create_unit_grd_sch (
          p_tab_grd_sch IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2
  ) ;

  --This procedure does the validations performed across different sub process at unil level.
  PROCEDURE validate_unit_dtls (
          p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
          p_rec_status   OUT NOCOPY    VARCHAR2
  );

  --This procedure is a sub process to insert records of Unit Section.
  PROCEDURE create_unit_section (
          p_usec_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  ) ;

  --This procedure is a sub process to insert records of Unit Section Grading Schema.
  PROCEDURE create_usec_grd_sch (
          p_tab_usec_gs IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  ) ;

  --This procedure is a sub process to insert records of Unit Section Occurrence.
  PROCEDURE create_usec_occur (
          p_tab_usec_occur IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2,
	  p_calling_context  IN VARCHAR2
  ) ;

 --This procedure is a sub process to insert records of referrence Unit
 -- Unit Section, Unit Section Occurrence.
  PROCEDURE create_unit_ref_code( p_tab_ref_cd IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
                                  p_c_rec_status OUT NOCOPY VARCHAR2,
			  	  p_calling_context  IN VARCHAR2);

 --This procedure is a sub process to create Unit Section Occurrence Instructors
 --in production table(IGS_PS_USO_INSTRCTRS)
  PROCEDURE create_uso_ins( p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type,
                            p_c_rec_status   OUT NOCOPY VARCHAR2 );


END igs_ps_unit_lgcy_pkg;

 

/
