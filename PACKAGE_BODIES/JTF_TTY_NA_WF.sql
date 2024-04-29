--------------------------------------------------------
--  DDL for Package Body JTF_TTY_NA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_NA_WF" AS
/* $Header: jtftrwab.pls 120.1 2005/06/24 00:25:40 jradhakr ship $ */

--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TTY_NA_WF
--  ---------------------------------------------------
--  PURPOSE
--      Process Catch All territories and create/update named accounts
--
--
--  PROCEDURES:
--       (see below for specification)
--
--  NOTES
--    This package is for PRIVATE USE ONLY use
--
--  HISTORY
--    12/13/02    ARPATEL          Package Body Created
--    02/25/03    ARPATEL          Added DN_MAPPING_COMPLETE_FLAG='N' when creating record in JTF_TTY_TERR_GRP_ACCTS
--    04/25/03    ARPATEL          bug#2878006 fix
--    06/02/03    ARPATEL          bug#2987314 fix
--    End of Comments
--

g_pkg_name     CONSTANT     VARCHAR2(30) := 'JTF_TTY_NA_WF';

PROCEDURE AssignRep
/*******************************************************************************
** Start of comments
**  Procedure   : AssignRep
**  Description :
**                This API modifies the Named Account model to ensure that a lead/opportunity
**                does not fall into a catch all territory again.
**
**                INPUT: details of a Lead/Opportunity which has fallen into a catch-all
**                OUTPUT: a modified Named Account model to ensure that lead/opportunity
**                        doesnt fall into catch all again.
**
**                PROCESS: 1) Find the Named Account whose keyword mapping rule
**                            matches the lead/opportunity business name
**                            AND whose state is the same as the lead/opportunity.
**
**                         2) If the lead/opportunity business name already exists as a named account then update
**                            the mapping rule of the NA found in step 1) above to include the new postal code.
**
**                         3) If the lead/opportunity business name does not exist as a named account then create
**                            a new Named account for this business name and create default mapping rules.
**
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     VARCHAR2 required
**
**  Notes :
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
)
IS

   lp_api_name                   CONSTANT VARCHAR2(30) := 'AssignRep';
   lp_api_version_number         CONSTANT NUMBER       := 1.0;
   l_lead_state                  VARCHAR2(360);
   l_lead_postal_code            VARCHAR2(360);
   l_lead_keyword                VARCHAR2(360);
   l_lead_terrgroup_Id           NUMBER;
   l_named_account_id            NUMBER;
   l_lead_access_Id              NUMBER;
   l_new_account_id              NUMBER;
   l_party_Id                    NUMBER;
   query_str                     VARCHAR2(30000);

   TYPE Ref_Cursor_Type IS REF CURSOR;
   c_named_accounts             Ref_Cursor_Type;
   l_named_account_rec          NA_Rec_Type;

       CURSOR c_resources(c_named_account_id NUMBER, c_terr_group_id NUMBER)  IS
       select NAR.RSC_GROUP_ID, NAR.RESOURCE_ID, RLV.ROLE_ID, NAR.RSC_ROLE_CODE
        from JTF_TTY_NAMED_ACCTS NA
           , JTF_TTY_TERR_GRP_ACCTS TGA
           , JTF_TTY_NAMED_ACCT_RSC NAR
           , JTF_RS_ROLES_VL RLV
        where NA.NAMED_ACCOUNT_ID = TGA.NAMED_ACCOUNT_ID
          AND TGA.TERR_GROUP_ACCOUNT_ID = NAR.TERR_GROUP_ACCOUNT_ID
          AND RLV.ROLE_CODE = NAR.RSC_ROLE_CODE
          AND NA.NAMED_ACCOUNT_ID = c_named_account_id
          AND TGA.TERR_GROUP_ID = c_terr_group_id ;


BEGIN
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Beginning of JTF_TTY_NA_WF.AssignRep');

    --get workflow attributes being passed in
    l_lead_state := wf_engine.GetItemAttrText
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'STATE'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_lead_state is:'||l_lead_state);

     l_lead_keyword := wf_engine.GetItemAttrText
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'KEYWORD'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_lead_keyword is:'||l_lead_keyword);

    l_lead_postal_code := wf_engine.GetItemAttrText
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'POSTAL_CODE'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_lead_postal_code is:'||l_lead_postal_code);

    l_lead_terrgroup_Id := wf_engine.GetItemAttrNumber
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'TERRGROUP_ID'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_lead_terrgroup_Id is:'||l_lead_terrgroup_Id);

    l_lead_access_Id := wf_engine.GetItemAttrNumber
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'ACCESS_ID'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_lead_access_Id is:'||l_lead_access_Id);

    l_party_Id := wf_engine.GetItemAttrNumber
                          ( itemtype => itemtype
                          , itemkey  => itemkey
                          , aname    => 'PARTY_ID'
                          );
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_party_Id is:'||l_party_Id);


    query_str :=
    'SELECT ILV.NAMED_ACCOUNT_ID, TGA.TERR_GROUP_ID ' ||
           ', decode(ILV.site_type_code, ''BR'', 6, ''SL'', 6, ''HQ'', 5, ''DU'', 4, ''GU'', 3, ''ALL'', 2, ''UN'', 1) SITE_RANK ' ||
      'FROM  ( ' ||
            'SELECT TNA.NAMED_ACCOUNT_ID, TNA.SITE_TYPE_CODE '||
                 ', case when (QM_1007.VALUE1_CHAR BETWEEN 1000 AND 2799) AND (NVL(QM_1007.VALUE2_CHAR,1000) BETWEEN 1000 AND 2799) then ''MA''  ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 2800 AND 2999) AND (NVL(QM_1007.VALUE2_CHAR,2800) BETWEEN 2800 AND 2999) then ''RI''  ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 3000 AND 3899) AND (NVL(QM_1007.VALUE2_CHAR,3000) BETWEEN 3000 AND 3899) then ''NH''  ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 3900 AND 4999) AND (NVL(QM_1007.VALUE2_CHAR,3900) BETWEEN 3900 AND 4999) then ''ME''  ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 5000 AND 5999) AND (NVL(QM_1007.VALUE2_CHAR,5000) BETWEEN 5000 AND 5999) then ''VT'' ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 6000 AND 6999) AND (NVL(QM_1007.VALUE2_CHAR,6000) BETWEEN 6000 AND 6999) then ''CT'' ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 7000 AND 8999) AND (NVL(QM_1007.VALUE2_CHAR,7000) BETWEEN 7000 AND 8999) then ''NJ'' ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 9000 AND 14999) AND (NVL(QM_1007.VALUE2_CHAR,9000) BETWEEN 9000 AND 14999) then ''NY'' ' ||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 15000 AND 19699) AND (NVL(QM_1007.VALUE2_CHAR,15000) BETWEEN 15000 AND 19699) then ''PA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 19700 AND 19999) AND (NVL(QM_1007.VALUE2_CHAR,19700) BETWEEN 19700 AND 19999) then ''DE'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20000 AND 20099) AND (NVL(QM_1007.VALUE2_CHAR,20000) BETWEEN 20000 AND 20099) then ''DC'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20600 AND 21999) AND (NVL(QM_1007.VALUE2_CHAR,20600) BETWEEN 20600 AND 21999) then ''MD'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20100 AND 20200) AND (NVL(QM_1007.VALUE2_CHAR,20100) BETWEEN 20100 AND 20200) then ''VA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 24700 AND 26899) AND (NVL(QM_1007.VALUE2_CHAR,24700) BETWEEN 24700 AND 26899) then ''WV'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 27000 AND 28999) AND (NVL(QM_1007.VALUE2_CHAR,27000) BETWEEN 27000 AND 28999) then ''NC'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 29000 AND 29999) AND (NVL(QM_1007.VALUE2_CHAR,29000) BETWEEN 29000 AND 29999) then ''SC'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 30000 AND 31999) AND (NVL(QM_1007.VALUE2_CHAR,30000) BETWEEN 30000 AND 31999) then ''GA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 32000 AND 34999) AND (NVL(QM_1007.VALUE2_CHAR,32000) BETWEEN 32000 AND 34999) then ''FL'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 35000 AND 36999) AND (NVL(QM_1007.VALUE2_CHAR,35000) BETWEEN 35000 AND 36999) then ''AL'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 37000 AND 38599) AND (NVL(QM_1007.VALUE2_CHAR,37000) BETWEEN 37000 AND 38599) then ''TN'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 38600 AND 39799) AND (NVL(QM_1007.VALUE2_CHAR,38600) BETWEEN 38600 AND 39799) then ''MS'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 40000 AND 42799) AND (NVL(QM_1007.VALUE2_CHAR,40000) BETWEEN 40000 AND 42799) then ''KY'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 43000 AND 45899) AND (NVL(QM_1007.VALUE2_CHAR,43000) BETWEEN 43000 AND 45899) then ''OH'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 46000 AND 47999) AND (NVL(QM_1007.VALUE2_CHAR,46000) BETWEEN 46000 AND 47999) then ''IN'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 48000 AND 49999) AND (NVL(QM_1007.VALUE2_CHAR,48000) BETWEEN 48000 AND 49999) then ''MI'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 50000 AND 52899) AND (NVL(QM_1007.VALUE2_CHAR,50000) BETWEEN 50000 AND 52899) then ''IA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 53000 AND 54999) AND (NVL(QM_1007.VALUE2_CHAR,53000) BETWEEN 53000 AND 54999) then ''WI'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 55000 AND 56799) AND (NVL(QM_1007.VALUE2_CHAR,55000) BETWEEN 55000 AND 56799) then ''MN'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 57000 AND 57799) AND (NVL(QM_1007.VALUE2_CHAR,57000) BETWEEN 57000 AND 57799) then ''SD'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 58000 AND 58899) AND (NVL(QM_1007.VALUE2_CHAR,58000) BETWEEN 58000 AND 58899) then ''ND'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 59000 AND 59999) AND (NVL(QM_1007.VALUE2_CHAR,59000) BETWEEN 59000 AND 59999) then ''MT'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 60000 AND 62999) AND (NVL(QM_1007.VALUE2_CHAR,60000) BETWEEN 60000 AND 62999) then ''IL'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 63000 AND 65899) AND (NVL(QM_1007.VALUE2_CHAR,63000) BETWEEN 63000 AND 65899) then ''MO'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 66000 AND 67999) AND (NVL(QM_1007.VALUE2_CHAR,66000) BETWEEN 66000 AND 67999) then ''KS'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 68000 AND 69399) AND (NVL(QM_1007.VALUE2_CHAR,68000) BETWEEN 68000 AND 69399) then ''NE'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 70000 AND 71499) AND (NVL(QM_1007.VALUE2_CHAR,70000) BETWEEN 70000 AND 71499) then ''LA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 71600 AND 72999) AND (NVL(QM_1007.VALUE2_CHAR,71600) BETWEEN 71600 AND 72999) then ''AR'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 73000 AND 74999) AND (NVL(QM_1007.VALUE2_CHAR,73000) BETWEEN 73000 AND 74999) then ''OK'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 75000 AND 79999) AND (NVL(QM_1007.VALUE2_CHAR,75000) BETWEEN 75000 AND 79999) then ''TX'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 80000 AND 81699) AND (NVL(QM_1007.VALUE2_CHAR,80000) BETWEEN 80000 AND 81699) then ''CO'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 82000 AND 83199) AND (NVL(QM_1007.VALUE2_CHAR,82000) BETWEEN 82000 AND 83199) then ''WY'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 83200 AND 83899) AND (NVL(QM_1007.VALUE2_CHAR,83200) BETWEEN 83200 AND 83899) then ''ID'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 84000 AND 84799) AND (NVL(QM_1007.VALUE2_CHAR,84000) BETWEEN 84000 AND 84799) then ''UT'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 85000 AND 86599) AND (NVL(QM_1007.VALUE2_CHAR,85000) BETWEEN 85000 AND 86599) then ''AZ'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 87000 AND 88499) AND (NVL(QM_1007.VALUE2_CHAR,87000) BETWEEN 87000 AND 88499) then ''NM'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 89000 AND 89899) AND (NVL(QM_1007.VALUE2_CHAR,89000) BETWEEN 89000 AND 89899) then ''NV'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 90000 AND 96699) AND (NVL(QM_1007.VALUE2_CHAR,90000) BETWEEN 90000 AND 96699) then ''CA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 96700 AND 96899) AND (NVL(QM_1007.VALUE2_CHAR,96700) BETWEEN 96700 AND 96899) then ''HI'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 97000 AND 97999) AND (NVL(QM_1007.VALUE2_CHAR,97000) BETWEEN 97000 AND 97999) then ''OR'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 98000 AND 99499) AND (NVL(QM_1007.VALUE2_CHAR,98000) BETWEEN 98000 AND 99499) then ''WA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 99500 AND 99999) AND (NVL(QM_1007.VALUE2_CHAR,99500) BETWEEN 99500 AND 99999) then ''AK'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20000 AND 20099) AND (NVL(QM_1007.VALUE2_CHAR,20000) BETWEEN 20000 AND 20099) then ''DC'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20201 AND 20599) AND (NVL(QM_1007.VALUE2_CHAR,20201) BETWEEN 20201 AND 20599) then ''DC'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 20100 AND 20200) AND (NVL(QM_1007.VALUE2_CHAR,20100) BETWEEN 20100 AND 20200) then ''VA'' '||
                          ' when (QM_1007.VALUE1_CHAR BETWEEN 22000 AND 24699) AND (NVL(QM_1007.VALUE2_CHAR,22000) BETWEEN 22000 AND 24699) then ''VA'' end '||
                 ' CALCULATED_STATE '||
                 ' , QM_1012.VALUE1_CHAR CUSTOMER_NAME '||
            ' FROM JTF_TTY_NAMED_ACCTS TNA '||
               ' , JTF_TTY_ACCT_QUAL_MAPS QM_1007 '||
               ' , JTF_TTY_ACCT_QUAL_MAPS QM_1012 '||
            ' WHERE '||
                  ' TNA.NAMED_ACCOUNT_ID = QM_1007.NAMED_ACCOUNT_ID '||
              ' AND QM_1007.QUAL_USG_ID = -1007 '||
              ' AND QM_1007.NAMED_ACCOUNT_ID = QM_1012.NAMED_ACCOUNT_ID '||
              ' AND QM_1012.QUAL_USG_ID = -1012 '||
            ' )ILV , JTF_TTY_TERR_GRP_ACCTS TGA '||
        ' WHERE ILV.NAMED_ACCOUNT_ID = TGA.NAMED_ACCOUNT_ID '||
        ' AND ILV.CALCULATED_STATE = '''||l_lead_state||
        ''' AND ( ILV.CUSTOMER_NAME = '''||l_lead_keyword || ''' OR ''' || l_lead_keyword || ''' LIKE ILV.CUSTOMER_NAME )'||
        ' AND rownum < 2 '||
        ' order by site_rank ';

        --find one named account which satisfies keyword and state requirement

    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('query_str is: '||query_str);

    --bug#2878006 fix ARPATEL 04/21/03
   IF l_lead_state is not null and l_lead_state <> '' and l_lead_postal_code is not null and l_lead_postal_code <> ''
   THEN

    --find Reps for each named account and assign to the lead
    OPEN c_named_accounts FOR query_str;
    FETCH c_named_accounts INTO l_named_account_rec;

        JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_named_account_rec.named_account_id is:'||l_named_account_rec.named_account_id);
        JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('l_named_account_rec.terr_group_id is:'||l_named_account_rec.terr_group_id);

        FOR rs_rec IN c_resources(l_named_account_rec.named_account_id, l_named_account_rec.terr_group_id)
        LOOP
           JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('rs_rec.rsc_group_id is:'||rs_rec.rsc_group_id);
           JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('rs_rec.resource_id is:'||rs_rec.resource_id);

           --create record in JTF_TTY_NAMED_ACCOUNT, JTF_TTY_ACCT_QUAL_MAPS,  JTF_TTY_NAMED_ACCT_RSC
           --so that NA territory is created next time

           JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('calling add_org_to_terrgp');
           /** creates a NA, if one for this party_id does not already exist else
            ** update the existing named account to include postal code as a mapping rule
            **/
           add_org_to_terrgp(p_terr_gp_id   => l_named_account_rec.terr_group_id,
                             p_ref_account_id  => l_named_account_rec.named_account_id,
                             p_party_id     => l_party_Id,
                             p_resource_id  => rs_rec.resource_id,
                             p_role_code => rs_rec.rsc_role_code,
                             p_user_id      => G_USER,
                             p_rsc_group_id => rs_rec.rsc_group_id,
                             p_lead_keyword => l_lead_keyword,
                             p_lead_postal_code => l_lead_postal_code,
                             x_account_id   => l_new_account_id);

        END LOOP;

    END IF;  --end of bug#2878006 fix

JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('End of JTF_TTY_NA_WF.AssignRep');
commit;
 EXCEPTION
  WHEN OTHERS
  THEN
    /*****************************************************************************
    ** Something went wrong return 'ERROR' and set the ERROR_MESSAGE
    *****************************************************************************/
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('ERROR_MESSAGE: '||to_char(SQLCODE)||':'||SQLERRM);
    wf_engine.SetItemAttrText( itemtype => itemtype
                             , itemkey  => itemkey
                             , aname    => 'ERROR_MESSAGE'
                             , avalue   => to_char(SQLCODE)||':'||SQLERRM
                             );

    resultout := 'COMPLETE:ERROR';

END AssignRep;

PROCEDURE add_org_to_terrgp( p_terr_gp_id IN NUMBER,
                             p_ref_account_id IN NUMBER,
                             p_party_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_user_id in NUMBER,
                             p_rsc_group_id IN NUMBER,
                             p_lead_keyword IN VARCHAR2,
                             p_lead_postal_code IN VARCHAR2,
                             x_account_id OUT NOCOPY NUMBER)
AS
 p_site_type_code varchar2(30);
 p_account_count number(30);
 p_rsc_acct_count number(30);
 p_terr_gp_acct_id number(30);
 p_terr_gp_acct_rsc_id number(30);
 p_terr_gp_acct_rsc_dn_id number(30) := 0;
 l_acct_qual_map_id number;

