--------------------------------------------------------
--  DDL for Package Body CTO_UPDATE_ITEMS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_UPDATE_ITEMS_PK" as
/* $Header: CTOUITMB.pls 120.7.12010000.8 2012/04/19 10:18:44 ntungare ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : CTOUPDIB.pls
| DESCRIPTION :
|
| HISTORY     : Created On : 	11-OCT-2003	Sajani Sheth
|
|               Modified   :    02-MAR-2004     Sushant Sawant
|                                               Fixed Bug 3472654
|                                               upgrades for matched config from CIB = 1 or 2 to 3 were not performed properly.
|                                               data was not transformed to bcmo.
|                                               perform_match check includes 'Y' and 'U'
|
|
|                              03-15-2004       Kiran Konada
|                                                3504153
|
|                                                Propagated fix 3340844 from CTOCITMB
|                                                Populate value revision_label into mtl_item_revisions_b
|                                                removed the join to distinct and join on bcso
|
|                                                Propagated fix 3338108  from CTOCITMB.pls
|                                                Populate revision_id by making a join to
|                                                mtl_item_revisions_b
|
|
|                              04-19-2004       Sushant Sawant
|                                               Fixed bug  3576040
|
|                              07-SEP-2004      Kiran Konada
|                                               bugfix 3877097
|                                               at lStmtNumber := 40,60,70,80
|                                               during the insert into cst_item_costs and
|                                               cst_item_cost_details
|                                               mp1.cost_organization_id was being inserted
|                                               BUT the NOT EXISTS condition was checking
|                                               for mp1.organization_id.
|                                               Fixed the above problem by using
|                                               mp1.cost_organization_id in NOT EXISTS condition
|                                               Code review has been done by Sushant
|
|              Modified on 18-APR-2005 By Sushant Sawant
|                                         Fixed Bug#4172300
|                                         Cost in validation org is not copied properly from model to config item.
|
|
|             Modified on  08-Aug-2005 by Kiran Konada
|                                      bug# 4539578
|                                      In R12, mtl_cross_references datamodel has been changed to
|				       mtl_cross_references_b and mtl_cross_references_tl
|
|
|             Modified on 22-Sep-2005  Renga Kannan
|                                      Made Code changes for ATG Performance
|                                      Project
|
|
|             Modified on 08-Nov-2005  Kiran Konada
|				       bug#4574899
|                                      Insert default data into New R12 item attributes
|
|
|             Modified on 03-Feb-2006  Kiran Konada
|                                      FP bugfix 4861996
|	                               added condition ic1.category_set_id = ic.category_set_id
*============================================================================*/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

g_atp_flag varchar2(1) := 'N' ;
gUserId number := nvl(Fnd_Global.USER_ID, -1);
gLoginId number := nvl(Fnd_Global.LOGIN_ID, -1);

TYPE ATTRIB_NAME_TAB_TYPE is table of mtl_item_attributes.attribute_name%type index by binary_integer ;

TYPE CONTROL_LEVEL_TAB_TYPE is table of mtl_item_attributes.control_level%type index by binary_integer ;

g_attribute_name_tab    ATTRIB_NAME_TAB_TYPE ;
g_control_level_tab     CONTROL_LEVEL_TAB_TYPE ;

/***************************************************************************
This procedure is called by CTO_Update_Configs_PK.Update_Configs to update itemsand sourcing for configurations in bcol_upg.
It does the following:
	1. Refreshes bcso/bcmo for all ato_line_ids in bcol_upg
	2. Create ACC items
	3. Create PC items (with special logic for attribute control)
	4. Creates item data
	--- Added by Renga Kannan on 01/23/04
	5. A new parameter p_upgrade_mode is added to this procedure. This is to update the
	   atp attributes on the existing configs.
***************************************************************************/
PROCEDURE Update_Items_And_Sourcing(
	p_changed_src IN varchar2,
	p_cat_id IN number,
	p_upgrade_mode IN Number,
	--Bugfix 10240482: Adding new parameter p_max_seq
	p_max_seq IN number,
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2)
IS

CURSOR c_lines(l_seq number) IS
select /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
distinct ato_line_id, program_id -- , perform_match
from bom_cto_order_lines_upg
where sequence = l_seq
and status = 'UPG';

CURSOR c_configs(l_ato_line_id number) IS
select substrb(concatenated_segments,1,50) config_name
from bom_cto_order_lines_upg bcolu,
mtl_system_items_kfv msi
where bcolu.ato_line_id = l_ato_line_id
and bcolu.config_item_id is not null
and bcolu.config_item_id = msi.inventory_item_id
and bcolu.ship_from_org_id = msi.organization_id;

CURSOR c_src_lines(l_seq number) IS
select /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
distinct ato_line_id, program_id
from bom_cto_order_lines_upg
where sequence = l_seq
and status = 'ITEM';

CURSOR c_copy_src_rules(p_ato_line_id number) IS
select bcso.rcv_org_id,
	bcso.organization_id,
	bcolu.config_creation,
	bcso.create_src_rules,
	bcso.model_item_id,
	bcso.config_item_id
from bom_cto_order_lines_upg bcolu,
	bom_cto_src_orgs bcso
where bcolu.ato_line_id = p_ato_line_id
and bcolu.bom_item_type = '1'
and nvl(bcolu.wip_supply_type, 1) <> 6
and bcolu.option_specific = 'N'
and bcolu.line_id = bcso.line_id;

--Bugfix 1024082
--l_seq number := 0;
lStmtNum number;
l_exists number;
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_status number;
l_stmt_num number := 0;
l_hold_result_out varchar2(30);
l_index number;
l_order_number number;

v_lines_perform_match varchar2(1);

--
-- bug 13051516
--
TYPE COPY_SRC_RULES_CACHE_TYP IS TABLE OF NUMBER INDEX BY VARCHAR2(32767);
COPY_SRC_RULES_CACHE COPY_SRC_RULES_CACHE_TYP ;

BEGIN

WriteToLog('Entering create_items_and_sourcing', 1);
xReturnStatus := FND_API.G_RET_STS_SUCCESS;

--
-- Call OSS processing
-- Populate / refresh bcso for all lines in bcol_upg
-- Create sourcing in CTO assignment set for these lines
--

--Bugfix 10240482: Changing the way sequence is used
--WHILE (TRUE) LOOP
for l_seq in 1..p_max_seq loop
	--
	-- Process all lines for each unique sequence
	--

	--Bugfix 10240482
	--l_seq := l_seq + 1;
	WriteToLog('Update_Items_And_Sourcing: l_seq:'|| l_seq, 1);

	BEGIN
	select 1
	into l_exists
	from bom_cto_order_lines_upg
	where sequence = l_seq
	and rownum = 1;

	EXCEPTION
	WHEN no_data_found THEN
	  --Bugfix 10240482
	  --exit;
	  WriteToLog('Update_Items_And_Sourcing: No_Data_Found for l_seq:'|| l_seq, 1);
	  goto end_loop1;

	END;

	FOR v_lines IN c_lines(l_seq) LOOP

		--
		-- Call OSS processing.
		--

		WriteToLog('Changed sourcing, processing OSS configs', 2);

		CTO_OSS_SOURCE_PK.PROCESS_OSS_CONFIGURATIONS(
			p_ato_line_id => v_lines.ato_line_id,
			p_mode => 'UPG',
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data);

                --  Bugfix 13362916
                --  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			WriteToLog('ERROR: Process oss configurations returned with exp error',1);

                        --Bugfix 6376208: Not all upgrade cases will be present on SO lines. Handle the NDF
                        begin

                        select oeh.order_number
			into l_order_number
			from oe_order_lines_all oel,
			oe_order_headers_all oeh
			where oel.line_id = v_lines.ato_line_id
			and oel.header_id = oeh.header_id;

                        exception
                        when no_data_found then
                                l_order_number := -99;
                        end;
                        --end Bugfix 6376208

			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);
			WriteToLog('ERROR: Order number '||l_order_number, 1);

			FOR v_configs IN c_configs(v_lines.ato_line_id) LOOP
				WriteToLog('ERROR: Configuration item '||v_configs.config_name, 1);
			END LOOP;

			lstmtnum := 20;
			FOR l_index IN 1..nvl(l_msg_count,1) LOOP
				lstmtnum := 20;
    				l_msg_data := fnd_msg_pub.get(
                      			p_msg_index => l_index,
                      			p_encoded  => FND_API.G_FALSE);
				lstmtnum := 30;
    				WriteToLog('Error : '||substr(l_msg_data,1,250), 1);
 			END LOOP;
			lstmtnum := 40;
			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);

			update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                        bom_cto_order_lines_upg
			set status = 'ERROR'
			where ato_line_id = v_lines.ato_line_id;

			WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
			GOTO SKIP;
			--raise FND_API.G_EXC_ERROR;
                /* Bugfix 13362916
		ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			WriteToLog('ERROR: Process_oss_configurations returned with unexp error',1);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
                */
		END IF;

		--
		-- Refresh bcso, create src for each ato_line_id
		-- Update status to 'BCSO'
		-- Sourcing will always be refreshed, irrespective of the
		-- parameter p_changed_src. This is to account for the new
		-- way in which we populate bcso_b, bcmo.
		--
		WriteToLog('Refresh bcso:: l_seq:: '||to_char(l_seq), 4);
		WriteToLog('Refresh bcso:: ato_line_id:: '||v_lines.ato_line_id, 4);

		--
		-- Delete from bcso_b
		--
		delete from bom_cto_src_orgs_b
		where line_id in
			(select /* INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4 BOM_CTO_ORDER_LINES_UPG_N2 ) */
                        line_id
			from bom_cto_order_lines_upg
			where ato_line_id = v_lines.ato_line_id
			and config_item_id is not null
			and status = 'UPG');
		WriteToLog('Lines deleted from bcso_b::'||sql%rowcount, 2);

		--
		-- delete from bcmo
		--
		delete from bom_cto_model_orgs
		where config_item_id in
			(select /* INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4 BOM_CTO_ORDER_LINES_UPG_N2 ) */
                        distinct config_item_id
			from bom_cto_order_lines_upg
			where ato_line_id = v_lines.ato_line_id
			and status = 'UPG');

		WriteToLog('Lines deleted from bcmo::'||sql%rowcount, 2);

		--
		-- populating bcso_b and bcmo with changed sourcing
		--
		l_status := CTO_MSUTIL_PUB.populate_src_orgs_upg(
				v_lines.ato_line_id,
				l_return_status,
				l_msg_count,
				l_msg_data);

		-- Bugfix 13362916
                -- IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
 	                WriteToLog('ERROR: Populate_src_orgs_upg returned with status:' || l_return_status, 1);

                        -- Bugfix 13362916
                        BEGIN
                           select oeh.order_number
                             into l_order_number
                           from oe_order_lines_all oel,
                                oe_order_headers_all oeh
                           where oel.line_id = v_lines.ato_line_id
                             and oel.header_id = oeh.header_id;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                           l_order_number := -99;
 	                END;

			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);
			WriteToLog('ERROR: Order number '||l_order_number, 1);

			FOR v_configs IN c_configs(v_lines.ato_line_id) LOOP
				WriteToLog('ERROR: Configuration item '||v_configs.config_name, 1);
			END LOOP;

			FOR l_index IN 1..nvl(l_msg_count,1) LOOP
    				l_msg_data := fnd_msg_pub.get(
                      			p_msg_index => l_index,
                      			p_encoded  => FND_API.G_FALSE);
    				WriteToLog('Error : '||substr(l_msg_data,1,250), 1);
 			END LOOP;
			lstmtnum := 40;
			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);

			update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                        bom_cto_order_lines_upg
			set status = 'ERROR'
			where ato_line_id = v_lines.ato_line_id;

			WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
			GOTO SKIP;
			--raise FND_API.G_EXC_ERROR;
                -- Bugfix 13362916
                /*
		ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			WriteToLog('ERROR: Populate_src_orgs_upg returned with unexp error',1);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
                */
		END IF;

		WriteToLog('After populate_src_orgs_upg:: seq::'||to_char(l_seq), 4);


               /*
               begin
               select perform_match into v_lines_perform_match
                 from bom_cto_order_lines_upg
               where line_id = v_lines.ato_line_id ;

               exception
               when others then
                  v_lines_perform_match := 'N' ;
               end ;
               */


               /* Bugfix 3472654 */
               /*
               if( v_lines_perform_match in(  'Y' , 'U') ) then

		WriteToLog('populate_src_orgs_upg:: perform match Y, Should call update_bcso  ' , 4);

                */


		--
		-- Updating bcso_b for other order lines having same config
		--
		Update_Bcso(
			v_lines.ato_line_id,
			l_return_status,
			l_msg_count,
			l_msg_data);

		-- Update_Bcso only returns unexp errors
		IF (l_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
                        WriteToLog('Update_bcso returned with unexpected error', 1);
                        --Bugfix 13362916
                        WriteToLog('Skipping ato_line_id:' || v_lines.ato_line_id, 1);
                        --raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        GOTO SKIP;
                END IF;

                /*
                else

		WriteToLog('populate_src_orgs_upg:: perform match N, No need to call update_bcso  ' , 4);

                end if ;
                */



		<<SKIP>>
		EXIT WHEN c_lines%NOTFOUND;
	END LOOP; /* c_lines */

	update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
        bom_cto_order_lines_upg
	set status = 'BCSO'
	where sequence = l_seq
	and status = 'UPG';

	WriteToLog('Lines updated to status BCSO:: '||sql%rowcount, 1);

	<<end_loop1>>
	null;

END LOOP;

WriteToLog('After refresh bcso', 4);


-- Update the atp attributes for the configuration in the existing orgs.
-- Added By Renga on 01/23/04

If p_upgrade_mode = 2 Then
   WriteToLog('Updating ATP attributes for configs in existing orgs');

   update mtl_system_items_b msic
   set    (msic.atp_components_flag,msic.atp_flag) = (select CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(msim.atp_flag,
										    msim.atp_components_flag),CTO_CONFIG_ITEM_PK.get_atp_flag
  			                 from  mtl_system_items_b msim
				         where msim.inventory_item_id = msic.base_item_id
  				         and   msim.organization_id   = msic.organization_id)
   where  msic.inventory_item_id in
               (
                select distinct config_item_id
                from   bom_cto_order_lines_upg
                where  status = 'BCSO'
		and    config_item_id is not null
               )
   and   exists (select 'x'
                 from mtl_system_items_b msim1
                 where msim1.inventory_item_id = msic.base_item_id
                 and   msim1.organization_id = msic.organization_id);

   WriteToLog('Number of Configs updated for ATP attributes ='||sql%rowcount);
End if;
-- End of addition by Renga

--
-- Create all auto-created items
-- Update status to 'ITEM'
--

Update_Acc_Items(
	l_return_status,
	l_msg_count,
	l_msg_data);

-- Update_Acc_Items only returns unexp errors
IF (l_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
	WriteToLog('Update_Acc_Items returned with unexpected error', 1);
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--
-- Create all pre-configured items
-- Update status to 'ITEM'
--

Update_Pc_Items(
	l_return_status,
	l_msg_count,
	l_msg_data);

-- Update_Pc_Items only returns unexp errors
IF (l_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
	WriteToLog('Update_Acc_Items returned with unexpected error', 1);
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--
-- create data for items in child tables
--
Update_Item_Data(
	nvl(p_cat_id, -99),
	l_return_status,
	l_msg_count,
	l_msg_data);

IF (l_return_status = fnd_api.G_RET_STS_ERROR) THEN
	WriteToLog('Update_Item_Data returned with expected error', 1);
	raise FND_API.G_EXC_ERROR;
ELSIF (l_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
	WriteToLog('Update_Item_Data returned with unexpected error', 1);
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--
-- Update status to 'ITEM'
--
update /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
bom_cto_order_lines_upg
set status = 'ITEM'
where status = 'BCSO';

WriteToLog('Items created. Status updated to ITEM for rows::'||sql%rowcount, 1);
--
-- Create sourcing rules in CTO assignment set
--

--Bugfix 10240482
--l_seq := 0;
--WHILE (TRUE) LOOP
for l_seq in 1..p_max_seq loop
	--
	-- Process all lines for each unique sequence
	--

	--Bugfix 10240482
	--l_seq := l_seq + 1;
	WriteToLog('Update_Items_And_Sourcing: l_seq:'|| l_seq, 1);

	BEGIN
	select 1
	into l_exists
	from bom_cto_order_lines_upg
	where sequence = l_seq
	and rownum = 1;

	EXCEPTION
	WHEN no_data_found THEN
	  --Bugfix 10240482
	  --exit;
	  WriteToLog('Update_Items_And_Sourcing: No_Data_Found for l_seq:'|| l_seq, 1);
	  goto end_loop2;

	END;

	FOR v_lines IN c_src_lines(l_seq) LOOP
		--
		-- Do not need to check for holds, as we are picking up
		-- lines in status 'ITEM' only
		--

		WriteToLog('Changed sourcing, creating OSS rules', 2);

		CTO_OSS_SOURCE_PK.create_oss_sourcing_rules
			(p_ato_line_id => v_lines.ato_line_id,
			p_mode 	=> 'UPG',
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
                        p_changed_src => p_changed_src );

	        -- bug 13362916
                --
		-- IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			WriteToLog('ERROR: Create_oss_sourcing_rules returned with status:' || l_return_status,1);

		        -- bug 13362916
                        BEGIN
                           select oeh.order_number
                             into l_order_number
                           from oe_order_lines_all oel,
                                oe_order_headers_all oeh
                           where oel.line_id = v_lines.ato_line_id
                             and oel.header_id = oeh.header_id;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                                     l_order_number := -99;
                        END;

			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);
			WriteToLog('ERROR: Order number '||l_order_number, 1);

			FOR v_configs IN c_configs(v_lines.ato_line_id) LOOP
				WriteToLog('ERROR: Configuration item '||v_configs.config_name, 1);
			END LOOP;

			FOR l_index IN 1..nvl(l_msg_count,1) LOOP
    				l_msg_data := fnd_msg_pub.get(
                      			p_msg_index => l_index,
                      			p_encoded  => FND_API.G_FALSE);
    				WriteToLog('Error : '||substr(l_msg_data,1,250), 1);
 			END LOOP;
			lstmtnum := 40;
			WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);

			update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                        bom_cto_order_lines_upg
			set status = 'ERROR'
			where ato_line_id = v_lines.ato_line_id;

			WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
			GOTO SKIP2;
			--raise FND_API.G_EXC_ERROR;
                -- 13362916
                /*
		ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			WriteToLog('ERROR: Create_oss_sourcing_rules returned with unexp error',1);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
                */
		END IF;

                --debugging for bug 13029577
 	        WriteToLog('++++++++++++++++++++++++++++++++++++++++++');
 	        WriteToLog('printing bcso values');
                FOR v_src_rule IN c_copy_src_rules(v_lines.ato_line_id) LOOP
                    WriteToLog('model::' || v_src_rule.model_item_id ||
 	                       '::config::' || v_src_rule.config_item_id ||
 	                       '::rcv_org::' || v_src_rule.rcv_org_id ||
 	                       '::org::' || v_src_rule.organization_id ||
 	                       '::cib::' || v_src_rule.config_creation ||
 	                       '::src::' || v_src_rule.create_src_rules);
 	        END LOOP;
 	        WriteToLog('++++++++++++++++++++++++++++++++++++++++++');
 	        --end debugging for bug 13029577

 	        --
 	        -- bug 13029577
 	        --
 	        COPY_SRC_RULES_CACHE.delete;

                FOR v_src_rule IN c_copy_src_rules(v_lines.ato_line_id) LOOP
                   --
                   -- bug 13051516
                   --
                   IF COPY_SRC_RULES_CACHE.EXISTS(v_src_rule.model_item_id||'-'||v_src_rule.config_item_id||'-'||v_src_rule.rcv_org_id) = FALSE THEN
                      COPY_SRC_RULES_CACHE(v_src_rule.model_item_id||'-'||v_src_rule.config_item_id||'-'||v_src_rule.rcv_org_id) := 1;

                        --
                        -- Call API to copy sourcing rules from model item
                        -- to config item.
                        -- Copy sourcing rules only if sourcing has changed
                        --
                        IF (v_src_rule.create_src_rules='Y' AND  v_src_rule.config_creation in (1, 2) AND p_changed_src = 'Y') THEN
                            WriteToLog ('Copying src rule for cfg item::'                                   ||to_char(v_src_rule.config_item_id)||' in org::'||
                                    to_char(v_src_rule.organization_id), 4);

                            CTO_MSUTIL_PUB.Create_Sourcing_Rules(
                                    pModelItemId    => v_src_rule.model_item_id,
                                    pConfigId       => v_src_rule.config_item_id,
                                    pRcvOrgId       => v_src_rule.rcv_org_id,
                                    p_mode          => 'UPGRADE',
                                    x_return_status => l_return_status,
                                    x_msg_count     => l_msg_count,
                                    x_msg_data      => l_msg_data);

                            -- Bugfix 13362916
                            -- IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                    WriteToLog('ERROR: Create_sourcing_rules returned with status:' || l_return_status,1);

                                    -- bug 13362916
                                    BEGIN
                                       select oeh.order_number
                                         into l_order_number
                                       from oe_order_lines_all oel,
                                            oe_order_headers_all oeh
                                       where oel.line_id = v_lines.ato_line_id
                                         and oel.header_id = oeh.header_id;
                                    EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
 	                                 l_order_number := -99;
                                    END;

                                    WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);
                                    WriteToLog('ERROR: Order number '||l_order_number, 1);

                                    FOR v_configs IN c_configs(v_lines.ato_line_id) LOOP
                                            WriteToLog('ERROR: Configuration item '||v_configs.config_name, 1);
                                    END LOOP;

                                    FOR l_index IN 1..nvl(l_msg_count,1) LOOP
                                            l_msg_data := fnd_msg_pub.get(
                                                    p_msg_index => l_index,
                                                    p_encoded  => FND_API.G_FALSE);
                                            WriteToLog('Error : '||substr(l_msg_data,1,250), 1);
                                    END LOOP;
                                    WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);

                                    update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                                    bom_cto_order_lines_upg
                                    set status = 'ERROR'
                                    where ato_line_id = v_lines.ato_line_id;

                                    WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
                                    GOTO SKIP2;
                            -- Bug 13362916
                            /*
                            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                    WriteToLog('ERROR: Create_sourcing_rules returned with unexp error',1);
                                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            */
                            END IF;
                        ELSIF (v_src_rule.config_creation = 3 ) THEN
                            --
                            -- Always copy sourcing rules if config_creation is 3
                            --
                            WriteToLog ('Copying src rule for cfg item:: '
                                    ||to_char(v_src_rule.config_item_id)||' in org:: '||
                                    to_char(v_src_rule.organization_id), 4);

                            CTO_MSUTIL_PUB.Create_TYPE3_Sourcing_Rules(
                                    pModelItemId    => v_src_rule.model_item_id,
                                    pConfigId       => v_src_rule.config_item_id,
                                    pRcvOrgId       => v_src_rule.organization_id,
                                    p_mode          => 'UPGRADE',
                                    x_return_status => l_return_status,
                                    x_msg_count     => l_msg_count,
                                    x_msg_data      => l_msg_data);

                            -- bug 13362916
                            -- IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                    WriteToLog('ERROR: Create_type3_sourcing_rules returned with status:' || l_return_status, 1);

                                    -- bug 13362916
                                    BEGIN
                                       select oeh.order_number
                                         into l_order_number
                                       from oe_order_lines_all oel,
                                            oe_order_headers_all oeh
                                       where oel.line_id = v_lines.ato_line_id
                                         and oel.header_id = oeh.header_id;
                                    EXCEPTION
				       WHEN no_data_found then
                                           l_order_number := -99;
				    END;

                                    WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);
                                    WriteToLog('ERROR: Order number '||l_order_number, 1);

                                    FOR v_configs IN c_configs(v_lines.ato_line_id) LOOP
                                            WriteToLog('ERROR: Configuration item '||v_configs.config_name, 1);
                                    END LOOP;

                                    FOR l_index IN 1..nvl(l_msg_count,1) LOOP
                                            l_msg_data := fnd_msg_pub.get(
                                                    p_msg_index => l_index,
                                                    p_encoded  => FND_API.G_FALSE);
                                            WriteToLog('Error : '||substr(l_msg_data,1,250), 1);
                                    END LOOP;
                                    WriteToLog('++++++++++++++++++++++++++++++++++++++++++', 1);

                                    update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4) */
                                    bom_cto_order_lines_upg
                                    set status = 'ERROR'
                                    where ato_line_id = v_lines.ato_line_id;

                                    WriteToLog('Rows updated to status ERROR::'||sql%rowcount, 1);
                                    GOTO SKIP2;
                            -- Bug 13362916
                            /*
                            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                                    WriteToLog('ERROR: Create_type3_sourcing_rules returned with unexp error',1);
                                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            */
                          END IF;
                       END IF;
                    END IF;
                END LOOP; /* c_copy_src_rules */
		<<SKIP2>>
		EXIT WHEN c_src_lines%NOTFOUND;
	END LOOP; /* c_src_lines */

	update /*+ INDEX( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
        bom_cto_order_lines_upg
	set status = 'CTO_SRC'
	where sequence = l_seq
	and status = 'ITEM';

	WriteToLog('Lines updated to status CTO_SRC:: '||sql%rowcount, 1);

	<<end_loop2>>
	null;

END LOOP;

WriteToLog('After create sourcing rules', 2);

EXCEPTION
	when NO_DATA_FOUND then
		WriteToLog('ERROR: NDF in Update_Items_and_Sourcing::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		cto_msg_pub.count_and_get
          		( p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		--return(0);

	when FND_API.G_EXC_ERROR then
		WriteToLog('ERROR: Expected error in Update_Items_and_Sourcing::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		cto_msg_pub.count_and_get
          		( p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_ERROR;
		--return(0);

	when FND_API.G_EXC_UNEXPECTED_ERROR then
		WriteToLog('ERROR: Unxpected error in Update_Items_and_Sourcing::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		--return(0);

	when OTHERS then
		WriteToLog('ERROR: Others error in Update_Items_and_Sourcing::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		cto_msg_pub.count_and_get
          		(  p_msg_count => xMsgCount
           		, p_msg_data  => xMsgData
           		);
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
		--return(0);

END Update_Items_And_Sourcing;


PROCEDURE Update_Bcso(
	p_ato_line_id IN number,
	l_return_status OUT NOCOPY varchar2,
	l_msg_count OUT NOCOPY number,
	l_msg_data OUT NOCOPY varchar2)
IS

        --new cursor for bulk fetch (bug 10307286)
        CURSOR c_line_info IS
        select distinct
               bcmo.group_reference_id,
               bcmo.model_item_id,
               bcso.line_id,
               bcso.top_model_line_id,
               bcso.config_item_id
        from bom_cto_model_orgs bcmo,
             bom_cto_src_orgs_b bcso
         where bcso.config_item_id  = bcmo.config_item_id and
               bcso.config_item_id in (select /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4 ) */
                                        distinct config_item_id
                                       from bom_cto_order_lines_upg
                                        where ato_line_id = p_ato_line_id and
                                              nvl(config_creation, 1) = 3 and
                                              config_item_id is not null  and
                                              status = 'UPG'              and
                                              nvl(perform_match, 'N')IN ('Y','U'));


        lStmtNum number;
        v_group_reference_id number;
        v_model_item_id number;

        --bug 10307286
        TYPE line_id_rec is RECORD (group_reference_id number,
                                    model_item_id number,
                                    line_id            number,
                                    top_model_line_id  number,
                                    config_item_id  number
                                    );

        TYPE line_id_rec_tab_typ is TABLE OF line_id_rec INDEX BY BINARY_INTEGER;
        line_id_rec_tab line_id_rec_tab_typ;

