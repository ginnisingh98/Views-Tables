--------------------------------------------------------
--  DDL for Package INV_KANBAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBAN_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVKBAPS.pls 115.15 2004/02/09 05:36:07 kkoothan ship $ */

  --This package is created to finish the kanban mobile transactions
  -- including replenishment and inquiry


  TYPE t_genref IS REF CURSOR;

  FUNCTION status_check(from_status_id IN NUMBER, to_status IN NUMBER)
    RETURN NUMBER;

  PROCEDURE replenishcard
    (x_message OUT NOCOPY VARCHAR2,
     x_status OUT NOCOPY VARCHAR2,
     p_org_id IN NUMBER,
     p_kanban_card_number IN VARCHAR2,
     p_lot_item_id        IN NUMBER  ,
     p_lot_number         IN VARCHAR2 ,
     p_lot_item_revision   IN VARCHAR2 ,
     p_lot_subinventory_code   IN VARCHAR2,
     p_lot_location_id         IN NUMBER ,
     p_lot_quantity            IN NUMBER,
     p_replenish_quantity      IN NUMBER  );

  FUNCTION getlocatorname(org_id IN NUMBER, locator_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION getorgcode(p_org_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION getsuppliersitename(supplier_site_id IN NUMBER)
    RETURN VARCHAR2;

  FUNCTION getdocmentnumber(v_document_header_id IN NUMBER, v_document_type_id IN NUMBER, v_document_detail_id IN NUMBER)
    RETURN VARCHAR2;

  PROCEDURE getreplenishinfo(
    p_org_id             IN     NUMBER
  , p_kanban_card_number IN     VARCHAR2
  , x_item               OUT    NOCOPY VARCHAR2
  , x_item_description   OUT    NOCOPY VARCHAR2
  , x_quantity           OUT    NOCOPY NUMBER
  , x_zone               OUT    NOCOPY VARCHAR2
  , x_project            OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_task                OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_locator             OUT    NOCOPY VARCHAR2
  , x_supply_status      OUT    NOCOPY VARCHAR2
  , x_source_type_id     OUT    NOCOPY NUMBER
  , x_source_type        OUT    NOCOPY VARCHAR2
  , x_source_org_id      OUT    NOCOPY NUMBER
  , --PJM-WMS Integration
   x_source_org          OUT    NOCOPY VARCHAR2
  , x_source_zone        OUT    NOCOPY VARCHAR2
  , x_source_project     OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_source_task         OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_source_locator      OUT    NOCOPY VARCHAR2
  , x_wip_line           OUT    NOCOPY VARCHAR2
  , x_supplier_name      OUT    NOCOPY VARCHAR2
  , x_supplier_site      OUT    NOCOPY VARCHAR2
  , x_item_id		 OUT    NOCOPY NUMBER
  , x_eligible_for_lbj   OUT    NOCOPY VARCHAR2
  , x_bom_seq_id         OUT    NOCOPY NUMBER
  , x_start_seq_num      OUT    NOCOPY NUMBER
  , x_message            OUT    NOCOPY VARCHAR2
  , x_status             OUT    NOCOPY VARCHAR2
  );

  PROCEDURE getsourcetypelov(x_kanban_ref OUT NOCOPY t_genref, p_source_type IN VARCHAR2);

  PROCEDURE getsupplierlov(x_kanban_ref OUT NOCOPY t_genref, p_supplier_name IN VARCHAR2);

  PROCEDURE getsuppliersitelov(x_kanban_ref OUT NOCOPY t_genref, p_supplier_site IN VARCHAR2, p_vendor_id IN NUMBER);

  PROCEDURE getwiplinelov(x_kanban_ref OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_wip_line IN VARCHAR2);

  PROCEDURE getinquiryinfo(
    x_kanban_ref             OUT    NOCOPY t_genref
  , p_org_id                 IN     NUMBER
  , p_kanban_card_number     IN     VARCHAR2
  , p_item_id                IN     NUMBER
  , p_source_type_id         IN     NUMBER
  , p_supplier               IN     VARCHAR2
  , p_supplier_site          IN     VARCHAR2
  , p_source_organization_id IN     NUMBER
  , p_source_sub             IN     VARCHAR2
  , p_source_loc             IN     NUMBER
  , p_wip_line_id            IN     NUMBER
  , p_project_id             IN     NUMBER DEFAULT NULL
  , p_task_id                IN     NUMBER DEFAULT NULL
  );

  /* VMI changes - Called from VendorSiteLOV though not used anymore*/
  PROCEDURE get_vmi_vendor_site_lov(x_ref OUT NOCOPY t_genref, p_vendor_site_code IN VARCHAR2, p_vendor_id IN NUMBER);

  /* Consignment Changes */
  PROCEDURE get_vendor_lov(x_ref OUT NOCOPY t_genref, p_vendor VARCHAR2,p_vendor_site_id VARCHAR2 DEFAULT NULL);
                                                                        --bug 2880891

  PROCEDURE get_starting_lot_lov
    (x_lot_num_lov OUT NOCOPY t_genref,
     p_organization_id IN NUMBER,
     p_assembly_item_id IN NUMBER,
     p_bom_sequence_id IN NUMBER,
     p_start_sequence_num IN VARCHAR2);

  /** This procedure returns the details of the kanban card passed like
   *  Card Type, Card Status, Supply Status etc.,
   *  @param   x_return_status           Return Status
   *  @param   x_msg_count               Message Count
   *  @param   x_msg_data                Message Data
   *  @param   x_card_type               Kanban Card Type
   *  @param   x_card_status             Kanban Card Status
   *  @param   x_supply_status           Kanban Card Supply status
   *  @param   x_status_check            Kanban Card Supply status Check
   *  @param   x_supply_status_meaning   Kanban Card Supply status meaning
   *  @param   p_organization_id         Organization Id
   *  @param   p_kanban_number           Kanban Card Number
   *
   **/
  PROCEDURE get_kanban_details(x_return_status OUT NOCOPY VARCHAR2
                             , x_msg_count OUT NOCOPY NUMBER
                             , x_msg_data OUT NOCOPY VARCHAR2
                             , x_card_type OUT NOCOPY NUMBER
                             , x_card_status OUT NOCOPY NUMBER
                             , x_supply_status OUT NOCOPY NUMBER
                             , x_status_check OUT NOCOPY NUMBER
                             , x_supply_status_meaning OUT NOCOPY VARCHAR2
                             , p_organization_id IN NUMBER
                             , p_kanban_number IN VARCHAR2);

  /** This procedure returns the details of the kanban move order
   *  like Mo Line Id, MO Reference Type, MO Line Status etc., for the Kanban Card passed.
   *  @param   x_return_status           Return Status
   *  @param   x_msg_count               Message Count
   *  @param   x_msg_data                Message Data
   *  @param   x_mo_line_id              Kanban Move Order Line Id
   *  @param   x_ref_type_code           Move Order Reference Type
   *  @param   x_mo_line_status_code     Kanban Move Order Line Status
   *  @param   x_mo_line_qty_diff        (Kanban Move Order Line quantity delivered - Total Kanban Move Order Line quantity)
   *  @param   p_organization_id         Organization Id
   *  @param   p_kanban_number           Kanban Card Number
   *
   **/
  PROCEDURE get_kanban_mo_details(x_return_status OUT NOCOPY VARCHAR2
                                , x_msg_count OUT NOCOPY NUMBER
                                , x_msg_data OUT NOCOPY VARCHAR2
                                , x_mo_line_id OUT NOCOPY NUMBER
                                , x_ref_type_code OUT NOCOPY NUMBER
                                , x_mo_line_status_code OUT NOCOPY NUMBER
                                , x_mo_line_qty_diff OUT NOCOPY NUMBER
                                , p_organization_id IN NUMBER
                                , p_kanban_number IN VARCHAR2);

END inv_kanban_pkg;


 

/
