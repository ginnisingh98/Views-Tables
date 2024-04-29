--------------------------------------------------------
--  DDL for Package Body CTO_UPDATE_CONFIGS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_UPDATE_CONFIGS_PK" as
/* $Header: CTOUCFGB.pls 120.6.12010000.15 2012/04/19 10:17:17 ntungare ship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUCFGB.pls
|
|DESCRIPTION : Contains modules to :
|
|HISTORY     : Created on 9-SEP-2003  by Sajani Sheth
|
|
|              01/13/2004  Kiran Konada
|                          bugfix 3368052
|
|              01/13/2004  Kiran Konada
|                          bugfix  3371155
|                          This is done not to look at configs present in bcol
|                          for de-linked orders as they dont belong to open
|                          order Lines
|
|              01/20/2004  Kiran Konada
|
|                          bugfix 3377963
|                          MOdel with cib attributes 1 or 2 present as child
|                          under a model with CIB attribute 3 is a invalid setup
|              01/23/04    Renga Kannan
|                          Added the implementation to update the atp attributes for the
|                          existing configs
|
|              01/27/04    Kiran Konada
|                          bugfix 3397123
|                          Changed the signature of Update_Configs
|                          To take in new parameters
|                          p_category_set_id
|                          p_dummy3
|                           The above two parameters are NOt used in the code,
|                          they had to be in teh signature as they are in Conc
|                          program definition
|
|               Modified   :    02-MAR-2004     Sushant Sawant
|                                               Fixed Bug 3472654
|                                               upgrades for matched config from CIB = 1 or 2 to 3 were not performed properly.
|                                               data was not transformed to bcmo.
|                                               perform_match is now inherited from bcol while populating bcol_upg
|
|               Modified   :    16-MAR-2004     Sushant Sawant
|                                               Fixed Bug 3567693
|                                               upgrades for matched config from CIB = 1 or 2 to 3 with no orders pointing
|                                               to the config item were not performed properly.

|
|               Modified   :    29-APR-2004     Sushant Sawant
|                                               Fixed Bug 3599397. Added check for config linked to oe in populate_cat_models code.
|
|
|               Modified   :    03-MAY-2004     Sushant Sawant
|                                               Fixed Bug 3602292. Defaulted option_specific to N in bcol_upg
|
|               Modified   :    18-AUG-2004     Kiran Konada
|                                               bugfix #3841575
|
|               Modified   :    20-AUG-2004     Kiran Konada
|                                               bugfix # 	3845686
|                                               1.moved the EXIT to be immediately after fetch
|                                               2.got the config_orgs attribute for BASE_MODEL_ID
|                                               3.added nvl and to_char to select column
|                                               nvl(to_char(msi.option_specific_sourced),'N')
|
+-----------------------------------------------------------------------------*/

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_UPDATE_CONFIGS_PK';
 PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

--forward declaration
PROCEDURE Check_invalid_configurations(
x_return_status	out NOCOPY varchar2);

/***********************************************************************
This procedure is called by the Update Existing Configurations batch
progam. It does the following:
	1. Call procedures to populate bcol_upg based on the input params
	2. Delete sourcing for canned configs not to be processed
	3. Update bcol_upg with sequence numbers for batch processing
	4. Call procedure to update items and sourcing
***********************************************************************/
PROCEDURE Update_Configs
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY varchar2,
p_item IN number,
p_dummy IN varchar2,
p_dummy2 IN varchar2,
p_category_set_id IN number, --bugfix3397123
p_dummy3 IN number, --bugfix3397123
p_cat_id IN number,
p_config_id IN number,
p_changed_src IN varchar2,
p_open_lines IN varchar2,
p_upgrade_mode In Number
) IS



/*
Redundant cursor

CURSOR c_seq(l_seq number) IS
select distinct sequence
from bom_cto_order_lines_upg
where sequence = l_seq;
*/

l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);

--Bugfix 10240482
--l_seq NUMBER := 0;
l_seq_temp NUMBER := 0;

l_status NUMBER;
l_stmt_num number := 0;
l_req_data varchar2(10);
l_request_id number;
l_exists varchar2(10);
l_bcolu_count number;
l_mrp_aset_id number;
l_cto_aset_id number;

Cursor Attachment_cur is
 select distinct ato_line_id
 from    bom_cto_order_lines_upg
 where  status = 'CTO_SRC'
 and    line_id = ato_line_id;


x_return_status  Varchar2(1);
x_msg_count      Number;
x_msg_data       Varchar2(1000);

--Bugfix 6710393
TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_cfg_itm_tbl num_tbl_type;
l_seq_tbl     num_tbl_type;
--Bugfix 6710393

bom_schema VARCHAR2(10) := 'BOM';

--Bugfix 10240482: New parameter
l_max_seq number;

--Bugfix 9953527
l_return_code number;

BEGIN

retcode := 0;

--
-- processing if 'all models' is selected for upgrade
--
WriteToLog('Begin Update Existing Configurations with Debug Level: '||gDebugLevel);
WriteToLog('Parameters passed:');
WriteToLog('   Items: '||p_item);
WriteToLog('   Item Category: '||p_cat_id);
WriteToLog('   Configuration Item: '||p_config_id);
WriteToLog('   Sourced configurations: '||p_changed_src);
WriteToLog('   Process existing order lines: '||p_open_lines);
WriteToLog('   Upgrade Mode                : '||to_char(p_upgrade_mode));

l_req_data := fnd_conc_global.request_data;
WriteToLog('l_req_data: '||l_req_data);

IF (l_req_data = 'CTO') THEN
	GOTO RESTART;
END IF;


If p_upgrade_mode = 3 then
   update_atp_attributes(
                          p_item           => p_item,
                          p_cat_id         => p_cat_id,
                          p_config_id      => p_config_id,
                          x_return_status  => x_return_status,
                          x_msg_data       => x_msg_data,
                          x_msg_count      => x_msg_count);
   WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
   WriteToLog('Update Existing Configurations completed with SUCCESS');
   WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
   errbuf := 'Program completed successfully.';
   return;

End if;
--
-- delete from bcol_upg and bcso_b
--
l_stmt_num := 10;
delete from bom_cto_src_orgs_b
where line_id in (
	select bcolu.line_id
	from bom_cto_order_lines_upg bcolu
	where bcolu.config_item_id is not null
	and not exists (
		select 'exists'
		from oe_order_lines_all oel
		where oel.line_id = bcolu.line_id));
WriteToLog('Rows deleted from bcso_b::'|| sql%rowcount, 1);

l_stmt_num := 15;
--
-- bug 8789722
-- since its a blind delete hence using truncate
-- delete from bom_cto_order_lines_upg;
--
execute immediate 'truncate table '||bom_schema||'.bom_cto_order_lines_upg';
WriteToLog('Rows deleted from bcol_upg::'|| sql%rowcount, 1);

BEGIN
select assignment_set_id
into l_cto_aset_id
from mrp_assignment_sets
where assignment_set_name = 'CTO Configuration Updates';

WriteToLog('CTO Seeded Assignment Set Id::'||l_cto_aset_id, 2);

EXCEPTION
WHEN no_data_found THEN
	WriteToLog('ERROR: CTO seeded assignment set not found', 1);

	--start bugfix 3368052
        --it has been decided not to seed assignment
	--instead create programatically when it is not found
	--during the first run of the program
        --reason : this is not a fnd object to create through ldt
	--and creating using a sql script requires giving lot of answers to
	--release team

        WriteToLog('Hence creating a assigment set', 1);

	 l_stmt_num := 16;
         INSERT INTO mrp_assignment_sets
	 (assignment_set_id ,
	  assignment_set_name,
	  description,
	  created_by,
	  last_updated_by,
	  creation_date,
	  last_update_date
	 )
	 VALUES
	 ( MRP_ASSIGNMENT_SETS_S.nextval,
	   'CTO Configuration Updates',
	   'Exclusively for use by CTO. Used during Upgrade Concurrent programs',
	   FND_GLOBAL.USER_ID,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   sysdate
	  )
	  returning assignment_set_id INTO l_cto_aset_id;

	  WriteToLog('Created Assignment set with assignment set id::'||l_cto_aset_id, 2);
          WriteToLog('Assignment set name::'|| 'CTO Configuration Updates', 2);

	  --end bugfix 3368052

END;

--
-- Delete all assignments from CTO Default Assignment Set
--
delete from mrp_sr_assignments
where assignment_set_id = l_cto_aset_id;

WriteToLog('Rows deleted from cto assignment set::'|| sql%rowcount, 1);

l_stmt_num := 18;
IF (p_item = 1) THEN
	l_stmt_num := 20;
	l_mrp_aset_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
	WriteToLog('MRP Assignment Set Id::'||l_mrp_aset_id, 2);

	l_stmt_num := 22;
	populate_all_models(
		p_changed_src,
		p_open_lines,
		l_return_status,
		l_msg_count,
		l_msg_data);

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		WriteToLog('ERROR: Populate_all_models returned unexpected error');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		WriteToLog('ERROR: Populate_all_models returned expected error');
		raise FND_API.G_EXC_ERROR;
	ELSE
		WriteToLog('Populate_all_models returned success', 3);
	END IF;

	--
	-- Delete sourcing for canned configurations not being upgraded
	-- (config_creation = 1 or 2) and not linked on open order lines
	-- Sourcing should not be deleted for pre-configured items in
	-- the match tables.
	--

	-- Modified by Renga Kannan on 06/06/06
	-- Fixed for bug 5263027
	-- Added a conidtion to check for open order with config items linked to the sales order

	l_stmt_num := 25;
	delete from mrp_sr_assignments
	where assignment_set_id = l_mrp_aset_id
	and inventory_item_id in
		(select config_item_id
		from bom_ato_configurations bac
		where not exists
			(select 'exists'
			from bom_cto_order_lines_upg bcolu
			where bcolu.config_item_id = bac.config_item_id
                          and rownum = 1) -- bug 13876670
		-- and not on open order lines
		and not exists
			(select 'exists'
			from oe_order_lines_all oel,
			bom_cto_order_lines bcol
			where bcol.config_item_id = bac.config_item_id
			and bcol.ato_line_id = oel.ato_line_id
			and nvl(oel.open_flag, 'N') = 'Y'
			and oel.item_type_code='CONFIG'
                        and rownum = 1) -- bug 13876670
		-- and item is not pre-configured
		and not exists
			(select 'pc'
			from mtl_system_items msi
			where msi.inventory_item_id = bac.config_item_id
                        -- bug 13876670
                        and msi.auto_created_config_flag = 'N'
                        and msi.organization_id = bac.organization_id
                        and rownum =1
			));

	WriteToLog('Sourcing deleted::'||sql%rowcount, 2);

ELSIF (p_item = 2) THEN
	l_stmt_num := 30;
	l_mrp_aset_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
	WriteToLog('MRP Assignment Set Id::'||l_mrp_aset_id, 2);

	l_stmt_num := 34;
	populate_cat_models(
		p_cat_id,
		p_changed_src,
		p_open_lines,
                -- bug 13876670
                p_category_set_id,
		l_return_status,
		l_msg_count,
		l_msg_data);

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		WriteToLog('ERROR: Populate_cat_models returned unexpected error');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		WriteToLog('ERROR: Populate_cat_models returned expected error');
		raise FND_API.G_EXC_ERROR;
	ELSE
		WriteToLog('Populate_cat_models returned success', 3);
	END IF;

	--
	-- Delete sourcing for canned configurations not being upgraded
	-- (config_creation = 1 or 2) and not on open order lines
	-- Sourcing should not be deleted for pre-configured items in the
	-- match tables.
	--
	l_stmt_num := 36;

-- Modified by Renga Kannan on 06/06/06
	-- Fixed for bug 5263027
	-- Added a conidtion to check for open order with config items linked to the sales order
        /* SQL Rewritten as part of performance fix 3641207 */
        delete from mrp_sr_assignments
        where assignment_set_id = l_mrp_aset_id
          and inventory_item_id in
              (
               select /*+ leading(mcat bac) */ DISTINCT config_item_id -- bug 13876670 added hint
                 from bom_ato_configurations bac,
                      mtl_item_categories mcat
                where bac.base_model_id = mcat.inventory_item_id
                  and mcat.category_id = p_cat_id
                  -- bug 13876670
                  and mcat.category_set_id = p_category_set_id
                  and not exists
                      (select 'exists'
                         from bom_cto_order_lines_upg bcolu
                        where bcolu.config_item_id = bac.config_item_id
                          and rownum = 1 -- 13876670
                      )
                  and NOT EXISTS -- bug 13876670
                      (select 'exists'
                         from oe_order_lines_all oel,
                              bom_cto_order_lines bcol
                        where bcol.config_item_id = bac.config_item_id
                        and   bcol.ato_line_id = oel.ato_line_id
                        and   bcol.config_item_id = oel.inventory_item_id
                        and   oel.item_type_code = 'CONFIG'
                        and   open_flag = 'Y'
                        and rownum = 1 -- 13876670
                      )
                  and not exists
                      (select /*+ no_unnest push_subq */ 'pc'
                         from mtl_system_items msi
                        where msi.inventory_item_id = bac.config_item_id
                          and msi.auto_created_config_flag = 'N'
                          -- 13876670
                          and msi.organization_id = bac.organization_id
                          and rownum = 1
                      )
               );


	WriteToLog('Sourcing deleted::'||sql%rowcount, 2);

