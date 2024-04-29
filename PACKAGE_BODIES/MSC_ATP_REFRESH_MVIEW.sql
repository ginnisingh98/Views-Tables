--------------------------------------------------------
--  DDL for Package Body MSC_ATP_REFRESH_MVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_REFRESH_MVIEW" AS
/* $Header: MSCATMVB.pls 120.2 2007/12/12 10:20:47 sbnaik ship $ */

-- rajjain 12/20/2002
PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

   PROCEDURE REFRESH_MVIEW(
	ERRBUF	        OUT 	NoCopy VARCHAR2,
        RETCODE		OUT	NoCopy NUMBER)
   IS
	TYPE char40_arr IS TABLE OF varchar2(40);
	TYPE number_arr IS TABLE OF number;

	i			NUMBER := 1;
	j			NUMBER := 1;
	l_applsys_schema 	varchar2(10);
        l_msc_schema            VARCHAR2(30);
	l_retval 		BOOLEAN;
	dummy1  		varchar2(10);
	dummy2 			varchar2(10);
	sql_stmt1  		varchar2(30000);
	sql_stmt2  		varchar2(30000);
	l_part_name  		char40_arr;
	l_cur_table  		char40_arr;
	l_temp_table  		char40_arr;
	l_tbspace  		char40_arr;
	l_min_instance_id	NUMBER := 0;
	l_max_instance_id	NUMBER := 31;
	--l_sub_part		number_arr;

        -- bug 2383867 : krajan
        -- stores value of MSC_CAP_ALLOCATION profile option
        l_msc_cap_allocation    varchar2(1);
        -- rajjain 12/20/2002
        l_spid                          VARCHAR2(12);
        --5053818
        l_item_hier_init_extent   number;
        l_item_hier_next_extent   number;
        l_item_hier_pct_inc       number;
        l_item_hier_indx_init_extent number;
        l_item_hier_indx_nxt_extent  number;
        l_item_hier_indx_pct_inc     number;

        l_res_hier_init_extent   number;
        l_res_hier_next_extent   number;
        l_res_hier_pct_inc       number;
        l_res_hier_indx_init_extent number;
        l_res_hier_indx_nxt_extent  number;
        l_res_hier_indx_pct_inc     number;

   BEGIN
      -- Bug 3304390 Disable Trace
      -- Deleted related code

      msc_util.msc_log('Begin REFRESH_MVIEW');
      l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);

      SELECT      a.oracle_username
      INTO        l_msc_schema
      FROM        FND_ORACLE_USERID a,
                  FND_PRODUCT_INSTALLATIONS b
      WHERE       a.oracle_id = b.oracle_id
      AND         b.application_id = 724;


      -- bug 2383867 : krajan
      l_msc_cap_allocation := NVL(FND_PROFILE.VALUE('MSC_CAP_ALLOCATION'), 'Y');
      msc_util.msc_log('Profile Option value' || l_msc_cap_allocation);

      msc_util.msc_log('Before getting partitions name');
      IF (l_msc_cap_allocation = 'Y') THEN

                msc_util.msc_log('AATP Profile Option Set. Getting everything.');
                SELECT	    table_name, partition_name, partition_name || '_TEMP',
		            --subpartition_count,
		            tablespace_name
                BULK COLLECT
                INTO	    l_cur_table, l_part_name, l_temp_table,
		            --l_sub_part,
		            l_tbspace
                --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                --FROM	    dba_tab_partitions
                FROM	    all_tab_partitions
                WHERE	    table_owner = l_msc_schema
                AND	    table_name IN ('MSC_ITEM_HIERARCHY_MV', 'MSC_RESOURCE_HIERARCHY_MV')
                ORDER BY    table_name, partition_name;

                -- :In Case of Huge data in MSC_ITEM_HIERARCHY_MV and MSC_RESOURCE_HIERARCHY_MV --5053818
                -- need to set proper Initial extent and next extent value for customers
                msc_util.msc_log('AATP Profile Option Set. Getting everything.');

                BEGIN
                SELECT  nvl(ITEM_HIER_INIT_EXTENT,40),
                        nvl(ITEM_HIER_NEXT_EXTENT,5),
                        nvl(ITEM_HIER_PCT_INCREASE,0),
                        nvl(ITEM_HIER_INDX_INIT_EXTENT,40),
                        nvl(ITEM_HIER_INDX_NEXT_EXTENT,2),
                        nvl(ITEM_HIER_INDX_PCT_INCREASE,0),
                        nvl(RES_HIER_INIT_EXTENT,40),
                        nvl(RES_HIER_NEXT_EXTENT,5),
                        nvl(RES_HIER_PCT_INCREASE,0),
                        nvl(RES_HIER_INDX_INIT_EXTENT,40),
                        nvl(RES_HIER_INDX_NEXT_EXTENT,2),
                        nvl(RES_HIER_INDX_PCT_INCREASE,0)
                INTO l_item_hier_init_extent,l_item_hier_next_extent,l_item_hier_pct_inc,
                     l_item_hier_indx_init_extent,l_item_hier_indx_nxt_extent,l_item_hier_indx_pct_inc,
                     l_res_hier_init_extent,l_res_hier_next_extent,l_res_hier_pct_inc,l_res_hier_indx_init_extent,
                     l_res_hier_indx_nxt_extent,l_res_hier_indx_pct_inc
                from msc_atp_parameters
                WHERE	rownum = 1;
                EXCEPTION
                  WHEN no_data_found THEN
                  l_item_hier_init_extent := 40;
                  l_item_hier_next_extent :=5;
                  l_item_hier_pct_inc :=0;
                  l_item_hier_indx_init_extent :=40;
                  l_item_hier_indx_nxt_extent :=2;
                  l_item_hier_indx_pct_inc :=0;
                  l_res_hier_init_extent := 40;
                  l_res_hier_next_extent :=5;
                  l_res_hier_pct_inc :=0;
                  l_res_hier_indx_init_extent := 40;
                  l_res_hier_indx_nxt_extent :=2;
                  l_res_hier_indx_pct_inc :=0;
                END;

      ELSE
                msc_util.msc_log('AATP Profile Option set to NO. Not getting Resource Hierarchy.');
                SELECT	    table_name, partition_name, partition_name || '_TEMP',
		            --subpartition_count,
		            tablespace_name
                BULK COLLECT
                INTO	    l_cur_table, l_part_name, l_temp_table,
		            --l_sub_part,
		            l_tbspace
                --bug 2495962: Change refrence from dba_xxx to all_xxx tables
                --FROM	    dba_tab_partitions
                FROM	    all_tab_partitions
                WHERE	    table_owner = l_msc_schema
                AND	    table_name = 'MSC_ITEM_HIERARCHY_MV'
                ORDER BY    partition_name;

                -- :In Case of Huge data in MSC_ITEM_HIERARCHY_MV and MSC_RESOURCE_HIERARCHY_MV --5053818
                -- need to set proper Initial extent and next extent value for customers
                msc_util.msc_log('AATP Profile Option Set. Getting everything.');

                BEGIN
                SELECT  NVL(ITEM_HIER_INIT_EXTENT,40),
                        nvl(ITEM_HIER_NEXT_EXTENT,5),
                        nvl(ITEM_HIER_PCT_INCREASE,0),
                        nvl(ITEM_HIER_INDX_INIT_EXTENT,40),
                        nvl(ITEM_HIER_INDX_NEXT_EXTENT,2),
                        nvl(ITEM_HIER_INDX_PCT_INCREASE,0)
                INTO l_item_hier_init_extent,l_item_hier_next_extent,l_item_hier_pct_inc,
                     l_item_hier_indx_init_extent,l_item_hier_indx_nxt_extent,l_item_hier_indx_pct_inc
                from msc_atp_parameters
                WHERE	rownum = 1;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  l_item_hier_init_extent := 40;
                  l_item_hier_next_extent :=5;
                  l_item_hier_pct_inc :=0;
                  l_item_hier_indx_init_extent :=40;
                  l_item_hier_indx_nxt_extent :=2;
                  l_item_hier_indx_pct_inc :=0;
                END;

      END IF;
      -- End bug 2383867 changes : krajan

      i := l_part_name.FIRST;

      msc_util.msc_log('Before Create Temp Table Loop');
      WHILE i IS NOT NULL LOOP

       IF i > 1 THEN
	  IF l_cur_table(i) <> l_cur_table(i-1) THEN
	     j := 2;
	     l_min_instance_id := 0;
	     l_max_instance_id := 31;
          END IF;
       END IF;

	-- Bug 1852008, modified materialized view definition to remove subpartitions
	-- Also, modified INITIAL extent sizes for MV and indexes to be 40K instead of 2M
	-- and NEXT for MV to be 5M and for indexes to be 2M.
	-- This would reduce the space needed to create these MV.
	--
       IF j = 1 THEN
       --5053818
	sql_stmt1 := 'create table ' || l_temp_table(i) ||
	' PCTFREE 0 STORAGE(INITIAL '||l_item_hier_init_extent||'K NEXT '||l_item_hier_next_extent||'M PCTINCREASE '||l_item_hier_pct_inc||')' ||
	' TABLESPACE ' || l_tbspace(i) ||
