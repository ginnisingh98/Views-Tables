--------------------------------------------------------
--  DDL for Package Body CTO_UPDATE_BOM_RTG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_UPDATE_BOM_RTG_PK" as
/* $Header: CTOUBOMB.pls 120.23.12010000.11 2011/12/13 07:10:25 abhissri ship $ */

/*============================================================================
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : CTOUBOMB.sql
| DESCRIPTION :
| HISTORY     : created   16-OCT-2003   by Sajani Sheth
                                                |
|               02/11/04      Sushant fixed bug 3402690. preconfigured items  |
|                             not upgraded.
|                                                                             |
|                             Sushant fixed bug 3396081. order not on hold    |
|                             for preconfigured items.                        |
|                                                                             |
|                                                                             |
|                                                                             |
|               04/19/04      Sushant fixed bug 3529592. Insert query for     |
|                             table bom_reference_designators should          |
|                             check for null values for column acd_type.      |
|                                                                             |
|
|               Modified   :    14-MAY-2004     Sushant Sawant
|                                               Fixed bug 3484511.
|

|
|               Modified   :    21-JUN-2004     Sushant Sawant
|                                               Fixed bug 3710096.
|                                               Substitute components were not copied
|
|               Modified  : 11-05-2004         Kiran Konada
|                                               Fixed bug 3793286.
|                                               Front Ported bug 3674833
|
|              Renga Kannan 28-Jan-2004   Front Port bug fix 4049807
|                                        Descriptive Flexfield Attribute
|                                        category is not copied from model
|                                        Added this column while inserting
|                                        into bom_operational_routings
|
|              Modified   :  02-02-2005   Kiran Konada
|                                         bug#4092184 FP:11.5.9 - 11.5.10 :I
|                                          customer bug#4081613
|                                         if custom package CTO_CUSTOM_CATALOG_DESC.catalog_desc_method is
|                                         set to 'C' to use custom api AND if model item is not assigned
|                                         to a catalog group. Create configuration process fails
|
|                                         Fix has been made not to honor the custom package if a ato model
|                                         is not assigned to a catalog group or there are no descrptive elements
|                                         defined for a catalog group.
|
|
|
|              Modified   :  04-09-2005   Sushant Sawant
|                                         bug#3793286
|                                         Reference designators from all individual instances of the consolidated
|                                         component from the model bill should be copied to the consolidated component
|                                         on the configuration bill.
|                                                                             |
|
|              Modified   :  04-09-2005   Sushant Sawant
|                                         Fixed issue for bug 4271269.
|                                         populate structure_type_id and effectivity_control columns in
|                                         bom_bill_of_materials view.
|
|		Modified  : 09-02-2005    Renga Kannan
|                                         Fixed the following issues in LBM and effecitivity
|                                         part of code
|
|                                         1.) LBM code does not handle null value for basis type
|                                         Added nvl clause for all insert stmt from bom_inventory_components
|                                         to bom_inventory_components_interface
|
|                                          2.) for overlapping effectivity dates with components having
|                                              having different basis type the message is not raised
|                                              properly. fixd that code
|
|                                          3.) Clubbing component code is inserting null qty value into
|                                              bic interface. Fixed the code not to insert these rows.
|
||		Modified by Renga Kannan on 09/07/2005
|                           Bug Fix 4595162
|                           Modified the code that populates basis type to
|                           bom_inventory_components table. As per bom team
|                           basis_type should have null for 'ITEM' and 2 for 'LOT'
|
|               Modified by Renga Kannan on 09/26/2006
|                           Bug Fix for 4628806
|                           Fixed a LBM related bug
|
|             Kiran Konada 05-Jan-2006	bugfix1765149
|                                       get the x and Y coordinate on canvas for flow routing
|
|
|               06-Jan-2006   Kiran Konada
|			   bugfix#4492875
|	                   Removed the debug statement having sql%rowcount as parameter, which
|			   was immeditaly after sql statement and before if statement using sql%rowcount
|
|                          Reason : if there is a logic dependent on sql%rowcount and debug log statement before
|                           it uses sql%rowcount , then logic may go wrong
|
|
*============================================================================*/

g_SchShpDate            Date;
g_EstRelDate		Date;
glast_update_date       Date  := to_date('01/01/2099 00:00:00','MM/DD/YYYY HH24:MI:SS');

/*
gUserId number := nvl(Fnd_Global.USER_ID, -1);
gLoginId number := nvl(Fnd_Global.LOGIN_ID, -1);
*/

-- bug 4271269. populate structure_type_id in BOM
g_structure_type_id    bom_bill_of_materials.structure_type_id%type ;

       gUserId number := nvl(fnd_global.user_id, -1);
       gLoginId number := nvl(fnd_global.login_id, -1);
       gRequestId number := nvl(fnd_global.conc_request_id, -1) ;
       gProgramApplId number := nvl(fnd_global.prog_appl_id, -1) ;
       gProgramId number := nvl(fnd_global.conc_program_id, -1) ;

-- 3222932 setting global replacement of null disable dates

g_futuredate            DATE := to_date('01/01/2099 00:00:00','MM/DD/YYYY HH24:MI:SS'); /* 02-14-2005 Sushant */

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

/***************************************************************************
This procedure will be called by the Update Configuration BOMs concurrent
program for a particular bcol_upg sequence. It will create BOMs and
Routings for all configurations having this sequence. Each line_id processed
successfully will be updated to status DONE. If BOM creation errors out, status
will be updated to 'ERROR'.
***************************************************************************/
PROCEDURE Update_Boms_Rtgs(
	errbuf OUT NOCOPY varchar2,
	retcode OUT NOCOPY varchar2,
	p_seq IN number,
	p_changed_src IN varchar2) IS

CURSOR c_boms IS
select distinct
bcolu.ato_line_id ato_line_id
from bom_cto_order_lines_upg bcolu
where bcolu.sequence = p_seq
and bcolu.status = 'BOM_PROC'
and bcolu.ato_line_id = bcolu.line_id;

CURSOR c_all_configs(p_ato_line_id number) IS
select /*+ INDEX (BCOLU BOM_CTO_ORDER_LINES_UPG_N4) */
        bcolu.line_id,
	bcolu.inventory_item_id,
	bcolu.config_item_id
from   bom_cto_order_lines_upg bcolu
where  bcolu.ato_line_id = p_ato_line_id
and    bcolu.bom_item_type = 1
and    nvl(bcolu.wip_supply_type,0) <> 6
and    bcolu.config_item_id is not null
and    bcolu.ato_line_id is not null
order by plan_level desc;

l_flow_calc number;
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_stmt_num number;
l_mrp_aset_id number;
l_cto_aset_id number;
l_bcolu_status varchar2(15);
l_row_count    Number;

l_error_flag   Varchar2(1) := 'N';
l_msg_data1     Varchar2(2000);
BEGIN

WriteToLog('Entering update_boms_rtgs', 1);
WriteToLog('	Sequence::'||p_seq, 1);
WriteToLog('	Changed sourcing::'||p_changed_src, 1);

l_stmt_num := 10;
l_flow_calc := FND_PROFILE.Value('CTO_PERFORM_FLOW_CALC');
WriteToLog('Perform_flow_calc::'||l_flow_calc, 3);

WHILE TRUE LOOP
	--
	-- select next N ato_line_ids and update status to BOM_PROC
	--
	l_stmt_num := 20;
	update bom_cto_order_lines_upg bcolu
	set status = 'BOM_PROC'
	where bcolu.ato_line_id in (select ato_line_id
		from bom_cto_order_lines_upg bcolu2
		where bcolu2.ato_line_id = bcolu2.line_id
		and bcolu2.sequence = p_seq
		and bcolu2.status = 'CTO_SRC'
		and rownum < G_SUB_BATCH_SIZE + 1);


	IF sql%notfound THEN
	    WriteToLog('No records to Process in BCOL',3);
	    Exit;
        Else
  	    WriteToLog('Updated status to BOM_PROC for rows::'||sql%rowcount, 3);
	END IF;

	l_stmt_num := 30;
	FOR v_boms in c_boms LOOP

		--
		-- Line could be put on hold due to dropped components
		-- being found for the same config item on a different order line
		-- Process only if line is not on hold
		--
		l_stmt_num := 35;
		select /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1) */
                status
		into l_bcolu_status
		from bom_cto_order_lines_upg
		where ato_line_id = v_boms.ato_line_id
		and rownum = 1;

		WriteToLog('Line is in status :: '||l_bcolu_status, 2);

		IF (l_bcolu_status = 'BOM_PROC') THEN
		-- Line is not on hold or in error. Process for BOM creation.			l_stmt_num := 40;
		FOR v_all_configs IN c_all_configs(v_boms.ato_line_id) LOOP

			l_stmt_num := 50;
			WriteToLog('In v_boms loop, ato_line_id:: '||v_boms.ato_line_id, 4);



                        select /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                        status
                        into l_bcolu_status
                        from bom_cto_order_lines_upg
                        where line_id = v_all_configs.line_id ;

                WriteToLog('Line is in status :: '||l_bcolu_status, 2);


		IF (l_bcolu_status = 'BOM_PROC') THEN

			Update_In_Src_Orgs(
				v_all_configs.line_id,
				v_all_configs.inventory_item_id,
				v_all_configs.config_item_id,
				l_flow_calc,
				l_return_status,
				l_msg_count,
				l_msg_data);

                        --
                        -- bug 10627731
                        --
			--IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				--WriteToLog('Update_In_Src_Orgs returned with expected error.', 1);
                                WriteToLog('Update_In_Src_Orgs returned with status:' || l_return_status ||
 	                                            ' for line_id:' || v_all_configs.line_id, 1);
            			--RAISE FND_API.G_EXC_ERROR ;
				--
				-- Here, we want to skip processing for
				-- the rest of this ato_line_id, but continue
				-- processing the remaining ato_line_ids.
				--
				update /*+ INDEX (BCOLU1 BOM_CTO_ORDER_LINES_UPG_N4) */
                                bom_cto_order_lines_upg bcolu1
				set bcolu1.status = 'ERROR'
				where bcolu1.ato_line_id =
					(select bcolu2.ato_line_id
					from bom_cto_order_lines_upg bcolu2
					where bcolu2.line_id = v_all_configs.line_id);

				WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
				l_error_flag := 'Y';
				EXIT;
                        --
                        -- bug 10627731
                        --
                        /*
        		ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
				WriteToLog('Update_In_Src_Orgs returned with unexpected error.', 1);
            			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                        */
        		END IF;



                END IF; /* line id could have been set to error if child line has encountered an error */



		END LOOP;
		WriteToLog('Error occured in bom creation',1);
		fnd_msg_pub.count_and_get(p_count => l_msg_count,
		                          p_data  => l_msg_data);
		If l_msg_count > 0 Then
		   WriteToLog('============= Error Messages ==============',1);
		   for i in 1..l_msg_count
		   Loop
                      l_msg_data1 := fnd_msg_pub.get(
				    p_msg_index  => i,
				    p_encoded   => fnd_api.g_false);
		      WriteToLog(l_msg_data1,1);
		   end loop;
		   WriteToLog('============= End of error Messages ============',1);
		End if;
		END IF; /* line on hold */
	END LOOP;

	l_stmt_num := 60;
	update bom_cto_order_lines_upg bcolu
	set status = 'BOM_LOOP'
	where sequence = p_seq
	and status = 'BOM_PROC';

	WriteToLog('Updated status to BOM_LOOP for rows::'||sql%rowcount, 3);

	--
	-- Loop processing done for these N ato_line_ids
	-- Do BOM and Rtg bulk processing
	--
	l_stmt_num := 70;
	Update_Bom_Rtg_Bulk(
		p_seq,
		l_return_status,
		l_msg_count,
		l_msg_data);
	IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		WriteToLog('Update_Bom_Rtg_Bulk returned with expected error.', 1);
            	RAISE FND_API.G_EXC_ERROR ;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		WriteToLog('Update_Bom_Rtg_Bulk returned with unexpected error.', 1);
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;

	--
	-- Update rows processed to BOM_BULK
	--
	update bom_cto_order_lines_upg bcolu
	set status = 'BOM_BULK'
	where bcolu.ato_line_id in (select ato_line_id
		from bom_cto_order_lines_upg bcolu2
		where bcolu2.sequence = p_seq
		and bcolu2.status = 'BOM_LOOP');

	WriteToLog('Rows updated to status BOM_BULK::' ||sql%rowcount, 2);

	l_mrp_aset_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
	WriteToLog('MRP Assignment Set Id::'||l_mrp_aset_id, 2);

	BEGIN
	select assignment_set_id
	into l_cto_aset_id
	from mrp_assignment_sets
	where assignment_set_name = 'CTO Configuration Updates';

	WriteToLog('CTO Seeded Assignment Set Id::'||l_cto_aset_id, 2);

	EXCEPTION
	WHEN no_data_found THEN
		WriteToLog('ERROR: CTO seeded assignment set not found', 1);
		RAISE FND_API.G_EXC_ERROR;
	END;

	--
	-- Copy sourcing from CTO to MRP Default Assignment Set
	--
	--Bugfix 8894392
	/*delete from mrp_sr_assignments
	where assignment_set_id = l_mrp_aset_id
	and inventory_item_id in
		(select config_item_id
		from bom_cto_order_lines_upg
		where sequence = p_seq
		and status = 'BOM_BULK'
		and (p_changed_src = 'Y'
		or (p_changed_src = 'N' and nvl(config_creation,'1') = '3')));*/

	--1st delete.. Removing assignments for configs that have cto assignment created
        delete from mrp_sr_assignments msa
	where msa.assignment_set_id = l_mrp_aset_id
	and msa.inventory_item_id in
		(select config_item_id
		  from bom_cto_order_lines_upg bcol
		  where sequence = p_seq
		  and status = 'BOM_BULK'
		  and bcol.config_item_id is not null
                  and EXISTS ( SELECT 'exists'
                                FROM mrp_sr_assignments ma
                                 WHERE ma.assignment_set_id = l_cto_aset_id
                                 AND ma.inventory_item_id = bcol.config_item_id
                             )
                );

	WriteToLog('Rows deleted from MRP Default Assignment Set after 1st delete::' ||sql%rowcount, 2);

	--2nd delete.. Removing those configs that do not have cto assignments and their base model
        --doesn't have mrp assignments

        delete from mrp_sr_assignments msa
	where msa.assignment_set_id = l_mrp_aset_id
	and msa.inventory_item_id in
		( select config_item_id
		  from bom_cto_order_lines_upg bcol
		  where sequence = p_seq
		  and status = 'BOM_BULK'
		  and bcol.config_item_id IS NOT null
                  and NOT EXISTS ( SELECT 'cto assg exists for config'
                                   FROM mrp_sr_assignments ma
                                   WHERE ma.assignment_set_id = l_cto_aset_id
                                   AND ma.inventory_item_id = bcol.config_item_id
                                 )
                  and NOT EXISTS ( SELECT 'mrp assg exists for model'
                                   FROM mrp_sr_assignments ma
                                   WHERE ma.assignment_set_id = l_mrp_aset_id
                                   AND ma.inventory_item_id = bcol.inventory_item_id
                                 )
                );

        WriteToLog('Rows deleted from MRP Default Assignment Set after 2nd delete::' ||sql%rowcount, 2);
        --End bugfix 8894392

	insert into mrp_sr_assignments(
		ASSIGNMENT_ID,
 		ASSIGNMENT_TYPE,
 		SOURCING_RULE_ID,
 		SOURCING_RULE_TYPE,
 		ASSIGNMENT_SET_ID,
 		LAST_UPDATE_DATE,
 		LAST_UPDATED_BY,
 		CREATION_DATE,
 		CREATED_BY,
 		LAST_UPDATE_LOGIN,
 		REQUEST_ID,
 		PROGRAM_APPLICATION_ID,
 		PROGRAM_ID,
 		PROGRAM_UPDATE_DATE,
 		ORGANIZATION_ID,
 		CATEGORY_ID,
 		CATEGORY_SET_ID,
 		INVENTORY_ITEM_ID,
 		SECONDARY_INVENTORY,
 		ATTRIBUTE_CATEGORY,
 		ATTRIBUTE1,
 		ATTRIBUTE2,
 		ATTRIBUTE3,
 		ATTRIBUTE4,
 		ATTRIBUTE5,
 		ATTRIBUTE6,
 		ATTRIBUTE7,
 		ATTRIBUTE8,
 		ATTRIBUTE9,
 		ATTRIBUTE10,
 		ATTRIBUTE11,
 		ATTRIBUTE12,
 		ATTRIBUTE13,
 		ATTRIBUTE14,
 		ATTRIBUTE15,
 		CUSTOMER_ID,
 		SHIP_TO_SITE_ID)
	select
		mrp_sr_assignments_s.nextval,	--ASSIGNMENT_ID,
 		ma.ASSIGNMENT_TYPE,
 		ma.SOURCING_RULE_ID,
 		ma.SOURCING_RULE_TYPE,
 		l_mrp_aset_id,
 		sysdate,	--LAST_UPDATE_DATE,
 		gUserId,	--LAST_UPDATED_BY,
 		sysdate,	--CREATION_DATE,
 		gUserId,	--CREATED_BY,
 		gLoginId,	--LAST_UPDATE_LOGIN,
 		null,		--REQUEST_ID,
 		null,		--PROGRAM_APPLICATION_ID,
 		null,		--PROGRAM_ID,
 		null,		--PROGRAM_UPDATE_DATE,
 		ma.ORGANIZATION_ID,
 		ma.CATEGORY_ID,
 		ma.CATEGORY_SET_ID,
 		ma.INVENTORY_ITEM_ID,
 		ma.SECONDARY_INVENTORY,
 		ma.ATTRIBUTE_CATEGORY,
 		ma.ATTRIBUTE1,
 		ma.ATTRIBUTE2,
 		ma.ATTRIBUTE3,
 		ma.ATTRIBUTE4,
 		ma.ATTRIBUTE5,
 		ma.ATTRIBUTE6,
 		ma.ATTRIBUTE7,
 		ma.ATTRIBUTE8,
 		ma.ATTRIBUTE9,
 		ma.ATTRIBUTE10,
 		ma.ATTRIBUTE11,
 		ma.ATTRIBUTE12,
 		ma.ATTRIBUTE13,
 		ma.ATTRIBUTE14,
 		ma.ATTRIBUTE15,
 		ma.CUSTOMER_ID,
 		ma.SHIP_TO_SITE_ID
	from mrp_sr_assignments ma
	where ma.assignment_set_id = l_cto_aset_id
	and ma.inventory_item_id in (
		select distinct bcolu.config_item_id
		from bom_cto_order_lines_upg bcolu
		where bcolu.sequence = p_seq
		and bcolu.status = 'BOM_BULK');

	WriteToLog('Rows inserted into MRP Default Assignment Set::' ||sql%rowcount, 2);

	--
	-- update status to 'MRP_SRC'
	--
	update bom_cto_order_lines_upg
	set status = 'MRP_SRC'
	where sequence = p_seq
	and status = 'BOM_BULK';

	WriteToLog('Updated status to MRP_SRC for rows::'||sql%rowcount, 3);

END LOOP; /* main wrapper loop */

--Moved this part to CTOUCFGB.pls as part of bugfix 6710393
/*
--
-- Delete rows from CTO assignment set
--
delete from mrp_sr_assignments
where assignment_set_id = l_cto_aset_id;

WriteToLog('Rows deleted from CTO Seeded Assignment Set::' ||sql%rowcount, 2);
*/
--Bugfix 6710393

If l_error_flag = 'Y' Then
   retcode :=1;
End if;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
	WriteToLog('ERROR: Expected error in CTO_Bom_Rtg_Pk.Update_Boms_Rtgs:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Configuration Boms completed with WARNING');
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Progam completed with warning';
        retcode := 1; -- exit with warning

   WHEN fnd_api.g_exc_unexpected_error THEN
	WriteToLog('ERROR: Unexpected error in CTO_Bom_Rtg_Pk.Update_Boms_Rtgs:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Configuration Boms completed with ERROR');
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Progam completed with error';
        retcode := 2; -- exit with error

   WHEN OTHERS then
	WriteToLog('ERROR: Others error in CTO_Bom_Rtg_Pk.Update_Boms_Rtgs:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Configuration Boms completed with ERROR');
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Progam completed with error';
        retcode := 2; -- exit with error


END Update_Boms_Rtgs;


/*-------------------------------------------------------------+
  Name : update_in_src_orgs
         This procedure creates a config item's bom and routing
         in all of the proper sourcing orgs based on the base
         model's sourcing rules.
+-------------------------------------------------------------*/
PROCEDURE Update_In_Src_Orgs(
        pLineId         in  number, -- Current Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        pFlowCalc       in  number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        )

IS

   lStmtNum        number;
   lStatus         number;
   lItmBillId      number;
   lCfgBillId      number;
   lCfgRtgId       number;
   xBillId         number;
   lXErrorMessage  varchar2(100);
   lXMessageName   varchar2(100);
   lXTableName     varchar2(100);
   XTableName     varchar2(100);
   lLineId         	number;
   lModelId        	number;
   lParentAtoLineId 	number := pLineId;
   lErrBuf         	varchar2(80);
   lTotLeadTime    	number := 0;
   lOEValidationOrg 	number;
   lOrderedQty     	number;
   lLeadTime       	number;

   CURSOR cSrcOrgs IS
          select   distinct bcso.organization_id,
                            bcolu.perform_match,
                            bcolu.option_specific,
                            bcso.create_bom bom_create,
                            bcso.model_item_id,
                            bcso.config_item_id
          from     bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
          where    bcso.line_id = pLineId
          and      bcso.model_item_id = pModelId
          and      bcso.config_item_id is not null
          and      bcso.line_id = bcolu.line_id  ;

v_bom_created  number := 0 ;
v_config_bom_exists  number := 0 ;
l_program_id number;

BEGIN

WriteToLog('Processing line_id '||pLineId, 3);

xReturnStatus := fnd_api.g_ret_sts_success;

--
-- Get total lead time for this config based on OE validation org
--
select nvl(schedule_ship_date,sysdate), nvl(program_id, 0)
into g_SchShpDate, l_program_id
from bom_cto_order_lines_upg
where line_id = pLineId ;

g_SchShpDate := greatest(g_SchShpDate, sysdate);
WriteToLog('Schedule Ship Date is '||g_SchShpDate, 4);

--
-- For canned configs not on open or closed order lines, estimated release
-- date should be the sysdate. It does not make sense to calculate a mfg
-- date that is in the past. So, we will skip ERD calculation in this case.
--
IF l_program_id = 99 THEN /* canned config */
	lTotLeadTime := 0;
ELSE

	lStmtNum := 40;
	-- get oevalidation org
	WriteToLog('Before getting validation org', 5);

        begin
        /* BUGFIX# 3484511 */
	select   nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
	into   lOEValidationOrg
	from   oe_order_lines_all oel
	where  oel.line_id = pLineid ;

        exception
                when no_data_found then
                   SELECT master_organization_id
                   INTO lOEValidationOrg
                   FROM mtl_parameters mp, bom_cto_order_lines_upg bcol
                   WHERE bcol.ship_from_org_id = mp.organization_id
                   and bcol.line_id = pLineid;
        end;  --Bugfix 6376208: The main query will run into no data found if SO having line_id has been purged.

	IF (lOEValidationOrg = -99) THEN
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Unable to find OE Validation Org for line_id '||pLineId, 1);
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		raise FND_API.G_EXC_ERROR;
	END IF;

	WriteToLog('Validation Org is :' ||  lOEValidationOrg,4);

	lStmtNum := 41;
	LOOP
	     	select bcolu.line_id,
			bcolu.inventory_item_id,
			bcolu.parent_ato_line_id,
	            	bcolu.ordered_quantity
	     	into   lLineId, lModelId, lParentAtoLineId, lOrderedQty
	     	from   bom_cto_order_lines_upg bcolu
	     	where  bcolu.line_id = lParentAtoLineId;

		WriteToLog('lLineId: ' || to_char(lLineId), 5);
		WriteToLog('lModelId: ' || to_char(lModelId), 5);
		WriteToLog('lParentAtoLineId: ' || to_char(lParentAtoLineId), 5);

	     	lStmtNum := 42;
	     	lStatus := get_model_lead_time(
                          lModelId,
                          lOEValidationOrg,
                          lOrderedQty,
                          lLeadTime,
                          lErrBuf);

	     	IF (lStatus = 0) THEN
			WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++', 1);
			WriteToLog('ERROR: Error in get_model_lead_time', 1);
			WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++', 1);
	        	raise FND_API.G_EXC_ERROR;
		ELSE
			lTotLeadTime := lLeadTime + lTotLeadTime;
		END IF;

		EXIT WHEN lLineId = lParentAtoLineId; -- when we reach the top model
	END LOOP;

	WriteToLog('Total lead time is: ' || to_char(lTotLeadTime), 3);

END IF; /* canned config */

FOR lNextRec IN cSrcOrgs LOOP

WriteToLog('Entered cSrcOrgs loop ' , 4);
WriteToLog('Update_in_src_orgs: model ' || pModelId || ' Line ' || pLineId || ' config ' || lNextRec.config_item_id || ' org ' || lNextRec.organization_id , 1);

if( lNextRec.bom_create = 'Y' ) then
	-- check if model bom exists in src org
	lStmtNum := 10;
	WriteToLog('In update_in_src_orgs. Item: ' ||to_char(pConfigId) || '. Org ' || to_char(lNextRec.organization_id), 5);

	lStmtNum := 100;
	lStatus := CTO_CONFIG_BOM_PK.check_bom(
					pItemId	=> pModelId,
                                        pOrgId	=> lNextRec.organization_id,
                                        xBillId	=> lItmBillId);

	WriteToLog('Returned from check_bom for model with result '
                         || to_char(lStatus), 3);

	if (lStatus = 1) then /* model BOM exists in this org */
		lStmtNum := 110;
		lStatus := CTO_CONFIG_BOM_PK.check_bom(
					pItemId	=> pConfigId,
                                        pOrgId	=> lNextRec.organization_id,
                                        xBillId	=> lItmBillId);

		WriteToLog('Returned from check_bom for config with result '
                        || to_char(lStatus), 3);


		if (lStatus <> 1) then

			-- config BOM does not exist
			lStmtNum := 125;

			lStatus := CTO_UPDATE_BOM_RTG_PK.update_bom_rtg_loop(
						pModelId	=> pModelId,
                                                pConfigId	=> pConfigId,
                                                pOrgId		=> lNextRec.organization_id,
                                                pLineId		=> pLineId,
						pLeadTime	=> lTotLeadTime,
						pFlowCalc	=> pFlowCalc,
                                                xBillId		=> lCfgBillId,
						xRtgId		=> lCfgRtgId,
                                                xErrorMessage	=> lXErrorMessage,
                                                xMessageName	=> lXMessageName,
                                                xTableName	=> lXTableName);

			WriteToLog('Returned from Update_bom_rtg_loop with status: '
                                || to_char(lStatus), 1);




			if (lStatus <> 1) then
				WriteToLog('ERROR: Update_Bom_Rtg_Loop returned with error.', 1);
				raise fnd_api.g_exc_error;
			end if;

			v_bom_created := v_bom_created + 1 ;  /* increment bom created variable */
			lStmtNum := 130;


		end if; -- end check config bom
		WriteToLog('Update_in_src_orgs: after bom loop creation.', 5);
	else /* model BOM does not exist in this org */
		-- Added by Renga Kannan to handle the exception
		WriteToLog('There is no bill for this model in this org',1);
		WriteToLog('Model id :'||to_char(pModelId),1);
		WriteToLog('Org id :'||to_char(lNextRec.organization_id),1);
            /*
             ** Warning **
             ** Achtung **
             ** Model BOM does not exist should not be treated as an error
             **
             ** Case: Specific Org
             **       BOM is created only in the end manufacturing org
             **
             ** Case: All Org
             **       BOM is created in all orgs where the model bom exists
             **
             **       In either case the error will be caught if the bom
             **       was not created even in a single org.

             cto_msg_pub.cto_message('BOM','CTO_BOM_NOT_DEFINED');
             raise fnd_api.g_exc_error;
             */
       end if; -- end check model bom

