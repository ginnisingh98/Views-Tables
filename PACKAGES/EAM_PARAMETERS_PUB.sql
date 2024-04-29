--------------------------------------------------------
--  DDL for Package EAM_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PARAMETERS_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPPRMS.pls 120.1 2005/06/17 02:00:38 appldev  $ */
/*#
 * This package is used for the INSERT / UPDATE of Eam Parameters.
 * It defines 2 key procedures insert_parameters, update_parameters
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Eam Parameters
 * @rep:category BUSINESS_ENTITY EAM_PARAMETER
 */

/*#
 * This procedure is used to insert records in WIP_EAM_PARAMETERS.
 * It is used to create Eam Parameters.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_ORGANIZATION_ID Organization Identifier
 * @param p_WORK_REQUEST_AUTO_APPROVE Work Request Auto Approve Flag
 * @param p_DEF_MAINT_COST_CATEGORY Default Maintenance Cost Category
 * @param p_DEF_EAM_COST_ELEMENT_ID Default Cost Element Identifier
 * @param p_WORK_REQ_EXTENDED_LOG_FLAG Work Request Extended Log Flag
 * @param p_DEFAULT_EAM_CLASS Default EAM WIP Accounting Class
 * @param p_EASY_WORK_ORDER_PREFIX Easy Work Order Prefix
 * @param p_WORK_ORDER_PREFIX Work Order Prefix
 * @param p_SERIAL_NUMBER_ENABLED Flag to indicate Asset Number generated automatically
 * @param p_AUTO_FIRM_FLAG A flag to indicate auto firming of the work order upon release
 * @param p_MAINTENANCE_OFFSET_ACCOUNT Maintenance Offset Account
 * @param p_MATERIAL_ISSUE_BY_MO Enable Material Issue Requests
 * @param p_DEFAULT_DEPARTMENT_ID Default Department Identifier
 * @param p_INVOICE_BILLABLE_ITEMS_ONLY Whether you want to invoice billable materials only or any material.
 * @param P_OVERRIDE_BILL_AMOUNT Reserved for future
 * @param p_BILLING_BASIS Billing Basis: 1=Price List, 2=Cost Plus
 * @param p_BILLING_METHOD Billing Method: 1=Bill By Requirements, 2=Bill By Activity
 * @param P_DYNAMIC_BILLING_ACTIVITY Reserved for future
 * @param p_DEFAULT_ASSET_FLAG Whether to default asset number based on Property location assigned to the employee
 * @param p_PM_IGNORE_MISSED_WO Whether Preventive Maintenance Engine should generate past work orders.
 * @param p_issue_zero_cost_flag Whether to issue rebuildables at zero cost or item cost.
 * @param p_WORK_REQUEST_ASSET_NUM_REQD Flag to denote whether asset number is mandatory during work request creation or not
 * @param P_EAM_WO_WORKFLOW_ENABLED Stores whether any of the workflow events can be raised for this organization or not. 'Y' indicates the events can be raised, 'N'/Null indicates the events cannot be raised
 * @param P_AUTO_FIRM_ON_CREATE A flag to indicate auto firming of the job on creation
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Insert Eam Parameters
 */


PROCEDURE insert_parameters
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY 	NUMBER				,
	x_msg_data			OUT NOCOPY 	VARCHAR2			,

	P_ORGANIZATION_ID		IN	NUMBER		,
	P_WORK_REQUEST_AUTO_APPROVE	IN	VARCHAR2	default 'N',
	P_DEF_MAINT_COST_CATEGORY	IN	NUMBER		,
	P_DEF_EAM_COST_ELEMENT_ID	IN	NUMBER		,
	P_WORK_REQ_EXTENDED_LOG_FLAG	IN	VARCHAR2	default 'Y',
	P_DEFAULT_EAM_CLASS		IN	VARCHAR2  	,
	P_EASY_WORK_ORDER_PREFIX	IN	VARCHAR2	default null,
	P_WORK_ORDER_PREFIX		IN	VARCHAR2	default null,
	P_SERIAL_NUMBER_ENABLED		IN	VARCHAR2	default 'Y',
	P_AUTO_FIRM_FLAG		IN	VARCHAR2	default 'Y',
	P_MAINTENANCE_OFFSET_ACCOUNT	IN	NUMBER		default null,
	P_MATERIAL_ISSUE_BY_MO		IN	VARCHAR2	default 'Y',
	P_DEFAULT_DEPARTMENT_ID		IN	NUMBER		default null,
	P_INVOICE_BILLABLE_ITEMS_ONLY	IN	VARCHAR2	default 'N',
	P_OVERRIDE_BILL_AMOUNT		IN	VARCHAR2	default null,
	P_BILLING_BASIS			IN	NUMBER		default null,
	P_BILLING_METHOD		IN	NUMBER		default null,
	P_DYNAMIC_BILLING_ACTIVITY	IN	VARCHAR2	default null,
        P_DEFAULT_ASSET_FLAG     	IN	VARCHAR2	default 'Y' ,
	P_PM_IGNORE_MISSED_WO		IN 	VARCHAR2 	default 'N',
	p_issue_zero_cost_flag		IN 	VARCHAR2	default 'Y',
	p_WORK_REQUEST_ASSET_NUM_REQD   IN      VARCHAR2	default 'Y',
	P_EAM_WO_WORKFLOW_ENABLED	IN	VARCHAR2	default null,
	P_AUTO_FIRM_ON_CREATE		IN	VARCHAR2	default null
);

