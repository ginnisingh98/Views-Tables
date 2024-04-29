--------------------------------------------------------
--  DDL for Package Body PO_ONLINE_AUTHORING_WF_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ONLINE_AUTHORING_WF_ACTIONS" AS
/* $Header: PO_ONLINE_AUTHORING_WF_ACTIONS.plb 120.9.12010000.2 2011/10/10 06:50:22 venuthot ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_ONLINE_AUTHORING_WF_ACTIONS');

-- The module base for the subprogram.
D_start_authoring_enabled_wf CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_authoring_enabled_wf');

-- The module base for the subprogram.
D_start_changes_discarded_wf CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'start_changes_discarded_wf');

-- The module base for the subprogram.
D_get_wf_role_for_suppliers CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_wf_role_for_suppliers');

D_get_wf_role_for_lock_owner CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'D_get_wf_role_for_lock_owner');

-- The following are local/Private procedure that support the workflow APIs:

g_batch_size       NUMBER := 2500;

------------------------------------------------------------------------------
--Start of Comments
--Name: start_authoring_enabled_wf
--Pre-reqs:
--  None
--Modifies:
--  None except the workflow item attributes
--Locks:
--  None
--Function:
--   1. Get the supplier usernames associated with the po_headers_all.vendor_id
--      and get the role associated with that list
--   2. Create AGREEMENT_AUTHORING_ENABLED process
--   3. Set the item attributes for this process(set the supplier role in
--      FORWARD_TO_ROLE item attribute)
--   4. Start the workflow process
--Parameters:
--IN:
--  p_agreement_id
--    po_header_id
--  p_agreement_info
--    The agreement information portion of the notification title
--    This is retrieved by the calling program's controller (Calls getTitle)
--    e.g. "Blanket Agreement 4611, 0"
--  p_ou_name
--    Operating Unit Name
--  p_buyer_user_id
--    Buyer user id
--OUT:
--  none
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE start_authoring_enabled_wf(p_agreement_id       IN NUMBER,
                                     p_agreement_info     IN VARCHAR2,
                                     p_ou_name            IN VARCHAR2,
                                     p_buyer_user_id      IN NUMBER)
IS
l_seq_for_item_key     varchar2(10)  := null;
l_item_type            po_headers_all.wf_item_type%type := 'POAUTH';
l_item_key             po_headers_all.wf_item_key%type := null;
l_supplier_user_name   fnd_user.user_name%type;
l_progress             NUMBER := 0;
-- bug 4733423: Modified the link to access edit blanket page
l_edit_agreement_url   varchar2(1000) :=
     'JSP:/OA_HTML/OA.jsp?OAFunc=PO_BLANKET' ||'&' ||
     'poHeaderId='||to_char(p_agreement_id) || '&' ||
     'poMode=update' || '&' ||
     'poCallingModule=notification' || '&' ||
     'poCallingNotifId=-&#NID-' || '&' ||
     'retainAM=Y' || '&' ||
     'addBreadCrumb=Y' || '&' ||
     'role=SUPPLIER';

l_supplier_list        DBMS_SQL.VARCHAR2_TABLE;
l_buyer_user_name      fnd_user.user_name%type;
l_buyer_display_name   per_people_f.full_name%type;
l_role_name            WF_USER_ROLES.ROLE_NAME%TYPE;
d_mod                  CONSTANT VARCHAR2(100) := D_start_authoring_enabled_wf;

BEGIN
  l_progress := 10;
  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
    PO_LOG.proc_begin(d_mod,'p_agreement_info',p_agreement_info);
    PO_LOG.proc_begin(d_mod,'p_ou_name',p_ou_name);
    PO_LOG.proc_begin(d_mod,'p_buyer_user_id',p_buyer_user_id);
  END IF;

  l_role_name := get_wf_role_for_suppliers(p_agreement_id, 'PA_BLANKET');
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress, 'l_role_name', l_role_name);
  END IF;

  -- Get the Buyer Name
  l_progress := 40;
  PO_REQAPPROVAL_INIT1.get_user_name(p_buyer_user_id,
                                     l_buyer_user_name,
                                     l_buyer_display_name);
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'l_buyer_user_name', l_buyer_user_name);
    PO_LOG.stmt(d_mod,l_progress,'l_buyer_display_name', l_buyer_display_name);
  END IF;

  -- Send the notification to all supplier users registered with the
  -- vendor_id of the document
  l_progress := 100;
  -- Formulate the item key for each Supplier notification
  select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
  into l_seq_for_item_key
  from sys.dual;

  l_progress := 150;
  l_item_key := to_char(p_agreement_id) || '-' || l_seq_for_item_key;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod, l_progress, 'Creating Process with l_item_key', l_item_key);
  END IF;

  -- Create the process
  l_progress := 200;

  wf_engine.createProcess ( ItemType  => l_item_type,
                            ItemKey   => l_item_key,
			    Process   => 'AGREEMENT_AUTHORING_ENABLED');
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'Process Created; Setting Attributes and Starting Process ...');
  END IF;

  l_progress := 300;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'PO_HEADER_ID',
                              avalue   => p_agreement_id);

  l_progress := 400;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'OPERATING_UNIT_NAME',
                              avalue   => p_ou_name);

  l_progress := 500;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'FORWARD_FROM_USER_NAME',
                              avalue   => l_buyer_display_name);

  l_progress := 600;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'FORWARD_TO_ROLE',
                              avalue   => l_role_name);

  l_progress := 700;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'AGREEMENT_INFO',
                              avalue   => p_agreement_info);

  l_progress := 800;
  wf_engine.SetItemAttrText ( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'EDIT_AGREEMENT_URL',
                              avalue   => l_edit_agreement_url);

  wf_engine.SetItemOwner( itemtype => l_item_type,
        		  itemkey  => l_item_key,
			  owner    => l_buyer_user_name);


    l_progress := 900;
    wf_engine.StartProcess ( ItemType  => l_item_type,
                             ItemKey   => l_item_key );
  IF PO_LOG.d_proc THEN
    PO_LOG.stmt(d_mod,l_progress,'End of start_authoring_enabled_wf: WF Process Started.');
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.context('PO_ONLINE_AUTHORING_WF_ACTIONS' , 'start_authoring_enabled_wf', l_item_type, l_item_key, l_progress);
    RAISE;

END start_authoring_enabled_wf;

-- bug5090429 START
------------------------------------------------------------------------------
--Start of Comments
--Name: start_changes_discarded_wf
--Pre-reqs:
--  None
--Modifies:
--  None except the workflow item attributes
--Locks:
--  None
--Function:
--   Sends notification to the user who's currently locking the document
--   about the lock being released and pending changes being discarded
--Parameters:
--IN:
--  p_agreement_id
--    po_header_id
--  p_agreement_info
--    The agreement information portion of the notification title
--    This is retrieved by the calling program's controller (Calls getTitle)
--    e.g. "Blanket Agreement 4611, 0"
--  p_lock_owner_role
--    Role of the user holding the lock
--  p_lock_owner_user_id
--    User ID of the user holding the lock
--  p_buyer_user_id
--    agent id of the buyer
--OUT:
--  none
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_changes_discarded_wf
( p_agreement_id        IN NUMBER,
	p_agreement_info     IN VARCHAR2,
	p_lock_owner_role    IN VARCHAR2,
	p_lock_owner_user_id IN NUMBER,
	p_buyer_user_id      IN NUMBER
) IS

d_mod      CONSTANT VARCHAR2(100) := D_start_changes_discarded_wf;
d_position NUMBER;

c_ITEM_TYPE CONSTANT po_headers_all.wf_item_type%type := 'POAUTH';
c_PROCESS   CONSTANT VARCHAR2(30) := 'AGREEMENT_CHANGES_DISCARDED';

l_seq_for_item_key     NUMBER := NULL;
l_item_key             po_headers_all.wf_item_key%type := null;

l_buyer_user_name      fnd_user.user_name%type;
l_buyer_display_name   per_people_f.full_name%type;

l_lock_owner_user_name      fnd_user.user_name%type;

l_forward_to_role      WF_USER_ROLES.ROLE_NAME%TYPE;
l_forward_to_role_dsp  VARCHAR2(500);
BEGIN
  d_position := 0;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
  END IF;

  -- bug5249393
  -- get lock owner role
  get_wf_role_for_lock_owner
  ( p_po_header_id => p_agreement_id,
    p_lock_owner_role => p_lock_owner_role,
    p_lock_owner_user_id => p_lock_owner_user_id,
    x_wf_role_name => l_forward_to_role,
    x_wf_role_name_dsp => l_forward_to_role_dsp
  );


  PO_REQAPPROVAL_INIT1.get_user_name(p_buyer_user_id,
                                     l_buyer_user_name,
                                     l_buyer_display_name);

  d_position := 10;

  SELECT PO_WF_ITEMKEY_S.NEXTVAL
  INTO   l_seq_for_item_key
  FROM   DUAL;

  l_item_key := p_agreement_id || '-' || l_seq_for_item_key;

  d_position := 20;

  WF_ENGINE.createProcess ( ItemType  => c_ITEM_TYPE,
                            ItemKey   => l_item_key,
                            Process   => c_PROCESS);

  d_position := 30;

  WF_ENGINE.SetItemAttrText ( itemtype => c_ITEM_TYPE,
                              itemkey  => l_item_key,
                              aname    => 'AGREEMENT_INFO',
                              avalue   => p_agreement_info);

  WF_ENGINE.SetItemAttrText ( itemtype => c_ITEM_TYPE,
                              itemkey  => l_item_key,
                              aname    => 'FORWARD_FROM_USER_NAME',
                              avalue   => l_buyer_display_name);

  WF_ENGINE.SetItemAttrText ( itemtype => c_ITEM_TYPE,
                              itemkey  => l_item_key,
                              aname    => 'FORWARD_FROM_FULL_NAME',
                              avalue   => l_buyer_display_name);

  WF_ENGINE.SetItemAttrText ( itemtype => c_ITEM_TYPE,
                              itemkey  => l_item_key,
                              aname    => 'FORWARD_TO_ROLE',
                              avalue   => l_forward_to_role);

  d_position := 40;

  WF_ENGINE.StartProcess ( ItemType  => c_ITEM_TYPE,
                           ItemKey   => l_item_key );

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod,'p_agreement_id',p_agreement_id);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.context('PO_ONLINE_AUTHORING_WF_ACTIONS' , 'start_changes_discarded_wf', c_ITEM_TYPE, l_item_key, d_position);
    RAISE;

END start_changes_discarded_wf;
-- bug5090429 END

------------------------------------------------------------------------------
--Start of Comments
--Name: get_wf_role_for_suppliers
--Pre-reqs:
--  None
--Modifies:
--  wf_role to create a new role
--Locks:
--  None
--Function:
--  For  give po_header_id, this procedure
--   1. Finds the supplier user names associated with po_headers_all.vendor_id
--   2. Checks if there is already a role associated with this supplier list
--   3. If not, then create an adhoc role for this supplier list
--   4. If there is already a role for this supplier list, use it.
--Parameters:
--IN:
--  p_document_id
--    po_header_id
--  p_document_type
--    Document type as expected by po_vendors_grp.get_external_userlist
--    'PO_STANDARD', 'PA_BLANKET', 'PA_CONTRACT'
--    Eventhough currently this code is being called only with PA_CONTRACT,
--    we will use this as a generic utility method to get supplier role.
--RETURN:
--  Workflow role for the supplier list associated with po_headers_all.vendor_id
--End of Comments
-------------------------------------------------------------------------------

FUNCTION get_wf_role_for_suppliers ( p_document_id    in     number,
                                     p_document_type  in     varchar2)
return varchar2 IS

l_progress             NUMBER;

-- declare local variables to hold output of get_supplier_userlist call
l_supplier_user_tbl    po_vendors_grp.external_user_tbl_type;
l_namelist             varchar2(31990):=null;
l_namelist_for_sql     varchar2(32000):=null;
l_num_users            NUMBER := 0;
l_vendor_id            NUMBER;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER := 0;
l_msg_data             VARCHAR2(2000);

-- local variables for role creation
l_role_name            WF_USER_ROLES.ROLE_NAME%TYPE := NULL;
l_role_display_name    varchar2(100):=null;
d_mod                  CONSTANT VARCHAR2(100) := D_get_wf_role_for_suppliers;


BEGIN
  l_progress  := 100;
  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_agreement_id', p_document_id );
    PO_LOG.proc_begin(d_mod,'p_document_type', p_document_type );
  END IF;

  -- Get the supplier user name list for a give po_header_id
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

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress,'x_supplier_userlist',l_namelist );
    PO_LOG.stmt(d_mod,l_progress,'x_num_users', l_num_users);
    PO_LOG.stmt(d_mod,l_progress,'x_vendor_id', l_vendor_id);
  END IF;

  l_progress  := 110;

  -- Proceed if return status is success
  if(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    l_progress  := 120;

    if(l_namelist is null) then
      l_role_name := null;
    else
      l_progress  := 130;
      begin
        -- Role display name is the Supplier name
        select vendor_name
          into l_role_display_name
          from po_vendors
          where vendor_id=l_vendor_id;
        exception
          when others then
            l_role_display_name:=' ';
      end;
      l_progress  := 140;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod, l_progress, 'l_role_display_name',l_role_display_name );
      END IF;

      -- Check for an existing role for this supplier list
      l_role_name:= PO_REQAPPROVAL_INIT1.get_wf_role_for_users(l_namelist_for_sql, l_num_users);
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,l_progress,'l_role_name',l_role_name );
      END IF;

      l_progress  := 150;
      -- If no role already exist for this supplier list, create one
      if (l_role_name is null ) then

        l_progress  := 160;
        -- We need to give a role name before creating an ADHOC role.
        l_role_name := substr('ADHOC' || to_char(sysdate, 'JSSSSS')|| to_char(p_document_id) || p_document_type, 1, 30);

        l_progress  := 170;
        -- Create a role
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_mod,'Creating l_role_name',l_role_name );
        END IF;
        WF_DIRECTORY.CreateAdHocRole( l_role_name,          -- role_name
                                      l_role_display_name , -- role_display_name
                                      null,       -- language
                                      null,       -- territory
                                      null,       -- role_description
                                      'MAILHTML', -- Both email and view notif
                                      l_namelist, -- role_users
                                      null,       -- email_address
                                      null,       -- fax
                                      'ACTIVE',   -- status
                                      null);      -- expiration_date
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_mod,l_progress,'Created l_role_name',l_role_name );
        END IF;
        l_progress  := 180;
        -- newly created adhoc role
      end if; -- if (l_role_name is null )

    end if; -- if(l_namelist is null)

  END IF; -- if(l_return_status = FND_API.G_RET_STS_SUCCESS)

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,l_progress, 'Returning l_role_name',l_role_name );
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod);
  END IF;
  l_progress  := 200;
  return l_role_name;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_ONLINE_AUTHORING_WF_ACTIONS.get_wf_role_for_suppliers failed at:',l_progress);
    wf_core.context('PO_ONLINE_AUTHORING_WF_ACTIONS.get_wf_role_for_suppliers',l_role_name||sqlerrm);
    RETURN NULL;
end get_wf_role_for_suppliers;

-- bug5249393 START
------------------------------------------------------------------------------
--Start of Comments
--Name: get_wf_role_for_lock_owner
--Pre-reqs:
--  None
--Modifies:
--  get wf role for the person locking the document
--Locks:
--  None
--Function:
--  If lock owner is cat admin, then wf role will be the user name of
--     the user and the dsp name will be the one listed in WF directory
--  If lock owner is supplier, then we need to create a adhoc user if one
--     does not exist. This is because we want to the role to have the display
--     name equal to vendor name, which may not exist in the system
--Parameters:
--IN:
--  p_po_header_id
--    Document unique identifier
--  p_lock_owner_role
--    Role of the user locking the document
--  p_lock_owner_user_id
--OUT:
--  x_wf_role_name
--    Workflow adhoc role name
--  x_wf_role_name_dsp
--    Workflow adhoc role display name
--RETURN:
--  Workflow role for the supplier list associated with po_headers_all.vendor_id
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_wf_role_for_lock_owner
( p_po_header_id IN NUMBER,
  p_lock_owner_role IN VARCHAR2,
  p_lock_owner_user_id IN NUMBER,
  x_wf_role_name OUT NOCOPY VARCHAR2,
	x_wf_role_name_dsp OUT NOCOPY VARCHAR2
)
IS

d_mod      CONSTANT VARCHAR2(100) := D_get_wf_role_for_lock_owner;
d_position NUMBER;

l_vendor_name PO_VENDORS.vendor_name%TYPE;
l_emp_id FND_USER.employee_id%TYPE;
l_user_name FND_USER.user_name%TYPE;
l_expected_wf_role_name WF_USER_ROLES.role_name%TYPE;
l_user_table WF_DIRECTORY.UserTable; --Added as part of Bug 13059528 fix

BEGIN

  d_position := 0;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  IF (p_lock_owner_role = PO_GLOBAL.g_role_CAT_ADMIN) THEN
    d_position := 10;

    SELECT employee_id
    INTO   l_emp_id
		FROM   fnd_user
    WHERE  user_id = p_lock_owner_user_id;

    d_position := 20;

    PO_REQAPPROVAL_INIT1.get_user_name
    ( p_employee_id       => l_emp_id,
      x_username          => x_wf_role_name,
      x_user_display_name => x_wf_role_name_dsp
    );

  ELSIF (p_lock_owner_role = PO_GLOBAL.g_role_SUPPLIER) THEN
    d_position := 30;

    SELECT user_name
    INTO   l_user_name
    FROM   fnd_user
    WHERE  user_id = p_lock_owner_user_id;

    SELECT PV.vendor_name
    INTO   x_wf_role_name_dsp
    FROM   po_headers_all POH,
           po_vendors PV
    WHERE  POH.po_header_id = p_po_header_id
    AND    POH.vendor_id = PV.vendor_id;

    l_expected_wf_role_name :=
		  'ADHOC_PO_LOCK_OWNER_' || l_user_name;

    -- Check whether an existing ad hoc role for the supplier user has been
    -- creatd already
    SELECT MAX(role_name)
    INTO   x_wf_role_name
    FROM   WF_USER_ROLES
    WHERE  role_name = l_expected_wf_role_name;

    d_position := 40;

    IF (x_wf_role_name IS NULL) THEN
      -- Need to create a new ad hoc role
      d_position := 50;

      x_wf_role_name := l_expected_wf_role_name;

      --Start of code changes for the bug 13059528
      /*
      WF_DIRECTORY.CreateAdHocRole
      ( x_wf_role_name,
        x_wf_role_name_dsp,
        NULL,
        NULL,
        NULL,
        'MAILHTML',
        l_user_name,
        NULL,
        NULL,
        'ACTIVE',
        NULL
      );*/

      l_user_table(0) := l_user_name;

      WF_DIRECTORY.CreateAdHocRole2
      ( x_wf_role_name,
        x_wf_role_name_dsp,
        NULL,
        NULL,
        NULL,
        'MAILHTML',
        l_user_table,
        NULL,
        NULL,
        'ACTIVE',
        NULL
      );
      --End of code changes for the bug 13059528

    ELSE
        -- if a role already exists, make sure that the role display name
        -- is up to date
        WF_DIRECTORY.setAdHocRoleAttr
        ( x_wf_role_name,
          x_wf_role_name_dsp,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
        );
    END IF;

  ELSE
    d_position := 60;

    -- We should never come to here
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod);
  END IF;

EXCEPTION

WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => D_PACKAGE_BASE,
    p_procedure_name => d_mod || '.' || d_position
  );

  WF_CORE.context('PO_ONLINE_AUTHORING_WF_ACTIONS' , 'get_adhoc_wf_role_for_lock_owner', d_position);
  RAISE;
END get_wf_role_for_lock_owner;
-- bug5249393 END


PROCEDURE create_buyer_acceptance_wf(p_po_header_id    IN NUMBER,
				     p_role            IN VARCHAR2,
				     p_role_user_id    IN NUMBER)
IS
l_progress varchar2(4) := '000';
BEGIN
  l_progress := '010';
  --TO DO: Add iP call here
END create_buyer_acceptance_wf;

END PO_ONLINE_AUTHORING_WF_ACTIONS;

/
