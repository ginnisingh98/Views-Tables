--------------------------------------------------------
--  DDL for Package JL_ZZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_TAX" AUTHID CURRENT_USER AS
/* $Header: jlzzrtxs.pls 120.2 2004/10/29 15:41:32 opedrega ship $ */

g_first_tax_line               BOOLEAN;
g_prev_header_id               NUMBER;
g_prev_cust_trx_line_number    NUMBER;
g_prev_invoice_line_number     NUMBER;
g_first_processed_invoice_line NUMBER;
g_first_processed_category_id  NUMBER;

TYPE ALL_TAX_GROUP IS RECORD (
  TaxGroup         NUMBER(15),
  TaxCateg         NUMBER(15),
  DetAttrValue     VARCHAR2(30)
  );
TYPE ALL_TAX_GRP_TAB IS TABLE OF ALL_TAX_GROUP INDEX BY BINARY_INTEGER;

g_all_tax_grp      ALL_TAX_GRP_TAB;

TYPE REL_TAX_LINE_AMOUNTS IS RECORD (
  TaxCateg         NUMBER(15),
  GrpAttrName      VARCHAR2(30),
  GrpAttrValue     VARCHAR2(30),
  ApplPriorBase    NUMBER,
  ChargedTax       NUMBER,
  CalcltdTax       NUMBER
  );
TYPE REL_TAX_LINE_AMT_TAB IS TABLE OF REL_TAX_LINE_AMOUNTS
                                                        INDEX BY BINARY_INTEGER;

g_rel_tax_line_amounts    REL_TAX_LINE_AMT_TAB;

TYPE REL_TRX_CATEG IS RECORD (
  ExistFlag           VARCHAR2(1)
  );
TYPE REL_TRX_CATEG_TAB IS TABLE OF REL_TRX_CATEG INDEX BY BINARY_INTEGER;

g_rel_trx_categ    REL_TRX_CATEG_TAB;


FUNCTION get_category_tax_code (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_set_of_books_id		IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_base_amount                 IN NUMBER,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2
  ) return VARCHAR2 ;

-- Commented for Bug 1934820.
-- PRAGMA RESTRICT_REFERENCES (get_category_tax_code, WNDS);

PROCEDURE get_category_tax_rule (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_set_of_books_id		IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_base_amount                 IN NUMBER,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2,
  o_tax_code                    IN OUT NOCOPY VARCHAR2,
  o_base_rate                   IN OUT NOCOPY NUMBER,
  o_rule_data_id                IN OUT NOCOPY NUMBER,
  o_rule_id                     IN OUT NOCOPY NUMBER
  );

PROCEDURE get_rule_info(
           p_rule                       IN     VARCHAR2,
           p_fiscal_classification_code IN     VARCHAR2,
           p_tax_category_id            IN     NUMBER,
           p_trx_date                   IN     DATE,
           p_ship_to_site_use_id        IN     NUMBER,
           p_bill_to_site_use_id        IN     NUMBER,
           p_inventory_item_id          IN     NUMBER,
           p_ship_from_warehouse_id     IN     NUMBER,
           p_group_tax_id               IN     NUMBER,
           p_contributor_type           IN     VARCHAR2,
           p_transaction_nature         IN     VARCHAR2,
           p_establishment_type         IN     VARCHAR2,
           p_transaction_nature_class   IN     VARCHAR2,
           p_inventory_organization_id  IN     NUMBER,
           p_ship_to_customer_id        IN     NUMBER,
           p_bill_to_customer_id        IN     NUMBER,
           p_warehouse_location_id      IN     NUMBER,
           p_memo_line_id               IN     NUMBER,
           p_base_amount                IN     NUMBER,
           p_application                IN     VARCHAR2,
           o_tax_code                   IN OUT NOCOPY VARCHAR2,
           o_base_rate                  IN OUT NOCOPY NUMBER,
           o_rule_data_id               IN OUT NOCOPY NUMBER );

--PRAGMA RESTRICT_REFERENCES (get_rule_info, WNDS);

FUNCTION get_tax_base_rate (
  p_tax_category_id             IN NUMBER,
  p_cust_trx_type_id            IN NUMBER,
  p_ship_to_site_use_id         IN NUMBER,
  p_bill_to_site_use_id         IN NUMBER,
  p_inventory_item_id           IN NUMBER,
  p_group_tax_id                IN NUMBER,
  p_memo_line_id                IN NUMBER,
  p_ship_to_customer_id         IN NUMBER,
  p_bill_to_customer_id         IN NUMBER,
  p_trx_date                    IN DATE,
  p_application                 IN VARCHAR2,
  p_warehouse_id                IN NUMBER,
  p_level                       IN VARCHAR2,
  p_fiscal_classification_code  IN VARCHAR2,
  p_inventory_organization_id   IN NUMBER,
  p_location_structure_id       IN NUMBER,
  p_location_segment_num        IN NUMBER,
  p_transaction_nature          IN VARCHAR2,
  p_establishment_type          IN VARCHAR2,
  p_contributor_type            IN VARCHAR2,
  p_warehouse_location_id       IN NUMBER,
  p_transaction_nature_class    IN VARCHAR2
  ) return NUMBER ;

