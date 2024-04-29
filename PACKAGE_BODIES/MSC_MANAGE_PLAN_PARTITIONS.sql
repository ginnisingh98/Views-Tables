--------------------------------------------------------
--  DDL for Package Body MSC_MANAGE_PLAN_PARTITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_MANAGE_PLAN_PARTITIONS" AS
/* $Header: MSCPRPRB.pls 120.11.12010000.6 2010/03/31 21:05:34 harshsha ship $ */


  TYPE table_list IS TABLE of varchar2(300);
  -- following list contain all the partitioned tables.
  -- tables having only inst part (and not plan part) should be added at the begining of the list

  partitioned_tables table_list := table_list(
											'VISITS',
											'WO_MILESTONES',
											'WO_ATTRIBUTES',
											'WO_TASK_HIERARCHY',
											'WORK_BREAKDOWN_STRUCT',
											'WO_OPERATION_REL',
											'SUPPLIES',
                                            'ROUTING_OPERATIONS',
                                            'RESOURCE_REQUIREMENTS',
                                            'JOB_OPERATION_NETWORKS',
                                            'JOB_OPERATIONS',
                                            'JOB_OP_RESOURCES',
                                            'JOB_REQUIREMENT_OPS',
					     'RESOURCE_INSTANCE_REQS', /* ds_plan: change */
					     'JOB_OP_RES_INSTANCES',
					     'NET_RES_INST_AVAIL',  /* ds_plan: change */
                                            'NET_RESOURCE_AVAIL',
                                            'DEMANDS',
                                            'SYSTEM_ITEMS',
                                            'BOMS',
                                            'BOM_COMPONENTS',
                                            'ROUTINGS',
                                            'OPERATION_RESOURCE_SEQS',
                                            'OPERATION_RESOURCES',
                                            'ITEM_SUBSTITUTES',
                                            'ITEM_CATEGORIES',
                                            'SALES_ORDERS',
                                            'ATP_SUMMARY_SO',
                                            'ATP_SUMMARY_SD',
                                            'ATP_SUMMARY_RES',
                                            'ATP_SUMMARY_SUP',
                                            'DELIVERY_DETAILS',
                                            'REGIONS',
                                            'REGION_LOCATIONS',
                                            'ZONE_REGIONS',
                                            'ALLOC_DEMANDS',
                                            'ALLOC_SUPPLIES',
                                            'FULL_PEGGING',
                                            'PART_PEGGING',
                                            'PART_SUPPLIES',
                                            'PART_DEMANDS',
                                            'ITEM_EXCEPTIONS',
                                            'CRITICAL_PATHS',
                                            -- 'EXC_DETAILS_ALL',
                                            'EXCEPTION_DETAILS',
                                            -- CTO ODR Simplified Pegging
                                            'ATP_PEGGING',
                                            'PQ_RESULTS',  --pabram
                                            'SINGLE_LVL_PEG', -- dsting
                                            'SUPPLIER_REQUIREMENTS',
                                            'SRP_ITEM_EXCEPTIONS', -- dsting
                                            'RP_KPI', -- Rapid Planning change
                                             'RP_CTB_DONOR_COMPONENTS', -- RP Clear to build
                                             'RP_CTB_ORDER_COMPONENTS'
                                              );


  -- updated partition_count  CTO ODR Simplified Pegging
  g_partition_count       CONSTANT NUMBER := 52;
  g_inst_partition_count  CONSTANT NUMBER := 37;
  MAXVALUE                CONSTANT NUMBER := 999999;
  PMAXVALUE               CONSTANT NUMBER := 999999;
  g_need_refresh_mv boolean := true;
--
-- private functions
--

-- -----------------------------------------------------
-- Checks the availability of healty partition of a plan
-- -----------------------------------------------------
FUNCTION check_partition_pvt(p_plan_id IN NUMBER) RETURN VARCHAR2 IS
  l_partition_name  VARCHAR2(100);
  l_sql_stmt	    VARCHAR2(300);
  l_cur_table  	    VARCHAR2(100);

  NON_EXISTING_PARTITION EXCEPTION;
  pragma exception_init(NON_EXISTING_PARTITION, -02149);

BEGIN
    FOR i IN 1..g_partition_count LOOP
        l_cur_table := 'MSC_'|| partitioned_tables(i);
        IF (l_cur_table NOT IN
        (
         'MSC_VISITS','MSC_WO_MILESTONES','MSC_WO_ATTRIBUTES',
         'MSC_WO_TASK_HIERARCHY','MSC_WORK_BREAKDOWN_STRUCT','MSC_WO_OPERATION_REL',
         'MSC_ITEM_CATEGORIES','MSC_SALES_ORDERS', 'MSC_ATP_SUMMARY_SO'
		   ,'MSC_DELIVERY_DETAILS','MSC_REGIONS','MSC_REGION_LOCATIONS','MSC_ZONE_REGIONS')) THEN
            l_partition_name := partitioned_tables(i) || '_' || to_char(p_plan_id);
            l_sql_stmt := 'Lock Table '||l_cur_table||' Partition ('||l_partition_name||') In Exclusive Mode Nowait';

            msc_util.msc_debug(l_sql_stmt);

            execute immediate l_sql_stmt;
        END IF;
    END LOOP;

    RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NON_EXISTING_PARTITION THEN
        msc_util.msc_debug('Partition '||l_partition_name||'does not exist.');
        RETURN FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        l_sql_stmt := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
        msc_util.msc_debug(l_sql_stmt);
        RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END check_partition_pvt;

--
-- this procedure cleans (truncate or drop) partitions
--
PROCEDURE clean_partition_pvt( P_plan_num IN NUMBER,
			       P_instance_num IN NUMBER,
			        p_is_plan IN NUMBER,
			       p_operation IN VARCHAR2,
			  x_return_status OUT NOCOPY VARCHAR2,
	    		  x_msg_data OUT NOCOPY VARCHAR2)  IS

  CURSOR C_SCHEMA IS
    SELECT a.oracle_username
      FROM FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
     WHERE a.oracle_id = b.oracle_id
       AND b.application_id = 724;

  l_partition_name  VARCHAR2(100);
  l_applsys_schema  VARCHAR2(100);
  i		    NUMBER;
  sql_stmt	    VARCHAR2(200);
  cur_table   	    VARCHAR2(100);
  dummy1	    VARCHAR2(50);
  dummy2	    VARCHAR2(50);
  l_name	    VARCHAR2(10);

