--------------------------------------------------------
--  DDL for Package IGF_SP_STDNT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_STDNT_REL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFPI04S.pls 115.1 2002/11/28 14:30:12 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spnsr_stdnt_id                    IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_tot_spnsr_amount                  IN     NUMBER,
    x_min_credit_points                 IN     NUMBER,
    x_min_attendance_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_spnsr_stdnt_id                    IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_tot_spnsr_amount                  IN     NUMBER,
    x_min_credit_points                 IN     NUMBER,
    x_min_attendance_type               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_spnsr_stdnt_id                    IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_tot_spnsr_amount                  IN     NUMBER,
    x_min_credit_points                 IN     NUMBER,
    x_min_attendance_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spnsr_stdnt_id                    IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_tot_spnsr_amount                  IN     NUMBER,
    x_min_credit_points                 IN     NUMBER,
    x_min_attendance_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_spnsr_stdnt_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_spnsr_stdnt_id                    IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_tot_spnsr_amount                  IN     NUMBER      DEFAULT NULL,
    x_min_credit_points                 IN     NUMBER      DEFAULT NULL,
    x_min_attendance_type               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sp_stdnt_rel_pkg;

 

/
