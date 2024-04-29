--------------------------------------------------------
--  DDL for Package Body FND_GEN_MIG_CMDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GEN_MIG_CMDS" AS
/* $Header: fndpgmcb.pls 120.10 2006/08/17 01:13:07 mnovakov noship $ */

 G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;
 G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

 g_threshold_size      NUMBER;

 TYPE NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE CharTabType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


 PROCEDURE write_out( p_owner IN VARCHAR2,
                      p_object_type IN VARCHAR2,
                      p_mig_cmd IN VARCHAR2,
                      p_object_name IN VARCHAR2 DEFAULT NULL,
                      p_old_tablespace IN VARCHAR2 DEFAULT NULL,
                      p_new_tablespace IN VARCHAR2 DEFAULT NULL,
                      p_subobject_type IN VARCHAR2 DEFAULT 'X',
                      p_parent_owner IN VARCHAR2 DEFAULT NULL,
                      p_parent_object_name IN VARCHAR2 DEFAULT NULL,
                      p_tot_blocks IN NUMBER DEFAULT 0,
                      p_index_parallel IN VARCHAR2 DEFAULT 'NOPARALLEL',
                      p_execution_mode IN VARCHAR2 DEFAULT NULL,
                      p_partitioned IN VARCHAR2 DEFAULT 'NO',
                      p_err_text IN VARCHAR2 DEFAULT NULL,
                      p_parent_lineno IN NUMBER DEFAULT NULL,
                      x_lineno OUT  NOCOPY  NUMBER)
 IS
   CURSOR lineno_csr IS
     SELECT FND_TS_MIG_CMDS_S.nextval
       FROM SYS.dual;
   l_lineno              NUMBER;

   CURSOR cmd_csr IS
     SELECT lineno,
            new_tablespace,
            object_type,
            subobject_type,
            migration_status
       FROM fnd_ts_mig_cmds
      WHERE owner = p_owner
        AND object_type = p_object_type
        AND object_name = p_object_name
        AND index_parallel = NVL(p_index_parallel, 'NOPARALLEL')
        AND subobject_type = NVL(p_subobject_type, 'X')
      order by migration_status;
   cmd_rec            cmd_csr%ROWTYPE;
   l_generated        BOOLEAN := FALSE;
   l_mig_cmd   varchar2(4000);
 BEGIN

   OPEN cmd_csr;
   FETCH cmd_csr INTO cmd_rec;
   if cmd_csr%FOUND
   then
      if p_object_type NOT IN ('ENABLE_TRIGGER', 'ENABLE_CONSTRAINT', 'DISABLE_TRIGGER', 'DISABLE_CONSTRAINT', 'STOP_QUEUE', 'START_QUEUE', 'ENABLE_POLICY', 'DISABLE_POLICY', 'POSTMIG')
      then
          if cmd_rec.migration_status IN ('GENERATED', 'ERROR')
          then
            UPDATE fnd_ts_mig_cmds
               SET migration_cmd = p_mig_cmd,
                   new_tablespace = p_new_tablespace,
                   old_tablespace = p_old_tablespace,
                   total_blocks = p_tot_blocks,
                   partitioned = p_partitioned,
                   parent_owner = p_parent_owner,
                   parent_object_name = p_parent_object_name,
                   generation_date = sysdate,
                   last_update_date = sysdate
             WHERE lineno = cmd_rec.lineno;
             l_generated := TRUE;
          end if;
      else
        UPDATE fnd_ts_mig_cmds
           SET migration_cmd = p_mig_cmd,
               last_update_date = sysdate
         WHERE lineno = cmd_rec.lineno;
        l_generated := TRUE;
      end if;
      x_lineno := cmd_rec.lineno;
   end if;
   CLOSE cmd_csr;

   if NOT l_generated
   then
     OPEN lineno_csr;
     FETCH lineno_csr INTO l_lineno;
     CLOSE lineno_csr;

     INSERT INTO fnd_ts_mig_cmds (lineno,
                                   owner,
                                   object_type,
                                   subobject_type,
                                   index_parallel,
                                   object_name,
                                   parent_lineno,
                                   old_tablespace,
                                   new_tablespace,
                                   migration_cmd,
                                   migration_status,
                                   parent_owner,
                                   parent_object_name,
                                   total_blocks,
                                   execution_mode,
                                   partitioned,
                                   error_text,
                                   generation_date,
                                   last_update_date)
        VALUES (l_lineno,
                p_owner,
                p_object_type,
                NVL(p_subobject_type, 'X'),
                NVL(p_index_parallel, 'NOPARALLEL'),
                p_object_name,
                p_parent_lineno,
                p_old_tablespace,
                p_new_tablespace,
                p_mig_cmd,
                'GENERATED',
                p_parent_owner,
                p_parent_object_name,
                p_tot_blocks,
                p_execution_mode,
                p_partitioned,
                p_err_text,
                sysdate,
                sysdate);
     x_lineno := l_lineno;
   end if;
 END write_out;

 FUNCTION get_txn_idx_tablespace
  RETURN VARCHAR2
 IS
   CURSOR idx_tbs_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = fnd_ts_mig_util.l_def_ind_tsp;
   l_tablespace_name	VARCHAR2(30);
 BEGIN
    OPEN idx_tbs_csr;
    FETCH idx_tbs_csr INTO l_tablespace_name;
    if idx_tbs_csr%NOTFOUND then
      raise_application_error(-20001, 'FND_TABLESPACES table does not have any entry for the Transaction index tablespace');
    end if;
    CLOSE idx_tbs_csr;
    RETURN l_tablespace_name;
 END get_txn_idx_tablespace;

 FUNCTION get_idx_tablespace(p_tablespace_type IN VARCHAR2,
                             p_tab_tablespace  IN VARCHAR2,
                             p_txn_idx_tablespace  IN VARCHAR2)
  RETURN VARCHAR2
 IS
   l_idx_tablespace          VARCHAR2(30);
 BEGIN
   if p_tablespace_type = fnd_ts_mig_util.l_def_tab_tsp then
     l_idx_tablespace := p_txn_idx_tablespace;
   else
     l_idx_tablespace := p_tab_tablespace;
   end if;
   RETURN l_idx_tablespace;
 END get_idx_tablespace;


 FUNCTION get_tot_blocks ( p_owner IN VARCHAR2,
                           p_object_type IN VARCHAR2,
                           p_object_name IN VARCHAR2,
                           p_partition_name IN VARCHAR2)
  RETURN NUMBER
 IS
   tot_blks              NUMBER;
   tot_byts              NUMBER;
   unused_blks           NUMBER;
   unused_byts           NUMBER;
   lst_ext_file          NUMBER;
   lst_ext_blk           NUMBER;
   lst_usd_blk           NUMBER;
   l_version             NUMBER;

   CURSOR lob_part_siz_csr IS
     SELECT blocks
       FROM dba_segments
      WHERE owner = p_owner
        AND segment_name = p_object_name
        AND partition_name = p_partition_name;
 BEGIN
  if p_object_type = 'LOB PARTITION' then
     l_version := fnd_ts_mig_util.get_db_version;
  end if;

  if p_object_type = 'LOB PARTITION' AND l_version < 10 then
     -- LOB PARTITIONS are not supported in DBMS_SPACE in 9i Bug# 2169303
     OPEN lob_part_siz_csr;
     FETCH lob_part_siz_csr INTO tot_blks;
     CLOSE lob_part_siz_csr;
  else
   DBMS_SPACE.UNUSED_SPACE (
                        p_owner,
                        p_object_name,
                        p_object_type,
                        tot_blks,
                        tot_byts,
                        unused_blks,
                        unused_byts,
                        lst_ext_file,
                        lst_ext_blk,
                        lst_usd_blk,
                        p_partition_name);
  end if;
   RETURN (NVL(tot_blks, 0) - NVL(unused_blks, 0));
 EXCEPTION WHEN OTHERS THEN
   RETURN NVL(tot_blks, 0);
--   DBMS_OUTPUT.PUT_LINE(p_owner||p_object_name||p_object_type||nvl(p_partition_name,'null'));
--   RAISE_APPLICATION_ERROR(-20001, p_owner||p_object_name||p_object_type||nvl(p_partition_name,'null'));
 END get_tot_blocks;


 PROCEDURE gen_move_obj ( p_owner IN VARCHAR2,
                          p_obj_type IN VARCHAR2,
                          p_sub_obj_type IN VARCHAR2,
                          p_obj_name IN VARCHAR2,
                          p_partitioned IN VARCHAR2,
                          p_logging IN VARCHAR2,
                          p_old_tablespace IN VARCHAR2,
                          p_new_tablespace IN VARCHAR2,
                          p_parent_owner IN VARCHAR2 DEFAULT NULL,
                          p_parent_obj_name IN VARCHAR2 DEFAULT NULL,
                          p_parent_lineno IN NUMBER DEFAULT NULL,
                          x_execution_mode OUT  NOCOPY VARCHAR2,
                          x_lineno OUT  NOCOPY NUMBER)
 IS
   CURSOR col_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT owner,
            table_name,
            column_name,
            data_type
       FROM dba_tab_columns
      WHERE owner = l_owner
        AND table_name = l_table_name
        AND data_type IN ('CLOB', 'BLOB', 'NCLOB');
