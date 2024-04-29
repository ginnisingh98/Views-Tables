--------------------------------------------------------
--  DDL for Package Body EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_STANDARD" AS
/* $Header: EDRSTNDB.pls 120.11.12000000.1 2007/01/18 05:55:36 appldev ship $ */

PROCEDURE PSIG_STATUS
	(
	p_event 	in	    varchar2,
	p_event_key	in          varchar2,
        P_status        out NOCOPY  varchar2
	) IS
BEGIN

     --Bug 3468810: start
     edr_ctx_pkg.set_secure_attr;
     --Bug 3468810: end

     --Bug 4565450: start
     select PSIG_STATUS into p_status
     from edr_psig_documents
     where EVENT_NAME=p_event
     and  EVENT_KEY=p_event_key
     and  PSIG_TIMESTAMP =
      (select MAX(PSIG_TIMESTAMP)
        from edr_psig_documents
        where EVENT_NAME=p_event
        and  EVENT_KEY=p_event_key
        and rownum < 2);
     --Bug 4565450: end

     --Bug 3468810: start
     --unset the secure context now.
     edr_ctx_pkg.unset_secure_attr;
     --Bug 3468810: end
 exception
   when no_data_found then
     p_status:=NULL;
   when others then
      p_status:='SQLERROR';

END PSIG_STATUS;

/* signature Requirement. This Procedure returns signature requireemnt for a given event.
   The status is 'Yes' */

PROCEDURE PSIG_REQUIRED
	(
	 p_event      in          varchar2,
	 p_event_key  in          varchar2,
       P_status     out NOCOPY  boolean
	) IS
  l_event_status varchar2(100);
  l_sub_status varchar2(100);
  l_sub_guid varchar2(4000);
  evt wf_event_t;
  l_application_id number;
  l_application_code varchar2(32);
  l_return_status varchar2(32);
  l_application_name varchar2(240);
  l_ame_transaction_Type varchar2(240);
  l_transaction_name varchar2(240);
  l_ruleids   ame_util.idList;
  l_rulenames ame_util.stringList;
  l_rulevalues EDR_STANDARD.ameruleinputvalues;
-- Bug 5167817 : start
--  approverList     ame_util.approversTable;
  approverList     EDR_UTILITIES.approvers_Table;
  approvalProcessCompleteYN ame_util.charType;
  itemClasses ame_util.stringList;
  itemIndexes ame_util.idList;
  itemIds ame_util.stringList;
  itemSources ame_util.longStringList;
  ruleIndexes ame_util.idList;
  sourceTypes ame_util.stringList;
-- Bug 5167817 : end

  l_esign_required varchar2(1);
  l_eRecord_required varchar2(1);
  CURSOR GET_EVT_SUBSCRIPTION_DETAILS IS
     select b.guid,A.status,b.status
     from
       wf_events a, wf_event_subscriptions b
     where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
       and b.STATUS = 'ENABLED'
	 --Bug No 4912782- Start
	 and b.source_type = 'LOCAL'
	 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	 --Bug No 4912782- End
  l_no_enabled_eres_sub NUMBER;
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
BEGIN

  --Bug 4074173 : start
  l_esign_required :='N';
  l_eRecord_required :='N';
  --Bug 4074173 : end

      /* Add a Savepoint to Rollback after the work is complete Bug Fix 3208296*/
      SAVEPOINT PSIG_REQUIRED;
      /* End of Fix Bug Fix 3208296 */
     /* We will code this once AMe API's are in place */
     p_status:=false;
     /*check if Profile value is enabled */
      if (fnd_profile.value('EDR_ERES_ENABLED') = 'Y') then
         /*check if event and subscritptions are Enabled */
    --
    -- Start Bug Fix 3078516
    -- Verify is more than one active ERES subscriptions are present
    --
        select count(*)  INTO l_no_enabled_eres_sub
        from
          wf_events a, wf_event_subscriptions b
        where a.GUID = b.EVENT_FILTER_GUID
          and a.name = p_event
          and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
          and b.STATUS = 'ENABLED'
	    --Bug No 4912782- Start
	    and b.source_type = 'LOCAL'
	    and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	    --Bug No 4912782- End
        IF l_no_enabled_eres_sub > 1 THEN
           RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
        ELSE
          OPEN GET_EVT_SUBSCRIPTION_DETAILS;
          FETCH GET_EVT_SUBSCRIPTION_DETAILS INTO l_sub_guid,l_Event_status,l_sub_status;
          CLOSE GET_EVT_SUBSCRIPTION_DETAILS;
        END IF;
    --
    -- End Bug Fix 3078516
    --

            IF l_event_status='ENABLED' and l_sub_status='ENABLED' then
               /*check if any AMe stuff is available */
               wf_event_t.initialize(evt);
               evt.setSendDate(sysdate);
               evt.setEventName(p_event);
               evt.setEventKey(p_event_key);
               -- Bug 5639849 : Starts
               -- No need to load all subscription parameters, just get
               -- ame_transaction_type using edr API.
               -- l_return_status:=wf_rule.setParametersIntoParameterList(l_sub_guid,evt);

               -- IF l_return_status='SUCCESS' THEN
                  /* Check for User Defined Parameters,
                    contains AME transactions Type
                    If Parameters are not specified, Assume Event name to be AME transaction Type

                   */
                   l_ame_transaction_type 	:= NVL(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE',l_sub_guid),
                                                       evt.getEventName( ));
               -- Bug 5639849 : Ends
                   /* AME Processing */
                   /* Select APPLICATION_ID of the Event. This is required by AME. Assumption made here
                      is OWNER_TAG will always be set to application Short Name*/

              	 SELECT application_id,APPLICATION_SHORT_NAME into l_application_id,l_application_code
             	 FROM FND_APPLICATION
                   WHERE APPLICATION_SHORT_NAME in (SELECT OWNER_TAG from WF_EVENTS
                                                  WHERE NAME=evt.getEventName( ));

        		 /* AME Enhancement Code. Determine if singature is need or not and also get approvers  */

      		 /* This Code should be uncommented when the SSWA AME forms move to opmeres */
                 -- Bug 5167817 : start
          	     /*  AME_API.GETAPPROVERSANDRULES3
          	                (	APPLICATIONIDIN    => l_application_Id,
				      TRANSACTIONIDIN    => evt.getEventKey( ),
				      TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName( )),
				      APPROVERSOUT       => approverList,
				      RULEIDSOUT         => l_ruleids,
				      RULEDESCRIPTIONSOUT=> l_rulenames
              		      );
                  */
                --Bug 5287504: Start
                BEGIN
		  AME_API2.GETALLAPPROVERS6
                  (
                        APPLICATIONIDIN    => l_application_Id,
                        TRANSACTIONIDIN    => evt.getEventKey(),
                        TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName()),
                        approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                        APPROVERSOUT       => approverList,
                        itemIndexesOut => itemIndexes,
                        itemClassesOut => itemClasses,
                        itemIdsOut => itemIds,
                        itemSourcesOut => itemSources,
                        ruleIndexesOut => ruleIndexes,
                        sourceTypesOut => sourceTypes,
                        RULEIDSOUT         => l_ruleids,
                        RULEDESCRIPTIONSOUT=> l_rulenames
                   );
                 EXCEPTION
                   WHEN OTHERS THEN
                     FND_MESSAGE.SET_NAME('EDR','EDR_AME_SETUP_ERR');
                     FND_MESSAGE.SET_TOKEN('TXN_TYPE',nvl(l_ame_transaction_type,evt.getEventName()));
                     FND_MESSAGE.SET_TOKEN('ERR_MSG',sqlerrm);
                     APP_EXCEPTION.RAISE_EXCEPTION;
                 END;
                 --Bug 5287504: End


                -- Bug 5167817 : end
         	        wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','AME API Called. Total Approver '||approverlist.count );

                	  select application_name into l_application_name
                	  from ame_Calling_Apps
                	  where
                 	        FND_APPLICATION_ID=l_application_id and
                  	  TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,evt.getEventName( ))
                  	  --Bug 4652277: Start
                  	  --and end_Date is null;
                  	  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
                  	  --Bug 4652277: End

             	  if approverList.count > 0 then

              	       for i in 1..l_ruleids.count loop
               	          wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Rule_id: '||l_ruleids(i)||' Rule '||l_rulenames(i));

			  -- Bug 3214495 : Start

                 	          EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES( transactiontypeid => NVL(l_ame_transaction_type,evt.getEventName( )),
                  	        		                      ameruleid =>l_ruleids(i),
                   		       		                      amerulename=>l_rulenames(i),
                    		      		                      ameruleinputvalues=>l_rulevalues);
                           -- Bug 3214495 : End
                        	 wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Total Input Values '||l_rulevalues.count );
                        	    if l_rulevalues.count > 0 then
                        	       for i in 1..l_rulevalues.count loop
                         	         if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then
                          	           if ( l_esign_required='N' and l_rulevalues(i).input_value ='Y') then
                           	             l_esign_required:= l_rulevalues(i).input_value;
                            	            end if;
                             		 elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then
                                            if ( l_erecord_required='N' and l_rulevalues(i).input_value ='Y') then
                                              l_erecord_required:= l_rulevalues(i).input_value;
                                            end if;
                                         end if;
                                        end loop;
                                    end if;
                         END LOOP;
                    END IF;
         		  wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Signature Required :'||l_esign_required);
		        wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','eRecord Required   :'||l_erecord_required);
         	        IF (l_esign_required='Y') THEN
                        p_status:=true;
                    END IF;
                END IF;
           -- Bug 5639849 : Starts
           -- Comment the If l_return status statement
           -- END IF;
           -- Bug 5639849 : Ends
              END IF;
      --
      -- Following statement clears all lock aquired by this session
      -- This is modified as part of bug fix 2639210

      --
                   ROLLBACK TO PSIG_REQUIRED;

