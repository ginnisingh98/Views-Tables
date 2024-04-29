--------------------------------------------------------
--  DDL for Package Body OKL_SO_CREDIT_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SO_CREDIT_APP_WF" AS
/* $Header: OKLRCRQB.pls 120.10.12010000.4 2009/06/02 10:39:04 racheruv ship $ */

  G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKL_SO_CREDIT_APP_WF';
  G_INIT_VERSION                  CONSTANT NUMBER        := 1.0;
  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;

  SUBTYPE lsqv_rec_type IS OKL_LSQ_PVT.LSQV_REC_TYPE; --Bug 7140398
  SUBTYPE lapv_rec_type IS OKL_LAP_PVT.LAPV_REC_TYPE; --  added for bug 7375141

   FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------------------------
 -- Return 'Y' if there are some active subscription for the given event
 -- Otherwise it returns 'N'
 -----------------------------------------------------------------------
 IS
  CURSOR cu0 IS
   SELECT 'Y'
     FROM wf_event_subscriptions a,
          wf_events b
    WHERE a.event_filter_guid = b.guid
      AND a.status = 'ENABLED'
      AND b.name   = p_event_name
      AND rownum   = 1;
  l_yn  VARCHAR2(1);
 BEGIN
  OPEN cu0;
   FETCH cu0 INTO l_yn;
   IF cu0%NOTFOUND THEN
      l_yn := 'N';
   END IF;
  CLOSE cu0;
  RETURN l_yn;
 END;
-----------------------------------------------------------------------

PROCEDURE create_credit_app_event
( p_quote_id   IN NUMBER,
  p_requestor_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2)
IS
 l_parameter_list wf_parameter_list_t;
 l_key  varchar2(240);
 l_yn   varchar2(1);
 l_event_name varchar2(240) := 'oracle.apps.okl.so.creditapplication';
 l_seq NUMBER ;
BEGIN

 SAVEPOINT create_credit_app_event;

x_return_status := OKC_API.G_RET_STS_SUCCESS ;
 -- Test if there are any active subscritions
 -- if it is the case then execute the subscriptions
 l_yn := exist_subscription(l_event_name);
 IF l_yn = 'Y' THEN

   --Get the item key
  select okl_wf_item_s.nextval INTO l_seq FROM DUAL ;
   l_key := l_event_name ||l_seq ;

   --Set Parameters
   wf_event.AddParameterToList('QUOTE_ID',TO_CHAR(p_quote_id),l_parameter_list);
   wf_event.AddParameterToList('REQUESTED_ID',TO_CHAR(p_requestor_id),l_parameter_list);
   --added by akrangan
   wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
 -- Call it again if you have more than one parameter
-- Keep data type (text) only

   -- Raise Event
   -- It is overloaded function so use according to requirement
   wf_event.raise(  p_event_name  => l_event_name
                             ,p_event_key   => l_key
                             ,p_parameters  => l_parameter_list);
   l_parameter_list.DELETE;

ELSE
  FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
  FND_MSG_PUB.ADD;
  x_return_status :=   OKC_API.G_RET_STS_ERROR ;
 END IF;
EXCEPTION

 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  FND_MSG_PUB.ADD;
  ROLLBACK TO create_credit_app_event;
 x_return_status :=   OKC_API.G_RET_STS_UNEXP_ERROR ;

END create_credit_app_event;

