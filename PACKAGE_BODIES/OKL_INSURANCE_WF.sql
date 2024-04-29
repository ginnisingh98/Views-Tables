--------------------------------------------------------
--  DDL for Package Body OKL_INSURANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INSURANCE_WF" AS
/* $Header: OKLRIWFB.pls 120.4 2007/11/19 17:00:29 zrehman noship $ */


-- Start of comments
--
-- Procedure Name  : load_mess
-- Description     : Private procedure to load messages into attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  procedure load_mess(  itemtype  in varchar2,
        itemkey    in varchar2) is
  i integer;
  j integer;
 begin
  j := NVL(FND_MSG_PUB.Count_Msg,0);
  if (j=0) then return; end if;
  if (j>9) then j:=9; end if;
  FOR I IN 1..J LOOP
    wf_engine.SetItemAttrText (itemtype   => itemtype,
              itemkey    => itemkey,
                aname   => 'MESSAGE'||i,
                    avalue  => FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
  END LOOP;
end;


--------------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  procedure Initialize (     itemtype  in varchar2,
        itemkey    in varchar2,
        actid    in number,
        funcmode  in varchar2,
        resultout  out NOCOPY varchar2  )IS


               l_owner_grp_id               NUMBER ;
               l_owner_id                   NUMBER;
               l_task_template_grp_id       NUMBER;
               l_task_template_grp_name     VARCHAR2(100);


    begin

     --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then
     l_owner_grp_id  := 1 ;

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
exception
  when others then
    wf_core.context('OKC_INSURANCE_WF',
    'Initialize',itemtype,
    itemkey,
    to_char(actid),
    funcmode);
    raise;

   end Initialize;


PROCEDURE Check_Insurance (     itemtype  in varchar2,
        itemkey    in varchar2,
        actid    in number,
        funcmode  in varchar2,
        resultout  out NOCOPY varchar2  )
  IS
  -- gboomina Bug - 5128517 - changing the cursor definition - Start
    CURSOR okc_k_status_csr(p_khr_id  IN NUMBER) IS
      SELECT STE_CODE
      FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
      WHERE  KHR.ID =  p_khr_id
      AND KHR.STS_CODE = OST.CODE;
  -- gboomina Bug - 5128517 - End

    CURSOR okl_k_lease_policy_csr(p_khr_id  IN NUMBER) IS
      SELECT 'x'
      FROM  OKL_INS_POLICIES_B IPYB
      WHERE IPYB.IPY_TYPE <> 'OPTIONAL_POLICY' AND
            SYSDATE BETWEEN IPYB.DATE_FROM AND IPYB.DATE_TO
        AND IPYB.KHR_ID = p_khr_id ;


    l_dummy   varchar(1) ;
    contract_id    NUMBER ;
    l_contarct_status VARCHAR2(30);
    G_NO_DATA_FOUND EXCEPTION   ;
  begin

    if (funcmode = 'RUN') then
       -- gboomina - Bug - 5128517 - Start
       -- Changing GetItemAttrNumber api to GetItemAttrText
      contract_id := wf_engine.GetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CONTRACT_ID');
       -- gboomina - Bug - 5128517 - End

      --1. Need to check Contract Status return 'INVALID'

      -------------------------------------------------------------------------
      ---- Check for Status of Contract
      ---------------------------------------------------------------------------

      OPEN  okc_k_status_csr(contract_id);
      FETCH okc_k_status_csr INTO l_contarct_status ;
      IF(okc_k_status_csr%NOTFOUND) THEN
        resultout := 'ERROR: No Contarct Status' ;
        CLOSE okc_k_status_csr ;
        RETURN ;
      END IF ;
      CLOSE okc_k_status_csr ;


      IF (l_contarct_status <> 'ACTIVE' ) THEN
        resultout := 'COMPLETE:INVALID';
        RETURN ;
      END IF ;

      --2. Need to check for lease insurance or third party with date range.

      OPEN  okl_k_lease_policy_csr(contract_id);
      FETCH okl_k_lease_policy_csr INTO l_dummy ;
      IF(okl_k_lease_policy_csr%NOTFOUND) THEN
        resultout := 'COMPLETE:NO';
        CLOSE okl_k_lease_policy_csr ;
        RETURN ;

      END IF ;
      resultout := 'COMPLETE:YES';
      CLOSE okl_k_lease_policy_csr ;
      RETURN ;

    end if;
    --
    -- CANCEL mode
    --
    if (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:NO';
    end if;
    --
    -- TIMEOUT mode
    --
    if (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:NO';
      return ;
    end if;
exception
  when others then
    wf_core.context('OKC_INSURANCE_WF',
    'Check_Insurance',
    itemtype,
    itemkey,
    to_char(actid),
    funcmode);
    raise;

    end Check_Insurance;





PROCEDURE Create_Third_Party_Task(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out NOCOPY varchar2  )
IS

    l_owner_grp_type_code  jtf_tasks_b.owner_type_code%TYPE ;
    l_owner_id              jtf_tasks_b.owner_id%TYPE;
    l_task_template_grp_id       NUMBER;
    l_task_template_grp_name     VARCHAR2(100);
    x_return_status    VARCHAR(1);
    x_msg_count       NUMBER;
    x_msg_data       VARCHAR2(2000);
    x_task_details_tbl  JTF_TASKS_PUB.task_details_tbl ;
    l_api_version     NUMBER :=1.0 ;
    contract_id    NUMBER ;
    l_source_object_id              NUMBER;
    l_source_object_name        jtf_tasks_b.source_object_name%TYPE;
    l_party_id   NUMBER := NULL;
    l_add_id     NUMBER := NULL;
    l_acct_id    NUMBER := NULL;
    l_org_id     NUMBER := NULL;
    G_NO_DATA_FOUND EXCEPTION   ;

   -- Changed by zrehman for Bug#5396328 - Workflow erroring out start
    CURSOR party_info_csr (p_contract_id NUMBER ) IS
      SELECT hze.party_site_id address,
             hdr.cust_acct_id acctid,
             rle.OBJECT1_ID1 partyid
      FROM   okc_k_headers_b hdr,
             okc_k_party_roles_b rle,
             hz_cust_acct_sites_all hze,
             hz_cust_site_uses_all hz
      WHERE  rle.rle_code = 'LESSEE'
      and    rle.dnz_chr_id =  hdr.id
      and    hdr.bill_to_site_use_id = hz.SITE_USE_ID
      and    hze.cust_acct_site_id = hz.cust_acct_site_id
      and    hdr.id = contract_id;

    CURSOR contract_number_csr(p_contract_id NUMBER ) IS
      SELECT CONTRACT_NUMBER
            ,ORG_ID
      FROM OKC_K_HEADERS_ALL_B
      WHERE ID  = p_contract_id ;

    -- gboomina Bug - 5128517 - Start
    -- Cursor to get Template Group Id, Owner Type Code and Owner Id
    CURSOR task_setup_info_csr(p_org_id NUMBER)
    IS
      SELECT TASK_TEMPLATE_GROUP_ID,
             OWNER_TYPE_CODE,
             OWNER_ID
      FROM OKL_SYSTEM_PARAMS_ALL
      WHERE ORG_ID = p_org_id;
   -- Changed by zrehman for Bug#5396328 - Workflow erroring out end


    -- Cursor to get Template Group Name
    CURSOR task_temp_grp_name_csr (temp_grp_id NUMBER)
    IS
      SELECT T.TEMPLATE_GROUP_NAME
      FROM JTF_TASK_TEMP_GROUPS_VL T,
           JTF_OBJECTS_VL OB
      WHERE T.SOURCE_OBJECT_TYPE_CODE = OB.OBJECT_CODE
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(T.START_DATE_ACTIVE, SYSDATE))
      AND TRUNC(NVL(T.END_DATE_ACTIVE, SYSDATE))
      AND T.TASK_TEMPLATE_GROUP_ID = temp_grp_id;

begin

  if (funcmode = 'RUN') then
    -- Get Contract ID
    -- gboomina - Bug - 5128517 - Start
    -- Changing GetItemAttrNumber to GetItemAttrText
    contract_id := wf_engine.GetItemAttrText(
    itemtype   => itemtype,
    itemkey  => itemkey,
    aname    => 'CONTRACT_ID');
    -- gboomina - Bug - 5128517 - End


    BEGIN
       OPEN  contract_number_csr(contract_id);
       FETCH contract_number_csr INTO l_source_object_name, l_org_id ;
       IF(contract_number_csr%NOTFOUND) THEN
         resultout := 'ERROR: No Contract Number';
         CLOSE contract_number_csr ;
         RETURN ;
       END IF ;
       CLOSE contract_number_csr ;
    EXCEPTION
    WHEN OTHERS  THEN
        resultout := 'ERROR: No Contract Number' ;
       RETURN;
    END ;


    -- gboomina Bug 5128517 - Start
    OPEN task_setup_info_csr(l_org_id);
      FETCH task_setup_info_csr INTO l_task_template_grp_id, l_owner_grp_type_code, l_owner_id;
      IF(task_setup_info_csr%NOTFOUND) THEN
        fnd_msg_pub.initialize;
        okl_api.set_message('OKL','OKL_ST_INS_TASK_NOT_SETUP');
        resultout := 'ERROR: OKL_ST_INS_TASK_NOT_SETUP';
        CLOSE task_setup_info_csr ;
        RETURN ;
      END IF ;
    CLOSE task_setup_info_csr ;

    IF ((l_owner_grp_type_code IS NULL ) OR (l_owner_grp_type_code = OKC_API.G_MISS_CHAR )) THEN
      fnd_msg_pub.initialize;
      okl_api.set_message('OKL','OKL_ST_INS_OWNR_TYP_NOT_SETUP');
      resultout := 'ERROR: OKL_ST_INS_OWNR_TYP_NOT_SETUP';
      RETURN ;
    END IF ;
    IF ((l_owner_id IS NULL ) OR (l_owner_id = OKC_API.G_MISS_NUM )) THEN
      fnd_msg_pub.initialize;
      okl_api.set_message('OKL','OKL_ST_INS_OWNR_NOT_SETUP');
      resultout := 'ERROR: OKL_ST_INS_OWNR_NOT_SETUP';
      RETURN ;
    END IF ;
    IF ((l_task_template_grp_id IS NULL ) OR (l_task_template_grp_id = OKC_API.G_MISS_NUM )) THEN
      fnd_msg_pub.initialize;
      okl_api.set_message('OKL','OKL_ST_INS_TEMP_GRP_NOT_SETUP');
      resultout := 'ERROR: OKL_ST_INS_TEMP_GRP_NOT_SETUP';
      RETURN ;
    END IF ;

    BEGIN
     OPEN  task_temp_grp_name_csr(l_task_template_grp_id);
     FETCH task_temp_grp_name_csr INTO l_task_template_grp_name ;
     IF(task_temp_grp_name_csr%NOTFOUND) THEN
        resultout := 'ERROR: No Task Template Group';
       CLOSE task_temp_grp_name_csr ;
       RETURN ;
     END IF ;
     CLOSE task_temp_grp_name_csr ;
      EXCEPTION
    WHEN OTHERS  THEN
        resultout := 'ERROR:' ;
        RETURN;
    END ;



    BEGIN
        OPEN  party_info_csr(contract_id);
         FETCH party_info_csr INTO l_add_id ,l_acct_id, l_party_id ;
         IF(party_info_csr%NOTFOUND) THEN
           fnd_msg_pub.initialize;
           okl_api.set_message('OKL','OKL_ST_INS_NO_PARTY_INFO');
           resultout := 'ERROR: OKL_ST_INS_NO_PARTY_INFO';
           CLOSE party_info_csr ;
           RETURN ;
         END IF ;
        CLOSE party_info_csr ;
        EXCEPTION
        WHEN OTHERS  THEN
          resultout := 'ERROR:' ;
          RETURN;
    END ;


   l_source_object_id := contract_id ;

    BEGIN
      JTF_TASKS_PUB.create_task_from_template (
        p_api_version          =>          l_api_version
       ,p_commit                     => null
        ,p_task_template_group_id     => l_task_template_grp_id,
        p_task_template_group_name   =>  l_task_template_grp_NAME,
        p_owner_type_code            => l_owner_grp_type_code,
        p_owner_id                   => l_owner_id,
        p_source_object_id           => l_source_object_id,
        p_source_object_name         => l_source_object_name
       ,x_return_status =>    x_return_status
       ,x_msg_count   =>        x_msg_count
       ,x_msg_data     =>        x_msg_data
       ,x_task_details_tbl   =>  x_task_details_tbl
       ,p_cust_account_id            => l_acct_id
       ,p_customer_id                => l_party_id
       ,p_address_id                 =>l_add_id
       );
    END ;

    if (x_return_status = OKC_API.G_RET_STS_SUCCESS) then
      resultout := 'COMPLETE:T';
      RETURN  ;
    else
      resultout := 'ERROR:' || FND_MSG_PUB.Get(x_msg_count,p_encoded =>FND_API.G_FALSE );
      RETURN ;
    end if;

  end if;
  --
    -- CANCEL mode
  --
    if (funcmode = 'CANCEL') then
    --
        resultout := 'COMPLETE:F';
        return ;
    --
    end if;
  --
  -- TIMEOUT mode
  --
  if (funcmode = 'TIMEOUT') then
    --
        resultout := 'COMPLETE:F';
        return ;
    --
  end if;

exception
  when others then
    wf_core.context('OKC_INSURANCE_WF',
    'Create_Third_Party_Task',
    itemtype,
    itemkey,
    to_char(actid),
    funcmode);
    raise;
   end Create_Third_Party_Task;





    procedure send_message (     itemtype  in varchar2,
        itemkey    in varchar2,
        actid    in number,
        funcmode  in varchar2,
        resultout  out NOCOPY varchar2  )IS
    begin
    NULL;
    end send_message;
END OKL_INSURANCE_WF;

/
