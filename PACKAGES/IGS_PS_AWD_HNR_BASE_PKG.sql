--------------------------------------------------------
--  DDL for Package IGS_PS_AWD_HNR_BASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_AWD_HNR_BASE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3LS.pls 115.0 2003/10/17 11:20:11 nalkumar noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_awd_hnr_basis_id                  IN OUT NOCOPY NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_awd_hnr_basis_id                  IN OUT NOCOPY NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_awd_hnr_basis_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_awd_hnr_basis_id                  IN     NUMBER      DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_weighted_average                  IN     NUMBER      DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_s_stat_element                    IN     VARCHAR2    DEFAULT NULL,
    x_timeframe                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_awd_hnr_base_pkg;

 

/
