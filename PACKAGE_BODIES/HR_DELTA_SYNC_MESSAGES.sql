--------------------------------------------------------
--  DDL for Package Body HR_DELTA_SYNC_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DELTA_SYNC_MESSAGES" as
/* $Header: perhrhdrir.pkb 120.13 2008/03/19 09:50:29 sathkris noship $ */

 /*Procedure to update the record into hr_psft_sync_run table begins*/
	PROCEDURE update_psft_sync_run
		(p_status number
		 ,p_process_name varchar2
		 ,p_run_date  date
		 ,errbuf  OUT NOCOPY VARCHAR2
		 ,retcode OUT NOCOPY VARCHAR2)
		IS
		l_status varchar2(10);

		BEGIN

		if p_status = 1 then
		    l_status := 'COMPLETED';
		elsif p_status = 2 then
		    l_status := 'STARTED';
		elsif p_status = 3 then
		    l_status := 'ERROR';
		end if;

		update hr_psft_sync_run
		set status = l_status where process = p_process_name
		and run_date =p_run_date;
		commit;

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		EXCEPTION WHEN OTHERS THEN
		        errbuf := errbuf||SQLERRM;
		        retcode := '1';
		        FND_FILE.put_line(fnd_file.log,'Error in update_psft_sync_run: '||SQLCODE);
		        FND_FILE.NEW_LINE(FND_FILE.log, 1);
		        FND_FILE.put_line(fnd_file.log,'Error Msg: '||substr(SQLERRM,1,700));

		END update_psft_sync_run;
 /*Procedure to update the record into hr_psft_sync_run table ends*/

  /*Procedure to insert the record into hr_psft_sync_run table begins*/
		 PROCEDURE insert_psft_sync_run
		 (p_status number
		 ,p_process_name varchar2
		 ,errbuf  OUT NOCOPY VARCHAR2
		 ,retcode OUT NOCOPY VARCHAR2)
		IS
		l_status varchar2(10);
		BEGIN

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		if p_status = 1 then
		    l_status := 'COMPLETED';
		elsif p_status = 2 then
		    l_status := 'STARTED';
		elsif p_status = 3 then
		    l_status := 'ERROR';
		end if;

		INSERT INTO hr_psft_sync_run(run_date,status,process)
		Values(sysdate,l_status,p_process_name);
		commit;

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		EXCEPTION WHEN OTHERS THEN
		        errbuf := errbuf||SQLERRM;
		        retcode := '1';
		        FND_FILE.put_line(fnd_file.log,'Error in insert_psft_sync_run: '||SQLCODE);
		        FND_FILE.NEW_LINE(FND_FILE.log, 1);
		        FND_FILE.put_line(fnd_file.log,'Error Msg: '||substr(SQLERRM,1,700));

		END insert_psft_sync_run;
  /*Procedure to insert the record into hr_psft_sync_run table ends*/

 /*Procedure to extract the delta synch data for country begins here*/

		PROCEDURE hr_country_delta_sync(errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id in NUMBER)
		is
		 p_cntry_code fnd_territories_vl.territory_code%type;
		 p_cntry_desc fnd_territories_vl.territory_short_name%type;
		 p_obs_flag fnd_territories_vl.obsolete_flag%type;
		 p_effective_date  date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		 p_last_update_date date;
		 p_unique_key  number;
		 p_row_id    rowid;
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);


	 	 cursor fet_cntry_fsync(p_max_run_date date) is
		 select ft.territory_code,
		 ft.territory_short_name ,
		 ft.territory_code,ft.obsolete_flag,ft.row_id,ft.last_update_date
		 from fnd_territories_vl ft
		 where  ft.last_update_date > p_max_run_date
		 and    (ft.territory_code,ft.row_id) not in (select cntry.country_code,cntry.row_id
		 from hr_country_delta_sync cntry
		 where ft.territory_code = cntry.country_code
		 and ft.row_id = cntry.row_id
		 and ft.last_update_date <= cntry.last_update_date
		 and   cntry.status in ('QUEUED','SENT'));

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_delta_status
		 is
		 select country_code,row_id,event_key from
		 hr_country_delta_sync
		 where status = 'QUEUED';

		 p_country_code varchar2(5);
		 p_row1_id rowid;
		 p_lstupd_date date;

		 cursor fet_cntry_sync(p_country_code varchar2,p_row1_id varchar2)
		 is
		select ft.territory_code,
		 ft.territory_short_name ,
		 ft.territory_code,ft.obsolete_flag,ft.row_id,ft.last_update_date
		 from fnd_territories_vl ft
		 where territory_code = p_country_code
		 and row_id = p_row1_id;

 		 p_cntry_delta_sts varchar2(10);
		 p_event_key_gen varchar2(50);

		 cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'COUNTRY_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'COUNTRY_FULL_SYNC'
		 and    status = 'COMPLETED';

		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'COUNTRY_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		 l_dummy number;
		 p_max_run_date date;

		 begin

		 	open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then
		 			FND_FILE.NEW_LINE(FND_FILE.log, 1);
					FND_FILE.put_line(fnd_file.log,'Country Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
					hr_delta_sync_messages.insert_psft_sync_run(2,'COUNTRY_DELTA_SYNC',errbuf,retcode);



					open fet_psft_run_dt;
		 			fetch fet_psft_run_dt into p_max_run_date;
		 			close fet_psft_run_dt;

		 			if p_max_run_date is null
					then
					open fet_psft_run_dt1;
					fetch fet_psft_run_dt1 into p_max_run_date;
					close fet_psft_run_dt1;
					end if;

					open fet_delta_status;
					loop
					  fetch fet_delta_status into p_country_code,p_row1_id,p_event_key_gen;

                      if fet_delta_status%found then

				 update hr_country_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_cntry_sync(p_country_code,p_row1_id);
        				  fetch fet_cntry_sync into p_cntry_code,p_cntry_desc,p_cntry_code,p_obs_flag,p_row_id,p_last_update_date;
        				  if fet_cntry_sync%found then

				                select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            					insert into hr_country_delta_sync(COUNTRY_CODE,COUNTRY_DESCRIPTION,ROW_ID,
                                COUNTRY_2CHAR,OBSOLETE_FLAG,LAST_UPDATE_DATE,STATUS,EFFECTIVE_STATUS_DATE,EVENT_KEY)
                                 values(p_cntry_code,p_cntry_desc,p_row_id,p_cntry_code,p_obs_flag,p_last_update_date,'QUEUED',p_effective_date,
            					p_cntry_code||'-'||to_char(p_unique_key));
                                commit;

            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'CNTRY',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_cntry_code||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => p_cntry_code||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);

                                          open csr_gen_msg(p_cntry_code||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then
                                                if p_gen_status not in ('0','10') then
			                                         FND_FILE.NEW_LINE(FND_FILE.log, 1);
                                                     FND_FILE.put_line(fnd_file.log,'Country Delta Synch Data Extraction Ends for the document id '||p_cntry_code||'-'||to_char(p_unique_key)
						     ||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				                        end if;
                                                  end if;
                                         close csr_gen_msg;

                            end if;
                            close fet_cntry_sync;
                           else
                              exit;
                            end if;
                    end loop;

                    close fet_delta_status;

		 			open fet_cntry_fsync(p_max_run_date);
		            loop
				             fetch fet_cntry_fsync into p_cntry_code,p_cntry_desc,p_cntry_code,p_obs_flag,p_row_id,p_last_update_date;
		            		 if 	fet_cntry_fsync%found then
									select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
									insert into hr_country_delta_sync(COUNTRY_CODE,COUNTRY_DESCRIPTION,ROW_ID,
                                    COUNTRY_2CHAR,OBSOLETE_FLAG,LAST_UPDATE_DATE,STATUS,EFFECTIVE_STATUS_DATE,EVENT_KEY)
                                    values(p_cntry_code,p_cntry_desc,p_row_id,p_cntry_code,p_obs_flag,p_last_update_date,'QUEUED',p_effective_date,
									p_cntry_code||'-'||to_char(p_unique_key));
                                    commit;
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'CNTRY',l_params);
						            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
						            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_cntry_code||'-'||to_char(p_unique_key), l_params);
						            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
						                           p_event_key => p_cntry_code||'-'||to_char(p_unique_key),
						                           p_parameters => l_params);

						           		open csr_gen_msg(p_cntry_code||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then
                                                if p_gen_status not in ('0','10') then
			                             FND_FILE.NEW_LINE(FND_FILE.log, 1);
                                                     FND_FILE.put_line(fnd_file.log,'Country Delta Synch Data Extraction Ends for the document id '||p_cntry_code||'-'||to_char(p_unique_key)
						     ||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				     end if;
                                                  end if;
                                         close csr_gen_msg;
				              else
				                exit;
				             end if;
					end loop;
		             		close fet_cntry_fsync;

					  hr_delta_sync_messages.update_psft_sync_run(1,'COUNTRY_DELTA_SYNC',p_effective_date,errbuf,retcode);
					  FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  FND_FILE.put_line(fnd_file.log,'Country Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		 	end if;

		  	exception
        	when OTHERS then
		    hr_delta_sync_messages.update_psft_sync_run(3,'COUNTRY_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Country Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		 end hr_country_delta_sync;

	/*Procedure to extract the delta synch data for country ends here*/

	/*Procedure to extract the delta synch data for state begins here*/

		PROCEDURE hr_state_delta_sync (errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id in NUMBER)
		is

		 p_cntry_code  fnd_territories_vl.territory_code%type;
		 p_state_code  fnd_common_lookups.lookup_code%type;
		 p_state_desc  fnd_common_lookups.meaning%type;
		 p_enable_flag fnd_common_lookups.enabled_flag%type;
		 p_effective_date date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		 p_unique_key  number;
		p_last_update_date date;
    		p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);

		 cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'STATE_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'STATE_FULL_SYNC'
		 and    status = 'COMPLETED';

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_state_sync(p_max_run_date date) is
		 select ft.territory_code,fcl.lookup_code,fcl.meaning,fcl.enabled_flag,fcl.last_update_date
		 from fnd_common_lookups fcl,fnd_territories_vl ft
		 where fcl.lookup_type = (ft.territory_code ||'_STATE')
		 and fcl.last_update_date > p_max_run_date
		 and (ft.territory_code ,fcl.lookup_code) not in (select state.country_code,state.state_code
		 from hr_state_delta_sync state
		 where ft.territory_code = state.country_code
		 and   fcl.lookup_code = state.state_code
		and   ft.last_update_date <= state.last_update_date
		 and   state.status in ('QUEUED','SENT'));

		 cursor fet_delta_status
		 is
		 select country_code,state_code,event_key from
		 hr_state_delta_sync
		 where status = 'QUEUED';

		 p_country_code varchar2(5);
		 p_stt_code varchar2(30);
		 p_lstupd_date date;

		 cursor fet_state_qsync(p_country_code varchar2,p_stt_code varchar2)
		 is
         select ft.territory_code,fcl.lookup_code,fcl.meaning,fcl.enabled_flag,fcl.last_update_date
		 from fnd_common_lookups fcl,fnd_territories_vl ft
		 where fcl.lookup_type = (ft.territory_code ||'_STATE')
		 and   fcl.lookup_type = (p_country_code||'_STATE')
		 and   fcl.lookup_code = p_stt_code;

 		 p_cntry_delta_sts varchar2(10);
		 p_event_key_gen varchar2(50);


		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'STATE_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		 l_dummy number;
		 p_max_run_date date;

		 begin

			open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		 	close fet_psft_sync;
		 	if l_dummy = 0
		 		then
				FND_FILE.NEW_LINE(FND_FILE.log, 1);
				FND_FILE.put_line(fnd_file.log,'State Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
				hr_delta_sync_messages.insert_psft_sync_run(2,'STATE_DELTA_SYNC',errbuf,retcode);

		 		open fet_psft_run_dt;
		 		fetch fet_psft_run_dt into p_max_run_date;
		 		close fet_psft_run_dt;

				if p_max_run_date is null
		 		then
		 		open fet_psft_run_dt1;
		 		fetch fet_psft_run_dt1 into p_max_run_date;
		 		close fet_psft_run_dt1;
		 		end if;

		 			open fet_delta_status;
					loop
					  fetch fet_delta_status into p_country_code,p_stt_code,p_event_key_gen;

                      if fet_delta_status%found then

                      update hr_state_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_state_qsync(p_country_code,p_stt_code);
        				  	fetch fet_state_qsync into p_cntry_code,p_state_code,p_state_desc,p_enable_flag,p_last_update_date;
        				    if fet_state_qsync%found then

				               select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            					insert into hr_state_delta_sync(COUNTRY_CODE,STATE_CODE,
                                STATE_DESCRIPTION,ENABLE_FLAG,STATUS,EFFECTIVE_STATUS_DATE,
                                LAST_UPDATE_DATE,EVENT_KEY )
                                 values(p_cntry_code,p_state_code,p_state_desc,p_enable_flag,'QUEUED',p_effective_date,p_last_update_date,p_state_code||'-'||to_char(p_unique_key));
		                        commit;

            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'STATE',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_state_code||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => p_state_code||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);
                            end if;
                            close fet_state_qsync;

                                 open csr_gen_msg(p_state_code||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

            		            if p_gen_status not in ('0','10') then
            						FND_FILE.NEW_LINE(FND_FILE.log, 1);
            	  					FND_FILE.put_line(fnd_file.log,'State Delta Synch Data Extraction Ends for the document id '||p_state_code||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
            		            end if;
            		            end if;
            		            close csr_gen_msg;

                          else
                             exit;
                            end if;
                    end loop;
                    close fet_delta_status;

		  		open fet_state_sync(p_max_run_date);
		  		loop
		    		fetch fet_state_sync into p_cntry_code,p_state_code,p_state_desc,p_enable_flag,p_last_update_date;
		            if 	fet_state_sync%found then
                    select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
		            insert into hr_state_delta_sync(COUNTRY_CODE,STATE_CODE,
                                STATE_DESCRIPTION,ENABLE_FLAG,STATUS,EFFECTIVE_STATUS_DATE,
                                LAST_UPDATE_DATE,EVENT_KEY ) values(p_cntry_code,p_state_code,p_state_desc,p_enable_flag,'QUEUED',p_effective_date,p_last_update_date,p_state_code||'-'||to_char(p_unique_key));
		            commit;

		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'STATE',l_params);
		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_state_code||'-'||to_char(p_unique_key), l_params);
		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
		                           p_event_key => p_state_code||'-'||to_char(p_unique_key),
		                           p_parameters => l_params);

		                       open csr_gen_msg(p_state_code||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

            		            if p_gen_status not in ('0','10') then
            						FND_FILE.NEW_LINE(FND_FILE.log, 1);
            	  					FND_FILE.put_line(fnd_file.log,'State Delta Synch Data Extraction Ends for the document id '||p_state_code||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
            		            end if;
            		            end if;
            		            close csr_gen_msg;
		            else
		                exit;
		             end if;
		    	end loop;

		    	close fet_state_sync;

		 	hr_delta_sync_messages.update_psft_sync_run(1,'STATE_DELTA_SYNC',p_effective_date,errbuf,retcode);
		 	FND_FILE.NEW_LINE(FND_FILE.log, 1);
    	    FND_FILE.put_line(fnd_file.log,'State Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

		 end if;


		  exception


		  when others then
		    hr_delta_sync_messages.update_psft_sync_run(3,'STATE_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in State Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		 end hr_state_delta_sync;

 	/*Procedure to extract the delta synch data for state ends here*/

 	/*Procedure to extract the delta synch data for location begins here*/
 	PROCEDURE  hr_location_delta_sync (errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id in NUMBER)

		is


		p_bg_id  		hr_locations_all.business_group_id%type;
    		p_loc_id 		hr_locations_all.LOCATION_ID%type;
    		p_active_date 		date;
    		p_effecive_status	varchar2(10);
    		p_loc_code 		hr_locations_all.LOCATION_CODE%type;
    		p_loc_desc		hr_locations_all.DESCRIPTION%type;
    		p_loc_style 		hr_locations_all.STYLE%type;
    		p_add_line_1		hr_locations_all.ADDRESS_LINE_1%type;
    		p_add_line_2		hr_locations_all.ADDRESS_LINE_2%type;
    		p_add_line_3		hr_locations_all.ADDRESS_LINE_3%type;
    		p_town_or_city		hr_locations_all.TOWN_OR_CITY%type;
    		p_country		hr_locations_all.COUNTRY%type;
    		p_postal_code		hr_locations_all.POSTAL_CODE%type;
    		p_region_1		hr_locations_all.REGION_1%type;
    		p_region_2		hr_locations_all.REGION_2%type;
    		p_region_3		hr_locations_all.REGION_3%type;
    		p_tel_no_1		hr_locations_all.TELEPHONE_NUMBER_1%type;
    		p_tel_no_2		hr_locations_all.TELEPHONE_NUMBER_2%type;
    		p_tel_no_3		hr_locations_all.TELEPHONE_NUMBER_3%type;
    		p_loc_info_13		   hr_locations_all.LOC_INFORMATION13%type;
    		p_loc_info_14		   hr_locations_all.LOC_INFORMATION14%type;
    		p_loc_info_15		   hr_locations_all.LOC_INFORMATION15%type;
    		 p_loc_info_16		   hr_locations_all.LOC_INFORMATION16%type;
    		 p_loc_info_17		   hr_locations_all.LOC_INFORMATION17%type;
    		 p_loc_info_18		   hr_locations_all.LOC_INFORMATION18%type;
    		 p_loc_info_19		   hr_locations_all.LOC_INFORMATION19%type;
    		 p_loc_info_20		   hr_locations_all.LOC_INFORMATION20%type;
		 p_effective_date	date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		 p_unique_key  number;
		 p_last_update_date date;
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);

		        cursor fet_psft_sync is
		 		select count('x')
		 		from   hr_psft_sync_run
		 		where  process = 'LOC_DELTA_SYNC'
		 		and    run_date < p_effective_date
		 		and    status = 'STARTED';

		 		cursor fet_psft_run_dt is
		 		select max(run_date)
		 		from   hr_psft_sync_run
		 		where  process = 'LOC_DELTA_SYNC'
		 		and    run_date < p_effective_date
		 		and    status = 'COMPLETED';


		 		cursor fet_psft_run_dt1 is
		 		select max(run_date)
		 		from   hr_psft_sync_run
		 		where  process = 'LOC_FULL_SYNC'
		 		and    status = 'COMPLETED';

		 		 l_dummy number;
		 		 p_max_run_date date;

		 cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		        cursor fet_loc_sync(p_max_run_date date) is
		        select  BUSINESS_GROUP_ID,
		        LOCATION_ID,
		        case when inactive_date is not null then inactive_date
		        else CREATION_DATE end,
		        case when inactive_date is not null then 'INACTIVE'
		        else 'ACTIVE' end,
		        LOCATION_CODE ,
		        DESCRIPTION,
		        STYLE,
		        COUNTRY,
		        ADDRESS_LINE_1,
		        ADDRESS_LINE_2,
		        ADDRESS_LINE_3,
		        TOWN_OR_CITY,
		        REGION_1,
		        REGION_2,
		        REGION_3,
		        POSTAL_CODE,
		        TELEPHONE_NUMBER_1,
		        TELEPHONE_NUMBER_2,
		        TELEPHONE_NUMBER_3,
		        LOC_INFORMATION13,
		        LOC_INFORMATION14,
				LOC_INFORMATION15,
				LOC_INFORMATION16,
				LOC_INFORMATION17,
				LOC_INFORMATION18,
				LOC_INFORMATION19,
				LOC_INFORMATION20,
				last_update_date

				from
				hr_locations_all loc
				where last_update_date > p_max_run_date
                and (loc.location_id,loc.business_group_id)not in(
                select sync.location_id,sync.business_group_id
                from hr_locn_delta_sync sync
                where loc.location_id = sync.location_id
                and  loc.business_group_id = sync.business_group_id
                and   loc.last_update_date <= sync.last_update_date
		        and   sync.status in ('QUEUED','SENT'));


        		 cursor fet_delta_status
        		 is
        		 select location_id,business_group_id,event_key from
        		 hr_locn_delta_sync
        		 where status = 'QUEUED';

        		 p_location_id number;
        		 p_business_group_id number;
        		 p_lstupd_date date;

        	    cursor fet_loc_qsync(p_location_id number,p_business_group_id number)
   		        is
                select  BUSINESS_GROUP_ID,
		        LOCATION_ID,
		        case when inactive_date is not null then inactive_date
		        else CREATION_DATE end,
		        case when inactive_date is not null then 'INACTIVE'
		        else 'ACTIVE' end,
		        LOCATION_CODE ,
		        DESCRIPTION,
		        STYLE,
		        COUNTRY,
		        ADDRESS_LINE_1,
		        ADDRESS_LINE_2,
		        ADDRESS_LINE_3,
		        TOWN_OR_CITY,
		        REGION_1,
		        REGION_2,
		        REGION_3,
		        POSTAL_CODE,
		        TELEPHONE_NUMBER_1,
		        TELEPHONE_NUMBER_2,
		        TELEPHONE_NUMBER_3,
		        LOC_INFORMATION13,
		        LOC_INFORMATION14,
				LOC_INFORMATION15,
				LOC_INFORMATION16,
				LOC_INFORMATION17,
				LOC_INFORMATION18,
				LOC_INFORMATION19,
				LOC_INFORMATION20,
				last_update_date

				from
				hr_locations_all loc
				where LOC.location_id = p_location_id
				and nvl(LOC.business_group_id,0) = nvl(p_business_group_id,0);

 		          p_cntry_delta_sts varchar2(10);
		          p_event_key_gen varchar2(50);



		begin

		 open fet_psft_sync;
		 fetch fet_psft_sync into l_dummy;
		 close fet_psft_sync;

		 if l_dummy = 0
		 then



			FND_FILE.NEW_LINE(FND_FILE.log, 1);
			FND_FILE.put_line(fnd_file.log,'Location Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
     	    hr_delta_sync_messages.insert_psft_sync_run(2,'LOC_DELTA_SYNC',errbuf,retcode);

		 	open fet_psft_run_dt;
		 	fetch fet_psft_run_dt into p_max_run_date;
		 	close fet_psft_run_dt;

		 	if p_max_run_date is null
		 	then
		 	open fet_psft_run_dt1;
		 	fetch fet_psft_run_dt1 into p_max_run_date;
		 	close fet_psft_run_dt1;
		 	end if;

            	open fet_delta_status;
					loop
					  fetch fet_delta_status into p_location_id,p_business_group_id,p_event_key_gen;

                      if fet_delta_status%found then

                      update hr_locn_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_loc_qsync(p_location_id,p_business_group_id);
        				  fetch fet_loc_qsync into p_bg_id,p_loc_id,p_active_date,p_effecive_status,
                                			 		p_loc_code, p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
                                			  		p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
                                			  		p_tel_no_3,p_loc_info_13,	p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
                                			  		p_loc_info_19,p_loc_info_20,p_last_update_date;
        		            if 	fet_loc_qsync%found then
                            select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
        		            insert into hr_locn_delta_sync(BUSINESS_GROUP_ID,
                                    LOCATION_ID,
                                    EFFECTIVE_DATE,
                                    EFFECTIVE_STATUS,
                                    LOCATION_CODE,
                                    LOCATION_DESCRIPTION,
                                    LOCATION_STYLE,
                                    COUNTRY,
                                    ADDRESS_LINE1,
                                    ADDRESS_LINE2,
                                    ADDRESS_LINE3,
                                    TOWN_OR_CITY,
                                    REGION_1,
                                    REGION_2,
                                    REGION_3,
                                    POSTAL_CODE,
                                    TELEPHONE_NUMBER_1,
                                    TELEPHONE_NUMBER_2,
                                    TELEPHONE_NUMBER_3,
                                    LOCATION_INFORMATION13,
                                    LOCATION_INFORMATION14,
                                    LOCATION_INFORMATION15,
                                    LOCATION_INFORMATION16,
                                    LOCATION_INFORMATION17,
                                    LOCATION_INFORMATION18,
                                    LOCATION_INFORMATION19,
                                    LOCATION_INFORMATION20,
                                    STATUS,
                                    EFFECTIVE_STATUS_DATE,
                                    LAST_UPDATE_DATE,
                                    EVENT_KEY
                                    )
                            values(p_bg_id,p_loc_id,p_active_date,p_effecive_status,
        			 		p_loc_code, p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
        			  		p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
        			  		p_tel_no_3,p_loc_info_13,	p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
        			  		p_loc_info_19,p_loc_info_20,'QUEUED',p_effective_date,p_last_update_date,p_loc_id||'-'||to_char(p_unique_key));
        		            commit;

            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'LOCN',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_loc_id||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => p_loc_id||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);


                         	        open csr_gen_msg(p_loc_id||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

						            if p_gen_status not in ('0','10') then
										FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  					FND_FILE.put_line(fnd_file.log,'Location Delta Synch Data Extraction Ends for the document id '||p_loc_id||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
    	  				            end if;
    	  				            end if;
    	  				            close csr_gen_msg;

                            end if;
                            close fet_loc_qsync;
                          else
                             exit;
                            end if;
                    end loop;
                    close fet_delta_status;


		  	open fet_loc_sync(p_max_run_date);
		  		loop
		        	fetch fet_loc_sync into  p_bg_id,p_loc_id,p_active_date,p_effecive_status,
			 		p_loc_code, p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
			  		p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
			  		p_tel_no_3,p_loc_info_13,	p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
			  		p_loc_info_19,p_loc_info_20,p_last_update_date;
		            if 	fet_loc_sync%found then
                    select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
		           insert into hr_locn_delta_sync(BUSINESS_GROUP_ID,
                                    LOCATION_ID,
                                    EFFECTIVE_DATE,
                                    EFFECTIVE_STATUS,
                                    LOCATION_CODE,
                                    LOCATION_DESCRIPTION,
                                    LOCATION_STYLE,
                                    COUNTRY,
                                    ADDRESS_LINE1,
                                    ADDRESS_LINE2,
                                    ADDRESS_LINE3,
                                    TOWN_OR_CITY,
                                    REGION_1,
                                    REGION_2,
                                    REGION_3,
                                    POSTAL_CODE,
                                    TELEPHONE_NUMBER_1,
                                    TELEPHONE_NUMBER_2,
                                    TELEPHONE_NUMBER_3,
                                    LOCATION_INFORMATION13,
                                    LOCATION_INFORMATION14,
                                    LOCATION_INFORMATION15,
                                    LOCATION_INFORMATION16,
                                    LOCATION_INFORMATION17,
                                    LOCATION_INFORMATION18,
                                    LOCATION_INFORMATION19,
                                    LOCATION_INFORMATION20,
                                    STATUS,
                                    EFFECTIVE_STATUS_DATE,
                                    LAST_UPDATE_DATE,
                                    EVENT_KEY
                                    ) values(p_bg_id,p_loc_id,p_active_date,p_effecive_status,
			 		p_loc_code, p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
			  		p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
			  		p_tel_no_3,p_loc_info_13,	p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
			  		p_loc_info_19,p_loc_info_20,'QUEUED',p_effective_date,p_last_update_date,p_loc_id||'-'||to_char(p_unique_key));
		            commit;

		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'LOCN',l_params);
		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', p_loc_id||'-'||to_char(p_unique_key), l_params);
		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
		                           p_event_key => p_loc_id||'-'||to_char(p_unique_key),
		                           p_parameters => l_params);

                    open csr_gen_msg(p_loc_id||'-'||to_char(p_unique_key));

                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                             if csr_gen_msg%found then

    	            if p_gen_status not in ('0','10') then
    					FND_FILE.NEW_LINE(FND_FILE.log, 1);
      					FND_FILE.put_line(fnd_file.log,'Location Delta Synch Data Extraction Ends for the document id '||p_loc_id||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
    	            end if;
    	            end if;
    	            close csr_gen_msg;


		            else
		                exit;
		             end if;
		      	end loop;
		    close fet_loc_sync;

			 hr_delta_sync_messages.update_psft_sync_run(1,'LOC_DELTA_SYNC',p_effective_date,errbuf,retcode);
		     FND_FILE.NEW_LINE(FND_FILE.log, 1);
    	     FND_FILE.put_line(fnd_file.log,'Location Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

		 end if;

		  exception

		    when OTHERS then

			hr_delta_sync_messages.update_psft_sync_run(3,'LOC_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Location Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		 end hr_location_delta_sync;

		 /*Procedure to fetch the delta sync data for location ends here*/

	 	 /*Procedure to fetch the delta sync data for person begins here*/
		 procedure hr_person_delta_sync(errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id in NUMBER) is


		L_EMPLOYEE_NUMBER  PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%type;
		L_USER_PERSON_TYPE VARCHAR2(60);
		L_DATE_OF_BIRTH DATE;
		L_TOWN_OF_BIRTH PER_ALL_PEOPLE_F.TOWN_OF_BIRTH%type;
		L_COUNTRY_OF_BIRTH PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH%type;
		L_DATE_OF_DEATH DATE;
		L_ORIGINAL_DATE_OF_HIRE DATE;
		L_EFFECTIVE_START_DATE DATE;
		L_SEX VARCHAR2(30);
		L_MARITAL_STATUS VARCHAR2(30);
		L_FULL_NAME PER_ALL_PEOPLE_F.FULL_NAME%type;
		L_PRE_NAME_ADJUNCT PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT%type;
		L_SUFFIX VARCHAR2(30);
		L_TITLE VARCHAR2(30);
		L_LAST_NAME PER_ALL_PEOPLE_F.LAST_NAME%type;
		L_FIRST_NAME PER_ALL_PEOPLE_F.FIRST_NAME%type;
		L_MIDDLE_NAMES PER_ALL_PEOPLE_F.MIDDLE_NAMES%type;
		L_ADDRESS_TYPE PER_ADDRESSES.ADDRESS_TYPE%type;
		L_DATE_FROM DATE;
		L_COUNTRY PER_ADDRESSES.COUNTRY%type;
		L_ADDRESS_LINE1 PER_ADDRESSES.ADDRESS_LINE1%type;
		L_ADDRESS_LINE2 PER_ADDRESSES.ADDRESS_LINE2%type;
		L_ADDRESS_LINE3 PER_ADDRESSES.ADDRESS_LINE3%type;
		L_TOWN_OR_CITY  PER_ADDRESSES.TOWN_OR_CITY%type;
		L_TELEPHONE_NUMBER_1 PER_ADDRESSES.TELEPHONE_NUMBER_1%type;
		L_REGION_1 PER_ADDRESSES.REGION_1%type;
		L_REGION_2 PER_ADDRESSES.REGION_1%type;
		L_POSTAL_CODE PER_ADDRESSES.POSTAL_CODE%type;
		L_EMAIL_ADDRESS per_all_people_f.email_address%type;
		L_PHONE_TYPE PER_PHONES.PHONE_TYPE%type;
		L_PHONE_NUMBER PER_PHONES.PHONE_NUMBER%type;
		L_NATIONALITY VARCHAR2(30);
		L_NATIONAL_IDENTIFIER PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER%type;
		l_business_group_id number(15);
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);
		 p_event_key_gen varchar2(150);
		 p_last_update_date date;

		/*Select state ment modified for the employee number
	           not getting displayed for Ex-Employee*/
		cursor csr_person_delta_sync (P_SYNC_DATE DATE) is

		SELECT  DECODE ( ppf.CURRENT_NPW_FLAG , 'Y',NPW_NUMBER,EMPLOYEE_NUMBER ) EMPLOYEE_NUMBER,
		        -- HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(P_SYNC_DATE , PPF.PERSON_ID) , bug 6891949
			HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(ppf.last_update_date , PPF.PERSON_ID) ,
		        DATE_OF_BIRTH,
		        TOWN_OF_BIRTH,
		        COUNTRY_OF_BIRTH,
		        DATE_OF_DEATH,
		        ORIGINAL_DATE_OF_HIRE,
		        EFFECTIVE_START_DATE,
		        HL1.MEANING SEX,
		        HL4.MEANING MARITAL_STATUS,
		        FULL_NAME,
		        PRE_NAME_ADJUNCT,
		        SUFFIX,
		        HL3.MEANING TITLE,
		        LAST_NAME,
		        FIRST_NAME,
		        MIDDLE_NAMES,
		        ADDRESS_TYPE,
		        padr.DATE_FROM,
		        COUNTRY,
		        ADDRESS_LINE1,
		        ADDRESS_LINE2,
		        ADDRESS_LINE3,
		        TOWN_OR_CITY,
		        TELEPHONE_NUMBER_1,
		        REGION_1,
		        REGION_2,
		        POSTAL_CODE,
		        EMAIL_ADDRESS,
		        PHONE_TYPE,
		        PHONE_NUMBER,
		        HL2.MEANING NATIONALITY,
		        NATIONAL_IDENTIFIER,
		        ppf.business_group_id,
		        ppf.LAST_UPDATE_DATE

		FROM    PER_ALL_PEOPLE_F ppf,
		        PER_ADDRESSES padr ,
		        PER_PHONES ppn ,
		        hr_lookups HL1 ,
		        HR_LOOKUPS HL2 ,
		        HR_LOOKUPS HL3 ,
		        HR_LOOKUPS HL4
		WHERE   ppf.person_id = padr.person_id (+)
		    AND ( padr.person_id is null
		     OR ( padr.person_id is not null
		    AND padr.primary_flag ='Y'
		    AND ppf.person_id     = padr.person_id
		    and sysdate  between padr.date_from and nvl (padr.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
		    ))
		    AND ppn.PARENT_ID (+) = PPF.PERSON_ID
		    -- Modified for the bug 6895752 starts here
		    /*AND ( ppn.parent_id is null
		     OR ( ppn.parent_id is not null
		    AND PPN.PARENT_TABLE            = 'PER_ALL_PEOPLE_F'
		    AND PPN.PHONE_TYPE              = 'W1' ))*/

		    AND PPN.PARENT_TABLE  (+)          = 'PER_ALL_PEOPLE_F'
		    AND PPN.PHONE_TYPE (+)             = 'W1'
		    -- Modified for the bug 6895752 ends here
		    AND ((ppf.CURRENT_EMPLOYEE_FLAG = 'Y'
		     OR ppf.person_id               in        -- modified for bug6873563
		        (SELECT nvl(pps.person_id , -100)
		        FROM    per_periods_of_service pps
		        WHERE   pps.person_id         = ppf.person_id
		            AND pps.business_group_id = ppf.business_group_id
		            AND pps.last_update_date  > P_SYNC_DATE
		            and  ACTUAL_TERMINATION_DATE is not null
		        ))
		     OR ( ppf.CURRENT_NPW_FLAG = 'Y'
		     OR ppf.person_id          in  -- modified for bug6873563
		        (SELECT nvl(ppp.person_id , -100)
		        FROM    per_periods_of_placement ppp
		        WHERE   ppp.person_id         = ppf.person_id
		            AND ppp.business_group_id = ppf.business_group_id
		            AND ppp.last_update_date  > P_SYNC_DATE
		            and  ACTUAL_TERMINATION_DATE is not null
		        )))
		    AND HL1.LOOKUP_TYPE (+)     = 'SEX'
		    AND HL1.LOOKUP_CODE (+)     = ppf.SEX
		    AND HL2.LOOKUP_TYPE (+)     = 'NATIONALITY'
		    AND HL2.LOOKUP_CODE (+)     = Ppf.NATIONALITY
		    AND HL3.LOOKUP_TYPE (+)     = 'TITLE'
		    AND HL3.LOOKUP_CODE (+)     = PPF.TITLE
		    AND HL4.LOOKUP_TYPE (+)     = 'MAR_STATUS'
		    AND HL4.LOOKUP_CODE (+)     = PPF.MARITAL_STATUS
		    AND ( (ppf.last_update_date > P_SYNC_DATE
		    AND sysdate BETWEEN effective_start_date AND effective_end_date )
		     OR (padr.last_update_date > P_SYNC_DATE) )
			 AND (ppf.employee_number,ppf.business_group_id)
                    not in (select per.employee_number,per.business_group_id
		 	from hr_person_delta_sync per
		 	where ppf.employee_number = per.employee_number
		 	and ppf.business_group_id = per.business_group_id
            and ppf.last_update_date = per.last_update_date
		 	and   per.status in ('QUEUED','SENT'));

		     p_effective_date date default sysdate;

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_delta_status
		 is
		 select employee_number,business_group_id,record_key  from
		 hr_person_delta_sync
		 where  status = 'QUEUED';

		 p_employee_number1 varchar2(50);
		 p_business_group_id1 number(15);
		 cursor csr_person_delta_qsync (p_employee_number varchar2,p_business_group_id number) is

		SELECT  DECODE ( ppf.CURRENT_NPW_FLAG , 'Y',NPW_NUMBER,EMPLOYEE_NUMBER ) EMPLOYEE_NUMBER,
		        HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(sysdate , PPF.PERSON_ID) ,
		        DATE_OF_BIRTH,
		        TOWN_OF_BIRTH,
		        COUNTRY_OF_BIRTH,
		        DATE_OF_DEATH,
		        ORIGINAL_DATE_OF_HIRE,
		        EFFECTIVE_START_DATE,
		        HL1.MEANING SEX,
		        HL4.MEANING MARITAL_STATUS,
		        FULL_NAME,
		        PRE_NAME_ADJUNCT,
		        SUFFIX,
		        HL3.MEANING TITLE,
		        LAST_NAME,
		        FIRST_NAME,
		        MIDDLE_NAMES,
		        ADDRESS_TYPE,
		        padr.DATE_FROM,
		        COUNTRY,
		        ADDRESS_LINE1,
		        ADDRESS_LINE2,
		        ADDRESS_LINE3,
		        TOWN_OR_CITY,
		        TELEPHONE_NUMBER_1,
		        REGION_1,
		        REGION_2,
		        POSTAL_CODE,
		        EMAIL_ADDRESS,
		        PHONE_TYPE,
		        PHONE_NUMBER,
		        HL2.MEANING NATIONALITY,
		        NATIONAL_IDENTIFIER,
		        ppf.business_group_id,
		        ppf.LAST_UPDATE_DATE

		FROM    PER_ALL_PEOPLE_F ppf,
		        PER_ADDRESSES padr ,
		        PER_PHONES ppn ,
		        hr_lookups HL1 ,
		        HR_LOOKUPS HL2 ,
		        HR_LOOKUPS HL3 ,
		        HR_LOOKUPS HL4
		WHERE   ppf.person_id = padr.person_id (+)
		    AND ( padr.person_id is null
		     OR ( padr.person_id is not null
		    AND padr.primary_flag ='Y'
		    AND ppf.person_id     = padr.person_id
		   -- and padr.last_update_date > P_SYNC_DATE
		    and sysdate  between padr.date_from and nvl (padr.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
		    ))
		    AND ppn.PARENT_ID (+) = PPF.PERSON_ID
		    -- Modified for the bug 6895752 starts here
		    /*AND ( ppn.parent_id is null
		     OR ( ppn.parent_id is not null
		    AND PPN.PARENT_TABLE            = 'PER_ALL_PEOPLE_F'
		    AND PPN.PHONE_TYPE              = 'W1' ))*/

		    AND PPN.PARENT_TABLE  (+)          = 'PER_ALL_PEOPLE_F'
		    AND PPN.PHONE_TYPE (+)             = 'W1'
		    -- Modified for the bug 6895752 ends here
		    AND ((ppf.CURRENT_EMPLOYEE_FLAG = 'Y'
		     OR ppf.person_id               =
		        (SELECT nvl(pps.person_id , -100)
		        FROM    per_periods_of_service pps
		        WHERE   pps.person_id         = ppf.person_id
		            AND pps.business_group_id = ppf.business_group_id
		            AND pps.business_group_id = p_business_group_id
		            --AND pps.last_update_date  > P_SYNC_DATE
		            and  ACTUAL_TERMINATION_DATE is not null
		        ))
		     OR ( ppf.CURRENT_NPW_FLAG = 'Y'
		     OR ppf.person_id          =
		        (SELECT nvl(ppp.person_id , -100)
		        FROM    per_periods_of_placement ppp
		        WHERE   ppp.person_id         = ppf.person_id
		            AND ppp.business_group_id = ppf.business_group_id
		            AND ppp.business_group_id = p_business_group_id
		            --AND ppp.last_update_date  > P_SYNC_DATE
		            and  ACTUAL_TERMINATION_DATE is not null
		        )))
		    AND HL1.LOOKUP_TYPE (+)     = 'SEX'
		    AND HL1.LOOKUP_CODE (+)     = ppf.SEX
		    AND HL2.LOOKUP_TYPE (+)     = 'NATIONALITY'
		    AND HL2.LOOKUP_CODE (+)     = Ppf.NATIONALITY
		    AND HL3.LOOKUP_TYPE (+)     = 'TITLE'
		    AND HL3.LOOKUP_CODE (+)     = PPF.TITLE
		    AND HL4.LOOKUP_TYPE (+)     = 'MAR_STATUS'
		    AND HL4.LOOKUP_CODE (+)     = PPF.MARITAL_STATUS
		    AND ppf.employee_number = p_employee_number
		    --AND ( (ppf.last_update_date > P_SYNC_DATE
		    AND sysdate BETWEEN effective_start_date AND effective_end_date;





		 p_cntry_delta_sts varchar2(10);

		cursor fet_psft_sync is
 		select count('x')
 		from   hr_psft_sync_run
 		where  process = 'PERSON_DELTA_SYNC'
 		and    run_date < sysdate
 		and    status = 'STARTED';


		cursor csr_psft_sync is
		 select max (run_date)
		 from   hr_psft_sync_run
		 where  process = 'PERSON_DELTA_SYNC'
		 and    run_date < sysdate
		 and    status = 'COMPLETED';


		 cursor csr_psft_sync_FULL is
		 select ruN_date
		 from   hr_psft_sync_run
		 where  process = 'PERSON_FULL_SYNC'
		 and    status = 'COMPLETED';

		l_dummy number;
		l_sync_date date;
		l_current_date date;
		p_unique_key  number;
		l_params WF_PARAMETER_LIST_T;

		begin
		 open fet_psft_sync;
		 fetch fet_psft_sync into l_dummy;
		 close fet_psft_sync;

		 if l_dummy = 0
		 then



				FND_FILE.NEW_LINE(FND_FILE.log, 1);
				FND_FILE.put_line(fnd_file.log,'Person Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
				hr_delta_sync_messages.insert_psft_sync_run(2,'PERSON_DELTA_SYNC',errbuf,retcode);

				 open csr_psft_sync;
				 fetch csr_psft_sync into l_sync_date;
				 close csr_psft_sync;

				 if l_sync_date is null then
				 open csr_psft_sync_FULL;
				 FETCH csr_psft_sync_FULL INTO l_sync_date ;
				 CLOSE csr_psft_sync_FULL;

				end if;

		l_current_date :=sysdate;

			open fet_delta_status;
					loop
					  fetch fet_delta_status into p_business_group_id1,p_employee_number1,p_event_key_gen;
					  if fet_delta_status%found then
					  update hr_person_delta_sync
					  set status = 'SENT'
					  where record_key = p_event_key_gen;
					  commit;

					  open csr_person_delta_qsync(p_employee_number1,p_business_group_id1);

                       fetch csr_person_delta_qsync into L_EMPLOYEE_NUMBER,L_USER_PERSON_TYPE,L_DATE_OF_BIRTH,L_TOWN_OF_BIRTH,L_COUNTRY_OF_BIRTH
                		         ,L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE,L_EFFECTIVE_START_DATE
                		         , L_SEX,L_MARITAL_STATUS,L_FULL_NAME,L_PRE_NAME_ADJUNCT ,L_SUFFIX
                		         ,L_TITLE,L_LAST_NAME,L_FIRST_NAME ,L_MIDDLE_NAMES, L_ADDRESS_TYPE ,L_DATE_FROM ,L_COUNTRY, L_ADDRESS_LINE1,
                		          L_ADDRESS_LINE2,L_ADDRESS_LINE3,L_TOWN_OR_CITY ,L_TELEPHONE_NUMBER_1,L_REGION_1 ,L_REGION_2,
                		          L_POSTAL_CODE, L_EMAIL_ADDRESS, L_PHONE_TYPE
                		          ,L_PHONE_NUMBER,L_NATIONALITY ,L_NATIONAL_IDENTIFIER,
                                  l_business_group_id,p_last_update_date ;

		 	            if csr_person_delta_qsync%found then

				                select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            		    		insert into hr_person_delta_sync
                                (EMPLOYEE_NUMBER,USER_PERSON_TYPE ,
                                DATE_OF_BIRTH,TOWN_OF_BIRTH,
                                COUNTRY_OF_BIRTH,BUSINESS_GROUP_ID,
                                DATE_OF_DEATH,ORIGINAL_DATE_OF_HIRE,
                                EFFECTIVE_START_DATE,SEX,MARITAL_STATUS ,
                                FULL_NAME,PRE_NAME_ADJUNCT,SUFFIX,
                                TITLE,LAST_NAME,FIRST_NAME ,
                                MIDDLE_NAMES,ADDRESS_TYPE ,DATE_FROM,
                                COUNTRY,ADDRESS_LINE1,
                                ADDRESS_LINE2,ADDRESS_LINE3,TOWN_OR_CITY,
                                TELEPHONE_NUMBER_1,REGION_1,REGION_2,POSTAL_CODE,
                                EMAIL_ADDRESS,PHONE_TYPE,PHONE_NUMBER,
                                NATIONALITY,NATIONAL_IDENTIFIER ,STATUS,
                                EFFECTIVE_STATUS_DATE,
                                LAST_UPDATE_DATE,
                                RECORD_KEY       )
                                 values (L_EMPLOYEE_NUMBER,L_USER_PERSON_TYPE,
            		            L_DATE_OF_BIRTH,L_TOWN_OF_BIRTH,L_COUNTRY_OF_BIRTH,l_business_group_id,
            		            L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE,L_EFFECTIVE_START_DATE,
            		            L_SEX,L_MARITAL_STATUS,L_FULL_NAME,L_PRE_NAME_ADJUNCT ,L_SUFFIX,
            		            L_TITLE,L_LAST_NAME,L_FIRST_NAME ,L_MIDDLE_NAMES, L_ADDRESS_TYPE ,L_DATE_FROM ,L_COUNTRY, L_ADDRESS_LINE1,
            		            L_ADDRESS_LINE2,L_ADDRESS_LINE3,L_TOWN_OR_CITY ,L_TELEPHONE_NUMBER_1,L_REGION_1 ,L_REGION_2,
            		            L_POSTAL_CODE, L_EMAIL_ADDRESS, L_PHONE_TYPE,
            		            L_PHONE_NUMBER,L_NATIONALITY ,L_NATIONAL_IDENTIFIER,'QUEUED',l_current_date,
                                p_last_update_date,L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key));

            		            commit;


            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'PERSON',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);

                                         open csr_gen_msg(L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Person Delta Synch Data Extraction Ends for the document id '||L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
	    	  				            end if;
	    	  				            close csr_gen_msg;

                            end if;
                            close csr_person_delta_qsync;
                          else
                             exit;
                            end if;
                    end loop;
                    close fet_delta_status;
		--
		  open csr_person_delta_sync (l_sync_date);
		  loop
		   fetch csr_person_delta_sync into L_EMPLOYEE_NUMBER,L_USER_PERSON_TYPE,L_DATE_OF_BIRTH,L_TOWN_OF_BIRTH,L_COUNTRY_OF_BIRTH
		         ,L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE,L_EFFECTIVE_START_DATE
		         , L_SEX,L_MARITAL_STATUS,L_FULL_NAME,L_PRE_NAME_ADJUNCT ,L_SUFFIX
		         ,L_TITLE,L_LAST_NAME,L_FIRST_NAME ,L_MIDDLE_NAMES, L_ADDRESS_TYPE ,L_DATE_FROM ,L_COUNTRY, L_ADDRESS_LINE1,
		          L_ADDRESS_LINE2,L_ADDRESS_LINE3,L_TOWN_OR_CITY ,L_TELEPHONE_NUMBER_1,L_REGION_1 ,L_REGION_2,
		          L_POSTAL_CODE, L_EMAIL_ADDRESS, L_PHONE_TYPE
		          ,L_PHONE_NUMBER,L_NATIONALITY ,L_NATIONAL_IDENTIFIER,
                  l_business_group_id,p_last_update_date ;

		    	if csr_person_delta_sync%found then

				    select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
		    			insert into hr_person_delta_sync
                                (EMPLOYEE_NUMBER,USER_PERSON_TYPE ,
                                DATE_OF_BIRTH,TOWN_OF_BIRTH,
                                COUNTRY_OF_BIRTH,BUSINESS_GROUP_ID,
                                DATE_OF_DEATH,ORIGINAL_DATE_OF_HIRE,
                                EFFECTIVE_START_DATE,SEX,MARITAL_STATUS ,
                                FULL_NAME,PRE_NAME_ADJUNCT,SUFFIX,
                                TITLE,LAST_NAME,FIRST_NAME ,
                                MIDDLE_NAMES,ADDRESS_TYPE ,DATE_FROM,
                                COUNTRY,ADDRESS_LINE1,
                                ADDRESS_LINE2,ADDRESS_LINE3,TOWN_OR_CITY,
                                TELEPHONE_NUMBER_1,REGION_1,REGION_2,POSTAL_CODE,
                                EMAIL_ADDRESS,PHONE_TYPE,PHONE_NUMBER,
                                NATIONALITY,NATIONAL_IDENTIFIER ,STATUS,
                                EFFECTIVE_STATUS_DATE,
                                LAST_UPDATE_DATE,
                                RECORD_KEY       )
                     values (L_EMPLOYEE_NUMBER,L_USER_PERSON_TYPE,
		            L_DATE_OF_BIRTH,L_TOWN_OF_BIRTH,L_COUNTRY_OF_BIRTH,l_business_group_id,
		            L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE,L_EFFECTIVE_START_DATE,
		            L_SEX,L_MARITAL_STATUS,L_FULL_NAME,L_PRE_NAME_ADJUNCT ,L_SUFFIX,
		            L_TITLE,L_LAST_NAME,L_FIRST_NAME ,L_MIDDLE_NAMES, L_ADDRESS_TYPE ,L_DATE_FROM ,L_COUNTRY, L_ADDRESS_LINE1,
		            L_ADDRESS_LINE2,L_ADDRESS_LINE3,L_TOWN_OR_CITY ,L_TELEPHONE_NUMBER_1,L_REGION_1 ,L_REGION_2,
		            L_POSTAL_CODE, L_EMAIL_ADDRESS, L_PHONE_TYPE,
		            L_PHONE_NUMBER,L_NATIONALITY ,L_NATIONAL_IDENTIFIER,'QUEUED',l_current_date,
                    p_last_update_date,L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key));

		            commit;

		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'PERSON',l_params);
		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key), l_params);
		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
		                           p_event_key => L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key),
		                           p_parameters => l_params);

                   	    open csr_gen_msg(L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key));

                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                             if csr_gen_msg%found then

			            if p_gen_status not in ('0','10') then
							FND_FILE.NEW_LINE(FND_FILE.log, 1);
    	  					FND_FILE.put_line(fnd_file.log,'Person Delta Synch Data Extraction Ends for the document id '||L_EMPLOYEE_NUMBER||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
			            end if;
			            end if;
			            close csr_gen_msg;


		    else
		        exit ;
		end if;

		    exit when csr_person_delta_sync%notfound;

		    end loop;
		    close csr_person_delta_sync;

		     hr_delta_sync_messages.update_psft_sync_run(1,'PERSON_DELTA_SYNC',p_effective_date,errbuf,retcode);
		     FND_FILE.NEW_LINE(FND_FILE.log, 1);
    	     FND_FILE.put_line(fnd_file.log,'Person Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		end if;

		  exception

		   when OTHERS then

		    hr_delta_sync_messages.update_psft_sync_run(3,'PERSON_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Person Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));



		end;
		 /*Procedure to fetch the delta sync data for person ends here*/

		/*Procedure to extract the workforce data for delta synch process begins here*/
		procedure hr_workforce_delta_sync(errbuf  OUT NOCOPY VARCHAR2
		 							     ,retcode OUT NOCOPY VARCHAR2
                                         ,p_party_site_id in NUMBER)
		is


        TYPE EMPLIDTYPE IS TABLE OF per_all_people_f.employee_number%type INDEX BY BINARY_INTEGER;
        TYPE EMPL_RCDTYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        TYPE PROBATION_DTTYPE IS TABLE OF per_all_assignments_f.probation_period%type INDEX BY BINARY_INTEGER;
        TYPE ORIG_HIRE_DTTYPE IS TABLE OF per_all_people_f.original_date_of_hire%type INDEX BY BINARY_INTEGER;
        TYPE WEFFDTTYPE IS TABLE OF per_all_assignments_f.effective_start_date%type INDEX BY BINARY_INTEGER;
        TYPE BUSINESS_UNITTYPE IS TABLE OF per_all_assignments_f.organization_id%type INDEX BY BINARY_INTEGER;
        TYPE WJOBCODETYPE IS TABLE OF per_all_assignments_f.job_id%type INDEX BY BINARY_INTEGER;
        TYPE EMPL_STATUSTYPE IS TABLE OF per_all_assignments_f.assignment_status_type_id%type INDEX BY BINARY_INTEGER;
        TYPE LOCATIONTYPE IS TABLE OF per_all_assignments_f.location_id%type INDEX BY BINARY_INTEGER;
        TYPE FULL_PART_TIMETYPE IS TABLE OF per_all_assignments_f.employment_category%type INDEX BY BINARY_INTEGER;
        TYPE COMPANYTYPE IS TABLE OF per_all_assignments_f.business_group_id%type INDEX BY BINARY_INTEGER;
        TYPE STD_HOURSTYPE IS TABLE OF per_all_assignments_f.normal_hours%type INDEX BY BINARY_INTEGER;
        TYPE STD_HRS_FREQUENCYTYPE IS TABLE OF per_all_assignments_f.frequency%type INDEX BY BINARY_INTEGER;
        TYPE GRADETYPE IS TABLE OF per_all_assignments_f.grade_id%type INDEX BY BINARY_INTEGER;
        TYPE SUPERVISOR_IDTYPE IS TABLE OF per_all_assignments_f.supervisor_id%type INDEX BY BINARY_INTEGER;
        TYPE ASGN_START_DTTYPE IS TABLE OF per_all_assignments_f.EFFECTIVE_START_DATE%type INDEX BY BINARY_INTEGER;
        TYPE ASGN_END_DTTYPE IS TABLE OF per_all_assignments_f.EFFECTIVE_END_DATE%type INDEX BY BINARY_INTEGER;
        TYPE TERMINATION_DTTYPE IS TABLE OF per_periods_of_service.final_process_date%type INDEX BY BINARY_INTEGER;
        TYPE LAST_DATE_WORKEDTYPE IS TABLE OF per_periods_of_service.ACCEPTED_TERMINATION_DATE%type INDEX BY BINARY_INTEGER;
        TYPE STEPTYPE IS TABLE OF PER_SPINAL_POINT_PLACEMENTS_F.STEP_ID%type INDEX BY BINARY_INTEGER;
        TYPE LSTUPDDTTYPE IS TABLE OF per_all_assignments_f.last_update_date%type INDEX BY BINARY_INTEGER;
        TYPE workforce IS REF CURSOR;

        TYPE WorkForceTblType IS RECORD
        (
            EMPLID EMPLIDTYPE
            ,EMPL_RCD EMPL_RCDTYPE
            ,PROBATION_DT PROBATION_DTTYPE
            ,ORIG_HIRE_DT ORIG_HIRE_DTTYPE
            ,EFFDT WEFFDTTYPE
            ,BUSINESS_UNIT BUSINESS_UNITTYPE
            ,JOBCODE WJOBCODETYPE
            ,EMPL_STATUS EMPL_STATUSTYPE
            ,LOCATION LOCATIONTYPE
            ,FULL_PART_TIME FULL_PART_TIMETYPE
            ,COMPANY COMPANYTYPE
            ,STD_HOURS STD_HOURSTYPE
            ,STD_HRS_FREQUENCY STD_HRS_FREQUENCYTYPE
            ,GRADE GRADETYPE
            ,SUPERVISOR_ID SUPERVISOR_IDTYPE
            ,ASGN_START_DT ASGN_START_DTTYPE
            ,ASGN_END_DT ASGN_END_DTTYPE
            ,TERMINATION_DT TERMINATION_DTTYPE
            ,LAST_DATE_WORKED LAST_DATE_WORKEDTYPE
            ,STEP STEPTYPE
            ,LAST_UPDATE_DATE LSTUPDDTTYPE
        );

        WorkForceFullType WorkForceTblType;
        WorkForcedeltaType WorkForceTblType;

        workforce_delta workforce;
        workforce_deltaq workforce;

        p_cnt number := 0;
        l_params WF_PARAMETER_LIST_T;
        p_unique_key  number;
        p_effective_date date default sysdate;
        p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);

        cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'WORKFORCE_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'WORKFORCE_FULL_SYNC'
		 and    status = 'COMPLETED';

		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'WORKFORCE_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_delta_status
		 is
		 select employee_number,business_group_id,job_id,event_key,last_update_date
         from HR_WORKFORCE_DELTA_SYNC
		 where status = 'QUEUED';

		 p_emp_num VARCHAR2(30);
		 p_bg_id number(15);
		 p_job_id number(15);
		 p_event_key_gen varchar2(240);
		 p_lst_upd_date date;

		 l_dummy number;
		 run_date date;

        begin

            open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then
		 			FND_FILE.NEW_LINE(FND_FILE.log, 1);
					FND_FILE.put_line(fnd_file.log,'Work Force Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
					hr_delta_sync_messages.insert_psft_sync_run(2,'WORKFORCE_DELTA_SYNC',errbuf,retcode);



					open fet_psft_run_dt;
		 			fetch fet_psft_run_dt into run_date;
		 			close fet_psft_run_dt;

		 			if run_date is null
					then
					open fet_psft_run_dt1;
					fetch fet_psft_run_dt1 into run_date;
					close fet_psft_run_dt1;
					end if;


					open fet_delta_status;
					loop
					  fetch fet_delta_status into p_emp_num,p_bg_id,p_job_id,p_event_key_gen,p_lst_upd_date;

                      if fet_delta_status%found then

                          update HR_WORKFORCE_DELTA_SYNC
        				  set  status = 'SENT'
        				  where event_key = p_event_key_gen;
        				  commit;

            	        OPEN workforce_deltaq FOR
                        SELECT ppf.employee_number,1 AS empl_rcd ,ppf.original_date_of_hire,
                        pas.probation_period,pas.effective_start_date effdt,pas.organization_id,
                        pas.job_id,pas.assignment_status_type_id,pas.location_id,
                        pas.employment_category,pas.business_group_id,pas.normal_hours,
                        pas.frequency,pas.grade_id,pas.supervisor_id,pas.EFFECTIVE_START_DATE,
                        nvl(pas.EFFECTIVE_END_DATE,sysdate) EFFECTIVE_END_DATE,
                        nvl(psf.step_id,0) Step_id
                        ,pos.final_process_date,pos.ACCEPTED_TERMINATION_DATE,pas.last_update_date
                        FROM per_all_people_f ppf,per_all_assignments_f pas,
                        per_periods_of_service pos,PER_SPINAL_POINT_PLACEMENTS_F psf
                        WHERE pas.primary_flag='Y'
                        AND pos.person_id=pas.person_id
                        AND ppf.person_id = pos.person_id
                        AND pas.business_group_id = psf.business_group_id(+)
                        AND pas.assignment_id = psf.assignment_id(+)
                        AND ppf.BUSINESS_GROUP_ID = pas.BUSINESS_GROUP_ID
                        AND pas.effective_start_date BETWEEN ppf.effective_start_date(+) AND
                        ppf.effective_end_date(+)
                        AND ppf.employee_number = p_emp_num
                        AND pas.business_group_id = p_bg_id
                        AND pas.job_id = p_job_id
                        AND pas.last_update_date >= p_lst_upd_date;

                        FETCH workforce_deltaq
                        INTO WorkForcedeltaType.EMPLID(1)
                        ,WorkForcedeltaType.EMPL_RCD(1)
                        ,WorkForcedeltaType.ORIG_HIRE_DT(1)
                        ,WorkForcedeltaType.PROBATION_DT(1)
                        ,WorkForcedeltaType.EFFDT(1)
                        ,WorkForcedeltaType.BUSINESS_UNIT(1)
                        ,WorkForcedeltaType.JOBCODE(1)
                        ,WorkForcedeltaType.EMPL_STATUS(1)
                        ,WorkForcedeltaType.LOCATION(1)
                        ,WorkForcedeltaType.FULL_PART_TIME(1)
                        ,WorkForcedeltaType.COMPANY(1)
                        ,WorkForcedeltaType.STD_HOURS(1)
                        ,WorkForcedeltaType.STD_HRS_FREQUENCY(1)
                        ,WorkForcedeltaType.GRADE(1)
                        ,WorkForcedeltaType.SUPERVISOR_ID(1)
                        ,WorkForcedeltaType.ASGN_START_DT(1)
                        ,WorkForcedeltaType.ASGN_END_DT(1)
                        ,WorkForcedeltaType.STEP(1)
                        ,WorkForcedeltaType.TERMINATION_DT(1)
                        ,WorkForcedeltaType.LAST_DATE_WORKED(1)
                        ,WorkForcedeltaType.LAST_UPDATE_DATE(1);


                       if  workforce_deltaq%FOUND then


                        select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
                        insert into HR_WORKFORCE_DELTA_SYNC
                        (EMPLOYEE_NUMBER,
                        EMPL_RCD ,
                        ORIGINAL_DATE_OF_HIRE,
                        PROBATION_PERIOD,
                        EFFDT,
                        ORGANIZATION_ID,
                        JOB_ID,
                        ASSIGNMENT_STATUS_TYPE_ID,
                        LOCATION_ID,
                        EMPLOYMENT_CATEGORY,
                        BUSINESS_GROUP_ID,
                        NORMAL_HOURS,
                        FREQUENCY,
                        GRADE_ID ,
                        SUPERVISOR_ID,
                        EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE,
                        STEP_ID,
                        FINAL_PROCESS_DATE,
                        ACCEPTED_TERMINATION_DATE,
                        STATUS,
                        EFFECTIVE_STATUS_DATE,
                        LAST_UPDATE_DATE,
                        EVENT_KEY)
                         values(
                         WorkForceDeltaType.EMPLID(1)
                        ,WorkForceDeltaType.EMPL_RCD(1)
                        ,WorkForceDeltaType.ORIG_HIRE_DT(1)
                        ,WorkForceDeltaType.PROBATION_DT(1)
                        ,WorkForceDeltaType.EFFDT(1)
                        ,WorkForceDeltaType.BUSINESS_UNIT(1)
                        ,WorkForceDeltaType.JOBCODE(1)
                        ,WorkForceDeltaType.EMPL_STATUS(1)
                        ,WorkForceDeltaType.LOCATION(1)
                        ,WorkForceDeltaType.FULL_PART_TIME(1)
                        ,WorkForceDeltaType.COMPANY(1)
                        ,WorkForceDeltaType.STD_HOURS(1)
                        ,WorkForceDeltaType.STD_HRS_FREQUENCY(1)
                        ,WorkForceDeltaType.GRADE(1)
                        ,WorkForceDeltaType.SUPERVISOR_ID(1)
                        ,WorkForceDeltaType.ASGN_START_DT(1)
                        ,WorkForceDeltaType.ASGN_END_DT(1)
                        ,WorkForceDeltaType.STEP(1)
                        ,WorkForceDeltaType.TERMINATION_DT(1)
                        ,WorkForceDeltaType.LAST_DATE_WORKED(1)
                        ,'QUEUED'
                        ,sysdate
                        ,WorkForceDeltaType.LAST_UPDATE_DATE(1)
                        ,WorkForceDeltaType.EMPLID(1)||WorkForceDeltaType.BUSINESS_UNIT(1)||
                         WorkForceDeltaType.JOBCODE(1)||'-'||to_char(p_unique_key));
                        commit;

                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'WORKFORCE',l_params);
                        WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
                        WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', WorkForceDeltaType.EMPLID(1)||WorkForceDeltaType.BUSINESS_UNIT(1)||
                        WorkForceDeltaType.JOBCODE(1)||'-'||to_char(p_unique_key), l_params);

                        WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
                        p_event_key => WorkForceDeltaType.EMPLID(1)||WorkForceDeltaType.BUSINESS_UNIT(1)||
                        WorkForceDeltaType.JOBCODE(1)||'-'||to_char(p_unique_key),
                        p_parameters => l_params);

                        open csr_gen_msg(WorkForceDeltaType.EMPLID(1)||WorkForceDeltaType.BUSINESS_UNIT(1)||
                        WorkForceDeltaType.JOBCODE(1)||'-'||to_char(p_unique_key));

                        fetch csr_gen_msg into p_gen_status,p_gen_msg;
                         if csr_gen_msg%found then
                            if p_gen_status not in ('0','10') then
                		       FND_FILE.NEW_LINE(FND_FILE.log, 1);
                		       FND_FILE.put_line(fnd_file.log,'Workforce Delta Synch Data Extraction Ends for the document id '||WorkForceDeltaType.EMPLID(1)||WorkForceDeltaType.BUSINESS_UNIT(1)||
                        WorkForceDeltaType.JOBCODE(1)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
                	            end if;
                              end if;
                            close csr_gen_msg;

                         end if;
                        close workforce_deltaq;
                        else
                                 exit;
                    end if;
                    end loop;

                    close fet_delta_status;


                    OPEN workforce_delta FOR
                    SELECT ppf.employee_number,1 AS empl_rcd ,ppf.original_date_of_hire,
                    pas.probation_period,pas.effective_start_date effdt,pas.organization_id,
                    pas.job_id,pas.assignment_status_type_id,pas.location_id,
                    pas.employment_category,pas.business_group_id,pas.normal_hours,
                    pas.frequency,pas.grade_id,pas.supervisor_id,pas.EFFECTIVE_START_DATE,
                    nvl(pas.EFFECTIVE_END_DATE,sysdate) EFFECTIVE_END_DATE,
                    nvl(psf.step_id,0) Step_id
                    ,pos.final_process_date,pos.ACCEPTED_TERMINATION_DATE,pas.last_update_date
                    FROM per_all_people_f ppf,per_all_assignments_f pas,
                    per_periods_of_service pos,PER_SPINAL_POINT_PLACEMENTS_F psf
                    WHERE pas.primary_flag='Y'
                    AND pos.person_id=pas.person_id
                    AND ppf.person_id = pos.person_id
                    AND pas.business_group_id = psf.business_group_id(+)
                    AND pas.assignment_id = psf.assignment_id(+)
                    AND ppf.BUSINESS_GROUP_ID = pas.BUSINESS_GROUP_ID
                    AND pas.effective_start_date BETWEEN ppf.effective_start_date(+) AND
                    ppf.effective_end_date(+)
                    AND pas.last_update_date >= run_date
                    AND (ppf.employee_number,pas.business_group_id,pas.job_id) not in (
                    select wfrc.employee_number,wfrc.business_group_id,wfrc.job_id
                    from HR_WORKFORCE_DELTA_SYNC wfrc
                    where wfrc.employee_number = ppf.employee_number
                    and wfrc.business_group_id = pas.business_group_id
                    and wfrc.job_id = pas.job_id
                    and pas.last_update_date <= wfrc.last_update_date
                    and wfrc.status in ('QUEUED','SENT')) ;

                    LOOP
                    BEGIN
                    FETCH workforce_delta BULK COLLECT
                    INTO WorkForcedeltaType.EMPLID
                    ,WorkForcedeltaType.EMPL_RCD
                    ,WorkForcedeltaType.ORIG_HIRE_DT
                    ,WorkForcedeltaType.PROBATION_DT
                    ,WorkForcedeltaType.EFFDT
                    ,WorkForcedeltaType.BUSINESS_UNIT
                    ,WorkForcedeltaType.JOBCODE
                    ,WorkForcedeltaType.EMPL_STATUS
                    ,WorkForcedeltaType.LOCATION
                    ,WorkForcedeltaType.FULL_PART_TIME
                    ,WorkForcedeltaType.COMPANY
                    ,WorkForcedeltaType.STD_HOURS
                    ,WorkForcedeltaType.STD_HRS_FREQUENCY
                    ,WorkForcedeltaType.GRADE
                    ,WorkForcedeltaType.SUPERVISOR_ID
                    ,WorkForcedeltaType.ASGN_START_DT
                    ,WorkForcedeltaType.ASGN_END_DT
                    ,WorkForcedeltaType.STEP
                    ,WorkForcedeltaType.TERMINATION_DT
                    ,WorkForcedeltaType.LAST_DATE_WORKED
                    ,WorkForcedeltaType.LAST_UPDATE_DATE;


                    END;

                    if WorkForcedeltaType.EMPLID.count <=0 then
                        CLOSE workforce_delta;
                        EXIT;
                    end if;

                    p_cnt := p_cnt + WorkForcedeltaType.EMPLID.count;

                    if  workforce_delta%NOTFOUND then
                        CLOSE workforce_delta;
                        EXIT;
                    end if;

                    END LOOP;


                    FOR I IN 1 .. p_cnt Loop
                    select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
                          insert into HR_WORKFORCE_DELTA_SYNC
                        (EMPLOYEE_NUMBER,
                        EMPL_RCD ,
                        ORIGINAL_DATE_OF_HIRE,
                        PROBATION_PERIOD,
                        EFFDT,
                        ORGANIZATION_ID,
                        JOB_ID,
                        ASSIGNMENT_STATUS_TYPE_ID,
                        LOCATION_ID,
                        EMPLOYMENT_CATEGORY,
                        BUSINESS_GROUP_ID,
                        NORMAL_HOURS,
                        FREQUENCY,
                        GRADE_ID ,
                        SUPERVISOR_ID,
                        EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE,
                        STEP_ID,
                        FINAL_PROCESS_DATE,
                        ACCEPTED_TERMINATION_DATE,
                        STATUS,
                        EFFECTIVE_STATUS_DATE,
                        LAST_UPDATE_DATE,
                        EVENT_KEY)
                         values(
                     WorkForceDeltaType.EMPLID(I)
                    ,WorkForceDeltaType.EMPL_RCD(I)
                    ,WorkForceDeltaType.ORIG_HIRE_DT(I)
                    ,WorkForceDeltaType.PROBATION_DT(I)
                    ,WorkForceDeltaType.EFFDT(I)
                    ,WorkForceDeltaType.BUSINESS_UNIT(I)
                    ,WorkForceDeltaType.JOBCODE(I)
                    ,WorkForceDeltaType.EMPL_STATUS(I)
                    ,WorkForceDeltaType.LOCATION(I)
                    ,WorkForceDeltaType.FULL_PART_TIME(I)
                    ,WorkForceDeltaType.COMPANY(I)
                    ,WorkForceDeltaType.STD_HOURS(I)
                    ,WorkForceDeltaType.STD_HRS_FREQUENCY(I)
                    ,WorkForceDeltaType.GRADE(I)
                    ,WorkForceDeltaType.SUPERVISOR_ID(I)
                    ,WorkForceDeltaType.ASGN_START_DT(I)
                    ,WorkForceDeltaType.ASGN_END_DT(I)
                    ,WorkForceDeltaType.STEP(I)
                    ,WorkForceDeltaType.TERMINATION_DT(I)
                    ,WorkForceDeltaType.LAST_DATE_WORKED(I)
                    ,'QUEUED'
                    ,sysdate
                    ,WorkForceDeltaType.LAST_UPDATE_DATE(I)
                    ,WorkForceDeltaType.EMPLID(I)||WorkForceDeltaType.BUSINESS_UNIT(I)||
                     WorkForceDeltaType.JOBCODE(I)||'-'||to_char(p_unique_key));
                    commit;

                    WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
                    WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'WORKFORCE',l_params);
                    WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
                    WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', WorkForceDeltaType.EMPLID(I)||WorkForceDeltaType.BUSINESS_UNIT(I)||
                    WorkForceDeltaType.JOBCODE(I)||'-'||to_char(p_unique_key), l_params);

                    WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
                    p_event_key => WorkForceDeltaType.EMPLID(I)||WorkForceDeltaType.BUSINESS_UNIT(I)||
                    WorkForceDeltaType.JOBCODE(I)||'-'||to_char(p_unique_key),
                    p_parameters => l_params);

                     open csr_gen_msg(WorkForceDeltaType.EMPLID(I)||WorkForceDeltaType.BUSINESS_UNIT(I)||
                    WorkForceDeltaType.JOBCODE(I)||'-'||to_char(p_unique_key));

                     fetch csr_gen_msg into p_gen_status,p_gen_msg;
                         if csr_gen_msg%found then
                            if p_gen_status not in ('0','10') then
                		       FND_FILE.NEW_LINE(FND_FILE.log, 1);
                		       FND_FILE.put_line(fnd_file.log,'Workforce Delta Synch Data Extraction Ends for the document id '||WorkForceDeltaType.EMPLID(I)||WorkForceDeltaType.BUSINESS_UNIT(I)||
                                WorkForceDeltaType.JOBCODE(I)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
                	            end if;
                              end if;
                     close csr_gen_msg;


                    END Loop;
                      hr_delta_sync_messages.update_psft_sync_run(1,'WORKFORCE_DELTA_SYNC',p_effective_date,errbuf,retcode);
					  FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  FND_FILE.put_line(fnd_file.log,'Work Force Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

                 End if;

                    exception
                	when OTHERS then
        		    hr_delta_sync_messages.update_psft_sync_run(3,'WORKFORCE_DELTA_SYNC',p_effective_date,errbuf,retcode);
                	errbuf := errbuf||SQLERRM;
                	retcode := '1';
                	FND_FILE.put_line(fnd_file.log, 'Error in Work Force Delta Synch Extraction: '||SQLCODE);
                	FND_FILE.NEW_LINE(FND_FILE.log, 1);
                	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		end hr_workforce_delta_sync;
		/*Procedure to extract the workforce data for delta synch process ends here*/

		/*Procedure to extract the jobcode data for delta synch process begins here*/
		procedure hr_jobcode_delta_sync(errbuf  OUT NOCOPY VARCHAR2
		 						       ,retcode OUT NOCOPY VARCHAR2
                                        ,p_party_site_id in NUMBER)
		is

            TYPE setidType IS TABLE OF per_jobs.business_group_id%type INDEX BY BINARY_INTEGER;
            TYPE jobcodeType IS TABLE OF per_jobs.job_id%type INDEX BY BINARY_INTEGER;
            TYPE effdtType IS TABLE OF per_jobs.date_from%type INDEX BY BINARY_INTEGER;
            TYPE effstatusType IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
            TYPE descrType IS TABLE OF per_jobs.name%type INDEX BY BINARY_INTEGER;
            TYPE lstupddtType IS TABLE OF per_jobs.last_update_date%type INDEX BY BINARY_INTEGER;
            TYPE jobcode IS REF CURSOR;

            TYPE JobCodeTblType IS RECORD
            (
            SETID setidType,
            JOBCODE jobcodeType,
            EFFDT effdtType,
            EFF_STATUS effstatusType,
            DESCR descrType,
            LAST_UPD_DATE lstupddtType);

            Jobcodedeltatype JobCodeTblType;

            jobcode_delta jobcode;
            jobcode_deltaq jobcode;

            p_cnt number := 0;
            l_params WF_PARAMETER_LIST_T;
            p_unique_key  number;
            p_effective_date date default sysdate;

             cursor fet_psft_run_dt is
    		 select max(run_date)
    		 from   hr_psft_sync_run
    		 where  process = 'JOBCODE_DELTA_SYNC'
    		 and    run_date < p_effective_date
    		 and    status = 'COMPLETED';

    		 cursor fet_psft_run_dt1 is
    		 select max(run_date)
    		 from   hr_psft_sync_run
    		 where  process = 'JOBCODE_FULL_SYNC'
    		 and    status = 'COMPLETED';

    		 cursor fet_psft_sync is
    		 select count('x')
    		 from   hr_psft_sync_run
    		 where  process = 'JOBCODE_DELTA_SYNC'
    		 and    run_date < p_effective_date
    		 and    status = 'STARTED';

    		 cursor fet_delta_status
    		 is
    		 select setid,jobcode,event_key,last_update_date from
    		 HR_JOBCODE_DELTA_SYNC
    		 where status = 'QUEUED';

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;



		     l_dummy number;
		     run_date date;
		     p_event_key_gen varchar2(240);
		     p_set_id number(15);
		     p_job_id number(15);
		     p_lst_upddt date;
		     p_gen_msg    VARCHAR2(4000);
		     p_gen_status  varchar2(10);

            BEGIN

            open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then

                        FND_FILE.NEW_LINE(FND_FILE.log, 1);
            			FND_FILE.put_line(fnd_file.log,'JobCode Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
            			hr_delta_sync_messages.insert_psft_sync_run(2,'JOBCODE_DELTA_SYNC',errbuf,retcode);
                        /* Fetching the jobcode data for delta Sync */

                        open fet_psft_run_dt;
             			fetch fet_psft_run_dt into run_date;
             			close fet_psft_run_dt;

             			if run_date is null
            			then
            			open fet_psft_run_dt1;
            			fetch fet_psft_run_dt1 into run_date;
            			close fet_psft_run_dt1;
            			end if;


                    open fet_delta_status;
					loop
					  fetch fet_delta_status into p_set_id,p_job_id,p_event_key_gen,p_lst_upddt;

                      if fet_delta_status%found then

                      update HR_JOBCODE_DELTA_SYNC
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;



                        OPEN jobcode_deltaq FOR
                        SELECT BUSINESS_GROUP_ID SETID,
                        JOB_ID JOBCODE,
                        DATE_FROM EFFDT,
                        DECODE(DATE_TO,NULL,'ACTIVE','INACTIVE') EFF_STATUS,
                        NAME DESCR,
                        LAST_UPDATE_DATE LAST_UPD_DATE
                        FROM PER_JOBS
                        WHERE last_update_date >= p_lst_upddt
                        AND BUSINESS_GROUP_ID = p_set_id
                        AND JOB_ID = p_job_id;

                        FETCH jobcode_deltaq
                        INTO Jobcodedeltatype.SETID(1)
                        ,Jobcodedeltatype.JOBCODE(1)
                        ,Jobcodedeltatype.EFFDT(1)
                        ,Jobcodedeltatype.EFF_STATUS(1)
                        ,Jobcodedeltatype.DESCR(1)
                        ,Jobcodedeltatype.LAST_UPD_DATE(1);

                        IF jobcode_deltaq%found then

                        select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

                        insert into HR_JOBCODE_DELTA_SYNC(
                        SETID ,
                        JOBCODE ,
                        EFFDT,
                        EFF_STATUS ,
                        DESCR ,
                        STATUS ,
                        EFFECTIVE_STATUS_DATE ,
                        LAST_UPDATE_DATE ,
                        EVENT_KEY)
                         values(
                        Jobcodedeltatype.SETID(1)
                        ,Jobcodedeltatype.JOBCODE(1)
                        ,Jobcodedeltatype.EFFDT(1)
                        ,Jobcodedeltatype.EFF_STATUS(1)
                        ,Jobcodedeltatype.DESCR(1)
                        ,'QUEUED'
                        ,sysdate
                        ,Jobcodedeltatype.LAST_UPD_DATE(1)
                        ,Jobcodedeltatype.SETID(1)||Jobcodedeltatype.JOBCODE(1)||'-'||to_char(p_unique_key));

                        commit;



                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'JOBCODE',l_params);
                        WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
                        WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID',Jobcodedeltatype.SETID(1)||Jobcodedeltatype.JOBCODE(1)||'-'||to_char(p_unique_key) , l_params);
                        WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
                        p_event_key => Jobcodedeltatype.SETID(1)||Jobcodedeltatype.JOBCODE(1)||'-'||to_char(p_unique_key),
                        p_parameters => l_params);

                        open csr_gen_msg(Jobcodedeltatype.SETID(1)||Jobcodedeltatype.JOBCODE(1)||'-'||to_char(p_unique_key));

                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                             if csr_gen_msg%found then

                        if p_gen_status not in ('0','10') then
            				FND_FILE.NEW_LINE(FND_FILE.log, 1);
            				FND_FILE.put_line(fnd_file.log,'JobCode Delta Synch Data Extraction Ends for the document id '||Jobcodedeltatype.SETID(1)||
					       Jobcodedeltatype.JOBCODE(1)||'-'
					       ||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
                        end if;
                        end if;
                        close csr_gen_msg;
                     end if;
                        close jobcode_deltaq;
                    else
                        exit;
                    end if;

                    END loop;
                 close fet_delta_status;


                        OPEN jobcode_delta FOR
                        SELECT job.BUSINESS_GROUP_ID SETID,
                        job.JOB_ID JOBCODE,
                        job.DATE_FROM EFFDT,
                        DECODE(job.DATE_TO,NULL,'ACTIVE','INACTIVE') EFF_STATUS,
                        job.NAME DESCR,
                        job.LAST_UPDATE_DATE LAST_UPD_DATE
                        FROM PER_JOBS job
                        WHERE job.last_update_date >= run_date
                        and (job.business_group_id,job.job_id)not in
                        (select setid,jobcode from HR_JOBCODE_DELTA_SYNC jbcd
                         where job.BUSINESS_GROUP_ID = jbcd.setid
                         and job.JOB_ID = jbcd.jobcode
                         and job.last_update_date <= jbcd.last_update_date
                         and jbcd.status in ('QUEUED','SENT'));

                       /* UNION
                        select SETID,
                        JOBCODE,
                        EFFDT,
                        EFF_STATUS,
                        DESCR
                        FROM HR.HR_JOBCODE_DELTA_SYNC
                        WHERE STATUS = 'QUEUED';*/

                        LOOP
                        BEGIN
                        FETCH jobcode_delta BULK COLLECT
                        INTO Jobcodedeltatype.SETID
                        ,Jobcodedeltatype.JOBCODE
                        ,Jobcodedeltatype.EFFDT
                        ,Jobcodedeltatype.EFF_STATUS
                        ,Jobcodedeltatype.DESCR
                        ,Jobcodedeltatype.LAST_UPD_DATE;

                        END;

                        if Jobcodedeltatype.JOBCODE.count <=0 then
                            CLOSE jobcode_delta;
                            EXIT;
                        end if;

                        p_cnt := p_cnt + Jobcodedeltatype.JOBCODE.count;

                        if  jobcode_delta%NOTFOUND then
                            CLOSE jobcode_delta;
                            EXIT;
                        end if;

                        END LOOP;


                        FOR I IN 1 .. p_cnt Loop

                        select hrhd_delta_sync_seq.nextval into p_unique_key from dual;

                           insert into HR_JOBCODE_DELTA_SYNC(
                            SETID ,
                            JOBCODE ,
                            EFFDT,
                            EFF_STATUS ,
                            DESCR ,
                            STATUS ,
                            EFFECTIVE_STATUS_DATE ,
                            LAST_UPDATE_DATE ,
                            EVENT_KEY)
                            values(
                        Jobcodedeltatype.SETID(I)
                        ,Jobcodedeltatype.JOBCODE(I)
                        ,Jobcodedeltatype.EFFDT(I)
                        ,Jobcodedeltatype.EFF_STATUS(I)
                        ,Jobcodedeltatype.DESCR(I)
                        ,'QUEUED'
                        ,sysdate
                        ,Jobcodedeltatype.LAST_UPD_DATE(I)
                        ,Jobcodedeltatype.SETID(I)||Jobcodedeltatype.JOBCODE(I)||'-'||to_char(p_unique_key));

                        commit;



                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
                        WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'JOBCODE',l_params);
                        WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
                        WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID',Jobcodedeltatype.SETID(I)||Jobcodedeltatype.JOBCODE(I)||'-'||to_char(p_unique_key) , l_params);
                        WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
                        p_event_key => Jobcodedeltatype.SETID(I)||Jobcodedeltatype.JOBCODE(I)||'-'||to_char(p_unique_key),
                        p_parameters => l_params);

                       open csr_gen_msg(Jobcodedeltatype.SETID(1)||Jobcodedeltatype.JOBCODE(1)||'-'||to_char(p_unique_key));

                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                             if csr_gen_msg%found then

                        if p_gen_status not in ('0','10') then
            				FND_FILE.NEW_LINE(FND_FILE.log, 1);
            				FND_FILE.put_line(fnd_file.log,'JobCode Delta Synch Data Extraction Ends for the document id '||Jobcodedeltatype.SETID(1)||
					       Jobcodedeltatype.JOBCODE(1)||'-'
					       ||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
                        end if;
                        end if;
                        close csr_gen_msg;

                    END loop;

                        hr_delta_sync_messages.update_psft_sync_run(1,'JOBCODE_DELTA_SYNC',p_effective_date,errbuf,retcode);
            		    FND_FILE.NEW_LINE(FND_FILE.log, 1);
                	    FND_FILE.put_line(fnd_file.log,'Jobcode Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
        end if;

        EXCEPTION
        WHEN OTHERS THEN
            hr_delta_sync_messages.update_psft_sync_run(3,'JOBCODE_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Jobcode Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		end hr_jobcode_delta_sync;
		/*Procedure to extract the jobcode data for delta synch process ends here*/
		/*Procedure to extract the organization data for delta synch process begins here*/
		procedure hr_organizaton_delta_sync(errbuf  OUT NOCOPY VARCHAR2
		 								   ,retcode OUT NOCOPY VARCHAR2
                                            ,p_party_site_id in NUMBER)
		is
		p_bg_id hr_all_organization_units.business_group_id%type;
		p_dept_id hr_all_organization_units.organization_id%type;
		p_eff_date date;
		p_loc_id hr_all_organization_units.location_id%type;
		p_person_id per_org_manager_v.person_id%type;
		p_full_name per_org_manager_v.full_name%type;
		 p_bg_name hr_all_organization_units.name%type;
		 p_eff_status varchar2(10);
		 p_effective_date  date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		 p_last_update_date date;
		 p_unique_key  number;
		 p_row_id    rowid;
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);


	 	 cursor fet_orgn_fsync(p_max_run_date date) is
		 select org.business_group_id,
                    org.organization_id,
                    case when org.date_to is null then org.date_from
                    else org.date_to end,
                    case when org.date_to is null then 'ACTIVE'
                    else 'INACTIVE' end,
                    org.name,
                    org.location_id,
                    mgr.person_id,
                    mgr.full_name,
                    org.last_update_date
             from hr_all_organization_units org
             ,per_org_manager_v mgr,hr_organization_information hrorg
              where org.business_group_id = mgr.business_group_id(+)
             and  org.organization_id = mgr.organization_id(+)
              and hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = 'HR_ORG'
             and sysdate between org.date_from
             and nvl(org.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
             and  sysdate between mgr.start_date(+) and mgr.end_date(+)
             and org.last_update_date > p_max_run_date
             and (org.business_group_id,org.organization_id) not in (select orgn.business_group_id,orgn.organization_id
        	    from hr_organization_delta_sync orgn
        	    where org.business_group_id = orgn.business_group_id
        	    and org.organization_id = orgn.organization_id
                and org.last_update_date <= orgn.last_update_date
        	    and   orgn.status in ('QUEUED','SENT'));

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_delta_status
		 is
		 select business_group_id,organization_id,event_key,last_update_date from
		 hr_organization_delta_sync
		 where status = 'QUEUED';

		 p_bgrp_id number(15);
		 p_orgn_id number(15);
		 p_lstupd_date date;

		 cursor fet_orgn_sync(p_bgrp_id number,p_orgn_id number,p_lstupd_date date)
		 is
         	 select org.business_group_id,
                    org.organization_id,
                    case when org.date_to is null then org.date_from
                    else org.date_to end,
                    case when org.date_to is null then 'ACTIVE'
                    else 'INACTIVE' end,
                    org.name,
                    org.location_id,
                    mgr.person_id,
                    mgr.full_name,
                    org.last_update_date
             from hr_all_organization_units org
             ,per_org_manager_v mgr,hr_organization_information hrorg
              where org.business_group_id = mgr.business_group_id(+)
             and  org.organization_id = mgr.organization_id(+)
              and hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = 'HR_ORG'
             and sysdate between org.date_from
             and nvl(org.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
             and  sysdate between mgr.start_date(+) and mgr.end_date(+)
             and org.organization_id = p_orgn_id
             and org.business_group_id = p_bgrp_id
             and  org.last_update_date >= p_lstupd_date ;

		 p_event_key_gen varchar2(50);

		 cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'ORG_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'ORG_FULL_SYNC'
		 and    status = 'COMPLETED';

		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'ORG_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		 l_dummy number;
		 p_max_run_date date;

		 begin

		 	open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then
		 			FND_FILE.NEW_LINE(FND_FILE.log, 1);
					FND_FILE.put_line(fnd_file.log,'Organization Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
					hr_delta_sync_messages.insert_psft_sync_run(2,'ORG_DELTA_SYNC',errbuf,retcode);



					open fet_psft_run_dt;
		 			fetch fet_psft_run_dt into p_max_run_date;
		 			close fet_psft_run_dt;

		 			if p_max_run_date is null
					then
					open fet_psft_run_dt1;
					fetch fet_psft_run_dt1 into p_max_run_date;
					close fet_psft_run_dt1;
					end if;

					open fet_delta_status;
					loop
					  fetch fet_delta_status into p_bgrp_id,p_orgn_id,p_event_key_gen,p_lstupd_date;

                      if fet_delta_status%found then

                      update hr_organization_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_orgn_sync(p_bgrp_id,p_orgn_id,p_lstupd_date);
        				  fetch fet_orgn_sync into p_bg_id,p_dept_id,p_eff_date,p_eff_status,p_bg_name,p_loc_id,p_person_id,p_full_name,p_last_update_date;
        				  if fet_orgn_sync%found then

				                select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            					insert into hr_organization_delta_sync(BUSINESS_GROUP_ID,
                                ORGANIZATION_ID,
                                BUSINESS_GROUP_NAME ,
                                EFFECTIVE_DATE,
                                EFFECTIVE_STATUS ,
                                COMPANY,
                                SETID_LOCATION,
                                LOCATION_ID,
                                MANAGER_ID ,
                                MANAGER_FULL_NAME,
                                LAST_UPDATE_DATE ,
                                STATUS,
                                EFFECTIVE_STATUS_DATE ,
                                EVENT_KEY
                                )
                                values(p_bg_id,p_dept_id,p_bg_name,p_eff_date,p_eff_status,p_bg_id,p_bg_id,p_loc_id,p_person_id,p_full_name,p_last_update_date,'QUEUED',p_effective_date,
            					to_char(p_dept_id)||'-'||to_char(p_unique_key));
                                commit;

            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'ORGN',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_dept_id)||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => to_char(p_dept_id)||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);

                                    open csr_gen_msg(to_char(p_dept_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Organization Delta Synch Data Extraction Ends for the document id '||to_char(p_dept_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
	    	  				            end if;
				                     close csr_gen_msg;


                            end if;
                            close fet_orgn_sync;
                           else
                              exit;
                            end if;
                    end loop;

                    close fet_delta_status;

		 			open fet_orgn_fsync(p_max_run_date);
		            loop
				             fetch fet_orgn_fsync into p_bg_id,p_dept_id,p_eff_date,p_eff_status,p_bg_name,p_loc_id,p_person_id,p_full_name,p_last_update_date;
		            		 if 	fet_orgn_fsync%found then
									select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
									insert into hr_organization_delta_sync(BUSINESS_GROUP_ID,
                                                    ORGANIZATION_ID,
                                                    BUSINESS_GROUP_NAME ,
                                                    EFFECTIVE_DATE,
                                                    EFFECTIVE_STATUS ,
                                                    COMPANY,
                                                    SETID_LOCATION,
                                                    LOCATION_ID,
                                                    MANAGER_ID ,
                                                    MANAGER_FULL_NAME,
                                                    LAST_UPDATE_DATE ,
                                                    STATUS,
                                                    EFFECTIVE_STATUS_DATE ,
                                                    EVENT_KEY
                                                    )
                                    values(p_bg_id,p_dept_id,p_bg_name,p_eff_date,p_eff_status,p_bg_id,p_bg_id,p_loc_id,p_person_id,p_full_name,p_last_update_date,'QUEUED',p_effective_date,
            					    to_char(p_dept_id)||'-'||to_char(p_unique_key));
                                    commit;
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'ORGN',l_params);
						            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
						            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_dept_id)||'-'||to_char(p_unique_key), l_params);
						            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
						                           p_event_key => to_char(p_dept_id)||'-'||to_char(p_unique_key),
						                           p_parameters => l_params);

						           		open csr_gen_msg(to_char(p_dept_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Organization Delta Synch Data Extraction Ends for the document id '||to_char(p_dept_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
	    	  				            end if;
				                     close csr_gen_msg;
				              else
				                exit;
				             end if;
					end loop;
		             		close fet_orgn_fsync;

					  hr_delta_sync_messages.update_psft_sync_run(1,'ORG_DELTA_SYNC',p_effective_date,errbuf,retcode);
					  FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  FND_FILE.put_line(fnd_file.log,'Organization Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		 	end if;

		  	exception
        	when OTHERS then
		    hr_delta_sync_messages.update_psft_sync_run(3,'ORG_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Organization Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_organizaton_delta_sync;
	    /*Procedure to extract the organization data for delta synch process begins here*/

		/*Procedure to extract the business group data for delta synch process begins here*/
		procedure hr_businessgrp_delta_sync(errbuf  OUT NOCOPY VARCHAR2
		 								   ,retcode OUT NOCOPY VARCHAR2
                                            ,p_party_site_id in NUMBER)
		is
		 p_bg_id PER_BUSINESS_GROUPS.business_group_id%type;
		 p_bg_name PER_BUSINESS_GROUPS.name%type;
		 p_eff_status varchar2(10);
		 p_eff_date date;
		 p_effective_date  date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		 p_last_update_date date;
		 p_unique_key  number;
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);


	 	 cursor fet_bg_fsync(p_max_run_date date) is
		 select business_group_id,
                    name,
                    case when date_to is null then date_from
                    else date_to end,
                    case when date_to is null then 'ACTIVE'
                    else 'INACTIVE' end,
                    last_update_date
             from hr_all_organization_units org
             where last_update_date > p_max_run_date
             and org.organization_id = org.business_group_id
		     and (business_group_id) not in (select business_group_id
		     from hr_bgrp_delta_sync bg
		     where org.business_group_id = bg.business_group_id
             and org.last_update_date <= bg.last_update_date
     	     and   bg.status in ('QUEUED','SENT'));

		 cursor fet_delta_status
		 is
		 select business_group_id,event_key,last_update_date from
		 hr_bgrp_delta_sync
		 where status = 'QUEUED';

		 p_bgrp_id number(15);
		 p_lstupd_date date;

		 cursor fet_bg_sync(p_bgrp_id number,p_lstupd_date date)
		 is
		select business_group_id,
                    name,
                    case when date_to is null then date_from
                    else date_to end,
                    case when date_to is null then 'ACTIVE'
                    else 'INACTIVE' end,
                    last_update_date
		from hr_all_organization_units org
		 where business_group_id = p_bgrp_id
		 and business_group_id = organization_id
		and last_update_date >= p_lstupd_date;

		cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 p_event_key_gen varchar2(50);

		 cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'BG_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'BG_FULL_SYNC'
		 and    status = 'COMPLETED';

		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'BG_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		 l_dummy number;
		 p_max_run_date date;

		 begin

		 	open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then
		 			FND_FILE.NEW_LINE(FND_FILE.log, 1);
					FND_FILE.put_line(fnd_file.log,'Business Group Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
					hr_delta_sync_messages.insert_psft_sync_run(2,'BG_DELTA_SYNC',errbuf,retcode);



					open fet_psft_run_dt;
		 			fetch fet_psft_run_dt into p_max_run_date;
		 			close fet_psft_run_dt;

		 			if p_max_run_date is null
					then
					open fet_psft_run_dt1;
					fetch fet_psft_run_dt1 into p_max_run_date;
					close fet_psft_run_dt1;
					end if;

					open fet_delta_status;
					loop
					  fetch fet_delta_status into p_bgrp_id,p_event_key_gen,p_lstupd_date;

                      if fet_delta_status%found then

                      update hr_bgrp_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_bg_sync(p_bgrp_id,p_lstupd_date);
        				  fetch fet_bg_sync into p_bg_id,p_bg_name,p_eff_date,p_eff_status,p_last_update_date;
        				  if fet_bg_sync%found then

				                select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            					insert into hr_bgrp_delta_sync(BUSINESS_GROUP_ID,BUSINESS_GROUP_NAME,
                                EFFECTIVE_DATE,EFFECTIVE_STATUS,LAST_UPDATE_DATE ,STATUS,EFFECTIVE_STATUS_DATE,
                                EVENT_KEY)
                                values(p_bg_id,p_bg_name,p_eff_date,p_eff_status,p_last_update_date,'QUEUED',p_effective_date,
            					to_char(p_bg_id)||'-'||to_char(p_unique_key));
                                commit;


            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'BGRP',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_bg_id)||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => to_char(p_bg_id)||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);

                                       open csr_gen_msg(to_char(p_bg_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                         if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Business Group Delta Synch Data Extraction Ends for the document id '||to_char(p_bg_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
                                         end if;
                                         close csr_gen_msg;

                            end if;
                            close fet_bg_sync;
                          else
                             exit;
                            end if;
                    end loop;

                    close fet_delta_status;

		 			open fet_bg_fsync(p_max_run_date);
		            loop
				             fetch fet_bg_fsync into  p_bg_id,p_bg_name,p_eff_date,p_eff_status,p_last_update_date;
		            		 if 	fet_bg_fsync%found then
									select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
									insert into hr_bgrp_delta_sync(BUSINESS_GROUP_ID,BUSINESS_GROUP_NAME,
                                    EFFECTIVE_DATE,EFFECTIVE_STATUS,LAST_UPDATE_DATE ,STATUS,EFFECTIVE_STATUS_DATE,
                                    EVENT_KEY)
                                   values(p_bg_id,p_bg_name,p_eff_date,p_eff_status,p_last_update_date,'QUEUED',p_effective_date,
            					   to_char(p_bg_id)||'-'||to_char(p_unique_key));
                                    commit;
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'BGRP',l_params);
						            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
						            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_bg_id)||'-'||to_char(p_unique_key), l_params);
						            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
						                           p_event_key => to_char(p_bg_id)||'-'||to_char(p_unique_key),
						                           p_parameters => l_params);

						           		open csr_gen_msg(to_char(p_bg_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                         if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Business Group Delta Synch Data Extraction Ends for the document id '||to_char(p_bg_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
                                         end if;
                                         close csr_gen_msg;
				              else
				                exit;
				             end if;
					end loop;
		             		close fet_bg_fsync;

					  hr_delta_sync_messages.update_psft_sync_run(1,'BG_DELTA_SYNC',p_effective_date,errbuf,retcode);
					  FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  FND_FILE.put_line(fnd_file.log,'Business Group Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		 	end if;

		  	exception
        	when OTHERS then
		    hr_delta_sync_messages.update_psft_sync_run(3,'BG_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Business Group Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_businessgrp_delta_sync;
	/*Procedure to extract the business group data for delta synch process ends here*/

	/*Procedure to extract the payroll group data for delta synch process begins here*/
		procedure hr_payroll_delta_sync(errbuf  OUT NOCOPY VARCHAR2
		                               ,retcode OUT NOCOPY VARCHAR2
                                       ,p_party_site_id in NUMBER)
		is
		 p_pyrl_id pay_all_payrolls_f.payroll_id%type;
		 p_pyrl_name pay_all_payrolls_f.payroll_name%type;
		 p_bg_id pay_all_payrolls_f.business_group_id%type;
		 p_eff_date date;
		 p_eff_status varchar2(10);
		 p_effective_date  date default sysdate;
		 l_params WF_PARAMETER_LIST_T;
		p_last_update_date date;
		 p_unique_key  number;
		 p_gen_msg    VARCHAR2(4000);
		 p_gen_status  varchar2(10);


	 	 cursor fet_pyrl_fsync(p_max_run_date date) is
		 select  payroll_id,
    	        payroll_name,
    	        business_group_id,
    	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
    	        then add_months(first_period_end_date,NUMBER_OF_YEARS*12) else (select min(effective_start_date) from
                                                                                 pay_all_payrolls_f pay1
                                                                                 where pay1.payroll_id = pay.payroll_id
                                                                                 and pay1.business_group_id = pay.business_group_id) end,
    	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
    	        then 'INACTIVE' else 'ACTIVE' end,
    	        last_update_date
    		from pay_all_payrolls_f pay
		where last_update_date > p_max_run_date
		and p_effective_date between effective_start_date and effective_end_date
		and (payroll_id,business_group_id)  not in (select pyrl.payroll_id,pyrl.business_group_id
		 from hr_pyrl_delta_sync pyrl
		 where pay.payroll_id = pyrl.payroll_id
		 and   pay.business_group_id = pyrl.business_group_id
         and   pay.last_update_date <= pyrl.last_update_date
		 and   pyrl.status in ('QUEUED','SENT'));

		 cursor csr_gen_msg(p_evn_key varchar2)
		is select generation_status,generation_message
		from ecx_out_process_v prcs
		where document_id = p_evn_key;

		 cursor fet_delta_status
		 is
		 select payroll_id,business_group_id,event_key,last_update_date from
		 hr_pyrl_delta_sync
		 where status = 'QUEUED';

		 p_payroll_id number(9,0);
		 p_bgrp_id NUMBER(15,0);
		 p_lstupd_date date;

		 cursor fet_pyrl_sync(p_payroll_id number,p_bgrp_id number,p_lstupd_date date)
		 is
		select  payroll_id,
    	        payroll_name,
    	        business_group_id,
    	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
    	        then add_months(first_period_end_date,NUMBER_OF_YEARS*12) else (select min(effective_start_date) from
                                                                                 pay_all_payrolls_f pay1
                                                                                 where pay1.payroll_id = pay.payroll_id
                                                                                 and pay1.business_group_id = pay.business_group_id) end,
    	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
    	        then 'INACTIVE' else 'ACTIVE' end,
    	        last_update_date
    	 from pay_all_payrolls_f pay
    	 where pay.payroll_id = p_payroll_id
    	 and   pay.business_group_id = p_bgrp_id
         and p_effective_date between effective_start_date and effective_end_date
         and last_update_date >= p_lstupd_date;

 	     p_event_key_gen varchar2(50);

		 cursor fet_psft_run_dt is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'PYRL_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'COMPLETED';

		 cursor fet_psft_run_dt1 is
		 select max(run_date)
		 from   hr_psft_sync_run
		 where  process = 'PYRL_FULL_SYNC'
		 and    status = 'COMPLETED';

		 cursor fet_psft_sync is
		 select count('x')
		 from   hr_psft_sync_run
		 where  process = 'PYRL_DELTA_SYNC'
		 and    run_date < p_effective_date
		 and    status = 'STARTED';

		 l_dummy number;
		 p_max_run_date date;

		 begin

		 	open fet_psft_sync;
		 	fetch fet_psft_sync into l_dummy;
		   	close fet_psft_sync;
		 	if l_dummy = 0
		 	then
		 			FND_FILE.NEW_LINE(FND_FILE.log, 1);
					FND_FILE.put_line(fnd_file.log,'Payroll Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
					hr_delta_sync_messages.insert_psft_sync_run(2,'PYRL_DELTA_SYNC',errbuf,retcode);



					open fet_psft_run_dt;
		 			fetch fet_psft_run_dt into p_max_run_date;
		 			close fet_psft_run_dt;

		 			if p_max_run_date is null
					then
					open fet_psft_run_dt1;
					fetch fet_psft_run_dt1 into p_max_run_date;
					close fet_psft_run_dt1;
					end if;

					open fet_delta_status;
					loop
					  fetch fet_delta_status into p_payroll_id,p_bgrp_id,p_event_key_gen,p_lstupd_date;

                      if fet_delta_status%found then

                      update hr_pyrl_delta_sync
    				  set  status = 'SENT'
    				  where event_key = p_event_key_gen;
    				  commit;

        				  open fet_pyrl_sync(p_payroll_id,p_bgrp_id,p_lstupd_date);
        				  fetch fet_pyrl_sync into p_pyrl_id,p_pyrl_name,p_bg_id,p_eff_date,p_eff_status,p_last_update_date;
        				  if fet_pyrl_sync%found then

				                select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
            					insert into hr_pyrl_delta_sync(PAYROLL_ID,
                                    PAYROLL_NAME,
                                    BUSINESS_GROUP_ID ,
                                    EFFECTIVE_DATE,
                                    EFFECTIVE_STATUS ,
                                    LAST_UPDATE_DATE,
                                    STATUS ,
                                    EFFECTIVE_STATUS_DATE,
                                    EVENT_KEY
                                    )
                                 values(p_pyrl_id,p_pyrl_name,p_bg_id,p_eff_date,p_eff_status,p_last_update_date,'QUEUED',p_effective_date,
            					to_char(p_pyrl_id)||'-'||to_char(p_unique_key));
                                commit;


            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            		            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'PYRL',l_params);
            		            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
            		            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_pyrl_id)||'-'||to_char(p_unique_key), l_params);
            		            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
            		                           p_event_key => to_char(p_pyrl_id)||'-'||to_char(p_unique_key),
            		                           p_parameters => l_params);

                                         open csr_gen_msg(to_char(p_pyrl_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Payroll Delta Synch Data Extraction Ends for the document id '||to_char(p_pyrl_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
	    	  				            end if;
	    	  				            close csr_gen_msg;

                            end if;
                            close fet_pyrl_sync;
                           else
                              exit;
                            end if;
                    end loop;

                    close fet_delta_status;

		 			open fet_pyrl_fsync(p_max_run_date);
		            loop
				             fetch fet_pyrl_fsync into p_pyrl_id,p_pyrl_name,p_bg_id,p_eff_date,p_eff_status,p_last_update_date;
		            		 if 	fet_pyrl_fsync%found then
									select hrhd_delta_sync_seq.nextval into p_unique_key from dual;
								    insert into hr_pyrl_delta_sync(PAYROLL_ID,
                                    PAYROLL_NAME,
                                    BUSINESS_GROUP_ID ,
                                    EFFECTIVE_DATE,
                                    EFFECTIVE_STATUS ,
                                    LAST_UPDATE_DATE,
                                    STATUS ,
                                    EFFECTIVE_STATUS_DATE,
                                    EVENT_KEY
                                    )
                                    values(p_pyrl_id,p_pyrl_name,p_bg_id,p_eff_date,p_eff_status,p_last_update_date,'QUEUED',p_effective_date,
         					               to_char(p_pyrl_id)||'-'||to_char(p_unique_key));
                                    commit;
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
						            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'PYRL',l_params);
						            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_party_site_id), l_params);
						            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', to_char(p_pyrl_id)||'-'||to_char(p_unique_key), l_params);
						            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
						                           p_event_key => to_char(p_pyrl_id)||'-'||to_char(p_unique_key),
						                           p_parameters => l_params);

						           		open csr_gen_msg(to_char(p_pyrl_id)||'-'||to_char(p_unique_key));

                                         fetch csr_gen_msg into p_gen_status,p_gen_msg;
                                             if csr_gen_msg%found then

							            if p_gen_status not in ('0','10') then
											FND_FILE.NEW_LINE(FND_FILE.log, 1);
				    	  					FND_FILE.put_line(fnd_file.log,'Payroll Delta Synch Data Extraction Ends for the document id '||to_char(p_pyrl_id)||'-'||to_char(p_unique_key)||'due to :'||p_gen_msg||'on'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	    	  				            end if;
	    	  				            end if;
	    	  				            close csr_gen_msg;
				              else
				                exit;
				             end if;
					end loop;
		             		close fet_pyrl_fsync;

					  hr_delta_sync_messages.update_psft_sync_run(1,'PYRL_DELTA_SYNC',p_effective_date,errbuf,retcode);
					  FND_FILE.NEW_LINE(FND_FILE.log, 1);
			    	  FND_FILE.put_line(fnd_file.log,'Payroll Delta Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		 	end if;

		  	exception
        	when OTHERS then
		    hr_delta_sync_messages.update_psft_sync_run(3,'PYRL_DELTA_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Payroll Delta Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_payroll_delta_sync;
	/*Procedure to extract the payroll group data for delta synch process ends here*/

	/*Common procedure called from concurrent program to extract the data begins here*/
	procedure hr_delta_sync (ERRBUF           OUT NOCOPY varchar2,
	                        RETCODE          OUT NOCOPY number,
	                        p_process_name in varchar2,
                            p_party_site_id in number)
	is
	p_effective_date date default sysdate;
	begin
	FND_FILE.NEW_LINE(FND_FILE.log, 1);
	FND_FILE.put_line(fnd_file.log,'Delta synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	 if p_process_name = 'STATE_DELTA_SYNCH'
	  then
	  hr_delta_sync_messages.hr_state_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'COUNTRY_DELTA_SYNCH'
	  then

	  hr_delta_sync_messages.hr_country_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'LOCATION_DELTA_SYNCH'
	  then
	  hr_delta_sync_messages.hr_location_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'PERSON_DELTA_SYNCH'
	  then
	  hr_delta_sync_messages.hr_person_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'WORKFORCE_DELTA_SYNCH'
	  then
	  hr_delta_sync_messages.hr_workforce_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'JOBCODE_DELTA_SYNCH' then
	  hr_delta_sync_messages.hr_jobcode_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'ORGANIZATION_DELTA_SYNCH' then
	  hr_delta_sync_messages.hr_organizaton_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'BUSINESSGROUP_DELTA_SYNCH' then
	  hr_delta_sync_messages.hr_businessgrp_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  elsif p_process_name = 'PAYROLL_DELTA_SYNCH' then
	  hr_delta_sync_messages.hr_payroll_delta_sync(ERRBUF,RETCODE,p_party_site_id);
	  end if;
	FND_FILE.NEW_LINE(FND_FILE.log, 1);
	FND_FILE.put_line(fnd_file.log,'Delta synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
	end hr_delta_sync;
	/*Common procedure called from concurrent program to extract the data ends here*/

    /*common procedure to update the status of the sync data from message designer starts here*/
    PROCEDURE update_delta_msg_status(p_event_key varchar2,
                                  p_process_name varchar2)
    is
    begin
     if p_process_name = 'STATE_DELTA_SYNCH'
	  then
	  update hr_state_delta_sync
	  set status = 'SENT'
	  where event_key = p_event_key;

	  elsif p_process_name = 'COUNTRY_DELTA_SYNCH'
	  then

	  update hr_country_delta_sync
	  set status = 'SENT'
	  where event_key = p_event_key;

	  elsif p_process_name = 'LOCATION_DELTA_SYNCH'
	  then

	  update hr_locn_delta_sync
	  set status = 'SENT'
	  where event_key = p_event_key;

	  elsif p_process_name = 'PERSON_DELTA_SYNCH'
	  then

	   update hr_person_delta_sync
	   set status = 'SENT'
	   where record_key = p_event_key;

	  elsif p_process_name = 'WORKFORCE_DELTA_SYNCH'
	  then

       update HR_WORKFORCE_DELTA_SYNC
	   set status = 'SENT'
	   where event_key = p_event_key;

	  elsif p_process_name = 'JOBCODE_DELTA_SYNCH' then

	   update HR_JOBCODE_DELTA_SYNC
	   set status = 'SENT'
	   where event_key = p_event_key;

	  elsif p_process_name = 'ORGANIZATION_DELTA_SYNCH' then

       update hr_organization_delta_sync
	   set status = 'SENT'
	   where event_key = p_event_key;

	  elsif p_process_name = 'BUSINESSGROUP_DELTA_SYNCH' then

       update hr_bgrp_delta_sync
	   set status = 'SENT'
	   where event_key = p_event_key;

	  elsif p_process_name = 'PAYROLL_DELTA_SYNCH' then

	   update hr_pyrl_delta_sync
	   set status = 'SENT'
	   where event_key = p_event_key;

	  end if;
	  end;

    /*common procedure to update the status of the sync data from message designer ends here*/

end hr_delta_sync_messages;


/
