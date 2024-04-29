--------------------------------------------------------
--  DDL for Package IGS_PR_STA_TYPE_ELE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STA_TYPE_ELE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI33S.pls 115.4 2002/11/29 03:23:11 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_s_stat_element                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_sta_type_ele_pkg;

 

/
