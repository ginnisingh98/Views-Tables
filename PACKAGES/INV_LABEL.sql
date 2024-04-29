--------------------------------------------------------
--  DDL for Package INV_LABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL" AUTHID CURRENT_USER AS
/* $Header: INVLABPS.pls 120.5.12010000.2 2008/07/29 13:40:08 ptkumar ship $ */
/*#
  * This procedure initiates a label print request for Oracle Warehouse
  * Management or Mobile Supply Chain Applications
  * @rep:scope public
  * @rep:product INV
  * @rep:lifecycle active
  * @rep:displayname Label Printing request for WMS/MSCA
  * @rep:category BUSINESS_ENTITY WMS_LABEL
  */

G_PKG_NAME  CONSTANT VARCHAR2(50) := 'INV_LABEL';

-- Table type definition for an array of transaction_id reocrds and input parameters
TYPE transaction_id_rec_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE input_parameter_rec_type is TABLE OF MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
    INDEX BY BINARY_INTEGER;

txn_id_null_rec      transaction_id_rec_type;
input_param_null_rec input_parameter_rec_type;

-- Table type definition of label type header information
TYPE label_type_rec is RECORD
(
    business_flow_code      NUMBER
,   label_type_id           NUMBER        -- Label Type ID
,   label_type              VARCHAR2(200) -- Label Type Desc
,   default_format_id       NUMBER
,   default_format_name     VARCHAR2(200)
,   default_printer         VARCHAR2(200)
,   default_no_of_copies    NUMBER
,   manual_format_id        NUMBER        -- Added for Add format/printer for manual request
,   manual_format_name      VARCHAR2(200) -- Added for Add format/printer for manual request
,   manual_printer          VARCHAR2(200) -- Added for Add format/printer for manual request
);
TYPE label_type_tbl_type IS TABLE OF label_type_rec INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
-- Included sql_Stmt to label_field_var_rec to hold the 'Custom Query' supplied by the user  |
---------------------------------------------------------------------------------------------
-- Record type and table of record type defintion for the selected fields for a format
TYPE label_field_variable_rec IS RECORD
(
    label_field_id      NUMBER
,   variable_name       VARCHAR2(100)
,   column_name         VARCHAR2(100)
,   sql_stmt            VARCHAR2(4000)  -- This field is newly added for the Custom SQL project.
);
------------------------End of this change for Custom Labels project code--------------------

TYPE label_field_variable_tbl_type IS TABLE OF label_field_variable_rec INDEX BY BINARY_INTEGER;

TYPE lpn_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Record type and table of record type definition to
--  keep lot and serial number data for material label
--  for receipt, inspection and put away
TYPE material_label_input_rec IS RECORD
(
    item_id         NUMBER
,   lot_number      VARCHAR2(240)
,   lot_quantity    NUMBER
,   serial_number   VARCHAR2(240)
);
TYPE material_label_input_tbl IS TABLE OF material_label_input_rec INDEX BY BINARY_INTEGER;

TYPE serial_tab_type IS TABLE OF VARCHAR(100) INDEX BY BINARY_INTEGER;

-- Table of record type to store label data.
--  Each record is a LONG variable to store one piece of label data
--  <LABEL> ... </LABEL>
--TYPE label_tbl_type IS TABLE OF LONG INDEX BY BINARY_INTEGER;

-- Sept.10: Patchset I change for label history and reprint
-- In addtion to the LONG variable for label data,
-- added information of Label format, Printer, and RequestID
TYPE label_rec_type IS RECORD
(
    label_request_id    NUMBER
,   label_content       LONG
,   label_status        VARCHAR2(1)
,   error_message       VARCHAR2(1000)
);
TYPE label_tbl_type IS TABLE OF label_rec_type INDEX BY BINARY_INTEGER;

TYPE t_genref IS REF CURSOR;

/* Bug 3417450. This table contains the request_id - label_type_id mapping which is
 * used to fetch the correct label format for the LPN Summary labels, if they are printed
 * from the LPN Content label print call
 */
TYPE label_request_rec IS RECORD
(
    label_request_id NUMBER
,   label_type_id NUMBER
);

TYPE label_request_tbl IS TABLE OF label_request_rec INDEX BY BINARY_INTEGER;



/*******************************************
 ** -- Global Variables
 *******************************************/