--PRAGMA RESTRICT_REFERENCES (get_tax_base_rate, WNDS);

--Bug 2367111
FUNCTION calculate
     (p_org_id IN NUMBER) RETURN VARCHAR2;

-- Bugfix 1388703
PROCEDURE calculate_tax_amount (p_transaction_nature       IN     VARCHAR2,
                                p_transaction_nature_class IN     VARCHAR2,
                                p_organization_class       IN     VARCHAR2,
                                p_base_amount	           IN     NUMBER,
                                p_tax_group	           IN     NUMBER,
                                p_tax_category_id	   IN     NUMBER,
                                p_trx_date	           IN     DATE,
                                p_rule_id	           IN     NUMBER,
                                p_ship_to_site_use_id      IN     NUMBER,
                                p_bill_to_site_use_id      IN     NUMBER,
                                p_establishment_type       IN     VARCHAR2,
                                p_contributor_type         IN     VARCHAR2,
                                p_customer_trx_id          IN     NUMBER,
                                p_customer_trx_line_id     IN     NUMBER,
                                p_related_customer_trx_id  IN     NUMBER,
                                p_previous_customer_trx_id IN     NUMBER,
                                p_location_id              IN     NUMBER,
                                p_contributor_class        IN     VARCHAR2,
                                p_set_of_books_id          IN     NUMBER,
                                p_latin_return_code        IN OUT NOCOPY VARCHAR,
                                p_tax_amount	           IN OUT NOCOPY NUMBER,
                                p_tax_rate	           IN OUT NOCOPY NUMBER,
                                p_calculated_tax_amount    IN OUT NOCOPY NUMBER,
                                p_exchange_rate            IN     NUMBER);

PROCEDURE calculate_latin_tax (p_tax_category_id            IN     NUMBER,
                               p_rule_id                    IN     NUMBER,
                               p_group_tax_id               IN     NUMBER,
                               p_trx_date                   IN     DATE,
                               p_contributor_type           IN     VARCHAR2,
                               p_transaction_nature         IN     VARCHAR2,
                               p_establishment_type         IN     VARCHAR2,
                               p_trx_type_id                IN     NUMBER,
                               p_ship_to_site_use_id        IN     NUMBER,
                               p_bill_to_site_use_id        IN     NUMBER,
                               p_inventory_item_id          IN     NUMBER,
                               p_memo_line_id               IN     NUMBER,
                               p_ship_to_cust_id            IN     NUMBER,
                               p_bill_to_cust_id            IN     NUMBER,
                               p_application                IN     VARCHAR2,
                               p_ship_from_warehouse_id     IN     NUMBER,
                               p_fiscal_classification_code IN     VARCHAR2,
                               p_warehouse_location_id      IN     NUMBER,
                               p_transaction_nature_class   IN     VARCHAR2,
                               p_set_of_books_id            IN     NUMBER,
                               p_location_structure_id      IN     NUMBER,
                               p_location_segment_num       IN     VARCHAR2,
                               p_entered_amount             IN     NUMBER,
                               p_customer_trx_id            IN     NUMBER,
                               p_customer_trx_line_id       IN     NUMBER,
                               p_related_customer_trx_id    IN     NUMBER,
                               p_previous_customer_trx_id   IN     NUMBER,
                               p_contributor_class          IN     VARCHAR2,
                               p_organization_class         IN     VARCHAR2,
                               p_tax_rate                   IN OUT NOCOPY NUMBER,
                               p_base_rate                  IN     NUMBER,
                               p_base_amount                IN OUT NOCOPY NUMBER,
                               o_tax_amount                 IN OUT NOCOPY NUMBER,
                               o_latin_return_code          IN OUT NOCOPY VARCHAR,
                               p_calculated_tax_amount      IN OUT NOCOPY NUMBER,
                               p_exchange_rate              IN     NUMBER);

FUNCTION get_legal_message (
             p_rule_id                    IN NUMBER,
             p_rule_data_id               IN NUMBER,
             p_legal_message_exception    IN VARCHAR2,
             p_ship_from_warehouse_id     IN NUMBER) RETURN VARCHAR2;

END JL_ZZ_TAX;

 

/
