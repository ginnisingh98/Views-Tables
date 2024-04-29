--------------------------------------------------------
--  DDL for Package Body MTH_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_UTIL_PKG" AS
/*$Header: mthutilb.pls 120.8.12010000.26 2010/04/08 18:35:25 gtippire ship $ */


/* *****************************************************************************
* Procedure		    :MTH_RUN_LOG_PRE_LOAD                              *
* Description 	 	:This procedure is used for the population of the      *
* mth_run_log table for the initial and incremental load. The procedure is     *
* called at the begenning of the mapping execution sequence to set the         *
* boundary conditions for the ebs collection for the corresponding fact        *
* or dimension.                                                                *
* File Name	 	    :MTHUTILB.PLS		             	       *
* Visibility		    :Public                			       *
* Parameters	 	    : p_fact_name       :name of the fact	       *
*                     p_db_global_name  :source system global name             *
*                     p_run_mode        :run mode 'INITIAL' or blank           *
*                     p_run_start_date  :run start date for the run            *
*                     p_is_fact         :0=false, 1=true                       *
*                     p_to_date         :to_date for the run                   *
* Modification log	:	                                               *
*			Author		Date			Change	       *
*			Ankit Goyal	31-May-2007	Initial Creation       *
*	Ankit Goyal	03-Jul-2007   Incorporated pushkala comments           *
*  Amrit Kaur      14-mar-2008   Commented apps_initilalize due to Bug 6737820 *
***************************************************************************** */
PROCEDURE mth_run_log_pre_load( p_fact_table IN VARCHAR2,
                                p_db_global_name IN VARCHAR2,
                                p_run_mode IN VARCHAR2,
                                p_run_start_date IN DATE,
                                p_is_fact IN NUMBER,
                                p_to_date IN DATE)
IS
--local variable declation

l_fact_table mth_run_log.fact_table%TYPE;--fact table name
l_ebs_organization_id mth_run_log.ebs_organization_id%TYPE;
l_ebs_organization_code mth_run_log.ebs_organization_code%TYPE;
l_from_date mth_run_log.from_date%TYPE;--from date of the run
l_to_date mth_run_log.to_date%TYPE;--to date of the run
l_source mth_run_log.source%TYPE;--process or discrete. Not used currently
l_system_fk_key mth_systems_setup.system_pk_key%TYPE;
l_creation_date mth_run_log.creation_date%TYPE;--who column
l_last_update_date mth_run_log.last_update_date%TYPE;--who column
l_creation_system_id mth_run_log.creation_system_id%TYPE;--who column
l_last_update_system_id mth_run_log.last_update_system_id%TYPE;--who column
--l_sysdate to holding the current date
l_sysdate DATE := sysdate;--target system sysdate
--l_mode is used to determine the run type , initial 0 or incremental 1
l_mode NUMBER := 0;--initial default
l_plant_start_date DATE; --Plant end date
--Hub organization code
l_hub_organization_code mth_run_log.hub_organization_code%TYPE;

--cursor for iterating through the ebs organizations in mth_plants_d
--the rows in the mth_run_log will be at organization granularity
CURSOR c_ebs_orgs IS
SELECT ebs_organization_id,organization_code,
  source,plant_pk,system_fk_key,from_date
FROM mth_plants_d, mth_systems_setup,mth_organizations_l
WHERE system_pk_key = system_fk_key
AND system_pk = p_db_global_name
AND NVL(to_date,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)--pick active plants only
AND plant_fk_key=plant_pk_key;

BEGIN
  IF p_run_mode = 'INITIAL' THEN--Initial load
  --delete the rows from run log
  DELETE FROM mth_run_log WHERE fact_table = p_fact_table;

  END IF;
  --initialize the local variables and who columns
  l_fact_table := p_fact_table;
  l_last_update_system_id := -99999;
  l_last_update_date := l_sysdate;
  l_to_date := p_to_date;

  --initialize the global start date
  IF p_is_fact = 0 THEN--for dimensions only
  l_from_date := To_Date('01-01-1900','MM-DD-YYYY');
  END IF;

  --iterate through the cursor
  FOR l_orgs IN c_ebs_orgs
  LOOP

  	--initialize the variables for current cursor value
    l_ebs_organization_id := l_orgs.ebs_organization_id;
    l_source := l_orgs.source;--pick source column from the plants
    l_ebs_organization_code := l_orgs.organization_code;
    l_creation_date := l_sysdate;
	l_creation_system_id := -1;

    IF p_is_fact = 1 THEN--for facts only
    	l_from_date := l_orgs.from_date;--run start date= plant start date
    END IF;

    l_plant_start_date := l_orgs.from_date;
    l_hub_organization_code := l_orgs.plant_pk;


   	IF l_orgs.ebs_organization_id is null THEN
   			/* We are dealing with non-ebs org configured to the passed system*/
   			/* Check if there are records for non-ebs organizations from same system and same fact and same plant */
   		SELECT COUNT(*)
	    INTO l_mode
	    FROM mth_run_log
	    WHERE fact_table = l_fact_table
	    AND db_global_name = p_db_global_name
	    AND hub_organization_code = l_orgs.plant_pk;

	    IF l_mode = 0 OR UPPER(p_run_mode) = 'INITIAL' THEN /* Initial Load */

	      --statement for insert

		      INSERT INTO mth_run_log (fact_table, ebs_organization_id,
			ebs_organization_code,from_date,to_date, source, db_global_name,
			creation_date,last_update_date,creation_system_id,
			last_update_system_id,plant_start_date,hub_organization_code)
		      VALUES(l_fact_table,l_ebs_organization_id,l_ebs_organization_code,
			l_from_date,l_to_date,l_source,p_db_global_name,l_creation_date,
			l_last_update_date,l_creation_system_id,l_last_update_system_id,
			l_plant_start_date,l_hub_organization_code);

	    ELSE
		    /* update all non_ebs organizations from same system and plant with to_date as the passed date */
    		--Custom Logic for the time dimension
		      IF p_fact_table = 'MTH_WORKDAY_SHIFTS_D'
		      THEN
			      UPDATE mth_run_log
			      SET from_date = p_run_start_date
			      WHERE
			      fact_table = p_fact_table and db_global_name=p_db_global_name;
		      END IF ;

		      --statment for update
		      UPDATE mth_run_log
		      SET TO_DATE = l_to_date,
		      LAST_UPDATE_DATE = l_last_update_date,
		      LAST_UPDATE_SYSTEM_ID =l_last_update_system_id
		      WHERE
		      fact_table =l_fact_table
		      AND db_global_name = p_db_global_name
		      AND hub_organization_code =  l_hub_organization_code;


    	END IF; /* END of Initial VS Incremental */

  ELSE
     /* We are dealing with EBS Organizations  */

    --determine if there are any rows in the mth_run_log for
    --the fact_table corresponding to the org
	    SELECT COUNT(*)
	    INTO l_mode
	    FROM mth_run_log
	    WHERE fact_table = l_fact_table
	    AND ebs_organization_id = l_orgs.ebs_organization_id
	    AND db_global_name = p_db_global_name
	    AND hub_organization_code = l_orgs.plant_pk;

	    --l_mode = 0 means that it is a initial run. p_run_mode is
	    --for forceful execution of the initial load

	    IF l_mode = 0 OR UPPER(p_run_mode) = 'INITIAL' THEN--initial load

	      --initialize the variables for initial load
	      l_creation_date := l_sysdate;
	      l_creation_system_id := -1;

	      --statement for insert

	      INSERT INTO mth_run_log (fact_table, ebs_organization_id,
		ebs_organization_code,from_date,to_date, source, db_global_name,
		creation_date,last_update_date,creation_system_id,
		last_update_system_id,plant_start_date,hub_organization_code)
	      VALUES(l_fact_table,l_ebs_organization_id,l_ebs_organization_code,
		l_from_date,l_to_date,l_source,p_db_global_name,l_creation_date,
		l_last_update_date,l_creation_system_id,l_last_update_system_id,
		l_plant_start_date,l_hub_organization_code);



	      --if the above condition fails then update the row
	    ELSE--incremental load

	      --Custom Logic for the time dimension
	      IF p_fact_table = 'MTH_WORKDAY_SHIFTS_D'
	      THEN
		      UPDATE mth_run_log
		      SET from_date = p_run_start_date
		      WHERE
		      fact_table = p_fact_table;
	      END IF ;
		      --statment for update
		      UPDATE mth_run_log
		      SET TO_DATE = l_to_date,
		      LAST_UPDATE_DATE = l_last_update_date,
		      LAST_UPDATE_SYSTEM_ID =l_last_update_system_id
		      WHERE
		      fact_table =l_fact_table
		      AND source =l_source
		      AND db_global_name = p_db_global_name
		      AND ebs_organization_id = l_ebs_organization_id
		      AND hub_organization_code =  l_hub_organization_code;

	      --end of if clause
	    END IF; /* END of Initial VS Incremental */

END IF; /* End of EBS VS NON-EBS */
    --end of the for loop
  END LOOP;

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_run_log_pre_load;


/* *****************************************************************************
* Procedure		    :MTH_RUN_LOG_POST_LOAD	       	      	       *
* Description 	 	:This procedure is used for the population of the      *
* mth_run_log table for the initial and incremental load. The procedure is     *
* called at the end of the mapping execution sequence to set the               *
* boundary conditions for the ebs collection for the corresponding fact        *
* or dimension.                                                                *
* File Name	 	  : MTHUTILB.PLS				       *
* Visibility		  : Public                                             *
* Parameters	 	  : p_fact_name : name of the fact table in the hub    *
*                   p_global_name: source system global name                   *
* Modification log	:						       *
*			Author		Date		    Change	       *
*			Ankit Goyal	31-May-2007   Initial Creation         *
*	Ankit Goyal	03-Jul-2007   Incorporated pushkala's comments         *
*   viveksha 30-Jan-2009 Updated the procedure to update txn ids *
***************************************************************************** */
PROCEDURE mth_run_log_post_load(p_fact_table IN VARCHAR2,
                                p_db_global_name IN VARCHAR2)

IS

--local variables initialization
l_fact_table mth_run_log.fact_table%TYPE;--fact table
l_sysdate DATE := sysdate;--variable for sysdate
l_last_update_system_id mth_run_log.last_update_system_id%TYPE;
l_last_update_date mth_run_log.last_update_date%TYPE;
l_system_fk_key mth_systems_setup.system_pk_key%TYPE;
l_to_date mth_run_log.to_date%TYPE;--variable for storing to_date
l_from_date mth_run_log.from_date%TYPE;--variable for storing from_date
l_ebs_organization_id mth_run_log.ebs_organization_id%TYPE;
--Hub organization code
l_hub_organization_code mth_run_log.hub_organization_code%TYPE;
--TXN IDS
l_to_txn_id mth_run_log.to_txn_id%TYPE;
l_from_txn_id mth_run_log.from_txn_id%TYPE;

--cursor for iterating through the ebs organizations in mth_plants_d
--the rows in the mth_run_log will be at organization granularity

CURSOR c_ebs_orgs
IS
SELECT ebs_organization_id,system_fk_key
FROM mth_plants_d, mth_systems_setup,mth_organizations_l
WHERE system_pk_key = system_fk_key
AND system_pk = p_db_global_name
AND NVL(to_date,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)--pick active plants only
AND plant_fk_key=plant_pk_key;


BEGIN

  --initialize the varialbles common to the initial and incremental
  -- loading

  l_fact_table := p_fact_table;
  l_last_update_system_id := -99999;
  l_last_update_date := l_sysdate;
  --iterate through the cursor

    /* The to_date for all organizations populated for a given fact and system are bound to be the same because
       all organizations are populated with sysdate(source or target) as the to_date. So giving a generic update command here would work */

    SELECT min(to_date) --min is to avoid getting duplicate rows
    INTO l_from_date--from date set to previous to_date
    FROM mth_run_log
    WHERE fact_table = l_fact_table
    AND db_global_name = p_db_global_name;

         --select the next starting txn id into l_from_txn_id
    SELECT MIN(to_txn_id)
    INTO l_from_txn_id--from txn id to be set to previous to txn id
    FROM mth_run_log
    WHERE fact_table = l_fact_table
    AND db_global_name = p_db_global_name;


    --if statement to restrict the accidental re run of the block
    IF l_from_date IS NOT NULL THEN
    --update the mth run log for next incremental run

    UPDATE mth_run_log
    SET from_date = l_from_date,--from date set to previous to_date
    to_date = NULL,--to_date set to null for next run
    last_update_date = l_last_update_date,
    from_txn_id = l_from_txn_id, -- from txn id set to previous to txn id
    to_txn_id = NULL
    Where fact_table = l_fact_table
    AND db_global_name =  p_db_global_name;

    END IF;



  /*
  FOR l_orgs IN c_ebs_orgs
  LOOP
    --initialize the variables for current cursor value
    l_ebs_organization_id := l_orgs.ebs_organization_id;


    --select the next starting date into l_from_date
    SELECT to_date
    INTO l_from_date--from date set to previous to_date
    FROM mth_run_log
    WHERE fact_table = l_fact_table
    AND db_global_name = p_db_global_name
    AND ebs_organization_id = l_ebs_organization_id;




    --if statement to restrict the accidental re run of the block
    IF l_from_date IS NOT NULL THEN
    --update the mth run log for next incremental run

    UPDATE mth_run_log
    SET from_date = l_from_date,--from date set to previous to_date
    to_date = NULL,--to_date set to null for next run
    from_txn_id = l_from_txn_id, -- from txn id set to previous to txn id
    to_txn_id = NULL,
    last_update_date = l_last_update_date
    Where fact_table = l_fact_table
    AND ebs_organization_id = l_ebs_organization_id
    AND db_global_name =  p_db_global_name;

    END IF;

  END LOOP;
*/

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');
END mth_run_log_post_load;


/* *****************************************************************************
* Procedure		:MTH_HRCHY_BALANCE_LOAD                                *
* Description 	 	:This procedure is used for the balancing of the       *
* hierarchy. The algorithm used for the balancing is down balancing 	       *
* Please refer to the Item fdd for more details on this.                       *
* File Name	 	:MTHUTILS.PLS			                       *
* Visibility		:Public			       		               *
* Parameters	 	:fact table name		                       *
* Modification log	:		                                       *
*			Author		Date			Change	       *
*	Ankit Goyal	17-Aug-2007	Initial Creation                       *
****************************************************************************** */
PROCEDURE mth_hrchy_balance_load(p_fact_table IN VARCHAR2) is

v_fact_table VARCHAR2(120);

--user defined type for array of records
TYPE denorm_rec_tab_type IS TABLE OF NUMBER;
TYPE denorm_rec_name_tab_type IS TABLE OF VARCHAR2(240);

--user defined type of record of arrays
TYPE denorm_rec_type IS RECORD (level9_fk_key denorm_rec_tab_type,
hierarchy_id denorm_rec_tab_type,
baselevel_fk_key denorm_rec_tab_type,
level7_fk_key denorm_rec_tab_type,
level6_fk_key denorm_rec_tab_type,
level5_fk_key denorm_rec_tab_type,
level4_fk_key denorm_rec_tab_type,
level3_fk_key denorm_rec_tab_type,
level2_fk_key denorm_rec_tab_type,
level1_fk_key denorm_rec_tab_type,
level9_name denorm_rec_name_tab_type,
level7_name denorm_rec_name_tab_type,
level6_name denorm_rec_name_tab_type,
level5_name denorm_rec_name_tab_type,
level4_name denorm_rec_name_tab_type,
level3_name denorm_rec_name_tab_type,
level2_name denorm_rec_name_tab_type,
level1_name denorm_rec_name_tab_type
);

--instantiation of the user defined type
--this will be the placeholder for the records fetched from the denorm table
denorm_rec denorm_rec_type;

--user defined cursor to hold the bulk collection of records
item_cur SYS_REFCURSOR;

--variable for the limit of the bulk collection
v_limit NUMBER :=5000;


BEGIN

--initialize the collection
denorm_rec := NULL;

--initialize the fact table name
v_fact_table :=p_fact_table;

