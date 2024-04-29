--------------------------------------------------------
--  DDL for Package Body HELLO1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HELLO1" as

procedure world is
begin

htp.p(fnd_profile.value('APPS_WEB_AGENT'));htp.nl;
htp.p(length(fnd_profile.value('APPS_WEB_AGENT')));htp.nl;

htp.p(FND_WEB_CONFIG.PLSQL_AGENT);

exception
        when others then
                htp.p(SQLERRM);
end;


end;

/
