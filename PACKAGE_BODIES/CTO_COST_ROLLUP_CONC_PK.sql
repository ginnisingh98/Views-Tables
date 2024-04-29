--------------------------------------------------------
--  DDL for Package Body CTO_COST_ROLLUP_CONC_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_COST_ROLLUP_CONC_PK" as
/* $Header: CTOCRCNB.pls 120.2.12000000.2 2007/03/09 12:38:35 abhissri ship $*/


/*
 *=========================================================================*
 |                                                                         |
 | Copyright (c) 2001, Oracle Corporation, Redwood Shores, California, USA |
 |                           All rights reserved.                          |
 |                                                                         |
 *=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |            CTO Cost rollup   package body                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   PL/SQL package body containing the  routine  for cost rollup          |
 |   of configuration items.                          			   |
 |   For different combination of parameters passed , code gets the parent |
 |   config item and its child and insert them into cst_sc_lists	   |
 |									   |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   Input :  	Config Item 		: Select this config item          |
 |		Base Model Item 	: All configs for this base model  |
 |		Item Created Days Ago   : All configs created in last "n"  |
 |					  days.				   |
 |		Organization		: Calculate cost for all configs in|
 |					  this org.			   |
 | HISTORY                                                                 |
 |   Date      Author           Comments                                                     |
 | --------- --------           ----------------------------------------------------         |
 |  10/27/2003  KSARKAR         creation of body      CTO_COST_ROLLUP_CONC_PK                |
 |                                                                                           |
 |  08/06/2004  Sushant Sawant  Modified                                                     |
 |                              Bugfix 3777922                                                  |
 |                              Changed code to process sourcing for parent before           |
 |                              child config item. This will ensure child sourcing           |
 |                              starts from the end manufacturing org of the parent config   |
 |                              Only Top config items will be picked from main cursor for    |
 |                              upgrade scenario as get_config_details will return child     |
 |                              configurations                                               |
 |
 |                              Bugfix 3784283
 |                              Cost Rollup will be performed in batches of approx 100 records
 |                              Total# of records should be >= 100 to be considered as a batch
 |                              A batch will consist of parent configs and all their children.
 |                              A logical break will consider parents and all their children
 |                              A savepoint will be created after each batch is processed.
 |                              A rollback to the previous savepoint will be performed for an
 |                              erroneous batch. Processing will continue for remaining records.
 |                              A summary of successful/failed configuration items will be
 |                              provided at the end of the program.
 |
 |                                                                                           |
 |                                                                                           |
 |                                                                                           |
 |  11/23/2004  Sushant Sawant  Modified                                                     |
 |                              bugfix 3941383                                               |
 |                              cost rollup for child configuration is not performed in      |
 |                              the root sourcing org if child model has 100% transfer from
 |                              sourcing rule.
 |                                                                                           |
 |                                                                                           |
 |                                                                                           |
 |  11/23/2004  Sushant Sawant  Modified                                                     |
 |                              bugfix 3975083                                               |
 |                              Optional cost rollup process fails when processing multiple  |
 |                              batches.                                                     |
 |                              Modified the code to reinitialize the index variable to      |
 |                              collect data for next batch in cfg_item_array array.         |
 |                                                                                           |
 |                                                                                           |
 *==========================================================================================*/

gMrpAssignmentSet        number ;

gUserId   number := nvl(fnd_global.user_id, -1);
gLoginId  number := nvl(fnd_global.login_id, -1);

-- Forward declaration
PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0);

-- Forward decalration

PROCEDURE get_sourcing_org (
	p_config_item_id     number
      , p_organization_id   number
      , p_return_status     out NOCOPY varchar2 );


/**********************************************************************************
Procedure body:	CTO_COST_ROLLUP_CONC_PK :
   This a stored PL/SQL concurrent program that rolls up config item cost based on
   different criteria.

INPUT arguments:
 p_config_item_id 	: Configuration Item.
 p_model_id  	: Configs with this base Model Item.
 p_num_of_days	: Configs created in the last "n" days.
 p_org_id	: Oreganization Id
 p_upgrade	: If this is for upgrade
 p_calc_costrollup : If costrollup is needed with upgrade
***********************************************************************************/
PROCEDURE cto_cost_rollup
                         (
                                errbuf 	 		OUT NOCOPY    VARCHAR2,
                         	retcode 		OUT NOCOPY    VARCHAR2,
                         	p_org_id        	IN      NUMBER,
				p_dummy			IN	NUMBER,
				p_config_item_id     	IN      NUMBER,
				p_dummy2		IN	NUMBER,
				p_model_id      	IN      NUMBER,
				p_num_of_days   	IN      NUMBER,
				p_upgrade		IN	VARCHAR2,
				p_calc_costrollup	IN	VARCHAR2

                        )
IS

        l_request_id 		NUMBER;
        l_program_appl_id 	NUMBER;
        l_program_id 		NUMBER;

        l_stat_num  		NUMBER := 0;
	l_status		INTEGER;
        l_group_id		NUMBER;
        l_return_status 	VARCHAR2(100);
        l_msg_count		NUMBER;
        l_msg_data		VARCHAR2(100);
        loop_counter		NUMBER;
        l_config_item		NUMBER;
       	l_child_config_item	NUMBER;
       	l_org_id		NUMBER;
	l_child_org_id		NUMBER;
	l_config_orgs		VARCHAR2(30);
	l_child_config_orgs	VARCHAR2(30);
	l_plan_level		bom_explosion_temp.plan_level%TYPE;


	TYPE ConfigCurTyp is REF CURSOR ;

	config_cv ConfigCurTyp;

	cursor cfg_org_cur ( x_config_item number ) is
		select msi.organization_id
		from   mtl_system_items msi
		where  msi.inventory_item_id = x_config_item
		and    msi.inventory_item_status_code <>
				  ( select nvl(bom_delete_status_code,'-99') -- bug fix 5276658
					  from   bom_parameters bp
					  where  bp.organization_id =msi.organization_id);


	-- rkaza. 04/28/2005.
	-- adding organization_id join between bet and msi for perf improvement
	cursor child_config_cur(xgrp_id bom_explosion_temp.group_id%TYPE ) is
	       select distinct bet.component_item_id,msi_b.config_orgs,bet.plan_level
	       from bom_explosion_temp bet
                  , mtl_system_items msi
                  , mtl_system_items msi_b
	       where bet.group_id = xgrp_id
	       and bet.component_item_id = msi.inventory_item_id
               and bet.organization_id = msi.organization_id
               and msi_b.inventory_item_id = msi.base_item_id
               and msi_b.organization_id = msi.organization_id
	       ORDER BY plan_level asc;

        /*
        bugfix 3777922

	old definition cursor cfg_src_org_cur ( x_config_item number,
				 x_org_id number ) is
        */
	cursor cfg_src_org_cur ( x_config_item number) is
		select distinct organization_id
		from   bom_cto_src_orgs_gt
		where  config_item_id = x_config_item ;
		/* commented and    rcv_org_id = x_org_id; */  -- bugfix 3777922



        /*
        bugfix 3777922
        cursor called only for child configurations with CIB 1 and 2.
        This cursor accepts parent config item id and provides end manufacturing orgs.
        The sourcing chain for child configs should be traversed from the end manufacturing org
        of the parent config.
        */
        cursor cfg_mfg_org_cur ( x_config_item number) is
                select distinct organization_id
                from   bom_cto_src_orgs_gt
                where  config_item_id = x_config_item
                  and  rcv_org_id = organization_id  ;


	i 	number := 1;
	j 	number := 1;



    l_record_exists boolean := FALSE ;

    l_parent_org_id     number ;


    succ_item_arr      t_cfg_item ;
    fail_item_arr      t_cfg_item ;
    v_error_encountered boolean ;
    fail_count         number ;
    succ_count         number ;


   l_config_description   varchar2(50);
   l_org_code             varchar2(50);
   change_record          boolean ;

   sql_stmt varchar2(5000);  --Bugfix 5907413
   flag number := 0;  --Bugfix 5907413: TO check what parameters are passed to SQL

