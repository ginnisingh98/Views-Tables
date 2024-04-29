--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RETURN_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RETURN_WF" AS
/* $Header: OKLRRWFB.pls 120.15.12010000.2 2009/11/09 07:15:34 rkuttiya ship $ */

  -- Start of comments
  --
  -- Procedure Name : check_repo_request
  -- Description    : validate repossession request from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_repo_request(  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
 l_knt   NUMBER;

    -- cursor to check request is valid
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT count(*)
 FROM   OKL_ASSET_RETURNS_V
 WHERE  ID= c_art_id;

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_knt;
  CLOSE okl_check_req_csr;

  IF l_knt = 0 THEN
   resultout := 'COMPLETE:INVALID_RETURN';
  ELSE
   resultout := 'COMPLETE:VALID_RETURN';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_repo_request', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_repo_request;

  -- Start of comments
  --
  -- Procedure Name : check_remk_assign
  -- Description    : validate remarketer assignement from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_remk_assign (  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
 l_knt   NUMBER;

    -- cursor to check request is valid
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT count(*)
 FROM   OKL_ASSET_RETURNS_V OARV,
           OKL_AM_REMARKET_TEAMS_UV ORTU
 WHERE  OARV.ID= c_art_id
    AND    OARV.RMR_ID = ORTU.ORIG_SYSTEM_ID;

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_knt;
  CLOSE okl_check_req_csr;

  IF l_knt = 0 THEN
   resultout := 'COMPLETE:REMARKETER_NOT_ASSIGNED';
  ELSE
   resultout := 'COMPLETE:REMARKETER_ASSIGNED';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_remk_assign', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_remk_assign;

  -- Start of comments
  --
  -- Procedure Name : populate_notification_attribs
  -- Description    : populate collections agent notification attributes from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE populate_notification_attribs(itemtype IN VARCHAR2,
                                    itemkey  IN VARCHAR2,
                         actid    IN NUMBER,
                           funcmode IN VARCHAR2,
                           p_art_id IN NUMBER) AS

    l_art_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DISPLAY_NAME%TYPE;
    -- cursor to populate notification attributes
    --Bug # 6174484 ssdeshpa Fixed for SQL Performance Start
 CURSOR okl_asset_return_csr(c_art_id NUMBER)
 IS
    /* SELECT OAR.LAST_UPDATED_BY, AD.CHR_ID CHR_ID,
           AD.ITEM_DESCRIPTION ASSET_DESCRIPTION,
           AD.CONTRACT_NUMBER CONTRACT_NUMBER, AD.NAME ASSET_NUMBER,
           AD.SERIAL_NUMBER SERIAL_NUMBER, AD.MODEL_NUMBER MODEL_NUMBER,
           OAR.DATE_REPOSSESSION_ACTUAL DATE_RETURNED, AD.ID KLE_ID,
           OAR.COMMENTS COMMENTS
     FROM
     OKL_AM_ASSET_DETAILS_UV AD,
     OKL_ASSET_RETURNS_V OAR
     WHERE
     AD.ID = OAR.KLE_ID
     AND oar.id = c_art_id; */
     SELECT
       OAR.LAST_UPDATED_BY ,
       CLEV.CHR_ID CHR_ID ,
       CLEV.ITEM_DESCRIPTION ASSET_DESCRIPTION ,
       OKHV.CONTRACT_NUMBER CONTRACT_NUMBER ,
       CLEV.NAME ASSET_NUMBER ,
       OALV.SERIAL_NUMBER SERIAL_NUMBER ,
       OALV.MODEL_NUMBER MODEL_NUMBER ,
       OAR.DATE_REPOSSESSION_ACTUAL DATE_RETURNED ,
       CLEV.ID KLE_ID ,
       OAR.RMR_ID RMR_ID,
       OAR.COMMENTS COMMENTS
     FROM OKC_K_LINES_V CLEV
         ,OKX_ASSET_LINES_V OALV
         ,OKC_K_HEADERS_ALL_B OKHV ,
         OKL_ASSET_RETURNS_V OAR
     WHERE CLEV.ID = OAR.KLE_ID
     AND CLEV.ID = OALV.PARENT_LINE_ID(+)
     AND CLEV.CHR_ID = OKHV.ID
     AND CLEV.STS_CODE <> 'ABANDONED'
     AND OAR.ID = c_art_id;

    --Bug # 6174484 ssdeshpa Fixed for SQL Performance End
    l_asset_return    okl_asset_return_csr%rowtype;

  BEGIN
    l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

 OPEN  okl_asset_return_csr(l_art_id);
 FETCH okl_asset_return_csr INTO l_asset_return;
 CLOSE okl_asset_return_csr;

    okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_asset_return.last_updated_by
                              , x_name     => l_user
                           , x_description => l_name);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'KHR_ID',
                              avalue  => to_char(l_asset_return.CHR_ID));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => l_asset_return.CONTRACT_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_NUMBER',
                              avalue  => l_asset_return.ASSET_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'DATE_RETURNED',
                              avalue  => to_char(l_asset_return.DATE_RETURNED));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'KLE_ID',
                              avalue  => to_char(l_asset_return.KLE_ID));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                              avalue  => to_char(l_asset_return.last_updated_by));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_DESCRIPTION',
                              avalue  => l_asset_return.asset_description);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'COMMENTS',
                              avalue  => l_asset_return.comments);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'SERIAL_NUMBER',
                              avalue  => l_asset_return.serial_number);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MODEL_NUMBER',
                              avalue  => l_asset_return.model_number);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'DISPLAY_NAME',
                              avalue  => l_name);
  EXCEPTION
     WHEN OTHERS THEN
        IF okl_asset_return_csr%ISOPEN THEN
           CLOSE okl_asset_return_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'populate_notification_attribs', itemtype, itemkey, actid, funcmode);
        RAISE;
  END populate_notification_attribs;

  -- Start of comments
  --
  -- Procedure Name : pop_repo_notify_att
  -- Description    : populate repossession notification attributes from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE POP_REPO_NOTIFY_ATT( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_art_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DESCRIPTION%TYPE;

    -- cursor to populate notification attributes
 CURSOR okl_asset_return_csr(c_art_id NUMBER)
 IS
    SELECT OAR.LAST_UPDATED_BY, KLE.CHR_ID CHR_ID,
           OKC.CONTRACT_NUMBER CONTRACT_NUMBER, KLE.NAME ASSET_NUMBER,
           OAR.DATE_RETURNED DATE_RETURNED, KLE.ID KLE_ID, OAR.RNA_ID AGENT_ID
     FROM OKL_K_LINES_FULL_V KLE,
     OKC_K_HEADERS_B OKC,
     OKL_ASSET_RETURNS_B OAR
     WHERE OKC.ID = KLE.CHR_ID
     AND OAR.KLE_ID = KLE.ID
     AND oar.id = c_art_id
     AND    ART1_CODE ='REPOS_REQUEST';

    l_asset_return    okl_asset_return_csr%rowtype;

    -- cursor to find valid external notification user
 CURSOR okl_vendor_csr(c_agent_id NUMBER)
 IS
 SELECT *
 FROM   OKX_VENDORS_V
 WHERE  ID1  = c_agent_id;

    l_vendor   OKX_VENDORS_V%rowtype;

   --12/20/06 rkuttiya added for XMLP Project

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;

  --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);


  BEGIN
    l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

 OPEN  okl_asset_return_csr(l_art_id);
 FETCH okl_asset_return_csr INTO l_asset_return;
 CLOSE okl_asset_return_csr;

 OPEN  okl_vendor_csr(l_asset_return.AGENT_ID);
 FETCH okl_vendor_csr INTO l_vendor;
 CLOSE okl_vendor_csr;

    okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_asset_return.last_updated_by
                              , x_name     => l_user
                           , x_description => l_name);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => l_asset_return.CONTRACT_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_NUMBER',
                              avalue  => l_asset_return.ASSET_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'DATE_RETURNED',
                              avalue  => to_char(l_asset_return.DATE_RETURNED));

    wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                              avalue  => to_char(l_asset_return.LAST_UPDATED_BY));

    -- Item Attributes for Fulfillment

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'PROCESS_CODE',
                              avalue  => 'AMNRA');

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRANSACTION_ID',
                              avalue  => l_art_id);
