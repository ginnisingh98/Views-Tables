--------------------------------------------------------
--  DDL for Package Body OKI_DBI_MV_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_MV_UTIL_PVT" AS
/* $Header: OKIRIMUB.pls 115.8 2003/04/29 22:07:11 rpotnuru noship $ */

  PROCEDURE drop_mv_log
  (   p_mv_log IN VARCHAR2
  ) IS

     MV_LOG_NOTEXISTS EXCEPTION ;
     PRAGMA exception_init(MV_LOG_NOTEXISTS, -12002) ;
  BEGIN
    EXECUTE IMMEDIATE 'drop materialized view log on ' || p_mv_log ;
  EXCEPTION
    WHEN MV_LOG_NOTEXISTS THEN NULL;
    WHEN OTHERS THEN null ;
  END drop_mv_log ;

  procedure create_mv_log
  (   p_base_table IN VARCHAR2
   ,  p_column_list IN VARCHAR2
   ,  p_sequence_flag IN VARCHAR2
   ,  p_rowid IN VARCHAR2
   ,  p_new_values IN VARCHAR2
   ,  p_data_tablespace IN VARCHAR2
   ,  p_index_tablespace IN VARCHAR2
   ,  p_next_extent IN VARCHAR2
  ) IS

  MV_LOG_EXISTS EXCEPTION ;

  PRAGMA exception_init(MV_LOG_EXISTS, -12000) ;

  l_sequence         VARCHAR2(20) := 'SEQUENCE' ;
  l_rowid            VARCHAR2(20) := 'ROWID' ;
  l_data_tablespace  VARCHAR2(30) := p_data_tablespace ;
  l_index_tablespace VARCHAR2(30) := p_index_tablespace ;
  l_column_list      VARCHAR2(3000) ;

  BEGIN

    IF (p_sequence_flag = 'N') THEN
      l_sequence := '' ;
    END IF ;

    IF (p_rowid = 'N') THEN
      l_rowid := '' ;
    ELSIF (p_sequence_flag = 'Y') THEN
      l_sequence := 'SEQUENCE,' ;
    END IF ;

    IF (p_column_list IS NOT NULL) THEN
      l_column_list := '(' || p_column_list || ')' ;
    END IF ;

    IF p_data_tablespace IS NULL THEN

       l_data_tablespace  := ad_mv.g_mv_data_tablespace;
       l_index_tablespace := ad_mv.g_mv_index_tablespace;

    END IF ;


    EXECUTE IMMEDIATE
           ' CREATE MATERIALIZED VIEW LOG ON ' || p_base_table ||
           ' TABLESPACE '||l_data_tablespace ||
           ' INITRANS 4 MAXTRANS 255 ' ||
           ' STORAGE(INITIAL 4K NEXT ' || p_next_extent ||
           '     MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)' ||
           ' WITH '|| l_sequence || l_rowid || l_column_list ||
           ' INCLUDING NEW VALUES' ;


  EXCEPTION
    WHEN MV_LOG_EXISTS THEN
       NULL ;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_MV_UTIL_PVT.create_mv_log ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' p_base_table  : ' || p_base_table ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END create_mv_log ;

  PROCEDURE drop_mv
  (   p_mv IN VARCHAR2
  ) IS
      mv_notexists EXCEPTION;
      PRAGMA EXCEPTION_INIT(mv_notexists, -12006);
  BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || p_mv;
  EXCEPTION
    WHEN mv_notexists THEN
       NULL;
    WHEN OTHERS THEN NULL ;
  END drop_mv ;

  PROCEDURE create_mv
  (   p_mv_name IN VARCHAR2
   ,  p_mv_sql IN VARCHAR2
   ,  p_build_mode IN VARCHAR2
   ,  p_refresh_mode IN VARCHAR2
   ,  p_enable_qrewrite IN VARCHAR2
   ,  p_partition_flag IN VARCHAR2
   ,  p_next_extent IN VARCHAR2
  ) IS

  l_data_tablespace  VARCHAR2(30) ;
  l_index_tablespace VARCHAR2(30) ;
  l_build_mode       VARCHAR2(20) := 'DEFERRED' ;
  l_refresh_mode     VARCHAR2(20) := 'FAST' ;
  l_enable_qrewrite  VARCHAR2(30) := 'DISABLE' ;
  l_storage          VARCHAR2(256) ;
  l_partition_clause VARCHAR2(2000) ;

  l_sql VARCHAR2(32767) ;

  mv_exists EXCEPTION ;

  PRAGMA EXCEPTION_INIT(mv_exists, -12006) ;

  BEGIN


    IF p_build_mode = 'I' THEN
      l_build_mode := 'IMMEDIATE' ;
    END IF ;

    IF p_refresh_mode = 'C' THEN
      l_refresh_mode := 'COMPLETE' ;
    END IF ;

    IF p_enable_qrewrite = 'Y' THEN
      l_enable_qrewrite := 'ENABLE' ;
    END IF ;

    l_storage := 'STORAGE(INITIAL 4K
                          NEXT ' || p_next_extent ||
                        ' MINEXTENTS 1
                          MAXEXTENTS UNLIMITED PCTINCREASE 0)';

    IF (p_partition_flag = 'Y') THEN
      l_partition_clause :=  ' PARTITION by LIST (grp_id)
        (PARTITION quarter VALUES (7)  PCTFREE 10 PCTUSED 80 '||l_storage||',
         PARTITION month   VALUES (11) PCTFREE 10 PCTUSED 80 '||l_storage||',
         PARTITION week    VALUES (13) PCTFREE 10 PCTUSED 80 '||l_storage||',
         PARTITION day     VALUES (14) PCTFREE 10 PCTUSED 80 '||l_storage||'
        ) ';
    END IF;


    l_data_tablespace  := ad_mv.g_mv_data_tablespace;
    l_index_tablespace := ad_mv.g_mv_index_tablespace;

    l_sql :=
           ' CREATE MATERIALIZED VIEW ' || p_mv_name ||
           ' TABLESPACE ' || l_data_tablespace ||
           ' INITRANS 4 MAXTRANS 255 ' ||
           l_storage || l_partition_clause ||
           ' BUILD ' || l_build_mode ||
           ' USING INDEX TABLESPACE ' || l_index_tablespace ||
           ' STORAGE (INITIAL 4K NEXT '||p_next_extent||
           '          MAXEXTENTS UNLIMITED PCTINCREASE 0) '||
           ' REFRESH ' || l_refresh_mode || ' ON DEMAND ' ||
           -- ' with <rowid|primary key> ' ||
           l_enable_qrewrite || ' QUERY REWRITE ' ||
           ' AS ' ||
           p_mv_sql ;

      ad_mv.create_mv(p_mv_name, l_sql);

  EXCEPTION
    WHEN mv_exists THEN
       NULL ;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_MV_UTIL_PVT.create_mv ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' p_mv_name  : ' || p_mv_name ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END create_mv ;

  PROCEDURE create_mv_index
  (   p_mv_name IN VARCHAR2
   ,  p_ind_name IN VARCHAR2
   ,  p_ind_col_list IN VARCHAR2
   ,  p_unique_flag IN VARCHAR2
   ,  p_ind_type IN VARCHAR2
   ,  p_next_extent IN VARCHAR2
   ,  p_partition_type IN VARCHAR2
  ) IS

  l_data_tablespace  VARCHAR2(30) ;
  l_index_tablespace VARCHAR2(30) ;
  l_unique           VARCHAR2(10) ;
  l_index_type       VARCHAR2(10) ;
  l_partition_clause VARCHAR2(100) ;

  mv_index_exists EXCEPTION ;

  PRAGMA EXCEPTION_INIT(mv_index_exists, -955) ;

  BEGIN

    IF (p_unique_flag = 'Y') THEN
      l_unique := 'UNIQUE ';
    END IF ;

    IF (p_ind_type = 'M') THEN
      l_index_type := 'BITMAP' ;
    END IF ;

    IF (p_partition_type = 'L') THEN
      l_partition_clause := ' LOCAL ' ;
    ELSIF (p_partition_type = 'G') THEN
      l_partition_clause := ' GLOBAL ' ;
    END IF ;

    l_data_tablespace  := ad_mv.g_mv_data_tablespace;
    l_index_tablespace := ad_mv.g_mv_index_tablespace;

    EXECUTE IMMEDIATE
           ' CREATE ' || l_unique || l_index_type || ' index ' || p_ind_name||
           ' ON ' || p_mv_name || '(' || p_ind_col_list || ' ) ' ||
           ' TABLESPACE '|| l_index_tablespace || l_partition_clause ||
           ' INITRANS 4 MAXTRANS 255' ||
           ' STORAGE(INITIAL 4K NEXT ' || p_next_extent ||
           '         MAXEXTENTS UNLIMITED PCTINCREASE 0)' ;
  EXCEPTION
    WHEN mv_index_exists THEN
       NULL ;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_MV_UTIL_PVT.create_mv_Index ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' p_mv_name  : ' || p_mv_name ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END create_mv_index;

  PROCEDURE drop_index
  (   p_index_name IN VARCHAR2
  ) IS
     mv_index_doesnotexist exception;
     PRAGMA EXCEPTION_INIT(mv_index_doesnotexist, -1418);
  BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX ' || p_index_name ;
  EXCEPTION
    WHEN mv_index_doesnotexist THEN NULL;
    WHEN OTHERS THEN NULL ;
  END drop_index ;


  PROCEDURE refresh
  (  p_mv_name         IN  VARCHAR2
   , p_parallel_degree IN  NUMBER
  ) IS
  BEGIN
   DBMS_MVIEW.REFRESH(
        list   => p_mv_name
      , method => '?'
      , parallelism => p_parallel_degree ) ;
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_MV_UTIL_PVT.refresh ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' p_mv_name  : ' || p_mv_name ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END refresh ;

  PROCEDURE crt_mx
  (  p_id       IN NUMBER
   , p_user_id  IN NUMBER
   , p_run_date IN DATE
   , p_login_id IN NUMBER
  ) IS
  BEGIN
    INSERT INTO oki_dbi_multiplexer_b(
           id
         , created_by
         , last_update_login
         , creation_date
         , last_updated_by
         , last_update_date)
    VALUES (p_id
          , p_user_id
          , p_login_id
          , p_run_date
          , p_user_id
          , p_run_date ) ;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      -- ignore the error if an attempt is made to insert an existing record
      NULL ;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_MV_UTIL_PVT.crt_mx ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       bis_collection_utilities.put_line( ' p_id  : ' || p_id ) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END crt_mx ;

END oki_dbi_mv_util_pvt  ;

/
