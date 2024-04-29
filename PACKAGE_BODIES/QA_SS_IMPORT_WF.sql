--------------------------------------------------------
--  DDL for Package Body QA_SS_IMPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_IMPORT_WF" AS
  /* $Header: qltsswfb.plb 120.1.12010000.5 2010/04/26 17:13:57 ntungare ship $ */


  --
  --This is a complete package that is used for the workflow notifications
  --sent from Self Service. This is used for both Self Service Transaction
  --Notification (which is launched at the time of Collection Import when
  --rows entered through self service error out)and Buyer Notification
  --(which is launched when the user invokes the "Send Notification"
  --button from the Self Service Enter Quality Results Page.
  --
  --The following procedures will be used for the QA Self Service Transaction
  --Notification Workflow
  --   Procedure unblock
  --   Procedure Check_Completion
  --   Procedure Dispatch_Notification.
  --   Procedure Set_Message_Attr
  --
  --The following procedures will be used for the QA Self Service Buyer
  --Notification Workflow
  --   Procedure Start_Buyer_Notification
  --   Procedure Send
  --   Function Get_Buyer_Name
  --   Function Get_User_Name
  --   Function Get_Plan_Name
  --   Function Get_Item
  --   Procedure Set_Supplier_Info
  --   Function Get_PO_Number
  --
  --Author: Revathy Narasimhan (rnarasim)
  --Created on: 99/07/23
  --

  --
  --These global variables are set for the transaction notification.
  --They are set only once and are accessed later
  --

  x_plan_name VARCHAR2(30);
  x_user_name VARCHAR2(100);
  x_organization_code VARCHAR2(3);
  x_error_rows NUMBER;
  x_creation_date DATE;
  x_last_updated_name VARCHAR2(80);
  -- Bug 9251631 FP for 8939914.Increased buyer_name to 100 characters.pdube
  -- x_buyer_name VARCHAR2(80);
  x_buyer_name VARCHAR2(100);

  --
  --The Transaction Notification Process is started before the Collection
  --Manager spawns the workers.
  --Package: QLTTRAMB; Function: launch_workflow;
  --
  --After the workflow is launched, the process immediately goes
  --to a block state.
  --As and when each worker is completed this procedure is called.
  --This unblocks the BLOCK activity. Once unblocked, the process moves to
  --the activity CHECK_COMPLETION.
  --Called from package: QLTTRAWB; Procedure WRAPPER; File: qlttrawb.plb
  --

PROCEDURE unblock (item_type IN VARCHAR2, key IN NUMBER) IS
   x_num_workers NUMBER;
BEGIN
   x_num_workers := wf_engine.getitemattrnumber(
     itemtype => item_type,
     itemkey => key,
     aname => 'NUM_WORKERS');
   x_num_workers := x_num_workers - 1;
   wf_engine.setitemattrnumber(
     itemtype => item_type,
     itemkey => key,
     aname => 'NUM_WORKERS',
     avalue => x_num_workers);
   wf_engine.completeactivity(item_type, key, 'BLOCK', NULL);
   RETURN;
END unblock;

--
--This Procedure will be called to check and see if all workers have finished
--Item attribute Num_Workers has the total number of workers launched.
--The Collection manager sets this item attribute value when it launches
--the workflow process.
--The process will go back to the UNBLOCK state from CHECK_COMPLETION stage
--till Num_Workers = 0(which implies that all workers have finished). It then
--proceeds to the Dispatch Notification activity.
--

PROCEDURE check_completion (itemtype IN VARCHAR2,
                            itemkey  IN VARCHAR2,
                            actid    IN NUMBER,
                            funcmode IN VARCHAR2,
                            result   OUT NOCOPY VARCHAR2) IS
   x_num_workers NUMBER;
   x_comp_workers NUMBER;
BEGIN
   IF (funcmode = 'RUN') THEN
      x_num_workers := wf_engine.getitemattrnumber(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'NUM_WORKERS');

      IF x_num_workers = 0  THEN
         result := 'COMPLETE:Y';
         RETURN;
      ELSE
         result := 'COMPLETE:N';
         RETURN;
      END IF;
   END IF;
END check_completion;


--
--Dispatch_Notification uses a cursor to find the right set of records.
--For every row of the record, a notification will be sent,to the user
--and the Supervisor.
--If the buyer exists then a notification is sent to the buyer as well.
--

PROCEDURE dispatch_notification (itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2,
                                 actid    IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 result   OUT NOCOPY VARCHAR2) IS
   x_request_id NUMBER;
   x_nid_user NUMBER;
   x_nid_supervisor NUMBER;
   x_nid_buyer NUMBER;

   --
   --This cursor gets the buyer name from po_agent_id in fnd_user
   --This cursor also gets the last_update_login from fnd_user
   --This also gets the name for source_line_id.
   --It fetches only the error rows from QRI.
   --

   cursor qri(x_request_id NUMBER) IS
     SELECT
     qr.plan_name, fu1.user_name, qr.organization_code,
       count(*), qr.creation_date,
       fu2.user_name, fu3.user_name
       FROM
       qa_results_interface qr, fnd_user fu1,
       fnd_user fu2, fnd_user fu3
       WHERE
       qr.source_line_id IS NOT NULL AND
       qr.process_status = 3 AND
       qr.request_id = x_request_id AND
       qr.source_line_id = fu1.user_id AND
       qr.last_update_login = fu2.user_id AND
       qr.po_agent_id = fu3.employee_id (+)
       GROUP BY
       qr.plan_name, fu1.user_name,
       qr.organization_code ,qr.creation_date,
       fu2.user_name, fu3.user_name;

BEGIN
   IF (funcmode = 'RUN') THEN
      x_request_id := wf_engine.getitemattrnumber(
        itemtype => 'QASSIMP',
        itemkey => itemkey,
        aname => 'REQUEST_ID');

      open qri(x_request_id);
      fetch qri INTO x_plan_name,
        x_user_name,
        x_organization_code,
        x_error_rows,
        x_creation_date,
        x_last_updated_name,
        x_buyer_name;

      WHILE qri%found LOOP

         x_nid_user := wf_notification.send
           (x_user_name,
           itemtype ,
           'FAILURE_DETECTED_TO_USER');
         set_message_attr(x_nid_user);
         x_nid_supervisor := wf_notification.send
           (x_last_updated_name,
           itemtype,
           'FAILURE_DETECTED_TO_SUPERVISOR');
         set_message_attr(x_nid_supervisor);

         IF x_buyer_name IS NOT NULL THEN
            x_nid_buyer := wf_notification.send
              (x_buyer_name,
              itemtype,
              'FAILURE_DETECTED_TO_BUYER');
            set_message_attr(x_nid_buyer);
         END IF;

         fetch qri INTO x_plan_name,
           x_user_name,
           x_organization_code,
           x_error_rows,
           x_creation_date,
           x_last_updated_name,
           x_buyer_name;

      END LOOP;
      close qri;
      result := 'COMPLETE:NO_MORE_ROWS';
   END IF; -- funcmode = 'Run'

END dispatch_notification;

--
--This procedure is called for a particular import notification,
--to set all the message attributes.
--

PROCEDURE set_message_attr(id IN NUMBER) IS
BEGIN
   wf_notification.setattrdate(id, 'CREATION_DATE', x_creation_date);
   wf_notification.setattrtext(id, 'PLAN_NAME', x_plan_name);
   wf_notification.setattrnumber(id, 'ERROR_ROWS', x_error_rows);
   wf_notification.setattrtext(id, 'USER_NAME', x_user_name);
   wf_notification.setattrtext(id, 'BUYER_NAME', x_buyer_name);
   wf_notification.setattrtext(id, 'ORGANIZATION_CODE', x_organization_code);
   wf_notification.setattrtext(id, 'LAST_UPDATE_LOGIN', x_last_updated_name);
END set_message_attr;


--
--This is used for starting Buyer notifications. This procedure starts
--the process and sets the attributes that are required for sending the
--notification. Called from package: QA_SS_CORE; Procedure Enter_Results
--File: qltsscob.plb
--

PROCEDURE start_buyer_notification
  (x_buyer_id IN NUMBER DEFAULT NULL,
   x_source_id IN NUMBER DEFAULT NULL,
   x_plan_id IN NUMBER DEFAULT NULL ,
   x_item_id IN NUMBER DEFAULT NULL,
   x_po_header_id IN NUMBER DEFAULT NULL) IS

   x_itemkey NUMBER;
   -- Bug 9251631 FP for 8939914.pdube
   -- Increased the size of variable to support 100 characters for buyer_name.
   -- x_buyer_name VARCHAR2(60) := 'Buyer Information Not Available';
   x_buyer_name VARCHAR2(100) := 'Buyer Information Not Available';
   x_plan_name VARCHAR2(60):= 'Plan Name Not Available';
   -- Bug 9251631 FP for 8939914.pdube
   -- Increased the size of variable to support 100 characters for user_name.
   -- x_user_name VARCHAR2(60) := 'User Name Not Available';
   x_user_name VARCHAR2(100) := 'User Name Not Available';

   x_item VARCHAR2(60) := 'Item Information Not Available';
   --
   -- bug 9652549 CLM changes
   --
   x_po_number VARCHAR2(80) := 'PO Number not available';
   x_itemtype VARCHAR2(8);
   x_org_id NUMBER;
   x_org_code VARCHAR2(3);
   x_org_name hr_all_organization_units.name%type;

BEGIN



   --Get the name of the itemtype to use, depending on the
   --profile option.
   --

   x_itemtype := get_itemtype_profile;

   --
   --Create Buyer Notification Process.
   --Return the itemkey.
   --

   x_itemkey  := create_buyer_process(x_itemtype);

   --
   --
   --Now get the various attributes and set them. Then start
   --the process.
   --Get Buyer name and set it.
   --

   IF x_buyer_id IS NOT NULL THEN
      x_buyer_name := get_buyer_name(x_buyer_id);
   END IF;
   wf_engine.setitemattrtext(
     itemtype => x_itemtype,
     itemkey  => x_itemkey,
     aname    => 'BUYER_NAME',
     avalue   => x_buyer_name);

   --
   --Get User Name, set it and also set the supplier information.
   --

   IF x_source_id IS NOT NULL THEN
      x_user_name := get_user_name(x_source_id);
      set_supplier_info(x_source_id, x_itemkey, x_itemtype);
   END IF;
   wf_engine.setitemattrtext(
     itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'USER_NAME',
       avalue   => x_user_name);

     --
     --Get Plan Name and set it.
     --

     IF x_plan_id IS NOT NULL THEN
        x_plan_name := get_plan_name(x_plan_id);
     END IF;
     wf_engine.setitemattrtext(
       itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'PLAN_NAME',
       avalue   => x_plan_name);

     --
     --Get OrgId and set it.
     --

     x_org_id := get_org_id(x_plan_id);
     wf_engine.setitemattrnumber(
       itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'ORGANIZATION_ID',
       avalue   => x_org_id);



     -- The two get and sets below are added to resolve the bug 1052466
     --
     -- orashid


     --
     --Get OrgCode and set it.
     --

     x_org_code := get_org_code(x_org_id);

     wf_engine.setitemattrtext(
     itemtype => x_itemtype,
     itemkey  => x_itemkey,
     aname    => 'ORGANIZATION_CODE',
     avalue   => x_org_code);

--
     --Get OrgName and set it.
     --

     x_org_name := get_org_name(x_org_id);
     wf_engine.setitemattrtext(
       itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'ORGANIZATION_NAME',
       avalue   => x_org_name);

     --
     --Get Item and set it.
     --

     IF x_item_id IS NOT NULL THEN
        x_item := get_item(x_item_id);
     END IF;
     wf_engine.setitemattrtext(
       itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'ITEM',
       avalue   => x_item);

     --
     --Get PO Number and set it.
     --

     IF x_po_header_id IS NOT NULL THEN
        x_po_number := get_po_number(x_po_header_id);
     END IF;
     wf_engine.setitemattrtext(
       itemtype => x_itemtype,
       itemkey  => x_itemkey,
       aname    => 'PO_NUMBER',
       avalue   => x_po_number);

     --
     --Start WF Process
     --

     wf_engine.startprocess(
       itemtype => x_itemtype,
       itemkey  => x_itemkey);
END start_buyer_notification;


--
--Used for sending the notification. We need to fetch the item level
--attributes and set each of them, for the message level attributes.
--If Workflow comes up with better mechanism, where you donot need to
--set the message level attributes, please rewrite this procedure : you would
--not need these gets and sets !
--Revathy
--

PROCEDURE send  (itemtype IN VARCHAR2,
                 itemkey  IN VARCHAR2,
                 actid    IN NUMBER,
                 funcmode IN  VARCHAR2,
                 result   OUT NOCOPY VARCHAR2) IS
   x_nid NUMBER;
   -- Bug 9251631 FP for 8939914.increased x_buyer_name to 100 chars.pdube
   -- x_buyer_name VARCHAR2(30);
   x_buyer_name VARCHAR2(100);

   x_plan_name VARCHAR2(30);

   -- Bug 9251631 FP for 8939914.increased x_user_name to 100 chars.pdube
   -- x_user_name VARCHAR2(30);
   x_user_name VARCHAR2(100);

   x_item VARCHAR2(60);
   x_supplier_name VARCHAR2(240);
   x_contact_name VARCHAR2(30);
   x_contact_phone VARCHAR2(30);
   --
   -- bug 9652549 CLM changes
   --
   x_po_number VARCHAR2(80);
   x_rsinf VARCHAR2(80);
   x_cimdf VARCHAR2(200);
   x_cursor_plan_name VARCHAR2(60);
   x_org_id NUMBER;
   x_org_code VARCHAR2(3);
   x_org_name hr_all_organization_units.name%type;


BEGIN
   IF (funcmode='RUN') THEN

      x_buyer_name := wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'BUYER_NAME');
      x_plan_name :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'PLAN_NAME');
      x_user_name :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'USER_NAME');
      x_item :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'ITEM');
      x_supplier_name :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'SUPPLIER_NAME');
      x_contact_name :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'CONTACT_NAME');
      x_contact_phone :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'CONTACT_PHONE');
      x_po_number :=   wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'PO_NUMBER');

     x_org_id :=  wf_engine.getitemattrnumber(
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'ORGANIZATION_ID');

     -- The next two gets are added to resolve the bug 1052466
     --
     -- orashid

        x_org_code :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'ORGANIZATION_CODE');

        x_org_name :=  wf_engine.getitemattrtext(
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'ORGANIZATION_NAME');


      --
      --Formulate the command for launching forms.
      --

      x_cimdf := 'QACIMDF:ORG_ID="'|| '&' || 'ORGANIZATION_ID"'||
        ' SELF_SERVICE="YES"' ||
        ' SELF_SERVICE_PLAN_NAME="' || '&' || 'PLAN_NAME"';

      x_rsinf := 'QARSINF:ORG_ID="'|| '&' || 'ORGANIZATION_ID"'||
        ' SELF_SERVICE_PLAN_NAME="' || '&' || 'PLAN_NAME"';

      --
      --Its not enough if the item level attributes are set.
      --We also have to set the message attributes, for each message
      --sent using wf_notification.send
      --

      x_nid := wf_notification.send(x_buyer_name, itemtype, 'RESULTS_SAVED_TO_BUYER');
      wf_notification.setattrtext(x_nid, 'BUYER_NAME', x_buyer_name);
      wf_notification.setattrtext(x_nid, 'PLAN_NAME', x_plan_name);
      wf_notification.setattrtext(x_nid, 'USER_NAME', x_user_name);
      wf_notification.setattrtext(x_nid, 'ITEM', x_item);
      wf_notification.setattrtext(x_nid, 'SUPPLIER_NAME', x_supplier_name);
      wf_notification.setattrtext(x_nid, 'CONTACT_NAME', x_contact_name);
      wf_notification.setattrtext(x_nid, 'CONTACT_PHONE', x_contact_phone);
      wf_notification.setattrtext(x_nid, 'PO_NUMBER', x_po_number);
      wf_notification.setattrnumber(x_nid, 'ORGANIZATION_ID', x_org_id);
      wf_notification.setattrtext(x_nid, 'ORGANIZATION_CODE', x_org_code);
      wf_notification.setattrtext(x_nid, 'ORGANIZATION_NAME', x_org_name);
      wf_notification.setattrtext(x_nid, 'OPEN_CIMDF_COMMAND', x_cimdf);
      wf_notification.setattrtext(x_nid, 'OPEN_RSINF_COMMAND', x_rsinf);
      -- Bug 8678616.FP to 8560872.Added this statement to update the subject
      -- with plan name.pdube Thu Jun 18 00:29:40 PDT 2009
      wf_notification.denormalize_notification(x_nid);

   END IF;

