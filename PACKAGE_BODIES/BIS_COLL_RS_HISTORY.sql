--------------------------------------------------------
--  DDL for Package Body BIS_COLL_RS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COLL_RS_HISTORY" AS
/*$Header: BISRSHTB.pls 120.4 2006/05/18 12:29:15 aguwalan noship $*/

 g_current_user_id         NUMBER  :=  FND_GLOBAL.User_id;
 g_error_status           VARCHAR2(80) := get_lookup_meaning('BIS_REQUEST_SET_STATUS','ERROR_COMPL');
 g_completion_status      VARCHAR2(80) := get_lookup_meaning('BIS_REQUEST_SET_STATUS','NORMAL_COMPL');
 g_warning_status	  VARCHAR2(80) := get_lookup_meaning('BIS_REQUEST_SET_STATUS','WARNING_COMPL');

 p_dummy_flag		  VARCHAR2(1)   := 'Y';

function get_lookup_meaning(p_lookup_type varchar2, p_lookup_code varchar2) return varchar2 is
l_meaning varchar2(200):= null;
begin
select MEANING into l_meaning from FND_LOOKUP_VALUES_VL where LOOKUP_TYPE=p_lookup_type and LOOKUP_CODE=p_lookup_code;
return l_meaning;
end;

/**********
  Enh#3473874 This procedure is to put RSG run data in report run tables.
  First it finds out all the stages for the given request set id.
  Then it recursively finds out the program within each stage
  Then it finds objects refreshed by every program with taking its join with bis_prog_linkage.
  It updates completion status and date for stages and request set.
*********/
procedure rsg_history_report (
	errbuf  		   OUT NOCOPY VARCHAR2,
        retcode		           OUT NOCOPY VARCHAR2,
	Root_request_id		   IN    NUMBER
) is

  l_root_request_id	number;
  l_current_stage	number;
  l_conc_prog_id	number;
  consider_mv_req	number;
  l_rs_history_stage	number;

  l_request_id		varchar2(2000) := '';
  l_parent_request_ids	varchar2(2000) :='';
  l_obj_type		varchar2(100);

   l_child_request	boolean := false;
  l_program_status	boolean  :=true;
  is_prog_part_of_rs	boolean  := false;

  l_req_set_id		number;
  l_req_app_id		number;
  l_req_set_name        FND_REQUEST_SETS.REQUEST_SET_NAME%TYPE;


  cursor c_stages is
    select
      rs.Request_set_id	  	  Request_set_id,
      rs.Set_app_id 		  Set_app_id  ,
      stg.request_set_stage_id	  Stage_id,
      req.Request_id  		  Request_id ,
      rs.request_id   		  Set_request_id,
      req.actual_start_date         Start_date,
      req.actual_completion_date    Completion_date,
      req.Status_code 		  Status_code,
      req.phase_code  		  phase_code,
      req.completion_text         Completion_text
    from bis_rs_run_history rs,
      fnd_request_set_stages stg,
      fnd_concurrent_requests req
    where rs.request_id = l_root_request_id
      and rs.request_set_id = stg.request_set_id
      and req.argument3 = stg.request_set_stage_id
      and req.parent_request_id = rs.request_id ;

  c_stages_rec  c_stages%rowtype;


 cursor c_programs is
    select
      stg.request_id	           Stage_request_id,
      req.request_id	           Request_id ,
      req.CONCURRENT_PROGRAM_ID  program_id,
      req.argument1		   obj_owner,
      req.argument2              obj_name
    from fnd_concurrent_requests req,
      bis_rs_stage_run_history stg
    where stg.set_request_id = l_root_request_id
      and stg.request_id = req.parent_request_id ;

  c_program_rec c_programs%rowtype;

  cursor c_sub_programs is
    select
      req.request_id	           Request_id ,
      req.parent_request_id        parent_request_id,
      req.CONCURRENT_PROGRAM_ID    program_id,
      prog.STAGE_REQUEST_ID	   stage_req_id
    from fnd_concurrent_requests req,
	 BIS_RS_PROG_RUN_HISTORY  prog
    where --(req.parent_request_id is not null) and
	req.parent_request_id = prog.request_id
      and (instr(l_parent_request_ids,to_char(req.parent_request_id)||',') <> 0);

  c_sub_programs_Rec c_sub_programs%rowtype;

  cursor c_get_program_id is
    select CONCURRENT_PROGRAM_ID
    from fnd_concurrent_programs
    where concurrent_program_name ='FNDGTST'
	  and APPLICATION_ID =0;

  cursor c_obj_type(l_object_name varchar2 ) is
    select object_type
    from bis_obj_properties
    where object_name= l_object_name
	   and (Object_type ='MV' or  Object_type ='TABLE');

/** Cursor no longer used in the code
  --for MVs of type consider refresh
  cursor c_refresh_mv is
    select obj.prog_request_id request_id
    from BIS_RS_PROG_RUN_HISTORY prog,
      fnd_concurrent_programs fnd,
      BIS_OBJ_REFRESH_HISTORY obj
    where prog.set_request_id = l_root_request_id
      and prog.program_id = fnd.CONCURRENT_PROGRAM_ID
      and fnd.CONCURRENT_PROGRAM_NAME ='BIS_MV_REFRESH'
      and obj.prog_request_id = prog.request_id
      and obj.Refresh_type = 'CONSIDER_REFRESH';

  c_refresh_mv_rec  c_refresh_mv%rowtype;
**/
  cursor c_consider_mv  is
    select request_id
    from BIS_RS_PROG_RUN_HISTORY
    where set_request_id = l_root_request_id
      and PROG_APP_ID =191
      and program_id = ( select CONCURRENT_PROGRAM_ID
                 	  from fnd_concurrent_programs
			  where CONCURRENT_PROGRAM_NAME ='BIS_MV_DUMMY_REFRESH' and APPLICATION_ID =191);

  -- get_stage
  cursor c_get_stage(p_prog_req_id in number) is
    select stage_request_id
    from bis_rs_prog_run_history
    where request_id = p_prog_req_id;

