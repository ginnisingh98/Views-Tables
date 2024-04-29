--------------------------------------------------------
--  DDL for Package Body EDR_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_UTILITIES" AS
/* $Header: EDRUTILB.pls 120.19.12010000.2 2009/03/26 17:13:54 srpuri ship $ */
/* Print Procedure */

--Bug 3164491 : start
EDR_OVERRIDE_DETAILS_ERR Exception;
--Bug 3164491 : end

PROCEDURE PRINTCLOB(result IN OUT NOCOPY CLOB) Is
xmlstr varchar2(32767);
line varchar2(2000);
begin
NULL;
end PRINTCLOB;


/* Generate e Record from gateway*/
PROCEDURE VERIFY_SETUP    (ERRBUF       OUT NOCOPY VARCHAR2,
                           RETCODE      OUT NOCOPY VARCHAR2,
                           P_EVENT      IN  VARCHAR2,
                           P_EVENT_KEY  IN  VARCHAR2
                          )IS

l_event_status varchar2(100);
l_sub_status varchar2(100);
l_sub_guid varchar2(4000);
evt wf_event_t;
l_application_id number;
l_application_code varchar2(32);
l_return_status varchar2(32);
l_application_name varchar2(240);
l_ame_transaction_Type varchar2(240);
l_xml_map_code varchar2(240);
l_xml_document clob;
l_transaction_name varchar2(240);

l_ruleids   edr_utilities.id_List;
l_rulenames edr_utilities.string_List;

l_rulevalues EDR_STANDARD.ameruleinputvalues;

-- Bug 2674799 : start
approverList     EDR_UTILITIES.approvers_Table;

-- ame approver api call variables
  approvalProcessCompleteYN ame_util.charType;
  itemClasses ame_util.stringList;
  itemIndexes ame_util.idList;
  itemIds ame_util.stringList;
  itemSources ame_util.longStringList;
  ruleIndexes ame_util.idList;
  sourceTypes ame_util.stringList;


-- Bug 2674799 : end




l_user varchar2(240);
i integer;
  CURSOR GET_EVT_SUBSCRIPTION_DETAILS IS
     select b.guid,A.status,b.status
     from
       wf_events a, wf_event_subscriptions b
     where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
	 --Bug No 4912782- Start
	 and b.source_type = 'LOCAL'
	 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	 --Bug No 4912782- End
  l_no_enabled_eres_sub NUMBER;
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
BEGIN
     /* Check if Profile option is Defined or Not */

     fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CHECK_SETUP');
     fnd_message.set_token('EVENT', p_Event);
     fnd_file.put_line(fnd_file.output, fnd_message.get);
     fnd_file.new_line(fnd_file.output, 2);

      if (fnd_profile.defined('EDR_ERES_ENABLED')) THEN
         fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_ERES_PROFILE_Y') );
      else
         fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_ERES_PROFILE_N') );
      end if;

      fnd_file.new_line(fnd_file.output, 1);
      if (fnd_timezones.GET_SERVER_TIMEZONE_CODE IS NULL) THEN
         fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_TIME_ZONE_N') );
      else
   fnd_message.set_name('EDR', 'EDR_UTIL_PLS_TIME_ZONE_Y');
   fnd_message.set_token('TMZONE', fnd_timezones.GET_SERVER_TIMEZONE_CODE);
         fnd_file.put_line(fnd_file.output, fnd_message.get);
      end if;

    fnd_message.set_name('EDR', 'EDR_UTIL_PLS_ERES_PROFILE_V');
    fnd_message.set_token( 'ERESPROFILE', fnd_profile.value('EDR_ERES_ENABLED'));
    fnd_file.put_line(fnd_file.output, fnd_message.get);
    fnd_file.new_line(fnd_file.output, 1);


        /*check if event and subscritptions are Enabled */
        BEGIN
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
              select count(*)  INTO l_no_enabled_eres_sub
              from
                wf_events a, wf_event_subscriptions b
              where a.GUID = b.EVENT_FILTER_GUID
                and a.name = p_event
                and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
		    --Bug No 4912782- Start
	    	    and b.source_type = 'LOCAL'
	          and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	  	    --Bug No 4912782- End
              IF l_no_enabled_eres_sub = 0 THEN
                RAISE NO_DATA_FOUND;
              ELSE
                OPEN GET_EVT_SUBSCRIPTION_DETAILS;
                LOOP
                  FETCH GET_EVT_SUBSCRIPTION_DETAILS INTO l_sub_guid,l_Event_status,l_sub_status;
                  EXIT WHEN GET_EVT_SUBSCRIPTION_DETAILS%NOTFOUND;
                  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_EVENT_STATUS');
                  fnd_message.set_token( 'EVENT', p_event);
                  fnd_message.set_token( 'STATUS', l_event_status);
                  fnd_file.put_line(fnd_file.output, fnd_message.get);

                  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_SUBSCRIBE_STATUS');
                  fnd_message.set_token( 'EVENT', p_event);
                  fnd_message.set_token( 'STATUS', l_sub_status);
                  fnd_file.put_line(fnd_file.output, fnd_message.get);
                END LOOP;
                CLOSE GET_EVT_SUBSCRIPTION_DETAILS;
              END IF;
            END IF;
        --
        -- End Bug Fix 3078516
        --
         EXCEPTION
           WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
             FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRP_ERR');
     fnd_message.set_token( 'EVENT', p_event);
             fnd_file.put_line(fnd_file.output, fnd_message.get);
             RETURN;
           WHEN NO_DATA_FOUND THEN
     fnd_message.set_name('EDR', 'EDR_UTIL_PLS_EVENTSUB_NOEXIST');
     fnd_message.set_token( 'EVENT', p_event);
             fnd_file.put_line(fnd_file.output, fnd_message.get);
             RETURN;
         END;

         /*check if any AMe stuff is available */
         wf_event_t.initialize(evt);
         evt.setSendDate(sysdate);
         evt.setEventName(p_event);
         evt.setEventKey(p_event_key);
         -- Bug 5639849 : Starts
         -- No need of loading all subscription parameters, rather just read the
         -- edr_ame_transaction_type and map code directly using edr API.
         --l_return_status:=wf_rule.setParametersIntoParameterList(l_sub_guid,evt);

         /* Check for User Defined Parameters, contains AME transactions Type
         If Parameters are not specified, Assume Event name to be AME transaction Type   */

         l_ame_transaction_type := NVL(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE', l_sub_guid), evt.getEventName( ) );
        -- Bug 5639849 : Ends

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_AME_TRANS_TYPE');
  fnd_message.set_token( 'TRANSTYPE', l_ame_transaction_type);
  fnd_file.put_line(fnd_file.output, fnd_message.get);


        /* AME Processing, Select APPLICATION_ID of the Event. */
        /* Required by AME. Assumption made here is OWNER_TAG will always be set to application Short Name*/
        BEGIN
          SELECT application_id,APPLICATION_SHORT_NAME into l_application_id,l_application_code
            FROM FND_APPLICATION
            WHERE APPLICATION_SHORT_NAME in
    (SELECT OWNER_TAG from WF_EVENTS WHERE NAME=evt.getEventName( ));

    fnd_message.set_name('EDR', 'EDR_UTIL_PLS_EVENT_APP_CODE');
    fnd_message.set_token( 'APPCODE', l_application_code);
    fnd_file.put_line(fnd_file.output, fnd_message.get);
    fnd_message.set_name('EDR', 'EDR_UTIL_PLS_EVENT_APP_ID');
    fnd_message.set_token( 'APPID', l_application_id);
    fnd_file.put_line(fnd_file.output, fnd_message.get);

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_EVENT_APP_ID_NO') );
  END;

fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_AME_RULE_EVAL') );


        --Bug 2674799: start

        EDR_UTILITIES.GET_APPROVERS
            (P_APPLICATION_ID   => l_application_Id,
             P_TRANSACTION_ID    => evt.getEventKey( ),
             P_TRANSACTION_TYPE  => NVL(l_ame_transaction_type,evt.getEventName( )),
             X_APPROVERS       => approverList,
             X_RULE_IDS         => l_ruleids,
             X_RULE_DESCRIPTIONS=> l_rulenames
         );

        --Bug 2674799: end

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_AME_APPROVER_NUM');
  fnd_message.set_token( 'APPR_NUM', approverlist.count);
        fnd_file.put_line(fnd_file.output, fnd_message.get);

        select application_name into l_application_name
        from ame_Calling_Apps
        where FND_APPLICATION_ID=l_application_id
        and TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,evt.getEventName( ))
        --Bug 4652277: Start
        --and end_Date is null;
        and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
        --Bug 4652277: End

        if approverList.count > 0 then
           for i in 1..approverList.count loop

              --Bug 2674799: start
              l_user := approverList(i).name;
              --Bug 2674799: end

        fnd_message.set_name('EDR', 'EDR_UTIL_PLS_AME_APPROVER_SEQ');
        fnd_message.set_token( 'APPROVER', l_user);
        fnd_message.set_token( 'APPR_SEQ', i);
              fnd_file.put_line(fnd_file.output, fnd_message.get);

            end loop;

            for i in 1..l_ruleids.count loop
                fnd_message.set_name('EDR', 'EDR_UTIL_PLS_AME_RULE_APPLY');
    fnd_message.set_token( 'RULEID', l_ruleids(i));
    fnd_message.set_token( 'RULENAME', l_rulenames(i));
    fnd_file.put_line(fnd_file.output, fnd_message.get);

    -- Bug 3214495 : Start

                EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES( transactiontypeid =>NVL(l_ame_transaction_type,evt.getEventName( )),
                                ameruleid =>l_ruleids(i),
                                amerulename=>l_rulenames(i),
                                  ameruleinputvalues=>l_rulevalues);

                -- Bug 3214495 : End

                fnd_message.set_name('EDR', 'EDR_UTIL_PLS_INPUT_VAR_NUM');
    fnd_message.set_token( 'NUM_INPUT', l_rulevalues.count);
    fnd_file.put_line(fnd_file.output, fnd_message.get);
                if l_rulevalues.count > 0 then
                   for i in 1..l_rulevalues.count loop
                     if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then
                      fnd_message.set_name('EDR', 'EDR_UTIL_PLS_INPUT_ESIG_REQ');
      fnd_message.set_token( 'VAR_ESIGREQ', l_rulevalues(i).input_value);
      fnd_file.put_line(fnd_file.output, fnd_message.get);
                     elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then
                        fnd_message.set_name('EDR', 'EDR_UTIL_PLS_INPUT_EREC_REQ');
      fnd_message.set_token( 'VAR_ERECREQ', l_rulevalues(i).input_value);
      fnd_file.put_line(fnd_file.output, fnd_message.get);
                     elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET' then
                        fnd_message.set_name('EDR', 'EDR_UTIL_PLS_INPUT_EREC_XSL');
      fnd_message.set_token( 'VAR_ERECXSL', l_rulevalues(i).input_value);
      fnd_file.put_line(fnd_file.output, fnd_message.get);
                     elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET_VER' then
                        fnd_message.set_name('EDR', 'EDR_UTIL_PLS_INPUT_EREC_VER');
      fnd_message.set_token( 'VAR_ERECVER', l_rulevalues(i).input_value);
      fnd_file.put_line(fnd_file.output, fnd_message.get);
                     end if;
                    end loop;
                 end if;

            END LOOP;
        END IF;

fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_DOC_GET_XML') );
               -- Bug  5639849 : Starts
               -- Read EDR_XML_MAP_CODE from subscription parameter rather than
               -- event parameter list.
        l_xml_map_code := NVL(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_XML_MAP_CODE',l_sub_guid),
                                      evt.getEventName( ));
               -- Bug 5639849 : Ends

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_DOC_GET_MAP');
  fnd_message.set_token( 'DOC_MAP', l_xml_map_code);
        fnd_file.put_line(fnd_file.output, fnd_message.get);
  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_DOC_GET_ID');
  fnd_message.set_token( 'DOC_ID', evt.getEventKey());
        fnd_file.put_line(fnd_file.output, fnd_message.get);

        wf_event.AddParameterToList('ECX_MAP_CODE', l_xml_map_code,evt.Parameter_List); /* XML Map Code*/
        wf_event.AddParameterToList('ECX_DOCUMENT_ID', evt.getEventKey( ),evt.Parameter_List); /* XML Document ID*/

  fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_DOC_GET_ECX') );

        /* Generate XML Document */
        L_XML_DOCUMENT:=ECX_STANDARD.GENERATE
                          ( p_event_name=>evt.getEventName( ),
                                  p_event_key=>evt.getEventKey( ),
                                  p_parameter_list=>evt.Parameter_List );

  fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_DOC_XML_GOT') );
        -- 3186732 start: fnd_message.set_token limit 3000 char, fnd_message.get limit 2000 char
        fnd_file.put_line(fnd_file.output, dbms_lob.SUBSTR(l_xml_document,32767) );
        -- 3186732 end: removed fnd_message set_name/set_token/get statements, write to output directly

        fnd_file.new_line(fnd_file.output, 2);
  fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_DOC_SETUP_OK') );


EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.output,SQLERRM);
            fnd_file.new_line(fnd_file.output,2);
      fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_DOC_SETUP_NO') );
END VERIFY_SETUP;



PROCEDURE GENERATE_ERECORD( P_XML IN CLOB,
        P_XSL IN CLOB,
        P_DOC OUT NOCOPY VARCHAR2) IS

i_stylesheet  xslprocessor.Stylesheet;
i_processor xslprocessor.Processor;
i_xmlDocFrag  xmlDOM.DOMDocumentFragment;
i_domDocFrag  xmlDOM.DOMDocumentFragment;
i_domNode         xmlDOM.DOMNode;
i_xslt_dir  varchar2(200);
i_fullpath  varchar2(200);
i_string  varchar2(2000);
l_xslt_payload  clob;
XSL_parser  xmlparser.parser;
XML_parser  xmlparser.parser;
l_xsl_doc xmldom.DOMDocument;
l_xml_doc xmldom.DOMDocument;
l_processed_xsl CLOB;
l_text varchar2(32767);
-- -- -- --   -- 3056514 fix -- --
i_Doc   xmlDOM.DOMDocument;
l_node_type pls_integer;
-- -- -- --   -- 3056514 fix -- --

begin
   /* convert i_xml_file from CLOB to DOMNode and set in ecx_utils.g_xmldoc */
   xml_parser := xmlparser.newParser;
   xmlparser.parseCLOB(xml_parser, P_XML);
   l_xml_doc := xmlparser.getDocument(xml_parser);
   ecx_utils.g_xmldoc:=xmlDOM.makeNode(l_xml_doc);
   xmlParser.freeParser(xml_parser);

   /* convert l_xslt_paylod from clob to DOMDocument */
   xsl_parser := xmlparser.newParser;
   xmlparser.parseCLOB(xsl_parser, P_XSL);
   l_xsl_doc := xmlparser.getDocument(xsl_parser);

   /* get the stylesheet */
   i_stylesheet := xslprocessor.newStyleSheet(l_xsl_doc, null);
   i_processor := xslprocessor.newProcessor;

   -- 3056514 fix, distinguish the internal node type to make different document node for xslprocessor
   l_node_type := xmlDOM.getNodeType(ecx_utils.g_xmldoc);
   if  l_node_type = xmlDOM.DOCUMENT_NODE  then
  i_Doc := xmlDOM.makeDocument(ecx_utils.g_xmldoc);
    i_xmlDocFrag := xslprocessor.processXSL(i_processor,i_stylesheet,i_Doc);
   elsif  l_node_type = xmlDOM.DOCUMENT_FRAGMENT_NODE  then
    i_domDocFrag := xmlDOM.makeDocumentFragment(ecx_utils.g_xmldoc);
    i_xmlDocFrag := xslprocessor.processXSL(i_processor,i_stylesheet,i_domDocFrag);
   end if;
   -- i_domDocFrag := xmlDOM.makeDocumentFragment(ecx_utils.g_xmldoc);
   -- i_xmlDocFrag := xslprocessor.processXSL(i_processor,i_stylesheet,i_domDocFrag);
   -- -- 3056514 fix endend -- -- --

   i_domNode := xmlDOM.makeNode(i_xmlDocFrag);
   ecx_utils.g_xmldoc := i_domNode;
   xmlDOM.writeTobuffer(ecx_utils.g_xmldoc, l_text);
   p_doc:=l_text;

   /*free all the used variables*/
   if (xsl_parser.id <> -1)
   then
    xmlParser.freeParser(xsl_parser);
   end if;
   if (not xmldom.isNull(l_xsl_doc))
   then
    xmldom.freeDocument(l_xsl_doc);
   end if;
exception
   /* Put All DOM Parser Exceptions Here. */
   WHEN OTHERS THEN
  if (xsl_parser.id <> -1)
  then
     xmlParser.freeParser(xsl_parser);
  end if;
  if (not xmldom.isNull(l_xsl_doc))
  then
     xmldom.freeDocument(l_xsl_doc);
  end if;
   raise;
END GENERATE_ERECORD;

/* Generate XML */
PROCEDURE GENERATE_XML(P_MAP_CODE      IN  VARCHAR2,
                       P_DOCUMENT_ID   IN  VARCHAR2,
                       P_XML           OUT NOCOPY CLOB,
                       P_ERROR_CODE    OUT NOCOPY NUMBER,
                       P_ERROR_MSG     OUT NOCOPY VARCHAR2,
                       P_LOG_FILE      OUT NOCOPY VARCHAR2
                      )
IS
  result  CLOB;
  retcode                       pls_integer;
  errmsg                        varchar2(2000);
  logfile                       varchar2(200);
begin
  ecx_outbound.getXML(i_map_code         => P_MAP_CODE,
                      i_document_id      => P_DOCUMENT_ID,
                      i_debug_level      => 6,
                      i_xmldoc           => P_XML,
                      i_ret_code         => P_ERROR_CODE,
                      i_errbuf           => P_ERROR_MSG,
                      i_log_file         => P_LOG_FILE);

  replace_user_data_token(p_xml);

END GENERATE_XML;

PROCEDURE TEMP_DATA_CLEANUP(ERRBUF    OUT NOCOPY VARCHAR2,
                            RETCODE   OUT NOCOPY VARCHAR2)
IS

BEGIN

  fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_UTIL_PLS_CLEAN_TEMP') );

  DELETE EDR_ERECORDS where ERECORD_SIGNATURE_STATUS not in ('PENDING');

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_EREC');
  fnd_message.set_token( 'CLN_NUMREC', SQL%ROWCOUNT);
  fnd_file.put_line(fnd_file.output, fnd_message.get);

  DELETE EDR_ESIGNATURES where EVENT_ID not in (SELECT EVENT_ID from EDR_ERECORDS);

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_ESIG');
  fnd_message.set_token( 'CLN_NUMSIG', SQL%ROWCOUNT);
  fnd_file.put_line(fnd_file.output, fnd_message.get);

-- Bug 3761813 rvsingh start
--Bug 4306292: Start
--Commenting the changes made for the red lining project.

   DELETE EDR_REDLINE_TRANS_DATA where EVENT_ID not in (SELECT EVENT_ID from EDR_ERECORDS);

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_REDLINE');
  fnd_message.set_token( 'CLN_NUMREDLINE', SQL%ROWCOUNT);
      fnd_file.put_line(fnd_file.output, fnd_message.get);

--Bug 4306292: End
-- Bug 3761813 rvsing stop

  DELETE EDR_TRANS_QUERY_TEMP;

  fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_TQRY');
  fnd_message.set_token( 'CLN_NUMQRY', SQL%ROWCOUNT);
  fnd_file.put_line(fnd_file.output, fnd_message.get);

  --Bug 5256904: Start
  DELETE FROM EDR_ERESPARAMETERS_T
  WHERE PARENT_TYPE = 'EDR_XDOC_PARAMS';
  --Bug 5256904: End

  --Bug 3667036: Start
  --In addition to previous cleanup operations, as a part of the OAF project
  --we also have to cleanup the temp data created as a part of OAF processing


  EDR_ERES_EVENT_PVT.DELETE_ERECORDS();
  --Bug 3667036: End

   -- Bug 3776079 : Added delete statements to cleanup edr
   -- print utility temporary data.

   DELETE FROM EDR_PREPARE_DOCUMENT_TEMP WHERE REQUEST_ID IN
    (SELECT REQUEST_ID FROM EDR_COLLATE_PRINT_TEMP
      WHERE CREATION_DATE < (SYSDATE - 2) );
   fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_PREP');
   fnd_message.set_token( 'CLN_NUMQRY', SQL%ROWCOUNT);
   fnd_file.put_line(fnd_file.output, fnd_message.get);

   DELETE FROM EDR_COLLATE_PRINT_TEMP where CREATION_DATE < (SYSDATE - 2);
   fnd_message.set_name('EDR', 'EDR_UTIL_PLS_CLEAN_COLL');
   fnd_message.set_token( 'CLN_NUMQRY', SQL%ROWCOUNT);
   fnd_file.put_line(fnd_file.output, fnd_message.get);

   -- Bug 3776079 : End

  COMMIT;
END TEMP_DATA_CLEANUP;

--CJ 2/27/2003
--This function would take the original string and use the delimiter to return the substring
--from the start of the string till the delimiter. The original script along with the
--substring are returned to the calling function

FUNCTION GET_DELIMITED_STRING(p_original_string IN OUT NOCOPY VARCHAR2,
          p_delimiter IN VARCHAR2)
return varchar2 IS
l_return_value VARCHAR2(1000);
l_location NUMBER;
l_length number;
BEGIN
  if (p_original_string is null) then
    l_return_value := null;
  else
    l_location := instr(p_original_string, p_delimiter);

    if (l_location = 0) then
      l_return_value := p_original_string;
      p_original_string := null;
    else
      l_return_value := substr(p_original_string, 1,l_location-1);
      l_length := length(p_original_string);
      p_original_string := substr(p_original_string,l_location+1,(l_length - l_location));
    end if;
  end if;

  return l_return_value;

END GET_DELIMITED_STRING;

PROCEDURE EDR_RAISE3( p_event_name  IN  varchar2,
                  p_event_key     IN  varchar2,
                  p_event_data  IN  clob default NULL,
      p_param_list  IN OUT  NOCOPY FND_TABLE_OF_VARCHAR2_255,
      p_send_date   IN  date   default NULL,
      p_param_value IN OUT  NOCOPY FND_TABLE_OF_VARCHAR2_255 ) IS

  --Bug 3207385: Start
  --This variable would now be a simple name/value param type.
  l_param_list fnd_wf_event.param_table;
  --Bug 3207385: End
  ith number := 1;
  len number := 1;
BEGIN

  len := p_param_list.COUNT;
  for ith in 1..len LOOP
    --l_param_list.extend;
    --Bug 3207385: Start
    --We just have to add the parameters directly into the parameter list.
    --wf_event.AddParameterToList( p_param_list(ith), p_param_value(ith),lparam_list);
    l_param_list(ith).param_name := p_param_list(ith);
    l_param_list(ith).param_value := p_param_value(ith);
    --Bug 3207385: End
  end LOOP;

  --Bug 3207385: Start
  --wf_event.raise3(p_event_name, p_event_key, p_event_data, l_param_list, p_send_date);
  --Call the new procedure "EDR_ERES_EVENT_PVT.RAISE_TABLE" to raise the business event.

  EDR_ERES_EVENT_PVT.RAISE_TABLE(P_EVENT_NAME,
                                 P_EVENT_KEY,
                                 P_EVENT_DATA,
                                 L_PARAM_LIST,
                                 L_PARAM_LIST.COUNT,
                                 P_SEND_DATE);

  --Recreate the param list and param value objects.
  p_param_list := FND_TABLE_OF_VARCHAR2_255();
  p_param_value := FND_TABLE_OF_VARCHAR2_255();

  for ith in 1..l_param_list.count LOOP
    p_param_list.extend;
    p_param_list(ith) := l_param_list(ith).param_name;

    p_param_value.extend;
    p_param_value(ith) := l_param_list(ith).param_value;
  end LOOP;
  --Bug 3207385: End
END EDR_RAISE3;