-- Start of comments
--
-- Procedure Name  : load_mess
-- Description     : Private procedure to load messages into attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  procedure load_mess(	itemtype	in varchar2,
				itemkey  	in varchar2) is
  i integer;
  j integer;
 begin
  j := NVL(FND_MSG_PUB.Count_Msg,0);
  if (j=0) then return; end if;
  if (j>9) then j:=9; end if;
  FOR I IN 1..J LOOP
    wf_engine.SetItemAttrText (itemtype 	=> itemtype,
	      			itemkey  	=> itemkey,
  	      			aname 	=> 'MESSAGE'||i,
		                avalue	=> FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
  END LOOP;
end;

-- sets requestor of credit request to the user who submitted the request.
procedure set_requestor( itemtype	in  varchar2
        				,itemkey  	in  varchar2
        				,actid		in  number
        				,funcmode	in  varchar2
        				,resultout	out NOCOPY varchar2) is

V_DUMMY             varchar2(240);
l_user_id           number;
l_request_id        number;
L_REQUESTOR 	     varchar2(240);
L_REQUESTOR_DNAME   varchar2(240);

cursor C_REQUESTOR_DISPLAY_NAME(P_USER_ID in number) is
  select user_name name,user_name display_name
  from   fnd_user
  where  user_id=P_USER_ID
  and    employee_id is null
union all
  select
       USR.USER_NAME name, PER.FULL_NAME display_name
  from
       PER_PEOPLE_F PER,
       FND_USER USR
  where  trunc(SYSDATE)
      between PER.EFFECTIVE_START_DATE and PER.EFFECTIVE_END_DATE
    and    PER.PERSON_ID       = USR.EMPLOYEE_ID
    and USR.USER_ID = P_USER_ID;

-- get the user who submitted the credit request
cursor c_submitted_by (b_credit_request_id IN NUMBER) IS
select source_user_id
from   ar_cmgt_credit_requests
where  credit_request_id = b_credit_request_id;

begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
--
-- Initiator/Initial
--
      l_request_id := TO_NUMBER( wf_engine.GetItemAttrText (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'CREDIT_REQUEST_ID'));

      open  c_submitted_by(l_request_id);
      fetch c_submitted_by INTO l_user_id;
      close c_submitted_by;
     wf_engine.SetItemAttrText (
         itemtype   => itemtype,
            itemkey => itemkey,
            aname   => 'USER_ID',
         avalue     => L_USER_ID);

	  open  C_REQUESTOR_DISPLAY_NAME(l_user_id);
	  fetch C_REQUESTOR_DISPLAY_NAME into L_REQUESTOR, L_REQUESTOR_DNAME;
	  close C_REQUESTOR_DISPLAY_NAME;
	  wf_engine.SetItemAttrText (
			itemtype=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'REQUESTOR',
			avalue	=> L_REQUESTOR);
	  wf_engine.SetItemAttrText (
			itemtype=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'REQUESTOR_DNAME',
			avalue	=> L_REQUESTOR_DNAME);

	  resultout := 'COMPLETE:';
  	  return;
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
exception
	when others then
	  wf_core.context('OKL_SO_CREDIT_APP_WF',
		'SET_REQUESTOR',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
end set_requestor;

-- sets approver  of credit request to the user who submitted the request.
procedure set_approver ( itemtype	in  varchar2
        				,itemkey  	in  varchar2
        				,actid		in  number
        				,funcmode	in  varchar2
        				,resultout	out NOCOPY varchar2) IS

V_DUMMY             varchar2(240);
l_user_id           number;
l_request_id        number;
L_APPROVER  	     varchar2(240);
L_APPROVER_DNAME    varchar2(240);

CURSOR C_APPROVER_DISPLAY_NAME IS
select role, name
from
(select 1 num, FND_PROFILE.VALUE('OKL_CREDIT_ANALYST') role,
	   NVL(PER.FULL_NAME, USR.USER_NAME) name
   from FND_USER USR, PER_PEOPLE_F PER
  where USR.USER_NAME = FND_PROFILE.VALUE('OKL_CREDIT_ANALYST')
    and USR.EMPLOYEE_ID = PER.PERSON_ID(+)
    and trunc(sysdate) between nvl(per.effective_start_date, trunc(sysdate)) and
						 nvl(per.effective_end_date, trunc(sysdate))
);

BEGIN
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
	  open  C_APPROVER_DISPLAY_NAME;
	  fetch C_APPROVER_DISPLAY_NAME into L_APPROVER,L_APPROVER_DNAME;
	  close C_APPROVER_DISPLAY_NAME;
	  wf_engine.SetItemAttrText (
			itemtype=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'APPROVER',
			avalue	=> L_APPROVER);
	  wf_engine.SetItemAttrText (
			itemtype=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'APPROVER_DNAME',
			avalue	=> L_APPROVER_DNAME);
--
	  resultout := 'COMPLETE:';
  	  return;
	--
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
	  wf_core.context('OKL_SO_CREDIT_APP_WF',
		'SET_APPROVER',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
END set_approver;

    -- sets credit request attributes in workflow with details from the credit
    -- request.
procedure credit_app_details ( itemtype	in  varchar2
            				,itemkey  	in  varchar2
            				,actid		in  number
            				,funcmode	in  varchar2
            				,resultout	out NOCOPY varchar2) is

    v_dummy             VARCHAR2(240);
    l_request_id        NUMBER;
    l_quote_number      VARCHAR2(120);
    l_credit_req_number VARCHAR2(30);
    l_credit_amount     NUMBER;
    l_requested_date    DATE;
    l_account_number    VARCHAR2(30);
    l_party_name        VARCHAR2(360);
    l_recomendation     VARCHAR2(30);
    l_recomend_value1   VARCHAR2(60);
    l_recomend_value2   VARCHAR2(60);
    l_okl_request_id    NUMBER;
    l_quote_id          NUMBER;
    l_request_status    VARCHAR2(30);
    l_currency          VARCHAR2(10);
    -- stub  out the cursor sql, since this procedure is not used
    -- Performance fix - bug#5484903
    CURSOR c_credit_app_details (b_credit_request_id IN NUMBER) IS
    SELECT
        null  quote_number
        ,null credit_req_number
        ,to_number(null) credit_amount
        ,to_date(null) requested_date
        ,null account_number
        ,null party_name
        ,to_number(null) id                  -- okl credit request id
        ,to_number(null) quote_id
        ,null status              -- lookup code (not meaning)
        ,null currency_code
     from dual;


    CURSOR c_recomendation (b_credit_request_id IN NUMBER) IS
    SELECT
         credit_recommendation
        ,recommendation_value1
        ,recommendation_value2
   FROM  ar_cmgt_cf_recommends
   WHERE credit_request_id = b_credit_request_id;

    begin
    	--
    	-- RUN mode - normal process execution
    	--
    	if (funcmode = 'RUN') then
    --
    -- Initiator/Initial
    --
          l_request_id := TO_NUMBER( wf_engine.GetItemAttrText (
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'CREDIT_REQUEST_ID'));

          open  c_credit_app_details(l_request_id);
          fetch c_credit_app_details INTO l_quote_number,
                                          l_credit_req_number,
                                          l_credit_amount,
                                          l_requested_date,
                                          l_account_number,
                                          l_party_name,
                                          l_okl_request_id,
                                          l_quote_id,
                                          l_request_status,
                                          l_currency;
          close c_credit_app_details;

         -- open  c_recomendation(l_request_id);
         -- fetch c_recomendation INTO l_recomendation,
         --                            l_recomend_value1,
         --                            l_recomend_value2;
         -- close c_recomendation;

         FOR r_recomendation IN c_recomendation(l_request_id) LOOP

             IF r_recomendation.credit_recommendation = 'APPROVE' THEN

                l_recomendation    := r_recomendation.credit_recommendation;
                l_recomend_value1  := r_recomendation.recommendation_value1;
                l_recomend_value2  := r_recomendation.recommendation_value2;

             ELSIF r_recomendation.credit_recommendation = 'REJECT' THEN

                l_recomendation    := r_recomendation.credit_recommendation;
                l_recomend_value1  := r_recomendation.recommendation_value1;
                l_recomend_value2  := r_recomendation.recommendation_value2;

             ELSE
                null; -- do nothing, other scenarios not yet used.
                -- l_recomendation    := r_recomendation.credit_recommendation;
                -- l_recomend_value1  := r_recomendation.recommendation_value1;
                -- l_recomend_value2  := r_recomendation.recommendation_value2;

             END IF;

         END LOOP; -- r_recomendation

         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'QUOTE_NUM',
                 avalue => l_quote_number);
    	  wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'CREDIT_REQ_NUM',
                 avalue => l_credit_req_number);
    	  wf_engine.SetItemAttrText (
    			itemtype=> itemtype,
    	      	itemkey	=> itemkey,
      	      	aname 	=> 'CREDIT_AMOUNT',
    			avalue	=> l_credit_amount);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'CREDIT_REQ_DATE',
                 avalue => l_requested_date);
    	  wf_engine.SetItemAttrText (
    			itemtype=> itemtype,
    	      	itemkey	=> itemkey,
      	      	aname 	=> 'CUST_ACCT_NUM',
    			avalue	=> l_account_number);
    	  wf_engine.SetItemAttrText (
    			itemtype=> itemtype,
    	      	itemkey	=> itemkey,
      	      	aname 	=> 'PARTY_NAME',
    			avalue	=> l_party_name);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'CREDIT_RECOMENDATION',
                 avalue => l_recomendation);
    	  wf_engine.SetItemAttrText (
    			itemtype=> itemtype,
    	      	itemkey	=> itemkey,
      	      	aname 	=> 'RECOMEND_VALUE1',
    			avalue	=> l_recomend_value1);
    	  wf_engine.SetItemAttrText (
    			itemtype=> itemtype,
    	      	itemkey	=> itemkey,
      	      	aname 	=> 'RECOMEND_VALUE2',
    			avalue	=> l_recomend_value2);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'ID',
                 avalue => l_okl_request_id);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'QUOTE_ID',
                 avalue => l_quote_id);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'REQUEST_STATUS',
                 avalue => l_request_status);
         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'CURRENCY',
                 avalue => l_currency);
    --
         IF l_recomendation = 'APPROVE' THEN
         	resultout := 'COMPLETE:T';
            return;
         ELSE
            resultout := 'COMPLETE:F';
            return;
         END IF;

    	--
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

