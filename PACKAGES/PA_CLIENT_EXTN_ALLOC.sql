--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_ALLOC" AUTHID CURRENT_USER AS
/* $Header: PAPALCCS.pls 120.2 2006/07/25 20:42:43 skannoji noship $ */
/*#
 * This extension contains procedures that define the source, target, offset, and basis for an allocation rule, to define
 * descriptive flexfields for allocation and to check dependencies.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Create Client Extension Allocation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

TYPE ALLOC_SOURCE_REC IS RECORD (
     PROJECT_ID               NUMBER ,
     TASK_ID                  NUMBER ,
     EXCLUDE_FLAG             VARCHAR2(1)
                              ) ;
TYPE ALLOC_SOURCE_TABTYPE IS TABLE OF ALLOC_SOURCE_REC
INDEX BY BINARY_INTEGER ;

TYPE ALLOC_TARGET_REC IS RECORD (
     PROJECT_ID               NUMBER ,
     TASK_ID                  NUMBER ,
     PERCENT                  NUMBER ,
     EXCLUDE_FLAG             VARCHAR2(1)
                              ) ;
TYPE ALLOC_TARGET_TABTYPE IS TABLE OF ALLOC_TARGET_REC
INDEX BY BINARY_INTEGER ;

TYPE ALLOC_OFFSET_REC IS RECORD (
     PROJECT_ID               NUMBER
,    TASK_ID                  NUMBER
,    OFFSET_AMOUNT            NUMBER
                              ) ;

TYPE ALLOC_OFFSET_TABTYPE IS TABLE OF ALLOC_OFFSET_REC
INDEX BY BINARY_INTEGER ;

/*#
 * You can use this extension to define source projects and tasks.
 *@param p_alloc_rule_id Identifier of the allocation rule
 *@rep:paraminfo {@rep:required}
 *@param x_source_proj_task_tbl Table defining source projects and tasks for each allocation rule. The index must be numbered sequentially from 1
 *@rep:paraminfo {@rep:required}
 *@param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 *@rep:paraminfo {@rep:required}
 *@param x_error_message Error message text
 *@rep:paraminfo {@rep:required}
 *@rep:scope public
 *@rep:lifecycle active
 *@rep:displayname Source Extension
 *@rep:compatibility S
*/
PROCEDURE source_extn( p_alloc_rule_id  IN NUMBER
                     , x_source_proj_task_tbl OUT NOCOPY ALLOC_SOURCE_TABTYPE
                     , x_status OUT NOCOPY NUMBER
                     , x_error_message OUT NOCOPY VARCHAR2 );

/*#
 * This procedure defines offset projects and tasks. For each allocation rule, you populate the global session variable
 * X_OFFSET_PROJ_TASK_TBL of data type table ALLOC_OFFSET_TABTYPE. The allocation run process reads the table to get the
 * offset project, task, and offset amount for the allocation run. The sum of offset amounts assigned to each offset
 * project and task equals the total offset amount (P_OFFSET_AMOUNT).
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param p_offset_amount The pool amount to be offset
 * @rep:paraminfo {@rep:required}
 * @param x_offset_proj_task_tbl Table defining offset information for each allocation rule. The index must be numbered sequentially from 1
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Offset Extension
 * @rep:compatibility S
*/
PROCEDURE offset_extn( p_alloc_rule_id IN NUMBER
                     , p_offset_amount IN NUMBER
                     , x_offset_proj_task_tbl OUT NOCOPY ALLOC_OFFSET_TABTYPE
                     , x_status OUT NOCOPY NUMBER
                     , x_error_message OUT NOCOPY VARCHAR2 );

/*#
 * This procedure defines offset tasks.
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param p_offset_project_id The offset project
 * @rep:paraminfo {@rep:required}
 * @param x_offset_task_id The offset task
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Offset Task Extension
 * @rep:compatibility S
*/
PROCEDURE offset_task_extn( p_alloc_rule_id     IN NUMBER
                          , p_offset_project_id IN NUMBER
                          , x_offset_task_id    OUT NOCOPY NUMBER
                          , x_status OUT NOCOPY NUMBER
                          , x_error_message OUT NOCOPY VARCHAR2 );

