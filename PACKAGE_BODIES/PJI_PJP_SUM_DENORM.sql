--------------------------------------------------------
--  DDL for Package Body PJI_PJP_SUM_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_SUM_DENORM" as
  /* $Header: PJISP03B.pls 120.11.12010000.3 2010/01/13 10:06:12 rmandali ship $ */

-- -----------------------------------------------------------------------

g_pa_debug_mode			varchar2(1);

g_msg_level_data_bug		number;
g_msg_level_data_corruption 	number;
g_msg_level_proc_call		number;
g_msg_level_high_detail		number;
g_msg_level_low_detail		number;


-- -----------------------------------------------------
-- procedure POPULATE_XBS_DENORM
-- -----------------------------------------------------

procedure POPULATE_XBS_DENORM(
	p_worker_id		in	number,
	p_denorm_type    	in 	varchar2,
	p_wbs_version_id 	in 	number,
	p_prg_group1     	in 	number,
	p_prg_group2     	in 	number
) is

-- p_denorm_type in ('WBS', 'PRG', 'ALL')
-- p_wbs_version_id = single project structure version
-- p_prg_group1   These parameters will be used if online program
-- p_prg_group2   change processing is required in the future.


-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API populates data for xbs data.  This API calls the
--	following procedures:
--
--		prg_denorm
--		wbs_denorm
--		merge_xbs_denorm
--
-- -----------------------------------------------------------------------


-- -----------------------------------------------------
-- Declare statements --

l_process 		varchar2(30);
l_extraction_type 	varchar2(30);
l_fpm_upgrade 		varchar2(30);
l_denorm_type 		varchar2(30);
l_prg_group_id 		number;

-- -----------------------------------------------------

begin

l_denorm_type := nvl(p_denorm_type, 'ALL');

if 	g_pa_debug_mode = 'Y'
then
	Pji_Utils.WRITE2LOG(
		'PJI_PJP '
			|| '- Begin: populate_xbs_denorm '
			|| '- p_worker_id = '
			|| p_worker_id
			|| ' l_denorm_type = '
			|| l_denorm_type
			|| ' p_wbs_version_id = '
			|| p_wbs_version_id,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- Variable assignments --

l_process := 	PJI_PJP_SUM_MAIN.g_process
		|| to_char(p_worker_id);

l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(
			l_process,
			'EXTRACTION_TYPE'
			);

l_fpm_upgrade := PJI_UTILS.GET_PARAMETER(
			'PJI_FPM_UPGRADE'
			);

-- ----------------------------------------

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP -   Variables -'
			|| ' l_process = '
			|| l_process
			|| ' l_extraction_type = '
			|| l_extraction_type,
		null,
		g_msg_level_high_detail
		);
end if;

-- ----------------------------------------

-- -----------------------------------------------------
-- WBS Online Mode --

if	l_denorm_type = 'WBS'
then

	-- ----------------------------------------------
	-- cleanup interim tables
	cleanup_xbs_denorm(
		p_worker_id,
		'ONLINE'
		);

	-- ----------------------------------------------

	-- delete WBS/XBS slices for specific struct_version_id		-- ###delete###

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   Delete specific WBS/XBS slices -'
				|| ' p_wbs_version_id = '
				|| p_wbs_version_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	-- ###perf_bug### Bug 3828726
	delete /*+ index(xbs, PA_XBS_DENORM_N2) */
  	from	pa_xbs_denorm xbs
  	where	struct_type in ('WBS', 'XBS')
	and	struct_version_id = p_wbs_version_id;

	-- delete PRG slices for specific prg_group and p_wbs_version_id
	begin
		-- get prg_group information from versions table
		select
		distinct
			prg_group
		into 	l_prg_group_id
		from 	pa_proj_element_versions
		where 	element_version_id = p_wbs_version_id;

	exception
		when no_data_found
		then
			null;
	end;

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   Deleted specific PRG slices -'
				|| ' p_wbs_version_id = '
				|| p_wbs_version_id
				|| ' prg_group_id = '
				|| l_prg_group_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	l_prg_group_id := null;

	if 	l_prg_group_id is not null
	then

		-- ###performance###
		delete
	  	from	pa_xbs_denorm
  		where	struct_type = 'PRG'
		and 	prg_group = l_prg_group_id;

		-- repopulate PRG slices PA_XBS_DENORM for a prg group
		prg_denorm_online(
			p_worker_id,
			'ONLINE',
			l_prg_group_id,
			null
			);

	else

		-- ###perf_bug### Bug 3828726
		delete /*+ index(prg, PA_XBS_DENORM_N1) */
	  	from	pa_xbs_denorm prg
  		where	struct_type = 'PRG'
		and 	struct_version_id is null
		and 	sup_id = p_wbs_version_id
		and 	sub_id = p_wbs_version_id;

		-- repopulate PRG slices PA_XBS_DENORM for a wbs_version_id
		prg_denorm_online(
			p_worker_id,
			'ONLINE',
			null,
			p_wbs_version_id
			);
	end if;

	-- ----------------------------------------------
	-- repopulate WBS/XBS slices PA_XBS_DENORM for a wbs_version_id

	wbs_denorm_online(
		p_worker_id,
		'ONLINE',
		p_wbs_version_id
		);

	-- merge results
	merge_xbs_denorm(
		p_worker_id,
		'ONLINE'
		);

	-- don't delete contents from PJI_FP_AGGR_XBS_T

	-- Sadiq will call cleanup_xbs_denorm(p_worker_id, 'ONLINE')


-- -----------------------------------------------------
-- PRG Online Mode --

elsif 	l_denorm_type = 'PRG'
then

  	null; -- do nothing for now


-- -----------------------------------------------------
-- Bulk Mode --

elsif	l_denorm_type = 'ALL'
then

	-- ----------------------------------------------
  	-- process PRG / WBS hiearchies during PJP summarization

	if 	(
		 not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(
			l_process,
			'PJI_PJP_SUM_DENORM.POPULATE_XBS_DENORM(p_worker_id);'
			)
		)
	then
	  	return;
	end if;

	-- ----------------------------------------------
	-- cleanup interim tables
	cleanup_xbs_denorm(
		p_worker_id,
		l_extraction_type
		);

	if (l_extraction_type = 'FULL' and l_fpm_upgrade = 'C') then
	  -- Since 'FULL' mode of denorm table population does not handle
	  -- new projects after the first time it is run, we need to run
	  -- in 'INCREMENTAL' mode.
	  l_extraction_type := 'INCREMENTAL';
	end if;

	-- ----------------------------------------------
	-- Bulk Full mode --

	if 	(
		 (
		  l_extraction_type = 'FULL'
		  and
		  l_fpm_upgrade is null
		  )
		 or
		 l_fpm_upgrade = 'P'
		)
	then

		-- PA_XBS_DENORM is empty, populate from scratch

		-- XBS normalization algorithm for all data in
		-- the structures tables.

		prg_denorm(
			p_worker_id,
			l_extraction_type
			);

		merge_xbs_denorm(
			p_worker_id,
			l_extraction_type
			);

		cleanup_xbs_denorm(
			p_worker_id,
			l_extraction_type
			);

	-- ----------------------------------------------
	-- Bulk Incremental/Partial mode --

	elsif	(
		 l_extraction_type = 'INCREMENTAL'
		 or
		 l_extraction_type = 'PARTIAL'
		)
	then
		-- PA_XBS_DENORM contains data, repopulate a portion of it

		-- delete WBS/XBS slices for specific struct_version_id 	-- ###delete###
		FOR WBS_DELETE_NODE IN
		(
		 select
		 distinct
			decode(	invert.id,
				1, i_log.event_object,
				2, i_log.attribute2
			) event_object_id
		 from	PJI_PA_PROJ_EVENTS_LOG i_log,
			(
			 select	1 id
			 from	dual
			UNION ALL
			 select 2 id
			from	dual
			) invert
		 where 	1=1
		 and 	i_log.worker_id = P_WORKER_ID
		 and 	i_log.event_type in ('WBS_CHANGE', 'WBS_PUBLISH')
		) LOOP

			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -   Delete specific WBS/XBS slices -'
						|| ' struct_version_id = '
						|| WBS_DELETE_NODE.event_object_id,
					null,
					g_msg_level_high_detail
					);
			end if;

			delete
			from   	PA_XBS_DENORM
			where  	1=1
			and 	STRUCT_TYPE in ('WBS', 'XBS')
			and 	STRUCT_VERSION_ID = WBS_DELETE_NODE.event_object_id;

		END LOOP;

		-- Event Type 1
		-- delete PRG slices for specific prg_group

		FOR PRG_DELETE_NODE IN
		(
		 select
		 distinct
		 	decode( invert.id,
				1, i_log.event_object,
			 	2, i_log.attribute1
				) event_object_id
		 from	PJI_PA_PROJ_EVENTS_LOG i_log,
			(
			 select	1 id
			 from	dual
			UNION ALL
			 select 2 id
			 from	dual
			) invert
		 where 	1=1
		 and 	i_log.worker_id = P_WORKER_ID
		 and 	i_log.event_type = 'PRG_CHANGE'
		 and 	i_log.event_object <> -1
		) LOOP

			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -   Program groups to be deleted -'
						|| ' prg_group = '
						|| PRG_DELETE_NODE.event_object_id,
					null,
					g_msg_level_high_detail
					);
			end if;

			-- check projects that are outdated

			FOR PRG_PROJECT_NODE IN
			(
			 select
			 distinct
				project_id
			 from	pa_proj_element_versions
			 where 	1=1
			 and 	object_type = 'PA_STRUCTURES'
			 and    prg_group IS NOT NULL   /*	4904076 */
			 and 	prg_group = PRG_DELETE_NODE.event_object_id
			) LOOP

				-- delete all slices of all projects belonging
				-- to specific projects in a group

				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -    Delete -'
							|| ' sup_project_id = '
							|| PRG_PROJECT_NODE.project_id,
						null,
						g_msg_level_high_detail
						);
				end if;

				delete
				from	PA_XBS_DENORM
				where	1=1
				-- and 	struct_type = 'PRG'
				and 	sup_project_id = PRG_PROJECT_NODE.project_id;

			END LOOP;

		END LOOP;


		-- Event Type 2
		-- delete All slices for sup_project_id

		FOR PRG_2_DELETE_NODE IN
		(
		 select
		 distinct
			i_log.ATTRIBUTE1
		 from	PJI_PA_PROJ_EVENTS_LOG i_log
		 where 1=1
		 and 	i_log.worker_id = P_WORKER_ID
		 and 	i_log.event_type = 'PRG_CHANGE'
		 and 	i_log.event_object = -1
		) LOOP

/* Bug 5006375 , 5608947 */
                     FOR PRG_PROJECT_NODE IN
			(
			 select
			 distinct
				project_id
			 from	pa_proj_element_versions
			 where 	1=1
			 and 	object_type = 'PA_STRUCTURES'
			 and    prg_group IS NULL   /*	4904076 */
			 and 	project_id = PRG_2_DELETE_NODE.attribute1
			) LOOP

			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -   Delete specific ALL slices -'
						|| ' sup_project_id = '
						|| PRG_PROJECT_NODE.project_id,
					null,
					g_msg_level_high_detail
					);
			end if;

			delete
			from	PA_XBS_DENORM
			where	1=1
			-- and 	struct_type = 'PRG'
			and 	sup_project_id = PRG_PROJECT_NODE.project_id;

                        --  PRG_2_DELETE_NODE.attribute1;

		   END LOOP;
/* Bug 5006375 , 5608947 */

		END LOOP;

		--
		-- XBS normalization algorithm based on:
		--
		--  EVENT_TYPE in ('WBS_CHANGE', 'WBS_PUBLISH')
		--    ==> EVENT_OBJECT = structure version
		--  EVENT_TYPE = 'PRG_CHANGE' ==> EVENT_OBJECT = program group
		--
		--  OPERATION_TYPE in ('I', 'U', 'D') ==> since we delete the entire
		--version or program we do not
		--use this parameter for now
		--
		--

		--  *** Use PJI_PA_PROJ_EVENTS_LOG *** to determine which PRG/WBS
		--  data to process. ***

		prg_denorm(
			p_worker_id,
			l_extraction_type
			);

		merge_xbs_denorm(
			p_worker_id,
			l_extraction_type
			);

		cleanup_xbs_denorm(
			p_worker_id,
			l_extraction_type
			);

		-- -----------------------------------------------------

	end IF;

	PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(
		l_process,
		'PJI_PJP_SUM_DENORM.POPULATE_XBS_DENORM(p_worker_id);'
		);

	commit;

end IF;

-- -----------------------------------------------------

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: populate_xbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end POPULATE_XBS_DENORM;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

procedure COPY_XBS_DENORM(
	p_worker_id	        in	number,
        p_wbs_version_id_from 	in 	number,
   	p_wbs_version_id_to 	in 	number,
        p_copy_mode             in varchar2
) is


-- p_wbs_version_id_from = single project structure version from which you are copying
-- p_wbs_version_id_to = single project structure version to which you are copying


-- -----------------------------------------------------------------------
--
--  History
--  4-MAR-2005	ajdas	Created
--  ***  This API populates data for xbs data.  This API calls the
--
-- -----------------------------------------------------------------------


-- -----------------------------------------------------
-- Declare statements --
/*bug#4590082, changed the WBS check to PRG slice check to see if any valid source version exists*/
cursor c_version_exists is select 1 from dual
                           where exists (select 1
                                         from  pa_xbs_denorm
                                         where struct_version_id is null
                                           and sup_id=p_wbs_version_id_from
                                           and sub_id=p_wbs_version_id_from );
l_dummy             NUMBER;
l_process 		    varchar2(30);
l_extraction_type 	varchar2(30);
l_fpm_upgrade 		varchar2(30);
l_denorm_type 		varchar2(30);
l_prg_group_id 		number;
l_last_update_date  date;
l_last_updated_by   number;
l_creation_date     date;
l_created_by        number;
l_last_update_login number;
l_top_proj_element_id number;
l_target_project_id number;
l_prg_exists number;
-- -----------------------------------------------------
begin

