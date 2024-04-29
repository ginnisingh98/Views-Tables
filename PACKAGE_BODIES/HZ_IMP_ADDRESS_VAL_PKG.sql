--------------------------------------------------------
--  DDL for Package Body HZ_IMP_ADDRESS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_ADDRESS_VAL_PKG" as
/*$Header: ARHADRVB.pls 120.20 2005/10/30 04:16:56 appldev noship $*/

-------------------------------------------------------------------
-- The procedure,address_validation_child will be called by
-- address_validation_main  procedure for each batch.
-- This procedure will intern call 'oracle.apps.ar.hz.import.outboundxml'
-- event subscription.
------------------------------------------------------------------------
 procedure address_validation_child(
  	Errbuf     OUT NOCOPY VARCHAR2,
	Retcode    OUT NOCOPY VARCHAR2,
    p_batch_id  	   		IN  NUMBER,
  	P_VAL_SUBSET_ID		 	IN  NUMBER DEFAULT NULL,
  	p_country_code    		IN  VARCHAR2 DEFAULT NULL,
  	p_module          		IN  VARCHAR2 DEFAULT NULL,
  	p_module_id       		IN  NUMBER DEFAULT NULL,
  	P_OVERWRITE_THRESHOLD  IN  VARCHAR2 DEFAULT NULL,
  	P_ORIG_SYSTEM			IN VARCHAR2 DEFAULT NULL,
  	P_ADAPTER_ID			IN	NUMBER DEFAULT NULL)
 is

  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
  l_return_status   VARCHAR2(30);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_request_id      NUMBER;
  l_event_key	    VARCHAR2(30);
  l_adapter_content_source 	hz_adapters.ADAPTER_CONTENT_SOURCE%type;
  l_adapter_id	   	hz_adapters.adapter_id%type;
  p_subset_id		NUMBER;
 begin
  --
  ---Set parameter mapcode in parameter list
  --
  wf_event.AddParameterToList(
	      p_name => 'ECX_MAP_CODE',
	      p_value => 'TCA_IMP_OAG_OUTBOUND',
	      p_parameterlist => l_parameter_list);

  --
  ---Set parameter where-clause of mapcode in parameter list
  --
   wf_event.AddParameterToList(
      p_name => 'P_BATCH_ID',
      p_value => p_batch_id,
      p_parameterlist => l_parameter_list);
  --
  ---Set parameter where-clause of mapcode in parameter list
  --
   wf_event.AddParameterToList(
      p_name => 'P_ORIG_SYSTEM_REFERENCE',
      p_value => P_ORIG_SYSTEM,
      p_parameterlist => l_parameter_list);
  --
  ---Set parameter where-clause of mapcode in parameter list
  --
   wf_event.AddParameterToList(
      p_name => 'P_VAL_SUBSET_ID',
      p_value => P_VAL_SUBSET_ID,
      p_parameterlist => l_parameter_list);

  --
  ---Set parameter where-clause of mapcode in parameter list
  --
   wf_event.AddParameterToList(
      p_name => 'P_OVERWRITE_THRESHOLD',
      p_value => P_OVERWRITE_THRESHOLD,
      p_parameterlist => l_parameter_list);

  --
  ---Set parameter where-clause of mapcode in parameter list
  --
   wf_event.AddParameterToList(
      p_name => 'P_ADAPTER_ID',
      p_value => P_ADAPTER_ID,
      p_parameterlist => l_parameter_list);

  --
  -- Raise event for outbound  XML
  --
  l_event_key := 'HZ_IMP_ADDROUT-'||to_char(P_ADAPTER_ID)||'-'||to_char(p_batch_id)||'-'||to_char(p_subset_id);
  wf_event.raise(
      p_event_name      => 'oracle.apps.ar.hz.import.outboundxml',
      p_event_key       => l_event_key,
      p_event_data	    => NULL,
      p_parameters      => l_parameter_list,
      p_send_date       => null);

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.put_line(fnd_file.log,'Others Error: Aborting Address Validation Child for this batch');
    FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    raise;
END address_validation_child;

-----------------------------------------------------------------------
-- The procedure,address_validation_main will be called by
-- UI Console wrapper concurrent program for each batch.
-- This procedure will intern call address_validation_child cp
--
------------------------------------------------------------------------

