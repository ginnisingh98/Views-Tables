--------------------------------------------------------
--  DDL for Package OKE_HOLD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_HOLD_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEHLDUS.pls 115.4 2002/08/14 01:43:49 alaw ship $ */
--
--  Name          : Status_Change
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions during
--                  a hold status change.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Status_Change
( P_Hold_ID          IN  NUMBER
, P_K_Header_ID      IN  NUMBER
, P_K_Line_ID        IN  NUMBER
, P_DTS_ID           IN  NUMBER
, P_Hold_Type_Code   IN  VARCHAR2
, P_Hold_Reason_Code IN  VARCHAR2
, P_Remove_Reason_Code IN  VARCHAR2
, P_Old_Status_Code  IN  VARCHAR2
, P_New_Status_Code  IN  VARCHAR2
, P_Updated_By       IN  NUMBER
, P_Update_Date      IN  DATE
, P_Login_ID         IN  NUMBER
);


END OKE_HOLD_UTILS;

 

/
