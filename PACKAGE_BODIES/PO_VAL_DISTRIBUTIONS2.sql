--------------------------------------------------------
--  DDL for Package Body PO_VAL_DISTRIBUTIONS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_DISTRIBUTIONS2" AS
  -- $Header: PO_VAL_DISTRIBUTIONS2.plb 120.14.12010000.18 2014/08/08 18:26:22 sbontala ship $
  c_entity_type_distribution CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_DISTRIBUTION;
  -- The module base for this package.
  d_package_base CONSTANT VARCHAR2(50) := po_log.get_package_base('PO_VAL_DISTRIBUTIONS2');

  -- The module base for the subprogram.
  d_amount_ordered CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT_ORDERED');
  d_quantity_ordered CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'QUANTITY_ORDERED');
  d_destination_org_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DESTINATION_ORG_ID');
  d_deliver_to_location_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DELIVER_TO_LOCATION_ID');
  d_deliver_to_person_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DELIVER_TO_PERSON_ID');
  d_destination_type_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DESTINATION_TYPE_CODE');
  d_destination_subinv CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DESTINATION_SUBINV');
  d_wip_entity_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'WIP_ENTITY_ID');
  d_prevent_encumberance_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PREVENT_ENCUMBERANCE_FLAG');
  d_gl_encumbered_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'GL_ENCUMBERED_DATE');
  d_charge_account_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CHARGE_ACCOUNT_ID');
  d_budget_account_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'BUDGET_ACCOUNT_ID');
  d_account_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ACCOUNT_ID');
  d_project_acct_context CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PROJECT_ACCT_CONTEXT');
  d_project_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PROJECT_INFO');
  d_tax_recovery_override_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'TAX_RECOVERY_OVERRIDE_FLAG');

  -- <PDOI Enhancement Bug#17063664>
  d_oke_contract_line_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'OKE_CONTRACT_LINE_ID');
  d_oke_contract_del_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'OKE_CONTRACT_DEL_ID');
  -- Indicates that the calling program is PDOI.
  c_program_pdoi CONSTANT VARCHAR2(10) := 'PDOI';
  -- The application name of PO.
  c_po CONSTANT VARCHAR2(2) := 'PO';