--' NOLOGGING' ||
	--' PARTITION BY HASH (INVENTORY_ITEM_ID) PARTITIONS ' || to_char(l_sub_part(i))||
	' AS ' ||
	'SELECT mi.inventory_item_id INVENTORY_ITEM_ID,
		mi.organization_id ORGANIZATION_ID,
		mi.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
		ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_alloc_rule_time_phases martp,
		msc_system_items mi,
		msc_allocation_assignments maa
	WHERE  	maa.assignment_type = 7
	AND	maa.inventory_item_id = mi.inventory_item_id
	AND     maa.organization_id = mi.organization_id
	AND     maa.sr_instance_id = mi.sr_instance_id
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mi.plan_id = -1
	AND     mi.sr_instance_id >= ' || to_char(l_min_instance_id) ||
	' AND	mi.sr_instance_id <  ' || to_char(l_max_instance_id) ||
	' UNION ALL
	SELECT 	mi.inventory_item_id INVENTORY_ITEM_ID,
		mi.organization_id ORGANIZATION_ID,
		mi.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
		ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_alloc_rule_time_phases martp,
		msc_system_items mi,
		msc_allocation_assignments maa
	WHERE  	maa.assignment_type = 3
	AND	maa.inventory_item_id = mi.inventory_item_id
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mi.plan_id = -1
        AND     mi.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mi.sr_instance_id <  ' || to_char(l_max_instance_id) ||
        ' AND NOT EXISTS (
                SELECT  maa7.inventory_item_id
                FROM    msc_allocation_assignments maa7
                WHERE   maa7.inventory_item_id = mi.inventory_item_id
                AND     maa7.organization_id = mi.organization_id
                AND     maa7.sr_instance_id = mi.sr_instance_id
                AND     maa7.assignment_type = 7 )
	UNION ALL
	SELECT 	mi.inventory_item_id INVENTORY_ITEM_ID,
		mi.organization_id ORGANIZATION_ID,
		mi.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_alloc_rule_time_phases martp,
		msc_allocation_assignments maa,
		msc_system_items mi,
		msc_item_categories mic
	WHERE	maa.assignment_type = 2
	AND	maa.category_set_id = mic.category_set_id
	AND	maa.category_name = mic.category_name
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mic.inventory_item_id = mi.inventory_item_id
	AND	mic.organization_id = mi.organization_id
	AND	mic.sr_instance_id = mi.sr_instance_id
	AND	mi.plan_id = -1
        AND     mi.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mi.sr_instance_id <  ' || to_char(l_max_instance_id) ||
        ' AND NOT EXISTS (
		SELECT	maa1.category_set_id
		FROM	msc_allocation_assignments maa1
		WHERE	maa1.inventory_item_id = mi.inventory_item_id
		AND	maa1.assignment_type = 3)
	AND NOT EXISTS (
                SELECT  maa7.inventory_item_id
                FROM    msc_allocation_assignments maa7
                WHERE   maa7.inventory_item_id = mi.inventory_item_id
                AND     maa7.organization_id = mi.organization_id
                AND     maa7.sr_instance_id = mi.sr_instance_id
                AND     maa7.assignment_type = 7 )
	UNION ALL
	SELECT  mi.inventory_item_id INVENTORY_ITEM_ID,
                mi.organization_id ORGANIZATION_ID,
                mi.sr_instance_id SR_INSTANCE_ID,
                ma.demand_class DEMAND_CLASS,
                maa.allocation_rule_name ALLOCATION_RULE_NAME,
                maa.assignment_type ASSIGNMENT_TYPE,
                ma.allocation_percent ALLOCATION_PERCENT,
                martp.effective_date EFFECTIVE_DATE,
                martp.disable_date DISABLE_DATE,
                ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM    msc_allocations ma,
                msc_alloc_rule_time_phases martp,
                msc_allocation_assignments maa,
                msc_system_items mi
	WHERE   maa.assignment_type = 6
	AND     maa.allocation_rule_name = martp.allocation_rule_name
	AND     martp.time_phase_id =  ma.time_phase_id
	AND     mi.organization_id = maa.organization_id
	AND     mi.sr_instance_id = maa.sr_instance_id
	AND     mi.plan_id = -1
        AND     mi.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mi.sr_instance_id <  ' || to_char(l_max_instance_id) ||
        ' AND NOT EXISTS (
                SELECT  /*+ leading(maa1) */ maa1.inventory_item_id
                FROM    msc_allocation_assignments maa1,
                        msc_item_categories mic
                WHERE   maa1.category_set_id = mic.category_set_id
                AND     maa1.category_name = mic.category_name
                AND     mi.inventory_item_id = mic.inventory_item_id
                AND     mi.organization_id = mic.organization_id
                AND     mi.sr_instance_id = mic.sr_instance_id
                AND     maa1.assignment_type = 2)
	AND NOT EXISTS (
                SELECT  maa2.inventory_item_id
                FROM    msc_allocation_assignments maa2
                WHERE   maa2.inventory_item_id = mi.inventory_item_id
                AND     maa2.assignment_type = 3)
	AND NOT EXISTS (
                SELECT  maa7.inventory_item_id
                FROM    msc_allocation_assignments maa7
                WHERE   maa7.inventory_item_id = mi.inventory_item_id
                AND     maa7.organization_id = mi.organization_id
                AND     maa7.sr_instance_id = mi.sr_instance_id
                AND     maa7.assignment_type = 7 )
	UNION ALL
	SELECT 	mi.inventory_item_id INVENTORY_ITEM_ID,
		mi.organization_id ORGANIZATION_ID,
		mi.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_system_items mi,
		msc_alloc_rule_time_phases martp,
		msc_allocation_assignments maa
	WHERE	maa.assignment_type = 1
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mi.plan_id = -1
        AND     mi.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mi.sr_instance_id <  ' || to_char(l_max_instance_id) ||
        ' AND NOT EXISTS (
		SELECT	/*+ leading(maa1) */ maa1.inventory_item_id
		FROM	msc_allocation_assignments maa1,
			msc_item_categories mic
		WHERE	maa1.category_set_id = mic.category_set_id
		AND	maa1.category_name = mic.category_name
                AND     mi.inventory_item_id = mic.inventory_item_id
                AND     mi.organization_id = mic.organization_id
                AND     mi.sr_instance_id = mic.sr_instance_id
		AND	maa1.assignment_type = 2)
	AND NOT EXISTS (
		SELECT	maa2.inventory_item_id
		FROM	msc_allocation_assignments maa2
		WHERE	maa2.inventory_item_id = mi.inventory_item_id
		AND	maa2.assignment_type = 3)
	AND NOT EXISTS (
                SELECT  maa3.inventory_item_id
                FROM    msc_allocation_assignments maa3
                WHERE   maa3.organization_id = mi.organization_id
                AND     maa3.sr_instance_id = mi.sr_instance_id
                AND     maa3.assignment_type = 6)
	AND NOT EXISTS (
                SELECT  maa7.inventory_item_id
                FROM    msc_allocation_assignments maa7
                WHERE   maa7.inventory_item_id = mi.inventory_item_id
                AND     maa7.organization_id = mi.organization_id
                AND     maa7.sr_instance_id = mi.sr_instance_id
                AND     maa7.assignment_type = 7 )';

	sql_stmt2 := 'create index ' || l_temp_table(i) || '_N1 on ' ||
	l_temp_table(i) || '
         --NOLOGGING
         --5053818
	(inventory_item_id, organization_id, sr_instance_id, demand_class)
	storage(INITIAL '||l_item_hier_indx_init_extent||'K NEXT '||l_item_hier_indx_nxt_extent||'M PCTINCREASE '||l_item_hier_indx_pct_inc||') tablespace ' || l_tbspace(i);
	--storage(INITIAL 40K NEXT 2M PCTINCREASE 0) LOCAL tablespace ' || l_tbspace(i);

       ELSIF j = 2 THEN

	sql_stmt1 := 'create table ' || l_temp_table(i) ||
	' PCTFREE 0 STORAGE(INITIAL '||l_res_hier_init_extent||'K NEXT '||l_res_hier_next_extent||'M PCTINCREASE '||l_res_hier_pct_inc||')' ||
	' TABLESPACE ' || l_tbspace(i) ||
  --' NOLOGGING' ||
	--' PARTITION BY HASH (DEPARTMENT_ID) PARTITIONS ' || to_char(l_sub_part(i))||
	' AS ' ||
	'SELECT maa.resource_id RESOURCE_ID,
		mdr.department_id DEPARTMENT_ID,
		mdr.organization_id ORGANIZATION_ID,
		mdr.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_alloc_rule_time_phases martp,
		msc_allocation_assignments maa,
		msc_department_resources mdr
	WHERE  	maa.assignment_type = 4
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	maa.resource_id = mdr.resource_id
	AND	maa.department_id = mdr.department_id
	AND	maa.organization_id = mdr.organization_id
	AND	maa.sr_instance_id = mdr.sr_instance_id
	AND	maa.resource_group IS NULL
	AND	mdr.plan_id = -1
        AND	mdr.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mdr.sr_instance_id <  ' || to_char(l_max_instance_id) ||
	' UNION ALL
	SELECT 	mdr.resource_id RESOURCE_ID,
		mdr.department_id DEPARTMENT_ID,
		mdr.organization_id ORGANIZATION_ID,
		mdr.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_alloc_rule_time_phases martp,
		msc_allocation_assignments maa,
		msc_department_resources mdr
	WHERE	maa.assignment_type = 5
	AND	maa.sr_instance_id = mdr.sr_instance_id
	AND	maa.resource_group = mdr.resource_group_name
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mdr.plan_id = -1
	AND	maa.resource_group IS NOT NULL
        AND	mdr.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mdr.sr_instance_id <  ' || to_char(l_max_instance_id) ||
	' AND NOT EXISTS (
		SELECT	maa1.resource_id
		FROM	msc_allocation_assignments maa1
		WHERE	maa1.resource_id = mdr.resource_id
		AND	maa1.organization_id = mdr.organization_id
		AND	maa1.sr_instance_id = mdr.sr_instance_id
		AND	maa1.department_id = mdr.department_id
		AND	maa1.assignment_type = 4)
	UNION ALL
	SELECT  mdr.resource_id RESOURCE_ID,
                mdr.department_id DEPARTMENT_ID,
                mdr.organization_id ORGANIZATION_ID,
                mdr.sr_instance_id SR_INSTANCE_ID,
                ma.demand_class DEMAND_CLASS,
                maa.allocation_rule_name ALLOCATION_RULE_NAME,
                maa.assignment_type ASSIGNMENT_TYPE,
                ma.allocation_percent ALLOCATION_PERCENT,
                martp.effective_date EFFECTIVE_DATE,
                martp.disable_date DISABLE_DATE,
                ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM    msc_allocations ma,
                msc_alloc_rule_time_phases martp,
                msc_allocation_assignments maa,
                msc_department_resources mdr
	WHERE   maa.assignment_type = 6
	AND     maa.sr_instance_id = mdr.sr_instance_id
	AND     maa.organization_id = mdr.organization_id
	AND     maa.allocation_rule_name = martp.allocation_rule_name
	AND     martp.time_phase_id =  ma.time_phase_id
	AND     mdr.plan_id = -1
	AND     maa.resource_group IS NULL
	AND     maa.resource_id IS NULL
        AND	mdr.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mdr.sr_instance_id <  ' || to_char(l_max_instance_id) ||
	' AND NOT EXISTS (
                SELECT  maa1.resource_id
                FROM    msc_allocation_assignments maa1
                WHERE   maa1.resource_id = mdr.resource_id
                AND     maa1.organization_id = mdr.organization_id
                AND     maa1.sr_instance_id = mdr.sr_instance_id
                AND     maa1.department_id = mdr.department_id
                AND     maa1.assignment_type = 4)
	AND NOT EXISTS (
                SELECT  maa2.resource_group
                FROM    msc_allocation_assignments maa2
                WHERE   maa2.resource_group = mdr.resource_group_name
                AND     maa2.sr_instance_id = mdr.sr_instance_id
                AND     maa2.assignment_type = 5)
	UNION ALL
	SELECT 	mdr.resource_id RESOURCE_ID,
		mdr.department_id DEPARTMENT_ID,
		mdr.organization_id ORGANIZATION_ID,
		mdr.sr_instance_id SR_INSTANCE_ID,
		ma.demand_class DEMAND_CLASS,
 		maa.allocation_rule_name ALLOCATION_RULE_NAME,
 		maa.assignment_type ASSIGNMENT_TYPE,
 		ma.allocation_percent ALLOCATION_PERCENT,
 		martp.effective_date EFFECTIVE_DATE,
 		martp.disable_date DISABLE_DATE,
 		ma.priority PRIORITY,
                ma.service_level SERVICE_LEVEL,
                martp.time_phase_id TIME_PHASE_ID,
                ma.class CLASS,
                ma.partner_id PARTNER_ID,
                ma.partner_site_id PARTNER_SITE_ID,
                ma.level_id LEVEL_ID,
                ma.level_alloc_percent LEVEL_ALLOC_PERCENT,
                ma.level_priority LEVEL_PRIORITY,
                ma.min_level_alloc_percent MIN_LEVEL_ALLOC_PERCENT,
                ma.min_allocation_percent MIN_ALLOCATION_PERCENT
	FROM	msc_allocations ma,
		msc_department_resources mdr,
		msc_alloc_rule_time_phases martp,
		msc_allocation_assignments maa
	WHERE	maa.assignment_type = 1
	AND	maa.allocation_rule_name = martp.allocation_rule_name
	AND	martp.time_phase_id =  ma.time_phase_id
	AND	mdr.plan_id = -1
	AND	maa.resource_id IS NULL
	AND	maa.resource_group IS NULL
        AND	mdr.sr_instance_id >= ' || to_char(l_min_instance_id) ||
        ' AND   mdr.sr_instance_id <  ' || to_char(l_max_instance_id) ||
	' AND NOT EXISTS (
		SELECT	maa1.resource_id
		FROM	msc_allocation_assignments maa1
		WHERE	maa1.resource_id = mdr.resource_id
		AND	maa1.department_id = mdr.department_id
		AND	maa1.organization_id = mdr.organization_id
		AND	maa1.sr_instance_id = mdr.sr_instance_id
		AND	maa1.assignment_type = 4)
	AND NOT EXISTS (
		SELECT	maa1.resource_group
		FROM	msc_allocation_assignments maa1
		WHERE	maa1.resource_group = mdr.resource_group_name
		AND	maa1.sr_instance_id = mdr.sr_instance_id
		AND	maa1.assignment_type = 5)
	AND NOT EXISTS (
                SELECT  maa3.resource_group
                FROM    msc_allocation_assignments maa3
                WHERE   maa3.organization_id = mdr.organization_id
                AND     maa3.sr_instance_id = mdr.sr_instance_id
                AND     maa3.assignment_type = 6)';

	sql_stmt2 := 'create index ' || l_temp_table(i) || '_N1 on ' ||
	l_temp_table(i) || '
  --NOLOGGING
  --5053818
	(resource_id, department_id, organization_id, sr_instance_id, demand_class)
	storage(INITIAL '||l_res_hier_indx_init_extent||'K NEXT '||l_res_hier_indx_nxt_extent||'M PCTINCREASE '||l_res_hier_indx_pct_inc||') tablespace ' || l_tbspace(i);
	--storage(INITIAL 40K NEXT 2M PCTINCREASE 0) LOCAL tablespace ' || l_tbspace(i);

       END IF;

      msc_util.msc_log('Before AD_DDL');
       BEGIN
	msc_util.msc_log('Before create table : ' ||l_temp_table(i));
	ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
               APPLICATION_SHORT_NAME => 'MSC',
               STATEMENT_TYPE => ad_ddl.create_table,
               STATEMENT => sql_stmt1,
               OBJECT_NAME => l_temp_table(i));
       EXCEPTION
	  WHEN others THEN

	     msc_util.msc_log(sqlerrm);
	     msc_util.msc_log('Inside Exception of create table : ' ||l_temp_table(i));
	     ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                    APPLICATION_SHORT_NAME => 'MSC',
                    STATEMENT_TYPE => ad_ddl.drop_table,
                    STATEMENT =>  'DROP TABLE ' || l_temp_table(i),
                    OBJECT_NAME => l_temp_table(i));

	     msc_util.msc_log('After Drop table : ' ||l_temp_table(i));
	     ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
                    APPLICATION_SHORT_NAME => 'MSC',
                    STATEMENT_TYPE => ad_ddl.create_table,
                    STATEMENT => sql_stmt1,
                    OBJECT_NAME => l_temp_table(i));
	     msc_util.msc_log('After create table : ' ||l_temp_table(i));
       END;

       BEGIN
	msc_util.msc_log('Before create index : ' ||l_temp_table(i));
	ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
               APPLICATION_SHORT_NAME => 'MSC',
               STATEMENT_TYPE => ad_ddl.create_index,
               STATEMENT => sql_stmt2,
               OBJECT_NAME => l_temp_table(i));
       EXCEPTION
	  WHEN others THEN

	     msc_util.msc_log(sqlerrm);
	     msc_util.msc_log('Inside Exception of create index : ' ||l_temp_table(i));
             --- bug 4156016: Raise exception so that we could error out gracefully
             RAISE FND_API.G_EXC_ERROR;

       END;

	fnd_stats.gather_table_stats('MSC', l_temp_table(i), granularity => 'ALL');

	i := l_cur_table.NEXT(i);
	l_min_instance_id := l_max_instance_id;

	IF i = l_cur_table.COUNT THEN
	   l_max_instance_id := 99999;
	ELSIF i < l_cur_table.COUNT THEN
	   IF l_cur_table(i) <> l_cur_table(i+1) THEN
	      l_max_instance_id := 99999;
	   ELSE
	      l_max_instance_id := l_max_instance_id + 30;
	   END IF;
	END IF;

      END LOOP;		-- WHILE i IS NOT NULL

     i := l_cur_table.FIRST;
     WHILE i IS NOT NULL LOOP
        sql_stmt1 := 'ALTER TABLE ' || l_cur_table(i) || ' exchange partition ' ||
                     l_part_name(i) || ' with table ' || l_temp_table(i) ||
		     ' including indexes without validation';

       BEGIN
	msc_util.msc_log('Before alter table : ' ||l_cur_table(i));
        ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
           APPLICATION_SHORT_NAME => 'MSC',
           STATEMENT_TYPE => ad_ddl.alter_table,
           STATEMENT => sql_stmt1,
           OBJECT_NAME => l_cur_table(i));
       EXCEPTION
	  WHEN others THEN

	     msc_util.msc_log(sqlerrm);
	     msc_util.msc_log('Inside Exception of alter table : ' ||l_cur_table(i));
	     --- bug 4156016: Raise exception so that we could error out gracefully
             RAISE FND_API.G_EXC_ERROR;

       END;

        sql_stmt2 := 'DROP TABLE ' || l_temp_table(i);

       BEGIN
	msc_util.msc_log('Before drop table : ' ||l_temp_table(i));
        ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
           APPLICATION_SHORT_NAME => 'MSC',
           STATEMENT_TYPE => ad_ddl.drop_table,
           STATEMENT => sql_stmt2,
           OBJECT_NAME => l_temp_table(i));
       EXCEPTION
	  WHEN others THEN

	     msc_util.msc_log(sqlerrm);
	     msc_util.msc_log('Inside Exception of alter table : ' ||l_temp_table(i));
             --- bug 4156016: Raise exception so that we could error out gracefully
             RAISE FND_API.G_EXC_ERROR;

       END;

	i := l_cur_table.NEXT(i);
     END LOOP;		-- WHILE i IS NOT NULL LOOP

      RETCODE:= G_SUCCESS;
      msc_util.msc_log('End REFRESH_MVIEW');
   EXCEPTION
      WHEN OTHERS THEN
	msc_util.msc_log(sqlerrm);
	msc_util.msc_log('Inside Main Exception');
        --bug 4156016: Set the error code here so that if an unhandled eception occurs in
        --- exception block then atleast the program will error out.
        RETCODE:= G_ERROR;
        ERRBUF:= SQLERRM;

	i := l_temp_table.FIRST;
	WHILE i IS NOT NULL LOOP

	   sql_stmt2 := 'DROP TABLE ' || l_temp_table(i);
           BEGIN
	   ad_ddl.do_ddl(APPLSYS_SCHEMA => l_applsys_schema,
              APPLICATION_SHORT_NAME => 'MSC',
              STATEMENT_TYPE => ad_ddl.drop_table,
              STATEMENT => sql_stmt2,
              OBJECT_NAME => l_temp_table(i));
           EXCEPTION
                WHEN OTHERS THEN
                    msc_util.msc_log('Error in droping table ' ||  l_temp_table(i));
           END;

	   i := l_temp_table.NEXT(i);
	END LOOP;		-- WHILE i IS NOT NULL LOOP

           ROLLBACK;
           ---bug 4156016: The variables have already been set
           --RETCODE:= G_ERROR;
           --ERRBUF:= SQLERRM;
   END REFRESH_MVIEW;


END MSC_ATP_REFRESH_MVIEW;

/