BEGIN

	--
	-- 1. Identify each config for this ato_line_id having attribute 3
	-- 2. For each config, identify all order lines
	-- 3. For each order line, delete sourcing from bcso for this config
	-- and insert line referencing bcmo.
	--
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	lStmtNum := 10;
	WriteToLog('Entering update_bcso', 3);

        --new bulk fetch for bug 10307286 (begin)
        OPEN c_line_info;
        FETCH c_line_info BULK COLLECT INTO line_id_rec_tab;
        CLOSE c_line_info;

        lStmtNum := 20;
        WriteToLog('Fecthed records from c_line_info count is :'||line_id_rec_tab.count, 3);

        DELETE from bom_cto_src_orgs_b
           where (line_id) IN (select distinct bcso.line_id
                                from bom_cto_src_orgs_b bcso
                               where bcso.config_item_id in (select /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4 ) */
                                                                distinct config_item_id
                                                              from bom_cto_order_lines_upg
                                                              where ato_line_id = p_ato_line_id
                                                                and nvl(config_creation, 1) = 3
                                                                and config_item_id is not null
                                                                and status = 'UPG'
                                                                and nvl(perform_match, 'N') IN ('Y','U')));

        WriteToLog('Deleted data from bom_cto_src_orgs_b count is :'||sql%rowcount, 3);


        lStmtNum := 30;
        FORALL cntr in 1..line_id_rec_tab.COUNT
         insert into bom_cto_src_orgs_b
                        (
                        top_model_line_id,
                        line_id,
                        group_reference_id,
                        model_item_id,
                        rcv_org_id,
                        organization_id,
                        create_bom,
                        cost_rollup,
                        organization_type, -- Used to store the source type
                        config_item_id,
                        create_src_rules,
                        rank,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        program_application_id,
                        program_id,
                        program_update_date
                        )
                Values (
                        line_id_rec_tab(cntr).top_model_line_id, -- p_ato_line_id ,
                        line_id_rec_tab(cntr).line_id,
                        line_id_rec_tab(cntr).group_reference_id,
                        line_id_rec_tab(cntr).model_item_id,
                        null,
                        -1,             -- organization_id is -1 for type3 matched
                        null,           -- create_bom
                        null,           -- cost_rollup
                        NULL ,  -- org_type is used to store the source type
                        line_id_rec_tab(cntr).config_item_id,   -- config_item_id
                        NULL,
                        NULL,           -- rank
                        sysdate,        -- creation_date
                        gUserId,        -- created_by
                        sysdate,        -- last_update_date
                        gUserId,        -- last_updated_by
                        gLoginId,       -- last_update_login
                        null,           -- program_application_id
                        null,           -- program_id
                        sysdate);       -- program_update_date

        WriteToLog('After insert into bom_cto_src_orgs_b count is :'||sql%rowcount, 3);

        lStmtNum := 40;
	update /* INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
	bom_cto_order_lines_upg
	set status = 'BCSO'
	where line_id in ( select distinct line_id
			    from bom_cto_src_orgs_b
			   where config_item_id  in( select /*+INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N4 ) */
							distinct config_item_id
							from bom_cto_order_lines_upg
							where ato_line_id = p_ato_line_id
							and nvl(config_creation, 1) = 3
							and config_item_id is not null
							and status = 'UPG'));


	WriteToLog('Updated rows to status BCSO::'||sql%rowcount, 4);

	--END LOOP;
	-- End of changes for 10307286

	lStmtNum := 50;
	WriteToLog('Exiting update_bcso', 2);

EXCEPTION
	when OTHERS then
		WriteToLog('Others error in Update_bcso::lStmtNum::'||to_char(lStmtNum)||'::'||sqlerrm, 1);
		cto_msg_pub.count_and_get
          		( p_msg_count => l_msg_count
           		, p_msg_data  => l_msg_data
           		);
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Bcso;


PROCEDURE Update_Item_Data(
	p_cat_id IN number,
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2)
IS

lStmtNumber number;
lMsgCount number;
lMsgData varchar2(240);
l_cto_cost_type_id number;
l_layer_id number;
x_err_num number;
x_msg_name varchar2(240);
l_rev_id number;

CURSOR c_layer IS
   select distinct
      MP1.organization_id org_id,
      DECODE(bcso.ORGANIZATION_ID, bcolu.ship_from_org_id, get_cost_group(bcolu.ship_from_org_id, bcolu.line_id), 1) cost_group_id,
      bcolu.config_item_id config_item_id
   from
        cst_item_costs c,
        bom_cto_src_orgs bcso,
	bom_cto_order_lines_upg bcolu,
	mtl_parameters mp1
   where bcolu.config_item_id is not null
   and bcolu.status = 'BCSO'
   and c.organization_id       = bcso.organization_id
   and c.inventory_item_id     = bcolu.inventory_item_id
   and C.COST_TYPE_ID          =  2     -- Average Costing
   and bcso.model_item_id = bcolu.inventory_item_id
   and bcso.line_id = bcolu.line_id
   and mp1.organization_id = bcso.organization_id
   and MP1.Primary_cost_method = 2     -- Create only in Avg costing org
   and NOT EXISTS
   	(select NULL
        from cst_quantity_layers
        where inventory_item_id = bcolu.config_item_id
        and organization_id = bcso.organization_id);

CURSOR c_bcolu_cfg IS
select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
        distinct
	config_item_id,
	inventory_item_id,
	line_id
from bom_cto_order_lines_upg bcolu
where bcolu.config_item_id is not null
and bcolu.status = 'BCSO';

CURSOR c_get_org_id IS
select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_N2 ) */
        bcolu.config_item_id cfg_item_id,
	bcolu.inventory_item_id model_item_id,
	msi.organization_id src_org_id
from mtl_system_items msi,
bom_cto_order_lines_upg bcolu
where bcolu.config_item_id is not null
and bcolu.status = 'BCSO'
and msi.inventory_item_id = bcolu.config_item_id
and not exists
	(SELECT  	'x'
       	 FROM   	FND_ATTACHED_DOCUMENTS
       	 WHERE  	pk1_value   = to_char(msi.organization_id)
       	 AND		pk2_value   = to_char(msi.inventory_item_id)
       	 AND    	entity_name = 'MTL_SYSTEM_ITEMS');



 Type number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;


 TYPE cicd_summary_rec_tab is record (
                               config_item_id           number_tbl_type,
                               cost_organization_id     number_tbl_type,
                               cost_type_id             number_tbl_type,
                               material_cost            number_tbl_type,
                               material_overhead_cost   number_tbl_type,
                               resource_cost            number_tbl_type,
                               outside_processing_cost  number_tbl_type,
                               overhead_cost            number_tbl_type,
                               item_cost                number_tbl_type ) ;




 l_rt_cicd_summary cicd_summary_rec_tab ;


v_cto_cost_type_name    cst_cost_types.cost_type%type;

 --kkonada R12
 --for mtl_cross_references_b
 --bug# 4539578

  TYPE cfg_item_id              IS TABLE OF bom_cto_order_lines_upg.config_item_id%type;
  TYPE org_id			IS TABLE OF mtl_cross_references_b.organization_id%type;
  TYPE cross_reference_type     IS TABLE OF mtl_cross_references_b.cross_reference_type%type;
  TYPE cross_reference          IS TABLE OF mtl_cross_references_b.cross_reference%type;
  TYPE org_independent_flag     IS TABLE OF mtl_cross_references_b.org_independent_flag%type;

  t_cfg_item_id                 cfg_item_id;
  t_organization_id		org_id;
  t_cross_ref_type		cross_reference_type;
  t_cross_ref			cross_reference;
  t_org_independent_flag	org_independent_flag;