--12/20/06 rkuttiya changed recipient type to VENDOR, for XMLP Project
    /*wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_TYPE',
                              avalue  => 'V'); */

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RECIPIENT_TYPE',
                                    avalue  => 'VENDOR');

    wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_ID',
                              avalue  => to_char(l_asset_return.AGENT_ID));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_DESCRIPTION',
                              avalue  => l_vendor.NAME);

--12/18/06 rkuttiya modified for XMLP Project
--set the From Address and TO Address
        OPEN c_recipient(l_asset_return.agent_id);
        FETCH c_recipient INTO l_to_email;
        CLOSE c_recipient;

         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'EMAIL_ADDRESS',
                                     avalue  =>  l_to_email);

        OPEN c_agent_csr(l_asset_return.last_updated_by);
        FETCH c_agent_csr into l_from_email;
        CLOSE c_agent_csr;

          wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'FROM_ADDRESS',
                                     avalue  =>  l_from_email);


           --18-Dec-06 rkuttiya added for XMLP Project
           --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_ART_ID';
          l_xmp_rec.param_value := l_art_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );



               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                        resultout := 'COMPLETE:SUCCESS';
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;


  EXCEPTION
     WHEN OTHERS THEN
        IF okl_asset_return_csr%ISOPEN THEN
           CLOSE okl_asset_return_csr;
        END IF;

        IF okl_vendor_csr%ISOPEN THEN
           CLOSE okl_vendor_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_REPO_NOTIFY_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END POP_REPO_NOTIFY_ATT;

  -- Start of comments
  --
  -- Procedure Name : pop_remk_notify_att
  -- Description    : populate remarketer notification attributes from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE POP_REMK_NOTIFY_ATT( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_art_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

 -- cursor to populate notification attributes
 --Added by cdubey for bug 5253787
 --Made changes to split the original cursor okl_asset_return_csr into two cursors for performance issue


 CURSOR okl_asset_return_csr(c_art_id NUMBER)
 IS
        SELECT OAR.LAST_UPDATED_BY,
              OAR.DATE_REPOSSESSION_ACTUAL DATE_RETURNED,
              OAR.RMR_ID RMR_ID,
              OAR.COMMENTS COMMENTS,
              OAR.KLE_ID KLE_ID
       FROM  OKL_ASSET_RETURNS_V OAR
       WHERE OAR.ID = c_art_id;

       CURSOR okl_asset_details_csr(c_kle_id  NUMBER)
       IS
       SELECT AD.CHR_ID CHR_ID,

           AD.ITEM_DESCRIPTION ASSET_DESCRIPTION,
           AD.CONTRACT_NUMBER CONTRACT_NUMBER, AD.NAME ASSET_NUMBER,
           AD.SERIAL_NUMBER SERIAL_NUMBER, AD.MODEL_NUMBER MODEL_NUMBER,
           AD.ID KLE_ID
    FROM  OKL_AM_ASSET_DETAILS_UV AD
    WHERE AD.ID = c_kle_id;
    l_asset_detail    okl_asset_details_csr%rowtype;
    --end cdubey for bug 5253787


    l_asset_return    okl_asset_return_csr%rowtype;

    -- cursor to find valid notification user
    CURSOR wf_users_csr(c_team_id NUMBER)
    IS
    SELECT count(*)
    FROM jtf_rs_teams_vl t,
         jtf_rs_role_relations_vl jtfr,
         jtf_rs_Resource_extns a,
         jtf_rs_Team_Members b,
         jtf_rs_Groups_b d,
         jtf_rs_resource_extns re,
         wf_users wu
    WHERE  t.team_id = c_team_id
    AND nvl (t.start_date_active, sysdate - 1) <= sysdate
    AND nvl (t.end_date_active, sysdate + 1) >= sysdate
    AND jtfr.role_code = 'REMARKETER'
    AND role_resource_type = 'RS_TEAM'
    AND jtfr.role_resource_id = t.team_id
    AND t.team_id = b.Team_Id
    AND (DECODE(b.Resource_Type,'INDIVIDUAL',a.Resource_Number,
                              d.Group_Number)) = re.resource_number
    AND b.Team_Resource_Id = a.Resource_Id (+)
    AND b.Team_Resource_Id = d.Group_Id (+)
    AND re.source_id = wu.orig_system_id
    AND re.user_name = wu.name; -- mdokal : Bug 3562321

  BEGIN

    l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

 OPEN  okl_asset_return_csr(l_art_id);
 FETCH okl_asset_return_csr INTO l_asset_return;
 CLOSE okl_asset_return_csr;

       --Added by cdubey for bug 5253787
       OPEN  okl_asset_details_csr(l_asset_return.KLE_ID);
       FETCH okl_asset_details_csr INTO l_asset_detail;
       CLOSE okl_asset_details_csr;
       --end cdubey


 OPEN  wf_users_csr(l_asset_return.RMR_ID);
 FETCH wf_users_csr INTO l_user;
 CLOSE wf_users_csr;

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TOTAL_RECIPIENTS',
                              avalue  => l_user);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CURRENT_RECIPIENT',
                              avalue  => l_user+1);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => l_asset_detail.CONTRACT_NUMBER);  --bug 5253787

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_NUMBER',
                              avalue  => l_asset_detail.ASSET_NUMBER);  --bug 5253787

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'DATE_RETURNED',
                              avalue  => to_char(l_asset_return.DATE_RETURNED));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                              avalue  => to_char(l_asset_return.LAST_UPDATED_BY));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REMARKETER_ID',
                              avalue  => to_char(l_asset_return.RMR_ID));

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_DESCRIPTION',
                              avalue  => l_asset_detail.asset_description);  --bug 5253787

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MODEL_NUMBER',
                              avalue  => l_asset_detail.model_number);  --bug 5253787

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'SERIAL_NUMBER',
                               avalue  => l_asset_detail.serial_number);  --bug 5253787

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_asset_return_csr%ISOPEN THEN
           CLOSE okl_asset_return_csr;
        END IF;

  --Added by cdubey for bug 5253787
           IF okl_asset_details_csr%ISOPEN THEN
              CLOSE okl_asset_details_csr;
           END IF;
          --end cdubey


        IF wf_users_csr%ISOPEN THEN
           CLOSE wf_users_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_REMK_NOTIFY_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END POP_REMK_NOTIFY_ATT;

  -- Start of comments
  --
  -- Procedure Name : notify_remk_user
  -- Description    : populate remarketer notification attributes from WF
  --                  This procedure is called recursively until all team
  --                  members have been notified.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE NOTIFY_REMK_USER( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_rmr_id      NUMBER;
    l_total_rec      NUMBER;
    l_current_rec       NUMBER  := 0;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DISPLAY_NAME%TYPE;
    l_current_user      WF_USERS.NAME%TYPE;

    -- cursor to populate notification attributes
    CURSOR wf_users_csr(c_team_id       NUMBER,
                        c_current_user  NUMBER,
                        c_name          VARCHAR)
    IS
       SELECT wu.name, wu.display_name
      FROM jtf_rs_teams_vl t,
           jtf_rs_role_relations_vl jtfr,
           jtf_rs_team_members_vl tm,
           jtf_rs_resource_extns_vl re,
           wf_users WU
     WHERE t.team_id = c_team_id
       AND nvl (t.start_date_active, sysdate - 1) <= sysdate
       AND nvl (t.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_code = 'REMARKETER'
       AND role_resource_type = 'RS_TEAM'
       AND nvl (jtfr.start_date_active, sysdate - 1) <= sysdate
       AND nvl (jtfr.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_resource_id = t.team_id
       AND t.team_id = tm.team_id
       AND tm.delete_flag = 'N'
       AND tm.resource_number = re.resource_number
       AND nvl (re.start_date_active, sysdate - 1) <= sysdate
       AND nvl (re.end_date_active, sysdate + 1) >= sysdate
       AND source_id = wu.orig_system_id
       AND ROWNUM < c_current_user
       AND wu.name > nvl(c_name, '0')
    UNION
    SELECT wu.name, wu.display_name
      FROM jtf_rs_teams_vl t,
           jtf_rs_role_relations_vl jtfr,
           jtf_rs_team_members_vl tm,
           jtf_rs_resource_extns_vl re,
           wf_users WU
     WHERE t.team_id = c_team_id
       AND nvl (t.start_date_active, sysdate - 1) <= sysdate
       AND nvl (t.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_code = 'REMARKETER'
       AND role_resource_type = 'RS_INDIVIDUAL'
       AND nvl (jtfr.start_date_active, sysdate - 1) <= sysdate
       AND nvl (jtfr.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_resource_id = re.RESOURCE_ID
       AND t.team_id = tm.team_id
       AND tm.delete_flag = 'N'
       AND tm.resource_number = re.resource_number
       AND nvl (re.start_date_active, sysdate - 1) <= sysdate
       AND nvl (re.end_date_active, sysdate + 1) >= sysdate
       AND source_id = wu.orig_system_id
       AND ROWNUM < c_current_user
       AND wu.name > nvl(c_name, '0')
    UNION
    SELECT wu.name, wu.display_name
      FROM jtf_rs_teams_vl t,
           jtf_rs_role_relations_vl jtfr,
           jtf_rs_team_members_vl tm,
           jtf_rs_resource_extns_vl re,
           wf_users WU
     WHERE t.team_id = c_team_id
       AND nvl (t.start_date_active, sysdate - 1) <= sysdate
       AND nvl (t.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_code = 'REMARKETER'
       AND role_resource_type = 'RS_TEAM_MEMBER'
       AND nvl (jtfr.start_date_active, sysdate - 1) <= sysdate
       AND nvl (jtfr.end_date_active, sysdate + 1) >= sysdate
       AND jtfr.role_resource_id = tm.team_member_id
       AND t.team_id = tm.team_id
       AND tm.delete_flag = 'N'
       AND tm.resource_number = re.resource_number
       AND nvl (re.start_date_active, sysdate - 1) <= sysdate
       AND nvl (re.end_date_active, sysdate + 1) >= sysdate
       AND source_id = wu.orig_system_id
       AND ROWNUM < c_current_user
       AND wu.name > nvl(c_name, '0')
    ORDER BY 1 ASC;

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_rmr_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'REMARKETER_ID');

      l_total_rec := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TOTAL_RECIPIENTS');

      l_current_rec := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'CURRENT_RECIPIENT');

      l_current_user := wf_engine.GetItemAttrText( itemtype => itemtype,
                                        itemkey => itemkey,
                                       aname   => 'PERFORMING_AGENT');


   OPEN  wf_users_csr(l_rmr_id, l_current_rec, l_current_user);
   FETCH wf_users_csr INTO l_user, l_name ;
   CLOSE wf_users_csr;

      wf_engine.SetItemAttrText ( itemtype=> itemtype,
                     itemkey => itemkey,
                    aname   => 'PERFORMING_AGENT',
                              avalue  => l_user);

      wf_engine.SetItemAttrText ( itemtype=> itemtype,
                     itemkey => itemkey,
                    aname   => 'RECIPIENT_NAME',
                              avalue  => l_name);

      l_current_rec := l_current_rec-1;

      wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CURRENT_RECIPIENT',
                              avalue  => l_current_rec);


   IF l_current_rec = 0 THEN
   resultout := 'COMPLETE:NOTIFY_COMPLETE';
   ELSE
   resultout := 'COMPLETE:NOTIFY_OUTSTANDING';
   END IF;

      RETURN ;

    END IF;
    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;
    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF wf_users_csr%ISOPEN THEN
           CLOSE wf_users_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'NOTIFY_REMK_USER', itemtype, itemkey, actid, funcmode);
        RAISE;

  END NOTIFY_REMK_USER;

  -- Start of comments
  --
  -- Procedure Name : check_asset_return
  -- Description    : validate asset return is for a repossession from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_asset_return(  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
 l_code   okl_asset_returns_v.ars_code%type;

    -- Check that the asset return refers to a Repossession Request
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT ARS_CODE
 FROM   OKL_ASSET_RETURNS_V
 WHERE  ID= c_art_id
    AND    ARS_CODE IN ('REPOSSESSED', 'UNSUCCESS_REPO')
    AND    ART1_CODE = 'REPOS_REQUEST';


    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_code;
  CLOSE okl_check_req_csr;

  IF l_code = 'UNSUCCESS_REPO' THEN
   resultout := 'COMPLETE:ASSET_NOT_RETURNED';
  ELSIF l_code = 'REPOSSESSED' THEN
   resultout := 'COMPLETE:ASSET_RETURNED';
  END IF;

        -- At this point populate the attributes required for the notification
        populate_notification_attribs(itemtype => itemtype,
                                   itemkey  => itemkey,
                         actid    => actid,
                           funcmode => funcmode,
                       p_art_id => l_art_id );

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_asset_return', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_asset_return;

  -- Start of comments
  --
  -- Procedure Name : check_return_type
  -- Description    : validate asset return from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_return_type (  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
 l_knt   NUMBER;

    -- Check that the asset return refers to a Repossession Request
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT count(*)
 FROM   OKL_ASSET_RETURNS_V
 WHERE  ID= c_art_id
    AND    ART1_CODE = 'REPOS_REQUEST';

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_knt;
  CLOSE okl_check_req_csr;

  IF l_knt = 0 THEN
   resultout := 'COMPLETE:NON_REPO_RETURN';
  ELSE
   resultout := 'COMPLETE:REPO_RETURN';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_return_type', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_return_type;

  -- Start of comments
  --
  -- Procedure Name : check_role_exists
  -- Description    : check notification is sent to a valid user from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_role_exists (  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_creator  NUMBER;
 l_role   VARCHAR2(100);
 l_name   VARCHAR2(100);

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_creator := wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey => itemkey,
                           aname   => 'CREATED_BY');


        okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_creator
                              , x_name     => l_role
                           , x_description => l_name);

        IF l_role IS NULL THEN
           resultout := 'COMPLETE:ROLE_NOT_FOUND';
        ELSE

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                            itemkey => itemkey,
                            aname   => 'REQUESTER',
                                      avalue  => l_role);

   resultout := 'COMPLETE:ROLE_FOUND';
        END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_role_exists', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_role_exists;

  -- Start of comments
  --
  -- Procedure Name : validate_title_ret
  -- Description    : title return request from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE validate_title_ret(  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
 l_code   okl_asset_returns_v.ars_code%type;

    -- Check that the asset return refers to a Repossession Request
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT OAR.KLE_ID KLE_ID, KLE.CHR_ID CHR_ID, OAR.LAST_UPDATED_BY LAST_UPDATED_BY
    FROM   okl_asset_returns_b OAR, OKL_K_LINES_FULL_V KLE
    WHERE  OAR.KLE_ID = KLE.ID
 AND    OAR.ID= c_art_id;

    l_art_rec      okl_check_req_csr%rowtype;
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    l_rule_rec          okl_rule_pub.rulv_rec_type;
    l_party_object_tbl  okl_am_parties_pvt.party_object_tbl_type;
    l_object_tbl        okl_am_util_pvt.jtf_object_tbl_type;


--12/18/06 rkuttiya added for XMLP Project

    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_art_rec;
  CLOSE okl_check_req_csr;

        IF l_art_rec.KLE_ID IS NOT NULL THEN

           -- First get the party id from the rule if the custodian is a 3rd party
     okl_am_util_pvt.get_rule_record (
             p_rgd_code => 'LAAFLG',
             p_rdf_code => 'LAFLTL',
             p_chr_id   => l_art_rec.chr_id,
             p_cle_id   => l_art_rec.kle_id,
             x_rulv_rec => l_rule_rec,
             x_return_status => l_return_status,
             p_message_yn => TRUE); -- put error message on stack if there is no rule

        END IF;

        IF  l_return_status = OKL_API.G_RET_STS_SUCCESS AND nvl(l_rule_rec.object2_id1, l_rule_rec.object1_id1) IS NOT NULL THEN -- party id exists

            resultout := 'COMPLETE:VALID';

          -- get party name
          -- To Do: change to okl_am_util_pvt MDOKAL
          okl_am_util_pvt.get_object_details (
                                             p_object_code => l_rule_rec.jtot_object2_code, -- no need to hard-code
                                             p_object_id1  => l_rule_rec.object2_id1, -- correct field to use
                                             p_object_id2  => l_rule_rec.object2_id2, -- correct field to use
                                             x_object_tbl  => l_object_tbl,
                                             x_return_status => l_return_status);

            -- Item Attributes for Fulfillment
            wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                              avalue  => l_art_rec.LAST_UPDATED_BY);

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'PROCESS_CODE',
                              avalue  => 'AMRTR');

--12/20/06 rkuttiya commented to change recipient type to LESSEE, for XMLP Project
            /*wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_TYPE',
                              avalue  => 'P'); */

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RECIPIENT_TYPE',
                                    avalue  => 'LESSEE');

            wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_ID',
                              avalue  => nvl(l_rule_rec.object2_id1, l_rule_rec.object1_id1));

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_DESCRIPTION',
                              avalue  => l_object_tbl(1).name );


