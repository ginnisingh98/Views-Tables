--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csiviivs.pls 120.12.12010000.2 2009/12/29 09:53:53 sjawaji ship $ */

/*----------------------------------------------------*/
/* Procedure name: Check_Reqd_Param_num               */
/* Description : To Check if the reqd parameter       */
/*----------------------------------------------------*/

PROCEDURE Check_Reqd_Param_num
(
        p_number                IN      NUMBER,
        p_param_name            IN      VARCHAR2,
        p_api_name              IN      VARCHAR2
);

/*----------------------------------------------------*/
/* Procedure name: Check_Reqd_Param_Char              */
/* Description : To Check if the reqd parameter       */
/*----------------------------------------------------*/

PROCEDURE Check_Reqd_Param_char
(
        p_variable              IN      VARCHAR2,
        p_param_name            IN      VARCHAR2,
        p_api_name              IN      VARCHAR2
);

/*----------------------------------------------------*/
/* Procedure name: Check_Reqd_Param_Date              */
/* Description : To Check if the reqd parameter       */
/*----------------------------------------------------*/

PROCEDURE Check_Reqd_Param_date
(
        p_date                  IN      DATE,
        p_param_name            IN      VARCHAR2,
        p_api_name              IN      VARCHAR2
);

/*----------------------------------------------------*/
/*  Validates the item instance ID                    */
/*----------------------------------------------------*/

