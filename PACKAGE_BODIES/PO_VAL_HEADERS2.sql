--------------------------------------------------------
--  DDL for Package Body PO_VAL_HEADERS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_HEADERS2" AS
   -- $Header: PO_VAL_HEADERS2.plb 120.19.12010000.8 2013/10/03 08:47:35 inagdeo ship $
   c_entity_type_header CONSTANT VARCHAR2(30) := po_validations.c_entity_type_header;
   -- The module base for this package.
   d_package_base CONSTANT VARCHAR2(50) := po_log.get_package_base('PO_VAL_HEADERS2');

   -- The module base for the subprogram.
   d_po_header_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PO_HEADER_ID');
   d_document_num CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'DOCUMENT_NUM');
   d_type_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'TYPE_LOOKUP_CODE');
   d_currency_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CURRENCY_CODE');
   d_rate_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'RATE_INFO');
   d_agent_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AGENT_ID');
   d_vendor_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VENDOR_INFO');
   d_ship_to_location_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIP_TO_LOCATION_ID');
   d_bill_to_location_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'BILL_TO_LOCATION_ID');
   d_last_updated_by CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'LAST_UPDATED_BY');
   d_ship_via_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIP_VIA_LOOKUP_CODE');
   d_fob_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'FOB_LOOKUP_CODE');
   d_freight_terms_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'FREIGHT_TERMS_LOOKUP_CODE');
   d_shipping_control CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'SHIPPING_CONTROL');
   d_approval_status CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'APPROVAL_STATUS');
   d_acceptance_required_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ACCEPTANCE_REQUIRED_FLAG');
   d_acceptance_due_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ACCEPTANCE_DUE_DATE');
   d_cancel_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CANCEL_FLAG');
   d_closed_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CLOSED_CODE');
   d_print_count CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRINT_COUNT');
   d_amount_to_encumber CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT_TO_ENCUMBER');
   d_style_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'STYLE_ID');
   d_amount_limit CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT_LIMIT');

