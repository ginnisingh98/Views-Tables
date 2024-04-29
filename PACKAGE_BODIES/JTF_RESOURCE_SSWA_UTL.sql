--------------------------------------------------------
--  DDL for Package Body JTF_RESOURCE_SSWA_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RESOURCE_SSWA_UTL" AS
  /* $Header: jtfrsswb.pls 120.0 2005/05/11 08:22:02 appldev noship $ */

  /*****************************************************************************************
   This package body defines all the routines which are declared in the package
   specification.
   ******************************************************************************************/

  /* Function to check if user has update access */

Function    Validate_Update_Access( p_resource_id           number,
  			            p_resource_user_id      number default null
			          ) Return varchar2
IS
l_profile_value	     VARCHAR2(10);
l_user_id            number;
l_resource_user_id   number;

BEGIN

  l_profile_value := nvl(FND_PROFILE.VALUE('JTF_RS_EMP_RES_UPD_ACCESS'),'SELF');
  l_user_id       := nvl(FND_PROFILE.VALUE('USER_ID'),-1);

  IF (l_profile_value = 'SELF') THEN
       IF (p_resource_user_id IS NULL) THEN
          BEGIN
            SELECT  nvl(user_id,0)
    	    INTO    l_resource_user_id
            FROM    jtf_rs_resource_extns
            WHERE   resource_id = p_resource_id;
          EXCEPTION WHEN NO_DATA_FOUND THEN
    	     l_resource_user_id := 0;
             WHEN OTHERS THEN
	     l_resource_user_id := -10;
          END;
        ELSE
          l_resource_user_id := p_resource_user_id;
        END IF;

        IF l_resource_user_id = l_user_id THEN
           Return 'SELF';
        ELSE
           Return 'OTHERS';
        END IF;

   ELSIF (l_profile_value = 'ANY') THEN
        Return 'ANY';
   ELSE
        Return 'OTHERS';
   END IF;

   END Validate_Update_Access;

END jtf_resource_sswa_utl;

/