begin
 errbuf  := NULL;
  retcode := '0';

  --purge the old data.
  purgeHistory;

-- handling here the logic this program running as standalone or part of request set.
  l_root_request_id := Root_request_id;

    if l_root_request_id is null then
	--Program is running as the part of the request set

		l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
		is_prog_part_of_rs := true;
	       --get request set details
	      if(get_req_set_details(p_request_set_id	   =>	  l_req_set_id,
			             p_request_set_appl_id =>	  l_req_app_id,
                           	     p_request_set_name    =>	  l_req_set_name,
				    p_root_request_id	   =>	  l_root_request_id )) then
			--BIS_COLLECTION_UTILITIES.put_line('Request set id '||l_req_set_id||' Application ID '||l_req_app_id );
			 p_dummy_flag	:= 'Y';
		else
                    l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
		    BIS_COLLECTION_UTILITIES.put_line('Given request id is not valid');
		  return;
		end if;
		BIS_COLLECTION_UTILITIES.put_line('********Program is running as the part of the request set***********');
    else
	       BIS_COLLECTION_UTILITIES.put_line('************Program is running as a standalone program********');
		--get request set details
		if (get_req_set_details(p_request_set_id   =>	  l_req_set_id,
			             p_request_set_appl_id  =>	  l_req_app_id,
                           	     p_request_set_name    =>	  l_req_set_name,
				    p_root_request_id	   =>	  l_root_request_id ) ) then

				 -- BIS_COLLECTION_UTILITIES.put_line('Request set id '||l_req_set_id||' Application ID '||l_req_app_id );
				 p_dummy_flag	:= 'Y';

				-- see if given parameters are valid
				if( l_req_app_id is null OR l_req_set_id is null) then
				     BIS_COLLECTION_UTILITIES.put_line('Given request id '||Root_request_id|| ' is not valid');
					  l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
					return;
				end if;

				-- see if program has already ran. if yes then return
				   if (if_program_already_ran(l_root_request_id)) then
					 BIS_COLLECTION_UTILITIES.put_line('History data has been already collected for ' ||l_root_request_id);
					      l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
					return;
				   end if;
		 else
			 l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
			BIS_COLLECTION_UTILITIES.put_line('History data will not be collected because either given request id '||Root_request_id|| ' is not valid or Request set has been terminated.');
			return;
		 end if;

    end if;


  -- If request set is of type Gather Statistics only then add row in RS RUN table
  -- as preparation program has not run
  if (get_refresh_mode(l_req_set_id,l_req_app_id)= 'ANAL') then
    add_rsg_rs_run_record(p_request_set_id	=>	l_req_set_id,
			  p_request_set_appl_id	=>	l_req_app_id,
			  p_request_name	=>	l_req_set_name,
			  p_root_req_id		=>	l_root_request_id);
  end if;


  --put stages data into history table
  for c_stages_rec in c_stages loop

	    BIS_RS_STAGE_RUN_HISTORY_PKG.Insert_Row
	      ( p_Request_set_id	=> c_stages_rec.Request_set_id
	       ,p_Set_app_id		=> c_stages_rec.Set_app_id
	       ,p_Stage_id		=> c_stages_rec.Stage_id
	       , p_Request_id		=> c_stages_rec.Request_id
	       , p_Set_request_id	=> c_stages_rec.Set_request_id
	       , p_Start_date		=>  c_stages_rec.Start_date
	       , p_Completion_date	=> c_stages_rec.Completion_date
	       , p_Status_code		=> c_stages_rec.Status_code
	       , p_phase_code		=> c_stages_rec.phase_code
	       , p_Creation_date	=> sysdate
	       , p_Created_by		=> g_current_user_id
	       , p_Last_update_date	=> sysdate
	       , p_Last_updated_by	=> g_current_user_id
	       , p_completion_text     => c_stages_rec.completion_text
	      );


  end loop;


 --put program data into tables.
 -- Here to find out recursive programs we can use connect by on fnd table as it takes very long time.
 --Hence we  have implemented connect by clause manually


  ---put data for gather stats first.
  open  c_get_program_id ;
  fetch c_get_program_id into l_conc_prog_id;
  close c_get_program_id;




  for c_programs_rec in c_programs loop
	  l_child_request := true;
	  l_request_id := c_programs_rec.Request_id || ',' || l_request_id;
    if ( c_programs_rec.program_id = l_conc_prog_id) then

	      --get fnd_stats parametes and pass
	      open c_obj_type(c_programs_rec.obj_name);
	      fetch c_obj_type into l_obj_type;
	      close c_obj_type;

		if l_obj_type is null then
			if (substr(c_programs_rec.obj_name, 1,5) = 'MLOG$')  then
			  l_obj_type := 'MV_LOG';
			else
				  if (substr(c_programs_rec.obj_name , length(c_programs_rec.obj_name)-1,2) = 'MV') then
				    l_obj_type := 'MV';
				  else
				    l_obj_type := 'TABLE';
				  end if;

			end if;
		 end if;

-- BIS_COLLECTION_UTILITIES.put_line('Adding data for gather stats program '||c_programs_rec.Request_id || ' with stage req id '|| c_programs_rec.Stage_request_id);
		    insert_program_object_data( x_request_id    => c_programs_rec.Request_id
						, x_stage_req_id  => c_programs_rec.Stage_request_id
						, x_object_name   => c_programs_rec.obj_name
						, x_object_type   => l_obj_type
						, x_refresh_type  => 'ANALYZED'
						,x_set_request_id => l_root_request_id);

       else
        --BIS_COLLECTION_UTILITIES.put_line('Adding data for program '|| c_programs_rec.Request_id);
		 insert_program_object_data( x_request_id    => c_programs_rec.Request_id
					 ,x_stage_req_id  => c_programs_rec.Stage_request_id
					 ,x_object_name   => null
					 ,x_object_type   => null
					 ,x_refresh_type  => null
					 ,x_set_request_id => l_root_request_id);
       end if;
       l_obj_type := null;
  end loop;

  --insert data for all the program recursively
