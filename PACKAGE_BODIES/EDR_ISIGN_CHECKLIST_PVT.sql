--------------------------------------------------------
--  DDL for Package Body EDR_ISIGN_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ISIGN_CHECKLIST_PVT" AS
/* $Header: EDRVISCB.pls 120.8.12000000.1 2007/01/18 05:56:21 appldev ship $ */

-- GLOBAL decleration

G_ENTITY_NAME constant varchar2(10) := 'ERECORD';


-- --------------------------------------
-- API name 	: IS_CHECKLIST_REQUIRED
-- Type		: Public
-- Pre-reqs	: None
-- procedue	: return Y/N based on checklsit steup and if Y, returns checlist name and checklist version
-- Parameters
-- IN	      :	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--			p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_isRequired_checklist	VARCHAR2	Checklist status
-- OUT	:	x_checklist_name		VARCHAR2	Checklist Name
-- OUT	:	x_checklist_ver   	VARCHAR2	Checklist Version

-- ---------------------------------------


PROCEDURE IS_CHECKLIST_REQUIRED  (
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	            IN   	varchar2,
	x_isRequired_checklist 	      OUT 	NOCOPY VARCHAR2,
      x_checklist_name              OUT   NOCOPY VARCHAR2,
      x_checklist_ver               OUT   NOCOPY VARCHAR2) IS

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
  approverList     ame_util.approversTable;

  l_isRequired_checklist varchar2(1);
  l_rule_checklist varchar2(1);
  l_temp_template      varchar2(200);
  l_temp_template_ver  varchar2(200);
  CURSOR GET_EVT_SUBSCRIPTION_DETAILS IS
     select b.guid,A.status,b.status
     from
       wf_events a, wf_event_subscriptions b
     where a.GUID = b.EVENT_FILTER_GUID
       and a.name = p_event_name
       and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
       and b.STATUS = 'ENABLED'
	 --Bug No 4912782- Start
	 and b.source_type = 'LOCAL'
	 and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	 --Bug No 4912782- End
  l_no_enabled_eres_sub NUMBER;
  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
BEGIN

     --Bug 4074173 : GSCC Warning
     l_isRequired_checklist :='N';

     SAVEPOINT CHECKLIST_REQUIRED;
     x_isRequired_checklist:='N';
     x_checklist_name:=NULL;
     x_checklist_ver:=NULL;

    -- Verify is more than one active ERES subscriptions are present
    --
        select count(*)  INTO l_no_enabled_eres_sub
        from
          wf_events a, wf_event_subscriptions b
        where a.GUID = b.EVENT_FILTER_GUID
          and a.name = p_event_name
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

               wf_event_t.initialize(evt);
               evt.setSendDate(sysdate);
               evt.setEventName(p_event_name);
               evt.setEventKey(p_event_key);
               -- Bug 5639849 : Starts
               -- No need loading all subscription parameters to event, just use
               -- edr_indexed_xml_util API to get ame_transaction _type parameter
               --l_return_status:=wf_rule.setParametersIntoParameterList(l_sub_guid,evt);

               --IF l_return_status='SUCCESS' THEN
                  /* Check for User Defined Parameters,
                    contains AME transactions Type
                    If Parameters are not specified, Assume Event name to be AME transaction Type

                   */
              l_ame_transaction_type:= NVL(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE',l_sub_guid), evt.getEventName( ));
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
               		      ); */

                --Bug 5287504: Start
		BEGIN
                  AME_API3.GETAPPLICABLERULES3
                      (	APPLICATIONIDIN    => l_application_Id,
				      TRANSACTIONIDIN    => evt.getEventKey( ),
				      TRANSACTIONTYPEIN  => NVL(l_ame_transaction_type,evt.getEventName( )),
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
                	  select application_name into l_application_name
                	  from ame_Calling_Apps
                	  where FND_APPLICATION_ID=l_application_id
                	  and TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,evt.getEventName( ))
                          --Bug 4652277: Start
                          --and end_Date is null;
                          and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
                          --Bug 4652277: End



                       /* check if any rules are satisfied, if not pick the variables from transaction */
                         if l_ruleids.count < 1 then
                             l_ruleids(1) := -1;
                             l_rulenames(1) := Null;
                         END IF;

              	       for i in 1..l_ruleids.count loop

		       -- Bug 3214495 : Start

                 	          EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES(transactiontypeid =>NVL(l_ame_transaction_type,evt.getEventName( )),
                  	        		                         ameruleid =>l_ruleids(i),
                   		       		                   amerulename=>l_rulenames(i),
                    		      		                   ameruleinputvalues=>l_rulevalues);
			-- Bug 3214495 : End
                        	    if l_rulevalues.count > 0 then
                        	       for i in 1..l_rulevalues.count loop
                         	       	if l_rulevalues(i).input_name = 'CHECKLIST_REQUIRED' then
                          	    		if (l_isRequired_checklist='N' and l_rulevalues(i).input_value ='Y') then
                           	               		l_rule_checklist:= l_rulevalues(i).input_value;
                            	            	end if;
                             	   	elsif l_rulevalues(i).input_name = 'CHECKLIST_TEMPLATE' then
                                            	l_temp_template:= l_rulevalues(i).input_value;
                             	   	elsif l_rulevalues(i).input_name = 'CHECKLIST_TEMPLATE_VER' then
                                            	l_temp_template_ver:= l_rulevalues(i).input_value;
                                       	end if;
                                          /* Assign Appropriate values based on most stringent rules*/
                                            if l_rule_checklist = 'Y' then
                                               x_isRequired_checklist:=l_rule_checklist;
      						     x_checklist_name:=l_temp_template;
                                               x_checklist_ver:= l_temp_template_ver;
                                            end if;
                                     end loop;
                                 end if;
                         END LOOP;
                    -- bug 5639849 : Starts
                    -- Commented the if return_status statement
                    -- END IF;
                    -- bug 5639849 : End if

      -- Following statement clears all lock aquired by this session


                   ROLLBACK TO CHECKLIST_REQUIRED;

