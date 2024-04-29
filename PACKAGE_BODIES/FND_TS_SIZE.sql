--------------------------------------------------------
--  DDL for Package Body FND_TS_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TS_SIZE" AS
/* $Header: fndpsizb.pls 120.4 2005/11/22 15:16:16 mnovakov noship $ */

 TYPE rec_type IS RECORD (
	owner			VARCHAR2(30),
	table_name		VARCHAR2(30),
	tablespace_name		VARCHAR2(30),
	object_class		VARCHAR2(30),
	parent			VARCHAR2(30),
	object_type		VARCHAR2(30),
	subobject_type		VARCHAR2(30),
	classified		VARCHAR2(3),
	partitioned		VARCHAR2(3));

 FUNCTION get_tsp_name (p_tablespace_type IN VARCHAR2)
   RETURN VARCHAR2
 IS
   CURSOR tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = p_tablespace_type;
   l_tablespace_name       VARCHAR2(30);
 BEGIN
   OPEN tsp_csr;
   FETCH tsp_csr INTO l_tablespace_name;
   CLOSE tsp_csr;
   RETURN l_tablespace_name;
 END get_tsp_name;

 PROCEDURE ins_fnd_ts_sizing (cur_rec IN rec_type,
                              p_uni_extent IN NUMBER,
                              p_allocation_type IN VARCHAR2,
                              p_creation_date IN DATE,
                              p_partition_name IN VARCHAR2 DEFAULT NULL)
 IS
   tot_blks               NUMBER(15);
   tot_byts               NUMBER(15);
   unused_blks            NUMBER;
   unused_byts            NUMBER;
   used_byts              NUMBER(15);
   lst_ext_file           NUMBER;
   lst_ext_blk            NUMBER;
   lst_usd_blk            NUMBER;
   l_err_status           VARCHAR2(30);
   l_err_code             VARCHAR2(4000);
   l_tablespace_name      VARCHAR2(30);
   l_object_type          VARCHAR2(30);
   l_uniform_extent_size  NUMBER(15);
   l_number_of_extents    NUMBER(15);
   l_total_bytes_required NUMBER(15);

   l_version              NUMBER;

   CURSOR lob_part_siz_csr IS
     SELECT bytes
       FROM dba_segments
      WHERE owner = cur_rec.owner
        AND segment_name = cur_rec.table_name
        AND partition_name = p_partition_name;
 BEGIN
   l_tablespace_name := get_tsp_name(cur_rec.object_class);

