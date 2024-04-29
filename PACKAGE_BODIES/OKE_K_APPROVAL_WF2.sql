--------------------------------------------------------
--  DDL for Package Body OKE_K_APPROVAL_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_APPROVAL_WF2" AS
/* $Header: OKEWKA2B.pls 120.1.12010000.3 2009/09/30 11:43:18 serukull ship $ */

--
-- Global Variables
--
CR         VARCHAR2(10) := FND_GLOBAL.newline;
BS         VARCHAR2(10) := '&nbsp;';

--
-- Private Functions and Procedures
--

--
-- Public Functions and Procedures
--

--
--  Name          : Contract_Number_Link
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the contract
--                  number with a link to contract flowdown viewer
--
--  Parameters    :
--  IN            : ItemType
--                  ItemKey
--                  ActID
--                  FuncMode
--  OUT NOCOPY /* file.sql.39 change */           : ResultOut ( None )
--
--  Returns       : None
--
PROCEDURE Contract_Number_Link
( Document_ID         IN      VARCHAR2
, Display_Type        IN      VARCHAR2
, Document            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
, Document_Type       IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

ItemType       WF_ITEMS.item_type%TYPE;
ItemKey        WF_ITEMS.item_key%TYPE;

L_K_Header_ID  NUMBER;
L_K_Number     VARCHAR2(240);

FlowdownURL    VARCHAR2(2000);

BEGIN

  ItemType := substr( Document_ID , 1 , instr(Document_ID , ':') - 1 );
  ItemKey  := substr( Document_ID , instr(Document_ID , ':') + 1
                    , length(Document_ID) - 2);

  L_K_Header_ID := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'CONTRACT_ID');
  L_K_Number    := WF_ENGINE.GetItemAttrText(ItemType , ItemKey , 'K_NUMBER');

  IF ( Display_Type = 'text/plain' ) THEN

    Document := 'L_K_Number';

  ELSE

    FlowdownURL := OKE_FLOWDOWN_UTILS.Flowdown_URL
                  ( X_Business_Area => 'APPROVAL'
                  , X_Object_Name   => 'OKE_K_HEADERS'
                  , X_PK1           => L_K_Header_ID
                  , X_PK2           => NULL );

    Document := '<a href="' || FlowdownURL || '">' || L_K_Number || '</a>';
    Document_Type := 'text/html';

  END IF;

END Contract_Number_Link;


