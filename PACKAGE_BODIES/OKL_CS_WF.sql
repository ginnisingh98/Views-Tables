--------------------------------------------------------
--  DDL for Package Body OKL_CS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_WF" AS
/* $Header: OKLRCSWB.pls 120.16.12010000.5 2009/06/15 03:36:58 rpillay ship $ */

l_ntf_result   VARCHAR2(30);

-----get messages from the server side-----------------
PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(5000) := '';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(50) ;
      l_message_name    VARCHAR2(30) ;
      l_id              NUMBER;
      l_message_num     NUMBER;
  	  l_msg_count       NUMBER;
	  l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;
          l_message_num := NULL;

          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_msgs := l_msg_list;
END Get_Messages;



PROCEDURE raise_equipment_exchange_event (
                         p_tas_id   IN NUMBER)
AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_event_name            varchar2(240) := 'oracle.apps.okl.cs.equipmentexchange';
        l_seq                   NUMBER;
	CURSOR okl_key_csr IS
	SELECT okl_wf_item_s.nextval
	FROM  dual;


BEGIN

        SAVEPOINT raise_equipment_exchange_event;

	OPEN okl_key_csr;
	FETCH okl_key_csr INTO l_seq;
	CLOSE okl_key_csr;
        l_key := l_event_name ||l_seq ;

        wf_event.AddParameterToList('TAS_ID',p_tas_id,l_parameter_list);
	--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

   -- Raise Event
           wf_event.raise(p_event_name => l_event_name
                        ,p_event_key   => l_key
                        ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_equipment_exchange_event;
END raise_equipment_exchange_event;


PROCEDURE exchange_equipment ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	)
    IS

	l_dummy   varchar(1) ;
        l_tas_id    		NUMBER ;
	l_return_status		VARCHAR2(100);
	l_api_version		NUMBER	:= 1.0;
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
    BEGIN

    	if (funcmode = 'RUN') then
     		l_tas_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TAS_ID');

		okl_equipment_exchange_pub.exchange(
			                p_api_version           =>l_api_version,
			                p_init_msg_list         =>fnd_api.g_false,
			                p_tas_id                =>l_tas_id,
			                x_return_status         =>l_return_status,
			                x_msg_count             =>l_msg_count,
			                x_msg_data              =>l_msg_data);
		--I think if the api is not a success we should log the error in a
		--table.

		IF l_return_status <> 'S' THEN
         		resultout := 'COMPLETE:N';
		ELSE
         		resultout := 'COMPLETE:Y';
		END IF;
         	RETURN ;

	end if;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
    		resultout := 'COMPLETE:N';

		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:Y';
    		return ;
		--
	end if;
EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'exchange_equipment',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;

END exchange_equipment;

PROCEDURE check_for_request ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
	l_tas_id		NUMBER;
	l_knt			NUMBER;

	CURSOR okl_check_req_csr(c_tas_id	NUMBER)
	IS
	SELECT count(*)
	FROM   OKL_TRX_ASSETS
	WHERE	ID=c_tas_id;

BEGIN
    	if (funcmode = 'RUN') then
     		l_tas_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TAS_ID');



		OPEN okl_check_req_csr(l_tas_id);
		FETCH okl_check_req_csr into l_knt;
		CLOSE okl_check_req_csr;

		IF l_knt = 0 THEN
			resultout := 'COMPLETE:N';
		ELSE
			resultout := 'COMPLETE:Y';
		END IF;
         	RETURN ;

	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

END check_for_request;

PROCEDURE populate_notification_attribs(itemtype        in varchar2,
                                	itemkey         in varchar2,
					p_tas_id IN NUMBER)
AS
	l_restruct_role		VARCHAR2(100);
	l_contract_number	VARCHAR2(120);
	l_request_number	NUMBER;
	x_thpv_tbl 		okl_equipment_exchange_pub.thpv_tbl_type;
	l_thpv_tbl 		okl_equipment_exchange_pub.thpv_tbl_type;

	l_new_talv_tbl 		okl_equipment_exchange_pub.talv_tbl_type;
	x_new_talv_tbl 		okl_equipment_exchange_pub.talv_tbl_type;

	l_old_talv_tbl 		okl_equipment_exchange_pub.talv_tbl_type;
	x_old_talv_tbl 		okl_equipment_exchange_pub.talv_tbl_type;
	l_no_data_found		BOOLEAN;

	l_old_vendor		VARCHAR2(240);
	l_new_vendor		VARCHAR2(240);

	CURSOR okl_contract_number(c_contract_id	NUMBER)
	IS
	SELECT contract_number
	FROM 	OKC_K_HEADERS_V
	WHERE id=c_contract_id;
BEGIN

	l_thpv_tbl(1).id:= p_tas_id;
	x_thpv_tbl :=okl_equipment_exchange_pub.get_Tas_hdr_rec(l_thpv_tbl,l_no_data_found);

	l_old_talv_tbl(1).tas_id 	:= p_tas_id;
	l_old_talv_tbl(1).tal_type 	:= 'OAS';
	x_old_talv_tbl :=okl_equipment_exchange_pub.get_tal_rec(l_old_talv_tbl,l_no_data_found);
	l_new_talv_tbl(1).tas_id 	:= p_tas_id;
	l_new_talv_tbl(1).tal_type 	:= 'NAS';
	x_new_talv_tbl :=okl_equipment_exchange_pub.get_tal_rec(l_new_talv_tbl,l_no_data_found);

	OPEN okl_contract_number(x_new_talv_tbl(1).dnz_khr_id);
	FETCH	okl_contract_number INTO l_contract_number;
	CLOSE okl_contract_number;

	--This should be populated from the DB.
	--rkuttiya added for bug:2923037
	l_restruct_role	:=	fnd_profile.value('OKL_CTR_RESTRUCTURE_REP');
	IF l_restruct_role IS NULL THEN
          l_restruct_role        := 'SYSADMIN';
        END IF;
	l_request_number  := x_thpv_tbl(1).trans_number;

     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OKLCSEQUIP_RESTRUCTURE_ROLE',
			                        avalue  => l_restruct_role);
	--Header Information
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'CONTRACT_NUMBER',
			                        avalue  => l_contract_number);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'REQUEST_NUMBER',
			                        avalue  => l_request_number);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'COMMENTS',
			                        avalue  => x_thpv_tbl(1).comments);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'RETURN_DATE',
			                        avalue  => x_old_talv_tbl(1).date_due);


	--Old Asset Information
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_ASSET_NUMBER',
			                        avalue  => x_old_talv_tbl(1).asset_number);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_ASSET_DESC',
			                        avalue  => x_old_talv_tbl(1).DESCRIPTION);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_COST',
			                        avalue  => x_old_talv_tbl(1).ORIGINAL_COST);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_YEAR',
			                        avalue  => x_old_talv_tbl(1).YEAR_MANUFACTURED);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_MODEL',
			                        avalue  => x_old_talv_tbl(1).MODEL_NUMBER);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_MANUFACTURER',
			                        avalue  => x_old_talv_tbl(1).MANUFACTURER_NAME);
	IF x_old_talv_tbl(1).SUPPLIER_ID IS NOT NULL THEN
		l_old_vendor := okl_equipment_exchange_pub.get_vendor_name(x_old_talv_tbl(1).SUPPLIER_ID);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_VENDOR',
			                        avalue  => l_old_vendor);
	END IF;

	--New Asset Information
     	/*	wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'OLD_ASSET_NUMBER',
			                        avalue  => x_new_talv_tbl(1).asset_number);
	*/
            --Bug# 5362977
            -- Set attribute NEW_ASSET_DESC with new asset description
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_ASSET_DESC',
			                        avalue  => x_new_talv_tbl(1).DESCRIPTION);

     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_COST',
			                        avalue  => x_new_talv_tbl(1).ORIGINAL_COST);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_YEAR',
			                        avalue  => x_new_talv_tbl(1).YEAR_MANUFACTURED);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_MODEL',
			                        avalue  => x_new_talv_tbl(1).MODEL_NUMBER);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_MANUFACTURER',
			                        avalue  => x_new_talv_tbl(1).MANUFACTURER_NAME);
	IF x_new_talv_tbl(1).SUPPLIER_ID IS NOT NULL THEN
		l_new_vendor := okl_equipment_exchange_pub.get_vendor_name(x_new_talv_tbl(1).SUPPLIER_ID);
     		wf_engine.SetItemAttrText ( 	itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'NEW_VENDOR',
			                        avalue  => l_new_vendor);
	END IF;
END populate_notification_attribs;

PROCEDURE check_exchange_type ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
	l_tas_id		NUMBER;
	l_exchange_type		VARCHAR2(60);
BEGIN
    	if (funcmode = 'RUN') then
     		l_tas_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TAS_ID');
		l_exchange_type := okl_equipment_exchange_pub.get_exchange_type(l_tas_id);

		populate_notification_attribs(itemtype,itemkey,l_tas_id);

		if l_exchange_type IN ('LLT','LLP') THEN
         		resultout := 'COMPLETE:LL';
		ELSE
         		resultout := 'COMPLETE:'|| l_exchange_type;
		END IF;
         	RETURN ;

	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

END check_exchange_type;



PROCEDURE check_temp_exchange ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
	--Returns YES for Temporary Exchange and NO in other cases.
IS
	l_tas_id		NUMBER;
	l_exchange_type		VARCHAR2(60);
BEGIN
    	if (funcmode = 'RUN') then
     		l_tas_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TAS_ID');
		l_exchange_type := okl_equipment_exchange_pub.get_exchange_type(l_tas_id);
		IF l_exchange_type = 'LLT' THEN
	         	resultout := 'COMPLETE:Y';
		ELSE
	         	resultout := 'COMPLETE:N';
		END IF;
         	RETURN ;

	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

END check_temp_exchange;

---Procedures for Transfer And Assumption Request Workflow

PROCEDURE Raise_TransferAsu_Event(p_trx_id      IN NUMBER)
AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_event_name            varchar2(240) := 'oracle.apps.okl.cs.transferandassumption';
        l_seq                   NUMBER;
	CURSOR okl_key_csr IS
	SELECT okl_wf_item_s.nextval
	FROM  dual;


