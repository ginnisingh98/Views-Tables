--------------------------------------------------------
--  DDL for Package IGF_AW_COA_GRP_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_GRP_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI06S.pls 120.0 2005/06/01 13:53:15 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_default_value                     IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_pell_coa                          IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER       DEFAULT NULL,
    x_pell_alternate_amt                IN     NUMBER       DEFAULT NULL,
    x_item_dist                         IN     VARCHAR2     DEFAULT NULL,
    x_lock_flag                         IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R'

    );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_default_value                     IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_pell_coa                          IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER       DEFAULT NULL,
    x_pell_alternate_amt                IN     NUMBER       DEFAULT NULL,
    x_item_dist                         IN     VARCHAR2     DEFAULT NULL,
    x_lock_flag                         IN     VARCHAR2     DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_default_value                     IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_pell_coa                          IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER       DEFAULT NULL,
    x_pell_alternate_amt                IN     NUMBER       DEFAULT NULL,
    x_item_dist                         IN     VARCHAR2     DEFAULT NULL,
    x_lock_flag                         IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_default_value                     IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_pell_coa                          IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER       DEFAULT NULL,
    x_pell_alternate_amt                IN     NUMBER       DEFAULT NULL,
    x_item_dist                         IN     VARCHAR2     DEFAULT NULL,
    x_lock_flag                         IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_coa_group (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_item (
    x_item_code                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_coa_code                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_default_value                     IN     NUMBER      DEFAULT NULL,
    x_fixed_cost                        IN     VARCHAR2    DEFAULT NULL,
    x_pell_coa                          IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_pell_amount                       IN     NUMBER      DEFAULT NULL,
    x_pell_alternate_amt                IN     NUMBER      DEFAULT NULL,
    x_item_dist                         IN     VARCHAR2    DEFAULT NULL,
    x_lock_flag                         IN     VARCHAR2    DEFAULT NULL
    );

END igf_aw_coa_grp_item_pkg;

 

/
