--------------------------------------------------------
--  DDL for Package IGS_FI_SUB_ER_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_SUB_ER_RT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF2S.pls 120.0 2005/09/09 18:49:18 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_err_id                        IN OUT NOCOPY NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_err_id                        IN OUT NOCOPY NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_sub_err_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_fee_as_rate (
    x_far_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sub_err_id                        IN     NUMBER      DEFAULT NULL,
    x_sub_er_id                         IN     NUMBER      DEFAULT NULL,
    x_far_id                            IN     NUMBER      DEFAULT NULL,
    x_create_date                       IN     DATE        DEFAULT NULL,
    x_logical_delete_date               IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_sub_er_rt_pkg;

 

/