--      ORDER by column_id;

   CURSOR lob_chunk_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT MIN(dl.chunk)
       FROM dba_lobs dl
      WHERE dl.owner = l_owner
        AND dl.table_name = l_table_name;
   l_chunk_size         DBA_LOBS.CHUNK%TYPE;

   CURSOR col_lob_csr (l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT /*+ FIRST_ROWS */ d.column_name ,
            d.table_name,
            d.segment_name,
            d.owner
       FROM dba_lobs d
      WHERE owner = l_owner
        AND table_name = l_table_name
        AND NOT EXISTS (select column_name
                          from dba_tab_columns c
                         where c.data_type in ('CLOB','BLOB','NCLOB')
                           and c.owner = l_owner
                           and c.table_name = l_table_name
                           and c.column_name = d.column_name)
        AND EXISTS (select attr_name
                      from dba_type_attrs ta,
                           dba_tab_columns tc
                     where tc.owner = l_owner
                       and tc.table_name = l_table_name
                       and tc.column_name = SUBSTR(d.column_name, 2, INSTR(d.column_name, '.', 1) - 3)
                       and tc.data_type_owner = ta.owner
                       and tc.data_type = ta.type_name
                       and ta.attr_type_name in ('CLOB','BLOB','NCLOB')
                       and ta.attr_name = RTRIM(SUBSTR(d.column_name,INSTR(d.column_name, '.', -1) + 2), '"'));

   -- Get all the LOBs (SEGMENT and INDEX) for sizing
   CURSOR lob_csr (l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT owner,
            column_name,
            table_name,
            segment_name,
            index_name
       FROM dba_lobs d
      WHERE owner = l_owner
        AND table_name = l_table_name;

   CURSOR iot_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT table_name
       FROM dba_tables
      WHERE owner = l_owner
        AND iot_type = 'IOT_OVERFLOW'
        AND iot_name = l_table_name;
   l_iot_over_name       DBA_TABLES.TABLE_NAME%TYPE;

   CURSOR iot_top_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT index_name
       FROM dba_indexes
      WHERE owner = l_owner
        AND table_name = l_table_name
        AND index_type = 'IOT - TOP';
   l_iot_top_name        DBA_INDEXES.INDEX_NAME%TYPE;

   CURSOR part_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT partitioning_type,
            subpartitioning_type,
            def_tablespace_name
       FROM dba_part_tables
      WHERE owner = l_owner
        AND table_name = l_table_name;

   CURSOR tab_part_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
     SELECT partition_name,
            tablespace_name,
            logging
       FROM dba_tab_partitions
      WHERE table_owner = l_owner
        AND table_name = l_table_name;

   -- Get all the LOB Partitions (SEGMENT and INDEX) for sizing
   CURSOR lob_part_csr (l_owner VARCHAR2,
                        l_table_name VARCHAR2,
                        l_part_name IN VARCHAR2) IS
     SELECT lob_name,
            column_name,
            lob_partition_name,
            lob_indpart_name
       FROM dba_lob_partitions
      WHERE table_owner = l_owner
        AND table_name = l_table_name
        AND partition_name = l_part_name;

   l_obj_type            FND_TS_MIG_CMDS.OBJECT_TYPE%TYPE;
   l_obj_name            FND_TS_MIG_CMDS.OBJECT_NAME%TYPE := p_obj_name;
   l_parent_owner        FND_TS_MIG_CMDS.PARENT_OBJECT_NAME%TYPE := p_parent_owner;
   l_parent_obj_name     FND_TS_MIG_CMDS.PARENT_OBJECT_NAME%TYPE := p_parent_obj_name;
   l_string              VARCHAR2(4000);
   l_lob_str             VARCHAR2(4000);
   l_store_str           VARCHAR2(4000);
   l_chunk_str           VARCHAR2(4000);
   l_iot_str             VARCHAR2(4000);
   l_ues                 NUMBER;
   l_parallel            VARCHAR2(30) := 'NOPARALLEL';
   l_long_cmd_type       VARCHAR2(30);
   l_storage_str         VARCHAR2(4000);
   l_logging_str         VARCHAR2(30) := 'NOLOGGING';
   l_tot_blocks          NUMBER := 0;
   l_sum_blocks          NUMBER := 0;
   l_lineno              NUMBER;
   l_parent_lineno       NUMBER := p_parent_lineno;
   l_execution_mode      FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE := 'P';
   l_def_tablespace_name DBA_PART_TABLES.DEF_TABLESPACE_NAME%TYPE;
   l_logging             VARCHAR2(30) := 'YES';
   l_version             NUMBER;
 BEGIN

   if p_obj_type = 'LONG_TABLE' then
     l_obj_type := 'TABLE';
     l_long_cmd_type := 'ALTER'; --since there are multiple cmds for LONG_TABLE
   elsif p_obj_type = 'MV_LOG' then
     l_obj_type := 'MATERIALIZED VIEW LOG ON';
     l_obj_name := p_parent_obj_name;  -- Log table name
   elsif p_obj_type = 'LONG_MVLOG' then
     l_obj_type := 'MATERIALIZED VIEW LOG ON';
     l_obj_name := p_parent_obj_name;  -- Log table name
   elsif p_obj_type = 'MVIEW' then
     l_obj_type := 'TABLE';
   else
     l_obj_type := p_obj_type;
   end if;

   FOR col_rec IN col_csr(p_owner, l_obj_name)
   LOOP
     if col_csr%ROWCOUNT = 1 then
       l_lob_str := 'LOB ('||col_rec.column_name;
     else
       l_lob_str := l_lob_str||', '||col_rec.column_name;
     end if;
   END LOOP;

   FOR col_lob_rec IN col_lob_csr(p_owner, l_obj_name)
   LOOP
     if l_lob_str IS NULL then
       l_lob_str := 'LOB ('||col_lob_rec.column_name;
     else
       l_lob_str := l_lob_str||', '||col_lob_rec.column_name;
     end if;
   END LOOP;

   l_ues := fnd_ts_mig_util.get_tablespace_ues(p_new_tablespace);
   if l_ues IS NOT NULL then
     l_storage_str := 'STORAGE (INITIAL '||TO_CHAR(l_ues)||' NEXT '||TO_CHAR(l_ues)||') ';
   end if;

   if l_lob_str IS NOT NULL then
       OPEN lob_chunk_csr(p_owner, l_obj_name);
       FETCH lob_chunk_csr INTO l_chunk_size;
       CLOSE lob_chunk_csr;

       l_chunk_str := ' CHUNK '||l_chunk_size||' NOCACHE '||l_storage_str;
       l_store_str := l_lob_str||') STORE AS (TABLESPACE '||p_new_tablespace;
       l_lob_str   := l_store_str;

       l_parallel := 'NOPARALLEL';
       l_execution_mode := 'P';
   end if;

   if NVL(p_sub_obj_type, 'N') = 'IOT' then
       OPEN iot_csr(p_owner, l_obj_name);
       FETCH iot_csr INTO l_iot_over_name;
       if iot_csr%FOUND then
         l_iot_str := ' OVERFLOW TABLESPACE '||p_new_tablespace||' '||l_storage_str;
       end if;
       CLOSE iot_csr;

       OPEN iot_top_csr(p_owner, l_obj_name);
       FETCH iot_top_csr INTO l_iot_top_name;
       CLOSE iot_top_csr;
   end if;

   if NVL(p_partitioned, 'NO') = 'NO' then
      -- Get the sizing for TABLE only since MV_LOG, MVIEW, LONG_MVLOG and
      -- LONG_TABLE will be truncated before the move.
     if p_obj_type = 'TABLE' then
       -- Get tot blocks for table/iot
       if NVL(p_sub_obj_type, 'N') = 'IOT' then
         l_tot_blocks := get_tot_blocks(p_owner,
                                        'INDEX',
                                        l_iot_top_name,
                                        NULL);
         if l_iot_over_name IS NOT NULL then
           l_tot_blocks := NVL(l_tot_blocks, 0) + get_tot_blocks(p_owner,
                                                                'TABLE',
                                                                l_iot_over_name,
                                                                NULL);
         end if;
       else
         l_tot_blocks := get_tot_blocks(p_owner,
                                        'TABLE',
                                        p_obj_name,
                                        NULL);
       end if;
       -- Get the total blocks for all LOBs
       if l_lob_str IS NOT NULL then
         FOR lob_rec IN lob_csr(p_owner, p_obj_name)
         LOOP
           l_tot_blocks := NVL(l_tot_blocks, 0) + get_tot_blocks(p_owner,
                                                           'LOB',
                                                           lob_rec.segment_name,
                                                           NULL);

           l_tot_blocks := NVL(l_tot_blocks, 0) + get_tot_blocks(p_owner,
                                                            'INDEX',
                                                            lob_rec.index_name,
                                                            NULL);
         END LOOP;
       end if;
       if l_lob_str IS NULL AND l_tot_blocks >= g_threshold_size then
         l_parallel := 'PARALLEL';
         l_execution_mode := 'S';
       end if;
     elsif p_obj_type = 'MV_LOG' then
       l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_parent_obj_name||'"';
       write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_subobject_type => 'TRUNCATE',
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => NULL,
                p_parent_object_name => NULL,
                p_parent_lineno => NULL,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                x_lineno => l_parent_lineno);
       l_parent_owner := p_owner;
       l_parent_obj_name := l_obj_name;
     elsif p_obj_type = 'LONG_MVLOG' then
       l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_parent_obj_name||'"';
       write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_subobject_type => 'TRUNCATE',
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => l_parent_owner,
                p_parent_object_name => p_obj_name,
                p_parent_lineno => p_parent_lineno,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                x_lineno => l_parent_lineno);
        l_parent_owner := p_owner;
        l_parent_obj_name := p_obj_name;
     elsif p_obj_type = 'MVIEW' then
       l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_obj_name||'"';
       write_out(
                p_owner => p_owner,
                p_object_type => 'MVIEW',
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_subobject_type => 'TRUNCATE',
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => p_parent_owner,
                p_parent_object_name => p_parent_obj_name,
                p_parent_lineno => p_parent_lineno,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                x_lineno => l_parent_lineno);
       l_parent_owner := p_owner;
       l_parent_obj_name := l_obj_name;
     end if;

     l_lob_str := l_store_str||l_chunk_str;
     if length(l_lob_str)>0 then l_lob_str := l_lob_str||')'; end if;
     -- added ) at the end Mladena

     l_string := 'ALTER '||l_obj_type||' "'||p_owner||'"."'||p_obj_name||'" MOVE TABLESPACE '||p_new_tablespace||' '||l_storage_str||' '||l_iot_str||' '||l_lob_str||' '||l_parallel||' '||l_logging_str;
     write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_old_tablespace => p_old_tablespace,
                p_new_tablespace => p_new_tablespace,
                p_subobject_type => l_long_cmd_type,
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => l_parent_owner,
                p_parent_object_name => l_parent_obj_name,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                p_parent_lineno => l_parent_lineno,
                x_lineno => l_lineno);
      l_sum_blocks := l_tot_blocks;
      x_lineno := l_lineno;
      if p_logging = 'YES' then
         l_logging_str := '" LOGGING';
      else
         l_logging_str := '" NOLOGGING';
      end if;
      l_string := 'ALTER '||l_obj_type||' "'||p_owner||'"."'||p_obj_name||l_logging_str;
       write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_old_tablespace => p_old_tablespace,
                p_new_tablespace => p_new_tablespace,
                p_subobject_type => 'LOGGING',
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => l_parent_owner,
                p_parent_object_name => l_parent_obj_name,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                p_parent_lineno => NVL(l_lineno, l_parent_lineno),
                x_lineno => l_lineno);
                x_lineno := l_lineno;

   --   x_lineno := l_lineno;

   elsif NVL(p_partitioned, 'NO') = 'YES' then

      if p_obj_type = 'TABLE' then
        -- All partitioned tables will be moved sequentially irrespective of
        -- the total block size except if they have LOBs.
        if l_lob_str IS NOT NULL then
          l_parallel := 'NOPARALLEL';
        else
          l_parallel := 'PARALLEL';
        end if;
        l_execution_mode := 'S';
     elsif p_obj_type = 'MV_LOG' then
       l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_parent_obj_name||'"';
       write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_subobject_type => 'TRUNCATE',
                p_parent_object_name => NULL,
                p_parent_lineno => NULL,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                x_lineno => l_parent_lineno);
        l_parent_owner := p_owner;
        l_parent_obj_name := l_obj_name;
     elsif p_obj_type = 'LONG_MVLOG' then
       l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_parent_obj_name||'"';
       write_out(
                 p_owner => p_owner,
                 p_object_type => p_obj_type,
                 p_mig_cmd => l_string,
                 p_object_name => l_obj_name,
                 p_subobject_type => 'TRUNCATE',
                 p_tot_blocks => l_tot_blocks,
                 p_parent_owner => l_parent_owner,
                 p_parent_object_name => p_obj_name,
                 p_parent_lineno => NULL,
                 p_execution_mode => l_execution_mode,
                 p_partitioned => 'NO',
                 x_lineno => l_parent_lineno);
     l_parent_owner := p_owner;
     l_parent_obj_name := p_obj_name;
    elsif p_obj_type = 'MVIEW' then
        -- All MVs will be truncated before move
        l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_obj_name||'"';
        write_out(
                p_owner => p_owner,
                p_object_type => 'MVIEW',
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_subobject_type => 'TRUNCATE',
                p_parent_object_name => p_parent_obj_name,
                p_parent_lineno => p_parent_lineno,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                x_lineno => l_parent_lineno);
        l_parent_owner := p_owner;
        l_parent_obj_name := l_obj_name;
      end if;

      FOR part_rec IN part_csr(p_owner, p_obj_name)
      LOOP
        l_def_tablespace_name := part_rec.def_tablespace_name;
        if NVL(part_rec.partitioning_type, 'X') = 'HASH' OR NVL(part_rec.subpartitioning_type, 'X') = 'HASH'
        then
          l_storage_str := NULL;
          l_logging_str := NULL;
          l_version := fnd_ts_mig_util.get_db_version;
          if l_version >= 10 then
             l_chunk_str := '';
          end if;
          -- l_chunk_str := l_chunk_str || ')'; -- added Mladena
        end if;
      END LOOP;

      l_logging := 'YES';
      FOR tab_part_rec IN tab_part_csr(p_owner, p_obj_name)
      LOOP
        if tab_part_rec.tablespace_name <> p_new_tablespace
        then
          if p_obj_type = 'TABLE' then
            -- Get the sizing for TABLEs only since MV Logs and MVs will be
            -- truncated before the move(Tables with LONG cannot be partitioned)
            if NVL(p_sub_obj_type, 'N') = 'IOT' then
              l_tot_blocks := get_tot_blocks(p_owner,
                                             'INDEX PARTITION',
                                             l_iot_top_name,
                                             tab_part_rec.partition_name);
            else
              l_tot_blocks := get_tot_blocks(p_owner,
                                             'TABLE PARTITION',
                                             p_obj_name,
                                             tab_part_rec.partition_name);
              if l_iot_over_name IS NOT NULL then
                l_tot_blocks := NVL(l_tot_blocks, 0) +
                                get_tot_blocks(p_owner,
                                               'TABLE PARTITION',
                                               l_iot_over_name,
                                               tab_part_rec.partition_name);
              end if;
            end if;
            -- Get the total blocks for all LOB Partitions
            if l_lob_str IS NOT NULL then
              FOR lob_part_rec IN lob_part_csr(p_owner,
                                               p_obj_name,
                                               tab_part_rec.partition_name)
              LOOP

                l_tot_blocks := NVL(l_tot_blocks, 0) +
                                get_tot_blocks(p_owner,
                                               'LOB PARTITION',
                                               lob_part_rec.lob_name,
                                               lob_part_rec.lob_partition_name);

                l_tot_blocks := NVL(l_tot_blocks, 0) +
                                get_tot_blocks(p_owner,
                                               'INDEX PARTITION',
                                               REPLACE(lob_part_rec.lob_name, 'LOB', 'IL'),
                                               lob_part_rec.lob_indpart_name);
              END LOOP;
            end if;
          end if;

          l_lob_str := l_store_str||l_chunk_str;
          if length(l_lob_str)>0 then l_lob_str := l_lob_str||')'; end if;
          -- added ) at the end Mladena

          l_string := 'ALTER '||l_obj_type||' "'||p_owner||'"."'||p_obj_name||'" MOVE PARTITION '||tab_part_rec.partition_name||' TABLESPACE '||p_new_tablespace||' '||l_storage_str||' '||l_iot_str||' '||l_lob_str||' '||l_parallel||' '||l_logging_str;
          write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_old_tablespace => tab_part_rec.tablespace_name,
                p_new_tablespace => p_new_tablespace,
                p_subobject_type => tab_part_rec.partition_name,
                p_tot_blocks => l_tot_blocks,
                p_parent_owner => l_parent_owner,
                p_parent_object_name => l_parent_obj_name,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'YES',
                p_parent_lineno => NVL(l_lineno, l_parent_lineno),
                x_lineno => l_lineno);
          l_sum_blocks := l_sum_blocks + l_tot_blocks;
          l_logging := tab_part_rec.logging;
        end if;
      END LOOP;

     if l_def_tablespace_name <> p_new_tablespace then
        l_string := 'ALTER TABLE "'||p_owner||'"."'||l_obj_name||'" MODIFY DEFAULT ATTRIBUTES TABLESPACE '||p_new_tablespace;
        write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_new_tablespace => p_new_tablespace,
                p_subobject_type => 'DEFAULT_TSP',
                p_parent_owner => l_parent_owner,
                p_parent_object_name => l_parent_obj_name,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                p_parent_lineno => NVL(l_lineno, l_parent_lineno),
                x_lineno => l_lineno);

      end if;
      if l_logging = 'YES' then
         l_logging_str := '" LOGGING';
      else
         l_logging_str := '" NOLOGGING';
      end if;
      l_string := 'ALTER TABLE "'||p_owner||'"."'||l_obj_name||l_logging_str;
      write_out(
                p_owner => p_owner,
                p_object_type => p_obj_type,
                p_mig_cmd => l_string,
                p_object_name => l_obj_name,
                p_new_tablespace => p_new_tablespace,
                p_subobject_type => 'LOGGING',
                p_parent_owner => l_parent_owner,
                p_parent_object_name => l_parent_obj_name,
                p_execution_mode => l_execution_mode,
                p_partitioned => 'NO',
                p_parent_lineno => NVL(l_lineno, l_parent_lineno),
                x_lineno => l_lineno);
      x_lineno := l_lineno;
   end if;

    -- Update the MV_LOG command with sum blocks
    -- as the MV_LOG TRUNCATE is the parent which will be enqueued initially.
    BEGIN
    if p_obj_type = 'TABLE' then
        UPDATE fnd_ts_mig_cmds
           SET total_blocks = l_sum_blocks,
               execution_mode = l_execution_mode
         WHERE owner = p_owner
           AND object_type = 'MV_LOG'
           AND object_name = p_parent_obj_name;
    end if;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;

    x_execution_mode := l_execution_mode;
 END gen_move_obj;


 PROCEDURE gen_rebuild_idx( p_owner IN VARCHAR2,
                            p_table_name IN VARCHAR2,
                            p_parent_obj_type IN VARCHAR2,
                            p_tab_moved IN BOOLEAN,
                            p_tablespace_name IN VARCHAR2,
                            p_parent_lineno IN NUMBER,
                            p_execution_mode IN VARCHAR2,
                            p_type IN VARCHAR2 DEFAULT 'INDEX')
 IS
  -- get all the indexes on the table
  CURSOR ind_csr(l_owner VARCHAR2, l_table_name VARCHAR2) IS
    SELECT owner,
           index_name,
           index_type,
           tablespace_name,
           partitioned,
           status,
           ityp_owner,
           ityp_name,
           domidx_opstatus,
           domidx_status,
           ltrim(rtrim(degree)) degree,
           ltrim(rtrim(logging)) logging
      FROM dba_indexes
     WHERE table_owner = l_owner
       AND table_name = l_table_name
       AND NVL(temporary, 'N') = 'N'
       AND index_type NOT IN ('IOT - TOP', 'LOB', 'CLUSTER')
     ORDER by index_type DESC;

  CURSOR part_csr(l_index_owner VARCHAR2, l_index_name VARCHAR2) IS
    SELECT partitioning_type,
           subpartitioning_type,
           def_tablespace_name
      FROM dba_part_indexes
     WHERE owner = l_index_owner
       AND index_name = l_index_name;

  CURSOR ind_part_csr(l_index_owner VARCHAR2, l_index_name VARCHAR2) IS
    SELECT /*+ ALL_ROWS */ partition_name,
           tablespace_name,
           status,
           ltrim(rtrim(logging)) logging
      FROM dba_ind_partitions
     WHERE index_owner = l_index_owner
       AND index_name = l_index_name;

  -- Check to see if all the dependent tables of context index are in the correct tablesapce, move them if not.
  CURSOR ctx_csr(l_index_owner VARCHAR2,
                 l_ctx_tabs VARCHAR2,
                 l_tablespace_name VARCHAR2) IS
    SELECT dt.owner,
           dt.table_name,
           dt.tablespace_name,
           dt.partitioned,
           dt.logging,
           dt.iot_type
      FROM dba_tables dt
     WHERE dt.owner = l_index_owner
       AND dt.table_name LIKE l_ctx_tabs
       AND dt.tablespace_name <> l_tablespace_name
       AND NVL(dt.iot_type, 'N') NOT IN ('IOT', 'IOT_OVERFLOW')
       AND NVL(dt.temporary, 'N') = 'N'
    UNION
    SELECT di.owner,
           di.table_name,
           di.tablespace_name,
           di.partitioned,
           di.logging,
           'IOT' iot_type
      FROM dba_indexes di
     WHERE di.owner = l_index_owner
       AND di.table_name LIKE l_ctx_tabs
       AND di.tablespace_name <> l_tablespace_name
       AND di.index_type = 'IOT _ TOP'
       AND NVL(di.temporary, 'N') = 'N';
  ctx_rec               ctx_csr%ROWTYPE;

  l_query                  VARCHAR2(4000);
  TYPE sdo_csr_type is REF CURSOR;
  sdo_csr                  sdo_csr_type;
  TYPE ctx_csr_type is REF CURSOR;
  ctx_stat_csr             ctx_csr_type;
  l_sdo_metadata_table     VARCHAR2(100);

  TYPE sdo_rec_type IS RECORD (
       sdo_index_type                  VARCHAR2(32),
       sdo_tsname                      VARCHAR2(32),
       sdo_index_table                 VARCHAR2(32),
       sdo_tablespace                  VARCHAR2(32),
       sdo_index_dims                  NUMBER,
       sdo_rtree_pctfree               NUMBER,
       sdo_commit_interval             NUMBER,
       sdo_level                       NUMBER,
       sdo_numtiles                    NUMBER);
  sdo_rec               sdo_rec_type;

  l_dummy               INTEGER;

  l_storage_pref        VARCHAR2(60) := 'APPS.TXN_IND_STORAGE_PREF';
  l_string              VARCHAR2(4000);
  l_sdo_params          VARCHAR2(4000);
  l_ues                 NUMBER;
  l_parallel            VARCHAR2(30);
  l_storage_str         VARCHAR2(4000);
  l_logging_str         VARCHAR2(30);
  l_tot_blocks          NUMBER := 0;
  l_lineno1             NUMBER;
  l_lineno2             NUMBER;
  l_lineno3             NUMBER;
  l_execution_mode      FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE := nvl(p_execution_mode, 'P');