-------------------------------------------------------------------------
-- po_header_id cannot be null and must not exist in Transaction header table.
-- Called for the create case.
-------------------------------------------------------------------------
   PROCEDURE po_header_id(
      p_id_tbl             IN              po_tbl_number,
      p_po_header_id_tbl   IN              po_tbl_number,
      x_result_set_id      IN OUT NOCOPY   NUMBER,
      x_result_type        OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_po_header_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
                      token2_name,
                      token2_value,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_po_header_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_PO_HDR_ID_UNIQUE'),
                   'PO_HEADER_ID',
                   p_po_header_id_tbl(i),
                   'COLUMN_NAME',
                   'PO_HEADER_ID',
                   'VALUE',
                   p_po_header_id_tbl(i),
                   DECODE(p_po_header_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_po_header_id_not_null,
                          PO_VAL_CONSTANTS.c_po_header_id_unique)
              FROM DUAL
             WHERE p_id_tbl(i) IS NULL OR EXISTS(SELECT 1
                                                   FROM po_headers_all poh
                                                  WHERE p_po_header_id_tbl(i) = poh.po_header_id);

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
   END po_header_id;

-----------------------------------------------------------------------------------------
-- document_num must not be null, must be unique, greater than or equal to zero and be of the correct type.
-----------------------------------------------------------------------------------------
   PROCEDURE document_num(
      p_id_tbl                   IN             po_tbl_number,
      p_po_header_id_tbl         IN             po_tbl_number,
      p_document_num_tbl         IN             po_tbl_varchar30,
      p_type_lookup_code_tbl     IN             po_tbl_varchar30,
      p_manual_po_num_type       IN             VARCHAR2,
      p_manual_quote_num_type    IN             VARCHAR2,
      x_results                  IN OUT NOCOPY  po_validation_results_type,
      x_result_set_id            IN OUT NOCOPY  NUMBER,
      x_result_type              OUT NOCOPY     VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_document_num;
      l_num_test NUMBER;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_document_num_tbl', p_document_num_tbl);
         po_log.proc_begin(d_mod, 'p_type_lookup_code_tbl', p_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_manual_po_num_type', p_manual_po_num_type);
         po_log.proc_begin(d_mod, 'p_manual_quote_num_type', p_manual_quote_num_type);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- Bulk validate document_num uniqueness
      --<PDOI Enhancement Bug#17063664> Adding Contract
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
                      token1_value,
					  validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_DOC_NUM_UNIQUE',
                   'DOCUMENT_NUM',
                   p_document_num_tbl(i),
                   'VALUE',
                   p_document_num_tbl(i),
                   PO_VAL_CONSTANTS.c_document_num_unique
              FROM DUAL
             WHERE p_document_num_tbl(i) IS NOT NULL AND --8688769 bug
		     ( EXISTS (SELECT 1
                         FROM po_headers_interface
                        WHERE document_num =p_document_num_tbl(i)
                          AND Nvl(process_code,PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING) IN (PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING,PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS)
                        GROUP BY document_num,org_id HAVING Count(document_num)>1)  --14641487 bug
               OR
               EXISTS(SELECT 1
                      FROM   po_headers
                      WHERE  segment1 = p_document_num_tbl(i)
                      AND    ((p_type_lookup_code_tbl(i) IN ('BLANKET', 'STANDARD', 'CONTRACT')
                              AND
                              type_lookup_code IN ('BLANKET', 'CONTRACT',
                                                   'PLANNED', 'STANDARD'))
                             OR
                              (p_type_lookup_code_tbl(i) = 'QUOTATION' AND
                               type_lookup_code = p_type_lookup_code_tbl(i)))));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_document_num_tbl(i) IS NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'DOCUMENT_NUM',
                                 p_column_val        => p_document_num_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'DOCUMENT_NUM',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_document_num_tbl(i),
                                 p_validation_id     => PO_VAL_CONSTANTS.c_document_num_not_null);

            x_result_type := po_validations.c_result_type_failure; -- bug5101044
         ELSIF ((p_type_lookup_code_tbl(i) IN ('BLANKET', 'STANDARD', 'CONTRACT')
                 AND p_manual_po_num_type = 'NUMERIC')
                OR
                (p_type_lookup_code_tbl(i) = 'QUOTATION'
                 AND p_manual_quote_num_type = 'NUMERIC')) THEN

            BEGIN
               l_num_test := TO_NUMBER(p_document_num_tbl(i));

               -- validate that document_num is greater than or equal to zero.
               -- Note that -po_header_id is a special segment1 that PDOI
               -- temporarily sets for documents without segment1 specified.
               IF (p_document_num_tbl(i) < 0 AND
                   p_document_num_tbl(i) <> -p_po_header_id_tbl(i)) THEN
                  x_results.add_result(p_entity_type       => c_entity_type_header,
                                       p_entity_id         => p_id_tbl(i),
                                       p_column_name       => 'DOCUMENT_NUM',
                                       p_column_val        => p_document_num_tbl(i),
                                       p_message_name      => 'PO_PDOI_LT_ZERO',
                                       p_token1_name       => 'COLUMN_NAME',
                                       p_token1_value      => 'DOCUMENT_NUM',
                                       p_token2_name       => 'VALUE',
                                       p_token2_value      => p_document_num_tbl(i),
                     p_validation_id     => PO_VAL_CONSTANTS.c_document_num_ge_zero);
                  x_result_type := po_validations.c_result_type_failure;
               END IF;

            EXCEPTION
            WHEN VALUE_ERROR THEN
               -- exception occured because value wasn't numeric
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'DOCUMENT_NUM',
                                    p_column_val        => p_document_num_tbl(i),
                                    p_message_name      => 'PO_PDOI_VALUE_NUMERIC',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'DOCUMENT_NUM',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_document_num_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_document_num_valid);
               x_result_type := po_validations.c_result_type_failure;
            END;
         END IF;
      END LOOP;

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

   END document_num;

-------------------------------------------------------------------------
-- type_lookup_code cannot be null and must be equal to
-- BLANKET, STANDARD or QUOTATION.
-------------------------------------------------------------------------
   PROCEDURE type_lookup_code(
      p_id_tbl                 IN              po_tbl_number,
      p_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                IN OUT NOCOPY   po_validation_results_type,
      x_result_type            OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_type_lookup_code;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_type_lookup_code_tbl', p_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_type_lookup_code_tbl(i) IS NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'TYPE_LOOKUP_CODE',
                                 p_column_val        => p_type_lookup_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'TYPE_LOOKUP_CODE',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_type_lookup_code_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_type_lookup_code_not_null);
            x_result_type := po_validations.c_result_type_failure;
        --<PDOI Enhancement Bug#17063664> Adding Contract
         ELSIF p_type_lookup_code_tbl(i) NOT IN('BLANKET', 'STANDARD', 'QUOTATION', 'CONTRACT') THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'TYPE_LOOKUP_CODE',
                                 p_column_val        => p_type_lookup_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_INVALID_TYPE_LKUP_CD',
                                 p_token1_name       => 'VALUE',
                                 p_token1_value      => p_type_lookup_code_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_type_lookup_code_valid);
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
   END type_lookup_code;