PROCEDURE EDR_NTF_HISTORY(  document_id   in varchar2,
                            display_type  in varchar2,
                            document      in out nocopy varchar2,
                            document_type in out nocopy varchar2) IS

 --Bug: 3499311 : Start - Specified Number format in call TO_NUMBER
  cursor NTF_HISTORY(document_id varchar2) is
  --Bug 4160412: Start
  --Modified query to ensure that signature details are fetched even though
  --signing reason is null.
  select SIGNATURE_SEQUENCE,USER_NAME,
         B.MEANING SIGNATURE_STATUS,
         SIGNATURE_TIMESTAMP,
         C.MEANING SIGNATURE_TYPE,
         (SELECT D.MEANING FROM WF_LOOKUPS D WHERE D.LOOKUP_CODE=A.SIGNATURE_REASON_CODE AND
          D.LOOKUP_TYPE='SIGNING_REASON_CODES') SIGNATURE_REASON_CODE,
         SIGNER_COMMENTS,
         --Bug 4113995: Start
         --Including overriding comments in the cursor.
         SIGNATURE_OVERRIDING_COMMENTS
         --Bug 4113995: End
  from EDR_ESIGNATURES A,
         FND_LOOKUPS B,
         WF_LOOKUPS C
  WHERE EVENT_ID=to_number(document_id,'999999999999.999999' ) AND
          A.SIGNATURE_STATUS=B.LOOKUP_CODE AND
          B.LOOKUP_TYPE='EDR_PSIG_ESIGNATURE' AND
          C.LOOKUP_CODE=A.SIGNATURE_TYPE AND
          C.LOOKUP_TYPE='PSIG_ESIGN_SIGNER_LOOKUP'
  --Bug 4272262: Start
  --Convert signature sequence to a number value before performing the
  --order by operation.
  order by  to_number(SIGNATURE_SEQUENCE,'999999999999.999999') desc;
  --Bug 4272262: End

  --Bug 4160412: End
  --Bug: 3499311 : End

    table_direction varchar2(1);
    table_type varchar2(1) ;
    table_width  varchar2(8);
    table_border varchar2(2);
    table_cellpadding varchar2(2);
    table_l_cellspacing varchar2(2) ;
    table_bgcolor varchar2(7);
    th_bgcolor varchar2(7) ;
    th_fontcolor varchar2(7) ;
    th_fontface varchar2(80) ;
    th_fontsize varchar2(2);
    td_bgcolor varchar2(7) ;
    td_fontcolor varchar2(7);
    td_fontface varchar2(80);
    td_fontsize varchar2(2);

  l_itype varchar2(30);
  l_ikey  varchar2(240);
  l_actid number;
  l_result_type varchar2(30);
  l_result_code varchar2(30);
  l_action varchar2(80);
  l_owner_role  varchar2(320);
  l_owner       varchar2(320);
  l_begin_date  date;
  i pls_integer;
  j pls_integer;
  l_delim     varchar2(1) ;
  l_cells       wf_notification.tdType;
  l_result varchar2(32767);
  L_SIGNATURE_SEQUENCE number;
  L_USER_NAME varchar2(240);
  L_SIGNATURE_STATUS varchar2(240);
  L_SIGNATURE_TIMESTAMP DATE;
  LSIGNER_COMMENTS varchar2(4000);
begin

    --Bug 4074173 : start
    table_direction  := 'L';
    table_type  := 'V';
    table_width  := '100%';
    table_border  := '0';
    table_cellpadding  := '3';
    table_l_cellspacing  := '1';
    table_bgcolor  := 'white';
    th_bgcolor  := '#cccc99';
    th_fontcolor  := '#336699';
    th_fontface := 'Arial, Helvetica, Geneva, sans-serif';
    th_fontsize  := '2';
    td_bgcolor  := '#f7f7e7';
    td_fontcolor := 'black';
    td_fontface := 'Arial, Helvetica, Geneva, sans-serif';
    td_fontsize  := '2';

    l_delim    := ':';
    --Bug 4074173 : end

  -- Bug 3841676 : Start
  -- Display EDR Signature History based on WF Document Type
  IF display_type = WF_NOTIFICATION.doc_text THEN
   document := NULL;
  ELSE
   j := 1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_SEQUENCE');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_NAME');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_STATUS');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_DATETIME');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_SIGNATURE_TYPE');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_REASON_CODE');
   j := j+1;
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_COMMENTS');
   j := j+1;
   --Bug 4113995: Start
   --Including overriding details in the signature history table.
   l_cells(j) := 'S:'||FND_MESSAGE.GET_STRING('EDR','EDR_NTF_OVERRIDING_DETAILS');
   j := j+1;
   --Bug 4113995: End

  i := 0;
  for histr in NTF_HISTORY(document_id) loop
    l_cells(j) := histr.SIGNATURE_SEQUENCE;
    j := j+1;
    l_cells(j) := 'S:'||wf_directory.GetRoledisplayname(histr.USER_NAME);
    j := j+1;
    l_cells(j) := 'S:'||histr.signature_status;
    j := j+1;
    --Bug 4687718: Start
    l_cells(j) := 'S:'||nvl(fnd_date.date_to_displayDT(histr.signature_timestamp,fnd_timezones.get_server_timezone_code),'&'||'nbsp;');
    --Bug 4687718: End
    j := j+1;
    l_cells(j) := 'S:'||nvl(histr.signature_type,'&'||'nbsp;');
    j := j+1;
    l_cells(j) := 'S:'||nvl(histr.SIGNATURE_REASON_CODE,'&'||'nbsp;');
    j := j+1;
    l_cells(j) := 'S:'||nvl(histr.signer_comments,'&'||'nbsp;');
    j := j+1;
    --Bug 4113995: Start
    --Including overriding details in the signature history table.
    l_cells(j) := 'S:'||nvl(histr.SIGNATURE_OVERRIDING_COMMENTS,'&'||'nbsp;');
    j := j+1;
    --Bug 4113995: End
    i := i+1;
  end loop;
    table_width := '100%';
    --Bug 4113995: Start
    --The signature history table will now have 8 columns.
    wf_notification.NTF_Table(l_cells,8,'HL',l_result);
    --Bug 4113995: End

    -- Bug 3787607 : Start
    -- Removed hard-coded usage of colors and used corresponding Style Sheet
    -- classes

    document:='<table><tr>'||
              '<td width="100%"><h2 class="x3w">'||
               FND_MESSAGE.GET_STRING('EDR','EDR_NTF_SIGNATURE_HISTORY')||
               '</h2></td></tr></table>'||
               '<table class="x1h" cellpadding="1" cellspacing="0" border="0" width="100%"><tr>' ||
               '<th scope="col" class="x1r">'||
               l_result ||'</th></tr> </table>';

    -- Bug 3787607 : End
  END IF;
  -- Bug 3841676 : End

  document_type:='text/html';

exception
  when OTHERS then
    wf_core.context('EDR_NTF_HISTORY', 'History',document_id);
    raise;
end EDR_NTF_HISTORY;

/* Get the standard WHO columns of a table row */
PROCEDURE getWhoColumns(creation_date     out nocopy date,
                        created_by        out nocopy number,
                        last_update_date  out nocopy date,
                        last_updated_by   out nocopy number,
                        last_update_login out nocopy number)
is
begin
  creation_date := sysdate;
  created_by := fnd_global.user_id();
  last_update_date := sysdate;
  last_updated_by := fnd_global.user_id();
  last_update_login := fnd_global.login_id();

end getWhoColumns;

--Bug 3164491: start
/* Get the userdisplayname for the fnd user */
function getUserDisplayName (p_username in varchar2)
return varchar2
is
l_displayname varchar2(400);
l_emailaddress varchar2(400);
l_notification_preference varchar2(30);
l_language varchar2(30);
l_teritory varchar2(30);

begin
  -- we are not using the wf_directory.getroledisplayname
  -- because we get a invalid number error when username
  -- contains a colon
  wf_directory.getroleinfo( ROLE => p_username,
                            DISPLAY_NAME => l_displayname,
                            EMAIL_ADDRESS => l_emailaddress,
                            NOTIFICATION_PREFERENCE => l_notification_preference,
                            LANGUAGE => l_language,
                            TERRITORY => l_teritory
                          );
  return l_displayname;
end getUserDisplayName;

/* get overriding details for the username */
function getOverridingDetails (p_username in varchar2)
return varchar2
is
l_error_num number;
l_error_msg varchar2(4000);
l_overriding_approver varchar2(80);
l_override varchar2(4000);
begin

  EDR_STANDARD.FIND_WF_NTF_RECIPIENT (P_ORIGINAL_RECIPIENT => p_username,
                                    P_MESSAGE_TYPE => 'EDRPSIGF',
                                    P_MESSAGE_NAME => 'PSIG_EREC_MESSAGE_BLAF',
                                    P_RECIPIENT => l_overriding_approver,
                                    P_NTF_ROUTING_COMMENTS => l_override,
                                    P_ERR_CODE => l_error_num,
                                    P_ERR_MSG => l_error_msg);
   IF  (l_ERROR_NUM > 0 ) THEN
     RAISE  EDR_OVERRIDE_DETAILS_ERR;
   END IF;

   return l_override;
end getOverridingDetails;

/* get actual recipient for the username */
function getActualRecipient (p_username in varchar2)
return varchar2
is
l_error_num number;
l_error_msg varchar2(4000);
l_overriding_approver varchar2(80);
l_override varchar2(4000);
begin

  EDR_STANDARD.FIND_WF_NTF_RECIPIENT (P_ORIGINAL_RECIPIENT => p_username,
                                    P_MESSAGE_TYPE => 'EDRPSIGF',
                                    P_MESSAGE_NAME => 'PSIG_EREC_MESSAGE_BLAF',
                                    P_RECIPIENT => l_overriding_approver,
                                    P_NTF_ROUTING_COMMENTS => l_override,
                                    P_ERR_CODE => l_error_num,
                                    P_ERR_MSG => l_error_msg);
   IF  (l_ERROR_NUM > 0 ) THEN
     RAISE EDR_OVERRIDE_DETAILS_ERR;
   END IF;

   return l_overriding_approver;

end  getActualRecipient;

--Bug 3589701 : start
--Unsupport the functionality to search by group as ame has not released it.
--Whenever ame supports it, we will uncomment this.
/* Get Userid from Ame */
/*
procedure getUseridFromAme (p_groupname in varchar2,
                            x_userid    out NOCOPY FND_TABLE_OF_VARCHAR2_255,
                            x_usergroupname out NOCOPY FND_TABLE_OF_VARCHAR2_255)
is
l_approval_group_id AME_APPROVAL_GROUPS.APPROVAL_GROUP_ID%TYPE;
l_approval_group_name AME_APPROVAL_GROUPS.NAME%TYPE;
l_parameter_values ame_util.longStringList;
l_parameter_names ame_util.stringList;
i integer;
ithelement integer := 0;
--get the amegroupid and groupname
cursor GET_AMEGROUP is select approval_group_id, name
                       from AME_APPROVAL_GROUPS
                       where upper(name) like p_groupname
                       and end_date is null;

BEGIN
 -- Begin Bug FIX 3388988
  x_userid :=FND_TABLE_OF_VARCHAR2_255();
  x_usergroupname :=FND_TABLE_OF_VARCHAR2_255();
 --End Bug Fix 3388988
 open GET_AMEGROUP;
  loop
    fetch GET_AMEGROUP into l_approval_group_id, l_approval_group_name;
    EXIT WHEN GET_AMEGROUP%NOTFOUND;
      -- call ame for the groupid and get all the memebers
      AME_APPROVAL_GROUP_PKG.GETGROUPMEMBERS (
                          APPROVALGROUPIDIN => l_approval_group_id,
                          MEMBERIDSOUT  => l_parameter_values,
                          MEMBERTYPESOUT => l_parameter_names);

      for i in 1 .. l_parameter_values.count loop
        --if the parameter name is USER_ID use it
        if ( (l_parameter_names(i) is not null) and
             (upper(l_parameter_names(i)) = 'USER_ID') ) then
           -- extend the array and add the userid to the list
           x_userid.extend;
     ithelement := ithelement + 1;
           x_userid(ithelement) := l_parameter_values(i);
           -- extend the array and add the groupname to the list
           x_usergroupname.extend;
           x_usergroupname(ithelement) := l_approval_group_name;
  end if;
      end loop;
  end loop;
  close GET_AMEGROUP;
END  getUseridFromAme;
*/
--Bug 3589701 : end
--Bug 3164491 : end

