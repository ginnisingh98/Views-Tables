--------------------------------------------------------
--  DDL for Package Body PO_REQAPPROVAL_INIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQAPPROVAL_INIT1" AS
/* $Header: POXWPA1B.pls 120.56.12010000.78 2014/12/18 11:31:49 linlilin ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
-- Read the profile option that determines whether the promise date will be defaulted with need-by date or not
g_default_promise_date VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('POS_DEFAULT_PROMISE_DATE_ACK'),'N');

g_document_subtype  PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;

--Bug#3497033
--g_currency_format_mask declared to pass in as the second parameter
--in FND_CURRENCY.GET_FORMAT_MASK
g_currency_format_mask NUMBER := 60;

 /*=======================================================================+
 | FILENAME
 |   POXWPA1B.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQAPPROVAL_INIT1
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED    (MM/DD/YY)
 | davidng      06/04/2002      Fix for bug 2401183. Used the Workflow Utility
 |                              Package wrapper function and procedure to get
 |                              and set attributes REL_NUM and REL_NUM_DASH
 |                              in procedure PO_REQAPPROVAL_INIT1.Initialise_Error
 *=======================================================================*/
--

TYPE g_refcur IS REF CURSOR;

-- Bug#3147435
-- Added contractor_requisition_flag and contractor_status to GetRecHdr_csr
Cursor GetRecHdr_csr(p_requisition_header_id NUMBER) RETURN ReqHdrRecord is
  select REQUISITION_HEADER_ID,DESCRIPTION,AUTHORIZATION_STATUS,
         TYPE_LOOKUP_CODE,PREPARER_ID,SEGMENT1,CLOSED_CODE,EMERGENCY_PO_NUM,
         NVL(CONTRACTOR_REQUISITION_FLAG, 'N'),
         NVL(CONTRACTOR_STATUS, 'NULL'), NOTE_TO_AUTHORIZER
  from po_requisition_headers_all
  where REQUISITION_HEADER_ID = p_requisition_header_id;

/*****************************************************************************
* The following are local/Private procedure that support the workflow APIs:  *
*****************************************************************************/


procedure SetReqHdrAttributes(itemtype in varchar2, itemkey in varchar2);

--
procedure SetReqAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure SetPOAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure SetRelAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure UpdtReqItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--
procedure UpdtPOItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--
procedure UpdtRelItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--

procedure GetCanOwnerApprove(itemtype in varchar2,itemkey in varchar2,
                             CanOwnerApproveFlag OUT NOCOPY varchar2);

PROCEDURE InsertActionHistSubmit(itemtype varchar2, itemkey varchar2,
                                 p_doc_id number, p_doc_type varchar2,
                                 p_doc_subtype varchar2, p_employee_id number,
                                 p_action varchar2, p_note varchar2, p_path_id number);

--
-- Bug 3845048 : Added update action history procedure as an autonomous transaction
PROCEDURE UpdateActionHistory(p_doc_id      IN number,
                              p_doc_type    IN varchar2,
                              p_doc_subtype IN varchar2,
                              p_action      IN varchar2
                              ) ;

-- <ENCUMBRANCE FPJ START>

FUNCTION EncumbOn_DocUnreserved(p_doc_type varchar2, p_doc_subtype varchar2,
                                p_doc_id number)
         RETURN varchar2;

-- <ENCUMBRANCE FPJ END>

PROCEDURE   PrintDocument(itemtype varchar2,itemkey varchar2);


-- DKC 10/10/99
PROCEDURE   FaxDocument(itemtype varchar2,itemkey varchar2);


FUNCTION Print_Requisition(p_doc_num varchar2, p_qty_precision varchar,
                           p_user_id varchar2) RETURN number ;

--Bug 6692126 Added p_document_id ,document subtype,with terms ,document type parameters
FUNCTION Print_PO(p_doc_num varchar2, p_qty_precision varchar,
                  p_user_id varchar2, p_document_id number default NULL,
                  p_document_subtype varchar2 default NULL,
                  p_withterms varchar2 default NULL) RETURN number ;

--DKC 10/10/99

--Bug 6692126 Added p_document_id ,document subtype,with terms ,document type parameters
FUNCTION Fax_PO(p_doc_num varchar2, p_qty_precision varchar,
                p_user_id varchar2, p_fax_enable varchar2,
                p_fax_num varchar2,p_document_id number default NULL,
                p_document_subtype varchar2 default NULL,
                p_withterms varchar2 default NULL) RETURN number ;

--Bug 6692126 Added p_document_id ,document subtype,with terms ,document type parameters
FUNCTION Print_Release(p_doc_num varchar2, p_qty_precision varchar,
                       p_release_num varchar2, p_user_id varchar2,
                       p_document_id number default NULL) RETURN number ;


-- DKC 10/10/99

--Bug 6692126 Added p_document_id ,document subtype,with terms ,document type parameters
FUNCTION Fax_Release(p_doc_num varchar2, p_qty_precision varchar,
                p_release_num varchar2, p_user_id varchar2,
                p_fax_enable varchar2, p_fax_num varchar2,
                p_document_id number default NULL) RETURN number ;


procedure CLOSE_OLD_NOTIF(itemtype in varchar2,
                          itemkey  in varchar2);


Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in  number,
				   acceptance_note in varchar2, --18853476
                                   flag                   in  varchar2);

/* added as part of bug 10399957 - deadlock issue during updating comm_rev_num value */
PROCEDURE Set_Comm_Rev_Num(l_doc_type IN VARCHAR2,
                           l_po_header_id IN NUMBER,
                           l_po_revision_num_curr IN NUMBER);
/************************************************************************************
* Added this procedure as part of Bug #: 2843760
* This procedure basically checks if archive_on_print option is selected, and if yes
* call procedure PO_ARCHIVE_PO_SV.ARCHIVE_PO to archive the PO
*************************************************************************************/
procedure archive_po(p_document_id in number,
                                        p_document_type in varchar2,
                                        p_document_subtype in varchar2);

-- <HTML Agreement R12 START>
PROCEDURE unlock_document
( p_po_header_id IN NUMBER
);
-- <HTML Agreement R12 END>

/**************************************************************************************
* The following are the global APIs.                                                  *
**************************************************************************************/

/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: get_diff_in_user_list

  DESCRIPTION   :
  Given a two lists of users, this procedure gives the difference of the two lists.
  The users must be present in the fnd_user table.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_super_set : A string having the list of user names
            Example string: 'GE1', 'GE2', 'GE22'
        p_subset : A list of string having the subset of user names present in the
        previous list.
    Output:
        x_name_list: A list users present in the super set but not in
            subset.
        x_users_count: The number of users in the above list.

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/
PROCEDURE get_diff_in_user_list ( p_super_set in varchar2, p_subset in varchar2 ,
                                  x_name_list out nocopy varchar2,
                                  x_name_list_for_sql out nocopy varchar2,
                                  x_users_count out nocopy number )
IS
l_refcur g_refcur;
l_name_list varchar2(2000);
l_count number;
l_user_name FND_USER.USER_NAME%type;
l_progress varchar2(255);
BEGIN
   l_count := 0;
    open l_refcur for
    'select distinct fu.user_name
    from fnd_user fu
    where fu.user_name in ('|| p_super_set || ')
    and fu.user_name not in (' || p_subset || ')';



    -- Loop through the cursor and construct the
    -- user list.
    LOOP
      fetch l_refcur into l_user_name;
      if l_refcur%notfound then
         exit;
      end if;
      IF l_count = 0 THEN
        l_count := l_count+1;
        x_name_list_for_sql :=  '''' ||l_user_name ||'''';
        x_name_list :=  l_user_name;
       ELSE
        l_count := l_count+1;
        x_name_list_for_sql := x_name_list_for_sql || ', ' || '''' || l_user_name||'''';
        x_name_list := x_name_list || ' ' || l_user_name;
      END IF;
    END LOOP;

    -- If there are no users found simply
    -- send back null.
    if l_count = 0 then
        x_name_list := '  NULL  ';
    end if;
    x_users_count := l_count;

EXCEPTION
 WHEN OTHERS THEN
    x_name_list := null;
        l_progress :=  'PO_REQAPPROVAL_INIT1.get_diff_in_user_list : Failed to get the list of users';
        po_message_s.sql_error('In Exception of get_diff_in_user_list ()', l_progress, sqlcode);
END;
/*******************************************************************
  < Added this function as part of Bug #: 2810150 >
  PROCEDURE NAME: get_wf_role_for_users

  DESCRIPTION   :
  Given a list of users, the procedure looks through the wf_user_roles
  to get a role that has exactly same set of input list of users.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_list_of_users - String containing the list of users
            Example string: 'GE1', 'GE2', 'GE22'
        p_num_users - number of users in the above list
    Output:
        A string containg the role name ( or null , if such role
        does not exist ).

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

FUNCTION get_wf_role_for_users(p_list_of_users IN VARCHAR2, p_num_users IN NUMBER) RETURN VARCHAR2
IS
   l_role_name  WF_USER_ROLES.ROLE_NAME%TYPE;
   l_adhoc      VARCHAR2(10);
   l_progress   VARCHAR2(255);
   l_offset     PLS_INTEGER;
   l_length     PLS_INTEGER;
   l_start      PLS_INTEGER;
   l_end        PLS_INTEGER;
   l_user_name  fnd_user.user_name%TYPE;
   l_count      PLS_INTEGER;

   CURSOR l_cur IS
      SELECT role_name
        FROM (
              SELECT role_name
                FROM wf_user_roles
               WHERE role_name IN
                     (SELECT role_name
                        FROM wf_user_roles
                       WHERE user_name in (SELECT user_name FROM po_wf_user_tmp)
                         AND role_name like 'ADHOC%'
                         AND NVL(EXPIRATION_DATE,SYSDATE+1) > SYSDATE
                       GROUP BY role_name
                      HAVING count(role_name) = p_num_users
                      )
               GROUP BY role_name
              HAVING COUNT(role_name) = p_num_users
              )
       WHERE ROWNUM < 2;
BEGIN

   DELETE po_wf_user_tmp; -- delete rows in the global temp table

   -- split the user names from p_list_of_users and insert them to the
   -- global temp table

   l_offset := 1;
   l_count := 0;

   WHILE TRUE LOOP
      l_start := Instr(p_list_of_users, '''', l_offset);
      IF l_start = 0 THEN
         EXIT;
      END IF;

      l_end := Instr(p_list_of_users, '''', l_start + 1);
      IF l_end = 0 THEN
         EXIT;
      END IF;

      l_user_name := Substr(p_list_of_users, l_start+1, l_end - l_start - 1);
      l_offset := l_end + 1;

      INSERT INTO po_wf_user_tmp (user_name) VALUES (l_user_name);
      l_count := l_count + 1;
   END LOOP;

   IF l_count = 0 OR l_count <> p_num_users THEN
      RETURN NULL;
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO l_role_name;
   IF l_cur%notfound THEN
      l_role_name := NULL;
   END IF;
   CLOSE l_cur;

   DELETE po_wf_user_tmp;
   RETURN l_role_name;

EXCEPTION
   WHEN OTHERS THEN
      l_role_name := null;
      l_progress :=  'PO_REQAPPROVAL_INIT1.get_wf_role_for_users: Failed to get the list of users';
      po_message_s.sql_error('In Exception of get_wf_role_for_users()', l_progress, sqlcode);
END get_wf_role_for_users;

/**
  < Added this function as part of Bug #: 2810150 >
    FUNCTION NAME: get_function_id
    Get the function id given the function name as in FND_FORM_FUNCTIONS table
    String p_function_name - Function name
    Return Number - The function id

    CHANGE History : Created 27-Feb-2003 JPASALA
*/
FUNCTION get_function_id (p_function_name IN VARCHAR2) RETURN NUMBER IS
   CURSOR l_cur IS
      SELECT function_id
        FROM fnd_form_functions
        WHERE function_name = p_function_name;
   l_function_id NUMBER:=0;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_function_id;
   CLOSE l_cur;
   if( l_function_id is null ) then
    l_function_id := -1;
   end if;
   RETURN l_function_id;

EXCEPTION
 WHEN OTHERS THEN
    l_function_id := -1;
    return l_function_id;
END get_function_id;

/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: get_user_list_with_resp

  DESCRIPTION   :
  Given a set of users and and a set of responsibilities,
    this procedures returns a new set of users that are
    assigned atleast one of the responsibilities in the
    given set.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_function_id - function id
        p_namelist - String containing the list of users
            Example string: 'GE1', 'GE2', 'GE22'
    Output:
        x_new_list - list of users that have the given responsibility.
        x_count - number of users in the above list


  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

PROCEDURE get_user_list_with_resp(
    p_function_id IN NUMBER,
    p_namelist IN VARCHAR2,
    x_new_list OUT NOCOPY VARCHAR2,
    x_new_list_for_sql  OUT NOCOPY VARCHAR2,
    x_count out nocopy number)