BEGIN

	WriteToLog('Entering Update_Item_Data', 3);
	lStmtNumber := 10;
	xReturnStatus := FND_API.G_RET_STS_SUCCESS;

	insert into mtl_system_items_tl (
		inventory_item_id,
		organization_id,
		language,
		source_lang,
		description,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login
		)
	select /*+ INDEX (BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,
		m.organization_id,
		l.language_code,
		userenv('LANG'),
		m.description,
		sysdate,
		gUserId,                              --last_updated_by
		sysdate,
		gUserId,                              --created_by
		gLoginId                              --last_update_login
	from
		mtl_system_items_tl m,
		bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu,
		fnd_languages  l
	where bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
	and m.inventory_item_id = bcolu.inventory_item_id
	and bcso.model_item_id = bcolu.inventory_item_id
	and bcso.line_id = bcolu.line_id
	and m.organization_id   = bcso.organization_id
	and  l.installed_flag In ('I', 'B')
	and  l.language_code  = m.language
	and  NOT EXISTS
		(select NULL
		from  mtl_system_items_tl  t
		where  t.inventory_item_id = bcolu.config_item_id
		and  t.organization_id = bcso.organization_id
		and  t.language = l.language_code );

	WriteToLog('Inserted rows into mtl_system_items_tl:: '||sql%rowcount,2);

	lStmtNumber := 20;
        insert into MTL_PENDING_ITEM_STATUS (
                inventory_item_id,
                organization_id,
                status_code,
                effective_date,
                pending_flag,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id)
        select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
                bcolu.config_item_id,
                m.organization_id,
                m.inventory_item_status_code,
                sysdate,
                'N',
                sysdate,
                gUserId,
                sysdate,
                gUserId,
                gLoginId,
                null,
                null,
                sysdate,
                null                    --  req_id
        from   mtl_system_items m,
        	bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
        where bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
	and m.inventory_item_id = bcolu.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
        and m.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from MTL_PENDING_ITEM_STATUS
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('Inserted rows into mtl_pending_item_status:: '||sql%rowcount,2);

        /*-------------------------------------------+
          Insert Item revision information
	  Till Patchset I, this information was inserted into mtl_item_revisions table.
	  In Patchset I, the table were changed to mtl_item_revisions_b and mtl_item_revisions_tl.
	  In Patchset I, we were constructing insert stmts dymanically to avoid BOM/INV odf dependency.
	  In Patchset J, we are inserting into the new tables. Dependency will not be an issue because we are maintaining a separate branch for J and I.
	  Cannot do bulk processing here, since a different revision_id needs to be generated for each config
        +-------------------------------------------*/
        lStmtNumber := 30;

	FOR v_bcolu_cfg IN c_bcolu_cfg LOOP
                 --removed as part of bugfix 3340844
		/*select MTL_ITEM_REVISIONS_B_S.nextval
		into l_rev_id
		from dual;*/


		WriteToLog('Going to insert rows into mtl_item_revisions_b:: '||   v_bcolu_cfg.config_item_id,2);
		insert into mtl_item_revisions_b
        	      (inventory_item_id,
        	       organization_id,
        	       revision,
        	       last_update_date,
        	       last_updated_by,
        	       creation_date,
        	       created_by,
        	       last_update_login,
        	       implementation_date,
        	       effectivity_date,
		       OBJECT_VERSION_NUMBER,
		       REVISION_ID,
		       REVISION_LABEL --3340844
        	      )
        	select  --distinct
        	       	v_bcolu_cfg.config_item_id,
        	       	m.organization_id,
        	        mp1.starting_revision,
        	        sysdate,
        	        gUserId,                     -- last_updated_by
        	        sysdate,
        	        gUserId,                     -- created_by
        	        gLoginId,                    -- last_update_login
        	        sysdate,
        	        sysdate,
		        1,                           --would be 1 for initial creation of item
		        MTL_ITEM_REVISIONS_B_S.nextval, -- 3338108       --l_rev_id, --revision_id is generated from sequence
			mp1.starting_revision --3340844
        	 from
        	       mtl_parameters mp1,
        	       mtl_system_items m
        	where m.inventory_item_id = v_bcolu_cfg.config_item_id
        	and m.organization_id = mp1.organization_id
        	and NOT EXISTS
        	        (select NULL
        	        from MTL_ITEM_REVISIONS_B
        	        where inventory_item_id = v_bcolu_cfg.config_item_id
        	        and organization_id = mp1.organization_id);

		WriteToLog('Inserted rows into mtl_item_revisions_b:: '||sql%rowcount,2);
	        --insert into _tl table so that item is visible in revisions form
		--for multi-lingual support

		insert into mtl_item_revisions_tl (
	                inventory_item_id,
	                organization_id,
			revision_id,
	                language,
	                source_lang,
	                description,
	                last_update_date,
	                last_updated_by,
	                creation_date,
	                created_by,
	                last_update_login
	                )
	        select distinct
	                v_bcolu_cfg.config_item_id,
	                m.organization_id,
			mr.revision_id, --3338108 --l_rev_id
	                l.language_code,
	                userenv('LANG'),
	                m.description,
	                sysdate,
	                gUserId,         --last_updated_by
	                sysdate,
	                gUserId,         --created_by
	                gLoginId         --last_update_login
	        from
	                mtl_system_items_tl m,
	                bom_cto_src_orgs bcso,
	                fnd_languages  l,
			mtl_item_revisions_b mr --3338108
	        where m.inventory_item_id = v_bcolu_cfg.inventory_item_id
	        and bcso.model_item_id = m.inventory_item_id
	        and bcso.line_id = v_bcolu_cfg.line_id
	        and m.organization_id   = bcso.organization_id
	        and  l.installed_flag In ('I', 'B')
	        and  l.language_code  = m.language
		and  mr.inventory_item_id = v_bcolu_cfg.config_item_id --3338108
		and mr.organization_id = bcso.organization_id --3338108
	        and  NOT EXISTS
	                (select NULL
	                from  mtl_item_revisions_tl  t
	                where  t.inventory_item_id = v_bcolu_cfg.config_item_id
	                and  t.organization_id = bcso.organization_id
			and  t.revision_id = mr.revision_id --3338108
	                and  t.language = l.language_code );

		WriteToLog('Inserted rows into mtl_item_revisions_tl:: '||sql%rowcount,2);

	END LOOP; /* c_bcolu_cfg */


      	/*----------------------------------------------------------+
         Insert cost records for config items
         The cost organization id is either the organization id
         or the master organization id
      	+----------------------------------------------------------*/



        lStmtNumber := 33;
        /* FIX to avoid rolled up cost of model from being included during cost rollup */
        /* begin Fix for bug 4172300. cost in validation org is not copied properly from model to config item */

	--performance bugfix4905887 shared memroy 1MB (sqlid :16104932 )
	--Removed comments to max possible
	--bsco is a mergable view now
	--removed un-necessary join on mtl_system_items
	--Removed a Distinct clause in IN sub-query

        select bcolu.config_item_id,
               C.organization_id,   -- bug 4172300
               C.cost_type_id,
               nvl(sum(decode( cicd.cost_element_id, 1 , nvl(cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,2 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,3 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,4 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,5 , nvl( cicd.item_cost, 0 ) ))  , 0 )
BULK COLLECT INTO
               l_rt_cicd_summary.config_item_id,
               l_rt_cicd_summary.cost_organization_id,
               l_rt_cicd_summary.cost_type_id,
               l_rt_cicd_summary.material_cost,
               l_rt_cicd_summary.material_overhead_cost,
               l_rt_cicd_summary.resource_cost,
               l_rt_cicd_summary.outside_processing_cost,
               l_rt_cicd_summary.overhead_cost
        from
                mtl_parameters        MP1,
                cst_item_costs        C,
                cst_item_cost_details CICD,
                bom_cto_order_lines_upg bcolu
      	where
                C.organization_id   = MP1.organization_id
        and     C.inventory_item_id = bcolu.inventory_item_id  -- pModelId
        and     C.COST_TYPE_ID  IN ( MP1.primary_cost_method, MP1.avg_rates_cost_type_id)
        and     C.inventory_item_id = CICD.inventory_item_id(+)
        and     C.organization_id  = CICD.organization_id(+)
        and     C.cost_type_id = CICD.cost_type_id(+)
        and     CICD.rollup_source_type(+) = 1      -- User Defined
        --bug 4172300
        and     ( bcolu.line_id , C.inventory_item_id, C.organization_id) in
                                             ( select
                                                      bcolu.line_id,
                                                      bcolu.inventory_item_id,
                                                      MP2.cost_organization_id
                                             from mtl_parameters mp2,
                                                  mtl_parameters mp3,
                                                  bom_cto_src_orgs bcso,
                                                  bom_cto_order_lines_upg bcolu
                                            where bcolu.config_item_id is not null
	                                          and bcolu.status = 'BCSO'
                                                  and bcso.model_item_id = bcolu.inventory_item_id
                                                  and     bcso.model_item_id = bcolu.inventory_item_id
                                                  and     bcso.line_id = bcolu.line_id
                                              and MP3.organization_id = bcso.organization_id
                                              and ((mp2.organization_id = bcso.organization_id) OR
                                                  (mp2.organization_id = mp3.master_organization_id))
                                         )
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.cost_organization_id
                and cost_type_id  in (mp1.primary_cost_method, mp1.avg_rates_cost_type_id))
        group by bcolu.config_item_id, C.organization_id, C.cost_type_id;



        /* end Fix for bug 4172300. cost in validation org is not copied properly from model to config item */

       if( l_rt_cicd_summary.cost_organization_id.count > 0 ) then
           for i in l_rt_cicd_summary.cost_organization_id.first..l_rt_cicd_summary.cost_organization_id.last
           loop

               oe_debug_pub.add( i || ') ' || 'Cost Header Info: ' ||
                         ' CFG ID ' || l_rt_cicd_summary.config_item_id(i) ||
                         ' cst org ' || l_rt_cicd_summary.cost_organization_id(i) ||
                         ' cst id ' || l_rt_cicd_summary.cost_type_id(i) ||
                         ' m cost ' || l_rt_cicd_summary.material_cost(i) ||
                         ' moh cost ' || l_rt_cicd_summary.material_overhead_cost(i) ||
                         ' rsc cost ' || l_rt_cicd_summary.resource_cost(i) ||
                         ' osp cost ' || l_rt_cicd_summary.outside_processing_cost(i) ||
                         ' ovh cost ' || l_rt_cicd_summary.overhead_cost(i) , 1 );



               l_rt_cicd_summary.item_cost(i) := l_rt_cicd_summary.material_cost(i) + l_rt_cicd_summary.material_overhead_cost(i)
                                        + l_rt_cicd_summary.resource_cost(i) + l_rt_cicd_summary.outside_processing_cost(i)
                                        + l_rt_cicd_summary.overhead_cost(i) ;



               oe_debug_pub.add( ' item cost ' || l_rt_cicd_summary.item_cost(i) , 1 );


            end loop ;


        else


               oe_debug_pub.add( ' no new item cost records for  upgrade ' , 1 );

        end if;


      	/*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
      	+------------------------------------------------------- */

      	lStmtNumber := 40;

      	insert into CST_ITEM_COSTS
            	(inventory_item_id,
             	organization_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	inventory_asset_flag,
             	lot_size,
             	based_on_rollup_flag,
             	shrinkage_rate,
             	defaulted_flag,
             	cost_update_id,
             	pl_material,
             	pl_material_overhead,
             	pl_resource,
             	pl_outside_processing,
             	pl_overhead,
             	tl_material,
             	tl_material_overhead,
             	tl_resource,
             	tl_outside_processing,
             	tl_overhead,
             	material_cost,
             	material_overhead_cost,
             	resource_cost,
             	outside_processing_cost ,
             	overhead_cost,
             	pl_item_cost,
             	tl_item_cost,
             	item_cost,
             	unburdened_cost ,
             	burden_cost,
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
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,                -- INVENTORY_ITEM_ID
             	mp1.cost_organization_id,
             	c.cost_type_id,
             	sysdate,                  -- last_update_date
             	-1,                       -- last_updated_by
             	sysdate,                  -- creation_date
             	-1,                       -- created_by
             	-1,                       -- last_update_login
             	C.inventory_asset_flag,
             	C.lot_size,
             	C.based_on_rollup_flag,
             	C.shrinkage_rate,
             	C.defaulted_flag,
             	NULL,                     -- cost_update_id
             	C.pl_material,
             	C.pl_material_overhead,
             	C.pl_resource,
             	C.pl_outside_processing,
             	C.pl_overhead,
             	C.tl_material,
             	C.tl_material_overhead,
             	C.tl_resource,
             	C.tl_outside_processing,
             	C.tl_overhead,
             	C.material_cost,
             	C.material_overhead_cost,
             	C.resource_cost,
             	C.outside_processing_cost ,
             	C.overhead_cost,
             	C.pl_item_cost,
             	C.tl_item_cost,
             	C.item_cost,
             	C.unburdened_cost ,
             	C.burden_cost,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.ATTRIBUTE12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
      	from
             	mtl_parameters MP1,
             	cst_item_costs C,
             	mtl_system_items S,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where  bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
	and S.organization_id   = C.organization_id
      	and    S.inventory_item_id = C.inventory_item_id
        and    C.inventory_item_id = bcolu.inventory_item_id
        and    C.inventory_item_id = S.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
      	and    C.cost_type_id  in ( mp1.primary_cost_method, mp1.avg_rates_cost_type_id)
        and    C.organization_id   = mp1.organization_id
	and    mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.cost_organization_id --bugfix 3877097
		and cost_type_id  in (mp1.primary_cost_method, mp1.avg_rates_cost_type_id));

	WriteToLog('Inserted rows into cst_item_costs:: '||sql%rowcount,2);







        if( l_rt_cicd_summary.cost_type_id.count> 0 ) then
        FORALL j IN 1..l_rt_cicd_summary.cost_type_id.last
              UPDATE cst_item_costs
                 set material_cost = l_rt_cicd_summary.material_cost(j),
                     material_overhead_cost = l_rt_cicd_summary.material_overhead_cost(j),
                     resource_cost = l_rt_cicd_summary.resource_cost(j),
                     outside_processing_cost = l_rt_cicd_summary.outside_processing_cost(j),
                     overhead_cost = l_rt_cicd_summary.overhead_cost(j),
                     tl_material = l_rt_cicd_summary.material_cost(j),
                     tl_material_overhead = l_rt_cicd_summary.material_overhead_cost(j),
                     tl_resource = l_rt_cicd_summary.resource_cost(j),
                     tl_outside_processing = l_rt_cicd_summary.outside_processing_cost(j),
                     tl_overhead = l_rt_cicd_summary.overhead_cost(j),
                     tl_item_cost = l_rt_cicd_summary.item_cost(j),
                     item_cost = l_rt_cicd_summary.item_cost(j),
                     burden_cost = l_rt_cicd_summary.material_overhead_cost(j)
              where inventory_item_id = l_rt_cicd_summary.config_item_id(j)      --   pConfigId
                and organization_id = l_rt_cicd_summary.cost_organization_id(j)
                and cost_type_id = l_rt_cicd_summary.cost_type_id(j) ;


        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || 'after update:CST_ITEM_COSTS '|| to_char(sql%rowcount),2);
        END IF;
         else

             oe_debug_pub.add( 'No update required to CST_ITEM_COSTS as no new records inserted ' , 1 ) ;

         end if;






	/* For standard costing orgs, we will copy model's user-defined
	cost in Frozen to the config in CTO cost type. */

	lStmtNumber := 50;


       /* begin bugfix 4057651, default CTO cost type id = 7 if it does not exist */
        begin

           select cost_type_id into l_cto_cost_type_id
             from cst_cost_types
            where cost_type = 'CTO' ;

        exception
        when no_data_found then

           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || ' no_data_found error CTO cost type id does not exist',2);
                oe_debug_pub.add('Create_Item: ' || ' defaulting CTO cost type id = 7 ',2);
           END IF;

           l_cto_cost_type_id := 7 ;

           begin
                select cost_type into v_cto_cost_type_name
                  from cst_cost_types
                 where cost_type_id = l_cto_cost_type_id  ;

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' cost type id =  ' || l_cto_cost_type_id ||
                                     '  has cost_type =  ' || v_cto_cost_type_name ,2);
                  END IF;
           exception
           when no_data_found then
                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' no_data_found error for cost type id = 7 ',2);
                  END IF;
                 cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
                 raise  FND_API.G_EXC_ERROR;
           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;
           end ;

        when others then
           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
        end ;
       /* end bugfix 4057651, default CTO cost type id = 7 if it does not exist */



	lStmtNumber := 60;
      	insert into CST_ITEM_COSTS
            	(inventory_item_id,
             	organization_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	inventory_asset_flag,
             	lot_size,
             	based_on_rollup_flag,
             	shrinkage_rate,
             	defaulted_flag,
             	cost_update_id,
             	pl_material,
             	pl_material_overhead,
             	pl_resource,
             	pl_outside_processing,
             	pl_overhead,
             	tl_material,
             	tl_material_overhead,
             	tl_resource,
             	tl_outside_processing,
             	tl_overhead,
             	material_cost,
             	material_overhead_cost,
             	resource_cost,
             	outside_processing_cost ,
             	overhead_cost,
             	pl_item_cost,
             	tl_item_cost,
             	item_cost,
             	unburdened_cost ,
             	burden_cost,
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
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,     -- INVENTORY_ITEM_ID
             	mp1.cost_organization_id,
             	l_cto_cost_type_id, 	  -- CTO cost_type_id,
             	sysdate,                  -- last_update_date
             	-1,                       -- last_updated_by
             	sysdate,                  -- creation_date
             	-1,                       -- created_by
             	-1,                       -- last_update_login
             	C.inventory_asset_flag,
             	C.lot_size,
             	C.based_on_rollup_flag,
             	C.shrinkage_rate,
             	C.defaulted_flag,
             	NULL,                     -- cost_update_id
             	C.pl_material,
             	C.pl_material_overhead,
             	C.pl_resource,
             	C.pl_outside_processing,
             	C.pl_overhead,
             	C.tl_material,
             	C.tl_material_overhead,
             	C.tl_resource,
             	C.tl_outside_processing,
             	C.tl_overhead,
             	C.material_cost,
             	C.material_overhead_cost,
             	C.resource_cost,
             	C.outside_processing_cost ,
             	C.overhead_cost,
             	C.pl_item_cost,
             	C.tl_item_cost,
             	C.item_cost,
             	C.unburdened_cost ,
             	C.burden_cost,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.ATTRIBUTE12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
      	from
             	mtl_parameters MP1,
             	cst_item_costs C,
             	mtl_system_items S,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where  bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
      	and S.organization_id   = C.organization_id
      	and    S.inventory_item_id = C.inventory_item_id
        and    C.inventory_item_id = bcolu.inventory_item_id
        and    C.inventory_item_id = S.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
      	and    C.cost_type_id  = mp1.primary_cost_method
	and    C.cost_type_id  = 1
        and    C.organization_id   = bcso.organization_id
	and    mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.cost_organization_id --bugfix 3877097
		and cost_type_id = l_cto_cost_type_id);

	WriteToLog('Inserted rows into cst_item_costs:: '||sql%rowcount,2);







        if( l_rt_cicd_summary.cost_type_id.count > 0 ) then
        FORALL j IN 1..l_rt_cicd_summary.cost_type_id.last
              UPDATE cst_item_costs
                 set material_cost = l_rt_cicd_summary.material_cost(j),
                     material_overhead_cost = l_rt_cicd_summary.material_overhead_cost(j),
                     resource_cost = l_rt_cicd_summary.resource_cost(j),
                     outside_processing_cost = l_rt_cicd_summary.outside_processing_cost(j),
                     overhead_cost = l_rt_cicd_summary.overhead_cost(j),
                     tl_material = l_rt_cicd_summary.material_cost(j),
                     tl_material_overhead = l_rt_cicd_summary.material_overhead_cost(j),
                     tl_resource = l_rt_cicd_summary.resource_cost(j),
                     tl_outside_processing = l_rt_cicd_summary.outside_processing_cost(j),
                     tl_overhead = l_rt_cicd_summary.overhead_cost(j),
                     tl_item_cost = l_rt_cicd_summary.item_cost(j),
                     item_cost = l_rt_cicd_summary.item_cost(j),
                     burden_cost = l_rt_cicd_summary.material_overhead_cost(j)
              where inventory_item_id = l_rt_cicd_summary.config_item_id(j)    --  pConfigId
                and organization_id = l_rt_cicd_summary.cost_organization_id(j)
                and cost_type_id = l_cto_cost_type_id  ;


        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || 'after update:cst_item_costs for CTO cost type  '||to_char(sql%rowcount),2);
        END IF;

         else

             oe_debug_pub.add( 'No update required to CST_ITEM_COSTS for CTO cost type as no new records inserted ' , 1 ) ;

         end if;




      	/*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
      	+-----------------------------------------------------*/

      	lStmtNumber := 70;

      	insert into cst_item_cost_details
            	(inventory_item_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	organization_id,
             	operation_sequence_id,
             	operation_seq_num,
             	department_id,
             	level_type,
             	activity_id,
             	resource_seq_num,
             	resource_id,
             	resource_rate,
             	item_units,
             	activity_units,
             	usage_rate_or_amount,
             	basis_type,
             	basis_resource_id,
             	basis_factor,
             	net_yield_or_shrinkage_factor,
             	item_cost,
             	cost_element_id,
             	rollup_source_type,
             	activity_context,
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
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,        -- inventory_item_id
             	c.cost_type_id,
             	sysdate,                     -- last_update_date
             	-1,                          -- last_updated_by
             	sysdate,                     -- creation_date
             	-1,                          -- created_by
             	-1,                          -- last_update_login
             	mp1.cost_organization_id,
             	c.operation_sequence_id,
             	c.operation_seq_num,
             	c.department_id,
             	c.level_type,
             	c.activity_id,
             	c.resource_seq_num,
             	c.resource_id,
             	c.resource_rate,
             	c.item_units,
             	c.activity_units,
             	c.usage_rate_or_amount,
             	c.basis_type,
             	c.basis_resource_id,
             	c.basis_factor,
             	c.net_yield_or_shrinkage_factor,
             	c.item_cost,
             	c.cost_element_id,
             	C.rollup_source_type,
             	C.activity_context,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.attribute12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
      	from
             	mtl_parameters        MP1,
             	cst_item_cost_details C,
             	mtl_system_items      S,
                bom_cto_src_orgs      bcso,
		bom_cto_order_lines_upg bcolu
      	where  bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
      	and  	S.organization_id   = C.organization_id
      	and    	S.inventory_item_id = C.inventory_item_id
      	and 	bcso.model_item_id = bcolu.inventory_item_id
        and 	bcso.line_id = bcolu.line_id
      	and    	C.organization_id   = MP1.organization_id
      	and    	C.inventory_item_id = bcolu.inventory_item_id
      	and    	C.inventory_item_id = S.inventory_item_id
      	and    	C.rollup_source_type = 1      -- User Defined
      	and    	C.COST_TYPE_ID  IN ( MP1.primary_cost_method, MP1.avg_rates_cost_type_id)
	and     mp1.organization_id  = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from cst_item_cost_details
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.cost_organization_id --bugfix 3877097
		and COST_TYPE_ID  IN (MP1.primary_cost_method, MP1.avg_rates_cost_type_id));

	WriteToLog('Inserted rows into cst_item_cost_details:: '||sql%rowcount,2);


	/* For standard costing orgs, we will copy model's user-defined
	cost in Frozen to the config in CTO cost type. */

	lStmtNumber := 80;
      	insert into cst_item_cost_details
            	(inventory_item_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	organization_id,
             	operation_sequence_id,
             	operation_seq_num,
             	department_id,
             	level_type,
             	activity_id,
             	resource_seq_num,
             	resource_id,
             	resource_rate,
             	item_units,
             	activity_units,
             	usage_rate_or_amount,
             	basis_type,
             	basis_resource_id,
             	basis_factor,
             	net_yield_or_shrinkage_factor,
             	item_cost,
             	cost_element_id,
             	rollup_source_type,
             	activity_context,
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
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,                   -- inventory_item_id
             	l_cto_cost_type_id, 	     -- CTO cost_type_id,
             	sysdate,                     -- last_update_date
             	-1,                          -- last_updated_by
             	sysdate,                     -- creation_date
             	-1,                          -- created_by
             	-1,                          -- last_update_login
             	mp1.cost_organization_id,
             	c.operation_sequence_id,
             	c.operation_seq_num,
             	c.department_id,
             	c.level_type,
             	c.activity_id,
             	c.resource_seq_num,
             	c.resource_id,
             	c.resource_rate,
             	c.item_units,
             	c.activity_units,
             	c.usage_rate_or_amount,
             	c.basis_type,
             	c.basis_resource_id,
             	c.basis_factor,
             	c.net_yield_or_shrinkage_factor,
             	c.item_cost,
             	c.cost_element_id,
             	C.rollup_source_type,
             	C.activity_context,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.attribute12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
      	from
             	mtl_parameters        MP1,
             	cst_item_cost_details C,
             	mtl_system_items      S,
                bom_cto_src_orgs      bcso,
		bom_cto_order_lines_upg bcolu
      	where  bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
      	and  	S.organization_id   = C.organization_id
      	and    	S.inventory_item_id = C.inventory_item_id
      	and 	bcso.model_item_id = bcolu.inventory_item_id
        and 	bcso.line_id = bcolu.line_id
      	and    	C.organization_id   = MP1.organization_id
      	and    	C.inventory_item_id = bcolu.inventory_item_id
      	and    	C.inventory_item_id = S.inventory_item_id
      	and    	C.rollup_source_type = 1      -- User Defined
      	and    	C.COST_TYPE_ID = MP1.primary_cost_method
	and 	C.cost_type_id = 1
	and     mp1.organization_id  = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from cst_item_cost_details
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.cost_organization_id --bugfix 3877097
		and COST_TYPE_ID = l_cto_cost_type_id);
	WriteToLog('Inserted rows into cst_item_cost_details:: '||sql%rowcount,2);


	lStmtNumber := 90;

	IF ( nvl(fnd_profile.value('CST_AVG_COSTING_OPTION'), '1') = '2' ) THEN
	  FOR v_layer in c_layer
	  LOOP

	  --
	  -- This costing API will insert a row into cst_quantity_layers
	  -- for a unique layer_id and the given parameters.
	  -- It will return 0 if failed, layer_id if succeeded
	  --
	  l_layer_id := cstpaclm.create_layer (
  		i_org_id => v_layer.org_id,
  		i_item_id => v_layer.config_item_id,	--pConfigId,
  		i_cost_group_id => v_layer.cost_group_id,
  		i_user_id => gUserId,
  		i_request_id => NULL,
  		i_prog_id => NULL,
  		i_prog_appl_id => NULL,
  		i_txn_id => -1,
  		o_err_num => x_err_num,
  		o_err_code => x_msg_name,
  		o_err_msg => lMsgData
		);

	  IF (l_layer_id = 0) THEN
		WriteToLog('Create_Item: ' || 'CST function create_layer returned with error '||to_char(x_err_num)||', '||x_msg_name||', '||
				lMsgData||'for '||to_char(v_layer.org_id)||', '||to_char(v_layer.cost_group_id),1);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSE
		WriteToLog('Inserted row into cql for '||to_char(l_layer_id)||', '||to_char(v_layer.org_id)||', '|| to_char(v_layer.cost_group_id),1);
	  END IF;

	  END LOOP;
	END IF;


      	/*--------------------------------------------------------+
        Insert rows into the mtl_desc_elem_val_interface table
        Descriptive elements are not organization controlled
	Using ship_from org in bcol_upg to get values
      	+---------------------------------------------------------*/

      	lStmtNumber := 100;

      	insert into MTL_DESCR_ELEMENT_VALUES
         	(inventory_item_id,
             	element_name,
             	last_update_date,
             	last_updated_by,
             	last_update_login,
             	creation_date,
             	created_by,
             	element_value,
             	default_element_flag,
             	element_sequence,
             	program_application_id,
             	program_id,
             	program_update_date,
             	request_id
            	)
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
		bcolu.config_item_id,     -- Inventory_item_id
             	E.element_name,           -- element_name
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	gLoginId,                 -- last_update_login
             	sysdate,                  -- creation_date
             	gUserId,                  -- created_by
             	D.element_value,          -- element_value
             	E.default_element_flag,   -- default_element_flag
             	E.element_sequence,       -- element_sequence
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	NULL                      -- request_id
      	from   mtl_system_items  s,
             	mtl_descr_element_values D,
             	mtl_descriptive_elements E,
		bom_cto_order_lines_upg bcolu
      	where  bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
      	and  D.inventory_item_id     = S.inventory_item_id
      	and    s.inventory_item_id     = bcolu.inventory_item_id
      	and    s.organization_id       = bcolu.ship_from_org_id
      	and    E.item_catalog_group_id = S.item_catalog_group_id
      	and    E.element_name          = D.element_name
	and NOT EXISTS
                (select NULL
                from mtl_descr_element_values
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcolu.ship_from_org_id);

	WriteToLog('Inserted rows into mtl_descr_element_values:: '||sql%rowcount,2);


      	/*--------------------------------------+
          Insert into mtl_item_categories
	  Do not insert into CTO category if passed
      	+--------------------------------------*/
      	lStmtNumber := 120;

	WriteToLog('Category id is ::'||p_cat_id, 3);

	IF p_cat_id = -99 THEN

	lStmtNumber := 122;

	--FP bugfix 4861996
	--added condition ic1.category_set_id = ic.category_set_id

        -- bug 13362916
        -- Modified for performance
        --
      	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
      	-- select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
        select /*+ leading( bcolu, ic1, mp1, bcso, mp2, ic) */
                distinct
             	bcolu.config_item_id,
             	ic.category_set_id,
             	ic.category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
      	from
             	mtl_item_categories ic,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and     ic.inventory_item_id = bcolu.inventory_item_id
      	and    	ic.organization_id = bcso.organization_id
        and     bcso.model_item_id = ic.inventory_item_id
        and     bcso.line_id = bcolu.line_id
        and     CTO_CUSTOM_CATEGORY_PK.Copy_Category (ic.category_set_id , ic.organization_id) = 1
        and NOT EXISTS
                (select /*+ NO_UNNEST PUSH_SUBQ */ NULL
                from  MTL_ITEM_CATEGORIES ic1
                where ic1.inventory_item_id = bcolu.config_item_id
                and   ic1.organization_id = bcso.organization_id
		and   ic1.category_set_id = ic.category_set_id
                and   rownum = 1 -- bug 13876670
		);

	WriteToLog('Inserted rows into mtl_item_categories:: '||sql%rowcount,2);
	lStmtNumber := 124;

	 --
 	 -- bug 13362916
 	 -- modified hints
         --
	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
         -- select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
         select /*+ leading( bcolu, ic1, mp1, bcso, mp2, ic) */
                distinct
             	bcolu.config_item_id,
             	mcsb.category_set_id,
             	mcsb.default_category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
      	from
             	mtl_item_categories 		ic,
             	mtl_category_sets_b 		mcsb,
             	mtl_default_category_sets 	mdcs,
                bom_cto_src_orgs        	bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and  	bcolu.inventory_item_id = ic.inventory_item_id
      	and    	ic.organization_id = bcso.organization_id
        and 	bcso.model_item_id = bcolu.inventory_item_id
        and 	bcso.line_id = bcolu.line_id
        and	mcsb.category_set_id = mdcs.category_set_id
        and	mdcs.functional_area_id = 2
        and 	NOT EXISTS
                (     	select /*+ NO_UNNEST PUSH_SUBQ */ NULL
                	from MTL_ITEM_CATEGORIES
                	where inventory_item_id = bcolu.config_item_id
                	and organization_id = bcso.organization_id
                	and category_set_id = mcsb.category_set_id
                        and rownum = 1 -- bug 13876670
		);

	WriteToLog('Inserted rows into mtl_item_categories for default categories:: '||sql%rowcount,2);

	ELSE /* p_cat_id is passed */

	lStmtNumber := 126;

	--FP bugfix 4861996
	--added condition ic1.category_set_id = ic.category_set_id

	 --
 	 -- bug 13362916
 	 -- modified hints
         --
      	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
      	-- select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
        select /*+ leading( bcolu, ic1, mp1, bcso, mp2, ic) */
                distinct
             	bcolu.config_item_id,
             	ic.category_set_id,
             	ic.category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
      	from
             	mtl_item_categories ic,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and     ic.inventory_item_id = bcolu.inventory_item_id
      	and    	ic.organization_id = bcso.organization_id
	and     ic.category_id <> p_cat_id -- CTO category
        and     bcso.model_item_id = ic.inventory_item_id
        and     bcso.line_id = bcolu.line_id
        and     CTO_CUSTOM_CATEGORY_PK.Copy_Category (ic.category_set_id , ic.organization_id) = 1
        and NOT EXISTS
                (select /*+ NO_UNNEST PUSH_SUBQ */ NULL
                from  MTL_ITEM_CATEGORIES ic1
                where ic1.inventory_item_id = bcolu.config_item_id
                and   ic1.organization_id = bcso.organization_id
		and   ic1.category_set_id = ic.category_set_id
                and   rownum = 1 -- bug 13876670
		);

	WriteToLog('Inserted rows into mtl_item_categories:: '||sql%rowcount,2);
	lStmtNumber := 128;

	 --
 	 -- bug 13362916
 	 -- modified hints
         --
	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
         -- select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
         select /*+ leading( bcolu, ic1, mp1, bcso, mp2, ic) */
                distinct
             	bcolu.config_item_id,
             	mcsb.category_set_id,
             	mcsb.default_category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
      	from
             	mtl_item_categories 		ic,
             	mtl_category_sets_b 		mcsb,
             	mtl_default_category_sets 	mdcs,
                bom_cto_src_orgs        	bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and  	bcolu.inventory_item_id = ic.inventory_item_id
      	and    	ic.organization_id = bcso.organization_id
	and     ic.category_id <> p_cat_id -- CTO category
        and 	bcso.model_item_id = bcolu.inventory_item_id
        and 	bcso.line_id = bcolu.line_id
        and	mcsb.category_set_id = mdcs.category_set_id
        and	mdcs.functional_area_id = 2
        and 	NOT EXISTS
                (     	select /*+ NO_UNNEST PUSH_SUBQ */ NULL
                	from MTL_ITEM_CATEGORIES
                	where inventory_item_id = bcolu.config_item_id
                	and organization_id = bcso.organization_id
                	and category_set_id = mcsb.category_set_id
                        and rownum = 1 -- bug 13876670
		);

	WriteToLog('Inserted rows into mtl_item_categories for default categories:: '||sql%rowcount,2);

	END IF; /* p_cat_id = -99 */


      	/*----------------------------------------------------+
        Copy related items into MTL_RELATED_ITEMS table
      	+----------------------------------------------------*/

      	lStmtNumber := 140;

      	insert into MTL_RELATED_ITEMS
           	(
             	inventory_item_id,
             	related_item_id,
             	relationship_type_id,
             	reciprocal_flag,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
            	)
      	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
             	bcolu.config_item_id,
             	ri.related_item_id,
             	ri.relationship_type_id,
             	ri.reciprocal_flag,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ri.organization_id
       	from  mtl_related_items ri,
             	bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
        and ri.inventory_item_id = bcolu.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
       	and   ri.organization_id   = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_related_items
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('Inserted rows into mtl_related_items:: '||sql%rowcount,2);

       	/*--------------------------------------------------+
           Copy substitute inventories
       	+--------------------------------------------------*/

       	lStmtNumber := 150;

       	insert into mtl_item_sub_inventories
           	(
             	inventory_item_id,
             	organization_id,
             	secondary_inventory,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	primary_subinventory_flag ,
             	picking_order,
             	min_minmax_quantity,
             	max_minmax_quantity,
             	inventory_planning_code,
             	fixed_lot_multiple,
             	minimum_order_quantity,
             	maximum_order_quantity,
             	source_type,
             	source_organization_id,
             	source_subinventory,
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
             	program_application_id ,
             	program_id,
             	program_update_date,
             	encumbrance_account
             	)
       	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
             	bcolu.config_item_id,
             	isi.ORGANIZATION_ID,
             	isi.SECONDARY_INVENTORY,
             	sysdate,                    -- last_update_date
             	gUserId,                    -- last_updated_by
             	sysdate,                    -- creation_date
             	gUserId,                    -- created_by
             	gLoginId,                   -- last_update_login
             	isi.PRIMARY_SUBINVENTORY_FLAG ,
             	isi.PICKING_ORDER,
             	isi.MIN_MINMAX_QUANTITY,
             	isi.MAX_MINMAX_QUANTITY,
             	isi.INVENTORY_PLANNING_CODE,
             	isi.FIXED_LOT_MULTIPLE,
             	isi.MINIMUM_ORDER_QUANTITY,
             	isi.MAXIMUM_ORDER_QUANTITY,
             	isi.SOURCE_TYPE,
             	isi.SOURCE_ORGANIZATION_ID,
             	isi.SOURCE_SUBINVENTORY,
             	isi.ATTRIBUTE_CATEGORY,
             	isi.ATTRIBUTE1,
             	isi.ATTRIBUTE2,
             	isi.ATTRIBUTE3,
             	isi.ATTRIBUTE4,
             	isi.ATTRIBUTE5,
             	isi.ATTRIBUTE6,
             	isi.ATTRIBUTE7,
             	isi.ATTRIBUTE8,
             	isi.ATTRIBUTE9,
             	isi.ATTRIBUTE10,
             	isi.ATTRIBUTE11,
             	isi.ATTRIBUTE12,
             	isi.ATTRIBUTE13,
             	isi.ATTRIBUTE14,
             	isi.ATTRIBUTE15,
             	NULL,                       -- request_id
             	NULL,                       -- program_application_id
             	NULL,                       -- program_id
             	SYSDATE,                    -- program_update_date
             	isi.ENCUMBRANCE_ACCOUNT
       	from
             	mtl_item_sub_inventories isi,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
       	and   isi.organization_id   = bcso.organization_id
       	and   isi.inventory_item_id = bcolu.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
        and NOT EXISTS
                (select NULL
                from mtl_item_sub_inventories
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('Inserted rows into mtl_item_sub_inventories:: '||sql%rowcount,2);


       	/*--------------------------------------+
          Copy secondary locators
       	+--------------------------------------*/

       	lStmtNumber := 160;

       	insert into mtl_secondary_locators
           	(
             	inventory_item_id,
             	organization_id,
             	secondary_locator,
             	primary_locator_flag,
             	picking_order,
             	subinventory_code,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date
           	)
       	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
             	bcolu.config_item_id,
             	sl.organization_id,
             	sl.secondary_locator,
             	sl.primary_locator_flag,
             	sl.picking_order,
             	sl.subinventory_code,
             	sysdate,                     -- last_update_date
             	gUserId,                     -- last_updated_by
             	sysdate,                     -- creation_date
             	gUserId,                     -- created_by
             	gLoginId,                    -- last_update_login
             	NULL,                        -- request_id
             	NULL,                        -- program_application_id
             	NULL,                        -- program_id
             	SYSDATE                      -- program_update_date
      	from
             	mtl_secondary_locators sl,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and   sl.organization_id = bcso.organization_id
      	and   bcolu.inventory_item_id = sl.inventory_item_id
        and   bcso.model_item_id = bcolu.inventory_item_id
        and   bcso.line_id = bcolu.line_id
        and NOT EXISTS
                (select NULL
                from mtl_secondary_locators
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('Inserted rows into mtl_secondary_locators:: '||sql%rowcount,2);

      	/*----------------------------------------+
            Copy cross references
      	+----------------------------------------*/

      	lStmtNumber := 170;

      --start bugfix  4539578
        select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
               distinct
            	bcolu.config_item_id,
            	cr_b.organization_id,
            	cr_b.cross_reference_type,
            	cr_b.cross_reference,
            	cr_b.org_independent_flag
       BULK COLLECT INTO
                t_cfg_item_id,
	        t_organization_id,
		t_cross_ref_type,
		t_cross_ref,
		t_org_independent_flag
       from
            	mtl_cross_references_b cr_b,
            	bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and (cr_b.organization_id = bcso.organization_id or
             cr_b.organization_id is NULL)
      	and   cr_b.inventory_item_id = bcolu.inventory_item_id
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
        and NOT EXISTS
                (select NULL
                from mtl_cross_references
                where inventory_item_id = bcolu.config_item_id
                and (organization_id = bcso.organization_id
		   or organization_id is null)); -- bugfix 1960994: added OR condition


	IF t_cross_ref_type.count <> 0 THEN

	 FORALL i IN 1..t_cross_ref_type.count
           INSERT INTO MTL_CROSS_REFERENCES_B
                            (
                              INVENTORY_ITEM_ID
                             ,ORGANIZATION_ID
                             ,CROSS_REFERENCE_TYPE
                             ,CROSS_REFERENCE
                             ,ORG_INDEPENDENT_FLAG
                             ,LAST_UPDATE_DATE
                             ,LAST_UPDATED_BY
                             ,CREATION_DATE
                             ,CREATED_BY
                             ,LAST_UPDATE_LOGIN
                             ,REQUEST_ID
                             ,PROGRAM_APPLICATION_ID
                             ,PROGRAM_ID
                             ,PROGRAM_UPDATE_DATE
                             ,SOURCE_SYSTEM_ID
                             ,OBJECT_VERSION_NUMBER
                             ,UOM_CODE
                             ,REVISION_ID
                             ,CROSS_REFERENCE_ID
                             ,EPC_GTIN_SERIAL
                             ,ATTRIBUTE1
                             ,ATTRIBUTE2
                             ,ATTRIBUTE3
                             ,ATTRIBUTE4
                             ,ATTRIBUTE5
                             ,ATTRIBUTE6
                             ,ATTRIBUTE7
                             ,ATTRIBUTE8
                             ,ATTRIBUTE9
                             ,ATTRIBUTE10
                             ,ATTRIBUTE11
                             ,ATTRIBUTE12
                             ,ATTRIBUTE13
                             ,ATTRIBUTE14
                             ,ATTRIBUTE15
                             ,ATTRIBUTE_CATEGORY
                           )
                     VALUES
		        (
                         t_cfg_item_id(i)
                        ,t_organization_id(i)
                        ,t_cross_ref_type(i)
  			,t_cross_ref(i)
  			,t_org_independent_flag(i)
  			,SYSDATE
  			,GUSERID
  			,SYSDATE
  			,GUSERID
                        ,GLOGINID
                        ,NULL       --REQUEST_ID
                        ,NULL       --PROGRAM_APPLICATION_ID
  			,NULL       --PROGRAM_ID
  			,SYSDATE    --PROGRAM_UPDATE_DATE
		        ,NULL       --SOURCE_SYSTEM_ID
  			,1          --OBJECT_VERSION_NUMBER
  			,NULL       --UOM_CODE      due to ER#3215422. do not copy uom_code and revision_id attribute for mtl_cross_references
  			,NULL       --REVISION_ID   due to ER#3215422. do not copy uom_code and revision_id attribute for mtl_cross_references
  			,MTL_CROSS_REFERENCES_B_S.NEXTVAL --CROSS_REFERENCE_ID
  			,0          --EPC_GTIN_SERIAL
  			,NULL       --ATTRIBUTE1
  			,NULL       --ATTRIBUTE2
  			,NULL       --ATTRIBUTE3
  			,NULL       --ATTRIBUTE4
  			,NULL       --ATTRIBUTE5
  			,NULL       --ATTRIBUTE6
  			,NULL       --ATTRIBUTE7
 		        ,NULL       --ATTRIBUTE8
 		        ,NULL       --ATTRIBUTE9
  			,NULL       --ATTRIBUTE10
  			,NULL       --ATTRIBUTE11
  			,NULL       --ATTRIBUTE12
  			,NULL       --ATTRIBUTE13
 			,NULL       --ATTRIBUTE14
  			,NULL       --ATTRIBUTE15
  			,NULL       --ATTRIBUTE_CATEGORY
		       );

	  WriteToLog('Inserted rows into mtl_cross_references_b:: '||sql%rowcount,2);

		  FORALL i IN 1..t_cfg_item_id.count
		   INSERT INTO mtl_cross_references_tl (
			  last_update_login
			  ,description
                          ,creation_date
                          ,created_by
                          ,last_update_date
                          ,last_updated_by
                          ,cross_reference_id
                          ,language
                          ,source_lang)
                    SELECT
                          gloginid,
                          mtl.description,
                          sysdate,
                          guserid,
                          sysdate,
                          guserid,
                          mtl_cross.cross_reference_id,
                          l.language_code,
                          userenv('lang')
                    FROM  fnd_languages l,
	                 mtl_cross_references_b mtl_cross,
	                 mtl_system_items_tl mtl
                    WHERE mtl_cross.inventory_item_id = t_cfg_item_id(i)
	            AND   mtl_cross.inventory_item_id = mtl.inventory_item_id
	            AND   mtl_cross.organization_id   = mtl.organization_id
                    AND   l.language_code  = mtl.language
	            AND   l.installed_flag in ('I', 'B')
                    AND  NOT EXISTS  (SELECT null
                           FROM   mtl_cross_references_tl t
                           WHERE  t.cross_reference_id = mtl_cross.cross_reference_id
                           AND    t.language = l.language_code);

	         WriteToLog('Inserted rows into mtl_cross_references_tl:: '||sql%rowcount,2);


        END IF; --t_cross_ref_type.count()

        --end bugfix # 4539578



	/*--------------------------------------+
          Copy Subinventory Defaults
       	+--------------------------------------*/

       	lStmtNumber := 180;

       	insert into mtl_item_sub_defaults
           	(
             	inventory_item_id,
             	organization_id,
             	subinventory_code,
             	default_type,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date
           	)
       	select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
             	bcolu.config_item_id,
             	sd.organization_id,
               	sd.subinventory_code,
               	sd.default_type,
             	sysdate,                     -- last_update_date
             	gUserId,                     -- last_updated_by
             	sysdate,                     -- creation_date
             	gUserId,                     -- created_by
             	gLoginId,                    -- last_update_login
             	NULL,                        -- request_id
             	NULL,                        -- program_application_id
             	NULL,                        -- program_id
             	SYSDATE                      -- program_update_date
      	from
             	mtl_item_sub_defaults sd,
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
      	and  	sd.organization_id = bcso.organization_id
      	and    	sd.inventory_item_id = bcolu.inventory_item_id
        and 	bcso.model_item_id = bcolu.inventory_item_id
        and 	bcso.line_id = bcolu.line_id
        and NOT EXISTS
                (select NULL
                from mtl_item_sub_defaults
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('Inserted rows into mtl_item_sub_defaults:: '||sql%rowcount,2);


        /*--------------------------------------+
          Copy Locator Defaults
        +--------------------------------------*/

        lStmtNumber := 190;
        insert into mtl_item_loc_defaults
                (
                inventory_item_id,
                organization_id,
                locator_id,
                default_type,
                subinventory_code,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date
                )
        select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
                bcolu.config_item_id,
                ld.organization_id,
                ld.locator_id,
                ld.default_type,
                ld.subinventory_code,
                sysdate,                     -- last_update_date
                gUserId,                     -- last_updated_by
                sysdate,                     -- creation_date
                gUserId,                     -- created_by
                gLoginId,                    -- last_update_login
                NULL,                        -- request_id
                NULL,                        -- program_application_id
                NULL,                        -- program_id
                SYSDATE                      -- program_update_date
        from
                mtl_item_loc_defaults   ld,
                bom_cto_src_orgs        bcso,
		bom_cto_order_lines_upg bcolu
      	where   bcolu.config_item_id is not null
	and     bcolu.status = 'BCSO'
        and     ld.organization_id      =       bcso.organization_id
        and     ld.inventory_item_id    =       bcso.model_item_id
        and     bcso.model_item_id      =       bcolu.inventory_item_id
	and     bcso.line_id            =       bcolu.line_id
        and NOT EXISTS
                (select NULL
                from mtl_item_loc_defaults
                where inventory_item_id = bcolu.config_item_id
                and   organization_id = ld.organization_id);


	WriteToLog('Inserted rows into mtl_item_loc_defaults:: '||sql%rowcount,2);
	--
	-- create item attachments in loop
	--
	lStmtNumber := 200;
	FOR v_get_org_id in c_get_org_id LOOP

		fnd_attached_documents2_pkg.copy_attachments (
	 			X_from_entity_name 	=>     'MTL_SYSTEM_ITEMS',
                        	X_from_pk1_value 	=>	v_get_org_id.src_org_id,
                        	X_from_pk2_value 	=>	v_get_org_id.model_item_id,
                        	X_from_pk3_value 	=>	NULL,
                        	X_from_pk4_value 	=>	NULL,
                        	X_from_pk5_value 	=>	NULL,
                        	X_to_entity_name 	=>	'MTL_SYSTEM_ITEMS',
                        	X_to_pk1_value 		=>	v_get_org_id.src_org_id,
                        	X_to_pk2_value 		=>	v_get_org_id.cfg_item_id,
                        	X_to_pk3_value 		=>	NULL,
                        	X_to_pk4_value 		=>	NULL,
                        	X_to_pk5_value 		=>	NULL,
                        	X_created_by 		=>	fnd_global.USER_ID,
                        	X_last_update_login 	=>	fnd_global.USER_ID,
                        	X_program_application_id =>	fnd_global.PROG_APPL_ID,
                        	X_program_id 		=>	fnd_global.CONC_REQUEST_ID,
                        	X_request_id 		=>	fnd_global.USER_ID,
                        	X_automatically_added_flag 	=>	NULL
                        	);

	WriteToLog('Done copy attachment for org id::'|| v_get_org_id.src_org_id,5);
	END LOOP;


EXCEPTION
	WHEN NO_DATA_FOUND THEN
		WriteToLog ('ERROR:NDF in update_item_data'||to_char(lStmtNumber)||sqlerrm,1);
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN FND_API.G_EXC_ERROR THEN
		WriteToLog ('ERROR:Expected error in update_item_data'||to_char(lStmtNumber)||sqlerrm,1);
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		WriteToLog ('ERROR:Unexpected error in update_item_data'||to_char(lStmtNumber)||sqlerrm,1);
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;

     	WHEN OTHERS THEN
		WriteToLog ('ERROR:Others error in update_item_data'||to_char(lStmtNumber)||sqlerrm,1);
        	CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Item_Data;


function get_cost_group( pOrgId  in number,
                         pLineID in number)
return integer is

l_cst_grp   number;

begin

    /*--------------------------------------------+
        This is a function to get cost_group_id
        for using in insert to cst_quantity_layers
    +---------------------------------------------*/

    select  nvl(costing_group_id,1)
    into    l_cst_grp
    from    pjm_project_parameters ppp
    where   ppp.project_id = ( select  project_id
                               from    oe_order_lines_all ol
                               where   ol.line_id = pLineId )
    and    ppp.organization_id = pOrgId;

    if (l_cst_grp = 0) then
                l_cst_grp := 1;
    end if;

    return(l_cst_grp);

exception
    when no_data_found then
	WriteToLog('get_cost_group: ' || 'ERROR: Could not fetch the cost_group_id from pjm_project_parameters (NDF)',1);
	return(0);

end get_cost_group;


PROCEDURE Update_Acc_Items(
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2)

IS

lStmtNumber         number;
lItemType           varchar2(30);

BEGIN

	WriteToLog('Entering Update_Acc_Items', 3);

	lStmtNumber := 10;
	xReturnStatus := FND_API.G_RET_STS_SUCCESS;

	lItemType :=  FND_PROFILE.Value('BOM:CONFIG_ITEM_TYPE');

	--perf bugfix	4905887 (sql id 16105473)
	--Removed comments to extent possible

        -- Bug 9223457.added additional attribute columns added in 12.1
        -- for mtl_sys_items.pdube

        insert into mtl_system_items_b
                (inventory_item_id,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                summary_flag,
                enabled_flag,
                start_date_active,
                end_date_active,
                description,
                buyer_id,
                accounting_rule_id,
                invoicing_rule_id,
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
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
                attribute16,  -- Bug 9223457
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                purchasing_item_flag,
                shippable_item_flag,
                customer_order_flag,
                internal_order_flag,
                service_item_flag,
                inventory_item_flag,
                eng_item_flag,
                inventory_asset_flag,
                purchasing_enabled_flag,
                customer_order_enabled_flag,
                internal_order_enabled_flag,
                so_transactions_flag,
                mtl_transactions_enabled_flag,
                stock_enabled_flag,
                bom_enabled_flag,
                build_in_wip_flag,
                revision_qty_control_code,
                item_catalog_group_id,
                catalog_status_flag,
                returnable_flag,
                default_shipping_org,
                collateral_flag,
                taxable_flag,
                allow_item_desc_update_flag,
                inspection_required_flag,
                receipt_required_flag,
                market_price,
                hazard_class_id,
                rfq_required_flag,
                qty_rcv_tolerance,
                un_number_id,
                price_tolerance_percent,
                asset_category_id,
                rounding_factor,
                unit_of_issue,
                enforce_ship_to_location_code,
                allow_substitute_receipts_flag,
                allow_unordered_receipts_flag,
                allow_express_delivery_flag,
                days_early_receipt_allowed,
                days_late_receipt_allowed,
                receipt_days_exception_code,
                receiving_routing_id,
                invoice_close_tolerance,
                receive_close_tolerance,
                auto_lot_alpha_prefix,
                start_auto_lot_number,
                lot_control_code,
                shelf_life_code,
                shelf_life_days,
                serial_number_control_code,
                start_auto_serial_number,
                auto_serial_alpha_prefix,
                source_type,
                source_organization_id,
                source_subinventory,
                expense_account,
                encumbrance_account,
                restrict_subinventories_code,
                unit_weight,
                weight_uom_code,
                volume_uom_code,
                unit_volume,
                restrict_locators_code,
                location_control_code,
                shrinkage_rate,
                acceptable_early_days,
                planning_time_fence_code,
                demand_time_fence_code,
                lead_time_lot_size,
                std_lot_size,
                cum_manufacturing_lead_time,
                overrun_percentage,
                acceptable_rate_increase,
                acceptable_rate_decrease,
                cumulative_total_lead_time,
                planning_time_fence_days,
                demand_time_fence_days,
                end_assembly_pegging_flag,
                planning_exception_set,
                bom_item_type,
                pick_components_flag,
                replenish_to_order_flag,
                base_item_id,
                atp_components_flag,
                atp_flag,
                fixed_lead_time,
                variable_lead_time,
                wip_supply_locator_id,
                wip_supply_type,
                wip_supply_subinventory,
                primary_uom_code,
                primary_unit_of_measure,
                allowed_units_lookup_code,
                cost_of_sales_account,
                sales_account,
                default_include_in_rollup_flag,
                inventory_item_status_code,
                inventory_planning_code,
                planner_code,
                planning_make_buy_code,
                fixed_lot_multiplier,
                rounding_control_type,
                carrying_cost,
                postprocessing_lead_time,
                preprocessing_lead_time,
                full_lead_time,
                order_cost,
                mrp_safety_stock_percent,
                mrp_safety_stock_code,
                min_minmax_quantity,
                max_minmax_quantity,
                minimum_order_quantity,
                fixed_order_quantity,
                fixed_days_supply,
                maximum_order_quantity,
                atp_rule_id,
                picking_rule_id,
                reservable_type,
                positive_measurement_error,
                negative_measurement_error,
                engineering_ecn_code,
                engineering_item_id,
                engineering_date,
                service_starting_delay,
                vendor_warranty_flag,
                serviceable_component_flag,
                serviceable_product_flag,
                base_warranty_service_id,
                payment_terms_id,
                preventive_maintenance_flag,
                primary_specialist_id,
                secondary_specialist_id,
                serviceable_item_class_id,
                time_billable_flag,
                material_billable_flag,
                expense_billable_flag,
                prorate_service_flag,
                coverage_schedule_id,
                service_duration_period_code,
                service_duration,
                max_warranty_amount,
                response_time_period_code,
                response_time_value,
                new_revision_code,
                tax_code,
                must_use_approved_vendor_flag,
                safety_stock_bucket_days,
                auto_reduce_mps,
                costing_enabled_flag,
                invoiceable_item_flag,
                invoice_enabled_flag,
                outside_operation_flag,
                outside_operation_uom_type,
                auto_created_config_flag,
                cycle_count_enabled_flag,
                item_type,
                model_config_clause_name,
                ship_model_complete_flag,
                mrp_planning_code,
                repetitive_planning_flag,
                return_inspection_requirement,
                effectivity_control,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
		comms_nl_trackable_flag,
		default_so_source_type,
		create_supply_flag,
		lot_status_enabled,
		default_lot_status_id,
		serial_status_enabled,
		default_serial_status_id,
		lot_split_enabled,
		lot_merge_enabled,
		bulk_picked_flag,
		FINANCING_ALLOWED_FLAG,
 		EAM_ITEM_TYPE ,
 		EAM_ACTIVITY_TYPE_CODE,
 		EAM_ACTIVITY_CAUSE_CODE,
 		EAM_ACT_NOTIFICATION_FLAG,
 		EAM_ACT_SHUTDOWN_STATUS,
 		SUBSTITUTION_WINDOW_CODE,
 		SUBSTITUTION_WINDOW_DAYS,
 		PRODUCT_FAMILY_ITEM_ID,
 		CHECK_SHORTAGES_FLAG,
 		PLANNED_INV_POINT_FLAG,
 		OVER_SHIPMENT_TOLERANCE,
 		UNDER_SHIPMENT_TOLERANCE,
 		OVER_RETURN_TOLERANCE,
 		UNDER_RETURN_TOLERANCE,
 		PURCHASING_TAX_CODE,
 		OVERCOMPLETION_TOLERANCE_TYPE,
 		OVERCOMPLETION_TOLERANCE_VALUE,
 		INVENTORY_CARRY_PENALTY,
 		OPERATION_SLACK_PENALTY,
 		UNIT_LENGTH,
 		UNIT_WIDTH,
 		UNIT_HEIGHT,
 		LOT_TRANSLATE_ENABLED,
 		CONTAINER_ITEM_FLAG,
 		VEHICLE_ITEM_FLAG,
 		DIMENSION_UOM_CODE,
 		SECONDARY_UOM_CODE,
 		MAXIMUM_LOAD_WEIGHT,
 		MINIMUM_FILL_PERCENT,
 		CONTAINER_TYPE_CODE,
 		INTERNAL_VOLUME,
 		EQUIPMENT_TYPE,
 		INDIVISIBLE_FLAG,
 		GLOBAL_ATTRIBUTE_CATEGORY,
 		GLOBAL_ATTRIBUTE1,
 		GLOBAL_ATTRIBUTE2,
 		GLOBAL_ATTRIBUTE3,
 		GLOBAL_ATTRIBUTE4,
 		GLOBAL_ATTRIBUTE5,
 		GLOBAL_ATTRIBUTE6,
 		GLOBAL_ATTRIBUTE7,
 		GLOBAL_ATTRIBUTE8,
 		GLOBAL_ATTRIBUTE9,
 		GLOBAL_ATTRIBUTE10,
		DUAL_UOM_CONTROL,
 		DUAL_UOM_DEVIATION_HIGH,
 		DUAL_UOM_DEVIATION_LOW,
                CONTRACT_ITEM_TYPE_CODE,
 		SUBSCRIPTION_DEPEND_FLAG,
 		SERV_REQ_ENABLED_CODE,
 		SERV_BILLING_ENABLED_FLAG,
 		RELEASE_TIME_FENCE_CODE,
 		RELEASE_TIME_FENCE_DAYS,
 		DEFECT_TRACKING_ON_FLAG,
 		SERV_IMPORTANCE_LEVEL,
	        WEB_STATUS,
		tracking_quantity_ind,
                ont_pricing_qty_source,
                approval_status,
		vmi_minimum_units,
		vmi_minimum_days,
		vmi_maximum_units,
		vmi_maximum_days,
		vmi_fixed_order_quantity,
		so_authorization_flag,
		consigned_flag,
		asn_autoexpire_flag,
		vmi_forecast_type,
		forecast_horizon,
		days_tgt_inv_supply,
		days_tgt_inv_window,
		days_max_inv_supply,
		days_max_inv_window,
		critical_component_flag,
		drp_planned_flag,
		exclude_from_budget_flag,
		convergence,
		continous_transfer,
		divergence,
			--r12,4574899
		lot_divisible_flag,
		grade_control_flag,
		child_lot_flag,
                child_lot_validation_flag,
		copy_lot_attribute_flag,
		parent_child_generation_flag,  --Bugfix 8821149
		lot_substitution_enabled,      --Bugfix 8821149
		recipe_enabled_flag,
                process_quality_enabled_flag,
		process_execution_enabled_flag,
	        process_costing_enabled_flag,
		hazardous_material_flag,
		preposition_point,
		repair_program,
		outsourced_assembly

                )
        select distinct
                bcolu.config_item_id,
                mp1.organization_id,
                sysdate,
                gUserId,
                sysdate,
                gUserId,
                gLoginId ,
                m.summary_flag,
                m.enabled_flag,
                m.start_date_active,
                m.end_date_active,
                m.description,
                m.buyer_id,
                m.accounting_rule_id,
                m.invoicing_rule_id,
		-- c.  copy from config item
                c.segment1,
		c.segment2,
		c.segment3,
		c.segment4,
		c.segment5,
		c.segment6,
		c.segment7,
		c.segment8,
		c.segment9,
		c.segment10,
                c.segment11,
		c.segment12,
		c.segment13,
		c.segment14,
		c.segment15,
		c.segment16,
		c.segment17,
		c.segment18,
		c.segment19,
		c.segment20,
                m.attribute_category,
                m.attribute1,
                m.attribute2,
                m.attribute3,
                m.attribute4,
                m.attribute5,
                m.attribute6,
                m.attribute7,
                m.attribute8,
                m.attribute9,
                m.attribute10,
                m.attribute11,
                m.attribute12,
                m.attribute13,
                m.attribute14,
                m.attribute15,
                m.attribute16,  -- Bug 9223457
                m.attribute17,
                m.attribute18,
                m.attribute19,
                m.attribute20,
                m.attribute21,
                m.attribute22,
                m.attribute23,
                m.attribute24,
                m.attribute25,
                m.attribute26,
                m.attribute27,
                m.attribute28,
                m.attribute29,
                m.attribute30,
                'Y',
                'Y',
                'Y',
                'Y',
                m.service_item_flag,
                'Y',
                m.eng_item_flag,
                m.inventory_asset_flag,
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                m.revision_qty_control_code,
                m.item_catalog_group_id,
                m.catalog_status_flag,
                m.returnable_flag,
                m.default_shipping_org,
                m.collateral_flag,
                m.taxable_flag,
                m.allow_item_desc_update_flag,
                m.inspection_required_flag,
                m.receipt_required_flag,
                m.market_price,
                m.hazard_class_id,
                m.rfq_required_flag,
                m.qty_rcv_tolerance,
                m.un_number_id,
                m.price_tolerance_percent,
                m.asset_category_id,
                m.rounding_factor,
                m.unit_of_issue,
                m.enforce_ship_to_location_code,
                m.allow_substitute_receipts_flag,
                m.allow_unordered_receipts_flag,
                m.allow_express_delivery_flag,
                m.days_early_receipt_allowed,
                m.days_late_receipt_allowed,
                m.receipt_days_exception_code,
                m.receiving_routing_id,
                m.invoice_close_tolerance,
                m.receive_close_tolerance,
                m.auto_lot_alpha_prefix,
                m.start_auto_lot_number,
                m.lot_control_code,
                m.shelf_life_code,
                m.shelf_life_days,
                m.serial_number_control_code,
                m.start_auto_serial_number,
                m.auto_serial_alpha_prefix,
                m.source_type,
                m.source_organization_id,
                m.source_subinventory,
                m.expense_account,
                m.encumbrance_account,
                m.restrict_subinventories_code,
		-- c. copy from config item
                c.unit_weight,
                c.weight_uom_code,
                c.volume_uom_code,
                c.unit_volume,
                m.restrict_locators_code,
                m.location_control_code,
                m.shrinkage_rate,
                m.acceptable_early_days,
                m.planning_time_fence_code,
                m.demand_time_fence_code,
                m.lead_time_lot_size,
                m.std_lot_size,
                m.cum_manufacturing_lead_time,
                m.overrun_percentage,
                m.acceptable_rate_increase,
                m.acceptable_rate_decrease,
                m.cumulative_total_lead_time,
                m.planning_time_fence_days,
                m.demand_time_fence_days,
                m.end_assembly_pegging_flag,
                m.planning_exception_set,
                4,		-- BOM_ITEM_TYPE:standard
                'N',
                'Y',
                m.inventory_item_id,	-- Base Model ID
                CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(m.atp_flag, m.atp_components_flag),
                CTO_CONFIG_ITEM_PK.get_atp_flag,
                m.fixed_lead_time,
                m.variable_lead_time,
                m.wip_supply_locator_id,
                m.wip_supply_type,
                m.wip_supply_subinventory,
                m.primary_uom_code,
                m.primary_unit_of_measure,
                m.allowed_units_lookup_code,
                m.cost_of_sales_account,
                m.sales_account,
                'Y',
                m.inventory_item_status_code,
                m.inventory_planning_code,
                m.planner_code,
                m.planning_make_buy_code,
                m.fixed_lot_multiplier,
                m.rounding_control_type,
                m.carrying_cost,
                m.postprocessing_lead_time,
                m.preprocessing_lead_time,
                m.full_lead_time,
                m.order_cost,
                m.mrp_safety_stock_percent,
                m.mrp_safety_stock_code,
                m.min_minmax_quantity,
                m.max_minmax_quantity,
                m.minimum_order_quantity,
                m.fixed_order_quantity,
                m.fixed_days_supply,
                m.maximum_order_quantity,
                m.atp_rule_id,
                m.picking_rule_id,
                1,              -- m.reservable_type
                m.positive_measurement_error,
                m.negative_measurement_error,
                m.engineering_ecn_code,
                m.engineering_item_id,
                m.engineering_date,
                m.service_starting_delay,
                m.vendor_warranty_flag,
                m.serviceable_component_flag,
                m.serviceable_product_flag,
                m.base_warranty_service_id,
                m.payment_terms_id,
                m.preventive_maintenance_flag,
                m.primary_specialist_id,
                m.secondary_specialist_id,
                m.serviceable_item_class_id,
                m.time_billable_flag,
                m.material_billable_flag,
                m.expense_billable_flag,
                m.prorate_service_flag,
                m.coverage_schedule_id,
                m.service_duration_period_code,
                m.service_duration,
                m.max_warranty_amount,
                m.response_time_period_code,
                m.response_time_value,
                m.new_revision_code,
                m.tax_code,
                m.must_use_approved_vendor_flag,
                m.safety_stock_bucket_days,
                m.auto_reduce_mps,
                m.costing_enabled_flag,
                m.invoiceable_item_flag,
                m.invoice_enabled_flag,
                m.outside_operation_flag,
                m.outside_operation_uom_type,
                'Y',		-- auto created config flag
                m.cycle_count_enabled_flag,
                lItemType,	--copy from profile
                m.model_config_clause_name,
                m.ship_model_complete_flag,
                m.mrp_planning_code,
                m.repetitive_planning_flag,
                m.return_inspection_requirement,
                nvl(m.effectivity_control, 1),
                null,
                null,
                99,           -- prg_id (to identify orgs where item is created by this program)
                sysdate,
		m.comms_nl_trackable_flag,
		nvl(m.default_so_source_type,'INTERNAL'),
		nvl(m.create_supply_flag, 'Y'),
		m.lot_status_enabled,
		m.default_lot_status_id,
		m.serial_status_enabled,
		m.default_serial_status_id,
		m.lot_split_enabled,
		m.lot_merge_enabled,
		m.bulk_picked_flag,
		m.FINANCING_ALLOWED_FLAG,
 		m.EAM_ITEM_TYPE ,
 		m.EAM_ACTIVITY_TYPE_CODE,
 		m.EAM_ACTIVITY_CAUSE_CODE,
 		m.EAM_ACT_NOTIFICATION_FLAG,
 		m.EAM_ACT_SHUTDOWN_STATUS,
 		m.SUBSTITUTION_WINDOW_CODE,
 		m.SUBSTITUTION_WINDOW_DAYS,
 		null,--5385901 m.PRODUCT_FAMILY_ITEM_ID,
 		m.CHECK_SHORTAGES_FLAG,
 		m.PLANNED_INV_POINT_FLAG,
 		m.OVER_SHIPMENT_TOLERANCE,
 		m.UNDER_SHIPMENT_TOLERANCE,
 		m.OVER_RETURN_TOLERANCE,
 		m.UNDER_RETURN_TOLERANCE,
 		m.PURCHASING_TAX_CODE,
 		m.OVERCOMPLETION_TOLERANCE_TYPE,
 		m.OVERCOMPLETION_TOLERANCE_VALUE,
 		m.INVENTORY_CARRY_PENALTY,
 		m.OPERATION_SLACK_PENALTY,
 		m.UNIT_LENGTH,
 		m.UNIT_WIDTH,
 		m.UNIT_HEIGHT,
 		m.LOT_TRANSLATE_ENABLED,
 		m.CONTAINER_ITEM_FLAG,
 		m.VEHICLE_ITEM_FLAG,
 		m.DIMENSION_UOM_CODE,
 		m.SECONDARY_UOM_CODE,
 		m.MAXIMUM_LOAD_WEIGHT,
 		m.MINIMUM_FILL_PERCENT,
 		m.CONTAINER_TYPE_CODE,
 		m.INTERNAL_VOLUME,
 		m.EQUIPMENT_TYPE,
 		m.INDIVISIBLE_FLAG,
 		m.GLOBAL_ATTRIBUTE_CATEGORY,
 		m.GLOBAL_ATTRIBUTE1,
 		m.GLOBAL_ATTRIBUTE2,
 		m.GLOBAL_ATTRIBUTE3,
 		m.GLOBAL_ATTRIBUTE4,
 		m.GLOBAL_ATTRIBUTE5,
 		m.GLOBAL_ATTRIBUTE6,
 		m.GLOBAL_ATTRIBUTE7,
 		m.GLOBAL_ATTRIBUTE8,
 		m.GLOBAL_ATTRIBUTE9,
 		m.GLOBAL_ATTRIBUTE10,
     		m.DUAL_UOM_CONTROL,
 		m.DUAL_UOM_DEVIATION_HIGH,
 		m.DUAL_UOM_DEVIATION_LOW,
                m.CONTRACT_ITEM_TYPE_CODE,
 		m.SUBSCRIPTION_DEPEND_FLAG,
 		m.SERV_REQ_ENABLED_CODE,
 		m.SERV_BILLING_ENABLED_FLAG,
 		m.RELEASE_TIME_FENCE_CODE,
 		m.RELEASE_TIME_FENCE_DAYS,
 		m.DEFECT_TRACKING_ON_FLAG,
 		m.SERV_IMPORTANCE_LEVEL,
	        m.web_status,
		m.tracking_quantity_ind,
                m.ont_pricing_qty_source,
                m.approval_status,
		m.vmi_minimum_units,
		m.vmi_minimum_days,
		m.vmi_maximum_units,
		m.vmi_maximum_days,
		m.vmi_fixed_order_quantity,
		m.so_authorization_flag,
		m.consigned_flag,
		m.asn_autoexpire_flag,
		m.vmi_forecast_type,
		m.forecast_horizon,
		m.days_tgt_inv_supply,
		m.days_tgt_inv_window,
		m.days_max_inv_supply,
		m.days_max_inv_window,
		m.critical_component_flag,
		m.drp_planned_flag,
		m.exclude_from_budget_flag,
		m.convergence,
		m.continous_transfer,
		m.divergence,
		  --r12,4574899
		'N',
		'N',
		/* Bugfix 8821149: Will populate these values from model.
		'N',
	        'N',
		'N',
		*/
		m.child_lot_flag,
		m.child_lot_validation_flag,
		m.copy_lot_attribute_flag,
		m.parent_child_generation_flag,
		m.lot_substitution_enabled,
		-- End Bugfix 8821149
		'N',
		'N',
		'N',
		'N',
		'N',
		'N',
		3,
		2

       from
                mtl_parameters mp1,
                mtl_system_items_b m,	-- model
		mtl_system_items_b c,	-- config
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
        where bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
	and m.inventory_item_id = bcolu.inventory_item_id
	-- get config item row for any one org
	and c.inventory_item_id = bcolu.config_item_id
	and c.organization_id = ( select organization_id from mtl_system_items
                                where inventory_item_id = c.inventory_item_id and rownum = 1) /*BUGFIX 3576040 */
	-- config is not pc in any orgs
	and not exists
		(select 'pc'
		from mtl_system_items msi1
		where msi1.inventory_item_id = bcolu.config_item_id
		and nvl(msi1.auto_created_config_flag,'N') = 'N')
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
        and m.organization_id = mp1.organization_id
        and mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_system_items_b
                where inventory_item_id = bcolu.config_item_id
                and organization_id = mp1.organization_id);

	WriteToLog('Items created::'||sql%rowcount, 2);

EXCEPTION
     	WHEN OTHERS THEN
		WriteToLog ('ERROR: Others error in Update_Acc_Items::'||to_char(lStmtNumber)||sqlerrm,1);
        	CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Acc_Items;


FUNCTION get_attribute_control( p_attribute_name in varchar2)
RETURN NUMBER
IS

v_attribute_name varchar2(100);

BEGIN
   v_attribute_name := UPPER( p_attribute_name );

   for i in 1..g_attribute_name_tab.count
   loop
       if( g_attribute_name_tab(i) = v_attribute_name ) then
           return g_control_level_tab(i);
       end if;

   end loop ;

   return 0;

END get_attribute_control;


PROCEDURE Update_Pc_Items(
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2)
IS

lStmtNumber         number;
lItemType           varchar2(30);

BEGIN

	WriteToLog('Entering Update_Pc_Items', 3);
	lStmtNumber := 10;
	xReturnStatus := FND_API.G_RET_STS_SUCCESS;

	lItemType :=  FND_PROFILE.Value('BOM:CONFIG_ITEM_TYPE');

	select substr(attribute_name, instr(attribute_name, '.' )+ 1), control_level
	BULK COLLECT
	INTO g_attribute_name_tab, g_control_level_tab
	from mtl_item_attributes
	where control_level = 1 ;


	--perf bugfix	4905887 (sql id 16105473)
	--Removed comments to extent possible

	lStmtNumber := 20;
        insert into mtl_system_items_b
                (inventory_item_id,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                summary_flag,
                enabled_flag,
                start_date_active,
                end_date_active,
                description,
                buyer_id,
                accounting_rule_id,
                invoicing_rule_id,
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
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
                attribute16,  -- Bug 9223457
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                purchasing_item_flag,
                shippable_item_flag,
                customer_order_flag,
                internal_order_flag,
                service_item_flag,
                inventory_item_flag,
                eng_item_flag,
                inventory_asset_flag,
                purchasing_enabled_flag,
                customer_order_enabled_flag,
                internal_order_enabled_flag,
                so_transactions_flag,
                mtl_transactions_enabled_flag,
                stock_enabled_flag,
                bom_enabled_flag,
                build_in_wip_flag,
                revision_qty_control_code,
                item_catalog_group_id,
                catalog_status_flag,
                returnable_flag,
                default_shipping_org,
                collateral_flag,
                taxable_flag,
                allow_item_desc_update_flag,
                inspection_required_flag,
                receipt_required_flag,
                market_price,
                hazard_class_id,
                rfq_required_flag,
                qty_rcv_tolerance,
                un_number_id,
                price_tolerance_percent,
                asset_category_id,
                rounding_factor,
                unit_of_issue,
                enforce_ship_to_location_code,
                allow_substitute_receipts_flag,
                allow_unordered_receipts_flag,
                allow_express_delivery_flag,
                days_early_receipt_allowed,
                days_late_receipt_allowed,
                receipt_days_exception_code,
                receiving_routing_id,
                invoice_close_tolerance,
                receive_close_tolerance,
                auto_lot_alpha_prefix,
                start_auto_lot_number,
                lot_control_code,
                shelf_life_code,
                shelf_life_days,
                serial_number_control_code,
                start_auto_serial_number,
                auto_serial_alpha_prefix,
                source_type,
                source_organization_id,
                source_subinventory,
                expense_account,
                encumbrance_account,
                restrict_subinventories_code,
                unit_weight,
                weight_uom_code,
                volume_uom_code,
                unit_volume,
                restrict_locators_code,
                location_control_code,
                shrinkage_rate,
                acceptable_early_days,
                planning_time_fence_code,
                demand_time_fence_code,
                lead_time_lot_size,
                std_lot_size,
                cum_manufacturing_lead_time,
                overrun_percentage,
                acceptable_rate_increase,
                acceptable_rate_decrease,
                cumulative_total_lead_time,
                planning_time_fence_days,
                demand_time_fence_days,
                end_assembly_pegging_flag,
                planning_exception_set,
                bom_item_type,
                pick_components_flag,
                replenish_to_order_flag,
                base_item_id,
                atp_components_flag,
                atp_flag,
                fixed_lead_time,
                variable_lead_time,
                wip_supply_locator_id,
                wip_supply_type,
                wip_supply_subinventory,
                primary_uom_code,
                primary_unit_of_measure,
                allowed_units_lookup_code,
                cost_of_sales_account,
                sales_account,
                default_include_in_rollup_flag,
                inventory_item_status_code,
                inventory_planning_code,
                planner_code,
                planning_make_buy_code,
                fixed_lot_multiplier,
                rounding_control_type,
                carrying_cost,
                postprocessing_lead_time,
                preprocessing_lead_time,
                full_lead_time,
                order_cost,
                mrp_safety_stock_percent,
                mrp_safety_stock_code,
                min_minmax_quantity,
                max_minmax_quantity,
                minimum_order_quantity,
                fixed_order_quantity,
                fixed_days_supply,
                maximum_order_quantity,
                atp_rule_id,
                picking_rule_id,
                reservable_type,
                positive_measurement_error,
                negative_measurement_error,
                engineering_ecn_code,
                engineering_item_id,
                engineering_date,
                service_starting_delay,
                vendor_warranty_flag,
                serviceable_component_flag,
                serviceable_product_flag,
                base_warranty_service_id,
                payment_terms_id,
                preventive_maintenance_flag,
                primary_specialist_id,
                secondary_specialist_id,
                serviceable_item_class_id,
                time_billable_flag,
                material_billable_flag,
                expense_billable_flag,
                prorate_service_flag,
                coverage_schedule_id,
                service_duration_period_code,
                service_duration,
                max_warranty_amount,
                response_time_period_code,
                response_time_value,
                new_revision_code,
                tax_code,
                must_use_approved_vendor_flag,
                safety_stock_bucket_days,
                auto_reduce_mps,
                costing_enabled_flag,
                invoiceable_item_flag,
                invoice_enabled_flag,
                outside_operation_flag,
                outside_operation_uom_type,
                auto_created_config_flag,
                cycle_count_enabled_flag,
                item_type,
                model_config_clause_name,
                ship_model_complete_flag,
                mrp_planning_code,
                repetitive_planning_flag,
                return_inspection_requirement,
                effectivity_control,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
		comms_nl_trackable_flag,
		default_so_source_type,
		create_supply_flag,
		lot_status_enabled,
		default_lot_status_id,
		serial_status_enabled,
		default_serial_status_id,
		lot_split_enabled,
		lot_merge_enabled,
		bulk_picked_flag,
		FINANCING_ALLOWED_FLAG,
 		EAM_ITEM_TYPE ,
 		EAM_ACTIVITY_TYPE_CODE,
 		EAM_ACTIVITY_CAUSE_CODE,
 		EAM_ACT_NOTIFICATION_FLAG,
 		EAM_ACT_SHUTDOWN_STATUS,
 		SUBSTITUTION_WINDOW_CODE,
 		SUBSTITUTION_WINDOW_DAYS,
 		PRODUCT_FAMILY_ITEM_ID,
 		CHECK_SHORTAGES_FLAG,
 		PLANNED_INV_POINT_FLAG,
 		OVER_SHIPMENT_TOLERANCE,
 		UNDER_SHIPMENT_TOLERANCE,
 		OVER_RETURN_TOLERANCE,
 		UNDER_RETURN_TOLERANCE,
 		PURCHASING_TAX_CODE,
 		OVERCOMPLETION_TOLERANCE_TYPE,
 		OVERCOMPLETION_TOLERANCE_VALUE,
 		INVENTORY_CARRY_PENALTY,
 		OPERATION_SLACK_PENALTY,
 		UNIT_LENGTH,
 		UNIT_WIDTH,
 		UNIT_HEIGHT,
 		LOT_TRANSLATE_ENABLED,
 		CONTAINER_ITEM_FLAG,
 		VEHICLE_ITEM_FLAG,
 		DIMENSION_UOM_CODE,
 		SECONDARY_UOM_CODE,
 		MAXIMUM_LOAD_WEIGHT,
 		MINIMUM_FILL_PERCENT,
 		CONTAINER_TYPE_CODE,
 		INTERNAL_VOLUME,
 		EQUIPMENT_TYPE,
 		INDIVISIBLE_FLAG,
 		GLOBAL_ATTRIBUTE_CATEGORY,
 		GLOBAL_ATTRIBUTE1,
 		GLOBAL_ATTRIBUTE2,
 		GLOBAL_ATTRIBUTE3,
 		GLOBAL_ATTRIBUTE4,
 		GLOBAL_ATTRIBUTE5,
 		GLOBAL_ATTRIBUTE6,
 		GLOBAL_ATTRIBUTE7,
 		GLOBAL_ATTRIBUTE8,
 		GLOBAL_ATTRIBUTE9,
 		GLOBAL_ATTRIBUTE10,
		DUAL_UOM_CONTROL,
 		DUAL_UOM_DEVIATION_HIGH,
 		DUAL_UOM_DEVIATION_LOW,
                CONTRACT_ITEM_TYPE_CODE,
 		SUBSCRIPTION_DEPEND_FLAG,
 		SERV_REQ_ENABLED_CODE,
 		SERV_BILLING_ENABLED_FLAG,
 		RELEASE_TIME_FENCE_CODE,
 		RELEASE_TIME_FENCE_DAYS,
 		DEFECT_TRACKING_ON_FLAG,
 		SERV_IMPORTANCE_LEVEL,
	        WEB_STATUS,
		tracking_quantity_ind,
                ont_pricing_qty_source,
                approval_status,
		vmi_minimum_units,
		vmi_minimum_days,
		vmi_maximum_units,
		vmi_maximum_days,
		vmi_fixed_order_quantity,
		so_authorization_flag,
		consigned_flag,
		asn_autoexpire_flag,
		vmi_forecast_type,
		forecast_horizon,
		days_tgt_inv_supply,
		days_tgt_inv_window,
		days_max_inv_supply,
		days_max_inv_window,
		critical_component_flag,
		drp_planned_flag,
		exclude_from_budget_flag,
		convergence,
		continous_transfer,
		divergence,
			--r12,4574899
		lot_divisible_flag,
		grade_control_flag,
		child_lot_flag,
                child_lot_validation_flag,
		copy_lot_attribute_flag,
		parent_child_generation_flag,  --Bugfix 8821149
		lot_substitution_enabled,      --Bugfix 8821149
		recipe_enabled_flag,
                process_quality_enabled_flag,
		process_execution_enabled_flag,
	        process_costing_enabled_flag,
		hazardous_material_flag,
		preposition_point,
		repair_program,
		outsourced_assembly


                )
        select /*+ INDEX ( BOM_CTO_ORDER_LINES_UPG BOM_CTO_ORDER_LINES_UPG_U1 ) */
                distinct
                bcolu.config_item_id,
                m.organization_id,
                sysdate,
                gUserId,          -- last_updated_by
                sysdate,
                gUserId,          -- created_by
                gLoginId ,        -- last_update_login
                decode( get_attribute_control( 'summary_flag') , 1 , config.summary_flag, m.summary_flag),
                decode( get_attribute_control( 'enabled_flag' ) , 1 , config.enabled_flag , m.enabled_flag),
                decode( get_attribute_control( 'start_date_active'), 1 , config.start_date_active, m.start_date_active) ,
                decode( get_attribute_control( 'end_date_active'), 1 , config.end_date_active, m.end_date_active) ,
                decode( get_attribute_control( 'description' ) , 1 , config.description, m.description) ,
                decode( get_attribute_control( 'buyer_id') , 1 , config.buyer_id, m.buyer_id) ,
                decode( get_attribute_control( 'accounting_rule_id' ) , 1 , config.accounting_rule_id, m.accounting_rule_id) ,
                decode( get_attribute_control( 'invoicing_rule_id' ) , 1 , config.invoicing_rule_id, m.invoicing_rule_id) ,
                config.segment1,
                config.segment2,
                config.segment3,
                config.segment4,
                config.segment5,
                config.segment6,
                config.segment7,
                config.segment8,
                config.segment9,
                config.segment10,
                config.segment11,
                config.segment12,
                config.segment13,
                config.segment14,
                config.segment15,
                config.segment16,
                config.segment17,
                config.segment18,
                config.segment19,
                config.segment20,
                decode(get_attribute_control( 'attribute_category'), 1 , config.attribute_category, m.attribute_category),
                m.attribute1,
                m.attribute2,
                m.attribute3,
                m.attribute4,
                m.attribute5,
                m.attribute6,
                m.attribute7,
                m.attribute8,
                m.attribute9,
                m.attribute10,
                m.attribute11,
                m.attribute12,
                m.attribute13,
                m.attribute14,
                m.attribute15,
                m.attribute16,  -- Bug 9223457
                m.attribute17,
                m.attribute18,
                m.attribute19,
                m.attribute20,
                m.attribute21,
                m.attribute22,
                m.attribute23,
                m.attribute24,
                m.attribute25,
                m.attribute26,
                m.attribute27,
                m.attribute28,
                m.attribute29,
                m.attribute30,
                'Y',
                'Y',
                'Y',
                'Y',
                decode( get_attribute_control( 'service_item_flag' ), 1, config.service_item_flag , m.service_item_flag) ,
                'Y',
                decode( get_attribute_control( 'eng_item_flag' ) , 1 , config.eng_item_flag , m.eng_item_flag) ,
                decode( get_attribute_control( 'inventory_asset_flag' ) , 1 , config.inventory_asset_flag , m.inventory_asset_flag) ,
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                decode( get_attribute_control( 'revision_qty_control_code' ) , 1 , config.revision_qty_control_code , m.revision_qty_control_code) ,
                decode( get_attribute_control( 'item_catalog_group_id' ) , 1 , config.item_catalog_group_id, m.item_catalog_group_id) ,
                decode( get_attribute_control( 'catalog_status_flag' ) , 1 , config.catalog_status_flag, m.catalog_status_flag) ,
                decode( get_attribute_control( 'returnable_flag' ) , 1 , config.returnable_flag, m.returnable_flag) ,
                decode( get_attribute_control( 'default_shipping_org' ) , 1, config.default_shipping_org, m.default_shipping_org),
                decode( get_attribute_control( 'collateral_flag') , 1 , config.collateral_flag , m.collateral_flag) ,
                decode( get_attribute_control( 'taxable_flag' ) , 1 , config.taxable_flag, m.taxable_flag) ,
                decode( get_attribute_control( 'allow_item_desc_update_flag' ) , 1, config.allow_item_desc_update_flag, m.allow_item_desc_update_flag),
                decode( get_attribute_control( 'inspection_required_flag' ), 1 , config.inspection_required_flag , m.inspection_required_flag),
                decode( get_attribute_control( 'receipt_required_flag' ), 1, config.receipt_required_flag, m.receipt_required_flag) ,
                decode( get_attribute_control( 'market_price' ) , 1 , config.market_price, m.market_price) ,
                decode( get_attribute_control( 'hazard_class_id' ), 1 , config.hazard_class_id, m.hazard_class_id),
                decode( get_attribute_control( 'rfq_required_flag'), 1 , config.rfq_required_flag, m.rfq_required_flag),
                decode( get_attribute_control( 'qty_rcv_tolerance'), 1, config.qty_rcv_tolerance, m.qty_rcv_tolerance),
                decode( get_attribute_control( 'un_number_id' ), 1 , config.un_number_id, m.un_number_id),
                decode( get_attribute_control( 'price_tolerance_percent'), 1 , config.price_tolerance_percent, m.price_tolerance_percent) ,
                decode( get_attribute_control( 'asset_category_id') , 1 , config.asset_category_id, m.asset_category_id) ,
                decode( get_attribute_control( 'rounding_factor' ) , 1 , config.rounding_factor, m.rounding_factor) ,
                decode( get_attribute_control( 'unit_of_issue') , 1 , config.unit_of_issue, m.unit_of_issue) ,
                decode( get_attribute_control( 'enforce_ship_to_location_code' ) , 1 , config.enforce_ship_to_location_code , m.enforce_ship_to_location_code),
                decode( get_attribute_control( 'allow_substitute_receipts_flag' ) , 1 , config.allow_substitute_receipts_flag, m.allow_substitute_receipts_flag) ,
                decode( get_attribute_control( 'allow_unordered_receipts_flag' ) , 1 , config.allow_unordered_receipts_flag, m.allow_unordered_receipts_flag) ,
                decode( get_attribute_control( 'allow_express_delivery_flag' ) ,1 , config.allow_express_delivery_flag, m.allow_express_delivery_flag) ,
                decode( get_attribute_control( 'days_early_receipt_allowed') , 1, config.days_early_receipt_allowed, m.days_early_receipt_allowed) ,
                decode( get_attribute_control( 'days_late_receipt_allowed' ) , 1 , config.days_late_receipt_allowed , m.days_late_receipt_allowed) ,
                decode( get_attribute_control( 'receipt_days_exception_code')  , 1 , config.receipt_days_exception_code, m.receipt_days_exception_code) ,
                decode( get_attribute_control( 'receiving_routing_id' ) , 1 , config.receiving_routing_id, m.receiving_routing_id),
                decode( get_attribute_control( 'invoice_close_tolerance'), 1, config.invoice_close_tolerance, m.invoice_close_tolerance) ,
                decode( get_attribute_control( 'receive_close_tolerance') , 1 , config.receive_close_tolerance , m.receive_close_tolerance) ,
                decode( get_attribute_control( 'auto_lot_alpha_prefix') , 1, config.auto_lot_alpha_prefix, m.auto_lot_alpha_prefix) ,
                decode( get_attribute_control( 'start_auto_lot_number') , 1, config.start_auto_lot_number, m.start_auto_lot_number) ,
                decode( get_attribute_control( 'lot_control_code') ,1 , config.lot_control_code, m.lot_control_code) ,
                decode( get_attribute_control( 'shelf_life_code'), 1 , config.shelf_life_code, m.shelf_life_code) ,
                decode( get_attribute_control( 'shelf_life_days') , 1, config.shelf_life_days, m.shelf_life_days) ,
                decode( get_attribute_control( 'serial_number_control_code' ) ,1,  config.serial_number_control_code, m.serial_number_control_code) ,
                decode( get_attribute_control( 'start_auto_serial_number' ) , 1 , config.start_auto_serial_number, m.start_auto_serial_number) ,
                decode( get_attribute_control( 'auto_serial_alpha_prefix') ,1 , config.auto_serial_alpha_prefix, m.auto_serial_alpha_prefix) ,
                decode( get_attribute_control( 'source_type' ) ,1 , config.source_type, m.source_type) ,
                decode( get_attribute_control( 'source_organization_id') , 1 , config.source_organization_id, m.source_organization_id) ,
                decode( get_attribute_control( 'source_subinventory') ,1 , config.source_subinventory, m.source_subinventory) ,
                decode( get_attribute_control( 'expense_account') , 1, config.expense_account, m.expense_account) ,
                decode( get_attribute_control( 'encumbrance_account') , 1 , config.encumbrance_account, m.encumbrance_account) ,
                decode( get_attribute_control( 'restrict_subinventories_code' ) , 1 , config.restrict_subinventories_code, m.restrict_subinventories_code) ,
                config.unit_weight,
                config.weight_uom_code,
                config.volume_uom_code,
                config.unit_volume,
                decode( get_attribute_control( 'restrict_locators_code'), 1, config.restrict_locators_code, m.restrict_locators_code) ,
                decode( get_attribute_control( 'location_control_code') , 1 , config.location_control_code, m.location_control_code) ,
                decode( get_attribute_control( 'shrinkage_rate' ) , 1, config.shrinkage_rate, m.shrinkage_rate) ,
                decode( get_attribute_control( 'acceptable_early_days') , 1 , config.acceptable_early_days, m.acceptable_early_days) ,
                decode( get_attribute_control( 'planning_time_fence_code' ) , 1 , config.planning_time_fence_code, m.planning_time_fence_code) ,
                decode( get_attribute_control( 'demand_time_fence_code') , 1 , config.demand_time_fence_code,  m.demand_time_fence_code) ,
                decode( get_attribute_control( 'lead_time_lot_size') ,1, config.lead_time_lot_size, m.lead_time_lot_size) ,
                decode( get_attribute_control( 'std_lot_size' ) , 1, config.std_lot_size, m.std_lot_size) ,
                decode( get_attribute_control( 'cum_manufacturing_lead_time' ) , 1 , config.cum_manufacturing_lead_time, m.cum_manufacturing_lead_time) ,
                decode( get_attribute_control( 'overrun_percentage') , 1, config.overrun_percentage, m.overrun_percentage) ,
                decode( get_attribute_control( 'acceptable_rate_increase'), 1, config.acceptable_rate_increase, m.acceptable_rate_increase) ,
                decode( get_attribute_control( 'acceptable_rate_decrease') , 1 , config.acceptable_rate_decrease, m.acceptable_rate_decrease) ,
                decode( get_attribute_control( 'cumulative_total_lead_time' ) , 1 , config.cumulative_total_lead_time, m.cumulative_total_lead_time) ,
                decode( get_attribute_control( 'planning_time_fence_days' ) , 1, config.planning_time_fence_days, m.planning_time_fence_days) ,
                decode( get_attribute_control( 'demand_time_fence_days') , 1, config.demand_time_fence_days, m.demand_time_fence_days) ,
                decode( get_attribute_control( 'end_assembly_pegging_flag') ,1 , config.end_assembly_pegging_flag , m.end_assembly_pegging_flag) ,
                decode( get_attribute_control( 'planning_exception_set' ) , 1 , config.planning_exception_set, m.planning_exception_set) ,
                4,                                 -- BOM_ITEM_TYPE : standard
                'N',
                'Y',
                bcolu.inventory_item_id,           -- Base Model ID
                decode( get_attribute_control( 'atp_components_flag') , 1, config.atp_components_flag, CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(m.atp_flag, m.atp_components_flag)),
		decode( get_attribute_control( 'atp_flag') , 1, config.atp_flag, cto_config_item_pk.get_atp_flag) ,	-- ATP flag, set by evaluate_atp_attributes
                decode( get_attribute_control( 'fixed_lead_time') ,1 , config.fixed_lead_time, m.fixed_lead_time) ,
                decode( get_attribute_control( 'variable_lead_time') , 1 , config.variable_lead_time, m.variable_lead_time) ,
                decode( get_attribute_control( 'wip_supply_locator_id' ) , 1, config.wip_supply_locator_id, m.wip_supply_locator_id) ,
                decode( get_attribute_control( 'wip_supply_type' ) , 1 , config.wip_supply_type , m.wip_supply_type) ,
                decode( get_attribute_control( 'wip_supply_subinventory' ) , 1 , config.wip_supply_subinventory, m.wip_supply_subinventory) ,
                decode( get_attribute_control( 'primary_uom_code' ) , 1 , config.primary_uom_code, m.primary_uom_code) ,
                decode( get_attribute_control( 'primary_unit_of_measure' ) , 1 , config.primary_unit_of_measure, m.primary_unit_of_measure) ,
                decode( get_attribute_control( 'allowed_units_lookup_code' ) , 1 , config.allowed_units_lookup_code, m.allowed_units_lookup_code) ,
                decode( get_attribute_control( 'cost_of_sales_account' ) , 1 , config.cost_of_sales_account, m.cost_of_sales_account) ,
                decode( get_attribute_control( 'sales_account' ) , 1, config.sales_account, m.sales_account) ,
                'Y',                        -- DEFAULT_INCLUDE_IN_ROLLUP_FLAG
                decode( get_attribute_control( 'inventory_item_status_code' ) , 1 , config.inventory_item_status_code, m.inventory_item_status_code) ,
                decode( get_attribute_control( 'inventory_planning_code') , 1, config.inventory_planning_code, m.inventory_planning_code) ,
                decode( get_attribute_control( 'planner_code') , 1 , config.planner_code, m.planner_code) ,
                decode( get_attribute_control( 'planning_make_buy_code' ) , 1 , config.planning_make_buy_code, m.planning_make_buy_code) ,
                decode( get_attribute_control( 'fixed_lot_multiplier' ) , 1 , config.fixed_lot_multiplier, m.fixed_lot_multiplier) ,
                decode( get_attribute_control( 'rounding_control_type' ) , 1, config.rounding_control_type, m.rounding_control_type) ,
                decode( get_attribute_control( 'carrying_cost' ) ,1 , config.carrying_cost, m.carrying_cost) ,
                decode( get_attribute_control( 'postprocessing_lead_time') , 1, config.postprocessing_lead_time, m.postprocessing_lead_time) ,
                decode( get_attribute_control( 'preprocessing_lead_time' ) , 1 , config.preprocessing_lead_time, m.preprocessing_lead_time) ,
                decode( get_attribute_control( 'full_lead_time') , 1,  config.full_lead_time, m.full_lead_time) ,
                decode( get_attribute_control( 'order_cost') , 1, config.order_cost, m.order_cost) ,
                decode( get_attribute_control( 'mrp_safety_stock_percent') , 1, config.mrp_safety_stock_percent, m.mrp_safety_stock_percent) ,
                decode( get_attribute_control( 'mrp_safety_stock_code' ) , 1,  config.mrp_safety_stock_code, m.mrp_safety_stock_code) ,
                decode( get_attribute_control( 'min_minmax_quantity' ) , 1, config.min_minmax_quantity, m.min_minmax_quantity) ,
                decode( get_attribute_control( 'max_minmax_quantity' ) , 1 , config.max_minmax_quantity, m.max_minmax_quantity) ,
                decode( get_attribute_control( 'minimum_order_quantity' ) , 1 , config.minimum_order_quantity , m.minimum_order_quantity) ,
                decode( get_attribute_control( 'fixed_order_quantity' ) , 1 , config.fixed_order_quantity, m.fixed_order_quantity) ,
                decode( get_attribute_control( 'fixed_days_supply' ) , 1 , config.fixed_days_supply, m.fixed_days_supply) ,
                decode( get_attribute_control( 'maximum_order_quantity' ) , 1, config.maximum_order_quantity, m.maximum_order_quantity) ,
                decode( get_attribute_control( 'atp_rule_id' ) , 1, config.atp_rule_id, m.atp_rule_id) ,
                decode( get_attribute_control( 'picking_rule_id' ) , 1, config.picking_rule_id, m.picking_rule_id) ,
                1,                                      -- m.reservable_type
                decode( get_attribute_control( 'positive_measurement_error' ) , 1, config.positive_measurement_error, m.positive_measurement_error) ,
                decode( get_attribute_control( 'negative_measurement_error' ) , 1, config.negative_measurement_error, m.negative_measurement_error) ,
                decode( get_attribute_control( 'engineering_ecn_code' ) , 1 , config.engineering_ecn_code, m.engineering_ecn_code) ,
                decode( get_attribute_control( 'engineering_item_id' ) , 1 , config.engineering_item_id, m.engineering_item_id) ,
                decode( get_attribute_control( 'engineering_date' ) , 1, config.engineering_date, m.engineering_date) ,
                decode( get_attribute_control( 'service_starting_delay') , 1 , config.service_starting_delay, m.service_starting_delay) ,
                decode( get_attribute_control( 'vendor_warranty_flag') , 1 , config.vendor_warranty_flag, m.vendor_warranty_flag) ,
                decode( get_attribute_control( 'serviceable_component_flag' ) , 1, config.serviceable_component_flag , m.serviceable_component_flag) ,
                decode( get_attribute_control( 'serviceable_product_flag' ) , 1, config.serviceable_product_flag , m.serviceable_product_flag) ,
                decode( get_attribute_control( 'base_warranty_service_id' ) ,1 , config.base_warranty_service_id, m.base_warranty_service_id) ,
                decode( get_attribute_control( 'payment_terms_id' ) , 1 , config.payment_terms_id, m.payment_terms_id) ,
                decode( get_attribute_control( 'preventive_maintenance_flag') , 1,  config.preventive_maintenance_flag, m.preventive_maintenance_flag) ,
                decode( get_attribute_control( 'primary_specialist_id') , 1 , config.primary_specialist_id, m.primary_specialist_id),
                decode( get_attribute_control( 'secondary_specialist_id') , 1 , config.secondary_specialist_id, m.secondary_specialist_id) ,
                decode( get_attribute_control( 'serviceable_item_class_id') , 1, config.serviceable_item_class_id, m.serviceable_item_class_id) ,
                decode( get_attribute_control( 'time_billable_flag' ) , 1 , config.time_billable_flag, m.time_billable_flag) ,
                decode( get_attribute_control( 'material_billable_flag' ) , 1, config.material_billable_flag, m.material_billable_flag) ,
                decode( get_attribute_control( 'expense_billable_flag' ) , 1 , config.expense_billable_flag , m.expense_billable_flag) ,
                decode( get_attribute_control( 'prorate_service_flag' ) , 1, config.prorate_service_flag, m.prorate_service_flag) ,
                decode( get_attribute_control( 'coverage_schedule_id' ) , 1,  config.coverage_schedule_id, m.coverage_schedule_id) ,
                decode( get_attribute_control( 'service_duration_period_code' ) , 1, config.service_duration_period_code, m.service_duration_period_code) ,
                decode( get_attribute_control( 'service_duration') , 1,  config.service_duration, m.service_duration) ,
                decode( get_attribute_control( 'max_warranty_amount' ) , 1 , config.max_warranty_amount, m.max_warranty_amount) ,
                decode( get_attribute_control( 'response_time_period_code' ) , 1, config.response_time_period_code, m.response_time_period_code) ,
                decode( get_attribute_control( 'response_time_value') , 1, config.response_time_value, m.response_time_value) ,
                decode( get_attribute_control( 'new_revision_code' ) , 1 , config.new_revision_code, m.new_revision_code) ,
                decode( get_attribute_control( 'tax_code') , 1, config.tax_code, m.tax_code) ,
                decode( get_attribute_control( 'must_use_approved_vendor_flag' ) , 1, config.must_use_approved_vendor_flag, m.must_use_approved_vendor_flag) ,
                decode( get_attribute_control( 'safety_stock_bucket_days' ) , 1, config.safety_stock_bucket_days, m.safety_stock_bucket_days) ,
                decode( get_attribute_control( 'auto_reduce_mps') , 1, config.auto_reduce_mps, m.auto_reduce_mps) ,
                decode( get_attribute_control( 'costing_enabled_flag' ) , 1, config.costing_enabled_flag, m.costing_enabled_flag) ,
                decode( get_attribute_control( 'invoiceable_item_flag' ) , 1, config.invoiceable_item_flag, m.invoiceable_item_flag) , -- 'N' changed for international dropship
                decode( get_attribute_control( 'invoice_enabled_flag' ) , 1, config.invoice_enabled_flag, m.invoice_enabled_flag) , -- 'N' changed for international dropship
                decode( get_attribute_control( 'outside_operation_flag') , 1, config.outside_operation_flag, m.outside_operation_flag) ,
                decode( get_attribute_control( 'outside_operation_uom_type' ) , 1, config.outside_operation_uom_type, m.outside_operation_uom_type) ,
                'Y',
                decode( get_attribute_control( 'cycle_count_enabled_flag') , 1 , config.cycle_count_enabled_flag, m.cycle_count_enabled_flag) ,
                lItemType,
                decode( get_attribute_control( 'model_config_clause_name') ,1 , config.model_config_clause_name, m.model_config_clause_name) ,
                decode( get_attribute_control( 'ship_model_complete_flag') ,1 , config.ship_model_complete_flag, m.ship_model_complete_flag) ,
                decode( get_attribute_control( 'mrp_planning_code' ) , 1 , config.mrp_planning_code, m.mrp_planning_code) ,                 -- earlier it was always from one org only
                decode( get_attribute_control( 'repetitive_planning_flag' ) , 1, config.repetitive_planning_flag, m.repetitive_planning_flag) ,   -- earlier it was always from one org only
                decode( get_attribute_control( 'return_inspection_requirement' ) , 1 , config.return_inspection_requirement, m.return_inspection_requirement) ,
                nvl( decode( get_attribute_control( 'effectivity_control') , 1, config.effectivity_control, m.effectivity_control) , 1),
                null,                               -- req_id
                null,                               -- prg_appid
                99,                               -- prg_id (to identify that item was created in this org by this program
                sysdate,
		decode( get_attribute_control( 'comms_nl_trackable_flag') , 1, config.comms_nl_trackable_flag, m.comms_nl_trackable_flag) ,
		nvl( decode( get_attribute_control( 'default_so_source_type') , 1 , config.default_so_source_type, m.default_so_source_type) ,'INTERNAL'),
		nvl( decode( get_attribute_control( 'create_supply_flag') , 1, config.create_supply_flag, m.create_supply_flag) , 'Y'),
		decode( get_attribute_control( 'lot_status_enabled') , 1, config.lot_status_enabled, m.lot_status_enabled) ,
		decode( get_attribute_control( 'default_lot_status_id' ) , 1, config.default_lot_status_id, m.default_lot_status_id) ,
		decode( get_attribute_control( 'serial_status_enabled') , 1, config.serial_status_enabled, m.serial_status_enabled) ,
		decode( get_attribute_control( 'default_serial_status_id') ,1 , config.default_serial_status_id, m.default_serial_status_id) ,
		decode( get_attribute_control( 'lot_split_enabled') , 1, config.lot_split_enabled, m.lot_split_enabled) ,
		decode( get_attribute_control( 'lot_merge_enabled') ,1 , config.lot_merge_enabled, m.lot_merge_enabled) ,
		decode( get_attribute_control( 'bulk_picked_flag' ) , 1 , config.bulk_picked_flag, m.bulk_picked_flag) ,
		decode( get_attribute_control( 'financing_allowed_flag') , 1, config.financing_allowed_flag, m.FINANCING_ALLOWED_FLAG) ,
 		decode( get_attribute_control( 'eam_item_type') , 1 , config.eam_item_type, m.EAM_ITEM_TYPE ) ,
 		decode( get_attribute_control( 'eam_activity_type_code') , 1 , config.eam_activity_type_code, m.EAM_ACTIVITY_TYPE_CODE) ,
 		decode( get_attribute_control( 'eam_activity_cause_code') , 1, config.eam_activity_cause_code, m.EAM_ACTIVITY_CAUSE_CODE) ,
 		decode( get_attribute_control( 'eam_act_notification_flag') , 1, config.eam_act_notification_flag, m.EAM_ACT_NOTIFICATION_FLAG) ,
 		decode( get_attribute_control( 'eam_act_shutdown_status') , 1, config.eam_act_shutdown_status, m.EAM_ACT_SHUTDOWN_STATUS) ,
 		decode( get_attribute_control( 'substitution_window_code') , 1, config.substitution_window_code, m.SUBSTITUTION_WINDOW_CODE) ,
 		decode( get_attribute_control( 'substitution_window_days') , 1, config.substitution_window_days, m.SUBSTITUTION_WINDOW_DAYS) ,
 		null, --5385901 decode( get_attribute_control( 'product_family_item_id') , 1, config.product_family_item_id, m.PRODUCT_FAMILY_ITEM_ID) ,
 		decode( get_attribute_control( 'check_shortages_flag') , 1, config.check_shortages_flag, m.CHECK_SHORTAGES_FLAG) ,
 		decode( get_attribute_control( 'planned_inv_point_flag') , 1, config.planned_inv_point_flag, m.PLANNED_INV_POINT_FLAG) ,
 		decode( get_attribute_control( 'over_shipment_tolerance') , 1, config.over_shipment_tolerance, m.OVER_SHIPMENT_TOLERANCE) ,
 		decode( get_attribute_control( 'under_shipment_tolerance') , 1, config.under_shipment_tolerance, m.UNDER_SHIPMENT_TOLERANCE) ,
 		decode( get_attribute_control( 'over_return_tolerance') , 1, config.over_return_tolerance, m.OVER_RETURN_TOLERANCE) ,
 		decode( get_attribute_control( 'under_return_tolerance') , 1, config.under_return_tolerance, m.UNDER_RETURN_TOLERANCE) ,
 		decode( get_attribute_control( 'purchasing_tax_code') , 1, config.purchasing_tax_code, m.PURCHASING_TAX_CODE) ,
 		decode( get_attribute_control( 'overcompletion_tolerance_type') , 1, config.overcompletion_tolerance_type, m.OVERCOMPLETION_TOLERANCE_TYPE) ,
 		decode( get_attribute_control( 'overcompletion_tolerance_value') , 1, config.overcompletion_tolerance_value, m.OVERCOMPLETION_TOLERANCE_VALUE) ,
 		decode( get_attribute_control( 'inventory_carry_penalty'), 1, config.inventory_carry_penalty, m.INVENTORY_CARRY_PENALTY) ,
 		decode( get_attribute_control( 'operation_slack_penalty') ,1, config.operation_slack_penalty, m.OPERATION_SLACK_PENALTY) ,
 		decode( get_attribute_control( 'unit_length') , 1, config.unit_length, m.UNIT_LENGTH) ,
 		decode( get_attribute_control( 'unit_width' ) , 1, config.unit_width, m.UNIT_WIDTH) ,
 		decode( get_attribute_control( 'unit_height') , 1, config.unit_height, m.UNIT_HEIGHT) ,
 		decode( get_attribute_control( 'lot_translate_enabled') , 1, config.lot_translate_enabled, m.LOT_TRANSLATE_ENABLED) ,
 		decode( get_attribute_control( 'container_item_flag') , 1, config.container_item_flag, m.CONTAINER_ITEM_FLAG) ,
 		decode( get_attribute_control( 'vehicle_item_flag') , 1, config.vehicle_item_flag, m.VEHICLE_ITEM_FLAG) ,
 		decode( get_attribute_control( 'dimension_uom_code') , 1, config.dimension_uom_code, m.DIMENSION_UOM_CODE) ,
 		decode( get_attribute_control( 'secondary_uom_code') , 1, config.secondary_uom_code, m.SECONDARY_UOM_CODE) ,
 		decode( get_attribute_control( 'maximum_load_weight') , 1, config.maximum_load_weight, m.MAXIMUM_LOAD_WEIGHT) ,
 		decode( get_attribute_control( 'minimum_fill_percent') , 1, config.minimum_fill_percent, m.MINIMUM_FILL_PERCENT) ,
 		decode( get_attribute_control( 'container_type_code') , 1, config.container_type_code, m.CONTAINER_TYPE_CODE) ,
 		decode( get_attribute_control( 'internal_volume') , 1, config.internal_volume, m.INTERNAL_VOLUME) ,
 		decode( get_attribute_control( 'equipment_type') , 1,  config.equipment_type , m.EQUIPMENT_TYPE) ,
 		decode( get_attribute_control( 'indivisible_flag') , 1, config.indivisible_flag, m.INDIVISIBLE_FLAG) ,
 		decode( get_attribute_control( 'global_attribute_category'), 1, config.global_attribute_category, m.GLOBAL_ATTRIBUTE_CATEGORY) ,
 		m.GLOBAL_ATTRIBUTE1,
 		m.GLOBAL_ATTRIBUTE2,
 		m.GLOBAL_ATTRIBUTE3,
 		m.GLOBAL_ATTRIBUTE4,
 		m.GLOBAL_ATTRIBUTE5,
 		m.GLOBAL_ATTRIBUTE6,
 		m.GLOBAL_ATTRIBUTE7,
 		m.GLOBAL_ATTRIBUTE8,
 		m.GLOBAL_ATTRIBUTE9,
 		m.GLOBAL_ATTRIBUTE10,
     		decode( get_attribute_control( 'dual_uom_control') , 1, config.dual_uom_control, m.DUAL_UOM_CONTROL) ,
 		decode( get_attribute_control( 'dual_uom_deviation_high') , 1, config.dual_uom_deviation_high, m.DUAL_UOM_DEVIATION_HIGH) ,
 		decode( get_attribute_control( 'dual_uom_deviation_low') , 1, config.dual_uom_deviation_low, m.DUAL_UOM_DEVIATION_LOW) ,
                decode( get_attribute_control( 'contract_item_type_code') , 1, config.contract_item_type_code, m.CONTRACT_ITEM_TYPE_CODE) ,
 		decode( get_attribute_control( 'subscription_depend_flag') , 1 , config.subscription_depend_flag, m.SUBSCRIPTION_DEPEND_FLAG) ,
 		decode( get_attribute_control( 'serv_req_enabled_code' ) , 1, config.serv_req_enabled_code, m.SERV_REQ_ENABLED_CODE) ,
 		decode( get_attribute_control( 'serv_billing_enabled_flag') , 1, config.serv_billing_enabled_flag, m.SERV_BILLING_ENABLED_FLAG) ,
 		decode( get_attribute_control( 'release_time_fence_code') , 1, config.release_time_fence_code, m.RELEASE_TIME_FENCE_CODE) ,
 		decode( get_attribute_control( 'release_time_fence_days' ) ,1, config.release_time_fence_days, m.RELEASE_TIME_FENCE_DAYS) ,
 		decode( get_attribute_control( 'defect_tracking_on_flag') , 1, config.defect_tracking_on_flag, m.DEFECT_TRACKING_ON_FLAG) ,
 		decode( get_attribute_control( 'serv_importance_level'), 1, config.serv_importance_level, m.SERV_IMPORTANCE_LEVEL) ,
	        decode( get_attribute_control( 'web_status') , 1, config.web_status, m.web_status),
		decode( get_attribute_control( 'tracking_quantity_ind') , 1, config.tracking_quantity_ind, m.tracking_quantity_ind),
		decode( get_attribute_control( 'ont_pricing_qty_source') , 1, config.ont_pricing_qty_source, m.ont_pricing_qty_source),
		decode( get_attribute_control( 'approval_status') , 1, config.approval_status, m.approval_status),
		--decode( get_attribute_control( 'default_control') , 1, config.tracking_quantity_ind, m.tracking_quantity_ind),
		decode( get_attribute_control( 'vmi_minimum_units') , 1, config.vmi_minimum_units, m.vmi_minimum_units),
		decode( get_attribute_control( 'vmi_minimum_days') , 1, config.vmi_minimum_days, m.vmi_minimum_days),
		decode( get_attribute_control( 'vmi_maximum_units') , 1, config.vmi_maximum_units, m.vmi_maximum_units),
		decode( get_attribute_control( 'vmi_maximum_days') , 1, config.vmi_maximum_days, m.vmi_maximum_days),
		decode( get_attribute_control( 'vmi_fixed_order_quantity') , 1, config.vmi_fixed_order_quantity, m.vmi_fixed_order_quantity),
		decode( get_attribute_control( 'so_authorization_flag') , 1, config.so_authorization_flag, m.so_authorization_flag),
		decode( get_attribute_control( 'consigned_flag') , 1, config.consigned_flag, m.consigned_flag),
		decode( get_attribute_control( 'asn_autoexpire_flag') , 1, config.asn_autoexpire_flag, m.asn_autoexpire_flag),
		decode( get_attribute_control( 'vmi_forecast_type') , 1, config.vmi_forecast_type, m.vmi_forecast_type),
		decode( get_attribute_control( 'forecast_horizon') , 1, config.forecast_horizon, m.forecast_horizon),
		decode( get_attribute_control( 'days_tgt_inv_supply') , 1, config.days_tgt_inv_supply, m.days_tgt_inv_supply),
		decode( get_attribute_control( 'days_tgt_inv_window') , 1, config.days_tgt_inv_window, m.days_tgt_inv_window),
		decode( get_attribute_control( 'days_max_inv_supply') , 1, config.days_max_inv_supply, m.days_max_inv_supply),
		decode( get_attribute_control( 'days_max_inv_window') , 1, config.days_max_inv_window, m.days_max_inv_window),
		decode( get_attribute_control( 'critical_component_flag') , 1, config.critical_component_flag, m.critical_component_flag),
		decode( get_attribute_control( 'drp_planned_flag') , 1, config.drp_planned_flag, m.drp_planned_flag),
		decode( get_attribute_control( 'exclude_from_budget_flag') , 1, config.exclude_from_budget_flag, m.exclude_from_budget_flag),
		decode( get_attribute_control( 'convergence') , 1, config.convergence, m.convergence),
		decode( get_attribute_control( 'continous_transfer') , 1, config.continous_transfer, m.continous_transfer),
		decode( get_attribute_control( 'divergence') , 1, config.divergence, m.divergence),
	         --r12,4574899
		'N',
		'N',
		/* Bugfix 8821149: Will populate these values from model.
		'N',
	        'N',
		'N',
		*/
		decode( get_attribute_control( 'child_lot_flag' ) , 1 , config.child_lot_flag, m.child_lot_flag),
		decode( get_attribute_control( 'child_lot_validation_flag' ) , 1 , config.child_lot_validation_flag, m.child_lot_validation_flag),
		decode( get_attribute_control( 'copy_lot_attribute_flag' ) , 1 , config.copy_lot_attribute_flag, m.copy_lot_attribute_flag),
		decode( get_attribute_control( 'parent_child_generation_flag' ) , 1 , config.parent_child_generation_flag, m.parent_child_generation_flag),
		decode( get_attribute_control( 'lot_substitution_enabled' ) , 1 , config.lot_substitution_enabled, m.lot_substitution_enabled),
		-- End Bugfix 8821149
		'N',
		'N',
		'N',
		'N',
		'N',
		'N',
		3,
		2

       from
                mtl_system_items_b m,		-- model
		mtl_system_items_b config,	-- config
                bom_cto_src_orgs bcso,
		bom_cto_order_lines_upg bcolu
        where bcolu.config_item_id is not null
	and bcolu.status = 'BCSO'
	and m.inventory_item_id = bcolu.inventory_item_id
	-- get config item row for any one org
	and config.inventory_item_id = bcolu.config_item_id
	and config.organization_id = bcolu.ship_from_org_id
	-- config is pc in atleast one orgs
	and exists
		(select 'pc'
		from mtl_system_items msi1
		where msi1.inventory_item_id = bcolu.config_item_id
		and nvl(msi1.auto_created_config_flag,'N') = 'N')
        and bcso.model_item_id = bcolu.inventory_item_id
        and bcso.line_id = bcolu.line_id
        and m.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_system_items_b
                where inventory_item_id = bcolu.config_item_id
                and organization_id = bcso.organization_id);

	WriteToLog('PC Items created::'||sql%rowcount, 2);

EXCEPTION
     	WHEN OTHERS THEN
		WriteToLog ('ERROR: Others error in Update_Pc_Items::'||to_char(lStmtNumber)||sqlerrm,1);
        	CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
		xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Pc_Items;


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0) IS
BEGIN
    IF gDebugLevel >= p_level THEN
	fnd_file.put_line (fnd_file.log, p_message);
    END IF;
END WriteToLog;


END CTO_UPDATE_ITEMS_PK;


/