if 	g_pa_debug_mode = 'Y'
then
	Pji_Utils.WRITE2LOG(
		'PJI_PJP '
			|| '- Begin: copy_xbs_denorm '
			|| '- p_worker_id = '
			|| p_worker_id
   			|| '- p_wbs_version_id_from = '
			|| p_wbs_version_id_from
			|| ' p_wbs_version_id_to = '
			|| p_wbs_version_id_to,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- Variable assignments --
-- Variable Assignments --

-- Checking if the target is already populated then not popultaing the denorm data
        begin
           select 1
           into l_prg_exists
           from dual
           where exists (select 1
                           from  pa_xbs_denorm
                           where struct_version_id is null
                           and   sup_id=p_wbs_version_id_to
                           and  sub_id=p_wbs_version_id_to);

           If l_prg_exists=1 then
           return;
          end if;
        exception when no_data_found then
          null;
        end;

l_last_update_date  := sysdate;
l_last_updated_by   := FND_GLOBAL.USER_ID;
l_creation_date     := sysdate;
l_created_by        := FND_GLOBAL.USER_ID;
l_last_update_login := FND_GLOBAL.LOGIN_ID;

    begin
	select proj_element_id  ,project_id
	into l_top_proj_element_id ,l_target_project_id
	from PA_PROJ_ELEMENT_VERSIONS
	where parent_structure_version_id= p_wbs_version_id_to
	and object_type='PA_STRUCTURES';
    exception
    when no_data_found then null;
    end;

    open c_version_exists ;
    fetch c_version_exists into l_dummy;
    if c_version_exists%found then

    If p_copy_mode='P' THEN

    /* First inserting all the records  of the old version changing the project_element_id mapping to element_number i.e
      sup_emt_id,sub_emt_id,subro_id   to    sup_element_numbner,sub_element_numbner,subroelement_numbner ,
      once that is done   getting the pro_element_id back for the new version by mapping the same element number
      to the new proj_element_ids*/
          declare
            cursor c_temp(p_wbs_version_id_from in number,p_wbs_version_id_to in number,l_top_proj_element_id in number) is
            select  temp.struct_type,temp.prg_group,projv1s.project_id sup_project_id, projv1s.proj_element_id sup_emt_id
			,projv1s.element_version_id sup_id,projv1s.parent_structure_version_id struct_version_id
			,temp.sub_leaf_flag, temp.sup_level, temp.sub_level,temp.relationship_type
			, decode( temp.struct_type,'WBS',l_top_proj_element_id,null) struct_emt_id
			,temp.sub_rollup_id,0,0,0,temp.sub_element_number,temp.subro_element_number
			 from  	pa_xbs_denorm_temp temp
		        ,PA_PROJ_ELEMENT_VERSIONS projv1s
		        ,pa_proj_elements proje1s
	       where    proje1s.element_number= temp.sup_element_number
	        and     proje1s.proj_element_id =projv1s.proj_element_id
			and projv1s.parent_structure_version_id=temp.struct_version_id
	        and 	projv1s.parent_structure_version_id=p_wbs_version_id_to;

        struct_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		prg_grouptab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_project_idtab  SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_idtab SYSTEM.pa_num_tbl_type                 := SYSTEM.pa_num_tbl_type();
		struct_version_idtab SYSTEM.pa_num_tbl_type       := SYSTEM.pa_num_tbl_type();
		sub_leaf_flagtab SYSTEM.PA_VARCHAR2_1_TBL_TYPE    := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
		sup_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
        relationship_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		struct_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_rollup_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		subro_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
		subro_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();

    begin
    insert into	PA_XBS_DENORM_temp
		(
		struct_type,	prg_group,		sup_project_id,
		sup_emt_id,		sup_id,		struct_version_id,
		sub_leaf_flag,		sup_level,		sub_level,
        relationship_type,		struct_emt_id,	sub_rollup_id,
		sub_id,		sub_emt_id,		subro_id,
		sub_element_number,
		sup_element_number,
		subro_element_number
		)
		 select    xbs.struct_type,
		null prg_group
		,xbs.sup_project_id
		 ,xbs.sup_emt_id,xbs.sup_id,p_wbs_version_id_to struct_version_id
	        , xbs.sub_leaf_flag,xbs.sup_level, xbs.sub_level
		, xbs.relationship_type,xbs.struct_emt_id,xbs.sub_rollup_id
                ,xbs.sub_id,xbs.sub_emt_id,xbs.subro_id
				,(select projeb.element_number  from pa_proj_elements projeb
				  where projeb.proj_element_id= xbs.sub_emt_id ) sub_element_number
				  ,(select decode( proje.object_type,'PA_TASKS',proje.element_number,'PA_STRUCTURES',to_char(l_top_proj_element_id ),null)   from pa_proj_elements proje
				 where proje.proj_element_id= xbs.sup_emt_id  ) sup_element_number
		                ,(select projec.element_number  from pa_proj_elements projec
				 where projec.proj_element_id= xbs.subro_id)  subro_element_number
			 from pa_xbs_denorm xbs
			      ,PA_PROJ_ELEMENT_VERSIONS projsup
			 where xbs.sup_emt_id =projsup.proj_element_id
			  and  xbs.sup_id=projsup.element_version_id
			  and  xbs.struct_version_id =p_wbs_version_id_from
			  and  projsup.parent_structure_version_id=xbs.struct_version_id;

	 OPEN c_temp( p_wbs_version_id_from,p_wbs_version_id_to,l_top_proj_element_id );
	 FETCH c_temp bulk collect into
		struct_typetab,
		prg_grouptab,
		sup_project_idtab,
		sup_emt_idtab,
		sup_idtab,
		struct_version_idtab,
		sub_leaf_flagtab,
		sup_leveltab,
		sub_leveltab,
       		relationship_typetab,
		struct_emt_idtab,
		sub_rollup_idtab,
		sub_idtab,
		sub_emt_idtab,
		subro_idtab,
		sub_element_numbertab,
		subro_element_numbertab;

        delete from pa_xbs_denorm_temp;
       IF struct_typetab.COUNT <>0 then
	   FORALL i IN struct_typetab.FIRST..struct_typetab.LAST
		              insert into	PA_XBS_DENORM_temp
		(
		struct_type
		,prg_group
		,sup_project_id
		,sup_emt_id
		,sup_id
		,struct_version_id
		,sub_leaf_flag
		,sup_level
		,sub_level
		,relationship_type
		,struct_emt_id
		,sub_rollup_id
		,sub_id
		,sub_emt_id
		,subro_id
		,sub_element_number
		,subro_element_number
		)
         VALUES
        (	struct_typetab(i)
		,prg_grouptab(i)
		,sup_project_idtab(i)
		,sup_emt_idtab(i)
		,sup_idtab(i)
		,struct_version_idtab(i)
		,sub_leaf_flagtab(i)
		,sup_leveltab(i)
		,sub_leveltab(i)
		,relationship_typetab(i)
		,struct_emt_idtab(i)
		,sub_rollup_idtab(i)
		,sub_idtab(i)
		,sub_emt_idtab(i)
		,subro_idtab(i)
		,sub_element_numbertab(i)
		,subro_element_numbertab(i)
		);
          END IF;
		close c_temp;
        --write_log('insert bulk into temp done 1');
		end;
        /* getting  the pro_element_id back for the new version by mapping the same element number
          to the new proj_element_ids*/
         declare
            cursor c_temp(p_wbs_version_id_to in number) is
             select temp.struct_type,temp.prg_group
                    ,temp.struct_version_id ,temp.sup_project_id
                    ,temp.sup_emt_id  , projv1b.proj_element_id sub_emt_id
		    ,temp.sup_id  ,projv1b.element_version_id sub_id
		    ,temp.sup_level,   temp.sub_level
                    ,temp.relationship_type   ,temp.sub_leaf_flag
                    ,temp.struct_emt_id,temp.sub_rollup_id
                    ,(select  proje1.proj_element_id from pa_proj_elements proje1
                                                         ,PA_PROJ_ELEMENT_VERSIONS projv1
	                                               	 WHERE PROJE1.PROJECT_ID=TEMP.SUP_PROJECT_ID
										              AND  PROJE1.OBJECT_TYPE='PA_TASKS'
									                  AND  PROJE1.ELEMENT_NUMBER= TEMP.SUBRO_ELEMENT_NUMBER
										              AND  PROJE1.PROJ_ELEMENT_ID=  PROJV1.PROJ_ELEMENT_ID
										              AND  PROJV1.PARENT_STRUCTURE_VERSION_ID=  TEMP.STRUCT_VERSION_ID
										              AND  PROJV1.PARENT_STRUCTURE_VERSION_ID=p_wbs_version_id_to
                        	) subro_id
			  from  pa_xbs_denorm_temp temp
		  	      ,PA_PROJ_ELEMENT_VERSIONS projv1b
			      ,pa_proj_elements proje1b
			where  proje1b.element_number= temp.sub_element_number
		        and  proje1b.proj_element_id 		=projv1b.proj_element_id
			and     projv1b.parent_structure_version_id=temp.struct_version_id
			and 	projv1b.parent_structure_version_id=p_wbs_version_id_to;

		 struct_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		prg_grouptab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_project_idtab  SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_idtab SYSTEM.pa_num_tbl_type                 := SYSTEM.pa_num_tbl_type();
		struct_version_idtab SYSTEM.pa_num_tbl_type       := SYSTEM.pa_num_tbl_type();
		sub_leaf_flagtab SYSTEM.PA_VARCHAR2_1_TBL_TYPE    := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
		sup_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		 relationship_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		struct_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_rollup_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		subro_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
		subro_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();

   begin
	 OPEN c_temp( p_wbs_version_id_to );
	 FETCH c_temp bulk collect into
        struct_typetab
		,prg_grouptab
		,struct_version_idtab
		,sup_project_idtab
		,sup_emt_idtab
		,sub_emt_idtab
		,sup_idtab
		,sub_idtab
		,sup_leveltab
		,sub_leveltab
       		,relationship_typetab
		,sub_leaf_flagtab
		,struct_emt_idtab
		,sub_rollup_idtab
		,subro_idtab  ;
        --write_log('second fetch done 1');
	IF struct_typetab.COUNT <>0 then
	   FORALL i IN struct_typetab.FIRST..struct_typetab.LAST
           insert into	PA_XBS_DENORM(
		struct_type
		,prg_group
		,struct_version_id
		,sup_project_id
		,sup_emt_id
		,sub_emt_id
		,sup_id
		,sub_id
		,sup_level
		,sub_level
       		,relationship_type
		,sub_leaf_flag
		,struct_emt_id
		,sub_rollup_id
		,subro_id
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		)
         VALUES
        ( struct_typetab(i)
		,prg_grouptab(i)
		,struct_version_idtab(i)
		,sup_project_idtab(i)
		,sup_emt_idtab(i)
		,sub_emt_idtab(i)
		,sup_idtab(i)
		,sub_idtab(i)
		,sup_leveltab(i)
		,sub_leveltab(i)
       		,relationship_typetab(i)
       		,sub_leaf_flagtab(i)
		,struct_emt_idtab(i)
		,sub_rollup_idtab(i)
		,subro_idtab(i)
		,l_last_update_date
		,l_last_updated_by
		,l_creation_date
		,l_created_by
		,l_last_update_login
		);
          END IF;
     /* The below insert replaces the call to Pji_Pjp_Sum_Rollup.update_xbs_denorm
      it inserts all the data to pji_xbs_Denorm from pa_xbs_Denorm*/
      IF struct_typetab.COUNT <>0 then
     FORALL i IN struct_typetab.FIRST..struct_typetab.LAST
        insert into	PJI_XBS_DENORM(
		struct_type
		,prg_group
		,struct_version_id
		,sup_project_id
		,sup_emt_id
		,sub_emt_id
		,sup_id
		,sub_id
		,sup_level
		,sub_level
       		,relationship_type
		,sub_leaf_flag
	--	,struct_emt_id
		,sub_rollup_id
		,subro_id
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		)
         VALUES
        ( struct_typetab(i)
		,prg_grouptab(i)
		,struct_version_idtab(i)
		,sup_project_idtab(i)
		,sup_emt_idtab(i)
		,sub_emt_idtab(i)
		,sup_idtab(i)
		,sub_idtab(i)
		,sup_leveltab(i)
		,sub_leveltab(i)
		,relationship_typetab(i)
		,sub_leaf_flagtab(i)
	--	,struct_emt_idtab(i)
		,sub_rollup_idtab(i)
		,subro_idtab(i)
		,l_last_update_date
		,l_last_updated_by
		,l_creation_date
		,l_created_by
		,l_last_update_login
		);
  	END IF;
		close c_temp;
	--	write_log('insert bulk into xbs_Denorm done 1');
		end;
    /* inserting the PRG lines*/
	insert
	into 	PA_XBS_DENORM
		(
		struct_type,
		prg_group,
		struct_version_id,
		sup_project_id,
		sup_emt_id,
		sub_emt_id,
		subro_id,
		sup_level,
		sub_rollup_id,
		sub_leaf_flag,
		sub_level,
		relationship_type,
		 struct_emt_id,
   		sup_id,
		  sub_id,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
    select xbs.struct_type,
           null prg_group,
           xbs.struct_version_id,l_target_project_id sup_project_id,
           l_top_proj_element_id sup_emt_id,l_top_proj_element_id sub_emt_id,
           xbs.subro_id,1,
           l_top_proj_element_id sub_rollup_id,xbs.sub_leaf_flag,
           1,xbs.relationship_type,
           xbs.struct_emt_id,to_number(p_wbs_version_id_to) wsup_id,
           to_number(p_wbs_version_id_to) wsub_id,l_last_update_date,
           l_last_updated_by,l_creation_date,
           l_created_by ,l_last_update_login
    from   PA_XBS_DENORM xbs
    where  xbs.struct_version_id is null
    and    xbs.sup_id=p_wbs_version_id_from
    and    xbs.sub_id=p_wbs_version_id_from;
--write_log('inert of PRG line done 1');

-- write_log(' first insert into pji 1');
   insert into PJI_XBS_DENORM
        (
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_TYPE,
          den.PRG_GROUP,
          den.STRUCT_VERSION_ID,
          den.SUP_PROJECT_ID,
          den.SUP_ID,
          den.SUP_EMT_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUB_EMT_ID,
          1 SUP_LEVEL,
          1 SUB_LEVEL,
          den.SUB_ROLLUP_ID,
          den.SUB_LEAF_FLAG,
          den.RELATIONSHIP_TYPE,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_XBS_DENORM den
        where  den.struct_version_id is null
        and    den.sup_id=p_wbs_version_id_to
        and    den.sub_id=p_wbs_version_id_to;


    elsIf p_copy_mode='V' THEN

    /* this code executes for  only pulishing or making working version when the version id changes between the same prtoject id */

        declare
         cursor c_temp(p_wbs_version_id_from in number,p_wbs_version_id_to in number) is
          select xbs.struct_type,xbs.prg_group,
                to_number(p_wbs_version_id_to) wstruct_version_id,xbs.sup_project_id,
                xbs.sup_emt_id,xbs.sub_emt_id,
                projsup.element_version_id sup_id,
                (select projsub.element_version_id  from PA_PROJ_ELEMENT_VERSIONS projsub
  	             where   projsub.proj_element_id= xbs.sub_emt_id
	             and projsup.parent_structure_version_id=projsub.parent_structure_version_id) sub_id,
     	   xbs.sup_level,xbs.sub_level,
           xbs.relationship_type,xbs.sub_leaf_flag,
           xbs.struct_emt_id,xbs.sub_rollup_id,
           xbs.subro_id
         from  pa_xbs_denorm xbs,
               PA_PROJ_ELEMENT_VERSIONS projsup
        where projsup.parent_structure_version_id= p_wbs_version_id_to
        and   projsup.proj_element_id= xbs.sup_emt_id
        and   xbs.struct_version_id= p_wbs_version_id_from;

        struct_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		prg_grouptab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_project_idtab  SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sup_idtab SYSTEM.pa_num_tbl_type                 := SYSTEM.pa_num_tbl_type();
		struct_version_idtab SYSTEM.pa_num_tbl_type       := SYSTEM.pa_num_tbl_type();
		sub_leaf_flagtab SYSTEM.PA_VARCHAR2_1_TBL_TYPE    := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
		sup_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_leveltab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
        relationship_typetab SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
		struct_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_rollup_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_emt_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		subro_idtab SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
		sub_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
		subro_element_numbertab SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();

   begin
	 OPEN c_temp( p_wbs_version_id_from,p_wbs_version_id_to );
	 FETCH c_temp bulk collect into
		 struct_typetab
		,prg_grouptab
		,struct_version_idtab
		,sup_project_idtab
		,sup_emt_idtab
		,sub_emt_idtab
		 ,sup_idtab
		,sub_idtab
		,sup_leveltab
		,sub_leveltab
		,relationship_typetab
		,sub_leaf_flagtab
		,struct_emt_idtab
		,sub_rollup_idtab
		,subro_idtab  ;
        IF struct_typetab.COUNT <>0 then
	   FORALL i IN struct_typetab.FIRST..struct_typetab.LAST
           insert into	PA_XBS_DENORM(
		struct_type
		,prg_group
		,struct_version_id
		,sup_project_id
		,sup_emt_id
		,sub_emt_id
		,sup_id
		,sub_id
		,sup_level
		,sub_level
	 	,relationship_type
		,sub_leaf_flag
		,struct_emt_id
		,sub_rollup_id
		,subro_id
		 ,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		)
         VALUES
        ( struct_typetab(i)
		,prg_grouptab(i)
		,struct_version_idtab(i)
		,sup_project_idtab(i)
		,sup_emt_idtab(i)
		,sub_emt_idtab(i)
		,sup_idtab(i)
		,sub_idtab(i)
		,sup_leveltab(i)
		,sub_leveltab(i)
		,relationship_typetab(i)
		,sub_leaf_flagtab(i)
		,struct_emt_idtab(i)
		,sub_rollup_idtab(i)
		,subro_idtab(i)
		,l_last_update_date
		 ,l_last_updated_by
		  ,l_creation_date
		  ,l_created_by
		  ,l_last_update_login
		);
         END IF;
     /* The below insert replaces the call to Pji_Pjp_Sum_Rollup.update_xbs_denorm
      it inserts all the data to pji_xbs_Denorm from pa_xbs_Denorm*/
      IF struct_typetab.COUNT <>0 then
     FORALL i IN struct_typetab.FIRST..struct_typetab.LAST
        insert into	PJI_XBS_DENORM(
		struct_type
		,prg_group
		,struct_version_id
		,sup_project_id
		,sup_emt_id
		,sub_emt_id
		,sup_id
		,sub_id
		,sup_level
		,sub_level
	       	,relationship_type
		,sub_leaf_flag
	--	,struct_emt_id
		,sub_rollup_id
		,subro_id
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
		)
         VALUES
        ( struct_typetab(i)
		,prg_grouptab(i)
		,struct_version_idtab(i)
		,sup_project_idtab(i)
		,sup_emt_idtab(i)
		,sub_emt_idtab(i)
		,sup_idtab(i)
		,sub_idtab(i)
		,sup_leveltab(i)
		,sub_leveltab(i)
       		,relationship_typetab(i)
       		,sub_leaf_flagtab(i)
	--	,struct_emt_idtab(i)
		,sub_rollup_idtab(i)
		,subro_idtab(i)
		,l_last_update_date
		 ,l_last_updated_by
		,l_creation_date
		,l_created_by
		,l_last_update_login
		);
          END IF;
		close c_temp;
	--	write_log('insert bulk into xbs_Denorm done 1');
		end;
    /* inserting the PRG lines*/
	insert
	into 	PA_XBS_DENORM
		(
		struct_type,
		prg_group,
		struct_version_id,
		sup_project_id,
		sup_emt_id,
		sub_emt_id,
		subro_id,
		sup_level,
		sub_rollup_id,
		sub_leaf_flag,
		sub_level,
       		relationship_type,
		struct_emt_id,
   		sup_id,
		sub_id,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
    select xbs.struct_type,xbs.prg_group,
           xbs.struct_version_id,xbs.sup_project_id,
           xbs.sup_emt_id,xbs.sub_emt_id,
           xbs.subro_id,1,
           xbs.sub_rollup_id,xbs.sub_leaf_flag,
           1,xbs.relationship_type,
           xbs.struct_emt_id,to_number(p_wbs_version_id_to) wsup_id,
           to_number(p_wbs_version_id_to) wsub_id,l_last_update_date,
           l_last_updated_by,l_creation_date,
           l_created_by ,l_last_update_login
    from   PA_XBS_DENORM xbs
    where  xbs.struct_version_id is null
    and    xbs.sup_id=p_wbs_version_id_from
    and    xbs.sub_id=p_wbs_version_id_from;

     insert into PJI_XBS_DENORM
        (
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_TYPE,
          den.PRG_GROUP,
          den.STRUCT_VERSION_ID,
          den.SUP_PROJECT_ID,
          den.SUP_ID,
          den.SUP_EMT_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUB_EMT_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_ROLLUP_ID,
          den.SUB_LEAF_FLAG,
          den.RELATIONSHIP_TYPE,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_XBS_DENORM den
        where  den.struct_version_id is null
        and    den.sup_id=p_wbs_version_id_to
        and    den.sub_id=p_wbs_version_id_to;
    end if;
  else
      /* If there are no record in the source version itself then call the existing API for
       the norma flow, so calling the populate_WBS_denorm ,
       But commenting this as this is a corner exception case, in which at present
       will not do any processing to find the exce[tional handling*/
      /* PJI_FM_PLAN_MAINT.POPULATE_WBS_DENORM(
      p_online            => 'Y'
     , x_return_status     => l_return_status );
     */
     null;
    end IF;
   close c_version_exists;
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: copy_xbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------
 -- write_log(' end of copy_xbs_Denorm 1');

  EXCEPTION
  WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PJI_PJP_SUM_DENORM' ,
                             p_procedure_name => 'COPY_XBS_DENORM');
    RAISE;

end COPY_XBS_DENORM;





-- -----------------------------------------------------------------------

-- -----------------------------------------------------
-- procedure POPULATE_RBS_DENORM
-- -----------------------------------------------------

procedure POPULATE_RBS_DENORM(
	p_worker_id 		in 	number,
	p_denorm_type    	in 	varchar2,
	p_rbs_version_id 	in 	number
) is


-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API populates data for rbs data.  This API calls the
--	following procedures:
--
--		rbs_denorm
--		merge_rbs_denorm
--
-- -----------------------------------------------------------------------


-- -----------------------------------------------------
-- Declare stataments --

l_process 		varchar2(30);
l_extraction_type 	varchar2(30);
l_denorm_type 		varchar2(30);
l_fpm_upgrade           varchar2(1);
-- -----------------------------------------------------

begin

l_denorm_type := nvl(p_denorm_type, 'ALL');


if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: populate_rbs_denorm -'
			|| ' p_worker_id = '
			|| p_worker_id,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- Variable assignments --

l_process := 	PJI_PJP_SUM_MAIN.g_process
 		|| to_char(p_worker_id);

l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(
			l_process,
			'EXTRACTION_TYPE'
			);

-- ----------------------------------------

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP -   Variables -'
			|| ' l_process = '
			|| l_process
			|| ' l_extraction_type = '
			|| l_extraction_type,
		null,
		g_msg_level_high_detail
		);
end if;

-- ----------------------------------------

-- -----------------------------------------------------
-- Online Mode --

if 	p_denorm_type = 'RBS'

then

	-- ----------------------------------------------
	-- delete RBS slices for specific struct_version_id 	-- ###delete###

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   Delete specific RBS slices -'
				|| ' p_rbs_version_id = '
				|| p_rbs_version_id,
			null,
			g_msg_level_high_detail
			);
	end if;

  /* Commented for Bug 9099240
	delete
  	from	PA_RBS_DENORM
  	where	1=1
	and	STRUCT_VERSION_ID = p_rbs_version_id;
  */
	-- ----------------------------------------------
	-- Repopulate PA_RBS_DENORM for specific struct_version_id

	cleanup_rbs_denorm(
		p_worker_id,
		'ONLINE'
		);

	rbs_denorm_online(
		p_worker_id,
		'ONLINE',
		p_rbs_version_id
		);

	merge_rbs_denorm(
		p_worker_id,
		'ONLINE'
		);

	-- don't delete contents from PJI_FP_AGGR_RBS_T

	-- Sadiq will call cleanup_xbs_denorm(p_worker_id, 'ONLINE')



-- -----------------------------------------------------
-- Bulk Mode --

elsif 	p_denorm_type = 'ALL'

then

	-- ----------------------------------------------
  	-- process RBS hiearchies during PJP summarization

	if 	(
		 not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(
			l_process,
			'PJI_PJP_SUM_DENORM.POPULATE_RBS_DENORM(p_worker_id);'
			)
		)
	then
  		return;
	end if;

	-- -------------------------------------------------------
	-- cleanup interim tables
	cleanup_rbs_denorm(
		p_worker_id,
		l_extraction_type
		);

	-- -------------------------------------------------------
        --Bug 4293903: In FULL mode if FPM upgrade is done treat as
        --incremental
        ----------------------------------------------------------
        l_fpm_upgrade := PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE');

        IF (nvl(l_fpm_upgrade,'P') = 'C' and
            l_extraction_type = 'FULL') THEN

            l_extraction_type := 'INCREMENTAL';

        END IF;

	-- Bulk Full mode --

	if 	l_extraction_type = 'FULL'

	then



		-- PA_RBS_DENORM is empty, populate from scratch

	  	--
		-- RBS normalization algorithm for all data in
		-- the structures tables.
		--

		rbs_denorm(
			p_worker_id,
			l_extraction_type,
			null
			);

		merge_rbs_denorm(
			p_worker_id,
			l_extraction_type
			);

		cleanup_rbs_denorm(
			p_worker_id,
			l_extraction_type
			);

	-- ----------------------------------
	-- Bulk Incremental/Partial mode --

	elsif	(
		 l_extraction_type = 'INCREMENTAL'
		 or
		 l_extraction_type = 'PARTIAL'
		 or
		 l_extraction_type = 'RBS'
		)
	then
		-- PA_RBS_DENORM contains data, repopulate a portion of it

    /* Commented for bug 9099240
		delete
		from 	PA_RBS_DENORM
		where	STRUCT_VERSION_ID in
			(
			select	EVENT_OBJECT
	  		from   	PJI_PA_PROJ_EVENTS_LOG
			where  	1=1
			and	EVENT_TYPE = 'PJI_RBS_CHANGE'
			and     WORKER_ID = P_WORKER_ID
			);
			*/

		--
  		-- RBS normalization algorithm based on:
		--
		--  EVENT_TYPE = 'PJI_RBS_CHANGE' ==> EVENT_OBJECT = structure version
		--
		--
		--
		--  *** Use PJI_PA_PROJ_EVENTS_LOG *** to determine which RBS
		--  data to process. ***
		--

		rbs_denorm(
			p_worker_id,
			l_extraction_type,
			null
			);

		merge_rbs_denorm(
			p_worker_id,
			l_extraction_type
			);

    /* Commented for bug 9099240
		cleanup_rbs_denorm(
			p_worker_id,
			l_extraction_type
			);
			*/

	end if;

-- -----------------------------------------------------

PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(
	l_process,
	'PJI_PJP_SUM_DENORM.POPULATE_RBS_DENORM(p_worker_id);'
	);

commit;
-- -----------------------------------------------------

end if;

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: populate_rbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end POPULATE_RBS_DENORM;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------
-- procedure POPULATE_RBS_DENORM_UPGRADE
-- -----------------------------------------------------

--
--  NOTE: Since this API updates both PA_RBS_DENORM and PJI_RBS_DENORM, it
--        should only be used during upgrade since change context between
--        PA_RBS_DENORM and PJI_RBS_DENORM is lost for the given RBS version.
--

--  30-JUL-2004  jwhite    Bug 3802762
--                         Because of savepoint issues with
--                         RES_LIST_TO_PLAN_RES_LIST api, commented-out
--                         commit in POPULATE_RBS_DENORM_UPGRADE
--
-- -----------------------------------------------------

procedure POPULATE_RBS_DENORM_UPGRADE(
	p_rbs_version_id	in  	   	number,
	x_return_status  	out nocopy 	varchar2,
	x_msg_count   	 	out nocopy 	number,
	x_msg_data       	out nocopy 	varchar2
) is

-- -----------------------------------------------------
-- Declare staments

l_worker_id		number;

l_last_update_date	date;
l_last_updated_by	number;
l_creation_date		date;
l_created_by		number;
l_last_update_login 	number;


-- -----------------------------------------------------

begin

l_worker_id := 1;


if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: populate_rbs_denorm_upgrade -'
			|| ' p_rbs_version_id = '
			|| p_rbs_version_id,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------

delete
from	PA_RBS_DENORM
where 	STRUCT_VERSION_ID = p_rbs_version_id;

delete
from 	PJI_RBS_DENORM
where 	STRUCT_VERSION_ID = p_rbs_version_id;

-- -----------------------------------------------------
--  Populate PA_RBS_DENORM for a single RBS version (should not commit)

rbs_denorm(
	l_worker_id,
	'UPGRADE',
	p_rbs_version_id
	);

merge_rbs_denorm(
	l_worker_id,
	'UPGRADE'
	);

cleanup_rbs_denorm(
	l_worker_id,
	'UPGRADE'
	);

-- -----------------------------------------------------

l_last_update_date  := sysdate;
l_last_updated_by   := FND_GLOBAL.USER_ID;
l_creation_date     := sysdate;
l_created_by        := FND_GLOBAL.USER_ID;
l_last_update_login := FND_GLOBAL.LOGIN_ID;


-- -----------------------------------------------------

insert
into 	PJI_RBS_DENORM
  	(
	struct_version_id,
	sup_id,
	subro_id,
	sub_id,
	sup_level,
	sub_level,
	sub_leaf_flag,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN
  	)
select
	struct_version_id,
	sup_id,
	subro_id,
	sub_id,
	sup_level,
	sub_level,
	sub_leaf_flag,
 	l_last_update_date,
	l_last_updated_by,
 	l_creation_date,
	l_created_by,
	l_last_update_login
from	PA_RBS_DENORM
where	STRUCT_VERSION_ID = p_rbs_version_id;

-- -----------------------------------------------------

x_return_status	:= FND_API.G_RET_STS_SUCCESS;
x_msg_count 	:= 0;
x_msg_data 	:= null;

-- -----------------------------------------------------
--  Bug 3802762, 30-JUL-2004, jwhite -----------------------------
--  Commented-out commit becuase of savepoint issue with a calling api

    --commit;

--  End Bug 3802762, 30-JUL-2004, jwhite --------------------------

-- -----------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: populate_rbs_denorm_upgrade',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end POPULATE_RBS_DENORM_UPGRADE;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure prg_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
) as

-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_PROJ_ELEMENT_VERSIONS
--		PA_OBJECT_RELATIONSHIPS
--
--	 Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_XBS
--
--	 When P_EXTRACTION_TYPE equals 'FULL', this API calls the following
--	procedure:
--		wbs_denorm
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --


l_prg_temp_parent 		number;
l_prg_temp_level 		number;
l_prg_node_count 		number;
l_prg_leaf_flag_id 		number;
l_prg_leaf_flag 		varchar2(1);

l_prj_temp_parent 		number;
l_prg_temp_rollup 		number;
l_prg_temp_sup_emt 		number;
l_prg_temp_sub_emt 		number;

l_prg_element_version_count	number;

l_prg_dummy_rollup 		number;
l_prg_dummy_task_flag 		varchar2(1);

l_project_id			number;

-- -----------------------------------------------------

begin

-- (PRG node = program)


if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: prg_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE,
		null,
		g_msg_level_proc_call
		);