BEGIN
 JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('begin add_org_to_terrgp');

 select count(*)
 into p_account_count
 from jtf_tty_named_accts
 where party_id = p_party_id;

 if p_account_count = 1 then
     select named_account_id
     into x_account_id
     from jtf_tty_named_accts
     where party_id = p_party_id;
 else
-- create a new named account for the party, if one does not exist
 select JTF_TTY_NAMED_ACCTS_S.nextval
 into   x_account_id
 from dual;
 end if;

p_site_type_code := get_site_type_code(p_party_id);

if (p_account_count < 1) then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('create a named account');

      insert into jtf_tty_named_accts
      (NAMED_ACCOUNT_ID,
       OBJECT_VERSION_NUMBER ,
       PARTY_ID       ,
       MAPPING_COMPLETE_FLAG,
       SITE_TYPE_CODE,
       CREATED_BY ,
       CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
      )
      VALUES(x_account_id,
             2,
             p_party_id,
             'N',
             p_site_type_code,
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             p_user_id
      );

       select JTF_TTY_TERR_GRP_ACCTS_S.nextval
       into   p_terr_gp_acct_id
       from dual;

      -- assign a named account for the party to terr gp, if one does not exist

      p_site_type_code := get_site_type_code(p_party_id);

      insert into JTF_TTY_TERR_GRP_ACCTS
      (TERR_GROUP_ACCOUNT_ID,
       OBJECT_VERSION_NUMBER ,
       TERR_GROUP_ID ,
       NAMED_ACCOUNT_ID,
       DN_JNA_MAPPING_COMPLETE_FLAG,
       DN_JNA_SITE_TYPE_CODE,
       DN_JNR_ASSIGNED_FLAG,
       CREATED_BY ,
       CREATION_DATE ,
       LAST_UPDATED_BY ,
       LAST_UPDATE_DATE ,
       LAST_UPDATE_LOGIN
      )
      VALUES(p_terr_gp_acct_id,
             2,
             p_terr_gp_id,
             x_account_id,
             'N',
             p_site_type_code,
             'N',
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             p_user_id
      );

      -- assign resource to the named account

       select jtf_tty_named_acct_rsc_s.nextval
       into   p_terr_gp_acct_rsc_id
       from dual;

      insert into jtf_tty_named_acct_rsc
      (ACCOUNT_RESOURCE_ID,
       OBJECT_VERSION_NUMBER ,
       TERR_GROUP_ACCOUNT_ID,
       RESOURCE_ID ,
       RSC_GROUP_ID,
       RSC_ROLE_CODE,
       ASSIGNED_FLAG       ,
       RSC_RESOURCE_TYPE,
       CREATED_BY ,
       CREATION_DATE ,
       LAST_UPDATED_BY ,
       LAST_UPDATE_DATE ,
       LAST_UPDATE_LOGIN
      )
      VALUES(p_terr_gp_acct_rsc_id,
             2,
             p_terr_gp_acct_id,
             p_resource_id,
             p_rsc_group_id,
             p_role_code,
             'N',
             'RS_EMPLOYEE',
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             p_user_id
      );

      --Insert into denorm table, the resource hierarchy records (similar to those of the candidate resource territory)
      -- ARPATEL 01/30/03
      INSERT INTO jtf_tty_acct_rsc_dn
      (ACCOUNT_RESOURCE_DN_ID,
       OBJECT_VERSION_NUMBER ,
       TERR_GROUP_ACCOUNT_ID,
       RESOURCE_ID ,
       RSC_GROUP_ID,
       ASSIGNED_TO_DIRECT_FLAG,
       RSC_ROLE_CODE,
       RSC_RESOURCE_TYPE,
       CREATED_BY ,
       CREATION_DATE ,
       LAST_UPDATED_BY ,
       LAST_UPDATE_DATE ,
       LAST_UPDATE_LOGIN
      )
      SELECT jtf_tty_acct_rsc_dn_s.nextval,
       1.0 ,
       p_terr_gp_acct_id,
       RESOURCE_ID ,
       RSC_GROUP_ID,
       ASSIGNED_TO_DIRECT_FLAG,
       RSC_ROLE_CODE,
       RSC_RESOURCE_TYPE,
       p_user_id,
       sysdate,
       p_user_id,
       sysdate,
       p_user_id
      FROM  jtf_tty_acct_rsc_dn
      WHERE terr_group_account_id = (select TGA.terr_group_account_id
                                      from JTF_TTY_TERR_GRP_ACCTS TGA
                                     where TGA.named_account_id = p_ref_account_id
                                       and TGA.terr_group_id =  p_terr_gp_id);

      --API to re-create the summation table
      JTF_TTY_NA_TERRGP.sum_accts(p_user_id => p_user_id);

      --create mapping rules for this named account
      create_mapping_rules (p_account_id  => x_account_id
                         ,  p_keyword     => p_lead_keyword
                         ,  p_postal_code => p_lead_postal_code );
      commit;