g_xml_content          LONG;
g_xml_header           LONG;
g_material_label_input material_label_input_tbl;
g_label_request_tbl    label_request_tbl;

-- Transaction Identifier denotes the source of Transaction. This is used
-- in conjunction with p_transaction_id to retrive the details. Possible values :
/* MANUAL: Manual mode. source is from p_input_param.p_transaction_id       */
/* MMTT : transaction is MTL_MATERIAL_TRANSACTIONS_TEMP.transaction_temp_id */
/* MTI  : transaction is MTL_TRANSACTION_INTERFACE.transaction_interface_id */
/* MTRL : transaction is MTL_TXN_REQUEST_LINES.line_id                      */
/* WFS  : transaction is WIP_FLOW_SCHEDULES.wip_entity_id                   */
/* RT   : transaction is RCV_TRANSACTION.lpn_group_id                       */
/* RSH  : transaction is RCV_SHIPMENT_HEADERS.shipment_header_id            */

-- bug #6417575, Label Printing Support for WIP Move Transactions (12.1)
/* WMT  : transaction is WIP_MOVE_TRANSACTIONS.transaction_id               */


TRX_ID_MANUAL CONSTANT NUMBER := 0;
TRX_ID_MMTT   CONSTANT NUMBER := 1;
TRX_ID_MTI    CONSTANT NUMBER := 2;
TRX_ID_MTRL   CONSTANT NUMBER := 3;
TRX_ID_WFS    CONSTANT NUMBER := 4;
TRX_ID_RT     CONSTANT NUMBER := 5;
TRX_ID_RSH    CONSTANT NUMBER := 6;
TRX_ID_DIS    CONSTANT NUMBER := 7; -- fabdi, added for gmo
TRX_ID_UNDIS  CONSTANT NUMBER := 8; -- fabdi, added for gmo
TRX_ID_WMT    CONSTANT NUMBER := 9; -- hjogleka, added for Label Printing Support for WIP Move Transactions (12.1)

-- Global Variable for RFID
-- Added for 11.5.10+ RFID Compliance project as lpn_group_id
-- Modified in R12 RFID project as EPC_GROUP_ID
-- This is used to  retrieve EPC for LPN/Material/Serial
-- For each label printing request, there will be a new LPN Group ID from WMS_EPC_S2
-- At the end of the label printing request, the value will be set to null
epc_group_id           NUMBER;

/*************************************************************************
*   Print Label
*     This can be called from transaction process or manual
*     p_print_mode:  1 => Transaction Driven
*                    2 => Manual print
*     If it is transaction driven, business flow code and transaction are required
*     If it is manual print, label type and input record are required
*  LABEL Types
*          1 Material
*          2 Serial
*          3 LPN
*          4 LPN Content
*          5 LPN Summary
*          6 Location
*          7 Shipping
*          8 Shipping Contents
*          9 WIP Content
*         10 WIP Flow
*         16 WIP Move Contents
***************************************************************************/
PROCEDURE PRINT_LABEL
(
    x_return_status          OUT NOCOPY VARCHAR2
,   x_msg_count              OUT NOCOPY NUMBER
,   x_msg_data               OUT NOCOPY VARCHAR2
,   x_label_status           OUT NOCOPY VARCHAR2
,   p_api_version            IN         NUMBER
,   p_init_msg_list          IN         VARCHAR2       := fnd_api.g_false
,   p_commit                 IN         VARCHAR2       := fnd_api.g_false
,   p_print_mode             IN         NUMBER
,   p_business_flow_code     IN         NUMBER    DEFAULT NULL
,   p_transaction_id         IN         transaction_id_rec_type   default txn_id_null_rec
,   p_input_param_rec        IN         input_parameter_rec_type  default input_param_null_rec
,   p_label_type_id          IN         NUMBER    DEFAULT NULL
,   p_no_of_copies           IN         NUMBER         := 1
,   p_transaction_identifier IN         NUMBER    DEFAULT NULL
,   p_format_id              IN         NUMBER    DEFAULT NULL   -- Added for the Add Printer and Format Project.
,   p_printer_name           IN         VARCHAR2  DEFAULT NULL -- Added for the Add Printer and Format Project.
) ;

