--------------------------------------------------------
--  DDL for Package Body OKS_CT_EVENTS_WFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CT_EVENTS_WFA" AS
/* $Header: OKSCTEVB.pls 120.2 2006/02/23 01:08:12 jvorugan noship $ */

-- ***************************************************************************
-- *									     *
-- *			   Contract EVENT Item Type 			     *
-- *									     *
-- ***************************************************************************

        	l_user_id number;
		l_resp_id number;
		l_resp_appl_id number;

PROCEDURE SELECTOR (
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funcmode      	IN VARCHAR2,
		result    	OUT NOCOPY VARCHAR2 ) IS
		l_user_id number;
		l_resp_id number;
		l_resp_appl_id number;
        	l_forward_to_username varchar2(30);
BEGIN
 	IF (funcmode = 'RUN') THEN

 /*
    		FND_PROFILE.Get('OKS_SERVICE_REQUEST_CREATOR', l_forward_to_username);


      		wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'FORWARD_TO_USERNAME' ,
                    avalue  => l_forward_to_username);
       BEGIN
       	select user_id into l_user_id
       	from fnd_user
       	where user_name = l_forward_to_username;
       EXCEPTION
        when others then
        null;
       END;

       WF_ENGINE.SetItemAttrNumber (
                    itemtype  => itemtype,
                    itemkey   => itemkey,
                    aname     => 'USER_ID',
                    avalue    => l_user_id
                    );
*/

		result := 'CREATE_SR'; --'COMPLETE';
 -- Engine calls SET_CTX just before activity execution
   	ELSIF (funcmode = 'SET_CTX') THEN
          -- First get the user id, resp id, and appl id

      --FND_GLOBAL.Apps_Initialize(1001296, 21708, 515);
/*
      FND_PROFILE.Get('OKS_SERVICE_REQUEST_CREATOR', l_forward_to_username);


      wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'FORWARD_TO_USERNAME' ,
                    avalue  => l_forward_to_username);
       BEGIN
       select user_id into l_user_id
       from fnd_user
       where user_name = l_forward_to_username;
       EXCEPTION
        when others then
        null;
       END;

       WF_ENGINE.SetItemAttrNumber (
                    itemtype  => itemtype,
                    itemkey   => itemkey,
                    aname     => 'USER_ID',
                    avalue    => l_user_id
                    );
*/
     result := 'CREATE_SR'; --'COMPLETE';

END IF;

EXCEPTION
	WHEN OTHERS then
		WF_CORE.context(OKS_CT_EVENTS_WFA.l_pkg_name,'Selector',itemtype,itemkey,actid,funcmode);
		raise;
END SELECTOR;

-- ---------------------------------------------------------------------------
-- Get Values
--   This procedure corresponds to the GET_VALUES function activity.
-- ---------------------------------------------------------------------------

PROCEDURE GET_VALUES(
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funcmode      	IN VARCHAR2,
		result    	OUT NOCOPY VARCHAR2 ) IS

	l_event_id		NUMBER := 0;
    l_oce_id		NUMBER := 0;
    l_k_line_id     NUMBER := 0;
    v_rownum        NUMBER := 0;
    v_line_id       NUMBER := 0;

	l_cp_service_id		NUMBER;
	l_customer_product_id	NUMBER;
