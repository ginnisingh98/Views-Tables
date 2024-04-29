--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PCO_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PCO_LOAD_PKG" AS
/* $Header: ENIPCOLB.pls 120.3 2006/03/31 01:11:38 lparihar noship $ */

-- Global variables
g_eni_schema    VARCHAR2(30);
g_bom_schema    VARCHAR2(30);
l_status              VARCHAR2(30);
l_industry            VARCHAR2(30);

TYPE g_conc_request_struct IS RECORD (
      request_id    number,
      request_phase VARCHAR2(20));

TYPE g_conc_request_varray IS VARRAY(10) OF g_conc_request_struct;
g_conc_request_array g_conc_request_varray;
g_actual_workers number;
g_batch_size number;
g_actual_recs_to_process number;
g_recs_per_worker number;
g_organization_id NUMBER;
g_number_of_batches NUMBER;
g_recs_per_batch number;
g_collection_date  DATE;

procedure validate_set_parameters(
	p_num_workers in number,
	p_batch_size in number) is
begin

	SELECT COUNT(*)
	INTO g_actual_recs_to_process
	FROM eni_dbi_pco_worker_assignments;

-- Set the batch size

	IF (NVL(p_batch_size,0) < 50) THEN
		g_batch_size := 50;
	ELSIF (p_batch_size > 200) THEN
		g_batch_size := 200;
	END IF;
	g_number_of_batches := ceil(g_actual_recs_to_process/g_batch_size);
	g_recs_per_batch := ceil(g_actual_recs_to_process/g_number_of_batches);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch size in validate = ' || g_batch_size);

-- Set the number of workers
	g_actual_workers := least(ceil(g_actual_recs_to_process/g_batch_size), least(p_num_workers, 10)); --FND_PROFILE.get('DBI_MAX_WORKERS'));
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Second Batch size in validate = ' || g_batch_size);

	IF (g_actual_workers = 0) THEN
	  g_actual_workers := 1;
	END IF;

end validate_set_parameters;

procedure collect_modified_bills IS

-- The cursor c_modified_bill_of_materials stores all the Bills that have been recorded in the
-- logs MLOG$_BOM_INVENTORY_COMPON and MLOG$_BOM_BILL_OF_MATERIAL.

   CURSOR c_modified_bill_of_materials(last_collected_date IN date)
   IS
	  -- Modified for bug # 3669751
        SELECT UNIQUE  -- Collects all modified common/non-common bills whose orgs are in org temp table
            bbom.assembly_item_id AS assembly_item_id,
            bbom.organization_id AS organization_id
        FROM
            mlog$_bom_components_b mbic,
            bom_structures_b bbom
        WHERE
            mbic.bill_sequence_id = bbom.bill_sequence_id and
            bbom.alternate_bom_designator IS NULL and
            bbom.bill_sequence_id = bbom.common_bill_sequence_id and
	    exists (select 1 from bom_structures_b bbom_common
	            where bbom_common.common_bill_sequence_id = bbom.bill_sequence_id
	  	    and bbom_common.organization_id IN
		    (select * from eni_dbi_part_count_org_temp))
	    and mbic.snaptime$$ > NVL(last_collected_date,mbic.snaptime$$)
   UNION  -- Collects all deleted/modified bills whose orgs are in the org temp table
        SELECT UNIQUE
    		bbom.assembly_item_id AS assembly_item_id,
    		bbom.organization_id AS organization_id
    	FROM
    		mlog$_bom_structures_b bbom   -- Bug # 3394284
        WHERE
            bbom.dmltype$$ <> 'I' and
            bbom.alternate_bom_designator IS NULL and
	    bbom.bill_sequence_id = bbom.common_bill_sequence_id and
	    bbom.organization_id IN (select * from eni_dbi_part_count_org_temp)
   UNION   -- This query collects all the common bills for the organizations in the temp table
        SELECT UNIQUE -- Collects any newly commoned bills
    		bbom.assembly_item_id AS assembly_item_id,
    		bbom.organization_id AS organization_id
    	FROM
    		mlog$_bom_structures_b mlog_bbom, bom_structures_b bbom
        WHERE
            mlog_bbom.alternate_bom_designator IS NULL and
	    mlog_bbom.bill_sequence_id <> mlog_bbom.common_bill_sequence_id and
	    mlog_bbom.organization_id IN (select * from eni_dbi_part_count_org_temp) and
	    mlog_bbom.common_bill_sequence_id = bbom.bill_sequence_id;

   o_error_msg varchar2(1000);
   o_error_code varchar2(1000);
   l_last_collected_date date;
