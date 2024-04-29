--------------------------------------------------------
--  DDL for Package Body WF_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_INSTALL" as
/* $Header: wfpartb.pls 120.5.12010000.4 2012/03/15 18:53:16 alsosa ship $ */
Procedure CreateTable (
  partition   in boolean,
  utl_dir     in varchar2,
  tblname     in varchar2,
  tblspcname  in varchar2 default null,
  modified   out nocopy boolean
)
is
  v_tablespace_name  varchar2(30);
  v_initial        number;
  v_next             number;
  v_pctinc           number;
  v_partitioned      varchar2(3);
  v_new_table        varchar2(30);
  v_old_table        varchar2(30);
  v_sql              varchar2(5000);
  v_dummy            varchar2(1);
  v_freelist_groups   varchar2(30);
  v_initrans         varchar2(30);
  v_pctfree          varchar2(30);
  v_pctused          varchar2(30);
    v_degree           varchar2(30);
  i_file_handle      utl_file.file_type;

begin
   begin
     if (partition) then
       i_file_handle := utl_file.fopen(utl_dir,'wfpart.sql','a',32767);
       SELECT TABLESPACE_NAME, INITIAL_EXTENT, NEXT_EXTENT,
              PCT_INCREASE,PARTITIONED
       INTO   v_tablespace_name, v_initial, v_next,
              v_pctinc, v_partitioned
       FROM   USER_TABLES
       WHERE  TABLE_NAME = tblname;

       -- initial extent could be much larger than next extent
       -- if it is greater than 10M, we made next extent at least 10M
       -- otherwise, we choose next extent to be at least 1M.
       if (v_initial > 10485760) then
         v_next := greatest(v_next,10485760);
       else
         v_next := greatest(v_next,1048576);
       end if;
    else
      i_file_handle := utl_file.fopen(utl_dir,'wfunpart.sql','a',32767);
      SELECT  NVL(UT.TABLESPACE_NAME,UPT.DEF_TABLESPACE_NAME),
              TO_CHAR(GREATEST(NVL(UT.INITIAL_EXTENT,
              TO_NUMBER(UPT.DEF_INITIAL_EXTENT)),65536)),
              TO_CHAR(GREATEST(NVL(UT.NEXT_EXTENT,
              TO_NUMBER(UPT.DEF_NEXT_EXTENT)),65536)),
              NVL(to_char(UT.PCT_INCREASE),UPT.DEF_PCT_INCREASE),
              UT.PARTITIONED
      INTO    v_tablespace_name, v_initial, v_next, v_pctinc, v_partitioned
      FROM    USER_PART_TABLES    UPT,
              USER_TABLES         UT
      WHERE   UT.TABLE_NAME       = tblname
      AND     UPT.TABLE_NAME(+) = UT.TABLE_NAME;

      -- In a partitioned table, next extent is much bigger, so we use that
      -- to calculate initial extent.  We estimated unpartitioned initial
      -- extent is 10 times of that partitioned next extent, but no less
      -- than 1M.
      -- the select above does not seem to get the next extent we defined
      -- during partitioning of the table so we hard code the value later.
      -- v_initial := greatest(v_next * 10, 1048576);
      v_next := 1048576;  -- set next extent to 1M

     end if;
  exception
    when NO_DATA_FOUND then
      utl_file.put_line(i_file_handle,'--Error while querying storage parameters.');
      utl_file.put_line(i_file_handle,'-- Table '||tblname||
                                      ' does not exist.');
      utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');
      utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
      utl_file.fflush(i_file_handle);
      utl_file.fclose(i_file_handle);
      raise_application_error(-20001,'Missing table '||tblname);
    when OTHERS then
      utl_file.put_line(i_file_handle,'--Error while querying storage parameters.');
      utl_file.fclose(i_file_handle);
      raise;
  end;

  if (partition) then
    if (v_partitioned = 'YES') then
      -- already partitioned.  Just exit.
      utl_file.put_line(i_file_handle,'--Table '||tblname||
                                      ' already partitioned .');
      utl_file.fclose(i_file_handle);
      modified := FALSE;
      return;
    end if;

    if (tblspcname is not null) then
      v_tablespace_name := tblspcname;
    end if;

    v_new_table := substr('WFN_'||tblname, 1, 30);

    -- check if new table name exists, if so, may ask to drop it.
    begin
      SELECT  null
      INTO    v_dummy from sys.dual
      WHERE   exists (
        SELECT  1
        FROM    USER_OBJECTS
        WHERE   OBJECT_NAME = v_new_table
                      );
      utl_file.put_line(i_file_handle,'--Name conflict.Please first drop '||
                                         v_new_table);
      utl_file.fclose(i_file_handle);
      raise_application_error(-20002, v_new_table||' already exists.');
    exception
      when NO_DATA_FOUND then
        null;
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while checking the new table name.');
        utl_file.fclose(i_file_handle);
        raise;
    end;

    --v_initial := 40K;   -- force it to 40k
    --v_next    := 1M; --force to 1MB


    utl_file.put_line(i_file_handle,'--Creating new table '||v_new_table);
    v_sql :=' create table %s'||'\n'||
            ' pctfree 10'||'\n'||
            ' pctused 80'||'\n'||
            ' initrans 10'||'\n'||
            ' tablespace %s'||'\n'||
            ' storage (initial 40K next %s'||'\n'||
            ' freelists 32 freelist groups 4'||'\n'||
            ' pctincrease %s )' ||'\n'||
            ' parallel '||'\n'||
            ' logging'||'\n'||
            ' partition by range (item_type) '||'\n'||
            ' subpartition by hash (item_key) '||'\n'||
            ' subpartitions 8 ('||'\n'||
            ' partition wf_item1 values less than ('||''''||'A1'||''''||' ) ,' ||'\n'||
            ' partition wf_item2 values less than ('||''''||'AM'||''''||' ) ,' ||'\n'||
            ' partition wf_item3 values less than ('||''''||'AP'||''''||' ) ,' ||'\n'||
            ' partition wf_item4 values less than ('||''''||'AR'||''''||' ) ,' ||'\n'||
            ' partition wf_item5 values less than ('||''''||'AZ'||''''||' ) ,' ||'\n'||
            ' partition wf_item6 values less than ('||''''||'BC'||''''||' ) ,' ||'\n'||
            ' partition wf_item7 values less than ('||''''||'BD'||''''||' ) ,' ||'\n'||
            ' partition wf_item8 values less than ('||''''||'BI'||''''||' ) ,' ||'\n'||
            ' partition wf_item9 values less than ('||''''||'BO'||''''||' ) ,' ||'\n'||
            ' partition wf_item10 values less than ('||''''||'BT'||''''||' ) ,' ||'\n'||
            ' partition wf_item11 values less than ('||''''||'BW'||''''||' ) ,' ||'\n'||
            ' partition wf_item12 values less than ('||''''||'CA'||''''||' ) ,' ||'\n'||
            ' partition wf_item13 values less than ('||''''||'CH'||''''||' ) ,' ||'\n'||
            ' partition wf_item14 values less than ('||''''||'CI'||''''||' ) ,' ||'\n'||
            ' partition wf_item15 values less than ('||''''||'CO'||''''||' ) ,' ||'\n'||
            ' partition wf_item16 values less than ('||''''||'CR'||''''||' ) ,' ||'\n'||
            ' partition wf_item17 values less than ('||''''||'CS'||''''||' ) ,' ||'\n'||
            ' partition wf_item18 values less than ('||''''||'CT'||''''||' ) ,' ||'\n'||
            ' partition wf_item19 values less than ('||''''||'CU'||''''||' ) ,' ||'\n'||
            ' partition wf_item20 values less than ('||''''||'DE'||''''||' ) ,' ||'\n'||
            ' partition wf_item21 values less than ('||''''||'EC'||''''||' ) ,' ||'\n'||
            ' partition wf_item22 values less than ('||''''||'ER'||''''||' ) ,' ||'\n'||
            ' partition wf_item23 values less than ('||''''||'FA'||''''||' ) ,' ||'\n'||
            ' partition wf_item24 values less than ('||''''||'FI'||''''||' ) ,' ||'\n'||
            ' partition wf_item25 values less than ('||''''||'FN'||''''||' ) ,' ||'\n'||
            ' partition wf_item26 values less than ('||''''||'GE'||''''||' ) ,' ||'\n'||
            ' partition wf_item27 values less than ('||''''||'GH'||''''||' ) ,' ||'\n'||
            ' partition wf_item28 values less than ('||''''||'GL'||''''||' ) ,' ||'\n'||
            ' partition wf_item29 values less than ('||''''||'GM'||''''||' ) ,' ||'\n'||
            ' partition wf_item30 values less than ('||''''||'GN'||''''||' ) ,' ||'\n'||
            ' partition wf_item31 values less than ('||''''||'HR'||''''||' ) ,' ||'\n'||
            ' partition wf_item32 values less than ('||''''||'IC'||''''||' ) ,' ||'\n'||
            ' partition wf_item33 values less than ('||''''||'IN'||''''||' ) ,' ||'\n'||
            ' partition wf_item34 values less than ('||''''||'IO'||''''||' ) ,' ||'\n'||
            ' partition wf_item35 values less than ('||''''||'IW'||''''||' ) ,' ||'\n'||
            ' partition wf_item36 values less than ('||''''||'JT'||''''||' ) ,' ||'\n'||
            ' partition wf_item37 values less than ('||''''||'JU'||''''||' ) ,' ||'\n'||
            ' partition wf_item38 values less than ('||''''||'KH'||''''||' ) ,' ||'\n'||
            ' partition wf_item39 values less than ('||''''||'KO'||''''||' ) ,' ||'\n'||
            ' partition wf_item40 values less than ('||''''||'LS'||''''||' ) ,' ||'\n'||
            ' partition wf_item41 values less than ('||''''||'MD'||''''||' ) ,' ||'\n'||
            ' partition wf_item42 values less than ('||''''||'MR'||''''||' ) ,' ||'\n'||
            ' partition wf_item43 values less than ('||''''||'MS'||''''||' ) ,' ||'\n'||
            ' partition wf_item44 values less than ('||''''||'NE'||''''||' ) ,' ||'\n'||
            ' partition wf_item45 values less than ('||''''||'NT'||''''||' ) ,' ||'\n'||
            ' partition wf_item46 values less than ('||''''||'OA'||''''||' ) ,' ||'\n'||
            ' partition wf_item47 values less than ('||''''||'OB'||''''||' ) ,' ||'\n'||
            ' partition wf_item48 values less than ('||''''||'OE'||''''||' ) ,' ||'\n'||
            ' partition wf_item49 values less than ('||''''||'OF'||''''||' ) ,' ||'\n'||
            ' partition wf_item50 values less than ('||''''||'OK'||''''||' ) ,' ||'\n'||
            ' partition wf_item51 values less than ('||''''||'OL'||''''||' ) ,' ||'\n'||
            ' partition wf_item52 values less than ('||''''||'OR'||''''||' ) ,' ||'\n'||
            ' partition wf_item53 values less than ('||''''||'PA'||''''||' ) ,' ||'\n'||
            ' partition wf_item54 values less than ('||''''||'PJ'||''''||' ) ,' ||'\n'||
            ' partition wf_item55 values less than ('||''''||'PM'||''''||' ) ,' ||'\n'||
            ' partition wf_item56 values less than ('||''''||'PO'||''''||' ) ,' ||'\n'||
            ' partition wf_item57 values less than ('||''''||'PQ'||''''||' ) ,' ||'\n'||
            ' partition wf_item58 values less than ('||''''||'PR'||''''||' ) ,' ||'\n'||
            ' partition wf_item59 values less than ('||''''||'QA'||''''||' ) ,' ||'\n'||
            ' partition wf_item60 values less than ('||''''||'RB'||''''||' ) ,' ||'\n'||
            ' partition wf_item61 values less than ('||''''||'RE'||''''||' ) ,' ||'\n'||
            ' partition wf_item62 values less than ('||''''||'RM'||''''||' ) ,' ||'\n'||
            ' partition wf_item63 values less than ('||''''||'RO'||''''||' ) ,' ||'\n'||
            ' partition wf_item64 values less than ('||''''||'SA'||''''||' ) ,' ||'\n'||
            ' partition wf_item65 values less than ('||''''||'SE'||''''||' ) ,' ||'\n'||
            ' partition wf_item66 values less than ('||''''||'SH'||''''||' ) ,' ||'\n'||
            ' partition wf_item67 values less than ('||''''||'SI'||''''||' ) ,' ||'\n'||
            ' partition wf_item68 values less than ('||''''||'SR'||''''||' ) ,' ||'\n'||
            ' partition wf_item69 values less than ('||''''||'SU'||''''||' ) ,' ||'\n'||
            ' partition wf_item70 values less than ('||''''||'SY'||''''||' ) ,' ||'\n'||
            ' partition wf_item71 values less than ('||''''||'TE'||''''||' ) ,' ||'\n'||
            ' partition wf_item72 values less than ('||''''||'TS'||''''||' ) ,' ||'\n'||
            ' partition wf_item73 values less than ('||''''||'WF'||''''||' ) ,' ||'\n'||
            ' partition wf_item74 values less than ('||''''||'WG'||''''||' ) ,' ||'\n'||
            ' partition wf_item75 values less than ('||''''||'WI'||''''||' ) ,' ||'\n'||
            ' partition wf_item76 values less than ('||''''||'WS'||''''||' ) ,' ||'\n'||
            ' partition wf_item77 values less than (MAXVALUE))' ||'\n'||
            ' as select * from %s ; \n';


    begin
     utl_file.putf(i_file_handle,v_sql,v_new_table,v_tablespace_name,
                   to_char(v_next),to_char(v_pctinc),tblname);
     utl_file.fflush(i_file_handle);
    exception
      when utl_file.WRITE_ERROR then
        utl_file.put_line(i_file_handle,'Error writing the dynamic sql into log file');
        utl_file.fclose(i_file_handle);
        raise;
      when utl_file.INTERNAL_ERROR then
        utl_file.put_line(i_file_handle,'Error writing the dynamic sql into log file');
        utl_file.fclose(i_file_handle);
        raise;
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        utl_file.fclose(i_file_handle);
        raise;
    end;

    utl_file.put_line(i_file_handle,'--Changing new table '||
                                  v_new_table||' to noparalle,logging');
    v_sql :='alter table %s'||'\n'||
            'noparallel  '||'\n'||
            'logging;'||'\n';
    begin
      utl_file.putf(i_file_handle,v_sql,v_new_table);
      utl_file.fflush(i_file_handle);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;
    -- rename orig table to old table
    v_old_table := substr('WFO_'||tblname, 1, 30);
    v_sql := 'alter table '||tblname||' rename to '||v_old_table||';';
    begin
      utl_file.put_line(i_file_handle,'--Execute the following statement :');
      utl_file.put_line(i_file_handle,v_sql);
      utl_file.putf(i_file_handle,' '||'\n');
    exception
      when OTHERS then
       utl_file.put_line(i_file_handle,'--Error in: '||substr(v_sql,1,220));
       utl_file.fclose(i_file_handle);
       raise;
    end;

    -- rename new table to orig table
    v_sql := 'alter table '||v_new_table||' rename to '||tblname||';';
    begin
      utl_file.put_line(i_file_handle,'--Execute the following statement :');
      utl_file.put_line(i_file_handle,v_sql);
      utl_file.putf(i_file_handle,' '||'\n');
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error in: '||substr(v_sql,1,220));
        utl_file.fclose(i_file_handle);
        raise_application_error(-20005,'Error in SQL: '||substr(v_sql,1,3000));
    end;
  else
   --If the table is already unpartitioned
   if (v_partitioned = 'NO') then
      -- already unpartitioned.  Just exit.
      utl_file.put_line(i_file_handle,'--Table '||tblname||
                                      ' not partitioned .');
      utl_file.fclose(i_file_handle);
      modified := FALSE;
      return;
    end if;

    begin
      SELECT to_char(least(to_number(VALUE),8)),
             to_char(least(to_number(VALUE),4))
      INTO   v_freelist_groups, v_initrans
      FROM   V$PARAMETER
      WHERE  NAME = 'cpu_count';
    exception
      when NO_DATA_FOUND then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        utl_file.put_line(i_file_handle,'-- View V$PARAMETER does not exist.');
        utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');
        utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
        raise_application_error(-20001,'Missing view V$PARAMETER');
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        raise;
    end;
    begin
      SELECT to_char(min(to_number(VALUE)))
      INTO   v_degree
      FROM   V$PARAMETER
      WHERE  NAME IN ('parallel_max_servers','cpu_count');
    exception
      when NO_DATA_FOUND then
        utl_file.put_line(i_file_handle,'--Error while querying number parallel degree.');
        utl_file.put_line(i_file_handle,'-- View V$PARAMETER does not exist.');
        utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');
        utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
        raise_application_error(-20001,'Missing view V$PARAMETER');
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        raise;
    end;
    if (tblspcname is not null) then
      v_tablespace_name := tblspcname;
    end if;


    v_new_table := 'NN'||substr(tblname, 3, 30);

    -- check if new table name exists, if so, may ask to drop it.
    begin
      SELECT  null
      INTO    v_dummy
      FROM    sys.dual
      WHERE   exists (SELECT 1
                      FROM   USER_OBJECTS
                      WHERE  OBJECT_NAME = v_new_table
                      );
      utl_file.put_line(i_file_handle,'Name conflict.  Please first drop '||
                                       v_new_table);
      raise_application_error(-20002, v_new_table||' already exists.');
    exception
      when NO_DATA_FOUND then
        null;
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while checking the new table name.');
        raise;
    end;

    --v_initial  := 1M;      -- Force it to smaller 1MB
    v_pctinc  := 0;
    v_pctused := '40';

    if (tblname = 'WF_ITEM_ACTIVITY_STATUSES') then
      v_initial := 104857600;   -- 100M
      v_pctfree := '40';
    elsif (tblname = 'WF_ITEM_ACTIVITY_STATUSES_H') then
      v_initial := 104857600;   -- 100M
      v_pctfree := '0';
    elsif (tblname = 'WF_ITEM_ATTRIBUTE_VALUES') then
      v_initial := 104857600;   -- 100M
      v_pctfree := '30';
    elsif (tblname = 'WF_ITEMS') then
      v_initial := 10485760;    -- 10M
      v_pctfree := '30';
    end if;

    -- Creating new table
  begin
    utl_file.put_line(i_file_handle,'--Creating new table '||v_new_table);
    v_sql := ' create table %s'||'\n'||
             ' pctfree %s'||'\n'||
             ' pctused %s'||'\n'||
             ' initrans %s'||'\n'||
             ' tablespace %s';

    utl_file.putf(i_file_handle,v_sql,v_new_table,v_pctfree,
                    v_pctused,v_initrans,v_tablespace_name);
    utl_file.putf(i_file_handle,'\n');
    utl_file.fflush(i_file_handle);
    v_sql :=  ' storage (initial %s  next %s '||'\n'||
              ' freelists 2 freelist groups %s'||'\n'||
              ' pctincrease 0 )' ||'\n'||
              ' parallel %s'||'\n'||
              ' logging'||
              ' as select * from %s ;'||'\n';

     utl_file.putf(i_file_handle,v_sql,
                     to_char(v_initial),to_char(v_next),v_freelist_groups,
                     v_degree,tblname);
     utl_file.fflush(i_file_handle);
   exception
     when utl_file.WRITE_ERROR then
       utl_file.put_line(i_file_handle,'--Error writing the dynamic sql into log file');
       utl_file.fclose(i_file_handle);
       raise;
     when utl_file.INTERNAL_ERROR then
       utl_file.put_line(i_file_handle,'Error writing the dynamic sql into log file');
       utl_file.fclose(i_file_handle);
       raise;
     when OTHERS then
       utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
       utl_file.fclose(i_file_handle);
       raise;
   end;

    -- changing new table
    utl_file.put_line(i_file_handle,'--Changing new table '||
                                  v_new_table||' to logging');
    v_sql :='alter table %s'||'\n'||
            'noparallel  '||'\n'||
            'logging;'||'\n';
    begin
      utl_file.putf(i_file_handle,v_sql,v_new_table);
      utl_file.fflush(i_file_handle);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;
     -- gathering CBO stats
    utl_file.put_line(i_file_handle,'--Gathering CBO Stats on new table '||v_new_table);
  --  begin
  --  utl_file.put_line(apps.fnd_stats.gather_table_stats(ownname => 'APPLSYS',
  --                                   tabname => v_new_table);
  --   null;
  --  end;

    -- rename orig table to old table
    v_old_table := 'OO'||substr(tblname, 3, 28);
    utl_file.put_line(i_file_handle,'--Rename '||tblname||' to '||v_old_table);
    v_sql := 'alter table '||tblname||' rename to '||v_old_table||';';
    begin
      utl_file.put_line(i_file_handle,v_sql);
      utl_file.putf(i_file_handle,'\n');
      utl_file.fflush(i_file_handle);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in: '||substr(v_sql,1,220));
        raise;
    end;

    -- rename new table to orig table
    utl_file.put_line(i_file_handle,'--Rename '||v_new_table||
                                    ' to '||tblname);
    v_sql := 'alter table '||v_new_table||' rename to '||tblname||';';
    begin
      utl_file.put_line(i_file_handle,v_sql);
      utl_file.putf(i_file_handle,'\n');
    exception
      when OTHERS then
        raise_application_error(-20005,'Error in SQL: '||substr(v_sql,1,220));
    end;
  end if;
  utl_file.fclose(i_file_handle);
  --set the out parameter value to TRUE for indicating
  --whether or not we sould create index or not.
  --If the table is already partitioned then we set this parameter
  --to FALSE to indicate we don't need to recreate indexes on it.
  modified := TRUE;
exception
  when OTHERS then
    utl_file.put_line(i_file_handle,'--Error in CreateTable '||tblname);
    if (utl_file.is_open(i_file_handle)) then
       utl_file.fclose(i_file_handle);
    end if;
    raise;
end CreateTable;

Procedure CreateIndex (
  partition in boolean ,
  utl_dir   in varchar2,
  idxname    in varchar2,
  tblspcname in varchar2 default null
)
is
  v_tablespace_name  varchar2(30);
  v_initial          number;
  v_next             number;
  v_pctinc           number;
  v_tblpartitioned   varchar2(3);
  v_idxpartitioned   varchar2(3);
  v_prefix           varchar2(8);
  v_new_index        varchar2(30);
  v_old_index        varchar2(30);
  v_sql              varchar2(4000);
  v_dummy            varchar2(1);
  partition_index    boolean := false;
  drop_index         boolean := false;
  v_freelist_groups  varchar2(30);
  v_initrans         varchar2(30);
  v_pctfree          varchar2(30);
  v_degree           varchar2(30);
  i_file_handle      utl_file.file_type;
begin
 begin
  if (partition) then
    i_file_handle := utl_file.fopen(utl_dir,'wfpart.sql','a',32767);
    utl_file.putf(i_file_handle,' '||'\n');
    SELECT  I.TABLESPACE_NAME, I.INITIAL_EXTENT, I.NEXT_EXTENT, I.PCT_INCREASE,
            I.PARTITIONED, T.PARTITIONED
    INTO    v_tablespace_name, v_initial, v_next, v_pctinc,
            v_idxpartitioned, v_tblpartitioned
    FROM    USER_INDEXES I, USER_TABLES T
    WHERE   I.INDEX_NAME = idxname
    AND     I.TABLE_NAME = T.TABLE_NAME;

    -- initial extent could be much larger than next extent
    -- if it is greater than 10M, we made next extent at least 10M
    -- otherwise, we choose next extent to be at least 1M.
    if (v_initial > 10485760) then
      v_next := greatest(v_next,10485760);
    else
      v_next := greatest(v_next,1048576);
    end if;
  else
    i_file_handle := utl_file.fopen(utl_dir,'wfunpart.sql','a',32767);
    SELECT  NVL(I.TABLESPACE_NAME,UPI.DEF_TABLESPACE_NAME),
            TO_CHAR(GREATEST(NVL(I.INITIAL_EXTENT,
            TO_NUMBER(UPI.DEF_INITIAL_EXTENT)),65536)),
            TO_CHAR(GREATEST(NVL(I.NEXT_EXTENT,
            TO_NUMBER(UPI.DEF_NEXT_EXTENT)),65536)),
            NVL(to_char(I.PCT_INCREASE),UPI.DEF_PCT_INCREASE),
            I.PARTITIONED, T.PARTITIONED
    INTO    v_tablespace_name, v_initial, v_next, v_pctinc,
            v_idxpartitioned, v_tblpartitioned
    FROM    USER_INDEXES I, USER_TABLES T, USER_PART_INDEXES UPI
    WHERE   I.INDEX_NAME = idxname
    AND     I.TABLE_NAME = T.TABLE_NAME
    AND     UPI.INDEX_NAME(+) = I.INDEX_NAME;

    -- In a partitioned index, next extent is much bigger, so we use that
    -- to calculate initial extent.  We estimated unpartitioned initial
    -- extent is 10 times of that partitioned next extent, but no less
    -- than 1M.
    -- the select above does not seem to get the next extent we defined
    -- during partitioning of the table so we hard code the value later.
    -- v_initial := greatest(v_next * 10, 1048576);
    v_next := 1048576;  -- set next extent to 1M

  end if;
 exception
    when NO_DATA_FOUND then
      utl_file.put_line(i_file_handle,'--Error while querying storage parameters.');
      utl_file.put_line(i_file_handle,'-- Index '||idxname||
                                      ' does not exist.');
      utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');
      utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
      utl_file.fflush(i_file_handle);
      utl_file.fclose(i_file_handle);
      raise_application_error(-20011,'Missing index '||idxname);
    when OTHERS then
      utl_file.put_line(i_file_handle,'--Error while querying storage parameters.');
      utl_file.fclose(i_file_handle);
      raise;
  end;

  if (partition) then
    if (tblspcname is not null) then
      v_tablespace_name := tblspcname;
    end if;

    v_new_index := substr('WFN_'||idxname, 1, 30);

    -- check if new index name exists, if so, may ask to drop it.
    begin
      SELECT null
      INTO   v_dummy
      FROM   sys.dual
      WHERE  exists (
             SELECT  1
             FROM    USER_OBJECTS
             WHERE   OBJECT_NAME = v_new_index
                    );
     utl_file.put_line(i_file_handle,'--Name conflict.  Please first drop '||v_new_index);
     utl_file.fclose(i_file_handle);
     raise_application_error(-20012, v_new_index||' already exists.');
   exception
     when NO_DATA_FOUND then
       null;
     when OTHERS then
       utl_file.put_line(i_file_handle,'--Error while checking the new index name.');
       utl_file.fclose(i_file_handle);
       raise;
   end;

   utl_file.put_line(i_file_handle,'--Recreate index '||idxname);
   v_prefix := 'WFO_';
   --v_initial := 40K; -- force it to 40k
   if (idxname = 'WF_ITEM_ACTIVITY_STATUSES_PK') then
     partition_index := true;
     v_prefix := 'WFP_';
     v_sql := 'create unique index %s'||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging'||'\n'||
              ' local ('||'\n'||
              ' partition wf_item1,' ||'\n'||
              ' partition wf_item2,' ||'\n'||
              ' partition wf_item3,' ||'\n'||
              ' partition wf_item4,' ||'\n'||
              ' partition wf_item5,' ||'\n'||
              ' partition wf_item6,' ||'\n'||
              ' partition wf_item7,' ||'\n'||
              ' partition wf_item8,' ||'\n'||
              ' partition wf_item9,' ||'\n'||
              ' partition wf_item10,' ||'\n'||
              ' partition wf_item11,' ||'\n'||
              ' partition wf_item12,' ||'\n'||
              ' partition wf_item13,' ||'\n'||
              ' partition wf_item14,' ||'\n'||
              ' partition wf_item15,' ||'\n'||
              ' partition wf_item16,' ||'\n'||
              ' partition wf_item17,' ||'\n'||
              ' partition wf_item18,' ||'\n'||
              ' partition wf_item19,' ||'\n'||
              ' partition wf_item20,' ||'\n'||
              ' partition wf_item21,' ||'\n'||
              ' partition wf_item22,' ||'\n'||
              ' partition wf_item23,' ||'\n'||
              ' partition wf_item24,' ||'\n'||
              ' partition wf_item25,' ||'\n'||
              ' partition wf_item26,' ||'\n'||
              ' partition wf_item27,' ||'\n'||
              ' partition wf_item28,' ||'\n'||
              ' partition wf_item29,' ||'\n'||
              ' partition wf_item30,' ||'\n'||
              ' partition wf_item31,' ||'\n'||
              ' partition wf_item32,' ||'\n'||
              ' partition wf_item33,' ||'\n'||
              ' partition wf_item34,' ||'\n'||
              ' partition wf_item35,' ||'\n'||
              ' partition wf_item36,' ||'\n'||
              ' partition wf_item37,' ||'\n'||
              ' partition wf_item38,' ||'\n'||
              ' partition wf_item39,' ||'\n'||
              ' partition wf_item40,' ||'\n'||
              ' partition wf_item41,' ||'\n'||
              ' partition wf_item42,' ||'\n'||
              ' partition wf_item43,' ||'\n'||
              ' partition wf_item44,' ||'\n'||
              ' partition wf_item45,' ||'\n'||
              ' partition wf_item46,' ||'\n'||
              ' partition wf_item47,' ||'\n'||
              ' partition wf_item48,' ||'\n'||
              ' partition wf_item49,' ||'\n'||
              ' partition wf_item50,' ||'\n'||
              ' partition wf_item51,' ||'\n'||
              ' partition wf_item52,' ||'\n'||
              ' partition wf_item53,' ||'\n'||
              ' partition wf_item54,' ||'\n'||
              ' partition wf_item55,' ||'\n'||
              ' partition wf_item56,' ||'\n'||
              ' partition wf_item57,' ||'\n'||
              ' partition wf_item58,' ||'\n'||
              ' partition wf_item59,' ||'\n'||
              ' partition wf_item60,' ||'\n'||
              ' partition wf_item61,' ||'\n'||
              ' partition wf_item62,' ||'\n'||
              ' partition wf_item63,' ||'\n'||
              ' partition wf_item64,' ||'\n'||
              ' partition wf_item65,' ||'\n'||
              ' partition wf_item66,' ||'\n'||
              ' partition wf_item67,' ||'\n'||
              ' partition wf_item68,' ||'\n'||
              ' partition wf_item69,' ||'\n'||
              ' partition wf_item70,' ||'\n'||
              ' partition wf_item71,' ||'\n'||
              ' partition wf_item72,' ||'\n'||
              ' partition wf_item73,' ||'\n'||
              ' partition wf_item74,' ||'\n'||
              ' partition wf_item75,' ||'\n'||
              ' partition wf_item76,' ||'\n'||
              ' partition wf_item77);';

   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N1') then
     v_prefix := 'WF1_';
     v_sql := 'create index %s '||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (ACTIVITY_STATUS, ITEM_TYPE, PROCESS_ACTIVITY)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N2') then
     v_prefix := 'WF2_';
     v_sql := 'create index %s '||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (NOTIFICATION_ID)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N3') then
     v_prefix := 'WF3_';
     v_sql := 'create index %s'||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (ITEM_TYPE,DUE_DATE)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )'||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N4') then
     v_prefix := 'WF4_';
     v_sql := 'create index %s'||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (ASSIGNED_USER, ITEM_TYPE)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )'||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N5') then
     v_prefix := 'WF5_';
     v_sql := 'create index %s'||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES (ITEM_TYPE, ACTIVITY_STATUS, DUE_DATE)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )'||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N1') then
     v_prefix := 'WFH1_';
     v_sql := 'create index %s '||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES_H (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N2') then
     v_prefix := 'WFH2_';
     v_sql := 'create index %s '||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES_H (NOTIFICATION_ID)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N3') then
     v_prefix := 'WFH3_';
     v_sql := 'create index %s '||'\n'||
              ' on WF_ITEM_ACTIVITY_STATUSES_H (ASSIGNED_USER)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging;';
   elsif (idxname = 'WF_ITEM_ATTRIBUTE_VALUES_PK') then
     partition_index := true;
     v_sql := 'create unique index %s '||'\n'||
              ' on WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME)'||'\n'||
              ' pctfree 10'||'\n'||
              ' initrans 10'||'\n'||
              ' tablespace %s '||'\n'||
              ' storage (initial 40K next %s '||'\n'||
              ' freelists 32 freelist groups 4'||'\n'||
              ' pctincrease %s )' ||'\n'||
              ' logging'||'\n'||
              ' local ('||'\n'||
              ' partition wf_item1,' ||'\n'||
              ' partition wf_item2,' ||'\n'||
              ' partition wf_item3,' ||'\n'||
              ' partition wf_item4,' ||'\n'||
              ' partition wf_item5,' ||'\n'||
              ' partition wf_item6,' ||'\n'||
              ' partition wf_item7,' ||'\n'||
              ' partition wf_item8,' ||'\n'||
              ' partition wf_item9,' ||'\n'||
              ' partition wf_item10,' ||'\n'||
              ' partition wf_item11,' ||'\n'||
              ' partition wf_item12,' ||'\n'||
              ' partition wf_item13,' ||'\n'||
              ' partition wf_item14,' ||'\n'||
              ' partition wf_item15,' ||'\n'||
              ' partition wf_item16,' ||'\n'||
              ' partition wf_item17,' ||'\n'||
              ' partition wf_item18,' ||'\n'||
              ' partition wf_item19,' ||'\n'||
              ' partition wf_item20,' ||'\n'||
              ' partition wf_item21,' ||'\n'||
              ' partition wf_item22,' ||'\n'||
              ' partition wf_item23,' ||'\n'||
              ' partition wf_item24,' ||'\n'||
              ' partition wf_item25,' ||'\n'||
              ' partition wf_item26,' ||'\n'||
              ' partition wf_item27,' ||'\n'||
              ' partition wf_item28,' ||'\n'||
              ' partition wf_item29,' ||'\n'||
              ' partition wf_item30,' ||'\n'||
              ' partition wf_item31,' ||'\n'||
              ' partition wf_item32,' ||'\n'||
              ' partition wf_item33,' ||'\n'||
              ' partition wf_item34,' ||'\n'||
              ' partition wf_item35,' ||'\n'||
              ' partition wf_item36,' ||'\n'||
              ' partition wf_item37,' ||'\n'||
              ' partition wf_item38,' ||'\n'||
              ' partition wf_item39,' ||'\n'||
              ' partition wf_item40,' ||'\n'||
              ' partition wf_item41,' ||'\n'||
              ' partition wf_item42,' ||'\n'||
              ' partition wf_item43,' ||'\n'||
              ' partition wf_item44,' ||'\n'||
              ' partition wf_item45,' ||'\n'||
              ' partition wf_item46,' ||'\n'||
              ' partition wf_item47,' ||'\n'||
              ' partition wf_item48,' ||'\n'||
              ' partition wf_item49,' ||'\n'||
              ' partition wf_item50,' ||'\n'||
              ' partition wf_item51,' ||'\n'||
              ' partition wf_item52,' ||'\n'||
              ' partition wf_item53,' ||'\n'||
              ' partition wf_item54,' ||'\n'||
              ' partition wf_item55,' ||'\n'||
              ' partition wf_item56,' ||'\n'||
              ' partition wf_item57,' ||'\n'||
              ' partition wf_item58,' ||'\n'||
              ' partition wf_item59,' ||'\n'||
              ' partition wf_item60,' ||'\n'||
              ' partition wf_item61,' ||'\n'||
              ' partition wf_item62,' ||'\n'||
              ' partition wf_item63,' ||'\n'||
              ' partition wf_item64,' ||'\n'||
              ' partition wf_item65,' ||'\n'||
              ' partition wf_item66,' ||'\n'||
              ' partition wf_item67,' ||'\n'||
              ' partition wf_item68,' ||'\n'||
              ' partition wf_item69,' ||'\n'||
              ' partition wf_item70,' ||'\n'||
              ' partition wf_item71,' ||'\n'||
              ' partition wf_item72,' ||'\n'||
              ' partition wf_item73,' ||'\n'||
              ' partition wf_item74,' ||'\n'||
              ' partition wf_item75,' ||'\n'||
              ' partition wf_item76,' ||'\n'||
              ' partition wf_item77);';
   elsif (idxname = 'WF_ITEMS_PK') then
     partition_index := true;
     v_sql:= 'create unique index %s '||'\n'||
             ' on WF_ITEMS (ITEM_TYPE, ITEM_KEY)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K  next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging'||'\n'||
             ' local ('||'\n'||
             ' partition wf_item1,' ||'\n'||
             ' partition wf_item2,' ||'\n'||
             ' partition wf_item3,' ||'\n'||
             ' partition wf_item4,' ||'\n'||
             ' partition wf_item5,' ||'\n'||
             ' partition wf_item6,' ||'\n'||
             ' partition wf_item7,' ||'\n'||
             ' partition wf_item8,' ||'\n'||
             ' partition wf_item9,' ||'\n'||
             ' partition wf_item10,' ||'\n'||
             ' partition wf_item11,' ||'\n'||
             ' partition wf_item12,' ||'\n'||
             ' partition wf_item13,' ||'\n'||
             ' partition wf_item14,' ||'\n'||
             ' partition wf_item15,' ||'\n'||
             ' partition wf_item16,' ||'\n'||
             ' partition wf_item17,' ||'\n'||
             ' partition wf_item18,' ||'\n'||
             ' partition wf_item19,' ||'\n'||
             ' partition wf_item20,' ||'\n'||
             ' partition wf_item21,' ||'\n'||
             ' partition wf_item22,' ||'\n'||
             ' partition wf_item23,' ||'\n'||
             ' partition wf_item24,' ||'\n'||
             ' partition wf_item25,' ||'\n'||
             ' partition wf_item26,' ||'\n'||
             ' partition wf_item27,' ||'\n'||
             ' partition wf_item28,' ||'\n'||
             ' partition wf_item29,' ||'\n'||
             ' partition wf_item30,' ||'\n'||
             ' partition wf_item31,' ||'\n'||
             ' partition wf_item32,' ||'\n'||
             ' partition wf_item33,' ||'\n'||
             ' partition wf_item34,' ||'\n'||
             ' partition wf_item35,' ||'\n'||
             ' partition wf_item36,' ||'\n'||
             ' partition wf_item37,' ||'\n'||
             ' partition wf_item38,' ||'\n'||
             ' partition wf_item39,' ||'\n'||
             ' partition wf_item40,' ||'\n'||
             ' partition wf_item41,' ||'\n'||
             ' partition wf_item42,' ||'\n'||
             ' partition wf_item43,' ||'\n'||
             ' partition wf_item44,' ||'\n'||
             ' partition wf_item45,' ||'\n'||
             ' partition wf_item46,' ||'\n'||
             ' partition wf_item47,' ||'\n'||
             ' partition wf_item48,' ||'\n'||
             ' partition wf_item49,' ||'\n'||
             ' partition wf_item50,' ||'\n'||
             ' partition wf_item51,' ||'\n'||
             ' partition wf_item52,' ||'\n'||
             ' partition wf_item53,' ||'\n'||
             ' partition wf_item54,' ||'\n'||
             ' partition wf_item55,' ||'\n'||
             ' partition wf_item56,' ||'\n'||
             ' partition wf_item57,' ||'\n'||
             ' partition wf_item58,' ||'\n'||
             ' partition wf_item59,' ||'\n'||
             ' partition wf_item60,' ||'\n'||
             ' partition wf_item61,' ||'\n'||
             ' partition wf_item62,' ||'\n'||
             ' partition wf_item63,' ||'\n'||
             ' partition wf_item64,' ||'\n'||
             ' partition wf_item65,' ||'\n'||
             ' partition wf_item66,' ||'\n'||
             ' partition wf_item67,' ||'\n'||
             ' partition wf_item68,' ||'\n'||
             ' partition wf_item69,' ||'\n'||
             ' partition wf_item70,' ||'\n'||
             ' partition wf_item71,' ||'\n'||
             ' partition wf_item72,' ||'\n'||
             ' partition wf_item73,' ||'\n'||
             ' partition wf_item74,' ||'\n'||
             ' partition wf_item75,' ||'\n'||
             ' partition wf_item76,' ||'\n'||
             ' partition wf_item77);';
  elsif (idxname = 'WF_ITEMS_N1') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (PARENT_ITEM_TYPE, PARENT_ITEM_KEY)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';
  elsif (idxname = 'WF_ITEMS_N2') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (BEGIN_DATE)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';
  elsif (idxname = 'WF_ITEMS_N3') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (END_DATE)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';
  elsif (idxname = 'WF_ITEMS_N4') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (ITEM_TYPE,ROOT_ACTIVITY,OWNER_ROLE)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';
  elsif (idxname = 'WF_ITEMS_N5') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (USER_KEY)'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';
  elsif (idxname = 'WF_ITEMS_N6') then
    v_sql := 'create index %s '||'\n'||
             ' on WF_ITEMS (OWNER_ROLE )'||'\n'||
             ' pctfree 10'||'\n'||
             ' initrans 10'||'\n'||
             ' tablespace %s '||'\n'||
             ' storage (initial 40K next %s '||'\n'||
             ' freelists 32 freelist groups 4'||'\n'||
             ' pctincrease %s )' ||'\n'||
             ' logging;';

  end if;

  -- now check if we need to proceed
  if (partition_index) then
    if (v_idxpartitioned = 'YES') then
      -- already partitioned.  Just exit.
      utl_file.put_line(i_file_handle,'--Index '||idxname||
                                         ' already partitioned.');
      utl_file.fflush(i_file_handle);
      utl_file.fclose(i_file_handle);
      return;
    elsif (v_tblpartitioned = 'YES') then
      -- first drop the index
      drop_index := true;
      begin
        utl_file.put_line(i_file_handle,'--Execute the statement fist to drop the existing index');
        utl_file.put_line(i_file_handle,'Drop index '||idxname);
        utl_file.putf(i_file_handle,' '||'\n');
      exception
        when OTHERS then
          utl_file.put_line(i_file_handle,'--Error in SQL: '||
                                 substr('drop index '||idxname,1,200));
          utl_file.fclose(i_file_handle);
          raise;
      end;

    end if;
  else
    if (v_tblpartitioned = 'YES') then
      -- Detected table partitioned meant this script had already been run.
      -- Just exit.
      utl_file.put_line(i_file_handle,'--Table for index '||idxname||' already partitioned.');
      utl_file.fclose(i_file_handle);
      return;
    end if;
  end if;

  begin
   utl_file.put_line(i_file_handle,'-- Execute the statement to create index '||                                                  v_new_index);
   utl_file.putf(i_file_handle,v_sql,v_new_index,v_tablespace_name,
                 to_char(v_next),to_char(v_pctinc));
   utl_file.putf(i_file_handle,'\n');
   utl_file.fflush(i_file_handle);
  exception
    when UTL_FILE.WRITE_ERROR then
      utl_file.put_line(i_file_handle,'--Error writing sql '||
                                      substr(v_sql,1,220)||'to file');
      utl_file.fclose(i_file_handle);
      raise;
    when UTL_FILE.INVALID_FILEHANDLE then
      utl_file.put_line(i_file_handle,'--Error : Invalid file handle ');
      utl_file.fclose(i_file_handle);
      raise;
    when UTL_FILE.INVALID_OPERATION then
      utl_file.put_line(i_file_handle,'--Error : Invalid operation');
      utl_file.fclose(i_file_handle);
      raise;
    when OTHERS then
      utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
      utl_file.fclose(i_file_handle);
      raise;
    end;

    -- Rename only if we did not drop index before
    if (not drop_index) then
      -- rename orig index to old index
      v_old_index := substr(v_prefix||idxname, 1, 30);
      utl_file.put_line(i_file_handle,'--Rename '||idxname||' to '||
                              v_old_index);
      v_sql := 'alter index '||idxname||' rename to '||v_old_index||';';
      begin
        utl_file.put_line(i_file_handle,'--Execute the statement :');
        utl_file.put_line(i_file_handle,v_sql);
        utl_file.putf(i_file_handle,'\n');
      exception
        when UTL_FILE.WRITE_ERROR then
          utl_file.put_line(i_file_handle,'--Error writing sql '||
                        substr(v_sql,1,220)||'to file');
          utl_file.fclose(i_file_handle);
          raise;
        when UTL_FILE.INVALID_FILEHANDLE then
          utl_file.put_line(i_file_handle,'--Error : Invalid file handle ');
          utl_file.fclose(i_file_handle);
          raise;
         when UTL_FILE.INVALID_OPERATION then
           utl_file.put_line(i_file_handle,'--Error : Invalid operation');
           utl_file.fclose(i_file_handle);
           raise;
         when others then
           utl_file.fclose(i_file_handle);
           raise;
         end;
      end if;

    -- rename new index to orig index
    utl_file.put_line(i_file_handle,'--Rename '||v_new_index||' to '||idxname);
    v_sql := 'alter index '||v_new_index||' rename to '||idxname||';';
    begin
     utl_file.put_line(i_file_handle,'--Execute the following sql :');
     utl_file.put_line(i_file_handle,v_sql);
     utl_file.putf(i_file_handle,' '||'\n');
    exception
      when UTL_FILE.WRITE_ERROR then
        utl_file.put_line(i_file_handle,'--Error writing sql '||
                                substr(v_sql,1,220)||'to file');
        utl_file.fclose(i_file_handle);
        raise;
      when UTL_FILE.INVALID_FILEHANDLE then
        utl_file.put_line(i_file_handle,'--Error : Invalid file handle ');
        utl_file.fclose(i_file_handle);
        raise;
      when UTL_FILE.INVALID_OPERATION then
        utl_file.put_line(i_file_handle,'--Error : Invalid operation');
        utl_file.fclose(i_file_handle);
        raise;
      when others then
        utl_file.fclose(i_file_handle);
        raise;
    end;

  else
    begin
      SELECT to_char(least(to_number(VALUE),8)),
             to_char(least(to_number(VALUE)*2,8))
      INTO   v_freelist_groups, v_initrans
      FROM   V$PARAMETER
      WHERE  NAME = 'cpu_count';
    exception
      when NO_DATA_FOUND then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        utl_file.put_line(i_file_handle,'-- View V$PARAMETER does not exist.');
        utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');
        utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
        raise_application_error(-20001,'Missing view V$PARAMETER');
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        raise;
    end;

    begin
      SELECT to_char(min(to_number(VALUE)))
      INTO   v_degree
      FROM   V$PARAMETER
      WHERE  NAME IN ('parallel_max_servers','cpu_count');
    exception
      when NO_DATA_FOUND then
        utl_file.put_line(i_file_handle,'--Error while querying number parallel degree.');
         utl_file.put_line(i_file_handle,'-- View V$PARAMETER does not exist.');
         utl_file.put_line(i_file_handle,'-- Please check if you login to the correct user, database,');

        utl_file.put_line(i_file_handle,'-- and that application installation has been completed successfully.');
        raise_application_error(-20001,'Missing view V$PARAMETER');

      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while querying number of CPUs.');
        raise;
    end;

    if (tblspcname is not null) then
      v_tablespace_name := tblspcname;
    end if;

    v_new_index := 'NN'||substr(idxname, 3, 30);

    -- check if new index name exists, if so, may ask to drop it.
    begin
      select null
      into   v_dummy
      from   sys.dual
      where  exists (select 1
                     from   USER_OBJECTS
                     where  OBJECT_NAME = v_new_index
                     );
      utl_file.put_line(i_file_handle,'Name conflict.  Please first drop '||v_new_index);
      raise_application_error(-20012, v_new_index||' already exists.');
    exception
      when NO_DATA_FOUND then
        null;
      when OTHERS then
        utl_file.put_line(i_file_handle,'--Error while checking the new index name.');
        raise;
    end;


    utl_file.put_line(i_file_handle,'--Recreating index '||idxname);

--  v_initial := v_next;  -- force it to uniform size
--  v_initial := 1M;
    v_pctinc  := '0';
    v_pctfree := '0';

    begin
      utl_file.put_line(i_file_handle,'--Create index '||v_new_index);

      if (idxname = 'WF_ITEM_ACTIVITY_STATUSES_PK') then
        v_sql := 'create unique index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N1') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (ACTIVITY_STATUS, ITEM_TYPE, PROCESS_ACTIVITY)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N2') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (NOTIFICATION_ID)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N3') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (DUE_DATE, ITEM_TYPE)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N4') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (ASSIGNED_USER, ITEM_TYPE)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_N5') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES (ITEM_TYPE, ACTIVITY_STATUS, DUE_DATE)'||
                 '\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N1') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES_H (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N2') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES_H (NOTIFICATION_ID)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ACTIVITY_STATUSES_H_N3') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEM_ACTIVITY_STATUSES_H (ASSIGNED_USER)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEM_ATTRIBUTE_VALUES_PK') then
        v_sql := 'create unique index %s'||'\n'||
                 ' on WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME)'||'\n';
        v_initial := 10485760;   -- 10M
      elsif (idxname = 'WF_ITEMS_PK') then
        v_sql := 'create unique index %s'||'\n'||
                 ' on WF_ITEMS (ITEM_TYPE, ITEM_KEY)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N1') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (PARENT_ITEM_TYPE, PARENT_ITEM_KEY)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N2') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (BEGIN_DATE)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N3') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (END_DATE)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N4') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (ITEM_TYPE,ROOT_ACTIVITY,OWNER_ROLE)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N5') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (USER_KEY)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_N6') then
        v_sql := 'create index %s'||'\n'||
                 ' on WF_ITEMS (OWNER_ROLE)'||'\n';
        v_initial := 1048576;    -- 1M
      elsif (idxname = 'WF_ITEMS_U1') then
        v_sql := 'create unique index %s'||'\n'||
                 ' on WF_ITEMS (HA_MIGRATION_FLAG, ITEM_TYPE, ITEM_KEY)'||'\n';
        v_initial := 1048576;    -- 1M
      end if;

      utl_file.putf(i_file_handle,v_sql,v_new_index);
      utl_file.fflush(i_file_handle);

      v_sql := ' pctfree %s'||'\n'||
               ' initrans %s'||'\n'||
               ' tablespace %s'||'\n'||
               ' storage (initial %s next %s'||'\n';
      utl_file.putf(i_file_handle,v_sql,v_pctfree,v_initrans,
                    v_tablespace_name,to_char(v_initial),to_char(v_next));
      utl_file.fflush(i_file_handle);
      v_sql := ' freelists 2 freelist groups %s'||'\n'||
               ' pctincrease 0)'||'\n'||
               ' parallel '||'\n'||
               ' logging;'||'\n';

      utl_file.putf(i_file_handle,v_sql,v_freelist_groups,v_degree);
      utl_file.fflush(i_file_handle);

    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;

    begin
      utl_file.put_line(i_file_handle,'--Execute the statement to alter index ');
      v_sql := 'alter index %s'||'\n'||
               ' noparallel'||'\n'||
               ' logging;'||'\n';
      utl_file.putf(i_file_handle,v_sql,v_new_index);
      utl_file.fflush(i_file_handle);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;

    -- gathering CBO stats
    UTL_FILE.PUT_LINE(I_FILE_Handle,'--Gathering CBO Stats on new index '||
                                              v_new_index);
  -- begin
  --   apps.fnd_stats.gather_index_stats(ownname=>'APPLSYS',
  --                                     indname=>v_new_index);
  --  null;
  -- end;

    -- rename orig index to old index
    v_old_index := 'OO'||substr(idxname,3,28);
    utl_file.put_line(i_file_handle,'--Rename '||idxname||' to '||v_old_index);
    v_sql := 'alter index '||idxname||' rename to '||v_old_index||';';

    begin
      utl_file.put_line(i_file_handle,v_sql);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;

    -- rename new index to orig index
    utl_file.put_line(i_file_handle,'--Rename '||v_new_index||' to '||idxname);
    v_sql := 'alter index '||v_new_index||' rename to '||idxname||';';
    begin
      utl_file.put_line(i_file_handle,v_sql);
    exception
      when OTHERS then
        utl_file.put_line(i_file_handle,'Error in SQL: '||substr(v_sql,1,220));
        raise;
    end;

  end if;

  utl_file.fclose(i_file_handle);