--	l_event_name		CS_EVENTS.NAME%TYPE;
	l_customer_id		NUMBER;
        l_party_number	        OKX_PARTIES_V.PARTY_NUMBER%TYPE;
	l_customer_name	OKX_PARTIES_V.NAME%TYPE := null;
    l_sr_summary        VARCHAR2(100);
    l_forward_to_username varchar2(30);
    l_user_id           NUMBER;



    l_jtot_object_code  OKC_CONDITION_HEADERS_V.jtot_object_code%TYPE;
    l_object_id         OKC_CONDITION_HEADERS_V.object_id%TYPE;



    CURSOR contract_cur IS
     select  cpl.object1_id1 customer_id,opv.name customer_name,opv.party_number party_number
    from    okc_k_lines_v cle,
            okc_k_headers_v chr,
            okc_k_party_roles_b cpl,
            okx_parties_v opv
    where   cle.id = l_k_line_id
    and     cle.dnz_chr_id = chr.id
    and     cpl.chr_id = chr.id
    and     cpl.cle_id is null
    and     cpl.dnz_chr_id = chr.id
    and     cpl.rle_code= 'CUSTOMER'
    and     cpl.jtot_object1_code = 'OKX_PARTY'
    and     cpl.object1_id1 = opv.id1 --to_char(opv.id1) -- commented because of performance bug 3157787
    and     opv.party_type = 'ORGANIZATION';


    CURSOR c_req_summary IS
    select  'CONTRACT - '||okhv.contract_number||'; MODIFIER - '||okhv.contract_number_modifier||
                '; SERVICE - '||msi.segment1||'; LINE NO. - '||oklv.line_number SR_SUMMARY
    from    okc_k_headers_v okhv,
            okc_k_lines_v   oklv,
            okc_k_items cim,
            mtl_system_items msi
    where   okhv.id = oklv.chr_id
    and     oklv.id = l_k_line_id
    and     oklv.id = cim.cle_id
    and     cim.jtot_object1_code = 'OKX_SERVICE'
    and     cim.object1_id1 = msi.inventory_item_id --to_char(msi.inventory_item_id)
    and     cim.object1_id2 = msi.organization_id; --to_char(msi.organization_id);




BEGIN

   	IF (funcmode= 'RUN') THEN

    FND_PROFILE.Get('OKS_SERVICE_REQUEST_CREATOR', l_forward_to_username);


      wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'FORWARD_TO_USERNAME' ,
                    avalue  => l_forward_to_username);
       BEGIN
       select user_id into l_user_id
       from fnd_user
       where user_name = l_forward_to_username;
       EXCEPTION
        when others then
        null;
       END;

       WF_ENGINE.SetItemAttrNumber (
                    itemtype  => itemtype,
                    itemkey   => itemkey,
                    aname     => 'USER_ID',
                    avalue    => l_user_id
                    );



        l_k_line_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'K_LINE_ID');


                    --log_errors('k_line_id: '||l_k_line_id);


			OPEN contract_cur;
			FETCH contract_cur INTO l_customer_id, l_customer_name,l_party_number;
			CLOSE contract_cur;

             --log_errors('customer name: '||l_customer_id||'-'||l_customer_name||'-'||l_party_number);

                 -- l_customer_id changed to l_party_numberfor bug 2608720
/*
		wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'CUSTOMER',
					avalue	=> l_customer_name || ':' || l_customer_id);

*/

		wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'CUSTOMER',
					avalue	=> l_customer_name || ':' ||l_party_number);

		wf_engine.SetItemAttrNumber(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'CUSTOMER_ID',
					avalue	=> l_customer_id);


        for     req_sum_rec in c_req_summary loop
                l_sr_summary := req_sum_rec.SR_SUMMARY;
        end loop;


        wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'REQUEST_SUMMARY',
					avalue	=> 'SR created by : '||l_sr_summary);

	/*	FOR wfparam_rec IN wfparam_cur LOOP

			IF wfparam_rec.data_type = 'VARCHAR2' THEN
				wf_engine.SetItemAttrText(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  		=> wfparam_rec.name,
					avalue		=> wfparam_rec.value);

			ELSIF wfparam_rec.data_type = 'DATE'  THEN
				wf_engine.SetItemAttrDate(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  		=> wfparam_rec.name,
					avalue		=> TO_DATE(wfparam_rec.value, 'DD-MM-YYYY HH24:MI:SS'));
			ELSIF wfparam_rec.data_type = 'NUMBER'  THEN
				wf_engine.SetItemAttrNumber(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  		=> wfparam_rec.name,
					avalue		=> TO_NUMBER(wfparam_rec.value));
			END IF;
		END LOOP; */
        --log_errors('set success');
      		result := 'COMPLETE';
    	ELSIF (funcmode= 'CANCEL') THEN
      		result := 'COMPLETE';
    	END IF;
EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(OKS_CT_EVENTS_WFA.l_pkg_name, 'Get_Values',
		      itemtype, itemkey, actid, funcmode);
      RAISE;
END GET_VALUES;


PROCEDURE CREATE_SR (
		itemtype      	IN VARCHAR2,
		itemkey       	IN VARCHAR2,
		actid         	IN NUMBER,
		funcmode      	IN VARCHAR2,
		result    	OUT NOCOPY VARCHAR2
) IS
	l_return_status	VARCHAR2(1);
    	l_msg_count		NUMBER;
    	l_msg_data		VARCHAR2(2000);
	l_user_id			NUMBER;
	l_login_id		NUMBER;
 	l_status_name		CS_INCIDENT_STATUSES.NAME%TYPE;
	l_severity_name	    CS_INCIDENT_SEVERITIES.NAME%TYPE;
	l_urgency_name		CS_INCIDENT_URGENCIES.NAME%TYPE;
	l_type_name		    CS_INCIDENT_TYPES.NAME%TYPE;
	l_customer_id		NUMBER;
	--NPALEPU
        --09-AUG-2005
        --TCA Project
        --Replaced RA_CUSTOMERS.CUSTOMER_NAME%TYPE with HZ_PARTIES.PARTY_NAME%TYPE as RA_CUSTOMERS is obsoleted.
        /*l_customer_name           RA_CUSTOMERS.CUSTOMER_NAME%TYPE; */
        l_customer_name         HZ_PARTIES.PARTY_NAME%TYPE;
        --END NPALEPU
	l_request_id		NUMBER;
	l_request_number	CS_INCIDENTS_V.INCIDENT_NUMBER%TYPE;
	l_request_summary	CS_INCIDENTS_V.SUMMARY%TYPE;
    l_org_id            NUMBER;
    l_request_id_in     NUMBER;
    l_request_number_in NUMBER;

	l_call_id			NUMBER;
    l_interaction_id	NUMBER;
    l_workflow_process_id			NUMBER;
	l_itemkey			VARCHAR2(80);
	l_return_wf_status	VARCHAR2(1);
	l_event_id		NUMBER;
    l_oce_id		NUMBER;
    l_k_line_id		NUMBER;
 	l_errmsg_name		VARCHAR2(30);
    l_API_ERROR		EXCEPTION;


    l_service_request_rec   CS_SERVICEREQUEST_PUB.SERVICE_REQUEST_REC_TYPE;
    l_notes_tab             CS_SERVICEREQUEST_PUB.NOTES_TABLE;
    l_contacts_tab          CS_SERVICEREQUEST_PUB.CONTACTS_TABLE;
    l_individual_owner      NUMBER;
    l_group_owner           NUMBER;
    l_individual_type       VARCHAR2(100);
    l_resp_appl_id	    number;
    l_resp_id		    number;
    l_SR_type_id	    number;



 /*  Modified by Jvorugan for Bug:4915689
    Now it considers the relationship status between Contract party and its contacts

   CURSOR  contact_point IS
    select  chcpv.party_id party_id,
            chcpv.contact_point_id contact_point_id,
            chcpv.CONTACT_POINT_TYPE CONTACT_POINT_TYPE,
            chcpv.PRIMARY_FLAG PRIMARY_FLAG,
            chcpv.party_type party_type
    from    csc_hz_parties_v chpv,
            csc_hz_contact_points_v chcpv
    where   obj_party_type = 'ORGANIZATION'
    and     object_id = (select object1_id1 from  okc_k_party_roles_v
                    where jtot_object1_code = 'OKX_PARTY'
                    and     chr_id = (select chr_id from okc_k_lines_v where id = l_k_line_id)
                    and     rownum = 1) --l_party_id
    and     chpv.party_id = chcpv.party_id --and     chpv.subject_id = chcpv.party_id
    and     chcpv.PRIMARY_FLAG = 'Y'
    and     chcpv.party_TYPE = 'PARTY_RELATIONSHIP' --'PERSON'
    and     rownum = 1;
    */

    CURSOR    contact_point IS
     select    chcpv.party_id party_id,
            chcpv.contact_point_id contact_point_id,
            chcpv.CONTACT_POINT_TYPE CONTACT_POINT_TYPE,
            chcpv.PRIMARY_FLAG PRIMARY_FLAG,
            chcpv.party_type party_type,
            chpv.sub_status
    from    csc_hz_parties_v chpv,
            csc_hz_contact_points_v chcpv,
            hz_relationships r
    where   chpv.obj_party_type = 'ORGANIZATION'
    and     chpv.object_id = (select object1_id1 from  okc_k_party_roles_v
                    where jtot_object1_code = 'OKX_PARTY'
                    and chr_id = (select chr_id from okc_k_lines_v where
                                         id = l_k_line_id)
                    and    rownum = 1)
    and    chpv.party_id = chcpv.party_id
    and    chcpv.PRIMARY_FLAG = 'Y'
    and    chcpv.party_TYPE = 'PARTY_RELATIONSHIP' --'PERSON'
    and    chpv.subject_id = r.subject_id
    and    chpv.object_id = r.object_id
    and    r.status = 'A'
    and    chpv.sub_status = 'A'
    and    chpv.obj_status = 'A'
    and    rownum = 1;



    CURSOR status IS
    select assent.opn_code opn_code
    from   okc_assents_v assent,
           okc_k_lines_v cle ,
           okc_k_headers_v okh
    where  cle.id = l_k_line_id
    and    okh.id = cle.dnz_chr_id
    and    assent.sts_code = cle.sts_code
    and    assent.scs_code = okh.scs_code
    and    assent.opn_code = 'ENTITLE'
    and    assent.allowed_yn = 'Y';

    CURSOR appscntxt IS
    select resp.responsibility_id,
           resp.responsibility_application_id
    from   fnd_user_resp_groups resp,
           cs_sr_type_mapping srmap
    where  resp.user_id    = l_user_id
    and    resp.responsibility_id = srmap.responsibility_id
    and    srmap.incident_type_id = l_SR_type_id
    and    rownum = 1;


