--------------------------------------------------------
--  DDL for Package Body JTF_ICXSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ICXSES" as
/* $Header: jtficxseb.pls 120.1.12010000.2 2008/10/06 05:22:37 gteella ship $ */

procedure updateSessionInfo(sessionid in number, nametab in jtf_varchar2_table_100, valtab in jtf_varchar2_table_2000, delNameTab in jtf_varchar2_Table_100 ) is
PRAGMA AUTONOMOUS_TRANSACTION;
indx binary_integer; name varchar2(30); value varchar2(4000);
stmt varchar2(200);
begin
  --dbms_output.put_line('something....');
  --dbms_output.put_line('something1....');

         -- remove the delete list.
       if delNameTab is not null and delNameTab.count > 0 then
     	   begin
          forall i in delNameTab.first .. delNameTab.last
           delete from icx_session_attributes where session_id = sessionid and name= delNameTab(i);
           commit;
           exception
            when others then
              rollback;
         end;
       end if;

         -- remove the update list.
       if nametab is not null and nametab.count > 0 then
     	  begin
          forall i in nametab.first .. nametab.last
            delete from icx_session_attributes where session_id = sessionid and name= nametab(i);
            commit;
            exception
             when others then
              rollback;
        end;
       end if;

      -- insert the update list.
      --dbms_output.put_line('something2....');
      if nametab is not null and nametab.count > 0 then
        begin
          forall i in nametab.first .. nametab.last
            insert into icx_session_attributes (session_id, name, value) values(sessionid, nametab(i), valtab(i));
            commit;
            exception
             when others then
              rollback;
        end;
      end if;

     commit;
  exception
    when others then
      rollback;

end updateSessionInfo;
end jtf_icxses;

/