end if;
	-- --------------------------------------------------------
	-- Get all PRG nodes from a certain level --

	--  Look only at the data to be processed
	--	1) FULL - All data
	--	2) INCREMENTAL or PARTIAL - Filter data by looking at the logs
	--	table
	--		2.1) PRG nodes changes
	--		2.2) PRG nodes additions

	l_project_id := null;

	FOR PRG_NODE IN
	(
	select
          distinct
      PRG_LEVEL,
	  PROJECT_ID,
	  PROJ_ELEMENT_ID,
	  ELEMENT_VERSION_ID,
	  PARENT_STRUCTURE_VERSION_ID,
	  PRG_GROUP
	from
	  (
	select /*+ ordered */ -- all Projects in batch_map
	  distinct
      1 prg_level,
	  ver.project_id,
	  ver.proj_element_id,
	  ver.element_version_id,
	  ver.parent_structure_version_id,
	  ver.prg_group
	from
	  PJI_PJP_PROJ_BATCH_MAP map,
	  PA_PROJ_ELEMENT_VERSIONS ver
	where
	  p_extraction_type      in ('FULL', 'UPGRADE') and
	  ver.object_type        = 'PA_STRUCTURES'      and
	  ver.prg_group          is null                and
	  map.worker_id          = p_worker_id          and
	  map.PJI_PROJECT_STATUS is null                and
	  ver.project_id         = map.project_id
	UNION ALL
	select /*+ ordered */
          -- Programs (UPGRADE only. In FULL, batch_map has necessary projects)
	  distinct
      pvt_nodes1.prg_level,
	  pvt_nodes1.project_id,
	  pvt_nodes1.proj_element_id,
	  pvt_nodes1.element_version_id,
	  pvt_nodes1.parent_structure_version_id,
	  pvt_nodes1.prg_group
	from
	  (
	  select /*+ ordered */
	    distinct
	    ver.prg_group
	  from
	    PA_PROJ_ELEMENT_VERSIONS ver,
	    PJI_PJP_PROJ_BATCH_MAP map
	  where
	    p_extraction_type in ('FULL', 'UPGRADE') and
	    ver.object_type        = 'PA_STRUCTURES' and
	    ver.prg_group          is not null       and
	    map.worker_id          = p_worker_id     and
	    map.PJI_PROJECT_STATUS is null           and
	    ver.project_id         = map.project_id
	  ) batch_map,
	  PA_PROJ_ELEMENT_VERSIONS pvt_nodes1
	where
	  p_extraction_type in ('FULL', 'UPGRADE') and
	  pvt_nodes1.object_type = 'PA_STRUCTURES' and
	  pvt_nodes1.prg_group   is not null       and
	  pvt_nodes1.prg_group   = batch_map.prg_group
	UNION ALL
	 select
	 distinct
	    pvt_nodes2.prg_level,
		pvt_nodes2.project_id,
		pvt_nodes2.proj_element_id,
		pvt_nodes2.element_version_id,
		pvt_nodes2.parent_structure_version_id,
		pvt_nodes2.prg_group
	 from 	PA_PROJ_ELEMENT_VERSIONS pvt_nodes2,
		(
		 select
		 distinct
			decode(	invert.id,
				1, i_log.event_object,
				2, i_log.attribute1
			) event_object_id
		 from	PJI_PA_PROJ_EVENTS_LOG i_log,
			(
			 select	1 id
			 from	dual
			 where p_extraction_type IN ('INCREMENTAL', 'PARTIAL')
			UNION ALL
			 select 2 id
			 from	dual
			 where p_extraction_type IN ('INCREMENTAL', 'PARTIAL')
			) invert
		 where 	1=1
		 and 	i_log.worker_id = P_WORKER_ID
		 and 	i_log.event_type = 'PRG_CHANGE'
		 ) log11
	 where 	1=1
	 and 	pvt_nodes2.prg_group = log11.event_object_id
	 and 	pvt_nodes2.object_type = 'PA_STRUCTURES'
     and 	pvt_nodes2.prg_group IS NOT NULl    /*	4904076 */
	UNION ALL
	 select
	 distinct
	    1 prg_level,
		pvt_nodes3.project_id,
		pvt_nodes3.proj_element_id,
		pvt_nodes3.element_version_id,
		pvt_nodes3.parent_structure_version_id,
		pvt_nodes3.prg_group
	 from 	PA_PROJ_ELEMENT_VERSIONS pvt_nodes3,
		(
		 select
		 distinct
			decode(	invert.id,
				1, i_log.event_object,
				2, i_log.attribute1
			) event_object_id
		 from	PJI_PA_PROJ_EVENTS_LOG i_log,
			(
			 select	1 id
			 from	dual
			 where p_extraction_type IN ('INCREMENTAL', 'PARTIAL')
			UNION ALL
			 select 2 id
			 from	dual
			 where p_extraction_type IN ('INCREMENTAL', 'PARTIAL')
			) invert
		 where 	1=1
		 and 	i_log.worker_id = P_WORKER_ID
		 and 	i_log.event_type = 'PRG_CHANGE'
		 and	i_log.event_object = -1
		 ) log22
	 where 	1=1
	 and 	pvt_nodes3.project_id = log22.event_object_id -- log22.attribute2
	 and 	pvt_nodes3.object_type = 'PA_STRUCTURES'
	 and	pvt_nodes3.prg_group is null
	  )
	order by
	  PRG_LEVEL DESC,     /* This DESC order by will take care the hierarchy of projects*/
	  PROJECT_ID,
	  PROJ_ELEMENT_ID,
	  ELEMENT_VERSION_ID,
	  PARENT_STRUCTURE_VERSION_ID,
	  PRG_GROUP
	) LOOP

	if (p_extraction_type = 'FULL' or p_extraction_type = 'UPGRADE') then

	  if (l_project_id is null) then

	    l_project_id := prg_node.PROJECT_ID;

	  elsif (l_project_id <> prg_node.PROJECT_ID) then

	    update PJI_PJP_PROJ_BATCH_MAP
	    set    PJI_PROJECT_STATUS = 'C'
	    where  WORKER_ID = p_worker_id and
	           PROJECT_ID = l_project_id;

	    commit;

	    l_project_id := prg_node.PROJECT_ID;

	  end if;

	end if;

	IF 	PRG_NODE.prg_level > 1  		-- ###prg_group_is_null###
		and
		PRG_NODE.prg_group is null

	THEN
		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP - PRG Group is null Data Bug - element_version_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_data_bug
				);
		end if;
	ELSE

		-- --------------------------------------------------------
		-- Check program self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf
    if PRG_NODE.prg_group is not null then
		select 	count(*)
		into 	l_prg_node_count
		from 	PJI_FP_AGGR_XBS pdt_count
		where 	1=1
		and	pdt_count.sup_id = PRG_NODE.element_version_id
		and	pdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;
    else
        l_prg_node_count := 0;
    end if;
		-- l_prg_leaf_flag_id --
		if 	l_prg_node_count > 0
		then
			l_prg_leaf_flag_id := 0;
		else
			l_prg_leaf_flag_id := 1;
		end if;

		-- l_prg_leaf_flag -- (business rule)
		if 	(
			 PRG_NODE.element_version_id = PRG_NODE.element_version_id
			 or
			 l_prg_leaf_flag_id = 1
			)
		then
			l_prg_leaf_flag := 'Y';
		else
			l_prg_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting PRG node self -'
					|| ' sup_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;


		-- Insert PRG node self --
		insert
		into 	PJI_FP_AGGR_XBS
			(
			struct_type,
			prg_group,
			struct_version_id,
			sup_project_id,
			sup_id,
			sup_emt_id,
			subro_id,
			sub_id,
			sub_emt_id,
			sup_level,
			sub_level,
			sub_rollup_id,
			sub_leaf_flag_id,
			sub_leaf_flag,
			status_id,
			worker_id
			)
		values (
			'PRG', 				-- structure type
			PRG_NODE.prg_group, 		-- prg group
			null, 				-- structure version id
			PRG_NODE.project_id, 		-- parent project id
			PRG_NODE.element_version_id, 	-- parent id
			PRG_NODE.proj_element_id,	-- sup emt id
			null,	 			-- immediate child id
			PRG_NODE.element_version_id, 	-- child id
			PRG_NODE.proj_element_id,	-- sub emt_id
			PRG_NODE.prg_level, 		-- parent level
			PRG_NODE.prg_level, 		-- child level
			PRG_NODE.proj_element_id,	-- child rollup id
			l_prg_leaf_flag_id,		-- child leaf flag id
			l_prg_leaf_flag,		-- child leaf flag
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);

		-- --------------------------------------------------------
		-- Check for PRG node's parents --
		--  Check only if the node is not a top most node (level = 1)

		IF 	PRG_NODE.prg_level <> 1

		THEN

			FOR PRG_PARENT_NODE IN
			(
			 select
			 distinct
				prt_parent.object_id_from1,
				prt_parent.relationship_type,
				ver.prg_level
			 from 	PA_OBJECT_RELATIONSHIPS prt_parent,
				PA_PROJ_ELEMENT_VERSIONS ver
			 where 	1=1
			 and 	prt_parent.object_id_to1 = PRG_NODE.element_version_id
			 and 	prt_parent.object_type_from = 'PA_TASKS'
			 and 	prt_parent.object_type_to = 'PA_STRUCTURES'
			 and 	(
				 prt_parent.relationship_type = 'LF'
				 or
				 prt_parent.relationship_type = 'LW'
				)
			 and 	ver.element_version_id = prt_parent.object_id_from1
			) LOOP

				select	pvt_parent1.parent_structure_version_id,
					pvt_parent1.project_id,
					pvt_parent1.proj_element_id
				into 	l_prg_temp_parent,
					l_prj_temp_parent,
					l_prg_dummy_rollup 		-- ###dummy### 		-- l_prg_temp_rollup
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent1
				where 	1=1
				and 	pvt_parent1.element_version_id = PRG_PARENT_NODE.object_id_from1;

				-- l_prg_dummy_task_flag 		-- ###dummy###
				select 	link_task_flag
				into 	l_prg_dummy_task_flag
				from 	pa_proj_elements
				where 	1=1
				and 	proj_element_id = l_prg_dummy_rollup;

				-- l_prg_temp_rollup
				if 	l_prg_dummy_task_flag = 'N'

				then
					l_prg_temp_rollup := l_prg_dummy_rollup;

				else
					/*
					select 	dt_ver1.proj_element_id
					into	l_prg_temp_rollup
					from  	pa_object_relationships dt_rel,
       						pa_proj_element_versions dt_ver1,
       						pa_proj_element_versions dt_ver2
					where 	1=1
					and 	dt_ver1.element_version_id = dt_rel.object_id_from1
					and 	dt_rel.object_type_from = 'PA_TASKS'
					and 	dt_rel.object_type_to = 'PA_TASKS'
					and 	dt_rel.object_id_to1 = dt_ver2.element_version_id
					and     dt_ver2.proj_element_id = l_prg_dummy_rollup;
					*/

					-- Bug 3838523
					select 	dt_ver1.proj_element_id
					into	l_prg_temp_rollup
					from  	pa_object_relationships dt_rel,
       						pa_proj_element_versions dt_ver1
					where 	1=1
					and 	dt_ver1.element_version_id = dt_rel.object_id_from1
					and 	dt_rel.object_type_from = 'PA_TASKS'
					and 	dt_rel.object_type_to = 'PA_TASKS'
					and     dt_rel.object_id_to1 = PRG_PARENT_NODE.object_id_from1;

				end if;

				-- l_prg_temp_sup_emt --
				select 	pvt_parent4.proj_element_id
				into 	l_prg_temp_sup_emt
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent4
				where 	1=1
				and 	pvt_parent4.element_version_id = l_prg_temp_parent;

				-- l_prg_temp_sub_emt --
				select 	pvt_parent5.proj_element_id
				into 	l_prg_temp_sub_emt
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent5
				where 	1=1
				and 	pvt_parent5.element_version_id = PRG_NODE.element_version_id;

				-- l_prg_leaf_flag --
				if 	(
					 l_prg_temp_parent = PRG_NODE.element_version_id
					 or
					 l_prg_leaf_flag_id = 1
					)
				then
					l_prg_leaf_flag := 'Y';
				else
					l_prg_leaf_flag := 'N';
				end if;


				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting PRG node parent -'
							|| ' element_version_id = '
							|| PRG_NODE.element_version_id
							|| ' sup_id = '
							|| l_prg_temp_parent
							|| ' sub_rollup_id = '
							|| l_prg_temp_rollup,
						null,
						g_msg_level_low_detail
						);
				end if;

				-- Insert PRG node's parent --
				insert
				into 	PJI_FP_AGGR_XBS
					(
					struct_type,
					prg_group,
					struct_version_id,
					sup_project_id,
					sup_id,
					sup_emt_id,
					subro_id,
					sub_id,
					sub_emt_id,
					sup_level,
					sub_level,
					sub_rollup_id,
					sub_leaf_flag_id,
					sub_leaf_flag,
					relationship_type,
					status_id,
					worker_id
					)
				values (
					'PRG',					-- structure type
					PRG_NODE.prg_group,			-- prg group
					null,					-- structure version id
					l_prj_temp_parent,			-- parent project id
					l_prg_temp_parent, 			-- parent id
					l_prg_temp_sup_emt,			-- sup emt_id
					PRG_NODE.proj_element_id, 		-- immediate child id
					PRG_NODE.element_version_id, 		-- child id
					l_prg_temp_sub_emt,			-- sub emt_id
					PRG_PARENT_NODE.prg_level,		-- parent level
					PRG_NODE.prg_level, 			-- child level
					l_prg_temp_rollup,			-- child rollup id
					l_prg_leaf_flag_id,			-- child leaf flag id
					l_prg_leaf_flag,			-- child leaf flag
					PRG_PARENT_NODE.relationship_type, 	-- relationship type (new)
					'parent', 				-- status id
					P_WORKER_ID				-- worker id
					);


				-- --------------------------------------------------------
				-- Check for PRG node's children --
				--  Filter nodes to see if the node has children

				FOR PRG_CHILDREN_NODE IN
				(
				 select
				 distinct
					pdt_child.sup_id,
					pdt_child.sub_id,
					pdt_child.sub_leaf_flag_id
				 from 	PJI_FP_AGGR_XBS pdt_child
				 where 	1=1
				 and 	pdt_child.sup_id = PRG_NODE.element_version_id
				 and 	pdt_child.sup_id <> pdt_child.sub_id
				 and	pdt_child.worker_id = P_WORKER_ID
				) LOOP

					-- l_prg_temp_level --
					select 	pdt_child1.sub_level
					into 	l_prg_temp_level
					from 	PJI_FP_AGGR_XBS pdt_child1
					where 	1=1
					and 	pdt_child1.sup_id = PRG_CHILDREN_NODE.sub_id
					and 	pdt_child1.sup_id = pdt_child1.sub_id
					and	pdt_child1.worker_id = P_WORKER_ID;

					-- l_prj_temp_parent --
					select 	pvt_child1.project_id
					into 	l_prj_temp_parent
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child1
					where 	1=1
					and 	pvt_child1.element_version_id = PRG_PARENT_NODE.object_id_from1;

					-- l_prg_temp_sup_emt --
					select 	pvt_child2.proj_element_id
					into 	l_prg_temp_sup_emt
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child2
					where 	1=1
					and 	pvt_child2.element_version_id = l_prg_temp_parent;

					-- l_prg_temp_sub_emt --
					select 	pvt_child3.proj_element_id
					into 	l_prg_temp_sub_emt
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child3
					where 	1=1
					and 	pvt_child3.element_version_id = PRG_CHILDREN_NODE.sub_id;

					-- l_prg_leaf_flag --
					if 	(
						 l_prg_temp_parent = PRG_CHILDREN_NODE.sub_id
						 or
						 PRG_CHILDREN_NODE.sub_leaf_flag_id = 1
						)
					then
						l_prg_leaf_flag := 'Y';
					else
						l_prg_leaf_flag := 'N';
					end if;


					if 	g_pa_debug_mode = 'Y'
					then
						PJI_UTILS.WRITE2LOG(
							'PJI_PJP -     Inserting PRG node child -'
								|| ' sup_id = '
								|| l_prg_temp_parent
								|| ' sub_emt_id = '
								|| l_prg_temp_sub_emt
								|| ' sub_level = '
								|| l_prg_temp_level,
								-- || PRG_CHILDREN_NODE.sup_id,
							null,
							g_msg_level_low_detail
							);
					end if;

					-- Insert PRG node's child --
					insert
					into 	PJI_FP_AGGR_XBS
						(
						struct_type,
						prg_group,
						struct_version_id,
						sup_project_id,
						sup_id,
						sup_emt_id,
						subro_id,
						sub_id,
						sub_emt_id,
						sup_level,
						sub_level,
						sub_rollup_id,
						sub_leaf_flag_id,
						sub_leaf_flag,
						status_id,
						worker_id
						)
					values (
						'PRG',					-- structure type
						PRG_NODE.prg_group,			-- prg group
						null,					-- struct_version_id
						l_prj_temp_parent,			-- parent project id
						l_prg_temp_parent, 			-- parent id
						l_prg_temp_sup_emt,			-- sup emt_id
						PRG_NODE.proj_element_id,	 	-- immediate child id
						PRG_CHILDREN_NODE.sub_id,		-- child id
						l_prg_temp_sub_emt,			-- sub emt_id
						PRG_PARENT_NODE.prg_level,		-- parent level
						l_prg_temp_level, 			-- child level
						null,	 				-- child rollup id
						PRG_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag
						l_prg_leaf_flag, 			-- child leaf flag
						'children',				-- status id
						P_WORKER_ID				-- worker id
						);

				END LOOP; -- FOR PRG_CHILD_NODE

			END LOOP; -- FOR PRG_PARENT_NODE

		END IF; -- if l_prg_level_id <> 1

	-- Call wbs_denorm

	-- -----------------------------------------------------
	-- Do not call wbs_denorm procedures for WBS nodes
	--  that don't exist or call more than once.

	select	count(*)
	into	l_prg_element_version_count
	from	PA_PROJ_ELEMENT_VERSIONS cv
	where	cv.parent_structure_version_id = PRG_NODE.element_version_id
	and	rownum = 1;

	if	(
		 1=1 -- P_EXTRACTION_TYPE = 'FULL'
		 and
		 l_prg_element_version_count > 0
		)
	then

		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -   Calling wbs_denorm - element_version_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;


		wbs_denorm(
			P_WORKER_ID,
			'FULL', -- P_EXTRACTION_TYPE,
			PRG_NODE.element_version_id
			-- PRG_NODE.proj_element_id
			);

	else

		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -   Not calling wbs_denorm, because WBS node does not exist - element_version_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;

	end if;

	END IF; -- prg group is null

	END LOOP; -- FOR PRG_NODE