--Bug 3465204 : start
procedure getProfileValue (p_profile in varchar2, x_profileValue out nocopy varchar2)
is
begin
   x_profileValue := fnd_profile.value(NAME => p_profile);

end getProfileValue;


procedure getProfileValueSpecific  (p_profile in varchar2,
                                    p_user_id in number default null,
                                    p_responsibility_id in number default null,
                                    p_application_id in number default null,
                                    p_org_id in number default null,
                                    p_server_id number default null,
                                    x_profilevalue out nocopy varchar2)
is
begin
   x_profileValue := fnd_profile.value_specific (NAME => p_profile,
                                                 USER_ID => p_user_id,
                                                 RESPONSIBILITY_ID => p_responsibility_id,
                                                 APPLICATION_ID => p_application_id,
                                                 ORG_ID => p_org_id,
                                                 SERVER_ID => p_server_id);
end getProfileValueSpecific;

--Bug 3465204 : end

--Bug 3437422: Start
FUNCTION GET_USER_DATA
RETURN VARCHAR2
AS
  numeric_data_format varchar2(50);
  default_numeric_format varchar2(20);
  user_data varchar2(2000);
BEGIN

  --Bug 4074173 : start
  default_numeric_format := ',.';
  --Bug 4074173 : end

  numeric_data_format := fnd_profile.value('ICX_NUMERIC_CHARACTERS');
  numeric_data_format := nvl(numeric_data_format, default_numeric_format);
  user_data := '<NUMERIC_DATA><ICX_NUMERIC_CHARACTERS>'|| numeric_data_format||
               '</ICX_NUMERIC_CHARACTERS></NUMERIC_DATA>';

  return user_data;
END GET_USER_DATA;

PROCEDURE REPLACE_USER_DATA_TOKEN
(P_IN_XML          IN OUT NOCOPY   CLOB)
AS
  user_data varchar2(2000);
  user_data_token varchar2(40);
  token_position integer;
BEGIN

  --Bug 4074173 : start
  user_data_token := '#EDR_USER_DATA';
  --Bug 4074173 : end

  token_position:= DBMS_LOB.INSTR
                         (lob_loc    => p_in_xml,
                          pattern    => user_data_token,
                          offset     => 1,
                          nth        => 1);

  if (token_position> 0) then
    user_data := get_user_data;
    p_in_xml:= clob_replace(p_in_xml,user_data_token, user_data);
  end if;

END REPLACE_USER_DATA_TOKEN;

FUNCTION CLOB_REPLACE
(p_source IN CLOB,
 p_srch_str IN VARCHAR2,
 p_replace_str IN VARCHAR2)
return CLOB
AS

l_offset    number;
l_amount    number;
l_diff      number;
l_buffer    VARCHAR2(32767);
x_replaced_clob   clob;
l_temp_len    number;
l_temp_clob   clob;
l_len     number;
l_pos     number;
l_first_char          VARCHAR2(1);
BEGIN

DBMS_LOB.CREATETEMPORARY(x_replaced_clob, TRUE, DBMS_LOB.SESSION);
DBMS_LOB.CREATETEMPORARY(l_temp_clob, TRUE, DBMS_LOB.SESSION);


--Obtain the length of the source CLOB
l_len:=dbms_lob.getlength(p_source);

--Set the amount to the 32 KB
l_amount:=32767;

--Initial Offset is set to 1
l_offset:=1;

--Obtain the difference
l_diff:=l_len-l_offset;


--If true then length of search is greater than that of the replacement string
if length(p_srch_str)>=length(p_replace_str) then

  --If this condition is true then size of CLOB is less than 32 KB
  if l_diff <= 32766 then

    --Therefore convert the CLOB to VARCHAR2
    dbms_lob.read(p_source,l_len,1,l_buffer);

    --Perform the replace operation
    l_buffer:=replace(l_buffer,p_srch_str,p_replace_str);

    --Append the modified VARCHAR2 to an EMPTY CLOB.
    dbms_lob.writeappend(x_replaced_clob,length(l_buffer),l_buffer);


  --Size of input CLOB is greater than 32 KB
  else

    --Obtain the First Character of the search string
    l_first_char:=substr(p_srch_str,1,1);

    --Parse the CLOB in chunks of 32 KB
    while l_diff > 32766



      loop
        --Read 32 KB of the CLOB into buffer
        dbms_lob.read(p_source,l_amount,l_offset,l_buffer);

        --This statement is used to check for boundary condition
        --Check if the first character of the search String occurs anywhere,
        --at the boundary of the 32 KB buffer.
        l_pos:=instr(l_buffer,l_first_char,l_amount-length(p_srch_str)+2);

        --If this condition is true then boundary condition has occured
        if l_pos>0

          then
            --Set the amount to pos-1.
            l_amount:=l_pos-1;

            --Repopulate the buffer to read only the above calculated amount
            l_buffer:=substr(l_buffer,1,l_amount);

            --Perform the Replace operation for this buffer.
            l_buffer:=replace(l_buffer,p_srch_str,p_replace_str);

            --Append this buffer to the target CLOB
            dbms_lob.writeappend(x_replaced_clob,length(l_buffer),l_buffer);

            --Increment the offset by the amount already modified
            l_offset:=l_offset+l_amount;

            --Reset Amount back to 32 KB
            l_amount:=32767;

          --Boundary Condition has not occurred
                      else

            --Reset amount back to 32 KB
            l_amount:=32767;

            --Perform the replace operation
            l_buffer:=replace(l_buffer,p_srch_str,p_replace_str);

            --Append this buffer to the target CLOB
            dbms_lob.writeappend(x_replaced_clob,length(l_buffer),l_buffer);

            --Increment the offset by the amount already modified
            l_offset:=l_offset+l_amount;


        end if;

        --Obtain the final difference, i.e. the amount still to be parsed
        l_diff:=l_len-l_offset;

      end loop;


      if l_diff>0

        then
        --If difference is greater than zero, perform the replace operatiom
        --on this last chunk and append it to the target CLOB.
        l_amount:=l_diff+1;
        dbms_lob.read(p_source,l_amount,l_offset,l_buffer);
        l_buffer:=replace(l_buffer,p_srch_str,p_replace_str);
        dbms_lob.writeappend(x_replaced_clob,length(l_buffer),l_buffer);

      end if;

  end if;


else
--Length of search string is smaller than that of the replacement string

  --Initialize offset
  l_offset:=1;

  --Loop till the whole CLOB is searched
  while l_offset <= l_len

  loop
    --Search for the required string starting from specified offset
    l_pos:=dbms_lob.instr(p_source,p_srch_str,l_offset);

    if l_pos > 0 then
    --Search is a success

      --Obtain the chunk of CLOB that exists before the occurence
      --of the search string
      l_amount:=l_pos-l_offset;

      --Push this into the target CLOB
      l_temp_len:=dbms_lob.getlength(x_replaced_clob);
      if l_amount > 0 then
      dbms_lob.copy(x_replaced_clob,p_source,l_amount,l_temp_len+1,l_offset);
      end if;

      --Push the replacement string into the target CLOB
      if length(p_replace_str) > 0 then
      dbms_lob.writeappend(x_replaced_clob,length(p_replace_str),p_replace_str);
      end if;
      l_offset:=l_pos+length(p_srch_str);
    else
      --The search String was not found from the specified offset
      --Append, the chunk of source CLOB from the offset to the end, into the
      --target CLOB
      l_temp_len:=dbms_lob.getlength(x_replaced_clob);
      dbms_lob.copy(x_replaced_clob,p_source,l_len-l_offset+1,l_temp_len+1,l_offset);
      l_offset:=l_len+1;
    end if;
  end loop;
end if;

RETURN x_replaced_clob;

END CLOB_REPLACE;
--Bug 3437422: End


--Bug 3101047 : Start
--Procedure defined to obtain the user display name along with the
--originating system name and system id for a given user name
PROCEDURE GETUSERROLEINFO
(P_USER_NAME    IN VARCHAR2,
 X_USER_DISPLAY_NAME  OUT NOCOPY VARCHAR2,
 X_ORIG_SYSTEM    OUT NOCOPY VARCHAR2,
 X_ORIG_SYSTEM_ID OUT NOCOPY NUMBER)
 IS

 L_NOTIF_PREF VARCHAR2(30);
 L_LANGUAGE VARCHAR2(30);
 L_TERRITORY VARCHAR2(30);
 L_EMAIL_ADDRESS VARCHAR2(400);
 L_FLAG VARCHAR2(10);

BEGIN
WF_DIRECTORY.GETROLEINFOMAIL (ROLE => P_USER_NAME,
             DISPLAY_NAME => X_USER_DISPLAY_NAME,
                         EMAIL_ADDRESS => L_EMAIL_ADDRESS,
             NOTIFICATION_PREFERENCE => L_NOTIF_PREF,
             LANGUAGE => L_LANGUAGE,
             TERRITORY => L_TERRITORY,
             ORIG_SYSTEM => X_ORIG_SYSTEM,
             ORIG_SYSTEM_ID => X_ORIG_SYSTEM_ID,
             INSTALLED_FLAG => L_FLAG);
END GETUSERROLEINFO;

--Procedure to obtain the event display name for a given event name.
PROCEDURE GET_EVENT_DESCRIPTION(P_EVENT IN VARCHAR2,
                                P_DESCRIPTION OUT NOCOPY VARCHAR2)
IS

CURSOR c1 is
SELECT DISPLAY_NAME
from
wf_events_vl
WHERE NAME= P_EVENT;

BEGIN
  OPEN C1;
  FETCH c1 into P_DESCRIPTION;
  CLOSE C1;

EXCEPTION
WHEN OTHERS THEN
 P_DESCRIPTION:=NULL;

END GET_EVENT_DESCRIPTION;


-- Bug 3863508 : Start

--Procedure to obtain the user display name from EDR_PSIG_DETAILS if
--the value is not null. Else it is fetched from FND tables
PROCEDURE FETCH_USER_DISPLAY_NAME(P_USER_NAME IN VARCHAR2,
           P_SIGNATURE_ID IN NUMBER,
         X_USER_DISPLAY_NAME OUT NOCOPY VARCHAR2)
IS
l_displayname varchar2(400);

BEGIN

select user_display_name into l_displayname from edr_psig_details where
          signature_id=p_signature_id;
x_user_display_name:=nvl(l_displayname,edr_utilities.getuserdisplayname(p_user_name));

--Bug 3101047 : END
END FETCH_USER_DISPLAY_NAME;

-- Bug 3863508 : End

-- Bug 3630380 : Start
--Procedure to obtain the user display name given the user id
PROCEDURE FETCH_USER_DISPLAY_NAME(P_USER_ID IN NUMBER,
           X_USER_DISPLAY_NAME OUT NOCOPY VARCHAR2)
AS
BEGIN
    X_USER_DISPLAY_NAME := EDR_UTILITIES.getUserDisplayName(fnd_user_ap_pkg.get_user_name(P_USER_ID));
END FETCH_USER_DISPLAY_NAME;
-- Bug 3630380 : End


--Bug 2674799 : start
--changed to use new approversTable datatype.

--Bug 3607477 : Start
-- Filters the duplicate and deleted approvers from the list of all ame approvers
FUNCTION  GET_UNIQUE_AME_APPROVERS(P_APPROVER_LIST IN approvers_Table)
RETURN  approvers_Table
AS

l_unique_approver_list approvers_Table;
--Bug 4870886 : start
l_final_approver_list approvers_Table;
--Bug 4870886 : end
l_count   NUMBER := 1;
-- Bug 5167253 : start
l_unique_approver_list_tmp ame_util.approverRecord2;
-- Bug 5167253 : end
BEGIN
  IF p_approver_list is null THEN
    return l_unique_approver_list;
  END IF;

  FOR i in 1..p_approver_list.count LOOP
    IF(nvl(p_approver_list(i).approval_status,' ') <> 'REPEATED' AND
       nvl(p_approver_list(i).approval_status, ' ') <> 'SUPPRESSED') THEN

       l_unique_approver_list(l_count) := p_approver_list(i);
       l_count := l_count+1;
    END IF;
  END LOOP;

