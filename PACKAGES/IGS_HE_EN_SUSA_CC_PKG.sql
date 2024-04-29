--------------------------------------------------------
--  DDL for Package IGS_HE_EN_SUSA_CC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EN_SUSA_CC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI44S.pls 120.1 2005/06/09 23:48:58 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_he_susa_cc_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_he_susa_cc_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_he_susa_cc_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_he_susa_cc_id                     IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_cost_centre                       IN     VARCHAR2    DEFAULT NULL,
    x_subject                           IN     VARCHAR2    DEFAULT NULL,
    x_proportion                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_en_susa_cc_pkg;

 

/
