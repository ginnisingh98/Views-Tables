--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BURDEN_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BURDEN_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: PAXBRGCS.pls 120.2 2006/06/27 18:44:41 rahariha noship $ */
/*#
 * This extension is used to customize the summary criteria for creating the summary burden transactions.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Summary Burden Grouping Customization
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * Use this procedure to create Summary Burden transactions in such a way that, the summary burden transactions
 * and its source raw transactions are mapped to the same Planning Resource in order to report them correctly in the
 * context of a Resource Breakdown Structure.
 * @param p_job_id This contains a value if the resource is of JOB type. It contains job identifier of the source transaction.
 * @param p_non_labor_resource This contains a value if the resource is of NON_LABOR_RESOURCE type. This holds the non labor
 * resource name of the source transaction.
 * @param p_non_labor_resource_orgn_id Identifier of the organization of the resource of the source transaction.
 * @param p_wip_resource_id Identifier of the resource for work in progress of the source transaction.
 * @param p_incurred_by_person_id Identifier of the person who incurred the source transaction.
 * @param p_inventory_item_id This contains a value if the resource is of ITEM type. It contains the resource identifier of
 * the source transaction.
 * @param p_vendor_id The vendor identifier of the source transaction.
 * @param p_bom_equipment_resource_id Identifier for BOM equipment resource of the osurce transaction.
 * @param p_bom_labor_resource_id This contains a value if the resource is of BOM_LABOR type.It holds the selected resource
 * identifier of the source transaction.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Summary Burden Grouping - Resource
 * @rep:compatibility S
*/
  FUNCTION CLIENT_GROUPING
 ( p_job_id				IN       PA_EXPENDITURE_ITEMS_ALL.job_id%type DEFAULT NULL,
   p_non_labor_resource			IN       PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type DEFAULT NULL,
   p_non_labor_resource_orgn_id		IN       PA_EXPENDITURE_ITEMS_ALL.organization_id%type DEFAULT NULL,
   p_wip_resource_id			IN       PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type DEFAULT NULL,
   p_incurred_by_person_id           	IN       PA_EXPENDITURES_ALL.incurred_by_person_id%type DEFAULT NULL,
   p_inventory_item_id                  IN       PA_EXPENDITURE_ITEMS_ALL.inventory_item_id%type DEFAULT NULL,
   p_vendor_id                         	IN       PA_COMMITMENT_TXNS.vendor_id%type DEFAULT NULL,
   p_bom_equipment_resource_id  	IN       PA_COMMITMENT_TXNS.bom_equipment_resource_id%type DEFAULT NULL,
   p_bom_labor_resource_id          	IN       PA_COMMITMENT_TXNS.bom_labor_resource_id%type DEFAULT NULL
  ) RETURN varchar2 ;


/*#
 * Use this procedure in conjunction with the above Summary Burden Grouping - Resource. NULL out those parameters
 * that were not used for additional grouping in Summary Burden Grouping - Resource.
 * @param p_job_id This contains a value if the resource is of JOB type. It contains job identifier of the source transaction.
 * @param p_non_labor_resource This contains a value if the resource is of NON_LABOR_RESOURCE type. This holds the non labor
 * resource name of the source transaction.
 * @param p_non_labor_resource_orgn_id Identifier of the organization of the resource of the source transaction.
 * @param p_wip_resource_id Identifier of the resource for work in progress of the source transaction.
 * @param p_incurred_by_person_id Identifier of the person who incurred the source transaction.
 * @param p_inventory_item_id This contains a value if the resource is of ITEM type. It contains the resource identifier of
 * the source transaction.
 * @param p_vendor_id The vendor identifier of the source transaction.
 * @param p_bom_equipment_resource_id Identifier for BOM equipment resource of the osurce transaction.
 * @param p_bom_labor_resource_id This contains a value if the resource is of BOM_LABOR type.It holds the selected resource
 * identifier of the source transaction.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Client Column Values - Resource
 * @rep:compatibility S
*/
 PROCEDURE CLIENT_COLUMN_VALUES
 ( p_job_id                             IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.job_id%type,
   p_non_labor_resource               	IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.non_labor_resource%type,
   p_non_labor_resource_orgn_id   	IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.organization_id%type,
   p_wip_resource_id                    IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.wip_resource_id%type,
   p_incurred_by_person_id          	IN OUT NOCOPY       PA_EXPENDITURES_ALL.incurred_by_person_id%type,
   p_inventory_item_id                  IN OUT NOCOPY       PA_EXPENDITURE_ITEMS_ALL.inventory_item_id%type,
   p_vendor_id                          IN OUT NOCOPY       PA_COMMITMENT_TXNS.vendor_id%type,
   p_bom_equipment_resource_id  	IN OUT NOCOPY       PA_COMMITMENT_TXNS.bom_equipment_resource_id%type,
   p_bom_labor_resource_id          	IN OUT NOCOPY       PA_COMMITMENT_TXNS.bom_labor_resource_id%type
  );

END PA_CLIENT_EXTN_BURDEN_RESOURCE;

 

/