BEGIN

  if (p_is_plan = SYS_YES) then
    l_name := to_char(P_plan_num);
  else
    l_name := '_'|| to_char(P_instance_num);
  end if;

  --
  -- get fnd  schema name
  --
  if (FND_INSTALLATION.GET_APP_INFO('FND',dummy1,dummy2,l_applsys_schema) = FALSE) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('MSC','MSC_PART_UNDEFINED_SCHEMA');
    x_msg_data := fnd_message.get;
    return;
  end if;

   --dbms_output.put_line('Schemas are:'||l_applsys_schema);


    FOR i in 1..g_partition_count LOOP

      cur_table := 'MSC_'|| partitioned_tables(i);
      l_partition_name := partitioned_tables(i) || '_'
  			||l_name ;

      --
      -- construct the partition statement
      --
      sql_stmt := 'alter table ' || cur_table || ' '
		|| p_operation || ' partition '
  		|| l_partition_name;

    --  dbms_output.put_line(sql_stmt);
--      execute immediate sql_stmt;
      begin
        ad_ddl.do_ddl(l_applsys_schema,'MSC',
		ad_ddl.alter_table,sql_stmt,cur_table);
      exception
        --
        -- ignore the drop errors
        --
        when others then
         x_msg_data := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      end;


    END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END clean_partition_pvt;

--
-- this procedure creates the partitions for all the
-- partitioned tables
--
PROCEDURE  create_partition_pvt (plan_num IN NUMBER,
				 instance_num IN NUMBER,
			    x_return_status OUT NOCOPY VARCHAR2,
			    x_msg_data  OUT NOCOPY VARCHAR2)
				 IS

  CURSOR C_SCHEMA IS
    SELECT a.oracle_username
      FROM FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
     WHERE a.oracle_id = b.oracle_id
       AND b.application_id = 724;


  l_partition_name  VARCHAR2(100);
  l_applsys_schema  VARCHAR2(100);
  i		    NUMBER;
  part_created      NUMBER;
  sql_stmt	    VARCHAR2(200);
  cur_table   	    VARCHAR2(100);
  dummy1	    VARCHAR2(50);
  dummy2	    VARCHAR2(50);
  l_err_buf         VARCHAR2(4000);
  l_ret_code        NUMBER;