EXCEPTION
   WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
     x_isRequired_checklist:='N';
     x_checklist_name:=NULL;
     x_checklist_ver:=NULL;
     ROLLBACK TO CHECKLIST_REQUIRED;
     FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRP_ERR');
     fnd_message.set_token( 'EVENT', p_event_name);
     --Bug 4162993: Start
     APP_EXCEPTION.RAISE_EXCEPTION;
     --Bug 4162993: End
   WHEN OTHERS THEN
     x_isRequired_checklist:='N';
     x_checklist_name:=NULL;
     x_checklist_ver:=NULL;
     ROLLBACK TO CHECKLIST_REQUIRED;
     FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
     FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_ISIGN_CHECKLIST_PVT');
     FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','IS_CHECKLIST_REQUIRED ');
     --Bug 4162993: Start
     APP_EXCEPTION.RAISE_EXCEPTION;
     --Bug 4162993: End
END IS_CHECKLIST_REQUIRED;


-- --------------------------------------
-- API name 	: IS_CHECKLIST_PRESENT
-- Type		: Private
-- Pre-reqs	: None
-- procedue	: Procedure will notify if checklist is availalb for a given file_id
-- Parameters
-- IN	      :	p_file_id   		NUMBER	file_id of iSign
-- OUT	:	x_checklist_status	VARCHAR2	Checklist Status
--                                              	Y - Checklist Present
--                                              	N - Checklist not avalable
-- ---------------------------------------



PROCEDURE IS_CHECKLIST_PRESENT  (
       	                                p_file_id	       	IN 	NUMBER,
		                        x_checklist_Status      OUT   NOCOPY VARCHAR2) IS

Cursor c1 is select count(*) from fnd_attached_documents
where ENTITY_NAME='EDR_FILES_B' and
      pk1_value=p_file_id and
      document_id in (select document_id from fnd_documents_vl where category_id in
                              (select category_id
				              from fnd_document_categories_vl
				              where name = 'EDR_ISIGN_ADDL_FILES'));
l_count number;
BEGIN

   OPEN c1;
    fetch c1 into l_count;
   CLOSE c1;

    if l_count > 0 then
        x_checklist_Status:='Y';
    else
        x_checklist_Status:='N';
    end if;

exception
when others then
      x_checklist_Status:='N';
END IS_CHECKLIST_PRESENT;


-- --------------------------------------
-- API name 	: ATTACH_CHECKLIST
-- Type		: Public
-- Pre-reqs	: None
-- procedue	: Procedure to Attach checklist to evidence store entity if available
-- Parameters
-- IN	      :	p_file_id   	NUMBER	file_id of iSign
-- OUT	:	x_return_status	VARCHAR2	Attachment Status
--                                              S - Successful
--                                              E - Error
-- ---------------------------------------


