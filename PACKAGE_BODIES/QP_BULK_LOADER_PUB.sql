--------------------------------------------------------
--  DDL for Package Body QP_BULK_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_LOADER_PUB" AS
/* $Header: QPXVBLKB.pls 120.24.12010000.12 2009/12/31 08:52:02 dnema ship $ */

FUNCTION GET_NULL_DATE RETURN DATE IS
BEGIN
   RETURN G_NULL_DATE;
END;

FUNCTION GET_NULL_CHAR RETURN VARCHAR2 IS
BEGIN
   RETURN G_NULL_CHAR;
END;

FUNCTION GET_NULL_NUMBER RETURN NUMBER IS
BEGIN
   RETURN G_NULL_NUMBER;
END;

PROCEDURE LOAD_PRICING_DATA
(
  err_buff     OUT NOCOPY  VARCHAR2
 ,retcode      OUT NOCOPY  NUMBER
 ,p_entity                 VARCHAR2
 ,p_entity_name		   VARCHAR2
 ,p_process_id	           NUMBER
 ,p_process_type           VARCHAR2
 ,p_process_parent	   VARCHAR2
 ,p_no_of_threads	   NUMBER   DEFAULT 1
 ,p_spawned_request	   VARCHAR2
 ,p_request_id  NUMBER   DEFAULT NULL
 ,p_debug_on		   VARCHAR2
 ,p_enable_dup_ln_check		   VARCHAR2
)
IS
   BEGIN

--added for moac
--Initialize MOAC and set org context to Multiple

  IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
--    MO_GLOBAL.set_policy_context('M', null);--commented as MO_GLOBAL.Init will set_policy_context  to 'M' or 'S' based on profile settings
  END IF;--MO_GLOBAL


   -- ENH duplicate line check flag RAVI
   G_QP_ENABLE_DUP_LINE_CHECK  :=p_enable_dup_ln_check;
   write_log('Duplicate Line Check: '||p_enable_dup_ln_check);

   G_QP_DEBUG := p_debug_on;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debug On: '||G_QP_DEBUG);
   FND_PROFILE.GET('QP_BATCH_SIZE_FOR_BULK_UPLOAD',g_qp_batch_size);
   if g_qp_batch_size is NULL or g_qp_batch_size < 1 then
	g_qp_batch_size := 1000;
   end if;
   write_log('Batch Size: '||to_char(g_qp_batch_size));

   IF p_entity = 'PRL' THEN

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'------Processing Price List Entity--------');

      load_lists
      ( err_buff=>err_buff
	,retcode=>retcode
	,p_entity_name=>p_entity_name
	,p_process_id=>p_process_id
	,p_process_type=>p_process_type
	,p_process_parent=>p_process_parent
	,p_no_of_threads=>p_no_of_threads
	,p_spawned_request=>p_spawned_request
	,p_request_id =>p_request_id);
   ELSE
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Only Price List Entity processing allowed');
   END IF;

END LOAD_PRICING_DATA;


PROCEDURE LOAD_LISTS
 (
        err_buff           OUT NOCOPY   VARCHAR2
	,retcode           OUT NOCOPY   NUMBER
	,p_entity_name                  VARCHAR2
	,p_process_id                   NUMBER
	,p_process_type                 VARCHAR2
	,p_process_parent               VARCHAR2
	,p_no_of_threads                NUMBER
	,p_spawned_request              VARCHAR2
	,p_request_id                   NUMBER   )