-----------------------------------------------------------
-- Validation Logic:
--   If order_type_lookup_code is RATE or FIXED PRICE,
--  Quantity_ordered must be null or 0.
--  If order_type_code is other than RATE or FIXED PRICE,
--  Quantity_ordered must not be null and be greater than 0
-----------------------------------------------------------
  PROCEDURE amount_ordered(
    p_id_tbl                IN              po_tbl_number,
    p_amount_ordered_tbl    IN              po_tbl_number,
    p_order_type_code_tbl   IN              po_tbl_varchar30,
    p_distribution_type_tbl IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    x_results               IN OUT NOCOPY   po_validation_results_type,
    x_result_type           OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_amount_ordered;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_amount_ordered_tbl', p_amount_ordered_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_code_tbl', p_order_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_distribution_type_tbl', p_distribution_type_tbl); -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF Nvl(p_distribution_type_tbl(i),'STANDARD') <> 'PREPAYMENT' THEN  -- PDOI for Complex PO Project
        IF (p_order_type_code_tbl(i) IN('RATE', 'FIXED PRICE')) THEN
          IF (NVL(p_amount_ordered_tbl(i), 0) <= 0) THEN
            x_results.add_result(p_entity_type      => c_entity_type_distribution,
                                p_entity_id        => p_id_tbl(i),
                                p_column_name      => 'AMOUNT_ORDERED',
                                p_column_val       => p_amount_ordered_tbl(i),
                                p_message_name     => 'PO_PDOI_SVC_MUST_AMT');
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        ELSE
          IF (NVL(p_amount_ordered_tbl(i), 0) <> 0) THEN
            x_results.add_result(p_entity_type      => c_entity_type_distribution,
                                p_entity_id        => p_id_tbl(i),
                                p_column_name      => 'AMOUNT_ORDERED',
                                p_column_val       => p_amount_ordered_tbl(i),
                                p_message_name     => 'PO_SVC_NO_AMT');
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END amount_ordered;

-----------------------------------------------------------
-- Validation Logic:
--   If order_type_lookup_code is RATE or FIXED PRICE,
--  Quantity_ordered must be null or 0.
--  If order_type_code is other than RATE or FIXED PRICE,
--  Quantity_ordered must not be null and be greater than 0
-----------------------------------------------------------
  PROCEDURE quantity_ordered(
    p_id_tbl                 IN              po_tbl_number,
    p_quantity_ordered_tbl   IN              po_tbl_number,
    p_order_type_code_tbl    IN              po_tbl_varchar30,
    p_distribution_type_tbl  IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    x_results                IN OUT NOCOPY   po_validation_results_type,
    x_result_type            OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_quantity_ordered;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_quantity_ordered_tbl', p_quantity_ordered_tbl);
      po_log.proc_begin(d_mod, 'p_order_type_code_tbl', p_order_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_distribution_type_tbl', p_distribution_type_tbl); -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF Nvl(p_distribution_type_tbl(i),'STANDARD') <> 'PREPAYMENT' THEN  -- PDOI for Complex PO Project
        IF (p_order_type_code_tbl(i) IN('RATE', 'FIXED PRICE')) THEN
          IF (NVL(p_quantity_ordered_tbl(i), 0) <> 0) THEN
            x_results.add_result(p_entity_type      => c_entity_type_distribution,
                                p_entity_id        => p_id_tbl(i),
                                p_column_name      => 'QUANTITY_ORDERED',
                                p_column_val       => p_quantity_ordered_tbl(i),
                                p_message_name     => 'PO_SVC_NO_QTY');
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        ELSE
          IF (NVL(p_quantity_ordered_tbl(i), 0) <= 0) THEN
            x_results.add_result(p_entity_type      => c_entity_type_distribution,
                                p_entity_id        => p_id_tbl(i),
                                p_column_name      => 'QUANTITY_ORDERED',
                                p_column_val       => p_quantity_ordered_tbl(i),
                                p_message_name     => 'PO_PDOI_INVALID_QTY');
            x_result_type := po_validations.c_result_type_failure;
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END quantity_ordered;

-----------------------------------------------------------
-- Validation Logic:
-- Should be the same as ship_to_organization_id.
-----------------------------------------------------------
  PROCEDURE destination_org_id(
    p_id_tbl               IN              po_tbl_number,
    p_dest_org_id_tbl      IN              po_tbl_number,
    p_ship_to_org_id_tbl   IN              po_tbl_number,
    x_results              IN OUT NOCOPY   po_validation_results_type,
    x_result_type          OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_destination_org_id;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_dest_org_id_tbl', p_dest_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (NVL(p_dest_org_id_tbl(i), -11) <> NVL(p_ship_to_org_id_tbl(i), -99)) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DESTINATION_ORG_ID',
                             p_column_val       => p_dest_org_id_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_DEST_ORG',
                             p_token1_name      => 'DESTINATION_ORGANIZATION',
                             p_token1_value     => p_dest_org_id_tbl(i));
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END destination_org_id;

-----------------------------------------------------------
-- Validation Logic:
--  If deliver_to_location_id is not null,
--  then validate against hr_locations based on ship_to_organization_id
-----------------------------------------------------------
  PROCEDURE deliver_to_location_id(
    p_id_tbl                       IN              po_tbl_number,
    p_deliver_to_location_id_tbl   IN              po_tbl_number,
    p_ship_to_org_id_tbl           IN              po_tbl_number,
    x_result_set_id                IN OUT NOCOPY   NUMBER,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_deliver_to_location_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_deliver_to_location_id_tbl', p_deliver_to_location_id_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_DEL_LOCATION',
               'DELIVER_TO_LOCATION_ID',
               p_deliver_to_location_id_tbl(i),
               'DELIVER_TO_LOCATION_ID',
               p_deliver_to_location_id_tbl(i)
          FROM DUAL
         WHERE p_deliver_to_location_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM hr_locations
                  WHERE NVL(inventory_organization_id, p_ship_to_org_id_tbl(i)) = p_ship_to_org_id_tbl(i)
                    AND NVL(inactive_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                    AND location_id = p_deliver_to_location_id_tbl(i))
           AND NOT EXISTS(
                 SELECT 1
                   FROM hz_locations
                  WHERE NVL(address_expiration_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                    AND location_id = p_deliver_to_location_id_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END deliver_to_location_id;

-----------------------------------------------------------
-- Validation Logic:
--  If deliver_to_person_id is not null, then validate against hr_employees_current_v
-----------------------------------------------------------
  PROCEDURE deliver_to_person_id(
    p_id_tbl                     IN              po_tbl_number,
    p_deliver_to_person_id_tbl   IN              po_tbl_number,
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_deliver_to_person_id;
    d_position NUMBER;

    l_fsp_business_group_id NUMBER := NULL;
    l_cwk_profile_value VARCHAR2(1) := NULL;
    l_assignment_type VARCHAR2(1) := NULL;

    l_index_tbl DBMS_SQL.number_table;
  BEGIN
    d_position := 0;

    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_deliver_to_person_id_tbl', p_deliver_to_person_id_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    d_position := 10;

    -- l_index_tbl is used to skip the validation if
    -- deliver_to_person_id is empty
    FOR i IN 1..p_id_tbl.COUNT LOOP
      IF (p_deliver_to_person_id_tbl(i) IS NOT NULL) THEN
        l_index_tbl(i) := i;
      END IF;
    END LOOP;

    SELECT FSP.BUSINESS_GROUP_ID
    INTO l_fsp_business_group_id
    FROM FINANCIALS_SYSTEM_PARAMETERS FSP;

    l_cwk_profile_value := nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N');
    IF (l_cwk_profile_value = 'Y') THEN
      l_assignment_type := 'C';
    ELSE
      l_assignment_type := 'E';
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_mod, d_position, 'l_fsp_business_group_id', l_fsp_business_group_id);
      PO_LOG.stmt(d_mod, d_position, 'l_assignment_type', l_assignment_type);
    END IF;

    d_position := 20;

    -- bug 5454379: add hint to use index PER_PEOPLE_F_PK
    --              which is more selective

--9034751 bug , Added decode condition to handle cross business group deliver to person id.
    FORALL i IN INDICES OF l_index_tbl
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_DEL_PERSON',
               'DELIVER_TO_PERSON_ID',
               p_deliver_to_person_id_tbl(i),
               'DELIVER_TO_PERSON',
               p_deliver_to_person_id_tbl(i)
          FROM DUAL
         WHERE NOT EXISTS(
                 SELECT
                        /*+ INDEX(P PER_PEOPLE_F_PK) */
                        1
                 FROM PER_PEOPLE_F P,
                      PER_ASSIGNMENTS_F A
                 WHERE P.person_id = p_deliver_to_person_id_tbl(i)
                 AND A.person_id = P.person_id
                 AND A.primary_flag = 'Y'
                 AND TRUNC(SYSDATE) BETWEEN P.effective_start_date AND P.effective_end_date
                 AND TRUNC(SYSDATE) BETWEEN A.effective_start_date AND A.effective_end_date
                 AND (NVL(current_employee_flag,'N') = 'Y'
                      OR NVL(current_npw_flag,'N') = 'Y')
                 AND Decode(hr_general.get_xbg_profile,'Y',p.business_group_id,
                                             l_fsp_business_group_id) = p.business_group_id
                 AND A.assignment_type IN ('E',l_assignment_type));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END deliver_to_person_id;

-----------------------------------------------------------
-- Validation Logic:
--   If not null, validate destination_type_code based on item_status,
--   accrue_on_receipt_flag, transaction_flow_header_id;
--
-- Validation Business Rules
-- item status
-- 'O'  =  outside processing item
--         - destination type must be SHOP FLOOR
-- 'E'  =  item stockable in the org
--         - destination type cannot be SHOP FLOOR
-- 'D'  =  item defined but not stockable in org
--         - destination type must be EXPENSE
-- null =  item not defined in org
--
-- accrue on receipt
-- 'N'     - destination type must be expense
-- 'Y'     - if expense_accrual = PERIOD END
--           then destination type code cannot be EXPENSE
-- Cannot be INVENTORY if item_id is null.
-- If SHIKYU item, then dest type code must be INVENTORY.
-----------------------------------------------------------
  PROCEDURE destination_type_code(
    p_id_tbl                       IN              po_tbl_number,
    p_dest_type_code_tbl           IN              po_tbl_varchar30,
    p_ship_to_org_id_tbl           IN              po_tbl_number,
    p_item_id_tbl                  IN              po_tbl_number,
    p_txn_flow_header_id_tbl       IN              po_tbl_number,
    p_accrue_on_receipt_flag_tbl   IN              po_tbl_varchar1,
    p_value_basis_tbl              IN              po_tbl_varchar30,
    p_purchase_basis_tbl		   IN              po_tbl_varchar30,   --bug 7644072
    p_expense_accrual_code         IN              po_system_parameters.expense_accrual_code%TYPE,
    p_loc_outsourced_assembly_tbl  IN              po_tbl_number,
    p_consigned_flag_tbl          IN po_tbl_varchar1,   --<<Bug#19379838 >>
    x_result_set_id                IN OUT NOCOPY   NUMBER,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS

    d_mod CONSTANT VARCHAR2(100) := d_destination_type_code;
    d_position NUMBER;

    -- key of temp table used to identify the derived result
    l_key                    po_session_gt.key%TYPE;
    l_num_list_tbl           DBMS_SQL.NUMBER_TABLE;

    -- tables to store the derived result
    l_index_tbl        PO_TBL_NUMBER;
    l_result_tbl       PO_TBL_VARCHAR1;
    l_item_status_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

  BEGIN

    d_position := 0;

    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    d_position := 10;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
      po_log.proc_begin(d_mod, 'p_txn_flow_header_id_tbl', p_txn_flow_header_id_tbl);
      po_log.proc_begin(d_mod, 'p_accrue_on_receipt_flag_tbl', p_accrue_on_receipt_flag_tbl);
      po_log.proc_begin(d_mod, 'p_expense_accrual_code', p_expense_accrual_code);
      po_log.proc_begin(d_mod, 'p_loc_outsourced_assembly_tbl', p_loc_outsourced_assembly_tbl);
       po_log.proc_begin(d_mod, 'p_consigned_flag_tbl', p_consigned_flag_tbl);--<<Bug#19379838 >>
      po_log.proc_begin(d_mod, 'p_value_basis_tbl', p_value_basis_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

     d_position := 20;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      -- If dest type code is INVENTORY, item_id must be NULL.
      IF (p_dest_type_code_tbl(i) = 'INVENTORY' AND p_item_id_tbl(i) IS NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DESTINATION_TYPE_CODE',
                             p_column_val       => p_dest_type_code_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_DEST_TYPE',
                             p_token1_name      => 'DESTINATION_TYPE',
                             p_token1_value     => p_dest_type_code_tbl(i));
        x_result_type := po_validations.c_result_type_failure;
      END IF;
      -- If SHIKYU item, destination type must be INVENTORY.
      IF (p_dest_type_code_tbl(i) <> 'INVENTORY' AND p_loc_outsourced_assembly_tbl(i) = 1) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DESTINATION_TYPE_CODE',
                             p_column_val       => p_dest_type_code_tbl(i),
                             p_message_name     => 'PO_PDOI_SHIKYU_DEST_TYPE');
        x_result_type := po_validations.c_result_type_failure;
      END IF;

       --<<Bug 19379838 Consigned shipments should have destination type as inventory>>--
       IF (p_dest_type_code_tbl(i) <> 'INVENTORY' AND p_consigned_flag_tbl(i) = 'Y') THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DESTINATION_TYPE_CODE',
                             p_column_val       => p_dest_type_code_tbl(i),
                             p_message_name     => 'PO_PDOI_CONS_DEST_TYPE');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    d_position := 30;

    -- assign a new key used in temporary table
    l_key := PO_CORE_S.get_session_gt_nextval;

    -- initialize table containing the row number
    PO_PDOI_UTL.generate_ordered_num_list
    (
      p_size     => p_id_tbl.COUNT,
      x_num_list => l_num_list_tbl
    );

    d_position := 40;

    FORALL i IN 1..l_num_list_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, char1)
      SELECT l_key,
             l_num_list_tbl(i),
             decode(msi.outside_operation_flag,'Y','O', decode(msi.stock_enabled_flag,'Y','E','D'))
      FROM  mtl_system_items msi
      WHERE p_dest_type_code_tbl(i) IS NOT NULL
        AND msi.organization_id = p_ship_to_org_id_tbl(i)
        AND msi.inventory_item_id = p_item_id_tbl(i);

    d_position := 50;

    DELETE FROM po_session_gt
    WHERE key = l_key
    RETURNING num1, char1
    BULK COLLECT INTO l_index_tbl, l_result_tbl;

    d_position := 60;

    l_item_status_tbl.extend(p_id_tbl.COUNT);

    FOR i IN 1..l_index_tbl.COUNT
    LOOP
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_mod, d_position, 'index', l_index_tbl(i));
        PO_LOG.stmt(d_mod, d_position, 'new item_status', l_result_tbl(i));
      END IF;

      l_item_status_tbl(l_index_tbl(i)) := l_result_tbl(i);
    END LOOP;

    -- For entries without item_id, defautl item_status to 'D'
    FOR i IN 1..p_id_tbl.COUNT LOOP
      IF (p_item_id_tbl(i) IS NULL) THEN
        l_item_status_tbl(i) := 'D';
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'l_item_status_tbl', l_item_status_tbl);
    END IF;

    d_position := 70;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_DEST_TYPE',
               'DESTINATION_TYPE_CODE',
               p_dest_type_code_tbl(i),
               'DESTINATION_TYPE',
               p_dest_type_code_tbl(i)
          FROM DUAL
         WHERE p_dest_type_code_tbl(i) IS NOT NULL
           AND NOT EXISTS(SELECT 1
                          FROM po_lookup_codes
                          WHERE lookup_type = 'DESTINATION TYPE'
                            AND ((nvl(l_item_status_tbl(i),'D') = 'D'
                                      /* AND lookup_code = 'EXPENSE') commented and added below 7644072*/
                                      AND lookup_code <> 'INVENTORY')   -- bug 7644072
                                 OR (nvl(l_item_status_tbl(i),'D') = 'E'
                                     AND lookup_code <> 'SHOP FLOOR')
                                 OR (nvl(l_item_status_tbl(i),'D') = 'O'
                                     AND lookup_code = 'SHOP FLOOR')
                            /* commenting the below and adding new conditions bug 7644072
                                 OR (p_value_basis_tbl(i) = 'FIXED PRICE' -- EAM Integration Enhancement R12
                                     AND lookup_code = 'SHOP FLOOR')*/
                                 OR (p_value_basis_tbl(i) = 'FIXED PRICE' -- EAM Integration Enhancement R12
                                     AND p_purchase_basis_tbl(i) = 'TEMP LABOR'   --bug7644072
                                     AND lookup_code = 'EXPENSE')                 --bug7644072
                                )
                            AND ((nvl(p_accrue_on_receipt_flag_tbl(i),'N') = 'N' AND lookup_code = 'EXPENSE')
                                 OR p_txn_flow_header_id_tbl(i) is NOT NULL
				 OR p_consigned_flag_tbl(i) = 'Y' --Bug 19379838
                                 OR (nvl(p_accrue_on_receipt_flag_tbl(i),'N') = 'Y'
                                    AND ((p_expense_accrual_code = 'PERIOD END' AND lookup_code <> 'EXPENSE')
                                         OR p_expense_accrual_code <> 'PERIOD END')
                                        )
                                )
                            AND lookup_code= p_dest_type_code_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    d_position := 80;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, d_position, NULL);
      END IF;

      RAISE;
  END destination_type_code;

-----------------------------------------------------------
-- Validation Logic:
--   If destination_type_code is INVENTORY and destination_subinventiry is not null,
--   validate the destination_subinventory against mtl_secondary_inventories based on
--   ship_to_organization_id and item_id.
--   If destination_type_code is SHOP FLOOR and EXPENSE, the value has to be NULL.
--   Need to validate that SHIKYU item can only have asset subinventory (inventory_asset = 1).
-----------------------------------------------------------
  PROCEDURE destination_subinv(
    p_id_tbl                       IN              po_tbl_number,
    p_destination_subinv_tbl       IN              po_tbl_varchar30,
    p_dest_type_code_tbl           IN              po_tbl_varchar30,
    p_item_id_tbl                  IN              po_tbl_number,
    p_ship_to_org_id_tbl           IN              po_tbl_number,
    p_loc_outsourced_assembly_tbl  IN              po_tbl_number,
    x_result_set_id                IN OUT NOCOPY   NUMBER,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_destination_subinv;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_destination_subinv_tbl', p_destination_subinv_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_loc_outsourced_assembly', p_loc_outsourced_assembly_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_dest_type_code_tbl(i) IN('SHOP FLOOR', 'EXPENSE') AND p_destination_subinv_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'DESTINATION_SUBINVENTORY',
                             p_column_val       => p_destination_subinv_tbl(i),
                             p_message_name     => 'PO_PDOI_INVALID_DEST_SUBINV');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_DEST_SUBINV',
               'DESTINATION_SUBINVENTORY',
               p_destination_subinv_tbl(i),
               'DESTINATION_SUBINVENTORY',
               p_destination_subinv_tbl(i)
          FROM DUAL
         WHERE p_dest_type_code_tbl(i) = 'INVENTORY'
           AND p_destination_subinv_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM mtl_secondary_inventories msub
                  WHERE msub.organization_id = NVL(p_ship_to_org_id_tbl(i), msub.organization_id)
                    AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                    AND (   p_item_id_tbl(i) IS NULL
                         OR (    p_item_id_tbl(i) IS NOT NULL
                             AND EXISTS(
                                   SELECT NULL
                                     FROM mtl_system_items msi
                                    WHERE msi.organization_id = NVL(p_ship_to_org_id_tbl(i), msi.organization_id)
                                      AND msi.inventory_item_id = p_item_id_tbl(i)
                                      AND (   msi.restrict_subinventories_code = 2
                                           OR (    msi.restrict_subinventories_code = 1
                                               AND EXISTS(
                                                     SELECT NULL
                                                       FROM mtl_item_sub_inventories mis
                                                      WHERE mis.organization_id =
                                                                       NVL(p_ship_to_org_id_tbl(i), mis.organization_id)
                                                        AND mis.inventory_item_id = msi.inventory_item_id
                                                        AND mis.secondary_inventory = msub.secondary_inventory_name))))))
                    AND msub.secondary_inventory_name = p_destination_subinv_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    -- Need to validate that SHIKYU item can only have asset subinventory (inventory_asset = 1).
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_SHIKYU_DEST_SUBINV',
               'DESTINATION_SUBINVENTORY',
               p_destination_subinv_tbl(i),
               'DESTINATION_SUBINVENTORY',
               p_destination_subinv_tbl(i)
          FROM DUAL
         WHERE p_destination_subinv_tbl(i) IS NOT NULL
           AND p_dest_type_code_tbl(i) = 'INVENTORY'
           AND p_loc_outsourced_assembly_tbl(i) = 1 /* SHIKYU item */
           AND EXISTS(
                 SELECT 1
                   FROM mtl_secondary_inventories msub
                  WHERE msub.organization_id = NVL(p_ship_to_org_id_tbl(i), msub.organization_id)
                    AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                    AND msub.asset_inventory = 2 /* Not asset subinventory */
                    AND msub.secondary_inventory_name = p_destination_subinv_tbl(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END destination_subinv;

-----------------------------------------------------------
-- Validation Logic:
--   If destination_type_code is SHOP FLOOR,
--   If wip_entity_id is null,
--       ERR: 'PO_PDOI_COLUMN_NOT_NULL'
--   Else
--       Validate against wip_repetitive_schedules/
--       wip_discrete_jobs depending on the value of
--       wip_repetitive_schedule_id. (If the
--       destination_type_code = 'SHOP FLOOR', then if
--       WIP_REPETITIVE_SCHEDULE_ID is not null then the
--        record must be a repetitive schedule. If
--        WIP_REPETITIVE_SCHEDULE_ID is NULL, then it
--        must be a discrete job)
-----------------------------------------------------------
  PROCEDURE wip_entity_id(
    p_id_tbl                    IN              po_tbl_number,
    p_wip_entity_id_tbl         IN              po_tbl_number,
    p_wip_rep_schedule_id_tbl   IN              po_tbl_number,
    p_dest_type_code_tbl        IN              po_tbl_varchar30,
    p_destination_org_id_tbl    IN              po_tbl_number,
    x_result_set_id             IN OUT NOCOPY   NUMBER,
    x_results                   IN OUT NOCOPY   po_validation_results_type,
    x_result_type               OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_wip_entity_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_wip_entity_id_tbl', p_wip_entity_id_tbl);
      po_log.proc_begin(d_mod, 'p_wip_rep_schedule_id_tbl', p_wip_rep_schedule_id_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_destination_org_id_tbl', p_destination_org_id_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_dest_type_code_tbl(i) = 'SHOP FLOOR' AND p_wip_entity_id_tbl(i) IS NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'WIP_ENTITY_ID',
                             p_column_val       => p_wip_entity_id_tbl(i),
                             p_message_name     => 'PO_PDOI_COLUMN_NOT_NULL',
                             p_token1_name      => 'COLUMN_NAME',
                             p_token1_value     => 'WIP_ENTITY_ID');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_WIP_SCHED',
               'WIP_REPETITIVE_SCHEDULE_ID',
               p_wip_rep_schedule_id_tbl(i),
               'WIP_REPETITIVE_SCHEDULE_ID',
               p_wip_rep_schedule_id_tbl(i)
          FROM DUAL
         WHERE p_dest_type_code_tbl(i) = 'SHOP FLOOR'
           AND p_wip_entity_id_tbl(i) IS NOT NULL
           AND p_wip_rep_schedule_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM wip_repetitive_schedules wrs
                  WHERE wrs.organization_id = p_destination_org_id_tbl(i)
                    AND wrs.wip_entity_id = p_wip_entity_id_tbl(i)
                    AND wrs.repetitive_schedule_id = p_wip_rep_schedule_id_tbl(i)
                    AND wrs.status_type IN(3, 4, 6));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_WIP_ENTITY',
               'WIP_ENTITY_ID',
               p_wip_entity_id_tbl(i),
               'WIP_ENTITY_ID',
               p_wip_entity_id_tbl(i)
          FROM DUAL
         WHERE p_dest_type_code_tbl(i) = 'SHOP FLOOR'
           AND p_wip_entity_id_tbl(i) IS NOT NULL
           AND p_wip_rep_schedule_id_tbl(i) IS NULL
           AND NOT EXISTS(
                 SELECT 1
                   FROM wip_discrete_jobs wdj
                  WHERE wdj.organization_id = p_destination_org_id_tbl(i)
                    AND wdj.wip_entity_id = p_wip_entity_id_tbl(i)
                    AND wdj.status_type IN(3, 4, 6));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END wip_entity_id;

-----------------------------------------------------------
-- Validation Logic:
--   The value needs to be 'Y' if the destination_type_code is 'SHOP FLOOR'.
--   For other destination type, the value has to be 'N'.
-----------------------------------------------------------
  PROCEDURE prevent_encumbrance_flag(
    p_id_tbl                   IN              po_tbl_number,
    p_prevent_encum_flag_tbl   IN              po_tbl_varchar1,
    p_dest_type_code_tbl       IN              po_tbl_varchar30,
   p_distribution_type_tbl    IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_wip_entity_id_tbl        IN              po_tbl_number,
    x_results                  IN OUT NOCOPY   po_validation_results_type,
    x_result_type              OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_prevent_encumberance_flag;
    l_wip_entity_type         NUMBER;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_prevent_encum_flag_tbl', p_prevent_encum_flag_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_distribution_type_tbl', p_distribution_type_tbl); -- PDOI for Complex PO Project
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

/* For Encumbrance Project - To enable Encumbrance for Destination type - Shop Floor and WIP entity type - EAM
     Retriving entity_type and Stting the prevent_encumbrance_flag to 'Y' if destination type = shop floor
     and wip_entity_type <> 6 ( '6' is for EAM jobs) */

    FOR i IN 1 .. p_id_tbl.COUNT LOOP

    IF(p_dest_type_code_tbl(i) = 'SHOP FLOOR') then
    BEGIN
     select entity_type
     into l_wip_entity_type
     from wip_entities
     where wip_entity_id = p_wip_entity_id_tbl(i) ;
    exception
    when others then
     null;
    END;
    END IF;

    IF (   (p_dest_type_code_tbl(i) = 'SHOP FLOOR' AND p_prevent_encum_flag_tbl(i) = 'N' AND l_wip_entity_type <> 6 ) /* Condition added for Encumbrance Project  */
          OR (p_dest_type_code_tbl(i) <> 'SHOP FLOOR' AND p_prevent_encum_flag_tbl(i) = 'Y'
	      AND p_distribution_type_tbl(i) <> 'PREPAYMENT')) THEN -- PDOI for Complex PO Project
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PREVENT_ENCUMBERANCE_FLAG',
                             p_column_val       => p_prevent_encum_flag_tbl(i),
                             p_message_name     => 'PO_PDOI_INV_PREV_ENCUM_FLAG');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END prevent_encumbrance_flag;

-----------------------------------------------------------
-- Bug 18907904
-- Validation Logic:
-- The GL encumdered date must be in open purchasing period
-----------------------------------------------------------
  PROCEDURE gl_encumbered_date(
                              p_id_tbl                  IN po_tbl_number,
                              p_gl_date_tbl             IN po_tbl_date,
                              p_set_of_books_id         IN NUMBER,
                              p_po_encumberance_flag    IN VARCHAR2,
                              x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                              x_result_type             OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_gl_encumbered_date;
    l_gl_enc_period_name  VARCHAR2(30);
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_gl_date_tbl', p_gl_date_tbl);
      po_log.proc_begin(d_mod, 'p_set_of_books_id', p_set_of_books_id);
      po_log.proc_begin(d_mod, 'p_po_encumberance_flag', p_po_encumberance_flag);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    --Tracking GL Encumbered Date not in Open Accounting Period
    -- Budgetary Action in an encumbrance enabled environment.


    IF (p_po_encumberance_flag = 'Y') THEN

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
          po_periods_sv.get_period_name(p_set_of_books_id,
				 	                            nvl( p_gl_date_tbl(i),sysdate),
                                      l_gl_enc_period_name);

          IF (l_gl_enc_period_name IS NULL) THEN
             x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'GL_ENCUMBERED_DATE',
                             p_column_val       => p_gl_date_tbl(i),
                             p_message_name     => 'PO_PO_ENTER_OPEN_GL_DATE');
             x_result_type := po_validations.c_result_type_failure;
          END IF;

      END LOOP;
    END IF;

   IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
   EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END gl_encumbered_date;

-----------------------------------------------------------
--  Validation Logic:
--   The charge_account_id can not be null.
--   If it is not null, it must be a valid  id in gl_code_combinations.
-----------------------------------------------------------
  PROCEDURE charge_account_id(
    p_id_tbl                  IN              po_tbl_number,
    p_charge_account_id_tbl   IN              po_tbl_number,
    p_gl_date_tbl             IN              po_tbl_date,
    p_chart_of_account_id     IN              NUMBER,
    x_result_set_id           IN OUT NOCOPY   NUMBER,
    x_result_type             OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_charge_account_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_charge_account_id_tbl', p_charge_account_id_tbl);
      po_log.proc_begin(d_mod, 'p_gl_date_tbl', p_gl_date_tbl);
      po_log.proc_begin(d_mod, 'p_chart_of_account_id', p_chart_of_account_id);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               decode(p_charge_account_id_tbl(i), NULL, 'PO_PDOI_NO_CHG_ACCT', 'PO_PDOI_INVALID_CHG_ACCOUNT'),
               'CHARGE_ACCOUNT_ID',
               p_charge_account_id_tbl(i),
               decode(p_charge_account_id_tbl(i), NULL, NULL, 'CHARGE_ACCOUNT'),
               decode(p_charge_account_id_tbl(i), NULL, NULL, p_charge_account_id_tbl(i))
          FROM DUAL
         WHERE (p_charge_account_id_tbl(i) IS NULL OR
                 (p_charge_account_id_tbl(i) IS NOT NULL AND
                  NOT EXISTS(
                      SELECT NULL
                        FROM gl_code_combinations gcc
                       WHERE gcc.code_combination_id = p_charge_account_id_tbl(i)
                         AND gcc.enabled_flag = 'Y'
                         AND TRUNC(NVL(p_gl_date_tbl(i), SYSDATE)) BETWEEN TRUNC(NVL(start_date_active,
                                                                                     NVL(p_gl_date_tbl(i), SYSDATE)))
                                                                       AND TRUNC(NVL(end_date_active,
                                                                                     NVL(p_gl_date_tbl(i), SYSDATE)))
                         AND gcc.detail_posting_allowed_flag = 'Y'
                         AND gcc.chart_of_accounts_id = p_chart_of_account_id
                         AND gcc.summary_flag = 'N')));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END charge_account_id;

-----------------------------------------------------------
--  Validation Logic:
--   1. If po_encumbrance_flag is Y, and destination_type_code is not 'SHOP FLOOR',
--      the budget_account_id can not be null.
--   2. If the account_id is not null, it must be a valid id in gl_code_combinations.
-----------------------------------------------------------
  PROCEDURE budget_account_id(
    p_id_tbl                  IN              po_tbl_number,
    p_budget_account_id_tbl   IN              po_tbl_number,
    p_gl_date_tbl             IN              po_tbl_date,
    p_dest_type_code_tbl      IN              po_tbl_varchar30,
    p_distribution_type_tbl   IN              po_tbl_varchar30, -- PDOI for Complex PO Project
    p_chart_of_account_id     IN              NUMBER,
    p_po_encumberance_flag    IN              VARCHAR2,
    p_wip_entity_id_tbl       IN              po_tbl_number,
    x_result_set_id           IN OUT NOCOPY   NUMBER,
    x_result_type             OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_budget_account_id;
    l_wip_entity_type number := NULL ;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_budget_account_id_tbl', p_budget_account_id_tbl);
      po_log.proc_begin(d_mod, 'p_gl_date_tbl', p_gl_date_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_distribution_type_tbl', p_distribution_type_tbl); -- PDOI for Complex PO Project
      po_log.proc_begin(d_mod, 'p_chart_of_account_id', p_chart_of_account_id);
      po_log.proc_begin(d_mod, 'p_po_encumberance_flag', p_po_encumberance_flag);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- bug 4899825: add checking on destination_type_code when
    --              budget_account_id is empty; If destination_
    --              type_code is 'SHOP FLOOR', budget_account_id
    --              could be empty even when encumbrance is enabled
    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_INVALID_BUDGET_ACCT',
               'BUDGET_ACCOUNT_ID',
               p_budget_account_id_tbl(i),
               'BUDGET_ACCOUNT',
               p_budget_account_id_tbl(i)
          FROM DUAL
        WHERE (p_po_encumberance_flag = 'Y' AND
                (p_dest_type_code_tbl(i) <> 'SHOP FLOOR' AND p_distribution_type_tbl(i) <> 'PREPAYMENT') AND
                                                                              -- PDOI for Complex PO Project
               (p_dest_type_code_tbl(i) <> 'SHOP FLOOR' OR  (p_dest_type_code_tbl(i) = 'SHOP FLOOR'
                AND (SELECT entity_type from wip_entities where wip_entity_id = p_wip_entity_id_tbl(i)) = 6))  /* Encumbrance Project */
                AND p_budget_account_id_tbl(i) IS NULL)
            OR (    p_budget_account_id_tbl(i) IS NOT NULL
                AND NOT EXISTS(
                      SELECT NULL
                        FROM gl_code_combinations gcc
                       WHERE gcc.code_combination_id = p_budget_account_id_tbl(i)
                         AND gcc.enabled_flag = 'Y'
                         AND TRUNC(NVL(p_gl_date_tbl(i), SYSDATE)) BETWEEN TRUNC(NVL(start_date_active,
                                                                                     NVL(p_gl_date_tbl(i), SYSDATE)))
                                                                       AND TRUNC(NVL(end_date_active,
                                                                                     NVL(p_gl_date_tbl(i), SYSDATE)))
                         AND gcc.detail_posting_allowed_flag = 'Y'
                         AND gcc.chart_of_accounts_id = p_chart_of_account_id
                         AND gcc.summary_flag = 'N'));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END budget_account_id;

----------------------------------------------------------------------------------
-- Validation Logic:
--   If the account_id is not null, it must be a valid id in gl_code_combinations.
--   Used to validate accrual account id and variance account id.
----------------------------------------------------------------------------------
  PROCEDURE account_id(
    p_id_tbl                IN              po_tbl_number,
    p_account_id_tbl        IN              po_tbl_number,
    p_gl_date_tbl           IN              po_tbl_date,
    p_chart_of_account_id   IN              NUMBER,
    p_message_name          IN              VARCHAR2,
    p_column_name           IN              VARCHAR2,
    p_token_name            IN              VARCHAR2,
    x_result_set_id         IN OUT NOCOPY   NUMBER,
    x_result_type           OUT NOCOPY      VARCHAR2)
  IS
     d_mod CONSTANT VARCHAR2(100) := d_account_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_account_id_tbl', p_account_id_tbl);
      po_log.proc_begin(d_mod, 'p_gl_date_tbl', p_gl_date_tbl);
      po_log.proc_begin(d_mod, 'p_chart_of_account_id', p_chart_of_account_id);
      po_log.proc_begin(d_mod, 'p_message_name', p_message_name);
      po_log.proc_begin(d_mod, 'p_column_name', p_column_name);
      po_log.proc_begin(d_mod, 'p_token_name', p_token_name);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   token1_name,
                   token1_value)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               p_message_name,
               p_column_name,
               p_account_id_tbl(i),
               p_token_name,
               p_account_id_tbl(i)
          FROM DUAL
         WHERE p_account_id_tbl(i) IS NOT NULL
           AND NOT EXISTS(
                 SELECT NULL
                   FROM gl_code_combinations gcc
                  WHERE gcc.code_combination_id = p_account_id_tbl(i)
                    AND gcc.enabled_flag = 'Y'
                    AND TRUNC(NVL(p_gl_date_tbl(i), SYSDATE)) BETWEEN TRUNC(NVL(start_date_active,
                                                                                NVL(p_gl_date_tbl(i), SYSDATE)))
                                                                  AND TRUNC(NVL(end_date_active,
                                                                                NVL(p_gl_date_tbl(i), SYSDATE)))
                    AND gcc.detail_posting_allowed_flag = 'Y'
                    AND gcc.chart_of_accounts_id = p_chart_of_account_id
                    AND gcc.summary_flag = 'N');

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END account_id;

-----------------------------------------------------------
-- Validation Logic:
--   Project_accounting_context must be 'Y' if the values of project_id, task_id, expenditure_type,
--   expenditure_organization_id are all not null.
-----------------------------------------------------------
  PROCEDURE project_acct_context(
    p_id_tbl                 IN              po_tbl_number,
    p_project_acct_ctx_tbl   IN              po_tbl_varchar30,
    p_project_id_tbl         IN              po_tbl_number,
    p_task_id_tbl            IN              po_tbl_number,
    p_exp_type_tbl           IN              po_tbl_varchar30,
    p_exp_org_id_tbl         IN              po_tbl_number,
    x_results                IN OUT NOCOPY   po_validation_results_type,
    x_result_type            OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_project_acct_context;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_project_acct_ctx_tbl', p_project_acct_ctx_tbl);
      po_log.proc_begin(d_mod, 'p_project_id_tbl', p_project_id_tbl);
      po_log.proc_begin(d_mod, 'p_task_id_tbl', p_task_id_tbl);
      po_log.proc_begin(d_mod, 'p_exp_type_tbl', p_exp_type_tbl);
      po_log.proc_begin(d_mod, 'p_exp_org_id_tbl', p_exp_org_id_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (    (p_project_acct_ctx_tbl(i) IS NULL OR p_project_acct_ctx_tbl(i) = 'N')
          AND p_project_id_tbl(i) IS NOT NULL
          AND p_task_id_tbl(i) IS NOT NULL
          AND p_exp_type_tbl(i) IS NOT NULL
          AND p_exp_org_id_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PROJECT_ACCOUNT_CONTEXT',
                             p_column_val       => p_project_acct_ctx_tbl(i),
                             p_message_name     => 'PO_PDOI_PROJECT_ACCT_CONTEXT');
        x_result_type := po_validations.c_result_type_failure;
      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END project_acct_context;

-----------------------------------------------------------
-- Validation Logic:
--   If project_accounting_context is 'Y',
--    If destination_type_code is EXPENSE,
--        a. validate project_id, task_id and expenditure_item_date against
--           pa_projects_expend_v/pa_tasks_expends_v
--        b. validate expenditure_type against pa_expenditure_type_expend_v
--        c. validate expenditure_organization_id against pa_organizations_expends_v
--        d. if all the above validations passed, call pa_transactions_pub.validate_transaction()
--           to validate project information.
--    Else if destination_type_code is INVENTORY
--        a. call po_project_details_sv.validate_proj_references_wrp() to validate PJM project
--        b. validate expenditure_type against pa_expenditure_types if not null
--        c. validate expenditure_organization_id against per_organzaition_units.
-----------------------------------------------------------
  PROCEDURE project_info(
    p_id_tbl                      IN              po_tbl_number,
    p_project_acct_ctx_tbl        IN              po_tbl_varchar30,
    p_dest_type_code_tbl          IN              po_tbl_varchar30,
    p_project_id_tbl              IN              po_tbl_number,
    p_task_id_tbl                 IN              po_tbl_number,
    p_expenditure_type_tbl        IN              po_tbl_varchar30,
    p_expenditure_org_id_tbl      IN              po_tbl_number,
    p_ship_to_org_id_tbl          IN              po_tbl_number,
    p_need_by_date_tbl            IN              po_tbl_date,
    p_promised_date_tbl           IN              po_tbl_date,
    p_expenditure_item_date_tbl   IN              po_tbl_date,
    p_ship_to_ou_id               IN              NUMBER,
    p_deliver_to_person_id_tbl    IN              po_tbl_number,
    p_agent_id_tbl                IN              po_tbl_number,
    p_txn_flow_header_id_tbl      IN              po_tbl_number,
    p_org_id_tbl                  IN              po_tbl_number, --<PDOI Enhancement Bug#17063664>
    x_results                     IN OUT NOCOPY   po_validation_results_type,
    x_result_type                 OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_project_info;
    l_valid VARCHAR2(1);
    l_msg_name VARCHAR2(100);  --<Bug 14662559>

  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_project_acct_ctx_tbl', p_project_acct_ctx_tbl);
      po_log.proc_begin(d_mod, 'p_dest_type_code_tbl', p_dest_type_code_tbl);
      po_log.proc_begin(d_mod, 'p_project_id_tbl', p_project_id_tbl);
      po_log.proc_begin(d_mod, 'p_task_id_tbl', p_task_id_tbl);
      po_log.proc_begin(d_mod, 'p_expenditure_type_tbl', p_expenditure_type_tbl);
      po_log.proc_begin(d_mod, 'p_expenditure_org_id_tbl', p_expenditure_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
      po_log.proc_begin(d_mod, 'p_need_by_date_tbl', p_need_by_date_tbl);
      po_log.proc_begin(d_mod, 'p_promised_date_tbl', p_promised_date_tbl);
      po_log.proc_begin(d_mod, 'p_expenditure_item_date_tbl', p_expenditure_item_date_tbl);
      po_log.proc_begin(d_mod, 'p_ship_to_ou_id', p_ship_to_ou_id);
      po_log.proc_begin(d_mod, 'p_deliver_to_person_id_tbl', p_deliver_to_person_id_tbl);
      po_log.proc_begin(d_mod, 'p_agent_id_tbl', p_agent_id_tbl);
      po_log.proc_begin(d_mod, 'p_txn_flow_header_id_tbl', p_txn_flow_header_id_tbl);
      po_log.proc_begin(d_mod, 'p_org_id_tbl', p_org_id_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF (p_project_acct_ctx_tbl(i) = 'Y') THEN
          po_pdoi_distributions_sv3.validate_project_info(p_dest_type_code_tbl(i),
                                                          p_project_id_tbl(i),
                                                          p_task_id_tbl(i),
                                                          p_expenditure_type_tbl(i),
                                                          p_expenditure_org_id_tbl(i),
                                                          p_ship_to_org_id_tbl(i),
                                                          p_need_by_date_tbl(i),
                                                          p_promised_date_tbl(i),
                                                          p_expenditure_item_date_tbl(i),
                                                          p_ship_to_ou_id,
                                                          NVL(p_deliver_to_person_id_tbl(i),p_agent_id_tbl(i)),
                                                          l_valid,
                                                          l_msg_name
                                                          );
   --Bug 14662559: Show different error messages for different project validations.
        IF (l_valid <> 'Y') THEN
         if l_msg_name = 'PO_PDOI_INVALID_EXPEND_TYPE' or l_msg_name = 'PO_PDOI_INVALID_EXPEND_ORG'  then
	         x_results.add_result(p_entity_type      => c_entity_type_distribution,
	                               p_entity_id        => p_id_tbl(i),
	                               p_column_name      => 'PROJECT_ID',
	                               p_column_val       => p_project_id_tbl(i),
	                              --Bug# 5117923: corrected the msg name
	                               p_message_name     => l_msg_name
	                               );

         else
	         x_results.add_result(p_entity_type      => c_entity_type_distribution,
	                               p_entity_id        => p_id_tbl(i),
	                               p_column_name      => 'PROJECT_ID',
	                               p_column_val       => p_project_id_tbl(i),
	                              --Bug# 5117923: corrected the msg name
	                               p_message_name     => 'PO_PDOI_INVALID_PROJ_INFO',
	                               p_token1_name      => 'PJM_ERROR_MSG',
	                               p_token1_value     => FND_MESSAGE.GET_STRING('PA',l_msg_name)
	                               );
          end if;

          x_result_type := po_validations.c_result_type_failure;
        END IF;
      END IF;

      IF (p_dest_type_code_tbl(i) = 'EXPENSE' AND p_project_id_tbl(i) IS NOT NULL
          AND p_txn_flow_header_id_tbl(i) IS NOT NULL) THEN
        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PROJECT_ID',
                             p_column_val       => p_project_id_tbl(i),
                             p_message_name     => 'PO_CROSS_OU_PA_PROJECT_CHECK');
        x_result_type := po_validations.c_result_type_failure;

      --<PDOI Enhancement Bug#17063664>
      --Project, Task and Award details should not be provided when Grants Accounting is enabled and the Destination type is set as "inventory".
      ELSIF (p_dest_type_code_tbl(i) = 'INVENTORY'
             AND p_project_id_tbl(i) IS NOT NULL
             /* AND PO_GMS_INTEGRATION_PVT.get_gms_enabled_flag(p_org_id => p_org_id_tbl(i)) = 'Y') THEN */
						 AND PO_GMS_INTEGRATION_PVT.is_gms_enabled ) THEN -- <<Bug#1822123850>>

        x_results.add_result(p_entity_type      => c_entity_type_distribution,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'PROJECT_ID',
                             p_column_val       => p_project_id_tbl(i),
                             p_message_name     => 'PO_PDOI_NO_PRJ_GRNT_INV');
        x_result_type := po_validations.c_result_type_failure;

      END IF;
    END LOOP;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END project_info;

-----------------------------------------------------------
-- Validation Logic:
--   If tax_recovery_override_flag is 'Y' and
--   p_allow_tax_rate_override is not 'Y', throw an error
-----------------------------------------------------------
  PROCEDURE tax_recovery_override_flag(p_id_tbl                     IN po_tbl_number,
                                       p_recovery_override_flag_tbl IN po_tbl_varchar1,
                                       p_allow_tax_rate_override    IN VARCHAR2,
									   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                       x_result_type                OUT NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_tax_recovery_override_flag;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_recovery_override_flag_tbl', p_recovery_override_flag_tbl);
      po_log.proc_begin(d_mod, 'p_allow_tax_rate_override', p_allow_tax_rate_override);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    IF (p_allow_tax_rate_override <> 'Y') THEN
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
        IF (p_recovery_override_flag_tbl(i) = 'Y') THEN
          x_results.add_result(p_entity_type      => c_entity_type_distribution,
                               p_entity_id        => p_id_tbl(i),
                               p_column_name      => 'TAX_RECOVERY_OVERRIDE_FLAG',
                               p_column_val       => p_recovery_override_flag_tbl(i),
                               p_message_name     => 'PO_PDOI_NO_TAX_RATE_OVERRIDE');
          x_result_type := po_validations.c_result_type_failure;
        END IF;
      END LOOP;
    END IF;

    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END tax_recovery_override_flag;

  -----------------------------------------------------------
--  16208248
--  Validation Logic:
--   The charge_account_id can not be null.
--   Validation of charge_account_id happens from PODistributionSvrCmd.java
--   This is to handle the case where Save is hit with the distribution
--   not being dirty in Create mode.
-----------------------------------------------------------
  PROCEDURE charge_account_id_null(
    p_id_tbl                  IN              po_tbl_number,
    p_charge_account_id_tbl   IN              po_tbl_number,
    x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
    x_result_type             OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_charge_account_id;
  BEGIN
    IF x_results IS NULL THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_charge_account_id_tbl', p_charge_account_id_tbl);

    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP

       IF p_charge_account_id_tbl(i) IS NULL THEN
          x_results.add_result(p_entity_type      => c_entity_type_distribution,
                               p_entity_id        => p_id_tbl(i),
                               p_column_name      => 'CHARGE_ACCOUNT_ID',
                               p_column_val       => p_charge_account_id_tbl(i),
                               p_message_name     => 'PO_CHARGE_NOT_NULL');
          x_result_type := po_validations.c_result_type_failure;
      END IF;

     END LOOP;


    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END charge_account_id_null;

  --BUg 16856753
  --This procedure calls validate_Account_wrapper to validate the charge account ids
   PROCEDURE charge_account_id_full(
    p_id_tbl                  IN              po_tbl_number,
    p_charge_account_id_tbl   IN              po_tbl_number,
	p_sob_id_tbl              IN              po_tbl_number,
    x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
    x_result_type             OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_charge_account_id;
	l_account_invalid varchar2(1):= 'N';
	l_result varchar2(1):= 'Y';
	l_structure gl_sets_of_books.chart_of_accounts_id%type;
  BEGIN
    IF x_results IS NULL THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_charge_account_id_tbl', p_charge_account_id_tbl);

    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP

       IF p_charge_account_id_tbl(i) IS NOT NULL THEN

        begin
		select CHART_OF_ACCOUNTS_ID into l_structure from gl_sets_of_books where set_of_books_id = p_sob_id_tbl(i);
		exception
		when others then
		l_account_invalid := 'Y';
		end;

      if (l_account_invalid = 'N') then
		   l_result :=     PO_DOCUMENT_CHECKS_PVT.validate_account_wrapper(
	                         p_structure_number => l_structure,
	                         p_combination_id  => p_charge_account_id_tbl(i),
	                         p_val_date => sysdate);
       END IF;

          if (l_result = 'N' or l_account_invalid = 'Y') then
            x_results.add_result(p_entity_type      => c_entity_type_distribution,
                               p_entity_id        => p_id_tbl(i),
                               p_column_name      => 'CHARGE_ACCOUNT_ID',
                               p_column_val       => p_charge_account_id_tbl(i),
                               p_message_name     => 'PO_PDOI_INVALID_CHARGE_ACCT');
             x_result_type := po_validations.c_result_type_failure;

          END IF;
		 END IF;
     END LOOP;


    IF po_log.d_proc THEN
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END charge_account_id_full;


----------------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validation Logic:
-- Validate that oke_contract_line_id exists in okc_k_lines_b
----------------------------------------------------------------------------------
  PROCEDURE oke_contract_line_id( p_id_tbl                IN              po_tbl_number,
                                  p_oke_con_line_id       IN              po_tbl_number,
                                  p_oke_con_hdr_id        IN              po_tbl_number,
                                  x_result_set_id         IN OUT NOCOPY   NUMBER,
                                  x_result_type           OUT NOCOPY      VARCHAR2)
  IS
     d_mod CONSTANT VARCHAR2(100) := d_oke_contract_line_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_oke_con_line_id', p_oke_con_line_id);
      po_log.proc_begin(d_mod, 'p_oke_con_hdr_id', p_oke_con_hdr_id);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_OKE_LINE_INVALID',
               'OKE_CONTRACT_LINE_ID',
               p_oke_con_line_id(i)
          FROM DUAL
         WHERE p_oke_con_line_id(i) IS NOT NULL
         AND NOT EXISTS (SELECT 'Y'
                         FROM okc_k_lines_b
                         WHERE id = p_oke_con_line_id(i)
                         AND   dnz_chr_id = p_oke_con_hdr_id(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END oke_contract_line_id;

----------------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validation Logic:
-- Validate that oke_contract_deliverable_id exists in oke_k_deliverables_b
----------------------------------------------------------------------------------
  PROCEDURE oke_contract_del_id(p_id_tbl                IN              po_tbl_number,
                                p_oke_con_del_id        IN              po_tbl_number,
                                p_oke_con_line_id       IN              po_tbl_number,
                                x_result_set_id         IN OUT NOCOPY   NUMBER,
                                x_result_type           OUT NOCOPY      VARCHAR2)
  IS
     d_mod CONSTANT VARCHAR2(100) := d_oke_contract_del_id;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_oke_con_del_id', p_oke_con_del_id);
      po_log.proc_begin(d_mod, 'p_oke_con_line_id', p_oke_con_line_id);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val)
        SELECT x_result_set_id,
               po_validations.c_result_type_failure,
               c_entity_type_distribution,
               p_id_tbl(i),
               'PO_PDOI_OKE_DEL_INVALID',
               'OKE_CONTRACT_DELIVERABLE_ID',
               p_oke_con_del_id(i)
          FROM DUAL
         WHERE p_oke_con_del_id(i) IS NOT NULL
         AND NOT EXISTS (SELECT 'Y'
                         FROM oke_k_deliverables_b
                         WHERE deliverable_id = p_oke_con_del_id(i)
                         AND   k_line_id = p_oke_con_line_id(i));

    IF (SQL%ROWCOUNT > 0) THEN
      x_result_type := po_validations.c_result_type_failure;
    END IF;

    IF po_log.d_proc THEN
      po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
      po_log.proc_end(d_mod, 'x_result_type', x_result_type);
      po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF po_log.d_exc THEN
        po_log.exc(d_mod, 0, NULL);
      END IF;

      RAISE;
  END oke_contract_del_id;

END po_val_distributions2;

/