procedure address_validation_main(
  	Errbuf         OUT NOCOPY VARCHAR2,
  	Retcode        OUT NOCOPY VARCHAR2,
  	p_batch_id     IN NUMBER) is

 TYPE BATCH_ID					IS TABLE OF HZ_IMP_ADDRESSES_INT.BATCH_ID%TYPE;
 TYPE ADAPTER_ID				IS TABLE OF HZ_ADAPTERS.ADAPTER_ID%TYPE;
 TYPE ADAPTER_CONTENT_SOURCE 	IS TABLE OF HZ_ADAPTERS.ADAPTER_CONTENT_SOURCE%TYPE;
 TYPE BATCH_SIZE				IS TABLE OF HZ_ADAPTERS.DEFAULT_BATCH_SIZE%TYPE;
 TYPE ROWID			   			IS TABLE OF VARCHAR2(50);
 TYPE REQUEST_ID  				IS TABLE OF NUMBER;
 TYPE THRESHOLD_STATUS			IS TABLE OF HZ_ADAPTERS.DEFAULT_REPLACE_STATUS_LEVEL%TYPE;
 l_adapter_id 		 		ADAPTER_ID;
 l_adapter_content_source	ADAPTER_CONTENT_SOURCE;
 l_batch_size				BATCH_SIZE;
 l_batch_id					NUMBER := p_batch_id;
 l_row_id					ROWID;
 l_from_rowid				ROWID;
 l_to_rowid					ROWID;
 l_request_id				number;--REQUEST_ID;
 l_default_replace_level    THRESHOLD_STATUS;

 cursor verify_imp_adapter is select count(ADAPTER_CONTENT_SOURCE)
 						  from 	 hz_imp_adapters
 						  where  batch_id = p_batch_id
 						  and    send_flag = 'Y';

 cursor imp_adapter_cur is select adapter_id,adapter_content_source,nvl(MAXIMUM_BATCH_SIZE,DEFAULT_BATCH_SIZE),
 							  DEFAULT_REPLACE_STATUS_LEVEL
   					   from   hz_adapters
   					   where  enabled_flag = 'Y'
   					   and    adapter_content_source in
   					   			(select distinct ADAPTER_CONTENT_SOURCE
   					   			 from 	 hz_imp_adapters
 						  	         where  batch_id = p_batch_id
 						  		 and    send_flag = 'Y') ;

 cursor imp_addresss_cur(v_adapter varchar2) is select rowid
 						from   hz_imp_addresses_int
 						where  batch_id = p_batch_id
 						and   country in
 							(select country_code from hz_imp_adapters
 							 where  adapter_content_source = v_adapter
 							 and    batch_id = p_batch_id
 							 and    send_flag = 'Y');
						/*	or
								not exists (select 'X' from fnd_territories
 										where TERRITORY_CODE = country)
 							);
 							 OR
 							  country not in
 							(select territory_code from hz_adapter_territories
 							 where  adapter_id = v_adapter_id
 							 and default_flag = 'Y');*/

 cursor adapter_cur is select adapter_id,adapter_content_source,nvl(MAXIMUM_BATCH_SIZE,DEFAULT_BATCH_SIZE),
 							  DEFAULT_REPLACE_STATUS_LEVEL
   					   from   hz_adapters
   					   where  enabled_flag = 'Y'
   					   and    adapter_id in
   					   		(select distinct HZ_LOCATION_SERVICES_PUB.get_adapter_id(null,country)
  					   	 	 from   hz_imp_addresses_int
  							 where  batch_id = p_batch_id
							 --Bug No:3347996.Added conditions to overcome unnecessary calls to
							 --HZ_LOCATION_SERVICES_PUB.get_adapter_id.
							 and    country in (select distinct territory_code
								       from   hz_adapter_territories t,
								               hz_adapters ad
								       where  ad.adapter_id =t.adapter_id
								       and    ad.enabled_flag='Y'
								       and    t.enabled_flag='Y'
								       and    t.default_flag = 'Y')
							 and   exists (select 'X' from fnd_territories
 								       where TERRITORY_CODE = country)
							 ----End of Bug No:3347996
							);

 cursor addresss_cur(v_adapter_id number) is select rowid
 						from   hz_imp_addresses_int
 						where  batch_id = p_batch_id
 						and    country in
 							(select territory_code from hz_adapter_territories t,
							                            hz_adapters ad
 							 where  t.adapter_id = v_adapter_id
							 and    ad.adapter_id =t.adapter_id
							 and    ad.enabled_flag='Y'
							 and    t.enabled_flag='Y' --Bug No:3347996
 							 and    t.default_flag = 'Y')
 						and  exists (select 'X' from fnd_territories
 									 where TERRITORY_CODE = country);

 cursor addresss_cur_default is select rowid
 						from   hz_imp_addresses_int
 						where  batch_id = p_batch_id
						--Bug No:3347996
 						and    country not in ((select distinct territory_code
								        from   hz_adapter_territories t,
									       hz_adapters ad
								        where ad.adapter_id=t.adapter_id
									and    ad.enabled_flag='Y'
									and    t.enabled_flag='Y'
								        and    t.default_flag = 'Y'
									)UNION
									(select distinct country_code
									 from hz_imp_adapters
									 where batch_id = p_batch_id
									 and   send_flag= 'Y')
								        );
						--End of --Bug No:3347996

						--Bug No:3347996--and not exists (select 'X' from fnd_territories
 						--Bug No:3347996			where TERRITORY_CODE = country);

 cursor default_adapter is select  adapter_id,adapter_content_source,nvl(MAXIMUM_BATCH_SIZE,DEFAULT_BATCH_SIZE),
 							  DEFAULT_REPLACE_STATUS_LEVEL
 						   from  hz_adapters
 						   where enabled_flag = 'Y'
 						   and   adapter_id = to_number(fnd_profile.value('HZ_DEFAULT_LOC_ADAPTER'));

 cursor validated_address_cur is
 		select 	country,count(decode(ACCEPT_STANDARDIZED_FLAG,'Y','Y',null))Validated_rec,
       			count(decode(ACCEPT_STANDARDIZED_FLAG,'N','N',null))Failed_rec,
       			count(ACCEPT_STANDARDIZED_FLAG)Total_rec
		from  	hz_imp_addresses_int
		where 	batch_id = p_batch_id
		and   	ACCEPT_STANDARDIZED_FLAG is not null
		group by country;

 cursor find_imp_country(p_country_code  varchar2) is select 'X' from hz_imp_adapters
 							where batch_id = p_batch_id
 							and country_code = p_country_code;
 l_count   	   		NUMBER;
 l_counter     		NUMBER :=0;
 l_error_count 		NUMBER :=0;
 l_success_count 	NUMBER :=0;
 l_last_fetch  		boolean;
 l_adapter_log_id  	NUMBER;
 l_boolean			BOOLEAN;
 l_request_status	boolean;
 l_dev_phase		varchar2(30); --Bug No: 3778263

 l_phase			varchar2(80);
 l_status			varchar2(80);
 l_dev_status		varchar2(80);
 l_message			varchar2(250);
 l_orig_system		varchar2(30);
 v_completion		boolean;
 l_completed_request number:=0;
 l_total_request	number;
 l_m_request_id		NUMBER;
 l_request_data		varchar2(25000);

 l_posi1                 NUMBER;
 l_times                 NUMBER;
 l_sub_request_ids       VARCHAR2(200);
 l_sub_request_id		 NUMBER;
 l_adapter_last_fetch    boolean := false;
 l_import_adapter_def	 varchar2(1) :='N';
 l_dummy1		 varchar2(2);
 l_adapter_found	 BOOLEAN := FALSE; --Bug No: 3535366
