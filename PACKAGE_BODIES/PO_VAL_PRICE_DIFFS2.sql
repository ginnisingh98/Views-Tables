--------------------------------------------------------
--  DDL for Package Body PO_VAL_PRICE_DIFFS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_PRICE_DIFFS2" AS
  -- $Header: PO_VAL_PRICE_DIFFS2.plb 120.8 2006/08/02 23:14:51 jinwang noship $
  c_entity_type_price_diff CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_PRICE_DIFF;
  -- The module base for this package.
  d_package_base CONSTANT VARCHAR2(50) := po_log.get_package_base('PO_VAL_PRICE_DIFFS2');

  -- The module base for the subprogram.
  d_price_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_TYPE');
  d_multiple_price_diff CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'MULTIPLE_PRICE_DIFF');
  d_entity_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ENTITY_TYPE');
  d_multiplier CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'MULTIPLIER');
  d_min_multiplier CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'MIN_MULTIPLIER');
  d_max_multiplier CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'MAX_MULTIPLIER');
  d_style_related_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'STYLE_RELATED_INFO');

  -- Indicates that the calling program is PDOI.
  c_program_pdoi CONSTANT VARCHAR2(10) := 'PDOI';
  -- The application name of PO.
  c_po CONSTANT VARCHAR2(2) := 'PO';