BEGIN


  --
  -- get fnd  schema name
  --
  if (FND_INSTALLATION.GET_APP_INFO('FND',dummy1,dummy2,l_applsys_schema) = FALSE) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('MSC','MSC_PART_UNDEFINED_SCHEMA');
    x_msg_data := fnd_message.get;
    return;
  end if;

 --  dbms_output.put_line('Schemas are:'||l_applsys_schema);

  --- first check if paritions for old plans in summary table exist or not. If not then
  -- create them
  MSC_POST_PRO.CREATE_PARTITIONS(l_err_buf, l_ret_code);
  IF (l_ret_code <> 0) THEN
      --- error occured during partition creation in summary tables
      --- Since partitions are not created for lower plan IDs successfully, partition
      --- for higher plan ID will not be created
      x_msg_data := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
  END IF;

  part_created := 1;

  FOR i in 1..g_partition_count LOOP


    cur_table := 'MSC_'|| partitioned_tables(i) ;
    l_partition_name := partitioned_tables(i) || '_' || to_char(plan_num);

    --
    -- construct the partition statement
    -- For non-collected tables partition by plan_id only
    --
    if (cur_table = 'MSC_FULL_PEGGING' OR cur_table = 'MSC_EXCEPTION_DETAILS'
	OR cur_table = 'MSC_ITEM_EXCEPTIONS'
        OR cur_table = 'MSC_CRITICAL_PATHS'
	OR cur_table = 'MSC_PQ_RESULTS'
	OR cur_table = 'MSC_SUPPLIER_REQUIREMENTS'
        OR cur_table = 'MSC_SRP_ITEM_EXCEPTIONS'
	OR cur_table = 'MSC_RP_KPI'
        OR cur_table = 'MSC_RP_CTB_DONOR_COMPONENTS'
        OR cur_table = 'MSC_RP_CTB_ORDER_COMPONENTS'
        OR cur_table = 'MSC_SINGLE_LVL_PEG'
        OR cur_table = 'MSC_PART_PEGGING'
        OR cur_table = 'MSC_PART_SUPPLIES'
        OR cur_table = 'MSC_PART_DEMANDS'
        ) THEN -- dsting

      sql_stmt := 'alter table ' || cur_table || ' add partition '
		|| l_partition_name
		|| ' VALUES LESS THAN ('
		|| to_char(plan_num+1)
		|| ')';
    else
      sql_stmt := 'alter table ' || cur_table || ' add partition '
		|| l_partition_name
		|| ' VALUES LESS THAN ('
		|| to_char(plan_num)
 		|| ','
		|| to_char(instance_num +1)
		|| ')';
    end if;

    --dbms_output.put_line(sql_stmt);
    -- execute immediate sql_stmt;

    if (cur_table NOT IN (
         'MSC_VISITS','MSC_WO_MILESTONES','MSC_WO_ATTRIBUTES',
         'MSC_WO_TASK_HIERARCHY','MSC_WORK_BREAKDOWN_STRUCT','MSC_WO_OPERATION_REL',
         'MSC_ITEM_CATEGORIES','MSC_SALES_ORDERS', 'MSC_ATP_SUMMARY_SO'
    			  ,'MSC_DELIVERY_DETAILS','MSC_REGIONS','MSC_REGION_LOCATIONS','MSC_ZONE_REGIONS')) then
    ad_ddl.do_ddl(l_applsys_schema,'MSC',
		ad_ddl.alter_table,sql_stmt,cur_table);
    end if;
    part_created := part_created +1;

  END LOOP;
  --dbms_output.put_line('****returning success****'||x_msg_data);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --
  -- could not create partition
  --
  WHEN OTHERS THEN

  --  dbms_output.put_line(sql_stmt || ' Error:'||to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
  --  fnd_message.set_name('MSC','MSC_PART_CREATE_FAILED');
  --  fnd_message.set_token('PARTITION',l_partition_name);
  --  x_msg_data := fnd_message.get;
    x_msg_data := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
    x_return_status := FND_API.G_RET_STS_ERROR;

    --
    -- if partitions were created partially then remove the ones
    -- that were successful so that we can exit in a clean state
    --
    for i in 1..part_created - 1 LOOP
      cur_table := 'MSC_'|| partitioned_tables(i);
      l_partition_name := partitioned_tables(i) || '_'
  			|| to_char(plan_num);

      --
      -- construct the partition statement
      --
      sql_stmt := 'alter table ' || cur_table || ' drop  partition '
  		|| l_partition_name;

   --   dbms_output.put_line(sql_stmt);
      -- execute immediate sql_stmt;
    ad_ddl.do_ddl(l_applsys_schema,'MSC',
		ad_ddl.alter_table,sql_stmt,cur_table);

    END LOOP;


END create_partition_pvt;

--
-- this procedure creates the instance partitions for all the
-- partitioned tables
--

PROCEDURE create_inst_partitions_pvt(
                            p_instance_id   IN  NUMBER,
			    x_return_status OUT NOCOPY VARCHAR2,
			    x_msg_data      OUT NOCOPY VARCHAR2)
				 IS

  CURSOR C_SCHEMA IS
    SELECT a.oracle_username
      FROM FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
     WHERE a.oracle_id = b.oracle_id
       AND b.application_id = 724;

  l_dummy_partition_name  VARCHAR2(100);
  l_partition_name  VARCHAR2(100);
  l_applsys_schema  VARCHAR2(100);
  i		    NUMBER;
  part_created      NUMBER;
  sql_stmt	    VARCHAR2(200);
  cur_table   	    VARCHAR2(100);
  dummy1	    VARCHAR2(50);
  dummy2	    VARCHAR2(50);
  l_err_buf         VARCHAR2(4000);
  l_ret_code        NUMBER;


BEGIN

  --
  -- get fnd  schema name
  --
  if (FND_INSTALLATION.GET_APP_INFO('FND',dummy1,dummy2,l_applsys_schema) = FALSE) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('MSC','MSC_PART_UNDEFINED_SCHEMA');
    x_msg_data := fnd_message.get;
    return;
  end if;

   --dbms_output.put_line('Schemas are:'||l_applsys_schema);

  --- first check if paritions for old plans in summary table exist or not. If not then
  -- create them
  MSC_POST_PRO.CREATE_PARTITIONS(l_err_buf, l_ret_code);
  IF (l_ret_code <> 0) THEN
      --- error occured during partition creation in summary tables
      --- Since partitions are not created for lower instance IDs successfully, partition
      --- for higher instnaces will not be created
      x_msg_data := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
  END IF;


  part_created := 1;

  FOR i in 1..g_inst_partition_count LOOP

--msc_util.log_msg(MSC_UTIL.G_D_STATUS,'db0-'||partitioned_tables(i));
    cur_table := 'MSC_'|| partitioned_tables(i) ;
    l_dummy_partition_name := partitioned_tables(i) || '_0';
    l_partition_name := partitioned_tables(i) || '__' || to_char(p_instance_id);

    --
    -- construct the partition statement
    --
    IF cur_table IN (
                 'MSC_VISITS','MSC_WO_MILESTONES','MSC_WO_ATTRIBUTES',
                 'MSC_WO_TASK_HIERARCHY','MSC_WORK_BREAKDOWN_STRUCT','MSC_WO_OPERATION_REL',
                 'MSC_ITEM_CATEGORIES','MSC_SALES_ORDERS', 'MSC_ATP_SUMMARY_SO'
    			,'MSC_DELIVERY_DETAILS','MSC_REGIONS','MSC_REGION_LOCATIONS','MSC_ZONE_REGIONS') then
       sql_stmt := 'alter table ' || cur_table
                || ' split partition '|| l_dummy_partition_name
		|| ' AT ( '|| to_char(p_instance_id+1)||')'
		|| ' INTO ( PARTITION '||l_partition_name||','
 		||        ' PARTITION '||l_dummy_partition_name||')';
    ELSE
       sql_stmt := 'alter table ' || cur_table
                || ' split partition '|| l_dummy_partition_name
		|| ' AT ( -1, '|| to_char(p_instance_id+1)||')'
		|| ' INTO ( PARTITION '||l_partition_name||','
 		||        ' PARTITION '||l_dummy_partition_name||')';
    END IF;

    -- execute immediate sql_stmt;
--    msc_util.log_msg(MSC_UTIL.G_D_STATUS,'db1-'||sql_stmt);

    ad_ddl.do_ddl(l_applsys_schema,'MSC',
		ad_ddl.alter_table,sql_stmt,cur_table);
--	msc_util.log_msg(MSC_UTIL.G_D_STATUS,'db1-competed');
    part_created := part_created +1;

  END LOOP;
  --dbms_output.put_line('****returning success****'||x_msg_data);

  INSERT INTO MSC_INST_PARTITIONS (
     INSTANCE_ID,
     FREE_FLAG,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN
   )
  VALUES (
     p_instance_id,
     2,			/* used partition */
     sysdate,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.USER_ID,
     FND_GLOBAL.LOGIN_ID
       );

  COMMIT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --
  -- could not create partition
  --
  WHEN OTHERS THEN

 --   dbms_output.put_line(sql_stmt || ' Error:'||to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
  --  fnd_message.set_name('MSC','MSCFULL_PEGGINGCREATE_FAILED');
  --  fnd_message.set_token('PARTITION',l_partition_name);
  --  x_msg_data := fnd_message.get;
    x_msg_data := to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
    x_return_status := FND_API.G_RET_STS_ERROR;

    --
    -- if partitions were created partially then remove the ones
    -- that were successful so that we can exit in a clean state
    --
    for i in 1..part_created - 1 LOOP
      cur_table := 'MSC_'|| partitioned_tables(i);
      l_partition_name := partitioned_tables(i) || '__'
  			|| to_char(p_instance_id);

      --
      -- construct the partition statement
      --
      sql_stmt := 'alter table ' || cur_table || ' drop  partition '
  		|| l_partition_name;

  --    dbms_output.put_line(sql_stmt);
      -- execute immediate sql_stmt;
    ad_ddl.do_ddl(l_applsys_schema,'MSC',
		ad_ddl.alter_table,sql_stmt,cur_table);

    END LOOP;


END create_inst_partitions_pvt;

--
-- public functions
--

--
-- Called by Create Plan UI. This procedure will identify if ther
-- is a free partition available in MSC_APPS_INSTANCES. If yes then
-- it returns the plan_id. Otherwise it create a new partition by
-- performing DDL on all the partitioned tables. It store the new
-- plan_id in MSC_PLAN_PARTITIONS, marks it as being used and returns it
-- to the calling UI

FUNCTION get_plan  (p_plan_name IN VARCHAR2,
		    x_return_status OUT NOCOPY VARCHAR2,
	    		  x_msg_data OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  CURSOR  C_FREE_PLAN IS
   SELECT plan_id
     FROM MSC_PLAN_PARTITIONS
    WHERE free_flag = 1
    FOR UPDATE;


  CURSOR C_PLAN_COUNT IS
   SELECT count(*)
     FROM MSC_PLAN_PARTITIONS;

  CURSOR C_MAX_PLAN IS
   SELECT max(plan_id)
     FROM MSC_PLAN_PARTITIONS;

  l_plan_id    NUMBER;
  l_max_plan   NUMBER;
  l_plan_count NUMBER;
  X_login_id   NUMBER;
  X_user_id    NUMBER;
  l_return_status     VARCHAR2(1);
  i	       NUMBER;
  cur_table   	    VARCHAR2(100);
  l_partition_name  VARCHAR2(100);
  sql_stmt	    VARCHAR2(200);
  share_partition   VARCHAR2(1);

BEGIN

  -- set return status

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if plans are sharing partitions
  --

  share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

  if (share_partition = 'Y') then
    SELECT MSC_PLANS_S.nextval
    INTO l_plan_id
    from dual;

    return l_plan_id;
  end if;

  -- find free plans
  OPEN C_FREE_PLAN;
  LOOP
    FETCH C_FREE_PLAN INTO l_plan_id;
    if  (C_FREE_PLAN%NOTFOUND) then

        --
        -- based on performance team's input, we donot want to create
        -- partitions on the fly. Hence, return error. Partitions
        -- should be created by the system dba because that involves
        -- analyzing as well as recompiling db objects

        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('MSC','MSC_NO_FREE_PARTITION');
        x_msg_data := fnd_message.get;
        l_plan_id := -1; --return -1;
        EXIT;
        --
        -- the code below is no longer needed
        --
        --
        -- No free plans available. So create one.
        --
        /* CLOSE C_FREE_PLAN;

        SELECT msc_plans_s.nextval
        INTO   l_plan_id
        FROm   dual;

        --
        -- now add a new partition to all the partitioned tables
        --

        create_partition_pvt(l_plan_id,MAXVALUE,x_return_status,x_msg_data);

        --
        -- if could not create partition then return error
        --
        if (x_return_status = FND_API.G_RET_STS_ERROR) then
            l_plan_id := -1;
            return l_plan_id;
        end if;

        X_user_id := to_number(FND_GLOBAL.User_Id);
        X_Login_Id := to_number(FND_GLOBAL.Login_Id);

        begin
            INSERT INTO MSC_PLAN_PARTITIONS (
                PLAN_ID,
                PLAN_NAME,
                FREE_FLAG,
                PARTITION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN
                )
            VALUES (
                l_plan_id,
                p_plan_name,
                2,
                l_plan_id,
                sysdate,
                X_User_Id,
                sysdate,
                X_User_Id,
                X_Login_Id
                );
        exception
            when others then
                --
                -- drop the partitions that were created in this run so
                -- as to ensure a clean exit
                --
                clean_partition_pvt(l_plan_id,MAXVALUE,1,'drop',x_return_status, x_msg_data);
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                x_msg_data :=  to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
                l_plan_id := -1;
                return l_plan_id;
        end;*/
    else
        --
        -- found a free plan. update it's name
        --
        --    dbms_output.put_line('Found a free plan'||p_plan_name);
        BEGIN
            if check_partition_pvt(l_plan_id) = FND_API.G_RET_STS_SUCCESS then
                UPDATE MSC_PLAN_PARTITIONS
                SET plan_name = p_plan_name,
                    free_flag = 2
                WHERE plan_id = l_plan_id;
                EXIT;
            ELSE
                UPDATE MSC_PLAN_PARTITIONS
                SET plan_name = '*UNUSABLE*',
                    free_flag = 2
                WHERE plan_id = l_plan_id;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                --fnd_message.set_name('MSC','MSC_PART_UPDATE_FAILED');
                x_msg_data :=   to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
                -- fnd_message.get;
                l_plan_id := -1;
                EXIT; --return l_plan_id;
        END;
    END IF;
  END LOOP;
  CLOSE C_FREE_PLAN;
  RETURN l_plan_id;

EXCEPTION WHEN others THEN


  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
  l_plan_id := -1;
  return l_plan_id;

END get_plan;


PROCEDURE create_inst_partition( errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY NUMBER,
				instance_count IN NUMBER) IS
  x_return_status VARCHAR2(10);
  i NUMBER;

BEGIN

  --
  -- create partition for each instance. Do not create partition
  -- for plan_id = -1 because that would have been created by
  -- adpatch during table creation time
  --
    FOR i in 1..instance_count LOOP

      create_partition_pvt(-1,i,x_return_status,errbuf);

      --
      -- break if partition creation fails
      --
      if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        exit;
      end if;

      INSERT INTO MSC_INST_PARTITIONS (
        INSTANCE_ID,
        FREE_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      VALUES (
        i,
        1,			/* free partition */
        sysdate,
        1,
        sysdate,
        1,
        1
       );

       commit;

    END LOOP;

    if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      retcode := G_SUCCESS;
    else
      retcode := G_ERROR;
    end if;

END  create_inst_partition;


--
-- This function creates the partition for the data
-- collected from the instance P_instance_id. The plan_id is
-- defaulted to -1
--
FUNCTION get_instance ( x_return_status OUT NOCOPY VARCHAR2,
		        x_msg_data  OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  CURSOR  C_FREE_INSTANCE IS
   SELECT instance_id
     FROM MSC_INST_PARTITIONS
    WHERE free_flag = 1;

  sql_stmt	    VARCHAR2(200);
  l_inst_id	    NUMBER:= NULL;

BEGIN
  -- set return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- find free instance
  OPEN C_FREE_INSTANCE;
  FETCH C_FREE_INSTANCE INTO l_inst_id;
  CLOSE C_FREE_INSTANCE;

  if l_inst_id IS NULL then

    --
    -- cannot create an instance partition dynamically.
    -- the sysadmin will have to create them
    --
      fnd_message.set_name('MSC','MSC_NO_FREE_PARTITION');
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      x_msg_data := fnd_message.get;
      return -1;

    /*
    SELECT msc_apps_instances_s.nextval
      INTO l_inst_id
      FROM DUAL;

    create_inst_partitions_pvt( l_inst_id,x_return_status,x_msg_data);

    if x_return_status = FND_API.G_RET_STS_ERROR THEN
       return -1;
    end if;
    */

  else
     null;
 --   dbms_output.put_line('Found a free instance'||l_inst_id);
  end if;

  begin
      UPDATE MSC_INST_PARTITIONS
         SET free_flag = 2
       WHERE instance_id = l_inst_id;

  exception
      when others then
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        --fnd_message.set_name('MSC','MSC_PART_UPDATE_FAILED');
        x_msg_data :=   to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
        -- fnd_message.get;
        l_inst_id := -1;
        return l_inst_id;
  end;

  return l_inst_id;

EXCEPTION WHEN others THEN
   x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
  l_inst_id := -1;
  return l_inst_id;

END get_instance;
--
--  returns the partition name
--

PROCEDURE get_partition_name (P_plan_id IN NUMBER,
			      P_instance_id IN NUMBER,
			     P_table_name IN VARCHAR2,
			     P_is_plan  IN NUMBER,
		             P_partition_name OUT NOCOPY VARCHAR2,
			     x_return_status OUT NOCOPY VARCHAR2,
			     x_msg_data  OUT NOCOPY VARCHAR2) IS

  i		 NUMBER;
  cur_table_name VARCHAR2(40);
  l_count   NUMBER;
  l_id      	NUMBER;

  CURSOR Plan_exists_C(P_plan_id IN NUMBER) IS
    SELECT count(*)
    FROM   MSC_PLAN_PARTITIONS
    WHERE  plan_id = P_plan_id;

  CURSOR Instance_exists_C(P_instance_id IN NUMBER) IS
    SELECT count(*)
    FROM   MSC_INST_PARTITIONS
    WHERE  instance_id = P_instance_id;

BEGIN
       msc_util.msc_debug('P_table_name = '||P_table_name );
  for i in 1..g_partition_count LOOP

    cur_table_name := 'MSC_' || partitioned_tables(i);
    if  (cur_table_name = P_table_name) then


      if (P_is_plan = SYS_YES) then
	l_id := P_plan_id;
        --
        -- now see if the plan/instance id exists in msc_plan_partitions
        --
        OPEN Plan_exists_C(P_plan_id);
        FETCH Plan_exists_C INTO l_count;
        CLOSE Plan_exists_C;
      else
 	l_id := P_instance_id;
        OPEN Instance_exists_C(P_instance_id);
        FETCH Instance_exists_C INTO l_count;
        CLOSE Instance_exists_C;
      end if;

      if (l_count <> 1) then
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := to_char(l_id) || 'Id does not exist';
        return;
      end if;

      --
      -- syntax: tab_name__<instance_id> for instances
      -- 	 tab_name_<plan_id> for plans
      --
      if (P_is_plan = SYS_YES) then
        P_partition_name := partitioned_tables(i) || '_' || to_char(P_plan_id);
      else

	P_partition_name := partitioned_tables(i) || '__' || to_char(P_instance_id);
      end if;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      return;
    end if;
  END LOOP;

  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := P_table_name || ' is not partitioned';
  return;
END get_partition_name;

--
-- purges a partiton from all the partitioned tables
--
PROCEDURE purge_partition( P_plan_id IN NUMBER,
			  x_return_status OUT NOCOPY VARCHAR2,
	    		  x_msg_data OUT NOCOPY VARCHAR2)  IS
BEGIN
   clean_partition_pvt(P_plan_id,MAXVALUE,1,'truncate', x_return_status, x_msg_data);

   if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
     begin

       UPDATE MSC_PLAN_PARTITIONS
       SET free_flag = 1
       WHERE plan_id = P_plan_id;
     exception
       when others then
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('MSC','MSC_PART_UPDATE_FAILED');
         x_msg_data := fnd_message.get;
         return;
     end;

   end if;

END purge_partition;

PROCEDURE create_force_partition (errbuf OUT NOCOPY varchar2,
		      	    retcode OUT NOCOPY number,
			    partition_num IN number,
			    plan IN NUMBER) IS
   x_return_status VARCHAR2(10);
   sql_stmt  varchar2(100);

BEGIN
--  dbms_output.put_line('---creating partitions---');
  if (plan = SYS_YES) then
    create_partition_pvt(partition_num, MAXVALUE,x_return_status, errbuf);
  else
     create_partition_pvt(-1,partition_num,x_return_status, errbuf);
  end if;

--  dbms_output.put_line('return status was '||x_return_status||' '||errbuf);

  if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    retcode := G_SUCCESS;
  else
    retcode := G_ERROR;
  end if;

--    sql_stmt := 'alter table temp.xx add partition xx'|| to_char(partition_num) ||
--		' values less than ('|| to_char(partition_num+1)||')' ;
--    dbms_output.put_line(sql_stmt);
--    execute immediate sql_stmt;


     begin
       if (plan = SYS_YES) then
         INSERT INTO MSC_PLAN_PARTITIONS (
         PLAN_ID,
         PLAN_NAME,
         FREE_FLAG,
         PARTITION_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN
       )
       VALUES (
         partition_num,
         to_char(partition_num),
         1,			/* free partition */
         partition_num,
         sysdate,
         1,
         sysdate,
         1,
         1
       );
     else
       INSERT INTO MSC_INST_PARTITIONS (
         INSTANCE_ID,
         FREE_FLAG,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN
       )
       VALUES (
         partition_num,
         1,			/* free partition */
         sysdate,
         1,
         sysdate,
         1,
         1
       );
     end if;
     commit;

    exception
       when others then

        --
	-- drop the partitions that were created in this run so
	-- as to ensure a clean exit
	--
        if (plan = SYS_YES) then
          clean_partition_pvt(partition_num,MAXVALUE,1,'drop',x_return_status, errbuf);
	else
	  clean_partition_pvt(-1,partition_num,2,'drop',x_return_status, errbuf);
	end if;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('MSC','MSC_PART_INSERT_FAILED');
        errbuf := fnd_message.get;
        retcode := to_number(x_return_status);
    end;
  exception
    when others then
      errbuf := 'partition = '||to_char(partition_num) || '  ' ||
	        to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
      retcode := G_ERROR;

END  create_force_partition;
PROCEDURE drop_force_partition (errbuf OUT NOCOPY varchar2,
		      	    retcode OUT NOCOPY number,
			    partition_num IN number,
			    plan IN NUMBER) IS
   x_return_status VARCHAR2(10);
   sql_stmt  varchar2(100);

BEGIN
  --
  -- Is it a plan partition or instance partition
  --
  if (plan = SYS_YES) then
    clean_partition_pvt(partition_num, MAXVALUE,1,'drop', x_return_status, errbuf);
  else
    clean_partition_pvt(-1,partition_num,2,'drop', x_return_status, errbuf);
  end if;

  if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    retcode := G_SUCCESS;
  else
    retcode := G_ERROR;
  end if;

--    sql_stmt := 'alter table temp.xx drop partition xx'|| to_char(partition_num)  ;
--    dbms_output.put_line(sql_stmt);
--    execute immediate sql_stmt;

  if (plan = SYS_YES) then
     DELETE FROM MSC_PLAN_PARTITIONS
     WHERE plan_id = partition_num;
     commit;
  else
    DELETE FROM MSC_INST_PARTITIONS
     WHERE instance_id = partition_num;
     commit;
  end if;

  exception
    when others then
      errbuf := 'delete failed'||to_char(partition_num) || '  ' ||
	        to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
      retcode := G_ERROR;

END  drop_force_partition;

PROCEDURE create_exist_plan_partitions( errbuf OUT NOCOPY VARCHAR2,
					   retcode OUT NOCOPY NUMBER) IS
  CURSOR  C_PLAN IS
   SELECT plan_id, compile_designator
     FROM MSC_PLANS
    WHERE plan_id <> -1
    ORDER BY plan_id;


   l_plan_id         NUMBER;
   l_plan_name	     VARCHAR(100);
   x_return_status   VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
   share_partition   VARCHAR2(1);
   plan_exists 	     BOOLEAN := FALSE;
   i		     NUMBER;
BEGIN

  --
  -- check if plans are sharing partitions
  -- if yes then just create one partition and return
  --
  share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');
--  dbms_output.put_line('share_partition := '||share_partition);
  if (share_partition = 'Y') then
   create_partition_pvt(PMAXVALUE,MAXVALUE,x_return_status,errbuf);
   if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      retcode := G_SUCCESS;
   else
      retcode := G_ERROR;
   end if;
   return;

  end if;


  OPEN C_PLAN;
  FETCH C_PLAN INTO l_plan_id,l_plan_name;

  --
  -- create partition for each plan. Do not create partition
  -- for plan_id = -1 because that would have been created by
  -- adpatch during table creation time
  --
   LOOP
    if (C_PLAN%NOTFOUND) then
     exit;
    end if;

    plan_exists := TRUE;
    create_partition_pvt(l_plan_id,MAXVALUE,x_return_status,errbuf);

    --
    -- break if partition creation fails
    --
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      exit;
    end if;

    INSERT INTO MSC_PLAN_PARTITIONS (
      PLAN_ID,
      PLAN_NAME,
      FREE_FLAG,
      PARTITION_NUMBER,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN
    )
    VALUES (
      l_plan_id,
      l_plan_name,
      2,			/* used partition */
      l_plan_id,
      sysdate,
      1,
      sysdate,
      1,
      1
     );

     commit;

    FETCH C_PLAN INTO l_plan_id,l_plan_name;

  END LOOP;

  CLOSE C_PLAN;

  --
  -- create 5 plans if none existed to begin with
  --
  if (plan_exists = FALSE) then
    FOR i in 1..5 LOOP

      SELECT msc_plans_s.nextval
      INTO   l_plan_id
      FROm   dual;
      create_partition_pvt(l_plan_id,MAXVALUE,x_return_status,errbuf);

      --
      -- break if partition creation fails
      --
      if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        exit;
      end if;

      INSERT INTO MSC_PLAN_PARTITIONS (
        PLAN_ID,
        PLAN_NAME,
        FREE_FLAG,
        PARTITION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
       )
      VALUES (
        l_plan_id,
        to_char(l_plan_id),
        1,			/* free partition */
        l_plan_id,
        sysdate,
        1,
        sysdate,
        1,
        1
       );

       commit;

    END LOOP;
  end if;

  if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    retcode := G_SUCCESS;
  else
    retcode := G_ERROR;
  end if;


END  create_exist_plan_partitions;


PROCEDURE drop_exist_plan_partitions( errbuf OUT NOCOPY VARCHAR2,
					   retcode OUT NOCOPY NUMBER) IS
  CURSOR  C_PLAN IS
   SELECT plan_id
     FROM MSC_PLANS
    WHERE plan_id <> -1;

   l_plan_id         NUMBER;
   x_return_status   VARCHAR2(10);
BEGIN

  OPEN C_PLAN;
  FETCH C_PLAN INTO l_plan_id;

  --
  -- drop partition for each plan except for plan_id =  -1
  --
  LOOP
    if (C_PLAN%NOTFOUND)  then
      exit;
    end if;

    --
    -- ignore the x_return_status since this is a forced drop
    -- so even if the partition drop failed because the partition
    -- never existed, that is OK.
    --
    clean_partition_pvt(l_plan_id,MAXVALUE,1,'drop',x_return_status,errbuf);


    FETCH C_PLAN INTO l_plan_id;
  END LOOP;

  CLOSE C_PLAN;

  DELETE FROM MSC_PLAN_PARTITIONS;
  retcode := G_SUCCESS;


END  drop_exist_plan_partitions;

PROCEDURE create_exist_inst_partitions( errbuf OUT NOCOPY VARCHAR2,
					   retcode OUT NOCOPY NUMBER) IS
  CURSOR  C_INSTANCE IS
   SELECT instance_id
     FROM MSC_apps_instances
    ORDER BY instance_id;

   l_instance_id         NUMBER;
   x_return_status   VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
   instance_exists       BOOLEAN := FALSE;
BEGIN

  OPEN C_INSTANCE;
  FETCH C_INSTANCE INTO l_instance_id;

  --
  -- create partition for each instance. Do not create partition
  -- for instance_id = -1 because that would have been created by
  -- adpatch during table creation time
  --
   LOOP
    if (C_INSTANCE%NOTFOUND) then
     exit;
    end if;

    instance_exists := TRUE;
  --  dbms_output.put_line('instance_id ='||to_char(l_instance_id));
    create_inst_partitions_pvt(l_instance_id,x_return_status,errbuf);

    --
    -- break if partition creation fails
    --
    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      exit;
    end if;

     commit;

    FETCH C_INSTANCE INTO l_instance_id;

  END LOOP;

  CLOSE C_INSTANCE;

  --
  -- if there were no instances then create one
  -- instance partition as default
  --
  if (instance_exists = FALSE) then

     SELECT msc_apps_instances_s.nextval
      INTO l_instance_id
      FROM DUAL;

     create_inst_partitions_pvt(l_instance_id,x_return_status,errbuf);

    --
    -- update msc_inst_partitions to mark the partition
    -- as free since the pvt api defaults it to used.
    --
     if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
      UPDATE MSC_INST_PARTITIONS
      SET    free_flag = 1
      WHERE  instance_id = l_instance_id;
     end if;

     commit;
  end if;

  if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    retcode := G_SUCCESS;
  else
    retcode := G_ERROR;
  end if;


END  create_exist_inst_partitions;

FUNCTION get_partition_number ( errbuf OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER,
				x_plan_id IN NUMBER) RETURN NUMBER IS
part_number   NUMBER;
BEGIN
   SELECT partition_number
   INTO   part_number
   FROM   MSC_PLAN_PARTITIONS
   WHERE  plan_id = x_plan_id;

   retcode := G_SUCCESS;
   return part_number;
exception
  when others then
   retcode := G_ERROR;
   errbuf :=  to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
   return -1;
END get_partition_number;

--
-- analyze a new partition
-- This procedure also refreshes the ATP snapshot
--
PROCEDURE analyze_plan(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
				x_plan_id IN NUMBER) IS
   i                NUMBER;
   l_partition_name VARCHAR2(51);
   cur_table         VARCHAR2(51);
   share_partition   VARCHAR2(1);
   lv_msc_schema     VARCHAR2(30);
   is_partitioned    VARCHAR2(10);
   v_snap_exist      number;
   -- v_tree_exist      number;
   v_analyze_plan_scope     NUMBER := NVL(FND_PROFILE.VALUE('MSC_ANALYZE_PARTITION_SCOPE'),1);


   Cursor msc_schema IS
    SELECT a.oracle_username
    FROM   FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
    WHERE  a.oracle_id = b.oracle_id
    AND    b.application_id= 724;

/*  --bug 3274373: Refresh Materialized view in ATP post plan processing.
    Cursor atp_snap IS
    SELECT 1
    FROM   all_objects
    WHERE  object_name like 'MSC_ATP_PLAN_SN'
    AND    owner = lv_msc_schema;
*/
/*
   Cursor tree_snap IS
    SELECT 1
    FROM   all_objects
    WHERE  object_name = 'MSC_SUPPLIER_TREE_MV'
    AND    owner = lv_msc_schema;
*/

BEGIN
  msc_util.msc_debug('starting atp snapshot refresh');
  retcode := G_SUCCESS;

  OPEN msc_schema;
  FETCH msc_schema INTO lv_msc_schema;
  CLOSE msc_schema;



/*  --bug 3274373: Refresh Materialized view in ATP post plan processing.
  OPEN atp_snap;
  FETCH atp_snap INTO v_snap_exist;
  CLOSE atp_snap;
*/
/*
  OPEN tree_snap;
  FETCH tree_snap INTO v_tree_exist;
  CLOSE tree_snap;
*/

/*  --bug 3274373: Refresh Materialized view in ATP post plan processing.
  --
  -- refresh the snapshot if it exists
  --
  if v_snap_exist =1 then
    MSC_UTIL.msc_debug('---- complete refresh of snapshot----');
    DBMS_SNAPSHOT.REFRESH( lv_msc_schema||'.MSC_ATP_PLAN_SN', 'C');
  end if;

*/

  SELECT partitioned
  INTO   is_partitioned
  FROM   dba_tables
  WHERE table_name = 'MSC_SUPPLIES'
  AND   owner = lv_msc_schema;

  --
  -- do not analyze partitions if the db is not partitioned
  --
if (is_partitioned = 'YES' AND x_plan_id <> 0) then

  msc_util.msc_debug('analyzing plan '||to_char(x_plan_id));

  FOR i in 1..g_partition_count LOOP


      share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');
      if (share_partition= 'Y') then
   	l_partition_name :=  partitioned_tables(i) || '_'
			     || to_char(PMAXVALUE);
      else
        l_partition_name := partitioned_tables(i) || '_'
  			||to_char(x_plan_id);
      end if;

      cur_table := 'MSC_'|| partitioned_tables(i);
      if (cur_table NOT IN (
                            'MSC_VISITS','MSC_WO_MILESTONES','MSC_WO_ATTRIBUTES',
                            'MSC_WO_TASK_HIERARCHY','MSC_WORK_BREAKDOWN_STRUCT','MSC_WO_OPERATION_REL',
                            'MSC_ITEM_CATEGORIES','MSC_SALES_ORDERS', 'MSC_ATP_SUMMARY_SO',
                            'MSC_ATP_SUMMARY_SD', 'MSC_ATP_SUMMARY_RES', 'MSC_ATP_SUMMARY_SUP',
                            'MSC_ALLOC_SUPPLIES', 'MSC_ALLOC_DEMANDS',
                            -- CTO ODR Simplified Pegging MSC_ATP_PEGGING not analyzed here
                            'MSC_EXC_DETAILS_ALL', 'MSC_ATP_PEGGING'
			    ,'MSC_DELIVERY_DETAILS','MSC_REGIONS','MSC_REGION_LOCATIONS','MSC_ZONE_REGIONS')) then

        msc_util.msc_debug('analyzing partition '||l_partition_name);
        IF v_analyze_plan_scope = 2 THEN
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>cur_table,
				   partname=>l_partition_name,
				   granularity=>'PARTITION',
				   percent =>10,degree=>4);
        ELSE
           fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>cur_table,
				   partname=>l_partition_name,
				   granularity=>'ALL',
				   percent =>10,degree=>4);
        END IF;
      end if;
  END LOOP;

end if;
/*
if g_need_refresh_mv and x_plan_id <> 0 and x_plan_id <> PMAXVALUE then

  declare
    p_out number;
  begin
   -- launch a concurrent program to refresh msc_supplier_tree_mv,
   -- populate kpi summary table and
   -- mark plan need to be recompared for plan comparison reports
    p_out := fnd_request.submit_request(
                         'MSC',
                         'MSC_UI_POST_PLAN',
                         null,
                         null,
                         false,
                         x_plan_id);
     commit;
     msc_util.msc_debug('launch UI Post Plan Program, request_id ='||p_out);
  end;

end if;
*/
END analyze_plan;

--
-- creates partitions
--
PROCEDURE create_partitions(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                plan_partition_count IN NUMBER,
			        inst_partition_count IN NUMBER) IS

   l_plan_id NUMBER;
   l_inst_id  NUMBER;
  X_login_id   NUMBER;
  X_user_id    NUMBER;
  x_return_status VARCHAR2(10);
   share_partition   VARCHAR2(1);

BEGIN

    retcode := G_SUCCESS;
    --
    -- check if plans are sharing partitions
    -- if yes then just create one partition and return
    --
    share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

  --  dbms_output.put_line('share partitions :='||share_partition);
    if (share_partition = 'Y' and plan_partition_count > 0) then
     create_partition_pvt(PMAXVALUE,MAXVALUE,x_return_status,errbuf);
     analyze_plan(errbuf,retcode,PMAXVALUE);
     if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
       retcode := G_SUCCESS;
     else
       retcode := G_ERROR;
     end if;

    else

      FOR i in 1..plan_partition_count LOOP

        SELECT msc_plans_s.nextval
        INTO   l_plan_id
        FROm   dual;


        --
        -- now add a new partition to all the partitioned tables
        --

        create_partition_pvt(l_plan_id,MAXVALUE,x_return_status,errbuf);

        --
        -- if could not create partition then return error
        --
        if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          retcode := G_ERROR;
          return;
        else
          retcode := G_SUCCESS;
        end if;



        X_user_id := to_number(FND_GLOBAL.User_Id);
        X_Login_Id := to_number(FND_GLOBAL.Login_Id);


        begin
         INSERT INTO MSC_PLAN_PARTITIONS (
         PLAN_ID,
         PLAN_NAME,
         FREE_FLAG,
         PARTITION_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN
        )
        VALUES (
         l_plan_id,
         to_char(l_plan_id),
         1,
         l_plan_id,
         sysdate,
         X_User_Id,
         sysdate,
         X_User_Id,
         X_Login_Id
        );
        exception
          when others then

          --
	  -- drop the partitions that were created in this run so
	  -- as to ensure a clean exit
	  --
          clean_partition_pvt(l_plan_id,MAXVALUE,1,'drop',x_return_status, errbuf);

          retcode := G_ERROR;
          errbuf :=  to_char(sqlcode) ||':'|| substr(sqlerrm,1,90);
          return ;
        end;
      --
      -- no need to analyze if no data
      --
        g_need_refresh_mv := false;
        analyze_plan(errbuf,retcode,l_plan_id);
        g_need_refresh_mv := true;
      END LOOP;

    end if;

      FOR i in 1..inst_partition_count LOOP
        SELECT msc_apps_instances_s.nextval
        INTO l_inst_id
        FROM DUAL;

        create_inst_partitions_pvt( l_inst_id,x_return_status,errbuf);

        if x_return_status = FND_API.G_RET_STS_ERROR THEN
          retcode := G_ERROR;
          return;
        end if;
    --
    -- update msc_inst_partitions to mark the partition
    -- as free since the pvt api defaults it to used.
    --
       if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
        UPDATE MSC_INST_PARTITIONS
        SET    free_flag = 1
        WHERE  instance_id = l_inst_id;
       end if;

      END LOOP;

    commit;
    return;
END create_partitions;

END MSC_MANAGE_PLAN_PARTITIONS;

/
