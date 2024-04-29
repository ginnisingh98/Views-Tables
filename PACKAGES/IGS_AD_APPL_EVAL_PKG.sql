--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_EVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_EVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA4S.pls 120.0 2005/06/01 22:08:02 appldev noship $ */

g_dns_ind VARCHAR2(1) := 'N';

 PROCEDURE insert_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_appl_eval_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2 default 'R',
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER  DEFAULT NULL,
       x_closed_ind IN VARCHAR2
     );

 PROCEDURE lock_row (
      x_rowid IN  VARCHAR2,
       x_appl_eval_id IN NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER  DEFAULT NULL,
       x_closed_ind IN VARCHAR2
       );

 PROCEDURE update_row (
      x_rowid IN  VARCHAR2,
       x_appl_eval_id IN NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2 default 'R',
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER DEFAULT NULL,
       x_closed_ind IN VARCHAR2
  );

 PROCEDURE add_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
       x_appl_eval_id IN OUT NOCOPY NUMBER,
       x_person_id IN NUMBER,
       x_admission_appl_number IN NUMBER,
       x_nominated_course_cd IN VARCHAR2,
       x_sequence_number IN NUMBER,
       x_evaluator_id IN NUMBER,
       x_assign_type IN VARCHAR2,
       x_assign_date IN DATE,
       x_evaluation_date IN DATE,
       x_rating_type_id IN NUMBER,
       x_rating_values_id IN NUMBER,
       x_rating_notes IN VARCHAR2,
       x_mode IN VARCHAR2 default 'R',
       x_evaluation_sequence IN NUMBER DEFAULT NULL,
       x_rating_scale_id IN NUMBER  DEFAULT NULL,
       x_closed_ind IN VARCHAR2
  ) ;

PROCEDURE delete_row (
  x_rowid in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_appl_eval_id IN NUMBER,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Rs_Values (
    x_rating_values_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );
  PROCEDURE Get_FK_Igs_Ad_Rating_Scales(
    x_rating_scale_id IN NUMBER
   );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_eval_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_evaluator_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_evaluation_date IN DATE DEFAULT NULL,
    x_rating_type_id IN NUMBER DEFAULT NULL,
    x_rating_values_id IN NUMBER DEFAULT NULL,
    x_rating_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_evaluation_sequence IN NUMBER DEFAULT NULL,
    x_rating_scale_id IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
 );

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  );
PROCEDURE wf_evaluator_validation (
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_nominated_course_cd   IN      VARCHAR2,
        x_sequence_number       IN      NUMBER,
        x_eval_seq              IN      NUMBER
        );

procedure Notification_On_Delete(
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
);

function find_prev_seq_number(
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
) RETURN NUMBER;

FUNCTION find_next_eval (
        x_person_id             IN      NUMBER,
        x_admission_appl_number IN      NUMBER,
        x_NOMINATED_COURSE_CD   IN      VARCHAR2,
        x_SEQUENCE_NUMBER       IN      NUMBER,
        x_eval_seq              IN      NUMBER
        ) RETURN NUMBER;

END igs_ad_appl_eval_pkg;

 

/