BEGIN
  If p_batch_id is null then
  	FND_FILE.put_line(fnd_file.log,'Aborting Address Validation Main for this batch as no batch found');
    return;     --Nothing to process
  end if;

  l_request_data := FND_CONC_GLOBAL.REQUEST_DATA;
  l_last_fetch := FALSE;
  --l_request_id := REQUEST_ID() ;
  l_counter := 1;

  -- this is not first run
  IF l_request_data IS NOT NULL THEN
    l_success_count := 0;
    --l_error_count :=0;
    --l_completed_request :=0;
    l_sub_request_ids := l_request_data;
	/*
	    Loop  -- start of checking status of child CP
	    l_posi1 := INSTRB(l_sub_request_ids, ' ', 1, 1);
	    l_sub_request_id := TO_NUMBER(SUBSTRB(l_request_data, 1, l_posi1-1));
	      --for k in l_request_id.first..l_request_id.last loop
		l_request_status :=FND_CONCURRENT.get_request_status(l_sub_request_id,'','',l_phase,l_status,l_dev_phase,l_dev_status,l_message);
			if  l_request_status = FALSE or l_dev_phase ='COMPLETE' then
				l_completed_request := l_completed_request +1;
				if l_dev_status='ERROR' then
				l_error_count := l_error_count +1;
				else -- l_dev_status='NORMAL' then
				l_success_count := l_success_count +1;
			    end if;
			end if;
		  end loop;
		exit when  l_completed_request = l_total_request;
		end loop; -- end of checking status of child CP
	*/
   	--------------------------

     fnd_file.put_line(FND_FILE.LOG, 'Addrval : l_sub_request_ids='||l_sub_request_ids);

     WHILE l_sub_request_ids IS NOT NULL LOOP
        l_posi1 := INSTRB(l_sub_request_ids, ' ', 1, 1);
        l_sub_request_id := TO_NUMBER(SUBSTRB(l_sub_request_ids, 1, l_posi1-1));
	--fnd_file.put_line(FND_FILE.LOG, 'Addrval l_sub_request_id='||l_sub_request_id);
        -- Check return status of validation request.
        IF (FND_CONCURRENT.GET_REQUEST_STATUS(
              request_id  => l_sub_request_id,
              phase       => l_phase,
              status      => l_status,
              dev_phase   => l_dev_phase,
              dev_status  => l_dev_status,
              message     => l_message)) THEN
          fnd_file.put_line(FND_FILE.LOG,'Addrval : l_sub_request_id='||l_sub_request_id||',l_dev_phase='||l_dev_phase||',l_dev_status='||l_dev_status);
	  IF l_dev_phase <> 'COMPLETE'
             OR l_dev_status <> 'NORMAL' THEN
            retcode := 2;
            FND_FILE.PUT_LINE(FND_FILE.LOG,TO_CHAR( l_sub_request_id ) ||
                              ' : ' || l_phase || ':' || l_status ||
                              ' (' || l_message || ').' );
		    update HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS = 'ERROR'
		    where batch_id = l_batch_id;
            RETURN;
          END IF;
        else
           if l_message is not null then
            l_success_count := l_success_count+1;
           end if;
       	   retcode :=0;
        END IF;
        l_sub_request_ids := SUBSTRB( l_sub_request_ids, l_posi1 + 1 );
	--Bug No: 3546295
        /*if l_sub_request_ids is null then
         return;
        end if;
	*/
	--End of 3546295--------
     END LOOP;

	--bug 3908043: Populate counts in HZ_IMP_ADAPTERS
   	OPEN verify_imp_adapter;
  	FETCH verify_imp_adapter into l_count;
  	CLOSE verify_imp_adapter;

  	IF l_count > 0 then
		-- Adapter defined for import for this batch
		l_import_adapter_def := 'Y';
	END IF;

      -- update/insert count to hz_imp_adapters table.
      if l_import_adapter_def = 'Y' then
      	for rec in validated_address_cur loop
      	 open  find_imp_country(rec.country);
      	 fetch find_imp_country into l_dummy1;
      	 close find_imp_country;
      	 if l_dummy1 is not null then
      	 	update hz_imp_adapters
      	 	set RECORDS_PASSED_VALIDATION = rec.Validated_rec,
      	 		RECORDS_FAILED_VALIDATION = rec.Failed_rec,
      	 		TOTAL_RECORDS_VALIDATED = rec.Total_rec
      	 	where batch_id = p_batch_id
      	 	and COUNTRY_CODE = rec.country;
      	 else
      	 	insert into hz_imp_adapters
      	 		(batch_id,country_code,RECORDS_PASSED_VALIDATION,
      	 	     RECORDS_FAILED_VALIDATION,TOTAL_RECORDS_VALIDATED,
      	 	     CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
				 LAST_UPDATE_DATE)
      	 	values(p_batch_id,rec.country,rec.Validated_rec,
      	 	       rec.Failed_rec,rec.Total_rec,
      	 	       -1,sysdate,-1,sysdate);
     	 end if;
     	 end loop;
      end if;
      --Bug No: 3546295
      update HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS = 'COMPLETED'
      where batch_id = l_batch_id;
      --End of 3546295--------
      -------------------------------------
  ELSE
  /*
   Logic to process the records to address validation is as follows
   1.If any adapters are defined in hz_imp_adapters then
        a) Get the adapters from hz_imp_adapters for this batch and process
	   those country records with the adapters defined in the hz_imp_adapters.
        b) Process the remaining records(countries not in hz_imp_adapters and
	   not in hz_adapter_territories) with the default adapter.

      Note: We should not process the countries in hz_adapter_territories
            if adapters are defined in hz_imp_adapters for this batch.

    2.If no adapters are defined in hz_imp_adapters then
	a) Get the country's default adapter from hz_adapter_territories
	   and process those country records with the adapters defined in the hz_adapters.
        b) Process the remaining records(countries not in hz_adapter_territories)
	   with the default adapter
    3. If the above cases 1 and 2 fails then
       a) Process all the records with the system default adapter
  */
  	OPEN verify_imp_adapter;
  	FETCH verify_imp_adapter into l_count;
  	CLOSE verify_imp_adapter;

  	IF l_count > 0 then
		-- Adapter defined for import for this batch;so get the adapters from hz_imp_adapters
		l_import_adapter_def := 'Y';
		OPEN  imp_adapter_cur;
		FETCH imp_adapter_cur BULK COLLECT into
			l_adapter_id,l_adapter_content_source,l_batch_size,l_default_replace_level;
		CLOSE  imp_adapter_cur;
		FND_FILE.put_line(fnd_file.log,'adapter count:'|| l_adapter_id.count);
  	ELSE

		-- No Adapter defined for import in hz_imp_adapters for this batch;so get
		-- the adapters from hz_adapters.
		OPEN  adapter_cur;
		FETCH adapter_cur BULK COLLECT into
			l_adapter_id,l_adapter_content_source,l_batch_size,l_default_replace_level;
			FND_FILE.put_line(fnd_file.log,'l_adapter_id count:'|| l_adapter_id.count);
			IF adapter_cur%NOTFOUND THEN
				l_adapter_last_fetch := TRUE;
			END IF;
			IF l_adapter_id.count = 0 AND l_adapter_last_fetch THEN
			    FND_FILE.put_line(fnd_file.log,'No valid adapter found in hz_adapters for this batch.');
			    --RETURN; Bug no:3365035.Commented return to continue the execution.
			END IF;
		CLOSE  adapter_cur;
  	END IF;
	--Set the address validation status of batch summary table before submit the chaild CP
	update HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS  = 'PROCESSING'
	where batch_id = l_batch_id returning ORIGINAL_SYSTEM into l_orig_system;
	IF l_adapter_id.COUNT >0 THEN --Bug no:3365035.To overcome numeric or value error
	        l_adapter_found := TRUE; --Bug No: 3535366
		FOR  i in l_adapter_id.first..l_adapter_id.last LOOP  /*start of Adaptor loop */

			IF l_import_adapter_def = 'Y' then
				OPEN imp_addresss_cur(l_adapter_content_source(i));
			ELSE
				OPEN addresss_cur(l_adapter_id(i));
			END IF;

			LOOP	/* start of batch creation  loop */
			   IF l_import_adapter_def = 'Y' then
				FETCH imp_addresss_cur BULK COLLECT into l_row_id limit l_batch_size(i);
				IF imp_addresss_cur%NOTFOUND THEN
				l_last_fetch := TRUE;
				END IF;
				IF l_row_id.COUNT = 0 AND l_last_fetch THEN
					--CLOSE imp_addresss_cur; Bug No:3335211
				EXIT;
				END IF;
			   ELSE
				FETCH addresss_cur BULK COLLECT into l_row_id limit l_batch_size(i);
				IF addresss_cur%NOTFOUND THEN
				l_last_fetch := TRUE;
				END IF;
				IF l_row_id.COUNT = 0 AND l_last_fetch THEN
					--CLOSE addresss_cur; Bug No:3335211.
				EXIT;
				END IF;
			   END IF;

			   FORALL j IN l_row_id.FIRST..l_row_id.LAST
				update hz_imp_addresses_int
				set validation_subset_id = l_counter,
				    adapter_content_source = l_adapter_content_source(i)
				where rowid = l_row_id(j);
				commit;
				--l_request_id.extend(1);
					l_request_id := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHADDRC','',
							to_char(sysdate,'DD-MON-YY HH:MI:SS'), TRUE,l_batch_id,
							l_counter, null,'HZ_IMPORT',l_batch_id,
							l_default_replace_level(i),l_orig_system,l_adapter_id(i));
				IF l_request_id = 0 THEN
				--Error submitting request
				      update HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS = 'ERROR'
				      where batch_id = l_batch_id;
				      retcode :=2;
				      fnd_file.put_line(FND_FILE.LOG, 'Error submitting address_validation_child');
					  return;
				   --	l_error_count := l_error_count +1;
				ELSE
				    --Submitted request
				    if l_request_data is null then
					l_request_data := to_char(l_request_id)||' ' ;
				    else
					l_request_data := l_request_data ||to_char(l_request_id)||' ' ;
				    end if;
				    fnd_file.put_line(FND_FILE.LOG, 'address_validation_main: child request submitted with request_id:'||l_request_id);
				END IF;

				IF  l_last_fetch = TRUE THEN
				 EXIT;
				END IF;
				l_counter := l_counter+1;  /* No of current batch request submitted */
			   END LOOP;	/* end of batch creation  loop */
			   IF l_import_adapter_def = 'Y' then
				CLOSE imp_addresss_cur;
			   ELSE
				CLOSE addresss_cur;
			   END IF;
		END LOOP;  /*End of Adaptor loop */

	END IF;
	--Start for Default Adapter
	--IF l_import_adapter_def <> 'Y' then --Bug No:3347996. Commented the condition

	   -- default adapter
	   OPEN default_adapter;
	   FETCH default_adapter bulk collect into
       	         l_adapter_id,l_adapter_content_source,l_batch_size,l_default_replace_level;
     	   FND_FILE.put_line(fnd_file.log,'l_adapter_id count:'|| l_adapter_id.count);
           IF default_adapter%NOTFOUND THEN
        	l_adapter_last_fetch := TRUE;
    	   END IF;
    	   IF l_adapter_id.count = 0 AND l_adapter_last_fetch THEN
    	      FND_FILE.put_line(fnd_file.log,'No Valid Default Adapter found');
	      -----Bug No: 3535366----
	      IF NOT l_adapter_found THEN
	        update HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS  = 'ERROR'
		where batch_id = l_batch_id
		returning ORIGINAL_SYSTEM into l_orig_system;
		retcode := 2;
                FND_FILE.put_line(fnd_file.log,'Error: No adapters found to process the records, Aborting Address Validation Main for this batch');
		FND_FILE.put_line(fnd_file.log,'Please run the import program by turning Run Address validation to ''NO'' or define at least default adapter');
	      END IF;
             -----End of Bug No: 3535366----
    	   END IF;
    	   CLOSE  default_adapter;

	   IF l_adapter_id.count >0 then
       		l_last_fetch := FALSE;
       		l_counter := l_counter+1;
		FOR  i in l_adapter_id.first..l_adapter_id.last LOOP  /*start of Default Adaptor loop */
		 OPEN addresss_cur_default;
		 LOOP  /* loop for batch creation */
		    FETCH addresss_cur_default BULK COLLECT into l_row_id limit l_batch_size(i);
			IF addresss_cur_default%NOTFOUND THEN
			   l_last_fetch := TRUE;
			END IF;
			IF l_row_id.COUNT = 0 AND l_last_fetch THEN
			   fnd_file.put_line(FND_FILE.LOG, 'No records are found to process for Default Adapter in address_validation_child ');
			   --close addresss_cur_default;
			   EXIT;
			END IF;

			FORALL j IN l_row_id.FIRST..l_row_id.LAST
			    UPDATE hz_imp_addresses_int
			    SET validation_subset_id = l_counter,
				adapter_content_source = l_adapter_content_source(i)
			    WHERE rowid = l_row_id(j);
			    COMMIT;
			    --l_request_id.extend(1);
			    l_request_id := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHADDRC','',
						to_char(sysdate,'DD-MON-YY HH:MI:SS'), TRUE,l_batch_id,
						l_counter, null,'HZ_IMPORT',l_batch_id,
						l_default_replace_level(i),l_orig_system,l_adapter_id(i));
			    IF l_request_id = 0 THEN
				--Error submitting request
			      UPDATE HZ_IMP_BATCH_SUMMARY set ADDR_VAL_STATUS = 'ERROR'
			      WHERE batch_id = l_batch_id;
			      retcode :=2;
			      fnd_file.put_line(FND_FILE.LOG, 'Error submitting address_validation_child for Default Adapter');

			      RETURN;
				--	l_error_count := l_error_count +1;
			    ELSE
			       --Submitted request
				IF l_request_data is null then
					l_request_data := to_char(l_request_id)||' ' ;
				ELSE
					l_request_data := l_request_data ||to_char(l_request_id)||' ' ;
				END IF;
			        fnd_file.put_line(FND_FILE.LOG, 'address_validation_main: child request submitted for Default Adapter with request_id:'||l_request_id);
			    END IF;

	   	     IF  l_last_fetch = TRUE THEN
			EXIT;
		     END IF;
		     l_counter := l_counter+1;  /* No of current batch request submitted */
		 END LOOP;	/* end of batch creation  loop */
		 CLOSE addresss_cur_default; /* close default adpater cur */
		 -------------------------------------------------
		END LOOP; --end of Default Adapter Loop
           END IF;
      --END IF;   --Bug No:3347996
      --End for Default Adapter
     IF l_request_data IS NOT NULL THEN  -- Bug No:3359194
      FND_CONC_GLOBAL.SET_REQ_GLOBALS(
      conc_status  => 'PAUSED',
      request_data => l_request_data);
     END IF;

  END IF;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.put_line(fnd_file.log,'Others Error: Aborting Address Validation Main for this batch');
    FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    RAISE ;