-- Bug 5167253 : start
  IF (l_unique_approver_list.count) > 1 then
    FOR j IN  REVERSE  1..(l_unique_approver_list.count-1) LOOP
      FOR i IN  1..j LOOP
        if(l_unique_approver_list(i).approver_order_number > l_unique_approver_list(i+1).approver_order_number) THEN
				l_unique_approver_list_tmp := l_unique_approver_list(i);
				l_unique_approver_list(i) := l_unique_approver_list(i+1);
				l_unique_approver_list(i+1) := l_unique_approver_list_tmp;
         END IF;
     END LOOP;
   END LOOP ;
  END IF;

-- Bug 5167253 : end

  --Bug 4870886 : Start
  l_final_approver_list := l_unique_approver_list;
  IF l_final_approver_list.count > 0 then

    l_final_approver_list(1).approver_order_number := 1;

    --This logic reorders the approver sequence appropriately.
    FOR i IN 1..(l_unique_approver_list.count - 1) LOOP
      IF l_unique_approver_list(i+1).approver_order_number=l_unique_approver_list(i).approver_order_number THEN
        l_final_approver_list(i+1).approver_order_number:=l_final_approver_list(i).approver_order_number;

      ELSE
        l_final_approver_list(i+1).approver_order_number:=l_final_approver_list(i).approver_order_number + 1;
      END IF;

    END LOOP;
  END IF;

  RETURN l_final_approver_list;
  --Bug 4870886 : End

END  GET_UNIQUE_AME_APPROVERS;
-- BUG 3607477 : End
-- Bug 2674799 : end


--Bug 3667036: Start
FUNCTION GET_XML_ATTRIBUTE
(
  P_EVENT_NAME       VARCHAR2,
  P_EVENT_KEY        VARCHAR2,
  p_XPATH_EXPRESSION VARCHAR2
)
RETURN VARCHAR2
AS
  l_api_version CONSTANT NUMBER := 1.0;
  l_return_status   VARCHAR2(1);
  l_msg_data        VARCHAR2(2000);
  l_XPATH_VALUE     VARCHAR2(2000);
  l_event_xml       CLOB;
BEGIN
  --read the xml from temp table
  select event_xml into l_event_xml
  from EDR_FINAL_XML_GT
  where event_name = p_event_name
  and event_key = p_event_key;

  --call the ecx api to get the value for the xpath
  ECX_STANDARD.GET_VALUE_FOR_XPATH
  (p_api_version       => l_api_version,
   x_return_status     => l_return_status,
   x_msg_data          => l_msg_data,
   p_XML_DOCUMENT      => l_event_xml,
   p_XPATH_EXPRESSION  => p_xpath_expression,
   x_XPATH_VALUE       => l_xpath_value
  );

RETURN l_XPATH_VALUE;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;

END GET_XML_ATTRIBUTE;

--Bug 3667036: End

--Bug 3621309: Start
--This API is defined to perform the required Database to XML
--and XML to XML transformation based on the event parameters
PROCEDURE GENERATE_XML_PAYLOAD(P_MAP_CODE      IN         VARCHAR2,
                               P_DOCUMENT_ID   IN         VARCHAR2,
                               P_RAW_XML       IN         CLOB,
                               P_EVENT_NAME    IN         VARCHAR2,
                               P_USE_CONTEXT   IN         VARCHAR2,
                               X_XML_PAYLOAD   OUT NOCOPY CLOB,
                               X_DISPLAY_XML   OUT NOCOPY CLOB
                              )
IS

  l_error_code     PLS_INTEGER;
  l_error_msg      VARCHAR2(2000);
  l_log_file       VARCHAR2(200);
  l_count          NUMBER;
  DB_TO_XML_ERROR  EXCEPTION;
  XML_TO_XML_ERROR EXCEPTION;

BEGIN
  --if the raw xml is not null it means that the data is existing in the database
  --and the map uses the database as the source
  if (p_raw_xml is null) then

    ecx_outbound.getXML(i_map_code         => P_MAP_CODE,
                        i_document_id      => P_DOCUMENT_ID,
                        i_debug_level      => 6,
                        i_xmldoc           => X_XML_PAYLOAD,
                        i_ret_code         => L_ERROR_CODE,
                        i_errbuf           => L_ERROR_MSG,
                        i_log_file         => L_LOG_FILE);

    --If the return code from ECX is a value other than 0 then
    --an error has occurred
    if(l_error_code <> 0) then
        raise DB_TO_XML_ERROR;
    end if;

  --Bug 3893101: Start
  --If Map Code is null then set the xml payload value to the raw XML value
  --itself.
  elsif P_MAP_CODE is null then

    X_XML_PAYLOAD := P_RAW_XML;
  --Bug 3893101: End

  else

    --else the map needs the source xml that would be transformed using the map
    ecx_inbound_trig.processXML(i_map_code    => P_MAP_CODE,
                                i_payload     => P_RAW_XML,
                                i_debug_level => 6,
                                i_ret_code    => L_ERROR_CODE,
                                i_errbuf      => L_ERROR_MSG,
                                i_log_file    => L_LOG_FILE,
                                o_payload     => X_XML_PAYLOAD);
    --If the return code from ECX is a value other than 0 then
    --an error has occurred
    if(l_error_code <> 0) then
        raise XML_TO_XML_ERROR;
    end if;

  end if;

  --replace the user data section of the xml generated from ecx
  replace_user_data_token(X_xml_PAYLOAD);

  if x_xml_payload is not null then
    --Manipulate the XML data to replace all occurrences of '<' with '&lt'
    --and all occurrences of '>' with '&gt'. Also prefix the CLOB with the
    --'<pre>' tag and append the CLOB with the '</pre>' tag. This ensures that
    --while rendering in a UI bean, the alignment is maintained.
    X_DISPLAY_XML := ADJUST_CLOB_FOR_DISPLAY(P_PAYLOAD      => X_XML_PAYLOAD,
                                             P_PAYLOAD_TYPE => 'XMLPAYLOAD'
                                            );
  end if;

  --if the api is used in the context of the validate setup ui page
  --we have to save the data in the glbal temp table in the database
  if (p_use_context = validate_setup_ui_ctx and p_raw_xml is not null) then

    --Check if row already exists in the global temp table for specified event
    --event name and event key.
    select count(*) into l_count from edr_final_xml_gt
                                 where event_name = p_event_name
                                 and event_key = p_document_id;
    if l_count > 0 then
      --A row exists, hence update the row.
      update edr_final_xml_gt
             set event_xml = X_XML_PAYLOAD
             where event_name = p_event_name
             and event_key = p_document_id;

    else
      --No row exists with the specified event name and event key.
      --Hence insert a row into the global temp table.
      insert into edr_final_xml_gt
      (event_name, event_key, event_xml)
      values
      (p_event_name, p_document_id, X_xml_PAYLOAD);

    end if;
  end if;

  EXCEPTION

  when DB_TO_XML_ERROR then
      FND_MESSAGE.SET_NAME('EDR','EDR_VALIDATE_XML_GEN_ERR');
      FND_MESSAGE.SET_TOKEN('OPERATION','DB to XML');
      FND_MESSAGE.SET_TOKEN('ERROR_DETAILS',l_error_msg);
      FND_MESSAGE.SET_TOKEN('LOG_DETAILS',l_log_file);
      APP_EXCEPTION.RAISE_EXCEPTION;

  when XML_TO_XML_ERROR then
      FND_MESSAGE.SET_NAME('EDR','EDR_VALIDATE_XML_GEN_ERR');
      FND_MESSAGE.SET_TOKEN('OPERATION','XML to XML');
      FND_MESSAGE.SET_TOKEN('ERROR_DETAILS',l_error_msg);
      FND_MESSAGE.SET_TOKEN('LOG_DETAILS',l_log_file);
      APP_EXCEPTION.RAISE_EXCEPTION;

  when others then
      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
      FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_UTILITIES');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GENERATE_XML_PAYLOAD');
      APP_EXCEPTION.RAISE_EXCEPTION;


END GENERATE_XML_PAYLOAD;


--This method is basically used to manipulate the CLOB provided
--for rendering on a OAF UI bean.
FUNCTION ADJUST_CLOB_FOR_DISPLAY(P_PAYLOAD      CLOB,
                                 P_PAYLOAD_TYPE VARCHAR2
                                 )
RETURN CLOB

AS

  L_TEMP_CLOB   CLOB;
  X_RETURN_CLOB CLOB;

BEGIN

  --Create a temporary clob
  DBMS_LOB.CREATETEMPORARY(x_return_clob, TRUE, DBMS_LOB.SESSION);

  --Prefix the <pre> tag.
  DBMS_LOB.WRITEAPPEND(X_RETURN_CLOB,5,'<pre>');

  if P_PAYLOAD_TYPE = 'XMLPAYLOAD' then
    --Payload is of type XMLPAYLOAD.
    --Therefore all occurrences of '<' should be replaced by '<' and
    --all occurrences of '>' should be replaced by '>'
    DBMS_LOB.CREATETEMPORARY(l_temp_clob, TRUE, DBMS_LOB.SESSION);
    L_TEMP_CLOB :=  EDR_UTILITIES.CLOB_REPLACE(P_PAYLOAD,'<','&lt');
    L_TEMP_CLOB := EDR_UTILITIES.CLOB_REPLACE(l_TEMP_CLOB,'>','&gt');
    DBMS_LOB.COPY(X_RETURN_CLOB,L_TEMP_CLOB,DBMS_LOB.GETLENGTH(L_TEMP_CLOB),6,1);
  else
    --Otherwise, just append the contents of L_TEMP_CLOB into X_RETURN_CLOB
    DBMS_LOB.COPY(X_RETURN_CLOB,P_PAYLOAD,DBMS_LOB.GETLENGTH(P_PAYLOAD),6,1);
  end if;

  --Append the </pre> tag.
  DBMS_LOB.WRITEAPPEND(X_RETURN_CLOB,6,'</pre>');

  RETURN X_RETURN_CLOB;

END ADJUST_CLOB_FOR_DISPLAY;

--This method is a wrapper over the ECX API. It is used to perform
--the XSLT transformation to create the e-record at run-time.
PROCEDURE XSLT_TRANSFORMATION ( p_xml_file               IN  CLOB,
                                p_xslt_file_name         IN  VARCHAR2,
                                p_XSLT_APPLICATION_CODE  IN  VARCHAR2,
                                p_XSLT_FILE_VER          IN  VARCHAR2,
                                x_output                 OUT NOCOPY CLOB,
                                x_retcode                OUT NOCOPY NUMBER,
                                x_retmsg                 OUT NOCOPY VARCHAR2
                              )
is

BEGIN

  --Create a temporary CLOB and copy the input contents from p_xml_file.
  --This is done because, the ECX API destroys the CLOB locator of the i/p
  --XML clob passed as parameter. Hence we create another CLOB and duplicate
  --the contents.
  DBMS_LOB.CREATETEMPORARY(X_OUTPUT, TRUE, DBMS_LOB.SESSION);
  DBMS_LOB.COPY(X_OUTPUT,p_xml_file,DBMS_LOB.GETLENGTH(p_xml_file));

  --Call the ECX api to perform the XSLT transformation.
  ECX_STANDARD.perform_xslt_transformation ( i_xml_file               => X_OUTPUT,
                                             i_xslt_file_name         => p_xslt_file_name,
                                             i_XSLT_FILE_VER          => p_xslt_file_ver,
                                             i_XSLT_APPLICATION_CODE  => p_xslt_application_code,
                                             i_retcode                => x_retcode,
                                             i_retmsg                 => x_retmsg
                                            );

  --Adjust the CLOB data so that it can rendered properly on the UI bean in OAF.
  X_OUTPUT := ADJUST_CLOB_FOR_DISPLAY ( P_PAYLOAD      => X_OUTPUT,
                                        P_PAYLOAD_TYPE => 'ERECORDPAYLOAD'
                                      );
end XSLT_TRANSFORMATION;

--This method is used to save the raw xml run-time data in the table EDR_RAW_XML_T
--This API is called when the developer mode is on.
PROCEDURE SAVE_RAW_XML( P_TRANSACTION_NAME IN VARCHAR2,
                        P_TRANSACTION_KEY  IN VARCHAR2,
                        P_RAW_XML          CLOB)
is

  L_COUNT_VALUE NUMBER;
  pragma AUTONOMOUS_TRANSACTION;

