--------------------------------------------------------
--  DDL for Package WSH_WV_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WV_UTILS" AUTHID CURRENT_USER as
/* $Header: WSHWVUTS.pls 120.4 2007/01/05 19:26:03 parkhj noship $ */

--<TPA_PUBLIC_NAME=WSH_TPA_CONTAINER_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPCO>

-- OTM R12 : packing ECO
G_RESET_WV  VARCHAR2(1) := 'N';
-- End of OTM R12 : packing ECO

--
-- Procedure:	Convert_Uom
-- Parameters:	from_uom - Uom code to convert from
-- 		to_uom   - Uom code to convert to
--              quantity - quantity to convert
--              item_id  - inventory item id
-- Description: This procedure will convert quantity from one Uom to another by
--              calling an inventory convert uom procedure
--

-- HW OPMCONV - Added lot_number and org_id parameters
FUNCTION convert_uom(from_uom IN VARCHAR2,
		     to_uom IN VARCHAR2,
		     quantity IN NUMBER,
		     item_id IN NUMBER DEFAULT NULL,
		     p_max_decimal_digits IN NUMBER DEFAULT 5, -- RV DEC_QTY
		     lot_number VARCHAR2 DEFAULT NULL,
		     org_id IN NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION convert_uom_core(from_uom IN VARCHAR2,
		     to_uom IN VARCHAR2,
		     quantity IN NUMBER,
		     item_id IN NUMBER DEFAULT NULL,
		     p_max_decimal_digits IN NUMBER DEFAULT 5, -- RV DEC_QTY
		     lot_number VARCHAR2 DEFAULT NULL,
		     org_id IN NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER;


-- The following pragma is used to allow convert_uom to be used in a select statement
-- WNDS : Write No Database State (does not allow tables to be altered)

pragma restrict_references (convert_uom, WNDS);


--
-- Procedure:	Get_Default_Uoms
-- Parameters:	p_organization_id - Organization where shipping parameters are defined
--              x_weight_uom_code - Default weight uom code
--              x_volume_uom_code - Default volume uom code
--	        x_return_status   - status of procedure call
-- Description: This procedure will find the default weight and volume uom codes from
--              wsh_shipping_parameters table, for a particular organization
--

PROCEDURE get_default_uoms ( p_organization_id IN NUMBER,
		             x_weight_uom_code  OUT NOCOPY  VARCHAR2,
			     x_volume_uom_code  OUT NOCOPY  VARCHAR2,
			     x_return_status    OUT NOCOPY  VARCHAR2);


--
-- Procedure:	Detail_Weight_Volume
-- Parameters:	p_delivery_detail_id - Delivery detail id
-- 		p_update_flag   - if 'Y' then delivery weight/volume is updated
--              x_net_weight    - calculated net weight
--              x_volume        - calculated volume
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the net weight and volume
--              of a delivery detail by finding the inventory unit weight/volume and
--              multiplying it with the converted shipped quantity (or requested quantity)
--


PROCEDURE Detail_Weight_Volume (
  p_delivery_detail_id IN NUMBER,
  p_update_flag IN VARCHAR2,
  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
  x_net_weight OUT NOCOPY  NUMBER,
  x_volume OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


--
-- Procedure:	Add_Container_Wt_Vol
-- Parameters:	p_container_instance_id - Container id (delivery_detail_id of container)
--             p_detail_id - id of delivery_detail to be added to container
--             p_detail_type   - 'L' - line, 'C' - cont
--		     p_fill_pc_flag  - if 'Y' then fill percent is also calculated.
--             x_net_weight    - calculated net weight
--             x_gross_weight  - calculated gross weight
--             x_volume        - calculated volume
--		     x_cont_fill_pc - calculated container fill percent
--		     x_return_status - status of procedure call
-- Description: This procedure will add weight and volume of a delivery detail
--              (container or line) to the container it is being assigned to
--              Caution: the procedure will override existing weight/volume
--                       on the container.
--

PROCEDURE Add_Container_Wt_Vol (
  p_container_instance_id IN NUMBER,
  p_detail_id     IN NUMBER,
  p_detail_type   IN VARCHAR2,
  p_fill_pc_flag  IN VARCHAR2,
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

--
-- Procedure:	Update_Container_Wt_Vol
-- Parameters:	p_container_instance_id - Container instance Id for update
-- 		p_override_flag - if 'Y' then container weight/volume is updated
--              x_net_weight    - calculated net weight
--              x_gross_weight  - calculated gross weight
--              x_volume        - calculated volume
--		p_fill_pc_flag - if 'Y' then fill percent is also calculated.
--		x_cont_fill_pc - calculated container fill percent
--		x_return_status - status of procedure call
-- Description: This procedure will update container weight/volume with calculated values
--              If override flag is 'Y' then all three fields will be updated, else only
--              the null fields will be updated.
--


PROCEDURE Update_Container_Wt_Vol (p_container_instance_id IN NUMBER,
				   p_gross_weight IN NUMBER,
				   p_net_weight IN NUMBER,
				   p_volume IN NUMBER,
                                   p_filled_volume IN NUMBER,
				   p_fill_pc_flag IN VARCHAR2,
                                   p_unit_weight IN NUMBER DEFAULT -99,
                                   p_unit_volume IN NUMBER DEFAULT -99,
				   x_cont_fill_pc OUT NOCOPY  NUMBER,
				   x_return_status OUT NOCOPY  VARCHAR2);

--
-- Procedure:	Container_Weight_Volume
-- Parameters:	p_container_instance_id - Container instance Id
-- 		p_override_flag - if 'Y' then all container (this container instance and
--                               all its child containers) weights/volume is updated
--              p_calc_wv_if_frozen - if 'Y' manually entered W/V will be overwritten
--                                  with calculated W/V
--              x_net_weight    - calculated net weight
--              x_gross_weight  - calculated gross weight
--              x_volume        - calculated volume
--		p_fill_pc_flag  - if 'Y' then fill percent is also calculated.
--		x_cont_fill_pc - calculated container fill percent
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the net and gross weight and volume
--              of a container and its child containers by summing up all child containers
--              and loose item weights/volumes.
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.containerTP
--


PROCEDURE Container_Weight_Volume (
  p_container_instance_id IN NUMBER,
  p_override_flag IN VARCHAR2,
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  p_fill_pc_flag  IN VARCHAR2,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
 p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y');

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.CONTAINERTP>

-- Start of comments
-- API name : Detail_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Multiple Delivery Details
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery Detail
--            Otherwise, the API returns the calculated W/V
--            If p_calc_wv_if_frozen is 'N' then W/V will be calculated not be calculated
--            for entities whose W/V is manually entered
-- Parameters :
-- IN:
--    p_detail_rows        IN wsh_util_core.id_tab_type REQUIRED
--    p_update_flag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       gives the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Detail_Weight_Volume (
  p_detail_rows   IN wsh_util_core.id_tab_type,
  p_override_flag IN VARCHAR2,
  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
  x_return_status OUT NOCOPY  VARCHAR2);


--
-- Procedure:	Calc_Cont_Fill_Pc
-- Parameters:	p_container_instance_id - Container Instance Id
-- 		p_update_flag - if 'Y' then fill percent and wt/vol is updated
--              p_fill_pc_basis - fill percent basis flag that determines if
--				fill percent is calculated by wt, vol or qty
--              x_fill_percent  - calculated fill percent of container
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the fill percent of the
--              container based on the fill percent basis flag. If the
--		container weight and volume has not been calculated it will
--		calculate the weight and volume before calculating the fill
--		percent. It will update the container instances table if
--		update flag is set to 'Y'
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.containerTP
--

PROCEDURE Calc_Cont_Fill_Pc (
 p_container_instance_id IN NUMBER,
 p_update_flag IN VARCHAR2,
 p_fill_pc_basis IN VARCHAR2,
 x_fill_percent OUT NOCOPY  NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) ;

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.CONTAINERTP>

--
-- Procedure:	Container_Tare_Weight_Self
-- Parameters:	p_container_instance_id - Container Instance id
-- 		p_cont_item_id - inventory item id of container
--              p_wt_uom    - weight uom code of tare weight
--              p_organization_id  - organization id
--              x_cont_tare_wt - calculated weight of only specified container
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the unit weight of the just the
--		container that is specified. Does not include tares of any
--		child containers.
--


PROCEDURE Container_Tare_Weight_Self (
 p_container_instance_id IN NUMBER,
 p_cont_item_id IN NUMBER,
 p_wt_uom IN VARCHAR2,
 p_organization_id IN NUMBER,
 x_cont_tare_wt OUT NOCOPY  NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.CONTAINERTP>

--
-- Procedure:	Check Fill PC
-- Parameters:	p_container_instance_id - container instance id of container
--              p_calculation_flag - w/v calculation flag, 'Y' for Automatic and 'N' for Manual
--		x_fill_status - fill status of container - 'Overpacked',
--		'Underpacked',or 'Success' (returns 'O','U' or 'S')
--		x_return_status - status of procedure call
-- Description: This procedure will check the fill status of container by
--		comparing the fill pc with min fill pc. If fill pc < min fill
--		pc then it is underpacked. If fill pc > 100 then overpacked
--		else 'Success'.
--

PROCEDURE Check_Fill_Pc (
		p_container_instance_id IN NUMBER,
	        p_calc_wt_vol_flag IN VARCHAR2 DEFAULT 'Y', -- bug 2790656
		x_fill_status OUT NOCOPY  VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2);


--
-- Procedure:	Delivery_Weight_Volume
-- Parameters:	p_delivery_id - Delivery_id of delivery
-- 		p_update_flag - if 'Y' then delivery weight/volume is updated
--              p_calc_wv_if_frozen - if 'N' then manually entered W/V will not be
--                       overwritten with calculated W/V
--              x_net_weight    - calculated net weight
--              x_gross_weight  - calculated gross weight
--              x_volume        - calculated volume
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the net and gross weight and volume
--              of a delivery by summing up all container and
--              loose item weights/volumes
--

PROCEDURE Delivery_Weight_Volume
		( p_delivery_id    IN NUMBER,
		  p_update_flag    IN VARCHAR2,
                  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
		  x_gross_weight   OUT NOCOPY  NUMBER,
		  x_net_weight     OUT NOCOPY  NUMBER,
		  x_volume         OUT NOCOPY  NUMBER,
		  x_return_status  OUT NOCOPY  VARCHAR2);

--
-- Procedure:	Delivery_Weight_Volume
-- Parameters:	p_del_rows - Delivery ids
-- 		p_update_flag - if 'Y' then delivery weight/volume is updated
--              p_calc_wv_if_frozen - if 'N' then manually entered W/V will not be
--                       overwritten with calculated W/V
--		x_return_status - status of procedure call
-- Description: This procedure will calculate the net and gross weight and volume
--              of deliveries by calling the single delivery_weight_volume procedure
--

PROCEDURE Delivery_Weight_Volume
		( p_del_rows       IN wsh_util_core.id_tab_type,
		  p_update_flag    IN VARCHAR2,
                  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
		  x_return_status  OUT NOCOPY  VARCHAR2);

-- Start of comments
-- API name : DD_WV_Post_Process
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to do post processing(Log exceptions in manual mode and
--            adjust W/V on parents in automatic mode)  for a delivery detail or container
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_diff_gross_wt      IN NUMBER
--      Gross Wt that needs to be adjusted on parent entities
--    p_diff_net_wt        IN NUMBER
--      Net Wt that needs to be adjusted on parent entities
--    p_diff_volume        IN NUMBER
--      Volume that needs to be adjusted on parent entities
--    p_diff_fill_volume   IN NUMBER
--      Filled Volume that needs to be adjusted on parent entities
--    p_check_for_empty    IN VARCHAR2
--      Check if the parent of p_delivery_detail_id becomes empty
--      without p_delivery_detail_id
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE DD_WV_Post_Process(
            p_delivery_detail_id    IN NUMBER,
            p_diff_gross_wt         IN NUMBER,
            p_diff_net_wt           IN NUMBER,
            p_diff_volume           IN NUMBER DEFAULT null,
            p_diff_fill_volume      IN NUMBER DEFAULT null,
            p_check_for_empty       IN VARCHAR2 DEFAULT 'N',
            x_return_status         OUT NOCOPY VARCHAR2);

-- Start of comments
-- API name : Del_WV_Post_Process
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to do post processing(Log exceptions in manual mode and
--            adjust W/V on parents in automatic mode)  for a delivery
-- Parameters :
-- IN:
--    p_delivery_id IN NUMBER Required
--    p_diff_gross_wt      IN NUMBER
--      Gross Wt that needs to be adjusted on parent entities
--    p_diff_net_wt        IN NUMBER
--      Net Wt that needs to be adjusted on parent entities
--    p_diff_volume        IN NUMBER
--      Volume that needs to be adjusted on parent entities
--    p_check_for_empty    IN VARCHAR2
--      Check if the parent of p_delivery_id becomes empty
--      without p_delivery_id
--    p_leg_id IN VARCHAR2
--      Do Post Processing only for the specified delivery/delivery leg
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0

PROCEDURE Del_WV_Post_Process(
            p_delivery_id     IN NUMBER,
            p_diff_gross_wt   IN NUMBER,
            p_diff_net_wt     IN NUMBER,
            p_diff_volume     IN NUMBER,
            p_check_for_empty IN VARCHAR2 DEFAULT 'N',
            p_leg_id          IN NUMBER DEFAULT NULL,
            x_return_status   OUT NOCOPY VARCHAR2);

-- Start of comments
-- API name : Detail_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Delivery Detail
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery Detail
--            Otherwise, the API returns the calculated W/V
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_update_flag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_post_process_flag  IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'N' if W/V should not be calculated if W/V is frozen
-- OUT:
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery detail
--    x_volume OUT NUMBER
--       gives the volume of delivery detail
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Detail_Weight_Volume (
  p_delivery_detail_id  IN NUMBER,
  p_update_flag         IN VARCHAR2,
  p_post_process_flag   IN VARCHAR2,
  p_calc_wv_if_frozen   IN VARCHAR2 DEFAULT 'Y',
  x_net_weight          OUT NOCOPY  NUMBER,
  x_volume              OUT NOCOPY  NUMBER,
  x_return_status       OUT NOCOPY  VARCHAR2);

-- Start of comments
-- API name : Container_Weight_Volume
-- Type     : Private
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Container
--            If p_override_flag is 'Y' then the calculated W/V is updated on Container
--            Otherwise, the API returns the calculated W/V
--            If p_post_process_flag is 'Y' then calls post processing API
-- Parameters :
-- IN:
--    p_container_instance_id IN NUMBER Required
--    p_override_flag         IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_fill_pc_flag          IN  VARCHAR2
--      'Y' if fill% needs to be calculated
--    p_post_process_flag     IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen     IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of container
--    x_net_weight OUT NUMBER
--       gives the net weight of container
--    x_volume OUT NUMBER
--       gives the volume of container
--    x_cont_fill_pc  OUT NUMBER
--       gives the Fill% of container
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Container_Weight_Volume (
  p_container_instance_id IN NUMBER,
  p_override_flag IN VARCHAR2,
  p_fill_pc_flag  IN VARCHAR2,
  p_post_process_flag IN VARCHAR2,
  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE Adjust_parent_WV (
  p_entity_type             IN VARCHAR2,
  p_entity_id               IN NUMBER,
  p_gross_weight            IN NUMBER,
  p_net_weight              IN NUMBER,
  p_volume                  IN NUMBER DEFAULT null,
  p_filled_volume           IN NUMBER DEFAULT null,
  p_wt_uom_code             IN VARCHAR2,
  p_vol_uom_code            IN VARCHAR2,
  p_inv_item_id             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_stop_type               IN VARCHAR2 DEFAULT NULL);

-- HW OPMCONV - new routine to check deviation
-- Function:	within_deviation
-- Parameters:	p_organization_id     - organization id
-- 		p_inventory_item_id   - Inventory Item id
--              p_lot_number          - Lot number
--              p_precision           - Precision - default 5
--              p_quantity            - Primary Qty
--              p_uom1                - Uom code to convert from
--              p_quantity2           - Secondary Qty
--              p_uom2                - Uom code to convert to
-- Description: This function calls new INV routine INV_CONVERT.within_deviation
--              to check if Qtys are within deviation for item types 'D' and 'N'
--
FUNCTION within_deviation (
      p_organization_id         IN   NUMBER,
      p_inventory_item_id       IN   NUMBER,
      p_lot_number              IN   VARCHAR2,
      p_precision               IN   NUMBER default 5,
      p_quantity                IN   NUMBER,
      p_uom1                    IN   VARCHAR2,
      p_quantity2               IN   NUMBER,
      p_uom2                    IN   VARCHAR2) RETURN NUMBER;

-- Bug#4254552:"Proration of weight from Delivery to delivery lines" Project.
-- Procedure name : Prorate_weight
-- Pre-reqs : Prorate_wt_flag should be 'Y' for the delivery.
-- Description : Prorates weight of the given delivery/container to its immediate children
--
-- Parameters :
--    p_entity_type	- 'DELIVERY' or 'CONTAINER'
--    p_entity_id	- Delivery_id or Container_id
--    p_old_gross_wt	- Original Gross Weight of the entity
--    p_new_gross_wt	- New Gross Weight of the entity
--    p_old_net_wt	- Original Net Weight of the entity
--    p_net_net_wt	- New Net Weight of the entity
--    p_weight_uom_code - Weight UOM of the entity

PROCEDURE Prorate_weight(
	    p_entity_type        IN VARCHAR2,
            p_entity_id          IN NUMBER,
            p_old_gross_wt       IN   NUMBER,
	    p_new_gross_wt       IN NUMBER,
            p_old_net_wt         IN   NUMBER,
	    p_new_net_wt         IN NUMBER,
            p_weight_uom_code    IN VARCHAR2,
	    x_return_status      OUT NOCOPY VARCHAR2,
            p_call_level         IN NUMBER DEFAULT NULL);

END WSH_WV_UTILS;


/