while ( l_child_request ) loop
      l_child_request := false;
      l_parent_request_ids := l_request_id;
      l_request_id := '';
       for c_sub_programs_rec in c_sub_programs loop
	       l_child_request := true;
	      l_request_id := to_char(c_sub_programs_rec.Request_id) || ',' || l_request_id;
	      --BIS_COLLECTION_UTILITIES.put_line('Adding data for recursive program '  ||c_sub_programs_rec.Request_id);
	        insert_program_object_data( x_request_id    => c_sub_programs_rec.Request_id
						 ,x_stage_req_id  => c_sub_programs_rec.stage_req_id
						 ,x_object_name   => null
						 ,x_object_type   => null
						 ,x_refresh_type  => null
						 ,x_set_request_id => l_root_request_id);

	end loop;
  end loop;

  /** comment out the following code along with enhancement 4247289
     All Unimplemented MVs being actually processed are recorded into history table
     by  procedure bis_mv_refresh.consider_refresh
  ---- Update the request ids for the MVs which were marked as consider refresh
  open c_consider_mv ;
  fetch c_consider_mv  into consider_mv_req;
  close c_consider_mv  ;

  for c_refresh_mv_rec in c_refresh_mv  loop
       if( BIS_OBJ_REFRESH_HISTORY_PKG.Update_Row
	      ( p_Prog_request_id      => c_refresh_mv_rec.request_id
	       ,p_new_Prog_request_id  => consider_mv_req
	       ,p_Last_update_date     => sysdate
	       ,p_Last_updated_by      =>  g_current_user_id     )) then
	      BIS_COLLECTION_UTILITIES.put_line('****Updated request for Mvs which were dummy refreshed*********');
       else
	      BIS_COLLECTION_UTILITIES.put_line('******Update for consider refresh failed********');
	end if;
  end loop;
  **/

  --update request_set table for completion status and date data.
        update_rs_stage_dates(l_root_request_id);

  -- Get data for the History program (current program)
  -- and update its stage and program completion date and status.
-- run following only if the program is running as the part of the request set
 if(is_prog_part_of_rs) then
	  OPEN c_get_stage(FND_GLOBAL.conc_request_id);
	  FETCH c_get_stage into l_rs_history_stage;
	  CLOSE c_get_stage;

	  if((BIS_RS_PROG_RUN_HISTORY_PKG.Update_Row( p_Set_request_id => l_root_request_id
						    , p_Stage_request_id  => l_rs_history_stage
						    , p_Request_id	  => FND_GLOBAL.conc_request_id
						    , p_Status_code       => 'C'
						    , p_Phase_code	  => 'C'
						    , p_Completion_date   => sysdate
						    , p_Last_update_date  => sysdate
						    , p_Last_updated_by   => g_current_user_id
						    , p_completion_text   => g_completion_status))
	      and (BIS_RS_STAGE_RUN_HISTORY_PKG.Update_Row (p_Request_id => l_rs_history_stage
				, p_Set_request_id   =>l_root_request_id
				, p_Completion_date  => sysdate
				, p_Status_code      => 'C'
				, p_phase_code       => 'C'
				, p_Last_update_date => sysdate
				, p_Last_updated_by  =>g_current_user_id
				, p_completion_text   => g_completion_status))
		) then

	    --BIS_COLLECTION_UTILITIES.put_line('****Program and stage status for current request updated sucessfully********');
	    p_dummy_flag	:= 'Y';
	  else
	    BIS_COLLECTION_UTILITIES.put_line('****Failed during setting Program and stage status for current request*********');
	  end if;
  end if;
  -- Collect Information such as row count, tablespace name for Objects
  capture_object_info(l_root_request_id);
  -- as fnd does not put completion text for requests completing with warning.
  -- but we will update in our code
  update_warn_compl_txt(l_root_request_id);
  -- call API to update report's last_update_date
  update_report_date;
EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in RSG History Collection program, ' ||  sqlerrm);
     --update request_set table for completion status and date data.
        update_rs_stage_dates(l_root_request_id);
      errbuf := sqlerrm;
     retcode := sqlcode;
     l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
end rsg_history_report;

/*
 Enh#3473874
 This program purges historical data depending on profile option value.
*/
procedure purgeHistory  is
history_days number;

cursor rs_run is
select request_id from  BIS_RS_RUN_HISTORY
where last_update_date <= (sysdate-history_days);

cursor rs_prog_run(p_set_rq_id number) is
select request_id from  BIS_RS_PROG_RUN_HISTORY
where set_request_id = p_set_rq_id;

begin
  history_days := fnd_profile.value('BIS_BIA_REQUESTSET_HISTORY');
  if (history_days is  null ) then
     history_days := 90;
  end if;

for rs_run_rec in rs_run loop
	--delete object data first
	for rs_prog_run_rec in rs_prog_run(rs_run_rec.request_id) loop
	   BIS_OBJ_REFRESH_HISTORY_PKG.Delete_Row(rs_prog_run_rec.request_id);
	end loop;

     -- then delete program data and stage data
     BIS_RS_PROG_RUN_HISTORY_PKG.Delete_Row(rs_run_rec.request_id);
     BIS_RS_STAGE_RUN_HISTORY_PKG.Delete_Row(rs_run_rec.request_id);
end loop;

BIS_RS_RUN_HISTORY_PKG.Delete_Row(sysdate-history_days);
commit;

EXCEPTION
  when others then
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in purgeHistory ' ||  sqlerrm);
     raise;
 end purgeHistory;


/*
 Enh#3473874
This API Gets called from three places. 1. From MV refresh Program  2. BSC Wrapper 3. History collection
This handles following conditions
1. If program called with program id alone then it founds objects and inserts
2. If program called with both program id and object details then it just inserts
3. It always first check if the records is there. If there updates else inserts
4. This programs also calls api to get space usage details of every object.
*/
procedure insert_program_object_data (x_request_id	IN	 NUMBER
                                     ,x_stage_req_id	IN	NUMBER
                                     ,x_object_name     IN	VARCHAR2
                                     ,x_object_type     IN	VARCHAR2
                                     ,x_refresh_type	IN	VARCHAR2
				     ,x_set_request_id	IN	NUMBER)