/*
   if SUBSTR(cur_rec.table_name, 1, 7) = 'SYS_LOB' then
     if cur_rec.partitioned = 'YES' then
       l_object_type := 'LOB PARTITION';
     else
       l_object_type := 'LOBSEGMENT';
     end if;
   elsif SUBSTR(cur_rec.table_name, 1, 6) = 'SYS_IL' then
     if cur_rec.partitioned = 'YES' then
       l_object_type := 'LOB INDEX PARTITION';
     else
       l_object_type := 'LOBINDEX';
     end if;
   else
     l_object_type := cur_rec.object_type;
   end if;
*/
   l_object_type := cur_rec.object_type;

   if cur_rec.object_type = 'LOB PARTITION' then
     l_version := fnd_ts_mig_util.get_db_version;
   end if;

   if cur_rec.object_type = 'LOB PARTITION' AND l_version < 10 then
     OPEN lob_part_siz_csr;
     FETCH lob_part_siz_csr INTO tot_byts;
     CLOSE lob_part_siz_csr;
     unused_byts := 0;
   else
   begin
     DBMS_SPACE.UNUSED_SPACE (
			cur_rec.owner,
			cur_rec.table_name,
			cur_rec.object_type,
    			tot_blks,
    			tot_byts,
    			unused_blks,
    			unused_byts,
    			lst_ext_file,
    			lst_ext_blk,
    			lst_usd_blk,
                        p_partition_name);
   exception when others then
      l_err_status := 'ERROR';
      tot_byts := 0;
      tot_blks := 0;
      unused_byts := 0;
      unused_blks := 0;
      l_err_code := sqlerrm;
   end;
   end if;
   used_byts := tot_byts - unused_byts;

   if P_ALLOCATION_TYPE = 'A' then
         l_uniform_extent_size:= null;
         l_number_of_extents:= null ;
      if tot_byts <=1048576 then
         l_total_bytes_required:= CEIL(used_byts/65536) * (65536);
         l_uniform_extent_size:= 65536;
         l_number_of_extents:= CEIL(used_byts/65536);
       end if;

      if (tot_byts <=67108864 and tot_byts >1048576)  then
         l_total_bytes_required:= CEIL(used_byts/1048576) * (1048576);
         l_uniform_extent_size:= 1048576;
         l_number_of_extents:= CEIL(used_byts/1048576);
      end if;

      if (tot_byts <=1073741824  and tot_byts > 67108864 ) then
         l_uniform_extent_size:= 8388608;
         l_number_of_extents:= CEIL(used_byts/8388608);
         l_total_bytes_required:= CEIL(used_byts/8388608) * (8388608);
      end if;

      if tot_byts > 1073741824  then
         l_total_bytes_required:= CEIL(used_byts/67108864) * (67108864);
         l_uniform_extent_size:= 67108864;
         l_number_of_extents:= CEIL(used_byts/67108864);
      end if;

   else
       if P_ALLOCATION_TYPE = 'U' then
         l_uniform_extent_size:= p_uni_extent;
         l_number_of_extents:= CEIL(used_byts/p_uni_extent);
         l_total_bytes_required:= (ceil(used_byts/p_uni_extent))*(p_uni_extent);
       end if;
    end if;

   INSERT INTO fnd_ts_sizing (
			owner,
			old_tablespace,
			new_tablespace,
			object_type,
			object_name,
			parent_object_name,
			current_extents,
			current_bytes,
			free_bytes,
			used_bytes,
			uniform_extent_size,
			number_of_extents,
                        allocation_type,
			total_bytes_required,
			sizing_error_status,
			error_code,
			classified,
			partitioned,
			creation_date)
                    values (
			cur_rec.owner,
       			cur_rec.tablespace_name,
			l_tablespace_name,
       			l_object_type,
       			cur_rec.table_name,
       			cur_rec.parent,
       			NULL,
       			tot_byts,
       			unused_byts,
       			used_byts,
                        l_uniform_extent_size,
       			--p_uni_extent,
       			--CEIL(used_byts/p_uni_extent),
                         l_number_of_extents,
       			--CEIL(used_byts/p_uni_extent) * p_uni_extent,
                         p_allocation_type,
                         l_total_bytes_required,
       			l_err_status,
       			l_err_code,
			cur_rec.classified,
			cur_rec.partitioned,
      			p_creation_date);

 END ins_fnd_ts_sizing;

 PROCEDURE gen_tab_sizing (p_app IN VARCHAR2,
                           p_uni_extent IN NUMBER,
                           p_allocation_type IN VARCHAR2,
                           p_creation_date IN DATE)
 IS
  cur_rec            rec_type;

  cursor tab_csr is
  -- CLASSIFIED
  -- TABLES (Normal) minus IOT Tables)
  -- MINUS AQ TABLES
  -- MINUS IOT OVERFLOW TABLES
  SELECT /*+ rule */	d.owner,
		d.table_name,
		d.tablespace_name,
		nvl(o.custom_tablespace_type, o.tablespace_type) object_class,
		'table' parent,
		'TABLE' object_type,
		'TABLE' subobject_type,
		'YES'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	fnd_object_tablespaces o,
         	DBA_TABLES d
   WHERE d.owner 			= o.oracle_username
     AND o.oracle_username 		= p_app
     AND d.owner	 		= p_app
     AND o.object_name 			= d.table_name
     AND o.object_type 			= 'TABLE'
     AND nvl(d.iot_type,'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(d.temporary, 'N') = 'N'
     AND d.table_name NOT LIKE 'BIN$%'
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = d.owner
                         and det.table_name = d.table_name)
  UNION ALL
  -- UNCLASSIFIED
  -- TABLES (Normal) minus IOT Tables, MV, MV logs
  -- MINUS AQ TABLES and Domain Indexes tables
  -- MINUS IOT and IOT OVERFLOW TABLES
  SELECT /*+ rule */	d.owner,
		d.table_name,
		d.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		'table' parent,
		'TABLE' object_type,
		'TABLE' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_tables d
   WHERE 	d.owner 	= p_app
     AND NOT EXISTS
        (SELECT object_name
           FROM fnd_object_tablespaces o
          WHERE o.oracle_username = p_app
            and o.object_name = d.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM DBA_SNAPSHOTS s
          where s.owner = p_app
            and s.table_name = d.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM DBA_SNAPSHOT_LOGS L
          where l.log_owner = p_app
            and l.log_table = d.table_name)
     AND  nvl(d.iot_type,'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = p_app
             and dqt.queue_table = d.table_name)
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = p_app
                         and det.table_name = d.table_name)
     AND  d.table_name NOT LIKE 'AQ$%'
     AND  d.table_name NOT LIKE 'DR$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- MVIEW LOGS
  SELECT /*+ rule */ distinct dsl.log_owner,
		dsl.log_table table_name,
		dt.tablespace_name,
                fnd_ts_mig_util.l_def_mv_tsp object_class,
		dt.table_name parent,
		'TABLE' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM 	dba_tables dt,
         	dba_snapshot_logs dsl
   WHERE  dsl.log_owner = p_app
     AND  dsl.log_owner = dt.owner
     AND  dt.owner = p_app
     AND  dsl.log_table = dt.table_name
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- MVIEWS
  SELECT /*+ rule */	d.owner,
		d.name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		dt.table_name parent,
		'TABLE' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM 	dba_snapshots d,
       		dba_tables dt
   WHERE  d.owner = p_app
     AND  d.owner = dt.owner
     AND  dt.owner = p_app
     AND  dt.table_name = d.table_name
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW
  -- MINUS AQ TABLES
  -- MINUS IOT START WITH 'DR$%' (Domain Index Tables IOT OVERFLOW)
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner = p_app
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'AQ$%'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'DR$%'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW FOR AQ TABLES
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
             fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner = p_app
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  NVL(dt.iot_name, 'ZZZ') LIKE 'AQ$%'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW for Domain Indexes IOTs
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner = p_app
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  NVL(dt.iot_name, 'ZZZ') LIKE 'DR$%'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in Classified Objects
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
		nvl(o.custom_tablespace_type, o.tablespace_type) object_class,
		d.table_name parent,
		'LOB' object_type,
		'TABLE' subobject_type,
		'YES' classified,
		nvl(dt.partitioned,'NO') partitioned
    from  fnd_object_tablespaces o,
          dba_lobs d,
          dba_tables dt
   where  dt.owner = p_app
     and  dt.owner = o.oracle_username
     and  o.oracle_username = p_app
     and  o.object_name = d.table_name
     and  o.object_type = 'TABLE'
     and  d.owner = p_app
     and  d.owner = dt.owner
     and  d.table_name = dt.table_name
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = dt.owner
                         and det.table_name = dt.table_name)
  UNION ALL
  -- LOBS in Unclassified Tables
  -- (no IOT, MVs, AQs, Domain Indexes)
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		d.table_name parent,
		'LOB' object_type,
		'TABLE' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs d,
          dba_tables dt
   where  d.owner = p_app
     and  d.owner = dt.owner
     and  dt.owner = p_app
     and  d.table_name = dt.table_name
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = p_app
             and o.object_name = dt.table_name)
     AND NOT  EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = dt.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs l
          where l.log_owner = p_app
            and l.log_table = d.table_name)
     and  dt.iot_type IS NULL
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = p_app
             and dqt.queue_table = dt.table_name)
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = p_app
                         and det.table_name = d.table_name)
     AND  dt.table_name NOT LIKE 'AQ$%'
     AND  dt.table_name NOT LIKE 'DR$%'
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in IOTs
  -- Minus AQ and Domain Index
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		d.table_name parent,
		'LOB' object_type,
		'IOT' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs d,
          dba_tables dt
   where  d.owner = p_app
     and  d.owner = dt.owner
     and  dt.owner = p_app
     and  d.table_name = dt.table_name
     and  NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = p_app
             and dqt.queue_table = dt.table_name)
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = p_app
                         and det.table_name = d.table_name)
     AND  dt.table_name NOT LIKE 'AQ$%'
     AND  dt.table_name NOT LIKE 'DR$%'
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBs in MVs
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		d.table_name parent,
		'LOB' object_type,
		'MVIEW' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs d,
          dba_tables dt
   where  d.owner = p_app
     and  d.owner = dt.owner
     and  dt.owner = p_app
     and  d.table_name = dt.table_name
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = d.table_name)
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in AQs
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		d.table_name parent,
		'LOB' object_type,
		'AQ' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs d,
          dba_tables dt
   where  d.owner = p_app
     and  d.owner = dt.owner
     and  dt.owner = p_app
     and  d.table_name = dt.table_name
     AND (EXISTS
           (SELECT queue_table
              FROM dba_queue_tables dqt
             WHERE dqt.owner = p_app
               and dqt.queue_table = dt.table_name)
           OR  dt.table_name LIKE 'AQ$%')
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in Domain Index Objects
  select /*+ rule */	d.owner,
		d.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		d.table_name parent,
		'LOB' object_type,
		'DOMAIN' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs d,
          dba_tables dt
   where  d.owner = p_app
     and  d.owner = dt.owner
     and  dt.owner = p_app
     and  d.table_name = dt.table_name
     AND  dt.table_name LIKE 'DR$%'
     AND  dt.table_name NOT LIKE 'BIN$%'

  UNION ALL
  -- Parent AQ tables
  SELECT /*+ rule */	dt.owner,
		dqt.queue_table table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		'table' parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM 	dba_queue_tables dqt,
		dba_tables dt
   WHERE  dt.owner = p_app
     AND  dt.owner = dqt.owner
     AND  dqt.owner = p_app
     AND  dt.table_name = dqt.queue_table
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Child AQ tables not IOTs
  SELECT /*+ rule */ dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		SUBSTR(dt.table_name, 5, LENGTH(dt.table_name)-6) parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner = p_app
     AND  dt.table_name LIKE 'AQ$%'
     AND  dt.iot_type IS NULL
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Domain Indexes tables not IOTs
  SELECT /*+ rule */ dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		SUBSTR(dt.table_name, 4, LENGTH(dt.table_name)-5) parent,
		'TABLE' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner = p_app
     AND  dt.table_name LIKE 'DR$%'
     AND  dt.iot_type IS NULL
     AND  dt.table_name NOT LIKE 'BIN$%'
     AND  NVL(dt.temporary, 'N') = 'N';

   cursor get_tab_partition(p_table_name varchar2) is
   select /*+ ALL_ROWS */ partition_name, tablespace_name
     from dba_tab_partitions
    where table_owner = p_app
      and table_name = p_table_name;

   cursor get_lob_partition(p_table_name varchar2, p_lob_name varchar2) is
   select /*+ ALL_ROWS */ lob_partition_name, lob_indpart_name, tablespace_name
     from dba_lob_partitions
    where table_owner = p_app
      and table_name = p_table_name
      and lob_name = p_lob_name;

 BEGIN

   DELETE FROM fnd_ts_sizing
    WHERE owner = p_app;
   COMMIT;

   OPEN tab_csr;
   LOOP
     FETCH tab_csr INTO cur_rec;
     EXIT WHEN tab_csr%NOTFOUND;

     cur_rec.object_class := trim(cur_rec.object_class);
     cur_rec.parent := trim(cur_rec.parent);
     cur_rec.object_type := trim(cur_rec.object_type);
     cur_rec.subobject_type := trim(cur_rec.subobject_type);
     cur_rec.classified  := trim(cur_rec.classified);
     cur_rec.partitioned := trim(cur_rec.partitioned);

     if (cur_rec.partitioned = 'NO') then
       -- non-partitioned tables and LOBS will be sized here.
       ins_fnd_ts_sizing (
			cur_rec,
                        p_uni_extent,
                        p_allocation_type,
      			p_creation_date);
     elsif (cur_rec.object_type = 'TABLE') then
         cur_rec.object_type := 'TABLE PARTITION';
  	 FOR tab_part_rec IN get_tab_partition(cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := tab_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        P_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        tab_part_rec.partition_name);
	 END LOOP;
     elsif (cur_rec.object_type = 'LOB') then
         cur_rec.object_type := 'LOB PARTITION';
  	 FOR lob_part_rec IN get_lob_partition(cur_rec.parent, cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := lob_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        lob_part_rec.lob_partition_name);
