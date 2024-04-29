--------------------------------------------------------
--  DDL for Package Body MSC_IMPORT_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_IMPORT_ONHAND" AS
/* $Header: MSCIOHDB.pls 120.1 2005/06/21 02:45:02 appldev ship $  */

PROCEDURE Import_Onhand(
 	         ERRBUF              OUT NOCOPY VARCHAR2,
		RETCODE             OUT NOCOPY NUMBER,
		v_req_id	    	IN  NUMBER) -- not used this release

IS
 l_user_id number := fnd_global.user_id;
BEGIN
       -- Now for another kludge. First thing that we will do is to update
       -- all the fields in the msc_st_demands tables with the mapped supplier
       -- codes on the exchange
       -- Rob, please check and then run into the database as soon as Bala
       -- Desikan gives us the mapping codes
/*
       update msc_st_demands
       set    attribute1 = decode(attribute1,'F159B','',
                                             'T407H','',
                                             'U0WRC','',
                                             'EE02A','',
                                             'CC05A','',
                                             'AE2DA','',NULL),
              attribute2 = decode(attribute2,'F159B','',
                                             'T407H','',
                                             'U0WRC','',
                                             'EE02A','',
                                             'CC05A','',
                                             'AE2DA','',NULL)
       where  attribute11 = 'NEW'
       and    attribute8 in ('ONHAND','FORECAST');
*/
	-- Validate Buyer Code
	update  MSC_ST_DEMANDS
	set     ATTRIBUTE11 = 'ERROR',
			ATTRIBUTE15 = 'Invalid Buyer Code'
	where   not exists ( select 	'exists'
							from	HZ_PARTIES HP,
									MSC_ST_DEMANDS MSD
							where  	HP.PARTY_NAME = MSD.ATTRIBUTE1
                                and HP.PARTY_TYPE = 'ORGANIZATION')
	and	ATTRIBUTE11 = 'NEW'
	and	ATTRIBUTE8 = 'ONHAND';

    -- Validate Quantity
	update  MSC_ST_DEMANDS
	set     ATTRIBUTE11 = 'ERROR',
			ATTRIBUTE15 = 'Invalid Quantity'
	where   ATTRIBUTE11 = 'NEW'
		and	ATTRIBUTE8 = 'ONHAND'
		and	ATTRIBUTE7 is null;

	-- Insert any new items into MSC_ITEMS
	insert into MSC_ITEMS(  INVENTORY_ITEM_ID,
							ITEM_NAME,
							DESCRIPTION,
							LAST_UPDATE_DATE,
							LAST_UPDATED_BY,
							CREATION_DATE,
							CREATED_BY )
					select  MSC_ITEMS_S.NEXTVAL,
							MSD1.ATTRIBUTE3,
							MSD1.ATTRIBUTE13,
							SYSDATE,
							l_user_id,
							SYSDATE,
							l_user_id
					from    (select  distinct MSD.ATTRIBUTE3 , MSD.ATTRIBUTE13
		 					from 	 MSC_ST_DEMANDS MSD
		 					where   MSD.ATTRIBUTE11 = 'NEW'
	 						and  MSD.ATTRIBUTE8 = 'ONHAND'
		 					and not exists (select 'exists'
											from msc_items item
											where item.item_name = MSD.ATTRIBUTE3)) MSD1;

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
		SYSDATE, l_user_id,
		SYSDATE, l_user_id
		from (select 	distinct
                        MSD.ATTRIBUTE1,
						MSD.ATTRIBUTE3,
						MSD.ATTRIBUTE4,
						MSD.ATTRIBUTE9,
						MSD.ATTRIBUTE10,
						hp.party_id,
						mi.inventory_item_id
		      from  MSC_ST_DEMANDS MSD,
					hz_parties hp,
					msc_items mi
		      where mi.item_name = MSD.ATTRIBUTE3
		      and  MSD.ATTRIBUTE1 = hp.party_name
              and  hp.party_type = 'ORGANIZATION'
		      and  MSD.ATTRIBUTE11 = 'NEW'
		      and  MSD.ATTRIBUTE8 = 'ONHAND'
		      and not exists
                        ( select 'exists'
						from    MSC_ST_DEMANDS,
								hz_parties,
								msc_system_items msi
						where   msi.organization_id = hp.party_id
						and	hp.party_name = MSD.ATTRIBUTE1
                        and     hp.party_type = 'ORGANIZATION'
						and msi.item_name = MSD.ATTRIBUTE3)) MSD1;

		-- Insert Onhand into msc_supplies

		insert into msc_supplies(
                        PLAN_ID,
			TRANSACTION_ID,
			ORGANIZATION_ID,
			SR_INSTANCE_ID,
			INVENTORY_ITEM_ID,
			NEW_SCHEDULE_DATE,
			ORDER_TYPE,
			NEW_ORDER_QUANTITY,
			FIRM_PLANNED_TYPE,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY)
		select  TO_NUMBER(MSD.ATTRIBUTE9),
			MSC_SUPPLIES_S.NEXTVAL,
			hz.party_id,
			TO_NUMBER(MSD.ATTRIBUTE10),
			mi.inventory_item_id,
			TO_DATE(MSD.ATTRIBUTE5, 'MM/DD/YYYY'),
			to_number(MSD.ATTRIBUTE14), -- 18
			TO_NUMBER(LTRIM(MSD.ATTRIBUTE7,'0')),
			'-1',
			SYSDATE,
			l_user_id,
			SYSDATE,
			l_user_id
		from  hz_parties hz,
		      MSC_ST_DEMANDS MSD,
		      msc_items mi
		where MSD.ATTRIBUTE3 = mi.item_name
		and   MSD.ATTRIBUTE11 = 'NEW'
		and   MSD.ATTRIBUTE8 = 'ONHAND'
		and   hz.party_name = MSD.ATTRIBUTE1
		and   hz.party_type = 'ORGANIZATION';

		UPDATE MSC_ST_DEMANDS
                SET ATTRIBUTE11 = 'IMPORTED'
		where 	ATTRIBUTE11 = 'NEW'
		and ATTRIBUTE8 = 'ONHAND';


        retcode := 0;
        errbuf := null;
        COMMIT;
exception
   when others then
     errbuf := 'Error:' || to_char(sqlcode) || ':' || substr(sqlerrm,1,60);
     retcode := 2; -- error;
     return;

END Import_ONHAND;

FUNCTION get_onhand(
            arg_plan_id   IN NUMBER,
            arg_org_id    IN NUMBER,
            arg_instance  IN NUMBER,
            arg_item_id   IN NUMBER)
return NUMBER
IS
  l_onhand  number := 0;
begin
  select sum(nvl(new_order_quantity,0))
  into   l_onhand
  from   msc_supplies
  where  plan_id = arg_plan_id
  and    organization_id = arg_org_id
  and    sr_instance_id = arg_instance
  and    inventory_item_id = arg_item_id
  and    order_type = 18;

  return(l_onhand);
EXCEPTION
  when no_data_found then
   return(0);
END get_onhand;

END MSC_IMPORT_ONHAND;

/
