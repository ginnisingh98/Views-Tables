--------------------------------------------------------
--  DDL for Package IEC_IH_HLPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_IH_HLPR_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVIHS.pls 115.14 2004/05/24 20:39:50 minwang noship $ */

-- Generic initial parameter, record and table defs used by CALL_IH
   L_INTERACTION_INITIAL  NUMBER :=0;
   L_MEDIA_LC_INITIAL     NUMBER := 0;

   L_INTERACTION_REC    JTF_IH_PUB.interaction_rec_type;
   L_ACTIVITIES_TBL     JTF_IH_PUB.activity_tbl_type;
   L_MEDIA_LC_REC       JTF_IH_PUB.media_lc_rec_type;

   TYPE MEDIA_ID_CURSOR is REF CURSOR;

   TYPE MEDIA_ID_TAB is TABLE of JTF_IH_MEDIA_ITEMS.MEDIA_ID%TYPE index by binary_integer;

-- Create interaction
PROCEDURE CREATE_INTERACTION
(
  P_MEDIA_ID      IN  NUMBER,
  P_PARTY_ID 	    IN	NUMBER,
  P_START_TIME	  IN	DATE,
  P_END_TIME		  IN	DATE,
  P_OUTCOME_ID	  IN	NUMBER,
  P_REASON_ID	    IN	NUMBER,
  P_RESULT_ID	    IN	NUMBER
);

-- update and close AO media item
PROCEDURE UPDATE_CLOSE_MEDIA_ITEM
(
  P_MEDIA_ID      IN  NUMBER,
  P_SUBSET_ID     IN  NUMBER,
  P_SVR_GROUP_ID  IN  NUMBER,
  P_START_TIME	  IN	DATE,
  P_END_TIME		  IN	DATE,
  P_ADDRESS	      IN  VARCHAR2,
  P_ABANDON_FLAG  IN  VARCHAR2,
  P_HARD_CLOSE    IN  VARCHAR2
);

-- create media item life cycle segment
PROCEDURE CREATE_MILCS
(
  P_MEDIA_ID      IN  NUMBER,
	P_MILCS_TYPE    IN  NUMBER,
	P_START_TIME    IN  DATE,
  P_END_TIME		  IN	DATE
);

END IEC_IH_HLPR_PVT;

 

/
