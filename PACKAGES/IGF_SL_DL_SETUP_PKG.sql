--------------------------------------------------------
--  DDL for Package IGF_SL_DL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI07S.pls 120.1 2005/06/22 10:30:46 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2  DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2 DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2 DEFAULT NULL
);

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dlset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2  DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2 DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dlset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2  DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2 DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2  DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2 DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dlset_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_school_id                         IN     VARCHAR2    DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER      DEFAULT NULL,
    x_orig_fee_perct_plus               IN     NUMBER      DEFAULT NULL,
    x_int_rebate                        IN     NUMBER      DEFAULT NULL,
    x_pnote_print_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_pnote_print_copies                IN     NUMBER      DEFAULT NULL,
    x_acc_note_for_disb                 IN     VARCHAR2    DEFAULT NULL,
    x_affirmation_reqd                  IN     VARCHAR2    DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2    DEFAULT NULL,
    x_disclosure_print_ind              IN     VARCHAR2    DEFAULT NULL,
    x_special_school                    IN     VARCHAR2    DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2    DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_dl_setup_pkg;

 

/
