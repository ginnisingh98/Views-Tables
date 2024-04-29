--------------------------------------------------------
--  DDL for Package INV_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVUPMSS.pls 120.5 2008/04/15 13:36:10 abaid ship $ */
--BEGIN SCHANDRU INVERES
function  get_from_status_code (  p_org_id in number default null,
                                  p_item_id in number default null,
                                  p_sub_inv in varchar2 default null,
                                  p_locator_id in number default null,
                                  p_lot in varchar2 default null,
                                  p_serial in varchar2 default null ) return varchar2 ;

--END SCHANDRU INVERES


PROCEDURE check_lot_range_status(
  				p_org_id                IN NUMBER,
			  	p_item_id               IN NUMBER,
                                p_from_lot 		IN VARCHAR2,
				p_to_lot		IN VARCHAR2,
                                x_Status                OUT nocopy VARCHAR2,
				x_Message               OUT nocopy VARCHAR2,
                                x_Status_Code           OUT nocopy VARCHAR2
                                );

PROCEDURE check_serial_range_status(
                                p_org_id                IN NUMBER,
                                p_item_id               IN NUMBER,
                                p_from_serial           IN VARCHAR2,
                                p_to_serial             IN VARCHAR2,
                                x_Status                OUT nocopy VARCHAR2,
                                x_Message               OUT nocopy VARCHAR2,
                                x_Status_Code           OUT nocopy VARCHAR2
                                );
PROCEDURE update_status(
     p_update_method              IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER
   , p_sub_code                   IN VARCHAR2
   , p_sub_status_id              IN NUMBER
   , p_sub_reason_id              IN NUMBER
   , p_locator_id                 IN NUMBER
   , p_loc_status_id	          IN NUMBER
   , p_loc_reason_id              IN NUMBER
   , p_from_lot_number            IN VARCHAR2
   , p_to_lot_number              IN VARCHAR2
   , p_lot_status_id 		  IN NUMBER
   , p_lot_reason_id 		  IN NUMBER
   , p_from_SN	                  IN VARCHAR2
   , p_to_SN    	          IN VARCHAR2
   , p_serial_status_id           IN NUMBER
   , p_serial_reason_id  	  IN NUMBER
   , x_Status                	  OUT nocopy VARCHAR2
   , x_Message                    OUT nocopy VARCHAR2
   , p_update_from_mobile	  IN VARCHAR2 DEFAULT 'Y'
  -- NSRIVAST, INVCONV , Start
   , p_grade_code                 IN VARCHAR2  DEFAULT NULL
   , p_primary_onhand             IN NUMBER    DEFAULT NULL
   , p_secondary_onhand           IN NUMBER    DEFAULT NULL
  -- NSRIVAST, INVCONV , End
   , p_onhand_status_id           IN NUMBER    DEFAULT NULL -- Added for # 6633612
   , p_onhand_reason_id           IN NUMBER    DEFAULT NULL -- Added for # 6633612
   , p_lpn_id                     IN NUMBER    DEFAULT NULL -- Added for # 6633612

   );

PROCEDURE invoke_reason_wf(
     p_update_method              IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER
   , p_sub_code                   IN VARCHAR2
   , p_sub_status_id              IN NUMBER
   , p_sub_reason_id              IN NUMBER
   , p_locator_id                 IN NUMBER
   , p_loc_status_id              IN NUMBER
   , p_loc_reason_id              IN NUMBER
   , p_from_lot_number            IN VARCHAR2
   , p_to_lot_number              IN VARCHAR2
   , p_lot_status_id              IN NUMBER
   , p_lot_reason_id              IN NUMBER
   , p_from_SN                    IN VARCHAR2
   , p_to_SN                      IN VARCHAR2
   , p_serial_status_id           IN NUMBER
   , p_serial_reason_id           IN NUMBER
   , p_onhand_status_id           IN NUMBER    DEFAULT NULL  -- Added for # 6633612
   , p_onhand_reason_id           IN NUMBER    DEFAULT NULL  -- Added for # 6633612
   , p_lpn_id                     IN NUMBER    DEFAULT NULL  -- Added for # 6633612
   , x_Status                     OUT nocopy VARCHAR2
   , x_Message                    OUT nocopy VARCHAR2);
   --Bug#5577767 Created this procedure to filter sec qty/uom based on tracking_quantity_ind.
PROCEDURE tracking_quantity_ind(p_item_id IN NUMBER,
                                p_org_id  IN NUMBER,
                                x_sec_qty IN OUT nocopy NUMBER,
                                x_sec_uom IN OUT nocopy VARCHAR2);
 --added for lpn status project to check if update transaction will result in mixed or not
 FUNCTION get_mixed_status(p_lpn_id NUMBER,
                           p_organization_id NUMBER,
                           p_outermost_lpn_id NUMBER,
                           p_inventory_item_id NUMBER,
                           p_lot_number VARCHAR2 := NULL,
                           p_status_id NUMBER)
                           RETURN VARCHAR2;
 --added for lpn status project to check if update transaction will result in mixed or not
FUNCTION get_mixed_status_serial(p_lpn_id NUMBER,
                          p_organization_id NUMBER,
                          p_outermost_lpn_id NUMBER,
                          p_inventory_item_id NUMBER,
                          p_lot_number VARCHAR2 := NULL,
                          p_fm_sn VARCHAR2,
                          p_to_sn VARCHAR2,
                          p_status_id NUMBER)
                           RETURN VARCHAR2;

END INV_STATUS_PKG;

/
