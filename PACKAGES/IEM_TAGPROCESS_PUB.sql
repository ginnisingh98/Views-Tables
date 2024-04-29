--------------------------------------------------------
--  DDL for Package IEM_TAGPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TAGPROCESS_PUB" AUTHID CURRENT_USER AS
/* $Header: iemptags.pls 120.0 2005/06/02 14:06:50 appldev noship $ */

--
--
-- Purpose: Maintain Tag Process
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  3/24/2002    Created
--  Liang Xia  11/18/2002   Modified getEncryptId() to return null
--                          for Acknowledgement account.
--  Liang Xia  12/6/2002    Fixed GSCC warning: NOCOPY, no G_MISS...
--  Liang Xia  11/26/2004   115.11 schema compliance change.
-- ---------   ------  -----------------------------------------

-- Enter procedure, function bodies as shown below

/*GLOBAL VARIABLES AVAILABLE TO THE PUBLIC FOR CALLING
  ===================================================*/

G_PKG_NAME varchar2(255)    :='IEM_TAGPROCESS_PUB';

  TYPE keyVals_rec_type is RECORD (
    key     iem_route_rules.key_type_code%type,
    value   iem_route_rules.value%type,
    datatype varchar2(1));

  --Table of Key-Values
  TYPE keyVals_tbl_type is TABLE OF keyVals_rec_type INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    : getEncryptId
--  Type        : Public for eMail Center internal use
--  Function    : This procedure returns encrypted_id,which used in out bound email for tagging process
--
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE getEncryptId(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_email_account_id	      IN iem_mstemail_accounts.email_account_id%type,
        p_agent_id                IN NUMBER,
        p_interaction_id          IN NUMBER,
        p_biz_keyVal_tab          IN keyVals_tbl_type,
        x_encrypted_id	          OUT  NOCOPY VARCHAR2,
        x_msg_count   		      OUT  NOCOPY NUMBER,
        x_return_status  		  OUT  NOCOPY VARCHAR2,
        x_msg_data   			  OUT  NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : IEM_STAMP_ENCRYPTED_TAG
--  Type        : private
--  Function    : This procedure stamp message_id on the encrypted tag
--
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE IEM_STAMP_ENCRYPTED_TAG(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_encrypted_id	          IN NUMBER,
        p_message_id              IN NUMBER,
        x_msg_count   		      OUT NOCOPY NUMBER,
        x_return_status  		  OUT NOCOPY VARCHAR2,
        x_msg_data   			  OUT NOCOPY VARCHAR2);

 --  Start of Comments
--  API name    : getTagValues
--  Type        : Public for eMail Center internal use
--  Function    : This procedure returns tags in key-val format for a given encrypted_id.
--                Necessary security checking is performed before return key-val.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE getTagValues(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_encrypted_id            IN VARCHAR2,
        p_message_id              IN NUMBER,
        x_key_value               OUT  NOCOPY keyVals_tbl_type,
        x_msg_count   		      OUT  NOCOPY NUMBER,
        x_return_status  		  OUT  NOCOPY VARCHAR2,
        x_msg_data   			  OUT  NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : getTagValues_on_MsgId
--  Type        : Public for eMail Center internal use
--  Function    : This procedure returns tags in key-val format for a given message_id if the message_id was stamped.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE getTagValues_on_MsgId(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_message_id              IN NUMBER,
        x_key_value               OUT NOCOPY keyVals_tbl_type,
        x_encrypted_id            OUT NOCOPY VARCHAR2,
        x_msg_count   		      OUT NOCOPY NUMBER,
        x_return_status  		  OUT NOCOPY VARCHAR2,
        x_msg_data   			  OUT NOCOPY VARCHAR2);

--  Start of Comments
--  API name    : isValidAgent
--  Type        : Public for eMail Center internal use
--  Function    : This function valids a eMail Center Agent. Used in auto-route email to the agent who sent the message.
--                Validation based on: 1. Agent account association. 2. Assigned 'ICENTER' role. 3.Assigned a group.
--  Pre-reqs    : None.
--  Parameters  :
function isValidAgent( p_agent_id number, p_email_acct_id number)
return boolean;

END;

 

/
