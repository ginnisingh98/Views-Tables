--------------------------------------------------------
--  DDL for Package INV_TRANSACTION_FLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTION_FLOW_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPICTS.pls 120.2.12010000.4 2009/06/16 10:06:34 rkatoori ship $ */
/*#
 * This package provides routines to create, update and query
 * inter-company transaction flows.
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Inter-company transaction flow
 * @rep:category BUSINESS_ENTITY INV_IC_TRANSACTION_FLOW
 */

G_PACKAGE_NAME        CONSTANT VARCHAR2(30) := 'INV_TRANSACTION_FLOW_PUB';

G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_WARNING     CONSTANT VARCHAR2(1) := 'W';
G_RET_STS_ERROR       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;

G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

G_TRUE                CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_FALSE               CONSTANT VARCHAR2(1) := FND_API.G_FALSE;

G_MISS_NUM            CONSTANT NUMBER := FND_API.G_MISS_NUM;
-- Record type for inter-company transaction flow
TYPE  mtl_transaction_flow_rec_type is RECORD
(
  HEADER_ID			NUMBER -- Transaction flow header ID
, START_ORG_ID			NUMBER -- Start Operating Unit
, END_ORG_ID			NUMBER -- End Operating Unit
, ORGANIZATION_ID		NUMBER -- The Ship From Organization ID for shipping flow or Ship TO organization
					-- for procuring flow
, LINE_NUMBER 			NUMBER -- Sequence of the intermediate Node
, FROM_ORG_ID			NUMBER -- From operating unit
, FROM_ORGANIZATION_ID		NUMBER -- Default Inventory Organization of the Source Operating Unit
, TO_ORG_ID			NUMBER -- To Operating Unit
, TO_ORGANIZATION_ID		NUMBER -- Default Inventory Organization of the Destination Operating Unit
, ASSET_ITEM_PRICING_OPTION	NUMBER -- The pricing option for asset item
, EXPENSE_ITEM_PRICING_OPTION	NUMBER -- The pricing option for expense Item
, START_DATE			DATE -- Start Effective Date
, END_DATE			DATE -- End Effective Date
, CUSTOMER_ID			NUMBER -- Customer Id
, ADDRESS_ID			NUMBER -- Address ID
, CUSTOMER_SITE_ID		NUMBER -- Customer location ID
, CUST_TRX_TYPE_ID		NUMBER -- Customer transaction type id
, VENDOR_ID			NUMBER -- Vendor ID
, VENDOR_SITE_ID		NUMBER -- Vendor Location ID
, FREIGHT_CODE_COMBINATION_ID	NUMBER -- Account ID for Freight Code
, INVENTORY_ACCRUAL_ACCOUNT_ID	NUMBER -- Account ID for Inventory Accrual Account
, EXPENSE_ACCRUAL_ACCOUNT_ID	NUMBER -- Account ID for Expense Accrual
, INTERCOMPANY_COGS_ACCOUNT_ID  NUMBER -- ACCOUNT ID For Intercompany COGS
, NEW_ACCOUNTING_FLAG		VARCHAR2(1) -- Flag to indicate if transaction flow is used
, From_ORG_COST_GROUP_ID	NUMBER -- Cost group of the Source  Inventory Organization
, TO_ORG_COST_GROUP_ID		NUMBER -- Cost Group Of the Destination Inventory Organization
);


TYPE g_transaction_flow_tbl_type is TABLE of mtl_transaction_flow_rec_type INDEX BY BINARY_INTEGER;

TYPE number_tbl IS TABLE of Number INDEX BY BINARY_INTEGER;

TYPE varchar2_tbl IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

/*==================================================================================================
 * Following constant are for transaction flow type:
 * 1 - Shipping
 * 2 - Procuring
 * This mapped to mfg_lookups with lookup_type INV_TRANSACTION_FLOW_TYPE
 *==================================================================================================*/
G_SHIPPING_FLOW_TYPE  CONSTANT NUMBER := 1;
G_PROCURING_FLOW_TYPE CONSTANT NUMBER := 2;

-- This constant is for the qualifier code. For 115.10, the only qualifier is category

G_QUALIFIER_CODE CONSTANT NUMBER := 1;


-- Global constant for x_transaction_flow_status used in check_transaction_flow()

G_TRANSACTION_FLOW_FOUND     CONSTANT VARCHAR2(1) := 'Y';
G_TRANSACTION_FLOW_NOT_FOUND CONSTANT VARCHAR2(1) := 'N';
/*==================================================================================================
 * The following constant are for the ds_type_code, the type code of drop ship transaction
 * 1 -  logical receipt for global procurement transaction
 * 2 -  physical receipt for drop ship transaction
 * 3 -  physical receipt for non drop ship transaction
 *=================================================================================================*/
G_LOGICAL_RECEIPT_FOR_DS      CONSTANT NUMBER := 1;
G_PHYSICAL_RECEIPT_FOR_DS     CONSTANT NUMBER := 2;
G_PHYSICAL_RECEIPT_FOR_NON_DS CONSTANT NUMBER := 3;

/*===================================================================================================
 * Procedure: GET_TRANSACTION_FLOW()
 *
 * Description:
 * This API is used to get a valid Inter-company Transaction Flow defined
 * between the provided Start Operating Unit and End Operating Unit,
 * which is active on the transaction date provided and of the flow type
 * specified, Global Procurement Flow  or Drop Ship flow.
 *
 * Usage:
 * This API will be a public API and will be called by
 * 1.	The "Create Logical Transaction" API within Oracle Inventory,
 * 2.	By Receiving during the time of delivery for True Drop Ship flows
 * 3.	By Oracle Costing while creating the Receiving Accounting Event records for
 *      Global Procurement flows
 *
 * Inputs:
 * 1.	p_start_operating_unit: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	p_end_operating_unit: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	p_flow_type: To indicate whether this is Global Procurement flow or   Drop Ship flow
 * 4.   p_organization_id: Indicates the ship from/ship to organization for
 *      drop ship and global procuremnt flows respectively
 * 5.	p_qualifier_code_tbl: Array of Qualifier Codes, The qualifier code
 *      for this release will be "1" representing 'Category'
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 5.	Array of Qualifier Value IDs: The value of the qualifier.
 *      For this release, it will be the category_id of the item. This is an optional parameter.
 *      The default value of this parameter will be NULL.
 * 6.	Transaction Date: The date when the transaction is going to happen.
 * 7.	API version - the version of the API
 * 8.	Get default cost group - Flag to get the default cost group for the
 *      intermediate organization nodes
 *
 * Outputs:
 * This API will return a table of records(x_transaction_flows_tbl) of all the nodes in between the
 * Start Operating Unit and End Operating Unit, the pricing options,
 * and the Inter-Company Relations information
 * x_return_status - this API will return FND_API.G_RET_STS_SUCESS if it is successfull and a transaction flow record
 *                   is found.
 *                 - This API will return G_RET_STS_WARNING if it is successful but no transaction flow record is
 *                   found
 *                 - This API will return FND_API.G_RET_STS_ERROR,FND_API.G_RET_STS_UNEXP_ERROR on error.
 * x_transaction_flows_tbl - table of records of all the nodes in between
 *                           the Start Operating Unit and End Operating Unit, the pricing options,
 *                            and the Inter-Company Relations information
 *===================================================================================================*/
