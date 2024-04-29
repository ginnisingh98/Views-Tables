--------------------------------------------------------
--  DDL for Package IGS_FI_1098T_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_1098T_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE8S.pls 120.0 2005/09/09 19:33:30 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stu_1098t_id                      IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stu_1098t_id                      IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stu_1098t_id                      IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_extract_date                      IN     DATE,
    x_party_name                        IN     VARCHAR2,
    x_taxid                             IN     VARCHAR2,
    x_stu_name_control                  IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_refund_amt                        IN     NUMBER,
    x_half_time_flag                    IN     VARCHAR2,
    x_grad_flag                         IN     VARCHAR2,
    x_special_data_entry                IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_irs_filed_flag                    IN     VARCHAR2,
    x_correction_flag                   IN     VARCHAR2,
    x_correction_type_code              IN     VARCHAR2,
    x_stmnt_print_flag                  IN     VARCHAR2,
    x_override_flag                     IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_delivery_point_code               IN     VARCHAR2,
    x_payment_amt                       IN     NUMBER,
    x_billed_amt                        IN     NUMBER,
    x_adj_amt                           IN     NUMBER,
    x_fin_aid_amt                       IN     NUMBER,
    x_fin_aid_adj_amt                   IN     NUMBER,
    x_next_acad_flag                    IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_stu_1098t_id                      IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_stu_1098t_id                      IN     NUMBER      DEFAULT NULL,
    x_tax_year_name                     IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_extract_date                      IN     DATE        DEFAULT NULL,
    x_party_name                        IN     VARCHAR2    DEFAULT NULL,
    x_taxid                             IN     VARCHAR2    DEFAULT NULL,
    x_stu_name_control                  IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_refund_amt                        IN     NUMBER      DEFAULT NULL,
    x_half_time_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_grad_flag                         IN     VARCHAR2    DEFAULT NULL,
    x_special_data_entry                IN     VARCHAR2    DEFAULT NULL,
    x_status_code                       IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_file_name                         IN     VARCHAR2    DEFAULT NULL,
    x_irs_filed_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_correction_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_correction_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_stmnt_print_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_override_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_postal_code                       IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_delivery_point_code               IN     VARCHAR2    DEFAULT NULL,
    x_payment_amt                       IN     NUMBER      DEFAULT NULL,
    x_billed_amt                        IN     NUMBER      DEFAULT NULL,
    x_adj_amt                           IN     NUMBER      DEFAULT NULL,
    x_fin_aid_amt                       IN     NUMBER      DEFAULT NULL,
    x_fin_aid_adj_amt                   IN     NUMBER      DEFAULT NULL,
    x_next_acad_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_1098t_data_pkg;

 

/