BEGIN

        SAVEPOINT raise_transferasu_event;

	OPEN okl_key_csr;
	FETCH okl_key_csr INTO l_seq;
	CLOSE okl_key_csr;
        l_key := l_event_name ||l_seq ;
        wf_event.AddParameterToList('TRX_ID',p_trx_id,l_parameter_list);
	--added by akrangan
       wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

   -- Raise Event
           wf_event.raise(p_event_name => l_event_name
                        ,p_event_key   => l_key
                        ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_transferasu_event;
END raise_transferAsu_event;


Procedure Check_Approval( itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out nocopy varchar2)
AS
	l_trx_id		NUMBER;
	l_ctr			NUMBER;

	CURSOR c_check_tfr_req(p_trx_id  IN NUMBER)
	IS
	SELECT count(*)
	FROM   OKL_TRX_CONTRACTS
	WHERE	ID=p_trx_id;

BEGIN
    	if (funcmode = 'RUN') then
     		l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TRX_ID');


		OPEN c_check_tfr_req(l_trx_id);
		FETCH c_check_tfr_req into l_ctr;
		CLOSE c_check_tfr_req;

		IF l_ctr = 0 THEN
			resultout := 'COMPLETE:REJECTED';
		ELSIF l_ctr > 0 THEN
		        resultout := 'COMPLETE:APPROVED';
		END IF;

         	RETURN ;

         /*
         	IF l_trx_id = 123 THEN
         	         resultout := 'COMPLETE:APPROVED';
		ELSE
		         resultout := 'COMPLETE:REJECTED';
		END IF;

         	RETURN;     */

	end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

END check_approval;

PROCEDURE Populate_TandA_attributes(itemtype          in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out nocopy varchar2)
AS

  CURSOR c_req_record(p_id IN NUMBER) IS
  SELECT *
  FROM OKL_TRX_CONTRACTS
  WHERE ID = p_id;

  CURSOR c_ctr_no(p_ctr_id IN NUMBER)
  IS
  SELECT contract_number
  FROM 	OKC_K_HEADERS_V
  WHERE id=p_ctr_id;

  --Cursor for obtaining the party name on the old contract
   CURSOR c_party(p_contract_id IN NUMBER) IS
   SELECT object1_id1,
          object1_id2
   FROM okc_k_party_roles_b
   WHERE dnz_chr_id = p_contract_id
   AND   rle_code = 'LESSEE';

   CURSOR c_lessee(p_id1 IN VARCHAR2,
                   p_id2 IN VARCHAR2) IS
   SELECT name
   FROM okx_parties_v
   WHERE ID1 = p_id1
   AND   ID2 = p_id2;

  l_cust_role                 VARCHAR2(100);
  l_credit_role               VARCHAR2(100);
  l_ctr_admin_role            VARCHAR2(100);
  l_vendor_role               VARCHAR2(100);
  l_collections_role          VARCHAR2(100);
  l_contact_email             VARCHAR2(2000);
  l_trx_id                    NUMBER;
  l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
  l_req_no                    NUMBER;
  l_type                      VARCHAR2(30);
  l_party_name                VARCHAR2(360);
  l_ctr_no                    VARCHAR2(120);
  lx_new_lessee_tbl           OKL_CS_TRANSFER_ASSUMPTION_PVT.new_lessee_tbl_type;
  lx_insurance_tbl            OKL_CS_TRANSFER_ASSUMPTION_PVT.insurance_tbl_type;
  l_message                   VARCHAR2(30000);
  l_error                     VARCHAR2(2000);
  l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version               CONSTANT NUMBER := 1;
  l_msg_count		      NUMBER;
  l_msg_data		      VARCHAR2(2000);
  l_requestor                 VARCHAR2(200);
  l_requestor_id              NUMBER;
  l_description               VARCHAR2(200);
  l_req_rec                   c_req_record%ROWTYPE;
  l_recipient_type            VARCHAR2(30);
  l_id1                       VARCHAR2(40);
  l_id2                       VARCHAR2(200);
 -- rkuttiya added for bug: 4056337
  l_transfer_date             DATE;

--rkuttiya added for populating From_Address for XMLP Project
  CURSOR c_agent_csr (c_agent_id NUMBER) IS
  SELECT nvl(ppf.email_address , fu.email_address) email
  FROM   fnd_user fu,
         per_people_f ppf
  WHERE  fu.employee_id = ppf.person_id (+)
  AND    fu.user_id = c_agent_id;

  l_from_email      VARCHAR2(100);


BEGIN
  IF (funcmode = 'RUN') THEN

   l_cust_role        := fnd_profile.value('OKL_CS_AGENT_CUST_RESPONSE');
    IF l_cust_role IS NULL THEN
       l_cust_role        := 'SYSADMIN';
    END IF;

   l_credit_role      := fnd_profile.value('OKL_CS_CREDIT_APPROVER');
   IF l_credit_role IS NULL THEN
     l_credit_role        := 'SYSADMIN';
   END IF;

   l_ctr_admin_role   := fnd_profile.value('OKL_CS_CONTRACT_ADMIN');
   IF l_ctr_admin_role IS NULL THEN
     l_ctr_admin_role        := 'SYSADMIN';
   END IF;

   l_vendor_role      := fnd_profile.value('OKL_CS_AGENT_VENDOR_RESPONSE');
   IF l_vendor_role IS NULL THEN
     l_vendor_role        := 'SYSADMIN';
   END IF;

   l_collections_role := fnd_profile.value('OKL_CS_COLLECTIONS_APPROVER');
   IF l_collections_role IS NULL THEN
     l_collections_role        := 'SYSADMIN';
   END IF;


-- Get the value of the request id
   l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					 itemkey  => itemkey,
					 aname    => 'TRX_ID');

    OPEN c_req_record(l_trx_id);
    FETCH c_req_record INTO l_req_rec;
    CLOSE c_req_record;

    l_req_no := l_req_rec.trx_number;
--rkuttiya added for bug: 4056337
    l_transfer_date := l_req_rec.date_transaction_occurred;

    OPEN c_party(l_req_rec.khr_id);
    FETCH c_party INTO l_id1,l_id2;
    CLOSE c_party;

    OPEN c_lessee(l_id1,l_id2);
    FETCH c_lessee INTO l_party_name;
    CLOSE c_lessee;

    OPEN c_ctr_no(l_req_rec.khr_id);
    FETCH c_ctr_no INTO l_ctr_no;
    CLOSE c_ctr_no;
    l_requestor_id := l_req_rec.created_by;

    OPEN c_agent_csr(l_req_rec.last_updated_by);
    FETCH c_agent_csr into l_from_email;
    CLOSE c_agent_csr;

    -- get the requestor
    OKL_AM_WF.GET_NOTIFICATION_AGENT(
           itemtype        => itemtype,
           itemkey         => itemkey,
           actid           => actid,
           funcmode        => funcmode,
           p_user_id       => l_requestor_id,
           x_name          => l_requestor,
           x_description   => l_description);

   --Set the Customer Recipient Type
     --l_recipient_type := 'PC';
     --rkuttiya changed recipient type to LESSEE for XMLP
       l_recipient_type := 'LESSEE';

  --rkuttiya added for Bug:4257336
     wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'CONTRACT_ID',
                               avalue   =>  l_req_rec.khr_id);
  --end changes for Bug:4257336

     wf_engine.SetItemAttrText(itemtype => itemtype,
				           itemkey  => itemkey,
				           aname    => 'CREATED_BY',
         	                           avalue   => l_requestor_id);
     wf_engine.SetItemAttrText(itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'REQUESTER',
         	               avalue   => l_requestor);
     wf_engine.SetItemAttrText(itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'NOTIFY_AGENT',
         	               avalue   => l_requestor);
     wf_engine.SetItemAttrText(itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'RECIPIENT_TYPE',
         	               avalue   => l_recipient_type);
     wf_engine.SetItemAttrText(itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PROCESS_CODE',
         	               avalue   => 'CSTSFRASU');
     wf_engine.SetItemAttrText(itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'SERVICE_FEE_CODE',
         	               avalue   => 'CSTSFRFEE');
     wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'FROM_ADDRESS',
                               avalue   => l_from_email);

     wf_engine.SetItemAttrText (itemtype=> itemtype,
			     itemkey => itemkey,
			     aname   => 'CUST_ROLE',
			     avalue  => l_cust_role) ;

     wf_engine.SetItemAttrText (itemtype=> itemtype,
			                    itemkey => itemkey,
			                    aname   => 'ROLE_CREDIT',
			                    avalue  => l_credit_role) ;
     wf_engine.SetItemAttrText (itemtype=> itemtype,
			                    itemkey => itemkey,
			                    aname   => 'ROLE_ADMIN',
			                    avalue  => l_ctr_admin_role) ;
     wf_engine.SetItemAttrText (itemtype=> itemtype,
			                    itemkey => itemkey,
			                    aname   => 'ROLE_VND',
			                    avalue  => l_vendor_role) ;
     wf_engine.SetItemAttrText (itemtype=> itemtype,
			                    itemkey => itemkey,
			                    aname   => 'ROLE_COLLECTION',
			                    avalue  => l_collections_role) ;



      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'CONTRACT_NUMBER',
			                     avalue  => l_ctr_no) ;
      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'TRANSACTION_ID',
			                     avalue  => l_trx_id) ;