--  l_parent_exec_mode  FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE := p_execution_mode;
  l_parent_lineno       NUMBER := p_parent_lineno;
  l_def_tablespace_name DBA_PART_INDEXES.DEF_TABLESPACE_NAME%TYPE;
  l_tablespace_name     FND_TABLESPACES.TABLESPACE%TYPE;
  l_part                NUMBER;
  l_logging             VARCHAR2(30) := 'YES';

 BEGIN
  FOR ind_rec IN ind_csr(p_owner, p_table_name)
  LOOP
--dbms_output.put_line('index name '||ind_rec.index_name);
    l_lineno1 := null;
    l_lineno2 := null;
    l_ues := fnd_ts_mig_util.get_tablespace_ues(p_tablespace_name);
    if l_ues IS NOT NULL then
      l_storage_str := 'STORAGE (INITIAL '||TO_CHAR(l_ues)||' NEXT '||TO_CHAR(l_ues)||') ';
    end if;

    l_logging_str := 'NOLOGGING';
    if p_execution_mode = 'P' then
      l_parallel := 'NOPARALLEL';
    elsif p_execution_mode = 'S' then
      l_parallel := 'PARALLEL';
    end if;

    if ind_rec.index_type <> 'DOMAIN' AND NVL(ind_rec.partitioned, 'NO') = 'NO'
    then
       -- Rebuild the index only if the table was moved OR the index is
       -- not in the correct tablespace.
      if p_tab_moved OR (ind_rec.tablespace_name <> p_tablespace_name)
      then
/* Execution mode will be same as that of the parent object.
        if p_parent_obj_type = 'TABLE' then
        -- Get the sizing for indexes of TABLEs only since MV_LOGs, MVIEWs
        -- and LONG_TABLEs will truncated before the move.
          l_tot_blocks := get_tot_blocks(ind_rec.owner,
                                         'INDEX',
                                         ind_rec.index_name,
                                         NULL);
          if l_tot_blocks >= g_threshold_size AND l_parent_exec_mode = 'S'
          then
            l_parallel := 'PARALLEL';
            l_execution_mode := 'S';
          end if;
        end if;
*/
        l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" REBUILD TABLESPACE '||p_tablespace_name||' '||l_storage_str||' '||l_parallel||' '||l_logging_str;
        write_out(
                   p_owner => ind_rec.owner,
                   p_object_type => p_type,
                   p_mig_cmd => l_string,
                   p_object_name => ind_rec.index_name,
                   p_old_tablespace => ind_rec.tablespace_name,
                   p_new_tablespace => p_tablespace_name,
                   p_parent_owner => p_owner,
                   p_parent_object_name => p_table_name,
                   p_tot_blocks => l_tot_blocks,
                   p_index_parallel => 'PARALLEL', -- l_parallel,
                   p_execution_mode => l_execution_mode,
                   p_parent_lineno => l_parent_lineno,
                   p_partitioned => 'NO',
                   x_lineno => l_lineno1);

        l_parent_lineno := l_lineno1;