if (p_extraction_type = 'FULL' or p_extraction_type = 'UPGRADE') then

  update PJI_PJP_PROJ_BATCH_MAP
  set    PJI_PROJECT_STATUS = null
  where  WORKER_ID = p_worker_id and
         PJI_PROJECT_STATUS = 'C';

end if;

-- ------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: prg_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- ------------------------------------------


end prg_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------




-- -----------------------------------------------------------------------

procedure wbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_wbs_version_id	in 	number
	-- P_PRG_SUP_EMT_ID 	IN 	NUMBER, -- ###xbs###
) as

-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***   This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_PROJ_ELEMENT_VERSIONS
--		PA_OBJECT_RELATIONSHIPS
--
--	  Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_XBS
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --

l_wbs_count		number;
l_wbs_temp_parent 	number;
l_wbs_temp_level 	number;
l_wbs_node_count 	number;
l_wbs_leaf_flag_id	number;
l_wbs_leaf_flag 	varchar2(1);

l_wbs_temp_sup_emt 	number;
l_wbs_temp_sub_emt 	number;

l_wbs_test_node		number;

l_struct_emt_id 	number;

l_sharing_code 		varchar2(80); 	-- ###financial###
l_project_id            number;

-- -----------------------------------------------------

begin

-- (WBS node = task)

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: wbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE
			|| ' p_wbs_version_id = '
			|| P_WBS_VERSION_ID,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- l_struct_emt_id -- 			-- ###sup_emt###
select
distinct
	sup_emt_id
into 	l_struct_emt_id
from 	pji_fp_aggr_xbs
where 	1=1
and 	struct_type = 'PRG'
and 	sup_id = P_WBS_VERSION_ID
and 	worker_id = P_WORKER_ID;


-- -----------------------------------------------------
-- l_sharing_code 			-- ###financial###

begin
	select 	projects.structure_sharing_code,projects.project_id
	into 	l_sharing_code,l_project_id
	from 	pa_projects_all projects,
		pa_proj_element_versions versions
	where 	1=1
	and 	projects.project_id = versions.project_id
	and  	versions.object_type = 'PA_STRUCTURES'
	and 	versions.element_version_id = P_WBS_VERSION_ID;
exception
	when no_data_found
	then
		l_sharing_code := 'PJI$NULL';
		l_project_id := -1;
end;

if 	l_sharing_code is null
then
	l_sharing_code := 'PJI$NULL';