END send;

--
--This function starts the Buyer Notification Process
--

FUNCTION create_buyer_process(x_type IN VARCHAR2) RETURN NUMBER IS
   x_itemkey NUMBER;
   cursor c IS
     SELECT qa_ss_notify_workflow_s.nextval FROM dual;
BEGIN
   open c;
   fetch c INTO x_itemkey;
   close c;
   wf_engine.createprocess(
     itemtype => x_type,
     itemkey  => x_itemkey,
     process  => 'BUYER_NOTIFICATION');
   RETURN x_itemkey;
END create_buyer_process;


--
--This function returns the itemtype as defined in the profile option.
--

FUNCTION get_itemtype_profile RETURN VARCHAR2 IS
   x_profile_val NUMBER;
   x_type VARCHAR2(20);
BEGIN
   x_profile_val := fnd_profile.VALUE('QA_SS_NOTIFY_WORKFLOW');
   IF x_profile_val = 1 THEN
      x_type := 'QASSNOT';
   ELSE
      x_type := 'QASSUNOT';
   END IF;
   RETURN x_type;
END get_itemtype_profile;

--
--This function returns the Buyer name for given Buyer.
--Uses the directory service provided by Workflow to get the name
--For more information, look at Worflow APIs.

FUNCTION get_buyer_name(s_id IN NUMBER) RETURN VARCHAR2 IS
   -- Bug 9251631 FP for 8939914.Increated disp_name to 360 chars and b_name to 100.pdube
   -- b_name VARCHAR2(30);
   -- x_disp_name VARCHAR2(60);
   b_name VARCHAR2(100);
   x_disp_name VARCHAR2(360);
