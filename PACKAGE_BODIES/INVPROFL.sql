--------------------------------------------------------
--  DDL for Package Body INVPROFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPROFL" as
/*$Header: INVPROFB.pls 120.1 2005/06/21 05:00:16 appldev ship $*/

procedure inv_pr_get_profile
(
appl_short_name  	IN  VARCHAR2,
profile_name  		IN  VARCHAR2,
user_id  		IN  NUMBER,
resp_appl_id 		IN  NUMBER,
resp_id 		IN  NUMBER,
profile_value 		OUT NOCOPY VARCHAR2,
return_code  		OUT NOCOPY NUMBER,
return_message  	OUT NOCOPY VARCHAR2
)
IS
    l_pr_option_id                  NUMBER;
    l_pr_level_id                   NUMBER;
    l_pr_level_value                NUMBER;
    l_pr_value                      VARCHAR2(30);
    no_profile_found                EXCEPTION;
    CURSOR get_profile_cursor(c_appl_short_name     IN VARCHAR2,
                              c_profile_name        IN VARCHAR2,
                              c_user_id             IN NUMBER,
                              c_resp_appl_id        IN NUMBER,
                              c_resp_id             IN NUMBER) IS
           SELECT  opt.profile_option_id,
                   level_id,
                   level_value,
                   substrb(profile_option_value,1,30)
           FROM    fnd_profile_options opt,
                   fnd_application appl,
                   fnd_profile_option_values val
           WHERE   opt.application_id = val.application_id
           AND     opt.profile_option_id = val.profile_option_id
           AND     opt.application_id = appl.application_id
           AND     appl.application_short_name = c_appl_short_name
           AND     opt.profile_option_name = c_profile_name
           AND     (
                     (val.level_id = 10001)        /* Site */
                      OR
                     (val.level_id = 10002        /* Application */
                         and val.level_value = c_resp_appl_id )
                   OR
                     (val.level_id = 10003        /* Responsibility */
                      and val.level_value_application_id = c_resp_appl_id
                      and val.level_value = c_resp_id)
                   OR
                     (val.level_id = 10004        /* User */
                      and val.level_value = c_user_id)
                   )
           ORDER BY opt.profile_option_id, level_id desc;

BEGIN
/* Set appropriate defaults */

  profile_value := NULL;
  OPEN get_profile_cursor(appl_short_name, profile_name,
                          user_id, resp_appl_id,
                          resp_id);
  FETCH get_profile_cursor INTO l_pr_option_id,
                                l_pr_level_id,
                                l_pr_level_value,
                                l_pr_value;
  IF  get_profile_cursor%NOTFOUND THEN
        RAISE no_profile_found;
  END IF;

  CLOSE get_profile_cursor;
--
  profile_value  := l_pr_value;
  return_code    := 0;
  return_message := 'Profile value found';
--
EXCEPTION
        WHEN    no_profile_found THEN
                return_code := -9999;
                return_message := 'INV_NO_PROFILE_VALUE';
        WHEN    OTHERS THEN
                return_code := SQLCODE;
                return_message := 'INVPRFIL.inv_pr_get_profile ' || SUBSTRB(SQLERRM,1,100);

END inv_pr_get_profile;

end INVPROFL;

/
