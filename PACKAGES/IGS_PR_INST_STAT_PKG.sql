--------------------------------------------------------
--  DDL for Package IGS_PR_INST_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_INST_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI34S.pls 115.4 2002/11/29 03:23:33 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_timeframe                         IN     VARCHAR2,
    x_standard_ind                      IN     VARCHAR2,
    x_display_ind                       IN     VARCHAR2,
    x_include_standard_ind              IN     VARCHAR2,
    x_include_local_ind                 IN     VARCHAR2,
    x_include_other_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_stat_type                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_display_order                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_display_order                     IN     NUMBER      DEFAULT NULL,
    x_timeframe                         IN     VARCHAR2    DEFAULT NULL,
    x_standard_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_display_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_include_standard_ind              IN     VARCHAR2    DEFAULT NULL,
    x_include_local_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_include_other_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE after_dml;

END igs_pr_inst_stat_pkg;

 

/