BEGIN

  --Verify if the row already exists with the given event name and event key
  select count(*) into L_count_Value
                  from EDR_RAW_XML_T
                  where event_name = p_transaction_name
                  and event_key = p_transaction_key;


  if(L_count_value > 0) then
    --Row already exists with the specified event name and event key.
    --There update the row.
    update EDR_RAW_XML_T set   RAW_XML = P_RAW_XML,
                               LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                               LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                               LAST_UPDATE_DATE = sysdate

           where event_name = p_transaction_name
           and event_key = p_transaction_key;

  else
    --No row exists with the specified event name and event key.
    --There insert a row into the table with the required details
    insert into EDR_RAW_XML_T(EVENT_NAME,
                              EVENT_KEY,
                              RAW_XML,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN,
                              LAST_UPDATE_DATE
                             )
                values ( p_transaction_name,
                         p_transaction_key,
                         p_raw_xml,
                         FND_GLOBAL.USER_ID,
                         sysdate,
                         FND_GLOBAL.USER_ID,
                         FND_GLOBAL.LOGIN_ID,
                         sysdate
                        );
  end if;
  --Commit the transaction.
  commit;

end SAVE_RAW_XML;

--This procedure obtains the required AME rule name,rule names, rule variables
--and rule values for a given event name and event key.
PROCEDURE GET_RULES_AND_VARIABLES
(
         P_EVENT_NAME              IN         VARCHAR2,
         P_EVENT_KEY               IN         VARCHAR2 DEFAULT NULL,
         X_AME_RULE_IDS            OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_AME_RULE_DESCRIPTIONS   OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_VARIABLE_NAMES          OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_VARIABLE_VALUES         OUT NOCOPY FND_TABLE_OF_VARCHAR2_255
)
IS

  l_esign_required varchar2(1);
  l_eRecord_required varchar2(1);

  l_rule_esign_required varchar2(1);
  l_rule_eRecord_required varchar2(1);
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
  l_temp_rule_names FND_TABLE_OF_VARCHAR2_255;
  l_temp_rule_values FND_TABLE_OF_VARCHAR2_255;
  l_rule_id NUMBER;
  l_variable_count NUMBER;
  -- bug 5586151 : start
  l_active_sub_guid varchar2(4000) := null;
  l_disabled_sub_guid varchar2(4000) :=null;
  l_disabled_sub_guid_count NUMBER :=0;
  NO_ERES_SUBSCRIPTIONS EXCEPTION;
  -- bug 5586151 : End
  CURSOR GET_EVT_SUBSCRIPTION_DETAILS IS
     select b.guid,A.status,b.status
     from
       wf_events a, wf_event_subscriptions b
     where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event_name
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
         -- bug 5586151 : start
           -- and b.STATUS = 'ENABLED'
         -- bug 5586151 : End
	 --Bug No 4912782- Start
	 and b.source_type = 'LOCAL'
	 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	 --Bug No 4912782- End
  l_no_enabled_eres_sub NUMBER;

  --The exception object to catch Multiple ERES subscriptions error.
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;

  l_change_signer varchar2(32);
  l_change_signer_defined varchar2(1);

BEGIN

  --Bug 4074173 : start
  l_esign_required :='N';
  l_eRecord_required :='N';
  l_change_signer := 'ALL';
  l_change_signer_defined :='N';
  --Bug 4074173 : end



  --Obtain the number of ERES subscriptions enabled for this event.
  select count(*)  INTO l_no_enabled_eres_sub
                   from wf_events a, wf_event_subscriptions b
                   where a.GUID = b.EVENT_FILTER_GUID
                   and a.name = p_event_name
                   and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
                   and b.STATUS = 'ENABLED'
			 --Bug No 4912782- Start
	  		 and b.source_type = 'LOCAL'
	  		 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	  		 --Bug No 4912782- End

  --If the count is greater than 1 than raise exception.
  IF l_no_enabled_eres_sub > 1 THEN
    RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
  ELSE
   -- bug 5586151 : start
	    --Else fetch the subscription details for the event.
		--    OPEN GET_EVT_SUBSCRIPTION_DETAILS;
		--    FETCH GET_EVT_SUBSCRIPTION_DETAILS INTO l_sub_guid,l_Event_status,l_sub_status;
		--    CLOSE GET_EVT_SUBSCRIPTION_DETAILS;
                OPEN GET_EVT_SUBSCRIPTION_DETAILS;
                LOOP
                  FETCH GET_EVT_SUBSCRIPTION_DETAILS INTO l_sub_guid,l_Event_status,l_sub_status;
                  EXIT WHEN GET_EVT_SUBSCRIPTION_DETAILS%NOTFOUND;
                  IF l_sub_status='ENABLED' THEN
                    l_active_sub_guid := l_sub_guid;
                    EXIT;
                  ELSE
                    l_disabled_sub_guid := l_sub_guid;
                    l_disabled_sub_guid_count := l_disabled_sub_guid_count+1;
                  END IF;
                END LOOP;
                CLOSE GET_EVT_SUBSCRIPTION_DETAILS;

                IF(l_active_sub_guid IS NULL and l_disabled_sub_guid_count > 1) THEN
                  RAISE NO_ERES_SUBSCRIPTIONS;
                ELSIF (l_active_sub_guid IS NULL and l_disabled_sub_guid_count = 0) THEN
                  RAISE NO_DATA_FOUND;
                ELSE
                   l_sub_guid := nvl(l_active_sub_guid,l_disabled_sub_guid);
                END IF;
	  -- bug 5586151 : End
  END IF;

  --If both event and subscription is enabled then
  --set the workflow variable parameters.
--  IF l_event_status='ENABLED' and l_sub_status='ENABLED' then
    IF l_sub_guid IS NOT NULL  then
    wf_event_t.initialize(evt);
    evt.setSendDate(sysdate);
    evt.setEventName(p_event_name);
    evt.setEventKey(p_event_key);

    --Bug 4704598: start
    --no need to do this as the way to fetch the subscription param is
    --changed
    --l_return_status:=wf_rule.setParametersIntoParameterList(l_sub_guid,evt);
    --Bug 4704598: end

    --If return status is success, then obtain the AME transaction name
    --from the subscription

    --Bug 4704598: start
    --comment this if and change the way subscription params are obtained
    --IF l_return_status='SUCCESS' THEN
    --  l_ame_transaction_type := NVL(wf_event.getValueForParameter('EDR_AME_TRANSACTION_TYPE',evt.Parameter_List),
    --                                                        evt.getEventName( ));

        l_ame_transaction_type := edr_indexed_xml_util.get_wf_params('EDR_AME_TRANSACTION_TYPE',l_sub_guid);
    --Bug 4704598: end

      --Obtain the application id and code.
      SELECT application_id,APPLICATION_SHORT_NAME into l_application_id,
                                                      l_application_code
          FROM FND_APPLICATION
          WHERE APPLICATION_SHORT_NAME in
                                       (SELECT OWNER_TAG from WF_EVENTS
                                        WHERE NAME=evt.getEventName( ));
      --For the obtained AME transaction, fetch the rules that are are
      --applicable for the specified transaction id.

      -- Bug 5167817 : start
      --Bug 5287504: Start
	  --Create a save point
	  --This is required because in previous versions of AME, all AME APIs
	  --stored the run-time data in temp tables and put a lock in it when executed..
	  --Since these tables are reused by other AME API's, their execution would
	  --fail because of this.
	  --Hence we always create a savepoint and rollback to remove this lock.
	  --AME has fixed this issue in recent patch, but for safety reasons,
	  --it is preferrable that this workaround is still utilized.
	  SAVEPOINT AME_RULES_AND_VARIABLES;
      BEGIN

        AME_API3.GETAPPLICABLERULES3(APPLICATIONIDIN    => l_application_Id,
                                     TRANSACTIONIDIN    => evt.getEventKey( ),
                                     TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName( )),
                                     RULEIDSOUT         => l_ruleids,
                                     RULEDESCRIPTIONSOUT=> l_rulenames);
          ROLLBACK TO AME_RULES_AND_VARIABLES;
      EXCEPTION
        WHEN OTHERS THEN
         -- Following statement clears all lock aquired by this session
         -- This is modified as part of bug fix 2639210
          ROLLBACK TO AME_RULES_AND_VARIABLES;
          FND_MESSAGE.SET_NAME('EDR','EDR_AME_SETUP_ERR');
          FND_MESSAGE.SET_TOKEN('TXN_TYPE',nvl(l_ame_transaction_type,evt.getEventName()));
          FND_MESSAGE.SET_TOKEN('ERR_MSG',sqlerrm);
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;
      --Bug 5287504: End

	-- Bug 5167817 : end
      --Obtain the application name
      select application_name into l_application_name
      from ame_Calling_Apps
      where FND_APPLICATION_ID=l_application_id
      and TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,evt.getEventName( ))
      --Bug 4652277: Start
      --and end_Date is null;
      and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
      --Bug 4652277: End

      --If no rules were found to be applicable then set the ruleid to -1
      --and other variables to null.
      if l_ruleids.count = 0 then
        l_ruleids.delete;
        l_rulenames.delete;
        l_ruleids(1) := -1;
        l_rulenames(1) := null;
      end if;

      --For each rule applicable in the transaction, obtain the rule variable
      --names and values.
      for i in 1..l_ruleids.count loop
        --These temporary variables are used to compute
        --the rule variable names and values.
        l_temp_rule_names := new FND_TABLE_OF_VARCHAR2_255();
        l_temp_rule_values := new FND_TABLE_OF_VARCHAR2_255();

        --Initialize variable count to zero
        l_variable_count := 1;

        l_rule_id := l_ruleids(i);
        wf_log_pkg.string(6, 'EDR_UTILITIES.GET_RULES_AND_VARIABLES','Rule_id: '||l_rule_id||' Rule '||l_rulenames(i));

        --Obtain the rule variable name and value for the specified rule name.

  -- Bug 3214495 : Start

        EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES(
                                              transactiontypeid =>NVL(l_ame_transaction_type,evt.getEventName( )),
                                              ameruleid          => l_rule_id,
                                              amerulename        => l_rulenames(i),
                                              ameruleinputvalues => l_rulevalues
                                             );

       -- Bug 3214495 : End

      wf_log_pkg.string(6, 'EDR_UTILITIES.GET_RULES_AND_VARIABLES','Total Input Values '||l_rulevalues.count );
      --If rule variables where found then compute the rules based on
      --the most restrictive rule.
      if l_rulevalues.count > 0 then
        for i in 1..l_rulevalues.count loop
          if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then
            l_rule_esign_required:=upper(l_rulevalues(i).input_value);
            --For ESIGN_REQUIRED, 'Y' preceds 'N'.
            --The value of ESIGN_REQUIRED preceds EREC_REQUIRED.
            if (upper(l_esign_required)='N' and l_rule_esign_required ='Y') then
              l_esign_required:= l_rule_esign_required;
            end if;
            --Set the temporary variables accordingly.
            l_temp_rule_names.extend;
            l_temp_rule_names(l_variable_count) := l_rulevalues(i).input_name;
            l_temp_rule_values.extend;
            l_temp_rule_values(l_variable_count) := l_esign_required;
            l_variable_count := l_variable_count + 1;
          --Similarly set the value of EREC_REQUIRED.
          elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then
            l_rule_erecord_required:=upper(l_rulevalues(i).input_value);

            if (upper(l_erecord_required)='N' and l_rule_erecord_required ='Y') then
               l_erecord_required:= l_rule_erecord_required;
            end if;

            l_temp_rule_names.extend;
            l_temp_rule_names(l_variable_count) := l_rulevalues(i).input_name;
            l_temp_rule_values.extend;
            l_temp_rule_values(l_variable_count) := l_erecord_required;
            l_variable_count := l_variable_count + 1;
            --For the CHANGE_SIGNERS variable,
            --NONE preceds ADHOC,
            --ADGOC preceds ALL
            elsif l_rulevalues(i).input_name = 'CHANGE_SIGNERS' then
              l_change_signer_defined := 'Y';

              if ( upper(l_change_signer)='ADHOC' and upper(l_rulevalues(i).input_value) ='NONE') then
                l_change_signer:= l_rulevalues(i).input_value;
              elsif ( upper(l_change_signer)='ALL' and upper(l_rulevalues(i).input_value) ='NONE') then
                l_change_signer:= l_rulevalues(i).input_value;
              elsif ( upper(l_change_signer)='ALL' and upper(l_rulevalues(i).input_value) ='ADHOC') then
                l_change_signer:= l_rulevalues(i).input_value;
              end if;
            else
              --If rule variable names are other than
              --ESIG_REQUIRED, EREC_REQUIRED,CHANGE_SIGNERS
              --then just obtain their values.
              l_temp_rule_names.extend;
              l_temp_rule_names(l_variable_count) := l_rulevalues(i).input_name;
              l_temp_rule_values.extend;
              l_temp_rule_values(l_variable_count) := l_rulevalues(i).input_value;
              l_variable_count := l_variable_count + 1;
            end if;
          --Increment the variable count value
          --The rationale behind using a separate counter for the temp
          --variables is that, the CHANGE_SIGNERS variable is set only
          --at the end of the procedure.
          end loop;
        end if;

        --If EREC_REQUIRED is set to 'Y'
        --then set the rule variables values
        --to that of the current rule.
        if l_rule_erecord_required ='Y' and l_esign_required='N' then
          if X_VARIABLE_VALUES is not null then
            X_VARIABLE_NAMES.delete;
            X_VARIABLE_VALUES.delete;
          end if;

          X_VARIABLE_NAMES := l_temp_rule_names;
          X_VARIABLE_VALUES := l_temp_rule_values;

        end if;

        --If ESIG_REQUIRED is set to 'Y'
        --then set the rule variables values
        --to that of the current rule.
        --The reason why this logic is repeated is that
        --ESIG_REQUIRED ='Y' takes precedence over
        --any value of EREC_REQUIRED.
        if l_rule_esign_required ='Y' then
          if X_VARIABLE_VALUES is not null then
            X_VARIABLE_NAMES.delete;
            X_VARIABLE_VALUES.delete;
          end if;

          X_VARIABLE_NAMES := l_temp_rule_names;
          X_VARIABLE_VALUES := l_temp_rule_values;
        end if;

        --If the no rule uptil now has set either of
        --ESIG_REQUIRED and EREC_REQUIRED to 'Y', then
        --set the rule variable values to that of the
        --current rule.
        if l_esign_required = 'N' and l_erecord_required = 'N' then
          if X_VARIABLE_VALUES is not null then
            X_VARIABLE_NAMES.delete;
            X_VARIABLE_VALUES.delete;
          end if;

          X_VARIABLE_NAMES := l_temp_rule_names;
          X_VARIABLE_VALUES := l_temp_rule_values;
        end if;

        --Delete the temporary variable contents if they exists.
        if l_temp_rule_names is not null then
          l_temp_rule_names.delete;
        end if;

        if l_temp_rule_values is not null then
          l_temp_rule_values.delete;
        end if;
      end loop;

      --If the change signer variable is defined then
      --set its value in the result array that has the most deterministic value
      --This workaround is required for change signers because, the variables
      --ESIGN_REQUIRED and EREC_REQUIRED have a precedence relationship between
      --themselves, while CHANGE_SIGNERS only has a precedence relationship
      --between its values not with any other variable.
      if l_change_signer_defined = 'Y' then
        if(X_VARIABLE_NAMES is null) then
          X_VARIABLE_NAMES := new FND_TABLE_OF_VARCHAR2_255();
          X_VARIABLE_VALUES := new FND_TABLE_OF_VARCHAR2_255();
        end if;

        X_VARIABLE_NAMES.extend;
        X_VARIABLE_VALUES.extend;

        X_VARIABLE_NAMES(X_VARIABLE_NAMES.count) := 'CHANGE_SIGNERS';
        X_VARIABLE_VALUES(X_VARIABLE_VALUES.count) := l_change_signer;
      end if;

      --Obtain the rule list from AME
      --If ruleids are not null then populate the out parameter variables.

      if l_ruleids(1) <> -1 then
        if l_ruleids.count > 0 then
          X_AME_RULE_IDS := NEW FND_TABLE_OF_VARCHAR2_255();
          X_AME_RULE_DESCRIPTIONS := NEW FND_TABLE_OF_VARCHAR2_255();
          for i in 1..l_rulenames.count loop
            X_AME_RULE_IDS.extend;
            X_AME_RULE_IDs(i) := l_ruleids(i);
            X_AME_RULE_DESCRIPTIONS.extend;
            X_AME_RULE_DESCRIPTIONS(i) := l_rulenames(i);
          end loop;
        end if;
      end if;

      wf_log_pkg.string(6, 'EDR_UTILITIES.GET_RULES_AND_VARIABLES','Signature Required :'||l_esign_required);
      wf_log_pkg.string(6, 'EDR_UTILITIES.GET_RULES_AND_VARIABLES','eRecord Required   :'||l_erecord_required);
    END IF;

  --Bug 4704598: start
  --  END IF;
  --Bug 4704598: end
  --

  EXCEPTION
   --In the event of multiple subscriptions raise an exception.
    WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
      FND_MESSAGE.SET_NAME('EDR','EDR_VALIDATE_MULTI_ERES_ERR');
      fnd_message.set_token( 'EVENT', p_event_name);
      raise_application_error(-20002,fnd_message.get);
    WHEN NO_DATA_FOUND THEN
    -- Bug 5586151 :start
     fnd_message.set_name('EDR', 'EDR_VALIDATE_NO_ERES_SUBS_ERR');
     fnd_message.set_token( 'EVENT_NAME', p_event_name);
     raise_application_error(-20003,fnd_message.get);
    WHEN NO_ERES_SUBSCRIPTIONS THEN
      FND_MESSAGE.SET_NAME('EDR','EDR_VALIDATE_NO_ACT_ERES_ERR');
      fnd_message.set_token( 'EVENT_NAME', p_event_name);
      raise_application_error(-20004,fnd_message.get);
    -- Bug 5586151 :End
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_UTILITIES');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_RULES_AND_VARIABLES');
      APP_EXCEPTION.RAISE_EXCEPTION;

