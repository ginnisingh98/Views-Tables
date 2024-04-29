--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_BIOSKETCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_BIOSKETCH_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvppbs.pls 115.2 2002/11/15 00:41:31 ashkumar ship $*/

Procedure update_prop_person_biosketch (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 P_PROPOSAL_ID               	  IN	 	NUMBER,
 P_PERSON_BIOSKETCH_ID       	  IN		NUMBER,
 P_SHOW_FLAG 		     	  IN            VARCHAR2,
 P_LINE_SEQUENCE	     	  IN		NUMBER,
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

-----------------------------------------------------------------------------------------------------------
/*
PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);
*/
END IGW_PROP_PERSON_BIOSKETCH_PVT;

 

/