BEGIN
--log_errors('entered create_sr');


    	IF (funcmode= 'RUN') THEN


        l_user_id   := wf_engine.GetItemAttrNumber(
				    itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'USER_ID');

                    --log_errors('entered create_sr USER_ID');

		l_customer_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'CUSTOMER_ID');

                    --log_errors(' create_sr CUSTOMER_ID');


		l_type_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'REQUEST_TYPE');
                     --log_errors('entered create_sr 2');


		l_status_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'REQUEST_STATUS');  --log_errors('entered create_sr 3');

		l_severity_name := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'REQUEST_SEVERITY');  --log_errors('entered create_sr 4');

		l_request_summary := wf_engine.GetItemAttrText(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'REQUEST_SUMMARY');  --log_errors('entered create_sr 5');

        l_k_line_id := wf_engine.GetItemAttrNumber(
				itemtype 	=> itemtype,
    				itemkey 	=> itemkey,
    				aname  	=> 'K_LINE_ID');


--log_errors('customer name: '||l_customer_id);
--log_errors('request summ: '||l_request_summary);


        CS_ServiceRequest_PUB.initialize_rec(l_service_request_rec);

-- uptaking function Security based SR creation introduced by SR team in 11.5.9
-- bug 3025009

    if nvl(fnd_profile.value('CS_SR_USE_TYPE_RESPON_SETUP'),'NO') = 'YES' then

  	  fnd_profile.get('INC_DEFAULT_INCIDENT_TYPE',l_SR_type_id);

      for appscntxt_rec in appscntxt loop
	  l_resp_id 		:= appscntxt_rec.responsibility_id;
        l_resp_appl_id 		:= appscntxt_rec.responsibility_application_id;
      end loop;

    end if;

        l_service_request_rec.summary 		:= l_request_summary;
        l_service_request_rec.caller_type 	:= 'ORGANIZATION';
        l_service_request_rec.customer_id 	:= l_customer_id ;
