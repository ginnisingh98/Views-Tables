--------------------------------------------------------
--  DDL for Package IGS_FI_A_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_A_HIERARCHIES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI89S.pls 120.1 2005/09/22 03:37:03 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_hierarchy_id                 IN OUT NOCOPY NUMBER,
    x_hierarchy_name                    IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_hierarchy_name                    IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_description                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_hierarchy_name                    IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_hierarchy_id                 IN OUT NOCOPY NUMBER,
    x_hierarchy_name                    IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_appl_hierarchy_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_hierarchy_name                    IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_hierarchy_id                 IN     NUMBER      DEFAULT NULL,
    x_hierarchy_name                    IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_effective_start_date              IN     DATE        DEFAULT NULL,
    x_effective_end_date                IN     DATE        DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_a_hierarchies_pkg;

 

/