--
--  Name          : Show_Approval_History
--  Pre-reqs      : Must be called from WF activity
--  Function      : This PL/SQL document procedure returns the approval
--                  history as maintained in SET_APPROVAL_HISTORY() for
--                  use in various notifications
--
--  Parameters    :
--  IN            : Document_ID ( ItemType:ItemKey )
--                  Display_Type
--                  Document_Type
--  OUT NOCOPY /* file.sql.39 change */           : Document
--                  Document_Type
--
--  Returns       : None
--
PROCEDURE Show_Approval_History
( Document_ID         IN      VARCHAR2
, Display_Type        IN      VARCHAR2
, Document            OUT NOCOPY /* file.sql.39 change */     VARCHAR2
, Document_Type       IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

ItemType       WF_ITEMS.item_type%TYPE;
ItemKey        WF_ITEMS.item_key%TYPE;
DocOut         VARCHAR2(32767);

L_K_Header_ID  NUMBER;

CURSOR h ( C_Header_ID  NUMBER ) IS
  SELECT ah.action_code
  ,      ac.action_name
  ,      ah.action_date
  ,      ah.approver_role_id
  ,      pr.meaning approver_role
  ,      ah.performer
  ,      ah.note
  FROM   oke_approval_history ah
  ,    ( select lookup_code action_code
         ,      meaning     action_name
         from   fnd_lookup_values
         where  view_application_id = 777
         and    lookup_type = 'APPROVAL_ACTION'
         and    language = userenv('LANG') ) ac
  ,      pa_project_role_types pr
  WHERE  ah.k_header_id = C_Header_ID
  AND    ah.chg_request_id IS NULL
  AND    ac.action_code = ah.action_code
  AND    pr.project_role_id (+) = ah.approver_role_id
  ORDER BY action_sequence DESC;
hrec h%rowtype;

CURSOR r ( C_role_name  VARCHAR2 ) IS
  SELECT nvl(p.full_name , u.user_name)
  ,      u.email_address
  FROM   fnd_user u
  ,      per_all_people_f p
  WHERE  u.user_name = C_role_name
  AND    p.person_id = u.employee_id
  AND    trunc(sysdate) BETWEEN p.effective_start_date AND p.effective_end_date;

Performer_Display_Name   VARCHAR2(240);
Performer_Email_Address  VARCHAR2(240);

 l_action_date_text varchar2(100);
 l_user_id number;

BEGIN

  ItemType := substr( Document_ID , 1 , instr(Document_ID , ':') - 1 );
  ItemKey  := substr( Document_ID , instr(Document_ID , ':') + 1
                    , length(Document_ID) - 2);

  L_K_Header_ID := WF_ENGINE.GetItemAttrNumber(ItemType , ItemKey , 'CONTRACT_ID');

  IF ( Display_Type = 'text/plain' ) THEN

    Document := '';

  ELSE
    DocOut := CR || CR || '<!-- SHOW_APPROVAL_HISTORY -->' || CR || CR;
    --
    -- Section Header
    --
    DocOut := DocOut
           || '<table border=0 cellspacing=2 cellpadding=2 width=100%>'
           || '<tr><td class=OraHeader>' || fnd_message.get_string('OKE' , 'OKE_WFNTF_APPROVAL_HISTORY')
           || '</td></tr>' || CR
           || '<tr><td class=OraBGAccentDark></td></tr>' || CR;

    --
    -- Table Header
    --
    DocOut := DocOut || '<tr><td>' || CR;
    DocOut := DocOut
           || '<table class=OraTable border=0 cellspacing=2 cellpadding=2 width=100%>' || CR || '<tr>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=15%>'
           || fnd_message.get_string('OKE' , 'OKE_WFNTF_ACTION')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=20%>'
           || fnd_message.get_string('OKE' , 'OKE_WFNTF_PERFORMER')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=20%>'
           || fnd_message.get_string('OKE' , 'OKE_WFNTF_ROLE')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=15%>'
           || fnd_message.get_string('OKE' , 'OKE_WFNTF_DATE')
           || '</th>' || CR;
    DocOut := DocOut
           || '<th class=OraTableColumnHeader width=30%>'
           || fnd_message.get_string('OKE' , 'OKE_WFNTF_NOTE')
           || '</th>' || CR || '</tr>' || CR;

    select fnd_global.user_id into l_user_id from dual;

    FOR hrec IN h ( L_K_Header_ID ) LOOP

      OPEN r ( hrec.Performer );
      FETCH r INTO Performer_Display_Name , Performer_Email_Address;
      CLOSE r;

      IF ( Performer_Display_Name IS NULL ) THEN
        Performer_Display_Name := hrec.Performer;
      END IF;

      DocOut := DocOut || '<tr>' || CR;
      DocOut := DocOut
             || '<td class=OraTableCellText>'
             || hrec.Action_Name
             || '</td>' || CR;
      IF ( Performer_Email_Address IS NOT NULL ) THEN
        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || '<a href="mailto:' || Performer_Email_Address || '">'
               || Performer_Display_Name || '</a>'
               || '</td>' || CR;
      ELSE
        DocOut := DocOut
               || '<td class=OraTableCellText>'
               || Performer_Display_Name
               || '</td>' || CR;
      END IF;
      DocOut := DocOut
             || '<td class=OraTableCellText>'
             || nvl(hrec.Approver_Role , BS)
             || '</td>' || CR;

      IF ( ( FND_RELEASE.MAJOR_VERSION = 12
        AND FND_RELEASE.minor_version >= 1
        AND FND_RELEASE.POINT_VERSION >= 1 )
        OR  (FND_RELEASE.MAJOR_VERSION > 12)
       )
      THEN
       l_action_date_text := '<BDO DIR="LTR">'
                             || to_char(hrec.Action_Date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', l_user_id),'NLS_CALENDAR = '''
                             || nvl ( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', l_user_id) , 'GREGORIAN' ) || '''')
                             || '</BDO>';

       ELSE
          l_action_date_text := fnd_date.date_to_displaydate(hrec.Action_Date);
       END IF;


      DocOut := DocOut
             || '<td class=OraTableCellText>'
             || l_action_date_text
              || '</td>' || CR;

      DocOut := DocOut
             || '<td class=OraTableCellText>'
             || nvl(hrec.Note , BS)
             || '</td>' || CR || '</tr>' || CR;

    END LOOP;

    DocOut := DocOut
           || '</td></tr></table>' || CR
           || '</table>' || CR || '<p>' || CR;

    Document := DocOut;
    Document_Type := 'text/html';

  END IF;

END Show_Approval_History;


END OKE_K_APPROVAL_WF2;

/
