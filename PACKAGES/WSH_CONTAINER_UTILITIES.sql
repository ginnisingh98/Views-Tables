--------------------------------------------------------
--  DDL for Package WSH_CONTAINER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONTAINER_UTILITIES" AUTHID CURRENT_USER as
/* $Header: WSHCMUTS.pls 120.0 2005/05/26 18:05:51 appldev noship $ */

--<TPA_PUBLIC_NAME=WSH_TPA_CONTAINER_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPCO>

-- bug 2381184
-- Record Structures
-- This is used with estimate detail container api
-- with new signature
    TYPE inrectype
    IS
    RECORD
      (
        container_instance_id NUMBER,
        delivery_detail_id NUMBER,
        organization_id NUMBER
      );
    --
    TYPE outrectype
    IS
    RECORD
      (
        num_cont NUMBER,
        max_qty_per_lpn NUMBER,
        fill_pc_per_lpn NUMBER,
        fill_pc_flag VARCHAR2(1),
        indivisible_flag VARCHAR2(1)
      );
    --
    TYPE inoutrectype
    IS
    RECORD
      (
        container_item_id NUMBER
      );
    --
    -- end bug 2381184
/*
-----------------------------------------------------------------------------
   FUNCTION   : Get Master Cont Id
   PARAMETERS : p_container_instance_id - instance id for the container
   RETURNS    : master container instance id
  DESCRIPTION : This function derives the master container instance id
		of the container by using a heirarchical SQL query on
		wsh_delivery_assignments_v table. This function can be used in
		SELECT statements that need to use the master container id.
------------------------------------------------------------------------------
*/

FUNCTION Get_Master_Cont_Id (p_cont_instance_id IN NUMBER) RETURN NUMBER;

-- The following pragma is used to allow Get_Master_Cont_id to be used
-- in a select statement
-- WNDS : Write No Database State (does not allow tables to be altered)

pragma restrict_references (Get_Master_Cont_Id, WNDS);


/*
-----------------------------------------------------------------------------
   FUNCTION   : Get Cont Name
   PARAMETERS : p_cont_instance_id - instance id for the container
   RETURNS    : container name for the container instance id
  DESCRIPTION : This function derives the container name for the container id

------------------------------------------------------------------------------
*/


FUNCTION Get_Cont_Name (p_cont_instance_id IN NUMBER) RETURN VARCHAR2;

-- The following pragma is used to allow Get_Cont_Name to be used
-- in a select statement
-- WNDS : Write No Database State (does not allow tables to be altered)

pragma restrict_references (Get_Cont_Name, WNDS);

-- Bug 2381184
-- Note There are 2 API with estimate_detail_containers name
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Detail Containers
   PARAMETERS : p_container_instance_id - instance id for the container
                x_container_item_id - container item for estimation
                p_delivery_detail_id - the delivery detail id for which the
                        number of containers is being estimated
                p_organization_id - organization_id
                x_num_cont - number of containers required to pack the line.
                x_return_status - return status of API
  DESCRIPTION : This procedure estimates the number of detail containers that
                would be required to pack a delivery detail.  The container
                item could be specified or if it is not specified, it is
                derived from the delivery detail or through the container load
                relationship. Using the inventory item and quantity on the
                detail and the container item, the number of containers is
                calculated/estimated.
------------------------------------------------------------------------------
*/
PROCEDURE Estimate_Detail_Containers(
   p_in_record IN inrectype,
   x_inout_record IN OUT NOCOPY  inoutrectype,
   x_out_record OUT NOCOPY  outrectype,
   x_return_status OUT NOCOPY  VARCHAR2
  );

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Detail Containers
   PARAMETERS : p_container_instance_id - instance id for the container
		x_container_item_id - container item for estimation
		p_delivery_detail_id - the delivery detail id for which the
			number of containers is being estimated
		p_organization_id - organization_id
		x_num_cont - number of containers required to pack the line.
		x_return_status - return status of API
  DESCRIPTION : This procedure estimates the number of detail containers that
		would be required to pack a delivery detail.  The container
		item could be specified or if it is not specified, it is
		derived from the delivery detail or through the container load
		relationship. Using the inventory item and quantity on the
		detail and the container item, the number of containers is
		calculated/estimated.
  FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.containerTP
------------------------------------------------------------------------------
*/


PROCEDURE Estimate_Detail_Containers(
   p_container_instance_id IN NUMBER DEFAULT NULL,
   x_container_item_id IN OUT NOCOPY  NUMBER,
   p_delivery_detail_id IN NUMBER,
   p_organization_id IN NUMBER,
   x_num_cont IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2);

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DeliveryDetailTP>

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Master Containers
   PARAMETERS : p_container_instance_id - instance id of the detail container
		x_mast_cont_item_id - master container item id
		p_det_cont_item_id - detail container item id
		p_organization_id - organization_id
		x_num_cont - number of master containers required to pack
			     the detail containers.
		x_return_status - return status of API
  DESCRIPTION : This procedure estimates the number of master containers that
		would be required to pack a number of detail containers.  The
		master container item could be specified or if it is not
		specified, it is derived from the container load relationship.
		Using the detail container item id and the derived master
		container item id the number of master containers is
		calculated/estimated.
  FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.containerTP