--rkuttiya added for bug: 4056337
      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'TRANSFER_DATE',
			                     avalue  => l_transfer_date) ;


      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'OLD_LESSEE',
			                     avalue  => l_party_name) ;

      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'REQUEST_NUMBER',
			                     avalue  => l_req_no) ;


  IF l_req_rec.complete_transfer_yn = 'N' THEN
      l_type := 'Partial';
      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'TRANSFER_TYPE',
			                     avalue  => 'Partial') ;
  ELSIF l_req_rec.complete_transfer_yn = 'Y' THEN
      l_type := 'Complete';
      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                     itemkey => itemkey,
			                     aname   => 'TRANSFER_TYPE',
			                     avalue  => 'Complete') ;
  END IF;


    OKL_CS_TRANSFER_ASSUMPTION_PVT.populate_new_lessee_details(p_api_version    => l_api_version ,
                                                               p_init_msg_list  => 'F',
                                                               p_request_id     => l_trx_id,
                                                               x_new_lessee_tbl => lx_new_lessee_tbl ,
                                                               x_return_status  => l_return_status,
                                                               x_msg_count      => l_msg_count,
                                                               x_msg_data       => l_msg_data);

     IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'NEW_CONTRACT_NUMBER',
			                        avalue  => lx_new_lessee_tbl(1).new_contract_number) ;

         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'NEW_LESSEE',
			                        avalue  => lx_new_lessee_tbl(1).new_lessee);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'RECIPIENT_DESCRIPTION',
			                        avalue  => lx_new_lessee_tbl(1).contact_name);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'EMAIL_ADDRESS',
			                        avalue  => lx_new_lessee_tbl(1).contact_email);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'RECIPIENT_ID',
			                        avalue  => lx_new_lessee_tbl(1).contact_id);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'BILL_TO',
			                        avalue  => lx_new_lessee_tbl(1).bill_to_address);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'CUST_ACCT_NUMBER',
			                        avalue  => lx_new_lessee_tbl(1).cust_acct_number);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'BANK_ACCOUNT',
			                        avalue  => lx_new_lessee_tbl(1).bank_account);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'INVOICE_FORMAT',
			                        avalue  => lx_new_lessee_tbl(1).invoice_format);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'PAYMENT_METHOD',
			                        avalue  => lx_new_lessee_tbl(1).payment_method);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'MLA_NO',
			                        avalue  => lx_new_lessee_tbl(1).master_lease);
         wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'CREDIT_LINE_NUMBER',
			                        avalue  => lx_new_lessee_tbl(1).credit_line_no);

         IF lx_new_lessee_tbl(1).lease_policy_yn = 'N' THEN
             OKL_CS_TRANSFER_ASSUMPTION_PVT.Populate_ThirdParty_Insurance
                                          (p_api_version     => l_api_version ,
                                           p_init_msg_list   => 'F',
                                           p_taa_id          => lx_new_lessee_tbl(1).taa_id,
                                           x_insurance_tbl   => lx_insurance_tbl ,
                                           x_return_status   => l_return_status,
                                           x_msg_count       => l_msg_count,
                                           x_msg_data        => l_msg_data);
              IF l_return_status <> 'S' THEN
		         FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	         Get_Messages(l_msg_count,l_error);

                  wf_engine.SetItemAttrText(itemtype  => itemtype,
                                            itemkey   => itemkey,
                                            aname     => 'ERROR_MESSAGE',
                                            avalue    => l_error);

                   resultout := 'COMPLETE:N';
               ELSE
                 wf_engine.SetItemAttrText (itemtype=> itemtype,
			                        itemkey => itemkey,
			                        aname   => 'INSURER',
			                        avalue  => lx_insurance_tbl(1).insurer) ;

                  wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                 itemkey => itemkey,
			                                 aname   => 'INSURANCE_AGENT',
			                                 avalue  => lx_insurance_tbl(1).insurance_agent);
                  wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                 itemkey => itemkey,
			                                 aname   => 'POLICY_NUMBER',
			                                 avalue  => lx_insurance_tbl(1).policy_number);
                  wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                 itemkey => itemkey,
			                                 aname   => 'COVERED_AMOUNT',
			                                 avalue  => lx_insurance_tbl(1).covered_amount);
                   wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                  itemkey => itemkey,
			                                  aname   => 'DEDUCTIBLE_AMOUNT',
			                                  avalue  => lx_insurance_tbl(1).deductible_amount);
                   wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                  itemkey => itemkey,
			                                  aname   => 'EFFECTIVE_FROM',
			                                  avalue  => lx_insurance_tbl(1).effective_from);
                   wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                  itemkey => itemkey,
			                                  aname   => 'EFFECTIVE_TO',
			                                  avalue  => lx_insurance_tbl(1).effective_to);
                   wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                  itemkey => itemkey,
			                                  aname   => 'PROOF_PROVIDED',
			                                  avalue  => lx_insurance_tbl(1).proof_provided);
                   wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                  itemkey => itemkey,
			                                  aname   => 'PROOF_REQUIRED',
			                                  avalue  => lx_insurance_tbl(1).proof_required);
                  IF lx_insurance_tbl(1).lessor_insured_yn = 'Y' THEN
                      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                     itemkey => itemkey,
			                                     aname   => 'LESSOR_INSURED_YN',
			                                     avalue  => 'Yes');
                  ELSIF lx_insurance_tbl(1).lessor_insured_yn = 'Y' THEN
                      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                     itemkey => itemkey,
			                                     aname   => 'LESSOR_INSURED_YN',
			                                     avalue  => 'No');
                  END IF;

                  IF lx_insurance_tbl(1).lessor_payee_yn = 'Y' THEN
                      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                     itemkey => itemkey,
			                                     aname   => 'LESSOR_PAYEE_YN',
			                                     avalue  => 'Yes');
                  ELSIF lx_insurance_tbl(1).lessor_payee_yn = 'Y' THEN
                      wf_engine.SetItemAttrText (itemtype=> itemtype,
			                                     itemkey => itemkey,
			                                     aname   => 'LESSOR_PAYEE_YN',
			                                     avalue  => 'No');
                  END IF;

               END IF;
         END IF;
      END IF;

       l_message  := '<p>Please review and approve the following Transfer and Assumption Request: <br> ' ||
                     'Request Number      :' || l_req_no ||'<br>'||
                     'Old Contract Number :' || l_ctr_no ||'<br>'||
                     'Old Lessee          :' || l_party_name ||'<br>'||
                     'New Contract Number :' || lx_new_lessee_tbl(1).new_contract_number ||'<br>'||
                     'New Lessee          :' || lx_new_lessee_tbl(1).new_lessee||'<br>'||
                     'Type of Transfer    :' || l_type ||'</p>'||
                     '<p> Please review further details of the request in the Lease Center.</p>';


        wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'TRX_TYPE_ID',
         	                    avalue  => 'OKLCSTRQ');

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'MESSAGE_DESCRIPTION',
         	                    avalue  => l_message);

  resultout := 'COMPLETE:';
  RETURN ;
  END IF;
         --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;
EXCEPTION
     WHEN OTHERS THEN
        IF c_req_record%ISOPEN THEN
           CLOSE c_req_record;
        END IF;
        IF c_ctr_no%ISOPEN THEN
           CLOSE c_ctr_no;
        END IF;
        IF c_party%ISOPEN THEN
           CLOSE c_party;
        END IF;
        IF c_lessee%ISOPEN THEN
           CLOSE c_lessee;
        END IF;

        wf_core.context('OKL_CS_WF' , 'populate_TandA_attributes', itemtype, itemkey, actid, funcmode);
        RAISE;
END;

Procedure Send_Cust_Fulfill(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2)
AS
  CURSOR c_document(p_ptm_code IN VARCHAR2) IS
  SELECT jtf_amv_item_id,email_subject_line
  FROM okl_cs_process_tmplts_uv
  WHERE NVL(org_id, -99) = NVL(mo_global.get_current_org_id(), -99)
  AND start_date <= TRUNC(sysdate)
  AND NVL(end_date, sysdate) >= TRUNC(sysdate)
  AND ptm_code = p_ptm_code;

  l_trx_id                  NUMBER;
  l_ptm_code                VARCHAR2(30);
  l_agent_id                NUMBER(15);
  l_server_id               NUMBER;
  l_content_id              NUMBER(15);
  l_from                    VARCHAR2(100);
  l_subject                 VARCHAR2(100);
  l_email                   VARCHAR2(2000);
  l_bind_var                JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_bind_val                JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_bind_var_type           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_commit                  CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
  lx_return_status           VARCHAR2(3);
  l_error                   VARCHAR2(2000);
  l_api_version		        NUMBER	:= 1.0;
  lx_msg_count	            NUMBER;
  lx_msg_data		        VARCHAR2(2000);
  lx_request_id             NUMBER;

BEGIN
 IF (funcmode = 'RUN') THEN
    -- Get the value of the request id
   l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					                      itemkey  => itemkey,
					                      aname    => 'TRX_ID');
   l_ptm_code := wf_engine.GetItemAttrText( itemtype => itemtype,
					                        itemkey  => itemkey,
					                        aname    => 'PROCESS_CODE');

   l_email    := wf_engine.GetItemAttrText( itemtype => itemtype,
					                        itemkey  => itemkey,
					                        aname    => 'CONTACT_EMAIL');

    l_bind_var(1)           := 'p_request_id';
    l_bind_val(1)           := l_trx_id;
    l_bind_var_type(1)      := 'NUMBER';
    l_agent_id              := FND_PROFILE.VALUE('USER_ID');
    l_server_id             := FND_PROFILE.VALUE('OKL_FM_SERVER');

    OPEN c_document(l_ptm_code);
    FETCH c_document INTO l_content_id,l_subject;
    CLOSE c_document;

    l_from := 'OKLDeveloper@oracle.com';

    OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version      => l_api_version,
                              p_init_msg_list    => 'T',
                              p_agent_id         => l_agent_id,
                              p_server_id        => l_server_id,
                              p_content_id       => l_content_id,
                              p_from             => l_from,
                              p_subject          => l_subject,
                              p_email            => l_email,
                              p_bind_var         => l_bind_var,
                              p_bind_val         => l_bind_val,
                              p_bind_var_type    => l_bind_var_type,
                              p_commit           => l_commit,
                              x_request_id       => lx_request_id,
                              x_return_status    => lx_return_status,
                              x_msg_count        => lx_msg_count,
                              x_msg_data         => lx_msg_data);

     IF lx_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   lx_msg_count,
               		         p_data           =>   lx_msg_data);
       	Get_Messages(lx_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';

     ELSE
       resultout := 'COMPLETE:Y';
     END IF;
   END IF;

        --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;
   EXCEPTION
     WHEN OTHERS THEN
        IF c_document%ISOPEN THEN
           CLOSE c_document;
        END IF;
        wf_core.context('OKL_CS_WF' , 'Send_Cust_Fulfill', itemtype, itemkey, actid, funcmode);
        RAISE;
END Send_Cust_Fulfill;

Procedure Send_Vendor_Fulfill(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2)
AS
  CURSOR c_document(p_ptm_code IN VARCHAR2) IS
  SELECT jtf_amv_item_id,email_subject_line
  FROM okl_cs_process_tmplts_uv
  WHERE NVL(org_id, -99) = NVL(mo_global.get_current_org_id(), -99)
  AND start_date <= TRUNC(sysdate)
  AND NVL(end_date, sysdate) >= TRUNC(sysdate)
  AND ptm_code = p_ptm_code;

  l_trx_id                  NUMBER;
  l_ptm_code                VARCHAR2(30);
  l_agent_id                NUMBER(15);
  l_server_id               NUMBER;
  l_content_id              NUMBER(15);
  l_from                    VARCHAR2(100);
  l_subject                 VARCHAR2(100);
  l_email                   VARCHAR2(2000);
  l_bind_var                JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_bind_val                JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_bind_var_type           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
  l_commit                  CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
  lx_return_status           VARCHAR2(3);
  l_error                   VARCHAR2(2000);
  l_api_version		        NUMBER	:= 1.0;
  lx_msg_count	            NUMBER;
  lx_msg_data		        VARCHAR2(2000);
  lx_request_id             NUMBER;

BEGIN
 IF (funcmode = 'RUN') THEN
    -- Get the value of the request id
   l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					                      itemkey  => itemkey,
					                      aname    => 'TRX_ID');
   l_ptm_code := wf_engine.GetItemAttrText( itemtype => itemtype,
					                        itemkey  => itemkey,
					                        aname    => 'PROCESS_CODE');

   l_email    := wf_engine.GetItemAttrText( itemtype => itemtype,
					                        itemkey  => itemkey,
					                        aname    => 'VENDOR_EMAIL');

    l_bind_var(1)           := 'p_request_id';
    l_bind_val(1)           := l_trx_id;
    l_bind_var_type(1)      := 'NUMBER';
    l_agent_id              := FND_PROFILE.VALUE('USER_ID');
    l_server_id             := FND_PROFILE.VALUE('OKL_FM_SERVER');

    OPEN c_document(l_ptm_code);
    FETCH c_document INTO l_content_id,l_subject;
    CLOSE c_document;

    l_from := 'OKLDeveloper@oracle.com';

    OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version      => l_api_version,
                              p_init_msg_list    => 'T',
                              p_agent_id         => l_agent_id,
                              p_server_id        => l_server_id,
                              p_content_id       => l_content_id,
                              p_from             => l_from,
                              p_subject          => l_subject,
                              p_email            => l_email,
                              p_bind_var         => l_bind_var,
                              p_bind_val         => l_bind_val,
                              p_bind_var_type    => l_bind_var_type,
                              p_commit           => l_commit,
                              x_request_id       => lx_request_id,
                              x_return_status    => lx_return_status,
                              x_msg_count        => lx_msg_count,
                              x_msg_data         => lx_msg_data);

     IF lx_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   lx_msg_count,
               		         p_data           =>   lx_msg_data);
       	Get_Messages(lx_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';

     ELSE
       resultout := 'COMPLETE:Y';
     END IF;
   END IF;

        --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;
   EXCEPTION
     WHEN OTHERS THEN
        IF c_document%ISOPEN THEN
           CLOSE c_document;
        END IF;
        wf_core.context('OKL_CS_WF' , 'Send_Vendor_Fulfill', itemtype, itemkey, actid, funcmode);
        RAISE;
END Send_Vendor_Fulfill;

Procedure Approve_Request(itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       out nocopy varchar2)
AS

  l_trx_id  NUMBER;
  l_contract_id  NUMBER;
  l_status  VARCHAR2(30);
  l_return_status		VARCHAR2(100);
  l_api_version		NUMBER	:= 1.0;
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_error           VARCHAR2(2000);

  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;

  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;

BEGIN
   IF (funcmode = 'RUN') THEN
     l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TRX_ID');
     l_status := 'APPROVED';

     l_tcnv_rec.id := l_trx_id;
     l_tcnv_rec.tsu_code := l_status;

     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version         => l_api_version,
                                              p_init_msg_list       => fnd_api.g_false,
                                              x_return_status       => l_return_status,
                                              x_msg_count           => l_msg_count,
                                              x_msg_data            => l_msg_data,
                                              p_tcnv_rec            => l_tcnv_rec,
                                              p_tclv_tbl            => l_tclv_tbl,
                                              x_tcnv_rec            => lx_tcnv_rec,
                                              x_tclv_tbl            => lx_tclv_tbl);

     IF l_return_status <> 'S' THEN
       FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       Get_Messages(l_msg_count,l_error);

       wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);
      	resultout := 'COMPLETE:N';
     ELSE
      	resultout := 'COMPLETE:Y';
     END IF;
     RETURN ;
   END IF;
        --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;