IS
  request_id   number;
  l_root_request_id  number;

  cursor request_id_exists is
    select 1 from BIS_RS_PROG_RUN_HISTORY
    where Request_id = x_request_id;

  cursor request_details is
    select program_application_id,
      req.concurrent_program_id,
      Status_code,
      Phase_code,
      actual_start_date,
      actual_completion_date,
      completion_text,
      concurrent_program_name
    from fnd_concurrent_requests req, fnd_concurrent_programs prog
    where request_id = x_request_id and req.concurrent_program_id = prog.concurrent_program_id
    and req.program_application_id = prog.application_id;

    req_details_rec request_details%rowtype;

  --for objects data
  l_Object_row_count		number;
  l_Object_space_usage		number;
  l_Tablespace_name		dba_segments.TABLESPACE_NAME%type;
  l_Free_tablespace_size	number;

  cursor c_objects is
    select linkage.OBJECT_TYPE obj_type,
      linkage.object_name obj_name,
      linkage.refresh_mode obj_refresh_mode
    from BIS_RS_PROG_RUN_HISTORY prog,
      fnd_concurrent_programs fnd,
      bis_obj_prog_linkages linkage
    where prog.request_id = x_request_id
      and prog.program_id = fnd.CONCURRENT_PROGRAM_ID
      and prog.prog_app_id = fnd.application_id
      and linkage.CONC_PROGRAM_NAME = fnd.CONCURRENT_PROGRAM_NAME
      and linkage.CONC_APP_ID = fnd.application_id
      and linkage.ENABLED_FLAG = 'Y'
      and fnd.CONCURRENT_PROGRAM_NAME not in ('BIS_MV_REFRESH','BIS_RSG_PREP','BIS_RSG_FINAL',
				     'BIS_BIA_RSG_VALIDATION','BIS_BIA_RSG_MLOG_CAD',
				     'BIS_MV_DUMMY_REFRESH','BIS_LAST_REFRESH_DATE_CONC',
				     'BIS_BIA_RSG_LOG_MGMNT','FNDGTST','BSC_DELETE_DATA_IND',
				     'BSC_REFRESH_DIM_IND','BSC_REFRESH_SUMMARY_IND','BIS_BIA_STATS_TABLE');

  c_objects_rec c_objects%rowtype;

BEGIN
  open request_details;
  fetch request_details into req_details_rec;
  close request_details;

  if (req_details_rec.concurrent_program_name = 'BIS_BIA_RS_STATUS_CHK') then
    return;
  end if;

  open request_id_exists;
  fetch request_id_exists into request_id;
  if (x_request_id is not null) then
    l_root_request_id := x_set_request_id;
    if (request_id_exists%NOTFOUND) then
      BIS_RS_PROG_RUN_HISTORY_PKG.Insert_Row
                                 ( p_Set_request_id	=> l_root_request_id
                                 , p_Stage_request_id	=> x_stage_req_id
                                 , p_Request_id		=> x_request_id
                                 , p_Program_id		=> req_details_rec.concurrent_program_id
                                 , p_Prog_app_id	=> req_details_rec.program_application_id
                                 , p_Status_code	=> req_details_rec.Status_code
                                 , p_Phase_code		=> req_details_rec.Phase_code
                                 , p_Start_date		=> req_details_rec.actual_start_date
                                 , p_Completion_date	=> req_details_rec.actual_completion_date
                                 , p_Creation_date      => sysdate
                                 , p_Created_by         => g_current_user_id
                                 , p_Last_update_date   => sysdate
                                 , p_Last_updated_by    => g_current_user_id
                                 , p_completion_text    => req_details_rec.completion_text
                                 );
    else
        --if request already exists then update status code , completion date and stage id.
       if (BIS_RS_PROG_RUN_HISTORY_PKG.update_row
                                    ( p_Set_request_id   => l_root_request_id
                                     , p_Stage_request_id => x_stage_req_id
                                     , p_Request_id	   => x_request_id
                                     , p_Status_code	   => req_details_rec.Status_code
                                     , p_Phase_code	   => req_details_rec.Phase_code
                                     , p_Completion_date   => req_details_rec.actual_completion_date
                                     , p_Last_update_date  =>  sysdate
                                     , p_Last_updated_by   => g_current_user_id
                                     , p_completion_text    => req_details_rec.completion_text) ) then
         p_dummy_flag	:= 'Y';
       else
	 BIS_COLLECTION_UTILITIES.put_line('***Update failed for request id '||x_request_id);
       end if;
    end if;
    close request_id_exists;

    if ( x_object_name is not null) then
      -- get space usage details
      /* Commenting the code here; as this api is called from Multiple programs &
       * Finding Tablespace, Row Count causes performance issue with programs like MV Refresh
       * Finally in RSG History Collection, we will find these details for all the objects.
       * The data collected might not be accurate, but then Product teams are ok with that.
       */
      /* get_space_usage_details(p_object_name	    => x_object_name
                             ,p_Object_type	    => x_object_type
                             ,p_Object_row_count    => l_Object_row_count
                             ,p_Object_space_usage    => l_Object_space_usage
                             ,p_Tablespace_name       => l_Tablespace_name
                             ,p_Free_tablespace_size  => l_Free_tablespace_size);
      */
      BIS_OBJ_REFRESH_HISTORY_PKG.Insert_Row(p_Prog_request_id      => x_request_id
                                            ,p_Object_type          => x_object_type
                                            ,p_Object_name          => x_object_name
                                            ,p_Refresh_type	    => x_refresh_type
                                            ,p_Object_row_count     => l_Object_row_count
                                            ,p_Object_space_usage   => l_Object_space_usage
                                            ,p_Tablespace_name      => l_Tablespace_name
                                            ,p_Free_tablespace_size => l_Free_tablespace_size
                                            ,p_Creation_date        => sysdate
                                            ,p_Created_by           => g_current_user_id
                                            ,p_Last_update_date     => sysdate
                                            ,p_Last_updated_by      => g_current_user_id
                                            );
    else
      for c_objects_rec in c_objects loop
           -- get space usage details
          get_space_usage_details(p_object_name	    => c_objects_rec.obj_name
                               ,p_Object_type	    => c_objects_rec.obj_type
                               ,p_Object_row_count  => l_Object_row_count
                               ,p_Object_space_usage => l_Object_space_usage
                               ,p_Tablespace_name    => l_Tablespace_name
                               ,p_Free_tablespace_size  => l_Free_tablespace_size
			       );
           BIS_OBJ_REFRESH_HISTORY_PKG.Insert_Row(p_Prog_request_id      => x_request_id
                                                ,p_Object_type          => c_objects_rec.obj_type
                                              ,p_Object_name          => c_objects_rec.obj_name
                                              ,p_Refresh_type	       => c_objects_rec.obj_refresh_mode
                                              ,p_Object_row_count     => l_Object_row_count
                                              ,p_Object_space_usage   => l_Object_space_usage
                                              ,p_Tablespace_name      => l_Tablespace_name
                                              ,p_Free_tablespace_size => l_Free_tablespace_size
                                              ,p_Creation_date        => sysdate
                                              ,p_Created_by           => g_current_user_id
                                              ,p_Last_update_date     => sysdate
                                              ,p_Last_updated_by      => g_current_user_id
                                              );
       end loop;
    end if;
  end if; --request id null

 EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in insert_program_object_data ' ||  sqlerrm);
     raise;