BEGIN


     WriteToLog('  Begin Cost Rollup process with Debug Level: '||gDebugLevel);
     WriteToLog('  Parameters passed..');
     WriteToLog('  Organization Id  : '||p_org_id);
     WriteToLog('  Config Item Id  : '||p_Config_item_Id);
     WriteToLog('  Base Model Id : '||p_Model_Id);
     WriteToLog('  Transacted number of days ago : '||p_num_of_days);
     WriteToLog('  Upgrade : '||p_upgrade);
     WriteToLog('  Perform Cost calculation : '||p_calc_costrollup);


     l_stat_num :=10;


     l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
     l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
     l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;


     WriteToLog('request_id      => '||l_request_id);
     WriteToLog('program_appl_id => '||l_program_appl_id);
     WriteToLog('program_id      => '||l_program_id);


     l_stat_num :=20;

	if p_upgrade= '2' then
                /* Bugfix 5907413: Commenting this SQL as it will no longer be used.
                   This SQL takes too long to populate config_cv so the CTO Calculate Cost
                   Rollup Program has performance issues. */
		/*OPEN config_cv FOR
		 	select    distinct msi.inventory_item_id,
				  nvl(msi_b.config_orgs,'1')
       		 	from      mtl_system_items msi,
       		 	          mtl_system_items msi_b
			where     msi.base_item_id is not null
                        and       msi.base_item_id = msi_b.inventory_item_id
                        and       msi.organization_id = msi_b.organization_id
   			and 	  msi.inventory_item_status_code <>
				  ( select bom_delete_status_code
					  from   bom_parameters bp
					  where  bp.organization_id =msi.organization_id
				  )
			and 	  (p_model_id is null or
				   msi.base_item_id = p_model_id)
       		 	and       (p_config_item_id is null or
				   msi.inventory_item_id = p_config_item_id)
       		 	and       (p_org_id is null or
				   msi.organization_id = p_org_id)
       		 	and       (p_num_of_days is null or
				   msi.creation_date > ( trunc(sysdate) - p_num_of_days ))
			ORDER BY  1; */
                --Bugfix 5907413: Adding Dynamic SQL.
                sql_stmt := 'select    distinct msi.inventory_item_id, ' ||
				  ' nvl(msi_b.config_orgs,''1'') '  ||
       		 	' from      mtl_system_items msi, ' ||
       		 	          ' mtl_system_items msi_b ' ||
			' where     msi.base_item_id is not null ' ||
                        ' and       msi.base_item_id = msi_b.inventory_item_id ' ||
                        ' and       msi.organization_id = msi_b.organization_id ' ||
   			' and 	  msi.inventory_item_status_code <> ' ||
				  ' ( select bom_delete_status_code ' ||
					  ' from   bom_parameters bp ' ||
					  ' where  bp.organization_id =msi.organization_id ' ||
				  ' )';

                IF p_model_id is not null THEN
                        sql_stmt := sql_stmt || ' and msi.base_item_id = :p_model_id ';
                        flag := flag + 1;
                END IF;

                IF p_config_item_id is not null THEN
                        sql_stmt := sql_stmt || ' and msi.inventory_item_id = :p_config_item_id ';
                        flag := flag + 2;
                END IF;

                IF p_org_id is not null THEN
                        sql_stmt := sql_stmt || ' and msi.organization_id = :p_org_id ';
                        flag := flag + 4;
                END IF;

                IF p_num_of_days is not null THEN
                        sql_stmt := sql_stmt || ' and msi.creation_date > ( trunc(sysdate) - :p_num_of_days ) ';
                        flag := flag + 8;
                END IF;

                sql_stmt := sql_stmt || ' ORDER BY  1 ';

                WriteToLog('SQL: ' || substr(sql_stmt,1, 1500));
                WriteToLog(substr(sql_stmt,1501,3000));
                WriteToLog(substr(sql_stmt,3001,4500));
                WriteToLog(substr(sql_stmt,4501,5000));
                WriteToLog('flag = '||flag );

                CASE flag

                        WHEN 0 then  --No (optional) parameter is passed
                                OPEN config_cv FOR sql_stmt;

                        WHEN 1 then  --Only Model_Id is passed
                                OPEN config_cv FOR sql_stmt USING p_model_id;

                        WHEN 2 then  --Only Config_item_id is passed
                                OPEN config_cv FOR sql_stmt USING p_config_item_id;

                        WHEN 3 then  --Model_id and config_item_id is passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_config_item_id;

                        WHEN 4 then  --Only organization_id is passed
                                OPEN config_cv FOR sql_stmt USING p_org_id;

                        WHEN 5 then  --model_id and organization_id are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_org_id;

                        WHEN 6 then  --config_item_id and organization_id are passed
                                OPEN config_cv FOR sql_stmt USING p_config_item_id, p_org_id;

                        WHEN 7 then  --model_id, config_item_id and org_id are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_config_item_id, p_org_id;

                        WHEN 8 then  --Only num_of_days is passed
                                OPEN config_cv FOR sql_stmt USING p_num_of_days;

                        WHEN 9 then  --model_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_num_of_days;

                        WHEN 10 then  --config_item_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_config_item_id, p_num_of_days;

                        WHEN 11 then  --model_id, config_item_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_config_item_id, p_num_of_days;

                        WHEN 12 then  --org_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_org_id, p_num_of_days;

                        WHEN 13 then  --model_id, org_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_org_id, p_num_of_days;

                        WHEN 14 then  --config_item_id, org_id and num_of_days are passed
                                OPEN config_cv FOR sql_stmt USING p_config_item_id, p_org_id, p_num_of_days;

                        WHEN 15 then  --model_id, config_item_id, org_id and num_of_days (All) are passed
                                OPEN config_cv FOR sql_stmt USING p_model_id, p_config_item_id, p_org_id, p_num_of_days;

                END CASE;
                --Bugfix 5907413: End of Dynamic SQL

	elsif p_upgrade= '1' then

	   if p_calc_costrollup = '2' then
	   	WriteToLog(' Not doing cost rollup since preform cost rollup parameter is NO', 2);
		return;
	   else
	   	 OPEN config_cv FOR
		 	select    distinct msi.inventory_item_id,
				  nvl( msi_b.config_orgs , '1')
       		 	from      bom_cto_order_lines_upg bcol_upg,
				  mtl_system_items msi,
				  mtl_system_items msi_b
			where     bcol_upg.line_id = bcol_upg.ato_line_id   /* bugfix 3777922 */
                        and       bcol_upg.config_item_id = msi.inventory_item_id
			and       msi.base_item_id is not null
                        and       msi.base_item_id = msi_b.inventory_item_id
                        and       msi.organization_id = msi_b.organization_id
                        and       bcol_upg.inventory_item_id = msi_b.inventory_item_id
   			and 	  msi.inventory_item_status_code <>
				  ( select bom_delete_status_code
					  from   bom_parameters bp
					  where  bp.organization_id = msi.organization_id
				  )
			ORDER BY  1;
	   end if;

	end if;



     << beginloop>>

     LOOP

     	      l_stat_num := 30;

	      SAVEPOINT CTOCCR;

     	      FETCH config_cv into l_config_item,l_config_orgs;
	      EXIT when config_cv%notfound;


	      WriteToLog('-------------------------------------------------------------------');
	      WriteToLog('Processing Config Id : '||l_config_item||' Attrib: '||l_config_orgs);
	      WriteToLog('-------------------------------------------------------------------');


              delete from bom_cto_src_orgs_gt ;


	      WriteToLog('deleted from bom_cto_src_orgs_gt : '|| sql%rowcount );
