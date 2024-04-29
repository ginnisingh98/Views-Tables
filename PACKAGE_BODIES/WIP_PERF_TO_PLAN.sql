--------------------------------------------------------
--  DDL for Package Body WIP_PERF_TO_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PERF_TO_PLAN" AS
/* $Header: wipbptpb.pls 115.9 2002/11/28 19:22:55 rmahidha ship $ */

PROCEDURE Load_Performance_Info(
	errbuf	 OUT NOCOPY VARCHAR2,
	retcode	 OUT NOCOPY VARCHAR2,
	p_date_from	IN VARCHAR2,
	p_date_to	IN VARCHAR2) IS
x_errnum	NUMBER;
x_errmesg	VARCHAR2(240);
BEGIN
	--dbms_output.put_line('Inside the Load_Performance_Info procedure.');
	Populate_Performance(
		p_date_from => p_date_from,
		p_date_to => p_date_to,
		p_userid => null,
		p_applicationid => null,
		p_errnum => x_errnum,
		p_errmesg => x_errmesg);

	--dbms_output.put_line('After the Populate_Performance Procedure');

		errbuf := x_errmesg;
		retcode := to_char(x_errnum);
EXCEPTION
	WHEN OTHERS THEN
		--dbms_output.put_line('Error in the Populate_Performance.');
		retcode := 1;
		null;
END Load_Performance_Info;

PROCEDURE Populate_Performance(
	p_date_from		IN VARCHAR2,
	p_date_to		IN VARCHAR2,
	p_userid		IN NUMBER,
	p_applicationid		IN NUMBER,
	p_errmesg	 OUT NOCOPY VARCHAR2,
	p_errnum	 OUT NOCOPY NUMBER)
IS
	x_userid	NUMBER;
	x_applicationid	NUMBER;

p_from_date DATE;
p_to_date DATE;

BEGIN
	--dbms_output.put_line('Entered the Main_Populate_Performance procedure');

        p_from_date := FND_DATE.canonical_to_date(p_date_from);
        p_to_date := FND_DATE.canonical_to_date(p_date_to);

	if p_userid is null then
		x_userid := fnd_global.user_id;
	else
		x_userid := p_userid;
	end if;

	if p_applicationid is null then
		x_applicationid := fnd_global.prog_appl_id;
	else
		x_applicationid := p_applicationid;
	end if;

	p_errnum := 0;
	p_errmesg :='';

	-- To Clean up the temporary data which can be caused by exception (6/14/98)
	Clean_Up_Exception;

	--dbms_output.put_line('Before Stage 1');
	-- Populate Plan data and Who columns for the performance table
	Populate_Who(
		p_date_from => p_from_date,
		p_date_to => p_to_date,
		p_userid => x_userid,
		p_applicationid => x_applicationid,
		p_errnum => p_errnum,
		p_errmesg => p_errmesg);

        --Error in the called program
        if (p_errnum <> 0) then
                return;
        end if;

	--dbms_output.put_line('Before Stage 2');
	-- Now get the actual performance data and the item cost
	-- from  discrete jobs, flow schedules and repetitive schedules
	-- and update the performance table
	Update_Actual_Quantity(
                p_errnum => p_errnum,
                p_errmesg => p_errmesg);

        --Error in the called program
        if (p_errnum <> 0) then
                return;
        end if;

	--dbms_output.put_line('Initial Clean Up - Stage3');
	--Delete old data in the performance table, and commit new populated data

	Post_Populate_Perf_Info(
				p_errnum => p_errnum,
				p_errmesg => p_errmesg);

	--Error in the called program
	if (p_errnum <> 0) then
		return;
	end if;

	return;

EXCEPTION
	WHEN OTHERS THEN
		--dbms_output.put_line(SQLCODE);
		--dbms_output.put_line(SQLERRM);
		p_errmesg := substr(SQLERRM, 1, 150);
		p_errnum := SQLCODE;
                Clean_Up_Exception;
		return;
END Populate_Performance;

/*------------------------------------------------------------------------------
		Populate Planning data and Who columns for the performance table
		default actual_quantity = 0 and item_cost = 1
 -----------------------------------------------------------------------------*/

PROCEDURE Populate_Who(
	p_date_from		IN DATE,
	p_date_to		IN DATE,
	p_userid		IN NUMBER,
	p_applicationid		IN NUMBER,
        p_errmesg               OUT NOCOPY VARCHAR2,
        p_errnum                OUT NOCOPY NUMBER)