END insert_program_object_data;

/*
 Enh#3473874
 This program gets space usage details for given object name
*/
procedure get_space_usage_details( p_object_name	     IN			varchar2,
				    p_Object_type	     IN			varchar2,
				    p_Object_row_count	     OUT  NOCOPY	number,
				    p_Object_space_usage     OUT  NOCOPY	number,
				    p_Tablespace_name        OUT  NOCOPY	varchar2,
				    p_Free_tablespace_size   OUT  NOCOPY	number
				    )
is

  l_object_type   varchar2(30);

  CURSOR cObjInfo_table IS
    SELECT TABLESPACE_NAME Tblsp
    FROM all_tables
    WHERE TABLE_NAME = p_object_name
    and OWNER = BIS_CREATE_REQUESTSET.get_object_owner(p_object_name,l_object_type);

    /* Moving the code to find out the free tablespace out of this api
    CURSOR cFreeTableSpace IS
    SELECT SUM(bytes) FreeTablespace
    FROM dba_free_Space fs
    WHERE fs.tablespace_name = p_Tablespace_name ;
    */
     CURSOR cObjInfo_part IS
	select PARTITION_NAME , TABLESPACE_NAME
	from all_tab_partitions
	where table_name = p_object_name
	and table_owner =  BIS_CREATE_REQUESTSET.get_object_owner(p_object_name,l_object_type);

  TYPE curType IS REF CURSOR;
  cRowCount	        curType;

  l_stmt        	VARCHAR2(1000);
  l_row_count	        INTEGER;


  p_total_blocks		number;
  p_total_bytes			number;
  p_unused_blocks		number;
  p_unused_bytes		number;
  p_last_used_extent_file_id	number;
  p_last_used_extent_block_id	number;
  p_last_used_block		number;

begin

p_Object_space_usage := 0;

IF p_Object_type = 'MV_LOG' then
  l_object_type := 'TABLE';
ELSE
   l_object_type := p_Object_type;
END IF;


IF (l_object_type not in ('TABLE','MV')) THEN
     p_Object_row_count := null;
     p_Object_space_usage := null;
     p_Tablespace_name := null;
     p_Free_tablespace_size := null;
  ELSE
   -- get tablespace name associated to the object

	for cObjInfo_table_rec in cObjInfo_table loop
	    p_Tablespace_name := cObjInfo_table_rec.Tblsp;
	end loop;

	if (p_Tablespace_name is null) then -- if object is partitioned.
		BIS_COLLECTION_UTILITIES.put_line(p_object_name ||' is a partitioned object');
		for cObjInfo_part_rec in cObjInfo_part loop
			p_Tablespace_name := cObjInfo_part_rec.TABLESPACE_NAME;

			dbms_space.unused_space (BIS_CREATE_REQUESTSET.get_object_owner(p_object_name,l_object_type),
					      p_object_name,
					     'TABLE PARTITION',
					      p_total_blocks,
					      p_total_bytes,
					      p_unused_blocks,
					      p_unused_bytes,
					      p_last_used_extent_file_id,
					      p_last_used_extent_block_id,
					      p_last_used_block,
					      cObjInfo_part_rec.PARTITION_NAME);

			p_Object_space_usage := p_Object_space_usage + p_total_bytes;
		end loop;


	else
		   -- get object free space
		   dbms_space.unused_space (BIS_CREATE_REQUESTSET.get_object_owner(p_object_name,l_object_type),
					      p_object_name,
					     'TABLE',
					      p_total_blocks,
					      p_total_bytes,
					      p_unused_blocks,
					      p_unused_bytes,
					      p_last_used_extent_file_id,
					      p_last_used_extent_block_id,
					      p_last_used_block);

		p_Object_space_usage := p_total_bytes;
	end if;

	-- Bug#5195936 :: The query to find out the free table space is causing performance issue for product teams.
	--get tablespace free space
	/*	     for cFreeTableSpace_rec in cFreeTableSpace loop
				p_Free_tablespace_size := cFreeTableSpace_rec.FreeTablespace;
		     end loop;
	*/
        p_Free_tablespace_size := null;
	begin
	 --get object row count
	     l_stmt := 'SELECT COUNT(*) FROM '|| p_object_name;
	      OPEN cRowCount FOR l_stmt;
	      FETCH cRowCount INTO l_row_count;
	      p_Object_row_count := l_row_count;
	      CLOSE cRowCount;
	  exception
	  when others then
	      p_Object_row_count := null;
	  end;


   END IF;

  EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in get_space_usage_details for object  '||p_object_name|| '  ' ||  sqlerrm);
     raise;