begin

IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
  THEN NULL;
  END IF;

        l_last_collected_date := fnd_date.displayDT_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('ENI_DBI_PART_COUNT_F'));

	dbms_mview.refresh('ENI_DBI_BOM_COMPONENTS_MV1','F');

	select sysdate into g_collection_date from dual;
        execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.ENI_DBI_PCO_WORKER_ASSIGNMENTS';

       -- Loop to Implode all the Modified Bills.
	FOR r_modified_bill_of_materials IN c_modified_bill_of_materials(l_last_collected_date) LOOP
	    bompimpl.imploder_userexit(
		sequence_id => 1,
		eng_mfg_flag => 2,
		org_id => r_modified_bill_of_materials.organization_id,
		impl_flag => 2,
		display_option => 2,
		levels_to_implode => 60,
		item_id => r_modified_bill_of_materials.assembly_item_id,
		impl_date => TO_CHAR(sysdate,'YYYY/MM/DD HH24:MI'),
		err_msg => o_error_msg,
		err_code => o_error_code);

           --Remove duplicates from BOM_IMPLOSION_TEMP
	   --as ENI_DBI_PCO_WORKER_ASSIGNMENTS already has rows
           DELETE FROM bom_implosion_temp bit
	   WHERE EXISTS (SELECT NULL
	                 FROM eni_dbi_pco_worker_assignments p
			 WHERE p.assembly_item_id = bit.parent_item_id
			   and p.organization_id  = bit.organization_id);

     -- Storing the implosion results into a table.
	   INSERT INTO eni_dbi_pco_worker_assignments
	   (
	        assembly_item_id,
	        organization_id,
		pto_flag,
		bom_type,
		worker_id,
		incr_status
	   )
           (SELECT  unique
                bit.parent_item_id AS assembly_item_id,
                bit.organization_id AS organization_id,
		(select msi.pick_components_flag from mtl_system_items_b msi
		 where msi.inventory_item_id = bit.parent_item_id and
		       msi.organization_id = bit.organization_id) AS pick_components_flag,
		(select msi.bom_item_type from mtl_system_items_b msi
		 where msi.inventory_item_id = bit.parent_item_id and
		       msi.organization_id = bit.organization_id) AS bom_item_type,
		 NULL as worker_id,
		 0 as incr_status
           FROM
                 BOM_IMPLOSION_TEMP bit, BOM_BILL_OF_MATERIALS bbom
           WHERE
		 bit.parent_item_id = bbom.assembly_item_id
		 AND bit.organization_id = bbom.organization_id
		 AND bbom.bill_sequence_id = bbom.common_bill_sequence_id
		 AND bbom.alternate_bom_designator IS NULL);

           DELETE FROM bom_implosion_temp;
	END LOOP;  -- Completed Implosion all the Modified Bills.
	COMMIT;
	dbms_mview.refresh('ENI_DBI_BOM_COMPONENTS_MV2','F');

end collect_modified_bills;