/*#
 * This API is used to get a valid Inter-company Transaction Flow defined
 * between the provided Start Operating Unit and End Operating Unit,
 * which is active on the transaction date provided and of the flow type
 * specified; Global Procurement Flow or Drop Ship flow.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_transaction_flows_tbl  return variable holding the table of records of all the nodes in between the Start Operating Unit and End Operating Unit
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_start_operating_unit The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 * @param p_end_operating_unit The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 * @param p_flow_type To indicate whether this is Global Procurement flow or Drop Ship flow
 * @param p_organization_id Indicates the ship from/ship to organization for drop ship and global procuremnt flows respectively
 * @param p_qualifier_code_tbl Array of Qualifier Codes, The qualifier code for this release will be "1" representing 'Category'
 * @param p_qualifier_value_tbl Array of Qualifier Value IDs.  For this release, it will be the category_id of the item.
 * @param p_transaction_date The date when the transaction is going to happen.
 * @param p_get_default_cost_group pass 'Y' to get the default cost group for the intermediate organization nodes
 * @rep:displayname Get Intercompany Transaction Flow
*/
procedure get_transaction_flow(
 	x_return_status		OUT NOCOPY 	VARCHAR2
, 	x_msg_data		OUT NOCOPY 	VARCHAR2
,	x_msg_count		OUT NOCOPY 	NUMBER
, 	x_transaction_flows_tbl	OUT NOCOPY 	G_TRANSACTION_FLOW_TBL_TYPE
,       p_api_version 		IN		NUMBER
,       p_init_msg_list		IN		VARCHAR2 DEFAULT G_FALSE
,	p_start_operating_unit	IN		NUMBER
, 	p_end_operating_unit	IN		NUMBER
,	p_flow_type		IN		NUMBER
,       p_organization_id	IN		NUMBER
, 	p_qualifier_code_tbl	IN		NUMBER_TBL
,	p_qualifier_value_tbl	IN		NUMBER_TBL
, 	p_transaction_date	IN		DATE
,       p_get_default_cost_group IN		VARCHAR2
);


 /*===================================================================================================
 * Procedure: GET_TRANSACTION_FLOW()
 *
 * Description:
 * This API is used to get a valid Inter-company Transaction Flow for a
 * given transaction flow header
 *
 * Usage:
 * This API will be a PUBLIC PROCEDURE and will be called by
 * 1.	the "Create Logical Transaction" API within Oracle Inventory,
 *
 * To get a valid Inter-company Transaction Flow for a given transaction flow header.
 * Inputs:
 * This API will receive the following input parameters:
 * 1.	p_api_version - the version of the API
 * 2.	p_header_id - Transaction Flow Header id
 * 3.   p_Get_default_cost_group - if passed 'Y' , populates the from org
 *      cost group and to org cost group on the return transaction flows table
 *
 * Outputs:
 * This API will return a table of records(x_transaction_flows_tbl) of all the nodes in between the
 * Start Operating Unit and End Operating Unit, the pricing options,
 * and the Inter-Company Relations information
 * x_return_status - this API will return FND_API.G_RET_STS_SUCESS if it is successfull and a transaction flow record
 *                   is found.
 *                 - This API will return G_RET_STS_WARNING if it is successful but no transaction flow record is
 *                   found
 *                 - This API will return FND_API.G_RET_STS_ERROR,FND_API.G_RET_STS_UNEXP_ERROR on error.
 * x_transaction_flows_tbl - table of records of all the nodes in between
 *                           the Start Operating Unit and End Operating Unit, the pricing options,
 *                            and the Inter-Company Relations information
 *===================================================================================================*/
/*#
 * This API is used to get a valid Inter-company Transaction Flow defined
 * for a given transaction flow header.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_transaction_flows_tbl  return variable holding the table of records of all the nodes in between the Start Operating Unit and End Operating Unit
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_header_id Transaction Flow Header identifier
 * @param p_get_default_cost_group pass 'Y' to get the default cost group for the intermediate organization nodes
 * @rep:displayname Get Intercompany Transaction Flow
*/
procedure get_transaction_flow(
 	x_return_status		OUT NOCOPY 	VARCHAR2
, 	x_msg_data		OUT NOCOPY 	VARCHAR2
,	x_msg_count		OUT NOCOPY 	NUMBER
, 	x_transaction_flows_tbl	OUT NOCOPY 	g_transaction_flow_tbl_type
,       p_api_version 		IN		NUMBER
,       p_init_msg_list		IN		VARCHAR2 default G_FALSE
, 	p_header_id	        IN		NUMBER
,       p_get_default_cost_group IN		VARCHAR2
);


/*======================================================================================================
 * Procedure: CHECK_TRANSACTION_FLOW()
 * Description:
 * This procedure will return true if a Inter-company Transaction Flow exists
 * between the provided Start Operating Unit and End Operating Unit,
 * which is active on the transaction date provided and of the flow type
 * specified, Global Procurement Flow or Drop Ship flow.
 *
 * Usage:
 * This will be a public procedure and will be called by PO while user creates the PO Document.
 * This API will return true if a Inter-company Transaction Flow exists between two operating units
 * for user specified date and qualifier.
 *
 * Inputs:
 * 1.	p_start_operating_unit: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	p_end_operating_unit: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	p_flow_type: To indicate whether this is Global Procurement flow or   Drop Ship flow
 * 4.   p_organization_id: Indicates the ship from/ship to organization for
 *      drop ship and global procuremnt flows respectively
 * 5.	p_qualifier_code_tbl: Array of Qualifier Codes, The qualifier code
 *      for this release will be "1" representing 'Category'
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 6.	Array of Qualifier Value IDs: The value of the qualifier.
 *      For this release, it will be the category_id of the item. This is an optional parameter.
 *      The default value of this parameter will be NULL.
 * 7.	Transaction Date: The date when the transaction is going to happen.
 * 8.	API version - the version of the API
 * 9.	Get default cost group - Flag to get the default cost group for the
 *      intermediate organization nodes
 *
 * Outputs:
 * This API will return G_TRANSACTION_FLOW_FOUND in x_transaction_flow_exists if a
 * Inter-company Transaction Flow exists between two operating units for user specified date and qualifier.
 * Otherwise, it will return G_TRANSACTION_FLOW_NOT_FOUND
 * The API will also return the header_id for the Inter-company Transaction Flow,
 * and the new_accounting_flag to indicate whether Inter-company Transaction Flow is used or not.
 *
 * x_transaction_flow_exists - G_TRANSACTION_FLOW_FOUND or G_TRANSACTION_FLOW_NOT_FOUND
 * x_header_id - header_id of the transaction flow found
 * x_new_accounting_flag - new_accounting_flag indicating whether Inter-company Transaction Flow is used or not.
 * x_return_status - this API will return FND_API.G_RET_STS_SUCESS if it is successful and a transaction flow record
 *                   is found.
 *                 - This API will return G_RET_STS_WARNING if it is successful but no transaction flow record is
 *                   found
 *                 - This API will return FND_API.G_RET_STS_ERROR,FND_API.G_RET_STS_UNEXP_ERROR on error.
 *======================================================================================================*/
