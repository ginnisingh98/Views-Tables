--------------------------------------------------------
--  DDL for Package Body POA_MV_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_MV_UTILS_PKG" as
/* $Header: POAMVUTLB.pls 120.0 2005/06/01 14:19:22 appldev noship $ */

  procedure drop_MV_Log(p_mv_log varchar2)
  is
  begin
    execute immediate 'drop materialized view log on '||p_mv_log;
  exception
    when others then null;
  end drop_MV_Log;

  procedure create_MV_Log(p_base_table varchar2
                       ,p_column_list varchar2 := NULL
                       ,p_sequence_flag varchar2 := 'Y'
                       ,p_rowid varchar2 := 'Y'
                       ,p_new_values varchar2 := 'Y'
                       ,p_data_tablespace varchar2 := null
                       ,p_index_tablespace varchar2 := null
                       ,p_next_extent varchar2 := '32K'
                       )
  is
    MV_LOG_EXISTS exception;
    pragma exception_init(MV_LOG_EXISTS, -12000);
    l_sequence varchar2(20) := 'SEQUENCE';
    l_rowid varchar2(20) := 'ROWID';
    l_data_tablespace  varchar2(30) := p_data_tablespace;
    l_index_tablespace varchar2(30) := p_index_tablespace;
    l_column_list varchar2(3000);
  begin
    if(p_sequence_flag = 'N') then l_sequence := ''; end if;
    if(p_rowid = 'N') then
      l_rowid := '';
    elsif(p_sequence_flag = 'Y') then
      l_sequence := 'SEQUENCE,';
    end if;
    if(p_column_list is not null) then l_column_list := '('||p_column_list||')'; end if;

    if p_data_tablespace is null then
 	l_data_tablespace := ad_mv.g_mv_data_tablespace;
	l_index_tablespace := ad_mv.g_mv_index_tablespace;
    end if;

    EXECUTE IMMEDIATE
           ' create materialized view log on '||p_base_table||
           ' tablespace '||l_data_tablespace||
           ' INITRANS 4 MAXTRANS 255 '||
           ' storage(INITIAL 4K NEXT '||p_next_extent||
           '     MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)'||
           ' with '||l_sequence||l_rowid||l_column_list||
           ' including new values';
  exception
    when MV_LOG_EXISTS then null;
  end create_MV_Log;

  procedure drop_MV(p_mv varchar2)
  is
         MV_NOTEXISTS exception;
         pragma exception_init(MV_NOTEXISTS, -12003);
  begin
    execute immediate 'drop materialized view '||p_mv;
  exception
    when MV_NOTEXISTS then null;
  end drop_MV;

  procedure create_MV(p_mv_name varchar2
                    ,p_mv_sql varchar2
                    ,p_build_mode varchar2 := 'D' -- DEFERRED
                    ,p_refresh_mode varchar2 := 'F' -- FAST
                    ,p_enable_qrewrite varchar2 := 'N'
                    ,p_partition_flag varchar2 := 'N'
                    ,p_next_extent varchar2 := '2M'
                    )
  is
	MV_EXISTS exception;
 	 pragma exception_init(MV_EXISTS, -12006);
    l_data_tablespace  varchar2(30);
    l_index_tablespace varchar2(30);
    l_build_mode varchar2(20) := 'DEFERRED';
    l_refresh_mode varchar2(20) := 'FAST';
    l_enable_qrewrite varchar2(30) := 'DISABLE';
    l_storage varchar2(256);
    l_partition_clause varchar2(2000);
    l_query varchar2(32767);
  begin
    if p_build_mode = 'I' then
      l_build_mode := 'IMMEDIATE';
    end if;

    if p_refresh_mode = 'C' then
      l_refresh_mode := 'COMPLETE';
    end if;

    if p_enable_qrewrite = 'Y' then
      l_enable_qrewrite := 'ENABLE';
    end if;

    l_storage := 'storage(INITIAL 4K NEXT '||p_next_extent||' MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)';

    if(p_partition_flag = 'Y') then
      l_partition_clause :=  ' PARTITION by LIST (grp_id)
        (PARTITION quarter VALUES (7) PCTFREE 10 PCTUSED 80 '||l_storage||',
        PARTITION month VALUES (11) PCTFREE 10 PCTUSED 80 '||l_storage||',
        PARTITION week VALUES (13) PCTFREE 10 PCTUSED 80 '||l_storage||',
        PARTITION day VALUES (14) PCTFREE 10 PCTUSED 80 '||l_storage||'
        ) ';
    end if;

	l_data_tablespace := ad_mv.g_mv_data_tablespace;
	l_index_tablespace := ad_mv.g_mv_index_tablespace;

    /*
     l_query := 'create materialized view '||p_mv_name|| '
            TABLESPACE '||l_data_tablespace||'
            INITRANS 4 MAXTRANS 255
           ' || l_storage|| '
           ' || l_partition_clause || '
           BUILD '||l_build_mode|| '
           USING index tablespace '|| l_index_tablespace || '
           STORAGE (INITIAL 4K NEXT '|| p_next_extent || '
           MAXEXTENTS UNLIMITED PCTINCREASE 0)
           REFRESH ' || l_refresh_mode || ' ON DEMAND
           ' || l_enable_qrewrite || ' QUERY REWRITE '|| '
           as
           ' || p_mv_sql;
     */

        l_query :=
           ' create materialized view '||p_mv_name||
           ' tablespace '||l_data_tablespace||
           ' INITRANS 4 MAXTRANS 255 '||
           l_storage||l_partition_clause||
           ' build '||l_build_mode||
           ' using index tablespace '||l_index_tablespace||
           ' storage (INITIAL 4K NEXT '||p_next_extent||
           '     MAXEXTENTS UNLIMITED PCTINCREASE 0) '||
           ' refresh '||l_refresh_mode ||' ON DEMAND '||
           -- ' with <rowid|primary key> '||
           l_enable_qrewrite||' QUERY REWRITE '||
           ' as '||
           p_mv_sql;

	ad_mv.create_mv(p_mv_name, l_query);

  exception
    when MV_EXISTS then null;
  end create_MV;


  procedure create_part_MV(p_mv_name varchar2
                    ,p_mv_sql varchar2
                    ,p_build_mode varchar2 := 'D' -- DEFERRED
                    ,p_refresh_mode varchar2 := 'F' -- FAST
                    ,p_enable_qrewrite varchar2 := 'N'
                    ,p_partition_clause varchar2 := NULL
                    ,p_next_extent varchar2 := '2M'
                    )
  is
	MV_EXISTS exception;
 	 pragma exception_init(MV_EXISTS, -12006);
    l_data_tablespace  varchar2(30);
    l_index_tablespace varchar2(30);
    l_build_mode varchar2(20) := 'DEFERRED';
    l_refresh_mode varchar2(20) := 'FAST';
    l_enable_qrewrite varchar2(30) := 'DISABLE';
    l_storage varchar2(256);
    l_query varchar2(32767);
  begin
    if p_build_mode = 'I' then
      l_build_mode := 'IMMEDIATE';
    end if;

    if p_refresh_mode = 'C' then
      l_refresh_mode := 'COMPLETE';
    end if;

    if p_enable_qrewrite = 'Y' then
      l_enable_qrewrite := 'ENABLE';
    end if;

    l_storage := 'storage(INITIAL 4K NEXT '||p_next_extent||' MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)';

	l_data_tablespace := ad_mv.g_mv_data_tablespace;
	l_index_tablespace := ad_mv.g_mv_index_tablespace;


        l_query :=
           ' create materialized view '||p_mv_name||
           ' tablespace '||l_data_tablespace||
           ' INITRANS 4 MAXTRANS 255 '||
           l_storage||p_partition_clause||
           ' build '||l_build_mode||
           ' using index tablespace '||l_index_tablespace||
           ' storage (INITIAL 4K NEXT '||p_next_extent||
           '     MAXEXTENTS UNLIMITED PCTINCREASE 0) '||
           ' refresh '||l_refresh_mode ||' ON DEMAND '||
           -- ' with <rowid|primary key> '||
           l_enable_qrewrite||' QUERY REWRITE '||
           ' as '||
           p_mv_sql;

	ad_mv.create_mv(p_mv_name, l_query);

  exception
    when MV_EXISTS then null;
  end create_part_MV;

  procedure create_MV_Index(p_mv_name varchar2
                            ,p_ind_name varchar2
                            ,p_ind_col_list varchar2
                            ,p_unique_flag varchar2 := 'N'
                            ,p_ind_type varchar2 := 'B' -- B = BTree , M = BitMap
                            ,p_next_extent varchar2 := '32K'
                            ,p_partition_type varchar2 := 'L' -- L = Local
                            )
  is
    l_data_tablespace  varchar2(30);
    l_index_tablespace varchar2(30);
    l_unique varchar2(10);
    l_index_type varchar2(10);
    l_partition_clause varchar2(100);
    MV_INDEX_EXISTS exception;
    pragma exception_init(MV_INDEX_EXISTS, -955);
  begin
    if(p_unique_flag = 'Y') then l_unique := 'UNIQUE '; end if;
    if(p_ind_type = 'M') then l_index_type := 'BITMAP'; end if;

    if(p_partition_type = 'L') then
      l_partition_clause := ' LOCAL ';
    elsif(p_partition_type = 'G') then
      l_partition_clause := ' GLOBAL ';
    end if;

	l_data_tablespace := ad_mv.g_mv_data_tablespace;
	l_index_tablespace := ad_mv.g_mv_index_tablespace;

    execute immediate
           ' create '||l_unique||l_index_type||' index '||p_ind_name||' ON '||p_mv_name ||'('||p_ind_col_list||') '||
           ' tablespace '||l_index_tablespace||l_partition_clause||
           ' INITRANS 4 MAXTRANS 255'||
           ' storage(INITIAL 4K NEXT '||p_next_extent||
           '     MAXEXTENTS UNLIMITED PCTINCREASE 0)';
  exception
    when MV_INDEX_EXISTS then null;
  end create_MV_Index;


end POA_MV_UTILS_PKG;

/
