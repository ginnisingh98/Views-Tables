--------------------------------------------------------
--  DDL for Package IEC_QUOTAUPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_QUOTAUPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVQUOS.pls 115.8 2004/04/30 18:25:27 minwang noship $ */

PROCEDURE UPDATE_QUOTA_LIST
   (P_QUOTA_USED            IN NUMBER
   ,P_LIST_HEADER_ID        IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
   );
PROCEDURE UPDATE_QUOTA_SUBSET
   (P_QUOTA_USED            IN NUMBER
   ,P_LIST_SUBSET_ID        IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
   );

PROCEDURE UPDATE_QUOTA
   (P_ID                    IN NUMBER
	 ,P_TYPE                  IN VARCHAR2
   ,P_QUOTA_USED            IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
	 );
PROCEDURE UPDATE_QUOTA
   (P_ID                    IN NUMBER
   ,P_TYPE                  IN VARCHAR2
   ,P_QUOTA_USED            IN NUMBER
         );

END IEC_QUOTAUPDATE_PVT;


 

/
