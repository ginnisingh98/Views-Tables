--------------------------------------------------------
--  DDL for Package CSD_PROCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_PROCESS_UTIL" AUTHID CURRENT_USER as
/* $Header: csdvutls.pls 120.8.12010000.3 2010/04/30 21:42:15 nnadig ship $ */

TYPE PRICING_ATTR_REC IS RECORD
(
 pricing_context        VARCHAR2(30) := FND_API.G_MISS_CHAR,
 pricing_attribute1     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute2     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute3     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute4     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute5     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute6     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute7     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute8     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute9     VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute10    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute11    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute12    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute13    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute14    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute15    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute16    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute17    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute18    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute19    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute20    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute21    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute22    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute23    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute24    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute25    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute26    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute27    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute28    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute29    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute30    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute31    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute32    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute33    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute34    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute35    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute36    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute37    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute38    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute39    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute40    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute41    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute42    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute43    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute44    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute45    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute46    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute47    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute48    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute49    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute50    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute51    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute52    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute53    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute54    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute55    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute56    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute57    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute58    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute59    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute60    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute61    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute62    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute63    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute64    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute65    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute66    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute67    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute68    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute69    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute70    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute71    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute72    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute73    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute74    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute75    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute76    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute77    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute78    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute79    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute80    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute81    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute82    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute83    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute84    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute85    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute86    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute87    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute88    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute89    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute90    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute91    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute92    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute93    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute94    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute95    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute96    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute97    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute98    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute99    VARCHAR2(150):= FND_API.G_MISS_CHAR,
 pricing_attribute100   VARCHAR2(150):= FND_API.G_MISS_CHAR
) ;


PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    NUMBER,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    VARCHAR2,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    DATE,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

FUNCTION Get_No_Chg_Flag
( p_txn_billing_type_id  IN NUMBER
 ) RETURN VARCHAR2;


FUNCTION Validate_action
(
  p_action        IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
 ) RETURN BOOLEAN;