--open the cursor
OPEN item_cur FOR 'SELECT     --select for the newe levels
        level9_fk_key,hierarchy_id,item_fk_key,
        Decode(diff_level,1,level8_fk_key,level9_fk_key) level7_fk_key_new,
        Decode(diff_level,1,level7_fk_key,2,level8_fk_key,level9_fk_key)
        level6_fk_key_new,
        Decode(diff_level,1,level6_fk_key,2,level7_fk_key,3,level8_fk_key,
        level9_fk_key) level5_fk_key_new,
        Decode(diff_level,1,level5_fk_key,2,level6_fk_key,3,level7_fk_key,4,
        level8_fk_key,level9_fk_key) level4_fk_key_new,
        Decode(diff_level,1,level4_fk_key,2,level5_fk_key,3,level6_fk_key,4,
        level7_fk_key,5,level8_fk_key,level9_fk_key) level3_fk_key_new,
        Decode(diff_level,1,level3_fk_key,2,level4_fk_key,3,level5_fk_key,4,
        level6_fk_key,5,level7_fk_key,6,level8_fk_key,level9_fk_key)
        level2_fk_key_new,
        Decode(diff_level,1,level2_fk_key,2,level3_fk_key,3,level4_fk_key,4,
        level5_fk_key,5,level6_fk_key,6,level7_fk_key,7,level8_fk_key,
        level9_fk_key) level1_fk_key_new,
        level9_name,
        Decode(diff_level,1,level8_name,level9_name) level7_name_new,
        Decode(diff_level,1,level7_name,2,level8_name,level9_name)
        level6_name_new,
        Decode(diff_level,1,level6_name,2,level7_name,3,level8_name,
        level9_name) level5_name_new,
        Decode(diff_level,1,level5_name,2,level6_name,3,level7_name,4,
        level8_name,level9_name) level4_name_new,
        Decode(diff_level,1,level4_name,2,level5_name,3,level6_name,4,
        level7_name,5,level8_name,level9_name) level3_name_new,
        Decode(diff_level,1,level3_name,2,level4_name,3,level5_name,4,
        level6_name,5,level7_name,6,level8_name,level9_name)
        level2_name_new,
        Decode(diff_level,1,level2_name,2,level3_name,3,level4_name,4,
        level5_name,5,level6_name,6,level7_name,7,level8_name,
        level9_name) level1_name_new
    from
        (--select the levels to be balanced
        SELECT hierarchy_id ,item_fk_key,
        level9_fk_key,level8_fk_key,level7_fk_key,level6_fk_key,
        level5_fk_key,level4_fk_key,level3_fk_key,level2_fk_key,
        level1_fk_key,
        level9_name,level8_name,level7_name,level6_name,
        level5_name,level4_name,level3_name,level2_name,
        level1_name,
        max_level-c_level diff_level
        FROM
          (
              SELECT hierarchy_id ,item_fk_key,
              level9_fk_key,level8_fk_key,level7_fk_key,level6_fk_key,
              level5_fk_key,level4_fk_key,level3_fk_key,level2_fk_key,
              level1_fk_key,
              level9_name,level8_name,level7_name,level6_name,
              level5_name,level4_name,level3_name,level2_name,
              level1_name,
              decode(level9_fk_key,NULL,0,1) +
              decode(level8_fk_key,NULL,0,1) +
              decode(level7_fk_key,NULL,0,1) +
              decode(level6_fk_key,NULL,0,1) +
              decode(level5_fk_key,NULL,0,1) +
              decode(level4_fk_key,NULL,0,1) +
              decode(level3_fk_key,NULL,0,1) +
              decode(level2_fk_key,NULL,0,1) +
              decode(level1_fk_key,NULL,0,1) c_level,--current level
              Max(decode(level9_fk_key,NULL,0,1) +
              decode(level8_fk_key,NULL,0,1) +
              decode(level7_fk_key,NULL,0,1) +
              decode(level6_fk_key,NULL,0,1) +
              decode(level5_fk_key,NULL,0,1) +
              decode(level4_fk_key,NULL,0,1) +
              decode(level3_fk_key,NULL,0,1) +
              decode(level2_fk_key,NULL,0,1) +
              decode(level1_fk_key,NULL,0,1)) over(PARTITION BY hierarchy_id)
              max_level--maximum level in the hierarchy
              FROM mth_item_denorm_d
              WHERE item_fk_key != MTH_UTIL_PKG.MTH_UA_GET_VAL
          )
          WHERE c_level<max_level
	  AND level9_fk_key IS NOT NULL
        )';
      LOOP
	    --fetch the rows in in cursor. Bulk collect
            FETCH item_cur BULK COLLECT INTO denorm_rec.level9_fk_key,
            denorm_rec.hierarchy_id,
            denorm_rec.baselevel_fk_key,denorm_rec.level7_fk_key,
		denorm_rec.level6_fk_key,
            denorm_rec.level5_fk_key,denorm_rec.level4_fk_key,
            denorm_rec.level3_fk_key,denorm_rec.level2_fk_key,
		denorm_rec.level1_fk_key,
            denorm_rec.level9_name,
            denorm_rec.level7_name,
	    denorm_rec.level6_name,
            denorm_rec.level5_name,
            denorm_rec.level4_name,
            denorm_rec.level3_name,
            denorm_rec.level2_name,
	    denorm_rec.level1_name
            LIMIT v_limit;

  	    --terminating condition
            EXIT WHEN denorm_rec.baselevel_fk_key.count =0;

	    --bulk update using forall
            FORALL i IN
	denorm_rec.baselevel_fk_key.first..denorm_rec.baselevel_fk_key.last
                UPDATE mth_item_denorm_d
                SET
                  level8_fk_key = denorm_rec.level9_fk_key(i),
                  level7_fk_key = denorm_rec.level7_fk_key(i),
                  level6_fk_key = denorm_rec.level6_fk_key(i),
                  level5_fk_key = denorm_rec.level5_fk_key(i),
                  level4_fk_key = denorm_rec.level4_fk_key(i),
                  level3_fk_key = denorm_rec.level3_fk_key(i),
                  level2_fk_key = denorm_rec.level2_fk_key(i),
                  level1_fk_key = denorm_rec.level1_fk_key(i),
                  level8_name   = denorm_rec.level9_name(i),
                  level7_name   = denorm_rec.level7_name(i),
                  level6_name   = denorm_rec.level6_name(i),
                  level5_name   = denorm_rec.level5_name(i),
                  level4_name   = denorm_rec.level4_name(i),
                  level3_name   = denorm_rec.level3_name(i),
                  level2_name   = denorm_rec.level2_name(i),
                  level1_name   = denorm_rec.level1_name(i)
                WHERE
                  item_fk_key = denorm_rec.baselevel_fk_key(i)
                  AND hierarchy_id= denorm_rec.hierarchy_id(i);
END LOOP;
--close the cursor
CLOSE item_cur;

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_hrchy_balance_load ;


/* *****************************************************************************
* Procedure		:MTH_TRUNCATE_TABLE	                               *
* Description 	 	:This procedure is used to truncate the table in the   *
* MTH Schema. Thsi can be overriden by spefying a custom schema name as well.  *
* File Name	 	:MTHUTILS.PLS		             		       *
* Visibility		:Public                				       *
* Parameters	 	:Table name  		                               *
* Modification log	:						       *
*			Author		Date			Change	       *
*			Ankit Goyal	11-Oct-2007	Initial Creation       *
***************************************************************************** */

PROCEDURE mth_truncate_table(p_table_name IN VARCHAR2) IS

--initialize variables here
v_stmt VARCHAR2(2000);
v_schema_name VARCHAR2(100);
v_status      VARCHAR2(30) ;
v_industry    VARCHAR2(30) ;

-- main body
BEGIN
IF (FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'MTH'
            , status                 => v_status
            , industry               => v_industry
            , oracle_schema          => v_schema_name))
THEN
--Prepare the truncate statement using schema name and table name
  v_stmt := 'TRUNCATE TABLE '||v_schema_name||'.'||p_table_name;
  EXECUTE IMMEDIATE v_stmt;
END IF;

END mth_truncate_table;

/* *****************************************************************************
* Procedure		:MTH_TRUNCATE_TABLE	                               *
* Description 	 	:This procedure is used to truncate the table in the   *
*                        specified schema.                                     *
* File Name	 	:MTHUTILS.PLS		             		       *
* Visibility		:Public                				       *
* Parameters	 	:Table name                                            *
*                        Schema name                                           *
* Modification log	:						       *
*			Author		Date			Change	       *
*			Yong Feng	July 18, 2008	Initial Creation       *
***************************************************************************** */

PROCEDURE mth_truncate_table(p_table_name IN VARCHAR2,
                             p_schema_name IN VARCHAR2) IS
--initialize variables here
v_stmt VARCHAR2(2000);

BEGIN
  --Prepare the truncate statement using schema name and table name
  v_stmt := 'TRUNCATE TABLE '||p_schema_name||'.'||p_table_name;
  EXECUTE IMMEDIATE v_stmt;

END mth_truncate_table;

/* ****************************************************************************
* Procedure             :MTH_TRUNCATE_TABLES                                  *
* Description           :This procedure is used to truncate the tables in the *
*                        list separated by comma.                             *
* File Name             :MTHUTILS.PLS                                         *
* Visibility            :Public                                               *
* Parameters            :p_list_table_names: List of table names separated    *
*                        by commas.                                           *
*                       :p_schema_name: The schema name for all listed tables.*
* Modification log      :                                                     *
*                       Author          Date                    Change        *
*                       Yong Feng       Aug-07-2008     Initial Creation      *
**************************************************************************** */

PROCEDURE mth_truncate_tables(p_list_table_names IN VARCHAR2) IS
  -- Index to identify the beginning of a table name in the list
  v_bidx number := 1;
  -- Index to identify the ending of a table name in the list
  v_eidx number;
  v_has_schema_name BOOLEAN;
  v_table_name varchar2(30);
  v_user_name varchar2(30);
  v_status      VARCHAR2(30) ;
  v_industry    VARCHAR2(30) ;
  v_mth_name varchar2(30);
  v_schema_name varchar2(30);
  v_list_length number;
  cursor getSchema (p_table_name in varchar2,
                    p_owner1 in varchar2,
                    p_owner2 in varchar2) is
  SELECT owner
  FROM ALL_TABLES
  WHERE table_name = p_table_name
  AND owner in (p_owner1, p_owner2);

BEGIN
  IF p_list_table_names IS NULL OR LENGTH(p_list_table_names) = 0 THEN
    RETURN;
  END IF;

  v_user_name :=user;

  IF (NOT FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'MTH'
            , status                 => v_status
            , industry               => v_industry
            , oracle_schema          => v_mth_name)) THEN
       RAISE_APPLICATION_ERROR (-20001,
        'Could not find MTH product.');
  END IF;

  v_list_length := LENGTH(p_list_table_names);

  -- Parse the list of table name and truncate each table
  v_eidx := INSTR(p_list_table_names, ',', v_bidx);

  -- Handle the case where there is only one element in the list
  IF (v_eidx = 0 AND v_bidx <= v_list_length) THEN
    v_eidx := v_list_length + 1;
  END IF;

  WHILE (v_eidx > 0 AND v_eidx > v_bidx) LOOP
    v_table_name := SUBSTR(p_list_table_names, v_bidx, (v_eidx - v_bidx));
    v_table_name := UPPER(TRIM(BOTH FROM v_table_name));

    -- Get the schema name for that table
    IF v_table_name IS NOT NULL AND LENGTH(v_table_name) > 0 THEN
      OPEN getSchema ( v_table_name, v_user_name, v_mth_name);
      FETCH getSchema INTO v_schema_name;
      IF (getSchema%FOUND) THEN
        MTH_TRUNCATE_TABLE(v_table_name, v_schema_name);
        CLOSE getSchema;
      ELSE
        CLOSE getSchema;
        RAISE_APPLICATION_ERROR (-20001,
          'Could not find table ' || v_table_name || ' in either ' || v_user_name || ' or ' || v_mth_name || '.');
      END IF;
    END IF;
    v_bidx := v_eidx + 1;
    v_eidx := INSTR(p_list_table_names, ',', v_bidx);
    -- Handle the case for end of the list
    IF (v_eidx = 0 AND v_bidx <= v_list_length) THEN
      v_eidx := v_list_length + 1;
    END IF;
  END LOOP;
END mth_truncate_tables;



/* ****************************************************************************
* Procedure             :MTH_TRUNCATE_MV_LOGS                                 *
* Description           :This procedure is used to truncate the Materialized  *
*                        View log created on the tables                       *
*                        list separated by comma.                             *
* File Name             :MTHUTILS.PLS                                         *
* Visibility            :Public                                               *
* Parameters            :p_list_table_names: List of table names separated    *
*                        by commas.                                           *
* Modification log      :                                                     *
*                       Author          Date                    Change        *
*                       Yong Feng       Aug-07-2008     Initial Creation      *
**************************************************************************** */

PROCEDURE MTH_TRUNCATE_MV_LOGS (p_list_table_names IN VARCHAR2) IS
  -- Index to identify the beginning of a table name in the list
  v_bidx number := 1;
  -- Index to identify the ending of a table name in the list
  v_eidx number;
  v_has_schema_name BOOLEAN;
  v_table_name varchar2(30);
  v_user_name varchar2(30);
  v_status      VARCHAR2(30) ;
  v_industry    VARCHAR2(30) ;
  v_mth_name varchar2(30);
  v_log_owner varchar2(30);
  v_log_table varchar2(30);
  v_list_length number;
  cursor getLogTableSchema (p_table_name in varchar2,
                            p_owner1 in varchar2,
                            p_owner2 in varchar2) is
  SELECT log_owner, log_table
  FROM ALL_SNAPSHOT_LOGS
  WHERE master = p_table_name
  AND log_owner in (p_owner1, p_owner2);

BEGIN
  IF p_list_table_names IS NULL OR LENGTH(p_list_table_names) = 0 THEN
    RETURN;
  END IF;

  v_user_name :=user;

  IF (NOT FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'MTH'
            , status                 => v_status
            , industry               => v_industry
            , oracle_schema          => v_mth_name)) THEN
       RAISE_APPLICATION_ERROR (-20001,
        'Could not find MTH product.');
  END IF;

  v_list_length := LENGTH(p_list_table_names);

  -- Parse the list of table name and truncate each table
  v_eidx := INSTR(p_list_table_names, ',', v_bidx);

  -- Handle the case where there is only one element in the list
  IF (v_eidx = 0 AND v_bidx <= v_list_length) THEN
    v_eidx := v_list_length + 1;
  END IF;

  WHILE (v_eidx > 0 AND v_eidx > v_bidx) LOOP
    v_table_name := SUBSTR(p_list_table_names, v_bidx, (v_eidx - v_bidx));
    v_table_name := UPPER(TRIM(BOTH FROM v_table_name));

    -- Get the mv log name and schema name for that table
    IF v_table_name IS NOT NULL AND LENGTH(v_table_name) > 0 THEN
      OPEN getLogTableSchema ( v_table_name, v_user_name, v_mth_name);
      FETCH getLogTableSchema INTO v_log_owner, v_log_table;
      IF (getLogTableSchema%FOUND) THEN
        MTH_TRUNCATE_TABLE(v_log_table, v_log_owner);
        CLOSE getLogTableSchema ;
      ELSE
        CLOSE getLogTableSchema;
        RAISE_APPLICATION_ERROR (-20001,
          'Could not find Materialized View Log on table ' || v_table_name || ' in either ' || v_user_name || ' or ' || v_mth_name || '.');
      END IF;
    END IF;
    v_bidx := v_eidx + 1;
    v_eidx := INSTR(p_list_table_names, ',', v_bidx);
    -- Handle the case for end of the list
    IF (v_eidx = 0 AND v_bidx <= v_list_length) THEN
      v_eidx := v_list_length + 1;
    END IF;
  END LOOP;
END MTH_TRUNCATE_MV_LOGS;




/* *****************************************************************************
* Function		:MTH_UA_GET_VAL	   			      	       *
* Description 	 	: This procedure is used to return the lookup code for *
* the unasssigned							       *
* File Name	 	:MTHUTILS.PLS		             		       *
* Visibility		:Public                				       *
* Parameters	 	:None                               	               *
* Return Value		:v_lookup_code : Unassigned lookup code value          *
* Modification log	:						       *
*			Author		Date			Change         *
*	Ankit Goyal	11-Oct-2007	Initial Creation                       *
***************************************************************************** */

Function mth_ua_get_val RETURN NUMBER IS
v_lookup_code varchar2(30);
BEGIN
--NULL
  SELECT lookup_code INTO v_lookup_code FROM FND_LOOKUP_VALUES  WHERE
    lookup_type='MTH_UNASSIGNED_L' AND language=userenv('LANG');

  RETURN(to_number(v_lookup_code));

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_ua_get_val;



/* *****************************************************************************
* Function		:MTH_UA_GET_MEANING			               *
* Description 	 	:This procedure is used to return the lookup meaning   *
* for the unasssigned			                                       *
* File Name	 	:MTHUTILS.PLS				               *
* Visibility		:Public			                               *
* Parameters	 	:None                          	                       *
* Return Value		:v_lookup_code : Unassigned lookup code value          *
* Modification log	:	                                               *
*			Author		Date			Change         *
*			Ankit Goyal	23-Oct-2007	Initial Creation       *
***************************************************************************** */

Function mth_ua_get_meaning RETURN VARCHAR2 IS
v_lookup_meaning varchar2(80);
BEGIN
--NULL
  SELECT meaning INTO v_lookup_meaning FROM FND_LOOKUP_VALUES  WHERE
    lookup_type='MTH_UNASSIGNED_L' AND language=userenv('LANG');

  RETURN(v_lookup_meaning);

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_ua_get_meaning;

/* ****************************************************************************
* Procedure		:request_lock	          	                      *
* Description 	 	:This procedure is used to request an exclusive       *
*    lock with p_key_table as the key using rdbms_lock package. The current   *
*    will wait indifinitely if the lock was held by others until the release  *
*    of the lock.                                                             *
* File Name	        :MTHUTILB.PLS	                       	   	      *
* Visibility	        :Private                          	              *
* Parameters	 	                              	                      *
*    p_key_table        : The name used to request an exclusive lock.         *
*    p_retval           : The return value of the operation:                  *
*                           0 - Success           			      *
*	                          1 - Timeout    			      *
*	                          2 - Deadlock    			      *
*	                          3 - Parameter Error    		      *
*	                          4 - Already owned    			      *
*	                          5 - Illegal Lock Handle    		      *
* Modification log	:					              *
*		           Author	Date	Change	                      *
*			   Yong Feng	17-Oct-2007	Initial Creation      *
**************************************************************************** */
PROCEDURE request_lock(p_key_table IN VARCHAR2, p_retval OUT NOCOPY INTEGER)
IS
  v_lockhandle VARCHAR2(200);
BEGIN
  dbms_lock.allocate_unique(p_key_table, v_lockhandle);
  p_retval := dbms_lock.request(v_lockhandle, dbms_lock.x_mode);
END request_lock;

/* ****************************************************************************
* Procedure		:generate_new_time_range	                      *
* Description 	 	:This procedure is used to generate a time range      *
*    starting from the last end date up to current time, sysdate, using       *
*    the p_key_table name as the key to look up the entry in mth_run_log      *
*    table. If the entry does not exist, create one and set the time range    *
*    to a hard-coded past time to current time.                               *
* File Name	 	:MTHUTILB.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	                                                      *
*    p_key_table        : Name to uniquely identify one entry in the          *
*                         mth_run_log table.                                  *
*    p_start_date       : An output value that specifies the start time       *
*                         of the new time period.                             *
*    p_end_date         : An output value that specifies the end time         *
*                         of the new time period.                             *
*    p_exclusive_lock   : Specify whether it needs to request an exclusive    *
*                         lock using p_key_table as the key so that only      *
*                         one procedure will be running at one point of time. *
*                         If the value is 1, then it will run in exclusive    *
*                         mode. The lock will be released when the            *
*                         transaction is either committed or rollbacked.      *
* Modification log	:					              *
*			Author		Date			Change        *
*			Yong Feng	17-Oct-2007	Initial Creation      *
**************************************************************************** */
PROCEDURE generate_new_time_range(p_key_table IN VARCHAR2,
                                  p_start_date OUT NOCOPY DATE,
                                  p_end_date OUT NOCOPY DATE,
                                  p_exclusive_lock IN NUMBER DEFAULT 1)
IS
  v_from_date mth_run_log.from_date%TYPE;
  v_to_date mth_run_log.to_date%TYPE;
  v_is_new_entry BOOLEAN := FALSE;
  v_default_start_date DATE := to_date('1950', 'YYYY');
  v_sysdate DATE := sysdate;
  v_retval number := 0;

  CURSOR c_lookup IS
      SELECT to_date
      FROM   mth_run_log
      WHERE  fact_table = p_key_table and rownum=1;
BEGIN
  -- 1. Validate the p_fact_table input value.
  IF (p_key_table is not null) THEN

    -- 2. Check to see if we need to request an exclusive lock.
    -- It will wait infinitively if it cannot get the lock.
    -- Do not request lock any more for the mappinging. Request one
    -- for the process flow instead.
    --IF p_exclusive_lock = 1 THEN
    --  request_lock(p_key_table, v_retval);
    --END IF;

    --IF v_retval = 0 THEN

      -- 3. Do the look up
      open c_lookup;
      fetch c_lookup into v_to_date;
      IF c_lookup%NOTFOUND THEN
        v_is_new_entry := TRUE;
      END IF;
      close c_lookup;

      v_from_date := v_to_date;
      v_to_date := v_sysdate;

      -- 4. Create a new entry if not exist. Otherwise, update the entry
      IF v_is_new_entry THEN
        v_from_date := v_default_start_date;
        INSERT INTO mth_run_log
          (fact_table, ebs_organization_id, ebs_organization_code, from_date,
           to_date, source, db_global_name, creation_date, last_update_date,
           creation_system_id, last_update_system_id, plant_start_date)
        VALUES
          (p_key_table, -1, '-1', v_from_date,
           v_to_date, -1, '-99999', v_sysdate, v_sysdate,
           -1, -1, v_default_start_date);
      ELSE
        UPDATE mth_run_log
          SET TO_DATE = v_to_date,
              FROM_DATE = v_from_date,
              LAST_UPDATE_DATE = v_sysdate
          WHERE
              fact_table = p_key_table;
      END IF;

      -- 5. Set the output variables
      p_start_date := v_from_date;
      p_end_date := v_to_date;
    --END IF;
  END IF;