procedure assign_worker_ids(p_collect_mode IN VARCHAR2) is
begin
 IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
  THEN NULL;
  END IF;

   IF (p_collect_mode = 'INIT') THEN
       -- Distributing the work equally among all the workers i.e., assigning equal number of Bills
       -- to all the workers for explosion.
	execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.ENI_DBI_PCO_WORKER_ASSIGNMENTS';

	IF (g_organization_id IS NULL) THEN
	  -- Insert statement to insert into the worker assigments table when
	  -- no organization is selected
		INSERT INTO eni_dbi_pco_worker_assignments
		(
			assembly_item_id,
			organization_id,
			pto_flag,
			bom_type,
			worker_id,
			incr_status
		)
	       (select
		   bbom.assembly_item_id AS inventory_item_id,
		   bbom.organization_id,
		   msi.pick_components_flag AS pto_flag,
		   msi.bom_item_type AS bom_type,
		   NULL worker_id,
		   0 AS incr_status
	       from bom_structures_b bbom,mtl_system_items_b msi  -- Bug # 3394284
	       where bill_sequence_id = common_bill_sequence_id and
		   bbom.alternate_bom_designator IS NULL and
		   bbom.organization_id = msi.organization_id and
		   bbom.assembly_item_id = msi.inventory_item_id and
		   msi.bom_item_type <> 2);
	ELSE
	  -- Modified for bug # 3669751
	  -- Statement to insert into the worker assignments table when
	  -- an organization is selected.
	  -- All the common / non-common bills in the organization selected are inserted.
		INSERT INTO eni_dbi_pco_worker_assignments
		(
			assembly_item_id,
			organization_id,
			pto_flag,
			bom_type,
			worker_id,
			incr_status
		)
		(select UNIQUE
		        NVL(bbom.common_assembly_item_id,assembly_item_id) AS inventory_item_id,
			NVL(bbom.common_organization_id,bbom.organization_id) AS organization_id,
			msi.pick_components_flag AS pto_flag,
		        msi.bom_item_type AS bom_type,
			NULL worker_id,
			0 AS incr_status
		from    bom_structures_b bbom,mtl_system_items_b msi
		where
			bbom.alternate_bom_designator IS NULL and
			bbom.organization_id = g_organization_id and
			NVL(bbom.common_organization_id,bbom.organization_id) = msi.organization_id and
			NVL(bbom.common_assembly_item_id,bbom.assembly_item_id) = msi.inventory_item_id and
			msi.bom_item_type <> 2 );
		COMMIT; -- Commit the bills to be collected into the worker assignments table

		DELETE FROM eni_dbi_part_count_f
		WHERE (assembly_item_id,organization_id) IN
		      (SELECT assembly_item_id, organization_id
		       FROM eni_dbi_pco_worker_assignments);
		COMMIT;
	END IF;

       SELECT sysdate into g_collection_date from dual;

   ELSIF (p_collect_mode = 'INCR') THEN
       ENI_DBI_PCO_LOAD_PKG.collect_modified_bills;
         -- procedure collects all the modified bills' information for incremental collection.
   END IF;

end assign_worker_ids;

procedure launch_workers(p_collect_mode IN VARCHAR2) is
	l_request_id number;
begin
     g_conc_request_array := g_conc_request_varray(null,null,null,null,null,null,
null,null,null,null);

fnd_profile.put('CONC_SINGLE_THREAD','N');

        for i in 1..g_actual_workers LOOP
            l_request_id := FND_REQUEST.SUBMIT_REQUEST
			   (
			     application => 'ENI',              -- Application short name
			     program => 'ENI_DBI_PCO_LOAD_WORKER', -- concurrent program short name
			     description => null,               -- description (optional)
			     start_time  => sysdate,
			     sub_request => false,              -- called from another conc. request
			     argument1   => i,
			     argument2   => g_batch_size,
			     argument3   => p_collect_mode);
		 commit;
		 g_conc_request_array(i).request_id := l_request_id;
		 g_conc_request_array(i).request_phase := 'NORMAL';
        end loop;

end launch_workers;

PROCEDURE wait_for_workers(p_collect_mode IN VARCHAR2) IS

l_request_flag boolean;
o_phase varchar2(100);
o_status varchar2(100);
o_dev_phase varchar2(100);
o_dev_status varchar2(100);
o_message varchar2(100);
l_done_flag varchar2(1);
l_error_occured NUMBER := 0;
l_error_code NUMBER;

