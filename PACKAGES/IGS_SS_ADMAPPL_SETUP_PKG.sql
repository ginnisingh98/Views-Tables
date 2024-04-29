--------------------------------------------------------
--  DDL for Package IGS_SS_ADMAPPL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_ADMAPPL_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB6S.pls 115.10 2002/11/22 13:12:59 knag ship $ */
  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_admappl_setup_id IN NUMBER,
    x_alias_type IN VARCHAR2,
    x_permanent_addr_type IN VARCHAR2,
    x_mailing_addr_type IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_ps_note_type_id IN NUMBER,
    x_we_note_type_id IN NUMBER,
    x_act_note_type_id IN NUMBER,
    x_dependent_of_veteran  IN NUMBER,
    x_app_source_id  IN NUMBER
  );
  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_admappl_setup_id IN NUMBER,
    x_alias_type IN VARCHAR2,
    x_permanent_addr_type IN VARCHAR2,
    x_mailing_addr_type IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_ps_note_type_id IN NUMBER,
    x_we_note_type_id IN NUMBER,
    x_act_note_type_id IN NUMBER,
    x_dependent_of_veteran  IN NUMBER,
    x_app_source_id  IN NUMBER ,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );
  FUNCTION get_pk_for_validation (
    x_admappl_setup_id IN NUMBER
  ) RETURN BOOLEAN;
 PROCEDURE get_fk_igs_ad_note_types_act (
   x_notes_type_id IN NUMBER
    );
 PROCEDURE get_fk_igs_pe_alias_types (
   x_alias_type IN VARCHAR2
    );
/* Code commented as these columns are obsoleted in DLD1.7
 PROCEDURE get_fk_igs_co_addr_type_mat (
   x_addr_type IN VARCHAR2
    );
 PROCEDURE get_fk_igs_co_addr_type_pat (
   x_addr_type IN VARCHAR2
    );
*/
 PROCEDURE get_fk_igs_ad_note_types_we (
   x_notes_type_id IN NUMBER
    );
 PROCEDURE get_fk_igs_pe_person_id_typ (
   x_person_id_type IN VARCHAR2
    );
 PROCEDURE get_fk_igs_ad_note_types_psnt (
   x_notes_type_id IN NUMBER
    );
  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  );
  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admappl_setup_id IN NUMBER DEFAULT NULL,
    x_alias_type IN VARCHAR2 DEFAULT NULL,
    x_permanent_addr_type IN VARCHAR2 DEFAULT NULL,
    x_mailing_addr_type IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_ps_note_type_id IN NUMBER DEFAULT NULL,
    x_we_note_type_id IN NUMBER DEFAULT NULL,
    x_act_note_type_id IN NUMBER DEFAULT NULL,
    x_dependent_of_veteran  IN NUMBER DEFAULT NULL,
    x_app_source_id  IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
END igs_ss_admappl_setup_pkg;

 

/
