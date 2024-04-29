--------------------------------------------------------
--  DDL for Package Body IBC_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_UTILITIES_PUB" as
/* $Header: ibcputlb.pls 115.2 2002/10/03 22:30:41 vicho ship $ */

-- ---------------------------------------------------
-- ----------- PACKAGE VARIABLES ---------------------
-- ---------------------------------------------------
G_PKG_NAME          CONSTANT VARCHAR2(30):='IBC_Utilities_Pub';
G_FILE_NAME         CONSTANT VARCHAR2(12):='ibcputlb.pls';

G_APPL_ID           NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID          NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID        NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID           NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID        NUMBER := FND_GLOBAL.Conc_Request_Id;


/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/










/****************************************************
-------------PROCEDURES--------------------------------------------------------------------------
****************************************************/







END Ibc_Utilities_Pub;

/
