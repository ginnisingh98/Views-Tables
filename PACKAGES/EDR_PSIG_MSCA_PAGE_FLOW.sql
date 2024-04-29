--------------------------------------------------------
--  DDL for Package EDR_PSIG_MSCA_PAGE_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_PSIG_MSCA_PAGE_FLOW" AUTHID CURRENT_USER AS
/* $Header: EDRVMPFS.pls 120.1.12000000.1 2007/01/18 05:56:29 appldev ship $ */


--This procedeure would process the signature process of the approvers in
--MSCA page flow and update the ERES tables accordingly.
--This is a PRIVATE procedure

-- Start of comments
-- API name   : PROCESS_RESPONSE
-- Type       : Private
-- Function   : Processes the signature response.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_event_id                IN NUMBER - The event Id value.
--            : p_erecord_id              IN NUMBER - The e-record ID value
--            : p_user_name               IN VARCHAR2 - The approver's user name
--            : p_action_code             IN VARCHAR2 - The action code
--            : p_action_meaning          IN VARCHAR2 - The action meaning
--            : p_sign_sequence           IN NUMBER - The approver sequence number
--            : p_signature_param_names   IN FND_TABLE_OF_VARCHAR2_255 - List of signature parameter names
--            : p_signature_param_values  IN FND_TABLE_OF_VARCHAR2_255 - List of signature parameter values
--            : p_sig_param_display_names IN FND_TABLE_OF_VARCHAR2_255 - List of signature parameter display values

-- OUT        : x_error_code OUT NOCOPY NUMBER - The status code
--            : x_error_msg  OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE PROCESS_RESPONSE( p_event_id                IN NUMBER,
                              p_erecord_id              IN NUMBER,
                              p_user_name               IN VARCHAR2,
                              p_action_code             IN VARCHAR2,
                              p_action_meaning          IN VARCHAR2,
                              p_sign_sequence           IN NUMBER,
                              p_signature_param_names   IN FND_TABLE_OF_VARCHAR2_255,
                              p_signature_param_values  IN FND_TABLE_OF_VARCHAR2_255,
                              p_sig_param_display_names IN FND_TABLE_OF_VARCHAR2_255,
                              x_error_code OUT NOCOPY NUMBER,
                              x_error_msg  OUT NOCOPY VARCHAR2);


--This procedeure would process pageflow for the CANCEL response.
--This is a PRIVATE procedure

-- Start of comments
-- API name   : PROCESS_CANCEL
-- Type       : Private
-- Function   : Processes the CANCEL RESPONSE
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_erecord_id IN NUMBER - The e-record ID value
--            : p_itemtype   IN VARCHAR2 - The pageflow item type
--            : p_itemkey    IN VARCHAR2 - The pageflow item key value

-- OUT        : x_error_code OUT NOCOPY NUMBER - The status code
--            : x_error_msg  OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE PROCESS_CANCEL(p_erecord_id IN NUMBER,
                           p_itemtype   IN VARCHAR2,
                           p_itemkey    IN VARCHAR2,
                           x_error_code OUT NOCOPY NUMBER,
                           x_error_msg  OUT NOCOPY VARCHAR2);


--This procedeure would process pageflow for the CANCEL response.
--This is a PRIVATE procedure

-- Start of comments
-- API name   : PROCESS_MSCA_BLOCKED_ACTIVITY
-- Type       : Private
-- Function   : This API would perform the actual pageflow block activities
--            : based on the action parameter.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_itemtype IN VARCHAR2 - The pageflow item type
--            : p_itemkey  IN VARCHAR2 - The pageflow item key value
--            : p_action   IN VARCHAR2 - The action required
--                                     - The possible are "DONE","DEFER"

-- OUT        : x_error_code OUT NOCOPY NUMBER - The status code
--            : x_error_msg  OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE PROCESS_MSCA_BLOCKED_ACTIVITY(p_itemtype IN VARCHAR2,
                                          p_itemkey IN VARCHAR2,
                                          p_action IN VARCHAR2,
                                          x_error_code OUT NOCOPY NUMBER,
                                          x_error_msg OUT NOCOPY VARCHAR2);



--This procedeure would process pageflow for the DEFER response.
--This is a PRIVATE procedure

-- Start of comments
-- API name   : PROCESS_DEFER
-- Type       : Private
-- Function   : Processes the DEFER RESPONSE
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_erecord_id IN NUMBER - The e-record ID value
--            : p_itemtype   IN VARCHAR2 - The pageflow item type
--            : p_itemkey    IN VARCHAR2 - The pageflow item key value

-- OUT        : x_error_code OUT NOCOPY NUMBER - The status code
--            : x_error_msg  OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE PROCESS_DEFER(p_erecord_id IN NUMBER,
                          p_itemtype   IN VARCHAR2,
                          p_itemkey    IN VARCHAR2,
                          x_error_code OUT NOCOPY NUMBER,
                          x_error_msg OUT NOCOPY VARCHAR2);



--This procedeure provides a wrapper over the API EDR_PSIG.CLOSEDOCUMENT
--This procedure has been defined to perform the closeDocument operation
--in an autonomous transaction.
--This is a PRIVATE procedure

-- Start of comments
-- API name   : CLOSE_DOCUMENT
-- Type       : Private
-- Function   : Closes the specified document in evidence store.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : P_DOCUMENT_ID IN NUMBER - The ID of the document to be closed.

-- OUT        : x_error_code OUT NOCOPY NUMBER - The status code
--            : x_error_msg  OUT NOCOPY VARCHAR2 - The return message indicating success/error.

  PROCEDURE CLOSE_DOCUMENT(P_DOCUMENT_ID          IN  NUMBER,
                           X_ERROR                OUT NOCOPY NUMBER,
                           X_ERROR_MSG            OUT NOCOPY VARCHAR2
                          );

END EDR_PSIG_MSCA_PAGE_FLOW;

 

/