EXCEPTION
   WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
     p_status:=false;
     ROLLBACK TO PSIG_REQUIRED;
     FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRP_ERR');
     fnd_message.set_token( 'EVENT', p_event);
     RAISE;
   WHEN OTHERS THEN
     p_status:=false;
     ROLLBACK TO PSIG_REQUIRED;
     FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
     FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_STANDARD');
     FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','PSIG_REQUIRED');
     RAISE;
END PSIG_REQUIRED;

/* eRecord Requirement. This Procedure returns signature requirement for a given event.
   The status is 'true' or 'false' */

PROCEDURE EREC_REQUIRED
	(
	p_event 	 in     varchar2,
	p_event_key	 in     varchar2,
        P_status     out NOCOPY boolean
	) IS

  l_event_status varchar2(100);
  l_sub_status varchar2(100);
  l_sub_guid varchar2(4000);

  evt wf_event_t;
  l_application_id number;
  l_application_code varchar2(32);
  l_return_status varchar2(32);
  l_application_name varchar2(240);
  l_ame_transaction_Type varchar2(240);
  l_transaction_name varchar2(240);
  l_ruleids   ame_util.idList;
  l_rulenames ame_util.stringList;
  l_rulevalues EDR_STANDARD.ameruleinputvalues;

-- Bug 5167817 : start
--  approverList     ame_util.approversTable;
   approverList     EDR_UTILITIES.approvers_Table;
   approvalProcessCompleteYN ame_util.charType;
   itemClasses ame_util.stringList;
   itemIndexes ame_util.idList;
   itemIds ame_util.stringList;
   itemSources ame_util.longStringList;
   ruleIndexes ame_util.idList;
   sourceTypes ame_util.stringList;
  -- Bug 5167817 : end

  l_esign_required varchar2(1);
  l_eRecord_required varchar2(1);

  CURSOR GET_EVT_SUBSCRIPTION_DETAILS IS
     select b.guid,A.status,b.status
     from
       wf_events a, wf_event_subscriptions b
     where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
       and b.STATUS = 'ENABLED'
	 --Bug No 4912782- Start
	 and b.source_type = 'LOCAL'
	 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	 --Bug No 4912782- End

  l_no_enabled_eres_sub NUMBER;
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
BEGIN

  --Bug 4074173 : start
  l_esign_required :='N';
  l_eRecord_required :='N';
  --Bug 4074173 : end

   /* Begin of Fix Bug Fix 3208296 */
     SAVEPOINT EREC_REQUIRED;
      /* End of Fix Bug Fix 3208296 */
     /* We will code this once AMe API's are in place */
     p_status:=false;
     /*check if Profile value is enabled */
      if (fnd_profile.value('EDR_ERES_ENABLED') = 'Y') then
         /*check if event and subscritptions are Enabled */
    --
    -- Start Bug Fix 3078516
    -- Verify is more than one active ERES subscriptions are present
    --
       select count(*) into l_no_enabled_eres_sub
       from
          wf_events a, wf_event_subscriptions b
       where a.GUID = b.EVENT_FILTER_GUID
        and a.name = p_event
         and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
         and b.STATUS = 'ENABLED'
	   --Bug No 4912782- Start
	   and b.source_type = 'LOCAL'
	   and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	   --Bug No 4912782- End
        IF l_no_enabled_eres_sub > 1 THEN
           RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
        ELSE
          OPEN GET_EVT_SUBSCRIPTION_DETAILS;
          FETCH GET_EVT_SUBSCRIPTION_DETAILS INTO l_sub_guid,l_Event_status,l_sub_status;
          CLOSE GET_EVT_SUBSCRIPTION_DETAILS;
        END IF;
    --
    -- End Bug Fix 3078516
    --

            IF l_event_status='ENABLED' and l_sub_status='ENABLED' then
               /*check if any AMe stuff is available */
               wf_event_t.initialize(evt);
               evt.setSendDate(sysdate);
               evt.setEventName(p_event);
               evt.setEventKey(p_event_key);
               -- Bug 5639849 : Starts
               -- No need to loading all subscription parameters, just get
               -- edr_ame_transaction_type using edr API.
               --l_return_status:=wf_rule.setParametersIntoParameterList(l_sub_guid,evt);

            -- IF l_return_status='SUCCESS' THEN
                /* Check for User Defined Parameters,
                  contains AME transactions Type
                  If Parameters are not specified, Assume Event name to be AME transaction Type

                 */
               l_ame_transaction_type 	:= NVL(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE',l_sub_guid),
                                      evt.getEventName( ));
               -- Bug 5639849: Ends
                /* AME Processing */
                /* Select APPLICATION_ID of the Event. This is required by AME. Assumption made here
                    is OWNER_TAG will always be set to application Short Name*/

        	SELECT application_id,APPLICATION_SHORT_NAME into l_application_id,l_application_code
          	FROM FND_APPLICATION
          	WHERE APPLICATION_SHORT_NAME in (SELECT OWNER_TAG from WF_EVENTS
                                                  WHERE NAME=evt.getEventName( ));

     		/* AME Enhancement Code. Determine if singature is need or not and also get approvers  */

      		 /* This Code should be uncommented when the SSWA AME forms move to opmeres */
            -- Bug 5167817 : start
         	/*
              AME_API.GETAPPROVERSANDRULES3
          	        (	APPLICATIONIDIN    => l_application_Id,
				TRANSACTIONIDIN    => evt.getEventKey( ),
				TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName( )),
				APPROVERSOUT       => approverList,
				RULEIDSOUT         => l_ruleids,
				RULEDESCRIPTIONSOUT=> l_rulenames
              		    );
           */

	    --Bug 5287504: Start
	    BEGIN
	      AME_API2.GETALLAPPROVERS6
              (
                        APPLICATIONIDIN    => l_application_Id,
                        TRANSACTIONIDIN    => evt.getEventKey(),
                        TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName()),
                        approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                        APPROVERSOUT       => approverList,
                        itemIndexesOut => itemIndexes,
                        itemClassesOut => itemClasses,
                        itemIdsOut => itemIds,
                        itemSourcesOut => itemSources,
                        ruleIndexesOut => ruleIndexes,
                        sourceTypesOut => sourceTypes,
                        RULEIDSOUT         => l_ruleids,
                        RULEDESCRIPTIONSOUT=> l_rulenames
              );
            EXCEPTION
              WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME('EDR','EDR_AME_SETUP_ERR');
                FND_MESSAGE.SET_TOKEN('TXN_TYPE',nvl(l_ame_transaction_type,evt.getEventName()));
                FND_MESSAGE.SET_TOKEN('ERR_MSG',sqlerrm);
                APP_EXCEPTION.RAISE_EXCEPTION;
            END;
            --bug 5287504: End

          -- Bug 5167817 : end
         	wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','AME API Called. Total Approver '||approverlist.count );
               	select application_name into l_application_name
                from ame_Calling_Apps
                where
                FND_APPLICATION_ID=l_application_id and
                TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,evt.getEventName( ))
                --Bug 4652277: Start
                --and end_Date is null;
                and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
                --Bug 4652277: End

             	  if approverList.count > 0 then

              	       for i in 1..l_ruleids.count loop
               	         wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Rule_id: '||l_ruleids(i)||' Rule '||l_rulenames(i));

                          -- Bug 3214495 : Start

                 	      EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES( transactiontypeid =>NVL(l_ame_transaction_type,evt.getEventName( )),
                  	        		                      ameruleid =>l_ruleids(i),
                   		       		                      amerulename=>l_rulenames(i),
                    		      		                      ameruleinputvalues=>l_rulevalues);

			   -- Bug 3214495 : End

                        	 wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Total Input Values '||l_rulevalues.count );
                        	    if l_rulevalues.count > 0 then
                        	       for i in 1..l_rulevalues.count loop
                         	         if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then
                          	           if ( l_esign_required='N' and l_rulevalues(i).input_value ='Y') then
                           	             l_esign_required:= l_rulevalues(i).input_value;
                            	            end if;
                             		 elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then
                                            if ( l_erecord_required='N' and l_rulevalues(i).input_value ='Y') then
                                              l_erecord_required:= l_rulevalues(i).input_value;
                                            end if;
                                         end if;
                                        end loop;
                                    end if;
                        END LOOP;
                    END IF;
         		wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','Signature Required :'||l_esign_required);
		        wf_log_pkg.string(6, 'EDR_STANDARD.psig_rule','eRecord Required   :'||l_erecord_required);
         	    IF (l_erecord_required='Y') THEN
                        p_status:=true;
                    END IF;
                END IF;
              -- Bug 5639849 : Starts
              -- Commented the l_return_status if statement
              --END IF;
              -- Bug 5639849: Ends
           END IF;

      --
      -- Following statement clears all lock aquired by this session
      -- This is modified as part of bug fix 2936432

      --
                   ROLLBACK TO EREC_REQUIRED;