--      l_parent_exec_mode := l_execution_mode;

        /* Mladena */
        -- if l_parallel = 'PARALLEL' then
          -- Set the Degree of parallelism back to 1.
          -- Set the Degree of parallelism back to original value.
          -- Set the LOGGING back to original value.
          -- l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" NOPARALLEL';
          if ind_rec.degree='1' then
             l_string := ' NOPARALLEL';
          elsif ind_rec.degree='DEFAULT' then
	     l_string := 'PARALLEL';
	  elsif ind_rec.degree>1 then
             l_string := 'PARALLEL '||ind_rec.degree;
          end if;

          if ind_rec.logging = 'YES' then
	     l_string := l_string||' LOGGING';
          end if;

          l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" '||l_string;
          write_out(
                   p_owner => ind_rec.owner,
                   p_object_type => p_type,
                   p_mig_cmd => l_string,
                   p_object_name => ind_rec.index_name,
                   p_old_tablespace => ind_rec.tablespace_name,
                   p_new_tablespace => p_tablespace_name,
                   p_parent_owner => ind_rec.owner,
                   p_parent_object_name => p_table_name,
                   p_tot_blocks => l_tot_blocks,
                   p_index_parallel => 'NOPARALLEL',
                   p_execution_mode => l_execution_mode,
                   p_parent_lineno => l_parent_lineno,
                   p_partitioned => 'NO',
                   x_lineno => l_lineno2);

          l_parent_lineno := l_lineno2;
        -- end if;
      end if;
    elsif ind_rec.index_type <> 'DOMAIN' AND NVL(ind_rec.partitioned, 'NO') = 'YES'
    then
      FOR part_rec IN part_csr(ind_rec.owner, ind_rec.index_name)
      LOOP
        l_def_tablespace_name := part_rec.def_tablespace_name;
        if NVL(part_rec.partitioning_type, 'X') = 'HASH' OR NVL(part_rec.subpartitioning_type, 'X') = 'HASH'
        then
          l_storage_str := NULL;
          l_logging_str := NULL;
        end if;
      END LOOP;

      l_part := 0;
      l_logging := 'YES';
      FOR ind_part_rec IN ind_part_csr(ind_rec.owner, ind_rec.index_name)
      LOOP
        if p_tab_moved OR (ind_part_rec.tablespace_name <> p_tablespace_name)
        then
        /* Execution mode will be same as that of the parent object.
          if p_parent_obj_type = 'TABLE' then
          -- Get the sizing for indexes of TABLEs only since MV_LOGs, MVIEWs
          -- and LONG_TABLEs will truncated before the move.
            l_tot_blocks := get_tot_blocks(ind_rec.owner,
                                           'INDEX PARTITION',
                                           ind_rec.index_name,
                                           ind_part_rec.partition_name);

            if l_tot_blocks >= g_threshold_size AND l_parent_exec_mode = 'S'
            then
              l_parallel := 'PARALLEL';
              l_execution_mode := 'S';
            end if;
          end if;
        */
          l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" REBUILD PARTITION '||ind_part_rec.partition_name||' TABLESPACE '||p_tablespace_name||' '||l_storage_str||' '||l_parallel||' '||l_logging_str;
          write_out(
                      p_owner => ind_rec.owner,
                      p_object_type => p_type,
                      p_mig_cmd => l_string,
                      p_object_name => ind_rec.index_name,
                      p_old_tablespace => ind_part_rec.tablespace_name,
                      p_new_tablespace => p_tablespace_name,
                      p_subobject_type => ind_part_rec.partition_name,
                      p_parent_owner => p_owner,
                      p_parent_object_name => p_table_name,
                      p_tot_blocks => l_tot_blocks,
                      p_index_parallel => 'PARALLEL', -- l_parallel,
                      p_execution_mode => l_execution_mode,
                      p_parent_lineno => l_parent_lineno,
                      p_partitioned => 'YES',
                      x_lineno => l_lineno1);
          l_parent_lineno := l_lineno1;
--        l_parent_exec_mode := l_execution_mode;
          l_part := l_part + 1;
          l_logging := ind_part_rec.logging;
        end if;
      END LOOP;
      -- Set the Degree of parallelism back to 1 for the Index if it was set
      -- to PARALLEL for any partition
      /* Mladena */
      if l_part>0 then

          if ind_rec.degree='1' then
             l_string := ' NOPARALLEL';
          elsif ind_rec.degree='DEFAULT' then
             l_string := 'PARALLEL';
          elsif ind_rec.degree>1 then
             l_string := 'PARALLEL '||ind_rec.degree;
          end if;

          if l_logging = 'YES' then
             l_string := l_string||' LOGGING';
          end if;

          l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'
                      ||ind_rec.index_name||'" '||l_string;

          write_out(
                 p_owner => ind_rec.owner,
                 p_object_type => p_type,
                 p_mig_cmd => l_string,
                 p_object_name => ind_rec.index_name,
                 p_new_tablespace => p_tablespace_name,
                 p_parent_owner => ind_rec.owner,
              -- p_parent_object_name => ind_rec.index_name,
                 p_parent_object_name => p_table_name,
                 p_index_parallel => 'NOPARALLEL',
                 p_execution_mode => l_execution_mode,
                 p_parent_lineno => l_lineno1,
                 p_partitioned => 'YES',
                 x_lineno => l_lineno2);
          l_parent_lineno := l_lineno2;
      end if;
      -- end if;
      if l_def_tablespace_name <> p_tablespace_name then
        l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" MODIFY DEFAULT ATTRIBUTES TABLESPACE '||p_tablespace_name;
        write_out(
                 p_owner => ind_rec.owner,
                 p_object_type => p_type,
                 p_mig_cmd => l_string,
                 p_object_name => ind_rec.index_name,
                 p_new_tablespace => p_tablespace_name,
                 p_subobject_type => 'DEFAULT_TSP',
                 p_parent_owner => ind_rec.owner,
                 p_parent_object_name => ind_rec.index_name,
                 p_index_parallel => 'NOPARALLEL',
                 p_execution_mode => l_execution_mode,
                 p_parent_lineno => l_parent_lineno,
                 p_partitioned => 'NO',
                 x_lineno => l_lineno3);
          l_parent_lineno := l_lineno3;
      end if;

    elsif ind_rec.index_type = 'DOMAIN' AND ind_rec.domidx_opstatus = 'VALID' AND ind_rec.domidx_status = 'VALID'
    then
      -- All Domain indexes go to transaction indexes tablespace.
      l_tablespace_name := fnd_ts_mig_util.get_tablespace_name(fnd_ts_mig_util.l_def_ind_tsp);
      if ind_rec.ityp_owner = 'CTXSYS'
      then

        l_query := 'SELECT 1
                    FROM   ctxsys.ctx_indexes
                    WHERE  idx_owner  = :1
                    AND    idx_name   = :2
                    AND    idx_status = ''INDEXED''';

        OPEN ctx_stat_csr FOR l_query USING ind_rec.owner, ind_rec.index_name;
        FETCH ctx_stat_csr INTO l_dummy;
        if ctx_stat_csr%FOUND then
          if NOT p_tab_moved then
            OPEN ctx_csr(ind_rec.owner,
                         'DR$'||ind_rec.index_name||'$%',
                         l_tablespace_name);
            FETCH ctx_csr INTO ctx_rec;
            CLOSE ctx_csr;
          end if;
          if p_tab_moved OR (ctx_rec.tablespace_name IS NOT NULL) then
            l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" REBUILD parameters (''replace storage '||l_storage_pref||''') ';
            write_out(
                       p_owner => ind_rec.owner,
                       p_object_type => p_type,
                       p_mig_cmd => l_string,
                       p_object_name => ind_rec.index_name,
                       p_old_tablespace => ind_rec.tablespace_name,
                       p_new_tablespace => l_tablespace_name,
                       p_subobject_type => 'INTERMEDIA',
                       p_parent_owner => p_owner,
                       p_parent_object_name => p_table_name,
                       p_execution_mode => l_execution_mode,
                       p_parent_lineno => l_parent_lineno,
                       x_lineno => l_lineno1);
            l_parent_lineno := l_lineno1;
          end if;
        end if;
        CLOSE ctx_stat_csr;
      elsif ind_rec.ityp_owner = 'MDSYS'
      then
          l_sdo_metadata_table := 'MDSYS.SDO_INDEX_METADATA_TABLE';
          l_query := 'SELECT sdo_index_type,
                             sdo_tsname,
                             sdo_index_table,
                             nvl(sdo_tablespace, ''X'') sdo_tablespace,
                             NVL(sdo_index_dims, 2) sdo_index_dims,
                             NVL(sdo_rtree_pctfree, 10) sdo_rtree_pctfree,
                             sdo_commit_interval,
                             sdo_level,
                             sdo_numtiles
                        FROM '||l_sdo_metadata_table||'
                       WHERE sdo_index_owner = :1
                         AND sdo_index_name = :2';
          OPEN sdo_csr FOR l_query USING ind_rec.owner, ind_rec.index_name;
          LOOP
            FETCH sdo_csr INTO sdo_rec;
            EXIT WHEN sdo_csr%NOTFOUND;
            if p_tab_moved OR (sdo_rec.sdo_tablespace <> l_tablespace_name) then
              if sdo_rec.sdo_index_type = 'RTREE' then
                l_sdo_params := 'rebuild_index='||sdo_rec.sdo_index_table||' sdo_indx_dims='||sdo_rec.sdo_index_dims||' sdo_rtr_pctfree='||sdo_rec.sdo_rtree_pctfree||' tablespace='||l_tablespace_name;
              elsif sdo_rec.sdo_index_type = 'QTREE' then
                l_sdo_params := 'rebuild_index='||sdo_rec.sdo_index_table||' sdo_commit_interval='||sdo_rec.sdo_commit_interval||' sdo_level='||sdo_rec.sdo_level||' sdo_numtiles='||sdo_rec.sdo_numtiles||' tablespace='||l_tablespace_name;
              end if;
              l_string := 'ALTER INDEX "'||ind_rec.owner||'"."'||ind_rec.index_name||'" REBUILD parameters ('''||l_sdo_params||''')';
               write_out(
                        p_owner => ind_rec.owner,
                        p_object_type => p_type,
                        p_mig_cmd => l_string,
                        p_object_name => ind_rec.index_name,
                        p_old_tablespace => ind_rec.tablespace_name,
                        p_new_tablespace => l_tablespace_name,
                        p_subobject_type => sdo_rec.sdo_index_table,
                        p_parent_owner => p_owner,
                        p_parent_object_name => p_table_name,
                        p_execution_mode => l_execution_mode,
                        p_parent_lineno => l_parent_lineno,
                        x_lineno => l_lineno1);
              l_parent_lineno := l_lineno1;
            end if;
          END LOOP;
          CLOSE sdo_csr;
      end if;
    end if;
  END LOOP;
 END gen_rebuild_idx;

 FUNCTION get_iot_tablespace(p_owner IN VARCHAR2,
                             p_iot_name IN VARCHAR2)
 RETURN VARCHAR2 IS
   CURSOR iot_ind_csr IS
     SELECT tablespace_name
       FROM dba_indexes
      WHERE table_owner = p_owner
        AND table_name = p_iot_name
        AND index_type = 'IOT - TOP';
   l_tablespace_name          VARCHAR2(30);
 BEGIN
   OPEN iot_ind_csr;
   FETCH iot_ind_csr INTO l_tablespace_name;
   CLOSE iot_ind_csr;

   RETURN l_tablespace_name;
 END get_iot_tablespace;


 PROCEDURE gen_move_aqs (p_owner IN VARCHAR2)
 IS
   TYPE AQRecTabType IS RECORD
     (owner              CharTabType,
      queue_table        CharTabType,
      tablespace_type    CharTabType,
      new_tablespace     CharTabType,
      tablespace_name    CharTabType,
      iot_type           CharTabType,
      partitioned        CharTabType,
      logging            CharTabType);
   aq_rec_tab            AQRecTabType;

   CURSOR aq_csr IS
     SELECT /*+ RULE */ dqt.owner owner,
            dqt.queue_table queue_table,
            fnd_ts_mig_util.l_aq_tab_tsp tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name tablespace_name,
            dt.iot_type iot_type,
            dt.partitioned partitioned,
            dt.logging logging
       FROM dba_queue_tables dqt,
            dba_tables dt,
            fnd_tablespaces ft
      WHERE dqt.owner = p_owner
        AND dqt.owner = dt.owner
        AND dqt.queue_table = dt.table_name
        AND ft.tablespace_type = fnd_ts_mig_util.l_aq_tab_tsp
        AND dt.table_name NOT LIKE 'BIN$%'
        AND NVL(dt.temporary, 'N') = 'N';

   qry                      VARCHAR2(4000);
   TYPE child_aq_csr_type is REF CURSOR;
   child_aq_csr             child_aq_csr_type;

   TYPE child_aq_rec_type IS RECORD (
        owner                   VARCHAR2(30),
        table_name              VARCHAR2(30),
        tablespace_name         VARCHAR2(30),
        iot_type                VARCHAR2(12),
        partitioned             VARCHAR2(3),
        logging                 VARCHAR2(3));
   child_aq_rec             child_aq_rec_type;
   l_tab_moved              BOOLEAN := FALSE;
   l_lineno                 NUMBER;
   l_child_lineno           NUMBER;
   l_execution_mode         FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE;

 BEGIN
  OPEN aq_csr;
  LOOP
   aq_rec_tab.owner.DELETE;
   FETCH aq_csr BULK COLLECT INTO
     aq_rec_tab.owner, aq_rec_tab.queue_table, aq_rec_tab.tablespace_type,
     aq_rec_tab.new_tablespace, aq_rec_tab.tablespace_name,
     aq_rec_tab.iot_type, aq_rec_tab.partitioned, aq_rec_tab.logging LIMIT 1000;
   EXIT WHEN aq_rec_tab.owner.COUNT = 0;
   FOR i IN aq_rec_tab.owner.FIRST..aq_rec_tab.owner.LAST
   LOOP
     l_tab_moved := FALSE;
     l_lineno := NULL;
     l_execution_mode := NULL;

     if aq_rec_tab.tablespace_name(i) <> aq_rec_tab.new_tablespace(i) OR
        NVL(aq_rec_tab.partitioned(i), 'NO') = 'YES'
     then
         gen_move_obj ( p_owner => aq_rec_tab.owner(i),
                        p_obj_type => 'TABLE',
                        p_sub_obj_type => aq_rec_tab.iot_type(i),
                        p_obj_name => aq_rec_tab.queue_table(i),
                        p_partitioned => aq_rec_tab.partitioned(i),
                        p_logging => aq_rec_tab.logging(i),
                        p_old_tablespace => aq_rec_tab.tablespace_name(i),
                        p_new_tablespace => aq_rec_tab.new_tablespace(i),
                        p_parent_owner => NULL,
                        p_parent_obj_name => NULL,
                        p_parent_lineno => NULL,
                        x_execution_mode => l_execution_mode,
                        x_lineno => l_lineno);
         l_tab_moved := TRUE;
     end if;

     gen_rebuild_idx( p_owner => aq_rec_tab.owner(i),
                      p_table_name => aq_rec_tab.queue_table(i),
                      p_parent_obj_type => 'TABLE',
                      p_tab_moved => l_tab_moved,
                      p_tablespace_name => aq_rec_tab.new_tablespace(i),
                      p_parent_lineno => l_lineno,
                      p_execution_mode => l_execution_mode,
                      p_type => 'INDEX');

-- Move all the dependent AQ tables
     qry := ' SELECT owner,
                     table_name,
                     tablespace_name,
                     iot_type,
                     partitioned,
                     logging
                FROM dba_tables
               WHERE owner    = :1
                 AND NVL(temporary, ''N'') = ''N''
                 AND table_name like ''AQ$_''||:2||''%''';
     OPEN child_aq_csr FOR qry USING aq_rec_tab.owner(i), aq_rec_tab.queue_table(i);
     LOOP
       FETCH child_aq_csr INTO child_aq_rec;
       EXIT WHEN child_aq_csr%NOTFOUND;
       l_tab_moved := FALSE;
       l_child_lineno := NULL;
       l_execution_mode := NULL;

       if NVL(child_aq_rec.iot_type, 'X') = 'IOT' then
         child_aq_rec.tablespace_name := get_iot_tablespace(child_aq_rec.owner,
                                                            child_aq_rec.table_name);
       end if;

       if child_aq_rec.tablespace_name <> aq_rec_tab.new_tablespace(i) OR
          NVL(child_aq_rec.partitioned, 'NO') = 'YES'
       then
         gen_move_obj ( p_owner => aq_rec_tab.owner(i),
                        p_obj_type => 'TABLE',
                        p_sub_obj_type => child_aq_rec.iot_type,
                        p_obj_name => child_aq_rec.table_name,
                        p_partitioned => child_aq_rec.partitioned,
                        p_logging => child_aq_rec.logging,
                        p_old_tablespace => child_aq_rec.tablespace_name,
                        p_new_tablespace => aq_rec_tab.new_tablespace(i),
                        p_parent_owner => NULL,
                        p_parent_obj_name => NULL,
                        p_parent_lineno => NULL,
                        x_execution_mode => l_execution_mode,
                        x_lineno => l_child_lineno);
         l_tab_moved := TRUE;
       end if;

       gen_rebuild_idx( p_owner => child_aq_rec.owner,
                        p_table_name => child_aq_rec.table_name,
                        p_parent_obj_type => 'TABLE',
                        p_tab_moved => l_tab_moved,
                        p_tablespace_name => aq_rec_tab.new_tablespace(i),
                        p_parent_lineno => l_child_lineno,
                        p_execution_mode => l_execution_mode,
                        p_type => 'INDEX');
     END LOOP;
     CLOSE child_aq_csr;

   END LOOP;
  END LOOP;
  CLOSE aq_csr;

 END gen_move_aqs;


 PROCEDURE gen_move_mvlogs (p_owner IN VARCHAR2,
                            p_table_name IN VARCHAR2,
                            x_parent_obj_name OUT NOCOPY VARCHAR2,
                            p_lineno IN NUMBER,
                            x_lineno OUT NOCOPY NUMBER,
                            p_type IN VARCHAR2 DEFAULT 'MV_LOG')