/*#
 * You can use this procedure to define amounts other than target costs for calculating the basis rate for target projects and tasks.
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the offset project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the offset task
 * @rep:paraminfo {@rep:required}
 * @param x_basis_amount The percentage of the pool amount allocated to this offset. (The sum of the basis amounts cannot equal zero.)
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Basis Extension
 * @rep:compatibility S
*/
PROCEDURE basis_extn( p_alloc_rule_id IN  NUMBER
                    , p_project_id    IN  NUMBER
                    , p_task_id       IN  NUMBER
                    , x_basis_amount  OUT NOCOPY NUMBER
                    , x_status         OUT NOCOPY NUMBER
                    , x_error_message OUT NOCOPY VARCHAR2 );

/*#
 * You can use this procedure to include or exclude projects or tasks temporarily when allocating amounts to target projects and tasks.
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param x_target_proj_task_tbl Table defining target projects and tasks for each allocation rule. The index must be numbered sequentially from 1
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Target Extension
 * @rep:compatibility S
*/
PROCEDURE target_extn( p_alloc_rule_id  IN NUMBER
                     , x_target_proj_task_tbl OUT NOCOPY ALLOC_TARGET_TABTYPE
                      , x_status OUT NOCOPY NUMBER
                     , x_error_message OUT NOCOPY VARCHAR2  );

/*#
 * You can use this procedure to define descriptive flexfields to be used when defining allocation rules.
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param p_run_id Identifier of the allocation run
 * @rep:paraminfo {@rep:required}
 * @param p_txn_type Type of transation: target transaction (T) or offset transaction (O)
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the offset project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the offset task
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_org The expenditure organization associated with the transaction
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_type_class The expenditure type class associated with the transaction
 * @rep:paraminfo {@rep:required}
 * @param p_expnd_type The expenditure type
 * @rep:paraminfo {@rep:required}
 * @param x_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param x_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transcation Descriptive Flexfield Extension
 * @rep:compatibility S
*/
PROCEDURE txn_dff_extn( p_alloc_rule_id    IN NUMBER
                       ,p_run_id           IN NUMBER
                       ,p_txn_type         IN VARCHAR2
                       ,p_project_id       IN VARCHAR2
                       ,P_task_id          IN VARCHAR2
                       ,p_expnd_org        IN VARCHAR2
                       ,p_expnd_type_class IN VARCHAR2
                       ,p_expnd_type       IN VARCHAR2
                       ,x_attribute_category OUT NOCOPY VARCHAR2
                       ,x_attribute1         OUT NOCOPY VARCHAR2
                       ,x_attribute2         OUT NOCOPY VARCHAR2
                       ,x_attribute3         OUT NOCOPY VARCHAR2
                       ,x_attribute4         OUT NOCOPY VARCHAR2
                       ,x_attribute5         OUT NOCOPY VARCHAR2
                       ,x_attribute6         OUT NOCOPY VARCHAR2
                       ,x_attribute7         OUT NOCOPY VARCHAR2
                       ,x_attribute8         OUT NOCOPY VARCHAR2
                       ,x_attribute9         OUT NOCOPY VARCHAR2
                       ,x_attribute10        OUT NOCOPY VARCHAR2
                       , x_status            OUT NOCOPY NUMBER
                       , x_error_message     OUT NOCOPY VARCHAR2
                     ) ;

/*#
 * You can use this procedure to verify compliance with the business rules of your choice.
 * @param p_alloc_rule_id Identifier of the allocation rule
 * @rep:paraminfo {@rep:required}
 * @param x_status  Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Dependency
 * @rep:compatibility S
*/
PROCEDURE check_dependency(p_alloc_rule_id IN NUMBER
                          , x_status       OUT NOCOPY NUMBER
                          , x_error_message  OUT NOCOPY VARCHAR2
                          ) ;
END PA_CLIENT_EXTN_ALLOC;

 

/
