--------------------------------------------------------
--  DDL for Package IGS_CO_S_PERLT_RPTGP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_S_PERLT_RPTGP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI27S.pls 115.2 2002/11/29 01:08:52 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_sup_repeating_group_cd            IN     VARCHAR2,
    x_sup_splrg_sequence_number         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_s_perlt_rptgp(
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_co_s_per_ltr (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_co_ltr_rpt_grp (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_letter_repeating_group_cd         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_letter_repeating_group_cd         IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_sup_repeating_group_cd            IN     VARCHAR2    DEFAULT NULL,
    x_sup_splrg_sequence_number         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_s_perlt_rptgp_pkg;

 

/