END generate_new_time_range;



/* *****************************************************************************
* Function		:GET_PROFILE_VAL  		       	               *
* Description 	 	:This function is used to retrive the value of the     *
* 			 profile for the profile name provided by the user     *
* File Name	 	:MTHSOURCEPATCHS.PLS	             		       *
* Visibility		:Public                				       *
* Return	 	: V_PROFILE_NAME - Global name of the source DB        *
* Modification log	:				                       *
*			Author		Date		    Change	       *
*			Ankit Goyal	29-Oct-2007	Initial Creation       *
******************************************************************************/
FUNCTION get_profile_val(p_profile_name IN VARCHAR2) RETURN VARCHAR2
IS
--local variable declation
v_profile_value varchar2(120);

v_uid number := -1;
v_rid number := -1;
v_applid number := 1;

BEGIN

--Initialize the session for default values -1.
/* fnd_global.apps_initialize(v_uid, v_rid, v_applid); */

--select the value of the profile into the local variable.
select fnd_profile.value(p_profile_name) into v_profile_value from dual;

--Return the value.
RETURN(v_profile_value);

--End the function
END;

/* ****************************************************************************
* Function		:Get_UDA_Eq_HId  	                              *
* Description 	 	:This function is used to retrive the hierarchy id of *
*			the UDA Equipment profile			      *
* File Name	 	:MTHUTILS.PLS	                   		      *
* Visibility		:Public                				      *
* Return	 	:Hierarchy id for the equipment UDA profile           *
* Modification log	:						      *
*			Author		Date		    Change	      *
*			Vivek		18-Jan-2008	Initial Creation      *
******************************************************************************/

FUNCTION Get_UDA_Eq_HId  RETURN VARCHAR IS

v_profile VARCHAR2(6);
v_pos NUMBER;
v_hId VARCHAR2(3);

BEGIN

-- Get the profile value, it will be of form h_id:level_no
v_profile := FND_PROFILE.VALUE('MTH_UDA_EQUIPMENT_PROFILE');

-- based on the position of :, retrieve h_id
v_pos := INSTR(v_profile,':');
v_hId := SUBSTR(v_profile,1,v_pos-1);

RETURN v_hId;

EXCEPTION
	WHEN OTHERS THEN NULL;
END;

/* ****************************************************************************
* Function		:Get_UDA_Eq_LNo  	                              *
* Description 	 	:This function is used to retrive the Level Number of *
*			the UDA Equipment profile			      *
* File Name	 	:MTHUTILS.PLS	                   		      *
* Visibility		:Public                				      *
* Return	 	:Level Number for the equipment UDA profile           *
* Modification log	:						      *
*			Author		Date		    Change	      *
*			Vivek		18-Jan-2008	Initial Creation      *
******************************************************************************/

FUNCTION Get_UDA_Eq_LNo  RETURN VARCHAR IS

v_profile VARCHAR2(6);
v_pos NUMBER;
v_lNo VARCHAR2(3);
v_length NUMBER;

BEGIN

-- Get the profile value, it will be of form h_id:level_no
v_profile := FND_PROFILE.VALUE('MTH_UDA_EQUIPMENT_PROFILE');

-- based on the position of :, retrieve h_id
v_pos := INSTR(v_profile,':');
v_length := LENGTH(v_profile);
v_lNo := SUBSTR(v_profile,v_pos+1,v_length);

RETURN v_lNo;

EXCEPTION
	WHEN OTHERS THEN NULL;
END;

/* ****************************************************************************
* Procedure		:REFRESH_MV	          	                      *
* Description 	 	:This procedure is used to call DBMS_MVIEW.REFRESH    *
*    procedure to refresh MVs.                                                *
* File Name	        :MTHUTILB.PLS			             	      *
* Visibility	        :Public   	                          	      *
* Parameters	 	                              	                      *
*    list               : Comma-separated list of materialized views that     *
*                         you want to refresh.                                *
*    method             :A string of refresh methods indicating how to        *
*                        refresh the listed materialized views.               *
*                        - An f indicates fast refresh                        *
*                        - ? indicates force refresh                          *
*                        - C or c indicates complete refresh                  *
*                        - A or a indicates always refresh. A and C are       *
*                          equivalent.		                              *
*    rollback_seg       :Name of the materialized view site rollback segment  *
*                        to use while refreshing materialized views.          *
*    push_deferred_rpc  : Used by updatable materialized views only.          *
*  refresh_after_errors :                                                     *
*   purge_option        :                                                     *
*   parallelism         : 0 specifies serial propagation                      *
*    heap_size          :                                                     *
*   atomic_refresh      :                                                     *
* Modification log	:						      *
*		         Author		Date		Change	              *
*			 Yong Feng	11-July-2008	Initial Creation      *
**************************************************************************** */
PROCEDURE REFRESH_MV(
   p_list                   IN     VARCHAR2,
   p_method                 IN     VARCHAR2       := NULL,
   p_rollback_seg           IN     VARCHAR2       := NULL,
   p_push_deferred_rpc      IN     BOOLEAN        := true,
   p_refresh_after_errors   IN     BOOLEAN        := false,
   p_purge_option           IN     BINARY_INTEGER := 1,
   p_parallelism            IN     BINARY_INTEGER := 0,
   p_heap_size              IN     BINARY_INTEGER := 0,
   p_atomic_refresh         IN     BOOLEAN        := true
)
IS
BEGIN
  DBMS_MVIEW.REFRESH(p_list, p_method, p_rollback_seg, p_push_deferred_rpc,
                     p_refresh_after_errors, p_purge_option,
                     p_parallelism, p_heap_size, p_atomic_refresh);
END REFRESH_MV;


/* ****************************************************************************
* Procedure		:REFRESH_ONE_MV	          	                              *
* Description 	 	:This procedure is used to call refresh one MV.       *
* File Name	        :MTHUTILB.PLS			             	            *
* Visibility	        :Public   	                          	      *
* Parameters	 	                              	                  *
*    p_mv_name          : Name of the materialized view to be refreshed.      *
*    p_method           :A string of refresh methods indicating how to        *
*                        refresh the listed materialized views.               *
*                        - An f indicates fast refresh                        *
*                        - ? indicates force refresh                          *
*                        - C or c indicates complete refresh                  *
*                        - A or a indicates always refresh. A and C are       *
*                          equivalent.		                              *
*    p_rollback_seg     :Name of the materialized view site rollback segment  *
*                        to use while refreshing materialized views.          *
*    p_refresh_mode     :A string of refresh mode:                            *
*                        - C , c or NULL indicates complete refresh.          *
*                        - R or r indicates resume refresh that has been      *
*                        started earlier. The MV will be refreshed if the     *
*                        refresh date is earlier than the date stored in      *
*                        to_date column in MTH_RUN_LOG for MTH_ALL_MVS entry. *
*   p_push_deferred_rpc : Used by updatable materialized views only.          *
* Modification log	:						                  *
*		         Author		Date		Change	                  *
*			 Yong Feng	19-Aug-2008	 Initial Creation                   *
**************************************************************************** */

PROCEDURE REFRESH_ONE_MV(
   p_mv_name                IN     VARCHAR2,
   p_method                 IN     VARCHAR2       := NULL,
   p_rollback_seg           IN     VARCHAR2       := NULL,
   p_refresh_mode           IN     VARCHAR2       := NULL
)
IS
  v_bneed_refresh BOOLEAN := FALSE;
  v_last_refresh_date DATE;
  v_refresh_date_required  DATE;
  v_unassigned_string VARCHAR2(20) := to_char(mth_util_pkg.mth_ua_get_val);
  v_mv_name varchar2(30);
  cursor getRefreshDate (p_mv_name in varchar2) is
  SELECT last_refresh_date
  FROM user_mviews
  WHERE mview_name = p_mv_name;
BEGIN
  v_mv_name := UPPER(TRIM(p_mv_name));
  IF v_mv_name IS NULL OR LENGTH(v_mv_name) = 0 THEN
    RETURN;
  END IF;

  -- Check whether the MV needs to be refreshed
  IF (p_refresh_mode IS NULL OR upper(p_refresh_mode) <> 'R') THEN
    -- Need to refresh in mode C
    v_bneed_refresh := TRUE;
  ELSE
    -- It is a resume operation
    -- First, find the refresh date in MTH_RUN_LOG in resume case
    SELECT max(to_date) into v_refresh_date_required
      FROM mth_run_log
      WHERE fact_table = 'MTH_ALL_MVS' AND db_global_name = v_unassigned_string;
    IF (v_refresh_date_required IS NULL) THEN
      -- Refresh the MV if there is no entry found in MTH_RUN_LOG
      v_bneed_refresh := TRUE;
    ELSE
      -- First get the last refresh date of the MV
      -- Then, compare the last refresh date of the MV with the date from the MTH_RUN_LOG
      -- to decide whether the MV needs to be refreshed
      OPEN getRefreshDate ( v_mv_name);
      FETCH getRefreshDate INTO v_last_refresh_date;
      IF (getRefreshDate%FOUND) THEN
         v_bneed_refresh := (v_last_refresh_date IS NULL OR v_last_refresh_date <= v_refresh_date_required);
        CLOSE getRefreshDate ;
      ELSE
        CLOSE getRefreshDate ;
        RAISE_APPLICATION_ERROR (-20001,
          'Could not find Materialized View ' || v_mv_name || '.');
      END IF;
    END IF;
  END IF;

  IF v_bneed_refresh THEN
    DBMS_MVIEW.REFRESH(v_mv_name, p_method, p_rollback_seg);
  END IF;
END REFRESH_ONE_MV;

/* *****************************************************************************
* Procedure		:PUT_EQUIP_DENORM_LEVEL_NUM	          	       *
* Description 	 	:This procedure is used to insert the level_num column *
*    in the mth_equipment_denorm_d table                                       *
* File Name	        :MTHUTILB.PLS			             	       *
* Visibility	        :Private	                          	       *
* Modification log	:						       *
*		       Author	      	Date	      	Change	               *
*		   shanthi donthu    16-Jul-2008     Initial Creation          *
***************************************************************************** */

PROCEDURE PUT_EQUIP_DENORM_LEVEL_NUM
IS
BEGIN
UPDATE MTH_EQUIPMENT_DENORM_D SET LEVEL_NUM = (
         CASE WHEN EQUIPMENT_FK_KEY IS NOT NULL THEN 10
         ELSE CASE WHEN LEVEL9_LEVEL_KEY IS NOT NULL THEN 9
         ELSE CASE WHEN LEVEL8_LEVEL_KEY IS NOT NULL THEN 8
         ELSE CASE WHEN LEVEL7_LEVEL_KEY IS NOT NULL THEN 7
         ELSE CASE WHEN LEVEL6_LEVEL_KEY IS NOT NULL THEN 6
         ELSE CASE WHEN LEVEL5_LEVEL_KEY IS NOT NULL THEN 5
         ELSE CASE WHEN LEVEL4_LEVEL_KEY IS NOT NULL THEN 4
         ELSE CASE WHEN LEVEL3_LEVEL_KEY IS NOT NULL THEN 3
         ELSE CASE WHEN LEVEL2_LEVEL_KEY IS NOT NULL THEN 2
         ELSE CASE WHEN LEVEL1_LEVEL_KEY IS NOT NULL THEN 1
         END
         END
         END
         END
         END
         END
         END
         END
         END
         END )
WHERE LEVEL_NUM IS NULL;

END PUT_EQUIP_DENORM_LEVEL_NUM;

/* *****************************************************************************
* Procedure     :update_equip_hrchy_gid                                        *
* Description    :This procedue is used for updating the group_id column in    *
* the mth_equip_hierarchy table. The group id will be used to determine the    *
* sequence in which a particular record will be processed in the equipment SCD *
* logic. The oldest relationships will have the lowest group id =1 and the new *
* relationships will have higher group id. All the catch all relationships i.e.*
* the relationship with parent = -99999 and effective date = 1-Jan-1900 will   *
* have group id defaulted to 1 inside the MTH_EQUIP_HRCHY_UA_ALL_MAP map.      *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       : none                                                      *
* Modification log :                                                           *
* Author Date Change                                                           *
* Ankit Goyal 26-Aug-2008 Initial Creation                                     *
***************************************************************************** */
PROCEDURE update_equip_hrchy_gid
IS
  /*variable to track # of conlficting rows*/
  l_max_gid NUMBER := 0;
  /*variable to get current maximum group id*/
  l_new_rows NUMBER := 0;
  v_new_ed DATE ;
  /*Variable to track the numnber of new rows */
  /*This cursor will fetch the number of rows that are in conflict. The rows
  are said to be in conflict when the incoming new rows have effective date
  less than the effective date of the current rows. This implies that the
  existing rows need to be processed after the new rows. This cursor fetches
  those rows and then logic in the program will manipulate those rows
  and increase theor group id.*/
  CURSOR cr_conflict_rows
  IS
     SELECT old_rows.hierarchy_id,
      old_rows.level_num         ,
      old_rows.group_id          ,
      old_rows.level_fk_key      ,
      old_rows.effective_date
       FROM
      (SELECT hierarchy_id           ,
        level_fk_key                 ,
        level_num                    ,
        effective_date effective_date,
        group_id
         FROM mth_equip_hierarchy
        WHERE group_id > 1
        /*group_id==1 are catch all rows.  */
     GROUP BY hierarchy_id,
        level_fk_key      ,
        level_num         ,
        group_id          ,
        effective_date
      ) old_rows        ,
    (SELECT hierarchy_id,
      level_fk_key      ,
      level_num         ,
      effective_date    ,
      parent_fk_key
       FROM mth_equip_hierarchy
      WHERE group_id IS NULL
    ) new_rows
    /*new relationships with group id as null */
    WHERE old_rows.hierarchy_id = new_rows.hierarchy_id
  AND old_rows.level_fk_key     = new_rows.level_fk_key
  AND old_rows.level_num        = new_rows.level_num
  AND old_rows.effective_date   > new_rows.effective_date;
  /*The effective date comparison will tell us if there are conflits */
  /*This cursor fetches the row among the conflict rows with the minimum
  effective date.This tells us all the rows that will need to be updated so
  that they are processed in the correct groups*/
  CURSOR cr_aggr_conflict_rows(p_effective_date IN date,p_hierarchy_id IN number,p_level_fk_key IN number,p_level_num IN number)
  IS
     SELECT new_ed FROM (
     SELECT old_rows.hierarchy_id    ,
      old_rows.level_num             ,
      MIN(old_rows.group_id) group_id,
      /*to skip group by */
      old_rows.level_fk_key                      ,
      MIN(old_rows.effective_date) effective_date,
      /*effecitve date of the old row */
      new_rows.effective_date new_ed
      /*effecitve date of the new row */
       FROM
      (SELECT hierarchy_id           ,
        level_fk_key                 ,
        level_num                    ,
        effective_date effective_date,
        group_id
         FROM mth_equip_hierarchy
        WHERE group_id > 1
        /*group_id==1 are catch all rows. */
      ) old_rows        ,
    (SELECT hierarchy_id,
      level_fk_key      ,
      level_num         ,
      effective_date    ,
      parent_fk_key
       FROM mth_equip_hierarchy
      WHERE group_id IS NULL
    ) new_rows
    /*new relationships with group id as null */
    WHERE old_rows.hierarchy_id = new_rows.hierarchy_id
  AND old_rows.level_fk_key     = new_rows.level_fk_key
  AND old_rows.level_num        = new_rows.level_num
  AND old_rows.effective_date   > new_rows.effective_date
   GROUP BY old_rows.hierarchy_id,
    old_rows.level_num         ,
    old_rows.level_fk_key      ,
    new_rows.effective_date) c_rows WHERE
  c_rows.effective_date =p_effective_date
  AND c_rows.hierarchy_id = p_hierarchy_id
  AND c_rows.level_fk_key = p_level_fk_key
  AND c_rows.level_num = p_level_num ;
  /*This cursor will fetch all the new rows for which the group id
  assignments have not been done.*/
  CURSOR cr_new_rows
  IS
     SELECT effective_date,
      hierarchy_id        ,
      level_fk_key        ,
      level_num
       FROM mth_equip_hierarchy
      WHERE group_id IS NULL;
BEGIN
    FOR l_rows      IN cr_conflict_rows
    LOOP
      /*All rows in conflict */
    OPEN cr_aggr_conflict_rows(l_rows.effective_date,l_rows.hierarchy_id, l_rows.level_fk_key,l_rows.level_num);
     FETCH cr_aggr_conflict_rows into v_new_ed ;
              /*All aggregated rows in conflict */
        /*This part of the logic deals with updating the group id
        of the new rows. */
        IF(cr_aggr_conflict_rows%FOUND) then
        /*set the group id of the new row equal to the group id of the old
          row which matches the effective date*/
           UPDATE mth_equip_hierarchy
          SET group_id           = l_rows.group_id
            WHERE effective_date = v_new_ed
            /*This is the determining condition */
          AND hierarchy_id = l_rows.hierarchy_id
          AND level_fk_key = l_rows.level_fk_key
          AND level_num    = l_rows.level_num;
        END IF;
     CLOSE  cr_aggr_conflict_rows;
      /*Update the odl rows and increment the group id by 1         */
       UPDATE mth_equip_hierarchy
      SET group_id           = l_rows.group_id + 1
        WHERE effective_date = l_rows.effective_date
      AND hierarchy_id       = l_rows.hierarchy_id
      AND level_fk_key       = l_rows.level_fk_key
      AND level_num          = l_rows.level_num;
    END LOOP;
  /*This part of the logic will update any rows which did not cause a conflict
  with the old rows. This logic is necessary as the data can contain both the
  conflit rows and non conflict rows*/
  /*get the number of new rows remaining to be updated. */
   SELECT COUNT(* )
     INTO l_new_rows
     FROM mth_equip_hierarchy
    WHERE group_id IS NULL;
  IF l_new_rows     > 0 THEN
    /*if new rows found */
    FOR new_rows IN cr_new_rows
    LOOP
       SELECT MAX(group_id)
         INTO l_max_gid
         FROM mth_equip_hierarchy
        WHERE hierarchy_id = new_rows.hierarchy_id
      AND level_fk_key     = new_rows.level_fk_key
      AND level_num        = new_rows.level_num;
    /*update the new rows gorup_id column and set it = group_id of old row + 1*/
       UPDATE mth_equip_hierarchy
      SET group_id         = l_max_gid + 1
        WHERE hierarchy_id = new_rows.hierarchy_id
      AND level_fk_key     = new_rows.level_fk_key
      AND level_num        = new_rows.level_num
      AND effective_date   = new_rows.effective_date;
    END LOOP;
  END IF;
  --handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END update_equip_hrchy_gid;

/* *****************************************************************************
* Function     :get_min_max_gid                                        	       *
* Description    :This finction returns the minimum or maximum group id in the *
* Equipment hierarchy table.                                                   *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       : Mode Number. Mode= 1 Minimum, Mode =2 Maximum             *
* Modification log :                                                           *
* Author Date Change                                                           *
* Ankit Goyal 26-Aug-2008 Initial Creation                                     *
***************************************************************************** */

