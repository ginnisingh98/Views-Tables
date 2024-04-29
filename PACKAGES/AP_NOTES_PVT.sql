--------------------------------------------------------
--  DDL for Package AP_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_NOTES_PVT" AUTHID CURRENT_USER AS
/* $Header: apwnotvs.pls 115.0 2003/11/11 19:26:11 vnama noship $ */


/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Get_User_Full_Name
--  TYPE                 : Public
--  PURPOSE              : Given a USER_ID the function will return the
--                         full name of the user.
--  PRE_REQS             : None
--
--  PARAMETERS           :
--  IN -
--  OUT -
--  IN OUT NO COPY -
--
--  MODIFICATION HISTORY :
--   Date         Author          Description of Changes
--   11-Nov-2003  V Nama          Created
--
--  NOTES                : Based on API - JTF_COMMON_PVT.GetUserInfo
--
-- End of comments
/*===========================================================================*/
FUNCTION Get_User_Full_Name (
  p_user_id                     IN     NUMBER
)
RETURN VARCHAR2;



END AP_NOTES_PVT;

 

/