/*
           cur_rec.object_type := 'INDEX PARTITION';
           cur_rec.table_name := REPLACE(cur_rec.table_name, 'LOB', 'IL');
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        lob_part_rec.lob_indpart_name);
*/
	 END LOOP;
     end if;
     COMMIT;
   END LOOP;
   CLOSE tab_csr;
 END gen_tab_sizing;


 PROCEDURE gen_ind_sizing (p_app IN VARCHAR2,
                           p_uni_extent IN NUMBER,
                           p_allocation_type IN VARCHAR2,
                           p_creation_date IN DATE)
 IS
  cur_rec            rec_type;

  cursor ind_csr is
  -- Indexes on Classified Tables
  select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		decode(nvl(o.custom_tablespace_type, o.tablespace_type), fnd_ts_mig_util.l_def_tab_tsp, fnd_ts_mig_util.l_def_ind_tsp, o.tablespace_type) object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'YES'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	fnd_object_tablespaces o,
         	dba_indexes i
   where 	i.table_owner = p_app
     and	o.oracle_username = i.table_owner
     and 	o.object_name = i.table_name
     and	i.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     and	NVL(i.temporary, 'N') = 'N'
     and        i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOB Indexes on Classified Tables
  select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		decode(nvl(o.custom_tablespace_type, o.tablespace_type), fnd_ts_mig_util.l_def_tab_tsp, fnd_ts_mig_util.l_def_tab_tsp, o.tablespace_type) object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'YES'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	fnd_object_tablespaces o,
         	dba_indexes i
   where 	i.table_owner = p_app
     and	o.oracle_username = i.table_owner
     and 	o.object_name = i.table_name
     and	i.index_type  ='LOB'
     and	NVL(i.temporary, 'N') = 'N'
     and        i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes for Unclassified Tables w/o lob
  -- (no IOTs, MVs, MV Logs, AQs, Domain Indexes)
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_unclass_ind_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE 	i.table_owner = p_app
     AND 	i.table_owner = dt.owner
     AND 	i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = p_app
             and o.object_name = i.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = i.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs s
          WHERE s.log_owner = p_app
            and s.log_table = i.table_name)
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = p_app
             and dqt.queue_table = i.table_name)
     AND  i.index_type  not in ('DOMAIN', 'IOT - TOP', 'CLUSTER','LOB')
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  NVL(i.temporary, 'N') = 'N'
     and        i.index_name NOT LIKE 'BIN$%'