EXCEPTION
   WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
     p_status:=false;
     ROLLBACK TO EREC_REQUIRED;
     FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRP_ERR');
     fnd_message.set_token( 'EVENT', p_event);
     RAISE;
   WHEN OTHERS THEN
   p_status:=false;
   ROLLBACK TO EREC_REQUIRED;
   FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
   FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
   FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_STANDARD');
   FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','EREC_REQUIRED');
   raise;
END EREC_REQUIRED;

FUNCTION PSIG_QUERY(p_eventQuery EDR_STANDARD.eventQuery) return number IS PRAGMA AUTONOMOUS_TRANSACTION;
  i number;
  l_document_id        number;
  l_query_id           number:=NULL;
  l_where_clause       varchar2(4000) ;
  l_sql                varchar2(4000);
  l_dbms_cur           integer;
  l_Rows_processed     integer;
  l_count              number:=0;
  l_prep_per           VARCHAR2(1) := null;
  l_append_per         VARCHAR2(1) := null;
begin
  if p_eventQuery.count > 0 THEN
    for i in 1 ..p_eventQuery.count loop
    -- Check do we need to prepend %
    IF p_eventQuery(i).key_type = 'PREPEND_PER' OR
       p_eventQuery(i).key_type = 'BOTH'
    THEN
      l_prep_per := '%';
    ELSE
      l_prep_per := null;
    END IF;

    -- Check do we need to append %
    IF p_eventQuery(i).key_type = 'APPEND_PER' OR
       p_eventQuery(i).key_type = 'BOTH'
    THEN
      l_append_per := '%';
    ELSE
      l_append_per := null;
    END IF;
    if I = 1 then
      /* Build the where clause based on parameters
         if key type is WHERE_CLAUSE then just and with event name
         Other wise construct Where clause based on parameters either
         append or prepend or set % both side of the string
                                                                       */
      if p_eventQuery(i).key_type = 'WHERE_CLAUSE' THEN
          l_where_clause:= '( (event_name = ' || '''' || p_eventQuery(i).event_name || '''' || ' and event_key = '|| '''' || p_eventQuery(i).event_key || '''' || ') ';
      ELSE
          l_where_clause:= '((event_name = ' || '''' || p_eventQuery(i).event_name || '''' || ' and event_key like ' || '''' || l_prep_per || p_eventQuery(i).event_key || l_append_per || '''' || ') ';
      END IF;

    ELSE
      if p_eventQuery(i).key_type = 'WHERE_CLAUSE' THEN
          l_where_clause:= l_where_clause || ' OR (event_name = ' || '''' || p_eventQuery(i).event_name || '''' || ' and event_key = ' || '''' || p_eventQuery(i).event_key || '''' || ') ';
      ELSE
          l_where_clause:= l_where_clause || ' OR (event_name = ' || '''' || p_eventQuery(i).event_name || '''' || ' and event_key like '|| '''' || l_prep_per || p_eventQuery(i).event_key || l_append_per || '''' || ') ';
      END IF;

    END IF;

   end Loop;

   /* Construct SQL */
     l_sql:='select document_id from edr_psig_documents where ' || l_where_clause || ' )' ;

   /* Open Dynamic sql */
                 IF dbms_sql.is_open(l_dbms_cur) THEN
                     dbms_sql.close_cursor(l_dbms_cur);
                 END IF;

      /* Opening the Cursor to fetch the row */
                l_dbms_cur:=dbms_sql.open_cursor;
                dbms_sql.parse(l_dbms_cur,l_sql,0);
                dbms_sql.define_column(l_dbms_cur,1,l_document_id);

                l_Rows_processed:=dbms_sql.execute(l_dbms_cur);
                 loop
                    IF dbms_sql.fetch_rows(l_dbms_cur) = 0 THEN
                       exit;
                    ELSE
                       if (l_count=0) then

                          select EDR_TRANS_QUERY_TEMP_S.nextval into l_query_id from dual;
                       end if;
                       l_count:=l_count+1;
                       dbms_sql.column_value(l_dbms_cur,1,l_document_id);
                       insert into EDR_TRANS_QUERY_TEMP(QUERY_ID,
							DOCUMENT_ID,
							CREATION_DATE,
							CREATED_BY,
							LAST_UPDATE_DATE,
							LAST_UPDATED_BY,
							LAST_UPDATE_LOGIN
                                                        )
							VALUES
							(l_query_id,
							 l_document_id,
							 sysdate,
							 fnd_global.user_id,
							 sysdate,
							 fnd_global.user_id,
							 fnd_global.login_id
                                                         );

                     END IF;
                   END LOOP;
                     dbms_sql.close_cursor(l_dbms_cur);
                   commit;

      END IF;
      return l_query_id;
 END PSIG_QUERY;

-- This API Would be deprecated and replaced by an API that takes transaction id as a parameter.
-- Bug 3214495 : Start

PROCEDURE GET_AMERULE_INPUT_VALUES( ameapplication     IN  varchar2,
                          		ameruleid          IN  NUMBER,
                          		amerulename        IN  VARCHAR2,
                          		ameruleinputvalues OUT NOCOPY EDR_STANDARD.ameruleinputvalues) is

  -- 3172322 start: parameterize the cursors on a local transId for duplicated sub-query
  -- 3172322 start: transName may be changed but 3075902 fix doesn't help here