exception
    	when others then
    	  wf_core.context('OKL_SO_CREDIT_APP_WF',
    		'CREDIT_APP_DETAILS',
    		itemtype,
    		itemkey,
    		to_char(actid),
    		funcmode);
    	  raise;
end credit_app_details;

--------------------------------------------------------------------------------
-- CREATE_CREDIT_LINE --
--------------------------------------------------------------------------------
  procedure CREATE_CREDIT_LINE ( 		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	)IS

  -- Variables --
  l_party_id          NUMBER;
  l_customer_name     VARCHAR2(360);
  l_cust_acct_id      NUMBER;
  l_cust_acct_num     VARCHAR2(30);
  l_site_use_id       NUMBER;
  l_limit_currency    VARCHAR2(15);
  l_limit_amount      NUMBER;
  l_trx_currency      VARCHAR2(15);
  l_trx_amount        NUMBER;
  --
  l_quote_id          NUMBER;
  l_credit_req_number VARCHAR2(90);
  l_credit_req_id     NUMBER;
  l_credit_amount     NUMBER;
  l_approved_by       NUMBER;
  l_approved_date     DATE;
  l_effective_from    DATE; -- application date
  l_effective_to      DATE; --
  l_status            VARCHAR2(30);
  l_credit_khr_id     NUMBER;
  l_credit_khr_desc   VARCHAR2(200);
  l_org_id            NUMBER;
  l_currency_code     VARCHAR2(15);
  --
  l_key               VARCHAR2(240); -- := p_event.GetEventKey();
  l_request_id        NUMBER;        -- := p_event.GetValueForParameter('CREDIT_REQUEST_ID');
  --
  l_credit_recommendation VARCHAR2(30);
  l_recommendation_value1 VARCHAR2(60);
  l_recommendation_value2 VARCHAR2(60);
  --
  lx_chr_rec          l_chr_rec;
  l_crqv_rec          OKL_CRQ_PVT.crqv_rec_type;
  lx_crqv_rec         OKL_CRQ_PVT.crqv_rec_type;
  l_crqv_tbl          OKL_CRQ_PVT.crqv_tbl_type;
  l_interaction_rec   JTF_IH_PUB.interaction_rec_type;
  l_activity_rec      JTF_IH_PUB.activity_rec_type;
  lx_interaction_id   NUMBER;
  l_action_id         NUMBER;
  lx_activity_id      NUMBER;
  l_login_id          NUMBER;
  l_resource_id       NUMBER;
  l_requestor_id      NUMBER;
  l_capital_amount    NUMBER;
  l_okl_credit_req    NUMBER;

  l_user_id           NUMBER;
  l_resp_id           NUMBER;
  l_resp_appl_id      NUMBER;
  L_SUBMITTED_BY      NUMBER;

  ls_request_num      VARCHAR2(80);
  l_seq               NUMBER;

  l_credit_k_number   VARCHAR2(100);
  l_amount            NUMBER ;
  l_object1_id        OKC_K_PARTY_ROLES_V.object1_id1%TYPE;
  l_object2_id2       OKC_K_PARTY_ROLES_V.object1_id2%TYPE;
  l_jtot_object_code  OKC_K_PARTY_ROLES_V.JTOT_OBJECT1_CODE%TYPE;
  x_chr_id            NUMBER;
  l_crqv_rec_type     OKL_CREDIT_REQUEST_PUB.crqv_rec_type ;
  x_crqv_rec_type     OKL_CREDIT_REQUEST_PUB.crqv_rec_type ;
  l_rlg_id            NUMBER;
  l_rulv_rec          OKL_RULE_PUB.rulv_rec_type ;
  x_rulv_rec          OKL_RULE_PUB.rulv_rec_type ;
  l_rgpv_rec          OKL_RULE_PUB.rgpv_rec_type ;
  x_rgpv_rec          OKL_RULE_PUB.rgpv_rec_type ;
  --p_clev_rec          OKL_OKC_MIGRATION_PVT.clev_rec_type;
  --p_klev_rec          OKL_CONTRACT_PUB.klev_rec_type;
  --x_clev_rec          OKL_OKC_MIGRATION_PVT.clev_rec_type;
  --x_klev_rec          OKL_CONTRACT_PUB.klev_rec_type;
  p_clev_tbl          OKL_CREDIT_PUB.clev_tbl_type;
  p_klev_tbl          OKL_KLE_PVT.klev_tbl_type;
  x_clev_tbl          OKL_CREDIT_PUB.clev_tbl_type;
  x_klev_tbl          OKL_KLE_PVT.klev_tbl_type;

  x_msg_data          VARCHAR2(2000);
  x_msg_count         NUMBER          := 0 ;
  l_api_version       NUMBER          := 1 ;
  x_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_inv_org_id        NUMBER;

  CURSOR l_okl_lse_id IS
  SELECT id
  FROM   OKC_LINE_STYLES_b
  WHERE  LTY_CODE = 'FREE_FORM';

  -- get party name
  CURSOR c_party_name(b_party_id IN NUMBER) IS
  SELECT name
  FROM   okx_parties_v
  WHERE  id1 = b_party_id;

  -- get credit request info
  CURSOR c_credit_request (b_credit_request_id IN NUMBER) IS
  SELECT
         limit_currency
        ,limit_amount
        ,trx_currency
        ,trx_amount
        ,party_id
        ,cust_account_id
        ,site_use_id
        ,application_date
  FROM   ar_cmgt_credit_requests
  WHERE  credit_request_id = b_credit_request_id;

  -- credit/contract relationship
  CURSOR c_okl_credit_request (b_credit_request_id IN NUMBER) IS
  SELECT
     quote_id           -- this is actually the contract id.
    ,credit_req_number
    ,credit_req_id
    ,credit_amount
    ,approved_by
    ,approved_date
    ,status
    ,credit_khr_id
    ,currency_code
    ,org_id
    ,created_by
  FROM  okl_credit_requests
  WHERE credit_req_id = b_credit_request_id;

  -- cursor to get inventory org id of the sales quote
 CURSOR c_get_inv_org_id (p_qte_id IN NUMBER) IS
 SELECT INV_ORGANIZATION_ID FROM OKC_K_HEADERS_B
 WHERE ID = p_qte_id;

  CURSOR c_recommendation (b_request_id IN NUMBER) IS
  SELECT credit_recommendation,
         recommendation_value1,
         recommendation_value2
  FROM   ar_cmgt_cf_recommends
  WHERE  credit_request_id = b_request_id ;

  CURSOR get_resource_id(b_user_id NUMBER) IS
  SELECT resource_id
  FROM   jtf_rs_resource_extns
  WHERE  user_id = b_user_id;

  CURSOR c_approver_user_id (b_user_name IN VARCHAR2) IS
  SELECT user_id
  FROM   fnd_user
  WHERE  user_name = b_user_name;