UNION ALL
  -- Indexes for Unclassified Tables with lob
  -- (no IOTs, MVs, MV Logs, AQs, Domain Indexes)
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE 	i.table_owner = p_app
     AND 	i.table_owner = dt.owner
     AND 	i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = p_app
             and o.object_name = i.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = i.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs s
          WHERE s.log_owner = p_app
            and s.log_table = i.table_name)
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = p_app
             and dqt.queue_table = i.table_name)
     AND  i.index_type = 'LOB'
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'

  UNION ALL
  -- IOT Tables (since IOT go to TRANSACTION data)
  -- Minus Child AQ IOTs
  -- Minus Domain Indexes IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		d.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner = p_app
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name NOT LIKE 'AQ$%'
     AND  d.table_name NOT LIKE 'DR$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes on IOTs
  -- Minus Indexes on AQ IOTs and Domain Index IOTs
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE  i.table_owner = p_app
     AND  dt.owner = i.table_owner
     AND  dt.table_name = i.table_name
     AND  NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  NOT  EXISTS
         (SELECT table_name
            FROM dba_snapshots s
           WHERE s.owner = p_app
             AND s.table_name = i.table_name)
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  i.index_type  NOT IN ('DOMAIN', 'IOT - TOP', 'CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
UNION ALL
  -- Indexes on IOTs witj lob
   -- Minus Indexes on AQ IOTs and Domain Index IOTs
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE  i.table_owner = p_app
     AND  dt.owner = i.table_owner
     AND  dt.table_name = i.table_name
     AND  NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  NOT  EXISTS
         (SELECT table_name
            FROM dba_snapshots s
           WHERE s.owner = p_app
             AND s.table_name = i.table_name)
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  i.index_type  ='LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes on MVs
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   where 	i.table_owner = p_app
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = i.table_name)
     AND  i.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
UNION ALL
  -- Indexes on MVs
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   where 	i.table_owner = p_app
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = p_app
            and s.table_name = i.table_name)
     AND  i.index_type  ='LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'

  UNION ALL
  -- Indexes on MV Logs
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   where 	i.table_owner = p_app
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshot_logs s
          WHERE s.log_owner = p_app
            and s.log_table = i.table_name)
     AND  I.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
UNION ALL
  -- Indexes on MV Logs with lobs
    select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   where 	i.table_owner = p_app
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshot_logs s
          WHERE s.log_owner = p_app
            and s.log_table = i.table_name)
     AND  I.index_type  ='LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Child AQ IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
         -- fnd_ts_mig_util.l_def_tab_tsp object_class,
		SUBSTR(d.table_name, 5, LENGTH(d.table_name)-6) parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner      = p_app
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name LIKE 'AQ$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.index_name NOT LIKE 'BIN$%'
  UNION ALL
   -- Indexes on Parent and Child AQ tables (including indexes on child IOTs)
   SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
     FROM 	dba_indexes di
    WHERE	di.table_owner = p_app
      AND (EXISTS
            (SELECT queue_table
               FROM dba_queue_tables dqt
              WHERE dqt.owner = p_app
                AND dqt.queue_table = di.table_name)
            OR  di.table_name LIKE 'AQ$%')
      AND	di.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
      AND  	NVL(di.temporary, 'N') = 'N'
      AND       di.index_name NOT LIKE 'BIN$%'
 UNION ALL
   -- Indexes on Parent and Child AQ tables (including indexes on child IOTs with lob)
   SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
     FROM 	dba_indexes di
    WHERE	di.table_owner = p_app
      AND (EXISTS
            (SELECT queue_table
               FROM dba_queue_tables dqt
              WHERE dqt.owner = p_app
                AND dqt.queue_table = di.table_name)
            OR  di.table_name LIKE 'AQ$%')
      AND	di.index_type  ='LOB'
      AND  	NVL(di.temporary, 'N') = 'N'
      AND       di.index_name NOT LIKE 'BIN$%'

  UNION ALL
  -- Child Domain Indexes IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		SUBSTR(d.table_name, 4, LENGTH(d.table_name)-5) parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner      = p_app
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name LIKE 'DR$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.index_name NOT LIKE 'BIN$%'
  UNION ALL
   -- Indexes on Child Domain Indexes tables including IOTs
   SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
     FROM 	dba_indexes di
    WHERE	di.table_owner = p_app
      AND	di.table_name LIKE 'DR$%'
      AND	di.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
      AND  	NVL(di.temporary, 'N') = 'N'
      AND       di.index_name NOT LIKE 'BIN$%'