CURSOR C0( the_trans_id VARCHAR2 ) is
  SELECT INPUT_NAME, DEFAULT_VALUE  from  EDR_AMETRAN_INPUT_VAR
    where AME_TRANS_ID = the_trans_id;
  -- 3172322 end: query on trans id

  -- 3172322 start: transName may be changed so need to collect all applnames for the same transId
CURSOR C1( the_trans_id VARCHAR2 ) is
  SELECT INPUT_NAME, INPUT_VALUE
  from  EDR_AMERULE_INPUT_VAR
  where AME_TRANS_NAME in
    ( select distinct application_name from ame_calling_apps where transaction_type_id = the_trans_id)
  AND  RULE_ID=ameruleid;

CURSOR TID is
   Select distinct transaction_type_id  FROM  ame_calling_apps
   WHERE application_name = ameapplication
   --Bug 4652277: Start
   --AND  end_date is null;
   and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
   --Bug 4652277: End

l_trans_id  varchar2(80);
  -- 3172322 end: select all transName matching this applName, remove query condition rule_name

  l_rulevalues EDR_STANDARD.ameruleinputvalues;
  i number:=0;
  j number:=0;
  l_name varchar2(240);
  l_value varchar2(240);
  BEGIN

    -- 3172322 start: open cursor to populate value into l_trans_id
    OPEN TID;
    Fetch TID into l_trans_id;
    IF TID%NOTFOUND THEN
      Close TID;
      RAISE NO_DATA_FOUND;
    END IF;
    Close TID;

    -- 3172322 end: also pass parameter l_trans_id to the cursors below

     /* Fetch Transaction inputs */
         OPEN c0(l_trans_id);
         Loop
           fetch c0 into l_name,l_value;
           EXIT when c0%NOTFOUND;
           i:=i+1;
           l_rulevalues(i).input_name:=l_name;
           l_rulevalues(i).input_value:=l_value;
         end loop;
         CLOSE c0;

     /* Now Check the Rule input Variable Values */

       /* Open Cursor */
         OPEN c1(l_trans_id);
         Loop
           fetch c1 into l_name,l_value;
           EXIT when c1%NOTFOUND;
           for i in 1..l_rulevalues.count
           loop
             if (l_rulevalues(i).input_name = l_name) then
                l_rulevalues(i).input_value:=l_value;
             end if;
           end loop;
         end loop;
         CLOSE c1;
         ameruleinputvalues:=l_rulevalues;
  END GET_AMERULE_INPUT_VALUES;

  -- Bug 3214495 : End




-- Bug 3214495 : Start

-- New API for passing Transaction Id as input

PROCEDURE GET_AMERULE_INPUT_VARIABLES( transactiontypeid     IN  varchar2,
                          		ameruleid          IN  NUMBER,
                          		amerulename        IN  VARCHAR2,
                          		ameruleinputvalues OUT NOCOPY EDR_STANDARD.ameruleinputvalues) is

  -- 3172322 start: parameterize the cursors on a local transId for duplicated sub-query
  -- 3172322 start: transName may be changed but 3075902 fix doesn't help here
CURSOR C0( the_trans_id VARCHAR2 ) is
  SELECT INPUT_NAME, DEFAULT_VALUE  from  EDR_AMETRAN_INPUT_VAR
    where AME_TRANS_ID = the_trans_id;
  -- 3172322 end: query on trans id

  -- 3172322 start: transName may be changed so need to collect all applnames for the same transId
CURSOR C1( the_trans_id VARCHAR2 ) is
  --Bug 5074583: Start
  SELECT INPUT_NAME, INPUT_VALUE  from  EDR_AMERULE_INPUT_VAR where AME_TRANS_ID = the_trans_id
    AND  RULE_ID=ameruleid;
  --Bug 5074583: End

l_trans_id  varchar2(80);
  -- 3172322 end: select all transName matching this applName, remove query condition rule_name

  l_rulevalues EDR_STANDARD.ameruleinputvalues;
  i number:=0;
  j number:=0;
  l_name varchar2(240);
  l_value varchar2(240);
  BEGIN

   l_trans_id := transactiontypeid;

     /* Fetch Transaction inputs */
         OPEN c0(l_trans_id);
         Loop
           fetch c0 into l_name,l_value;
           EXIT when c0%NOTFOUND;
           i:=i+1;
           l_rulevalues(i).input_name:=l_name;
           l_rulevalues(i).input_value:=l_value;
         end loop;
         CLOSE c0;

     /* Now Check the Rule input Variable Values */

       /* Open Cursor */
         OPEN c1(l_trans_id);
         Loop
           fetch c1 into l_name,l_value;
           EXIT when c1%NOTFOUND;
           for i in 1..l_rulevalues.count
           loop
             if (l_rulevalues(i).input_name = l_name) then
                l_rulevalues(i).input_value:=l_value;
             end if;
           end loop;
         end loop;
         CLOSE c1;
         ameruleinputvalues:=l_rulevalues;
  END GET_AMERULE_INPUT_VARIABLES;

  -- Bug 3214495 : End

PROCEDURE DISPLAY_DATE(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) IS
BEGIN
  -- BUG 322791 : Added FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE in the function call
  P_DATE_OUT:= FND_DATE.DATE_TO_DISPLAYDT(P_DATE_IN, FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
END;

-- BUG: 3075771 New Procedure added to return date  only

PROCEDURE DISPLAY_DATE_ONLY(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) IS
BEGIN

  display_date(p_date_in,P_DATE_OUT );
  P_DATE_OUT :=  trunc(fnd_date.displayDT_to_date(P_DATE_OUT));
END;

-- BUG: 3075771 New Procedure added to return time  only

PROCEDURE DISPLAY_TIME_ONLY(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) IS
BEGIN

  display_date(p_date_in,P_DATE_OUT );
  P_DATE_OUT :=  trim(substr(P_DATE_OUT, length(trunc(fnd_date.displayDT_to_date(P_DATE_OUT))) + 1));
END;

/* Audit Comparasion values */

FUNCTION COMPARE_AUDITVALUES(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2
                              )
             return varchar2 IS
l_trigger_status varchar2(100);
AUDIT_DISABLED exception;
SQL_STMT varchar2(4000);
P_CURRENT_VALUE varchar2(2000);
P_OLD_VALUE varchar2(2000);
l_table_name varchar2(4000);

BEGIN
    /* check if audit is enable on the given table, if not throw an error */
    BEGIN
     SELECT status into l_trigger_status
      FROM  user_triggers
     WHERE  trigger_name=P_TABLE_NAME||'_AU';

 wf_log_pkg.string(6, 'TEST','Trigger Status ' ||l_trigger_status);


    EXCEPTION
        WHEN NO_DATA_FOUND then
        raise AUDIT_DISABLED;
    END;
     IF l_trigger_status ='DISABLED' then
        raise AUDIT_DISABLED;
     END IF;
      /* fetch current value */
       sql_stmt := 'SELECT :1 FROM :2 WHERE :3 = :4';

    EXECUTE IMMEDIATE 'select ' ||P_COLUMN||' from '||P_TABLE_NAME ||' where '||P_PKNAME||'='||P_PKVALUE ||' '
                INTO p_current_value;

    wf_log_pkg.string(6, 'TEST','Current Value ' ||p_current_value);


      /* fetch old values from audit tables */
       l_table_name:=P_TABLE_NAME||'_A';


        l_table_name:=P_TABLE_NAME||'_A';
        wf_log_pkg.string(6, 'TEST','Audit Table ' ||l_table_name);
        wf_log_pkg.string(6, 'TEST','SQL '||sql_stmt);
      BEGIN
        EXECUTE IMMEDIATE 'select '||P_COLUMN||' from '||L_TABLE_NAME||' where '||P_PKNAME||'='||P_PKVALUE ||' and '||
                    'AUDIT_SESSION_ID=USERENV('||''''||'SESSIONID'||''''||') and '||
                    'AUDIT_TIMESTAMP in (SELECT max(AUDIT_TIMESTAMP) from '||L_TABLE_NAME||' where '||P_PKNAME||'='||P_PKVALUE ||'  and '||
                    'AUDIT_SESSION_ID=USERENV('||''''||'SESSIONID'||''''||')) and '||
                    'AUDIT_TRANSACTION_TYPE='||''''||'U'||'''' INTO  p_old_value;
        wf_log_pkg.string(6, 'TEST','old Value ' ||p_old_value);
        EXCEPTION
         WHEN NO_DATA_FOUND then
           /* Non of the columns changed */
          return 'false';
        END;
        IF p_old_value is NULL then
           return 'false';
        ELSIF p_old_value <> p_current_value then
           return 'true';
        END IF;
 EXCEPTION
   WHEN AUDIT_DISABLED then
       raise;