END address_validation_main;

-----------------------------------------------------------------------
-- This function will be called by update_validated_address procedure,
-- to compare the threshold and validated status code.
--
------------------------------------------------------------------------
function compare_treshhold(p_value1 varchar2, p_value2 varchar2)
  	return varchar2 is
  begin
   if  p_value1 is not null and p_value2 is not null then
     if to_number(p_value2) >= to_number(p_value1) then
     	return 'Y';
     else
     	return 'N';
     end if;
   else
     return 'N';
   end if;
  exception
   	when others THEN
    	FND_FILE.put_line(fnd_file.log,'compare_treshhold: Aborting processing inboundxml for this batch');
    	FND_FILE.put_line(fnd_file.log,'compare_treshhold: p_value1,p_value2:-'||p_value1||'-'||p_value2);
    	FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    	RAISE FND_API.G_EXC_ERROR;
  end;

-----------------------------------------------------------------------
-- This procedure will be called by xml gateway through mapcode,
-- as a procedure call.
--
------------------------------------------------------------------------
Procedure  update_validated_address(
  p_SITE_ORIG_SYSTEM_REFERENCE  in	VARCHAR2 ,
  p_SITE_ORIG_SYSTEM	 		in	VARCHAR2 ,
  p_batch_id	 				in NUMBER,
  p_Address1	 				in VARCHAR2 DEFAULT NULL,
  p_Address2	 				in VARCHAR2 DEFAULT NULL,
  p_Address3	 				in VARCHAR2 DEFAULT NULL,
  p_Address4	 				in VARCHAR2 DEFAULT NULL,
  p_city	 	 				in VARCHAR2 DEFAULT NULL,
  p_county	 	 				in VARCHAR2 DEFAULT NULL,
  p_CountrySubEntity 			in VARCHAR2 DEFAULT NULL,
  p_country	 	 				in VARCHAR2 DEFAULT NULL,
  p_postal_code	 				in VARCHAR2 DEFAULT NULL,
  p_status		 				in VARCHAR2 DEFAULT NULL,
  P_OVERWRITE_THRESHOLD 		in VARCHAR2 DEFAULT NULL )is