else /* create_config_bom = 'N' */
	WriteToLog('Create_config_bom parameter is set to N in this org',3);
	WriteToLog('Model id :'||to_char(pModelId),3);
	WriteToLog('Org id   ;'||to_char(lNextRec.organization_id),3);

end if ; /* create_config_bom = 'Y' */

end loop;

if( v_bom_created = 0 and v_config_bom_exists = 0 ) then
	WriteToLog('BOM not created in any orgs.', 1);
end if ;


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
	WriteToLog('Expected error in update_in_src_orgs: '||to_char(lStmtNum)||'::'||sqlerrm, 1);
        xReturnStatus := fnd_api.g_ret_sts_error;
        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
	WriteToLog('Unexpected error in update_in_src_orgs: '||to_char(lStmtNum)||'::'||sqlerrm, 1);
        xReturnStatus := fnd_api.g_ret_sts_unexp_error ;
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
            );

   WHEN OTHERS then
	WriteToLog('Others error in update_in_src_orgs: '||to_char(lStmtNum)||'::'||sqlerrm, 1);
        xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );


END Update_In_Src_Orgs;


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0) IS
BEGIN
    IF gDebugLevel >= p_level THEN
	fnd_file.put_line (fnd_file.log, p_message);
    END IF;
END WriteToLog;


PROCEDURE update_item_num(
	p_parent_bill_seq_id IN NUMBER,
	p_item_num IN OUT NOCOPY NUMBER,
	p_org_id IN NUMBER,
	p_seq_increment IN NUMBER);


FUNCTION Update_Bom_Rtg_Loop(
    pModelId        in       number,
    pConfigId       in       number,
    pOrgId          in       number,
    pLineId         in       number,
    pLeadTime	    in       number,
    pFlowCalc	    in	     number,
    xBillId         out NOCOPY     number,
    xRtgId	    out NOCOPY     number,
    xErrorMessage   out NOCOPY     varchar2,
    xMessageName    out NOCOPY     varchar2,
    xTableName      out NOCOPY     varchar2)
RETURN INTEGER
IS

   lStmtNum  		number;
   lCnt            	number := 0;
   lConfigBillId   	number;
   lstatus	        number;
   lEstRelDate     	date;
   lOpseqProfile   	number;
   lItmBillID      	number;

   v_missed_line_id		number;
   v_missed_item		varchar2(50);
   v_config_item		varchar2(50);
   v_model			varchar2(50);
   v_config			varchar2(50);
   v_missed_line_number		varchar2(50);
   v_order_number		number;
   l_token			CTO_MSG_PUB.token_tbl;
   lcreate_item			number;		-- 2986192
   lorg_code			varchar2(3);	-- 2986192

   /* Cursor to select dropped lines */
   cursor missed_lines ( 	xlineid		number,
                                xconfigbillid   number,
                                xEstRelDate     date ) is    /* Effectivity_date changes */
   select line_id
   from bom_cto_order_lines_upg
   where parent_ato_line_id=xlineid
   and parent_ato_line_id <> line_id 	/* to avoid selecting top model */
   minus
   select revised_item_sequence_id 	/* new column used to store line_id */
   from bom_inventory_comps_interface
   where bill_sequence_id = xconfigbillid
   and greatest(sysdate, xEstRelDate ) >= effectivity_date
   and (( disable_date is null ) or ( disable_date is not null and  greatest(sysdate, xEstRelDate) <= disable_date )) ;

   CURSOR consolidate_components  IS
        select  distinct
            b1.bill_sequence_id,
            b1.operation_seq_num,
            b1.component_sequence_id,
            b1.component_item_id,
            b1.component_quantity,
	    nvl(b1.optional_on_model, 1)
        from
            bom_inventory_comps_interface    b1,
            bom_inventory_comps_interface    b2
        where  b1.bill_sequence_id = b2.bill_sequence_id
        and    b1.component_sequence_id <> b2.component_sequence_id
        and    b1.operation_seq_num = b2.operation_seq_num
        and    b1.component_item_id = b2.component_item_id
        and    b1.bill_sequence_id = lConfigBillId
        order by b1.bill_sequence_id,
                 b1.component_item_id,
                 b1.operation_seq_num,
                 b1.component_quantity,
                 b1.component_sequence_id;

    p_item_num		number := 0;
    p_bill_seq_id 	number;
    p_seq_increment	number;
    lCfgRtgId       number;
    lCfmRtgflag     number;
   l_ser_start_op number;
    l_ser_code     number;
    l_row_count    number := 0;
     lItmRtgId        number;
    l_status        VARCHAR2(1);
    l_industry      VARCHAR2(1);
    l_schema        VARCHAR2(30);
    lLineId         number;
    lModelId        number;
    lParentAtoLineId number := pLineId;
    lOrderedQty     number;
    lLeadTime       number;
    lErrBuf         varchar2(80);
    lTotLeadTime    number := 0;
    lOEValidationOrg number;

     /*New variables added for bugfix 1906371 and 1935580*/
    lmodseqnum    	number;
    lmodtyp       	number;
    lmodrtgseqid    	number;
    lmodnewCfgRtgId    	number;
    lopseqnum	    	number;
    loptyp          	number;
    lrtgseqid       	number;
    lnewCfgRtgId    	number;

    l_test		number;

lBomId number;
lSaveBomId number;
     lSaveOpSeqNum   number;
     lSaveItemId     number;
     lSaveCompSeqId  number;
     lTotalQty       number;
     lSaveOptional   number;
    lCompSeqId             number ;
    lItemId                number ;
    lqty                   number ;
    lOptional	           number ;
l_from_sequence_id number;

    l_install_cfm          BOOLEAN;

    UP_DESC_ERR    exception;

    /* ------------------------------------------------------+
       cursor to  be used to copy attachments for all
       operations fro model to operations on config
       requset id column contains model_op_seq_id.
    +--------------------------------------------------------*/

    cursor allops is
    select operation_sequence_id, request_id
    from bom_operation_sequences
    where routing_sequence_id = lCfgRtgId;

     /* ------------------------------------------------------+
       cursor added for bugfix 1906371 and 1935580  to  select
       distinct combinations of op_seq_num and op_type
    +--------------------------------------------------------*/

    cursor get_op_seq_num (pRtgId number) is
    select distinct operation_seq_num,nvl(operation_type,1)
    from bom_operation_sequences
    --where last_update_login=pRtgId;
    where config_routing_id=pRtgId;


 v_program_id         bom_cto_order_lines_upg.program_id%type;

    TYPE mod_opclass_rtg_tab IS TABLE OF NUMBER	INDEX BY BINARY_INTEGER;


    tModOpClassRtg	mod_opclass_rtg_tab;
    tDistinctRtgSeq	mod_opclass_rtg_tab;
    lexists		varchar2(1);
    k			number;

l_config_creation varchar(1);
l_program_id number;
l_hold_source_rec		OE_Holds_PVT.Hold_Source_REC_type;
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_hold_result_out varchar2(30);
l_order_num number;
--Bugfix 10240482
--l_line_num number;
l_line_num varchar2(100);
l_line_number  varchar2(100);

CURSOR c_holds IS
select oel.line_id,
oel.header_id header_id,
oeh.order_number order_num,
to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number)) line_num
from bom_cto_order_lines_upg bcolu,
oe_order_lines_all oel,
oe_order_headers_all oeh
where bcolu.config_item_id = pConfigId
and nvl(bcolu.program_id, -99) <> 99
and bcolu.line_id = oel.ato_line_id
and oel.item_type_code = 'CONFIG'
and oel.header_id = oeh.header_id;



v_orders_present number := 0 ;

 -- start 3674833
    -- Collection to store comp seq


        TYPE seq_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


    model_comp_seq_id_arr               seq_tab;
        component_item_id_arr           seq_tab;
    operation_seq_num_arr       seq_tab;  --4244576

        club_component_sequence_id  number;
        prev_comp_item_id                       number;

-- end 3674833





    /* begin 02-14-2005 Sushant */

    -- 3222932 Variable declaration of new code

    -- Collection to store all eff and disable dates

    TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    asc_date_arr    date_tab;

    -- Collection to store clubbed quantity with new date window

    TYPE club_rec IS RECORD (
    eff_dt                  DATE,
    dis_dt                  DATE,
    qty                     NUMBER,
    row_id                  rowid
    );

    TYPE club_tab IS TABLE OF club_rec INDEX BY BINARY_INTEGER;

    club_tab_arr    club_tab;


    lrowid          ROWID;

    -- Get all components to be clubbed
    -- bug 4244576: It is possible that the same item is existing at op seq 15, 25, 30, 15. In
    -- this case the two records at 15 needs to be clubbed but not the once at 25 and 30. Going
    -- just by item_id will club all 4 records. We need to go by item_id and op_seq.
    cursor  club_comp is
        select  distinct b1.component_item_id   item_id, b1.operation_seq_num
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b1.bill_sequence_id = lConfigBillId; /* No changes required for LBM Project */


    -- variables for debugging
   dbg_eff_date    Date;
   dbg_dis_date    Date;
   dbg_qty         Number;

   -- Cursor for debugging
   cursor c1_debug( xItemId        number, xOperation_seq_num number) is
        select effectivity_date eff_date,
               nvl (disable_date,g_SchShpDate) dis_date,
               component_quantity cmp_qty
        from   bom_inventory_comps_interface
        where  bill_sequence_id = lConfigBillId
        and    component_item_id = xItemId
        and    operation_seq_num = xOperation_seq_num; --4244576
   -- bugfix 3985173
   -- new cursor for component sequence
   cursor club_comp_seq ( xComponentItemId      number, xOperation_seq_num number ) is
     select bic.component_sequence_id comp_seq_id
     from   bom_inventory_components bic,
            bom_bill_of_materials bom
     where  bom.assembly_item_id  = pConfigId
     and    bom.organization_id   = pOrgId
     and    bic.bill_sequence_id  = bom.bill_sequence_id
     and    bic.component_item_id = xComponentItemId
     and    bic.operation_seq_num = xOperation_seq_num; --4244576



     v_zero_qty_count      number ;
  l_token1            CTO_MSG_PUB.token_tbl;
  v_model_item_name   varchar2(2000) ;

    /* end 02-14-2005 Sushant */

   /* LBM Project */
    v_diff_basis_string  varchar2(2000);
    v_sub_diff_basis_string  varchar2(2000);

    l_new_line  varchar2(10) := fnd_global.local_chr(10);

    basis_model_comp_seq_id_arr               seq_tab;
        basis_component_item_id_arr           seq_tab;




  v_overlap_check  number := 0 ;

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  v_t_overlap_comp_item_id  num_tab;
  v_t_overlap_src_op_seq_num num_tab;
  v_t_overlap_src_eff_date   date_tab;
  v_t_overlap_src_disable_date date_tab;
  v_t_overlap_dest_op_seq_num  num_tab;
  v_t_overlap_dest_eff_date    date_tab;
  v_t_overlap_dest_disable_date date_tab;

   /* LBM Project */
  l_model_name   varchar2(1000);
  l_comp_name    varchar2(1000);
  l_org_name     varchar2(1000);

--- Renga

    cursor Debug_cur is
           select assembly_item_id,component_item_id,operation_seq_num,max(disable_date) disable_date
	   from   bom_inventory_comps_interface
	   where  bill_sequence_id = lconfigbillid
	   group by assembly_item_id,component_item_id,operation_seq_num;

--- End Renga

l_batch_id Number;
l_token2            CTO_MSG_PUB.token_tbl;

BEGIN

WriteToLog('Entering Update_Bom_Rtg_Loop', 2);

xBillId    := 0;
lStmtNum   := 10;
select bom_inventory_components_s.nextval
into lConfigBillId
from dual;

WriteToLog('Creating Bill:: ' || lConfigBillId, 2);

lStmtNum   := 20;
BEGIN
select CAL.CALENDAR_DATE
into   lEstRelDate
from   bom_calendar_dates cal,
	mtl_system_items msi,
	bom_cto_order_lines_upg bcolu,
	mtl_parameters mp
where  msi.organization_id    = pOrgId
and    msi.inventory_item_id  = pModelId
and    bcolu.line_id            = pLineId
and    bcolu.inventory_item_id  = msi.inventory_item_id
and    mp.organization_id     = msi.organization_id
and    cal.calendar_code      = mp.calendar_code
and    cal.exception_set_id   = mp.calendar_exception_set_id
and    cal.seq_num =
	(select cal2.prior_seq_num - pLeadTime
	from   bom_calendar_dates cal2
	where  cal2.calendar_code    = mp.calendar_code
	and    cal2.exception_set_id = mp.calendar_exception_set_id
	and    cal2.calendar_date    = trunc(bcolu.schedule_ship_date));