-------------------------------------------------------------------------
-- validate currency_code not null and against FND_CURRENCIES.
-------------------------------------------------------------------------
   PROCEDURE currency_code(
      p_id_tbl              IN              po_tbl_number,
      p_currency_code_tbl   IN              po_tbl_varchar30,
      x_result_set_id       IN OUT NOCOPY   NUMBER,
      x_result_type         OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_currency_code;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_currency_code_tbl', p_currency_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- Bulk validate currency_code not null and against FND_CURRENCIES
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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_currency_code_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_CURRENCY'),
                   'CURRENCY_CODE',
                   p_currency_code_tbl(i),
                   'COLUMN_NAME',
                   'CURRENCY_CODE',
                   'VALUE',
                   p_currency_code_tbl(i),
                   DECODE(p_currency_code_tbl(i), NULL, PO_VAL_CONSTANTS.c_currency_code_not_null,
                          PO_VAL_CONSTANTS.c_currency_code_valid)
              FROM DUAL
             WHERE p_currency_code_tbl(i) IS NULL
                OR NOT EXISTS(
                      SELECT 1
                        FROM fnd_currencies cur
                       WHERE p_currency_code_tbl(i) = cur.currency_code
                         AND cur.enabled_flag = 'Y'
                         AND SYSDATE BETWEEN NVL(cur.start_date_active, SYSDATE - 1)
                                         AND NVL(cur.end_date_active, SYSDATE + 1));

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
   END currency_code;

-------------------------------------------------------------------------
-- If currency_code equals functional currency code, rate_type, rate_date and rate must be null.
-- If currency_code does not equal functional currency code, validate rate_type not null,
-- validate rate_type against gl_daily_conversion_type_v, validate rate is not null and positive,
-- validate rate against g1_currency_api.get_rate().
-------------------------------------------------------------------------
   PROCEDURE rate_info(
      p_id_tbl              IN              po_tbl_number,
      p_currency_code_tbl   IN              po_tbl_varchar30,
      p_rate_type_tbl       IN              po_tbl_varchar30,
      p_rate_tbl            IN              po_tbl_number,
      p_rate_date_tbl       IN              po_tbl_date,
      p_func_currency_code  IN              VARCHAR2,
      p_set_of_books_id     IN              NUMBER,
      x_result_set_id       IN OUT NOCOPY   NUMBER,
      x_results             IN OUT NOCOPY   po_validation_results_type,
      x_result_type         OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_rate_info;
      x_rate NUMBER;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_currency_code_tbl', p_currency_code_tbl);
         po_log.proc_begin(d_mod, 'p_rate_tbl', p_rate_tbl);
         po_log.proc_begin(d_mod, 'p_rate_type_tbl', p_rate_type_tbl);
         po_log.proc_begin(d_mod, 'p_rate_date_tbl', p_rate_date_tbl);
         po_log.proc_begin(d_mod, 'p_func_currency_code', p_func_currency_code);
         po_log.proc_begin(d_mod, 'p_set_of_books_id', p_set_of_books_id);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP

         -- check if currency is equal to functional currency
         IF p_func_currency_code = NVL(p_currency_code_tbl(i), ' ') THEN
            -- validate rate is null if currency is functional
            IF p_rate_tbl(i) IS NOT NULL THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE',
                                    p_column_val        => p_rate_tbl(i),
                                    p_message_name      => 'PO_PDOI_RATE_INFO_NULL',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_null);
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            -- validate rate_type is null if currency is functional
            IF p_rate_type_tbl(i) IS NOT NULL THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE_TYPE',
                                    p_column_val        => p_rate_type_tbl(i),
                                    p_message_name      => 'PO_PDOI_RATE_INFO_NULL',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE_TYPE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_type_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_type_null);
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            -- validate rate_date is null if currency is functional
            IF p_rate_date_tbl(i) IS NOT NULL THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE_DATE',
                                    p_column_val        => p_rate_date_tbl(i),
                                    p_message_name      => 'PO_PDOI_RATE_INFO_NULL',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE_DATE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_date_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_date_null);
               x_result_type := po_validations.c_result_type_failure;
            END IF;
         ELSE
            -- currency is not functional

            -- validate rate is not null
            IF p_rate_tbl(i) IS NULL THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE',
                                    p_column_val        => p_rate_tbl(i),
                                    p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_not_null);
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            -- validate rate is positive
            IF NVL(p_rate_tbl(i), 1) < 0 THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE',
                                    p_column_val        => p_rate_tbl(i),
                                    p_message_name      => 'PO_PDOI_LT_ZERO',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_ge_zero);
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            -- validate rate_type is not null if currency is functional
            IF p_rate_type_tbl(i) IS NULL THEN
               x_results.add_result(p_entity_type       => c_entity_type_header,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'RATE_TYPE',
                                    p_column_val        => p_rate_type_tbl(i),
                                    p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                    p_token1_name       => 'COLUMN_NAME',
                                    p_token1_value      => 'RATE_TYPE',
                                    p_token2_name       => 'VALUE',
                                    p_token2_value      => p_rate_type_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_rate_type_not_null);
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            -- validate rate against g1_currency_api.get_rate()
            IF p_rate_type_tbl(i) IS NOT NULL AND
               p_rate_tbl(i) IS NOT NULL AND
               p_rate_type_tbl(i) <> 'User'
            THEN
               -- Bug 5547502: replaced get_rate() with get_rate_sql() which has
               -- proper exception handling.
               x_rate := gl_currency_api.get_rate_sql(p_set_of_books_id,
                                                  p_currency_code_tbl(i),
                                                  p_rate_date_tbl(i),
                                                  p_rate_type_tbl(i));
               x_rate := ROUND(x_rate, 15);

               IF (NVL(x_rate, 0) <> NVL(p_rate_tbl(i), 0)) THEN
                  x_results.add_result(p_entity_type   => c_entity_type_header,
                                       p_entity_id     => p_id_tbl(i),
                                       p_column_name   => 'RATE',
                                       p_column_val    => p_rate_tbl(i),
                                       p_message_name  => 'PO_PDOI_INVALID_RATE',
                                       p_token1_name   => 'VALUE',
                                       p_token1_value  => p_rate_tbl(i),
                     p_validation_id     => PO_VAL_CONSTANTS.c_rate_valid);
                  x_result_type := po_validations.c_result_type_failure;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- validate rate_type against GL_DAILY_CONVERSION_TYPES
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_RATE_TYPE',
                   'RATE_TYPE',
                   p_rate_type_tbl(i),
                   'VALUE',
                   p_rate_type_tbl(i),
                   PO_VAL_CONSTANTS.c_rate_type_valid
              FROM DUAL
             WHERE p_func_currency_code <> NVL(p_currency_code_tbl(i), ' ')
               AND p_rate_type_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                                FROM gl_daily_conversion_types_v dct
                               WHERE p_rate_type_tbl(i) = dct.conversion_type);

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
   END rate_info;

