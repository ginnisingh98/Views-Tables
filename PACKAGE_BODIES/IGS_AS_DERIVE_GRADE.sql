--------------------------------------------------------
--  DDL for Package Body IGS_AS_DERIVE_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DERIVE_GRADE" AS
/* $Header: IGSAS59B.pls 120.0 2005/07/05 12:58:23 appldev noship $ */
  g_module_head CONSTANT VARCHAR2(40) := 'igs.plsql.igs_as_derive_grade.';
  g_person_id NUMBER(15);
  g_course_cd VARCHAR2(10);
  g_uoo_id NUMBER(15);
  g_mark_grade VARCHAR2(60);
  g_grading_period_cd VARCHAR2(30);
  g_unit_section_submitted BOOLEAN;
  g_attempt VARCHAR2(80) := fnd_message.get_string ('IGS', 'IGS_AS_ASSESSMENT_STATUS');
  --
  -- Function to validate the Grading Schema Mark Range and return an error
  -- message when the mark range is null or has gaps
  --
  FUNCTION validate_grading_schema (
    p_grading_schema_cd            IN VARCHAR2,
    p_version_number               IN NUMBER
  ) RETURN VARCHAR2 IS
    --
    -- Cursor to get the grade and mark range for a given Grading Schema
    --
    CURSOR cur_grading_schema_grades (
             cp_grading_schema_cd IN VARCHAR2,
             cp_version_number IN NUMBER
           ) IS
      SELECT   grade,
               lower_mark_range,
               upper_mark_range
      FROM     igs_as_grd_sch_grade
      WHERE    grading_schema_cd = cp_grading_schema_cd
      AND      version_number = cp_version_number
      AND      s_result_type IN ('FAIL', 'PASS')
      AND      NVL (admin_only_ind, 'N') <> 'Y'
      AND      NVL (closed_ind, 'N') <> 'Y'
      ORDER BY lower_mark_range ASC;
    --
    rec_grading_schema_grades cur_grading_schema_grades%ROWTYPE;
    prev_rec_grading_schema_grades cur_grading_schema_grades%ROWTYPE;
    l_routine VARCHAR2(30) := 'validate_grading_schema';
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_grading_schema_cd=>' || p_grading_schema_cd || ';' ||
        'p_version_number=>' || p_version_number || ';'
      );
    END IF;
    FOR rec_grading_schema_grades IN cur_grading_schema_grades (
                                       p_grading_schema_cd,
                                       p_version_number
                                     ) LOOP
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string (
           fnd_log.level_statement,
           g_module_head || l_routine || '.mark_range',
           'Lower =>' || rec_grading_schema_grades.lower_mark_range ||
           '; Upper =>' || rec_grading_schema_grades.upper_mark_range || ';'
         );
       END IF;
       IF ((rec_grading_schema_grades.lower_mark_range IS NULL) OR
           (rec_grading_schema_grades.upper_mark_range IS NULL)) THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string (
             fnd_log.level_statement,
             g_module_head || l_routine || '.mark_range_null',
             'Mark Range is NULL'
           );
         END IF;
         RETURN 'IGS_AS_US_GRD_SCH_HAS_NO_MARKS';
       ELSIF NOT ((rec_grading_schema_grades.lower_mark_range -
                   prev_rec_grading_schema_grades.upper_mark_range > 0) AND
                  (rec_grading_schema_grades.lower_mark_range -
                   prev_rec_grading_schema_grades.upper_mark_range <= 1)) THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string (
             fnd_log.level_statement,
             g_module_head || l_routine || '.lower_upper_mark_gap',
             'Gap Between Lower mark Of Current Range And Upper Mark Of Previous Range'
           );
         END IF;
         RETURN 'IGS_AS_US_GRD_SCH_HAS_NO_MARKS';
       END IF;
       prev_rec_grading_schema_grades := rec_grading_schema_grades;
    END LOOP;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    RETURN NULL;
  END validate_grading_schema;
  --
  -- Procedure to validate the Assessment Item and Unit Section Grading Schema's
  -- mark range and return an error message in case mark range has null values
  -- or gaps
  --
  PROCEDURE validate_ai_us_grd_mark_range (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_unit_cd                      IN VARCHAR2,
    p_usec_grading_schema          IN VARCHAR2,
    p_usec_grading_schema_version  IN NUMBER,
    p_validate_ai_grd_schema       IN VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) IS
    --
    -- Cursor to get the default Grading Schema for the Unit Section
    --
    CURSOR cur_usec_dflt_grading_schema (
             cp_uoo_id IN NUMBER
           ) IS
      SELECT   grading_schema_code,
               grd_schm_version_number
      FROM     igs_ps_usec_grd_schm
      WHERE    uoo_id = cp_uoo_id
      AND      default_flag = 'Y';
    --
    -- Cursor to get the default Grading Schema for the Unit if default Grading
    -- Schema for the Unit Section is not setup
    --
    CURSOR cur_unit_dflt_grading_schema (
             cp_uoo_id IN NUMBER
           ) IS
      SELECT   ugs.grading_schema_code,
               ugs.grd_schm_version_number
      FROM     igs_ps_unit_grd_schm ugs,
               igs_ps_unit_ofr_opt_all uoo
      WHERE    uoo.uoo_id = cp_uoo_id
      AND      ugs.unit_code = uoo.unit_cd
      AND      ugs.unit_version_number = uoo.version_number
      AND      ugs.default_flag = 'Y';
    --
    -- Cursor to get the Active Student Unit Attempt Assessment Items
    --
    CURSOR cur_sua_ai (
             cp_person_id IN NUMBER,
             cp_course_cd IN VARCHAR2,
             cp_uoo_id IN NUMBER
           ) IS
      SELECT   DISTINCT grading_schema_cd,
               gs_version_number
      FROM     igs_as_su_atmpt_itm
      WHERE    person_id = cp_person_id
      AND      course_cd = cp_course_cd
      AND      uoo_id = cp_uoo_id
      AND      logical_delete_dt IS NULL
      AND      grading_schema_cd IS NOT NULL;
    --
    -- Get the Assessment ID and Reference and return them to the calling program
    --
    CURSOR cur_sua_ai_failing (
             cp_person_id IN NUMBER,
             cp_course_cd IN VARCHAR2,
             cp_uoo_id IN NUMBER,
             cp_grading_schema_cd IN VARCHAR2,
             cp_gs_version_number IN NUMBER
           ) IS
      SELECT   suai.ass_id ass_id,
               suai.unit_ass_item_id,
               suai.unit_section_ass_item_id
      FROM     igs_as_su_atmpt_itm suai
      WHERE    suai.person_id = cp_person_id
      AND      suai.course_cd = cp_course_cd
      AND      suai.uoo_id = cp_uoo_id
      AND      suai.grading_schema_cd = cp_grading_schema_cd
      AND      suai.gs_version_number = cp_gs_version_number;
    --
    -- Get Unit Assessment Item Reference
    --
    CURSOR cur_uai_reference (
             cp_unit_ass_item_id IN NUMBER
           ) IS
      SELECT uai.reference
      FROM   igs_as_unitass_item_all uai
      WHERE  uai.unit_ass_item_id = cp_unit_ass_item_id;
    --
    -- Get Unit Section Assessment Item Reference
    --
    CURSOR cur_usai_reference (
             cp_unit_section_ass_item_id IN NUMBER
           ) IS
      SELECT usai.reference
      FROM   igs_ps_unitass_item usai
      WHERE  usai.unit_section_ass_item_id = cp_unit_section_ass_item_id;
    --
    rec_usec_dflt_grading_schema cur_usec_dflt_grading_schema%ROWTYPE;
    l_routine CONSTANT VARCHAR2(30) := 'validate_ai_us_grd_mark_range';
    rec_sua_ai_failing cur_sua_ai_failing%ROWTYPE;
    rec_uai_reference cur_uai_reference%ROWTYPE;
    rec_usai_reference cur_usai_reference%ROWTYPE;
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_unit_cd=>' || p_unit_cd || ';' ||
        'p_usec_grading_schema=>' || p_usec_grading_schema || ';' ||
        'p_usec_grading_schema_version=>' || p_usec_grading_schema_version || ';' ||
        'p_validate_ai_grd_schema=>' || p_validate_ai_grd_schema || ';'
      );
    END IF;
    --
    -- Identify the default Grading Schema for the Unit Section
    --
    IF (p_usec_grading_schema IS NULL) THEN
      OPEN cur_usec_dflt_grading_schema (p_uoo_id);
      FETCH cur_usec_dflt_grading_schema INTO rec_usec_dflt_grading_schema;
      IF (cur_usec_dflt_grading_schema%NOTFOUND) THEN
        CLOSE cur_usec_dflt_grading_schema;
        OPEN cur_unit_dflt_grading_schema (p_uoo_id);
        FETCH cur_unit_dflt_grading_schema INTO rec_usec_dflt_grading_schema;
        CLOSE cur_unit_dflt_grading_schema;
      ELSE
        CLOSE cur_usec_dflt_grading_schema;
      END IF;
    ELSE
      rec_usec_dflt_grading_schema.grading_schema_code := p_usec_grading_schema;
      rec_usec_dflt_grading_schema.grd_schm_version_number := p_usec_grading_schema_version;
    END IF;
    --
    -- Check that the mark ranges for the default Unit Section Grading Schema
    -- are NOT NULL. And also check that there is no gap of marks in the Grading
    -- Schema.
    --
    p_message_name := validate_grading_schema (
                        rec_usec_dflt_grading_schema.grading_schema_code,
                        rec_usec_dflt_grading_schema.grd_schm_version_number
                      );
    IF (p_message_name IS NOT NULL) THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.dflt_grd_sch_for_uoo_id',
          'Default Unit Section Grading Schema has gaps/invalid range'
        );
      END IF;
      RETURN;
    END IF;
    --
    -- For all the grading schemas set for the Assessment Items attached to the
    -- Student Unit Attempt check if the mark ranges are NOT NULL. And also
    -- check that there is no gap of marks in the Grading Schema.
    --
    IF (p_validate_ai_grd_schema = 'Y') THEN
      FOR rec_sua_ai IN cur_sua_ai (
                          p_person_id,
                          p_course_cd,
                          p_uoo_id
                        ) LOOP
        p_message_name := validate_grading_schema (
                            rec_sua_ai.grading_schema_cd,
                            rec_sua_ai.gs_version_number
                          );
        IF (p_message_name IS NOT NULL) THEN
          OPEN cur_sua_ai_failing (
                 p_person_id,
                 p_course_cd,
                 p_uoo_id,
                 rec_sua_ai.grading_schema_cd,
                 rec_sua_ai.gs_version_number
               );
          FETCH cur_sua_ai_failing INTO rec_sua_ai_failing;
          CLOSE cur_sua_ai_failing;
          IF (rec_sua_ai_failing.unit_ass_item_id IS NOT NULL) THEN
            OPEN cur_uai_reference (rec_sua_ai_failing.unit_ass_item_id);
            FETCH cur_uai_reference INTO rec_uai_reference;
            CLOSE cur_uai_reference;
            p_message_name := 'IGS_AS_AI_GRD_SCH_HAS_NO_MARKS::' ||
                              rec_sua_ai_failing.ass_id || '^^' ||
                              rec_uai_reference.reference;
          ELSE
            OPEN cur_usai_reference (rec_sua_ai_failing.unit_section_ass_item_id);
            FETCH cur_usai_reference INTO rec_usai_reference;
            CLOSE cur_usai_reference;
            p_message_name := 'IGS_AS_AI_GRD_SCH_HAS_NO_MARKS::' ||
                              rec_sua_ai_failing.ass_id || '^^' ||
                              rec_usai_reference.reference;
          END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.suaai_grd_sch',
              'Student Unit Attempt Assessment Item Grading Schema has gaps/invalid range'
            );
          END IF;
          RETURN;
        END IF;
      END LOOP;
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
  END validate_ai_us_grd_mark_range;
  --
  -- Program Unit to derive the Mark and Grade for a Student Unit Attempt from
  -- Student Unit Attempt Assessment Item Outcomes
  -- The return value of this function is a concatenation of Mark and Grade
  -- separated by ::
  --
  FUNCTION derive_suao_mark_grade (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2
  ) RETURN VARCHAR2 IS
    --
    -- Cursor to get the Student Unit Attempt Assessment Items' information
    --
    CURSOR cur_suaaig (
             cp_person_id IN NUMBER,
             cp_course_cd IN VARCHAR2,
             cp_uoo_id IN NUMBER,
             cp_grading_period_cd IN VARCHAR2
           ) IS
      SELECT   suag.group_name,
               DECODE (cp_grading_period_cd,
                 'FINAL', suag.final_formula_code,
                 'MIDTERM', suag.midterm_formula_code) group_formula_code,
               DECODE (cp_grading_period_cd,
                 'FINAL', suag.final_formula_qty,
                  'MIDTERM', suag.midterm_formula_qty) group_formula_qty,
               DECODE (cp_grading_period_cd,
                 'FINAL', suag.final_weight_qty,
                 'MIDTERM', suag.midterm_weight_qty) group_weight_qty,
               suai.ass_id,
               suai.grading_schema_cd,
               suai.gs_version_number,
               DECODE (cp_grading_period_cd,
                 'FINAL', suai.final_mandatory_type_code,
                 'MIDTERM', suai.midterm_mandatory_type_code) mandatory_type_code,
               DECODE (cp_grading_period_cd,
                 'FINAL', suai.final_weight_qty,
                 'MIDTERM', suai.midterm_weight_qty) ai_weight_qty,
               NVL (suai.waived_flag, 'N') waived_flag,
               suai.mark,
               (suai.mark - gslu.lower_limit) *
               (100 / (gslu.upper_limit - gslu.lower_limit)) common_base_mark
      FROM     igs_as_sua_ai_group suag,
               igs_as_su_atmpt_itm suai,
               (SELECT   grading_schema_cd,
                         version_number,
                         MIN (lower_mark_range) lower_limit,
                         MAX (upper_mark_range) upper_limit
                FROM     igs_as_grd_sch_grade
                GROUP BY grading_schema_cd,
                         version_number) gslu
      WHERE    suag.person_id = cp_person_id
      AND      suag.course_cd = cp_course_cd
      AND      suag.uoo_id = cp_uoo_id
      AND      suag.logical_delete_date IS NULL
      AND      suai.logical_delete_dt IS NULL
      AND      DECODE (cp_grading_period_cd,
                 'FINAL', suag.final_formula_code,
                 'MIDTERM', suag.midterm_formula_code) IS NOT NULL
      AND      DECODE (cp_grading_period_cd,
                 'FINAL', suag.final_weight_qty,
                 'MIDTERM', suag.midterm_weight_qty) > 0
      AND      DECODE (cp_grading_period_cd,
                 'FINAL', suai.final_mandatory_type_code,
                 'MIDTERM', suai.midterm_mandatory_type_code) IS NOT NULL
      AND      DECODE (suai.waived_flag,
                 'Y', 1,
                 NVL (DECODE (cp_grading_period_cd,
                        'FINAL', suai.final_weight_qty,
                        'MIDTERM', suai.midterm_weight_qty), 0)) > 0
      AND      suag.sua_ass_item_group_id = suai.sua_ass_item_group_id
      AND      suai.grading_schema_cd = gslu.grading_schema_cd (+)
      AND      suai.gs_version_number = gslu.version_number (+)
      ORDER BY suag.group_name ASC, common_base_mark DESC;
    --
    -- Cursor to get the Default Unit Section Grading Schema details
    --
    CURSOR cur_usec_grd_sch (
             cp_uoo_id IN NUMBER
           ) IS
      SELECT   usgs.grading_schema_code,
               usgs.grd_schm_version_number,
               gslu.lower_limit,
               gslu.upper_limit
      FROM     igs_ps_usec_grd_schm usgs,
               (SELECT   grading_schema_cd,
                         version_number,
                         MIN (lower_mark_range) lower_limit,
                         MAX (upper_mark_range) upper_limit
                FROM     igs_as_grd_sch_grade
                GROUP BY grading_schema_cd,
                         version_number) gslu
      WHERE    usgs.uoo_id = cp_uoo_id
      AND      usgs.default_flag = 'Y'
      AND      usgs.grading_schema_code = gslu.grading_schema_cd
      AND      usgs.grd_schm_version_number = gslu.version_number;
    --
    -- Cursor to get the Default Unit Grading Schema details if Unit Section
    -- Grading Schemas are not setup
    --
    CURSOR cur_unit_grd_sch (
             cp_uoo_id IN NUMBER
           ) IS
      SELECT   ugs.grading_schema_code,
               ugs.grd_schm_version_number,
               gslu.lower_limit,
               gslu.upper_limit
      FROM     igs_ps_unit_grd_schm ugs,
               igs_ps_unit_ofr_opt_all uoo,
               (SELECT   grading_schema_cd,
                         version_number,
                         MIN (lower_mark_range) lower_limit,
                         MAX (upper_mark_range) upper_limit
                FROM     igs_as_grd_sch_grade
                GROUP BY grading_schema_cd,
                         version_number) gslu
      WHERE    uoo.uoo_id = cp_uoo_id
      AND      ugs.unit_code = uoo.unit_cd
      AND      ugs.unit_version_number = uoo.version_number
      AND      ugs.default_flag = 'Y'
      AND      ugs.grading_schema_code = gslu.grading_schema_cd
      AND      ugs.grd_schm_version_number = gslu.version_number;
    --
    -- Cursor to get the grade for a given mark from a given Grading Schema
    --
    CURSOR cur_grade (
             cp_grading_schema_code IN VARCHAR2,
             cp_grading_schema_version IN NUMBER,
             cp_mark IN NUMBER
           ) IS
      SELECT   grade,
               s_result_type
      FROM     igs_as_grd_sch_grade
      WHERE    grading_schema_cd = cp_grading_schema_code
      AND      version_number = cp_grading_schema_version
      AND      cp_mark BETWEEN lower_mark_range AND upper_mark_range;
    --
    --
    --
    CURSOR cur_entry_conf IS
      SELECT   key_mark_entry_dec_points
      FROM     igs_as_entry_conf
      WHERE    s_control_num = 1;
    --
    rec_entry_conf cur_entry_conf%ROWTYPE;
    l_format_mask VARCHAR2(9);
    TYPE suaaio_table_type IS TABLE OF cur_suaaig%ROWTYPE INDEX BY BINARY_INTEGER;
    suaaio_table suaaio_table_type;
    TYPE rec_group_marks_weights_type IS RECORD (
           group_name VARCHAR2(30),
           mark NUMBER,
           group_weight_qty NUMBER
         );
    TYPE suaaig_table_type IS TABLE OF rec_group_marks_weights_type INDEX BY BINARY_INTEGER;
    suaaig_table suaaig_table_type;
    rec_usec_grd_sch cur_usec_grd_sch%ROWTYPE;
    rec_grade cur_grade%ROWTYPE;
    aio_table_index NUMBER := 1;
    aig_table_index NUMBER := 0;
    v_group_best_atleast_n NUMBER := 0;
    v_previous_group_name VARCHAR2(30) := '`';
    v_previous_group_formula NUMBER;
    v_previous_group_formula_cd VARCHAR2(30) := '`';
    l_routine VARCHAR2(30) := 'derive_suao_mark_grade';
    v_suao_raw_mark NUMBER;
    v_suao_mark NUMBER;
    v_sum_of_all_the_weights NUMBER := 0;
    v_mark_weight_products NUMBER := 0;
    v_mandatory_pass_items_passed BOOLEAN := TRUE;
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';'
      );
    END IF;
    --
    -- Initialise the global variables to avoid recomputing Mark/Grade for the
    -- for the same Student Unit Attempt and Grading Period
    --
    g_person_id := p_person_id;
    g_course_cd := p_course_cd;
    g_uoo_id := p_uoo_id;
    g_grading_period_cd := p_grading_period_cd;
    --
    -- Step 1
    --
    -- Select all the Assessment Item Groups which are associated with the
    -- student that have Non-Zero weighting and convert them to the same base scale
    --
    FOR rec_suaaig IN cur_suaaig (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      ) LOOP
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.selected values',
          'group_name =>' || rec_suaaig.group_name || ';' ||
          'group_formula_code =>' || rec_suaaig.group_formula_code || ';' ||
          'group_formula_qty =>' || rec_suaaig.group_formula_qty || ';' ||
          'group_weight_qty =>' || rec_suaaig.group_weight_qty || ';' ||
          'ass_id =>' || rec_suaaig.ass_id || ';' ||
          'grading_schema_cd =>' || rec_suaaig.grading_schema_cd || ';' ||
          'gs_version_number =>' || rec_suaaig.gs_version_number || ';' ||
          'mandatory_type_code =>' || rec_suaaig.mandatory_type_code || ';' ||
          'ai_weight_qty =>' || rec_suaaig.ai_weight_qty || ';' ||
          'waived_flag =>' || rec_suaaig.waived_flag || ';' ||
          'mark =>' || rec_suaaig.mark || ';' ||
          'common_base_mark =>' || rec_suaaig.common_base_mark || ';' ||
          'v_group_best_atleast_n =>' || v_group_best_atleast_n || ';'
        );
      END IF;
      --
      -- Step 2
      --
      -- Group all Assessment Items of a grading period based on the
      -- Assessment Type and Formula. Select the Best N or At least N assessment
      -- items while accounting for any 'Waived' flag of the Student Unit
      -- Assessment Items. Filter out all the outcomes that are not needed for
      -- derivation. If the student has not attempted Best N or At least N then
      -- set mark = NULL, Grade = NULL, and exit.
      --
      IF (v_previous_group_name <> rec_suaaig.group_name) THEN
        IF (v_previous_group_formula > v_group_best_atleast_n) THEN
          --
          -- Student does not have enough Best N or Atleast N for SUAO derivation;
          -- So return Mark and Grade as NULL
          --
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.not_enough_best_atleast_n_items',
              'Returning the SUAO Mark as NULL and Grade as NULL with error message IGS_AS_STU_HAS_INSUF_AI_ATTMPS'
            );
          END IF;
          RETURN ('::;;IGS_AS_STU_HAS_INSUF_AI_ATTMPS');
        END IF;
        v_previous_group_name := rec_suaaig.group_name;
        v_previous_group_formula := rec_suaaig.group_formula_qty;
        v_previous_group_formula_cd := rec_suaaig.group_formula_code;
        v_group_best_atleast_n := 0;
      END IF;
      --
      -- Step 3
      --
      -- Check if All Mandatory Type of Assessment Items have been attempted.
      -- If not, then set marks to 0 and set grade to NULL for the SUAO and exit.
      --
      IF ((rec_suaaig.mandatory_type_code = 'MANDATORY') AND
          (rec_suaaig.mark IS NULL) AND
          (rec_suaaig.waived_flag = 'N')) THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.mandatory_items_enough_best_atleast_n_items',
              'Returning the SUAO Mark as 0 and Grade as NULL with error message IGS_AS_STU_NOT_ATMPT_MAND_AI'
            );
          END IF;
        RETURN ('0::;;IGS_AS_STU_NOT_ATMPT_MAND_AI');
      END IF;
      --
      -- Check if All 'Mandatory Pass' assessment items have been passed.
      --
      IF ((rec_suaaig.mandatory_type_code = 'MANDATORY_PASS') AND
          (v_mandatory_pass_items_passed)) THEN
        OPEN cur_grade (
               rec_suaaig.grading_schema_cd,
               rec_suaaig.gs_version_number,
               rec_suaaig.mark
             );
        FETCH cur_grade INTO rec_grade;
        CLOSE cur_grade;
        IF (NVL (rec_grade.s_result_type, 'NOTPASS') <> 'PASS') THEN
          v_mandatory_pass_items_passed := FALSE;
        END IF;
      END IF;
      --
      -- Get the Best N/Atleast N Assessment Items
      --
      IF ((rec_suaaig.group_formula_code IN ('BEST_N', 'ATLEAST_N')) AND
          ((rec_suaaig.mark IS NOT NULL) OR
           (rec_suaaig.waived_flag = 'Y'))) THEN
        v_group_best_atleast_n := v_group_best_atleast_n + 1;
      END IF;
      --
      -- Add the Student Unit Attempt Assessment Item information to a table to
      -- derive the Assessment Item Group Mark
      --
      IF ((rec_suaaig.group_formula_code = 'BEST_N') AND
          ((rec_suaaig.mark IS NOT NULL) OR
           (rec_suaaig.waived_flag = 'Y'))) THEN
        IF (v_group_best_atleast_n <= rec_suaaig.group_formula_qty) THEN
          IF (rec_suaaig.waived_flag = 'Y') THEN
            rec_suaaig.mark := 0;
          END IF;
          suaaio_table(aio_table_index) := rec_suaaig;
          aio_table_index := aio_table_index + 1;
        END IF;
      ELSIF ((rec_suaaig.mark IS NOT NULL) OR
             (rec_suaaig.waived_flag = 'Y')) THEN
        IF (rec_suaaig.waived_flag = 'Y') THEN
          rec_suaaig.mark := 0;
        END IF;
        suaaio_table(aio_table_index) := rec_suaaig;
        aio_table_index := aio_table_index + 1;
      END IF;
    END LOOP;
    --
    IF ((v_previous_group_formula_cd IN ('BEST_N', 'ATLEAST_N')) AND
        (v_previous_group_formula > v_group_best_atleast_n)) THEN
      --
      -- Student does not have enough Best N or Atleast N for SUAO derivation;
      -- So return Mark and Grade as NULL
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.not_enough_best_atleast_n_items',
          'Returning the SUAO Mark as NULL and Grade as NULL with error message IGS_AS_STU_HAS_INSUF_AI_ATTMPS'
        );
      END IF;
      RETURN ('::;;IGS_AS_STU_HAS_INSUF_AI_ATTMPS');
    END IF;
    --
    IF (v_previous_group_name  = '`') THEN
      --
      -- No Student Unit Attempts Assessment Items found so return NULL
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.no_assessment_items_setup',
          'Returning the SUAO Mark as NULL and Grade as NULL as there are no assessment items setup'
        );
      END IF;
      RETURN ('::');
    END IF;
    --
    v_previous_group_name := '`';
    --
    OPEN cur_entry_conf;
    FETCH cur_entry_conf INTO rec_entry_conf;
    CLOSE cur_entry_conf;
    IF (NVL (rec_entry_conf.key_mark_entry_dec_points, 0) = 0) THEN
      l_format_mask := 'FM990';
    ELSE
      l_format_mask := RPAD ('FM990D', 9 - (3 - rec_entry_conf.key_mark_entry_dec_points), '0');
    END IF;
    --
    -- Step 4
    --
    -- Roll up Student Unit Attempt Assessment Item Group mark (SUAAIG Mark)
    -- from each Student Unit Attempt Assessment Item mark (SUAAI Mark)
    --
    FOR i IN 1..(aio_table_index - 1) LOOP
      IF (v_previous_group_name <> suaaio_table(i).group_name) THEN
        --
        -- Compute the Assessment Item Group Mark at the change of each group
        --
        IF (aig_table_index > 0) THEN
          suaaig_table(aig_table_index).group_name := v_previous_group_name;
          IF (v_sum_of_all_the_weights > 0) THEN
            suaaig_table(aig_table_index).mark := TO_CHAR ((v_mark_weight_products / v_sum_of_all_the_weights), l_format_mask);
          ELSE
            suaaig_table(aig_table_index).mark := 0;
          END IF;
          suaaig_table(aig_table_index).group_weight_qty := v_previous_group_formula;
          --
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.assessment_item_group_mark',
              'Group Name =>' || v_previous_group_name || ';' ||
              'Group Formula Weight =>' || v_previous_group_formula || ';' ||
              'Mark =>' || suaaig_table(aig_table_index).mark || ';'
            );
          END IF;
        END IF;
        v_sum_of_all_the_weights := 0;
        v_mark_weight_products := 0;
        v_previous_group_name := suaaio_table(i).group_name;
        v_previous_group_formula := suaaio_table(i).group_weight_qty;
        aig_table_index := aig_table_index + 1;
      END IF;
      IF (suaaio_table(i).waived_flag = 'N') THEN
        v_sum_of_all_the_weights := v_sum_of_all_the_weights + suaaio_table(i).ai_weight_qty;
        v_mark_weight_products := v_mark_weight_products + (NVL (suaaio_table(i).common_base_mark, 0) * suaaio_table(i).ai_weight_qty);
      END IF;
    END LOOP;
    --
    -- Compute the Assessment Item Group Mark at the change of each group
    --
    IF (aig_table_index > 0) THEN
      suaaig_table(aig_table_index).group_name := v_previous_group_name;
      IF (v_sum_of_all_the_weights > 0) THEN
        suaaig_table(aig_table_index).mark := TO_CHAR ((v_mark_weight_products / v_sum_of_all_the_weights), l_format_mask);
      ELSE
        suaaig_table(aig_table_index).mark := 0;
      END IF;
      suaaig_table(aig_table_index).group_weight_qty := v_previous_group_formula;
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.assessment_item_group_mark',
          'Group Name =>' || v_previous_group_name || ';' ||
          'Group Formula Weight =>' || v_previous_group_formula || ';' ||
          'Mark =>' || suaaig_table(aig_table_index).mark || ';'
        );
      END IF;
    END IF;
    --
    v_sum_of_all_the_weights := 0;
    v_mark_weight_products := 0;
    --
    -- Step 5
    --
    -- Roll up Student Unit Attempt mark (SUA mark) from each Student
    -- Unit Attempt Assessment Item Group mark (SUAAIG mark)
    --
    FOR i IN 1..aig_table_index LOOP
      v_sum_of_all_the_weights := v_sum_of_all_the_weights + suaaig_table(i).group_weight_qty;
      v_mark_weight_products := v_mark_weight_products + (NVL (suaaig_table(i).mark, 0) * suaaig_table(i).group_weight_qty);
    END LOOP;
    --
    IF (v_sum_of_all_the_weights > 0) THEN
      v_suao_raw_mark := TO_CHAR ((v_mark_weight_products / v_sum_of_all_the_weights), l_format_mask);
    ELSE
      v_suao_raw_mark := 0;
    END IF;
    --
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_statement,
        g_module_head || l_routine || '.suao_raw_mark',
        'SUAO Raw Mark =>' || v_suao_raw_mark || ';'
      );
    END IF;
    --
    -- Step 6
    --
    -- Convert Student Unit Attempt Outcome mark to the Unit Section Grading
    -- Schema and find corresponding Grade.
    --
    OPEN cur_usec_grd_sch (p_uoo_id);
    FETCH cur_usec_grd_sch INTO rec_usec_grd_sch;
    --
    IF (cur_usec_grd_sch%NOTFOUND) THEN
      CLOSE cur_usec_grd_sch;
      OPEN cur_unit_grd_sch (p_uoo_id);
      FETCH cur_unit_grd_sch INTO rec_usec_grd_sch;
      CLOSE cur_unit_grd_sch;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.usec_dflt_grd_sch_not_available',
          '=>Default Unit Grading Schema=>' || rec_usec_grd_sch.grading_schema_code || ';' || rec_usec_grd_sch.grd_schm_version_number || ';'
        );
      END IF;
    ELSE
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.usec_dflt_grd_sch_available',
          '=>Default Unit Section Grading Schema=>' || rec_usec_grd_sch.grading_schema_code || ';' || rec_usec_grd_sch.grd_schm_version_number || ';'
        );
      END IF;
      CLOSE cur_usec_grd_sch;
    END IF;
    --
    v_suao_mark := TO_CHAR ((v_suao_raw_mark * ((rec_usec_grd_sch.upper_limit - rec_usec_grd_sch.lower_limit)/100)) + rec_usec_grd_sch.lower_limit, l_format_mask);
    --
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_statement,
        g_module_head || l_routine || '.suao_mark_using_usec_grd_sch',
        'SUAO Mark Converted to Unit Section Grading Schema=>' || v_suao_mark || ';'
      );
    END IF;
    --
    OPEN cur_grade (
           rec_usec_grd_sch.grading_schema_code,
           rec_usec_grd_sch.grd_schm_version_number,
           v_suao_mark
         );
    FETCH cur_grade INTO rec_grade;
    CLOSE cur_grade;
    --
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_statement,
        g_module_head || l_routine || '.suao_grade',
        'SUAO Grade=>' || rec_grade.grade || ';'
      );
    END IF;
    --
    -- Step 7
    --
    -- Check if All 'Mandatory Pass' assessment items have been passed.
    -- If not, then keep marks unchanged and assign a "Fail" grade for the SUAO.
    --
    IF (NOT v_mandatory_pass_items_passed) THEN
      rec_grade.grade := NULL;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.not_passed_mand_pass_items',
          'Returning the derived SUAO Mark and NULL for Grade with error message IGS_AS_STU_NOT_PAS_MAND_PAS_AI'
        );
      END IF;
      RETURN (v_suao_mark || '::;;IGS_AS_STU_NOT_PAS_MAND_PAS_AI');
    END IF;
    --
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    --
    RETURN (v_suao_mark || '::' || rec_grade.grade);
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_exception,
          g_module_head || l_routine || '.exception',
          'Returning the derived SUAO Mark and NULL for Grade with error : ' || SQLERRM
        );
      END IF;
      RETURN (v_suao_mark || '::');
  END derive_suao_mark_grade;
  --
  -- Procedure to derive the Student Unit Attempt Outcome Mark and Grade from
  -- Student Unit Attempt Assessment Item Outcome
  --
  PROCEDURE derive_suao_mark_grade_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_mark                         OUT NOCOPY NUMBER,
    p_grade                        OUT NOCOPY VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) IS
    l_routine VARCHAR2(30) := 'derive_suao_mark_grade_suaio';
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';p_message_name'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      --
      -- Mark/Grade already derived for the Student so return mark without recomputing
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.mark_already_derived',
          'Returning the already derived mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1) ||
          '; grade=>' || SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2) || '; with error message ' || p_message_name
        );
      END IF;
    ELSE
      --
      -- Mark/Grade not derived for the Student so derive and return Mark
      --
      g_mark_grade := derive_suao_mark_grade (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.derived_mark',
          'Derived Mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1) ||
          '; with error message ' || p_message_name
        );
      END IF;
    END IF;
    --
    -- Extract Message Name
    --
    IF (INSTR (g_mark_grade, ';;') > 0) THEN
      p_message_name := SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2);
    END IF;
    --
    -- Extract Grade
    --
    IF (p_message_name IS NULL) THEN
      p_grade := SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2);
    ELSE
      p_grade := SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2, INSTR (g_mark_grade, ';;') - INSTR (g_mark_grade, '::')- 2);
    END IF;
    --
    -- Extract Mark
    --
    p_mark := SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1);
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
  END derive_suao_mark_grade_suaio;
  --
  -- Function to derive the Student Unit Attempt Outcome Mark from Student Unit
  -- Attempt Assessment Item Outcome Marks
  --
  -- This function is a overloaded so that it can be called from SQL and PL/SQL
  -- or Java separately so that the error message can be shown to the user in
  -- case of PL/SQL or Java
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS
    l_routine VARCHAR2(30) := 'derive_suao_mark_from_suaio';
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';p_message_name'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      --
      -- Mark/Grade already derived for the Student so return mark without recomputing
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.mark_already_derived',
          'Returning the already derived mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1) ||
          '; with error message ' || SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2)
        );
     END IF;
    ELSE
      --
      -- Mark/Grade not derived for the Student so derive and return Mark
      --
      g_mark_grade := derive_suao_mark_grade (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.derived_mark',
          'Derived Mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1) ||
          '; with error message ' || SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2)
        );
      END IF;
    END IF;
    IF (INSTR (g_mark_grade, ';;') > 0) THEN
      p_message_name := SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2);
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    RETURN (SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1));
  END derive_suao_mark_from_suaio;
  --
  -- Function to derive the Student Unit Attempt Outcome Mark from Student Unit
  -- Attempt Assessment Item Outcome Marks
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN NUMBER IS
    l_routine VARCHAR2(30) := 'derive_suao_mark_from_suaio';
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      --
      -- Mark/Grade already derived for the Student so return Mark without recomputing
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.mark_already_derived',
          'Returning the already derived mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
        );
      END IF;
    ELSE
      --
      -- Mark/Grade not derived for the Student so derive and return Mark
      --
      g_mark_grade := derive_suao_mark_grade (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.derived_mark',
          'Derived Mark=>' ||
          SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
        );
      END IF;
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    RETURN (SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1));
  END derive_suao_mark_from_suaio;
  --
  -- Function to check 'Derive Unit Mark from Assessment Item Mark' and if the
  -- Unit Section is not Submitted then derive the Student Unit Attempt Outcome
  -- Mark from Student Unit Attempt Assessment Item Outcome Marks if the Outcome
  -- is neither Finalized nor Manually Overridden. If the Mark and Grade are not
  -- to be derived then the passed on mark and grade will be returned back.
  --
  FUNCTION derive_suao_mark_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_mark                         IN NUMBER,
    p_grade                        IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN NUMBER IS
    --
    -- Check if the Unit Section Grades are submitted
    --
    CURSOR cur_usec_submitted IS
      SELECT 'Y' submitted
      FROM   igs_as_gaa_sub_hist sub
      WHERE  sub.uoo_id = p_uoo_id
      AND    sub.grading_period_cd = p_grading_period_cd
      AND    sub.submission_type = 'GRADE'
      AND    sub.submission_status = 'COMPLETE';
    --
    --
    --
    CURSOR cur_suao_final_man_ovr IS
      SELECT 'Y' finalized_manually_overridden
      FROM   igs_as_su_stmptout_all suao
      WHERE  suao.person_id = p_person_id
      AND    suao.course_cd = p_course_cd
      AND    suao.uoo_id = p_uoo_id
      AND    suao.grading_period_cd = p_grading_period_cd
      AND    suao.outcome_dt =
             (SELECT MAX (outcome_dt)
              FROM   igs_as_su_stmptout_all
              WHERE  person_id = suao.person_id
              AND    course_cd = suao.course_cd
              AND    uoo_id = suao.uoo_id
              AND    grading_period_cd = suao.grading_period_cd)
      AND    (suao.manual_override_flag = 'Y'
      OR      suao.finalised_outcome_ind = 'Y');
    --
    l_routine VARCHAR2(30) := 'derive_suao_mark_from_suaio';
    rec_usec_submitted cur_usec_submitted%ROWTYPE;
    rec_suao_final_man_ovr cur_suao_final_man_ovr%ROWTYPE;
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_mark=>' || p_mark || ';' ||
        'p_grade=>' || p_grade || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
      g_unit_section_submitted := FALSE;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      IF g_unit_section_submitted THEN
        --
        -- As the Unit Section is submitted Mark/Grade need not be derived so
        -- return the passed values as Mark/Grade
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.usec_submitted_mark_not_derived',
            'Returning the passed mark as Unit Section is submitted=>' || p_mark
          );
        END IF;
        g_mark_grade := p_mark || '::' || p_grade;
      ELSE
        --
        -- Mark/Grade already derived for the Student so return Mark without recomputing
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.mark_already_derived_usec_not_submitted',
            'Returning the already derived mark as Unit Section is not Submitted=>' ||
            SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
          );
        END IF;
      END IF;
    ELSE
      --
      g_person_id := p_person_id;
      g_course_cd := p_course_cd;
      g_uoo_id := p_uoo_id;
      g_grading_period_cd := p_grading_period_cd;
      --
      -- Check if the Unit Section Grades are submitted
      --
      OPEN cur_usec_submitted;
      FETCH cur_usec_submitted INTO rec_usec_submitted;
      CLOSE cur_usec_submitted;
      IF (rec_usec_submitted.submitted = 'Y') THEN
        g_unit_section_submitted := TRUE;
        --
        -- Return back the passed Mark/Grade as Unit Section is Submitted
        --
        g_mark_grade := p_mark || '::' || p_grade;
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.mark_not_derived_as_usec_submitted',
            'Returning back the passed mark as Unit Section is Submitted=>' ||
            SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
          );
        END IF;
      ELSE
        g_unit_section_submitted := FALSE;
        --
        -- Check if the Student Unit Attempt Outcomes that are flagged as
        -- 'Manually Overridden' or 'Finalized' will not be recalculated.
        --
        OPEN cur_suao_final_man_ovr;
        FETCH cur_suao_final_man_ovr INTO rec_suao_final_man_ovr;
        CLOSE cur_suao_final_man_ovr;
        IF (rec_suao_final_man_ovr.finalized_manually_overridden = 'Y') THEN
          --
          g_unit_section_submitted := TRUE;
          --
          -- Return back the passed Mark/Grade as Student Unit Attempt Outcome
          -- is 'Finalized' or 'Manually Overridden'
          --
          g_mark_grade := p_mark || '::' || p_grade;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.mark_not_derived_as_suao_fin_man_ovr',
              'Returning back the passed mark as Student Unit Attempt Outcome is ' ||
              'Finalized or Manually Overridden=>' ||
              SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
            );
           END IF;
        ELSE
          --
          -- Mark/Grade not derived for the Student so derive and return Mark
          --
          g_mark_grade := derive_suao_mark_grade (
                            p_person_id,
                            p_course_cd,
                            p_uoo_id,
                            p_grading_period_cd
                          );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.derived_mark',
              'Derived Mark=>' ||
              SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1)
            );
          END IF;
        END IF;
      END IF;
    END IF;
    --
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    --
    RETURN (SUBSTR (g_mark_grade, 1, INSTR (g_mark_grade, '::') - 1));
    --
  END derive_suao_mark_from_suaio;
  --
  --
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_routine VARCHAR2(30) := 'derive_suao_grade_from_suaio';
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';p_message_name'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      --
      -- Mark/Grade already derived for the Student so return Grade without recomputing
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.grade_already_derived',
          'Returning the already derived grade=>' ||
          SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2) ||
          '; with error message ' || SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2)
        );
      END IF;
    ELSE
      --
      -- Mark/Grade not derived for the Student so derive and return Grade
      --
      g_mark_grade := derive_suao_mark_grade (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.derived_grade',
          'Derived Grade=>' ||
          SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2) ||
          '; with error message ' || SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2)
        );
       END IF;
    END IF;
    IF (INSTR (g_mark_grade, ';;') > 0) THEN
      p_message_name := SUBSTR (g_mark_grade, INSTR (g_mark_grade, ';;') + 2);
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    IF (p_message_name IS NULL) THEN
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2));
    ELSE
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2, INSTR (g_mark_grade, ';;') - INSTR (g_mark_grade, '::')- 2));
    END IF;
  END derive_suao_grade_from_suaio;
  --
  --
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2 IS
    l_routine VARCHAR2(30) := 'derive_suao_grade_from_suaio';
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      --
      -- Mark/Grade already derived for the Student so return Grade without recomputing
      --
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.grade_already_derived',
          'Returning the already derived grade=>' ||
          SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
        );
      END IF;
    ELSE
      --
      -- Mark/Grade not derived for the Student so derive and return Grade
      --
      g_mark_grade := derive_suao_mark_grade (
                        p_person_id,
                        p_course_cd,
                        p_uoo_id,
                        p_grading_period_cd
                      );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || l_routine || '.derived_grade',
          'Derived Grade=>' ||
          SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
        );
      END IF;
    END IF;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    IF (INSTR (g_mark_grade, ';;') > 0) THEN
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2, INSTR (g_mark_grade, ';;') - INSTR (g_mark_grade, '::')- 2));
    ELSE
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2));
    END IF;
  END derive_suao_grade_from_suaio;
  --
  -- Function to check 'Derive Unit Mark from Assessment Item Mark' and if the
  -- Unit Section is not Submitted then derive the Student Unit Attempt Outcome
  -- Grade from Student Unit Attempt Assessment Item Outcome Marks if the Outcome
  -- is neither Finalized nor Manually Overridden. If the Mark and Grade are not
  -- to be derived then the passed on mark and grade will be returned back.
  --
  FUNCTION derive_suao_grade_from_suaio (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_grading_period_cd            IN VARCHAR2,
    p_mark                         IN NUMBER,
    p_grade                        IN VARCHAR2,
    p_reset_mark_grade             IN VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2 IS
    --
    -- Check if the Unit Section Grades are submitted
    --
    CURSOR cur_usec_submitted IS
      SELECT 'Y' submitted
      FROM   igs_as_gaa_sub_hist sub
      WHERE  sub.uoo_id = p_uoo_id
      AND    sub.grading_period_cd = p_grading_period_cd
      AND    sub.submission_type = 'GRADE'
      AND    sub.submission_status = 'COMPLETE';
    --
    --
    --
    CURSOR cur_suao_final_man_ovr IS
      SELECT 'Y' finalized_manually_overridden
      FROM   igs_as_su_stmptout_all suao
      WHERE  suao.person_id = p_person_id
      AND    suao.course_cd = p_course_cd
      AND    suao.uoo_id = p_uoo_id
      AND    suao.grading_period_cd = p_grading_period_cd
      AND    suao.outcome_dt =
             (SELECT MAX (outcome_dt)
              FROM   igs_as_su_stmptout_all
              WHERE  person_id = suao.person_id
              AND    course_cd = suao.course_cd
              AND    uoo_id = suao.uoo_id
              AND    grading_period_cd = suao.grading_period_cd)
      AND    (suao.manual_override_flag = 'Y'
      OR      suao.finalised_outcome_ind = 'Y');
    --
    l_routine VARCHAR2(30) := 'derive_suao_grade_from_suaio';
    rec_usec_submitted cur_usec_submitted%ROWTYPE;
    rec_suao_final_man_ovr cur_suao_final_man_ovr%ROWTYPE;
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_grading_period_cd=>' || p_grading_period_cd || ';' ||
        'p_mark=>' || p_mark || ';' ||
        'p_grade=>' || p_grade || ';' ||
        'p_reset_mark_grade=>' || p_reset_mark_grade || ';'
      );
    END IF;
    --
    -- Nullify the global variables so that the Mark/Grade is derived afresh
    --
    IF (p_reset_mark_grade = 'Y') THEN
      g_person_id := NULL;
      g_course_cd := NULL;
      g_uoo_id := NULL;
      g_grading_period_cd := NULL;
      g_unit_section_submitted := FALSE;
    END IF;
    --
    -- Check if the Mark/Grade is already derived for the Student
    --
    IF g_person_id = p_person_id AND
       g_course_cd = p_course_cd AND
       g_uoo_id = p_uoo_id AND
       g_grading_period_cd = p_grading_period_cd THEN
      IF g_unit_section_submitted THEN
        --
        -- As the Unit Section is submitted Mark/Grade need not be derived so
        -- return the passed values as Mark/Grade
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.usec_submitted_grade_not_derived',
            'Returning the passed grade as Unit Section is submitted=>' || p_grade
          );
        END IF;
        g_mark_grade := p_mark || '::' || p_grade;
      ELSE
        --
        -- Mark/Grade already derived for the Student so return Grade without recomputing
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.grade_already_derived_usec_not_submitted',
            'Returning the already derived grade as Unit Section is not Submitted=>' ||
            SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
          );
        END IF;
      END IF;
    ELSE
      --
      g_person_id := p_person_id;
      g_course_cd := p_course_cd;
      g_uoo_id := p_uoo_id;
      g_grading_period_cd := p_grading_period_cd;
      --
      -- Check if the Unit Section Grades are submitted
      --
      OPEN cur_usec_submitted;
      FETCH cur_usec_submitted INTO rec_usec_submitted;
      CLOSE cur_usec_submitted;
      IF (rec_usec_submitted.submitted = 'Y') THEN
        g_unit_section_submitted := TRUE;
        --
        -- Return back the passed Mark/Grade as Unit Section is Submitted
        --
        g_mark_grade := p_mark || '::' || p_grade;
        --
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || l_routine || '.grade_not_derived_as_usec_submitted',
            'Returning back the passed grade as Unit Section is Submitted=>' ||
            SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
          );
        END IF;
      ELSE
        g_unit_section_submitted := FALSE;
        --
        -- Check if the Student Unit Attempt Outcomes that are flagged as
        -- 'Manually Overridden' or 'Finalized' will not be recalculated.
        --
        OPEN cur_suao_final_man_ovr;
        FETCH cur_suao_final_man_ovr INTO rec_suao_final_man_ovr;
        CLOSE cur_suao_final_man_ovr;
        IF (rec_suao_final_man_ovr.finalized_manually_overridden = 'Y') THEN
          --
          g_unit_section_submitted := TRUE;
          --
          -- Return back the passed Mark/Grade as Student Unit Attempt Outcome
          -- is 'Finalized' or 'Manually Overridden'
          --
          g_mark_grade := p_mark || '::' || p_grade;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.grade_not_derived_as_suao_fin_man_ovr',
              'Returning back the passed grade as Student Unit Attempt Outcome is ' ||
              'Finalized or Manually Overridden=>' ||
              SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
            );
          END IF;
        ELSE
          --
          -- Mark/Grade not derived for the Student so derive and return Grade
          --
          g_mark_grade := derive_suao_mark_grade (
                            p_person_id,
                            p_course_cd,
                            p_uoo_id,
                            p_grading_period_cd
                          );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || l_routine || '.derived_grade',
              'Derived Grade=>' ||
              SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2)
            );
          END IF;
        END IF;
      END IF;
    END IF;
    --
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        l_routine
      );
    END IF;
    --
    IF (INSTR (g_mark_grade, ';;') > 0) THEN
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2, INSTR (g_mark_grade, ';;') - INSTR (g_mark_grade, '::')- 2));
    ELSE
      RETURN (SUBSTR (g_mark_grade, INSTR (g_mark_grade, '::') + 2));
    END IF;
    --
  END derive_suao_grade_from_suaio;
  --
  -- Function to derive Student's Assessment Status
  --
  -- 1st time the student enrolls in unit; Assessment Status = 'First Attempt'
  -- 2nd time the student enrolls in unit section; Assessment Status =
  -- 'Second Attempt', so and so forth
  --
  FUNCTION get_assessment_status (
    p_person_id                    IN NUMBER,
    p_course_cd                    IN VARCHAR2,
    p_uoo_id                       IN NUMBER,
    p_unit_cd                      IN VARCHAR2
  ) RETURN VARCHAR2 AS
    --
    -- Cursor to get the unit repeat information for a student
    --
    -- Note: Discontinued Unit Attempts are also considered as a graded outcome
    -- is created for Discontinued Unit Attempts.
    --
    CURSOR cur_suao (
             cp_uoo_id IN NUMBER,
             cp_unit_cd IN VARCHAR2,
             cp_person_id IN NUMBER,
             cp_course_cd IN VARCHAR2
           ) IS
      SELECT DISTINCT suao.person_id,
                      suao.course_cd,
                      suao.unit_cd,
                      suao.ci_start_dt
      FROM            igs_as_su_stmptout_all suao,
                      igs_en_su_attempt_all sua
      WHERE           suao.person_id = sua.person_id
      AND             suao.course_cd = sua.course_cd
      AND             suao.uoo_id = sua.uoo_id
      AND             sua.unit_attempt_status <> 'DROPPED'
      AND             suao.uoo_id <> p_uoo_id
      AND             suao.unit_cd = cp_unit_cd
      AND             suao.course_cd = cp_course_cd
      AND             suao.person_id = cp_person_id
      ORDER BY        suao.ci_start_dt ASC;
    --
    -- Cursor to get the Unit Section's Teaching Calendar Start Date
    --
    CURSOR cur_start_dt (
             cp_uoo_id IN NUMBER
           ) IS
      SELECT start_dt
      FROM   igs_ca_inst ci,
             igs_ps_unit_ofr_opt_all uoo
      WHERE  uoo.cal_type = ci.cal_type
      AND    ci.sequence_number = uoo.ci_sequence_number
      AND    uoo.uoo_id = cp_uoo_id;
    --
    l_st_dt DATE;
    lnrepeat NUMBER := 0;
    l_routine CONSTANT VARCHAR2(30) := 'get_assessment_status';
    --
  BEGIN
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.begin',
        'Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';' ||
        'p_uoo_id=>' || p_uoo_id || ';' ||
        'p_unit_cd=>' || p_unit_cd || ';'
      );
    END IF;
    OPEN cur_start_dt (p_uoo_id);
    FETCH cur_start_dt INTO l_st_dt;
    CLOSE cur_start_dt;
    FOR rec_suao IN cur_suao (p_uoo_id, p_unit_cd, p_person_id, p_course_cd) LOOP
      IF (l_st_dt > rec_suao.ci_start_dt) THEN
        lnrepeat := lnrepeat + 1;
      END IF;
    END LOOP;
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || l_routine || '.end',
        'Total number of repeats lnrepeat=>' || lnrepeat
      );
    END IF;
    RETURN TO_CHAR (TO_DATE (lnrepeat + 1, 'J'), 'Jspth') || ' ' || g_attempt;
  END get_assessment_status;
  --
  -- Function that derives the Grading Period for a given Teaching Calendar
  --
  FUNCTION get_grading_period_code (
    p_teach_cal_type               IN VARCHAR2,
    p_teach_ci_sequence_number     IN NUMBER
  ) RETURN VARCHAR2 IS
    --
    -- Get the Assessment Calendar Configuration
    --
    CURSOR cur_assessment_cal_conf IS
      SELECT acc.mid_mgs_start_dt_alias,
             acc.mid_mgs_end_dt_alias,
             acc.efinal_mgs_start_dt_alias,
             acc.efinal_mgs_end_dt_alias,
             acc.final_mgs_start_dt_alias,
             acc.final_mgs_end_dt_alias
      FROM   igs_as_cal_conf acc
      WHERE  s_control_num = 1;
    --
    -- Check if the Teaching Period falls within given Start and End Date Alias
    --
    CURSOR cur_grading_period_details (
             cp_teach_cal_type IN VARCHAR2,
             cp_teach_ci_sequence_number IN NUMBER,
             cp_start_date_alias IN VARCHAR2,
             cp_end_date_alias IN VARCHAR2
           ) IS
      SELECT   'Y'
      FROM     igs_ca_da_inst_v dai1,
               igs_ca_da_inst_v dai2
      WHERE    dai1.alias_val >= TRUNC (SYSDATE)
      AND      dai2.alias_val <= TRUNC (SYSDATE)
      AND      dai1.cal_type = dai2.cal_type
      AND      dai1.ci_sequence_number = dai2.ci_sequence_number
      AND      dai1.cal_type = cp_teach_cal_type
      AND      dai1.ci_sequence_number = cp_teach_ci_sequence_number
      AND      dai2.dt_alias = cp_start_date_alias
      AND      dai1.dt_alias = cp_end_date_alias;
    --
    rec_grading_period_details cur_grading_period_details%ROWTYPE;
    rec_assessment_cal_conf cur_assessment_cal_conf%ROWTYPE;
    --
  BEGIN
    --
    OPEN cur_assessment_cal_conf;
    FETCH cur_assessment_cal_conf INTO rec_assessment_cal_conf;
    CLOSE cur_assessment_cal_conf;
    --
    OPEN cur_grading_period_details (
           p_teach_cal_type,
           p_teach_ci_sequence_number,
           rec_assessment_cal_conf.mid_mgs_start_dt_alias,
           rec_assessment_cal_conf.mid_mgs_end_dt_alias
         );
    FETCH cur_grading_period_details INTO rec_grading_period_details;
    --
    IF (cur_grading_period_details%FOUND) THEN
      CLOSE cur_grading_period_details;
      RETURN 'MIDTERM';
    ELSE
      CLOSE cur_grading_period_details;
      --
      OPEN cur_grading_period_details (
             p_teach_cal_type,
             p_teach_ci_sequence_number,
             rec_assessment_cal_conf.efinal_mgs_start_dt_alias,
             rec_assessment_cal_conf.efinal_mgs_end_dt_alias
           );
      FETCH cur_grading_period_details INTO rec_grading_period_details;
      --
      IF (cur_grading_period_details%FOUND) THEN
        CLOSE cur_grading_period_details;
        RETURN 'EARLY_FINAL';
      ELSE
        CLOSE cur_grading_period_details;
        --
        OPEN cur_grading_period_details (
               p_teach_cal_type,
               p_teach_ci_sequence_number,
               rec_assessment_cal_conf.final_mgs_start_dt_alias,
               rec_assessment_cal_conf.final_mgs_end_dt_alias
             );
        FETCH cur_grading_period_details INTO rec_grading_period_details;
        --
        IF (cur_grading_period_details%FOUND) THEN
          CLOSE cur_grading_period_details;
          RETURN 'FINAL';
        ELSE
          CLOSE cur_grading_period_details;
        END IF;
      END IF;
    END IF;
    --
    -- If nothing is derived then return 'FINAL'
    --
    RETURN 'FINAL';
    --
  END get_grading_period_code;
END igs_as_derive_grade;

/
