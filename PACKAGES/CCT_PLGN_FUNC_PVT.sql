--------------------------------------------------------
--  DDL for Package CCT_PLGN_FUNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_PLGN_FUNC_PVT" AUTHID CURRENT_USER AS
/* $Header: cctvplgs.pls 115.0 2002/09/18 01:37:36 edwang noship $ */



FUNCTION DO_LAUNCH_CLIENT_SDK
 (
   P_RESOURCE_ID  NUMBER
  ,P_USER_ID      NUMBER
  ,P_RESP_ID      NUMBER
  ,P_RESP_APPL_ID NUMBER
  ,P_USER_LANG    VARCHAR2
 ) RETURN VARCHAR2;

END CCT_PLGN_FUNC_PVT;

 

/