PROCEDURE ATTACH_CHECKLIST  (
	p_file_id		       	IN 	NUMBER,
	x_return_Status               OUT   NOCOPY VARCHAR2)
AS PRAGMA AUTONOMOUS_TRANSACTION;

      l_return_status varchar2(100);
      l_msg_count number;
      l_msg_data varchar2(4000);
      l_erecord_id number;
      l_category_id NUMBER;
      l_checklist_status VARCHAR2(1);
Begin
       -- Check if checklsit exists for the file
          EDR_ISIGN_CHECKLIST_PVT.IS_CHECKLIST_PRESENT(p_file_id =>p_file_id,
                                                        x_checklist_Status=>l_checklist_Status
							);

  If l_checklist_status= 'Y' THEN

       -- get the erecord id for the file
      EDR_STANDARD_PUB.GET_ERECORD_ID(
               P_API_VERSION => 1.0,
               P_INIT_MSG_LIST => FND_API.G_FALSE,
               X_RETURN_STATUS => l_return_status,
               X_MSG_COUNT     => l_msg_count,
               X_MSG_DATA      => l_msg_data,
               P_EVENT_NAME    => 'oracle.apps.edr.file.approve',
               P_EVENT_KEY     =>  p_file_ID,
               X_ERECORD_ID    => l_erecord_id);

            -- Make an attachemtn to erecord entity
      IF (L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS and l_erecord_id is not NULL) THEN
          -- call copy attachment for each category
                /* select Catgory id of checklist   */
				select category_id into l_category_id
				from fnd_document_categories_vl
				where name = 'EDR_ISIGN_ADDL_FILES';

        --Bug 4381237: Start
        --Change the call to edr attachment API
	--fnd_attached_documents2_pkg.copy_attachments
	edr_attachments_grp.copy_attachments
	--Bug 4381237: End
        (X_from_entity_name 		=> 'EDR_FILES_B',
         X_from_pk1_value 		=> p_file_id,
         X_from_pk2_value 		=> NULL,
         X_from_pk3_value 		=> NULL,
         X_from_pk4_value 		=> NULL,
         X_from_pk5_value 		=> NULL,
         X_to_entity_name 		=> G_ENTITY_NAME,
         X_to_pk1_value                 => l_erecord_id,
         X_to_pk2_value                 => null,
         X_to_pk3_value                 => null,
         X_to_pk4_value                 => null,
         X_to_pk5_value                 => null,
         X_created_by 			=> fnd_global.user_id,
         X_last_update_login 		=> fnd_global.login_id,
         X_program_application_id 	=> null,
         X_program_id 			=> null,
         X_request_id 			=> null,
         X_automatically_added_flag 	=> null,
         X_from_category_id            	=> l_category_id,
         X_to_category_id              	=> l_category_id);
         END IF;
    END IF;
    COMMIT;
    x_return_Status:='S';
exception
when others then
    ROLLBACK;
    x_return_Status:='E';
END ATTACH_CHECKLIST;

PROCEDURE DELETE_CHECKLIST  (
	p_file_id		       	IN 	NUMBER,
	x_return_Status               OUT   NOCOPY VARCHAR2) IS
      l_return_status varchar2(100);
      l_attach_document_id number;
Cursor c1 is select ATTACHED_DOCUMENT_ID from fnd_attached_documents
where ENTITY_NAME='EDR_FILES_B' and
      pk1_value=p_file_id and
      document_id in (select document_id from fnd_documents_vl where category_id in
                              (select category_id
				              from fnd_document_categories_vl
				              where name = 'EDR_ISIGN_ADDL_FILES'));
Begin

   OPEN c1;
     fetch c1 into l_attach_document_id ;
     IF c1%FOUND THEN
      -- Delete Checklist
        fnd_attached_documents3_pkg.DELETE_ROW(
                   X_ATTACHED_DOCUMENT_ID=> l_attach_document_id ,
                   X_DATATYPE_ID         => 6,
                   DELETE_DOCUMENT_FLAG  => 'Y');
     END IF;
   CLOSE c1;

 x_return_Status:='S';
exception
when others then
    x_return_Status:='E';
END DELETE_CHECKLIST;

END EDR_ISIGN_CHECKLIST_PVT;

/
