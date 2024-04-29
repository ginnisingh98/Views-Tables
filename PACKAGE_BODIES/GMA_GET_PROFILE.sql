--------------------------------------------------------
--  DDL for Package Body GMA_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_GET_PROFILE" AS
/* $Header: GMAPROFB.pls 115.0 99/07/16 02:46:53 porting shi $ */
 FUNCTION get_profile_value(appl_short_name  IN VARCHAR2,profile_name IN VARCHAR2) RETURN VARCHAR2 IS
        CURSOR get_profile_cursor(c_appl_short_name VARCHAR2,c_profile_name VARCHAR2) IS
        SELECT  substr(profile_option_value,1,30)
        FROM    fnd_profile_options opt,
                fnd_application appl,
                fnd_profile_option_values val
        WHERE   opt.application_id = val.application_id
        AND     opt.profile_option_id = val.profile_option_id
        AND     opt.application_id = appl.application_id
        AND     appl.application_short_name = c_appl_short_name
        AND     opt.profile_option_name = c_profile_name
        AND     val.level_id = 10001        /* Site */
        ORDER BY opt.profile_option_id, level_id desc;
  l_pr_value VARCHAR2(30);
BEGIN
  OPEN get_profile_cursor(appl_short_name,profile_name);
  FETCH get_profile_cursor INTO l_pr_value;
  CLOSE get_profile_cursor;
  return(l_pr_value);
END get_profile_value;
END GMA_GET_PROFILE;

/
