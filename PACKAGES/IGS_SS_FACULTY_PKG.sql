--------------------------------------------------------
--  DDL for Package IGS_SS_FACULTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_FACULTY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSS08S.pls 115.5 2003/05/16 11:56:06 knaraset ship $ */
 -- Bug No. 1956374 Procedure assp_val_mark_grade ,assp_get_sua_gs  are removed
 FUNCTION assp_ins_get_by_uoo(
  p_keying_who IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_include_discont_ind IN VARCHAR2 ,
  p_sort_by IN VARCHAR2 ,
  p_keying_time OUT NOCOPY DATE,
  p_return_status OUT NOCOPY VARCHAR2,
  p_msg_data OUT NOCOPY VARCHAR2,
  p_msg_count OUT NOCOPY NUMBER
 ) RETURN VARCHAR2 ;



  PROCEDURE update_suao(
    p_person_id          IN NUMBER,
    p_cal_type           IN VARCHAR2,
    p_ci_sequence_number IN NUMBER,
    p_unit_cd            IN VARCHAR2,
    p_course_cd          IN VARCHAR2,
    p_mark               IN NUMBER,
    p_grade              IN VARCHAR2,
    p_grading_schema_cd  IN VARCHAR2,
    p_gs_version_number  IN NUMBER,
    p_uoo_id             IN igs_en_su_attempt.uoo_id%TYPE
  );

END IGS_SS_FACULTY_PKG;

 

/