begin

 UPDATE HZ_IMP_ADDRESSES_INT SET
 	Address1_std = p_Address1,
 	Address2_std = p_Address2,
	Address3_std = p_Address3,
	Address4_std = p_Address4,
	city_std   	 = p_city,
	county_std   = p_county,
	PROV_STATE_ADMIN_CODE_STD = p_CountrySubEntity,
	country_std  = nvl(upper(p_country), upper(country)),
	postal_code_std = p_postal_code,
	ACCEPT_STANDARDIZED_FLAG = compare_treshhold(p_status,P_OVERWRITE_THRESHOLD),
	DATE_VALIDATED = trunc(sysdate),
	ADDR_VALID_STATUS_CODE = p_status
 WHERE SITE_ORIG_SYSTEM_REFERENCE = P_SITE_ORIG_SYSTEM_REFERENCE
   AND SITE_ORIG_SYSTEM = P_SITE_ORIG_SYSTEM
   AND BATCH_ID = p_batch_id;

exception
  WHEN NO_DATA_FOUND THEN
        FND_FILE.put_line(fnd_file.log,'Can not find record for update HZ_IMP_ADDRESSES_INT: ');
        FND_FILE.put_line(fnd_file.log,'Batch_Id,:'||p_batch_id);
        FND_FILE.put_line(fnd_file.log,'SITE_ORIG_SYSTEM,:'||P_SITE_ORIG_SYSTEM);
        FND_FILE.put_line(fnd_file.log,'SITE_ORIG_SYSTEM_REFERENCE:'||P_SITE_ORIG_SYSTEM_REFERENCE);
        RAISE FND_API.G_EXC_ERROR;
  WHEN others THEN
    	FND_FILE.put_line(fnd_file.log,'update_validated_address: Aborting processing inboundxml for this batch');
    	FND_FILE.put_line(fnd_file.log,'Batch_Id,:'||p_batch_id);
    	FND_FILE.put_line(fnd_file.log,'SITE_ORIG_SYSTEM,:'||P_SITE_ORIG_SYSTEM);
    	FND_FILE.put_line(fnd_file.log,'SITE_ORIG_SYSTEM_REFERENCE:'||P_SITE_ORIG_SYSTEM_REFERENCE);
    	FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    	RAISE FND_API.G_EXC_ERROR;