UNION ALL
   -- Indexes on Child Domain Indexes tables including IOTs with lob
   SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
     FROM 	dba_indexes di
    WHERE	di.table_owner = p_app
      AND	di.table_name LIKE 'DR$%'
      AND	di.index_type  ='LOB'
      AND       di.index_name NOT LIKE 'BIN$%'
      AND  	NVL(di.temporary, 'N') = 'N';

   cursor get_ind_partition(p_index_name varchar2) is
   select /*+ ALL_ROWS */ partition_name, tablespace_name
     from dba_ind_partitions
    where index_name = p_index_name
      and index_owner=p_app;
 BEGIN
/*
   DELETE FROM fnd_ts_sizing
    WHERE owner = p_app
      AND object_type IN ('INDEX', 'INDEX PARTITION', 'LOBINDEX');
   COMMIT;
*/

   OPEN ind_csr;
   LOOP
     FETCH ind_csr INTO cur_rec;
     EXIT WHEN ind_csr%NOTFOUND;

     cur_rec.object_class := trim(cur_rec.object_class);
     cur_rec.parent := trim(cur_rec.parent);
     cur_rec.object_type := trim(cur_rec.object_type);
     cur_rec.subobject_type := trim(cur_rec.subobject_type);
     cur_rec.classified  := trim(cur_rec.classified);
     cur_rec.partitioned := trim(cur_rec.partitioned);

     if (cur_rec.partitioned = 'NO') then
       -- non-partitioned indexes will be sized here.
       ins_fnd_ts_sizing (
			cur_rec,
                        p_uni_extent,
                        p_allocation_type,
      			p_creation_date);
     elsif (cur_rec.object_type = 'INDEX') then
         cur_rec.object_type := 'INDEX PARTITION';
  	 FOR ind_part_rec IN get_ind_partition(cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := ind_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        ind_part_rec.partition_name);
	 END LOOP;
     end if;
     COMMIT;
   END LOOP;
   CLOSE ind_csr;
 END gen_ind_sizing;

 PROCEDURE gen_all_tab_sizing ( p_uni_extent IN NUMBER,
                                p_allocation_type IN VARCHAR2,
                                p_creation_date IN DATE)
 IS
  cur_rec            rec_type;

  CURSOR tab_csr IS
  -- CLASSIFIED TABLES (Normal) minus IOT Tables
  -- MINUS AQ TABLES
  -- MINUS IOT OVERFLOW TABLES
  SELECT /*+ rule */    dt.owner,
                dt.table_name,
                dt.tablespace_name,
                nvl(fot.custom_tablespace_type, fot.tablespace_type) object_class,
                'table' parent,
                'TABLE' object_type,
                'TABLE' subobject_type,
                'YES'   classified,
                NVL(dt.partitioned,'NO') partitioned
    FROM        fnd_object_tablespaces fot,
                dba_tables dt
   WHERE dt.owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND dt.owner = fot.oracle_username
     AND fot.object_name = dt.table_name
     AND fot.object_type = 'TABLE'
     AND nvl(dt.iot_type,'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND dt.table_name NOT LIKE 'BIN$%'
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = dt.owner
                         and det.table_name = dt.table_name)
  UNION ALL
  -- UNCLASSIFIED
  -- TABLES (Normal) minus IOT Tables, MV, MV logs
  -- MINUS AQ TABLES and Domain Indexes tables
  -- MINUS IOT and IOT OVERFLOW TABLES
  SELECT /*+ rule */	dt.owner,
		dt.table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		'table' parent,
		'TABLE' object_type,
		'TABLE' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM 	dba_tables dt
   WHERE 	dt.owner IN (select oracle_username
                               from fnd_oracle_userid
                              where read_only_flag IN ('E','A','U','K','M'))
     AND NOT EXISTS
        (SELECT object_name
           FROM fnd_object_tablespaces o
          WHERE o.oracle_username = dt.owner
            AND o.object_name = dt.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = dt.owner
            AND s.table_name = dt.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs l
          WHERE l.log_owner = dt.owner
            AND l.log_table = dt.table_name)
     AND  NVL(dt.iot_type,'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = dt.owner
             AND dqt.queue_table = dt.table_name)
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = dt.owner
                         and det.table_name = dt.table_name)
     AND  dt.table_name NOT LIKE 'AQ$%'
     AND  dt.table_name NOT LIKE 'DR$%'
     AND  dt.table_name NOT LIKE 'RUPD$%'
     AND  dt.table_name NOT LIKE 'MDRT%$'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- MVIEW LOGS
  SELECT /*+ rule */ distinct dsl.log_owner,
		dsl.log_table table_name,
		dt.tablespace_name,
                fnd_ts_mig_util.l_def_mv_tsp object_class,
		dt.table_name parent,
		'TABLE' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM 	dba_tables dt,
         	dba_snapshot_logs dsl
   WHERE  dsl.log_owner IN (select oracle_username
                              from fnd_oracle_userid
                             where read_only_flag IN ('E','A','U','K','M'))
     AND  dsl.log_owner = dt.owner
     AND  dsl.log_table = dt.table_name
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- MVIEWS
  SELECT /*+ rule */	ds.owner,
		ds.name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		dt.table_name parent,
		'TABLE' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM 	dba_snapshots ds,
       		dba_tables dt
   WHERE  ds.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  ds.owner = dt.owner
     AND  dt.table_name = ds.table_name
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW
  -- MINUS AQ TABLES
  -- MINUS IOT START WITH 'DR$%' (Domain Index Tables IOT OVERFLOW)
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'AQ$%'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'DR$%'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'RUPD$%'
     AND  NVL(dt.iot_name, 'ZZZ') NOT LIKE 'MDRT%$'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW FOR AQ TABLES
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
         --fnd_ts_mig_util.l_def_tab_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  NVL(dt.iot_name, 'ZZZ') LIKE 'AQ$%'
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT OVERFLOW for Domain Indexes IOTs
  SELECT /*+ rule */	dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		dt.iot_name parent,
		'TABLE' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  NVL(dt.iot_type, 'ZZZ') = 'IOT_OVERFLOW'
     AND  (NVL(dt.iot_name, 'ZZZ') LIKE 'DR$%'
          OR NVL(dt.iot_name, 'ZZZ') LIKE 'MDRT%$')
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in Classified Objects
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
		nvl(o.custom_tablespace_type, o.tablespace_type) object_class,
		dl.table_name parent,
		'LOB' object_type,
		'TABLE' subobject_type,
		'YES' classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  fnd_object_tablespaces o,
          dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dt.owner = o.oracle_username
     AND  o.object_name = dl.table_name
     AND  o.object_type = 'TABLE'
     AND  dl.owner = dt.owner
     AND  dl.table_name = dt.table_name
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = dt.owner
                         and det.table_name = dt.table_name)
  UNION ALL
  -- LOBS in Unclassified Tables
  -- (no IOT, MVs, AQs, Domain Indexes)
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		dl.table_name parent,
		'LOB' object_type,
		'TABLE' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dl.owner = dt.owner
     AND  dl.table_name = dt.table_name
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = dt.owner
             and o.object_name = dt.table_name)
     AND NOT  EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = dt.owner
            and s.table_name = dt.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs l
          where l.log_owner = dt.owner
            and l.log_table = dt.table_name)
     and  dt.iot_type IS NULL
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = dt.owner
             and dqt.queue_table = dt.table_name)
     AND NOT EXISTS
         (select det.table_name
            from dba_external_tables det
           where det.owner = dt.owner
             and det.table_name = dt.table_name)
     AND  dt.table_name NOT LIKE 'AQ$%'
     AND  dt.table_name NOT LIKE 'DR$%'
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in IOTs
  -- Minus AQ and Domain Index
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		dl.table_name parent,
		'LOB' object_type,
		'IOT' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dl.owner = dt.owner
     AND  dl.table_name = dt.table_name
     AND  NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = dt.owner
             and dqt.queue_table = dt.table_name)
     AND NOT EXISTS ( select det.table_name
                        from dba_external_tables det
                       where det.owner = dt.owner
                         and det.table_name = dt.table_name)
     AND  dt.table_name NOT LIKE 'AQ$%'
     AND  dt.table_name NOT LIKE 'DR$%'
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBs in MVs
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		dl.table_name parent,
		'LOB' object_type,
		'MVIEW' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dl.owner = dt.owner
     AND  dl.table_name = dt.table_name
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = dt.owner
            and s.table_name = dt.table_name)
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in AQs
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
 		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		dl.table_name parent,
		'LOB' object_type,
		'AQ' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dl.owner = dt.owner
     AND  dl.table_name = dt.table_name
     AND (EXISTS
           (SELECT queue_table
              FROM dba_queue_tables dqt
             WHERE dqt.owner = dt.owner
               and dqt.queue_table = dt.table_name)
           OR  dt.table_name LIKE 'AQ$%')
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- LOBS in Domain Index Objects
  SELECT /*+ rule */	dl.owner,
		dl.segment_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		dl.table_name parent,
		'LOB' object_type,
		'DOMAIN' subobject_type,
		'NO'  classified,
		nvl(dt.partitioned,'NO') partitioned
    from  dba_lobs dl,
          dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     and  dl.owner = dt.owner
     and  dl.table_name = dt.table_name
     AND  dt.table_name LIKE 'DR$%'
     and  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Parent AQ tables
  SELECT /*+ rule */	dt.owner,
		dqt.queue_table table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		'table' parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM 	dba_queue_tables dqt,
		dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dt.owner = dqt.owner
     AND  dt.table_name = dqt.queue_table
     AND  NVL(dt.temporary, 'N') = 'N'
     AND  dt.table_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Child AQ tables not IOTs
  SELECT /*+ rule */ dt.owner,
		dt.table_name table_name,
		dt.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_tab_tsp object_class,
		SUBSTR(dt.table_name, 5, LENGTH(dt.table_name)-6) parent,
		'TABLE' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		NVL(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dt.table_name LIKE 'AQ$%'
     AND  dt.iot_type IS NULL
     AND  NVL(dt.temporary, 'N') = 'N'
  UNION ALL
  -- Domain Indexes tables not IOTs
  SELECT /*+ rule */ dt.owner owner,
		dt.table_name table_name,
		dt.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		SUBSTR(dt.table_name, 4, LENGTH(dt.table_name)-5) parent,
		'TABLE' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(dt.partitioned,'NO') partitioned
    FROM  dba_tables dt
   WHERE  dt.owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  dt.table_name LIKE 'DR$%'
     AND  dt.iot_type IS NULL
     AND  NVL(dt.temporary, 'N') = 'N';

   CURSOR get_tab_partition(p_owner VARCHAR2, p_table_name VARCHAR2) IS
   select /*+ ALL_ROWS */ partition_name, tablespace_name
     from dba_tab_partitions
    where table_name = p_table_name
      and table_owner = p_owner;

   cursor get_lob_partition(p_owner varchar2, p_table_name varchar2, p_lob_name varchar2) is
   select /*+ ALL_ROWS */ lob_partition_name, lob_indpart_name, tablespace_name
     from dba_lob_partitions
    where table_owner = p_owner
      and table_name = p_table_name
      and lob_name = p_lob_name;

 BEGIN

   DELETE FROM fnd_ts_sizing;
   COMMIT;

   OPEN tab_csr;
   LOOP
     FETCH tab_csr INTO cur_rec;
     EXIT WHEN tab_csr%NOTFOUND;

     cur_rec.object_class := trim(cur_rec.object_class);
     cur_rec.parent := trim(cur_rec.parent);
     cur_rec.object_type := trim(cur_rec.object_type);
     cur_rec.subobject_type := trim(cur_rec.subobject_type);
     cur_rec.classified  := trim(cur_rec.classified);
     cur_rec.partitioned := trim(cur_rec.partitioned);

     if (cur_rec.partitioned = 'NO') then
       -- non-partitioned tables and LOBS will be sized here.
       ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date);
     elsif (cur_rec.object_type = 'TABLE') then
         cur_rec.object_type := 'TABLE PARTITION';
         FOR tab_part_rec IN get_tab_partition (cur_rec.owner, cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := tab_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        tab_part_rec.partition_name);
         END LOOP;
     elsif (cur_rec.object_type = 'LOB') then
         cur_rec.object_type := 'LOB PARTITION';
  	 FOR lob_part_rec IN get_lob_partition(cur_rec.owner, cur_rec.parent, cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := lob_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        P_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        lob_part_rec.lob_partition_name);