end COMPARE_AUDITVALUES;

PROCEDURE FIND_WF_NTF_RECIPIENT(P_ORIGINAL_RECIPIENT IN VARCHAR2,
                                P_MESSAGE_TYPE IN VARCHAR2,
                                P_MESSAGE_NAME IN VARCHAR2,
                                P_RECIPIENT IN OUT NOCOPY VARCHAR2,
                                P_NTF_ROUTING_COMMENTS IN OUT NOCOPY VARCHAR2,
                                P_ERR_CODE OUT NOCOPY varchar2,
                                P_ERR_MSG  OUT NOCOPY varchar2)IS
l_original_recipient varchar2(40);
X_role varchar2(40);
/* SKARIMIS Changed the cusrosr to handle NULL values as NULL=NULL comparision does not work */
cursor rulecurs(x_role varchar2) is
    select WRR.ACTION, WRR.ACTION_ARGUMENT, WRR.RULE_COMMENT
    from WF_ROUTING_RULES WRR
    where WRR.ROLE =L_ORIGINAL_RECIPIENT
    and sysdate between nvl(WRR.BEGIN_DATE, sysdate-1) and
                        nvl(WRR.END_DATE, sysdate+1)
    and nvl(WRR.MESSAGE_TYPE, nvl(P_MESSAGE_TYPE,0)) = nvl(P_MESSAGE_TYPE,0)
    and nvl(WRR.MESSAGE_NAME, nvl(P_MESSAGE_NAME,0)) = nvl(P_MESSAGE_NAME,0)
    order by WRR.MESSAGE_TYPE, WRR.MESSAGE_NAME;
l_RECIPIENT varchar2(200);
l_OVERRIDE_MODE varchar2(100);
l_comments varchar2(4000);
BAD_FORWARD exception;
forwardCount number := 0;
final_comments varchar2(4000);
BEGIN
    l_original_recipient := p_original_recipient;
    while true
      LOOP
     	IF (forwardCount >= 10) then
        	Raise BAD_FORWARD;
     	ELSE
       		forwardCount:=forwardCount+1;
     	END IF;
        OPEN ruleCurs(l_original_recipient);
        fetch ruleCurs into l_override_mode,l_recipient,l_comments;
	     IF ruleCurs%NOTFOUND THEN
        	/* No overriding Rule */
         	exit;
     	     ELSE
              Wf_Core.Token('TO_ROLE', WF_Directory.GetRoleDisplayName(l_recipient));
              Wf_Core.Token('FROM_ROLE', WF_Directory.GetRoleDisplayName(L_original_recipient));

	       IF l_override_mode = 'FORWARD' then
        	   	  L_COMMENTS := Wf_Core.Translate('DELEGATE_AUDIT_MSG')||' ';
	       ELSIF l_override_mode = 'TRANSFER' then
        		  L_COMMENTS := Wf_Core.Translate('TRANSFER_AUDIT_MSG')||' ';

               --Bug 3879150: Start
	       --A NOOP means that there is no transfer of notification.
	       ELSIF l_override_mode = 'NOOP' then
	         --No delegation or transfer of ownership. Hence exit.
		 exit;
	       --Bug 3879150: End

       	       ELSE
         	 	raise BAD_FORWARD;
       	       END IF;
               final_comments :=final_comments||wf_core.newline||l_comments;
       	       l_original_recipient := l_recipient;
               close ruleCurs;
             END IF;
    END LOOP;
    P_RECIPIENT:=l_ORIGINAL_RECIPIENT;
    P_NTF_ROUTING_COMMENTS:=final_COMMENTS;
    close ruleCurs;
    P_ERR_CODE:=0;
EXCEPTION
 WHEN BAD_FORWARD then
   P_ERR_CODE:= 20001;
   FND_MESSAGE.SET_NAME('EDR','EDR_BAD_NTF_RULE');
   FND_MESSAGE.SET_TOKEN('NAME',WF_Directory.GetRoleDisplayName(p_original_recipient));
   P_ERR_MSG:= FND_MESSAGE.GET;

END FIND_WF_NTF_RECIPIENT;