/*************************************************************************
*   Print Label
*   New Overloaded procedure add by GMO fabdi
*
*    This can be called from transaction process or manual
*     p_print_mode:  1 => Transaction Driven
*                    2 => Manual print
*       If it is transaction driven, business flow code and transaction are required
*       If it is manual print, label type and input record are required
*  LABEL Types
*          1 Material
*          2 Serial
*          3 LPN
*          4 LPN Content
*          5 LPN Summary
*          6 Location
*          7 Shipping
*          8 Shipping Contents
*          9 WIP Content
*         10 WIP Flow
*         11 Process material
*         12 Dispense material
*         13 dispense cage
*         14 process product
*         15 process sample
*
***************************************************************************/
PROCEDURE PRINT_LABEL
(
    x_return_status           OUT NOCOPY VARCHAR2
,   x_msg_count               OUT NOCOPY NUMBER
,   x_msg_data                OUT NOCOPY VARCHAR2
,   x_label_status            OUT NOCOPY VARCHAR2
,   x_label_request_id        OUT NOCOPY NUMBER -- fabdi, new para
,   p_api_version             IN         NUMBER
,   p_init_msg_list           IN         VARCHAR2      := fnd_api.g_false
,   p_commit                  IN         VARCHAR2      := fnd_api.g_false
,   p_print_mode              IN         NUMBER
,   p_business_flow_code      IN         NUMBER   DEFAULT NULL
,   p_transaction_id          IN         transaction_id_rec_type  default txn_id_null_rec
,   p_input_param_rec         IN         input_parameter_rec_type default input_param_null_rec
,   p_label_type_id           IN         NUMBER   DEFAULT NULL
,   p_no_of_copies            IN         NUMBER        := 1
,   p_transaction_identifier  IN         NUMBER   DEFAULT NULL
,   p_format_id               IN         NUMBER   DEFAULT NULL   -- Added for the Add Printer and Format Project.
,   p_printer_name            IN         VARCHAR2 DEFAULT NULL -- Added for the Add Printer and Format Project.
) ;

/********************************************
 * Wrapper API for calling printing from Java
 * This wrapper is for giving transaction ID
 *******************************************/
PROCEDURE PRINT_LABEL_WRAP
(
    x_return_status           OUT NOCOPY VARCHAR2
,   x_msg_count               OUT NOCOPY NUMBER
,   x_msg_data                OUT NOCOPY VARCHAR2
,   x_label_status            OUT NOCOPY VARCHAR2
,   p_business_flow_code      IN         NUMBER   DEFAULT NULL
,   p_transaction_id          IN         NUMBER
,   p_transaction_identifier  IN         NUMBER   DEFAULT NULL
) ;

/********************************************
 * Wrapper API for calling printing from Java
 * This wrapper is for Manual Mode
 *******************************************/
