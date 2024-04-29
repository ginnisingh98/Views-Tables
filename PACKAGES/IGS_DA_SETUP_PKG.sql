--------------------------------------------------------
--  DDL for Package IGS_DA_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI40S.pls 120.1 2005/09/28 02:22:50 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type                IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type                IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type                IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type                IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_s_control_num                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_unit_set_cat (
    x_unit_set_cat                      IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_or_org_alt_idtyp (
    x_org_alternate_id_type             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_s_control_num                     IN     NUMBER      DEFAULT NULL,
    x_program_definition_ind            IN     VARCHAR2    DEFAULT NULL,
    x_default_student_id_type                IN     VARCHAR2    DEFAULT NULL,
    x_default_inst_id_type                   IN     VARCHAR2    DEFAULT NULL,
    x_default_address_type              IN     VARCHAR2    DEFAULT NULL,
    x_wif_major_unit_set_cat            IN     VARCHAR2    DEFAULT NULL,
    x_wif_minor_unit_set_cat            IN     VARCHAR2    DEFAULT NULL,
    x_wif_track_unit_set_cat            IN     VARCHAR2    DEFAULT NULL,
    x_wif_unit_set_title                IN     VARCHAR2    DEFAULT NULL,
    x_third_party_options               IN     VARCHAR2    DEFAULT NULL,
--    x_advisor_relationship_ind          IN     VARCHAR2    DEFAULT NULL,
    x_display_container_ind             IN     VARCHAR2    DEFAULT NULL,
    x_container_title                   IN     VARCHAR2    DEFAULT NULL,
    x_link_text                         IN     VARCHAR2    DEFAULT NULL,
    x_link_url                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_setup_pkg;

 

/