/*******************************************************************************
*****  This procedure returns single Descriptive flex field prompt          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    COLUMN_NAME        -- Attribute Column Name (ATTRIBUTE1 ...)       ****
*****    PROMPT_TYPE        -- Allowed Values LEFT OR ABOVE based on        ****
*****                          prompt type we return value from one of the  ****
*****                          following field                              ****
*****                          LEFT -->  FORM_LEFT_PROMPT                   ****
*****                          ABOVE --> FORM_ABOVE_PROMPT                  ****
*****    COLUMN_PROMPT      -- Returns Prompt for Column Name passed        ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_SINGLE_PROMPT(P_APPLICATION_ID     IN NUMBER,
                                      P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                      P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                      P_COLUMN_NAME        IN VARCHAR2,
                                      P_PROMPT_TYPE        IN VARCHAR2,
                                      P_COLUMN_PROMPT      OUT NOCOPY VARCHAR2) AS
   CURSOR GET_DESC_FLEX_PROMPT IS
   SELECT FORM_LEFT_PROMPT, FORM_ABOVE_PROMPT
   FROM FND_DESCR_FLEX_COL_USAGE_VL
   WHERE APPLICATION_ID = P_APPLICATION_ID
     and DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEX_DEF_NAME
     and DESCRIPTIVE_FLEX_CONTEXT_CODE = P_DESC_FLEX_CONTEXT
     and APPLICATION_COLUMN_NAME = P_COLUMN_NAME;

   l_prompt_rec GET_DESC_FLEX_PROMPT%ROWTYPE;
 BEGIN
   OPEN GET_DESC_FLEX_PROMPT;
   FETCH GET_DESC_FLEX_PROMPT  INTO l_prompt_rec;
   IF P_PROMPT_TYPE = 'LEFT' THEN
     P_COLUMN_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
   ELSIF P_PROMPT_TYPE = 'ABOVE' THEN
     P_COLUMN_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
   ELSE
     P_COLUMN_PROMPT := NULL;
   END IF;
   CLOSE GET_DESC_FLEX_PROMPT;
 END GET_DESC_FLEX_SINGLE_PROMPT;

/*******************************************************************************
*****  This procedure returns all 30 Descriptive flex field prompt          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    PROMPT_TYPE        -- Allowed Values LEFT OR ABOVE based on        ****
*****                          prompt type we return value from one of the  ****
*****                          following field                              ****
*****                          LEFT -->  FORM_LEFT_PROMPT                   ****
*****                          ABOVE --> FORM_ABOVE_PROMPT                  ****
*****    COLUMN1_PROMPT      -- Returns Prompt for Column Name passed       ****
*****    ....... COLUMN30_PROMPT                                            ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_ALL_PROMPTS(P_APPLICATION_ID     IN NUMBER,
                                    P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                    P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                    P_PROMPT_TYPE        IN VARCHAR2 ,
                                    P_COLUMN1_NAME       IN VARCHAR2,
                                    P_COLUMN2_NAME       IN VARCHAR2,
                                    P_COLUMN3_NAME       IN VARCHAR2,
                                    P_COLUMN4_NAME       IN VARCHAR2,
                                    P_COLUMN5_NAME       IN VARCHAR2,
                                    P_COLUMN6_NAME       IN VARCHAR2,
                                    P_COLUMN7_NAME       IN VARCHAR2,
                                    P_COLUMN8_NAME       IN VARCHAR2,
                                    P_COLUMN9_NAME       IN VARCHAR2,
                                    P_COLUMN10_NAME      IN VARCHAR2,
                                    P_COLUMN11_NAME      IN VARCHAR2,
                                    P_COLUMN12_NAME       IN VARCHAR2,
                                    P_COLUMN13_NAME       IN VARCHAR2,
                                    P_COLUMN14_NAME       IN VARCHAR2,
                                    P_COLUMN15_NAME       IN VARCHAR2,
                                    P_COLUMN16_NAME       IN VARCHAR2,
                                    P_COLUMN17_NAME       IN VARCHAR2,
                                    P_COLUMN18_NAME       IN VARCHAR2,
                                    P_COLUMN19_NAME       IN VARCHAR2,
                                    P_COLUMN20_NAME       IN VARCHAR2,
                                    P_COLUMN21_NAME       IN VARCHAR2,
                                    P_COLUMN22_NAME       IN VARCHAR2,
                                    P_COLUMN23_NAME       IN VARCHAR2,
                                    P_COLUMN24_NAME       IN VARCHAR2,
                                    P_COLUMN25_NAME       IN VARCHAR2,
                                    P_COLUMN26_NAME       IN VARCHAR2,
                                    P_COLUMN27_NAME       IN VARCHAR2,
                                    P_COLUMN28_NAME       IN VARCHAR2,
                                    P_COLUMN29_NAME       IN VARCHAR2,
                                    P_COLUMN30_NAME       IN VARCHAR2,
                                    P_COLUMN1_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN2_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN3_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN4_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN5_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN6_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN7_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN8_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN9_PROMPT     OUT NOCOPY VARCHAR2,
                                    P_COLUMN10_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN11_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN12_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN13_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN14_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN15_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN16_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN17_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN18_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN19_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN20_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN21_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN22_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN23_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN24_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN25_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN26_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN27_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN28_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN29_PROMPT    OUT NOCOPY VARCHAR2,
                                    P_COLUMN30_PROMPT    OUT NOCOPY VARCHAR2) IS

   CURSOR GET_DESC_FLEX_PROMPTS IS
   SELECT col_vl.APPLICATION_COLUMN_NAME,
          col_vl.FORM_LEFT_PROMPT,
          col_vl.FORM_ABOVE_PROMPT
   FROM FND_DESCR_FLEX_COL_USAGE_VL col_vl,fnd_descr_flex_contexts ctx
   WHERE col_vl.APPLICATION_ID = P_APPLICATION_ID
     and col_vl.DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEX_DEF_NAME
     and col_vl.APPLICATION_ID = ctx.APPLICATION_ID
     and col_vl.DESCRIPTIVE_FLEXFIELD_NAME = ctx.DESCRIPTIVE_FLEXFIELD_NAME
     and col_vl.DESCRIPTIVE_FLEX_CONTEXT_CODE <> NVL(P_DESC_FLEX_CONTEXT,' ')
     and col_vl.DESCRIPTIVE_FLEX_CONTEXT_CODE  = ctx.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and ctx.GLOBAL_FLAG = 'Y'
   UNION ALL
   SELECT APPLICATION_COLUMN_NAME,
          FORM_LEFT_PROMPT,
          FORM_ABOVE_PROMPT
   FROM FND_DESCR_FLEX_COL_USAGE_VL
   WHERE APPLICATION_ID = P_APPLICATION_ID
     and DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEX_DEF_NAME
     and DESCRIPTIVE_FLEX_CONTEXT_CODE = NVL(P_DESC_FLEX_CONTEXT,' ');

   l_prompt_rec GET_DESC_FLEX_PROMPTS%ROWTYPE;
 BEGIN
   OPEN GET_DESC_FLEX_PROMPTS;
   LOOP
     FETCH GET_DESC_FLEX_PROMPTS  INTO l_prompt_rec;
     EXIT WHEN GET_DESC_FLEX_PROMPTS%NOTFOUND;
     IF P_PROMPT_TYPE = 'LEFT' THEN
       IF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN1_NAME THEN
          P_COLUMN1_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN2_NAME THEN
          P_COLUMN2_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN3_NAME THEN
          P_COLUMN3_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN4_NAME THEN
          P_COLUMN4_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN5_NAME THEN
          P_COLUMN5_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN6_NAME THEN
          P_COLUMN6_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN7_NAME THEN
          P_COLUMN7_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN8_NAME THEN
          P_COLUMN8_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN9_NAME THEN
          P_COLUMN9_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN10_NAME THEN
          P_COLUMN10_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN11_NAME THEN
          P_COLUMN11_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN12_NAME THEN
          P_COLUMN12_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN13_NAME THEN
          P_COLUMN13_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN14_NAME THEN
          P_COLUMN14_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN15_NAME THEN
          P_COLUMN15_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN16_NAME THEN
          P_COLUMN16_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN17_NAME THEN
          P_COLUMN17_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN18_NAME THEN
          P_COLUMN18_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN19_NAME THEN
          P_COLUMN19_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN20_NAME THEN
          P_COLUMN20_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN21_NAME THEN
          P_COLUMN21_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN22_NAME THEN
          P_COLUMN22_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN23_NAME THEN
          P_COLUMN23_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN24_NAME THEN
          P_COLUMN24_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN25_NAME THEN
          P_COLUMN25_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN26_NAME THEN
          P_COLUMN26_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN27_NAME THEN
          P_COLUMN27_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN28_NAME THEN
          P_COLUMN28_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN29_NAME THEN
          P_COLUMN29_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN30_NAME THEN
          P_COLUMN30_PROMPT := l_prompt_rec.FORM_LEFT_PROMPT;
       END IF;

     ELSIF P_PROMPT_TYPE = 'ABOVE' THEN
       IF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN1_NAME THEN
          P_COLUMN1_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN2_NAME THEN
          P_COLUMN2_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN3_NAME THEN
          P_COLUMN3_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN4_NAME THEN
          P_COLUMN4_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN5_NAME THEN
          P_COLUMN5_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN6_NAME THEN
          P_COLUMN6_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN7_NAME THEN
          P_COLUMN7_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN8_NAME THEN
          P_COLUMN8_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN9_NAME THEN
          P_COLUMN9_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN10_NAME THEN
          P_COLUMN10_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN11_NAME THEN
          P_COLUMN11_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN12_NAME THEN
          P_COLUMN12_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN13_NAME THEN
          P_COLUMN13_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN14_NAME THEN
          P_COLUMN14_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN15_NAME THEN
          P_COLUMN15_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN16_NAME THEN
          P_COLUMN16_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN17_NAME THEN
          P_COLUMN17_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN18_NAME THEN
          P_COLUMN18_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN19_NAME THEN
          P_COLUMN19_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN20_NAME THEN
          P_COLUMN20_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN21_NAME THEN
          P_COLUMN21_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN22_NAME THEN
          P_COLUMN22_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN23_NAME THEN
          P_COLUMN23_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN24_NAME THEN
          P_COLUMN24_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN25_NAME THEN
          P_COLUMN25_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN26_NAME THEN
          P_COLUMN26_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN27_NAME THEN
          P_COLUMN27_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN28_NAME THEN
          P_COLUMN28_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN29_NAME THEN
          P_COLUMN29_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       ELSIF l_prompt_rec.APPLICATION_COLUMN_NAME = P_COLUMN30_NAME THEN
          P_COLUMN30_PROMPT := l_prompt_rec.FORM_ABOVE_PROMPT;
       END IF;
     END IF;
   END LOOP;
   CLOSE GET_DESC_FLEX_PROMPTS;
END GET_DESC_FLEX_ALL_PROMPTS;


-- Bug 4501520 :rvsingh:start

/*******************************************************************************
*****  This procedure returns all 30 Descriptive flex field values          ****
*****  It accepts                                                           ****
*****    Application ID -- Descriptive Flexed Field owner Application       ****
*****    DESC_FLEX_DEF_NAME -- Name of the Flex Definition                  ****
*****    DESC_FLEX_CONTEXT  -- Flex Definition context(ATTRIBUTE_CATEGORY)  ****
*****    P_COLUMN1_NAME ..P_COLUMN30_NAME     --  Name of the columns       ****
*****    P_COLUMN1_ID_VAL ..P_COLUMN30_ID_VAL -- ID or values of columns passed*
*****                          if the id is passed  then corresponding value****
*****                             else                                      ****
*****                               value is returned                       ****
*****    COLUMN1_VAL      -- Returns value for Column Name passed           ****
*****    ....... COLUMN30_VAL                                               ****
********************************************************************************/