EXCEPTION
WHEN no_data_found THEN
	xErrorMessage := ' Error in calculating Estimated Release date ';		xMessageName  := 'CTO_NO_CALENDAR';
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++', 1);
       	WriteToLog('ERROR: Error in calculating Estimated Release Date', 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++', 1);
       	return(1);
END;

lEstRelDate := greatest(lEstRelDate, sysdate);
WriteToLog('Estimated Release Date is : ' || lEstRelDate, 3);
g_EstRelDate := lEstRelDate;
WriteToLog('Global Estimated Release Date is : ' || g_EstRelDate, 3);

/*-------------------------------------------------------------------------+
       Check profile option 'Inherit Operation_sequence_number'. If it is set
       to 'Yes', ensure that the childern default the operation sequence number
       from its parent, if not already assigned.
+--------------------------------------------------------------------------*/
lOpseqProfile := FND_PROFILE.Value('BOM:CONFIG_INHERIT_OP_SEQ');
WriteToLog('Profile Config_inherit_op_seq is ' || lOpseqProfile, 3);

lStmtNum := 80;
if lOpseqProfile = 1 then
	WriteToLog('Calling inherit_op_seq_ml with line id ' ||
                        to_char(pLineId) || ' in org ' ||
                        to_char(pOrgId), 4);

	lStatus := inherit_op_seq_ml(pLineId, pOrgId,pModelId,lConfigBillId,xErrorMessage,xMessageName);
	if lStatus <> 1 then
		WriteToLog('Inherit_op_seq_ml returned with error for line id: '|| to_char(pLineId), 1);
		return(1);
	end if;

else
/*-----------------------------------------------------------+
     First:
     All the chosen option items/models/Classes  associated
     with the new configuration items will be loaded into the
     BOM_INVENTORY_COMPS_INTERFACE table.
+-------------------------------------------------------------*/

	xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';
	lStmtNum   := 30;

        -- rkaza. bug 4524248. bom structure import enhancements.
        -- Added batch_id

	insert into BOM_INVENTORY_COMPS_INTERFACE
	      (
	      operation_seq_num,
	      component_item_id,
	      last_update_date,
	      last_updated_by,
	      creation_date,
	      created_by,
	      last_update_login,
	      item_num,
	      component_quantity,
	      component_yield_factor,
	      component_remarks,
	      effectivity_date,
	      change_notice,
	      implementation_date,
	      disable_date,
	      attribute_category,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      attribute6,
	      attribute7,
	      attribute8,
	      attribute9,
	      attribute10,
	      attribute11,
	      attribute12,
	      attribute13,
	      attribute14,
	      attribute15,
	      planning_factor,
	      quantity_related,
	      so_basis,
	      optional,
	      mutually_exclusive_options,
	      include_in_cost_rollup,
	      check_atp,
	      shipping_allowed,
	      required_to_ship,
	      required_for_revenue,
	      include_on_ship_docs,
	      include_on_bill_docs,
	      low_quantity,
	      high_quantity,
	      acd_type,
	      old_component_sequence_id,
	      component_sequence_id,
	      bill_sequence_id,
	      request_id,
	      program_application_id,
	      program_id,
	      program_update_date,
	      wip_supply_type,
	      pick_components,
	      model_comp_seq_id,
	      supply_subinventory,
	      supply_locator_id,
	      bom_item_type,
	      optional_on_model,	-- New columns for configuration
	      parent_bill_seq_id,	-- BOM restructure project
	      plan_level,		-- Used by CTO only
	      revised_item_sequence_id,
	      assembly_item_id    /* Bug Fix: 4147224 */
            , basis_type,           /* LBM project */
              batch_id
	      )
	  select
	      nvl(ic1.operation_seq_num,1),
	      decode(bcol1.config_item_id, NULL, ic1.component_item_id, -- new
	                                              bcol1.config_item_id),
	      SYSDATE,                            -- last_updated_date
	      1,                                  -- last_updated_by
	      SYSDATE,                            -- creation_date
	      1,                                  -- created_by
	      1,                                  -- last_update_login
	      ic1.item_num,
      Round(
           CTO_UTILITY_PK.convert_uom( bcol1.order_quantity_uom, msi_child.primary_uom_code, bcol1.ordered_quantity ,
msi_child.inventory_item_id )
          / CTO_UTILITY_PK.convert_uom(bcol2.order_quantity_uom, msi_parent.primary_uom_code, NVL(bcol2.ordered_quantity,1) , msi_parent.inventory_item_id ) , 7) , /* 02-14-2005 Sushant */
	      -- Decimal-Qty Support for Option Items
	      ic1.component_yield_factor,
	      ic1.component_remarks,                    --Bugfix 7188428
              --NULL,                               --ic1.component_remark
	      -- TRUNC(SYSDATE),                     -- effective date
              -- 3222932 If eff_date > sysdate , insert eff_Date else insert sysdate
              decode(
                  greatest(ic1.effectivity_date,sysdate), ic1.effectivity_date , ic1.effectivity_date , sysdate ),
              /* 02-14-2005 sushant */
	      NULL,                               -- change notice
	      SYSDATE,                            -- implementation_date
	      -- NULL,                               -- disable date
              nvl(ic1.disable_date,g_futuredate), -- 3222932  /* 02-14-2005 Sushant */
	      ic1.attribute_category,
	      ic1.attribute1,
	      ic1.attribute2,
	      ic1.attribute3,
	      ic1.attribute4,
	      ic1.attribute5,
	      ic1.attribute6,
	      ic1.attribute7,
	      ic1.attribute8,
	      ic1.attribute9,
	      ic1.attribute10,
	      ic1.attribute11,
	      ic1.attribute12,
	      ic1.attribute13,
	      ic1.attribute14,
	      ic1.attribute15,
	      100,                                  -- planning_factor */
	      2,                                    -- quantity_related */
	      decode(bcol1.config_item_id, NULL, decode(ic1.bom_item_type,4,ic1.so_basis,2),
	                                        2), -- so_basis */
	      2,                                    -- optional */
	      2,                                    -- mutually_exclusive_options */
	      decode(bcol1.config_item_id, NULL, decode(ic1.bom_item_type,4, ic1.include_in_cost_rollup, 2), 1), -- Cost_rollup */
	      decode(bcol1.config_item_id, NULL, decode(ic1.bom_item_type,4, ic1.check_atp, 2), 2), -- check_atp */
	      2,                                    -- shipping_allowed = NO */
	      2,                                    -- required_to_ship = NO */
	      ic1.required_for_revenue,
	      ic1.include_on_ship_docs,
	      ic1.include_on_bill_docs,
	      NULL,                                 -- low_quantity */
	      NULL,                                 -- high_quantity */
	      NULL,                                 -- acd_type */
	      NULL,                                 --old_component_sequence_id */
	      bom_inventory_components_s.nextval,   -- component sequence id */
	      lConfigBillId,                        -- bill sequence id */
	      NULL,                                 -- request_id */
	      NULL,                                 -- program_application_id */
	      NULL,                                 -- program_id */
	      NULL,                                 -- program_update_date */
	      ic1.wip_supply_type,
	      2,                                    -- pick_components = NO */
	      decode(bcol1.config_item_id, NULL, (-1)*ic1.component_sequence_id, ic1.component_sequence_id),	-- saved model comp seq for later use. If config item, then saved model comp seq id as positive, otherwise negative.
	      ic1.supply_subinventory,
	      ic1.supply_locator_id,
	      --ic1.bom_item_type
	      decode(bcol1.config_item_id, NULL, ic1.bom_item_type, 4),
	      1,			--optional_on_model,
	      ic1.bill_sequence_id,	--parent_bill_seq_id,
	      (bcol1.plan_level-bcol2.plan_level),	--plan_level
	      bcol1.line_id,
	      bcol3.inventory_item_id  /* Bug Fix: 4147224 */
            , nvl(ic1.basis_type,1),            /* LBM project */
              cto_msutil_pub.bom_batch_id
  	  from
	    bom_inventory_components ic1,
	    bom_cto_order_lines_upg bcol1,	-- Option
	    bom_cto_order_lines_upg bcol2,	-- Parent-Model
	    bom_cto_order_lines_upg bcol3,	-- Parent-component
            mtl_system_items  msi_child ,   /* 02-14-2005 Sushant */ -- begin bugfix 1653881
            mtl_system_items  msi_parent    /* 02-14-2005 Sushant */ -- begin bugfix 1653881
	  where  ic1.bill_sequence_id = (
	        select common_bill_sequence_id
	        from   bom_bill_of_materials bbm
	        where  organization_id = pOrgId
	        and    alternate_bom_designator is null
	        and    assembly_item_id =(
	            select distinct assembly_item_id
	            from   bom_bill_of_materials bbm1,
	                   bom_inventory_components bic1
	            where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
	            and    component_sequence_id = bcol1.component_sequence_id
	            and    bbm1.assembly_item_id = bcol3.inventory_item_id ))
	  and ic1.component_item_id = bcol1.inventory_item_id
          /* begin  02-14-2005 Sushant */
          and msi_child.inventory_item_id = bcol1.inventory_item_id
          and msi_child.organization_id = pOrgId
          and msi_parent.inventory_item_id = bcol2.inventory_item_id
          and msi_parent.organization_id = pOrgId
          /* end 02-14-2005 Sushant */
	  -- and ic1.effectivity_date  <= g_SchShpDate  /* New approach for effectivity dates */
          and ic1.implementation_date is not null  --bug4122212
	  -- and NVL(ic1.disable_date, (lEstRelDate + 1)) > lEstRelDate
          and  ( ic1.disable_date is null or
              (ic1.disable_date is not null and  ic1.disable_date >= sysdate ) -- New Approach for effectivity dates /* bug #3389846 */
             )
	  and      (( ic1.optional = 1 and ic1.bom_item_type = 4)
	            or
		    ( ic1.bom_item_type in (1,2)))
	  and     bcol1.ordered_quantity <> 0
	  and     bcol1.line_id <> bcol2.line_id
	  and     bcol1.parent_ato_line_id = bcol2.line_id
	  and     bcol1.parent_ato_line_id is not null
	  and     bcol1.link_to_line_id is not null
	  and     bcol2.line_id            = pLineId
	  and     bcol2.ship_from_org_id   = bcol1.ship_from_org_id
	  and     (bcol3.parent_ato_line_id  = bcol1.parent_ato_line_id
	           or
	           bcol3.line_id = bcol1.parent_ato_line_id)
	  and     bcol3.line_id = bcol1.link_to_line_id;

    	WriteToLog('Inserted ' || sql%rowcount ||' rows into BOM_INVENTORY_COMPS_INTERFACE.',3);


        /* begin 04-04-2005 */

        select count(*) into v_zero_qty_count from bom_inventory_comps_interface
         where bill_sequence_id = lConfigBillId  and component_quantity = 0 ;


        WriteToLog( 'MODELS: CHECK Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

        if( v_zero_qty_count > 0 ) then

            WriteToLog( 'SHOULD Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

            select concatenated_segments into v_model_item_name
              from mtl_system_items_kfv
             where inventory_item_id = pModelId
               and rownum = 1 ;


            l_token1(1).token_name  := 'MODEL_NAME';
            l_token1(1).token_value := v_model_item_name ;


            cto_msg_pub.cto_message('BOM','CTO_ZERO_BOM_COMP', l_token1 );

            raise fnd_api.g_exc_error;




        end if ;



        /* end 04-04-2005  */






   /* New Approach for effectivity dates */






   /*---------------------------------------------------------------+
      Second:
      All the standard component items  associated
      with the new configuration items will be loaded into the
      BOM_INVENTORY_COMPS_INTERFACE table.
   +----------------------------------------------------------------*/

	lStmtNum := 50;
   	xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';
	insert into BOM_INVENTORY_COMPS_INTERFACE
	     (
	     operation_seq_num,
	     component_item_id,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     item_num,
	     component_quantity,
	     component_yield_factor,
	     component_remarks,
	     effectivity_date,
	     change_notice,
	     implementation_date,
	     disable_date,
	     attribute_category,
	     attribute1,
	     attribute2,
	     attribute3,
	     attribute4,
	     attribute5,
	     attribute6,
	     attribute7,
	     attribute8,
	     attribute9,
	     attribute10,
	     attribute11,
	     attribute12,
	     attribute13,
	     attribute14,
	     attribute15,
	     planning_factor,
	     quantity_related,
	     so_basis,
	     optional,
	     mutually_exclusive_options,
	     include_in_cost_rollup,
	     check_atp,
	     shipping_allowed,
	     required_to_ship,
	     required_for_revenue,
	     include_on_ship_docs,
	     include_on_bill_docs,
	     low_quantity,
	     high_quantity,
	     acd_type,
	     old_component_sequence_id,
	     component_sequence_id,
	     bill_sequence_id,
	     request_id,
	     program_application_id,
	     program_id,
	     program_update_date,
	     wip_supply_type,
	     pick_components,
	     model_comp_seq_id,
	     supply_subinventory,
	     supply_locator_id,
	     bom_item_type,
	     optional_on_model,		-- New columns for configuration
	     parent_bill_seq_id,	-- BOM restructure project.
	     plan_level			-- Used by CTO only.
            , basis_type,             /* LBM project */
             batch_id
		)
	select
	     nvl(ic1.operation_seq_num,1),
	     ic1.component_item_id,
	     SYSDATE,                           -- last_updated_date
	     1,                                 -- last_updated_by
	     SYSDATE,                           -- creation_date
	     1,                                 -- created_by
	     1,                                 -- last_update_login
	     ic1.item_num,
     decode( nvl(ic1.basis_type,1), 1 , Round( ( ic1.component_quantity * ( bcol1.ordered_quantity
          / bcol2.ordered_quantity)), 7 ) , Round(ic1.component_quantity , 7 ) ) ,  /* Decimal-Qty Support for Option Items, LBM project */
	     ic1.component_yield_factor,
	     ic1.component_remarks,                    --Bugfix 7188428
             --NULL,                              -- ic1.component_remark
	     -- TRUNC(SYSDATE),                    -- effective date
             decode(                            -- 3222932 /* 02-14-2005 Sushant */
             greatest(ic1.effectivity_date,sysdate), ic1.effectivity_date , ic1.effectivity_date , sysdate ),
	     NULL,                              -- change notice
	     SYSDATE,                           -- implementation_date
	     -- NULL,                              -- disable date
             nvl(ic1.disable_date,g_futuredate), -- 3222932 /* 02-14-2005 Sushant */
	     ic1.attribute_category,
	     ic1.attribute1,
	     ic1.attribute2,
	     ic1.attribute3,
	     ic1.attribute4,
	     ic1.attribute5,
	     ic1.attribute6,
	     ic1.attribute7,
	     ic1.attribute8,
	     ic1.attribute9,
	     ic1.attribute10,
	     ic1.attribute11,
	     ic1.attribute12,
	     ic1.attribute13,
	     ic1.attribute14,
	     ic1.attribute15,
	     100,                                  -- planning_factor
	     2,                                    -- quantity_related
	     ic1.so_basis,
	     2,                                    -- optional
	     2,                                    -- mutually_exclusive_options
	     ic1.include_in_cost_rollup,
	     ic1.check_atp,
	     2,                                    -- shipping_allowed = NO
	     2,                                    -- required_to_ship = NO
	     ic1.required_for_revenue,
	     ic1.include_on_ship_docs,
	     ic1.include_on_bill_docs,
	     NULL,                                 -- low_quantity
	     NULL,                                 -- high_quantity
	     NULL,                                 -- acd_type
	     NULL,                                 -- old_component_sequence_id
	     bom_inventory_components_s.nextval,   -- component sequence id
	     lConfigBillId,                        -- bill sequence id
	     NULL,                                 -- request_id
	     NULL,                                 -- program_application_id
	     NULL,                                 -- program_id
	     NULL,                                 -- program_update_date
	     ic1.wip_supply_type,
	     2,                                    -- pick_components = NO
	     (-1)*ic1.component_sequence_id,       -- model comp seq for later use
	     ic1.supply_subinventory,
	     ic1.supply_locator_id,
	     ic1.bom_item_type,
	     2,				--optional_on_model,
	     ic1.bill_sequence_id,	--parent_bill_seq_id,
	     bcol1.plan_level+1-bcol2.plan_level	--plan_level
             , nvl(ic1.basis_type,1),           /* LBM project */
             cto_msutil_pub.bom_batch_id
	from
	     bom_cto_order_lines_upg bcol1,                 -- component
	     bom_cto_order_lines_upg bcol2,                 -- Model
	     mtl_system_items si1,
	     mtl_system_items si2,
	     bom_bill_of_materials b,
	     bom_inventory_components ic1
	   where   si1.organization_id = pOrgId
	   and     bcol1.inventory_item_id = si1.inventory_item_id
	   and     si1.bom_item_type in (1,2)      -- model, option class
	   and     si2.inventory_item_id = bcol2.inventory_item_id
	   and     si2.organization_id = si1.organization_id
	   and     si2.bom_item_type = 1
	   and     ((bcol1.parent_ato_line_id  = bcol2.line_id
	            and ( bcol1.bom_item_type <> 1
	                  or
	                 (bcol1.bom_item_type = 1 and nvl(bcol1.wip_supply_type, 0) = 6))
	            )
	            or bcol1.line_id = bcol2.line_id
	           )
	   and     bcol2.line_id = pLineId
	   and     si1.organization_id     = b.organization_id
	   and     bcol1.inventory_item_id    = b.assembly_item_id
	   and     b.alternate_bom_designator is NULL
	   and     b.common_bill_sequence_id = ic1.bill_sequence_id
	   and     ic1.optional = 2         -- optional = no
	   -- and     ic1.effectivity_date <= greatest( NVL(g_SchShpDate,sysdate),sysdate) /* New Approach for effectivity dates */
	   and     ic1.implementation_date is not null
	   -- and     NVL(ic1.disable_date,NVL(lEstRelDate, SYSDATE)+1) > NVL(lEstRelDate,SYSDATE)
	   -- and    NVL(ic1.disable_date,SYSDATE) >= SYSDATE
           and  ( ic1.disable_date is null or
                (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
	   and     ic1.bom_item_type = 4;

    	WriteToLog('Inserted ' || sql%rowcount ||' rows into BOM_INVENTORY_COMPS_INTERFACE.',3);



/* begin Extend Effectivity Dates for Option Items with disable date */

   oe_debug_pub.add('create_bom_ml:: Config bill id = '||lconfigbillid,1);

   For debug_rec in debug_cur
   Loop
      WriteToLog('create_bom_ml: : Assembly_item_id = '||debug_rec.assembly_item_id,1);
      WriteToLog('create_bom_ml: : Componenet_item_id = '||debug_rec.component_item_id,1);
      WriteToLog('create_bom_ml: : operation_sequence_num = '||debug_rec.operation_seq_num,1);
      WriteToLog('create_bom_ml: : MAxDisbale Date = '||debug_rec.disable_date,1);
      WriteToLog('==================================',1);
   End Loop;

  update bom_inventory_comps_interface
   set disable_date = g_futuredate
   where (component_item_id, nvl(assembly_item_id,-1),disable_date)
   in    ( select
              component_item_id, nvl(assembly_item_id,-1),max(disable_date)
           from bom_inventory_comps_interface
           where bill_sequence_id = lConfigBillId
           group by component_item_id,  assembly_item_id
	 )
   and  bill_sequence_id = lConfigBillId
   and disable_date <> g_futuredate ;

   If PG_DEBUG <> 0 Then
      WriteToLog('Create_bom_ml: Extending the disable dates to futuure date = '||sql%rowcount,1);
      WriteToLog('Create_bom_ml: lconfigBillId = '||to_char(lConfigBillid),1);
   End if;



   /* end Extend Effectivity Dates for Option Items with disable date */



   /* New Approach for effectivity dates */
   /* begin Check for Overlapping Effectivity Dates */
   v_overlap_check := 0 ;

   begin
     select 1 into v_overlap_check
     from dual
     where exists
       ( select * from bom_inventory_comps_interface
          where bill_sequence_id = lConfigBillId
          group by component_item_id, assembly_item_id
          having count(distinct operation_seq_num) > 1
       );
   exception
   when others then
       v_overlap_check := 0 ;
   end;


   if(v_overlap_check = 1) then

     begin
        select s1.component_item_id,
               s1.operation_seq_num, s1.effectivity_date, s1.disable_date,
               s2.operation_Seq_num , s2.effectivity_date, s2.disable_date
        BULK COLLECT INTO
               v_t_overlap_comp_item_id,
               v_t_overlap_src_op_seq_num,  v_t_overlap_src_eff_date, v_t_overlap_src_disable_date ,
               v_t_overlap_dest_op_seq_num , v_t_overlap_dest_eff_date, v_t_overlap_dest_disable_date
        from bom_inventory_comps_interface s1 , bom_inventory_comps_interface s2
       where s1.component_item_id = s2.component_item_id and s1.assembly_item_id = s2.assembly_item_id
         and s1.effectivity_date between s2.effectivity_date and s2.disable_date
         and s1.component_sequence_id <> s2.component_sequence_id ;


     exception
     when others then
        null ;
     end ;


     if( v_t_overlap_src_op_seq_num.count > 0 ) then
         for i in v_t_overlap_src_op_seq_num.first..v_t_overlap_src_op_seq_num.last
         loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog (' The following components have overlapping dates ', 1);
                WriteToLog (' COMP ' || ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' || ' OVERLAPS ' ||
                                              ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' , 1);

                WriteToLog ( v_t_overlap_comp_item_id(i) ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) ||
                                  ' OVERLAPS ' ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) , 1);

             END IF;

             cto_msg_pub.cto_message('BOM','CTO_OVERLAP_DATE_ERROR');

         end loop ;

         raise fnd_api.g_exc_error;

     end if ;

   end if;


end if; /* end of check lOpseqProfile = 1 */



lStmtNum := 51;
--
-- checking for dropped components
--
WriteToLog ('Checking for dropped components', 3);
BEGIN

select 	substrb(concatenated_segments,1,50)
into	v_config
from 	mtl_system_items_kfv
where 	organization_id = pOrgId
and 	inventory_item_id = pConfigId ;
WriteToLog('Config name is.. '|| v_config ,5);

lcreate_item := nvl(FND_PROFILE.VALUE('CTO_CONFIG_EXCEPTION'), 1);
WriteToLog ('Config exception profile:: '||lcreate_item, 3);
WriteToLog ('Estimated Release date :: '||to_char(lEstRelDate),1);

open missed_lines(pLineId,lConfigBillId, lEstRelDate );  /* New Approach for effectivity dates */
loop
	fetch missed_lines into v_missed_line_id;

	exit when missed_lines%NOTFOUND;

	lStmtNum := 52;
	BEGIN
	WriteToLog('Select missed component details.. ' || v_missed_line_id  ,3);




        begin


	select 	substrb(msi.concatenated_segments,1,50),
    		to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||decode(oel.option_number,NULL,NULL,'.'||to_char(option_number)),
    		oeh.order_number
	into 	v_missed_item,v_missed_line_number,v_order_number
	from 	mtl_system_items_kfv msi, oe_order_lines_all oel,oe_order_headers_all oeh
	where 	msi.organization_id = oel.ship_from_org_id
	and   	msi.inventory_item_id = oel.inventory_item_id
	and	oel.header_id	= oeh.header_id
	and	oel.line_id = v_missed_line_id;


        exception
        when no_data_found then


               /* Fix for bug 3402690 */
	       WriteToLog('No data found, must be preconfigured item .. ' ,5);

               --Begin Bugfix 10240482
	       declare
               ship_org_id_temp number;
	       item_id_temp number;

	       begin
	       lStmtNum := 5201;
	       select ship_from_org_id,
		      inventory_item_id
		into ship_org_id_temp,
		     item_id_temp
	        from bom_cto_order_lines_upg
		where line_id = v_missed_line_id;

	       oe_debug_pub.add('New Msg: ship_org_id_temp:' || ship_org_id_temp);
	       oe_debug_pub.add('New Msg: item_id_temp:' || item_id_temp);

	       exception
	       when others then
	         oe_debug_pub.add('Exception in debug code:' || sqlerrm);
	       end;

	       /*select substrb(msi.concatenated_segments,1,50),
                       'Not Available' ,
                       -1
                  into v_missed_item,v_missed_line_number,v_order_number
                  from mtl_system_items_kfv msi, bom_cto_order_lines_upg bcolu
                 where msi.organization_id = bcolu.ship_from_org_id
                   and msi.inventory_item_id = bcolu.inventory_item_id
                   and bcolu.line_id = v_missed_line_id;
	       */

               lStmtNum := 5202;
	       select substrb(msi.concatenated_segments,1,50),
                       'Not Available' ,
                       -1
                  into v_missed_item,v_missed_line_number,v_order_number
                  from mtl_system_items_kfv msi, bom_cto_order_lines_upg bcolu
                 where msi.inventory_item_id = bcolu.inventory_item_id
                   and bcolu.line_id = v_missed_line_id
		   and rownum = 1;
	       --End Bugfix 10240482

        when others then
            raise ;


        end ;




	lStmtNum := 53;
	WriteToLog('Select model.. ' ,5);
	select 	substrb(concatenated_segments,1,50)
	into	v_model
	from 	mtl_system_items_kfv
	where 	organization_id = pOrgId
	and 	inventory_item_id = pModelId ;

	lStmtNum := 54;
	WriteToLog('Select Org.. ' ,5);
	select	organization_code
	into 	lOrg_code
	from 	mtl_parameters
	where	organization_id =pOrgId ;

	if ( lcreate_item = 1 ) then
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('WARNING: The component '||v_missed_item
                        	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| ' was not included in the configured item''s bill. ',1);
		WriteToLog ('Configuration Item Name : '||v_config,1);
		WriteToLog ('Model Name : '||v_model,1);
		WriteToLog ('Order Number : '||v_order_number,1);
          	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	else
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog ('ERROR: The configured item BOM was not created because component '||v_missed_item 	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| ' could not be included in the configured item''s bill. ',1);
		WriteToLog ('Configuration Item Name : '||v_config,1);
		WriteToLog ('Model Name : '||v_model,1);
		WriteToLog ('Order Number : '||v_order_number,1);
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++', 1);

	end if;

	EXCEPTION			-- exception for stmt 52 ,53 and 54
	when others then
		WriteToLog('Others excepn from stmt '||lStmtNum ||':'||sqlerrm, 1);
		raise fnd_api.g_exc_error;

	END ;

end loop; /* missed lines cursor */

/* gDropItem is set to 0 . Not resetting this to 1
for next order in the batch since even when items are
dropped for one order in the batch , the whole batch
should end with warning */

if missed_lines%ROWCOUNT > 0 then
	CTO_CONFIG_BOM_PK.gDropItem := 0;
	lStmtNum := 55;
	--
	-- Put all open order lines having this config item on hold
	--
	select nvl(config_creation, '1')
	into l_config_creation
	from bom_cto_order_lines_upg
	where line_id = pLineId;

	WriteToLog('l_config_creation:: '||l_config_creation, 3);

	--IF (l_program_id <> 99) THEN
		IF l_config_creation = 3 THEN
			FOR v_holds in c_holds LOOP
				--
				-- apply hold if one does not already exist
				--
				OE_HOLDS_PUB.Check_Holds (
		 			p_api_version 		=> 1.0
					,p_line_id 		=> v_holds.line_id
					,x_result_out 		=> l_hold_result_out
					,x_return_status 	=> l_return_status
					,x_msg_count 		=> l_msg_count
					,x_msg_data 		=> l_msg_data);

        			IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                   			WriteToLog('Failed in Check Holds with expected error.' ,1);
                			raise FND_API.G_EXC_ERROR;

        			ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   			WriteToLog('Failed in Check Holds with unexpected error.' ,1);
                			raise FND_API.G_EXC_UNEXPECTED_ERROR;

        			ELSE
                   			WriteToLog('Success in Check Holds.' ,1);
					if l_hold_result_out = FND_API.G_FALSE then

                    				WriteToLog('Calling OM api to apply hold.' ,1);
		    				l_hold_source_rec.hold_entity_code   := 'O';
                    				l_hold_source_rec.hold_id            := 55;
                    				l_hold_source_rec.hold_entity_id     := v_holds.header_id;
                    				l_hold_source_rec.header_id          := v_holds.header_id;
                    				l_hold_source_rec.line_id            := v_holds.line_id;

		    				OE_Holds_PUB.Apply_Holds (
				   			p_api_version        => 1.0
                               				,   p_hold_source_rec    => l_hold_source_rec
                               				,   x_return_status      => l_return_status
                               				,   x_msg_count          => l_msg_count
                               				,   x_msg_data           => l_msg_data);

        	    				IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
     		                			WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
							WriteToLog ('ERROR: Apply_holds returned expected error.', 1);
							WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
							raise fnd_api.g_exc_error;

        	    				ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     		       					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
							WriteToLog ('ERROR: Apply_holds returned unexpected error.', 1);
							WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
                					raise fnd_api.g_exc_error;
		    				END IF;
						l_order_num := v_holds.order_num;
						l_line_num := v_holds.line_num;

						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
						WriteToLog ('WARNING: Order line put on hold due to dropped components on configuration item '|| v_config , 1);
						WriteToLog ('Order number: '||l_order_num, 1);
						WriteToLog ('Line number: '||l_line_num, 1);
						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
					ELSE /* l_hold_result_out */
						l_order_num := v_holds.order_num;
						l_line_num := v_holds.line_num;


						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
						WriteToLog ('Order line already on hold.', 1);
						WriteToLog ('Order number: '||l_order_num, 1);
						WriteToLog ('Line number: '||l_line_num, 1);
						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
					END IF; /* l_hold_result_out */
				END IF; /* check holds returns error */
			END LOOP;
		ELSE /* l_config_creation is 1 or 2 */

               	   WriteToLog('Going to Get order Information .' ,1);


                   begin

                        v_orders_present := 1 ;

			select oel.line_id,
				oel.header_id,
				oeh.order_number,
				to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||decode(oel.option_number,NULL,NULL,'.'||to_char(option_number))
			into l_hold_source_rec.line_id,
				l_hold_source_rec.header_id,
				l_order_num,
				l_line_number
			from bom_cto_order_lines_upg bcolu,
			oe_order_lines_all oel,
			oe_order_headers_all oeh
			where bcolu.line_id = pLineId
			and bcolu.ato_line_id = oel.ato_line_id  /* BUG 3396081 dropped component in lower config */
                        and oel.item_type_code = 'CONFIG'
			and oel.header_id = oeh.header_id;


                   EXCEPTION
                   when no_data_found then
               		       WriteToLog('No Orders present for this configuration.' ,1);
                               v_orders_present := 0 ;


                   when others then
                               raise ;
                   END ;



                   if( v_orders_present = 1 ) then


               		WriteToLog('Going to Check Holds .' ,1);

			--
			-- apply hold if one does not already exist
			--
			OE_HOLDS_PUB.Check_Holds (
	 			p_api_version 		=> 1.0
				,p_line_id 		=> pLineId
				,x_result_out 		=> l_hold_result_out
				,x_return_status 	=> l_return_status
				,x_msg_count 		=> l_msg_count
				,x_msg_data 		=> l_msg_data);

			IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               			WriteToLog('Failed in Check Holds with expected error.' ,1);
               			raise FND_API.G_EXC_ERROR;
       			ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               			WriteToLog('Failed in Check Holds with unexpected error.' ,1);
               			raise FND_API.G_EXC_UNEXPECTED_ERROR;
       			ELSE
               			WriteToLog('Success in Check Holds.' ,1);
				if l_hold_result_out = FND_API.G_FALSE then

					WriteToLog('Calling OM api to apply hold.' ,1);
	    				l_hold_source_rec.hold_entity_code   := 'O';
               				l_hold_source_rec.hold_id            := 55;
               				--l_hold_source_rec.hold_entity_id     := v_holds.header_id;
					l_hold_source_rec.hold_entity_id     := l_hold_source_rec.header_id;
               				--l_hold_source_rec.header_id          := v_holds.header_id;
              				--l_hold_source_rec.line_id            := v_holds.ato_line_id;

               		                WriteToLog('Going to Apply Holds .' ,1);


	    				OE_Holds_PUB.Apply_Holds (
			   			p_api_version        => 1.0
                       				,   p_hold_source_rec    => l_hold_source_rec
                       				,   x_return_status      => l_return_status
                       				,   x_msg_count          => l_msg_count
                       				,   x_msg_data           => l_msg_data);

       	    				IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	                			WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
						WriteToLog ('ERROR: Apply_holds returned expected error.', 1);
						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
						raise fnd_api.g_exc_error;

       	    				ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	       					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
						WriteToLog ('ERROR: Apply_holds returned unexpected error.', 1);
						WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
               					raise fnd_api.g_exc_error;
	    				END IF;
					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
					WriteToLog ('WARNING: Order line put on hold due to dropped components on configuration item '|| v_config , 1);
					WriteToLog ('Order number: '||l_order_num, 1);
					WriteToLog ('Line number: '||l_line_number, 1);
					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
				ELSE
					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
					WriteToLog ('Order line already on hold.', 1);
					WriteToLog ('Order number: '||l_order_num, 1);
					WriteToLog ('Line number: '||l_line_number, 1);
					WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
				END IF; /* l_hold_results */
			END IF; /* line not on hold */

                   END IF; /* check for orders present */

		END IF; /* l_config_creation = 3 */
	--END IF; /*l_program_id <> 99 */
	if ( lcreate_item <> 1 ) then
		WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog ('ERROR: BOM for configuration item '||v_config||' is not created due to dropped components.', 1);
		WriteToLog ('+++++++++++++++++++++++++++++++++++++++++++++', 1);
		close missed_lines;

		--
		-- Update status to 'ERROR'
		-- Update for all lines having this config if config creation = 3
		--
		IF l_config_creation = 3 THEN
			update bom_cto_order_lines_upg bcolu1
			set bcolu1.status = 'ERROR'
			where bcolu1.ato_line_id in
				(select bcolu2.ato_line_id
				from bom_cto_order_lines_upg bcolu2
				where config_item_id = pConfigId);

			WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
		ELSE
			update bom_cto_order_lines_upg bcolu1
			set bcolu1.status = 'ERROR'
			where bcolu1.ato_line_id =
				(select bcolu2.ato_line_id
				from bom_cto_order_lines_upg bcolu2
				where bcolu2.line_id = pLineId);

			WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
		END IF;
		return(1);
	end if;
end if;
close missed_lines;

EXCEPTION                 -- exception for stmt 51 and 55
when others then
	WriteToLog ('Failed in stmt ' || lStmtNum || ' with error: '||sqlerrm, 1);
	raise fnd_api.g_exc_error;
END ; /* check for dropped components */

/*---------------------------------------------------------------+
       Third : Get the base model row into BOM_INVENTORY_COMPONENTS
+----------------------------------------------------------------*/

lStmtNum := 60;
insert into BOM_INVENTORY_COMPS_INTERFACE
       (
       operation_seq_num,
       component_item_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       item_num,
       component_quantity,
       component_yield_factor,
       component_remarks,
       effectivity_date,
       change_notice,
       implementation_date,
       disable_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       planning_factor,
       quantity_related,
       so_basis,
       optional,
       mutually_exclusive_options,
       include_in_cost_rollup,
       check_atp,
       shipping_allowed,
       required_to_ship,
       required_for_revenue,
       include_on_ship_docs,
       include_on_bill_docs,
       low_quantity,
       high_quantity,
       acd_type,
       old_component_sequence_id,
       component_sequence_id,
       bill_sequence_id,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       wip_supply_type,
       pick_components,
       model_comp_seq_id,
       bom_item_type,
       optional_on_model,	-- New columns for configuration
       parent_bill_seq_id,	-- BOM restructure project.
       plan_level		-- Used by CTO only.
      , basis_type,     /* LBM project */
       batch_id
       )
   select
       1,			-- operation_seq_num
       bcol.inventory_item_id,
       SYSDATE,                 -- last_updated_date
       1,                       -- last_updated_by
       SYSDATE,                 -- creation_date
       1,                       -- created_by
       1,                       -- last_update_login
       9,			-- item_num
       1,	                -- comp_qty
       1,			-- yield_factor
       NULL,                    --ic1.component_remark
       SYSDATE,                 -- effective date  -bug4150255: removed the trunc  04-10-2005
       NULL,                    -- change notice
       SYSDATE,                 -- implementation_date
       NULL,                    -- disable date
       NULL,			-- attribute_category
       NULL,			-- attribute1
       NULL,                    -- attribute2
       NULL,                    -- attribute3
       NULL,                    -- attribute4
       NULL,                    -- attribute5
       NULL,                    -- attribute6
       NULL,                    -- attribute7
       NULL,                    -- attribute8
       NULL,                    -- attribute9
       NULL,                    -- attribute10
       NULL,                    -- attribute11
       NULL,                    -- attribute12
       NULL,                    -- attribute13
       NULL,                    -- attribute14
       NULL,                    -- attribute15
       100,                     -- planning_factor
       2,                       -- quantity_related
       2,			-- so_basis
       2,                       -- optional
       2,                       -- mutually_exclusive_options
       2,			-- include_in_cost_rollup
       2,			-- check_atp
       2,                       -- shipping_allowed = NO
       2,                       -- required_to_ship = NO
       2,			-- required_for_revenue
       2,			-- include_on_ship_docs
       2,			-- include_on_bill_docs
       NULL,                    -- low_quantity
       NULL,                    -- high_quantity
       NULL,                    -- acd_type
       NULL,                    -- old_component_sequence_id
       bom_inventory_components_s.nextval,  -- component sequence id
       lConfigBillId,           -- bill sequence id
       NULL,                    -- request_id
       NULL,                    -- program_application_id
       NULL,                    -- program_id
       NULL,                    -- program_update_date
       6,			-- wip_supply_type
       2,                        -- pick_components = NO
       NULL,                    -- model comp seq id for later use
       1,                        -- bom_item_type
       1,			--optional_on_model,
       0,			--parent_bill_seq_id,
       0			--plan_level
       , 1,                      -- basis_type  /* LBM project */
       cto_msutil_pub.bom_batch_id
    from
       bom_cto_order_lines_upg bcol
    where   bcol.line_id = pLineId
    and     bcol.ordered_quantity <> 0
    and     bcol.inventory_item_id = pModelId;

lCnt := sql%rowcount ;
WriteToLog('Inserted ' || lCnt ||' rows into bom_inventory_comps_interface',3);

xBillId := lConfigBillId;

--
-- create routing
--

xRtgID           := 0;
lStatus := check_routing (pConfigId,
                              pOrgId,
                              lItmRtgId,
                              lCfmRtgFlag );

if lStatus = 1  then
       	WriteToLog('Config Routing' || lCfgRtgId || '  already exists ',2);
	GOTO ROUTING;
end if;

	/*-------------------------------------------------------------+
	      Config does not have  routing. If  model also does not have
	      routing, we do not need to do anything, return with success.
	+--------------------------------------------------------------*/

	lCfmRtgFlag := NULL;
	lStatus := check_routing (pModelId,
                              pOrgId,
                              lItmRtgId,
                              lCfmRtgFlag);
	if lStatus <> 1  then
	       	WriteToLog('Model Does not have a routing ',1);
		GOTO ROUTING;
   	end if;

		select bom_operational_routings_s.nextval
		into   lCfgRtgId
		from   dual;

		xTableName := 'BOM_OPERATIONAL_ROUTING';
		lStmtNum   := 30;

		WriteToLog('Inserting the routing header information into bom_operational_routings..',5);

		insert into bom_operational_routings
		       (
		       routing_sequence_id,
		       assembly_item_id,
		       organization_id,
		       alternate_routing_designator,
		       last_update_date,
		       last_updated_by,
		       creation_date,
		       created_by,
		       last_update_login,
		       routing_type,
		       common_routing_sequence_id,
		       common_assembly_item_id,
		       routing_comment,
		       completion_subinventory,
		       completion_locator_id,
		       attribute_category,
		       attribute1,
		       attribute2,
		       attribute3,
		       attribute4,
		       attribute5,
		       attribute6,
		       attribute7,
		       attribute8,
		       attribute9,
		       attribute10,
		       attribute11,
		       attribute12,
		       attribute13,
		       attribute14,
		       attribute15,
		       request_id,
		       program_application_id,
		       program_id,
		       program_update_date,
		       line_id,
		       mixed_model_map_flag,
		       priority,
		       cfm_routing_flag,
		       total_product_cycle_time,
		       ctp_flag,
		       project_id,
		       task_id
		       )
		select
		       lCfgRtgId,                    -- Routing Sequence Id
		       pConfigId,                    -- assembly item Id
		       pOrgId,                       -- Organization Id
		       null,                         -- alternate routing designator
		       sysdate,                      -- last update date
		       gUserID,                      -- last updated by
		       sysdate,
		       gUserId,	                         /* created_by */
		       gLoginId, 	                         /* last_update_login */
		       bor.routing_type,	         /* routing_type */
		       lCfgRtgId, 	                 /* common_routing_sequence_id */
		       null,                             /* common_assembly_item_id */
		       bor.routing_comment,
		       bor.completion_subinventory,
		       bor.completion_locator_id,
		       bor.attribute_category,           -- 4049807
		       bor.attribute1,
		       bor.attribute2,
		       bor.attribute3,
		       bor.attribute4,
		       bor.attribute5,
		       bor.attribute6,
		       bor.attribute7,
		       bor.attribute8,
		       bor.attribute9,
		       bor.attribute10,
		       bor.attribute11,
		       bor.attribute12,
		       bor.attribute13,
		       bor.attribute14,
		       bor.attribute15,
		       null,
		       null,
		       -99,	--program_id
		       null,
		       bor.line_id,
		       bor.mixed_model_map_flag,
		       bor.priority,
		       bor.cfm_routing_flag,
		       bor.total_product_cycle_time,
		       bor.ctp_flag,
		       bor.project_id,
		       bor.task_id
		from
		       bom_operational_routings  bor,
		       mtl_parameters            mp
		where   bor.assembly_item_id     = pModelId
		and     bor.organization_id      = pOrgId
		and     bor.alternate_routing_designator is null
		and     mp.organization_id       = pOrgId;

		WriteToLog('Inserted Routing Header :' || lCfgRtgId, 4);

		/*---------------------------------------------------------------+
		      Udpate the mixed_model_map_flag. If the cfm_routing_flag
		      is 1, then mixed_model_flag should be 1 if any flow_routing
		      (primary or alternate) for the model has the mixed_model_flag
		      equal to 1.
		+----------------------------------------------------------------*/

		lStmtNum := 40;

		update bom_operational_routings b
		       set mixed_model_map_flag =
		       ( select 1
		             from  bom_operational_routings bor
		             where bor.assembly_item_id     = pModelId
		             and   bor.organization_id      = pOrgId
		             and   bor.cfm_routing_flag     = 1
		             and   bor.mixed_model_map_flag = 1
		             and   bor.alternate_routing_designator is not NULL )
		where  b.routing_sequence_id = lCfgRtgID
		and    b.mixed_model_map_flag <> 1
		and    b.cfm_routing_flag =1;

		/*---------------------------------------------------------------+
		        Identify all distinct operation steps to be picked up from
		        Model routing and mark the last_update_login field
		        for those to lCfgRtgId.
		        Ignore option dependednt flag on operations types 2 and 3
		        Copy from Model Item's routing only.
		        -- Mandatory steps  model
		        -- option dependent steps associated with options/option Class
			-- "additional" option dependent steps associated with options/OC
		        -- Option dependent steps associated with mandatory comps.
			-- "additional" Option dependent steps associated with mandatory comps.
			The "additional" operation steps are the steps stored in the new
			table bom_component_operations to support one-to-many BOM components
			to Routing steps.
		+----------------------------------------------------------------*/

lStmtNum := 50;
/*
 Fixed Performance bug in the following sql. AS the following sql is huge one,
 performance team asked us to divide the sql into pieces. We are planning to
 insert a record from each sub query in the union class and then update it from
 temp table
 */

 l_batch_id := bom_import_pub.get_batchid;

 insert into bom_op_sequences_interface
            (
             operation_seq_num,
	     operation_type,
	     routing_sequence_id,
	     batch_id
	    )
 select distinct
          os1.operation_seq_num,
          nvl(operation_type,1),
          os1.routing_sequence_id,
	  l_batch_id
 from
          bom_cto_order_lines_upg   bcol1,
          mtl_system_items          si1,
          bom_operational_routings  or1,
          bom_operation_sequences   os1
 where  bcol1.line_id      = pLineId
 and    bcol1.inventory_item_id = pModelId
 and    si1.organization_id     = pOrgId -- this is the mfg org from src_orgs
 and    si1.inventory_item_id   = bcol1.inventory_item_id
 and    si1.bom_item_type       = 1                /* model  */
 and    or1.assembly_item_id    = si1.inventory_item_id
 and    or1.organization_id     = si1.organization_id
 and    or1.alternate_routing_designator is NULL
 and    nvl(or1.cfm_routing_flag,2)    = lCfmRtgflag
 and    os1.routing_sequence_id = or1.common_routing_sequence_id
 and    ( os1.operation_type in (2,3)
            or ( os1.option_dependent_flag  = 2
                 and     nvl(os1.operation_type,1 ) = 1 ))
 and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate ));

 insert into bom_op_sequences_interface
            (
             operation_seq_num,
	     operation_type,
	     routing_sequence_id,
	     batch_id
	    )
 select distinct
       os1.operation_seq_num,
       NVL(os1.operation_type,1),
       os1.routing_sequence_id,
       l_batch_id
 from
       bom_cto_order_lines_upg bcol1,	-- components
       bom_cto_order_lines_upg bcol2,	-- parent models or option classes
       mtl_system_items msi,
       bom_inventory_components  ic1,
       bom_bill_of_materials     b1,
       bom_operational_routings  or1,
       bom_operation_sequences   os1
 where  bcol1.parent_ato_line_id = pLineId         /*AP*/
 and    bcol1.item_type_code in  ('CLASS','OPTION') /* OC and Option items */
 and    bcol1.line_id <> bcol2.line_id
 and    bcol2.inventory_item_id = msi.inventory_item_id
 and    msi.organization_id = pOrgId -- new from src_orgs
 and    msi.bom_item_type = 1
 and    bcol2.line_id = pLineId
 and    bcol2.ordered_quantity <> 0
 and    bcol2.line_id  = bcol1.link_to_line_id
 and  ic1.bill_sequence_id = (
        select common_bill_sequence_id
        from   bom_bill_of_materials bbm
        where  organization_id = pOrgId
        and    alternate_bom_designator is null
        and    assembly_item_id =(
            select distinct assembly_item_id
            from   bom_bill_of_materials bbm1,
                   bom_inventory_components bic1
            where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
            and    component_sequence_id        = bcol1.component_sequence_id
            and    bbm1.assembly_item_id        = bcol2.inventory_item_id ))
 and    ic1.component_item_id           = bcol1.inventory_item_id
 and    ic1.effectivity_date<= g_SchShpdate
 and    NVL(ic1.disable_date, (lEstRelDate + 1)) > lEstRelDate
 and    b1.common_bill_sequence_id     = ic1.bill_sequence_id
 and    b1.assembly_item_id = bcol2.inventory_item_id  -- fix to bug 1272142
 and    b1.alternate_bom_designator is NULL
 and    or1.assembly_item_id           = b1.assembly_item_id
 and    or1.organization_id            = b1.organization_id
 and	   b1.organization_id		  = pOrgId  --bug 1935580
 and    or1.alternate_routing_designator is null
 and    nvl(or1.cfm_routing_flag,2)           = lCfmRtgFlag
 and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
 and    os1.routing_sequence_id         = or1.common_routing_sequence_id
 and    ((os1.operation_seq_num     = ic1.operation_seq_num)
  	or (os1.operation_seq_num in
		(select bco.operation_seq_num
		from bom_component_operations bco
		where bco.component_sequence_id = ic1.component_sequence_id)))
 and    os1.option_dependent_flag       = 1
 and    nvl(os1.operation_type,1)       = 1;


 insert into bom_op_sequences_interface
            (
             operation_seq_num,
	     operation_type,
	     routing_sequence_id,
	     batch_id
	    )
select
        distinct
        os1.operation_seq_num,
        nvl(os1.operation_type,1),
        os1.routing_sequence_id,
	l_batch_id
from
	bom_operation_sequences    os1,
        bom_operational_routings   or1,
        mtl_system_items           si2,
        bom_inventory_components   ic1,
        bom_bill_of_materials      b1,
        mtl_system_items           si1
where  si1.organization_id       = pOrgId
and    si1.inventory_item_id     = pModelId
and    si1.bom_item_type         = 1 /* model */
and    b1.organization_id        = si1.organization_id
and    b1.assembly_item_id       = si1.inventory_item_id
and    b1.alternate_bom_designator is null
and    or1.assembly_item_id      = b1.assembly_item_id
and    or1.organization_id       = b1.organization_id
and    or1.alternate_routing_designator is null
and    nvl(or1.cfm_routing_flag,2)      = lCfmRtgFlag    /*ensure correct OC rtgs*/
and    os1.routing_sequence_id   = or1.common_routing_sequence_id
and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
and    ic1.bill_sequence_id    = b1.common_bill_sequence_id
and    ic1.optional     = 2
and    ic1.implementation_date is not null
and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
and    si2.inventory_item_id     = ic1.component_item_id
and    si2.organization_id       = b1.organization_id
and    si2.bom_item_type         = 4        /* standard */
and    os1.option_dependent_flag = 1
and    ((os1.operation_seq_num     = ic1.operation_seq_num)
    	or (os1.operation_seq_num in
		(select bco.operation_seq_num
		from bom_component_operations bco
		where bco.component_sequence_id = ic1.component_sequence_id)))
and    nvl(os1.operation_type,1) = 1;


-- Fixed by Renga Kannan on 05/23/06
-- Fixed bug 5228179
-- Start updating config_routing_id for performance reasons
Update bom_operation_sequences
set    config_routing_id = lCfgRtgId,
       last_update_date  = glast_update_date
Where (
        operation_seq_num,
	nvl(operation_type,1),
	routing_sequence_id) In
	(select operation_seq_num,
	        nvl(operation_type,1),
	        routing_sequence_id
	 from   bom_op_sequences_interface
	 where  batch_id = l_batch_id)
and    implementation_date is not null
and  ( disable_date is null or
         (disable_date is not null and  disable_date >= sysdate ))
RETURNING routing_sequence_id BULK COLLECT INTO tModOpClassRtg;

WriteToLog('Model Routing : Marked ' || sql%rowcount || ' records for insertion',4);--moved here for 4492875

delete from bom_op_sequences_interface where batch_id = l_batch_id;

if tModOpClassRtg.count > 0 then
      k := 1;
      tDistinctRtgSeq(k) := tModOpClassRtg(1);
      for i in tModOpClassRtg.FIRST..tModOpClassRtg.LAST
      loop
    	lexists := 'N';
    	for j in tDistinctRtgSeq.FIRST..tDistinctRtgSeq.LAST
	loop
	   if tDistinctRtgSeq(j) = tModOpClassRtg(i) then
	       lexists := 'Y';
	       exit;
	   end if;
	end loop;
	if lexists = 'N' then
	   k := k+1;
	   tDistinctRtgSeq(k) := tModOpClassRtg(i);
	end if;
      end loop;

end if;

--- Added by Renga Kannan



if( tDistinctRtgSeq.count > 0 ) then
     for i in tDistinctRtgSeq.first..tDistinctRtgSeq.last
     loop
      	if( tDistinctRtgSeq.exists(i) ) then
      	    WriteToLog('Distinct Model Routing Seq Id: '||tDistinctRtgSeq(i),4);
      	end if ;
     end loop ;

else
        WriteToLog('Distinct Table contains ' || tDistinctRtgSeq.count, 4 ) ;
end if ;


lStmtNum := 51;
lmodnewCfgRtgId := lCfgRtgId * (-1);
lmodseqnum:=0;
lmodtyp:=0;
lmodrtgseqid :=0;

open get_op_seq_num(lCfgRtgId);

loop
    	fetch get_op_seq_num into lmodseqnum,lmodtyp;
    	exit when get_op_seq_num%notfound;

       	WriteToLog('Op Seq # : ' || lmodseqnum || ' Op Type : ' || lmodtyp ,4);
	WriteToLog('Estimated release date lEstRelDate '|| to_char(lEstRelDate,'mm-dd-yy:hh:mi:ss'), 4);

        select max(routing_sequence_id) into lmodrtgseqid
    	from   bom_operation_sequences
        where  operation_seq_num = lmodseqnum
        and    nvl(operation_type,1)= lmodtyp
        --and    last_update_login=lCfgRtgId
	and 	config_routing_id = lCfgRtgId
	and    last_update_date = glast_update_date;

       	WriteToLog('Max. Routing Seq Id : ' || lmodrtgseqid, 4);

        update bom_operation_sequences
        --set    last_update_login=lmodnewCfgRtgId
	set    config_routing_id=lmodnewCfgRtgId
        where  operation_seq_num = lmodseqnum
        and    nvl(operation_type,1)= lmodtyp
        and    routing_sequence_id=lmodrtgseqid
    	-- and    effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate)   NEw approach for effectivity dates
    	and    implementation_date is not null
        /*
    	and    nvl(disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
	and    nvl(disable_date,sysdate+1) > sysdate;--Bugfix 2771065
        */
        and  ( disable_date is null or
         (disable_date is not null and  disable_date >= sysdate )) ;/* New Approach for Effectivity Dates */


       	WriteToLog('Update login to ' || lmodnewCfgRtgId ||' where routing seq Id is '||lmodrtgseqid, 4);

end loop;
close get_op_seq_num;

WriteToLog('Model Routing : Marked ' || sql%rowcount || ' rows for insertion' , 4);

/*-----------------------------------------------------------------+
         First Insert :
         Load  distinct operation steps from Model's routing
+-------------------------------------------------------------------*/

lStmtNum := 60;

WriteToLog('Inserting into bom_operation_sequences - 1st insert ..',5);

if( tDistinctRtgSeq.count > 0 ) then
      FORALL i IN tDistinctRtgSeq.FIRST..tDistinctRtgSeq.LAST
      insert into bom_operation_sequences
        (
        operation_sequence_id,
        routing_sequence_id,
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,-- new column for 11.5.4 BOM patchset
	x_coordinate,           --bugfix 1765149
        y_coordinate            --bugfix 1765149
        )
    select
        bom_operation_sequences_s.nextval,      /* operation_sequence_id */
        lcfgrtgid,                              /* routing_sequence_id */
        os1.operation_seq_num,
        sysdate,                                /* last update date */
        gUserId,                                /* last updated by */
        sysdate,                                /* creation date */
        gUserId,                                /* created by */
        gLoginId,                               /* last update login  */
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        trunc(sysdate),         /* effective date */
        null,                   /* disable date */
        os1.backflush_flag,
        2,               /* option_dependent_flag */
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
        os1.operation_sequence_id,  /* using request_id  column to store model op seq id */
        1,                          /* program_application_id */
        1,                          /* program_id */
        sysdate,                    /* program_update_date */
        reference_flag,
        nvl(operation_type,1),
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	trunc(sysdate), 	-- new column for 11.5.4 BOM patchset
	os1.x_coordinate,           --bugfix 1765149
        os1.y_coordinate            --bugfix 1765149
    from
        bom_operation_sequences    os1
      --where os1.last_update_login = lmodnewcfgrtgid
      where os1.config_routing_id = lmodnewcfgrtgid
      and   os1.routing_sequence_id = tDistinctRtgSeq(i);

end if;

WriteToLog('Inserted ' || sql%rowcount || ' rows in BOS', 3);

tModOpClassRtg.DELETE;
tDistinctRtgSeq.DELETE;

/*--------------------------------------------------------------+
       Intialize last_update_login column so that it can be used
       to identify steps from option class routings
+---------------------------------------------------------------*/

lStmtNum := 70;
update bom_operation_sequences
--set last_update_login =  - 1
set config_routing_id =  - 1
--where last_update_login in (lCfgRtgId, lmodnewcfgrtgid);
where config_routing_id in (lCfgRtgId, lmodnewcfgrtgid);

WriteToLog('Initialized config_routing_id for ' || sql%rowcount || ' rows in BOS', 4);

/*--------------------------------------------------------------+
       Mark all steps that need to be picked up from option
       Class routings
        -- Mandatory steps of Class routing
        -- Option dependent steps  associated with options/option Class
	-- "Additional" option dependent steps  associated with options/option Class
        -- Option dependent steps associated with mandatory comps.
	-- "Additional" option dependent steps associated with mandatory comps.
	The "additional" operation steps are the steps stored in the new
	table bom_component_operations to support one-to-many BOM components
	to Routing steps.
+-------------------------------------------------------------*/
lStmtNum := 80;
update bom_operation_sequences
--set   last_update_login = lCfgRtgId
set   config_routing_id = lCfgRtgId
    	 ,last_update_date = glast_update_date           -- 3180827
where  (
          operation_seq_num,
          nvl(operation_type,1),
          routing_sequence_id
          ) in (
    select
        distinct
        os1.operation_seq_num,
        nvl(os1.operation_type,1),
        os1.routing_sequence_id
    from
        mtl_system_items          si1,
	bom_cto_order_lines_upg   bcol,
        bom_operational_routings  or1,
        bom_operation_sequences   os1
    where   bcol.parent_ato_line_id = pLineId
    and     si1.organization_id     = pOrgId
    and     si1.inventory_item_id   = bcol.inventory_item_id
    and     si1.bom_item_type       in ( 1, 2 )     /* Models and Classes  */
    and     bcol.line_id <> pLineId
    and     or1.assembly_item_id    = si1.inventory_item_id
    and     or1.organization_id     = si1.organization_id
    and     or1.alternate_routing_designator is NULL
    and     NVL(or1.cfm_routing_flag,2)  = lCfmRtgflag
    and     os1.routing_sequence_id = or1.common_routing_sequence_id
    /*
    and     os1.effectivity_date    <= greatest(nvl(lEstRelDate, sysdate),sysdate)
    and     nvl(os1.disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
    */
  and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    and     ( os1.operation_type in (2,3)
              OR ( os1.option_dependent_flag  = 2
                   and     NVL(os1.operation_type,1 ) = 1 ))
    union
    select
        distinct
        os1.operation_seq_num,
        nvl(os1.operation_type,1),
        os1.routing_sequence_id
    from
        bom_cto_order_lines_upg   bcol1,               /* components */
        bom_cto_order_lines_upg   bcol2, 		/* parents  model   */
        bom_inventory_components  ic1,
        bom_bill_of_materials     b1,
        bom_operational_routings  or1,
        bom_operation_sequences   os1
    where  bcol1.parent_ato_line_id  = pLineId
    and    bcol1.item_type_code in  ('CLASS','OPTION')
    and    bcol2.parent_ato_line_id = pLineId
    and    bcol2.line_id <> pLineId    /*AP*/
    and    bcol2.item_type_code  =  'CLASS' /*  option classes */
    and    bcol2.ordered_quantity <> 0
    and    bcol2.line_id = bcol1.link_to_line_id
    and ic1.bill_sequence_id = (
        select common_bill_sequence_id
        from   bom_bill_of_materials bbm
        where  organization_id = pOrgId
        and    alternate_bom_designator is null
        and    assembly_item_id =(
            select distinct assembly_item_id
            from   bom_bill_of_materials bbm1,
                   bom_inventory_components bic1
            where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
            and    component_sequence_id        = bcol1.component_sequence_id
            and    bbm1.assembly_item_id        = bcol2.inventory_item_id ))
    and    ic1.component_item_id           = bcol1.inventory_item_id
    /*
    and    ic1.effectivity_date<= g_SchShpDate
    and    NVL(ic1.disable_date, (lEstRelDate + 1)) > lEstRelDate
    */
  and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    and    b1.common_bill_sequence_id     = ic1.bill_sequence_id
    and    b1.assembly_item_id = bcol2.inventory_item_id -- fix for bug 1272142
    and    b1.alternate_bom_designator is NULL
    and    or1.assembly_item_id           = b1.assembly_item_id
    and    or1.organization_id            = b1.organization_id
    and	   b1.organization_id		= pOrgId  --bug 1210477
    and    or1.alternate_routing_designator is null
    and    nvl(or1.cfm_routing_flag,2)           = lCfmRtgFlag
/*
    and    os1.effectivity_date           <= greatest(nvl(lEstRelDate, sysdate),sysdate)
    and    nvl(os1.disable_date,nvl(lEstRelDate, sysdate)+ 1) > nvl(lEstRelDate,sysdate)
*/
  and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    and    os1.routing_sequence_id         = or1.common_routing_sequence_id
    and    ((os1.operation_seq_num     = ic1.operation_seq_num)
    	or (os1.operation_seq_num in
		(select bco.operation_seq_num
		from bom_component_operations bco
		where bco.component_sequence_id = ic1.component_sequence_id)))
    and    os1.option_dependent_flag       = 1
    and    nvl(os1.operation_type,1)       = 1
    union
    select
        distinct
        os1.operation_seq_num,
        nvl(os1.operation_type,1),
        os1.routing_sequence_id
    from
        bom_operation_sequences    os1,
        bom_operational_routings   or1,
        mtl_system_items           si2,
        bom_inventory_components   ic1,
        bom_bill_of_materials      b1,
        mtl_system_items           si1,
        bom_cto_order_lines_upg    bcol        /* Model or option class */
    where  bcol.parent_ato_line_id = pLineId
    and    bcol.component_sequence_id is not null
    and    bcol.ordered_quantity       <> 0
    and    si1.organization_id       = pOrgId
    and    si1.inventory_item_id     = bcol.inventory_item_id
    and    si1.bom_item_type in (1,2) /* model or option class */
    and    b1.organization_id        = pOrgId
    and    b1.assembly_item_id       = bcol.inventory_item_id
    and    b1.alternate_bom_designator is null
    and    ic1.bill_sequence_id      = b1.common_bill_sequence_id
    and    ic1.optional              = 2
    -- and    ic1.effectivity_date     <= greatest(nvl(g_SchShpdate, sysdate),sysdate)  New Approach for effectivity dates
    and    ic1.implementation_date is not null
    -- and    nvl(ic1.disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
  and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    and    si2.inventory_item_id     = ic1.component_item_id
    and    si2.organization_id       = b1.organization_id
    and    si2.bom_item_type         = 4        /* standard */
    and    or1.assembly_item_id      = b1.assembly_item_id
    and    or1.organization_id       = b1.organization_id
    and    or1.alternate_routing_designator is null
    and    nvl(or1.cfm_routing_flag,2) = lCfmRtgFlag
/*
    and    os1.effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate)
    and    nvl(os1.disable_date,nvl(lEstRelDate, sysdate)+ 1) > nvl(lEstRelDate,sysdate)
*/
  and  ( os1.disable_date is null or
         (os1.disable_date is not null and  os1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    and    os1.routing_sequence_id   = or1.common_routing_sequence_id
    and    os1.option_dependent_flag = 1
    and    ((os1.operation_seq_num     = ic1.operation_seq_num)
    	or (os1.operation_seq_num in
		(select bco.operation_seq_num
		from bom_component_operations bco
		where bco.component_sequence_id = ic1.component_sequence_id)))
    and    nvl(os1.operation_type,1) = 1)
    -- and    effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate)
    and    implementation_date is not null
/*
    and    nvl(disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
    and   nvl(disable_date,sysdate+1) > sysdate --Bugfix 2771065
*/
  and  ( disable_date is null or
         (disable_date is not null and  disable_date >= sysdate )) /* New Approach for Effectivity Dates */
    RETURNING routing_sequence_id BULK COLLECT INTO tModOpClassRtg;

WriteToLog('Option Routing : Marked ' || sql%rowcount || ' rows for insertion' ,3);--moved here for 4492875

/*3093686  get only the distinct ones */

if tModOpClassRtg.count > 0  then
      k := 1;
      tDistinctRtgSeq(k) := tModOpClassRtg(1);
      for i in tModOpClassRtg.FIRST..tModOpClassRtg.LAST
      loop
    	lexists := 'N';
    	for j in tDistinctRtgSeq.FIRST..tDistinctRtgSeq.LAST
	loop
	   if tDistinctRtgSeq(j) = tModOpClassRtg(i) then
	       lexists := 'Y';
	       exit;
	   end if;
	end loop;
	if lexists = 'N' then
	   k := k+1;
	   tDistinctRtgSeq(k) := tModOpClassRtg(i);
	end if;
      end loop;
end if;

if( tDistinctRtgSeq.count > 0 ) then
     for i in tDistinctRtgSeq.first..tDistinctRtgSeq.last
     loop
      	if( tDistinctRtgSeq.exists(i) ) then
      	  IF PG_DEBUG <> 0 THEN
      	    WriteToLog('Distinct Option Class Routing Seq Id: '||tDistinctRtgSeq(i),1);
      	  END IF;
      	end if ;
     end loop ;

else
       WriteToLog( 'Distinct Table contains ' || tDistinctRtgSeq.count, 5 ) ;
end if ;


lStmtNum := 81;
lnewCfgRtgId := lCfgRtgId * (-1);
lopseqnum:=0;
loptyp:=0;
lrtgseqid:=0;

open get_op_seq_num(lCfgRtgId);

loop
    	fetch get_op_seq_num into lopseqnum,loptyp;
    	exit when get_op_seq_num%notfound;

	WriteToLog('Op Seq # : ' || lopseqnum || ' Op Type : ' || loptyp , 4);

        select max(routing_sequence_id) into lrtgseqid
    	from bom_operation_sequences
        where operation_seq_num = lopseqnum
        and   nvl(operation_type,1)= loptyp
        --and   last_update_login=lCfgRtgId
	and   config_routing_id=lCfgRtgId
	and   last_update_date = glast_update_date;

	WriteToLog('Max. Routing Seq Id : ' || lrtgseqid, 4);

        update bom_operation_sequences
        --set last_update_login=lnewCfgRtgId
	set config_routing_id=lnewCfgRtgId
        where operation_seq_num = lopseqnum
        and   nvl(operation_type,1)= loptyp
        and   routing_sequence_id=lrtgseqid
    	-- and    effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate) -- 2650828 New approach for effectivity dates
    	and    implementation_date is not null
        /*
    	and    nvl(disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
	and    nvl(disable_date,sysdate+1) > sysdate;--Bugfix 2771065
        */
  and  ( disable_date is null or
         (disable_date is not null and  disable_date >= sysdate )) ; /* New Approach for Effectivity Dates */


	WriteToLog('Update login to ' || lnewCfgRtgId ||' where routing seq Id is '||lrtgseqid, 4);

end loop;
close get_op_seq_num;




/*-----------------------------------------------------------------+
       Second Insert :
       Load  distinct operation steps from Class(es) routing
       ( steps include Option independednt steps, option dependednt
       steps associated with selected components, option dependent
       steps associated with mandatory componets)
+-------------------------------------------------------------------*/

lStmtNum := 90;

WriteToLog('Inserting into bom_operation_sequences - 2nd insert ..',5);

    if( tDistinctRtgSeq.count > 0 ) then				-- 3093686
     FORALL i IN tDistinctRtgSeq.FIRST..tDistinctRtgSeq.LAST		-- 3093686
      insert into bom_operation_sequences
        (
        operation_sequence_id,
        routing_sequence_id,
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,	-- new column for 11.5.4 BOM patchset
	x_coordinate,           --bugfix 1765149
        y_coordinate            --bugfix 1765149
        )
    select
        bom_operation_sequences_s.nextval, /* operation_sequence_id */
        lcfgrtgid,                         /* routing_sequence_id */
        os1.operation_seq_num,
        sysdate,                           /* last update date */
        gUserId,                           /* last updated by */
        sysdate,                           /* creation date */
        gUserID,                           /* created by */
        gLoginId,                          /* last update login  */
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        trunc(sysdate),                    /* effective date */
        null,                              /* disable date */
        os1.backflush_flag,
        2,                                 /* option_dependent_flag */
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
        os1.operation_sequence_id,  /* using request_id ->  model op seq id */
        1,                          /* program_application_id */
        1,                          /* program_id */
        sysdate,                    /* program_update_date */
        reference_flag,
        nvl(operation_type,1),
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	trunc(sysdate),	-- new column for 11.5.4 BOM patchset
	os1.x_coordinate,           --bugfix 1765149
        os1.y_coordinate            --bugfix 1765149
       from
	bom_operation_sequences    os1
       --where  os1.last_update_login = lnewCfgRtgId  /*Bugfix 1906371 - change lCfgRtgId to  lnewCfgRtgId */
	where  os1.config_routing_id = lnewCfgRtgId  /*Bugfix 1906371 - change lCfgRtgId to  lnewCfgRtgId */
       and    os1.operation_seq_num not in (
            select operation_seq_num
            from   bom_operation_sequences bos1
             where  bos1.routing_sequence_id   = lCfgRtgId
				/* Bugfix 1983384 where  bos1.last_update_login   = lnewCfgRtgId */
            and    nvl(bos1.operation_type,1) = nvl(os1.operation_type,1))
       and   os1.routing_sequence_id = tDistinctRtgSeq(i);		-- 3093686
    end if;								-- 3093686

    	WriteToLog('Inserted  ' || sql%rowcount || 'rows ', 4);

    tModOpClassRtg.DELETE;
    tDistinctRtgSeq.DELETE;

    -- New update of 3180827
    lStmtNum := 95;
    update bom_operation_sequences
    --set last_update_login = - 1
    set config_routing_id = - 1
    --where last_update_login in (lCfgRtgId, lmodnewcfgrtgid);
    where config_routing_id in (lCfgRtgId, lmodnewcfgrtgid);

     /*-------------------------------------------------------------------+
             Now update the process_op_seq_id  and line_seq_id of
             all events to new operations sequence Ids (map).
             Old operation_sequence_ids are available in request_id
     +-------------------------------------------------------------------*/

     lStmtNum := 100;
     xTableName := 'BOM_OPERATION_SEQUENCES';
     -- bug 7425806: Events from option class routing operations also need to
     -- be linked to operations on config routing.
     /***********************************************************************
     update bom_operation_sequences bos1
     set    process_op_seq_id = (
         select  operation_sequence_id
         from   bom_operation_sequences bos2
         where  bos1.process_op_seq_id   = bos2.request_id
         and    bos2.routing_sequence_id = lCfgRtgId)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     lStmtNum := 110;
     update bom_operation_sequences bos1
     set    line_op_seq_id = (
         select  operation_sequence_id
         from   bom_operation_sequences bos2
         where  bos1.line_op_seq_id = bos2.request_id
         and    bos2.routing_sequence_id = lCfgRtgId)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;
     ***************************************************************************/

     update bom_operation_sequences bos1
     set line_op_seq_id = (
        select bos2.operation_sequence_id
        from bom_operation_sequences bos2,
             bom_operation_sequences bos3
        where bos3.operation_sequence_id = bos1.line_op_seq_id
        and   bos2.routing_sequence_id = lCfgRtgId
        and   bos3.operation_seq_num = bos2.operation_seq_num
        and   bos2.operation_type = 3)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     lStmtNum := 110;
     update bom_operation_sequences bos1
     set process_op_seq_id = (
        select bos2.operation_sequence_id
        from bom_operation_sequences bos2,
             bom_operation_sequences bos3
        where bos3.operation_sequence_id = bos1.process_op_seq_id
        and   bos2.routing_sequence_id = lCfgRtgId
        and   bos3.operation_seq_num = bos2.operation_seq_num
        and   bos2.operation_type = 2)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     -- end bug 7425806

     /*-----------------------------------------------------------+
           Delete routing from routing header  if
           there is no operation associated with the routing
     +-----------------------------------------------------------*/

     lStmtNum := 120;
     xTableName := 'BOM_OPERATIONAL_ROUTINGS';

     delete from BOM_OPERATIONAL_ROUTINGS b1
     where  b1.routing_sequence_id not in
         (select routing_sequence_id
          from   bom_operation_sequences )
     and    b1.routing_sequence_id = lCfgRtgId;

     if sql%rowcount > 0 then
        	WriteToLog( 'No operations were copied, config routing deleted. ', 2);
        	GOTO ROUTING;
     end if;


     /*--------------------------------------------------------------+
        If there is a  operation_seq_num associated with
        the config component which  not belong to the
        config routing, the operation_seq_num will be
        set to 1.
     +--------------------------------------------------------------*/
     lStmtNum := 130;
     xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';

     update bom_inventory_comps_interface ci
     set    ci.operation_seq_num = 1
     where not exists
          (select 'op seq exists in config routing'
           from
	       bom_operation_sequences bos,
               bom_operational_routings bor
           where bos.operation_seq_num = ci.operation_seq_num
           and   bos.routing_sequence_id = bor.routing_sequence_id
           and   bor.assembly_item_id = pConfigId
           and   bor.organization_id  = pOrgId
           and   bor.alternate_routing_designator is null)
     and   ci.bill_sequence_id = lConfigBillId;


     lstmtNum := 390;

     -- Begin Bugfix 8778162: Copy the attachment on routing header from model
     -- to config.
     lstmtNum := 395;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: Copying the attachment on routing header.', 2);
	oe_debug_pub.add ('create_routing_ml: Model routing_sequence_id:' || lItmRtgId, 2);
     END IF;

     FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
           X_from_entity_name              =>'BOM_OPERATIONAL_ROUTINGS',
           X_from_pk1_value                =>lItmRtgId,
           X_from_pk2_value                =>'',
           X_from_pk3_value                =>'',
           X_from_pk4_value                =>'',
           X_from_pk5_value                =>'',
           X_to_entity_name                =>'BOM_OPERATIONAL_ROUTINGS',
           X_to_pk1_value                  =>lCfgRtgId,
           X_to_pk2_value                  =>'',
           X_to_pk3_value                  =>'',
           X_to_pk4_value                  =>'',
           X_to_pk5_value                  =>'',
           X_created_by                    =>gUserId,
           X_last_update_login             =>gLoginId,
           X_program_application_id        =>'',
           X_program_id                    =>'',
           X_request_id                    =>''
           );
     -- End Bugfix 8778162

     --
     -- For each operation in the routing, copy attachments of operations
     -- copied from model/option class to operations on the config item
     --

     for nextop in allops loop

       lstmtNum := 400;

       FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
           X_from_entity_name              =>'BOM_OPERATION_SEQUENCES',
           X_from_pk1_value                =>nextop.request_id,
           X_from_pk2_value                =>'',
           X_from_pk3_value                =>'',
           X_from_pk4_value                =>'',
           X_from_pk5_value                =>'',
           X_to_entity_name                =>'BOM_OPERATION_SEQUENCES',
           X_to_pk1_value                  =>nextop.operation_sequence_id,
           X_to_pk2_value                  =>'',
           X_to_pk3_value                  =>'',
           X_to_pk4_value                  =>'',
           X_to_pk5_value                  =>'',
           X_created_by                    =>1,
           X_last_update_login             =>'',
           X_program_application_id        =>'',
           X_program_id                    =>'',
           X_request_id                    =>''
           );
     end loop;

     lstmtNum := 410;
     select nvl(cfm_routing_flag,2)
     into   lCfmRtgFlag
     from   bom_operational_routings
     where  routing_sequence_id = lCfgrtgId;


	--
	-- if flow manufacturing is installed and the 'Perform Flow Calulations'
     	-- parameter is set to 2 or 3 (perform calculations based on processes or perform
     	-- calulations based on Line operations) the routing is 'flow routing' then
     	-- calculate operation times, yields, net planning percent  and total
     	-- product cycle time for config routing
	--


     --
     -- Check if flow_manufacturing is installed
     --

     l_install_cfm := FND_INSTALLATION.Get_App_Info(application_short_name => 'FLM',
                                                    status      => l_status,
                                                    industry    => l_industry,
                                                    oracle_schema => l_schema);

     lstmtNum := 410;
     if ( l_status = 'I' and pFlowCalc >1 and lCfmRtgflag = 1 ) then

        --
        -- Calculate Operation times
        --

        BOM_CALC_OP_TIMES_PK.calculate_operation_times(
                             arg_org_id              => pOrgId,
                             arg_routing_sequence_id => lcfgRtgId);

        --
        -- Calculate cumu yield, rev cumu yield and net plannning percent
        --

        BOM_CALC_CYNP.calc_cynp(
                      p_routing_sequence_id => lcfgRtgId,
                      p_operation_type      => pFlowCalc,      /* operation_type = process */
                      p_update_events       => 1 );     /* update events */

        --
        -- Calculate total_product_cycle_time
        --

        BOM_CALC_TPCT.calculate_tpct(
                      p_routing_sequence_id => lcfgRtgId,
                      p_operation_type      => pFlowCalc);      /* Operation_type = Process */
     end if;

       -- Feature :Serial tracking in wip
       -- LOgic : serial tracking is enabled only when serial control mode is 'pre-defined' (ie 2)
       -- If model serialization_start_op seq is not populated, we will copy the minimum 'seriallization_start_op'
       -- of OC's chosen
       --modified by kkonada


     if( lCfmRtgFlag = 1) then ---flow doesnot support serial tracking
       null;
     else
            lstmtNum := 411;
            Select serial_number_control_code
            into   l_ser_code
            from   mtl_System_items
            where  inventory_item_id = pModelId
            and organization_id =pOrgId;

             	WriteToLog('serial_number_control_code of model is  '||l_ser_code , 4);

       	    if ( l_ser_code = 2) then --serialized ,pre-defined

                 lstmtNum := 412;

		  WriteToLog('select serial start op from model  ' , 4);

		  BEGIN
		         --will select serial start op of model, only if effective on the day
			 --as routing generation takes care of eefectivity, we check if op seq is present in config routing
		  	 select serialization_start_op
			 into l_ser_start_op
			 from bom_operational_routings
			 where assembly_item_id = pModelId
			 and alternate_routing_designator is null
			 and organization_id = pOrgId
			 and serialization_start_op in
						(Select OPERATION_SEQ_NUM
  	 		  		   	from bom_operation_sequences
						where routing_sequence_id = lCfgRtgId
						 );
		 EXCEPTION
		   WHEN no_data_found THEN
			l_ser_start_op := NULL;
		  END;

		 	WriteToLog('l_ser_start_op ie serialization_start_op from model is  '|| l_ser_start_op, 4);

		 if(l_ser_start_op is null)then

                   lstmtNum := 413;
                   	WriteToLog('Before updating config routing with serial start op of option class', 4);

                   begin
                	update bom_operational_routings
                   	set serialization_start_op =
					( select min( serialization_start_op)
                                          from bom_operational_routings
                                          where organization_id = pOrgId
                                          and alternate_routing_designator is null
                                          and assembly_item_id in
                                                       ( select component_item_id
                                                         from  bom_inventory_comps_interface
                                                         where bom_item_type =2
                                                         and  bill_sequence_id = lConfigBillId
                                                        )
					  and serialization_start_op in
							(Select OPERATION_SEQ_NUM
  	 							   	from bom_operation_sequences
									where routing_sequence_id = lCfgRtgId
							 )--serial start op exists as a operation in routing(ie effective oper)
                                         )
                  	where assembly_item_id = pConfigId
                 	and alternate_routing_designator is null
                  	and organization_id = pOrgId;

                       l_row_count := sql%rowcount;
                   exception
                     when no_data_found then
                	   	WriteToLog('No option classes chosen while creating coonfiguration ', 4);
		   end;

                   	WriteToLog('Config rows updated with OC serial start opseq->'||l_row_count, 4);

		  else --model has serial start op seq

			lstmtNum := 414;
			update bom_operational_routings
			set serialization_start_op = l_ser_start_op
			where routing_sequence_id =  lCfgRtgId ;

			 	WriteToLog('Updated with serial start op of model, serial start op =>'||l_ser_start_op  , 4);

                 end if;--l_ser_start_op
            end if;--l_ser_code
     end if; /* flow rtg */

