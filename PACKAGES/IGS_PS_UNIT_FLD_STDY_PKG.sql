--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_FLD_STDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_FLD_STDY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0GS.pls 115.5 2002/11/29 01:56:43 nsidana ship $ */
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
  PROCEDURE insert_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
      x_unit_field_of_study_id IN OUT NOCOPY NUMBER,
      x_unit_code IN VARCHAR2,
      x_version_number IN NUMBER,
      x_field_of_study IN VARCHAR2,
      x_mode IN VARCHAR2 DEFAULT 'R'
  );
  PROCEDURE lock_row (
      x_rowid IN  VARCHAR2,
      x_unit_field_of_study_id IN NUMBER,
      x_unit_code IN VARCHAR2,
      x_version_number IN NUMBER,
      x_field_of_study IN VARCHAR2
  );
  PROCEDURE update_row (
      x_rowid IN  VARCHAR2,
      x_unit_field_of_study_id IN NUMBER,
      x_unit_code IN VARCHAR2,
      x_version_number IN NUMBER,
      x_field_of_study IN VARCHAR2,
      x_mode IN VARCHAR2 DEFAULT 'R'
  );
  PROCEDURE add_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
      x_unit_field_of_study_id IN OUT NOCOPY NUMBER,
      x_unit_code IN VARCHAR2,
      x_version_number IN NUMBER,
      x_field_of_study IN VARCHAR2,
      x_mode IN VARCHAR2 DEFAULT 'R'
  );
  PROCEDURE delete_row (
      x_rowid IN VARCHAR2
  );
  FUNCTION get_pk_for_validation (
      x_unit_field_of_study_id IN NUMBER
  ) RETURN BOOLEAN;
  FUNCTION get_uk_for_validation (
      x_field_of_study IN VARCHAR2,
      x_unit_code IN VARCHAR2,
      x_version_number IN NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE Get_FK_Igs_Ps_Fld_Of_Study (
    x_field_of_study IN VARCHAR2
  );
  PROCEDURE get_fk_igs_ps_unit_ver (
      x_unit_cd IN VARCHAR2,
      x_version_number IN NUMBER
  );
  PROCEDURE Before_DML (
      p_action IN VARCHAR2,
      x_rowid IN VARCHAR2 DEFAULT NULL,
      x_unit_field_of_study_id IN NUMBER DEFAULT NULL,
      x_unit_code IN VARCHAR2 DEFAULT NULL,
      x_version_number IN NUMBER DEFAULT NULL,
      x_field_of_study IN VARCHAR2 DEFAULT NULL,
      x_creation_date IN DATE DEFAULT NULL,
      x_created_by IN NUMBER DEFAULT NULL,
      x_last_update_date IN DATE DEFAULT NULL,
      x_last_updated_by IN NUMBER DEFAULT NULL,
      x_last_update_login IN NUMBER DEFAULT NULL
  );
END igs_ps_unit_fld_stdy_pkg;

 

/