END GET_RULES_AND_VARIABLES;

--Bug 3621309: end

-- Bug 3575265 :Start
-- Start of comments
-- API Name     : GET_TEST_SCENARIO_XML
-- Type     : PRIVATE UTILITY
-- Function   : This API is called by XML Gateway while producing EDR
--        ERES OAF Inter Event 4 Payload
-- Pre-reqs     : None
-- Parameters   :
-- IN     : P_TEST_SCENARIO_ID - TestScenarioId of the event being
--       tested
-- OUT            : P_PARTIAL_XML - XML returned to XML gateway which will
--                        be part of event payload
-- OUT            : P_TEST_SCENARIO - XML returned to XML gateway which will
--                        be part of event payload
-- OUT            : P_TEST_SCENARIO_INSTANCE - XML returned to XML gateway which will
--                        be part of event payload

PROCEDURE GET_TEST_SCENARIO_XML
(
  P_TEST_SCENARIO_ID IN NUMBER,
  P_PARTIAL_XML OUT NOCOPY VARCHAR2,
  P_TEST_SCENARIO OUT NOCOPY VARCHAR2,
  P_TEST_SCENARIO_INSTANCE OUT NOCOPY VARCHAR2
) IS

l_test_scenario_id number;
l_test_scenario VARCHAR2(1000);
l_test_scenario_instance VARCHAR2(1000);
BEGIN

  select test_scenario_id, test_scenario, test_scenario_instance
  into l_test_scenario_id, l_test_scenario, l_test_scenario_instance
  from edr_inter_event_test_scenarios
  where test_scenario_id = p_test_scenario_id;

  p_partial_xml := l_test_scenario_id;
  p_test_scenario := l_test_scenario;
  p_test_scenario_instance := l_test_scenario_instance;
END GET_TEST_SCENARIO_XML;

-- Bug 3575265 : End

-- Bug 3882605 : start

-- Start of comments
-- API name             : GET_PARENT_ERECORD_ID
-- Type                 : Private Utility.
-- Function             : fetches Parent eRecord ID for a given erecord. P_PARENT_ERECORD_ID will be NULL if not found
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_ID eRecord id for which parent erecord id need to be retrieved
-- OUT                  : P_PARENT_ERECORD_ID Parent eRecord id of a given eRecord

-- End of comments

PROCEDURE GET_PARENT_ERECORD_ID(P_ERECORD_ID IN NUMBER,
                                P_PARENT_ERECORD_ID OUT NOCOPY NUMBER)
IS
CURSOR c1 is
SELECT PARENT_ERECORD_ID
from
EDR_EVENT_RELATIONSHIP
WHERE CHILD_ERECORD_ID= P_ERECORD_ID;
BEGIN
  OPEN C1;
  FETCH c1 into P_PARENT_ERECORD_ID;
  CLOSE C1;
EXCEPTION
WHEN OTHERS THEN
 P_PARENT_ERECORD_ID:=NULL;
END GET_PARENT_ERECORD_ID;

-- Bug 3882605 : end

--Bug 3893101: Start
PROCEDURE GENERATE_EVENT_PAYLOAD ( P_EVENT_KEY   IN VARCHAR2,
                                   P_XML_CLOB_ID IN NUMBER )
is

l_event_xml               CLOB;
l_ret_code                PLS_INTEGER;
l_error_msg               VARCHAR2(2000);
l_log_file                VARCHAR2(200);

BEGIN

  --Call the ECX API to perform the DB to XML transformation
  ECX_OUTBOUND.GETXML( i_map_code => 'oracle.apps.edr.IntrEvnt.Event',
                       i_document_id => p_event_key,
                       i_debug_level => FND_LOG.G_CURRENT_RUNTIME_LEVEL,
                       i_xmldoc => l_event_xml,
                       i_ret_code => l_ret_code,
                       i_errbuf => l_error_msg,
                       i_log_file => l_log_file
                     );
  insert into EDR_PROCESS_ERECORDS_T(ERECORD_SEQUENCE_ID,
                                      PAYLOAD,
                                      CREATED_BY,
                                      CREATION_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_DATE)
  values(P_XML_CLOB_ID,
           l_event_xml,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate);

END GENERATE_EVENT_PAYLOAD;
--Bug 3893101: End


--Bug 2674799 : start

PROCEDURE GET_APPROVERS(
        p_APPLICATION_ID IN NUMBER,
        p_TRANSACTION_ID IN VARCHAR2,
        p_TRANSACTION_TYPE IN VARCHAR2,
        x_APPROVERS OUT NOCOPY APPROVERS_TABLE,
        x_RULE_IDS OUT NOCOPY ID_LIST,
        x_RULE_DESCRIPTIONS OUT NOCOPY STRING_LIST
     )
AS
  approvalProcessCompleteYN ame_util.charType;
  itemClasses ame_util.stringList;
  itemIndexes ame_util.idList;
  itemIds ame_util.stringList;
  itemSources ame_util.longStringList;
  ruleIndexes ame_util.idList;
  sourceTypes ame_util.stringList;

  approverList APPROVERS_TABLE;

BEGIN
       AME_API2.GETALLAPPROVERS6
             (
                        APPLICATIONIDIN    => p_application_id,
                        TRANSACTIONIDIN    => p_TRANSACTION_ID,
                        TRANSACTIONTYPEIN  => p_TRANSACTION_TYPE,
                        approvalProcessCompleteYNOut => approvalProcessCompleteYN,
                        APPROVERSOUT       => approverList,
                        itemIndexesOut => itemIndexes,
                        itemClassesOut => itemClasses,
                        itemIdsOut => itemIds,
                        itemSourcesOut => itemSources,
                        ruleIndexesOut => ruleIndexes,
                        sourceTypesOut => sourceTypes,
                        RULEIDSOUT         => x_RULE_IDS,
                        RULEDESCRIPTIONSOUT=> x_RULE_DESCRIPTIONS
                   );

       X_APPROVERS := GET_UNIQUE_AME_APPROVERS( approverList);
      --Bug 5724159 :Start
        IF (approverList.count=0) THEN
       /* This API does not return any rules when the number of approvers is 0 .
           so we need to call another API provided by AME to populate rule id's */

        SAVEPOINT AME_RULES_AND_VARIABLES;
         BEGIN

          AME_API3.GETAPPLICABLERULES3(APPLICATIONIDIN    =>p_application_Id,
                                     TRANSACTIONIDIN    =>p_TRANSACTION_ID,
                                     TRANSACTIONTYPEIN  => p_TRANSACTION_TYPE,
                                     RULEIDSOUT         => x_RULE_IDS,
                                     RULEDESCRIPTIONSOUT=> x_RULE_DESCRIPTIONS);
         ROLLBACK TO AME_RULES_AND_VARIABLES;
       EXCEPTION
       WHEN OTHERS THEN
        -- Following statement clears all lock aquired by this session
        -- This is modified as part of bug fix 2639210
          ROLLBACK TO AME_RULES_AND_VARIABLES;
          FND_MESSAGE.SET_NAME('EDR','EDR_AME_SETUP_ERR');
          FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_TRANSACTION_TYPE);
          FND_MESSAGE.SET_TOKEN('ERR_MSG',sqlerrm);
          APP_EXCEPTION.RAISE_EXCEPTION;
      END;
   END IF;
