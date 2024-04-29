--------------------------------------------------------
--  DDL for Package IGS_AD_RECRUIT_PI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_RECRUIT_PI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIE5S.pls 115.5 2002/11/28 22:33:08 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_probability_index_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_probability_index_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_probability_index_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_probability_index_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_probability_index_id              IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  PROCEDURE get_fk_igs_pe_person (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_probability_index_id              IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_probability_type_code_id          IN     NUMBER      DEFAULT NULL,
    x_calculation_date                  IN     DATE        DEFAULT NULL,
    x_probability_value                 IN     NUMBER      DEFAULT NULL,
    x_probability_source_code_id        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_recruit_pi_pkg;

 

/
