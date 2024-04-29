--------------------------------------------------------
--  DDL for Package OPIMPXIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPIMPXIN" AUTHID CURRENT_USER AS
/*$Header: OPIMXINS.pls 120.1 2005/06/08 18:29:57 appldev  $ */

   Procedure calc_wip_completion(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);


   Procedure calc_wip_issue(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_assembly_return(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_po_deliveries(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_value_to_orgs(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_value_from_orgs(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_customer_shipment(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_inv_adjustment(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_total_issue(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure calc_total_receipt(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number);

   Procedure Insert_update_push_log(
            p_trx_date IN Date,
            p_organization_id IN Number,
            p_item_id         IN Number default NULL,
            p_cost_group_id   IN Number default NULL,
            p_revision        IN Varchar2 default NULL,
            p_lot_number      IN Varchar2 default NULL,
            p_subinventory    IN Varchar2 default NULL,
            p_locator         IN Number default NULL,
            p_item_status     IN Varchar2 default NULL,
            p_item_type       IN Varchar2 default NULL,
            p_base_uom        IN Varchar2 default NULL,
            p_col_name1       IN Varchar2 default NULL,
            p_total1          IN Number default NULL,
            p_col_name2       IN Varchar2 default NULL,
            p_total2          IN Number default NULL,
            p_col_name3       IN Varchar2 default NULL,
            p_total3          IN Number default NULL,
            p_col_name4       IN Varchar2 default NULL,
            p_total4          IN Number default NULL,
            p_col_name5       IN Varchar2 default NULL,
            p_total5          IN Number default NULL,
            p_col_name6       IN Varchar2 default NULL,
            p_total6          IN Number default NULL,
            selector          IN Number default NULL,
            success           OUT nocopy Number);

   Procedure Initialize(
            p_trx_date        OUT nocopy Date,
            p_organization_id OUT nocopy Number,
            p_item_id         OUT nocopy Number,
            p_cost_group_id   OUT nocopy Number,
            p_revision        OUT nocopy Varchar2,
            p_lot_number      OUT nocopy Varchar2,
            p_subinventory    OUT nocopy Varchar2,
            p_locator         OUT nocopy Number,
            total_qty         OUT nocopy Number,
            total_value       OUT nocopy Number);

End OPIMPXIN;

 

/