END Approve_Request;

PROCEDURE Update_Request_Internal( itemtype          in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2)
AS

  l_trx_id           NUMBER;
  l_contract_id      NUMBER;
  l_status           VARCHAR2(30);
  l_rjn_code         VARCHAR2(30);
  l_approved_yn      VARCHAR2(1);

  l_return_status	 VARCHAR2(100);
  l_api_version		 NUMBER	:= 1.0;
  l_msg_count		 NUMBER;
  l_msg_data		 VARCHAR2(2000);

  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;

  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;
  l_error          VARCHAR2(2000);

BEGIN
   IF (funcmode = 'RUN') THEN
     l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	itemkey	=> itemkey,
							aname  	=> 'TRX_ID');

     l_approved_yn := wf_engine.GetItemAttrText( itemtype   => itemtype,
						      	                 itemkey	=> itemkey,
							                     aname  	=> 'APPROVED_YN');
     IF l_approved_yn = 'Y' THEN
       l_status := 'SUBMITTED';
     ELSE
        l_status := 'REJECTED';
        l_rjn_code := 'INTAPPR';
     END IF;

     l_tcnv_rec.id := l_trx_id;
     l_tcnv_rec.tsu_code := l_status;
     l_tcnv_rec.rjn_code := l_rjn_code;

     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version         => l_api_version,
                                              p_init_msg_list       => fnd_api.g_false,
                                              x_return_status       => l_return_status,
                                              x_msg_count           => l_msg_count,
                                              x_msg_data            => l_msg_data,
                                              p_tcnv_rec            => l_tcnv_rec,
                                              p_tclv_tbl            => l_tclv_tbl,
                                              x_tcnv_rec            => lx_tcnv_rec,
                                              x_tclv_tbl            => lx_tclv_tbl);

           IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';

       ELSE
        	IF l_approved_yn = 'Y' THEN
              resultout := 'COMPLETE:APPROVED';
            ELSIF l_approved_yn = 'N' THEN
              resultout := 'COMPLETE:REJECTED';
            END IF;
        END IF;
      RETURN ;
   END IF;
        --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;



END Update_Request_Internal;

PROCEDURE Customer_Post( itemtype          in  varchar2,
                         itemkey           in  varchar2,
                         actid             in  number,
                         funcmode          in  varchar2,
                         resultout         out nocopy varchar2)

AS


  l_nid          NUMBER;
  l_ntf_comments VARCHAR2(4000);

  l_trx_id           NUMBER;
  l_contract_id      NUMBER;
  l_sts_code           VARCHAR2(30);
  l_rjn_code         VARCHAR2(30);

  l_return_status	 VARCHAR2(100);
  l_api_version		 NUMBER	:= 1.0;
  l_msg_count		 NUMBER;
  l_msg_data		 VARCHAR2(2000);

  l_tcnv_rec       okl_trx_contracts_pvt.tcnv_rec_type;
  l_tclv_tbl       okl_trx_contracts_pvt.tclv_tbl_type;
  lx_tcnv_rec      okl_trx_contracts_pvt.tcnv_rec_type;
  lx_tclv_tbl      okl_trx_contracts_pvt.tclv_tbl_type;
  l_error          VARCHAR2(2000);

BEGIN
  IF (funcmode = 'RESPOND') THEN
  --get request id
    l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
     				      	    itemkey  => itemkey,
					    aname    => 'TRX_ID');


     --get notification id from wf_engine context
     l_nid := WF_ENGINE.CONTEXT_NID;
     l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

     IF l_ntf_result = 'NO' THEN
       l_sts_code := 'REJECTED';
       l_rjn_code := 'CUST';
      -- l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
     ELSIF l_ntf_result = 'YES' THEN
        l_sts_code     := 'CUSTAPPR';
       -- l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
      END IF;


     l_tcnv_rec.id          := l_trx_id;
     --l_tcnv_rec.description := l_ntf_comments;
     l_tcnv_rec.tsu_code    := l_sts_code;
     l_tcnv_rec.rjn_code    := l_rjn_code;


     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version       => l_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);


     IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
        IF l_ntf_result = 'YES' THEN
          resultout := 'COMPLETE:YES';
          return;
        ELSIF l_ntf_result = 'NO' THEN
          resultout := 'COMPLETE:NO';
         return;
        END IF;
      END IF;
    END IF;
    --
    --Transfer Mode
    --
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      return;
    END IF;

    --Run Mode
    IF funcmode = 'RUN' THEN
      resultout := 'COMPLETE:'||l_ntf_result;
      return;
    END IF;

         --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Collections_Post',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Customer_post;

PROCEDURE Vendor_Post( itemtype          in  varchar2,
                         itemkey           in  varchar2,
                         actid             in  number,
                         funcmode          in  varchar2,
                         resultout         out nocopy varchar2)

AS

  l_nid             NUMBER;
 --rkuttiya commented foll.for bug # 5149488
 -- l_ntf_result      VARCHAR2(30);
 --
  l_ntf_comments    VARCHAR2(4000);
  l_trx_id          NUMBER;
  l_contract_id     NUMBER;
  l_sts_code        VARCHAR2(30);
  l_rjn_code        VARCHAR2(30);
  l_approved_yn     VARCHAR2(1);

  l_return_status	 VARCHAR2(100);
  l_api_version		 NUMBER	:= 1.0;
  l_msg_count		 NUMBER;
  l_msg_data		 VARCHAR2(2000);

  l_tcnv_rec       okl_trx_contracts_pvt.tcnv_rec_type;
  l_tclv_tbl       okl_trx_contracts_pvt.tclv_tbl_type;
  lx_tcnv_rec      okl_trx_contracts_pvt.tcnv_rec_type;
  lx_tclv_tbl      okl_trx_contracts_pvt.tclv_tbl_type;
  l_error          VARCHAR2(2000);

BEGIN
  IF (funcmode = 'RESPOND') THEN
  --get request id
    l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
     				      	    itemkey  => itemkey,
					    aname    => 'TRX_ID');


     --get notification id from wf_engine context
     l_nid := WF_ENGINE.CONTEXT_NID;
     l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

   --rkuttiya changed for bug#5149488
     IF l_ntf_result = 'VND_REJECTED' THEN
       l_sts_code := 'REJECTED';
       l_rjn_code := 'VND';
       l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
     ELSIF l_ntf_result = 'VND_APPROVED' THEN
        l_sts_code     := 'VENDAPPR';
        l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
      END IF;


     l_tcnv_rec.id          := l_trx_id;
     l_tcnv_rec.description := l_ntf_comments;
     l_tcnv_rec.tsu_code    := l_sts_code;
     l_tcnv_rec.rjn_code    := l_rjn_code;


     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version       => l_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);


     IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
   --rkuttiya changed for bug#5149488
        IF l_ntf_result = 'VND_APPROVED' THEN
          resultout := 'COMPLETE:VND_APPROVED';
          return;
        ELSIF l_ntf_result = 'VND_REJECTED' THEN
          resultout := 'COMPLETE:VND_REJECTED';
         return;
        END IF;
      END IF;
    END IF;
    --
    --Transfer Mode
    --
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      return;
    END IF;

 --rkuttiya added for bug # 5149488
    --Run Mode
    IF funcmode = 'RUN' THEN
      resultout := 'COMPLETE:'|| l_ntf_result;
      return;
    END IF;

         --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Vendor_Post',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Vendor_post;


Procedure Check_Vendor_Pgm(itemtype          in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) IS

CURSOR c_vnd_pgm(p_ctr_id IN NUMBER) IS
  SELECT khr_id
  FROM okl_k_headers_v
  where id = p_ctr_id  ;

CURSOR c_contact_role(p_contract_id IN NUMBER) IS
SELECT co.object1_id1,
       co.jtot_object1_code
FROM   okc_contacts_v co,
       okc_k_party_roles_b pr
WHERE co.dnz_chr_id = p_contract_id
AND   co.cpl_id = pr.id
AND   co.dnz_chr_id = pr.dnz_chr_id
AND   pr.rle_code = 'OKL_VENDOR';

CURSOR c_email(p_object_id IN NUMBER) IS
SELECT name,
       email_address
FROM okx_salesreps_v
WHERE id1 = p_object_id;


l_ctr_id             NUMBER;
l_khr_id             NUMBER;
l_email              VARCHAR2(30);
l_object_id          NUMBER;
l_object_code        VARCHAR2(30);
l_contact_name       VARCHAR2(240);

--rkuttiya added for XMLP
l_api_version		NUMBER	:= 1.0;
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_error                 VARCHAR2(2000);
l_trx_id                 NUMBER;
l_init_msg_list         VARCHAR2(1) := 'T';
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
ERR                     EXCEPTION;
l_batch_id              NUMBER;
l_xmp_rec               OKL_XMLP_PARAMS_PVT.xmp_rec_type;
lx_xmp_rec              OKL_XMLP_PARAMS_PVT.xmp_rec_type;
BEGIN
  IF funcmode = 'RUN' THEN
    l_ctr_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					 itemkey  => itemkey,
					 aname    => 'CONTRACT_ID');
    OPEN c_vnd_pgm(l_ctr_id);
    FETCH c_vnd_pgm INTO l_khr_id;
    CLOSE c_vnd_pgm;

    IF l_khr_id IS NOT NULL THEN
       OPEN c_contact_role(l_khr_id);
       FETCH c_contact_role INTO l_object_id,l_object_code;
       CLOSE c_contact_role;
       IF l_object_code = 'OKX_SALEPERS' THEN
         OPEN c_email(l_object_id);
         FETCH c_email INTO l_contact_name,l_email;
         CLOSE c_email;
       END IF;

     l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
     				      	    itemkey  => itemkey,
					    aname    => 'TRX_ID');

