--------------------------------------------------------
--  DDL for Package JTF_IH_GETUSER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_GETUSER_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFIHUPS.pls 115.3 2002/11/08 19:13:58 rdday ship $ */

FUNCTION GetUserInfo (p_user_id IN NUMBER)RETURN VARCHAR2;

END JTF_IH_GETUSER_PVT;


 

/