end get_space_usage_details;

/*
 Enh#3473874
 This inserts the record in the BIS_RS_RUN_HISTORY table.
 This is called from history collection program if request set is of type gather statistics only
for all the case it will be called from preparation program
*/

PROCEDURE add_rsg_rs_run_record(p_request_set_id	IN NUMBER,
				p_request_set_appl_id	IN NUMBER,
				p_request_name		IN VARCHAR2,
				p_root_req_id		IN NUMBER)
IS
l_refresh_mode		varchar2(30);
l_force_full_refresh	varchar2(30);
l_request_set_id	number;
l_rs_phase_code		fnd_concurrent_requests.PHASE_CODE%type;
l_rs_status_code	fnd_concurrent_requests.STATUS_CODE%type;
l_completion_text       fnd_concurrent_requests.completion_text%type;

cursor request_set_details is
select PHASE_CODE ,STATUS_CODE,completion_text from fnd_concurrent_requests
where request_id = p_root_req_id;

BEGIN
   l_refresh_mode :=
    CASE get_refresh_mode(p_request_set_id,p_request_set_appl_id)
      WHEN 'ANAL'  THEN 'GATHER_STATS'
      WHEN 'INIT' THEN 'INIT_LOAD'
      ELSE 'INCR_LOAD'
    END;


  open request_set_details;
  fetch request_set_details into l_rs_phase_code,l_rs_status_code,l_completion_text;
  close request_set_details;

  BIS_RS_RUN_HISTORY_PKG.Insert_Row(
			  p_Request_set_id  =>	p_request_set_id
			, p_Set_app_id      =>	p_request_set_appl_id
			, p_request_set_name=>  p_request_name
			, p_Request_id      =>	 p_root_req_id
			, p_rs_refresh_type =>	l_refresh_mode
			, p_Start_date      =>	sysdate
			, p_Completion_date =>	null
			, p_Status_code     =>	l_rs_status_code
			, p_Phase_code	    =>	l_rs_phase_code
			, p_Creation_date   =>	sysdate
			, p_Created_by      =>	g_current_user_id
			, p_Last_update_date => sysdate
			, p_Last_updated_by  => g_current_user_id
                        , p_completion_Text  => l_completion_text
                        );

 EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in add_rsg_rs_run_record ' ||  sqlerrm);
     raise;

END add_rsg_rs_run_record;

/*
 Enh#3473874
 This gets the refresh mode of request set.
*/

FUNCTION get_refresh_mode(p_request_set_id	IN NUMBER,
                          p_request_set_appl_id	IN NUMBER) RETURN VARCHAR2
IS

cursor refresh_mode is
select option_value
from bis_request_set_options
where request_set_name=( select request_set_name from fnd_request_sets
			  where request_set_id = p_request_set_id
			  and application_id = p_request_set_appl_id)
and  SET_APP_ID=p_request_set_appl_id
and option_name='REFRESH_MODE';

cursor analyze_object is
select option_value
from bis_request_set_options
where request_set_name=( select request_set_name from fnd_request_sets
			  where request_set_id = p_request_set_id
			  and application_id = p_request_set_appl_id)
and  SET_APP_ID=p_request_set_appl_id
and option_name='ANALYZE_OBJECT';

l_refresh_mode   refresh_mode%rowtype;
l_analyze_object analyze_object%rowtype;
BEGIN
	  OPEN refresh_mode;
	  FETCH refresh_mode INTO l_refresh_mode;
	  CLOSE refresh_mode;

	  if (l_refresh_mode.option_value is null) then
	    OPEN analyze_object;
	    FETCH analyze_object INTO l_analyze_object;
	    CLOSE analyze_object;
	    if (l_analyze_object.option_value ='Y') then
	      RETURN 'ANAL';
	    end if;
	  end if;
	  RETURN l_refresh_mode.option_value;

EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in get_refresh_mode ' ||  sqlerrm);
     raise;
END get_refresh_mode;

/**********
  Enh#3473874 This function will check is the data has been already collected for some particular request set.
*********/

FUNCTION if_program_already_ran(l_root_request_id IN NUMBER ) RETURN BOOLEAN IS
  cursor if_program_ran is
	select 1 from BIS_RS_RUN_HISTORY
	where REQUEST_ID = l_root_request_id and PHASE_CODE = 'C';
   prog_ran_rec  if_program_ran%rowtype;

   l_program_already_ran  boolean  := false;

BEGIN

	  for prog_ran_rec in if_program_ran loop
		l_program_already_ran := true;
	  end loop;

	 return l_program_already_ran;

 EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in if_program_already_ran ' ||  sqlerrm);
     raise;
END if_program_already_ran;


/**********
  Enh#3473874 This procedure will give requestset id and appln id given a request id.
*********/
FUNCTION get_req_set_details(p_request_set_id	   OUT    NOCOPY NUMBER,
			 p_request_set_appl_id	   OUT    NOCOPY NUMBER,
			 p_request_set_name        OUT    NOCOPY VARCHAR2,
			 p_root_request_id	   IN     NUMBER ) RETURN BOOLEAN  IS


cursor is_req_valid(p_req_id number) is
select
req.argument1,
req.argument2,
req.status_code,
req.phase_code
from
fnd_concurrent_requests req
where
req.request_id = p_req_id
and req.argument4 is null;

cursor get_rs_details is
select request_set_name from
fnd_request_sets
where application_id = p_request_set_appl_id and request_set_id = p_request_set_id;

get_rs_details_rec get_rs_details%rowtype;

l_status_code  fnd_concurrent_requests.status_code%type;
l_phase_code  fnd_concurrent_requests.phase_code%type;

BEGIN

	  open is_req_valid(p_root_request_id);
	  fetch is_req_valid into p_request_set_appl_id,p_request_set_id,l_status_code,l_phase_code;
	          if(l_phase_code ='C' and l_status_code ='X') then
		     return false;
		  end if;
	   close is_req_valid;

      --Added for bug 4184138
	for get_rs_details_rec in get_rs_details loop
		p_request_set_name := get_rs_details_rec.request_set_name;
		return true;
         end loop;

	 return false;