BEGIN

   while (true) loop

        for i in 1 .. g_actual_workers loop

         -- Find out the phase of this request id.

         l_request_flag := fnd_concurrent.get_request_status(g_conc_request_array(i).request_id,
                                           null,
                                           null,
                                           o_phase,
                                           o_status,
                                           o_dev_phase,
                                           o_dev_status,
                                           o_message);

         -- set the phase of this request id in the array
         g_conc_request_array(i).request_phase := o_phase;

         end loop;
         l_done_flag := 'Y';
        for i in 1..g_actual_workers loop
         if ( g_conc_request_array(i).request_phase <> 'Completed') then
          l_done_flag := 'N';
         end if;
        end loop;
        if l_done_flag = 'Y' then
          exit;
        end if;
   end loop;

   SELECT COUNT(*)
   INTO l_error_occured
   FROM ENI_DBI_PCO_WORKER_ASSIGNMENTS
   WHERE incr_status = -1;

   IF (l_error_occured <> 0) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Incremental Collection has errored out.');
	RETURN;
   END IF;

   IF (p_collect_mode = 'INIT') THEN  -- when initial collection, complete refresh the MV

       DBMS_MVIEW.REFRESH('ENI_DBI_PART_COUNT_MV','C');

   ELSE -- When Incremental collection

        -- Deleting from part count fact table the data for all the modified Bills.
	  DELETE FROM ENI_DBI_PART_COUNT_F
	  WHERE
	     (assembly_item_id,organization_id) IN
	     (SELECT assembly_item_id, organization_id FROM eni_dbi_pco_worker_assignments);
	  commit;

	  INSERT INTO ENI_DBI_PART_COUNT_F(
                        assembly_item_id,
                        organization_id,
                        item_id_fk,
                        component_item_id,
                        effectivity_date,
                        disable_date,
                        bom_level,
                        ITEM_CATALOG_GROUP_ID
                       )
	  (SELECT assembly_item_id,
	          organization_id,
	          '-1',
	          component_item_id,
	          effectivity_date,
	          disable_date,
	          bom_level,
	          -1
	   FROM ENI_DBI_PART_COUNT_INCR_TEMP);
	   COMMIT;
           BEGIN
              DBMS_MVIEW.REFRESH('ENI_DBI_PART_COUNT_MV','F');
           /* Bug 5130157
              Full refresh might raise error ORA 12034
              catch it and execute a full refresh instead
           */
           EXCEPTION
           WHEN OTHERS THEN
               l_error_code := SQLCODE;
               IF l_error_code = -12034 THEN
                  DBMS_MVIEW.REFRESH('ENI_DBI_PART_COUNT_MV','C');
               ELSE
                  RAISE;
               END IF;
           END;
    END IF;

END WAIT_FOR_WORKERS;

procedure cleanup is
begin

IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
  THEN NULL;
  END IF;

   -- Truncate all the temporary tables used.
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_eni_schema||'.ENI_DBI_PCO_WORKER_ASSIGNMENTS';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_eni_schema||'.ENI_DBI_PART_COUNT_INCR_TEMP';
--   DELETE FROM mlog$_bom_components_b;
--   DELETE FROM mlog$_bom_structures_b;

end cleanup;

procedure process_incident_interface_g(
  o_err_code out nocopy varchar2,
  o_err_msg out nocopy varchar2,
  p_num_workers in number default 1,
  p_organization_id IN NUMBER default NULL,
  p_batch_size in number default 10,
  p_collect_mode IN VARCHAR2 default 'INIT',
  p_purge_fact IN VARCHAR2 default 'YES'
) IS
l_num_recs_to_process NUMBER;
l_worker_id NUMBER;
s_id NUMBER(10);
start_time date;
end_time date;
time_taken number(20,10);
l_error_msg varchar2(1000);
l_error_code varchar2(1000);
worker_id NUMBER(2);
l_org_exists NUMBER;

