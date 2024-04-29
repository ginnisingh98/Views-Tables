--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_GEN_ASSET_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_GEN_ASSET_LINES" AUTHID CURRENT_USER AS
--$Header: PAPGALCS.pls 120.3 2006/11/10 00:31:23 skannoji noship $
/*#
 * This extension enables you to define how Oracle Projects assigns asset lines to a task.process.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Asset Assignment
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this procedure define how asset lines are assigned to tasks.
 * @param p_project_id     Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id        Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_item_id  Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_id      Identifier of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_type  Expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_category Expenditure category
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_type_class Expenditure type class
 * @rep:paraminfo {@rep:required}
 * @param p_non_labor_org_id   Identifier of the organization for non-labor tasks
 * @rep:paraminfo {@rep:required}
 * @param p_non_labor_resource  Identifier of the organization for non-labor resources
 * @rep:paraminfo {@rep:required}
 * @param p_invoice_id       Identifier of the invoice
 * @rep:paraminfo {@rep:required}
 * @param p_inv_dist_line_number Invoice distribution line number
 * @rep:paraminfo {@rep:required}
 * @param p_vendor_id   Identifier of the supplier
 * @rep:paraminfo {@rep:required}
 * @param p_employee_id Identifier of the employee
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2   Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3    Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4    Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5     Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6     Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7    Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8     Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9      Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10     Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category    Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_in_service_through_date  Date through which the asset is in service
 * @rep:paraminfo {@rep:required}
 * @param x_asset_id     Identifier of the asset
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Client Asset Assignment
 * @rep:compatibility S
*/
PROCEDURE CLIENT_ASSET_ASSIGNMENT(p_project_id 	              IN NUMBER,
				  p_task_id                   IN NUMBER,
                                  p_expnd_item_id             IN NUMBER,
                                  p_expnd_id                  IN NUMBER,
                                  p_expnd_type                IN VARCHAR2,
                                  p_expnd_category            IN VARCHAR2,
                                  p_expnd_type_class          IN VARCHAR2,
                                  p_non_labor_org_id          IN NUMBER,
                                  p_non_labor_resource        IN VARCHAR2,
				  p_invoice_id                IN NUMBER,
                                  p_inv_dist_line_number      IN NUMBER,
                                  p_vendor_id                 IN NUMBER,
                                  p_employee_id               IN NUMBER,
                                  p_attribute1                IN VARCHAR2,
                                  p_attribute2                IN VARCHAR2,
                                  p_attribute3                IN VARCHAR2,
                                  p_attribute4                IN VARCHAR2,
                                  p_attribute5                IN VARCHAR2,
                                  p_attribute6                IN VARCHAR2,
                                  p_attribute7                IN VARCHAR2,
                                  p_attribute8                IN VARCHAR2,
                                  p_attribute9                IN VARCHAR2,
                                  p_attribute10               IN VARCHAR2,
                                  p_attribute_category        IN VARCHAR2,
                                  p_in_service_through_date   IN DATE,
                                  x_asset_id                  IN OUT NOCOPY NUMBER);
END;

 

/
