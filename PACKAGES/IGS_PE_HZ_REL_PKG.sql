--------------------------------------------------------
--  DDL for Package IGS_PE_HZ_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_HZ_REL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIB1S.pls 120.1 2005/07/08 01:27:31 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag		IN     VARCHAR2	   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag		IN     VARCHAR2	   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag		IN     VARCHAR2	   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2,
    x_primary                           IN     VARCHAR2,
    x_secondary                         IN     VARCHAR2,
    x_joint_salutation                  IN     VARCHAR2,
    x_next_to_kin                       IN     VARCHAR2,
    x_rep_faculty                       IN     VARCHAR2,
    x_rep_staff                         IN     VARCHAR2,
    x_rep_student                       IN     VARCHAR2,
    x_rep_alumni                        IN     VARCHAR2,
    x_emergency_contact_flag		IN     VARCHAR2	   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_relationship_id                   IN     NUMBER,
    x_directional_flag                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_relationship_id                   IN     NUMBER      DEFAULT NULL,
    x_directional_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_primary                           IN     VARCHAR2    DEFAULT NULL,
    x_secondary                         IN     VARCHAR2    DEFAULT NULL,
    x_joint_salutation                  IN     VARCHAR2    DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2    DEFAULT NULL,
    x_rep_faculty                       IN     VARCHAR2    DEFAULT NULL,
    x_rep_staff                         IN     VARCHAR2    DEFAULT NULL,
    x_rep_student                       IN     VARCHAR2    DEFAULT NULL,
    x_rep_alumni                        IN     VARCHAR2    DEFAULT NULL,
    x_emergency_contact_flag		IN     VARCHAR2	   DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_hz_rel_pkg;

 

/