/*#
 * This procedure will return true if an Inter-company Transaction Flow exists
 * between the provided Start Operating Unit and End Operating Unit,
 * which is active on the transaction date provided and of the flow type
 * specified; Global Procurement Flow or Drop Ship flow.
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_start_operating_unit The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 * @param p_end_operating_unit The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 * @param p_flow_type To indicate whether this is Global Procurement flow or Drop Ship flow
 * @param p_organization_id Indicates the ship from/ship to organization for drop ship and global procuremnt flows respectively
 * @param p_qualifier_code_tbl Array of Qualifier Codes, The qualifier code for this release will be "1" representing 'Category'
 * @param p_qualifier_value_tbl Array of Qualifier Value IDs.  For this release, it will be the category_id of the item.
 * @param p_transaction_date The date when the transaction is going to happen.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_header_id  return variable holding the header id of the transaction flow found
 * @param x_new_accounting_flag return variable indicating whether advanced accounting is being used for the transaction flow
 * @param x_transaction_flow_exists return FND_API.G_RET_STS_SUCESS if transaction flow found
 * @rep:displayname Check Inter Company Transaction Flow
*/
Procedure check_transaction_flow(
	p_api_version		  IN	        NUMBER
,       p_init_msg_list           IN            VARCHAR2 default G_FALSE
,	p_start_operating_unit	  IN	        NUMBER
, 	p_end_operating_unit	  IN	        NUMBER
,	p_flow_type		  IN		NUMBER
,       p_organization_id	  IN		NUMBER
, 	p_qualifier_code_tbl	  IN		NUMBER_TBL
,	p_qualifier_value_tbl	  IN		NUMBER_TBL
, 	p_transaction_date	  IN		DATE
,	x_return_status		  OUT NOCOPY	VARCHAR2
,	x_msg_count		  OUT NOCOPY	NUMBER
,	x_msg_data		  OUT NOCOPY	VARCHAR2
, 	x_header_id		  OUT NOCOPY 	NUMBER
, 	x_new_accounting_flag	  OUT NOCOPY	VARCHAR2
,	x_transaction_flow_exists OUT NOCOPY	VARCHAR2
);

/*=======================================================================================================
 * Procedure: create_transaction_flow()
 * This API is a private API to insert new transaction flow for  a start operating unit and end operating unit.
 * This API will be called by the Transaction Flow Setup Form on the ON-INSERT trigger of the block.
 * Inputs:
 *
 * 1.	Start OU: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	End OU: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	Flow Type: To indicate what is the flow type, either Global Procurement or Drop Ship
 * 4.	Qualifier Code: The qualifier code, for  this release, it will be "1" - Category.
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 5.	Qualifier Value ID: The value of the qualifier.
 *      For this release, it will be the category_id of the item. The default value of this parameter will be NULL.
 * 6.	Start Date: The date when the Inter-company Transaction Flow become active.
 *      The default value is SYSDATE. This is required parameter
 * 7.	End Date: The date when the when Inter-company Transaction Flow become inactive.
 * 8.	Asset Item Pricing Option: The pricing option for asset item for global procurement flow.
 * 9.	Expense Item Pricing option: the pricing option for expense item
 * 10.	new accounting flag : flag to indicate new accounting will be use
 * 11.	line_number_tbl - list of sequence of the line nodes
 * 12.	from_ou_tbl - list of from operating unit of the line nodes
 * 13.	to_ou_tbl - list of to_operating unit of the line nodes
 *
 * Outputs:
 * 1.	header_id
 * 2.	line_number
 *
 *=======================================================================================================*/