begin

-- Initialize variables
  g_organization_id := p_organization_id;
  g_actual_workers := p_num_workers;
  g_batch_size := NVL(p_batch_size,1);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'collection mode parameter is  = ' || p_collect_mode);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch size = ' || g_batch_size);

  IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
   THEN NULL;
  END IF;

  IF (p_collect_mode = 'INIT') THEN
     IF ((p_purge_fact = 'YES') OR (p_organization_id IS NULL)) THEN

	IF (BIS_COLLECTION_UTILITIES.SETUP(p_object_name => 'ENI_DBI_PART_COUNT_F') = false) then
		RAISE_APPLICATION_ERROR(-20000,l_error_msg);
	END IF;

	execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_part_count_f';
	execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_part_count_org_temp';

	DBMS_MVIEW.REFRESH('ENI_DBI_BOM_COMPONENTS_MV1','C');
	DBMS_MVIEW.REFRESH('ENI_DBI_BOM_COMPONENTS_MV2','C');

        IF (p_organization_id IS NULL) THEN
		INSERT INTO eni_dbi_part_count_org_temp
		(organization_id)
		(SELECT organization_id from hr_all_organization_units);
		COMMIT;
	ELSE
	   	INSERT INTO eni_dbi_part_count_org_temp
		(organization_id) VALUES (p_organization_id);
		COMMIT;
	END IF;
     ELSE
--        delete from eni_dbi_part_count_f
--	where organization_id = p_organization_id;
--	COMMIT;

	SELECT NVL((SELECT 1 from eni_dbi_part_count_org_temp
			where organization_id = p_organization_id),-1)
	INTO l_org_exists
	FROM DUAL;
	IF (l_org_exists = -1) THEN
	   	INSERT INTO eni_dbi_part_count_org_temp
		(organization_id) VALUES (p_organization_id);
		COMMIT;
	END IF;
     END IF;

  ELSE
        execute immediate 'TRUNCATE TABLE '||g_eni_schema||'.eni_dbi_part_count_incr_temp';
	IF (BIS_COLLECTION_UTILITIES.SETUP(p_object_name => 'ENI_DBI_PART_COUNT_F') = false) then
		RAISE_APPLICATION_ERROR(-20000,l_error_msg);
	END IF;
  END IF;

    -- Assign worker ids to the interface table records
  ENI_DBI_PCO_LOAD_PKG.assign_worker_ids(p_collect_mode);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'assign worker ids');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Started Execution...............');

  SELECT count(*)
  INTO l_num_recs_to_process
  FROM eni_dbi_pco_worker_assignments;

  IF (l_num_recs_to_process <= 0) THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Bills to work upon');
	RETURN;
   ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of Bills to work upon is:' || l_num_recs_to_process);
  END IF;

    -- Validate the parameters and reset them if required
       ENI_DBI_PCO_LOAD_PKG.validate_set_parameters(p_num_workers,p_batch_size);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'validate_set_parameters');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'after validate Batch size = ' || g_batch_size);


    -- Launch workers
       ENI_DBI_PCO_LOAD_PKG.launch_workers(p_collect_mode);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'launch workers..');

    -- Wait for the workers to complete the collection.
       IF (p_collect_mode = 'INCR') THEN
		ENI_DBI_PCO_LOAD_PKG.wait_for_workers('INCR');
		ENI_DBI_PCO_LOAD_PKG.cleanup;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'wait for workers is complete');
		BIS_COLLECTION_UTILITIES.WRAPUP(
                    p_status => true,
                    p_period_from => sysdate,
		    p_period_to => g_collection_date);
       ELSE
    	    ENI_DBI_PCO_LOAD_PKG.wait_for_workers('INIT');
            IF ((p_purge_fact = 'YES') OR (p_organization_id IS NULL)) THEN
		BIS_COLLECTION_UTILITIES.WRAPUP(
                    p_status => true,
                    p_period_from => sysdate,
		    p_period_to => g_collection_date);
	    END IF;
       END IF;

