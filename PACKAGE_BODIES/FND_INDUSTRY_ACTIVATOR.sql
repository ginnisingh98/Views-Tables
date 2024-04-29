--------------------------------------------------------
--  DDL for Package Body FND_INDUSTRY_ACTIVATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_INDUSTRY_ACTIVATOR" as
/* $Header: afindactb.pls 120.3 2005/08/31 21:09:14 dbowles noship $ */
v_industry_id NUMBER(3);

---- PRIVATE ROUTINES
procedure activate_messages is

cursor industry_message_list(p_industry_id  IN NUMBER) is
                select application_id,
                       message_name,
                       message_text,
                       language_code
                from fnd_new_messages_il
                where industry_id = p_industry_id;

cursor   get_original_text(p_app_id  IN NUMBER,
                           p_message_name IN VARCHAR2,
                           p_language_code IN VARCHAR2) is
                select
                       message_text
                from fnd_new_messages
                where application_id = p_app_id and
                      message_name = p_message_name and
                      language_code  = p_language_code and
                      last_updated_by  IN ('0','1','2');

BEGIN
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating industry translated message text.');
   -- get the list of messages for the current industry from fnd_new_messages_il
   for v1 in industry_message_list(v_industry_id)  loop
   -- populate the orig_message_text column
     for v2 in get_original_text(v1.application_id,
                                 v1.message_name,
                                 v1.language_code) loop
       update fnd_new_messages_il
       set orig_message_text = v2.message_text
       where application_id = v1.application_id and
             message_name   = v1.message_name and
             language_code = v1.language_code and
             industry_id = v_industry_id;
     end loop;
   -- replace the message_text in fnd_new_messages with the message_text for the active
   -- industry
       update fnd_new_messages
       set message_text = v1.message_text,
           last_updated_by = 8
       where application_id = v1.application_id and
             message_name = v1.message_name and
             language_code = v1.language_code;
   end loop;
   commit;
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update of industry translated message text completed.');
END activate_messages;

procedure activate_lookups is

cursor industry_lookup_list(p_industry_id  IN NUMBER) is
                select application_id,
                       lookup_type,
                       lookup_code,
                       language_code,
                       meaning,
                       description
                from fnd_lookup_values_il
                where industry_id = p_industry_id;

cursor   get_original_lookups(p_app_id      IN NUMBER,
                              p_lookup_type IN VARCHAR2,
                              p_lookup_code IN VARCHAR2,
                              p_language_code IN VARCHAR2) is
                select
                       meaning,
                       description
                from fnd_lookup_values
                where view_application_id = p_app_id and
                      lookup_type = p_lookup_type and
                      lookup_code = p_lookup_code and
                      language  = p_language_code and
                      last_updated_by  IN ('0','1','2');

BEGIN
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updating industry translated lookups.');
   -- get the list of lookups for the current industry from fnd_lookup_values_il
   for v1 in industry_lookup_list(v_industry_id)  loop
   -- populate the orig_message_text column
     for v2 in get_original_lookups(v1.application_id,
                                 v1.lookup_type,
                                 v1.lookup_code,
                                 v1.language_code) loop
       update fnd_lookup_values_il
       set orig_meaning = v2.meaning,
           orig_description = v2.description
       where application_id = v1.application_id and
             lookup_type   = v1.lookup_type and
             lookup_code   = v1.lookup_code and
             language_code = v1.language_code and
             industry_id = v_industry_id;
     end loop;
   -- replace the meaning and/or description in fnd_lookup_values
   -- for the active industry
   -- using exception handlers around the update meaning statement so that
   -- we do not violate unique index constraint (APPLSYS.FND_LOOKUP_VALUES_U2)
   -- this constraint means for a given lookup type there multiple lookup codes cannot
   -- have the same meaning.  If the update violates the constraint, we silently do not update that row.
     begin
       if v1.meaning is NOT NULL then
         update fnd_lookup_values
         set meaning = v1.meaning,
             last_updated_by = 8
         where view_application_id = v1.application_id and
             lookup_type = v1.lookup_type and
             lookup_code = v1.lookup_code and
             language = v1.language_code;
       end if;
     exception
       when others then
         null;
     end;
     if v1.description is NOT NULL then
       update fnd_lookup_values
       set description = v1.description,
           last_updated_by = 8
       where view_application_id = v1.application_id and
             lookup_type = v1.lookup_type and
             lookup_code = v1.lookup_code and
             language = v1.language_code;
     end if;
   end loop;
   commit;
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Completed updating industry translated lookups.');
END activate_lookups;