BEGIN
   wf_directory.getusername('PER', s_id, b_name, x_disp_name);
   RETURN b_name;
END get_buyer_name;

--
--Function to retrieve user name.
--

FUNCTION get_user_name(u_id IN NUMBER) RETURN VARCHAR2 IS
   -- Bug 9251631 FP for 8939914.pdube
   -- u_name VARCHAR2(30);
   u_name VARCHAR2(100);
   cursor c IS
     SELECT DISTINCT fu.user_name FROM
       fnd_user fu
       WHERE
       fu.user_id = u_id;
BEGIN

   open c;
   fetch c INTO u_name;
   IF c%notfound THEN
      close c;
      RETURN NULL;
   ELSE
      close c;
      RETURN u_name;
   END IF;
END get_user_name;

--
--This function returns the plan name.
--

FUNCTION get_plan_name(p_id IN NUMBER) RETURN VARCHAR2 IS
   p_name VARCHAR2(30);
   cursor c IS
     SELECT name FROM
       qa_plans qp
       WHERE
       qp.plan_id = p_id;
BEGIN
   open c;
   fetch c INTO p_name;
   IF c%notfound THEN
      close c;
      RETURN NULL;
   ELSE
      close c;
      RETURN p_name;
   END IF;
END get_plan_name;

--
--This function finds the Org Id given the plan name
--