IS
BEGIN
        --dbms_output.put_line('Populate Plan data and Who columns');

        p_errnum := 0;
        p_errmesg :='';

	-- LOCK TABLE wip_bis_perf_to_plan IN EXCLUSIVE MODE NOWAIT;

	insert into wip_bis_perf_to_plan(
		ORGANIZATION_ID,
		INVENTORY_ITEM_ID,
		SCHEDULE_DATE,
		SCHEDULE_QUANTITY,
		ACTUAL_QUANTITY,
		ITEM_COST,
		EXISTING_FLAG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		PROGRAM_APPLICATION_ID
	)
	(select mbppv.organization_id,
		mbppv.inventory_item_id,
		mbppv.schedule_date,
		nvl(mbppv.schedule_quantity,0),
		0,
		0,
		0,
		sysdate,
		p_userid,
		sysdate,
		p_userid,
		p_applicationid
	from 	mrp_bis_plan_prod_v mbppv
	where	trunc(mbppv.schedule_date) between trunc(nvl(p_date_from,mbppv.schedule_date))
		and trunc(nvl(p_date_to,mbppv.schedule_date))
	);

	--dbms_output.put_line('Populate plan data and Who columns successfully.');
	commit;
	return;
EXCEPTION
        WHEN OTHERS THEN
		--dbms_output.put_line('Failed in Populate plan data and Who columns.');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errmesg :=  'Failed in Populate plan data and Who columns: ' ||substr(SQLERRM, 1, 150);
                p_errnum := SQLCODE;
		Clean_Up_Exception;
                return;

END Populate_Who;
/*------------------------------------------------------------------------------------
		to update the actual_quantity,item_cost for performance table
 ------------------------------------------------------------------------------------*/

PROCEDURE Update_Actual_Quantity(
	p_errmesg OUT NOCOPY VARCHAR2,
	p_errnum OUT NOCOPY NUMBER)
IS
sum_quantity		NUMBER;
complete_quantity	NUMBER;
p_item_cost		NUMBER;

CURSOR perf_cur IS
	SELECT 	organization_id,
		inventory_item_id,
		schedule_date,
		actual_quantity,
		item_cost
	FROM wip_bis_perf_to_plan WHERE existing_flag = 0 FOR UPDATE;
perf_rec perf_cur%ROWTYPE;

