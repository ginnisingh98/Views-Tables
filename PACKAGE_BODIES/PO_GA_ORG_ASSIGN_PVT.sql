--------------------------------------------------------
--  DDL for Package Body PO_GA_ORG_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GA_ORG_ASSIGN_PVT" AS
/* $Header: POXPORGB.pls 120.3 2005/09/21 00:45:23 arudas noship $ */

--< Shared Proc FPJ Start >
-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_GA_ORG_ASSIGN_PVT';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';
--< Shared Proc FPJ End >

--------------------------------------------------------------------------------
--Start of Comments
--Name: insert_row
--Pre-reqs:
--  None.
--Modifies:
--  PO_GA_ORG_ASSIGNMENTS.
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Inserts the record p_org_assign_rec into PO_GA_ORG_ASSIGNMENTS.  Shows
--  message PO_GA_ORG_ASSIGN_DUPLICATE on error.
--Parameters:
--IN:
--p_init_msg_list
--  Standard API parameter to initialize the API message list.
--p_org_assign_rec
--  Record of the entire row of PO_GA_ORG_ASSIGNMENTS table.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - on success
--  FND_API.g_ret_sts_error - if duplicate row is inserted
--  FND_API.g_ret_sts_unexp_error - unexpected error
--x_row_id
--  The rowid of the record inserted into the table.
--Testing:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insert_row
(    p_init_msg_list    IN  VARCHAR2,                      --< Shared Proc FPJ >
     x_return_status    OUT NOCOPY VARCHAR2,               --< Shared Proc FPJ >
     p_org_assign_rec   IN  PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
     x_row_id           OUT NOCOPY     ROWID
)
IS
  l_org_assignment_id PO_GA_ORG_ASSIGNMENTS.ORG_ASSIGNMENT_ID%TYPE; --<HTML Agreement R12>
BEGIN
    --< Shared Proc FPJ Start >
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization
    --< Shared Proc FPJ End >

    --<HTML Agreement R12 Start>
    -- SQL What:retrieve the value of org_assignment_id
    -- SQL Why: to insert into po_ga_org_assignments
    SELECT  PO_GA_ORG_ASSIGNMENTS_S.nextval
    INTO    l_org_assignment_id
    FROM    dual;
    --<HTML Agreement R12 End>

    INSERT INTO po_ga_org_assignments
    (   org_assignment_id   , --<HTML Agreement R12>
        po_header_id        ,
        organization_id     ,
        enabled_flag        ,
        vendor_site_id      ,
        last_update_date    ,
        last_updated_by     ,
        creation_date       ,
        created_by          ,
        last_update_login   ,
        purchasing_org_id   )                  --< Shared Proc FPJ >
    VALUES
    (   l_org_assignment_id                 , --<HTML Agreement R12>
        p_org_assign_rec.po_header_id       ,
        p_org_assign_rec.organization_id    ,
        p_org_assign_rec.enabled_flag       ,
        p_org_assign_rec.vendor_site_id     ,
        p_org_assign_rec.last_update_date   ,
        p_org_assign_rec.last_updated_by    ,
        p_org_assign_rec.creation_date      ,
        p_org_assign_rec.created_by         ,
        p_org_assign_rec.last_update_login  ,
        p_org_assign_rec.purchasing_org_id  )  --< Shared Proc FPJ >
    RETURNING
        rowid
    INTO
        x_row_id;

EXCEPTION
    --< Shared Proc FPJ Start >
    WHEN DUP_VAL_ON_INDEX THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_GA_ORG_ASSIGN_DUPLICATE');
        FND_MSG_PUB.add;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'insert_row');
    --< Shared Proc FPJ End >
END insert_row;