end;

-----------------------------------------------------------------------
-- Folowing Rule Function will be called from event subscription,
--'oracle.apps.ar.hz.import.inboundxml' which is raised by
-- another rule function outboundxml_rule.
--
-- This function rule will process the inbound xml doc and update
-- the hz_imp_addresses_int table with validated address components.
------------------------------------------------------------------------
FUNCTION inboundxml_rule (
  p_subscription_guid   IN RAW,
  p_event               IN OUT NOCOPY wf_event_t )
RETURN VARCHAR2 IS
  l_event_data          CLOB := NULL;
  l_ecx_map_code        VARCHAR2(30);
  l_adapter_id          NUMBER;
  l_overwrite_threshold VARCHAR2(30);
  l_batch_sequence      NUMBER;
  l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
BEGIN
  FND_FILE.put_line(fnd_file.log,'inboundxml_rule called');
   l_event_data := p_event.getEventData;
  IF(l_event_data IS NOT NULL) THEN
    l_ecx_map_code := p_event.getValueForParameter('ECX_MAP_CODE');
    FND_FILE.put_line(fnd_file.log,'ECX Map Code: '||l_ecx_map_code);

    ecx_standard.processXMLCover(
      		i_map_code    =>l_ecx_map_code,
      		i_inpayload   =>l_event_data,
      		i_debug_level =>3);
	commit;
  END IF;
  RETURN 'SUCCESS';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_FILE.put_line(fnd_file.log,'Expected Error: Aborting processing inboundxml for this batch');
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_ERROR; --Bug No: 3778263

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_FILE.put_line(fnd_file.log,'Unexpected Error: Aborting processing inboundxml for this batch');
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR; --Bug No: 3778263
  WHEN OTHERS THEN
    FND_FILE.put_line(fnd_file.log,'Others Error: Aborting processing inboundxml for this batch');
    FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE; --Bug No: 3778263
