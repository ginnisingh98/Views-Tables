--------------------------------------------------------
--  DDL for Package PJM_TASK_AUTOASSIGN_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TASK_AUTOASSIGN_COPY" AUTHID CURRENT_USER AS
/* $Header: PJMTACRS.pls 115.3 2002/10/29 20:14:10 alaw noship $ */

--
-- Functions and Procedures
--
PROCEDURE Copy_Rules
( P_From_Project_ID         IN             NUMBER
, P_To_Project_ID           IN             NUMBER
, P_Organization_ID         IN             NUMBER
, P_Copy_Option             IN             VARCHAR2
, P_Use_Default_Task        IN             VARCHAR2
, X_Return_Status           OUT NOCOPY     VARCHAR2
, X_Msg_Count               OUT NOCOPY     NUMBER
, X_Msg_Data                OUT NOCOPY     VARCHAR2
, X_Count1                  OUT NOCOPY     NUMBER
, X_Count2                  OUT NOCOPY     NUMBER
);


END PJM_TASK_AUTOASSIGN_COPY;

 

/
