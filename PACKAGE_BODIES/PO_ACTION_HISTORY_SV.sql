--------------------------------------------------------
--  DDL for Package Body PO_ACTION_HISTORY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACTION_HISTORY_SV" AS
-- $Header: POXACTHB.pls 120.0.12010000.3 2014/02/20 08:54:14 aacai ship $

G_PKG_NAME CONSTANT varchar2(30) := 'PO_ACTION_HISTORY_SV';

g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.' ;

-- Read the profile option that enables/disables the debug log
g_debug_stmt   CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp  CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;




--------------------------------------------------------------------------------
-- Private procedures
--------------------------------------------------------------------------------

PROCEDURE initialize_vars(
   x_employee_id                    IN OUT NOCOPY  NUMBER
,  x_user_id                        OUT    NOCOPY  NUMBER
,  x_login_id                       OUT    NOCOPY  NUMBER
);


-------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history
--Pre-reqs:
--  None.
--Modifies:
--  PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  Updates the action history entry for documents that currently have
--  a NULL entry in the action history.
--Parameters:
--IN:
--p_doc_id_tbl
--  Document header ids.
--    PO_HEADERS_ALL.po_header_id
--    PO_RELEASES_ALL.po_release_id
--    PO_REQUISITION_HEADERS_ALL.requisition_header_id
--p_doc_type_tbl
--  Document type corresponding to the IDs.
--    PO_ACTION_HISTORY.object_type_code
--p_action_code
--  The action with which to fill in the NULL entry.
--    PO_ACTION_HISTORY.action_code
--p_employee_id
--  The HR employee_id with which to record the action.
--  This id should correspond to PER_ALL_PEOPLE_F.person_id.
--  If NULL is passed, the employee_id will be retrieved
--  that corresponds to the current FND user (FND_USER.employee_id).
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_action_history(
   p_doc_id_tbl                     IN             po_tbl_number
,  p_doc_type_tbl                   IN             po_tbl_varchar30
,  p_action_code                    IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
      DEFAULT NULL
)
IS

l_proc_name             CONSTANT VARCHAR2(30) := 'UPDATE_ACTION_HISTORY';
l_log_head              CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress              VARCHAR2(3) := '000';

l_user_id               NUMBER;
l_login_id              NUMBER;
l_employee_id           NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_id_tbl',p_doc_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type_tbl',p_doc_type_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action_code',p_action_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Do some high-level parameter validation.

IF (p_doc_id_tbl.COUNT <> p_doc_type_tbl.COUNT) THEN
   l_progress := '020';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '100';

-- Initialize vars.

l_employee_id := p_employee_id;

l_progress := '110';

initialize_vars(
   x_employee_id  => l_employee_id
,  x_user_id      => l_user_id
,  x_login_id     => l_login_id
);

l_progress := '200';

-- We've got all the data we need, so update the table.

FORALL i IN 1 .. p_doc_id_tbl.COUNT
UPDATE PO_ACTION_HISTORY POAH
SET
   POAH.last_update_date = SYSDATE
,  POAH.last_updated_by = l_user_id
,  POAH.action_code = p_action_code
,  POAH.action_date = SYSDATE
,  POAH.employee_id = NVL(l_employee_id, POAH.employee_id)
,  POAH.note = NULL
,  POAH.offline_code =
      DECODE(  POAH.offline_code
            ,  'PRINTED', 'PRINTED'
            , NULL
            )
,  POAH.last_update_login = l_login_id
WHERE POAH.object_id = p_doc_id_tbl(i)
AND   POAH.object_type_code = p_doc_type_tbl(i)
AND   POAH.action_code IS NULL
AND   POAH.employee_id = l_employee_id
;

l_progress := '300';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'SQL%ROWCOUNT',SQL%ROWCOUNT);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   PO_MESSAGE_S.sql_error(g_pkg_name,l_proc_name,l_progress,SQLCODE,SQLERRM);
   RAISE;

END update_action_history;

