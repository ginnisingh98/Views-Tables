--------------------------------------------------------
--  DDL for Package IGR_I_ENTRY_LVLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_ENTRY_LVLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH01S.pls 120.0 2005/06/02 03:36:15 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inq_entry_level_id                IN OUT NOCOPY NUMBER,
    x_inq_entry_level                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inq_entry_level_id                IN     NUMBER,
    x_inq_entry_level                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inq_entry_level_id                IN     NUMBER,
    x_inq_entry_level                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inq_entry_level_id                IN OUT NOCOPY NUMBER,
    x_inq_entry_level                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inq_entry_level_id                IN     NUMBER ,
    x_closed_ind                        IN     VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_inq_entry_level                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inq_entry_level_id                IN     NUMBER      DEFAULT NULL,
    x_inq_entry_level                   IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igr_i_entry_lvls_pkg;

 

/