exception
  when OTHERS then
    utl_file.put_line(i_file_handle,'--Error in CreateIndex'||idxname);
    utl_file.fclose(i_file_handle);
    raise;
end CreateIndex;

PROCEDURE Start_partition(p_tablespace  in  varchar2,
                          partition     out nocopy boolean)
is
  current_space    number;
  used_space       number;
  table_list varchar2 (200);
  statement varchar2 (1000);
begin
  table_list := '''WF_ITEM_ACTIVITY_STATUSES'''||','
                ||'''WF_ITEM_ACTIVITY_STATUSES_H'''||','
                ||'''WF_ITEM_ATTRIBUTE_VALUES'''||','||'''WF_ITEMS''';
  select sum(bytes )/1024/1024
  into   current_space
  from   user_free_space
  where  tablespace_name = p_tablespace;

  statement := 'SELECT SUM(BYTES)/1024/1024 FROM USER_SEGMENTS
  WHERE TABLESPACE_NAME = '''||p_tablespace||''' AND SEGMENT_NAME in (
  SELECT INDEX_NAME FROM USER_INDEXES WHERE PARTITIONED='||'''NO'''
  ||' AND TABLE_NAME IN ('||table_list||')
  UNION
  SELECT TABLE_NAME from USER_TABLES WHERE PARTITIONED='||'''NO'''
  ||' AND TABLE_NAME IN ('||table_list||'))';

  EXECUTE IMMEDIATE statement INTO used_space;

  if (used_space > current_space) then
    partition := FALSE;
  else
    partition := TRUE;
  end if;
end;

end Wf_Install;

/
