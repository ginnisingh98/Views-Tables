--------------------------------------------------------
--  DDL for Procedure XXAH_USERS_RESP_DEACTIVATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_USERS_RESP_DEACTIVATE" 
AS
   CURSOR cur1
   IS
        SELECT fu.user_name,
               frt.responsibility_name,
               furg.start_date,
               furg.end_date,
               fr.responsibility_key,
               fa.application_short_name,
               fs.security_group_key
          FROM fnd_user_resp_groups_direct furg,
               fnd_user fu,
               fnd_responsibility_tl frt,
               fnd_responsibility fr,
               fnd_application_tl fat,
               fnd_application fa,
               fnd_security_groups fs
         WHERE     furg.user_id = fu.user_id
               AND furg.responsibility_id = frt.responsibility_id
               AND fr.responsibility_id = frt.responsibility_id
               AND fa.application_id = fat.application_id
               AND fr.application_id = fat.application_id
               AND fr.data_group_id = fs.security_group_id
               AND frt.language = USERENV ('LANG')
               AND UPPER (fu.user_name) LIKE UPPER ('PNL03Q03') -- <change it>
      -- AND tunc(fu.end_date) <= TRUNC(SYSDATE)
      ORDER BY frt.responsibility_name;
BEGIN
   FOR all_user IN cur1
   LOOP
      BEGIN
         fnd_user_pkg.delresp (
            username         => all_user.user_name,
            resp_app         => all_user.application_short_name,
            resp_key         => all_user.responsibility_key,
            security_group   => all_user.security_group_key);
         COMMIT;

         DBMS_OUTPUT.put_line (
               'Responsiblity'
            || all_user.application_short_name
            || 'is removed from the user'
            || all_user.user_name
            || ' Successfully');
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'Error encountered while deleting responsibilty from the user and the error is '
               || SQLERRM);
      END;
   END LOOP;
END;

/