/*



	      -- check if l_config_item is in array already. Then we dont need to process this item again

	      if cfg_item_arr_cum.count > 0 then
	      -- check if config id exist
      	      -- if exist then goto beginloop;
	      	for l in cfg_item_arr_cum.FIRST .. cfg_item_arr_cum.LAST
		loop
		   if cfg_item_arr_cum(l).cfg_item_id = l_config_item then
			WriteToLog('Config Id : '||l_config_item||' already processed. ');
			goto beginloop;
		   end if;
		end loop;
	      end if;


*/



	      -- Ideally, we should get the sourcing org for the parent config and populate
	      -- the array. But, we will defer it because, we need to get the child configs for this parent.
	      -- If get_config_details errors out for any reason, we should not populate the parent config
	      -- details in the array.


	       --
	       -- We will first try to get the child configs for the parent configuration
	       --

	       WriteToLog ('calling cto_transfer_price_pk.get_config_details ');

	       cto_transfer_price_pk.get_config_details(
                                          p_item_id   	=> l_config_item
                                        , p_mode_id   	=> 3   -- 'BOTH'
					, p_configs_only => 'Y'
                                        , x_group_id   	=> l_group_id
                                        , x_msg_count  	=> l_msg_count
                                        , x_msg_data   	=> l_msg_data
                                        , x_return_status => l_return_status ) ;

		if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                        WriteToLog('get_config_details: ' || 'get_config_details returned unexp error.');
			ROLLBACK TO CTOCCR;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

        	elsif (l_return_status = FND_API.G_RET_STS_ERROR) then
                        retcode := 1;		-- Set this for conc request to end in WARNING
                        WriteToLog('get_config_details: ' || 'get_config_details returned expected error.');
			ROLLBACK TO CTOCCR;
			goto beginloop;

        	end if;

		WriteToLog('get_config_details: ' || 'Success in get_config_details ', 5);
		WriteToLog('get_config_details: ' || 'Group Id : '|| l_group_id, 5);




               -- Parent Sourcing should be populated before child sourcing as child sourcing starts
               -- from the organizations where parent sourcing ends.









		-- now, populate the parent config details in the array

	        -- if l_config_orgs = 3 ,
	        -- cost rollup in all org for parents
	        -- get all_orgs where l_config_item exist

		WriteToLog ('Going to populate details for parent config..');

	        if ( l_config_orgs = '3' )
			OR
		   ( l_config_orgs in ('1' , '2')   AND p_org_id is null )
                        OR
                   (p_upgrade = '1' )                                      -- bugfix 3777922
	        then

	       	    open cfg_org_cur (l_config_item);

	            LOOP
			WriteToLog ('Inside cfg_org_cur loop.. ' );

	                fetch cfg_org_cur into l_org_id;
		        EXIT WHEN cfg_org_cur%NOTFOUND;
		        -- populate cfg_item_arr with parent config details



                            l_record_exists := FALSE ;

                            if cfg_item_arr.count > 0 then
                               -- check if config id exist
                               -- if exist then goto beginloop;
                               for l in cfg_item_arr.FIRST .. cfg_item_arr.LAST
                               loop
                                  if cfg_item_arr(l).cfg_item_id = l_config_item AND
                                     cfg_item_arr(l).cfg_org_id = l_org_id then

                                      WriteToLog('Config Id : '||l_config_item|| ' org id ' || l_org_id
                                                 || ' already processed. ');

                                      l_record_exists := TRUE ;
                                      exit ;

                                  end if;
                               end loop;
                            end if;




                        if( l_record_exists = FALSE ) then
		        cfg_item_arr(i).cfg_item_id := l_config_item;
		        cfg_item_arr(i).cfg_org_id  := l_org_id;
                        WriteToLog('Index: ('||i||') -> Config item id: '||cfg_item_arr(i).cfg_item_id||
			   ' Org Id: '||cfg_item_arr(i).cfg_org_id , 5);

		        i := i + 1;


                        end if;


	            END LOOP;
	            close cfg_org_cur;

	        elsif ( l_config_orgs in ('1' , '2')   AND p_org_id is not null AND p_upgrade = '2') then -- bugfix 3777922

	       	    --
	       	    -- get sourcing orgs for p_org_id and l_config_item  /* sajani */
	       	    -- load cfg_item_arr with p_org_id +  sourcing orgs for l_config_item
	       	    --

	       	    --
	       	    -- following proc populates temp table bcso_gt
	       	    -- with config item id and relevant sourcing org
	       	    --

		    WriteToLog ('Calling get_sourcing org..');

	            get_sourcing_org (p_config_item_id  => l_config_item ,
				 p_organization_id => p_org_id,
				 p_return_status   => l_return_status );

		    WriteToLog ('** l_return_status = '|| l_return_status );

	            if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                        WriteToLog('get_sourcing_org: ' || 'raised Unexpected error.');
			ROLLBACK TO CTOCCR;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

	       	    elsif (l_return_status = FND_API.G_RET_STS_ERROR) then
                        retcode := 1;		-- Set this for conc request to end in WARNING
                        WriteToLog('get_sourcing_org: ' || 'raised Expected error.');
			ROLLBACK TO CTOCCR;
			goto beginloop;
		    else
                        WriteToLog('get_sourcing_org: SUCCESSFULLL !!!! ');


	       	    end if;


                        WriteToLog('get_sourcing_org: Adding dummy record for ship org. ');

                             insert into bom_cto_src_orgs_gt
                                (
                                config_item_id,
                                organization_id,
                                rcv_org_id,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                program_application_id,
                                program_id,
                                program_update_date
                                )
                             select
                                l_config_item,
                                p_org_id,
                                null ,    /* this is intentionally null to indicate  origin 100%transfer from org */
                                sysdate,        -- creation_date
                                gUserId,        -- created_by
                                sysdate,        -- last_update_date
                                gUserId,        -- last_updated_by
                                gLoginId,       -- last_update_login
                                null,           -- program_application_id,??
                                null,           -- program_id,??
                                sysdate         -- program_update_date
                             from dual
                             where NOT EXISTS
                                (select NULL
                                  from bom_cto_src_orgs_gt
                                  where rcv_org_id =  p_org_id
                                  and organization_id = p_org_id
                                  and config_item_id = l_config_item );


		    --
		    -- query the bom_cto_src_orgs_gt table and get all sourcing orgs for parent config.
		    --
		    open cfg_src_org_cur (l_config_item);     -- bugfix 3777622
	            LOOP
			WriteToLog ('inside cfg_src_org_cur loop for parent.');

	                fetch cfg_src_org_cur into l_org_id;
		        EXIT WHEN cfg_src_org_cur%NOTFOUND;

		        --
		        -- populate cfg_item_arr with parent config and its sourcing orgs
		        --



                            l_record_exists := FALSE ;

                            if cfg_item_arr.count > 0 then
                               -- check if config id exist
                               -- if exist then goto beginloop;
                               for l in cfg_item_arr.FIRST .. cfg_item_arr.LAST
                               loop
                                  if cfg_item_arr(l).cfg_item_id = l_config_item AND
                                     cfg_item_arr(l).cfg_org_id = l_org_id then

                                      WriteToLog('Config Id : '||l_config_item|| ' org id ' || l_org_id
                                                 || ' already processed. ');

                                      l_record_exists := TRUE ;
                                      exit ;

                                  end if;
                               end loop;
                            end if;


                        if( l_record_exists = FALSE ) then
		        cfg_item_arr(i).cfg_item_id := l_config_item;
		  	cfg_item_arr(i).cfg_org_id  := l_org_id;
                  	WriteToLog('Index: ('||i||') -> Config item id: '||cfg_item_arr(i).cfg_item_id||
				' Org Id: '||cfg_item_arr(i).cfg_org_id);

		  	i := i + 1;

                        end if;


	            END LOOP;
	            close cfg_src_org_cur;

		end if; /* l_config_orgs check */

	       --
	       -- At this point structure is loaded with parent configs, child configs and relevant orgs
	       --














	        --
	        -- Now, get all child for this grp id
	        --

	        l_stat_num := 31;

	        open child_config_cur(l_group_id) ;
	        loop
		   WriteToLog ('inside child_config_cur loop..' );
	           fetch child_config_cur into l_child_config_item, l_child_config_orgs, l_plan_level;

	           exit when child_config_cur%NOTFOUND;

	           WriteToLog( ' fetched ' ||  l_child_config_item || ' Orgs ' || l_child_config_orgs
                                           ||  ' p_upgrade ' || p_upgrade , 5 ) ;

		   if ( l_child_config_orgs = '3' )
			OR
		      ( l_child_config_orgs in ('1' , '2')   AND p_org_id is null )
                        OR
                       (p_upgrade = '1')                                                -- bugfix 3777922
	           then
			l_stat_num := 32;
			   WriteToLog ('inside child condition 1 .. ');

	         	open cfg_org_cur ( l_child_config_item);

	         	LOOP

			   WriteToLog ('inside cfg_org_cur loop.. ');
	           	   fetch cfg_org_cur into l_child_org_id;

		   	   EXIT WHEN cfg_org_cur%NOTFOUND;




                            -- check if l_config_item is in array already. Then we dont need to process this item again

                            l_record_exists := FALSE ;

                            if cfg_item_arr.count > 0 then
                               -- check if config id exist
                               -- if exist then goto beginloop;
                               for l in cfg_item_arr.FIRST .. cfg_item_arr.LAST
                               loop
                                  if cfg_item_arr(l).cfg_item_id = l_child_config_item AND
                                     cfg_item_arr(l).cfg_org_id = l_child_org_id then

                                      WriteToLog('Config Id : '|| l_child_config_item|| ' org id ' || l_child_org_id
                                                 || ' already processed. ');

                                      l_record_exists := TRUE ;
                                      exit ;

                                  end if;
                               end loop;
                            end if;




                           if( l_record_exists = FALSE ) then
		  	   --
		  	   -- populate cfg_item_arr with child config details
		  	   --

		           cfg_item_arr(i).cfg_item_id 		:= l_child_config_item;
		           cfg_item_arr(i).cfg_org_id  		:= l_child_org_id;
                           WriteToLog('Index: ('||i||') -> Child Config item id: '||cfg_item_arr(i).cfg_item_id||
				      ' Org Id: '||cfg_item_arr(i).cfg_org_id, 5);

		           i := i + 1;

                           end if;


	         	END LOOP;

	                close cfg_org_cur;

	     	   elsif ( l_child_config_orgs in ('1' , '2')   AND p_org_id is not null AND p_upgrade = '2' ) then  -- bugfix 3777922

			   WriteToLog ('inside child condition 2 .. ');
	        	-- get sourcing orgs for p_org_id and child_config_orgs
	       		-- load cfg_item_arr with p_org_id +  sourcing orgs for child_config_orgs

	       		-- following proc populates temp table bcso_gt
	       		-- with config item id and relevant sourcing org



		    open cfg_mfg_org_cur (l_config_item);     -- bugfix 3777622
	            LOOP
			WriteToLog ('inside cfg_src_org_cur loop for parent.');

	                fetch cfg_mfg_org_cur into l_parent_org_id;
		        EXIT WHEN cfg_mfg_org_cur%NOTFOUND;


			WriteToLog ('calling get_sourcing_org..' || l_child_config_item
                                 || ' org ' || l_parent_org_id);
	       		get_sourcing_org (p_config_item_id  => l_child_config_item ,
				 p_organization_id => l_parent_org_id ,
				 p_return_status   => l_return_status );

	       		if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                        	WriteToLog('get_sourcing_org: ' || 'raised Unexpected error.');
				ROLLBACK TO CTOCCR;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;

	       		elsif (l_return_status = FND_API.G_RET_STS_ERROR) then
                                retcode := 1;		-- Set this for conc request to end in WARNING
                        	WriteToLog('get_sourcing_org: ' || 'raised Expected error.');
				ROLLBACK TO CTOCCR;
				goto beginloop;

	       		end if;


                        WriteToLog('get_sourcing_org: Adding dummy record for ship org. ');

                             insert into bom_cto_src_orgs_gt
                                (
                                config_item_id,
                                organization_id,
                                rcv_org_id,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                program_application_id,
                                program_id,
                                program_update_date
                                )
                             select
                                l_child_config_item,
                                l_parent_org_id,                             -- bugfix 3777922
                                null ,                             -- bugfix 3777922  /* this is intentionally null for origin 100% transfer from org*/
                                sysdate,        -- creation_date
                                gUserId,        -- created_by
                                sysdate,        -- last_update_date
                                gUserId,        -- last_updated_by
                                gLoginId,       -- last_update_login
                                null,           -- program_application_id,??
                                null,           -- program_id,??
                                sysdate         -- program_update_date
                             from dual
                             where NOT EXISTS
                                (select NULL
                                  from bom_cto_src_orgs_gt
                                  where rcv_org_id =  l_parent_org_id -- bugfix 3777922
                                  and organization_id = l_parent_org_id     -- bugfix 3777922
                                  and config_item_id = l_child_config_item ) ; -- bugfix 3941383



                       end loop ;


                       close cfg_mfg_org_cur ;




			--
			-- query the bom_cto_src_orgs_gt table and get all sourcing orgs for child config.
			--
		        /* old call open cfg_src_org_cur (l_child_config_item,p_org_id); */


		        open cfg_src_org_cur (l_child_config_item);       -- bugfix 3777922
	                LOOP
			    WriteToLog ('inside cfg_src_org_cur loop for child');

	          	    fetch cfg_src_org_cur into l_org_id;
		  	    EXIT WHEN cfg_src_org_cur%NOTFOUND;

			    -- populate cfg_item_arr with parent config sourcing


                            l_record_exists := FALSE ;

                            if cfg_item_arr.count > 0 then
                               -- check if config id exist
                               -- if exist then goto beginloop;
                               for l in cfg_item_arr.FIRST .. cfg_item_arr.LAST
                               loop
                                  if cfg_item_arr(l).cfg_item_id = l_child_config_item AND
                                     cfg_item_arr(l).cfg_org_id = l_org_id then

                                      WriteToLog('Config Id : '||l_child_config_item|| ' org id ' || l_org_id
                                                 || ' already processed. ');

                                      l_record_exists := TRUE ;
                                      exit ;

                                  end if;
                               end loop;
                            end if;









                            if( l_record_exists = FALSE ) then
		  	    cfg_item_arr(i).cfg_item_id := l_child_config_item;
		            cfg_item_arr(i).cfg_org_id  := l_org_id;
                            WriteToLog('Index: ('||i||') -> Child Config item id: '||cfg_item_arr(i).cfg_item_id||
					' Org Id: '||cfg_item_arr(i).cfg_org_id, 5);

		  	    i := i + 1;


                            end if;


	        	END LOOP;

	       	 	close cfg_src_org_cur;

	           end if; /* end of child_config_orgs check */







	        end loop; /* end of child_config_cur cursor loop */

	        close child_config_cur ;


                WriteToLog(' Closed child_config_cur ' ) ;



     if( cfg_item_arr.count >= 100 ) then                /* Start bugfix 3784283 */


     --
     -- Passing array to the cost rollup API
     --



        SavePoint S1;

        WriteToLog('Calling CTO_CONFIG_COST_PK.Cost_Roll_Up_ML.. ', 5);
        WriteToLog('Calling CTO_CONFIG_COST_PK.Cost_Roll_Up_ML.. ' || cfg_item_arr.count , 5);

        WriteToLog ('==============================================');
	WriteToLog (' Collected Data for '|| config_cv%ROWCOUNT || ' parent configs or processing .');
        WriteToLog ('==============================================');

        l_status := CTO_CONFIG_COST_PK.Cost_Roll_Up_ML(
                        p_cfg_itm_tbl       => cfg_item_arr,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                        );

	l_stat_num := 231;

        if (l_status = 0) then

           WriteToLog('CTO_CONFIG_COST_PK.Cost_Roll_Up_ML returned error. '||l_msg_data);


            WriteToLog('following batch of records could not be processed successfully .. ', 5);

            for curr_count in 1..cfg_item_arr.count
            loop
                fail_count := fail_item_arr.count + 1;
                fail_item_arr(fail_count).cfg_item_id := cfg_item_arr(curr_count).cfg_item_id ;
                fail_item_arr(fail_count).cfg_org_id := cfg_item_arr(curr_count).cfg_org_id ;

               WriteToLog('Config Id: ' || cfg_item_arr(curr_count).cfg_item_id ||
                         ' Org Id: ' || cfg_item_arr(curr_count).cfg_org_id , 5);
            end loop;

            WriteToLog('Total records that could not be processed successfully .. ' || cfg_item_arr.count , 5);


            Rollback TO S1 ;

            v_error_encountered := TRUE ;


        else

            for curr_count in 1..cfg_item_arr.count
            loop
                succ_count := succ_item_arr.count + 1 ;
                succ_item_arr(succ_count).cfg_item_id := cfg_item_arr(curr_count).cfg_item_id ;
                succ_item_arr(succ_count).cfg_org_id := cfg_item_arr(curr_count).cfg_org_id ;
            end loop;


        end if;


        cfg_item_arr.delete ;

        i := 1 ; /* fix for bug 3975083 */

        end if ; /* cfg_item_arr.count >= 100 */  /* end bugfix 3784283 */






     END LOOP; /* parent config loop */   /* bugfix 3777922 */




     if config_cv%ROWCOUNT = 0 then
	WriteToLog ('Nothing to process.');
	return;
     else
        WriteToLog ('==============================================');
	WriteToLog ('Total Processed '|| config_cv%ROWCOUNT || ' parent configs.');
        WriteToLog ('==============================================');
     end if;



	l_stat_num := 331;


     /* Process remaining records < 100 */
     if( cfg_item_arr.count > 0 ) then   -- bugfix 3784283


     --
     -- Passing array to the cost rollup API
     --



        SavePoint S1;

        WriteToLog('Calling CTO_CONFIG_COST_PK.Cost_Roll_Up_ML.. ', 5);
        WriteToLog('Calling CTO_CONFIG_COST_PK.Cost_Roll_Up_ML.. ' || cfg_item_arr.count , 5);

        WriteToLog ('==============================================');
	WriteToLog (' Collected Data for '|| config_cv%ROWCOUNT || ' parent configs or processing .');
        WriteToLog ('==============================================');

        l_status := CTO_CONFIG_COST_PK.Cost_Roll_Up_ML(
                        p_cfg_itm_tbl       => cfg_item_arr,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data
                        );

        if (l_status = 0) then

           WriteToLog('CTO_CONFIG_COST_PK.Cost_Roll_Up_ML returned error. '||l_msg_data);


            WriteToLog ('====================================================================', 1);
            WriteToLog('following batch of records could not be processed successfully .. ', 1);
            WriteToLog ('====================================================================', 1);

            for curr_count in 1..cfg_item_arr.count
            loop
                fail_count := fail_item_arr.count + 1 ;
                fail_item_arr(fail_count).cfg_item_id := cfg_item_arr(curr_count).cfg_item_id ;
                fail_item_arr(fail_count).cfg_org_id := cfg_item_arr(curr_count).cfg_org_id ;

               WriteToLog('Config Id: ' || cfg_item_arr(curr_count).cfg_item_id ||
                         ' Org Id: ' || cfg_item_arr(curr_count).cfg_org_id , 1);
            end loop;

            WriteToLog ('====================================================================', 1);
            WriteToLog('Total records for this batch that could not be processed successfully .. ' || cfg_item_arr.count , 1);
            WriteToLog ('====================================================================', 1);


            Rollback TO S1 ;

            v_error_encountered := TRUE ;


        else

            for curr_count in 1..cfg_item_arr.count
            loop
                succ_count := succ_item_arr.count + 1 ;
                succ_item_arr(succ_count).cfg_item_id := cfg_item_arr(curr_count).cfg_item_id ;
                succ_item_arr(succ_count).cfg_org_id := cfg_item_arr(curr_count).cfg_org_id ;
            end loop;


        end if;


       end if ; /* cfg_item_arr.count > 0 */  -- bugfix 3784283










	l_stat_num := 431;



        WriteToLog ('====================================================================', 1);
        WriteToLog('following records have been processed successfully .. ', 1);
        WriteToLog ('====================================================================', 1);
        for curr_count in 1..succ_item_arr.count
        loop

	    l_stat_num := 441;

               l_config_description := 'N/A' ;
               l_org_code           := 'N/A' ;

	    l_stat_num := 451;

            begin
                SELECT substrb(kfv.concatenated_segments,1,35),
                                 mp.organization_code
                      INTO   l_config_description, l_org_code
                      FROM   mtl_system_items_kfv kfv, mtl_parameters mp
                      WHERE  kfv.inventory_item_id = succ_item_arr(curr_count).cfg_item_id
                      AND    kfv.organization_id = succ_item_arr(curr_count).cfg_org_id
                      AND    kfv.organization_id = mp.organization_id;

             exception
             when others then

                  null ;
             end ;


	    l_stat_num := 461;
               WriteToLog('Config Id: ' || succ_item_arr(curr_count).cfg_item_id ||
                          ' Org Id: ' || succ_item_arr(curr_count).cfg_org_id ||
                          ' Item Name ' || l_config_description ||
                          ' Org Code ' || l_org_code
                          , 1);

        end loop;
        WriteToLog ('====================================================================', 1);
        WriteToLog('Total records processed successfully .. ' || succ_item_arr.count , 1);
        WriteToLog ('====================================================================', 1);

        commit ;


        if( v_error_encountered ) then
           WriteToLog ('====================================================================', 1);
           WriteToLog('following records have not been processed successfully .. ', 1);
           WriteToLog ('====================================================================', 1);
           for curr_count in 1..fail_item_arr.count
           loop


               l_config_description := 'N/A' ;
               l_org_code           := 'N/A' ;


               begin
                    SELECT substrb(kfv.concatenated_segments,1,35),
                                 mp.organization_code
                      INTO   l_config_description, l_org_code
                      FROM   mtl_system_items_kfv kfv, mtl_parameters mp
                      WHERE  kfv.inventory_item_id = fail_item_arr(curr_count).cfg_item_id
                      AND    kfv.organization_id = fail_item_arr(curr_count).cfg_org_id
                      AND    kfv.organization_id = mp.organization_id;

               exception
               when others then
                           null ;
               end ;


               WriteToLog('Config Id: ' || fail_item_arr(curr_count).cfg_item_id ||
                          ' Org Id: ' || fail_item_arr(curr_count).cfg_org_id ||
                          ' Item Name ' || l_config_description ||
                          ' Org Code ' || l_org_code
                          , 1);

           end loop;
           WriteToLog ('====================================================================', 1);
           WriteToLog('Total records not been  processed successfully .. ' || fail_item_arr.count , 1);
           WriteToLog ('====================================================================', 1);
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;





        if config_cv%ISOPEN then
           CLOSE config_cv;
        end if;