-------------------------------------------------------------------------------
--Start of Comments
--Since: 2014-FEB-20 added for bug 16702968
--Name: insert_action_history (single)
--Pre-reqs:
--  None.
--Modifies:
--  PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  Creates the specified action history entry.
--Parameters:
--IN:
--p_doc_id
--  Document header ids.
--    PO_HEADERS_ALL.po_header_id
--    PO_RELEASES_ALL.po_release_id
--    PO_REQUISITION_HEADERS_ALL.requisition_header_id
--p_doc_type
--  Document type corresponding to the IDs.
--    PO_ACTION_HISTORY.object_type_code
--p_doc_subtype
--  Document subtype.
--    PO_HEADERS_ALL.type_lookup_code
--    PO_RELEASES_ALL.release_type
--    PO_REQUISITION_HEADERS_ALL.type_lookup_code
--p_doc_revision_num
--  The revision number of the document.
--    PO_HEADERS_ALL.revision_num
--    PO_RELEASES_ALL.revision_num
--    These are NULL for Reqs.
--p_action_code
--  The actions to record.
--    PO_ACTION_HISTORY.action_code
--  The ordering of these actions are important for the
--    sequence_num of the action history entry.
--    SUBMIT should come before the other action.
--p_note
--  The note that goes along with this operation. E.g., user's response to a notification
--p_employee_id
--  The HR employee_id with which to record the action.
--  This id should correspond to PER_ALL_PEOPLE_F.person_id.
--  If NULL is passed, the employee_id will be retrieved
--  that corresponds to the current FND user (FND_USER.employee_id).
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE insert_action_history(
    p_doc_id            IN po_action_history.object_id%type,
    p_doc_type          IN po_action_history.object_type_code%type,
    p_doc_subtype       IN po_action_history.object_sub_type_code%type,
    p_doc_revision_num  IN po_action_history.object_revision_num%type,
    p_action_code       IN po_action_history.action_code%type,
    p_note              IN po_action_history.note%type default null,
    p_employee_id       IN number default null
)
IS
    l_proc_name CONSTANT VARCHAR2(30) := 'INSERT_ACTION_HISTORY';
    l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
    l_progress  VARCHAR2(3) := '000';

    l_user_id       NUMBER;
    l_login_id      NUMBER;
    l_employee_id   NUMBER;
BEGIN

    IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(l_log_head);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_id', p_doc_id);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_type', p_doc_type);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_subtype', p_doc_subtype);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_revision_num', p_doc_revision_num);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_action_code', p_action_code);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_note', p_note);
        PO_DEBUG.debug_var(l_log_head, l_progress, 'p_employee_id', p_employee_id);
    END IF;

    l_progress := '010';


    -- Initialize vars.

    l_employee_id := p_employee_id;

    l_progress := '020';

    initialize_vars(
        x_employee_id  => l_employee_id,
        x_user_id      => l_user_id,
        x_login_id     => l_login_id);

    l_progress := '030';

    -- Create the entries.
    --
    -- The SELECT is used to retrieve the sequence_num.
    -- The NVL, MAX are arranged to return a row with 0 as the sequence_num
    -- when no entries exist for the doc.

    insert into po_action_history
    (   object_id,
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
        object_revision_num,
        last_update_login,
        program_update_date,
        note
    )
    select
        p_doc_id,
        p_doc_type,
        p_doc_subtype,
        nvl(max(poah.sequence_num),0) + 1,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        p_action_code,
        sysdate,
        l_employee_id,
        p_doc_revision_num,
        l_login_id,
        sysdate,
        p_note
    from po_action_history poah
   where poah.object_id = p_doc_id
     and poah.object_type_code = p_doc_type;

    l_progress := '040';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head, l_progress, 'SQL%ROWCOUNT', SQL%ROWCOUNT);
        PO_DEBUG.debug_end(l_log_head);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
        RAISE;
END insert_action_history;


-------------------------------------------------------------------------------
--Start of Comments
--Name: insert_action_history
--Pre-reqs:
--  None.
--Modifies:
--  PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  Creates the specified action history entries.
--Parameters:
--IN:
--p_doc_id_tbl
--  Document header ids.
--    PO_HEADERS_ALL.po_header_id
--    PO_RELEASES_ALL.po_release_id
--    PO_REQUISITION_HEADERS_ALL.requisition_header_id
--p_doc_type_tbl
--  Document type corresponding to the IDs.
--    PO_ACTION_HISTORY.object_type_code
--p_doc_subtype_tbl
--  Document subtype.
--    PO_HEADERS_ALL.type_lookup_code
--    PO_RELEASES_ALL.release_type
--    PO_REQUISITION_HEADERS_ALL.type_lookup_code
--p_doc_revision_num_tbl
--  The revision number of the document.
--    PO_HEADERS_ALL.revision_num
--    PO_RELEASES_ALL.revision_num
--    These are NULL for Reqs.
--p_action_code_tbl
--  The actions to record.
--    PO_ACTION_HISTORY.action_code
--  The ordering of these actions are important for the
--    sequence_num of the action history entry.
--    SUBMIT should come before the other action.
--p_employee_id
--  The HR employee_id with which to record the action.
--  This id should correspond to PER_ALL_PEOPLE_F.person_id.
--  If NULL is passed, the employee_id will be retrieved
--  that corresponds to the current FND user (FND_USER.employee_id).
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE insert_action_history(
   p_doc_id_tbl                     IN             po_tbl_number
,  p_doc_type_tbl                   IN             po_tbl_varchar30
,  p_doc_subtype_tbl                IN             po_tbl_varchar30
,  p_doc_revision_num_tbl           IN             po_tbl_number
,  p_action_code_tbl                IN             po_tbl_varchar30
,  p_employee_id                    IN             NUMBER
      DEFAULT NULL
)
IS