-------------------------------------------------------------------------
-- Agent Id must not be null and validate against PO_AGENTS.
-------------------------------------------------------------------------
   PROCEDURE agent_id(
      p_id_tbl          IN              po_tbl_number,
      p_agent_id_tbl    IN              po_tbl_number,
      x_result_set_id   IN OUT NOCOPY   NUMBER,
      x_result_type     OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_agent_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_agent_id_tbl', p_agent_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- validate agent_id against PO_AGENTS
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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_agent_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_BUYER'),
                   'AGENT_ID',
                   p_agent_id_tbl(i),
                   'COLUMN_NAME',
                   'AGENT_ID',
                   'VALUE',
                   p_agent_id_tbl(i),
                   DECODE(p_agent_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_agent_id_not_null,
                          PO_VAL_CONSTANTS.c_agent_id_valid)
              FROM DUAL
             WHERE p_agent_id_tbl(i) IS NULL
                OR NOT EXISTS(
                      SELECT 1
                        FROM po_agents poa
                       WHERE p_agent_id_tbl(i) = poa.agent_id
                         AND SYSDATE BETWEEN NVL(poa.start_date_active, SYSDATE - 1)
                                         AND NVL(poa.end_date_active, SYSDATE + 1));

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
   END agent_id;

-------------------------------------------------------------------------
-- validate vendorId is Not Null
-- validate vendorSiteId is Not Null
-- validate vendor_id using po_suppliers_val_v
-- validate vendor_site_id using po_supplier_sites_val_v
-- validate vendor_contact_id using po_vendor_contacts
-- validate vendor site CCR if approval status is APPROVED.
-------------------------------------------------------------------------
   PROCEDURE vendor_info(
      p_id_tbl                  IN              po_tbl_number,
      p_vendor_id_tbl           IN              po_tbl_number,
      p_vendor_site_id_tbl      IN              po_tbl_number,
      p_vendor_contact_id_tbl   IN              po_tbl_number,
      p_type_lookup_code_tbl    IN              po_tbl_varchar30, -- 8913559 bug
      p_federal_instance        IN              VARCHAR,
      x_result_set_id           IN OUT NOCOPY   NUMBER,
      x_results                 IN OUT NOCOPY   po_validation_results_type,
      x_result_type             OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_vendor_info;
      l_return_status VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);
      l_ccr_status VARCHAR2(1);
      l_error_code NUMBER;

      -- Vendor site registration exists and is Active
      -- Other possible values include: 'D'(Deleted), 'E'(Expired), 'N'(Unknown)
      -- and 'U'(Unregistered)
      g_site_reg_active CONSTANT VARCHAR2(1) := 'A';
      -- Vendor site registration does not exist, which means the vendor
      -- is exempt from CCR
      g_site_not_ccr_site CONSTANT NUMBER := 2;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_id_tbl', p_vendor_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_site_id_tbl', p_vendor_site_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_contact_id_tbl', p_vendor_contact_id_tbl);
	 po_log.proc_begin(d_mod, 'p_type_lookup_code_tbl', p_type_lookup_code_tbl); -- 8913559 bug
         po_log.proc_begin(d_mod, 'p_federal_instance', p_federal_instance);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_vendor_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_VENDOR'),
                   'VENDOR_ID',
                   p_vendor_id_tbl(i),
                   'COLUMN_NAME',
                   'VENDOR_ID',
                   'VALUE',
                   p_vendor_id_tbl(i),
                   DECODE(p_vendor_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_vendor_not_null,
                          PO_VAL_CONSTANTS.c_vendor_valid)
              FROM DUAL
             WHERE p_vendor_id_tbl(i) IS NULL
                OR NOT EXISTS(SELECT 1
                              FROM po_suppliers_val_v psv
                              WHERE p_vendor_id_tbl(i) = psv.vendor_id);

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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_vendor_site_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_VENDOR_SITE'),
                   'VENDOR_SITE_ID',
                   p_vendor_site_id_tbl(i),
                   'COLUMN_NAME',
                   'VENDOR_SITE_ID',
                   'VALUE',
                   p_vendor_site_id_tbl(i),
                   DECODE(p_vendor_site_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_vendor_site_not_null,
                          PO_VAL_CONSTANTS.c_vendor_site_valid)
              FROM DUAL
-- << 8913559 bug >>
 WHERE p_vendor_id_tbl(i) IS NOT NULL
               AND (  p_vendor_site_id_tbl(i) IS NULL   AND p_type_lookup_code_tbl(i) <> 'QUOTATION'  )
                    OR ( p_vendor_site_id_tbl(i) IS NOT NULL
                        AND
                        NOT EXISTS(SELECT 1
                                    FROM po_supplier_sites_val_v pssv
                                   WHERE p_vendor_id_tbl(i) = pssv.vendor_id
                                     AND p_vendor_site_id_tbl(i) = pssv.vendor_site_id));


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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_VDR_CNTCT',
                   'VENDOR_CONTACT_ID',
                   p_vendor_contact_id_tbl(i),
                   'VALUE',
                   p_vendor_contact_id_tbl(i),
                   PO_VAL_CONSTANTS.c_vendor_contact_valid
              FROM DUAL
             WHERE p_vendor_id_tbl(i) IS NOT NULL
               AND p_vendor_site_id_tbl(i) IS NOT NULL
               AND p_vendor_contact_id_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                                FROM po_vendor_contacts pvc
                               WHERE p_vendor_site_id_tbl(i) = pvc.vendor_site_id
                                 AND p_vendor_contact_id_tbl(i) = pvc.vendor_contact_id);

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF (p_federal_instance = 'Y') THEN
         FOR i IN 1 .. p_id_tbl.COUNT LOOP
            BEGIN
               fv_ccr_grp.fv_ccr_reg_status(p_api_version         => 1.0,
                                            p_init_msg_list       => 'F',
                                            p_vendor_site_id      => p_vendor_site_id_tbl(i),
                                            x_return_status       => l_return_status,
                                            x_msg_count           => l_msg_count,
                                            x_msg_data            => l_msg_data,
                                            x_ccr_status          => l_ccr_status,
                                            x_error_code          => l_error_code);

               -- (1) return status is error and vendor site is not exempt from CCR;
               IF    (l_return_status = fnd_api.g_ret_sts_error AND l_error_code <> g_site_not_ccr_site)
                  OR
                     -- (2) return status is success but registration status is not ACTIVE;
                     (l_return_status = fnd_api.g_ret_sts_success AND l_ccr_status <> g_site_reg_active)
                  OR
                     -- (3) return status is unexpected error
                     (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
                  x_results.add_result(p_entity_type       => c_entity_type_header,
                                       p_entity_id         => p_id_tbl(i),
                                       p_column_name       => 'VENDOR_SITE_ID',
                                       p_column_val        => p_vendor_site_id_tbl(i),
                                       p_message_name      => 'PO_PDOI_VENDOR_SITE_CCR_INV',
                                       p_token1_name       => 'VENDOR_SITE_ID',
                                       p_token1_value      => p_vendor_site_id_tbl(i),
                                       p_token2_name       => 'VENDOR_ID',
                                       p_token2_value      => p_vendor_id_tbl(i),
                     p_validation_id     => PO_VAL_CONSTANTS.c_vendor_site_ccr_valid);
                  x_result_type := po_validations.c_result_type_failure;
               END IF;
            END;
         END LOOP;
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
   END vendor_info;

-------------------------------------------------------------------------
-- ShipToLocationId must not be null and valid in HR_LOCATIONS.
-------------------------------------------------------------------------
   PROCEDURE ship_to_location_id(
      p_id_tbl                    IN              po_tbl_number,
      p_ship_to_location_id_tbl   IN              po_tbl_number,
      -- Bug 7007502: Added new param p_type_lookup_code_tbl
      p_type_lookup_code_tbl      IN              po_tbl_varchar30,
      x_result_set_id             IN OUT NOCOPY   NUMBER,
      x_result_type               OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_ship_to_location_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_ship_to_location_id_tbl', p_ship_to_location_id_tbl);
         po_log.proc_begin(d_mod, 'p_type_lookup_code_tbl', p_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- validate ship_to_location_id is not null (for PO and BPA) and valid in HR_LOCATIONS
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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_ship_to_location_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_SHIP_LOC_ID'),
                   'SHIP_TO_LOCATION_ID',
                   p_ship_to_location_id_tbl(i),
                   'COLUMN_NAME',
                   'SHIP_TO_LOCATION_ID',
                   'VALUE',
                   p_ship_to_location_id_tbl(i),
                   DECODE(p_ship_to_location_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_ship_to_location_id_not_null,
                          PO_VAL_CONSTANTS.c_ship_to_location_id_valid)
             FROM DUAL
             WHERE (p_ship_to_location_id_tbl(i) IS NULL
                    -- Bug 7007502: Allow bill_to_loc to be NULL for Quotations.
                    AND p_type_lookup_code_tbl(i) <> 'QUOTATION')
                OR (p_ship_to_location_id_tbl(i) IS NOT NULL
                    AND NOT EXISTS(
                      SELECT 1
                        FROM hr_locations hrl
                       WHERE hrl.ship_to_site_flag = 'Y'
                         AND p_ship_to_location_id_tbl(i) = hrl.location_id
                         AND SYSDATE < NVL(hrl.inactive_date, SYSDATE + 1)));

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
   END ship_to_location_id;

-------------------------------------------------------------------------
-- BillToLocationId must not be null and validate against HR_LOCATIONS.
-------------------------------------------------------------------------
   PROCEDURE bill_to_location_id(
      p_id_tbl                    IN              po_tbl_number,
      p_bill_to_location_id_tbl   IN              po_tbl_number,
      -- Bug 7007502: Added new param p_type_lookup_code_tbl
      p_type_lookup_code_tbl      IN              po_tbl_varchar30,
      x_result_set_id             IN OUT NOCOPY   NUMBER,
      x_result_type               OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_bill_to_location_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_bill_to_location_id_tbl', p_bill_to_location_id_tbl);
         po_log.proc_begin(d_mod, 'p_type_lookup_code_tbl', p_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- validate bill_to_location_id is not null (for PO and BPA) and valid in HR_LOCATIONS
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
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   DECODE(p_bill_to_location_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_BILL_LOC_ID'),
                   'BILL_TO_LOCATION_ID',
                   p_bill_to_location_id_tbl(i),
                   'COLUMN_NAME',
                   'BILL_TO_LOCATION_ID',
                   'VALUE',
                   p_bill_to_location_id_tbl(i),
                   DECODE(p_bill_to_location_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_bill_to_location_id_not_null,
                          PO_VAL_CONSTANTS.c_bill_to_location_id_valid)
             FROM DUAL
             WHERE (p_bill_to_location_id_tbl(i) IS NULL
                    -- Bug 7007502: Allow bill_to_loc to be NULL for Quotations.
                    AND p_type_lookup_code_tbl(i) <> 'QUOTATION')
                OR (p_bill_to_location_id_tbl(i) IS NOT NULL
                    AND NOT EXISTS(
                      SELECT 1
                        FROM hr_locations hrl
                       WHERE hrl.bill_to_site_flag = 'Y'
                         AND p_bill_to_location_id_tbl(i) = hrl.location_id
                         AND SYSDATE < NVL(hrl.inactive_date, SYSDATE + 1)));

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
   END bill_to_location_id;

-------------------------------------------------------------------------
-- validate ship_via_lookup_code against ORG_FREIGHT
-------------------------------------------------------------------------
   PROCEDURE ship_via_lookup_code(
      p_id_tbl                     IN              po_tbl_number,
      p_ship_via_lookup_code_tbl   IN              po_tbl_varchar30,
      p_inventory_org_id           IN              NUMBER,
      x_result_set_id              IN OUT NOCOPY   NUMBER,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_ship_via_lookup_code;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_ship_via_lookup_code_tbl', p_ship_via_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FREIGHT_CARR',
                   'SHIP_VIA_LOOKUP_CODE',
                   p_ship_via_lookup_code_tbl(i),
                   'VALUE',
                   p_ship_via_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_ship_via_lookup_code
              FROM DUAL
             WHERE p_ship_via_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM org_freight ofr
                       WHERE p_ship_via_lookup_code_tbl(i) = ofr.freight_code
                         AND NVL(ofr.disable_date, SYSDATE + 1) > SYSDATE
                         AND ofr.organization_id = p_inventory_org_id);

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
   END ship_via_lookup_code;

-------------------------------------------------------------------------
-- validate fob_lookup_code against PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE fob_lookup_code(
      p_id_tbl                IN              po_tbl_number,
      p_fob_lookup_code_tbl   IN              po_tbl_varchar30,
      x_result_set_id         IN OUT NOCOPY   NUMBER,
      x_result_type           OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_fob_lookup_code;
   BEGIN
      IF (x_result_set_id IS NULL) THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_fob_lookup_code_tbl', p_fob_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FOB',
                   'FOB_LOOKUP_CODE',
                   p_fob_lookup_code_tbl(i),
                   'VALUE',
                   p_fob_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_fob_lookup_code
              FROM DUAL
             WHERE p_fob_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM po_lookup_codes plc
                       WHERE p_fob_lookup_code_tbl(i) = plc.lookup_code
                         AND plc.lookup_type = 'FOB'
                         AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1));

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
   END fob_lookup_code;

-------------------------------------------------------------------------
-- validate freight_terms_lookup_code against PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE freight_terms_lookup_code(
      p_id_tbl                     IN              po_tbl_number,
      p_freight_terms_lookup_tbl   IN              po_tbl_varchar30,
      x_result_set_id              IN OUT NOCOPY   NUMBER,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_freight_terms_lookup_code;
   BEGIN
      IF (x_result_set_id IS NULL) THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_freight_terms_lookup_tbl', p_freight_terms_lookup_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_FREIGHT_TERMS',
                   'FREIGHT_TERMS_LOOKUP_CODE',
                   p_freight_terms_lookup_tbl(i),
                   'VALUE',
                   p_freight_terms_lookup_tbl(i),
                   PO_VAL_CONSTANTS.c_freight_terms_lookup_code
              FROM DUAL
             WHERE p_freight_terms_lookup_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM po_lookup_codes plc
                       WHERE p_freight_terms_lookup_tbl(i) = plc.lookup_code
                         AND plc.lookup_type = 'FREIGHT TERMS'
                         AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1));

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
   END freight_terms_lookup_code;

-------------------------------------------------------------------------
-- validate shipping_control against PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE shipping_control(
      p_id_tbl                 IN              po_tbl_number,
      p_shipping_control_tbl   IN              po_tbl_varchar30,
      x_result_set_id          IN OUT NOCOPY   NUMBER,
      x_result_type            OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_shipping_control;
   BEGIN
      IF (x_result_set_id IS NULL) THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_shipping_control_tbl', p_shipping_control_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_SHIPPING_CTRL',
                   'SHIPPING_CONTROL',
                   p_shipping_control_tbl(i),
                   'VALUE',
                   p_shipping_control_tbl(i),
                   PO_VAL_CONSTANTS.c_shipping_control
              FROM DUAL
             WHERE p_shipping_control_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM po_lookup_codes plc
                       WHERE p_shipping_control_tbl(i) = plc.lookup_code
                         AND plc.lookup_type = 'SHIPPING CONTROL'
                         AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1));

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
   END shipping_control;

-------------------------------------------------------------------------
-- validate acceptance_due_date is not null if acceptance_required_flag = Y.
-- Only called for Blanket and SPO.
-------------------------------------------------------------------------
   PROCEDURE acceptance_due_date(
      p_id_tbl                     IN              po_tbl_number,
      p_acceptance_reqd_flag_tbl   IN              po_tbl_varchar1,
      p_acceptance_due_date_tbl    IN              po_tbl_date,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_acceptance_due_date;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_acceptance_due_date_tbl', p_acceptance_due_date_tbl);
         po_log.proc_begin(d_mod, 'p_acceptance_reqd_flag_tbl', p_acceptance_reqd_flag_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- Bug6601134(obsoleted 4467491)
      /*FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_acceptance_reqd_flag_tbl(i) = 'Y' AND p_acceptance_due_date_tbl(i) IS NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'ACCEPTANCE_DUE_DATE',
                                 p_column_val        => p_acceptance_due_date_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'ACCEPTANCE_DUE_DATE',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_acceptance_due_date_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_acceptance_due_date);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;*/

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
   END acceptance_due_date;

-------------------------------------------------------------------------
-- validate cancel_flag = N.  Only called for Blanket and SPO.
-------------------------------------------------------------------------
   PROCEDURE cancel_flag(
      p_id_tbl            IN              po_tbl_number,
      p_cancel_flag_tbl   IN              po_tbl_varchar1,
      x_results           IN OUT NOCOPY   po_validation_results_type,
      x_result_type       OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_cancel_flag;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_cancel_flag_tbl', p_cancel_flag_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_cancel_flag_tbl(i) <> 'N' THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'CANCEL_FLAG',
                                 p_column_val        => p_cancel_flag_tbl(i),
                                 p_message_name      => 'PO_PDOI_INVALID_VALUE',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'CANCEL_FLAG',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_cancel_flag_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_cancel_flag);

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
   END cancel_flag;

-------------------------------------------------------------------------
-- validate closed_code = OPEN.  Only called for Blanket and SPO.
-------------------------------------------------------------------------
   PROCEDURE closed_code(
      p_id_tbl                     IN              po_tbl_number,
      p_closed_code_tbl            IN              po_tbl_varchar30,
      p_acceptance_reqd_flag_tbl   IN              po_tbl_varchar1,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_closed_code;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_closed_code_tbl', p_closed_code_tbl);
         po_log.proc_begin(d_mod, 'p_acceptance_reqd_flag_tbl', p_acceptance_reqd_flag_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_acceptance_reqd_flag_tbl(i) ='Y' AND p_closed_code_tbl(i) <> 'OPEN' THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'CLOSED_CODE',
                                 p_column_val        => p_closed_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_INVALID_VALUE',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'CLOSED_CODE',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_closed_code_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_closed_code);

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
   END closed_code;

-------------------------------------------------------------------------
-- validate print_count = 0.  Only called for Blanket and SPO.
-------------------------------------------------------------------------
   PROCEDURE print_count(
      p_id_tbl                     IN              po_tbl_number,
      p_print_count_tbl            IN              po_tbl_number,
      p_approval_status_tbl        IN              po_tbl_varchar30,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_print_count;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_print_count_tbl', p_print_count_tbl);
         po_log.proc_begin(d_mod, 'p_approval_status_tbl', p_approval_status_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_approval_status_tbl(i) <> 'APPROVED' AND p_print_count_tbl(i) <> 0 THEN
            x_results.add_result(p_entity_type   => c_entity_type_header,
                                 p_entity_id     => p_id_tbl(i),
                                 p_column_name   => 'PRINT_COUNT',
                                 p_column_val    => p_print_count_tbl(i),
                                 p_message_name  => 'PO_PDOI_INVALID_VALUE',
                                 p_token1_name   => 'COLUMN_NAME',
                                 p_token1_value  => 'PRINT COUNT',
                                 p_token2_name   => 'VALUE',
                                 p_token2_value  => 0,
                 p_validation_id => PO_VAL_CONSTANTS.c_print_count);
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
   END print_count;

-------------------------------------------------------------------------
-- validate approval_status = INCOMPLETE, APPROVED, INITIATE APPROVAL.
-- Only called for Blanket and SPO.
-------------------------------------------------------------------------
   PROCEDURE approval_status(
      p_id_tbl                     IN              po_tbl_number,
      p_approval_status_tbl        IN              po_tbl_varchar30,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_approval_status;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_approval_status_tbl', p_approval_status_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_approval_status_tbl(i) NOT IN('APPROVED', 'INCOMPLETE', 'INITIATE APPROVAL') THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'APPROVAL_STATUS',
                                 p_column_val        => p_approval_status_tbl(i),
                                 p_message_name      => 'PO_PDOI_INVALID_STATUS',
                 p_validation_id     => PO_VAL_CONSTANTS.c_approval_status);
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
   END approval_status;

-------------------------------------------------------------------------
-- validate amount_to_encumber > 0
-------------------------------------------------------------------------
   PROCEDURE amount_to_encumber(
      p_id_tbl                   IN              po_tbl_number,
      p_amount_to_encumber_tbl   IN              po_tbl_number,
      x_results                  IN OUT NOCOPY   po_validation_results_type,
      x_result_type              OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_amount_to_encumber;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_amount_to_encumber_tbl', p_amount_to_encumber_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_amount_to_encumber_tbl(i) <= 0 THEN
            x_results.add_result(p_entity_type       => c_entity_type_header,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT_TO_ENCUMBER',
                                 p_column_val        => p_amount_to_encumber_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'AMOUNT_TO_ENCUMBER',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_amount_to_encumber_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_amount_to_encumber);
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
   END amount_to_encumber;

-------------------------------------------------------------------------------------
-- Validate style_id exists in system, is active and is not enabled for complex work.
-------------------------------------------------------------------------------------
   PROCEDURE style_id(
      p_id_tbl                       IN              po_tbl_number,
      p_style_id_tbl                 IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_style_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- validate that the style_id exists in the system and the status is ACTIVE.
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_STYLE_ID',
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   PO_VAL_CONSTANTS.c_style_id_valid
              FROM DUAL
             WHERE NOT EXISTS(SELECT 1
                              FROM  po_doc_style_headers pdsh
                              WHERE pdsh.style_id = p_style_id_tbl(i) AND
                                    pdsh.status = 'ACTIVE');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

  /* PDOI for Complex PO Project: Allow Complex PO styles:
      -- validate that complex work is not enabled
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
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   p_id_tbl(i),
                   'PO_PDOI_COMPLEX_WORK_STYLE',
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   PO_VAL_CONSTANTS.c_style_id_complex_work
              FROM DUAL
             WHERE EXISTS(SELECT 1
                          FROM   po_doc_style_headers pdsh
                          WHERE  pdsh.style_id = p_style_id_tbl(i) AND
                                 pdsh.progress_payment_flag = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;  */

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

   END style_id;

   -- bug4911388 START
  -------------------------------------------------------------------------
  -- validate that acceptance_reuqired_flag has correct value
  -------------------------------------------------------------------------
   PROCEDURE acceptance_required_flag
   ( p_id_tbl IN PO_TBL_NUMBER,
     p_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
     p_acceptance_required_flag_tbl IN PO_TBL_VARCHAR1,
     x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
     x_result_type OUT NOCOPY VARCHAR2
   )
   IS

    d_mod CONSTANT VARCHAR2(100) := d_acceptance_required_flag;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1..p_id_tbl.COUNT LOOP

        IF (p_type_lookup_code_tbl(i) = 'QUOTATION') THEN

          IF ( NVL(p_acceptance_required_flag_tbl(i), 'N') <> 'N') THEN

            x_results.add_result
            ( p_entity_type   => c_entity_type_header,
              p_entity_id     => p_id_tbl(i),
              p_column_name   => 'ACCEPTANCE_REQUIRED_FLAG',
              p_column_val    => p_acceptance_required_flag_tbl(i),
              p_message_name  => 'PO_PDOI_COLUMN_NULL',
              p_token1_name   => 'COLUMN_NAME',
              p_token1_value  => 'ACCEPTANCE_REQUIRED_FLAG',
              p_token2_name   => 'VALUE',
              p_token2_value  => p_acceptance_required_flag_tbl(i),
              p_validation_id => PO_VAL_CONSTANTS.c_acceptance_required_flag
            );

            x_result_type := po_validations.c_result_type_failure;
          END IF;

        ELSE

          IF (p_acceptance_required_flag_tbl(i) NOT IN ('N', 'Y', 'D', 'S')) THEN

            x_results.add_result
            ( p_entity_type   => c_entity_type_header,
              p_entity_id     => p_id_tbl(i),
              p_column_name   => 'ACCEPTANCE_REQUIRED_FLAG',
              p_column_val    => p_acceptance_required_flag_tbl(i),
              p_message_name  => 'PO_PDOI_INVALID_ACC_REQD_FLAG',
              p_validation_id => PO_VAL_CONSTANTS.c_acceptance_required_flag
            );

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
   END acceptance_required_flag;

   -- bug4911388 END


  -- bug5352625

  -------------------------------------------------------------------------
  -- validate that amount limit is valid
  -------------------------------------------------------------------------
   PROCEDURE amount_limit
   ( p_id_tbl IN PO_TBL_NUMBER,
     p_amount_limit_tbl IN PO_TBL_NUMBER,
     p_amount_agreed_tbl IN PO_TBL_NUMBER,
     x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
     x_result_type OUT NOCOPY VARCHAR2
   ) IS
     d_mod CONSTANT VARCHAR2(100) := d_amount_limit;
   BEGIN

     IF (x_results IS NULL) THEN
       x_results := po_validation_results_type.new_instance();
     END IF;

     x_result_type := po_validations.c_result_type_success;



     PO_VALIDATION_HELPER.greater_or_equal_zero
     ( p_calling_module     => d_mod,
       p_null_allowed_flag  => PO_CORE_S.g_parameter_YES,
       p_value_tbl          => p_amount_limit_tbl,
       p_entity_id_tbl      => p_id_tbl,
       p_entity_type        => c_entity_type_header,
       p_column_name        => 'AMOUNT_LIMIT',
       p_message_name       => 'PO_PDOI_LT_ZERO',
       p_token1_name        => 'COLUMN_NAME',
       p_token1_value       => 'AMOUNT_LIMIT',
       p_token2_name        => 'VALUE',
       p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_amount_limit_tbl),
       p_validation_id      => PO_VAL_CONSTANTS.c_amount_limit_gt_zero,
       x_results            => x_results,
       x_result_type        => x_result_type
     );


     FOR i IN 1..p_id_tbl.COUNT LOOP

       -- Amount agreed has to be populated if amount limit is populated
       IF (p_amount_limit_tbl(i) IS NOT NULL AND
           p_amount_agreed_tbl(i) IS NULL) THEN

         x_results.add_result
         ( p_entity_type => c_entity_type_HEADER,
           p_entity_id => p_id_tbl(i),
           p_column_name => 'AMOUNT_AGREED',
           p_column_val => p_amount_agreed_tbl(i),
           p_message_name => PO_MESSAGE_S.PO_AMT_LMT_NOT_NULL,
           p_validation_id => PO_VAL_CONSTANTS.c_amount_agreed_not_null
         );


         x_result_type := po_validations.c_result_type_failure;
       END IF;

       IF ( p_amount_limit_tbl(i) < p_amount_agreed_tbl(i) ) THEN

         x_results.add_result
         ( p_entity_type => c_entity_type_HEADER,
           p_entity_id => p_id_tbl(i),
           p_column_name => 'AMOUNT_LIMIT',
           p_column_val => p_amount_limit_tbl(i),
           p_message_name => PO_MESSAGE_S.PO_PO_AMT_LIMIT_CK_FAILED,
           p_validation_id => PO_VAL_CONSTANTS.c_amount_limit_gt_amt_agreed
         );

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
   END amount_limit;



END PO_VAL_HEADERS2;

/