/*#
 * This procedure is used to create an intercompany transaction flow header,
 * transaction flow lines and intercompany relations together. This procedure
 * mimics the creation of a transaction flow through the Intercompany
 * transaction flow form. Please refer to the form and the Inventory User's
 * Guide to understand each parameter.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_header_id  return variable holding the header id of the transaction flow created
 * @param x_line_number_tbl return variable table of transaction flow line numbers created
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_validation_level Indiactes the level of validation to be done. Pass 1.
 * @param p_start_org_id Start operating_unit
 * @param p_end_org_id End Operating Unit
 * @param p_flow_type indicate whether this is used for Global Procurement flow or Drop Ship flow
 * @param p_organization_id Indicates the ship from/ship to organization for drop ship and global procuremnt flows respectively
 * @param p_qualifier_code The qualifier code for this release will be "1" representing 'Category'
 * @param p_qualifier_value_id  The qualifier value For this release will be the category_id of the item.
 * @param p_asset_item_pricing_option pricing option for asset item for global procurement flow.
 * @param p_expense_item_pricing_option pricing option for expense item
 * @param p_new_accounting_flag Indicates whether advanced accounting to be used
 * @param p_start_date The date when the Inter-company Transaction Flow become active.
 * @param p_end_date The date when the when Inter-company Transaction Flow become inactive.
 * @param p_Attribute_Category Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute1 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute2 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute3 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute4 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute5 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute6 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute7 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute8 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute9 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute10 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute11 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute12 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute13 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute14 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute15 Flexfield Attribute for Transaction Flow Header
 * @param p_line_number_tbl Table of line numbers
 * @param p_from_org_id_tbl Table of from operating unit of the line nodes
 * @param p_from_organization_id_tbl Table of from organization_id of the line nodes
 * @param p_to_org_id_tbl Table of to operating unit of the line nodes
 * @param p_to_organization_id_tbl Table of to organization_id of the line nodes
 * @param p_LINE_Attribute_Category_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute1_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute2_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute3_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute4_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute5_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute6_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute7_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute8_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute9_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute10_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute11_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute12_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute13_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute14_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute15_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_Ship_Organization_Id_tbl Table of Shipping organization_id for each Transaction Flow Line
 * @param p_Sell_Organization_Id_tbl Table of selling organization_id for each Transaction Flow Line
 * @param p_Vendor_Id_tbl Table of  vendor_id for each Transaction Flow Line
 * @param p_Vendor_Site_Id_tbl Table of vendor site id for each Transaction Flow Line
 * @param p_Customer_Id_tbl Table of customer id for each Transaction Flow Line
 * @param p_Address_Id_tbl Table of address id for each Transaction Flow Line
 * @param p_Customer_Site_Id_tbl Table of customer site id for each Transaction Flow Line
 * @param p_Cust_Trx_Type_Id_tbl Table of customer transaction type id for each Transaction Flow Line
 * @param p_IC_Attribute_Category_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute1_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute2_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute3_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute4_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute5_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute6_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute7_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute8_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute9_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute10_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute11_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute12_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute13_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute14_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute15_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_Revalue_Average_Flag_tbl Table of revalue average flags for Inter company relation
 * @param p_Freight_Code_Comb_Id_tbl Table of Freight Code Combination Ids for Inter company relation
 * @param p_Inv_Currency_Code_tbl Table of currency code for Inter company relation
 * @param p_IC_COGS_Acct_Id_tbl  Table of COGS account ids for Inter company relation
 * @param p_Inv_Accrual_Acct_Id_tbl Table of accrual account Ids for Inter company relation
 * @param p_Exp_Accrual_Acct_Id_tbl Table of expense accrual account Ids  for Inter company relation
 * @rep:displayname Create Inter Company Transaction Flow
*/
PROCEDURE create_transaction_flow
(
  x_return_status		OUT NOCOPY 	VARCHAR2
, x_msg_data			OUT NOCOPY 	VARCHAR2
, x_msg_count			OUT NOCOPY 	NUMBER
, x_header_id			OUT NOCOPY	NUMBER
, x_line_number_tbl		OUT NOCOPY	NUMBER_TBL
, p_api_version                 IN              NUMBER
, p_init_msg_list               IN              VARCHAR2 default G_FALSE
, p_validation_level		IN		NUMBER
, p_start_org_id	 	IN 		NUMBER
, p_end_org_id			IN		NUMBER
, p_flow_type			IN		NUMBER
, p_organization_id             IN              NUMBER
, p_qualifier_code		IN		NUMBER
, p_qualifier_value_id		IN		NUMBER
, p_asset_item_pricing_option 	IN		NUMBER
, p_expense_item_pricing_option IN 		NUMBER
, p_new_accounting_flag		IN		VARCHAR2
, p_start_date                  IN              DATE DEFAULT SYSDATE
, p_end_date                    IN              DATE DEFAULT NULL
, P_Attribute_Category          IN              VARCHAR2
, P_Attribute1                  IN              VARCHAR2
, P_Attribute2                  IN              VARCHAR2
, P_Attribute3                  IN              VARCHAR2
, P_Attribute4                  IN              VARCHAR2
, P_Attribute5                  IN              VARCHAR2
, P_Attribute6                  IN              VARCHAR2
, P_Attribute7                  IN              VARCHAR2
, P_Attribute8                  IN              VARCHAR2
, P_Attribute9                  IN              VARCHAR2
, P_Attribute10                 IN              VARCHAR2
, P_Attribute11                 IN              VARCHAR2
, P_Attribute12                 IN              VARCHAR2
, P_Attribute13                 IN              VARCHAR2
, P_Attribute14                 IN              VARCHAR2
, P_Attribute15                 IN              VARCHAR2
, p_line_number_tbl		     IN		NUMBER_TBL
, p_from_org_id_tbl		     IN		NUMBER_TBL
, p_from_organization_id_tbl	     IN 	NUMBER_TBL
, p_to_org_id_tbl		     IN		NUMBER_TBL
, p_to_organization_id_tbl	     IN 	NUMBER_TBL
, P_LINE_Attribute_Category_tbl      IN         VARCHAR2_tbl
, P_LINE_Attribute1_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute2_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute3_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute4_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute5_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute6_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute7_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute8_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute9_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute10_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute11_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute12_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute13_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute14_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute15_tbl             IN         VARCHAR2_tbl
, P_Ship_Organization_Id_tbl             IN         NUMBER_tbl
, P_Sell_Organization_Id_tbl             IN         NUMBER_tbl
, P_Vendor_Id_tbl                        IN         NUMBER_tbl
, P_Vendor_Site_Id_tbl                   IN         NUMBER_tbl
, P_Customer_Id_tbl                      IN         NUMBER_tbl
, P_Address_Id_tbl                       IN         NUMBER_tbl
, P_Customer_Site_Id_tbl                 IN         NUMBER_tbl
, P_Cust_Trx_Type_Id_tbl                 IN         NUMBER_tbl
, P_IC_Attribute_Category_tbl            IN         VARCHAR2_tbl
, P_IC_Attribute1_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute2_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute3_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute4_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute5_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute6_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute7_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute8_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute9_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute10_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute11_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute12_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute13_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute14_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute15_tbl                   IN         VARCHAR2_tbl
, P_Revalue_Average_Flag_tbl             IN         VARCHAR2_tbl
, P_Freight_Code_Comb_Id_tbl      	 IN         NUMBER_tbl
, P_Inv_Currency_Code_tbl		 IN	    NUMBER_tbl
, P_IC_COGS_Acct_Id_tbl     	         IN         NUMBER_tbl
, P_Inv_Accrual_Acct_Id_tbl     	 IN         NUMBER_tbl
, P_Exp_Accrual_Acct_Id_tbl       	 IN         NUMBER_tbl
);



/*========================================================================================================
 * Procedure: Update_transaction_Flow()
 *
 * Description:
 * This API is used to update the transaction flow. Once a transaction flow is created, user can only
 * update the start date and the end date.
 *
 * Inputs:
 * 1.	header_id
 * 2.	end_date
 * 3.   start_date
 *
 * Outputs:
 * 1.	Return status
 * 2.	message
 * 3.	message count
 *
 *========================================================================================================*/