END inboundxml_rule;

-----------------------------------------------------------------------
-- Folowing Rule Function will be called from event subscription,
--'oracle.apps.ar.hz.import.outboundxml' which is raised by
-- address_validation_child Concurrent Program.
--
-- This function rule will do the following
-- 1) Get the generated xml doc by ecx_standard.generate
-- 2) Pass the xml doc to HZ_LOCATION_SERVICES_PUB.submit_addrval_doc
-- 3) Get returned validated xml doc, raise another wf event to parse
--    the validated addresses.
------------------------------------------------------------------------
function outboundxml_rule(
                        p_subscription_guid in	   raw,
                        p_event		   in out nocopy wf_event_t
                      ) return varchar2
is
  transaction_type     	varchar2(240);
  transaction_subtype   varchar2(240);
  party_id	        	varchar2(240);
  party_site_id	      	varchar2(240);
  party_type            varchar2(200); --Bug #2183619
  document_number       varchar2(240);
  resultout             boolean;
  retcode				pls_integer;
  errmsg				varchar2(2000);
  debug_level           varchar2(2000);
  i_debug_level         pls_integer;
  parameterList         varchar2(200);
  ecx_exception_type    varchar2(200) := null;
  l_event_data			nclob;
  l_event_data1			clob;
  l_batch_id			NUMBER;
  l_adapter_log_id      NUMBER;
  l_adapter_id			NUMBER;
  l_subset_id			NUMBER;
  l_return_status   	VARCHAR2(30);
  l_msg_count       	NUMBER;
  l_msg_data        	VARCHAR2(2000);
  l_orig_system			varchar2(30);
  --l_xml1				clob;
  l_event_key			varchar2(30);
  l_parameter_list     wf_parameter_list_t := wf_parameter_list_t();