/*#
* These procedure initiates manual label print request based on the provided
* information.  Note that the label will be generated with the given information
* provided by the input parameters, and will not be based on any transaction
* records such as MTL_MATERIAL_TRANSACTIONS_TEMP records. However, a
* business flow code can be provided for those transactions that do not have
* transaction records, such as Serial Generation, Cost Group Update, etc.
*
* @param x_return_status Return status of the procedure. If the procedure
* succeeds, the value will be fnd_api.g_ret_sts_success; if there is an expected * error, the value will be fnd_api.g_ret_sts_error; if there is an unexpected
* error, the value will be fnd_api.g_ret_sts_unexp_error;
* @ paraminfo {@rep:required}
* @ param x_msg_count if there is one or more errors, the number of error
* messages in the buffer
* @ paraminfo {@rep:required}
* @ param x_msg_data if there is one and only one error, the error message is x_msg_data, otherwise, get the messages from the message stack
* @ paraminfo {@rep:required}
* @ param x_label_status status message from printer. Currently not used
* @ paraminfo {@rep:required}
* @ param p_business_flow_code the business flow code that initiate this printing request. It is null for a manual print request. Valid values are specified in lookup WMS_BUSINESS_FLOW. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_label_type Type of label that is requested. Valid values are specified in lookup WMS_LABEL_TYPE. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_organization_id Organization ID. It is required for Material and Serial label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_inventory_item_id Inventory Item ID. It is required for Material and Serial label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_revision Item Revision.It is required for Material and Serial label, if applicable. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_lot_number Lot Number.It is required for Material and Serial label, if applicable. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_fm_serial_number From Serial Number. It is required for Serial label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_to_serial_number To Serial Number. It is required for Material and Serial label, when printing for a range of serial numbers, if applicable.Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_lpn_id License Plate Number ID. It is required for LPN, LPN Content, LPN Summary, and Shipping Content label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_subinventory_code Subinventory Code. It may be required for Location label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_locator_id Locator ID, It may be required for Location label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_delivery_id Delivery ID. It is required for Shipping and Shipping Content label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_quantity Quantity. It is required for Material label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_uom Unit of Measure code. It is required for Material label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_wip_entity_id WIP Entity Id. It is required for WIP Move Contents Label, Default value is NULL
* @ paraminfo {@rep:optional}
* @ param p_no_of_copies Number of copies of the label. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_fm_schedule_number From Schedule Number. Default value is  NULL. It is not used currently
* @ paraminfo {@rep:optional}
* @ param p_to_schedule_number To Schedule Number. Default value is  NULL. It is not used currently. Default value is  NULL
* @ paraminfo {@rep:optional}
* @ param p_format_id Label Format ID. If provided, this specific label format will be used to generate labels. Otherwise, the label format will be decided with WMS Rules Engine or default label format in a Inventory only appplication. Default is NULL
* @ paraminfo {@rep:optional}
* @ param p_printer_name Printer Name. If it is provided, this specific printer will be used to print a label. Otherwise, the printer will be decided with printer setup. Default value is  NULL
* @ paraminfo {@rep:optional}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname API to initiate a manual label printing request
* @rep:businessevent print_label_manual_wrap
*/
PROCEDURE PRINT_LABEL_MANUAL_WRAP
(
    x_return_status                   OUT NOCOPY  VARCHAR2
,   x_msg_count                       OUT NOCOPY  NUMBER
,   x_msg_data                        OUT NOCOPY  VARCHAR2
,   x_label_status                    OUT NOCOPY  VARCHAR2
,   p_business_flow_code              IN          NUMBER   DEFAULT NULL
,   p_label_type                      IN          NUMBER   DEFAULT NULL
,   p_organization_id                 IN          NUMBER   DEFAULT NULL
,   p_inventory_item_id               IN          NUMBER   DEFAULT NULL
,   p_revision                        IN          VARCHAR2 DEFAULT NULL
,   p_lot_number                      IN          VARCHAR2 DEFAULT NULL
,   p_fm_serial_number                IN          VARCHAR2 DEFAULT NULL
,   p_to_serial_number                IN          VARCHAR2 DEFAULT NULL
,   p_lpn_id                          IN          NUMBER   DEFAULT NULL
,   p_subinventory_code               IN          VARCHAR2 DEFAULT NULL
,   p_locator_id                      IN          NUMBER   DEFAULT NULL
,   p_delivery_id                     IN          NUMBER   DEFAULT NULL
,   p_quantity                        IN          NUMBER   DEFAULT NULL
,   p_uom                             IN          VARCHAR2 DEFAULT NULL
,   p_wip_entity_id                   IN          NUMBER   DEFAULT NULL
,   p_no_of_copies                    IN          NUMBER   DEFAULT NULL
,   p_fm_schedule_number              IN          VARCHAR2 DEFAULT NULL
,   p_to_schedule_number              IN          VARCHAR2 DEFAULT NULL
,   p_format_id                       IN          NUMBER   DEFAULT NULL
,   p_printer_name                    IN          VARCHAR2 DEFAULT NULL
);

/*****************************************************
 * API to get the label fields defined for a specific
 * format. This get called from the individual label
 * API's often.
 *****************************************************/
PROCEDURE GET_VARIABLES_FOR_FORMAT(
    x_variables         OUT NOCOPY label_field_variable_tbl_type
,   x_variables_count   OUT NOCOPY NUMBER
,   p_format_id         IN         NUMBER
);
/******************************************************
 * Overloaded procedure GET_VARIABLES_FOR_FORMAT
 * Added in 11.5.10+
 * Also it can check whether a given variable is included
 * in the given format
 * p_exist_variable_name has the name of the variable
 *  that will be checked for existence
 * x_is_variable_exist returns whether the given variable exists
 *  possible value is 'Y' or 'N'
 *******************************************************/