is
l_refcur g_refcur;
l_first boolean;
l_user_name varchar2(100);
l_count number;
l_progress varchar2(200);
l_f  varchar2 (10);
begin
    l_count := 0;
    l_f := '''' || 'F' || '''';
    open l_refcur for
    'select distinct fu.user_name
    from fnd_user fu, fnd_user_resp_groups furg
    where fu.user_id = furg.user_id
    and furg.responsibility_id in
    (
        SELECT
        responsibility_id
            FROM fnd_responsibility fr
        WHERE menu_id in
            ( SELECT fme.menu_id
          FROM fnd_menu_entries fme
              START WITH fme.function_id ='|| p_function_id ||'
          CONNECT BY PRIOR menu_id = sub_menu_id
            )
        and (end_date is null or end_date > sysdate) '||
        ' and fr.responsibility_id not in (select responsibility_id from fnd_resp_functions
                                                 where action_id= '|| p_function_id ||
                                                 ' and rule_type=' || l_f || ' )' ||

   ' )
    and fu.user_name in (' || p_namelist || ')
    and (furg.end_date is null or furg.end_date > sysdate )' ;




    -- Loop through the cursor and construct the
    -- user list.
    LOOP
      fetch l_refcur into l_user_name;
      if l_refcur%notfound then
         exit;
      end if;
      IF l_count = 0 THEN
         l_count := l_count+1;
         x_new_list_for_sql :=  '''' ||l_user_name ||'''';
         x_new_list := l_user_name;
       ELSE
         l_count := l_count+1;
         x_new_list_for_sql := x_new_list_for_sql || ', ' || '''' || l_user_name||'''';
         x_new_list := x_new_list || ' ' || l_user_name;
      END IF;
    END LOOP;

    -- If there are no users found simply
    -- send back null.
    if l_count = 0 then
        x_new_list := '  NULL  ';
    end if;
    x_count := l_count;

EXCEPTION
 WHEN OTHERS THEN
    x_new_list := ' null ';
        l_progress :=  'PO_REQAPPROVAL_INIT1.get_user_list_with_resp: Failed to get the list of users';
        po_message_s.sql_error('In Exception of get_user_list_with_resp()', l_progress, sqlcode);
end get_user_list_with_resp;
-------------------------------------------------------------------------------
--Start of Comments
--Name: start_wf_process
--Pre-reqs:
--  N/A
--Modifies:
--  N/A
--Locks:
--  None
--Function:
--  Starts a Document Approval workflow process.
--Parameters:
--IN:
--ItemType
--  Item Type of the workflow to be started; if NULL, we will use the default
--  Approval Workflow Item Type for the given DocumentType
--ItemKey
--  Item Key for starting the workflow; if NULL, we will construct a new key
--  from the sequence
--WorkflowProcess
--  Workflow process to be started; if NULL, we will use the default Approval
--  Workflow Process for the given DocumentType
--ActionOriginatedFrom
--  Indicates the caller of this procedure. If 'CANCEL', then the approval will
--  not insert into the action history.
--DocumentID
--  This value for this parameter depends on the DocumentType:
--    'REQUISITION': PO_REQUISITION_HEADERS_ALL.requisition_header_id
--    'PO' or 'PA':  PO_HEADERS_ALL.po_header_id
--    'RELEASE':     PO_RELEASES_ALL.po_release_id
--DocumentNumber
--  (Obsolete) This parameter is ignored. This procedure will derive the
--  document number from DocumentID and DocumentType. (Bug 3284628)
--PreparerID
--  Requester (for Requisitions) or buyer (for other document types)
--  whose approval authority should be used in the approval workflow
--DocumentType
--  'REQUISITION', 'PO', 'PA', 'RELEASE'
--DocumentSubType
--  The value for this parameter depends on the DocumentType:
--    'REQUISITION': PO_REQUISITION_HEADERS_ALL.type_lookup_code
--    'PO' or 'PA':  PO_HEADERS_ALL.type_lookup_code
--    'RELEASE':     PO_RELEASES_ALL.release_type
--SubmitterAction
--  (Unused) This parameter is not currently used.
--ForwardToID
--  Requester (for Requisitions) or buyer (for other document types)
--  that this document is being forwarded to
--ForwardFromID
--  Requester (for Requisitions) or buyer (for other document types)
--  that this document is being forwarded from.
--DefaultApprovalPathID
--  Approval hierarchy to use in the approval workflow
--Note
--  Note to be entered into Action History for this document
--PrintFlag
--  If 'Y', this document will be printed.
--FaxFlag
--  If 'Y', this document will be faxed.
--FaxNumber
--  Phone number that this document will be faxed to
--EmailFlag
--  If 'Y', this document will be emailed.
--EmailAddress
--  Email address that this document will be sent to
--CreateSourcingRule
--  Blankets only: If 'Y', the workflow will create new sourcing rules,
--  rule assignments, and ASL entries.
--ReleaseGenMethod
--  Blankets only: Release Generation Method to use when creating ASL entries
--UpdateSourcingRule
--  Blankets only: If 'Y', the workflow will update existing sourcing rules
--  and ASL entries.
--MassUpdateReleases
--  <RETROACTIVE FPI> Blankets / GAs only: If 'Y', we will update the price
--  on the releases of the blanket or standard POs of the GA with the
--  retroactive price change on the blanket/GA line.
--RetroactivePriceChange
--  <RETROACTIVE FPI> Releases / Standard POs only: If 'Y', indicates that
--  this release/PO has been updated with a retroactive price change.
--  This flag is used to differentiate between approval of releases from
--  the form and from the Mass Update Releases concurrent program.
--OrgAssignChange
--  <GA FPI> Global Agreements only: If 'Y', indicates that an Organization
--  Assignment change has been made to this GA.
--CommunicatePriceChange
--  <RETROACTIVE FPJ> Blankets only: If 'Y', we will communicate any releases
--  or POs that were retroactively priced to the Supplier.
--p_background_flag
--  <DROPSHIP FPJ> If 'Y', we will do the following:
--  1. No database commit
--  2. Change the authorization_status to 'IN PROCESS'.
--  3. Launch the approval workflow with background_flag set to 'Y', so that
--  it blocks immediately at a deferred activity.
--  As a result, the caller can choose to commit or rollback its changes.
--p_Initiator
--  Added for RCO Enhancement changes for R12. RCO will pass this parameter
--  value as : 'SUPPLIER' or 'REQUESTER'. Other callers will pass as NULL
--  value (default). The corresponding value('REQUESTER'/'SUPPLIER') is used
--  to set INITIATOR wf attribute in RCO wf.
--p_xml_flag
--  If 'Y' or 'N', this procedure will update the xml_flag in PO_HEADERS_ALL
--  or PO_RELEASES_ALL accordingly. This is used by HTML Orders. (Bug 5218538)
--  If null, no updates will be made.
--  p_source_type_code VARCHAR2 DEFAULT null
-- For the internal change order for requisitions the value will be INVENTORY

--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Start_WF_Process ( ItemType          VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ActionOriginatedFrom   VARCHAR2,
                             DocumentID             NUMBER,
                             DocumentNumber         VARCHAR2,
                             PreparerID             NUMBER,
                             DocumentTypeCode       VARCHAR2,
                             DocumentSubtype        VARCHAR2,
                             SubmitterAction        VARCHAR2,
                             forwardToID            NUMBER,
                             forwardFromID          NUMBER,
                             DefaultApprovalPathID  NUMBER,
                             Note                   VARCHAR2,
                             PrintFlag              VARCHAR2,
                             FaxFlag                    VARCHAR2,
                             FaxNumber                    VARCHAR2,
                             EmailFlag              VARCHAR2,
                             EmailAddress           VARCHAR2,
                             CreateSourcingRule     VARCHAR2,
                             ReleaseGenMethod       VARCHAR2,
                             UpdateSourcingRule     VARCHAR2,
                             MassUpdateReleases     VARCHAR2,
                             RetroactivePriceChange VARCHAR2,
                             OrgAssignChange        VARCHAR2,   -- GA FPI
                             CommunicatePriceChange VARCHAR2, -- <FPJ Retroactive>
                             p_Background_Flag      VARCHAR2 default 'N', -- <DropShip FPJ>
                             p_Initiator            VARCHAR2 default NULL,
                             p_xml_flag             VARCHAR2 default NULL,
                                                         /* Bug6708182 FPDS-NG ER. */
                                                         /* Added */
                             FpdsngFlag             VARCHAR2 default 'N' ,
			     p_source_type_code VARCHAR2 DEFAULT null,
                                                         /* End Added*/
             		     p_bypass_checks_flag VARCHAR2 DEFAULT 'N', /*AME Project*/
                             p_sourcing_level VARCHAR2 DEFAULT NULL,/*BUG19701485*/
                             p_sourcing_inv_org_id NUMBER DEFAULT NULL /*BUG19701485*/
                                                 )
IS
l_responsibility_id     number;
l_user_id               number;
l_application_id        number;

x_progress              varchar2(300);
x_wf_created            number;
x_orgid                 number;

EmailAddProfile   VARCHAR2(60);


x_acceptance_required_flag      varchar2(1) := null;
x_acceptance_due_date   date;
x_agent_id NUMBER;

x_buyer_username         varchar2(100);
x_buyer_display_name varchar2(240);

l_userkey           varchar2(40);
l_doc_num_rel       varchar2(30);
l_doc_display_name  FND_NEW_MESSAGES.message_text%TYPE; -- Bug 3215186
l_release_num       PO_RELEASES.release_num%TYPE; -- Bug 3215186
l_revision_num      PO_HEADERS.revision_num%TYPE; -- Bug 3215186
l_ga_flag           varchar2(1) := null;  -- FPI GA

/* RETROACTIVE FPI START */
l_seq_for_item_key varchar2(25)  := null; --Bug14305923
l_can_change_forward_from_flag
                po_document_types.can_change_forward_from_flag%type;
l_can_change_forward_to_flag po_document_types.can_change_forward_to_flag%type;
l_can_change_approval_path po_document_types.can_change_approval_path_flag%type;
l_can_preparer_approve_flag po_document_types.can_preparer_approve_flag%type;
l_default_approval_path_id po_document_types.default_approval_path_id%type;
l_can_approver_modify_flag po_document_types.can_approver_modify_doc_flag%type;
l_forwarding_mode_code po_document_types.forwarding_mode_code%type;
l_itemtype po_document_types.wf_approval_itemtype%type;
l_workflow_process po_document_types.wf_approval_process%type;
l_itemkey varchar2(60);
l_type_name po_document_types.type_name%type;

/* RETROACTIVE FPI END */

l_drop_ship_flag po_line_locations.drop_ship_flag%type; -- <DropShip FPJ>
l_conterms_exist_flag     PO_HEADERS_ALL.CONTERMS_EXIST_FLAG%TYPE; --<CONTERMS FPJ>
--bug##3682458 replaced legal entity name with operating unit
l_operating_unit  hr_all_organization_units_tl.name%TYPE; --<POC FPJ>

l_document_number PO_HEADERS_ALL.segment1%TYPE; -- Bug 3284628

l_consigned_flag PO_HEADERS_ALL.CONSIGNED_CONSUMPTION_FLAG%TYPE;
l_autoapprove_retro  varchar2(1);

l_okc_doc_type  varchar2(20);  -- <Word Integration 11.5.10+>
l_vendor po_vendors.vendor_name%type; --Bug 4254468
l_vendor_site_code po_vendor_sites_all.vendor_site_code%type; --Bug 4254468
l_communicatePriceChange VARCHAR2(1); -- bug4176111

/* PO AME Approval workflow change */
-- Start : PO AME Approval workflow
  l_ame_approval_id  NUMBER := NULL;
  l_document_id_temp NUMBER;
  l_ame_transaction_type PO_DOC_STYLE_HEADERS.ame_transaction_type%TYPE := NULL;
  l_itemtype_st po_document_types.wf_approval_itemtype%type := NULL;
  l_workflow_process_st po_document_types.wf_approval_process%type :=NULL;
-- END  : PO AME Approval workflow

emp_user_id              NUMBER;
l_assignment_type_id NUMBER;/*BUG19701485*/
BEGIN


/* DBMS_OUTPUT.enable(10000); */

  x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: at beginning of Start_WF_Process';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  --
  -- Start Process :
  --      - If a process is passed then it will be run
  --      - If a process is not passed then the selector function defined in
  --        item type will be determine which process to run
  --

  /* RETROACTIVE FPI START.
   * Get the itemtype and WorkflowProcess from po_document_types
   * if it is not set.
  */

   --Bug 14601936 - Disabling AME for Planned POs, Local PAs, Releases
   l_ga_flag := null;

   IF DocumentTypeCode = 'PA' THEN
           select global_agreement_flag
           into l_ga_flag
           from po_headers_all
           where po_header_id = DocumentID;
    END IF;

  If ((ItemType is NULL) or (WorkflowProcess is NULL)) then

        po_approve_sv.get_document_types(
                p_document_type_code           => DocumentTypeCode,
                p_document_subtype             => DocumentSubtype,
                x_can_change_forward_from_flag =>l_can_change_forward_from_flag,
                x_can_change_forward_to_flag   => l_can_change_forward_to_flag,
                x_can_change_approval_path     => l_can_change_approval_path,
                x_default_approval_path_id     => l_default_approval_path_id,
                x_can_preparer_approve_flag    => l_can_preparer_approve_flag, -- Bug 2737257
                x_can_approver_modify_flag     => l_can_approver_modify_flag,
                x_forwarding_mode_code         => l_forwarding_mode_code,
                x_wf_approval_itemtype         => l_itemtype,
                x_wf_approval_process          => l_workflow_process,
                x_type_name                    => l_type_name);

        /* PO AME Approval workflow change */
        -- Start : PO AME Approval workflow

        /* Logic : Get ame_transaction_type and workflow process from style headers page.
           If ame_transaction_type is not null for corresponding style, then update base
           po_headers_all table with ame_approval_id (from sequence) and ame_transaction_type.*/


          --IF DocumentTypeCode = 'PO' OR DocumentTypeCode = 'PA' THEN
          IF DocumentSubtype = 'STANDARD'  OR (DocumentTypeCode = 'PA' AND nvl(l_ga_flag,'N') = 'Y') THEN

              -- Get the workflow attributes form Doc styles
             BEGIN
                SELECT ds.wf_approval_itemtype,
                       ds.wf_approval_process,
                       ds.ame_transaction_type,
                       Decode(poh.authorization_status, 'REJECTED', 0,
                                                    poh.ame_approval_id)
                INTO   l_itemtype_st, l_workflow_process_st, l_ame_transaction_type,
                       l_ame_approval_id
                FROM   po_doc_style_headers ds,
                       po_headers_all poh
                WHERE  poh.po_header_id = DocumentID
                       AND poh.style_id = ds.style_id
                 AND ds.ame_transaction_type is not null;

                 IF l_workflow_process_st IS NOT NULL OR l_itemtype_st IS NOT NULL THEN
                   l_itemtype             := l_itemtype_st;
                   l_workflow_process     := l_workflow_process_st;
                 END IF;
             EXCEPTION
               WHEN OTHERS THEN
                  null;
             END;

          END IF;
        -- END  : PO AME Approval workflow
  else
        l_itemtype := ItemType;
        l_workflow_process := WorkflowProcess;

  END IF;

  IF l_ame_transaction_type IS NOT NULL THEN
  --bug 18640598: For AME po approval, every time before workflow start,
  --we should assign new ame_approval_id for the document,
  --no matter the l_ame_approval is null or not null.
     select po_ame_approvals_s.nextval into l_ame_approval_id from dual;

     UPDATE po_headers_all
     SET    ame_approval_id = l_ame_approval_id,
            ame_transaction_type = l_ame_transaction_type
     WHERE  po_header_id = DocumentID;
  END IF;

  If (ItemKey is NULL) then

        select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
        into l_seq_for_item_key
        from sys.dual;

        l_itemkey := to_char(DocumentID) || '-' ||
                                         l_seq_for_item_key;
  else
        l_itemkey := ItemKey;

  END IF;

  /* RETROACTIVE FPI END */

  IF  ( l_itemtype is NOT NULL )   AND
      ( l_itemkey is NOT NULL)     AND
      ( DocumentID is NOT NULL ) THEN

        -- bug 852056: check to see if process has already been created
        -- if it has, don't create process again.
        begin
          select count(*)
          into   x_wf_created
          from   wf_items
          where  item_type = l_itemtype
            and  item_key  = l_itemkey;
        exception
          when others then
            x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: check process existance';
            po_message_s.sql_error('In Exception of Start_WF_Process()', x_progress, sqlcode);
            raise;
        end;

        -- Bug 5218538 START
        -- Update the XML/EDI flags in the database based on p_xml_flag.
        -- Do this before the commit, to avoid deadlock situations.
        IF ((p_xml_flag IS NOT NULL)
            AND
            ((DocumentTypeCode='RELEASE' and DocumentSubtype='BLANKET')
              OR (DocumentTypeCode='PO' and DocumentSubtype='STANDARD'))) THEN

          x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: Updating the xml_flag: ' || p_xml_flag;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);
          END IF;

          IF (p_xml_flag = 'Y') THEN

            IF (DocumentTypeCode = 'RELEASE') THEN
              UPDATE po_releases_all
              SET xml_flag = 'Y',
                  edi_processed_flag = 'N'
              WHERE po_release_id = DocumentID;
            ELSE
              UPDATE po_headers_all
              SET xml_flag = 'Y',
                  edi_processed_flag = 'N'
              WHERE po_header_id = DocumentID;
            END IF;

          ELSIF (p_xml_flag = 'N') THEN

            IF (DocumentTypeCode = 'RELEASE') THEN
              UPDATE po_releases_all
              SET xml_flag = 'N'
              WHERE po_release_id = DocumentID;
            ELSE
              update po_headers_all
              SET xml_flag = 'N'
              WHERE po_header_id = DocumentID;
            END IF;

          END IF; -- p_xml_flag = 'Y'
        END IF; -- p_xml_flag IS NOT NULL
        -- Bug 5218538 END

       --<DropShip FPJ Start>
       --commit only when background flag is not N.
       --Default value is N which will commit to retain behavior of current callers.
       --background flag is passed as 'Y' when called from OM for Drop Ship FPJ, commit not done
       IF p_Background_Flag <> 'Y' THEN
         commit;
       END IF;
       --<DropShip FPJ End>

       if x_wf_created = 0 then
        wf_engine.CreateProcess( ItemType => l_itemtype,
                                 ItemKey  => l_itemkey,
                                 process  => l_workflow_process );
       end if;

        --
        -- Initialize workflow item attributes
        --
        /* get the profile option value for the second Email Address */

        FND_PROFILE.GET('PO_SECONDRY_EMAIL_ADD', EmailAddProfile);

        if NVL(ActionOriginatedFrom, 'Approval') = 'POS_DATE_CHG' then

                wf_engine.SetItemAttrText (     itemtype   => l_itemtype,
                                                itemkey    => l_itemkey,
                                                aname      => 'WEB_SUPPLIER_REQUEST',
                                                avalue     =>  'Y');
        end if;

        --< Bug 3631960 Start >
        /* bug 4621626 : passing ActionOriginatedFrom to INTERFACE_SOURCE_CODE,
           instead of NULL in case of CANCEL, will use the same in the workflow
           to skip the PO_APPROVED notification ,when wf is called from cancel.
         */

        x_progress := 'start wf process called interface source code:'||ActionOriginatedFrom;
        PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);

        IF (ActionOriginatedFrom = 'CANCEL') THEN

            -- If approval workflow is being called from a Cancel action, then
            -- do not insert into action history.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INSERT_ACTION_HIST_FLAG'
                                          , avalue   => 'N'
                                          );
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INTERFACE_SOURCE_CODE'
                                          , avalue   => ActionOriginatedFrom
                                          );
            -- Bug 5701051 We should always bypass the approval hierarchy
            -- for a Cancel action, since the approval workflow is only being
            -- invoked for communication and archival purposes.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    =>
                                            'BYPASS_APPROVAL_HIERARCHY_FLAG'
                                          , avalue   => 'Y'
                                          );
        ELSE

            -- All other cases, we need to insert into action history.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INSERT_ACTION_HIST_FLAG'
                                          , avalue   => 'Y'
                                          );
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INTERFACE_SOURCE_CODE'
                                          , avalue   => ActionOriginatedFrom
                                          );
            -- Bug 5701051 We do not need to bypass the approval hierarchy
            -- for other actions.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    =>
                                            'BYPASS_APPROVAL_HIERARCHY_FLAG'
                                          , avalue   => 'N'
                                          );
        END IF;  --< if ActionOriginatedFrom ... >
        --< Bug 3631960 End >

        IF (p_Initiator IS NOT NULL) THEN

            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INITIATOR'
                                          , avalue   => p_Initiator
                                          );

        END IF;

        --
        wf_engine.SetItemAttrNumber (   itemtype   => l_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'DOCUMENT_ID',
                                        avalue     => DocumentID);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'DOCUMENT_TYPE',
                                        avalue          =>  DocumentTypeCode);
        --

        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'DOCUMENT_SUBTYPE',
                                        avalue          =>  DocumentSubtype);
        --Bug#18416955
        if DocumentTypeCode <> 'RELEASE' then
          po_wf_util_pkg.setitemattrtext
                     (itemtype => l_itemtype
                     ,itemkey  => l_itemkey
                     ,aname    => 'NOTIFICATION_REGION'
                     ,avalue   => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NOTIF&poHeaderId=' || DocumentID);
	  --bug 20040340
          po_wf_util_pkg.setitemattrtext
                     (itemtype => l_itemtype,
                      itemkey  => l_itemkey,
                      aname    => '#HISTORY',
                      avalue   => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NTF_ACTION_DETAILS&poHeaderId=' || DocumentID ||'&showActions=Y');
        end if;

   /* PO AME Approval Changes : Setting workflow attributes ame_transaction_id and ame_transaction_type. */
        -- Start :

	--IF DocumentTypeCode = 'PO' OR DocumentTypeCode = 'PA' THEN
	 IF DocumentSubtype = 'STANDARD'  OR (DocumentTypeCode = 'PA' AND nvl(l_ga_flag,'N') = 'Y') THEN

        	po_wf_util_pkg.setitemattrNumber(   itemtype   => l_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'AME_TRANSACTION_ID',
                                        avalue     => l_ame_approval_id);

                po_wf_util_pkg.setitemattrtext (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'AME_TRANSACTION_TYPE',
                                        avalue          =>  l_ame_transaction_type);

  	      if l_ame_transaction_type is not NULL THEN

  	        x_progress :=  'PO_REQAPPROVAL_INIT1.setting notifictaion regions ' ;

       	         IF (g_po_wf_debug = 'Y') THEN
      	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);
        	  END IF;

	      po_wf_util_pkg.setitemattrtext
                     (itemtype => l_itemtype
                     ,itemkey  => l_itemkey
                     ,aname    => 'NOTIFICATION_REGION'
                     ,avalue   => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NOTIF&poHeaderId=' || DocumentID);


              po_wf_util_pkg.setitemattrtext(itemtype => l_itemtype,
                                              itemkey  => l_itemkey,
                                              aname    => '#HISTORY',
                                              avalue => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NTF_ACTION_DETAILS&poHeaderId=' || DocumentID ||
                                                         '&ameTransactionType=' ||  l_ame_transaction_type ||
                                                         '&ameTransactionId=' || l_ame_approval_id ||
                                                         '&showActions=Y');

               po_wf_util_pkg.setitemattrtext(itemtype => l_itemtype,
                                              itemkey  => l_itemkey,
                                              aname    => '#HISTORY_SUPP',
                                              avalue => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NTF_ACTION_DETAILS&poHeaderId=' || DocumentID || '&showActions=N');

		END if;

      END IF;
	-- END  PO AME Approval Changes

--<POC FPJ>
  g_document_subtype := DocumentSubtype;
        --
        wf_engine.SetItemAttrNumber (   itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'PREPARER_ID',
                                        avalue          => PreparerID);
        --
        wf_engine.SetItemAttrNumber (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_TO_ID',
                                        avalue          =>  ForwardToID);
        --

/* Bug# 2308846: kagarwal
** Description: The forward from user was always set to the preparer
** in the Approval process. Hence if the forward from user was
** different from the preparer, the forward from was showing
** wrong information.
**
** Fix Details: Modified the procedure Start_WF_Process() and
** Set_Startup_Values() to set the forward from attributes
** correctly.
*/

        if (forwardFromID is not NULL) then
          wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  forwardFromID);

        else
          wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  forwardFromID);
        end if;

        --
        wf_engine.SetItemAttrNumber (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'APPROVAL_PATH_ID',
                                        avalue          =>  DefaultApprovalPathID);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'NOTE',
                                        avalue          =>  Note);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'PRINT_DOCUMENT',
                                        avalue          =>  PrintFlag);

        PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'JUSTIFICATION',
                                        avalue          =>  Note);

       IF (DocumentTypeCode = 'REQUISITION') THEN

 	        SELECT PRH.segment1
 	        INTO l_document_number
 	        FROM po_requisition_headers PRH
 	        WHERE PRH.requisition_header_id = DocumentID;

 	         BEGIN
 	         wf_engine.SetItemUserKey(itemtype        => l_itemtype,
 	                                  itemkey         => l_itemkey,
 	                                  userkey         => l_document_number);

 	         EXCEPTION
 	           when others then
 	               null;
 	         END;

        END IF;
        -- DKC 10/13/99
        IF DocumentTypeCode IN ('PO', 'PA', 'RELEASE') THEN

                /* Bug6708182 FPDS-NG ER. */
                /* Bug 6708182 Start */
                IF DocumentTypeCode IN ('PO', 'RELEASE') THEN

                        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                                                                        itemkey         => l_itemkey,
                                                                                        aname           => 'FPDSNG_FLAG',
                                                                                        avalue          =>  FpdsngFlag);
                END IF;
                /* Bug 6708182 End */

           if DocumentTypeCode <> 'RELEASE' then

           SELECT poh.acceptance_required_flag,
                  poh.acceptance_due_date,
                  poh.agent_id
           into   x_acceptance_required_flag,
                  x_acceptance_due_date,
                  x_agent_id
           from po_headers  poh
           where poh.po_header_id = DocumentID;

         ELSE

           SELECT por.acceptance_required_flag,
                  por.acceptance_due_date, por.agent_id
             into      x_acceptance_required_flag,
                     x_acceptance_due_date,
                     x_agent_id
                from po_releases por,
                     po_headers_all  poh  -- <R12 MOAC>
                where por.po_release_id = DocumentID
                     and   por.po_header_id = poh.po_header_id;


        END IF;

        wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                    itemkey  => l_itemkey,
                                    aname    => 'ACCEPTANCE_REQUIRED',
                                    avalue   => x_acceptance_required_flag);

        wf_engine.SetItemAttrDate ( itemtype => l_itemtype,
                                    itemkey  => l_itemkey,
                                    aname    => 'ACCEPTANCE_DUE_DATE',
                                    avalue   => x_acceptance_due_date);

        /*
        Bug 14078118
        Changed 'BUYER_USER_ID' to the actual 'user id' of the buyer. Agent Id points to the employee ID.
        */
        BEGIN
                select user_id
                into emp_user_id
                from fnd_user
                where employee_id = x_agent_id
                and rownum = 1
                and sysdate < nvl(end_date, sysdate + 1);
        EXCEPTION
        WHEN OTHERS THEN
                null;
        END;

        wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
                                      itemkey  => l_itemkey,
                                      aname    => 'BUYER_USER_ID',
                                      avalue   => emp_user_id);

     if (DocumentTypeCode in ('PO', 'PA')) then

        /* FPI GA Start */

        -- <GC FPJ>
        -- Pass ga flag to the wf for all PA documents (BLANKET and CONTRACT)

        -- IF DocumentTypeCode = 'PA' AND DocumentSubtype = 'BLANKET' THEN

         IF DocumentTypeCode = 'PA' THEN

           PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype    => l_itemtype,
                                         itemkey     => l_itemkey,
                                         aname       => 'GLOBAL_AGREEMENT_FLAG',
                                         avalue      =>  l_ga_flag);
         END IF;
         /* FPI GA End */

       /* bug 2115200 */
       /* Added logic to derive the doc display name */
       --CONTERMS FPJ Extracting Contract Terms value in this Query as well
        select revision_num,
               DECODE(TYPE_LOOKUP_CODE,
                 'BLANKET',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_BLKT'),
                 'CONTRACT',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_CNTR'),
                 'STANDARD',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_STD'),
                 'PLANNED',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_PLND')),
               NVL(CONTERMS_EXIST_FLAG,'N'), --<CONTERMS FPJ>
               segment1 -- Bug 3284628
        into l_revision_num,
             l_doc_display_name,
             l_conterms_exist_flag, --<CONTERMS FPJ>
             l_document_number -- Bug 3284628
        from po_headers
        where po_header_id = DocumentID;

      l_doc_num_rel := l_document_number;

      --<CONTERMS FPJ Start>
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype    => l_itemtype,
                                      itemkey     => l_itemkey,
                                      aname       => 'CONTERMS_EXIST_FLAG',
                                      avalue      =>  l_conterms_exist_flag);
      --<CONTERMS FPJ END>

      /* FPI GA Start */
       if l_ga_flag = 'Y' then
         l_doc_display_name := FND_MESSAGE.GET_STRING('PO','PO_GA_TYPE');
       end if;
      /* FPI GA End */

     elsif (DocumentTypeCode = 'RELEASE') then

       -- Bug 3859714. Workflow attribute WITH_TERMS should be set to 'N' for
       -- a Release because a release will not have Terms.
       l_conterms_exist_flag := 'N';

       /* bug 2115200 */
        select POR.revision_num,
               POR.release_num,
               DECODE(POR.release_type,
                 'BLANKET', FND_MESSAGE.GET_STRING('POS','POS_POTYPE_BLKTR'),
                 'SCHEDULED',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_PLNDR')),
               POH.segment1 -- Bug 3284628
        into l_revision_num,
             l_release_num,
             l_doc_display_name,
             l_document_number -- Bug 3284628
        from po_releases POR,
             po_headers_all POH  -- <R12 MOAC>
        where POR.po_release_id = DocumentID
        and   POR.po_header_id = POH.po_header_id; -- JOIN

        l_doc_num_rel := l_document_number || '-' || l_release_num;


     END IF; -- DocumentTypeCode


/* Bug# 2474660: kagarwal
** Desc: Setting the item user key for all documents.
** The item user key will be the document number for PO/PA/Requisitions
** and BPA Number - Release Num for releases.
*/


     if (DocumentTypeCode = 'RELEASE') then
        l_userkey := l_doc_num_rel;
     else
        l_userkey := l_document_number; -- Bug 3284628
     end if;

     BEGIN
        wf_engine.SetItemUserKey(itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 userkey         => l_userkey);

     EXCEPTION
       when others then
          null;
     END;

     -- bug4176111
     -- The default of communicate price change should be 'Y' for Standard PO
     -- /Releases, and 'N' for everything else
     l_communicatePriceChange := CommunicatePriceChange;

     IF (l_CommunicatePriceChange IS NULL) THEN
       IF (DocumentTypeCode='RELEASE' and DocumentSubtype='BLANKET')
              OR (DocumentTypeCode='PO' and DocumentSubtype='STANDARD') THEN

         l_communicatePriceChange := 'Y';
       ELSE
         l_communicatePriceChange := 'N';
       END IF;
     END IF;




      -- Bug 3284628 START
      wf_engine.SetItemAttrText (   itemtype   => l_itemtype,
                                      itemkey    => l_itemkey,
                                      aname      => 'DOCUMENT_NUMBER',
                                      avalue     => l_document_number);
      -- Bug 3284628 END

      /* bug 2115200 */

      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'DOCUMENT_NUM_REL',
                                 avalue          =>  l_doc_num_rel);

      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'REVISION_NUMBER',
                                 avalue          =>  l_revision_num);
      --Bug 16448690
      wf_engine.SetItemAttrNumber (itemtype      => l_itemtype,
                                   itemkey       => l_itemkey,
				   aname         => 'PO_REVISION_NUM',
				   avalue        => l_revision_num);
      IF (DocumentTypeCode = 'PA' AND DocumentSubtype IN ('BLANKET','CONTRACT')) OR
         (DocumentTypeCode = 'PO' AND DocumentSubtype = 'STANDARD')  THEN

            l_doc_display_name := PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(DocumentID);

      END IF;

      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'DOCUMENT_DISPLAY_NAME',
                                 avalue          =>  l_doc_display_name);



        if x_agent_id is not null then

                x_progress := '003';

                -- Get the buyer user name


                  WF_DIRECTORY.GetUserName(  'PER',
                                           x_agent_id,
                                            x_buyer_username,
                                           x_buyer_display_name);
                x_progress := '004';

                wf_engine.SetItemAttrText (           itemtype => l_itemtype,
                                                      itemkey  => l_itemkey,
                                                      aname    => 'BUYER_USER_NAME',
                                                      avalue   => x_buyer_username);
        end if;


          --DKC 10/10/99
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'FAX_DOCUMENT',
                                          avalue          =>  FaxFlag);
          --DKC 10/10/99
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'FAX_NUMBER',
                                          avalue          =>  FaxNumber);


          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_DOCUMENT',
                                          avalue          =>  EmailFlag);

          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_ADDRESS',
                                          avalue          =>  EmailAddress);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_ADD_FROM_PROFILE',
                                          avalue          =>  EmailAddProfile);


            wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'CREATE_SOURCING_RULE',
                                          avalue          =>  createsourcingrule);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'UPDATE_SOURCING_RULE',
                                          avalue          =>  updatesourcingrule);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'RELEASE_GENERATION_METHOD',
                                          avalue          =>  ReleaseGenMethod);
            /*BUG19701485 BEGIN*/
            IF (createsourcingrule = 'Y' OR updatesourcingrule = 'Y') THEN
              IF NVL(p_sourcing_level,'ITEM')='ITEM' THEN
                l_assignment_type_id :=3;
              ELSIF p_sourcing_level ='ITEM-ORGANIZATION' THEN
                l_assignment_type_id :=6;
              END IF;
              wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                          itemkey => l_itemkey,
            	                          aname => 'PO_SR_ASSIGNMENT_TYPE_ID',
            			          avalue => l_assignment_type_id);

              wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                          itemkey => l_itemkey,
            				  aname => 'PO_SR_ORGANIZATION_ID',
            			          avalue => p_sourcing_inv_org_id);
            END IF;
            /*BUG19701485 END*/


            /* RETROACTIVE FPI START */
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'MASSUPDATE_RELEASES',
                                          avalue       =>  MassUpdateReleases);

            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_R_RETRO_CHANGE',
                                          avalue       =>  RetroactivePriceChange);
            /* RETROACTIVE FPI  END */

            /* GA FPI start */
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'GA_ORG_ASSIGN_CHANGE',
                                          avalue       =>  OrgAssignChange);
            /* GA FPI End */

            -- <FPJ Retroactive START>
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_H_RETROACTIVE_SUPPLIER_COMM',
                                          avalue       =>  l_communicatePriceChange);  -- bug4176111
            -- <FPJ Retroactive END>

            --<DropShip FPJ Start>
            PO_WF_UTIL_PKG.SetItemAttrText(itemtype    => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'BACKGROUND_FLAG',
                                          avalue       =>  p_background_flag);

            -- l_drop_ship_flag indicates if current Release/PO has any DropShip Shipments
            BEGIN
              l_drop_ship_flag := 'N';

              IF DocumentTypeCode = 'RELEASE' THEN
                select 'Y'
                into l_drop_ship_flag
                from dual
                where exists
                 (select 'Release DropShip Shipment Exists'
                  from po_line_locations
                  where po_release_id = DocumentId
                  and drop_ship_flag = 'Y');

              ELSIF DocumentTypeCode = 'PO' THEN
                select 'Y'
                into l_drop_ship_flag
                from dual
                where exists
                 (select 'PO DropShip Shipment Exists'
                  from po_line_locations
                  where po_header_id = DocumentId
                  and drop_ship_flag = 'Y');
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_drop_ship_flag := 'N';
            END;

            -- Workflow Attribute DROP_SHIP_FLAG added for any customizations to refer to it.
            -- Base Purchasing code does NOT refer to DROP_SHIP_FLAG attribute
            PO_WF_UTIL_PKG.SetItemAttrText(itemtype    => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'DROP_SHIP_FLAG',
                                          avalue       =>  l_drop_ship_flag);
            --<DropShip FPJ End>

            -- Bug 3318625 START
            -- Set the autoapprove attribute for retroactively priced consumption
            -- advices so that they are always routed through change order skipping
            -- the authority checks
            BEGIN
              l_consigned_flag := 'N';

             IF DocumentTypeCode = 'RELEASE' THEN
                select  NVL(consigned_consumption_flag, 'N') -- Bug 3318625
                into    l_consigned_flag
                from   po_releases_all
                where  po_release_id = DocumentId;
              ELSIF DocumentTypeCode = 'PO' THEN
                select  NVL(consigned_consumption_flag, 'N')
                into    l_consigned_flag
                from   po_headers_all
                where  po_header_id = DocumentId;
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_consigned_flag := 'N';
            END;

            IF l_consigned_flag = 'Y' THEN
               l_autoapprove_retro := 'Y';

               PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_H_RETROACTIVE_AUTOAPPROVAL',
                                          avalue       =>  l_autoapprove_retro);
            END IF;

            -- Bug 3318625 END

        /* Get the multi-org context and store it in item attribute ORG_ID. This will be
        ** By all other activities.
        */
        PO_REQAPPROVAL_INIT1.get_multiorg_context (DocumentTypeCode, DocumentID, x_orgid);

        IF x_orgid is NOT NULL THEN

          PO_MOAC_UTILS_PVT.set_org_context(x_orgid) ;       -- <R12 MOAC>

          /* Set the Org_id item attribute. We will use it to get the context for every activity */
          wf_engine.SetItemAttrNumber (   itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'ORG_ID',
                                          avalue          => x_orgid);

        END IF;


         -- DKC 02/06/01
         wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_EMAIL_HEADER',
                                          avalue         => 'PLSQL:PO_EMAIL_GENERATE.GENERATE_HEADER/'|| l_itemtype || ':' || l_itemkey); --<BUG 9891660 Passing Itemtype and itemkey>


         -- DKC 02/06/01
         wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_EMAIL_BODY',
                                          avalue           => 'PLSQLCLOB:PO_EMAIL_GENERATE.GENERATE_HTML/'|| l_itemtype || ':' || l_itemkey); --<BUG 9891660 Passing Itemtype and itemkey>

          /* set the terms and conditions read from a file */
                        --EMAILPO FPH--
                        -- GENERATE_TERMS is changed to take itemtype and itemkey instead of DocumentID and DocumentTypeCode
                        -- as itemtype and itemkey are necessary for retrieving the profile options
                        -- Upgrade related issues are handled in PO_EMAIL_GENERATE.GENERATE_TERMS procedure
          /* Bug 2687751. When we refactored start_wf_process, we defaulted
           * item type and item key and changed all the occurences of
           * itemkey to use local variable l_itemkey. This was left out in the
           * SetItemAttrText for PO_TERMS_CONDITIONS. Changing this as part
           * of bug 2687751.
          */
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_TERMS_CONDITIONS',
                                          avalue           => 'PLSQLCLOB:PO_EMAIL_GENERATE.GENERATE_TERMS/'|| l_itemtype || ':' || l_itemkey);

        END IF;
--<Bug 4254468 Start> Need to show supplier and operating unit in
-- PO Approval notifications

   BEGIN
      if DocumentTypeCode <> 'RELEASE' then
              select pov.vendor_name,
                     pvs.vendor_site_code
              into l_vendor,
                   l_vendor_site_code
              from po_vendors pov,po_headers poh,po_vendor_sites_all pvs
              where pov.vendor_id    = poh.vendor_id
              and poh.po_header_id   = DocumentId
              and poh.vendor_site_id = pvs.vendor_site_id;
      else
              select pov.vendor_name,
                     pvs.vendor_site_code
              into l_vendor,
                   l_vendor_site_code
              from po_releases por,po_headers poh,
                   po_vendors pov,po_vendor_sites_all pvs
              where por.po_release_id = DocumentId
              and por.po_header_id    = poh.po_header_id
              and poh.vendor_id       = pov.vendor_id
              and poh.vendor_site_id  = pvs.vendor_site_id;
      end if;
   EXCEPTION
      WHEN OTHERS THEN
         --In case of any exception, the supplier will show up as null
         null;
   END;

   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => l_vendor);

   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'SUPPLIER_SITE',
                                   avalue   => l_vendor_site_code);

   --Brought the following code out of POC FPJ block
   --Need to display the Legal Entity Name on the Notification Subject

   IF  x_orgid is not null  THEN
      --bug#3682458 replaced the sql that retrieves legal entity
      --name with sql that retrieves operating unit name
      BEGIN
         SELECT hou.name
         into   l_operating_unit
         FROM
                hr_organization_units hou
         WHERE
                hou.organization_id = x_orgid;
      EXCEPTION
         WHEN OTHERS THEN
            l_operating_unit:=null;
      END;
   END IF;

   --bug#3682458 replaced legal_entity_name with operating_unit_name
   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'OPERATING_UNIT_NAME',
                                  avalue=>l_operating_unit);
--<Bug 4254468 End>

--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
--Bug#18301844, when output format is PDF type need set below attributes,
--no need check AME Transaction Type
IF PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' THEN
   --AND l_ame_transaction_type is not NULL THEN  --Bug 17884758, PM require the AME support Text.
   --OR  l_ame_transaction_type is not NULL THEN -- PO AME Project

PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                itemkey         => l_itemkey,
                                aname           => 'WITH_TERMS',
                                avalue          =>l_conterms_exist_flag);

PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                itemkey         => l_itemkey,
                                aname           => 'LANGUAGE_CODE',
                                avalue          =>userenv('LANG'));

PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'EMAIL_TEXT_WITH_PDF',
                      avalue=>FND_MESSAGE.GET_STRING('PO','PO_PDF_EMAIL_TEXT'));

PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PO_PDF_ERROR',
                      avalue=>FND_MESSAGE.GET_STRING('PO','PO_PDF_ERROR'));

PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT_BUYER',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH_APP/'|| l_itemtype||':'||l_itemkey);

-- Bug 3851357. Replaced PDF_ATTACH_SUPP with PDF_ATTACH so that the procedure
-- PO_COMMUNICATION_PKG.PDF_ATTACH is consistently called for all Approval PDF
-- supplier notifications
PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT_SUPP',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH/'|| l_itemtype||':'||l_itemkey);

PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH/'||l_itemtype||':'||l_itemkey);


  -- <Start Word Integration 11.5.10+>
  -- <Set up okc doc attachmetn attribute, if necessary>
  IF (l_conterms_exist_flag = 'Y')
  THEN

    l_okc_doc_type := PO_CONTERMS_UTL_GRP.get_po_contract_doctype(DocumentSubtype);

    IF ( ('STRUCTURED' <> OKC_TERMS_UTIL_GRP.get_contract_source_code(p_document_type => l_okc_doc_type
                                                                    , p_document_id => DocumentID))
          AND
         ('N' = OKC_TERMS_UTIL_GRP.is_primary_terms_doc_mergeable(p_document_type => l_okc_doc_type
                                                                , p_document_id => DocumentID))
       )
    THEN

      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                      itemkey => l_itemkey,
                                      aname => 'OKC_DOC_ATTACHMENT',
                                      avalue =>
                               'PLSQLBLOB:PO_COMMUNICATION_PVT.OKC_DOC_ATTACH/'||
                                    l_itemtype||':'||l_itemkey);

    END IF;  -- not structured and not mergeable

    -- <Start Contract Dev. Report 11.5.10+>: Set up attachments links region.
    -- create attchment with actual l revision number instead of -99
    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'PO_OKC_ATTACHMENTS',
                                   avalue   =>
                         'FND:entity=OKC_CONTRACT_DOCS'
                         || '&' || 'pk1name=BusinessDocumentType'
                         || '&' || 'pk1value=' || DocumentTypeCode || '_' || DocumentSubtype
                         || '&' || 'pk2name=BusinessDocumentId'
                         || '&' || 'pk2value=' || DocumentID
                         || '&' || 'pk3name=BusinessDocumentVersion'
                         || '&' || 'pk3value=' || '-99'
                         || '&' || 'categories=OKC_REPO_CONTRACT,OKC_REPO_APP_ABSTRACT');
    -- <End Contract Dev. Report 11.5.10+>


  END IF; -- l_conterms_exist_flag = 'Y'
  -- <End Word Integration 11.5.10+>

END IF;
--<POC FPJ End>
        IF DocumentTypeCode = 'REQUISITION'  AND p_source_type_code = 'INVENTORY'  THEN
               wf_engine.SetItemAttrText ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'SOURCE_TYPE_CODE',
                                      avalue          =>  p_source_type_code);

       END IF;

        -- R12 PO change Order tolerances ECO : 4716963
        -- Retrive the tolerances from the new PO tolerances table and
        -- set the corresponding workflow attributes if the values in
        -- the table are not null.
        IF DocumentTypeCode = 'PO' THEN
          PO_CHORD_WF6.Set_Wf_Order_Tol(l_itemtype, l_itemkey , DocumentSubtype);
        ELSIF DocumentTypeCode = 'PA' THEN
          PO_CHORD_WF6.Set_Wf_Agreement_Tol(l_itemtype, l_itemkey , DocumentSubtype);
        ELSIF DocumentTypeCode = 'RELEASE' THEN
          PO_CHORD_WF6.Set_Wf_Release_Tol(l_itemtype, l_itemkey , DocumentSubtype);
        END IF;

        x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: Before call to FND_PROFILE';
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);
        END IF;

        /* Get the USER_ID and the RESPONSIBLITY_ID for the current forms session.
        ** This will be used in later calls to APPS_INITIALIZE(), before calling
        ** the Document Manager.
        */

       if (x_wf_created = 0) then
        --FND_PROFILE.GET('USER_ID', l_user_id);
        --FND_PROFILE.GET('RESP_ID', l_responsibility_id);
        --FND_PROFILE.GET('RESP_APPL_ID', l_application_id);


        l_responsibility_id := fnd_global.resp_id;
        l_application_id := fnd_global.resp_appl_id;
        /*Bug 10418763 If the PO approval is launched from create doc flow then
 	  set the user_id to the buyer_id on the PO rather than the current
 	  session user_id */

 	                    BEGIN
 	                      IF (ActionOriginatedFrom = 'CREATEDOC')  THEN
 	                         select user_id
 	                           into l_user_id
 	                         from fnd_user
 	                         where employee_id = PreparerID;
 	                      ELSE
 	                  l_user_id := fnd_global.user_id;
 	                      END IF;
 	                  EXCEPTION
 	                  WHEN OTHERS THEN
 	                     l_user_id := fnd_global.user_id;
 	                  END;
 	              /*Bug 10418763 end */

        IF (l_user_id = -1) THEN
            l_user_id := NULL;
        END IF;

        IF (l_responsibility_id = -1) THEN
            l_responsibility_id := NULL;
        END IF;

        IF (l_application_id = -1) THEN
            l_application_id := NULL;
        END IF;


        /* l_application_id := 201; */
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'USER_ID',
                                      avalue          =>  l_user_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'APPLICATION_ID',
                                      avalue          =>  l_application_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'RESPONSIBILITY_ID',
                                      avalue          =>  l_responsibility_id);

        /* Set the context for the doc manager */
        fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);
                -- bug fix 2424044
                IF x_orgid is NOT NULL THEN
                  PO_MOAC_UTILS_PVT.set_org_context(x_orgid) ;       -- <R12 MOAC>
                END IF;
       end if;


       --<DropShip FPJ Start>
       -- When background flag is 'Y' the approval workflow blocks at a background activity
       -- set authorization_status to IN PROCESS so that the header is 'locked'
       -- while the workflow process is waiting for background engine to pick it up

       IF p_background_flag = 'Y' THEN
           IF DocumentTypeCode = 'RELEASE' THEN
               update po_releases
               set AUTHORIZATION_STATUS = 'IN PROCESS',
               last_updated_by      = fnd_global.user_id,
               last_update_login    = fnd_global.login_id,
               last_update_date     = sysdate
               where po_release_id  = DocumentID;
           ELSE --PO or PA
               update po_headers
               set AUTHORIZATION_STATUS = 'IN PROCESS',
               last_updated_by         = fnd_global.user_id,
               last_update_login       = fnd_global.login_id,
               last_update_date        = sysdate
               where po_header_id      = DocumentID;
           END IF;
       END IF; -- END of IF p_background_flag = 'Y'

            --<DropShip FPJ End>

     /*AME Project*/
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype, itemkey => l_itemkey, aname => 'BYPASS_CHECKS_FLAG', avalue => p_bypass_checks_flag);

        x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: Before  call to wf_engine.StartProcess()' ||
                       ' parameter DefaultApprovalPathID= ' || to_char(DefaultApprovalPathID);
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,l_itemkey,x_progress);
        END IF;

        --bug19627524  added for deadlock issue causing by scheduled
        --             workflow_background_process catch the defered
        --             PDOI approval workflow
        IF ActionOriginatedFrom in ('PDOI','PDOI_AUTO_APPROVE') THEN
          commit;
        END IF;
        --bug19627524

        --
        wf_engine.StartProcess(         itemtype        => l_itemtype,
                                        itemkey         => l_itemkey );

    END IF;

EXCEPTION
 WHEN OTHERS THEN

   x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: In Exception handler';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,l_itemkey,x_progress);
   END IF;

   po_message_s.sql_error('In Exception of Start_WF_Process()', x_progress, sqlcode);

   RAISE;

END Start_WF_Process;