--< Shared Proc FPJ Start >  Rewrote update_row procedure
--------------------------------------------------------------------------------
--Start of Comments
--Name: update_row
--Pre-reqs:
--  None.
--Modifies:
--  PO_GA_ORG_ASSIGNMENTS
--  FND_MSG_PUB on error.
--Locks:
--  PO_GA_ORG_ASSIGNMENTS
--Function:
--  Updates the PO_GA_ORG_ASSIGNMENTS row with rowid p_row_id. Only the
--  following columns are updated:
--      organization_id
--      purchasing_org_id
--      enabled_flag
--      vendor_site_id
--      last_update_date
--      last_updated_by
--      last_update_login
--  Shows message PO_GA_ORG_ASSIGN_DUPLICATE on duplicate rows error.
--Parameters:
--IN:
--p_init_msg_list
--  Standard API parameter to initialize the API message list.
--p_org_assign_rec
--  Record of the entire row of PO_GA_ORG_ASSIGNMENTS table.
--p_row_id
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - on success
--  FND_API.g_ret_sts_error - if update causes duplicate rows
--  FND_API.g_ret_sts_unexp_error - unexpected error
--Testing:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_row
(   p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    p_org_assign_rec    IN  PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
    p_row_id            IN  ROWID
)
IS

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    UPDATE po_ga_org_assignments
       SET organization_id   = p_org_assign_rec.organization_id,
           purchasing_org_id = p_org_assign_rec.purchasing_org_id,
           enabled_flag      = p_org_assign_rec.enabled_flag,
           vendor_site_id    = p_org_assign_rec.vendor_site_id,
           last_update_date  = p_org_assign_rec.last_update_date,
           last_updated_by   = p_org_assign_rec.last_updated_by,
           last_update_login = p_org_assign_rec.last_update_login
     WHERE rowid = p_row_id;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_GA_ORG_ASSIGN_DUPLICATE');
        FND_MSG_PUB.add;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'update_row');
END update_row;
--< Shared Proc FPJ End >

/*==============================================================================

    PROCEDURE:      delete_row

    DESCRIPTION:    Deletes a row from PO_GA_ORG_ASSIGNMENTS.

==============================================================================*/
PROCEDURE delete_row
(
    p_po_header_id      IN      PO_GA_ORG_ASSIGNMENTS.po_header_id%TYPE
)
IS
BEGIN

    DELETE FROM po_ga_org_assignments
    WHERE       po_header_id = p_po_header_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('delete_row','000',SQLCODE);
        RAISE;

END delete_row;


--< Shared Proc FPJ Start >
--------------------------------------------------------------------------------
--Start of Comments
--Name: delete_row
--Pre-reqs:
--  None.
--Modifies:
--  PO_GA_ORG_ASSIGNMENTS.
--Locks:
--  PO_GA_ORG_ASSIGNMENTS
--Function:
--  Deletes the row in PO_GA_ORG_ASSIGNMENTS with p_po_header_id and
--  p_organization_id. Uses APP_EXCEPTION.raise_exception when error occurs.
--Parameters:
--IN:
--p_po_header_id
--p_organization_id
--Testing:
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE delete_row
(   p_po_header_id    IN NUMBER,
    p_organization_id IN NUMBER
)
IS
BEGIN

    DELETE FROM po_ga_org_assignments
     WHERE po_header_id = p_po_header_id
       AND organization_id = p_organization_id;

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error(routine    => 'PO_GA_ORG_ASSIGN_PVT.delete_row',
                               location   => '200',
                               error_code => SQLCODE);
        APP_EXCEPTION.raise_exception;
END delete_row;


--Rewrote lock_row procedure
--------------------------------------------------------------------------------
--Start of Comments
--Name: lock_row
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  PO_GA_ORG_ASSIGNMENTS
--Function:
--  Locks the row in PO_GA_ORG_ASSIGNMENTS with rowid p_row_id.  If the DB lock
--  cannot be acquired, then standard FND record lock exception handling is
--  used. The following columns are compared with the database values:
--      organization_id
--      purchasing_org_id
--      vendor_site_id
--      enabled_flag
--  If any of these are different than the database value, the procedure will
--  error out after setting the FND message FORM_RECORD_CHANGED. If the matching
--  record in the database cannot be found, the FND message FORM_RECORD_DELETED
--  is set.  Uses APP_EXCEPTION.raise_exception when errors occur.
--Parameters:
--IN:
--p_org_assign_rec
--p_row_id
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE lock_row
(   p_org_assign_rec IN PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
    p_row_id         IN ROWID
)
IS
    l_pgoa_rec PO_GA_ORG_ASSIGNMENTS%ROWTYPE;