/*
           cur_rec.object_type := 'INDEX PARTITION';
           cur_rec.table_name := REPLACE(cur_rec.table_name, 'LOB', 'IL');
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        lob_part_rec.lob_indpart_name);
*/
	 END LOOP;
     end if;
     COMMIT;
   END LOOP;
   CLOSE tab_csr;
 END gen_all_tab_sizing;

 PROCEDURE gen_all_ind_sizing (p_uni_extent IN NUMBER,
                               p_allocation_type IN VARCHAR2,
                               p_creation_date IN DATE)
 IS
  cur_rec            rec_type;

  cursor ind_csr is
  -- Indexes on Classified Tables
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		decode(nvl(o.custom_tablespace_type, o.tablespace_type), fnd_ts_mig_util.l_def_tab_tsp, fnd_ts_mig_util.l_def_ind_tsp, o.tablespace_type) object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'YES'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM fnd_object_tablespaces o,
         dba_indexes i
   WHERE i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND o.oracle_username = i.table_owner
     AND o.object_name = i.table_name
     AND o.object_type = 'TABLE'
     AND i.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND NVL(i.temporary, 'N') = 'N'
     AND i.index_name NOT LIKE 'BIN$%'
  UNION ALL
-- Indexes on Classified Tables with lob
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		decode(nvl(o.custom_tablespace_type, o.tablespace_type), fnd_ts_mig_util.l_def_tab_tsp, fnd_ts_mig_util.l_def_tab_tsp, o.tablespace_type) object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'YES'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM fnd_object_tablespaces o,
         dba_indexes i
   WHERE i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND o.oracle_username = i.table_owner
     AND o.object_name = i.table_name
     AND o.object_type = 'TABLE'
     AND i.index_type  ='LOB'
     AND NVL(i.temporary, 'N') = 'N'
     AND i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes for Unclassified Tables
  -- (no IOTs, MVs, MV Logs, AQs, Domain Indexes)
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_unclass_ind_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND i.table_owner = dt.owner
     AND i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = i.table_owner
             and o.object_name = i.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs s
          WHERE s.log_owner = i.table_owner
            and s.log_table = i.table_name)
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = i.table_owner
             and dqt.queue_table = i.table_name)
     AND  i.index_type  not in ('DOMAIN', 'IOT - TOP', 'CLUSTER','LOB')
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  NVL(i.temporary, 'N') = 'N'
     AND i.index_name NOT LIKE 'BIN$%'

