--------------------------------------------------------
--  DDL for Package IGF_AW_CORRESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_CORRESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI37S.pls 115.4 2002/11/28 14:42:25 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_crsp_id                           IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_line_data                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_crsp_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_line_data                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_crsp_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_line_data                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_crsp_id                           IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_line_data                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_crsp_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_crsp_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_line_number                       IN     NUMBER      DEFAULT NULL,
    x_line_data                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_corresp_pkg;

 

/