BEGIN
  	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then

   l_request_id := TO_NUMBER( wf_engine.GetItemAttrText (
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'CREDIT_REQUEST_ID'));

    IF (wf_engine.GetItemAttrText(itemtype,itemkey,'TLOC_END_DATE') is NULL) then
         resultout := 'ERROR: Must enter an End Date for Term Line of Credit ';
	      --resultout := 'COMPLETE:F';
    ELSE
      l_effective_to := wf_engine.GetItemAttrText(itemtype,itemkey,'TLOC_END_DATE');
      -- assign a val just in case.  should not go here
      IF l_effective_to IS NULL THEN
         l_effective_to := sysdate + 30;
      END IF;
	 END IF;

    OPEN  c_credit_request(l_request_id);
    FETCH c_credit_request INTO l_limit_currency, l_limit_amount,
                                l_trx_currency, l_trx_amount,
                                l_party_id, l_cust_acct_id, l_site_use_id,
                                l_effective_from;
    IF    c_credit_request%NOTFOUND THEN
          -- add message -- credit request not found
          CLOSE c_credit_request;
          resultout := 'ERROR:  unable to find credit request';
          return;
    END IF;
    CLOSE c_credit_request;

    OPEN  c_okl_credit_request (l_request_id);
    FETCH c_okl_credit_request INTO l_quote_id, l_credit_req_number, l_credit_req_id,
          l_credit_amount, l_approved_by, l_approved_date, l_status, l_credit_khr_id,
          l_currency_code, l_org_id, l_user_id;
    IF    c_okl_credit_request%NOTFOUND THEN
          -- add message -- credit request not found
          CLOSE c_okl_credit_request;
          resultout := 'ERROR:  unable to find credit request';
          return;
    END IF;
    CLOSE c_okl_credit_request;

    OPEN  c_get_inv_org_id (l_quote_id);
    FETCH c_get_inv_org_id INTO l_inv_org_id;
    IF    c_get_inv_org_id%NOTFOUND THEN
          -- add message -- credit request not found
          CLOSE c_get_inv_org_id;
          resultout := 'ERROR:  unable to find inventory orgainzation id';
          return;
    END IF;
    CLOSE c_get_inv_org_id;

    OPEN  c_approver_user_id(FND_PROFILE.VALUE('OKL_CREDIT_ANALYST'));
    FETCH c_approver_user_id INTO l_approved_by;
    close c_approver_user_id;

    -- get credit checklist.
    -- will pass checklist as a parameter from the submit credit request UI
    -- in the future.

   l_object2_id2      := '#';
   l_jtot_object_code := 'OKX_PARTY';
   l_credit_khr_desc := 'Created as a result of credit request '||l_request_id;

   OPEN  c_party_name(l_party_id);
   FETCH c_party_name INTO l_customer_name;
   CLOSE c_party_name;

 --  3. CREATE CREDIT LINE CONTRACT
   OKL_CREDIT_PUB.create_credit(
        p_api_version                  => l_api_version,
        p_init_msg_list                => OKC_API.G_TRUE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_contract_number              => null,
        p_description                  => l_credit_khr_desc,
        p_customer_id1                 => l_party_id,
        p_customer_id2                 => l_object2_id2,           -- '#'
        p_customer_code                => l_jtot_object_code,      -- 'OKX_PARTY'
        p_customer_name                => l_customer_name,
        p_effective_from               => l_effective_from,
        p_effective_to                 => l_effective_to,
        p_currency_code                => l_currency_code,
        p_currency_conv_type           => null,
        p_currency_conv_rate           => null,
        p_currency_conv_date           => null,
            -- the following two parameters are post 12/31 --
        p_credit_ckl_id                => null, --G_CREDIT_CHKLST_TPL,
        p_funding_ckl_id               => null,
            -- added customer account details due to rules migration
        p_cust_acct_id                 => l_cust_acct_id, -- 11.5.10 rule migration project
        p_cust_acct_number             => l_cust_acct_num, -- 11.5.10 rule migration project
        p_revolving_credit_yn          => 'N', -- Need to find
        p_sts_code                     => 'NEW',-- Need to verify
        p_org_id                       => l_org_id ,
        p_organization_id              => l_inv_org_id,
        p_source_chr_id                => null,
        x_chr_id                       => x_chr_id);

   IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
        resultout := 'ERROR:' || x_msg_data;
        return;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         resultout := 'ERROR:FALSE';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

