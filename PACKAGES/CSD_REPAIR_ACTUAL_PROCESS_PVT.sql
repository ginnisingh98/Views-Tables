--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ACTUAL_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ACTUAL_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: csdactps.pls 120.1 2008/05/23 23:12:34 swai ship $ csdactps.pls */
-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ACTUAL_PROCESS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdactps.pls';
G_MSG_MODULE_CODE_ACT CONSTANT VARCHAR2(5) := 'ACT';

/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Task                           */
/* description : Procedure is used to import Task debrief lines into  */
/*               repair actual lines. We only create links to         */
/*               existing charge lines for the debrief lines. The     */
/*               links are represented in repair actual lines table.  */
/*               No new charge lines are created.                     */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag - This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*--------------------------------------------------------------------*/

PROCEDURE Import_Actuals_From_Task
(
  p_api_version           IN           NUMBER,
  p_commit                IN           VARCHAR2,
  p_init_msg_list         IN           VARCHAR2,
  p_validation_level      IN           NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2,
  x_msg_count             OUT NOCOPY   NUMBER,
  x_msg_data              OUT NOCOPY   VARCHAR2,
  p_repair_line_id        IN           NUMBER,
  p_repair_actual_id      IN           NUMBER,
  x_warning_flag          OUT NOCOPY   VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Wip                            */
/* description : Procedure is used to import WIP debrief lines into   */
/*               repair actual lines. We consider material and        */
/*               resource transactions to create charge/repair actual */
/*               lines.                                               */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag - This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*--------------------------------------------------------------------*/

PROCEDURE Import_Actuals_From_Wip (
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2,
    p_init_msg_list         IN     VARCHAR2,
    p_validation_level      IN     NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2,
    p_repair_line_id        IN   NUMBER,
    p_repair_actual_id      IN   NUMBER,
    p_repair_type_id        IN   NUMBER,
    p_business_process_id   IN   NUMBER,
    p_currency_code         IN   VARCHAR2,
    p_incident_id           IN   NUMBER,
    p_organization_id       IN   NUMBER,
    x_warning_flag          OUT  NOCOPY VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: Import_Actuals_From_Estimate                       */
/* description : Procedure is used to import Estimates lines into     */
/*               repair actual lines. Creates new charge lines and    */
/*               corresponding repair actual lines.                   */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/*                                                                    */
/* x_warning_flag - This flag communicates to the calling procedure   */
/*                  whether there are any messages logged that can be */
/*                  displayed to the user. If the value is G_TRUE     */
/*                  then it indicates that one or more message have   */
/*                  been logged.                                      */
/*--------------------------------------------------------------------*/

PROCEDURE Import_Actuals_From_Estimate
(
  p_api_version           IN           NUMBER,
  p_commit                IN           VARCHAR2,
  p_init_msg_list         IN           VARCHAR2,
  p_validation_level      IN           NUMBER,
  x_return_status         OUT NOCOPY   VARCHAR2,
  x_msg_count             OUT NOCOPY   NUMBER,
  x_msg_data              OUT NOCOPY   VARCHAR2,
  p_repair_line_id        IN           NUMBER,
  p_repair_actual_id      IN           NUMBER,
  x_warning_flag          OUT NOCOPY   VARCHAR2
);

/*--------------------------------------------------------------------*/
/* procedure name: Convert_MLE_To_Actuals                             */
/* description : Procedure is used to convert table of records from   */
/*               MLE table format to repair actual lines format.      */
/*                                                                    */
/* Called from : Import_Actuals_From_Wip                              */
/*                                                                    */
/*--------------------------------------------------------------------*/

PROCEDURE Convert_MLE_To_Actuals ( p_MLE_lines_tbl    IN   CSD_CHARGE_LINE_UTIL. MLE_LINES_TBL_TYPE,
                                   p_repair_line_id   IN   NUMBER,
                                   p_repair_actual_id IN   NUMBER,
                                   x_actual_lines_tbl IN OUT NOCOPY CSD_REPAIR_ACTUAL_LINES_PVT.CSD_ACTUAL_LINES_TBL_TYPE
                                  );


/*--------------------------------------------------------------------*/
/* procedure name: Get_Default_Third_Party_Info                       */
/* description : Procedure is used to get the default bill and ship   */
/*               information from the repair actual header. If no     */
/*               header is found, defaults are gotten from the SR     */
/*                                                                    */
/* Called from : Get_Default_Third_Party_Info                         */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE Get_Default_Third_Party_Info (p_repair_line_id      IN      NUMBER,
                                        x_bill_to_account_id    OUT NOCOPY NUMBER,
                                        x_bill_to_party_id      OUT NOCOPY NUMBER,
                                        x_bill_to_party_site_id OUT NOCOPY NUMBER,
                                        x_ship_to_account_id    OUT NOCOPY NUMBER,
                                        x_ship_to_party_id      OUT NOCOPY NUMBER,
                                        x_ship_to_party_site_id OUT NOCOPY NUMBER
                             );


End CSD_REPAIR_ACTUAL_PROCESS_PVT;

/