l_proc_name             CONSTANT VARCHAR2(30) := 'INSERT_ACTION_HISTORY';
l_log_head              CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress              VARCHAR2(3) := '000';

l_user_id               NUMBER;
l_login_id              NUMBER;
l_employee_id           NUMBER;

l_count                 NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_id_tbl',p_doc_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type_tbl',p_doc_type_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype_tbl',p_doc_subtype_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_revision_num_tbl',p_doc_revision_num_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action_code_tbl',p_action_code_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Do some high-level parameter validation.

l_count := p_doc_id_tbl.COUNT;

l_progress := '020';

IF (  l_count <> p_doc_type_tbl.COUNT
   OR l_count <> p_doc_subtype_tbl.COUNT
   OR l_count <> p_doc_revision_num_tbl.COUNT
   OR l_count <> p_action_code_tbl.COUNT
) THEN
   l_progress := '030';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '100';

-- Initialize vars.

l_employee_id := p_employee_id;

l_progress := '110';

initialize_vars(
   x_employee_id  => l_employee_id
,  x_user_id      => l_user_id
,  x_login_id     => l_login_id
);

l_progress := '200';

-- Create the entries.
--
-- The SELECT is used to retrieve the sequence_num.
-- The NVL, MAX are arranged to return a row with 0 as the sequence_num
-- when no entries exist for the doc.

FORALL i IN 1 .. p_doc_id_tbl.COUNT
INSERT INTO PO_ACTION_HISTORY
(  object_id
,  object_type_code
,  object_sub_type_code
,  sequence_num
,  last_update_date
,  last_updated_by
,  creation_date
,  created_by
,  action_code
,  action_date
,  employee_id
,  object_revision_num
,  last_update_login
,  program_update_date
)
SELECT
   p_doc_id_tbl(i)
,  p_doc_type_tbl(i)
,  p_doc_subtype_tbl(i)
,  NVL(MAX(POAH.sequence_num),0) + 1 --Bug 13370924
,  SYSDATE
,  l_user_id
,  SYSDATE
,  l_user_id
,  p_action_code_tbl(i)
,  SYSDATE
,  l_employee_id
,  p_doc_revision_num_tbl(i)
,  l_login_id
,  SYSDATE
FROM
   PO_ACTION_HISTORY POAH
WHERE POAH.object_id = p_doc_id_tbl(i)
AND   POAH.object_type_code = p_doc_type_tbl(i)
;

l_progress := '300';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'SQL%ROWCOUNT',SQL%ROWCOUNT);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   PO_MESSAGE_S.sql_error(g_pkg_name,l_proc_name,l_progress,SQLCODE,SQLERRM);
   RAISE;

END insert_action_history;




-------------------------------------------------------------------------------
--Start of Comments
--Name: initialize_vars
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the current FND user_id, login_id, and employee_id.
--Parameters:
--IN OUT:
--x_employee_id
--  If the input value is NULL, then this will be updated with
--  the employee_id corresponding to the current user.
--OUT:
--x_user_id
--  The current FND user.
--x_login_id
--  The current FND login ID.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE initialize_vars(
   x_employee_id                    IN OUT NOCOPY  NUMBER
,  x_user_id                        OUT    NOCOPY  NUMBER
,  x_login_id                       OUT    NOCOPY  NUMBER
)
IS

l_proc_name             CONSTANT VARCHAR2(30) := 'INITIALIZE_VARS';
l_log_head              CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_employee_id',x_employee_id);
END IF;

l_progress := '010';

x_user_id := FND_GLOBAL.USER_ID;
x_login_id := FND_GLOBAL.LOGIN_ID;

l_progress := '110';

-- If an employee_id was not provided, determine an appropriate id.

IF (x_employee_id IS NULL) THEN

   -- Get the employee id corresponding to the current user.

   BEGIN

      l_progress := '120';

      SELECT
         HR.employee_id
      INTO
         x_employee_id
      FROM
         FND_USER FND
      ,  HR_EMPLOYEES_CURRENT_V HR
      WHERE FND.user_id = x_user_id
      AND   FND.employee_id = HR.employee_id
      ;

      l_progress := '130';

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_progress := '140';

      IF g_debug_unexp THEN
         PO_DEBUG.debug_unexp(l_log_head,l_progress,'Employee id not found.');
      END IF;

      -- If we can't find an employee_id,
      -- then we'll keep the old employee_id,
      -- so keep x_employee_id as NULL to enable an NVL().
      x_employee_id := NULL;

      l_progress := '150';

   END;

END IF;
-- If an employee id was provided, we don't change it.

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_employee_id',x_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_user_id',x_user_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_login_id',x_login_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   PO_MESSAGE_S.sql_error(g_pkg_name,l_proc_name,l_progress,SQLCODE,SQLERRM);

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_employee_id',x_employee_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_user_id',x_user_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_login_id',x_login_id);
   END IF;

   RAISE;

END initialize_vars;




END PO_ACTION_HISTORY_SV;

/