/*#
 * This procedure is used to update the existing records in WIP_EAM_PARAMETERS.
 * It is used to update Eam Parameters.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_ORGANIZATION_ID Organization Identifier
 * @param p_WORK_REQUEST_AUTO_APPROVE Work Request Auto Approve Flag
 * @param p_DEF_MAINT_COST_CATEGORY Default Maintenance Cost Category
 * @param p_DEF_EAM_COST_ELEMENT_ID Default Cost Element Identifier
 * @param p_WORK_REQ_EXTENDED_LOG_FLAG Work Request Extended Log Flag
 * @param p_DEFAULT_EAM_CLASS Default EAM WIP Accounting Class
 * @param p_EASY_WORK_ORDER_PREFIX Easy Work Order Prefix
 * @param p_WORK_ORDER_PREFIX Work Order Prefix
 * @param p_SERIAL_NUMBER_ENABLED Flag to indicate Asset Number generated automatically
 * @param p_AUTO_FIRM_FLAG A flag to indicate auto firming of the work order upon release
 * @param p_MAINTENANCE_OFFSET_ACCOUNT Maintenance Offset Account
 * @param p_MATERIAL_ISSUE_BY_MO Enable Material Issue Requests
 * @param p_DEFAULT_DEPARTMENT_ID Default Department Identifier
 * @param p_INVOICE_BILLABLE_ITEMS_ONLY Whether you want to invoice billable materials only or any material.
 * @param P_OVERRIDE_BILL_AMOUNT Reserved for future
 * @param p_BILLING_BASIS Billing Basis: 1=Price List, 2=Cost Plus
 * @param p_BILLING_METHOD Billing Method: 1=Bill By Requirements, 2=Bill By Activity
 * @param P_DYNAMIC_BILLING_ACTIVITY Reserved for future
 * @param p_DEFAULT_ASSET_FLAG Whether to default asset number based on Property location assigned to the employee
 * @param p_PM_IGNORE_MISSED_WO Whether Preventive Maintenance Engine should generate past work orders.
 * @param p_issue_zero_cost_flag Whether to issue rebuildables at zero cost or item cost.
 * @param p_WORK_REQUEST_ASSET_NUM_REQD Flag to denote whether asset number is mandatory during work request creation or not
 * @param P_EAM_WO_WORKFLOW_ENABLED Stores whether any of the workflow events can be raised for this organization or not. 'Y' indicates the events can be raised, 'N'/Null indicates the events cannot be raised
 * @param P_AUTO_FIRM_ON_CREATE A flag to indicate auto firming of the job on creation
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update Eam Parameters
 */


PROCEDURE update_parameters
(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN 	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,

	x_return_status			OUT NOCOPY 	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY 	NUMBER				,
	x_msg_data			OUT NOCOPY 	VARCHAR2			,

	P_ORGANIZATION_ID		IN	NUMBER		,
	P_WORK_REQUEST_AUTO_APPROVE	IN	VARCHAR2	default 'N',
	P_DEF_MAINT_COST_CATEGORY	IN	NUMBER		,
	P_DEF_EAM_COST_ELEMENT_ID	IN	NUMBER		,
	P_WORK_REQ_EXTENDED_LOG_FLAG	IN	VARCHAR2	default 'Y',
	P_DEFAULT_EAM_CLASS		IN	VARCHAR2  	,
	P_EASY_WORK_ORDER_PREFIX	IN	VARCHAR2	default null,
	P_WORK_ORDER_PREFIX		IN	VARCHAR2	default null,
	P_SERIAL_NUMBER_ENABLED		IN	VARCHAR2	default 'Y',
	P_AUTO_FIRM_FLAG		IN	VARCHAR2	default 'Y',
	P_MAINTENANCE_OFFSET_ACCOUNT	IN	NUMBER		default null,
	P_MATERIAL_ISSUE_BY_MO		IN	VARCHAR2	default 'Y',
	P_DEFAULT_DEPARTMENT_ID		IN	NUMBER		default null,
	P_INVOICE_BILLABLE_ITEMS_ONLY	IN	VARCHAR2	default 'N',
	P_OVERRIDE_BILL_AMOUNT		IN	VARCHAR2	default null,
	P_BILLING_BASIS			IN	NUMBER		default null,
	P_BILLING_METHOD		IN	NUMBER		default null,
	P_DYNAMIC_BILLING_ACTIVITY	IN	VARCHAR2	default null,
        P_DEFAULT_ASSET_FLAG     	IN	VARCHAR2	default 'Y' ,
	P_PM_IGNORE_MISSED_WO		IN 	VARCHAR2 	default 'N',
	p_issue_zero_cost_flag		IN 	VARCHAR2	default 'Y',
	p_WORK_REQUEST_ASSET_NUM_REQD   IN	VARCHAR2	default 'Y',
	P_EAM_WO_WORKFLOW_ENABLED	IN	VARCHAR2	default null,
	P_AUTO_FIRM_ON_CREATE		IN	VARCHAR2	default null
);

END;

 

/