FUNCTION InstanceExists
 (
   p_item_instance_id  IN  NUMBER,
   p_stack_err_msg     IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*-----------------------------------------------------*/
/*  Validates the termination status                   */
/*-----------------------------------------------------*/

FUNCTION termination_status
( p_instance_status_id     IN      NUMBER
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  Validates the item instance Number                */
/*----------------------------------------------------*/


FUNCTION Is_InstanceNum_Valid
(   p_item_instance_id           IN      NUMBER,
    p_instance_number            IN      VARCHAR2,
    p_mode                       IN      VARCHAR2,
    p_stack_err_msg              IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function verifies that the item is a valid   */
/*  inventory item and is marked as 'Trackable'       */
/*----------------------------------------------------*/

FUNCTION Is_Trackable
 (
   p_inv_item_id       IN  NUMBER,
   p_org_id            IN  NUMBER,
   p_trackable_flag    IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
   p_stack_err_msg     IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This Procedure verifies validity of serial number */
/*  ,lot number and revision when vld_organization_id */
/*  is changing.                                      */
/*----------------------------------------------------*/

PROCEDURE Validate_org_dependent_params
 (
   p_instance_rec           IN OUT NOCOPY csi_datastructures_pub.instance_rec,
   p_txn_rec                IN     csi_datastructures_pub.transaction_rec,
   l_return_value           IN OUT NOCOPY BOOLEAN
);

/*----------------------------------------------------*/
/*  This Procedure verifies that the item revision is */
/*  valid by looking into the mtl revision table      */
/*----------------------------------------------------*/

PROCEDURE Validate_Revision
 (
   p_inv_item_id            IN     NUMBER,
   p_inv_org_id             IN     NUMBER,
   p_revision               IN     VARCHAR2,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN,
   p_rev_control_code       IN     NUMBER DEFAULT FND_API.G_MISS_NUM
);

PROCEDURE Update_Revision
 (
   p_inv_item_id            IN     NUMBER,
   p_inv_org_id             IN     NUMBER,
   p_revision               IN     VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN,
   p_rev_control_code       IN     NUMBER DEFAULT FND_API.G_MISS_NUM
);

/*------------------------------------------------------*/
/*  This Procedure is called when creating a serial #s  */
/*  in mtl_serial_numbers for manually created CPs      */
/*------------------------------------------------------*/
--
PROCEDURE Create_Serial
 (
   p_inv_org_id         IN     NUMBER,
   p_inv_item_id        IN     NUMBER,
   p_serial_number      IN     VARCHAR2,
   p_mfg_srl_num_flag   IN OUT NOCOPY VARCHAR2,
   p_location_type_code IN     VARCHAR2,
   p_ins_flag           OUT NOCOPY VARCHAR2,
   p_lot_number         IN     VARCHAR2,
   p_gen_object_id      OUT NOCOPY NUMBER,
   l_return_value       IN OUT NOCOPY BOOLEAN
 );
--
/*----------------------------------------------------*/
/*  This function verifies that the item              */
/*  is under serial control or not                    */
/*----------------------------------------------------*/

FUNCTION Is_treated_serialized
( p_serial_control_code  IN      NUMBER  ,
  p_location_type_code   IN      VARCHAR2,
  p_transaction_type_id  IN      NUMBER DEFAULT FND_API.G_MISS_NUM
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function verifies that the item serial number*/
/*  is valid by looking into the mtl serial #s table  */
/*----------------------------------------------------*/

PROCEDURE Validate_Serial_Number
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   P_mfg_serial_number_flag     IN     VARCHAR2,
   p_txn_rec                    IN     csi_datastructures_pub.transaction_rec,
   p_creation_complete_flag     IN OUT NOCOPY VARCHAR2,
   p_location_type_code         IN     VARCHAR2, -- Added by sk on 09/13/01
   p_srl_control_code           IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   p_instance_id                IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   p_instance_usage_code        IN     VARCHAR2,
   l_return_value               IN OUT NOCOPY BOOLEAN
 );

/*----------------------------------------------------*/
/*  This procedure verifies that the serial number    */
/*  uniqueness                                        */
/*----------------------------------------------------*/

PROCEDURE Validate_ser_uniqueness
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   p_instance_id                IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   l_return_value               IN OUT NOCOPY BOOLEAN
 ) ;

/*---------------------------------------------------*/
/*  Validates the lot uniqueness and creates lot     */
/*  numbers in MLNs for manually created Instances   */
/*  Bug# 4011408                                     */
/*---------------------------------------------------*/

PROCEDURE Create_Lot
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_lot_number                 IN     VARCHAR2,
   p_shelf_life_code            IN     NUMBER,
   p_instance_id                IN     NUMBER,
   l_return_value               IN OUT NOCOPY BOOLEAN
 );

/*----------------------------------------------------*/
/*  This procedure verifies that the item lot number  */
/*  is valid by looking into the mtl lot #s table     */
/*----------------------------------------------------*/

PROCEDURE Validate_Lot_Number
 (
   p_inv_org_id             IN     NUMBER,
   p_inv_item_id            IN     NUMBER,
   p_lot_number             IN     VARCHAR2,
   p_mfg_serial_number_flag IN     VARCHAR2,
   p_txn_rec                IN     csi_datastructures_pub.transaction_rec,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   p_lot_control_code       IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   l_return_value           IN OUT NOCOPY BOOLEAN
);

/*----------------------------------------------------*/
/*  This function verifies that the quantity is not<0 */
/*  and also checks for serialized items              */
/*----------------------------------------------------*/

FUNCTION Is_Quantity_Valid
( p_instance_id         IN      NUMBER  ,
  p_inv_organization_id IN      NUMBER  ,
  p_quantity            IN      NUMBER  ,
  p_serial_control_code IN      NUMBER  ,
  p_location_type_code  IN      VARCHAR2,
  p_flag                IN      VARCHAR2,
  p_csi_txn_type_id     IN      NUMBER DEFAULT -999,
  p_current_qty         IN      NUMBER DEFAULT 0,
  p_stack_err_msg       IN BOOLEAN DEFAULT TRUE
)
RETURN BOOLEAN;

/*------------------------------------------------------------*/
/*  This function validates the uniqueness of config key      */
/*------------------------------------------------------------*/

FUNCTION Is_unique_config_key
( p_config_inst_hdr_id  IN      NUMBER  ,
  p_config_inst_item_id IN      NUMBER  ,
  p_instance_id         IN      NUMBER  ,
  p_validation_mode     IN      VARCHAR2
)
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function verifies that the UOM code is       */
/*  valid by looking into the mtl units of measure    */
/*  Also converts the entered uom into base uom       */
/*----------------------------------------------------*/

Procedure Is_Valid_Uom
(
    p_inv_org_id                IN      NUMBER,
    p_inv_item_id               IN      NUMBER,
    p_uom_code                  IN OUT NOCOPY  VARCHAR2,
    p_quantity                  IN OUT NOCOPY  NUMBER,
    p_creation_complete_flag    IN OUT NOCOPY  VARCHAR2,
    l_return_value              IN OUT NOCOPY  BOOLEAN);

/*----------------------------------------------------*/
/*  This function validates the item condition by     */
/*  looking through the MTL Material Statuses         */
/*----------------------------------------------------*/

PROCEDURE Is_Valid_Condition
 (
   p_instance_condition_id  IN     NUMBER,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN
);
/*----------------------------------------------------*/
/*  This function validates the item status by        */
/*  looking into the IB status tables                 */
/*----------------------------------------------------*/

PROCEDURE Is_Valid_Status
(
   p_instance_status_id     IN     NUMBER,
   p_creation_complete_flag IN OUT NOCOPY VARCHAR2,
   l_return_value           IN OUT NOCOPY BOOLEAN
 );

/*----------------------------------------------------*/
/*  This function validates the system id bu looking  */
/*  into the CSI systems lookup table                 */
/*----------------------------------------------------*/

FUNCTION Is_Valid_System_id
 (
   p_system_id          IN  NUMBER,
   p_stack_err_msg      IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the instance type code   */
/*  by looking through the CSI lookups                */
/*----------------------------------------------------*/

FUNCTION Is_Valid_Instance_Type
 (
   p_instance_type_code IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*-----------------------------------------------------*/
/*  This function checks for the instance usage code   */
/*  by looking through the CSI lookups                 */
/*-----------------------------------------------------*/

FUNCTION Valid_Inst_Usage_Code
(
   p_inst_usage_code    IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the active start date    */
/*  by looking through the CSI Instances table        */
/*----------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(   p_start_date            IN  DATE,
    p_end_date              IN  DATE,
    p_stack_err_msg         IN  BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the active start date    */
/*  by looking through the CSI Instances table        */
/*----------------------------------------------------*/

FUNCTION Is_EndDate_Valid
(
        p_start_date            IN   DATE,
    p_end_date              IN   DATE,
        p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the location type code   */
/*  by looking through the CSI lookups                */
/*----------------------------------------------------*/

FUNCTION Is_Valid_Location_Source
 (
   p_loc_source_table   IN  VARCHAR2,
   p_stack_err_msg      IN  BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*-----------------------------------------------------*/
/*  This procedure is used to validate the values      */
/*  passed to the update_item_instance                 */
/*-----------------------------------------------------*/

PROCEDURE get_merge_rec
(
   p_instance_rec      IN OUT NOCOPY   csi_datastructures_pub.instance_rec,
   l_curr_instance_rec IN       csi_datastructures_pub.instance_rec,
   l_get_instance_rec  OUT NOCOPY      csi_datastructures_pub.instance_rec
);

/*----------------------------------------------------*/
/* Function Name :  Get_instance_id                   */
/*                                                    */
/* Description  :  This function generates            */
/*                 instance_ids using a sequence      */
/*----------------------------------------------------*/

FUNCTION Get_instance_id
        ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
                           )
RETURN NUMBER;

/*----------------------------------------------------*/
/* Function Name :  get_cis_item_instance_h_id        */
/*                                                    */
/* Description  :  This function generates            */
/*                 cis_item_instance_h_id using a seq.*/
/*----------------------------------------------------*/

FUNCTION get_csi_item_instance_h_id
        ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
                           )
RETURN NUMBER;

/*----------------------------------------------------*/
/* Procedure name: Is_Instance_creation_complete      */
/* Description :   Check if the instance creation is  */
/*                 complete                           */
/*----------------------------------------------------*/

FUNCTION Is_Inst_creation_complete
(       p_instance_id           IN      NUMBER,
        p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*----------------------------------------------------*/
/* Procedure name: Is_Instance_parent                 */
/* Description : Check for the parent in csi rel's    */
/*                                                    */
/*----------------------------------------------------*/

FUNCTION Instance_has_Parent
( p_instance_id          IN      NUMBER,
  p_stack_err_msg        IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*----------------------------------------------------*/
/* This function verifies that the item serial number */
/* is valid by looking into the mtl serial #s table   */
/*----------------------------------------------------*/

PROCEDURE Validate_srl_num_for_Inst_Upd
 (
   p_inv_org_id                 IN     NUMBER,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   P_mfg_serial_number_flag     IN     VARCHAR2,
   p_txn_rec                    IN     csi_datastructures_pub.transaction_rec,
   p_location_type_code         IN     VARCHAR2, -- Added by sk on 09/13/01
   p_srl_control_code           IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   p_instance_usage_code        IN     VARCHAR2,
   p_instance_id                IN     NUMBER DEFAULT FND_API.G_MISS_NUM,
   l_return_value               IN OUT NOCOPY BOOLEAN
 );

/*----------------------------------------------------*/
/*  This function verifies that the quantity is not<0 */
/*  and also checks for serialized items              */
/*----------------------------------------------------*/
/*
FUNCTION Update_Quantity
(
  p_instance_id         IN      NUMBER  ,
  p_inv_organization_id IN      NUMBER  ,
  p_quantity            IN      NUMBER  ,
--p_serial_number       IN      VARCHAR2,
  p_serial_control_code IN      NUMBER  ,
  p_location_type_code  IN      VARCHAR2,
  p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
)
RETURN BOOLEAN;
*/
/*----------------------------------------------------*/
/*  This Procedure validates the accounting class code*/
/*                                                    */
/*----------------------------------------------------*/

PROCEDURE get_valid_acct_class
( p_instance_id            IN      NUMBER
 ,p_curr_acct_class_code   IN      VARCHAR2
 ,p_loc_type_code          IN      VARCHAR2
 ,x_acct_class_code        OUT NOCOPY     VARCHAR2
);

/*----------------------------------------------------*/
/*  Validates the item instance ID                    */
/*----------------------------------------------------*/

FUNCTION Is_InstanceID_Valid
(
 p_instance_id          IN      NUMBER,
 p_stack_err_msg        IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the active end date      */
/*  by looking through the CSI Instances table        */
/*----------------------------------------------------*/

FUNCTION EndDate_Valid
(
        p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
	p_transaction_id           IN NUMBER,  -- Bug 9081875
        p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This function checks for the uniqueness of        */
/*  the party owner                                   */
/*----------------------------------------------------*/

FUNCTION validate_uniqueness
(   p_instance_rec       csi_datastructures_pub.instance_rec,
    p_party_rec          csi_datastructures_pub.party_rec,
    p_srl_control_code   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_csi_txn_type_id    NUMBER DEFAULT FND_API.G_MISS_NUM
)
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  Validates the item instance ID                    */
/*  Used exclusively by copy item instance            */
/*----------------------------------------------------*/

FUNCTION Val_and_get_inst_rec
 (
   p_item_instance_id  IN       NUMBER,
   p_instance_rec         OUT NOCOPY   csi_datastructures_pub.instance_rec,
   p_stack_err_msg     IN       BOOLEAN DEFAULT TRUE
 )
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  Function : To get extended attrib level           */
/*  Used exclusively by copy item instance            */
/*----------------------------------------------------*/


FUNCTION get_ext_attrib_level
( p_ATTRIBUTE_ID       IN          NUMBER,
  p_ATTRIBUTE_LEVEL        OUT NOCOPY     VARCHAR2,
  p_stack_err_msg      IN          BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  Function : val_bom_org                            */
/*  Function : To validate item and org               */
/*----------------------------------------------------*/

FUNCTION val_item_org
( p_INVENTORY_ITEM_ID       IN          NUMBER,
  p_ORGANIZATION_ID         IN          VARCHAR2,
  p_stack_err_msg           IN          BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------*/
/*  Function : val_bom_org                             */
/*             To validate bom and org                 */
/*-----------------------------------------------------*/

FUNCTION val_bom_org
( p_INVENTORY_ITEM_ID       IN          NUMBER,
  p_ORGANIZATION_ID         IN          VARCHAR2,
  p_stack_err_msg           IN          BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;


/*-----------------------------------------------------*/
/*  Function : val_inst_ter_flag                       */
/*             To validate instances with statuses     */
/*              having termination_flag set to 'Y'     */
/*              has a end_date                         */
/*-----------------------------------------------------*/

FUNCTION val_inst_ter_flag
( p_status_id        IN          NUMBER,
  p_stack_err_msg    IN          BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------*/
/*  Function : Is_config_exploded                      */
/*             To check if the configuration for       */
/*              the item has been exploded ever        */
/*              before in Istalled Base                */
/*-----------------------------------------------------*/

FUNCTION Is_config_exploded
( p_instance_id      IN          NUMBER,
  p_stack_err_msg    IN          BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_EndDate_Valid                          */
/* Description : Check if version labels active end date     */
/*         is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;
--
/*-----------------------------------------------------------*/
/* Function name: Is_Valid_Location_ID                       */
/* Description : Check if the Location_ID and Location_Type  */
/*               are valid                                   */
/*-----------------------------------------------------------*/
FUNCTION Is_Valid_Location_ID
   (
     p_location_source_table              IN  VARCHAR2,
     p_location_id                        IN  NUMBER
   ) RETURN BOOLEAN;
--
/*-----------------------------------------------------------*/
/* Function name: Validate_Related_Loc_Params                */
/* Description : Check the Related Location Parameters for   */
/*               the give Location Type code and Location ID */
/*-----------------------------------------------------------*/
FUNCTION Validate_Related_Loc_Params
 (
   p_location_source_table              IN  VARCHAR2,
   p_location_id                        IN  NUMBER,
   p_organization_id                    IN  NUMBER,
   p_subinventory                       IN  VARCHAR2,
   p_locator_id                         IN  NUMBER,
   p_project_id                         IN  NUMBER,
   p_task_id                            IN  NUMBER,
   p_sales_ord_line_id                  IN  NUMBER,
   p_wip_job_id                         IN  NUMBER,
   p_po_line_id                         IN  NUMBER,
   p_inst_usage_code                    IN  VARCHAR2
 ) RETURN BOOLEAN;

-- Added by sguthiva for att enhancements

/*-----------------------------------------------------------*/
/* Procedure name: get_link_locations                        */
/* Description : Retreive the Location Parameters from       */
/*               associated instances of an instance of      */
/*               instance item class link                    */
/*-----------------------------------------------------------*/
 PROCEDURE get_link_locations
 (p_instance_header_tbl         IN OUT NOCOPY  csi_datastructures_pub.instance_header_tbl,
  x_return_status               OUT NOCOPY     VARCHAR2
  );

/*-----------------------------------------------------------*/
/* Procedure name: Call_batch_validate                       */
/* Description   : Call the batch validate                   */
/*-----------------------------------------------------------*/
PROCEDURE Call_batch_validate
( p_instance_rec        IN  csi_datastructures_pub.instance_rec
 ,p_config_hdr_id       IN  NUMBER
 ,p_config_rev_nbr      IN  NUMBER
 ,x_config_hdr_id       OUT NOCOPY NUMBER
 ,x_config_rev_nbr      OUT NOCOPY NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------*/
/* Procedure name: Create_hdr_xml                            */
/* Description   : Build xml message to pass it to cz api    */
/*-----------------------------------------------------------*/

PROCEDURE Create_hdr_xml
( p_config_hdr_id       IN  NUMBER
, p_config_rev_nbr      IN  NUMBER
, p_config_inst_hdr_id  IN  NUMBER
, x_xml_hdr             OUT NOCOPY VARCHAR2 -- this needs to be passed to Send_input_xml
, x_return_status       OUT NOCOPY VARCHAR2 );

/*-----------------------------------------------------------*/
/* Procedure name: Send_input_xml                            */
/* Description   : Make the actual call to cz api            */
/*-----------------------------------------------------------*/
PROCEDURE Send_input_xml
( p_xml_hdr             IN   VARCHAR2 -- Value passed from Create_hdr_xml
, x_out_xml_msg         OUT NOCOPY  LONG
, x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE  Parse_output_xml
(  p_xml                IN  LONG
  ,x_config_hdr_id      OUT NOCOPY NUMBER
  ,x_config_rev_nbr     OUT NOCOPY NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2 );
-- End addition by sguthiva for att enhancements

/*-----------------------------------------------------------*/
/* Procedure name: Is_Ver_StartDate_Valid                    */
/* Description : Check if Version Label's active start       */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;
--
/*-----------------------------------------------------------*/
/* Procedure name: Check_Prior_Txn                           */
/* Description : Check if there is any transactions pending  */
/*               this Item Instance prior to the current Txn */
/*-----------------------------------------------------------*/

PROCEDURE Check_Prior_Txn
   ( p_instance_rec           IN  csi_datastructures_pub.instance_rec
    ,p_txn_rec                IN  csi_datastructures_pub.transaction_rec
    ,p_prior_txn_id           OUT NOCOPY NUMBER
    ,p_mode                   IN  VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2
   );
   --
/*-----------------------------------------------------------*/
/* Procedure name: Is_Forward_Synch                          */
/* Description : Check if for the instance, forward synch is */
/*               not done after error correction.            */
/*-----------------------------------------------------------*/

FUNCTION Is_Forward_Synch
    ( p_instance_id  IN NUMBER,
      p_stop_all_txn IN VARCHAR2,
      p_mtl_txn_id   IN NUMBER )
 RETURN BOOLEAN;
--
/*-----------------------------------------------------------*/
/* Function name: Is_Valid_Master_Org                        */
/* Description : Check validity of the Master Organization   */
/*-----------------------------------------------------------*/

FUNCTION Is_Valid_Master_Org
   ( p_master_org_id  IN NUMBER )
  RETURN BOOLEAN;
--

/*-----------------------------------------------------------*/
/* Function name: Check_for_eam_item                         */
/* Description  : Check for eam item                         */
/*-----------------------------------------------------------*/
FUNCTION Check_for_eam_item
(p_inventory_item_id   IN NUMBER,
 p_organization_id     IN NUMBER,
 p_eam_item_type       IN NUMBER DEFAULT FND_API.G_MISS_NUM
 )
  RETURN BOOLEAN;

  PROCEDURE validate_serial_for_upd(
    p_instance_rec       IN csi_datastructures_pub.instance_rec,
    p_txn_rec            IN csi_datastructures_pub.transaction_rec,
    p_old_serial_number  IN varchar2,
    x_return_status      OUT nocopy varchar2);

/*---------------------------------------------------------*/
/*  This function checks for the operational status code   */
/*  by looking through the CSI lookups                     */
/*---------------------------------------------------------*/

FUNCTION Valid_operational_status
(
   p_operational_status    IN  VARCHAR2
 )
RETURN BOOLEAN;

/*---------------------------------------------------------*/
/*  This function checks for the currency code             */
/*  by looking through the fnd_currencies                  */
/*---------------------------------------------------------*/
FUNCTION Valid_currency_code
(
   p_currency_code    IN  VARCHAR2
 )
RETURN BOOLEAN;

/*---------------------------------------------------------*/
/*  This function checks if status is updateable           */
/*  by looking through the csi_instance_statuses           */
/*---------------------------------------------------------*/
FUNCTION is_status_updateable
(
   p_instance_status    IN  NUMBER,
   p_current_status     IN  NUMBER
 )
RETURN BOOLEAN;
--
/*-----------------------------------------------------------*/
/*  This function gets the version label of an item instance */
/*  based on the time stamp passed.                          */
/*---------------------------------------------------------*/
FUNCTION Get_Version_label
(
   p_instance_id        IN  NUMBER,
   p_time_stamp         IN  DATE
 )
RETURN VARCHAR2;
--

PROCEDURE get_mtl_txn_for_srl
(
     p_inventory_item_id IN number,
     p_serial_number     IN varchar2,
     x_mtl_txn_tbl       OUT nocopy csi_datastructures_pub.mtl_txn_tbl
);


END csi_Item_Instance_Vld_pvt;

/