--12/18/06 rkuttiya modified for XMLP Project
--set the From Address and TO Address
        OPEN c_recipient(nvl(l_rule_rec.object2_id1, l_rule_rec.object1_id1));
        FETCH c_recipient INTO l_to_email;
        CLOSE c_recipient;

         wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'EMAIL_ADDRESS', -- 20/07/2007 ansethur modified the Item attribute name
                                     avalue  =>  l_to_email);

        OPEN c_agent_csr(l_art_rec.last_updated_by);
        FETCH c_agent_csr into l_from_email;
        CLOSE c_agent_csr;

          wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'FROM_ADDRESS', -- 20/07/2007 ansethur modified the Item attribute name
                                     avalue  =>  l_from_email);


           --18-Dec-06 rkuttiya added for XMLP Project
           --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_ART_ID';
          l_xmp_rec.param_value := l_art_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                        resultout := 'COMPLETE:VALID'; -- 20/07/2007 ansethur modified the value passed
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;

        ELSE
            resultout := 'COMPLETE:INVALID';
        END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

 EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

  END validate_title_ret;


  -- Start of comments
  --
  -- Procedure Name : validate_shipping_instr
  -- Description    : validate shipping instruction request from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --    18-Dec-06  rkuttiya modified for XMLP Project
  -- End of comments
  PROCEDURE validate_shipping_instr(
                                 itemtype IN  VARCHAR2,
                     itemkey   IN  VARCHAR2,
                      actid  IN  NUMBER,
                        funcmode IN  VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id          NUMBER;

    -- Check that the asset return refers to a Repossession Request
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
    SELECT ra.last_updated_by, cp.contact_party_id pac_id, contact_party_name
    FROM   okl_asset_returns_b    ar
          ,okl_relocate_assets_b      ra
          ,okl_am_contact_points_uv   cp
          ,okl_am_contacts_uv        c
    WHERE ar.id = c_art_id
    AND ar.id  = ra.art_id
    AND pac_id = cp.contact_contact_point_id
    AND cp.contact_party_id = c.contact_party_id
    AND ist_id IS NOT NULL;

    l_csr_rec okl_check_req_csr%rowtype;

    l_user_name   WF_USERS.name%type;
    l_name        WF_USERS.description%type;

    l_recipient_name     varchar2(100);
    l_recipient_id       number;
    l_party_object_tbl   okl_am_parties_pvt.party_object_tbl_type;

  --12/18/06 rkuttiya added for XMLP Project

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    ERR EXCEPTION;
    l_batch_id     NUMBER;
    l_xmp_rec      OKL_XMLP_PARAMS_PVT.xmp_rec_type;
    lx_xmp_rec     OKL_XMLP_PARAMS_PVT.xmp_rec_type;
  --get the recipient email address
    CURSOR c_recipient(p_recipient_id IN NUMBER)
    IS
    SELECT hzp.email_address email
    FROM  hz_parties hzp
    WHERE hzp.party_id = p_recipient_id;

  -- get the sender email address
    CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;
    l_from_email      VARCHAR2(100);
    l_to_email        VARCHAR2(100);

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN  okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_csr_rec;
  CLOSE okl_check_req_csr;

        okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_csr_rec.last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);

        -- Find party details based on the PAC_ID
        --okl_am_parties_pvt.get_party_details (
        --                                 p_id_code      => 'PC',
        --                                p_id_value      => l_csr_rec.pac_id,
        --                                    x_party_object_tbl => l_party_object_tbl,
        --                                 x_return_status  => l_return_status);

        -- Check that a contact was returned for the TRANSACTION_ID given.
  IF l_csr_rec.pac_id IS NOT NULL THEN
   resultout := 'COMPLETE:VALID';

            wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CREATED_BY',
                             avalue  => l_csr_rec.last_updated_by);

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user_name);

            -- Populate Item Attributes for Fulfillment
            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'PROCESS_CODE',
                              avalue  => 'AMNSI');