/*#
 * This procedure is used to update an intercompany transaction flow. Once a
 * transaction flow has been created, user can only
 * update the start date and the end date on the header.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_validation_level Indiactes the level of validation to be done. Pass 1.
 * @param p_header_id Transaction flow header
 * @param p_flow_type indicate whether this is used for Global Procurement flow or Drop Ship flow
 * @param p_start_date The date when the Inter-company Transaction Flow become active.
 * @param p_end_date The date when the when Inter-company Transaction Flow become inactive.
 * @param p_Attribute_Category Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute1 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute2 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute3 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute4 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute5 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute6 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute7 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute8 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute9 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute10 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute11 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute12 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute13 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute14 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute15 Flexfield Attribute for Transaction Flow Header
 * @param p_line_number_tbl Table of line numbers
 * @param p_LINE_Attribute_Category_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute1_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute2_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute3_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute4_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute5_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute6_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute7_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute8_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute9_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute10_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute11_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute12_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute13_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute14_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_LINE_Attribute15_tbl Table of Flexfield Attribute for Transaction Flow Lines
 * @param p_Ship_Organization_Id_tbl Table of Shipping organization_id for each Transaction Flow Line
 * @param p_Sell_Organization_Id_tbl Table of selling organization_id for each Transaction Flow Line
 * @param p_Vendor_Id_tbl Table of  vendor_id for each Transaction Flow Line
 * @param p_Vendor_Site_Id_tbl Table of vendor site id for each Transaction Flow Line
 * @param p_Customer_Id_tbl Table of customer id for each Transaction Flow Line
 * @param p_Address_Id_tbl Table of address id for each Transaction Flow Line
 * @param p_Customer_Site_Id_tbl Table of customer site id for each Transaction Flow Line
 * @param p_Cust_Trx_Type_Id_tbl Table of customer transaction type id for each Transaction Flow Line
 * @param p_IC_Attribute_Category_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute1_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute2_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute3_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute4_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute5_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute6_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute7_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute8_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute9_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute10_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute11_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute12_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute13_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute14_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_IC_Attribute15_tbl Table of Flexfield Attribute for Inter company relation
 * @param p_Revalue_Average_Flag_tbl Table of revalue average flags for Inter company relation
 * @param p_Freight_Code_Comb_Id_tbl Table of Freight Code Combination Ids for Inter company relation
 * @param p_Inv_Currency_Code_tbl Table of currency code for Inter company relation
 * @param p_IC_COGS_Acct_Id_tbl  Table of COGS account ids for Inter company relation
 * @param p_Inv_Accrual_Acct_Id_tbl Table of accrual account Ids for Inter company relation
 * @param p_Exp_Accrual_Acct_Id_tbl Table of expense accrual account Ids  for Inter company relation
 * @rep:displayname Update Inter Company Transaction Flow
*/
PROCEDURE update_transaction_flow
(
  x_return_status		           OUT NOCOPY 	   VARCHAR2
, x_msg_data			           OUT NOCOPY 	   VARCHAR2
, x_msg_count			           OUT NOCOPY 	   NUMBER
, p_api_version                 IN              NUMBER
, p_init_msg_list               IN              VARCHAR2
, p_validation_level		        IN		         NUMBER
, p_header_id                   IN              NUMBER
, p_flow_type                   IN              NUMBER
, p_start_date                  IN              DATE
, p_end_date                    IN              DATE
, P_Attribute_Category          IN              VARCHAR2
, P_Attribute1                  IN              VARCHAR2
, P_Attribute2                  IN              VARCHAR2
, P_Attribute3                  IN              VARCHAR2
, P_Attribute4                  IN              VARCHAR2
, P_Attribute5                  IN              VARCHAR2
, P_Attribute6                  IN              VARCHAR2
, P_Attribute7                  IN              VARCHAR2
, P_Attribute8                  IN              VARCHAR2
, P_Attribute9                  IN              VARCHAR2
, P_Attribute10                 IN              VARCHAR2
, P_Attribute11                 IN              VARCHAR2
, P_Attribute12                 IN              VARCHAR2
, P_Attribute13                 IN              VARCHAR2
, P_Attribute14                 IN              VARCHAR2
, P_Attribute15                 IN              VARCHAR2
, p_line_number_tbl		        IN	            NUMBER_TBL
, P_LINE_Attribute_Category_tbl IN              VARCHAR2_tbl
, P_LINE_Attribute1_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute2_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute3_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute4_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute5_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute6_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute7_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute8_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute9_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute10_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute11_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute12_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute13_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute14_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute15_tbl        IN              VARCHAR2_tbl
, P_Ship_Organization_Id_tbl    IN              NUMBER_tbl
, P_Sell_Organization_Id_tbl    IN              NUMBER_tbl
, P_Vendor_Id_tbl               IN              NUMBER_tbl
, P_Vendor_Site_Id_tbl          IN              NUMBER_tbl
, P_Customer_Id_tbl             IN              NUMBER_tbl
, P_Address_Id_tbl              IN              NUMBER_tbl
, P_Customer_Site_Id_tbl        IN              NUMBER_tbl
, P_Cust_Trx_Type_Id_tbl        IN              NUMBER_tbl
, P_IC_Attribute_Category_tbl   IN              VARCHAR2_tbl
, P_IC_Attribute1_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute2_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute3_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute4_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute5_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute6_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute7_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute8_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute9_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute10_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute11_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute12_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute13_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute14_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute15_tbl          IN              VARCHAR2_tbl
, P_Revalue_Average_Flag_tbl    IN              VARCHAR2_tbl
, P_Freight_Code_Comb_Id_tbl    IN              NUMBER_tbl
, p_inv_currency_code_tbl	     IN	            NUMBER_tbl
, P_IC_COGS_Acct_Id_tbl         IN              NUMBER_tbl
, P_Inv_Accrual_Acct_Id_tbl     IN              NUMBER_tbl
, P_Exp_Accrual_Acct_Id_tbl     IN              NUMBER_tbl
) ;


   /*#
 * This procedure is used to update an intercompany transaction flow header.
 * Once a transaction flow is created, a user can only
 * update the start date and the end date on the header.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_header_id Transaction flow header
 * @param p_start_date The date when the Inter-company Transaction Flow become active.
 * @param p_end_date The date when the when Inter-company Transaction Flow become inactive.
 * @param p_Attribute_Category Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute1 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute2 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute3 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute4 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute5 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute6 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute7 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute8 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute9 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute10 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute11 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute12 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute13 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute14 Flexfield Attribute for Transaction Flow Header
 * @param p_Attribute15 Flexfield Attribute for Transaction Flow Header
 * @rep:displayname Update Inter Company Transaction Flow Header
*/
   PROCEDURE update_transaction_flow_header
   (X_return_status	    OUT NOCOPY	VARCHAR2
    , x_msg_data	    OUT NOCOPY	VARCHAR2
    , x_msg_count	    OUT NOCOPY	NUMBER
    , p_api_version         IN          NUMBER
    , p_init_msg_list       IN          VARCHAR2 DEFAULT G_FALSE
    , p_header_id	    IN		NUMBER
    , p_end_date	    IN		DATE
    , p_start_date	    IN		DATE
    , P_Attribute_Category  IN          VARCHAR2
    , P_Attribute1          IN          VARCHAR2
    , P_Attribute2          IN          VARCHAR2
    , P_Attribute3          IN          VARCHAR2
    , P_Attribute4          IN          VARCHAR2
    , P_Attribute5          IN          VARCHAR2
    , P_Attribute6          IN          VARCHAR2
    , P_Attribute7          IN          VARCHAR2
    , P_Attribute8          IN          VARCHAR2
    , P_Attribute9          IN          VARCHAR2
    , P_Attribute10         IN          VARCHAR2
    , P_Attribute11         IN          VARCHAR2
    , P_Attribute12         IN          VARCHAR2
   , P_Attribute13          IN          VARCHAR2
   , P_Attribute14          IN          VARCHAR2
   , P_Attribute15          IN          VARCHAR2);