PROCEDURE GET_VARIABLES_FOR_FORMAT(
    x_variables           OUT NOCOPY label_field_variable_tbl_type
,   x_variables_count     OUT NOCOPY NUMBER
,   x_is_variable_exist   OUT NOCOPY VARCHAR2
,   p_format_id           IN         NUMBER
,   p_exist_variable_name IN         VARCHAR2 DEFAULT NULL
);

/*****************************************************
 * API to get default formatfor a pabel type passed in
 *****************************************************/
PROCEDURE GET_DEFAULT_FORMAT
  (p_label_type_id   IN         number,
   p_label_format    OUT NOCOPY VARCHAR2,
   p_label_format_id OUT NOCOPY NUMBER
);

/**********************************************************
 * Rules Engine call from within the individual label API's
 **********************************************************/
PROCEDURE GET_FORMAT_WITH_RULE
(
 P_DOCUMENT_ID                        IN         NUMBER               ,
 P_LABEL_FORMAT_ID                    IN         NUMBER   default null,
 P_ORGANIZATION_ID                    IN         NUMBER   default null,
 P_INVENTORY_ITEM_ID                  IN         NUMBER   default null,
 P_SUBINVENTORY_CODE                  IN         VARCHAR2 default null,
 P_LOCATOR_ID                         IN         NUMBER   default null,
 P_LOT_NUMBER                         IN         VARCHAR2 default null,
 P_REVISION                           IN         VARCHAR2 default null,
 P_SERIAL_NUMBER                      IN         VARCHAR2 default null,
 P_LPN_ID                             IN         NUMBER   default null,
 P_SUPPLIER_ID                        IN         NUMBER   default null,
 P_SUPPLIER_SITE_ID                   IN         NUMBER   default null,
 P_SUPPLIER_ITEM_ID                   IN         NUMBER   default null,
 P_CUSTOMER_ID                        IN         NUMBER   default null,
 P_CUSTOMER_SITE_ID                   IN         NUMBER   default null,
 P_CUSTOMER_ITEM_ID                   IN         NUMBER   default null,
 P_CUSTOMER_CONTACT_ID                IN         NUMBER   default null,
 P_FREIGHT_CODE                       IN         VARCHAR2 default null,
 P_LAST_UPDATE_DATE                   IN         DATE                 ,
 P_LAST_UPDATED_BY                    IN         NUMBER               ,
 P_CREATION_DATE                      IN         DATE                 ,
 P_CREATED_BY                         IN         NUMBER               ,
 P_LAST_UPDATE_LOGIN                  IN         NUMBER   default null,
 P_REQUEST_ID                         IN         NUMBER   default null,
 P_PROGRAM_APPLICATION_ID             IN         NUMBER   default null,
 P_PROGRAM_ID                         IN         NUMBER   default null,
 P_PROGRAM_UPDATE_DATE                IN         DATE     default null,
 P_ATTRIBUTE_CATEGORY                 IN         VARCHAR2 default null,
 P_ATTRIBUTE1                         IN         VARCHAR2 default null,
 P_ATTRIBUTE2                         IN         VARCHAR2 default null,
 P_ATTRIBUTE3                         IN         VARCHAR2 default null,
 P_ATTRIBUTE4                         IN         VARCHAR2 default null,
 P_ATTRIBUTE5                         IN         VARCHAR2 default null,
 P_ATTRIBUTE6                         IN         VARCHAR2 default null,
 P_ATTRIBUTE7                         IN         VARCHAR2 default null,
 P_ATTRIBUTE8                         IN         VARCHAR2 default null,
 P_ATTRIBUTE9                         IN         VARCHAR2 default null,
 P_ATTRIBUTE10                        IN         VARCHAR2 default null,
 P_ATTRIBUTE11                        IN         VARCHAR2 default null,
 P_ATTRIBUTE12                        IN         VARCHAR2 default null,
 P_ATTRIBUTE13                        IN         VARCHAR2 default null,
 P_ATTRIBUTE14                        IN         VARCHAR2 default null,
 P_ATTRIBUTE15                        IN         VARCHAR2 default null,
 P_PRINTER_NAME                       IN         VARCHAR2 default null,
 P_DELIVERY_ID                        IN         NUMBER   default null,
 P_BUSINESS_FLOW_CODE                 IN         NUMBER   default null,
 P_PACKAGE_ID                         IN         NUMBER   default null,
 p_sales_order_header_id              IN         NUMBER   default null,  -- bug 2326102
 p_sales_order_line_id                IN         NUMBER   default null,  -- bug 2326102
 p_delivery_detail_id                 IN         NUMBER   default null,  -- bug 2326102
 p_use_rule_engine                    IN         VARCHAR2 default null,  -- For label history of multi-rec label types
 x_return_status                      OUT NOCOPY VARCHAR2             ,
 x_label_format_id                    OUT NOCOPY NUMBER               ,
 x_label_format                       OUT NOCOPY VARCHAR2             ,
 x_label_request_id                   OUT NOCOPY NUMBER                  -- For label history
);

