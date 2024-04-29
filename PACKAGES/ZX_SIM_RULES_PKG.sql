--------------------------------------------------------
--  DDL for Package ZX_SIM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_SIM_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrisimrulespkgs.pls 120.1 2005/10/27 18:50:45 pla ship $ */

  PROCEDURE Insert_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER);

  PROCEDURE Update_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER);

  PROCEDURE Delete_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER);

  PROCEDURE Lock_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER);

  PROCEDURE add_language;

END ZX_SIM_RULES_PKG;

 

/
