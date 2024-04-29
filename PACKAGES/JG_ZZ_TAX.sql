--------------------------------------------------------
--  DDL for Package JG_ZZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_TAX" AUTHID CURRENT_USER AS
/* $Header: jgzzrtxs.pls 120.7 2004/12/10 02:29:46 lxzhang ship $ */

FUNCTION recalculate_tax RETURN VARCHAR2;

FUNCTION get_default_tax_code (p_set_of_books_id     IN NUMBER,
                               p_trx_date            IN DATE,
                               p_trx_type_id         IN NUMBER) RETURN VARCHAR2;

FUNCTION get_default_tax_code (
                            p_ship_to_site_use_id IN NUMBER
                           ,p_bill_to_site_use_id IN NUMBER
                           ,p_inventory_item_id   IN NUMBER
                           ,p_organization_id     IN NUMBER
                           ,p_warehouse_id        IN NUMBER
                           ,p_set_of_books_id     IN NUMBER
                           ,p_trx_date            IN DATE
                           ,p_trx_type_id         IN NUMBER
                           ,p_cust_trx_id         IN NUMBER
                           ,p_cust_trx_line_id    IN NUMBER
                           ,APPL_SHORT_NAME       IN VARCHAR2
                           ,FUNC_SHORT_NAME       IN VARCHAR2)
RETURN VARCHAR2;

END JG_ZZ_TAX;

 

/
