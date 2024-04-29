--------------------------------------------------------
--  DDL for Package Body FND_USER_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_USER_AP_PKG" AS
/* $Header: fnduserb.pls 115.0 99/07/17 07:47:22 porting ship $ */

     -----------------------------------------------------------------------
     -- Function get_user_name returns the user_name stored in FND_USER
     -- when passed a user_id
     --
     FUNCTION get_user_name(l_user_id IN NUMBER)
         RETURN VARCHAR2
     IS
         l_user_name fnd_user.user_name%TYPE := '';

         cursor l_user_cursor is
	   select user_name
	   from   fnd_user
	   where  user_id = l_user_id;

     BEGIN

         open l_user_cursor;
         fetch l_user_cursor into l_user_name;
	 close l_user_cursor;

         RETURN(l_user_name);

     END get_user_name;


END FND_USER_AP_PKG;

/