--12/18/06 modified recipient type to 'LESSEE' for XML Publisher, since this was originally Party Contact
/*
            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_TYPE',
                              avalue  => 'PC'); */
            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                itemkey => itemkey,
                                                aname   => 'RECIPIENT_TYPE',
                                    avalue  => 'LESSEE');

            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_ID',
                                avalue  =>  l_csr_rec.pac_id);


            wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'RECIPIENT_DESCRIPTION',
                                avalue  =>  l_csr_rec.contact_party_name);
--12/18/06 rkuttiya modified for XMLP Project
--set the From Address and TO Address
        OPEN c_recipient(l_csr_rec.pac_id);
        FETCH c_recipient INTO l_to_email;
        CLOSE c_recipient;

        OPEN c_agent_csr(l_csr_rec.last_updated_by);
        FETCH c_agent_csr into l_from_email;
        CLOSE c_agent_csr;

          wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'EMAIL_ADDRESS',
                                     avalue  =>  l_to_email);


        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                     itemkey => itemkey,
                                     aname   => 'FROM_ADDRESS',
                                     avalue  =>  l_from_email);

           --18-Dec-06 rkuttiya added for XMLP Project
           --code for inserting bind parameters into table

          l_xmp_rec.param_name := 'P_ART_ID';
          l_xmp_rec.param_value := l_art_id;
          l_xmp_rec.param_type_code := 'NUMBER';

           OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec(
                           p_api_version     => l_api_version
                          ,p_init_msg_list   => l_init_msg_list
                          ,x_return_status   => l_return_status
                          ,x_msg_count       => x_msg_count
                          ,x_msg_data        => x_msg_data
                          ,p_xmp_rec         => l_xmp_rec
                          ,x_xmp_rec         => lx_xmp_rec
                           );
               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE ERR;
               END IF;


                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       l_batch_id := lx_xmp_rec.batch_id;
                       wf_engine.SetItemAttrText ( itemtype=> itemtype,
                                                   itemkey => itemkey,
                                                   aname   => 'BATCH_ID',
                                                    avalue  => l_batch_id );
                        resultout := 'COMPLETE:VALID'; -- rkuttiya changed
                ELSE
                        resultout := 'COMPLETE:ERROR';
                END IF;
 ELSE
         resultout := 'COMPLETE:INVALID';
 END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'validate_shipping_instr', itemtype, itemkey, actid, funcmode);
        RAISE;

  END validate_shipping_instr;

  -- Start of comments
  --
  -- Procedure Name : validate_asset_repair
  -- Description    : validate asset repair approval request from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE validate_asset_repair(  itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_id      NUMBER;
 l_knt   NUMBER;

    -- cursor to check request is valid
 CURSOR okl_check_req_csr(c_id NUMBER)
 IS
 SELECT count(*)
 FROM   OKL_ASSET_CNDTNS ACD, OKL_ASSET_CNDTN_LNS_V ACN
 WHERE  ACD.ID = c_id
    AND    ACD.ID = ACN.ACD_ID
    AND    upper(nvl(ACN.APPROVED_YN, 'N')) <> 'Y'
    AND    ACN.ACS_CODE = 'WAITING_FOR_APPROVAL';

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_id);
  FETCH okl_check_req_csr INTO l_knt;
  CLOSE okl_check_req_csr;

  IF l_knt = 0 THEN
   resultout := 'COMPLETE:INVALID';
  ELSE
   resultout := 'COMPLETE:VALID';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'validate_asset_repair', itemtype, itemkey, actid, funcmode);
        RAISE;

  END validate_asset_repair;

  -- Start of comments
  --
  -- Procedure Name : set_approved_yn
  -- Description    : set asset repair approval to Y/N from WF,
  --                  calls TAPI
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE set_approved_yn(  itemtype IN VARCHAR2,
                  itemkey   IN VARCHAR2,
                     actid  IN NUMBER,
                     funcmode IN VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2 )IS

 l_id  NUMBER;
 l_knt     NUMBER;
    l_approved_yn    VARCHAR2(10);

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_acnv_rec OKL_ACN_PVT.ACNV_REC_TYPE;
    x_acnv_rec OKL_ACN_PVT.ACNV_REC_TYPE;
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    CURSOR c_rec_csr(C_ID NUMBER)  IS
 SELECT ACN.ID id
    FROM   OKL_ASSET_CNDTNS ACD,
           OKL_ASSET_CNDTN_LNS_V ACN
    WHERE  ACD.ID = C_ID
    AND    ACD.ID = ACN.ACD_ID
    AND    nvl(UPPER(ACN.APPROVED_YN), 'N') <> 'Y'
    AND    ACN.ACS_CODE = 'WAITING_FOR_APPROVAL';

    ERR EXCEPTION;
    BEGIN

      IF (funcmode = 'RUN') THEN

      l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

      l_approved_yn := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');


        l_acnv_rec.APPROVED_YN := l_approved_yn;
        l_acnv_rec.DATE_APPROVED := SYSDATE;

  IF upper(l_approved_yn) = 'Y' THEN
   l_acnv_rec.ACS_CODE  :=  'APPROVED';
  ELSE
   l_acnv_rec.ACS_CODE  :=  'REJECTED';
  END IF;

        FOR c_rec IN c_rec_csr(l_id) LOOP

          l_acnv_rec.ID := c_rec.id;

          okl_acn_pvt.update_row( p_api_version    => l_api_version,
                                  p_init_msg_list  => l_init_msg_list,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_acnv_rec       => l_acnv_rec,
                                  x_acnv_rec       => x_acnv_rec);

    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE ERR;
    END IF;
        END LOOP;


  IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
   resultout := 'COMPLETE:SUCCESS';
  ELSE
   resultout := 'COMPLETE:ERROR';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN ERR THEN
        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_ASSET_REPAIR_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_ASSET_REPAIR_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END set_approved_yn;

  -- Start of comments
  --
  -- Procedure Name : pop_asset_repair_att
  -- Description    : populate asset repair attributes from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE POP_ASSET_REPAIR_ATT( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_id      NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DESCRIPTION%TYPE;
    l_message       VARCHAR2(30000);

    -- cursor to populate notification attributes
 --Bug # 6174484 ssdeshpa Fixed Cursor for SQL Performance start
 CURSOR okl_asset_repair_csr(c_id NUMBER)
 IS
/* SELECT ACN.LAST_UPDATED_BY LAST_UPDATED_BY,
           AD.ASSET_NUMBER     ASSET_NUMBER,
           AD.ITEM_DESCRIPTION ASSET_DESCRIPTION,
           AD.CONTRACT_NUMBER  CONTRACT_NUMBER,
           ACN.PART_NAME       PART_NAME,
           ACN.RECOMMENDED_REPAIR DETAILS,
           FND1.MEANING CONDITION_TYPE,
           FND2.MEANING DAMAGE_TYPE
 FROM   OKL_AM_ASSET_RETURNS_UV AD,
           OKL_ASSET_CNDTNS ACD,
           OKL_ASSET_CNDTN_LNS_V ACN,
           FND_LOOKUPS FND1,
           FND_LOOKUPS FND2
    WHERE  ACD.KLE_ID = AD.KLE_ID
 AND    ACD.ID = C_ID
    AND    ACD.ID = ACN.ACD_ID
    AND    upper(nvl(ACN.APPROVED_YN, 'N')) <> 'Y'
    AND    ACN.ACS_CODE = 'WAITING_FOR_APPROVAL'
    AND FND1.LOOKUP_TYPE = 'OKL_ASSET_CONDITION'
    AND FND1.LOOKUP_CODE = ACN.CDN_CODE
    AND FND2.LOOKUP_TYPE = 'OKL_DAMAGE_TYPE'
    AND FND2.LOOKUP_CODE = ACN.DTY_CODE;*/

SELECT ACNB.LAST_UPDATED_BY LAST_UPDATED_BY,
       KLE.NAME     ASSET_NUMBER,
       KLE.ITEM_DESCRIPTION ASSET_DESCRIPTION,
       OKC.CONTRACT_NUMBER  CONTRACT_NUMBER,
       ACNT.PART_NAME       PART_NAME,
       ACNT.RECOMMENDED_REPAIR DETAILS,
       FND1.MEANING CONDITION_TYPE,
       FND2.MEANING DAMAGE_TYPE
 FROM  OKL_ASSET_RETURNS_B OAR,
       OKC_K_HEADERS_ALL_B OKC,
       OKC_K_LINES_V KLE,
       OKL_ASSET_CNDTNS_ALL ACD,
       OKL_AST_CNDTN_LNS_ALL_B ACNB,
       OKL_ASSET_CNDTN_LNS_TL ACNT,
       FND_LOOKUPS FND1,
       FND_LOOKUPS FND2
 WHERE OKC.ID = KLE.CHR_ID
 AND OAR.KLE_ID = KLE.ID
 AND ACD.KLE_ID = OAR.KLE_ID
 AND ACD.ID = c_id
 AND ACNB.ID = ACNT.ID
 AND ACNT.LANGUAGE = USERENV('LANG')
 AND ACD.ID = ACNB.ACD_ID
 AND UPPER(NVL(ACNB.APPROVED_YN, 'N')) <> 'Y'
 AND ACNB.ACS_CODE = 'WAITING_FOR_APPROVAL'
 AND FND1.LOOKUP_TYPE = 'OKL_ASSET_CONDITION'
 AND FND1.LOOKUP_CODE = ACNB.CDN_CODE
 AND FND2.LOOKUP_TYPE = 'OKL_DAMAGE_TYPE'
 AND FND2.LOOKUP_CODE = ACNB.DTY_CODE;

--Bug # 6174484 ssdeshpa Fixed Cursor for SQL Performance start

    l_header_done    BOOLEAN := FALSE;
    l_updated_by     NUMBER;

  BEGIN

    l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

    --build message (temp)

    FOR l_asset_repair_rec in okl_asset_repair_csr(l_id) LOOP

      IF NOT l_header_done THEN
        l_message  := '<p>The repairs listed below are requested for the Asset '||l_asset_repair_rec.asset_number||'<br>'||
                      l_asset_repair_rec.asset_description||' from Contract Number '||l_asset_repair_rec.contract_number||'</p>'||
                      '<p>The repairs will be completed following your approval.</p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td><b>Part<b/></td>'||
                      '<td><b>Condition Type<b/></td>'||
                      '<td><b>Damage Type<b/></td>'||
                      '<td><b>Details<b/></td>'||
                      '</tr>';
         l_header_done := TRUE;
         l_updated_by  := l_asset_repair_rec.last_updated_by;
      END IF;

      l_message  :=  l_message||'<tr>'||
                                '<td>'||l_asset_repair_rec.part_name||'</td>'||
                                '<td>'||l_asset_repair_rec.condition_type||'</td>'||
                                '<td>'||l_asset_repair_rec.damage_type||'</td>'||
                                '<td>'||l_asset_repair_rec.details||'</td>'||
                                '</tr>';

    END LOOP;

    IF l_header_done THEN
      l_message  := l_message||'</table>';
    END IF;

    okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_updated_by
                              , x_name     => l_user
                           , x_description => l_name);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'WF_ADMINISTRATOR',
                              avalue  => l_user);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRX_TYPE_ID',
                              avalue  => 'OKLAMAAR');

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DESCRIPTION',
                              avalue  => l_message);
  EXCEPTION
     WHEN OTHERS THEN
        IF okl_asset_repair_csr%ISOPEN THEN
           CLOSE okl_asset_repair_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_ASSET_REPAIR_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;

  END POP_ASSET_REPAIR_ATT;

  -- Start of comments
  --
  -- Procedure Name : populate_itd_atts
  -- Description    : populate Internal Transport Department notification attributes
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE populate_itd_atts(itemtype IN VARCHAR2,
                              itemkey  IN VARCHAR2,
                     actid    IN NUMBER,
                     funcmode IN VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2) AS

    l_art_id      NUMBER;
 l_no_data_found  BOOLEAN;
