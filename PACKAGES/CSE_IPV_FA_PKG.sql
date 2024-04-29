--------------------------------------------------------
--  DDL for Package CSE_IPV_FA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_IPV_FA_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEIPVFS.pls 120.5.12000000.1 2007/01/18 05:16:27 appldev ship $

  TYPE invoice_rec IS RECORD(
    invoice_dist_id           NUMBER,
    invoice_dist_line_num     NUMBER,
    invoice_id                NUMBER,
    invoice_num               VARCHAR2(50),
    po_dist_id                NUMBER,
    po_num                    VARCHAR2(20),
    po_vendor_id              NUMBER,
    payables_ccid             NUMBER,
    invoice_price_variance    NUMBER,
    unit_price                NUMBER,
    quantity_invoiced         NUMBER,
    inventory_item_id         NUMBER,
    organization_id           NUMBER);

  TYPE ma_process_rec IS RECORD(
    asset_id                  NUMBER,
    mass_addition_id          NUMBER,
    book_type_code            VARCHAR2(30),
    asset_category_id         NUMBER,
    units                     NUMBER,
    description               VARCHAR2(80),
    date_placed_in_service    DATE,
    expense_ccid              NUMBER);

  TYPE ma_process_tbl IS TABLE OF ma_process_rec INDEX BY binary_integer;

  PROCEDURE process_ipv_to_fa(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_po_header_id            IN         number,
    p_inventory_item_id       IN         number,
    p_organization_id         IN         number,
    p_include_zero_ipv        IN         varchar2);

END cse_ipv_fa_pkg;

 

/