-- SetStartupValues
--  Iinitialize/assigns startup values to workflow attributes.
--
-- IN
--   itemtype, itemkey, actid, funcmode
-- OUT
--   Resultout
--    - Completed   - Activity was completed without any errors.
--
procedure Set_Startup_Values(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_doc_subtype   varchar2(25);
l_document_id   number;

l_preparer_id number;
x_username    varchar2(100);
x_user_display_name varchar2(240);
x_ff_username    varchar2(100);
x_ff_user_display_name varchar2(240);
x_ft_username    varchar2(100);
x_ft_user_display_name varchar2(240);
l_forward_to_id     number;
l_forward_from_id   number;
l_authorization_status varchar2(25);
l_open_form         varchar2(200);
l_update_req_url    varchar2(1000);
l_open_req_url    varchar2(1000);
l_resubmit_req_url    varchar2(1000);    -- Bug 636924, lpo, 03/31/98
--Bug#3147435
--Variables for VIEW_REQ_DTLS_URL, EDIT_REQ_URL and RESUBMIT_REQ_URL
l_view_req_dtls_url varchar2(1000);
l_edit_req_url varchar2(1000);
l_resubmit_url varchar2(1000);
l_error_msg       varchar2(200);
l_review_msg varchar2(200);   -- PO AME Project
x_orgid     number;

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_po_revision number;

l_interface_source      VARCHAR2(30);
l_can_modify_flag       VARCHAR2(1);

l_view_po_url varchar2(1000);   -- HTML Orders R12
l_edit_po_url varchar2(1000);   -- HTML Orders R12
l_style_id    po_headers_all.style_id%TYPE;
l_ga_flag     po_headers_all.global_agreement_flag%TYPE;

/*  Bug 7535468
    Increasing the length of x_progress from 200 to 1200 */
x_progress  varchar2(1200);

--Context Setting Revamp
l_printer     VARCHAR2(30);
l_conc_copies number;
l_conc_save_output varchar2(1);
--Bug 6164753
l_external_url varchar2(500);

--Added by Eric Ma for IL PO Notification on Apr-13,2009,Begin
---------------------------------------------------------------------------
lv_tax_region        varchar2(30);        --tax region code
---------------------------------------------------------------------------
--Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End
BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_Startup_Values: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */

  --Context Setting Revamp
  /* PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */

  -- Set the multi-org context

  x_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF x_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(x_orgid) ;       -- <R12 MOAC>

  END IF;

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  /* Since we are just starting the workflow assign the preparer_id to
  ** variable APPROVER_EMPID. This variable always holds the
  ** employee id of the approver i.e. activity VERIFY AUTHORITY will
  ** always use this employee id to verify authority against.
  ** If the preparer can not approve, then process FIND APPROVER will
  ** find an approver and put his/her employee_id in APPROVER_EMPID
  ** item attribute.
  */
  l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

   /*7125551, including the sql to get the value of l_can_modify_flag here*/

      SELECT CAN_APPROVER_MODIFY_DOC_FLAG
             INTO l_can_modify_flag
             FROM po_document_types
            WHERE DOCUMENT_TYPE_CODE = l_document_type
      AND DOCUMENT_SUBTYPE = l_doc_subtype;

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_preparer_id);

   /* Get the username and display_name of the preparer. This will
   ** be used as the FORWARD-FROM in the notifications.
   ** Initially the preparer is also considered as the approver, so
   ** set the approver_username also.
   */
   PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, x_username,
                                      x_user_display_name);

   -- Bug 711141 fix (setting process owner here)

   wf_engine.SetItemOwner (itemtype => itemtype,
                           itemkey  => itemkey,

/* { Bug 2148872:          owner    => 'PER:' || l_preparer_id);

     wf_engine.SetItemOwner needs 'owner' parameter to be passed as
     the internal user name of the owner in wf_users. To pass it as
     "PER:person_id" has been disallowed by WF.                    */

                           owner    => x_username);   -- Bug 2148872 }

   -- Context Setting revamp (begin)

   l_printer := fnd_profile.value('PRINTER');
   l_conc_copies := to_number(fnd_profile.value('CONC_COPIES'));
   l_conc_save_output := fnd_profile.value('CONC_SAVE_OUTPUT');


     /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attrbute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */


   po_wf_util_pkg.SetItemAttrText (itemtype => itemType,
                              itemkey  => itemkey,
                              aname    => 'PREPARER_PRINTER',
                              avalue   => l_printer);

   po_wf_util_pkg.SetItemAttrNumber (itemtype => itemType,
                              itemkey  => itemkey,
                              aname    => 'PREPARER_CONC_COPIES',
                              avalue   => l_conc_copies);

   po_wf_util_pkg.SetItemAttrText (itemtype  => itemType,
                                  itemkey   => itemkey,
                                  aname     => 'PREPARER_CONC_SAVE_OUTPUT',
                                  avalue    => l_conc_save_output);

   --Context Setting revamp (end)

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

/* Bug# 2308846: kagarwal
** Description: The forward from user was always set to the preparer
** in the Approval process. Hence if the forward from user was
** different from the preparer, the forward from was showing
** wrong information.
**
** Fix Details: Modified the procedure Start_WF_Process() and
** Set_Startup_Values() to set the forward from attributes
** correctly.
*/


   l_forward_from_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_FROM_ID');

   IF (l_forward_from_id <> l_preparer_id) THEN

      PO_REQAPPROVAL_INIT1.get_user_name(l_forward_from_id, x_ff_username,
                                         x_ff_user_display_name);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_USER_NAME' ,
                                  avalue     => x_ff_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_DISP_NAME' ,
                                  avalue     => x_ff_user_display_name);

   ELSE

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_USER_NAME' ,
                                  avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_DISP_NAME' ,
                                  avalue     => x_user_display_name);

   END IF;


   /* Get the username (this is the name used to forward the notification to)
   ** from the FORWARD_TO_ID. We need to do this here!
   ** Also set the item attribute FORWARD_TO_USERNAME to that username.
   */
   l_forward_to_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');

   IF l_forward_to_id is NOT NULL THEN

/* kagarwal: Use a diff variable for username and display name
** for forward to as later we set the responder attributes to same
** as that of preparer using the var x_username and
** x_user_display_name
*/
      /* Get the forward-to display name */
      PO_REQAPPROVAL_INIT1.get_user_name(l_forward_to_id, x_ft_username,
                                      x_ft_user_display_name);

      /* Set the forward-to display name */
      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => x_ft_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => x_ft_user_display_name);

   END IF;

   -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
-------------------------------------------------------------------------------------
   lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => x_orgid);
-------------------------------------------------------------------------------------
   -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End
   /* Bug 1064651
   ** Init  RESPONDER to PREPARER if document is a requisition.
   */

   IF l_document_type = 'REQUISITION' THEN

      wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RESPONDER_ID',
                                   avalue   => l_preparer_id);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'RESPONDER_USER_NAME' ,
                                  avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'RESPONDER_DISPLAY_NAME' ,
                                  avalue     => x_user_display_name);

     /* Bug 3800933
      ** Need to set the preparer's language as worflow attribute for info template attachment of req approval
     */
     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                    itemkey     => itemkey,
                                    aname       => 'PREPARER_LANGUAGE',
                                    avalue      =>  userenv('LANG'));

     -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
     -------------------------------------------------------------------------------------
     IF lv_tax_region='JAI'
     THEN
       --open indian localization form
       l_open_form:=JAI_PO_WF_UTIL_PUB.Get_Jai_Open_Form_Command
                    (pv_document_type => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE);

       wf_engine.SetItemAttrText ( itemtype   => itemType
                                 , itemkey    => itemkey
                                 , aname      => 'OPEN_FORM_COMMAND'
                                 , avalue     => l_open_form
                                 );
     END IF;
     -------------------------------------------------------------------------------------
     -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End
  END IF;

  -- Set the Command for the button that opens the Enter PO/Releases form
  -- Note: the Open Form command for the requisition is hard-coded in the
  --       Requisition approval workflow.

  IF l_document_type IN ('PO', 'PA') THEN
     -- <HTML Orders R12 Start >
     -- Set the URL and form link attributes based on doc style and type
     IF l_doc_subtype in ('BLANKET', 'CONTRACT') THEN
        l_ga_flag := PO_WF_UTIL_PKG.GetItemAttrText (itemtype    => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'GLOBAL_AGREEMENT_FLAG');
     END IF;

     IF (nvl(l_ga_flag,'N')  = 'N' AND (l_doc_subtype = 'BLANKET' OR l_doc_subtype = 'CONTRACT')) OR
        l_doc_subtype = 'PLANNED' THEN --added the condition to check for contract PO also as part of bug 7125551 fix
        -- HTML Orders R12
        -- The url links are not applicable for local agreements
        l_view_po_url := null;
        l_edit_po_url := null;
        -- Modified by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
        -------------------------------------------------------------------------------------
        IF (lv_tax_region='JAI' AND l_doc_subtype = 'PLANNED')
        THEN
          --open indian localization form
          l_open_form:=JAI_PO_WF_UTIL_PUB.Get_Jai_Open_Form_Command
                       (pv_document_type => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE);

        ELSE
	  --Bug8399676 Removed the double quotes aroung MODIFY and POXSTNOT
          --Bug 7716930
          l_open_form := 'PO_POXPOEPO:PO_HEADER_ID=' || '&' || 'DOCUMENT_ID' ||
                      ' ACCESS_LEVEL_CODE=MODIFY' ||
                      ' POXPOEPO_CALLING_FORM=POXSTNOT';
        END IF;
        -------------------------------------------------------------------------------------
        -- Modified by Eric Ma for IL PO Notification on Apr-13,2009 ,End
     ELSIF nvl(l_ga_flag,'N')  = 'Y' OR
              l_doc_subtype = 'STANDARD' THEN

        Begin
          -- SQL What : Get the style id fromm po_headers
          -- SQL Why  : To derive the style type
          SELECT style_id
          INTO   l_style_id
          FROM   po_headers_all
          WHERE  po_header_id = l_document_id;
        Exception
          When Others Then
            l_style_id := null;
        End;

        l_view_po_url := get_po_url(p_po_header_id => l_document_id,
                                    p_doc_subtype  => l_doc_subtype,
                                    p_mode         => 'viewOnly');

        /*  Bug 7307832
        Added Debug Messages */
       x_progress := 'PO_REQAPPROVAL_INIT1.get_po_url viewOnly' || 'l_view_po_url ::'|| l_view_po_url;
       IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
       END IF;

        IF nvl(l_can_modify_flag,'N') = 'Y' THEN   /*Bug 7125551, edit document link should not be available if approver can modify is
        unchecked for the document type.*/

                l_edit_po_url := get_po_url(p_po_header_id => l_document_id,
                                            p_doc_subtype  => l_doc_subtype,
                                            p_mode         => 'update');
        /*  Bug 7307832
        Added WF Debug Messages */
       x_progress := 'PO_REQAPPROVAL_INIT1.get_po_url update' || 'l_edit_po_url ::'|| l_edit_po_url;
       IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
       END IF;

        ELSE
                l_edit_po_url := null;
        END IF;

        IF PO_DOC_STYLE_GRP.is_standard_doc_style(l_style_id) = 'Y' THEN

          -- Modified by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
          -------------------------------------------------------------------------------------
          IF lv_tax_region='JAI'
          THEN
            --open indian localization form
            l_open_form:=JAI_PO_WF_UTIL_PUB.Get_Jai_Open_Form_Command
                         (pv_document_type => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE);

          ELSE
            --STANDARD PO FORM
            --Bug 7716930
            l_open_form := 'PO_POXPOEPO:PO_HEADER_ID=' || '&' || 'DOCUMENT_ID' ||
                           ' ACCESS_LEVEL_CODE=MODIFY' ||
                           ' POXPOEPO_CALLING_FORM=POXSTNOT';
          END IF;
          -------------------------------------------------------------------------------------
          -- Modified by Eric Ma for IL PO Notification on Apr-13,2009 ,End
        ELSE
          l_open_form := null;
        END IF;

     END IF;
     -- <HTML Orders R12 End >

  ELSIF l_document_type = 'RELEASE' THEN
    -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
    -------------------------------------------------------------------------------------
    IF lv_tax_region='JAI'
    THEN
      --open indian localization form
      l_open_form:=JAI_PO_WF_UTIL_PUB.Get_Jai_Open_Form_Command
                  (pv_document_type => JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE);
    ELSE
      --STANDARD RELEASE FORM
      --Bug 7716930
      l_open_form := 'PO_POXPOERL:PO_RELEASE_ID=' || '&' || 'DOCUMENT_ID' ||
                     ' ACCESS_LEVEL_CODE=MODIFY' ||
                     ' POXPOERL_CALLING_FORM=POXSTNOT';
    END IF;
    -------------------------------------------------------------------------------------
    -- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End

     -- HTML Orders R12
     -- The url links are not applicable for releases
     l_view_po_url := null;
     l_edit_po_url := null;

  END IF;

  IF (l_document_type <> 'REQUISITION') then
        -- HTML Orders R12
        -- Set the URL and form attributes
        PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'OPEN_FORM_COMMAND' ,
                                      avalue     => l_open_form);

        PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'VIEW_DOC_URL' ,
                                      avalue     => l_view_po_url);

        PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'EDIT_DOC_URL' ,
                                      avalue     => l_edit_po_url);

  END IF;
  /* WEB REQUISITIONS:
  **  Set the URL to  VIEW/UPDATE web requisitions
  */

  -- The support for icx 3.0 is removed.

  IF (fnd_profile.value('POR_SSP4_INSTALLED') = 'Y' AND
      l_document_type = 'REQUISITION' and
      po_core_s.get_product_install_status('ICX') = 'I') THEN

     --Bug#3147435
     --Set the values for workflow attribute
     --VIEW_REQ_DTLS_URL and EDIT_REQ_URL

     l_view_req_dtls_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                            'porMode=viewReq' || '&' ||
                            'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                            '_OrgId=' || to_char(x_orgid) || '&' ||
                            'addBreadCrumb=Y' || '&' ||
 	  'currNid=-&#NID-' ;

     l_edit_req_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                       'porMode=approverCheckout' || '&' ||
                       'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                       '_OrgId=' || to_char(x_orgid)|| '&' ||
                            'currNid=-&#NID-';

     l_resubmit_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                       'porMode=resubmitReq' || '&' ||
                       'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                       '_OrgId=' || to_char(x_orgid);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'VIEW_REQ_DTLS_URL',
                                      avalue     => l_view_req_dtls_url);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'EDIT_REQ_URL',
                                      avalue     => l_edit_req_url);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'RESUBMIT_REQ_URL',
                                      avalue     => l_resubmit_url);

     /* Removed call for  jumpIntoFunction() to set the attributes value.
        Instead of that setting the values of l_view_req_dtls_url, l_edit_req_url and l_resubmit_url variables
        into corrosponding attributes */

     l_open_req_url := l_view_req_dtls_url;
     l_update_req_url := l_edit_req_url;

     -- Bug 636924, lpo, 03/31/98
     -- Added resubmit link.
     l_resubmit_req_url := l_resubmit_url;

     -- End of fix. Bug 636924, lpo, 03/31/98

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_URL' ,
                                 avalue     => l_open_req_url);

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_UPDATE_URL' ,
                                 avalue     => l_update_req_url);

     -- Bug 636924, lpo, 03/31/98
     -- Added resubmit workflow attribute.

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_RESUBMIT_URL' ,
                                 avalue     => l_resubmit_req_url);

     l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

     l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

      /* bug 7125551, as part of this bug, commenting out the below sql and including it at the beginning of this procedure so
     that the l_can_modify_flag can be used elsewhere also*/

     /*SELECT CAN_APPROVER_MODIFY_DOC_FLAG
       INTO l_can_modify_flag
       FROM po_document_types
      WHERE DOCUMENT_TYPE_CODE = l_document_type
        AND DOCUMENT_SUBTYPE = l_doc_subtype;*/

     -- Not showing the open form icon if this is an IP req and owner can't
     -- modify.

     if l_can_modify_flag = 'N' and l_interface_source = 'POR' then

        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'OPEN_FORM_COMMAND' ,
                              avalue     => '');
     end if;

  END IF;

  /* Set the Subject of the Approval notification initially to
  ** "requires your approval". If the user enters an invalid forward-to
  ** then this messages gets nulled-out and the "Invalid Forward-to"
  ** message gets a value (see notification: Approve Requisition).
  */
  fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
  l_error_msg := fnd_message.get;

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'REQUIRES_APPROVAL_MSG' ,
                              avalue     => l_error_msg);

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'WRONG_FORWARD_TO_MSG' ,
                              avalue     => '');

  /* Get the orignial authorization status from the document
  ** This has to be done here as we set the document status to
  ** IN-PROCESS after this.
  */

  IF l_document_type='REQUISITION' THEN

     select AUTHORIZATION_STATUS
     into l_authorization_status
     from po_requisition_headers_all
     where REQUISITION_HEADER_ID = l_document_id;

/* Bug#1810322: kagarwal
** Desc: If the original authorization status is IN PROCESS or PRE-APPROVED
** for Reqs then we need to store INCOMPLETE as the original authorization
** status.
*/

     IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
        l_authorization_status := 'INCOMPLETE';
     END IF;

  ELSIF l_document_type IN ('PO','PA') THEN

     select AUTHORIZATION_STATUS, NVL(REVISION_NUM,0)
     into l_authorization_status, l_po_revision
     from po_headers_all
     where PO_HEADER_ID = l_document_id;

/* Bug#1810322: kagarwal
** Desc: If the original authorization status is IN PROCESS or PRE-APPROVED
** for PO/Releases then we need to store REQUIRES REAPPROVAL as the original
** authorization status if the revision number is greater than 0 else
** INCOMPLETE.
*/

     IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
        IF l_po_revision > 0 THEN
                l_authorization_status := 'REQUIRES REAPPROVAL';
        ELSE
                l_authorization_status := 'INCOMPLETE';
        END IF;
     END IF;

  ELSIF l_document_type = 'RELEASE' THEN

      select AUTHORIZATION_STATUS, NVL(REVISION_NUM,0)
      into l_authorization_status, l_po_revision
      from po_releases_all
      where  PO_RELEASE_ID = l_document_id;

      IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
        IF l_po_revision > 0 THEN
                l_authorization_status := 'REQUIRES REAPPROVAL';
        ELSE
                l_authorization_status := 'INCOMPLETE';
        END IF;
     END IF;

  END IF;

  /* Set the doc authorization_status into original_autorization_status */

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                             itemkey    => itemkey,
                             aname      => 'ORIG_AUTH_STATUS' ,
                             avalue     => l_authorization_status);


  /* Set PLSQL document attribute */

  if l_document_type='REQUISITION' then

/* bug 2480327 notification UI enhancement
   add  &#NID to PLSQL document attributes
 */

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_REQ_APPROVE_MSG',
                              avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_APPROVE_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_APPROVED_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_APPROVED_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_NO_APPROVER_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_NO_APPROVER_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_REJECT_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_REJECT_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQ_LINES_DETAILS',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_REQ_LINES_DETAILS/'||
                         itemtype||':'||
                         itemkey);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'ACTION_HISTORY',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_ACTION_HISTORY/'||
                         itemtype||':'||
                         itemkey);

  elsif l_document_type IN ('PO', 'PA', 'RELEASE') then

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_APPROVE_MSG',
                              avalue   => 'PLSQL:PO_WF_PO_NOTIFICATION.GET_PO_APPROVE_MSG/' ||
                                                itemtype || ':' || itemkey);

    -- <BUG 7006113>
    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_LINES_DETAILS',
                              avalue   => 'PLSQLCLOB:PO_WF_PO_NOTIFICATION.GET_PO_LINES_DETAILS/'||
                                                itemtype||':'|| itemkey);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'ACTION_HISTORY',
                              avalue   => 'PLSQL:PO_WF_PO_NOTIFICATION.GET_ACTION_HISTORY/'||
                                                itemtype||':'|| itemkey);

   /* PO AME Project :Start
    Setting requires review message */
    fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_REVIEW');
    l_review_msg := fnd_message.get;
    PO_WF_UTIL_PKG.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'REQUIRES_REVIEW_MSG' ,
                              avalue     => l_review_msg);
   /* PO AME Project :End */

  end if;

  --Bug 6164753
  l_external_url := fnd_profile.value('POS_EXTERNAL_URL');

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => '#WFM_HTMLAGENT',
                                            avalue   => l_external_url);
  --Bug 6164753


  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_Startup_Values: 03'||
                'Open Form Command= ' || l_open_form;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Set_Startup_Values',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_STARTUP_VALUES');
    raise;

END Set_Startup_Values;


--
-- Get_Req_Attributes
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_Req_Attributes(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_requisition_header_id NUMBER;
l_authorization_status varchar2(25);
l_orgid                number;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Req_Attributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2377333
  ** Setting application context
  */

  --Context Setting Revamp
  /* PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */


  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_requisition_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  GetReqAttributes(l_requisition_header_id,itemtype,itemkey);

     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --
  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Req_Attributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Req_Attributes',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_REQ_ATTRIBUTES');
    raise;

END Get_Req_Attributes;

-- set_doc_stat_preapproved
-- Added for WR4
procedure set_doc_stat_preapproved(itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2    ) is

-- Bug 3326847: Change l_requisition_header_id to l_doc__header_id
--              This is because the PO Approval WF will now call this as code as well.
l_doc_header_id         NUMBER;
l_po_header_id          NUMBER;
l_doc_type              VARCHAR2(14);
l_authorization_stat    VARCHAR2(25);
l_note                  VARCHAR2(4000);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_preapproved: 01';
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  -- Bug 3326847: Change l_requisition_header_id to l_doc_header_id
  l_doc_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_authorization_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AUTHORIZATION_STATUS');

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     IF l_doc_type = 'REQUISITION' THEN

        -- Bug 3326847: Change l_requisition_header_id to l_doc_header_id
        SetReqAuthStat(l_doc_header_id, itemtype,itemkey,l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');


     ELSIF l_doc_type IN ('PO', 'PA') THEN

        -- Bug 3327847: Added code to set POs to 'PRE-APPROVED' status.

        SetPOAuthStat(l_doc_header_id, itemtype, itemkey, l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');

     ELSIF l_doc_type = 'RELEASE' THEN

        -- Bug 3327847: Added code to set Releases to 'PRE-APPROVED' status.

        SetRelAuthStat(l_doc_header_id, itemtype, itemkey, l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');

     END IF;
     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_preapproved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_PREAPPROVED');
    raise;

END set_doc_stat_preapproved;


-- set_doc_stat_inprocess
--  Set the Doc status to In process and update the Doc Header table with the Itemtype
--  and Itemkey indicating that this doc has been submitted to workflow.
--
procedure set_doc_stat_inprocess(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_doc_type              VARCHAR2(14);
l_authorization_stat    VARCHAR2(25);
l_note                  VARCHAR2(4000);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_authorization_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AUTHORIZATION_STATUS');

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  /* If the Doc is INCOMPLETE or REJECTED (not IN PROCESS or PRE-APPROVED), then
  ** we want to set it to IN PROCESS and update the ITEMTYPE/ITEMKEY columns.
  ** If this is an upgrade to R11, then we need to update the ITEMTYPE/ITEMKEY columns
  ** Note that we only pickup docs is IN PROCESS or PRE-APPROVED in the upgrade step.
  */
  IF   ( NVL(l_authorization_stat, 'INCOMPLETE') NOT IN ('IN PROCESS', 'PRE-APPROVED') )
     OR
       ( l_note = 'UPGRADE_TO_R11' )  THEN

     IF l_doc_type = 'REQUISITION' THEN

        SetReqAuthStat(l_document_id, itemtype,itemkey,l_note, 'IN PROCESS');

     ELSIF l_doc_type IN ('PO', 'PA') THEN

        SetPOAuthStat(l_document_id, itemtype,itemkey,l_note,  'IN PROCESS');

        -- <HTML Agreement R12 START>
        -- Release functional lock, if needed

        x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 02 unlock document';
        IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;


        unlock_document
        ( p_po_header_id => l_document_id);

        -- <HTML Agreement R12 END>


     ELSIF l_doc_type = 'RELEASE' THEN

        SetRelAuthStat(l_document_id, itemtype,itemkey,l_note,  'IN PROCESS');

     END IF;

     wf_engine.SetItemAttrText ( itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname     => 'AUTHORIZATION_STATUS',
                              avalue    => 'IN PROCESS' );



  END IF;

     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_inprocess',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_INPROCESS');
    raise;

END set_doc_stat_inprocess;

--
procedure set_doc_to_originalstat(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_orig_auth_stat        VARCHAR2(25);
l_auth_stat             VARCHAR2(25);
l_requisition_header_id NUMBER;
l_po_header_id          NUMBER;
l_doc_id                NUMBER;
l_doc_type              VARCHAR2(14);
l_doc_subtype           VARCHAR2(25);
l_orgid                 NUMBER;
x_progress              varchar2(200);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_orig_auth_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORIG_AUTH_STATUS');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText(itemtype => itemtype,
                                             itemkey => itemkey,
                                             aname   => 'DOCUMENT_SUBTYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  /* If the doc is APPROVED then don't reset the status. We should
  ** not run into this case. But this is to prevent any problems
  */
  IF l_doc_type = 'REQUISITION' THEN

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;

     IF l_auth_stat <> 'APPROVED' THEN
        SetReqAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat);
     END IF;

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

      IF l_auth_stat <> 'APPROVED' THEN
         SetPOAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat );
      END IF;

  ELSIF l_doc_type = 'RELEASE' THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

      IF l_auth_stat <> 'APPROVED' THEN
         SetRelAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat );
      END IF;

  END IF;

  IF l_auth_stat <> 'APPROVED' THEN

    wf_engine.SetItemAttrText ( itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname     => 'AUTHORIZATION_STATUS',
                              avalue    => l_orig_auth_stat);

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 02' ||
                ' Auth_status= ' || l_auth_stat || ', Orig_auth_stat= ' || l_orig_auth_stat;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


     -- Bug 3845048: Added the code to update the action history with 'no action'
     -- so that the action history code is completed properly when the document
     -- is returned to the submitter, in case of no approver found or time out

     x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 03' || 'Update Action History'
                    || 'Action Code = No Action';
     IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;
     /* This was added for bug 3845048.
        As part of fix 5691965 moving this code to prior location in approval wf.
     UpdateActionHistory(p_doc_id      =>  l_doc_id,
                         p_doc_type    =>  l_doc_type,
                         p_doc_subtype =>  l_doc_subtype,
                         p_action      =>  'NO ACTION'
                        ) ;
     */
     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_inprocess',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_INPROCESS');
    raise;

END set_doc_to_originalstat;

-- Register_doc_submitted
--
--   Update the DOC HEADER with the Workflow Itemtype and ItemKey
--
procedure Register_doc_submitted(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_doc_id                NUMBER;
l_doc_type              VARCHAR2(25);
l_authorization_stat    VARCHAR2(25);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Register_doc_submitted: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_doc_id := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  IF l_doc_type = 'REQUISITION' THEN

      UpdtReqItemtype(itemtype,itemkey, l_doc_id);

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      UpdtPOItemtype(itemtype,itemkey, l_doc_id );

  ELSIF l_doc_type = 'RELEASE' THEN

        UpdtRelItemtype(itemtype,itemkey, l_doc_id);

  END IF;


     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.Register_doc_submitted: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Register_doc_submitted',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.REGISTER_DOC_SUBMITTED');
    raise;

END Register_doc_submitted;

--
-- can_owner_approve
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure can_owner_approve(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
x_CanOwnerApproveFlag   VARCHAR2(1);
l_interface_source      VARCHAR2(30);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.can_owner_approve: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

  /* For one time upgrade of notifications for the client, we want to
  ** follow a certain path in the workflow. We do not want to go through
  ** the VERIFY AUTHORITY path. Therefore, set the RESULT to N
  */
  IF NVL(l_interface_source,'X') = 'ONE_TIME_UPGRADE' THEN
    --
     resultout := wf_engine.eng_completed || ':' || 'N';
    --
  ELSE

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    -- Set the multi-org context
    l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

    END IF;

    PO_REQAPPROVAL_INIT1.GetCanOwnerApprove(itemtype, itemkey, x_CanOwnerApproveFlag);

    --
     resultout := wf_engine.eng_completed || ':' || x_CanOwnerApproveFlag ;
    --

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.can_owner_approve: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','can_owner_approve',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.CAN_OWNER_APPROVE');
    raise;

END can_owner_approve;

-- Bug 10013322
--   Is_Submitter_Same_As_Preparer
--   Check whether Submitter is same as preparer
--

procedure Is_Submitter_Same_As_Preparer(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) IS
    l_preparer_id   NUMBER;
    l_submitter_id  NUMBER;
    l_approver_id  NUMBER;

    BEGIN
    l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

     l_submitter_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUBMITTER_ID');

    IF(((l_preparer_id IS NOT NULL) AND (l_submitter_id IS NOT NULL)) AND (l_preparer_id <> l_submitter_id))THEN

    resultout := wf_engine.eng_completed || ':' || 'N' ;

    ELSE

    resultout := wf_engine.eng_completed || ':' || 'Y' ;

    END IF;

END  Is_Submitter_Same_As_Preparer ;

--
-- Is_doc_preapproved
--   Is document status pre-approved
--
procedure Is_doc_preapproved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_auth_stat varchar2(25);
l_doc_type  varchar2(25);
l_doc_id    number;
l_orgid     number;
x_progress              varchar2(200);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_doc_preapproved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */

  --Context Setting Revamp
  /* PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  -- Bug 762194: Need to set multi-org context.

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;


  IF l_doc_type = 'REQUISITION' THEN

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

  ELSIF l_doc_type = 'RELEASE' THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

  END IF;


  IF l_auth_stat = 'PRE-APPROVED' THEN

  --
     resultout := wf_engine.eng_completed || ':' || 'Y' ;
  --

  ELSIF l_auth_stat = 'IN PROCESS' THEN
  --
     resultout := wf_engine.eng_completed || ':' || 'N' ;
  --

  ELSE
  -- The doc is either APPROVED, INCOMPLETE or REJECTED. This invalid, therefore
  -- we will exit the workflow with an INVALID ACTION status.
     resultout := wf_engine.eng_completed || ':' || 'INVALID_AUTH_STATUS' ;
  --

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_doc_preapproved: 02' ||
                ' Authorization_status= ' || l_auth_stat ;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_doc_preapproved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_DOC_PREAPPROVED');
    raise;

END Is_doc_preapproved;


--
--
-- Ins_actionhist_submit
--   When we start the workflow, if the document status is NOT 'IN PROCESS' or
--   PRE-APPROVED, then insert a SUBMIT action row into PO_ACTION_HISTORY
--   to signal the submission of the document for approval.
--   Also, insert an additional row with a NULL ACTION_CODE (to simulate a
--   forward-to since the DOC status is IN PROCESS. The code in the DOC-MANAGER
--   looks for this row.
--
procedure Ins_actionhist_submit(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_note        PO_ACTION_HISTORY.note%TYPE;
l_employee_id number;
l_orgid       number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_path_id number;

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_submit: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

/* Bug 1100247 Amitabh
** Desc:Initially the Workflow sets the preparer_id, approver_empid
**      as the value passed to it by the POXAPAPC.pld file. As it always
**      assumed that an Incomplete Requisition would get approved  by
**      preparer only. Then when it calls the GetReqAttributes()
**      it would reget the preparer_id from the po_requisition_headers_all
**      table hence if the preparer_id and approver_empid are different
**      then the action history would be wrongly updated.
**
**      Modifying the parameter l_employee_id to be passed to
**      InsertActionHistSubmit() from PREPARER_ID to
**      APPROVER_EMPID.
**
**      Also modified the SetReqHdrAttributes() to also set the
**      PREPARER_USER_NAME and PREPARER_DISPLAY_NAME.
**
*/

  l_employee_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

  PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUBMITTER_ID',
                                 avalue   => l_employee_id);

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  PO_REQAPPROVAL_INIT1.InsertActionHistSubmit(itemtype,itemkey,l_doc_id, l_doc_type,
                                   l_doc_subtype, l_employee_id, 'SUBMIT', l_note, l_path_id);


  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --


  x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_submit: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Ins_actionhist_submit',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.INS_ACTIONHIST_SUBMIT');
    raise;

END Ins_actionhist_submit;

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Passed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  --
     resultout := wf_engine.eng_completed || ':' || 'PASSED_VERIFICATION' ;
  --

END Set_End_VerifyDoc_Passed;

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Failed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  --
     resultout := wf_engine.eng_completed || ':' || 'FAILED_VERIFICATION' ;
  --

END Set_End_VerifyDoc_Failed;

--
-- Set_End_Valid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Valid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);
BEGIN

  --
     resultout := wf_engine.eng_completed || ':' || 'VALID_ACTION' ;
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_End_Valid_Action: RESULT=VALID_ACTION';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

END Set_End_Valid_Action;

--
-- Set_End_Invalid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Invalid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN

  --
     resultout := wf_engine.eng_completed || ':' || 'INVALID_ACTION' ;
  --

END Set_End_Invalid_Action;

