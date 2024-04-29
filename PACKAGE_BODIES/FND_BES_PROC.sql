--------------------------------------------------------
--  DDL for Package Body FND_BES_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_BES_PROC" as
/* $Header: AFBESPROCB.pls 115.2 2002/10/25 18:56:58 gashford noship $ */

BES_DATABASE_ID       constant varchar2(30) := 'BES_DATABASE_ID';
BES_SECURITY_GROUP_ID constant varchar2(30) := 'BES_SECURITY_GROUP_ID';

--------------------------------------------------------------------------------
function process_event(p_subscription_guid in            raw,
                       p_event             in out nocopy wf_event_t)
   return varchar2
is
   l_database_id       varchar2(255);
   l_security_group_id number;
begin
   -- if not already present, add the database name to the event

   if(p_event.getValueForParameter(BES_DATABASE_ID) is null) then
      l_database_id := fnd_web_config.database_id();

      p_event.addParameterToList(BES_DATABASE_ID, l_database_id);
   end if;

   -- if not already present, add the security group id to the event

   if(p_event.getValueForParameter(BES_SECURITY_GROUP_ID) is null) then
      l_security_group_id := fnd_global.security_group_id();

      p_event.addParameterToList(BES_SECURITY_GROUP_ID, l_security_group_id);
   end if;

   return wf_rule.default_rule(p_subscription_guid, p_event);
end process_event;

end fnd_bes_proc;

/