UNION ALL
  -- Indexes for Unclassified Tables with lob
  -- (no IOTs, MVs, MV Logs, AQs, Domain Indexes)
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_unclass_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'INDEX' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND i.table_owner = dt.owner
     AND i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') NOT IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT EXISTS
         (SELECT object_name
            FROM fnd_object_tablespaces o
           WHERE o.oracle_username = i.table_owner
             and o.object_name = i.table_name)
     AND NOT EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND NOT EXISTS
        (SELECT log_table
           FROM dba_snapshot_logs s
          WHERE s.log_owner = i.table_owner
            and s.log_table = i.table_name)
     AND NOT EXISTS
         (SELECT queue_table
            FROM dba_queue_tables dqt
           WHERE dqt.owner = i.table_owner
             and dqt.queue_table = i.table_name)
     AND  i.index_type  ='LOB'
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  NVL(i.temporary, 'N') = 'N'
     AND i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- IOT Tables (since IOT go to TRANSACTION data)
  -- Minus Child AQ IOTs
  -- Minus Domain Indexes IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		d.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name NOT LIKE 'AQ$%'
     AND  d.table_name NOT LIKE 'DR$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes on IOTs
  -- Minus Indexes on AQ IOTs and Domain Index IOTs
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND i.table_owner = dt.owner
     AND i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT  EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  i.index_type  NOT IN ('DOMAIN', 'IOT - TOP', 'CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'

UNION ALL
  -- Indexes on IOTs witj lob
   -- Minus Indexes on AQ IOTs and Domain Index IOTs
  SELECT /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'IOT' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    FROM 	dba_indexes i,
                dba_tables dt
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND i.table_owner = dt.owner
     AND i.table_name = dt.table_name
     AND NVL(dt.iot_type, 'ZZZ') IN ('IOT', 'IOT_OVERFLOW')
     AND NVL(dt.temporary, 'N') = 'N'
     AND NOT  EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND  i.table_name NOT LIKE 'AQ$%'
     AND  i.table_name NOT LIKE 'DR$%'
     AND  i.index_type  ='LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Indexes on MVs
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND  i.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
UNION ALL
  -- Indexes on MVs with lob
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MVIEW' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshots s
          WHERE s.owner = i.table_owner
            and s.table_name = i.table_name)
     AND  i.index_type  = 'LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'

  UNION ALL
  -- Indexes on MV Logs
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshot_logs s
          WHERE s.log_owner = i.table_owner
            and s.log_table = i.table_name)
     AND  i.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'

  UNION ALL
  -- Indexes on MV Logs with lob
   select /*+ rule */	i.owner,
		i.index_name table_name,
		i.tablespace_name,
		fnd_ts_mig_util.l_def_mv_tsp object_class,
		i.table_name parent,
		'INDEX' object_type,
		'MV_LOG' subobject_type,
		'NO'   classified,
		nvl(i.partitioned,'NO') partitioned
    from 	dba_indexes i
   WHERE  i.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND EXISTS
        (SELECT table_name
           FROM dba_snapshot_logs s
          WHERE s.log_owner = i.table_owner
            and s.log_table = i.table_name)
     AND  i.index_type  ='LOB'
     AND  NVL(i.temporary, 'N') = 'N'
     AND  i.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Child AQ IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
        --	fnd_ts_mig_util.l_def_tab_tsp object_class,
		SUBSTR(d.table_name, 5, LENGTH(d.table_name)-6) parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name LIKE 'AQ$%'
     AND  NVL(d.temporary, 'N') = 'N'
  UNION ALL
   -- Indexes on Parent and Child AQ tables (including indexes on child IOTs)
  SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
    FROM 	dba_indexes di
   WHERE  di.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
      AND (EXISTS
            (SELECT queue_table
               FROM dba_queue_tables dqt
              WHERE dqt.owner = di.table_owner
                AND dqt.queue_table = di.table_name)
            OR  di.table_name LIKE 'AQ$%')
      AND	di.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
      AND  	NVL(di.temporary, 'N') = 'N'
      AND  di.index_name NOT LIKE 'BIN$%'