FUNCTION get_org_id(p_id IN NUMBER) RETURN NUMBER IS
   x_id NUMBER;
   x_cursor_plan_id NUMBER;
   cursor c(x_cursor_plan_id NUMBER) IS
     SELECT organization_id FROM qa_plans
       WHERE plan_id = x_cursor_plan_id;
BEGIN
   open c(p_id);
   fetch c INTO x_id;
   close c;
   RETURN x_id;
END get_org_id;


-- The two functions below were added to resolve the bug # 1052466
--
-- orashid


--
--This function finds the Org Code given the org id
--


FUNCTION get_org_code (org_id IN NUMBER) RETURN VARCHAR2 IS

   x_org_code varchar2(3);
   x_cursor_org_id NUMBER;

   -- Bug 4958774. SQL Repository Fix SQL ID: 15008535
   cursor c(x_cursor_org_id NUMBER) IS
     SELECT organization_code
     FROM mtl_parameters -- org_organization_definitions
       WHERE  organization_id = x_cursor_org_id;

BEGIN

   open c(org_id);
   fetch c INTO x_org_code;
   close c;
   RETURN x_org_code;

END get_org_code;


--
--This function finds the Org Name given the org id
--

FUNCTION get_org_name (org_id IN NUMBER) RETURN VARCHAR2 IS

   x_org_name hr_all_organization_units.name%type;
   x_cursor_org_id NUMBER;

   -- Bug 4958774.  SQL Repository Fix SQL ID: 15008551
   cursor c(x_cursor_org_id NUMBER) IS
     SELECT organization_name
     FROM inv_organization_name_v -- org_organization_definitions
       WHERE  organization_id = x_cursor_org_id;

