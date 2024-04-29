--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTEN_CIP_GROUPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTEN_CIP_GROUPING" AUTHID CURRENT_USER AS
/* $Header: PAXGCES.pls 120.5 2007/02/06 09:30:20 rshaik ship $ */
/*#
 * You can use this extension to define a unique method that your company uses to specify how expenditure lines are grouped
 * to form asset lines.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname CIP Grouping
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this function to define how expenditures lines are grouped to form asset lines.
 * @return Returns the the method of grouping expenditure lines to form asset lines.
 * @param p_proj_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_item_id Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_id Identifier of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_type Identifier of the expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_category Identifier of the expenditure category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10  Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_transaction_source Transaction source
 * @rep:paraminfo {@rep:required}
 * @param p_ref2  System reference 2
 * @rep:paraminfo {@rep:required}
 * @param p_ref3  System reference 3
 * @rep:paraminfo {@rep:required}
 * @param p_ref4  System reference 4
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Client Grouping Method
 * @rep:compatibility S
*/
FUNCTION CLIENT_GROUPING_METHOD(    p_proj_id 	     IN PA_PROJECTS_ALL.project_id%TYPE,
      		                    p_task_id        IN PA_TASKS.task_id%TYPE,
                                    p_expnd_item_id  IN PA_EXPENDITURE_ITEMS_ALL.expenditure_item_id%TYPE,
                                    p_expnd_id       IN PA_EXPENDITURE_ITEMS_ALL.expenditure_id%TYPE,
                                    p_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
                                    p_expnd_category IN PA_EXPENDITURE_CATEGORIES.expenditure_category%TYPE,
				    p_attribute1     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute2     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute3     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute4     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute5     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute6     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute7     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute8     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute9     IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute10    IN PA_EXPENDITURE_ITEMS_ALL.attribute1%TYPE,
                                    p_attribute_category IN PA_EXPENDITURE_ITEMS_ALL.attribute_category%TYPE,
       	                            p_transaction_source IN PA_EXPENDITURE_ITEMS_ALL.transaction_source%TYPE,
                                    p_ref2           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference2%TYPE,  /*bug5454123-adding system_reference2,3,4*/
                                    p_ref3           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference3%TYPE,
                                    p_ref4           IN PA_COST_DISTRIBUTION_LINES_ALL.system_reference4%TYPE)
 return VARCHAR2;

 END PA_CLIENT_EXTEN_CIP_GROUPING;

/
