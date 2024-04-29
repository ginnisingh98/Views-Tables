--------------------------------------------------------
--  DDL for Package JL_ZZ_PO_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_PO_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzul1s.pls 120.1.12010000.2 2008/08/25 06:44:49 vspuli ship $ */


  PROCEDURE get_fcc_code (fcc_code_type IN     VARCHAR2,
                          tran_nat_type IN     VARCHAR2,
                          so_org_id     IN     VARCHAR2,
                          inv_item_id   IN     NUMBER,
                          fcc_code      IN OUT NOCOPY VARCHAR2,
                          tran_nat      IN OUT NOCOPY VARCHAR2,
                          row_number    IN     NUMBER,
                          Errcd         IN OUT NOCOPY NUMBER);

  PROCEDURE get_total_tax (po_header_id IN     NUMBER,
                           total_tax    IN OUT NOCOPY VARCHAR2,
                           row_number   IN     NUMBER,
                           Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_fc_code (form_org_id  IN     NUMBER,
                         form_item_id IN     NUMBER,
                         fc_code      IN OUT NOCOPY VARCHAR2,
                         row_number   IN     NUMBER,
                         Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_global_attributes (form_line_loca_id IN     NUMBER,
                                   ga1               IN OUT NOCOPY VARCHAR2,
                                   ga2               IN OUT NOCOPY VARCHAR2,
                                   ga3               IN OUT NOCOPY VARCHAR2,
                                   ga4               IN OUT NOCOPY VARCHAR2,
                                   ga5               IN OUT NOCOPY VARCHAR2,
                                   ga6               IN OUT NOCOPY VARCHAR2,
                                   row_number        IN     NUMBER,
                                   Errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE get_total_tax_for_release (po_header_id2  IN     NUMBER,
                                       po_release_id2 IN     NUMBER,
                                       total_tax      IN OUT NOCOPY VARCHAR2,
                                       row_number     IN     NUMBER,
                                       Errcd          IN OUT NOCOPY NUMBER);

  PROCEDURE get_context_name3 (global_description IN OUT NOCOPY VARCHAR2,
                               row_number         IN     NUMBER,
                               Errcd              IN OUT NOCOPY NUMBER);

  PROCEDURE get_trx_reason1 (org_id     IN     NUMBER,
                             item_id    IN     NUMBER,
                             trx_reason IN OUT NOCOPY VARCHAR2,
                             fcc        IN OUT NOCOPY VARCHAR2,
                             row_number IN     NUMBER,
                             Errcd      IN OUT NOCOPY NUMBER);

  PROCEDURE get_trx_reason2 (trx_reason IN OUT NOCOPY VARCHAR2,
                             row_number IN     NUMBER,
                             Errcd      IN OUT NOCOPY NUMBER);

  PROCEDURE get_displayed_field (tran_code  IN     VARCHAR2,
                                 disp_field IN OUT NOCOPY VARCHAR2,
                                 row_number IN     NUMBER,
                                 Errcd      IN OUT NOCOPY NUMBER);

  PROCEDURE get_trx_reason_cd_per_req_line(
               p_master_inv_org_id IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
             , p_inventory_org_id  IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
             , p_item_id           IN  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
             , p_org_id            IN  PO_REQUISITION_LINES.ORG_ID%TYPE
             , x_trx_reason_code   OUT NOCOPY PO_REQUISITION_LINES.TRANSACTION_REASON_CODE%TYPE
             , x_error_code        OUT NOCOPY NUMBER);

END JL_ZZ_PO_LIBRARY_1_PKG;

/