PROCEDURE trace(p_message IN VARCHAR2,
                p_prompt  IN VARCHAR2 ,
                p_level   IN NUMBER DEFAULT 12);


/***************************************
 * Get numbers between a specified range
 ***************************************/
PROCEDURE GET_NUMBER_BETWEEN_RANGE(
    fm_x_number     IN         VARCHAR2
,   to_x_number     IN         VARCHAR2
,   x_return_status OUT NOCOPY VARCHAR2
,   x_number_table  OUT NOCOPY serial_tab_type );

/***************************************
 * Update history record
 ***************************************/
PROCEDURE update_history_record(
    p_label_request_id  IN NUMBER
,   p_status_flag       IN VARCHAR2 DEFAULT NULL
,   p_job_status        IN VARCHAR2 DEFAULT NULL
,   p_printer_status    IN VARCHAR2 DEFAULT NULL
,   p_status_type       IN VARCHAR2 DEFAULT NULL
,   p_outfile_name      IN VARCHAR2 DEFAULT NULL
,   p_outfile_directory IN VARCHAR2 DEFAULT NULL
,   p_error_message     IN VARCHAR2 DEFAULT NULL
);

/**************************************
 * Reprint a previous label to a specified
 *  printer or no of copies
 * The input parameters are
 * p_hist_label_request_id :
       is the label request ID of the original
       label printing history record
 * p_printer_name: new printer name
 * p_no_of_copies: new number of copies
 **************************************/
PROCEDURE RESUBMIT_LABEL_REQUEST(
    x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_hist_label_request_id IN         NUMBER
,   p_printer_name          IN         VARCHAR2 DEFAULT NULL
,   p_no_of_copy            IN         NUMBER   DEFAULT NULL
);

/*************************************
 * Obtain Label Request Print Hist
 *************************************/
PROCEDURE INV_LABEL_REQUESTS_REPRINT (
               x_label_rep_hist_inqs    OUT NOCOPY t_genref,
               p_printer_Name           IN         VARCHAR2,
               p_bus_flow_Code          IN         NUMBER,
               p_label_type_Id          IN         NUMBER,
               p_lpn_Id                 IN         NUMBER,
               p_Requests               IN         NUMBER,
               p_created_By             IN         NUMBER,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2
);

-- Bug #3067059
/**************************************
 * Checks if there is a GTIN defined for the
 * Item + UOM + Rev combination.
 * Also fetches  GTIN and GTIN Desc. if it is
 * defined for the given Org, Item, UOM, Rev
**************************************/
PROCEDURE IS_ITEM_GTIN_ENABLED(
        x_return_status         OUT NOCOPY VARCHAR2
      , x_gtin_enabled          OUT NOCOPY BOOLEAN
      , x_gtin                  OUT NOCOPY VARCHAR2
      , x_gtin_desc             OUT NOCOPY VARCHAR2
      , p_organization_id       IN         NUMBER
      , p_inventory_item_id     IN         NUMBER
      , p_unit_of_measure       IN         VARCHAR2
      , p_revision              IN         VARCHAR2
);

/*****************************************
 * Global variables for business flow code
 *****************************************/
