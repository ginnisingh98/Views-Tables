--------------------------------------------------------
--  DDL for Package Body AS_SALES_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_GROUP_PVT" as
/* $Header: asxvsgrb.pls 115.4 2002/11/06 01:02:02 appldev ship $ */

--
-- NAME
--   AS_SALES_GROUP_PVT
--
-- HISTORY
--   6/19/98        ALHUNG        CREATED
--
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_SALES_GROUP_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvsgrb.pls';

G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;



END AS_SALES_GROUP_PVT;

/
