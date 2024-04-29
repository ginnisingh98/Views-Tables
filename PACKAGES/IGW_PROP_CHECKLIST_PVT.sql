--------------------------------------------------------
--  DDL for Package IGW_PROP_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_CHECKLIST_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvpchs.pls 115.2 2002/11/14 18:52:00 vmedikon ship $*/

Procedure update_prop_checklist (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 p_proposal_id                    IN	 	NUMBER,
 p_document_type_code             IN		VARCHAR2,
 p_checklist_order	          IN         	NUMBER,
 p_complete 		          IN         	VARCHAR2,
 p_not_applicable	          IN		VARCHAR2,
 p_record_version_number          IN 		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);
------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2);


-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS;
-----------------------------------------------------------------------------------------------------
PROCEDURE POPULATE_CHECKLIST (P_PROPOSAL_ID  	IN	NUMBER,
			      x_return_status   OUT NOCOPY 	VARCHAR2);

------------------------------------------------------------------------------------------------------
 FUNCTION GET_PERSON_NAME_FROM_USER_ID (P_USER_ID    IN      NUMBER) RETURN  VARCHAR2;

END IGW_PROP_CHECKLIST_PVT;

 

/
