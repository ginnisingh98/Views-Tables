--------------------------------------------------------
--  DDL for Package IGF_DB_PAYS_PRG_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_PAYS_PRG_T_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI08S.pls 115.1 2002/11/28 14:14:56 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dbpays_id                         IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dbpays_id                         IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dbpays_id                         IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dbpays_id                         IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_prg_ver_num                       IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_ver_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dbpays_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dbpays_id                         IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_program_cd                        IN     VARCHAR2    DEFAULT NULL,
    x_prg_ver_num                       IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_unit_ver_num                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_db_pays_prg_t_pkg;

 

/