end if;


	-- -----------------------------------------------------
	-- Get all WBS nodes from a certain level and from a certain project --

	--  Look only at the data to be processed
	--	1) FULL - All data
	--	2) INCREMENTAL or PARTIAL - Filter data by looking at the logs
	--	table

	FOR WBS_NODE IN
	(
	 select	wvt_nodes.wbs_level,
        wvt_nodes.project_id,
		wvt_nodes.proj_element_id,
		wvt_nodes.element_version_id,
		wvt_nodes.parent_structure_version_id,
		wvt_nodes.financial_task_flag 		-- ###financial###
	 from 	PA_PROJ_ELEMENT_VERSIONS wvt_nodes
	 where 	1=1
	 and	(
		 P_EXTRACTION_TYPE = 'FULL'
		 or
		 P_EXTRACTION_TYPE = 'UPGRADE'
		)
	 and 	wvt_nodes.object_type = 'PA_TASKS'
	  and 	exists 			 		-- ###dummy###
		(
		 select 1
		 from 	pa_proj_elements ele
		 where 	link_task_flag = 'N'
		    and ele.project_id = l_project_id
            and ele.proj_element_id = wvt_nodes.proj_element_id
            and rownum <= 1
		)
	 and 	wvt_nodes.parent_structure_version_id = P_WBS_VERSION_ID
     and    wvt_nodes.wbs_level is not null
     ORDER BY wbs_level DESC
	) LOOP


		-- -----------------------------------------------------
		-- Check WBS node self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf

		select 	count(*)
		into 	l_wbs_node_count
		from 	PJI_FP_AGGR_XBS wdt_count
		where 	wdt_count.sup_id = WBS_NODE.element_version_id
		and	wdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;

		-- l_wbs_leaf_flag_id --
		if 	l_wbs_node_count > 0
		then
			l_wbs_leaf_flag_id := 0;
		else
			l_wbs_leaf_flag_id := 1;
		end if;

		-- l_wbs_leaf_flag -- (business rule)
		if 	(
			 WBS_NODE.proj_element_id = WBS_NODE.proj_element_id
			 or
			 l_wbs_leaf_flag_id = 1
			)
		then
			l_wbs_leaf_flag := 'Y';
		else
			l_wbs_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting WBS node self - element_version_id = '
					|| WBS_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;

		-- Insert WBS node self --
		insert
		into	PJI_FP_AGGR_XBS
			(
			struct_type,
			prg_group,
			struct_emt_id,
			struct_version_id,
			sup_project_id,
			sup_id,
			sup_emt_id,
			subro_id,
			sub_id,
			sub_emt_id,
			sup_level,
			sub_level,
			sub_rollup_id,
			sub_leaf_flag_id,
			sub_leaf_flag,
			relationship_type,
			status_id,
			worker_id
			)
		values (
			'WBS',				-- structure type
			null,				-- prg group
			l_struct_emt_id,		-- structure element id
			P_WBS_VERSION_ID, 		-- structure version id
			WBS_NODE.project_id,		-- parent project id
			WBS_NODE.element_version_id, 	-- parent id
			WBS_NODE.proj_element_id,	-- sup emt id
			null, 				-- immediate child id
			WBS_NODE.element_version_id, 	-- child id
			WBS_NODE.proj_element_id,	-- sub emt_id
			WBS_NODE.wbs_level, 		-- parent level
			WBS_NODE.wbs_level, 		-- child level
			null,				-- child rollup id
			l_wbs_leaf_flag_id,	 	-- child leaf flag id
			l_wbs_leaf_flag,	 	-- child leaf flag
			decode(l_sharing_code,
				'SHARE_FULL',       'WF',
				'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
				'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
							-- sub financial task flag 	-- ###financial###
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);

		-- --------------------------------------------------------
		-- Check for WBS node's parent --
		--  Check only if the node is not a top most node (level = 1)

		IF 	WBS_NODE.wbs_level <> 1
		THEN


		-- -----------------------------------------------------
		-- Filter WBS nodes to those that have one and only one parent
		--  if not, the node is invalid.  Cases with no parents or two parents
		--  have appeared with corrupted data
		--  Removed the call (was there for M QA builds) as disscussed with sadiq

			-- l_wbs_temp_parent --
			select 	wrt_parent.object_id_from1
			into 	l_wbs_temp_parent
			from 	PA_OBJECT_RELATIONSHIPS wrt_parent
			where 	1=1
			and 	wrt_parent.object_id_to1 = WBS_NODE.element_version_id
			and 	wrt_parent.object_type_from = 'PA_TASKS'
			and 	wrt_parent.object_type_to = 'PA_TASKS'
			and 	wrt_parent.relationship_type = 'S';

			-- l_wbs_temp_sup_emt --
			select 	wvt_parent1.proj_element_id
			into 	l_wbs_temp_sup_emt
			from 	PA_PROJ_ELEMENT_VERSIONS wvt_parent1
			where 	1=1
			and 	wvt_parent1.element_version_id = l_wbs_temp_parent;

			-- l_wbs_temp_sub_emt --
			select 	wvt_parent2.proj_element_id
			into 	l_wbs_temp_sub_emt
			from 	PA_PROJ_ELEMENT_VERSIONS wvt_parent2
			where 	1=1
			and 	wvt_parent2.element_version_id = WBS_NODE.element_version_id;

			-- l_wbs_leaf_flag --
			if 	(
				 l_wbs_temp_sup_emt = l_wbs_temp_sub_emt
				 or
				 l_wbs_leaf_flag_id = 1
				)
			then
				l_wbs_leaf_flag := 'Y';
			else
				l_wbs_leaf_flag := 'N';
			end if;


			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -     Inserting WBS node parent - l_wbs_temp_parent = '
						|| l_wbs_temp_parent,
					null,
					g_msg_level_low_detail
					);
			end if;


			-- Insert WBS node's parent --
			insert
			into 	PJI_FP_AGGR_XBS
				(
				struct_type,
				prg_group,
				struct_emt_id,
				struct_version_id,
				sup_project_id,
				sup_id,
				sup_emt_id,
				subro_id,
				sub_id,
				sub_emt_id,
				sup_level,
				sub_level,
				sub_rollup_id,
				sub_leaf_flag_id,
				sub_leaf_flag,
				relationship_type,
				status_id,
				worker_id
				)
			values (
				'WBS',				-- structure type
				null,				-- prg group
				l_struct_emt_id,		-- structure element id
				P_WBS_VERSION_ID, 		-- structure version id
				WBS_NODE.project_id,		-- parent project id
				l_wbs_temp_parent, 		-- parent id
				l_wbs_temp_sup_emt,		-- sup_emt_id
				WBS_NODE.proj_element_id, 	-- immediate child id
				WBS_NODE.element_version_id, 	-- child id
				l_wbs_temp_sub_emt,		-- sub_emt_id
				WBS_NODE.wbs_level -1, 		-- parent level
				WBS_NODE.wbs_level, 		-- child level
				null,				-- child rollup id
				l_wbs_leaf_flag_id,	 	-- child leaf flag id
				l_wbs_leaf_flag,	 	-- child leaf flag
				decode(l_sharing_code,
					'SHARE_FULL',       'WF',
					'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
					'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
								-- sub financial task flag 	-- ###financial###
				'parent',			-- status id
				P_WORKER_ID			-- worker id
				);

			-- --------------------------------------------------------
			-- Check for WBS node's children --
			--  Filter nodes to see if the node has children

			FOR WBS_CHIlDREN_NODE IN
			(
			select 	wdt_child.sup_id,
				wdt_child.sub_id,
				wdt_child.sub_leaf_flag_id,
				wdt_child.relationship_type
			from 	PJI_FP_AGGR_XBS wdt_child
			where 	1=1
			and 	wdt_child.sup_id = WBS_NODE.element_version_id
			and 	wdt_child.sup_id <> wdt_child.sub_id
			and	wdt_child.worker_id = P_WORKER_ID
			) LOOP

				-- l_wbs_temp_level --
				select 	wdt_child1.sub_level
				into 	l_wbs_temp_level
				from 	PJI_FP_AGGR_XBS wdt_child1
				where 	1=1
				and 	wdt_child1.sup_id = WBS_CHILDREN_NODE.sub_id
				and 	wdt_child1.sup_id = wdt_child1.sub_id
				and	wdt_child1.worker_id = P_WORKER_ID;

				-- l_wbs_temp_sup_emt --
				select 	wvt_child1.proj_element_id
				into 	l_wbs_temp_sup_emt
				from 	PA_PROJ_ELEMENT_VERSIONS wvt_child1
				where 	1=1
				and 	wvt_child1.element_version_id = l_wbs_temp_parent;

				-- l_wbs_temp_sub_emt --
				select 	wvt_child2.proj_element_id
				into 	l_wbs_temp_sub_emt
				from 	PA_PROJ_ELEMENT_VERSIONS wvt_child2
				where 	1=1
				and 	wvt_child2.element_version_id = WBS_CHILDREN_NODE.sub_id;

				-- l_wbs_leaf_flag --
				if 	(
					 l_wbs_temp_sup_emt = l_wbs_temp_sub_emt
					 or
					 WBS_CHILDREN_NODE.sub_leaf_flag_id = 1
					)
				then
					l_wbs_leaf_flag := 'Y';
				else
					l_wbs_leaf_flag := 'N';
				end if;


				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting WBS node child - sup_id = '
							|| WBS_CHILDREN_NODE.sup_id,
						null,
						g_msg_level_low_detail
						);
				end if;

				-- Insert WBS node's child --
				insert
				into 	PJI_FP_AGGR_XBS
					(
					struct_type,
					prg_group,
					struct_emt_id,
					struct_version_id,
					sup_project_id,
					sup_id,
					sup_emt_id,
					subro_id,
					sub_id,
					sub_emt_id,
					sup_level,
					sub_level,
					sub_rollup_id,
					sub_leaf_flag_id,
					sub_leaf_flag,
					relationship_type,
					status_id,
					worker_id
					)
				values (
					'WBS',					-- structure type
					null,					-- prg group
					l_struct_emt_id,			-- structure element id
					P_WBS_VERSION_ID, 			-- structure version id
					WBS_NODE.project_id,			-- parent project id
					l_wbs_temp_parent, 			-- parent id
					l_wbs_temp_sup_emt,			-- sup emt_id
					WBS_NODE.proj_element_id, 		-- immediate child id
					WBS_CHILDREN_NODE.sub_id, 		-- child id
					l_wbs_temp_sub_emt,			-- sub emt_id
					WBS_NODE.wbs_level - 1,			-- parent level
					l_wbs_temp_level, 			-- child level
					null, 					-- child rollup id
					WBS_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag id
					l_wbs_leaf_flag, 			-- child leaf flag
					decode(l_sharing_code,
						'SHARE_FULL',       'WF',
						'SHARE_PARTIAL',    decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'WF', 'LW'),
						'SPLIT_MAPPING',    decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW'),
						'SPLIT_NO_MAPPING', decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW'),
						'PJI$NULL',         decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW')),
										-- sub financial task flag 	-- ###financial###
					'children',				-- status id
					P_WORKER_ID				-- worker id
					);

			END LOOP; -- FOR WBS_CHIlDREN_NODE

	ELSE

		-- l_wbs_leaf_flag -- (business rule)
		if 	(
			 P_WBS_VERSION_ID = WBS_NODE.element_version_id
			 or
			 l_wbs_leaf_flag_id = 1
			)
		then
			l_wbs_leaf_flag := 'Y';
		else
			l_wbs_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting XBS node self - sup_id = '
					|| P_WBS_VERSION_ID,
				null,
 				g_msg_level_low_detail
				);
		end if;

		-- Insert XBS node --
		insert
		into	PJI_FP_AGGR_XBS
			(
			struct_type,
			prg_group,
			struct_version_id,
			sup_project_id,
			sup_id,
			sup_emt_id,
			subro_id,
			sub_id,
			sub_emt_id,
			sup_level,
			sub_level,
			sub_rollup_id,
			sub_leaf_flag_id,
			sub_leaf_flag,
			relationship_type,
			status_id,
			worker_id
			)
		values (
			'XBS',				-- structure type
			null,				-- prg group
			P_WBS_VERSION_ID, 		-- structure version id
			WBS_NODE.project_id,		-- parent project id
			P_WBS_VERSION_ID, 		-- parent id
			l_struct_emt_id,		-- sup emt id
			null, 				-- immediate child id
			WBS_NODE.element_version_id, 	-- child id
			WBS_NODE.proj_element_id,	-- sub emt_id
			0,		 		-- parent level (l_wbs_level_id)
			WBS_NODE.wbs_level, 		-- child level
			null,				-- child rollup id
			l_wbs_leaf_flag_id,		-- child leaf flag id
			l_wbs_leaf_flag,	 	-- child leaf flag
			decode(l_sharing_code,
				'SHARE_FULL',       'WF',
				'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
				'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
							-- sub financial task flag 	-- ###financial###
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);


	END IF; -- IF l_wbs_level_id <> 1

	END LOOP; -- FOR WBS_NODE


-- ----------------------------------------------

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: wbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------

end wbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure prg_denorm_online(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_prg_group_id	 	in 	number,
	p_wbs_version_id 	in 	number
) as

-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_PROJ_ELEMENT_VERSIONS
--		PA_OBJECT_RELATIONSHIPS
--
--	 Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_XBS
--
--	 When P_EXTRACTION_TYPE equals 'FULL', this API calls the following
--	procedure:
--		wbs_denorm
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --

l_prg_level_id 			number;
l_prg_temp_parent 		number;
l_prg_temp_level 		number;
l_prg_node_count 		number;
l_prg_leaf_flag_id 		number;
l_prg_leaf_flag 		varchar2(1);

l_prj_temp_parent 		number;
l_prg_temp_rollup 		number;
l_prg_temp_sup_emt 		number;
l_prg_temp_sub_emt 		number;

l_prg_element_version_count	number;

l_prg_dummy_rollup 		number;
l_prg_dummy_task_flag 		varchar2(1);

-- -----------------------------------------------------

begin

-- (PRG node = program)

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: prg_denorm_online -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE
			|| ' p_prg_group_id = '
			|| p_prg_group_id
			|| ' p_wbs_version_id = '
			|| p_wbs_version_id,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------

-- Get deepest PRG node level --

--  Look only at the data to be processed

if 	p_prg_group_id is not null
then

	select	max(pvt_level.prg_level)
	into 	l_prg_level_id
	from 	PA_PROJ_ELEMENT_VERSIONS pvt_level
	where	1=1
	and 	pvt_level.object_type = 'PA_STRUCTURES'
	and     pvt_level.prg_group IS NOT NULL   /*	4904076 */
	and 	prg_group = p_prg_group_id;

else

	l_prg_level_id := 1; 	-- and 	element_version_id = p_wbs_version_id;

end if;

-- --------------------------------------------------------
--  PRG nodes with no prg_level (is null) are valid.  Therefore,
-- treat these nodes as level 1.

if	l_prg_level_id is null
then
	l_prg_level_id := 1;
end if;

-- --------------------------------------------------------

LOOP

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   PRG Inserts - l_prg_level_id = '
				|| l_prg_level_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	-- --------------------------------------------------------
	-- Get all PRG nodes from a certain level --

	--  Look only at the data to be processed


	FOR PRG_NODE IN
	(
	 select
	 distinct
		pvt_nodes1.project_id,
		pvt_nodes1.proj_element_id,
		pvt_nodes1.element_version_id,
		pvt_nodes1.parent_structure_version_id,
		pvt_nodes1.prg_group,
	        pvt_nodes1.prg_level               /*4625702*/
	 from 	PA_PROJ_ELEMENT_VERSIONS pvt_nodes1
	 where 	1=1
	 and 	pvt_nodes1.object_type = 'PA_STRUCTURES'
	 and 	pvt_nodes1.element_version_id = p_wbs_version_id
	) LOOP


	IF 	l_prg_level_id > 1  		-- ###prg_group_is_null###
		and
		PRG_NODE.prg_group is null

	THEN
		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP - PRG Group is null Data Bug - element_version_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_data_bug
				);
		end if;
	ELSE

		-- --------------------------------------------------------
		-- Check program self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf

		select 	count(*)
		into 	l_prg_node_count
		from 	PJI_FP_AGGR_XBS_T pdt_count
		where 	1=1
		and	pdt_count.sup_id = PRG_NODE.element_version_id
		and	pdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;

		-- l_prg_leaf_flag_id --
		if 	l_prg_node_count > 0
		then
			l_prg_leaf_flag_id := 0;
		else
			l_prg_leaf_flag_id := 1;
		end if;

		-- l_prg_leaf_flag -- (business rule)
		if 	(
			 PRG_NODE.element_version_id = PRG_NODE.element_version_id
			 or
			 l_prg_leaf_flag_id = 1
			)
		then
			l_prg_leaf_flag := 'Y';
		else
			l_prg_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting PRG node self - sup_id = '
					|| PRG_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;


		-- Insert PRG node self --
		insert
		into 	PJI_FP_AGGR_XBS_T
			(
			struct_type,
			prg_group,
			struct_version_id,
			sup_project_id,
			sup_id,
			sup_emt_id,
			subro_id,
			sub_id,
			sub_emt_id,
			sup_level,
			sub_level,
			sub_rollup_id,
			sub_leaf_flag_id,
			sub_leaf_flag,
			status_id,
			worker_id
			)
		values (
			'PRG', 				-- structure type
			PRG_NODE.prg_group,		-- prg group
			null, 				-- structure version id
			PRG_NODE.project_id, 		-- parent project id
			PRG_NODE.element_version_id, 	-- parent id
			PRG_NODE.proj_element_id,	-- sup emt id
			null,	 			-- immediate child id
			PRG_NODE.element_version_id, 	-- child id
			PRG_NODE.proj_element_id,	-- sub emt_id
			nvl(PRG_NODE.prg_level,1) ,     -- 4625702 l_prg_level_id, 		-- parent level
			nvl(PRG_NODE.prg_level,1) ,     -- 4625702 l_prg_level_id, 		-- child level
			PRG_NODE.proj_element_id,	-- child rollup id
			l_prg_leaf_flag_id,		-- child leaf flag id
			l_prg_leaf_flag,		-- child leaf flag
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);


		-- --------------------------------------------------------
		-- Check for PRG node's parents --
		--  Check only if the node is not a top most node (level = 1)

		IF 	l_prg_level_id <> 1

		THEN

			FOR PRG_PARENT_NODE IN
			(
			 select
			 distinct
				prt_parent.object_id_from1,
				prt_parent.relationship_type,
				ver.prg_level
			 from 	PA_OBJECT_RELATIONSHIPS prt_parent,
				PA_PROJ_ELEMENT_VERSIONS ver
			 where 	1=1
			 and 	prt_parent.object_id_to1 = PRG_NODE.element_version_id
			 and 	prt_parent.object_type_from = 'PA_TASKS'
			 and 	prt_parent.object_type_to = 'PA_STRUCTURES'
			 and 	(
				 prt_parent.relationship_type = 'LF'
				 or
				 prt_parent.relationship_type = 'LW'
				)
			 and 	ver.element_version_id = prt_parent.object_id_from1
			) LOOP

				-- l_prg_temp_parent --
				-- l_prj_temp_parent --
				-- l_prg_dummy_rollup --
				select	pvt_parent1.parent_structure_version_id,
					pvt_parent1.project_id,
					pvt_parent1.proj_element_id
				into 	l_prg_temp_parent,
					l_prj_temp_parent,
					l_prg_dummy_rollup 		-- ###dummy### 		-- l_prg_temp_rollup
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent1
				where 	1=1
				and 	pvt_parent1.element_version_id = PRG_PARENT_NODE.object_id_from1;

				-- l_prg_dummy_task_flag 		-- ###dummy###
				select 	link_task_flag
				into 	l_prg_dummy_task_flag
				from 	pa_proj_elements
				where 	1=1
				and 	proj_element_id = l_prg_dummy_rollup;

				-- l_prg_temp_rollup
				if 	l_prg_dummy_task_flag = 'N'

				then
					l_prg_temp_rollup := l_prg_dummy_rollup;

				else
					select 	dt_ver1.proj_element_id
					into	l_prg_temp_rollup
					from  	pa_object_relationships dt_rel,
       						pa_proj_element_versions dt_ver1
       						/* commented for bug 3838523 pa_proj_element_versions dt_ver2*/
					where 	1=1
					and 	dt_ver1.element_version_id = dt_rel.object_id_from1
					and 	dt_rel.object_type_from = 'PA_TASKS'
					and 	dt_rel.object_type_to = 'PA_TASKS'
					and     dt_rel.object_id_to1 = PRG_PARENT_NODE.object_id_from1;

				/*	Commented for bug 3838523 and added above line
				        and 	dt_rel.object_id_to1 = dt_ver2.element_version_id
					and     dt_ver2.proj_element_id = l_prg_dummy_rollup; */
				end if;

				-- l_prg_temp_sup_emt --
				select 	pvt_parent4.proj_element_id
				into 	l_prg_temp_sup_emt
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent4
				where 	1=1
				and 	pvt_parent4.element_version_id = l_prg_temp_parent;

				-- l_prg_temp_sub_emt --
				select 	pvt_parent5.proj_element_id
				into 	l_prg_temp_sub_emt
				from 	PA_PROJ_ELEMENT_VERSIONS pvt_parent5
				where 	1=1
				and 	pvt_parent5.element_version_id = PRG_NODE.element_version_id;

				-- l_prg_leaf_flag --
				if 	(
					 l_prg_temp_parent = PRG_NODE.element_version_id
					 or
					 l_prg_leaf_flag_id = 1
					)
				then
					l_prg_leaf_flag := 'Y';
				else
					l_prg_leaf_flag := 'N';
				end if;


				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting PRG node parent -'
							|| ' element_version_id = '
							|| PRG_NODE.element_version_id
							|| ' sup_id = '
							|| l_prg_temp_parent
							|| ' sub_rollup_id = '
							|| l_prg_temp_rollup,
						null,
						g_msg_level_low_detail
						);
				end if;


				-- Insert PRG node's parent --
				insert
				into 	PJI_FP_AGGR_XBS_T
					(
					struct_type,
					prg_group,
					struct_version_id,
					sup_project_id,
					sup_id,
					sup_emt_id,
					subro_id,
					sub_id,
					sub_emt_id,
					sup_level,
					sub_level,
					sub_rollup_id,
					sub_leaf_flag_id,
					sub_leaf_flag,
					relationship_type,
					status_id,
					worker_id
					)
				values (
					'PRG',					-- structure type
					PRG_NODE.prg_group,			-- prg group
					null,					-- structure version id
					l_prj_temp_parent,			-- parent project id
					l_prg_temp_parent, 			-- parent id
					l_prg_temp_sup_emt,			-- sup emt_id
					PRG_NODE.proj_element_id, 		-- immediate child id
					PRG_NODE.element_version_id, 		-- child id
					l_prg_temp_sub_emt,			-- sub emt_id
					PRG_PARENT_NODE.prg_level,		-- parent level
					l_prg_level_id, 			-- child level
					l_prg_temp_rollup,			-- child rollup id
					l_prg_leaf_flag_id,			-- child leaf flag id
					l_prg_leaf_flag,			-- child leaf flag
					PRG_PARENT_NODE.relationship_type, 	-- relationship type (new)
					'parent', 				-- status id
					P_WORKER_ID				-- worker id
					);


				-- --------------------------------------------------------
				-- Check for PRG node's children --
				--  Filter nodes to see if the node has children

				FOR PRG_CHILDREN_NODE IN
				(
				 select
				 distinct
					pdt_child.sup_id,
					pdt_child.sub_id,
					pdt_child.sub_leaf_flag_id
				 from 	PJI_FP_AGGR_XBS_T pdt_child
				 where 	1=1
				 and 	pdt_child.sup_id = PRG_NODE.element_version_id
				 and 	pdt_child.sup_id <> pdt_child.sub_id
				 and	pdt_child.worker_id = P_WORKER_ID
				) LOOP

					-- l_prg_temp_level --
					select 	pdt_child1.sub_level
					into 	l_prg_temp_level
					from 	PJI_FP_AGGR_XBS_T pdt_child1
					where 	1=1
					--and 	pdt_child1.struct_type = 'PRG'
					and 	pdt_child1.sup_id = PRG_CHILDREN_NODE.sub_id
					and 	pdt_child1.sub_id = PRG_CHILDREN_NODE.sub_id
					and	pdt_child1.worker_id = P_WORKER_ID;

					-- l_prj_temp_parent --
					select 	pvt_child1.project_id
					into 	l_prj_temp_parent
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child1
					where 	1=1
					and 	pvt_child1.element_version_id = PRG_PARENT_NODE.object_id_from1;

					-- l_prg_temp_sup_emt --
					select 	pvt_child2.proj_element_id
					into 	l_prg_temp_sup_emt
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child2
					where 	1=1
					and 	pvt_child2.element_version_id = l_prg_temp_parent;

					-- l_prg_temp_sub_emt --
					select 	pvt_child3.proj_element_id
					into 	l_prg_temp_sub_emt
					from 	PA_PROJ_ELEMENT_VERSIONS pvt_child3
					where 	1=1
					and 	pvt_child3.element_version_id = PRG_CHILDREN_NODE.sub_id;

					-- l_prg_leaf_flag --
					if 	(
						 l_prg_temp_parent = PRG_CHILDREN_NODE.sub_id
						 or
						 PRG_CHILDREN_NODE.sub_leaf_flag_id = 1
						)
					then
						l_prg_leaf_flag := 'Y';
					else
						l_prg_leaf_flag := 'N';
					end if;


					if 	g_pa_debug_mode = 'Y'
					then
						PJI_UTILS.WRITE2LOG(
							'PJI_PJP -     Inserting PRG node child -'
								|| ' element_version_id = '
								|| PRG_NODE.element_version_id
								|| ' sup_id = '
								|| l_prg_temp_parent
								|| ' sub_emt_id = '
								|| l_prg_temp_sub_emt
								|| ' sub_level = '
								|| l_prg_temp_level,
								-- || PRG_CHILDREN_NODE.sup_id,
							null,
							g_msg_level_low_detail
							);
					end if;

					-- Insert PRG node's child --
					insert
					into 	PJI_FP_AGGR_XBS_T
						(
						struct_type,
						prg_group,
						struct_version_id,
						sup_project_id,
						sup_id,
						sup_emt_id,
						subro_id,
						sub_id,
						sub_emt_id,
						sup_level,
						sub_level,
						sub_rollup_id,
						sub_leaf_flag_id,
						sub_leaf_flag,
						status_id,
						worker_id
						)
					values (
						'PRG',					-- structure type
						PRG_NODE.prg_group,			-- prg group
						null,					-- struct_version_id
						l_prj_temp_parent,			-- parent project id
						l_prg_temp_parent, 			-- parent id
						l_prg_temp_sup_emt,			-- sup emt id
						PRG_NODE.proj_element_id,	 	-- immediate child id
						PRG_CHILDREN_NODE.sub_id,		-- child id
						l_prg_temp_sub_emt,			-- sub emt id
						PRG_PARENT_NODE.prg_level,		-- parent level
						l_prg_temp_level, 			-- child level
						null,	 				-- child rollup id
						PRG_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag
						l_prg_leaf_flag, 			-- child leaf flag
						'children',				-- status id
						P_WORKER_ID				-- worker id
						);

				END LOOP; -- FOR PRG_CHILD_NODE

			END LOOP; -- FOR PRG_PARENT_NODE

		END IF; -- if l_prg_level_id <> 1

	-- Call wbs_denorm

	-- #change: do not call wbs_denorm in online version

	END IF; -- prg group is null

	END LOOP; -- FOR PRG_NODE

	-- Decrease PRG node level --

	l_prg_level_id := l_prg_level_id - 1;
	exit when l_prg_level_id = 0;

END LOOP; -- PRG_LEVEL

-- -----------------------------------------

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: prg_denorm_online',
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------

end prg_denorm_online;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure wbs_denorm_online(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2,
	p_wbs_version_id 	in 	number
	-- P_PRG_SUP_EMT_ID 	IN 	NUMBER, -- ###xbs###
) as

-- -----------------------------------------------------------------------
--
--  History
--  31-MAR-2004	aartola	Created
--
--
--  ***   This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_PROJ_ELEMENT_VERSIONS
--		PA_OBJECT_RELATIONSHIPS
--
--	  Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_XBS_T
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --

l_wbs_count		number;
l_wbs_level_id 		number;
l_wbs_temp_parent 	number;
l_wbs_temp_level 	number;
l_wbs_node_count 	number;
l_wbs_leaf_flag_id	number;
l_wbs_leaf_flag 	varchar2(1);

l_wbs_temp_sup_emt 	number;
l_wbs_temp_sub_emt 	number;

l_wbs_test_node		number;

l_struct_emt_id 	number;
l_struct_emt_id_count 	number;

l_sharing_code 		varchar2(80); 	-- ###financial###

-- -----------------------------------------------------

begin

-- (WBS node = task)

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin wbs_denorm_online -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE
			|| ' p_wbs_version_id = '
			|| P_WBS_VERSION_ID,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- get a node count

select	count(*)
into 	l_wbs_count
from 	PA_PROJ_ELEMENT_VERSIONS wvt_count
where 	1=1
and 	wvt_count.object_type = 'PA_TASKS'
and 	wvt_count.proj_element_id in 		-- ###dummy###
	(
	 select proj_element_id
	 from 	pa_proj_elements
	 where 	link_task_flag = 'N'
	)
and 	wvt_count.parent_structure_version_id = P_WBS_VERSION_ID
and	rownum = 1;

-- -----------------------------------------------------

IF 	l_wbs_count = 0

THEN

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   Wbs node as task does not exist - p_wbs_version_id = '
				|| P_WBS_VERSION_ID,
			null,
			g_msg_level_low_detail
			);
	end if;

ELSE


-- -----------------------------------------------------
-- Get deepest WBS node level --
--  Look only at the data to be processed
--	1) ONLINE

select	max(wvt_level.wbs_level)
into 	l_wbs_level_id
from 	PA_PROJ_ELEMENT_VERSIONS wvt_level
where 	1=1
and 	wvt_level.object_type = 'PA_TASKS'
and 	wvt_level.proj_element_id in 		-- ###dummy###
	(
	 select proj_element_id
	 from 	pa_proj_elements
	 where 	link_task_flag = 'N'
	)
and 	wvt_level.parent_structure_version_id = P_WBS_VERSION_ID;


-- --------------------------------------------------------
-- WBS nodes with no level (is null) are INVALID.

if	l_wbs_level_id is null		-- ###level_is_null###
then

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   Level is null Data Corruption - p_wbs_version_id = '
				|| P_WBS_VERSION_ID,
			null,
			g_msg_level_data_corruption
			);
	end if;

	l_wbs_level_id := 1;
end if;

-- -----------------------------------------------------
-- l_struct_emt_id -- 			-- ###sup_emt###

select
distinct
	sup_emt_id
into 	l_struct_emt_id
from 	pji_fp_aggr_xbs_t
where 	1=1
and 	struct_type = 'PRG'
and 	sup_id = P_WBS_VERSION_ID
and 	worker_id = P_WORKER_ID;


-- -----------------------------------------------------
-- l_sharing_code

begin
	select 	structure_sharing_code
	into 	l_sharing_code
	from 	pa_projects_all projects,
		pa_proj_element_versions versions
	where 	1=1
	and 	projects.project_id = versions.project_id
	and  	versions.object_type = 'PA_STRUCTURES'
	and 	versions.element_version_id = P_WBS_VERSION_ID;
exception
	when no_data_found
	then
		l_sharing_code := 'PJI$NULL';
end;

if 	l_sharing_code is null
then
	l_sharing_code := 'PJI$NULL';
end if;


-- -----------------------------------------------------