IS
   TYPE MVLogRecTabType IS RECORD
     (log_owner          CharTabType,
      master             CharTabType,
      log_table          CharTabType,
      tablespace_type    CharTabType,
      new_tablespace     CharTabType,
      tablespace_name    CharTabType,
      iot_type           CharTabType,
      partitioned        CharTabType,
      logging            CharTabType);
   mvlog_rec_tab         MVLogRecTabType;

   CURSOR mvlog_csr IS
     SELECT /*+ RULE */ distinct dsl.log_owner log_owner,
            dsl.master master,
            dsl.log_table,
            fnd_ts_mig_util.l_def_mv_tsp tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_snapshot_logs dsl,
            dba_tables dt,
            fnd_tablespaces ft
      WHERE dsl.log_owner = p_owner
        AND dsl.master = p_table_name
        AND dsl.log_owner = dt.owner
        AND dsl.log_table = dt.table_name
        AND ft.tablespace_type = fnd_ts_mig_util.l_def_mv_tsp
        AND dt.table_name NOT LIKE 'BIN$%'
        AND NVL(dt.temporary, 'N') = 'N';

   l_tab_moved              BOOLEAN := FALSE;
   l_string                 VARCHAR2(4000);
   l_lineno                 NUMBER;
   l_execution_mode         FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE;

 BEGIN
  OPEN mvlog_csr;
  LOOP
   mvlog_rec_tab.log_owner.DELETE;
   FETCH mvlog_csr BULK COLLECT INTO
      mvlog_rec_tab.log_owner, mvlog_rec_tab.master, mvlog_rec_tab.log_table,
      mvlog_rec_tab.tablespace_type, mvlog_rec_tab.new_tablespace,
      mvlog_rec_tab.tablespace_name, mvlog_rec_tab.iot_type,
      mvlog_rec_tab.partitioned, mvlog_rec_tab.logging LIMIT 1000;
   EXIT WHEN mvlog_rec_tab.log_owner.COUNT = 0;
   FOR i IN mvlog_rec_tab.log_owner.FIRST..mvlog_rec_tab.log_owner.LAST
   LOOP
     l_tab_moved := FALSE;
     l_lineno := NULL;
     l_execution_mode := NULL;

     if mvlog_rec_tab.tablespace_name(i) <> mvlog_rec_tab.new_tablespace(i)
     then
       gen_move_obj ( p_owner => mvlog_rec_tab.log_owner(i),
                      p_obj_type => p_type,
                      p_sub_obj_type => mvlog_rec_tab.iot_type(i),
                      p_obj_name => mvlog_rec_tab.master(i),
                      p_partitioned => mvlog_rec_tab.partitioned(i),
                      p_logging => mvlog_rec_tab.logging(i),
                      p_old_tablespace => mvlog_rec_tab.tablespace_name(i),
                      p_new_tablespace => mvlog_rec_tab.new_tablespace(i),
                      p_parent_owner => mvlog_rec_tab.log_owner(i),
                      p_parent_obj_name => mvlog_rec_tab.log_table(i),
                      p_parent_lineno => p_lineno,
                      x_execution_mode => l_execution_mode,
                      x_lineno => l_lineno);
       l_tab_moved := TRUE;
     end if;

     -- Rebuild all the indexes on the MV log, if any, in the new tablespace
     gen_rebuild_idx( p_owner => mvlog_rec_tab.log_owner(i),
                      p_table_name => mvlog_rec_tab.log_table(i),
                      p_parent_obj_type => p_type,
                      p_tab_moved => l_tab_moved,
                      p_tablespace_name => mvlog_rec_tab.new_tablespace(i),
                      p_parent_lineno => l_lineno,
                      p_execution_mode => l_execution_mode,
                      p_type => 'INDEX');
     x_parent_obj_name := mvlog_rec_tab.log_table(i);
     x_lineno := l_lineno;
   END LOOP;
  END LOOP;
  CLOSE mvlog_csr;

 END gen_move_mvlogs;

 PROCEDURE gen_move_mvs (p_owner IN VARCHAR2)
 IS
   TYPE MVRecTabType IS RECORD
     (owner              CharTabType,
      name               CharTabType,
      table_name         CharTabType,
      tablespace_type    CharTabType,
      new_tablespace     CharTabType,
      tablespace_name    CharTabType,
      iot_type           CharTabType,
      partitioned        CharTabType,
      logging            CharTabType);
   mv_rec_tab            MVRecTabType;

   CURSOR mv_csr IS
	SELECT /*+ RULE */ ds.owner,
            ds.name,
            ds.table_name,
            fnd_ts_mig_util.l_def_mv_tsp tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_snapshots ds,
            dba_tables dt,
            fnd_tablespaces ft
      WHERE ds.owner = p_owner
        AND ds.owner = dt.owner
        AND ds.table_name = dt.table_name
        AND dt.cluster_name IS NULL
        AND ft.tablespace_type = fnd_ts_mig_util.l_def_mv_tsp
        AND dt.table_name NOT LIKE 'BIN$%'
        AND NVL(dt.temporary, 'N') = 'N';

   CURSOR part_tsp_csr(l_owner VARCHAR2, l_table_name VARCHAR2, l_tablespace_name VARCHAR2) IS
     SELECT '1'
       FROM dba_tab_partitions
      WHERE table_owner = l_owner
        AND table_name = l_table_name
        AND tablespace_name <> l_tablespace_name;
   l_dummy                  VARCHAR2(1);

   l_tab_moved              BOOLEAN := FALSE;
   l_string                 VARCHAR2(4000);
   l_parent_lineno          NUMBER;
   l_lineno                 NUMBER;
   l_parent_owner           FND_TS_MIG_CMDS.PARENT_OWNER%TYPE;
   l_parent_obj_name        FND_TS_MIG_CMDS.PARENT_OBJECT_NAME%TYPE;
   l_execution_mode         FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE;

 BEGIN
  OPEN mv_csr;
  LOOP
   mv_rec_tab.owner.DELETE;
   FETCH mv_csr BULK COLLECT INTO
      mv_rec_tab.owner, mv_rec_tab.name, mv_rec_tab.table_name,
      mv_rec_tab.tablespace_type, mv_rec_tab.new_tablespace,
      mv_rec_tab.tablespace_name, mv_rec_tab.iot_type,
      mv_rec_tab.partitioned, mv_rec_tab.logging LIMIT 1000;
   EXIT WHEN mv_rec_tab.owner.COUNT = 0;
   FOR i IN mv_rec_tab.owner.FIRST..mv_rec_tab.owner.LAST
   LOOP
     l_tab_moved := FALSE;
     l_lineno := NULL;
     l_parent_lineno := NULL;
     l_parent_owner := NULL;
     l_parent_obj_name := NULL;
     l_execution_mode := NULL;

     if NVL(mv_rec_tab.partitioned(i), 'NO') = 'YES' then
       -- Check if any partition needs to be moved
       OPEN part_tsp_csr(mv_rec_tab.owner(i), mv_rec_tab.table_name(i), mv_rec_tab.new_tablespace(i));
       FETCH part_tsp_csr INTO l_dummy;
       if part_tsp_csr%FOUND then
         l_tab_moved := TRUE;
       end if;
       CLOSE part_tsp_csr;
     end if;

     -- Move any MV Logs on the MV in the new tablespace
     gen_move_mvlogs (p_owner => mv_rec_tab.owner(i),
                      p_table_name => mv_rec_tab.table_name(i),
                      x_parent_obj_name => l_parent_obj_name,
                      p_lineno => NULL,
                      x_lineno => l_parent_lineno,
                      p_type => 'MV_LOG');
     if l_parent_obj_name IS NOT NULL then
       l_parent_owner := mv_rec_tab.owner(i);
     end if;

     if mv_rec_tab.tablespace_name(i) <> mv_rec_tab.new_tablespace(i) OR
        l_tab_moved
     then
       gen_move_obj ( p_owner => mv_rec_tab.owner(i),
                      p_obj_type => 'MVIEW',
                      p_sub_obj_type => mv_rec_tab.iot_type(i),
                      p_obj_name => mv_rec_tab.table_name(i),
                      p_partitioned => mv_rec_tab.partitioned(i),
                      p_logging => mv_rec_tab.logging(i),
                      p_old_tablespace => mv_rec_tab.tablespace_name(i),
                      p_new_tablespace => mv_rec_tab.new_tablespace(i),
                      p_parent_owner => l_parent_owner,
                      p_parent_obj_name => l_parent_obj_name,
                      p_parent_lineno => l_parent_lineno,
                      x_execution_mode => l_execution_mode,
                      x_lineno => l_lineno);
       l_tab_moved := TRUE;
     end if;

     -- Rebuild all the indexes on the MV in the new tablespace
     gen_rebuild_idx( p_owner => mv_rec_tab.owner(i),
                      p_table_name => mv_rec_tab.table_name(i),
                      p_parent_obj_type => 'MVIEW',
                      p_tab_moved => l_tab_moved,
                      p_tablespace_name => mv_rec_tab.new_tablespace(i),
                      p_parent_lineno => l_lineno,
                      p_execution_mode => l_execution_mode,
                      p_type => 'INDEX');

   END LOOP;
  END LOOP;
  CLOSE mv_csr;

 END gen_move_mvs;

 PROCEDURE gen_truncate_tab( p_owner IN VARCHAR2,
                             p_table_name IN VARCHAR2,
                             p_new_tablespace IN VARCHAR2,
                             x_lineno OUT  NOCOPY NUMBER)
 IS
   l_string              VARCHAR2(4000);
   l_lineno              NUMBER;
 BEGIN
   l_string := 'TRUNCATE TABLE "'||p_owner||'"."'||p_table_name||'"';
   write_out(
              p_owner => p_owner,
              p_object_type => 'LONG_TABLE',
              p_mig_cmd => l_string,
              p_object_name => p_table_name,
              p_new_tablespace => p_new_tablespace,
              p_subobject_type => 'TRUNCATE',
              p_execution_mode => 'P',
              x_lineno => l_lineno);
   x_lineno := l_lineno;
 END gen_truncate_tab;

 PROCEDURE get_long_col( p_owner IN VARCHAR2,
                         p_table_name IN VARCHAR2,
                         x_col_name OUT  NOCOPY VARCHAR2,

                         x_data_type OUT  NOCOPY VARCHAR2)
 IS
   CURSOR long_col_csr IS
     SELECT column_name,
            data_type
       FROM dba_tab_columns
      WHERE owner = p_owner
        AND table_name = p_table_name
        AND data_type IN ('LONG', 'LONG RAW');
 BEGIN
   OPEN long_col_csr;
   FETCH long_col_csr INTO x_col_name, x_data_type;
   CLOSE long_col_csr;
 END get_long_col;

 PROCEDURE gen_alter_tab( p_owner IN VARCHAR2,
                          p_table_name IN VARCHAR2,
                          p_alter_type IN VARCHAR2,
                          p_col_list IN VARCHAR2,
                          p_new_tablespace IN VARCHAR2,
                          p_parent_lineno IN NUMBER,
                          x_lineno OUT NOCOPY  NUMBER)
 IS
   l_string              VARCHAR2(4000);
   l_lineno              NUMBER;
 BEGIN
   l_string := 'ALTER TABLE "'||p_owner||'"."'||p_table_name||'" '||p_alter_type||' ('||p_col_list||')';
   write_out(
              p_owner => p_owner,
              p_object_type => 'LONG_TABLE',
              p_mig_cmd => l_string,
              p_object_name => p_table_name,
              p_new_tablespace => p_new_tablespace,
              p_subobject_type => p_alter_type,
              p_execution_mode => 'P',
              p_parent_object_name => p_table_name,
              p_parent_lineno => p_parent_lineno,
              x_lineno => l_lineno);
   x_lineno := l_lineno;
 END gen_alter_tab;


 PROCEDURE gen_move_longs (p_owner IN VARCHAR2,
                           p_threshold_size IN NUMBER DEFAULT NULL)
 IS
   CURSOR userid_csr IS
     SELECT oracle_username
       FROM fnd_oracle_userid
      WHERE oracle_username = p_owner
        AND read_only_flag IN ('E', 'A', 'U', 'M', 'K');
   l_schema           VARCHAR2(30);

   TYPE TabRecTabType IS RECORD
     (owner              CharTabType,
      table_name         CharTabType,
      tablespace_type    CharTabType,
      new_tablespace     CharTabType,
      tablespace_name    CharTabType,
      iot_type           CharTabType,
      partitioned        CharTabType,
      logging            CharTabType);
   tab_rec_tab            TabRecTabType;

   CURSOR tab_csr IS
     SELECT dt.owner,
            dt.table_name,
            NVL(fot.custom_tablespace_type, fot.tablespace_type) tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_tables dt,
            fnd_object_tablespaces fot,
            fnd_tablespaces ft
      WHERE dt.owner = p_owner
        AND dt.owner = fot.oracle_username
        AND dt.table_name = fot.object_name
        AND NVL(fot.custom_tablespace_type, fot.tablespace_type) = ft.tablespace_type
        AND fot.object_type = 'TABLE'
        AND dt.cluster_name IS NULL
        AND dt.table_name NOT LIKE 'BIN$%'
        AND EXISTS ( select dtc.table_name
                       from dba_tab_columns dtc
                      where dtc.owner = p_owner
                        and dtc.table_name = dt.table_name
                        and dtc.data_type in ('LONG', 'LONG RAW'))
    UNION ALL
    -- all unclassified tables go to TRANSACTION_TABLE tablespace
     SELECT dt.owner,
            dt.table_name,
            fnd_ts_mig_util.l_unclass_tsp tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_tables dt,
            fnd_tablespaces ft
      WHERE dt.owner = p_owner
        AND ft.tablespace_type = fnd_ts_mig_util.l_unclass_tsp
        AND dt.cluster_name IS NULL
        AND dt.table_name NOT LIKE 'BIN$%'
        AND EXISTS ( select dtc.table_name
                       from dba_tab_columns dtc
                      where dtc.owner = p_owner
                        and dtc.table_name = dt.table_name
                        and dtc.data_type in ('LONG', 'LONG RAW'))
        AND NOT EXISTS ( SELECT object_name
                           FROM fnd_object_tablespaces fot
                          WHERE fot.oracle_username = p_owner
                            AND fot.object_type = 'TABLE'
                            AND fot.object_name = dt.table_name);

   CURSOR c1 IS
     SELECT fnd_ts_mig_cmds_s.nextval from dual;
   l_seq                    NUMBER;
   l_stag_tab_name          VARCHAR2(30);

   l_idx_tablespace         VARCHAR2(30);
   l_txn_idx_tablespace     VARCHAR2(30) := get_txn_idx_tablespace;
   l_long_col_name          VARCHAR2(30);
   l_long_data_type         VARCHAR2(30);
   l_string                 VARCHAR2(4000);
   l_tab_moved              BOOLEAN := FALSE;
   l_lineno1                NUMBER;
   l_lineno2                NUMBER;
   l_lineno3                NUMBER;
   l_lineno4                NUMBER;
   l_lineno5                NUMBER;
   l_lineno6                NUMBER;
   l_execution_mode         FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE;
   l_parent_owner           VARCHAR2(30);
   l_parent_obj_name        VARCHAR2(30);

 BEGIN
   g_threshold_size := p_threshold_size;
   -- Null threshold signifies all PARALLEL.

   OPEN userid_csr;
   FETCH userid_csr INTO l_schema;
   if userid_csr%NOTFOUND then
     raise_application_error(-20001, 'Schema '||p_owner||' is invalid for migration');
   end if;
   CLOSE userid_csr;


  OPEN tab_csr;
  LOOP
   tab_rec_tab.owner.DELETE;
   FETCH tab_csr BULK COLLECT INTO
      tab_rec_tab.owner, tab_rec_tab.table_name,
      tab_rec_tab.tablespace_type, tab_rec_tab.new_tablespace,
      tab_rec_tab.tablespace_name, tab_rec_tab.iot_type,
      tab_rec_tab.partitioned, tab_rec_tab.logging LIMIT 1000;
   EXIT WHEN tab_rec_tab.owner.COUNT = 0;
   FOR i IN tab_rec_tab.owner.FIRST..tab_rec_tab.owner.LAST
   LOOP
     l_tab_moved := FALSE;
     l_lineno1 := NULL;
     l_lineno2 := NULL;
     l_lineno3 := NULL;
     l_lineno4 := NULL;
     l_lineno5 := NULL;
     l_lineno6 := NULL;
     l_execution_mode := NULL;

     l_parent_owner   := NULL;
     l_parent_obj_name:= NULL;

     if tab_rec_tab.tablespace_name(i) <> tab_rec_tab.new_tablespace(i) then
       OPEN c1;
       FETCH c1 INTO l_seq;
       CLOSE c1;

       l_stag_tab_name := SUBSTR(tab_rec_tab.table_name(i), 1, 30-LENGTH(TO_CHAR(l_seq)))||TO_CHAR(l_seq);
       write_out(
              p_owner => tab_rec_tab.owner(i),
              p_object_type => 'LONG_TABLE',
              p_mig_cmd => l_stag_tab_name,
              p_object_name => tab_rec_tab.table_name(i),
              p_new_tablespace => tab_rec_tab.new_tablespace(i),
              p_subobject_type => 'COPY_TO_STAGE',
              p_execution_mode => 'P',
              x_lineno => l_lineno1);

       get_long_col( tab_rec_tab.owner(i),
                     tab_rec_tab.table_name(i),
                     l_long_col_name,
                     l_long_data_type);

       -- Check to see if there is any index on this LONG col and get its DDL
       -- Drop the index on LONG col (TBD)

       gen_alter_tab( tab_rec_tab.owner(i),
                      tab_rec_tab.table_name(i),
                      'DROP',
                      l_long_col_name,
                      tab_rec_tab.new_tablespace(i),
                      l_lineno1,
                      l_lineno2);

       -- move the table to new tablespace
       gen_move_obj ( p_owner => tab_rec_tab.owner(i),
                      p_obj_type => 'LONG_TABLE',
                      p_sub_obj_type => tab_rec_tab.iot_type(i),
                      p_obj_name => tab_rec_tab.table_name(i),
                      p_partitioned => tab_rec_tab.partitioned(i),
                      p_logging => tab_rec_tab.logging(i),
                      p_old_tablespace => tab_rec_tab.tablespace_name(i),
                      p_new_tablespace => tab_rec_tab.new_tablespace(i),
                      p_parent_owner => tab_rec_tab.owner(i),
                      p_parent_obj_name => tab_rec_tab.table_name(i),
                      p_parent_lineno => l_lineno2,
                      x_execution_mode => l_execution_mode,
                      x_lineno => l_lineno3);

       -- Add the long column back to the table
       gen_alter_tab( tab_rec_tab.owner(i),
                      tab_rec_tab.table_name(i),
                      'ADD',
                      l_long_col_name||' '||l_long_data_type,
                      tab_rec_tab.new_tablespace(i),
                      l_lineno3,
                      l_lineno4);

       write_out(
              p_owner => tab_rec_tab.owner(i),
              p_object_type => 'LONG_TABLE',
              p_mig_cmd => l_stag_tab_name,
              p_object_name => tab_rec_tab.table_name(i),
              p_new_tablespace => tab_rec_tab.new_tablespace(i),
              p_subobject_type => 'COPY_FROM_STAGE',
              p_parent_lineno => l_lineno4,
              p_execution_mode => 'P',
              x_lineno => l_lineno5);

       -- Create the index on LONG col, if any(TBD)

       l_tab_moved := TRUE;
     end if;

     -- 02/25/05 Check to see if there are any MV logs on Long Table and if present, truncate them and move them to the correct tablespace
     gen_move_mvlogs (p_owner => tab_rec_tab.owner(i),
                      p_table_name => tab_rec_tab.table_name(i),
                      x_parent_obj_name => l_parent_obj_name,
                      p_lineno => l_lineno5,
                      x_lineno => l_lineno6,
                      p_type => 'LONG_MVLOG');

     l_idx_tablespace := get_idx_tablespace(tab_rec_tab.tablespace_type(i),
                                            tab_rec_tab.new_tablespace(i),
                                            l_txn_idx_tablespace);

     -- Rebuild all the indexes on the table in the new tablespace
     gen_rebuild_idx( p_owner => tab_rec_tab.owner(i),
                      p_table_name => tab_rec_tab.table_name(i),
                      p_parent_obj_type => 'LONG_TABLE',
                      p_tab_moved => l_tab_moved,
                      p_tablespace_name => l_idx_tablespace,
                      p_parent_lineno => l_lineno5,
                      p_execution_mode => l_execution_mode,
                      p_type => 'LONG_INDEX');

   END LOOP;
  END LOOP;
  CLOSE tab_csr;

 END gen_move_longs;


 PROCEDURE gen_move_tabs (p_owner IN VARCHAR2)
 IS
   TYPE TabRecTabType IS RECORD
     (owner              CharTabType,
      table_name         CharTabType,
      tablespace_type    CharTabType,
      new_tablespace     CharTabType,
      tablespace_name    CharTabType,
      iot_type           CharTabType,
      partitioned        CharTabType,
      logging            CharTabType);
   tab_rec_tab            TabRecTabType;

   CURSOR tab_csr IS
     -- Classified tables only
     SELECT dt.owner,
            dt.table_name,
            NVL(fot.custom_tablespace_type, fot.tablespace_type) tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_tables dt,
            fnd_object_tablespaces fot,
            fnd_tablespaces ft
      WHERE dt.owner = p_owner
        AND dt.owner = fot.oracle_username
        AND dt.table_name = fot.object_name
        AND NVL(fot.custom_tablespace_type, fot.tablespace_type) = ft.tablespace_type
        AND fot.object_type = 'TABLE'
        AND NVL(dt.temporary, 'N') = 'N'
        AND dt.cluster_name IS NULL
        AND NOT EXISTS ( select dtc.table_name
                           from dba_tab_columns dtc
                          where dtc.owner = p_owner
                            and dtc.table_name = dt.table_name
                            and dtc.data_type in ('LONG', 'LONG RAW'))
        AND NOT EXISTS ( select ds.table_name
                           from dba_snapshots ds
                          where ds.owner = p_owner
                            and ds.table_name = dt.table_name)
        AND NOT EXISTS ( select dsl.log_table
                           from dba_snapshot_logs dsl
                          where dsl.log_owner = p_owner
                            and dsl.log_table = dt.table_name)
        AND NOT EXISTS ( select dqt.queue_table
                           from dba_queue_tables dqt
                          where dqt.owner = p_owner
                            and dqt.queue_table = dt.table_name)
        AND NOT EXISTS ( select det.table_name
                           from dba_external_tables det
                          where det.owner = p_owner
                            and det.table_name = dt.table_name)
        AND dt.table_name NOT LIKE 'AQ$%'  -- tables for AQ tables
        AND (dt.table_name NOT LIKE 'DR$%'  -- tables for INTERMEDIA indexes
             OR dt.owner = 'CTXSYS')
        AND dt.table_name NOT LIKE 'RUPD$%' -- tables for snapshot logs
        AND dt.table_name NOT LIKE 'MDRT%$' -- tables for SPATIAL indexes
        AND dt.table_name NOT LIKE 'BIN$%'
        AND dt.nested='NO'
    UNION ALL
    -- all unclassified tables go to TRANSACTION_TABLES tablespace
    -- Not IOTs, AQs, Domain Index tables, MVs, MV logs
     SELECT dt.owner,
            dt.table_name,
            fnd_ts_mig_util.l_unclass_tsp tablespace_type,
            ft.tablespace new_tablespace,
            dt.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_tables dt,
            fnd_tablespaces ft
      WHERE dt.owner = p_owner
        AND ft.tablespace_type = fnd_ts_mig_util.l_unclass_tsp
        AND NOT EXISTS ( SELECT object_name
                           FROM fnd_object_tablespaces fot
                          WHERE fot.oracle_username = p_owner
                            AND fot.object_type = 'TABLE'
                            AND fot.object_name = dt.table_name)
        AND NVL(dt.temporary, 'N') = 'N'
        AND NVL(dt.iot_type, 'X') NOT IN ('IOT', 'IOT_OVERFLOW')
        AND dt.cluster_name IS NULL
        AND NOT EXISTS ( select dtc.table_name
                           from dba_tab_columns dtc
                          where dtc.owner = p_owner
                            and dtc.table_name = dt.table_name
                            and dtc.data_type in ('LONG', 'LONG RAW'))
        AND NOT EXISTS ( select ds.table_name
                           from dba_snapshots ds
                          where ds.owner = p_owner
                            and ds.table_name = dt.table_name)
        AND NOT EXISTS ( select dsl.log_table
                           from dba_snapshot_logs dsl
                          where dsl.log_owner = p_owner
                            and dsl.log_table = dt.table_name)
        AND NOT EXISTS ( select dqt.queue_table
                           from dba_queue_tables dqt
                          where dqt.owner = p_owner
                            and dqt.queue_table = dt.table_name)
        AND NOT EXISTS ( select det.table_name
                           from dba_external_tables det
                          where det.owner = p_owner
                            and det.table_name = dt.table_name)
        AND dt.table_name NOT LIKE 'AQ$%'  -- tables for AQ tables
        AND (dt.table_name NOT LIKE 'DR$%'  -- tables for INTERMEDIA indexes
             OR dt.owner = 'CTXSYS')
        AND dt.table_name NOT LIKE 'RUPD$%' -- tables for snapshot logs
        AND dt.table_name NOT LIKE 'MDRT%$' -- tables for SPATIAL indexes
        AND dt.table_name NOT LIKE 'BIN$%'
        AND dt.nested='NO'
    UNION ALL
    -- all IOTs go to TRANSACTION_TABLES (default rule)
    -- Not AQs, Domain Index tables
     SELECT dt.owner,
            dt.table_name,
            fnd_ts_mig_util.l_def_tab_tsp tablespace_type,
            ft.tablespace new_tablespace,
            di.tablespace_name,
            dt.iot_type,
            dt.partitioned,
            dt.logging
       FROM dba_tables dt,
            dba_indexes di,
            fnd_tablespaces ft
      WHERE dt.owner = p_owner
        AND ft.tablespace_type = fnd_ts_mig_util.l_def_tab_tsp
        AND dt.owner = di.table_owner
        AND dt.table_name = di.table_name
        AND di.index_type = 'IOT - TOP'
        AND NVL(dt.temporary, 'N') = 'N'
        AND NVL(dt.iot_type, 'X') = 'IOT'
        AND dt.cluster_name IS NULL
        AND NOT EXISTS ( select dqt.queue_table
                           from dba_queue_tables dqt
                          where dqt.owner = p_owner
                            and dqt.queue_table = dt.table_name)
        AND NOT EXISTS ( select det.table_name
                           from dba_external_tables det
                          where det.owner = p_owner
                            and det.table_name = dt.table_name)
        AND dt.table_name NOT LIKE 'AQ$%'  -- tables for AQ tables
        AND (dt.table_name NOT LIKE 'DR$%'  -- tables for INTERMEDIA indexes
             OR dt.owner = 'CTXSYS')
        AND dt.table_name NOT LIKE 'MDRT%$' -- tables for SPATIAL indexes
        AND dt.table_name NOT LIKE 'BIN$%'
        AND dt.table_name NOT LIKE 'RUPD$%'; -- tables for snapshot logs

   CURSOR part_tsp_csr(l_owner VARCHAR2, l_table_name VARCHAR2, l_tablespace_name VARCHAR2) IS
     SELECT '1'
       FROM dba_tab_partitions
      WHERE table_owner = l_owner
        AND table_name = l_table_name
        AND tablespace_name <> l_tablespace_name;
   l_dummy                  VARCHAR2(1);

   l_idx_tablespace         VARCHAR2(30);
   l_txn_idx_tablespace     VARCHAR2(30) := get_txn_idx_tablespace;
   l_tab_moved              BOOLEAN := FALSE;
   l_lineno                 NUMBER;
   l_parent_lineno          NUMBER;
   l_parent_owner           FND_TS_MIG_CMDS.PARENT_OWNER%TYPE;
   l_parent_obj_name        FND_TS_MIG_CMDS.PARENT_OBJECT_NAME%TYPE;
   l_execution_mode         FND_TS_MIG_CMDS.EXECUTION_MODE%TYPE;

 BEGIN

  OPEN tab_csr;
  LOOP
   tab_rec_tab.owner.DELETE;
   FETCH tab_csr BULK COLLECT INTO
      tab_rec_tab.owner, tab_rec_tab.table_name,
      tab_rec_tab.tablespace_type, tab_rec_tab.new_tablespace,
      tab_rec_tab.tablespace_name, tab_rec_tab.iot_type,
      tab_rec_tab.partitioned, tab_rec_tab.logging LIMIT 1000;
   EXIT WHEN tab_rec_tab.owner.COUNT = 0;
   FOR i IN tab_rec_tab.owner.FIRST..tab_rec_tab.owner.LAST
   LOOP
     l_tab_moved := FALSE;
     l_lineno := NULL;
     l_parent_lineno := NULL;
     l_parent_owner := NULL;
     l_parent_obj_name := NULL;
     l_execution_mode := NULL;

     if NVL(tab_rec_tab.partitioned(i), 'NO') = 'YES' then
       -- Check if any partition needs to be moved
       OPEN part_tsp_csr(tab_rec_tab.owner(i),tab_rec_tab.table_name(i),tab_rec_tab.new_tablespace(i));
       FETCH part_tsp_csr INTO l_dummy;
       if part_tsp_csr%FOUND then
         l_tab_moved := TRUE;
       end if;
       CLOSE part_tsp_csr;
     end if;

     -- 04/21/03 Check to see if there are any MV logs on this Table and if present, truncate them and move them to the correct tablespace before moving the table.
     gen_move_mvlogs (p_owner => tab_rec_tab.owner(i),
                      p_table_name => tab_rec_tab.table_name(i),
                      x_parent_obj_name => l_parent_obj_name,
                      p_lineno => NULL,
                      x_lineno => l_parent_lineno,
                      p_type => 'MV_LOG');
     if l_parent_obj_name IS NOT NULL then
       l_parent_owner := tab_rec_tab.owner(i);
     end if;

     if tab_rec_tab.tablespace_name(i) <> tab_rec_tab.new_tablespace(i) OR
        l_tab_moved
     then
       gen_move_obj ( p_owner => tab_rec_tab.owner(i),
                      p_obj_type => 'TABLE',
                      p_sub_obj_type => tab_rec_tab.iot_type(i),
                      p_obj_name => tab_rec_tab.table_name(i),
                      p_partitioned => tab_rec_tab.partitioned(i),
                      p_logging => tab_rec_tab.logging(i),
                      p_old_tablespace => tab_rec_tab.tablespace_name(i),
                      p_new_tablespace => tab_rec_tab.new_tablespace(i),
                      p_parent_owner => l_parent_owner,
                      p_parent_obj_name => l_parent_obj_name,
                      p_parent_lineno => l_parent_lineno,
                      x_execution_mode => l_execution_mode,
                      x_lineno => l_lineno);
       l_tab_moved := TRUE;
     end if;

     l_idx_tablespace := get_idx_tablespace(tab_rec_tab.tablespace_type(i),
                                            tab_rec_tab.new_tablespace(i),
                                            l_txn_idx_tablespace);

     -- Rebuild all the indexes on the table in the new tablespace
     gen_rebuild_idx( p_owner => tab_rec_tab.owner(i),
                      p_table_name => tab_rec_tab.table_name(i),
                      p_parent_obj_type => 'TABLE',
                      p_tab_moved => l_tab_moved,
                      p_tablespace_name => l_idx_tablespace,
                      p_parent_lineno => l_lineno,
                      p_execution_mode => l_execution_mode,
                      p_type => 'INDEX');

   END LOOP;
  END LOOP;
  CLOSE tab_csr;

 END gen_move_tabs;


 PROCEDURE gen_migrate_schema (p_schema IN VARCHAR2,
                               p_threshold_size IN NUMBER DEFAULT NULL)
 IS
   CURSOR userid_csr IS
     SELECT oracle_username
       FROM fnd_oracle_userid
      WHERE oracle_username = p_schema
        AND read_only_flag IN ('E', 'A', 'U', 'M', 'K');
   l_schema           VARCHAR2(30);
   l_string           VARCHAR2(4000);
 BEGIN
   OPEN userid_csr;
   FETCH userid_csr INTO l_schema;
   if userid_csr%NOTFOUND then
     raise_application_error(-20001, 'Schema '||p_schema||' is invalid for migration');
   end if;
   CLOSE userid_csr;

   g_threshold_size := p_threshold_size;

   gen_move_tabs (l_schema);

   gen_move_mvs (l_schema);

   gen_move_aqs (l_schema);

 END gen_migrate_schema;


 PROCEDURE gen_alter_constraint (p_schema IN VARCHAR2)
 IS
   CURSOR cons_csr(l_owner VARCHAR2) IS
     SELECT dc.owner, dc.table_name, dc.constraint_name
       FROM dba_constraints dc
      WHERE r_owner = l_owner
        AND constraint_type = 'R'
        AND status = 'ENABLED';
   l_string        VARCHAR2(4000);
   l_lineno        NUMBER;
 BEGIN
   FOR cons_rec IN cons_csr(p_schema)
   LOOP
     l_string := 'ALTER TABLE "'||cons_rec.owner||'"."'||cons_rec.table_name||'" DISABLE CONSTRAINT '||cons_rec.constraint_name;
     write_out(
                p_owner => p_schema,
                p_object_type => 'DISABLE_CONSTRAINT',
                p_mig_cmd => l_string,
                p_object_name => cons_rec.constraint_name,
                x_lineno => l_lineno);

     l_string := 'ALTER TABLE "'||cons_rec.owner||'"."'||cons_rec.table_name||'" ENABLE NOVALIDATE CONSTRAINT '||cons_rec.constraint_name;
     write_out(
                p_owner => p_schema,
                p_object_type => 'ENABLE_CONSTRAINT',
                p_mig_cmd => l_string,
                p_object_name => cons_rec.constraint_name,
                x_lineno => l_lineno);
   END LOOP;
 END gen_alter_constraint;

 PROCEDURE gen_alter_trigger (p_schema IN VARCHAR2)
 IS
   CURSOR trg_csr(l_owner VARCHAR2) IS
     SELECT dt.owner, dt.trigger_name
       FROM dba_triggers dt
      WHERE table_owner = l_owner
        AND status = 'ENABLED';
   l_string        VARCHAR2(4000);
   l_lineno        NUMBER;
 BEGIN
   FOR trg_rec IN trg_csr(p_schema)
   LOOP
     l_string := 'ALTER TRIGGER "'||trg_rec.owner||'"."'||trg_rec.trigger_name||'" DISABLE';
     write_out(
                p_owner => p_schema,
                p_object_type => 'DISABLE_TRIGGER',
                p_mig_cmd => l_string,
                p_object_name => trg_rec.trigger_name,
                x_lineno => l_lineno);

     l_string := 'ALTER TRIGGER "'||trg_rec.owner||'"."'||trg_rec.trigger_name||'" ENABLE';
     write_out(
                p_owner => p_schema,
                p_object_type => 'ENABLE_TRIGGER',
                p_mig_cmd => l_string,
                p_object_name => trg_rec.trigger_name,
                x_lineno => l_lineno);
   END LOOP;
 END gen_alter_trigger;

 PROCEDURE gen_alter_queue (p_schema IN VARCHAR2)
 IS
   CURSOR queue_csr(l_owner VARCHAR2) IS
     SELECT dq.owner, dq.name
       FROM dba_queues dq
      WHERE owner = l_owner
        AND queue_type = 'NORMAL_QUEUE'
        AND TRIM(enqueue_enabled) = 'YES';
   l_string        VARCHAR2(4000);
   l_lineno        NUMBER;
 BEGIN
   FOR queue_rec IN queue_csr(p_schema)
   LOOP
     l_string := 'BEGIN DBMS_AQADM.STOP_QUEUE('''||queue_rec.owner||'.'||queue_rec.name||'''); END;';
     write_out(
                p_owner => p_schema,
                p_object_type => 'STOP_QUEUE',
                p_mig_cmd => l_string,
                p_object_name => queue_rec.name,
                x_lineno => l_lineno);

     l_string := 'BEGIN DBMS_AQADM.START_QUEUE('''||queue_rec.owner||'.'||queue_rec.name||'''); END;';
     write_out(
                p_owner => p_schema,
                p_object_type => 'START_QUEUE',
                p_mig_cmd => l_string,
                p_object_name => queue_rec.name,
                x_lineno => l_lineno);
   END LOOP;
 END gen_alter_queue;

 PROCEDURE gen_alter_policy (p_schema IN VARCHAR2)
 IS
  CURSOR policy_csr(l_owner VARCHAR2) IS
    SELECT object_owner,
           object_name,
           policy_group,
           policy_name
      FROM dba_policies
     WHERE object_owner = l_owner
       AND enable = 'YES';
   l_string        VARCHAR2(4000);
   l_lineno        NUMBER;
 BEGIN
   FOR policy_rec IN policy_csr(p_schema)
   LOOP
     l_string := 'BEGIN DBMS_RLS.ENABLE_GROUPED_POLICY('''||policy_rec.object_owner||''', '''||policy_rec.object_name||''', '''||policy_rec.policy_group||''', '''||policy_rec.policy_name||''', FALSE); END;';
     write_out(
                p_owner => p_schema,
                p_object_type => 'DISABLE_POLICY',
                p_mig_cmd => l_string,
                p_object_name => policy_rec.policy_name,
                p_subobject_type => policy_rec.object_name,
                x_lineno => l_lineno);

     l_string := 'BEGIN DBMS_RLS.ENABLE_GROUPED_POLICY('''||policy_rec.object_owner||''', '''||policy_rec.object_name||''', '''||policy_rec.policy_group||''', '''||policy_rec.policy_name||''', TRUE); END;';
     write_out(
                p_owner => p_schema,
                p_object_type => 'ENABLE_POLICY',
                p_mig_cmd => l_string,
                p_object_name => policy_rec.policy_name,
                p_subobject_type => policy_rec.object_name,
                x_lineno => l_lineno);
   END LOOP;
 END gen_alter_policy;

 PROCEDURE gen_postmig_cmd (p_schema IN VARCHAR2)
 IS
   CURSOR lineno_csr IS
     SELECT FND_TS_MIG_CMDS_S.nextval
       FROM SYS.dual;
   l_lineno              NUMBER;

   CURSOR cmd_csr IS
     SELECT lineno, subobject_type
       FROM fnd_ts_mig_cmds
      WHERE object_type = 'POSTMIG'
        AND object_name = 'AQ_TM_PROCESSES';

   CURSOR aq_tm_csr IS
     SELECT value
       FROM v$parameter
      WHERE name='aq_tm_processes';
   l_string        VARCHAR2(1000);
   l_value1        VARCHAR2(1000);
   l_value2        VARCHAR2(1000);
 BEGIN
   OPEN cmd_csr;
   FETCH cmd_csr INTO l_lineno, l_value1;
   CLOSE cmd_csr;

   OPEN aq_tm_csr;
   FETCH aq_tm_csr INTO l_value2;
   CLOSE aq_tm_csr;

   if NVL(l_value2, 0) <> 0 AND l_value1 IS NULL then
     OPEN lineno_csr;
     FETCH lineno_csr INTO l_lineno;
     CLOSE lineno_csr;

     l_string := 'ALTER SYSTEM SET AQ_TM_PROCESSES = '||l_value2;
     INSERT INTO fnd_ts_mig_cmds (lineno,
                                   owner,
                                   object_type,
                                   subobject_type,
                                   index_parallel,
                                   object_name,
                                   migration_cmd,
                                   migration_status,
                                   execution_mode,
                                   partitioned,
                                   generation_date,
                                   last_update_date)
        VALUES (l_lineno,
                p_schema,
                'POSTMIG',
                l_value2,
                'NOPARALLEL',
                'AQ_TM_PROCESSES',
                l_string,
                'GENERATED',
                'P',
                'NO',
                sysdate,
                sysdate);
   elsif NVL(l_value2, 0) <> 0 AND l_value1 <> l_value2 then
      l_string := 'ALTER SYSTEM SET AQ_TM_PROCESSES = '||l_value2;
      UPDATE fnd_ts_mig_cmds
         SET migration_cmd = l_string,
             subobject_type = l_value2,
             generation_date = sysdate,
             last_update_date = sysdate
       WHERE lineno = l_lineno;
   end if;

 END gen_postmig_cmd;

 PROCEDURE gen_disable_cmds (p_schema IN VARCHAR2)
 IS
 BEGIN

   gen_alter_constraint (p_schema);

   gen_alter_trigger (p_schema);

   gen_alter_queue (p_schema);

   gen_alter_policy (p_schema);

   gen_postmig_cmd (p_schema);

 END gen_disable_cmds;

END fnd_gen_mig_cmds;

/
