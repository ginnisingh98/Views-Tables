--------------------------------------------------------
--  DDL for Package Body WF_BES_CLEANUP_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_BES_CLEANUP_INIT" as
/* $Header: WFBESCUIB.pls 115.0 2002/08/21 19:28:21 gashford noship $ */

--------------------------------------------------------------------------------
-- Initializes the apps context to SYSADMIN.
--------------------------------------------------------------------------------
procedure apps_initialize
is
   l_user_id number;
   l_resp_id number;
   l_resp_appl_id number;
begin
   select u.user_id
   into l_user_id
   from fnd_user u
   where u.user_name = 'SYSADMIN';

   select r.application_id,
          r.responsibility_id
   into l_resp_appl_id,
        l_resp_id
   from fnd_application a,
        fnd_responsibility r
   where r.application_id = a.application_id
   and a.application_short_name = 'SYSADMIN'
   and r.responsibility_key = 'SYSTEM_ADMINISTRATOR';

   fnd_global.apps_initialize(user_id      => l_user_id,
                              resp_id      => l_resp_id,
                              resp_appl_id => l_resp_appl_id);
end apps_initialize;

--------------------------------------------------------------------------------
procedure start_cleanup_process
is
   l_request_id number;
   l_phase varchar2(30);
   l_status varchar2(30);
   l_dev_phase varchar2(30);
   l_dev_status varchar2(30);
   l_message varchar2(2000);
   l_request_status_return boolean;
   l_repeat_options_return boolean;
   l_submit_request_return number;

   l_cleanup_repeat_interval number;
   l_cleanup_repeat_unit varchar2(30);
   l_cleanup_repeat_type varchar2(30);
   l_cleanup_app_short_name varchar2(50);
   l_cleanup_program varchar2(30);
begin
   l_cleanup_repeat_interval := 12;
   l_cleanup_repeat_unit := 'HOURS';
   l_cleanup_repeat_type := 'START';
   l_cleanup_app_short_name := 'FND';
   l_cleanup_program := 'FNDWFBES_CONTROL_QUEUE_CLEANUP';

  -- see if the cleanup process is already there

   l_request_status_return := fnd_concurrent.get_request_status(
                                 request_id     => l_request_id,
                                 appl_shortname => l_cleanup_app_short_name,
                                 program        => l_cleanup_program,
                                 phase          => l_phase,
                                 status         => l_status,
                                 dev_phase      => l_dev_phase,
                                 dev_status     => l_dev_status,
                                 message        => l_message);

   if(l_request_id is null) then
      -- the cleanup request has never been submitted so submit it

      apps_initialize();

      l_repeat_options_return := fnd_request.set_repeat_options(
                                    repeat_interval => l_cleanup_repeat_interval,
                                    repeat_unit     => l_cleanup_repeat_unit,
                                    repeat_type     => l_cleanup_repeat_type);

      l_submit_request_return := fnd_request.submit_request(
                                    application => l_cleanup_app_short_name,
                                    program     => l_cleanup_program);

      commit;
   else
      -- the cleanup request has already been submitted so no action is required

      null;
   end if;
end start_cleanup_process;

end wf_bes_cleanup_init;

/
