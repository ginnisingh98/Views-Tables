--------------------------------------------------------
--  DDL for Package JL_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AUTO_INVOICE" AUTHID CURRENT_USER as
/* $Header: jlzzrais.pls 120.4.12010000.2 2009/12/15 07:31:58 rsaini ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdff                                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_request_id            Number   -- Concurrent Request id             |
 |                                                                            |
 |   RETURNS                                                                  |
 |      0                       Number   -- Validations Failed                |
 |      1                       Number   -- Validation Succeeded              |
 |                                                                            |
 | HISTORY                                                                    |
 |    10-Aug-97  Marcia Toriyama   Created.                                   |
 |    02-Sep-97  German Bertot     Changed validate_gdff specification from   |
 |                                 Procedure to Function.                     |
 |    02-Sep-2004 Octavio Pedregal  Bug 2367111 - MOAC changes             |
 *----------------------------------------------------------------------------*/
  FUNCTION validate_gdff
       (p_request_id  IN NUMBER,
        p_org_id      IN NUMBER DEFAULT           --Bugfix 2367111
                         to_number(fnd_profile.value('ORG_ID'))) RETURN NUMBER;
-- Added by venkat  04-Aug-1999
  FUNCTION trx_num_upd
       (p_batch_source_id IN NUMBER,
        p_trx_number      IN VARCHAR2,
        p_org_id          IN NUMBER DEFAULT           --Bugfix 2367111
                         to_number(fnd_profile.value('ORG_ID'))
       ) RETURN VARCHAR2;

  FUNCTION validate_tax_attributes  (p_interface_line_id            IN NUMBER
                                   , p_line_type                    IN VARCHAR2
                                   , p_memo_line_id                 IN NUMBER
                                   , p_inventory_item_id            IN NUMBER
                                   , p_product_fiscal_class         IN VARCHAR2
                                   , p_product_category             IN VARCHAR2
                                   , p_trx_business_category        IN VARCHAR2
                                   , p_line_attribute11             IN VARCHAR2
                                   , p_line_attribute12             IN VARCHAR2
                                   , p_address_id                   IN NUMBER
                                   , p_warehouse_id                 IN NUMBER)
  RETURN BOOLEAN;

  FUNCTION validate_interest_attributes (p_interface_line_id IN NUMBER
                                    , p_line_type              IN VARCHAR2
                                    , p_header_attribute1      IN VARCHAR2
                                    , p_header_attribute2      IN VARCHAR2
                                    , p_header_attribute3      IN VARCHAR2
                                    , p_header_attribute4      IN VARCHAR2
                                    , p_header_attribute5      IN VARCHAR2
                                    , p_header_attribute6      IN VARCHAR2
                                    , p_header_attribute7      IN VARCHAR2)
  RETURN BOOLEAN;

  FUNCTION validate_billing_attributes (p_interface_line_id IN NUMBER
                                    , p_line_type             IN VARCHAR2
                                    , p_memo_line_id          IN NUMBER
                                    , p_inventory_item_id     IN NUMBER
                                    , p_header_attribute9     IN VARCHAR2
                                    , p_header_attribute10    IN VARCHAR2
                                    , p_header_attribute11    IN VARCHAR2
                                    , p_header_attribute13    IN VARCHAR2
                                    , p_header_attribute15    IN VARCHAR2
                                    , p_header_attribute16    IN VARCHAR2
                                    , p_header_attribute17    IN VARCHAR2
                                    , p_line_attribute1       IN VARCHAR2
                                    , p_line_attribute4       IN VARCHAR2
                                    , p_line_attribute5       IN VARCHAR2
                                    , p_line_attribute6       IN VARCHAR2
                                    , p_line_attribute7       IN VARCHAR2)
      RETURN BOOLEAN;

  FUNCTION jl_br_cm_upd_inv_status (p_request_id IN NUMBER)
      RETURN NUMBER;        -- Added for bug no 9183563

END JL_ZZ_AUTO_INVOICE;

/