-- added because it is a required parameter to SR API. bug 2960675
	  l_service_request_rec.verify_cp_flag 	:= 'N';



/* -- code bumped back to SR API version 2.0

        l_service_request_rec.creation_program_code    := 'OKS_CT_EVENTS_WFA';
        l_service_request_rec.last_update_program_code := 'OKS_CT_EVENTS_WFA';
        l_service_request_rec.sr_creation_channel      := 'AUTOMATIC';

*/

        for  ct_pt_rec in contact_point loop

        l_contacts_tab(1).party_id :=           ct_pt_rec.party_id;
        l_contacts_tab(1).contact_point_id :=   ct_pt_rec.contact_point_id;
        l_contacts_tab(1).CONTACT_POINT_TYPE := ct_pt_rec.CONTACT_POINT_TYPE;
        l_contacts_tab(1).PRIMARY_FLAG :=       ct_pt_rec.PRIMARY_FLAG;
        l_contacts_tab(1).CONTACT_TYPE :=       ct_pt_rec.party_type;

        end loop;

        for sts_rec in status loop

/*-- code bumped back to SR API version 2.0

             CS_SERVICEREQUEST_PUB.CREATE_SERVICEREQUEST(
                p_api_version			        => 3.0, --2.0, changed from 11.5.9
                p_init_msg_list		            => FND_API.G_TRUE, --FND_API.G_FALSE, --commented to clean the message stack
                p_commit		                => FND_API.G_FALSE, --FND_API.G_TRUE,
                x_return_status	                => l_return_status,
                x_msg_count			            => l_msg_count,
                x_msg_data			            => l_msg_data,
		p_resp_appl_id			=> l_resp_appl_id,
		p_resp_id			=> l_resp_id,
                p_user_id			            => l_user_id,
                p_service_request_rec           => l_service_request_rec,
                p_notes                         => l_notes_tab,
                p_contacts                      => l_contacts_tab,
                x_request_id			        => l_request_id,
                x_request_number		        => l_request_number,
                x_interaction_id                => l_interaction_id,
                x_workflow_process_id           => l_workflow_process_id,
              -- Added for assignment manager changes for 11.5.9
                x_individual_owner              => l_individual_owner,
                x_group_owner                   => l_group_owner,
                x_individual_type               => l_individual_type);
*/



             CS_SERVICEREQUEST_PUB.CREATE_SERVICEREQUEST(
                p_api_version			        => 2.0,
                p_init_msg_list		            => FND_API.G_TRUE, --FND_API.G_FALSE, --commented to clean the message stack. bug 2960675.
                p_commit		                => FND_API.G_FALSE, --FND_API.G_TRUE,
                x_return_status	                => l_return_status,
                x_msg_count			            => l_msg_count,
                x_msg_data			            => l_msg_data,
		p_resp_appl_id			=> l_resp_appl_id,
		p_resp_id			=> l_resp_id,
                p_user_id			            => l_user_id,
                p_service_request_rec           => l_service_request_rec,
                p_notes                         => l_notes_tab,
                p_contacts                      => l_contacts_tab,
                x_request_id			        => l_request_id,
                x_request_number		        => l_request_number,
                x_interaction_id                => l_interaction_id,
                x_workflow_process_id           => l_workflow_process_id);


	       	WF_ENGINE.SetItemAttrText(
    					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'REQUEST_NUMBER',
					avalue	=> l_request_number);


    		 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             WF_ENGINE.SetItemAttrText(
    					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'L_MSG_DATA',
					    avalue	=> 'API error: CS_SERVICEREQUEST_PUB.CREATE_SERVICEREQUEST '||l_msg_data);

        		WF_CORE.context(
				pkg_name	=>  OKS_CT_EVENTS_WFA.l_pkg_name,
			 	proc_name	=>  'CREATE_SR',
			 	arg1		=>  'p_itemkey =>'||itemkey );

                result := 'COMPLETE:SR_CREATE_ERROR';

             else

              WF_ENGINE.SetItemAttrText(
    					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'L_MSG_DATA',
					    avalue	=> 'success ');

                result := 'COMPLETE:SR_CREATED';

             END IF;

           end loop;

           If result is NULL Then

            result := 'COMPLETE:NOT_ENTITLE';

           end if;

      --		result := 'COMPLETE';
    	ELSIF (funcmode= 'CANCEL') THEN
      		result := 'COMPLETE';
    	END IF;

EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(OKS_CT_EVENTS_WFA.l_pkg_name, 'Create_SR',
		      itemtype, itemkey, actid, funcmode);
      RAISE;

END CREATE_SR;


-- OUT
--   Resultout    - 'COMPLETE:T' if receiver is found
--		  - 'COMPLETE:F' if receiver is not found
--
PROCEDURE VALIDATE_RECEIVER (
		itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode	in varchar2,
		result		out nocopy varchar2	) is
	l_receiver_name	VARCHAR2(30);
BEGIN
	--
  	-- RUN mode - activity
	--

  	IF funcmode = 'RUN' THEN
		l_receiver_name := wf_engine.GetItemAttrText(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'FORWARD_TO_USERNAME' );


		IF  l_receiver_name IS NULL then
			--
			result := 'COMPLETE:F';
			--
		ELSE
			-- Write your own code here to validate the receiver name here
			--
			result := 'COMPLETE:T';
			--
		END IF;
	--
  	-- CANCEL mode - activity
	--
  	ELSIF (funcmode = 'CANCEL') THEN
		--
    		result := 'COMPLETE:';
    		return;
	--
	-- TIMEOUT mode
	--
	ELSIF (funcmode = 'TIMEOUT') THEN
		result := 'COMPLETE:';
		return;
	END IF;
EXCEPTION
	WHEN OTHERS then
		WF_CORE.context(OKS_CT_EVENTS_WFA.l_pkg_name,'Validate_Receiver',itemtype,itemkey,actid,funcmode);
		raise;
END VALIDATE_RECEIVER;

PROCEDURE UPDATE_EVENT (
		itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode	in varchar2,
		result		out nocopy varchar2	) is
	l_event_id	NUMBER;
BEGIN
	--
  	-- RUN mode - activity
	--

  	IF funcmode = 'RUN' THEN
		/*l_event_id := wf_engine.GetItemAttrNumber(
					itemtype 	=> itemtype,
    					itemkey 	=> itemkey,
    					aname  	=> 'EVENT_ID' );*/

                        --log_errors('updating events ');

	/*	UPDATE CS_EVENTS
			SET LAST_EVENT_DATE = sysdate
		WHERE EVENT_ID = l_event_id;*/

		result := 'COMPLETE';
	--
  	-- CANCEL mode - activity
	--
  	ELSIF (funcmode = 'CANCEL') THEN
		--
    		result := 'COMPLETE:';
    		return;
	--
	-- TIMEOUT mode
	--
	ELSIF (funcmode = 'TIMEOUT') THEN
		result := 'COMPLETE:';
		return;
	END IF;
EXCEPTION
	WHEN OTHERS then
		WF_CORE.context(OKS_CT_EVENTS_WFA.l_pkg_name,'Update_Event',itemtype,itemkey,actid,funcmode);
		raise;
END UPDATE_EVENT;

END OKS_CT_EVENTS_WFA;

/
