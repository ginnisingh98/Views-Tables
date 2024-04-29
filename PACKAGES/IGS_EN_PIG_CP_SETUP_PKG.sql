--------------------------------------------------------
--  DDL for Package IGS_EN_PIG_CP_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_PIG_CP_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI68S.pls 115.4 2003/02/18 09:16:30 npalanis noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_prsid_max_cp                      IN     NUMBER,
    x_prsid_min_cp                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_prsid_max_cp                      IN     NUMBER,
    x_prsid_min_cp                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_prsid_max_cp                      IN     NUMBER,
    x_prsid_min_cp                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_prsid_max_cp                      IN     NUMBER,
    x_prsid_min_cp                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_group_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_persid_group (
    x_group_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_id                          IN     NUMBER      DEFAULT NULL,
    x_prsid_max_cp                      IN     NUMBER      DEFAULT NULL,
    x_prsid_min_cp                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END Igs_En_Pig_Cp_Setup_Pkg;

 

/