EXCEPTION
	when FND_API.G_EXC_ERROR then
               	WriteToLog('cto_cost_rollup: ' || 'EXPECTED ERROR:' || to_char(l_stat_num),1);
                retcode := 1;--completes with warning status -- Bug Fix 5527848
		l_return_status := FND_API.G_RET_STS_ERROR;


	when FND_API.G_EXC_UNEXPECTED_ERROR then
        	WriteToLog('cto_cost_rollup: ' || 'UNEXPECTED ERROR:' || to_char(l_stat_num),1);
                retcode := 1;--completes with warning status  --Bug Fix 5527848
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


        when OTHERS then
         	WriteToLog('OTHERS excpn in cto_cost_rollup: '||to_char(l_stat_num)||'::'||sqlerrm);
                errbuf := 'Completed with error';
                retcode := 2;--completes with error status
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END cto_cost_rollup;

PROCEDURE get_sourcing_org (
	p_config_item_id     number
      , p_organization_id    number
      , p_return_status	     OUT NOCOPY varchar2 )
is

    v_t_sourcing_info   CTO_MSUTIL_PUB.sourcing_info;
    v_buy_traversed     boolean := false ;
    v_source_type       mrp_sources_v.source_type%type ;
    l_make_buy_code     mtl_system_items.planning_make_buy_code%type ;

    l_curr_src_org      mrp_sources_v.source_organization_id%type  ;
    l_source_type       mrp_sources_v.source_type%type ;
    l_curr_assg_type    mrp_sources_v.assignment_type%type ;
    l_curr_rank         mrp_sources_v.rank%type ;
    v_sourcing_rule_exists varchar2(10) ;


    x_exp_error_code    NUMBER ;
    x_return_status     varchar2(100);

    lStmtNum            number ;
    x_msg_data          varchar2(250) ;
    x_msg_count         number ;
    v_bcso_count        number ;
    l_circular_src	varchar2(1);