WMS_BF_RECEIPT             CONSTANT NUMBER := 1;
WMS_BF_INSPECTION          CONSTANT NUMBER := 2;
WMS_BF_DELIVERY            CONSTANT NUMBER := 3;
WMS_BF_PUTAWAY_DROP        CONSTANT NUMBER := 4;
WMS_BF_LPN_CORRECTION      CONSTANT NUMBER := 5;
WMS_BF_CROSSDOCK           CONSTANT NUMBER := 6;
WMS_BF_REPLENISHMENT_DROP  CONSTANT NUMBER := 7;
WMS_BF_CYCLE_COUNT         CONSTANT NUMBER := 8;
WMS_BF_PHYSICAL_COUNT      CONSTANT NUMBER := 9;
WMS_BF_MAT_STATUS_UPD      CONSTANT NUMBER := 10;
WMS_BF_COST_GROUP_UPD      CONSTANT NUMBER := 11;
WMS_BF_LOT_SPLIT_MERGE     CONSTANT NUMBER := 12;
WMS_BF_MISC_RECEIPT        CONSTANT NUMBER := 13;
WMS_BF_ORG_TRANSFER        CONSTANT NUMBER := 14;
WMS_BF_SUB_TRANSFER        CONSTANT NUMBER := 15;
WMS_BF_LPN_GENERATION      CONSTANT NUMBER := 16;
WMS_BF_SN_GENERATION       CONSTANT NUMBER := 17;
WMS_BF_PICK_LOAD           CONSTANT NUMBER := 18;
WMS_BF_PICK_DROP           CONSTANT NUMBER := 19;
WMS_BF_PACK_LPN            CONSTANT NUMBER := 20;
WMS_BF_SHIP_CONFIRM        CONSTANT NUMBER := 21;
WMS_BF_CARTONIZATION       CONSTANT NUMBER := 22;
WMS_BF_MISC_ISSUE          CONSTANT NUMBER := 23;
WMS_BF_DYNAMIC_LOCATOR     CONSTANT NUMBER := 24;
WMS_BF_IMPORT_ASN          CONSTANT NUMBER := 25;
WMS_BF_WIP_COMPLETION      CONSTANT NUMBER := 26;
WMS_BF_PUTAWAY_PREGEN      CONSTANT NUMBER := 27;
WMS_BF_WIP_PICK_LOAD       CONSTANT NUMBER := 28;
WMS_BF_WIP_PICK_DROP       CONSTANT NUMBER := 29;
WMS_BF_INV_PUTAWAY         CONSTANT NUMBER := 30;
WMS_BF_FLOW_LINE_START     CONSTANT NUMBER := 31;
WMS_BF_FLOW_LINE_OPERATION CONSTANT NUMBER := 32;
WMS_BF_FLOW_WORK_ASSEMBLY  CONSTANT NUMBER := 33;
WMS_BF_REPLENISHMENT_LOAD  CONSTANT NUMBER := 34;
WMS_BF_WIP_FLOW_PUTAWAY    CONSTANT NUMBER := 35;


/*******************************************
 * Global variables for Date, Time, User
 *******************************************/
G_DATE  VARCHAR2(20);
G_TIME  VARCHAR2(20);
G_USER  VARCHAR2(100);
G_DATE_FORMAT_MASK VARCHAR2(100);

/*******************************************
 * Global variable for Character Set and
 *  XML encoding
 *******************************************/
G_CHARACTER_SET VARCHAR2(50):= NULL;
G_XML_ENCODING  VARCHAR2(50):= NULL;
G_DEFAULT_XML_ENCODING CONSTANT VARCHAR2(50) := 'UTF-8';

/************************************
 * Global variable for Profile values
 ************************************/
G_PROFILE_PRINT_MODE NUMBER;
G_PROFILE_PREFIX     VARCHAR2(100);
G_PROFILE_OUT_DIR    VARCHAR2(200);
-- Bug #3067059
G_PROFILE_GTIN       VARCHAR2(100) := NULL;
/***********************************
 * Global variable for debug profile
 ***********************************/
L_DEBUG NUMBER := 0;


/***********************************
 * Global variable for label status
 ***********************************/
G_SUCCESS VARCHAR2(1) := 'S';
G_ERROR VARCHAR2(1) := 'E';
G_WARNING VARCHAR2(1) := 'W';
--added for lpn status project to get the status of the lpn after the transaction has been commited
FUNCTION get_txn_lpn_status
         (p_lpn_id IN NUMBER,
          p_transaction_id IN NUMBER,
          p_organization_id IN NUMBER,
          p_business_flow IN NUMBER)
          RETURN VARCHAR2 ;
--end of lpn status project

END INV_LABEL;

/
