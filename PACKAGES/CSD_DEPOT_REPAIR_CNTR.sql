--------------------------------------------------------
--  DDL for Package CSD_DEPOT_REPAIR_CNTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_DEPOT_REPAIR_CNTR" AUTHID CURRENT_USER as
/* $Header: csddrcls.pls 115.17 2003/05/01 01:07:46 sangigup ship $ */

procedure convert_to_primary_uom
          (p_item_id  in number,
           p_organization_id in number,
           p_from_uom in varchar2,
           p_from_quantity in number,
           p_result_quantity OUT NOCOPY number);

procedure  depot_rma_receipts
           (errbuf              OUT NOCOPY    varchar2,
            retcode             OUT NOCOPY    number,
          p_repair_line_id    in     number);

procedure  depot_wip_update
           (errbuf             OUT NOCOPY    varchar2,
            retcode            OUT NOCOPY    varchar2,
          p_repair_line_id   in     number);

procedure  depot_update_task_hist
           (errbuf             OUT NOCOPY    varchar2,
            retcode            OUT NOCOPY    number,
          p_repair_line_id   in     number);


procedure get_wip_job_completed_quantity(p_wip_entity_id in number,
                                         x_wip_completed_qty OUT NOCOPY number,
                                        x_COMPLETION_SUBINVENTORY OUT NOCOPY varchar2,
                                         x_DATE_COMPLETED OUT NOCOPY date,
                                      x_ORGANIZATION_ID OUT NOCOPY number,
                                       x_routing_reference_id OUT NOCOPY number,
                                       x_LAST_UPDATED_BY OUT NOCOPY number);


procedure  depot_shipment_update
             (errbuf             OUT NOCOPY    varchar2,
              retcode            OUT NOCOPY    varchar2,
            p_repair_line_id   in     number);

procedure get_txn_billing_type
           (p_line_id             in  number,
            p_header_id           in  number,
            x_repair_number       OUT NOCOPY varchar2,
            x_repair_line_id      OUT NOCOPY number,
            x_txn_billing_type_id OUT NOCOPY number,
            x_quantity            OUT NOCOPY number);

End CSD_DEPOT_REPAIR_CNTR;

 

/