BEGIN
        p_errnum := 0;
        p_errmesg :='';

	--dbms_output.put_line('Start Update actual_quantity.');

	OPEN perf_cur;
	LOOP
		FETCH perf_cur INTO perf_rec;
		EXIT WHEN perf_cur%NOTFOUND or perf_cur%NOTFOUND IS NULL;

	-- Update the item_cost based on table cst_item_costs, mtl_parameters
		BEGIN
        		select distinct cic.item_cost into p_item_cost
        		from
               			cst_item_costs cic,
				mtl_parameters mp
        		where   mp.organization_id = perf_rec.organization_id
        		and     cic.organization_id = mp.organization_id
        		and     cic.inventory_item_id = perf_rec.inventory_item_id
        		and     cic.cost_type_id = mp.primary_cost_method;


		EXCEPTION
			WHEN NO_DATA_FOUND THEN p_item_cost := 0;
		END;


		sum_quantity := 0;

	-- For all the discrete jobs complete on schedule

		BEGIN
			select nvl(sum(mmt.primary_quantity),0) into complete_quantity
			from
				mtl_material_transactions mmt,
				wip_entities we,
				wip_discrete_jobs wdj

			where 	mmt.transaction_source_type_id = 5
			and	mmt.transaction_action_id in (31,32)
			and	wdj.organization_id = perf_rec.organization_id
			and	wdj.primary_item_id = perf_rec.inventory_item_id
			and	mmt.organization_id = wdj.organization_id
			and	mmt.inventory_item_id = wdj.primary_item_id
			and	mmt.transaction_source_id = wdj.wip_entity_id
			and	we.wip_entity_id = wdj.wip_entity_id
			and	we.entity_type in (1,3)
			and	trunc(mmt.transaction_date) <= trunc(wdj.scheduled_completion_date)
			and   	trunc(wdj.scheduled_completion_date) = trunc(perf_rec.schedule_date)

			group by
				mmt.inventory_item_id,
				trunc(wdj.scheduled_completion_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;

	-- for all the discrete jobs completed after the completion date
		BEGIN
		select nvl(sum(mmt.primary_quantity),0) into complete_quantity
		from
			mtl_material_transactions mmt,
			wip_entities we,
			wip_discrete_jobs wdj

		where 	mmt.transaction_source_type_id = 5
		and	mmt.transaction_action_id in (31,32)
		and	wdj.organization_id = perf_rec.organization_id
		and	wdj.primary_item_id = perf_rec.inventory_item_id
		and	mmt.organization_id = wdj.organization_id
		and	mmt.inventory_item_id = wdj.primary_item_id
		and	mmt.transaction_source_id = wdj.wip_entity_id
		and	we.wip_entity_id = wdj.wip_entity_id
		and	we.entity_type in (1,3)
		and	trunc(mmt.transaction_date) > trunc(wdj.scheduled_completion_date)
		and	trunc(mmt.transaction_date) = trunc(perf_rec.schedule_date)

		group by
			mmt.inventory_item_id,
			trunc(mmt.transaction_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;


	-- For all the flow schedules complete on schedule
		BEGIN
			select nvl(sum(mmt.primary_quantity),0) into complete_quantity
			from
				mtl_material_transactions mmt,
				wip_entities we,
	 			wip_flow_schedules wfs
			where 	mmt.transaction_source_type_id = 5
			and	mmt.transaction_action_id in (31,32)
			and	wfs.organization_id = perf_rec.organization_id
			and	wfs.primary_item_id = perf_rec.inventory_item_id
			and	mmt.organization_id = wfs.organization_id
			and	mmt.inventory_item_id = wfs.primary_item_id
			and	mmt.transaction_source_id = wfs.wip_entity_id
			and	we.wip_entity_id = wfs.wip_entity_id
			and	we.entity_type = 4
			and	trunc(mmt.transaction_date) <= trunc(wfs.scheduled_completion_date)
			and	trunc(wfs.scheduled_completion_date) = trunc(perf_rec.schedule_date)
			group by
				mmt.inventory_item_id,
				trunc(wfs.scheduled_completion_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;

	-- for all the flow schedules completed after the completion date
		BEGIN
		select 	nvl(sum(mmt.primary_quantity),0) into complete_quantity
		from
			mtl_material_transactions mmt,
			wip_entities we,
			wip_flow_schedules wfs

		where 	mmt.transaction_source_type_id = 5
		and	mmt.transaction_action_id in (31,32)
		and	wfs.organization_id = perf_rec.organization_id
		and	wfs.primary_item_id = perf_rec.inventory_item_id
		and	mmt.organization_id = wfs.organization_id
		and	mmt.inventory_item_id = wfs.primary_item_id
		and	mmt.transaction_source_id = wfs.wip_entity_id
		and	we.wip_entity_id = wfs.wip_entity_id
		and	we.entity_type = 4
		and	trunc(mmt.transaction_date) > trunc(wfs.scheduled_completion_date)
		and	trunc(mmt.transaction_date) = trunc(perf_rec.schedule_date)

		group by
			mmt.inventory_item_id,
			trunc(mmt.transaction_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;

		-- For all the repetitive schedules completed on schedule
		BEGIN
			select  nvl(sum(mmta.primary_quantity),0) into complete_quantity
			from
				wip_repetitive_schedules wrs,
				wip_entities we,
				mtl_material_transactions mmt,
				mtl_material_txn_allocations mmta
			where 	mmt.transaction_source_type_id = 5
			and	mmt.transaction_action_id in (31,32)
			and	wrs.organization_id = perf_rec.organization_id
			and	we.primary_item_id = perf_rec.inventory_item_id
			and	we.entity_type = 2
			and 	we.wip_entity_id = wrs.wip_entity_id
			and 	we.organization_id = wrs.organization_id
			and	mmta.organization_id = wrs.organization_id
			and	mmta.repetitive_schedule_id = wrs.repetitive_schedule_id
			and	mmt.organization_id = wrs.organization_id
			and	mmt.inventory_item_id = we.primary_item_id
			and	mmt.transaction_source_id = we.wip_entity_id
			and	mmt.transaction_id = mmta.transaction_id
			and	trunc(mmta.transaction_date) <= trunc(wrs.last_unit_completion_date)
			and	trunc(wrs.last_unit_completion_date) = trunc(perf_rec.schedule_date)
			group by
				mmt.inventory_item_id,
				trunc(wrs.last_unit_completion_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;

		-- for all the repetitive schedules completed after the completion date
		BEGIN
		select nvl(sum(mmta.primary_quantity),0) into complete_quantity
		from
			wip_repetitive_schedules wrs,
			wip_entities we,
			mtl_material_transactions mmt,
			mtl_material_txn_allocations mmta
		where 	mmt.transaction_source_type_id = 5
		and	mmt.transaction_action_id in (31,32)
		and	wrs.organization_id = perf_rec.organization_id
		and	we.primary_item_id = perf_rec.inventory_item_id
		and	we.entity_type = 2
		and 	we.wip_entity_id = wrs.wip_entity_id
		and 	we.organization_id = wrs.organization_id
		and	mmta.organization_id = wrs.organization_id
		and	mmta.repetitive_schedule_id = wrs.repetitive_schedule_id
		and	mmt.organization_id = wrs.organization_id
		and	mmt.inventory_item_id = we.primary_item_id
		and	mmt.transaction_source_id = we.wip_entity_id
		and	mmt.transaction_id = mmta.transaction_id
		and	trunc(mmta.transaction_date) > trunc(wrs.last_unit_completion_date)
		and	trunc(mmta.transaction_date) = trunc(perf_rec.schedule_date)
		group by
			mmt.inventory_item_id,
			trunc(mmta.transaction_date);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN complete_quantity := 0;
		END;

		sum_quantity := sum_quantity + complete_quantity;

		UPDATE wip_bis_perf_to_plan
		SET
			actual_quantity = actual_quantity + sum_quantity,
			item_cost = p_item_cost
		WHERE CURRENT OF perf_cur;

	END LOOP;

	CLOSE perf_cur;

        commit;
        --dbms_output.put_line('Update actual_quantity successfully.');
        return;
EXCEPTION
        WHEN OTHERS THEN
                --dbms_output.put_line('Failed in Update actual_quantity.');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errmesg :=  'Failed in Update actual_quantity: ' ||substr(SQLERRM, 1, 150);
                p_errnum := SQLCODE;
		if perf_cur%ISOPEN then
			--dbms_output.put_line('Close cursor when exception.');
			CLOSE perf_cur;
		end if;
		Clean_Up_Exception;
                return;
END Update_Actual_Quantity;


PROCEDURE Post_Populate_Perf_Info(
	        p_errnum	 OUT NOCOPY NUMBER,
       		p_errmesg	 OUT NOCOPY VARCHAR2)
IS

BEGIN

	p_errnum := 0;
	p_errmesg :='';

	-- LOCK TABLE wip_bis_perf_to_plan IN EXCLUSIVE MODE ; -- NOWAIT;
	--dbms_output.put_line('Delete all the old information from performance table.');
	delete from wip_bis_perf_to_plan where existing_flag <> 0;

	--dbms_output.put_line('Commit all the populated data');
	update wip_bis_perf_to_plan set existing_flag = 1;

	--dbms_output.put_line('all the populated data commited successfully.');

	commit;
	return;

  EXCEPTION
        WHEN OTHERS THEN
                --dbms_output.put_line('Failed in post populating performance table.');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errmesg :=  'Failed in post updating performance table: ' ||substr(SQLERRM, 1, 150);
                p_errnum := SQLCODE;
		delete from wip_bis_perf_to_plan;
		--dbms_output.put_line('All data deleted from wip_bis_perf_to_plan');
		commit;
		return;

		 --null;
End Post_Populate_Perf_Info;

PROCEDURE Clean_Up_Exception

IS
BEGIN


	-- LOCK TABLE wip_bis_perf_to_plan IN EXCLUSIVE MODE NOWAIT;

	-- Delete all the performance data not correctly populated
	delete from wip_bis_perf_to_plan
	where existing_flag = 0;

	commit;
	return;
EXCEPTION

        WHEN OTHERS THEN
                --dbms_output.put_line('Failed in cleaning up exception.');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);

                delete from wip_bis_perf_to_plan;
                --dbms_output.put_line('All data deleted from wip_bis_perf_to_plan');
                commit;
                return;

END Clean_Up_Exception;

END WIP_PERF_TO_PLAN;

/
