--------------------------------------------------------
--  DDL for Package Body PO_REQIMP_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQIMP_VAL_PVT" AS
/* $Header: POXVRIVB.pls 115.3 2004/01/07 18:17:42 jskim ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_REQIMP_VAL_PVT';
l_bulk_limit CONSTANT NUMBER := 1000; -- bulk collect limit - number of rows

/**
* Private Procedure: val_pjm_proj_references
* Requires: none
* Modifies: PO_INTERFACE_ERRORS, concurrent program log
* Parameters:
*  p_interface_table_code - the interface table to be validated;
*    if PO_REQIMP_VAL_PVT.G_PO_REQUISITIONS_INTERFACE,
       use PO_REQUISITIONS_INTERFACE
*    if PO_REQIMP_VAL_PVT.G_PO_REQ_DIST_INTERFACE,
       use PO_REQ_DIST_INTERFACE
* Effects: For all records with the given request ID in the specified
*  interface table, calls the PJM validation API to validate
*  project and task information. Writes any validation errors to
*  PO_INTERFACE_ERRORS and any validation warnings to the concurrent
*  program log.
* Returns:
*  x_return_status -
*    FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurs
*    FND_API.G_RET_STS_SUCCESS otherwise
*/
PROCEDURE val_pjm_proj_references (
    p_api_version IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    p_interface_table_code IN VARCHAR2,
    p_request_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_prog_application_id IN NUMBER,
    p_program_id IN NUMBER
) IS
  l_api_name CONSTANT VARCHAR2(30) := 'VAL_PJM_PROJ_REFERENCES';
  l_api_version CONSTANT NUMBER := 1.0;

  TYPE project_info_cv_type IS REF CURSOR;
  project_info_cv project_info_cv_type;
  l_interface_table_name VARCHAR2(80);

  TYPE l_number_tbl_type IS TABLE of NUMBER;
  TYPE l_date_tbl_type IS TABLE of DATE;
  l_project_id_tbl          l_number_tbl_type;
  l_task_id_tbl             l_number_tbl_type;
  l_destination_org_id_tbl  l_number_tbl_type;
  l_need_by_date_tbl        l_date_tbl_type;
  l_transaction_id_tbl      l_number_tbl_type;
  l_destination_ou_id_tbl   l_number_tbl_type;

  TYPE l_errors_tbl_type IS TABLE of
    PO_INTERFACE_ERRORS.error_message%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE l_err_transaction_id_tbl_type IS TABLE of
    PO_INTERFACE_ERRORS.interface_transaction_id%TYPE
    INDEX BY BINARY_INTEGER;
  l_errors_tbl              l_errors_tbl_type;
  l_err_transaction_id_tbl  l_err_transaction_id_tbl_type;
  l_errorI                  NUMBER := 1;

  l_val_proj_result     VARCHAR(1);
  l_val_proj_error_code VARCHAR2(80);

