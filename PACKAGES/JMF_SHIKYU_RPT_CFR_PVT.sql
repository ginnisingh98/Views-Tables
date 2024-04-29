--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RPT_CFR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RPT_CFR_PVT" AUTHID CURRENT_USER AS
--$Header: JMFVCFRS.pls 120.12 2006/11/22 01:01:34 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFVCFRS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Specification file of the package for creating     |
--|                        temporary data for SHIKYU Confirmation Report.     |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   15-APR-2005          shu  Created.                                      |
--|   07-DEC-2005          shu  added procedures rpt_get_xxx for report data  |
--|   19-JAN-2006          shu  changed parameter p_currency_conversion_date  |
--|                             from date to varchar2;                        |
--|                             added rpt_debug_show_mid_data procedure       |
--|   19-JUN-2006          amy  updated to fix bug 5391412                    |
--|                             Renamed original procedure rpt_get_SubPO_data |
--|                             as rpt_get_SubPO_data_Onhand for future use   |
--|                             Added new procedure rpt_get_SubPO_data        |
--|   17-NOV-2006          amy  updated procedure add_data_to_cfr_temp        |
--|                             and rpt_get_UnReceived_data to fix bug 5583680|
--|   21-NOV-2006         vchu  Bug fix for 5665334: Changed the signature    |
--|                             of cfr_before_report_trigger to pass in the   |
--|                             ID of the FROM and TO OEM Organization,       |
--|                             instead of the name.  Also added a new helper |
--|                             procedure to get the name of an Inventory     |
--|                             organization given the ID.                    |
--+===========================================================================+

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_RPT_CFR_PVT';

  -- Public function and procedure declarations

    -- Bug 5665334
  --========================================================================
  -- PROCEDURE : get_organization_name    PUBLIC
  -- PARAMETERS: p_organization_id        Inventory Organization ID
  --           : x_organization_name      Organization Name to be returned
  -- COMMENT   : The procedure returns the name of an Inventory Organization
  --             if the input ID parameter was valid.
  --========================================================================
  PROCEDURE get_organization_name
  ( p_organization_id      IN  NUMBER
  , x_organization_name    OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : cfr_before_report_trigger    PUBLIC
  -- PARAMETERS: p_rpt_mode                       the report mode: External/Internal report
  --           : p_ou_id                      Operating unit id
  --           : p_supplier_name_from         the supplier name from
  --           : p_supplier_name_to           the supplier name to
  --           : p_supplier_site_code_from    the supplier site code from
  --           : p_supplier_site_code_to      the supplier site code to
  --           : p_oem_inv_org_name_from      oem inventory org name from
  --           : p_oem_inv_org_name_to        oem inventory org name to
  --           : p_item_number_from           item number from
  --           : p_item_number_to             item number to
  --           : p_days_received              received after the days ago
  --           : p_sort_by                    By Supplier/Site or By Item,
  --                                          the External report can use only by Supplier/Site
  --           : p_currency_conversion_type   the currency conversion type
  --           : p_currency_conversion_date   the currency conversion date
  -- COMMENT   : this procedure will be called in the before report trigger,
  --             all the other needed procedures will be called in this procedure
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE cfr_before_report_trigger
  (
    p_rpt_mode                 IN VARCHAR2
   ,p_ou_id                    IN NUMBER
   ,p_supplier_name_from       IN VARCHAR2
   ,p_supplier_site_code_from  IN VARCHAR2
   ,p_supplier_name_to         IN VARCHAR2
   ,p_supplier_site_code_to    IN VARCHAR2
   ,p_oem_inv_org_id_from      IN NUMBER    -- Bug 5665334
   ,p_oem_inv_org_id_to        IN NUMBER    -- Bug 5665334
   ,p_item_number_from         IN VARCHAR2
   ,p_item_number_to           IN VARCHAR2
   ,p_days_received            IN NUMBER
   ,p_sort_by                  IN VARCHAR2
   ,p_currency_conversion_type IN VARCHAR2
   ,p_currency_conversion_date IN VARCHAR2
   ,p_functional_currency      IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : cfr_get_onhand_components    PUBLIC
  -- PARAMETERS: p_onhand_row_type            row type id to identify the
  --                                          onhand components information
  --           : p_ou_id                      Operating unit id
  --           : p_supplier_name_from         the supplier name from
  --           : p_supplier_site_code_from    the supplier site code from
  --           : p_supplier_name_to           the supplier name to
  --           : p_supplier_site_code_to      the supplier site code to
  --           : p_oem_inv_org_name_from      oem inventory org name from
  --           : p_oem_inv_org_name_to        oem inventory org name to
  --           : p_item_number_from           item id from
  --           : p_item_number_to             item id to
  -- COMMENT   : It is used to get all the onhand compoents primary UOM quantity;
  --             (reference to the condition:''Operating Unit, 'from OEM INV organization' ,'to OEM INV organization',
  --             'From supplier','From site','To supplier','To site','From Item','To item')
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_onhand_components
  (
    p_onhand_row_type         IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_supplier_name_from      IN VARCHAR2
   ,p_supplier_site_code_from IN VARCHAR2
   ,p_supplier_name_to        IN VARCHAR2
   ,p_supplier_site_code_to   IN VARCHAR2
   ,p_oem_inv_org_name_from   IN VARCHAR2
   ,p_oem_inv_org_name_to     IN VARCHAR2
   ,p_item_number_from        IN VARCHAR2
   ,p_item_number_to          IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : get_rpt_confirmation_data    PUBLIC
  -- PARAMETERS: p_onhand_row_type            row type id to identify the
  --                                          onhand components information
  --           : p_rep_po_unalloc_row_type    replenishment po unalloc row in mid-temp table
  --           : p_rep_po_unconsumed_row_type replenishment po unconsume row in mid-temp table
  --           : p_sub_po_unconsumed_row_type subcontract po unconsume row in mid-temp table
  --           : p_days_received              received after the days ago
  --           : p_sort_by                    By Supplier/Site or By Item, the External report can use only by Supplier/Site
  --           : p_currency_conversion_type   the currency conversion type
  --           : p_currency_conversion_date   the currency conversion date
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  --             first the unallocated qty,then the allocated but unconsumed qty.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_rpt_confirmation_data
  (
    p_onhand_row_type            IN NUMBER
   ,p_rep_po_unalloc_row_type    IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_days_received              IN NUMBER
    --  , p_sort_by                        IN  VARCHAR2
   ,p_currency_conversion_type IN VARCHAR2
   ,p_currency_conversion_date IN DATE
  );

  --========================================================================
  -- PROCEDURE : get_unallocated_components    PUBLIC
  -- PARAMETERS: p_rep_po_unalloc_row_type    row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : x_need_to_find_pri_qty       the need to find quantity under primary UOM
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe unallocated rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unallocated_components
  (
    p_rep_po_unalloc_row_type  IN NUMBER
   ,p_rcv_transaction_row_type IN NUMBER
   ,p_ou_id                    IN NUMBER
   ,p_supplier_id              IN NUMBER
   ,p_supplier_site_id         IN NUMBER
   ,p_oem_inv_org_id           IN NUMBER
   ,p_tp_inv_org_id            IN NUMBER
   ,p_item_id                  IN NUMBER
   ,p_project_id               IN NUMBER
   ,p_task_id                  IN NUMBER
   ,x_need_to_find_pri_qty     IN OUT NOCOPY NUMBER
  );

  --========================================================================
  -- PROCEDURE : get_unallocated_rep_po    PUBLIC ,get_unallocated_replenishment_po
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_ou_id                      the operating unit id
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order that have unallocated receipts for the item
  --             and insert the result to mid temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unallocated_rep_po
  (
    p_rep_po_unalloc_row_type IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_supplier_id             IN NUMBER
   ,p_supplier_site_id        IN NUMBER
   ,p_oem_inv_org_id          IN NUMBER
   ,p_tp_inv_org_id           IN NUMBER
   ,p_item_id                 IN NUMBER
   ,p_project_id              IN NUMBER
   ,p_task_id                 IN NUMBER
  );

  --========================================================================
  -- FUNCTION  : get_rep_po_residual_unalloc    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order residual unallocated quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rep_po_residual_unalloc
  (
    p_rep_po_unalloc_row_type IN NUMBER
   ,p_ou_id                   IN NUMBER
   ,p_rcv_transaction_id      IN NUMBER
   ,p_supplier_id             IN NUMBER
   ,p_supplier_site_id        IN NUMBER
   ,p_oem_inv_org_id          IN NUMBER
   ,p_tp_inv_org_id           IN NUMBER
   ,p_item_id                 IN NUMBER
   ,p_project_id              IN NUMBER
   ,p_task_id                 IN NUMBER
  ) RETURN NUMBER;

  --========================================================================
  -- PROCEDURE : set_rep_po_residual_unalloc    PUBLIC ,set_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rep_po_unalloc_row_type       row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_rep_po_id                  row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order residual unallocated quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rep_po_residual_unalloc
  (
    p_rep_po_unalloc_row_type    IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,p_new_rep_po_unallocated_pri IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : set_rcv_transaction_unalloc    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_rcv_unallocated_pri        the rcv unallocated quantity for primary uom
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : update the replenishment po receive transaction unallocated information for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rcv_transaction_unalloc
  (
    p_rcv_row_type        IN NUMBER
   ,p_ou_id               IN NUMBER
   ,p_rcv_transaction_id  IN NUMBER
   ,p_rcv_unallocated_pri IN NUMBER
   ,p_supplier_id         IN NUMBER
   ,p_supplier_site_id    IN NUMBER
   ,p_oem_inv_org_id      IN NUMBER
   ,p_tp_inv_org_id       IN NUMBER
   ,p_item_id             IN NUMBER
   ,p_project_id          IN NUMBER
   ,p_task_id             IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : get_unconsumed_components    PUBLIC
  -- PARAMETERS: p_sub_po_unconsumed_row_type row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : x_need_to_find_pri_qty       the need to find quantity under primary UOM
  -- COMMENT   : for each line in the on hand data in the jmf_shikyu_cfr_mid_temp table,
  --             this procedure is used to get the possilbe allocated but unconsumed rcv_transaction data information
  --             for those onhand SHIKYU components based on LIFO received date.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_components
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,x_need_to_find_pri_qty       IN OUT NOCOPY NUMBER
  );

  --========================================================================
  -- PROCEDURE : get_unconsumed_sub_po    PUBLIC ,unconsumed_subcontracting_po
  -- PARAMETERS: p_sub_po_unconsumed_row_type row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the subcontracting purchase order that not fully received
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_sub_po
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER --need oem supplier id ????
   ,p_supplier_site_id           IN NUMBER --need oem supplier site id ????
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : get_unconsumed_rep_po    PUBLIC ,get_unconsumed_replenishment_po
  -- PARAMETERS: p_rep_po_unconsume_row_type       row type id to identify the
  --                                          unconsumed components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the replenishment purchase order that have unallocated receipts for the item
  --             and insert the result to mid temp table
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_unconsumed_rep_po
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rep_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  );

  --========================================================================
  -- FUNCTION  : get_sub_po_residual_unconsume    PUBLIC ,get_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_sub_po_unconsumed_row_type      row type id to identify the
  --                                          unallocated components information
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : find the subcontract order residual unconsumed quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_sub_po_residual_unconsume
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
  ) RETURN NUMBER;

  --========================================================================
  -- PROCEDURE : set_sub_po_residual_unconsume    PUBLIC ,set_replenishment_po_unallocated quantity for primary uom
  -- PARAMETERS: p_sub_po_unconsumed_row_type     row type id to identify the
  --                                          unconsumed components information
  --           : p_rcv_transaction_row_type   row type id to identify the rcv_transaction data
  --           : p_rep_po_id                  row type id to identify the rcv_transaction data
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  --           : p_new_consumed_pri           the new consumed primary quantity that need to update in the temp table
  -- COMMENT   : find the subcontract order residual unaconsumed quantity for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_sub_po_residual_unconsume
  (
    p_sub_po_unconsumed_row_type IN NUMBER
   ,p_rcv_transaction_row_type   IN NUMBER
   ,p_ou_id                      IN NUMBER
   ,p_rcv_transaction_id         IN NUMBER
   ,p_supplier_id                IN NUMBER
   ,p_supplier_site_id           IN NUMBER
   ,p_oem_inv_org_id             IN NUMBER
   ,p_tp_inv_org_id              IN NUMBER
   ,p_item_id                    IN NUMBER
   ,p_project_id                 IN NUMBER
   ,p_task_id                    IN NUMBER
   ,p_new_consumed_pri           IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : set_rcv_transaction_unconsume    PUBLIC ,get_replenishment_po_unconsumed quantity for primary uom
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --           : p_rcv_transaction_id         row type id to identify the rcv_transaction data
  --           : p_rcv_unallocated_pri        the rcv unallocated quantity for primary uom
  --           : p_supplier_id                the supplier id got from the onhand info from mid temp table
  --           : p_supplier_site_id           the supplier site id got from the onhand info from mid temp table
  --           : p_oem_inv_org_id             the oem_inv_org_id got from the onhand info from mid temp table
  --           : p_tp_inv_org_id              the tp_inv_org_id got from the onhand info from mid temp table
  --           : p_item_id                    the item_id got from the onhand info from mid temp table
  -- COMMENT   : update the replenishment po receive transaction unallocated information for primary uom
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE set_rcv_transaction_unconsume
  (
    p_rcv_row_type       IN NUMBER
   ,p_ou_id              IN NUMBER
   ,p_rcv_transaction_id IN NUMBER
   ,p_rcv_unconsumed_pri IN NUMBER
   ,p_supplier_id        IN NUMBER
   ,p_supplier_site_id   IN NUMBER
   ,p_oem_inv_org_id     IN NUMBER
   ,p_tp_inv_org_id      IN NUMBER
   ,p_item_id            IN NUMBER
   ,p_project_id         IN NUMBER
   ,p_task_id            IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : validate_cfr_mid_temp    PUBLIC ,validate the data in mid temp table, do UOM and Currency conversion
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : this include UOM and Currency conversion and data check
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE validate_cfr_mid_temp(p_rcv_row_type IN NUMBER);

  --========================================================================
  -- PROCEDURE : add_data_to_cfr_temp    PUBLIC ,process the mid_temp data and add to temp talbe for report builder
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : and data merge to temp talbe for report builder
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE add_data_to_cfr_temp
  (
    p_rcv_row_type              IN NUMBER
   ,p_rpt_mode                  IN VARCHAR2
   ,p_days_received             IN NUMBER
   ,p_currency_conversion_type  IN VARCHAR2
   ,p_currency_conversion_date  IN DATE
   ,p_functional_currency       IN VARCHAR2
   -- Amy added to fix bug 5583680 start
   ,p_supplier_name_from        IN VARCHAR2
   ,p_supplier_site_code_from   IN VARCHAR2
   ,p_supplier_name_to          IN VARCHAR2
   ,p_supplier_site_code_to     IN VARCHAR2
   ,p_oem_inv_org_name_from     IN VARCHAR2
   ,p_oem_inv_org_name_to       IN VARCHAR2
   -- Amy added to fix bug 5583680 end
  );

  --========================================================================
  -- PROCEDURE : rpt_get_crude_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the crude data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_CRUDE_DATA
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_crude_data(
   p_rpt_mode                  IN VARCHAR2
  ,p_currency_conversion_type  IN VARCHAR2
  ,p_currency_conversion_date  IN DATE
  ,p_functional_currency       IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : rpt_get_Comp_Estimated_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the Component Estimated data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_COMPONENT
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_Comp_Estimated_data(p_rpt_mode IN VARCHAR2);

  --========================================================================
  -- PROCEDURE : rpt_get_SubPO_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  --                         p_ou_id                          ou_id to identify period infor
  --                         p_days_received             user entered parameter to determine period
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_SUBCONTRACT_PO
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_SubPO_data(
            p_rpt_mode IN VARCHAR2
            ,p_ou_id IN NUMBER
            ,p_days_received IN NUMBER);

  --========================================================================
  -- PROCEDURE : rpt_get_UnReceived_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_SUBCONTRACT_PO
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_UnReceived_data
  (
   p_rpt_mode 				   IN VARCHAR2
  -- Amy added to fix bug 5583680 start
  ,p_supplier_name_from        IN VARCHAR2
  ,p_supplier_site_code_from   IN VARCHAR2
  ,p_supplier_name_to          IN VARCHAR2
  ,p_supplier_site_code_to     IN VARCHAR2
  ,p_oem_inv_org_name_from     IN VARCHAR2
  ,p_oem_inv_org_name_to       IN VARCHAR2
  -- Amy added to fix bug 5583680 end
  );

  --========================================================================
  -- PROCEDURE : rpt_get_Received_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_EXT_SUBCONTRACT_PO
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_Received_data(
   p_rpt_mode IN VARCHAR2
  ,p_days_received IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : rpt_get_Int_data    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the Component data into jmf_shikyu_cfr_rpt_temp with
  --             RPT_DATA_TYPE = CFR_INT_COMPONENT
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_Int_data(p_rpt_mode IN VARCHAR2);

  --========================================================================
  -- PROCEDURE : rpt_get_SubPO_data_Onhand    PUBLIC ,
  -- PARAMETERS: p_rcv_row_type               row type id to identify the rcv_transaction
  -- COMMENT   : get the SubPO info for the component data into jmf_shikyu_cfr_rpt_temp with
  --                      These subPOs can affect onhand quantity in MP inventory.
  --             RPT_DATA_TYPE = CFR_EXT_SUBCONTRACT_PO_AFT_ONHAND
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_get_SubPO_data_Onhand(p_rpt_mode IN VARCHAR2);

  --========================================================================
  -- PROCEDURE : rpt_debug_show_mid_data    PUBLIC ,
  -- PARAMETERS: p_row_type                 row type in jmf_shikyu_cfr_mid_temp
  --             p_output_to                the parameter for debug_output
  -- COMMENT   : show the data in temp table jmf_shikyu_cfr_mid_temp
  --             using debug_output
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_debug_show_mid_data
  (
    p_row_type  IN VARCHAR2
   ,p_output_to IN VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : rpt_debug_show_temp_data    PUBLIC ,
  -- PARAMETERS: p_rpt_data_type            row type in jmf_shikyu_cfr_rpt_temp
  --             p_output_to                the parameter for debug_output
  -- COMMENT   : show the data in temp table jmf_shikyu_cfr_rpt_temp
  --             using debug_output
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE rpt_debug_show_temp_data
  (
    p_rpt_data_type IN VARCHAR2
   ,p_output_to     IN VARCHAR2
  );

END JMF_SHIKYU_RPT_CFR_PVT;

 

/