procedure section_title (which IN number,
                            title IN varchar2) is

   begin
      FND_FILE.NEW_LINE(which);
      FND_FILE.PUT_LINE(which, '----------------------------------------------------------------');
      FND_FILE.PUT_LINE(which, title);
      FND_FILE.PUT_LINE(which, '----------------------------------------------------------------');
   end section_title;


----PUBLIC ROUTINES

procedure activate_industry(errbuf         OUT NOCOPY VARCHAR2,
                            retcode        OUT NOCOPY VARCHAR2,
                            p_industry_id  IN VARCHAR2) is
e_bad_profile  EXCEPTION;
e_deactivate   EXCEPTION;
v_errbuf       VARCHAR2(2000);
v_retcode      VARCHAR2(3);
v_activate_date DATE;
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of FND_INDUSTRY_ACTIVATION');
   v_activate_date := SYSDATE;
   deactivate_industries(v_errbuf,
                         v_retcode);
   if retcode = 2 then
      raise e_deactivate;
   end if;
   v_industry_id := to_number(p_industry_id);
   --Now set the profile to the new value for the desired industry
   if fnd_profile.save('FND_INDUSTRY_ID', v_industry_id,'SITE') then
   section_title(FND_FILE.LOG, 'Activating industry '||v_industry_id);
      commit;
   else
      raise e_bad_profile;
   end if;
   activate_messages;
   activate_lookups;
   errbuf := ('Industry activation complete.');
   retcode := 0 ;
EXCEPTION
   when e_bad_profile then
      errbuf := ('Industry activation failed. Make sure that the FND_INDUSTRY_ID profile
                  has been defined for your system.');
      retcode := 2 ;
   when e_deactivate then
      null;
END activate_industry;

procedure deactivate_industries(errbuf         OUT NOCOPY VARCHAR2,
                                retcode        OUT NOCOPY VARCHAR2) is
cursor  restore_message_text is
                select il.application_id,
                      il.message_name,
                      il.language_code,
                      il.orig_message_text
                from fnd_new_messages_il il,
                     fnd_new_messages n
                where il.industry_id = v_industry_id and
                      il.application_id = n.application_id and
                      il.language_code = n.language_code and
                      il.message_name =  n.message_name and
                      n.last_updated_by = 8;

cursor restore_lookups is
                select il.application_id,
                      il.lookup_type,
                      il.lookup_code,
                      il.language_code,
                      il.orig_meaning,
                      il.orig_description
                from fnd_lookup_values_il il,
                     fnd_lookup_values lv
                where il.industry_id = v_industry_id and
                      il.application_id = lv.view_application_id and
                      il.lookup_type = lv.lookup_type and
                      il.lookup_code =  lv.lookup_code and
                      il.language_code = lv.language and
                      lv.last_updated_by = 8;

BEGIN
   v_industry_id := to_number(fnd_profile.value('FND_INDUSTRY_ID'));
   -- if the profile returns a null value then industries were never activated
   if v_industry_id is NULL then

      return;
   end if;
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   section_title(FND_FILE.LOG, 'Deactivating INDUSTRY_ID '||v_industry_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Restoring original message text.');


   for v1 in restore_message_text loop

        if v1.orig_message_text is not null then
           update fnd_new_messages
           set message_text = v1.orig_message_text,
               last_updated_by = 2
           where application_id = v1.application_id and
                 message_name = v1.message_name and
                 language_code = v1.language_code;
        end if;
   end loop;
   commit;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Original message text restored.');
   -- clean up the orig_message_text column in the FND_NEW_MESSAGES_IL table
   update fnd_new_messages_il
   set orig_message_text = null;
   commit;
   FND_FILE.NEW_LINE(FND_FILE.LOG);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Restoring original lookup values meaning and description.');
   for v2 in restore_lookups loop
     if v2.orig_meaning is not null then
        update fnd_lookup_values
        set meaning = v2.orig_meaning,
            description = v2.orig_description,
            last_updated_by = 2
        where view_application_id = v2.application_id
              and lookup_type  = v2.lookup_type
              and lookup_code  = v2.lookup_code
              and language = v2.language_code;
     end if;
   end loop;
   commit;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Original lookup value meanings and descriptions restored.');
   -- clean up the orig_meaning and orig_description columns in the FND_LOOKUP_VALUES_IL table
   update fnd_lookup_values_il
   set orig_meaning = null,
       orig_description = null;
   commit;
   if fnd_profile.save('FND_INDUSTRY_ID', NULL,'SITE') then
     errbuf := ('Industry deactivation complete.');
     retcode := 0 ;
   else
     errbuf := ('Industry deactivation failed');
     retcode := 2 ;
   end if;
END deactivate_industries;

END;

/