--    l_performer         WF_USERS.NAME%TYPE;
    l_requester         WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DISPLAY_NAME%TYPE;
    -- cursor to populate notification attributes

  CURSOR okl_asset_return_csr(c_art_id NUMBER)
  IS
/*     SELECT OAR.LAST_UPDATED_BY LAST_UPDATED_BY,
            AD.ITEM_DESCRIPTION ASSET_DESCRIPTION,
            AD.NAME             ASSET_NUMBER,
            AD.CONTRACT_NUMBER  CONTRACT_NUMBER,
            AD.SERIAL_NUMBER    SERIAL_NUMBER,
            AD.MODEL_NUMBER     MODEL_NUMBER,
            OAR.COMMENTS        COMMENTS
     FROM   OKL_AM_ASSET_DETAILS_UV AD, OKL_ASSET_RETURNS_V OAR
     WHERE  AD.ID  = OAR.KLE_ID
     AND    OAR.ID = c_art_id;
*/
     SELECT OAR.LAST_UPDATED_BY LAST_UPDATED_BY,
            AD.ITEM_DESCRIPTION ASSET_DESCRIPTION,
            AD.NAME             ASSET_NUMBER,
            AD.CONTRACT_NUMBER  CONTRACT_NUMBER,
            AD.SERIAL_NUMBER    SERIAL_NUMBER,
            AD.MODEL_NUMBER     MODEL_NUMBER,
            OAR.COMMENTS        COMMENTS,
            C.CONTACT_PARTY_NAME CONTACT_NAME,
            CP.CONTACT_DETAILS   CONTACT_DETAILS
     FROM   OKL_AM_ASSET_DETAILS_UV AD,
            OKL_ASSET_RETURNS_V OAR,
            OKL_RELOCATE_ASSETS_V ORA,
            OKL_AM_CONTACT_POINTS_UV CP,
            OKL_AM_CONTACTS_UV  C
     WHERE  AD.ID  = OAR.KLE_ID
     AND    OAR.ID = c_art_id
     AND    OAR.ID = ORA.ART_ID
     AND    ORA.PAC_ID = CP.CONTACT_CONTACT_POINT_ID
     AND    CP.CONTACT_PARTY_ID = C.CONTACT_PARTY_ID;

    l_asset_return    okl_asset_return_csr%rowtype;

  BEGIN
    l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

 OPEN  okl_asset_return_csr(l_art_id);
 FETCH okl_asset_return_csr INTO l_asset_return;
 CLOSE okl_asset_return_csr;

    -- Get the notification recipient from profile.