------------------------------------------------------------------------------
*/


PROCEDURE  Estimate_Master_Containers(
   p_container_instance_id IN NUMBER,
   x_mast_cont_item_id IN OUT NOCOPY  NUMBER,
   p_det_cont_item_id IN NUMBER,
   p_organization_id IN NUMBER,
   x_num_cont IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2);

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.ContainerTP>

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Master Cont Serial
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_container_id - the master container of the container
			derived using the container hierarchy.
		x_master_container_name - container name for the master
			container.
		x_master_serial_number - serial number of the master container
			derived using the container hierarchy.
		x_return_status - return status of API
  DESCRIPTION : This procedure derives the master container instance id and
		master serial number of the container.  The master serial
		number and master container instance id is derived from the
		container instance table using the container heirarchy.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Master_Cont_Serial (
   p_container_instance_id IN NUMBER,
   x_master_container_id IN OUT NOCOPY  NUMBER,
   x_master_container_name IN OUT NOCOPY  VARCHAR2,
   x_master_serial_number IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update Child Containers
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_cont_instance_id - master container of the container
		x_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the master container instance id and
		master serial number of all the child containers. When the
		master serial number and master container instance id is
		changed on the master container, all the child containers are
		updated with the new values using this API.
------------------------------------------------------------------------------
*/



PROCEDURE Update_Child_Containers (
   p_container_instance_id IN NUMBER,
   p_master_cont_instance_id IN NUMBER,
   p_master_serial_number IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate Master Serial Number
   PARAMETERS : p_container_instance_id - instance id for the container
		p_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This is a dummy procedure created to help customers create
		a customizable validation API for the master serial number. It
		currently returns success for all cases.
  FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.containerTP
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Master_Serial_Number (
   p_master_serial_number IN VARCHAR2,
   p_container_instance_id IN NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2);

--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.ContainerTP>

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Master Serial Number
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the master serial number for a
		container by getting the serial number of the master container
		in the container heirarchy.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Master_Serial_Number (
   p_container_instance_id IN NUMBER,
   x_master_serial_number IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Is Empty
   PARAMETERS : p_container_instance_id - instance id for the container
	 	x_empty_flag - flag to return empty or non-empty
		x_return_status - return status of API
  DESCRIPTION : This procedure checks the container to see if there are any
		lines packed in the container. If there are no lines it returns
		a true flag to indicate that it is empty.
------------------------------------------------------------------------------
*/


PROCEDURE Is_Empty (
   p_container_instance_id IN NUMBER,
   x_empty_flag IN OUT NOCOPY  BOOLEAN,
   x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Is Empty
   PARAMETERS : p_container_instance_id - instance id for the container
                x_empty_flag - flag to return empty or non-empty
                x_return_status - return status of API
  DESCRIPTION : This procedure checks the container to see if there are any
                lines packed in the container. If there are no lines it returns
                a 'Y' flag to indicate that it is empty.
                If C1 contains C2 and C3. C2 has C4 which is empty , but C3 has a ddid
                Based on this API, C1 is not empty, but C2 ind C4 are empty.
------------------------------------------------------------------------------
*/

PROCEDURE Is_Empty (
   p_container_instance_id IN NUMBER,
   x_empty_flag OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Fill Percent
   PARAMETERS : p_container_instance_id - instance id for the container
		x_percent_fill - percent fill of the container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the percent fill of the container
		from the container instances table. If the percent fill is
		null, it recalculates the percent fill for the container.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Fill_Percent (
   p_container_instance_id IN NUMBER,
   x_percent_fill OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Delivery Status
   PARAMETERS : p_container_instance_id - instance id for the container
		x_delivery_id - delivery id the container is assigned to
		x_del_status - status of delivery that the container is
			assigned to.
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the delivery id and delivery status
		of the delivery that the container is assigned to.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Delivery_Status (
   p_container_instance_id IN NUMBER,
   x_delivery_id IN OUT NOCOPY  NUMBER,
   x_del_status IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Hold_Code
   PARAMETERS : p_delivery_detail_id - delivery detail id
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the hold code for the delivery detail
		id and returns a success if there is no hold code and returns
		an error if there is any invalid hold code.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Hold_Code (
  p_delivery_detail_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Hazard_Class
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_container_instance_id - delivery detail id of container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the hazard class id of the delivery
		detail id and checks if there is any incompatability or
		special restrictions on packing the detail into the specified
		container.  Also checks to see if the hazard class for the
		detail is incompatible with the other details already in the
		container. It returns a success if there are no restrictions
		and returns an error if there is any invalid hazard class.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Hazard_Class (
 p_delivery_detail_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2);


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Container
   PARAMETERS : p_container_name - container name that needs to be validated.
		p_container_instance_id - the delivery detail id for the
		container that needs to be updated.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes in the container name and existing
		container id (detail id) and checks to see if the container
		that is being updated is assigned to a closed, confirmed or
		in-transit delivery. If it is, no update is allowed - if not,
		only the container name can be updated if the name is not a
		duplicate of an existing container.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Container (
  p_container_name IN VARCHAR2,
  p_container_instance_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2);


END WSH_CONTAINER_UTILITIES;

 

/