--
-- Is_Interface_ReqImport
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   Is the calling module REQ IMPORT. If it is, then we need to RESERVE the doc.
--   Web Requisition come through REQ IMPORT.
procedure Is_Interface_ReqImport(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

l_interface_source  varchar2(25);
BEGIN

  l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

  IF l_interface_source <> 'PO_FORM' THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
  END IF;

END Is_Interface_ReqImport;

--
-- Encumb_on_doc_unreserved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If Encumbrance is ON and Document is NOT reserved, then return Y.
--   We need to reserve the doc.

procedure Encumb_on_doc_unreserved(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is
l_document_type varchar2(25);
l_document_subtype varchar2(25) := NULL;
l_document_id   number;
l_orgid     number;

x_progress  varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  -- <ENCUMBRANCE FPJ START>
  -- Get the subtype for doc type other than requisition

  if l_document_type <> 'REQUISITION' THEN

     l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');
  end if;

  -- <ENCUMBRANCE FPJ END>

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;


  IF ( EncumbOn_DocUnreserved(
               p_doc_type    => l_document_type,
               p_doc_subtype => l_document_subtype,
               p_doc_id      => l_document_id)
      = 'Y' ) THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved: 01';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved: 02';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.ENCUMB_ON_DOC_UNRESERVED');
    raise;

END Encumb_on_doc_unreserved;

--
--
-- RESERVE_AT_COMPLETION_CHECK
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If the reserve at completion flag is checked, then return Y.

procedure RESERVE_AT_COMPLETION_CHECK(   itemtype        in varchar2,
                                         itemkey         in varchar2,
                                         actid           in number,
                                         funcmode        in varchar2,
                                         resultout       out NOCOPY varchar2    ) is

l_reserve_at_compl varchar2(1);
x_CanOwnerApproveFlag   varchar2(1);

x_progress  varchar2(100);
l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

/* Bug# 2234341: kagarwal
** Desc: The preparer cannot reserve a requisiton at the start of the
** approval workflow, if the preparer cannot approve and also the reserve
** at completion is No.
** The logic that follows here is that the owner/preparer is also an
** approver, if the preparer can approve is allowed.
*/

   select nvl(fsp.reserve_at_completion_flag,'N') into l_reserve_at_compl
        from financials_system_parameters fsp;

  PO_REQAPPROVAL_INIT1.GetCanOwnerApprove(itemtype, itemkey, x_CanOwnerApproveFlag);

 /*Bug 8520350 - Removing the check on OWNER_CAN_APPROVE.Since the two are not interdependent */

  IF (l_reserve_at_compl = 'N' ) THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_commit: 01';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_commit: 02';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.RESERVE_AT_COMPLETION_CHECK');
    raise;

END RESERVE_AT_COMPLETION_CHECK;


-- Remove_reminder_notif
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Remove the reminder notifications since this doc is now approved.

procedure Remove_reminder_notif(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2 ) is

l_release_flag varchar2(1);
l_orgid        number;
l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_document_id  number;
l_wf_item_key  varchar2(100);
x_progress     varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

cursor po_cursor(p_header_id number) is
select wf_item_key
from po_headers
where po_header_id= p_header_id;

cursor req_cursor(p_header_id number) is
select wf_item_key
from po_requisition_headers
where requisition_header_id= p_header_id;

cursor rel_cursor(p_header_id number) is
select wf_item_key
from po_releases
where po_release_id= p_header_id;

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Remove_reminder_notif: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;
/* Bug #: 1384323 draising
   Forward fix of Bug # 1338325
   We need to set multi org context by getting it from the
   database rather rather than the org id attribute.
*/

/*
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;
*/
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

       PO_REQAPPROVAL_INIT1.get_multiorg_context(l_document_type,l_document_id,l_orgid);

   IF l_orgid is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
       wf_engine.SetItemAttrNumber (itemtype => itemtype ,
                                    itemkey  => itemkey ,
                                    aname    => 'ORG_ID' ,
                                    avalue  => l_orgid );
  END IF;

/* End of fix for Bug # 1384323 */
 IF l_document_type = 'RELEASE' THEN

    l_release_flag := 'Y';

 ELSE

   l_release_flag := 'N';

 END IF;

 /* Remove reminder notifications */
 PO_APPROVAL_REMINDER_SV. Cancel_Notif ( l_document_subtype,
                                         l_document_id,
                                         l_release_flag);

 /* If the document has been previously submitted to workflow, and did not
 ** complete because of some error or some action such as Document being rejected,
 ** then notifications may have been  issued to users.
 ** We need to remove those notifications once we submit the document to a
 ** new workflow run, so that the user is not confused.
 */

  IF l_document_type='REQUISITION' THEN

    open req_cursor(l_document_id);
    fetch req_cursor into l_wf_item_key;
    close req_cursor;

  ELSIF l_document_type IN ('PO','PA') THEN

    open po_cursor(l_document_id);
    fetch po_cursor into l_wf_item_key;
    close po_cursor;

  ELSIF l_document_type = 'RELEASE' THEN

    open rel_cursor(l_document_id);
    fetch rel_cursor into l_wf_item_key;
    close rel_cursor;

  END IF;

  IF l_wf_item_key is NOT NULL THEN

    Close_Old_Notif(itemtype, l_wf_item_key);

  END IF;

  resultout := wf_engine.eng_completed ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Remove_reminder_notif: 02.';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Remove_reminder_notif',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.REMOVE_REMINDER_NOTIF');
    raise;

END Remove_reminder_notif;

procedure Print_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_print_doc   varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

/* Bug 17575349 fix */
l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_preparer_id NUMBER;
l_default_method varchar2(15);
l_fax_number varchar2(20);
l_document_num varchar2(20);
l_po_email_add  WF_USERS.EMAIL_ADDRESS%TYPE;

/* Bug 17374891 */
l_document_id   number;
l_notif_method varchar2(15);
/* Bug 17374891 */

/* Bug 19214300 */
l_fax_doc varchar2(2);
l_email_doc varchar2(2);
/* Bug 19214300 */
BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Start of code changes for the bug 17575349 */

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

 IF l_document_type <> 'REQUISITION' THEN


 /* EDI and XML takes the precendence. Need to check whether EDI/XML is setup for the vendor site */

  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: checking EDI setting.. ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  PO_VENDOR_SITES_SV.get_transmission_defaults_edi(p_document_id     => l_document_id,
                                  p_document_type        => l_document_type,
                                  p_document_subtype     => l_document_subtype,
                                  p_preparer_id          => l_preparer_id,
                                  x_default_method       => l_default_method,
                                  x_email_address        => l_po_email_add,
                                  x_fax_number           => l_fax_number,
                                  x_document_num         => l_document_num,
                                  p_retrieve_only_flag   => 'Y');

  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: default transmission method: ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress||l_default_method);
  END IF;

  if ((l_default_method = 'EDI') OR (l_default_method = 'XML')) then
	wf_engine.SetItemAttrText (     itemtype        => itemtype,
									itemkey         => itemkey,
									aname           => 'PRINT_DOCUMENT',
									avalue          =>  'N');
  else
  --bug 18898316: No need to retrieve notify method from db for Release
  -- as approvers can not change it via notification link. Directly get value from wf attribute.

  --bug#19214300 begin
    l_print_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'PRINT_DOCUMENT');

    l_fax_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'FAX_DOCUMENT');

    l_email_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'EMAIL_DOCUMENT');


    IF (l_document_type IN ('PO', 'PA') AND NVL(l_print_doc,'N') <> 'Y'
        AND NVL(l_fax_doc,'N') <> 'Y' AND NVL(l_email_doc,'N') <> 'Y') THEN
  --bug#19214300 end

	  /* bug 17374891: Supplier notify method might changed by approvers,
		 need to retrieve the latest notify method */
		 BEGIN
		   Select supplier_notif_method
		   into l_notif_method
		   from po_headers_all
		   where po_header_id = l_document_id;
		 EXCEPTION
		   WHEN OTHERS THEN
		   NULL;
		 END;

	    if (nvl(l_notif_method,'NONE') <> 'PRINT') then
			wf_engine.SetItemAttrText (     itemtype        => itemtype,
											itemkey         => itemkey,
											aname           => 'PRINT_DOCUMENT',
											avalue          =>  'N');
		else
			wf_engine.SetItemAttrText (     itemtype        => itemtype,
											itemkey         => itemkey,
											aname           => 'PRINT_DOCUMENT',
											avalue          =>  'Y');
		end if;
	/* BUG 17374891 end */
   END IF;  /* bug 18898316 end */
	end if;
	/* End of code changes for the bug 17575349 */

  END IF;

  l_print_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PRINT_DOCUMENT');

  /* the value of l_print_doc should be Y or N */
  IF (nvl(l_print_doc,'N') <> 'Y') THEN
        l_print_doc := 'N';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_print_doc ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: 02. Result= ' || l_print_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.PRINT_DOC_YES_NO');
    raise;

END Print_Doc_Yes_No;


-- DKC 10/10/99
procedure Fax_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_fax_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

/* Bug 17575349 changes*/
l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_preparer_id NUMBER;
l_default_method varchar2(15);
l_document_num varchar2(20);
l_po_email_add  WF_USERS.EMAIL_ADDRESS%TYPE;

/* Bug 17374891 */
l_document_id   number;
l_fax_number varchar2(20);
l_notif_method varchar2(15);
/* Bug 17374891 */

/* Bug 19214300 */
l_print_doc  varchar2(2);
l_email_doc  varchar2(2);
/* Bug 19214300 */

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Start of code chagnes for the bug 17575349 */
     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

 /* EDI/XML takes the precedence. Hence, check for the EDI/XML first */

  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: checking the default transmission ...';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  PO_VENDOR_SITES_SV.get_transmission_defaults_edi(p_document_id     => l_document_id,
                                  p_document_type        => l_document_type,
                                  p_document_subtype     => l_document_subtype,
                                  p_preparer_id          => l_preparer_id,
                                  x_default_method       => l_default_method,
                                  x_email_address        => l_po_email_add,
                                  x_fax_number           => l_fax_number,
                                  x_document_num         => l_document_num,
                                  p_retrieve_only_flag   => 'Y');

  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: default transmission method: ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress||l_default_method);
  END IF;

  if ((l_default_method = 'EDI') or (l_default_method = 'XML')) then
	wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'FAX_DOCUMENT',
                                    avalue          =>  'N');
  else

  /* End of code chagnes for the bug 17575349 */
  --bug 18898316: No need to retrieve notify method from db for Release
  -- as approvers can not change it via notification link. Directly get value from wf attribute.

  --bug#19214300 begin
    l_print_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'PRINT_DOCUMENT');

    l_fax_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'FAX_DOCUMENT');

    l_email_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'EMAIL_DOCUMENT');


    IF (l_document_type IN ('PO', 'PA') AND NVL(l_print_doc,'N') <> 'Y'
        AND NVL(l_fax_doc,'N') <> 'Y' AND NVL(l_email_doc,'N') <> 'Y') THEN
  --bug#19214300 end

  /* bug 17374891: Supplier notify method might changed by approvers,
     need to retrieve the latest notify method */
     l_fax_number := null;
     BEGIN
       Select fax, supplier_notif_method
       into l_fax_number, l_notif_method
       from po_headers_all
       where po_header_id = l_document_id;
     EXCEPTION
       WHEN OTHERS THEN
       NULL;
     END;

  if nvl(l_notif_method,'NONE') <> 'FAX' then
    wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'FAX_DOCUMENT',
                                    avalue          =>  'N');
  else
     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'FAX_DOCUMENT',
                                    avalue          =>  'Y');
     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'FAX_NUMBER',
                                     avalue          =>  l_fax_number);
  end if;
/* BUG 17374891 end */
 END IF;
 end if; --bug 17575349. End of EDI or XML if condition

  l_fax_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FAX_DOCUMENT');

  /* the value of l_fax_doc should be Y or N */
  IF (nvl(l_fax_doc,'N') <> 'Y') THEN
        l_fax_doc := 'N';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_fax_doc ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: 02. Result= ' || l_fax_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOC_YES_NO');
    raise;

END Fax_Doc_Yes_No;


--SR-ASL FPH --
procedure Create_SR_ASL_Yes_No( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_create_sr_asl     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_document_type PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

l_resp_id     number;
l_user_id     number;
l_appl_id     number;

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Create_SR_ASL_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');


  l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_ID');

  l_resp_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSIBILITY_ID');

  l_appl_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPLICATION_ID');

  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

  --Context Setting Revamp
  /* if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then

    -- Bug 4290541,replaced apps init call with set doc mgr contxt
    PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */

        IF l_orgid is NOT NULL THEN
                PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
        END IF;

 -- end if;



  l_create_sr_asl := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CREATE_SOURCING_RULE');
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_TYPE');
  l_document_subtype := wf_engine.GetItemAttrText (itemtype =>itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_SUBTYPE');

  /* the value of CREATE_SOURCING_RULE should be Y or N */
  IF (nvl(l_create_sr_asl,'N') <> 'Y') THEN
    l_create_sr_asl := 'N';
  ELSE
    if l_document_type = 'PA'  then
      if l_document_subtype = 'BLANKET' then
        l_create_sr_asl := 'Y';
      else
        l_create_sr_asl := 'N';
      end if;
    else
        l_create_sr_asl := 'N';
    end if;
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_create_sr_asl;

  x_progress := 'PO_REQAPPROVAL_INIT1.Create_SR_ASL_Yes_No: 02. Result= ' || l_create_sr_asl;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  l_create_sr_asl := 'N';
    resultout := wf_engine.eng_completed || ':' || l_create_sr_asl;
END Create_SR_ASL_Yes_No;






-- DKC 10/10/99
procedure Send_WS_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, l_notifier);


  if (l_notifier is not null) then
        l_send_notif := 'Y';
        --Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
        ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_NOTIF_PERFORMER',
                                   avalue   => l_notifier);
   else
        l_send_notif := 'N';
   end if;

   resultout := wf_engine.eng_completed || ':' || l_send_notif ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOC_YES_NO');
    raise;

END Send_WS_Notif_Yes_No;


/*
< Added this procedure as part of Bug #: 2810150 >
*/
procedure Send_WS_FYI_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);
l_notifier_resp varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

-- BINDING FPJ
l_acceptance_flag   PO_HEADERS_ALL.acceptance_required_flag%TYPE;

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

-- BINDING FPJ START

    IF ((l_document_type <> 'RELEASE') AND
       l_document_subtype IN ('STANDARD','BLANKET','CONTRACT')) THEN
        SELECT acceptance_required_flag
                  INTO l_acceptance_flag
                  FROM po_headers_all
                 WHERE po_header_Id = l_document_id;

        IF l_acceptance_flag = 'S' THEN
            PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'Y', l_notifier, l_notifier_resp);
        ELSE
            PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'N', l_notifier, l_notifier_resp);
        END IF;
    ELSE
-- BINDING FPJ END
        PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'N', l_notifier, l_notifier_resp);
    END IF;


  if (l_notifier is not null) then
        l_send_notif := 'Y';
        --Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
        ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_NOTIF_PERFORMER',
                                   avalue   => l_notifier);
   else
        l_send_notif := 'N';
   end if;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_ACK_NOTIF_PERFORMER',
                                   avalue   => l_notifier_resp);

   resultout := wf_engine.eng_completed || ':' || l_send_notif ;


  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No');
    raise;

END Send_WS_FYI_Notif_Yes_No;



/*
< Added this procedure as part of Bug #: 2810150 >
*/
procedure Send_WS_ACK_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_notifier:=wf_engine.GetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_ACK_NOTIF_PERFORMER');

  if (l_notifier is not null) then
        --Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
        ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);
        l_send_notif := 'Y';
   else
        l_send_notif := 'N';
   end if;


   resultout := wf_engine.eng_completed || ':' || l_send_notif ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No');
    raise;

END Send_WS_ACK_Notif_Yes_No;


/*
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  This procedure assumes that all the supplier users related to this
  document need to be sent the notification.

  Returns the role containing all the users in the "resultout" variable
*/
procedure  locate_notifier(document_id    in      varchar2,
                                 document_type   in     varchar2,
                                 resultout      in out NOCOPY  varchar2) IS
l_role_with_resp varchar2(1000);
l_notify_only_flag varchar2(10);
BEGIN
    l_notify_only_flag := 'Y';
    locate_notifier(document_id, document_type, l_notify_only_flag, resultout, l_role_with_resp);
END;


/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: locate_notifier

  DESCRIPTION   :
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  Referenced by : Workflow procedures
  parameters    :
   Input:
    document_id - the document id
    document_type - Document type
    p_notify_only_flag -
        The values can be 'Y' or 'N'
        'Y' means: The procedure will return all the users that are supplier users related to the document.
        Returns the role containing all the users in the "x_resultout" variable

        'N' means: we want users that need to be sent FYI and also the users with resp.
            x_resultout: will have the role for the users that need to be sent the FYI
            x_role_with_resp: will have the role for users having the fucntion "POS_ACK_ORDER" assigned to
            them.

   Output:
    x_resultout - Role for the users that need to be sent FYI
    x_role_with_resp - Role for the users who have the ability to acknowledge.

  CHANGE History: Created      27-Feb-2003    jpasala
                  modified     10-JUL-2003    sahegde
  Bugs Fixed: 7233648 - Start
    Added a condition cancel_flag = N in where-clause of the query to calculate
    expiration_date. Also added if-condition to check if expiration_date is less
    than sysdate then expiration_date = sysdate +180, so that role's expiry date
    is six months from sysdate.
  Bugs Fixed: 7233648 - End

*******************************************************************/

procedure locate_notifier       (p_document_id    in      varchar2,
                                 p_document_type   in     varchar2,
                                 p_notify_only_flag in  varchar2,
                                 x_resultout      in out NOCOPY  varchar2,
                                 x_role_with_resp in out NOCOPY VARCHAR2) IS


/*CONERMS FPJ START*/
-- declare local variables to hold output of get_supplier_userlist call
l_supplier_user_tbl po_vendors_grp.external_user_tbl_type;
l_namelist varchar2(31990):=null;
l_namelist_for_sql varchar2(32000):=null;
l_num_users number := 0;
l_vendor_id NUMBER;
l_return_status VARCHAR2(1);
l_msg_count NUMBER := 0;
l_msg_data VARCHAR2(2000);
/*CONERMS FPJ END*/

-- local variables for role creation
l_role_name WF_USER_ROLES.ROLE_NAME%TYPE;
l_role_display_name varchar2(100):=null;
l_temp varchar2(100);
l_expiration_date DATE;
l_count number;
l_select boolean;
l_refcur1  g_refcur;
l_users_with_resp varchar2(32000);
l_step varchar2(32000) := '0';
l_diff_users_for_sql varchar2(32000);
l_user_count_with_resp number:=0;
l_fyi_user_count number:=0;


BEGIN
  l_num_users := 0;
  l_step := '0';

  /* CONTERMS FPJ START */
  -- The code to create the user list has been sliced into another procedure
  -- called po_vendors_grp.get_external_userlist. This procedure now makes a
  -- call to it to retrieve, comma and space delimited userlist, and number
  -- of users, supplier list in a table and vendor id.
  /*po_doc_utl_pvt.get_supplier_userlist(p_document_id => p_document_id
                       ,p_document_type             => p_document_type
                       ,x_return_status             => l_return_status
                       ,x_supplier_user_tbl         => l_supplier_user_tbl
                       ,x_supplier_userlist         => l_namelist
                       ,x_supplier_userlist_for_sql => l_namelist_for_sql
                       ,x_num_users                 => l_num_users
                       ,x_vendor_id                 => l_vendor_id);*/

  po_vendors_grp.get_external_userlist
          (p_api_version               => 1.0
          ,p_init_msg_list             => FND_API.G_FALSE
          ,p_document_id               => p_document_id
          ,p_document_type             => p_document_type
          ,x_return_status             => l_return_status
          ,x_msg_count                 => l_msg_count
          ,x_msg_data                  => l_msg_data
          ,x_external_user_tbl         => l_supplier_user_tbl
          ,x_supplier_userlist         => l_namelist
          ,x_supplier_userlist_for_sql => l_namelist_for_sql
          ,x_num_users                 => l_num_users
          ,x_vendor_id                 => l_vendor_id);

  l_step := '0'||l_namelist;
  -- proceed if return status is success
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    l_step := '4'|| l_namelist;
    if(l_namelist is null) then
      x_resultout := null;
    else
      if (p_document_type in ('PO', 'PA')) then
        select max(need_by_date)+180
        into l_expiration_date
        from po_line_locations
        where po_header_id = to_number(p_document_id)
        and cancel_flag = 'N';

        if l_expiration_date <= sysdate then
          l_expiration_date := sysdate + 180;
        end if;

      elsif (p_document_type = 'RELEASE') then
        select max(need_by_date)+180
        into l_expiration_date
        from po_line_locations
        where po_release_id = to_number(p_document_id)
        and cancel_flag = 'N';

        if l_expiration_date <= sysdate then
          l_expiration_date := sysdate + 180;
        end if;

      else
        l_expiration_date:=null;
      end if;
      begin
        select vendor_name
          into l_role_display_name
          from po_vendors
          where vendor_id=l_vendor_id;
        exception
          when others then
            l_role_display_name:=' ';
      end;

      IF p_notify_only_flag = 'Y' THEN
          l_role_name:= get_wf_role_for_users(l_namelist_for_sql, l_num_users ) ;
      ELSE

        -- get the list of users with the given resp from the current set of users
        l_step := '6';
        get_user_list_with_resp( get_function_id('POS_ACK_ORDER'),
            l_namelist_for_sql, l_namelist, l_users_with_resp,l_user_count_with_resp);

        IF ( l_user_count_with_resp > 0 ) then
            l_step := '7 : '|| l_user_count_with_resp;
            x_role_with_resp := get_wf_role_for_users(l_users_with_resp, l_user_count_with_resp ) ;

            if(x_role_with_resp is null ) then
                x_role_with_resp:=substr('ADHOCR' || to_char(sysdate, 'JSSSSS')|| p_document_id || p_document_type, 1, 30);
                l_step := '17'|| x_role_with_resp ;
                WF_DIRECTORY.CreateAdHocRole(x_role_with_resp, l_role_display_name ,
                  null,
                  null,
                  null,
                  'MAILHTML',
                  l_namelist,
                  null,
                  null,
                 'ACTIVE',
                 l_expiration_date);
            end if;
        ELSE
            x_role_with_resp := null;
        END IF;

        l_fyi_user_count := l_num_users - l_user_count_with_resp;

        if ( l_fyi_user_count =0  ) then
            /* Bug 17368215, roqiu. Rollback update in bug 5087421, this bug disable Acceptance Required email notification when Approve PO.
	    It's not right, now enable it.*/
            x_resultout := x_role_with_resp;
            /*x_resultout :=null;*/
            return;
        end if;


        l_step := '10: ' ;
        if ( l_user_count_with_resp > 0 ) then
            get_diff_in_user_list ( l_namelist_for_sql, l_users_with_resp ,
                                  l_namelist , l_diff_users_for_sql, l_fyi_user_count);
        else
            l_diff_users_for_sql:= l_namelist_for_sql;
            l_fyi_user_count := l_num_users;
        end if;
        l_step := '11: count='||l_fyi_user_count ;
        l_role_name := get_wf_role_for_users(l_diff_users_for_sql, l_fyi_user_count ) ;
      END IF; -- End of notify flag check

      if (l_role_name is null ) then
        l_step := '17'|| l_role_name;

        /* Bug 2966804 START */
        /* We need to give a role name before creating an ADHOC role. */

        l_role_name := substr('ADHOC' || to_char(sysdate, 'JSSSSS')|| p_document_id || p_document_type, 1, 30);

        /* Bug 2966804 END */

        WF_DIRECTORY.CreateAdHocRole(l_role_name, l_role_display_name ,
          null,
          null,
          null,
          'MAILHTML',
          l_namelist,
          null,
          null,
          'ACTIVE',
          l_expiration_date);
        x_resultout:=l_role_name;
      else
        l_step := '11'|| l_role_name;
        x_resultout:= l_role_name;
      end if;
    end if;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1.locate_notifier failed at:',l_step);
    wf_core.context('PO_REQAPPROVAL_INIT1.locate_notifier',l_role_name||sqlerrm);
    --raise_application_error(-20001,'l_role_name ='||l_role_name ||' and l_step='||l_step ||' and l_list='||l_namelist_for_sql, true);
end locate_notifier;

-- DKC 02/06/01
procedure Email_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_email_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_document_id   number;
l_po_header_id  number;
l_vendor_site_code varchar2(15);
l_vendor_site_id number;
--EMAILPO FPH START--
l_vendor_site_lang PO_VENDOR_SITES.LANGUAGE%TYPE;
l_adhocuser_lang WF_LANGUAGES.NLS_LANGUAGE%TYPE;
l_adhocuser_territory WF_LANGUAGES.NLS_TERRITORY%TYPE;
--EMAILPO FPH START--
     /* Bug 2989951 Increased the width of the following variables */
l_po_email_performer  WF_USERS.NAME%TYPE;
l_po_email_add        WF_USERS.EMAIL_ADDRESS%TYPE;
l_display_name        WF_USERS.DISPLAY_NAME%TYPE;
l_po_email_performer_prof WF_USERS.NAME%TYPE;
l_po_email_add_prof       WF_USERS.EMAIL_ADDRESS%TYPE;
l_display_name_prof       WF_USERS.DISPLAY_NAME%TYPE;
l_performer_exists number;
l_notification_preference varchar2(20) := 'MAILHTM2'; -- Bug 3788367
l_when_to_archive varchar2(80);
l_archive_result varchar2(2);

/* Bug 17374891 */
l_notif_method varchar2(15);
/* Bug 17374891 */
/* Bug 17575349 changes*/
l_preparer_id NUMBER;
l_default_method varchar2(15);
l_fax_number varchar2(20);
l_document_num varchar2(20);

/* Bug 9254430 */
 	 l_note fnd_new_messages.message_text%TYPE;
 	 /* End Bug 9254430 */

/*Bug 9283386*/
l_doc_display_name  FND_NEW_MESSAGES.message_text%TYPE;
l_lang_code  wf_languages.code%TYPE;
/*Bug 9283386*/

--Added as part of the multiple email addresses support - Bug# 16043012
  l_role_users WF_DIRECTORY.UserTable;
  l_email_address VARCHAR2(40);
  l_counter number;
  l_role VARCHAR2(100);
  l_display_role_name VARCHAR2(100);
  l_hold_email VARCHAR2(2000);
-- bug 17213213
cursor docDisp(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;

/* Bug 19214300 */
l_fax_doc   varchar2(2);
l_print_doc varchar2(2);
/* Bug 19214300 */


BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug 2687751.
   * For blankets, the org context was not getting set and hence
   * sql query which selecs vendor_site_id below from po_vendor_sites
   * was throwing an exception. Hence setting the org context here.
  */
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
  END IF;

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

	/* Start of code changes for the bug 17575349 */

     l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');
	/* XML/EDI takes the precedence. And incase of EDI/XML, email will not be sent */

	x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: checking for EDI setting..';
	IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;

	PO_VENDOR_SITES_SV.get_transmission_defaults_edi(p_document_id     => l_document_id,
									  p_document_type        => l_document_type,
									  p_document_subtype     => l_document_subtype,
									  p_preparer_id          => l_preparer_id,
									  x_default_method       => l_default_method,
									  x_email_address        => l_po_email_add,
									  x_fax_number           => l_fax_number,
									  x_document_num         => l_document_num,
									  p_retrieve_only_flag   => 'Y');


	x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: default transmission method: ';
	IF (g_po_wf_debug = 'Y') THEN
	 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress||l_default_method);
	END IF;

	if ((l_default_method = 'EDI') or (l_default_method = 'XML')) then

		wf_engine.SetItemAttrText ( itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'EMAIL_DOCUMENT',
                                    avalue          =>  'N');
	else
	/* End of code changes for the bug 17575349 */
  --bug 18898316: No need to retrieve notify method from db for Release
  -- as approvers can not change it via notification link. Directly get value from wf attribute.


  --bug#19214300 begin
    l_print_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'PRINT_DOCUMENT');

    l_fax_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'FAX_DOCUMENT');

    l_email_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'EMAIL_DOCUMENT');


    IF (l_document_type IN ('PO', 'PA') AND NVL(l_print_doc,'N') <> 'Y'
        AND NVL(l_fax_doc,'N') <> 'Y' AND NVL(l_email_doc,'N') <> 'Y') THEN
  --bug#19214300 end

  /* bug 17374891: Supplier notify method might changed by approvers,
     need to retrieve the latest notify method */
     BEGIN
       Select email_address, supplier_notif_method
       into l_po_email_add, l_notif_method
       from po_headers_all
       where po_header_id = l_document_id;
     EXCEPTION
       WHEN OTHERS THEN
       NULL;
     END;

  if nvl(l_notif_method,'NONE') <> 'EMAIL' then
    wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'EMAIL_DOCUMENT',
                                    avalue          =>  'N');
  else
    wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'EMAIL_DOCUMENT',
                                    avalue          =>  'Y');

    wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'EMAIL_ADDRESS',
                                    avalue          =>  l_po_email_add);
  end if;
  end if;
 end if; --Bug 17575349 fix. End of XML/EDI if condition

  l_email_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_DOCUMENT');
