--------------------------------------------------------
--  DDL for Package JTF_IH_IEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_IEC_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFIHPAS.pls 115.10 2004/05/24 17:59:38 ialeshin ship $*/

-- Generic initial parameter, record and table defs used by CALL_IH
   --L_INITIAL NUMBER :=0;
   --L_MEDIA_INIT NUMBER := 0;
   --L_MEDIA_LF_INIT NUMBER := 0;

   --L_INTERACTION_REC    JTF_IH_PUB.interaction_rec_type;
   --L_ACTIVITIES_TBL     JTF_IH_PUB.activity_tbl_type;
   --L_MEDIA_REC		JTF_IH_PUB.media_rec_type;

   TYPE MEDIA_ID_CURSOR is REF CURSOR;

   TYPE MEDIA_ID_TAB is TABLE of JTF_IH_MEDIA_ITEMS.MEDIA_ID%TYPE index by binary_integer;

-- Create media items
PROCEDURE GET_MEDIA_IDS
  ( P_COUNT     IN  NUMBER
  , X_MEDIA_IDS OUT NOCOPY MEDIA_ID_CURSOR
  );

PROCEDURE CLOSE_AO_CALL
		(
			p_Media_id		IN NUMBER,
  	  		p_Hard_Close 	IN VARCHAR2 DEFAULT NULL,
  		  	p_source_item_id IN NUMBER,
  			p_address 		IN VARCHAR2,
  			p_start_date_time IN DATE DEFAULT NULL,
  			p_end_date_time IN DATE DEFAULT NULL,
  			p_duration  	IN NUMBER DEFAULT NULL,
  			p_media_abandon_flag IN VARCHAR2 DEFAULT NULL,
  			x_Commit 		IN	VARCHAR2 DEFAULT NULL,
			x_return_status	OUT NOCOPY	VARCHAR2,
			x_msg_count		OUT NOCOPY	NUMBER,
			x_msg_data		OUT NOCOPY	VARCHAR2,
			-- Enh# 3646665
			p_Server_Group_ID IN NUMBER  DEFAULT NULL
  );
END JTF_IH_IEC_PVT;

 

/