/*#
 * This procedure is used to update an intercompany transaction flow line.  A
 * User can only update the flexfield attributes on the line.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_header_id Transaction flow header
 * @param p_line_number Transaction flow line number
 * @param p_Attribute_Category Flexfield Attribute for Transaction Flow line
 * @param p_Attribute1 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute2 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute3 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute4 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute5 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute6 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute7 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute8 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute9 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute10 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute11 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute12 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute13 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute14 Flexfield Attribute for Transaction Flow line
 * @param p_Attribute15 Flexfield Attribute for Transaction Flow line
 * @rep:displayname Update Inter Company Transaction Flow line
*/
   PROCEDURE update_transaction_flow_line
   (x_return_status          OUT NOCOPY VARCHAR2
    , x_msg_data             OUT NOCOPY VARCHAR2
    , x_msg_count            OUT NOCOPY VARCHAR2
    , p_api_version         IN          NUMBER
    , p_init_msg_list       IN          VARCHAR2 DEFAULT G_FALSE
    , p_header_id            IN         NUMBER
    , p_line_number              IN     NUMBER
    , p_attribute_category  IN     VARCHAR2
    , p_attribute1          IN     VARCHAR2
    , p_attribute2          IN     VARCHAR2
    , p_attribute3          IN     VARCHAR2
    , p_attribute4          IN     VARCHAR2
    , p_attribute5          IN     VARCHAR2
    , p_attribute6          IN     VARCHAR2
    , p_attribute7          IN     VARCHAR2
    , p_attribute8          IN     VARCHAR2
    , p_attribute9          IN     VARCHAR2
    , p_attribute10         IN     VARCHAR2
    , p_attribute11         IN     VARCHAR2
    , p_attribute12         IN     VARCHAR2
    , p_attribute13         IN     VARCHAR2
    , p_attribute14         IN     VARCHAR2
    , p_attribute15         IN     VARCHAR2
    );

 /*#
 * This procedure is used to update the intercompany relation information
 *  between two operating units.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_Ship_Organization_Id shipping organization
 * @param p_Sell_Organization_Id selling organization
 * @param p_vendor_id vendor id
 * @param p_Vendor_Site_Id vendor site id
 * @param p_Customer_Id customer id
 * @param p_Address_Id address id
 * @param p_Customer_Site_Id customer site id
 * @param p_Cust_Trx_Type_Id customer transaction type id
 * @param p_Attribute_Category Flexfield Attribute for Inter-company relation
 * @param p_Attribute1 Flexfield Attribute for Inter-company relation
 * @param p_Attribute2 Flexfield Attribute for Inter-company relation
 * @param p_Attribute3 Flexfield Attribute for Inter-company relation
 * @param p_Attribute4 Flexfield Attribute for Inter-company relation
 * @param p_Attribute5 Flexfield Attribute for Inter-company relation
 * @param p_Attribute6 Flexfield Attribute for Inter-company relation
 * @param p_Attribute7 Flexfield Attribute for Inter-company relation
 * @param p_Attribute8 Flexfield Attribute for Inter-company relation
 * @param p_Attribute9 Flexfield Attribute for Inter-company relation
 * @param p_Attribute10 Flexfield Attribute for Inter-company relation
 * @param p_Attribute11 Flexfield Attribute for Inter-company relation
 * @param p_Attribute12 Flexfield Attribute for Inter-company relation
 * @param p_Attribute13 Flexfield Attribute for Inter-company relation
 * @param p_Attribute14 Flexfield Attribute for Inter-company relation
 * @param p_Attribute15 Flexfield Attribute for Inter-company relation
 * @param p_Revalue_Average_Flag Revalue average flag for Inter-company relation
 * @param p_Freight_Code_Combination_Id Freight Code Combination Id for Inter company relation
 * @param p_Inv_Currency_Code currency code for Inter-company relation
 * @param p_flow_type indicate whether this is used for Global Procurement flow or Drop Ship flow
 * @param p_Intercompany_COGS_Account_Id  COGS account id for Inter-company relation
 * @param p_Inventory_Accrual_Account_Id accrual account Id for Inter company relation
 * @param p_Expense_Accrual_Account_Id expense accrual account Id for Inter company relation
 * @rep:displayname Update Inter-company relation
 */
 PROCEDURE update_ic_relation
   (x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY VARCHAR2,
    p_api_version                 IN   NUMBER,
    p_init_msg_list               IN   VARCHAR2 DEFAULT g_false,
    p_Ship_Organization_Id        IN   NUMBER,
    p_Sell_Organization_Id        IN   NUMBER,
    p_Vendor_Id                   IN   NUMBER,
    p_Vendor_Site_Id              IN   NUMBER,
    p_Customer_Id                 IN   NUMBER,
    p_Address_Id                  IN   NUMBER,
    p_Customer_Site_Id            IN   NUMBER,
    p_Cust_Trx_Type_Id            IN   NUMBER,
    p_Attribute_Category          IN   VARCHAR2,
    p_Attribute1                  IN   VARCHAR2,
    p_Attribute2                  IN   VARCHAR2,
    p_Attribute3                  IN   VARCHAR2,
    p_Attribute4                  IN   VARCHAR2,
    p_Attribute5                  IN   VARCHAR2,
    p_Attribute6                  IN   VARCHAR2,
    p_Attribute7                  IN   VARCHAR2,
    p_Attribute8                  IN   VARCHAR2,
    p_Attribute9                  IN   VARCHAR2,
   p_Attribute10                  IN   VARCHAR2,
   p_Attribute11                  IN   VARCHAR2,
   p_Attribute12                  IN   VARCHAR2,
   p_Attribute13                  IN   VARCHAR2,
   p_Attribute14                  IN   VARCHAR2,
   p_Attribute15                  IN   VARCHAR2,
   p_Revalue_Average_Flag         IN   VARCHAR2,
   p_Freight_Code_Combination_Id  IN   NUMBER,
   p_inv_currency_code		  IN   NUMBER,
   p_Flow_Type                    IN   NUMBER,
   p_Intercompany_COGS_Account_Id IN   NUMBER,
   p_Inventory_Accrual_Account_Id IN   NUMBER,
   p_Expense_Accrual_Account_Id   IN   NUMBER
   );

 /*#
 * This procedure is used to validate the intercompany relations information
 * for two operating units.
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_valid return variable indicating if all the information is valid
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_Ship_Organization_Id shipping organization
 * @param p_Sell_Organization_Id selling organization
 * @param p_vendor_id vendor id
 * @param p_Vendor_Site_Id vendor site id
 * @param p_Customer_Id customer id
 * @param p_Address_Id address id
 * @param p_Customer_Site_Id customer site id
 * @param p_Cust_Trx_Type_Id customer transaction type id
 * @param p_Attribute_Category Flexfield Attribute for Inter-company relation
 * @param p_Attribute1 Flexfield Attribute for Inter-company relation
 * @param p_Attribute2 Flexfield Attribute for Inter-company relation
 * @param p_Attribute3 Flexfield Attribute for Inter-company relation
 * @param p_Attribute4 Flexfield Attribute for Inter-company relation
 * @param p_Attribute5 Flexfield Attribute for Inter-company relation
 * @param p_Attribute6 Flexfield Attribute for Inter-company relation
 * @param p_Attribute7 Flexfield Attribute for Inter-company relation
 * @param p_Attribute8 Flexfield Attribute for Inter-company relation
 * @param p_Attribute9 Flexfield Attribute for Inter-company relation
 * @param p_Attribute10 Flexfield Attribute for Inter-company relation
 * @param p_Attribute11 Flexfield Attribute for Inter-company relation
 * @param p_Attribute12 Flexfield Attribute for Inter-company relation
 * @param p_Attribute13 Flexfield Attribute for Inter-company relation
 * @param p_Attribute14 Flexfield Attribute for Inter-company relation
 * @param p_Attribute15 Flexfield Attribute for Inter-company relation
 * @param p_Revalue_Average_Flag Revalue average flag for Inter-company relation
 * @param p_Freight_Code_Combination_Id Freight Code Combination Id for Inter company relation
 * @param p_Inv_Currency_Code currency code for Inter-company relation
 * @param p_flow_type indicate whether this is used for Global Procurement flow or Drop Ship flow
 * @param p_Intercompany_COGS_Account_Id  COGS account id for Inter-company relation
 * @param p_Inventory_Accrual_Account_Id accrual account Id for Inter company relation
 * @param p_Expense_Accrual_Account_Id expense accrual account Id for Inter company relation
 * @rep:displayname Validate Inter-company relation
 */
 PROCEDURE validate_ic_relation_rec
   (x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY VARCHAR2,
    x_valid                  OUT NOCOPY VARCHAR2,
    p_api_version                 IN   NUMBER,
    p_init_msg_list               IN   VARCHAR2 DEFAULT g_false,
    p_Ship_Organization_Id        IN   NUMBER,
    p_Sell_Organization_Id        IN   NUMBER,
    p_Vendor_Id                   IN   NUMBER,
    p_Vendor_Site_Id              IN   NUMBER,
    p_Customer_Id                 IN   NUMBER,
    p_Address_Id                  IN   NUMBER,
    p_Customer_Site_Id            IN   NUMBER,
    p_Cust_Trx_Type_Id            IN   NUMBER,
    p_Attribute_Category          IN   VARCHAR2,
    p_Attribute1                  IN   VARCHAR2,
    p_Attribute2                  IN   VARCHAR2,
    p_Attribute3                  IN   VARCHAR2,
    p_Attribute4                  IN   VARCHAR2,
    p_Attribute5                  IN   VARCHAR2,
    p_Attribute6                  IN   VARCHAR2,
   p_Attribute7                  IN   VARCHAR2,
   p_Attribute8                  IN   VARCHAR2,
   p_Attribute9                  IN   VARCHAR2,
   p_Attribute10                  IN   VARCHAR2,
   p_Attribute11                  IN   VARCHAR2,
   p_Attribute12                  IN   VARCHAR2,
   p_Attribute13                  IN   VARCHAR2,
   p_Attribute14                  IN   VARCHAR2,
   p_Attribute15                  IN   VARCHAR2,
   p_Revalue_Average_Flag         IN   VARCHAR2,
   p_Freight_Code_Combination_Id  IN   NUMBER,
   p_inv_currency_code	          IN   NUMBER,
   p_Flow_Type                    IN   NUMBER,
   p_Intercompany_COGS_Account_Id IN   NUMBER,
   p_Inventory_Accrual_Account_Id IN   NUMBER,
   p_Expense_Accrual_Account_Id   IN   NUMBER
   );