/* BUG 17374891 end */

  -- the value of l_email_doc should be Y or N
  IF (nvl(l_email_doc,'N') <> 'Y') THEN
        l_email_doc := 'N';
  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: l_email_doc: ';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress||l_email_doc);
  END IF;

  -- Here, we are creating an entry in wf_local_users and assigning that to the email performer
  IF (l_email_doc = 'Y') THEN

     l_po_email_add := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADDRESS');

     l_po_email_add_prof :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADD_FROM_PROFILE');


     if (l_document_type in ('PO', 'PA')) then
        l_po_header_id := l_document_id;

     elsif (l_document_type = 'RELEASE') then
        select po_header_id into l_po_header_id
        from po_releases
        where po_release_id = l_document_id;

     else
        null;
     end if;

     x_progress := '002';

        --EMAILPO FPH--
        --also retrieve language to set the adhocuser language to supplier site preferred language
        select poh.vendor_site_id, pvs.vendor_site_code, pvs.language
        into l_vendor_site_id, l_vendor_site_code, l_vendor_site_lang
        from po_headers poh, po_vendor_sites pvs
        where pvs.vendor_site_id = poh.vendor_site_id
        and poh.po_header_id =         l_po_header_id;

        --EMAILPO FPH START--
        /*Bug 9283386 fetched language code into l_lang_code*/
        IF l_vendor_site_lang is  NOT NULL then
                SELECT wfl.nls_language, wfl.nls_territory,wfl.code INTO l_adhocuser_lang, l_adhocuser_territory, l_lang_code
                FROM wf_languages wfl, fnd_languages_vl flv
                WHERE wfl.code = flv.language_code AND flv.nls_language = l_vendor_site_lang;
        ELSE
                SELECT wfl.nls_language, wfl.nls_territory,wfl.code into l_adhocuser_lang, l_adhocuser_territory, l_lang_code
                FROM wf_languages wfl, fnd_languages_vl flv
                WHERE wfl.code = flv.language_code AND flv.installed_flag = 'B';
        END IF;
        --EMAILPO FPH END--

        /* Bug 9254430 */
 	     /* The Message sent to Supplier should be in Supplier Language if
 	     Suppliers language is different from Buyers language */
 	         IF l_vendor_site_lang is  NOT NULL then
 	         BEGIN
           x_progress := '003';
 	         -- SQL What : Get the message in the Supliers language.
 	           SELECT message_text
 	            INTO l_note
 	            FROM fnd_new_messages fm,
 	                 fnd_languages fl
 	            WHERE fm.message_name = 'PO_PDF_EMAIL_TEXT'
 	              AND fm.language_code = fl.language_code
 	              AND fl.nls_language = l_vendor_site_lang;
 	         EXCEPTION
 	            WHEN OTHERS THEN
 	               NULL;
 	         END;
 	         PO_WF_UTIL_PKG.SetItemAttrText( itemtype => itemtype,
 	                                         itemkey => itemkey,
 	                                         aname => 'EMAIL_TEXT_WITH_PDF',
 	                                         avalue => l_note);
 	         END IF;
 	     /* End Bug 9254430 */

       /*Begin Bug 9283386 Setting DOCUMENT_DISPLAY_NAME in l_lang_code*/
       -- bug 17213213: Get style display name only for SPO,BPA,CPA
       if (l_document_type = 'PA' AND l_document_subtype IN ('BLANKET','CONTRACT')) OR
         (l_document_type = 'PO' AND l_document_subtype =   'STANDARD')  then
          l_doc_display_name := PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(l_po_header_id,l_lang_code);
       else
          OPEN docDisp(l_document_type, l_document_subtype);
          FETCH docDisp into l_doc_display_name;
          CLOSE docDisp;
       end if;
      wf_engine.SetItemAttrText (itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_DISPLAY_NAME',
                                 avalue          =>  l_doc_display_name);

      l_doc_display_name:=wf_engine.getItemAttrText (itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_DISPLAY_NAME');
   /*End Bug 9283386*/

   --START of code changes done as part of Multiple email addresses Bug# 16043012
    IF instr(l_po_email_add,',') > 0 THEN
      IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'inside multiple email logic.....');
      END IF;
      l_role := null;
      l_counter := 1;
      l_hold_email := l_po_email_add;

      LOOP
        IF InStr(l_hold_email,',')>0 THEN
          l_email_address := substr(l_hold_email,1,instr(l_hold_email,',')-1);
        ELSE
          l_email_address := l_hold_email;
        END IF;
        l_po_email_performer := l_email_address||'.'||l_adhocuser_lang;
        l_po_email_performer:= Upper(l_po_email_performer);
        l_display_name := l_email_address;

        select count(1) into l_performer_exists from wf_users where name = l_po_email_performer;

        if (l_performer_exists = 0) then
          WF_DIRECTORY.CreateAdHocUser(l_po_email_performer,
	  			       l_display_name,
				       l_adhocuser_lang,
				       l_adhocuser_territory,
				       null,
				       l_notification_preference,
				       l_email_address,
				       null,
				       'ACTIVE',
				       null);
        else
          WF_DIRECTORY.SETADHOCUSERATTR(l_po_email_performer,
	  			        l_display_name,
					l_notification_preference,
					l_adhocuser_lang,
					l_adhocuser_territory,
					l_email_address,
					null);
        end if;

        l_role_users(l_counter) := l_po_email_performer;
	      l_counter := l_counter + 1;
	      if instr(l_hold_email,',') > 0 then
		      l_hold_email := ltrim(rtrim(substr(l_hold_email,instr(l_hold_email,',')+1),', '),', ');
	      else
		      exit;
	      end if;
	      if instr(l_hold_email,'@') = 0 then
		      exit;
	      end if;
      END LOOP;

      l_display_role_name := null;
      l_role := null;
      WF_DIRECTORY.createAdhocRole2(role_name => l_role,
		  role_display_name => l_display_role_name,
		  role_users => l_role_users,
		  notification_preference => 'MAILHTM2');

      IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'inside multiple email logic...After creating the Adhoc role..');
      END IF;

      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                      itemkey => itemkey,
                                      aname => 'PO_WF_EMAIL_PERFORMER',
                                      avalue => l_role);

    ELSE


    /* Bug 2989951. AdHocUser Name should be concatenation of the E-mail Address and the language */
          l_po_email_performer := l_po_email_add||'.'||l_adhocuser_lang;
          l_po_email_performer := upper(l_po_email_performer);

          l_display_name := l_po_email_add; --Bug 18046156 fix

     select count(*) into l_performer_exists
     from wf_users where name = l_po_email_performer;
     /* Bug 2864242 The wf_local_users table is obsolete after the patch 2350501. So used the
        wf_users view instead of wf_local_users table */


     x_progress := '004';

     if (l_performer_exists = 0) then
        --EMAILPO FPH--
        -- Pass in the correct adhocuser language and territory for CreateAdHocUser and SetAdhocUserAttr instead of null
        WF_DIRECTORY.CreateAdHocUser(l_po_email_performer, l_display_name, l_adhocuser_lang, l_adhocuser_territory, null, l_notification_preference,         l_po_email_add, null, 'ACTIVE', null);

      else
        WF_DIRECTORY.SETADHOCUSERATTR(l_po_email_performer, l_display_name, l_notification_preference, l_adhocuser_lang, l_adhocuser_territory,        l_po_email_add, null);

      end if;

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'PO_WF_EMAIL_PERFORMER',
                                    avalue    =>  l_po_email_performer);

    END IF;
    --End of code changes for the Multiple Email Address issue- Bug# 16043012

     /* set the  performer from thr profilr to send the second email */
     /* Bug 2989951. Secondary AdHocUser Name should be concatenation of the Secondary E-mail Address and the language

     l_po_email_performer_prof := 'PO_SECONDRY_EMAIL_ADD';
     l_display_name_prof := 'PO_SECONDRY_EMAIL_ADD'; */

     l_po_email_performer_prof := l_po_email_add_prof||'.'||l_adhocuser_lang;
     l_po_email_performer_prof := upper(l_po_email_performer_prof);
--ER 5688144: correct the display name of Secondary E-mail Address
     l_display_name_prof := l_po_email_add_prof;
--ER 5688144: End

     select count(*) into l_performer_exists
     from wf_users where name = l_po_email_performer_prof;
     /* Bug 2864242 The wf_local_users table is obsolete after the patch 2350501. So used the
        wf_users view instead of wf_local_users table */


         --EMAILPO FPH START--
         -- For second email also the language and territory settings should be same as for the first one above
         x_progress := '005';
     if (l_performer_exists = 0) then

        WF_DIRECTORY.CreateAdHocUser(l_po_email_performer_prof, l_display_name_prof, l_adhocuser_lang, l_adhocuser_territory, null, l_notification_preference,         l_po_email_add_prof, null, 'ACTIVE', null);

      else
        WF_DIRECTORY.SETADHOCUSERATTR(l_po_email_performer_prof, l_display_name_prof, l_notification_preference, l_adhocuser_lang, l_adhocuser_territory,        l_po_email_add_prof, null);

      end if;
        --EMAILPO FPH END--

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'PO_WF_EMAIL_PERFORMER2',
                                    avalue    =>  l_po_email_performer_prof);



    x_progress := '006';


    -- bug 4727400 : updates need to autonomous, PA needs to be take care of.
       update_print_count(l_document_id,l_document_type);

    --Bug#2843760: Moved portion of code which does the PO archiving to internal procedure ARCHIVE_PO
        ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);


  END IF;


   resultout := wf_engine.eng_completed || ':' || l_email_doc ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: 02. Result= ' || l_email_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- resultout := wf_engine.eng_completed || ':' || 'Y' ;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No',x_progress||':'||sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.EMAIL_DOC_YES_NO');
    raise;

END Email_Doc_Yes_No;


-- Print_Document
--   Resultout
--     ACTIVITY_PERFORMED
--   Print Document.

procedure Print_Document(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_print_doc   varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 02';

  PrintDocument(itemtype,itemkey);
  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 03';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Print_Document',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.PRINT_DOCUMENT');
    raise;

END Print_Document;




-- Procedure called by wf.
-- DKC 10/10/99
procedure Fax_Document(     itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_fax_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 02';

  FaxDocument(itemtype,itemkey);
  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 03';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Fax_Document',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOCUMENT');
    raise;

END Fax_Document;






-- Is_document_Approved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Is the document already approved. This may be the case if the document
--   was PRE-APPROVED before it goes through the reserve action. The RESERVE
--   would then approve the doc after it reserved the funds.

procedure Is_document_Approved(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_auth_stat   varchar2(25);
l_doc_type varchar2(25);
l_doc_id       number;
l_orgid       number;
x_resultout   varchar2(1);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Is_document_Approved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2377333
  ** Setting application context
  */
  --Context Setting Revamp
  --PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
  IF l_doc_type='REQUISITION' THEN

    x_progress := '002';

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;


  ELSIF l_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

  ELSIF l_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

   END IF;

  IF l_auth_stat = 'APPROVED' THEN

     resultout := wf_engine.eng_completed || ':' || 'Y' ;
     x_resultout := 'Y';
  ELSE
     resultout := wf_engine.eng_completed || ':' || 'N';
     x_resultout := 'N';
  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_document_Approved: 02. Result=' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_document_Approved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_DOCUMENT_APPROVED');
    raise;


END Is_document_Approved;

-- Get_Create_PO_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed

procedure Get_Create_PO_Mode(itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       out NOCOPY varchar2    ) is
l_create_po_mode  VARCHAR2(1);
x_progress        varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN


   x_progress := 'PO_REQAPPROVAL_INIT1.Get_Create_PO_Mode: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_create_po_mode := wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'SEND_CREATEPO_TO_BACKGROUND');

  /* Bug 678291 by dkfchan
  ** if the approval mode is background, set the result to 'BACKGROUD'
  ** Removed the original method which set the WF_ENGINE.THRESHOLD to -1.
  ** This fix depends on the change poxwfrqa.wft and poxwfpoa.wft also.
  */

  IF NVL(l_create_po_mode,'N') = 'Y' THEN
    resultout := wf_engine.eng_completed || ':' ||  'BACKGROUND';
  ELSE
    resultout := wf_engine.eng_completed || ':' ||  'ONLINE';
  END IF;

  x_progress :=  'PO_REQAPPROVAL_INIT1.Get_Create_PO_Mode: ' ||
                 'Create PO Mode= ' || l_create_po_mode;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Create_PO_Mode',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_CREATE_PO_MODE');
    raise;

END Get_Create_PO_Mode;

-- Get_Workflow_Approval_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      On-line
--      Background

procedure Get_Workflow_Approval_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_approval_mode   VARCHAR2(30);
x_progress              varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  /* get the profile PO_WORKFLOW_APPROVAL_MODE and return the value */

   x_progress := 'PO_REQAPPROVAL_INIT1.Get_Workflow_Approval_Mode: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  fnd_profile.get('PO_WORKFLOW_APPROVAL_MODE', l_approval_mode);

  /* Bug 678291 by dkfchan
  ** if the approval mode is background, set the result to 'BACKGROUD'
  ** Removed the original method which set the WF_ENGINE.THRESHOLD to -1.
  ** This fix depends on the change poxwfrqa.wft and poxwfpoa.wft also.
  */

  IF l_approval_mode =  'BACKGROUND' or l_approval_mode is NULL THEN
    resultout := wf_engine.eng_completed || ':' ||  'BACKGROUND';
  ELSE
    resultout := wf_engine.eng_completed || ':' ||  'ONLINE';
  END IF;

  x_progress :=  'PO_REQAPPROVAL_INIT1.Get_Workflow_Approval_Mode: ' ||
                 'Approval Mode= ' || l_approval_mode;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Workflow_Approval_Mode',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_WORKFLOW_APPROVAL_MODE');
    raise;

END Get_Workflow_Approval_Mode;

-- Dummy
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed
-- Dummy procedure that does nothing (NOOP). Used to set the
-- cost above the backgound engine threshold. This causes the
-- workflow to execute in the background.
procedure Dummy(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is

BEGIN

  /* Do nothing */
  NULL;

END Dummy;



/****************************************************************************
* The Following are the supporting APIs to the workflow functions.
* These API's are Private (Not declared in the Package specs).
****************************************************************************/

procedure GetReqAttributes(p_requisition_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2) is

l_line_num varchar2(80);
x_progress varchar2(100) := '000';

counter NUMBER:=0;
BEGIN


  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Fetch the Req Header, then set the attributes.  */
  open GetRecHdr_csr(p_requisition_header_id);
  FETCH GetRecHdr_csr into ReqHdr_rec;
  close GetRecHdr_csr;

  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  SetReqHdrAttributes(itemtype, itemkey);

  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','GetReqAttributes',x_progress);
        raise;

end GetReqAttributes;
--


--------------------------------------------------------------------------------
--Start of Comments
--Name: getReqAmountInfo
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  convert req total, req amount, req tax into approver preferred currency for display
--Parameters:
--IN:
--itemtype
--  workflow item type
--itemtype
--  workflow item key
--p_function_currency
--  functional currency
--p_total_amount_disp
--  req total including tax, in displayable format
--p_total_amount
--  req total including tax, number
--p_req_amount_disp
--  req total without including tax, in displayable format
--p_req_amount
--  req total without including tax, number
--p_tax_amount_disp
--  req tax, in displayable format
--p_tax_amount
--  req tax number
--OUT:
--p_amount_for_subject
--p_amount_for_header
--p_amount_for_tax
--End of Comments
-------------------------------------------------------------------------------
procedure getReqAmountInfo(itemtype        in varchar2,
                          itemkey         in varchar2,
                          p_function_currency in varchar2,
                          p_total_amount_disp in varchar2,
                          p_total_amount in number,
                          p_req_amount_disp in varchar2,
                          p_req_amount in number,
                          p_tax_amount_disp in varchar2,
                          p_tax_amount in number,
                          x_amount_for_subject out nocopy varchar2,
                          x_amount_for_header out nocopy varchar2,
                          x_amount_for_tax out nocopy varchar2) is

  l_rate_type po_system_parameters.default_rate_type%TYPE;
  l_rate number;
  l_denominator_rate number;
  l_numerator_rate number;
  l_approval_currency varchar2(30);
  l_amount_disp varchar2(60);
  l_amount_approval_currency number;
  l_approver_user_name fnd_user.user_name%TYPE;
  l_user_id fnd_user.user_id%TYPE;
  l_progress varchar2(200);
  l_no_rate_msg varchar2(200);

begin
  SELECT  default_rate_type
  INTO l_rate_type
  FROM po_system_parameters;

  l_progress := 'getReqAmountInfo:' || l_rate_type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_approver_user_name := PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_USER_NAME');
  if (l_approver_user_name is not null) then
    SELECT user_id
    INTO l_user_id
    FROM fnd_user
    WHERE user_name = l_approver_user_name;

    l_progress := 'getReqAmountInfo:' || l_user_id;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_approval_currency := FND_PROFILE.VALUE_SPECIFIC('ICX_PREFERRED_CURRENCY', l_user_id);
  end if;

  if (l_approval_currency = p_function_currency or l_approver_user_name is null
      or l_rate_type is null or l_approval_currency is null) then
    x_amount_for_subject := p_total_amount_disp || ' ' || p_function_currency;
    x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
    x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
    return;
  end if;

  l_progress := 'getReqAmountInfo:' || l_approval_currency;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  gl_currency_api.get_closest_triangulation_rate(
                  x_from_currency => p_function_currency,
                  x_to_currency => l_approval_currency,
                  x_conversion_date => sysdate,
                  x_conversion_type => l_rate_type,
                  x_max_roll_days  => 5,
                  x_denominator => l_denominator_rate,
                  x_numerator => l_numerator_rate,
                  x_rate => l_rate);


  l_progress := 'getReqAmountInfo:' || substrb(to_char(l_rate), 1, 30);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  /* setting amount for notification subject */
  l_amount_approval_currency := (p_total_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));
  x_amount_for_subject := l_amount_disp || ' ' || l_approval_currency;

  /* setting amount for header attribute */
  l_amount_approval_currency := (p_req_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  l_progress := 'getReqAmountInfo:' || l_amount_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

  l_amount_approval_currency := (p_tax_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

exception
when gl_currency_api.no_rate then
  l_progress := 'getReqAmountInfo: no rate';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_req_amount_disp || ' ' || p_function_currency;

  l_no_rate_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_RATE');
  l_no_rate_msg := replace (l_no_rate_msg, '&CURRENCY', l_approval_currency);

  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_no_rate_msg || ')';

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_no_rate_msg || ')';

when others then

  l_progress := 'getReqAmountInfo:' || substrb(SQLERRM, 1,200);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;

end;

procedure SetReqHdrAttributes(itemtype in varchar2, itemkey in varchar2) is

x_progress varchar2(200) := '000';

l_auth_stat  varchar2(80);
l_closed_code varchar2(80);
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_doc_type_disp varchar2(240); /* Bug# 2616355: kagarwal */
-- l_doc_subtype_disp varchar2(80);

l_req_amount        number;
l_req_amount_disp   varchar2(60);
l_tax_amount        number;
l_tax_amount_disp   varchar2(60);
l_total_amount      number;
l_total_amount_disp varchar2(60);

l_amount_for_subject varchar2(400);
l_amount_for_header varchar2(400);
l_amount_for_tax varchar2(400);
-- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
---------------------------------------------------------------------------
ln_jai_excl_nr_tax       number;              --exclusive non-recoverable tax
lv_tax_region            varchar2(30);        --tax region code
---------------------------------------------------------------------------
-- Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End

/* Bug# 1162252: Amitabh
** Desc: Changed the length of l_currency_code from 8 to 30
**       as the call to PO_CORE_S2.get_base_currency would
**       return varchar2(30).
*/

l_currency_code     varchar2(30);
l_doc_id            number;

/* Bug 1100247: Amitabh
*/
x_username    varchar2(100);
x_user_display_name varchar2(240);

/* Bug 2830992
 */
l_num_attachments number;
 /*Start Bug#3406460 */
 l_precision        number;
 l_ext_precision    number;
 l_min_acct_unit    number;
 /*End Bug#3406460  */
cursor c1(p_auth_stat varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='AUTHORIZATION STATUS'
  and lookup_code = p_auth_stat;

cursor c2(p_closed_code varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT STATE'
  and lookup_code = p_closed_code;

/* Bug# 2616355: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor c3(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;

/*
cursor c4(p_doc_subtype varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='REQUISITION TYPE'
  and lookup_code = p_doc_subtype;
*/

/* Bug# 1470041: kagarwal
** Desc: Modified the cursor req_total_csr for calculating the Req Total
** in procedure SetReqHdrAttributes() to ignore the Req lines modified using
** the modify option in the autocreate form.
**
** Added condition:
**                 AND  NVL(modified_by_agent_flag, 'N') = 'N'
*/
/*Start Bug#3406460 - Added precision parameter to round the line amount*/
cursor req_total_csr(p_doc_id number,l_precision number) is
   SELECT nvl(SUM(round(decode(order_type_lookup_code,
                         'RATE', amount,
                         'FIXED PRICE', amount,
                         quantity * unit_price),l_precision)) ,0)
   FROM   po_requisition_lines
   WHERE  requisition_header_id = p_doc_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';
/*End Bug#3406460*/
/* Bug# 2483898: kagarwal
** Desc:  When calculating the Tax for Requisitons submitted for approval,
** the cancelled requisition lines should be ignored. Also the lines modified in
** the autocreate form using the modify option should also be ignored.
*/

cursor req_tax_csr(p_doc_id number) is
   SELECT nvl(sum(nonrecoverable_tax), 0)
   FROM   po_requisition_lines rl,
          po_req_distributions_all rd  -- <R12 MOAC>
   WHERE  rl.requisition_header_id = p_doc_id
     AND  rd.requisition_line_id = rl.requisition_line_id
     AND  NVL(rl.cancel_flag,'N') = 'N'
     AND  NVL(rl.modified_by_agent_flag, 'N') = 'N';

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'DOCUMENT_NUMBER',
                                   avalue     =>  ReqHdr_rec.segment1);
   --
   wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'DOCUMENT_ID',
                                   avalue     => ReqHdr_rec.requisition_header_id);
   --
   wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'PREPARER_ID',
                                   avalue     => ReqHdr_rec.preparer_id);
   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS',
                                   avalue     =>  ReqHdr_rec.authorization_status);
   --

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_DESCRIPTION',
                                   avalue      =>  ReqHdr_rec.description);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE',
                                   avalue      =>  ReqHdr_rec.closed_code);
   --

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'EMERGENCY_PO_NUMBER',
                                   avalue      =>  ReqHdr_rec.emergency_po_num);
   --

   -- Bug#3147435
   x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 02 Start of Hdr Att for JRAD';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   -- Bug#3147435
   --Set the CONTRACTOR_REQUISITION_FLAG
   PO_WF_UTIL_PKG.SetItemAttrText (itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CONTRACTOR_REQUISITION_FLAG',
                                   avalue      =>  ReqHdr_rec.contractor_requisition_flag);
   --

   -- Bug#3147435
   --Set the CONTRACTOR_STATUS
   PO_WF_UTIL_PKG.SetItemAttrText (itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CONTRACTOR_STATUS',
                                   avalue      =>  ReqHdr_rec.contractor_status);
   --

   -- Bug#3147435
   x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 03 End of Hdr Att for JRAD';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

/* Bug 1100247  Amitabh*/
   PO_REQAPPROVAL_INIT1.get_user_name(ReqHdr_rec.preparer_id, x_username,
                                      x_user_display_name);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

   /* Get the translated values for the DOC_TYPE, DOC_SUBTYPE, AUTH_STATUS and
   ** CLOSED_CODE. These will be displayed in the notifications.
   */
  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   OPEN C1(ReqHdr_rec.authorization_status);
   FETCH C1 into l_auth_stat;
   CLOSE C1;

   OPEN C2(ReqHdr_rec.closed_code);
   FETCH C2 into l_closed_code;
   CLOSE C2;

/* Bug# 2616355: kagarwal */

   OPEN C3(l_doc_type, l_doc_subtype);
   FETCH C3 into l_doc_type_disp;
   CLOSE C3;

/*
   OPEN C4(l_doc_subtype);
   FETCH C4 into l_doc_subtype_disp;
   CLOSE C4;
*/

   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS_DISP',
                                   avalue     =>  l_auth_stat);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE_DISP',
                                   avalue      =>  l_closed_code);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_TYPE_DISP',
                                   avalue      =>  l_doc_type_disp);
   --
/* Bug# 2616355: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/
/*
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_SUBTYPE_DISP',
                                   avalue      =>  l_doc_subtype_disp);
*/

   l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_currency_code := PO_CORE_S2.get_base_currency;
/*Start Bug#3406460 - call to fnd function to get precision */
   fnd_currency.get_info(l_currency_code,
                         l_precision,
                        l_ext_precision,
                         l_min_acct_unit);
/* End Bug#3406460*/

    OPEN req_total_csr(l_doc_id,l_precision); --Bug#3406460  added parameter X_precision
   FETCH req_total_csr into l_req_amount;
   CLOSE req_total_csr;

   /* For REQUISITIONS, since every line could have a different currency, then
   ** will show the total in the BASE/FUNCTIONAL currency.
   ** For POs, we will show it in the Document currency specified by the user.
   */

   l_req_amount_disp := TO_CHAR(l_req_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'FUNCTIONAL_CURRENCY',
                                   avalue      =>  l_currency_code);

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_AMOUNT_DSP',
                                   avalue      =>  l_req_amount_disp);

  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,Begin
  ---------------------------------------------------------------------------
  --get tax region
  lv_tax_region   := JAI_PO_WF_UTIL_PUB.get_tax_region
	                   ( pv_document_type => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
	                   , pn_document_id   => l_doc_id
	                   );

  IF (lv_tax_region ='JAI')
  THEN
    --Get IL tax
    JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REQ_DOC_TYPE
	                                 , pn_document_id        => l_doc_id
	                                 , xn_excl_tax_amount    => l_tax_amount
	                                 , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
                                         );
  ELSE
    --Get Standard Ebtax
    OPEN req_tax_csr(l_doc_id);
    FETCH req_tax_csr into l_tax_amount;
    CLOSE req_tax_csr;
  END IF;  --(lv_tax_region ='JAI')
  ---------------------------------------------------------------------------
  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,End

  l_tax_amount_disp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP',
                                   avalue      =>  l_tax_amount_disp);

  l_total_amount := l_req_amount + l_tax_amount;

  l_total_amount_disp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));


  /* bug 3105327
     support approval currency in notification header and subject
     because TOTAL_AMOUNT_DSP is only used in notification,
     this bug fix changes the meaning of this attribute from total to
     total with currency;
     the workflow definition is modified such that
     currency atribute is removed from the subject.
   */
  getReqAmountInfo(itemtype => itemtype,
                          itemkey => itemkey,
                          p_function_currency => l_currency_code,
                          p_total_amount_disp => l_total_amount_disp,
                          p_total_amount => l_total_amount,
                          p_req_amount_disp => l_req_amount_disp,
                          p_req_amount => l_req_amount,
                          p_tax_amount_disp => l_tax_amount_disp,
                          p_tax_amount => l_tax_amount,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);
  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,Begin
  ---------------------------------------------------------------------------
  IF (lv_tax_region ='JAI')
  THEN
     --format the non recoverable tax for display
     l_amount_for_tax := JAI_PO_WF_UTIL_PUB.Get_Jai_Req_Tax_Disp
                         ( pn_jai_excl_nr_tax =>ln_jai_excl_nr_tax
                         , pv_total_tax_dsp   =>l_amount_for_tax
                         , pv_currency_code   =>l_currency_code
                         , pv_currency_mask   =>g_currency_format_mask
                         ) ;
  END IF; -- (lv_tax_region ='JAI')
  ---------------------------------------------------------------------------
  --Modified by Eric Ma for IL PO Notification on Apr-13,2009,End

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TOTAL_AMOUNT_DSP',
                                   avalue      =>  l_amount_for_subject);

  /* begin bug 2480327 notification UI enhancement */

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_header);

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_tax);


    PO_WF_UTIL_PKG.SetItemAttrDocument(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'ATTACHMENT',
                            documentid   =>
   'FND:entity=REQ_HEADERS' || '&' || 'pk1name=REQUISITION_HEADER_ID' ||
   '&' || 'pk1value='|| ReqHdr_rec.requisition_header_id);

  /* end bug 2480327 notification UI enhancement */

  x_progress := 'SetReqHdrAttributes (end): : ' || l_auth_stat ||
                l_currency_code || l_req_amount_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if (ReqHdr_rec.NOTE_TO_AUTHORIZER is not null) then
    PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'JUSTIFICATION',
                                   avalue      =>  ReqHdr_rec.NOTE_TO_AUTHORIZER);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetReqHdrAttributes',x_progress);
        raise;


end SetReqHdrAttributes;

/* added as part of bug 10399957 - deadlock issue during updating comm_rev_num value */
PROCEDURE Set_Comm_Rev_Num(l_doc_type IN VARCHAR2,
                           l_po_header_id IN NUMBER,
                           l_po_revision_num_curr IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

  SAVEPOINT save_rev_num;

  IF l_doc_type IN ('PO', 'PA') THEN

  	UPDATE po_headers_all
	  SET comm_rev_num = l_po_revision_num_curr
  	WHERE po_header_id = l_po_header_id;

    -- added for bug 9072034 (to update revision number for releases.)
  ELSIF l_doc_type in ('RELEASE') THEN

  	UPDATE po_releases_all
	  SET comm_rev_num = l_po_revision_num_curr
    WHERE po_release_id = l_po_header_id;

  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO save_rev_num;
    wf_core.context('PO_REQAPPROVAL_INIT1','Set_Comm_Rev_Num',x_progress);
        raise;

End Set_Comm_Rev_Num;
--
--  procedure SetReqAuthStat, SetPOAuthStat, SetRelAuthStat
--    This procedure sets the document status to IN PROCESS, if called at the beginning of the
--    Approval Workflow,
--    or to INCOMPLETE if doc failed STATE VERIFICATION or COMPLETENESS check at the
--    beginning of WF,
--    or to it's original status if No Approver was found or doc failed STATE VERIFICATION
--    or COMPLETENESS check before APPROVE, REJECT or FORWARD

procedure SetReqAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2,note varchar2,
                         p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_requisition_header_id number;
x_progress varchar2(3):= '000';

BEGIN

  l_requisition_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */

/* Bug# 1894960: kagarwal
** Desc: Requisitons Upgraded from 10.7 fails to set the status of Requisiton
** to Pre-Approved.
**
** Reason being that when the procedure SetReqAuthStat() is called to set the
** Requisiton status to Pre-Approved, the conditon
** "IF (note = 'UPGRADE_TO_R11')" do not set the authorization status causes
** the Requisiton to remain in the existing status.
** Hence the Upgraded Requisitons can never be set to 'Pre-Approved' status and
** the approval process will always return the Req with Notification
** "No Approver Found".
**
** Whereas the reason for this condition was to not set the status of upgrade
** Reqs to IN PROCESS as it could have been PRE-APPROVED.
**
** Changed the procedure SetReqAuthStat().
**
** Modified the clause IF note = 'UPGRADE_TO_R11'
**
** TO:
**
** IF (note = 'UPGRADE_TO_R11' and p_auth_status = 'IN PROCESS') THEN
**
** Now when the approval process will  call the procedure SetReqAuthStat()
** to set the Requisiton to 'Pre-Approved' status then it will go to the
** else part and set its authorization status to 'Pre-Approved'.
*/

  IF (note = 'UPGRADE_TO_R11' and p_auth_status = 'IN PROCESS') THEN

    update po_requisition_headers set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    active_shopping_cart_flag = NULL,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where requisition_header_id = l_requisition_header_id;

  ELSE

    update po_requisition_headers set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    active_shopping_cart_flag = NULL,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where requisition_header_id = l_requisition_header_id;

  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetReqAuthStat',x_progress);
        raise;

END SetReqAuthStat;

--
procedure SetPOAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                        p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_po_header_id  NUMBER;
x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  l_po_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */
  IF note = 'UPGRADE_TO_R11' THEN

    update po_headers set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_header_id = l_po_header_id;

  ELSE

    update po_headers set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    ,submit_date = decode(p_auth_status,
              'INCOMPLETE', to_date(null),submit_date)   --<DBI Req Fulfillment 11.5.11>
    where po_header_id = l_po_header_id;
  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetPOAuthStat',x_progress);
        raise;

END SetPOAuthStat;

--
procedure SetRelAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_Release_header_id  NUMBER;
x_progress varchar2(3):= '000';

BEGIN

   x_progress := '001';

  l_Release_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */
  IF note = 'UPGRADE_TO_R11' THEN

    update po_releases   set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_release_id = l_Release_header_id;

  ELSE

    update po_releases   set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    ,submit_date = decode(p_auth_status,
              'INCOMPLETE', to_date(null),submit_date)   --<DBI Req Fulfillment 11.5.11>
    where po_release_id = l_Release_header_id;
  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetRelAuthStat',x_progress);
        raise;

END SetRelAuthStat;
--
--
procedure UpdtReqItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;
x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_requisition_headers   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  where requisition_header_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtReqItemtype',x_progress);
        raise;

END UpdtReqItemtype;

--
procedure UpdtPOItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_headers   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  ,submit_date            = sysdate       --<DBI Req Fulfillment 11.5.11>
  where po_header_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtPOItemtype',x_progress);
        raise;

END UpdtPOItemtype;


--
procedure UpdtRelItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_releases   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  ,submit_date            = sysdate       --<DBI Req Fulfillment 11.5.11>
  where po_release_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtRelItemtype',x_progress);
        raise;

END UpdtRelItemtype;

--
procedure GetCanOwnerApprove(itemtype in varchar2,itemkey in varchar2,
                             CanOwnerApproveFlag out NOCOPY varchar2)
is

Cursor C1(p_document_type_code VARCHAR2, p_document_subtype VARCHAR2) is
 select NVL(can_preparer_approve_flag,'N')
 from po_document_types
 where document_type_code = p_document_type_code
 and   document_subtype = p_document_subtype;

l_document_type_code VARCHAR2(25);
l_document_subtype   VARCHAR2(25);
x_progress varchar2(3):= '000';

BEGIN

 x_progress := '001';
 l_document_type_code := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

 l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  open C1(l_document_type_code, l_document_subtype);
  Fetch C1 into CanOwnerApproveFlag;
  close C1;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','GetCanOwnerApprove',x_progress);
        raise;

END GetCanOwnerApprove;
--

/*****************************************************************************
*
*  Supporting APIs declared in the package spec.
*****************************************************************************/


PROCEDURE get_multiorg_context(document_type varchar2, document_id number,
                               x_orgid IN OUT NOCOPY number) is

cursor get_req_orgid is
  select org_id
  from po_requisition_headers_all
  where requisition_header_id = document_id;

cursor get_po_orgid is
  select org_id
  from po_headers_all
  where po_header_id = document_id;

cursor get_release_orgid is
  select org_id
  from po_releases_all
  where po_release_id = document_id;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';
  IF document_type = 'REQUISITION' THEN


     OPEN get_req_orgid;
     FETCH get_req_orgid into x_orgid;
     CLOSE get_req_orgid;

  ELSIF document_type IN ( 'PO','PA' ) THEN

     OPEN get_po_orgid;
     FETCH get_po_orgid into x_orgid;
     CLOSE get_po_orgid;

  ELSIF document_type = 'RELEASE' THEN

     OPEN get_release_orgid ;
     FETCH get_release_orgid into x_orgid;
     CLOSE get_release_orgid;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_multiorg_context',x_progress);
        raise;

END get_multiorg_context;


--
PROCEDURE get_employee_id(p_username IN varchar2, x_employee_id OUT NOCOPY number) is

-- DEBUG: Is this the best way to get the emp_id of the username
--        entered as a forward-to in the notification?????
--
  /* 1578061 add orig system condition to enhance performance. */

  cursor c_empid is
    select ORIG_SYSTEM_ID
    from   wf_users WF
    where  WF.name     = p_username
      and  ORIG_SYSTEM NOT IN ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

x_progress varchar2(3):= '000';

BEGIN

    open  c_empid;
    fetch c_empid into x_employee_id;

    /* DEBUG: get Vance and Kevin opinion on this:
    ** If no employee_id is found then return null. We will
    ** treat that as the user not supplying a forward-to username.
    */
    IF c_empid%NOTFOUND  THEN

       x_employee_id := NULL;

    END IF;

    close c_empid;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_employee_id',p_username);
        raise;


END get_employee_id;


--
PROCEDURE get_user_name(p_employee_id IN number, x_username OUT NOCOPY varchar2,
                        x_user_display_name OUT NOCOPY varchar2) is

p_orig_system  varchar2(20);

BEGIN

  p_orig_system:= 'PER';

  WF_DIRECTORY.GetUserName(p_orig_system,
                           p_employee_id,
                           x_username,
                           x_user_display_name);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_user_name',to_char(p_employee_id));
        raise;

END get_user_name;


--
PROCEDURE InsertActionHistSubmit(itemtype varchar2, itemkey varchar2,
                                 p_doc_id number, p_doc_type varchar2,
                                 p_doc_subtype varchar2, p_employee_id number,
                                 p_action varchar2, p_note varchar2,
                                 p_path_id number) is

pragma AUTONOMOUS_TRANSACTION;

l_auth_stat varchar2(25);
l_action_code varchar2(25);
l_revision_num number := NULL;
l_hist_count   number := NULL;
l_sequence_num   number := NULL;
l_approval_path_id number;

CURSOR action_hist_cursor(doc_id number , doc_type varchar2) is
   select max(sequence_num)
   from po_action_history
   where object_id= doc_id and
   object_type_code = doc_type;

CURSOR action_hist_code_cursor (doc_id number , doc_type varchar2, seq_num number) is
   select action_code
   from po_action_history
   where object_id = doc_id and
   object_type_code = doc_type and
   sequence_num = seq_num;


x_progress varchar2(3):='000';

l_transaction_type po_doc_style_headers.ame_transaction_type%TYPE;

BEGIN

  /* Get the document authorization status.
  ** has been submitted before, i.e.
  ** First insert a row with  a SUBMIT action.
  ** Then insert a row with a NULL ACTION_CODE to simulate the forward-to
  ** since the doc status has been changed to IN PROCESS.
  */

  x_progress := '001';

  l_approval_path_id := p_path_id;

  IF p_doc_type='REQUISITION' THEN

    x_progress := '002';

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = p_doc_id;


  ELSIF p_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select NVL(authorization_status,'INCOMPLETE'),revision_num, ame_transaction_type
             into l_auth_stat, l_revision_num, l_transaction_type
      from PO_HEADERS
      where po_header_id = p_doc_id;

  ELSIF p_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select NVL(authorization_status,'INCOMPLETE'),revision_num
             into l_auth_stat, l_revision_num
      from PO_RELEASES
      where po_release_id = p_doc_id;

   END IF;

   x_progress := '005';

   /* Check if this document had been submitted to workflow at some point
   ** and somehow kicked out. If that's the case, the sequence number
   ** needs to be incremented by one. Otherwise start at zero.
   */
   OPEN action_hist_cursor(p_doc_id , p_doc_type );
   FETCH action_hist_cursor into l_sequence_num;
   CLOSE action_hist_cursor;
   IF l_sequence_num is NULL THEN
      l_sequence_num := 1; --Bug 13370924
   ELSE
      OPEN action_hist_code_cursor(p_doc_id , p_doc_type, l_sequence_num);
      FETCH action_hist_code_cursor into l_action_code;
      l_sequence_num := l_sequence_num +1;
   END IF;


   x_progress := '006';
   IF ((l_sequence_num = 1)
        OR
       (l_sequence_num > 1 and l_action_code is NOT NULL)) THEN
      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              p_action,
              decode(p_action, '',to_date(null), sysdate),
              p_employee_id,
              p_note,
              l_revision_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );

    ELSE
        l_sequence_num := l_sequence_num - 1;
        UPDATE PO_ACTION_HISTORY
          set object_id = p_doc_id,
              object_type_code = p_doc_type,
              object_sub_type_code = p_doc_subtype,
              sequence_num = l_sequence_num,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              creation_date = sysdate,
              created_by = fnd_global.user_id,
              action_code = p_action,
              action_date = decode(p_action, '',to_date(null), sysdate),
              employee_id = p_employee_id,
              note = p_note,
              object_revision_num = l_revision_num,
              last_update_login = fnd_global.login_id,
              request_id = 0,
              program_application_id = 0,
              program_id = 0,
              program_update_date = '',
              approval_path_id = l_approval_path_id,
              offline_code = ''
        WHERE
              object_id= p_doc_id and
              object_type_code = p_doc_type and
              sequence_num = l_sequence_num;

    END IF;

    -- iProcurement: Approval History changes.
    -- Null action code will not be inserted into po_action_history table.

    -- bug4643013
    -- Still insert null action during submission except for requisition

    /*AME Project - Inserting NULL action only when AME is not used*/

    IF (p_doc_type <> 'REQUISITION' AND l_transaction_type IS NULL) THEN

      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num + 1,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              NULL,              -- ACTION_CODE
              decode(p_action, '',to_date(null), sysdate),
              p_employee_id,
              NULL,
              l_revision_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              0,
              '' );
    END IF;

    x_progress := '007';