END process_incident_interface_g;

PROCEDURE part_count_collect_worker(
    o_error_msg OUT NOCOPY VARCHAR2,
    o_error_code OUT NOCOPY VARCHAR2,
    p_worker_id IN NUMBER DEFAULT 1,
    p_batch_size IN NUMBER DEFAULT 50,
    p_collect_mode IN VARCHAR2 DEFAULT 'INIT'
)IS
l_error NUMBER := 0;
start_time DATE;
end_time DATE;
time_taken NUMBER(20,10);
s_id NUMBER(10);
p_error_occured NUMBER := 0;
	-- the set of items in mtl_system_items_b
	-- which have BOM_ENABLED_FLAG set to 'Y'.
begin

  IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
   THEN NULL;
  END IF;


    WHILE (TRUE) LOOP
        -- Updating the rows to be worked on by the worker by setting worker_id.

	SELECT count(*)
	INTO l_error
	FROM eni_Dbi_pco_worker_assignments
	WHERE incr_status = -1;

	IF (l_error > 0) THEN
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'Error has occured during the collection');
	     o_error_code := 2;
	     o_error_msg := 'Error';
	     EXIT;
	END IF;

	UPDATE eni_dbi_pco_worker_assignments
	SET worker_id = p_worker_id , incr_status = 1
	WHERE worker_id IS NULL AND incr_status = 0
	AND rownum <= p_batch_size;

	IF (SQL%ROWCOUNT = 0) THEN
		EXIT;
	ELSE
	        COMMIT;
		ENI_DBI_PCO_LOAD_PKG.part_count_collect(p_worker_id,p_collect_mode,p_error_occured);

		-- Updating the status of the rows worked upon to 0.
		UPDATE eni_dbi_pco_worker_assignments
		SET incr_status = 0
		WHERE worker_id = p_worker_id AND incr_status = 1;
		COMMIT;

		IF (NVL(p_error_occured,0) = 1) THEN
		    o_error_code := 1;
		    o_error_msg := 'Warning';
		ELSIF (NVL(p_error_occured,0) = 2) THEN
		    o_error_code := 2;
		    o_error_msg := 'Error occured';
		    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_eni_schema||'.ENI_DBI_PART_COUNT_F';
		END IF;
	END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
      o_error_code := 2;
      o_error_msg := SQLERRM;
      eni_dbi_util_pkg.log('An error prevented the initial part count collection from completing successfully');
      eni_dbi_util_pkg.log(o_error_code||':'||o_error_msg);
      ROLLBACK;
END part_count_collect_worker;

-- This is the procedure to collect the bills assigned to the worker p_worker_id into Part Count Fact.
PROCEDURE part_count_collect(
    p_worker_id IN NUMBER,
    p_collect_mode IN VARCHAR2 DEFAULT 'INIT',
    o_error_occured OUT NOCOPY NUMBER
) IS
CURSOR c_bom_enabled_items(p_worker_id IN NUMBER) IS
    SELECT
        assembly_item_id,
        organization_id,
        pto_flag,
        bom_type
    FROM
        eni_dbi_pco_worker_assignments worker_bills
    WHERE
        worker_bills.worker_id = p_worker_id and
	worker_bills.incr_status = 1 ;
l_grp_id NUMBER := 0;
l_inventory_item_id NUMBER;
l_org_id NUMBER;
l_bill_sequence_id NUMBER;
l_incr_flag NUMBER := 0;
l_item_org VARCHAR2(50);
l_error_msg VARCHAR2(1000);
l_error_code VARCHAR2(1000);