BEGIN

                WriteToLog( 'Entered get_sourcing_org to find sourcing chain with item id: ' || p_config_item_id ||
			    ' and orgn_id: ' || p_organization_id) ;

                lStmtNum := 0 ;

		p_return_status := FND_API.G_RET_STS_SUCCESS;

                v_buy_traversed := FALSE ;

                WriteToLog( 'calling query sourcing org ') ;

                CTO_MSUTIL_PUB.query_sourcing_org_ms(
				p_inventory_item_id	=> p_config_item_id
                               ,p_organization_id	=> p_organization_id
                               ,p_sourcing_rule_exists	=> v_sourcing_rule_exists
                               ,p_source_type		=> v_source_type
                               ,p_t_sourcing_info	=> v_t_sourcing_info
                               ,x_exp_error_code	=> x_exp_error_code
                               ,x_return_status		=> x_return_status );

		IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN

		   WriteToLog(' Error in query_sourcing_org_ms.. ');
		   raise FND_API.G_EXC_UNEXPECTED_ERROR;

                END IF;


                WriteToLog( 'output query sourcing org rule '  || v_t_sourcing_info.sourcing_rule_id.count) ;
                WriteToLog( 'output query sourcing org src org '  || v_t_sourcing_info.source_organization_id.count) ;
                WriteToLog( 'output query sourcing org src type'  || v_t_sourcing_info.source_type.count) ;



                if( v_t_sourcing_info.source_type.count > 0 ) then

                    FOR i in 1..v_t_sourcing_info.source_type.count
                    LOOP

                        WriteToLog( 'output query sourcing org type '  || v_t_sourcing_info.source_type(i)) ;

                        if(  v_t_sourcing_info.source_type(i) in ( 1, 2 )  ) then
           			/* 1 = Transfer From, 2 = Make At */

                             WriteToLog( ' came into type 1,2  ') ;

                             begin
                               lStmtNum := 1 ;
		               l_curr_src_org := v_t_sourcing_info.source_organization_id(i) ;

                               lStmtNum := 2 ;
		               l_source_type  := v_t_sourcing_info.source_type(i) ;

                               lStmtNum := 3 ;
			       l_curr_assg_type := v_t_sourcing_info.assignment_type(i) ;

                               lStmtNum := 4 ;
			       l_curr_rank := v_t_sourcing_info.rank(i) ;

                             exception

                               when others then

                             	WriteToLog( ' errored into type 1,2  at '  || lStmtNum  || ' err ' || SQLERRM ) ;
			     	raise FND_API.G_EXC_UNEXPECTED_ERROR;

                             end ;


                             if( l_source_type = 1) then
			     WriteToLog ( ' Check Circular Sourcing ..');

			     lStmtNum := 8;

			     begin

			     select distinct 'Y'
			     into l_circular_src
			     from bom_cto_src_orgs_gt
			     where config_item_id =  p_config_item_id
			     and rcv_org_id = l_curr_src_org;

			     exception
			       when no_data_found then
				  l_circular_src := 'N';
			     end;

        		     lStmtNum := 9;
                             IF l_circular_src = 'Y' THEN
 			     	WriteToLog( ' Circular Sourcing detected ..');
                        	raise FND_API.G_EXC_ERROR;
                             END IF;


                             end if;


                             WriteToLog( 'going to insert bcso for type 1,2  ') ;

                             lStmtNum := 10 ;

			     begin


		             insert into bom_cto_src_orgs_gt
				(
				config_item_id,
				organization_id,
				rcv_org_id,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				program_application_id,
				program_id,
				program_update_date
				)
		             select
				p_config_item_id,
				l_curr_src_org,
				p_organization_id,
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
			     from dual
			     where NOT EXISTS
                                (select NULL
                                  from bom_cto_src_orgs_gt
                                  where rcv_org_id = p_organization_id
                                  and organization_id = l_curr_src_org
                                  and config_item_id = p_config_item_id );

			     exception

			     	when others then

				WriteToLog( ' errored inserting at '  || lStmtNum  || ' err ' || SQLERRM ) ;
			     	raise FND_API.G_EXC_UNEXPECTED_ERROR;

                             end ;


                             WriteToLog( 'inserted' || sql%rowcount || 'records in bcso for type 1,2.') ;
                             WriteToLog( 'inserted bcso for type 1,2  rcv_org =  '  || p_organization_id || ', src_org = ' || l_curr_src_org) ;


                        elsif( v_t_sourcing_info.source_type(i) = 3 and NOT v_buy_traversed ) then
           			/* 3 = Buy From */

                             v_buy_traversed := TRUE ;

                             WriteToLog( ' came into type 3 '  , 1 ) ;

                             begin
                                lStmtNum := 21 ;
		                l_curr_src_org := nvl( v_t_sourcing_info.source_organization_id(i) , p_organization_id )  ;
                                lStmtNum := 22 ;
		                l_source_type  := v_t_sourcing_info.source_type(i) ;

                                lStmtNum := 23 ;
			        l_curr_assg_type := v_t_sourcing_info.assignment_type(i) ;

                                lStmtNum := 24 ;
			        l_curr_rank := v_t_sourcing_info.rank(i) ;

                             exception

                             when others then

                                WriteToLog( ' errored into type 3  at '  || lStmtNum  || ' err ' || SQLERRM) ;
			     	raise FND_API.G_EXC_UNEXPECTED_ERROR;

                             end ;


                             lStmtNum := 30 ;


			     begin


		             insert into bom_cto_src_orgs_gt
				(
				config_item_id,
				organization_id,
				rcv_org_id,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				program_application_id,
				program_id,
				program_update_date
				)
		             select
				p_config_item_id,
				l_curr_src_org,
				p_organization_id,
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
			     from dual
			     where NOT EXISTS
                                (select NULL
                                  from bom_cto_src_orgs_gt
                                  where rcv_org_id = p_organization_id
                                  and organization_id = l_curr_src_org
                                  and config_item_id = p_config_item_id );

			     exception

			     	when others then

				WriteToLog( ' errored inserting at '  || lStmtNum  || ' err ' || SQLERRM ) ;
			     	raise FND_API.G_EXC_UNEXPECTED_ERROR;

                             end ;



                             WriteToLog( 'inserted' || sql%rowcount || 'records in bcso for type 3.') ;
                             WriteToLog( 'inserted bcso for type 3  rcv_org =  '  || p_organization_id || ', src_org = ' || l_curr_src_org) ;


                        end if;


                        lStmtNum := 40 ;
                        if( v_t_sourcing_info.source_type(i) = 1 ) then

                            WriteToLog( 'calling process sourcing chain recursive  ') ;

                            lStmtNum := 50 ;

                            get_sourcing_org( p_config_item_id
                            		     , v_t_sourcing_info.source_organization_id(i)
					     , x_return_status
					    );
	       		    if (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                        	WriteToLog('get_sourcing_org: ' || 'raised Unexpected error.');
				raise FND_API.G_EXC_UNEXPECTED_ERROR;

	       		    elsif (x_return_status = FND_API.G_RET_STS_ERROR) then
                        	WriteToLog('get_sourcing_org: ' || 'raised Expected error.');
				raise FND_API.G_EXC_ERROR;

	       		    end if;

                        end if;


                    END LOOP ;


                else

                     -- When there is no sourcing rule defined we need to check for the make_buy_type of the
                     -- item to determine the buy model


		        WriteToLog('get_sourcing_org : ' || 'No sourcing rule defined..');

                        lStmtNum := 57;

                        -- When the item is not defined in the sourcing org it needs to be
                        -- treated as INVALID sourcing

                        BEGIN

                           SELECT planning_make_buy_code
                           INTO   l_make_buy_code
                           FROM   MTL_SYSTEM_ITEMS
                           WHERE  inventory_item_id = p_config_item_id
                           AND    organization_id   = p_organization_id ;

                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN

                           	WriteToLog('get_sourcing_org: ' || 'ERROR::The item is not defined in the sourcing org');
                           -- The following message handling is modified by Renga Kannan
                           -- We need to give the add for once to FND function and other
                           -- to OE, in both cases we need to set the message again
                           -- This is because if we not set the token once again the
                           -- second add will not get the message.

                                cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
                                raise FND_API.G_EXC_ERROR;

                        END;

		        l_curr_src_org := p_organization_id ;

                        if( l_make_buy_code  = 2) then

                            l_source_type := 3 ;
                        else
                            l_source_type := 2 ;
                        end if;

                        l_curr_rank  := null ;


			begin

		           insert into bom_cto_src_orgs_gt
				(
				config_item_id,
				rcv_org_id,
				organization_id,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				program_application_id,
				program_id,
				program_update_date
				)
		          select p_config_item_id ,
				p_organization_id, -- will work for end of chain source or no source
				p_organization_id,
				sysdate,	-- creation_date
				gUserId,	-- created_by
				sysdate,	-- last_update_date
				gUserId,	-- last_updated_by
				gLoginId,	-- last_update_login
				null, 		-- program_application_id,??
				null, 		-- program_id,??
				sysdate		-- program_update_date
			   from dual
			     where NOT EXISTS
                                (select NULL
                                  from bom_cto_src_orgs_gt
                                  where rcv_org_id = p_organization_id
                                  and organization_id =p_organization_id
                                  and config_item_id = p_config_item_id );

			exception

			     	when others then

				WriteToLog( ' errored inserting at '  || lStmtNum  || ' err ' || SQLERRM ) ;
			     	raise FND_API.G_EXC_UNEXPECTED_ERROR;

                	end ;


                        WriteToLog( 'inserted bcso for end of chain  '  || SQL%rowcount) ;

                end if;

EXCEPTION
	when FND_API.G_EXC_ERROR then
               	WriteToLog('get_sourcing_org: ' || 'EXPECTED ERROR:' || to_char(lStmtNum),1);
		p_return_status := FND_API.G_RET_STS_ERROR;


	when FND_API.G_EXC_UNEXPECTED_ERROR then
        	WriteToLog('get_sourcing_org: ' || 'UNEXPECTED ERROR:' || to_char(lStmtNum),1);
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


        when OTHERS then
         	WriteToLog('OTHERS excpn in get_sourcing_org: '||to_char(lStmtNum)||'::'||sqlerrm);
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END get_sourcing_org;


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0) is
begin
    if gDebugLevel >= p_level then
	/* fnd_file.put_line (fnd_file.log, p_message); */
	oe_debug_pub.add (p_message);
    end if;
end WriteToLog;

END CTO_COST_ROLLUP_CONC_PK;


/