IS

     l_rows NATURAL;
     l_request_id NUMBER;
     l_no_of_lines NUMBER:=0;
     l_batch_size NUMBER:=0;
     l_mod NUMBER:=0;
     l_req_data VARCHAR2(10);
     l_req_data_counter NUMBER;
     l_new_request_id NUMBER;
     l_no_of_threads NUMBER;
     l_retcode NUMBER;
     l_err_buff VARCHAR2(240);
     l_min_hdr_id NUMBER;
     l_max_hdr_id NUMBER;
     l_min_list_line_id NUMBER;
     l_max_list_line_id NUMBER;
     l_list_header_id NUMBER;
     l_process_parent VARCHAR2(50);
     l_count NUMBER;
     l_source_system_code VARCHAR2(30);
     l_pte_code VARCHAR2(30);

     l_suc_line NUMBER;
     l_err_line NUMBER;
     l_suc_pr_attr NUMBER;
     l_err_pr_attr NUMBER;

    l_start_time number;
    l_end_time number;

    --Bug#3604426 RAVI
    l_msg_txt VARCHAR2(2000);

    --ENH Update Functionality RAVI
    /**
    local variables for holding the number of headers and header qualifeirs
    to be processed.
    **/
    l_header_count NUMBER:=0;
    l_qualifier_count NUMBER:=0;

     BEGIN

     l_no_of_threads :=p_no_of_threads;
     l_process_parent := p_process_parent;
   /*-----------------------------------------------------------
                   HEADER PROCESSING
   -------------------------------------------------------------*/

      IF p_spawned_request = 'N' or p_spawned_request IS NULL
      THEN

	 FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);
	 write_log('Parent Request Id: '||l_request_id);

         IF p_no_of_threads IS NULL THEN
	    l_no_of_threads := 1;
	 END IF;

	 IF p_process_parent IS NULL THEN
	    l_process_parent := 'Y';
	 END IF;

	 l_req_data := fnd_conc_global.request_data;

	 IF ( l_req_data IS NOT NULL)
	 THEN
	    write_log( 'Second call');

	  select hsecs into l_start_time from v$timer;
          write_log( 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

	 l_req_data_counter:=to_number(l_req_data) + 1;

	   select min(list_header_id), max(list_header_id)
	     into l_min_hdr_id, l_max_hdr_id
	     from qp_list_headers_b
	    where request_id = l_request_id;

         write_log( 'LOW HEADER ID: '||l_min_hdr_id);
         write_log( 'HIGH HEADER ID: '||l_max_hdr_id);

	 IF l_min_hdr_id IS NOT NULL  AND l_max_hdr_id IS NOT NULL THEN

	    --Changes for bug 8359554 start
	    /*
	     QP_Maintain_Denormalized_Data.Update_Qualifiers
		(err_buff => l_err_buff,
		 retcode => l_retcode,
		 p_List_Header_Id => l_min_hdr_id,
		 p_List_Header_Id_high => l_max_hdr_id,
		 p_update_type => 'QUAL_IND'
		 );
             */

          /* For each child request call Denormalize program to update
	     Qualification Indicator but only for those lines which
	     have beem updated or inserted for the request */

          FOR child_req_rec IN (SELECT request_id
                         FROM FND_CONCURRENT_REQUESTS
                         WHERE parent_request_id = l_request_id)
          LOOP

             QP_Maintain_Denormalized_Data.Update_Qualifiers
		(err_buff => l_err_buff,
		 retcode => l_retcode,
		 p_List_Header_Id => l_min_hdr_id,
		 p_List_Header_Id_high => l_max_hdr_id,
		 p_update_type => 'QUAL_IND',
		 p_request_id => child_req_rec.request_id
		 );
	   -- BEGIN 8418006
           --END LOOP;

           -- Changes for bug 8359554 end

	    Begin
	     update qp_pte_segments
	     set used_in_setup='Y'
	     where nvl(used_in_setup,'N')='N'
	     and segment_id in
		(select a.segment_id
		from qp_segments_b a, qp_prc_contexts_b b, qp_qualifiers c, qp_list_headers_b h
		where h.list_header_id  BETWEEN  l_min_hdr_id  and l_max_hdr_id
		and  h.active_flag = 'Y'
		and   c.REQUEST_ID             = child_req_rec.request_id    --8418006
		and   c.list_header_id = h.list_header_id
		and   a.segment_mapping_column = c.qualifier_attribute
		and   a.prc_context_id         = b.prc_context_id
		and   b.prc_context_type       = 'QUALIFIER'
		and   b.prc_context_code       = c.qualifier_context);

	     update qp_pte_segments
	     set used_in_setup='Y'
	     where nvl(used_in_setup,'N')='N'
		and segment_id in
		(select  a.segment_id
		from qp_segments_b a, qp_prc_contexts_b b, qp_pricing_attributes c, qp_list_headers_b h
		where h.list_header_id BETWEEN  l_min_hdr_id  and l_max_hdr_id
		and    h.active_flag = 'Y'
		and   c.REQUEST_ID             = child_req_rec.request_id    --8418006
		and   c.list_header_id         = h.list_header_id
		and   a.segment_mapping_column = c.pricing_attribute
		and   a.prc_context_id         = b.prc_context_id
		and   b.prc_context_type       = 'PRICING_ATTRIBUTE'
		and   b.prc_context_code       = c.pricing_attribute_context);

	     update qp_pte_segments
	     set used_in_setup='Y'
	     where nvl(used_in_setup,'N')='N'
		and segment_id in
		(select  a.segment_id
		from qp_segments_b a, qp_prc_contexts_b b, qp_pricing_attributes c, qp_list_headers_b h
		where h.list_header_id BETWEEN  l_min_hdr_id  and l_max_hdr_id
		and    h.active_flag = 'Y'
		and   c.REQUEST_ID             = child_req_rec.request_id    --8418006
		and   c.list_header_id         = h.list_header_id
		and   a.segment_mapping_column = c.product_attribute
		and   a.prc_context_id         = b.prc_context_id
		and   b.prc_context_type       = 'PRODUCT'
		and   b.prc_context_code       = c.product_attribute_context);
	     Exception
		when others then
			null;
	     End;
          END LOOP; -- end child_req_rec
	  -- END 8418006


	   IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	     for l_list_header_id in l_min_hdr_id..l_max_hdr_id
	     loop
		begin
		    select min(list_line_id), max(list_line_id)
		    into   l_min_list_line_id, l_max_list_line_id
		    from   qp_list_lines
		    where  list_header_id = l_list_header_id;

		  QP_ATTR_GRP_PVT.Update_Qual_Segment_id(l_list_header_id,
							    null,
							    -1,
							    -1);
		  QP_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_list_header_id,
						    l_min_list_line_id,l_max_list_line_id);
		  QP_ATTR_GRP_PVT.generate_hp_atgrps(l_list_header_id,null);
		  QP_ATTR_GRP_PVT.update_pp_lines(l_list_header_id,
						    l_min_list_line_id,l_max_list_line_id);
		exception
			when others then
				null;
		end;
	     end loop;
	    END IF;
	    --uncommenting below to include pattern changes and changes related to bug 8737735
	    --- jagan PL/SQL pattern engine
            IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
               IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' THEN
		     for l_list_header_id in l_min_hdr_id..l_max_hdr_id
		     loop
			begin
			    select min(list_line_id), max(list_line_id)
			    into   l_min_list_line_id, l_max_list_line_id
			    from   qp_list_lines
			    where  list_header_id = l_list_header_id;

			  QP_PS_ATTR_GRP_PVT.Update_Qual_Segment_id(l_list_header_id,
							    null,
							    -1,
							    -1);
			  QP_PS_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_list_header_id,
						    l_min_list_line_id,l_max_list_line_id);
			  QP_PS_ATTR_GRP_PVT.generate_hp_atgrps(l_list_header_id,null);
			  QP_PS_ATTR_GRP_PVT.update_pp_lines(l_list_header_id,
						    l_min_list_line_id,l_max_list_line_id);
			exception
				when others then
					null;
			end;
		     end loop;

	        END IF;
	      END IF;
	 END IF;

         IF l_retcode <> 0 THEN
	    retcode := 2;
	    write_log( 'Error in procedure QP_Maintain_Denormalized_Data.Update_Qualifiers');
         END IF;

	 --clean up code
	 CLEAN_UP_CODE(l_request_id);

	select hsecs into l_end_time from v$timer;
	write_log( 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time taken for the header process 2 (sec):' ||(l_end_time - l_start_time)/100);
	 Return;
      ELSE -- ( l_req_data IS NULL)
	 write_log( 'First Call');
	 l_req_data_counter:=1;

      END IF; -- ( l_req_data IS NOT NULL)

  ----   Header Started

	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-----------Bulk Pricelist Data Loader---------');
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Paremeters');
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Entity Name: '||p_entity_name);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Process Id: '||p_process_id);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Process Type:'||p_process_type);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Process Parent: '||p_process_parent);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Number Of Threads: '||p_no_of_threads);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '------------------------------');

     select hsecs into l_start_time from v$timer;
     write_log( 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

       FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
       FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);

       write_log('Source system code (Profile) :'||l_source_system_code);
       write_log('PTE_Code (Profile) :'||l_pte_code);

	 IF p_entity_name IS NOT NULL
         THEN

            -- Bug#3604226 RAVI START
            -- Orig_Sys_Hdr_ref has to be unique for insertion
            fnd_message.set_name('QP', 'QP_HDR_REF_NOT_UNIQUE');
            l_msg_txt := FND_MESSAGE.GET;

            INSERT INTO QP_INTERFACE_ERRORS
             (error_id,last_update_date, last_updated_by, creation_date,
              created_by, last_update_login, request_id, program_application_id,
              program_id, program_update_date, entity_type, table_name, column_name,
              orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
              orig_sys_pricing_attr_ref,  error_message)
              SELECT
               qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
               FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, l_request_id, 661,
               NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'ORIG_SYS_HEADER_REF',
               qpih.orig_sys_header_ref,null,null,null,l_msg_txt
              FROM QP_INTERFACE_LIST_HEADERS qpih
              WHERE qpih.name = p_entity_name
                AND qpih.process_status_flag ='P' --is null
                AND qpih.interface_action_code ='INSERT'
                AND EXISTS(
                      select 1 from qp_list_headers_b qplh
                      where qplh.orig_system_header_ref=qpih.orig_sys_header_ref
                      );
            IF SQL%ROWCOUNT > 0 THEN
              Write_Log('ERROR: Hdr_Ref not Unique');
            END IF;
            -- Bug#3604226 RAVI END


            -- Bug 4958784 RAVI
            /**
            Load only if header with same orig_sys_hdr_ref is non existent
            in qp tables for INSERT action
            **/
	    UPDATE qp_interface_list_headers qpih
            SET    qpih.request_id = l_request_id, qpih.process_status_flag = 'P'
	    WHERE  qpih.name = p_entity_name
	    AND    (qpih.source_system_code IS NULL
		or (qpih.source_system_code = nvl(l_source_system_code, qpih.source_system_code)))
	    AND    (qpih.pte_code IS NULL or (qpih.pte_code = nvl(l_pte_code, qpih.pte_code)))
	    AND    nvl(qpih.list_source_code, '*') <> 'BSO'
	    AND    nvl(qpih.process_id,0) = nvl(p_process_id, nvl(qpih.process_id,0))
            AND    qpih.list_type_code = 'PRL'
	    AND    qpih.process_flag = 'Y'
	    AND    nvl(qpih.process_type,' ') = nvl(p_process_type, nvl(qpih.process_type,' '))
	    AND    qpih.interface_action_code IN ('INSERT','UPDATE','DELETE')
            -- Bug 5208480(5208112,4188784) RAVI
            -- Should not be able to update list type code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qplh.list_type_code <> qpih.list_type_code
            )
            -- Should not be able to update list header id
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.list_header_id is not null
               and qplh.list_header_id <> qpih.list_header_id
            )
            -- Should not be able to update rounding factor
            --Bug#5208112 RAVI
            --Validation shifted to QP_BULK_VALIDATE package.
            /**
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.rounding_factor is not null
               and qplh.rounding_factor <> qpih.rounding_factor
            )
            **/
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.list_source_code is not null
               and qplh.list_source_code <> qpih.list_source_code
            )
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.source_system_code is not null
               and qplh.source_system_code <> qpih.source_system_code
            )
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.source_system_code is not null
               and qplh.source_system_code <> qpih.source_system_code
            )
            AND NOT EXISTS(
              select 1 from qp_list_headers qplh
              where qpih.interface_action_code = 'INSERT'
            -- ENH undo alcoa changes RAVI
            /**
            The key between interface and qp tables is only orig_sys_hdr_ref
            (not list_header_id)
            **/
              and qplh.orig_system_header_ref=qpih.orig_sys_header_ref);

          --ENH Update Functionality RAVI
          /**
          The number of interface headers loaded for processing
          (insert,update,delete)
          **/
	  l_header_count:=SQL%ROWCOUNT;

          --ENH Update Functionality RAVI
          /**
          If interface action is update then load all null value interface columns
          with values from corresponding qp table columns
          **/
          UPDATE qp_interface_list_headers qpih
          SET ( creation_date,
	      created_by,
              program_application_id,
              program_id,
              program_update_date,
              list_type_code,
              start_date_active,
              end_date_active,
              source_lang,
              automatic_flag,
              name,
              description,
              currency_code,
              version_no,
              rounding_factor,
              ship_method_code,
              freight_terms_code,
              terms_id,
              comments,
              discount_lines_flag,
              gsa_indicator,
              prorate_flag,
              source_system_code,
              ask_for_flag,
              active_flag,
              parent_list_header_id,
              active_date_first_type,
              start_date_active_first,
              end_date_active_first,
              active_date_second_type,
              start_date_active_second,
              end_date_active_second,
              context,
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
              language,
              mobile_download,
              currency_header_id,
              orig_sys_header_ref,
              orig_org_id,
              global_flag
             ) = ( select
             		decode(qpih.creation_date, null, qplh.creation_date,
                              decode(qpih.creation_date,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.creation_date
                                     )
                              ),
                        decode(qpih.created_by, null, qplh.created_by,
                              decode(qpih.created_by,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.created_by
                                     )
                              ),
                        decode(qpih.program_application_id, null, qplh.program_application_id,
                              decode(qpih.program_application_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.program_application_id
                                     )
                              ),
                        decode(qpih.program_id, null, qplh.program_id,
                              decode(qpih.program_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.program_id
                                     )
                              ),
                        decode(qpih.program_update_date, null, qplh.program_update_date,
                              decode(qpih.program_update_date,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.program_update_date
                                     )
                              ),
                        decode(qpih.list_type_code, null, qplh.list_type_code,
                              decode(qpih.list_type_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.list_type_code
                                     )
                              ),
       			--Bug# 5228368 RAVI
                        decode(qpih.start_date_active, null, to_char(qplh.start_date_active,'YYYY/MM/DD'),
                              decode(qpih.start_date_active,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.start_date_active
                                     )
                              ),
       			--Bug# 5228368 RAVI
                        decode(qpih.end_date_active, null, to_char(qplh.end_date_active,'YYYY/MM/DD'),
                              decode(qpih.end_date_active,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.end_date_active
                                     )
                              ),
                        decode(qpih.source_lang, null, userenv('lang'),
                              decode(qpih.source_lang,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.source_lang
                                     )
                              ),
                        decode(qpih.automatic_flag, null, qplh.automatic_flag,
                              decode(qpih.automatic_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.automatic_flag
                                     )
                              ),
                        decode(qpih.name, null, qplh.name,
                              decode(qpih.name,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.name
                                     )
                              ),
                        decode(qpih.description, null, qplh.description,
                              decode(qpih.description,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.description
                                     )
                              ),
                        decode(qpih.currency_code, null, qplh.currency_code,
                              decode(qpih.currency_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.currency_code
                                     )
                              ),
                        decode(qpih.version_no, null, qplh.version_no,
                              decode(qpih.version_no,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.version_no
                                     )
                              ),
                        decode(qpih.rounding_factor, null, qplh.rounding_factor,
                              decode(qpih.rounding_factor,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.rounding_factor
                                     )
                              ),
                        --Bug# 5412029 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpih.ship_method,
                               null,
                               decode(qpih.ship_method_code, null, qplh.ship_method_code,
                                      decode(qpih.ship_method_code,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpih.ship_method_code
                                             )
                                     ),
                               decode(qpih.ship_method_code, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpih.ship_method_code
                                     )
                              ),
                        decode(qpih.freight_terms,
                               null,
                               decode(qpih.freight_terms_code, null, qplh.freight_terms_code,
                                      decode(qpih.freight_terms_code,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpih.freight_terms_code
                                             )
                                     ),
                               decode(qpih.freight_terms_code, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpih.freight_terms_code
                                     )
                              ),
                        decode(qpih.terms,
                               null,
                               decode(qpih.terms_id, null, qplh.terms_id,
                                      decode(qpih.terms_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpih.terms_id
                                             )
                                     ),
                               decode(qpih.terms_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpih.terms_id
                                     )
                              ),
                        --Bug# 5412029 RAVI END
                        decode(qpih.comments, null, qplh.comments,
                              decode(qpih.comments,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.comments
                                     )
                              ),
                        decode(qpih.discount_lines_flag, null, qplh.discount_lines_flag,
                              decode(qpih.discount_lines_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.discount_lines_flag
                                     )
                              ),
                        decode(qpih.gsa_indicator, null, qplh.gsa_indicator,
                              decode(qpih.gsa_indicator,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.gsa_indicator
                                     )
                              ),
                        decode(qpih.prorate_flag, null, qplh.prorate_flag,
                              decode(qpih.prorate_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.prorate_flag
                                     )
                              ),
                        decode(qpih.source_system_code, null, qplh.source_system_code,
                              decode(qpih.source_system_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.source_system_code
                                     )
                              ),
                        decode(qpih.ask_for_flag, null, qplh.ask_for_flag,
                              decode(qpih.ask_for_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.ask_for_flag
                                     )
                              ),
                        decode(qpih.active_flag, null, qplh.active_flag,
                              decode(qpih.active_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_flag
                                     )
                              ),
                        decode(qpih.parent_list_header_id, null, qplh.parent_list_header_id,
                              decode(qpih.parent_list_header_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.parent_list_header_id
                                     )
                              ),
                        decode(qpih.active_date_first_type, null, qplh.active_date_first_type,
                              decode(qpih.active_date_first_type,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_date_first_type
                                     )
                              ),
                        decode(qpih.start_date_active_first, null, qplh.start_date_active_first,
                              decode(qpih.start_date_active_first,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.start_date_active_first
                                     )
                              ),
                        decode(qpih.end_date_active_first, null, qplh.end_date_active_first,
                              decode(qpih.end_date_active_first,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.end_date_active_first
                                     )
                              ),
                        decode(qpih.active_date_second_type, null, qplh.active_date_second_type,
                              decode(qpih.active_date_second_type,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_date_second_type
                                    )
                              ),
                        decode(qpih.start_date_active_second, null, qplh.start_date_active_second,
                              decode(qpih.start_date_active_second,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.start_date_active_second
                                     )
                              ),
                        decode(qpih.end_date_active_second, null, qplh.end_date_active_second,
                              decode(qpih.end_date_active_second,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.end_date_active_second
                                     )
                              ),
                        decode(qpih.context, null, qplh.context,
                              decode(qpih.context,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.context
                                     )
                              ),
                        decode(qpih.attribute1, null, qplh.attribute1,
                              decode(qpih.attribute1,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute1
                                     )
                              ),
                        decode(qpih.attribute2, null, qplh.attribute2,
                              decode(qpih.attribute2,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute2
                                     )
                              ),
                        decode(qpih.attribute3, null, qplh.attribute3,
                              decode(qpih.attribute3,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute3
                                     )
                              ),
                        decode(qpih.attribute4, null, qplh.attribute4,
                              decode(qpih.attribute4,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute4
                                     )
                              ),
                        decode(qpih.attribute5, null, qplh.attribute5,
                              decode(qpih.attribute5,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute5
                                     )
                              ),
                        decode(qpih.attribute6, null, qplh.attribute6,
                              decode(qpih.attribute6,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute6
                                     )
                              ),
                        decode(qpih.attribute7, null, qplh.attribute7,
                              decode(qpih.attribute7,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute7
                                     )
                              ),
                        decode(qpih.attribute8, null, qplh.attribute8,
                              decode(qpih.attribute8,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute8
                                     )
                              ),
                        decode(qpih.attribute9, null, qplh.attribute9,
                              decode(qpih.attribute9,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute9
                                     )
                              ),
                        decode(qpih.attribute10, null, qplh.attribute10,
                              decode(qpih.attribute10,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute10
                                     )
                              ),
                        decode(qpih.attribute11, null, qplh.attribute11,
                              decode(qpih.attribute11,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute11
                                     )
                              ),
                        decode(qpih.attribute12, null, qplh.attribute12,
                              decode(qpih.attribute12,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute12
                                     )
                              ),
                        decode(qpih.attribute13, null, qplh.attribute13,
                              decode(qpih.attribute13,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute13
                                     )
                              ),
                        decode(qpih.attribute14, null, qplh.attribute14,
                              decode(qpih.attribute14,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute14
                                     )
                              ),
                        decode(qpih.attribute15, null, qplh.attribute15,
                              decode(qpih.attribute15,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute15
                                     )
                              ),
                        decode(qpih.language, null, userenv('lang'),
                              decode(qpih.language,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.language
                                     )
                              ),
                        decode(qpih.mobile_download, null, qplh.mobile_download,
                              decode(qpih.mobile_download,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.mobile_download
                                     )
                              ),
                        --Bug# 5412029 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpih.currency_header,
                               null,
                               decode(qpih.currency_header_id, null, qplh.currency_header_id,
                                      decode(qpih.currency_header_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpih.currency_header_id
                                             )
                                     ),
                               decode(qpih.currency_header_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpih.currency_header_id
                                     )
                              ),
                        --Bug# 5412029 RAVI END
                        decode(qpih.orig_sys_header_ref, null, qplh.orig_system_header_ref,
                              decode(qpih.orig_sys_header_ref,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.orig_sys_header_ref
                                     )
                              ),
                        decode(qpih.orig_org_id, null, qplh.orig_org_id,
                              decode(qpih.orig_org_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.orig_org_id
                                     )
                              ),
                        decode(qpih.global_flag, null, qplh.global_flag,
                              decode(qpih.global_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.global_flag
                                     )
                              )
                   from  qp_list_headers qplh
                   where qplh.orig_system_header_ref=qpih.orig_sys_header_ref
                  )
            where qpih.request_id = l_request_id
            and qpih.process_status_flag = 'P'
            and qpih.interface_action_code = 'UPDATE';

	 ELSE

            -- Bug#3604226 RAVI START
            -- Orig_Sys_Hdr_ref has to be unique for insertion

            fnd_message.set_name('QP', 'QP_HDR_REF_NOT_UNIQUE');
            l_msg_txt := FND_MESSAGE.GET;

            INSERT INTO QP_INTERFACE_ERRORS
             (error_id,last_update_date, last_updated_by, creation_date,
              created_by, last_update_login, request_id, program_application_id,
              program_id, program_update_date, entity_type, table_name, column_name,
              orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
              orig_sys_pricing_attr_ref,  error_message)
              SELECT
               qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
               FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, l_request_id, 661,
               NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  'ORIG_SYS_HEADER_REF',
               qpih.orig_sys_header_ref,null,null,null,l_msg_txt
              FROM QP_INTERFACE_LIST_HEADERS qpih
              WHERE nvl(qpih.process_type,' ') = nvl(p_process_type, nvl(qpih.process_type,' '))
                AND nvl(qpih.process_id,0) = nvl(p_process_id, nvl(qpih.process_id,0))
                AND qpih.process_status_flag ='P' --is null
                AND qpih.interface_action_code ='INSERT'
                AND EXISTS(
                      select 1 from qp_list_headers_b qplh
                      where qplh.orig_system_header_ref=qpih.orig_sys_header_ref
                      );
            IF SQL%ROWCOUNT > 0 THEN
              Write_Log('ERROR: Hdr_Ref not Unique');
            END IF;
            -- Bug#3604226 RAVI END

            -- Bug 4958784 RAVI
            /**
            Load only if header with same orig_sys_hdr_ref is non existent
            in qp tables for INSERT action
            **/
            write_log('Entity Name Is null');
	    UPDATE qp_interface_list_headers qpih
	    SET    qpih.request_id = l_request_id
	    WHERE  qpih.request_id is null
	    AND    (qpih.source_system_code IS NULL
		or (qpih.source_system_code = nvl(l_source_system_code, qpih.source_system_code)))
	    AND    (qpih.pte_code IS NULL or (qpih.pte_code = nvl(l_pte_code, qpih.pte_code)))
	    AND    nvl(qpih.list_source_code, '*') <> 'BSO'
            AND    process_status_flag = 'P'
            AND    nvl(qpih.process_id,0) = nvl(p_process_id, nvl(qpih.process_id,0))
            AND    qpih.list_type_code = 'PRL'
	    AND    decode(p_process_id, null,qpih.process_flag,'Y') = 'Y'
	    AND    nvl(qpih.process_type,' ') = nvl(p_process_type, nvl(qpih.process_type,' '))
	    AND    qpih.interface_action_code IN ('INSERT','UPDATE','DELETE')
            -- Bug 5208480(5208112,4188784) RAVI
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qplh.list_type_code <> qpih.list_type_code
            )
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.list_header_id is not null
               and qplh.list_header_id <> qpih.list_header_id
            )
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.rounding_factor is not null
               and qplh.rounding_factor <> qpih.rounding_factor
            )
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.list_source_code is not null
               and qplh.list_source_code <> qpih.list_source_code
            )
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.source_system_code is not null
               and qplh.source_system_code <> qpih.source_system_code
            )
            -- Bug# 5246745 RAVI
            -- Should not be able to update list source code
            AND NOT EXISTS(
               select 1 from qp_list_headers qplh
               where qpih.interface_action_code = 'UPDATE'
               and qplh.orig_system_header_ref=qpih.orig_sys_header_ref
               and qpih.source_system_code is not null
               and qplh.source_system_code <> qpih.source_system_code
            )
            AND NOT EXISTS(
            select 1 from qp_list_headers qplh
            where qpih.interface_action_code = 'INSERT'
            -- ENH undo alcoa changes RAVI
            /**
            The key between interface and qp tables is only orig_sys_hdr_ref
            (not list_header_id)
            **/
            and qplh.orig_system_header_ref=qpih.orig_sys_header_ref);

          --ENH Update Functionality RAVI
          /**
          The number of interface headers loaded for processing
          (insert,update,delete)
          **/
	  l_header_count:=SQL%ROWCOUNT;

          --ENH Update Functionality RAVI
          /**
          If interface action is update then load all null value interface columns
          with values from corresponding qp table columns
          **/
          UPDATE qp_interface_list_headers qpih
          SET ( creation_date,
	      created_by,
              program_application_id,
              program_id,
              program_update_date,
              list_type_code,
              start_date_active,
              end_date_active,
              source_lang,
              automatic_flag,
              name,
              description,
              currency_code,
              version_no,
              rounding_factor,
              ship_method_code,
              freight_terms_code,
              terms_id,
              comments,
              discount_lines_flag,
              gsa_indicator,
              prorate_flag,
              source_system_code,
              ask_for_flag,
              active_flag,
              parent_list_header_id,
              active_date_first_type,
              start_date_active_first,
              end_date_active_first,
              active_date_second_type,
              start_date_active_second,
              end_date_active_second,
              context,
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
              language,
              mobile_download,
              currency_header_id,
              orig_sys_header_ref,
              orig_org_id,
              global_flag
             ) = ( select
             		decode(qpih.creation_date, null, qplh.creation_date,
                              decode(qpih.creation_date,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.creation_date
                                     )
                              ),
                        decode(qpih.created_by, null, qplh.created_by,
                              decode(qpih.created_by,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.created_by
                                     )
                              ),
                        decode(qpih.program_application_id, null, qplh.program_application_id,
                              decode(qpih.program_application_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.program_application_id
                                     )
                              ),
                        decode(qpih.program_id, null, qplh.program_id,
                              decode(qpih.program_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.program_id
                                     )
                              ),
                        decode(qpih.program_update_date, null, qplh.program_update_date,
                              decode(qpih.program_update_date,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.program_update_date
                                     )
                              ),
                        decode(qpih.list_type_code, null, qplh.list_type_code,
                              decode(qpih.list_type_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.list_type_code
                                     )
                              ),
       			--Bug# 5228368 RAVI
                        decode(qpih.start_date_active, null, to_char(qplh.start_date_active,'YYYY/MM/DD'),
                              decode(qpih.start_date_active,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.start_date_active
                                     )
                              ),
       			--Bug# 5228368 RAVI
                        decode(qpih.end_date_active, null, to_char(qplh.end_date_active,'YYYY/MM/DD'),
                              decode(qpih.end_date_active,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.end_date_active
                                     )
                              ),
                        decode(qpih.source_lang, null, userenv('lang'),
                              decode(qpih.source_lang,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.source_lang
                                     )
                              ),
                        decode(qpih.automatic_flag, null, qplh.automatic_flag,
                              decode(qpih.automatic_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.automatic_flag
                                     )
                              ),
                        decode(qpih.name, null, qplh.name,
                              decode(qpih.name,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.name
                                     )
                              ),
                        decode(qpih.description, null, qplh.description,
                              decode(qpih.description,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.description
                                     )
                              ),
                        decode(qpih.currency_code, null, qplh.currency_code,
                              decode(qpih.currency_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.currency_code
                                     )
                              ),
                        decode(qpih.version_no, null, qplh.version_no,
                              decode(qpih.version_no,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.version_no
                                     )
                              ),
                        decode(qpih.rounding_factor, null, qplh.rounding_factor,
                              decode(qpih.rounding_factor,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.rounding_factor
                                     )
                              ),
                        --Bug# 5412029 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpih.ship_method,
                               null,
                               decode(qpih.ship_method_code, null, qplh.ship_method_code,
                                      decode(qpih.ship_method_code,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpih.ship_method_code
                                             )
                                     ),
                               decode(qpih.ship_method_code, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpih.ship_method_code
                                     )
                              ),
                        decode(qpih.freight_terms,
                               null,
                               decode(qpih.freight_terms_code, null, qplh.freight_terms_code,
                                      decode(qpih.freight_terms_code,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpih.freight_terms_code
                                             )
                                     ),
                               decode(qpih.freight_terms_code, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpih.freight_terms_code
                                     )
                              ),
                        decode(qpih.terms,
                               null,
                               decode(qpih.terms_id, null, qplh.terms_id,
                                      decode(qpih.terms_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpih.terms_id
                                             )
                                     ),
                               decode(qpih.terms_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpih.terms_id
                                     )
                              ),
                        --Bug# 5412029 RAVI END
                        decode(qpih.comments, null, qplh.comments,
                              decode(qpih.comments,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.comments
                                     )
                              ),
                        decode(qpih.discount_lines_flag, null, qplh.discount_lines_flag,
                              decode(qpih.discount_lines_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.discount_lines_flag
                                     )
                              ),
                        decode(qpih.gsa_indicator, null, qplh.gsa_indicator,
                              decode(qpih.gsa_indicator,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.gsa_indicator
                                     )
                              ),
                        decode(qpih.prorate_flag, null, qplh.prorate_flag,
                              decode(qpih.prorate_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.prorate_flag
                                     )
                              ),
                        decode(qpih.source_system_code, null, qplh.source_system_code,
                              decode(qpih.source_system_code,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.source_system_code
                                     )
                              ),
                        decode(qpih.ask_for_flag, null, qplh.ask_for_flag,
                              decode(qpih.ask_for_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.ask_for_flag
                                     )
                              ),
                        decode(qpih.active_flag, null, qplh.active_flag,
                              decode(qpih.active_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_flag
                                     )
                              ),
                        decode(qpih.parent_list_header_id, null, qplh.parent_list_header_id,
                              decode(qpih.parent_list_header_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.parent_list_header_id
                                     )
                              ),
                        decode(qpih.active_date_first_type, null, qplh.active_date_first_type,
                              decode(qpih.active_date_first_type,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_date_first_type
                                     )
                              ),
                        decode(qpih.start_date_active_first, null, qplh.start_date_active_first,
                              decode(qpih.start_date_active_first,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.start_date_active_first
                                     )
                              ),
                        decode(qpih.end_date_active_first, null, qplh.end_date_active_first,
                              decode(qpih.end_date_active_first,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.end_date_active_first
                                     )
                              ),
                        decode(qpih.active_date_second_type, null, qplh.active_date_second_type,
                              decode(qpih.active_date_second_type,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.active_date_second_type
                                    )
                              ),
                        decode(qpih.start_date_active_second, null, qplh.start_date_active_second,
                              decode(qpih.start_date_active_second,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.start_date_active_second
                                     )
                              ),
                        decode(qpih.end_date_active_second, null, qplh.end_date_active_second,
                              decode(qpih.end_date_active_second,
                                     QP_BULK_LOADER_PUB.G_NULL_DATE,
                                     null,
                                     qpih.end_date_active_second
                                     )
                              ),
                        decode(qpih.context, null, qplh.context,
                              decode(qpih.context,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.context
                                     )
                              ),
                        decode(qpih.attribute1, null, qplh.attribute1,
                              decode(qpih.attribute1,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute1
                                     )
                              ),
                        decode(qpih.attribute2, null, qplh.attribute2,
                              decode(qpih.attribute2,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute2
                                     )
                              ),
                        decode(qpih.attribute3, null, qplh.attribute3,
                              decode(qpih.attribute3,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute3
                                     )
                              ),
                        decode(qpih.attribute4, null, qplh.attribute4,
                              decode(qpih.attribute4,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute4
                                     )
                              ),
                        decode(qpih.attribute5, null, qplh.attribute5,
                              decode(qpih.attribute5,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute5
                                     )
                              ),
                        decode(qpih.attribute6, null, qplh.attribute6,
                              decode(qpih.attribute6,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute6
                                     )
                              ),
                        decode(qpih.attribute7, null, qplh.attribute7,
                              decode(qpih.attribute7,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute7
                                     )
                              ),
                        decode(qpih.attribute8, null, qplh.attribute8,
                              decode(qpih.attribute8,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute8
                                     )
                              ),
                        decode(qpih.attribute9, null, qplh.attribute9,
                              decode(qpih.attribute9,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute9
                                     )
                              ),
                        decode(qpih.attribute10, null, qplh.attribute10,
                              decode(qpih.attribute10,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute10
                                     )
                              ),
                        decode(qpih.attribute11, null, qplh.attribute11,
                              decode(qpih.attribute11,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute11
                                     )
                              ),
                        decode(qpih.attribute12, null, qplh.attribute12,
                              decode(qpih.attribute12,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute12
                                     )
                              ),
                        decode(qpih.attribute13, null, qplh.attribute13,
                              decode(qpih.attribute13,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute13
                                     )
                              ),
                        decode(qpih.attribute14, null, qplh.attribute14,
                              decode(qpih.attribute14,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute14
                                     )
                              ),
                        decode(qpih.attribute15, null, qplh.attribute15,
                              decode(qpih.attribute15,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.attribute15
                                     )
                              ),
                        decode(qpih.language, null, userenv('lang'),
                              decode(qpih.language,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.language
                                     )
                              ),
                        decode(qpih.mobile_download, null, qplh.mobile_download,
                              decode(qpih.mobile_download,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.mobile_download
                                     )
                              ),
                        --Bug# 5412029 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpih.currency_header,
                               null,
                               decode(qpih.currency_header_id, null, qplh.currency_header_id,
                                      decode(qpih.currency_header_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpih.currency_header_id
                                             )
                                     ),
                               decode(qpih.currency_header_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpih.currency_header_id
                                     )
                              ),
                        --Bug# 5412029 RAVI END
                        decode(qpih.orig_sys_header_ref, null, qplh.orig_system_header_ref,
                              decode(qpih.orig_sys_header_ref,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.orig_sys_header_ref
                                     )
                              ),
                        decode(qpih.orig_org_id, null, qplh.orig_org_id,
                              decode(qpih.orig_org_id,
                                     QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                     null,
                                     qpih.orig_org_id
                                     )
                              ),
                        decode(qpih.global_flag, null, qplh.global_flag,
                              decode(qpih.global_flag,
                                     QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                     null,
                                     qpih.global_flag
                                     )
                              )
                   from  qp_list_headers qplh
                   where qplh.orig_system_header_ref=qpih.orig_sys_header_ref
                  )
            where qpih.request_id = l_request_id
            and qpih.process_status_flag = 'P'
            and qpih.interface_action_code = 'UPDATE';

	 END IF;

         --ENH Update Functionality RAVI
          /**
          If number of interface headers loaded for processing
          (insert,update,delete) is zero then log a message and exit
          else log a message and process the header and related info
          **/
	 IF l_header_count = 0
	 THEN
	    write_log( 'NO LIST HEADER RECORDS TO PROCESS');
	 ELSE
             write_log('List Headers picked: '||l_header_count);

             --Bug# 5412029
             --ID is to be got from Code
	     --Value to ID conversion before validation
	     QP_BULK_VALUE_TO_ID.Header(l_request_id);

	     -- Attribute level validation for headers

	     QP_BULK_VALIDATE.Attribute_Header(l_request_id);

	     --setting process_status_flag
	     QP_BULK_VALIDATE.Mark_Errored_Interface_Record
					      ( p_table_type=>'HEADER',
						p_request_id=>l_request_id);

	     --Value to ID conversion
	     --QP_BULK_VALUE_TO_ID.Header(l_request_id);

	     --Insert Error messages into db caused by value-ID conversion
	     QP_BULK_VALUE_TO_ID.Insert_Header_Error_Messages(l_request_id);


	     --Bulk load into pl/sql table, entity-validation and Insert/Delete/Update operation
	     Process_Header(l_request_id);

	 END IF;

          -- Bug 5208480(5208112,4188784) RAVI
	  UPDATE qp_interface_qualifiers qpiq
	    SET    qpiq.request_id = l_request_id
	    WHERE    qpiq.rowid IN
	       (SELECT q.rowid
	        FROM   qp_interface_qualifiers q,qp_interface_list_headers h
	        WHERE  q.orig_sys_header_ref = h.orig_sys_header_ref
	        AND    q.request_id IS NULL
	        AND    q.process_status_flag = 'P'
	        AND    h.process_status_flag = 'I'
	        AND    nvl(q.process_id,0) = nvl(p_process_id, nvl(q.process_id,0))
	        AND    nvl(q.process_type,' ') = nvl(p_process_type, nvl(q.process_type,' '))
	        AND    decode(p_process_id, null,q.process_flag,'Y') = 'Y'
	        AND    q.interface_action_code IN ('INSERT','UPDATE','DELETE')
	       )
               -- Bug 5208480(5208112,4188784) RAVI
               AND NOT EXISTS
               (
                  select 1 from qp_qualifiers qpq
                  where qpiq.interface_action_code = 'UPDATE'
                  and qpiq.orig_sys_qualifier_ref = qpq.orig_sys_qualifier_ref
                  and qpq.qualifier_id is not null
                  and qpiq.qualifier_id <> qpq.qualifier_id
               )
	      ;

          --ENH Update Functionality RAVI
          /**
          The number of interface header qualifiers loaded for processing
          (insert,update,delete)
          **/
          l_qualifier_count:=SQL%ROWCOUNT;

        --ENH Update Functionality RAVI
        /**
        If interface action is update then load all null value interface columns
        with values from corresponding qp table columns
        **/
        UPDATE 	qp_interface_qualifiers qpiq
        SET ( 	active_flag,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                comparison_operator_code,
                context,
                created_by,
                created_from_rule_id,
            	creation_date,
            	distinct_row_count,
                end_date_active,
                excluder_flag,
                header_quals_exist_flag,
                list_header_id,
                list_line_id,
                list_type_code,
                orig_sys_header_ref,
                orig_sys_line_ref,
                orig_sys_qualifier_ref,
                program_application_id,
                program_id,
                program_update_date,
                qual_attr_value_from_number,
                qual_attr_value_to_number,
                qualifier_attr_value,
                qualifier_attribute,
                qualifier_context,
                qualifier_datatype,
                qualifier_group_cnt,
                qualifier_grouping_no,
                qualifier_id,
                qualifier_precedence,
                qualifier_rule_id,
                qualify_hier_descendents_flag,
                search_ind,
                start_date_active,
                --Bug# 5456164 RAVI
                qualifier_attr_value_code
	    ) = ( select
	    		decode(qpiq.active_flag, null, qphq.active_flag,
				decode(qpiq.active_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.active_flag
				)
			),
        	        decode(qpiq.attribute1, null, qphq.attribute1,
				decode(qpiq.attribute1,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute1
				)
			),
                	decode(qpiq.attribute10, null, qphq.attribute10,
				decode(qpiq.attribute10,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute10
				)
			),
	                decode(qpiq.attribute11, null, qphq.attribute11,
				decode(qpiq.attribute11,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute11
				)
			),
	                decode(qpiq.attribute12, null, qphq.attribute12,
				decode(qpiq.attribute12,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute12
				)
			),
	                decode(qpiq.attribute13, null, qphq.attribute13,
				decode(qpiq.attribute13,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute13
				)
			),
	                decode(qpiq.attribute14, null, qphq.attribute14,
				decode(qpiq.attribute14,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute14
				)
			),
        	        decode(qpiq.attribute15, null, qphq.attribute15,
				decode(qpiq.attribute15,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute15
				)
			),
                	decode(qpiq.attribute2, null, qphq.attribute2,
				decode(qpiq.attribute2,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute2
				)
			),
	                decode(qpiq.attribute3, null, qphq.attribute3,
				decode(qpiq.attribute3,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute3
				)
			),
        	        decode(qpiq.attribute4, null, qphq.attribute4,
				decode(qpiq.attribute4,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute4
				)
			),
                	decode(qpiq.attribute5, null, qphq.attribute5,
				decode(qpiq.attribute5,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute5
				)
			),
                	decode(qpiq.attribute6, null, qphq.attribute6,
				decode(qpiq.attribute6,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute6
				)
			),
                	decode(qpiq.attribute7, null, qphq.attribute7,
				decode(qpiq.attribute7,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute7
				)
			),
        	        decode(qpiq.attribute8, null, qphq.attribute8,
				decode(qpiq.attribute8,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute8
				)
			),
                	decode(qpiq.attribute9, null, qphq.attribute9,
				decode(qpiq.attribute9,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.attribute9
				)
			),
                	decode(qpiq.comparison_operator_code, null, qphq.comparison_operator_code,
				decode(qpiq.comparison_operator_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.comparison_operator_code
				)
			),
                	decode(qpiq.context, null, qphq.context,
				decode(qpiq.context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.context
				)
			),
                	decode(qpiq.created_by, null, qphq.created_by,
				decode(qpiq.created_by,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.created_by
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                        **/
                        decode(qpiq.created_from_rule,
                               null,
                               decode(qpiq.created_from_rule_id, null, qphq.created_from_rule_id,
                                      decode(qpiq.created_from_rule_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpiq.created_from_rule_id
                                            )
                                     ),
                               decode(qpiq.created_from_rule_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpiq.created_from_rule_id
                                     )
                        ),
                        --Bug# 5456164 RAVI END
            		decode(qpiq.creation_date, null, qphq.creation_date,
				decode(qpiq.creation_date,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpiq.creation_date
				)
			),
            		decode(qpiq.distinct_row_count, null, qphq.distinct_row_count,
				decode(qpiq.distinct_row_count,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.distinct_row_count
				)
			),
                	decode(qpiq.end_date_active, null, qphq.end_date_active,
				decode(qpiq.end_date_active,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpiq.end_date_active
				)
			),
                	decode(qpiq.excluder_flag, null, qphq.excluder_flag,
				decode(qpiq.excluder_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.excluder_flag
				)
			),
                	decode(qpiq.header_quals_exist_flag, null, qphq.header_quals_exist_flag,
				decode(qpiq.header_quals_exist_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.header_quals_exist_flag
				)
			),
	                decode(qpiq.list_header_id, null, qphq.list_header_id,
				decode(qpiq.list_header_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.list_header_id
				)
			),
	                decode(qpiq.list_line_id, null, qphq.list_line_id,
				decode(qpiq.list_line_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.list_line_id
				)
			),
	                decode(qpiq.list_type_code, null, qphq.list_type_code,
				decode(qpiq.list_type_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.list_type_code
				)
			),
	                decode(qpiq.orig_sys_header_ref, null, qphq.orig_sys_header_ref,
				decode(qpiq.orig_sys_header_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.orig_sys_header_ref
				)
			),
	                decode(qpiq.orig_sys_line_ref, null, qphq.orig_sys_line_ref,
				decode(qpiq.orig_sys_line_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.orig_sys_line_ref
				)
			),
	                decode(qpiq.orig_sys_qualifier_ref, null, qphq.orig_sys_qualifier_ref,
				decode(qpiq.orig_sys_qualifier_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.orig_sys_qualifier_ref
				)
			),
	                decode(qpiq.program_application_id, null, qphq.program_application_id,
				decode(qpiq.program_application_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.program_application_id
				)
			),
	                decode(qpiq.program_id, null, qphq.program_id,
				decode(qpiq.program_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.program_id
				)
			),
	                decode(qpiq.program_update_date, null, qphq.program_update_date,
				decode(qpiq.program_update_date,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpiq.program_update_date
				)
			),
	                decode(qpiq.qual_attr_value_from_number, null, qphq.qual_attr_value_from_number,
				decode(qpiq.qual_attr_value_from_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qual_attr_value_from_number
				)
			),
	                decode(qpiq.qual_attr_value_to_number, null, qphq.qual_attr_value_to_number,
				decode(qpiq.qual_attr_value_to_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qual_attr_value_to_number
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                        **/
                        decode(qpiq.qualifier_attr_value_code,
                               null,
                               decode(qpiq.qualifier_attr_value, null, qphq.qualifier_attr_value,
                                      decode(qpiq.qualifier_attr_value,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpiq.qualifier_attr_value
                                            )
                                     ),
                               decode(qpiq.qualifier_attr_value, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpiq.qualifier_attr_value
                                     )
                        ),
                        decode(qpiq.qualifier_attribute_code,
                               null,
                               decode(qpiq.qualifier_attribute, null, qphq.qualifier_attribute,
                                      decode(qpiq.qualifier_attribute,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpiq.qualifier_attribute
                                            )
                                     ),
                               decode(qpiq.qualifier_attribute, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpiq.qualifier_attribute
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpiq.qualifier_context, null, qphq.qualifier_context,
				decode(qpiq.qualifier_context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.qualifier_context
				)
			),
	                decode(qpiq.qualifier_datatype, null, qphq.qualifier_datatype,
				decode(qpiq.qualifier_datatype,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.qualifier_datatype
				)
			),
	                decode(qpiq.qualifier_group_cnt, null, qphq.qualifier_group_cnt,
				decode(qpiq.qualifier_group_cnt,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qualifier_group_cnt
				)
			),
	                decode(qpiq.qualifier_grouping_no, null, qphq.qualifier_grouping_no,
				decode(qpiq.qualifier_grouping_no,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qualifier_grouping_no
				)
			),
	                decode(qpiq.qualifier_id, null, qphq.qualifier_id,
				decode(qpiq.qualifier_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qualifier_id
				)
			),
	                decode(qpiq.qualifier_precedence, null, qphq.qualifier_precedence,
				decode(qpiq.qualifier_precedence,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.qualifier_precedence
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                        **/
                        decode(qpiq.qualifier_rule,
                               null,
                               decode(qpiq.qualifier_rule_id, null, qphq.qualifier_rule_id,
                                      decode(qpiq.qualifier_rule_id,
                                             QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                             null,
                                             qpiq.qualifier_rule_id
                                            )
                                     ),
                               decode(qpiq.qualifier_rule_id, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                      qpiq.qualifier_rule_id
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpiq.qualify_hier_descendents_flag, null, qphq.qualify_hier_descendents_flag,
				decode(qpiq.qualify_hier_descendents_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpiq.qualify_hier_descendents_flag
				)
			),
	                decode(qpiq.search_ind, null, qphq.search_ind,
				decode(qpiq.search_ind,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpiq.search_ind
				)
			),
	                decode(qpiq.start_date_active, null, qphq.start_date_active,
				decode(qpiq.start_date_active,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpiq.start_date_active
				)
			),
                        --Bug# 5456164 RAVI
	                decode(qpiq.qualifier_attr_value_code,
	                       QP_BULK_LOADER_PUB.G_NULL_CHAR, null,
				qpiq.qualifier_attr_value_code
			)
                   	from 	qp_qualifiers qphq,
                        	qp_list_headers_b qplh
                   	where -- CAUSES FTS AS NO INDEX ON LINE_REF
                   		qpiq.orig_sys_qualifier_ref = qphq.orig_sys_qualifier_ref
                   		and qphq.list_header_id = qplh.list_header_id
                   		and qplh.orig_system_header_ref=qpiq.orig_sys_header_ref
                   )
              where qpiq.request_id = l_request_id
              and   qpiq.process_status_flag = 'P'
              and   qpiq.interface_action_code = 'UPDATE';

         --ENH Update Functionality RAVI
          /**
          If number of interface header qualifiers loaded for processing
          (insert,update,delete) is zero then log a message and exit
          else log a message and process the header qualifier and related info
          **/
	 IF l_qualifier_count = 0
	 THEN
	    write_log( 'NO QUALIFIER RECORDS TO PROCESS');
	 ELSE
	     write_log('Number of qualifier records picked: '||l_qualifier_count);

             --Bug# 5412029
             --ID is to be got from Code
	     --Value to ID conversion before validation
	     QP_BULK_VALUE_TO_ID.Qualifier(l_request_id);

	     -- Attribute level validation for Qualifier
	     QP_BULK_VALIDATE.Attribute_Qualifier(l_request_id);


	     --setting process_status_flag
	     QP_BULK_VALIDATE.Mark_Errored_Interface_Record
			      ( p_table_type=>'QUALIFIER',
				p_request_id=>l_request_id);

	     --Insert Error messages into db caused by value-ID conversion
	     QP_BULK_VALUE_TO_ID.Insert_Qual_Error_Message(l_request_id);

	     --Bulk load into pl/sql table, entity-validation and Insert/Delete/Update operation
	     Process_Qualifier(l_request_id);

	 END IF;

	 --Delete all the inserted errored records
	 Post_cleanup(l_request_id);
	 write_log('----Header and qualifier processind complete----');

	 END IF; -- p_entity_name IS NOT NULL
 /*--------------------------- END PROCESSING HEADER----------------------------------*/



  /*--------------------------------------------------------------------------------
                               PROCESS LINES
  ---------------------------------------------------------------------------------*/

  IF p_spawned_request = 'N' or p_spawned_request IS NULL  THEN

     -- Update the all the lines to be processed with request_id
            -- Bug 5208480(5208112,4188784) RAVI
	    Update qp_interface_list_lines qpil
	    Set qpil.request_id= l_request_id
	    Where qpil.rowid IN
	    (select l.rowid
	     from qp_interface_list_lines l, qp_interface_list_headers h
	     where  h.process_status_flag='I'
	     and	l.process_status_flag = 'P'
	     and    l.request_id is null
	     and    h.request_id = l_request_id
	     and    h.orig_sys_header_ref=l.orig_sys_header_ref
	     and     decode(p_process_id, null,l.process_flag,'Y') = 'Y'
	     and    nvl(l.process_id,0) = nvl(p_process_id, nvl(l.process_id,0))
	     and    nvl(l.process_type,' ') = nvl(p_process_type, nvl(l.process_type,' '))
	     and    l.interface_action_code IN ('INSERT','UPDATE','DELETE')	)
             -- Bug 5208480(5208112,4188784) RAVI
   	     -- commenting code for bug 9247305 for performance reasons
	     -- duplicate check has been moved to procedure QP_BULK_VALIDATE.ENTITY_LINE
	     -- which will be called later on.
               /*AND NOT EXISTS
               (
                  select 1 from qp_list_lines qpll
                  where qpil.interface_action_code = 'UPDATE'
                  and qpil.orig_sys_line_ref = qpll.orig_sys_line_ref
                  and qpll.list_line_id is not null
                  and qpil.list_line_id <> qpll.list_line_id
               )*/
	     ;

	  write_log('Number of Lines picked: '||SQL%ROWCOUNT);


        --ENH Update Functionality RAVI
        /**
        If interface action is update then load all null value interface columns
        with values from corresponding qp table columns
        **/
        UPDATE 	qp_interface_list_lines qpil
        SET ( 	accrual_conversion_rate,
                accrual_flag,
                accrual_qty,
                accrual_uom_code,
                arithmetic_operator,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                automatic_flag,
                base_qty,
                base_uom_code,
                benefit_limit,
                benefit_price_list_line_id,
                benefit_qty,
                benefit_uom_code,
                charge_subtype_code,
                charge_type_code,
                comments,
                context,
                continuous_price_break_flag,
                created_by,
            	creation_date,
            	effective_period_uom,
                end_date_active,
                estim_accrual_rate,
                estim_gl_value,
                expiration_date,
                expiration_period_start_date,
                expiration_period_uom,
                generate_using_formula_id,
                include_on_returns_flag,
                incompatibility_grp_code,
                inventory_item_id,
                list_header_id,
                list_line_id,
                list_line_no,
                list_line_type_code,
                list_price,
                list_price_uom_code,
                modifier_level_code,
                net_amount_flag,
                number_effective_periods,
                number_expiration_periods,
                operand,
                organization_id,
                orig_sys_header_ref,
                orig_sys_line_ref,
                override_flag,
                percent_price,
                price_break_header_ref,--change
                price_break_type_code,
                price_by_formula_id,
                pricing_group_sequence,
                pricing_phase_id,
                primary_uom_flag,
                print_on_invoice_flag,
                product_precedence,
                program_application_id,
                program_id,
                program_update_date,
                proration_type_code,
                qualification_ind,
                rebate_transaction_type_code,
                recurring_flag,
                recurring_value,
                related_item_id,
                relationship_type_id,
                reprice_flag,
                revision,
                revision_date,
                revision_reason_code,
                rltd_modifier_grp_type,--change
                start_date_active,
                substitution_attribute,
                substitution_context,
                substitution_value
	    ) = ( select
	    		     decode(qpil.accrual_conversion_rate, null, qpll.accrual_conversion_rate,
                              	 decode(qpil.accrual_conversion_rate,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.accrual_conversion_rate
                                        )
                                 ),
                             decode(qpil.accrual_flag, null, qpll.accrual_flag,
                                 decode(qpil.accrual_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.accrual_flag
                                        )
                                 ),
                             decode(qpil.accrual_qty, null, qpll.accrual_qty,
                                 decode(qpil.accrual_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.accrual_qty
                                        )
                                 ),
                             decode(qpil.accrual_uom_code, null, qpll.accrual_uom_code,
                                 decode(qpil.accrual_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.accrual_uom_code
                                        )
                                 ),
                             decode(qpil.arithmetic_operator, null, qpll.arithmetic_operator,
                                 decode(qpil.arithmetic_operator,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.arithmetic_operator
                                        )
                                 ),
                             decode(qpil.attribute1, null, qpll.attribute1,
                                 decode(qpil.attribute1,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute1
                                        )
                                 ),
                             decode(qpil.attribute10, null, qpll.attribute10,
                                 decode(qpil.attribute10,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute10
                                        )
                                 ),
                             decode(qpil.attribute11, null, qpll.attribute11,
                                 decode(qpil.attribute11,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute11
                                        )
                                 ),
                             decode(qpil.attribute12, null, qpll.attribute12,
                                 decode(qpil.attribute12,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute12
                                        )
                                 ),
                             decode(qpil.attribute13, null, qpll.attribute13,
                                 decode(qpil.attribute13,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute13
                                        )
                                 ),
                             decode(qpil.attribute14, null, qpll.attribute14,
                                 decode(qpil.attribute14,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute14
                                        )
                                 ),
                             decode(qpil.attribute15, null, qpll.attribute15,
                                 decode(qpil.attribute15,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute15
                                        )
                                 ),
                             decode(qpil.attribute2, null, qpll.attribute2,
                                 decode(qpil.attribute2,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute2
                                        )
                                 ),
                             decode(qpil.attribute3, null, qpll.attribute3,
                                 decode(qpil.attribute3,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute3
                                        )
                                 ),
                             decode(qpil.attribute4, null, qpll.attribute4,
                                 decode(qpil.attribute4,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute4
                                        )
                                 ),
                             decode(qpil.attribute5, null, qpll.attribute5,
                                 decode(qpil.attribute5,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute5
                                        )
                                 ),
                             decode(qpil.attribute6, null, qpll.attribute6,
                                 decode(qpil.attribute6,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute6
                                        )
                                 ),
                             decode(qpil.attribute7, null, qpll.attribute7,
                                 decode(qpil.attribute7,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute7
                                        )
                                 ),
                             decode(qpil.attribute8, null, qpll.attribute8,
                                 decode(qpil.attribute8,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute8
                                        )
                                 ),
                             decode(qpil.attribute9, null, qpll.attribute9,
                                 decode(qpil.attribute9,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute9
                                        )
                                 ),
                             decode(qpil.automatic_flag, null, qpll.automatic_flag,
                                 decode(qpil.automatic_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.automatic_flag
                                        )
                                 ),
                             decode(qpil.base_qty, null, qpll.base_qty,
                                 decode(qpil.base_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.base_qty
                                        )
                                 ),
                             decode(qpil.base_uom_code, null, qpll.base_uom_code,
                                 decode(qpil.base_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.base_uom_code
                                        )
                                 ),
                             decode(qpil.benefit_limit, null, qpll.benefit_limit,
                                 decode(qpil.benefit_limit,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_limit
                                        )
                                 ),
                             decode(qpil.benefit_price_list_line_id, null, qpll.benefit_price_list_line_id,
                                 decode(qpil.benefit_price_list_line_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_price_list_line_id
                                        )
                                 ),
                             decode(qpil.benefit_qty, null, qpll.benefit_qty,
                                 decode(qpil.benefit_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_qty
                                        )
                                 ),
                             decode(qpil.benefit_uom_code, null, qpll.benefit_uom_code,
                                 decode(qpil.benefit_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.benefit_uom_code
                                        )
                                 ),
                             decode(qpil.charge_subtype_code, null, qpll.charge_subtype_code,
                                 decode(qpil.charge_subtype_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.charge_subtype_code
                                        )
                                 ),
                             decode(qpil.charge_type_code, null, qpll.charge_type_code,
                                 decode(qpil.charge_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.charge_type_code
                                        )
                                 ),
                             decode(qpil.comments, null, qpll.comments,
                                 decode(qpil.comments,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.comments
                                        )
                                 ),
                             decode(qpil.context, null, qpll.context,
                                 decode(qpil.context,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.context
                                        )
                                 ),
                             decode(qpil.continuous_price_break_flag, null, qpll.continuous_price_break_flag,
                                 decode(qpil.continuous_price_break_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.continuous_price_break_flag
                                        )
                                 ),
                             decode(qpil.created_by, null, qpll.created_by,
                                 decode(qpil.created_by,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.created_by
                                        )
                                 ),
        		     decode(qpil.creation_date, null, qpll.creation_date,
        		         decode(qpil.creation_date,
        		                QP_BULK_LOADER_PUB.G_NULL_DATE,
        		                null,
        		                qpil.creation_date
        		                )
        		         ),
        		     decode(qpil.effective_period_uom, null, qpll.effective_period_uom,
        		         decode(qpil.effective_period_uom,
        		                QP_BULK_LOADER_PUB.G_NULL_CHAR,
        		                null,
        		                qpil.effective_period_uom
        		                )
        		         ),
                             decode(qpil.end_date_active, null, qpll.end_date_active,
                                 decode(qpil.end_date_active,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.end_date_active
                                        )
                                 ),
                             decode(qpil.estim_accrual_rate, null, qpll.estim_accrual_rate,
                                 decode(qpil.estim_accrual_rate,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.estim_accrual_rate
                                        )
                                 ),
                             decode(qpil.estim_gl_value, null, qpll.estim_gl_value,
                                 decode(qpil.estim_gl_value,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.estim_gl_value
                                        )
                                 ),
                             decode(qpil.expiration_date, null, qpll.expiration_date,
                                 decode(qpil.expiration_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.expiration_date
                                        )
                                 ),
                             decode(qpil.expiration_period_start_date, null, qpll.expiration_period_start_date,
                                 decode(qpil.expiration_period_start_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.expiration_period_start_date
                                        )
                                 ),
                             decode(qpil.expiration_period_uom, null, qpll.expiration_period_uom,
                                 decode(qpil.expiration_period_uom,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.expiration_period_uom
                                        )
                                 ),
                             --Bug# 5412029 RAVI START
                             /**
                              * If VALUE=null then
                              *    If ID=null update ID to existing data
                              *    If ID=id update ID to id
                              *    If ID=G_NULL update ID to null
                              * If VALUE<>null then
                              *    If ID=null update ID to existing data
                              *    If ID=id update ID to id
                              *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                              **/
                             decode(qpil.generate_using_formula,
                                    null,
                                    decode(qpil.generate_using_formula_id, null, qpll.generate_using_formula_id,
                                           decode(qpil.generate_using_formula_id,
                                                  QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                                  null,
                                                  qpil.generate_using_formula_id
                                                 )
                                          ),
                                    decode(qpil.generate_using_formula_id, null, null,
                                           QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                           qpil.generate_using_formula_id
                                          )
                                   ),
                             --Bug# 5412029 RAVI END
                             decode(qpil.include_on_returns_flag, null, qpll.include_on_returns_flag,
                                 decode(qpil.include_on_returns_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.include_on_returns_flag
                                        )
                                 ),
                             decode(qpil.incompatibility_grp_code, null, qpll.incompatibility_grp_code,
                                 decode(qpil.incompatibility_grp_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.incompatibility_grp_code
                                        )
                                 ),
                             decode(qpil.inventory_item_id, null, qpll.inventory_item_id,
                                 decode(qpil.inventory_item_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.inventory_item_id
                                        )
                                 ),
                             decode(qpil.list_header_id, null, qpll.list_header_id,
                                 decode(qpil.list_header_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_header_id
                                        )
                                 ),
                             decode(qpil.list_line_id, null, qpll.list_line_id,
                                 decode(qpil.list_line_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_line_id
                                        )
                                 ),
                             decode(qpil.list_line_no, null, qpll.list_line_no,
                                 decode(qpil.list_line_no,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_line_no
                                        )
                                 ),
                             decode(qpil.list_line_type_code, null, qpll.list_line_type_code,
                                 decode(qpil.list_line_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_line_type_code
                                        )
                                 ),
                             decode(qpil.list_price, null, qpll.list_price,
                                 decode(qpil.list_price,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_price
                                        )
                                 ),
                             decode(qpil.list_price_uom_code, null, qpll.list_price_uom_code,
                                 decode(qpil.list_price_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_price_uom_code
                                        )
                                 ),
                             decode(qpil.modifier_level_code, null, qpll.modifier_level_code,
                                 decode(qpil.modifier_level_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.modifier_level_code
                                        )
                                 ),
                             decode(qpil.net_amount_flag, null, qpll.net_amount_flag,
                                 decode(qpil.net_amount_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.net_amount_flag
                                        )
                                 ),
                             decode(qpil.number_effective_periods, null, qpll.number_effective_periods,
                                 decode(qpil.number_effective_periods,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.number_effective_periods
                                        )
                                 ),
                             decode(qpil.number_expiration_periods, null, qpll.number_expiration_periods,
                                 decode(qpil.number_expiration_periods,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.number_expiration_periods
                                        )
                                 ),
                             decode(qpil.operand, null, qpll.operand,
                                 decode(qpil.operand,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.operand
                                        )
                                 ),
                             decode(qpil.organization_id, null, qpll.organization_id,
                                 decode(qpil.organization_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.organization_id
                                        )
                                 ),
                             decode(qpil.orig_sys_header_ref, null, qpll.orig_sys_header_ref,
                                 decode(qpil.orig_sys_header_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.orig_sys_header_ref
                                        )
                                 ),
                             decode(qpil.orig_sys_line_ref, null, qpll.orig_sys_line_ref,
                                 decode(qpil.orig_sys_line_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.orig_sys_line_ref
                                        )
                                 ),
                             decode(qpil.override_flag, null, qpll.override_flag,
                                 decode(qpil.override_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.override_flag
                                        )
                                 ),
                             decode(qpil.percent_price, null, qpll.percent_price,
                                 decode(qpil.percent_price,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.percent_price
                                        )
                                 ),
                             decode(qpil.price_break_header_ref, null,
                             	        (select pll.orig_sys_line_ref
                                         from qp_list_lines pll, qp_rltd_modifiers rm
                                         where rm.to_rltd_modifier_id = qpll.list_line_id
                                         and rm.from_rltd_modifier_id = pll.list_line_id
                                         and rm.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
                                         ),
                                 decode(qpil.price_break_header_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.price_break_header_ref
                                       )
                                 ),
                             decode(qpil.price_break_type_code, null, qpll.price_break_type_code,
                                 decode(qpil.price_break_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.price_break_type_code
                                        )
                                 ),
                             --Bug# 5412029 RAVI START
                             /**
                              * If VALUE=null then
                              *    If ID=null update ID to existing data
                              *    If ID=id update ID to id
                              *    If ID=G_NULL update ID to null
                              * If VALUE<>null then
                              *    If ID=null update ID to existing data
                              *    If ID=id update ID to id
                              *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                              **/
                             decode(qpil.price_by_formula,
                                    null,
                                    decode(qpil.price_by_formula_id, null, qpll.price_by_formula_id,
                                           decode(qpil.price_by_formula_id,
                                                  QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                                  null,
                                                  qpil.price_by_formula_id
                                                 )
                                          ),
                                    decode(qpil.price_by_formula_id, null, null,
                                           QP_BULK_LOADER_PUB.G_NULL_NUMBER,null,
                                           qpil.price_by_formula_id
                                          )
                                   ),
                             --Bug# 5412029 RAVI END
                             decode(qpil.pricing_group_sequence, null, qpll.pricing_group_sequence,
                                 decode(qpil.pricing_group_sequence,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.pricing_group_sequence
                                        )
                                 ),
                             decode(qpil.pricing_phase_id, null, qpll.pricing_phase_id,
                                 decode(qpil.pricing_phase_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.pricing_phase_id
                                        )
                                 ),
                             decode(qpil.primary_uom_flag, null, qpll.primary_uom_flag,
                                 decode(qpil.primary_uom_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.primary_uom_flag
                                        )
                                 ),
                             decode(qpil.print_on_invoice_flag, null, qpll.print_on_invoice_flag,
                                 decode(qpil.print_on_invoice_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.print_on_invoice_flag
                                        )
                                 ),
                             decode(qpil.product_precedence, null, qpll.product_precedence,
                                 decode(qpil.product_precedence,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.product_precedence
                                        )
                                 ),
                             decode(qpil.program_application_id, null, qpll.program_application_id,
                                 decode(qpil.program_application_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.program_application_id
                                        )
                                 ),
                             decode(qpil.program_id, null, qpll.program_id,
                                 decode(qpil.program_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.program_id
                                        )
                                 ),
                             decode(qpil.program_update_date, null, qpll.program_update_date,
                                 decode(qpil.program_update_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.program_update_date
                                        )
                                 ),
                             decode(qpil.proration_type_code, null, qpll.proration_type_code,
                                 decode(qpil.proration_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.proration_type_code
                                        )
                                 ),
                             decode(qpil.qualification_ind, null, qpll.qualification_ind,
                                 decode(qpil.qualification_ind,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.qualification_ind
                                        )
                                 ),
                             decode(qpil.rebate_transaction_type_code, null, qpll.rebate_transaction_type_code,
                                 decode(qpil.rebate_transaction_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.rebate_transaction_type_code
                                        )
                                 ),
                             decode(qpil.recurring_flag, null, qpll.recurring_flag,
                                 decode(qpil.recurring_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.recurring_flag
                                        )
                                 ),
                             decode(qpil.recurring_value, null, qpll.recurring_value,
                                 decode(qpil.recurring_value,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.recurring_value
                                        )
                                 ),
                             decode(qpil.related_item_id, null, qpll.related_item_id,
                                 decode(qpil.related_item_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.related_item_id
                                        )
                                 ),
                             decode(qpil.relationship_type_id, null, qpll.relationship_type_id,
                                 decode(qpil.relationship_type_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.relationship_type_id
                                        )
                                 ),
                             decode(qpil.reprice_flag, null, qpll.reprice_flag,
                                 decode(qpil.reprice_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.reprice_flag
                                        )
                                 ),
                             decode(qpil.revision, null, qpll.revision,
                                 decode(qpil.revision,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.revision
                                        )
                                 ),
                             decode(qpil.revision_date, null, qpll.revision_date,
                                 decode(qpil.revision_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.revision_date
                                        )
                                 ),
                             decode(qpil.revision_reason_code, null, qpll.revision_reason_code,
                                 decode(qpil.revision_reason_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.revision_reason_code
                                        )
                                 ),
                             decode(qpil.rltd_modifier_grp_type, null,
                                        (select rm.RLTD_MODIFIER_GRP_TYPE
                                         from qp_list_lines pll, qp_rltd_modifiers rm
                                         where rm.to_rltd_modifier_id = qpll.list_line_id
                                         and rm.from_rltd_modifier_id = pll.list_line_id
                                         and rm.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
                                         ),
                                 decode(qpil.rltd_modifier_grp_type,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.rltd_modifier_grp_type
                                        )
                                 ),
                             decode(qpil.start_date_active, null, qpll.start_date_active,
                                 decode(qpil.start_date_active,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.start_date_active
                                        )
                                 ),
                             decode(qpil.substitution_attribute, null, qpll.substitution_attribute,
                                 decode(qpil.substitution_attribute,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_attribute
                                        )
                                 ),
                             decode(qpil.substitution_context, null, qpll.substitution_context,
                                 decode(qpil.substitution_context,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_context
                                        )
                                 ),
                             decode(qpil.substitution_value, null, qpll.substitution_value,
                                 decode(qpil.substitution_value,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_value
                                        )
                                 )
                   	from 	qp_list_headers qplh,
                        	qp_list_lines qpll
                   	where -- CAUSES FTS AS NO INDEX ON LINE_REF
                   		qpil.orig_sys_line_ref = qpll.orig_sys_line_ref
                   		and qpll.list_header_id = qplh.list_header_id
                   		and qplh.orig_system_header_ref=qpil.orig_sys_header_ref
                   )
              where qpil.request_id = l_request_id
              and   qpil.process_status_flag = 'P'
              --Bug# 5236656
              -- The interface lines record should be updated in case of both update or delete action.
              and   qpil.interface_action_code IN ('UPDATE','DELETE');


          -- Bug 5208480(5208112,4188784) RAVI
	  UPDATE qp_interface_pricing_attribs qpip
	  SET    qpip.request_id = l_request_id
	  WHERE  qpip.rowid IN
	     (SELECT pa.rowid
	      FROM  qp_interface_pricing_attribs pa, qp_interface_list_headers h
	      WHERE h.process_status_flag='I'
	      AND   h.orig_sys_header_ref=pa.orig_sys_header_ref
	      AND   h.request_id = l_request_id
	      AND   pa.request_id IS NULL
	      AND   pa.process_status_flag = 'P'
	      AND   decode(p_process_id, null,pa.process_flag,'Y') = 'Y'
	      AND   nvl(pa.process_id,0) = nvl(p_process_id, nvl(pa.process_id,0))
	      AND   nvl(pa.process_type,' ') = nvl(p_process_type, nvl(pa.process_type,' '))
	      AND   pa.interface_action_code IN ('INSERT','UPDATE','DELETE') )
              -- Bug 5208480(5208112,4188784) RAVI
              AND NOT EXISTS
              (
               select 1 from qp_pricing_attributes qppa
               where qpip.interface_action_code = 'UPDATE'
               and qpip.orig_sys_line_ref = qppa.orig_sys_line_ref
               and qppa.list_line_id is not null
               and qpip.list_line_id <> qppa.list_line_id
              )
              -- Bug# 5246745 RAVI
              -- Should not be able to update product attribute context
              AND NOT EXISTS
              (
               select 1 from qp_pricing_attributes qppa
               where qpip.interface_action_code = 'UPDATE'
               and qpip.orig_sys_line_ref = qppa.orig_sys_line_ref
               and qppa.product_attribute_context is not null
               and qpip.product_attribute_context <> qppa.product_attribute_context
              )
              -- Bug# 5246745 RAVI
              -- Should not be able to update product attribute
              AND NOT EXISTS
              (
               select 1 from qp_pricing_attributes qppa
               where qpip.interface_action_code = 'UPDATE'
               and qpip.orig_sys_line_ref = qppa.orig_sys_line_ref
               and qppa.product_attribute is not null
               and qpip.product_attribute <> qppa.product_attribute
              )
              -- Bug# 5246745 RAVI
              -- Should not be able to update product attribute Value
              AND NOT EXISTS
              (
               select 1 from qp_pricing_attributes qppa
               where qpip.interface_action_code = 'UPDATE'
               and qpip.orig_sys_line_ref = qppa.orig_sys_line_ref
               and qppa.product_attr_value is not null
               and qpip.product_attr_value <> qppa.product_attr_value
              )
	    ;

        write_log('Number of Pricing Attributes picked: '||SQL%ROWCOUNT);

        --ENH Update Functionality RAVI
        /**
        If interface action is update then load all null value interface columns
        with values from corresponding qp table columns
        **/
        UPDATE 	qp_interface_pricing_attribs qpip
        SET ( 	accumulate_flag,
                attribute_grouping_no,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                comparison_operator_code,
                context,
                created_by,
                excluder_flag,
                list_header_id,
                list_line_id,
                orig_sys_header_ref,
                orig_sys_line_ref,
                orig_sys_pricing_attr_ref,
                pricing_attr_value_from,
                pricing_attr_value_from_number,
                pricing_attr_value_to,
                pricing_attr_value_to_number,
                pricing_attribute,
                pricing_attribute_context,
                pricing_attribute_datatype,
                pricing_attribute_id,
                pricing_phase_id,
                product_attr_value,
                product_attribute,
                product_attribute_context,
                product_attribute_datatype,
                product_uom_code,
                program_application_id,
                program_id,
                program_update_date,
                qualification_ind,
                --Bug#5456164 RAVI START
                --If ID in ID_to_VAL is G_CHAR then set it null
                product_attr_val_disp,
                pricing_attr_value_from_disp,
                pricing_attr_value_to_disp
                --Bug#5456164 RAVI START
	    ) = ( select
	    		decode(qpip.accumulate_flag, null, qppa.accumulate_flag,
				decode(qpip.accumulate_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.accumulate_flag
				)
			),
	    		decode(qpip.attribute_grouping_no, null, qppa.attribute_grouping_no,
				decode(qpip.attribute_grouping_no,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.attribute_grouping_no
				)
			),
        	        decode(qpip.attribute1, null, qppa.attribute1,
				decode(qpip.attribute1,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute1
				)
			),
                	decode(qpip.attribute10, null, qppa.attribute10,
				decode(qpip.attribute10,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute10
				)
			),
	                decode(qpip.attribute11, null, qppa.attribute11,
				decode(qpip.attribute11,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute11
				)
			),
	                decode(qpip.attribute12, null, qppa.attribute12,
				decode(qpip.attribute12,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute12
				)
			),
	                decode(qpip.attribute13, null, qppa.attribute13,
				decode(qpip.attribute13,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute13
				)
			),
	                decode(qpip.attribute14, null, qppa.attribute14,
				decode(qpip.attribute14,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute14
				)
			),
        	        decode(qpip.attribute15, null, qppa.attribute15,
				decode(qpip.attribute15,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute15
				)
			),
                	decode(qpip.attribute2, null, qppa.attribute2,
				decode(qpip.attribute2,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute2
				)
			),
	                decode(qpip.attribute3, null, qppa.attribute3,
				decode(qpip.attribute3,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute3
				)
			),
        	        decode(qpip.attribute4, null, qppa.attribute4,
				decode(qpip.attribute4,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute4
				)
			),
                	decode(qpip.attribute5, null, qppa.attribute5,
				decode(qpip.attribute5,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute5
				)
			),
                	decode(qpip.attribute6, null, qppa.attribute6,
				decode(qpip.attribute6,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute6
				)
			),
                	decode(qpip.attribute7, null, qppa.attribute7,
				decode(qpip.attribute7,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute7
				)
			),
        	        decode(qpip.attribute8, null, qppa.attribute8,
				decode(qpip.attribute8,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute8
				)
			),
                	decode(qpip.attribute9, null, qppa.attribute9,
				decode(qpip.attribute9,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute9
				)
			),
                	decode(qpip.comparison_operator_code, null, qppa.comparison_operator_code,
				decode(qpip.comparison_operator_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.comparison_operator_code
				)
			),
                	decode(qpip.context, null, qppa.context,
				decode(qpip.context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.context
				)
			),
                	decode(qpip.created_by, null, qppa.created_by,
				decode(qpip.created_by,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.created_by
				)
			),
                	decode(qpip.excluder_flag, null, qppa.excluder_flag,
				decode(qpip.excluder_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.excluder_flag
				)
			),
	                decode(qpip.list_header_id, null, qppa.list_header_id,
				decode(qpip.list_header_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.list_header_id
				)
			),
	                decode(qpip.list_line_id, null, qppa.list_line_id,
				decode(qpip.list_line_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.list_line_id
				)
			),
	                decode(qpip.orig_sys_header_ref, null, qppa.orig_sys_header_ref,
				decode(qpip.orig_sys_header_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_header_ref
				)
			),
	                decode(qpip.orig_sys_line_ref, null, qppa.orig_sys_line_ref,
				decode(qpip.orig_sys_line_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_line_ref
				)
			),
	                decode(qpip.orig_sys_pricing_attr_ref, null, qppa.orig_sys_pricing_attr_ref,
				decode(qpip.orig_sys_pricing_attr_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_pricing_attr_ref
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpip.pricing_attr_value_from_disp,
                               null,
                               decode(qpip.pricing_attr_value_from, null, qppa.pricing_attr_value_from,
                                      decode(qpip.pricing_attr_value_from,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpip.pricing_attr_value_from
                                            )
                                      ),
                               decode(qpip.pricing_attr_value_from, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpip.pricing_attr_value_from
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpip.pricing_attr_value_from_number, null, qppa.pricing_attr_value_from_number,
				decode(qpip.pricing_attr_value_from_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attr_value_from_number
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpip.pricing_attr_value_to_disp,
                               null,
                               decode(qpip.pricing_attr_value_to, null, qppa.pricing_attr_value_to,
                                      decode(qpip.pricing_attr_value_to,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpip.pricing_attr_value_to
                                            )
                                      ),
                               decode(qpip.pricing_attr_value_to, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpip.pricing_attr_value_to
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpip.pricing_attr_value_to_number, null, qppa.pricing_attr_value_to_number,
				decode(qpip.pricing_attr_value_to_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attr_value_to_number
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpip.pricing_attr_code,
                               null,
                               decode(qpip.pricing_attribute, null, qppa.pricing_attribute,
                                      decode(qpip.pricing_attribute,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpip.pricing_attribute
                                            )
                                      ),
                               decode(qpip.pricing_attribute, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpip.pricing_attribute
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpip.pricing_attribute_context, null, qppa.pricing_attribute_context,
				decode(qpip.pricing_attribute_context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attribute_context
				)
			),
	                decode(qpip.pricing_attribute_datatype, null, qppa.pricing_attribute_datatype,
				decode(qpip.pricing_attribute_datatype,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attribute_datatype
				)
			),
	                decode(qpip.pricing_attribute_id, null, qppa.pricing_attribute_id,
				decode(qpip.pricing_attribute_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attribute_id
				)
			),
	                decode(qpip.pricing_phase_id, null, qppa.pricing_phase_id,
				decode(qpip.pricing_phase_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_phase_id
				)
			),
                        --Bug# 5456164 RAVI START
                        /**
                         * If VALUE=null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID=G_NULL update ID to null
                         * If VALUE<>null then
                         *    If ID=null update ID to existing data
                         *    If ID=id update ID to id
                         *    If ID<>id update ID to null (conversion is done as required in ValueToId)
                         **/
                        decode(qpip.product_attr_val_disp,
                               null,
                               decode(qpip.product_attr_value, null, qppa.product_attr_value,
                                      decode(qpip.product_attr_value,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpip.product_attr_value
                                            )
                                      ),
                               decode(qpip.product_attr_value, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpip.product_attr_value
                                     )
                        ),
                        decode(qpip.product_attr_code,
                               null,
                               decode(qpip.product_attribute, null, qppa.product_attribute,
                                      decode(qpip.product_attribute,
                                             QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                             null,
                                             qpip.product_attribute
                                            )
                                      ),
                               decode(qpip.product_attribute, null, null,
                                      QP_BULK_LOADER_PUB.G_NULL_CHAR,null,
                                      qpip.product_attribute
                                     )
                        ),
                        --Bug# 5456164 RAVI END
	                decode(qpip.product_attribute_context, null, qppa.product_attribute_context,
				decode(qpip.product_attribute_context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attribute_context
				)
			),
	                decode(qpip.product_attribute_datatype, null, qppa.product_attribute_datatype,
				decode(qpip.product_attribute_datatype,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attribute_datatype
				)
			),
	                decode(qpip.product_uom_code, null, qppa.product_uom_code,
				decode(qpip.product_uom_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_uom_code
				)
			),
	                decode(qpip.program_application_id, null, qppa.program_application_id,
				decode(qpip.program_application_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.program_application_id
				)
			),
	                decode(qpip.program_id, null, qppa.program_id,
				decode(qpip.program_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.program_id
				)
			),
	                decode(qpip.program_update_date, null, qppa.program_update_date,
				decode(qpip.program_update_date,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpip.program_update_date
				)
			),
	                decode(qpip.qualification_ind, null, qppa.qualification_ind,
				decode(qpip.qualification_ind,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.qualification_ind
				)
			),
                        --Bug# 5456164 RAVI START
                	--If ID in ID_to_VAL is G_CHAR then set it null
	                decode(qpip.product_attr_val_disp,
	                       QP_BULK_LOADER_PUB.G_NULL_CHAR, null,
				qpip.product_attr_val_disp
			),
	                decode(qpip.pricing_attr_value_from_disp,
	                       QP_BULK_LOADER_PUB.G_NULL_CHAR, null,
				qpip.pricing_attr_value_from_disp
			),
	                decode(qpip.pricing_attr_value_to_disp,
	                       QP_BULK_LOADER_PUB.G_NULL_CHAR, null,
				qpip.pricing_attr_value_to_disp
			)
                        --Bug# 5456164 RAVI END
                   	from 	qp_pricing_attributes qppa,
                        	qp_list_headers_b qplh
                   	where -- CAUSES FTS AS NO INDEX ON PRICNG_ATTR_REF
                   		qpip.orig_sys_pricing_attr_ref = qppa.orig_sys_pricing_attr_ref
                   		and qppa.list_header_id = qplh.list_header_id
                   		and qplh.orig_system_header_ref=qpip.orig_sys_header_ref
                   )
              where qpip.request_id = l_request_id
              and   qpip.process_status_flag = 'P'
              and   qpip.interface_action_code IN ('UPDATE','DELETE');

      --Highest Price Break Value To '9999...999' if it is null
      UPDATE qp_interface_pricing_attribs qpip
      SET    qpip.pricing_attr_value_to = '999999999999999'
      WHERE  qpip.request_id = l_request_id
      AND EXISTS (
            SELECT 'YES'
            FROM   qp_interface_list_lines qpil
            WHERE  qpil.request_id = qpip.request_id
            AND    qpip.orig_sys_line_ref = qpil.orig_sys_line_ref
            AND    qpil.price_break_header_ref is not null
            AND    qpip.pricing_attr_value_to is null
      );

      --Value to ID Conversion of lines and pricing attributes
      QP_BULK_VALUE_TO_ID.Line(l_request_id);

      QP_BULK_VALUE_TO_ID.Insert_Line_Error_Message(l_request_id);

      -- ENH duplicate line check flag RAVI
      IF G_QP_ENABLE_DUP_LINE_CHECK='Y' THEN
         QP_BULK_VALIDATE.Dup_line_Check(l_request_id);
      END IF;

      write_log('After duplicate Line Check');

      /*----------------Breaking the lines among the threads -----------------------------------*/

      --Number of lines to be processed

      SELECT count(*) INTO l_no_of_lines
      FROM   qp_interface_list_lines
      WHERE  request_id = l_request_id
      AND    process_status_flag = 'P'
      AND    price_break_header_ref is null
      AND    rltd_modifier_grp_type is null;

      write_log('No of Lines to be processed:'||l_no_of_lines);

      IF l_no_of_lines = 0 THEN

	   SELECT count(*) INTO l_count
		FROM (SELECT 'Y'
			FROM qp_interface_list_lines
		       WHERE request_id = l_request_id
			 AND process_status_flag = 'P'
		       UNION
		      SELECT 'Y'
			FROM qp_interface_pricing_attribs
		       WHERE request_id = l_request_id
			 AND process_status_flag = 'P');

	        IF l_count > 0 THEN
		   l_no_of_lines := 1;
		ELSE
		   l_no_of_lines := 0;
		   write_log( 'No Lines to process');
		END IF;
      END IF;

      IF l_no_of_lines = 0
      THEN
	 write_log( 'No Lines to Process');
	 CLEAN_UP_CODE(l_request_id);
	 Return;
      END IF;

      IF p_no_of_threads > l_no_of_lines
      THEN
	 l_no_of_threads:=l_no_of_lines;
      END IF;


      l_batch_size := floor(l_no_of_lines/l_no_of_threads);
      l_mod        := mod(l_no_of_lines, l_no_of_threads);

      write_log( 'Batch Size: '||l_batch_size);
      write_log( 'Mod: '||l_mod);

      FOR I in 1..l_no_of_threads
      LOOP

         -- ENH duplicate line check flag RAVI
	 l_new_request_id := fnd_request.submit_request('QP','QPXVBLK','Pricelist Import'||
							l_req_data, NULL, TRUE,
							'PRL',
							p_entity_name,p_process_id, p_process_type -- Bug No: 6235177, change NULL to p_process_typ
							,p_process_parent,l_no_of_threads,
							'Y',l_request_id,g_qp_debug, G_QP_ENABLE_DUP_LINE_CHECK);
	 write_log( 'Child '||I||' request_id: '||l_new_request_id);

	 IF l_new_request_id=0
	 THEN
	    FND_FILE.put_line(FND_FILE.OUTPUT, 'Error in spawning child process');
	    retcode := 2;
	    err_buff  := FND_MESSAGE.GET;
	    Return;
	 ELSE
	    G_thread_info_table(I).request_id := l_new_request_id;

	    IF I=p_no_of_threads
	    THEN
	       UPDATE qp_interface_list_lines
               SET    request_id = l_new_request_id
	       WHERE  request_id = l_request_id
	       AND    process_status_flag = 'P'
               AND    price_break_header_ref IS NULL
               AND    rltd_modifier_grp_type IS NULL
               AND    rownum <= l_batch_size+l_mod;
	    ELSE
	       UPDATE qp_interface_list_lines
               SET    request_id = l_new_request_id
	       WHERE  request_id = l_request_id
	       AND    process_status_flag = 'P'
               AND    price_break_header_ref IS NULL
               AND    rltd_modifier_grp_type IS NULL
               AND    rownum <= l_batch_size;
	    END IF;
	    G_thread_info_table(I).total_lines := SQL%ROWCOUNT;
	    COMMIT;
	 END IF;

    END LOOP;

    select hsecs into l_end_time from v$timer;
    write_log( 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time taken for the header process 1 (sec):' ||(l_end_time - l_start_time)/100);

    --Parents waits untill all the threads complete
    fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
				    request_data =>to_char(l_req_data_counter));



    write_log( 'Parent process waiting for childs to complete....');

  ELSE
  /*------------------------------- Child Thread processing lines -----------------------*/

    --child threads request id
    write_log( '-----Begining of Child Process-----');

    FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);

    write_log( 'Request ID: '||l_request_id);

    -- Update PBH child lines with request id.

      select hsecs into l_start_time from v$timer;
      write_log( 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

    -- Bug 5208480(5208112,4188784) RAVI
    UPDATE qp_interface_list_lines qpil
    SET    qpil.request_id = l_request_id
    WHERE qpil.rowid IN
     ((SELECT c.rowid
      FROM   qp_interface_list_lines p,qp_interface_list_lines c
      WHERE  p.request_id = l_request_id
      AND    c.request_id = p_request_id
      AND    c.price_break_header_ref = p.orig_sys_line_ref
      AND    c.rltd_modifier_grp_type = 'PRICE BREAK'
      AND    c.process_status_flag = 'P'
      AND    p.process_status_flag = 'P' )
      UNION
     (SELECT c.rowid
      FROM   qp_interface_list_lines p,qp_interface_list_lines c
      WHERE  p.process_status_flag = 'I'
      AND    c.request_id = p_request_id
      AND    c.price_break_header_ref = p.orig_sys_line_ref
      AND    c.rltd_modifier_grp_type = 'PRICE BREAK'
      AND    c.process_status_flag = 'P'))
      -- Bug 5208480(5208112,4188784) RAVI
      AND NOT EXISTS
         (
          select 1 from qp_list_lines qpll
          where qpil.interface_action_code = 'UPDATE'
          and qpil.orig_sys_line_ref = qpll.orig_sys_line_ref
          and qpll.list_line_id is not null
          and qpil.list_line_id <> qpll.list_line_id
         )
      ;

      write_log( 'Number of PBH child lines picked: '||SQL%ROWCOUNT);

        --ENH Update Functionality RAVI
        /**
        If interface action is update then load all null value interface columns
        with values from corresponding qp table columns
        **/
        -- Bug#5353889 RAVI START
        -- Comment the update as the updates are already done.
        /**
        UPDATE 	qp_interface_list_lines qpil
        SET ( 	accrual_conversion_rate,
                accrual_flag,
                accrual_qty,
                accrual_uom_code,
                arithmetic_operator,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                automatic_flag,
                base_qty,
                base_uom_code,
                benefit_limit,
                benefit_price_list_line_id,
                benefit_qty,
                benefit_uom_code,
                charge_subtype_code,
                charge_type_code,
                comments,
                context,
                continuous_price_break_flag,
                created_by,
            	creation_date,
            	effective_period_uom,
                end_date_active,
                estim_accrual_rate,
                estim_gl_value,
                expiration_date,
                expiration_period_start_date,
                expiration_period_uom,
                generate_using_formula_id,
                include_on_returns_flag,
                incompatibility_grp_code,
                inventory_item_id,
                list_header_id,
                list_line_id,
                list_line_no,
                list_line_type_code,
                list_price,
                list_price_uom_code,
                modifier_level_code,
                net_amount_flag,
                number_effective_periods,
                number_expiration_periods,
                operand,
                organization_id,
                orig_sys_header_ref,
                orig_sys_line_ref,
                override_flag,
                percent_price,
                price_break_header_ref,--change
                price_break_type_code,
                price_by_formula_id,
                pricing_group_sequence,
                pricing_phase_id,
                primary_uom_flag,
                print_on_invoice_flag,
                product_precedence,
                program_application_id,
                program_id,
                program_update_date,
                proration_type_code,
                qualification_ind,
                rebate_transaction_type_code,
                recurring_flag,
                recurring_value,
                related_item_id,
                relationship_type_id,
                reprice_flag,
                revision,
                revision_date,
                revision_reason_code,
                rltd_modifier_grp_type,--change
                start_date_active,
                substitution_attribute,
                substitution_context,
                substitution_value
	    ) = ( select
	    		     decode(qpil.accrual_conversion_rate, null, qpll.accrual_conversion_rate,
                              	 decode(qpil.accrual_conversion_rate,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.accrual_conversion_rate
                                        )
                                 ),
                             decode(qpil.accrual_flag, null, qpll.accrual_flag,
                                 decode(qpil.accrual_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.accrual_flag
                                        )
                                 ),
                             decode(qpil.accrual_qty, null, qpll.accrual_qty,
                                 decode(qpil.accrual_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.accrual_qty
                                        )
                                 ),
                             decode(qpil.accrual_uom_code, null, qpll.accrual_uom_code,
                                 decode(qpil.accrual_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.accrual_uom_code
                                        )
                                 ),
                             decode(qpil.arithmetic_operator, null, qpll.arithmetic_operator,
                                 decode(qpil.arithmetic_operator,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.arithmetic_operator
                                        )
                                 ),
                             decode(qpil.attribute1, null, qpll.attribute1,
                                 decode(qpil.attribute1,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute1
                                        )
                                 ),
                             decode(qpil.attribute10, null, qpll.attribute10,
                                 decode(qpil.attribute10,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute10
                                        )
                                 ),
                             decode(qpil.attribute11, null, qpll.attribute11,
                                 decode(qpil.attribute11,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute11
                                        )
                                 ),
                             decode(qpil.attribute12, null, qpll.attribute12,
                                 decode(qpil.attribute12,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute12
                                        )
                                 ),
                             decode(qpil.attribute13, null, qpll.attribute13,
                                 decode(qpil.attribute13,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute13
                                        )
                                 ),
                             decode(qpil.attribute14, null, qpll.attribute14,
                                 decode(qpil.attribute14,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute14
                                        )
                                 ),
                             decode(qpil.attribute15, null, qpll.attribute15,
                                 decode(qpil.attribute15,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute15
                                        )
                                 ),
                             decode(qpil.attribute2, null, qpll.attribute2,
                                 decode(qpil.attribute2,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute2
                                        )
                                 ),
                             decode(qpil.attribute3, null, qpll.attribute3,
                                 decode(qpil.attribute3,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute3
                                        )
                                 ),
                             decode(qpil.attribute4, null, qpll.attribute4,
                                 decode(qpil.attribute4,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute4
                                        )
                                 ),
                             decode(qpil.attribute5, null, qpll.attribute5,
                                 decode(qpil.attribute5,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute5
                                        )
                                 ),
                             decode(qpil.attribute6, null, qpll.attribute6,
                                 decode(qpil.attribute6,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute6
                                        )
                                 ),
                             decode(qpil.attribute7, null, qpll.attribute7,
                                 decode(qpil.attribute7,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute7
                                        )
                                 ),
                             decode(qpil.attribute8, null, qpll.attribute8,
                                 decode(qpil.attribute8,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute8
                                        )
                                 ),
                             decode(qpil.attribute9, null, qpll.attribute9,
                                 decode(qpil.attribute9,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.attribute9
                                        )
                                 ),
                             decode(qpil.automatic_flag, null, qpll.automatic_flag,
                                 decode(qpil.automatic_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.automatic_flag
                                        )
                                 ),
                             decode(qpil.base_qty, null, qpll.base_qty,
                                 decode(qpil.base_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.base_qty
                                        )
                                 ),
                             decode(qpil.base_uom_code, null, qpll.base_uom_code,
                                 decode(qpil.base_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.base_uom_code
                                        )
                                 ),
                             decode(qpil.benefit_limit, null, qpll.benefit_limit,
                                 decode(qpil.benefit_limit,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_limit
                                        )
                                 ),
                             decode(qpil.benefit_price_list_line_id, null, qpll.benefit_price_list_line_id,
                                 decode(qpil.benefit_price_list_line_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_price_list_line_id
                                        )
                                 ),
                             decode(qpil.benefit_qty, null, qpll.benefit_qty,
                                 decode(qpil.benefit_qty,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.benefit_qty
                                        )
                                 ),
                             decode(qpil.benefit_uom_code, null, qpll.benefit_uom_code,
                                 decode(qpil.benefit_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.benefit_uom_code
                                        )
                                 ),
                             decode(qpil.charge_subtype_code, null, qpll.charge_subtype_code,
                                 decode(qpil.charge_subtype_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.charge_subtype_code
                                        )
                                 ),
                             decode(qpil.charge_type_code, null, qpll.charge_type_code,
                                 decode(qpil.charge_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.charge_type_code
                                        )
                                 ),
                             decode(qpil.comments, null, qpll.comments,
                                 decode(qpil.comments,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.comments
                                        )
                                 ),
                             decode(qpil.context, null, qpll.context,
                                 decode(qpil.context,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.context
                                        )
                                 ),
                             decode(qpil.continuous_price_break_flag, null, qpll.continuous_price_break_flag,
                                 decode(qpil.continuous_price_break_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.continuous_price_break_flag
                                        )
                                 ),
                             decode(qpil.created_by, null, qpll.created_by,
                                 decode(qpil.created_by,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.created_by
                                        )
                                 ),
        		     decode(qpil.creation_date, null, qpll.creation_date,
        		         decode(qpil.creation_date,
        		                QP_BULK_LOADER_PUB.G_NULL_DATE,
        		                null,
        		                qpil.creation_date
        		                )
        		         ),
        		     decode(qpil.effective_period_uom, null, qpll.effective_period_uom,
        		         decode(qpil.effective_period_uom,
        		                QP_BULK_LOADER_PUB.G_NULL_CHAR,
        		                null,
        		                qpil.effective_period_uom
        		                )
        		         ),
                             decode(qpil.end_date_active, null, qpll.end_date_active,
                                 decode(qpil.end_date_active,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.end_date_active
                                        )
                                 ),
                             decode(qpil.estim_accrual_rate, null, qpll.estim_accrual_rate,
                                 decode(qpil.estim_accrual_rate,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.estim_accrual_rate
                                        )
                                 ),
                             decode(qpil.estim_gl_value, null, qpll.estim_gl_value,
                                 decode(qpil.estim_gl_value,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.estim_gl_value
                                        )
                                 ),
                             decode(qpil.expiration_date, null, qpll.expiration_date,
                                 decode(qpil.expiration_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.expiration_date
                                        )
                                 ),
                             decode(qpil.expiration_period_start_date, null, qpll.expiration_period_start_date,
                                 decode(qpil.expiration_period_start_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.expiration_period_start_date
                                        )
                                 ),
                             decode(qpil.expiration_period_uom, null, qpll.expiration_period_uom,
                                 decode(qpil.expiration_period_uom,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.expiration_period_uom
                                        )
                                 ),
                             decode(qpil.generate_using_formula_id, null, qpll.generate_using_formula_id,
                                 decode(qpil.generate_using_formula_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.generate_using_formula_id
                                        )
                                 ),
                             decode(qpil.include_on_returns_flag, null, qpll.include_on_returns_flag,
                                 decode(qpil.include_on_returns_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.include_on_returns_flag
                                        )
                                 ),
                             decode(qpil.incompatibility_grp_code, null, qpll.incompatibility_grp_code,
                                 decode(qpil.incompatibility_grp_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.incompatibility_grp_code
                                        )
                                 ),
                             decode(qpil.inventory_item_id, null, qpll.inventory_item_id,
                                 decode(qpil.inventory_item_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.inventory_item_id
                                        )
                                 ),
                             decode(qpil.list_header_id, null, qpll.list_header_id,
                                 decode(qpil.list_header_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_header_id
                                        )
                                 ),
                             decode(qpil.list_line_id, null, qpll.list_line_id,
                                 decode(qpil.list_line_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_line_id
                                        )
                                 ),
                             decode(qpil.list_line_no, null, qpll.list_line_no,
                                 decode(qpil.list_line_no,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_line_no
                                        )
                                 ),
                             decode(qpil.list_line_type_code, null, qpll.list_line_type_code,
                                 decode(qpil.list_line_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_line_type_code
                                        )
                                 ),
                             decode(qpil.list_price, null, qpll.list_price,
                                 decode(qpil.list_price,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.list_price
                                        )
                                 ),
                             decode(qpil.list_price_uom_code, null, qpll.list_price_uom_code,
                                 decode(qpil.list_price_uom_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.list_price_uom_code
                                        )
                                 ),
                             decode(qpil.modifier_level_code, null, qpll.modifier_level_code,
                                 decode(qpil.modifier_level_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.modifier_level_code
                                        )
                                 ),
                             decode(qpil.net_amount_flag, null, qpll.net_amount_flag,
                                 decode(qpil.net_amount_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.net_amount_flag
                                        )
                                 ),
                             decode(qpil.number_effective_periods, null, qpll.number_effective_periods,
                                 decode(qpil.number_effective_periods,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.number_effective_periods
                                        )
                                 ),
                             decode(qpil.number_expiration_periods, null, qpll.number_expiration_periods,
                                 decode(qpil.number_expiration_periods,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.number_expiration_periods
                                        )
                                 ),
                             decode(qpil.operand, null, qpll.operand,
                                 decode(qpil.operand,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.operand
                                        )
                                 ),
                             decode(qpil.organization_id, null, qpll.organization_id,
                                 decode(qpil.organization_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.organization_id
                                        )
                                 ),
                             decode(qpil.orig_sys_header_ref, null, qpll.orig_sys_header_ref,
                                 decode(qpil.orig_sys_header_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.orig_sys_header_ref
                                        )
                                 ),
                             decode(qpil.orig_sys_line_ref, null, qpll.orig_sys_line_ref,
                                 decode(qpil.orig_sys_line_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.orig_sys_line_ref
                                        )
                                 ),
                             decode(qpil.override_flag, null, qpll.override_flag,
                                 decode(qpil.override_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.override_flag
                                        )
                                 ),
                             decode(qpil.percent_price, null, qpll.percent_price,
                                 decode(qpil.percent_price,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.percent_price
                                        )
                                 ),
                             decode(qpil.price_break_header_ref, null,
                             	        (select pll.orig_sys_line_ref
                                         from qp_list_lines pll, qp_rltd_modifiers rm
                                         where rm.to_rltd_modifier_id = qpll.list_line_id
                                         and rm.from_rltd_modifier_id = pll.list_line_id
                                         and rm.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
                                         ),
                                 decode(qpil.price_break_header_ref,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.price_break_header_ref
                                       )
                                 ),
                             decode(qpil.price_break_type_code, null, qpll.price_break_type_code,
                                 decode(qpil.price_break_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.price_break_type_code
                                        )
                                 ),
                             decode(qpil.price_by_formula_id, null, qpll.price_by_formula_id,
                                 decode(qpil.price_by_formula_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.price_by_formula_id
                                        )
                                 ),
                             decode(qpil.pricing_group_sequence, null, qpll.pricing_group_sequence,
                                 decode(qpil.pricing_group_sequence,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.pricing_group_sequence
                                        )
                                 ),
                             decode(qpil.pricing_phase_id, null, qpll.pricing_phase_id,
                                 decode(qpil.pricing_phase_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.pricing_phase_id
                                        )
                                 ),
                             decode(qpil.primary_uom_flag, null, qpll.primary_uom_flag,
                                 decode(qpil.primary_uom_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.primary_uom_flag
                                        )
                                 ),
                             decode(qpil.print_on_invoice_flag, null, qpll.print_on_invoice_flag,
                                 decode(qpil.print_on_invoice_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.print_on_invoice_flag
                                        )
                                 ),
                             decode(qpil.product_precedence, null, qpll.product_precedence,
                                 decode(qpil.product_precedence,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.product_precedence
                                        )
                                 ),
                             decode(qpil.program_application_id, null, qpll.program_application_id,
                                 decode(qpil.program_application_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.program_application_id
                                        )
                                 ),
                             decode(qpil.program_id, null, qpll.program_id,
                                 decode(qpil.program_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.program_id
                                        )
                                 ),
                             decode(qpil.program_update_date, null, qpll.program_update_date,
                                 decode(qpil.program_update_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.program_update_date
                                        )
                                 ),
                             decode(qpil.proration_type_code, null, qpll.proration_type_code,
                                 decode(qpil.proration_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.proration_type_code
                                        )
                                 ),
                             decode(qpil.qualification_ind, null, qpll.qualification_ind,
                                 decode(qpil.qualification_ind,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.qualification_ind
                                        )
                                 ),
                             decode(qpil.rebate_transaction_type_code, null, qpll.rebate_transaction_type_code,
                                 decode(qpil.rebate_transaction_type_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.rebate_transaction_type_code
                                        )
                                 ),
                             decode(qpil.recurring_flag, null, qpll.recurring_flag,
                                 decode(qpil.recurring_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.recurring_flag
                                        )
                                 ),
                             decode(qpil.recurring_value, null, qpll.recurring_value,
                                 decode(qpil.recurring_value,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.recurring_value
                                        )
                                 ),
                             decode(qpil.related_item_id, null, qpll.related_item_id,
                                 decode(qpil.related_item_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.related_item_id
                                        )
                                 ),
                             decode(qpil.relationship_type_id, null, qpll.relationship_type_id,
                                 decode(qpil.relationship_type_id,
                                        QP_BULK_LOADER_PUB.G_NULL_NUMBER,
                                        null,
                                        qpil.relationship_type_id
                                        )
                                 ),
                             decode(qpil.reprice_flag, null, qpll.reprice_flag,
                                 decode(qpil.reprice_flag,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.reprice_flag
                                        )
                                 ),
                             decode(qpil.revision, null, qpll.revision,
                                 decode(qpil.revision,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.revision
                                        )
                                 ),
                             decode(qpil.revision_date, null, qpll.revision_date,
                                 decode(qpil.revision_date,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.revision_date
                                        )
                                 ),
                             decode(qpil.revision_reason_code, null, qpll.revision_reason_code,
                                 decode(qpil.revision_reason_code,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.revision_reason_code
                                        )
                                 ),
                             decode(qpil.rltd_modifier_grp_type, null,
                                        (select rm.RLTD_MODIFIER_GRP_TYPE
                                         from qp_list_lines pll, qp_rltd_modifiers rm
                                         where rm.to_rltd_modifier_id = qpll.list_line_id
                                         and rm.from_rltd_modifier_id = pll.list_line_id
                                         and rm.RLTD_MODIFIER_GRP_TYPE='PRICE BREAK'
                                         ),
                                 decode(qpil.rltd_modifier_grp_type,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.rltd_modifier_grp_type
                                        )
                                 ),
                             decode(qpil.start_date_active, null, qpll.start_date_active,
                                 decode(qpil.start_date_active,
                                        QP_BULK_LOADER_PUB.G_NULL_DATE,
                                        null,
                                        qpil.start_date_active
                                        )
                                 ),
                             decode(qpil.substitution_attribute, null, qpll.substitution_attribute,
                                 decode(qpil.substitution_attribute,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_attribute
                                        )
                                 ),
                             decode(qpil.substitution_context, null, qpll.substitution_context,
                                 decode(qpil.substitution_context,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_context
                                        )
                                 ),
                             decode(qpil.substitution_value, null, qpll.substitution_value,
                                 decode(qpil.substitution_value,
                                        QP_BULK_LOADER_PUB.G_NULL_CHAR,
                                        null,
                                        qpil.substitution_value
                                        )
                                 )
                   	from 	qp_list_headers qplh,
                        	qp_list_lines qpll
                   	where -- CAUSES FTS AS NO INDEX ON LINE_REF
                   		qpil.orig_sys_line_ref = qpll.orig_sys_line_ref
                   		and qpll.list_header_id = qplh.list_header_id
                   		and qplh.orig_system_header_ref=qpil.orig_sys_header_ref
                   )
              where qpil.request_id = l_request_id
              and   qpil.process_status_flag = 'P'
              and   qpil.interface_action_code = 'UPDATE';
        **/
        -- Bug#5353889 RAVI END

    -- Update Pricing attributes records with request id
    UPDATE qp_interface_pricing_attribs qpip
    SET    qpip.request_id = l_request_id
    WHERE  qpip.rowid IN
    ((SELECT /*+ index(PA  QP_INTERFACE_PRCNG_ATTRIBS_N4)*/ pa.ROWID --7433219
      FROM   qp_interface_list_lines l, qp_interface_pricing_attribs pa
      WHERE  l.request_id = l_request_id
      AND    (pa.request_id = p_request_id or pa.request_id is NULL)
      AND    pa.process_status_flag = 'P'
      AND    l.process_status_flag  = 'P'
      -- Begin Bug No: 6235177
      AND decode(p_process_id, null, pa.process_flag,'Y') = 'Y'
      AND nvl(pa.process_id, 0) = nvl(p_process_id, nvl(pa.process_id, 0))
      AND nvl(pa.process_type, ' ') = nvl(p_process_type, nvl(pa.process_type, ' '))
      -- End Bug No: 6235177
      AND    pa.orig_sys_line_ref = l.orig_sys_line_ref)
      UNION
     (SELECT /*+ index(PA  QP_INTERFACE_PRCNG_ATTRIBS_N4)*/ pa.ROWID --7433219
      FROM   qp_interface_list_lines l, qp_interface_pricing_attribs pa
      WHERE  l.process_status_flag = 'I'
      AND    (pa.request_id = p_request_id or pa.request_id is NULL)
      AND    pa.process_status_flag = 'P'
      -- Begin Bug No: 6235177
      AND   decode(p_process_id, null,pa.process_flag,'Y') = 'Y'
      AND   nvl(pa.process_id,0) = nvl(p_process_id, nvl(pa.process_id,0))
      AND   nvl(pa.process_type,' ') = nvl(p_process_type, nvl(pa.process_type,' '))
      -- End Bug No: 6235177
      AND    pa.orig_sys_line_ref = l.orig_sys_line_ref))
      -- Bug 5208480(5208112,4188784) RAVI
      AND NOT EXISTS
         (
          select 1 from qp_pricing_attributes qppa
          where qpip.interface_action_code = 'UPDATE'
          and qpip.orig_sys_line_ref = qppa.orig_sys_line_ref
          and qppa.list_line_id is not null
          and qpip.list_line_id <> qppa.list_line_id
         )
      ;

  write_log('Number of Pricing Attributes picked: '||sql%rowcount);

        --ENH Update Functionality RAVI
        /**
        If interface action is update then load all null value interface columns
        with values from corresponding qp table columns
        **/
        -- Bug#5353889 RAVI START
        -- Comment the update as the updates are already done.
        /**
        UPDATE 	qp_interface_pricing_attribs qpip
        SET ( 	accumulate_flag,
                attribute_grouping_no,
                attribute1,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                comparison_operator_code,
                context,
                created_by,
                excluder_flag,
                list_header_id,
                list_line_id,
                orig_sys_header_ref,
                orig_sys_line_ref,
                orig_sys_pricing_attr_ref,
                pricing_attr_value_from,
                pricing_attr_value_from_number,
                pricing_attr_value_to,
                pricing_attr_value_to_number,
                pricing_attribute,
                pricing_attribute_context,
                pricing_attribute_datatype,
                pricing_attribute_id,
                pricing_phase_id,
                product_attr_value,
                product_attribute,
                product_attribute_context,
                product_attribute_datatype,
                product_uom_code,
                program_application_id,
                program_id,
                program_update_date,
                qualification_ind
	    ) = ( select
	    		decode(qpip.accumulate_flag, null, qppa.accumulate_flag,
				decode(qpip.accumulate_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.accumulate_flag
				)
			),
	    		decode(qpip.attribute_grouping_no, null, qppa.attribute_grouping_no,
				decode(qpip.attribute_grouping_no,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.attribute_grouping_no
				)
			),
        	        decode(qpip.attribute1, null, qppa.attribute1,
				decode(qpip.attribute1,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute1
				)
			),
                	decode(qpip.attribute10, null, qppa.attribute10,
				decode(qpip.attribute10,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute10
				)
			),
	                decode(qpip.attribute11, null, qppa.attribute11,
				decode(qpip.attribute11,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute11
				)
			),
	                decode(qpip.attribute12, null, qppa.attribute12,
				decode(qpip.attribute12,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute12
				)
			),
	                decode(qpip.attribute13, null, qppa.attribute13,
				decode(qpip.attribute13,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute13
				)
			),
	                decode(qpip.attribute14, null, qppa.attribute14,
				decode(qpip.attribute14,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute14
				)
			),
        	        decode(qpip.attribute15, null, qppa.attribute15,
				decode(qpip.attribute15,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute15
				)
			),
                	decode(qpip.attribute2, null, qppa.attribute2,
				decode(qpip.attribute2,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute2
				)
			),
	                decode(qpip.attribute3, null, qppa.attribute3,
				decode(qpip.attribute3,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute3
				)
			),
        	        decode(qpip.attribute4, null, qppa.attribute4,
				decode(qpip.attribute4,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute4
				)
			),
                	decode(qpip.attribute5, null, qppa.attribute5,
				decode(qpip.attribute5,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute5
				)
			),
                	decode(qpip.attribute6, null, qppa.attribute6,
				decode(qpip.attribute6,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute6
				)
			),
                	decode(qpip.attribute7, null, qppa.attribute7,
				decode(qpip.attribute7,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute7
				)
			),
        	        decode(qpip.attribute8, null, qppa.attribute8,
				decode(qpip.attribute8,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute8
				)
			),
                	decode(qpip.attribute9, null, qppa.attribute9,
				decode(qpip.attribute9,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.attribute9
				)
			),
                	decode(qpip.comparison_operator_code, null, qppa.comparison_operator_code,
				decode(qpip.comparison_operator_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.comparison_operator_code
				)
			),
                	decode(qpip.context, null, qppa.context,
				decode(qpip.context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.context
				)
			),
                	decode(qpip.created_by, null, qppa.created_by,
				decode(qpip.created_by,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.created_by
				)
			),
                	decode(qpip.excluder_flag, null, qppa.excluder_flag,
				decode(qpip.excluder_flag,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.excluder_flag
				)
			),
	                decode(qpip.list_header_id, null, qppa.list_header_id,
				decode(qpip.list_header_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.list_header_id
				)
			),
	                decode(qpip.list_line_id, null, qppa.list_line_id,
				decode(qpip.list_line_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.list_line_id
				)
			),
	                decode(qpip.orig_sys_header_ref, null, qppa.orig_sys_header_ref,
				decode(qpip.orig_sys_header_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_header_ref
				)
			),
	                decode(qpip.orig_sys_line_ref, null, qppa.orig_sys_line_ref,
				decode(qpip.orig_sys_line_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_line_ref
				)
			),
	                decode(qpip.orig_sys_pricing_attr_ref, null, qppa.orig_sys_pricing_attr_ref,
				decode(qpip.orig_sys_pricing_attr_ref,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.orig_sys_pricing_attr_ref
				)
			),
	                decode(qpip.pricing_attr_value_from, null, qppa.pricing_attr_value_from,
				decode(qpip.pricing_attr_value_from,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attr_value_from
				)
			),
	                decode(qpip.pricing_attr_value_from_number, null, qppa.pricing_attr_value_from_number,
				decode(qpip.pricing_attr_value_from_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attr_value_from_number
				)
			),
	                decode(qpip.pricing_attr_value_to, null, qppa.pricing_attr_value_to,
				decode(qpip.pricing_attr_value_to,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attr_value_to
				)
			),
	                decode(qpip.pricing_attr_value_to_number, null, qppa.pricing_attr_value_to_number,
				decode(qpip.pricing_attr_value_to_number,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attr_value_to_number
				)
			),
	                decode(qpip.pricing_attribute, null, qppa.pricing_attribute,
				decode(qpip.pricing_attribute,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attribute
				)
			),
	                decode(qpip.pricing_attribute_context, null, qppa.pricing_attribute_context,
				decode(qpip.pricing_attribute_context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attribute_context
				)
			),
	                decode(qpip.pricing_attribute_datatype, null, qppa.pricing_attribute_datatype,
				decode(qpip.pricing_attribute_datatype,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.pricing_attribute_datatype
				)
			),
	                decode(qpip.pricing_attribute_id, null, qppa.pricing_attribute_id,
				decode(qpip.pricing_attribute_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_attribute_id
				)
			),
	                decode(qpip.pricing_phase_id, null, qppa.pricing_phase_id,
				decode(qpip.pricing_phase_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.pricing_phase_id
				)
			),
	                decode(qpip.product_attr_value, null, qppa.product_attr_value,
				decode(qpip.product_attr_value,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attr_value
				)
			),
	                decode(qpip.product_attribute, null, qppa.product_attribute,
				decode(qpip.product_attribute,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attribute
				)
			),
	                decode(qpip.product_attribute_context, null, qppa.product_attribute_context,
				decode(qpip.product_attribute_context,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attribute_context
				)
			),
	                decode(qpip.product_attribute_datatype, null, qppa.product_attribute_datatype,
				decode(qpip.product_attribute_datatype,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_attribute_datatype
				)
			),
	                decode(qpip.product_uom_code, null, qppa.product_uom_code,
				decode(qpip.product_uom_code,QP_BULK_LOADER_PUB.G_NULL_CHAR,
					null,qpip.product_uom_code
				)
			),
	                decode(qpip.program_application_id, null, qppa.program_application_id,
				decode(qpip.program_application_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.program_application_id
				)
			),
	                decode(qpip.program_id, null, qppa.program_id,
				decode(qpip.program_id,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.program_id
				)
			),
	                decode(qpip.program_update_date, null, qppa.program_update_date,
				decode(qpip.program_update_date,QP_BULK_LOADER_PUB.G_NULL_DATE,
					null,qpip.program_update_date
				)
			),
	                decode(qpip.qualification_ind, null, qppa.qualification_ind,
				decode(qpip.qualification_ind,QP_BULK_LOADER_PUB.G_NULL_NUMBER,
					null,qpip.qualification_ind
				)
			)
                   	from 	qp_pricing_attributes qppa,
                        	qp_list_headers_b qplh
                   	where -- CAUSES FTS AS NO INDEX ON PRICNG_ATTR_REF
                   		qpip.orig_sys_pricing_attr_ref = qppa.orig_sys_pricing_attr_ref
                   		and qppa.list_header_id = qplh.list_header_id
                   		and qplh.orig_system_header_ref=qpip.orig_sys_header_ref
                   )
              where qpip.request_id = l_request_id
              and   qpip.process_status_flag = 'P'
              and   qpip.interface_action_code IN ('UPDATE','DELETE');
	**/
        -- Bug#5353889 RAVI END

  QP_BULK_VALIDATE.Attribute_Line(l_request_id);

  QP_BULK_VALIDATE.Mark_Errored_Interface_Record
	                                  ( p_table_type=>'LINE',
					    p_request_id=>l_request_id);

  QP_BULK_VALIDATE.Mark_Errored_Interface_Record
	                                  ( p_table_type=>'PRICING_ATTRIBS',
					    p_request_id=>l_request_id);

  Process_line(l_request_id,p_process_parent); -- 6028305

  write_log('After Process Line');
/* Commented for bug no 6028305
  Process_pricing_attr(l_request_id);

  write_log('After Process Pricing attribute');
*/
  --check that each line inserted had atleast one null pricing context/attr record
  validate_lines(l_request_id);

/* Commented for bug No  6028305
  --Clean up code
   write_log( 'Process Parent: '|| p_process_parent);
  	 IF p_process_parent = 'N' THEN
	    Delete_Errored_Records_Parents(l_request_id);  --deleteing upto one level
	 END IF;
*/

	   SELECT count(*) INTO l_suc_line
	     FROM qp_interface_list_lines
	    WHERE request_id = l_request_id
	      AND process_status_flag = 'I';

	   SELECT count(*) INTO l_err_line
	     FROM qp_interface_list_lines
	    WHERE request_id = l_request_id
	      AND process_status_flag IS NULL;

	   SELECT count(*) INTO l_suc_pr_attr
	     FROM qp_interface_pricing_attribs
	    WHERE request_id = l_request_id
	      AND process_status_flag = 'I';

	   SELECT count(*) INTO l_err_pr_attr
	     FROM qp_interface_pricing_attribs
	    WHERE request_id = l_request_id
	      AND process_status_flag IS NULL;

	   purge(l_request_id);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Number Of Successfully Processed Lines: '||l_suc_line);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Number Of Errored Lines: '||l_err_line);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Number Of Successfully Processed Pricing Attr: '||l_suc_pr_attr);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Number Of Errored Pricing Attr: '||l_err_pr_attr);
    ERRORS_TO_OUTPUT(l_request_id);

    select hsecs into l_end_time from v$timer;
    write_log( 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time taken for the line process (sec):' ||(l_end_time - l_start_time)/100);

  END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	retcode := 2;
	write_log('Unexpected error '||substr(sqlerrm,1200));
	write_log( ' ');
	oe_debug_pub.add(sqlerrm);
	err_buff := FND_MESSAGE.GET;
     WHEN OTHERS THEN
	retcode := 2;
	write_log('Unexpected error '||substr(sqlerrm,1200));
	write_log( ' ');
	oe_debug_pub.add(sqlerrm);
	err_buff := FND_MESSAGE.GET;

 END LOAD_LISTS;


-- PROCESS HEADER API performs complete processing
-- of header including entity validation and Insert/Update/Delete oprerations


 PROCEDURE PROCESS_HEADER
             (p_request_id   NUMBER)
  IS

  BEGIN

    write_log('Inside Process Header');

    QP_BULK_UTIL.LOAD_INS_HEADER
	             (p_request_id=>p_request_id
		      ,x_header_rec=>G_INS_HEADER_REC);

    write_log('Records loaded for INS:'||G_INS_HEADER_REC.orig_sys_header_ref.count);

    IF G_INS_HEADER_REC.orig_sys_header_ref.count>0 THEN

       QP_BULK_VALIDATE.ENTITY_HEADER(p_header_rec=>G_INS_HEADER_REC);

       QP_BULK_UTIL.Insert_Header(p_header_rec=>G_INS_HEADER_REC);
       QP_BULK_MSG.Save_Message(p_request_id);


           FORALL I IN G_INS_HEADER_REC.orig_sys_header_ref.FIRST..
		    G_INS_HEADER_REC.orig_sys_header_ref.LAST

	   UPDATE qp_interface_list_headers
           SET    process_status_flag = decode(G_INS_HEADER_REC.process_status_flag(I),'P','I',G_INS_HEADER_REC.process_status_flag(I))
	   WHERE  nvl(orig_sys_header_ref,'*') = nvl(G_INS_HEADER_REC.orig_sys_header_ref(I),'*')
             AND request_id=p_request_id; -- Bug No: 6235177

	   write_log('Records Updated with process_status_flag: ' || sql%rowcount);

    END IF;

    QP_BULK_UTIL.LOAD_UDT_HEADER
	             (p_request_id => p_request_id
		     ,x_header_rec => G_UDT_HEADER_REC);

    write_log('Records loaded for UDT:'||G_UDT_HEADER_REC.orig_sys_header_ref.count);

    IF G_UDT_HEADER_REC.orig_sys_header_ref.count>0 THEN

       QP_BULK_VALIDATE.ENTITY_HEADER(p_header_rec=>G_UDT_HEADER_REC);

       QP_BULK_UTIL.Update_Header(p_header_rec=>G_UDT_HEADER_REC);
       QP_BULK_MSG.Save_Message(p_request_id);

       	FORALL I IN G_UDT_HEADER_REC.orig_sys_header_ref.FIRST..
		    G_UDT_HEADER_REC.orig_sys_header_ref.LAST

	   UPDATE qp_interface_list_headers
           SET    process_status_flag = decode(G_UDT_HEADER_REC.process_status_flag(I),'P','I',G_UDT_HEADER_REC.process_status_flag(I))
	   WHERE  nvl(orig_sys_header_ref,'*') = nvl(G_UDT_HEADER_REC.orig_sys_header_ref(I),'*')
             AND request_id = p_request_id; -- Bug No: 6235177

	write_log('Records Updated with process_status_flag:' || sql%rowcount);
    END IF;


    QP_BULK_UTIL.Delete_Header(p_request_id);

    QP_BULK_MSG.Save_Message(p_request_id);

    write_log('Leaving Process Header');
    COMMIT;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_HEADER'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END  PROCESS_HEADER;


PROCEDURE PROCESS_QUALIFIER
              (p_request_id   NUMBER)
IS
   CURSOR C_INS_QUALIFIER IS
     SELECT  q.QUALIFIER_ID
	    ,q.REQUEST_ID
	    ,q.QUALIFIER_GROUPING_NO
            ,q.QUALIFIER_CONTEXT
	    ,q.QUALIFIER_ATTRIBUTE
	    ,q.QUALIFIER_ATTR_VALUE
	    ,q.QUALIFIER_ATTR_VALUE_TO
	    ,q.QUALIFIER_DATATYPE
	    ,q.QUALIFIER_PRECEDENCE
	    ,q.COMPARISON_OPERATOR_CODE
	    ,q.EXCLUDER_FLAG
	    ,q.START_DATE_ACTIVE
	    ,q.END_DATE_ACTIVE
	    ,q.LIST_HEADER_ID
	    ,q.LIST_LINE_ID
	    ,q.QUALIFIER_RULE_ID
	    ,q.CREATED_FROM_RULE_ID
	    ,h.ACTIVE_FLAG
	    ,h.LIST_TYPE_CODE
	    ,q.QUAL_ATTR_VALUE_FROM_NUMBER
	    ,q.QUAL_ATTR_VALUE_TO_NUMBER
	    ,q.QUALIFIER_GROUP_CNT
	    ,q.HEADER_QUALS_EXIST_FLAG
	    ,q.CONTEXT
	    ,q.ATTRIBUTE1
	    ,q.ATTRIBUTE2
	    ,q.ATTRIBUTE3
	    ,q.ATTRIBUTE4
	    ,q.ATTRIBUTE5
	    ,q.ATTRIBUTE6
	    ,q.ATTRIBUTE7
	    ,q.ATTRIBUTE8
	    ,q.ATTRIBUTE9
	    ,q.ATTRIBUTE10
	    ,q.ATTRIBUTE11
	    ,q.ATTRIBUTE12
	    ,q.ATTRIBUTE13
	    ,q.ATTRIBUTE14
	    ,q.ATTRIBUTE15
	    ,q.PROCESS_ID
	    ,q.PROCESS_TYPE
	    ,q.INTERFACE_ACTION_CODE
	    ,q.LOCK_FLAG
	    ,q.PROCESS_FLAG
	    ,q.DELETE_FLAG
	    ,q.PROCESS_STATUS_FLAG
	    ,q.LIST_LINE_NO
	    ,q.CREATED_FROM_RULE
	    ,q.QUALIFIER_RULE
	    ,q.QUALIFIER_ATTRIBUTE_CODE
	    ,q.QUALIFIER_ATTR_VALUE_CODE
	    ,q.QUALIFIER_ATTR_VALUE_TO_CODE
	    ,q.ATTRIBUTE_STATUS
	    ,q.ORIG_SYS_HEADER_REF
	    ,q.ORIG_SYS_QUALIFIER_REF
	    ,q.ORIG_SYS_LINE_REF
            ,q.QUALIFY_HIER_DESCENDENTS_FLAG
       FROM   qp_interface_qualifiers q, qp_interface_list_headers h
      WHERE    q.request_id = p_request_id
       AND    h.request_id = p_request_id    -- bug no 5881528
	AND    h.orig_sys_header_ref = q.orig_sys_header_ref
	AND    q.process_status_flag = 'P'
	AND    h.process_status_flag ='I'
	AND    q.interface_action_code = 'INSERT';

      CURSOR C_UDT_QUALIFIER IS
     SELECT  q.QUALIFIER_ID
	    ,q.REQUEST_ID
	    ,q.QUALIFIER_GROUPING_NO
            ,q.QUALIFIER_CONTEXT
	    ,q.QUALIFIER_ATTRIBUTE
	    ,q.QUALIFIER_ATTR_VALUE
	    ,q.QUALIFIER_ATTR_VALUE_TO
	    ,q.QUALIFIER_DATATYPE
	    ,q.QUALIFIER_PRECEDENCE
	    ,q.COMPARISON_OPERATOR_CODE
	    ,q.EXCLUDER_FLAG
	    ,q.START_DATE_ACTIVE
	    ,q.END_DATE_ACTIVE
	    ,q.LIST_HEADER_ID
	    ,q.LIST_LINE_ID
	    ,q.QUALIFIER_RULE_ID
	    ,q.CREATED_FROM_RULE_ID
	    ,h.ACTIVE_FLAG
	    ,h.LIST_TYPE_CODE
	    ,q.QUAL_ATTR_VALUE_FROM_NUMBER
	    ,q.QUAL_ATTR_VALUE_TO_NUMBER
	    ,q.QUALIFIER_GROUP_CNT
	    ,q.HEADER_QUALS_EXIST_FLAG
	    ,q.CONTEXT
	    ,q.ATTRIBUTE1
	    ,q.ATTRIBUTE2
	    ,q.ATTRIBUTE3
	    ,q.ATTRIBUTE4
	    ,q.ATTRIBUTE5
	    ,q.ATTRIBUTE6
	    ,q.ATTRIBUTE7
	    ,q.ATTRIBUTE8
	    ,q.ATTRIBUTE9
	    ,q.ATTRIBUTE10
	    ,q.ATTRIBUTE11
	    ,q.ATTRIBUTE12
	    ,q.ATTRIBUTE13
	    ,q.ATTRIBUTE14
	    ,q.ATTRIBUTE15
	    ,q.PROCESS_ID
	    ,q.PROCESS_TYPE
	    ,q.INTERFACE_ACTION_CODE
	    ,q.LOCK_FLAG
	    ,q.PROCESS_FLAG
	    ,q.DELETE_FLAG
	    ,q.PROCESS_STATUS_FLAG
	    ,q.LIST_LINE_NO
	    ,q.CREATED_FROM_RULE
	    ,q.QUALIFIER_RULE
	    ,q.QUALIFIER_ATTRIBUTE_CODE
	    ,q.QUALIFIER_ATTR_VALUE_CODE
	    ,q.QUALIFIER_ATTR_VALUE_TO_CODE
	    ,q.ATTRIBUTE_STATUS
	    ,q.ORIG_SYS_HEADER_REF
	    ,q.ORIG_SYS_QUALIFIER_REF
	    ,q.ORIG_SYS_LINE_REF
            ,q.QUALIFY_HIER_DESCENDENTS_FLAG
       FROM   qp_interface_qualifiers q, qp_interface_list_headers h
      WHERE    q.request_id = p_request_id
       AND    h.request_id = p_request_id    -- bug no 5881528
	AND    h.orig_sys_header_ref = q.orig_sys_header_ref
	AND    q.process_status_flag = 'P'
	AND    h.process_status_flag ='I'
	AND    q.interface_action_code = 'UPDATE';

   l_rows NATURAL;
   l_ret_code NUMBER;
   l_err_buf VARCHAR2(30);
   l_hq_count NUMBER;
   l_return_status VARCHAR2(1);

BEGIN
     write_log('Entering process QUalifier');
     l_rows := g_qp_batch_size;

     OPEN C_INS_QUALIFIER;
     LOOP
             G_INS_QUALIFIER_REC.QUALIFIER_ID.delete;
	     G_INS_QUALIFIER_REC.REQUEST_ID.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_GROUPING_NO.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_CONTEXT.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTRIBUTE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_DATATYPE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_PRECEDENCE.delete;
	     G_INS_QUALIFIER_REC.COMPARISON_OPERATOR_CODE.delete;
	     G_INS_QUALIFIER_REC.EXCLUDER_FLAG.delete;
	     G_INS_QUALIFIER_REC.START_DATE_ACTIVE.delete;
	     G_INS_QUALIFIER_REC.END_DATE_ACTIVE.delete;
	     G_INS_QUALIFIER_REC.LIST_HEADER_ID.delete;
	     G_INS_QUALIFIER_REC.LIST_LINE_ID.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_RULE_ID.delete;
	     G_INS_QUALIFIER_REC.CREATED_FROM_RULE_ID.delete;
	     G_INS_QUALIFIER_REC.ACTIVE_FLAG.delete;
	     G_INS_QUALIFIER_REC.LIST_TYPE_CODE.delete;
	     G_INS_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER.delete;
	     G_INS_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_GROUP_CNT.delete;
	     G_INS_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG.delete;
	     G_INS_QUALIFIER_REC.CONTEXT.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE1.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE2.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE3.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE4.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE5.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE6.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE7.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE8.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE9.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE10.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE11.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE12.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE13.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE14.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE15.delete;
	     G_INS_QUALIFIER_REC.PROCESS_ID.delete;
	     G_INS_QUALIFIER_REC.PROCESS_TYPE.delete;
	     G_INS_QUALIFIER_REC.INTERFACE_ACTION_CODE.delete;
	     G_INS_QUALIFIER_REC.LOCK_FLAG.delete;
	     G_INS_QUALIFIER_REC.PROCESS_FLAG.delete;
	     G_INS_QUALIFIER_REC.DELETE_FLAG.delete;
	     G_INS_QUALIFIER_REC.PROCESS_STATUS_FLAG.delete;
	     G_INS_QUALIFIER_REC.LIST_LINE_NO.delete;
	     G_INS_QUALIFIER_REC.CREATED_FROM_RULE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_RULE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTRIBUTE_CODE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_CODE.delete;
	     G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO_CODE.delete;
	     G_INS_QUALIFIER_REC.ATTRIBUTE_STATUS.delete;
	     G_INS_QUALIFIER_REC.ORIG_SYS_HEADER_REF.delete;
	     G_INS_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF.delete;
	     G_INS_QUALIFIER_REC.ORIG_SYS_LINE_REF.delete;
             G_INS_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG.delete;


       FETCH C_INS_QUALIFIER BULK COLLECT
       INTO  G_INS_QUALIFIER_REC.QUALIFIER_ID
	    ,G_INS_QUALIFIER_REC.REQUEST_ID
	    ,G_INS_QUALIFIER_REC.QUALIFIER_GROUPING_NO
	    ,G_INS_QUALIFIER_REC.QUALIFIER_CONTEXT
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTRIBUTE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO
	    ,G_INS_QUALIFIER_REC.QUALIFIER_DATATYPE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_PRECEDENCE
	    ,G_INS_QUALIFIER_REC.COMPARISON_OPERATOR_CODE
	    ,G_INS_QUALIFIER_REC.EXCLUDER_FLAG
	    ,G_INS_QUALIFIER_REC.START_DATE_ACTIVE
	    ,G_INS_QUALIFIER_REC.END_DATE_ACTIVE
	    ,G_INS_QUALIFIER_REC.LIST_HEADER_ID
	    ,G_INS_QUALIFIER_REC.LIST_LINE_ID
	    ,G_INS_QUALIFIER_REC.QUALIFIER_RULE_ID
	    ,G_INS_QUALIFIER_REC.CREATED_FROM_RULE_ID
	    ,G_INS_QUALIFIER_REC.ACTIVE_FLAG
	    ,G_INS_QUALIFIER_REC.LIST_TYPE_CODE
	    ,G_INS_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER
	    ,G_INS_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER
	    ,G_INS_QUALIFIER_REC.QUALIFIER_GROUP_CNT
	    ,G_INS_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG
	    ,G_INS_QUALIFIER_REC.CONTEXT
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE1
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE2
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE3
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE4
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE5
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE6
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE7
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE8
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE9
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE10
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE11
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE12
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE13
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE14
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE15
	    ,G_INS_QUALIFIER_REC.PROCESS_ID
	    ,G_INS_QUALIFIER_REC.PROCESS_TYPE
	    ,G_INS_QUALIFIER_REC.INTERFACE_ACTION_CODE
	    ,G_INS_QUALIFIER_REC.LOCK_FLAG
	    ,G_INS_QUALIFIER_REC.PROCESS_FLAG
	    ,G_INS_QUALIFIER_REC.DELETE_FLAG
	    ,G_INS_QUALIFIER_REC.PROCESS_STATUS_FLAG
	    ,G_INS_QUALIFIER_REC.LIST_LINE_NO
	    ,G_INS_QUALIFIER_REC.CREATED_FROM_RULE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_RULE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTRIBUTE_CODE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_CODE
	    ,G_INS_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO_CODE
	    ,G_INS_QUALIFIER_REC.ATTRIBUTE_STATUS
	    ,G_INS_QUALIFIER_REC.ORIG_SYS_HEADER_REF
	    ,G_INS_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF
	    ,G_INS_QUALIFIER_REC.ORIG_SYS_LINE_REF
            ,G_INS_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG
	    LIMIT l_rows;



           write_log('No of INS Qual records fetched: '
		                  || G_INS_qualifier_rec.process_flag.count);

           IF G_INS_qualifier_rec.orig_sys_qualifier_ref.count >0 Then

            QP_BULK_VALIDATE.ENTITY_QUALIFIER
	                      (p_qualifier_rec=>G_INS_QUALIFIER_REC);

	    QP_BULK_UTIL.Insert_Qualifier(p_qualifier_rec=>G_INS_QUALIFIER_REC);

	    QP_BULK_MSG.SAVE_MESSAGE(p_request_id);

	    --set process_status_flag

	    FORALL I IN G_INS_QUALIFIER_REC.orig_sys_qualifier_ref.FIRST
		     ..G_INS_QUALIFIER_REC.orig_sys_qualifier_ref.LAST
	      UPDATE qp_interface_qualifiers
           	SET    process_status_flag = decode(G_INS_QUALIFIER_REC.process_status_flag(I),'P','I',G_INS_QUALIFIER_REC.process_status_flag(I))
	       WHERE  -- orig_sys_header_ref = G_INS_QUALIFIER_REC.orig_sys_header_ref(I) --commented for bug8359604
		     orig_sys_qualifier_ref = G_INS_QUALIFIER_REC.orig_sys_qualifier_ref(I)
		 AND request_id = p_request_id; --Bug No: 6235177

	    END IF;
	    COMMIT;
	EXIT WHEN C_INS_QUALIFIER%NOTFOUND;

     END LOOP; /*-----End processing insertin records --------*/
     CLOSE C_INS_QUALIFIER;
	   ---------------------- UPDATION ---------------------------------
     OPEN C_UDT_QUALIFIER;
     LOOP

             G_UDT_QUALIFIER_REC.QUALIFIER_ID.delete;
	     G_UDT_QUALIFIER_REC.REQUEST_ID.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_GROUPING_NO.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_CONTEXT.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTRIBUTE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_DATATYPE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_PRECEDENCE.delete;
	     G_UDT_QUALIFIER_REC.COMPARISON_OPERATOR_CODE.delete;
	     G_UDT_QUALIFIER_REC.EXCLUDER_FLAG.delete;
	     G_UDT_QUALIFIER_REC.START_DATE_ACTIVE.delete;
	     G_UDT_QUALIFIER_REC.END_DATE_ACTIVE.delete;
	     G_UDT_QUALIFIER_REC.LIST_HEADER_ID.delete;
	     G_UDT_QUALIFIER_REC.LIST_LINE_ID.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_RULE_ID.delete;
	     G_UDT_QUALIFIER_REC.CREATED_FROM_RULE_ID.delete;
	     G_UDT_QUALIFIER_REC.ACTIVE_FLAG.delete;
	     G_UDT_QUALIFIER_REC.LIST_TYPE_CODE.delete;
	     G_UDT_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER.delete;
	     G_UDT_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_GROUP_CNT.delete;
	     G_UDT_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG.delete;
	     G_UDT_QUALIFIER_REC.CONTEXT.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE1.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE2.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE3.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE4.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE5.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE6.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE7.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE8.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE9.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE10.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE11.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE12.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE13.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE14.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE15.delete;
	     G_UDT_QUALIFIER_REC.PROCESS_ID.delete;
	     G_UDT_QUALIFIER_REC.PROCESS_TYPE.delete;
	     G_UDT_QUALIFIER_REC.INTERFACE_ACTION_CODE.delete;
	     G_UDT_QUALIFIER_REC.LOCK_FLAG.delete;
	     G_UDT_QUALIFIER_REC.PROCESS_FLAG.delete;
	     G_UDT_QUALIFIER_REC.DELETE_FLAG.delete;
	     G_UDT_QUALIFIER_REC.PROCESS_STATUS_FLAG.delete;
	     G_UDT_QUALIFIER_REC.LIST_LINE_NO.delete;
	     G_UDT_QUALIFIER_REC.CREATED_FROM_RULE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_RULE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTRIBUTE_CODE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_CODE.delete;
	     G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO_CODE.delete;
	     G_UDT_QUALIFIER_REC.ATTRIBUTE_STATUS.delete;
	     G_UDT_QUALIFIER_REC.ORIG_SYS_HEADER_REF.delete;
	     G_UDT_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF.delete;
	     G_UDT_QUALIFIER_REC.ORIG_SYS_LINE_REF.delete;
             G_UDT_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG.delete;


       FETCH C_UDT_QUALIFIER BULK COLLECT
       INTO  G_UDT_QUALIFIER_REC.QUALIFIER_ID
	    ,G_UDT_QUALIFIER_REC.REQUEST_ID
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_GROUPING_NO
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_CONTEXT
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTRIBUTE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_DATATYPE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_PRECEDENCE
	    ,G_UDT_QUALIFIER_REC.COMPARISON_OPERATOR_CODE
	    ,G_UDT_QUALIFIER_REC.EXCLUDER_FLAG
	    ,G_UDT_QUALIFIER_REC.START_DATE_ACTIVE
	    ,G_UDT_QUALIFIER_REC.END_DATE_ACTIVE
	    ,G_UDT_QUALIFIER_REC.LIST_HEADER_ID
	    ,G_UDT_QUALIFIER_REC.LIST_LINE_ID
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_RULE_ID
	    ,G_UDT_QUALIFIER_REC.CREATED_FROM_RULE_ID
	    ,G_UDT_QUALIFIER_REC.ACTIVE_FLAG
	    ,G_UDT_QUALIFIER_REC.LIST_TYPE_CODE
	    ,G_UDT_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER
	    ,G_UDT_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_GROUP_CNT
	    ,G_UDT_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG
	    ,G_UDT_QUALIFIER_REC.CONTEXT
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE1
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE2
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE3
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE4
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE5
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE6
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE7
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE8
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE9
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE10
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE11
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE12
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE13
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE14
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE15
	    ,G_UDT_QUALIFIER_REC.PROCESS_ID
	    ,G_UDT_QUALIFIER_REC.PROCESS_TYPE
	    ,G_UDT_QUALIFIER_REC.INTERFACE_ACTION_CODE
	    ,G_UDT_QUALIFIER_REC.LOCK_FLAG
	    ,G_UDT_QUALIFIER_REC.PROCESS_FLAG
	    ,G_UDT_QUALIFIER_REC.DELETE_FLAG
	    ,G_UDT_QUALIFIER_REC.PROCESS_STATUS_FLAG
	    ,G_UDT_QUALIFIER_REC.LIST_LINE_NO
	    ,G_UDT_QUALIFIER_REC.CREATED_FROM_RULE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_RULE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTRIBUTE_CODE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_CODE
	    ,G_UDT_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO_CODE
	    ,G_UDT_QUALIFIER_REC.ATTRIBUTE_STATUS
	    ,G_UDT_QUALIFIER_REC.ORIG_SYS_HEADER_REF
	    ,G_UDT_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF
	    ,G_UDT_QUALIFIER_REC.ORIG_SYS_LINE_REF
            ,G_UDT_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG
	    LIMIT l_rows;

           write_log('No of qual upt records: '
			 || G_UDT_qualifier_rec.process_flag.count);

           IF G_UDT_qualifier_rec.orig_sys_qualifier_ref.count >0 Then

            QP_BULK_VALIDATE.ENTITY_QUALIFIER
	                      (p_qualifier_rec=>G_UDT_QUALIFIER_REC);

	    QP_BULK_UTIL.Update_Qualifier(p_qualifier_rec=>G_UDT_QUALIFIER_REC);

	    QP_BULK_MSG.SAVE_MESSAGE(p_request_id);

	   --set process_status_flag

	   FORALL I IN G_UDT_QUALIFIER_REC.orig_sys_qualifier_ref.FIRST
		     ..G_UDT_QUALIFIER_REC.orig_sys_qualifier_ref.LAST
	   UPDATE qp_interface_qualifiers
           SET    process_status_flag = decode(G_UDT_QUALIFIER_REC.process_status_flag(I),'P','I',G_UDT_QUALIFIER_REC.process_status_flag(I))
	   WHERE  -- orig_sys_header_ref = G_UDT_QUALIFIER_REC.orig_sys_header_ref(I) --Commented for bug8359604
	       orig_sys_qualifier_ref = G_UDT_QUALIFIER_REC.orig_sys_qualifier_ref(I)
	   AND request_id = p_request_id; -- Bug No: 6235177


	   END IF;

           COMMIT;
	   EXIT WHEN C_UDT_QUALIFIER%NOTFOUND;
	   END LOOP;
	   CLOSE C_UDT_QUALIFIER;

      write_log('Done with qualifier insertion and updation');


      QP_BULK_MSG.SAVE_MESSAGE(p_request_id);

      QP_BULK_UTIL.Delete_Qualifier(p_request_id);

      write_log('Existing Process Qualifier');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_QUALIFIER'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_QUALIFIER'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PROCESS_QUALIFIER;


PROCEDURE PROCESS_LINE
          (p_request_id NUMBER,
           p_process_parent varchar2) -- 6028305
IS
  CURSOR C_INS_LINE IS
  SELECT   LIST_LINE_ID
	   ,PROGRAM_APPLICATION_ID
	   ,PROGRAM_ID
	   ,PROGRAM_UPDATE_DATE
	   ,REQUEST_ID
	   ,LIST_HEADER_ID
	   ,LIST_LINE_TYPE_CODE
	   ,START_DATE_ACTIVE
	   ,END_DATE_ACTIVE
	   ,AUTOMATIC_FLAG
	   ,MODIFIER_LEVEL_CODE
	   ,PRICE_BY_FORMULA_ID
	   ,LIST_PRICE
	   ,LIST_PRICE_UOM_CODE
	   ,PRIMARY_UOM_FLAG
	   ,INVENTORY_ITEM_ID
	   ,ORGANIZATION_ID
	   ,RELATED_ITEM_ID
	   ,RELATIONSHIP_TYPE_ID
	   ,SUBSTITUTION_CONTEXT
	   ,SUBSTITUTION_ATTRIBUTE
	   ,SUBSTITUTION_VALUE
	   ,REVISION
	   ,REVISION_DATE
	   ,REVISION_REASON_CODE
	   ,PRICE_BREAK_TYPE_CODE
	   ,PERCENT_PRICE
	   ,NUMBER_EFFECTIVE_PERIODS
	   ,EFFECTIVE_PERIOD_UOM
	   ,ARITHMETIC_OPERATOR
	   ,OPERAND
	   ,OVERRIDE_FLAG
	   ,PRINT_ON_INVOICE_FLAG
	   ,REBATE_TRANSACTION_TYPE_CODE
	   ,BASE_QTY
	   ,BASE_UOM_CODE
	   ,ACCRUAL_QTY
	   ,ACCRUAL_UOM_CODE
	   ,ESTIM_ACCRUAL_RATE
	   ,PROCESS_ID
	   ,PROCESS_TYPE
	   ,INTERFACE_ACTION_CODE
	   ,LOCK_FLAG
	   ,PROCESS_FLAG
	   ,DELETE_FLAG
	   ,PROCESS_STATUS_FLAG
	   ,COMMENTS
	   ,GENERATE_USING_FORMULA_ID
	   ,REPRICE_FLAG
	   ,LIST_LINE_NO
	   ,ESTIM_GL_VALUE
	   ,BENEFIT_PRICE_LIST_LINE_ID
	   ,EXPIRATION_PERIOD_START_DATE
	   ,NUMBER_EXPIRATION_PERIODS
	   ,EXPIRATION_PERIOD_UOM
	   ,EXPIRATION_DATE
	   ,ACCRUAL_FLAG
	   ,PRICING_PHASE_ID
	   ,PRICING_GROUP_SEQUENCE
	   ,INCOMPATIBILITY_GRP_CODE
	   ,PRODUCT_PRECEDENCE
	   ,PRORATION_TYPE_CODE
	   ,ACCRUAL_CONVERSION_RATE
	   ,BENEFIT_QTY
	   ,BENEFIT_UOM_CODE
	   ,RECURRING_FLAG
	   ,BENEFIT_LIMIT
	   ,CHARGE_TYPE_CODE
	   ,CHARGE_SUBTYPE_CODE
	   ,INCLUDE_ON_RETURNS_FLAG
	   ,QUALIFICATION_IND
	   ,CONTEXT
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
	   ,RLTD_MODIFIER_GRP_NO
	   ,RLTD_MODIFIER_GRP_TYPE
	   ,PRICE_BREAK_HEADER_REF
	   ,PRICING_PHASE_NAME
	   ,PRICE_BY_FORMULA
	   ,GENERATE_USING_FORMULA
	   ,ATTRIBUTE_STATUS
	   ,ORIG_SYS_LINE_REF
	   ,ORIG_SYS_HEADER_REF
	   ,RECURRING_VALUE
	   ,NET_AMOUNT_FLAG
           --Bug#5359974 RAVI
           ,CONTINUOUS_PRICE_BREAK_FLAG
FROM   qp_interface_list_lines
WHERE  request_id = p_request_id
AND    process_status_flag = 'P'
AND    interface_action_code='INSERT'
ORDER BY LIST_LINE_TYPE_CODE; --bug 7315191

  CURSOR C_UDT_LINE IS
  SELECT   LIST_LINE_ID
	   ,PROGRAM_APPLICATION_ID
	   ,PROGRAM_ID
	   ,PROGRAM_UPDATE_DATE
	   ,REQUEST_ID
	   ,LIST_HEADER_ID
	   ,LIST_LINE_TYPE_CODE
	   ,START_DATE_ACTIVE
	   ,END_DATE_ACTIVE
	   ,AUTOMATIC_FLAG
	   ,MODIFIER_LEVEL_CODE
	   ,PRICE_BY_FORMULA_ID
	   ,LIST_PRICE
	   ,LIST_PRICE_UOM_CODE
	   ,PRIMARY_UOM_FLAG
	   ,INVENTORY_ITEM_ID
	   ,ORGANIZATION_ID
	   ,RELATED_ITEM_ID
	   ,RELATIONSHIP_TYPE_ID
	   ,SUBSTITUTION_CONTEXT
	   ,SUBSTITUTION_ATTRIBUTE
	   ,SUBSTITUTION_VALUE
	   ,REVISION
	   ,REVISION_DATE
	   ,REVISION_REASON_CODE
	   ,PRICE_BREAK_TYPE_CODE
	   ,PERCENT_PRICE
	   ,NUMBER_EFFECTIVE_PERIODS
	   ,EFFECTIVE_PERIOD_UOM
	   ,ARITHMETIC_OPERATOR
	   ,OPERAND
	   ,OVERRIDE_FLAG
	   ,PRINT_ON_INVOICE_FLAG
	   ,REBATE_TRANSACTION_TYPE_CODE
	   ,BASE_QTY
	   ,BASE_UOM_CODE
	   ,ACCRUAL_QTY
	   ,ACCRUAL_UOM_CODE
	   ,ESTIM_ACCRUAL_RATE
	   ,PROCESS_ID
	   ,PROCESS_TYPE
	   ,INTERFACE_ACTION_CODE
	   ,LOCK_FLAG
	   ,PROCESS_FLAG
	   ,DELETE_FLAG
	   ,PROCESS_STATUS_FLAG
	   ,COMMENTS
	   ,GENERATE_USING_FORMULA_ID
	   ,REPRICE_FLAG
	   ,LIST_LINE_NO
	   ,ESTIM_GL_VALUE
	   ,BENEFIT_PRICE_LIST_LINE_ID
	   ,EXPIRATION_PERIOD_START_DATE
	   ,NUMBER_EXPIRATION_PERIODS
	   ,EXPIRATION_PERIOD_UOM
	   ,EXPIRATION_DATE
	   ,ACCRUAL_FLAG
	   ,PRICING_PHASE_ID
	   ,PRICING_GROUP_SEQUENCE
	   ,INCOMPATIBILITY_GRP_CODE
	   ,PRODUCT_PRECEDENCE
	   ,PRORATION_TYPE_CODE
	   ,ACCRUAL_CONVERSION_RATE
	   ,BENEFIT_QTY
	   ,BENEFIT_UOM_CODE
	   ,RECURRING_FLAG
	   ,BENEFIT_LIMIT
	   ,CHARGE_TYPE_CODE
	   ,CHARGE_SUBTYPE_CODE
	   ,INCLUDE_ON_RETURNS_FLAG
	   ,QUALIFICATION_IND
	   ,CONTEXT
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
	   ,RLTD_MODIFIER_GRP_NO
	   ,RLTD_MODIFIER_GRP_TYPE
	   ,PRICE_BREAK_HEADER_REF
	   ,PRICING_PHASE_NAME
	   ,PRICE_BY_FORMULA
	   ,GENERATE_USING_FORMULA
	   ,ATTRIBUTE_STATUS
	   ,ORIG_SYS_LINE_REF
	   ,ORIG_SYS_HEADER_REF
	   ,RECURRING_VALUE
	   ,NET_AMOUNT_FLAG
           --Bug#5359974 RAVI
           ,CONTINUOUS_PRICE_BREAK_FLAG
FROM   qp_interface_list_lines
WHERE  request_id = p_request_id
AND    process_status_flag = 'P'
AND    interface_action_code='UPDATE';


l_rows NATURAL;
l_rltd_modifiers_id NUMBER;
l_rltd_modifiers_grp_no NUMBER;
l_from_rltd_modifier_id NUMBER;
l_msg_txt VARCHAR2(240);

BEGIN

   write_log('Entering Process Line');
   l_rows := g_qp_batch_size;

   OPEN C_INS_LINE;
   LOOP
                  G_INS_LINE_REC.list_line_id.DELETE;
                  G_INS_LINE_REC.PROGRAM_APPLICATION_ID.DELETE;
		  G_INS_LINE_REC.PROGRAM_ID.delete;
		  G_INS_LINE_REC.PROGRAM_UPDATE_DATE.DELETE;
		  G_INS_LINE_REC.REQUEST_ID.DELETE;
		  G_INS_LINE_REC.LIST_HEADER_ID.DELETE;
		  G_INS_LINE_REC.LIST_LINE_TYPE_CODE.DELETE;
		  G_INS_LINE_REC.START_DATE_ACTIVE.DELETE;
		  G_INS_LINE_REC.END_DATE_ACTIVE.DELETE;
		  G_INS_LINE_REC.AUTOMATIC_FLAG.DELETE;
		  G_INS_LINE_REC.MODIFIER_LEVEL_CODE.DELETE;
		  G_INS_LINE_REC.PRICE_BY_FORMULA_ID.DELETE;
		  G_INS_LINE_REC.LIST_PRICE.DELETE;
		  G_INS_LINE_REC.LIST_PRICE_UOM_CODE.DELETE;
		  G_INS_LINE_REC.PRIMARY_UOM_FLAG.DELETE;
		  G_INS_LINE_REC.INVENTORY_ITEM_ID.DELETE;
		  G_INS_LINE_REC.ORGANIZATION_ID.DELETE;
		  G_INS_LINE_REC.RELATED_ITEM_ID.DELETE;
		  G_INS_LINE_REC.RELATIONSHIP_TYPE_ID.DELETE;
		  G_INS_LINE_REC.SUBSTITUTION_CONTEXT.DELETE;
		  G_INS_LINE_REC.SUBSTITUTION_ATTRIBUTE.DELETE;
		  G_INS_LINE_REC.SUBSTITUTION_VALUE.DELETE;
		  G_INS_LINE_REC.REVISION.DELETE;
		  G_INS_LINE_REC.REVISION_DATE.DELETE;
		  G_INS_LINE_REC.REVISION_REASON_CODE.DELETE;
		  G_INS_LINE_REC.PRICE_BREAK_TYPE_CODE.DELETE;
		  G_INS_LINE_REC.PERCENT_PRICE.DELETE;
		  G_INS_LINE_REC.NUMBER_EFFECTIVE_PERIODS.DELETE;
		  G_INS_LINE_REC.EFFECTIVE_PERIOD_UOM.DELETE;
		  G_INS_LINE_REC.ARITHMETIC_OPERATOR.DELETE;
		  G_INS_LINE_REC.OPERAND.DELETE;
		  G_INS_LINE_REC.OVERRIDE_FLAG.DELETE;
		  G_INS_LINE_REC.PRINT_ON_INVOICE_FLAG.DELETE;
		  G_INS_LINE_REC.REBATE_TRANSACTION_TYPE_CODE.DELETE;
		  G_INS_LINE_REC.BASE_QTY.DELETE;
		  G_INS_LINE_REC.BASE_UOM_CODE.DELETE;
		  G_INS_LINE_REC.ACCRUAL_QTY.DELETE;
		  G_INS_LINE_REC.ACCRUAL_UOM_CODE.DELETE;
		  G_INS_LINE_REC.ESTIM_ACCRUAL_RATE.DELETE;
		  G_INS_LINE_REC.PROCESS_ID.DELETE;
		  G_INS_LINE_REC.PROCESS_TYPE.DELETE;
		  G_INS_LINE_REC.INTERFACE_ACTION_CODE.DELETE;
		  G_INS_LINE_REC.LOCK_FLAG.DELETE;
		  G_INS_LINE_REC.PROCESS_FLAG.DELETE;
		  G_INS_LINE_REC.DELETE_FLAG.DELETE;
		  G_INS_LINE_REC.PROCESS_STATUS_FLAG.DELETE;
		  G_INS_LINE_REC.COMMENTS.DELETE;
		  G_INS_LINE_REC.GENERATE_USING_FORMULA_ID.DELETE;
		  G_INS_LINE_REC.REPRICE_FLAG.DELETE;
		  G_INS_LINE_REC.LIST_LINE_NO.DELETE;
		  G_INS_LINE_REC.ESTIM_GL_VALUE.DELETE;
		  G_INS_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID.DELETE;
		  G_INS_LINE_REC.EXPIRATION_PERIOD_START_DATE.DELETE;
		  G_INS_LINE_REC.NUMBER_EXPIRATION_PERIODS.DELETE;
		  G_INS_LINE_REC.EXPIRATION_PERIOD_UOM.DELETE;
		  G_INS_LINE_REC.EXPIRATION_DATE.DELETE;
		  G_INS_LINE_REC.ACCRUAL_FLAG.DELETE;
		  G_INS_LINE_REC.PRICING_PHASE_ID.DELETE;
		  G_INS_LINE_REC.PRICING_GROUP_SEQUENCE.DELETE;
		  G_INS_LINE_REC.INCOMPATIBILITY_GRP_CODE.DELETE;
		  G_INS_LINE_REC.PRODUCT_PRECEDENCE.DELETE;
		  G_INS_LINE_REC.PRORATION_TYPE_CODE.DELETE;
		  G_INS_LINE_REC.ACCRUAL_CONVERSION_RATE.DELETE;
		  G_INS_LINE_REC.BENEFIT_QTY.DELETE;
		  G_INS_LINE_REC.BENEFIT_UOM_CODE.DELETE;
		  G_INS_LINE_REC.RECURRING_FLAG.DELETE;
		  G_INS_LINE_REC.BENEFIT_LIMIT.DELETE;
		  G_INS_LINE_REC.CHARGE_TYPE_CODE.DELETE;
		  G_INS_LINE_REC.CHARGE_SUBTYPE_CODE.DELETE;
		  G_INS_LINE_REC.INCLUDE_ON_RETURNS_FLAG.DELETE;
		  G_INS_LINE_REC.QUALIFICATION_IND.DELETE;
		  G_INS_LINE_REC.CONTEXT.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE1.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE2.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE3.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE4.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE5.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE6.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE7.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE8.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE9.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE10.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE11.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE12.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE13.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE14.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE15.DELETE;
		  G_INS_LINE_REC.RLTD_MODIFIER_GRP_NO.DELETE;
		  G_INS_LINE_REC.RLTD_MODIFIER_GRP_TYPE.DELETE;
		  G_INS_LINE_REC.PRICE_BREAK_HEADER_REF.DELETE;
		  G_INS_LINE_REC.PRICING_PHASE_NAME.DELETE;
		  G_INS_LINE_REC.PRICE_BY_FORMULA.DELETE;
		  G_INS_LINE_REC.GENERATE_USING_FORMULA.DELETE;
		  G_INS_LINE_REC.ATTRIBUTE_STATUS.DELETE;
		  G_INS_LINE_REC.ORIG_SYS_LINE_REF.DELETE;
		  G_INS_LINE_REC.ORIG_SYS_HEADER_REF.DELETE;
		  G_INS_LINE_REC.RECURRING_VALUE.DELETE;
		  G_INS_LINE_REC.NET_AMOUNT_FLAG.DELETE;
                  --Bug#5359974 RAVI
                  G_INS_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG.DELETE;


      FETCH C_INS_LINE BULK COLLECT
	  INTO    G_INS_LINE_REC.LIST_LINE_ID
		 ,G_INS_LINE_REC.PROGRAM_APPLICATION_ID
		 ,G_INS_LINE_REC.PROGRAM_ID
		 ,G_INS_LINE_REC.PROGRAM_UPDATE_DATE
		 ,G_INS_LINE_REC.REQUEST_ID
		 ,G_INS_LINE_REC.LIST_HEADER_ID
		 ,G_INS_LINE_REC.LIST_LINE_TYPE_CODE
		 ,G_INS_LINE_REC.START_DATE_ACTIVE
		 ,G_INS_LINE_REC.END_DATE_ACTIVE
		 ,G_INS_LINE_REC.AUTOMATIC_FLAG
		 ,G_INS_LINE_REC.MODIFIER_LEVEL_CODE
		 ,G_INS_LINE_REC.PRICE_BY_FORMULA_ID
		 ,G_INS_LINE_REC.LIST_PRICE
		 ,G_INS_LINE_REC.LIST_PRICE_UOM_CODE
		 ,G_INS_LINE_REC.PRIMARY_UOM_FLAG
		 ,G_INS_LINE_REC.INVENTORY_ITEM_ID
		 ,G_INS_LINE_REC.ORGANIZATION_ID
		 ,G_INS_LINE_REC.RELATED_ITEM_ID
		 ,G_INS_LINE_REC.RELATIONSHIP_TYPE_ID
		 ,G_INS_LINE_REC.SUBSTITUTION_CONTEXT
		 ,G_INS_LINE_REC.SUBSTITUTION_ATTRIBUTE
		 ,G_INS_LINE_REC.SUBSTITUTION_VALUE
		 ,G_INS_LINE_REC.REVISION
		 ,G_INS_LINE_REC.REVISION_DATE
		 ,G_INS_LINE_REC.REVISION_REASON_CODE
		 ,G_INS_LINE_REC.PRICE_BREAK_TYPE_CODE
		 ,G_INS_LINE_REC.PERCENT_PRICE
		 ,G_INS_LINE_REC.NUMBER_EFFECTIVE_PERIODS
		 ,G_INS_LINE_REC.EFFECTIVE_PERIOD_UOM
		 ,G_INS_LINE_REC.ARITHMETIC_OPERATOR
		 ,G_INS_LINE_REC.OPERAND
		 ,G_INS_LINE_REC.OVERRIDE_FLAG
		 ,G_INS_LINE_REC.PRINT_ON_INVOICE_FLAG
		 ,G_INS_LINE_REC.REBATE_TRANSACTION_TYPE_CODE
		 ,G_INS_LINE_REC.BASE_QTY
		 ,G_INS_LINE_REC.BASE_UOM_CODE
		 ,G_INS_LINE_REC.ACCRUAL_QTY
		 ,G_INS_LINE_REC.ACCRUAL_UOM_CODE
		 ,G_INS_LINE_REC.ESTIM_ACCRUAL_RATE
		 ,G_INS_LINE_REC.PROCESS_ID
		 ,G_INS_LINE_REC.PROCESS_TYPE
		 ,G_INS_LINE_REC.INTERFACE_ACTION_CODE
		 ,G_INS_LINE_REC.LOCK_FLAG
		 ,G_INS_LINE_REC.PROCESS_FLAG
		 ,G_INS_LINE_REC.DELETE_FLAG
		 ,G_INS_LINE_REC.PROCESS_STATUS_FLAG
		 ,G_INS_LINE_REC.COMMENTS
		 ,G_INS_LINE_REC.GENERATE_USING_FORMULA_ID
		 ,G_INS_LINE_REC.REPRICE_FLAG
		 ,G_INS_LINE_REC.LIST_LINE_NO
		 ,G_INS_LINE_REC.ESTIM_GL_VALUE
		 ,G_INS_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID
		 ,G_INS_LINE_REC.EXPIRATION_PERIOD_START_DATE
		 ,G_INS_LINE_REC.NUMBER_EXPIRATION_PERIODS
		 ,G_INS_LINE_REC.EXPIRATION_PERIOD_UOM
		 ,G_INS_LINE_REC.EXPIRATION_DATE
		 ,G_INS_LINE_REC.ACCRUAL_FLAG
		 ,G_INS_LINE_REC.PRICING_PHASE_ID
		 ,G_INS_LINE_REC.PRICING_GROUP_SEQUENCE
		 ,G_INS_LINE_REC.INCOMPATIBILITY_GRP_CODE
		 ,G_INS_LINE_REC.PRODUCT_PRECEDENCE
		 ,G_INS_LINE_REC.PRORATION_TYPE_CODE
		 ,G_INS_LINE_REC.ACCRUAL_CONVERSION_RATE
		 ,G_INS_LINE_REC.BENEFIT_QTY
		 ,G_INS_LINE_REC.BENEFIT_UOM_CODE
		 ,G_INS_LINE_REC.RECURRING_FLAG
		 ,G_INS_LINE_REC.BENEFIT_LIMIT
		 ,G_INS_LINE_REC.CHARGE_TYPE_CODE
		 ,G_INS_LINE_REC.CHARGE_SUBTYPE_CODE
		 ,G_INS_LINE_REC.INCLUDE_ON_RETURNS_FLAG
		 ,G_INS_LINE_REC.QUALIFICATION_IND
		 ,G_INS_LINE_REC.CONTEXT
		 ,G_INS_LINE_REC.ATTRIBUTE1
		 ,G_INS_LINE_REC.ATTRIBUTE2
		 ,G_INS_LINE_REC.ATTRIBUTE3
		 ,G_INS_LINE_REC.ATTRIBUTE4
		 ,G_INS_LINE_REC.ATTRIBUTE5
		 ,G_INS_LINE_REC.ATTRIBUTE6
		 ,G_INS_LINE_REC.ATTRIBUTE7
		 ,G_INS_LINE_REC.ATTRIBUTE8
		 ,G_INS_LINE_REC.ATTRIBUTE9
		 ,G_INS_LINE_REC.ATTRIBUTE10
		 ,G_INS_LINE_REC.ATTRIBUTE11
		 ,G_INS_LINE_REC.ATTRIBUTE12
		 ,G_INS_LINE_REC.ATTRIBUTE13
		 ,G_INS_LINE_REC.ATTRIBUTE14
		 ,G_INS_LINE_REC.ATTRIBUTE15
		 ,G_INS_LINE_REC.RLTD_MODIFIER_GRP_NO
		 ,G_INS_LINE_REC.RLTD_MODIFIER_GRP_TYPE
		 ,G_INS_LINE_REC.PRICE_BREAK_HEADER_REF
		 ,G_INS_LINE_REC.PRICING_PHASE_NAME
		 ,G_INS_LINE_REC.PRICE_BY_FORMULA
		 ,G_INS_LINE_REC.GENERATE_USING_FORMULA
		 ,G_INS_LINE_REC.ATTRIBUTE_STATUS
		 ,G_INS_LINE_REC.ORIG_SYS_LINE_REF
		 ,G_INS_LINE_REC.ORIG_SYS_HEADER_REF
		 ,G_INS_LINE_REC.RECURRING_VALUE
		 ,G_INS_LINE_REC.NET_AMOUNT_FLAG
                 --Bug#5359974 RAVI
                 ,G_INS_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG
      LIMIT l_rows;

      write_log('Lines Loaded for INS: '||G_INS_LINE_REC.orig_sys_line_ref.count);

      IF G_INS_LINE_REC.orig_sys_line_ref.count>0 THEN

      QP_BULK_VALIDATE.Entity_Line(p_line_rec=>G_INS_LINE_REC);

      QP_BULK_MSG.Save_Message(p_request_id);

      -- 6028305

      if p_process_parent='N' then
        --Invalidate all the valid sibling break lines, in this request
        update qp_interface_list_lines qill1
        set qill1.process_status_flag=null
        where qill1.price_break_header_ref is not null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        --if any sibling of this child line fails validation in this request
        and exists (Select 'Y' from qp_interface_list_lines qill2
        where qill2.process_status_flag is null
        and qill2.request_id=p_request_id
        and qill2.price_break_header_ref=qill1.price_break_header_ref);

         write_log('Inside process_parent Lines Loaded for INS1: '||G_INS_LINE_REC.orig_sys_line_ref.count);
        --Invalidate all the valid price break header lines, in this request
        update qp_interface_list_lines qill1
        set qill1.process_status_flag=null
        where qill1.price_break_header_ref is null
        and qill1.LIST_LINE_TYPE_CODE='PBH'
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        --if any price break qill2 of this header line fails validation in this request
        and exists (Select 'Y' from qp_interface_list_lines qill2
        where qill2.process_status_flag is null
        and qill2.LIST_LINE_TYPE_CODE='PLL'
        and qill2.request_id=p_request_id
        and qill2.price_break_header_ref=qill1.orig_sys_line_ref);

         write_log('Inside process_parent Lines Loaded for INS2: '||G_INS_LINE_REC.orig_sys_line_ref.count);

        end if;




      -- end bug 6028305

      QP_BULK_UTIL.Insert_line(G_INS_LINE_REC);

      --set process_status_flag
	   FORALL I IN G_INS_LINE_REC.orig_sys_line_ref.FIRST
		     ..G_INS_LINE_REC.orig_sys_line_ref.LAST
	   UPDATE qp_interface_list_lines
           SET    process_status_flag = decode(G_INS_LINE_REC.process_status_flag(I),'P', 'I',G_INS_LINE_REC.process_status_flag(I))
	   WHERE  orig_sys_line_ref = G_INS_LINE_REC.orig_sys_line_ref(I)
	   AND    orig_sys_header_ref = G_INS_LINE_REC.orig_sys_header_ref(I)
 	   AND request_id = p_request_id; -- Bug No: 6235177

	   FOR I IN G_INS_LINE_REC.orig_sys_line_ref.FIRST
		    ..G_INS_LINE_REC.orig_sys_line_ref.LAST
	   LOOP

          	 IF G_INS_LINE_REC.price_break_header_ref(I) IS NOT NULL
		 AND G_INS_LINE_REC.rltd_modifier_grp_type(I) IS NOT NULL
		 AND G_INS_LINE_REC.process_status_flag(I) IN ('P', 'I') THEN


		  BEGIN
	           write_log('Inserting relation for: '
				     ||G_INS_LINE_REC.orig_sys_line_ref(I));
		   SELECT list_line_id
		     into l_from_rltd_modifier_id
		     from qp_list_lines
		    where orig_sys_header_ref = G_INS_LINE_REC.orig_sys_header_ref(I)
		     and  orig_sys_line_ref = G_INS_LINE_REC.price_break_header_ref(I);

		   select QP_RLTD_MODIFIERS_S.nextval
		     into l_rltd_modifiers_id
		     from dual;

		   SELECT QP_RLTD_MODIFIER_GRP_NO_S.nextval
		     INTO l_rltd_modifiers_grp_no
		     FROM dual;


	       QP_RLTD_MODIFIER_PVT.Insert_Row(
					         l_rltd_modifiers_id
					       , SYSDATE
					       , FND_GLOBAL.USER_ID
					       , SYSDATE
					       , FND_GLOBAL.USER_ID
					       , FND_GLOBAL.CONC_LOGIN_ID
					       , l_rltd_modifiers_grp_no
					       , l_from_rltd_modifier_id
					       , G_INS_LINE_REC.list_line_id(I)
					       , 'PRICE BREAK'
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       , null
					       );
	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     G_INS_LINE_REC.process_status_flag(I):=NULL;
		     FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_PARENT_PBH_REF');
		     l_msg_txt:= FND_MESSAGE.GET;
		     --Insert msg
		       INSERT INTO QP_INTERFACE_ERRORS
			(error_id,last_update_date, last_updated_by, creation_date,
			 created_by, last_update_login, request_id, program_application_id,
			 program_id, program_update_date, entity_type, table_name, column_name,
		         orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			 orig_sys_pricing_attr_ref,error_message)
		       VALUES
			(qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
			 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
			 NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
			 G_INS_LINE_REC.orig_sys_header_ref(I),G_INS_LINE_REC.orig_sys_line_ref(I),
			 null,null,l_msg_txt);
	       END;
	      END IF;
	   END LOOP;
        -- 6028305 process attributes here
       Process_pricing_attr(p_request_id,p_process_parent);
      END IF;
      COMMIT;
      EXIT WHEN C_INS_LINE%NOTFOUND;
      END LOOP;
      CLOSE C_INS_LINE;

   OPEN C_UDT_LINE;
   LOOP
                  G_UDT_LINE_REC.LIST_LINE_ID.DELETE;
                  G_UDT_LINE_REC.PROGRAM_APPLICATION_ID.DELETE;
		  G_UDT_LINE_REC.PROGRAM_ID.delete;
		  G_UDT_LINE_REC.PROGRAM_UPDATE_DATE.DELETE;
		  G_UDT_LINE_REC.REQUEST_ID.DELETE;
		  G_UDT_LINE_REC.LIST_HEADER_ID.DELETE;
		  G_UDT_LINE_REC.LIST_LINE_TYPE_CODE.DELETE;
		  G_UDT_LINE_REC.START_DATE_ACTIVE.DELETE;
		  G_UDT_LINE_REC.END_DATE_ACTIVE.DELETE;
		  G_UDT_LINE_REC.AUTOMATIC_FLAG.DELETE;
		  G_UDT_LINE_REC.MODIFIER_LEVEL_CODE.DELETE;
		  G_UDT_LINE_REC.PRICE_BY_FORMULA_ID.DELETE;
		  G_UDT_LINE_REC.LIST_PRICE.DELETE;
		  G_UDT_LINE_REC.LIST_PRICE_UOM_CODE.DELETE;
		  G_UDT_LINE_REC.PRIMARY_UOM_FLAG.DELETE;
		  G_UDT_LINE_REC.INVENTORY_ITEM_ID.DELETE;
		  G_UDT_LINE_REC.ORGANIZATION_ID.DELETE;
		  G_UDT_LINE_REC.RELATED_ITEM_ID.DELETE;
		  G_UDT_LINE_REC.RELATIONSHIP_TYPE_ID.DELETE;
		  G_UDT_LINE_REC.SUBSTITUTION_CONTEXT.DELETE;
		  G_UDT_LINE_REC.SUBSTITUTION_ATTRIBUTE.DELETE;
		  G_UDT_LINE_REC.SUBSTITUTION_VALUE.DELETE;
		  G_UDT_LINE_REC.REVISION.DELETE;
		  G_UDT_LINE_REC.REVISION_DATE.DELETE;
		  G_UDT_LINE_REC.REVISION_REASON_CODE.DELETE;
		  G_UDT_LINE_REC.PRICE_BREAK_TYPE_CODE.DELETE;
		  G_UDT_LINE_REC.PERCENT_PRICE.DELETE;
		  G_UDT_LINE_REC.NUMBER_EFFECTIVE_PERIODS.DELETE;
		  G_UDT_LINE_REC.EFFECTIVE_PERIOD_UOM.DELETE;
		  G_UDT_LINE_REC.ARITHMETIC_OPERATOR.DELETE;
		  G_UDT_LINE_REC.OPERAND.DELETE;
		  G_UDT_LINE_REC.OVERRIDE_FLAG.DELETE;
		  G_UDT_LINE_REC.PRINT_ON_INVOICE_FLAG.DELETE;
		  G_UDT_LINE_REC.REBATE_TRANSACTION_TYPE_CODE.DELETE;
		  G_UDT_LINE_REC.BASE_QTY.DELETE;
		  G_UDT_LINE_REC.BASE_UOM_CODE.DELETE;
		  G_UDT_LINE_REC.ACCRUAL_QTY.DELETE;
		  G_UDT_LINE_REC.ACCRUAL_UOM_CODE.DELETE;
		  G_UDT_LINE_REC.ESTIM_ACCRUAL_RATE.DELETE;
		  G_UDT_LINE_REC.PROCESS_ID.DELETE;
		  G_UDT_LINE_REC.PROCESS_TYPE.DELETE;
		  G_UDT_LINE_REC.INTERFACE_ACTION_CODE.DELETE;
		  G_UDT_LINE_REC.LOCK_FLAG.DELETE;
		  G_UDT_LINE_REC.PROCESS_FLAG.DELETE;
		  G_UDT_LINE_REC.DELETE_FLAG.DELETE;
		  G_UDT_LINE_REC.PROCESS_STATUS_FLAG.DELETE;
		  G_UDT_LINE_REC.COMMENTS.DELETE;
		  G_UDT_LINE_REC.GENERATE_USING_FORMULA_ID.DELETE;
		  G_UDT_LINE_REC.REPRICE_FLAG.DELETE;
		  G_UDT_LINE_REC.LIST_LINE_NO.DELETE;
		  G_UDT_LINE_REC.ESTIM_GL_VALUE.DELETE;
		  G_UDT_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID.DELETE;
		  G_UDT_LINE_REC.EXPIRATION_PERIOD_START_DATE.DELETE;
		  G_UDT_LINE_REC.NUMBER_EXPIRATION_PERIODS.DELETE;
		  G_UDT_LINE_REC.EXPIRATION_PERIOD_UOM.DELETE;
		  G_UDT_LINE_REC.EXPIRATION_DATE.DELETE;
		  G_UDT_LINE_REC.ACCRUAL_FLAG.DELETE;
		  G_UDT_LINE_REC.PRICING_PHASE_ID.DELETE;
		  G_UDT_LINE_REC.PRICING_GROUP_SEQUENCE.DELETE;
		  G_UDT_LINE_REC.INCOMPATIBILITY_GRP_CODE.DELETE;
		  G_UDT_LINE_REC.PRODUCT_PRECEDENCE.DELETE;
		  G_UDT_LINE_REC.PRORATION_TYPE_CODE.DELETE;
		  G_UDT_LINE_REC.ACCRUAL_CONVERSION_RATE.DELETE;
		  G_UDT_LINE_REC.BENEFIT_QTY.DELETE;
		  G_UDT_LINE_REC.BENEFIT_UOM_CODE.DELETE;
		  G_UDT_LINE_REC.RECURRING_FLAG.DELETE;
		  G_UDT_LINE_REC.BENEFIT_LIMIT.DELETE;
		  G_UDT_LINE_REC.CHARGE_TYPE_CODE.DELETE;
		  G_UDT_LINE_REC.CHARGE_SUBTYPE_CODE.DELETE;
		  G_UDT_LINE_REC.INCLUDE_ON_RETURNS_FLAG.DELETE;
		  G_UDT_LINE_REC.QUALIFICATION_IND.DELETE;
		  G_UDT_LINE_REC.CONTEXT.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE1.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE2.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE3.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE4.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE5.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE6.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE7.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE8.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE9.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE10.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE11.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE12.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE13.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE14.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE15.DELETE;
		  G_UDT_LINE_REC.RLTD_MODIFIER_GRP_NO.DELETE;
		  G_UDT_LINE_REC.RLTD_MODIFIER_GRP_TYPE.DELETE;
		  G_UDT_LINE_REC.PRICE_BREAK_HEADER_REF.DELETE;
		  G_UDT_LINE_REC.PRICING_PHASE_NAME.DELETE;
		  G_UDT_LINE_REC.PRICE_BY_FORMULA.DELETE;
		  G_UDT_LINE_REC.GENERATE_USING_FORMULA.DELETE;
		  G_UDT_LINE_REC.ATTRIBUTE_STATUS.DELETE;
		  G_UDT_LINE_REC.ORIG_SYS_LINE_REF.DELETE;
		  G_UDT_LINE_REC.ORIG_SYS_HEADER_REF.DELETE;
		  G_UDT_LINE_REC.RECURRING_VALUE.DELETE;
		  G_UDT_LINE_REC.NET_AMOUNT_FLAG.DELETE;
                  --Bug#5359974 RAVI
                  G_UDT_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG.DELETE;


      FETCH C_UDT_LINE BULK COLLECT
	  INTO    G_UDT_LINE_REC.LIST_LINE_ID
		 ,G_UDT_LINE_REC.PROGRAM_APPLICATION_ID
		 ,G_UDT_LINE_REC.PROGRAM_ID
		 ,G_UDT_LINE_REC.PROGRAM_UPDATE_DATE
		 ,G_UDT_LINE_REC.REQUEST_ID
		 ,G_UDT_LINE_REC.LIST_HEADER_ID
		 ,G_UDT_LINE_REC.LIST_LINE_TYPE_CODE
		 ,G_UDT_LINE_REC.START_DATE_ACTIVE
		 ,G_UDT_LINE_REC.END_DATE_ACTIVE
		 ,G_UDT_LINE_REC.AUTOMATIC_FLAG
		 ,G_UDT_LINE_REC.MODIFIER_LEVEL_CODE
		 ,G_UDT_LINE_REC.PRICE_BY_FORMULA_ID
		 ,G_UDT_LINE_REC.LIST_PRICE
		 ,G_UDT_LINE_REC.LIST_PRICE_UOM_CODE
		 ,G_UDT_LINE_REC.PRIMARY_UOM_FLAG
		 ,G_UDT_LINE_REC.INVENTORY_ITEM_ID
		 ,G_UDT_LINE_REC.ORGANIZATION_ID
		 ,G_UDT_LINE_REC.RELATED_ITEM_ID
		 ,G_UDT_LINE_REC.RELATIONSHIP_TYPE_ID
		 ,G_UDT_LINE_REC.SUBSTITUTION_CONTEXT
		 ,G_UDT_LINE_REC.SUBSTITUTION_ATTRIBUTE
		 ,G_UDT_LINE_REC.SUBSTITUTION_VALUE
		 ,G_UDT_LINE_REC.REVISION
		 ,G_UDT_LINE_REC.REVISION_DATE
		 ,G_UDT_LINE_REC.REVISION_REASON_CODE
		 ,G_UDT_LINE_REC.PRICE_BREAK_TYPE_CODE
		 ,G_UDT_LINE_REC.PERCENT_PRICE
		 ,G_UDT_LINE_REC.NUMBER_EFFECTIVE_PERIODS
		 ,G_UDT_LINE_REC.EFFECTIVE_PERIOD_UOM
		 ,G_UDT_LINE_REC.ARITHMETIC_OPERATOR
		 ,G_UDT_LINE_REC.OPERAND
		 ,G_UDT_LINE_REC.OVERRIDE_FLAG
		 ,G_UDT_LINE_REC.PRINT_ON_INVOICE_FLAG
		 ,G_UDT_LINE_REC.REBATE_TRANSACTION_TYPE_CODE
		 ,G_UDT_LINE_REC.BASE_QTY
		 ,G_UDT_LINE_REC.BASE_UOM_CODE
		 ,G_UDT_LINE_REC.ACCRUAL_QTY
		 ,G_UDT_LINE_REC.ACCRUAL_UOM_CODE
		 ,G_UDT_LINE_REC.ESTIM_ACCRUAL_RATE
		 ,G_UDT_LINE_REC.PROCESS_ID
		 ,G_UDT_LINE_REC.PROCESS_TYPE
		 ,G_UDT_LINE_REC.INTERFACE_ACTION_CODE
		 ,G_UDT_LINE_REC.LOCK_FLAG
		 ,G_UDT_LINE_REC.PROCESS_FLAG
		 ,G_UDT_LINE_REC.DELETE_FLAG
		 ,G_UDT_LINE_REC.PROCESS_STATUS_FLAG
		 ,G_UDT_LINE_REC.COMMENTS
		 ,G_UDT_LINE_REC.GENERATE_USING_FORMULA_ID
		 ,G_UDT_LINE_REC.REPRICE_FLAG
		 ,G_UDT_LINE_REC.LIST_LINE_NO
		 ,G_UDT_LINE_REC.ESTIM_GL_VALUE
		 ,G_UDT_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID
		 ,G_UDT_LINE_REC.EXPIRATION_PERIOD_START_DATE
		 ,G_UDT_LINE_REC.NUMBER_EXPIRATION_PERIODS
		 ,G_UDT_LINE_REC.EXPIRATION_PERIOD_UOM
		 ,G_UDT_LINE_REC.EXPIRATION_DATE
		 ,G_UDT_LINE_REC.ACCRUAL_FLAG
		 ,G_UDT_LINE_REC.PRICING_PHASE_ID
		 ,G_UDT_LINE_REC.PRICING_GROUP_SEQUENCE
		 ,G_UDT_LINE_REC.INCOMPATIBILITY_GRP_CODE
		 ,G_UDT_LINE_REC.PRODUCT_PRECEDENCE
		 ,G_UDT_LINE_REC.PRORATION_TYPE_CODE
		 ,G_UDT_LINE_REC.ACCRUAL_CONVERSION_RATE
		 ,G_UDT_LINE_REC.BENEFIT_QTY
		 ,G_UDT_LINE_REC.BENEFIT_UOM_CODE
		 ,G_UDT_LINE_REC.RECURRING_FLAG
		 ,G_UDT_LINE_REC.BENEFIT_LIMIT
		 ,G_UDT_LINE_REC.CHARGE_TYPE_CODE
		 ,G_UDT_LINE_REC.CHARGE_SUBTYPE_CODE
		 ,G_UDT_LINE_REC.INCLUDE_ON_RETURNS_FLAG
		 ,G_UDT_LINE_REC.QUALIFICATION_IND
		 ,G_UDT_LINE_REC.CONTEXT
		 ,G_UDT_LINE_REC.ATTRIBUTE1
		 ,G_UDT_LINE_REC.ATTRIBUTE2
		 ,G_UDT_LINE_REC.ATTRIBUTE3
		 ,G_UDT_LINE_REC.ATTRIBUTE4
		 ,G_UDT_LINE_REC.ATTRIBUTE5
		 ,G_UDT_LINE_REC.ATTRIBUTE6
		 ,G_UDT_LINE_REC.ATTRIBUTE7
		 ,G_UDT_LINE_REC.ATTRIBUTE8
		 ,G_UDT_LINE_REC.ATTRIBUTE9
		 ,G_UDT_LINE_REC.ATTRIBUTE10
		 ,G_UDT_LINE_REC.ATTRIBUTE11
		 ,G_UDT_LINE_REC.ATTRIBUTE12
		 ,G_UDT_LINE_REC.ATTRIBUTE13
		 ,G_UDT_LINE_REC.ATTRIBUTE14
		 ,G_UDT_LINE_REC.ATTRIBUTE15
		 ,G_UDT_LINE_REC.RLTD_MODIFIER_GRP_NO
		 ,G_UDT_LINE_REC.RLTD_MODIFIER_GRP_TYPE
		 ,G_UDT_LINE_REC.PRICE_BREAK_HEADER_REF
		 ,G_UDT_LINE_REC.PRICING_PHASE_NAME
		 ,G_UDT_LINE_REC.PRICE_BY_FORMULA
		 ,G_UDT_LINE_REC.GENERATE_USING_FORMULA
		 ,G_UDT_LINE_REC.ATTRIBUTE_STATUS
		 ,G_UDT_LINE_REC.ORIG_SYS_LINE_REF
		 ,G_UDT_LINE_REC.ORIG_SYS_HEADER_REF
		 ,G_UDT_LINE_REC.RECURRING_VALUE
		 ,G_UDT_LINE_REC.NET_AMOUNT_FLAG
                 --Bug#5359974 RAVI
                 ,G_UDT_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG
      LIMIT l_rows;

      write_log('Lines Loaded for UDT: ' || G_UDT_LINE_REC.orig_sys_line_ref.count);

      IF G_UDT_LINE_REC.orig_sys_line_ref.count>0 THEN

      G_UDT_LINE_REC_OLD:=G_UDT_LINE_REC; -- 6028305

      QP_BULK_VALIDATE.Entity_Line(p_line_rec=>G_UDT_LINE_REC);

      QP_BULK_MSG.Save_Message(p_request_id);

      -- 6028305
        if p_process_parent='N' then
        --Invalidate all the valid sibling break lines, in this request
        update qp_interface_list_lines qill1
        set qill1.process_status_flag=null
        where qill1.price_break_header_ref is not null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        --if any sibling of this child line fails validation in this request
        and exists (Select 'Y' from qp_interface_list_lines qill2
        where qill2.process_status_flag is null
        and qill2.request_id=p_request_id
        and qill2.price_break_header_ref=qill1.price_break_header_ref);


        --Invalidate all the valid price break header lines, in this request
        update qp_interface_list_lines qill1
        set qill1.process_status_flag=null
        where qill1.price_break_header_ref is null
        and qill1.LIST_LINE_TYPE_CODE='PBH'
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        --if any price break qill2 of this header line fails validation in this request
        and exists (Select 'Y' from qp_interface_list_lines qill2
        where qill2.process_status_flag is null
        and qill2.LIST_LINE_TYPE_CODE='PLL'
        and qill2.request_id=p_request_id
        and qill2.price_break_header_ref=qill1.orig_sys_line_ref);
        COMMIT;
        end if;

      QP_BULK_UTIL.Update_line(G_UDT_LINE_REC);


      --set process_status_flag
	   FORALL I IN G_UDT_LINE_REC.orig_sys_line_ref.FIRST
		     ..G_UDT_LINE_REC.orig_sys_line_ref.LAST
	   UPDATE qp_interface_list_lines
           SET    process_status_flag = decode(G_UDT_LINE_REC.process_status_flag(I),'P', 'I',G_UDT_LINE_REC.process_status_flag(I))
	   WHERE  orig_sys_line_ref = G_UDT_LINE_REC.orig_sys_line_ref(I)
	   AND    orig_sys_header_ref = G_UDT_LINE_REC.orig_sys_header_ref(I)
	   AND request_id = p_request_id; -- Bug No: 6235177



      COMMIT;
       -- changes for bug no  6028305
      Process_pricing_attr(p_request_id,p_process_parent);
       -- update the parent back 6028305
       if p_process_parent='N'  then
          QP_BULK_UTIL.UPDATE_LINE_TO_OLD(G_UDT_LINE_REC_OLD);
       end if;

        END IF;

      EXIT WHEN C_UDT_LINE%NOTFOUND;
  END LOOP;
  CLOSE C_UDT_LINE;

  QP_BULK_UTIL.Delete_Line(p_request_id);

  write_log('Existing Process Line');

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--set Process_status_flag

END PROCESS_LINE;

PROCEDURE PROCESS_PRICING_ATTR
          (p_request_id NUMBER,
           p_process_parent varchar2) -- 6028305

IS

   CURSOR C_INS_PRICING_ATTR
   IS
     SELECT   /*+ index(pa QP_INTERFACE_PRCNG_ATTRIBS_N4) */ pa.PRICING_ATTRIBUTE_ID --7433219
	     ,pa.PROGRAM_APPLICATION_ID
	     ,pa.PROGRAM_ID
	     ,pa.PROGRAM_UPDATE_DATE
	     ,pa.REQUEST_ID
	     ,pa.LIST_LINE_ID
	     ,pa.EXCLUDER_FLAG
	     ,pa.ACCUMULATE_FLAG
	     ,pa.PRODUCT_ATTRIBUTE_CONTEXT
	     ,pa.PRODUCT_ATTRIBUTE
	     ,pa.PRODUCT_ATTR_VALUE
	     ,pa.PRODUCT_UOM_CODE
	     ,pa.PRICING_ATTRIBUTE_CONTEXT
	     ,pa.PRICING_ATTRIBUTE
	     ,pa.PRICING_ATTR_VALUE_FROM
	     ,pa.PRICING_ATTR_VALUE_TO
	     ,pa.ATTRIBUTE_GROUPING_NO
	     ,pa.PRODUCT_ATTRIBUTE_DATATYPE
	     ,pa.PRICING_ATTRIBUTE_DATATYPE
	     --,pa.COMPARISON_OPERATOR_CODE--commented for bug 8737735,added line below
	     ,DECODE(pa.PRICING_ATTRIBUTE_CONTEXT,NULL,'BETWEEN',pa.COMPARISON_OPERATOR_CODE)
	     ,pa.LIST_HEADER_ID
	     ,pa.PRICING_PHASE_ID
	     ,pa.QUALIFICATION_IND
	     ,pa.PRICING_ATTR_VALUE_FROM_NUMBER
	     ,pa.PRICING_ATTR_VALUE_TO_NUMBER
	     ,pa.CONTEXT
	     ,pa.ATTRIBUTE1
	     ,pa.ATTRIBUTE2
	     ,pa.ATTRIBUTE3
	     ,pa.ATTRIBUTE4
	     ,pa.ATTRIBUTE5
	     ,pa.ATTRIBUTE6
	     ,pa.ATTRIBUTE7
	     ,pa.ATTRIBUTE8
	     ,pa.ATTRIBUTE9
	     ,pa.ATTRIBUTE10
	     ,pa.ATTRIBUTE11
	     ,pa.ATTRIBUTE12
	     ,pa.ATTRIBUTE13
	     ,pa.ATTRIBUTE14
	     ,pa.ATTRIBUTE15
	     ,pa.PROCESS_ID
	     ,pa.PROCESS_TYPE
	     ,pa.INTERFACE_ACTION_CODE
	     ,pa.LOCK_FLAG
	     ,pa.PROCESS_FLAG
	     ,pa.DELETE_FLAG
	     ,pa.PROCESS_STATUS_FLAG
	     ,pa.PRICE_LIST_LINE_INDEX
	     ,pa.LIST_LINE_NO
	     ,pa.ORIG_SYS_PRICING_ATTR_REF
	     ,pa.PRODUCT_ATTR_CODE
	     ,pa.PRODUCT_ATTR_VAL_DISP
	     ,pa.PRICING_ATTR_CODE
	     ,pa.PRICING_ATTR_VALUE_FROM_DISP
	     ,pa.PRICING_ATTR_VALUE_TO_DISP
	     ,pa.ATTRIBUTE_STATUS
	     ,pa.ORIG_SYS_LINE_REF
	     ,pa.ORIG_SYS_HEADER_REF
       FROM qp_interface_pricing_attribs pa, qp_interface_list_lines l
      WHERE   pa.request_id = p_request_id
       AND   l.request_id = p_request_id    -- bug no 5881528
	AND   l.orig_sys_line_ref = pa.orig_sys_line_ref
	AND   l.process_status_flag = 'I'
	AND   pa.process_status_flag = 'P'
	AND   pa.interface_action_code = 'INSERT';

   CURSOR C_UDT_PRICING_ATTR
   IS
     SELECT   /*+ index(pa QP_INTERFACE_PRCNG_ATTRIBS_N4) */ pa.PRICING_ATTRIBUTE_ID --7433219
	     ,pa.PROGRAM_APPLICATION_ID
	     ,pa.PROGRAM_ID
	     ,pa.PROGRAM_UPDATE_DATE
	     ,pa.REQUEST_ID
	     ,pa.LIST_LINE_ID
	     ,pa.EXCLUDER_FLAG
	     ,pa.ACCUMULATE_FLAG
	     ,pa.PRODUCT_ATTRIBUTE_CONTEXT
	     ,pa.PRODUCT_ATTRIBUTE
	     ,pa.PRODUCT_ATTR_VALUE
	     ,pa.PRODUCT_UOM_CODE
	     ,pa.PRICING_ATTRIBUTE_CONTEXT
	     ,pa.PRICING_ATTRIBUTE
	     ,pa.PRICING_ATTR_VALUE_FROM
	     ,pa.PRICING_ATTR_VALUE_TO
	     ,pa.ATTRIBUTE_GROUPING_NO
	     ,pa.PRODUCT_ATTRIBUTE_DATATYPE
	     ,pa.PRICING_ATTRIBUTE_DATATYPE
	     ,pa.COMPARISON_OPERATOR_CODE
	     ,pa.LIST_HEADER_ID
	     ,pa.PRICING_PHASE_ID
	     ,pa.QUALIFICATION_IND
	     ,pa.PRICING_ATTR_VALUE_FROM_NUMBER
	     ,pa.PRICING_ATTR_VALUE_TO_NUMBER
	     ,pa.CONTEXT
	     ,pa.ATTRIBUTE1
	     ,pa.ATTRIBUTE2
	     ,pa.ATTRIBUTE3
	     ,pa.ATTRIBUTE4
	     ,pa.ATTRIBUTE5
	     ,pa.ATTRIBUTE6
	     ,pa.ATTRIBUTE7
	     ,pa.ATTRIBUTE8
	     ,pa.ATTRIBUTE9
	     ,pa.ATTRIBUTE10
	     ,pa.ATTRIBUTE11
	     ,pa.ATTRIBUTE12
	     ,pa.ATTRIBUTE13
	     ,pa.ATTRIBUTE14
	     ,pa.ATTRIBUTE15
	     ,pa.PROCESS_ID
	     ,pa.PROCESS_TYPE
	     ,pa.INTERFACE_ACTION_CODE
	     ,pa.LOCK_FLAG
	     ,pa.PROCESS_FLAG
	     ,pa.DELETE_FLAG
	     ,pa.PROCESS_STATUS_FLAG
	     ,pa.PRICE_LIST_LINE_INDEX
	     ,pa.LIST_LINE_NO
	     ,pa.ORIG_SYS_PRICING_ATTR_REF
	     ,pa.PRODUCT_ATTR_CODE
	     ,pa.PRODUCT_ATTR_VAL_DISP
	     ,pa.PRICING_ATTR_CODE
	     ,pa.PRICING_ATTR_VALUE_FROM_DISP
	     ,pa.PRICING_ATTR_VALUE_TO_DISP
	     ,pa.ATTRIBUTE_STATUS
	     ,pa.ORIG_SYS_LINE_REF
	     ,pa.ORIG_SYS_HEADER_REF
       FROM qp_interface_pricing_attribs pa, qp_interface_list_lines l
      WHERE   pa.request_id = p_request_id
       AND   l.request_id = p_request_id    -- bug no 5881528
	AND   l.orig_sys_line_ref = pa.orig_sys_line_ref
	AND   l.process_status_flag = 'I'
	AND   pa.process_status_flag = 'P'
	AND   pa.interface_action_code = 'UPDATE';

l_rows NATURAL;

BEGIN
   write_log('Entering Process Pricing Attribute');
   OPEN C_INS_PRICING_ATTR;
   l_rows := g_qp_batch_size;

   LOOP

              G_INS_PRICING_ATTR_REC.pricing_attribute_id.Delete;
   	      G_INS_PRICING_ATTR_REC.PROGRAM_APPLICATION_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.PROGRAM_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.PROGRAM_UPDATE_DATE.DELETE;
	      G_INS_PRICING_ATTR_REC.REQUEST_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.LIST_LINE_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.EXCLUDER_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.ACCUMULATE_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_UOM_CODE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE.DELETE;
	      G_INS_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE.DELETE;
	      G_INS_PRICING_ATTR_REC.LIST_HEADER_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_PHASE_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.QUALIFICATION_IND.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER.DELETE;
	      G_INS_PRICING_ATTR_REC.CONTEXT.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE1.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE2.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE3.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE4.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE5.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE6.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE7.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE8.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE9.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE10.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE11.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE12.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE13.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE14.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE15.DELETE;
	      G_INS_PRICING_ATTR_REC.PROCESS_ID.DELETE;
	      G_INS_PRICING_ATTR_REC.PROCESS_TYPE.DELETE;
	      G_INS_PRICING_ATTR_REC.INTERFACE_ACTION_CODE.DELETE;
	      G_INS_PRICING_ATTR_REC.LOCK_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.PROCESS_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.DELETE_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.PROCESS_STATUS_FLAG.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICE_LIST_LINE_INDEX.DELETE;
	      G_INS_PRICING_ATTR_REC.LIST_LINE_NO.DELETE;
	      G_INS_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_CODE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_VAL_DISP.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_CODE.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_DISP.DELETE;
	      G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_DISP.DELETE;
	      G_INS_PRICING_ATTR_REC.ATTRIBUTE_STATUS.DELETE;
	      G_INS_PRICING_ATTR_REC.ORIG_SYS_LINE_REF.DELETE;
	      G_INS_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF.DELETE;

   FETCH C_INS_PRICING_ATTR BULK COLLECT
       INTO  G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE_ID
	     ,G_INS_PRICING_ATTR_REC.PROGRAM_APPLICATION_ID
	     ,G_INS_PRICING_ATTR_REC.PROGRAM_ID
	     ,G_INS_PRICING_ATTR_REC.PROGRAM_UPDATE_DATE
	     ,G_INS_PRICING_ATTR_REC.REQUEST_ID
	     ,G_INS_PRICING_ATTR_REC.LIST_LINE_ID
	     ,G_INS_PRICING_ATTR_REC.EXCLUDER_FLAG
	     ,G_INS_PRICING_ATTR_REC.ACCUMULATE_FLAG
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_UOM_CODE
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE
	     ,G_INS_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE
	     ,G_INS_PRICING_ATTR_REC.LIST_HEADER_ID
	     ,G_INS_PRICING_ATTR_REC.PRICING_PHASE_ID
	     ,G_INS_PRICING_ATTR_REC.QUALIFICATION_IND
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER
	     ,G_INS_PRICING_ATTR_REC.CONTEXT
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE1
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE2
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE3
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE4
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE5
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE6
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE7
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE8
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE9
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE10
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE11
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE12
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE13
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE14
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE15
	     ,G_INS_PRICING_ATTR_REC.PROCESS_ID
	     ,G_INS_PRICING_ATTR_REC.PROCESS_TYPE
	     ,G_INS_PRICING_ATTR_REC.INTERFACE_ACTION_CODE
	     ,G_INS_PRICING_ATTR_REC.LOCK_FLAG
	     ,G_INS_PRICING_ATTR_REC.PROCESS_FLAG
	     ,G_INS_PRICING_ATTR_REC.DELETE_FLAG
	     ,G_INS_PRICING_ATTR_REC.PROCESS_STATUS_FLAG
	     ,G_INS_PRICING_ATTR_REC.PRICE_LIST_LINE_INDEX
	     ,G_INS_PRICING_ATTR_REC.LIST_LINE_NO
	     ,G_INS_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_CODE
	     ,G_INS_PRICING_ATTR_REC.PRODUCT_ATTR_VAL_DISP
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_CODE
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_DISP
	     ,G_INS_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_DISP
	     ,G_INS_PRICING_ATTR_REC.ATTRIBUTE_STATUS
	     ,G_INS_PRICING_ATTR_REC.ORIG_SYS_LINE_REF
	     ,G_INS_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF

	     LIMIT l_rows;

      write_log('Pricing Attribute loaded for INS: '
			   ||G_INS_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.COUNT);

      IF (G_INS_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.COUNT >0 ) THEN

      QP_BULK_VALIDATE.Entity_pricing_attr(p_pricing_attr_rec=>G_INS_PRICING_ATTR_REC);

      QP_BULK_MSG.Save_Message(p_request_id);


       -- 6028305
      if p_process_parent='N' then

        --if any price break of this header line fails validation in this request
        update qp_interface_pricing_Attribs qill1
        set qill1.process_status_flag=null
        where qill1.PRICING_ATTR_CODE is null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        and exists

        (select 'Y'
        from qp_interface_pricing_Attribs q1,qp_interface_list_lines q2,qp_interface_list_lines q3
        where q1.process_status_flag is null
        and q1.request_id=p_request_id
        and q2.request_id=p_request_id
         and q3.request_id=p_request_id
        and q1.ORIG_SYS_LINE_REF=q2.ORIG_SYS_LINE_REF
        and  q2.price_break_header_ref is not null
        and  q2.price_break_header_ref=q3.orig_sys_line_ref
        and q2.ORIG_SYS_HEADER_REF=q3.ORIG_SYS_HEADER_REF
        and q1.ORIG_SYS_HEADER_REF=q2.ORIG_SYS_HEADER_REF
        and qill1.ORIG_SYS_LINE_REF=q3.ORIG_SYS_LINE_REF);

       -- Deleting all child if the siblings fail
        update qp_interface_pricing_Attribs qill1
        set qill1.process_status_flag=null
        where qill1.PRICING_ATTR_CODE is not null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        and exists
        (select 'Y'
        from qp_interface_pricing_Attribs q1,qp_interface_list_lines q2,qp_interface_list_lines q3
        where q1.process_status_flag is null
        and q1.request_id=p_request_id
        and q2.request_id=p_request_id
        and q3.request_id=p_request_id
        and q1.ORIG_SYS_LINE_REF=q2.ORIG_SYS_LINE_REF
        and  q2.price_break_header_ref is not null
        and  q2.price_break_header_ref=q3.price_break_header_ref
        and q2.ORIG_SYS_HEADER_REF=q3.ORIG_SYS_HEADER_REF
        and q1.ORIG_SYS_HEADER_REF=q2.ORIG_SYS_HEADER_REF
        and qill1.ORIG_SYS_LINE_REF=q3.ORIG_SYS_LINE_REF);


        ---- updating the corresponding list lines
        update qp_interface_list_lines qill
        set process_Status_flag = null
        where qill.request_id=p_request_id
        and qill.process_status_flag is not null
        and exists
        ( select 'Y'
          from qp_interface_pricing_Attribs q1
          where q1.process_status_flag is null
          and q1.request_id=p_request_id
          and q1.ORIG_SYS_HEADER_REF=qill.ORIG_SYS_HEADER_REF
          and q1.ORIG_SYS_LINE_REF=qill.ORIG_SYS_LINE_REF);

        COMMIT;
        end if;

      QP_BULK_UTIL.Insert_pricing_attr(G_INS_PRICING_ATTR_REC);

      --set the process_status_flag
	   FORALL I IN G_INS_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.FIRST
		     ..G_INS_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.LAST
	   UPDATE qp_interface_pricing_attribs
           SET    process_status_flag = decode(G_INS_PRICING_ATTR_REC.process_status_flag(I),'P','I',G_INS_PRICING_ATTR_REC.process_status_flag(I))
	   WHERE  orig_sys_pricing_attr_ref = G_INS_PRICING_ATTR_REC.orig_sys_pricing_attr_ref(I)
	   AND    orig_sys_line_ref = G_INS_PRICING_ATTR_REC.orig_sys_line_ref(I)
	   AND    orig_sys_header_ref = G_INS_PRICING_ATTR_REC.orig_sys_header_ref(I)
	   AND request_id = p_request_id; -- Bug No: 6235177

      END IF;
      COMMIT;
      EXIT WHEN C_INS_PRICING_ATTR%NOTFOUND;
      END LOOP;
      CLOSE C_INS_PRICING_ATTR;

   OPEN C_UDT_PRICING_ATTR;

   LOOP

              G_UDT_PRICING_ATTR_REC.pricing_attribute_id.Delete;
   	      G_UDT_PRICING_ATTR_REC.PROGRAM_APPLICATION_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROGRAM_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROGRAM_UPDATE_DATE.DELETE;
	      G_UDT_PRICING_ATTR_REC.REQUEST_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.LIST_LINE_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.EXCLUDER_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.ACCUMULATE_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_UOM_CODE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE.DELETE;
	      G_UDT_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE.DELETE;
	      G_UDT_PRICING_ATTR_REC.LIST_HEADER_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_PHASE_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.QUALIFICATION_IND.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER.DELETE;
	      G_UDT_PRICING_ATTR_REC.CONTEXT.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE1.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE2.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE3.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE4.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE5.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE6.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE7.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE8.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE9.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE10.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE11.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE12.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE13.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE14.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE15.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROCESS_ID.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROCESS_TYPE.DELETE;
	      G_UDT_PRICING_ATTR_REC.INTERFACE_ACTION_CODE.DELETE;
	      G_UDT_PRICING_ATTR_REC.LOCK_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROCESS_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.DELETE_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.PROCESS_STATUS_FLAG.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICE_LIST_LINE_INDEX.DELETE;
	      G_UDT_PRICING_ATTR_REC.LIST_LINE_NO.DELETE;
	      G_UDT_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_CODE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_VAL_DISP.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_CODE.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_DISP.DELETE;
	      G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_DISP.DELETE;
	      G_UDT_PRICING_ATTR_REC.ATTRIBUTE_STATUS.DELETE;
	      G_UDT_PRICING_ATTR_REC.ORIG_SYS_LINE_REF.DELETE;
	      G_UDT_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF.DELETE;

   FETCH C_UDT_PRICING_ATTR BULK COLLECT
       INTO  G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE_ID
	     ,G_UDT_PRICING_ATTR_REC.PROGRAM_APPLICATION_ID
	     ,G_UDT_PRICING_ATTR_REC.PROGRAM_ID
	     ,G_UDT_PRICING_ATTR_REC.PROGRAM_UPDATE_DATE
	     ,G_UDT_PRICING_ATTR_REC.REQUEST_ID
	     ,G_UDT_PRICING_ATTR_REC.LIST_LINE_ID
	     ,G_UDT_PRICING_ATTR_REC.EXCLUDER_FLAG
	     ,G_UDT_PRICING_ATTR_REC.ACCUMULATE_FLAG
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_UOM_CODE
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE
	     ,G_UDT_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE
	     ,G_UDT_PRICING_ATTR_REC.LIST_HEADER_ID
	     ,G_UDT_PRICING_ATTR_REC.PRICING_PHASE_ID
	     ,G_UDT_PRICING_ATTR_REC.QUALIFICATION_IND
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER
	     ,G_UDT_PRICING_ATTR_REC.CONTEXT
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE1
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE2
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE3
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE4
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE5
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE6
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE7
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE8
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE9
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE10
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE11
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE12
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE13
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE14
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE15
	     ,G_UDT_PRICING_ATTR_REC.PROCESS_ID
	     ,G_UDT_PRICING_ATTR_REC.PROCESS_TYPE
	     ,G_UDT_PRICING_ATTR_REC.INTERFACE_ACTION_CODE
	     ,G_UDT_PRICING_ATTR_REC.LOCK_FLAG
	     ,G_UDT_PRICING_ATTR_REC.PROCESS_FLAG
	     ,G_UDT_PRICING_ATTR_REC.DELETE_FLAG
	     ,G_UDT_PRICING_ATTR_REC.PROCESS_STATUS_FLAG
	     ,G_UDT_PRICING_ATTR_REC.PRICE_LIST_LINE_INDEX
	     ,G_UDT_PRICING_ATTR_REC.LIST_LINE_NO
	     ,G_UDT_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_CODE
	     ,G_UDT_PRICING_ATTR_REC.PRODUCT_ATTR_VAL_DISP
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_CODE
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_DISP
	     ,G_UDT_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_DISP
	     ,G_UDT_PRICING_ATTR_REC.ATTRIBUTE_STATUS
	     ,G_UDT_PRICING_ATTR_REC.ORIG_SYS_LINE_REF
	     ,G_UDT_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF

	     LIMIT l_rows;
      write_log('Pricing Attribute loaded for UDT:'
			   ||G_UDT_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.COUNT);

      IF (G_UDT_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF.COUNT >0 ) THEN

        QP_BULK_VALIDATE.Entity_pricing_attr(p_pricing_attr_rec=>G_UDT_PRICING_ATTR_REC);

        QP_BULK_MSG.Save_Message(p_request_id);

        -- 6028305

         if p_process_parent='N' then

        --if any price break of this header line fails validation in this request
        update qp_interface_pricing_Attribs qill1
        set qill1.process_status_flag=null
        where qill1.PRICING_ATTR_CODE is null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        and exists

        (select 'Y'
        from qp_interface_pricing_Attribs q1,qp_interface_list_lines q2,qp_interface_list_lines q3
        where q1.process_status_flag is null
        and q1.request_id=p_request_id
        and q2.request_id=p_request_id
        and q3.request_id=p_request_id
        and q1.ORIG_SYS_LINE_REF=q2.ORIG_SYS_LINE_REF
        and  q2.price_break_header_ref is not null
        and  q2.price_break_header_ref=q3.orig_sys_line_ref
        and q2.ORIG_SYS_HEADER_REF=q3.ORIG_SYS_HEADER_REF
        and q1.ORIG_SYS_HEADER_REF=q2.ORIG_SYS_HEADER_REF
        and qill1.ORIG_SYS_LINE_REF=q3.ORIG_SYS_LINE_REF);

       write_log( 'Number of attribute lines picked1: '||SQL%ROWCOUNT);
       -- Deleting all child if the siblings fail
        update qp_interface_pricing_Attribs qill1
        set qill1.process_status_flag=null
        where qill1.PRICING_ATTR_CODE is not null
        and qill1.request_id=p_request_id
        and qill1.process_status_flag is not null
        and exists
        (select 'Y'
        from qp_interface_pricing_Attribs q1,qp_interface_list_lines q2,qp_interface_list_lines q3
        where q1.process_status_flag is null
        and q1.request_id=p_request_id
        and q2.request_id=p_request_id
        and q3.request_id=p_request_id
        and q1.ORIG_SYS_LINE_REF=q2.ORIG_SYS_LINE_REF
        and  q2.price_break_header_ref is not null
        and  q2.price_break_header_ref=q3.price_break_header_ref
        and q2.ORIG_SYS_HEADER_REF=q3.ORIG_SYS_HEADER_REF
        and q1.ORIG_SYS_HEADER_REF=q2.ORIG_SYS_HEADER_REF
        and qill1.ORIG_SYS_LINE_REF=q3.ORIG_SYS_LINE_REF);

write_log( 'Number of attribute lines picked1: '||SQL%ROWCOUNT);
        ---- updating the corresponding list lines
        update qp_interface_list_lines qill
        set process_Status_flag = null
        where qill.request_id=p_request_id
        and qill.process_status_flag is not null
        and exists
        ( select 'Y'
          from qp_interface_pricing_Attribs q1
          where q1.process_status_flag is null
          and q1.request_id=p_request_id
          and q1.ORIG_SYS_HEADER_REF=qill.ORIG_SYS_HEADER_REF
          and q1.ORIG_SYS_LINE_REF=qill.ORIG_SYS_LINE_REF);

write_log( 'Number of attribute lines picked1: '||SQL%ROWCOUNT);
        commit;
        end if;

        QP_BULK_UTIL.Update_pricing_attr(G_UDT_PRICING_ATTR_REC);

      --set the process_status_flag
	   FORALL I IN G_UDT_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.FIRST
		     ..G_UDT_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.LAST
	   UPDATE qp_interface_pricing_attribs
           SET    process_status_flag = decode(G_UDT_PRICING_ATTR_REC.process_status_flag(I),'P','I',G_UDT_PRICING_ATTR_REC.process_status_flag(I))
	   WHERE  orig_sys_pricing_attr_ref = G_UDT_PRICING_ATTR_REC.orig_sys_pricing_attr_ref(I)
	   AND    orig_sys_line_ref = G_UDT_PRICING_ATTR_REC.orig_sys_line_ref(I)
	   AND    orig_sys_header_ref = G_UDT_PRICING_ATTR_REC.orig_sys_header_ref(I)
	   AND request_id = p_request_id; --Bug No: 6235177

      END IF;
      COMMIT;
      EXIT WHEN C_UDT_PRICING_ATTR%NOTFOUND;
      END LOOP;
      CLOSE C_UDT_PRICING_ATTR;

       Post_cleanup_Line(p_request_id);  --delete all the errored records

       QP_BULK_UTIL.Delete_Pricing_Attr(p_request_id);

       write_log('Leaving Process Pricing Attribute');
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCESS_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PROCESS_PRICING_ATTR;

PROCEDURE POST_CLEANUP
          (p_request_id NUMBER)
IS
   BEGIN
      write_log('Entering POST_CLEANUP');

      Delete from qp_list_headers_tl
	 where list_header_id IN
	 (Select b.list_header_id
	    from qp_list_headers_b b, qp_interface_list_headers h
           where h.request_id = p_request_id
 	     and b.orig_system_header_ref=h.orig_sys_header_ref
	     and h.process_status_flag  IS NULL
	     and h.interface_action_code = 'INSERT'
          -- 6028305
         AND NOT EXISTS(
              select 1 from qp_list_headers qplh
              where h.interface_action_code = 'INSERT'
              and qplh.orig_system_header_ref=h.orig_sys_header_ref));

      Delete from qp_list_headers_b
	 where orig_system_header_ref IN
	 (Select orig_sys_header_ref
	    from qp_interface_list_headers h
           where h.request_id = p_request_id
	     and h.process_status_flag  IS NULL
	     and h.interface_action_code = 'INSERT'
           -- 6028305
         AND NOT EXISTS(
              select 1 from qp_list_headers qplh
              where h.interface_action_code = 'INSERT'
              and qplh.orig_system_header_ref=h.orig_sys_header_ref));

      Delete from qp_qualifiers
	where rowid IN
       (Select   q.rowid
    	  from   qp_interface_qualifiers iq, qp_qualifiers q
	  where  iq.request_id = p_request_id
       and   q.request_id= p_request_id -- changes made by rassharm 6028305
  	   and   iq.process_status_flag IS NULL
	   and   iq.interface_action_code = 'INSERT'
	   and   iq.orig_sys_qualifier_ref = q.orig_sys_qualifier_ref
	   and   iq.orig_sys_header_ref = q.orig_sys_header_ref);

    write_log('Leaving POST_CLEANUP');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE POST_CLEANUP:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE POST_CLEANUP:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END POST_CLEANUP;

PROCEDURE POST_CLEANUP_LINE
          (p_request_id NUMBER)
IS

   BEGIN

      -- To delete only those record which where inserted even after error.
      write_log('Entering POST_CLEANUP_LINE');

      Delete from qp_rltd_modifiers
       where  from_rltd_modifier_id IN
       (select l.list_line_id
	  from qp_list_lines l, qp_interface_list_lines il
	 where il.request_id = p_request_id
       and  l.request_id = p_request_id -- changes made by rassharm 6028305
	   and il.process_status_flag  IS NULL
	   and il.interface_action_code ='INSERT'
	   and il.orig_sys_header_ref = l.orig_sys_header_ref
	   and il.orig_sys_line_ref = l.orig_sys_line_ref);


       Delete from qp_rltd_modifiers
       where  to_rltd_modifier_id IN
       (select l.list_line_id
	  from qp_list_lines l, qp_interface_list_lines il
	 where il.request_id = p_request_id
       and  l.request_id = p_request_id -- changes made by rassharm 6028305
	   and il.process_status_flag  IS NULL
	   and il.interface_action_code ='INSERT'
	   and il.orig_sys_header_ref = l.orig_sys_header_ref
	   and il.orig_sys_line_ref = l.orig_sys_line_ref);

      Delete from qp_pricing_attributes
	 where pricing_attribute_id IN
         (Select pa.pricing_attribute_id
	  from   qp_pricing_attributes pa, qp_interface_pricing_attribs ipa
	  where  ipa.request_id = p_request_id
       and   pa.request_id = p_request_id -- changes made by rassharm 6028305
	   and   ipa.process_status_flag IS NULL
	   and   ipa.interface_action_code ='INSERT'
	   and   ipa.orig_sys_pricing_attr_ref =  pa.orig_sys_pricing_attr_ref
	   and   ipa.orig_sys_line_ref =  pa.orig_sys_line_ref
	   and   ipa.orig_sys_header_ref =  pa.orig_sys_header_ref
	   and   ipa.interface_action_code = 'INSERT');


      Delete from qp_list_lines
       where list_line_id IN
       (select l.list_line_id
	  from qp_list_lines l, qp_interface_list_lines il
	 where il.request_id = p_request_id
       and  l.request_id = p_request_id -- changes made by rassharm 6028305
	   and il.process_status_flag  IS NULL
	   and il.interface_action_code ='INSERT'
	   and il.orig_sys_header_ref = l.orig_sys_header_ref
	   and il.orig_sys_line_ref = l.orig_sys_line_ref);

    write_log('Leaving POST_CLEANUP_LINE');

   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE POST_CLEANUP_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE POST_CLEANUP_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END POST_CLEANUP_LINE;

PROCEDURE VALIDATE_LINES
          (p_request_id NUMBER)
IS
   cursor c_invalid_lines is
     select l.list_line_id,               -- price list lines
	    l.orig_sys_line_ref,
	    l.orig_sys_header_ref
       from qp_list_lines l
      where l.request_id = p_request_id
	and not exists (select  'x' from qp_rltd_modifiers
			where  to_rltd_modifier_id = l.list_line_id)
	and not exists  (select 'x' from qp_pricing_attributes pa
			 where l.list_line_id = pa.list_line_id
			   and pa.pricing_attribute_context is null
			   and pa.pricing_attribute is null
			   and pa.pricing_attr_value_from is null
			   and pa.pricing_attr_value_to is null)
       union
       select l.list_line_id,             -- price break child line
	    l.orig_sys_line_ref,
	    l.orig_sys_header_ref
       from qp_list_lines l
      where l.request_id = p_request_id
	and  exists (select  'x' from qp_rltd_modifiers
			where  to_rltd_modifier_id = l.list_line_id)
	and not exists  (select 'x' from qp_pricing_attributes pa
			 where l.list_line_id = pa.list_line_id
			   and pa.pricing_attribute_context is not null
			   and pa.pricing_attribute is not null
			   and (pa.pricing_attr_value_from is not null
			    or  pa.pricing_attr_value_to is not null))
	union
       select l.list_line_id,             -- price break child line
	    l.orig_sys_line_ref,
	    l.orig_sys_header_ref
       from qp_list_lines l
      where l.request_id = p_request_id
        AND l.list_line_type_code ='PBH'
	and not exists(select pl.list_line_id
			from qp_list_lines pl, qp_rltd_modifiers rltd
			where rltd.from_rltd_modifier_id = l.list_line_id
			and pl.list_line_id = rltd.to_rltd_modifier_id);

l_list_line_id_tbl QP_BULK_LOADER_PUB.num_type;
l_orig_sys_line_ref_tbl QP_BULK_LOADER_PUB.char50_type;
l_orig_sys_header_ref_tbl QP_BULK_LOADER_PUB.char50_type;
l_msg_txt VARCHAR2(2000);

BEGIN

 open c_invalid_lines;
 fetch c_invalid_lines
    bulk collect into
    l_list_line_id_tbl,
    l_orig_sys_line_ref_tbl,
    l_orig_sys_header_ref_tbl;
 close c_invalid_lines;

 write_log('Entering validate line');

 IF l_orig_sys_line_ref_tbl.count>0 THEN

  write_log('Number of invalid lines: '|| l_orig_sys_line_ref_tbl.count);

  FORALL I in  l_orig_sys_line_ref_tbl.first..l_orig_sys_line_ref_tbl.last
   UPDATE qp_interface_list_lines
      SET process_status_flag = NULL
    WHERE orig_sys_header_ref = l_orig_sys_header_ref_tbl(I)
      AND orig_sys_line_ref = l_orig_sys_line_ref_tbl(I)
      AND request_id = p_request_id; --Bug No: 6235177

 FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
   DELETE FROM qp_pricing_attributes
    WHERE list_line_id = l_list_line_id_tbl(I);

 FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
   DELETE FROM qp_list_lines
    WHERE list_line_id = l_list_line_id_tbl(I);

 FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
   DELETE FROM qp_rltd_modifiers
    WHERE to_rltd_modifier_id = l_list_line_id_tbl(I);

 -- Price break child lines and its attributes
  FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
      DELETE FROM qp_list_lines
       WHERE list_line_id IN
       (SELECT to_rltd_modifier_id
	  FROM qp_rltd_modifiers
	 WHERE from_rltd_modifier_id = l_list_line_id_tbl(I));

   FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
       DELETE FROM qp_pricing_attributes
       WHERE list_line_id IN
       (SELECT to_rltd_modifier_id
	  FROM qp_rltd_modifiers
	 WHERE from_rltd_modifier_id = l_list_line_id_tbl(I));

    FORALL I in l_list_line_id_tbl.first..l_list_line_id_tbl.last
       DELETE FROM QP_RLTD_MODIFIERS
	WHERE from_rltd_modifier_id = l_list_line_id_tbl(I);


 FND_MESSAGE.SET_NAME('QP', 'PR_LINE_REQ_PROD_ATTR');
 l_msg_txt := FND_MESSAGE.GET;

 FORALL I in  l_orig_sys_line_ref_tbl.first..l_orig_sys_line_ref_tbl.last
  INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
			orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref,error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES', NULL,
	     null,l_orig_sys_line_ref_tbl(I),null,null,l_msg_txt);

 write_log('Leaving Validate_Lines');

 END IF;
    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE VALIDATE_LINES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE VALIDATE_LINES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END VALIDATE_LINES;


PROCEDURE Delete_errored_records_parents
          (p_request_id NUMBER)
IS

 CURSOR c_pricing_attr IS
 SELECT orig_sys_pricing_attr_ref,
	orig_sys_line_ref,
	orig_sys_header_ref
   FROM qp_interface_pricing_attribs
  WHERE request_id = p_request_id
    AND process_status_flag IS NULL;

 CURSOR c_pbh_child_line IS
 SELECT orig_sys_line_ref,
	orig_sys_header_ref,
	price_break_header_ref
   FROM qp_interface_list_lines
  WHERE request_id = p_request_id
    AND process_status_flag IS NULL
    AND price_break_header_ref IS NOT NULL;


l_exist  NUMBER;
l_parent_id NUMBER;

BEGIN

   write_log( 'Entering Delete errored records parents');
   --delete list lines for a pricing attribute failure
   FOR l_pricing_attr_rec IN c_pricing_attr
   LOOP
      BEGIN

	   DELETE FROM QP_PRICING_ATTRIBUTES
	   WHERE  list_line_id IN
	    (SELECT r.to_rltd_modifier_id
	       FROM qp_rltd_modifiers r, qp_list_lines l
	      WHERE l.orig_sys_line_ref = l_pricing_attr_rec.orig_sys_line_ref
	      AND   l.orig_sys_header_ref = l_pricing_attr_rec.orig_sys_header_ref
	      AND   l.list_line_id = r.from_rltd_modifier_id);

	   DELETE FROM QP_LIST_LINES
	   WHERE  list_line_id IN
	    (SELECT r.to_rltd_modifier_id
	       FROM qp_rltd_modifiers r, qp_list_lines l
	      WHERE l.orig_sys_line_ref = l_pricing_attr_rec.orig_sys_line_ref
	      AND   l.orig_sys_header_ref = l_pricing_attr_rec.orig_sys_header_ref
	      AND   l.list_line_id = r.from_rltd_modifier_id);

	   DELETE FROM QP_RLTD_MODIFIERS
	    WHERE from_rltd_modifier_id IN
	    (SELECT list_line_id FROM QP_LIST_LINES l
	      WHERE l.orig_sys_line_ref = l_pricing_attr_rec.orig_sys_line_ref
		AND   l.orig_sys_header_ref = l_pricing_attr_rec.orig_sys_header_ref);

	   DELETE FROM QP_PRICING_ATTRIBUTES
	    WHERE orig_sys_line_ref = l_pricing_attr_rec.orig_sys_line_ref
	      AND orig_sys_header_ref = l_pricing_attr_rec.orig_sys_header_ref;

	   DELETE FROM QP_LIST_LINES
	    WHERE orig_sys_line_ref = l_pricing_attr_rec.orig_sys_line_ref
	      AND orig_sys_header_ref = l_pricing_attr_rec.orig_sys_header_ref;

    END;

   END LOOP;

   FOR l_pbh_cline_rec IN c_pbh_child_line
   LOOP
	DELETE FROM QP_PRICING_ATTRIBUTES
	  WHERE list_line_id IN
	  (SELECT to_rltd_modifier_id
	     FROM QP_RLTD_MODIFIERS r, QP_LIST_LINES l
	    WHERE  l.orig_sys_line_ref = l_pbh_cline_rec.price_break_header_ref
	      AND  l.orig_sys_header_ref = l_pbh_cline_rec.orig_sys_header_ref
	      AND l.list_line_id = r.from_rltd_modifier_id);

	DELETE FROM QP_LIST_LINES
	  WHERE list_line_id IN
	  (SELECT to_rltd_modifier_id
	     FROM QP_RLTD_MODIFIERS r, QP_LIST_LINES l
	    WHERE  l.orig_sys_line_ref = l_pbh_cline_rec.price_break_header_ref
	      AND  l.orig_sys_header_ref = l_pbh_cline_rec.orig_sys_header_ref
	      AND l.list_line_id = r.from_rltd_modifier_id);

        DELETE FROM QP_PRICING_ATTRIBUTES
	 WHERE list_line_id IN
	 (SELECT list_line_id
	    FROM QP_LIST_LINES
	   WHERE orig_sys_line_ref =  l_pbh_cline_rec.orig_sys_line_ref
	     AND orig_sys_header_ref =  l_pbh_cline_rec.orig_sys_header_ref);

	DELETE FROM QP_LIST_LINES
	 WHERE list_line_id IN
	 (SELECT list_line_id
	    FROM QP_LIST_LINES
	   WHERE orig_sys_line_ref =  l_pbh_cline_rec.orig_sys_line_ref
	     AND orig_sys_header_ref =  l_pbh_cline_rec.orig_sys_header_ref);

	DELETE FROM QP_RLTD_MODIFIERS
	 WHERE from_rltd_modifier_id IN
	 (SELECT list_line_id
	    FROM QP_LIST_LINES
	   WHERE orig_sys_line_ref =  l_pbh_cline_rec.orig_sys_line_ref
	     AND orig_sys_header_ref =  l_pbh_cline_rec.orig_sys_header_ref);

   END LOOP;
   write_log('Leaving Delete errored records parent');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log(
			 'UNEXCPECTED ERROR IN PROCEDURE DELETE_ERRORED_RECORDS_PARENTS:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log(
			 'UNEXCPECTED ERROR IN PROCEDURE DELETE_ERRORED_RECORDS_PARENTS:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_errored_records_parents;

PROCEDURE ERRORS_TO_OUTPUT
          (p_request_id NUMBER)
IS

 CURSOR c_errors IS
 SELECT request_id,
	entity_type,
	table_name,
	orig_sys_header_ref,
	orig_sys_line_ref,
	orig_sys_pricing_attr_ref,
	orig_sys_qualifier_ref,
	error_message
 from QP_INTERFACE_ERRORS
 WHERE request_id = p_request_id;

 l_request_id				    NUMBER;
 l_ENTITY_TYPE                              VARCHAR2(30);
 l_TABLE_NAME                               VARCHAR2(30);
 l_COLUMN_NAME                              VARCHAR2(80);
 l_ERROR_MESSAGE                            VARCHAR2(240);
 l_ORIG_SYS_LINE_REF                        VARCHAR2(50);
 l_ORIG_SYS_PRICING_ATTR_REF                VARCHAR2(50);
 l_ORIG_SYS_HEADER_REF                      VARCHAR2(50);
 l_ORIG_SYS_QUALIFIER_REF                   VARCHAR2(50);

BEGIN
      fnd_file.put_line(FND_FILE.OUTPUT,'');
      fnd_file.put_line(FND_FILE.OUTPUT,'Error Details');
      fnd_file.put_line(FND_FILE.OUTPUT,'');
      OPEN c_errors;
      LOOP
        FETCH 	c_errors
         INTO 	l_request_id,
		l_entity_type,
		l_table_name,
		l_orig_sys_header_ref,
		l_orig_sys_line_ref,
		l_orig_sys_pricing_attr_ref,
		l_orig_sys_qualifier_ref,
		l_error_message;

         EXIT WHEN c_errors%NOTFOUND;
	 if l_table_name = 'QP_INTERFACE_LIST_HEADERS' then
	     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_request_id)
						||'/'||l_entity_type
						||'/'||l_table_name
						||'/'||l_orig_sys_header_ref
						||' '||l_error_message);
	 elsif l_table_name = 'QP_INTERFACE_LIST_LINES' then
	     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_request_id)
						||'/'||l_entity_type
						||'/'||l_table_name
						||'/'||l_orig_sys_header_ref
						||'/'||l_orig_sys_line_ref
						||' '||l_error_message);
	 elsif l_table_name = 'QP_INTERFACE_LIST_QUALIFIERS' then
	     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_request_id)
						||'/'||l_entity_type
						||'/'||l_table_name
						||'/'||l_orig_sys_header_ref
						||'/'||l_orig_sys_qualifier_ref
						||' '||l_error_message);
	 elsif l_table_name = 'QP_INTERFACE_LIST_PRICING_ATTRIBS' then
	     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_request_id)
						||'/'||l_entity_type
						||'/'||l_table_name
						||'/'||l_orig_sys_header_ref
						||'/'||l_orig_sys_line_ref
						||'/'||l_orig_sys_pricing_attr_ref
						||' '||l_error_message);
	 else
	     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_request_id)
						||'/'||l_entity_type
						||'/'||l_table_name
						||'/'||l_orig_sys_header_ref
						||'/'||l_orig_sys_qualifier_ref
						||'/'||l_orig_sys_line_ref
						||'/'||l_orig_sys_pricing_attr_ref
						||' '||l_error_message);

	 end if;
         fnd_file.put_line(FND_FILE.OUTPUT,'');
      END LOOP;
END;

PROCEDURE PURGE
          (p_request_id NUMBER)
IS
   BEGIN
        write_log('Entering Purging');
	DELETE FROM qp_interface_pricing_attribs
	 WHERE request_id = p_request_id
	   AND process_status_flag = 'I';

	DELETE FROM qp_interface_list_lines
	 WHERE request_id = p_request_id
	   AND process_status_flag = 'I';

	DELETE FROM qp_interface_qualifiers
	 WHERE request_id = p_request_id
	   AND process_status_flag = 'I';

	DELETE FROM qp_interface_list_headers
	 WHERE request_id = p_request_id
	   AND process_status_flag = 'I';

      write_log('Leaving Purging');

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE PURGE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       write_log( 'UNEXCPECTED ERROR IN PROCEDURE PURGE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PURGE;

--Basic_Pricing_Condition
FUNCTION Get_QP_Status RETURN VARCHAR2 IS
BEGIN
   IF G_QP_STATUS IS NULL THEN
       IF FND_GLOBAL.RESP_APPL_ID = 714 THEN
	-- If the calling application is FTE then treat QP installation status
	-- as fully installed.
	    G_QP_STATUS := 'I';
       ELSE
	-- Get the QP installation status
	   G_QP_STATUS :=  QP_UTIL.GET_QP_STATUS;
       END IF;
   END IF;

   RETURN G_QP_STATUS;

END;

PROCEDURE CLEAN_UP_CODE (l_request_id number)
IS
     l_suc_head NUMBER;
     l_err_head NUMBER;
     l_suc_qual NUMBER;
     l_err_qual NUMBER;
Begin

	 write_log( 'Complete...');


	   Select count(*) into l_suc_head
	     from qp_interface_list_headers
	    where request_id = l_request_id
	      and process_status_flag = 'I';

	   Select count(*) into l_err_head
	     from qp_interface_list_headers
	    where request_id = l_request_id
	      and process_status_flag IS NULL;

	   Select count(*) into l_suc_qual
	     from qp_interface_qualifiers
	    where request_id = l_request_id
	      and process_status_flag = 'I';

	   Select count(*) into l_err_qual
	     from qp_interface_qualifiers
	    where request_id = l_request_id
	      and process_status_flag IS NULL;

	  purge(l_request_id);

	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Number Of succesfully Processed Headers: '||l_suc_head);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Number Of Errored Headers: '||l_err_head);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Number Of succesfully Processed Qualifiers: '||l_suc_qual);
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Number Of Errored Qualifiers: '||l_err_qual);
	 ERRORS_TO_OUTPUT(l_request_id);
END;

PROCEDURE write_log(log_text VARCHAR2)
IS
BEGIN
	IF G_QP_DEBUG = 'Y' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG, log_text);
	END IF;
END;

END QP_BULK_LOADER_PUB;

/