FUNCTION get_min_max_gid
     (minmax  IN NUMBER)
RETURN NUMBER
IS
  v_minmax  NUMBER := 0;
BEGIN
  IF minmax = 1 THEN
    SELECT MIN(group_id)
    INTO   v_minmax
    FROM   mth_equip_hierarchy;
  ELSE
    SELECT MAX(group_id)
    INTO   v_minmax
    FROM   mth_equip_hierarchy;
  END IF;

  RETURN v_minmax;
END get_min_max_gid;

/* *****************************************************************************
* Procedure     :switch_column_default_value                                   *
* Description    :This procedure will determine the current value of the       *
*  processing_flag of the table, issue an alter table statement to switch      *
*  the default values to another (1 to 2, or 2 to 1,) and return the           *
*  current value. If there are no data in the table, do nothing and return     *
*  0.                                                                          *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       :                                                           *
*         p_table_name:  table name                                            *
*         p_current_processing_flag: the current value of processing_flag      *
*                                    It could be 1, or 2 for normal case.      *
*                                    If it is 0, then no data is available     *
*                                    the table. So no process is needed.       *
* Modification log :                                                           *
* Author Date Change:  Yong Feng 10/2/08 Initial creation                      *
***************************************************************************** */

PROCEDURE switch_column_default_value (
    p_table_name IN VARCHAR2,
    p_current_processing_flag OUT NOCOPY NUMBER)
IS
  v_stmt varchar2(500);
  v_current_value NUMBER;
  v_new_value NUMBER;
  e_wrong_value EXCEPTION;
  v_schema_name VARCHAR2(100);
  v_status      VARCHAR2(30) ;
  v_industry    VARCHAR2(30) ;
BEGIN
  IF p_table_name IS NULL OR LENGTH(p_table_name) = 0 THEN
    RETURN;
  END IF;

  IF (NOT FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'MTH'
            , status                 => v_status
            , industry               => v_industry
            , oracle_schema          => v_schema_name)) THEN
       RAISE_APPLICATION_ERROR (-20002,
        'Could not find MTH product.');
  END IF;

  v_stmt := 'SELECT processing_flag FROM ' ||
            v_schema_name || '.' || p_table_name ||
            ' WHERE rownum < 2';
  EXECUTE IMMEDIATE v_stmt INTO v_current_value;

  IF v_current_value = 1 THEN
    v_new_value := 2;
  ELSIF v_current_value = 2 THEN
    v_new_value := 1;
  ELSE RAISE e_wrong_value;
  END IF;

  v_stmt := 'ALTER TABLE ' || v_schema_name || '.' || p_table_name ||
            ' MODIFY PROCESSING_FLAG DEFAULT ' || v_new_value;
  EXECUTE IMMEDIATE v_stmt;
  p_current_processing_flag := v_current_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_current_processing_flag := 0;
  WHEN e_wrong_value THEN
   RAISE_APPLICATION_ERROR (-20001, 'The table ' || p_table_name ||
     ' contains wrong value ' || v_current_value ||
     ' in column PROCESSING_FLAG.');
END switch_column_default_value;


/* *****************************************************************************
* Procedure     :truncate_table_partition                                      *
* Description    :This procedure will truncate the partition corresponding     *
*                 to the value of p_current_processing_flag.                   *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       :                                                           *
*         p_table_name:  table name                                            *
*         p_current_processing_flag: Used to determine the partition to be     *
*          truncated. Truncate p1 if the value is 1; truncate p2 if 2.         *
* Modification log :                                                           *
* Author Date Change:  Yong Feng 10/2/08 Initial creation                      *
***************************************************************************** */

PROCEDURE truncate_table_partition (
    p_table_name IN VARCHAR2,
    p_current_processing_flag IN NUMBER)
IS
  v_stmt        VARCHAR2(500);
  v_schema_name VARCHAR2(100);
  v_status      VARCHAR2(30) ;
  v_industry    VARCHAR2(30) ;
  v_partition_name    VARCHAR2(30) ;

BEGIN
  IF (NOT FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'MTH'
            , status                 => v_status
            , industry               => v_industry
            , oracle_schema          => v_schema_name)) THEN
       RAISE_APPLICATION_ERROR (-20002,
        'Could not find MTH product.');
  END IF;

  IF (p_current_processing_flag = 1) THEN
    v_partition_name := 'P1';
  ELSIF p_current_processing_flag = 2 THEN
    v_partition_name := 'P2';
  ELSE
   RAISE_APPLICATION_ERROR (-20003, 'The table ' || p_table_name ||
     ' cannot have the value ' || p_current_processing_flag ||
     ' in column PROCESSING_FLAG.');
  END IF;
  v_stmt := 'ALTER TABLE '||v_schema_name||'.'||p_table_name ||
            ' TRUNCATE PARTITION ' || v_partition_name;
  EXECUTE IMMEDIATE v_stmt;
END truncate_table_partition;

/* *****************************************************************************
* Procedure      :mth_run_log_pre_load                              	       *
* Description    :This procedure will log entries when a map is run taking     *
*                 transaction id and populating from_txn_id and to_txn_id      *
* File Name         :MTHUTILS.PLS                                              *
* Visibility     :Public                                                       *
* Modification log :                                                           *
* Author Date Change:  Vivek Sharma 21-Jan-2009 Initial creation               *
***************************************************************************** */

PROCEDURE mth_run_log_pre_load( p_fact_table IN VARCHAR2,
                                p_db_global_name IN VARCHAR2,
                                p_run_mode IN VARCHAR2,
                                p_run_start_date IN DATE,
                                p_is_fact IN NUMBER,
                                p_to_date IN DATE,
                                p_to_txn_id IN NUMBER)
IS
--local variable declation

l_fact_table mth_run_log.fact_table%TYPE;--fact table name
l_ebs_organization_id mth_run_log.ebs_organization_id%TYPE;
l_ebs_organization_code mth_run_log.ebs_organization_code%TYPE;
l_from_date mth_run_log.from_date%TYPE;--from date of the run
l_to_date mth_run_log.to_date%TYPE;--to date of the run
l_source mth_run_log.source%TYPE;--process or discrete. Not used currently
l_system_fk_key mth_systems_setup.system_pk_key%TYPE;
l_creation_date mth_run_log.creation_date%TYPE;--who column
l_last_update_date mth_run_log.last_update_date%TYPE;--who column
l_creation_system_id mth_run_log.creation_system_id%TYPE;--who column
l_last_update_system_id mth_run_log.last_update_system_id%TYPE;--who column
--l_sysdate to holding the current date
l_sysdate DATE := sysdate;--target system sysdate
--l_mode is used to determine the run type , initial 0 or incremental 1
l_mode NUMBER := 0;--initial default
l_plant_start_date DATE; --Plant end date
--Hub organization code
l_hub_organization_code mth_run_log.hub_organization_code%TYPE;
--TXN IDS
l_to_txn_id mth_run_log.to_txn_id%TYPE;
l_from_txn_id mth_run_log.from_txn_id%TYPE;

--cursor for iterating through the ebs organizations in mth_plants_d
--the rows in the mth_run_log will be at organization granularity
CURSOR c_ebs_orgs IS
SELECT ebs_organization_id,organization_code,
  source,plant_pk,system_fk_key,from_date
FROM mth_plants_d, mth_systems_setup,mth_organizations_l
WHERE system_pk_key = system_fk_key
AND system_pk = p_db_global_name
AND NVL(to_date,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)--pick active plants only
AND plant_fk_key=plant_pk_key;

BEGIN
  IF p_run_mode = 'INITIAL' THEN--Initial load
  l_from_txn_id := 0;
  --delete the rows from run log
  DELETE FROM mth_run_log WHERE fact_table = p_fact_table;

  END IF;
  --initialize the local variables and who columns
  l_fact_table := p_fact_table;
  l_last_update_system_id := -99999;
  l_last_update_date := l_sysdate;
  l_to_date := p_to_date;
  l_to_txn_id := p_to_txn_id;

  --initialize the global start date
  IF p_is_fact = 0 THEN--for dimensions only
  l_from_date := To_Date('01-01-1900','MM-DD-YYYY');
  END IF;

  --iterate through the cursor
  FOR l_orgs IN c_ebs_orgs
  LOOP

  	--initialize the variables for current cursor value
    l_ebs_organization_id := l_orgs.ebs_organization_id;
    l_source := l_orgs.source;--pick source column from the plants
    l_ebs_organization_code := l_orgs.organization_code;
    l_creation_date := l_sysdate;
	l_creation_system_id := -1;

    IF p_is_fact = 1 THEN--for facts only
    	l_from_date := l_orgs.from_date;--run start date= plant start date
    END IF;

    l_plant_start_date := l_orgs.from_date;
    l_hub_organization_code := l_orgs.plant_pk;


   	IF l_orgs.ebs_organization_id is null THEN
   			/* We are dealing with non-ebs org configured to the passed system*/
   			/* Check if there are records for non-ebs organizations from same system and same fact and same plant */
   		SELECT COUNT(*)
	    INTO l_mode
	    FROM mth_run_log
	    WHERE fact_table = l_fact_table
	    AND db_global_name = p_db_global_name
	    AND hub_organization_code = l_orgs.plant_pk;

	    IF l_mode = 0 OR UPPER(p_run_mode) = 'INITIAL' THEN /* Initial Load */

	      --statement for insert

		      INSERT INTO mth_run_log (fact_table, ebs_organization_id,
			ebs_organization_code,from_date,to_date, source, db_global_name,
			creation_date,last_update_date,creation_system_id,
			last_update_system_id,plant_start_date,hub_organization_code,from_txn_id,to_txn_id)
		      VALUES(l_fact_table,l_ebs_organization_id,l_ebs_organization_code,
			l_from_date,l_to_date,l_source,p_db_global_name,l_creation_date,
			l_last_update_date,l_creation_system_id,l_last_update_system_id,
			l_plant_start_date,l_hub_organization_code,l_from_txn_id,l_to_txn_id);

	    ELSE
		    /* update all non_ebs organizations from same system and plant with to_date as the passed date */
    		--Custom Logic for the time dimension
		      IF p_fact_table = 'MTH_WORKDAY_SHIFTS_D'
		      THEN
			      UPDATE mth_run_log
			      SET from_date = p_run_start_date
			      WHERE
			      fact_table = p_fact_table and db_global_name=p_db_global_name;
		      END IF ;

		      --statment for update
		      UPDATE mth_run_log
		      SET TO_DATE = l_to_date,
		      TO_TXN_ID = l_to_txn_id,
		      LAST_UPDATE_DATE = l_last_update_date,
		      LAST_UPDATE_SYSTEM_ID =l_last_update_system_id
		      WHERE
		      fact_table =l_fact_table
		      AND db_global_name = p_db_global_name
		      AND hub_organization_code =  l_hub_organization_code;


    	END IF; /* END of Initial VS Incremental */

  ELSE
     /* We are dealing with EBS Organizations  */

    --determine if there are any rows in the mth_run_log for
    --the fact_table corresponding to the org
	    SELECT COUNT(*)
	    INTO l_mode
	    FROM mth_run_log
	    WHERE fact_table = l_fact_table
	    AND ebs_organization_id = l_orgs.ebs_organization_id
	    AND db_global_name = p_db_global_name
	    AND hub_organization_code = l_orgs.plant_pk;

	    --l_mode = 0 means that it is a initial run. p_run_mode is
	    --for forceful execution of the initial load

	    IF l_mode = 0 OR UPPER(p_run_mode) = 'INITIAL' THEN--initial load

	      --initialize the variables for initial load
	      l_creation_date := l_sysdate;
	      l_creation_system_id := -1;

	      --statement for insert

	      INSERT INTO mth_run_log (fact_table, ebs_organization_id,
		ebs_organization_code,from_date,to_date, source, db_global_name,
		creation_date,last_update_date,creation_system_id,
		last_update_system_id,plant_start_date,hub_organization_code,from_txn_id,to_txn_id)
	      VALUES(l_fact_table,l_ebs_organization_id,l_ebs_organization_code,
		l_from_date,l_to_date,l_source,p_db_global_name,l_creation_date,
		l_last_update_date,l_creation_system_id,l_last_update_system_id,
		l_plant_start_date,l_hub_organization_code,l_from_txn_id,l_to_txn_id);



	      --if the above condition fails then update the row
	    ELSE--incremental load

	      --Custom Logic for the time dimension
	      IF p_fact_table = 'MTH_WORKDAY_SHIFTS_D'
	      THEN
		      UPDATE mth_run_log
		      SET from_date = p_run_start_date
		      WHERE
		      fact_table = p_fact_table;
	      END IF ;
		      --statment for update
		      UPDATE mth_run_log
		      SET TO_DATE = l_to_date,
		      TO_TXN_ID = l_to_txn_id,
		      LAST_UPDATE_DATE = l_last_update_date,
		      LAST_UPDATE_SYSTEM_ID =l_last_update_system_id
		      WHERE
		      fact_table =l_fact_table
		      AND source =l_source
		      AND db_global_name = p_db_global_name
		      AND ebs_organization_id = l_ebs_organization_id
		      AND hub_organization_code =  l_hub_organization_code;

	      --end of if clause
	    END IF; /* END of Initial VS Incremental */

END IF; /* End of EBS VS NON-EBS */
    --end of the for loop
  END LOOP;

--handle exceptions
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR (-20001,
        'Exception has occured');

END mth_run_log_pre_load;