--Bug 5724159 :End

--Bug 5287504: Start
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_AME_SETUP_ERR');
    FND_MESSAGE.SET_TOKEN('TXN_TYPE',p_TRANSACTION_TYPE);
    FND_MESSAGE.SET_TOKEN('ERR_MSG',sqlerrm);
    APP_EXCEPTION.RAISE_EXCEPTION;
--Bug 5287504: End
END GET_APPROVERS;
-- Bug 2674799 : end


--Bug 4122622: Start
-- Start of comments
-- API name             : REPEATING_NUMBERS_EXIST
-- Type                 : Private Utility.
-- Function             : Checks if any of the number in the method
--                        are repeated. If so it returns true. Else it returns
--                        false.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_NUMBERS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE
--                      : Array of numbers.
-- RETURNS              : Boolean valye which indicates if any of the e-record ids
--                      : are repeating.

FUNCTION REPEATING_NUMBERS_EXIST(P_NUMBERS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE)

return boolean

is

i pls_integer;

j pls_integer;

l_repeating boolean;

BEGIN

  l_repeating := false;


  i := p_numbers.FIRST;

  while i is not null loop
    j := p_numbers.NEXT(i);

    --Iterate through the e-record ID list.
    while j is not null loop
      --Set the flag and exit as soon as a repeating e-record ID is found.
      if(p_numbers(i) = p_numbers(j)) then
        l_repeating := true;
        exit;
      end if;
      j := p_numbers.NEXT(j);
    end loop;

    if (l_repeating) then
      exit;
    end if;

    i := p_numbers.NEXT(i);
  end loop;

return l_repeating;

END REPEATING_NUMBERS_EXIST;


-- Start of comments
-- API name             : GET_ERECORD_IDS
-- Type                 : Private Utility.
-- PROCEDURE            : The procedure takes a comma separated string of
--                      : child e-record IDs and converts them into table of numbers.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_IDS_STRING IN VARCHAR2
--                      : Comma separated string of child e-record IDs.
-- OUT                  : X_ERECORD_IDS_ARRAY
--                      : The array of e-record ID values.

PROCEDURE GET_ERECORD_IDS(P_ERECORD_IDS_STRING IN VARCHAR2,
                          X_ERECORD_IDS_ARRAY OUT NOCOPY EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE)

is

l_current_erecord_id NUMBER;
l_current_erecord_id_string VARCHAR2(128);
l_erecord_ids_string VARCHAR2(4000);
l_pos NUMBER;
l_count NUMBER;
begin

  l_erecord_ids_string := p_erecord_ids_string;
  l_count := 1;


  while true loop
    --Search for each occurrence of the "," character.
    --Extract the child e-record Id that is occurring.
    l_pos := instr(l_erecord_ids_string,',');
    if(l_pos = 0) then
      l_current_erecord_id_string := l_erecord_ids_string;
      l_erecord_ids_string := substr(l_erecord_ids_string,l_pos+1,length(l_erecord_ids_string)-length(l_current_erecord_id_string) + 1);
      --Convert the string e-record ID into a Number value.
      l_current_erecord_id := to_number(l_current_erecord_id_string,'999999999999.999999');
      x_erecord_ids_array(l_count) :=  l_current_erecord_id;
      exit;
    end if;
    l_current_erecord_id_string := substr(l_erecord_ids_string,1,l_pos-1);
    l_erecord_ids_string := substr(l_erecord_ids_string,l_pos+1,length(l_erecord_ids_string)-length(l_current_erecord_id_string) + 1);
    --Convert the string e-record ID into a Number value.
    l_current_erecord_id := to_number(l_current_erecord_id_string,'999999999999.999999');
    x_erecord_ids_array(l_count) :=  l_current_erecord_id;
    l_count := l_count + 1;
  end loop;

END GET_ERECORD_IDS;
--Bug 4122622: End


--Bug 4160412: Start
--This method is used to obtain the a table of approvers from the comma separated string.
PROCEDURE GET_APPROVER_LIST(P_APPROVING_USERS       IN  VARCHAR2,
                            X_APPROVER_LIST         OUT NOCOPY EDR_UTILITIES.APPROVERS_TABLE,
                            X_ARE_APPROVERS_VALID   OUT NOCOPY VARCHAR2,
                            X_INVALID_APPROVERS     OUT NOCOPY VARCHAR2)
IS

  l_list_counter           NUMBER;
  l_count                  NUMBER;
  l_pos                    NUMBER;
  l_approving_users        VARCHAR2(4000);
  l_current_approving_user VARCHAR2(4000);

BEGIN

  l_approving_users := upper(p_approving_users);

  l_list_counter := 1;


  X_ARE_APPROVERS_VALID := 'Y';

  while true loop

    --Search for each occurrence of the "," character.
    --Extract the user name for which it is occurring.
    l_pos := instr(l_approving_users,',');
    if(l_pos = 0) then

      --Check if the specified user name is an FND USER.
      select count(*) into l_count from wf_roles
      where name = l_approving_users
      and status = 'ACTIVE'
      and (orig_system = 'PER' or ORIG_SYSTEM = 'FND_USR');


      --If count is zero then, then check if the specified user name is a responsibility.
      if(l_count = 0) then

        --Check if the specified user name is a responsibility
        select count(*) into l_count from wf_roles
        where name = l_approving_users
        and status = 'ACTIVE'
        and orig_system = 'FND_RESP';

        --If this count is also zero then the specified approver name is invalid.
        if l_count  = 0 then
          X_ARE_APPROVERS_VALID := 'N';
          X_INVALID_APPROVERS := X_INVALID_APPROVERS || ',' || l_approving_users;
        else
          X_APPROVER_LIST(l_list_counter).NAME := '#'||l_approving_users;
          X_APPROVER_LIST(l_list_counter).APPROVER_ORDER_NUMBER := l_list_counter;
        end if;
      else
        X_APPROVER_LIST(l_list_counter).NAME := l_approving_users;
        X_APPROVER_LIST(l_list_counter).APPROVER_ORDER_NUMBER := l_list_counter;
      end if;

      exit;

    end if;

    IF l_pos > 1 then

      --Extract the approver from the comma separated string.
      l_current_approving_user := substr(l_approving_users,1,l_pos-1);

      --Filter the source string to remove the approvers extracted in the previous step.
      l_approving_users := substr(l_approving_users,l_pos+1,length(l_approving_users)-length(l_current_approving_user) + 1);

      --Check if the specified user name is an fnd user.
      select count(*) into l_count from wf_roles
      where name = l_current_approving_user
      and status = 'ACTIVE'
      and (orig_system = 'PER' or orig_system = 'FND_USR');

      --If count is zero then, then check if the specified user name is a responsibility.
      if(l_count = 0) then

        --Check if the specified user name is a responsibility
        select count(*) into l_count from wf_roles
        where name = l_current_approving_user
        and status = 'ACTIVE'
        and orig_system = 'FND_RESP';

        --If this count is also zero then the specified approver name is invalid.
        if l_count = 0 then
          X_ARE_APPROVERS_VALID := 'N';
          X_INVALID_APPROVERS := X_INVALID_APPROVERS || ',' || l_current_approving_user;
        else
          X_APPROVER_LIST(l_list_counter).NAME := '#'||l_current_approving_user;
          X_APPROVER_LIST(l_list_counter).APPROVER_ORDER_NUMBER := l_list_counter;
          l_list_counter := l_list_counter + 1;
        end if;
      else
        X_APPROVER_LIST(l_list_counter).NAME := l_current_approving_user;
        X_APPROVER_LIST(l_list_counter).APPROVER_ORDER_NUMBER := l_list_counter;
        l_list_counter := l_list_counter + 1;
      end if;
    else
      if l_approving_users is null or length(l_approving_users) = 0 then
        exit;
      else
        --The control would come here if there were multiple commas specified in sequence.
        l_approving_users := substr(l_approving_users,l_pos+1,length(l_approving_users));
      end if;
    end if;
  end loop;

  if length(x_invalid_approvers) > 0 then
    --Trim the invalid approvers string to remove the extra comma prefixed.
    x_invalid_approvers := ltrim(x_invalid_approvers,',');
  end if;

END GET_APPROVER_LIST;


--This functions would return true if the approver list contains repeating approvers.
--Otherwise it returns false.
FUNCTION ARE_APPROVERS_REPEATING(P_APPROVER_LIST IN EDR_UTILITIES.APPROVERS_TABLE)

RETURN BOOLEAN

IS

i NUMBER;
j NUMBER;
l_repeating boolean;

BEGIN

l_repeating := false;

--Iterate through each approver in the list to identify the repeating approver.
for i in 1..p_approver_list.count loop

  if instr(p_approver_list(i).name,'#') <> 1 then
    for j in i+1..p_approver_list.count loop

      if i <> j then
        if instr(p_approver_list(j).name,'#') <> 1 and upper(p_approver_list(i).name) = upper(p_approver_list(j).name) then
          --A repeating approver was found. Hence set the boolean variable to true.
          l_repeating := true;
          exit;
        end if;
      end if;
    end loop;
  end if;

  if l_repeating then
    exit;
  end if;

end loop;

return l_repeating;

END ARE_APPROVERS_REPEATING;
--Bug 4160412: End

-- FP Bug 5564086 : Starts
 /* Internal API to get the commited value , out of the session. */

  FUNCTION GET_OLD_VALUE(P_TABLE_NAME IN VARCHAR2,
                         P_COLUMN     IN VARCHAR2,
                         P_PKNAME     IN VARCHAR2,
                         P_PKVALUE    IN VARCHAR2
                         )
             return varchar2  IS PRAGMA AUTONOMOUS_TRANSACTION;
  l_value VARCHAR2(4000);
  BEGIN
     EXECUTE IMMEDIATE 'select ' ||P_COLUMN||' from '||P_TABLE_NAME ||' where '||
                      P_PKNAME||'='||P_PKVALUE ||' ' into l_value;
     return l_value;
  END GET_OLD_VALUE;

  -- Function to return  'true' or 'false' if a column has been updated.
  FUNCTION HAS_ATTRIBUTE_CHANGED(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2,
                              P_TRACK_INSERT IN VARCHAR2
                             )
             return varchar2 IS
  l_CURRENT_VALUE varchar2(4000);
  l_OLD_VALUE varchar2(4000);

  BEGIN
    EXECUTE IMMEDIATE 'select ' ||P_COLUMN||' from '||P_TABLE_NAME ||' where '||P_PKNAME||
                       '='||P_PKVALUE ||' ' into l_current_value;

    begin
      l_old_value := get_old_value(P_TABLE_NAME,P_COLUMN,P_PKNAME,P_PKVALUE);
    exception  when no_data_found then
      if(P_TRACK_INSERT = 'Y' AND l_current_value is not null) then
        return 'true';
      else
         return 'false';
      end if;
    end;

    if (l_old_value <> l_current_value) then
      return 'true';
    else
     return 'false';
     end if;
  EXCEPTION WHEN OTHERS THEN
    return 'false';

  END HAS_ATTRIBUTE_CHANGED;


/* This function will compare audit values and return true or false based on the the results */

 FUNCTION HAS_ATTRIBUTE_CHANGED(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2
                             )
             return varchar2 IS
 BEGIN
    return HAS_ATTRIBUTE_CHANGED(P_TABLE_NAME => P_TABLE_NAME,
                                 P_COLUMN => P_COLUMN,
                                 P_PKNAME => P_PKNAME,
                                 P_PKVALUE => P_PKVALUE,
                                 P_TRACK_INSERT => 'N');
 END HAS_ATTRIBUTE_CHANGED;
-- FP Bug 5564086 : Ends






END EDR_UTILITIES;

/
