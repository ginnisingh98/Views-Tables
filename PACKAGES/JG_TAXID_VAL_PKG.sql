--------------------------------------------------------
--  DDL for Package JG_TAXID_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_TAXID_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzgtis.pls 120.2 2002/11/12 23:30:14 thwon ship $ */

FUNCTION check_numeric(p_taxpayer_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_length(p_country_code IN VARCHAR2,
                      p_num_digits   IN NUMBER,
                      p_taxpayer_id  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_primary_bank_branch(p_bank_branch_id     IN NUMBER,
                                   p_bank_name          IN VARCHAR2,
                                   p_bank_branch_name   IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_detail_bank_branch(p_bank_branch_id IN NUMBER) RETURN VARCHAR2;

FUNCTION check_uniqueness(p_country_code    IN  VARCHAR2,
                          p_taxpayer_id     IN  VARCHAR2,
                          p_record_id       IN  NUMBER,
                          p_calling_program IN  VARCHAR2,
                          p_orig_system_ref IN  VARCHAR2,
                          p_entity_name     IN  VARCHAR2,
                          p_request_id      IN  NUMBER) RETURN VARCHAR2;

FUNCTION check_unique_tax_reg_num(p_country_code    IN  VARCHAR2,
                                  p_tax_reg_num     IN  VARCHAR2,
                                  p_record_id       IN  NUMBER,
                                  p_calling_program IN  VARCHAR2,
                                  p_orig_system_ref IN  VARCHAR2,
                                  p_entity_name     IN  VARCHAR2,
                                  p_request_id      IN  NUMBER) RETURN VARCHAR2;

PROCEDURE check_cross_module(p_country_code      IN  VARCHAR2,
                             p_entity_name       IN  VARCHAR2,
                             p_taxpayer_id       IN  VARCHAR2,
                             p_origin            IN  VARCHAR2,
                             p_taxid_type        IN  VARCHAR2,
                             p_calling_program   IN  VARCHAR2,
                             p_return_ar         OUT NOCOPY VARCHAR2,
                             p_return_ap         OUT NOCOPY VARCHAR2,
                             p_return_hr         OUT NOCOPY VARCHAR2,
                             p_return_bk         OUT NOCOPY VARCHAR2);

FUNCTION check_algorithm(p_taxpayer_id        IN VARCHAR2,
                         p_country            IN VARCHAR2,
                         p_global_attribute12 IN VARCHAR2) RETURN VARCHAR2;


END JG_TAXID_VAL_PKG;

 

/