EXCEPTION
	WHEN OTHERS THEN
     return false;
END get_req_set_details;

/******
FND does not put Completion Text for the programs or stages which completed with warning
But we need to update the same in out tables otherwise it will N/A in out reports.
This procedure updted the completion text to "Completed with Error" for all the programs and stages
which comepleted with status as "Warning"
********/
PROCEDURE update_warn_compl_txt(p_root_req_id IN NUMBER) IS

cursor check_in_progs(root_req_id number) is
select request_id ,STAGE_REQUEST_ID from BIS_RS_PROG_RUN_HISTORY
where SET_REQUEST_ID = root_req_id and
      status_code = 'G' ;

check_in_progs_rec check_in_progs%rowtype;

cursor check_in_stages(root_req_id number) is
select request_id from BIS_RS_STAGE_RUN_HISTORY
where SET_REQUEST_ID = root_req_id and
      status_code = 'G' ;
check_in_stages_rec check_in_stages%rowtype;

BEGIN
	for check_in_progs_rec in  check_in_progs(p_root_req_id) loop
	        if(BIS_RS_PROG_RUN_HISTORY_PKG.Update_Row
		     (	 p_Set_request_id	=> p_root_req_id,
			 p_Stage_request_id 	=> check_in_progs_rec.STAGE_REQUEST_ID,
			 p_Request_id		=> check_in_progs_rec.request_id,
			 p_Last_update_date     => sysdate,
			 p_Last_updated_by      => g_current_user_id,
                         p_completion_text      => g_warning_status))  then

			 --BIS_COLLECTION_UTILITIES.put_line('Updated warning completion text ');
			  p_dummy_flag := 'Y';
		 else
			 BIS_COLLECTION_UTILITIES.put_line('Updating warning completion text for programs failed');
		end if;
	end loop;

	for check_in_stages_rec in check_in_stages(p_root_req_id) loop
		 if(BIS_RS_STAGE_RUN_HISTORY_PKG.Update_Row
			(p_Request_id	    =>  check_in_stages_rec.request_id	,
			 p_Set_request_id   =>  p_root_req_id,
			 p_Last_update_date =>  sysdate,
			 p_Last_updated_by  =>  g_current_user_id,
			 p_completion_text  =>  g_warning_status) ) then

			 --BIS_COLLECTION_UTILITIES.put_line('Updated warning completion text for satges');
			  p_dummy_flag := 'Y';
		 else
			 BIS_COLLECTION_UTILITIES.put_line('Updating warning completion text for stages failed');
		end if;
	end loop;


EXCEPTION
	WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in update_warning_completion_text ' ||  sqlerrm);
     raise;
END update_warn_compl_txt;

/*
We can not update the status for the request sets which were terminated as
our history collection program will not be called at all. And the entry will be always "Running". This will
affect our Page refresh status report.
Hence we will call this API in preparation program and Page refresh status program.
This API will update status for the request set which were terminated.
*/
PROCEDURE update_terminated_rs is

cursor terminate_rs is
select request_id from BIS_RS_RUN_HISTORY
where phase_code ='R' ;
terminate_rs_rec terminate_rs%rowtype;

cursor req_details(req_no number) is
select ACTUAL_COMPLETION_DATE,
phase_code,
status_code,
completion_text
from
fnd_concurrent_requests
where
request_id =req_no and
phase_code ='C' and
status_code ='X';

req_details_rec req_details%rowtype;

BEGIN
for terminate_rs_rec in terminate_rs loop
	for req_details_rec in req_details(terminate_rs_rec.request_id) loop
		if(BIS_RS_RUN_HISTORY_PKG.Update_Row( p_Request_id	   => terminate_rs_rec.request_id
						       ,p_Completion_date  => req_details_rec.ACTUAL_COMPLETION_DATE
						       ,p_Phase_code	   => req_details_rec.phase_code
						       ,p_Status_code	   => req_details_rec.status_code
						       ,p_Last_update_date => sysdate
						       ,p_Last_updated_by  => g_current_user_id
						       ,p_Completion_text  => req_details_rec.completion_text))	 then
		    --BIS_COLLECTION_UTILITIES.put_line('*****Updated Terminated Req sets with request id ' || terminate_rs_rec.request_id);
		    p_dummy_flag	:= 'Y';
		  else
		    BIS_COLLECTION_UTILITIES.put_line('************Updation of Terminated Request sets failed*****************');
		  end if;
	end loop;
end loop;
EXCEPTION
	WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in update_terminated_rs ' ||  sqlerrm);
     raise;
END update_terminated_rs;


/* This procedure updates the correct start time and end time for all the stages and request set.*/
PROCEDURE update_rs_stage_dates(p_root_req_id IN NUMBER) IS

 --for updating request set status
  cursor c_request_status is
    select status_code from BIS_RS_PROG_RUN_HISTORY
    where set_request_id =p_root_req_id
      and (status_code ='E' or status_code ='G')
      --added for Bug 4173989
      union
     select status_code from BIS_RS_STAGE_RUN_HISTORY
    where set_request_id = p_root_req_id
      and (status_code ='E' or status_code ='G') ;

  cursor c_get_rs_start_time is
    select min(stg.start_date) start_date
    from bis_rs_stage_run_history stg
    where SET_REQUEST_ID = p_root_req_id;

 rs_start_date date;

 cursor c_stages is
 select request_id
 from bis_rs_stage_run_history stg
 where SET_REQUEST_ID = p_root_req_id;

 cursor c_stages_dates(stage_req_id number) is
select min(START_DATE) stage_start_date,  max(COMPLETION_DATE) stage_com_date
from bis_rs_prog_run_history
where STAGE_REQUEST_ID =stage_req_id;

  is_request_err	boolean :=false;
  is_request_warn	boolean :=false;
  l_status_code		BIS_RS_RUN_HISTORY.status_code%type;
  l_Completion_text	varchar2(2000);
  l_stage_start_date	Date;
  l_stage_end_date	Date;
