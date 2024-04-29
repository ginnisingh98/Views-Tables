--------------------------------------------------------
--  DDL for Package IGS_AD_HZ_EXTRACURR_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_HZ_EXTRACURR_ACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB9S.pls 120.0 2005/06/01 22:03:57 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_extracurr_act_id               IN OUT NOCOPY NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_extracurr_act_id               IN     NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_extracurr_act_id               IN     NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_extracurr_act_id               IN OUT NOCOPY NUMBER,
    x_person_interest_id                IN     NUMBER,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_hz_extracurr_act_id            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_person_interest (
    x_person_interest_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_extracurr_act_id               IN     NUMBER      DEFAULT NULL,
    x_person_interest_id                IN     NUMBER      DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_hours_per_week                    IN     NUMBER      DEFAULT NULL,
    x_weeks_per_year                    IN     NUMBER      DEFAULT NULL,
    x_activity_source_cd                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL
  );

END igs_ad_hz_extracurr_act_pkg;

 

/