BEGIN

  IF(FND_INSTALLATION.GET_APP_INFO('BOM', l_status, l_industry, g_bom_schema))
   THEN NULL;
  END IF;

  IF(FND_INSTALLATION.GET_APP_INFO('ENI', l_status, l_industry, g_eni_schema))
   THEN NULL;
  END IF;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_bom_schema||'.BOM_EXPLOSION_TEMP';
    FOR r_bom_enabled_items IN c_bom_enabled_items(p_worker_id) LOOP
       l_org_id := r_bom_enabled_items.organization_id;
       l_inventory_item_id := r_bom_enabled_items.assembly_item_id;
       l_grp_id := l_grp_id + 1;
       -- run the bom exploder for this item
       IF (NOT((r_bom_enabled_items.pto_flag = 'Y') and (r_bom_enabled_items.bom_type = 2))) THEN
       -- Modified the call to bom exploder to call the procedure explode as per the BOM bug fix # 3575617
              bompexpl.explode(
                    org_id => l_org_id,
                    bom_or_eng => 2,
                    std_comp_flag => 2,
                    grp_id => l_grp_id,
                    levels_to_explode => 60,
                    item_id => l_inventory_item_id,
                    rev_date => '1900/01/01 1:00', -- Made changes as per the bug # 3575617
                    explode_option => 1,
                    err_msg => l_error_msg,
                    error_code => l_error_code);

             IF (l_error_code <> 0) OR l_error_msg IS NOT NULL THEN
		      -- Error in Explosion
		 SELECT bbom.bill_sequence_id INTO l_bill_sequence_id
		 FROM   BOM_STRUCTURES_B bbom              -- Bug # 3394284
		 WHERE 	bbom.assembly_item_id = l_inventory_item_id
			AND bbom.organization_id = l_org_id
			AND bbom.alternate_bom_designator IS NULL
			AND bbom.bill_sequence_id = bbom.common_bill_sequence_id;
		 ENI_DBI_UTIL_PKG.LOG('Error occured during the explosion of Item-Org ' || l_inventory_item_id || '-' || l_org_id ||' of Bill_Sequence_id' || l_bill_sequence_id);
		 ENI_DBI_UTIL_PKG.LOG(l_error_code||':'||l_error_msg);

		 IF (l_error_msg <> 'BOM_MAX_LEVELS') THEN -- Modified as part of the fix for the Bug # 3140363
                     l_error_code := 2;  -- Modified as part of the fix for the Bug # 3127260
		     o_error_occured := 2;
		        -- Error
		     UPDATE eni_dbi_pco_worker_assignments
		     SET incr_status = -1
		     WHERE
			worker_id = p_worker_id AND
			assembly_item_id = l_inventory_item_id AND
			organization_id = l_org_id;
		     COMMIT;
		     EXECUTE IMMEDIATE 'truncate table '||g_eni_schema||'.eni_dbi_part_count_f';
		     RETURN; -- Returning with out collecting remaining bills due to error
                 ELSE
		     ENI_DBI_UTIL_PKG.LOG('Increase the MAX_BOM_LEVEL value in the profile of the Organization ' || l_org_id);
		     ENI_DBI_UTIL_PKG.LOG('If the MAX_BOM_LEVEL value is 59, then this is max number of levels possible for explosion.');
		     l_error_code := 1; -- Warning
		     o_error_occured := 1;
                 END IF;          -- BOM_MAX_LEVELS check end

	    END IF;               -- Explosion error check end
         END IF;                  -- end of explosion for the current item-org
    END LOOP;                     -- end of explosion of all the Bills

    FOR l_temp_var IN 1..1 LOOP
    BEGIN
        IF (p_collect_mode = 'INIT') THEN
		INSERT /*+ APPEND */ INTO eni_dbi_part_count_f
		(
			assembly_item_id,
			organization_id,
			item_id_fk,
			component_item_id,
			effectivity_date,
			disable_date,
			bom_level,
			ITEM_CATALOG_GROUP_ID
		)
		SELECT
			b1.top_item_id,
			b1.organization_id,
			'-1',
			b1.component_item_id AS component_item_id,
			trunc(b1.effectivity_date),
			trunc(NVL(b1.disable_date,to_date('1-1-2085','dd-mm-yyyy'))),
			b1.plan_level,
			-1
		FROM
			bom_explosion_temp b1,mtl_system_items_b i
		WHERE
			b1.component_sequence_id IS NOT NULL and
			b1.bom_item_type <> 2  and
			    -- Filtering out the Option classes items which
			    -- donot have Bills attached to them.
   -- Bug 3968305: use wip_supply_type at component-level, not item-level
			b1.wip_supply_type <> 6  and
			    --  Filtering out the phantom items.
			b1.component_item_id = i.inventory_item_id and
			b1.organization_id = i.organization_id and
			not exists (
			   select 1 from bom_bill_of_materials bbom
			   where bbom.assembly_item_id = b1.component_item_id and
			   bbom.organization_id = b1.organization_id) and
		       (NOT(((1,'PTO') IN (select i3.bom_item_type,i3.item_type
				from mtl_system_items_b i3
				where i3.inventory_item_id = b1.top_item_id and
				i3.organization_id = b1.organization_id)) and
		       ((2,'POC') IN (select i2.bom_item_type,i2.item_type
				from mtl_system_items_b i2
				where i2.inventory_item_id = b1.assembly_item_id and
			    i2.organization_id = b1.organization_id))));
	ELSE
		INSERT /*+ APPEND */ INTO eni_dbi_part_count_incr_temp
		(
			assembly_item_id,
			organization_id,
			component_item_id,
			effectivity_date,
			disable_date,
			bom_level
		)
		SELECT
			b1.top_item_id,
			b1.organization_id,
			b1.component_item_id AS component_item_id,
			trunc(b1.effectivity_date),
			trunc(NVL(b1.disable_date,to_date('1-1-2085','dd-mm-yyyy'))),
			b1.plan_level
		FROM
			bom_explosion_temp b1,mtl_system_items_b i
		WHERE
			b1.component_sequence_id IS NOT NULL and
			b1.bom_item_type <> 2  and
			    -- Filtering out the Option classes items which
			    -- donot have Bills attached to them.
   -- Bug 3968305: use wip_supply_type at component-level, not item-level
			b1.wip_supply_type <> 6  and
			    --  Filtering out the phantom items.
			b1.component_item_id = i.inventory_item_id and
			b1.organization_id = i.organization_id and
			not exists (
			   select 1 from bom_bill_of_materials bbom
			   where bbom.assembly_item_id = b1.component_item_id and
			   bbom.organization_id = b1.organization_id) and
		       (NOT(((1,'PTO') IN (select i3.bom_item_type,i3.item_type
				from mtl_system_items_b i3
				where i3.inventory_item_id = b1.top_item_id and
				i3.organization_id = b1.organization_id)) and
		       ((2,'POC') IN (select i2.bom_item_type,i2.item_type
				from mtl_system_items_b i2
				where i2.inventory_item_id = b1.assembly_item_id and
			    i2.organization_id = b1.organization_id))));
	END IF;
    EXCEPTION
	WHEN OTHERS THEN
		l_error_msg := SQLERRM;
		l_error_code := 2;
		    -- Modified as part of the fix for the Bug # 3127260
		FND_FILE.PUT_LINE(FND_FILE.LOG,'The following error has occured while inserting into the Part Count fact table');
		ENI_DBI_UTIL_PKG.LOG(l_error_code||':'||l_error_msg);
		ENI_DBI_UTIL_PKG.LOG('An error prevented the INCREMENTAL part count collection from completing successfully');
		EXECUTE IMMEDIATE 'truncate table '||g_eni_schema||'.eni_dbi_part_count_f';
		RETURN; -- Return from the for loop after the explosion.
    END;
END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      l_error_code := 2;
      l_error_msg := SQLERRM;
      ENI_DBI_UTIL_PKG.LOG('An error prevented the initial part count collection from completing successfully');
      ENI_DBI_UTIL_PKG.LOG(l_error_code||':'||l_error_msg);

END PART_COUNT_COLLECT;  -- End of the procedure definition

END ENI_DBI_PCO_LOAD_PKG;

/