/*==========================================================================================================
 * Package: INV_TRANSACTION_FLOW_PUB
 *
 * Procedure: GET_DROPSHIP_PO_TRANSACTION_TYPE
 *
 * Description:
 * This API gets the drop ship transaction type code for a drop ship or global procurement flow.
 * This API will be called by Oracle Receiving  as well as Oracle Costing
 *
 * Inputs:
 * - 	p_po_line_location_id  - the Purchase Order LIne Location
 * -	p_global_procurement_flag - a flag to indicate whether the flow is global procurement flow
 *
 * Outputs:
 * - x_ds_type_code  - the drop ship transaction type code. The possible value for this are:
 *      1 - Drop Ship flow and logical
 *      2 - Drop Ship Flow and physical
 *      3 - Not a Drop Ship Flow and Physical
 * - x_header_id    - Transaction Flow Header Identifier
 * - x_return_Status -  the return status
 * - x_msg_data - the error message
 * - x_msg_count - the message count
 *============================================================================================================*/
/*#
 * This API gets the drop ship transaction type code for a drop ship or global procurement flow.
 * This API will be called by Oracle Receiving  as well as Oracle Costing
 * @param p_api_version API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_rcv_transaction_id rcv_transaction_id from rcv_transactions table for the receipt
 * @param p_global_procurement_flag pass 'Y' for a global procurement flow
 * @param x_return_status return variable holding the status of the procedure call
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_msg_data return variable holding the error message
 * @param x_transaction_type_id return variable indicating Inventory transaction type id
 * @param x_transaction_action_id return variable indicating Inventory transaction action id
 * @param x_transaction_source_type_id return variable indicating Inventory transaction source type id
 * @param x_dropship_type_code return  1 - Drop Ship flow and logical, 2 - Drop Ship Flow and physical, 3 - Not a Drop Ship Flow and Physical
 * @param x_header_id return variable holding Transaction Flow Header Id found
 * @rep:scope internal
 * @rep:displayname Get Dropship Transaction type
 */
Procedure Get_Dropship_PO_Txn_type
(
  p_api_version			IN  	   NUMBER
, p_init_msg_list               IN         VARCHAR2 default G_FALSE
, p_rcv_transaction_id		IN	   NUMBER
, p_global_procurement_flag	IN	   VARCHAR2
, x_return_Status		OUT NOCOPY VARCHAR2
, x_msg_data			OUT NOCOPY VARCHAR2
, x_msg_count			OUT NOCOPY NUMBER
, x_transaction_type_id		OUT NOCOPY NUMBER
, x_transaction_action_id	OUT NOCOPY NUMBER
, x_transaction_Source_type_id  OUT NOCOPY NUMBER
, x_dropship_type_code		OUT NOCOPY NUMBER
, x_header_id                   OUT NOCOPY NUMBER
);


/*================================================================================================
 * Package : INV_TRANSACTION_FLOW_PUB
 *
 * Function: Convert_Currency();
 *
 * Description: This function is to convert the transfer price to the functional currency of
 * 	        a given OU. It will also returns the functional currency of that OU.
 *
 * Input Parameters:
 *	1. p_org_id 	- The operating unit to which functional currency will be converted
 *	2. p_transfer_price - the transfer price to be converted
 *	3. p_currency_code - the currency code to be converted to functional currency
 *	4. Transaction date - the date to be used to get the conversion rate
 *
 * Output Parameter:
 *	1. transfer price in functional currency
 *	2. functional currency of the given OU
 *	3. x_return_status - return status
 *	4. x_msg_data	- error message
 *	5. x_msg_count - number of message in the message stack
 *
 *================================================================================================*/


FUNCTION convert_currency (
          p_org_id              IN NUMBER
        , p_transfer_price      IN NUMBER
        , p_currency_code       IN VARCHAR2
        , p_transaction_date    IN DATE
        , p_logical_txn         IN VARCHAR2 DEFAULT 'N' /* bug 6696446 */
        , x_functional_currency_code OUT NOCOPY VARCHAR2
        , x_return_status       OUT NOCOPY VARCHAR2
        , x_msg_data            OUT NOCOPY VARCHAR2
        , x_msg_count           OUT NOCOPY NUMBER
) RETURN NUMBER;


