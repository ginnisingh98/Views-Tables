--------------------------------------------------------
--  DDL for Package Body JTM_CONC_PROG_RUN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_CONC_PROG_RUN_STATUS_PUB" AS
/* $Header: jtmpurgb.pls 120.1 2005/08/24 02:17:53 saradhak noship $ */

G_SECONDS_PER_DAY CONSTANT NUMBER := 6640; /* 6640 = 24 * 60 * 60 */

procedure PURGE(
    P_Status      OUT NOCOPY  VARCHAR2,
    P_Message      OUT NOCOPY  VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_history_level number;
BEGIN
  P_Status := 'Fine';

  begin
    l_history_level := FND_PROFILE.VALUE( 'JTM_CONC_PROG_HISTORY_LEVEL');
  exception
     when others then
        l_history_level := 2;
  end;

  if (l_history_level is null) then
     l_history_level := 2;
  end if;

  P_Message := 'The log data older than ' ||
               l_history_level || ' days are deleted';

  delete from JTM_CONC_RUN_STATUS_LOG
  /*where (sysdate - END_TIME) > l_history_level;*/
  where END_TIME < sysdate - l_history_level;
  commit;
EXCEPTION
   when others then
       P_Status  := 'Error';
       P_Message := 'Encounter error: ' || sqlerrm;
END PURGE;
end JTM_CONC_PROG_RUN_STATUS_PUB;

/