/**** Customer Account rule now created on header ******************
*
*-- create customer account rule group and rule
* IF l_cust_acct_id IS NOT NULL THEN
*
     --5 CREATE RULE GROUP
     l_rgpv_rec.dnz_chr_id := x_chr_id ;
     l_rgpv_rec.rgp_type   := 'KRG' ;
     l_rgpv_rec.rgd_code   := 'LACAN' ;
     l_rgpv_rec.chr_id     := x_chr_id;

     okl_rule_pub.create_rule_group(
        p_api_version                  =>l_api_version,
        p_init_msg_list                => OKC_API.G_TRUE,
        x_return_status                =>x_return_status,
        x_msg_count                    =>x_msg_count,
        x_msg_data                     =>x_msg_data,
        p_rgpv_rec                     =>  l_rgpv_rec,
        x_rgpv_rec                     => x_rgpv_rec);


     IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
        resultout := 'ERROR:' || x_msg_data;
    	  return;
   	      -- RAISE FND_API.G_EXC_ERROR;
	 ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
           resultout := 'ERROR:FALSE';
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

     -- 6. CREATE RULE

     l_rulv_rec.rgp_id                    := x_rgpv_rec.id ;
     l_rulv_rec.DNZ_CHR_ID                := x_chr_id ;
     l_rulv_rec.rule_information_category := 'CAN';
     l_rulv_rec.object1_id1               := l_cust_acct_id;
     l_rulv_rec.object1_id2               := '#';
     l_rulv_rec.jtot_object1_code         := 'OKX_CUSTACCT';
     l_rulv_rec.WARN_YN                   := 'N';
     l_rulv_rec.STD_TEMPLATE_YN           := 'N';

     okl_rule_pub.create_rule(
        p_api_version                  =>l_api_version,
        p_init_msg_list                => OKC_API.G_TRUE,
        x_return_status                =>x_return_status,
        x_msg_count                    =>x_msg_count,
        x_msg_data                     =>x_msg_data,
        p_rulv_rec                     =>l_rulv_rec,
        x_rulv_rec                     =>x_rulv_rec);

    IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
         resultout := 'ERROR:' || x_msg_data;
    		return;
	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
*        resultout := 'ERROR:FALSE';
*   	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*	END IF;
* END IF; -- create customer account
*
*************************************************************************/

    -- CREATE contract line
   p_clev_tbl(0).dnz_chr_id := x_chr_id;

   OPEN  l_okl_lse_id;
   FETCH l_okl_lse_id INTO p_clev_tbl(0).lse_id ;
     IF( l_okl_lse_id%NOTFOUND) THEN
         resultout := 'ERROR: No Line Style';
         return;
      END IF;
   CLOSE l_okl_lse_id ;

   p_clev_tbl(0).chr_id                := x_chr_id;
   p_clev_tbl(0).LINE_NUMBER           := 1;
   p_clev_tbl(0).STS_CODE              := 'NEW';
   p_clev_tbl(0).DISPLAY_SEQUENCE      := 1;
   p_clev_tbl(0).EXCEPTION_YN          := 'N';
   p_clev_tbl(0).START_DATE            := l_effective_from;
   p_klev_tbl(0).amount                :=  l_credit_amount;
   p_klev_tbl(0).credit_nature         := 'NEW';
   p_klev_tbl(0).OBJECT_VERSION_NUMBER := 1 ;

   OKL_CREDIT_PUB.create_credit_limit(
        p_api_version                  => l_api_version,
        p_init_msg_list                => OKC_API.G_TRUE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clev_tbl                     => p_clev_tbl,
        p_klev_tbl                     => p_klev_tbl,
        x_clev_tbl                     => x_clev_tbl,
        x_klev_tbl                     => x_klev_tbl);

   IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       resultout := 'ERROR:' || x_msg_data;
       return;
	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          resultout := 'ERROR:FALSE';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    -- 7. Change Status of the credit request
   l_okl_credit_req :=  wf_engine.GetItemAttrNumber (
           itemtype => itemtype,
           itemkey  => itemkey,
           aname    => 'ID');

    SELECT OBJECT_VERSION_NUMBER
    INTO   l_crqv_rec_type.OBJECT_VERSION_NUMBER
    FROM   OKL_CREDIT_REQUESTS
    WHERE  ID = l_okl_credit_req ;

   l_crqv_rec_type.ID            := l_okl_credit_req ;
   l_crqv_rec_type.STATUS        := 'APPROVED';
   l_crqv_rec_type.CREDIT_KHR_ID := x_chr_id ;
   l_crqv_rec_type.approved_by   := l_approved_by;
   l_crqv_rec_type.approved_date := SYSDATE;

         wf_engine.SetItemAttrText (
               itemtype => itemtype,
                itemkey => itemkey,
                  aname => 'REQUEST_STATUS',
                 avalue => l_crqv_rec_type.STATUS);

   okl_credit_request_pub.update_credit_request(
         p_api_version                  => l_api_version
        ,p_init_msg_list                => 'T'
        ,x_return_status                =>x_return_status
        ,x_msg_count                    => x_msg_count
        ,x_msg_data                     =>x_msg_data
        ,p_crqv_rec                     =>l_crqv_rec_type
        ,x_crqv_rec                     => x_crqv_rec_type);

 	IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
        resultout := 'ERROR:' || x_msg_data;
    	  return;
	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            resultout := 'ERROR:NO';
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    -- create Interaction History.
    l_login_id := fnd_global.login_id;
    l_resp_id           := fnd_global.RESP_ID;

    OPEN  get_resource_id (l_user_id);
    FETCH get_resource_id INTO l_resource_id;
    CLOSE get_resource_id;

--
-- will not need all these --
    -- l_interaction_rec.interaction_id             := ;
    --l_interaction_rec.reference_form             := null;
    --l_interaction_rec.follow_up_action           := null;
    --l_interaction_rec.duration                   := 0;
    --l_interaction_rec.inter_interaction_duration := 0;
    --l_interaction_rec.non_productive_time_amount := null;
    --l_interaction_rec.preview_time_amount        := null;
    --l_interaction_rec.productive_time_amount     := 0;
    l_interaction_rec.start_date_time            := sysdate;
    --l_interaction_rec.end_date_time              := null;
    --l_interaction_rec.wrapup_time_amount         := null;
    l_interaction_rec.handler_id                 := 540; -- OKL - Lease Management
    --l_interaction_rec.source_code_id             := null;
    --l_interaction_rec.source_code                := null;
    --l_interaction_rec.script_id                  := null;
    l_interaction_rec.resource_id                := l_resource_id;
    l_interaction_rec.outcome_id                 := 10 ; -- Request Processed
    l_interaction_rec.party_id                   := l_party_id;
    --l_interaction_rec.result_id                  := null; --6;
    --l_interaction_rec.reason_id                  := null;
    --l_interaction_rec.parent_id                  := null;
    --l_interaction_rec.object_id                  := null;
    --l_interaction_rec.object_type                := null;

    jtf_ih_pub.open_interaction(
            p_api_version     => l_api_version,
            p_init_msg_list   => okl_api.g_true,
            p_commit          => okl_api.g_false,
            p_user_id         => l_user_id,
            p_login_id        => l_login_id,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_interaction_rec => l_interaction_rec,
            x_interaction_id  => lx_interaction_id);

   IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       resultout := 'ERROR:NO';
         return;
   -- RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            resultout := 'ERROR:NO';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- l_activity_rec.activity_id             :=
    --l_activity_rec.duration                := 0;
    l_activity_rec.cust_account_id         := lx_chr_rec.cust_acct_id;
    l_activity_rec.cust_org_id             := lx_chr_rec.org_id;
    --l_activity_rec.role                    := null;
    l_activity_rec.start_date_time         := sysdate;
    --l_activity_rec.task_id                 := null;
    --l_activity_rec.doc_id                  := null;
    --l_activity_rec.doc_ref                 := null;
    --l_activity_rec.doc_source_object_name  := null;
    --l_activity_rec.media_id                := null;
    l_activity_rec.action_item_id          := 87; -- Credit Request
    l_activity_rec.interaction_id          := lx_interaction_id;
    l_activity_rec.outcome_id              := 10;
    --l_activity_rec.result_id               := null;
    --l_activity_rec.reason_id               := null;
    --l_activity_rec.description             := null;
    l_activity_rec.action_id               := 81;    -- Approved
    --l_activity_rec.interaction_action_type := null;
    --l_activity_rec.object_id               := null;
    --l_activity_rec.object_type             := null;
    --l_activity_rec.source_code_id          := null;
    --l_activity_rec.source_code             := null;

    jtf_ih_pub.add_activity(
            p_api_version     => l_api_version,
            p_init_msg_list   => okl_api.g_true,
            p_commit          => okl_api.g_false,
            p_user_id         => l_user_id,
            p_login_id        => l_login_id,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_activity_rec    => l_activity_rec,
            x_activity_id     => lx_activity_id);

   IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       resultout := 'ERROR:NO';
         return;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            resultout := 'ERROR:NO';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   jtf_ih_pub.CLOSE_INTERACTION (
            p_api_version     => l_api_version,
            p_init_msg_list   => okl_api.g_true,
            p_commit          => okl_api.g_false,
            P_RESP_APPL_ID    => l_resp_appl_id,
            P_RESP_ID         => l_resp_id,
            P_USER_ID         => l_user_id,
            P_LOGIN_ID        => l_login_id,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            P_INTERACTION_ID  => lx_interaction_id);

   IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       resultout := 'ERROR:NO';
         return;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            resultout := 'ERROR:NO';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	  resultout := 'COMPLETE:YES';
  	  return;
	--
	END IF;
	--
  	-- CANCEL mode
	--
  	if (funcmode = 'CANCEL') then
		--
	      resultout := 'COMPLETE:YES';
    		return;
		--
  	end if;
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
	      resultout := 'COMPLETE:NO';
    		return;
		--
	end if;