/*==========================================================================================================
 * Package: INV_TRANSACTION_FLOWS_PUB
 *
 * Procedure: GET_TRANSFER_PRICE_FOR_ITEM
 *
 * Description:
 * This API gets the transfer price in the transaction UOM using the following defaulting mechanism:
 * 1.	list price at transaction UOM I established transfer price list
 * 2.	Transaction cost of shipment transaction.
 * This API will be called by Oracle Inventory as well as Oracle CTO for CTO item
 *
 * Inputs:
 * - 	From_Org_ID - the start operating unit
 * -	To_Org_Id - The End operating Unit
 * -	Transaction_UOM - the transaction units of meassure
 * -	Invenotry_Item_ID - the inventory item identifier
 * -	Transaction ID - the logical transaction id
 * -	price_list_id - the static price list id.
 * -    global_procurement_flag - the flag to indicate if the flow is for global procurement
 * -    drop ship flag - the flag to indicate if the flow used is for external drop ship with
 *	procurement flag.
 *
 *
 * Outputs:
 * - x_transfer_price - the unit transfer price of the item
 * - x_currency_code - the currency code of the transfer price
 * - x_return_Status -  the return status
 * - x_msg_data - the error message
 * - x_msg_count - the message count
 *============================================================================================================*/
Procedure get_transfer_price_for_item
(
  x_return_status	OUT NOCOPY	VARCHAR2
, x_msg_data		OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_transfer_price	OUT NOCOPY	NUMBER
, x_currency_code	OUT NOCOPY	VARCHAR2
, p_api_version             IN          NUMBER
, p_init_msg_list           IN          VARCHAR2 default G_FALSE
, p_from_org_id		    IN		NUMBER
, p_to_org_id		    IN		NUMBER
, p_transaction_uom	    IN		VARCHAR2
, p_inventory_item_id	    IN		NUMBER
, p_transaction_id	    IN 		NUMBER
, p_from_organization_id    IN		NUMBER DEFAULT NULL
, p_price_list_id	    IN		NUMBER
, p_global_procurement_flag IN		VARCHAR2
, p_drop_ship_flag	    IN		VARCHAR2 DEFAULT 'N'
, p_cto_item_flag	    IN          VARCHAR2 DEFAULT 'N'
-- , p_process_discrete_xfer_flag IN       VARCHAR2 DEFAULT 'N'    -- Bug  4750256
, p_order_line_id           IN          VARCHAR2 DEFAULT  NULL -- Bug 5171637/5138311 umoogala: replaced above line with this one.
);

/*==========================================================================================================
 * Procedure: GET_TRANSFER_PRICE
 *
 * Description:
 * This API is wrapper API to the Get_Transfer_Price API.
 * This API will be called by Oracle Inventory Create_logical_transaction API
 * as well as Oracle Costing.
 * This API will be called with transaction_uom as : PO UOM or SO UOM, whichever is applicable.
 * The API will return the transfer_price in the Transaction_UOM that was passed to it.
 * The currency of the price will be the currency set in the price list.
 * The calling program will take care of appropriate conversions of UOM and currency.
 *
 * Inputs:
 * - 	From_Org_ID - the start operating unit
 * -	To_Org_Id - The End operating Unit
 * -	Transaction UOM - the units of meassure
 * -	Invenotry_Item_ID - the inventory item identifier
 * -    Transaction ID - the inventory transaction ID
 * -	price_list_id - the static price list id.
 * -    global_procurement_flag - the flag to indicate if the flow is for global procurement
 * -    drop ship flag - the flag to indicate if the flow used is for external drop ship with
 *	procurement flag.
 *
 * Outputs:
 * - 	x_transfer_price  - The total price for the item.
 *	If there are no pricelist found, then return 0
 * -	x_currency_code - the currency code of the transfer price
 * - 	x_return_status -  the return status - S - success, E - Error, U - Unexpected Error
 * - 	x_msg_data - the error message
 * - 	x_msg_count - the number of messages in the message stack.
 *==========================================================================================================*/

PROCEDURE Get_Transfer_Price
(
  x_return_status	OUT NOCOPY 	VARCHAR2
, x_msg_data		OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_transfer_price	OUT NOCOPY	NUMBER
, x_currency_code	OUT NOCOPY	VARCHAR2
, x_incr_transfer_price  OUT NOCOPY 	NUMBER
, x_incr_currency_code   OUT NOCOPY      VARCHAR2
, p_api_version             IN          NUMBER
, p_init_msg_list           IN          VARCHAR2 default G_FALSE
, p_from_org_id		    IN		NUMBER
, p_to_org_id		    IN 		NUMBER
, p_transaction_uom	    IN		VARCHAR2
, p_inventory_item_id	    IN		NUMBER
, p_transaction_id	    IN		NUMBER
, p_from_organization_id    IN          NUMBER DEFAULT NULL
, p_global_procurement_flag IN 		VARCHAR2
, p_drop_ship_flag	    IN		VARCHAR2 DEFAULT 'N'
-- , p_process_discrete_xfer_flag IN       VARCHAR2 DEFAULT 'N'    -- Bug  4750256
, p_order_line_id           IN          VARCHAR2 DEFAULT  NULL -- Bug 5171637/5138311 umoogala: replaced above line with this one.
, p_txn_date                IN          DATE DEFAULT NULL  /* added for bug 8282784 */
);

/*==========================================================================================================
 * Function: GET_TRANSFER_PRICE_DATE();
 *
 * Description: This function is to get the date by which the transfer price for the item will be queried from Transfer Price List
 *                        This function retrieve the date according to value of profile "INV: Intercompany Transfer Price Date".
 *	                   i) Profile set to 'ORDER DATE'
 *	                        a) Shipping flow-  function returns order line pricing date
 *	                        b) Procurement flow-  function returns Purchase Order Approved date.
 *                         ii) Profile set to 'CURRENT DATE', function returns sysdate
 *
 * Input Parameters:
 *      1. p_call                         -  Determines from where this function is called
 *                                                  I - Called from internal procedure or function of INV_TRANSACTION_FLOW_PUB
 *                                                  E - Called from any external procedure or function
 *	2. p_order_line_id 	 -  SO line id for Shipping flow and PO line id for purchasing flow
 *     3. p_global_procurement_flag
 *	4. p_transaction_id      -  This is not required when called from external procedure/function
 *	5. p_drop_ship_flag     - default is N
 *
 * Output Parameter:
 *	1. x_return_status - return status
 *	2. x_msg_data	- error message
 *	3. x_msg_count - number of message in the message stack
 *
 *   It returns a date value
 * Note -   Function is added as a part of changes done in bug#6700919
 *==========================================================================================================*/
FUNCTION get_transfer_price_date(
   p_call                                         IN VARCHAR2
 , p_order_line_id                       IN NUMBER
 , p_global_procurement_flag IN VARCHAR2
 , p_transaction_id                     IN NUMBER  DEFAULT NULL
 , p_drop_ship_flag	               IN VARCHAR2 DEFAULT 'N'
 , x_return_status                       OUT NOCOPY VARCHAR2
 , x_msg_data                             OUT NOCOPY VARCHAR2
 , x_msg_count                           OUT NOCOPY NUMBER
) RETURN DATE;

end INV_TRANSACTION_FLOW_PUB;

/