BEGIN

   open c(org_id);
   fetch c INTO x_org_name;
   close c;
   RETURN x_org_name;

END get_org_name;





--
--Function to retrieve item for an item id
--

FUNCTION get_item (i_id IN NUMBER) RETURN VARCHAR2 IS
   i_name VARCHAR2(30);
   cursor c IS
     SELECT DISTINCT msiv.concatenated_segments FROM
       mtl_system_items_kfv msiv
       WHERE msiv.inventory_item_id = i_id;
BEGIN
   open c;
   fetch c INTO i_name;
   IF c%notfound THEN
      close c;
      RETURN NULL;
   ELSE
      close c;
      RETURN i_name;
   END IF;
END get_item;

--
--Function to retrieve po_number for a po_header_id
--

FUNCTION get_po_number (p_id IN NUMBER) RETURN VARCHAR2 IS
   --
   -- bug 9652549 CLM changes
   --
   po_number VARCHAR2(80);
   cursor c IS
     SELECT DISTINCT po.segment1 FROM
       PO_HEADERS_TRX_V po
       WHERE po.po_header_id = p_id;
BEGIN
   open c;
   fetch c INTO po_number;
   IF c%notfound THEN
      close c;
      RETURN NULL;
   ELSE
      close c;
      RETURN po_number;
   END IF;
