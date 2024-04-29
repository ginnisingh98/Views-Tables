--------------------------------------------------------
--  DDL for Package IGF_SL_CL_RESP_R7_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_RESP_R7_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI39S.pls 120.0 2005/06/01 13:58:19 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clresp7_id                        IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_identifier_code_txt        IN     VARCHAR2,
    x_email_txt                         IN     VARCHAR2,
    x_valid_email_flag                  IN     VARCHAR2,
    x_email_effective_date              IN     DATE,
    x_borrower_temp_add_line_1_txt      IN     VARCHAR2,
    x_borrower_temp_add_line_2_txt      IN     VARCHAR2,
    x_borrower_temp_add_city_txt        IN     VARCHAR2,
    x_borrower_temp_add_state_txt       IN     VARCHAR2,
    x_borrower_temp_add_zip_num         IN     NUMBER,
    x_borr_temp_add_zip_xtn_num         IN     NUMBER,
    x_borr_forgn_postal_code_txt        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clresp7_id                        IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_identifier_code_txt        IN     VARCHAR2,
    x_email_txt                         IN     VARCHAR2,
    x_valid_email_flag                  IN     VARCHAR2,
    x_email_effective_date              IN     DATE,
    x_borrower_temp_add_line_1_txt      IN     VARCHAR2,
    x_borrower_temp_add_line_2_txt      IN     VARCHAR2,
    x_borrower_temp_add_city_txt        IN     VARCHAR2,
    x_borrower_temp_add_state_txt       IN     VARCHAR2,
    x_borrower_temp_add_zip_num         IN     NUMBER,
    x_borr_temp_add_zip_xtn_num         IN     NUMBER,
    x_borr_forgn_postal_code_txt        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clresp7_id                        IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_identifier_code_txt        IN     VARCHAR2,
    x_email_txt                         IN     VARCHAR2,
    x_valid_email_flag                  IN     VARCHAR2,
    x_email_effective_date              IN     DATE,
    x_borrower_temp_add_line_1_txt      IN     VARCHAR2,
    x_borrower_temp_add_line_2_txt      IN     VARCHAR2,
    x_borrower_temp_add_city_txt        IN     VARCHAR2,
    x_borrower_temp_add_state_txt       IN     VARCHAR2,
    x_borrower_temp_add_zip_num         IN     NUMBER,
    x_borr_temp_add_zip_xtn_num         IN     NUMBER,
    x_borr_forgn_postal_code_txt        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clresp7_id                        IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code_txt                   IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_identifier_code_txt        IN     VARCHAR2,
    x_email_txt                         IN     VARCHAR2,
    x_valid_email_flag                  IN     VARCHAR2,
    x_email_effective_date              IN     DATE,
    x_borrower_temp_add_line_1_txt      IN     VARCHAR2,
    x_borrower_temp_add_line_2_txt      IN     VARCHAR2,
    x_borrower_temp_add_city_txt        IN     VARCHAR2,
    x_borrower_temp_add_state_txt       IN     VARCHAR2,
    x_borrower_temp_add_zip_num         IN     NUMBER,
    x_borr_temp_add_zip_xtn_num         IN     NUMBER,
    x_borr_forgn_postal_code_txt        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clresp7_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_cl_resp_r4 (
    x_clrp1_id                            IN     NUMBER
  ) ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clresp7_id                        IN     NUMBER      DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_identifier_code_txt        IN     VARCHAR2    DEFAULT NULL,
    x_email_txt                         IN     VARCHAR2    DEFAULT NULL,
    x_valid_email_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_email_effective_date              IN     DATE        DEFAULT NULL,
    x_borrower_temp_add_line_1_txt      IN     VARCHAR2    DEFAULT NULL,
    x_borrower_temp_add_line_2_txt      IN     VARCHAR2    DEFAULT NULL,
    x_borrower_temp_add_city_txt        IN     VARCHAR2    DEFAULT NULL,
    x_borrower_temp_add_state_txt       IN     VARCHAR2    DEFAULT NULL,
    x_borrower_temp_add_zip_num         IN     NUMBER      DEFAULT NULL,
    x_borr_temp_add_zip_xtn_num         IN     NUMBER      DEFAULT NULL,
    x_borr_forgn_postal_code_txt        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_cl_resp_r7_dtls_pkg;

 

/