commit;
EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','InsertActionHistSubmit',x_progress);
        raise;

END InsertActionHistSubmit;


--

-- <ENCUMBRANCE FPJ START>
-- Rewriting the following procedure to use the encumbrance APIs

FUNCTION EncumbOn_DocUnreserved(
                 p_doc_type    varchar2,
                 p_doc_subtype varchar2,
                 p_doc_id      number)
RETURN varchar2
IS
PRAGMA AUTONOMOUS_TRANSACTION;
-- The autonomous_transaction is required due to the use of the global temp
-- table PO_ENCUMBRANCE_GT, as the call to do_reserve later in the workflow
-- process is in an autonomous transaction because it must commit.
-- Without this autonomous transaction, the following error is raised:
-- ORA-14450: attempt to access a transactional temp table already in use

p_return_status          varchar2(1);
p_reservable_flag        varchar2(1);
l_progress               varchar2(200);

l_unreserved_flag VARCHAR2(1) := 'N';
l_return_exc   EXCEPTION;

BEGIN

   l_progress := '000';

   -- If the document is contract then we do not encumber it

   IF p_doc_subtype = 'CONTRACT' THEN

      RAISE l_return_exc;

   END IF;

   -- Check if encumbrance is on

   IF NOT (PO_CORE_S.is_encumbrance_on(
                  p_doc_type     => p_doc_type,
                  p_org_id       => NULL))
   THEN
       l_progress := '010';
      RAISE l_return_exc;
   END IF;

   l_progress := '020';

    -- Check if there is any distribution that can be reserved

   PO_DOCUMENT_FUNDS_PVT.is_reservable(
   x_return_status    =>   p_return_status
,  p_doc_type         =>   p_doc_type
,  p_doc_subtype      =>   p_doc_subtype
,  p_doc_level        =>   PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
,  p_doc_level_id     =>   p_doc_id
,  x_reservable_flag  =>   p_reservable_flag);

  l_progress := '030';

  IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '040';

  IF (p_return_status = FND_API.G_RET_STS_SUCCESS) AND
     (p_reservable_flag = PO_DOCUMENT_FUNDS_PVT.g_parameter_YES) THEN

     l_progress := '050';

      l_unreserved_flag := 'Y';
  END IF;

  l_progress := '060';

   ROLLBACK;
   RETURN(l_unreserved_flag);

EXCEPTION

WHEN l_return_exc THEN
   ROLLBACK;
   RETURN(l_unreserved_flag);

WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','EncumbOn_DocUnreserved',
                         l_progress);

   ROLLBACK;
   RAISE;

END EncumbOn_DocUnreserved;

-- <ENCUMBRANCE FPJ END>

PROCEDURE   PrintDocument(itemtype varchar2,itemkey varchar2) is

l_document_type   VARCHAR2(25);
l_document_num   VARCHAR2(30);
l_release_num     NUMBER;
l_request_id      NUMBER := 0;
l_qty_precision   VARCHAR2(30);
l_user_id         VARCHAR2(30);

--Context Setting Revamp
l_printer          VARCHAR2(30);
l_conc_copies      NUMBER;
l_conc_save_output VARCHAR2(1);
l_conc_save_output_bool BOOLEAN;
l_spo_result       BOOLEAN;

x_progress varchar2(200);

/*Bug 6692126 start */
l_document_id number;
l_withterms  varchar2(1);
l_document_subtype     po_headers.type_lookup_code%TYPE;
/*Bug 6692126 end */

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.PrintDocument: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   -- Get the profile option report_quantity_precision

   fnd_profile.get('REPORT_QUANTITY_PRECISION', l_qty_precision);

   /* Bug 2012896: the profile option REPORT_QUANTITY_PRECISION could be
      NULL. Even at site level!  And in that case the printing of report
      results into the inappropriate printing of quantities.
      Fix: Now, if the profile option is NULL, we are setting the variable
      l_qty_precision to 2, so that the printing would not fail. Why 2 ?
      This is the default defined in the definition of the said profile
      option. */

   IF l_qty_precision IS NULL THEN
      l_qty_precision := '2';
   END IF;

   -- Get the user id for the current user.  This information
   -- is used when sending concurrent request.

   FND_PROFILE.GET('USER_ID', l_user_id);

   -- Send the concurrent request to print document.

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_num := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_NUMBER');

  /*Bug 6692126 Get the item attributes DOCUMENT_ID,DOCUMENT_SUBTYPE
  and WITH_TERMS and pass it to Print_PO and Print_Release procedures*/

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'DOCUMENT_SUBTYPE');

  /*Bug6692126 Donot set the item attribute with_terms for requisitions
     as this attribute doesnot exist in req approval workflow*/
  IF l_document_type <> 'REQUISITION' THEN
  l_withterms := wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'WITH_TERMS');
  END IF;

  -- Bug 4918772
  -- The global variable 4918772 should be populated. This is used by
  -- the print/fax routines
  g_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'DOCUMENT_SUBTYPE');
  -- End Bug 4918772


  -- Context Setting Revamp.
  /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attribute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */

  l_printer := po_wf_util_pkg.GetItemAttrText (itemtype  => itemtype,
                                            itemkey   => itemkey,
                                            aname     => 'PREPARER_PRINTER');
  -- Need to get the no of copies, and save output values for the
  -- preparer and pass it to the set_print_options procedure
  l_conc_copies := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'PREPARER_CONC_COPIES');
  l_conc_save_output := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'PREPARER_CONC_SAVE_OUTPUT');

  if l_conc_save_output = 'Y' then
     l_conc_save_output_bool := TRUE;
  else
     l_conc_save_output_bool :=  FALSE;
  end if;


  -- <Debug start>
        x_progress := 'SPO : got printer as '||l_printer||
                      ' conc_copies '||l_conc_copies||
                      ' save o/p '||l_conc_save_output;

         IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
         END IF;
  -- <debug end>

  if (l_printer is not null) then
     l_spo_result := fnd_request.set_print_options(printer=> l_printer,
                                                    copies=> l_conc_copies,
                                                    save_output => l_conc_save_output_bool);

     if (l_spo_result) then
     -- <Debug start>
        x_progress := 'SPO:set print options successful';
        IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;
     -- <debug end>
     else
     -- <Debug start>
        x_progress := 'SPO:set print options not successful ';
        IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;
     -- <Debug end>
     end if;
  end if;

  --End Context Setting Revamp.

   IF l_document_type = 'REQUISITION' THEN

        l_request_id := Print_Requisition(l_document_num, l_qty_precision,
                                          l_user_id);

   ELSIF l_document_type = 'RELEASE' THEN

        l_release_num := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RELEASE_NUM');

        --Bug 6692126 Pass document_id,documentsubtype parameters
        l_request_id := Print_Release(l_document_num, l_qty_precision,
                                      to_char(l_release_num), l_user_id, l_document_id);

   ELSE
        --Bug 6692126 Pass document_id,subtype and with terms parameters
        l_request_id := Print_PO(l_document_num, l_qty_precision,
                                          l_user_id,
                                          l_document_id,l_document_subtype,l_withterms);
   END IF;

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CONCURRENT_REQUEST_ID',
                                avalue   => l_request_id);

  x_progress := 'PO_REQAPPROVAL_INIT1.PrintDocument: 02. request_id= ' || to_char(l_request_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','PrintDocument',x_progress);
        raise;

END PrintDocument;




-- DKC 10/10/99
PROCEDURE   FaxDocument(itemtype varchar2,itemkey varchar2) is

l_document_type   VARCHAR2(25);
l_document_num    VARCHAR2(30);
l_release_num     NUMBER;
l_request_id      NUMBER := 0;
l_qty_precision   VARCHAR2(30);
l_user_id         VARCHAR2(30);

l_fax_enable      VARCHAR2(25);
l_fax_num         VARCHAR2(30);  -- 5765243

--Context Setting Revamp
l_spo_result      BOOLEAN;
l_printer         VARCHAR2(30);
/*Bug 6692126 start */
l_document_id           number;
l_withterms             varchar2(1);
l_document_subtype      po_headers.type_lookup_code%TYPE;
 /*Bug 6692126 end */

x_progress varchar2(200);

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.FaxDocument: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   -- Get the profile option report_quantity_precision

   fnd_profile.get('REPORT_QUANTITY_PRECISION', l_qty_precision);

   -- Get the user id for the current user.  This information
   -- is used when sending concurrent request.

   FND_PROFILE.GET('USER_ID', l_user_id);

   -- Send the concurrent request to fax document.

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_num := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_NUMBER');

  /*Bug 6692126 Get the document_id ,document subtype and with terms
   item attribute and pass it to Fax_PO and Fax_Release procedures
   Donot rely on global variable.Instead get the document subtype
   and pass it as a paramter */

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_SUBTYPE');

  l_withterms := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'WITH_TERMS');

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'DOCUMENT_TYPE');

  -- Bug 4918772
  -- The global variable 4918772 should be populated. This is used by
  -- the print/fax routines
  g_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'DOCUMENT_SUBTYPE');
  -- End Bug 4918772


   -- Context Setting revamp : setting the printer to that of the preparer, so that
   -- irrespective of who submits the request, the printing should happen
   -- on preparer's printer
  /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attrbute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */

  l_printer := po_wf_util_pkg.GetItemAttrText  (itemtype   => itemtype,
                                            itemkey   => itemkey,
                                            aname     => 'PREPARER_PRINTER');

  if (l_printer is not null) then
     l_spo_result:= fnd_request.set_print_options(printer=> l_printer);
  end if;

   IF l_document_type IN ('PO', 'PA') THEN

        l_fax_enable := wf_engine.GetItemAttrText (itemtype => itemtype,
                                        itemkey        => itemkey,
                                        aname        => 'FAX_DOCUMENT');

        l_fax_num    := wf_engine.GetItemAttrText (itemtype => itemtype,
                                        itemkey        => itemkey,
                                        aname        => 'FAX_NUMBER');

        --Bug 6692126 Pass document_id ,document subtype and with terms parameters

        l_request_id := Fax_PO(l_document_num, l_qty_precision,
                                        l_user_id, l_fax_enable, l_fax_num,l_document_id,l_document_subtype,l_withterms);

   ELSIF l_document_type = 'RELEASE' THEN

        l_release_num := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RELEASE_NUM');

        l_fax_enable := wf_engine.GetItemAttrText (itemtype => itemtype,
                                        itemkey        => itemkey,
                                        aname        => 'FAX_DOCUMENT');

        l_fax_num    := wf_engine.GetItemAttrText (itemtype => itemtype,
                                        itemkey        => itemkey,
                                        aname        => 'FAX_NUMBER');

         --Bug 6692126 Pass document_id ,document subtype parameters

        l_request_id := Fax_Release(l_document_num, l_qty_precision,
                                        to_char(l_release_num), l_user_id,
                                        l_fax_enable, l_fax_num,l_document_id);

   END IF;

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CONCURRENT_REQUEST_ID',
                                avalue   => l_request_id);

  x_progress := 'PO_REQAPPROVAL_INIT1.FaxDocument: 02. request_id= ' || to_char(l_request_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','FaxDocument',x_progress);
        raise;

END FaxDocument;






FUNCTION Print_Requisition(p_doc_num varchar2, p_qty_precision varchar,
                           p_user_id varchar2) RETURN number is

l_request_id NUMBER;
x_progress varchar2(200);

BEGIN
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>

     l_request_id := fnd_request.submit_request('PO',
                'PRINTREQ',
                null,
                null,
                false,
                'P_REQ_NUM_FROM=' || p_doc_num,
                'P_REQ_NUM_TO=' || p_doc_num,
                'P_QTY_PRECISION=' || p_qty_precision,
                fnd_global.local_chr(0),
                NULL,
                NULL,
                NULL,
                NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_Requisition',x_progress);
        raise;
END;

FUNCTION Print_PO(p_doc_num varchar2, p_qty_precision varchar,
                  p_user_id varchar2,p_document_id number default NULL,
                  p_document_subtype varchar2 default NULL,p_withterms varchar2 default NULL) RETURN number is

l_request_id number;
x_progress varchar2(200);
l_set_lang boolean;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
--Bug5080617 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T'  and
    g_document_subtype <>'PLANNED') THEN
--Launching the Dispatch Purchase Order Concurrent Program
    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>

    l_request_id := fnd_request.submit_request('PO',
        'POXPOPDF',
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num       ,--P_po_num_to
         null           ,--P_relaese_num_from
         null           ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'             ,--P_test_flag
         null           ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         null           ,--P_fax_enable
         null           ,--P_fax_number
         'Y'            ,--P_BLANKET_LINES
        'Communicate'   ,--View_or_Communicate,
         p_withterms    ,--P_WITHTERMS Bug# 6692126 instead of 'Y'
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id   ,--P_DOCUMENT_ID Bug# 6692126
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         p_document_subtype, --P_DOCUMENT_TYPE Bug# 6692126
         0              ,--P_max_zip_size, <PO Attachment Support 11i.11>
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL);
--<POC FPJ End>
ELSE

    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>
    /* bug 13540069*/
	l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
    l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO='   || p_doc_num,
                'P_USER_ID=' || p_user_id,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_BLANKET_LINES=Y',
                'P_PRINT_RELEASES=N',
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);
END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_PO',x_progress);
        raise;

END Print_PO;





--DKC 10/10/99
FUNCTION Fax_PO(p_doc_num varchar2, p_qty_precision varchar,
                p_user_id varchar2, p_fax_enable varchar2,
                p_fax_num varchar2,p_document_id number default NULL,
                p_document_subtype varchar2,p_withterms varchar2) RETURN number is

l_request_id number;
x_progress varchar2(200);
l_set_lang boolean;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype <>'PLANNED') THEN

--Launching the Dispatch Purchase Order Concurrent Program
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>
--Bug5080617 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null
     l_request_id := fnd_request.submit_request('PO',
        'POXPOFAX'      ,--Bug 6332444
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num       ,--P_po_num_to
         null           ,--P_relaese_num_from
         null           ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'             ,--P_test_flag
         null           ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         'Y'            ,--P_fax_enable
         p_fax_num      ,--P_fax_number
         'Y'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         p_withterms    ,--P_WITHTERMS  Bug# 6692126 instead of 'Y'
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug# 6692126
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         p_document_subtype,--P_DOCUMENT_TYPE Bug# 6692126
         0              ,--P_max_zip_size, <PO Attachment Support 11i.11>
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL);

--<POC FPJ End>

ELSE
    --<R12 MOAC START>
    po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
    --<R12 MOAC END>
    /* bug 13540069*/
	l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
    l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO='   || p_doc_num,
                'P_USER_ID=' || p_user_id,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_FAX_ENABLE=' || p_fax_enable,
                'P_FAX_NUM=' || p_fax_num,
                'P_BLANKET_LINES=Y',   -- Bug 3672088
                'P_PRINT_RELEASES=N',  -- Bug 3672088
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL);
END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Fax_PO',x_progress);
        raise;

END Fax_PO;





FUNCTION Print_Release(p_doc_num varchar2, p_qty_precision varchar,
             p_release_num varchar2, p_user_id varchar2,p_document_id number default NULL) RETURN number is

l_request_id number;
x_progress varchar2(200);
l_set_lang boolean;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype = 'BLANKET') THEN
--Launching the Dispatch Purchase Order Concurrent Program
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>
--Bug5080617 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null
     l_request_id := fnd_request.submit_request('PO',
        'POXPOPDF',
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num      ,--P_po_num_to
         p_release_num  ,--P_release_num_from
         p_release_num  ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'            ,--P_test_flag
         'Y'            ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         null           ,--P_fax_enable
         null           ,--P_fax_number
         'Y'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         'N'            ,--P_WITHTERMS
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug# 6692126
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         'RELEASE'      ,--P_DOCUMENT_TYPE  Bug# 6692126
         0              ,--P_max_zip_size, <PO Attachment Support 11i.11>
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL);
--<POC FPJ End >
ELSE

     -- FRKHAN 09/17/98. Change 'p_doc_num || p_release_num' from P_RELEASE_NUM_FROM and TO to just p_release_num
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>
     /* bug 13540069*/
	 l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
     l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_USER_ID=' || p_user_id,
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO=' || p_doc_num,
                'P_RELEASE_NUM_FROM=' || p_release_num,
                'P_RELEASE_NUM_TO='   || p_release_num,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_BLANKET_LINES=N',
                'P_PRINT_RELEASES=Y',
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_Release',x_progress);
        raise;

END Print_Release;




-- Auto Fax
-- DKC 10/10/99
FUNCTION Fax_Release(p_doc_num varchar2, p_qty_precision varchar,
                p_release_num varchar2, p_user_id varchar2,
                p_fax_enable varchar2, p_fax_num varchar2,p_document_id number default NULL) RETURN number is

l_request_id number;
x_progress varchar2(200);
l_set_lang boolean;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype = 'BLANKET') THEN
--Launching the Dispatch Purchase Order Concurrent Program
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>
--Bug5080617 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null
     l_request_id := fnd_request.submit_request('PO',
        'POXPOFAX', --Bug 13088481 fix
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num       ,--P_po_num_to
         p_release_num  ,--P_relaese_num_from
         p_release_num  ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'            ,--P_test_flag
         'Y'            ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         'Y'            ,--P_fax_enable
         p_fax_num      ,--P_fax_number
         'N'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         'N'            ,--P_WITHTERMS
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug# 6692126
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         'RELEASE'       ,--P_DOCUMENT_TYPE Bug# 6692126
         0              ,--P_max_zip_size, <PO Attachment Support 11i.11>
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL);
--<POC FPJ End>

ELSE
     --<R12 MOAC START>
     po_moac_utils_pvt.set_request_context(po_moac_utils_pvt.get_current_org_id);
     --<R12 MOAC END>
     /* bug 13540069*/
	 l_set_lang := fnd_request.set_options('NO', 'NO', NULL,NULL, NULL, FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS'));
     l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_USER_ID=' || p_user_id,
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO=' || p_doc_num,
                'P_RELEASE_NUM_FROM=' || p_release_num,
                'P_RELEASE_NUM_TO='   || p_release_num,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_FAX_ENABLE=' || p_fax_enable,
                'P_FAX_NUM=' || p_fax_num,
                'P_BLANKET_LINES=N',   -- Bug 3672088
                'P_PRINT_RELEASES=Y',  -- Bug 3672088
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL);
END IF;


    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Fax_Release',x_progress);
        raise;

END Fax_Release;






--
-- Is apps source code POR ?
-- Determines if the requisition is created
-- through web requisition 4.0 or higher
--
procedure is_apps_source_POR(itemtype in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_apps_source_code          VARCHAR2(25)  :='';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

BEGIN
   IF (funcmode='RUN') THEN
    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    IF l_document_id IS NOT NULL THEN

      select nvl(apps_source_code, 'PO')
      into   l_apps_source_code
      from   po_requisition_headers_all
      where  requisition_header_id=l_document_id;

    END IF;

    l_progress:='002-'||to_char(l_document_id);

    /* POR = Web Requisition 4.0 or higher */
    IF (l_apps_source_code='POR') THEN

     resultout:='COMPLETE:'||'Y';
     return;
    ELSE
     resultout:='COMPLETE:'||'N';
     return;

    END IF;

   END IF; -- run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','is_apps_source_POR',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_APPS_SOURCE_POR');
    RAISE;

END is_apps_source_POR;

-- Bug#3147435
-- Is contractor status PENDING?
-- Determines if the requisition has contractor_status PENDING at header level
procedure is_contractor_status_pending(itemtype in varchar2,
                                       itemkey         in varchar2,
                                       actid           in number,
                                       funcmode        in varchar2,
                                       resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_contractor_status         VARCHAR2(25)  := '';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

BEGIN
   l_progress:='001-'||funcmode;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (funcmode='RUN') THEN
    l_contractor_status := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACTOR_STATUS');

    l_progress:='002-'||l_contractor_status;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (l_contractor_status = 'PENDING') THEN
     --Bug#3268971
     --Setting the item attribute value to Y, which will be used in
     --ReqLinesNOtificationsCO to determine whether to display the helptext
     --for contractor assignment
     PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACTOR_ASSIGNMENT_REQD',
                                       avalue   => 'Y' );
     resultout:='COMPLETE:'||'Y';

     l_progress:='003-'||resultout;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     return;
    ELSE
     resultout:='COMPLETE:'||'N';

     l_progress:='004-'||resultout;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     return;
    END IF;

   END IF; -- run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','is_contractor_status_pending',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.is_contractor_status_pending');
    RAISE;

END is_contractor_status_pending;

-- Bug 823167 kbenjami
--
-- Is the Submitter the last Approver?
-- Checks to see if submitter is also the current
-- approver of the doc.
-- Prevents two notifications from being sent to the
-- same person.
--
procedure Is_Submitter_Last_Approver(itemtype   in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is

approver_id     number;
preparer_id     number;

x_username    varchar2(100);

x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;

  preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey => itemkey,
                                              aname => 'PREPARER_ID');

  approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey => itemkey,
                                              aname => 'FORWARD_FROM_ID');

  x_username := wf_engine.GetItemAttrText (itemtype => itemtype,
                                              itemkey => itemkey,
                                              aname => 'FORWARD_FROM_USER_NAME');

  -- return Y if forward from user name is null.
  /* Bug5142627(forward fix 3733830) After the fix 2308846 the FORWARD_FROM_ID might be null
     when it is just submitted for approval and no-approver-found.
     So this also should be excluded.
  */
  if (approver_id is null OR
      preparer_id = approver_id OR x_username is null) then
    resultout := wf_engine.eng_completed || ':' || 'Y';
    x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 02. Result = Yes';
  else
    resultout := wf_engine.eng_completed || ':' || 'N';
    x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 02. Result = No';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_Submitter_Last_Approver',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_SUBMITTER_LAST_APPROVER');
    raise;

end Is_Submitter_Last_Approver;

--

function get_error_doc(itemtype in varchar2,
                       itemkey  in varchar2) return varchar2
IS
  l_doc_string varchar2(200);

  l_document_type varchar2(25);
  l_document_subtype varchar2(25);
  l_document_id number;
  l_org_id number;

BEGIN

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  IF (l_document_type IN ('PO', 'PA')) THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1
      into l_doc_string
      from po_headers hd,
           po_lookup_codes ty,
           po_lookup_codes st
     where hd.po_header_id = l_document_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'DOCUMENT SUBTYPE'
       and st.lookup_code = hd.TYPE_LOOKUP_CODE;
  ELSIF (l_document_type = 'REQUISITION') THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1
      into l_doc_string
      from po_requisition_headers hd,
           po_lookup_codes ty,
           po_lookup_codes st
     where hd.requisition_header_id = l_document_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'REQUISITION TYPE'
       and st.lookup_code = hd.TYPE_LOOKUP_CODE;
  ELSIF (l_document_type = 'RELEASE') THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1 || '-' ||
           rl.RELEASE_NUM
      into l_doc_string
      from po_headers hd,
           po_releases rl,
           po_lookup_codes ty,
           po_lookup_codes st
     where rl.po_release_id = l_document_id
       and rl.po_header_id = hd.po_header_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'DOCUMENT SUBTYPE'
       and st.lookup_code = rl.RELEASE_TYPE;
  END IF;

  return(l_doc_string);

EXCEPTION
 WHEN OTHERS THEN
   RAISE;

END get_error_doc;

function get_preparer_user_name(itemtype in varchar2,
                                itemkey  in varchar2) return varchar2
IS

  l_name          varchar2(100);
  l_preparer_id   number;
  l_disp          varchar2(240);

BEGIN

  l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PREPARER_ID');

  PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_name, l_disp);

  return(l_name);

END;

procedure send_error_notif(itemtype    in varchar2,
                           itemkey     in varchar2,
                           username    in varchar2,
                           doc         in varchar2,
                           msg         in varchar2,
                           loc         in varchar2,
                           document_id in number) is

pragma AUTONOMOUS_TRANSACTION;

/* Bug# 2074072: kagarwal
** Desc: Calling wf process to send Error Notification
** instead of the wf API.
*/

  -- l_nid NUMBER;
  l_seq                varchar2(25); --Bug14305923
  Err_ItemKey          varchar2(240);
  Err_ItemType         varchar2(240):= 'POERROR';
  l_document_id        number;
  x_progress           varchar2(1000);

BEGIN

 -- To be used only for PO and Req Approval wf

   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 10';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 20'
                  ||' username: '|| username
                  ||' doc: '|| doc
                  ||' location: '|| loc
                  ||' error msg: '|| msg;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


   if username is not null and doc is not null then

    /*  l_nid  := wf_notification.Send(username,
                                     itemtype,
                                     'PLSQL_ERROR_OCCURS',
                                     null, null, null, null);

      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_DOC', doc);
      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_LOC', loc);
      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_MSG', msg);
    */

      -- Get Document Id for the Errored Item.

      IF (document_id IS NULL) THEN

        l_document_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
      ELSE

        l_document_id := document_id;

      END IF;

      select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;
      Err_ItemKey := to_char(l_document_id) || '-' || l_seq;


      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 50'
                      ||' Parent Itemtype: '|| ItemType
                      ||' Parent Itemkey: '|| ItemKey
                      ||' Error Itemtype: '|| Err_ItemType
                      ||' Error Itemkey: '|| Err_ItemKey;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      wf_engine.CreateProcess( ItemType => Err_ItemType,
                              ItemKey  => Err_ItemKey,
                              process  => 'PLSQL_ERROR_NOTIF');

      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 70';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      -- Set the attributes
     po_wf_util_pkg.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PLSQL_ERROR_DOC',
                                 avalue     =>  doc);

     --
     po_wf_util_pkg.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PLSQL_ERROR_LOC',
                                 avalue     => loc);
     --
     po_wf_util_pkg.SetItemAttrText ( itemtype        => Err_ItemType,
                                 itemkey         => Err_ItemKey,
                                 aname           => 'PLSQL_ERROR_MSG',
                                 avalue          =>  msg);
     --
     po_wf_util_pkg.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PREPARER_USER_NAME' ,
                                 avalue     => username);
     --
      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 100';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;


      wf_engine.StartProcess(itemtype        => Err_ItemType,
                             itemkey         => Err_ItemKey);

      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif:  900';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      commit;

  end if;

EXCEPTION
 WHEN OTHERS THEN
   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: '|| sqlerrm;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;
   RAISE;

END send_error_notif;

-- This procedure will close all the notification of all the
-- previous approval WF.

procedure CLOSE_OLD_NOTIF(itemtype in varchar2,
                          itemkey  in varchar2) is