/*    l_performer := fnd_profile.value('OKL_TRANSPORTATION_NOTIFICATION');

          -- get the requestor
    OKL_AM_WF.GET_NOTIFICATION_AGENT(
           itemtype        => itemtype,
           itemkey         => itemkey,
           actid           => actid,
           funcmode        => funcmode,
           p_user_id       => l_asset_return.last_updated_by,
           x_name          => l_requester,
           x_description   => l_name);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_requester);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'PERFORMING_AGENT',
                              avalue  => l_performer);
*/
    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTACT_NAME',
                              avalue  => l_asset_return.CONTACT_NAME);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTACT_METHOD',
                              avalue  => l_asset_return.CONTACT_DETAILS);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => l_asset_return.CONTRACT_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_NUMBER',
                              avalue  => l_asset_return.ASSET_NUMBER);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSET_DESCRIPTION',
                              avalue  => l_asset_return.asset_description);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'DETAILS',
                              avalue  => l_asset_return.comments);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'SERIAL_NUMBER',
                              avalue  => l_asset_return.serial_number);

    wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MODEL_NUMBER',
                              avalue  => l_asset_return.model_number);

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_asset_return_csr%ISOPEN THEN
           CLOSE okl_asset_return_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'populate_itd_atts', itemtype, itemkey, actid, funcmode);
        RAISE;
  END populate_itd_atts;

  PROCEDURE VALIDATE_CONT_PORT (itemtype IN  VARCHAR2,
                  itemkey   IN  VARCHAR2,
                     actid     IN  NUMBER,
                     funcmode IN  VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2) IS

 CURSOR okl_pfc_csr(c_id NUMBER)
 IS
    SELECT count(1)
    FROM    OKL_PRTFL_CNTRCTS_B     PFC
    WHERE PFC.KHR_ID      = c_id;

    l_id        NUMBER;
    l_count     NUMBER;

  BEGIN

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');


      OPEN  okl_pfc_csr(l_id);
      FETCH okl_pfc_csr into l_count;
      CLOSE okl_pfc_csr;

      IF l_count > 0 THEN
        resultout := 'COMPLETE:VALID';
      ELSE
        resultout := 'COMPLETE:INVALID';
      END IF;

      RETURN ;

    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_pfc_csr%ISOPEN THEN
           CLOSE okl_pfc_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'VALIDATE_CONT_PORT', itemtype, itemkey, actid, funcmode);
        RAISE;
  END VALIDATE_CONT_PORT;

  -- Start of comments
  --
  -- Procedure Name : POP_CONT_PORT_ATT
  -- Description    : populate portfolio approval message attributes
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE POP_CONT_PORT_ATT( itemtype IN  VARCHAR2,
                  itemkey   IN  VARCHAR2,
                     actid     IN  NUMBER,
                     funcmode IN  VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2) IS

    l_id          NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

    l_message           VARCHAR2(30000);
    -- cursor to populate notification attributes

 CURSOR okl_pfc_csr(c_id NUMBER)
 IS
    SELECT TEAM_NAME   ASSIGNMENT_GROUP,
        AD.CONTRACT_NUMBER  CONTRACT_NUMBER,
   FND.MEANING   STRATEGY,
   PFCL.BUDGET_AMOUNT BUDGET,
   PFCL.DATE_STRATEGY_EXECUTION_DUE EXECUTION_DATE,
            PFC.LAST_UPDATED_BY  LAST_UPDATED_BY
    FROM    OKL_PRTFL_CNTRCTS_B     PFC,
            OKL_PRTFL_LINES_V       PFCL,
            OKC_K_HEADERS_V         AD,
            FND_LOOKUPS             FND,
            JTF_RS_TEAMS_VL         T
    WHERE   PFC.KHR_ID                = c_id
    AND     PFC.ID                    = PFCL.PFC_ID
    AND     AD.ID                     = PFC.KHR_ID
    AND     ASSET_TRACK_STRATEGY_CODE = FND.LOOKUP_CODE
    AND     FND.LOOKUP_TYPE           = 'OKL_ASSET_TRACK_STRATEGIES'
    AND     TMB_ID                    = T.TEAM_ID;

    l_header_done    BOOLEAN := FALSE;
    l_user_name      WF_USERS.name%type;
    l_name           WF_USERS.description%type;

  BEGIN

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        --build message

        FOR l_pfc_rec in okl_pfc_csr(to_number(l_id)) LOOP

          IF NOT l_header_done THEN
            l_message  := '<p>'||l_pfc_rec.assignment_group||'</p>'||
                      '<p>Contract Number:'||l_pfc_rec.contract_number||'</p>'||
       '<p>Please approve the following profile.</p>'||
                      '<table width="50%" border="1">'||
                      '<tr>'||
                      '<td>Strategy</td>'||
                      '<td>Budget</td>'||
                      '<td>Execution Date</td>'||
                      '</tr>';
             l_header_done := TRUE;

             okl_am_wf.get_notification_agent(
                                itemtype   => itemtype
                           , itemkey     => itemkey
                           , actid       => actid
                           , funcmode   => funcmode
                              , p_user_id     => l_pfc_rec.last_updated_by
                              , x_name     => l_user_name
                           , x_description => l_name);
          END IF;

          l_message  :=  l_message||'<tr>'||
                                '<td>'||l_pfc_rec.strategy||'</td>'||
                                '<td>'||l_pfc_rec.budget||'</td>'||
                                '<td>'||l_pfc_rec.execution_date||'</td>'||
                                '</tr>';
        END LOOP;

        IF l_header_done THEN
          l_message  := l_message||'</table>';
        END IF;

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TRX_TYPE_ID',
                              avalue  => 'OKLAMATK');

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'MESSAGE_DESCRIPTION',
                              avalue  => l_message);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user_name);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'WF_ADMINISTRATOR',
                              avalue  => l_user);
        resultout := 'COMPLETE:';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_pfc_csr%ISOPEN THEN
           CLOSE okl_pfc_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_CONT_PORT_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;
  END POP_CONT_PORT_ATT;

  -- Start of comments
  --
  -- Procedure Name : SET_CP_APPROVED_YN
  -- Description    : Update the APPROVED FLAG for contract portfolio
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE SET_CP_APPROVED_YN( itemtype IN  VARCHAR2,
                  itemkey   IN  VARCHAR2,
                     actid     IN  NUMBER,
                     funcmode IN  VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2) IS

 CURSOR okl_pfc_csr(c_id NUMBER)
 IS
    SELECT PFCL.ID               ID
    FROM    OKL_PRTFL_LINES_B     PFCL,
            OKL_PRTFL_CNTRCTS_B   PFC
    WHERE   PFC.KHR_ID          = c_id
    AND     PFC.ID              = PFCL.PFC_ID;

    l_pfc_rec           okl_pfc_csr%rowtype;
    l_id          NUMBER;
    l_approved_yn       VARCHAR2(10);

    l_return_status VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    l_pflv_rec OKL_PRTFL_LINES_PUB.PFLV_REC_TYPE;
    x_pflv_rec OKL_PRTFL_LINES_PUB.PFLV_REC_TYPE;
    l_api_version    NUMBER       := 1;
    l_init_msg_list  VARCHAR2(1) := 'T';

    API_ERROR  EXCEPTION;

  BEGIN

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

      l_approved_yn := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'APPROVED_YN');

  IF upper(l_approved_yn) = 'Y' THEN
   l_pflv_rec.TRX_STATUS_CODE  :=  'APPROVED';
  ELSE
   l_pflv_rec.TRX_STATUS_CODE  :=  'REJECTED';
  END IF;

        FOR  c_rec in okl_pfc_csr(l_id) LOOP

          l_pflv_rec.ID := c_rec.id;

          okl_prtfl_lines_pub.update_prtfl_lines(
                                            p_api_version    => l_api_version,
                                            p_init_msg_list  => l_init_msg_list,
                                            x_return_status  => l_return_status,
                                            x_msg_count      => x_msg_count,
                                            x_msg_data       => x_msg_data,
                                            p_pflv_rec       => l_pflv_rec,
                                            x_pflv_rec       => x_pflv_rec);

    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE API_ERROR;
    END IF;

        END LOOP;

  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
   RAISE API_ERROR;
  ELSE
   resultout := 'COMPLETE:SUCCESS';
  END IF;

        RETURN ;
    END IF;

  EXCEPTION

     WHEN API_ERROR THEN
        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'SET_CP_APPROVED_YN', itemtype, itemkey, actid, funcmode);
        RAISE;

     WHEN OTHERS THEN
        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'SET_CP_APPROVED_YN', itemtype, itemkey, actid, funcmode);
        RAISE;

  END SET_CP_APPROVED_YN;

  -- Start of comments
  --
  -- Procedure Name : POP_CPE_NOTIFY_ATT
  -- Description    : populate assignment group notification attributes from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE POP_CPE_NOTIFY_ATT( itemtype IN  VARCHAR2,
                  itemkey   IN  VARCHAR2,
                     actid     IN  NUMBER,
                     funcmode IN  VARCHAR2,
                  resultout OUT NOCOPY VARCHAR2) IS

    l_id          NUMBER;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;

    l_message           VARCHAR2(30000);
    -- cursor to populate notification attributes
 CURSOR okl_pfc_csr(c_id NUMBER)
 IS
    SELECT TMB_ID,
        AD.CONTRACT_NUMBER  CONTRACT_NUMBER,
   FND.MEANING   STRATEGY,
   PFCL.BUDGET_AMOUNT BUDGET,
   PFCL.DATE_STRATEGY_EXECUTION_DUE EXECUTION_DATE,
            PFC.LAST_UPDATED_BY  LAST_UPDATED_BY
    FROM    OKL_PRTFL_CNTRCTS_B     PFC,
            OKL_PRTFL_LINES_V       PFCL,
            OKC_K_HEADERS_V         AD,
            FND_LOOKUPS             FND
    WHERE   PFC.KHR_ID                = c_id
    AND     PFC.ID                    = PFCL.PFC_ID
    AND     AD.ID                     = PFC.KHR_ID
    AND     ASSET_TRACK_STRATEGY_CODE = FND.LOOKUP_CODE
    AND     FND.LOOKUP_TYPE           = 'OKL_ASSET_TRACK_STRATEGIES';


    l_pfc_rec  okl_pfc_csr%rowtype;

    -- cursor to find valid notification user
    CURSOR wf_users_csr(c_team_id NUMBER)
    IS
    SELECT count(1)
    FROM jtf_rs_teams_b t,
         jtf_rs_role_relations_vl jtfr,
         jtf_rs_Resource_extns a,
         jtf_rs_Team_Members b,
         jtf_rs_Groups_b d,
         jtf_rs_resource_extns re,
         wf_users WU
    WHERE
    t.team_id = c_team_id
    AND nvl (t.start_date_active, sysdate - 1) <= sysdate
    AND nvl (t.end_date_active, sysdate + 1) >= sysdate
    AND jtfr.role_code = 'PORTFOLIO_GROUP'
    AND role_resource_type = 'RS_TEAM'
    AND jtfr.role_resource_id = t.team_id
    AND t.team_id = b.Team_Id
    AND (DECODE(b.Resource_Type,'INDIVIDUAL',a.Resource_Number,
                              d.Group_Number)) = re.resource_number
    AND b.Team_Resource_Id = a.Resource_Id (+)
    AND b.Team_Resource_Id = d.Group_Id (+)
    AND re.user_name = wu.name
    AND re.source_id = wu.orig_system_id;

    l_user_name      WF_USERS.name%type;
    l_name           WF_USERS.description%type;

  BEGIN

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

     OPEN  okl_pfc_csr(l_id);
     FETCH okl_pfc_csr INTO l_pfc_rec;
     CLOSE okl_pfc_csr;

     OPEN  wf_users_csr(l_pfc_rec.TMB_ID);
     FETCH wf_users_csr INTO l_user;
     CLOSE wf_users_csr;

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'TOTAL_RECIPIENTS',
                              avalue  => l_user);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CURRENT_RECIPIENT',
                              avalue  => l_user+1);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CONTRACT_NUMBER',
                              avalue  => l_pfc_rec.CONTRACT_NUMBER);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'STRATEGY',
                              avalue  => l_pfc_rec.STRATEGY);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'ASSIGNMENT_GROUP_ID',
                              avalue  => to_char(l_pfc_rec.TMB_ID));

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'BUDGET',
                              avalue  => l_pfc_rec.BUDGET);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'EXECUTION_DATE',
                              avalue  => l_pfc_rec.EXECUTION_DATE);

        okl_am_wf.get_notification_agent(itemtype   => itemtype
                                    ,itemkey    => itemkey
                                    ,actid      => actid
                                    ,funcmode   => funcmode
                                    ,p_user_id  => l_pfc_rec.last_updated_by
                                    ,x_name     => l_user_name
                                    ,x_description  =>  l_name);

        wf_engine.SetItemAttrText ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'REQUESTER',
                              avalue  => l_user_name);

        resultout := 'COMPLETE:';
        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_pfc_csr%ISOPEN THEN
           CLOSE okl_pfc_csr;
        END IF;

        IF wf_users_csr%ISOPEN THEN
           CLOSE wf_users_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'POP_REMK_NOTIFY_ATT', itemtype, itemkey, actid, funcmode);
        RAISE;
  END POP_CPE_NOTIFY_ATT;


  -- Start of comments
  --
  -- Procedure Name : NOTIFY_ASS_GRP_USER
  -- Description    : populate assignment group notification attributes from WF
  --                  This procedure is called recursively until all team
  --                  members have been notified.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE NOTIFY_ASS_GRP_USER( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS

    l_rmr_id      NUMBER;
    l_total_rec      NUMBER;
    l_current_rec       NUMBER  := 0;
 l_no_data_found  BOOLEAN;
    l_user              WF_USERS.NAME%TYPE;
    l_name              WF_USERS.DISPLAY_NAME%TYPE;
    l_current_user      WF_USERS.NAME%TYPE;

    -- cursor to populate notification attributes
    CURSOR wf_users_csr(c_team_id       NUMBER,
                        c_current_user  NUMBER,
                        c_name          VARCHAR)
    IS
    SELECT wu.name, wu.display_name
    FROM jtf_rs_teams_vl t,
         jtf_rs_role_relations_vl jtfr,
         jtf_rs_Resource_extns a,
         jtf_rs_Team_Members b,
         jtf_rs_Groups_b d,
         jtf_rs_resource_extns re,
         wf_users WU
    WHERE  t.team_id = c_team_id
    AND nvl (t.start_date_active, sysdate - 1) <= sysdate
    AND nvl (t.end_date_active, sysdate + 1) >= sysdate
    AND jtfr.role_code = 'PORTFOLIO_GROUP'
    AND role_resource_type = 'RS_TEAM'
    AND jtfr.role_resource_id = t.team_id
    AND t.team_id = b.Team_Id
    AND (DECODE(b.Resource_Type,'INDIVIDUAL',a.Resource_Number,
                              d.Group_Number)) = re.resource_number
    AND b.Team_Resource_Id = a.Resource_Id (+)
    AND b.Team_Resource_Id = d.Group_Id (+)
    AND re.source_id = wu.orig_system_id
    AND re.user_name = wu.name
    AND ROWNUM < c_current_user
    AND wu.name > nvl(c_name, '0')
    order by 1 asc;

  BEGIN

    IF (funcmode = 'RUN') THEN

      l_rmr_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'ASSIGNMENT_GROUP_ID');

      l_total_rec := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TOTAL_RECIPIENTS');

      l_current_rec := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'CURRENT_RECIPIENT');

      l_current_user := wf_engine.GetItemAttrText( itemtype => itemtype,
                                        itemkey => itemkey,
                                       aname   => 'PERFORMING_AGENT');


   OPEN  wf_users_csr(l_rmr_id, l_current_rec, l_current_user);
   FETCH wf_users_csr INTO l_user, l_name ;
   CLOSE wf_users_csr;

      wf_engine.SetItemAttrText ( itemtype=> itemtype,
                     itemkey => itemkey,
                    aname   => 'PERFORMING_AGENT',
                              avalue  => l_user);

      wf_engine.SetItemAttrText ( itemtype=> itemtype,
                     itemkey => itemkey,
                    aname   => 'RECIPIENT_NAME',
                              avalue  => l_name);

      l_current_rec := l_current_rec-1;

      wf_engine.SetItemAttrNumber ( itemtype=> itemtype,
                    itemkey => itemkey,
                    aname   => 'CURRENT_RECIPIENT',
                              avalue  => l_current_rec);


   IF l_current_rec = 0 THEN
   resultout := 'COMPLETE:NOTIFY_COMPLETE';
   ELSE
   resultout := 'COMPLETE:NOTIFY_OUTSTANDING';
   END IF;

      RETURN ;

    END IF;
    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;
    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF wf_users_csr%ISOPEN THEN
           CLOSE wf_users_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'NOTIFY_ASS_GRP_USER', itemtype, itemkey, actid, funcmode);
        RAISE;

  END NOTIFY_ASS_GRP_USER;

  -- Start of comments
  --
  -- Procedure Name : check_itd_request
  -- Description    : Validate Notify Internal Trans. Dept. request from WF
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_itd_request(   itemtype IN VARCHAR2,
                     itemkey   IN VARCHAR2,
                      actid  IN NUMBER,
                        funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 )IS

 l_art_id  NUMBER;
    l_last_updated_by NUMBER;
    l_requester     VARCHAR2(100);
    l_description   VARCHAR2(100);

    -- cursor to check request is valid
 CURSOR okl_check_req_csr(c_art_id NUMBER)
 IS
 SELECT last_updated_by
 FROM   OKL_ASSET_RETURNS_V
 WHERE  ID= c_art_id;

    BEGIN

      IF (funcmode = 'RUN') THEN

      l_art_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                            itemkey => itemkey,
                          aname   => 'TRANSACTION_ID');

  OPEN okl_check_req_csr(l_art_id);
  FETCH okl_check_req_csr INTO l_last_updated_by;
  CLOSE okl_check_req_csr;

        OKL_AM_WF.GET_NOTIFICATION_AGENT(
           itemtype        => itemtype,
           itemkey         => itemkey,
           actid           => actid,
           funcmode        => funcmode,
           p_user_id       => l_last_updated_by,
           x_name          => l_requester,
           x_description   => l_description);


      wf_engine.SetItemAttrText( itemtype => itemtype,
                itemkey => itemkey,
              aname   => 'REQUESTER',
                                   avalue   => l_requester);

      wf_engine.SetItemAttrText( itemtype => itemtype,
                itemkey => itemkey,
              aname   => 'WF_ADMINISTRATOR',
                                   avalue   => l_requester);

  IF l_last_updated_by IS NULL THEN
   resultout := 'COMPLETE:INVALID_RETURN';
  ELSE
   resultout := 'COMPLETE:VALID_RETURN';
  END IF;

        RETURN ;

      END IF;
      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;
      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
        --
        resultout := 'COMPLETE:';
        RETURN;
        --
      END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF okl_check_req_csr%ISOPEN THEN
           CLOSE okl_check_req_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_itd_request', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_itd_request;

  -- Start of comments
  --
  -- Procedure Name : check_profile_recipient
  -- Description : check if the profile value for OKL_MANUAL_TERMINATION_QUOTE_REP
  --                  returns valid recipients.
  -- Business Rules :
  -- Parameters  : itemtype, itemkey, actid, funcmode, resultout
  -- Version  : 1.0
  --
  -- End of comments
  PROCEDURE check_profile_recipient( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                      actid  IN NUMBER,
                       funcmode IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2 ) AS


    l_id            VARCHAR2(100);
    l_performer     VARCHAR2(100);
    l_recipients    NUMBER;

    cursor c1_csr (p_value varchar)  is
       select count(*)
       from WF_USER_ROLES WUR
       where WUR.ROLE_NAME = p_value;


  BEGIN

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
                        itemkey => itemkey,
                      aname   => 'TRANSACTION_ID');

        -- Get the notification recipient from profile.
        l_performer := fnd_profile.value('OKL_TRANSPORTATION_NOTIFICATION');

        wf_engine.SetItemAttrText( itemtype => itemtype,
                itemkey => itemkey,
              aname   => 'PERFORMING_AGENT',
                                   avalue   => l_performer);


        OPEN c1_csr (l_performer);
        FETCH c1_csr INTO l_recipients;
        CLOSE c1_csr;

  IF l_recipients > 0 THEN
      resultout := 'COMPLETE:VALID_RETURN';
        ELSE
      resultout := 'COMPLETE:INVALID_RETURN';
        END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

  EXCEPTION

     WHEN OTHERS THEN

        IF c1_csr%ISOPEN THEN
           CLOSE c1_csr;
        END IF;

        wf_core.context('OKL_AM_ASSET_RETURN_WF' , 'check_profile_recipient', itemtype, itemkey, actid, funcmode);
        RAISE;

  END check_profile_recipient;

END OKL_AM_ASSET_RETURN_WF;

/