END get_po_number;

--
--Sets Supplier Information.
--

PROCEDURE set_supplier_info(s_id IN NUMBER,
                            x_itemkey IN  NUMBER, x_itemtype IN VARCHAR2) IS
   x_supplier_name VARCHAR2(240);
   x_contact_name VARCHAR2(300);
   x_contact_phone VARCHAR2(60);
   --
   -- bug 7383622
   -- Modified the cursor definiton to make use of the
   -- supplier id instaed of the user_id for performance
   -- ntungare
   --
   cursor c (p_supplier_id IN NUMBER) IS
     SELECT pv.vendor_name,
       pvc.first_name || ' ' || pvc.last_name contact_name,
       pvc.area_code || ' ' || pvc.phone contact_phone
       FROM   po_vendors pv,
       po_vendor_sites_all pvs,
       po_vendor_contacts pvc
       --, fnd_user fu
       WHERE  pvc.vendor_site_id = pvs.vendor_site_id AND
       pvs.vendor_id = pv.vendor_id AND
       --pvc.vendor_contact_id = fu.supplier_id AND
       --fu.user_id = s_id
       pvc.vendor_contact_id = p_supplier_id
       ORDER BY pvc.phone; -- list the ones that have telephone first.
   --
   -- bug 7383622
   -- Added a new variable to capture the supplier id
   -- ntungare
   --
   l_supplier_id  NUMBER;

   CURSOR get_supplier_id IS
      SELECT supplier_id from fnd_user where user_id = s_id;
BEGIN
   --
   -- bug 7383622
   -- get the supplier id from the user id
   -- ntungare
   --
   open get_supplier_id;
   fetch get_supplier_id into l_supplier_id;
   close get_supplier_id;

   open c(l_supplier_id);
   fetch c INTO x_supplier_name, x_contact_name, x_contact_phone;
   IF c%found THEN
      wf_engine.setitemattrtext(
        itemtype => x_itemtype,
        itemkey  => x_itemkey,
        aname    => 'SUPPLIER_NAME',
        avalue   => x_supplier_name);
      wf_engine.setitemattrtext(
        itemtype => x_itemtype,
        itemkey  => x_itemkey,
        aname    => 'CONTACT_NAME',
        avalue   => x_contact_name);
      wf_engine.setitemattrtext(
        itemtype => x_itemtype,
        itemkey  => x_itemkey,
        aname    => 'CONTACT_PHONE',
        avalue   => x_contact_phone);
      close c;
      RETURN;
   END IF;
   close c;
   RETURN;
END set_supplier_info;

END qa_ss_import_wf;


/