/* ****************************************************************************
* Function		:GET_ATTR_EXT_COLUMN 	                              *
* Description 	 	:This function is used to retrive column name in   *
* 			 MTH_EQUIPMENTS_EXT_B that stores the value of an given  *
*        attribute name.   *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_attr_name:  Attribute name  *
* Return	 	: COLUMN_NAME - Column name in MTH_EQUIPMENTS_EXT_B that  *
*              stores the value of an given attribute name.      *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_ATTR_EXT_COLUMN(p_attr_name IN VARCHAR2,
                             p_att_grp_name IN VARCHAR2 DEFAULT 'SPECIFICATIONS'
                            ) RETURN VARCHAR2 IS
  cursor getColumnName (p_attr_name in varchar2,
                        p_att_grp_name IN VARCHAR2) is
  SELECT DATABASE_COLUMN
  FROM EGO_ATTRS_V
  WHERE application_id = 9001 AND
        ATTR_GROUP_TYPE = 'MTH_EQUIPMENTS_GROUP'  AND
        attr_group_name = p_att_grp_name AND
        ATTR_NAME = p_attr_name;
  v_attr_dbcol varchar2(30) := NULL;
BEGIN

 IF p_attr_name IS NULL OR LENGTH(p_attr_name) = 0 OR
    p_att_grp_name IS NULL OR LENGTH(p_att_grp_name) = 0 THEN
    RETURN NULL;
  END IF;

  OPEN getColumnName ( p_attr_name, p_att_grp_name );
  FETCH getColumnName INTO v_attr_dbcol;
  CLOSE getColumnName;
  RETURN v_attr_dbcol;
END GET_ATTR_EXT_COLUMN;


/* ****************************************************************************
* Function		:GET_ATTR_GROUP_ID        	                              *
* Description 	 	:This function is used to retrive attribute group ID    *
* 			 from EGO_ATTR_GROUPS_V for a given attribute group name.   *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_att_grp_name:  Attribute group name  *
* Return	 	:  Attribute group id for the specified attribute group name      *
* Modification log	:						      *
*	Author Date Change: Yong Feng	26-Aug-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_ATTR_GROUP_ID(p_att_grp_name IN VARCHAR2 DEFAULT 'SPECIFICATIONS'
                          ) RETURN NUMBER IS
  cursor getAttrGroupId (p_att_grp_name IN VARCHAR2) is
  SELECT ATTR_GROUP_ID
  FROM EGO_ATTR_GROUPS_V
  WHERE application_id = 9001 AND
        ATTR_GROUP_TYPE = 'MTH_EQUIPMENTS_GROUP'  AND
        attr_group_name = p_att_grp_name;
  v_attr_grp_id NUMBER := NULL;
BEGIN

 IF p_att_grp_name IS NULL OR LENGTH(p_att_grp_name) = 0 THEN
    RETURN NULL;
  END IF;

  OPEN getAttrGroupId ( p_att_grp_name );
  FETCH getAttrGroupId INTO v_attr_grp_id;
  CLOSE getAttrGroupId;
  RETURN v_attr_grp_id;
END GET_ATTR_GROUP_ID;


/* ****************************************************************************
* Procedure		:GET_UPPER_LOWER_LIMITS 	                              *
* Description 	 	Find and return the UPPER and LOWER limit for the    *
*                 equipment specified. *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_equipment_fk_key:  Equipment fk key  *
*             p_attr_name:  Attribute name   *
*             p_att_grp_name:  attribute group name   *
*             p_low_lim_name:  attribute name in EGO_ATTRS_V   *
*             p_upp_lim_name:  another attribute name in EGO_ATTRS_V  *
*             p_ret_LOWER_LIMIT : Lower limit returned *
*             p_ret_UPPER_LIMIT : Upper limit returned *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_UPPER_LOWER_LIMITS(p_equipment_fk_key IN NUMBER,
                                 p_attr_name in VARCHAR2,
                                 p_att_grp_name IN VARCHAR2
                                                DEFAULT 'SPECIFICATIONS',
                                 p_low_lim_name IN VARCHAR2
                                                DEFAULT 'LLIMIT',
                                 p_upp_lim_name IN VARCHAR2
                                                DEFAULT 'ULIMIT',
                                 p_ret_LOWER_LIMIT OUT NOCOPY NUMBER,
                                 p_ret_UPPER_LIMIT OUT NOCOPY NUMBER) IS

  TYPE cur_typ IS REF CURSOR;
  c cur_typ;
  query_str VARCHAR2(200);

  v_upp_column_name varchar2(30);
  v_low_column_name varchar2(30);
  v_parameter_col_name varchar2(30);
  v_attr_grp_id number;

BEGIN
  v_attr_grp_id := GET_ATTR_GROUP_ID(p_att_grp_name);
  v_parameter_col_name := GET_ATTR_EXT_COLUMN('PARAMETER', p_att_grp_name);
  v_low_column_name := GET_ATTR_EXT_COLUMN(p_low_lim_name, p_att_grp_name);
  v_upp_column_name := GET_ATTR_EXT_COLUMN(p_upp_lim_name, p_att_grp_name);
  p_ret_LOWER_LIMIT := NULL;
  p_ret_UPPER_LIMIT := NULL;

  -- RETURN because LLIMIT or ULIMIT has not been setup properly
  if (v_low_column_name is NULL or LENGTH(v_low_column_name) = 0 or
      v_upp_column_name is NULL or LENGTH(v_upp_column_name) = 0 or
      v_parameter_col_name is NULL or LENGTH(v_parameter_col_name) = 0 or
      v_attr_grp_id is NULL ) THEN
      RETURN;
  END IF;

  query_str := 'SELECT ' ||  v_low_column_name || ', ' || v_upp_column_name ||
               ' FROM mth_equipments_ext_b' ||
               ' WHERE equipment_pk_key = :e_id AND ' ||
               v_parameter_col_name || ' = :attr_name AND ' ||
               ' attr_group_id = :attr_group_id';
  OPEN c FOR query_str USING p_equipment_fk_key, p_attr_name, v_attr_grp_id;
  FETCH c INTO p_ret_LOWER_LIMIT, p_ret_UPPER_LIMIT;
  CLOSE c;
END GET_UPPER_LOWER_LIMITS;


/* ****************************************************************************
* Procedure		:GET_LATEST_READINGS 	                              *
* Description 	 	Find the latest readings bwtween two readings *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Private
* Parameters       :                                                           *
*             p_tag_data1:  One tag data  *
*             p_reading_time1: One reading time   *
*             p_tag_data2:  Another input tag data  and return the latest one *
*                           among two *
*             p_reading_time2: Another input reading time and return the  *
*                           latest one among two *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_LATEST_READINGS(p_tag_data1 IN VARCHAR2,
                              p_reading_time1 in DATE,
                              p_tag_data2 IN OUT NOCOPY VARCHAR2,
                              p_reading_time2 IN OUT NOCOPY DATE) IS

BEGIN
  IF p_reading_time2 IS NULL OR
     p_reading_time1 IS NOT NULL and p_reading_time2 IS NOT NULL AND
     p_reading_time1 > p_reading_time2
  THEN
    p_tag_data2 := p_tag_data1;
    p_reading_time2 := p_reading_time1;
  END IF;
END GET_LATEST_READINGS;


/* ****************************************************************************
* Function		:GET_PREV_TAG_READING 	                              *
* Description 	 	:This function is used to retrive the previous reading *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_code and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  TAG code name  *
*             p_reading_time:  current reading_time  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
* Return	 	: Previous tag reading for the same tag *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_PREV_TAG_READING(p_tag_code IN VARCHAR2,
                              p_reading_time IN DATE,
                              p_range_in_hours IN NUMBER DEFAULT NULL)
                RETURN VARCHAR2 IS
  v_end_date DATE;
  v_pre_tag_data_stg VARCHAR2(255) := null;
  v_pre_reading_time_stg date := null;
  v_processed_flag NUMBER;
  v_pre_tag_data VARCHAR2(255) := null;
  v_pre_reading_time date := null;
  v_pre_tag_data_err VARCHAR2(255) := null;
  v_pre_reading_time_err date := null;
  v_pre_tag_data_ret VARCHAR2(255) := null;
  v_pre_reading_time_ret date := null;
  v_pre_tag_data_ret2 VARCHAR2(255) := null;
  v_pre_reading_time_ret2 date := null;

  v_found_pre_in_readings boolean := false;
  v_found_pre_in_err boolean := false;
  v_found_pre_in_stg boolean := false;

  CURSOR c_readings_stg (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time, processed_flag
    FROM mth_tag_readings_stg
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

  CURSOR c_readings     (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time
    FROM mth_tag_readings
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

  CURSOR c_readings_err (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time
    FROM mth_tag_readings_err
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

BEGIN
  IF p_range_in_hours is not NULL and p_range_in_hours > 0 THEN
    v_end_date := p_reading_time - p_range_in_hours / 24;
  ELSE
    v_end_date := p_reading_time - 36500;
  END IF;

  OPEN c_readings_stg ( p_tag_code, p_reading_time, v_end_date);
  FETCH c_readings_stg INTO
        v_pre_tag_data_stg, v_pre_reading_time_stg, v_processed_flag;
  v_found_pre_in_stg := c_readings_stg%FOUND;
  CLOSE c_readings_stg;

  -- If found the previous reading in staging table and the data
  -- has not been processed yet, then that is the latest.
  IF v_found_pre_in_stg = true  THEN
    RETURN v_pre_tag_data_stg;
  END IF;

  -- Otherwise, look into readings and err tables.
  OPEN c_readings ( p_tag_code, p_reading_time, v_end_date);
  FETCH c_readings INTO v_pre_tag_data, v_pre_reading_time;
  v_found_pre_in_readings := c_readings%FOUND;
  CLOSE c_readings;

  OPEN c_readings_err ( p_tag_code, p_reading_time, v_end_date);
  FETCH c_readings_err INTO v_pre_tag_data_err, v_pre_reading_time_err;
  v_found_pre_in_err := c_readings_err%FOUND;
  CLOSE c_readings_err;

  GET_LATEST_READINGS(v_pre_tag_data_err,
                      v_pre_reading_time_err,
                      v_pre_tag_data,
                      v_pre_reading_time);
  return v_pre_tag_data;
END GET_PREV_TAG_READING;




/* ****************************************************************************
* Procedure		:GET_PREV_TAG_READING_INFO 	                              *
* Description 	 	:This function is used to retrive the previous reading *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_code and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  TAG code name  *
*             p_reading_time:  current reading_time  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             p_pre_tag_data: Previous tag reading for the same tag code *
*             p_pre_reading_time: reading time for the previous tag reading  *
*             p_pre_eqp_availability: The availability_flag in the
*                      mth_equipment_shifts_d table      *
*                                     Y - available *
*                                     N - not available *
*                                     NULL - no schedule available *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_PREV_TAG_READING_INFO(p_tag_code IN VARCHAR2,
                                    p_reading_time IN DATE,
                                    p_range_in_hours IN NUMBER DEFAULT NULL,
                                    p_pre_tag_data OUT NOCOPY VARCHAR2,
                                    p_pre_reading_time OUT NOCOPY DATE,
                                    p_pre_eqp_availability OUT NOCOPY VARCHAR2)
IS
  v_end_date DATE;
  v_pre_tag_data_stg VARCHAR2(255) := null;
  v_pre_reading_time_stg date := null;
  v_processed_flag NUMBER;
  v_pre_tag_data VARCHAR2(255) := null;
  v_pre_reading_time date := null;
  v_pre_tag_data_err VARCHAR2(255) := null;
  v_pre_reading_time_err date := null;
  v_pre_tag_data_ret VARCHAR2(255) := null;
  v_pre_reading_time_ret date := null;
  v_pre_tag_data_ret2 VARCHAR2(255) := null;
  v_pre_reading_time_ret2 date := null;
  v_pre_eqp_availability varchar2(1) := null;

  v_found_pre_in_readings boolean := false;
  v_found_pre_in_err boolean := false;
  v_found_pre_in_stg boolean := false;
  v_equipment_fk_key number;

  CURSOR c_readings_stg (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time, equipment_fk_key
    FROM mth_tag_readings_stg
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

  CURSOR c_readings     (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time, equipment_fk_key
    FROM mth_tag_readings
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

  CURSOR c_readings_err (p_tag_code IN VARCHAR2,
                         p_start_reading_time IN DATE,
                         p_end_reading_time IN DATE) IS
    SELECT tag_data, reading_time, equipment_fk_key
    FROM mth_tag_readings_err
    WHERE tag_code = p_tag_code AND
          reading_time < p_start_reading_time AND
          reading_time >= p_end_reading_time
    ORDER BY reading_time desc;

    cursor c_avail (p_equipment_fk_key IN NUMBER, p_reading_time IN DATE ) IS
      SELECT s.availability_flag
      FROM MTH_EQUIPMENT_SHIFTS_D s
      WHERE s.equipment_fk_key = p_equipment_fk_key AND
            p_reading_time BETWEEN s.from_date AND s.To_Date;


BEGIN
  IF p_range_in_hours is not NULL and p_range_in_hours > 0 THEN
    v_end_date := p_reading_time - p_range_in_hours / 24;
  ELSE
    v_end_date := p_reading_time - 36500;
  END IF;

  OPEN c_readings_stg ( p_tag_code, p_reading_time, v_end_date);
  FETCH c_readings_stg INTO
        v_pre_tag_data, v_pre_reading_time, v_equipment_fk_key;
  v_found_pre_in_stg := c_readings_stg%FOUND;
  CLOSE c_readings_stg;

  -- If found the previous reading in staging table and the data
  -- has not been processed yet, then that is the latest.
  -- Otherwise, look into readings and err tables.
  IF v_found_pre_in_stg = false THEN
    begin

      OPEN c_readings ( p_tag_code, p_reading_time, v_end_date);
      FETCH c_readings INTO v_pre_tag_data, v_pre_reading_time,
                            v_equipment_fk_key;
      v_found_pre_in_readings := c_readings%FOUND;
      CLOSE c_readings;

      OPEN c_readings_err ( p_tag_code, p_reading_time, v_end_date);
      FETCH c_readings_err INTO v_pre_tag_data_err, v_pre_reading_time_err,
                                v_equipment_fk_key;
      v_found_pre_in_err := c_readings_err%FOUND;
      CLOSE c_readings_err;

      GET_LATEST_READINGS(v_pre_tag_data_err,
                          v_pre_reading_time_err,
                          v_pre_tag_data,
                          v_pre_reading_time);
     end;
   end if;

  IF ( v_pre_tag_data is not null and  v_pre_reading_time is not NULL ) THEN
    OPEN c_avail (v_equipment_fk_key, v_pre_reading_time);
    FETCH c_avail INTO v_pre_eqp_availability;
    CLOSE c_avail;
  END IF;

  p_pre_tag_data := v_pre_tag_data;
  p_pre_reading_time := v_pre_reading_time;
  p_pre_eqp_availability := v_pre_eqp_availability;

END GET_PREV_TAG_READING_INFO;


/* ****************************************************************************
* Procedure		:GET_PREV_TAG_READING_SET 	                              *
* Description 	 	:This function is used to retrive the previous reading set *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_codes and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour. The reading set bounded by the same *
*                  group id contains both tags *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code1:  TAG code name  *
*             p_reading_time1:  corresponding reading_time  *
*             p_tag_code2:  Another tag code name  *
*             p_reading_time2:  corresponding reading_time to the second tag *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             p_pre_tag_data1: Previous tag reading for the  tag_code1 *
*             p_pre_tag_data2: Previous tag reading for the  tag_code2  *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_PREV_TAG_READING_SET(p_tag_code1 IN VARCHAR2,
                                    p_reading_time1 IN DATE,
                                    p_tag_code2 IN VARCHAR2,
                                    p_reading_time2 IN DATE,
                                    p_range_in_hours IN NUMBER DEFAULT NULL,
                                    p_pre_tag_data1 OUT NOCOPY VARCHAR2,
                                    p_pre_tag_data2 OUT NOCOPY VARCHAR2) IS
  CURSOR c_pre_data_set(p_tag_code1 IN VARCHAR2, p_reading_time1 IN DATE,
                        p_tag_code2 IN VARCHAR2, p_reading_time2 IN DATE,
                        p_end_time IN DATE) IS
      SELECT tag_data1, reading_time1, tag_data2, reading_time2
      FROM (
        SELECT r1.tag_data tag_data1, r1.reading_time reading_time1,
              r2.tag_data tag_data2, r2.reading_time reading_time2
        FROM   mth_tag_readings_stg r1, mth_tag_readings_stg r2
        WHERE  r1.group_id = r2.GROUP_id AND
              r1.reading_time < p_reading_time1 AND
              r2.reading_time < p_reading_time2 AND
              r1.reading_time >= p_end_time AND
              r2.reading_time >= p_end_time AND
              r1.tag_code = p_tag_code1 AND
              r2.tag_code = p_tag_code2
        UNION ALL
        SELECT r1.tag_data tag_data1, r1.reading_time reading_time1,
              r2.tag_data tag_data2, r2.reading_time reading_time2
        FROM   mth_tag_readings r1, mth_tag_readings r2
        WHERE  r1.group_id = r2.GROUP_id AND
              r1.reading_time < p_reading_time1 AND
              r2.reading_time < p_reading_time2 AND
              r1.reading_time >= p_end_time AND
              r2.reading_time >= p_end_time AND
              r1.tag_code = p_tag_code1 AND
              r2.tag_code = p_tag_code2
        UNION ALL
        SELECT r1.tag_data tag_data1, r1.reading_time reading_time1,
              r2.tag_data tag_data2, r2.reading_time reading_time2
        FROM   mth_tag_readings_err r1, mth_tag_readings_err r2
        WHERE  r1.group_id = r2.GROUP_id AND
              r1.reading_time < p_reading_time1 AND
              r2.reading_time < p_reading_time2 AND
              r1.reading_time >= p_end_time AND
              r2.reading_time >= p_end_time AND
              r1.tag_code = p_tag_code1 AND
              r2.tag_code = p_tag_code2
      )
      ORDER BY   reading_time1 DESC, reading_time2 DESC;

  v_reading_time1 DATE;
  v_reading_time2 DATE;
  v_begin_date DATE;
  v_end_date DATE;
BEGIN
  v_begin_date := LEAST(p_reading_time1, p_reading_time2);
  IF (v_begin_date IS NULL) THEN
    v_begin_date := SYSDATE;
  END IF;
  IF p_range_in_hours is not NULL and p_range_in_hours > 0 THEN
    v_end_date := v_begin_date - p_range_in_hours / 24;
  ELSE
    v_end_date := v_begin_date - 36500;
  END IF;

  OPEN c_pre_data_set(p_tag_code1, p_reading_time1,
                      p_tag_code2, p_reading_time2, v_end_date);
  FETCH c_pre_data_set INTO p_pre_tag_data1, v_reading_time1,
        p_pre_tag_data2, v_reading_time2;
  CLOSE c_pre_data_set;
END GET_PREV_TAG_READING_SET;


/* ****************************************************************************
* Function		:VERIFY_TAG_DATA_TREND 	                              *
* Description 	 	Check consecutive values of tag readings is above  *
*                 mean value (or) below mean value and the previous set of *
*                 data does not satisfy this condition *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  tag code name  *
*             p_tag_data:  tag data  *
*             p_reading_time:  corresponding reading_time  *
*             p_att_grp_name:  group name  *
*             p_mean_attr_name:  attribute name in EGO_ATTRS_V   *
*             p_num_of_readings:  Number of consective readings to check  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             RETURN: 0 Does not satisfy the condition *
*                     1 Has a up trend  *
*                     2 Has a down trend  *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION VERIFY_TAG_DATA_TREND(p_tag_code IN VARCHAR2,
                               p_tag_data IN VARCHAR2,
                               p_reading_time IN DATE,
                               p_att_grp_name IN VARCHAR2
                                              DEFAULT 'SPECIFICATIONS',
                               p_mean_attr_name IN VARCHAR2
                                              DEFAULT 'MEAN',
                               p_num_of_readings IN NUMBER,
                               p_range_in_hours IN NUMBER DEFAULT NULL)
                        RETURN NUMBER
IS
  CURSOR c_attr_name (p_tag_code IN VARCHAR2) IS
      SELECT a.attr_name, t.equipment_fk_key
      FROM mth_tag_destination_map t, ego_attrs_v a, EGO_ATTR_GROUPS_V g
      WHERE t.tag_code = p_tag_code and t.attribute = a.attr_id AND
            t.attribute_group = g.attr_group_id AND a.application_id = 9001 AND
            a.application_id = g.application_id and
            a.attr_group_name = g.attr_group_name;

  CURSOR c_pre_data_set(p_tag_code IN VARCHAR2, p_reading_time IN DATE,
                        p_end_time IN DATE) IS
      SELECT tag_data, reading_time
      FROM (
        SELECT tag_data, reading_time
        FROM   mth_tag_readings_stg
        WHERE  reading_time < p_reading_time AND
               reading_time >= p_end_time AND
               tag_code = p_tag_code
        UNION ALL
        SELECT tag_data, reading_time
        FROM   mth_tag_readings
        WHERE  reading_time < p_reading_time AND
               reading_time >= p_end_time AND
               tag_code = p_tag_code
        UNION ALL
        SELECT tag_data, reading_time
        FROM   mth_tag_readings_err
        WHERE  reading_time < p_reading_time AND
               reading_time >= p_end_time AND
               tag_code = p_tag_code
      )
      ORDER BY   reading_time DESC;

  TYPE cur_typ IS REF CURSOR;
  c cur_typ;
  query_str VARCHAR2(200);
  v_mean_column_name varchar2(30);
  v_ret_value number := 1;
  v_attr_name varchar2(30);
  v_equipment_fk_key number;
  v_mean_value number;
  v_end_date DATE;
  v_is_up_trend boolean;
  v_num_data_examed number;

  v_cur_tag_data varchar2(255);
  v_cur_reading_time date;
  v_pre_tag_data varchar2(255);
  v_pre_reading_time date;
  v_has_trend boolean;
  v_cur_tag_value number;
  v_pre_tag_value number;
  v_pre_has_trend boolean;
  v_has_more_data boolean;
  v_parameter_col_name varchar2(30);
  v_attr_grp_id number;

BEGIN
  v_attr_grp_id := GET_ATTR_GROUP_ID(p_att_grp_name);
  v_parameter_col_name := GET_ATTR_EXT_COLUMN('PARAMETER', p_att_grp_name);

  -- Get the attribute name associated with tag code
  open c_attr_name(p_tag_code);
  fetch c_attr_name into v_attr_name, v_equipment_fk_key;
  close c_attr_name;

  -- Construct the sql to get the value for that attribute
  v_mean_column_name := GET_ATTR_EXT_COLUMN(p_mean_attr_name, p_att_grp_name);

  IF v_attr_name is null or length(v_attr_name) = 0 or
     v_parameter_col_name is NULL or LENGTH(v_parameter_col_name) = 0 or
     v_mean_column_name is NULL or LENGTH(v_mean_column_name) = 0 or
     v_attr_grp_id is NULL THEN
    return 0;
  END IF;

  query_str := 'SELECT ' ||  v_mean_column_name ||
               ' FROM mth_equipments_ext_b' ||
               ' WHERE equipment_pk_key = :e_id AND ' ||
               v_parameter_col_name || ' = :attr_name AND ' ||
               ' attr_group_id = :attr_group_id';
  OPEN c FOR query_str USING v_equipment_fk_key, v_attr_name, v_attr_grp_id;
  FETCH c INTO v_mean_value;
  CLOSE c;

  -- IF could not find the mean value, or a user-specified value, OR
  -- the mean value is equal to the current tag_data
  -- THEN return 0 for no trend found.
  IF (v_mean_value IS NULL OR to_number(p_tag_data) = v_mean_value ) THEN
    return 0;
  END IF;

  IF p_range_in_hours is not NULL and p_range_in_hours > 0 THEN
    v_end_date := p_reading_time - p_range_in_hours / 24;
  ELSE
    v_end_date := p_reading_time - 36500;
  END IF;
  OPEN c_pre_data_set(p_tag_code, p_reading_time, v_end_date);

  v_is_up_trend := (to_number(p_tag_data) > v_mean_value);

  v_num_data_examed := 1;
  v_pre_tag_value := to_number(p_tag_data);
  v_has_trend := true;
  v_has_more_data := true;
  while v_num_data_examed <= p_num_of_readings  and
        v_has_trend and v_has_more_data loop
    fetch c_pre_data_set into v_cur_tag_data, v_cur_reading_time;
    --EXIT WHEN c_pre_data_set%NOTFOUND;
    if (c_pre_data_set%NOTFOUND) THEN
      v_has_more_data := false;
    else
      begin
        v_cur_tag_value := to_number(v_cur_tag_data);
         v_pre_has_trend := v_has_trend;
        if v_is_up_trend then
          v_has_trend := ( -- v_pre_tag_value > v_cur_tag_value AND
                           v_cur_tag_value > v_mean_value );
        else
          v_has_trend := ( -- v_pre_tag_value < v_cur_tag_value AND
                           v_cur_tag_value < v_mean_value );
        end if;

        v_num_data_examed := v_num_data_examed + 1;
        v_pre_tag_value := v_cur_tag_value;
      end;
    end if;
  end loop;
  close c_pre_data_set;

  if ((v_num_data_examed = p_num_of_readings + 1) and
     v_pre_has_trend = true and v_has_trend = false)  OR
     ((v_num_data_examed = p_num_of_readings) and  v_has_trend = true) then
     IF v_is_up_trend THEN
       v_ret_value := 1;
     ELSE
       v_ret_value := 2;
     END IF;
  else
    v_ret_value := 0;
  end if;
  return v_ret_value;

END VERIFY_TAG_DATA_TREND;


/* ****************************************************************************
* Procedure		:PUT_DOWN_STS_EXPECTED_UPTIME 	                              *
* Description 	 	:This procedure puts expected_up_time for planned   *
*                  downtime in the mth_equip_statuses table  *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: Shanthi Swaroop Donthu	18-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE PUT_DOWN_STS_EXPECTED_UPTIME
IS
v_start_time DATE;
v_end_time   DATE;
v_run_date   DATE;
BEGIN
SELECT DISTINCT from_date INTO v_run_date FROM mth_run_log WHERE fact_table = 'MTH_EQUIP_DOWN_STS_UPTIME';

    FOR i IN (SELECT equipment_fk_key,shift_workday_fk_key,from_date,To_Date,system_fk_key,creation_date,last_update_date,creation_system_id,
                            last_update_system_id FROM mth_equip_statuses WHERE status=3 AND To_Date IS NOT NULL AND last_update_date>=v_run_date)
    LOOP
    v_start_time := i.from_date;
    v_end_time   := i.To_Date;

          --Dbms_Output.PUT_LINE('v_start_time AND v_end_time are'||'-----'||To_Char(v_start_time,'dd-Mon-yyyy hh24:mi:ss')||'------'||To_Char(v_end_time,'dd-Mon-yyyy hh24:mi:ss'));

         FOR j IN (SELECT equipment_fk_key,shift_workday_fk_key,from_date,To_Date FROM mth_equipment_shifts_d WHERE equipment_fk_key = i.equipment_fk_key
                     AND shift_workday_fk_key = i.shift_workday_fk_key AND Upper(availability_flag)= 'N')
         LOOP

         --Dbms_Output.PUT_LINE('Equip_shift'||'------'||To_Char(j.from_date,'dd-Mon-yyyy hh24:mi:ss')||'------'||To_Char(j.to_date,'dd-Mon-yyyy hh24:mi:ss'));
         /***************************************/

         IF (v_start_time < j.from_date) THEN
            IF (v_end_time >= j.from_date) THEN
                   IF (i.from_date = v_start_time) THEN
                        UPDATE mth_equip_statuses SET To_Date = j.from_date WHERE equipment_fk_key = i.equipment_fk_key
                                                         AND shift_workday_fk_key = i.shift_workday_fk_key AND from_date = v_start_time;
                                                       /***** NO EXPECTE_DOWN_TIME ******/
                    --Dbms_Output.PUT_LINE('Third Updated status record with the end date'||'---'||To_Char(j.from_date,'dd-Mon-yyyy hh24:mi:ss'));
                    ELSE
                         INSERT INTO mth_equip_statuses(equipment_fk_key,shift_workday_fk_key,from_date,To_Date,status,system_fk_key,
                                  creation_date,last_update_date,creation_system_id,last_update_system_id) VALUES (i.equipment_fk_key,
                                  i.shift_workday_fk_key,v_start_time,j.from_date,3,i.system_fk_key,i.creation_date,sysdate,
                                  i.creation_system_id,i.last_update_system_id);

                     --Dbms_Output.PUT_LINE('inserted status record with'||'---'||To_Char(v_start_time,'dd-Mon-yyyy hh24:mi:ss')||'---'||To_Char(j.from_date,'dd-Mon-yyyy hh24:mi:ss'));

                    END IF;

                  IF (v_end_time <= j.To_Date) THEN

                      INSERT INTO mth_equip_statuses(equipment_fk_key,shift_workday_fk_key,from_date,To_Date,status,system_fk_key,
                                  creation_date,last_update_date,creation_system_id,last_update_system_id,expected_up_time,status_type) VALUES (i.equipment_fk_key,
                                  i.shift_workday_fk_key,j.from_date,v_end_time,3,i.system_fk_key,i.creation_date,sysdate,
                                  i.creation_system_id,i.last_update_system_id,((j.To_Date-j.from_date)*24),'PLANNED DOWNTIME');/*** EXPECTED_UP_TIME = J.TO_DATE - J.FROM_DATE **/
                                  EXIT;
                        --Dbms_Output.PUT_LINE('inserted status record with'||'---'||To_Char(j.from_date,'dd-Mon-yyyy hh24:mi:ss')||'---'||To_Char(v_end_time,'dd-Mon-yyyy hh24:mi:ss'));

                  ELSE
                      INSERT INTO mth_equip_statuses(equipment_fk_key,shift_workday_fk_key,from_date,To_Date,status,system_fk_key,
                                  creation_date,last_update_date,creation_system_id,last_update_system_id,expected_up_time,status_type) VALUES (i.equipment_fk_key,
                                  i.shift_workday_fk_key,j.from_date,j.to_date,3,i.system_fk_key,i.creation_date,sysdate,
                                  i.creation_system_id,i.last_update_system_id,((j.To_Date-j.from_date)*24),'PLANNED DOWNTIME');/*** EXPECTED_UP_TIME = J.TO_DATE - J.FROM_DATE **/

                           --Dbms_Output.PUT_LINE('inserted status record with'||'---'||To_Char(j.from_date,'dd-Mon-yyyy hh24:mi:ss')||'---'||To_Char(j.to_date,'dd-Mon-yyyy hh24:mi:ss'));


                      v_start_time := j.To_Date;
                  END IF;
            END IF;
         END IF;

          /****************************************/

         IF (v_start_time >= j.from_date AND v_start_time < j.To_Date)  THEN
            --Dbms_Output.PUT_LINE('First IF condition');

             IF(v_end_time <= j.to_date) THEN

             UPDATE mth_equip_statuses SET expected_up_time = ((j.to_date-v_start_time)*24), status_type = 'PLANNED DOWNTIME', last_update_date = SYSDATE
                                     WHERE equipment_fk_key = i.equipment_fk_key
                                                         AND shift_workday_fk_key = i.shift_workday_fk_key AND from_date = v_start_time AND To_Date=v_end_time;
                   /***UPDATE THE RECORD WITH *** EXPECTED_UP_TIME = V_END_TIME - V_START_TIMR **/

             EXIT ;

             ELSE
                  UPDATE mth_equip_statuses SET To_Date = j.to_date, last_update_date = SYSDATE,expected_up_time=((j.To_Date - v_start_time)*24), status_type ='PLANNED DOWNTIME'   WHERE equipment_fk_key = i.equipment_fk_key
                                                         AND shift_workday_fk_key = i.shift_workday_fk_key AND from_date = v_start_time;

                  --Dbms_Output.PUT_LINE('Third Updated status record with the end date'||'---'||To_Char(j.to_date,'dd-Mon-yyyy hh24:mi:ss'));

                  INSERT INTO mth_equip_statuses(equipment_fk_key,shift_workday_fk_key,from_date,To_Date,status,system_fk_key,
                                  creation_date,last_update_date,creation_system_id,last_update_system_id) VALUES (i.equipment_fk_key,
                                  i.shift_workday_fk_key,j.to_date,v_end_time,3,i.system_fk_key,i.creation_date,sysdate,
                                  i.creation_system_id,i.last_update_system_id);

                 --Dbms_Output.PUT_LINE('inserted status record with'||'---'||To_Char(j.to_date,'dd-Mon-yyyy hh24:mi:ss')||'---'||To_Char(v_end_time,'dd-Mon-yyyy hh24:mi:ss'));

                  v_start_time := j.To_Date;

             END IF;
         END IF;
      COMMIT;

