--------------------------------------------------------
--  DDL for Package IGW_GR_PERSONNEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_GR_PERSONNEL" AUTHID CURRENT_USER as
/* $Header: igwgrpersonnels.pls 120.0 2005/06/16 23:01:42 vmedikon ship $ */

----------------------------------------  PERSONNEL GENERAL ------------------------------------------
FUNCTION MIN_PERSONNEL_START_DATE (P_PROPOSAL_ID 	IN 	NUMBER,
				   P_PERSON_PARTY_ID	IN	NUMBER) RETURN DATE;

FUNCTION MAX_PERSONNEL_END_DATE (P_PROPOSAL_ID 	IN 	NUMBER,
				   P_PERSON_PARTY_ID	IN	NUMBER) RETURN DATE;

 ---------------------------------------------------------------------------------------------------------
FUNCTION GET_SPONSOR_NAME (p_sponsor_id	number) return varchar2;


---------------------------------------------------------------------------------------
FUNCTION GET_PERSON_NAME (p_person_party_id number) return varchar2;

---------------------------------------------------------------------------------------------------------
FUNCTION GET_MAJOR_GOALS (p_proposal_id   NUMBER) RETURN VARCHAR2;

--------------------------------------------------------------------------------------
PROCEDURE POPULATE_BIO_TABLES (	p_init_msg_list     	in    	varchar2,
 			                p_commit              	in    	varchar2,
 			       		p_validate_only     	in    	varchar2,
			       		p_proposal_id       	in    	number,
			       		p_party_id          		in    	number,
			       		x_return_status	   	out 	NOCOPY   varchar2,
			       		x_msg_count         	out 	NOCOPY   number,
 			       		x_msg_data          	out 	NOCOPY   varchar2);

FUNCTION GET_FORMATTED_ADDRESS (P_PARTY_ID      NUMBER) RETURN VARCHAR2;

PROCEDURE add_other_support_commitments (
      p_init_msg_list                IN VARCHAR2,
      p_validate_only                IN VARCHAR2,
      p_commit                       IN VARCHAR2,
      p_prop_person_support_id       IN NUMBER,
      p_proposal_id                  IN NUMBER,
      p_person_party_id              IN NUMBER,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------
PROCEDURE delete_personnel_related_data(
      p_init_msg_list                IN 		VARCHAR2  ,
      p_commit                       IN 		VARCHAR2  ,
      p_proposal_id                IN 		NUMBER,
      p_person_party_id          IN 		NUMBER,
      x_return_status               OUT 	NOCOPY VARCHAR2,
      x_msg_count                  OUT 	NOCOPY NUMBER,
      x_msg_data                    OUT 	NOCOPY VARCHAR2);
END  IGW_GR_PERSONNEL;

 

/