<<ROUTING>>










     /*--------------------------------------------------------------+
	If more than one row in the BOM_INVENTORY_COMPS_INTERFACE
        that contain the same bill_sequence_id, operation_seq_num and
        component_item_id, those rows will be combined into a
        single row and  the accumulated COMPONENT_QUANTITY will be
        used in the row.
     +---------------------------------------------------------------*/

      -- start 3674833
     -- Populate seq_tab_arr with component sequence id information
     -- We need this info before inserting into bom_reference_designator
     -- 4244576 - Also need to get operstion_seq_num into an array.

        select  b1.model_comp_seq_id,  b1.component_item_id, b1.operation_seq_num
        BULK COLLECT INTO model_comp_seq_id_arr,  component_item_id_arr, operation_seq_num_arr
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b1.bill_sequence_id = lConfigBillId
        UNION
        select  b2.model_comp_seq_id,  b2.component_item_id, b2.operation_seq_num
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b2.bill_sequence_id = lConfigBillId
        ORDER by 2;


        if model_comp_seq_id_arr.count > 0 then
          for x1 in model_comp_seq_id_arr.FIRST..model_comp_seq_id_arr.LAST
            loop
            WriteToLog( ' Start Looping ',1);
             IF PG_DEBUG <> 0 THEN
                WriteToLog( ' Model_Comp_seq (' ||x1|| ') = ' ||model_comp_seq_id_arr(x1)
                                                ||' Component_item_id (' ||x1|| ') = ' ||component_item_id_arr(x1)
                        ||' operation-seq_num (' ||x1|| ') = ' ||operation_seq_num_arr(x1),1); --4244576
             END IF;
            end loop;
        end if;
     -- end 3674833