BEGIN
  IF NOT FND_API.compatible_api_call(l_api_version,p_api_version,
         l_api_name, G_PKG_NAME ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  x_return_status := FND_API.g_ret_sts_success;

  IF (p_interface_table_code =
      PO_REQIMP_VAL_PVT.G_PO_REQUISITIONS_INTERFACE) THEN
    l_interface_table_name := 'PO_REQUISITIONS_INTERFACE';

    OPEN project_info_cv FOR
      --< Bug 3265539 Start >
      -- Need to derive the OU of the dest inventory org as well.
      --
      -- SQL What: Retrieve project-related information from
      --   PO_REQUISITIONS_INTERFACE.
      -- SQL Why: To validate project information using the PJM API.
      SELECT pri.project_id,
             pri.task_id,
             pri.destination_organization_id,
             pri.need_by_date,
             pri.transaction_id,
             TO_NUMBER(hoi.org_information3)
      FROM po_requisitions_interface pri,
           hr_organization_information hoi
      WHERE pri.project_accounting_context = 'Y'
      AND pri.request_id = p_request_id
      -- Bug 3043971 We should only perform PJM validation on Inventory and
      -- Shop Floor lines (i.e. not Expense):
      AND NVL(pri.destination_type_code, 'EXPENSE') IN ('INVENTORY', 'SHOP FLOOR')
      AND pri.destination_organization_id = hoi.organization_id
      AND hoi.org_information_context = 'Accounting Information';
      --< Bug 3265539 End >

  ELSIF (p_interface_table_code =
         PO_REQIMP_VAL_PVT.G_PO_REQ_DIST_INTERFACE) THEN
    l_interface_table_name := 'PO_REQ_DIST_INTERFACE';

    OPEN project_info_cv FOR
      --< Bug 3265539 Start >
      -- Need to derive the OU of the dest inventory org as well.
      --
      -- SQL What: Retrieve project-related information from
      --   PO_REQUISITIONS_INTERFACE and PO_REQ_DIST_INTERFACE.
      -- SQL Why: To validate project information using the PJM API.
      -- SQL Join: po_req_dist_interface.dist_sequence_id =
      --   po_requisitions_interface.req_dist_sequence_id
      SELECT d.project_id,
             d.task_id,
             d.destination_organization_id,
             r.need_by_date,
             d.transaction_id,
             TO_NUMBER(hoi.org_information3)
      FROM po_req_dist_interface d,
           po_requisitions_interface r,
           hr_organization_information hoi
      WHERE d.project_accounting_context = 'Y'
      AND d.request_id = p_request_id
      AND d.dist_sequence_id = r.req_dist_sequence_id
      -- Bug 3043971 We should only perform PJM validation on Inventory and
      -- Shop Floor lines (i.e. not Expense):
      AND NVL(d.destination_type_code, 'EXPENSE') IN ('INVENTORY', 'SHOP FLOOR')
      AND d.destination_organization_id = hoi.organization_id
      AND hoi.org_information_context = 'Accounting Information';
      --< Bug 3265539 End >

  ELSE
    FND_MSG_PUB.build_exc_msg(G_PKG_NAME,l_api_name,
      'Invalid value for p_interface_table_code: ' || p_interface_table_code);
    RAISE FND_API.g_exc_unexpected_error;
  END IF; -- p_interface_table_code

  -- Bulk collect the project information into PL/SQL tables,
  -- l_bulk_limit records at a time, and perform validation.
  LOOP

    FETCH project_info_cv BULK COLLECT
      INTO l_project_id_tbl, l_task_id_tbl, l_destination_org_id_tbl,
           l_need_by_date_tbl, l_transaction_id_tbl,
           l_destination_ou_id_tbl          --< Bug 3265539 >
      LIMIT l_bulk_limit;

    EXIT WHEN
      l_project_id_tbl.COUNT = 0; -- no records fetched in this iteration

    -- Validate each record in our PL/SQL tables
    FOR i IN l_project_id_tbl.FIRST..l_project_id_tbl.LAST LOOP
      --< Bug 3265539 Start >
      -- Call PO wrapper procedure to validate the PJM project
      PO_PROJECT_DETAILS_SV.validate_proj_references_wpr
          (p_inventory_org_id => l_destination_org_id_tbl(i),
           p_operating_unit   => l_destination_ou_id_tbl(i),
           p_project_id       => l_project_id_tbl(i),
           p_task_id          => l_task_id_tbl(i),
           p_date1            => l_need_by_date_tbl(i),
           p_date2            => NULL,
           p_calling_function => 'REQIMPORT',
           x_error_code       => l_val_proj_error_code,
           x_return_code      => l_val_proj_result);

      IF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_failure) THEN
        -- Add the error and the current transaction ID to PL/SQL tables
        l_errors_tbl(l_errorI) := fnd_message.get;
        l_err_transaction_id_tbl(l_errorI) := l_transaction_id_tbl(i);
        l_errorI := l_errorI + 1;
      ELSIF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_warning) THEN
        -- Write the warning to the concurrent program log
        FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.get);
      END IF;
      --< Bug 3265539 End >

    END LOOP; -- Validate each record...

    EXIT WHEN project_info_cv%NOTFOUND; -- all records have been fetched

  END LOOP; -- Bulk collect...

  CLOSE project_info_cv;

  IF (l_errors_tbl.COUNT = 0) THEN
    RETURN;
  END IF;

  -- Bulk insert all the errors into PO_INTERFACE_ERRORS
  FORALL i IN l_errors_tbl.FIRST..l_errors_tbl.LAST
    INSERT INTO po_interface_errors
      (interface_type,interface_transaction_id,column_name,
       error_message,
       creation_date,created_by,last_update_date,last_updated_by,
       last_update_login,request_id,program_application_id,program_id,
       program_update_date, table_name)
    VALUES
      ('REQIMPORT',l_err_transaction_id_tbl(i),'PROJECT ACCOUNTING COLUMNS',
       l_errors_tbl(i),
       SYSDATE,p_user_id,SYSDATE,p_user_id,
       p_login_id,p_request_id,p_prog_application_id,
       p_program_id,SYSDATE,l_interface_table_name);

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF project_info_cv%ISOPEN THEN
      CLOSE project_info_cv;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name);
    END IF;
    IF project_info_cv%ISOPEN THEN
      CLOSE project_info_cv;
    END IF;
END val_pjm_proj_references;

END PO_REQIMP_VAL_PVT;

/