exception
	when others then
	  wf_core.context('OKL_SO_CREDIT_WF',
		'CREATE_CREDIT_LINE',itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
END CREATE_CREDIT_LINE;

  ------------------------------------------------------------------------------
  -- PROCEDURE update_status
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_status
  -- Description     : This procedure updates the lease application status.
  -- Business Rules  : This procedure updates the lease application status.
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 26-Oct-2005 PAGARG updated
  --                   19-Nov-2008 gboomina Bug 6971371 Modified the logic to update
  --                   Lease App based on status of Credit Recommendation

  --
  -- End of comments
  PROCEDURE UPDATE_STATUS(
            itemtype    IN  VARCHAR2,
            itemkey     IN  VARCHAR2,
            actid       IN  NUMBER,
            funcmode    IN  VARCHAR2,
            resultout   OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_STATUS';
    l_return_status            VARCHAR2(1);
    x_msg_data                 VARCHAR2(2000);
    x_msg_count                NUMBER := 0;
    l_lap_status               VARCHAR2(30);
    l_prospect_id              NUMBER;
    l_cust_acct_id             NUMBER;
    l_org_id                   NUMBER;

    --Bug 6651146 PAGARG use base table instead of secured synonym to obtain
    --lease app id
    CURSOR credit_req_csr(cp_credit_req_id IN NUMBER)
    IS
      SELECT CCR.SOURCE_COLUMN1
           , LAB.CREATED_BY
           , LAB.PROSPECT_ID
           , LAB.CUST_ACCT_ID
           , LAB.ORG_ID
      FROM AR_CMGT_CREDIT_REQUESTS CCR
         , OKL_LEASE_APPS_ALL_B LAB
      WHERE CCR.SOURCE_COLUMN3 = 'LEASEAPP'
        AND CCR.SOURCE_COLUMN1 = LAB.ID
		AND CCR.CREDIT_REQUEST_ID = cp_credit_req_id;

    l_credit_req_id      AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE;
    l_lap_id             OKL_LEASE_APPLICATIONS_B.ID%TYPE;
    l_created_by         OKL_LEASE_APPLICATIONS_B.CREATED_BY%TYPE;
    -- Bug#4741121 - viselvar  - Modified - Start
    l_parameter_list           wf_parameter_list_t;
    p_event_name               VARCHAR2(240)       := 'oracle.apps.okl.sales.leaseapplication.record_credit_decision';
    -- Bug#4741121 - viselvar  - Modified - End


    CURSOR credit_req_sts_csr(p_credit_request_id IN NUMBER)
    IS
      SELECT credit_recommendation, status
      FROM ar_cmgt_cf_recommends
      WHERE credit_request_id = p_credit_request_id
        AND credit_recommendation IN ('REJECT','APPROVE');

      l_request_status     ar_cmgt_cf_recommends.status%TYPE;
      l_cr_recom           ar_cmgt_cf_recommends.credit_recommendation%TYPE;

      --Bug 7140398 START
      CURSOR get_main_offer_csr(cp_lap_id NUMBER) IS
       SELECT ID
       FROM OKL_LEASE_QUOTES_B
       WHERE PARENT_OBJECT_ID = cp_lap_id
       AND   PARENT_OBJECT_CODE = 'LEASEAPP'
        AND PRIMARY_QUOTE = 'Y';

        l_lsq_id okl_lease_quotes_b.id%type;

        CURSOR is_counter_offer_exist(cp_lap_id NUMBER) IS
         SELECT DISTINCT STATUS
       FROM okl_lease_quotes_b
       WHERE status = 'CR-RECOMMENDATION'
       AND parent_object_code = 'LEASEAPP'
       AND PARENT_OBJECT_ID =  cp_lap_id;

      l_counter_offer_exist VARCHAR2(1) := 'N';
      l_status okl_lease_quotes_b.status%type;
      l_lsqv_rec         lsqv_rec_type;
      x_lsqv_rec         lsqv_rec_type;
      --Bug 7140398 END

      -- Added for bug 7375141
      l_lapv_rec         lapv_rec_type;
      x_lapv_rec         lapv_rec_type;
      l_exp_date              DATE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_SO_CREDIT_APP_WF.UPDATE_STATUS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

   	--
	-- RUN mode - normal process execution
	--
    IF (funcmode = 'RUN')
	THEN
      l_credit_req_id :=  wf_engine.GetItemAttrNumber (
                      itemtype   => itemtype
                     ,itemkey    => itemkey
                     ,aname      => 'CREDIT_REQUEST_ID');

      OPEN credit_req_csr(l_credit_req_id);
      FETCH credit_req_csr INTO l_lap_id
                              , l_created_by
                              , l_prospect_id
                              , l_cust_acct_id
                              , l_org_id;
      CLOSE credit_req_csr;

      --Bug 6651146 PAGARG set the org of lease app in session for update api
      --to work properly.
      MO_GLOBAL.set_policy_context('S', l_org_id);

      OPEN credit_req_sts_csr(l_credit_req_id);
      FETCH credit_req_sts_csr INTO l_cr_recom, l_request_status;
      CLOSE credit_req_sts_csr;

      IF(l_cr_recom = 'APPROVE' AND l_request_status = 'I')
      THEN
        --If approve recommendation is added in status I then
        --update lease app status to Credit Approved
        l_lap_status := 'CR-APPROVED';
      ELSIF(l_cr_recom = 'REJECT' AND l_request_status = 'I')
      THEN
        --If reject recommendation is added in status I then
        --update lease app status to Credit Rejected
        l_lap_status := 'CR-REJECTED';
      ELSIF ((l_cr_recom = 'REJECT' OR l_cr_recom = 'APPROVE') AND
                l_request_status = 'R')
      THEN
        --If reject or approve recommendation is added and is in status R then
        --update lease app status to Recommendations Not Approved
        l_lap_status := 'RECOM_NOT_APPROVED';
      END IF;

      --Bug 7140398 START
       l_counter_offer_exist := 'N';
     OPEN is_counter_offer_exist (l_lap_id);
     FETCH is_counter_offer_exist INTO l_status;
     IF is_counter_offer_exist%NOTFOUND THEN
       l_counter_offer_exist := 'N';
     else
        l_counter_offer_exist := 'Y';
     END IF;
     CLOSE is_counter_offer_exist;

     IF (l_cr_recom = 'REJECT' OR l_counter_offer_exist = 'Y' OR l_lap_status = 'RECOM_NOT_APPROVED') THEN
         OPEN get_main_offer_csr (l_lap_id);
         FETCH get_main_offer_csr INTO l_lsq_id;
         CLOSE get_main_offer_csr;
         l_lsqv_rec.id := l_lsq_id;

       IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
       THEN
         OKL_DEBUG_PUB.LOG_DEBUG(
             FND_LOG.LEVEL_PROCEDURE
            ,L_MODULE
            ,'begin debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
       END IF;

       -- call the procedure to create lease quote line
       OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE(
           p_api_version                        => l_api_version
          ,p_init_msg_list                      => OKL_API.G_FALSE
          ,p_transaction_control                => OKL_API.G_TRUE
          ,p_lease_qte_rec                      => l_lsqv_rec
          ,x_lease_qte_rec                      => x_lsqv_rec
          ,x_return_status                      => l_return_status
          ,x_msg_count                          => x_msg_count
          ,x_msg_data                           => x_msg_data);

       IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
       THEN
         OKL_DEBUG_PUB.LOG_DEBUG(
             FND_LOG.LEVEL_PROCEDURE
            ,L_MODULE
            ,'end debug call OKL_LEASE_QUOTE_PVT.UPDATE_LEASE_QTE');
       END IF;


       IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     END IF;

     --Bug 7140398 END

      --l_lap_status will be null if Reject or Approve recommendation is not
      --available in status I or R in that case don't call api to update lease app status

      IF(l_lap_status IS NOT NULL)
      THEN
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS');
        END IF;

        OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS(
            p_api_version           => l_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_lap_id                => l_lap_id
           ,p_lap_status            => l_lap_status
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_APP_PVT.SET_LEASE_APP_STATUS'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

   	    IF ( l_return_status = FND_API.G_RET_STS_ERROR )
        THEN
          resultout := 'ERROR:' || x_msg_data;
          RETURN;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
        THEN
          resultout := 'ERROR:' || x_msg_data;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

         -- Added for bug 7375141 - start
         l_exp_date := OKL_LEASE_APP_PVT.get_approval_exp_date(l_lap_id);
         if (l_exp_date is not null and l_exp_date <> OKL_API.G_MISS_DATE) then
              IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
             THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_PROCEDURE
          ,L_MODULE
          ,'begin debug call POPULATE_LEASE_APP');
     END IF;

     OKL_LEASE_APP_PVT.POPULATE_LEASE_APP(
         p_api_version           => l_api_version
        ,p_init_msg_list         => OKL_API.G_FALSE
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,p_lap_id                => l_lap_id
        ,x_lapv_rec              => x_lapv_rec
        ,x_lsqv_rec              => x_lsqv_rec);

     IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
     THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_PROCEDURE
          ,L_MODULE
          ,'end debug call POPULATE_LEASE_APP');
     END IF;

     -- write to log
     IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_STATEMENT
          ,L_MODULE || ' Result of POPULATE_LEASE_APP'
          ,'l_return_status ' || l_return_status);
     END IF; -- end of statement level debug
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )
         THEN
           resultout := 'ERROR:' || x_msg_data;
           RETURN;
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
         THEN
           resultout := 'ERROR:' || x_msg_data;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     l_lapv_rec := x_lapv_rec;
     l_lapv_rec.valid_to:= l_exp_date;

     IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
     THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_PROCEDURE
          ,L_MODULE
          ,'begin debug call OKL_LAP_PVT.UPDATE_ROW');
     END IF;

     OKL_LAP_PVT.UPDATE_ROW(
         p_api_version           => l_api_version
        ,p_init_msg_list         => OKL_API.G_FALSE
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,p_lapv_rec              => l_lapv_rec
        ,x_lapv_rec              => x_lapv_rec);

     IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
     THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_PROCEDURE
          ,L_MODULE
          ,'end debug call OKL_LAP_PVT.UPDATE_ROW');
     END IF;

     -- write to log
     IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(
           FND_LOG.LEVEL_STATEMENT
          ,L_MODULE || ' Result of OKL_LAP_PVT.UPDATE_ROW'
          ,'l_return_status ' || l_return_status);
     END IF; -- end of statement level debug
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )
         THEN
           resultout := 'ERROR:' || x_msg_data;
           RETURN;
         ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
         THEN
           resultout := 'ERROR:' || x_msg_data;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
   End if;
       -- Added for bug 7375141 - End

        --Bug 4872271 PAGARG Call the API which will check if there is any Parent
        --to this Lease App and in status Appeal/Resubmit in Progress. If yes
        --then restore the status of parent to original status
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'begin debug call OKL_LEASE_APP_PVT.REVERT_TO_ORIG_STATUS');
        END IF;

        OKL_LEASE_APP_PVT.REVERT_TO_ORIG_STATUS(
            p_api_version           => l_api_version
           ,p_init_msg_list         => OKL_API.G_FALSE
           ,p_lap_id                => l_lap_id
           ,x_return_status         => l_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_PROCEDURE
             ,L_MODULE
             ,'end debug call OKL_LEASE_APP_PVT.REVERT_TO_ORIG_STATUS');
        END IF;

        -- write to log
        IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(
              FND_LOG.LEVEL_STATEMENT
             ,L_MODULE || ' Result of OKL_LEASE_APP_PVT.REVERT_TO_ORIG_STATUS'
             ,'l_return_status ' || l_return_status);
        END IF; -- end of statement level debug

   	    IF ( l_return_status = FND_API.G_RET_STS_ERROR )
        THEN
          resultout := 'ERROR:' || x_msg_data;
          RETURN;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
        THEN
          resultout := 'ERROR:' || x_msg_data;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;-- For l_lap_status is not null condition
      -- Bug#4741121 - viselvar  - Modified - Start
      -- raise the business event passing the lease application id added to the parameter list

      wf_event.addparametertolist('LAPP_ID'
                              ,l_lap_id
                              ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            l_api_version
                            ,p_init_msg_list =>            OKL_API.G_FALSE
                            ,x_return_status =>            l_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);
      -- Bug#4741121 - viselvar  - Modified - End

      resultout := 'COMPLETE:YES';
      RETURN;
    END IF;
    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL')
    THEN
      resultout := 'COMPLETE:YES';
      RETURN;
    END IF;
    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT')
    THEN
      resultout := 'COMPLETE:NO';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      --Credit Request cursor
      IF credit_req_csr%ISOPEN
      THEN
        CLOSE credit_req_csr;
      END IF;
      --Credit Request status cursor
      IF credit_req_sts_csr%ISOPEN
      THEN
        CLOSE credit_req_sts_csr;
      END IF;
      wf_core.context(
         G_PKG_NAME
        ,l_api_name
        ,itemtype
        ,itemkey
        ,to_char(actid)
        ,funcmode);
	  RAISE;
  END UPDATE_STATUS ;

  ---------------------------------------------------------------------------
  -- create_credit_app
  ---------------------------------------------------------------------------
  procedure create_credit_app ( 		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	)IS

             l_quote_id  NUMBER;
             l_requestor_id NUMBER;
             l_capital_amount NUMBER;

             ls_request_num  VARCHAR2(80) ;
             l_seq     NUMBER ;

  l_crqv_rec_type  okl_credit_request_pub.crqv_rec_type ;
  x_crqv_rec_type  okl_credit_request_pub.crqv_rec_type ;
  x_msg_data    VARCHAR2(2000);
  x_msg_count   NUMBER := 0 ;
  l_api_version NUMBER := 1.0 ;
  x_return_status  VARCHAR2(1) ;
  l_quote_number OKC_K_HEADERS_B.CONTRACT_number%TYPE;

       CURSOR contract_number_csr(p_contract_id NUMBER ) IS
     SELECT SUM(KLE.CAPITAL_AMOUNT) ,chr.contract_number
      FROM OKC_K_LINES_B CLEB,OKL_K_LINES KLE, OKC_K_HEADERS_V CHR
     WHERE chr.scs_code = 'QUOTE'
     AND chr.ID = l_quote_id
     AND  CLEB.ID = KLE.ID
     AND   CLEB.DNZ_CHR_ID = chr.ID
     AND CLEB.CLE_ID IS NULL
     GROUP  BY chr.ID , chr.contract_number;

    begin
   	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then


 --    1. Get values (quote_id , requestor_id) from workflow
  l_quote_id := TO_NUMBER(	  wf_engine.GetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'QUOTE_ID'));

 l_requestor_id := TO_NUMBER(  wf_engine.GetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'REQUESTED_ID'));

    BEGIN
 --  2. Get Capital  amount
      OPEN  contract_number_csr(l_quote_id);
     FETCH contract_number_csr INTO l_capital_amount, l_quote_number ;
     IF(contract_number_csr%NOTFOUND) THEN
        resultout := 'ERROR: No Capital Amount';
       CLOSE contract_number_csr ;
       RETURN ;
     END IF ;
     CLOSE contract_number_csr ;
      EXCEPTION
    WHEN OTHERS  THEN
        resultout := 'ERROR: Not able to get' ;
        RETURN;
    END ;

 -- 3. Get Request Number
  select okl_wf_item_s.nextval INTO l_seq FROM DUAL ;
   ls_request_num := l_quote_number ||l_seq ;

 -- 4. CREATE credit app request
     l_crqv_rec_type.QUOTE_ID := l_quote_id ;
     l_crqv_rec_type.CREDIT_REQ_NUMBER := ls_request_num ;
     l_crqv_rec_type.CREDIT_REQ_ID := NULL ;
     l_crqv_rec_type.CREDIT_AMOUNT := l_capital_amount ;
     l_crqv_rec_type.REQUESTED_BY :=l_requestor_id ;
    l_crqv_rec_type.REQUESTED_DATE := SYSDATE ;
   -- APPROVED_BY
    -- APPROVED_DATE
     l_crqv_rec_type.STATUS := 'ENTERED';
      l_crqv_rec_type.CURRENCY_CODE :=  'USD';

  okl_credit_request_pub.insert_credit_request(
     p_api_version                  => l_api_version
    ,p_init_msg_list                => 'T'
    ,x_return_status                =>x_return_status
    ,x_msg_count                    => x_msg_count
    ,x_msg_data                     =>x_msg_data
    ,p_crqv_rec                     =>l_crqv_rec_type
    ,x_crqv_rec                     => x_crqv_rec_type);

   	IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
            resultout := 'COMPLETE:N';
    		return;
	ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            resultout := 'COMPLETE:NO';
        --    		return;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- 5. set approver role, REQUEST STATUS , CREDIT_AMOUNT , rEQUEST NUMBER
 	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'APPROVER_ID',
			avalue	=> 'ADMIN');

       	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'CREDIT_REQ_NUM',
			avalue	=> ls_request_num);

         	  wf_engine.SetItemAttrText (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'REQUEST_STATUS',
			avalue	=> 'ENTERED');

         	  wf_engine.SetItemAttrNumber (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'CREDIT_AMOUNT',
			avalue	=> l_capital_amount);

           wf_engine.SetItemAttrNumber (
			itemtype 	=> itemtype,
	      	itemkey	=> itemkey,
  	      	aname 	=> 'ID',
            avalue	=> x_crqv_rec_type.ID);

 -- 6. set return code YES
	  resultout := 'COMPLETE:Y';
  	  return;
	--
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
	--
	-- TIMEOUT mode
	--
	if (funcmode = 'TIMEOUT') then
		--
    		resultout := 'COMPLETE:N';
    		return;
		--
	end if;