-------------------------------------------------------------------------
-- Price type cannot be NULL and must be valid in PO_PRICE_DIFF_LOOKUPS_V
-------------------------------------------------------------------------
  PROCEDURE price_type(
    p_id_tbl           IN              po_tbl_number,
    p_price_type_tbl   IN              po_tbl_varchar30,
    x_result_set_id    IN OUT NOCOPY   NUMBER,
    x_result_type      OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_price_type;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_price_type_tbl', p_price_type_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    -- Price type cannot be Null and must be valid in PO_PRICE_DIFF_LOOKUPS_V
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
               c_entity_type_price_diff,
               p_id_tbl(i),
               DECODE(p_price_type_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_SVC_INVALID_PRICE_TYPE'),
               'PRICE_TYPE',
               p_price_type_tbl(i),
               'PRICE_TYPE',
               p_price_type_tbl(i),
               DECODE(p_price_type_tbl(i), NULL, PO_VAL_CONSTANTS.c_price_type_not_null,
                      PO_VAL_CONSTANTS.c_price_type_valid)
          FROM DUAL
         WHERE p_price_type_tbl(i) IS NULL
               OR(p_price_type_tbl(i) IS NOT NULL AND
               NOT EXISTS(SELECT 1
                          FROM po_price_diff_lookups_v
                          WHERE price_differential_type = p_price_type_tbl(i)));

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
  END price_type;

-------------------------------------------------------------------------
-- Multiple price differential records of the same type for a line/price break record are not allowed.
-------------------------------------------------------------------------
  PROCEDURE multiple_price_diff(
    p_id_tbl            IN              po_tbl_number,
    p_price_type_tbl    IN              po_tbl_varchar30,
    p_entity_type_tbl   IN              po_tbl_varchar30,
    p_entity_id_tbl     IN              PO_TBL_NUMBER,
    x_result_set_id     IN OUT NOCOPY   NUMBER,
    x_result_type       OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_multiple_price_diff;
    l_gt_key NUMBER;
  BEGIN
    IF x_result_set_id IS NULL THEN
      x_result_set_id := po_validations.next_result_set_id();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_price_type_tbl', p_price_type_tbl);
      po_log.proc_begin(d_mod, 'p_entity_type_tbl', p_entity_type_tbl);
      po_log.proc_begin(d_mod, 'p_entity_id_tbl', p_entity_id_tbl);
      po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
    END IF;

    l_gt_key := PO_CORE_S.get_session_gt_nextval();
    -- insert the data in current group into temp table for comparason
    FORALL i IN 1..p_id_tbl.COUNT
      INSERT INTO po_session_gt
                  (key,
                   num1,
                   index_num1,
                   char1,
                   char2)
      SELECT l_gt_key,
             p_id_tbl(i),
             p_entity_id_tbl(i),
             p_entity_type_tbl(i),
             p_price_type_tbl(i)
      FROM   DUAL;

    -- Check that we are not creating multiple price differential
    -- records of the same type for a line/price break record against
    -- txn table or draft table or records within the same group
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
               c_entity_type_price_diff,
               p_id_tbl(i),
               'PO_PDOI_SVC_NO_MULTI_DIFF',
               'PRICE_TYPE',
               p_price_type_tbl(i),
               NULL,
               NULL,
               PO_VAL_CONSTANTS.c_multiple_price_diff
          FROM DUAL
         WHERE p_price_type_tbl(i) IS NOT NULL
           AND p_entity_type_tbl(i) IS NOT NULL
           AND p_entity_id_tbl(i) IS NOT NULL
           AND (EXISTS(SELECT 1
                       FROM po_price_differentials
                       WHERE entity_id = p_entity_id_tbl(i)
                         AND entity_type = p_entity_type_tbl(i)
                         AND price_type = p_price_type_tbl(i))
                OR
                EXISTS(SELECT 1
                       FROM po_price_diff_draft
                      WHERE entity_id = p_entity_id_tbl(i)
                        AND entity_type = p_entity_type_tbl(i)
                        AND price_type = p_price_type_tbl(i))
                OR
                EXISTS(SELECT 1
                       FROM po_session_gt
                      WHERE key = l_gt_key
                        AND num1 < p_id_tbl(i)
                        AND index_num1 = p_entity_id_tbl(i)
                        AND char1 = p_entity_type_tbl(i)
                        AND char2 = p_price_type_tbl(i)));

    -- remove the records from temp table
    DELETE FROM po_session_gt
    WHERE key = l_gt_key;

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

  END multiple_price_diff;

-------------------------------------------------------------------------
-- Validate price differential is tied to a valid entity type for
-- different document type
-------------------------------------------------------------------------
  PROCEDURE entity_type(
    p_id_tbl            IN              po_tbl_number,
    p_entity_type_tbl   IN              po_tbl_varchar30,
    p_doc_type          IN              VARCHAR2,
    x_results           IN OUT NOCOPY   po_validation_results_type,
    x_result_type       OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_entity_type;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_entity_type_tbl', p_entity_type_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    -- bug 4700377
    -- validate entity_type value based on document types
    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF ((p_doc_type = 'BLANKET' AND p_entity_type_tbl(i) NOT IN('BLANKET LINE', 'PRICE BREAK'))
          OR
          (p_doc_type = 'STANDARD' AND p_entity_type_tbl(i) <> 'PO LINE')) THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'ENTITY_TYPE',
                             p_column_val       => p_entity_type_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_INVALID_ENT_TYPE',
				     p_validation_id    => PO_VAL_CONSTANTS.c_entity_type);
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
  END entity_type;

-------------------------------------------------------------------------
-- If the entity type is PO LINE, the multiplier column must not be null.
-- If the entity type is BLANKET LINE or PRICE BREAK, the multiplier column
-- must be null.
-------------------------------------------------------------------------
  PROCEDURE multiplier(
    p_id_tbl            IN              po_tbl_number,
    p_entity_type_tbl   IN              po_tbl_varchar30,
    p_multiplier_tbl    IN              po_tbl_number,
    x_results           IN OUT NOCOPY   po_validation_results_type,
    x_result_type       OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_multiplier;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_entity_type_tbl', p_entity_type_tbl);
      po_log.proc_begin(d_mod, 'p_multiplier_tbl', p_multiplier_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_entity_type_tbl(i) = 'PO LINE' AND p_multiplier_tbl(i) IS NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'MUTLIPLIER',
                             p_column_val       => p_multiplier_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_MUST_MULTIPLIER',
							 p_validation_id    => PO_VAL_CONSTANTS.c_multiplier_not_null);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF p_entity_type_tbl(i) IN('BLANKET LINE', 'PRICE BREAK') AND p_multiplier_tbl(i) IS NOT NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'MULTIPLIER',
                             p_column_val       => p_multiplier_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_NO_MULTIPLIER',
							 p_validation_id    => PO_VAL_CONSTANTS.c_multiplier_null);
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
  END multiplier;

-------------------------------------------------------------------------
-- If the entity type is PO LINE, the min multiplier column must be null.
-- If the entity type is BLANKET LINE or PRICE BREAK, the min multiplier column
-- must not be null.
-------------------------------------------------------------------------
  PROCEDURE min_multiplier(
    p_id_tbl               IN              po_tbl_number,
    p_entity_type_tbl      IN              po_tbl_varchar30,
    p_min_multiplier_tbl   IN              po_tbl_number,
    x_results              IN OUT NOCOPY   po_validation_results_type,
    x_result_type          OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_min_multiplier;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_entity_type_tbl', p_entity_type_tbl);
      po_log.proc_begin(d_mod, 'p_min_multiplier_tbl', p_min_multiplier_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_entity_type_tbl(i) = 'PO LINE' AND p_min_multiplier_tbl(i) IS NOT NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'MIN_MULTIPLIER',
                             p_column_val       => p_min_multiplier_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_NO_MIN_MULT',
				     p_validation_id    => PO_VAL_CONSTANTS.c_min_multiplier_null);
        x_result_type := po_validations.c_result_type_failure;
      ELSIF p_entity_type_tbl(i) IN('BLANKET LINE', 'PRICE BREAK') AND p_min_multiplier_tbl(i) IS NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'MIN_MULTIPLIER',
                             p_column_val       => p_min_multiplier_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_MUST_MIN_MULT',
				     p_validation_id    => PO_VAL_CONSTANTS.c_min_multiplier_not_null);
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
  END min_multiplier;

-------------------------------------------------------------------------
-- If the entity type is PO LINE, the multiplier column must be null.
-- If the entity type is BLANKET LINE or PRICE BREAK, the multiplier column
-- must not be null.
-------------------------------------------------------------------------
  PROCEDURE max_multiplier(
    p_id_tbl               IN              po_tbl_number,
    p_entity_type_tbl      IN              po_tbl_varchar30,
    p_max_multiplier_tbl   IN              po_tbl_number,
    x_results              IN OUT NOCOPY   po_validation_results_type,
    x_result_type          OUT NOCOPY      VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := d_max_multiplier;
  BEGIN
    IF (x_results IS NULL) THEN
      x_results := po_validation_results_type.new_instance();
    END IF;

    x_result_type := po_validations.c_result_type_success;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
      po_log.proc_begin(d_mod, 'p_entity_type_tbl', p_entity_type_tbl);
      po_log.proc_begin(d_mod, 'p_max_multiplier_tbl', p_max_multiplier_tbl);
      po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
    END IF;

    FOR i IN 1 .. p_id_tbl.COUNT LOOP
      IF p_entity_type_tbl(i) = 'PO LINE' AND p_max_multiplier_tbl(i) IS NOT NULL THEN
        x_results.add_result(p_entity_type      => c_entity_type_price_diff,
                             p_entity_id        => p_id_tbl(i),
                             p_column_name      => 'MAX_MULTIPLIER',
                             p_column_val       => p_max_multiplier_tbl(i),
                             p_message_name     => 'PO_PDOI_SVC_NO_MAX_MULT',
				     p_validation_id    => PO_VAL_CONSTANTS.c_max_multiplier_null);
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
  END max_multiplier;

-------------------------------------------------------------------------------------
-- Validate price_differentials_flag = Y for the given style
-------------------------------------------------------------------------------------
   PROCEDURE style_related_info(
      p_id_tbl                       IN              po_tbl_number,
      p_style_id_tbl                 IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_style_related_info;
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

      -- bug5130037
      -- Have NVL() around pdsh.price_differentials_flag
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
                   c_entity_type_price_diff,
                   p_id_tbl(i),
                   'PO_PDOI_PRICE_DIFF_STYLE',
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   PO_VAL_CONSTANTS.c_price_diff_style_info
              FROM DUAL
             WHERE EXISTS(SELECT 1
                          FROM  po_doc_style_headers pdsh
                          WHERE pdsh.style_id = p_style_id_tbl(i) AND
                                NVL(pdsh.price_differentials_flag, 'N') = 'N');

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

  END style_related_info;


END PO_VAL_PRICE_DIFFS2;

/
