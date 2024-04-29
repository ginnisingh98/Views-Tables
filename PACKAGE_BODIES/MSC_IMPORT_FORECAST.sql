--------------------------------------------------------
--  DDL for Package Body MSC_IMPORT_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_IMPORT_FORECAST" AS
/* $Header: MSCIFSTB.pls 120.1 2005/06/21 02:55:40 appldev ship $  */

PROCEDURE Import_Forecast(
		    ERRBUF              OUT NOCOPY VARCHAR2,
   		    RETCODE             OUT NOCOPY NUMBER,
		    v_req_id	    	IN  NUMBER) -- not used for now
IS
  l_user_id number := fnd_global.user_id;
BEGIN
	-- Validate Seller Code
	update  msc_st_demands
	set     ATTRIBUTE11 = 'ERROR',
			ATTRIBUTE15 = 'Invalid Seller Code'
	where   not exists (select 'exists'
			    		from	HZ_PARTIES HP,
								MSC_ST_DEMANDS MSD
			    		where	HP.PARTY_NAME = MSD.ATTRIBUTE1
							and	HP.PARTY_TYPE = 'ORGANIZATION')
	and	ATTRIBUTE11 = 'NEW'
	and	ATTRIBUTE8 in ('FORECAST');

	-- Validate Buyer Code
	update  msc_st_demands
	set		ATTRIBUTE11 = 'ERROR',
			ATTRIBUTE15 = 'Invalid Buyer Code'
	where   not exists ( 	select 	'exists'
							from	HZ_PARTIES HP,
									MSC_ST_DEMANDS MSD
							where  	HP.PARTY_NAME = MSD.ATTRIBUTE2
                                and HP.PARTY_TYPE = 'ORGANIZATION')
    and	ATTRIBUTE11 = 'NEW'
	and	ATTRIBUTE8 in ('FORECAST');

    -- Validate Quantity
	update  msc_st_demands
	set     ATTRIBUTE11 = 'ERROR',
		ATTRIBUTE15 = 'Invalid Forecast Quantity'
	where   ATTRIBUTE11 = 'NEW'
	and	ATTRIBUTE8 = 'FORECAST'
	and	ATTRIBUTE7 < 0 ;

	-- Insert any new items into MSC_ITEMS
	insert into MSC_ITEMS(  INVENTORY_ITEM_ID,
				ITEM_NAME,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY )
	select  MSC_ITEMS_S.NEXTVAL,
		MSD1.ATTRIBUTE3,
		SYSDATE,
		l_user_id,
		SYSDATE,
		l_user_id
	from    (select  distinct MSD.ATTRIBUTE3
		 from 	 msc_st_demands MSD
		 where   MSD.ATTRIBUTE11 = 'NEW'
	 	 and  MSD.ATTRIBUTE8 = 'FORECAST'
		 and not exists (select 'exists'
				from msc_items item
				where item.item_name = MSD.ATTRIBUTE3)) MSD1;

	-- Do monster insert into msc_system_items for Seller

	insert into MSC_SYSTEM_ITEMS(
                        PLAN_ID, ORGANIZATION_ID,
			INVENTORY_ITEM_ID, SR_INSTANCE_ID,
			SR_INVENTORY_ITEM_ID,ITEM_NAME,
			LOT_CONTROL_CODE, ROUNDING_CONTROL_TYPE,
			IN_SOURCE_PLAN, MRP_PLANNING_CODE,
			FULL_LEAD_TIME, UOM_CODE,
			ATP_COMPONENTS_FLAG, BUILD_IN_WIP_FLAG,
			PURCHASING_ENABLED_FLAG, PLANNING_MAKE_BUY_CODE,
			REPETITIVE_TYPE, ENGINEERING_ITEM_FLAG,
			WIP_SUPPLY_TYPE, SAFETY_STOCK_CODE,
			EFFECTIVITY_CONTROL, INVENTORY_PLANNING_CODE,
			CALCULATE_ATP, ATP_FLAG,
			LAST_UPDATE_DATE, LAST_UPDATED_BY,
			CREATION_DATE, CREATED_BY)
	select	TO_NUMBER(MSD1.ATTRIBUTE9),
		MSD1.PARTY_ID,
		MSD1.INVENTORY_ITEM_ID,
		TO_NUMBER(MSD1.ATTRIBUTE10),
		MSD1.INVENTORY_ITEM_ID,
		MSD1.ATTRIBUTE3,
		'-1', '-1',
		'-1', '-1',
		'-1', MSD1.ATTRIBUTE4,
		'z', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', 'z',
		SYSDATE, l_user_id,
		SYSDATE, l_user_id
		from (select distinct
                        MSD.ATTRIBUTE1,
			MSD.ATTRIBUTE3,
			MSD.ATTRIBUTE4,
			MSD.ATTRIBUTE9,
			MSD.ATTRIBUTE10,
			hp.party_id,
			mi.inventory_item_id
			from 	msc_st_demands MSD,
				hz_parties hp,
				msc_items mi
			where 	mi.item_name = MSD.ATTRIBUTE3
			and     MSD.ATTRIBUTE1 = hp.party_name
                        and     hp.party_type = 'ORGANIZATION'
			and	MSD.ATTRIBUTE11 = 'NEW'
			and	MSD.ATTRIBUTE8 = 'FORECAST'
			and not exists
                ( select 'exists'
				  from  msc_st_demands,
					hz_parties,
					msc_system_items msi
				where   msi.organization_id = hp.party_id
				and	hp.party_name = MSD.ATTRIBUTE1
                                and     hp.party_type = 'ORGANIZATION'
				and msi.item_name = MSD.ATTRIBUTE3)) MSD1;

	-- Do monster insert into msc_system_items for Buyer

	insert into MSC_SYSTEM_ITEMS(
                PLAN_ID, ORGANIZATION_ID,
		INVENTORY_ITEM_ID, SR_INSTANCE_ID,
		SR_INVENTORY_ITEM_ID,ITEM_NAME,
		LOT_CONTROL_CODE, ROUNDING_CONTROL_TYPE,
		IN_SOURCE_PLAN, MRP_PLANNING_CODE,
		FULL_LEAD_TIME, UOM_CODE,
		ATP_COMPONENTS_FLAG, BUILD_IN_WIP_FLAG,
		PURCHASING_ENABLED_FLAG, PLANNING_MAKE_BUY_CODE,
		REPETITIVE_TYPE, ENGINEERING_ITEM_FLAG,
		WIP_SUPPLY_TYPE, SAFETY_STOCK_CODE,
		EFFECTIVITY_CONTROL, INVENTORY_PLANNING_CODE,
		CALCULATE_ATP, ATP_FLAG,
		LAST_UPDATE_DATE, LAST_UPDATED_BY,
		CREATION_DATE, CREATED_BY)
	select	TO_NUMBER(MSD1.ATTRIBUTE9),
		MSD1.PARTY_ID,
		MSD1.INVENTORY_ITEM_ID,
		TO_NUMBER(MSD1.ATTRIBUTE10),
		MSD1.INVENTORY_ITEM_ID,
		MSD1.ATTRIBUTE3,
		'-1', '-1',
		'-1', '-1',
		'-1', MSD1.ATTRIBUTE4,
		'z', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', '-1',
		'-1', 'z',
		SYSDATE, '-1',
		SYSDATE, '-1'
	from (select distinct
        	MSD.ATTRIBUTE2,
		MSD.ATTRIBUTE3,
		MSD.ATTRIBUTE4,
		MSD.ATTRIBUTE9,
		MSD.ATTRIBUTE10,
		hp.party_id,
		mi.inventory_item_id
	      from 	msc_st_demands MSD,
			hz_parties hp,
			msc_items mi
	      where mi.item_name = MSD.ATTRIBUTE3
	      and   MSD.ATTRIBUTE2 = hp.party_name
              and   hp.party_type = 'ORGANIZATION'
	      and   MSD.ATTRIBUTE11 = 'NEW'
              and   MSD.ATTRIBUTE8 = 'FORECAST'
              and not exists ( select 'exists'
				from    msc_st_demands,
					hz_parties,
					msc_system_items msi
				where   msi.organization_id = hp.party_id
				and	hp.party_name = MSD.ATTRIBUTE2
                                and     hp.party_type = 'ORGANIZATION'
				and msi.item_name = MSD.ATTRIBUTE3)) MSD1;

	-- Insert forecast entries
	insert into msc_demands(
                DEMAND_ID,
		USING_REQUIREMENT_QUANTITY,
		ASSEMBLY_DEMAND_COMP_DATE,
		USING_ASSEMBLY_DEMAND_DATE,
		DEMAND_TYPE,
		USING_ASSEMBLY_ITEM_ID,
		PLAN_ID,
		ORGANIZATION_ID,
                CUSTOMER_ID,
		INVENTORY_ITEM_ID,
		SR_INSTANCE_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY)
	select  MSC_DEMANDS_S.NEXTVAL,
		TO_NUMBER(MSD.ATTRIBUTE7),
		TO_DATE(MSD.ATTRIBUTE6, 'MM/DD/YYYY'),
		TO_DATE(MSD.ATTRIBUTE5, 'MM/DD/YYYY'),
		TO_NUMBER(MSD.ATTRIBUTE12),
		mi.inventory_item_id,
		TO_NUMBER(MSD.ATTRIBUTE9),
		seller.party_id,
                buyer.party_id,
		mi.inventory_item_id,
		TO_NUMBER(MSD.ATTRIBUTE10),
		SYSDATE,
		'-1',
		SYSDATE,
		'-1'
	from    hz_parties seller,
                hz_parties buyer,
		msc_items mi,
		msc_st_demands MSD
	where   seller.party_name = msd.attribute1
        and     seller.party_type = 'ORGANIZATION'
        and     buyer.party_name = msd.attribute2
        and     buyer.party_type = 'ORGANIZATION'
	and MSD.ATTRIBUTE3 = mi.item_name
	and MSD.ATTRIBUTE11 = 'NEW'
	and MSD.ATTRIBUTE8 = 'FORECAST';

	UPDATE msc_st_demands
        SET ATTRIBUTE11 = 'IMPORTED'
	where 	ATTRIBUTE11 = 'NEW'
	and ATTRIBUTE8 = 'FORECAST';

        retcode := 0;
        errbuf := null;
        COMMIT;
        dbms_mview.refresh('msc_hz_bucketed_demands_mv');
exception
   when others then
     errbuf := 'Error:' || to_char(sqlcode) || ':' || substr(sqlerrm,1,60);
     retcode := 2; -- error;
     return;
END Import_Forecast;

END MSC_IMPORT_FORECAST;

/