pragma AUTONOMOUS_TRANSACTION;
begin

    update wf_notifications set status = 'CLOSED'
     where notification_id in (
           select ias.notification_id
             from wf_item_activity_statuses ias,
                  wf_notifications ntf
            where ias.item_type = itemtype
              and ias.item_key  = itemkey
              and ntf.notification_id  = ias.notification_id);

    commit;

end;

/* Bug# 1739194: kagarwal
** Desc: Added new procedure to check the document manager error.
*/
procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_error_number   NUMBER;

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Is_Document_Manager_Error_1_2: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_error_number:=
   wf_engine.GetItemAttrNumber (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'DOC_MGR_ERROR_NUM');

   l_progress := 'Is_Document_Manager_Error_1_2: 002 - '||
                  to_char(l_error_number);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (l_error_number = 1 or l_error_number = 2) THEN
     resultout:='COMPLETE:'||'Y';
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Is_Document_Manager_Error_1_2',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';

END Is_Document_Manager_Error_1_2;



/**************************************************************************/
procedure PROFILE_VALUE_CHECK(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
x_progress    varchar2(300);
l_po_email_add_prof     varchar2(60);
l_prof_value varchar2(2);
l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN
   x_progress := 'PO_REQAPPROVAL_INIT1.profile_value_check: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_po_email_add_prof := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADD_FROM_PROFILE');

  /* the value of l_po_email_add_prof has a value or it is null*/
  IF  l_po_email_add_prof is null THEN
        l_prof_value := 'N';
  ELSE
       l_prof_value := 'Y';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_prof_value ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.profile_value_check: 02. Result= ' || l_prof_value;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_INIT1', 'PROFILE_VALUE_CHECK' ,
                    itemtype, itemkey, x_progress);
    resultout:='COMPLETE:'||'N';

END;

procedure Check_Error_Count(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_count   NUMBER;
  l_error_count   NUMBER;
  l_item_type  varchar2(30);
  l_item_key  varchar2(30);

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'CHECK_ERROR_COUNT: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_item_type :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_TYPE');
   l_item_key :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_KEY');
   l_count:= wf_engine.GetItemAttrNumber (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'RETRY_COUNT');


   Select count(*)
   into l_error_count
   from wf_items
   where parent_item_type=l_item_type
   and parent_item_key = l_item_key;


   IF (l_error_count <= l_count) then
     resultout:='COMPLETE:'||'Y'; -- retry
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Check_Error_Count',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';
END Check_Error_Count;

procedure Initialise_Error(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_error_number number;
  l_name          varchar2(100);
  l_preparer_id   number;
  l_disp          varchar2(240);
  l_item_type  varchar2(30);
  l_item_key  varchar2(30);
  l_doc_err_num number;
  l_doc_type varchar2(25); /* Bug# 2655410 */
  l_doc_subtype varchar2(25);
 -- l_doc_subtype_disp varchar2(30);
  l_doc_type_disp    varchar2(240);
  l_orgid            number;
  l_ga_flag   varchar2(1) := null;  -- FPI GA

  l_doc_num          varchar2(30);
  l_sys_error_msg    varchar2(2000) :='';
  l_release_num_dash varchar2(30);
  l_release_num      number; --1942901
  l_document_id      PO_HEADERS_ALL.po_header_id%TYPE; --<R12 STYLES PHASE II>

/* Bug# 2655410: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor docDisp(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;


BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Initialise_Error: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_item_type :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_TYPE');
   l_item_key :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_KEY');

/* Bug# 2708702 kagarwal
** Fix Details: Make all the Set and Get calls for parent item type to use the PO wrapper
** PO_WF_UTIL_PKG so that the missing attribute errors are ignored.
*/

   l_preparer_id := PO_WF_UTIL_PKG.GetItemAttrNumber (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'PREPARER_ID');

   PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_name, l_disp);

/* Bug# 2655410: kagarwal
** Desc: We will get the document type display value from
** po document types. Hence we need to get the doc type and subtype
** from the parent wf and then set the doc type display in the
** error wf.
**
** Also need to set the org context before calling the cursor
*/

   l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_SUBTYPE');

   l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_TYPE');

   IF l_doc_type = 'PA' AND l_doc_subtype = 'BLANKET' THEN

       l_ga_flag := PO_WF_UTIL_PKG.GetItemAttrText (itemtype    => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'GLOBAL_AGREEMENT_FLAG');
   END IF;


  --<R12 STYLES PHASE II START >

    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                          (itemtype   => l_item_type,
                                           itemkey    => l_item_key,
                                           aname      => 'DOCUMENT_ID');


  if l_ga_flag = 'N' then

      l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_item_type,
                                              itemkey  => l_item_key,
                                              aname    => 'ORG_ID');

      IF l_orgid is NOT NULL THEN

          PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

      END IF;

  end if; /* if l_ga_flag = 'N' */

  if (l_doc_type = 'PA' AND l_doc_subtype IN ('BLANKET','CONTRACT')) OR
     (l_doc_type = 'PO' AND l_doc_subtype =   'STANDARD')  then

     l_doc_type_disp:= PO_DOC_STYLE_PVT.get_style_display_name(l_document_id);

  else

      OPEN docDisp(l_doc_type, l_doc_subtype);
      FETCH docDisp into l_doc_type_disp;
      CLOSE docDisp;

  end if;
  --<R12 STYLES PHASE II END >


   l_doc_num := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_NUMBER');


   l_sys_error_msg := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'SYSADMIN_ERROR_MSG');

   l_release_num_dash := PO_WF_UTIL_PKG.GetItemAttrText (itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'RELEASE_NUM_DASH');

   l_release_num:= PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'RELEASE_NUM');

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => l_name);

/* Bug# 2655410: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/

/*   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_SUBTYPE_DISP' ,
                              avalue     => l_doc_subtype_disp);
*/
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_TYPE_DISP' ,
                              avalue     => l_doc_type_disp);

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_NUMBER' ,
                              avalue     => l_doc_num);

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'RELEASE_NUM_DASH' ,
                              avalue     => l_release_num_dash);

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'RELEASE_NUM' ,
                              avalue     => l_release_num);


   l_error_number := PO_REQAPPROVAL_ACTION.doc_mgr_err_num;
   /* bug 1942091. Set the Error attributes */
   l_sys_error_msg := PO_REQAPPROVAL_ACTION.sysadmin_err_msg;

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'DOC_MGR_ERROR_NUM',
                                   avalue     => l_error_number);
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'SYSADMIN_ERROR_MSG' ,
                              avalue     => l_sys_error_msg);
   /* Set the parents doc manager error number and sysadmin error mesg*/
   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOC_MGR_ERROR_NUM',
                                   avalue     => l_error_number);
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'SYSADMIN_ERROR_MSG' ,
                              avalue     => l_sys_error_msg);

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Initialise_Error',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';
END Initialise_Error;



procedure acceptance_required   ( itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
        l_acceptance_flag po_headers_all.acceptance_required_flag%TYPE;
        x_progress              varchar2(3) := '000';
        l_document_id number;
        l_document_type po_document_types.document_type_code%type;
        l_document_subtype po_document_types.document_subtype%type;
        l_when_to_archive po_document_types.archive_external_revision_code%type;
        l_archive_result varchar2(1);
        l_revision_num number; -- <Bug 5501659> --
        l_responded_shipments number; -- <Bug 5501659> --
begin
/*
1. Bug#2742276: To find out if acceptance is required, older version used to check workflow
attribute ACCEPTANCE_REQUIRED.
This may not be correct since acceptance_requried_flag may be updated in the DB.
Thus, we shall query acceptance_required_flag from po_headers/po_releases view.

*/
        x_progress := '001';

        l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

        l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

         l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

        if(l_document_type <> 'RELEASE') then
                select acceptance_required_flag
                into l_acceptance_flag
                from po_headers_all --bug 4764963
                where po_header_Id = l_document_id;
        else
                select acceptance_required_flag
                into l_acceptance_flag
                from po_releases_all --bug 4764963
                where po_release_Id = l_document_id;
        end if;

/* BINDING FPJ  START*/
    IF nvl(l_acceptance_flag,'N') <> 'N' THEN
       result := 'COMPLETE:' || 'Y';
    ELSE
       result := 'COMPLETE:' || 'N';
    END IF;
/* BINDING FPJ  END*/

/*** Checking if at least one shipment has been responded to (Bug 5501659) */
    -- There should be no notification if there has been at least on reponse

    if(l_document_type <> 'RELEASE') then
            select revision_num
            into l_revision_num
            from po_headers_all
            where po_header_id = l_document_id;

            select count(*)
            into l_responded_shipments
            from PO_ACCEPTANCES
            where po_header_id = l_document_id and
            revision_num = l_revision_num;
    else
            select revision_num
            into l_revision_num
            from po_releases_all
            where po_release_id = l_document_id;

            select count(*)
            into l_responded_shipments
            from PO_ACCEPTANCES
            where po_release_id = l_document_id and
            revision_num = l_revision_num;
    end if;


    if(l_responded_shipments > 0) THEN
        result := 'COMPLETE:' || 'N';
    end if;

/*** (Bug 5501659) ***/


exception
  WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','acceptance_required',x_progress);
        raise;
end;

--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
        x_progress              varchar2(3) := '000';
        x_acceptance_result        fnd_new_messages.message_text%type := null; -- Bug 2821341
        x_org_id                number;
        x_user_id                number;
        x_document_id           number;
        x_document_type_code    varchar2(30);
        x_po_header_id          po_headers_all.po_header_id%TYPE;
        x_vendor                po_vendors.vendor_name%TYPE; /* Bug 7172641 Changing the size as equal to the column size of vendor_name in po_vendors table */
        x_supp_user_name        varchar2(100);
        x_supplier_displayname  varchar2(100);
        x_revision_num          number;                -- RDP
        -- x_accp_type                varchar2(100);
        l_nid                   number;
        l_ntf_role_name         varchar2(320);
	x_acceptance_note       PO_ACCEPTANCES.note%TYPE;        --bug 18853476

begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                             aname    => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;       -- <R12 MOAC>

  x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');

   -- commented out the usage of accptance_type (FPI)
  /* x_accp_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'ACCEPTANCE_TYPE'); */

  x_acceptance_result := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'ACCEPTANCE_RESULT');

  -- Get the reason here, pass to mehtod Insert_Acc_Rejection_Row
  x_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'ACCEPTANCE_COMMENTS');

if x_document_type_code <> 'RELEASE' then
        select pov.vendor_name,poh.revision_num
        into x_vendor,x_revision_num                         -- RDP
        from po_vendors pov,po_headers poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=x_document_id;
else
        select pov.vendor_name, poh.po_header_id, por.revision_num   --RDP
        into x_vendor,x_po_header_id,x_revision_num
        from po_releases por,
             po_headers_all poh,  -- <R12 MOAC>
             po_vendors pov
        where por.po_release_id = x_document_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;
end if;



      if (x_document_type_code <> 'RELEASE') then

        --dbms_output.put_line('For std pos');
       begin
        select a.notification_id, a.recipient_role
        INTO   l_nid, l_ntf_role_name
        from   wf_notifications a,
               wf_item_activity_statuses wa
        where  itemkey=wa.item_key
        and    itemtype=wa.item_type
        and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
        and    a.notification_id=wa.notification_id and a.status = 'CLOSED';
       exception
        when others then l_nid := null;
       end;

       else
       begin
        --dbms_output.put_line('For Releases');
        select a.notification_id, a.recipient_role
        INTO  l_nid, l_ntf_role_name
        from  wf_notifications a,
              wf_item_activity_statuses wa
        where itemkey=wa.item_key
        and   itemtype=wa.item_type
        and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
        and   a.notification_id=wa.notification_id and a.status = 'CLOSED';
       exception
        when others then l_nid := null;
      end;
    end if;

    if (l_nid is null) then
      --we do not want to continue if the notification is not closed.
      return;
    else
     x_supp_user_name := wf_notification.responder(l_nid);
    end if;


   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => x_vendor);

   -- commented out the usage of accptance_type (FPI)
  /* IF (x_accp_type is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ACCEPTANCE_TYPE',
                                        avalue   => 'Accepted' );
   END IF; */


   IF (x_acceptance_result is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ACCEPTANCE_RESULT',
                                        avalue   => fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED') );
   END IF;


 if (substr(x_supp_user_name, 1, 6) = 'email:') then
     --Get the username and store that in the supplier_user_name.
      x_supp_user_name := PO_ChangeOrderWF_PVT.getEmailResponderUserName(x_supp_user_name, l_ntf_role_name);
 end if;


 PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_USER_NAME',
                                 avalue   => x_supp_user_name);

 x_user_id :=  PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,    -- RDP
                                    itemkey  => itemkey,
                                    aname    => 'BUYER_USER_ID');



-- Default only when the profile option is set
   IF( g_default_promise_date = 'Y') THEN
       IF(x_document_type_code <> 'RELEASE') THEN                         -- RDP
         POS_ACK_PO.Acknowledge_promise_date(null,x_document_id,null,x_revision_num,x_user_id);
       ELSE
          POS_ACK_PO.Acknowledge_promise_date(null,x_po_header_id,x_document_id,x_revision_num,x_user_id);
       END IF;
   END IF;




  -- insert acceptance record.
  Insert_Acc_Rejection_Row(itemtype, itemkey, actid, x_acceptance_note, 'Y');

EXCEPTION
  WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Register_acceptance',x_progress);
        raise;
end;

--

procedure  Register_rejection   (  itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
        x_progress              varchar2(3) := '000';
        x_acceptance_result        fnd_new_messages.message_text%type := null;  -- Bug 2821341
        x_org_id                number;
        x_document_id           number;
        x_document_type_code    varchar2(30);
        x_vendor                varchar2(80);
        x_supp_user_name        varchar2(100);
        x_supplier_displayname  varchar2(100);
        --x_accp_type                varchar2(100);
        l_revision_num number;
        l_is_hdr_rejected varchar2(1);
        l_return_status varchar2(1);
l_role_name varchar2(50);
l_role_display_name varchar2(50);
l_nid  number;
l_ntf_role_name         varchar2(320);

x_acceptance_note    PO_ACCEPTANCES.note%TYPE;        --bug 18853476

begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                             aname    => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;       -- <R12 MOAC>

  x_progress := '001';
  x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');


  -- commented out the usage of accptance_type (FPI)
  /* x_accp_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'ACCEPTANCE_TYPE'); */

  x_acceptance_result := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'ACCEPTANCE_RESULT');

if x_document_type_code <> 'RELEASE' then
        select
                pov.vendor_name,
                poh.revision_num
        into
                x_vendor,
                l_revision_num
        from po_vendors pov,po_headers poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=x_document_id;

        x_progress := '002';
        PO_ChangeOrderWF_PVT.IsPOHeaderRejected(
                                                        1.0,
                                                        l_return_status,
                                                        x_document_id,
                                                        null,
                                                        l_revision_num,
                                                        l_is_hdr_rejected);
else
        select
                pov.vendor_name,
                por.revision_num
        into
                x_vendor,
                l_revision_num
        from po_releases por,
             po_headers_all poh,   --<R12 MOAC>
             po_vendors pov
        where por.po_release_id = x_document_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;

        x_progress := '003';
        PO_ChangeOrderWF_PVT.IsPOHeaderRejected(
                                                        1.0,
                                                        l_return_status,
                                                        null,
                                                        x_document_id,
                                                        l_revision_num,
                                                        l_is_hdr_rejected);
end if;


   if (x_document_type_code <> 'RELEASE') then

           --dbms_output.put_line('For std pos');
          begin
           select a.notification_id, a.recipient_role
           INTO   l_nid, l_ntf_role_name
           from   wf_notifications a,
                  wf_item_activity_statuses wa
           where  itemkey=wa.item_key
           and    itemtype=wa.item_type
           and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and    a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
          end;

          else
          begin
           --dbms_output.put_line('For Releases');
           select a.notification_id, a.recipient_role
           INTO  l_nid, l_ntf_role_name
           from  wf_notifications a,
                 wf_item_activity_statuses wa
           where itemkey=wa.item_key
           and   itemtype=wa.item_type
           and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and   a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
         end;
       end if;

       if (l_nid is null) then
           --We do not want to continue if the notification is not closed.
           return;
       else
         x_supp_user_name := wf_notification.responder(l_nid);
       end if;


  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => x_vendor);

   -- commented out the usage of accptance_type (FPI)
   /* IF (x_accp_type is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ACCEPTANCE_TYPE',
                                        avalue   => 'Rejected' );
   END IF; */


   IF (x_acceptance_result is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'ACCEPTANCE_RESULT',
                                        avalue   => 'Rejected' );
   END IF;


  if (substr(x_supp_user_name, 1, 6) = 'email:') then
      --Get the username and store that in the supplier_user_name.
       x_supp_user_name := PO_ChangeOrderWF_PVT.getEmailResponderUserName(x_supp_user_name, l_ntf_role_name);
   end if;

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER_USER_NAME',
                                   avalue   => x_supp_user_name);



  -- insert rejection record.
  if(l_is_hdr_rejected = 'Y') then
        x_progress := '004';
	 -- bug 18853476, get the reason here, pass to mehtod Insert_Acc_Rejection_Row
         x_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                              aname    => 'ACCEPTANCE_COMMENTS');


        Insert_Acc_Rejection_Row(itemtype, itemkey, actid, x_acceptance_note, 'N');
  else
        x_progress := '005';
        wf_directory.createadhocrole(
                l_role_name ,
                l_role_display_name ,
                null,
                null,
                null,
                'MAILHTML',
                null,
                null,
                null,
                'ACTIVE',
                sysdate+1);
    PO_WF_UTIL_PKG.SetItemAttrText  (   itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'BUYER_USER_NAME',
                                        avalue   => l_role_name);
  end if;

EXCEPTION
  WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Register_rejection',x_progress);
        raise;
end;


Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                                   actid           in  number,
				   acceptance_note in varchar2, -- 18853476
                                   flag                   in  varchar2)
is
   PRAGMA AUTONOMOUS_TRANSACTION; --<BUG 10189933 Modified the call as AUTONOMOUS_TRANSACTION>
   x_row_id             varchar2(30);
  -- Bug 2850566
  -- x_Acceptance_id      number;
  -- x_Last_Update_Date   date                  :=  TRUNC(SYSDATE);
  -- x_Last_Updated_By    number                :=  fnd_global.user_id;
  -- End of Bug 2850566

   x_Creation_Date      date            :=  TRUNC(SYSDATE);
   x_Created_By         number          :=  fnd_global.user_id;
   x_Po_Header_Id       number;
   x_Po_Release_Id      number;
   x_Action             varchar2(240)   := 'NEW';
   x_Action_Date        date            :=  TRUNC(SYSDATE);
   x_Revision_Num       number;
   x_Accepted_Flag      varchar2(1)     := flag;
  -- x_Acceptance_Lookup_Code varchar2(25);
   x_document_id        number;
   x_document_type_code varchar2(30);

   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_Last_Updated_By    PO_ACCEPTANCES.last_updated_by%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   --  End of Bug 2850566
   l_rspndr_usr_name    fnd_user.user_name%TYPE := '';
   l_accepting_party varchar2(1);
begin
    -- Bug 2850566
    -- Commented out the select statement as it is handled in the PO_ACCEPTANCES rowhandler
        -- SELECT po_acceptances_s.nextval into x_Acceptance_id FROM sys.dual;

         -- commented out the usage of accptance_type (FPI)
        /* x_Acceptance_Lookup_Code := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                                      itemkey  => itemkey,
                                                                       aname    => 'ACCEPTANCE_LOOKUP_CODE'); */

         -- commented out the usage of accptance_type (FPI)
        /* if (x_Acceptance_Lookup_Code is NULL) then
           if flag = 'Y' then
                x_Acceptance_Lookup_Code := 'Accepted Terms';
           else
                x_Acceptance_Lookup_Code := 'Unacceptable Changes';
           end if;
        end if; */

        x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_ID');

        x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                                     itemkey  => itemkey,
                                                                      aname    => 'DOCUMENT_TYPE');


        --Bug 19862266, get the wf corresponding version not the latest version.
        x_revision_num := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'REVISION_NUMBER');

        -- abort any outstanding acceptance notifications for any previous revision of the document.

        --Bug 19862266, get the wf corresponding version not the latest version.
        if x_document_type_code <> 'RELEASE' then
                x_Po_Header_Id := x_document_id;
        else
                x_Po_Release_Id := x_document_id;

                select po_header_id
                into x_Po_Header_Id
                from po_releases
                where po_release_id = x_document_id;
        end if;

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF x_po_release_id IS NULL THEN
     l_acc_po_header_id := x_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

    l_rspndr_usr_name := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                                     itemkey  => itemkey,
                                                                      aname    => 'SUPPLIER_USER_NAME');

    begin
      select user_id into   l_Last_Updated_By
      from fnd_user
      where user_name = upper(l_rspndr_usr_name);
      l_accepting_party := 'S';
    exception when others then
      --in case of non-isp users there wont be any suppliers
      l_Last_Updated_By := x_created_by;
      l_accepting_party := 'S';  --ack is always by supplier.
    end;
    l_Last_Update_Login := l_Last_Updated_By;

    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                  =>  l_rowid,
                        x_acceptance_id                         =>  l_acceptance_id,
            x_Last_Update_Date       =>  l_Last_Update_Date,
            x_Last_Updated_By        =>  l_Last_Updated_By,
            x_Last_Update_Login      =>  l_Last_Update_Login,
                        p_creation_date                         =>  x_Creation_Date,
                        p_created_by                         =>  l_Last_Updated_By,
                        p_po_header_id                         =>  l_acc_po_header_id,
                        p_po_release_id                         =>  x_Po_Release_Id,
                        p_action                             =>  x_Action,
                        p_action_date                         =>  x_Action_Date,
                        p_employee_id                         =>  null,
                        p_revision_num                         =>  x_Revision_Num,
                        p_accepted_flag                         =>  x_Accepted_Flag,
                        p_note                   =>  acceptance_note,
                        p_accepting_party        =>  l_accepting_party
                        );

   --  End of Bug 2850566 RBAIRRAJ


   -- Reset the Acceptance required Flag
   --Bug 6847039 - Start
   --Update the last update date when po_headers_all/po_releases_all tables are updated.
   if x_po_release_id is not null then
      update po_releases
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_release_id = x_po_release_id;
   else
      update po_headers
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_header_id = x_po_header_id;
   end if;
   COMMIT; --<BUG 10189933>
exception
        when others then
        raise;
end;

/* Bug#2353153: kagarwal
** Added new PROCEDURE set_doc_mgr_context as a global procedure as this
** is being used by wf apis present in different packages.
**
** Calling Set_doc_mgr_context to set the application context in procedures
** Set_Startup_Values() and Is_doc_preapproved() procedures for PO Approval
** to succeed when SLS SUB LEDGER SECURITY (IGI) is being used
*/

PROCEDURE Set_doc_mgr_context (itemtype VARCHAR2,
                               itemkey VARCHAR2)  is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;
l_orgid      number; --RETRO FPI

x_progress  varchar2(200);

-- Bug 4290541 Start
X_User_Id            NUMBER;
X_Responsibility_Id  NUMBER;
X_Application_Id     NUMBER;
-- Bug 4290541 End

BEGIN

   -- Bug 4290541 Start
   --Fnd_Profile.Get('USER_ID',X_User_Id);
   --Fnd_Profile.Get('RESP_ID',X_Responsibility_Id);
   --Fnd_Profile.Get('RESP_APPL_ID',X_Application_Id);
   -- Bug 4290541 End
   -- Context Setting Revamp
   X_User_Id := fnd_global.user_id;
   X_Responsibility_Id := fnd_global.resp_id;
   X_Application_Id := fnd_global.resp_appl_id;


   x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_mgr_context.X_USER_ID= '
                || to_char(x_user_id)
                || 'X_ APPLICATION_ID= ' || to_char(x_application_id)
                || 'X_RESPONSIBILITY_ID= ' || to_char(x_responsibility_id);
   IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


   IF (X_User_Id = -1) THEN
    X_User_Id := NULL;
   END IF;

   IF (X_Responsibility_Id = -1) THEN
     X_Responsibility_Id := NULL;
   END IF;

   IF (X_Application_Id = -1) THEN
     X_Application_Id := NULL;
   END IF;

   l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'USER_ID');
   --
   l_application_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'APPLICATION_ID');
   --
   l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONSIBILITY_ID');

   x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_mgr_context.L_USER_ID= '
                || to_char(l_user_id)
                || ' L_APPLICATION_ID= ' || to_char(l_application_id)
                || 'L_RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);
   IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   -- bug 3543578
   -- Returning a Req from AutoCreate was nulling out the FND context.
   -- No particular context is required for sending the notification in
   -- the NOTIFY_RETURN_REQ process, so only change the context if
   -- a valid context has been explicitly set for the workflow process.

   -- Bug 4125251 Start
   -- Set the application context to the logged-in user
   -- if not null

    IF (NVL(X_USER_ID,-1)           = -1 OR
        NVL(X_RESPONSIBILITY_ID,-1) = -1 OR
        NVL(X_APPLICATION_ID,-1)    = -1)THEN
      IF X_USER_ID IS NOT NULL THEN
         FND_GLOBAL.APPS_INITIALIZE (X_USER_ID, L_RESPONSIBILITY_ID, L_APPLICATION_ID);
      ELSE
      -- Start fix for Bug 3543578
         IF (     L_USER_ID           IS NOT NULL
            AND   L_RESPONSIBILITY_ID IS NOT NULL
            AND   L_APPLICATION_ID    IS NOT NULL) THEN
            FND_GLOBAL.APPS_INITIALIZE (L_USER_ID, L_RESPONSIBILITY_ID, L_APPLICATION_ID);
         END IF;
      -- End fix for Bug 3543578
      END IF;
    END IF;
    -- Bug 4125251 End

  /* RETRO FPI START.
   *  If we had set the org context for a different operating unit, the above
   * fnd_global.APPS_INITIALIZE resets it back to the operating unit of
   * the responsibility. So set the org context explicitly again.
  */
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

  END IF;

  /* RETRO FPI END. */


  -- Bug 3571038
  igi_sls_context_pkg.set_sls_context;


EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','set_doc_mgr_context',x_progress);
        raise;

END Set_doc_mgr_context;

/* RETROACTIVE FPI START */
procedure MassUpdate_Releases_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    ) IS
l_orgid       number;
l_massupdate_releases     varchar2(2);
l_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
l_document_type PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

l_resp_id     number;
l_user_id     number;
l_appl_id     number;

BEGIN

  l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');


  l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_ID');

  l_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSIBILITY_ID');

  l_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPLICATION_ID');

  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

  --Context Setting Revamp
  /* if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then

   -- Bug 4125251,replaced apps init call with set doc mgr context call
      PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */

        IF l_orgid is NOT NULL THEN
               PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
        END IF;

  -- end if;



  l_massupdate_releases := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'MASSUPDATE_RELEASES');
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_TYPE');
  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype =>itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_SUBTYPE');

  /* the value of CREATE_SOURCING_RULE should be Y or N */
  IF (nvl(l_massupdate_releases,'N') <> 'Y') THEN
    l_massupdate_releases := 'N';
  ELSE
    if (l_document_type = 'PA' and l_document_subtype = 'BLANKET') then
        l_massupdate_releases := 'Y';
    else
        l_massupdate_releases := 'N';
    end if;
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_massupdate_releases;

  l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Yes_No: 02. Result= ' || l_massupdate_releases;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  l_massupdate_releases := 'N';
    resultout := wf_engine.eng_completed || ':' || l_massupdate_releases;
END MassUpdate_Releases_Yes_No;

procedure MassUpdate_Releases_Workflow( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    )  is
l_document_id po_headers_all.po_header_id%type;
l_vendor_id   po_headers_all.vendor_id%type;
l_vendor_site_id   po_headers_all.vendor_site_id%type;
l_progress varchar2(300);
l_update_releases varchar2(1) := 'Y';
l_return_status varchar2(1) ;
l_communicate_update varchar2(30); -- Bug 3574895. Length same as that on the form field PO_APPROVE.COMMUNICATE_UPDATES
l_category_struct_id  mtl_category_sets_b.structure_id%type; -- Bug 3592705
begin

        l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: 01';

        /* Bug# 2846210
        ** Desc: Setting application context as this wf api will be executed
        ** after the background engine is run.
        */

        Set_doc_mgr_context(itemtype, itemkey);

        l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
        select poh.vendor_id, poh.vendor_site_id
        into l_vendor_id, l_vendor_site_id
        from po_headers poh
        where poh.po_header_id = l_document_id;

        --<Bug 3592705 Start> Retrieved the default structure for
        --     Purchasing from the view mtl_default_sets_view.
        Begin
           SELECT structure_id
           INTO   l_category_struct_id
           FROM   mtl_default_sets_view
           WHERE  functional_area_id = 2 ;
        Exception
           when others then
              l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: Could not find Category Structure Id';
              IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
              END IF;
              raise;
        End;
        --<Bug 3592705 End>

        --Bug 3574895. Retroactively Repriced Releases/Std PO's are not getting
        --             communicated to supplier. Need to pick up the workflow
        --             attribute CO_H_RETROACTIVE_SUPPLIER_COMM here from the
        --             Blanket Approval Workflow and pass it in the procedure
        --             call below so that it may be set correctly for Release/
        --             Standard PO Approval as well.
        l_communicate_update := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CO_H_RETROACTIVE_SUPPLIER_COMM');

        PO_RETROACTIVE_PRICING_PVT. MassUpdate_Releases
              ( p_api_version => 1.0,
                p_validation_level => 100,
                p_vendor_id => l_vendor_id,
                p_vendor_site_id => l_vendor_site_id ,
                p_po_header_id => l_document_id,
                p_category_struct_id => l_category_struct_id, -- Bug 3592705
                p_category_from => null,
                p_category_to => null,
                p_item_from => null,
                p_item_to => null,
                p_date => null,
                p_communicate_update => l_communicate_update, --Bug 3574895
                x_return_status => l_return_status);

        If (l_return_status <> 'S') then
                l_update_releases := 'N';
        End if;

        l_progress := ': 02. Result= ' || l_update_releases;
        IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;
        resultout := wf_engine.eng_completed || ':' || l_update_releases;
EXCEPTION
  WHEN OTHERS THEN
        l_update_releases := 'N';
        l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: 03.'||
                        ' Result= ' || l_update_releases;
        resultout := wf_engine.eng_completed || ':' || l_update_releases;
        IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;
END MassUpdate_Releases_Workflow;

procedure Send_Supplier_Comm_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    ) IS
l_retro_change varchar2(1);
l_supplier_comm varchar2(1) := 'Y'; --default has to be Y
l_progress varchar2(300);
l_document_type   PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype   PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

BEGIN
  l_progress := 'PO_REQAPPROVAL_INIT1.Send_Supplier_Comm_Yes_No: 01';

  l_retro_change := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CO_R_RETRO_CHANGE');

  -- Bug 3694128 : get the document type and subtype
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  -- Bug 3694128 : The communication depends on the WF attribute only
  -- for std PO's and blanket releases. For all other documents we
  -- always communicate.
  If (l_retro_change = 'Y') and
     ((l_document_type = 'RELEASE' AND l_document_subtype = 'BLANKET') OR
      (l_document_type = 'PO' AND l_document_subtype = 'STANDARD')) then
        l_supplier_comm := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'CO_H_RETROACTIVE_SUPPLIER_COMM');
  else
     l_supplier_comm := 'Y';
  end if;

  -- Bug 3325520
  IF (l_supplier_comm IS NULL) THEN
    l_supplier_comm := 'N';
  END IF; /*IF (l_supplier_comm IS NULL)*/

  resultout := wf_engine.eng_completed || ':' || l_supplier_comm;

  l_progress := 'PO_REQAPPROVAL_INIT1.Send_Supplier_Comm_Yes_No: 02. Result= ' || l_supplier_comm;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
  l_supplier_comm := 'Y';
    resultout := wf_engine.eng_completed || ':' || l_supplier_comm;
