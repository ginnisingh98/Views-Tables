--------------------------------------------------------
--  DDL for Package Body MSC_ANALYSE_TABLES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ANALYSE_TABLES_PK" AS
    /* $Header: MSCANTBB.pls 115.9 2004/02/11 11:11:27 ashaj ship $ */

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

PROCEDURE    analyse IS

	CURSOR tab_list(p_owner varchar2) is
	SELECT	table_name,
                partitioned
	FROM	all_tables
	where 	owner=p_owner
        and     table_name like 'MSC%'
        and     temporary <> 'Y';

	var_table_name	VARCHAR2(30);
        var_partitioned VARCHAR2(3);

        v_applsys_schema VARCHAR2(32);
        lv_retval        boolean;
        lv_dummy1        varchar2(32);
        lv_dummy2        varchar2(32);
BEGIN
	lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2, v_applsys_schema);

	OPEN tab_list(v_applsys_schema);

	LOOP
		FETCH tab_list INTO var_table_name,
                                    var_partitioned;

		EXIT WHEN tab_list%NOTFOUND;

                IF var_partitioned='YES' THEN
                   fnd_stats.gather_table_stats(
                                 v_applsys_schema,
                                 var_table_name,
                                 granularity => 'PARTITION');
                ELSE
                   fnd_stats.gather_table_stats(v_applsys_schema, var_table_name);
                END IF;

	END LOOP;

        CLOSE tab_list;

END analyse;


    PROCEDURE analyse_table( p_table_name       IN VARCHAR2,
                             p_instance_id      IN NUMBER,
                             p_plan_id          IN NUMBER) IS

	CURSOR tab_list( cv_table_name IN VARCHAR2, cv_owner IN VARCHAR2) is
	SELECT	table_name,
                partitioned
	FROM	all_tables
	where 	owner=cv_owner
        and     table_name= UPPER(cv_table_name)
        and     temporary <> 'Y';

	var_table_name	   VARCHAR2(30);
        var_partitioned    VARCHAR2(3);
        var_partition_name VARCHAR2(30);
        var_is_plan        NUMBER;

        var_return_status   VARCHAR2(2048);
        var_msg_data        VARCHAR2(2048);

        v_applsys_schema VARCHAR2(32);
        lv_retval        boolean;
        lv_dummy1        varchar2(32);
        lv_dummy2        varchar2(32);

BEGIN
        lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,v_applsys_schema);
	OPEN tab_list( p_table_name,v_applsys_schema);

	FETCH tab_list INTO var_table_name,
                            var_partitioned;

        IF tab_list%NOTFOUND THEN RETURN; END IF;

        IF var_partitioned='YES' THEN
           IF p_instance_id IS NULL AND
              p_plan_id     IS NULL THEN

              /* analyse all the partitions */
              fnd_stats.gather_table_stats(
                            v_applsys_schema,
                            var_table_name,
                            granularity => 'PARTITION');

           ELSE

              IF p_plan_id= -1 OR p_plan_id IS NULL THEN
                 var_is_plan:= SYS_NO;
              ELSE
                 var_is_plan:= SYS_YES;
              END IF;

              msc_manage_plan_partitions.get_partition_name
                         ( p_plan_id,
                           p_instance_id,
                           p_table_name,
                           var_is_plan,
                           var_partition_name,
                           var_return_status,
                           var_msg_data);

              fnd_stats.gather_table_stats(
                            v_applsys_schema,
                            var_table_name,
                            10,
                            4,
                            var_partition_name);

           END IF;
        ELSE
           fnd_stats.gather_table_stats(v_applsys_schema, var_table_name, 10, 4);
        END IF;

        CLOSE tab_list;

        RETURN;

EXCEPTION

   WHEN OTHERS THEN
      RETURN;

END analyse_table;

END; -- package

/
