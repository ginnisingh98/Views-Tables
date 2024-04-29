--------------------------------------------------------
--  DDL for Package ZX_SIM_CONDITIONS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_SIM_CONDITIONS1_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrisimcondspkgs.pls 120.0 2004/06/16 17:44:25 opedrega ship $ */

  PROCEDURE Insert_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER);

  PROCEDURE Update_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER);

  PROCEDURE Delete_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER);

  PROCEDURE Lock_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER);

END ZX_SIM_CONDITIONS1_PKG;

 

/