END LOOP;
COMMIT;
END LOOP;
DELETE FROM mth_equip_statuses WHERE from_date = To_Date;
COMMIT;

END PUT_DOWN_STS_EXPECTED_UPTIME;



/*****************************************************************************
* Procedure		:MTH_LOAD_HOUR_STATUS 	                              *
* Description 	 	:This procedure is used to break the shift level status data   *
*                  into hour level and populates into mth_equip_statuses table  *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: Shanthi Swaroop Donthu	08-Dec-2009	Initial Creation      *
******************************************************************************/

PROCEDURE MTH_LOAD_HOUR_STATUS(p_equipment_fk_key IN  NUMBER,p_shift_workday_fk_key IN  NUMBER,
p_from_date IN  DATE, p_to_date IN  DATE,p_status IN  VARCHAR2,
p_system_fk_key IN  NUMBER,p_user_dim1_fk_key IN  NUMBER, p_user_dim2_fk_key IN  NUMBER,
p_user_dim3_fk_key IN  NUMBER,p_user_dim4_fk_key IN  NUMBER, p_user_dim5_fk_key IN  NUMBER,
p_user_attr1 IN  VARCHAR2,p_user_attr2 IN  VARCHAR2, p_user_attr3 IN  VARCHAR2,
p_user_attr4 IN  VARCHAR2,p_user_attr5 IN  VARCHAR2, p_user_measure1 IN  NUMBER,
p_user_measure2 IN  NUMBER,p_user_measure3 IN  NUMBER, p_user_measure4 IN  NUMBER,
p_user_measure5 IN  NUMBER ,p_hour_fk_key IN NUMBER,p_hour_fk IN VARCHAR2,p_hour_to_time IN DATE) IS

--initialize variables here
v_unassigned_string VARCHAR2(20) := to_char(mth_util_pkg.mth_ua_get_val);
v_count NUMBER;
v_next_hour_from_time DATE;
v_next_hour_to_time DATE;
v_next_hour_fk_key VARCHAR2(120);

BEGIN
IF (p_hour_to_time >= p_to_date)
THEN
MERGE INTO  MTH_EQUIP_STATUSES stat
       USING (select p_equipment_fk_key p_equipment_fk_key, p_shift_workday_fk_key p_shift_workday_fk_key,
        p_hour_fk_key p_hour_fk_key, p_from_date p_from_date, p_to_date p_to_date, p_status p_status,
        p_system_fk_key p_system_fk_key,p_user_dim1_fk_key p_user_dim1_fk_key,
        p_user_dim2_fk_key p_user_dim2_fk_key, p_user_dim3_fk_key p_user_dim3_fk_key,
        p_user_dim4_fk_key p_user_dim4_fk_key, p_user_dim5_fk_key p_user_dim5_fk_key,
        p_user_attr1 p_user_attr1,p_user_attr2 p_user_attr2, p_user_attr3 p_user_attr3,
        p_user_attr4 p_user_attr4, p_user_attr5 p_user_attr5, p_user_measure1 p_user_measure1,
        p_user_measure2 p_user_measure2, p_user_measure3 p_user_measure3,
        p_user_measure4 p_user_measure4, p_user_measure5 p_user_measure5 FROM dual) var
               ON  (stat.equipment_fk_key = var.p_equipment_fk_key AND
               stat.shift_workday_fk_key = var.p_shift_workday_fk_key AND
               stat.hour_fk_key = var.p_hour_fk_key AND
               stat.from_date = var.p_from_date)
     WHEN MATCHED THEN
         UPDATE SET To_Date = p_to_date, status = p_status, system_fk_key = Nvl(p_system_fk_key,v_unassigned_string),
                 user_dim1_fk_key = p_user_dim1_fk_key, user_dim2_fk_key = p_user_dim2_fk_key,
                 user_dim3_fk_key = p_user_dim3_fk_key, user_dim4_fk_key = p_user_dim4_fk_key,
                 user_dim5_fk_key = p_user_dim1_fk_key, user_attr1 = p_user_attr1,user_attr2 =p_user_attr2,
                 user_attr3 = p_user_attr3, user_attr4 = p_user_attr4, user_attr5 = p_user_attr5,
                 user_measure1 = p_user_measure1, user_measure2 = p_user_measure2,
                 user_measure3 = p_user_measure3, user_measure4 = p_user_measure4,
                 user_measure5 = p_user_measure5, last_update_date = SYSDATE,last_update_system_id =p_system_fk_key

     WHEN NOT MATCHED THEN
         INSERT (stat.EQUIPMENT_FK_KEY, stat.SHIFT_WORKDAY_FK_KEY, stat.FROM_DATE, stat.TO_DATE,
         stat.STATUS, stat.SYSTEM_FK_KEY, stat.USER_DIM1_FK_KEY, stat.USER_DIM2_FK_KEY, stat.USER_DIM3_FK_KEY,
         stat.USER_DIM4_FK_KEY, stat.USER_DIM5_FK_KEY, stat.USER_ATTR1, stat.USER_ATTR2, stat.USER_ATTR3,
         stat.USER_ATTR4, stat.USER_ATTR5, stat.USER_MEASURE1, stat.USER_MEASURE2, stat.USER_MEASURE3,
         stat.USER_MEASURE4, stat.USER_MEASURE5, stat.CREATION_DATE, stat.LAST_UPDATE_DATE, stat.CREATION_SYSTEM_ID,
         stat.LAST_UPDATE_SYSTEM_ID, stat.CREATED_BY, stat.LAST_UPDATE_LOGIN, stat.LAST_UPDATED_BY,
         stat.EXPECTED_UP_TIME, stat.STATUS_TYPE, stat.HOUR_FK_KEY)
             VALUES (p_equipment_fk_key, p_shift_workday_fk_key, p_from_date, p_to_date, p_status,
             Nvl(p_system_fk_key,v_unassigned_string),
p_user_dim1_fk_key, p_user_dim2_fk_key, p_user_dim3_fk_key, p_user_dim4_fk_key, p_user_dim5_fk_key, p_user_attr1,
p_user_attr2, p_user_attr3, p_user_attr4, p_user_attr5, p_user_measure1, p_user_measure2, p_user_measure3,
p_user_measure4, p_user_measure5,SYSDATE,SYSDATE,Nvl(p_system_fk_key,v_unassigned_string),
Nvl(p_system_fk_key,v_unassigned_string),NULL,NULL,NULL,NULL,NULL,p_hour_fk_key);

ELSE

  MERGE INTO  MTH_EQUIP_STATUSES stat
       USING (select p_equipment_fk_key p_equipment_fk_key, p_shift_workday_fk_key p_shift_workday_fk_key,
       p_hour_fk_key p_hour_fk_key, p_from_date p_from_date, p_to_date p_to_date, p_status p_status,
       p_system_fk_key p_system_fk_key,p_user_dim1_fk_key p_user_dim1_fk_key,
       p_user_dim2_fk_key p_user_dim2_fk_key, p_user_dim3_fk_key p_user_dim3_fk_key,
       p_user_dim4_fk_key p_user_dim4_fk_key, p_user_dim5_fk_key p_user_dim5_fk_key,p_user_attr1 p_user_attr1,
       p_user_attr2 p_user_attr2, p_user_attr3 p_user_attr3, p_user_attr4 p_user_attr4,
       p_user_attr5 p_user_attr5, p_user_measure1 p_user_measure1, p_user_measure2 p_user_measure2,
       p_user_measure3 p_user_measure3,p_user_measure4 p_user_measure4, p_user_measure5 p_user_measure5 FROM dual) var
               ON  (stat.equipment_fk_key = var.p_equipment_fk_key AND
               stat.shift_workday_fk_key = var.p_shift_workday_fk_key AND
               stat.hour_fk_key = var.p_hour_fk_key AND
               stat.from_date = var.p_from_date)
     WHEN MATCHED THEN
         UPDATE SET To_Date = p_hour_to_time, status = p_status, system_fk_key = Nvl(p_system_fk_key,v_unassigned_string),
                 user_dim1_fk_key = p_user_dim1_fk_key, user_dim2_fk_key = p_user_dim2_fk_key,
                 user_dim3_fk_key = p_user_dim3_fk_key, user_dim4_fk_key = p_user_dim4_fk_key,
                 user_dim5_fk_key = p_user_dim1_fk_key, user_attr1 = p_user_attr1,user_attr2 =p_user_attr2,
                 user_attr3 = p_user_attr3, user_attr4 = p_user_attr4, user_attr5 = p_user_attr5,
                 user_measure1 = p_user_measure1, user_measure2 = p_user_measure2,
                 user_measure3 = p_user_measure3, user_measure4 = p_user_measure4,
                 user_measure5 = p_user_measure5, last_update_date = SYSDATE,last_update_system_id =p_system_fk_key

     WHEN NOT MATCHED THEN
         INSERT (stat.EQUIPMENT_FK_KEY, stat.SHIFT_WORKDAY_FK_KEY, stat.FROM_DATE, stat.TO_DATE,
         stat.STATUS, stat.SYSTEM_FK_KEY, stat.USER_DIM1_FK_KEY, stat.USER_DIM2_FK_KEY, stat.USER_DIM3_FK_KEY,
         stat.USER_DIM4_FK_KEY, stat.USER_DIM5_FK_KEY, stat.USER_ATTR1, stat.USER_ATTR2, stat.USER_ATTR3,
         stat.USER_ATTR4, stat.USER_ATTR5, stat.USER_MEASURE1, stat.USER_MEASURE2, stat.USER_MEASURE3,
         stat.USER_MEASURE4, stat.USER_MEASURE5, stat.CREATION_DATE, stat.LAST_UPDATE_DATE, stat.CREATION_SYSTEM_ID,
         stat.LAST_UPDATE_SYSTEM_ID, stat.CREATED_BY, stat.LAST_UPDATE_LOGIN, stat.LAST_UPDATED_BY,
         stat.EXPECTED_UP_TIME, stat.STATUS_TYPE, stat.HOUR_FK_KEY)
             VALUES (p_equipment_fk_key, p_shift_workday_fk_key, p_from_date, p_hour_to_time, p_status,
             Nvl(p_system_fk_key,v_unassigned_string),
p_user_dim1_fk_key, p_user_dim2_fk_key, p_user_dim3_fk_key, p_user_dim4_fk_key, p_user_dim5_fk_key, p_user_attr1,
p_user_attr2, p_user_attr3, p_user_attr4, p_user_attr5, p_user_measure1, p_user_measure2, p_user_measure3,
p_user_measure4, p_user_measure5,SYSDATE,SYSDATE,Nvl(p_system_fk_key,v_unassigned_string),
Nvl(p_system_fk_key,v_unassigned_string),NULL,NULL,NULL,NULL,NULL,p_hour_fk_key);

SELECT FLOOR((p_to_date -p_hour_to_time)*24) INTO v_count FROM DUAL;

FOR i IN 1..v_count+1 LOOP