exception
	when others then
	  wf_core.context('OKL_SO_CREDIT_APP_WF',
		'CREATE_CREDIT_APP',
      itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;

  end create_credit_app;

  -- Ensures an end date has been specifed for credit contract creation
  -- by the user.  If no date is entered the notification is resent.
  --
  procedure credit_k_end_dated(
            itemtype    in         varchar2,
				itemkey  	in         varchar2,
				actid		   in         number,
				funcmode	   in         varchar2,
				resultout	out nocopy varchar2	) is
  begin
	--
	-- RUN mode - normal process execution
	--
	if (funcmode = 'RUN') then
        if (wf_engine.GetItemAttrText(itemtype,itemkey,'TLOC_END_DATE') is NULL) then
	      resultout := 'COMPLETE:F';
	  else
       -- check that the date is greater than the request date
       if (wf_engine.GetItemAttrText(itemtype,itemkey,'TLOC_END_DATE') < sysdate) then
	      resultout := 'COMPLETE:F';
  	    else
	      resultout := 'COMPLETE:T';
       end if;
	  end if;
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
  exception
	when others then
	  wf_core.context('OKL_SO_CREDIT_APP_WF',
		'CREDIT_K_END_DATED',
		itemtype,
		itemkey,
		to_char(actid),
		funcmode);
	  raise;
  end credit_k_end_dated;

    procedure send_message ( 		itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout out nocopy varchar2	)IS
    begin
    NULL;
    end send_message;

END OKL_SO_CREDIT_APP_WF;

/