UNION ALL
   -- Indexes on Parent and Child AQ tables (including indexes on child IOTs with lob)
  SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
            fnd_ts_mig_util.l_aq_tab_tsp object_class,
		--fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'AQ' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
    FROM 	dba_indexes di
   WHERE  di.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
      AND (EXISTS
            (SELECT queue_table
               FROM dba_queue_tables dqt
              WHERE dqt.owner = di.table_owner
                AND dqt.queue_table = di.table_name)
            OR  di.table_name LIKE 'AQ$%')
      AND	di.index_type  ='LOB'
      AND  	NVL(di.temporary, 'N') = 'N'
      AND  di.index_name NOT LIKE 'BIN$%'
  UNION ALL
  -- Child Domain Indexes IOTs
  SELECT /*+ rule */	d.owner,
		d.index_name table_name,
		d.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		SUBSTR(d.table_name, 4, LENGTH(d.table_name)-5) parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(d.partitioned,'NO') partitioned
    FROM 	dba_indexes d
   WHERE  d.table_owner IN (select oracle_username
                        from fnd_oracle_userid
                       where read_only_flag IN ('E','A','U','K','M'))
     AND  d.index_type = 'IOT - TOP'
     AND  d.table_name LIKE 'DR$%'
     AND  NVL(d.temporary, 'N') = 'N'
     AND  d.index_name NOT LIKE 'BIN$%'
  UNION ALL
   -- Indexes on Child Domain Indexes tables including IOTs
  SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
		fnd_ts_mig_util.l_def_ind_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
    FROM 	dba_indexes di
   WHERE  di.table_owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  di.table_name LIKE 'DR$%'
     AND  di.index_type  not in ('DOMAIN','IOT - TOP','CLUSTER','LOB')
     AND  NVL(di.temporary, 'N') = 'N'
     AND  di.index_name NOT LIKE 'BIN$%'
UNION ALL
   -- Indexes on Child Domain Indexes tables including IOTs wit lob
  SELECT /*+ rule */ di.owner,
		di.index_name table_name,
		di.tablespace_name,
		fnd_ts_mig_util.l_def_tab_tsp object_class,
		di.table_name parent,
		'INDEX' object_type,
		'DOMAIN' subobject_type,
		'NO'   classified,
		nvl(di.partitioned,'NO') partitioned
    FROM 	dba_indexes di
   WHERE  di.table_owner IN (select oracle_username
                         from fnd_oracle_userid
                        where read_only_flag IN ('E','A','U','K','M'))
     AND  di.table_name LIKE 'DR$%'
     AND  di.index_type  ='LOB'
     AND  NVL(di.temporary, 'N') = 'N';

   cursor get_ind_partition(p_owner VARCHAR2, p_index_name VARCHAR2) is
   select /*+ ALL_ROWS */ partition_name, tablespace_name
     from dba_ind_partitions
    where index_owner = p_owner
      and index_name = p_index_name;
 BEGIN
/*
   DELETE FROM fnd_ts_sizing
    WHERE object_type IN ('INDEX', 'INDEX PARTITION', 'LOBINDEX');
   COMMIT;
*/

   OPEN ind_csr;
   LOOP
     FETCH ind_csr INTO cur_rec;
     EXIT WHEN ind_csr%NOTFOUND;

     cur_rec.object_class := trim(cur_rec.object_class);
     cur_rec.parent := trim(cur_rec.parent);
     cur_rec.object_type := trim(cur_rec.object_type);
     cur_rec.subobject_type := trim(cur_rec.subobject_type);
     cur_rec.classified  := trim(cur_rec.classified);
     cur_rec.partitioned := trim(cur_rec.partitioned);

     if (cur_rec.partitioned = 'NO') then
       -- non-partitioned indexes will be sized here.
       ins_fnd_ts_sizing (
			cur_rec,
                        p_uni_extent,
                        p_allocation_type,
      			p_creation_date);
     elsif (cur_rec.object_type = 'INDEX') then
         cur_rec.object_type := 'INDEX PARTITION';
  	 FOR ind_part_rec IN get_ind_partition(cur_rec.owner, cur_rec.table_name)
         LOOP
           cur_rec.tablespace_name := ind_part_rec.tablespace_name;
           ins_fnd_ts_sizing (
                        cur_rec,
                        p_uni_extent,
                        p_allocation_type,
                        p_creation_date,
                        ind_part_rec.partition_name);
	 END LOOP;
     end if;
     COMMIT;
   END LOOP;
   CLOSE ind_csr;
 END gen_all_ind_sizing;

END fnd_ts_size;

/