--set the value for the vendor email attribute,recipient type - VC for Vendor Contact
     wf_engine.SetItemAttrText (itemtype=> itemtype,
			        itemkey => itemkey,
			        aname   => 'VENDOR_EMAIL',
			        avalue  => l_email) ;

--set the EMAIL_ADDRESS attribute to that of Vendor for XML Publisher Report
     wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'EMAIL_ADDRESS',
                               avalue   => l_email);

--rkuttiya changed recipient type to VENDOR for XMLPProject
     wf_engine.SetItemAttrText (itemtype=> itemtype,
			        itemkey => itemkey,
			        aname   => 'RECIPIENT_TYPE',
			        avalue  => 'VENDOR') ;

     wf_engine.SetItemAttrText (itemtype=> itemtype,
			        itemkey => itemkey,
			        aname   => 'RECIPIENT_DESCRIPTION',
			        avalue  => l_contact_name);

     wf_engine.SetItemAttrText (itemtype=> itemtype,
			        itemkey => itemkey,
			        aname   => 'RECIPIENT_ID',
			        avalue  => l_object_id);

--rkuttiya added for XMLP Project
--code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_REQUEST_ID';
          l_xmp_rec.param_value := l_trx_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );

           IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
              l_batch_id := lx_xmp_rec.batch_id;
              wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                          itemkey => itemkey,
                                          aname   => 'BATCH_ID',
                                          avalue  => l_batch_id );
             resultout := 'COMPLETE:YES';

           ELSE
             FND_MSG_PUB.Count_And_Get
                              (  p_count          =>   l_msg_count,
                                 p_data           =>   l_msg_data);
             Get_Messages(l_msg_count,l_error);

             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);
             resultout := 'COMPLETE:N';
           END IF;

    ELSE
       resultout := 'COMPLETE:NO';
    END IF;
  END IF;

       --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Check_Vendor_Pgm',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Check_Vendor_Pgm;

Procedure Check_Cust_Delinquency(itemtype          in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out nocopy varchar2)
AS
  CURSOR c_cust_del(p_party_id IN NUMBER) IS
    SELECT COUNT(*) FROM
    IEX_DELINQUENCIES_ALL
    WHERE PARTY_CUST_ID = p_party_id
    AND STATUS NOT IN ('CURRENT','PREDELINQUENT');
  l_party_id     NUMBER;
  l_ctr          NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN
    l_party_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					    itemkey  => itemkey,
					    aname    => 'PARTY_ID');
    OPEN c_cust_del(l_party_id);
    FETCH c_cust_del INTO l_ctr;
    CLOSE c_cust_del;

    IF l_ctr > 0 THEN
       resultout := 'COMPLETE:YES';
    ELSE
       resultout := 'COMPLETE:NO';
    END IF;
    return;
  END IF;

       --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Check_Cust_Delinquency',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Check_Cust_Delinquency;

Procedure Apply_Service_Fees(itemtype          in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2)
AS
  CURSOR c_svf_info(p_svf_code IN VARCHAR2) IS
  SELECT fnd.meaning svf_name,
         fnd.description svf_desc,
         svf.amount svf_amount
   FROM   fnd_lookups fnd,
          okl_service_fees_b svf
   WHERE  svf.srv_code= 'CSTSFRFEE'
   AND  svf.srv_code = fnd.lookup_code
   AND  lookup_type = 'OKL_SERVICE_FEES';

    l_trx_id          NUMBER;
    l_khr_id          NUMBER;
    l_sty_name        VARCHAR2(150);
    l_svf_code        VARCHAR2(30);
    l_svf_amount      NUMBER;
    l_svf_desc        VARCHAR2(1995);
     l_svf_name       VARCHAR2(100);
    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(2000);

    lx_tai_id         NUMBER;

    l_data                VARCHAR2(2000);
    l_msg_index_out       NUMBER;
    l_error               VARCHAR2(2000);


  BEGIN
    IF (funcmode = 'RUN') THEN
    -- Get the value of the request id
      l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
					                         itemkey  => itemkey,
					                         aname    => 'TRX_ID');
      l_svf_code := wf_engine.GetItemAttrText( itemtype => itemtype,
					                           itemkey  => itemkey,
					                           aname    => 'SERVICE_FEE_CODE');

      l_sty_name     := 'SERVICE_FEE_TRANS_REQUEST';


      l_khr_id       := wf_engine.GetItemAttrText( itemtype => itemtype,
					                         itemkey  => itemkey,
					                         aname    => 'CONTRACT_ID');
      OPEN c_svf_info(l_svf_code);
      FETCH c_svf_info into l_svf_name,l_svf_desc,l_svf_amount;
      CLOSE c_svf_info;


       okl_cs_transactions_pub.create_svf_invoice(p_khr_id        => l_khr_id,
                                                 p_sty_name      => l_sty_name,
                                                 p_svf_code      => l_svf_code,
                                                 p_svf_amount    => l_svf_amount,
                                                 p_svf_desc      => l_svf_desc,
                                                 x_tai_id        => lx_tai_id,
                                                 x_return_status => lx_return_status,
                                                 x_msg_count     => lx_msg_count,
                                                 x_msg_data      => lx_msg_data);


       IF lx_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   lx_msg_count,
               		         p_data           =>   lx_msg_data);
       	Get_Messages(lx_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);
         resultout := 'COMPLETE:N';

     ELSE
       resultout := 'COMPLETE:Y';
     END IF;
   END IF;
 EXCEPTION
     WHEN OTHERS THEN
        IF c_svf_info%ISOPEN THEN
           CLOSE c_svf_info;
        END IF;
        wf_core.context('OKL_CS_WF' , 'Apply_Service_Fees', itemtype, itemkey, actid, funcmode);
        RAISE;
 END Apply_Service_Fees;


Procedure Credit_post(itemtype          in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out nocopy varchar2)
AS

  l_nid          NUMBER;
  l_ntf_comments VARCHAR2(4000);
  l_rjn_code     VARCHAR2(30);

  l_trx_id       NUMBER;
  l_contract_id  NUMBER;

  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;

  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;

  l_api_version		NUMBER	:= 1.0;
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_error           VARCHAR2(2000);
  l_sts_code        VARCHAR2(30);

  l_init_msg_list  VARCHAR2(1) := 'T';
  l_return_status  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  ERR EXCEPTION;
  l_batch_id     NUMBER;
  l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
BEGIN
  IF (funcmode = 'RESPOND') THEN
  --get request id
     l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
     				      	    itemkey  => itemkey,
					    aname    => 'TRX_ID');


     --get notification id from wf_engine context
     l_nid := WF_ENGINE.CONTEXT_NID;
     l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

     IF l_ntf_result = 'CREDIT_REJECTED' THEN
       l_sts_code := 'REJECTED';
       l_rjn_code := 'CRDPT';
       l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');

     ELSIF l_ntf_result = 'CREDIT_APPROVED' THEN
        l_sts_code     := 'CREDAPPR';
        l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
      END IF;


     l_tcnv_rec.id          := l_trx_id;
     l_tcnv_rec.description := l_ntf_comments;
     l_tcnv_rec.tsu_code    := l_sts_code;
     l_tcnv_rec.rjn_code    := l_rjn_code;

     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version       => l_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);


     IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
        IF l_ntf_result = 'CREDIT_REJECTED' THEN
          resultout := 'COMPLETE:CREDIT_REJECTED';
          return;
        ELSIF l_ntf_result = 'CREDIT_APPROVED' THEN
          resultout := 'COMPLETE:CREDIT_APPROVED';

        --18-Dec-06 rkuttiya added for XMLP Project
        --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_REQUEST_ID';
          l_xmp_rec.param_value := l_trx_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => l_msg_count
                          ,x_msg_data        => l_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );

           IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
              l_batch_id := lx_xmp_rec.batch_id;
              wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                          itemkey => itemkey,
                                          aname   => 'BATCH_ID',
                                          avalue  => l_batch_id );

           ELSE
             FND_MSG_PUB.Count_And_Get
                              (  p_count          =>   l_msg_count,
                                 p_data           =>   l_msg_data);
             Get_Messages(l_msg_count,l_error);

             wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);
             resultout := 'COMPLETE:N';
           END IF;
         return;
        END IF;
      END IF;
    END IF;
    --
    --Transfer Mode
    --
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      return;
    END IF;

    --Run Mode
    IF funcmode = 'RUN' THEN
      resultout := 'COMPLETE:'|| l_ntf_result;
      return;
    END IF;

         --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Credit_Post',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Credit_post;

Procedure Collections_post(itemtype          in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       out nocopy varchar2)
AS

  l_nid          NUMBER;
  l_ntf_comments VARCHAR2(4000);
  l_rjn_code     VARCHAR2(30);

  l_trx_id       NUMBER;
  l_contract_id  NUMBER;

  SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_trx_contracts_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_trx_contracts_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_trx_contracts_pvt.tclv_tbl_type;

  l_tcnv_rec       tcnv_rec_type;
  l_tclv_tbl       tclv_tbl_type;
  lx_tcnv_rec      tcnv_rec_type;
  lx_tclv_tbl      tclv_tbl_type;

  l_return_status	VARCHAR2(100);
  l_api_version		NUMBER	:= 1.0;
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_error           VARCHAR2(2000);
  l_sts_code        VARCHAR2(30);
BEGIN
  IF (funcmode = 'RESPOND') THEN
  --get request id
     l_trx_id := wf_engine.GetItemAttrText( itemtype => itemtype,
     				      	    itemkey  => itemkey,
					    aname    => 'TRX_ID');


     --get notification id from wf_engine context
     l_nid := WF_ENGINE.CONTEXT_NID;
     l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

     IF l_ntf_result = 'COLLECTIONS_REJECTED' THEN
       l_sts_code := 'REJECTED';
       l_rjn_code := 'CODPT';
       l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
      ELSE
        l_sts_code     := 'COLLAPPR';
        l_ntf_comments := wf_notification.GetAttrText(l_nid,'COMMENTS');
      END IF;


     l_tcnv_rec.id          := l_trx_id;
     l_tcnv_rec.description := l_ntf_comments;
     l_tcnv_rec.tsu_code    := l_sts_code;
     l_tcnv_rec.rjn_code    := l_rjn_code;

     OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version       => l_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_tcnv_rec            => l_tcnv_rec,
                                                p_tclv_tbl            => l_tclv_tbl,
                                                x_tcnv_rec            => lx_tcnv_rec,
                                                x_tclv_tbl            => lx_tclv_tbl);


     IF l_return_status <> 'S' THEN
		FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
        IF l_ntf_result = 'COLLECTIONS_REJECTED' THEN
          resultout := 'COMPLETE:COLLECTIONS_REJECTED';
          return;
        ELSIF l_ntf_result = 'COLLECTIONS_APPROVED' THEN
          resultout := 'COMPLETE:COLLECTIONS_APPROVED';
         return;
        END IF;
      END IF;
    END IF;
    --
    --Transfer Mode
    --
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      return;
    END IF;

    --Run Mode
    IF funcmode = 'RUN' THEN
      resultout := 'COMPLETE:'|| l_ntf_result;
      return;
    END IF;

         --
        -- CANCEL mode
        --
   IF (funcmode = 'CANCEL') THEN
                --
     resultout := 'COMPLETE:';
     return;
      --
   END IF;
        --
        -- TIMEOUT mode
        --
   IF (funcmode = 'TIMEOUT') THEN
     --
     resultout := 'COMPLETE:';
     return;
                --
   END IF;


