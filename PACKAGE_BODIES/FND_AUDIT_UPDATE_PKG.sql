--------------------------------------------------------
--  DDL for Package Body FND_AUDIT_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AUDIT_UPDATE_PKG" as
/*  $Header: fdaaddrk.pls 120.5.12010000.2 2008/09/03 19:42:28 jwsmith ship $ */

procedure FND_AUDIT_ROW_KEY(errbuf IN OUT NOCOPY varchar2, rc IN OUT NOCOPY varchar2, p_snm varchar2,p_taplid number,p_tabid number)
is

cursor l_is_there_row_key_csr(c_tabname varchar2, c_owner varchar2) is
select column_name from
dba_tab_columns where
table_name = c_tabname and
owner = c_owner and
column_name = 'ROW_KEY';

cursor l_get_owner_csr(c_tabname varchar2) is
select owner from
dba_tables where
table_name = c_tabname and
owner in (select oracle_username from fnd_oracle_userid);

cursor l_get_tab_columns_csr(c_tabname varchar2, c_owner varchar2) is
select column_name from dba_tab_columns where
column_name <> 'ROW_KEY' and column_id > 7 and
table_name = c_tabname and
owner = c_owner
order by column_id;

cursor l_get_base_table_name_csr(c_appid number, c_tabid number) is
select table_name from fnd_tables where
application_id=c_appid and
table_id = c_tabid;


 v_CursorID      NUMBER;
 v_dummy         NUMBER;
 v_rowkey varchar2(30);
 v_longflag varchar2(1) := 'N';
 v_altertable varchar2(400);
 v_tname varchar2(30);
 v_oldtname varchar2(30);
 v_shadname varchar2(30);
 v_owner varchar2(30);
 v_createtable varchar2(2000);
 v_updatetable varchar2(2000);
 tcount number;
 toldcount number;

begin
  v_longflag := 'N';
  v_shadname := p_snm;
  v_oldtname := v_shadname || '_O';

  open l_get_base_table_name_csr(p_taplid, p_tabid);
  fetch l_get_base_table_name_csr into v_tname;
  close l_get_base_table_name_csr;

  open l_get_owner_csr(v_tname);
  fetch l_get_owner_csr into v_owner;
  close l_get_owner_csr;

  open l_is_there_row_key_csr(p_snm,v_owner);
  fetch l_is_there_row_key_csr into v_rowkey;
  if l_is_there_row_key_csr%FOUND then
     close l_is_there_row_key_csr;
  else
     /* if long tablename that needs to be truncated */
     if (length(v_tname) > 24) then
        v_longflag := 'Y';
        /* truncate and append _A to get new shadow table name */
        v_tname := substr(rtrim(v_shadname,'_A'),0,24) || '_A';
     else
     v_tname := v_shadname;
     end if;
     execute immediate('alter table ' || v_owner ||'.' || v_shadname || ' rename to ' || v_oldtname);
     execute immediate('drop synonym ' || v_shadname);
     execute immediate('create synonym '|| v_oldtname || ' for ' || v_owner ||'.' || v_oldtname);
     execute immediate('alter table '|| v_owner ||'.'|| v_oldtname || ' add (row_key number)');
     v_updatetable := 'update '|| v_owner ||'.'|| v_oldtname || ' set row_key = ' ||
                    '(TO_NUMBER(TO_CHAR(AUDIT_TIMESTAMP,''YYYYMMDDHH24MISS''))'
                     || '* 100000 + MOD(AUDIT_SEQUENCE_ID,100000)) * 100000 + AUDIT_SESSION_ID';
     execute immediate (v_updatetable);
     v_createtable := 'create table ' || v_owner ||'.'|| v_tname || ' as (select audit_timestamp, audit_transaction_type, audit_user_name, audit_true_nulls, audit_session_id, audit_sequence_id, audit_commit_id, row_key';
     for l_get_col_rec in l_get_tab_columns_csr(v_oldtname, v_owner) loop
       v_createtable := v_createtable || ',  ' || l_get_col_rec.column_name;
     end loop;
     v_createtable := v_createtable || ' from '|| v_owner ||'.'|| v_oldtname || ')';
     execute immediate (v_createtable);
     execute immediate ('select count(*) from '|| v_owner ||'.'|| v_tname) into tcount;
     execute immediate ('select count(*) from '|| v_owner ||'.'|| v_oldtname) into toldcount;
     if (tcount = toldcount) then
        execute immediate ('drop table '|| v_owner ||'.'|| v_oldtname);
        execute immediate ('drop synonym '|| v_oldtname);
        execute immediate ('create synonym '|| v_tname || ' for ' || v_owner ||'.' || v_tname);
        if (v_longflag = 'Y') then
         execute immediate ('drop procedure ' || v_shadname || 'IP');
         execute immediate ('drop procedure ' || v_shadname || 'UP');
         execute immediate ('drop procedure ' || v_shadname || 'DP');
         execute immediate ('drop trigger ' || v_shadname || 'D');
         execute immediate ('drop trigger ' || v_shadname || 'I');
         execute immediate ('drop trigger ' || v_shadname || 'U');
         execute immediate ('drop view ' || v_shadname || 'C1');
         execute immediate ('drop view ' || v_shadname || 'V1');
      end if;
    else
      null;
      /* add error message */
    end if;
    rc := '0';
    close l_is_there_row_key_csr;
  end if;
end FND_AUDIT_ROW_KEY;

end FND_AUDIT_UPDATE_PKG;

/