BEGIN

--compute stage start and end time depending upon programs within it.

for c_stages_rec in c_stages loop
  for c_stages_dates_rec in c_stages_dates(c_stages_rec.request_id) loop
	l_stage_start_date := c_stages_dates_rec.stage_start_date;
	l_stage_end_date   := c_stages_dates_rec.stage_com_date;
  end loop;
	if (BIS_RS_STAGE_RUN_HISTORY_PKG.Update_Row(p_Request_id        => c_stages_rec.request_id
				, p_Set_request_id   => p_root_req_id
				, p_start_date       => l_stage_start_date
				, p_Completion_date  => l_stage_end_date
				, p_Last_update_date => sysdate
				, p_Last_updated_by  =>g_current_user_id)) then
			p_dummy_flag := 'Y';
	else
	    BIS_COLLECTION_UTILITIES.put_line('Stage updation for start date and end date failed for stage with request id ' ||c_stages_rec.request_id );
	end if;


end loop;
--compute request status depending upon the porgram and stage status
 for c_request_status_rec in c_request_status loop
	if c_request_status_rec.status_code = 'E' then
		is_request_err := true;
	else
		is_request_warn := true;
	end if;
  end loop;

 if(is_request_err) then
    l_status_code := 'E';
    l_Completion_text := g_error_status;
  else
	   if( is_request_warn) then
	    l_status_code := 'G';
	    l_Completion_text := g_warning_status;
	  else
	    l_status_code := 'C';
	    l_Completion_text := g_completion_status;
	  end if;
  end if;

--compute request set start and end time depending upon stage start time and completion time.
   OPEN c_get_rs_start_time;
  FETCH c_get_rs_start_time INTO rs_start_date;
  CLOSE c_get_rs_start_time;

  if(BIS_RS_RUN_HISTORY_PKG.Update_Row( p_Request_id   => p_root_req_id
                                       ,p_start_date => rs_start_date
                                       ,p_Completion_date  => sysdate
                                       ,p_Phase_code   => 'C'
                                       ,p_Status_code  => l_status_code
                                       ,p_Last_update_date  => sysdate
                                       ,p_Last_updated_by   =>g_current_user_id
                                       ,p_Completion_text => l_Completion_text))	 then
    BIS_COLLECTION_UTILITIES.put_line('************History Data for this request set is collected sucessfully');
  else
    BIS_COLLECTION_UTILITIES.put_line('************Updation of Request Set status failed*****************');
  end if;

EXCEPTION
	WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in update_rs_stage_dates ' ||  sqlerrm);
     raise;
END update_rs_stage_dates;

/*
We need to have last_update_date at the bottom of the report for all our reports.
This API updates these seeded report's last_update_date in bis_obj_properties table.
*/
PROCEDURE update_report_date IS

BEGIN
  	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_REQ_DETAILS_PGE',sysdate);
	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_SETS_DET_PGE',sysdate);
	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_SETS_LVL_PGE',sysdate);
	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_SPACE_DET_PGE',sysdate);
	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_SUB_REQS_PGE',sysdate);
	bis_impl_dev_pkg.update_obj_last_refresh_date('REPORT','BIS_BIA_RSG_TABLESPACE_PGE',sysdate);

EXCEPTION
	WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in update_report_date ' ||  sqlerrm);
     raise;
END update_report_date;

/*
 * Bug#5195936 - For performance reasons, free tablespace & Row Count is no longer calculated while
 * inserting object data. Hence this api to populate this information in BIS_OBJ_REFRESH_HISTORY
 */
PROCEDURE capture_object_info(p_root_request_id IN NUMBER) IS
  CURSOR get_objects IS
    SELECT object_name, object_type, prog_Request_id
    FROM BIS_RS_PROG_RUN_HISTORY prog, BIS_OBJ_REFRESH_HISTORY obj
    WHERE set_request_id = p_root_request_id AND obj.prog_request_id = prog.request_id;

  --for objects data
  l_Object_row_count		NUMBER;
  l_Object_space_usage		NUMBER;
  l_Tablespace_name		dba_segments.TABLESPACE_NAME%type;
  l_Free_tablespace_size	NUMBER;
  l_success                     BOOLEAN;
BEGIN
  BIS_COLLECTION_UTILITIES.put_line('Started :: Updating Object Details');
  FOR get_objects_rec IN get_objects LOOP
    get_space_usage_details(p_object_name	    => get_objects_rec.object_name
                           ,p_Object_type	    => get_objects_rec.object_type
                           ,p_Object_row_count      => l_Object_row_count
                           ,p_Object_space_usage    => l_Object_space_usage
                           ,p_Tablespace_name       => l_Tablespace_name
                           ,p_Free_tablespace_size  => l_Free_tablespace_size);

    l_success := BIS_OBJ_REFRESH_HISTORY_PKG.UPDATE_ROW(p_Prog_request_id      => get_objects_rec.prog_Request_id
                                                       ,p_Object_type          => get_objects_rec.object_type
                                                       ,p_Object_name          => get_objects_rec.object_name
                                                       ,p_Object_row_count     => l_Object_row_count
                                                       ,p_Object_space_usage   => l_Object_space_usage
                                                       ,p_Tablespace_name      => l_Tablespace_name
                                                       ,p_Free_tablespace_size => l_Free_tablespace_size
                                                       ,p_Last_update_date     => sysdate
                                                       ,p_Last_updated_by      => g_current_user_id);
    IF (NOT l_success) THEN
      BIS_COLLECTION_UTILITIES.put_line('Failed to Update Row for Object Refresh History in capture_object_info()');
    END IF;
  END LOOP;
  BIS_COLLECTION_UTILITIES.put_line('Completed :: Updating Object Details');
EXCEPTION
  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Error in capture_object_info :: '||sqlerrm);
    RAISE;
END capture_object_info;


END BIS_COLL_RS_HISTORY;

/