EXCEPTION
	when others then
	  wf_core.context('OKL_CS_WF',
		'Collections_Post',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  RAISE;
END Collections_post;

PROCEDURE days_cust_balance_overdue ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
        l_contract_id          NUMBER;
        l_inv_days_tbl         inv_days_tbl_type;
        l_return_status        VARCHAR2(10);
	l_days_overdue		NUMBER;
BEGIN
        if (funcmode = 'RUN') then
                l_contract_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CONTRACT_ID');

                days_cust_balance_overdue(p_contract_id => l_contract_id
                                         ,x_inv_days_tbl => l_inv_days_tbl
                                         ,x_return_status => l_return_status);

                IF l_return_status = 'S' THEN
                        l_days_overdue := l_inv_days_tbl(l_inv_days_tbl.FIRST).days;
                        resultout := 'COMPLETE:' || l_days_overdue;
                ELSE
                        resultout := 'COMPLETE:NO';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'days_cust_balance_overdue',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;


END days_cust_balance_overdue;

PROCEDURE get_contract_balance ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
        l_contract_id          NUMBER;
        l_outstanding_balance  NUMBER;
        l_return_status        VARCHAR2(10);
BEGIN
        if (funcmode = 'RUN') then
                l_contract_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CONTRACT_ID');

                get_contract_balance(p_contract_id => l_contract_id
                                         ,x_outstanding_balance => l_outstanding_balance
                                         ,x_return_status => l_return_status);

                IF l_return_status = 'S' THEN
                        resultout := 'COMPLETE:' || l_outstanding_balance;
                ELSE
                        resultout := 'COMPLETE:NO';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'get_contract_balance',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;


END get_contract_balance;

PROCEDURE get_customer_balance ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
        l_cust_account_id          NUMBER;
        l_outstanding_balance  NUMBER;
        l_return_status        VARCHAR2(10);
BEGIN
        if (funcmode = 'RUN') then
                l_cust_account_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CUST_ACCOUNT_ID');

                get_customer_balance(p_cust_account_id => l_cust_account_id
                                         ,x_outstanding_balance => l_outstanding_balance
                                         ,x_return_status => l_return_status);

                IF l_return_status = 'S' THEN
                        resultout := 'COMPLETE:' || l_outstanding_balance;
                ELSE
                        resultout := 'COMPLETE:NO';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'get_customer_balance',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;


END get_customer_balance;

PROCEDURE get_product ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
        l_contract_id          NUMBER;
        l_product_rec           product_rec_type;
        l_return_status        VARCHAR2(10);
        l_product_name          VARCHAR2(150);
BEGIN
        if (funcmode = 'RUN') then
                l_contract_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CONTRACT_ID');

                get_product(p_contract_id => l_contract_id
                                         ,x_product_rec => l_product_rec
                                         ,x_return_status => l_return_status);

                IF l_return_status = 'S' THEN
                        l_product_name := l_product_rec.product_name;
                        resultout := 'COMPLETE:' || l_product_name;
                ELSE
                        resultout := 'COMPLETE:NO';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'get_product',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;


END get_product;

PROCEDURE get_bill_to_address ( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
IS
        l_contract_id          NUMBER;
        l_address_rec          address_rec_type;
        l_return_status        VARCHAR2(10);
        l_address_desc          VARCHAR2(80);
BEGIN
        if (funcmode = 'RUN') then
                l_contract_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CONTRACT_ID');

                get_bill_to_address(p_contract_id => l_contract_id
                                         ,x_address_rec => l_address_rec
                                         ,x_return_status => l_return_status);

                IF l_return_status = 'S' THEN
                        l_address_desc := l_address_rec.description;
                        resultout := 'COMPLETE:' || l_address_desc;
                ELSE
                        resultout := 'COMPLETE:NO';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'get_bill_to_address',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;


END get_bill_to_address;



---------------------------------------------------------------
-- The following APIS are utility APIs for getting information
-- for a contract.
---------------------------------------------------------------

procedure days_cust_balance_overdue
(p_contract_id          IN      NUMBER
,x_inv_days_tbl         OUT NOCOPY     inv_days_tbl_type
,x_return_status        OUT NOCOPY     VARCHAR2)
AS
------------------------------------------------------------------
-- The output parameter is of the form
--  Invoice Number          Days      Amount      Khrid
--    ABC                    8         3000.00    7667718289128936832
--    DEF                    5         8000.00    7667718289128936832
--    XYZ                    2         1000.00    7667718289128936832
-------------------------------------------------------------------

----------------------------------------------------------
-- This cursor gets the id from the header table for all the
-- invoices which have payment due and the due date is less
-- than the current date(this info is stored in ar_payment_schedules_all).
-- So traverse from header to line to Streams table and then to the
-- payments table.
----------------------------------------------------------
CURSOR c_overdue_hdr(c_khr_id NUMBER)
IS
select consolidated_invoice_number,id
from okl_cnsld_ar_hdrs_b
where id in
        (select distinct(cnr_id)
        from okl_cnsld_ar_lines_b
        where id in
                (select
                distinct b.lln_id
                from ar_payment_schedules_all a,
                okl_cnsld_ar_strms_b b
                where b.receivables_invoice_id=a.customer_trx_id
                and b.khr_id = c_khr_id
                and a.amount_due_remaining > 0
                and a.due_date < sysdate));

----------------------------------------------------------
-- This cursor get the days the payment is overdue, Total Amount Due,
-- for a particular contract and in descending order of the date.
----------------------------------------------------------
CURSOR c_overdue_days (c_ar_hdr_id NUMBER)
IS
select  trunc(sysdate) - trunc(d.due_date) days,
        sum(amount_due_remaining) total_amount,
        c.khr_id
from
okl_cnsld_ar_hdrs_b a,
okl_cnsld_ar_lines_b b,
okl_cnsld_ar_strms_b c,
ar_payment_schedules_all d
where
a.id=b.cnr_id and
b.id=c.lln_id and
c.receivables_invoice_id = d.customer_trx_id and
a.id=c_ar_hdr_id
group by  (trunc(sysdate) - trunc(d.due_date)),c.khr_id
order by days desc;

i       NUMBER  :=      0;

BEGIN


FOR hdr_rec in c_overdue_hdr(p_contract_id)
LOOP

        FOR day_rec in c_overdue_days(hdr_rec.id)
        LOOP
           i := i+1;

           x_inv_days_tbl(i).consolidated_invoice_number := hdr_rec.consolidated_invoice_number;
           x_inv_days_tbl(i).days                       := day_rec.days;
           x_inv_days_tbl(i).amount_due_remaining       := day_rec.total_amount;
           x_inv_days_tbl(i).khr_id                     := day_rec.khr_id;

        END LOOP;
END LOOP;
x_return_status := Okl_Api.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END days_cust_balance_overdue;

------------------------------------------------------------------
-- The following API gets the outstanding Balance for a
-- particular contract.
------------------------------------------------------------------

PROCEDURE get_contract_balance (
     p_contract_id              IN  NUMBER,
     x_outstanding_balance      OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2)
  IS
    -- Get amount outstanding
    CURSOR outstanding_rcvble_csr IS
      SELECT NVL(SUM(amount_due_remaining),0)
      FROM   okl_bpd_leasing_payment_trx_v
      WHERE  contract_id = p_contract_id;

  BEGIN
    OPEN outstanding_rcvble_csr;
    FETCH outstanding_rcvble_csr into  x_outstanding_balance;
    CLOSE outstanding_rcvble_csr;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END get_contract_balance;

------------------------------------------------------------------
-- The following API gets the outstanding Balance for a
-- particular customer.
-- This Calls the get_contract_balance API in a loop for all
-- the contracts found for a customer and totals the amount for
-- each customer.
------------------------------------------------------------------
PROCEDURE get_customer_balance (
     p_cust_account_id              IN  NUMBER,
     x_outstanding_balance      OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2)
  IS
    -- Get List of contracts associated with this customer.

        CURSOR contracts_csr(c_cust_account_id NUMBER) IS
        SELECT chrb.id khr_id , CHRB.contract_number,
                hca.cust_account_id
        FROM    OKC_K_HEADERS_B CHRB,
                HZ_CUST_ACCOUNTS HCA
        WHERE CHRB.CUST_ACCT_ID = HCA.CUST_ACCOUNT_ID
        AND hca.cust_account_id = c_cust_account_id;


        -- smoduga:Removed for rules migration
        /*FROM    OKC_K_HEADERS_B CHRB,
                OKC_RULES_B ORGB1,
                OKC_RULE_GROUPS_B ORGB2,
                HZ_CUST_ACCOUNTS HCA
        WHERE orgb2.id = orgb1.rgp_id
        AND to_char(HCA.CUST_ACCOUNT_ID) = orgb1.object1_id1
        AND chrb.id = orgb1.dnz_chr_id
        AND chrb.id = orgb2.chr_id
        AND orgb1.rule_information_category = 'CAN'
        AND orgb2.rgd_code = 'LACAN'
        AND hca.cust_account_id = c_cust_account_id;*/

        l_outstanding_balance   NUMBER := 0;
        l_return_status         VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
        l_total_balance         NUMBER :=0;
  BEGIN

    FOR khr_rec in contracts_csr(p_cust_account_id)
    LOOP
        get_contract_balance(khr_rec.khr_id,l_outstanding_balance,l_return_status);

        IF l_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
                l_total_balance := l_total_balance + l_outstanding_balance;
        END IF;
    END LOOP;
    x_outstanding_balance := l_total_balance;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END get_customer_balance;

------------------------------------------------------------------
-- The following API gets the product name for a particular
-- Contract
------------------------------------------------------------------
PROCEDURE get_product (
     p_contract_id              IN  NUMBER,
     x_product_rec              OUT NOCOPY product_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2)
IS
        CURSOR products_csr(c_contract_id NUMBER)
        IS
        SELECT b.id,b.name,b.description
        FROM okl_k_headers a,okl_products b
        WHERE a.pdt_id=b.id
        AND a.pdt_id is not null
        AND a.id=c_contract_id;
BEGIN

    OPEN products_csr(p_contract_id);
    FETCH products_csr INTO x_product_rec.product_id,
                            x_product_rec.product_name,
                            x_product_rec.product_description;
    CLOSE products_csr;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END get_product;

------------------------------------------------------------------
-- The following API gets the Bill to Address for a particular
-- Contract.
-- Note : the Description field formats the address and returns the
-- address
------------------------------------------------------------------

PROCEDURE get_bill_to_address (
     p_contract_id              IN  NUMBER,
     x_address_rec              OUT NOCOPY address_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2)
IS
        CURSOR address_csr(c_contract_id NUMBER)
        IS

        SELECT c.address1,
               c.address2,
               c.address3,
               c.address4,
               c.city,
               c.postal_code,
               c.state,
               c.province,
               c.county,
               c.country,
               c.description
        FROM okc_k_headers_b chr,
        okx_cust_site_uses_v c
        WHERE c.id1 = chr.bill_to_site_use_id
        and chr.id  = c_contract_id ;

      -- smoduga : Removed rule related table for rules migration
      /*
        FROM
        okc_rule_groups_v a
        ,okc_rules_v b
        ,okx_cust_site_uses_v c
        WHERE
        a.rgd_code='LABILL'
        AND a.id=b.rgp_id
        AND b.RULE_INFORMATION_CATEGORY = 'BTO'
        AND b.object1_id1= c.id1
        AND a.chr_id=c_contract_id;*/

BEGIN

    OPEN address_csr(p_contract_id);
    FETCH address_csr INTO x_address_rec.address1,
                            x_address_rec.address2,
                            x_address_rec.address3,
                            x_address_rec.address4,
                            x_address_rec.city,
                            x_address_rec.postal_code,
                            x_address_rec.state,
                            x_address_rec.province,
                            x_address_rec.county,
                            x_address_rec.country,
                            x_address_rec.description;
    CLOSE address_csr;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END get_bill_to_address;

--Lease Renewal Work flow APIs

PROCEDURE raise_lease_renewal_event(p_request_id   IN NUMBER)
AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_event_name            varchar2(240) := 'oracle.apps.okl.cs.contractleaserenewal';
        l_seq                   NUMBER;
        CURSOR okl_key_csr IS
        SELECT okl_wf_item_s.nextval
        FROM  dual;


BEGIN

        SAVEPOINT raise_lease_renewal_event;

        OPEN okl_key_csr;
        FETCH okl_key_csr INTO l_seq;
        CLOSE okl_key_csr;
        l_key := l_event_name ||l_seq ;

        wf_event.AddParameterToList('REQUEST_ID',p_request_id,l_parameter_list);
	--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

   -- Raise Event
           wf_event.raise(p_event_name => l_event_name
                        ,p_event_key   => l_key
                        ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_lease_renewal_event;
END raise_lease_renewal_event;


PROCEDURE populate_lease_renew_attrib(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
	l_lease_renewal_role  VARCHAR2(50) ;
	l_request_id	NUMBER;
	l_old_contract_id NUMBER;
	l_yield           NUMBER;
	l_start_date      DATE;
	l_end_date        DATE;
	l_term            NUMBER;
	l_rent            NUMBER;
	l_residula_percentage NUMBER;
	l_new_contract_id   NUMBER;
	l_parent_contract_num VARCHAR2(100);

	CURSOR c_req_record(p_id IN NUMBER) IS
	  SELECT *
	  FROM OKL_TRX_REQUESTS
          WHERE ID = p_id;

       l_req_rec  c_req_record%ROWTYPE;

        CURSOR c_ctr_no(p_ctr_id IN NUMBER) IS
 	SELECT contract_number
  	FROM 	OKC_K_HEADERS_V
  	WHERE id=p_ctr_id;
BEGIN

        if (funcmode = 'RUN') then
                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                OPEN c_req_record(l_request_id);
  			FETCH c_req_record INTO l_req_rec;
  		CLOSE c_req_record;

  		  l_old_contract_id := l_req_rec.parent_khr_id;
		  l_yield := l_req_rec.yield;
		  l_start_date := l_req_rec.start_date;
		  l_end_date := l_req_rec.end_date;
		  l_term := l_req_rec.term_duration;
		  l_rent := l_req_rec.amount;
		  l_residula_percentage := l_req_rec.residual;
		  l_new_contract_id := l_req_rec.dnz_khr_id;


		  OPEN c_ctr_no(l_old_contract_id);
		  	FETCH c_ctr_no INTO l_parent_contract_num;
  		  CLOSE c_ctr_no;

  	--rkuttiya added for bug:2923037
  		 l_lease_renewal_role	:=	fnd_profile.value('OKL_CTR_RENEWAL_REP');
	          IF l_lease_renewal_role IS NULL THEN
                    l_lease_renewal_role        := 'SYSADMIN';
                  END IF;
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'ROLE_TO_RENEW_LEASE',
                                                avalue  => l_lease_renewal_role);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'OLD_CHRID',
                                                avalue  => l_old_contract_id);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'YIELD',
                                                avalue  => l_yield);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'START_DATE',
                                                avalue  => l_start_date);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'END_DATE',
                                                avalue  => l_end_date);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'TERM',
                                                avalue  => l_term);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RENT',
                                                avalue  => l_rent);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RESIDUAL_PTY',
                                                avalue  => l_residula_percentage);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CHR_ID',
                                                avalue  => l_new_contract_id);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'OLD_CONTRACT_NUMBER',
                                                avalue  => l_parent_contract_num);
                resultout := 'COMPLETE:';
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'populate_lease_renew_attrib',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END populate_lease_renew_attrib;


