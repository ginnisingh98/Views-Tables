--------------------------------------------------------
--  DDL for Package ZX_TDS_PROCESS_CEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_PROCESS_CEC_PVT" AUTHID CURRENT_USER as
/* $Header: zxdilcecevalpvs.pls 120.7 2006/12/27 18:45:29 svaze ship $ */

TYPE action_rec_type is RECORD(
  tax_condition_id   AR_TAX_CONDITIONS_ALL.tax_condition_id%type,
  action_type        AR_TAX_CONDITION_ACTIONS_ALL.TAX_CONDITION_ACTION_TYPE%type,
  action_code        AR_TAX_CONDITION_ACTIONS_ALL.TAX_CONDITION_ACTION_CODE%type,
  action_value       AR_TAX_CONDITION_ACTIONS_ALL.TAX_CONDITION_ACTION_VALUE%type);    -- Bug 5128566

TYPE action_rec_tbl_type is table of action_rec_type
index by BINARY_INTEGER;


PROCEDURE evaluate_cec (p_constraint_id               IN     NUMBER DEFAULT NULL,
                       p_condition_set_id             IN     NUMBER DEFAULT NULL,
                       p_exception_set_id             IN     NUMBER DEFAULT NULL,
                       p_cec_ship_to_party_site_id    IN     NUMBER,
                       p_cec_bill_to_party_site_id    IN     NUMBER,
                       p_cec_ship_to_party_id         IN     NUMBER,
                       p_cec_bill_to_party_id         IN     NUMBER,
                       p_cec_poo_location_id          IN     NUMBER,
                       p_cec_poa_location_id          IN     NUMBER,
                       p_cec_trx_id                   IN     NUMBER,
                       p_cec_trx_line_id              IN     NUMBER,
                       p_cec_ledger_id                IN     NUMBER,
                       p_cec_internal_organization_id IN     NUMBER,
                       p_cec_so_organization_id       IN     NUMBER,
                       p_cec_product_org_id           IN     NUMBER,
                       p_cec_product_id               IN     NUMBER,
                       p_cec_trx_type_id              IN     NUMBER,
                       p_cec_trx_line_date            IN     DATE,
                       p_cec_fob_point                IN     VARCHAR2,
		       p_cec_ship_to_site_use_id      IN     VARCHAR2,
                       p_cec_bill_to_site_use_id      IN     VARCHAR2,
                       p_cec_result                      OUT NOCOPY BOOLEAN,
                       p_action_rec_tbl                  OUT NOCOPY action_rec_tbl_type,
                       p_return_status                   OUT NOCOPY VARCHAR2,
                       p_error_buffer                    OUT NOCOPY VARCHAR2);



FUNCTION  ship_to (p_classification IN VARCHAR2 Default NULL,
                   p_operator       IN VARCHAR2 Default NULL,
                   p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  bill_to (p_classification IN VARCHAR2 Default NULL,
                   p_operator       IN VARCHAR2 Default NULL,
                   p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  ship_from (p_classification IN VARCHAR2 Default NULL,
                     p_operator       IN VARCHAR2 Default NULL,
                     p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  poo
            (p_classification IN VARCHAR2 Default NULL,
             p_operator       IN VARCHAR2 Default NULL,
             p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  poa (p_classification IN VARCHAR2 Default NULL,
               p_operator       IN VARCHAR2 Default NULL,
               p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  trx (p_classification IN VARCHAR2 Default NULL,
               p_operator       IN VARCHAR2 Default NULL,
               p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  item (p_classification IN VARCHAR2 Default NULL,
                p_operator       IN VARCHAR2 Default NULL,
                p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

FUNCTION  tax_code (p_classification IN VARCHAR2 Default NULL,
                    p_operator       IN VARCHAR2 Default NULL,
                    p_value          IN VARCHAR2 DEFAULT NULL)
          return BOOLEAN;

PROCEDURE user_message  (p_msg IN VARCHAR2 DEFAULT NULL);

PROCEDURE system_message(p_msg IN VARCHAR2 DEFAULT NULL);

PROCEDURE apply_exception       (p_exception IN VARCHAR2 DEFAULT NULL);
PROCEDURE do_not_apply_exception(p_exception IN VARCHAR2 DEFAULT NULL);
PROCEDURE use_tax_code          (p_tax_code  IN VARCHAR2 DEFAULT NULL);

PROCEDURE use_this_tax_code (p_tax_code       IN VARCHAR2 DEFAULT NULL);
PROCEDURE default_tax_code (p_tax_code       IN VARCHAR2 DEFAULT NULL); --Bug 5730672
PROCEDURE use_this_tax_group(p_tax_group_code IN VARCHAR2 DEFAULT NULL);

PROCEDURE do_not_use_this_tax_code (p_param IN VARCHAR2 DEFAULT NULL);
PROCEDURE do_not_use_this_tax_group(p_param IN VARCHAR2 DEFAULT NULL);

FUNCTION get_location_column(p_style          IN VARCHAR2,
                             p_classification IN VARCHAR2) return VARCHAR2;

FUNCTION get_site_location (p_site_use_id    IN NUMBER,
                            p_classification IN VARCHAR2)
         return VARCHAR2;

FUNCTION get_hr_location (p_organization_id IN NUMBER,
                          p_location_id     IN NUMBER,
                          p_classification IN VARCHAR2)
         return VARCHAR2;

END ZX_TDS_PROCESS_CEC_PVT;

 

/