SELECT LEAD_HOUR,LEAD_FROM_DATE,LEAD_TO_DATE INTO v_next_hour_fk_key, v_next_hour_from_time, v_next_hour_to_time
FROM(
SELECT HOUR_PK,LEAD( HOUR_PK_KEY ,i) OVER(ORDER BY FROM_TIME  ) LEAD_HOUR, LEAD( FROM_TIME,i) OVER(ORDER BY FROM_TIME  ) LEAD_FROM_DATE,
LEAD( TO_TIME ,i) OVER(ORDER BY FROM_TIME) LEAD_TO_DATE FROM MTH_HOUR_D)
WHERE HOUR_PK = p_hour_fk;

MERGE INTO  MTH_EQUIP_STATUSES stat
       USING (select p_equipment_fk_key p_equipment_fk_key, p_shift_workday_fk_key p_shift_workday_fk_key,
       p_hour_fk_key p_hour_fk_key, p_from_date p_from_date, p_to_date p_to_date, p_status p_status,
       p_system_fk_key p_system_fk_key,p_user_dim1_fk_key p_user_dim1_fk_key,
       p_user_dim2_fk_key p_user_dim2_fk_key, p_user_dim3_fk_key p_user_dim3_fk_key,
       p_user_dim4_fk_key p_user_dim4_fk_key, p_user_dim5_fk_key p_user_dim5_fk_key,
       p_user_attr1 p_user_attr1,p_user_attr2 p_user_attr2, p_user_attr3 p_user_attr3,
       p_user_attr4 p_user_attr4, p_user_attr5 p_user_attr5, p_user_measure1 p_user_measure1,
       p_user_measure2 p_user_measure2, p_user_measure3 p_user_measure3,p_user_measure4 p_user_measure4,
       p_user_measure5 p_user_measure5,v_next_hour_fk_key v_next_hour_fk_key,
       v_next_hour_from_time v_next_hour_from_time,v_next_hour_to_time v_next_hour_to_time FROM dual) var
               ON  (stat.equipment_fk_key = var.p_equipment_fk_key AND
               stat.shift_workday_fk_key = var.p_shift_workday_fk_key AND
               stat.hour_fk_key = var.v_next_hour_fk_key AND
               stat.from_date = var.v_next_hour_from_time)
     WHEN MATCHED THEN
         UPDATE SET To_Date = least(p_to_date,v_next_hour_to_time), status = p_status,
         system_fk_key = Nvl(p_system_fk_key,v_unassigned_string),
                 user_dim1_fk_key = p_user_dim1_fk_key, user_dim2_fk_key = p_user_dim2_fk_key,
                 user_dim3_fk_key = p_user_dim3_fk_key, user_dim4_fk_key = p_user_dim4_fk_key,
                 user_dim5_fk_key = p_user_dim1_fk_key, user_attr1 = p_user_attr1,user_attr2 =p_user_attr2,
                 user_attr3 = p_user_attr3, user_attr4 = p_user_attr4, user_attr5 = p_user_attr5,
                 user_measure1 = p_user_measure1, user_measure2 = p_user_measure2,
                 user_measure3 = p_user_measure3, user_measure4 = p_user_measure4,
                 user_measure5 = p_user_measure5, last_update_date = SYSDATE,last_update_system_id =p_system_fk_key

     WHEN NOT MATCHED THEN
         INSERT (stat.EQUIPMENT_FK_KEY, stat.SHIFT_WORKDAY_FK_KEY, stat.FROM_DATE, stat.TO_DATE,
         stat.STATUS, stat.SYSTEM_FK_KEY, stat.USER_DIM1_FK_KEY, stat.USER_DIM2_FK_KEY, stat.USER_DIM3_FK_KEY,
         stat.USER_DIM4_FK_KEY, stat.USER_DIM5_FK_KEY, stat.USER_ATTR1, stat.USER_ATTR2, stat.USER_ATTR3,
         stat.USER_ATTR4, stat.USER_ATTR5, stat.USER_MEASURE1, stat.USER_MEASURE2, stat.USER_MEASURE3,
         stat.USER_MEASURE4, stat.USER_MEASURE5, stat.CREATION_DATE, stat.LAST_UPDATE_DATE, stat.CREATION_SYSTEM_ID,
         stat.LAST_UPDATE_SYSTEM_ID, stat.CREATED_BY, stat.LAST_UPDATE_LOGIN, stat.LAST_UPDATED_BY,
         stat.EXPECTED_UP_TIME, stat.STATUS_TYPE, stat.HOUR_FK_KEY)
             VALUES (p_equipment_fk_key, p_shift_workday_fk_key, v_next_hour_from_time,
             least(p_to_date,v_next_hour_to_time), p_status,Nvl(p_system_fk_key,v_unassigned_string),
p_user_dim1_fk_key, p_user_dim2_fk_key, p_user_dim3_fk_key, p_user_dim4_fk_key, p_user_dim5_fk_key, p_user_attr1,
p_user_attr2, p_user_attr3, p_user_attr4, p_user_attr5, p_user_measure1, p_user_measure2, p_user_measure3,
p_user_measure4, p_user_measure5,SYSDATE,SYSDATE,Nvl(p_system_fk_key,v_unassigned_string),
Nvl(p_system_fk_key,v_unassigned_string),NULL,NULL,NULL,NULL,NULL,v_next_hour_fk_key);

END LOOP;
COMMIT;
END IF;
COMMIT;
END MTH_LOAD_HOUR_STATUS;



/* ****************************************************************************
* Procedure		:GENERATE_SHIFTS	                              *
* Description 	 	:This procedure generates the shifts in workday shifts  *
*                  and  equipment shifts table *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: amrit Kaur	04-Dec-2009	Initial Creation      *
******************************************************************************/


PROCEDURE GENERATE_SHIFTS( p_plant_fk_key IN NUMBER,
                                p_start_date IN DATE,
                                  p_end_date IN DATE)
IS
--local variable declation

l_plant_fk_key NUMBER ;
l_sysdate DATE := sysdate;--variable for sysdate
l_last_update_system_id NUMBER ;
l_last_update_date DATE ;
l_plant_pk VARCHAR2(120);
l_start_time varchar2(8);--variable for storing start time
l_end_time VARCHAR2(8);--variable for storing end_time
l_graveyard VARCHAR2(30);
l_shift_num  number;
l_shift_name VARCHAR2(240);
l_line_num NUMBER ;
l_start_date DATE ;
l_end_date DATE ;
l_start_time1 NUMBER;
l_end_time1 NUMBER;
l_equipment_fk_key NUMBER ;
l1_plant_fk_key NUMBER ;
    N NUMBER:=0;
    l_creation_system_id NUMBER;
    --l_organization_code VARCHAR2(120);
     l_system_fk_key NUMBER;
    l_site_id NUMBER ;
    l_entity_pk_key NUMBER ;
    l_entity_name     VARCHAR2(100);
    l_entity_type     VARCHAR2(30);
    l_production_entity  VARCHAR2(1);
    l_shift_workday_pk_key NUMBER ;
    l1_shift_date DATE ;
    l_from_date DATE ;
    l_to_date DATE ;
    l_shift_type VARCHAR2(30);
   -- l_graveyard_shift NUMBER;
  CURSOR c_shift_def IS

    select start_time ,end_time ,graveyard ,shift_num , shift_name,shift_type
-- into  l_start_time, l_end_time, l_graveyard, l_shift_num,l_line_num,l_shift_name,l_shift_type
 from

mth_site_shift_definitions where plant_fk_key=p_plant_fk_key;

BEGIN

 l_plant_fk_key := p_plant_fk_key;
l_start_date := p_start_date;
l_end_date := p_end_date;
l_system_fk_key := "MTH_UTIL_PKG"."MTH_UA_GET_VAL"();

--DELETE FROM mth_workday_shifts_D WHERE plant_fk_key = l_plant_fk_key and shift_date>=l_start_date ;
DELETE FROM mth_workday_shifts_D WHERE plant_fk_key = l_plant_fk_key and Trunc(from_date)>=l_start_date AND Trunc(from_date)<=l_end_date;
DELETE FROM mth_workday_shifts_D WHERE plant_fk_key = l_plant_fk_key and shift_date>=l_start_date AND shift_date<=l_end_date;
DELETE FROM mth_equipment_shifts_d WHERE availability_date>=l_start_date AND availability_date<=l_end_date
AND equipment_fk_key IN (SELECT DISTINCT(Nvl(a.equipment_fk_key,0))
 FROM mth_equipment_shifts_d a,mth_equipments_d b WHERE b.equipment_pk_key=a.equipment_fk_key AND b.plant_fk_key =l_plant_fk_key
 UNION ALL
SELECT distinct(Nvl(a.equipment_fk_key,0) )
 FROM mth_equipment_shifts_d a,mth_resources_d b WHERE b.resource_pk_key=a.equipment_fk_key AND b.plant_fk_key =l_plant_fk_key

UNION ALL
SELECT distinct(Nvl(a.equipment_fk_key,0) )
 FROM mth_equipment_shifts_d a,mth_plants_d b WHERE b.plant_pk_key=a.equipment_fk_key AND b.plant_pk_key =l_plant_fk_key

 UNION ALL
SELECT distinct(Nvl(a.equipment_fk_key,0) )
 FROM mth_equipment_shifts_d a,mth_equip_entities_mst b WHERE b.entity_pk_key=a.equipment_fk_key AND b.plant_fk_key =l_plant_fk_key
);

  FOR l_shift_def IN c_shift_def
  LOOP

    l_start_time := l_shift_def.start_time;
     l_end_time   := l_shift_def.end_time;
      l_graveyard  := l_shift_def.graveyard;
       l_shift_num  := l_shift_def.shift_num;
      -- l_line_num    := l_shift_def.line_num;
       l_shift_name   := l_shift_def.shift_name;
 l_shift_type     := l_shift_def.shift_type;



select plant_pk into l_plant_pk  from mth_plants_d where plant_pk_key=l_plant_fk_key;
--SELECT organization_code  INTO l_organization_code FROM mth_organizations_l WHERE plant_fk_key =
--l_plant_fk_key;
N := l_end_date-l_start_date;

for i IN 1.. N+1
 LOOP



  l_last_update_system_id := -99999;
  l_last_update_date := l_sysdate;
	l_creation_system_id := -1;
  l_start_time1 := TO_NUMBER(SUBSTR(l_start_time,1,2))*3600+
                        TO_NUMBER(SUBSTR(l_start_time,4,2))*60+
                        TO_NUMBER(SUBSTR(l_start_time,7,2));

          l_end_time1 := TO_NUMBER(SUBSTR(l_end_time,1,2))*3600+
                        TO_NUMBER(SUBSTR(l_end_time,4,2))*60+
                        TO_NUMBER(SUBSTR(l_end_time,7,2));


   INSERT INTO mth_workday_shifts_D(shift_workday_pk_key, shift_workday_pk,
			shift_date,shift_date_julian,plant_fk_key,shift_type,
                        graveyard_shift,from_date,to_date, shift_num,shift_name,
                        source_org_code,system_fk_key,
			creation_date,last_update_date,creation_system_id,
			last_update_system_id)
		      VALUES(mth.mth_workdays_shifts_s.nextval,
                        to_char(DECODE(GREATEST( l_start_time1, l_end_time1 ) ,
                        l_start_time1 , l_start_date  ,
                        l_start_date) + ((TO_NUMBER(SUBSTR(l_start_time,1,2))+
                        (TO_NUMBER(SUBSTR(l_start_time,4,2))/60)+
                        (TO_NUMBER(SUBSTR(l_start_time,7,2))/3600))/24),
                        'yyyymmdd-hh24:mi:ss')||'-'||l_shift_num||'-'||l_plant_pk,
                        DECODE(GREATEST( l_start_time1, l_end_time1 ) , l_start_time1 ,
                        l_start_date  +  Decode( l_shift_def.graveyard, 'SED',1,0) , l_start_date)  ,
                        TO_NUMBER(TO_CHAR( l_start_date ,'J')),
          l_plant_fk_key,l_shift_type,l_graveyard,
                        l_start_date + ((TO_NUMBER(SUBSTR(l_start_time,1,2))+
                        (TO_NUMBER(SUBSTR(l_start_time,4,2))/60)+
                        (TO_NUMBER(SUBSTR(l_start_time,7,2))/3600))/24),
         DECODE(GREATEST( l_start_time1, l_end_time1 ) , l_start_time1 ,
                        l_start_date + ((TO_NUMBER(SUBSTR(l_end_time,1,2))+
                        (TO_NUMBER(SUBSTR(l_end_time,4,2))/60)+
                        (TO_NUMBER(SUBSTR(l_end_time,7,2))/3600))/24)+  Decode( l_shift_def.graveyard, 'SED',1,1) ,
                        l_start_date + ((TO_NUMBER(SUBSTR(l_end_time,1,2))+
                        (TO_NUMBER(SUBSTR(l_end_time,4,2))/60)+
                        (TO_NUMBER(SUBSTR(l_end_time,7,2))/3600))/24)),
                        l_shift_num,l_shift_name,null, l_system_fk_key,
			l_sysdate,			l_sysdate,
                        l_creation_system_id,l_last_update_system_id);
        l_start_date := l_start_date+1;


END LOOP;
  COMMIT;



              l_start_date := p_start_date;


IF UPPER(l_shift_type)='BOTH'   THEN
  INSERT INTO  mth_equipment_shifts_d(equipment_fk_key,availability_date,shift_workday_fk_key,from_date,To_Date,line_num,availability_flag,entity_type,creation_date,last_update_date,creation_system_id,
			last_update_system_id)        (

SELECT b.entity_pk_key entity_pk_key,a.shift_date shift_date,a.shift_workday_pk_key shift_workday_fk_key,a.from_date from_date,a.to_date To_Date,1 line_num,'Y',
b.entity_type entity_type,SYSDATE,SYSDATE,-1,-99999

 --INTO l_site_id,l_entity_pk_key,l_entity_name,l_entity_type,l_production_entity,
 --l_shift_workday_pk_key,l1_shift_date,l_from_date,l_to_date
  FROM   mth_workday_shifts_d a ,
(
   SELECT plant_fk_key site_id, entity_pk_key, entity_name, entity_type, production_entity production_entity
   FROM mth.mth_equip_entities_mst
   UNION ALL
   SELECT plant_pk_key site_id, plant_pk_key entity_pk_key, plant_name entity_name, 'SITE', production_site production_entity
   FROM mth.mth_plants_d
   UNION ALL
   SELECT plant_fk_key site_id, resource_pk_key entity_pk_key, resource_name entity_name, 'RESOURCE', production_resource production_entity
   FROM mth.mth_resources_d
   UNION ALL
   SELECT plant_fk_key site_id, equipment_pk_key entity_pk_key, equipment_name entity_name, 'EQUIPMENT', production_equipment production_entity
   FROM mth.mth_equipments_d
)b
WHERE b.site_id = a.plant_fk_key
AND a.plant_fk_key=l_plant_fk_key
AND shift_date>=l_start_date
AND shift_date<=l_end_date
AND UPPER(a.shift_type)='BOTH'
--AND a.line_num=l_line_num
AND a.shift_num=l_shift_num
AND a.shift_name=l_shift_name
AND l_shift_def.start_time=To_Char(from_date,'HH24:MI:SS')
AND l_shift_def.end_time=To_Char(To_Date,'HH24:MI:SS'));

END IF;
  IF UPPER(l_shift_type)='PROD-SHIFT'   THEN
  INSERT INTO  mth_equipment_shifts_d(equipment_fk_key,availability_date,shift_workday_fk_key,from_date,To_Date,line_num,availability_flag,entity_type,creation_date,last_update_date,creation_system_id,
			last_update_system_id)        (

SELECT b.entity_pk_key entity_pk_key,a.shift_date shift_date,a.shift_workday_pk_key shift_workday_fk_key,a.from_date from_date,a.to_date To_Date,1 line_num,'Y',
b.entity_type entity_type,SYSDATE,SYSDATE,-1,-99999

 --INTO l_site_id,l_entity_pk_key,l_entity_name,l_entity_type,l_production_entity,
 --l_shift_workday_pk_key,l1_shift_date,l_from_date,l_to_date
  FROM   mth_workday_shifts_d a ,
(
   SELECT plant_fk_key site_id, entity_pk_key, entity_name, entity_type, production_entity production_entity
   FROM mth.mth_equip_entities_mst
   UNION ALL
   SELECT plant_pk_key site_id, plant_pk_key entity_pk_key, plant_name entity_name, 'SITE', production_site production_entity
   FROM mth.mth_plants_d
   UNION ALL
   SELECT plant_fk_key site_id, resource_pk_key entity_pk_key, resource_name entity_name, 'RESOURCE', production_resource production_entity
   FROM mth.mth_resources_d
   UNION ALL
   SELECT plant_fk_key site_id, equipment_pk_key entity_pk_key, equipment_name entity_name, 'EQUIPMENT', production_equipment production_entity
   FROM mth.mth_equipments_d
)b
WHERE b.site_id = a.plant_fk_key
AND a.plant_fk_key=l_plant_fk_key
AND shift_date>=l_start_date
AND shift_date<=l_end_date
AND b.production_entity='Y'
AND UPPER(a.shift_type)='PROD-SHIFT'
--AND a.line_num=l_line_num
AND a.shift_num=l_shift_num
AND a.shift_name=l_shift_name
AND l_shift_def.start_time=To_Char(from_date,'HH24:MI:SS')
AND l_shift_def.end_time=To_Char(To_Date,'HH24:MI:SS'));

END IF;
   IF UPPER(l_shift_type)='NON-PROD-SHIFT'   THEN
  INSERT INTO  mth_equipment_shifts_d(equipment_fk_key,availability_date,shift_workday_fk_key,from_date,To_Date,line_num,availability_flag,entity_type,creation_date,last_update_date,creation_system_id,
			last_update_system_id)        (

SELECT b.entity_pk_key entity_pk_key,a.shift_date shift_date,a.shift_workday_pk_key shift_workday_fk_key,a.from_date from_date,a.to_date To_Date,1 line_num,'Y',
b.entity_type entity_type,SYSDATE,SYSDATE,-1,-99999

 --INTO l_site_id,l_entity_pk_key,l_entity_name,l_entity_type,l_production_entity,
 --l_shift_workday_pk_key,l1_shift_date,l_from_date,l_to_date
  FROM   mth_workday_shifts_d a ,
(
   SELECT plant_fk_key site_id, entity_pk_key, entity_name, entity_type, production_entity production_entity
   FROM mth.mth_equip_entities_mst
   UNION ALL
   SELECT plant_pk_key site_id, plant_pk_key entity_pk_key, plant_name entity_name, 'SITE', production_site production_entity
   FROM mth.mth_plants_d
   UNION ALL
   SELECT plant_fk_key site_id, resource_pk_key entity_pk_key, resource_name entity_name, 'RESOURCE', production_resource production_entity
   FROM mth.mth_resources_d
   UNION ALL
   SELECT plant_fk_key site_id, equipment_pk_key entity_pk_key, equipment_name entity_name, 'EQUIPMENT', production_equipment production_entity
   FROM mth.mth_equipments_d
)b
WHERE b.site_id = a.plant_fk_key
AND a.plant_fk_key=l_plant_fk_key
AND shift_date>=l_start_date
AND shift_date<=l_end_date
AND b.production_entity='N'
AND UPPER(a.shift_type)='NON-PROD-SHIFT'
--AND a.line_num=l_line_num
AND a.shift_num=l_shift_num
AND a.shift_name=l_shift_name
AND l_shift_def.start_time=To_Char(from_date,'HH24:MI:SS')
AND l_shift_def.end_time=To_Char(To_Date,'HH24:MI:SS'));