elsif (p_account_count = 1)
then
  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('p_account_count = 1: Update mapping rules');
  -- Update mapping rules for this existing named account by adding the postal code mapping
  select JTF_TTY_ACCT_QUAL_MAPS_S.nextval
    into l_acct_qual_map_id
    from dual;

   INSERT INTO JTF_TTY_ACCT_QUAL_MAPS
   (account_qual_map_id,
    object_version_number,
    named_account_id,
    qual_usg_id,
    comparison_operator,
    value1_char,
    value2_char,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
    ) VALUES
    (
     l_acct_qual_map_id
   , 2.0
   , x_account_id
   , -1007 --Postal Code
   , '='
   , p_lead_postal_code
   , null
   , G_USER
   , sysdate
   , G_USER
   , sysdate );

end if; --ending if (p_account_count < 1)

  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('end add_org_to_terrgp');
END add_org_to_terrgp;

function get_site_type_code( p_party_id NUMBER ) return varchar2
is
   l_site_type_code  VARCHAR2(30);
   l_chk_done        VARCHAR2(1) := 'N' ;

begin

    hz_common_pub.disable_cont_source_security;

   -- check for global ultimate

    begin

      SELECT 'Y'
        INTO l_chk_done
        FROM DUAL
       WHERE EXISTS ( select 'Y'
                     from hz_relationships hzr
                    where hzr.subject_table_name = 'HZ_PARTIES'
                      and hzr.object_table_name = 'HZ_PARTIES'
                      and hzr.relationship_type = 'GLOBAL_ULTIMATE'
                      and hzr.relationship_code = 'GLOBAL_ULTIMATE_OF'
                      and hzr.status = 'A'
                      and sysdate between hzr.start_date and nvl(hzr.end_date, sysdate)
                      and hzr.subject_id = p_party_id );
    exception
           when no_data_found  then null;
    end;

    IF l_chk_done = 'Y'
    THEN
        l_site_type_code := 'GU' ;
        RETURN l_site_type_code;
    END IF;

    -- check for domestic ultimate

    begin
        SELECT 'Y'
          INTO l_chk_done
          FROM DUAL
         WHERE EXISTS ( select 'Y'
                     from hz_relationships hzr
                    where hzr.subject_table_name = 'HZ_PARTIES'
                      and hzr.object_table_name = 'HZ_PARTIES'
                      and hzr.relationship_type = 'DOMESTIC_ULTIMATE'
                      and hzr.relationship_code = 'DOMESTIC_ULTIMATE_OF'
                      and hzr.status = 'A'
                      and sysdate between hzr.start_date and nvl(hzr.end_date, sysdate)
                      and hzr.subject_id = p_party_id );
    exception
           when no_data_found  then null;
    end;



    IF l_chk_done = 'Y'
    THEN
        l_site_type_code := 'DU' ;
        RETURN l_site_type_code;
    END IF;

    BEGIN

      select lkp.lookup_code
        into l_site_type_code
        from fnd_lookups lkp,
             hz_parties hzp
       where lkp.lookup_type = 'JTF_TTY_SITE_TYPE_CODE'
         and hzp.hq_branch_ind = lkp.lookup_code
         and hzp.party_id = p_party_id;


     EXCEPTION
         when no_data_found then
              l_site_type_code := 'UN';

     END;



     RETURN( l_site_type_code);

