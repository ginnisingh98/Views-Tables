--------------------------------------------------------
--  DDL for Package CCT_APPID_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_APPID_PUB" AUTHID CURRENT_USER as
/* $Header: cctresps.pls 115.0 2003/08/25 14:49:31 gvasvani noship $ */
/*------------------------------------------------------------------------
REM
REM-----------------------------------------------------------------------*/

Function GetApplicationID(
     p_Classification   IN VARCHAR2,
     p_MediaType        IN VARCHAR2,
     p_AgentID          IN NUMBER
	) Return NUMBER;

END CCT_AppID_Pub;

 

/