begin

  l_event_data := to_nclob(p_event.getEventData);
  --l_event_data1 := p_event.getEventData;
  l_batch_id   :=  p_event.getValueForParameter('P_BATCH_ID');
  l_orig_system :=  p_event.getValueForParameter('P_ORIG_SYSTEM_REFERENCE');
  l_subset_id  :=  p_event.getValueForParameter('P_VAL_SUBSET_ID');
  l_adapter_id :=  p_event.getValueForParameter('P_ADAPTER_ID');
   --
   ---Call address validation service API
   --
  FND_FILE.put_line(fnd_file.log,'calling HZ_LOCATION_SERVICES_PUB.submit_addrval_doc procedure ');
  FND_FILE.put_line(fnd_file.log,'BATCH_ID: '||l_batch_id);
  FND_FILE.put_line(fnd_file.log,'ADAPTER ID: '||l_adapter_id);
  FND_FILE.put_line(fnd_file.log,'ORIG_SYSTEM: '||l_orig_system);
  FND_FILE.put_line(fnd_file.log,'SUBSET ID '||l_subset_id);
   HZ_LOCATION_SERVICES_PUB.submit_addrval_doc(
		  p_addrval_doc  	   		=> l_event_data,
		  p_adapter_id			 	=> l_adapter_id,
		  p_country_code    		=> null,
		  p_module         			=> 'HZ_IMPORT',
		  p_module_id       		=> l_batch_id,
		  x_return_status   		=> l_return_status,
		  x_msg_count       		=> l_msg_count,
		  x_msg_data        		=> l_msg_data );


  IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   wf_event.AddParameterToList(
      p_name => 'ECX_MAP_CODE',
      p_value => 'TCA_IMP_OAG_INBOUND',
      p_parameterlist => l_parameter_list);

   l_event_key := 'HZ_IMP_IN'||l_batch_id||'-'||l_subset_id||'-'||to_char(sysdate,'HH:MI:SS');
  --
  --- Raise the event for inboundxml
  --
  FND_FILE.put_line(fnd_file.log,'outboundxml_rule: raising inboundxml event');
  wf_event.raise(
      p_event_name      => 'oracle.apps.ar.hz.import.inboundxml',
      p_event_key       => l_event_key,
      p_event_data	    => to_clob(l_event_data),
      --p_event_data	    => l_event_data1,
      p_parameters      => l_parameter_list,
      p_send_date       => null);

	  l_parameter_list.DELETE;

  RETURN 'SUCCESS';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_FILE.put_line(fnd_file.log,'Expected Error: Aborting outboundxml process for this batch');
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_ERROR; --Bug No: 3778263

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_FILE.put_line(fnd_file.log,'Unexpected Error: Aborting outboundxml process for this batch');
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR; --Bug No: 3778263
  WHEN OTHERS THEN
    FND_FILE.put_line(fnd_file.log,'Others Error: Aborting outboundxml process for this batch');
    FND_FILE.put_line(fnd_file.log,'SQL Error: '||SQLERRM);
    Wf_Core.Context('ECX_RULE', 'OUTBOUNDXML', p_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE; --Bug No: 3778263
END outboundxml_rule;

end HZ_IMP_ADDRESS_VAL_PKG;

/