END IF;

COMMIT;
END LOOP;

   l_start_date := p_start_date;

   for i IN 1.. N+1
 LOOP


  l_last_update_system_id := -99999;
  l_last_update_date := l_sysdate;
	l_creation_system_id := -1;

   INSERT INTO mth_workday_shifts_D(shift_workday_pk_key, shift_workday_pk,
			shift_date,shift_date_julian,plant_fk_key,shift_type,graveyard_shift,from_date,to_date, shift_num,shift_name,source_org_code,system_fk_key,
			creation_date,last_update_date,creation_system_id,
			last_update_system_id)
		      VALUES(mth.mth_workdays_shifts_s.nextval,l_start_date||'-'||l_plant_pk|| "MTH_UTIL_PKG"."MTH_UA_GET_VAL"(),l_start_date ,TO_NUMBER(TO_CHAR( l_start_date ,'J')),
          l_plant_fk_key,'BOTH',null,null,
         null,null,FND_PROFILE.VALUE('MTH_CATCH_ALL_NAME'),null, l_system_fk_key,
			l_sysdate,			l_sysdate,l_creation_system_id,l_last_update_system_id);
        l_start_date := l_start_date+1;


END LOOP;
  COMMIT;
       l_start_date := p_start_date;

  INSERT INTO  mth_equipment_shifts_d(equipment_fk_key,availability_date,shift_workday_fk_key,from_date,To_Date,line_num,availability_flag,entity_type,creation_date,last_update_date,creation_system_id,
			last_update_system_id)        (

SELECT b.entity_pk_key entity_pk_key,a.shift_date shift_date,a.shift_workday_pk_key shift_workday_fk_key,Trunc(a.shift_date) from_date,Trunc(a.shift_date) To_Date,1 line_num,'Y',
b.entity_type entity_type,SYSDATE,SYSDATE,-1,-99999

 --INTO l_site_id,l_entity_pk_key,l_entity_name,l_entity_type,l_production_entity,
 --l_shift_workday_pk_key,l1_shift_date,l_from_date,l_to_date
  FROM   mth_workday_shifts_d a ,
(
   SELECT plant_fk_key site_id, entity_pk_key, entity_name, entity_type, production_entity production_entity
   FROM mth.mth_equip_entities_mst
   UNION ALL
   SELECT plant_pk_key site_id, plant_pk_key entity_pk_key, plant_name entity_name, 'SITE', production_site production_entity
   FROM mth.mth_plants_d
   UNION ALL
   SELECT plant_fk_key site_id, resource_pk_key entity_pk_key, resource_name entity_name, 'RESOURCE', production_resource production_entity
   FROM mth.mth_resources_d
   UNION ALL
   SELECT plant_fk_key site_id, equipment_pk_key entity_pk_key, equipment_name entity_name, 'EQUIPMENT', production_equipment production_entity
   FROM mth.mth_equipments_d
)b
WHERE b.site_id = a.plant_fk_key
AND a.plant_fk_key=l_plant_fk_key
AND shift_date>=l_start_date
AND shift_date<=l_end_date
AND UPPER(a.shift_type)='BOTH'
AND a.FROM_DATE IS NULL
AND a .To_Date IS NULL
--AND a.line_num=NULL
AND a.shift_num IS NULL
 );



--handle exceptions
--EXCEPTION
 --  WHEN NO_DATA_FOUND THEN
 --  RAISE_APPLICATION_ERROR (-20001,
    --    'Exception has occured');

END GENERATE_SHIFTS;



/* ****************************************************************************
* Function    		:get_incremental_tag_data                                      *
* Description 	 	:Insert the error row into the error with the error code    *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_prev_tag_value -  Previous tag value               *
* Return Value          :Incremental value if incremental logic needs to be   *
*                          be applied; return p_tag_value otherwise           *
**************************************************************************** */

FUNCTION get_incremental_tag_data(P_TAG_VALUE IN VARCHAR2,
                               P_IS_NUMBER IN NUMBER,
                               P_IS_CUMULATIVE IN NUMBER,
                               P_IS_ASSENDING IN NUMBER,
                               P_INITIAL_VALUE IN NUMBER,
                               P_MAX_RESET_VALUE IN NUMBER,
                               p_prev_tag_value IN VARCHAR2)  RETURN VARCHAR2
IS
  v_incr_value VARCHAR2(255);
BEGIN
  -- 1. Do not need to apply the incremental logic
  IF (P_IS_NUMBER IS NULL OR P_IS_NUMBER <> 1 OR
      P_IS_CUMULATIVE IS NULL OR P_IS_CUMULATIVE <> 1) THEN
    v_incr_value := P_TAG_VALUE;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 1 AND
         p_prev_tag_value IS NOT NULL) THEN
    -- 2. Assending tag and it is not the first reding
    -- 2.1 not reset
    v_incr_value := CASE WHEN To_Number(P_TAG_VALUE) >= To_Number(p_prev_tag_value)
                         THEN P_TAG_VALUE - p_prev_tag_value
                         -- 2.2 after reset
                         ELSE P_MAX_RESET_VALUE - p_prev_tag_value +
                              P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 1 AND
         p_prev_tag_value IS NULL) THEN
    -- 3. Assending tag and it is the first reding
    -- 3.1 First reading
    v_incr_value := CASE WHEN To_Number(P_TAG_VALUE) >= To_Number(P_INITIAL_VALUE)
                         THEN P_TAG_VALUE - P_INITIAL_VALUE
                         -- 3.2 First reading but reset already
                         ELSE P_MAX_RESET_VALUE - P_INITIAL_VALUE + P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 0 AND
         p_prev_tag_value IS NOT NULL) THEN
    -- 4. Descending tag and it is not the first reding
    -- 4.1 not reset
    v_incr_value := CASE WHEN To_Number(P_TAG_VALUE) <= To_Number(p_prev_tag_value)
                         THEN p_prev_tag_value - P_TAG_VALUE
                         -- 2.2 after reset
                         ELSE p_prev_tag_value + P_MAX_RESET_VALUE -
                              P_TAG_VALUE
                    END;
  ELSIF (P_IS_CUMULATIVE = 1 AND  P_IS_ASSENDING = 0 AND
         p_prev_tag_value IS NULL) THEN
    -- 5. Descending tag and it is  the first reding
    -- 4.1 not reset
    v_incr_value := CASE WHEN To_Number(P_TAG_VALUE) <= To_Number(P_INITIAL_VALUE)
                         THEN P_INITIAL_VALUE - P_TAG_VALUE
                         -- 3.2 First reading but reset already
                         ELSE P_INITIAL_VALUE + P_MAX_RESET_VALUE - P_TAG_VALUE
                    END;
  END IF;
  RETURN v_incr_value;

END get_incremental_tag_data;



/* ****************************************************************************
* Procedure    		:update_tag_to_latest_tab                                   *
* Description 	 	:Update an existing the latest reading time and tag value   *
*                  for a tag if table MTH_TAG_READINGS_LATEST already   *
*                  has a entry for the tag. Otherwise, insert a new row       *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code -  tag code                               *
*                        p_latest_reading_time - reading time of the latest   *
*                        p_latest_tag_value -  latest tag reading             *
*                        p_lookup_entry_exist - whether the entry with the    *
*                            same tag code exists in the                      *
*                            MTH_TAG_READINGS_LATEST or not             *
* Return Value          :None                                                 *
**************************************************************************** */

PROCEDURE update_tag_to_latest_tab(p_tag_code IN VARCHAR2,
                                   p_latest_reading_time IN DATE,
                                   p_latest_tag_value IN VARCHAR2,
                                   p_lookup_entry_exist IN BOOLEAN)
IS
BEGIN
  -- If the entry exists, do the update; otherwise, do the insert
  IF (p_lookup_entry_exist) THEN
    UPDATE MTH_TAG_READINGS_LATEST
    SET    reading_time = p_latest_reading_time, tag_value = p_latest_tag_value
    WHERE  tag_code = p_tag_code;
  ELSE
    INSERT INTO MTH_TAG_READINGS_LATEST
           (TAG_CODE, READING_TIME, TAG_VALUE) VALUES
           (p_tag_code, p_latest_reading_time, p_latest_tag_value);
  END IF;

END update_tag_to_latest_tab;


/* ****************************************************************************
* Function     		:MTH_IS_TAG_RAW_DATA_ROW_VALID                                *
* Description 	 	:Check if the raw from MTH_TAG_READINGS_RAW is valid      *
*                  or not.                                         *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code - Tag code                                *
*                        p_reading_time - Reading time                        *
*                        p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_prev_reading_time -  reading time for the previous *
*                                               tag reading                   *
* Return Value          : Found violations of the following rules:            *
*                         'NGV'  -	Usage value is negative.                  *
*                         'OTR'  -	Usage value is out of range defined       *
*                                   for a cumulative tag.                     *
*                         'OTO'  - 	The raw reading data is out of order.     *
*                         'DUP'  -	The raw reading data is duplicated.       *
*                        NULL  - Valid row                                    *
***************************************************************************** */

FUNCTION MTH_IS_TAG_RAW_DATA_ROW_VALID
         (p_tag_code IN VARCHAR2,
          p_reading_time IN DATE,
          p_tag_value IN VARCHAR2,
          p_is_number IN NUMBER,
          p_is_cumulative IN NUMBER,
          p_is_assending IN NUMBER,
          p_initial_value IN NUMBER,
          p_max_reset_value IN NUMBER,
          p_prev_reading_time IN DATE) RETURN VARCHAR2
IS
  v_err_code VARCHAR2(240) := '';
BEGIN
  IF (p_is_number = 1 AND p_tag_value < 0) THEN
    v_err_code :=  v_err_code || 'NGV ';
  END IF;
  IF (p_is_number = 1 AND p_is_cumulative = 1 AND
      p_tag_value > p_max_reset_value) THEN
    v_err_code :=  v_err_code || 'OTR ';
  END IF;
  IF (p_prev_reading_time IS NOT NULL AND
      p_reading_time < p_prev_reading_time) THEN
    v_err_code :=  v_err_code || 'OTO ';
  END IF;
  IF (p_prev_reading_time IS NOT NULL AND
      p_reading_time = p_prev_reading_time) THEN
    v_err_code :=  v_err_code || 'DUP ';
  END IF;
  IF (Length(v_err_code) = 0) THEN
    v_err_code := NULL;
  END IF;
  RETURN v_err_code;
END MTH_IS_TAG_RAW_DATA_ROW_VALID;



/* ****************************************************************************
* Procedure		:MTH_LOAD_TAG_RAW_TO_PROCESSED                                *
* Description 	 	:Load data from  the table MTH_TAG_READINGS_RAW           *
* into meter readings table MTH_TAG_READINGS_RAW_PROCESSED                    *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_curr_partition (value of the partition column      *
**************************************************************************** */

PROCEDURE MTH_LOAD_TAG_RAW_TO_PROCESSED(p_curr_partition IN NUMBER)
IS

  -- Fetch raw data for active tags from the patition
  -- ordered by TAG_CODE, READING_TIME
  CURSOR c_getRawData (p_processing_flag IN NUMBER) IS
    SELECT R.TAG_CODE, R.READING_TIME,  R.TAG_DATA,
           Decode(DATA_TYPE, 'NUM', 1, 0) IS_NUMBER,
           Decode(T.READING_TYPE, 'CHNG', 1, 0) AS IS_CUMULATIVE,
           Decode(T.ORDER_TYPE, 'ASC', 1, 0) IS_ASSENDING,
           T.INITIAL_VALUE, T.MAX_RESET_VALUE, R.GROUP_ID, R.CREATION_DATE, R.USER_ATTR1, R.USER_ATTR2, R.USER_ATTR3, R.USER_ATTR4, R.USER_ATTR5, R.USER_MEASURE1, R.USER_MEASURE2, R.USER_MEASURE3, R.USER_MEASURE4, R.USER_MEASURE5, R.QUALITY_FLAG
    FROM MTH_TAG_READINGS_RAW R, MTH_TAG_MASTER T
    WHERE PROCESSING_FLAG = p_processing_flag AND
          R.TAG_CODE = T.TAG_CODE (+)
    ORDER BY TAG_CODE, READING_TIME;

  -- Fetch the previous reading time for the given tag code
  CURSOR c_getPrevReadingTimeForTag (p_tag_code IN VARCHAR2) IS
    SELECT TAG_VALUE, READING_TIME
    FROM MTH_TAG_READINGS_LATEST
    WHERE TAG_CODE = p_tag_code;

  v_curr_partition NUMBER := p_curr_partition;
  v_curr_tag_code VARCHAR2(255) := NULL;
  v_prev_tag_code VARCHAR2(255) := NULL;
  v_prev_reading_time DATE := NULL;
  v_prev_tag_value VARCHAR2(255) := NULL;
  v_lookup_entry_exist boolean;
  v_err_code VARCHAR2(240);
  v_incr_tag_value VARCHAR2(255);


Begin

  -- 1. First switch the partition for the meter readings raw table
  --mth_util_pkg.switch_column_default_value(v_raw_tab_name, v_curr_partition);
  IF (v_curr_partition = 0) THEN
    -- No data available in the table to be processed
    RETURN;
  END IF;

    -- 2. Fetch the raw data for active tag and process each row
  FOR r_raw_data IN c_getRawData(v_curr_partition) LOOP
    v_curr_tag_code := r_raw_data.TAG_CODE;

    -- 2.0 Update/Create entry in MTH_TAG_READINGS_LATEST for previous tag
    IF (v_prev_tag_code IS NOT NULL AND v_prev_tag_code <> v_curr_tag_code) THEN
      update_tag_to_latest_tab(v_prev_tag_code,
                               v_prev_reading_time,
                               v_prev_tag_value,
                               v_lookup_entry_exist);
    END IF;

    -- 2.1 Find the meters and latest reading for the new tag code
    IF (v_prev_tag_code IS NULL OR v_prev_tag_code <> v_curr_tag_code) THEN
      -- 2.1.0 Reset the previous reading for the new tag code
      v_prev_tag_value := NULL;
      v_prev_reading_time := NULL;

      -- 2.1.2 Find previous reading time and tag value for the  currenttag
      --       in the lookup table MTH_TAG_READINGS_LATEST
      OPEN c_getPrevReadingTimeForTag(v_curr_tag_code);
      FETCH c_getPrevReadingTimeForTag INTO
              v_prev_tag_value, v_prev_reading_time;
      CLOSE c_getPrevReadingTimeForTag;
      v_lookup_entry_exist :=  v_prev_reading_time IS NOT NULL;
    END IF;

 -- 2.2 Validate the raw data
    v_err_code := MTH_IS_TAG_RAW_DATA_ROW_VALID (r_raw_data.TAG_CODE,
                                                 r_raw_data.READING_TIME,
                                                 r_raw_data.TAG_DATA,
                                                 r_raw_data.IS_NUMBER,
                                                 r_raw_data.IS_CUMULATIVE,
                                                 r_raw_data.IS_ASSENDING,
                                                 r_raw_data.INITIAL_VALUE,
                                                 r_raw_data.MAX_RESET_VALUE,
                                                 v_prev_reading_time);


    -- 2.3 Insert data into either meter readings or error table
    IF (v_err_code IS NOT NULL OR Length(v_err_code) > 0) THEN
      -- 2.3.1 Insert the error row to error table  if there is any error
       INSERT INTO MTH_TAG_READINGS_UNPROCESS_ERR
          (GROUP_ID, READING_TIME , TAG_CODE, TAG_DATA, CREATION_DATE, USER_ATTR1, USER_ATTR2, USER_ATTR3, USER_ATTR4, USER_ATTR5, USER_MEASURE1, USER_MEASURE2, USER_MEASURE3, USER_MEASURE4, USER_MEASURE5, QUALITY_FLAG, REPROCESSED_READY_YN, ERR_CODE)
        VALUES (r_raw_data.GROUP_ID, r_raw_data.READING_TIME, r_raw_data.TAG_CODE, r_raw_data.TAG_DATA, r_raw_data.CREATION_DATE, r_raw_data.USER_ATTR1, r_raw_data.USER_ATTR2, r_raw_data.USER_ATTR3, r_raw_data.USER_ATTR4, r_raw_data.USER_ATTR5,
        r_raw_data.USER_MEASURE1, r_raw_data.USER_MEASURE2, r_raw_data.USER_MEASURE3, r_raw_data.USER_MEASURE4, r_raw_data.USER_MEASURE5, r_raw_data.QUALITY_FLAG,'N', v_err_code);
    ELSE
      -- 2.3.2 Get the incremental value
      v_incr_tag_value := get_incremental_tag_data(r_raw_data.TAG_DATA,
                                                r_raw_data.IS_NUMBER,
                                                r_raw_data.IS_CUMULATIVE,
                                                r_raw_data.IS_ASSENDING,
                                                r_raw_data.INITIAL_VALUE,
                                                r_raw_data.MAX_RESET_VALUE,
                                                v_prev_tag_value);

      -- 2.3.3 Insert the data into the mth_tag_readings_processed table
       INSERT INTO MTH_TAG_READINGS_RAW_PROCESSED (GROUP_ID, READING_TIME , TAG_CODE, TAG_DATA, CREATION_DATE, USER_ATTR1, USER_ATTR2, USER_ATTR3, USER_ATTR4, USER_ATTR5, USER_MEASURE1, USER_MEASURE2, USER_MEASURE3, USER_MEASURE4,
       USER_MEASURE5, QUALITY_FLAG) VALUES ( r_raw_data.GROUP_ID, r_raw_data.READING_TIME, r_raw_data.TAG_CODE, v_incr_tag_value, r_raw_data.CREATION_DATE, r_raw_data.USER_ATTR1, r_raw_data.USER_ATTR2, r_raw_data.USER_ATTR3,
       r_raw_data.USER_ATTR4, r_raw_data.USER_ATTR5, r_raw_data.USER_MEASURE1, r_raw_data.USER_MEASURE2, r_raw_data.USER_MEASURE3, r_raw_data.USER_MEASURE4, r_raw_data.USER_MEASURE5, r_raw_data.QUALITY_FLAG);

    END IF;

    -- 2.4 Save the current data as previous data, which can be used for :
    v_prev_tag_code :=  v_curr_tag_code;
    v_prev_tag_value := r_raw_data.TAG_DATA;
    v_prev_reading_time := Greatest(r_raw_data.READING_TIME,
                                    Nvl(v_prev_reading_time,
                                        r_raw_data.READING_TIME));

  END LOOP;

       -- 2.6 Update/Create entry in MTH_TAG_READINGS_LATEST for the last tag
           update_tag_to_latest_tab(v_prev_tag_code,
                                    v_prev_reading_time,
                                    v_prev_tag_value,
                                    v_lookup_entry_exist);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;

COMMIT;

END MTH_LOAD_TAG_RAW_TO_PROCESSED;




END mth_util_pkg;

/