LOOP

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   WBS Inserts - l_wbs_level_id = '
				|| l_wbs_level_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	-- -----------------------------------------------------
	-- Get all WBS nodes from a certain level and from a certain project --
	--  Look only at the data to be processed
	--	1) ONLINE

	FOR WBS_NODE IN
	(
	 select	wvt_nodes.project_id,
		wvt_nodes.proj_element_id,
		wvt_nodes.element_version_id,
		wvt_nodes.parent_structure_version_id,
		wvt_nodes.financial_task_flag 		-- ###financial###
	 from 	PA_PROJ_ELEMENT_VERSIONS wvt_nodes
	 where 	1=1
	 and 	wvt_nodes.object_type = 'PA_TASKS'
	 and 	wvt_nodes.proj_element_id in 		-- ###dummy###
		(
		 select proj_element_id
		 from 	pa_proj_elements
		 where 	link_task_flag = 'N'
		)
	 and 	wvt_nodes.parent_structure_version_id = P_WBS_VERSION_ID
	 and 	wvt_nodes.wbs_level = l_wbs_level_id
	) LOOP


		-- -----------------------------------------------------
		-- Check WBS node self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf

		select 	count(*)
		into 	l_wbs_node_count
		from 	PJI_FP_AGGR_XBS_T wdt_count
		where 	wdt_count.sup_id = WBS_NODE.element_version_id
		and	wdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;

		-- l_wbs_leaf_flag_id --
		if 	l_wbs_node_count > 0
		then
			l_wbs_leaf_flag_id := 0;
		else
			l_wbs_leaf_flag_id := 1;
		end if;

		-- l_wbs_leaf_flag -- (business rule)
		if 	(
			 WBS_NODE.proj_element_id = WBS_NODE.proj_element_id
			 or
			 l_wbs_leaf_flag_id = 1
			)
		then
			l_wbs_leaf_flag := 'Y';
		else
			l_wbs_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting WBS node self - element_version_id = '
					|| WBS_NODE.element_version_id,
				null,
				g_msg_level_low_detail
				);
		end if;


		-- Insert WBS node self --
		insert
		into	PJI_FP_AGGR_XBS_T
			(
			struct_type,
			prg_group,
			struct_emt_id,
			struct_version_id,
			sup_project_id,
			sup_id,
			sup_emt_id,
			subro_id,
			sub_id,
			sub_emt_id,
			sup_level,
			sub_level,
			sub_rollup_id,
			sub_leaf_flag_id,
			sub_leaf_flag,
			relationship_type,
			status_id,
			worker_id
			)
		values (
			'WBS',				-- structure type
			null,				-- prg group
			l_struct_emt_id, 		-- structure element id
			P_WBS_VERSION_ID, 		-- structure version id
			WBS_NODE.project_id,		-- parent project id
			WBS_NODE.element_version_id, 	-- parent id
			WBS_NODE.proj_element_id,	-- sup emt_id
			null, 				-- immediate child id
			WBS_NODE.element_version_id, 	-- child id
			WBS_NODE.proj_element_id,	-- sub emt_id
			l_wbs_level_id, 		-- parent level
			l_wbs_level_id, 		-- child level
			null,				-- child rollup id
			l_wbs_leaf_flag_id,	 	-- child leaf flag id
			l_wbs_leaf_flag,	 	-- child leaf flag
			decode(l_sharing_code,
				'SHARE_FULL',       'WF',
				'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
				'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
				'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
							-- sub financial task flag 	-- ###financial###
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);

		-- --------------------------------------------------------
		-- Check for WBS node's parent --
		--  Check only if the node is not a top most node (level = 1)

		IF 	l_wbs_level_id <> 1
		THEN


		-- -----------------------------------------------------
		-- Filter WBS nodes to those that have one and only one parent
		--  if not, the node is invalied.  Cases with no parents or two parents
		--  have appeared with corrupted data

		select	count(*)			-- ###parent_is_one###
		into	l_wbs_test_node
		from	PA_OBJECT_RELATIONSHIPS rel,
			(
			 select	element_version_id
			 from	PA_PROJ_ELEMENT_VERSIONS
			 where 	1=1
			 and 	WBS_LEVEL > 1
			 and	element_version_id = WBS_NODE.element_version_id
			) ver
		where	1=1
		and	rel.OBJECT_TYPE_FROM = 'PA_TASKS'
		and 	rel.OBJECT_TYPE_TO = 'PA_TASKS'
		and	rel.RELATIONSHIP_TYPE = 'S'
		and	ver.ELEMENT_VERSION_ID = rel.OBJECT_ID_to1 (+);

		IF	l_wbs_test_node = 1

		THEN

			--
			-- Discrepancy between prg_denorm and wbs_denorm
			--  As opposed to PRG nodes, WBS nodes cannot have more that one parent
			--

			-- l_wbs_temp_parent --
			select 	wrt_parent.object_id_from1
			into 	l_wbs_temp_parent
			from 	PA_OBJECT_RELATIONSHIPS wrt_parent
			where 	1=1
			and 	wrt_parent.object_id_to1 = WBS_NODE.element_version_id
			and 	wrt_parent.object_type_from = 'PA_TASKS'
			and 	wrt_parent.object_type_to = 'PA_TASKS'
			and 	wrt_parent.relationship_type = 'S';

			-- l_wbs_temp_sup_emt --
			select 	wvt_parent1.proj_element_id
			into 	l_wbs_temp_sup_emt
			from 	PA_PROJ_ELEMENT_VERSIONS wvt_parent1
			where 	1=1
			and 	wvt_parent1.element_version_id = l_wbs_temp_parent;

			-- l_wbs_temp_sub_emt --
			select 	wvt_parent2.proj_element_id
			into 	l_wbs_temp_sub_emt
			from 	PA_PROJ_ELEMENT_VERSIONS wvt_parent2
			where 	1=1
			and 	wvt_parent2.element_version_id = WBS_NODE.element_version_id;

			-- l_wbs_leaf_flag --
			if 	(
				 l_wbs_temp_sup_emt = l_wbs_temp_sub_emt
				 or
				 l_wbs_leaf_flag_id = 1
				)
			then
				l_wbs_leaf_flag := 'Y';
			else
				l_wbs_leaf_flag := 'N';
			end if;


			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -     Inserting WBS node parent - l_wbs_temp_parent = '
						|| l_wbs_temp_parent,
					null,
					g_msg_level_low_detail
					);
			end if;

			-- Insert WBS node's parent --
			insert
			into 	PJI_FP_AGGR_XBS_T
				(
				struct_type,
				prg_group,
				struct_emt_id,
				struct_version_id,
				sup_project_id,
				sup_id,
				sup_emt_id,
				subro_id,
				sub_id,
				sub_emt_id,
				sup_level,
				sub_level,
				sub_rollup_id,
				sub_leaf_flag_id,
				sub_leaf_flag,
				relationship_type,
				status_id,
				worker_id
				)
			values (
				'WBS',				-- structure type
				null,				-- prg group
				l_struct_emt_id, 		-- structure element id
				P_WBS_VERSION_ID, 		-- structure version id
				WBS_NODE.project_id,		-- parent project id
				l_wbs_temp_parent, 		-- parent id
				l_wbs_temp_sup_emt,		-- sup_emt_id
				WBS_NODE.proj_element_id, 	-- immediate child id
				WBS_NODE.element_version_id, 	-- child id
				l_wbs_temp_sub_emt,		-- sub_emt_id
				l_wbs_level_id - 1, 		-- parent level
				l_wbs_level_id, 		-- child level
				null,				-- child rollup id
				l_wbs_leaf_flag_id,	 	-- child leaf flag id
				l_wbs_leaf_flag,	 	-- child leaf flag
				decode(l_sharing_code,
					'SHARE_FULL',       'WF',
					'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
					'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
								-- sub financial task flag 	-- ###financial###
				'parent',			-- status id
				P_WORKER_ID			-- worker id
				);


			-- --------------------------------------------------------
			-- Check for WBS node's children --
			--  Filter nodes to see if the node has children

			FOR WBS_CHILDREN_NODE IN
			(
			select 	wdt_child.sup_id,
				wdt_child.sub_id,
				wdt_child.sub_leaf_flag_id,
				wdt_child.relationship_type
			from 	PJI_FP_AGGR_XBS_T wdt_child
			where 	1=1
			and 	wdt_child.sup_id = WBS_NODE.element_version_id
			and 	wdt_child.sup_id <> wdt_child.sub_id
			and	wdt_child.worker_id = P_WORKER_ID
			) LOOP

				-- l_wbs_temp_level --
				select 	wdt_child1.sub_level
				into 	l_wbs_temp_level
				from 	PJI_FP_AGGR_XBS_T wdt_child1
				where 	1=1
				and 	wdt_child1.sup_id = WBS_CHILDREN_NODE.sub_id
				and 	wdt_child1.sup_id = wdt_child1.sub_id
				and	wdt_child1.worker_id = P_WORKER_ID;

				-- l_wbs_temp_sup_emt --
				select 	wvt_child1.proj_element_id
				into 	l_wbs_temp_sup_emt
				from 	PA_PROJ_ELEMENT_VERSIONS wvt_child1
				where 	1=1
				and 	wvt_child1.element_version_id = l_wbs_temp_parent;

				-- l_wbs_temp_sub_emt --
				select 	wvt_child2.proj_element_id
				into 	l_wbs_temp_sub_emt
				from 	PA_PROJ_ELEMENT_VERSIONS wvt_child2
				where 	1=1
				and 	wvt_child2.element_version_id = WBS_CHILDREN_NODE.sub_id;

				-- l_wbs_leaf_flag --
				if 	(
					 l_wbs_temp_sup_emt = l_wbs_temp_sub_emt
					 or
					 WBS_CHILDREN_NODE.sub_leaf_flag_id = 1
					)
				then
					l_wbs_leaf_flag := 'Y';
				else
					l_wbs_leaf_flag := 'N';
				end if;


				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting WBS node child - sup_id = '
							|| WBS_CHILDREN_NODE.sup_id,
						null,
						g_msg_level_low_detail
						);
				end if;


				-- Insert WBS node's child --
				insert
				into 	PJI_FP_AGGR_XBS_T
					(
					struct_type,
					prg_group,
					struct_emt_id,
					struct_version_id,
					sup_project_id,
					sup_id,
					sup_emt_id,
					subro_id,
					sub_id,
					sub_emt_id,
					sup_level,
					sub_level,
					sub_rollup_id,
					sub_leaf_flag_id,
					sub_leaf_flag,
					relationship_type,
					status_id,
					worker_id
					)
				values (
					'WBS',					-- structure type
					null,					-- prg group
					l_struct_emt_id,	 		-- structure element id
					P_WBS_VERSION_ID, 			-- structure version id
					WBS_NODE.project_id,			-- parent project id
					l_wbs_temp_parent, 			-- parent id
					l_wbs_temp_sup_emt,			-- sup emt_id
					WBS_NODE.proj_element_id, 		-- immediate child id
					WBS_CHILDREN_NODE.sub_id, 		-- child id
					l_wbs_temp_sub_emt,			-- sub emt_id
					l_wbs_level_id - 1, 			-- parent level
					l_wbs_temp_level, 			-- child level
					null, 					-- child rollup id
					WBS_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag id
					l_wbs_leaf_flag, 			-- child leaf flag
					decode(l_sharing_code,
						'SHARE_FULL',       'WF',
						'SHARE_PARTIAL',    decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'WF', 'LW'),
						'SPLIT_MAPPING',    decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW'),
						'SPLIT_NO_MAPPING', decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW'),
						'PJI$NULL',         decode(nvl(WBS_CHILDREN_NODE.relationship_type, 'N'), 'Y', 'LF', 'LW')),
										-- sub financial task flag 	-- ###financial###
					'children',				-- status id
					P_WORKER_ID				-- worker id
					);

			END LOOP; -- FOR WBS_CHILDREN_NODE

		ELSE

			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -   Parent Data Corruption - element_version_id = '
						|| WBS_NODE.element_version_id,
					null,
					g_msg_level_data_corruption
					);
			end if;

		END IF; -- l_wbs_test_node = 1 -- ###parent_is_one###

	ELSE

		select 	count(*)
		into 	l_struct_emt_id_count
		from 	pa_proj_element_versions
		where 	1=1
		and 	element_version_id = P_WBS_VERSION_ID
		and	rownum = 1;

		if	l_struct_emt_id_count <> 0
		then

			-- l_struct_emt_id -- 			-- ###xbs###
			select
			distinct
				proj_element_id
			into 	l_struct_emt_id
			from 	pa_proj_element_versions
			where 	1=1
			and 	element_version_id = P_WBS_VERSION_ID;


			-- l_wbs_leaf_flag -- (business rule)
			if 	(
				 P_WBS_VERSION_ID = WBS_NODE.element_version_id
				 or
				 l_wbs_leaf_flag_id = 1
				)
			then
				l_wbs_leaf_flag := 'Y';
			else
				l_wbs_leaf_flag := 'N';
			end if;


			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -     Inserting XBS node self - sup_id = '
						|| P_WBS_VERSION_ID,
					null,
					g_msg_level_low_detail
					);
			end if;

			-- Insert XBS node --
			insert
			into	PJI_FP_AGGR_XBS_T
				(
				struct_type,
				prg_group,
				struct_version_id,
				sup_project_id,
				sup_id,
				sup_emt_id,
				subro_id,
				sub_id,
				sub_emt_id,
				sup_level,
				sub_level,
				sub_rollup_id,
				sub_leaf_flag_id,
				sub_leaf_flag,
				relationship_type,
				status_id,
				worker_id
				)
			values (
			       'XBS',				-- structure type
			       null,				-- prg group
			       P_WBS_VERSION_ID, 		-- structure version id
			       WBS_NODE.project_id,		-- parent project id
			       P_WBS_VERSION_ID, 		-- parent id
			       l_struct_emt_id,			-- sup emt_id
			       null, 				-- immediate child id
			       WBS_NODE.element_version_id, 	-- child id
			       WBS_NODE.proj_element_id,	-- sub emt_id
			       0,		 		-- parent level
			       l_wbs_level_id,			-- child level
			       null,				-- child rollup id
			       l_wbs_leaf_flag_id,		-- child leaf flag id
			       l_wbs_leaf_flag,	 		-- child leaf flag
				decode(l_sharing_code,
					'SHARE_FULL',       'WF',
					'SHARE_PARTIAL',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'WF', 'LW'),
					'SPLIT_MAPPING',    decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'SPLIT_NO_MAPPING', decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW'),
					'PJI$NULL',         decode(nvl(WBS_NODE.financial_task_flag, 'N'), 'Y', 'LF', 'LW')),
								-- sub financial task flag 	-- ###financial###
			       'self',				-- status id
			       P_WORKER_ID			-- worker id
			       );
		else

			if 	g_pa_debug_mode = 'Y'
			then
				PJI_UTILS.WRITE2LOG(
					'PJI_PJP -   DATA BUG - element_version_id = '
						|| WBS_NODE.element_version_id
						|| ' struct_version_id = '
						|| P_WBS_VERSION_ID,
					null,
					g_msg_level_high_detail
					);
			end if;

		end if;

	END IF; -- IF l_wbs_level_id <> 1

	END LOOP; -- FOR WBS_NODE

	-- Decrease WBS node level --
	l_wbs_level_id := l_wbs_level_id - 1;
	exit when l_wbs_level_id = 0;

END LOOP; -- WBS_LEVEL

END IF; -- WBS COUNT

-- -------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: wbs_denorm_online',
		null,
		g_msg_level_proc_call
		);
end if;
-- -------------------------------------------------

end wbs_denorm_online;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure rbs_denorm(
	p_worker_id 	  	in 	number,
	p_extraction_type 	in 	varchar2,
	p_rbs_version_id  	in 	number
) as


-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_RBS_ELEMENTS
--
--	 Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_RBS
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --

l_rbs_level_id 		number;
l_rbs_temp_parent 	number;
l_rbs_temp_level 	number;
l_rbs_node_count 	number;
l_rbs_leaf_flag_id 	number;
l_rbs_leaf_flag 	varchar2(1);
/* Added for Bug 9099240 Start*/
l_max_rbs_level_id  number;
l_rbs_exists1        number;
l_rbs_exists2        number;
l_rbs_exists3        number;
/* Added for Bug 9099240 End */

-- -----------------------------------------------------

begin

-- (RBS node = resource)

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: rbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE
			|| ' p_rbs_version_id = '
			|| P_RBS_VERSION_ID,
		null,
		g_msg_level_proc_call
		);
end if;

/* Added for Bug 9099240 Start*/
l_rbs_exists1 := 0;
l_rbs_exists2 := 0;
l_rbs_exists3 := 0;
/* Added for Bug 9099240 End */

-- -----------------------------------------------------
-- Get deepest RBS node level --
--  Look only at the data to be processed
--	1) FULL - All data
--	2) INCREMENTAL or PARTIAL - Filter data by looking at the logs table

if	P_EXTRACTION_TYPE = 'FULL'
then
	select	max(pvt_level.rbs_level)
	into 	l_rbs_level_id
	from 	PA_RBS_ELEMENTS pvt_level
	where	1=1
	and 	pvt_level.user_created_flag = 'N';

elsif	(
	 P_EXTRACTION_TYPE = 'INCREMENTAL'
	 or
	 P_EXTRACTION_TYPE = 'PARTIAL'
	 or
	 P_EXTRACTION_TYPE = 'RBS'
	)
then
	select	max(pvt_level.rbs_level)
	into 	l_rbs_level_id
	from 	PA_RBS_ELEMENTS pvt_level,
		(
		 select	distinct event_type, event_object
		 from 	PJI_PA_PROJ_EVENTS_LOG
		 where 	1=1
		 and	event_type = 'PJI_RBS_CHANGE'
		 and	worker_id = P_WORKER_ID
	 	) log
	where 	1=1
	and 	pvt_level.user_created_flag = 'N'
	and	pvt_level.rbs_version_id = log.event_object;

elsif	P_EXTRACTION_TYPE = 'UPGRADE'
then
	select	max(pvt_level.rbs_level)
	into 	l_rbs_level_id
	from 	PA_RBS_ELEMENTS pvt_level
	where	1=1
	and 	pvt_level.user_created_flag = 'N'
	and	pvt_level.rbs_version_id = P_RBS_VERSION_ID;

else
	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   No maximum level found - p_rbs_version_id = '
				|| P_RBS_VERSION_ID,
			null,
			g_msg_level_data_corruption
			);
	end if;

	l_rbs_level_id := 1;		-- ###level_is_null###
end if;


-- --------------------------------------------------------
-- RBS nodes with no level (is null) are INVALID.

if	l_rbs_level_id is null		-- ###level_is_null###
then
	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP - Level is null Data Corruption - p_rbs_version_id = '
				|| P_RBS_VERSION_ID,
			null,
			g_msg_level_data_corruption
			);
	end if;

	l_rbs_level_id := 1;
end if;

-- -----------------------------------------------------

l_max_rbs_level_id := l_rbs_level_id;  /* Added for Bug 9099240 */

-- -----------------------------------------------------

