--------------------------------------------------------
--  DDL for Package IGS_PE_FUND_EXCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_FUND_EXCL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI98S.pls 115.3 2002/11/29 01:37:50 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_excl_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_excl_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_excl_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE,
    x_expiry_dt                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fund_excl_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_pee_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_pfe_start_dt                      IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_pe_persenc_effct (
    x_person_id                         IN     NUMBER,
    x_encumbrance_type                  IN     VARCHAR2,
    x_pen_start_dt                      IN     DATE,
    x_s_encmb_effect_type               IN     VARCHAR2,
    x_pee_start_dt                      IN     DATE,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_excl_id                      IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_encumbrance_type                  IN     VARCHAR2    DEFAULT NULL,
    x_pen_start_dt                      IN     DATE        DEFAULT NULL,
    x_s_encmb_effect_type               IN     VARCHAR2    DEFAULT NULL,
    x_pee_start_dt                      IN     DATE        DEFAULT NULL,
    x_pee_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_pfe_start_dt                      IN     DATE        DEFAULT NULL,
    x_expiry_dt                         IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_fund_excl_pkg;

 

/