ELSE
	l_stmt_num := 40;
	l_mrp_aset_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
	WriteToLog('MRP Assignment Set Id::'||l_mrp_aset_id, 2);

	l_stmt_num := 45;

	populate_config(
		p_changed_src,
		p_open_lines,
		p_config_id,
		l_return_status,
		l_msg_count,
		l_msg_data);

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		WriteToLog('ERROR: Populate_configs returned unexpected error');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
		WriteToLog('ERROR: Populate_configs returned expected error');
		raise FND_API.G_EXC_ERROR;
	ELSE
		WriteToLog('Populate_configs returned success', 3);
	END IF;

	l_stmt_num := 45;

	--
	-- Delete sourcing if this configuration is not being upgraded
	-- (config_creation = 1 or 2) and is not on open order lines.
	-- Sourcing should not be deleted if it is a pre-configured item.
	--

	delete from mrp_sr_assignments
	where assignment_set_id = l_mrp_aset_id
	and inventory_item_id = p_config_id
	-- not being upgraded
	and not exists
		(select 'exists'
		from bom_cto_order_lines_upg bcolu
		where bcolu.config_item_id = p_config_id
                  and rownum = 1 -- bug 13876670
                 )
	-- and not on open order lines
	and not exists           /* bug 3399310 sushant changed the query to identify config item exists */
		(select 'exists'
		from oe_order_lines_all oel,
		bom_cto_order_lines bcol
		where bcol.config_item_id = p_config_id
		and bcol.line_id = oel.ato_line_id
                and oel.item_type_code = 'CONFIG'
		and nvl(oel.open_flag, 'N') = 'Y'
                and rownum = 1 -- bug 13876670
                )
	-- and item is not pre-configured
	and not exists
		(select 'pc'
		from mtl_system_items msi
		where msi.inventory_item_id = p_config_id
                -- bug 13876670
		and msi.auto_created_config_flag = 'N'
                and rownum = 1
                );

	WriteToLog('Sourcing deleted::'||sql%rowcount, 2);

END IF;

-- bug 6710393: It is sufficient to have each config item only once in
-- in bcol_upg. We will delete all except one occurence of each config
-- item to avoid deadlock and unique contraint violation in CTOUBOMB
-- workers.
-- bug 6710393: Getting the stats before performing the delete
-- So that the appropriate indexes get used

l_stmt_num := 46;

fnd_stats.gather_table_stats(
             ownname=>'BOM',
             tabname=>'BOM_CTO_ORDER_LINES_UPG',
             percent=>90);

--
-- bug 13362916
-- Modified for improving performance
--
/*
delete from bom_cto_order_lines_upg bcol1
where ato_line_id not in (select max(bcol2.ato_line_id)
                          from bom_cto_order_lines_upg bcol2
                          where bcol2.config_item_id is not null
                          group by bcol2.config_item_id
                          );
*/
DELETE
 FROM bom_cto_order_lines_upg bcol1
 WHERE rowid IN
   (SELECT rowid
    FROM
     (SELECT rowid,
             row_number() over(PARTITION BY bcol2.config_item_id ORDER BY bcol2.ato_line_id DESC) rnk
     FROM bom_cto_order_lines_upg bcol2
     WHERE bcol2.config_item_id IS NOT NULL
     )
    WHERE rnk <> 1
   );
WriteToLog('New Msg: Rows deleted from bcolu:: ' ||sql%rowcount, 2);

--
-- if no rows populated into bcol, return
--
select count(*)
into l_bcolu_count
from bom_cto_order_lines_upg;
WriteToLog('Rows populated in bcol_upg::'||l_bcolu_count, 1);

