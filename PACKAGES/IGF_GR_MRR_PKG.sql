--------------------------------------------------------
--  DDL for Package IGF_GR_MRR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_MRR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI12S.pls 115.4 2002/11/28 14:18:11 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mrr_id                            IN OUT NOCOPY NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_current_ssn                       IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mrr_id                            IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_current_ssn                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_mrr_id                            IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_current_ssn                       IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mrr_id                            IN OUT NOCOPY NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_current_ssn                       IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_mrr_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mrr_id                            IN     NUMBER      DEFAULT NULL,
    x_record_type                       IN     VARCHAR2    DEFAULT NULL,
    x_req_inst_pell_id                  IN     VARCHAR2    DEFAULT NULL,
    x_mrr_code1                         IN     VARCHAR2    DEFAULT NULL,
    x_mrr_code2                         IN     VARCHAR2    DEFAULT NULL,
    x_mr_stud_id                        IN     VARCHAR2    DEFAULT NULL,
    x_mr_inst_pell_id                   IN     VARCHAR2    DEFAULT NULL,
    x_stud_orig_ssn                     IN     VARCHAR2    DEFAULT NULL,
    x_orig_name_cd                      IN     VARCHAR2    DEFAULT NULL,
    x_inst_pell_id                      IN     VARCHAR2    DEFAULT NULL,
    x_inst_name                         IN     VARCHAR2    DEFAULT NULL,
    x_inst_addr1                        IN     VARCHAR2    DEFAULT NULL,
    x_inst_addr2                        IN     VARCHAR2    DEFAULT NULL,
    x_inst_city                         IN     VARCHAR2    DEFAULT NULL,
    x_inst_state                        IN     VARCHAR2    DEFAULT NULL,
    x_zip_code                          IN     VARCHAR2    DEFAULT NULL,
    x_faa_name                          IN     VARCHAR2    DEFAULT NULL,
    x_faa_tel                           IN     VARCHAR2    DEFAULT NULL,
    x_faa_fax                           IN     VARCHAR2    DEFAULT NULL,
    x_faa_internet_addr                 IN     VARCHAR2    DEFAULT NULL,
    x_schd_pell_grant                   IN     NUMBER      DEFAULT NULL,
    x_orig_awd_amt                      IN     NUMBER      DEFAULT NULL,
    x_tran_num                          IN     VARCHAR2    DEFAULT NULL,
    x_efc                               IN     NUMBER      DEFAULT NULL,
    x_enrl_dt                           IN     DATE        DEFAULT NULL,
    x_orig_creation_dt                  IN     DATE        DEFAULT NULL,
    x_disb_accepted_amt                 IN     NUMBER      DEFAULT NULL,
    x_last_active_dt                    IN     DATE        DEFAULT NULL,
    x_next_est_disb_dt                  IN     DATE        DEFAULT NULL,
    x_eligibility_used                  IN     NUMBER      DEFAULT NULL,
    x_ed_use_flags                      IN     VARCHAR2    DEFAULT NULL,
    x_stud_last_name                    IN     VARCHAR2    DEFAULT NULL,
    x_stud_first_name                   IN     VARCHAR2    DEFAULT NULL,
    x_stud_middle_name                  IN     VARCHAR2    DEFAULT NULL,
    x_stud_dob                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_current_ssn                       IN     VARCHAR2    DEFAULT NULL
  );

END igf_gr_mrr_pkg;

 

/