PROCEDURE approve_lease_renewal ( itemtype      in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
BEGIN
--Dummy API which alawys approves the request.

        if (funcmode = 'RUN') then
		--
                resultout := 'COMPLETE:APPROVED';
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:REJECTED';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:REJECTED';
                return;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'approve_lease_renewal',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END approve_lease_renewal;


PROCEDURE post_notify_lease_renewal(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS

    l_request_id	NUMBER;
    l_nid               NUMBER;
BEGIN

    l_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'REQUEST_ID');

    IF (funcmode = 'RESPOND') THEN
      --get notification id from wf_engine context
      l_nid := WF_ENGINE.CONTEXT_NID;
      l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

      resultout := 'COMPLETE:'|| l_ntf_result;

    --Run Mode
    ELSIF funcmode = 'RUN' THEN
       resultout := 'COMPLETE:'|| l_ntf_result;

    -- CANCEL mode
    ELSIF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

    -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context('OKL_CS_WF',
                      'post_notify_lease_renewal',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
	  RAISE;
  END post_notify_lease_renewal;



PROCEDURE post_reject_lease_renewal(itemtype    in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       out nocopy varchar2)
  AS

      l_request_id	NUMBER;
      l_nid               NUMBER;
  BEGIN

      l_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'REQUEST_ID');

      IF (funcmode = 'RESPOND') THEN
        --get notification id from wf_engine context
        l_nid := WF_ENGINE.CONTEXT_NID;
        l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

        resultout := 'COMPLETE:'|| l_ntf_result;

      --Run Mode
      ELSIF funcmode = 'RUN' THEN
         resultout := 'COMPLETE:'|| l_ntf_result;

      -- CANCEL mode
      ELSIF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';

      -- TIMEOUT mode
      ELSIF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        wf_core.context('OKL_CS_WF',
                        'post_reject_lease_renewal',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
    END post_reject_lease_renewal;



--Principal Paydown Work flow APIs

PROCEDURE raise_principal_paydown_event(p_request_id   IN NUMBER)
AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_event_name            varchar2(240) := 'oracle.apps.okl.cs.principalpaydown';
        l_seq                   NUMBER;
        CURSOR okl_key_csr IS
        SELECT okl_wf_item_s.nextval
        FROM  dual;


BEGIN

        SAVEPOINT raise_principal_paydown_event;

        OPEN okl_key_csr;
        FETCH okl_key_csr INTO l_seq;
        CLOSE okl_key_csr;
        l_key := l_event_name ||l_seq ;

        wf_event.AddParameterToList('REQUEST_ID',p_request_id,l_parameter_list);
	--added by akrangan
        wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

   -- Raise Event
           wf_event.raise(p_event_name => l_event_name
                        ,p_event_key   => l_key
                        ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_principal_paydown_event;
END raise_principal_paydown_event;


PROCEDURE populate_ppd_attrib(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
	l_principal_paydown_role  VARCHAR2(50) ;
	l_request_id	NUMBER;
	l_yield           NUMBER;
	l_start_date      DATE;
	l_end_date        DATE;
	l_term            NUMBER;
	l_rent            NUMBER;
	l_residula_percentage NUMBER;
	l_contract_id   NUMBER;
	l_contract_num VARCHAR2(100);
	l_return_status		VARCHAR2(100);
	l_api_version		NUMBER	:= 1.0;
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_cur_prin_balance NUMBER;
        l_new_prin_balance NUMBER;
        l_principal_balance NUMBER;
        l_acc_int NUMBER;


	CURSOR c_req_record(p_id IN NUMBER) IS
	  SELECT *
	  FROM OKL_TRX_REQUESTS
          WHERE ID = p_id;

       l_req_rec  c_req_record%ROWTYPE;

        CURSOR c_ctr_no(p_ctr_id IN NUMBER) IS
 	SELECT contract_number
  	FROM 	OKC_K_HEADERS_V
  	WHERE id=p_ctr_id;
BEGIN

        if (funcmode = 'RUN') then
                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                OPEN c_req_record(l_request_id);
  		FETCH c_req_record INTO l_req_rec;
  		CLOSE c_req_record;


		  l_contract_id := l_req_rec.dnz_khr_id;


		  OPEN c_ctr_no(l_contract_id);
		  FETCH c_ctr_no INTO l_contract_num;
  		  CLOSE c_ctr_no;

  	--rkuttiya added for bug:2923037
  		  l_principal_paydown_role	:=	fnd_profile.value('OKL_CTR_RESTRUCTURE_REP');
	          IF l_principal_paydown_role IS NULL THEN
                    l_principal_paydown_role        := 'SYSADMIN';
                  END IF;
/*
      OKL_STREAM_GENERATOR_PVT.get_sched_principal_bal(
                                         p_api_version  => l_api_version,
                                         p_init_msg_list => 'T',
                                         p_khr_id        => l_old_contract_id,
                                         p_kle_id        => NULL,
                                         p_date          => NVL(l_req_rec.payment_date,sysdate),
                                         x_principal_balance => l_principal_balance,
                                         x_accumulated_int => l_acc_int,
                                         x_return_status => l_return_status,
                                         x_msg_count     => l_msg_count,
                                         x_msg_data      => l_msg_data);
	l_cur_prin_balance := l_principal_balance + l_acc_int;

      l_new_prin_balance := (nvl(l_cur_prin_balance,0) - nvl(l_req_rec.payment_amount,0));
*/

                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'ROLE_TO_EXECUTE_PPD',
                                                avalue  => l_principal_paydown_role);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'KHR_ID',
                                                avalue  => l_contract_id);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'PAYDOWN_AMOUNT',
                                                avalue  => l_req_rec.payment_amount);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'REQUEST_NUMBER',
                                                avalue  => l_req_rec.request_number);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CONTRACT_NUMBER',
                                                avalue  => l_contract_num);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'NEW_PAYMENT_AMOUNT',
                                                avalue  => l_req_rec.amount);

		--Next Payment Date
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'NEXT_PAYMENT_DATE',
                                                avalue  => l_req_rec.start_date);
		--Paydown Date
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'PAYDOWN_DATE',
                                                avalue  => l_req_rec.payment_date);

               wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CURRENT_PRIN_BALANCE',
                                                avalue  => l_cur_prin_balance);

                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'NEW_PRIN_BALANCE',
                                                avalue  => l_new_prin_balance);

                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CURRENCY_CODE',
                                                avalue  => l_req_rec.currency_code);

                resultout := 'COMPLETE:';
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'populate_ppd_attrib',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END populate_ppd_attrib;