BEGIN

    --SQL What: Lock the record with rowid p_row_id.
    --SQL Why: Obtain the lock and compare values to see if there's a difference
    SELECT *
      INTO l_pgoa_rec
      FROM po_ga_org_assignments
     WHERE rowid = p_row_id
       FOR UPDATE NOWAIT;

    IF (l_pgoa_rec.organization_id <> p_org_assign_rec.organization_id) OR
       (l_pgoa_rec.purchasing_org_id <> p_org_assign_rec.purchasing_org_id) OR
       (l_pgoa_rec.vendor_site_id <> p_org_assign_rec.vendor_site_id) OR
       (l_pgoa_rec.enabled_flag <> p_org_assign_rec.enabled_flag)
    THEN
        RAISE FND_API.g_exc_error;
    END IF;

EXCEPTION
    WHEN APP_EXCEPTION.record_lock_exception THEN
        -- The record could not be locked, so raise it to calling procedure
        RAISE APP_EXCEPTION.record_lock_exception;
    WHEN NO_DATA_FOUND THEN
        -- Could not find the record
        FND_MESSAGE.set_name(application => 'FND',
                             name => 'FORM_RECORD_DELETED');
        APP_EXCEPTION.raise_exception;
    WHEN FND_API.g_exc_error THEN
        -- The individual value comparisons failed
        FND_MESSAGE.set_name(application => 'FND',
                             name => 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.raise_exception;
    WHEN OTHERS THEN
        FND_MSG_PUB.build_exc_msg
            (p_pkg_name       => g_pkg_name,
             p_procedure_name => 'lock_row',
             p_error_text     => NULL);
        APP_EXCEPTION.raise_exception;
END lock_row;

--------------------------------------------------------------------------------
--Start of Comments
--Name: copy_rows
--Pre-reqs:
--  None.
--Modifies:
--  PO_GA_ORG_ASSIGNMENTS
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Copy all the org assignments of p_from_po_header_id to new org assignments
--  for p_to_po_header_id. The WHO columns are not copied over; they are updated
--  with the input parameters.
--Parameters:
--IN:
--p_init_msg_list
--  Standard param initializes API message list if FND_API.g_true;
--p_from_po_header_id
--  The header ID of the original GA whose org assignments will be copied.
--p_to_po_header_id
--  The header ID of the new GA for the new org assignments.
--p_last_update_date
--p_last_updated_by
--p_creation_date
--p_created_by
--p_last_update_login
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - success.
--  FND_API.g_ret_sts_error - duplicate rows inserted. Appends message
--      PO_GA_ORG_ASSIGN_DUPLICATE.
--  FND_API.g_ret_sts_unexp_error - Unexpected error occurred, or no rows were
--      inserted. Appends unexpected error message.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE copy_rows
(
    p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    p_from_po_header_id IN  NUMBER,
    p_to_po_header_id   IN  NUMBER,
    p_last_update_date  IN  DATE,
    p_last_updated_by   IN  NUMBER,
    p_creation_date     IN  DATE,
    p_created_by        IN  NUMBER,
    p_last_update_login IN  NUMBER
)
IS
BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    --<Bug4623941 Start>
    -- Used PO_GA_ORG_ASSIGNMENTS_S.nextval directly inside insert statement
    --<Bug4623941 End>

    INSERT INTO PO_GA_ORG_ASSIGNMENTS
    (
           org_assignment_id, --<HTML Agreement R12>
           po_header_id,
           organization_id,
           enabled_flag,
           vendor_site_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           purchasing_org_id
    )
    SELECT PO_GA_ORG_ASSIGNMENTS_S.nextval     ,--Bug#4623941
           p_to_po_header_id,
           pgoa.organization_id,
           pgoa.enabled_flag,
           pgoa.vendor_site_id,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_created_by,
           p_last_update_login,
           pgoa.purchasing_org_id
      FROM po_ga_org_assignments pgoa
     WHERE pgoa.po_header_id = p_from_po_header_id;

    IF (SQL%ROWCOUNT = 0) THEN
        -- Return error if nothing was inserted
        RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name(application => 'PO',
                             name        => 'PO_GA_ORG_ASSIGN_DUPLICATE');
        FND_MSG_PUB.add;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'copy_rows',
                                p_error_text     => NULL);
END copy_rows;

--< Shared Proc FPJ End >

END PO_GA_ORG_ASSIGN_PVT;

/
