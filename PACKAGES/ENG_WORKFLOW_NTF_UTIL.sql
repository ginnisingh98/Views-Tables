--------------------------------------------------------
--  DDL for Package ENG_WORKFLOW_NTF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_WORKFLOW_NTF_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUNTFS.pls 120.2 2006/02/18 20:08:19 mkimizuk noship $ */


-- Message Attribute Record
TYPE Change_Mesg_Attribute_Rec_Type IS RECORD
(
  item_type                  VARCHAR2(8)
 ,item_key                   VARCHAR2(240)
 ,notification_id            NUMBER
 ,wf_msg_name                VARCHAR2(30)
 ,change_id                  NUMBER
 ,change_line_id             NUMBER
 ,change_notice              VARCHAR2(10)
 ,organization_id            NUMBER
 ,organization_code          VARCHAR2(3)
 ,item_organization_id       NUMBER
 ,item_id                    NUMBER
 ,item_name                  VARCHAR2(800)
 ,item_revision_id           NUMBER
 ,item_revision              VARCHAR2(3)
 ,item_revision_label        VARCHAR2(80)
 ,change_management_type     VARCHAR2(40)
 ,change_name                VARCHAR2(240)
 ,description                VARCHAR2(3000)
 ,change_order_type          VARCHAR2(10)
 ,organization_name          VARCHAR2(60)
 ,eco_department             VARCHAR2(60)
 ,change_status              VARCHAR2(80)
 ,approval_status            VARCHAR2(80)
 ,priority                   VARCHAR2(50)
 ,reason                     VARCHAR2(50)
 ,assignee                   VARCHAR2(360)
 ,assignee_company           VARCHAR2(360)
 ,line_sequence_number       NUMBER
 ,line_name                  VARCHAR2(240)
 ,line_description           VARCHAR2(5000)
 ,line_status                VARCHAR2(80)
 ,line_assignee              VARCHAR2(360)
 ,line_assignee_company      VARCHAR2(360)
 ,action_id                  NUMBER
 ,action_party_id            NUMBER
 ,action_party_name          VARCHAR2(360)
 ,action_party_company       VARCHAR2(360)
 ,action_desc                VARCHAR2(5000)
 ,route_id                   NUMBER
 ,step_id                    NUMBER
 ,step_seq_num               NUMBER
 ,required_date              DATE
 ,condition_type             VARCHAR2(80)
 ,step_instruction           VARCHAR2(5000)
 ,host_url                   VARCHAR2(480)
 ,style_sheet                VARCHAR2(100)
);



--  API name   : GetMessageTextBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf text message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
PROCEDURE GetMessageTextBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY  CLOB
 , document_type  IN OUT  NOCOPY  VARCHAR2
) ;


--  API name   : GetMessageHTMLBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf HTML message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
PROCEDURE GetMessageHTMLBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
) ;



FUNCTION GetRunFuncURL
( p_function_name     IN     VARCHAR2
, p_resp_appl_id      IN     NUMBER    DEFAULT NULL
, p_resp_id           IN     NUMBER    DEFAULT NULL
, p_security_group_id IN     NUMBER    DEFAULT NULL
, p_parameters        IN     VARCHAR2  DEFAULT NULL
) RETURN VARCHAR2 ;


FUNCTION GetChangeRunFuncURL
( p_change_id IN     NUMBER)
 RETURN VARCHAR2 ;

FUNCTION GetChangeSummaryRunFuncURL
( p_change_id IN     NUMBER)
 RETURN VARCHAR2 ;


PROCEDURE GetNtfRecipient
( p_notification_id  IN NUMBER
, x_party_id         OUT NOCOPY NUMBER
, x_party_name       OUT NOCOPY VARCHAR2
, x_user_id          OUT NOCOPY NUMBER
, x_user_name        OUT NOCOPY VARCHAR2
) ;


/*********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/
-- None

END Eng_Workflow_Ntf_Util ;

 

/