PROCEDURE post_notify_ppd(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS

    l_request_id	NUMBER;
    l_nid               NUMBER;
BEGIN

    l_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'REQUEST_ID');

    IF (funcmode = 'RESPOND') THEN
      --get notification id from wf_engine context
      l_nid := WF_ENGINE.CONTEXT_NID;
      l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

      resultout := 'COMPLETE:'|| l_ntf_result;

    --Run Mode
    ELSIF funcmode = 'RUN' THEN
       resultout := 'COMPLETE:'|| l_ntf_result;

    -- CANCEL mode
    ELSIF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

    -- TIMEOUT mode
    ELSIF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.context('OKL_CS_WF',
                      'post_notify_principal_paydown',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);
	  RAISE;
  END post_notify_ppd;

--Added the following APIs as part of 11.5.10+
PROCEDURE invoice_bill_apply(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
    IS

        l_return_status         VARCHAR2(100) := 'S';
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);

        l_khr_id             NUMBER;
        l_request_id             NUMBER;
    BEGIN

        if (funcmode = 'RUN') then

        l_khr_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'KHR_ID');

        l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');

        --call the API here.
        okl_cs_principal_paydown_pvt.invoice_bill_apply
					  (p_api_version   => l_api_version,
                                           p_init_msg_list => fnd_api.g_false,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data,
                                           p_khr_id        => l_khr_id,
                                           p_req_id    => l_request_id);

                IF l_return_status <> 'S' THEN
    		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';
                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when G_EXCEPTION then
          wf_core.context('OKL_CS_WF',
                'invoice_bill_apply',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

        when others then
          wf_core.context('OKL_CS_WF',
                'invoice_bill_apply',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END invoice_bill_apply;


PROCEDURE update_ppd_processed_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
        l_request_id            NUMBER ;
        l_return_status         VARCHAR2(100) := 'S';
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
        l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
        x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

    CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;


    BEGIN

        if (funcmode = 'RUN') then

                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                l_trqv_rec.id := l_request_id;
                l_trqv_rec.request_status_code := 'PROCESSED';

	       OPEN c_obj_vers_csr(l_request_id);
	       FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	       CLOSE c_obj_vers_csr;

                  -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       => fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);



                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';
                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when G_EXCEPTION then
          wf_core.context('OKL_CS_WF',
                'update_ppd_processed_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

        when others then
          wf_core.context('OKL_CS_WF',
                'update_ppd_processed_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END update_ppd_processed_status;


PROCEDURE raise_credit_memo_event(p_request_id   IN NUMBER)
AS
        l_parameter_list        wf_parameter_list_t;
        l_key                   varchar2(240);
        l_event_name            varchar2(240) := 'oracle.apps.okl.cs.issuecreditmemo';
        l_seq                   NUMBER;
        CURSOR okl_key_csr IS
        SELECT okl_wf_item_s.nextval
        FROM  dual;


BEGIN

        SAVEPOINT raise_credit_memo_event;

        OPEN okl_key_csr;
        FETCH okl_key_csr INTO l_seq;
        CLOSE okl_key_csr;
        l_key := l_event_name ||l_seq ;

        wf_event.AddParameterToList('REQUEST_ID',p_request_id,l_parameter_list);
        wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list); --dkagrawa added for MOAC
        -- Set the User Id, Responsibility Id and Application Id as workflow attributes Bug#5743303
        wf_event.AddParameterToList('USER_ID',Fnd_Global.User_Id,l_parameter_list);
        wf_event.AddParameterToList('RESPONSIBILITY_ID',Fnd_Global.Resp_Id,l_parameter_list);
        wf_event.AddParameterToList('APPLICATION_ID',Fnd_Global.Resp_Appl_Id,l_parameter_list);

   -- Raise Event
           wf_event.raise(p_event_name => l_event_name
                        ,p_event_key   => l_key
                        ,p_parameters  => l_parameter_list);
           l_parameter_list.DELETE;

EXCEPTION
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO raise_credit_memo_event;
END raise_credit_memo_event;



PROCEDURE populate_credit_memo_attribs(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
        l_approve_credit_memo_role  VARCHAR2(100) ; -- bug 7287398: changed from 50 to 100
        l_request_id    NUMBER;
        l_contract_id   NUMBER;
        l_contract_num VARCHAR2(100);

        CURSOR c_req_record(p_id IN NUMBER) IS
          SELECT *
          FROM OKL_TRX_REQUESTS
          WHERE ID = p_id;

       l_req_rec  c_req_record%ROWTYPE;

        CURSOR c_ctr_no(p_ctr_id IN NUMBER) IS
        SELECT contract_number
        FROM    OKC_K_HEADERS_V
        WHERE id=p_ctr_id;
BEGIN

        if (funcmode = 'RUN') then
                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                OPEN c_req_record(l_request_id);
                        FETCH c_req_record INTO l_req_rec;
                CLOSE c_req_record;

                  l_contract_id := l_req_rec.dnz_khr_id;

                  OPEN c_ctr_no(l_contract_id);
                  FETCH c_ctr_no INTO l_contract_num;
                  CLOSE c_ctr_no;

--rkuttiya added for bug:2923037
          l_approve_credit_memo_role	:=	fnd_profile.value('OKL_CREDIT_MEMO_REP');
	  IF l_approve_credit_memo_role IS NULL THEN
            l_approve_credit_memo_role        := 'SYSADMIN';
          END IF;
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'NOTIFICATION_ROLE',
                                                avalue  => l_approve_credit_memo_role);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CONTRACT_ID',
                                                avalue  => l_contract_id);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CREDIT_AMOUNT',
                                                avalue  => l_req_rec.amount);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'REQUEST_NUMBER',
                                                avalue  => l_req_rec.request_number);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'CONTRACT_NUMBER',
                                                avalue  => l_contract_num);
                wf_engine.SetItemAttrText (     itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'LSM_ID',
                                                avalue  => l_req_rec.lsm_id);
                resultout := 'COMPLETE:Y';
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';
                return;
                --
        end if;
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'populate_credit_memo_attribs',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END populate_credit_memo_attribs;


PROCEDURE create_credit_memo_invoice(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
    IS

        l_dummy   varchar(1) ;
        l_lsm_id                NUMBER ;
        l_credit_amount                NUMBER ;
        lx_tai_id                NUMBER ;
        l_return_status         VARCHAR2(100);
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
	l_sty_id		NUMBER;
	l_transaction_source    VARCHAR2(100); -- vpanwar for bug no 6334774

  CURSOR get_sty_id(c_lsm_id IN NUMBER)
  IS
  SELECT sty_id
  FROM OKL_CNSLD_AR_STRMS_B
  WHERE id=c_lsm_id;

    BEGIN

        if (funcmode = 'RUN') then
                l_lsm_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'LSM_ID');

                l_credit_amount := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'CREDIT_AMOUNT');
		--We need to send -ve amount to the API so negating the amount.
		l_credit_amount := -(l_credit_amount);

        OPEN get_sty_id(l_lsm_id);
        FETCH get_sty_id INTO l_sty_id;
        CLOSE get_sty_id;

	l_transaction_source := 'LEASE_CENTER'; -- vpanwar for bug no 6334774


        okl_credit_memo_pub.insert_request(p_api_version   => l_api_version,
                                           p_init_msg_list => fnd_api.g_false,
                                           -- p_lsm_id        => l_lsm_id,
                                           p_tld_id        => l_lsm_id,
                                           p_credit_amount => l_credit_amount,
					   p_credit_sty_id => l_sty_id,
					   p_transaction_source => l_transaction_source, -- vpanwar for bug no 6334774
                                           x_tai_id        => lx_tai_id,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data);

                --I think if the api is not a success we should log the error in a
                --table.

                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';

                ELSE

	                wf_engine.SetItemAttrText (itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'TAI_ID',
                                                avalue  => lx_tai_id);

                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'create_credit_memo_invoice',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END create_credit_memo_invoice;

PROCEDURE update_crm_approved_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
        l_request_id            NUMBER ;
        l_return_status         VARCHAR2(100);
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
        l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
        x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

    CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;


    BEGIN

        if (funcmode = 'RUN') then

                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                l_trqv_rec.id := l_request_id;
                l_trqv_rec.request_status_code := 'APPROVED';

	       OPEN c_obj_vers_csr(l_request_id);
	       FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	       CLOSE c_obj_vers_csr;

                        -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       =>fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);



                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';

                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'update_crm_approved_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END update_crm_approved_status;
-------------------------------


PROCEDURE update_crm_rejected_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
        l_request_id            NUMBER ;
        l_return_status         VARCHAR2(100);
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
        l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
        x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

    CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;


    BEGIN

        if (funcmode = 'RUN') then

                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                l_trqv_rec.id := l_request_id;
                l_trqv_rec.request_status_code := 'REJECTED';

	       OPEN c_obj_vers_csr(l_request_id);
	       FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	       CLOSE c_obj_vers_csr;

                        -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       =>fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);



                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';

                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'update_crm_rejected_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END update_crm_rejected_status;
-------------------------------



PROCEDURE update_crm_success_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS

        l_tai_id                NUMBER ;
        l_request_id                NUMBER ;
        l_return_status         VARCHAR2(100);
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
        l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
        x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

    CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;


    BEGIN

        if (funcmode = 'RUN') then
                l_tai_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'TAI_ID');

                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                l_trqv_rec.id := l_request_id;
                l_trqv_rec.object1_id1 := l_tai_id;
                l_trqv_rec.jtot_object1_code := 'OKL_TRX_AR_INVOICES_B';
                l_trqv_rec.request_status_code := 'ENTERED';

	       OPEN c_obj_vers_csr(l_request_id);
	       FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	       CLOSE c_obj_vers_csr;

                        -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       =>fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);



                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';

                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'update_crm_success_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END update_crm_success_status;

-------------------------------
PROCEDURE update_crm_error_status(itemtype  in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out nocopy varchar2)
AS
        l_request_id            NUMBER ;
        l_return_status         VARCHAR2(100);
        l_api_version           NUMBER  := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_error              VARCHAR2(2000);
        l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
        x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

    CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;


    BEGIN

        if (funcmode = 'RUN') then

                l_request_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey => itemkey,
                                                        aname   => 'REQUEST_ID');
                l_trqv_rec.id := l_request_id;
                l_trqv_rec.request_status_code := 'INCOMPLETE'; --Should this be error instead

	       OPEN c_obj_vers_csr(l_request_id);
	       FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	       CLOSE c_obj_vers_csr;

                        -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       =>fnd_api.g_false,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);



                IF l_return_status <> 'S' THEN
		       FND_MSG_PUB.Count_And_Get
               		    (  p_count          =>   l_msg_count,
               		       p_data           =>   l_msg_data
	                   );
       		       Get_Messages(l_msg_count,l_error);

		         wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'ERROR_MESSAGE',
                                   avalue    => l_error);

                        resultout := 'COMPLETE:N';

                ELSE
                        resultout := 'COMPLETE:Y';
                END IF;
                RETURN ;

        end if;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:N';

                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:Y';
                return ;
                --
        end if;
EXCEPTION
        when others then
          wf_core.context('OKL_CS_WF',
                'update_crm_error_status',
                itemtype,
                itemkey,
                to_char(actid),
                funcmode);
          RAISE;

END update_crm_error_status;
-------------------------------



END OKL_CS_WF;

/
