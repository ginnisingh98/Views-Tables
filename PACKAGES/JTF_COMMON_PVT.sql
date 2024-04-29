--------------------------------------------------------
--  DDL for Package JTF_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_COMMON_PVT" 
/* $Header: jtfvcmns.pls 115.3 2002/05/08 17:23:30 pkm ship     $ */
AUTHID CURRENT_USER AS

FUNCTION GetUserInfo
/*******************************************************************************
** Given a USER_ID the function will return the username/partyname. This
** Function is used to display the CREATED_BY who column information on JTF
** transaction pages.
*******************************************************************************/
(p_user_id IN NUMBER
)RETURN VARCHAR2;

END JTF_COMMON_PVT;

 

/