IF l_bcolu_count = 0 THEN
	WriteToLog('+++++++++++++++++++++++++++++++++++++++', 1);
	WriteToLog('No configuration items to be processed.', 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++', 1);
	return;
END IF;

--start bugfix 3377963

--an model with CIB attribute 1 or 2 cannot be as a child of
--model whose CIB attribute is 3
--perfoming above validation by calling following API
l_stmt_num := 50;
Check_invalid_configurations(l_return_status);

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	WriteToLog('Check_invalid_configurations returned unexpected error', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSE
	WriteToLog('Check_invalid_configurations returned success', 3);
END IF;

l_stmt_num := 51;

select count(*)
into l_bcolu_count
from bom_cto_order_lines_upg
where status <>'ERROR';

WriteToLog('Rows populated in bcol_upg and NOT in error status::'||l_bcolu_count, 1);

IF l_bcolu_count = 0 THEN

        WriteToLog('+++++++++++++++++++++++++++++++++++++++', 1);
	WriteToLog('No configuration items to be processed.', 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++', 1);

       -- Write status of all config items processed to log file
       --

       --Bugfix 13362916: Passing the new parameter
       Write_Config_Status(l_return_status,l_return_code);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  WriteToLog('Write_Config_Status returned unexpected error', 1);
       ELSE
	  WriteToLog('Write_Config_Status returned success', 3);
       END IF;


	return;
END IF;
--bugfix 3377963

--
-- update all cfgs to be upgraded with a sequence number
--
l_stmt_num := 60;
WHILE (TRUE) LOOP

	--Bugfix 10240482
	l_seq_temp := l_seq_temp + 1;

	update bom_cto_order_lines_upg bcolu
	set bcolu.sequence = l_seq_temp
	where bcolu.ato_line_id in
		(select ato_line_id
		from bom_cto_order_lines_upg bcolu2
		where bcolu2.ato_line_id = bcolu2.line_id
		and bcolu2.status IN ('UPG')
		and rownum < G_BATCH_SIZE + 1
		and bcolu2.sequence is null);

	IF sql%notfound THEN
		exit;
	END IF;

END LOOP;

--Bugfix 10240482
l_max_seq := l_seq_temp;

WriteToLog('Done updating sequence in bcol_upg', 4);

--Bugfix 6710393
WriteToLog('Going for a second update of sequence numbers', 4);

SELECT config_item_id, Max(SEQUENCE)
  BULK COLLECT INTO l_cfg_itm_tbl, l_seq_tbl
    FROM bom_cto_order_lines_upg
     WHERE config_item_id IS NOT NULL
     GROUP BY config_item_id
     HAVING Count(DISTINCT SEQUENCE) > 1;

WriteToLog('Count of rows to be updated:: '|| l_cfg_itm_tbl.count, 1);

FOR i IN 1..l_cfg_itm_tbl.count loop

   WriteToLog('i: '||i||' l_cfg_itm_tbl(i): '||l_cfg_itm_tbl(i)||' l_seq_tbl(i): '||l_seq_tbl(i), 4);

   UPDATE bom_cto_order_lines_upg bcol1
   SET bcol1.SEQUENCE = l_seq_tbl(i)
   WHERE ato_line_id IN ( SELECT distinct ato_line_id
                           FROM bom_cto_order_lines_upg bcol2
                            WHERE bcol2.config_item_id = l_cfg_itm_tbl(i)
                        );

   WriteToLog('Rows updated::'|| sql%rowcount, 1);
END LOOP;
--Bugfix 6710393

--
-- create items, populate bcso and create sourcing
--
l_stmt_num := 70;

Cto_Update_Items_Pk.Update_Items_And_Sourcing(
			  p_changed_src     => p_changed_src
			, p_cat_id          => p_cat_id
			, p_upgrade_mode    => p_upgrade_mode
			--Bugfix 10240482: Passing the new parameter p_max_seq
			, p_max_seq         => l_max_seq
			, xReturnStatus     => l_return_status
			, xMsgCount         => l_msg_count
			, xMsgData          => l_msg_data);

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	WriteToLog('ERROR: Update_items_and_sourcing returned unexpected error');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
	WriteToLog('ERROR: Update_items_and_sourcing returned expected error');
	--raise FND_API.G_EXC_ERROR;
ELSE
	WriteToLog('Update_items_and_sourcing returned success', 3);
END IF;


--
-- Added by Renga on 01/20/04 . Added a call to create item attachments
--
WriteToLog('Before creating Attachments', 3);
For attachment_rec in attachment_cur
loop

  CTO_UTILITY_PK.create_item_attachments(p_ato_line_id   => attachment_rec.ato_line_id,
                                         x_return_status => x_return_status,
					 x_msg_count     => x_msg_count,
					 x_msg_data      => x_msg_data);
End loop;
WriteToLog('After creating Attachments', 3);

/* End of addition by Renga */

--
-- Launch child request to create BOM for each sequence
--

-- rkaza. bug 4524248. bom structure import enhancements. 11/05/05.
l_stmt_num := 75;

WriteToLog('update_configs: About to generate bom batch ID', 5);

cto_msutil_pub.set_bom_batch_id(x_return_status => l_return_status);

if l_return_status <> fnd_api.G_RET_STS_SUCCESS then
   WriteToLog('update_configs: ' || 'Failed in set_bom_batch_id with unexp error.', 1);
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

l_stmt_num := 80;

--Bugfix 10240482
--l_seq := 0;
--WHILE TRUE LOOP
FOR l_seq in 1..l_max_seq LOOP

--l_seq := l_seq + 1;
WriteToLog('update_configs:: '||to_char(l_seq));

BEGIN
select 'exists'
into l_exists
from bom_cto_order_lines_upg
where sequence = l_seq
and rownum = 1;

EXCEPTION
WHEN no_data_found THEN
  --Bugfix 10240482
  --exit;
  WriteToLog('update_configs:: No_Data_Found for l_seq:'|| l_seq, 1);
  goto end_loop;
END; -- sub block

WriteToLog('going to call CTOUPBOM with l_seq :: '||to_char(l_seq));
WriteToLog('and p_changed_src:: '||p_changed_src );

-- Added by Renga Kannan 03/30/06
-- This is a wrapper API to call PLM team's to sync up item media index
-- With out this sync up the item cannot be searched in Simple item search page
-- This is fixed for bug 4656048

CTO_MSUTIL_PUB.syncup_item_media_index;

l_stmt_num := 90;
l_request_id := fnd_request.submit_request(
			'BOM',
			'CTOUPBOM',
			null,
			null,
			TRUE,	-- should be TRUE, but inactive mgr issue
			l_seq,
                        p_changed_src);

WriteToLog('l_request_id:: '||to_char(l_request_id));

IF (l_request_id = 0) THEN
	WriteToLog('ERROR: Error launching child request for BOM creation.', 1);
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

<<end_loop>>
null;

END LOOP;

fnd_conc_global.set_req_globals(
				conc_status => 'PAUSED',
				request_data => 'CTO'
				);
return;

<< RESTART >>
--
-- The program will restart from this point after child requests complete
-- We should not rely on any variables that were initialized in the earlier
-- part of this procedure, as they would be reset
--
l_stmt_num := 100;
WriteToLog('Program restarted.');

--Bugfix 6710393
BEGIN
select assignment_set_id
into l_cto_aset_id
from mrp_assignment_sets
where assignment_set_name = 'CTO Configuration Updates';

--WriteToLog('CTO Seeded Assignment Set Id::'||l_cto_aset_id, 2);

EXCEPTION
WHEN no_data_found THEN
	WriteToLog('ERROR: CTO seeded assignment set not found', 1);
	RAISE FND_API.G_EXC_ERROR;
END;
WriteToLog('New Msg: CTO Seeded Assignment Set Id::'||l_cto_aset_id, 2);
--
-- Delete rows from CTO assignment set
--
delete from mrp_sr_assignments
where assignment_set_id = l_cto_aset_id;

WriteToLog('Rows deleted from CTO Seeded Assignment Set::' ||sql%rowcount, 2);
--Bugfix 6710393

--
-- Removing from CTO category
--
IF (p_item = 2) THEN
	delete from mtl_item_categories
	where category_id = p_cat_id;

	WriteToLog('Rows deleted from category::'||sql%rowcount, 2);
END IF;


--
-- Write status of all config items processed to log file
--
--Bugfix 13362916: Adding the new parameter
Write_Config_Status(l_return_status,l_return_code);

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	WriteToLog('Write_Config_Status returned unexpected error', 1);
ELSE
	WriteToLog('Write_Config_Status returned success', 3);
END IF;

--Bugfix 13362916
if l_return_code = 1 then
  retcode := 1;  --Program ends in warning

  WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
  WriteToLog('Update Existing Configurations completed with WARNING');
  WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
  errbuf := 'Program completed with warning.';
else
  WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
  WriteToLog('Update Existing Configurations completed with SUCCESS');
  WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
  errbuf := 'Program completed successfully.';
end if;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
	WriteToLog('ERROR: Exp error in CTO_Update_Configs_Pk.Update_Configs:: '|| l_stmt_num ||'::'||sqlerrm);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Existing Configurations completed with ERROR.', 1);
	WriteToLog('Please contact the system administrator.', 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Program completed with error';
        retcode := 2; --exits with error

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexp error in CTO_Update_Configs_Pk.Update_Configs:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Existing Configurations completed with ERROR');
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Program completed with error';
        retcode := 2; --exits with error

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in CTO_Update_Configs_Pk.Update_Configs:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Existing Configurations completed with ERROR.', 1);
	WriteToLog('Please contact the system administrator.', 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	errbuf := 'Progam completed with error';
        retcode := 2; --exits with error

END update_configs;


PROCEDURE populate_all_models(
p_changed_src IN varchar2,
p_open_lines IN varchar2,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2)

IS

--
-- cursor to select all individual (not top level) config
-- items in bac having item attribute = 3 and not in bcol_upg
--
CURSOR c_bac IS
-- individual configs not in bcol and having item attribute 3
select distinct bac.config_item_id config_id
from bom_ato_configurations bac,
mtl_system_items msi
where NOT EXISTS
	(select 'exists'
	from bom_cto_order_lines_upg bcolu
	where bcolu.config_item_id = bac.config_item_id)
and bac.base_model_id = msi.inventory_item_id
and bac.organization_id = msi.organization_id
and msi.config_orgs = '3'; -- bug 13362916 removed nvl for performance


--
-- cursor to select all top level config
-- items in bac having item attribute = 3 and not in bcol_upg
--
CURSOR c_bac_top IS
-- individual configs not in bcol and having item attribute 3
select distinct bac.config_item_id config_id
from bom_ato_configurations bac,
mtl_system_items msi
-- item attribute is 3
where bac.base_model_id = msi.inventory_item_id
and bac.organization_id = msi.organization_id
and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
-- and is top parent with attribute 3
and NOT EXISTS
	(select 'exists'
	from bom_ato_configurations bac2
	, mtl_system_items msi2
	where bac.config_item_id = bac2.component_item_id
	and bac2.base_model_id = msi2.inventory_item_id
	and bac2.organization_id = msi2.organization_id
	and msi2.config_orgs = '3') -- bug 13362916 removed nvl for performance
-- and not already in bcol_upg
and NOT EXISTS
	(select 'exists'
	from bom_cto_order_lines_upg bcolu
	where bcolu.config_item_id = bac.config_item_id);

l_match NUMBER;
l_exists varchar2(1);
l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_stmt_num number := 0;

l_count number;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	WriteToLog('Entering populate_all_models', 1);

	l_stmt_num := 10;
	l_match := fnd_profile.value('BOM:MATCH_CONFIG');
	WriteToLog('l_match is: '|| l_match, 1);

	l_stmt_num := 20;
	IF ((l_match = 2) AND (p_open_lines = 'N')) THEN
		-- match is off and open lines not to be upgraded
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		WriteToLog('Match profile is No and you chose not to update existing configurations. No configurations will be updated.');
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		return;
	END IF;


	l_stmt_num := 40;
	IF (p_changed_src = 'N') THEN
		-- sourcing has not changed
		WriteToLog('No changed sourcing', 1);
		l_stmt_num := 50;
		IF p_open_lines = 'Y' THEN
			--
			-- select all open order lines having config items with attribute in (2,3)
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 1', 3);

			select count(line_id)
			into l_count
			from bom_cto_order_lines_upg;
                        WriteToLog('kiran cont in bcol_upgs is =>'||l_count);

			l_stmt_num := 60;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, config_creation
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH                   --7201878
			--, 'N'		--PERFORM_MATCH
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(mtl.config_orgs, '1')
			--changed the where clause to use a subquery
			--bugfix 3841575
			from bom_cto_order_lines bcol2
			, mtl_system_items mtl
			-- select entire configuration
			where mtl.inventory_item_id =  bcol2.inventory_item_id
			and   mtl.organization_id = bcol2.ship_from_org_id
			and bcol2.ato_line_id in
			            (select distinct bcol1.ato_line_id
                                     from bom_cto_order_lines bcol1
                                     , oe_order_lines_all oel
				     , mtl_system_items msi
				    -- for configs whose models have attr=2,3
				    where bcol1.config_item_id is not null
				    and bcol1.inventory_item_id = msi.inventory_item_id
				    and bcol1.ship_from_org_id = msi.organization_id
				    and msi.config_orgs        in ('2', '3') -- bug 13362916 removed nvl for performance
				      -- and are on open order lines
				    and bcol1.line_id = oel.line_id
				    and oel.open_flag = 'Y'); -- bug 13362916 removed NVL


			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		ELSE /* p_open_lines = 'N' */
			--
			-- select all open order lines having canned config items with attribute = 3
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 2', 3);
			l_stmt_num := 70;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, config_creation
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH               --7201878
			--, 'Y'		--PERFORM_MATCH  /* Sushant Made changes for identifying matched items */
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(msi.config_orgs, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, bom_ato_configurations bac
			, oe_order_lines_all oel
			, mtl_system_items msi
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
			-- and exists in bcol
			and bac.config_item_id = bcol1.config_item_id
			-- on open order lines
			and bcol1.line_id = oel.line_id
			and oel.open_flag = 'Y' -- bug 13362916 removed NVL
			and bcol2.ato_line_id = bcol1.ato_line_id;
			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		END IF; /* p_open_lines = 'Y' */

		IF l_match = 1 THEN
			--
			-- select additional config items with attribute = 3 on closed order lines
			-- populate into bcol_upg
			-- mark as UPG
			--
			-- Commenting as part of Bugfix 8894392
			-- Reasoning: Suppose I had an OSS setup and the configs that have that setup
			-- are all on the closed SO lines. Now, I want to change the OSS for model in
			-- such a way that the shipping warehouse on these closed lines becomes an
			-- invalid org as per new OSS rules. Now when I run UEC for the old configs,
			-- the UEC ended in error saying ship from org is not valid. Thus even though
			-- the lines are closed, I cannot change the OSS setup on the model to make
			-- the old warehouse invalid.
			-- Changed the logic. Now we do not pick up any configs on closed lines. If a
			-- matched CIB = 3 config is not found on any open lines, we look for the config
			-- in bom_ato_configurations table.

			-- Another change is the use of decode while populating perform_match flag.
			-- This flag is now populated using this decode statement:
			-- decode(bcol.perform_match, 'C', 'Y', bcol.perform_match). This is done to make
			-- the behaviour of custom match similar to standard match. A lot of irregularities
			-- arose because of different treatment of custom and standard match in UEC. An
			-- example is:  bcmo and bcso get populated differently for perform_match = C and
			-- perform_match = Y. This resulted in wrong results.

			/*WriteToLog('sql 3', 3);
			l_stmt_num := 80;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, config_creation
			)
			select distinct
			bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , bcol.PERFORM_MATCH           --7201878
			--, 'Y'		--PERFORM_MATCH  /* Sushant made changes to identify matched items */
			/*, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, 99		-- matched item on closed line
			, bcol.PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(msi.config_orgs, '1')
			from bom_ato_configurations bac
			, bom_cto_order_lines bcol
			, mtl_system_items msi
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and nvl(msi.config_orgs, '1') = '3'
			-- and not already in bcol_upg
			and NOT EXISTS
				(select 'exists'
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = bac.config_item_id)
			-- select first ato_line_id in bcol
			and bcol.ato_line_id =
				(select bcol1.ato_line_id
				from bom_cto_order_lines bcol1
				where bcol1.config_item_id = bac.config_item_id
				-- pick up only if config is at top level
				and bcol1.line_id = bcol1.ato_line_id
				and rownum = 1)
			;
			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);*/

			--
			-- select all individual (not top level) config items in bac having item attribute = 3 and not in bcol_upg
			-- populate into bcol_upg from bcol or bac
			-- mark as UPG
			-- mark with program_id = 99 to indicate that it was populated from bac
			--
			WriteToLog('sql 3', 2);
			l_stmt_num := 90;
			FOR v_bac IN c_bac LOOP
				--
				-- check to see if not already populated as part of parent
				--
				WriteToLog('Item being populated from bac::'|| to_char(v_bac.config_id), 4);
				BEGIN
				select 'Y'
				into l_exists
				from bom_cto_order_lines_upg
				where config_item_id = v_bac.config_id
				and rownum = 1;
				WriteToLog('Item::'|| to_char(v_bac.config_id)||' already exists in bcolu', 4);

				EXCEPTION
				WHEN no_data_found THEN
				WriteToLog('Populating from bac Item::'|| to_char(v_bac.config_id), 4);
				populate_bcolu_from_bac(
					v_bac.config_id
					, l_return_status
					, l_msg_count
					, l_msg_data);
				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					WriteToLog('ERROR: Populate_bcolu_from_bac returned unexp error');
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
					WriteToLog('ERROR: Populate_bcolu_from_bac returned expected error');
					raise FND_API.G_EXC_ERROR;
				END IF;
				END; -- sub block
			END LOOP;

		END IF; /* l_match = 1 */
	ELSE
		WriteToLog('Changed sourcing', 1);

		-- srcing has changed
		l_stmt_num := 100;
		IF p_open_lines = 'Y' THEN
			--
			-- select all open order lines
			-- populate into bcol_upg
			-- mark as UPG
			-- TEST THIS!!
			--
			WriteToLog('sql 5', 3);
			l_stmt_num := 110;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, CONFIG_CREATION
			)
			select distinct
			bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , decode(bcol.perform_match, 'C', 'Y', bcol.perform_match)  -- Bugfix 8894392
			--, bcol.PERFORM_MATCH              --7201878
			--, 'N'		--PERFORM_MATCH
			, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, bcol.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(msi.CONFIG_ORGS, '1')
			from bom_cto_order_lines bcol
			, oe_order_lines_all oel
			, mtl_system_items msi
			-- select all configs on open order lines
			where bcol.ato_line_id = oel.ato_line_id
			and oel.open_flag = 'Y' -- bug 13362916 removed NVL
			and bcol.inventory_item_id = msi.inventory_item_id
			and bcol.ship_from_org_id = msi.organization_id
                        and oel.item_type_code = 'CONFIG' ; /* added condition for bug 3599397 */

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		ELSE /* p_open_lines = 'N' */
			--
			-- select all open order lines having canned config items with attribute = 3
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 6', 3);
			l_stmt_num := 120;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, CONFIG_CREATION
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH                 --7201878
			--, 'Y'		--PERFORM_MATCH   /* Sushant made changes to identify matched items */
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(msi.CONFIG_ORGS, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, bom_ato_configurations bac
			, oe_order_lines_all oel
			, mtl_system_items msi
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
			-- and exists in bcol
			and bac.config_item_id = bcol1.config_item_id
			-- on open order lines
			and bcol1.line_id = oel.line_id
			and oel.open_flag = 'Y' -- bug 13362916 removed nvl
			and bcol2.ato_line_id = bcol1.ato_line_id
			;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		END IF; /* p_open_lines = 'Y' */

		IF l_match = 1 THEN
			--
			-- select additional TOP LEVEL config items with attribute = 3 on closed order lines
			-- populate into bcol_upg
			-- mark as UPG
			--

			-- commenting as part of Bugfix 8894392
			/*WriteToLog('sql 7', 3);
			l_stmt_num := 130;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			, CONFIG_CREATION
			)
			select distinct
			bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , bcol.PERFORM_MATCH              --7201878
			--, 'N'		--PERFORM_MATCH  /* Sushant made changes to identify matched items */
			/*, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, 99		-- matched item on closed line
			, bcol.PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'		--REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			, nvl(msi.CONFIG_ORGS, '1')
			from bom_ato_configurations bac
			, bom_cto_order_lines bcol
			, mtl_system_items msi
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and nvl(msi.config_orgs, '1') = '3'
			-- and is top parent with attribute 3
			and NOT EXISTS
				(select 'exists'
				from bom_ato_configurations bac2
				, mtl_system_items msi2
				where bac.config_item_id = bac2.component_item_id
				and bac2.base_model_id = msi2.inventory_item_id
				and bac2.organization_id = msi2.organization_id
				and nvl(msi2.config_orgs, '1') = '3')
			-- and not already in bcol_upg
			and NOT EXISTS
				(select 'exists'
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = bac.config_item_id)
			-- select first ato_line_id in bcol
			and bcol.ato_line_id =
				(select bcol1.ato_line_id
				from bom_cto_order_lines bcol1
				where bcol1.config_item_id = bac.config_item_id
				-- pick up only if config is at top level
				and bcol1.line_id = bcol1.ato_line_id
				and rownum = 1)
			;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);*/

			--
			-- select all top level config items in bac having item attribute = 3 and not in bcol_upg
			-- populate into bcol_upg from bcol or bac
			-- mark as UPG
			-- mark with program_id = 99 to indicate that it was populated from bac
			--
			WriteToLog('sql 8', 3);
			l_stmt_num := 140;
			FOR v_bac_top IN c_bac_top LOOP
				WriteToLog('Item being populated from bac::'|| to_char(v_bac_top.config_id), 4);
				BEGIN
				select 'exists'
				into l_exists
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = v_bac_top.config_id
				and rownum = 1;
				WriteToLog('Item::'|| to_char(v_bac_top.config_id)||' already exists in bcolu', 4);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					WriteToLog('Populating from bac Item::'|| to_char(v_bac_top.config_id), 4);
					populate_bcolu_from_bac(
						v_bac_top.config_id
						, l_return_status
						, l_msg_count
						, l_msg_data);
					IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						WriteToLog('ERROR: Populate_bcolu_from_bac returned unexp error');
						raise FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
						WriteToLog('ERROR: Populate_bcolu_from_bac returned expected error');
						raise FND_API.G_EXC_ERROR;
					END IF;
				END; -- sub-block
			END LOOP;

		END IF; /* l_match = 1 */

	END IF; /* sourcing not changed */

	WriteToLog('Done populate_all_models.', 1);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	WriteToLog('ERROR: Expected error in Populate_All_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexpected error in Populate_All_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_All_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

END populate_all_models;


PROCEDURE populate_cat_models(
p_cat_id IN number,
p_changed_src IN varchar2,
p_open_lines IN varchar2,
-- bug 13876670
p_category_set_id IN NUMBER,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2)

IS

--
-- cursor to select all individual (not top level) config
-- items in bac having item attribute = 3
-- and assigned to CTO category and not in bcol_upg
--
CURSOR c_bac(p_cat_id number) IS
-- individual configs not in bcol and having item attribute 3
select /*+ ORDERED */ distinct bac.config_item_id config_id --Bugfix 6617686 Added a hint
from mtl_item_categories mcat,  --Bugfix 6617686: Changed the order of tables
mtl_system_items msi,
bom_ato_configurations bac
where NOT EXISTS
	(select 'exists'
	from bom_cto_order_lines_upg bcolu
	where bcolu.config_item_id = bac.config_item_id)
and bac.base_model_id = msi.inventory_item_id
and bac.organization_id = msi.organization_id
and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
-- and base model is in CTO category
and mcat.inventory_item_id = msi.inventory_item_id
and mcat.organization_id = msi.organization_id
and mcat.category_id = p_cat_id;


--
-- cursor to select all top level config
-- items in bac having item attribute = 3
-- and assigned to CTO category and not in bcol_upg
--
CURSOR c_bac_top(p_cat_id number, p_category_set_id number) IS
-- individual configs not in bcol and having item attribute 3
select distinct bac.config_item_id config_id  --Bugfix 6617686 Added a hint
from mtl_item_categories mcat, --Bugfix 6617686 Changed the order of tables
mtl_system_items msi,
bom_ato_configurations bac
-- item attribute is 3
where bac.base_model_id = msi.inventory_item_id
and bac.organization_id = msi.organization_id
and msi.config_orgs     = '3'
-- and base model is in CTO category
and mcat.inventory_item_id = msi.inventory_item_id
and mcat.organization_id = msi.organization_id
and mcat.category_id = p_cat_id
-- bug 13876670
and mcat.category_set_id = p_category_set_id
-- and is top parent with attribute 3
and NOT EXISTS
	(select /*+ no_unnest push_subq */ 'exists' -- bug 13876670 added hint
	from bom_ato_configurations bac2
	, mtl_system_items msi2
	where bac.config_item_id = bac2.component_item_id
	and bac2.base_model_id = msi2.inventory_item_id
	and bac2.organization_id = msi2.organization_id
	and msi2.config_orgs     = '3')
-- and not already in bcol_upg
and NOT EXISTS
	(select /*+ index(bcolu BOM_CTO_ORDER_LINES_UPG_N1) */ 'exists' -- 13362916 added hint
	from bom_cto_order_lines_upg bcolu
	where bcolu.config_item_id = bac.config_item_id);


l_match NUMBER;
l_exists varchar2(1);
l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_stmt_num number := 0;

BEGIN
	WriteToLog ('Entering populate_cat_models', 1);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_stmt_num := 10;

	l_match := fnd_profile.value('BOM:MATCH_CONFIG');
	WriteToLog ('l_match is: ' || to_char(l_match), 1);

	l_stmt_num := 20;
	IF ((l_match = 2) AND (p_open_lines = 'N')) THEN
		-- match is off and open lines not to be upgraded
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		WriteToLog('Match profile is No and you chose not to update existing configurations. No configurations will be updated.');
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		return;
	END IF;

	WriteToLog ('CTO category id:: '||to_char(p_cat_id), 1);

	l_stmt_num := 50;
	IF (p_changed_src = 'N') THEN
		-- sourcing has not changed
		WriteToLog('Sourcing has not changed', 2);

		IF p_open_lines = 'Y' THEN
			--
			-- select all open order lines having config items in l_cat_id with attribute in (2,3)
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 1', 3);
			l_stmt_num := 60;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, config_creation
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH           --7201878
			--, 'N'	--bcol2.PERFORM_MATCH
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'	--bcol2.REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol2.SEQUENCE
			, nvl(msi.config_orgs, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, oe_order_lines_all oel
			, mtl_system_items msi
			, mtl_item_categories mcat
			-- select entire configuration
			where bcol2.ato_line_id = bcol1.ato_line_id
			and bcol1.config_item_id is not null
			-- for configs whose models are in CTO category
			and mcat.inventory_item_id = bcol1.inventory_item_id
			and mcat.organization_id = bcol1.ship_from_org_id
			and mcat.category_id = p_cat_id
			-- for configs whose models have attr=2,3
			and bcol1.inventory_item_id = msi.inventory_item_id
			and bcol1.ship_from_org_id = msi.organization_id
			and msi.config_orgs        in ('2', '3') -- bug 13362916 removed nvl for performance
			-- and are on open order lines
			and bcol1.line_id = oel.ato_line_id /* changed line_id to ato_line_id */
			and oel.open_flag = 'Y' -- bug 13362916 removed NVL
                        and oel.item_type_code = 'CONFIG' ; /* added check for config linked to oe */

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		ELSE /* p_open_lines = 'N' */
			--
			-- select all open order lines having canned config items with attribute = 3
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 2', 3);
			l_stmt_num := 70;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, config_creation
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH                   --7201878
			--, 'Y'	--bcol2.PERFORM_MATCH /* Sushant made changes to identify matched items */
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'	--bcol2.REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol2.SEQUENCE
			, nvl(msi.config_orgs, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, bom_ato_configurations bac
			, oe_order_lines_all oel
			, mtl_system_items msi
			, mtl_item_categories mcat
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
			-- and exists in bcol
			and bac.config_item_id = bcol1.config_item_id
			-- for configs whose models are in CTO category
			and mcat.inventory_item_id = bcol1.inventory_item_id
			and mcat.organization_id = bcol1.ship_from_org_id
			and mcat.category_id = p_cat_id
			-- on open order lines
			and bcol1.line_id = oel.ato_line_id /* changed line_id to ato_line_id */
			and oel.open_flag = 'Y' -- bug 13362916 removed NVL
			and bcol2.ato_line_id = bcol1.ato_line_id
                        and oel.item_type_code = 'CONFIG' ;  /* added check for config linked to oe */
			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		END IF; /* p_open_lines = 'Y' */

		IF l_match = 1 THEN
			--
			-- select additional config items with attribute = 3 on closed order lines
			-- populate into bcol_upg
			-- mark as UPG
			--

			-- commenting as part of Bugfix 8894392
			/*WriteToLog('sql 3', 3);
			l_stmt_num := 80;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, config_creation
			)*/
			--select /*+ ORDERED*/ distinct  --Bugfix 6617686 Added a hint
			/*bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , bcol.PERFORM_MATCH                    --7201878
			--, 'N'	--bcol.PERFORM_MATCH
			, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, 99		-- matched item on closed line
			, bcol.PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'	--bcol.REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol.SEQUENCE
			, nvl(msi.config_orgs, '1')
			from mtl_item_categories mcat --Bugfix 6617686 Changed the order of tables
			, mtl_system_items msi
			, bom_ato_configurations bac
                        , bom_cto_order_lines bcol
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and nvl(msi.config_orgs, '1') = '3'
			-- and base model is in CTO category
			and mcat.inventory_item_id = msi.inventory_item_id
			and mcat.organization_id = msi.organization_id
			and mcat.category_id = p_cat_id
			-- and not already in bcol_upg
			and NOT EXISTS
				(select 'exists'
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = bac.config_item_id)
			-- select first ato_line_id in bcol
			and bcol.ato_line_id =
				(select bcol1.ato_line_id
				from bom_cto_order_lines bcol1
				where bcol1.config_item_id = bac.config_item_id
				-- pick up only if config is at top level
				and bcol1.line_id = bcol1.ato_line_id
				and rownum = 1)
			;
			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);*/

			--
			-- select all individual (not top level) config items in bac having item attribute = 3 and not in bcol_upg
			-- populate into bcol_upg from bcol or bac
			-- mark as UPG
			-- mark with program_id = 99 to indicate that it was populated from bac
			--
			WriteToLog('sql 4', 3);
			l_stmt_num := 90;
			FOR v_bac IN c_bac(p_cat_id) LOOP
				--
				-- check to see if not already populated as part of parent
				--
				WriteToLog('Item being populated from bac::'|| to_char(v_bac.config_id), 4);
				BEGIN
				select 'Y'
				into l_exists
				from bom_cto_order_lines_upg
				where config_item_id = v_bac.config_id
				and rownum = 1;
				WriteToLog('Item::'|| to_char(v_bac.config_id)||' already exists in bcolu', 4);

				EXCEPTION
				WHEN no_data_found THEN
				WriteToLog('Populating from bac Item::'|| to_char(v_bac.config_id), 4);
				populate_bcolu_from_bac(
					v_bac.config_id
					, l_return_status
					, l_msg_count
					, l_msg_data);
				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					WriteToLog('ERROR: Populate_bcolu_from_bac returned unexp error');
					raise FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
					WriteToLog('ERROR: Populate_bcolu_from_bac returned expected error');
					raise FND_API.G_EXC_ERROR;
				END IF;
				END; -- sub block
			END LOOP;

		END IF; /* l_match = 1 */
	ELSE
		WriteToLog('Sourcing has changed', 2);

		-- srcing changed
		IF p_open_lines = 'Y' THEN
			--
			-- select all open order lines
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 5', 3);
                        WriteToLog('p_category_set_id = '||p_category_set_id ||' p_cat_id = '||p_cat_id, 3);
			l_stmt_num := 100;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, CONFIG_CREATION
			)
			select distinct
			bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , decode(bcol.perform_match, 'C', 'Y', bcol.perform_match)  -- Bugfix 8894392
			--, bcol.PERFORM_MATCH                    --7201878
			--, 'N'	--bcol.PERFORM_MATCH
			, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, bcol.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'	--bcol.REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol.SEQUENCE
			, nvl(msi2.CONFIG_ORGS, '1')
			from bom_cto_order_lines bcol
			, oe_order_lines_all oel
			, mtl_system_items msi2
			-- select all configs on open order lines
			where bcol.ato_line_id = oel.ato_line_id
			and bcol.inventory_item_id = msi2.inventory_item_id
			and bcol.ship_from_org_id = msi2.organization_id
			and oel.open_flag = 'Y' -- 13362916 removed NVL
			and oel.ato_line_id in -- bug 6617686 connect using oel rather than bcol to get better filtering
				(select /*+ leading(MCAT) */ distinct bcol2.ato_line_id --Bugfix 6617686 Added a hint
				from mtl_item_categories mcat --Bugfix 6617686 Changed the order of tables
				, mtl_system_items msi
				, bom_cto_order_lines bcol2
				where bcol2.config_item_id is not null
				and bcol2.inventory_item_id = msi.inventory_item_id
				and bcol2.ship_from_org_id = msi.organization_id
				-- and base model is in CTO category
				and mcat.inventory_item_id = msi.inventory_item_id
				and mcat.organization_id = msi.organization_id
				and mcat.category_id = p_cat_id
                                -- bug 13876670
                                and mcat.category_set_id = p_category_set_id)
                        and oel.item_type_code = 'CONFIG' ;/* original bug detected, added condition for bug 3599397 */

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		ELSE /* p_open_lines = 'N' */
			--
			-- select all open order lines having canned config items with attribute = 3 and assigned to CTO category
			-- populate into bcol_upg
			-- mark as UPG
			-- TEST THIS!!
			--
			WriteToLog('sql 6', 3);
			l_stmt_num := 110;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, CONFIG_CREATION
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH                   --7201878
			--, 'Y'	--bcol2.PERFORM_MATCH  /* Sushant made changes to identify matched items */
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'	--bcol2.REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol2.SEQUENCE
			, nvl(msi.CONFIG_ORGS, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, bom_ato_configurations bac
			, oe_order_lines_all oel
			, mtl_system_items msi
			, mtl_item_categories mcat
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and msi.config_orgs     = '3' -- bug 13362916 removed nvl for performance
			-- and exists in bcol
			and bac.config_item_id = bcol1.config_item_id
			-- on open order lines
			and bcol1.line_id = oel.line_id
			and oel.open_flag = 'Y' -- bug 13362916 removed nvl
			and bcol2.ato_line_id = bcol1.ato_line_id
			-- and base model is in CTO category
			and mcat.inventory_item_id = msi.inventory_item_id
			and mcat.organization_id = msi.organization_id
			and mcat.category_id = p_cat_id
                        -- bug 13876670
                        and mcat.category_set_id = p_category_set_id;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);

		END IF; /* p_open_lines = 'Y' */

		IF l_match = 1 THEN
			--
			-- select additional TOP LEVEL config items with attribute = 3 on closed order lines
			-- populate into bcol_upg
			-- mark as UPG
			--
			-- commenting as part of Bugfix 8894392
			/*WriteToLog('sql 7', 3);
			l_stmt_num := 120;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, CONFIG_CREATION
			)*/
			--select /*+ leading(MCAT) */ distinct
			/*bcol.ATO_LINE_ID
			, bcol.BATCH_ID
			, bcol.BOM_ITEM_TYPE
			, bcol.COMPONENT_CODE
			, bcol.COMPONENT_SEQUENCE_ID
			, bcol.CONFIG_ITEM_ID
			, bcol.INVENTORY_ITEM_ID
			, bcol.ITEM_TYPE_CODE
			, bcol.LINE_ID
			, bcol.LINK_TO_LINE_ID
			, bcol.ORDERED_QUANTITY
			, bcol.ORDER_QUANTITY_UOM
			, bcol.PARENT_ATO_LINE_ID
                        , bcol.PERFORM_MATCH                    --7201878
			--, 'Y'	--bcol.PERFORM_MATCH /* Sushant made changes to identify matched items */
			/*, bcol.PLAN_LEVEL
			, bcol.SCHEDULE_SHIP_DATE
			, bcol.SHIP_FROM_ORG_ID
			, bcol.TOP_MODEL_LINE_ID
			, bcol.WIP_SUPPLY_TYPE
			, bcol.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol.CREATED_BY
			, bcol.LAST_UPDATE_LOGIN
			, bcol.REQUEST_ID
			, bcol.PROGRAM_APPLICATION_ID
			, 99		-- matched item on closed line
			, bcol.PROGRAM_UPDATE_DATE
			, bcol.OPTION_SPECIFIC
			, 'N'	--bcol.REUSE_CONFIG
			, bcol.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol.SEQUENCE
			, nvl(msi.CONFIG_ORGS, '1')
			from bom_ato_configurations bac
			, bom_cto_order_lines bcol
			, mtl_system_items msi
			, mtl_item_categories mcat
			-- base model has item attr = 3
			where bac.base_model_id = msi.inventory_item_id
			and bac.organization_id = msi.organization_id
			and nvl(msi.config_orgs, '1') = '3'
			-- and base model is in CTO category
			and mcat.inventory_item_id = msi.inventory_item_id
			and mcat.organization_id = msi.organization_id
			and mcat.category_id = p_cat_id
			-- and is top parent with attribute 3
			and NOT EXISTS
				(select 'exists'
				from bom_ato_configurations bac2
				, mtl_system_items msi2
				where bac.config_item_id = bac2.component_item_id
				and bac2.base_model_id = msi2.inventory_item_id
				and bac2.organization_id = msi2.organization_id
				and nvl(msi2.config_orgs, '1') = '3')
			-- and not already in bcol_upg
			and NOT EXISTS
				(select 'exists'
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = bac.config_item_id)
			-- select first ato_line_id in bcol
			and bcol.ato_line_id =
				(select bcol1.ato_line_id
				from bom_cto_order_lines bcol1
				where bcol1.config_item_id = bac.config_item_id
				-- pick up only if config is at top level
				and bcol1.line_id = bcol1.ato_line_id
				and rownum = 1)
			;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);*/

			--
			-- select all top level config items in bac having item attribute = 3 and not in bcol_upg
			-- populate into bcol_upg from bcol or bac
			-- mark as UPG
			-- mark with program_id = 99 to indicate that it was populated from bac
			--
			WriteToLog('sql 8', 3);
			l_stmt_num := 130;
			FOR v_bac_top IN c_bac_top(p_cat_id, p_category_set_id) LOOP --13876670
				WriteToLog('Item being populated from bac::'|| to_char(v_bac_top.config_id), 4);
				BEGIN
				select 'exists'
				into l_exists
				from bom_cto_order_lines_upg bcolu
				where bcolu.config_item_id = v_bac_top.config_id
				and rownum = 1;
				WriteToLog('Item::'|| to_char(v_bac_top.config_id)||' already exists in bcolu', 4);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					WriteToLog('Populating from bac Item::'|| to_char(v_bac_top.config_id), 4);
					populate_bcolu_from_bac(
						v_bac_top.config_id
						, l_return_status
						, l_msg_count
						, l_msg_data);
					IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						WriteToLog('ERROR: Populate_bcolu_from_bac returned unexp error');
						raise FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
						WriteToLog('ERROR: Populate_bcolu_from_bac returned expected error');
						raise FND_API.G_EXC_ERROR;
					END IF;
				END; -- sub-block
			END LOOP;

		END IF; /* l_match = 1 */

	END IF; /* ms or oss not defined */

	WriteToLog('Done populate_cat_models.', 1);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	WriteToLog('ERROR: Expected error in Populate_Cat_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexpected error in Populate_Cat_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Cat_Models::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       		FND_MSG_PUB.Add_Exc_Msg
       			(G_PKG_NAME
       			,'Populate_Cat_Models');
       	END IF;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

END Populate_Cat_Models;


PROCEDURE populate_config(
p_changed_src IN varchar2,
p_open_lines IN varchar2,
p_config_id IN number,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2) IS

l_match NUMBER;
l_attribute NUMBER;
l_exists varchar2(1);
l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_stmt_num number := 0;

BEGIN
	WriteToLog ('Entering populate_config', 1);
	WriteToLog ('p_config_id is: ' || to_char(p_config_id), 1);
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_stmt_num := 10;

	l_match := fnd_profile.value('BOM:MATCH_CONFIG');
	WriteToLog ('l_match is: ' || to_char(l_match), 1);
	l_stmt_num := 20;

	IF ((l_match = 2) AND (p_open_lines = 'N')) THEN
		-- match is off and open lines not to be upgraded
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		WriteToLog('Match profile is No and you chose not to update existing configurations. No configurations will be updated.');
		WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++');
		return;
	END IF;

	-- get item attribute for this config
	l_stmt_num := 40;
	select nvl(msi.config_orgs, '1')
	into l_attribute
	from mtl_system_items msi
	where msi.inventory_item_id =
		(select msi2.base_item_id
		from mtl_system_items msi2
		where msi2.inventory_item_id = p_config_id
		and rownum = 1)
	and rownum = 1;

	WriteToLog ('Config_creation is: ' || to_char(l_attribute), 1);

	IF (p_changed_src = 'N' and l_attribute = 1) THEN
		-- no changed sourcing and attribute is 1
		WriteToLog('Sourcing has not changed. Item attribute is 1.Configuration item will not be processed.', 1);
		return;
	ELSE
		IF p_open_lines = 'Y' THEN
			--
			-- select all open order lines having this config item
			-- populate into bcol_upg
			-- mark as UPG
			--
			WriteToLog('sql 1', 3);
			l_stmt_num := 50;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, CONFIG_CREATION
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
			, decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.perform_match  -- Sushant Changed as part of bug 3472654  'N'
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'	--bcol2.REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol2.SEQUENCE
			, nvl(msi.config_orgs, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, oe_order_lines_all oel
			, mtl_system_items msi
			, oe_order_lines_all oel2 --bugfix 3371155
			-- select entire configuration
			where bcol2.ato_line_id = bcol1.ato_line_id
			-- to get item attribute
			and msi.inventory_item_id = bcol2.inventory_item_id
			and msi.organization_id = bcol2.ship_from_org_id
			-- for this config
			and bcol1.config_item_id = p_config_id
			-- and are on open order lines
			and bcol1.line_id = oel.line_id
			and oel.open_flag = 'Y' -- bug 13362916 removed nvl
			--bugfix  3371155
			 and bcol1.ato_line_id = oel2.ato_line_id
                        and oel2.item_type_code = 'CONFIG'
			--end 3371155
			;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);


		ELSE /* p_open_lines = 'N' */
			--
			-- select all open order lines having this canned config item, only if it has attribute = 3
			-- populate into bcol_upg
			-- mark as UPG
			--
			IF (l_attribute = 3) THEN
			WriteToLog('sql 2', 3);
			l_stmt_num := 60;
			insert into bom_cto_order_lines_upg
			(
			 ATO_LINE_ID
			, BATCH_ID
			, BOM_ITEM_TYPE
			, COMPONENT_CODE
			, COMPONENT_SEQUENCE_ID
			, CONFIG_ITEM_ID
			, INVENTORY_ITEM_ID
			, ITEM_TYPE_CODE
			, LINE_ID
			, LINK_TO_LINE_ID
			, ORDERED_QUANTITY
			, ORDER_QUANTITY_UOM
			, PARENT_ATO_LINE_ID
			, PERFORM_MATCH
			, PLAN_LEVEL
			, SCHEDULE_SHIP_DATE
			, SHIP_FROM_ORG_ID
			, TOP_MODEL_LINE_ID
			, WIP_SUPPLY_TYPE
			, HEADER_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN
			, REQUEST_ID
			, PROGRAM_APPLICATION_ID
			, PROGRAM_ID
			, PROGRAM_UPDATE_DATE
			, OPTION_SPECIFIC
			, REUSE_CONFIG
			, QTY_PER_PARENT_MODEL
			, STATUS
			--, SEQUENCE
			, CONFIG_CREATION
			)
			select distinct
			bcol2.ATO_LINE_ID
			, bcol2.BATCH_ID
			, bcol2.BOM_ITEM_TYPE
			, bcol2.COMPONENT_CODE
			, bcol2.COMPONENT_SEQUENCE_ID
			, bcol2.CONFIG_ITEM_ID
			, bcol2.INVENTORY_ITEM_ID
			, bcol2.ITEM_TYPE_CODE
			, bcol2.LINE_ID
			, bcol2.LINK_TO_LINE_ID
			, bcol2.ORDERED_QUANTITY
			, bcol2.ORDER_QUANTITY_UOM
			, bcol2.PARENT_ATO_LINE_ID
                        , decode(bcol2.perform_match, 'C', 'Y', bcol2.perform_match)  -- Bugfix 8894392
			--, bcol2.PERFORM_MATCH                   --7201878
			--, 'Y'	--bcol2.PERFORM_MATCH /* Sushant made change to identify matched items */
			, bcol2.PLAN_LEVEL
			, bcol2.SCHEDULE_SHIP_DATE
			, bcol2.SHIP_FROM_ORG_ID
			, bcol2.TOP_MODEL_LINE_ID
			, bcol2.WIP_SUPPLY_TYPE
			, bcol2.HEADER_ID
			, sysdate	--LAST_UPDATE_DATE
			, bcol2.LAST_UPDATED_BY
			, sysdate	--CREATION_DATE
			, bcol2.CREATED_BY
			, bcol2.LAST_UPDATE_LOGIN
			, bcol2.REQUEST_ID
			, bcol2.PROGRAM_APPLICATION_ID
			, bcol2.PROGRAM_ID
			, sysdate	--PROGRAM_UPDATE_DATE
			, bcol2.OPTION_SPECIFIC
			, 'N'	--bcol2.REUSE_CONFIG
			, bcol2.QTY_PER_PARENT_MODEL
			, 'UPG'		--STATUS
			--, bcol2.SEQUENCE
			, nvl(msi.config_orgs, '1')
			from bom_cto_order_lines bcol1
			, bom_cto_order_lines bcol2
			, bom_ato_configurations bac
			, oe_order_lines_all oel
			, mtl_system_items msi
			where bac.config_item_id = p_config_id
			-- and exists in bcol
			and bac.config_item_id = bcol1.config_item_id
			-- on open order lines
			and bcol1.line_id = oel.line_id
			and oel.open_flag = 'Y' -- bug 13362916. removed nvl
			and bcol2.ato_line_id = bcol1.ato_line_id
			-- to get item attribute
			and msi.inventory_item_id = bcol2.inventory_item_id
			and msi.organization_id = bcol2.ship_from_org_id;

			WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);
			END IF;

		END IF; /* p_open_lines = 'Y' */

		IF l_match = 1 THEN
			--
			-- select this config item on closed order lines, only if attribute = 3 and not already in bcol_upg
			-- populate into bcol_upg
			-- mark as UPG
			--
			-- commenting as part of Bugfix 8894392
			/*IF (l_attribute = 3) THEN
				WriteToLog('sql 3', 3);
				l_stmt_num := 70;
				insert into bom_cto_order_lines_upg
				(
				 ATO_LINE_ID
				, BATCH_ID
				, BOM_ITEM_TYPE
				, COMPONENT_CODE
				, COMPONENT_SEQUENCE_ID
				, CONFIG_ITEM_ID
				, INVENTORY_ITEM_ID
				, ITEM_TYPE_CODE
				, LINE_ID
				, LINK_TO_LINE_ID
				, ORDERED_QUANTITY
				, ORDER_QUANTITY_UOM
				, PARENT_ATO_LINE_ID
				, PERFORM_MATCH
				, PLAN_LEVEL
				, SCHEDULE_SHIP_DATE
				, SHIP_FROM_ORG_ID
				, TOP_MODEL_LINE_ID
				, WIP_SUPPLY_TYPE
				, HEADER_ID
				, LAST_UPDATE_DATE
				, LAST_UPDATED_BY
				, CREATION_DATE
				, CREATED_BY
				, LAST_UPDATE_LOGIN
				, REQUEST_ID
				, PROGRAM_APPLICATION_ID
				, PROGRAM_ID
				, PROGRAM_UPDATE_DATE
				, OPTION_SPECIFIC
				, REUSE_CONFIG
				, QTY_PER_PARENT_MODEL
				, STATUS
				, CONFIG_CREATION
				)
				select distinct
				bcol.ATO_LINE_ID
				, bcol.BATCH_ID
				, bcol.BOM_ITEM_TYPE
				, bcol.COMPONENT_CODE
				, bcol.COMPONENT_SEQUENCE_ID
				, bcol.CONFIG_ITEM_ID
				, bcol.INVENTORY_ITEM_ID
				, bcol.ITEM_TYPE_CODE
				, bcol.LINE_ID
				, bcol.LINK_TO_LINE_ID
				, bcol.ORDERED_QUANTITY
				, bcol.ORDER_QUANTITY_UOM
				, bcol.PARENT_ATO_LINE_ID
                                , bcol.PERFORM_MATCH                    --7201878
				--, 'Y'	--bcol.PERFORM_MATCH  /* Sushant made changes to identify matched items */
				/*, bcol.PLAN_LEVEL
				, bcol.SCHEDULE_SHIP_DATE
				, bcol.SHIP_FROM_ORG_ID
				, bcol.TOP_MODEL_LINE_ID
				, bcol.WIP_SUPPLY_TYPE
				, bcol.HEADER_ID
				, sysdate	--LAST_UPDATE_DATE
				, bcol.LAST_UPDATED_BY
				, sysdate	--CREATION_DATE
				, bcol.CREATED_BY
				, bcol.LAST_UPDATE_LOGIN
				, bcol.REQUEST_ID
				, bcol.PROGRAM_APPLICATION_ID
				, 99		-- matched item on closed line
				, bcol.PROGRAM_UPDATE_DATE
				, bcol.OPTION_SPECIFIC
				, 'N'	--bcol.REUSE_CONFIG
				, bcol.QTY_PER_PARENT_MODEL
				, 'UPG'		--STATUS
				, nvl(msi.config_orgs, '1')
				from bom_ato_configurations bac
				, bom_cto_order_lines bcol
				, mtl_system_items msi
				where bac.config_item_id = p_config_id
				and NOT EXISTS
					(select 'exists'
					from bom_cto_order_lines_upg bcolu
					where bcolu.config_item_id = bac.config_item_id)
				-- select first ato_line_id in bcol
				and bcol.ato_line_id =
					(select bcol1.ato_line_id
					from bom_cto_order_lines bcol1
					where bcol1.config_item_id = bac.config_item_id
					-- pick up only if config is at top level
					and bcol1.line_id = bcol1.ato_line_id
					and rownum = 1)
				-- to get item attribute
				and msi.inventory_item_id = bcol.inventory_item_id
				and msi.organization_id = bcol.ship_from_org_id;

				WriteToLog('Rows inserted::'|| to_char(sql%rowcount), 3);
			END IF;*/

			--
			-- populate into bcol_upg from bac
			-- if not already exists
			-- only if attribute = 3
			-- mark as UPG
			-- mark with program_id = 99 to indicate that it was populated from bac
			--
			WriteToLog('sql 4', 3);

			--
			-- check to see if not already populated as part of parent
			--
			IF (l_attribute = 3) THEN

			WriteToLog('Item being populated from bac::'|| to_char(p_config_id), 4);
			l_stmt_num := 80;
			BEGIN
			select 'Y'
			into l_exists
			from bom_cto_order_lines_upg
			where config_item_id = p_config_id
			and rownum = 1;
			WriteToLog('Item::'|| to_char(p_config_id)||' already exists in bcolu', 4);

			EXCEPTION
			WHEN no_data_found THEN
			WriteToLog('Populating from bac Item::'|| to_char(p_config_id), 4);
			populate_bcolu_from_bac(
				p_config_id
				, l_return_status
				, l_msg_count
				, l_msg_data);
			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				WriteToLog('ERROR: Populate_bcolu_from_bac returned unexp error');
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
				WriteToLog('ERROR: Populate_bcolu_from_bac returned expected error');
				raise FND_API.G_EXC_ERROR;
			END IF;
			END; -- sub block
			END IF; /* l_attribute = 3 */
		END IF; /* l_match = 1 */

	END IF; /* sourcing not changed, attribute is 1*/

	WriteToLog('Done populate_config');

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	WriteToLog('ERROR: Expected error in Populate_Config::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexpected error in Populate_Config::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Config::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

END populate_config;


PROCEDURE populate_bcolu_from_bac(
	p_config_id IN number,
	x_return_status out NOCOPY varchar2,
	x_msg_count out NOCOPY number,
	x_msg_data out NOCOPY varchar2) IS

t_bcol BCOL_TAB;

CURSOR c_bac_data IS
select
bom_cto_order_lines_s1.nextval,		-- line_id
substr(bac.component_code, (instr(bac.component_code, '-', -1)+1)),	-- inventory_item_id
bac.component_item_id,			-- header_id::storing comp_item_id here for intermediate processing
bac.component_code,			-- component_code
msi.bom_item_type,			-- bom_item_type
msi.primary_uom_code,			-- order_quantity_uom
bac.component_quantity,			-- ordered_quantity
bac.component_quantity,			-- per_quantity
sysdate,				-- schedule_ship_date
'N' , -- option_specific BUGFIX 3602292 defaulted this value to N as model will not have option_specific_sourced flag.
nvl(msi.config_orgs, '1'),		-- config_orgs
sysdate,				-- creation_date
nvl(Fnd_Global.USER_ID, -1),		-- created_by
sysdate,				-- last_update_date
nvl(Fnd_Global.USER_ID, -1),		-- last_updated_by
cto_update_configs_pk.bac_program_id,	-- program_id
'Y',					-- perform_match  /* Sushant made changes to identify matched items */
'N',					-- reuse_config
bac.organization_id
from bom_ato_configurations bac,
mtl_system_items msi
where bac.config_item_id = p_config_id
-- and bac.component_item_id <> bac.base_model_id -- not pick up top model
and msi.inventory_item_id = substr(bac.component_code, (instr(bac.component_code, '-', -1)+1))	-- bac.component_item_id
and msi.organization_id = bac.organization_id;

l_index number := 0;
l_top_model_line_id number;
l_base_model_id number;
l_header_id number;
i number := 0;
l_child_config_id NUMBER;
l_parent_index NUMBER;
l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_stmt_num number;

l_skip_config number := 0;  --Bugfix 13362916
l_exists varchar2(1);       --Bugfix 13362916
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_stmt_num := 10;

        -- bug 13362916
        WriteToLog('=================Inside populate_bcolu_from_bac:p_config_id::' || p_config_id || '=================');

	BEGIN
	select base_model_id
	into l_base_model_id
	from bom_ato_configurations
	where config_item_id = p_config_id
	and rownum = 1;

	EXCEPTION
	WHEN no_data_found THEN
		WriteToLog('Config does not exist in match tables.');
		return;
	END;

	--
	-- Get cursor data from bac into t_bcol
	--
	l_stmt_num := 20;
	OPEN c_bac_data;

	WHILE(TRUE)
	LOOP

	l_index := t_bcol.count + 1;
        l_stmt_num := 30;

	FETCH c_bac_data INTO
		t_bcol(l_index).line_id,
		t_bcol(l_index).inventory_item_id,
		t_bcol(l_index).header_id,
		t_bcol(l_index).component_code,
		t_bcol(l_index).bom_item_type,
		t_bcol(l_index).order_quantity_uom,
		t_bcol(l_index).ordered_quantity,
		t_bcol(l_index).qty_per_parent_model,
		t_bcol(l_index).schedule_ship_date,
		t_bcol(l_index).option_specific,
		t_bcol(l_index).config_creation,
		t_bcol(l_index).creation_date,
		t_bcol(l_index).created_by,
		t_bcol(l_index).last_update_date,
		t_bcol(l_index).last_updated_by,
		t_bcol(l_index).program_id,
		t_bcol(l_index).perform_match,
		t_bcol(l_index).reuse_config,
                t_bcol(l_index).ship_from_org_id;

	EXIT WHEN c_bac_data%NOTFOUND OR c_bac_data%NOTFOUND IS NULL;

	l_stmt_num := 35;
	IF t_bcol(l_index).inventory_item_id = l_base_model_id THEN
		l_top_model_line_id := t_bcol(l_index).line_id;
		t_bcol(l_index).plan_level := 1;
		t_bcol(l_index).config_item_id := p_config_id;
	END IF;

	END LOOP;
	CLOSE c_bac_data;

	--
	-- populate t_bcol recursively for all child configs
	-- error out if any child config has item attribute <> 3
	--
	l_stmt_num := 40;
	FOR i IN t_bcol.first .. t_bcol.last LOOP

		IF t_bcol(i).header_id <> t_bcol(i).inventory_item_id THEN
			-- this is a lower level config
			l_child_config_id := t_bcol(i).header_id;
			l_parent_index := i;

                        --
                        -- Bug 13362916
                        --
                        WriteToLog('Calling populate_child_config:l_parent_index::' || l_parent_index);
                        WriteToLog('Calling populate_child_config:l_child_config_id::' || l_child_config_id);

			populate_child_config(
				t_bcol,
				l_parent_index,
				l_child_config_id,
				l_return_status,
				l_msg_count,
				l_msg_data);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				WriteToLog('ERROR: Populate_child_config returned unexp error.');
                                --
				-- bug 13362916
                                --
				-- raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                l_skip_config := 1;
                                exit;
			END IF;

		END IF;
	END LOOP;

        -- bug 13362916
        IF l_skip_config = 0 then  --Bugfix 13362916
           l_stmt_num := 50;
           select bom_cto_order_lines_s1.nextval
           into l_header_id
           from dual;

           -- populate top_model_line_id, ato_line_id and header_id
           l_stmt_num := 60;
           FOR i IN 1..t_bcol.count LOOP
                   t_bcol(i).top_model_line_id := l_top_model_line_id;
                   t_bcol(i).ato_line_id := l_top_model_line_id;
                   t_bcol(i).header_id := l_header_id;
           END LOOP;

           -- populate link_to_line_id
           l_stmt_num := 70;
           populate_link_to_line_id(t_bcol,
                                   l_return_status);
           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   WriteToLog('ERROR: Populate_link_to_line_id returned unexp error');
                   --Bugfix 13362916
		   --raise FND_API.G_EXC_UNEXPECTED_ERROR;
		   l_skip_config := 1;
           END IF;

           -- convert t_bcol to sparse array
           l_stmt_num := 80;
           IF l_skip_config = 0 then  --Bugfix 13362916
              contiguous_to_sparse_bcol(t_bcol,
                                      l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      WriteToLog('ERROR: Contiguous_to_sparse_bcol returned unexp error');
                      --Bugfix 13362916
		      --raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      l_skip_config := 1;
              END IF;
           END IF;

           -- populate plan_level
           l_stmt_num := 90;
           IF l_skip_config = 0 then  --Bugfix 13362916
              populate_plan_level(t_bcol,
                              l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      WriteToLog('ERROR: Populate_plan_level returned unexp error');
                      --Bugfix 13362916
		      --raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      l_skip_config := 1;
              END IF;
           END IF;

           -- populate wip_supply_type
           l_stmt_num := 100;
           IF l_skip_config = 0 then  --Bugfix 13362916
              populate_wip_supply_type(t_bcol,
                                      l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      WriteToLog('ERROR: Populate_wip_supply_type returned unexp error');
                      --Bugfix 13362916
		      --raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      l_skip_config := 1;
              -- bug 5859772: If a 'N' (for no data found exception in populate_wip_supply_type ) is returned,
              -- it means the bill has changed since the config was created.
              -- We will not process the config in that case and simply return.
              ELSIF l_return_status = 'N' then
                      WriteToLog('Model bill has changed since the config was created. Not processing this config '||p_config_id, 1);
                      return;
              END IF;
           END IF;

           -- populate parent_ato_line_id
           l_stmt_num := 110;
           IF l_skip_config = 0 then  --Bugfix 13362916
              populate_parent_ato(t_bcol,
                              l_top_model_line_id,
                              l_return_status);
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      WriteToLog('ERROR: Populate_parent_ato returned unexp error');
                      --Bugfix 13362916
		      --raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      l_skip_config := 1;
              END IF;
           END IF;

           -- insert into bcol
           l_stmt_num := 120;
           IF l_skip_config = 0 then  --Bugfix 13362916
              i := t_bcol.first;

              WHILE i IS NOT NULL LOOP
                      l_stmt_num := 130;
                      INSERT INTO bom_cto_order_lines_upg(
                           HEADER_ID ,
                           LINE_ID ,
                           LINK_TO_LINE_ID ,
                           ATO_LINE_ID ,
                           PARENT_ATO_LINE_ID ,
                           TOP_MODEL_LINE_ID ,
                           PLAN_LEVEL ,
                           WIP_SUPPLY_TYPE ,
                           PERFORM_MATCH ,
                           BOM_ITEM_TYPE ,
                           COMPONENT_CODE ,
                           COMPONENT_SEQUENCE_ID ,
                           CONFIG_ITEM_ID ,
                           INVENTORY_ITEM_ID ,
                           ITEM_TYPE_CODE ,
                           BATCH_ID ,
                           ORDERED_QUANTITY ,
                           ORDER_QUANTITY_UOM ,
                           SCHEDULE_SHIP_DATE ,
                           SHIP_FROM_ORG_ID ,
                           LAST_UPDATE_DATE ,
                           LAST_UPDATED_BY ,
                           CREATION_DATE ,
                           CREATED_BY ,
                           LAST_UPDATE_LOGIN ,
                           REQUEST_ID ,
                           PROGRAM_APPLICATION_ID ,
                           PROGRAM_ID ,
                           PROGRAM_UPDATE_DATE ,
                           QTY_PER_PARENT_MODEL,
                           OPTION_SPECIFIC,
                           REUSE_CONFIG,
                           STATUS,
                           SEQUENCE,
                           CONFIG_CREATION
                           )
                      VALUES (
                           t_bcol(i).header_id,
                           t_bcol(i).line_id,
                           t_bcol(i).link_to_line_id,
                           t_bcol(i).ato_line_id,
                           t_bcol(i).parent_ato_line_id,
                           t_bcol(i).top_model_line_id,
                           t_bcol(i).plan_level,
                           t_bcol(i).wip_supply_type,
                           'Y',       -- perform_match BUGFIX 3567693
                           t_bcol(i).bom_item_type,
                           t_bcol(i).component_code,
                           t_bcol(i).component_sequence_id,
                           t_bcol(i).config_item_id,
                           t_bcol(i).inventory_item_id,
                           decode(t_bcol(i).line_id, t_bcol(i).ato_line_id, 'MODEL', decode(t_bcol(i).bom_item_type, '4', 'OPTION', 'CLASS')),
                           null,      -- batch_id
                           t_bcol(i).ordered_quantity,
                           t_bcol(i).order_quantity_uom,
                           t_bcol(i).schedule_ship_date,
                           t_bcol(i).ship_from_org_id,
                           t_bcol(i).last_update_date,
                           t_bcol(i).last_updated_by,
                           t_bcol(i).creation_date,
                           t_bcol(i).created_by,
                           t_bcol(i).last_update_login,
                           null,      -- request_id
                           null,      -- program_application_id
                           t_bcol(i).program_id,
                           null,      -- program_update_date
                           t_bcol(i).qty_per_parent_model,
                           t_bcol(i).option_specific,
                           'N',
                           'UPG',
                           null,
                           t_bcol(i).config_creation
                           );

              WriteToLog('populate_bcolu_from_bac: Inserted ' || t_bcol(i).line_id);
                      i:= t_bcol.next(i);
              END LOOP;
           END IF;
        END IF;  --l_skip_config = 0 -- bug 13362916

        --Bugfix 13362916
        IF l_skip_config = 1 then  --Bugfix 12633924: Removed else.
          WriteToLog('populate_bcolu_from_bac: skipping config_id:' || p_config_id);
          --Check if this config already exists in bcolu
          BEGIN
            select 'Y'
            into l_exists
            from bom_cto_order_lines_upg
            where config_item_id = p_config_id
            and rownum = 1;

            WriteToLog('Item::'|| to_char(p_config_id)||' already exists in bcolu', 4);

          EXCEPTION
            WHEN no_data_found THEN
              WriteToLog('Populating bcolu for config id:' || p_config_id || 'in status ERROR.');
              for i in t_bcol.first..t_bcol.last loop
                if t_bcol.exists(i) then
                  if t_bcol(i).inventory_item_id = l_base_model_id then
                    WriteToLog('populate_bcolu_from_bac: inserting in bcolu in status ERROR');

                    INSERT INTO bom_cto_order_lines_upg(
                          HEADER_ID ,
                          LINE_ID ,
                          ATO_LINE_ID ,
                          PARENT_ATO_LINE_ID ,
                          TOP_MODEL_LINE_ID ,
                          PERFORM_MATCH ,
                          BOM_ITEM_TYPE ,
                          COMPONENT_CODE ,
                          CONFIG_ITEM_ID ,
                          INVENTORY_ITEM_ID ,
                          ITEM_TYPE_CODE ,
                          BATCH_ID ,
                          ORDERED_QUANTITY ,
                          ORDER_QUANTITY_UOM ,
                          SCHEDULE_SHIP_DATE ,
                          SHIP_FROM_ORG_ID ,
                          LAST_UPDATE_DATE ,
                          LAST_UPDATED_BY ,
                          CREATION_DATE ,
                          CREATED_BY ,
                          LAST_UPDATE_LOGIN ,
                          REQUEST_ID ,
                          PROGRAM_APPLICATION_ID ,
                          PROGRAM_ID ,
                          PROGRAM_UPDATE_DATE ,
                          QTY_PER_PARENT_MODEL,
                          OPTION_SPECIFIC,
                          REUSE_CONFIG,
                          STATUS,
                          SEQUENCE,
                          CONFIG_CREATION
                    )
                    VALUES (
                          t_bcol(i).header_id,
                          t_bcol(i).line_id,
                          l_top_model_line_id,
                          l_top_model_line_id,
                          l_top_model_line_id,
                          'Y',  -- perform_match
                          t_bcol(i).bom_item_type,
                          t_bcol(i).component_code,
                          t_bcol(i).config_item_id,
                          t_bcol(i).inventory_item_id,
                          decode(t_bcol(i).line_id, l_top_model_line_id, 'MODEL', decode(t_bcol(i).bom_item_type, '4', 'OPTION', 'CLASS')),
                          null, -- batch_id
                          t_bcol(i).ordered_quantity,
                          t_bcol(i).order_quantity_uom,
                          t_bcol(i).schedule_ship_date,
                          t_bcol(i).ship_from_org_id,
                          t_bcol(i).last_update_date,
                          t_bcol(i).last_updated_by,
                          t_bcol(i).creation_date,
                          t_bcol(i).created_by,
                          t_bcol(i).last_update_login,
                          null, -- request_id
                          null, -- program_application_id
                          t_bcol(i).program_id,
                          null, -- program_update_date
                          t_bcol(i).qty_per_parent_model,
                          t_bcol(i).option_specific,
                          'N',
                          'ERROR',
                          null,
                          t_bcol(i).config_creation
                    );

                    exit;
                  end if;
                end if;
              end loop;
          END;
        end if;
        WriteToLog('=================End populate_bcolu_from_bac:p_config_id::' || p_config_id || '=================');

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexpected error in Populate_Bcolu_From_Bac::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Bcolu_From_Bac::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

END populate_bcolu_from_bac;


PROCEDURE populate_child_config(
	t_bcol IN OUT NOCOPY bcol_tab,
	p_parent_index IN NUMBER,
	p_child_config_id IN NUMBER,
	x_return_status out NOCOPY varchar2,
	x_msg_count out NOCOPY number,
	x_msg_data out NOCOPY varchar2) IS


CURSOR c_bac_child_data(l_curr_config_id NUMBER) IS
select
bom_cto_order_lines_s1.nextval,		-- line_id
substr(bac.component_code, (instr(bac.component_code, '-', -1)+1)),	-- inventory_item_id
bac.component_item_id,			-- header_id::storing comp_item_id here for intermediate processing
substr(bac.component_code, (instr(bac.component_code, '-', 1)+1)),	-- component_code
--bac.config_item_id,			-- config_item_id
msi.bom_item_type,			-- bom_item_type
msi.primary_uom_code,			-- order_quantity_uom
bac.component_quantity,			-- ordered_quantity
bac.component_quantity,			-- per_quantity
sysdate,				-- schedule_ship_date
nvl(to_char(msi.option_specific_sourced),'N'),		-- option_specific --bugfix3845686
nvl(msi.config_orgs, '1'),		-- config_orgs
sysdate,				-- creation_date
nvl(Fnd_Global.USER_ID, -1),		-- created_by
sysdate,				-- last_update_date
nvl(Fnd_Global.USER_ID, -1),		-- last_updated_by
cto_update_configs_pk.bac_program_id,	-- program_id
bac.organization_id                     --Bugfix 10240482
from bom_ato_configurations bac,
mtl_system_items msi
where bac.config_item_id = l_curr_config_id
and bac.component_item_id <> bac.base_model_id --not pick up top model
and msi.inventory_item_id = bac.component_item_id
and msi.organization_id = bac.organization_id;

l_child_config_id NUMBER;
l_parent_index NUMBER;
i NUMBER;
l_item_attr NUMBER;
l_new_index NUMBER;
l_index NUMBER;
l_return_status	varchar2(1);
l_msg_count number;
l_msg_data varchar2(240);
l_child_model_id number;
l_child_model_name varchar2(50);
l_stmt_num number;

BEGIN

	--
	-- populate t_bcol recursively for all child configs
	-- error out if any child config has item attribute <> 3
	--
	WriteToLog('ENTERED Populate_child_config, this is a recursive api ');
	WriteToLog('IN parameters ');
	WriteToLog('p_parent_index=>'||p_parent_index);
	WriteToLog('p_child_config_id=>'||p_child_config_id);

	l_stmt_num := 10;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_parent_index := p_parent_index;

	WriteToLog('t_bcol(l_parent_index).header_id=>'||t_bcol(l_parent_index).header_id);

	select nvl(msi.config_orgs, '1'), inventory_item_id
	into l_item_attr, l_child_model_id
	from mtl_system_items msi
	where msi.inventory_item_id = (select base_item_id --bugfix3845686
	                               from mtl_system_items
				       where inventory_item_id = t_bcol(l_parent_index).header_id
				       and rownum =1)
	--and msi.organization_id = t_bcol(l_parent_index).ship_from_org_id;
	and rownum = 1;


        WriteToLog('l_item_attr=>'||l_item_attr);

	l_stmt_num := 20;
	IF (nvl(l_item_attr, 1) <> 3) THEN

		l_stmt_num := 30;
		select substrb(concatenated_segments,1,50) name
		into l_child_model_name
		from mtl_system_items_kfv msi
		where msi.inventory_item_id = l_child_model_id
		and rownum=1;/* Fixed bug 3529482 */



		WriteToLog('++++++++++++++++++++++++++++++++++++++++', 1);
		WriteToLog('Item attribute Configured Item, BOM creation not setup correctly for child model '||l_child_model_name||' . Please correct this and run the program again.', 1);
		WriteToLog('++++++++++++++++++++++++++++++++++++++++', 1);
		raise FND_API.G_EXC_ERROR;
	ELSE
		-- populate config_id column for this line
		l_stmt_num := 40;
		t_bcol(l_parent_index).config_item_id := t_bcol(l_parent_index).header_id;
		l_new_index := t_bcol.count + 1;

		-- populate child config from bac
		l_stmt_num := 50;
		OPEN c_bac_child_data(p_child_config_id);

		WHILE(TRUE)
		LOOP
			l_stmt_num := 60;
			l_index := t_bcol.count + 1;

			FETCH c_bac_child_data INTO
				t_bcol(l_index).line_id,
				t_bcol(l_index).inventory_item_id,
				t_bcol(l_index).header_id,
				t_bcol(l_index).component_code,
				t_bcol(l_index).bom_item_type,
				t_bcol(l_index).order_quantity_uom,
				t_bcol(l_index).ordered_quantity,
				t_bcol(l_index).qty_per_parent_model,
				t_bcol(l_index).schedule_ship_date,
				t_bcol(l_index).option_specific,
				t_bcol(l_index).config_creation,
				t_bcol(l_index).creation_date,
				t_bcol(l_index).created_by,
				t_bcol(l_index).last_update_date,
				t_bcol(l_index).last_updated_by,
				t_bcol(l_index).program_id,
				t_bcol(l_index).ship_from_org_id;  --Bugfix 10240482;

		       EXIT WHEN c_bac_child_data%NOTFOUND; --	bugfix 3845686

				t_bcol(l_index).component_code := t_bcol(p_parent_index).component_code||'-'||t_bcol(l_index).component_code;
				t_bcol(l_index).ordered_quantity := t_bcol(p_parent_index).ordered_quantity * t_bcol(l_index).ordered_quantity;



		END LOOP;

		CLOSE c_bac_child_data;
	END IF;


	l_stmt_num := 70;
	FOR i IN l_new_index .. t_bcol.last LOOP
		IF t_bcol(i).header_id <> t_bcol(i).inventory_item_id THEN

			-- this is a lower level config
			l_stmt_num := 80;
			l_child_config_id := t_bcol(i).header_id;
			l_parent_index := i;

			--KIRAN
			WriteToLog('CIB of item being passed=>'||t_bcol(i).config_creation);

			populate_child_config(
				t_bcol,
				l_parent_index,
				l_child_config_id,
				l_return_status,
				l_msg_count,
				l_msg_data);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				WriteToLog('ERROR: Populate_child_config returned unexp error');
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	END LOOP;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	WriteToLog('ERROR: Unexpected error in Populate_Child_Config::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Child_Config::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	CTO_MSG_PUB.Count_And_Get
       		(p_msg_count => x_msg_count
       		,p_msg_data  => x_msg_data
       		);

END populate_child_config;


PROCEDURE populate_link_to_line_id(
p_bcol_tab IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2) IS

TYPE varchar2_1000_tbl_type IS TABLE OF varchar2(1000) INDEX BY binary_integer;
l_parent_code_tab varchar2_1000_tbl_type;
l_loc number :=0 ;
l_stmt_num number;

BEGIN

	l_stmt_num := 10;
	FOR i IN 1..p_bcol_tab.count LOOP
		l_loc := instr(p_bcol_tab(i).component_code , '-' , -1 );
		IF (l_loc = 0) THEN
			l_parent_code_tab(i) := null;
		ELSE
			l_parent_code_tab(i) := substr(p_bcol_tab(i).component_code, 1, l_loc-1);
		END IF;
		p_bcol_tab(i).link_to_line_id := null;
	END LOOP;

	l_stmt_num := 20;
	FOR i IN 1..l_parent_code_tab.count LOOP
		FOR j IN 1..p_bcol_tab.count LOOP
			IF (l_parent_code_tab(i) = p_bcol_tab(j).component_code) THEN
				p_bcol_tab(i).link_to_line_id := p_bcol_tab(j).line_id;
               			EXIT;

			END IF;
		END LOOP;
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Link_To_Line_Id::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_link_to_line_id;


PROCEDURE populate_plan_level(
p_t_bcol IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2)
IS

TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
v_raw_line_id TABNUM ;
v_src_point   number ;
j             number ;
i             number := 0 ;
l_stmt_num number;

BEGIN

	l_stmt_num := 10;
	i := p_t_bcol.first ;

	WHILE i IS NOT NULL LOOP
		IF (p_t_bcol.exists(i)) THEN
			v_src_point := i;

			l_stmt_num := 20;
			WHILE (p_t_bcol(v_src_point).plan_level IS NULL) LOOP
				v_raw_line_id(v_raw_line_id.count + 1) := v_src_point;
				v_src_point := p_t_bcol(v_src_point).link_to_line_id;
			END LOOP;

			j := v_raw_line_id.count;

			l_stmt_num := 30;
			WHILE (j >= 1) LOOP
				p_t_bcol(v_raw_line_id(j)).plan_level := p_t_bcol(v_src_point).plan_level + 1;
				v_src_point := v_raw_line_id(j);
				j := j -1;
			END LOOP;
			v_raw_line_id.delete;
		END IF;

		i := p_t_bcol.next(i);
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Plan_Level::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_plan_level;


PROCEDURE populate_wip_supply_type(
p_t_bcol IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2)
IS

v_item number;
v_parent_item number;
i number := 0;
l_stmt_num number;

BEGIN

	l_stmt_num := 10;
	i := p_t_bcol.first ;

	WHILE i IS NOT NULL LOOP
		IF (p_t_bcol.exists(i)) THEN
			l_stmt_num := 20;
			IF (p_t_bcol(i).line_id <> p_t_bcol(i).ato_line_id) THEN
				v_item := i;
				v_parent_item := p_t_bcol(v_item).link_to_line_id;
				l_stmt_num := 30;
-- bug 5859772: We need to handle a no data found here. This can happen if the bill
-- has changed since the config was created. In such a case we shall not process
-- the config.
                                begin
                                select
				bic.wip_supply_type,
				bic.component_sequence_id
				into p_t_bcol(v_item).wip_supply_type,
				p_t_bcol(v_item).component_sequence_id
				from bom_bill_of_materials bbom,
				bom_inventory_components bic
				where bbom.bill_sequence_id =
					(select common_bill_sequence_id
					from bom_bill_of_materials
					where assembly_item_id = p_t_bcol(v_parent_item).inventory_item_id
					and alternate_bom_designator is null
					and rownum = 1)
				and bbom.common_bill_sequence_id = bic.bill_sequence_id
				and bic.component_item_id = p_t_bcol(v_item).inventory_item_id
				and rownum = 1;
                                exception
                                   when no_data_found then
                                       x_return_status := 'N';
                                end;
-- end bug fix 5859772

			END IF; /* line_id <> ato_line_id */
		END IF; /* exists */

		i := p_t_bcol.next(i);
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Wip_Supply_Type::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_wip_supply_type;


PROCEDURE populate_parent_ato(
p_t_bcol in out NOCOPY bcol_tab,
p_bcol_line_id in bom_cto_order_lines.line_id%type,
x_return_status	OUT NOCOPY varchar2)
IS

TYPE TABNUM IS TABLE of NUMBER index by binary_integer;
v_raw_line_id TABNUM;
v_src_point NUMBER;
v_prev_src_point NUMBER;
j NUMBER;
v_step VARCHAR2(10);
i NUMBER := 0;
l_stmt_num number;

BEGIN
	l_stmt_num := 10;
	i := p_t_bcol.first;

	WHILE i IS NOT NULL LOOP
		l_stmt_num := 20;
		IF (p_t_bcol.exists(i)) THEN
			v_src_point := i;
			WHILE (p_t_bcol.exists(v_src_point)) LOOP
				v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point;
				v_prev_src_point := v_src_point;
				v_src_point := p_t_bcol(v_src_point).link_to_line_id;
				l_stmt_num := 30;
				IF (v_src_point IS NULL or v_prev_src_point = p_bcol_line_id) THEN
					v_src_point := v_prev_src_point;
					EXIT;
				END IF;

				l_stmt_num := 40;
				IF (p_t_bcol(v_src_point).bom_item_type = '1' AND
					p_t_bcol(v_src_point).ato_line_id IS NOT NULL AND
					nvl (p_t_bcol(v_src_point).wip_supply_type , 0) <> '6') THEN
						EXIT;
				END IF;
			END LOOP;

			j := v_raw_line_id.count;

			l_stmt_num := 50;
			WHILE (j >= 1) LOOP
				p_t_bcol(v_raw_line_id(j)).parent_ato_line_id := v_src_point;
				j := j -1;
			END LOOP;

			v_raw_line_id.delete;
		END IF;

		i := p_t_bcol.next(i);
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Populate_Parent_Ato::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_parent_ato;


PROCEDURE contiguous_to_sparse_bcol(
p_t_bcol in out NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2)
IS

p_t_sparse_bcol bcol_tab;
l_stmt_num number;

BEGIN

	l_stmt_num := 10;
	FOR i IN 1..p_t_bcol.count LOOP
		p_t_sparse_bcol(i) := p_t_bcol(i);
	END LOOP;

	p_t_bcol.delete;

	l_stmt_num := 20;
	FOR i IN 1..p_t_sparse_bcol.count LOOP
		p_t_bcol(p_t_sparse_bcol(i).line_id) := p_t_sparse_bcol(i);
	END LOOP;

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('ERROR: Others error in Contiguous_To_Sparse_Bcol::'||to_char(l_stmt_num)||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END contiguous_to_sparse_bcol;


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0) IS
BEGIN
    IF gDebugLevel >= p_level THEN
	fnd_file.put_line (fnd_file.log, p_message);
    END IF;
END WriteToLog;


PROCEDURE Write_Config_Status(
x_return_status out NOCOPY varchar2,
--Bugfix 13362916
x_return_code   out NOCOPY number)
IS

--
-- This cursor will pick up all successfully upgraded configs:
-- 	If config_creation = 3 and successful on atleast one order line
--	Or if config_creation = 1,2 and successful on all order lines
--
CURSOR c_success IS
select distinct substrb(concatenated_segments,1,50) name,msi.inventory_item_id
item_id
from bom_cto_order_lines_upg bcolu,
mtl_system_items_kfv msi
where bcolu.config_item_id is not null
and bcolu.config_item_id = msi.inventory_item_id
and bcolu.ship_from_org_id = msi.organization_id
and ((bcolu.config_creation = '3'
	and exists (select 'exists'
		from bom_cto_order_lines_upg bcolu1
		where bcolu1.config_item_id = bcolu.config_item_id
		and bcolu1.status = 'MRP_SRC'
		and rownum = 1))
or (bcolu.config_creation <> '3'
	and not exists (select 'exists'
		from bom_cto_order_lines_upg bcolu1
		where bcolu1.config_item_id = bcolu.config_item_id
		and bcolu1.status <> 'MRP_SRC')))
order by 1;  -- Modified by Renga for bug 3930047

--
-- This cursor will pick up all errored configs:
-- 	If errored on all order lines
--
CURSOR c_error IS
select distinct substrb(concatenated_segments,1,50) name,
                 msi.inventory_item_id item_id
from bom_cto_order_lines_upg bcolu,
mtl_system_items_kfv msi
where bcolu.config_item_id is not null
and bcolu.config_item_id = msi.inventory_item_id
and bcolu.ship_from_org_id = msi.organization_id
and not exists (select 'exists'
		from bom_cto_order_lines_upg bcolu1
		where bcolu1.config_item_id = bcolu.config_item_id
		and bcolu1.status = 'MRP_SRC')
order by 1;  -- Modified by Renga for bug 3930047

--
-- This cursor will pick up partially successful configs:
-- 	If config_creation = 1,2 and errored out on some
--	order lines and successul on other order lines
--
CURSOR c_partial IS
select distinct substrb(concatenated_segments,1,50) name,
        msi.inventory_item_id item_id,
	oeh.order_number,
	decode(bcolu.status, 'MRP_SRC', 'was successfully processed', 'errored out') status
from bom_cto_order_lines_upg bcolu,
mtl_system_items_kfv msi,
oe_order_lines_all oel,
oe_order_headers_all oeh
where bcolu.config_item_id is not null
and bcolu.config_item_id = msi.inventory_item_id
and bcolu.ship_from_org_id = msi.organization_id
and config_creation <> '3'
and exists (select 'exists'
	from bom_cto_order_lines_upg bcolu1
	where bcolu1.config_item_id = bcolu.config_item_id
	and bcolu1.status = 'MRP_SRC')
and exists (select 'exists'
	from bom_cto_order_lines_upg bcolu1
	where bcolu1.config_item_id = bcolu.config_item_id
	and bcolu1.status <> 'MRP_SRC')
and oel.line_id = bcolu.ato_line_id
and oel.header_id = oeh.header_id
order by name, status;

l_stmt_num number;

BEGIN

l_stmt_num := 10;
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_return_code := 0; -- bug 13362916

WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
WriteToLog('Following configuration items were processed successfully for Item, BOM and Routing creation:');

FOR v_success IN c_success LOOP
	WriteToLog('    '||v_success.name||'('||v_success.item_id||')', 1);
END LOOP;

l_stmt_num := 20;
WriteToLog(' ', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
WriteToLog('Following configuration items were not processed for Item, BOM and Routing creation due to errors:');

FOR v_error IN c_error LOOP
   WriteToLog('    '||v_error.name||'('||v_error.item_id||')', 1);
   --Bugfix 13362916: This will make the program end in warning if there are
   --some configs that are in error.
   x_return_code := 1;
END LOOP;

WriteToLog('These configuration items may exist on multiple order lines. Please go through the log file for details on error and action required for each configuration item in error for all order lines.', 1);

l_stmt_num := 30;
WriteToLog(' ', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
WriteToLog('Following configuration items were partially successful for Item, BOM and Routing creation:');

FOR v_partial IN c_partial LOOP
    WriteToLog('    Configuration item '||v_partial.name||'('||v_partial.item_id||')'||' '||v_partial.status||' for order number '||v_partial.order_number, 1);
    --Bugfix 13362916: This will make the program end in warning if there are
    --some configs that are only partially processed.
    x_return_code := 1;
END LOOP;

WriteToLog('Please go through the log file for details on error and action required for each configuration item in error.');

WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);
WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 1);

EXCEPTION
WHEN OTHERS THEN
	WriteToLog('Others error in Write_Config_Status::'||l_stmt_num||'::'||sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Write_Config_Status;


--start bugfix 3377963
--Checks if a model with CIB attribute 1 or 2 is present under a model
--with a cib attribute 3
PROCEDURE Check_invalid_configurations(
x_return_status	out NOCOPY varchar2)

IS

CURSOR c_invalid_configuration IS
SELECT bom_item_type,
       wip_supply_type,
       config_creation,
       config_item_id,
       inventory_item_id,
       parent_ato_line_id,
       ato_line_id,
       line_id,
       ship_from_org_id
FROM   bom_cto_order_lines_upg
WHERE ato_line_id in ( SELECT DISTINCT bupg1.ato_line_id
                       FROM  bom_cto_order_lines_upg bupg1
		       WHERE bupg1.config_creation = 3);

TYPE r_bcolupg IS RECORD
(
       bom_item_type      number,
       wip_supply_type    number,
       config_creation    number,
       config_item_id     number,
       inventory_item_id  number,
       parent_ato_line_id number,
       ato_line_id        number,
       line_id            number,
       status             number,   -- 0 : fine --1  :  error
       ship_from_org_id   number
);


--Bugfix 9148706: Indexing by LONG
--TYPE bcol_upg_tbl_type IS TABLE OF r_bcolupg index by binary_integer;
TYPE bcol_upg_tbl_type IS TABLE OF r_bcolupg index by LONG;

t_bcol bcol_upg_tbl_type;

TYPE number_arr_tbl_type IS TABLE OF number index by binary_integer;

t_ato_line_id number_arr_tbl_type;

k number;
i number;
l_stmt_num number;


BEGIN
 l_stmt_num := 10;
 x_return_status := FND_API.G_RET_STS_SUCCESS;


l_stmt_num := 20;
FOR c_config in c_invalid_configuration
LOOP
 k := c_config.line_id;

 t_bcol(k).bom_item_type      := c_config.bom_item_type;
 t_bcol(k).wip_supply_type    := c_config.wip_supply_type;
 t_bcol(k).config_creation    := c_config.config_creation;
 t_bcol(k).config_item_id     := c_config.config_item_id;
 t_bcol(k).inventory_item_id  := c_config.inventory_item_id;
 t_bcol(k).parent_ato_line_id := c_config.parent_ato_line_id ;
 t_bcol(k).ato_line_id        := c_config.ato_line_id ;
 t_bcol(k).line_id            := c_config.line_id ;
 t_bcol(k).status             := 0;
 t_bcol(K).ship_from_org_id   := c_config.ship_from_org_id;

END LOOP;


--CHECKING for invalid configuration
l_stmt_num := 30;
i := t_bcol.first ;

l_stmt_num := 40;
while i is not null
loop
      if( t_bcol(i).bom_item_type = 1
          and
          nvl(t_bcol(i).wip_supply_type, 1 ) <> 6
	  and
	  t_bcol(i).config_creation in (1, 2)
	  and
	  t_bcol(t_bcol(i).ato_line_id).status = 0 ) then

             if( t_bcol(t_bcol(i).parent_ato_line_id).config_creation = 3) then

	         t_bcol(t_bcol(i).ato_line_id).status := 1;

		    l_stmt_num := 50;
                    IF t_ato_line_id.count = 0 THEN
		        t_ato_line_id(1) := t_bcol(i).ato_line_id;
	            ELSE
                        t_ato_line_id( t_ato_line_id.last+1) := t_bcol(i).ato_line_id;
		    END IF; --t_ato_line_id

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Check_invalid_configurations: ' ||
		                     'INVALID MODEL SETUP exists for line id  '  ||t_bcol(i).line_id
                                     || ' model item ' || t_bcol(i).inventory_item_id
                                     || ' Ship from org'||t_bcol(i).ship_from_org_id
                                     || ' item config creation ' || t_bcol(i).config_creation
                                     || ' parent line id  '  || t_bcol(t_bcol(i).parent_ato_line_id).line_id
                                     || ' parent model item ' || t_bcol(t_bcol(i).parent_ato_line_id).inventory_item_id
                                     || ' parent config_creation ' || t_bcol(t_bcol(i).parent_ato_line_id).config_creation
                                      , 1 );

                 END IF; --oe debug


             end if; --config_creation = 3

         end if ;

          l_stmt_num := 60;
          i := t_bcol.next(i) ;

end loop ;

l_stmt_num := 70;
IF t_ato_line_id.count = 0 THEN
   oe_debug_pub.add('There are NO invalid configurations',5);

ELSIF t_ato_line_id.count > 0 THEN
  l_stmt_num := 75;
  oe_debug_pub.add('There are ' || t_ato_line_id.count ||'top ato models with invalid configurations');

  l_stmt_num := 80;
  FORALL j IN t_ato_line_id.first..t_ato_line_id.last
  UPDATE bom_cto_order_lines_upg
  SET status  = 'ERROR'
  WHERE ato_line_id = t_ato_line_id(j);

  l_stmt_num:= 90;
  oe_debug_pub.add('Updated '||sql%rowcount||'lines with error status',1);

END IF;


EXCEPTION

WHEN OTHERS THEN
	WriteToLog('ERROR: Unexp error in CTO_Update_Configs_Pk.Check_invalid_configurations:: '|| l_stmt_num ||'::'||sqlerrm, 1);
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog('Update Existing Configurations completed with ERROR');
	WriteToLog('+++++++++++++++++++++++++++++++++++++++++++++++++++');
	WriteToLog(' error in Check_invalid_configurations::'||sqlerrm, 1);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END Check_invalid_configurations;

--bugfix 3259017
--added no copy to out variables
Procedure update_atp_attributes(
                          p_item          IN  Number,
                          p_cat_id        IN  Number,
                          p_config_id     IN  Number,
                          x_return_status OUT NOCOPY varchar2,
                          x_msg_data      OUT NOCOPY Varchar2,
                          x_msg_count     OUT NOCOPY Number) is
Begin
   WriteToLog('   Entering Update_atp_attributes procedure');
   If p_item = 1 Then

      -- Update based on all models

      update mtl_system_items_b msic
      set    (atp_components_flag,atp_flag) = (select CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(nvl(msim.atp_flag,'N'),nvl(msim.atp_components_flag,'N')),CTO_CONFIG_ITEM_PK.get_atp_flag
                                         from   mtl_system_items_b msim
                                         where  msim.inventory_item_id = msic.base_item_id
				          and    msim.organization_id   = msic.organization_id)

      where msic.base_item_id is not null
      and   'x'= (select 'x'
              from mtl_system_items_b msim1
              where msim1.inventory_item_id = msic.base_item_id
              and   msim1.organization_id   = msic.organization_id);



      WriteToLog(' Number of records updated = '||sql%rowcount);

   elsif p_item = 2 then
     -- update based on the category id
      update mtl_system_items_b msic
      set    (atp_components_flag,atp_flag) = (select CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(nvl(msim.atp_flag,'N'),nvl(msim.atp_components_flag,'N')),CTO_CONFIG_ITEM_PK.get_atp_flag
                                        from   mtl_system_items_b msim
                                        where  msim.inventory_item_id = msic.base_item_id
				        and    msim.organization_id   = msic.organization_id)
      where msic.inventory_item_id in (select msi.inventory_item_id
                                       from mtl_system_items_b msi,
				            mtl_item_categories mcat
				       where msi.base_item_id = mcat.inventory_item_id
				       and   mcat.category_id = p_cat_id)
     and exists (select 'x' from mtl_system_items_b msim
                 where  msim.inventory_item_id = msic.base_item_id
                 and    msim.organization_id   = msic.organization_id);

      WriteToLog(' Number of records updated = '||sql%rowcount);

   elsif p_item = 3 then
     -- update based on config item
     update mtl_system_items_b msic
     set    (atp_components_flag,atp_flag)  = (select CTO_CONFIG_ITEM_PK.evaluate_atp_attributes(msim.atp_flag,msim.atp_components_flag),CTO_CONFIG_ITEM_PK.get_atp_flag
                                        from   mtl_system_items_b msim
                                        where  msim.inventory_item_id = msic.base_item_id
				        and    msim.organization_id   = msic.organization_id)
     where  msic.inventory_item_id = p_config_id
     and    exists (select 'x' from mtl_system_items_b msim
                    where  msim.inventory_item_id = msic.base_item_id
                    and    msim.organization_id   = msic.organization_id);
      WriteToLog(' Number of records updated = '||sql%rowcount);
   end if;

End Update_atp_attributes;

--end bugfix 3377963



END CTO_UPDATE_CONFIGS_PK;

/