exception

   when others then
        null;

end get_site_type_code;

PROCEDURE get_site_type(p_party_id IN Number,
                             x_party_type OUT NOCOPY VARCHAR2)
AS
 site_type_code varchar2(30);
BEGIN
  site_type_code := get_site_type_code(p_party_id);
  select lkp.meaning
  into   x_party_type
  from   fnd_lookups lkp
  where  lkp.lookup_type = 'JTF_TTY_SITE_TYPE_CODE'
  and    lkp.lookup_code = site_type_code;

END get_site_type;

PROCEDURE create_mapping_rules (p_account_id  IN NUMBER
                              , p_keyword     IN VARCHAR2
                              , p_postal_code IN VARCHAR2)
AS
  l_acct_qual_map_id number;
 BEGIN
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('begin create_mapping_rules');

    select JTF_TTY_ACCT_QUAL_MAPS_S.nextval
    into   l_acct_qual_map_id
    from dual;

   INSERT INTO JTF_TTY_ACCT_QUAL_MAPS
   (account_qual_map_id,
    object_version_number,
    named_account_id,
    qual_usg_id,
    comparison_operator,
    value1_char,
    value2_char,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
    ) VALUES
    (
     l_acct_qual_map_id
   , 2.0
   , p_account_id
   , -1012 --Customer Name Range
   , '='
   , p_keyword
   , null
   , G_USER
   , sysdate
   , G_USER
   , sysdate );

   select JTF_TTY_ACCT_QUAL_MAPS_S.nextval
    into   l_acct_qual_map_id
    from dual;

   INSERT INTO JTF_TTY_ACCT_QUAL_MAPS
   (account_qual_map_id,
    object_version_number,
    named_account_id,
    qual_usg_id,
    comparison_operator,
    value1_char,
    value2_char,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
    ) VALUES
    (
     l_acct_qual_map_id
   , 2.0
   , p_account_id
   , -1007 --Postal Code
   , '='
   , p_postal_code
   , null
   , G_USER
   , sysdate
   , G_USER
   , sysdate );

   JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('end create_mapping_rules');

 END create_mapping_rules;



END JTF_TTY_NA_WF;


/