LOOP

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   RBS Inserts - l_rbs_level_id = '
				|| l_rbs_level_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	-- Get all RBS nodes from a certain level --
	--  Look only at the data to be processed
	--	1) FULL - All data
	--	2) INCREMENTAL or PARTIAL - Filter data by looking at the logs
	--	table
	--		2.1) RBS node's changes

	FOR RBS_NODE IN
	(
	 select
	 distinct
						-- pvt_nodes.project_id,
		pvt_nodes1.rbs_version_id, 	-- pvt_nodes.proj_element_id,
		pvt_nodes1.rbs_element_id,	-- pvt_nodes.element_version_id,
		pvt_nodes1.parent_element_id	-- pvt_nodes.parent_structure_version_id,
						-- pvt_nodes.rbs_group
	 from 	PA_RBS_ELEMENTS pvt_nodes1,
		pji_pjp_proj_batch_map map,
		pa_rbs_prj_assignments assignments
	 where 	1=1
	 and 	P_EXTRACTION_TYPE = 'FULL'
	 and 	pvt_nodes1.user_created_flag = 'N'
	 and 	(
		 pvt_nodes1.rbs_level = l_rbs_level_id
		 or
		 (
		  l_rbs_level_id = 1
		  and
		  pvt_nodes1.rbs_level is null
		 )
		)
	 and 	map.project_id = assignments.project_id
	 and	assignments.rbs_version_id = pvt_nodes1.rbs_version_id
	UNION ALL
	 select
	 distinct
						-- pvt_nodes.project_id,
		pvt_nodes2.rbs_version_id, 	-- pvt_nodes.proj_element_id,
		pvt_nodes2.rbs_element_id,	-- pvt_nodes.element_version_id,
		pvt_nodes2.parent_element_id	-- pvt_nodes.parent_structure_version_id,
						-- pvt_nodes.rbs_group
	 from 	PA_RBS_ELEMENTS pvt_nodes2,
		(
		 select
		 distinct
			log1.event_type, log1.event_object
		 from 	PJI_PA_PROJ_EVENTS_LOG log1
		 where 	1=1
		 and	log1.event_type = 'PJI_RBS_CHANGE'
		 and	worker_id = P_WORKER_ID
		 ) log11
	 where 	1=1
	 and	(
		 P_EXTRACTION_TYPE = 'INCREMENTAL'
		 or
		 P_EXTRACTION_TYPE = 'PARTIAL'
		 or
		 P_EXTRACTION_TYPE = 'RBS'
		)
	 and 	pvt_nodes2.user_created_flag = 'N'
	 and	pvt_nodes2.rbs_version_id = log11.event_object
	 and 	pvt_nodes2.rbs_level = l_rbs_level_id
	 /* Added for Bug 9099240 Start */
	 and  l_rbs_level_id = l_max_rbs_level_id
	 and  pvt_nodes2.rbs_element_id between PA_RBS_MAPPING.g_max_rbs_id1 and PA_RBS_MAPPING.g_max_rbs_id2
	UNION ALL
	 select
	 distinct
		pvt_nodes2.rbs_version_id,
		pvt_nodes2.rbs_element_id,
		pvt_nodes2.parent_element_id
	 from 	PA_RBS_ELEMENTS pvt_nodes2,
		(
		 select
		 distinct
			log1.event_type, log1.event_object
		 from 	PJI_PA_PROJ_EVENTS_LOG log1
		 where 	1=1
		 and	log1.event_type = 'PJI_RBS_CHANGE'
		 and	worker_id = P_WORKER_ID
		 ) log11
	 where 	1=1
	 and	(
		 P_EXTRACTION_TYPE = 'INCREMENTAL'
		 or
		 P_EXTRACTION_TYPE = 'PARTIAL'
		 or
		 P_EXTRACTION_TYPE = 'RBS'
		)
	 and 	pvt_nodes2.user_created_flag = 'N'
	 and	pvt_nodes2.rbs_version_id = log11.event_object
	 and 	pvt_nodes2.rbs_level = l_rbs_level_id
	 and  l_rbs_level_id <> l_max_rbs_level_id
	 /* Added for Bug 9099240 End */
	UNION ALL
	 select
	 distinct
						-- pvt_nodes.project_id,
		pvt_nodes1.rbs_version_id, 	-- pvt_nodes.proj_element_id,
		pvt_nodes1.rbs_element_id,	-- pvt_nodes.element_version_id,
		pvt_nodes1.parent_element_id	-- pvt_nodes.parent_structure_version_id,
						-- pvt_nodes.rbs_group
	 from 	PA_RBS_ELEMENTS pvt_nodes1
	 where 	1=1
	 and 	P_EXTRACTION_TYPE = 'UPGRADE'
	 and 	pvt_nodes1.user_created_flag = 'N'
	 and 	(
		 pvt_nodes1.rbs_level = l_rbs_level_id
		 or
		 (
		  l_rbs_level_id = 1
		  and
		  pvt_nodes1.rbs_level is null
		 )
		)
	 and	pvt_nodes1.rbs_version_id = P_RBS_VERSION_ID
	) LOOP


		-- -----------------------------------------------------
		-- Check RBS node self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf

		select 	count(*)
		into 	l_rbs_node_count
		from 	PJI_FP_AGGR_RBS pdt_count
		where 	1=1
		and	pdt_count.sup_id = RBS_NODE.rbs_element_id
 		and	pdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;

		-- l_rbs_leaf_flag_id --
		if 	l_rbs_node_count > 0
		then
			l_rbs_leaf_flag_id := 0;
		else
			l_rbs_leaf_flag_id := 1;
		end if;

		-- l_rbs_leaf_flag -- (business rule)
		if 	(
			 RBS_NODE.rbs_version_id = RBS_NODE.rbs_version_id
			 or
			 l_rbs_leaf_flag_id = 1
			)
		then
			l_rbs_leaf_flag := 'Y';
		else
			l_rbs_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting RBS node self - rbs_element_id = '
					|| RBS_NODE.rbs_element_id,
				null,
				g_msg_level_low_detail
				);
		end if;

/* Added for Bug 9099240 Start */
    begin
       select count(*) into l_rbs_exists1
       from pa_rbs_denorm den,
            (select distinct log1.event_object
   		      from 	PJI_PA_PROJ_EVENTS_LOG log1
   		      where 	1=1
   		      and	log1.event_type = 'PJI_RBS_CHANGE'
		      and	worker_id = P_WORKER_ID)
		       log11
       where den.struct_version_id = log11.event_object
       and den.sup_id = RBS_NODE.rbs_element_id
       and den.sub_id = RBS_NODE.rbs_element_id
       and den.subro_id is null;
    exception
       when NO_DATA_FOUND then
            l_rbs_exists1 := 0;
    end;
/* Added for Bug 9099240 End */

		-- Insert RBS node self --
		if l_rbs_exists1 = 0 then  /* Added for Bug 9099240 */
		insert
		into 	PJI_FP_AGGR_RBS
			(
			struct_version_id,
			sup_id,
			subro_id,
			sub_id,
			sup_level,
			sub_level,
			sub_leaf_flag_id,
			sub_leaf_flag,
			status_id,
			worker_id
			)
		values (
			RBS_NODE.rbs_version_id,	-- rbs version id
			RBS_NODE.rbs_element_id, 	-- parent id
			null, 				-- immediate child id
			RBS_NODE.rbs_element_id, 	-- child id
			l_rbs_level_id, 		-- parent level
			l_rbs_level_id, 		-- child level
			l_rbs_leaf_flag_id,		-- child leaf flag id
			l_rbs_leaf_flag,		-- child leaf flag
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);
		end if;   /* Added for Bug 9099240 */

		-- --------------------------------------------------------
		-- Check for RBS node's parent --
		--  Check only if the node is not a top most node (level = 1)

		IF 	l_rbs_level_id <> 1
		THEN

			FOR RBS_PARENT_NODE IN
			(
			 select
			 distinct
				prt_parent.parent_element_id
			 from 	PA_RBS_ELEMENTS prt_parent
			 where 	1=1
			 and 	prt_parent.user_created_flag = 'N'
			 and 	prt_parent.rbs_element_id = RBS_NODE.rbs_element_id -- prt_parent.child_id
			) LOOP


			-- l_rbs_temp_parent --
			l_rbs_temp_parent := RBS_PARENT_NODE.parent_element_id;


			-- Filter data corruption  ###parent_is_null###

			IF	l_rbs_temp_parent is not null
			THEN


				-- l_rbs_leaf_flag --
				if 	(
					 l_rbs_temp_parent = RBS_NODE.rbs_element_id
					 or
					 l_rbs_leaf_flag_id = 1
					)
				then
					l_rbs_leaf_flag := 'Y';
				else
					l_rbs_leaf_flag := 'N';
				end if;

				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting RBS node parent - l_rbs_temp_parent - = '
							|| l_rbs_temp_parent,
						null,
						g_msg_level_low_detail
						);
				end if;

            /* Added for Bug 9099240 Start */
            begin
               select count(*) into l_rbs_exists2
               from pa_rbs_denorm den,
                    (select distinct log1.event_object
           		      from 	PJI_PA_PROJ_EVENTS_LOG log1
           		      where 	1=1
           		      and	log1.event_type = 'PJI_RBS_CHANGE'
          	      and	worker_id = P_WORKER_ID)
          	       log11
               where den.struct_version_id = log11.event_object
               and den.sup_id = l_rbs_temp_parent
               and den.sub_id = RBS_NODE.rbs_element_id
               and den.subro_id = RBS_NODE.rbs_element_id;
            exception
               when NO_DATA_FOUND then
                    l_rbs_exists2 := 0;
            end;
            /* Added for Bug 9099240 End */

				-- Insert RBS node's parent --
				if l_rbs_exists2 = 0 then  /* Added for Bug 9099240 */
				insert
				into 	PJI_FP_AGGR_RBS
					(
					struct_version_id,
					sup_id,
					subro_id,
					sub_id,
					sup_level,
					sub_level,
					sub_leaf_flag_id,
					sub_leaf_flag,
					status_id,
					worker_id
					)
				values (
					RBS_NODE.rbs_version_id,	-- rbs version id
					l_rbs_temp_parent, 		-- parent id
					RBS_NODE.rbs_element_id,	-- immediate child id
					RBS_NODE.rbs_element_id, 	-- child id
					l_rbs_level_id - 1, 		-- parent level
					l_rbs_level_id, 		-- child level
					l_rbs_leaf_flag_id,		-- child leaf flag id
					l_rbs_leaf_flag,		-- child leaf flag
					'parent', 			-- status id
 					P_WORKER_ID			-- worker id
					);
				end if;   /* Added for Bug 9099240 */


				-- --------------------------------------------------------
				-- Check for RBS node's children --
				--  Filter nodes to see if the node has children

				FOR RBS_CHILDREN_NODE IN
				(
				 select
				 distinct
					pdt_child.sup_id,
					pdt_child.sub_id,
					pdt_child.sub_leaf_flag_id
				 from 	PJI_FP_AGGR_RBS pdt_child
				 where 	1=1
				 and 	pdt_child.sup_id = RBS_NODE.rbs_element_id
				 and 	pdt_child.sup_id <> pdt_child.sub_id
		 		 and	pdt_child.worker_id = P_WORKER_ID
				) LOOP

					-- l_rbs_temp_level --
					select 	pdt_child1.sub_level
					into 	l_rbs_temp_level
					from 	PJI_FP_AGGR_RBS pdt_child1
					where 	1=1
					and 	pdt_child1.sup_id = RBS_CHILDREN_NODE.sub_id
					and 	pdt_child1.sup_id = pdt_child1.sub_id
 					and	pdt_child1.worker_id = P_WORKER_ID;

					-- l_rbs_leaf_flag --
					if 	(
						 l_rbs_temp_parent = RBS_CHILDREN_NODE.sub_id
						 or
						 RBS_CHILDREN_NODE.sub_leaf_flag_id = 1
						)
					then
						l_rbs_leaf_flag := 'Y';
					else
						l_rbs_leaf_flag := 'N';
					end if;


					if 	g_pa_debug_mode = 'Y'
					then
						PJI_UTILS.WRITE2LOG(
							'PJI_PJP -     Inserting RBS node child - sup_id = '
								|| RBS_CHILDREN_NODE.sup_id,
							null,
							g_msg_level_low_detail
							);
					end if;

            /* Added for Bug 9099240 Start */
            begin
               select count(*) into l_rbs_exists3
               from pa_rbs_denorm den,
                    (select distinct log1.event_object
           		      from 	PJI_PA_PROJ_EVENTS_LOG log1
           		      where 	1=1
           		      and	log1.event_type = 'PJI_RBS_CHANGE'
        		      and	worker_id = P_WORKER_ID)
        		       log11
               where den.struct_version_id = log11.event_object
               and den.sup_id = l_rbs_temp_parent
               and den.sub_id = RBS_CHILDREN_NODE.sub_id
               and den.subro_id = RBS_NODE.rbs_element_id;
            exception
               when NO_DATA_FOUND then
                    l_rbs_exists3 := 0;
            end;
            /* Added for Bug 9099240 End */

					-- Insert RBS node's child --
					if l_rbs_exists3 = 0 then   /* Added for Bug 9099240 */
					insert
					into 	PJI_FP_AGGR_RBS
						(
						struct_version_id,
						sup_id,
						subro_id,
						sub_id,
						sup_level,
						sub_level,
						sub_leaf_flag_id,
						sub_leaf_flag,
						status_id,
						worker_id
						)
					values (
						RBS_NODE.rbs_version_id,		-- rbs version id
						l_rbs_temp_parent, 			-- parent id
						RBS_NODE.rbs_element_id,		-- immediate child id
						RBS_CHILDREN_NODE.sub_id,		-- child id
						l_rbs_level_id - 1, 			-- parent level
						l_rbs_temp_level, 			-- child level
						RBS_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag
						l_rbs_leaf_flag, 			-- child leaf flag
						'children',				-- status id
 						P_WORKER_ID				-- worker id
						);
					end if;   /* Added for Bug 9099240 */

				END LOOP; -- FOR RBS_CHILD_NODE

			ELSE

				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -   Parent Data Corruption - rbs_element_id = '
								|| RBS_NODE.rbs_element_id,
						null,
						g_msg_level_data_corruption
						);
				end if;

			END IF;				     -- ###parent_is_null###

			END LOOP; -- FOR RBS_PARENT_NODE

		END IF; -- if RBS_LEVEL <> 1

	END LOOP; -- FOR RBS_NODE

	-- Decrease rbs level --
	l_rbs_level_id := l_rbs_level_id - 1;
	exit when l_rbs_level_id = 0;

END LOOP; -- RBS_LEVEL

-- -----------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: rbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------
/* Added for Bug 9099240 Start */
PA_RBS_MAPPING.g_max_rbs_id1 := PA_RBS_MAPPING.g_max_rbs_id2 + 1;
PA_RBS_MAPPING.g_max_rbs_id2 := 0;
/* Added for Bug 9099240 End */

end rbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------







-- -----------------------------------------------------------------------

procedure rbs_denorm_online(
	p_worker_id 	  	in 	number,
	p_extraction_type    	in 	varchar2,
	p_rbs_version_id  	in 	number
) as


-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This API assumes that the following tables exist and that they are
--	properly populated (no cycles, correct relationships, etc)
--
--		PA_RBS_ELEMENTS
--
--	 Then, this API populates output values in the following existing
--	table:
--		PJI_FP_AGGR_RBS_T
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
--  Declare statements --

l_rbs_level_id 		number;
l_rbs_temp_parent 	number;
l_rbs_temp_level 	number;
l_rbs_node_count 	number;
l_rbs_leaf_flag_id 	number;
l_rbs_leaf_flag 	varchar2(1);
/* Added for Bug 9099240 Start */
l_rbs_id1     number;
l_rbs_id2     number;
l_max_rbs_level_id 		number;
l_rbs_exists1        number;
l_rbs_exists2        number;
l_rbs_exists3        number;
/* Added for Bug 9099240 End */
-- -----------------------------------------------------

begin

-- (RBS node = resource)

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: rbs_denorm_online -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE
			|| ' p_rbs_version_id = '
			|| P_RBS_VERSION_ID,
		null,
		g_msg_level_proc_call
		);
end if;

/* Added for Bug 9099240 Start */
l_rbs_id1 := PA_RBS_MAPPING.g_max_rbs_id1;
l_rbs_id2 := PA_RBS_MAPPING.g_max_rbs_id2;
l_rbs_exists1 := 0;
l_rbs_exists2 := 0;
l_rbs_exists3 := 0;
/* Added for Bug 9099240 End */
-- -----------------------------------------------------

-- Get deepest RBS node level --

select	max(pvt_level.rbs_level)
into 	l_rbs_level_id
from 	PA_RBS_ELEMENTS pvt_level
where	1=1
and 	pvt_level.user_created_flag = 'N'
and	pvt_level.rbs_version_id = P_RBS_VERSION_ID;


-- --------------------------------------------------------
-- RBS nodes with no level (is null) are INVALID.

if	l_rbs_level_id is null		-- ###level_is_null###
then
	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP - Level is null Data Corruption - p_rbs_version_id = '
				|| P_RBS_VERSION_ID,
			null,
			g_msg_level_data_corruption
			);
	end if;

	l_rbs_level_id := 1;
end if;

-- -----------------------------------------------------

l_max_rbs_level_id := l_rbs_level_id;    /* Added for Bug 9099240 */

-- -----------------------------------------------------