FUNCTION Validate_incident_id
(
  p_incident_id   IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_repair_type_id
(
  p_repair_type_id    IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_inventory_item_id
(
  p_inventory_item_id     IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_unit_of_measure
(
  p_unit_of_measure  IN VARCHAR2
 ) RETURN BOOLEAN;

FUNCTION Validate_repair_group_id
(
  p_repair_group_id   IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_ro_job_date
(
  p_date  IN  DATE
 ) RETURN BOOLEAN;

PROCEDURE Convert_Est_to_Chg_rec
(
  p_estimate_line_rec  IN   CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
  x_charges_rec        OUT NOCOPY   CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
  x_return_status      OUT NOCOPY   VARCHAR2
);

PROCEDURE get_incident_id
(
  p_repair_line_id     IN   NUMBER,
  x_incident_id        OUT NOCOPY   NUMBER,
  x_return_status      OUT NOCOPY   VARCHAR2
);

PROCEDURE build_prod_txn_tbl
(
  p_repair_line_id     IN   NUMBER,
  p_create_thirdpty_line IN VARCHAR2 := fnd_api.g_false,
  x_prod_txn_tbl       OUT NOCOPY   csd_process_pvt.product_txn_tbl,
  x_return_status      OUT NOCOPY   VARCHAR2
);

PROCEDURE build_prodtxn_tbl_int
( p_repair_line_id     IN	NUMBER,
  p_quantity           IN   NUMBER,
  p_Serial_number      IN   VARCHAR2,
  p_instance_id        IN   NUMBER,
  p_create_thirdpty_line IN VARCHAR2 := fnd_api.g_false,
  x_prod_txn_tbl       OUT NOCOPY	csd_process_pvt.product_txn_tbl,
  x_return_status      OUT NOCOPY	VARCHAR2
 ) ;


FUNCTION Validate_rep_line_id
(
  p_repair_line_id  IN  NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_action_type
( p_action_type     IN VARCHAR2
 ) RETURN BOOLEAN;

FUNCTION Validate_action_code
( p_action_code     IN VARCHAR2
 ) RETURN BOOLEAN;

FUNCTION get_org_id
(
 --sangita shirkol changes  p_repair_line_id  IN  NUMBER
 p_incident_id IN NUMBER
 ) RETURN NUMBER;

--sangita Shirkol chnages

FUNCTION get_inv_org_id
	RETURN NUMBER;

FUNCTION get_bus_process
(
  p_repair_line_id IN  NUMBER
 ) RETURN NUMBER;

PROCEDURE Convert_to_Chg_rec
(
  p_prod_txn_rec       IN   CSD_PROCESS_PVT.PRODUCT_TXN_REC,
  x_charges_rec        OUT NOCOPY   Cs_Charge_Details_Pub.CHARGES_REC_TYPE,
  x_return_status      OUT NOCOPY   VARCHAR2
);


PROCEDURE get_line_type
(
  p_txn_billing_type_id IN  NUMBER,
  p_org_id              IN  NUMBER,
  x_line_type_id        OUT NOCOPY  NUMBER,
  x_line_category_code  OUT NOCOPY VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2
);

FUNCTION Get_group_rejected_quantity
(
  p_repair_group_id   IN    NUMBER
 ) RETURN NUMBER;

FUNCTION Validate_prod_txn_id
(
  p_prod_txn_id   IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_estimate_id
(
  p_estimate_id   IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_estimate_line_id
(
  p_estimate_line_id      IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION Validate_wip_entity_id
(
  p_wip_entity_id     IN    NUMBER
 ) RETURN BOOLEAN;

PROCEDURE Validate_wip_task
(
  p_prod_txn_id    IN   NUMBER,
  x_return_status  OUT NOCOPY   VARCHAR2
 );

PROCEDURE Validate_quantity
(
  p_action_type    IN   VARCHAR2,
  p_repair_line_id IN   VARCHAR2,
  p_prod_txn_qty   IN   NUMBER,
  x_return_status  OUT NOCOPY   VARCHAR2
 );

FUNCTION Is_item_serialized
(
  p_inv_item_id   IN    NUMBER
 ) RETURN BOOLEAN;

FUNCTION get_estimate( p_repair_line_id number,p_code varchar2 ) RETURN number;
FUNCTION g_miss_num RETURN number;
FUNCTION g_miss_char RETURN varchar2;
FUNCTION g_miss_date RETURN date;
FUNCTION g_valid_level(p_level varchar2) RETURN number;
FUNCTION g_boolean(p_FLAG varchar2) RETURN varchar2;
FUNCTION get_error_constant(err_msg varchar2) RETURN varchar2;
FUNCTION ui_prod_txn_rec RETURN csd_process_pvt.product_txn_rec;
FUNCTION sr_rec RETURN csd_process_pvt.service_request_rec;
FUNCTION repair_order_rec RETURN csd_repairs_pub.repln_rec_type;
FUNCTION ui_estimate_rec RETURN csd_repair_estimate_pvt.repair_estimate_rec;
FUNCTION ui_job_parameter_rec RETURN csd_group_job_pvt.job_parameter_rec;
FUNCTION ui_estimate_line_rec RETURN csd_repair_estimate_pvt.repair_estimate_line_rec;
FUNCTION ui_actual_lines_rec RETURN CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_REC_TYPE;
FUNCTION ui_charge_lines_rec RETURN Cs_Charge_Details_Pub.CHARGES_REC_TYPE;
FUNCTION ui_actuals_rec RETURN CSD_REPAIR_ACTUALS_PVT.CSD_REPAIR_ACTUALS_REC_TYPE;
FUNCTION ui_pricing_attr_rec RETURN csd_process_util.pricing_attr_rec;

FUNCTION ui_instance_rec RETURN csi_datastructures_pub.instance_rec;
FUNCTION ui_party_tbl  RETURN csi_datastructures_pub.party_tbl;
FUNCTION ui_party_account_tbl RETURN csi_datastructures_pub.party_account_tbl;
FUNCTION ui_organization_units_tbl RETURN  csi_datastructures_pub.organization_units_tbl;
FUNCTION ui_extend_attrib_values_tbl RETURN  csi_datastructures_pub.extend_attrib_values_tbl;
FUNCTION ui_pricing_attribs_tbl RETURN  csi_datastructures_pub.pricing_attribs_tbl;
FUNCTION ui_instance_asset_tbl RETURN  csi_datastructures_pub.instance_asset_tbl;
FUNCTION ui_transaction_rec RETURN  csi_datastructures_pub.transaction_rec;


PROCEDURE GET_CHARGE_SELLING_PRICE
       (p_inventory_item_id    in  NUMBER,
        p_price_list_header_id in  NUMBER,
        p_unit_of_measure_code in  VARCHAR2,
        p_currency_code        in  VARCHAR2,
        p_quantity_required    in  NUMBER,
        p_account_id		   in  NUMBER DEFAULT null,	 /* bug#3875036 */
	   p_org_id               in  NUMBER, -- Added for R12
        p_pricing_rec          in  CSD_PROCESS_UTIL.PRICING_ATTR_REC,
        x_selling_price        out NOCOPY NUMBER,
        x_return_status        out NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2
        ) ;

/* bug#3875036 */
PROCEDURE PRICE_REQUEST
       (p_inventory_item_id    in  NUMBER,
        p_price_list_header_id in  NUMBER,
        p_unit_of_measure_code in  VARCHAR2,
        p_currency_code        in  VARCHAR2,
        p_quantity_required    in  NUMBER,
        p_account_id		   in  NUMBER DEFAULT null,
        p_pricing_rec          in  CSD_PROCESS_UTIL.PRICING_ATTR_REC,
        x_selling_price        out NOCOPY NUMBER,
        x_return_status        out NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2
        ) ;


--gilam: bug 3082902 - ADD DEFAULT PRICE LIST TO RO FOR CONSISTENCY WITH RO CURRENCY
PROCEDURE GET_RO_DEFAULT_CURR_PL
(
  p_api_version        		IN  NUMBER,
  p_init_msg_list      		IN  VARCHAR2,
  p_incident_id 	    	IN  NUMBER,
  p_repair_type_id	    	IN  NUMBER,
  p_ro_contract_line_id    	IN  NUMBER,
  x_contract_pl_id    		OUT NOCOPY NUMBER,
  x_profile_pl_id    		OUT NOCOPY NUMBER,
  x_currency_code	        OUT NOCOPY VARCHAR2,
  x_return_status      		OUT NOCOPY VARCHAR2,
  x_msg_count          		OUT NOCOPY NUMBER,
  x_msg_data           		OUT NOCOPY VARCHAR2
);
--

-- travi changes
   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  COMMIT_ROLLBACK
   --   Type        :  Private Procedure
   --   Pre-Req     :  None
   --   Function    :  Does a commit or a rollback on the server side.
   --
   --   PARAMETERS
   --   IN
   --      COM_ROLL     IN   VARCHAR2 Optional   Default := 'ROLL'
   --
   --   End of Comments
   --

PROCEDURE COMMIT_ROLLBACK(
        COM_ROLL       IN   VARCHAR2 := 'ROLL') ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_SUCCESS
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_SUCCESS
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_ERROR
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_ERROR
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_UNEXP_ERROR
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_UNEXP_ERROR
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_NONE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_VALID_LEVEL_NONE
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_FULL
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_VALID_LEVEL_FULL
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_INT
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  CS_INTERACTION_PVT.G_VALID_LEVEL_INT
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_INT RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_TRUE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_TRUE
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION G_TRUE RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_FALSE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_FALSE
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION G_FALSE RETURN Varchar2;

FUNCTION get_res_name (p_object_type_code IN VARCHAR2,
                       p_object_id        IN NUMBER)
      RETURN VARCHAR2;


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  Is_MultiOrg_Enabled
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns TRUE if multiorg is enabled
   --                  else returns FALSE
   --   Return Type :  Boolean
   --
   --   End of Comments
   --
FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name    : Get_GLCurrencyCode
--   Type        :  Private Function
--   Pre-Req     :  None
--   Function    :  Returns CURRENCY CODE for the org id passed. If no currency
--                  code exists for the org, returns null.
--   Return Type : Varchar2
--
--   End of Comments
--


FUNCTION Get_GLCurrencyCode (p_org_id IN NUMBER )
       RETURN VARCHAR2;


-- bug fix for 4108369, Begin
FUNCTION Get_Sr_add_to_order (
	 p_repair_line_Id IN NUMBER,
	 p_action_type IN VARCHAR2
    ) RETURN NUMBER;



-- ***************************************************************************************
-- Fixed for bug#5190905
--
-- Procedure name: csd_get_txn_billing_type
-- description :   Ideally, the RT setup should capture SACs 'RMA'/'Ship' only (not SAC-BT) and select
--                 billing type based on the item attribute at the time of default prod txn creation.
--                 This API return the correct txn_billing_type_id based on Item billing type and service
--                 activity (Transaction_type_id).
--                 If transaction_type_id is not passed to this API then it derive the transaction_type_id
--                 using parameter p_txn_billing_type_id and then it derive the correct txn_billing_type_id
--                 for transaction.
-- Called from   : WVI trigger of rcv_ship.TRANSACTION_TYPE and CSD_PROCESS_UTIL.build_prodtxn_tbl_int
-- Input Parm    : p_api_version         NUMBER      Api Version number
--                 p_init_msg_list       VARCHAR2    Initializes message stack if fnd_api.g_true,
--                                                   default value is fnd_api.g_false
--		   p_incident_id         NUMBER      incident id of service request
--                 p_inventory_item_id   NUMBER
--                 p_transaction_type_id NUMBER
--                 p_txn_billing_type_id NUMBER      txn_billing_type_id (Service activity billing type SAC-BT)
--                                                   selected by user in RO type setup form. This can be pre/post
--                                                   repair RMA service activity or pre/post SHIP repair Service activity
-- Output Parm   :
--                 x_txn_billing_type_id NUMBER      New Txn_billing_type_Id based on transaction
--                                                   type and billing type of Item
--                 x_return_status       VARCHAR2    Return status after the call. The status can be
--                                                   fnd_api.g_ret_sts_success (success)
--                                                   fnd_api.g_ret_sts_error (error)
--                                                   fnd_api.g_ret_sts_unexp_error (unexpected)
--                 x_msg_count           NUMBER      Number of messages in the message stack
--                 x_msg_data            VARCHAR2    Message text if x_msg_count >= 1
-- **************************************************************************************
Procedure csd_get_txn_billing_type (
              p_api_version                 IN     NUMBER,
              p_init_msg_list               IN     VARCHAR2,
              p_incident_id                 IN     NUMBER,
              p_inventory_item_id           IN     NUMBER,
              P_transaction_type_id         IN     NUMBER,
              p_txn_billing_type_id         IN     NUMBER,
              x_txn_billing_type_id     OUT NOCOPY NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2
              );

/* bug#3875036 */
FUNCTION GET_PL_CURRENCY_CODE(p_price_list_id   IN   NUMBER)
	   RETURN VARCHAR2;


--begin bug#7355526, nnadig
-- Description: validates the subinventory on the ship line.
-- The function will see if negative inventory is allowed, if yes, then
-- it will check for the availability of item/serial number in the inventory.
-- parameters
-- @p_org_id IN Organization id
-- @p_sub_inv IN Sub Inventory Code
-- @p_inventory_item_id IN Inventory Item id of item
-- @p_serial_number IN serial number of the item.

FUNCTION validate_subinventory_ship
    (
        p_org_id            IN NUMBER,
        p_sub_inv           IN VARCHAR2,
        p_inventory_item_id IN NUMBER,
        p_serial_number     IN VARCHAR2 )
    RETURN BOOLEAN;

-- new function to validate the order, order line for OM holds.
-- Parameters.
-- @p_action_type in Type of line (RMA OR SHIP)
-- @p_order_header_id in order header id for the line.
-- @p_order_line_id  in order line id for the line default is null.
-- @x_entity_on_hold out Tells entity on hold H = header L = line.
FUNCTION validate_order_for_holds
    (
        p_action_type     IN VARCHAR2,
        p_order_header_id IN NUMBER,
        p_order_line_id   IN NUMBER DEFAULT NULL)
    RETURN BOOLEAN;

-- end bug#7355526, nnadig

End CSD_PROCESS_UTIL ;


/