/*

*
*
*
*
*
*
     lSaveBomId      := 0;
     lSaveOpSeqNum   := 0;
     lSaveItemId     := 0;
     lSaveCompSeqId  := 0;
     lTotalQty       := 0;
     lSaveOptional   := 2;

     lStmtNum := 300;
     open consolidate_components;
        loop
           fetch consolidate_components  into
           lBomId,
           lOpSeqNum,
	   lCompSeqId,
           lItemId,
           lqty,
	   lOptional;
           exit when (consolidate_components%notfound);
           if lSaveBomId   <> lBomId then
            *--------------------------------------------+
	      different bill and not begining of the loop
	    +--------------------------------------------*
                if lTotalQty <> 0 then
                  update bom_inventory_comps_interface
                  set    component_quantity = Round( lTotalQty, 7) * Decimal-Qty Support for Option Items *
                  where  component_sequence_id = lSaveCompSeqId;
                end if;

		if lSaveOptional = 1 then
		  update bom_inventory_comps_interface
                  set    optional_on_model = lSaveOptional
                  where  component_sequence_id = lSaveCompSeqId;
		end if;

               lTotalQty := lqty;
               lSaveBomId   := lBomId;
               lSaveOpSeqNum  := lOpSeqNum;
               lSaveItemId := lItemId;
               lSaveCompSeqId := lCompSeqId;
	       if lOptional = 1 then
			lSaveOptional := 1;
	       end if;
           else
           *-----------------------------------------------+
                same bill but different item
	   +------------------------------------------------*
               if lSaveItemId <> lItemId then
                  update  bom_inventory_comps_interface
                  set     component_quantity = Round( lTotalQty, 7 ) * Decimal-Qty Support for Option Items *
                  where   component_sequence_id = lSaveCompSeqId;

		  if lSaveOptional = 1 then
			update  bom_inventory_comps_interface
                  	set     optional_on_model = lSaveOptional
                  	where   component_sequence_id = lSaveCompSeqId;
		  end if;

                  lTotalQty := lqty;
		  lSaveOptional := lOptional;
                  *--------------------------------------------+
	                same bill and item but different seq_num
	          +---------------------------------------------*
               else
                   if lSaveOpSeqNum  <> lOpSeqNum then
                      update bom_inventory_comps_interface
                      set    component_quantity = Round( lTotalQty  , 7 ) * Decimal-Qty Support for Option Items *
                      where  component_sequence_id = lSaveCompSeqId;
                      lTotalQty := lqty;

		      if lSaveOptional = 1 then
			update  bom_inventory_comps_interface
                  	set     optional_on_model = lSaveOptional
                  	where   component_sequence_id = lSaveCompSeqId;
		      end if;
		      lSaveOptional := lOptional;
                      *----------------------------------+
			     duplicated one
		      +----------------------------------*
                   else
                      delete bom_inventory_comps_interface
                      where component_sequence_id = lSaveCompSeqId;
                      lTotalQty := lTotalQty + lqty;
		      if lOptional = 1 then
			lSaveOptional := 1;
	       	      end if;
                   end if;
               end if;
               lSaveBomId   := lBomId;
               lSaveOpSeqNum  := lOpSeqNum;
               lSaveItemId := lItemId;
               lSaveCompSeqId := lCompSeqId;
           end if;
        end loop;
        *------------------------------------------------+
               handle the last row here
         +-------------------------------------------------*

         	WriteToLog('Consolidate_components:lTotalQty: ' || to_char(lTotalQty), 5);
         	WriteToLog('Consolidate_components:ComponentSeqID: ' || to_char(lSaveCompSeqId), 5);

         lStmtNum := 140;
         update bom_inventory_comps_interface
         set    component_quantity = Round( lTotalQty  , 7 ) * Decimal-Qty Support for Option Items *
         where  component_sequence_id = lSaveCompSeqId;

	 if lSaveOptional = 1 then
		update  bom_inventory_comps_interface
                set     optional_on_model = lSaveOptional
                where   component_sequence_id = lSaveCompSeqId;
	 end if;
     close consolidate_components;






*
*
*
*
*
*
*
*
*/


    /* begin 02-14-2005  Sushant */

     -- Start new code 3222932

     -- Execute following code for each clubbed components
     for club_comp_rec in club_comp
     loop

        -- Get all eff and disable dates in asc order
        -- 4244576
        WriteToLog( ' Looping for item id : ' ||club_comp_rec.item_id ||' operation_seq : '||club_comp_rec.operation_seq_num,1);

        select  distinct effectivity_date
        BULK COLLECT INTO asc_date_arr
        from    bom_inventory_comps_interface
        where   bill_sequence_id = lConfigBillId
        and     component_item_id = club_comp_rec.item_id
        and     operation_seq_num = club_comp_rec.operation_seq_num --4244576
        UNION
        select  distinct disable_date
        from    bom_inventory_comps_interface
        where   bill_sequence_id = lConfigBillId
        and     component_item_id = club_comp_rec.item_id
        and     operation_seq_num = club_comp_rec.operation_seq_num --4244576
        order by 1;

        -- Printing dates

        if asc_date_arr.count > 0 then
          for x1 in asc_date_arr.FIRST..asc_date_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog('Date ('||x1||') = '||to_char(asc_date_arr(x1),'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;

        -- Creating clubbing windows


        if asc_date_arr.count > 0 then
          for x2 in 1..(asc_date_arr.count-1)
            loop
                club_tab_arr(x2).eff_dt         :=      asc_date_arr(x2);
                club_tab_arr(x2).dis_dt         :=      asc_date_arr(x2+1);
            end loop;
        end if;

        -- Printing dates of clubbing window

        if club_tab_arr.count > 0 then
          for x3 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog('ED ('||x3||') = ' ||to_char(club_tab_arr(x3).eff_dt,'DD-MON-YY HH24:MI:SS')||
                         ' ---- DD ('||x3||') = '|| to_char(club_tab_arr(x3).dis_dt,'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;

        -- Modifying eff dates of clubbing windows

        /*Commenting this as part of bugfix 11059122 (FP:9978623)
          Initially the disable_date was non-inclusive in BOM code. This implies that on the exact time of the
          disable_date, the component was not available to any manufacturing function. BOM team caused a regression
          via bug 2726385 and made the disable_date inclusive. Now, consider the following scenario:
          Item    Op Seq  Effectivity_date      Disable_date
          ====    ======  ================      ============
          I1      1       14-DEC-2010 12:00:00  30-DEC-2010 00:00:00
          I1      1       30-DEC-2010 00:00:00  <NULL>

          If the disable_date is inclusive, it means at 30-DEC-2010 00:00:00 both instances of I1 are active, which
          is incorrect. We believe that to get around this situation, CTO added one second to the effectivity_date
          in such scenarios. This change was made via bug 3059499.

          BOM team fixed the regression via bug 3128252 and made the disable_date non-inclusive again. So there is
          no need to add a one second differential by CTO.

        if club_tab_arr.count > 0 then
          for x21 in 2..(club_tab_arr.count)
            loop
                if ( club_tab_arr(x21 - 1).dis_dt =  club_tab_arr(x21).eff_dt ) then
                  club_tab_arr(x21).eff_dt      :=      club_tab_arr(x21).eff_dt + 1/86400;
                end if;
            end loop;
        end if;
        */

        -- Printing dates of clubbing window

        if club_tab_arr.count > 0 then
          for x22 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog('ED ('||x22||') = ' ||to_char(club_tab_arr(x22).eff_dt,'DD-MON-YY HH24:MI:SS')||
                   ' ---- DD ('||x22||') = '|| to_char(club_tab_arr(x22).dis_dt,'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;


        -- for debug
        for d1 in c1_debug (club_comp_rec.item_id, club_comp_rec.operation_seq_num) loop --4244576

                dbg_eff_date := d1.eff_date;
                dbg_dis_date := d1.dis_date;
                dbg_qty      := d1.cmp_qty;

          IF PG_DEBUG <> 0 THEN
            WriteToLog( 'ED '||to_char(dbg_eff_date,'DD-MON-YY HH24:MI:SS')||' DD '||to_char(dbg_dis_date,'DD-MON-YY HH24:MI:SS')||' Qty '||dbg_qty);
          END IF;

        end loop;

        -- Clubbing quantities

        if club_tab_arr.count > 0 then
          for x4 in club_tab_arr.FIRST.. club_tab_arr.LAST
            loop



            IF PG_DEBUG <> 0 THEN
                WriteToLog ('checking for club comp error ', 1 ) ;
             END IF;



        /* begin LBM project */
        /* Check whether multiple occurences of the same component with the same inventory_item_id
           and operation_sequence have conflicting basis_type.
        */
        select  b1.model_comp_seq_id,  b1.component_item_id
        BULK COLLECT INTO
        basis_model_comp_seq_id_arr,  basis_component_item_id_arr
        from
        bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where  b1.bill_sequence_id = b2.bill_sequence_id
        and    b1.component_sequence_id <> b2.component_sequence_id
        and    b1.operation_seq_num = b2.operation_seq_num
        and    b1.component_item_id = b2.component_item_id
        and    b1.bill_sequence_id = lConfigBillId
        and    b1.basis_type <> b2.basis_type
        and    b1.effectivity_date <= club_tab_arr(x4).eff_dt
        and    nvl(b1.disable_date,g_SchShpDate) >= club_tab_arr(x4).dis_dt
        and    b1.bill_sequence_id = lConfigBillId
        and    b1.component_item_id = club_comp_rec.item_id
        and    b1.operation_seq_num = club_comp_rec.operation_seq_num
        and    b2.effectivity_date <= club_tab_arr(x4).eff_dt
        and    nvl(b2.disable_date,g_SchShpDate) >= club_tab_arr(x4).dis_dt;


        if( basis_model_comp_seq_id_arr.count > 0 ) then


            for i in 1..basis_model_comp_seq_id_arr.count
            loop
               if ( i = 1 ) then

                   v_diff_basis_string := 'component ' || basis_component_item_id_arr(i) ;

               else

                   v_sub_diff_basis_string := 'component ' || basis_component_item_id_arr(i) || l_new_line ;

                   v_diff_basis_string := v_diff_basis_string || v_sub_diff_basis_string ;

               end if ;
            end loop;


          IF PG_DEBUG <> 0 THEN
            WriteToLog( 'Going to Raise CTO_CLUB_COMP_ERROR');
            WriteToLog( 'will not populated message CTO_CLUB_COMP_ERROR');
          END IF;
               select segment1 into
               l_model_name
               from mtl_system_items
               where inventory_item_id = pmodelid
               and   organization_id   = porgid;


               select segment1 into
               l_comp_name
               from mtl_system_items
               where inventory_item_id = club_comp_rec.item_id
               and   organization_id   = porgid;

               select organization_name
               into   l_org_name
               from   inv_organization_name_v
               where  organization_id = porgid;

               l_token(1).token_name    := 'MODEL';
               l_token(1).token_value   := l_model_name;
               l_token(2).token_name    := 'ORGANIZATION';
               l_token(2).token_value    := l_org_name;
               l_token(3).token_name   := 'COMPONENT';
               l_token(3).token_value   := l_comp_name;
    	       cto_msg_pub.cto_message('BOM','CTO_CLUB_COMP_ERROR',l_token);



               raise fnd_api.g_exc_error;


        end if;

        /* end LBM project */



             IF PG_DEBUG <> 0 THEN
                WriteToLog ('Going for Group Function ', 1 ) ;
             END IF;






                select max(rowid), sum(decode(basis_type, 1, component_quantity, 0))
                                 + max(decode(basis_type, 2, component_quantity, 0))  /* LBM Project */
                into   club_tab_arr(x4).row_id,club_tab_arr(x4).qty
                from   bom_inventory_comps_interface
                where  effectivity_date <= club_tab_arr(x4).eff_dt
                and    nvl(disable_date,g_SchShpDate) >= club_tab_arr(x4).dis_dt
                and    bill_sequence_id = lConfigBillId
                and    component_item_id = club_comp_rec.item_id
                and    operation_seq_num = club_comp_rec.operation_seq_num; --4244576

            end loop;
        end if;

         -- Printing Clubbed quantity with window

        if club_tab_arr.count > 0 then
          for x5 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog('ED (' ||x5|| ') = ' ||to_char(club_tab_arr(x5).eff_dt,'DD-MON-YY HH24:MI:SS')||
                                  ' -- DD (' ||x5|| ') = ' ||to_char(club_tab_arr(x5).dis_dt,'DD-MON-YY HH24:MI:SS')||                                  ' -- Qty (' ||x5|| ') = ' ||club_tab_arr(x5).qty,1);
             END IF;
            end loop;
        end if;

        -- Now insert into bom_inventory_comps_interface

        if club_tab_arr.count > 0 then

          for x6 in club_tab_arr.FIRST.. club_tab_arr.LAST
           loop
            If nvl(club_tab_arr(x6).qty,0) <> 0 Then
            insert into bom_inventory_comps_interface
              (
                component_item_id,
                bill_sequence_id,
                effectivity_date,
                disable_date,
                component_quantity,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                operation_seq_num,
                last_update_login,
                item_num,
                component_yield_factor,
                component_remarks,
                change_notice,
                implementation_date,
                attribute_category,
                attribute1,
                attribute2,
                 attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                include_on_bill_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                component_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                pick_components,
                model_comp_seq_id,
                supply_subinventory,
                supply_locator_id,
                bom_item_type,
                optional_on_model,
                parent_bill_seq_id,
                plan_level,
                revised_item_sequence_id
                , basis_type,   /* LBM change */
                batch_id
                 )
              select
                club_comp_rec.item_id,
                lConfigBillId,
                club_tab_arr(x6).eff_dt,
                club_tab_arr(x6).dis_dt,
                round(club_tab_arr(x6).qty,7),          -- to maintain decimal qty support of option items
                SYSDATE,
                lConfigBillId,                          -- CREATED_BY is set to lConfigBillId to identify rows from clubbing
                SYSDATE,
                1,
                operation_seq_num,
                last_update_login,
                item_num,
                component_yield_factor,
                component_remarks,
                change_notice,
                implementation_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
                so_basis,optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                include_on_bill_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                bom_inventory_components_s.nextval,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                pick_components,
                model_comp_seq_id,
                supply_subinventory,
                supply_locator_id,
                bom_item_type,
                optional_on_model,
                parent_bill_seq_id,
                plan_level,
                revised_item_sequence_id
                , nvl(basis_type,1),                  /* LBM project */
                cto_msutil_pub.bom_batch_id
              from      bom_inventory_comps_interface
              where     component_item_id = club_comp_rec.item_id
              and       operation_seq_num = club_comp_rec.operation_seq_num --4244576
              and       bill_sequence_id = lConfigBillId
              and       rowid   = club_tab_arr(x6).row_id;
              End if;
           end loop;
         end if;

         -- Delete original option item rows from bici
         delete from     bom_inventory_comps_interface
         where           component_item_id = club_comp_rec.item_id
         and             operation_seq_num = club_comp_rec.operation_seq_num --4244576
         and             bill_sequence_id = lConfigBillId
         and             created_by <> lConfigBillId;

         -- Delete rows from bom_inventory_comps_interface where qty = 0
         delete from     bom_inventory_comps_interface
         where           component_item_id = club_comp_rec.item_id
         and             operation_seq_num = club_comp_rec.operation_seq_num --4244576
         and             bill_sequence_id = lConfigBillId
         and             created_by = lConfigBillId
         and             component_quantity = 0;

         -- Delete club_tab_arr and  asc_date_arr to process next item in club_comp_cur
         if club_tab_arr.count > 0 then
          for x7 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
                club_tab_arr.DELETE(x7);
            end loop;
         end if;

         if asc_date_arr.count > 0 then
          for x8 in asc_date_arr.FIRST..asc_date_arr.LAST
            loop
                asc_date_arr.DELETE(x8);
            end loop;
         end if;

      end loop;       -- End loop of club_comp_cur

-- end new code 3222932





   /* end 02-14-2005 Sushant */





  /*----------------------------------------------+
    Update item sequence id.
    To address configuration BOM restructure enhancements,
    item sequence is being updated such that there are no
    duplicate sequences, and in the logical order of components
    selection from the parent model BOM.
    The Item Sequence Increment is based on the profile
    "BOM:Item Sequence Increment".
  +----------------------------------------------*/

  --
  -- Get item sequence increment
  --
  p_seq_increment := fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT');
  	WriteToLog('Item Seq Increment::'||to_char(p_seq_increment), 5);

  --
  -- update item_num of top model
  --
  p_item_num := p_item_num + p_seq_increment;

  	WriteToLog('p_item_num::'||to_char(p_item_num), 5);

  update bom_inventory_comps_interface
  set item_num = p_item_num
  where bill_sequence_id = lConfigbillid and parent_bill_seq_id = 0; /* 04-04-2005 bugfix 3374548 */



  	WriteToLog('Updated model row::'||sql%rowcount, 5);

  p_item_num := p_item_num + p_seq_increment;

  	WriteToLog('Going to get top model for billseq ::'|| to_char(lConfigBillId) , 5);  /* Introduced by sushant */
  --
  -- get bill_sequence_id of top model
  --
  select common_bill_sequence_id
  into p_bill_seq_id
  from bom_bill_of_materials
  where assembly_item_id =
	(select component_item_id
	from bom_inventory_comps_interface
	where bill_sequence_id = lConfigBillId and parent_bill_seq_id = 0)  /* Introduced by sushant */
  and organization_id = pOrgId
  and alternate_bom_designator is null;

  --
  -- call update_item_num procedure with top model
  -- this will update item_num for the rest of the items
  --
  	WriteToLog('Calling update_item_num will p_bill_seq_id::'||to_char(p_bill_seq_id)||' and p_item_num::'||to_char(p_item_num), 5);

  update_item_num(
	p_bill_seq_id,
	p_item_num,
	pOrgId,
	p_seq_increment);


  /*-------------------------------------------+
    Load BOM_bill_of_materials
  +-------------------------------------------*/
  	WriteToLog('Before first insert into bill_of_materials.' ,3);
  	WriteToLog('Org: ' ||to_char(pOrgId), 4);
  	WriteToLog('Model: ' || to_char(pModelId), 4);
  	WriteToLog('Config: ' || to_char(pConfigId), 4);



  /* begin changes for bug 4271269 */

  if g_structure_type_id is null then

     begin

      select structure_type_id into g_structure_type_id from bom_alternate_designators
      where alternate_designator_code is null ;

     exception
     when others then
         IF PG_DEBUG <> 0 THEN
            WriteToLog('create_bom_data_ml: ' || 'others error while retrieving structure_type_id .' ,2);
            WriteToLog('create_bom_data_ml: ' || 'defaulting structure_type_id to 1 .' ,2);
            g_structure_type_id := 1;

         END IF;

     end ;


     IF PG_DEBUG <> 0 THEN
        WriteToLog('create_bom_data_ml: ' || 'structure_type_id is ' || g_structure_type_id  ,2);
     END IF;


  end if ;

  /* end changes for bug 4271269 */


 -- As per BOM team, they have added two new fileds
  -- PK1_value and PK2_VAlue in 11.5.10 and R12
  -- These fields are added for some PLM projects
  -- PK1_VALUE should be assembly_item_id
  -- PK2_VALUE should be organization id
  -- So far these two columns are populated thru database trigger
  -- bom is planning on droping this trigger in R12, hence we need

  lStmtNum := 145;
  xTableName := 'BOM_BILL_OF_MATERIALS';
  insert into BOM_BILL_OF_MATERIALS(
      assembly_item_id,
      organization_id,
      alternate_bom_designator,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      specific_assembly_comment,
      pending_from_ecn,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      assembly_type,
      bill_sequence_id,
      common_bill_sequence_id,
      source_bill_sequence_id,  /* COMMON BOM Project 12.0 */
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      implementation_date,               -- bug fix 3759118,FP 3810243
      structure_type_id,                -- bugfix 4271269
      effectivity_control,               -- bugfix 4271269
      pk1_value,
      pk2_value
      )
  select
      pConfigId,              		-- assembly_item_id
      pOrgId,                 		-- organization_id
      NULL,                   		-- alternate_bom_designator
      /* Begin Bugfix 8775615: Populate user id and login id.
      sysdate,                		-- last_update_date
      1,                      		-- last_update_by
      sysdate,                		-- creation date
      1,                      		-- created by
      1,                      		-- last_update_login
      */
      sysdate,                		-- last_update_date
      gUserId,                      	-- last_update_by
      sysdate,                		-- creation date
      gUserId,                      	-- created by
      gLoginId,                      	-- last_update_login
      -- End Bugfix 8775615
      b.specific_assembly_comment,	-- specific assembly comment
      NULL,                   		-- pending from ecn
      b.attribute_category,             -- attribute category
      b.attribute1,                   	-- attribute1
      b.attribute2,                   	-- attribute2
      b.attribute3,                   	-- attribute3
      b.attribute4,                   	-- attribute4
      b.attribute5,                   	-- attribute5
      b.attribute6,                   	-- attribute6
      b.attribute7,                   	-- attribute7
      b.attribute8,                   	-- attribute8
      b.attribute9,                   	-- attribute9
      b.attribute10,                   	-- attribute10
      b.attribute11,                   	-- attribute11
      b.attribute12,                  	-- attribute12
      b.attribute13,                   	-- attribute13
      b.attribute14,                 	-- attribute14
      b.attribute15,                   	-- attribute15
      b.assembly_type,        		-- assembly_type
      lConfigBillId,
      lConfigBillId,
      lConfigBillId,                    -- source_bill_sequence_id  COMMON BOM Project 12.0
      NULL,                   		-- request id
      NULL,                   		-- program_application_id
      NULL,                   		-- program id
      NULL,                    		-- program date
      SYSDATE,                           --  implementation date bug fix 3759118,FP 3810243
      g_structure_type_id,               -- bugfix 4271269   structure_type_id
      1,                                  -- bugfix 4271269   effectivity_control
      pconfigid,
      porgid
  from    bom_bill_of_materials b
  where   b.assembly_item_id = pModelId
  and     b.organization_id  = pOrgId
  and     b.alternate_bom_designator is NULL;

  	WriteToLog('Inserted rows into bom_bill_of_materials::'||sql%rowcount, 2 );

  /*-----------------------------------------------+
    Load Bom_inventory_components
  +----------------------------------------------*/
  	WriteToLog('Before second insert into bom_inventory_components. ', 3);
  lStmtNum := 310;
  xTableName := 'BOM_INVENTORY_COMPONENTS';
  insert into BOM_INVENTORY_COMPONENTS
      (
        operation_seq_num,
        component_item_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        item_num,
        component_quantity,
        component_yield_factor,
        component_remarks,
        effectivity_date,
        change_notice,
        implementation_date,
        disable_date,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        planning_factor,
        quantity_related,
        so_basis,
        optional,
        mutually_exclusive_options,
        include_in_cost_rollup,
        check_atp,
        shipping_allowed,
        required_to_ship,
        required_for_revenue,
        include_on_ship_docs,
        include_on_bill_docs,
        low_quantity,
        high_quantity,
        acd_type,
        old_component_sequence_id,
        component_sequence_id,
        common_component_sequence_id,             /* COMMON BOM Project 12.0 */
        bill_sequence_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        wip_supply_type,
        operation_lead_time_percent,
        revised_item_sequence_id,
        supply_locator_id,
        supply_subinventory,
        pick_components,
	bom_item_type,
	optional_on_model,	--isp bom
	parent_bill_seq_id,	--isp bom
	plan_level,		--isp bom
	model_comp_seq_id	--isp bom
        , basis_type            /* LBM change */
        )
   select
        b.operation_seq_num,
        b.component_item_id,
        /* Begin Bugfix 8775615: Populate user id and login id.
	b.last_update_date,
        1,	-- last_updated_by
        b.creation_date,
        1,      -- created_by
        b.last_update_login,
	*/
	b.last_update_date,	-- last_update_date
        gUserId,		-- last_updated_by
        b.creation_date,	-- creation_date
        gUserId,		-- created_by
        gLoginId,		-- last_update_login
	-- End Bugfix 8775615
        b.item_num,
        b.component_quantity,
        b.component_yield_factor,
        b.component_remarks,
        b.effectivity_date,
        b.change_notice,
        b.implementation_date,
        -- b.disable_date,
        -- 3222932 Chg g_futuredate back to NULL
        decode(b.disable_date,g_futuredate,to_date(NULL), b.disable_date), /* 02-14-2005 Sushant */
        b.attribute_category,
        b.attribute1,
        b.attribute2,
        b.attribute3,
        b.attribute4,
        b.attribute5,
        b.attribute6,
        b.attribute7,
        b.attribute8,
        b.attribute9,
        b.attribute10,
        b.attribute11,
        b.attribute12,
        b.attribute13,
        b.attribute14,
        b.attribute15,
        b.planning_factor,
        b.quantity_related,
        b.so_basis,
        b.optional,
        b.mutually_exclusive_options,
        b.include_in_cost_rollup,
        decode( msi.bom_item_type , 1 , decode( msi.atp_flag , 'Y' , 1 , b.check_atp ) , b.check_atp ) ,  /* ATP changes for Model component */
        b.shipping_allowed,
        b.required_to_ship,
        b.required_for_revenue,
        b.include_on_ship_docs,
        b.include_on_bill_docs,
        b.low_quantity,
        b.high_quantity,
        b.acd_type,
        b.old_component_sequence_id,
        b.component_sequence_id,
        b.component_sequence_id,        -- common_component_sequence_id COMMON BOM Project 12.0
        b.bill_sequence_id,
        NULL,        /* request_id */
        NULL,     /* program_application_id */
        NULL,        /* program_id */
        sysdate,         /* program_update_date */
        b.wip_supply_type,
        b.operation_lead_time_percent,
        NULL,	-- 2524562
        b.supply_locator_id,
        b.supply_subinventory,
        b.pick_components,
	b.bom_item_type,
	b.optional_on_model,	--isp bom
	b.parent_bill_seq_id,	--isp bom
	b.plan_level,		--isp bom
	b.model_comp_seq_id	--isp bom
       , decode(b.basis_type,1,null,b.basis_type)           /* LBM change */
    from   bom_inventory_comps_interface b,
	mtl_system_items msi
    where  b.bill_sequence_id = lConfigBillId
    and  b.component_item_id = msi.inventory_item_id
    and  msi.organization_id = pOrgId;

WriteToLog('Inserted rows into bom_inv_comps::'||sql%rowcount, 2 );

















        /*-----------------------------------------------+
              Populate Substitutes for Mandatory components
        +----------------------------------------------*/
        IF PG_DEBUG <> 0 THEN
            WriteToLog('create_bom_data_ml: ' || 'Before second insert into bom_inventory_components. ', 2);
        END IF;
        lStmtNum := 315;
        xTableName := 'BOM_SUBSTITUTE_COMPONENTS';




          insert into bom_substitute_components (
                   substitute_component_id
                  ,substitute_item_quantity
                  ,component_sequence_id
                  ,acd_type
                  ,change_notice
                  ,attribute_category
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,original_system_reference
                  ,enforce_int_requirements
                  ,request_id
                  ,program_application_id
                  ,program_id
                  ,program_update_date
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
               )
               select
                   s.substitute_component_id            -- substitute_component_id
                  ,s.substitute_item_quantity
                  ,b.component_sequence_id
                  ,s.acd_type
                  ,s.change_notice
                  ,s.attribute_category
                  ,s.attribute1
                  ,s.attribute2
                  ,s.attribute3
                  ,s.attribute4
                  ,s.attribute5
                  ,s.attribute6
                  ,s.attribute7
                  ,s.attribute8
                  ,s.attribute9
                  ,s.attribute10
                  ,s.attribute11
                  ,s.attribute12
                  ,s.attribute13
                  ,s.attribute14
                  ,s.attribute15
                  ,s.original_system_reference
                  ,s.enforce_int_requirements
                  ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                  ,FND_GLOBAL.PROG_APPL_ID /* PROGRAM_APPLICATION_ID */
                  ,FND_GLOBAL.CONC_PROGRAM_ID /* PROGRAM_ID */
                  ,sysdate /* PROGRAM_UPDATE_DATE */
                  ,sysdate /* LAST_UPDATE_DATE */
                  ,gUserId /* LAST_UPDATED_BY  */
                  ,sysdate /* CREATION_DATE */
                  ,gUserId /* CREATED_BY  */
                  ,gLoginId /* LAST_UPDATE_LOGIN */
                  /*
                  ,request_id
                  ,program_application_id
                  ,program_id
                  ,program_update_date
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  */
    from   bom_inventory_comps_interface b , bom_inventory_components bic, bom_substitute_components s
    where  b.bill_sequence_id = lConfigBillId
      and  ABS(b.model_comp_seq_id) = bic.component_sequence_id
      and  bic.optional = 2                                      /* only mandatory components */
      and  bic.component_sequence_id = s.component_sequence_id ;






    IF PG_DEBUG <> 0 THEN
        WriteToLog('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount, 1);
    END IF;















   /* -------------------------------------------------------------------------+
         Insert into BOM_REFERENCE_DESIGNATORS table
   +--------------------------------------------------------------------------*/
   IF PG_DEBUG <> 0 THEN
        WriteToLog('create_bom_data_ml: ' || 'Before third insert into bom_reference_designators. ', 2);
   END IF;
   lStmtNum := 320;
   xTableName := 'BOM_REFERENCE_DESIGNATORS';
   insert into BOM_REFERENCE_DESIGNATORS
       (
       component_reference_designator,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       ref_designator_comment,
       change_notice,
       component_sequence_id,
       acd_type,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
       )
    select
       r.component_reference_designator,
       /* Begin Bugfix 8775615: Populate user id and login id.
       SYSDATE,
       1,
       SYSDATE,
       1,
       1,
       */
       SYSDATE,		-- last_update_date
       gUserId,		-- last_updated_by
       SYSDATE,		-- creation_date
       gUserId,		-- created_by
       gLoginId,	-- last_update_login
       -- End Bugfix 8775615
       r.REF_DESIGNATOR_COMMENT,
       NULL,
       ic.COMPONENT_SEQUENCE_ID,
       r.ACD_TYPE,
       NULL,
       NULL,
       NULL,
       NULL,
       r.ATTRIBUTE_CATEGORY,
       r.ATTRIBUTE1,
       r.ATTRIBUTE2,
       r.ATTRIBUTE3,
       r.ATTRIBUTE4,
       r.ATTRIBUTE5,
       r.ATTRIBUTE6,
       r.ATTRIBUTE7,
       r.ATTRIBUTE8,
       r.ATTRIBUTE9,
       r.ATTRIBUTE10,
       r.ATTRIBUTE11,
       r.ATTRIBUTE12,
       r.ATTRIBUTE13,
       r.ATTRIBUTE14,
       r.ATTRIBUTE15
    from
       bom_inventory_components ic,
       bom_reference_designators r,
       bom_bill_of_materials b
    where   b.assembly_item_id = pConfigId
       and     b.organization_id  = pOrgId
       and     ic.bill_sequence_id = b.bill_sequence_id
       and     r.component_sequence_id = abs(ic.model_comp_seq_id)      -- previously last_update_login
       and     nvl(r.acd_type,0) <> 3;

    IF PG_DEBUG <> 0 THEN
        WriteToLog('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
    END IF;


    -- start 3674833
    -- need to insert reference designators of remaining components


    if model_comp_seq_id_arr.count > 0 then
                  prev_comp_item_id := 0;
          for x1 in model_comp_seq_id_arr.FIRST..model_comp_seq_id_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                WriteToLog( ' Model_Comp_seq (' ||x1|| ') = ' ||model_comp_seq_id_arr(x1)
                                                ||' Component_item_id (' ||x1|| ') = ' ||component_item_id_arr(x1),1);
             END IF;



                 /*  04-09-2005

                     bugfix 3985173: Commented following code since there could be instances when same component with
                                    same op seq number is appearing multiple times for a config bom. In that scenario,
                                    following query will return ORA-01422 error

                       if prev_comp_item_id <> component_item_id_arr(x1) then

                         -- Determine the component_sequence_id into which this item has been clubbed
                         select
                                bic.component_sequence_id into club_component_sequence_id
                         from
                                bom_inventory_components bic,
                                bom_bill_of_materials bom
                         where  bom.assembly_item_id = pConfigId
                         and    bom.organization_id  = pOrgId
                         and    bic.bill_sequence_id = bom.bill_sequence_id
                         and    bic.component_item_id = component_item_id_arr(x1);
                         prev_comp_item_id := component_item_id_arr(x1);
                      end if;
                 */




                -- bugfix 3985173 : New code will loop through component seq and insert
                -- into bom_reference_designator
                for a1 in club_comp_seq ( component_item_id_arr(x1), operation_seq_num_arr(x1) ) loop  --4244576

                 club_component_sequence_id := a1.comp_seq_id;


                 -- insert into BOM_REFERENCE_DESIGNATORS for the corresponding model_comp_seq_id
                 -- if it has not already been inserted.
                 IF PG_DEBUG <> 0 THEN
                        WriteToLog('club_component_sequence_id is '||club_component_sequence_id, 1);
                 END if;
                 IF PG_DEBUG <> 0 THEN
                        WriteToLog('Trying to insert into BOM_REFERENCE_DESIGNATORS', 1);
                END if;
                begin
                 insert into BOM_REFERENCE_DESIGNATORS
                                 (
                                  component_reference_designator,
                                  last_update_date,
                                  last_updated_by,
                                  creation_date,
                                  created_by,
                                  last_update_login,
                                  ref_designator_comment,
                                  change_notice,
                                  component_sequence_id,
                                  acd_type,
                                  request_id,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15
                                 )
                                 select
                                  r.component_reference_designator,
                                  /* Begin Bugfix 8775615: Populate user id and login id.
				  SYSDATE,
                                  1,
                                  SYSDATE,
                                  1,
                                  1,
				  */
				  SYSDATE,		-- last_update_date
				  gUserId,		-- last_updated_by
				  SYSDATE,		-- creation_date
				  gUserId,		-- created_by
				  gLoginId,		-- last_update_login
				  -- End Bugfix 8775615
                                  r.REF_DESIGNATOR_COMMENT,
                                  NULL,
                                  club_component_sequence_id,
                                  r.ACD_TYPE,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  r.ATTRIBUTE_CATEGORY,
                                  r.ATTRIBUTE1,
                                  r.ATTRIBUTE2,
                                  r.ATTRIBUTE3,
                                  r.ATTRIBUTE4,
                                  r.ATTRIBUTE5,
                                  r.ATTRIBUTE6,
                                  r.ATTRIBUTE7,
                                  r.ATTRIBUTE8,
                                  r.ATTRIBUTE9,
                                  r.ATTRIBUTE10,
                                  r.ATTRIBUTE11,
                                  r.ATTRIBUTE12,
                                  r.ATTRIBUTE13,
                                  r.ATTRIBUTE14,
                                  r.ATTRIBUTE15
                                 from
                                                 bom_reference_designators r
                                 where   r.component_sequence_id = abs(model_comp_seq_id_arr(x1))
                                 and     nvl(r.acd_type,0) <> 3;

				 --moved here for 4492875
				 IF PG_DEBUG <> 0 THEN
                                  WriteToLog('For this record '||sql%rowcount||' records are inserted in bom_reference_designators', 1);
                                 END if;
                        exception
                                when others then
                                IF PG_DEBUG <> 0 THEN
                                        WriteToLog('The record for this designator and component sequence already exists in BOM_REFERENCE_DESIGNATORS', 1);
                                END IF;
                        end;

                 end loop;   -- 3985173 : end of club_comp_seq cursor loop

                 prev_comp_item_id := component_item_id_arr(x1); -- 3985173

            end loop ;

        end if;


    -- end 3674833


     xRtgId := lCfgRtgId;

   /*-----------------------------------------------------------+
       Update MTL_DESCR_ELEMENT_VALUES  table
   +------------------------------------------------------------*/

    xTableName := 'MTL_DESCR_ELEMENT_VALUES';
    lStmtNum   := 330;


    if CTO_CUSTOM_CATALOG_DESC.catalog_desc_method  = 'C'  then
	-- Call Custom API with details..

     	WriteToLog ('Prepare data for calling custom hook...', 5);

    	DECLARE
    		cursor ctg is
		select ELEMENT_NAME
		from   mtl_descr_element_values
		where  inventory_item_id = pConfigId;

 		l_catalog_dtls 	CTO_CUSTOM_CATALOG_DESC.CATALOG_DTLS_TBL_TYPE;
		l_params	CTO_CUSTOM_CATALOG_DESC.INPARAMS;
		i 		NUMBER;
		original_count 	NUMBER;
		l_return_status VARCHAR2(1);

    	BEGIN
        	i := 1;
		l_return_status := FND_API.G_RET_STS_SUCCESS;

		for rec in ctg
		loop
	    		l_catalog_dtls(i).cat_element_name  := rec.element_name;
	    		l_catalog_dtls(i).cat_element_value := NULL;
			WriteToLog ('l_catalog_dtls('||i||').cat_element_name = '||
									rec.element_name, 5);
	    		i := i+1;
		end loop;

		original_count := l_catalog_dtls.count;

             -- bugfix 4081613: Do not execute the rest of the code if cursor ctg did not fetch any rows.
             if original_count > 0 then
		l_params.p_item_id := pConfigId;
		l_params.p_org_id  := pOrgId;

     		WriteToLog ('Parameter passed: l_params.p_item_id = '||l_params.p_item_id ||
     	                             	     '; l_params.p_org_id = '||l_params.p_org_id , 5);

		CTO_CUSTOM_CATALOG_DESC.user_catalog_desc (
					p_params => l_params,
					p_catalog_dtls => l_catalog_dtls,
					x_return_status => l_return_status);

        	if( l_return_status = FND_API.G_RET_STS_ERROR ) then
			WriteToLog ('CTO_CUSTOM_CATALOG_DESC.user_catalog_desc returned exp error', 1);
            		RAISE FND_API.G_EXC_ERROR ;

        	elsif( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
			WriteToLog ('CTO_CUSTOM_CATALOG_DESC.user_catalog_desc returned unexp error', 1);
            		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        	end if ;

		if l_catalog_dtls.count <> original_count then
			WriteToLog ('ERROR: Custom hook did not return same number of elements.'||
				 'Original_count='||original_count||
				 'New count = '||l_catalog_dtls.count, 1);
			raise FND_API.G_EXC_ERROR;
		end if;

		for k in l_catalog_dtls.first..l_catalog_dtls.last
		loop
	   	   if l_catalog_dtls(k).cat_element_value is not null then
			WriteToLog ('l_catalog_dtls('||k||').cat_element_name = '||
						l_catalog_dtls(k).cat_element_name||
		                  '; l_catalog_dtls('||k||').cat_element_value = '||
						l_catalog_dtls(k).cat_element_value, 5);
    		       lStmtNum   := 331;

    		       update MTL_DESCR_ELEMENT_VALUES  i
    		       set    i.element_value = l_catalog_dtls(k).cat_element_value
   		       where  i.inventory_item_id = pConfigId
		       and    i.element_name = l_catalog_dtls(k).cat_element_name;

   		       	WriteToLog('Updated rows in mtl_desc_element_values::'|| sql%rowcount, 2);
	   	   end if;
		end loop;

            end if; --bugfix 4081613
    	END;

    elsif CTO_CUSTOM_CATALOG_DESC.catalog_desc_method  = 'Y'  then
    	lStmtNum   := 332;
    	WriteToLog ('Std feature : Rollup lower level model catalog desc to top level', 4);
    	update MTL_DESCR_ELEMENT_VALUES  i
    	set    i.element_value =
       			( select /*+ ORDERED */
	     			NVL(max(v.element_value),i.element_value)
         		  from
            			bom_bill_of_materials         bi,
            			bom_inventory_components      bc1,
            			bom_inventory_components      bc2,
            			bom_dependent_desc_elements   be,
            			mtl_descr_element_values      v
         		  where    bi.assembly_item_id       = pConfigId
                          and   bi.organization_id        = pOrgId
                          and   bi.alternate_bom_Designator is null
                          and   bc1.bill_sequence_id      = bi.bill_sequence_id
                          and   bc2.component_sequence_id = abs(bc1.model_comp_seq_id)	-- previously last_update_login
                          and   be.bill_sequence_id       = bc2.bill_sequence_id
                          and   be.element_name           = i.element_name
                          and   v.inventory_item_id       = bc1.component_item_id
                          and   v.element_name            = i.element_name
   	                )
   	where i.inventory_item_id = pConfigId;

	WriteToLog('Updated rows in mtl_desc_element_values::'|| sql%rowcount, 2);
    else

    	lStmtNum   := 333;
  	WriteToLog ('Std feature : DO NOT Rollup lower level model catalog desc to top level', 4);

    	update MTL_DESCR_ELEMENT_VALUES  i
    	set    i.element_value =
       			( select /*+ ORDERED */
	     			NVL(max(v.element_value),i.element_value)
         		  from
            			bom_bill_of_materials         bi,
            			bom_inventory_components      bc1,
            			bom_inventory_components      bc2,
            			bom_dependent_desc_elements   be,
            			mtl_descr_element_values      v
         		  where    bi.assembly_item_id       = pConfigId
                          and   bi.organization_id        = pOrgId
                          and   bi.alternate_bom_Designator is null
                          and   bc1.bill_sequence_id      = bi.bill_sequence_id
                          and   bc2.component_sequence_id = abs(bc1.model_comp_seq_id)	-- previously last_update_login
                          and   be.bill_sequence_id       = bc2.bill_sequence_id
                          and   be.element_name           = i.element_name
                          and   v.inventory_item_id       = bc1.component_item_id
                          and   v.element_name            = i.element_name
                          -- bugfix 2590966
                          -- Following code eliminates lower level configurations
			  -- Fp bug fix 4761813. Modified the sub query sql to
			  -- user exists clause instead of using not in for performance
			  -- reason
			   and not exists
                          (
                          SELECT 'x' FROM MTL_SYSTEM_ITEMS
                          WHERE ORGANIZATION_ID = pOrgId
                          AND BC1.COMPONENT_ITEM_ID = INVENTORY_ITEM_ID
                          AND BASE_ITEM_ID IS NOT NULL
                          AND BOM_ITEM_TYPE = 4
                          AND REPLENISH_TO_ORDER_FLAG = 'Y'
                          )
   	                   -- end bugfix 2590966
   	                )
   	where i.inventory_item_id = pConfigId;
	WriteToLog('Updated rows in mtl_desc_element_values::'|| sql%rowcount, 2);
    end if;


   /*---------------------------------------------------------------------+
         Update descriptions of the config items in
         the MTL_SYSTEM_ITEMS
   +----------------------------------------------------------------------*/

   lStmtNum   := 350;
   xTableName := 'MTL_SYSTEM_ITMES';
   l_status := bmlupid_update_item_desc(pConfigid,
                                      pOrgId,
                                      xErrorMessage);

   if l_status <> 0 then
	WriteToLog('ERROR:bmlupid_update_item_desc returned error::' || l_status, 1);
      raise FND_API.G_EXC_ERROR;
   end if;
/*------------------------------------------------------------+
Copy BOM attachments
+------------------------------------------------------------*/

   lStmtNum   := 360;
   select  common_bill_sequence_id
   into    l_from_sequence_id
   from    bom_bill_of_materials
   where   assembly_item_id = pModelId
   and     organization_id  = pOrgId
   and     alternate_bom_designator is NULL;

   lStmtNum   := 370;
   fnd_attached_documents2_pkg.copy_attachments(
                        X_from_entity_name      =>  'BOM_BILL_OF_MATERIALS',
                        X_from_pk1_value        =>  l_from_sequence_id,
                        X_from_pk2_value        =>  '',
                        X_from_pk3_value        =>  '',
                        X_from_pk4_value        =>  '',
                        X_from_pk5_value        =>  '',
                        X_to_entity_name        =>  'BOM_BILL_OF_MATERIALS',
                        X_to_pk1_value          =>  lConfigBillId,
                        X_to_pk2_value          =>  '',
                        X_to_pk3_value          =>  '',
                        X_to_pk4_value          =>  '',
                        X_to_pk5_value          =>  '',
                        X_created_by            =>  1,
                        X_last_update_login     =>  '',
                        X_program_application_id=>  '',
                        X_program_id            =>  '',
                        X_request_id            =>  ''
                        );

   lStmtNum   := 380;

  /* Clean up bom_inventory_comps_interface  */

  delete from bom_inventory_comps_interface
  where  bill_sequence_id = lConfigBillId;

  lCnt := sql%rowcount;
  WriteToLog('Deleted from bici, rows::'||lCnt);

  --Bugfix 11056452
  delete from bom_bill_of_mtls_interface
  where bill_sequence_id = lConfigBillId;

  lCnt := sql%rowcount;
  WriteToLog('Deleted from bmi, rows::'||lCnt);


     return(1);


EXCEPTION

	WHEN NO_DATA_FOUND THEN
          	xBillID := 0;
             	return(0);

      	WHEN FND_API.G_EXC_ERROR THEN
        	xErrorMessage := 'CTOCBOMB:create_bom_ml failed with expected error in stmt '||to_char(lStmtNum);
		xMessageName  := 'CTO_CREATE_BOM_ERROR';
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Expected error in Update_Bom_Rtg_Loop::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
                return(0);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	xErrorMessage := 'CTOCBOMB:create_bom_ml failed with unexpected error in stmt '||to_char(lStmtNum);
		xMessageName  := 'CTO_CREATE_BOM_ERROR';
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Unexpected error in Update_Bom_Rtg_Loop::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
                return(0);


	WHEN OTHERS THEN
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNum)||':'||substrb(sqlerrm,1,150);
		xMessageName  := 'CTO_CREATE_BOM_ERROR';
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Update_Bom_Rtg_Loop::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
        	return(0);

END Update_Bom_Rtg_Loop;


PROCEDURE Update_Bom_Rtg_Bulk(
	p_seq in number,
	xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2)
IS

lStmtNum number;

BEGIN

    WriteToLog('Entering update_bom_rtg_bulk', 1);

    /*-----------------------------------------------------+
          Process routing revision table
    +-----------------------------------------------------*/
    lStmtNum   := 70;

    WriteToLog('Inserting into mtl_rtg_item_revisions..',5);
    insert into MTL_RTG_ITEM_REVISIONS
         (
          inventory_item_id,
          organization_id,
          process_revision,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          change_notice  ,
          ecn_initiation_date,
          implementation_date,
          implemented_serial_number,
          effectivity_date       ,
          attribute_category,
          attribute1     ,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13 ,
          ATTRIBUTE14,
          ATTRIBUTE15
         )
    select distinct
          bor.assembly_item_id,
          bor.organization_id,
          mp.starting_revision,
          sysdate,       /* LAST_UPDATE_DATE */
          gUserId,       /* LAST_UPDATED_BY */
          sysdate,       /* CREATION_DATE */
          gUserId,       /* created_by */
          gLoginId,      /* last_update_login */
          NULL,          /* CHANGE_NOTICE  */
          NULL,          /* ECN_INITIATION_DATE */
          TRUNC(SYSDATE), /* IMPLEMENTATION_DATE */
          NULL,          /* IMPLEMENTED_SERIAL_NUMBER */
          TRUNC(SYSDATE), /* EFFECTIVITY_DATE  */
          NULL,          /* ATTRIBUTE_CATEGORY */
          NULL,          /* ATTRIBUTE1  */
          NULL,          /* ATTRIBUTE2 */
          NULL,          /* ATTRIBUTE3 */
          NULL,          /* ATTRIBUTE4 */
          NULL,          /* ATTRIBUTE5 */
          NULL,          /* ATTRIBUTE6 */
          NULL,          /* ATTRIBUTE7 */
          NULL,          /* ATTRIBUTE8 */
          NULL,          /* ATTRIBUTE9 */
          NULL,          /* ATTRIBUTE10 */
          NULL,          /* ATTRIBUTE11 */
          NULL,          /* ATTRIBUTE12 */
          NULL,          /* ATTRIBUTE13 */
          NULL,          /* ATTRIBUTE14 */
          NULL           /* ATTRIBUTE15 */
     from bom_operational_routings bor,
          mtl_parameters  mp,
	  bom_cto_order_lines_upg bcolu
     where bcolu.sequence = p_seq
     and bcolu.status = 'BOM_LOOP'
     and bcolu.config_item_id = bor.assembly_item_id
     and bor.alternate_routing_designator is null
     -- and bor.routing_sequence_id = lCfgRtgId
     and   bor.organization_id = mp.organization_id
     and not exists (
		select 'exists'
		from mtl_rtg_item_revisions mrir
		where mrir.inventory_item_id = bcolu.config_item_id
		and mrir.organization_id = mp.organization_id
		and mrir.process_revision = mp.starting_revision);

     WriteToLog('Inserted rows into mtl_rtg_item_revisions::'||sql%rowcount, 3);
     /*------------------------------------------------+
        ** Load operation resources  table
	** 3 new columns added for WIP Simultaneous Resources
     +-------------------------------------------------*/

     lStmtNum := 150;

     WriteToLog('Inserting into bom_operation_resources..',5);
     insert into BOM_OPERATION_RESOURCES
         (
         operation_sequence_id,
         resource_seq_num,
         resource_id    ,
         activity_id,
         standard_rate_flag,
         assigned_units ,
         usage_rate_or_amount,
         usage_rate_or_amount_inverse,
         basis_type,
         schedule_flag,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         resource_offset_percent,
	 autocharge_type,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
	 schedule_seq_num,
	 substitute_group_num,
	 setup_id,			/*bugfix2950774*/
	 principle_flag
         )
     select distinct
         osi.operation_sequence_id, /* operation sequence id */
         bor.resource_seq_num,
         bor.resource_id, /* resource id */
         bor.activity_id,
         bor.standard_rate_flag,
         bor.assigned_units,
         bor.usage_rate_or_amount,
         bor.usage_rate_or_amount_inverse,
         bor.basis_type,
         bor.schedule_flag,
         SYSDATE,                        /* last update date */
         gUserId,                        /* last updated by */
         SYSDATE,                        /* creation date */
         gUserId,                        /* created by */
         1,                              /* last update login */
         bor.resource_offset_percent,
         bor.autocharge_type,
         bor.attribute_category,
         bor.attribute1,
         bor.attribute2,
         bor.attribute3,
         bor.attribute4,
         bor.attribute5,
         bor.attribute6,
         bor.attribute7,
         bor.attribute8,
         bor.attribute9,
         bor.attribute10,
         bor.attribute11,
         bor.attribute12,
         bor.attribute13,
         bor.attribute14,
         bor.attribute15,
         NULL,                           /* request_id */
         NULL,               /* program_application_id */
         NULL,                           /* program_id */
         NULL,                   /* program_update_date */
	 bor.schedule_seq_num,
	 bor.substitute_group_num,
	 bor.setup_id,			/* Bugfix2950774 */
	 bor.principle_flag
     from
         bom_operation_sequences osi,
         bom_operation_resources bor,
	 bom_cto_order_lines_upg bcolu,
	 bom_operational_routings bor1
     where bcolu.sequence = p_seq
     and bcolu.status = 'BOM_LOOP'
     and bcolu.config_item_id = bor1.assembly_item_id
     and osi.routing_sequence_id = bor1.routing_sequence_id
     -- and osi.routing_sequence_id = lCfgRtgId
     and   osi.request_id  = bor.operation_sequence_id
     and not exists (
	select 'exists'
	from bom_operation_resources bor2
	where bor2.operation_sequence_id = osi.operation_sequence_id
	and bor2.resource_seq_num = bor.resource_seq_num);

     /* request_id contains model op seq_id now */

     WriteToLog('Inserted rows into bom_operation_resources::'||sql%rowcount, 3);


     /*------------------------------------------------+
        ** Load sub operation resources  table
	** new table for WIP Simultaneous Resources
     +-------------------------------------------------*/
     lStmtNum := 155;

     WriteToLog('Inserting into bom_sub_operation_resources ..',5);
     insert into BOM_SUB_OPERATION_RESOURCES
		(operation_sequence_id,
 		substitute_group_num,
 		--resource_seq_num,
 		resource_id,
 		--scheduling_seq_num,
                schedule_seq_num,
 		replacement_group_num,
 		activity_id,
 		standard_rate_flag,
 		assigned_units,
 		usage_rate_or_amount,
 		usage_rate_or_amount_inverse,
 		basis_type,
 		schedule_flag,
 		last_update_date,
 		last_updated_by,
 		creation_date,
 		created_by,
 		last_update_login,
 		resource_offset_percent,
 		autocharge_type,
 		principle_flag,
 		attribute_category,
 		attribute1,
 		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
 		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
 		attribute12,
		attribute13,
		attribute14,
		attribute15,
		setup_id,			/* bugfix2950774 */
 		request_id,
 		program_application_id,
 		program_id,
 		program_update_date
		)
	select  distinct
		osi.operation_sequence_id,
 		bsor.substitute_group_num,
 		--bsor.resource_seq_num,
 		bsor.resource_id,
 		--bsor.scheduling_seq_num,
                bsor.schedule_seq_num,
 		bsor.replacement_group_num,
 		bsor.activity_id,
 		bsor.standard_rate_flag,
 		bsor.assigned_units,
 		bsor.usage_rate_or_amount,
 		bsor.usage_rate_or_amount_inverse,
 		bsor.basis_type,
 		bsor.schedule_flag,
 		SYSDATE,	/*last_update_date*/
 		gUserId,	/*last_updated_by*/
 		SYSDATE,	/*creation_date*/
 		gUserId,	/*created_by*/
 		1,		/*last_update_login*/
 		bsor.resource_offset_percent,
 		bsor.autocharge_type,
 		bsor.principle_flag,
 		bsor.attribute_category,
 		bsor.attribute1,
 		bsor.attribute2,
		bsor.attribute3,
		bsor.attribute4,
		bsor.attribute5,
		bsor.attribute6,
 		bsor.attribute7,
		bsor.attribute8,
		bsor.attribute9,
		bsor.attribute10,
		bsor.attribute11,
 		bsor.attribute12,
		bsor.attribute13,
		bsor.attribute14,
		bsor.attribute15,
		bsor.setup_id,			/* bugfix2950774 */
 		NULL,		/*request_id*/
 		NULL,		/*program_application_id*/
 		NULL,		/*program_id*/
 		NULL		/*program_update_date*/
	from
         	bom_operation_sequences osi,
         	bom_sub_operation_resources bsor,
		bom_cto_order_lines_upg bcolu,
		bom_operational_routings bor
     	where bcolu.sequence = p_seq
     	and bcolu.status = 'BOM_LOOP'
	and bcolu.config_item_id = bor.assembly_item_id
	and osi.routing_sequence_id = bor.routing_sequence_id
	-- and osi.routing_sequence_id = lCfgRtgId
     	and   osi.request_id  = bsor.operation_sequence_id
	and not exists (
		select 'exists'
		from bom_sub_operation_resources bsor1
		where bsor1.operation_sequence_id = osi.operation_sequence_id
		and bsor1.resource_id = bsor.resource_id
		and bsor1.substitute_group_num = bsor.substitute_group_num
		and bsor1.replacement_group_num = bsor.replacement_group_num);

     	/* request_id contains model op seq_id now */

        WriteToLog('Inserted rows into bom_sub_operation_resources::'||sql%rowcount, 3);

     /*---------------------------------------------------+
		** Process operation Networks table
     +---------------------------------------------------*/
     lStmtNum := 380;

     WriteToLog('Inserting into bom_operation_networks ..',5);
     INSERT INTO bom_operation_networks
            ( FROM_OP_SEQ_ID,
            TO_OP_SEQ_ID,
            TRANSITION_TYPE,
            PLANNING_PCT,
            EFFECTIVITY_DATE,
            DISABLE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1  ,
            ATTRIBUTE2  ,
            ATTRIBUTE3  ,
            ATTRIBUTE4  ,
            ATTRIBUTE5  ,
            ATTRIBUTE6  ,
            ATTRIBUTE7  ,
            ATTRIBUTE8  ,
            ATTRIBUTE9  ,
            ATTRIBUTE10 ,
            ATTRIBUTE11 ,
            ATTRIBUTE12 ,
            ATTRIBUTE13 ,
            ATTRIBUTE14 ,
            ATTRIBUTE15
            )
    SELECT distinct
           bos3.operation_sequence_id,
           bos4.operation_sequence_id,
           bon.TRANSITION_TYPE,
           bon.PLANNING_PCT,
           bon.EFFECTIVITY_DATE,
           bon.DISABLE_DATE,
           bon.CREATED_BY,
           bon.CREATION_DATE,
           bon.LAST_UPDATED_BY,
           bon.LAST_UPDATE_DATE,
           bon.LAST_UPDATE_LOGIN,
           bon.ATTRIBUTE_CATEGORY,
           bon.ATTRIBUTE1,
           bon.ATTRIBUTE2,
           bon.ATTRIBUTE3,
           bon.ATTRIBUTE4,
           bon.ATTRIBUTE5,
           bon.ATTRIBUTE6,
           bon.ATTRIBUTE7,
           bon.ATTRIBUTE8,
           bon.ATTRIBUTE9,
           bon.ATTRIBUTE10,
           bon.ATTRIBUTE11,
           bon.ATTRIBUTE12,
           bon.ATTRIBUTE13,
           bon.ATTRIBUTE14,
           bon.ATTRIBUTE15
    FROM   bom_operation_networks    bon,
           bom_operation_sequences   bos1, /* 'from'  Ops of model  */
           bom_operation_sequences   bos2, /* 'to'    Ops of model  */
           bom_operation_sequences   bos3, /* 'from'  Ops of config */
           bom_operation_sequences   bos4, /* 'to'    Ops of config */
           bom_operational_routings  brif,
	   bom_cto_order_lines_upg bcolu
    WHERE  bon.from_op_seq_id         = bos1.operation_sequence_id
    AND     bon.to_op_seq_id           = bos2.operation_sequence_id
    AND     bos1.routing_sequence_id   = bos2.routing_sequence_id
    AND     bos3.routing_sequence_id   = brif.routing_sequence_id
    AND     brif.cfm_routing_flag      = 1
    --AND     brif.routing_sequence_id   = lCfgrtgId
    and	    bcolu.sequence = p_seq
    and bcolu.status = 'BOM_LOOP'
    and     bcolu.config_item_id = brif.assembly_item_id
    and     brif.alternate_routing_designator is null
    AND     bos3.operation_seq_num     = bos1.operation_seq_num
    AND     NVL(bos3.operation_type,1) = NVL(bos1.operation_type, 1)
    AND     bos4.routing_sequence_id   = bos3.routing_sequence_id
    AND     bos4.operation_seq_num     = bos2.operation_seq_num
    AND     NVL(bos4.operation_type,1) = NVL(bos2.operation_type, 1)
    AND     bos1.routing_sequence_id   = (     /* find the model routing */
            select routing_sequence_id
            from   bom_operational_routings   bor,
                   mtl_system_items msi
            where  brif.assembly_item_id = msi.inventory_item_id
            and    brif.organization_id  = msi.organization_id
            and    bor.assembly_item_id  = msi.base_item_id
            and    bor.organization_id   = msi.organization_id
            and    bor.cfm_routing_flag  = 1
            and    bor.alternate_routing_designator is null )
    and     not exists (
	select 'exists'
	from bom_operation_networks bon2
	where bon2.from_op_seq_id = bos3.operation_sequence_id
	and bon2.to_op_seq_id = bos4.operation_sequence_id);

     WriteToLog('Inserted rows into bom_operation_networks::'||sql%rowcount, 3);


   /* -------------------------------------------------------------------------+
         Insert into BOM_REFERENCE_DESIGNATORS table
	  HAS BEEN REMOVED AS PART OF BUGFIX 3793286
	 as there is already a insert in this table  in api update_bom_rtg_loop.
	 For additional details look at update *** KKONADA  11/05/04 03:43 pm ***
	 of bug 3793286
   +--------------------------------------------------------------------------*/


EXCEPTION

	WHEN OTHERS THEN
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Update_Bom_Rtg_Bulk::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		xReturnStatus := fnd_api.g_ret_sts_unexp_error;
        	cto_msg_pub.count_and_get
        	  (  p_msg_count => xMsgCount
        	   , p_msg_data  => xMsgData
        	   );


END Update_Bom_Rtg_Bulk;

/*------------------------------------------------+
This procedure is called in a loop to update the
Item Sequence Number on the components of the configuration
BOM such that there are no duplicates, and the logical order
in which they are selected from the model BOM is maintained.
+------------------------------------------------*/
PROCEDURE update_item_num(
	p_parent_bill_seq_id IN NUMBER,
	p_item_num IN OUT NOCOPY NUMBER,
	p_org_id IN NUMBER,
	p_seq_increment	IN NUMBER)

IS

    CURSOR c_update_item_num(p_parent_bill_seq_id number) IS
	select component_sequence_id,
		component_item_id
	from bom_inventory_comps_interface
	where parent_bill_seq_id = p_parent_bill_seq_id
	FOR UPDATE OF item_num;

    p_bill_seq_id number;

BEGIN

  FOR v_update_item_num IN c_update_item_num(p_parent_bill_seq_id)
  LOOP

	WriteToLog('In update loop for item '||to_char(v_update_item_num.component_item_id), 5);

  	--
  	-- update item_num of child of this model
  	--
  	update bom_inventory_comps_interface
  	set item_num = p_item_num
  	where current of c_update_item_num;

	WriteToLog('Updated item '||to_char(v_update_item_num.component_item_id)|| ' with item num '||to_char(p_item_num), 5);

  	p_item_num := p_item_num + p_seq_increment;

  	--
  	-- get bill_sequence_id of child
  	--
	BEGIN

  	select common_bill_sequence_id
  	into p_bill_seq_id
  	from bom_bill_of_materials
  	where assembly_item_id = v_update_item_num.component_item_id
	and organization_id = p_org_id
	and alternate_bom_designator is null;

	WriteToLog('Calling update_item_num will p_bill_seq_id::'||to_char(p_bill_seq_id)||' and p_item_num::'||to_char(p_item_num), 5);

	update_item_num(
		p_bill_seq_id,
		p_item_num,
		p_org_id,
		p_seq_increment);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		WriteToLog('This component '||to_char(v_update_item_num.component_item_id)||' does not have a BOM', 2);

	END;

  END LOOP;

EXCEPTION
	WHEN OTHERS THEN
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Update_Item_Num::'||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);

END update_item_num;


FUNCTION inherit_op_seq_ml(
  		pLineId        in   oe_order_lines.line_id%TYPE := NULL,
  		pOrgId         in   oe_order_lines.ship_from_org_id%TYPE := NULL,
  		pModelId       in   bom_bill_of_materials.assembly_item_id%TYPE := NULL ,
  		pConfigBillId  in   bom_inventory_components.bill_sequence_id%TYPE := NULL,
  		xErrorMessage  out  NOCOPY VARCHAR2,
  		xMessageName   out  NOCOPY VARCHAR2)
RETURN INTEGER IS

	CURSOR c_incl_items_all_level (	xOrgId  	mtl_system_items.organization_id%TYPE,
					xLineId 	bom_cto_order_lines_upg.line_id%TYPE,
					xConfigBillId	bom_inventory_components.bill_sequence_id%TYPE ,
					xSchShpdt 	date,
					xEstReldt 	date ) IS
	select  bbm.organization_id,
		nvl(bic.operation_seq_num,1) operation_seq_num ,	-- 2433862
		nvl(bet.operation_seq_num,1) parent_op_seq_num, 	-- 2433862
     		bic.component_item_id,
     		bic.item_num,
     		decode(nvl(bic.basis_type,1),1,bic.component_quantity * (bcol1.ordered_quantity  / bcol2.ordered_quantity ),bic.component_quantity) component_qty,
          	bic.component_yield_factor,
                bic.component_remarks,                                  --Bugfix 7188428
     		bic.attribute_category,
     		bic.attribute1,
     		bic.attribute2,
     		bic.attribute3,
     		bic.attribute4,
     		bic.attribute5,
     		bic.attribute6,
     		bic.attribute7,
     		bic.attribute8,
     		bic.attribute9,
     		bic.attribute10,
     		bic.attribute11,
     		bic.attribute12,
     		bic.attribute13,
     		bic.attribute14,
     		bic.attribute15,
     		bic.so_basis,
     		bic.include_in_cost_rollup,
     		bic.check_atp,
     		bic.required_for_revenue,
     		bic.include_on_ship_docs,
     		bic.include_on_bill_docs,
     		bic.wip_supply_type,
     		bic.component_sequence_id,            		-- model comp seq for later use
     		bic.supply_subinventory,
     		bic.supply_locator_id,
     		bic.bom_item_type,
		bic.bill_sequence_id,				-- parent_bill_seq_id
		bcol1.plan_level+1 plan_level,
                decode(                                         -- 3222932 /* 02-14-2005 Sushant */
                  greatest(bic.effectivity_date,sysdate),
                  bic.effectivity_date ,
                  bic.effectivity_date ,
                  sysdate ) eff_date,
                nvl(bic.disable_date,g_futuredate) dis_date,     -- 3222932 /* 02-14-2005 Sushant */
                nvl(bic.basis_type,1) basis_type
	from 	bom_cto_order_lines_upg		bcol1,		-- COMPONENT
		bom_cto_order_lines_upg		bcol2,		-- MODEL
		mtl_system_items 		si1,
     		mtl_system_items 		si2,
		bom_bill_of_materials 		bbm,
		bom_inventory_components 	bic,		-- Components
		bom_inventory_components 	bic1,		-- Parent
		bom_explosion_temp		bet
	where 	bcol1.parent_ato_line_id = xLineId
	and	bcol1.component_code = bet.component_code
	and     si1.organization_id = xOrgId
   	and     bcol1.inventory_item_id = si1.inventory_item_id
   	and     si1.bom_item_type in (1,2)      		-- model, option class
   	and     si2.inventory_item_id = bcol2.inventory_item_id
   	and     si2.organization_id = si1.organization_id
   	and     si2.bom_item_type = 1
	and     (bcol1.parent_ato_line_id  = bcol2.line_id
                  	and ( bcol1.bom_item_type <> 1
                        	or  (	bcol1.bom_item_type = 1
                             		and 	nvl(bcol1.wip_supply_type, 0) = 6
                             	    )
                            )
                )
        and	bet.bill_sequence_id = xConfigBillId
	and	bet.top_bill_sequence_id = xConfigBillId
	and	bic1.component_sequence_id = bcol1.component_sequence_id
	and	bic1.bom_item_type in (1,2)
	and	bbm.assembly_item_id	= bic1.component_item_id
	and	bbm.organization_id	= si1.organization_id
	and	bbm.alternate_bom_designator is NULL
	and	bic.bill_sequence_id = DECODE(bbm.common_bill_sequence_id,bbm.bill_sequence_id,bbm.bill_sequence_id,bbm.common_bill_sequence_id)
	and    	bic.optional = 2
	and    	bic.bom_item_type = 4
	and    	bic.effectivity_date <= greatest( NVL(xSchShpdt,sysdate),sysdate)
	and    	bic.implementation_date is not null
	and    	NVL(bic.disable_date,NVL(xEstReldt, SYSDATE)+1) > NVL(xEstReldt,SYSDATE)
	and	NVL(bic.disable_date,SYSDATE) >= SYSDATE;

	CURSOR c_model_oc_oi_rows(xConfigBillId bom_inventory_components.bill_sequence_id%TYPE) IS
	SELECT 		/*+ INDEX( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11) */
                        nvl(operation_seq_num,1) operation_seq_num,	-- 2433862
		        component_code,
			rowid
	from 		bom_explosion_temp
	where		bill_sequence_id = xConfigBillId
	and		component_code IS NOT NULL
	ORDER BY component_code;

	lStmtNumber 	number;
	lCnt		number;

/* begin 04-04-2005 */
  v_zero_qty_count      number ;
  l_token1            CTO_MSG_PUB.token_tbl;
  v_model_item_name   varchar2(2000) ;
/* end 04-04-2005 */



 v_overlap_check  number := 0 ;

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  v_t_overlap_comp_item_id  num_tab;
  v_t_overlap_src_op_seq_num num_tab;
  v_t_overlap_src_eff_date   date_tab;
  v_t_overlap_src_disable_date date_tab;
  v_t_overlap_dest_op_seq_num  num_tab;
  v_t_overlap_dest_eff_date    date_tab;
  v_t_overlap_dest_disable_date date_tab;

 l_token2   CTO_MSG_PUB.token_tbl;


	BEGIN


	lStmtNumber := 520;

	--
	-- Insert Option Classes and Option Items
	-- Compare to last insert , here we have an addl column
	-- component_code to insert comp_code of classes /items
	-- from bcol
	--

insert into bom_explosion_temp
 (      top_bill_sequence_id,
   organization_id,
   plan_level,
   sort_order,
  operation_seq_num,
        component_item_id,
        item_num,
        component_quantity,
        component_yield_factor,
        component_remarks,                              --Bugfix 7188428
        context,                                        -- mapped to attribute_category in bic interface
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        planning_factor,
        select_quantity,
        so_basis,
        optional,
        mutually_exclusive_options,
        include_in_rollup_flag,
        check_atp,
        shipping_allowed,
        required_to_ship,
        required_for_revenue,
        include_on_ship_docs,
        include_on_bill_docs,
        component_sequence_id,
        bill_sequence_id,
        wip_supply_type,
        pick_components,
        base_item_id,
        supply_subinventory,
        supply_locator_id,
        bom_item_type,
  component_code,
  line_id,
  top_item_id,
                effectivity_date,
                disable_date,
		assembly_item_id,   /* Bug Fix: 4147224 */
  basis_type
       )
 select  pconfigbillid,
  bcol2.ship_from_org_id,
  (bcol1.plan_level-bcol2.plan_level),
  '1',           -- Sort Order
  nvl(ic1.operation_seq_num,1),
        decode(bcol1.config_item_id, NULL, ic1.component_item_id,bcol1.config_item_id),
        ic1.item_num,
                Round(
                CTO_UTILITY_PK.convert_uom( bcol1.order_quantity_uom, msi_child.primary_uom_code,
                    bcol1.ordered_quantity , msi_child.inventory_item_id ) /
                CTO_UTILITY_PK.convert_uom(bcol2.order_quantity_uom, msi_parent.primary_uom_code,
                    NVL(bcol2.ordered_quantity,1) , msi_parent.inventory_item_id ) , 7) ,
        ic1.component_yield_factor,
        ic1.component_remarks,                          --Bugfix 7188428
        ic1.attribute_category,
        ic1.attribute1,
        ic1.attribute2,
        ic1.attribute3,
        ic1.attribute4,
        ic1.attribute5,
        ic1.attribute6,
        ic1.attribute7,
        ic1.attribute8,
        ic1.attribute9,
        ic1.attribute10,
        ic1.attribute11,
        ic1.attribute12,
        ic1.attribute13,
        ic1.attribute14,
        ic1.attribute15,
        100,
        2,
        decode(bcol1.config_item_id, NULL,
  decode(ic1.bom_item_type,4,ic1.so_basis,2),2),
        1,
        2,
        decode(bcol1.config_item_id, NULL,
           decode(ic1.bom_item_type,4,
    ic1.include_in_cost_rollup, 2),1),
        decode(bcol1.config_item_id, NULL,
   decode(ic1.bom_item_type,4,
    ic1.check_atp, 2),2),
        2,
        2,
        ic1.required_for_revenue,
        ic1.include_on_ship_docs,
        ic1.include_on_bill_docs,
        bom_inventory_components_s.nextval,
        pConfigBillId,
        ic1.wip_supply_type,
        2,
        decode(bcol1.config_item_id, NULL, (-1)*ic1.component_sequence_id, ic1.component_sequence_id),
        ic1.supply_subinventory,
        ic1.supply_locator_id,
        decode(bcol1.config_item_id, NULL, ic1.bom_item_type, 4),
  bcol1.component_code,
  bcol1.line_id,
  ic1.bill_sequence_id,
                decode(
                  greatest(ic1.effectivity_date,sysdate),
                  ic1.effectivity_date ,
                  ic1.effectivity_date ,
                  sysdate ),
                nvl(ic1.disable_date,g_futuredate),
bcol3.inventory_item_id , /* Bug Fix: 4147224 */
  nvl(ic1.basis_type,1)
  from    bom_inventory_components ic1,
      bom_cto_order_lines_upg bcol1,
      bom_cto_order_lines_upg bcol2,
      bom_cto_order_lines_upg bcol3,
                mtl_system_items msi_child,
                mtl_system_items msi_parent
 where   ic1.bill_sequence_id = (
         select common_bill_sequence_id
         from   bom_bill_of_materials bbm
         where  organization_id = pOrgId
         and    alternate_bom_designator is null
         and    assembly_item_id =(
              select distinct assembly_item_id
              from    bom_bill_of_materials bbm1,
                     bom_inventory_components bic1
              where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
              and    component_sequence_id        = bcol1.component_sequence_id
              and    bbm1.assembly_item_id        = bcol3.inventory_item_id ))
   and  ic1.component_item_id           = bcol1.inventory_item_id
        and     msi_child.inventory_item_id = bcol1.inventory_item_id
        and     msi_child.organization_id = pOrgId
        and     msi_parent.inventory_item_id = bcol2.inventory_item_id
        and     msi_parent.organization_id = pOrgId
        and     ic1.implementation_date is not null
         and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate ))
   and      (( ic1.optional = 1 and ic1.bom_item_type = 4)
                 or
             ( ic1.bom_item_type in (1,2)))
   and     bcol1.ordered_quantity <> 0
   and     bcol1.line_id <> bcol2.line_id
   and     bcol1.parent_ato_line_id = bcol2.line_id
   and     bcol1.parent_ato_line_id is not null
   and     bcol1.link_to_line_id is not null
   and     bcol2.line_id            = pLineId
   and     bcol2.ship_from_org_id   = bcol1.ship_from_org_id
   and     (bcol3.parent_ato_line_id  = bcol1.parent_ato_line_id
             or
       bcol3.line_id = bcol1.parent_ato_line_id)
   and     bcol3.line_id = bcol1.link_to_line_id;

    	lCnt := sql%rowcount ;

 	WriteToLog('Inherit_op_seq_ml:Inserted in BE Temp ' || lCnt ||' Option item/Option class rows with bill seq id as '|| pConfigBillId, 3);







         /* 04-04-2005 begin zero qty check */

         select /*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
         count(*) into v_zero_qty_count from bom_explosion_temp
         where bill_sequence_id = pConfigBillId  and component_quantity = 0 ;

         WriteToLog( 'MODELS: CHECK Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

         if( v_zero_qty_count > 0 ) then

             WriteToLog( 'Inherit_op_seq_ml:: SHOULD Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;


             select concatenated_segments into v_model_item_name
               from mtl_system_items_kfv
              where inventory_item_id = pModelId
                and rownum = 1 ;


             l_token1(1).token_name  := 'MODEL_NAME';
             l_token1(1).token_value := v_model_item_name ;


             cto_msg_pub.cto_message('BOM','CTO_ZERO_BOM_COMP' , l_token1 );

             raise fnd_api.g_exc_error;




         end if ;


         /* 04-04-2005 end zero qty check */



    /* Effectivity Dates changes */
        /* moved mandatory comps code */
	lStmtNumber := 510;

	/*Insert Incl. items under Base Model */

	INSERT INTO bom_explosion_temp
	(
 		top_bill_sequence_id,
 		organization_id,
 		plan_level,
 		sort_order,
 		operation_seq_num,
      		component_item_id,
      		item_num,
      		component_quantity,
      		component_yield_factor,
                component_remarks,                              --Bugfix 7188428
      		context,					-- mapped to attribute_category in bic interface
      		attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		optional,					-- mapped to optional_on_model in bic interface
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		component_sequence_id,
      		bill_sequence_id,
      		wip_supply_type,
      		pick_components,
      		base_item_id,					-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
		top_item_id,
                Effectivity_date,     -- Added by Renga
                Disable_date         -- Added by Renga					-- mapped to parent_bill_seq_id in bic interface
                , basis_type    /* LBM project */
      	)
	select 	pConfigBillId,                  		-- top bill sequence id
		bbm.organization_id,				-- Model's organization_id
		1,						-- Plan Level, should be 0+1 for model's smc's
		'1',      					-- Sort Order
		nvl(bic.operation_seq_num,1),
     		bic.component_item_id,
     		bic.item_num,
     		bic.component_quantity  component_qty,
     		bic.component_yield_factor,
                bic.component_remarks,                          --Bugfix 7188428
     		bic.attribute_category,
     		bic.attribute1,
     		bic.attribute2,
     		bic.attribute3,
     		bic.attribute4,
     		bic.attribute5,
     		bic.attribute6,
     		bic.attribute7,
     		bic.attribute8,
     		bic.attribute9,
     		bic.attribute10,
     		bic.attribute11,
     		bic.attribute12,
     		bic.attribute13,
     		bic.attribute14,
     		bic.attribute15,
     		100,                                  		-- planning_factor
     		2,                                    		-- quantity_related
     		bic.so_basis,
     		2,                                    		-- optional
     		2,                                    		-- mutually_exclusive_options
     		bic.include_in_cost_rollup,
     		bic.check_atp,
     		2,                                    		-- shipping_allowed = NO
     		2,                                    		-- required_to_ship = NO
     		bic.required_for_revenue,
     		bic.include_on_ship_docs,
     		bic.include_on_bill_docs,
     		bom_inventory_components_s.nextval,   		-- component sequence id
     		pConfigBillId,                        		-- bill sequence id
     		bic.wip_supply_type,
     		2,                                    		-- pick_components = NO
     		(-1)*bic.component_sequence_id,            		-- model comp seq for later use
     		bic.supply_subinventory,
     		bic.supply_locator_id,
     		bic.bom_item_type,
		bic.bill_sequence_id,
                decode(                                         -- 3222932
                  greatest(bic.effectivity_date,sysdate),
                  bic.effectivity_date ,
                  bic.effectivity_date ,
                  sysdate ),
                nvl(bic.disable_date,g_futuredate)              -- 3222932
                , nvl(bic.basis_type,1)                                /* LBM project */
	from 	bom_cto_order_lines_upg		bcol,
		bom_bill_of_materials 		bbm,
		bom_inventory_components 	bic
	where   bcol.line_id = pLineId
	and     bcol.ordered_quantity <> 0
	-- bugfix 2389283 and	instr(bcol.component_code,'-',1,1) = 0 /* To identify Top Model */
	and     bcol.inventory_item_id = pModelId
	and	bbm.organization_id = pOrgId
	and	bcol.inventory_item_id = bbm.assembly_item_id
	and     bbm.alternate_bom_designator is NULL
	and     bbm.common_bill_sequence_id = bic.bill_sequence_id
	and     bic.optional = 2
	and     bic.bom_item_type = 4
	-- and     bic.effectivity_date <= greatest( NVL(g_SchShpDate,sysdate),sysdate) /* New approach for effectivity dates */
	and     bic.implementation_date is not null
        /*
	and     NVL(bic.disable_date,NVL(g_EstRelDate, SYSDATE)+1) > NVL(g_EstRelDate,SYSDATE)
	and    	NVL(bic.disable_date,SYSDATE) >= SYSDATE;
        */
        and  ( bic.disable_date is null or
         (bic.disable_date is not null and  bic.disable_date >= sysdate )) ; /* New Approach for Effectivity Dates */

	lCnt := sql%rowcount ;

	IF PG_DEBUG <> 0 THEN
		WriteToLog ('inherit_op_seq_ml: ' || 'First -- Inserted in BE Temp ' || lCnt ||' Incl Item rows with bill seq id as '|| pConfigBillId,1);
	END IF;

	lStmtNumber := 530;

	/*+------------------------------------------------------------------------------------------------------------
	Open cursor c_model_oc_oi_rows(xConfigBillId) for rows inserted in bet
	This will update all Option Class and Option Item rows
	Mandatory items directly under model will already have op_seq_num. For these mandatory items we don't need to
	inherit the op_seq_num since they are directly under model.
	The component_code for these mand items are NULL as they are not in BCOL.
	so , mandatory item rows from bet will not be selected by c_model_oc_oi_rows cursor and will not be updated
	Explanation :
	For a Bill structure like this :
	55631 	1.1.0    KS-ATO-MODEL1*6389
   	55627 	1.1      KS-ATO-MODEL1
    	55628 	1.1.1    KS-ATO-MODEL3
    	55629 	1.1.2    KS-ATO-OC1
    	55630 	1.1.3    KS-ATO-OI1
   	BCOL.LINE_ID 	BCOL.COMP_SEQ_ID 	BCOL.COMPONENT_CODE
   	----------   	----------------	---------------
     	55627          	21053                	6280
     	55628          	21322                	6280-6376
     	55629          	21303                	6280-6376-6282
     	55630          	21035                	6280-6376-6282-6288
	Now , instr( bet.component_code,'-',1,2 ) will select line_id 55629 and 55630 as those rows are actual candidates for
	op_seq_num update. 55627 was not inserted in bet as it is the base model row and we are not selecting 55628 since this
	is directly under the top model and inheritence logic does not apply to this line.
	Inheritence starts from second level . First level components under top model will always have op_seq_num.

	+------------------------------------------------------------------------------------------------------------+*/

	FOR r1 in c_model_oc_oi_rows(pConfigBillId) LOOP
		IF r1.operation_seq_num = 1 AND instr(r1.component_code,'-',1,2)<>0 THEN
			 IF PG_DEBUG <> 0 THEN  -- 13079222
			       oe_debug_pub.add ('Component Code: ' || r1.component_code,1);
		         END IF;
			UPDATE bom_explosion_temp bet
			SET bet.operation_seq_num = (
				SELECT /*+ INDEX( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11) */
                                       nvl(operation_seq_num,1)	-- 2433862
				FROM   bom_explosion_temp
				WHERE  component_code = substr(bet.component_code,1,to_number(instr(bet.component_code,'-',-1,1))-1)
				AND    bill_sequence_id = pConfigBillId
 				AND    top_bill_sequence_id = pConfigBillId)
			WHERE component_code = r1.component_code
			AND   rowid = r1.rowid;
		END IF;
	END LOOP;

	lStmtNumber := 540;

	/* Open cursor c_incl_items_all_level */

	FOR r2 in c_incl_items_all_level (pOrgId ,pLineId ,pConfigBillId,g_SchShpDate,g_EstRelDate ) LOOP
	   INSERT INTO bom_explosion_temp
	   (	top_bill_sequence_id,
 		organization_id,
 		plan_level,
 		sort_order,
 		operation_seq_num,
      		component_item_id,
      		item_num,
      		component_quantity,
      		component_yield_factor,
                component_remarks,                              --Bugfix 7188428
     		context,					-- mapped to attribute_category in bic interface
     		attribute1,
     		attribute2,
     		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
     		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		optional,					-- mapped to optional_on_model of bic interface
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		component_sequence_id,
      		bill_sequence_id,
      		wip_supply_type,
      		pick_components,
      		base_item_id,					-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
		top_item_id,					-- mapped to parent_bill_seq_id of bic interface
                effectivity_date,                               -- 3222932 /* 02-14-2005 Sushant */
                disable_date,                                    -- 3222932 /* 02-14-2005 Sushant */
                basis_type
	   )
	   VALUES
	   (	pConfigBillId,                	  		-- top bill sequence id
		r2.organization_id,			  	-- Model's organization_id
		r2.plan_level, 					  -- Plan Level
		'1',      					  -- Sort Order
		DECODE(r2.operation_seq_num,1,r2.parent_op_seq_num,r2.operation_seq_num),
		r2.component_item_id,
		r2.item_num,
		r2.component_qty,
		r2.component_yield_factor,
                r2.component_remarks,                           --Bugfix 7188428
		r2.attribute_category,
     		r2.attribute1,
     		r2.attribute2,
     		r2.attribute3,
     		r2.attribute4,
     		r2.attribute5,
     		r2.attribute6,
     		r2.attribute7,
     		r2.attribute8,
     		r2.attribute9,
     		r2.attribute10,
     		r2.attribute11,
     		r2.attribute12,
     		r2.attribute13,
     		r2.attribute14,
     		r2.attribute15,
		100,                                  		-- planning_factor
     		2,                                    		-- quantity_related
		r2.so_basis,
		2,                                    		-- optional
     		2,                                    		-- mutually_exclusive_options
		r2.include_in_cost_rollup,
     		r2.check_atp,
     		2,                                    		-- shipping_allowed = NO
     		2,                                   		-- required_to_ship = NO
     		r2.required_for_revenue,
     		r2.include_on_ship_docs,
     		r2.include_on_bill_docs,
		bom_inventory_components_s.nextval,   		-- component sequence id
     		pConfigBillId,                        		-- bill sequence id
		r2.wip_supply_type,
     		2,                                    		-- pick_components = NO
     		(-1)*r2.component_sequence_id,            		-- model comp seq for later use
     		r2.supply_subinventory,
     		r2.supply_locator_id,
     		r2.bom_item_type,
		r2.bill_sequence_id,				-- parent_bill_seq_id
                r2.eff_date,                                    -- 3222932 /* 02-14-2005 Sushant */
                r2.dis_date,  		 -- 3222932 /* 02-14-2005 Sushant */
		r2.basis_type
	   );
	   lCnt := sql%rowcount ;
	   WriteToLog('Inherit_op_seq_ml:Inserted in BE Temp ' || lCnt ||' manadatory item rows with bill seq id as '|| pConfigBillId, 4);
	END LOOP;


	lStmtNumber := 550;

	/*Insert into bic interface*/
	insert into BOM_INVENTORY_COMPS_INTERFACE
	( 	operation_seq_num,
      		component_item_id,
      		last_update_date,
      		last_updated_by,
      		creation_date,
      		created_by,
      		last_update_login,
      		item_num,
      		component_quantity,
      		component_yield_factor,
      		component_remarks,
      		effectivity_date,
      		change_notice,
      		implementation_date,
      		disable_date,
      		attribute_category,
      		attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		quantity_related,
      		so_basis,
      		optional,
      		mutually_exclusive_options,
      		include_in_cost_rollup,
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		low_quantity,
      		high_quantity,
      		acd_type,
      		old_component_sequence_id,
      		component_sequence_id,
      		bill_sequence_id,
      		request_id,
      		program_application_id,
      		program_id,
      		program_update_date,
      		wip_supply_type,
      		pick_components,
      		model_comp_seq_id,
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
      		revised_item_sequence_id,			-- 2814257
		optional_on_model,
		plan_level,
		parent_bill_seq_id,
                assembly_item_id /* Bug Fix 4147224 */
                , basis_type,                   /* LBM changes */
                batch_id
	)
	select 	/*+ INDEX( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11) */
                nvl(operation_seq_num,1),			-- 2433862
      		component_item_id,
		SYSDATE,                            		-- last_updated_date
      		1,                                  		-- last_updated_by
      		SYSDATE,                            		-- creation_date
      		1,                                  		-- created_by
      		1,                                  		-- last_update_login
      		item_num,
      		component_quantity,
      		component_yield_factor,
		component_remarks,                              --Bugfix 7188428
                --NULL,                               		-- component_remark
		-- TRUNC(SYSDATE),                     		-- effective date
                effectivity_date,                /* 02-14-2005 Sushant */
      		NULL,                               		-- change notice
      		SYSDATE,                            		-- implementation_date
      		disable_date,                               		-- disable date
      		context,					-- mapped to attribute_category in bic interface
     		 attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		2,						-- optional
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
		NULL,                                 		-- low_quantity
      		NULL,                                 		-- high_quantity
     		NULL,                                 		-- acd_type
      		NULL,                                 		-- old_component_sequence_id
      		component_sequence_id,
      		bill_sequence_id,
		NULL,                                 		-- request_id
      		NULL,                                 		-- program_application_id
      		NULL,                                 		-- program_id
      		NULL,                                 		-- program_update_date
      		wip_supply_type,
      		pick_components,
      		base_item_id,				  	-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
      		line_id,					-- 2814257
		optional,
		plan_level,
		top_item_id,
                assembly_item_id /* Bug Fix: 4147224 */
                , nvl(basis_type,1),  /* LBM project */
                cto_msutil_pub.bom_batch_id
	from 	bom_explosion_temp
	where 	bill_sequence_id = pConfigBillId;

	lCnt := sql%rowcount ;
	WriteToLog('Inherit_op_seq_ml:Inserted in BIC Interface ' || lCnt ||' rows from BET', 4);
	   update bom_inventory_comps_interface
   set disable_date = g_futuredate
   where (component_item_id, operation_seq_num,disable_date)
   in    ( select
              component_item_id, operation_seq_num,max(disable_date)
           from bom_inventory_comps_interface
           where bill_sequence_id = pConfigBillId
           group by component_item_id, operation_seq_num, assembly_item_id
	 )
   and  bill_sequence_id = pConfigBillId
   and disable_date <> g_futuredate ;

   If PG_DEBUG <> 0 Then
      WriteToLog('Create_bom_ml: Extending the disable dates to futuure date = '||sql%rowcount,1);
      WriteToLog('Create_bom_ml: lconfigBillId = '||to_char(pConfigBillid),1);
   End if;


   /* begin Check for Overlapping Effectivity Dates */
   v_overlap_check := 0 ;

   begin
     select 1 into v_overlap_check
     from dual
      where exists
       ( select * from bom_inventory_comps_interface
          where bill_sequence_id = pConfigBillId
          group by component_item_id, assembly_item_id
          having count(distinct operation_seq_num) > 1
       );
   exception
   when others then
       v_overlap_check := 0 ;
   end;


   if(v_overlap_check = 1) then

     begin
        select s1.component_item_id,
               s1.operation_seq_num, s1.effectivity_date, s1.disable_date,
               s2.operation_Seq_num , s2.effectivity_date, s2.disable_date
        BULK COLLECT INTO
               v_t_overlap_comp_item_id,
               v_t_overlap_src_op_seq_num,  v_t_overlap_src_eff_date, v_t_overlap_src_disable_date ,
               v_t_overlap_dest_op_seq_num , v_t_overlap_dest_eff_date, v_t_overlap_dest_disable_date
        from bom_inventory_comps_interface s1 , bom_inventory_comps_interface s2
       where s1.component_item_id = s2.component_item_id and s1.assembly_item_id = s2.assembly_item_id
         and s1.effectivity_date between s2.effectivity_date and s2.disable_date
         and s1.component_sequence_id <> s2.component_sequence_id ;


     exception
     when others then
        null ;
     end ;



     if( v_t_overlap_src_op_seq_num.count > 0 ) then
         for i in v_t_overlap_src_op_seq_num.first..v_t_overlap_src_op_seq_num.last
         loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add (' The following components have overlapping dates ', 1);
                oe_debug_pub.add (' COMP ' || ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' || ' OVERLAPS ' ||
                                              ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' , 1);
                /*
                oe_debug_pub.add ( v_t_overlap_comp_item_id(i) ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) ||
                                  ' OVERLAPS ' ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) , 1);
                    */
             END IF;

            select concatenated_segments into v_model_item_name
              from mtl_system_items_kfv
             where inventory_item_id = pModelId
               and rownum = 1 ;


            l_token1(2).token_name  := 'MODEL';
            l_token1(2).token_value := v_model_item_name ;

             cto_msg_pub.cto_message('BOM','CTO_OVERLAP_DATE_ERROR');
         end loop ;

         raise fnd_api.g_exc_error;

     end if ;

   end if;



   /* end Check for Overlapping Effectivity Dates */










	lStmtNumber := 560;

	/*Flushing the temp table*/
	DELETE  /*+ INDEX (BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11 ) */
        from bom_explosion_temp
	WHERE 	bill_sequence_id = pConfigBillId;

	return(1);

EXCEPTION
      	when no_data_found then
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNumber);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: No data found error in Inherit_Op_Seq_Ml::'||to_char(lStmtNumber)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
        	return(0);
      	when others then
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNumber)||':'||substrb(sqlerrm,1,150);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Inherit_Op_Seq_Ml::'||to_char(lStmtNumber)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
        	return(0);
END inherit_op_seq_ml;


/*-----------------------------------------------------------------+
  Name : check_bom
         Check to see if the BOM exists for the item in the
         specified org.
+------------------------------------------------------------------*/
FUNCTION check_bom(
        pItemId        in      number,
        pOrgId         in      number,
        xBillId        out  NOCOPY   number)
RETURN INTEGER
IS


BEGIN

    xBillId := 0;

    WriteToLog('Check_bom:Before check_bom sql::xBillId:: '||to_char(xBillId ), 5);

    select bill_sequence_id
    into   xBillId
    from   bom_bill_of_materials
    where  assembly_item_id = pItemId
    and    organization_id  = pOrgId
    and    alternate_bom_designator is null;

    WriteToLog('Check_bom:After check_bom sql::xBillId:: '||to_char(xBillId )||'returning 1', 5);

    return(1);

EXCEPTION

    when no_data_found then
	WriteToLog('BOM not found.', 4);
    	return(0);

    when others then
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	WriteToLog('ERROR: Others error in Check_BOM::'||sqlerrm,1);
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	return(0);

END CHECK_BOM;


/*-----------------------------------------------------------------+
  Name : get_model_lead_time
+------------------------------------------------------------------*/

FUNCTION get_model_lead_time
(       pModelId in number,
        pOrgId   in number,
        pQty     in number,
        pLeadTime out NOCOPY number,
        pErrBuf  out NOCOPY varchar2
)
RETURN INTEGER

IS

   lStmtNum number;

begin
   WriteToLog('Getting Lead Time for Model: ' || to_char(pModelId), 4);
   lStmtNum := 100;

   select (ceil(nvl(msi.fixed_lead_time,0)
               +  nvl(msi.variable_lead_time,0) * pQty))
   into    pLeadTime
   from    mtl_system_items msi
   where   inventory_item_id = pModelId
   and     organization_id = pOrgId;

   WriteToLog('Lead Time: ' || to_char(pLeadtime), 4);

   return 1;

EXCEPTION

WHEN others THEN
       	pErrBuf := 'CTOCBOMB: ' || lStmtNum || substrb(SQLERRM,1,150);
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	WriteToLog('ERROR: Others error in Get_Model_Lead_Time::'||to_char(lStmtNum)||sqlerrm,1);
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
       	return 0;

END get_model_lead_time;

/*-----------------------------------------------------------------+
  Name : bmlggpn_get_group_name
+------------------------------------------------------------------*/

FUNCTION bmlggpn_get_group_name
(       group_id        number,
        group_name      out nocopy varchar2,
        err_buf         out nocopy varchar2
)
RETURN INTEGER
is
max_seg         number;
lStmtNum	number;
type segvalueType is table of varchar2(30)
        index by binary_integer;
seg_value       segvalueType;
segvalue_tmp    varchar2(30);
segnum_tmp      number;
catseg_value    varchar2(240);
delimiter       varchar2(10);
profile_setting varchar2(30);
CURSOR profile_check IS
	select nvl(substr(profile_option_value,1,30),'N')
	from fnd_profile_option_values val,fnd_profile_options op
	where op.application_id = 401
	and   op.profile_option_name = 'USE_NAME_ICG_DESC'
	and   val.level_id = 10001  /* This is for site level  */
        and   val.application_id = op.application_id
	and   val.profile_option_id = op.profile_option_id;
begin
	/* First lets get the value for profile option USE_NAME_ICG_DESC
	** If this is 'N' we need to use the description
	** If this is 'Y' then we need to use the group name
	** We are going to stick with group name if the customer is
	** not on R10.5, which means they do not have the profile
	** If they have R10.5 then we are going to use description
	** because that is what inventory is going to do.
	** Remember at the earliest we should get rid of this function
	** and call INV API. Remember we at ATO are not in the business
	** of duplicating code of other teams
	*/

	profile_setting := 'Y';

	lStmtNum :=250;
	OPEN profile_check;
	FETCH profile_check INTO profile_setting;
	IF profile_check%NOTFOUND THEN
	profile_setting := 'Y';
	END IF;

       	WriteToLog('Bmlggpn_get_group_name: use_name_icg_desc :'|| profile_setting, 5);

   if profile_setting = 'Y' then

	/* Let us select the catalog group name from mtl_catalog_groups
	** At some point in time we need to call the inventory function
	** to do this, so we can centralize this stuff
	*/
	lStmtNum :=260;

	SELECT MICGK.concatenated_segments
	INTO group_name
        FROM mtl_item_catalog_groups_kfv MICGK
        WHERE MICGK.item_catalog_group_id = group_id;

   else
	lStmtNum :=270;
	/* This is to get the description of the catalog */
        SELECT MICG.description
	INTO group_name
        FROM mtl_item_catalog_groups MICG
        WHERE MICG.item_catalog_group_id = group_id;

   end if;
        return(0);
EXCEPTION
        when others then
                err_buf := 'CTOCBOMB: ' || lStmtNum || substrb(SQLERRM,1,150);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Bmlggpn_Get_Group_Name::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
                return(SQLCODE);
END bmlggpn_get_group_name;


/*-----------------------------------------------------------------+
   Name :  bmlupid_update_item_desc
+------------------------------------------------------------------*/

FUNCTION bmlupid_update_item_desc
(
        item_id                 NUMBER,
        org_id                  NUMBER,
        err_buf         out   nocopy VARCHAR2
)
RETURN INTEGER
IS
        /*
        ** Create cursor to retrieve all descriptive element values for the item
        */
        CURSOR cc is
                select element_value
                from mtl_descr_element_values
                where inventory_item_id = item_id
                and element_value is not NULL
		and default_element_flag = 'Y'
                order by element_sequence;

        delimiter       varchar2(10);
        e_value         varchar2(30);
        cat_value       varchar2(240);
        idx             number;
        group_id        number;
        group_name      varchar2(240);		-- bugfix 2483982: increased the size from 30 to 240
        lStmtNum        number;
        status          number;
        INV_GRP_ERROR   exception;
begin
        lStmtNum := 280;
       	WriteToLog('bmlupid_update_item_desc: ' || '  In bmlupid_update_item_desc ',2);

        select concatenated_segment_delimiter into delimiter
        from fnd_id_flex_structures
        where id_flex_code = 'MICG'
	and   application_id = 401;

        lStmtNum := 285;
        select item_catalog_group_id into group_id
        from mtl_system_items
        where inventory_item_id = item_id
        and organization_id = org_id;

       	WriteToLog('Bmlupid_update_item_desc:item_catalog_group_id : ' || group_id, 4);

        idx := 0;
        cat_value := '';
        open cc;
        loop
                fetch cc into e_value;
                exit when (cc%notfound);

                if idx = 0 then
                        lStmtNum := 290;
                        status := bmlggpn_get_group_name(group_id,group_name,
							  err_buf);
                        if status <> 0 then
                        	raise INV_GRP_ERROR;
                        end if;
                        cat_value := group_name || delimiter || e_value;
                else
                  lStmtNum := 295;
		  cat_value := cat_value || SUBSTRB(delimiter || e_value,1,
			240-LENGTHB(cat_value));
                end if;
               	WriteToLog('Bmlupid_update_item_desc:cat_value :' || cat_value, 4);
                idx := idx + 1;
        end loop;
	close cc;

        if idx <> 0 then
                update mtl_system_items
                set description = cat_value
                where inventory_item_id = item_id;
                /*and organization_id = org_id;		Bugfix 2163311 */
        /* start bugfix 1845141 */
                update mtl_system_items_tl
                set description = cat_value
                where inventory_item_id = item_id;
                /*and organization_id = org_id;		Bugfix 2163311 */
       /* end bugfix 1845141 */
        end if;

        return(0);

EXCEPTION
        when INV_GRP_ERROR then
                err_buf := 'CTOCBOMB: Invalid catalog group for the item ' || item_id || ' status:' || status;
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Invalid catalog group for the item::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
                return(1);

        when OTHERS then
                err_buf := 'CTOCBOMB: ' || lStmtNum ||substrb(SQLERRM,1,150);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('ERROR: Others error in Bmlupid_Update_Item_Desc::'||to_char(lStmtNum)||sqlerrm,1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
                return(1);

END  bmlupid_update_item_desc;


/*-------------------------------------------------+
   check_routing :
   Checks the existence of routing of an assembly
   in an org. If routing exists, returns 1 and
   otherwise returns 0
+-------------------------------------------------*/

FUNCTION check_routing (
        pItemId        in      number,
        pOrgId         in      number,
        xRtgId         out nocopy     number,
        xRtgType       out nocopy     number)
RETURN INTEGER
IS


BEGIN

    xRtgId := 0;
    xRtgType := 0;

    select routing_sequence_id,
           NVL(cfm_routing_flag,2)
    into   xRtgId,
           xRtgType
    from   bom_operational_routings
    where  assembly_item_id = pItemId
    and    organization_id  = pOrgId
    and    alternate_routing_designator is null;

    return (1);

EXCEPTION

    when no_data_found then
	WriteToLog('Routing does not exist.', 4);
    	return (0) ;

    when others then
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	WriteToLog('ERROR: Others error in Check_Routing::'||sqlerrm,1);
	WriteToLog('++++++++++++++++++++++++++++++++++++++++++++++++', 1);
	return (0) ;

END check_routing;

END CTO_UPDATE_BOM_RTG_PK;

/