PROCEDURE GET_DESC_FLEX_ALL_VALUES(P_APPLICATION_ID     IN NUMBER,
                                    P_DESC_FLEX_DEF_NAME IN VARCHAR2,
                                    P_DESC_FLEX_CONTEXT  IN VARCHAR2,
                                    P_COLUMN1_NAME       IN VARCHAR2,
                                    P_COLUMN2_NAME       IN VARCHAR2,
                                    P_COLUMN3_NAME       IN VARCHAR2,
                                    P_COLUMN4_NAME       IN VARCHAR2,
                                    P_COLUMN5_NAME       IN VARCHAR2,
                                    P_COLUMN6_NAME       IN VARCHAR2,
                                    P_COLUMN7_NAME       IN VARCHAR2,
                                    P_COLUMN8_NAME       IN VARCHAR2,
                                    P_COLUMN9_NAME       IN VARCHAR2,
                                    P_COLUMN10_NAME      IN VARCHAR2,
                                    P_COLUMN11_NAME      IN VARCHAR2,
                                    P_COLUMN12_NAME       IN VARCHAR2,
                                    P_COLUMN13_NAME       IN VARCHAR2,
                                    P_COLUMN14_NAME       IN VARCHAR2,
                                    P_COLUMN15_NAME       IN VARCHAR2,
                                    P_COLUMN16_NAME       IN VARCHAR2,
                                    P_COLUMN17_NAME       IN VARCHAR2,
                                    P_COLUMN18_NAME       IN VARCHAR2,
                                    P_COLUMN19_NAME       IN VARCHAR2,
                                    P_COLUMN20_NAME       IN VARCHAR2,
                                    P_COLUMN21_NAME       IN VARCHAR2,
                                    P_COLUMN22_NAME       IN VARCHAR2,
                                    P_COLUMN23_NAME       IN VARCHAR2,
                                    P_COLUMN24_NAME       IN VARCHAR2,
                                    P_COLUMN25_NAME       IN VARCHAR2,
                                    P_COLUMN26_NAME       IN VARCHAR2,
                                    P_COLUMN27_NAME       IN VARCHAR2,
                                    P_COLUMN28_NAME       IN VARCHAR2,
                                    P_COLUMN29_NAME       IN VARCHAR2,
                                    P_COLUMN30_NAME       IN VARCHAR2,
                                    P_COLUMN1_ID_VAL       IN VARCHAR2,
                                    P_COLUMN2_ID_VAL       IN VARCHAR2,
                                    P_COLUMN3_ID_VAL       IN VARCHAR2,
                                    P_COLUMN4_ID_VAL       IN VARCHAR2,
                                    P_COLUMN5_ID_VAL       IN VARCHAR2,
                                    P_COLUMN6_ID_VAL       IN VARCHAR2,
                                    P_COLUMN7_ID_VAL       IN VARCHAR2,
                                    P_COLUMN8_ID_VAL       IN VARCHAR2,
                                    P_COLUMN9_ID_VAL       IN VARCHAR2,
                                    P_COLUMN10_ID_VAL      IN VARCHAR2,
                                    P_COLUMN11_ID_VAL      IN VARCHAR2,
                                    P_COLUMN12_ID_VAL       IN VARCHAR2,
                                    P_COLUMN13_ID_VAL       IN VARCHAR2,
                                    P_COLUMN14_ID_VAL       IN VARCHAR2,
                                    P_COLUMN15_ID_VAL       IN VARCHAR2,
                                    P_COLUMN16_ID_VAL       IN VARCHAR2,
                                    P_COLUMN17_ID_VAL       IN VARCHAR2,
                                    P_COLUMN18_ID_VAL       IN VARCHAR2,
                                    P_COLUMN19_ID_VAL       IN VARCHAR2,
                                    P_COLUMN20_ID_VAL       IN VARCHAR2,
                                    P_COLUMN21_ID_VAL       IN VARCHAR2,
                                    P_COLUMN22_ID_VAL       IN VARCHAR2,
                                    P_COLUMN23_ID_VAL       IN VARCHAR2,
                                    P_COLUMN24_ID_VAL       IN VARCHAR2,
                                    P_COLUMN25_ID_VAL       IN VARCHAR2,
                                    P_COLUMN26_ID_VAL       IN VARCHAR2,
                                    P_COLUMN27_ID_VAL       IN VARCHAR2,
                                    P_COLUMN28_ID_VAL       IN VARCHAR2,
                                    P_COLUMN29_ID_VAL       IN VARCHAR2,
                                    P_COLUMN30_ID_VAL       IN VARCHAR2,
                                    P_COLUMN1_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN2_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN3_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN4_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN5_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN6_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN7_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN8_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN9_VAL     OUT NOCOPY VARCHAR2,
                                    P_COLUMN10_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN11_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN12_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN13_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN14_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN15_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN16_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN17_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN18_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN19_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN20_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN21_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN22_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN23_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN24_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN25_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN26_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN27_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN28_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN29_VAL    OUT NOCOPY VARCHAR2,
                                    P_COLUMN30_VAL    OUT NOCOPY VARCHAR2) IS
  l_appl_short_name         varchar2(30) := 'EDR';
  l_values_or_ids           varchar2(10) := 'I';
  l_validation_date         DATE         := SYSDATE;
  l_segcount  number;
  l_attrrcount number;
  l_error_segment          varchar2(30);
  errors_received        EXCEPTION;
 BEGIN
 l_attrrcount :=0;
 l_segcount  :=0;

    select count(*) INTO l_attrrcount  from (
       SELECT col_vl.APPLICATION_COLUMN_NAME
	    FROM FND_DESCR_FLEX_COL_USAGE_VL col_vl,fnd_descr_flex_contexts ctx
          WHERE col_vl.APPLICATION_ID = P_APPLICATION_ID
	    and col_vl.DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEX_DEF_NAME
	    and col_vl.APPLICATION_ID = ctx.APPLICATION_ID
          and col_vl.DESCRIPTIVE_FLEXFIELD_NAME = ctx.DESCRIPTIVE_FLEXFIELD_NAME
          and col_vl.DESCRIPTIVE_FLEX_CONTEXT_CODE <> NVL(P_DESC_FLEX_CONTEXT,' ')
          and col_vl.DESCRIPTIVE_FLEX_CONTEXT_CODE  = ctx.DESCRIPTIVE_FLEX_CONTEXT_CODE
          and ctx.GLOBAL_FLAG = 'Y'
     UNION ALL
        SELECT APPLICATION_COLUMN_NAME
            FROM FND_DESCR_FLEX_COL_USAGE_VL
            WHERE APPLICATION_ID = P_APPLICATION_ID
            and DESCRIPTIVE_FLEXFIELD_NAME = P_DESC_FLEX_DEF_NAME
            and DESCRIPTIVE_FLEX_CONTEXT_CODE = NVL(P_DESC_FLEX_CONTEXT,' '));

   -- check for valid context for flexfield
     IF(l_attrrcount > 0) THEN

        FND_FLEX_DESCVAL.set_context_value(P_DESC_FLEX_CONTEXT);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE1',P_COLUMN1_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE2',P_COLUMN2_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE3',P_COLUMN3_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE4',P_COLUMN4_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE5',P_COLUMN5_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE6',P_COLUMN6_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE7',P_COLUMN7_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE8',P_COLUMN8_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE9',P_COLUMN9_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE10',P_COLUMN10_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE11',P_COLUMN11_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE12',P_COLUMN12_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE13',P_COLUMN13_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE14',P_COLUMN14_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE15',P_COLUMN15_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE16',P_COLUMN16_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE17',P_COLUMN17_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE18',P_COLUMN18_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE19',P_COLUMN19_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE20',P_COLUMN20_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE21',P_COLUMN21_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE22',P_COLUMN22_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE23',P_COLUMN23_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE24',P_COLUMN24_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE25',P_COLUMN25_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE26',P_COLUMN26_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE27',P_COLUMN27_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE28',P_COLUMN28_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE29',P_COLUMN29_ID_VAL);
        FND_FLEX_DESCVAL.set_column_value('ATTRIBUTE30',P_COLUMN30_ID_VAL);

       IF  FND_FLEX_DESCVAL.validate_desccols(l_appl_short_name,P_DESC_FLEX_DEF_NAME,l_values_or_ids,l_validation_date)  THEN
            wf_log_pkg.string(6, 'GET_DESC_FLEX_ALL_VALUES','Function completed successfully');
            l_segcount := FND_FLEX_DESCVAL.segment_count;
            -- FND_FLEX_DESCVAL.segment_value(1) - Segment name
         IF(l_segcount > 1)THEN
           FOR i in 2..l_segcount LOOP
             IF FND_FLEX_DESCVAL.segment_column_name(i) = P_COLUMN1_NAME THEN
                P_COLUMN1_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN2_NAME THEN
               P_COLUMN2_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN3_NAME THEN
               P_COLUMN3_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN4_NAME THEN
               P_COLUMN4_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN5_NAME THEN
               P_COLUMN5_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN6_NAME THEN
               P_COLUMN6_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN7_NAME THEN
               P_COLUMN7_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN8_NAME THEN
               P_COLUMN8_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN9_NAME THEN
               P_COLUMN9_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN10_NAME THEN
               P_COLUMN10_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN11_NAME THEN
               P_COLUMN11_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN12_NAME THEN
               P_COLUMN12_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN13_NAME THEN
               P_COLUMN13_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN14_NAME THEN
               P_COLUMN14_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN15_NAME THEN
               P_COLUMN15_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN16_NAME THEN
               P_COLUMN16_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN17_NAME THEN
               P_COLUMN17_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN18_NAME THEN
               P_COLUMN18_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN19_NAME THEN
               P_COLUMN19_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN20_NAME THEN
               P_COLUMN20_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN21_NAME THEN
               P_COLUMN21_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN22_NAME THEN
               P_COLUMN22_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN23_NAME THEN
               P_COLUMN23_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN24_NAME THEN
               P_COLUMN24_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN25_NAME THEN
               P_COLUMN25_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN26_NAME THEN
               P_COLUMN26_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN27_NAME THEN
               P_COLUMN27_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN28_NAME THEN
               P_COLUMN28_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN29_NAME THEN
               P_COLUMN29_VAL := FND_FLEX_DESCVAL.segment_value(i);
             ELSIF FND_FLEX_DESCVAL.segment_column_name(i)= P_COLUMN30_NAME THEN
               P_COLUMN30_VAL := FND_FLEX_DESCVAL.segment_value(i);
             END IF;
          END LOOP;
        END IF;
      ELSE
           l_error_segment := FND_FLEX_DESCVAL.error_segment;
           RAISE errors_received;
      END IF;
    END IF;

 EXCEPTION
   WHEN errors_received THEN
   FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
   FND_MESSAGE.SET_TOKEN('ERROR_TEXT',fnd_flex_descval.error_message);
   FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_STANDARD');
   FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_DESC_FLEX_ALL_VALUES');
   raise;