LOOP

	if 	g_pa_debug_mode = 'Y'
	then
		PJI_UTILS.WRITE2LOG(
			'PJI_PJP -   RBS Inserts - l_rbs_level_id = '
				|| l_rbs_level_id,
			null,
			g_msg_level_high_detail
			);
	end if;

	-- Get all RBS nodes from a certain level --

	FOR RBS_NODE IN
	(
	 select
	 distinct
						-- pvt_nodes.project_id,
		pvt_nodes1.rbs_version_id, 	-- pvt_nodes.proj_element_id,
		pvt_nodes1.rbs_element_id,	-- pvt_nodes.element_version_id,
		pvt_nodes1.parent_element_id	-- pvt_nodes.parent_structure_version_id,
						-- pvt_nodes.rbs_group
	 from 	PA_RBS_ELEMENTS pvt_nodes1
	 where 	1=1
	 and 	pvt_nodes1.user_created_flag = 'N'
	 and 	(
		 pvt_nodes1.rbs_level = l_rbs_level_id
		 or
		 (
		  l_rbs_level_id = 1
		  and
		  pvt_nodes1.rbs_level is null
		 )
		)
	 and	pvt_nodes1.rbs_version_id = P_RBS_VERSION_ID
	 /* Added for Bug 9099240 Start */
	 and pvt_nodes1.rbs_element_id between l_rbs_id1 and l_rbs_id2
	 union all
	 select
	 distinct
		pvt_nodes1.rbs_version_id,
		pvt_nodes1.rbs_element_id,
		pvt_nodes1.parent_element_id
	 from 	PA_RBS_ELEMENTS pvt_nodes1
	 where 	1=1
	 and 	pvt_nodes1.user_created_flag = 'N'
	 and 	(
		 pvt_nodes1.rbs_level = l_rbs_level_id
		 or
		 (
		  l_rbs_level_id = 1
		  and
		  pvt_nodes1.rbs_level is null
		 )
		)
	 and	pvt_nodes1.rbs_version_id = P_RBS_VERSION_ID
	 and l_max_rbs_level_id <> l_rbs_level_id
	 /* Added for Bug 9099240 End */
	) LOOP


		-- -----------------------------------------------------
		-- Check RBS node self --

		-- Determine if the node to be inserted is a leaf
		--  If the node to be inserted has not been inserted before,
		-- then we know that the node is a leaf

		select 	count(*)
		into 	l_rbs_node_count
		from 	PJI_FP_AGGR_RBS_T pdt_count
		where 	1=1
		and	pdt_count.sup_id = RBS_NODE.rbs_element_id
 		and	pdt_count.worker_id = P_WORKER_ID
		and	rownum = 1;

		-- l_rbs_leaf_flag_id --
		if 	l_rbs_node_count > 0
		then
			l_rbs_leaf_flag_id := 0;
		else
			l_rbs_leaf_flag_id := 1;
		end if;

		-- l_rbs_leaf_flag -- (business rule)
		if 	(
			 RBS_NODE.rbs_version_id = RBS_NODE.rbs_version_id
			 or
			 l_rbs_leaf_flag_id = 1
			)
		then
			l_rbs_leaf_flag := 'Y';
		else
			l_rbs_leaf_flag := 'N';
		end if;


		if 	g_pa_debug_mode = 'Y'
		then
			PJI_UTILS.WRITE2LOG(
				'PJI_PJP -     Inserting RBS node self - rbs_element_id = '
					|| RBS_NODE.rbs_element_id,
				null,
				g_msg_level_low_detail
				);
		end if;

    /* Added for Bug 9099240 Start */
    begin
       select count(*) into l_rbs_exists1
       from pa_rbs_denorm den
       where den.struct_version_id = P_RBS_VERSION_ID
       and den.sup_id = RBS_NODE.rbs_element_id
       and den.sub_id = RBS_NODE.rbs_element_id
       and den.subro_id is null;
    exception
       when NO_DATA_FOUND then
            l_rbs_exists1 := 0;
    end;
    /* Added for Bug 9099240 End */

		-- Insert RBS node self --
		if l_rbs_exists1 = 0 then  /* Added for Bug 9099240 */
		insert
		into 	PJI_FP_AGGR_RBS_T
			(
			struct_version_id,
			sup_id,
			subro_id,
			sub_id,
			sup_level,
			sub_level,
			sub_leaf_flag_id,
			sub_leaf_flag,
			status_id,
			worker_id
			)
		values (
			RBS_NODE.rbs_version_id,	-- rbs version id
			RBS_NODE.rbs_element_id, 	-- parent id
			null, 				-- immediate child id
			RBS_NODE.rbs_element_id, 	-- child id
			l_rbs_level_id, 		-- parent level
			l_rbs_level_id, 		-- child level
			l_rbs_leaf_flag_id,		-- child leaf flag id
			l_rbs_leaf_flag,		-- child leaf flag
			'self',				-- status id
			P_WORKER_ID			-- worker id
			);
		end if;   /* Added for Bug 9099240 */

		-- --------------------------------------------------------
		-- Check for RBS node's parent --
		--  Check only if the node is not a top most node (level = 1)

		IF 	l_rbs_level_id <> 1
		THEN

			FOR RBS_PARENT_NODE IN
			(
			 select
			 distinct
				prt_parent.parent_element_id
			 from 	PA_RBS_ELEMENTS prt_parent
			 where 	1=1
			 and 	prt_parent.user_created_flag = 'N'
			 and 	prt_parent.rbs_element_id = RBS_NODE.rbs_element_id -- prt_parent.child_id
			) LOOP


			-- l_rbs_temp_parent --
			l_rbs_temp_parent := RBS_PARENT_NODE.parent_element_id;


			-- Filter data corruption  ###parent_is_null###

			IF	l_rbs_temp_parent is not null
			THEN


				-- l_rbs_leaf_flag --
				if 	(
					 l_rbs_temp_parent = RBS_NODE.rbs_element_id
					 or
					 l_rbs_leaf_flag_id = 1
					)
				then
					l_rbs_leaf_flag := 'Y';
				else
					l_rbs_leaf_flag := 'N';
				end if;

				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -     Inserting RBS node parent - l_rbs_temp_parent - = '
							|| l_rbs_temp_parent,
						null,
						g_msg_level_low_detail
						);
				end if;

        /* Added for Bug 9099240 Start */
        begin
           select count(*) into l_rbs_exists2
           from pa_rbs_denorm den
           where den.struct_version_id = P_RBS_VERSION_ID
           and den.sup_id = l_rbs_temp_parent
           and den.sub_id = RBS_NODE.rbs_element_id
           and den.subro_id = RBS_NODE.rbs_element_id;
        exception
           when NO_DATA_FOUND then
                l_rbs_exists2 := 0;
        end;
        /* Added for Bug 9099240 End */

				-- Insert RBS node's parent --
				if l_rbs_exists2 = 0 then  /* Added for Bug 9099240 */
				insert
				into 	PJI_FP_AGGR_RBS_T
					(
					struct_version_id,
					sup_id,
					subro_id,
					sub_id,
					sup_level,
					sub_level,
					sub_leaf_flag_id,
					sub_leaf_flag,
					status_id,
					worker_id
					)
				values (
					RBS_NODE.rbs_version_id,	-- rbs version id
					l_rbs_temp_parent, 		-- parent id
					RBS_NODE.rbs_element_id,	-- immediate child id
					RBS_NODE.rbs_element_id, 	-- child id
					l_rbs_level_id - 1, 		-- parent level
					l_rbs_level_id, 		-- child level
					l_rbs_leaf_flag_id,		-- child leaf flag id
					l_rbs_leaf_flag,		-- child leaf flag
					'parent', 			-- status id
 					P_WORKER_ID			-- worker id
					);
				end if;   /*Added for Bug 9099240 */


				-- --------------------------------------------------------
				-- Check for RBS node's children --
				--  Filter nodes to see if the node has children

				FOR RBS_CHILDREN_NODE IN
				(
				 select
				 distinct
					pdt_child.sup_id,
					pdt_child.sub_id,
					pdt_child.sub_leaf_flag_id
				 from 	PJI_FP_AGGR_RBS_T pdt_child
				 where 	1=1
				 and 	pdt_child.sup_id = RBS_NODE.rbs_element_id
				 and 	pdt_child.sup_id <> pdt_child.sub_id
		 		 and	pdt_child.worker_id = P_WORKER_ID
				) LOOP

					-- l_rbs_temp_level --
					select 	pdt_child1.sub_level
					into 	l_rbs_temp_level
					from 	PJI_FP_AGGR_RBS_T pdt_child1
					where 	1=1
					and 	pdt_child1.sup_id = RBS_CHILDREN_NODE.sub_id
					and 	pdt_child1.sup_id = pdt_child1.sub_id
 					and	pdt_child1.worker_id = P_WORKER_ID;

					-- l_rbs_leaf_flag --
					if 	(
						 l_rbs_temp_parent = RBS_CHILDREN_NODE.sub_id
						 or
						 RBS_CHILDREN_NODE.sub_leaf_flag_id = 1
						)
					then
						l_rbs_leaf_flag := 'Y';
					else
						l_rbs_leaf_flag := 'N';
					end if;


					if 	g_pa_debug_mode = 'Y'
					then
						PJI_UTILS.WRITE2LOG(
							'PJI_PJP -     Inserting RBS node child - sup_id = '
								|| RBS_CHILDREN_NODE.sup_id,
							null,
							g_msg_level_low_detail
							);
					end if;

            /* Added for Bug 9099240 Start */
            begin
               select count(*) into l_rbs_exists3
               from pa_rbs_denorm den
               where den.struct_version_id = P_RBS_VERSION_ID
               and den.sup_id = l_rbs_temp_parent
               and den.sub_id = RBS_CHILDREN_NODE.sub_id
               and den.subro_id = RBS_NODE.rbs_element_id
               and rownum = 1;
            exception
               when NO_DATA_FOUND then
                    l_rbs_exists3 := 0;
            end;
            /* Added for Bug 9099240 End */

					-- Insert RBS node's child --
					if l_rbs_exists3 = 0 then  /* Added for Bug 9099240 */
					insert
					into 	PJI_FP_AGGR_RBS_T
						(
						struct_version_id,
						sup_id,
						subro_id,
						sub_id,
						sup_level,
						sub_level,
						sub_leaf_flag_id,
						sub_leaf_flag,
						status_id,
						worker_id
						)
					values (
						RBS_NODE.rbs_version_id,		-- rbs version id
						l_rbs_temp_parent, 			-- parent id
						RBS_NODE.rbs_element_id,		-- immediate child id
						RBS_CHILDREN_NODE.sub_id,		-- child id
						l_rbs_level_id - 1, 			-- parent level
						l_rbs_temp_level, 			-- child level
						RBS_CHILDREN_NODE.sub_leaf_flag_id, 	-- child leaf flag
						l_rbs_leaf_flag, 			-- child leaf flag
						'children',				-- status id
 						P_WORKER_ID				-- worker id
						);
					end if;  /* Added for Bug 9099240 */

				END LOOP; -- FOR RBS_CHILD_NODE

			ELSE

				if 	g_pa_debug_mode = 'Y'
				then
					PJI_UTILS.WRITE2LOG(
						'PJI_PJP -   Parent Data Corruption - rbs_element_id = '
							|| RBS_NODE.rbs_element_id,
						null,
						g_msg_level_data_corruption
						);
				end if;

			END IF;				     -- ###parent_is_null###

			END LOOP; -- FOR RBS_PARENT_NODE

		END IF; -- if RBS_LEVEL <> 1

	END LOOP; -- FOR RBS_NODE

	-- Decrease rbs level --
	l_rbs_level_id := l_rbs_level_id - 1;
	exit when l_rbs_level_id = 0;

END LOOP; -- RBS_LEVEL

-- -------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: rbs_denorm_online',
		null,
		g_msg_level_proc_call
		);
end if;
-- -------------------------------------------------
/* Added for Bug 9099240 Start */
PA_RBS_MAPPING.g_max_rbs_id1 := PA_RBS_MAPPING.g_max_rbs_id2 + 1;
PA_RBS_MAPPING.g_max_rbs_id2 := 0;
/* Added for Bug 9099240 End */

end rbs_denorm_online;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure merge_xbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
) as

-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This procedure merges data from the denorm interim table
-- 	(PJI_FP_AGGR_XBS) to the actual denorm table (PA_XBS_DENORM)
--
--	 After calling this procedure, the contents of the interim table
--	need to be deleted.
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------------------------
-- Declare statements --

l_last_update_date  date;
l_last_updated_by   number;
l_creation_date     date;
l_created_by        number;
l_last_update_login number;

-- -----------------------------------------------------

begin

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: merge_xbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- Variable Assignments --

l_last_update_date  := sysdate;
l_last_updated_by   := FND_GLOBAL.USER_ID;
l_creation_date     := sysdate;
l_created_by        := FND_GLOBAL.USER_ID;
l_last_update_login := FND_GLOBAL.LOGIN_ID;

-- -----------------------------------------------------

if 	p_extraction_type = 'FULL'

then

	insert
	into 	PA_XBS_DENORM
		(
		struct_type,
		prg_group,
		struct_emt_id,
		struct_version_id,
		sup_project_id,
		sup_id,
		sup_emt_id,
		subro_id,
		sub_id,
		sub_emt_id,
		sup_level,
		sub_level,
		sub_rollup_id,
		sub_leaf_flag,
		relationship_type,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
	select
		distinct
		interim.struct_type,
		interim.prg_group,
		interim.struct_emt_id,
		interim.struct_version_id,
		interim.sup_project_id,
		interim.sup_id,
		interim.sup_emt_id,
		interim.subro_id,
		interim.sub_id,
		interim.sub_emt_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_rollup_id,
		interim.sub_leaf_flag,
		interim.relationship_type,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_XBS		interim,
		PA_XBS_DENORM		denorm
	where	1=1
	and 	interim.worker_id = p_worker_id
	and 	nvl(interim.struct_type, -1) = nvl(denorm.struct_type (+), -1)
	and 	nvl(interim.prg_group, -1) = nvl(denorm.prg_group (+), -1)
	and 	nvl(interim.struct_emt_id, -1) = nvl(denorm.struct_emt_id (+), -1)
	and 	nvl(interim.struct_version_id, -1) = nvl(denorm.struct_version_id (+), -1)
	and 	nvl(interim.sup_project_id, -1) = nvl(denorm.sup_project_id (+), -1)
	and 	nvl(interim.sup_id, -1) = nvl(denorm.sup_id (+), -1)
	and 	nvl(interim.sup_emt_id, -1) = nvl(denorm.sup_emt_id (+), -1)
	and 	nvl(interim.subro_id, -1) = nvl(denorm.subro_id (+), -1)
	and 	nvl(interim.sub_id, -1) = nvl(denorm.sub_id (+), -1)
	and 	nvl(interim.sub_emt_id, -1) = nvl(denorm.sub_emt_id (+), -1)
	and 	nvl(interim.sup_level, -1) = nvl(denorm.sup_level (+), -1)
	and 	nvl(interim.sub_level, -1) = nvl(denorm.sub_level (+), -1)
	and 	nvl(interim.sub_rollup_id, -1) = nvl(denorm.sub_rollup_id (+), -1)
	and 	nvl(interim.sub_leaf_flag, -1) = nvl(denorm.sub_leaf_flag (+), -1)
	and 	nvl(interim.relationship_type, -1) = nvl(denorm.relationship_type (+), -1)
	and	denorm.struct_type is null
	order by
		interim.struct_version_id,
		interim.sup_id,
		interim.sub_id;

-- -------------------------

elsif  	p_extraction_type = 'ONLINE'

then

	insert
	into 	PA_XBS_DENORM
		(
		struct_type,
		prg_group,
		struct_emt_id,
		struct_version_id,
		sup_project_id,
		sup_id,
		sup_emt_id,
		subro_id,
		sub_id,
		sub_emt_id,
		sup_level,
		sub_level,
		sub_rollup_id,
		sub_leaf_flag,
		relationship_type,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
	select
		distinct
		interim.struct_type,
		interim.prg_group,
		interim.struct_emt_id,
		interim.struct_version_id,
		interim.sup_project_id,
		interim.sup_id,
		interim.sup_emt_id,
		interim.subro_id,
		interim.sub_id,
		interim.sub_emt_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_rollup_id,
		interim.sub_leaf_flag,
		interim.relationship_type,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_XBS_T	interim
	where	interim.worker_id = p_worker_id
	order by
		interim.struct_version_id,
		interim.sup_id,
		interim.sub_id;

-- -------------------------

else 	-- UPGRADE, PARTIAL, INCREMENTAL

	insert
	into 	PA_XBS_DENORM
		(
		struct_type,
		prg_group,
		struct_emt_id,
		struct_version_id,
		sup_project_id,
		sup_id,
		sup_emt_id,
		subro_id,
		sub_id,
		sub_emt_id,
		sup_level,
		sub_level,
		sub_rollup_id,
		sub_leaf_flag,
		relationship_type,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
	select
		distinct
		interim.struct_type,
		interim.prg_group,
		interim.struct_emt_id,
		interim.struct_version_id,
		interim.sup_project_id,
		interim.sup_id,
		interim.sup_emt_id,
		interim.subro_id,
		interim.sub_id,
		interim.sub_emt_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_rollup_id,
		interim.sub_leaf_flag,
		interim.relationship_type,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_XBS		interim
	where	interim.worker_id = p_worker_id
	order by
		interim.struct_version_id,
		interim.sup_id,
		interim.sub_id;

-- -------------------------

end if;

-- -----------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: merge_xbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end merge_xbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------






-- -----------------------------------------------------------------------

procedure merge_rbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
) as

-- -----------------------------------------------------------------------
--
--  History
--  19-MAR-2004	aartola	Created
--
--
--  ***  This procedure merges data from the denorm interim table
-- 	(PJI_FP_AGGR_RBS) to the actual denorm table (PA_RBS_DENORM)
--
--	 After calling this procedure, the contents of the interim table
--	need to be deleted.
--
-- -----------------------------------------------------------------------

-- -----------------------------------------------------
-- Declare statements --

l_last_update_date  date;
l_last_updated_by   number;
l_creation_date     date;
l_created_by        number;
l_last_update_login number;

-- -----------------------------------------------------

begin

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: merge_rbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------
-- Variable assignments --

l_last_update_date  := sysdate;
l_last_updated_by   := FND_GLOBAL.USER_ID;
l_creation_date     := sysdate;
l_created_by        := FND_GLOBAL.USER_ID;
l_last_update_login := FND_GLOBAL.LOGIN_ID;

-- -----------------------------------------------------

if 	p_extraction_type = 'FULL'

then

	insert
	into 	PA_RBS_DENORM
		(
		struct_version_id,
		sup_id,
		subro_id,
		sub_id,
		sup_level,
		sub_level,
		sub_leaf_flag,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
	)
	select
		interim.struct_version_id,
		interim.sup_id,
		interim.subro_id,
		interim.sub_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_leaf_flag,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_RBS		interim,
		PA_RBS_DENORM		denorm
	where	1=1
	and	interim.worker_id = p_worker_id
	and 	nvl(interim.struct_version_id, -1) = nvl(denorm.struct_version_id (+), -1)
	and 	nvl(interim.sup_id, -1) = nvl(denorm.sup_id (+), -1)
	and 	nvl(interim.subro_id, -1) = nvl(denorm.subro_id (+), -1)
	and 	nvl(interim.sub_id, -1) = nvl(denorm.sub_id (+), -1)
	and 	nvl(interim.sup_level, -1) = nvl(denorm.sup_level (+), -1)
	and 	nvl(interim.sub_level, -1) = nvl(denorm.sub_level (+), -1)
	and 	nvl(interim.sub_leaf_flag, -1) = nvl(denorm.sub_leaf_flag (+), -1)
	and	denorm.struct_version_id is null;

-- -------------------------

elsif 	p_extraction_type = 'ONLINE'

then

	insert
	into 	PA_RBS_DENORM
		(
		struct_version_id,
		sup_id,
		subro_id,
		sub_id,
		sup_level,
		sub_level,
		sub_leaf_flag,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
	)
	select
		interim.struct_version_id,
		interim.sup_id,
		interim.subro_id,
		interim.sub_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_leaf_flag,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_RBS_T	interim
	where 	interim.worker_id = p_worker_id;

-- -------------------------

else 	-- UPGRADE, PARTIAL, INCREMENTAL

	insert
	into 	PA_RBS_DENORM
		(
		struct_version_id,
		sup_id,
		subro_id,
		sub_id,
		sup_level,
		sub_level,
		sub_leaf_flag,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
	select
		interim.struct_version_id,
		interim.sup_id,
		interim.subro_id,
		interim.sub_id,
		interim.sup_level,
		interim.sub_level,
		interim.sub_leaf_flag,
		l_last_update_date,
		l_last_updated_by,
		l_creation_date,
		l_created_by,
		l_last_update_login
	from 	PJI_FP_AGGR_RBS 	interim
	where	interim.worker_id = p_worker_id;

-- -------------------------

end if;

-- -----------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: merge_rbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end merge_rbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------




-- -----------------------------------------------------------------------

procedure cleanup_xbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
) as

-- -----------------------------------------------------

begin

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: cleanup_xbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------


if 	p_extraction_type = 'ONLINE'

then
	delete
	from 	PJI_FP_AGGR_XBS_T
	where 	worker_id = p_worker_id;

else 	-- FULL, INCREMENTAL, PARTIAL, UPGRADE

	delete
	from 	PJI_FP_AGGR_XBS
	where 	worker_id = p_worker_id;

end if;

-- -----------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: cleanup_xbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end cleanup_xbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------





-- -----------------------------------------------------------------------

procedure cleanup_rbs_denorm(
	p_worker_id 		in 	number,
	p_extraction_type 	in 	varchar2
) as

-- -----------------------------------------------------

begin

if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - Begin: cleanup_rbs_denorm -'
			|| ' p_worker_id = '
			|| P_WORKER_ID
			|| ' p_extraction_type = '
			|| P_EXTRACTION_TYPE,
		null,
		g_msg_level_proc_call
		);
end if;

-- -----------------------------------------------------


if 	p_extraction_type = 'ONLINE'

then
	delete
	from 	PJI_FP_AGGR_RBS_T
	where 	worker_id = p_worker_id;

else 	-- FULL, INCREMENTAL, PARTIAL, UPGRADE

	delete
	from 	PJI_FP_AGGR_RBS
	where 	worker_id = p_worker_id;
end if;

-- -----------------------------------------------------
if 	g_pa_debug_mode = 'Y'
then
	PJI_UTILS.WRITE2LOG(
		'PJI_PJP - End: cleanup_rbs_denorm',
		null,
		g_msg_level_proc_call
		);
end if;
-- -----------------------------------------------------

end cleanup_rbs_denorm;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------





-- -----------------------------------------------------------------------

begin

-- -----------------------------------------------------

-- Declare global variables

g_pa_debug_mode			:= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
g_msg_level_data_bug		:= 6;
g_msg_level_data_corruption 	:= 5;
g_msg_level_proc_call		:= 3;
g_msg_level_high_detail		:= 2;
g_msg_level_low_detail		:= 1;

-- -----------------------------------------------------


end PJI_PJP_SUM_DENORM;

/