END Send_Supplier_Comm_Yes_No;

/* RETROACTIVE FPI END */

/************************************************************************************
* Added this procedure as part of Bug #: 2843760
* This procedure basically checks if archive_on_print option is selected, and if yes
* call procedure PO_ARCHIVE_PO_SV.ARCHIVE_PO to archive the PO
*************************************************************************************/
procedure archive_po(p_document_id in number,
                     p_document_type in varchar2,
                     p_document_subtype in varchar2)
IS
-- <FPJ Refactor Archiving API>
l_return_status varchar2(1) ;
l_msg_count NUMBER := 0;
l_msg_data VARCHAR2(2000);

BEGIN

  -- <FPJ Refactor Archiving API>
  PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
    p_api_version => 1.0,
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_process => 'PRINT',
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data);

END ARCHIVE_PO;


-- <FPJ Retroactive START>
/**
* Public Procedure: Retro_Invoice_Release_WF
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag
* Effects:  This procedure updates invoice adjustment flag, and calls Costing
*           and Inventory APIs.
*/
PROCEDURE Retro_Invoice_Release_WF( itemtype        IN VARCHAR2,
                                    itemkey         IN VARCHAR2,
                                    actid           IN NUMBER,
                                    funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2)
IS

l_retro_change          VARCHAR2(1);
l_document_id           PO_HEADERS_ALL.po_header_id%TYPE;
l_document_type         PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_progress              VARCHAR2(2000);
l_update_releases       VARCHAR2(1) := 'Y';
l_return_status         VARCHAR2(1) ;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(2000);
l_retroactive_update    VARCHAR2(30) := 'NEVER';
l_reset_retro_update    BOOLEAN := FALSE;

BEGIN

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 01';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_update_releases;

  /* Bug# 2846210
  ** Desc: Setting application context as this wf api will be executed
  ** after the background engine is run.
  */

  Set_doc_mgr_context(itemtype, itemkey);

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DOCUMENT_ID');
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DOCUMENT_TYPE');

  l_retro_change := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CO_R_RETRO_CHANGE');

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 02. ' ||
                'l_document_id = ' || l_document_id ||
                'l_document_type = ' || l_document_type ||
                'l_retro_change = ' || l_retro_change ;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Only handle retroactive invoice change for PO or Release
  IF (l_document_type NOT IN ('PO', 'RELEASE')) THEN
    RETURN;
  END IF;

  -- Don't trust l_retro_change='N' because if user makes retro changes, instead
  -- of approving it immediately, he chooses to close the form and re-query
  -- the PO/Release, then approve it.
  -- In this case, d_globals.retroactive_change_flag is lost.
  -- Always trust l_retro_change='Y'
  IF (l_retro_change IS NULL OR l_retro_change = 'N') THEN

    l_retro_change := PO_RETROACTIVE_PRICING_PVT.Is_Retro_Update(
                        p_document_id   => l_document_id,
                        p_document_type => l_document_type);

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 03' ||
                'l_retro_change = ' || l_retro_change ;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


  END IF; /*IF (l_retro_change IS NULL OR l_retro_change = 'N')*/

  IF (l_retro_change = 'Y') THEN
    l_retroactive_update := PO_RETROACTIVE_PRICING_PVT.Get_Retro_Mode;

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 04' ||
                'l_retroactive_update = ' || l_retroactive_update;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    -- Need to reset retroactive_date afterwards
    l_reset_retro_update := TRUE;

    IF (l_retroactive_update = 'NEVER') THEN
      l_retro_change := 'N';
    END IF; /*IF (l_retroactive_update = 'NEVER')*/

  END IF; /*IF (l_retro_change = 'Y')*/

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 05' ||
                'l_retroactive_update = ' || l_retroactive_update ||
                'l_retro_change = ' || l_retro_change ;
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Set 'CO_R_RETRO_CHANGE' attribute so that later Workflow process can
  -- use this attribute safely
  PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CO_R_RETRO_CHANGE',
                                  avalue   =>  l_retro_change);

  IF (l_retro_change = 'Y' AND l_retroactive_update = 'ALL_RELEASES') THEN
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 06. Calling ' ||
                  'PO_RETROACTIVE_PRICING_PVT.Retro_Invoice_Release';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_RETROACTIVE_PRICING_PVT.Retro_Invoice_Release
      ( p_api_version   => 1.0,
        p_document_id   => l_document_id,
        p_document_type => l_document_type ,
        x_return_status => l_return_status,
        x_msg_count        => l_msg_count,
        x_msg_data         => l_msg_data);

    IF (l_return_status <> 'S') THEN
      l_update_releases := 'N';
    END IF;

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 07. Result= ' ||
                  l_update_releases;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

  END IF; /*IF (l_retro_change = 'Y' AND l_retroactive_update = 'ALL_RELEASES')*/

  IF (l_reset_retro_update) THEN
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 08. Reset_Retro_Update';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_RETROACTIVE_PRICING_PVT.Reset_Retro_Update(
        p_document_id   => l_document_id,
        p_document_type => l_document_type);
  END IF; /*IF (l_reset_retro_update)*/

  resultout := wf_engine.eng_completed || ':' || l_update_releases;

EXCEPTION
  WHEN OTHERS THEN
    l_update_releases := 'N';
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 09.'||
                  ' Result= ' || l_update_releases;
    resultout := wf_engine.eng_completed || ':' || l_update_releases;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

END Retro_Invoice_Release_WF;

-- <FPJ Retroactive END>

-------------------------------------------------------------------------------
--Start of Comments :  Bug 3845048
--Name: UpdateActionHistory
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Updates the action history for the given doc with an action
--Parameters:
--IN:
--p_doc_id
--  Document id
--p_doc_type
--  Document type
--p_doc_subtype
--  Document Sub type
--p_action
--  Action to be inserted into the action history
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-- <BUG 5691965 START>
/*
  Update the Action History with a note ICX_POR_NOTIF_TIMEOUT in approvers
  language
*/
PROCEDURE UpdateActionHistory(p_doc_id      IN number,
                              p_doc_type    IN varchar2,
                              p_doc_subtype IN varchar2,
                              p_action      IN varchar2
                              ) is
pragma AUTONOMOUS_TRANSACTION;

l_emp_id          NUMBER;
l_rowid           ROWID;
l_name            wf_local_roles.NAME%TYPE;
l_display_name    wf_local_roles.display_name%TYPE;
l_email_address   wf_local_roles.email_address%TYPE;
l_notification_preference     wf_local_roles.notification_preference%TYPE;
l_language        wf_local_roles.LANGUAGE%TYPE;
l_territory       wf_local_roles.territory%TYPE;
l_note            fnd_new_messages.message_text%TYPE;

BEGIN
        -- SQL What : Get the employee_id corresponding to the last NULL action record.
        -- Sql Why  : To get hold the language of the employee.

   BEGIN
      SELECT pah.employee_id, pah.ROWID
        INTO l_emp_id,        l_rowid
        FROM po_action_history pah
       WHERE pah.object_id = p_doc_id
         AND pah.object_type_code = p_doc_type
         AND pah.object_sub_type_code = p_doc_subtype
         AND pah.sequence_num = (SELECT Max(sequence_num)
                                   FROM po_action_history pah1
                                  WHERE pah1.object_id = p_doc_id
                                    AND pah1.object_type_code = p_doc_type
                                    AND pah1.object_sub_type_code = p_doc_subtype)
         AND pah.action_code is NULL;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF l_emp_id IS NOT NULL THEN

      wf_directory.GetUserName ( p_orig_system        => 'PER',
                                 p_orig_system_id     => l_emp_id,
                                 p_name               => l_name,
                                 p_display_name       => l_display_name );

      IF l_name IS NOT NULL THEN

         WF_DIRECTORY.GETROLEINFO ( ROLE              => l_name,
                                    Display_Name      => l_display_name,
                                    Email_Address     => l_email_address,
                                    Notification_Preference => l_notification_preference,
                                    LANGUAGE          => l_language,
                                    Territory         => l_territory );

         IF l_language IS NOT NULL THEN
            BEGIN
               -- SQL What : Get the message in the approvers language.
               -- Sql Why  : To maintain the NO ACTION message in approver language.
               SELECT message_text
                 INTO l_note
                 FROM fnd_new_messages fm,
                      fnd_languages fl
                WHERE fm.message_name = 'ICX_POR_NOTIF_TIMEOUT'
                  AND fm.language_code = fl.language_code
                  AND fl.nls_language = l_language;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      END IF;
   END IF;

   IF l_note IS NULL THEN
      l_note := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');
   END IF;

   IF l_rowid IS NOT NULL THEN
      -- SQL What : Update the No action in the action history.
      -- Sql Why  : To maintain the NO ACTION message in approver language.
      UPDATE po_action_history pah
         SET pah.action_code   = p_action,
                  pah.action_date   = SYSDATE,
             pah.Note = l_note,
             pah.last_updated_by   = fnd_global.user_id,
             pah.last_update_login = fnd_global.login_id,
             pah.last_update_date  = SYSDATE
      WHERE ROWID = l_rowid;
   END IF;
   COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    NULL;
END;
-- <BUG 5691965 END>
-------------------------------------------------------------------------------
--Start of Comments :  R12 Online authoring Notifications
--Name: should_notify_cat_admin
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the Catalog admin has to be notified of the
--  PO approval. The catalog admin will be notified if the changes
--  were initiated by admin. In this scenario, the notification will be
--  sent to both the catalog admin (in addition to the buyer+supplier, which is
--  an existing logic)
--Parameters:
--IN:
--p_item_type
--  WF item type
--p_item_key
--  WF Item key
--p_act_id
--  ActionId
--p_func_mode
--  Function mode
--OUT
--x_result_out
--  Y/N: Whether to send notification to catalog admin or not
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE should_notify_cat_admin(p_item_type        in varchar2,
                                  p_item_key         in varchar2,
                                  p_act_id           in number,
                                  p_func_mode        in varchar2,
                                  x_result_out       out NOCOPY varchar2    ) is
l_progress            varchar2(200);
l_doc_id              number;
l_doc_type            PO_HEADERS_ALL.TYPE_LOOKUP_CODE%type;
l_cat_admin_user_name FND_USER.USER_NAME%type;
BEGIN
  l_progress := '100';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,l_progress);
  END IF;

  l_progress := '110';
  -- Get the Catalog Admin User Name
  l_cat_admin_user_name := wf_engine.GetItemAttrText (
                                   itemtype => p_item_type,
                                   itemkey  => p_item_key,
                                   aname    => 'CATALOG_ADMIN_USER_NAME');

  l_progress := '130';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,'Item Attribute value for CATALOG_ADMIN_USER_NAME='|| l_cat_admin_user_name);
  END IF;

  IF l_cat_admin_user_name is not null THEN
       l_progress := '150';
       x_result_out := wf_engine.eng_completed || ':' || 'Y' ;
  ELSE
    l_progress := '190';
    x_result_out := wf_engine.eng_completed || ':' || 'N' ;
  END IF;
  l_progress := '200';

EXCEPTION
  WHEN OTHERS THEN
  wf_core.context('PO_REQAPPROVAL_INIT1','should_notify_cat_admin',l_progress||' DocumentId='||to_char(l_doc_id));
  raise;

END should_notify_cat_admin;


-------------------------------------------------------------------------------
--Start of Comments :  R12 Online authoring Notifications
--Name: should_notify_cat_admin
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  If this is an agreement that has been locked by the catalog admin (change
--  initiator, then set the item attribute CATALOG_ADMIN_USER_NAME so that
--  the catalog admin can be notified later in the workflow process.
--  The reason why we are setting the attribute here instead of checking later
--  in the wf process is because, the lock_owner_role/lock_owner_id will be
--  cleared from po_headers_all later. So first capture the item attribute
--  use it later in the workflow to decide whether a notification has to be
--  sent. See Node "SHOULD_NOTIFY_CAT_ADMIN" function in the PO Approval and
--  PO Approval Top Process(Also see function should_notify_cat_admin() in
--  this file).
--Parameters:
--IN:
--p_item_type
--  WF item type
--p_item_key
--  WF Item key
--p_doc_id
--  Document Id(PO Header Id)
--p_doc_type
--  Document type (PO/PA)
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_catalog_admin_user_name(p_item_type in varchar2,
                                      p_item_key  in varchar2,
                                      p_doc_id    in number,
                                      p_doc_type  in varchar2) is
l_progress           varchar2(255);
l_user_name          FND_USER.USER_NAME%type;
l_lock_owner_role    PO_HEADERS_ALL.lock_owner_role%type;
l_lock_owner_user_id PO_HEADERS_ALL.lock_owner_user_id%type;
BEGIN
  l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 100' ||
                     'Document Id='|| to_char(p_doc_id) ||
                     'Document Type='|| p_doc_type;
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,l_progress);
  END IF;

  l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 110';
  -- Proceed only if this is an agreement
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,l_progress);
  END IF;

  IF p_doc_type = 'PA' THEN
    -- Get the locking user role and user id information
    select lock_owner_user_id, lock_owner_role
    into   l_lock_owner_user_id, l_lock_owner_role
    from   po_headers_all
    where  po_header_id = p_doc_id;

    l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 140' ||
                    'l_lock_owner_user_id ='|| to_char(l_lock_owner_user_id) ||
                    'l_lock_owner_role Type='|| l_lock_owner_role;

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,l_progress);
    END IF;

     IF l_lock_owner_role = 'CAT ADMIN' THEN
       l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 150';

       -- The performer attribute holds the user name, get the user name
       -- associated with the user id
       select user_name into l_user_name
       from   fnd_user
       where  user_id = l_lock_owner_user_id;

       l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 155' ||
                     'UserName='|| l_user_name;
       IF (g_po_wf_debug = 'Y') THEN
         PO_WF_DEBUG_PKG.insert_debug(p_item_type,p_item_key,l_progress);
       END IF;

       l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 160';
       -- Set the item attribute tied to the performer of the
       -- approval notification
       wf_engine.SetItemAttrText ( itemtype => p_item_type ,
                                   itemkey  => p_item_key ,
                                   aname    => 'CATALOG_ADMIN_USER_NAME',
                                   avalue   => l_user_name);
       l_progress := 'PO_REQAPPROVAL_INIT1.set_catalog_admin_user_name: 170';
    END IF; -- End of check for "CAT ADMIN"
  END IF; -- End of Check for "PA" (Agreement check)
  l_progress := '200';

EXCEPTION
  WHEN OTHERS THEN
  wf_core.context('PO_REQAPPROVAL_INIT1','set_catalog_admin_user_name',l_progress||' DocumentId='||to_char(p_doc_id));
  raise;

END set_catalog_admin_user_name;

-------------------------------------------------------------------------------
--Start of Comments :  HTML Orders R12
--Name: get_po_url
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Constructs the PO view/Update page URLs based on the document
--  type and mode
--Parameters:
--IN:
--p_po_header_id
--  Document Id
--p_doc_subtype
--  Document subtype
--p_mode
--  ViewOnly or Update mode
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
Function get_po_url (p_po_header_id IN NUMBER,
                     p_doc_subtype  IN VARCHAR2,
                     p_mode         IN VARCHAR2)
Return VARCHAR2 IS

l_url            varchar2(1000);
l_page_function  varchar2(25);

BEGIN

  IF p_doc_subtype = 'STANDARD' THEN
     l_page_function := 'PO_ORDER';
  ELSIF p_doc_subtype = 'BLANKET' THEN
     l_page_function := 'PO_BLANKET';
  ELSIF p_doc_subtype = 'CONTRACT' THEN
     l_page_function := 'PO_CONTRACT';
  END IF;

  IF p_mode = 'viewOnly' THEN

    /*  Bug 7307832
        Added JSP:/OA_HTML/ before OA.jsp?OAFunc= */
    l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=' || l_page_function || '&' ||
             'poHeaderId=' || p_po_header_id || '&' ||
             'poMode=' || p_mode || '&' ||
             'poCallingModule=notification'|| '&' ||
             'poHideUpdate=Y'|| '&' ||
             'poCallingNotifId=-&#NID-'|| '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y' ;

  ELSE
    /*  Bug 7307832
        Added JSP:/OA_HTML/ before OA.jsp?OAFunc= */
    l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=' || l_page_function || '&' ||
             'poHeaderId=' || p_po_header_id || '&' ||
             'poMode=' || p_mode || '&' ||
             'poCallingModule=notification'|| '&' ||
             'poCallingNotifId=-&#NID-'|| '&' ||
             'retainAM=Y' || '&' || 'addBreadCrumb=Y' ;

  END IF;

  Return l_url;

END;


-- <HTML Agreement R12 START>

-------------------------------------------------------------------------------
--Start of Comments
--Name: unlock_document
--Function:
--  Clear Lock owner information autonomously
--Parameters:
--IN:
--p_po_header_id
--  Document Id
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE unlock_document
( p_po_header_id IN NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  PO_DRAFTS_PVT.unlock_document
  ( p_po_header_id => p_po_header_id
  );

  COMMIT;
END unlock_document;
-- <HTML Agreement R12 END>

-- <Bug 5059002 Begin>

/**
* Public Procedure: set_is_supplier_context_y
* Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y to let
* the POREQ_SELECTOR know we should be in the supplier's context
* and not reset to the buyer's context
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
*/

-- Commenting this code. Most likely will not be required with our context Setting fix.
/* procedure set_is_supplier_context_y(p_item_type        in varchar2,
                                  p_item_key         in varchar2,
                                  p_act_id           in number,
                                  p_func_mode        in varchar2,
                                  x_result_out       out NOCOPY varchar2) is
  l_progress                  VARCHAR2(300);
begin
  l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_y: ';
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'IS_SUPPLIER_CONTEXT',
                                 avalue   => 'Y');

  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
  END IF;
  RAISE;
end set_is_supplier_context_y; */

/**
* Public Procedure: set_is_supplier_context_n
* Sets the workflow attribute IS_SUPPLIER_CONTEXT to N to let
* the POREQ_SELECTOR know we are no longer in the suppliers
* context.
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
*/
/* procedure set_is_supplier_context_n(p_item_type        in varchar2,
                                  p_item_key         in varchar2,
                                  p_act_id           in number,
                                  p_func_mode        in varchar2,
                                  x_result_out       out NOCOPY varchar2) is

  l_progress                  VARCHAR2(300);
begin

  l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_n: ';
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
  END IF;

  -- Set the IS_SUPPLIER_CONTEXT value to 'N'
  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'IS_SUPPLIER_CONTEXT',
                                 avalue   => 'N');

  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
  END IF;
  RAISE;
end set_is_supplier_context_n; */
-- <Bug 5059002 End>

-- <Bug 4950854 Begin>
--  added the following proc to update the print count

--<Bug 14271696 :Cancel Refactoring Project>
-- Made the procedure non-autonomous
-- There was  deadlock error occurring when the communication was invoked
-- from Cancel as the Cancel code also updates the po_headers_all/po_releases_all tables
-- and the Commit/Rollback will not happen when the communication is invoked.
--<Bug 16516373 Start>
-- Autonomous procedure to update print count
PROCEDURE update_print_count( p_doc_id NUMBER,
                              p_doc_type VARCHAR2 )
IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    IF (p_doc_type = 'RELEASE')  THEN

        UPDATE po_releases_all pr
        SET pr.printed_date = sysdate, pr.print_count = nvl(pr.print_count,0) + 1
        WHERE pr.po_release_id = p_doc_id ;

    ELSIF (p_doc_type  in ('PO','PA')) THEN

        UPDATE po_headers_all ph
        SET ph.printed_date = sysdate, ph.print_count = nvl(ph.print_count,0) + 1
        WHERE ph.po_header_id = p_doc_id ;
    END IF;
 COMMIT;
END;

-- Non-Autonomous procedure to update print count
PROCEDURE update_print_count_na( p_doc_id NUMBER,
                              p_doc_type VARCHAR2 )
IS
BEGIN

    IF (p_doc_type = 'RELEASE')  THEN

        UPDATE po_releases_all pr
        SET pr.printed_date = sysdate, pr.print_count = nvl(pr.print_count,0) + 1
        WHERE pr.po_release_id = p_doc_id ;

    ELSIF (p_doc_type  in ('PO','PA')) THEN

        UPDATE po_headers_all ph
        SET ph.printed_date = sysdate, ph.print_count = nvl(ph.print_count,0) + 1
        WHERE ph.po_header_id = p_doc_id ;
    END IF;
END;
--<Bug 16516373 End>

-- <Bug 4950854 End>

-- <BUG 5691965 START>
/*
** Public Procedure: Update_Action_History_TimeOut
** Requires:
**   IN PARAMETERS:
**     Usual workflow attributes.
** Modifies: Action History
** Effects:  Actoin History is updated with No Action if the approval
**           notification is TimedOut.
*/

PROCEDURE Update_Action_History_Timeout (Itemtype     IN    VARCHAR2,
                                         Itemkey      IN    VARCHAR2,
                                         Actid        IN    NUMBER,
                                         Funcmode     IN    VARCHAR2,
                                         Resultout    OUT   NOCOPY VARCHAR2) IS

L_Doc_Id                NUMBER;
L_Doc_Type              Po_Action_History.Object_Type_Code%TYPE;
L_Doc_Subtype           Po_Action_History.Object_Sub_Type_Code%TYPE;

BEGIN

  L_Doc_Type := Wf_Engine.Getitemattrtext (Itemtype => Itemtype,
                                           Itemkey  => Itemkey,
                                           Aname    => 'DOCUMENT_TYPE');

  L_Doc_Subtype := Wf_Engine.Getitemattrtext(Itemtype => Itemtype,
                                             Itemkey  => Itemkey,
                                             Aname    => 'DOCUMENT_SUBTYPE');

  L_Doc_Id := Wf_Engine.Getitemattrnumber (Itemtype => Itemtype,
                                           Itemkey  => Itemkey,
                                           Aname    => 'DOCUMENT_ID');

  UpdateActionHistory ( p_doc_id      =>  L_Doc_Id,
                        p_doc_type    =>  L_Doc_Type,
                        p_doc_subtype =>  L_Doc_Subtype,
                        p_action      =>  'NO ACTION'
                      );

END Update_Action_History_Timeout;
-- <BUG 5691965 END>

-- <Bug 6144768 Begin>
-- When Supplier responds from iSP then the responder should show
-- as supplier and also supplier acknowledgement notifications
-- should be available in the To-Do Notification full list.


/**
* Public Procedure: set_is_supplier_context_y
* Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y to let
* the POREQ_SELECTOR know we should be in the supplier's context
* and not reset to the buyer's context
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
*/
procedure set_is_supplier_context_y(p_item_type        in varchar2,
                                    p_item_key         in varchar2,
                                    p_act_id           in number,
                                    p_func_mode        in varchar2,
                                    x_result_out       out NOCOPY varchar2) is
  l_progress                  VARCHAR2(300);
begin
  l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_y: ';
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'IS_SUPPLIER_CONTEXT',
                                 avalue   => 'Y');

  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
  END IF;
  RAISE;
end set_is_supplier_context_y;

/**
* Public Procedure: set_is_supplier_context_n
* Sets the workflow attribute IS_SUPPLIER_CONTEXT to N to let
* the POREQ_SELECTOR know we are no longer in the suppliers
* context.
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
*/
procedure set_is_supplier_context_n(p_item_type        in varchar2,
                                    p_item_key         in varchar2,
                                    p_act_id           in number,
                                    p_func_mode        in varchar2,
                                    x_result_out       out NOCOPY varchar2) is

  l_progress                  VARCHAR2(300);
begin

  l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_n: ';
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
  END IF;

  -- Set the IS_SUPPLIER_CONTEXT value to 'N'
  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'IS_SUPPLIER_CONTEXT',
                                 avalue   => 'N');

  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
  END IF;
  RAISE;
end set_is_supplier_context_n;
-- <Bug 6144768 End>

-- code added for bug 8291565
-- to avoid sending repetitive FYI notifications to supplier users for the same revision number of a Purchase Order.

PROCEDURE check_rev_num_supplier_notif(itemtype IN VARCHAR2,
                                        itemkey IN VARCHAR2,
                                        actid   IN VARCHAR2,
                                        funcmode IN VARCHAR2,
                                        resultout OUT NOCOPY VARCHAR2) IS

l_revision_num_flag varchar2(2);
l_progress varchar2(255);

BEGIN

  l_revision_num_flag := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'HAS_REVISION_NUM_INCREMENTED');

  l_progress := 'PO_REQAPPROVAL_INIT1.check_rev_num_supplier_notif: HAS_REVISION_NUM_INCREMENTED = '||l_revision_num_flag;

  resultout := wf_engine.eng_completed || ':' || l_revision_num_flag ;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_progress || 'Unexpected error');
  END IF;
  RAISE;

END check_rev_num_supplier_notif;

PROCEDURE update_supplier_com_rev_num(itemtype IN VARCHAR2,
                                      itemkey IN VARCHAR2,
                                      actid   IN VARCHAR2,
                                      funcmode IN VARCHAR2,
                                      resultout OUT NOCOPY VARCHAR2) IS

l_po_header_id NUMBER;
l_po_revision_num_curr NUMBER;
l_progress varchar2(255);
l_doc_type varchar2(10);

BEGIN

  l_po_header_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'DOCUMENT_ID');

  l_po_revision_num_curr := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'NEW_PO_REVISION_NUM');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  /* bug 10399957 - adding the call to update the comm_rev_num value
                    in a seperate autonomous transaction type procedure
                    to resolve deadlock issues */

  Set_Comm_Rev_Num(l_doc_type, l_po_header_id, l_po_revision_num_curr);

  l_progress := 'PO_REQAPPROVAL_INIT1.update_supplier_com_rev_num: Current PO Rev Number = '||l_po_revision_num_curr;

EXCEPTION
WHEN OTHERS THEN
  IF (g_po_wf_debug = 'Y') THEN
   PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, l_progress || 'Unexpected error');
  END IF;
  RAISE;

END update_supplier_com_rev_num;

-- end of code added for bug 8291565
-- to avoid sending repetitive FYI notifications to supplier users for the same revision number of a Purchase Order.

-- Bug#18416955
-- Is_Doc_Release
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Check if this document is release or not, if not, then using the OAF html notification body
--   if Yes, then using the TEXT mode body,

procedure Is_Doc_Release(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_doc_type varchar2(25);
x_resultout   varchar2(1);
x_progress    varchar2(300);

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Is_Doc_Release: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');


  IF l_doc_type = 'RELEASE' THEN
      x_resultout := 'Y';
  ELSE
      x_resultout := 'N';
  END IF;

  resultout := x_resultout;

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_Doc_Release: 02. Result=' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_Doc_Release',x_progress);
    raise;
END Is_Doc_Release;

--Bug#18301844
procedure cancel_comm_process(ItemType               VARCHAR2,
                              ItemKey                VARCHAR2,
                              WorkflowProcess        VARCHAR2,
                              ActionOriginatedFrom   VARCHAR2,
                              DocumentID             NUMBER,
                              DocumentTypeCode       VARCHAR2,
                              DocumentSubtype        VARCHAR2,
                              SubmitterAction        VARCHAR2,
                              p_Background_Flag      VARCHAR2 default 'N',
                              p_communication_method_value VARCHAR2,      --bug#19214300
                              p_communication_method_option VARCHAR2) is  --bug#19214300
 l_po_revision_num_orig NUMBER;
 l_itemtype         po_headers_all.wf_item_type%type := ItemType;
 l_itemkey          po_headers_all.wf_item_key%type  := ItemKey;
 l_workflow_process po_document_types.wf_approval_process%type := WorkflowProcess;
 l_revision_num     po_headers_all.revision_num%type;
 l_rev_incremented  varchar2(1) := 'N';
 l_progress         varchar2(100);
 l_view_po_url varchar2(1000);
 l_agent_id number;
 l_preparer_user_name varchar2(100);
 l_preparer_disp_name varchar2(100);

/* Bug 19214300 */
l_fax_flag varchar2(1);
l_email_flag varchar2(1);
l_print_flag varchar2(1);
l_fax_number po_headers_all.fax%type;
l_email_address po_headers_all.email_address%type;
/* Bug 19214300 */
begin
    --Create the process
    wf_engine.CreateProcess( ItemType => l_itemtype,
                             ItemKey  => l_itemkey,
                             process  => l_workflow_process );

    IF DocumentTypeCode IN ('PO', 'PA') THEN
	  	SELECT nvl(comm_rev_num, -1), revision_num, decode(sign(revision_num - nvl(comm_rev_num, -1)), 1, 'Y', 'N'), agent_id
		    INTO l_po_revision_num_orig, l_revision_num, l_rev_incremented, l_agent_id
		    FROM po_headers_all
		   WHERE po_header_id = DocumentID;
    ELSIF DocumentTypeCode in ('RELEASE') THEN
	  	SELECT nvl(comm_rev_num, -1), revision_num, decode(sign(revision_num - nvl(comm_rev_num, -1)), 1, 'Y', 'N'), agent_id
		    INTO l_po_revision_num_orig, l_revision_num, l_rev_incremented, l_agent_id
		    FROM po_releases_all
		   WHERE po_release_id = DocumentID;
    END IF;

    if l_agent_id is not null then
	     PO_REQAPPROVAL_INIT1.get_user_name(l_agent_id, l_preparer_user_name,
                                      l_preparer_disp_name);
       PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PREPARER_USER_NAME',
                                    avalue => l_preparer_user_name);

       PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PREPARER_DISPLAY_NAME',
                                    avalue => l_preparer_disp_name);
    end if;

	  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                            itemkey => l_itemkey,
                            aname => 'OLD_PO_REVISION_NUM',
                            AVALUE => l_po_revision_num_orig);

  	PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                            itemkey => l_itemkey,
                            aname => 'NEW_PO_REVISION_NUM',
                            AVALUE => l_revision_num);

  	PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                            itemkey => l_itemkey,
                            aname => 'HAS_REVISION_NUM_INCREMENTED',
                            AVALUE => l_rev_incremented);

    l_view_po_url := PO_REQAPPROVAL_INIT1.get_po_url(p_po_header_id => DocumentID,
                                                     p_doc_subtype  => DocumentSubtype,
                                                     p_mode         => 'viewOnly');

    PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'VIEW_DOC_URL',
                                    avalue => l_view_po_url);
    l_progress := 'Start to launch cancel_communicate process.';
    IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
    END IF;

    --bug#19214300
    IF (p_communication_method_option = 'FAX') THEN
      l_fax_flag := 'Y';
      l_fax_number := p_communication_method_value;
    ELSIF (p_communication_method_option = 'EMAIL') THEN
      l_email_flag := 'Y';
      l_email_address := p_communication_method_value;
    ELSIF (p_communication_method_option = 'PRINT') THEN
      l_print_flag := 'Y';
    END IF;
    --bug#19214300

    PO_REQAPPROVAL_INIT1.start_wf_process
        ( ItemType => l_itemtype,
          ItemKey => l_itemkey,
          WorkflowProcess => l_workflow_process,
          ActionOriginatedFrom => ActionOriginatedFrom,
          DocumentId => DocumentID,
          DocumentNumber => NULL,  -- Obsolete parameter
          PreparerId => NULL,
          DocumentTypeCode => DocumentTypeCode,
          DocumentSubtype => DocumentSubtype,
          SubmitterAction => SubmitterAction,
          ForwardToId => NULL,
          ForwardFromId => NULL,
          DefaultApprovalPathId => NULL,
          Note => NULL,
          PrintFlag => l_print_flag,  --bug#19214300
          FaxFlag => l_fax_flag,      --bug#19214300
          FaxNumber => l_fax_number,  --bug#19214300
          EmailFlag => l_email_flag,  --bug#19214300
          EmailAddress => l_email_address,  --bug#19214300
          CreateSourcingRule => NULL,
          ReleaseGenMethod => NULL,
          UpdateSourcingRule => NULL,
          p_Background_Flag => p_Background_Flag
        );

    l_progress := 'End to launch cancel_communicate process.';
    IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
    END IF;

Exception
   when others then
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
     END IF;
     po_message_s.sql_error('In Exception of cancel_comm_process()', l_progress, sqlcode);
     RAISE;
end cancel_comm_process;

end PO_REQAPPROVAL_INIT1;

/
