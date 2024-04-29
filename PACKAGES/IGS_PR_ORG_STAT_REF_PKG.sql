--------------------------------------------------------
--  DDL for Package IGS_PR_ORG_STAT_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_ORG_STAT_REF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI37S.pls 115.3 2002/11/29 03:24:20 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2,
    x_include_or_exclude                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_unit_ref_cd                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_org_stat (
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_unit_ref_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_include_or_exclude                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_org_stat_ref_pkg;

 

/