END GET_DESC_FLEX_ALL_VALUES;

-- Bug 4501520 :rvsingh:end
/*******************************************************************************
*****  This procedure returns Lookup code meaning                           ****
*****  It accepts                                                           ****
*****   LOOKUP_TYPE and LOOKUP CODE as in parameter and Returns MEANING     ****
*****   as out parameter.  This uses FND_LOOKUPS View                       ****
********************************************************************************/

PROCEDURE GET_MEANING(P_LOOKUP_TYPE IN VARCHAR2,
                      P_LOOKUP_CODE IN VARCHAR2,
                      P_MEANING     OUT NOCOPY VARCHAR2) IS
  CURSOR GET_LKUP_MEANING IS
    SELECT MEANING
    FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
      AND LOOKUP_CODE = P_LOOKUP_CODE;
BEGIN
  OPEN GET_LKUP_MEANING;
  FETCH GET_LKUP_MEANING INTO P_MEANING;
  CLOSE GET_LKUP_MEANING;
END;


-- bug 4865689 :start
/*******************************************************************************
*****  This procedure returns USER RESPONSE                                 ****
*****  It accepts                                                           ****
*****   LOOKUP_TYPE and PSIG_STATUS as in parameter and Returns RESPONSE     ****
*****   as out parameter.  This uses FND_LOOKUPS View                       ****
********************************************************************************/

PROCEDURE GET_USER_RESPONSE(P_LOOKUP_TYPE IN VARCHAR2,
                      P_PSIG_STATUS IN VARCHAR2,
                      P_RESPONSE     OUT NOCOPY VARCHAR2) IS
  L_LOOKUP_CODE VARCHAR2(30);
  CURSOR GET_LKUP_MEANING IS
    SELECT MEANING
    FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
      AND LOOKUP_CODE = L_LOOKUP_CODE;
BEGIN
   IF(P_PSIG_STATUS = 'REJECTED') THEN
     P_RESPONSE := null;
   ELSIF(P_PSIG_STATUS = 'COMPLETE') THEN
     P_RESPONSE := null;
   ELSIF (P_PSIG_STATUS = 'ERROR') THEN
     P_RESPONSE := null;
   ELSIF (P_PSIG_STATUS = 'CANCEL') THEN
     L_LOOKUP_CODE := 'CANCELED';
     OPEN GET_LKUP_MEANING;
     FETCH GET_LKUP_MEANING INTO P_RESPONSE;
     CLOSE GET_LKUP_MEANING;
   ELSE
     L_LOOKUP_CODE := 'WAITING';
     OPEN GET_LKUP_MEANING;
     FETCH GET_LKUP_MEANING INTO P_RESPONSE;
     CLOSE GET_LKUP_MEANING;
   END IF;
END;
-- bug 4865689 :end

/****+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++****
*****  This procedure returns single query id for eRecords                  ****
*****  It is a simplied version of PSIG_QUERY for Java api                  ****
*****  It accepts strings of event name, event key and query type           ****
*****+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++****/

PROCEDURE PSIG_QUERY_ONE( p_event_name 	IN FND_TABLE_OF_VARCHAR2_255,
			  p_event_key  	IN FND_TABLE_OF_VARCHAR2_255,
			  o_query_id	OUT NOCOPY NUMBER )
IS
  ith		NUMBER;
  nEvents	NUMBER;
  l_single_array EDR_STANDARD.eventQuery;
BEGIN
  nEvents := p_event_name.COUNT;

  IF p_event_key.COUNT = nEvents THEN

    FOR ith in 1..nEvents LOOP
--	l_single_array.extend;    -- can't extend table...

    	l_single_array(ith).event_name := p_event_name(ith);	-- substr(p_event_name(ith),1,240);
    	l_single_array(ith).event_key  := p_event_key(ith);	-- substr(p_event_key(ith), 1,240);
    	l_single_array(ith).key_type   := 'WHERE_CLAUSE';
    END LOOP;
    o_query_id := EDR_STANDARD.PSIG_QUERY(l_single_array);

  ELSE
    o_query_id := 0;
  END IF;

END;


end EDR_STANDARD;

/
