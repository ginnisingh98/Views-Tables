--------------------------------------------------------
--  DDL for Package OE_CHG_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CHG_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCHGS.pls 120.1.12000000.1 2007/01/16 22:08:07 appldev ship $ */

--  Start of Comments
--  API name    OE_CHG_ORDER_PVT
--  Type        PRIVATE
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_CHG_ORDER_PVT';
G_USER_TEXT        VARCHAR2(2000);
G_ORDER_NUMBER     NUMBER;
G_ORDER_TYPE       VARCHAR2(150);


/* Procedure StartChgOrderProcess
** Usage    This procedure will launch a workflow as specified
**          in parameter p_workflow with item_key as p_wf_key_id
**          Any informations in table oe_line_pending_actions for
**          the given p_wf_key_id are reterived to populate workflow
**          Item attributes.
** Parameters
**          IN    p_workflow_process  Name of the workflow process to be started
**          IN    x_pending_rec pending request record type , this is used
**                to store the context information for workflow process
**          x_return_status      Procedure result falg
*/



PROCEDURE Start_ChangeOrderFlow
(   p_itemtype in varchar2
   ,p_itemkey  in varchar2
);


PROCEDURE Create_ChgOrderWorkItem
(
       p_Workflow_Process   IN VARCHAR2
     , p_resolving_role     IN VARCHAR2
     , p_resolving_name     IN VARCHAR2
     , p_user_text          IN VARCHAR2  );



/* Procedure Generate_PLSQLDoc - this is used to create
** a PL/SQL document type of an attribute for dynamic
** message body. The document buffer is aligned appropriately
** based on the display type for the notification
*/

PROCEDURE Generate_PLSQLDoc(p_document_id in varchar2,
                            p_display_type in varchar2,
                            p_document in out NOCOPY /* file.sql.39 change */ varchar2,
                            p_document_type in out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Update_User_Text(p_user_text in varchar2);

PROCEDURE Update_Order_Number(p_order_number in NUMBER);

/* Procedure RecordLinHist
** Inserts a line record and reason_code, comments in the history tables.
** p_histroy_type_code can be used to specify the activity for which the
** history trail was recorded. wf_activity_code, wf_result_code
** can be used to indicate the state of the line at which the history was
** recorded.
** Parameter
**     IN   p_line_id        Line for which the histroy is recorde
**     IN   p_line_rec       Line for which the histroy is recorded
**     IN   p_hist_type_code Code indentifying the acitivity for whihc the
**                           history record is generated
**     IN   p_reason_code    Reason code
**     IN   p_comments       Comments
**     IN   p_wf_activity_code p_wf_activity code and p_wf_result_code
**     IN   p_wf_result_code   determine the state of the line with respect to
**                             workflow at which the history was generatged.
*/
Procedure RecordLineHist
  (p_line_id          In Number
  ,p_line_rec         In OE_ORDER_PUB.LINE_REC_TYPE
               := OE_Order_PUB.G_MISS_LINE_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  );

/* Start Audit Trail */
Procedure RecordHeaderHist
  (p_header_id        In Number
  ,p_header_rec       In OE_ORDER_PUB.HEADER_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,p_changed_attribute IN VARCHAR2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2);

Procedure RecordHSCreditHist
  (p_header_scredit_id           In Number
  ,p_header_scredit_rec         In OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2);

Procedure RecordLSCreditHist
  (p_line_scredit_id          In Number
  ,p_line_scredit_rec         In OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE
               := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  );

Procedure RecordHPAdjHist
  (p_header_adj_id          In Number
  ,p_header_adj_rec         In OE_ORDER_PUB.HEADER_ADJ_REC_TYPE
               := OE_Order_PUB.G_MISS_HEADER_ADJ_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  );

Procedure RecordLPAdjHist
  (p_line_adj_id          In Number
  ,p_line_adj_rec         In OE_ORDER_PUB.LINE_ADJ_REC_TYPE
               := OE_Order_PUB.G_MISS_LINE_ADJ_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  );

-- Added to fix 2964593
PROCEDURE Reset_Audit_History_Flags;

/* End Audit Trail */

END;

 

/
