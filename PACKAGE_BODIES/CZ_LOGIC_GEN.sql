--------------------------------------------------------
--  DDL for Package Body CZ_LOGIC_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_LOGIC_GEN" AS
/*	$Header: czlcegnb.pls 120.33.12010000.5 2010/05/18 20:40:59 smanna ship $		*/
---------------------------------------------------------------------------------------
TYPE tShortStringArray      IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE tIntegerArray          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; --kdande; Bug 6881902; 11-Mar-2008
TYPE tIntegerArray_idx_vc2  IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
TYPE refCursor              IS REF CURSOR;
OperatorLiterals            tShortStringArray;
OperatorLetters             tShortStringArray;
CodeByCodeLookup            tIntegerArray;
GenHeader                   VARCHAR2(100) := '$Header: czlcegnb.pls 120.33.12010000.5 2010/05/18 20:40:59 smanna ship $';

DATATYPE_TRANSLATABLE_PROP  CONSTANT PLS_INTEGER := 8;
CZ_SEQUENCE_INCREMENT       CONSTANT NUMBER := 20;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_LOGIC_(inDevlProjectId IN NUMBER,
                          thisRunId       IN OUT NOCOPY NUMBER,
                          TwoPhaseCommit  IN PLS_INTEGER)
IS

  TYPE tStringArray       IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  TYPE tNumberArray       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; --kdande; Bug 6881902; 11-Mar-2008
  TYPE tNumberArray_idx_vc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tDateArray         IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE table_of_number_tables IS TABLE OF tNumberArray INDEX BY BINARY_INTEGER;
  TYPE table_of_tNumberArray_idx_vc2 IS TABLE OF tNumberArray_idx_vc2 INDEX BY BINARY_INTEGER;  -- jonatara:bug7041718
  TYPE tVarcharHashType   IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);

  TYPE tPsNodeId          IS TABLE OF cz_ps_nodes.ps_node_id%TYPE INDEX BY VARCHAR2(15);
  TYPE tItemId            IS TABLE OF cz_ps_nodes.item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPersistentId      IS TABLE OF cz_ps_nodes.persistent_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPersistentId_idx_vc2  IS TABLE OF cz_ps_nodes.persistent_node_id%TYPE INDEX BY VARCHAR2(15);
  TYPE tPsNodeType        IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tInitialValue      IS TABLE OF cz_ps_nodes.initial_value%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tParentId          IS TABLE OF cz_ps_nodes.parent_id%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tMinimum           IS TABLE OF cz_ps_nodes.minimum%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tMaximum           IS TABLE OF cz_ps_nodes.maximum%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tVirtualFlag       IS TABLE OF cz_ps_nodes.virtual_flag%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tFeatureType       IS TABLE OF cz_ps_nodes.feature_type%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tName              IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tDescriptionId     IS TABLE OF cz_ps_nodes.intl_text_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMinimumSel        IS TABLE OF cz_ps_nodes.minimum_selected%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tMaximumSel        IS TABLE OF cz_ps_nodes.maximum_selected%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tBomRequired       IS TABLE OF cz_ps_nodes.bom_required_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tReferenceId       IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tUsageMask         IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDecimalQty        IS TABLE OF cz_ps_nodes.decimal_qty_flag%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tIbTrackable       IS TABLE OF cz_ps_nodes.ib_trackable%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tAccumulator       IS TABLE OF cz_ps_nodes.accumulator_flag%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tInitialNumValue   IS TABLE OF cz_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInstantiableFlag  IS TABLE OF cz_ps_nodes.instantiable_flag%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008
  TYPE tShippableFlag     IS TABLE OF cz_ps_nodes.shippable_item_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tTransactableFlag  IS TABLE OF cz_ps_nodes.inventory_transactable_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tAtoFlag           IS TABLE OF cz_ps_nodes.assemble_to_order_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSerializableFlag  IS TABLE OF cz_ps_nodes.serializable_item_flag%TYPE INDEX BY BINARY_INTEGER;

  TYPE tSetEffFrom        IS TABLE OF cz_effectivity_sets.effective_from%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetEffUntil       IS TABLE OF cz_effectivity_sets.effective_until%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetEffId          IS TABLE OF cz_effectivity_sets.effectivity_set_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSetName           IS TABLE OF cz_effectivity_sets.name%TYPE INDEX BY BINARY_INTEGER;

  TYPE tHeaderId          IS TABLE OF cz_lce_headers.lce_header_id%TYPE INDEX BY VARCHAR2(15);
  TYPE tExplNodeId        IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER; --kdande; Bug 6881902; 11-Mar-2008
  TYPE tExplNodeId_idx_vc2 IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY VARCHAR2(15); --kdande; Bug 6881902; 11-Mar-2008

  TYPE tExprType          IS TABLE OF cz_expression_nodes.expr_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprSubtype       IS TABLE OF cz_expression_nodes.expr_subtype%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprId            IS TABLE OF cz_expression_nodes.expr_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParentId      IS TABLE OF cz_expression_nodes.expr_parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprTemplateId    IS TABLE OF cz_expression_nodes.template_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParamIndex    IS TABLE OF cz_expression_nodes.param_index%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgumentIndex IS TABLE OF cz_expression_nodes.argument_index%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgumentName  IS TABLE OF cz_expression_nodes.argument_name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataType      IS TABLE OF cz_expression_nodes.data_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExpressId         IS TABLE OF cz_expression_nodes.express_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataValue     IS TABLE OF cz_expression_nodes.data_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprPropertyId    IS TABLE OF cz_expression_nodes.property_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPresentType       IS TABLE OF cz_expressions.present_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tOptionId          IS TABLE OF cz_des_chart_cells.secondary_opt_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tConsequentFlag    IS TABLE OF cz_expression_nodes.consequent_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDesFeatureType    IS TABLE OF cz_des_chart_features.feature_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataNumValue  IS TABLE OF cz_expression_nodes.data_num_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgSignature  IS TABLE OF cz_expression_nodes.argument_signature_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParSignature  IS TABLE OF cz_expression_nodes.param_signature_id%TYPE INDEX BY BINARY_INTEGER;

  TYPE tRuleId            IS TABLE OF cz_rules.rule_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tRuleName          IS TABLE OF cz_rules.name%TYPE INDEX BY BINARY_INTEGER;

  TYPE tArgumentName      IS TABLE OF cz_signature_arguments.argument_name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tArgumentIndex     IS TABLE OF cz_signature_arguments.argument_index%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDataType          IS TABLE OF cz_signature_arguments.data_type%TYPE INDEX BY BINARY_INTEGER;

  commit_counter       PLS_INTEGER := 0;
  CommitBlockSize      PLS_INTEGER;
  OptimizeNotTrue      PLS_INTEGER;
  OptimizeAllAnyOf     PLS_INTEGER;
  GenerateGatedCombo   PLS_INTEGER;
  ChangeChildrenOrder  PLS_INTEGER;
  StopOnFatalRuleError PLS_INTEGER;
  GenerateUpdatedOnly  PLS_INTEGER;
  StoreNlsCharacters   VARCHAR2(16) := NlsNumericCharacters;

  rootProjectName      cz_devl_projects.name%TYPE;
  rootProjectType      cz_devl_projects.model_type%TYPE;

  NewHeaders           tIntegerArray;
  OldHeaders           tIntegerArray;
  NewHeadersComponents tIntegerArray;
  NewHeadersExplosions tIntegerArray;
  counterNewHeaders    PLS_INTEGER := 1;

  IsLogicGenerated     tIntegerArray_idx_vc2;
  modelChecked         tIntegerArray_idx_vc2;
  vSeqNbrByHeader      tNumberArray_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008
  v_HeaderByAccId      tHeaderId;
  v_HeaderByNotTrueId  tHeaderId;
  h_HeaderPiDefined    tStringArray;
  h_HeaderEDefined     tStringArray;

  memoryTemplateStart  tIntegerArray;
  memoryTemplateEnd    tIntegerArray;
  v_tTmplNodeId        tExplNodeId;
  v_tTmplType          tExprType;
  v_tTmplSubtype       tExprSubtype;
  v_tTmplId            tExprId;
  v_tTmplParentId      tExprParentId;
  v_tTmplTemplateId    tExprTemplateId;
  v_tTmplExpressId     tExpressId;
  v_tTmplPsNodeId      tExplNodeId;
  v_tTmplDataValue     tExprDataValue;
  v_tTmplDataType      tExprDataType;
  v_tTmplPropertyId    tExprPropertyId;
  v_tTmplArgumentIndex tExprArgumentIndex;
  v_tTmplArgumentName  tExprArgumentName;
  v_tTmplConsequent    tConsequentFlag;

  t_RuleId             tRuleId;
  t_SignatureId        tRuleId;
  t_RuleName           tRuleName;
  h_SeededName         tRuleName;
  h_ReportName         tRuleName;
  h_SignatureId        tRuleId;
  h_SignatureDataType  tIntegerArray;

  glPsNodeId           tPsNodeId;
  glItemId             tItemId;
  glPersistentId       tPersistentId_idx_vc2;
  glReferenceId        tReferenceId;
  glPsNodeType         tPsNodeType;
  glIndexByPsNodeId    tIntegerArray_idx_vc2;
  glLastChildIndex     tIntegerArray_idx_vc2;
  glParentId           tParentId;
  glFeatureType        tFeatureType;
  glName               tName;
  glBomRequired        tBomRequired;
  glHeaderByPsNodeId   tNumberArray_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008
  glEffFrom            tDateArray;
  glEffUntil           tDateArray;
  glUsageMask          tUsageMask;
  glMinimum            tMinimum;
  glMaximum            tMaximum;
  glMinimumSel         tMinimumSel;
  glMaximumSel         tMaximumSel;
  glVirtualFlag        tVirtualFlag;
  glDecimalQty         tDecimalQty;
  glIbTrackable        tIbTrackable;
  glInitialValue       tInitialValue;
  glAccumulator        tAccumulator;
  glInitialNumValue    tInitialNumValue;
  glInstantiableFlag   tInstantiableFlag;
  featOptionsCount     tIntegerArray_idx_vc2;

  v_NodeIdByComponent  tExplNodeId_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008

--Support for effectivity sets
  gvEffFrom            tSetEffFrom;
  gvEffUntil           tSetEffUntil;
  gvSetId              tSetEffId;
  gvIndexBySetId       tIntegerArray;

  globalCount          PLS_INTEGER := 1;
 --Just to support debugging
  nDebug               PLS_INTEGER := 7777777;
 --Auxiliery parameters for reporting
  nParam               NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  errorMessage         VARCHAR2(4000);
  thisName             VARCHAR2(4000);
  parentName           VARCHAR2(4000);

--Referencing level indicator and model stack
  globalLevel          PLS_INTEGER := 0;
  globalStack          tIntegerArray;
  globalRef            tIntegerArray;
  globalInstance       tIntegerArray;
  instanceModel        tIntegerArray_idx_vc2;
  trackableAncestor    tIntegerArray_idx_vc2;

--Set of data for implementing the locking mechanism
  l_msg_data           VARCHAR2(4000);
  l_msg_count          NUMBER := 0;
  l_return_status      VARCHAR2(1);
  l_lock_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_locked_models      cz_security_pvt.number_type_tbl;
  FAILED_TO_LOCK_MODEL EXCEPTION;

 --bug fix 8689041 Modified the criteria to retrieve last_logic_update and logic creation_date
  logicSQL  VARCHAR2(4000) := 'SELECT proj.devl_project_id, max(proj.last_logic_update),max(head.creation_date)' ||
                              '  FROM cz_devl_projects proj, cz_model_ref_expls expl, cz_lce_headers head' ||
                              ' WHERE proj.deleted_flag = ''' || FLAG_NOT_DELETED ||
                              ''' AND expl.deleted_flag = ''' || FLAG_NOT_DELETED ||
                              ''' AND head.deleted_flag = ''' || FLAG_NOT_DELETED ||
                              ''' AND expl.node_depth = 1' ||
                              '   AND expl.model_id = :1' ||
                              '   AND head.net_type in (1,2)' ||
                              '   AND proj.devl_project_id = expl.component_id' ||
                              '   AND proj.devl_project_id = head.component_id' ||
                              '   AND head.component_id = head.devl_project_id' ||
                              '   GROUP BY proj.devl_project_id';


  h_containerReferred  tIntegerArray_idx_vc2;
  containerReferred    VARCHAR2(4000) :=

    'SELECT 1 FROM DUAL WHERE EXISTS' ||
    '  (SELECT model_id FROM cz_model_ref_expls' ||
    '    WHERE deleted_flag = ''' || FLAG_NOT_DELETED || '''' ||
    '      AND ps_node_type IN (' || PS_NODE_TYPE_REFERENCE || ', ' || PS_NODE_TYPE_CONNECTOR || ')' ||
    '      AND component_id = :1' ||
    '      AND (SELECT model_type FROM cz_devl_projects' ||
    '            WHERE devl_project_id = model_id) = ''' || MODEL_TYPE_CONTAINER_MODEL || ''')';

  GENERATION_REQUIRED         CONSTANT PLS_INTEGER := 1;
  GENERATION_NOT_REQUIRED     CONSTANT PLS_INTEGER := 2;

  table_name_generator        PLS_INTEGER := 1;
  table_hash_propval          tVarcharHashType;
---------------------------------------------------------------------------------------
--Bug #5727549.

last_id_allocated  NUMBER := NULL;
next_id_to_use     NUMBER := 0;

FUNCTION next_lce_header_id RETURN NUMBER IS
  id_to_return  NUMBER;
BEGIN
  IF((last_id_allocated IS NULL) OR
     (next_id_to_use = (NVL(last_id_allocated, 0) + CZ_SEQUENCE_INCREMENT)))THEN

    SELECT cz_lce_headers_s.NEXTVAL INTO last_id_allocated FROM DUAL;
    next_id_to_use := last_id_allocated;
  END IF;

  id_to_return := next_id_to_use;
  next_id_to_use := next_id_to_use + 1;
 RETURN id_to_return;
END next_lce_header_id;
---------------------------------------------------------------------------------------
--Reporting procedure

PROCEDURE REPORT(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER) IS
BEGIN

  INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id)
  VALUES (inMessage, nDebug, 'Logic Generator', inUrgency, thisRunId);

EXCEPTION
  WHEN OTHERS THEN
    RAISE CZ_G_UNABLE_TO_REPORT_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE SET_NLS_CHARACTERS(p_nls_characters IN VARCHAR2) IS
BEGIN
  IF(NlsNumericCharacters <> StoreNlsCharacters)THEN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''' || p_nls_characters || '''';
  END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_COMPONENT_TREE(inComponentId         IN NUMBER,
                                  inProjectId           IN NUMBER,
                                  inParentLogicHeaderId IN NUMBER)
IS

 TYPE tNodeDepth      IS TABLE OF cz_model_ref_expls.node_depth%TYPE INDEX BY BINARY_INTEGER;
 TYPE tNodeType       IS TABLE OF cz_model_ref_expls.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tVirtualFlag    IS TABLE OF cz_model_ref_expls.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tParentId       IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tPsNodeId       IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tChildModelExpl IS TABLE OF cz_model_ref_expls.child_model_expl_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExplNodeType   IS TABLE OF cz_model_ref_expls.expl_node_type%TYPE INDEX BY BINARY_INTEGER;
 --kdande; Bug 6881902; 11-Mar-2008; Made the following PLSQL types local to the procedure as they are used for Bulk Collects
 TYPE tPsNodeType     IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tReferenceId    IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tDecimalQty     IS TABLE OF cz_ps_nodes.decimal_qty_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tIbTrackable    IS TABLE OF cz_ps_nodes.ib_trackable%TYPE INDEX BY BINARY_INTEGER;
 TYPE tAccumulator    IS TABLE OF cz_ps_nodes.accumulator_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tInstantiableFlag  IS TABLE OF cz_ps_nodes.instantiable_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tFeatureType       IS TABLE OF cz_ps_nodes.feature_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tName              IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
 TYPE tInitialValue      IS TABLE OF cz_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
 TYPE tMinimum           IS TABLE OF cz_ps_nodes.minimum%TYPE INDEX BY BINARY_INTEGER;
 TYPE tMaximum           IS TABLE OF cz_ps_nodes.maximum%TYPE INDEX BY BINARY_INTEGER;
 TYPE tMinimumSel        IS TABLE OF cz_ps_nodes.minimum_selected%TYPE INDEX BY BINARY_INTEGER;
 TYPE tMaximumSel        IS TABLE OF cz_ps_nodes.maximum_selected%TYPE INDEX BY BINARY_INTEGER;

 ntPsNodeId           tPsNodeId;
 ntItemId             tItemId;
 ntPersistentId       tPersistentId;
 ntPsNodeType         tPsNodeType;
 ntInitialValue       tInitialValue;
 ntParentId           tParentId;
 ntMinimum            tMinimum;
 ntMaximum            tMaximum;
 ntVirtualFlag        tVirtualFlag;
 ntFeatureType        tFeatureType;
 ntName               tName;
 ntDescriptionId      tDescriptionId;
 ntMinimumSel         tMinimumSel;
 ntMaximumSel         tMaximumSel;
 ntBomRequired        tBomRequired;
 ntReferenceId        tReferenceId;
 dtEffFrom            tDateArray;
 dtEffUntil           tDateArray;
 vtUsageMask          tUsageMask;
 ntEffSetId           tSetEffId;
 ntDecimalQty         tDecimalQty;
 ntIbTrackable        tIbTrackable;
 ntAccumulator        tAccumulator;
 ntInitialNumValue    tInitialNumValue;
 ntInstantiableFlag   tInstantiableFlag;
 ntShippableFlag      tShippableFlag;
 ntTransactableFlag   tTransactableFlag;
 ntAtoFlag            tAtoFlag;
 ntSerializableFlag   tSerializableFlag;

 v_tNodeDepth         tNodeDepth;
 v_tNodeType          tNodeType;
 v_tVirtualFlag       tVirtualFlag;
 v_tParentId          tParentId;
 v_tPsNodeId          tPsNodeId;
 v_tReferringId       tPsNodeId;
 v_tChildModelExpl    tChildModelExpl;
 v_tExplNodeType      tExplNodeType;
 v_NodeId             tExplNodeId;

 v_IndexByNodeId      tIntegerArray_idx_vc2;
 v_TypeByExplId       tExplNodeType;

 thisComponentExplId  cz_model_ref_expls.model_ref_expl_id%TYPE;
 thisProjectId        cz_devl_projects.devl_project_id%TYPE;
 thisProjectName      cz_devl_projects.name%TYPE;
 thisProjectType      cz_devl_projects.model_type%TYPE;
 thisRootExplIndex    PLS_INTEGER;

 nStructureHeaderId   cz_lce_headers.lce_header_id%TYPE;
 PrevEffFrom          DATE := EpochBeginDate;
 PrevEffUntil         DATE := EpochEndDate;
 PrevUsageMask        cz_ps_nodes.effective_usage_mask%TYPE := AnyUsageMask;
 CurrentEffFrom       DATE;
 CurrentEffUntil      DATE;
 CurrentUsageMask     cz_ps_nodes.effective_usage_mask%TYPE;
 FeatureEffFrom       DATE;
 FeatureEffUntil      DATE;
 FeatureUsageMask     cz_ps_nodes.effective_usage_mask%TYPE;
 nSequenceNbr         NUMBER := 1;
 vLogicText           VARCHAR2(4000);
 vLogicLine           VARCHAR2(4000);
 vLogicName           VARCHAR2(4000);

 CurrentFromDate      VARCHAR2(25);
 CurrentUntilDate     VARCHAR2(25);
 localMinString       VARCHAR2(25);
 localMaxString       VARCHAR2(25);

 CurrentlyPacking     PLS_INTEGER;
 LastPacked           PLS_INTEGER := PACKING_GENERIC;
 generatingFeature    PLS_INTEGER := 0;

 i                    PLS_INTEGER;
 j                    PLS_INTEGER;
 localCount           PLS_INTEGER;
 optionCounter        PLS_INTEGER;
 trackableContext     NUMBER; -- jonatara:bug7041718
 instantiableContext  NUMBER; -- jonatara:bug7041718
---------------------------------------------------------------------------------------
 PROCEDURE PACK IS
 BEGIN
    IF(vLogicLine IS NOT NULL)THEN
     IF(LENGTHB(vLogicText) + LENGTHB(vLogicLine)>2000)THEN

       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nStructureHeaderId, nSequenceNbr, vLogicText);
       vLogicText := NULL;
       nSequenceNbr := nSequenceNbr + 1;

       --Commit in blocks if not disabled

       IF(TwoPhaseCommit = 0)THEN
         commit_counter := commit_counter + 1;
         IF(commit_counter = CommitBlockSize)THEN
          COMMIT;
          commit_counter := 0;
         END IF;
       END IF;
     END IF;
     vLogicText := vLogicText || vLogicLine;
     vLogicLine := NULL;

     LastPacked := PACKING_GENERIC;

    END IF;
 END PACK;
---------------------------------------------------------------------------------------
 PROCEDURE PACK_EFFECTIVITY IS
 BEGIN
    IF(vLogicLine IS NOT NULL)THEN
     IF(LENGTHB(vLogicText) + LENGTHB(vLogicLine)>2000)THEN

       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nStructureHeaderId, nSequenceNbr, vLogicText);
       vLogicText := NULL;
       nSequenceNbr := nSequenceNbr + 1;

       --Commit in blocks if not disabled

       IF(TwoPhaseCommit = 0)THEN
         commit_counter := commit_counter + 1;
         IF(commit_counter = CommitBlockSize)THEN
          COMMIT;
          commit_counter := 0;
         END IF;
       END IF;
     END IF;

     IF(LastPacked = PACKING_EFFECTIVITY AND CurrentlyPacking = LastPacked)THEN

      --We are inserting one effectivity statement after another. Replace the last
      --one with the current one.

      vLogicText := SUBSTR(vLogicText, 1, INSTR(vLogicText, 'EFF', -1, 1) - 1) || vLogicLine;

     ELSE
       vLogicText := vLogicText || vLogicLine;
     END IF;

     vLogicLine := NULL;
     LastPacked := CurrentlyPacking;

    END IF;
 END PACK_EFFECTIVITY;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_EFFECTIVITY_LOGIC(inCurrentEffFrom   IN DATE,
                                     inCurrentEffUntil  IN DATE,
                                     inCurrentUsageMask IN VARCHAR2) IS
BEGIN
  IF((inCurrentEffFrom <> PrevEffFrom) OR (inCurrentEffUntil <> PrevEffUntil) OR
     (inCurrentUsageMask <> PrevUsageMask))THEN

       vLogicLine := LTRIM(inCurrentUsageMask, '0');
       IF(vLogicLine IS NOT NULL) THEN
         vLogicLine := EffUsagePrefix || vLogicLine;
       END IF;

       IF(inCurrentEffFrom = EpochBeginDate)THEN
         CurrentFromDate := NULL;
       ELSE
         CurrentFromDate := TO_CHAR(inCurrentEffFrom, EffDateFormat);
       END IF;

       IF(inCurrentEffUntil = EpochEndDate)THEN
         CurrentUntilDate := NULL;
       ELSE
         CurrentUntilDate := TO_CHAR(inCurrentEffUntil, EffDateFormat);
       END IF;

       vLogicLine := 'EFF ' || CurrentFromDate || ', ' || CurrentUntilDate || ', ' || vLogicLine || NewLine;

       CurrentlyPacking := PACKING_EFFECTIVITY;
       PACK_EFFECTIVITY;

       PrevEffFrom := inCurrentEffFrom;
       PrevEffUntil := inCurrentEffUntil;
       PrevUsageMask := inCurrentUsageMask;
  END IF;
END;
---------------------------------------------------------------------------------------
--This procedure is used for marking BOM items that are ancestors of a trackable BOM
--item. Such items cannot have default quantity greater than 1, and cannot be on the
--RHS of a numeric rule.
--The procedure can be called only for a BOM Option Class or Standard or a reference,
--so parent always exists.

PROCEDURE PROPAGATE_TRACKABLE_ANCESTOR IS

  auxIndex  NUMBER := glIndexByPsNodeId(ntParentId(i));  --kdande; Bug 6881902; 11-Mar-2008
BEGIN
  WHILE((NOT trackableAncestor.EXISTS(glPsNodeId(auxIndex))) AND
        glPsNodeType(auxIndex) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))LOOP

    IF(glInitialValue(auxIndex) > 1)THEN

      nParam := auxIndex;
      RAISE CZ_S_INCORRECT_QUANTITY;
    END IF;

    trackableAncestor(glPsNodeId(auxIndex)) := 1;
    EXIT WHEN glParentId(auxIndex) IS NULL;

    auxIndex := glIndexByPsNodeId(glParentId(auxIndex));
  END LOOP;
END;
---------------------------------------------------------------------------------------
FUNCTION IS_NODE_LOGICAL(j IN PLS_INTEGER) RETURN BOOLEAN IS
  l_node_type  NUMBER := ntPsNodeType(j);
BEGIN
  RETURN
    l_node_type <> PS_NODE_TYPE_TOTAL AND l_node_type <> PS_NODE_TYPE_RESOURCE AND
    (l_node_type <> PS_NODE_TYPE_FEATURE OR
       ntFeatureType(j) IN (PS_NODE_FEATURE_TYPE_BOOLEAN, PS_NODE_FEATURE_TYPE_OPTION) OR
         (ntFeatureType(j) = PS_NODE_FEATURE_TYPE_INTEGER AND
          ntMinimum(j) IS NOT NULL AND ntMinimum(j) >= 0));
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_ACCUMULATOR(j IN PLS_INTEGER) IS
BEGIN

  --Check if we need to create an accumulator for this node. Note that accumulator must be
  --always effective. Part of the fix for the bug #2857955.

  IF(ntAccumulator(j) IS NOT NULL AND ntAccumulator(j) <> FLAG_NO_ACCUMULATOR)THEN

    GENERATE_EFFECTIVITY_LOGIC(EpochBeginDate, EpochEndDate, AnyUsageMask);
    vLogicName := 'P_' || TO_CHAR(ntPersistentId(j));

    IF((NOT v_HeaderByAccId.EXISTS(ntPsNodeId(j))) AND
       TO_NUMBER(UTL_RAW.BIT_AND(ntAccumulator(j), FLAG_ACCUMULATOR_ACC)) = TO_NUMBER(FLAG_ACCUMULATOR_ACC))THEN

      vLogicLine := 'TOTAL ' || vLogicName || '_ACC' || NewLine ||
                    'INC ' || vLogicName || '_ACC' || ' ' || vLogicName ||
                    OperatorLiterals(OPERATOR_ROUND) || NewLine;

      v_HeaderByAccId(ntPsNodeId(j)) := nStructureHeaderId;
    END IF;

    IF((NOT v_HeaderByNotTrueId.EXISTS(ntPsNodeId(j))) AND
       TO_NUMBER(UTL_RAW.BIT_AND(ntAccumulator(j), FLAG_ACCUMULATOR_NT)) = TO_NUMBER(FLAG_ACCUMULATOR_NT))THEN

      --Bug #5015333. Only node that has a 'logical' value can have this type of accumulator. Initially the
      --accumulator_flag may have been set by a NOTTRUE operator. At this time the node had to have logical
      --value, otherwise the rule would have been rejected by a verification (HAS_LOGICAL_VALUE function in
      --GENERATE_NOTTRUE procedure). However later the rule may have been deleted, and the type of the node
      --changed, so that the node does not have a 'logical' value anymore. As the accumulator_flag is still
      --set, the code below will create a 'logical' relation that may crash the engine.

      IF(IS_NODE_LOGICAL(j))THEN

        vLogicLine := 'OBJECT ' || vLogicName || '_NT' || NewLine ||
                      'NOTTRUE ' || vLogicName || ' ' || vLogicName || '_NT' || NewLine;
        v_HeaderByNotTrueId(ntPsNodeId(j)) := nStructureHeaderId;

      ELSE

        --Although it is not necessary to reset the accumulator_flag here, doing so will allow to skip this
        --verification in the future. This should not have any effect on the currency of the model's logic.

        UPDATE cz_ps_nodes SET
             accumulator_flag = TO_CHAR(TO_NUMBER(UTL_RAW.BIT_AND(ntAccumulator(j), FLAG_ACCUMULATOR_ACC)))
         WHERE ps_node_id = ntPsNodeId(j);
      END IF;
    END IF;

    PACK;
  END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_RULES IS

 TYPE iteratorNode       IS RECORD (node_type  NUMBER,
                                    node_id    NUMBER,
                                    node_value VARCHAR2(4000),
                                    node_obj   VARCHAR2(4000),
                                    node_id_ex NUMBER);
 TYPE tIteratorArray     IS TABLE OF iteratorNode INDEX BY BINARY_INTEGER;

 --The cursor returns all the rules assigned in this project (model).

 CURSOR c_rules IS
  SELECT rule_id, rule_type, antecedent_id, consequent_id, name, reason_id,
         expr_rule_type, rule_folder_id, component_id, model_ref_expl_id,
         effective_from, effective_until, effective_usage_mask, effectivity_set_id,
         unsatisfied_msg_id, unsatisfied_msg_source, presentation_flag, class_name
  FROM cz_rules
  WHERE devl_project_id = inComponentId
    AND deleted_flag = FLAG_NOT_DELETED
    AND disabled_flag = FLAG_NOT_DISABLED;

 v_tExplNodeId        tExplNodeId;
 v_tExprType          tExprType;
 v_tExprSubtype       tExprSubtype;
 v_tExprId            tExprId;
 v_tExprParentId      tExprParentId;
 v_tExprTemplateId    tExprTemplateId;
 v_tExprParamIndex    tExprParamIndex;
 v_tExprArgumentName  tExprArgumentName;
 v_tExprDataType      tExprDataType;
 v_tExpressId         tExpressId;
 v_tExprPsNodeId      tExplNodeId;
 v_tRealPsNodeId      tExplNodeId;
 v_tExprDataValue     tExprDataValue;
 v_tExprPropertyId    tExprPropertyId;
 v_tConsequentFlag    tConsequentFlag;
 v_tFeatureType       tDesFeatureType;
 v_tExprDataNumValue  tExprDataNumValue;
 v_tExprArgSignature  tExprArgSignature;
 v_tExprParSignature  tExprParSignature;
 v_LoadConditionId    tExplNodeId;
 v_ExplByPsNodeId     tExplNodeId_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008

 v_tArgumentName      tArgumentName;
 v_tArgumentIndex     tArgumentIndex;
 v_tDataType          tDataType;

 v_InstByLevel        tIntegerArray;
 v_IndexByExprNodeId  tIntegerArray_idx_vc2;
 v_Assignable         tIntegerArray;
 v_Participant        tIntegerArray;
 v_DistinctIndex      tIntegerArray;
 v_ParticipantIndex   tIntegerArray;
 v_RuleConnectorNet   tIntegerArray;
 v_LevelCount         tIntegerArray;
 v_LevelIndex         tIntegerArray;
 v_LevelType          tIntegerArray;
 v_MarkLoadCondition  tIntegerArray;
 v_tIsHeaderGenerated tIntegerArray;
 v_tSequenceNbr       tIntegerArray;
 v_tLogicNetType      tIntegerArray;

 v_NodeLogicLevel     tIntegerArray;
 v_NodeAssignable     tIntegerArray;
 v_NodeInstantiable   tIntegerArray;
 v_NodeTrackable      tIntegerArray;
 v_IsConnectorNet     tIntegerArray;
 v_ChildrenIndex      tIntegerArray_idx_vc2;
 v_NumberOfChildren   tIntegerArray_idx_vc2;
 v_MaxRuleExists      tIntegerArray;
 v_ProhibitInRules    tIntegerArray;
 v_ProhibitOptional   tIntegerArray;
 v_ProhibitConnector  tIntegerArray;
 v_NodeIndexPath      tIntegerArray;
 v_NodeDownPath       tStringArray;
 v_RelativeNodePath   tStringArray;
 v_AssignedDownPath   tStringArray;
 v_NodeUpPath         tStringArray;
 v_RuleQualifiedName  tStringArray;
 v_FuncQualifiedName  tStringArray;

 v_LoadHeaders        tHeaderId;
 v_LoadConditions     tStringArray;

 h_EffFrom            tDateArray;
 h_EffUntil           tDateArray;
 h_EffUsageMask       tUsageMask;

 PrevRuleEffFrom      tDateArray;
 PrevRuleEffUntil     tDateArray;
 PrevRuleUsageMask    tUsageMask;

 nAntecedentId        cz_rules.antecedent_id%TYPE;
 nConsequentId        cz_rules.consequent_id%TYPE;
 nRuleId              cz_rules.rule_id%TYPE;
 nRuleFolderId        cz_rules.rule_folder_id%TYPE;
 nRuleType            cz_rules.rule_type%TYPE;
 RuleTemplateType     cz_rules.rule_type%TYPE;
 nRuleOperator        cz_rules.expr_rule_type%TYPE;
 nReasonId            cz_rules.reason_id%TYPE;
 nComponentId         cz_rules.component_id%TYPE;
 nModelRefExplId      cz_rules.model_ref_expl_id%TYPE;
 dEffFrom             cz_rules.effective_from%TYPE;
 dEffUntil            cz_rules.effective_until%TYPE;
 nRuleEffSetId        cz_rules.effectivity_set_id%TYPE;
 nUnsatisfiedId       cz_rules.unsatisfied_msg_id%TYPE;
 nUnsatisfiedSource   cz_rules.unsatisfied_msg_source%TYPE;
 nPresentationFlag    cz_rules.presentation_flag%TYPE;
 vRuleName            cz_rules.name%TYPE;
 vUsageMask           cz_rules.effective_usage_mask%TYPE;
 vClassName           cz_rules.class_name%TYPE;
 MaxDepthId           cz_model_ref_expls.model_ref_expl_id%TYPE;
 nAux                 cz_model_ref_expls.model_ref_expl_id%TYPE;
 MaxDepthValue        cz_model_ref_expls.node_depth%TYPE;
 baseDepthValue       cz_model_ref_expls.node_depth%TYPE;
 nHeaderId            cz_lce_headers.lce_header_id%TYPE;
 nPreviousHeaderId    cz_lce_headers.lce_header_id%TYPE;
 nNewLogicFileFlag    PLS_INTEGER := 0;
 nRuleAssignedLevel   PLS_INTEGER;
 MaxDepthIndex        PLS_INTEGER;
 logicNetType         PLS_INTEGER;
 expressionSize       PLS_INTEGER;
 expressionStart      PLS_INTEGER;
 expressionEnd        PLS_INTEGER;
 numericLHS           PLS_INTEGER;
 generateCompare      PLS_INTEGER;
 generateCollect      PLS_INTEGER;

 ConnectorIndex       PLS_INTEGER;
 InstantiableIndex    PLS_INTEGER;
 OptionalIndex        PLS_INTEGER;
 AssignableIndex      PLS_INTEGER;
 TrackableIndex       PLS_INTEGER;

 jAntecedentRoot      PLS_INTEGER;
 jConsequentRoot      PLS_INTEGER;
 jAntecedentRootCount PLS_INTEGER;
 jConsequentRootCount PLS_INTEGER;
 ListType             PLS_INTEGER;
 nLocalDefaults       PLS_INTEGER := 0;
 nLocalExprId         PLS_INTEGER := 1000;

 nCounter             PLS_INTEGER;
 distinctCount        PLS_INTEGER;
 participantCount     PLS_INTEGER;
 localFeatureType     PLS_INTEGER;
 localMinimum         PLS_INTEGER;
 auxIndex             NUMBER; --kdande; Bug 6881902; 11-Mar-2008
 auxCount             NUMBER; --kdande; Bug 6881902; 11-Mar-2008
 localString          VARCHAR2(32000);
 pathString           VARCHAR2(32000);
 baseString           VARCHAR2(32000);
 localNodeId          NUMBER;
 localRunId           NUMBER;

 generateRound        PLS_INTEGER;
 optimizeChain        PLS_INTEGER;
 optimizeContribute   PLS_INTEGER;
 optimizeTarget       VARCHAR2(4000);
 t_prefix             VARCHAR2(128);

 returnListType       PLS_INTEGER;
 returnStringArray    tStringArray;

 parameterScope       tIteratorArray;
 parameterName        tStringArray;

 --This type is used when it is necessary to hash a table name by a text key.

 TYPE temp_table_hash_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(4000);
 temp_table_hash      temp_table_hash_type;
 temp_cmpt_table_hash temp_table_hash_type;

 --Some of the variables are level specific for embedded FORALL, so we need to know the
 --the current level. One example is the table hash key below.
 --COMPATIBLE currently cannot be embedded, so the variable will never be greater than 1.

 forallLevel          PLS_INTEGER := 0;
 compatLevel          PLS_INTEGER := 0;

 --This key is used to identify a temporary table constructed for an iterator and hash its
 --name in temp_table_hash or temp_cmpt_table_hash.
 --The format of this key is:
 --<ps_node_id>-<model_ref_expl_id>-<property_id-1>-...-<property_id_N>

 --We need tables of keys because of the possibility of embedded FORALL - on every level
 --the level specific key should be considered.
 --Although currently FORALL cannot be embedded into COMPATIBLE, this may change in the
 --future, therefore it is better to have separate keys.

 temp_table_hash_key  tStringArray;
 temp_cmpt_hash_key   tStringArray;

 --This is a universal array accumulating all the temp tables we need to delete across
 --all FORALL(s) and COMPATIBLE(s).

 temp_tables          tStringArray;

 --For logic and comparison rules having an unsatisified message (unsatisfied_msg_source <> 0)
 --this string will be populated with unsatisfied_msg_id, and used as a part of GS syntax when
 --the relation has more then one operand on either side. For all the other types of rules the
 --string will be null.

 sUnsatisfiedId       VARCHAR2(4000);
---------------------------------------------------------------------------------------
FUNCTION GET_PROPERTY_VALUE(p_node_id     IN cz_ps_nodes.ps_node_id%TYPE,
                            p_property_id IN cz_properties.property_id%TYPE,
                            p_item_id     IN cz_item_masters.item_id%TYPE,
                            x_data_type   IN OUT NOCOPY cz_properties.data_type%TYPE)
  RETURN VARCHAR2 IS
    l_def_value  cz_properties.def_value%TYPE;
    l_tab        tStringArray;
BEGIN

  SELECT NVL(TO_CHAR(def_num_value), def_value), data_type INTO l_def_value, x_data_type
    FROM cz_properties
   WHERE property_id = p_property_id
     AND deleted_flag = FLAG_NOT_DELETED;

  SELECT NVL(TO_CHAR(data_num_value), data_value) BULK COLLECT INTO l_tab
    FROM cz_ps_prop_vals
   WHERE ps_node_id = p_node_id
     AND property_id = p_property_id
     AND deleted_flag = FLAG_NOT_DELETED;

  IF(l_tab.COUNT = 0 AND p_item_id IS NOT NULL)THEN

     SELECT NVL(TO_CHAR(property_num_value), property_value) BULK COLLECT INTO l_tab
       FROM cz_item_property_values
      WHERE property_id = p_property_id
        AND item_id = p_item_id
        AND deleted_flag = FLAG_NOT_DELETED;

     IF(l_tab.COUNT = 0)THEN

         SELECT NULL BULK COLLECT INTO l_tab
           FROM cz_item_type_properties t, cz_item_masters m
          WHERE m.item_id = p_item_id
            AND m.deleted_flag = FLAG_NOT_DELETED
            AND t.deleted_flag = FLAG_NOT_DELETED
            AND t.property_id = p_property_id
            AND t.item_type_id = m.item_type_id;
     END IF;
  END IF;

  IF(l_tab.EXISTS(1))THEN

    IF(x_data_type = DATATYPE_TRANSLATABLE_PROP)THEN

      SELECT localized_str INTO l_tab(1) FROM cz_localized_texts
       WHERE intl_text_id = l_tab(1) AND language = USERENV('LANG');

      IF(l_tab(1) IS NULL)THEN

        SELECT localized_str INTO l_tab(1) FROM cz_localized_texts
         WHERE intl_text_id = l_def_value AND language = USERENV('LANG');
      END IF;
    END IF;

     RETURN NVL(l_tab(1), l_def_value);
  END IF;

  x_data_type := NULL;
  RETURN NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_data_type := NULL;
    RETURN NULL;
END;
---------------------------------------------------------------------------------------
--The local procedure is required because the sequence numbers must be different
--Still works with global buffers and commit parameters

 PROCEDURE PACK IS
 BEGIN
    IF(vLogicLine IS NOT NULL)THEN
     IF(LENGTHB(vLogicText) + LENGTHB(vLogicLine)>2000)THEN

       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nHeaderId, v_tSequenceNbr(nHeaderId), vLogicText);
       vLogicText := NULL;
       v_tSequenceNbr(nHeaderId) := v_tSequenceNbr(nHeaderId) + 1;

       --Commit in blocks if not disabled

       IF(TwoPhaseCommit = 0)THEN
         commit_counter := commit_counter + 1;
         IF(commit_counter = CommitBlockSize)THEN
          COMMIT;
          commit_counter := 0;
         END IF;
       END IF;
     END IF;
     vLogicText := vLogicText || vLogicLine;
     vLogicLine := NULL;
    END IF;
 END PACK;
---------------------------------------------------------------------------------------
--This function returns fully qualified rule name given rule_folder_id of a rule
--and puts generated names into a hash table for reuse.

FUNCTION RULE_NAME RETURN VARCHAR2 IS
  vQualified  VARCHAR2(4000) := '.';
  nRuleName   PLS_INTEGER;
BEGIN
  IF(nRuleFolderId IS NULL OR nRuleFolderId = -1)THEN RETURN vRuleName; END IF;
  IF(v_RuleQualifiedName.EXISTS(nRuleFolderId))THEN RETURN v_RuleQualifiedName(nRuleFolderId) || vRuleName; END IF;
  nRuleName := LENGTHB(vRuleName);
  FOR folder IN (SELECT name FROM cz_rule_folders
                  WHERE deleted_flag = FLAG_NOT_DELETED
                    AND parent_rule_folder_id IS NOT NULL
                  START WITH rule_folder_id = nRuleFolderId
                    AND object_type = 'RFL'
                CONNECT BY PRIOR parent_rule_folder_id = rule_folder_id
                    AND object_type = 'RFL')LOOP
     IF(LENGTHB(folder.name) + LENGTHB(vQualified) + 1 < 2000 - nRuleName)THEN
      vQualified := '.' || folder.name || vQualified;
     ELSE
      EXIT;
     END IF;
  END LOOP;
  v_RuleQualifiedName(nRuleFolderId) := vQualified;
  RETURN vQualified || vRuleName;
END;
---------------------------------------------------------------------------------------
--This function returns fully qualified name of a functional companion given
--rule_folder_id.

FUNCTION COMPANION_NAME(inCompanionName IN VARCHAR2, inFolderId IN NUMBER) RETURN VARCHAR2 IS
  vQualified  VARCHAR2(4000) := '.';
  nameLen     PLS_INTEGER;
BEGIN
  IF(inFolderId IS NULL OR inFolderId = -1)THEN RETURN inCompanionName; END IF;
  IF(v_FuncQualifiedName.EXISTS(inFolderId))THEN RETURN v_FuncQualifiedName(inFolderId) || inCompanionName; END IF;
  nameLen := LENGTHB(inCompanionName);
  FOR folder IN (SELECT name FROM cz_rule_folders
                  WHERE deleted_flag = FLAG_NOT_DELETED
                    AND parent_rule_folder_id IS NOT NULL
                 START WITH rule_folder_id = inFolderId
                 CONNECT BY PRIOR parent_rule_folder_id = rule_folder_id)LOOP
     IF(LENGTHB(folder.name) + LENGTHB(vQualified) + 1 < 2000 - nameLen)THEN
      vQualified := '.' || folder.name || vQualified;
     ELSE
      EXIT;
     END IF;
  END LOOP;
  v_FuncQualifiedName(inFolderId) := vQualified;
  RETURN vQualified || inCompanionName;
END;
---------------------------------------------------------------------------------------
--The ps_node_id value is fixed in the memory for references to BOM. This function can
--be called when the original value (ps_node_id of the reference node) is required.

FUNCTION REAL_PS_NODE_ID(j IN PLS_INTEGER) RETURN NUMBER IS
BEGIN
  IF(v_tRealPsNodeId.EXISTS(j))THEN RETURN v_tRealPsNodeId(j); ELSE RETURN v_tExprPsNodeId(j); END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION SIGNATURE_DATA_TYPE(p_signature_id IN NUMBER) RETURN PLS_INTEGER IS
  v_data_type  PLS_INTEGER;
BEGIN
  IF(h_SignatureDataType.EXISTS(p_signature_id))THEN RETURN h_SignatureDataType(p_signature_id); END IF;

  BEGIN
    SELECT data_type INTO v_data_type FROM cz_signatures
     WHERE deleted_flag = FLAG_NOT_DELETED
       AND signature_id = p_signature_id;

    h_SignatureDataType(p_signature_id) := v_data_type;
    RETURN v_data_type;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE CZ_R_NO_SIGNATURE_ID;
  END;
END;
---------------------------------------------------------------------------------------
FUNCTION COMPATIBLE_DATA_TYPES(p_object_type IN PLS_INTEGER, p_subject_type PLS_INTEGER) RETURN BOOLEAN IS
  v_null  PLS_INTEGER;
BEGIN
  SELECT NULL INTO v_null FROM cz_conversion_rels_v
   WHERE object_type = p_object_type AND subject_type = p_subject_type;
  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RETURN FALSE;
END;
---------------------------------------------------------------------------------------
FUNCTION GET_ARGUMENT_INFO(p_param_index  IN NUMBER,
                           p_signature_id IN NUMBER,
                           x_mutable      IN OUT NOCOPY VARCHAR2,
                           x_collection   IN OUT NOCOPY VARCHAR2)
RETURN NUMBER IS
  v_data_type  cz_signature_arguments.data_type%TYPE;
BEGIN
  SELECT data_type, mutable_flag, collection_flag INTO v_data_type, x_mutable, x_collection
    FROM cz_signature_arguments
   WHERE deleted_flag = FLAG_NOT_DELETED
     AND argument_signature_id = p_signature_id
     AND argument_index = p_param_index;
  RETURN v_data_type;
EXCEPTION
  WHEN OTHERS THEN
    RETURN DATA_TYPE_VOID;
END;
---------------------------------------------------------------------------------------
FUNCTION APPLICABLE_SYS_PROP(j IN PLS_INTEGER, p_ps_node_id IN NUMBER, p_rule_id IN NUMBER) RETURN BOOLEAN IS
  v_null        PLS_INTEGER;
  v_ps_node_id  NUMBER;
  v_data_type   cz_signature_arguments.data_type%TYPE;
  v_mutable     cz_signature_arguments.mutable_flag%TYPE;
  v_collection  cz_signature_arguments.collection_flag%TYPE;
BEGIN

  --Some of the upgraded rules may not have param_index and param_signature_id populated. However, upgraded
  --rules are not real statement rules, so they are not supposed to have any user error in them and in this
  --case the verification is not required.

  IF(v_tExprParamIndex(j) IS NULL OR v_tExprParSignature(j) IS NULL)THEN RETURN TRUE; END IF;

  IF(p_ps_node_id IS NULL)THEN v_ps_node_id := REAL_PS_NODE_ID(j); ELSE v_ps_node_id := p_ps_node_id; END IF;
  v_data_type := GET_ARGUMENT_INFO(v_tExprParamIndex(j), v_tExprParSignature(j), v_mutable, v_collection);

  SELECT NULL INTO v_null
    FROM cz_rul_typedpsn_v psn,
         cz_conversion_rels_v cnv,
         cz_system_property_rels_v rel,
         cz_system_properties_v sys,
         cz_conversion_rels_v cnv2
   WHERE psn.detailed_type_id = cnv.object_type
     AND cnv.subject_type = rel.subject_type
     AND rel.object_type = sys.rule_id
     AND rel.rel_type_code = 'SYS'
     AND sys.data_type = cnv2.object_type
     AND psn.ps_node_id = v_ps_node_id
     AND sys.rule_id = p_rule_id
     AND sys.mutable_flag >= v_mutable
     AND sys.collection_flag <= v_collection
     AND cnv2.subject_type = v_data_type;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RETURN FALSE;
END;
---------------------------------------------------------------------------------------
FUNCTION APPLICABLE_SYS_PROP(j IN PLS_INTEGER, p_ps_node_id IN NUMBER, p_rule_name IN VARCHAR2) RETURN BOOLEAN IS
  v_null        PLS_INTEGER;
  v_ps_node_id  NUMBER;
  v_data_type   cz_signature_arguments.data_type%TYPE;
  v_mutable     cz_signature_arguments.mutable_flag%TYPE;
  v_collection  cz_signature_arguments.collection_flag%TYPE;
BEGIN

  --Some of the upgraded rules may not have param_index and param_signature_id populated. However, upgraded
  --rules are not real statement rules, so they are not supposed to have any user error in them and in this
  --case the verification is not required.

  IF(v_tExprParamIndex(j) IS NULL OR v_tExprParSignature(j) IS NULL)THEN RETURN TRUE; END IF;

  IF(p_ps_node_id IS NULL)THEN v_ps_node_id := REAL_PS_NODE_ID(j); ELSE v_ps_node_id := p_ps_node_id; END IF;
  v_data_type := GET_ARGUMENT_INFO(v_tExprParamIndex(j), v_tExprParSignature(j), v_mutable, v_collection);

  SELECT NULL INTO v_null
    FROM cz_rul_typedpsn_v psn,
         cz_conversion_rels_v cnv,
         cz_system_property_rels_v rel,
         cz_system_properties_v sys,
         cz_conversion_rels_v cnv2
   WHERE psn.detailed_type_id = cnv.object_type
     AND cnv.subject_type = rel.subject_type
     AND rel.object_type = sys.rule_id
     AND rel.rel_type_code = 'SYS'
     AND sys.data_type = cnv2.object_type
     AND psn.ps_node_id = v_ps_node_id
     AND UPPER(sys.name) = p_rule_name
     AND sys.mutable_flag >= v_mutable
     AND sys.collection_flag <= v_collection
     AND cnv2.subject_type = v_data_type;

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RETURN FALSE;
END;
---------------------------------------------------------------------------------------
--Splits the CHR(7)-separated path into an array of node names.

FUNCTION SPLIT_PATH(p_path IN VARCHAR2) RETURN tStringArray IS

  l_substr      VARCHAR2(32000) := p_path;
  l_index       PLS_INTEGER;
  l_return_tbl  tStringArray;
BEGIN

  IF(p_path IS NULL)THEN RETURN l_return_tbl; END IF;
  LOOP

    l_index := INSTR(l_substr, FND_GLOBAL.LOCAL_CHR(7));

    IF(l_index > 0)THEN

      l_return_tbl(l_return_tbl.COUNT + 1) := SUBSTR(l_substr, 1, l_index - 1);
      l_substr := SUBSTR(l_substr, l_index + 1);
    ELSE

      l_return_tbl(l_return_tbl.COUNT + 1) := l_substr;
      EXIT;
    END IF;
  END LOOP;

  RETURN l_return_tbl;
END;
---------------------------------------------------------------------------------------
PROCEDURE RESOLVE_NODE(p_node_tbl        IN tStringArray,
                       p_parent_node_id  IN NUMBER,
                       p_parent_expl_id  IN NUMBER,
                       x_child_node_id   IN OUT NOCOPY NUMBER,
                       x_child_expl_id   IN OUT NOCOPY NUMBER) IS

  l_eff_from            DATE := EpochBeginDate;
  l_eff_until           DATE := EpochEndDate;
  l_index               PLS_INTEGER;
  l_parent_id           NUMBER;

  l_return_node_id_tbl  tNumberArray;
  l_return_expl_id_tbl  tNumberArray;

  FUNCTION REPORT_PATH RETURN VARCHAR2 IS

    l_return  VARCHAR2(32000) := NULL;
  BEGIN

    FOR i IN 1..p_node_tbl.COUNT LOOP

      IF(l_return IS NOT NULL)THEN l_return := l_return || '.'; END IF;
      l_return := l_return || p_node_tbl(i);
    END LOOP;
   RETURN l_return;
  END;

  PROCEDURE RESOLVE_CHILDREN(p_index      IN PLS_INTEGER,
                             p_node_id    IN NUMBER,
                             p_expl_id    IN NUMBER,
                             p_eff_from   IN DATE,
                             p_eff_until  IN DATE) IS

    t_eff_from_tbl   tDateArray;
    t_eff_until_tbl  tDateArray;
    t_node_id_tbl    tNumberArray;
    t_expl_id_tbl    tNumberArray;
    l_eff_from_tbl   tDateArray;
    l_eff_until_tbl  tDateArray;
    l_node_id_tbl    tNumberArray;
    l_expl_id_tbl    tNumberArray;

    l_counter        PLS_INTEGER := 0;
    l_index          PLS_INTEGER;
  BEGIN

    SELECT ps_node_id, model_ref_expl_id, effective_from, effective_until
      BULK COLLECT INTO l_node_id_tbl, l_expl_id_tbl, l_eff_from_tbl, l_eff_until_tbl
      FROM cz_explmodel_nodes_v
     WHERE model_id = inComponentId
       AND parent_psnode_expl_id = p_expl_id
       AND effective_parent_id = p_node_id
       AND suppress_flag = '0'
       AND name = p_node_tbl(p_index);

    FOR i IN 1..l_node_id_tbl.COUNT LOOP

      IF(p_eff_from > l_eff_from_tbl(i))THEN l_eff_from_tbl(i) := p_eff_from; END IF;
      IF(p_eff_until < l_eff_until_tbl(i))THEN l_eff_until_tbl(i) := p_eff_until; END IF;

      IF(l_eff_from_tbl(i) <= l_eff_until_tbl(i))THEN

        l_counter := l_counter + 1;

        t_eff_from_tbl(l_counter) := l_eff_from_tbl(i);
        t_eff_until_tbl(l_counter) := l_eff_until_tbl(i);
        t_node_id_tbl(l_counter) := l_node_id_tbl(i);
        t_expl_id_tbl(l_counter) := l_expl_id_tbl(i);
      END IF;
    END LOOP;

    FOR i IN 1..t_node_id_tbl.COUNT LOOP

      IF(p_index = p_node_tbl.COUNT)THEN

        l_index := l_return_node_id_tbl.COUNT + 1;

        l_return_node_id_tbl(l_index) := t_node_id_tbl(i);
        l_return_expl_id_tbl(l_index) := t_expl_id_tbl(i);
      ELSE

        RESOLVE_CHILDREN(p_index + 1, t_node_id_tbl(i), t_expl_id_tbl(i), t_eff_from_tbl(i), t_eff_until_tbl(i));
      END IF;
    END LOOP;
  END;
BEGIN

  --Propagate effectivity from all the bom references down from the root model.

  FOR i IN 1..globalLevel LOOP

    --We need to stop on the model, in which the rule is defined.

    IF(globalStack(i) = inComponentId)THEN EXIT; END IF;

    --Account only for references to bom(s).

    IF(glPsNodeType(glIndexByPsNodeId(globalStack(i))) IN (PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTIONCLASS,PS_NODE_TYPE_BOM_STANDARD))THEN

      l_index := glIndexByPsNodeId(globalRef(i));

      IF(glEffFrom(l_index) > l_eff_from)THEN l_eff_from := glEffFrom(l_index); END IF;
      IF(glEffUntil(l_index) < l_eff_until)THEN l_eff_until := glEffUntil(l_index); END IF;
    END IF;
  END LOOP;

  --Adjust effectivities for the least unambiguous parent.

  l_index := glIndexByPsNodeId(p_parent_node_id);

  IF(glEffFrom(l_index) > l_eff_from)THEN l_eff_from := glEffFrom(l_index); END IF;
  IF(glEffUntil(l_index) < l_eff_until)THEN l_eff_until := glEffUntil(l_index); END IF;

  --Finally adjust for the rule effectivity.

  IF(dEffFrom > l_eff_from)THEN l_eff_from := dEffFrom; END IF;
  IF(dEffUntil < l_eff_until)THEN l_eff_until := dEffUntil; END IF;

  --If effectivity range is empty, it will be impossible to resolve the node.

  IF(l_eff_until < l_eff_from)THEN

    localString := REPORT_PATH;
    RAISE CZ_R_INCORRECT_REFERENCE;
  END IF;

  IF(p_node_tbl.COUNT = 0)THEN

    x_child_node_id := p_parent_node_id;
    x_child_expl_id := p_parent_expl_id;
    RETURN;
  END IF;

  RESOLVE_CHILDREN(1, p_parent_node_id, p_parent_expl_id, l_eff_from, l_eff_until);

  IF(l_return_node_id_tbl.COUNT = 0)THEN

    localString := REPORT_PATH;
    RAISE CZ_R_INCORRECT_REFERENCE;
  ELSIF(l_return_node_id_tbl.COUNT > 1)THEN

    localString := REPORT_PATH;
    RAISE CZ_R_AMBIGUOUS_REFERENCE;
  ELSE

    x_child_node_id := l_return_node_id_tbl(1);
    x_child_expl_id := l_return_expl_id_tbl(1);
  END IF;
END;
---------------------------------------------------------------------------------------
--Forward declarations block.

FUNCTION GENERATE_EXPRESSION(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray;
FUNCTION GENERATE_REFNODE(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray;
FUNCTION LOOKUP_ARGUMENT(j IN PLS_INTEGER) RETURN PLS_INTEGER;
FUNCTION GENERATE_ARGUMENT(j IN PLS_INTEGER, ListType IN OUT NOCOPY PLS_INTEGER) RETURN tStringArray;
---------------------------------------------------------------------------------------
FUNCTION HAS_LOGICAL_VALUE(j IN PLS_INTEGER) RETURN BOOLEAN IS
  NodeType     PLS_INTEGER := v_tExprType(j);
  PsNodeType   PLS_INTEGER;
  PsNodeIndex  PLS_INTEGER;
BEGIN

  --When the validation is made from the high-level section of a logic rule, some of the participants
  --may still be arguments, so we need to look up the value of the argument before validating its
  --type. The argument in this case can be either a literal or a node (bug #3388169).

  IF(NodeType = EXPR_ARGUMENT)THEN

    PsNodeIndex := LOOKUP_ARGUMENT(j);
    IF(parameterScope(PsNodeIndex).node_id IS NULL)THEN RETURN FALSE; END IF;

    NodeType := EXPR_PSNODE;
    v_tExprPsNodeId(j) := parameterScope(PsNodeIndex).node_id;
  END IF;

  IF(NodeType = EXPR_NODE_TYPE_LITERAL)THEN
    RETURN (v_tExprDataType(j) = DATA_TYPE_BOOLEAN);
  ELSIF(NodeType = EXPR_PSNODE)THEN
    IF(v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN RETURN TRUE;
    ELSE

      PsNodeIndex := glIndexByPsNodeId(v_tExprPsNodeId(j));
      PsNodeType := glPsNodeType(PsNodeIndex);

      RETURN
         PsNodeType <> PS_NODE_TYPE_TOTAL
           AND
         PsNodeType <> PS_NODE_TYPE_RESOURCE
           AND
            (
             PsNodeType <> PS_NODE_TYPE_FEATURE
              OR
             glFeatureType(PsNodeIndex) IN (PS_NODE_FEATURE_TYPE_BOOLEAN, PS_NODE_FEATURE_TYPE_OPTION)
              OR
             (
               glFeatureType(PsNodeIndex) = PS_NODE_FEATURE_TYPE_INTEGER
                AND
               glMinimum(PsNodeIndex) IS NOT NULL
                AND
               glMinimum(PsNodeIndex) >= 0
             )
            );
    END IF;
  ELSIF(NodeType = EXPR_NODE_TYPE_OPERATOR)THEN
     RETURN COMPATIBLE_DATA_TYPES(SIGNATURE_DATA_TYPE(h_SignatureId(v_tExprSubtype(j))), DATA_TYPE_BOOLEAN);
  ELSIF(NodeType IN (EXPR_FORALL, EXPR_FORALL_DISTINCT))THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION HAS_OPTIONS_APPLIED(j IN PLS_INTEGER) RETURN BOOLEAN IS
BEGIN
  RETURN (v_ChildrenIndex.EXISTS(v_tExprId(j)) AND
          h_SeededName.EXISTS(v_tExprSubtype(v_ChildrenIndex(v_tExprId(j)))) AND
          h_SeededName(v_tExprSubtype(v_ChildrenIndex(v_tExprId(j)))) = RULE_SYS_PROP_OPTIONS);
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NODE_CHILDREN(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 nCount    PLS_INTEGER;
 oper      tStringArray;
 ListType  PLS_INTEGER;
BEGIN

--nDebug := 7000005;

  nCount := 1;
  nChild := v_ChildrenIndex(v_tExprId(j));

--nDebug := 7000006;

  WHILE(v_tExprParentId(nChild) = v_tExprId(j)) LOOP

--nDebug := 7000007;

   oper.DELETE;
   oper := GENERATE_EXPRESSION(nChild, ListType);

   FOR i IN 1..oper.COUNT LOOP

    v_return(nCount) := oper(i);
    nCount := nCount + 1;

   END LOOP;

   nChild := nChild + 1;

  END LOOP;

--nDebug := 7000008;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NAME(j IN PLS_INTEGER, id IN NUMBER) RETURN VARCHAR2 IS --kdande; Bug 6881902; 11-Mar-2008
 v_return   VARCHAR2(4000);
 counter    PLS_INTEGER;
 val        PLS_INTEGER;
 delimiter  CHAR(1) := NULL;
 ExplId     cz_model_ref_expls.model_ref_expl_id%TYPE := v_tExplNodeId(j);
BEGIN

 IF(NOT v_NodeUpPath.EXISTS(ExplId))THEN
   counter := nRuleAssignedLevel;
   val := v_NodeLogicLevel(ExplId);
   WHILE(counter > val) LOOP
     v_return := v_return || PATH_DELIMITER || 'parent';
     counter := counter - 1;
   END LOOP;
   v_NodeUpPath(ExplId) := v_return;
 ELSE
   v_return := v_NodeUpPath(ExplId);
 END IF;

 IF(v_tLogicNetType(nHeaderId) = LOGIC_NET_TYPE_NETWORK AND (NOT v_IsConnectorNet.EXISTS(ExplId)))THEN

   --If we are generating into a conditional net, we add an extra ^parent to the path, but only if
   --this is not a connector's net.

   v_return := PATH_DELIMITER || 'parent' || v_return;
 END IF;

 IF(v_return IS NOT NULL OR v_AssignedDownPath(ExplId) IS NOT NULL)THEN
   delimiter := PATH_DELIMITER;
 END IF;

 v_return := v_return || v_AssignedDownPath(ExplId) || delimiter;

 --The description below is only true if the reference participates in the rule as an
 --object, because if this is a rule against this reference's system property than we
 --still should generate the regular name. So, we need to make sure that we construct
 --the new name only if this reference participates in compatibility rules - the only
 --type of rules where it can participate as an object (an option). Bug #2567898.

 IF(nRuleType IN (RULE_TYPE_COMPAT_RULE, RULE_TYPE_COMPAT_TABLE, RULE_TYPE_DESIGNCHART_RULE) AND
    glPsNodeType(glIndexByPsNodeId(id)) = PS_NODE_TYPE_REFERENCE)THEN

   --The following comment is not exactly correct, see the above description.
   --The node identified by <id> is a reference. In this case we should not generate
   --the regular P_<id>, because such object would never exist. Instead, we generate
   --^N_<id>^P_<reference_id> to refer to the referenced object in the child subnet.
   --This fixes the base bug #2128641.

   IF(v_return IS NULL)THEN v_return := PATH_DELIMITER; END IF;
   v_return := v_return || 'N_' || TO_CHAR(glPersistentId(id)) || PATH_DELIMITER ||
                           'P_' || TO_CHAR(glReferenceId(id));
 ELSE

   v_return := v_return || 'P_' || TO_CHAR(glPersistentId(id));
 END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
--Special version of GENERATE_NAME that accepts model_ref_expl_id value as a parameter
--instead of extracting it from cz_expression nodes by index j.

FUNCTION GENERATE_NAME_EXPL(ExplId IN PLS_INTEGER, id IN NUMBER) RETURN VARCHAR2 IS  --kdande; Bug 6881902; 11-Mar-2008
 v_return   VARCHAR2(4000);
 counter    PLS_INTEGER;
 val        PLS_INTEGER;
 delimiter  CHAR(1) := NULL;
BEGIN

 IF(NOT v_NodeUpPath.EXISTS(ExplId))THEN
   counter := nRuleAssignedLevel;
   val := v_NodeLogicLevel(ExplId);
   WHILE(counter > val) LOOP
     v_return := v_return || PATH_DELIMITER || 'parent';
     counter := counter - 1;
   END LOOP;
   v_NodeUpPath(ExplId) := v_return;
 ELSE
   v_return := v_NodeUpPath(ExplId);
 END IF;

 IF(v_tLogicNetType(nHeaderId) = LOGIC_NET_TYPE_NETWORK AND (NOT v_IsConnectorNet.EXISTS(ExplId)))THEN

   --If we are generating into a conditional net, we add an extra ^parent to the path, but only if
   --this is not a connector's net.

   v_return := PATH_DELIMITER || 'parent' || v_return;
 END IF;

 IF(v_return IS NOT NULL OR v_AssignedDownPath(ExplId) IS NOT NULL)THEN
   delimiter := PATH_DELIMITER;
 END IF;

 v_return := v_return || v_AssignedDownPath(ExplId) || delimiter;

 --The description below is only true if the reference participates in the rule as an
 --object, because if this is a rule against this reference's system property than we
 --still should generate the regular name. So, we need to make sure that we construct
 --the new name only if this reference participates in compatibility rules - the only
 --type of rules where it can participate as an object (an option). Bug #2567898.

 IF(nRuleType IN (RULE_TYPE_COMPAT_RULE, RULE_TYPE_COMPAT_TABLE, RULE_TYPE_DESIGNCHART_RULE) AND
    glPsNodeType(glIndexByPsNodeId(id)) = PS_NODE_TYPE_REFERENCE)THEN

   --The following comment is not exactly correct, see the above description.
   --The node identified by <id> is a reference. In this case we should not generate
   --the regular P_<id>, because such object would never exist. Instead, we generate
   --^N_<id>^P_<reference_id> to refer to the referenced object in the child subnet.
   --This fixes the base bug #2128641.

   IF(v_return IS NULL)THEN v_return := PATH_DELIMITER; END IF;
   v_return := v_return || 'N_' || TO_CHAR(glPersistentId(id)) || PATH_DELIMITER ||
                           'P_' || TO_CHAR(glReferenceId(id));
 ELSE

   v_return := v_return || 'P_' || TO_CHAR(glPersistentId(id));
 END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NODE(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
BEGIN

  v_return(1) := GENERATE_NAME(j, v_tExprPsNodeId(j));
  RETURN v_return;

END;
---------------------------------------------------------------------------------------
FUNCTION ADJUSTED_EXPLOSION(p_parent_expl_id IN NUMBER, p_child_node_id IN NUMBER) RETURN NUMBER IS
BEGIN
  FOR i IN 1..v_NodeId.COUNT LOOP
    IF(v_tParentId(i) = p_parent_expl_id AND v_tReferringId(i) = p_child_node_id)THEN
      RETURN v_NodeId(i);
    END IF;
  END LOOP;
END;
---------------------------------------------------------------------------------------
FUNCTION EXPAND_NODE(j IN PLS_INTEGER) RETURN tIntegerArray IS
  v_result       tIntegerArray;
  nCount         PLS_INTEGER;
  v_ps_node_id   NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  v_node_type    PLS_INTEGER;
  v_index        PLS_INTEGER;
  v_start_index  PLS_INTEGER;
  v_end_index    PLS_INTEGER;
BEGIN

  IF(v_tExprType(j) = EXPR_OPERATOR)THEN

    --The function is called on an operator node. We assume that this is OptionsOf, and so it has one
    --operand which represents a structure node. This structure node has its explosion populated in
    --cz_expression_nodes table. It is often convenient to associate this explosion also with the
    --operator itself. This is a fix for the bug #2232741.

    v_ps_node_id := v_tExprPsNodeId(v_ChildrenIndex(v_tExprId(j)));
    v_tExplNodeId(j) := v_tExplNodeId(v_ChildrenIndex(v_tExprId(j)));

  ELSIF(v_tExprType(j) = EXPR_PSNODE AND v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

    v_ps_node_id := v_tExprPsNodeId(j);
  ELSE

    --Left for backward compatibility.

    v_result(1) := v_tExprPsNodeId(j);
    RETURN v_result;
  END IF;

  v_index := glIndexByPsNodeId(v_ps_node_id);
  v_node_type := glPsNodeType(v_index);
  v_start_index := v_index + 1;

  IF(NOT glLastChildIndex.EXISTS(v_ps_node_id))THEN

    localString := glName(v_index);
    RAISE CZ_E_NO_EXPECTED_CHILDREN;
  END IF;

  v_end_index := glLastChildIndex(v_ps_node_id);
  nCount := 1;

  --If the function is called on a feature, we return options. If the function is called on a
  --BOM node, we return BOM children.

  IF(v_node_type = PS_NODE_TYPE_FEATURE)THEN

    FOR i IN v_start_index..v_end_index LOOP

      v_result(nCount) := glPsNodeId(i);
      v_ExplByPsNodeId(glPsNodeId(i)) := v_tExplNodeId(j);
      nCount := nCount + 1;
    END LOOP;
  ELSIF(v_node_type IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

    FOR i IN v_start_index..v_end_index LOOP

      IF((glPsNodeType(i) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD) OR
          (glPsNodeType(i) = PS_NODE_TYPE_REFERENCE AND
          glPsNodeType(glIndexByPsNodeId(glReferenceId(glPsNodeId(i)))) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD)))
          AND glParentId(i) = v_ps_node_id)THEN

           IF(glPsNodeType(i) = PS_NODE_TYPE_REFERENCE)THEN
             v_result(nCount) := glReferenceId(glPsNodeId(i));
             v_ExplByPsNodeId(glReferenceId(glPsNodeId(i))) := ADJUSTED_EXPLOSION(v_tExplNodeId(j), glPsNodeId(i));
           ELSE
             v_result(nCount) := glPsNodeId(i);
             v_ExplByPsNodeId(glPsNodeId(i)) := v_tExplNodeId(j);
           END IF;
           nCount := nCount + 1;
      END IF;
    END LOOP;
  END IF;
 RETURN v_result;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_CHILDRENOF(p_expl_id IN PLS_INTEGER, p_ps_node_id IN NUMBER) RETURN tStringArray IS  --kdande; Bug 6881902; 11-Mar-2008
  v_return       tStringArray;
  nCount         PLS_INTEGER;
  v_node_type    PLS_INTEGER;
  v_index        PLS_INTEGER;
  v_start_index  PLS_INTEGER;
  v_end_index    PLS_INTEGER;
BEGIN

nDebug := 7004050;

  --This function does basically the same as the previous one. The difference is that it can be used
  --only for system property, it is called on the system property node, taking the ps_node_id of the
  --parent as a parameter, and it returns generated names.

  v_index := glIndexByPsNodeId(p_ps_node_id);
  v_node_type := glPsNodeType(v_index);
  v_start_index := v_index + 1;

  IF(NOT glLastChildIndex.EXISTS(p_ps_node_id))THEN

    localString := glName(v_index);
    RAISE CZ_E_NO_EXPECTED_CHILDREN;
  END IF;

  v_end_index := glLastChildIndex(p_ps_node_id);
  nCount := 1;

  --If the function is called on a feature, we return options. If the function is called on a
  --BOM node, we return BOM children.

  IF(v_node_type = PS_NODE_TYPE_FEATURE)THEN

    FOR i IN v_start_index..v_end_index LOOP

      v_return(nCount) := GENERATE_NAME_EXPL(p_expl_id, glPsNodeId(i));
      nCount := nCount + 1;
    END LOOP;

  ELSIF(v_node_type IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

    FOR i IN v_start_index..v_end_index LOOP
      IF((glPsNodeType(i) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD) OR
          (glPsNodeType(i) = PS_NODE_TYPE_REFERENCE AND
          glPsNodeType(glIndexByPsNodeId(glReferenceId(glPsNodeId(i)))) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD)))
          AND glParentId(i) = p_ps_node_id)THEN

           IF(glPsNodeType(i) = PS_NODE_TYPE_REFERENCE)THEN
             v_return(nCount) := GENERATE_NAME_EXPL(ADJUSTED_EXPLOSION(p_expl_id, glPsNodeId(i)), glReferenceId(glPsNodeId(i)));
           ELSE
             v_return(nCount) := GENERATE_NAME_EXPL(p_expl_id, glPsNodeId(i));
           END IF;
           nCount := nCount + 1;
      END IF;
    END LOOP;
  END IF;

nDebug := 7004059;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ARITHMETIC(j IN PLS_INTEGER) RETURN tStringArray IS

  v_return     tStringArray;
  nChild       PLS_INTEGER;
  nCount       PLS_INTEGER;
  lhs          tStringArray;
  rhs          tStringArray;
  ListType     PLS_INTEGER;
  v_rounding   VARCHAR2(16) := ' ';
  v_target     VARCHAR2(4000);
  v_parj       PLS_INTEGER;
  optimizeFlag PLS_INTEGER := 0;

BEGIN

  IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
   RAISE CZ_E_WRONG_ARITHMETIC_OPER;
  END IF;

  nCount := 1;
  nChild := v_ChildrenIndex(v_tExprId(j));
  IF(v_tExprParentId.EXISTS(nChild + 1) AND v_tExprParentId(nChild + 1) = v_tExprId(j))THEN
   nCount := 2;
  END IF;

nDebug := 8004002;

  --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
  nLocalDefaults := nLocalDefaults + 1;
  v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);
  v_target := 'TOTAL ' || v_return(1) || NewLine;

  --Check if this procedure has been called for generation of a direct child expression of a rounding
  --operator. If so, set a flag to generate an enhanced contribute relation and no temporary total.
  --If the rounding operator is a root operator of a numeric rule with an advanced lhs expression,
  --which is indicated by the optimizeChain flag, generate the optimized contribute relation.

  IF(v_tExprParentId(j) IS NOT NULL)THEN

    v_parj := v_IndexByExprNodeId(v_tExprParentId(j));

    IF(v_tExprType(v_parj) = EXPR_NODE_TYPE_OPERATOR AND
       v_tExprSubtype(v_parj) IN (OPERATOR_ROUND, OPERATOR_CEILING, OPERATOR_FLOOR, OPERATOR_TRUNCATE))THEN

       v_rounding := OperatorLiterals(v_tExprSubtype(v_parj));
       generateRound := OPTIMIZATION_COMPLETED;

       IF(optimizeChain = OPTIMIZATION_REQUESTED)THEN

         v_return(1) := optimizeTarget;
         v_target := NULL;
         optimizeChain := OPTIMIZATION_COMPLETED;
       END IF;
    END IF;
  ELSIF(optimizeContribute = OPTIMIZATION_REQUESTED)THEN

    optimizeFlag := 1;
    optimizeContribute := OPTIMIZATION_COMPLETED;
  END IF;

  IF(nCount = 1)THEN

nDebug := 8004003;

    lhs := GENERATE_EXPRESSION(nChild, ListType);
    IF(v_tExprSubtype(j) = OPERATOR_SUB)THEN

      IF(optimizeFlag = 0)THEN

        vLogicLine := v_target || 'CONTRIBUTE ' || lhs(1) || OperatorLiterals(OPERATOR_MULT) || '-1 ' ||
                      v_return(1) || v_rounding || '... ' || TO_CHAR(nReasonId) || NewLine;
      ELSE

        v_return(1) := lhs(1) || OperatorLiterals(OPERATOR_MULT) || '-1 ';
      END IF;
    ELSE

      v_return(1) := lhs(1);
    END IF;
  ELSE

nDebug := 8004004;

    lhs := GENERATE_EXPRESSION(nChild, ListType);

nDebug := 8004005;

    rhs := GENERATE_EXPRESSION(nChild + 1, ListType);

nDebug := 8004006;

    IF(optimizeFlag = 0)THEN

      vLogicLine := v_target || 'CONTRIBUTE ' || lhs(1) || OperatorLiterals(v_tExprSubtype(j)) ||
                    rhs(1) || ' ' || v_return(1) || v_rounding || '... ' || TO_CHAR(nReasonId) || NewLine;
    ELSE

      v_return(1) := lhs(1) || OperatorLiterals(v_tExprSubtype(j)) || rhs(1) || ' ';
    END IF;
  END IF;

 PACK;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_MATH_UNARY(j IN PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
  v_result  tStringArray;
  nChild    PLS_INTEGER;
  ListType  PLS_INTEGER;
BEGIN

nDebug := 7000100;

  IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 1)THEN
    nParam := v_tExprSubtype(j);
    RAISE CZ_E_MATH_PARAMETERS;
  END IF;

  nChild := v_ChildrenIndex(v_tExprId(j));

nDebug := 7000101;

  --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
  nLocalDefaults := nLocalDefaults + 1;
  v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

nDebug := 7000102;

  v_result := GENERATE_EXPRESSION(nChild, ListType);

nDebug := 7000103;

  vLogicLine := 'TOTAL ' || v_return(1) || NewLine ||
                'MF ' || v_result(1) || OperatorLiterals(v_tExprSubtype(j)) ||
                v_return(1) || ' ... ' || TO_CHAR(nReasonId) || NewLine;
  PACK;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_MATH_BINARY(j IN PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
  nChild    PLS_INTEGER;
  lhs       tStringArray;
  rhs       tStringArray;
  ListType  PLS_INTEGER;
BEGIN

nDebug := 7000200;

  IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 2)THEN
    nParam := v_tExprSubtype(j);
    RAISE CZ_E_MATH_PARAMETERS;
  END IF;

  nChild := v_ChildrenIndex(v_tExprId(j));

nDebug := 7000201;

  --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
  nLocalDefaults := nLocalDefaults + 1;
  v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

nDebug := 7000202;

  lhs := GENERATE_EXPRESSION(nChild, ListType);

nDebug := 7000203;

  rhs := GENERATE_EXPRESSION(nChild + 1, ListType);

  --Bug #1990405. For the pow function, the second operand must evaluate to an integer. This
  --requirement may be removed or modified later.

  IF(v_tExprSubtype(j) = OPERATOR_POW)THEN

    --The generated expression should be an integer constant.

    IF(REPLACE(TRANSLATE(rhs(1), '0123456789', '0000000000'), '0', NULL) IS NOT NULL)THEN
      RAISE CZ_E_INCORRECT_POWER;
    END IF;
  END IF;

nDebug := 7000204;

  vLogicLine := 'TOTAL ' || v_return(1) || NewLine ||
                'MF ' || lhs(1) || ' ' || rhs(1) || OperatorLiterals(v_tExprSubtype(j)) ||
                v_return(1) || ' ... ' || TO_CHAR(nReasonId) || NewLine;
  PACK;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_MATH_ROUND(j IN PLS_INTEGER) RETURN tStringArray IS
  v_return   tStringArray;
  nChild     PLS_INTEGER;
  lhs        tStringArray;
  rhs        tStringArray;
  ListType   PLS_INTEGER;
  sReasonId  VARCHAR2(4000) := TO_CHAR(nReasonId);
BEGIN

nDebug := 7000300;

  IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 2)THEN
    nParam := v_tExprSubtype(j);
    RAISE CZ_E_MATH_PARAMETERS;
  END IF;

  nChild := v_ChildrenIndex(v_tExprId(j));

nDebug := 7000301;

  --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
  nLocalDefaults := nLocalDefaults + 1;
  v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

nDebug := 7000302;

  lhs := GENERATE_EXPRESSION(nChild, ListType);

nDebug := 7000303;

  rhs := GENERATE_EXPRESSION(nChild + 1, ListType);

nDebug := 7000304;

  vLogicLine := 'TOTAL ' || v_return(1) || '_1' || NewLine ||
                'MF ' || lhs(1) || ' ' || rhs(1) || OperatorLiterals(OPERATOR_MATHDIV) ||
                v_return(1) || '_1 ... ' || sReasonId || NewLine;
  PACK;
  vLogicLine := 'TOTAL ' || v_return(1) || '_2' || NewLine ||
                'MF ' || v_return(1) || '_1' || OperatorLiterals(v_tExprSubtype(j)) ||
                v_return(1) || '_2 ... ' || sReasonId || NewLine;
  PACK;
  vLogicLine := 'TOTAL ' || v_return(1) || NewLine ||
                'CONTRIBUTE ' || rhs(1) || OperatorLiterals(OPERATOR_MULT) ||
                v_return(1) || '_2 ' || v_return(1) || ' ... ' || sReasonId || NewLine;
  PACK;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_LITERAL(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
BEGIN

  v_return(1) := v_tExprDataValue(j);

  IF(v_tExprDataType(j) = DATA_TYPE_BOOLEAN)THEN
    IF(UPPER(v_tExprDataValue(j)) IN ('1', LOGICAL_CONSTANT_TRUE))THEN

      v_return(1) := ALWAYS_TRUE;
    ELSIF(UPPER(v_tExprDataValue(j)) IN ('0', LOGICAL_CONSTANT_FALSE))THEN

      v_return(1) := ALWAYS_FALSE;
    END IF;

    --Bug #4375977.

    IF(v_tLogicNetType(nHeaderId) = LOGIC_NET_TYPE_NETWORK AND (NOT v_IsConnectorNet.EXISTS(v_tExplNodeId(j))))THEN

       --If we are generating into a conditional net, we add an extra ^parent to the path, but only if
       --this is not a connector's net.

       v_return(1) := PATH_DELIMITER || 'parent' || PATH_DELIMITER || v_return(1);
    END IF;
  END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_CONSTANT(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
BEGIN
  IF(v_tExprSubtype(j) = EXPR_SUBTYPE_CONSTANT_E)THEN

    IF(NOT h_HeaderEDefined.EXISTS(nHeaderId))THEN
      h_HeaderEDefined(nHeaderId) := 'T_' || TO_CHAR(nHeaderId) || '_E';
      vLogicLine := 'TOTAL ' || h_HeaderEDefined(nHeaderId) || ' ' || MATH_CONSTANT_E || NewLine;
      PACK;
    END IF;
    v_return(1) := h_HeaderEDefined(nHeaderId);

  ELSIF(v_tExprSubtype(j) = EXPR_SUBTYPE_CONSTANT_PI)THEN

    IF(NOT h_HeaderPiDefined.EXISTS(nHeaderId))THEN
      h_HeaderPiDefined(nHeaderId) := 'T_' || TO_CHAR(nHeaderId) || '_PI';
      vLogicLine := 'TOTAL ' || h_HeaderPiDefined(nHeaderId) || ' ' || MATH_CONSTANT_PI || NewLine;
      PACK;
    END IF;
    v_return(1) := h_HeaderPiDefined(nHeaderId);

  ELSE
    RAISE CZ_E_UNKNOWN_EXPR_TYPE;
  END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_MINMAX(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return         tStringArray;
 v_child          tStringArray;
 v_current        VARCHAR2(4000);
 v_oper           VARCHAR2(10) := OperatorLiterals(v_tExprSubtype(j));
 v_rounding       VARCHAR2(16) := ' ';
 v_actual         VARCHAR2(16) := ' ';
 v_parj           PLS_INTEGER;
 v_target         VARCHAR2(4000);
 doOptimize       PLS_INTEGER := 0;
 v_name           VARCHAR2(128);
BEGIN

 nLocalDefaults := nLocalDefaults + 1;
 v_name := TO_CHAR(nLocalDefaults);

 v_child := GENERATE_NODE_CHILDREN(j);
 v_return(1) := t_prefix || v_name || '_1';
 v_target := 'TOTAL ' || v_return(1) || NewLine;

 IF(v_child.COUNT < 2)THEN
   RAISE CZ_E_WRONG_MINMAX_OPERATOR;
 END IF;

 --Check if this procedure has been called for generation of a direct child expression of a rounding
 --operator. If so, set a flag to generate an enhanced contribute relation and no temporary total.
 --If the rounding operator is a root operator of a numeric rule with an advanced lhs expression,
 --which is indicated by the optimizeChain flag, generate the optimized contribute relation.

 IF(v_tExprParentId(j) IS NOT NULL)THEN

   v_parj := v_IndexByExprNodeId(v_tExprParentId(j));

   IF(v_tExprType(v_parj) = EXPR_NODE_TYPE_OPERATOR AND
      v_tExprSubtype(v_parj) IN (OPERATOR_ROUND, OPERATOR_CEILING, OPERATOR_FLOOR, OPERATOR_TRUNCATE))THEN

      v_rounding := OperatorLiterals(v_tExprSubtype(v_parj));
      generateRound := OPTIMIZATION_COMPLETED;

      IF(optimizeChain = OPTIMIZATION_REQUESTED)THEN

        optimizeChain := OPTIMIZATION_COMPLETED;
        doOptimize := 1;
      END IF;
   END IF;
 END IF;

 --If the operator has just two operands, only one contribute relation will be generated, prepare
 --variables for this relation.

 IF(v_child.COUNT = 2)THEN

   v_actual := v_rounding;
   IF(doOptimize = 1)THEN

     v_target := NULL;
     v_return(1) := optimizeTarget;
   END IF;
 END IF;

 vLogicLine := v_target || 'CONTRIBUTE ' || v_child(1) || v_oper || v_child(2) || ' ' ||
               v_return(1) || v_actual || '... ' || TO_CHAR(nReasonId) || NewLine;

 PACK;

 v_current := v_return(1);
 v_actual := ' ';

 FOR i IN 3..v_child.COUNT LOOP

  v_return(1) := t_prefix || v_name || '_' || TO_CHAR(i-1);
  v_target := 'TOTAL ' || v_return(1) || NewLine;

  --If the operator has more than two operands, two or more contribute relations will be
  --generated. We want to modify only the last of them, so prepare the variables before
  --generating the last one.

  IF(i = v_child.COUNT)THEN

   v_actual := v_rounding;
   IF(doOptimize = 1)THEN

     v_target := NULL;
     v_return(1) := optimizeTarget;
   END IF;
  END IF;

  vLogicLine := v_target || 'CONTRIBUTE ' || v_child(i) || v_oper || v_current || ' ' ||
                v_return(1) || v_actual || '... ' || TO_CHAR(nReasonId) || NewLine;

  v_current := v_return(1);
  PACK;

 END LOOP;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_OF(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 v_result  tIntegerArray;
 nChild    PLS_INTEGER;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
  RAISE CZ_E_WRONG_OF_OPERATOR;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));
 v_result := EXPAND_NODE(j);

 FOR i IN 1..v_result.COUNT LOOP

   v_return(i) := GENERATE_NAME_EXPL(v_ExplByPsNodeId(v_result(i)), v_result(i));
 END LOOP;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NOT(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 oper      tStringArray;
 ListType  PLS_INTEGER;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
  RAISE CZ_E_WRONG_NOT_OPERATOR;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));
 IF(v_tExprParentId.EXISTS(nChild + 1) AND v_tExprParentId(nChild + 1) = v_tExprId(j))THEN
  RAISE CZ_E_WRONG_NOT_OPERATOR;
 END IF;

 IF(NOT HAS_LOGICAL_VALUE(nChild))THEN
  nParam := j;
  RAISE CZ_E_INVALID_OPERAND_TYPE;
 END IF;

 --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
 nLocalDefaults := nLocalDefaults + 1;
 v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

 oper := GENERATE_EXPRESSION(nChild, ListType);

 vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
               'GS N ... ' || TO_CHAR(nReasonId) || NewLine ||
               'GL' || OperatorLetters(OPERATOR_ANYOF) || oper(1) || NewLine ||
               'GR' || OperatorLetters(OPERATOR_ANYOF) || v_return(1) || NewLine;
 PACK;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NOTTRUE(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return    tStringArray;
 nChild      PLS_INTEGER;
 oper        tStringArray;
 ListType    PLS_INTEGER;
 v_NodeId    NUMBER; --kdande; Bug 6881902; 11-Mar-2008
 v_HeaderId  NUMBER;
 v_nodename  VARCHAR2(4000);
 v_accuname  VARCHAR2(4000);
 iLocal      PLS_INTEGER;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
  RAISE CZ_E_WRONG_NOTTRUE_OPERATOR;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));
 IF(v_tExprParentId.EXISTS(nChild + 1) AND v_tExprParentId(nChild + 1) = v_tExprId(j))THEN
  RAISE CZ_E_WRONG_NOTTRUE_OPERATOR;
 END IF;

 IF(NOT HAS_LOGICAL_VALUE(nChild))THEN
  nParam := j;
  RAISE CZ_E_INVALID_OPERAND_TYPE;
 END IF;

 --OptimizeNotTrue is a db setting which is disabled by default.

 IF(OptimizeNotTrue = 0 OR v_tExprType(nChild) <> EXPR_NODE_TYPE_NODE)THEN

   --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
   nLocalDefaults := nLocalDefaults + 1;
   v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

   oper := GENERATE_EXPRESSION(nChild, ListType);

   vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
                 'NOTTRUE ' || oper(1) || ' ' || v_return(1) || ' ... ' || TO_CHAR(nReasonId) || NewLine;
   PACK;
 ELSE

   v_NodeId := v_tExprPsNodeId(nChild);

   IF((NOT v_HeaderByNotTrueId.EXISTS(v_NodeId)) AND
      (glAccumulator(v_NodeId) IS NULL OR glAccumulator(v_NodeId) = FLAG_NO_ACCUMULATOR))THEN

     --Need to generate a new NOTTRUE relation in the node's structure file

     v_HeaderId := glHeaderByPsNodeId(v_NodeId);
     v_nodename := 'P_' || TO_CHAR(glPersistentId(v_NodeId));
     v_accuname := v_nodename || '_NT';

     --Flush off the buffer because we are about to write to another file

     IF(vLogicText IS NOT NULL)THEN
       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nHeaderId, v_tSequenceNbr(nHeaderId), vLogicText);
       vLogicText := NULL;
       v_tSequenceNbr(nHeaderId) := v_tSequenceNbr(nHeaderId) + 1;
     END IF;

     --Fix for the bug #2398832 - we may be re-using the accumulator, so we should not
     --assign to it effectivities and usages of a particular node.
     --Do not write the effectivity dates using the actual effective date interval of
     --the corresponding node.

     --iLocal := glIndexByPsNodeId(v_NodeId);
     --CurrentEffFrom := glEffFrom(iLocal);
     --CurrentEffUntil := glEffUntil(iLocal);
     --CurrentUsageMask := glUsageMask(iLocal);

     --Instead make the accumulator always effective and universal.

     CurrentEffFrom := EpochBeginDate;
     CurrentEffUntil := EpochEndDate;
     CurrentUsageMask := AnyUsageMask;

     IF((NOT h_EffFrom.EXISTS(v_HeaderId)) OR
        (h_EffFrom(v_HeaderId) <> CurrentEffFrom OR h_EffUntil(v_HeaderId) <> CurrentEffUntil OR
         h_EffUsageMask(v_HeaderId) <> CurrentUsageMask))THEN

       h_EffFrom(v_HeaderId) := CurrentEffFrom;
       h_EffUntil(v_HeaderId) := CurrentEffUntil;
       h_EffUsageMask(v_HeaderId) := CurrentUsageMask;

       vLogicText := LTRIM(CurrentUsageMask, '0');
       IF(vLogicText IS NOT NULL) THEN
         vLogicText := EffUsagePrefix || vLogicText;
       END IF;

       IF(CurrentEffFrom = EpochBeginDate)THEN
         CurrentFromDate := NULL;
       ELSE
         CurrentFromDate := TO_CHAR(CurrentEffFrom, EffDateFormat);
       END IF;

       IF(CurrentEffUntil = EpochEndDate)THEN
         CurrentUntilDate := NULL;
       ELSE
         CurrentUntilDate := TO_CHAR(CurrentEffUntil, EffDateFormat);
       END IF;

       vLogicText := 'EFF ' || CurrentFromDate || ', ' || CurrentUntilDate || ', ' || vLogicText || NewLine;
     END IF;

     vLogicText := vLogicText || 'OBJECT ' || v_accuname || NewLine ||
                   'NOTTRUE ' || v_nodename || ' ' || v_accuname || ' ... ' || TO_CHAR(nReasonId) || NewLine;

     INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
      (v_HeaderId, vSeqNbrByHeader(v_HeaderId), vLogicText);
     vLogicText := NULL;
     vSeqNbrByHeader(v_HeaderId) := vSeqNbrByHeader(v_HeaderId) + 1;

     v_HeaderByNotTrueId(v_NodeId) := v_HeaderId;

     --Part of the fix for the bug #2857955. We will never be here if glAccumulator(v_NodeId) was
     --FLAG_ACCUMULATOR_NT because the accumulator would have already been created.

     UPDATE cz_ps_nodes SET
       accumulator_flag = DECODE(glAccumulator(v_NodeId), FLAG_ACCUMULATOR_ACC, FLAG_ACCUMULATOR_BOTH, FLAG_ACCUMULATOR_NT)
     WHERE ps_node_id = v_NodeId;

   END IF;

   v_return(1) := GENERATE_NAME(nChild, v_NodeId) || '_NT';
 END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION COMPARE_VALUES(val1 IN VARCHAR2, val2 IN VARCHAR2, OperType IN PLS_INTEGER)
RETURN BOOLEAN IS
  v_null  NUMBER;
BEGIN
  IF(OperType = OPERATOR_EQUALS)THEN
    RETURN (val1 = val2);
  ELSIF(OperType = OPERATOR_NOTEQUALS)THEN
    RETURN (val1 <> val2);
  ELSIF(OperType = OPERATOR_EQUALS_INT)THEN
    RETURN (val1 = val2);
  ELSIF(OperType = OPERATOR_NOTEQUALS_INT)THEN
    RETURN (val1 <> val2);
  ELSIF(OperType = OPERATOR_GT)THEN
    RETURN (val1 > val2);
  ELSIF(OperType = OPERATOR_LT)THEN
    RETURN (val1 < val2);
  ELSIF(OperType = OPERATOR_GE)THEN
    RETURN (val1 >= val2);
  ELSIF(OperType = OPERATOR_LE)THEN
    RETURN (val1 <= val2);
  ELSIF(OperType = OPERATOR_BEGINSWITH)THEN
    RETURN (INSTR(val1, val2) = 1);
  ELSIF(OperType = OPERATOR_ENDSWITH)THEN
    RETURN (INSTR(val1, val2, -1) = (LENGTH(val1) - LENGTH(val2) + 1));
  ELSIF(OperType = OPERATOR_CONTAINS)THEN
    RETURN (INSTR(val1, val2) <> 0);
  ELSIF(OperType = OPERATOR_LIKE)THEN
    BEGIN
      SELECT NULL INTO v_null FROM DUAL WHERE val1 LIKE val2;
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    END;
  ELSIF(OperType = OPERATOR_MATCHES)THEN
    BEGIN
      SELECT NULL INTO v_null FROM DUAL WHERE val1 LIKE val2;
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    END;
  ELSIF(OperType = OPERATOR_DOESNOTBEGINWITH)THEN
    RETURN (INSTR(val1, val2) <> 1);
  ELSIF(OperType = OPERATOR_DOESNOTENDWITH)THEN
    RETURN (INSTR(val1, val2, -1) <> (LENGTH(val1) - LENGTH(val2) + 1));
  ELSIF(OperType = OPERATOR_DOESNOTCONTAIN)THEN
    RETURN (INSTR(val1, val2) = 0);
  ELSIF(OperType = OPERATOR_NOTLIKE)THEN
    BEGIN
      SELECT NULL INTO v_null FROM DUAL WHERE val1 NOT LIKE val2;
      RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    END;
  ELSE
    RAISE CZ_E_WRONG_COMPARISON_OPER;
  END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION EXTRACT_PROPERTY_VALUE(inVal IN VARCHAR2, inType IN PLS_INTEGER)
RETURN VARCHAR2 IS
BEGIN
  IF(inType = DATATYPE_STRING)THEN
    RETURN SUBSTR(inVal, INSTR(inVal, PROPERTY_DELIMITER) + 1);
  ELSE
    RETURN inVal;
  END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION EXTRACT_PROPERTY_VALUE(inVal IN VARCHAR2)

--This simplified version is used in GENERATE_REFNODE to extract boolean property values
--represented as character '0'/'1' in the database.

RETURN VARCHAR2 IS
BEGIN
    RETURN SUBSTR(inVal, INSTR(inVal, PROPERTY_DELIMITER) + 1);
END;
---------------------------------------------------------------------------------------
FUNCTION EXTRACT_PROPERTY_NODE(inVal IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN SUBSTR(inVal, 1, INSTR(inVal, PROPERTY_DELIMITER) - 1);
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_CONCAT(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 lhs       tStringArray;
 rhs       tStringArray;
 lListType PLS_INTEGER;
 rListType PLS_INTEGER;
 ExprId    PLS_INTEGER := v_tExprId(j);
BEGIN

  IF(NOT v_ChildrenIndex.EXISTS(ExprId))THEN
   RAISE CZ_E_WRONG_COMPARISON_OPER;
  END IF;

  nChild := v_ChildrenIndex(ExprId);
  IF(NOT v_tExprParentId.EXISTS(nChild + 1) OR v_tExprParentId(nChild + 1) IS NULL OR
     v_tExprParentId(nChild + 1) <> ExprId)THEN
   RAISE CZ_E_WRONG_COMPARISON_OPER;
  END IF;

  lhs := GENERATE_EXPRESSION(nChild, lListType);
  rhs := GENERATE_EXPRESSION(nChild+1, rListType);

  v_return(1) := EXTRACT_PROPERTY_VALUE(lhs(1)) || EXTRACT_PROPERTY_VALUE(rhs(1));
  ListType := DATA_TYPE_TEXT;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
--Bug 5620750 - function to generate the new ToText operator when used outside of PBC
--context.

FUNCTION GENERATE_TOTEXT(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 ExprId    PLS_INTEGER := v_tExprId(j);
BEGIN

  IF((NOT v_ChildrenIndex.EXISTS(ExprId)) OR v_NumberOfChildren(ExprId) <> 1)THEN
    RAISE CZ_R_WRONG_EXPRESSION_NODE;
  END IF;

  v_return(1) := TO_CHAR(v_tExprDataNumValue(v_ChildrenIndex(ExprId)));
  ListType := DATA_TYPE_TEXT;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_COMPARE(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 v_left    tStringArray;
 nChild    PLS_INTEGER;
 lhs       tStringArray;
 rhs       tStringArray;
 lListType PLS_INTEGER;
 rListType PLS_INTEGER;
 OperType  PLS_INTEGER := v_tExprSubtype(j);
 ExprId    PLS_INTEGER := v_tExprId(j);
 nCount    PLS_INTEGER := 1;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(ExprId))THEN
  RAISE CZ_E_WRONG_COMPARISON_OPER;
 END IF;

 nChild := v_ChildrenIndex(ExprId);
 IF(NOT v_tExprParentId.EXISTS(nChild + 1) OR v_tExprParentId(nChild + 1) IS NULL OR
    v_tExprParentId(nChild + 1) <> ExprId)THEN
  RAISE CZ_E_WRONG_COMPARISON_OPER;
 END IF;

nDebug := 8001120;

 --v_return(1) := 'T_' || TO_CHAR(ExprId);
 nLocalDefaults := nLocalDefaults + 1;
 v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

nDebug := 8001121;

 generateCompare := 1;
 lhs := GENERATE_EXPRESSION(nChild, lListType);

nDebug := 8001122;

 rhs := GENERATE_EXPRESSION(nChild+1, rListType);
 generateCompare := 0;

  --Bug #4191838.

  IF(lhs.COUNT = 1 AND lListType = DATA_TYPE_TEXT AND rhs.COUNT = 1 AND rListType = DATA_TYPE_TEXT)THEN

     v_left(1) := 'OBJECT ' || v_return(1) || NewLine;
     v_left(2) := TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ALLOF) || ALWAYS_TRUE || NewLine ||
                  'GR' || OperatorLetters(OPERATOR_ALLOF) || v_return(1) || NewLine;

     IF(COMPARE_VALUES(EXTRACT_PROPERTY_VALUE(lhs(1), lListType),
                       EXTRACT_PROPERTY_VALUE(rhs(1), rListType), OperType))THEN
       vLogicLine := v_left(1) || 'GS R ... ' || v_left(2);
     ELSE
       vLogicLine := v_left(1) || 'GS E ... ' || v_left(2);
     END IF;
    PACK;
    RETURN v_return;
   END IF;

nDebug := 8001123;

 IF(lListType = DATATYPE_STRING OR rListType = DATATYPE_STRING)THEN

nDebug := 8001124;

  FOR ii IN 1..lhs.COUNT LOOP
   FOR jj IN 1..rhs.COUNT LOOP

    IF(COMPARE_VALUES(EXTRACT_PROPERTY_VALUE(lhs(ii), lListType),
                      EXTRACT_PROPERTY_VALUE(rhs(jj), rListType), OperType))THEN
     IF(lListType = DATATYPE_STRING AND rListType = DATATYPE_STRING)THEN

nDebug := 8001125;

       v_left(nCount) := v_return(1) || '_' || TO_CHAR(nCount);

       vLogicLine := 'OBJECT ' || v_left(nCount) || NewLine ||
                     'GS R ' || sUnsatisfiedId || '... ' || TO_CHAR(nReasonId) || NewLine ||
                     'GL' || OperatorLetters(OPERATOR_ALLOF) ||
                      EXTRACT_PROPERTY_NODE(lhs(ii)) || ' ' || EXTRACT_PROPERTY_NODE(rhs(jj)) || NewLine ||
                     'GR' || OperatorLetters(OPERATOR_ALLOF) || v_left(nCount) || NewLine;
       PACK;
       nCount := nCount + 1;

     ELSIF(lListType = DATATYPE_STRING)THEN

nDebug := 8001126;

       v_left(nCount) := EXTRACT_PROPERTY_NODE(lhs(ii));
       nCount := nCount + 1;

     ELSIF(rListType = DATATYPE_STRING)THEN

nDebug := 8001127;

       v_left(nCount) := EXTRACT_PROPERTY_NODE(rhs(jj));
       nCount := nCount + 1;

     END IF;
    END IF;
   END LOOP;
  END LOOP;

nDebug := 8001128;

  IF(v_left.COUNT = 0)THEN

    vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
                  'GS E ...' || TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ALLOF) || ALWAYS_TRUE || NewLine ||
                  'GR' || OperatorLetters(OPERATOR_ALLOF) || v_return(1) || NewLine;

  ELSE

    localString := NULL;
    IF(v_left.COUNT > 1)THEN localString := sUnsatisfiedId; END IF;

    vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
                  'GS R ' || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ANYOF);

    PACK;

nDebug := 8001129;

    FOR i IN 1..v_left.COUNT LOOP

      vLogicLine := v_left(i) || ' ';
      PACK;

    END LOOP;

    vLogicLine := NewLine || 'GR' || OperatorLetters(OPERATOR_ALLOF) || v_return(1) || NewLine;

nDebug := 8001130;

  END IF;

 ELSE

nDebug := 8001131;

   vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
                 'COMPARE ' || lhs(1) || OperatorLiterals(OperType) ||
                 rhs(1) || ' ' || v_return(1) || ' ... ' || TO_CHAR(nReasonId) || NewLine;
 END IF;

 PACK;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ANYALLOF(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
 v_return    tStringArray;
 v_child     tStringArray;
 v_parentid  NUMBER;
 v_parj      PLS_INTEGER;
 nChild      PLS_INTEGER;
BEGIN

--nDebug := 7000001;

 --Bug #5015333 - need a verification for the logical nature of the operands.

 nChild := v_ChildrenIndex(v_tExprId(j));

 WHILE(v_tExprParentId(nChild) = v_tExprId(j)) LOOP

   IF(NOT HAS_LOGICAL_VALUE(nChild))THEN

     nParam := j;
     RAISE CZ_E_INVALID_OPERAND_TYPE;
   END IF;

   nChild := nChild + 1;
 END LOOP;

 v_child := GENERATE_NODE_CHILDREN(j);
 v_parentid := v_tExprParentId(j);

 --This is important that this assignment goes after the node children generation, because the
 --type of the parent operator can be changed during the children generation in some cases
 --(see internal case #3 below).

 ListType := v_tExprSubtype(j);

 IF(OptimizeAllAnyOf = 1)THEN
   IF(v_parentid IS NOT NULL)THEN

     v_parj := v_IndexByExprNodeId(v_parentid);

     IF(v_tExprType(v_parj) = EXPR_NODE_TYPE_OPERATOR AND
        v_tExprSubtype(v_parj) IN (OPERATOR_ANYOF, OPERATOR_ALLOF))THEN

       IF(ListType = v_tExprSubtype(v_parj))THEN

         --AllOf(AllOf(...) , ...), AnyOf(AnyOf(...) , ...).
         --Internal case #1.

         return v_child;
       ELSIF(v_child.COUNT = 1)THEN

         --This operator is either AnyOf or AllOf. It is different from the parent operator which
         --is also AnyOf or AllOf. Therefore, this is AllOf(AnyOf(...) , ...) or
         --AnyOf(AllOf(...) , ...). If only one child has been generated for this operator than
         --we have the case of AllOf(AnyOf(1) , ...) or AnyOf(AllOf(1) , ...).
         --Internal case #2.

         return v_child;

       ELSIF(v_NumberOfChildren(v_parentid) = 1)THEN

         --We have AllOf(AnyOf(...)) or AnyOf(AllOf(...)), i. e. this AllOf or AnyOf operator is
         --the only child of its parent.If so, we not only carry over the children list but also
         --reverse the type of the parent operator.
         --Internal case #3.

         v_tExprSubtype(v_parj) := ListType;
         return v_child;
       END IF;
     END IF;
   ELSIF(nRuleType = RULE_TYPE_LOGIC_RULE)THEN
     IF(nRuleOperator <> RULE_OPERATOR_DEFAULTS OR j = jConsequentRoot)THEN
       return v_child;
     ELSIF(v_child.COUNT = 1)THEN
       return v_child;
     END IF;
   END IF;
 END IF;

--nDebug := 7000002;

 --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
 nLocalDefaults := nLocalDefaults + 1;
 v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

--nDebug := 7000003;

 localString := NULL;
 IF(v_child.COUNT > 1)THEN localString := sUnsatisfiedId; END IF;

 vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
               'GS R ' || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
               'GL' || OperatorLetters(ListType);

 PACK;

 IF(ChangeChildrenOrder = 1)THEN
   FOR i IN REVERSE 1..v_child.COUNT LOOP

     vLogicLine := v_child(i) || ' ';
     PACK;

   END LOOP;
 ELSE
   FOR i IN 1..v_child.COUNT LOOP

     vLogicLine := v_child(i) || ' ';
     PACK;

   END LOOP;
 END IF;

--nDebug := 7000004;

 vLogicLine := NewLine || 'GR' || OperatorLetters(OPERATOR_ALLOF) || v_return(1) || NewLine;
 PACK;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ANDOR(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 lhs       tStringArray;
 rhs       tStringArray;
 lListType PLS_INTEGER;
 rListType PLS_INTEGER;
BEGIN

 IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 2)THEN
  RAISE CZ_E_WRONG_ANDOR_OPERATOR;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));

 IF(NOT (HAS_LOGICAL_VALUE(nChild) AND HAS_LOGICAL_VALUE(nChild + 1)))THEN
  nParam := j;
  RAISE CZ_E_INVALID_OPERAND_TYPE;
 END IF;

 IF(OptimizeAllAnyOf = 1)THEN
   IF(v_tExprSubtype(j) = OPERATOR_AND)THEN
     v_tExprSubtype(j) := OPERATOR_ALLOF;
   ELSE
     v_tExprSubtype(j) := OPERATOR_ANYOF;
   END IF;
   RETURN GENERATE_ANYALLOF(j, ListType);
 END IF;

nDebug := 8001700;

 --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
 nLocalDefaults := nLocalDefaults + 1;
 v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

 lhs := GENERATE_EXPRESSION(nChild, lListType);
 rhs := GENERATE_EXPRESSION(nChild+1, rListType);

nDebug := 8001701;

 vLogicLine := 'OBJECT ' || v_return(1) || NewLine ||
               'GS R ' || sUnsatisfiedId || '... ' || TO_CHAR(nReasonId) || NewLine ||
               'GL' || OperatorLetters(v_tExprSubtype(j)) || lhs(1) || ' ' || rhs(1) || NewLine ||
               'GR' || OperatorLetters(OPERATOR_ANYOF) || v_return(1) || NewLine;
 PACK;

nDebug := 8001702;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ROUND(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 oper      tStringArray;
 ListType  PLS_INTEGER;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
  RAISE CZ_E_WRONG_ROUND_OPERATOR;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));
 IF(v_tExprParentId.EXISTS(nChild + 1) AND v_tExprParentId(nChild + 1)= v_tExprId(j))THEN

  RAISE CZ_E_WRONG_ROUND_OPERATOR;
 END IF;

 generateRound := OPTIMIZATION_REQUESTED;

 oper := GENERATE_EXPRESSION(nChild, ListType);

 --The value may have been changed by the child expression generation. In this case we are
 --optimizing and do not want the increment relation to be generated at all.

 IF(generateRound = OPTIMIZATION_REQUESTED)THEN

   --v_return(1) := 'T_' || TO_CHAR(v_tExprId(j));
   nLocalDefaults := nLocalDefaults + 1;
   v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);

   vLogicLine := 'TOTAL ' || v_return(1) || NewLine || 'INC ' || oper(1) || ' ' || v_return(1) ||
                 OperatorLiterals(v_tExprSubtype(j)) || '... ' || TO_CHAR(nReasonId) || NewLine;
   PACK;
   generateRound := OPTIMIZATION_COMPLETED;
 ELSE

   v_return(1) := oper(1);
 END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION PROPERTY_VALUE(j IN PLS_INTEGER, iPSN IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER)
RETURN VARCHAR2 IS
  v_return      VARCHAR2(4000);
  nChild        NUMBER;
  c_values      refCursor;
  optionId      cz_ps_nodes.ps_node_id%TYPE := glPsNodeId(iPSN);
  propertyId    cz_expression_nodes.property_id%TYPE := v_tExprPropertyId(j);
  itemId        cz_ps_nodes.item_id%TYPE := glItemId(iPSN);
  sysPropName   VARCHAR2(30);
BEGIN

  IF(v_tExprType(j) = EXPR_SYS_PROP)THEN

   IF(NOT h_SeededName.EXISTS(v_tExprSubtype(j)))THEN RAISE CZ_E_BAD_PROPERTY_TYPE; END IF;
   sysPropName := h_SeededName(v_tExprSubtype(j));

   IF(sysPropName = RULE_SYS_PROP_NAME)THEN

--nDebug := 8001160;

     v_return := glName(iPSN);
     ListType := DATATYPE_STRING;

   ELSIF(sysPropName = RULE_SYS_PROP_QUANTITY)THEN

     --Related bug: #2317427.

     v_return := GENERATE_NAME(j, optionId);
     ListType := DATATYPE_INTEGER;

   ELSIF(sysPropName = RULE_SYS_PROP_INSTANCECOUNT)THEN

--nDebug := 8001161;

     --If it is a non-virtual component/product/reference, we add _ACTUALCOUNT to the name.
     --If it is a virtual component/product/reference, we return '1'.
     --If it is an option, we just generate the name.

     IF(glPsNodeType(iPSN) IN (PS_NODE_TYPE_COMPONENT,
                               PS_NODE_TYPE_REFERENCE,
                               PS_NODE_TYPE_PRODUCT))THEN
      IF(glVirtualFlag(iPSN) = FLAG_NON_VIRTUAL)THEN
       v_return := GENERATE_NAME(j, optionId)||'_ACTUALCOUNT';
      ELSE
       v_return := '1';
      END IF;
     ELSE
       v_return := GENERATE_NAME(j, optionId);
     END IF;
     ListType := DATATYPE_INTEGER;

--nDebug := 8001162;

   ELSIF(sysPropName = RULE_SYS_PROP_MININSTANCE)THEN

--nDebug := 8001163;

     v_return := GENERATE_NAME(j, optionId)||'_MIN';
     ListType := DATATYPE_INTEGER;

   ELSIF(sysPropName = RULE_SYS_PROP_MAXINSTANCE)THEN

--nDebug := 8001164;

     v_return := GENERATE_NAME(j, optionId)||'_MAX';
     ListType := DATATYPE_INTEGER;

   ELSE

     RAISE CZ_E_BAD_PROPERTY_TYPE;
   END IF;
  ELSE

   BEGIN

--nDebug := 8001165;

     v_return := GET_PROPERTY_VALUE(optionId, propertyId, itemId, ListType);

     IF(v_return IS NULL)THEN RAISE CZ_E_NULL_PROPERTY_VALUE; END IF;

     IF(ListType IN (DATATYPE_INTEGER, DATATYPE_FLOAT))THEN

       BEGIN
         nChild := TO_NUMBER(v_return);
       EXCEPTION
         WHEN OTHERS THEN

           SELECT name INTO errorMessage
             FROM cz_properties
            WHERE property_id = propertyId;

           localString := v_return;
           RAISE CZ_R_INCORRECT_DATA_TYPE;
       END;
     END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE CZ_E_NO_SUCH_PROPERTY;
     WHEN TOO_MANY_ROWS THEN
       RAISE CZ_E_INCORRECT_PROPERTY;
     WHEN OTHERS THEN
       RAISE;
   END;
  END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION STATIC_SYSPROP_VALUE(p_node_id IN NUMBER, p_rule_id IN NUMBER, p_parent_up IN PLS_INTEGER)
RETURN VARCHAR2 IS

  optionIndex  PLS_INTEGER;
  v_step       PLS_INTEGER := p_parent_up;
  sysPropName  cz_rules.name%TYPE;
  v_return     VARCHAR2(4000);
BEGIN

  sysPropName := h_SeededName(p_rule_id);
  errorMessage := h_ReportName(p_rule_id);
  optionIndex := glIndexByPsNodeId(p_node_id);

  BEGIN
    WHILE(v_step > 1)LOOP
      optionIndex := glIndexByPsNodeId(glParentId(optionIndex));
      v_step := v_step - 1;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE CZ_E_INCORRECT_PROPERTY;
  END;

  IF(sysPropName = RULE_SYS_PROP_NAME)THEN

    v_return := glName(optionIndex);

  ELSIF(sysPropName IN (RULE_SYS_PROP_MINVALUE, RULE_SYS_PROP_MINQUANTITY, RULE_SYS_PROP_MINSELECTED))THEN

    v_return := glMinimum(optionIndex);

  ELSIF(sysPropName IN (RULE_SYS_PROP_MAXVALUE, RULE_SYS_PROP_MAXQUANTITY, RULE_SYS_PROP_MAXSELECTED))THEN

    v_return := glMaximum(optionIndex);

  ELSIF(sysPropName = RULE_SYS_PROP_DESCRIPTION)THEN

    RAISE CZ_E_DESCRIPTION_IN_WHERE;
  ELSE

    RAISE CZ_E_PROPERTY_NOT_STATIC;
  END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION SYSTEM_PROPERTY_VALUE(j IN PLS_INTEGER, iPSN IN tStringArray, ListType OUT NOCOPY PLS_INTEGER)
RETURN tStringArray IS

  v_return     tStringArray;
  v_result     tStringArray;
  optionId     cz_ps_nodes.ps_node_id%TYPE;
  propertyId   cz_expression_nodes.property_id%TYPE := v_tExprPropertyId(j);
  itemId       cz_ps_nodes.item_id%TYPE;
  c_values     refCursor;
  nChild       NUMBER;
  optionIndex  PLS_INTEGER;
  sysPropName  VARCHAR2(30);
BEGIN

nDebug := 9001000;

 FOR i IN 1..iPSN.COUNT LOOP

   optionId := TO_NUMBER(iPSN(i));
   optionIndex := glIndexByPsNodeId(optionId);

   IF(v_tExprType(j) = EXPR_NODE_TYPE_SYSPROP)THEN

     sysPropName := h_SeededName(v_tExprSubtype(j));

     IF(sysPropName = RULE_SYS_PROP_NAME)THEN

       v_return(i) := glName(optionIndex);
       ListType := DATA_TYPE_TEXT;

     ELSIF(sysPropName = RULE_SYS_PROP_DESCRIPTION)THEN

       v_return(i) := glName(optionIndex);
       ListType := DATA_TYPE_TEXT;

     ELSIF(sysPropName = RULE_SYS_PROP_PARENT)THEN

       v_return(i) := TO_CHAR(glParentId(optionIndex));
       ListType := DATA_TYPE_NODE;

     ELSIF(sysPropName = RULE_SYS_PROP_OPTIONS)THEN

       v_result.DELETE;
       v_result := GENERATE_CHILDRENOF(v_tExplNodeId(j), TO_NUMBER(iPSN(i)));

       FOR ii IN 1..v_result.COUNT LOOP
         v_return(v_return.COUNT + 1) := v_result(ii);
       END LOOP;
       ListType := DATA_TYPE_NODE_COLL;

     ELSIF(sysPropName = RULE_SYS_PROP_MINVALUE)THEN

       v_return(i) := GENERATE_NAME(j, optionId)||'_MIN';
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MAXVALUE)THEN

       v_return(i) := GENERATE_NAME(j, optionId)||'_MAX';
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MINQUANTITY)THEN

       v_return(i) := TO_CHAR(glMinimum(optionIndex));
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MAXQUANTITY)THEN

       v_return(i) := TO_CHAR(glMaximum(optionIndex));
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MINSELECTED)THEN

       v_return(i) := TO_CHAR(glMinimumSel(optionIndex));
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MAXSELECTED)THEN

       v_return(i) := TO_CHAR(glMaximumSel(optionIndex));
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MININSTANCE)THEN

       IF(v_tExprSubtype(j) = 53)THEN

         --For MinInstances and MaxInstances this is a fix for the bug #3558753.

         --The reason we put two sets of MinInstances/MaxInstances was to support backward compatibility
         --of rules using those properties in the LHS. 53 and 54 are not mutable, thus they should not
         --be on the RHS (generic validation using the view already takes care of that). The remaining
         --part is to hard-code generating '0' for 53 (MinInstances) and '1' for 54 (MaxINstances).
         --(see also bug #4366895).

         v_return(i) := '0';
       ELSE

         v_return(i) := GENERATE_NAME(j, optionId)||'_MIN';
       END IF;
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_MAXINSTANCE)THEN

       IF(v_tExprSubtype(j) = 54)THEN

         v_return(i) := '1';
       ELSE

         v_return(i) := GENERATE_NAME(j, optionId)||'_MAX';
       END IF;
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_STATE)THEN

       v_return(i) := GENERATE_NAME(j, optionId);
       ListType := DATA_TYPE_BOOLEAN;

     ELSIF(sysPropName = RULE_SYS_PROP_VALUE)THEN

       v_return(i) := GENERATE_NAME(j, optionId);
       ListType := DATA_TYPE_VOID;

     ELSIF(sysPropName = RULE_SYS_PROP_QUANTITY)THEN

       v_return(i) := GENERATE_NAME(j, optionId);
       ListType := DATA_TYPE_INTEGER;

     ELSIF(sysPropName = RULE_SYS_PROP_INSTANCECOUNT)THEN

       IF(glPsNodeType(optionIndex) IN (PS_NODE_TYPE_COMPONENT,
                                        PS_NODE_TYPE_REFERENCE,
                                        PS_NODE_TYPE_PRODUCT))THEN

         --If it is a non-virtual component/product/reference, we add _ACTUALCOUNT to the name.
         --If it is a virtual component/product/reference, we return '1'.
         --If it is an option, we just generate the name.

         IF(glVirtualFlag(optionIndex) = FLAG_NON_VIRTUAL)THEN
           v_return(i) := GENERATE_NAME(j, optionId)||'_ACTUALCOUNT';
         ELSE
           v_return(i) := '1';
         END IF;
       ELSE
         v_return(i) := GENERATE_NAME(j, optionId);
       END IF;

       ListType := DATA_TYPE_INTEGER;
     ELSE

       RAISE CZ_E_NO_SUCH_PROPERTY;
     END IF;
   ELSE

     BEGIN

       itemId := glItemId(optionIndex);

       v_return(i) := GET_PROPERTY_VALUE(optionId, propertyId, itemId, ListType);

       IF(v_return(i) IS NULL)THEN RAISE CZ_E_NULL_PROPERTY_VALUE; END IF;

       IF(ListType IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

         BEGIN
           nChild := TO_NUMBER(v_return(i));
         EXCEPTION
           WHEN OTHERS THEN

             SELECT name INTO errorMessage
               FROM cz_properties
              WHERE property_id = propertyId;

             localString := v_return(i);
             RAISE CZ_R_INCORRECT_DATA_TYPE;
         END;
       END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RAISE CZ_E_NO_SUCH_PROPERTY;
       WHEN TOO_MANY_ROWS THEN
         RAISE CZ_E_INCORRECT_PROPERTY;
       WHEN OTHERS THEN
         RAISE;
     END;
   END IF;
 END LOOP;

nDebug := 9001009;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_PROPERTY(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return     tStringArray;
 ListType     PLS_INTEGER;
BEGIN

  v_return(1) := PROPERTY_VALUE(j, glIndexByPsNodeId(v_tExprPsNodeId(j)), ListType);
  RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION EXPAND_NODE_OPTIONAL(pvPsNodeId IN NUMBER) RETURN tIntegerArray IS  --kdande; Bug 6881902; 11-Mar-2008
 v_return     tIntegerArray;
 nCount       PLS_INTEGER;
 nStartIndex  PLS_INTEGER;
 nEndIndex    PLS_INTEGER;
 indicator    PLS_INTEGER := 0;
BEGIN

  nStartIndex := glIndexByPsNodeId(pvPsNodeId) + 1;

  IF(NOT glLastChildIndex.EXISTS(pvPsNodeId))THEN
    localString := glName(glIndexByPsNodeId(pvPsNodeId));
    RAISE CZ_E_NO_EXPECTED_CHILDREN;
  END IF;

  nEndIndex := glLastChildIndex(pvPsNodeId);
  nCount := 1;

  IF(glPsNodeType(glIndexByPsNodeId(pvPsNodeId)) = PS_NODE_TYPE_FEATURE)THEN

    indicator := 1;
    FOR i IN nStartIndex..nEndIndex LOOP

      v_return(nCount) := i;
      nCount := nCount + 1;

    END LOOP;
  ELSE

   FOR i IN nStartIndex..nEndIndex LOOP

     IF(glParentId(i) = pvPsNodeId AND glBomRequired(i) = FLAG_BOM_OPTIONAL)THEN

       v_return(nCount) := i;
       nCount := nCount + 1;

     END IF;
   END LOOP;
  END IF;

 --Validate that there are any optional children, otherwise the rule has no sense so
 --just ignore it.

 IF(v_return.COUNT = 0)THEN
   localString := glName(glIndexByPsNodeId(pvPsNodeId));
   IF(indicator = 1)THEN
     RAISE CZ_E_NO_EXPECTED_CHILDREN;
   END IF;
   RAISE CZ_E_NO_OPTIONAL_CHILDREN;
 END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_VAL(j IN PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 nChild    PLS_INTEGER;
 ListType  PLS_INTEGER;
 nCheck    NUMBER;
BEGIN

 IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
  RAISE CZ_E_WRONG_VAL_EXPRESSION;
 END IF;

 nChild := v_ChildrenIndex(v_tExprId(j));
 IF(v_tExprParentId.EXISTS(nChild + 1) AND v_tExprParentId(nChild + 1) = v_tExprId(j))THEN
  RAISE CZ_E_WRONG_VAL_EXPRESSION;
 END IF;

 v_return := GENERATE_EXPRESSION(nChild, ListType);

 BEGIN
  nCheck := TO_NUMBER(v_return(1));
 EXCEPTION
   WHEN OTHERS THEN
     RAISE CZ_E_WRONG_VAL_EXPRESS_TYPE;
 END;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_LOGIC_SIDE(j IN PLS_INTEGER, Operator OUT NOCOPY PLS_INTEGER)
RETURN tStringArray IS
  v_return     tStringArray;
  ListType     PLS_INTEGER := NEVER_EXISTS_ID;
BEGIN

nDebug := 8001110;

   --Removing the 'simple expression' branch as a part of the fix for the bug #3371279.

   IF(v_tExprType(j) = EXPR_OPERATOR AND NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

     RAISE CZ_R_INCOMPLETE_LOGIC_RULE;
   END IF;

   v_return := GENERATE_EXPRESSION(j, ListType);
   Operator := OPERATOR_ALLOF;
   IF(ListType IN (OPERATOR_ANYOF, OPERATOR_ALLOF))THEN
     Operator := ListType;
   END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_LOGIC_RULE IS
 defaultName  tStringArray;
 itemName     tStringArray;
 v_lefts      tStringArray;
 v_rights     tStringArray;
 LeftOp       PLS_INTEGER;
 RightOp      PLS_INTEGER;
 ListType     PLS_INTEGER;
 ObjectName   VARCHAR2(16);
BEGIN

    IF(jAntecedentRoot IS NULL OR jConsequentRoot IS NULL)THEN
      RAISE CZ_R_INVALID_LOGIC_RULE;
    END IF;

nDebug := 8001100;

    IF(nRuleOperator = RULE_OPERATOR_DEFAULTS)THEN

nDebug := 8001101;

      defaultName := GENERATE_EXPRESSION(jAntecedentRoot, ListType);
      ListType := NEVER_EXISTS_ID;
      itemName := GENERATE_EXPRESSION(jConsequentRoot, ListType);
      IF(ListType NOT IN (OPERATOR_ANYOF, OPERATOR_ALLOF))THEN
        ListType := OPERATOR_ANYOF;
      END IF;

nDebug := 8001102;

      localString := NULL;
      IF(itemName.COUNT > 1)THEN localString := sUnsatisfiedId; END IF;

      nLocalDefaults := nLocalDefaults + 1;
      ObjectName := 'D_' || TO_CHAR(nLocalDefaults) || '_' || TO_CHAR(MaxDepthId);

      vLogicLine := 'OBJECT ' || ObjectName || NewLine ||
        'WITH _default = ' || defaultName(1) || NewLine ||
        'GS R ' || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
        'GL' || OperatorLetters(ListType);

      PACK;

nDebug := 8001103;

      FOR i IN 1..itemName.COUNT LOOP

        vLogicLine := itemName(i) || ' ';
        PACK;

      END LOOP;

      vLogicLine := NewLine || 'GR N ' || ObjectName || NewLine;
      PACK;

nDebug := 8001104;

    ELSE

nDebug := 8001105;

        v_lefts := GENERATE_LOGIC_SIDE(jAntecedentRoot, LeftOp);
        v_rights := GENERATE_LOGIC_SIDE(jConsequentRoot, RightOp);

nDebug := 8001106;

        localString := NULL;
        IF(v_lefts.COUNT > 1 OR v_rights.COUNT > 1)THEN localString := sUnsatisfiedId; END IF;

        vLogicLine := 'GS' || OperatorLetters(nRuleOperator) || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
                      'GL' || OperatorLetters(LeftOp);
        PACK;

nDebug := 8001107;

        FOR i IN 1..v_lefts.COUNT LOOP

          vLogicLine := v_lefts(i) || ' ';
          PACK;

        END LOOP;

nDebug := 8001108;

        vLogicLine := NewLine || 'GR' || OperatorLetters(RightOp);
        PACK;

        FOR i IN 1..v_rights.COUNT LOOP

          vLogicLine := v_rights(i) || ' ';
          PACK;

        END LOOP;

        vLogicLine := NewLine;
        PACK;

nDebug := 8001109;

    END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION HAS_INTEGER_VALUE(j IN PLS_INTEGER) RETURN PLS_INTEGER IS
  NodeType     PLS_INTEGER := v_tExprType(j);
  FeatureType  PLS_INTEGER;
  SysPropType  PLS_INTEGER;
  PsNodeIndex  PLS_INTEGER;
BEGIN

  IF(NodeType = EXPR_ARGUMENT)THEN

    PsNodeIndex := LOOKUP_ARGUMENT(j);
    IF(parameterScope(PsNodeIndex).node_id IS NULL)THEN RETURN GENERATE_SCOPE_ERROR; END IF;

    NodeType := EXPR_PSNODE;
    v_tExprPsNodeId(j) := parameterScope(PsNodeIndex).node_id;
  END IF;

  IF(NodeType = EXPR_PSNODE)THEN

    NodeType := glPsNodeType(glIndexByPsNodeId(v_tExprPsNodeId(j)));
    FeatureType := glFeatureType(glIndexByPsNodeId(v_tExprPsNodeId(j)));
    localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(j)));

    IF(NodeType = PS_NODE_TYPE_FEATURE AND FeatureType IN
                 (PS_NODE_FEATURE_TYPE_OPTION, PS_NODE_FEATURE_TYPE_BOOLEAN)
                  AND (NOT v_ChildrenIndex.EXISTS(v_tExprId(j))))THEN

      IF(FeatureType = PS_NODE_FEATURE_TYPE_OPTION)THEN
        errorMessage := 'Option Feature';
      ELSE
        errorMessage := 'Boolean Feature';
      END IF;
      RAISE CZ_R_INCORRECT_NUMERIC_RHS;
    ELSIF(NodeType = PS_NODE_TYPE_COMPONENT AND (NOT v_ChildrenIndex.EXISTS(v_tExprId(j))))THEN

      --Bug #3800339. This is a component without a system property applied. As the data is corrupted,
      --it may not be possible to catch things like that by queries against the seed data.

      errorMessage := 'Component';
      RAISE CZ_R_INCORRECT_NUMERIC_RHS;
    END IF;

    IF(v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN
      IF(v_tExprType(v_ChildrenIndex(v_tExprId(j))) = EXPR_PROP)THEN

        --User properties are not allowed in the consequent expression.

        RAISE CZ_R_INVALID_NUMERIC_RULE;
      END IF;

      SysPropType := v_tExprSubtype(v_ChildrenIndex(v_tExprId(j)));
      IF(NOT h_SeededName.EXISTS(SysPropType))THEN RAISE CZ_E_BAD_PROPERTY_TYPE; END IF;

      IF(h_SeededName(SysPropType) = RULE_SYS_PROP_SELECTION)THEN RETURN GENERATE_DYNAMIC; END IF;

      IF(h_SeededName(SysPropType) <> RULE_SYS_PROP_SELECTION AND
         (NOT APPLICABLE_SYS_PROP(j, NULL, SysPropType)))THEN

        localString := h_ReportName(sysPropType);
        auxIndex := glIndexByPsNodeId(v_tExprPsNodeId(j));
        RAISE CZ_R_INCOMPATIBLE_SYSPROP;
      ELSE

        --Bug #4677027. No rounding operator for contributions to any bom nodes.

        IF(NodeType IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN RETURN GENERATE_CONTRIBUTE; END IF;

        IF(COMPATIBLE_DATA_TYPES(SIGNATURE_DATA_TYPE(h_SignatureId(SysPropType)), DATATYPE_INTEGER))THEN
          RETURN GENERATE_INCREMENT;
        END IF;
      END IF;
    ELSE
      IF(NodeType = PS_NODE_TYPE_OPTION OR
         (NodeType = PS_NODE_TYPE_FEATURE AND FeatureType = PS_NODE_FEATURE_TYPE_INTEGER))THEN
            RETURN GENERATE_INCREMENT;
      END IF;
    END IF;
   RETURN GENERATE_CONTRIBUTE;
  ELSE
   RETURN GENERATE_CONTRIBUTE;
  END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NUMERIC_PART(j IN PLS_INTEGER, NodeId IN OUT NOCOPY NUMBER)  --kdande; Bug 6881902; 11-Mar-2008
RETURN VARCHAR2 IS
  ExprType  PLS_INTEGER := v_tExprType(j);
  v_return  VARCHAR2(4000);
  v_propval tStringArray;
  ListType  PLS_INTEGER;
  nChild    NUMBER;
BEGIN
  IF(ExprType IN (EXPR_PSNODE, EXPR_ARGUMENT))THEN

    v_propval := GENERATE_EXPRESSION(j, ListType);
    v_return := v_propval(1);
    NodeId := v_tExprPsNodeId(j);

  ELSIF(ExprType = EXPR_NODE_TYPE_COUNT)THEN

    v_return := GENERATE_NAME(j, v_tExprPsNodeId(j));
    NodeId := v_tExprPsNodeId(j);

  ELSIF(ExprType = EXPR_NODE_TYPE_LITERAL)THEN

    v_return := v_tExprDataValue(j);
    NodeId := 0;

  ELSIF(ExprType = EXPR_NODE_TYPE_PROP)THEN

    v_return := PROPERTY_VALUE(j, glIndexByPsNodeId(NodeId), ListType);
    NodeId := 0;

    BEGIN
     nChild := TO_NUMBER(v_return);
     IF(nChild = 0)THEN NodeId := -1; END IF;
    EXCEPTION
      WHEN OTHERS THEN

        SELECT name INTO errorMessage
          FROM cz_properties
         WHERE property_id = v_tExprPropertyId(j);

        RAISE CZ_R_INCORRECT_NUMERICLHS;
    END;

  ELSIF(ExprType = EXPR_NODE_TYPE_OPERATOR AND v_tExprSubtype(j) = OPERATOR_DOT)THEN

    nChild := v_ChildrenIndex(v_tExprId(j));
    v_tExplNodeId(nChild + 1) := v_tExplNodeId(nChild);
    v_return := PROPERTY_VALUE(nChild + 1, glIndexByPsNodeId(v_tExprPsNodeId(nChild)), ListType);
    NodeId := v_tExprPsNodeId(nChild);

  ELSE

    RAISE CZ_R_INVALID_NUMERIC_PART;

  END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_BOOLEAN_PART(j IN PLS_INTEGER) RETURN VARCHAR2 IS
  nChild    PLS_INTEGER;
  v_return  VARCHAR2(4000);
  v_index   tIntegerArray;
  ExprId    PLS_INTEGER := v_tExprId(j);
BEGIN

nDebug := 8001001;

  nChild := v_ChildrenIndex(ExprId);

nDebug := 8001002;

  nLocalDefaults := nLocalDefaults + 1;
  v_return := t_prefix || TO_CHAR(nLocalDefaults);

  vLogicLine := 'OBJECT ' || v_return || NewLine ||
                'GS R ... ' || TO_CHAR(nReasonId) || NewLine ||
                'GL' || OperatorLetters(v_tExprSubtype(j));
  PACK;

nDebug := 8001004;

  WHILE(v_tExprParentId(nChild) = ExprId) LOOP

    v_index := EXPAND_NODE(nChild);

    FOR i IN 1..v_index.COUNT LOOP

      vLogicLine := GENERATE_NAME_EXPL(v_ExplByPsNodeId(v_index(i)), v_index(i)) || ' ';
      PACK;
    END LOOP;

    nChild := nChild + 1;
  END LOOP;

nDebug := 8001005;

  vLogicLine := NewLine || 'GR' || OperatorLetters(OPERATOR_ALLOF) || v_return || NewLine;
  PACK;

nDebug := 8001006;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_INCREMENT_LOGIC IS
  v_NodeId        NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  v_HeaderId      NUMBER;
  v_return        VARCHAR2(4000);
  v_result        tStringArray;
  v_index         tStringArray;
  v_acname        VARCHAR2(4000);
  v_nodename      VARCHAR2(4000);
  v_accuname      VARCHAR2(4000);
  ListType        PLS_INTEGER;
  sSign           VARCHAR2(8) := NULL;
  lhsNode         PLS_INTEGER := 0;
  rhsNode         PLS_INTEGER := 0;
  lhsName         VARCHAR2(4000);
  rhsName         VARCHAR2(4000);
  nOpNode         PLS_INTEGER;
  nChild          PLS_INTEGER;
  nGrandChild     PLS_INTEGER;
  nSuffix         PLS_INTEGER := 0;
  iLocal          PLS_INTEGER;
  operatorLiteral VARCHAR2(4000);
  v_name          VARCHAR2(128);
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_INCREMENT_RECORD IS
  v_total  VARCHAR2(4000) := NULL;
BEGIN

  IF(v_tExprSubtype(nOpNode) = OPERATOR_DIV)THEN

    v_total := t_prefix || v_name || '_' || TO_CHAR(nSuffix);
    vLogicLine := 'TOTAL ' || v_total || NewLine ||
                  'CONTRIBUTE ' || lhsName || OperatorLiterals(OPERATOR_DIV) ||
                  rhsName || ' ' || v_total || ' ... ' || TO_CHAR(nReasonId) || NewLine;
    PACK;
  ELSIF(v_tExprSubtype(nOpNode) = OPERATOR_MATHDIV)THEN

    v_total := t_prefix || v_name || '_' || TO_CHAR(nSuffix);
    vLogicLine := 'TOTAL ' || v_total || NewLine ||
                  'MF ' || lhsName || ' ' || rhsName || OperatorLiterals(OPERATOR_MATHDIV) ||
                  v_total || ' ... ' || TO_CHAR(nReasonId) || NewLine;
    PACK;
  END IF;

  sSign := NULL;
  IF(nRuleOperator = RULE_OPERATOR_CONSUMES)THEN
    sSign := '-1 ';
  END IF;

  IF(v_total IS NULL)THEN

   vLogicLine := 'INC ' || sSign || lhsName || ' ' || rhsName || ' ' || v_acname ||
                 OperatorLiteral || '... ' || TO_CHAR(nReasonId) || NewLine;

  ELSE

   vLogicLine := 'INC ' || sSign || v_total || ' ' || v_acname ||
                 OperatorLiteral || '... ' || TO_CHAR(nReasonId) || NewLine;

  END IF;
 PACK;
END;
---------------------------------------------------------------------------------------
BEGIN

  nLocalDefaults := nLocalDefaults + 1;
  v_name := TO_CHAR(nLocalDefaults);

  --Generate the accumulator and corresponding increment relation if necessary

nDebug := 8001200;

  v_return := GENERATE_NUMERIC_PART(jConsequentRoot, v_NodeId);

nDebug := 8001201;

  IF(v_tExprType(jConsequentRoot) = EXPR_NODE_TYPE_OPERATOR AND
     v_tExprSubtype(jConsequentRoot) = OPERATOR_DOT)THEN

nDebug := 8001202;

   nChild := v_ChildrenIndex(v_tExprId(jConsequentRoot)) + 1;
   v_acname := v_return;

   --Commenting the following block out as the fix to bug #1657701. Assuming that this code
   --was necessary until some fixes in participants' model_ref_expl_id population hadn't
   --been done, and now it's obsolete.
/*
   IF(v_NodeId = v_tPsNodeId(v_IndexByNodeId(MaxDepthId)))THEN
     v_acname := PATH_DELIMITER || 'parent' || PATH_DELIMITER || v_acname;
   END IF;
*/

  ELSIF(v_tExprType(jConsequentRoot) = EXPR_PSNODE AND v_ChildrenIndex.EXISTS(v_tExprId(jConsequentRoot)))THEN

    nChild := jConsequentRoot;
    v_acname := v_return;

  ELSIF((NOT v_HeaderByAccId.EXISTS(v_NodeId)) AND
        (glAccumulator(v_NodeId) IS NULL OR glAccumulator(v_NodeId) = FLAG_NO_ACCUMULATOR))THEN

nDebug := 8001203;

   v_HeaderId := glHeaderByPsNodeId(v_NodeId);
   v_nodename := 'P_' || TO_CHAR(glPersistentId(v_NodeId));
   v_accuname := v_nodename || '_ACC';

   --Flush off the buffer because we are about to write to another file

   IF(vLogicText IS NOT NULL)THEN
    INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
     (nHeaderId, v_tSequenceNbr(nHeaderId), vLogicText);
    vLogicText := NULL;
    v_tSequenceNbr(nHeaderId) := v_tSequenceNbr(nHeaderId) + 1;
   END IF;

   --Fix for the bug #2398832 - we may be re-using the accumulator, so we should not
   --assign to it effectivities and usages of a particular node.
   --Do not write the effectivity dates using the actual effective date interval of
   --the corresponding node.

   --iLocal := glIndexByPsNodeId(v_NodeId);
   --CurrentEffFrom := glEffFrom(iLocal);
   --CurrentEffUntil := glEffUntil(iLocal);
   --CurrentUsageMask := glUsageMask(iLocal);

   --Instead make the accumulator always effective and universal.

   CurrentEffFrom := EpochBeginDate;
   CurrentEffUntil := EpochEndDate;
   CurrentUsageMask := AnyUsageMask;

   IF((NOT h_EffFrom.EXISTS(v_HeaderId)) OR
      (h_EffFrom(v_HeaderId) <> CurrentEffFrom OR h_EffUntil(v_HeaderId) <> CurrentEffUntil OR
       h_EffUsageMask(v_HeaderId) <> CurrentUsageMask))THEN

     h_EffFrom(v_HeaderId) := CurrentEffFrom;
     h_EffUntil(v_HeaderId) := CurrentEffUntil;
     h_EffUsageMask(v_HeaderId) := CurrentUsageMask;

     vLogicText := LTRIM(CurrentUsageMask, '0');
     IF(vLogicText IS NOT NULL) THEN
       vLogicText := EffUsagePrefix || vLogicText;
     END IF;

     IF(CurrentEffFrom = EpochBeginDate)THEN
       CurrentFromDate := NULL;
     ELSE
       CurrentFromDate := TO_CHAR(CurrentEffFrom, EffDateFormat);
     END IF;

     IF(CurrentEffUntil = EpochEndDate)THEN
       CurrentUntilDate := NULL;
     ELSE
       CurrentUntilDate := TO_CHAR(CurrentEffUntil, EffDateFormat);
     END IF;

     vLogicText := 'EFF ' || CurrentFromDate || ', ' || CurrentUntilDate || ', ' || vLogicText || NewLine;
   END IF;

   vLogicText := vLogicText || 'TOTAL ' || v_accuname || NewLine ||
                 'INC ' || v_accuname || ' ' || v_nodename ||
                 OperatorLiterals(OPERATOR_ROUND) || '... ' || TO_CHAR(nReasonId) || NewLine;

   INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
    (v_HeaderId, vSeqNbrByHeader(v_HeaderId), vLogicText);
   vLogicText := NULL;
   vSeqNbrByHeader(v_HeaderId) := vSeqNbrByHeader(v_HeaderId) + 1;

   v_HeaderByAccId(v_NodeId) := v_HeaderId;
   v_acname := v_return || '_ACC';

   --Part of the fix for the bug #2857955. We will never be here if glAccumulator(v_NodeId) was
   --FLAG_ACCUMULATOR_ACC because the accumulator would have already been created.

   UPDATE cz_ps_nodes SET
     accumulator_flag = DECODE(glAccumulator(v_NodeId), FLAG_ACCUMULATOR_NT, FLAG_ACCUMULATOR_BOTH, FLAG_ACCUMULATOR_ACC)
   WHERE ps_node_id = v_NodeId;

  ELSE

nDebug := 8001204;

   v_acname := v_return || '_ACC';
  END IF;

nDebug := 8001205;

  --If we are here, than the RHS expression has an integer value and so the LHS expression
  --should have a root rounding operator. So go down one level.
  --However, as a fix for the bug #3558699 we now don't require the root rounding operator
  --if the data type of antecedent is convertible to integer. Therefore we have to be more
  --flexible here.

  IF(v_tExprType(jAntecedentRoot) <> EXPR_OPERATOR OR v_tExprSubtype(jAntecedentRoot) NOT IN
           (OPERATOR_ROUND, OPERATOR_CEILING, OPERATOR_FLOOR, OPERATOR_TRUNCATE, OPERATOR_NONE))THEN
    nOpNode := jAntecedentRoot;
    OperatorLiteral := OperatorLiterals(OPERATOR_NONE);
  ELSE
    nOpNode := v_ChildrenIndex(v_tExprId(jAntecedentRoot));
    OperatorLiteral := OperatorLiterals(v_tExprSubtype(jAntecedentRoot));
  END IF;

  IF(v_tExprType(nOpNode) = EXPR_OPERATOR AND (NOT v_ChildrenIndex.EXISTS(v_tExprId(nOpNode))))THEN
    RAISE CZ_R_INCOMPLETE_NUMERIC_RULE;
  END IF;

  IF(v_ChildrenIndex.EXISTS(v_tExprId(nOpNode)))THEN
    lhsNode := v_ChildrenIndex(v_tExprId(nOpNode));
    rhsNode := lhsNode + v_NumberOfChildren(v_tExprId(nOpNode)) - 1;
  END IF;

  IF(nPresentationFlag = FLAG_FREEFORM_RULE)THEN

    --Check if this is a simple numeric rule that has been upgraded to become a free-form rule. For such
    --rules we want to generate an optimized INC relation.
    --Bug #4047086. However, the operator can only be multiplication to be able to optimize.
    --Bugs #4256960, #4254591. The RHS operand must also be simple, not an operator.

    IF((v_tExprType(nOpNode) = EXPR_OPERATOR AND v_tExprSubtype(nOpNode) = OPERATOR_MULT) AND
       (v_tExprType(rhsNode) <> EXPR_OPERATOR) AND (v_tExprType(lhsNode) = EXPR_LITERAL OR
       (v_tExprType(lhsNode) IN (EXPR_PSNODE, EXPR_ARGUMENT) AND (NOT HAS_OPTIONS_APPLIED(lhsNode)))))THEN

      rhsNode := lhsNode + 1;

      lhsName := GENERATE_NUMERIC_PART(lhsNode, v_NodeId);
      rhsName := GENERATE_NUMERIC_PART(rhsNode, v_NodeId);
      GENERATE_INCREMENT_RECORD;
      RETURN;
    ELSE

nDebug := 8001206;

      numericLHS := 1;
      v_result := GENERATE_EXPRESSION(nOpNode, ListType);
      IF(nRuleOperator = RULE_OPERATOR_CONSUMES)THEN
        sSign := '-1 ';
      END IF;
      vLogicLine := 'INC ' || sSign || v_result(1) || ' ' || v_acname ||
                    OperatorLiteral || '... ' || TO_CHAR(nReasonId) || NewLine;
      PACK;
      RETURN;
    END IF;
  END IF;

nDebug := 8001207;

  FOR i IN lhsNode..rhsNode - 1 LOOP
    IF(v_tExprType(i) = EXPR_PSNODE AND HAS_OPTIONS_APPLIED(i))THEN

      v_index := GENERATE_CHILDRENOF(v_tExplNodeId(i), v_tExprPsNodeId(i));

      FOR ich IN 1..v_index.COUNT LOOP

        lhsName := v_index(ich);
        rhsName := GENERATE_NUMERIC_PART(rhsNode, v_NodeId);
        GENERATE_INCREMENT_RECORD;
        nSuffix := nSuffix + 1;
      END LOOP;
    ELSIF(v_tExprType(i) IN (EXPR_LITERAL, EXPR_PSNODE))THEN

      lhsName := GENERATE_NUMERIC_PART(i, v_NodeId);
      v_NodeId := v_tExprPsNodeId(i);
      rhsName := GENERATE_NUMERIC_PART(rhsNode, v_NodeId);

      GENERATE_INCREMENT_RECORD;
      nSuffix := nSuffix + 1;
    ELSE

      RAISE CZ_R_INVALID_NUMRULE_NODE;
    END IF;
  END LOOP;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_CONTRIBUTE_LOGIC IS
  v_return     VARCHAR2(4000);
  v_result     tStringArray;
  v_index      tStringArray;
  ListType     PLS_INTEGER;
  sSign        VARCHAR2(8);
  lhsNode      PLS_INTEGER;
  rhsNode      PLS_INTEGER;
  lhsName      VARCHAR2(4000);
  rhsName      VARCHAR2(4000);
  nChild       PLS_INTEGER;
  nGrandChild  PLS_INTEGER;
  v_NodeId     NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  nSuffix      PLS_INTEGER := 0;
  nOpNode      PLS_INTEGER := jAntecedentRoot;
  sOpRoot      VARCHAR2(16):= ' ';
  v_HeaderId   NUMBER;
  v_nodename   VARCHAR2(4000);
  v_accuname   VARCHAR2(4000);
  iLocal       PLS_INTEGER;
  v_name       VARCHAR2(128);
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_CONTRIBUTE_RECORD IS
  v_total  VARCHAR2(4000);
  v_local  VARCHAR2(4000) := v_return;
BEGIN
  IF(nRuleOperator = RULE_OPERATOR_CONSUMES)THEN

    v_total := t_prefix || v_name || '_' || TO_CHAR(nSuffix);
    vLogicLine := 'TOTAL ' || v_total || NewLine ||
                  'CONTRIBUTE ' || v_total || OperatorLiterals(OPERATOR_MULT) ||
                  '-1 ' || v_local || ' ... ' || TO_CHAR(nReasonId) || NewLine;
    v_local := v_total;
    PACK;
  END IF;

  IF(v_NodeId = -1 AND v_tExprSubtype(nOpNode) = OPERATOR_MULT)THEN

    vLogicLine := 'CONTRIBUTE ' || lhsName || OperatorLiterals(OPERATOR_SUB) ||
                  lhsName || ' ' || v_local || sOpRoot || '... ' || TO_CHAR(nReasonId) || NewLine;
  ELSIF(v_tExprSubtype(nOpNode) = OPERATOR_MATHDIV)THEN

    v_total := t_prefix || v_name || '_' || TO_CHAR(nSuffix);
    vLogicLine := 'TOTAL ' || v_total || NewLine ||
                  'MF ' || lhsName || ' ' || rhsName || OperatorLiterals(OPERATOR_MATHDIV) ||
                  v_total || ' ... ' || TO_CHAR(nReasonId) || NewLine;
    PACK;
    vLogicLine := 'CONTRIBUTE 1 ' || v_total || ' ' || v_local || sOpRoot || '... ' || TO_CHAR(nReasonId) || NewLine;
  ELSE

    vLogicLine := 'CONTRIBUTE ' || lhsName || OperatorLiterals(v_tExprSubtype(nOpNode)) ||
                  rhsName || ' ' || v_local || sOpRoot || '... ' || TO_CHAR(nReasonId) || NewLine;
  END IF;
  PACK;
END;
---------------------------------------------------------------------------------------
BEGIN

  nLocalDefaults := nLocalDefaults + 1;
  v_name := TO_CHAR(nLocalDefaults);

nDebug := 8002;

  v_return := GENERATE_NUMERIC_PART(jConsequentRoot, v_NodeId);
  optimizeChain := OPTIMIZATION_UNKNOWN;
  optimizeContribute := OPTIMIZATION_UNKNOWN;

  IF(v_tLogicNetType(nHeaderId) = LOGIC_NET_TYPE_NETWORK AND
     glPsNodeType(glIndexByPsNodeId(v_NodeId)) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

    --This is a conditional numeric rule against a BOM node. We will create an accumulator and
    --a 'contribute' relation from the accumulator to the BOM object, if such accumulator does
    --not exist. We'll need to temporarily switch context to the BOM object's structure file.

    IF((NOT v_HeaderByAccId.EXISTS(v_NodeId)) AND
       (glAccumulator(v_NodeId) IS NULL OR glAccumulator(v_NodeId) = FLAG_NO_ACCUMULATOR))THEN

      --Retrieve the corresponding structure file header and prepare the names.

      v_HeaderId := glHeaderByPsNodeId(v_NodeId);
      v_nodename := 'P_' || TO_CHAR(glPersistentId(v_NodeId));
      v_accuname := v_nodename || '_ACC';

      --Flush off the buffer because we are about to write to another file.

      IF(vLogicText IS NOT NULL)THEN
        INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
         (nHeaderId, v_tSequenceNbr(nHeaderId), vLogicText);
        vLogicText := NULL;
        v_tSequenceNbr(nHeaderId) := v_tSequenceNbr(nHeaderId) + 1;
      END IF;

      --Fix for the bug #2398832 - we may be re-using the accumulator, so we should not
      --assign to it effectivities and usages of a particular node.
      --Do not write the effectivity dates using the actual effective date interval of
      --the corresponding node.

      --iLocal := glIndexByPsNodeId(v_NodeId);
      --CurrentEffFrom := glEffFrom(iLocal);
      --CurrentEffUntil := glEffUntil(iLocal);
      --CurrentUsageMask := glUsageMask(iLocal);

      --Instead make the accumulator always effective and universal.

      CurrentEffFrom := EpochBeginDate;
      CurrentEffUntil := EpochEndDate;
      CurrentUsageMask := '0';

      IF((NOT h_EffFrom.EXISTS(v_HeaderId)) OR
         (h_EffFrom(v_HeaderId) <> CurrentEffFrom OR h_EffUntil(v_HeaderId) <> CurrentEffUntil OR
          h_EffUsageMask(v_HeaderId) <> CurrentUsageMask))THEN

        h_EffFrom(v_HeaderId) := CurrentEffFrom;
        h_EffUntil(v_HeaderId) := CurrentEffUntil;
        h_EffUsageMask(v_HeaderId) := CurrentUsageMask;

        vLogicText := LTRIM(CurrentUsageMask, '0');
        IF(vLogicText IS NOT NULL) THEN
          vLogicText := EffUsagePrefix || vLogicText;
        END IF;

        IF(CurrentEffFrom = EpochBeginDate)THEN
          CurrentFromDate := NULL;
        ELSE
          CurrentFromDate := TO_CHAR(CurrentEffFrom, EffDateFormat);
        END IF;

        IF(CurrentEffUntil = EpochEndDate)THEN
          CurrentUntilDate := NULL;
        ELSE
          CurrentUntilDate := TO_CHAR(CurrentEffUntil, EffDateFormat);
        END IF;

        vLogicText := 'EFF ' || CurrentFromDate || ', ' || CurrentUntilDate || ', ' || vLogicText || NewLine;
      END IF;

      --Write the logic record in the structure file.

      vLogicText := vLogicText || 'TOTAL ' || v_accuname || NewLine ||
                    'CONTRIBUTE 1 ' || v_accuname || ' ' || v_nodename ||
                    ' ... ' || TO_CHAR(nReasonId) || NewLine;

      INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
       (v_HeaderId, vSeqNbrByHeader(v_HeaderId), vLogicText);

      vLogicText := NULL;
      vSeqNbrByHeader(v_HeaderId) := vSeqNbrByHeader(v_HeaderId) + 1;
      v_HeaderByAccId(v_NodeId) := v_HeaderId;

      --This line and the ELSE branch below are to fix the bug #2702587 - we need not only create the
      --accumulator and a relation for it to the object but we also need to generate the rule so that
      --it contributes to the accumulator, not the objects.

      v_return := v_return || '_ACC';

      --Part of the fix for the bug #2857955. We will never be here if glAccumulator(v_NodeId) was
      --FLAG_ACCUMULATOR_ACC because the accumulator would have already been created.

      UPDATE cz_ps_nodes SET
        accumulator_flag = DECODE(glAccumulator(v_NodeId), FLAG_ACCUMULATOR_NT, FLAG_ACCUMULATOR_BOTH, FLAG_ACCUMULATOR_ACC)
      WHERE ps_node_id = v_NodeId;

    ELSE

      v_return := v_return || '_ACC';
    END IF;
  END IF;

nDebug := 8003;

  IF(v_tExprSubtype(jAntecedentRoot) IN
      (OPERATOR_ROUND, OPERATOR_FLOOR, OPERATOR_CEILING, OPERATOR_TRUNCATE, OPERATOR_NONE))THEN
    nOpNode := v_ChildrenIndex(v_tExprId(jAntecedentRoot));
    sOpRoot := OperatorLiterals(v_tExprSubtype(jAntecedentRoot));
  END IF;

  IF(nPresentationFlag = FLAG_FREEFORM_RULE)THEN

nDebug := 8004;

   IF(nRuleOperator = RULE_OPERATOR_CONTRIBUTES)THEN

     sSign := '1 ';

     --If this is a numeric contribute rule with a root rounding operator, set the flag and store
     --the target from the Motorola optimization (bug #2540163).

     IF(v_tExprSubtype(jAntecedentRoot) IN
         (OPERATOR_ROUND, OPERATOR_FLOOR, OPERATOR_CEILING, OPERATOR_TRUNCATE))THEN

       optimizeChain := OPTIMIZATION_REQUESTED;
       optimizeTarget := v_return;
     ELSE

       optimizeContribute := OPTIMIZATION_REQUESTED;
     END IF;
   ELSE

     sSign := '-1 ';
   END IF;

nDebug := 8004001;

   numericLHS := 1;
   v_result := GENERATE_EXPRESSION(jAntecedentRoot, ListType);

   --The value may have been changed during the expression generation. If it is not 0, we still
   --want to generate the rule's contribute relation. However, if it is 0 than the relation has
   --already been generated as a part of the optimization so here we just skip it.

   IF(optimizeChain IN (OPTIMIZATION_REQUESTED, OPTIMIZATION_UNKNOWN))THEN
     IF(optimizeContribute = OPTIMIZATION_COMPLETED)THEN

       vLogicLine := 'CONTRIBUTE ' || v_result(1) || v_return || ' ... ' || TO_CHAR(nReasonId) || NewLine;
     ELSE

       vLogicLine := 'CONTRIBUTE ' || v_result(1) || OperatorLiterals(OPERATOR_MULT) ||
                     sSign || v_return || sOpRoot || '... ' || TO_CHAR(nReasonId) || NewLine;
     END IF;

     PACK;
     optimizeChain := OPTIMIZATION_UNKNOWN;
   END IF;

   RETURN;
  END IF;

nDebug := 8005;

  lhsNode := v_ChildrenIndex(v_tExprId(nOpNode));
  rhsNode := lhsNode + v_NumberOfChildren(v_tExprId(nOpNode)) - 1;

nDebug := 8006;

  FOR i IN lhsNode..rhsNode - 1 LOOP

    IF(v_tExprType(i) = EXPR_PSNODE AND HAS_OPTIONS_APPLIED(i))THEN

      v_index := GENERATE_CHILDRENOF(v_tExplNodeId(i), v_tExprPsNodeId(i));

      FOR ich IN 1..v_index.COUNT LOOP

        lhsName := v_index(ich);
        rhsName := GENERATE_NUMERIC_PART(rhsNode, v_NodeId);

        GENERATE_CONTRIBUTE_RECORD;
        nSuffix := nSuffix + 1;
      END LOOP;
    ELSIF(v_tExprType(i) IN (EXPR_LITERAL, EXPR_PSNODE))THEN

      lhsName := GENERATE_NUMERIC_PART(i, v_NodeId);
      v_NodeId := v_tExprPsNodeId(i);
      rhsName := GENERATE_NUMERIC_PART(rhsNode, v_NodeId);

      GENERATE_CONTRIBUTE_RECORD;
      nSuffix := nSuffix + 1;
    ELSE

      RAISE CZ_R_INVALID_NUMRULE_NODE;
    END IF;
  END LOOP;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_DYNAMIC_LOGIC IS
  v_result        tStringArray;
  v_children      tIntegerArray;
  ListType        PLS_INTEGER;
  v_name          VARCHAR2(4000);
  v_return        VARCHAR2(4000);
  v_object        VARCHAR2(4000);
  v_index         PLS_INTEGER;
BEGIN

  IF(v_tExprType(jConsequentRoot) = EXPR_ARGUMENT)THEN

   ListType := DATA_TYPE_NODE;
   v_result := GENERATE_ARGUMENT(jConsequentRoot, ListType);
  END IF;

  nLocalDefaults := nLocalDefaults + 1;
  v_return := t_prefix || TO_CHAR(nLocalDefaults);
  v_index := 1;

  v_result.DELETE;
  v_result := GENERATE_EXPRESSION(jAntecedentRoot, ListType);
  v_children := EXPAND_NODE_OPTIONAL(v_tExprPsNodeId(jConsequentRoot));

  FOR i IN 1..v_result.COUNT LOOP
    FOR ii IN 1..v_children.COUNT LOOP

      v_name := GENERATE_NAME_EXPL(v_tExplNodeId(jConsequentRoot), glPsNodeId(v_children(ii)));
      v_object := v_return || '_' || TO_CHAR(v_index);

      vLogicLine := 'OBJECT ' || v_object || NewLine ||
                    'GS I ... ' || TO_CHAR(nReasonId) || NewLine ||
                    'GL' || OperatorLetters(OPERATOR_ALLOF) || v_name || NewLine ||
                    'GR' || OperatorLetters(OPERATOR_ALLOF) || v_object || NewLine ||
                    'INC ' || v_result(i) || ' ' || v_object || ' ' || v_name ||
                    ' ... ' || TO_CHAR(nReasonId) || NewLine;
      PACK;

      v_index := v_index + 1;
    END LOOP;
  END LOOP;
END GENERATE_DYNAMIC_LOGIC;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_NUMERIC_RULE IS

  v_index  PLS_INTEGER;
BEGIN

    IF(jAntecedentRoot IS NULL OR jConsequentRoot IS NULL)THEN
      RAISE CZ_R_INVALID_NUMERIC_RULE;
    END IF;

    IF(v_tExprType(jAntecedentRoot) = EXPR_OPERATOR AND (NOT v_ChildrenIndex.EXISTS(v_tExprId(jAntecedentRoot))))THEN
      RAISE CZ_R_INCOMPLETE_NUMERIC_RULE;
    END IF;

    IF(HAS_INTEGER_VALUE(jConsequentRoot) = GENERATE_INCREMENT)THEN

      --For a numeric rule, if RHS has an integer value, the antecedent root should be a rounding operator.
      --As a fix for the bug #3558699, we are making this check more flexible - we require the rounding
      --operator only if the data type of the antecedent is not convertible to integer.
      --As a fix for the bug #3764347, if the antecedent root is a multiply operator, we drill down into
      --its operands and check their data types.

      IF(v_tExprType(jAntecedentRoot) <> EXPR_OPERATOR OR v_tExprSubtype(jAntecedentRoot) NOT IN
           (OPERATOR_ROUND, OPERATOR_CEILING, OPERATOR_FLOOR, OPERATOR_TRUNCATE))THEN

        v_index := jAntecedentRoot;
        IF(v_tExprType(v_index) = EXPR_OPERATOR AND v_tExprSubtype(v_index) = OPERATOR_NONE)THEN

          --Bug #4180719. This is an empty operator, drill down one level.

          v_index:= v_ChildrenIndex(v_tExprId(v_index));
        END IF;

        IF(v_tExprType(v_index) = EXPR_OPERATOR AND v_tExprSubtype(v_index) = OPERATOR_MULT)THEN

          --This is a multiply operator, check the data types of the children.

          v_index := v_ChildrenIndex(v_tExprId(v_index));

          IF((NOT COMPATIBLE_DATA_TYPES(v_tExprDataType(v_index), DATA_TYPE_INTEGER)) OR
             (NOT COMPATIBLE_DATA_TYPES(v_tExprDataType(v_index + 1), DATA_TYPE_INTEGER)))THEN

            RAISE CZ_R_INVALID_NUM_SIMPLE_EXPR;
          END IF;
        ELSIF(NOT COMPATIBLE_DATA_TYPES(v_tExprDataType(v_index), DATA_TYPE_INTEGER))THEN

          RAISE CZ_R_INVALID_NUM_SIMPLE_EXPR;
        END IF;
      END IF;

      GENERATE_INCREMENT_LOGIC;
    ELSIF(HAS_INTEGER_VALUE(jConsequentRoot) = GENERATE_CONTRIBUTE)THEN
      GENERATE_CONTRIBUTE_LOGIC;
    ELSIF(HAS_INTEGER_VALUE(jConsequentRoot) = GENERATE_DYNAMIC)THEN
      GENERATE_DYNAMIC_LOGIC;
    ELSE
      RAISE CZ_R_PARAMETER_NOT_FOUND;
    END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_COMPARISON_RULE IS
 leftOper   tStringArray;
 rightOper  tStringArray;
 ListType   PLS_INTEGER;
 jRoot      PLS_INTEGER;
 jChild     PLS_INTEGER;
BEGIN

    IF(jAntecedentRoot IS NULL OR jConsequentRoot IS NULL)THEN
      RAISE CZ_R_INVALID_COMPARISON_RULE;
    END IF;

    leftOper := GENERATE_EXPRESSION(jAntecedentRoot, ListType);

    jRoot := jConsequentRoot;

    IF(v_tExprType(jRoot) = EXPR_OPERATOR AND v_tExprSubtype(jRoot) IN (OPERATOR_ALLOF, OPERATOR_ANYOF) AND
       v_NumberOfChildren(v_tExprId(jRoot)) = 1)THEN

      jChild := v_ChildrenIndex(v_tExprId(jRoot));
      IF(v_tExprType(jChild) = EXPR_PSNODE AND (NOT v_ChildrenIndex.EXISTS(v_tExprId(jChild))))THEN

        jRoot := jChild;
      END IF;
    END IF;

    rightOper := GENERATE_EXPRESSION(jRoot, ListType);

    vLogicLine := 'GS' || OperatorLetters(nRuleOperator) || '... ' || TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ALLOF) || leftOper(1) || NewLine ||
                  'GR' || OperatorLetters(OPERATOR_ALLOF) || rightOper(1) || NewLine;

    PACK;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_LOGIC_TREE(j IN PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
BEGIN

  IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 2)THEN
    RAISE CZ_R_INVALID_LOGIC_RULE;
  END IF;

  nRuleOperator := v_tExprSubtype(j);
  jAntecedentRoot := v_ChildrenIndex(v_tExprId(j));
  jConsequentRoot := jAntecedentRoot + 1;

  v_tExprParentId(jAntecedentRoot) := NULL;
  v_tExprParentId(jConsequentRoot) := NULL;

  --High-level logic rule validation section. Should not do these validations for comparison rules.
  --Make sure antecedent and consequent nodes have logical value.
  --If this is a comparison rule with a DEFAULT operator, which was not allowed before, we will
  --generate this rule as a logic rule (bug #3343569).

  IF(RuleTemplateType = RULE_TYPE_LOGIC_RULE OR nPresentationFlag = FLAG_FREEFORM_RULE OR
     nRuleOperator = RULE_OPERATOR_DEFAULTS)THEN

    nRuleType := RULE_TYPE_LOGIC_RULE;

    IF(NOT HAS_LOGICAL_VALUE(jAntecedentRoot))THEN
      nParam := jAntecedentRoot;
      IF(v_tExprPsNodeId(nParam) IS NULL)THEN
        localString := NULL;
      ELSE
        localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(nParam)));
      END IF;

      RAISE CZ_R_LOGIC_RULE_WRONG_FEAT;
    END IF;

    IF(NOT HAS_LOGICAL_VALUE(jConsequentRoot))THEN
      nParam := jConsequentRoot;
      IF(v_tExprPsNodeId(nParam) IS NULL)THEN
        localString := NULL;
      ELSE
        localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(nParam)));
      END IF;

      RAISE CZ_R_LOGIC_RULE_WRONG_FEAT;
    END IF;

    GENERATE_LOGIC_RULE;

  ELSIF(RuleTemplateType = RULE_TYPE_COMPARISON_RULE)THEN

    nRuleType := RULE_TYPE_COMPARISON_RULE;
    GENERATE_COMPARISON_RULE;

  ELSE

    RAISE CZ_R_UNKNOWN_RULE_TYPE;
  END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_NUMERIC_TREE(j IN PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
BEGIN

  IF((NOT v_ChildrenIndex.EXISTS(v_tExprId(j))) OR v_NumberOfChildren(v_tExprId(j)) <> 2)THEN
    RAISE CZ_R_INVALID_NUMERIC_RULE;
  END IF;

  nRuleType := RULE_TYPE_NUMERIC_RULE;

  nRuleOperator := v_tExprSubtype(j);
  jAntecedentRoot := v_ChildrenIndex(v_tExprId(j));
  jConsequentRoot := jAntecedentRoot + 1;

  v_tExprParentId(jAntecedentRoot) := NULL;
  v_tExprParentId(jConsequentRoot) := NULL;

  --High-level numeric rule validation section.
  --Make sure participating features have correct types.

  FOR i IN expressionStart..expressionEnd LOOP
    IF(v_tExprPsNodeId(i) IS NOT NULL)THEN

      localMinimum := glIndexByPsNodeId(v_tExprPsNodeId(i));

      IF(glPsNodeType(localMinimum) = PS_NODE_TYPE_FEATURE AND
         glFeatureType(localMinimum) = PS_NODE_FEATURE_TYPE_STRING)THEN

         nParam := i;
         RAISE CZ_R_NUMERIC_RULE_WRONG_FEAT;
       END IF;

       IF(i = jConsequentRoot AND trackableAncestor.EXISTS(v_tExprPsNodeId(i)))THEN

          --This node is an ancestor of a BOM trackable item. It should be prohibited from
          --participating on the RHS of a numeric rule.

          nParam := glIndexByPsNodeId(v_tExprPsNodeId(i));
          RAISE CZ_R_TRACKABLE_ANCESTOR;
        END IF;
    END IF;
  END LOOP;

  GENERATE_NUMERIC_RULE;
  RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_TEMPLATE_APPLICATION(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER)
RETURN tStringArray IS

  v_return         tStringArray;
  h_mapExprId      tIntegerArray_idx_vc2;

  jdef             PLS_INTEGER;
  templateStart    PLS_INTEGER;
  templateEnd      PLS_INTEGER;
  v_index          PLS_INTEGER;

---------------------------------------------------------------------------------------
PROCEDURE READ_TEMPLATE(p_template_id IN NUMBER) IS

  --These are local arrays used only to transfer data to the relevant expression arrays.

  v_NodeId          tExplNodeId;
  v_Type            tExprType;
  v_Subtype         tExprSubtype;
  v_Id              tExprId;
  v_ParentId        tExprParentId;
  v_TemplateId      tExprTemplateId;
  v_ExpressId       tExpressId;
  v_PsNodeId        tExplNodeId;
  v_DataValue       tExprDataValue;
  v_PropertyId      tExprPropertyId;
  v_ArgumentIndex   tExprArgumentIndex;
  v_ArgumentName    tExprArgumentName;
  v_ConsequentFlag  tConsequentFlag;
  v_DataNumValue    tExprDataNumValue;
  v_DataType        tExprDataType;

BEGIN

nDebug := 8010100;

  IF(NOT memoryTemplateStart.EXISTS(p_template_id))THEN

    SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, template_id,
           express_id, expr_subtype, ps_node_id, data_value, property_id, argument_index,
           argument_name, consequent_flag, data_num_value, data_type
    BULK COLLECT INTO v_NodeId, v_Type, v_Id, v_ParentId, v_TemplateId,
                      v_ExpressId, v_Subtype, v_PsNodeId, v_DataValue, v_PropertyId, v_ArgumentIndex,
                      v_ArgumentName, v_ConsequentFlag, v_DataNumValue, v_DataType
      FROM cz_expression_nodes
     WHERE rule_id = p_template_id
       AND expr_type <> EXPR_NODE_TYPE_PUNCT
       AND deleted_flag = FLAG_NOT_DELETED
     ORDER BY expr_parent_id, seq_nbr;

nDebug := 8010101;

    IF(v_Id.COUNT = 0)THEN
      RAISE CZ_R_TEMPLATE_UNKNOWN;
    END IF;

    v_index := v_tTmplId.COUNT + 1;
    memoryTemplateStart(p_template_id) := v_index;

nDebug := 8010102;

    FOR i IN 1..v_Id.COUNT LOOP

      IF(v_DataNumValue(i) IS NOT NULL)THEN v_DataValue(i) := TO_CHAR(v_DataNumValue(i)); END IF;

      v_tTmplNodeId(v_index)        := v_NodeId(i);
      v_tTmplType(v_index)          := v_Type(i);
      v_tTmplSubtype(v_index)       := v_Subtype(i);
      v_tTmplId(v_index)            := v_Id(i);
      v_tTmplParentId(v_index)      := v_ParentId(i);
      v_tTmplTemplateId(v_index)    := v_TemplateId(i);
      v_tTmplExpressId(v_index)     := v_ExpressId(i);
      v_tTmplPsNodeId(v_index)      := v_PsNodeId(i);
      v_tTmplPropertyId(v_index)    := v_PropertyId(i);
      v_tTmplArgumentIndex(v_index) := v_ArgumentIndex(i);
      v_tTmplArgumentName(v_index)  := v_ArgumentName(i);
      v_tTmplConsequent(v_index)    := v_ConsequentFlag(i);
      v_tTmplDataValue(v_index)     := v_DataValue(i);
      v_tTmplDataType(v_index)      := v_DataType(i);

      v_index := v_index + 1;
    END LOOP;

    memoryTemplateEnd(p_template_id) := v_tTmplId.COUNT;
  END IF;
END;
---------------------------------------------------------------------------------------
FUNCTION COPY_EXPRESSION_NODE(j_from IN PLS_INTEGER, j_parent IN PLS_INTEGER)
RETURN PLS_INTEGER IS
  j_to  PLS_INTEGER;
BEGIN

nDebug := 8010105;

   j_to := v_tExprId.COUNT + 1;
   nLocalExprId := nLocalExprId + 1;

   v_tExprId(j_to) := nLocalExprId;
   v_tExprParentId(j_to) := j_parent;

   v_tExplNodeId(j_to)       := v_tExplNodeId(j_from);
   v_tExprType(j_to)         := v_tExprType(j_from);
   v_tExprSubtype(j_to)      := v_tExprSubtype(j_from);
   v_tExprTemplateId(j_to)   := v_tExprTemplateId(j_from);
   v_tExprParamIndex(j_to)   := v_tExprParamIndex(j_from);
   v_tExprParSignature(j_to) := v_tExprParSignature(j_from);
   v_tExpressId(j_to)        := v_tExpressId(j_from);
   v_tExprPsNodeId(j_to)     := v_tExprPsNodeId(j_from);
   v_tExprDataValue(j_to)    := v_tExprDataValue(j_from);
   v_tExprDataType(j_to)     := v_tExprDataType(j_from);
   v_tExprPropertyId(j_to)   := v_tExprPropertyId(j_from);
   v_tConsequentFlag(j_to)   := v_tConsequentFlag(j_from);
   v_tExprArgumentName(j_to) := v_tExprArgumentName(j_from);

nDebug := 8010106;

 RETURN j_to;
END;
---------------------------------------------------------------------------------------
PROCEDURE COPY_EXPRESSION_TREE(j_from IN PLS_INTEGER, j_parent IN PLS_INTEGER) IS
  j_child     PLS_INTEGER;
  j_children  tIntegerArray;
BEGIN

nDebug := 8010107;

  IF(v_ChildrenIndex.EXISTS(v_tExprId(j_from)))THEN

    j_child := v_ChildrenIndex(v_tExprId(j_from));

    WHILE(v_tExprParentId(j_child) = v_tExprId(j_from))LOOP

      j_children(j_child) := COPY_EXPRESSION_NODE(j_child, j_parent);
      j_child := j_child + 1;
    END LOOP;

    j_child := v_ChildrenIndex(v_tExprId(j_from));

    WHILE(v_tExprParentId(j_child) = v_tExprId(j_from))LOOP

      COPY_EXPRESSION_TREE(j_child, j_children(j_child));
      j_child := j_child + 1;
    END LOOP;
  END IF;

nDebug := 8010108;

END;
---------------------------------------------------------------------------------------
BEGIN

  RuleTemplateType := v_tExprSubtype(j);
  READ_TEMPLATE(RuleTemplateType);
  templateStart := v_tExprId.COUNT + 1;

  FOR i IN memoryTemplateStart(RuleTemplateType)..memoryTemplateEnd(RuleTemplateType) LOOP

    IF(v_tTmplType(i) = EXPR_ARGUMENT AND v_tTmplArgumentIndex(i) IS NOT NULL)THEN

nDebug := 8010109;

      --This is an argument, may correspond to a collection of paramaters in the template
      --application.

      jdef := 0;

      FOR ii IN expressionStart..expressionEnd LOOP

        IF(v_tExprParamIndex(ii) = v_tTmplArgumentIndex(i))THEN

          jdef := 1;
          v_index := v_tExprId.COUNT + 1;
          nLocalExprId := nLocalExprId + 1;

          v_tExprId(v_index)           := nLocalExprId;
          h_mapExprId(v_tExprId(ii))   := nLocalExprId;

          --If this entry gets overwritten many times, it is not a problem because in this case it
          --will never be used.

          h_mapExprId(v_tTmplId(i))    := nLocalExprId;

          v_tExprParentId(v_index)     := v_tTmplParentId(i);
          v_tExplNodeId(v_index)       := v_tExplNodeId(ii);
          v_tExprType(v_index)         := v_tExprType(ii);
          v_tExprSubtype(v_index)      := v_tExprSubtype(ii);
          v_tExprTemplateId(v_index)   := v_tExprTemplateId(ii);
          v_tExpressId(v_index)        := v_tExpressId(ii);
          v_tExprPsNodeId(v_index)     := v_tExprPsNodeId(ii);
          v_tExprDataValue(v_index)    := v_tExprDataValue(ii);
          v_tExprDataType(v_index)     := v_tExprDataType(ii);
          v_tExprPropertyId(v_index)   := v_tExprPropertyId(ii);
          v_tConsequentFlag(v_index)   := v_tConsequentFlag(ii);
          v_tExprArgumentName(v_index) := v_tExprArgumentName(ii);
          v_tExprParamIndex(v_index)   := v_tExprParamIndex(ii);
          v_tExprParSignature(v_index) := v_tExprParSignature(ii);

          IF(v_tExprType(v_index) = EXPR_TEMPLATE)THEN v_tExprType(v_index) := EXPR_OPERATOR; END IF;
        END IF;
      END LOOP;

      --No parameter was found for this argument - incomplete rule.

      IF(jdef = 0)THEN RAISE CZ_R_INCORRECT_NODE_ID; END IF;
    ELSE

nDebug := 8010110;

      --This is a regular node in the template definition, just copy.

      v_index := v_tExprId.COUNT + 1;
      nLocalExprId := nLocalExprId + 1;

      v_tExprId(v_index)           := nLocalExprId;
      h_mapExprId(v_tTmplId(i))    := nLocalExprId;

      v_tExprParentId(v_index)     := v_tTmplParentId(i);
      v_tExplNodeId(v_index)       := v_tTmplNodeId(i);
      v_tExprType(v_index)         := v_tTmplType(i);
      v_tExprSubtype(v_index)      := v_tTmplSubtype(i);
      v_tExprTemplateId(v_index)   := v_tTmplTemplateId(i);
      v_tExpressId(v_index)        := v_tTmplExpressId(i);
      v_tExprPsNodeId(v_index)     := v_tTmplPsNodeId(i);
      v_tExprDataValue(v_index)    := v_tTmplDataValue(i);
      v_tExprDataType(v_index)     := v_tTmplDataType(i);
      v_tExprPropertyId(v_index)   := v_tTmplPropertyId(i);
      v_tConsequentFlag(v_index)   := v_tTmplConsequent(i);
      v_tExprArgumentName(v_index) := v_tTmplArgumentName(i);
    END IF;
  END LOOP;

nDebug := 8010111;

  templateEnd := v_tExprId.COUNT;

  FOR i IN templateStart..templateEnd LOOP

    IF(v_tExprParentId(i) IS NOT NULL)THEN

      IF(NOT h_mapExprId.EXISTS(v_tExprParentId(i)))THEN RAISE CZ_R_INCORRECT_NODE_ID; END IF;
      v_tExprParentId(i) := h_mapExprId(v_tExprParentId(i));
    END IF;
  END LOOP;

nDebug := 8010112;

  FOR i IN expressionStart..expressionEnd LOOP

    IF(h_mapExprId.EXISTS(v_tExprId(i)))THEN

      COPY_EXPRESSION_TREE(i, h_mapExprId(v_tExprId(i)));
    END IF;
  END LOOP;

  expressionStart := templateStart;
  expressionEnd := v_tExprId.COUNT;

nDebug := 8010114;

  --We need to populate all the auxiliary arrays because now this is the expression we will be
  --processing. We don't really have to empty these arrays.

  v_IndexByExprNodeId.DELETE;
  v_NumberOfChildren.DELETE;
  v_ChildrenIndex.DELETE;

  FOR i IN expressionStart..expressionEnd LOOP

    v_tExprSubtype(i) := v_tExprTemplateId(i);

    --Add the indexing option.

    v_IndexByExprNodeId(v_tExprId(i)) := i;

    IF(v_tExprParentId(i) IS NOT NULL)THEN

      IF(v_NumberOfChildren.EXISTS(v_tExprParentId(i)))THEN
        v_NumberOfChildren(v_tExprParentId(i)) := v_NumberOfChildren(v_tExprParentId(i)) + 1;
      ELSE
        v_NumberOfChildren(v_tExprParentId(i)) := 1;
      END IF;

      IF(NOT v_ChildrenIndex.EXISTS(v_tExprParentId(i)))THEN
        v_ChildrenIndex(v_tExprParentId(i)) := i;
      END IF;

    ELSE

      --This is the root of the exploded template application expression tree.

      jdef := i;
    END IF;

nDebug := 8010115;

  END LOOP;

nDebug := 8010116;

  v_return := GENERATE_EXPRESSION(jdef, ListType);
  RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION LOOKUP_ARGUMENT(j IN PLS_INTEGER) RETURN PLS_INTEGER IS
  argIndex  PLS_INTEGER := 0;
BEGIN

  IF(parameterScope.COUNT = 0)THEN
    RAISE CZ_R_EMPTY_PARAMETER_SCOPE;
  END IF;

  FOR i IN 1..parameterName.COUNT LOOP
    IF(parameterName(i) = v_tExprArgumentName(j))THEN argIndex := i; EXIT; END IF;
  END LOOP;

  IF(argIndex = 0)THEN
    RAISE CZ_R_PARAMETER_NOT_FOUND;
  END IF;

 RETURN argIndex;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ARGUMENT(j IN PLS_INTEGER, ListType IN OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
  argIndex  PLS_INTEGER := 0;
BEGIN

nDebug := 7004010;

  --The procedure can be called with a particular ListType to get a specific field from the
  --parameter scope.
  --Call with ListType = 0 to get the data type from cz_expression_nodes.
  --When called with ListType NULL, generate name or return value field.

  --Bug #4681261 - with re-using of temporary tables, we cannot use stored generated names
  --anymore because these names depend not only on ps_node_id, model_ref_expl_id but also
  --on where the rule is assined. Therefore need to generate the name here instead of in
  --generate_iterator.

  argIndex := LOOKUP_ARGUMENT(j);

  v_tExprPsNodeId(j) := parameterScope(argIndex).node_id;
  v_tExplNodeId(j) := parameterScope(argIndex).node_id_ex;

  --If this is a node, generate name here.

  IF(v_tExprPsNodeId(j) IS NOT NULL AND v_tExplNodeId(j) IS NOT NULL AND
     parameterScope(argIndex).node_value IS NULL AND parameterScope(argIndex).node_obj IS NULL)THEN

       v_return(1) := GENERATE_NAME_EXPL(v_tExplNodeId(j), v_tExprPsNodeId(j));
       parameterScope(argIndex).node_value := v_return(1);
       parameterScope(argIndex).node_obj := v_return(1);
  END IF;

  IF(ListType = DATA_TYPE_VOID)THEN ListType := v_tExprDataType(j); END IF;
  IF(ListType IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL, DATA_TYPE_BOOLEAN, DATA_TYPE_TEXT))THEN

    v_return(1) := parameterScope(argIndex).node_value;
  ELSIF(ListType = DATA_TYPE_NODE)THEN

    v_return(1) := parameterScope(argIndex).node_id;
  ELSIF(ListType = DATA_TYPE_VARIANT)THEN

    v_return(1) := parameterScope(argIndex).node_obj;
  ELSE

    v_return(1) := parameterScope(argIndex).node_value;
  END IF;

nDebug := 7004019;

  RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_FORALL(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tIteratorArray;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_REFNODE(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
  v_children    tIntegerArray;
  v_object      VARCHAR2(128);
  nodeChild     NUMBER;
  featChild     NUMBER;
  featPsNodeId  NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  LocalType     PLS_INTEGER;
  IsNumeric     PLS_INTEGER;
  IsNotZero     PLS_INTEGER;
  nCheck        NUMBER;
  countTrue     PLS_INTEGER := 0;
  countFalse    PLS_INTEGER := 0;
  v_actual      VARCHAR2(16) := ' ';
  v_return      tStringArray;
  v_propval     tStringArray;
  v_psnode      tStringArray;
  CurrentId     NUMBER;
  nodeId        NUMBER; --jonatara:bug7041718
  v_sysprop     PLS_INTEGER;
  v_mutable     VARCHAR2(1);
  v_collection  VARCHAR2(1);
  v_context     PLS_INTEGER;
BEGIN

nDebug := 7004070;

 CurrentId := v_tExprId(j);
 nodeChild := v_ChildrenIndex(CurrentId);
 nLocalDefaults := nLocalDefaults + 1;

 IF(v_tExprType(j) = EXPR_ARGUMENT)THEN

   --This is an argument, we assume that it is of type 'node'.

   LocalType := DATA_TYPE_NODE;
   v_return := GENERATE_ARGUMENT(j, LocalType);

 ELSE

   --It's not an argument, so it's a ps_node.

   v_return(1) := TO_CHAR(v_tExprPsNodeId(j));
 END IF;

 nodeId := v_return(1);

 WHILE(v_tExprParentId.EXISTS(nodeChild) AND v_tExprParentId(nodeChild) = CurrentId)LOOP
   IF(v_tExplNodeId(nodeChild) IS NULL OR v_tExplNodeId(nodeChild) = -1 OR

      --Bug #3821827, caused by a corruption, when the explosion_id value was neither NULL or -1,
      --but was just some incorrect value when it is expected to be NULL.

      (NOT v_NodeLogicLevel.EXISTS(v_tExplNodeId(nodeChild))))THEN

     v_tExplNodeId(nodeChild) := v_ExplByPsNodeId(nodeId);
   END IF;

   IF(h_SeededName.EXISTS(v_tExprSubtype(nodeChild)) AND h_SeededName(v_tExprSubtype(nodeChild)) = RULE_SYS_PROP_SELECTION)THEN

     featChild := v_ChildrenIndex(CurrentId);
     featPsNodeId := v_return(1);
     v_children := EXPAND_NODE_OPTIONAL(featPsNodeId);
     v_sysprop := nodeChild + 1;
     LocalType := DATA_TYPE_VOID;
     v_context := 1;

     IF(v_tExprParentId.EXISTS(v_sysprop) AND v_tExprParentId(v_sysprop) = CurrentId)THEN

       --The system property was explicitly specified.

nDebug := 7004073;

       IF(v_tExprType(v_sysprop) = EXPR_NODE_TYPE_SYSPROP)THEN
         IF(NOT h_SeededName.EXISTS(v_tExprSubtype(v_sysprop)))THEN RAISE CZ_E_BAD_PROPERTY_TYPE; END IF;

         IF(NOT APPLICABLE_SYS_PROP(j, glPsNodeId(v_children(1)), v_tExprSubtype(v_sysprop)))THEN

           auxIndex := v_children(1);
           localString := h_ReportName(v_tExprSubtype(v_sysprop));
           RAISE CZ_R_INCOMPATIBLE_SYSPROP;
         END IF;
       END IF;

       v_tExplNodeId(v_sysprop) := v_ExplByPsNodeId(nodeId);
       v_context := 0;
     ELSE

       --This is Node.Selection(), the actual system property is not specified. It can be either .State()
       --or .Quantity() depending on the context.

       IF(COMPATIBLE_DATA_TYPES(GET_ARGUMENT_INFO(v_tExprParamIndex(j), v_tExprParSignature(j),
                                                  v_mutable, v_collection), DATA_TYPE_BOOLEAN))THEN
         --The context is boolean.

nDebug := 7004071;

         IF(NOT APPLICABLE_SYS_PROP(j, NULL, RULE_SYS_PROP_STATE))THEN

           auxIndex := glIndexByPsNodeId(nodeId);
           localString := 'State';
           RAISE CZ_R_INCOMPATIBLE_SYSPROP;
         END IF;

         ListType := DATA_TYPE_BOOLEAN;
         v_return.DELETE;
         v_return(1) := GENERATE_NAME(j, nodeId);

         --This is Feature.Selection().State(), which in a boolean context is equivalent to Feature.

         EXIT;
       ELSE

         --The context is numeric.

nDebug := 7004072;

         IF(NOT APPLICABLE_SYS_PROP(j, glPsNodeId(v_children(1)), RULE_SYS_PROP_QUANTITY))THEN

           auxIndex := v_children(1);
           localString := 'Quantity';
           RAISE CZ_R_INCOMPATIBLE_SYSPROP;
         END IF;

         LocalType := DATA_TYPE_DECIMAL;
       END IF;
     END IF;

     v_return.DELETE;

     IF(nRuleType = RULE_TYPE_NUMERIC_RULE AND v_context = 0 AND
        v_tExprType(v_sysprop) = EXPR_NODE_TYPE_SYSPROP AND
        h_SeededName(v_tExprSubtype(v_sysprop)) = RULE_SYS_PROP_STATE)THEN

       --This is Node.Selection().State() in a numeric rule, State() was explicitly specified.
       --Bugs #4198455, #4366598.

       v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);
       vLogicLine := 'OBJECT ' || v_return(1) || NewLine;
       PACK;

       FOR i IN 1..v_children.COUNT LOOP

         vLogicLine := 'OBJECT ' || v_return(1) || '_' || TO_CHAR(i) || NewLine ||
                       'GS I ... ' || TO_CHAR(nReasonId) || NewLine ||
                       'GL' || OperatorLetters(OPERATOR_ANYOF) || GENERATE_NAME(j, glPsNodeId(v_children(i))) || NewLine ||
                       'GR' || OperatorLetters(OPERATOR_ANYOF) || v_return(1) || '_' || TO_CHAR(i) || NewLine;
         PACK;

         vLogicLine := 'INC ' || v_return(1) || '_' || TO_CHAR(i) || ' ' || v_return(1) ||
                          OperatorLiterals(OPERATOR_ROUND) || '... ' || TO_CHAR(nReasonId) || NewLine;
         PACK;
       END LOOP;

       RETURN v_return;
     END IF;

     FOR i IN 1..v_children.COUNT LOOP

       v_propval(1) := TO_CHAR(glPsNodeId(v_children(i)));

       IF(v_context = 1)THEN v_propval(1) := GENERATE_NAME(j, glPsNodeId(v_children(i)));
       ELSE v_propval := SYSTEM_PROPERTY_VALUE(v_sysprop, v_propval, LocalType); END IF;
       ListType := LocalType;

       BEGIN
         nCheck := TO_NUMBER(v_propval(1));
         IsNumeric := 1;
         IsNotZero := 1;
         IF(nCheck = 0)THEN
           IsNotZero := 0;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           IsNumeric := 0;
           IsNotZero := 1;
       END;

       IF(LocalType IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

         v_object := t_prefix || TO_CHAR(nLocalDefaults) || '_' || TO_CHAR(i);

         IF(IsNumeric = 1)THEN

            --If a number, we have to GATE it throught the real option. We will do
            --it even if the property value is 0 for consistency.

            vLogicLine := 'OBJECT ' || v_object || NewLine ||
                          'GS I ... ' || TO_CHAR(nReasonId) || NewLine ||
                          'GL' || OperatorLetters(OPERATOR_ANYOF) || GENERATE_NAME(featChild, glPsNodeId(v_children(i))) || NewLine ||
                          'GR' || OperatorLetters(OPERATOR_ANYOF) || v_object || NewLine;
         ELSE

            --If the property value is not numeric, then it is a "P_" name returned
            --as a result of Feat.#Selection.Count. In this case we have to GATE it
            --by making an INC from the real option. This prevents from propagating
            --when the option is FALSE.

            vLogicLine := 'OBJECT ' || v_object || NewLine ||
                          'INC ' || GENERATE_NAME(featChild, glPsNodeId(v_children(i))) || ' ' || v_object ||
                          OperatorLiterals(OPERATOR_NONE) ||
                          '... ' || TO_CHAR(nReasonId) || NewLine;
         END IF;

         PACK;

         IF(NOT v_return.EXISTS(1))THEN

           v_return(1) := t_prefix || TO_CHAR(nLocalDefaults);
           vLogicLine := 'TOTAL ' || v_return(1) || NewLine;
           PACK;
         END IF;

         --In any case we multiply the property count (a number if it's .property or
         --the actual option if it is .#Count) by the intermediate object (the gate)
         --which is only true if the option is true. That way if no options selected
         --the result will be UNKNOWN.

         IF(IsNumeric = 0)THEN

           --If the property is not numeric then we multiply by 1 because it is the
           --count of the option.

           vLogicLine := 'CONTRIBUTE ' || v_object || OperatorLiterals(OPERATOR_MULT) ||
                         '1 ' || v_return(1) || v_actual || '... ' || TO_CHAR(nReasonId) || NewLine;

         ELSIF(IsNotZero = 1)THEN

           --If the property is not zero we have to multiply the gate by the property.

           vLogicLine := 'CONTRIBUTE ' || v_object || OperatorLiterals(OPERATOR_MULT) ||
                         v_propval(1) || ' ' || v_return(1) || v_actual || '... ' || TO_CHAR(nReasonId) || NewLine;

         ELSE

           --If the property value is 0, we will subtract the gate from the gate. This
           --is required in order to propagate 0 only if the option is selected. If we
           --used "gate * 0" it would always propagate 0, even if the gate is UNKNOWN,
           --and we don't want that to happen.

           vLogicLine := 'CONTRIBUTE ' || v_object || OperatorLiterals(OPERATOR_SUB) ||
                         v_object || ' ' || v_return(1) || v_actual || '... ' || TO_CHAR(nReasonId) || NewLine;

         END IF;
         PACK;

       ELSE

         IF(LocalType <> DATA_TYPE_TEXT OR generateCompare = 1)THEN

            v_return(i) := GENERATE_NAME(featChild, glPsNodeId(v_children(i))) || PROPERTY_DELIMITER || v_propval(1);
         ELSE
           --The expression contained a Text property which is only allowed in a comparison expression.
           --A Text property is not allowed in the context of your expression. Rule '%RULENAME' in
           --Model '%MODELNAME' ignored.

            RAISE CZ_R_PROPERTY_NOT_ALLOWED;
         END IF;
       END IF;
     END LOOP;

     IF(LocalType = DATA_TYPE_BOOLEAN)THEN

       --The code inside this block has been changed as a fix for bug #1862896.
       --Start with creating gating objects and INC relations for all the extracted
       --options.

       FOR i IN 1..v_return.COUNT LOOP

         v_object := t_prefix || TO_CHAR(nLocalDefaults) || '_' || TO_CHAR(i);
         vLogicLine := 'OBJECT ' || v_object || NewLine ||
                       'INC ' || EXTRACT_PROPERTY_NODE(v_return(i)) || ' ' || v_object ||
                       OperatorLiterals(OPERATOR_ROUND) || '... ' || TO_CHAR(nReasonId) || NewLine;

         --We are going to calculate the counts of true/false options in order to decide whether
         --we need to include the unsatisfied message id in the following GS relations. First we
         --overwrite the concatenated name/property value string in v_return to be just property
         --value as we don't use the concatenated format of v_return in this branch anymore.

         v_return(i) := EXTRACT_PROPERTY_VALUE(v_return(i));
         IF(v_return(i) = BOOLEAN_TRUE_REPRESENTATION)THEN countTrue := countTrue + 1;
         ELSIF(v_return(i) = BOOLEAN_FALSE_REPRESENTATION)THEN countFalse := countFalse + 1;
         END IF;

         PACK;
       END LOOP;

       --This is the resulting object that will be returned. Any of the TRUE gating
       --objects requires this object, any of the FALSE gating objects negates it.

       v_object := t_prefix || TO_CHAR(nLocalDefaults);
       vLogicLine := 'OBJECT ' || v_object || NewLine;

       IF(countTrue > 0)THEN

         localString := NULL;
         IF(countTrue > 1)THEN localString := sUnsatisfiedId; END IF;

         vLogicLine := vLogicLine || 'GS R ' || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
                     'GL' || OperatorLetters(OPERATOR_ANYOF);
         PACK;

nDebug := 8001156;

         --Generate the list of all the TRUE gating objects.

         FOR i IN 1..v_return.COUNT LOOP

           IF(v_return(i) = BOOLEAN_TRUE_REPRESENTATION)THEN
             vLogicLine := v_object || '_' || TO_CHAR(i) || ' ';
             PACK;
           END IF;
         END LOOP;

         vLogicLine := NewLine || 'GR' || OperatorLetters(OPERATOR_ANYOF) || v_object || NewLine;
       END IF;

       IF(countFalse > 0)THEN

         localString := NULL;
         IF(countFalse > 1)THEN localString := sUnsatisfiedId; END IF;

         vLogicLine := vLogicLine || 'GS N ' || localString || '... ' || TO_CHAR(nReasonId) || NewLine ||
                       'GL' || OperatorLetters(OPERATOR_ANYOF);
         PACK;

nDebug := 8001157;

         --Generate the list of all the FALSE gating objects.

         FOR i IN 1..v_return.COUNT LOOP

           IF(v_return(i) = BOOLEAN_FALSE_REPRESENTATION)THEN
             vLogicLine := v_object || '_' || TO_CHAR(i) || ' ';
             PACK;
           END IF;
         END LOOP;

         vLogicLine := NewLine || 'GR' || OperatorLetters(OPERATOR_ANYOF) || v_object || NewLine;
       END IF;
       PACK;

       v_return.DELETE;
       v_return(1) := v_object;

     END IF;

     --We don't need to move on as we already processed the following expression node(s).

     EXIT;
   ELSE

     IF(v_tExprType(nodeChild) = EXPR_NODE_TYPE_SYSPROP)THEN
       IF(NOT h_SeededName.EXISTS(v_tExprSubtype(nodeChild)))THEN RAISE CZ_E_BAD_PROPERTY_TYPE; END IF;

       IF(NOT APPLICABLE_SYS_PROP(j, NULL, v_tExprSubtype(nodeChild)))THEN

         auxIndex := glIndexByPsNodeId(nodeId);
         localString := h_ReportName(v_tExprSubtype(nodeChild));
         RAISE CZ_R_INCOMPATIBLE_SYSPROP;
       END IF;
     END IF;

     v_propval := SYSTEM_PROPERTY_VALUE(nodeChild, v_return, ListType);

     IF(ListType = DATA_TYPE_TEXT)THEN

       --This is a direct user or system property of DATA_TYPE_TEXT. Currently we don't allow
       --any operations to work with strings other than the comparison operators, therefore we
       --are going from here back to the GENERATE_COMPARE procedure , which expects the output
       --to be a combination of the node's P_ name and the property value.

       --This whole IF block is a part of the fix for the bug #1706286.

       IF(generateCompare = 1)THEN

         FOR i IN 1..v_propval.COUNT LOOP

           v_return(i) := GENERATE_NAME(v_ChildrenIndex(CurrentId), v_return(i)) || PROPERTY_DELIMITER || v_propval(i);
         END LOOP;
       ELSIF(generateCollect = 1)THEN

         --Exclusion from the above comment: we can be generating the COLLECT expression. Such expression
         --can contain references to text properties to be used for comparison in the WHERE clause, but
         --at this time we do not know that they will be used in comparison. We need to just return the
         --value of the property.

         v_return := v_propval;
       ELSE
         --The expression contained a Text property which is only allowed in a comparison expression.
         --A Text property is not allowed in the context of your expression. Rule '%RULENAME' in
         --Model '%MODELNAME' ignored.

         RAISE CZ_R_PROPERTY_NOT_ALLOWED;
       END IF;
     ELSIF(ListType = DATA_TYPE_BOOLEAN AND v_tExprType(nodeChild) = EXPR_PROP)THEN

       --For boolean user properties we replace the 0/1 values with corresponding object names.
       --Bug #3371279.

       FOR i IN 1..v_propval.COUNT LOOP
         IF(v_propval(i) = BOOLEAN_TRUE_REPRESENTATION)THEN v_return(i) := ALWAYS_TRUE;
         ELSE v_return(i) := ALWAYS_FALSE; END IF;
       END LOOP;
     ELSE

       v_return := v_propval;
     END IF;
   END IF;

   nodeChild := nodeChild + 1;
 END LOOP;

nDebug := 7004080;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_ITERATOR(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tIteratorArray IS

  v_return  tIteratorArray;
  v_iterin  tIteratorArray;
  nChild    PLS_INTEGER;
  nCount    PLS_INTEGER;
  nGrand    PLS_INTEGER;
  nType     PLS_INTEGER;
  v_result  tIntegerArray;
  v_record  tStringArray;
  nodeName  VARCHAR2(4000);

BEGIN

nDebug := 7004000;

  nChild := v_ChildrenIndex(v_tExprId(j));

  WHILE(v_tExprParentId(nChild) = v_tExprId(j))LOOP

    v_result.DELETE;
    v_record.DELETE;
    v_iterin.DELETE;

    nCount := v_return.COUNT + 1;

    IF(v_tExprType(nChild) = EXPR_PSNODE)THEN
      IF(v_ChildrenIndex.EXISTS(v_tExprId(nChild)))THEN
        IF(HAS_OPTIONS_APPLIED(nChild))THEN

          IF(v_NumberOfChildren(v_tExprId(j)) = 1)THEN

            temp_table_hash_key(forallLevel) := TO_CHAR(v_tExprPsNodeId(nChild)) || '-' || TO_CHAR(v_tExplNodeId(nChild));
            temp_cmpt_hash_key(compatLevel) := temp_table_hash_key(forallLevel);
          END IF;

          v_result := EXPAND_NODE(nChild);

          FOR i IN 1..v_result.COUNT LOOP

            --Bug #4681261 - with re-using of temporary tables, we cannot use stored generated names
            --anymore because these names depend not only on ps_node_id, model_ref_expl_id but also
            --on where the rule is assined. Name will be generated in generate_argument.
            --nodeName := GENERATE_NAME_EXPL(v_ExplByPsNodeId(v_result(i)), v_result(i));

            v_return(nCount).node_type := DATA_TYPE_NODE;
            v_return(nCount).node_value := NULL;
            v_return(nCount).node_id := v_result(i);
            v_return(nCount).node_obj := NULL;
            v_return(nCount).node_id_ex := v_ExplByPsNodeId(v_result(i));

            nCount := nCount + 1;
          END LOOP;
        ELSE

          v_record := GENERATE_REFNODE(nChild, ListType);

          FOR i IN 1..v_record.COUNT LOOP

            v_return(nCount).node_type := ListType;
            v_return(nCount).node_value := v_record(i);
            v_return(nCount).node_id := NULL;
            v_return(nCount).node_obj := v_record(i);

            nCount := nCount + 1;
          END LOOP;
        END IF;
      ELSE

        --Bug #4681261 - with re-using of temporary tables, we cannot use stored generated names
        --anymore because these names depend not only on ps_node_id, model_ref_expl_id but also
        --on where the rule is assined. Name will be generated in generate_argument.
        --nodeName := GENERATE_NAME(nChild, v_tExprPsNodeId(nChild));

        v_return(nCount).node_type := DATA_TYPE_NODE;
        v_return(nCount).node_value := NULL;
        v_return(nCount).node_id := v_tExprPsNodeId(nChild);
        v_return(nCount).node_obj := NULL;
        v_return(nCount).node_id_ex := v_tExplNodeId(nChild);
      END IF;
    ELSIF(v_tExprType(nChild) = EXPR_LITERAL)THEN

      v_return(nCount).node_type := v_tExprDataType(nChild);
      v_return(nCount).node_value := v_tExprDataValue(nChild);
      v_return(nCount).node_id := NULL;
      v_return(nCount).node_obj := NULL;

    ELSIF(v_tExprType(nChild) = EXPR_OPERATOR AND v_tExprSubtype(nChild) = OPERATOR_OPTIONSOF)THEN

      nGrand := v_ChildrenIndex(v_tExprId(nChild));

      IF(v_NumberOfChildren(v_tExprId(j)) = 1)THEN

        temp_table_hash_key(forallLevel) := TO_CHAR(v_tExprPsNodeId(nGrand)) || '-' || TO_CHAR(v_tExplNodeId(nGrand));
        temp_cmpt_hash_key(compatLevel) := temp_table_hash_key(forallLevel);
      END IF;

      v_result := EXPAND_NODE(nChild);

      FOR i IN 1..v_result.COUNT LOOP

        --Bug #4681261 - with re-using of temporary tables, we cannot use stored generated names
        --anymore because these names depend not only on ps_node_id, model_ref_expl_id but also
        --on where the rule is assined. Name will be generated in generate_argument.
        --nodeName := GENERATE_NAME_EXPL(v_ExplByPsNodeId(v_result(i)), v_result(i));

        v_return(nCount).node_type := DATA_TYPE_NODE;
        v_return(nCount).node_value := NULL;
        v_return(nCount).node_id := v_result(i);
        v_return(nCount).node_obj := NULL;
        v_return(nCount).node_id_ex := v_ExplByPsNodeId(v_result(i));

        nCount := nCount + 1;
      END LOOP;

    ELSIF(v_tExprType(nChild) IN (EXPR_FORALL, EXPR_FORALL_DISTINCT))THEN

      v_iterin := GENERATE_FORALL(nChild, ListType);

      FOR i IN 1..v_iterin.COUNT LOOP

        v_return(nCount) := v_iterin(i);
        nCount := nCount + 1;
      END LOOP;
    ELSE

      v_record := GENERATE_EXPRESSION(nChild, ListType);

      IF(v_tExprPsNodeId(nChild) IS NOT NULL)THEN

         nType := v_tExprType(nChild);
         v_tExprType(nChild) := EXPR_PSNODE;

         v_iterin := GENERATE_ITERATOR(j, ListType);
         v_tExprType(nChild) := nType;

         FOR i IN 1..v_iterin.COUNT LOOP

           v_return(nCount) := v_iterin(i);
           nCount := nCount + 1;
         END LOOP;

      ELSE

         FOR i IN 1..v_record.COUNT LOOP

           v_return(nCount).node_type := DATA_TYPE_VARIANT;
           v_return(nCount).node_value := v_record(i);

           --If it's a 'P_' object, the node_id should still be populated, otherwise it will be impossible
           --to use properties of this objects.

           v_return(nCount).node_id := NULL;
           v_return(nCount).node_obj := v_record(i);

           nCount := nCount + 1;
         END LOOP;
      END IF;
    END IF;

    nChild := nChild + 1;
  END LOOP;

nDebug := 7004009;

  RETURN v_return;
END;
---------------------------------------------------------------------------------------
FUNCTION EXTRACT_PROPERTY_INFO(j IN PLS_INTEGER, PropName OUT NOCOPY VARCHAR2,
                               DataType OUT NOCOPY PLS_INTEGER,
                               PropertyType OUT NOCOPY PLS_INTEGER)
RETURN PLS_INTEGER IS
  propChild   PLS_INTEGER := v_ChildrenIndex(v_tExprId(j));
  propertyId  PLS_INTEGER;
  tempVal NUMBER := -1;
BEGIN

nDebug := 7004040;

  PropertyType := 0;

  WHILE(v_tExprParentId(propChild) = v_tExprId(j) AND
        v_tExprPropertyId(propChild) IS NULL AND v_tExprType(propChild) NOT IN
        (EXPR_NODE_TYPE_SYSPROP, EXPR_LITERAL))LOOP
       propChild := propChild + 1;
  END LOOP;

nDebug := 7004042;

  IF(v_tExprParentId(propChild) = v_tExprId(j))THEN
    BEGIN
      IF(v_tExprPropertyId(propChild) IS NOT NULL)THEN

        SELECT data_type, name INTO DataType, PropName
          FROM cz_properties
           WHERE deleted_flag = FLAG_NOT_DELETED
             AND property_id = v_tExprPropertyId(propChild);
nDebug := 7004043;

        RETURN v_tExprPropertyId(propChild);

      ELSIF(v_tExprType(propChild) = EXPR_LITERAL)THEN

        SELECT property_id, data_type, name INTO propertyId, DataType, PropName
          FROM cz_properties
         WHERE deleted_flag = FLAG_NOT_DELETED
           AND name = v_tExprDataValue(propChild);

        RETURN propertyId;
      ELSE

        PropertyType := 1;
        WHILE(v_tExprParentId(propChild) = v_tExprId(j) AND
              h_SeededName(v_tExprSubtype(propChild)) = RULE_SYS_PROP_PARENT)LOOP

          propChild := propChild + 1;
          PropertyType := PropertyType + 1;
        END LOOP;
        IF(v_tExprParentId(propChild) = v_tExprId(j))THEN

          SELECT data_type, name INTO DataType, PropName
            FROM cz_system_properties_v
           WHERE rule_id = v_tExprSubtype(propChild);

          RETURN v_tExprSubtype(propChild);
        ELSE
          RAISE CZ_E_INCORRECT_PROPERTY;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE CZ_E_INCORRECT_PROPERTY;
    END;
  ELSE
    RAISE CZ_E_INCORRECT_PROPERTY;
  END IF;
nDebug := 7004049;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_FORALL_(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tIteratorArray IS

  iteratorIndex    tIntegerArray;
  iterator         tIteratorArray;
  whereIndex       PLS_INTEGER := 0;
  expressionIndex  PLS_INTEGER := 0;
  nChild           PLS_INTEGER;
  nCount           PLS_INTEGER;
  v_property_id    tIntegerArray;
  v_data_type      tIntegerArray;
  v_prop_name      tStringArray;
  v_return         tIteratorArray;
  v_express        tStringArray;
  SQLCreate        VARCHAR2(8000);
  SQLInsert        VARCHAR2(8000);
  SQLValues        VARCHAR2(8000);
  SQLSelect        VARCHAR2(8000);
  SQLFrom          VARCHAR2(8000);
  SQLWhere         VARCHAR2(8000) := NULL;
  tableName        VARCHAR2(4000);
  tableAlias       VARCHAR2(4000);
  nodeId           NUMBER; --jonatara:bug7041718
  itemId           PLS_INTEGER;
  propertyId       PLS_INTEGER;
  c_values         refCursor;
  v_cursor         NUMBER;
  propertyVal      VARCHAR2(4000);
  localNumber      NUMBER;
  localString      VARCHAR2(4000);
  bindValue        tStringArray;
  v_flag           tIntegerArray;
  v_stack_start    PLS_INTEGER;
  v_stack_end      PLS_INTEGER;
  v_value_exists   PLS_INTEGER := 0;

  bind_node_id     DBMS_SQL.NUMBER_TABLE;
  bind_node_id_ex  DBMS_SQL.NUMBER_TABLE;
  bind_node_type   DBMS_SQL.NUMBER_TABLE;
  bind_node_value  DBMS_SQL.VARCHAR2_TABLE;
  bind_node_obj    DBMS_SQL.VARCHAR2_TABLE;

  TYPE bind_value_table IS TABLE OF DBMS_SQL.VARCHAR2_TABLE INDEX BY BINARY_INTEGER;
  bind_values      bind_value_table;
  arg_table_name   temp_table_hash_type;
  hash_propval_key VARCHAR2(4000);
---------------------------------------------------------------------------------------
PROCEDURE EXPLORE_WHERE(j IN PLS_INTEGER, v_argument IN VARCHAR2) IS
  nChild      PLS_INTEGER;
  nCount      PLS_INTEGER;
  propertyId  PLS_INTEGER;
  dataType    PLS_INTEGER;
  propType    PLS_INTEGER;
  propName    cz_properties.name%TYPE;
BEGIN

nDebug := 7004020;

  nChild := v_ChildrenIndex(v_tExprId(j));

  WHILE(v_tExprParentId(nChild) = v_tExprId(j))LOOP

    nCount := v_property_id.COUNT + 1;

    IF(v_ChildrenIndex.EXISTS(v_tExprId(nChild)))THEN
      IF(v_tExprType(nChild) = EXPR_ARGUMENT AND v_tExprArgumentName(nChild) = v_argument)THEN

        propertyId := EXTRACT_PROPERTY_INFO(nChild, propName, dataType, propType);

	nDebug := 7004021;

        IF(NOT v_flag.EXISTS(propertyId))THEN

          v_property_id(nCount) := propertyId;
          v_data_type(nCount) := dataType;
          v_prop_name(nCount) := propName;
          v_flag(propertyId) := propType;
        END IF;
      ELSE

        EXPLORE_WHERE(nChild, v_argument);
      END IF;
    END IF;
    nChild := nChild + 1;
  END LOOP;

nDebug := 7004029;
END;
---------------------------------------------------------------------------------------
--This function finds every reference to iterators in the FORALL WHERE clause, replaces
--arguments with <table_alias>.value string and reference nodes with <table_alias>.i_<property_id>
--string. It returns the generated SQL WHERE clause of the SELECT statement. All the literal
--values are collected in an array for later binding.

FUNCTION EXAMINE_WHERE_CLAUSE(j IN PLS_INTEGER) RETURN VARCHAR2 IS
  argChild         PLS_INTEGER;
  propType         PLS_INTEGER;
  jChild           PLS_INTEGER;
  isLocal          PLS_INTEGER := 0;
  LocalType        PLS_INTEGER := DATA_TYPE_VOID;
  propName         cz_properties.name%TYPE;
  v_extern         tStringArray;
  v_quotes         VARCHAR2(2);
BEGIN

nDebug := 7004030;

  IF(v_tExprType(j) = EXPR_ARGUMENT)THEN

    --This is an argument. First of all, find out if it corresponds to one of the local iterators - only
    --in this case there will be a temporary table with the corresponding name. Otherwise, it can be an
    --external argument from an upper level FORALL. In this case we have to get the value from the
    --parameter scope and use it as a literal in the generated WHERE clause.

    FOR i IN 1..iteratorIndex.COUNT LOOP

      IF(v_tExprArgumentName(iteratorIndex(i)) = v_tExprArgumentName(j))THEN isLocal := 1; END IF;
    END LOOP;

    IF(isLocal = 1)THEN

      --This is an argument that corresponds to a local iterator.

      IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

        --Add <table_name>.value to the WHERE clause being generated.

        RETURN arg_table_name(v_tExprArgumentName(j)) || '.node_value';
      ELSE

        --Add <table_name>.i_<property_id> to the WHERE clause being generated.
        RETURN arg_table_name(v_tExprArgumentName(j)) || '.i_' ||
               TO_CHAR(EXTRACT_PROPERTY_INFO(j, propName, jChild, propType));
      END IF;
    ELSE

      --This is an external argument, must be in the parameter scope.
      --We assume that it is of type 'node'.

      v_extern := GENERATE_ARGUMENT(j, LocalType);
      IF(LocalType = DATA_TYPE_TEXT)THEN v_quotes := ''''; END IF;

      IF(v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

        RETURN v_quotes || PROPERTY_VALUE(v_ChildrenIndex(v_tExprId(j)), glIndexByPsNodeId(v_tExprPsNodeId(j)), LocalType) || v_quotes;
      ELSE

        RETURN v_quotes || v_extern(1) || v_quotes;
      END IF;
    END IF;
  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_NODE AND v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

    --Nodes can participate in the WHERE clause only with a property applied.
    --Bug #4648386.

    v_extern(1) := EXTRACT_PROPERTY_INFO(j, propName, jChild, propType);
    nDebug := 7004032;
    IF(jChild IN (DATATYPE_TRANSLATABLE_PROP, DATA_TYPE_TEXT))THEN v_quotes := ''''; END IF;

    IF(propType = 0)THEN

      RETURN v_quotes || PROPERTY_VALUE(v_ChildrenIndex(v_tExprId(j)), glIndexByPsNodeId(v_tExprPsNodeId(j)), LocalType) || v_quotes;
    ELSE

      RETURN v_quotes || STATIC_SYSPROP_VALUE(v_tExprPsNodeId(j), v_tExprPropertyId(j), propType) || v_quotes;
    END IF;
  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_LITERAL)THEN

    bindValue(bindValue.COUNT + 1) := v_tExprDataValue(j);
    RETURN ':x' || TO_CHAR(bindValue.COUNT);

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_OPERATOR)THEN

    jChild := v_ChildrenIndex(v_tExprId(j));

    IF(v_tExprSubtype(j) = OPERATOR_TOTEXT)THEN

        --Added for the bug #5620750. Just need ignore the ToText operator to continue using
        --default type conversion.

        RETURN EXAMINE_WHERE_CLAUSE(jChild);
    END IF;

    IF(v_tExprParentId.EXISTS(jChild + 1) AND v_tExprParentId(jChild + 1)= v_tExprId(j))THEN

      IF(v_tExprSubtype(j) IN (OPERATOR_EQUALS,
                               OPERATOR_NOTEQUALS,
                               OPERATOR_EQUALS_INT,
                               OPERATOR_NOTEQUALS_INT,
                               OPERATOR_GT,
                               OPERATOR_LT,
                               OPERATOR_GE,
                               OPERATOR_LE,
                               OPERATOR_AND,
                               OPERATOR_OR))THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || OperatorLiterals(v_tExprSubtype(j)) ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_CONCAT)THEN

        RETURN EXAMINE_WHERE_CLAUSE(jChild) || ' || ' || EXAMINE_WHERE_CLAUSE(jChild + 1);

      ELSIF(v_tExprSubtype(j) = OPERATOR_BEGINSWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_ENDSWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_CONTAINS)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_LIKE)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_MATCHES)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTBEGINWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTENDWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTCONTAIN)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_NOTLIKE)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSE

        RAISE CZ_E_UKNOWN_OPER_IN_COMPAT;
      END IF;

    ELSIF(v_tExprSubtype(j) = OPERATOR_NOT)THEN

      RETURN '(NOT ' || EXAMINE_WHERE_CLAUSE(jChild) || ')';

    ELSE

      RAISE CZ_E_WRONG_OPER_IN_COMPAT;
    END IF;
  ELSE

    RAISE CZ_R_WRONG_COMPAT_EXPRESSION;
  END IF;
END;
---------------------------------------------------------------------------------------
BEGIN

nDebug := 7004100;

  nChild := v_ChildrenIndex(v_tExprId(j));

  WHILE(v_tExprParentId(nChild) = v_tExprId(j)) LOOP
    IF(v_tExprType(nChild) = EXPR_ITERATOR)THEN

      iteratorIndex(iteratorIndex.COUNT + 1) := nChild;
    ELSIF(v_tExprType(nChild) = EXPR_WHERE)THEN

      whereIndex := nChild;
    ELSE

      expressionIndex := nChild;
    END IF;

    nChild := nChild + 1;
  END LOOP;

  v_stack_start := parameterScope.COUNT + 1;
  v_stack_end := v_stack_start + iteratorIndex.COUNT - 1;

nDebug := 7004101;

  FOR i IN 1..iteratorIndex.COUNT LOOP

    bind_node_id.DELETE;
    bind_node_id_ex.DELETE;
    bind_node_type.DELETE;
    bind_node_value.DELETE;
    bind_node_obj.DELETE;
    bind_values.DELETE;

    v_property_id.DELETE;
    v_data_type.DELETE;
    v_prop_name.DELETE;
    v_flag.DELETE;

    temp_table_hash_key(forallLevel) := NULL;
    tableAlias := 'T' || TO_CHAR(i);

    iterator.DELETE;
    iterator := GENERATE_ITERATOR(iteratorIndex(i), ListType);

    IF(whereIndex <> 0)THEN
      EXPLORE_WHERE(whereIndex, v_tExprArgumentName(iteratorIndex(i)));
    END IF;

    IF(temp_table_hash_key(forallLevel) IS NOT NULL)THEN
      FOR ii IN 1..v_property_id.COUNT LOOP
        temp_table_hash_key(forallLevel) := temp_table_hash_key(forallLevel) || '-' || TO_CHAR(v_property_id(ii));
      END LOOP;
    END IF;

nDebug := 7004102;

    IF(temp_table_hash_key(forallLevel) IS NOT NULL AND temp_table_hash.EXISTS(temp_table_hash_key(forallLevel)))THEN

      tableName := temp_table_hash(temp_table_hash_key(forallLevel));
      arg_table_name(v_tExprArgumentName(iteratorIndex(i))) := tableAlias;

      IF(SQLSelect IS NULL)THEN SQLSelect := 'SELECT '; ELSE SQLSelect := SQLSelect || ', '; END IF;
      SQLSelect := SQLSelect || tableAlias || '.node_type, ' ||
                                tableAlias || '.node_id, ' ||
                                tableAlias || '.node_value, ' ||
                                tableAlias || '.node_obj, ' ||
                                tableAlias || '.node_id_ex';
      IF(SQLFrom IS NULL)THEN SQLFrom := ' FROM '; ELSE SQLFrom := SQLFrom || ', '; END IF;
      SQLFrom := SQLFrom || tableName || ' ' || tableAlias;

    ELSE

    tableName := 'G_' || TO_CHAR(table_name_generator);
    table_name_generator := table_name_generator + 1;
    arg_table_name(v_tExprArgumentName(iteratorIndex(i))) := tableAlias;

    IF(SQLSelect IS NULL)THEN SQLSelect := 'SELECT '; ELSE SQLSelect := SQLSelect || ', '; END IF;
    SQLSelect := SQLSelect || tableAlias || '.node_type, ' ||
                              tableAlias || '.node_id, ' ||
                              tableAlias || '.node_value, ' ||
                              tableAlias || '.node_obj, ' ||
                              tableAlias || '.node_id_ex';
    IF(SQLFrom IS NULL)THEN SQLFrom := ' FROM '; ELSE SQLFrom := SQLFrom || ', '; END IF;
    SQLFrom := SQLFrom || tableName || ' ' || tableAlias;

    SQLCreate := 'CREATE GLOBAL TEMPORARY TABLE ' || tableName ||
                 '(node_type NUMBER, node_id NUMBER, node_value VARCHAR2(' || TO_CHAR(MAXIMUM_INDEX_LENGTH) ||
                 '), node_obj VARCHAR2(' || TO_CHAR(MAXIMUM_INDEX_LENGTH) || '), node_id_ex NUMBER';

    FOR ii IN 1..v_property_id.COUNT LOOP

      SQLCreate := SQLCreate || ', i_' || TO_CHAR(v_property_id(ii));

      IF(v_data_type(ii) IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

        SQLCreate := SQLCreate || ' NUMBER';
      ELSE

        SQLCreate := SQLCreate || ' VARCHAR2(' || TO_CHAR(MAXIMUM_INDEX_LENGTH) || ')';
      END IF;
    END LOOP;

    SQLCreate := SQLCreate || ') ON COMMIT PRESERVE ROWS';

nDebug := 7004103;

    BEGIN
      EXECUTE IMMEDIATE SQLCreate;
    EXCEPTION
      WHEN OTHERS THEN

        --If the table already exists, truncate it, drop and try to create again.

        IF(SQLCODE = ORACLE_OBJECT_ALREADY_EXISTS)THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || tableName;
          EXECUTE IMMEDIATE 'DROP TABLE ' || tableName;
          EXECUTE IMMEDIATE SQLCreate;
        ELSE
          RAISE;
        END IF;
    END;

    --The table is created, add its name to the delete list.

    temp_tables(temp_tables.COUNT + 1) := tableName;

nDebug := 7004104;

    SQLInsert := 'INSERT INTO ' || tableName || '(node_type, node_id, node_value, node_obj, node_id_ex';
    SQLValues := ' VALUES (:y1, :y2, :y3, :y4, :y5';

    FOR ii IN 1..v_property_id.COUNT LOOP

      BEGIN

        EXECUTE IMMEDIATE 'CREATE INDEX ' || tableName || '_I' || TO_CHAR(ii) || ' ON ' || tableName ||
                          '(i_' || v_property_id(ii) || ')';
      EXCEPTION
        WHEN OTHERS THEN
          IF(SQLCODE <> ORACLE_OBJECT_ALREADY_EXISTS)THEN RAISE; END IF;
      END;

      SQLInsert := SQLInsert || ', i_' || TO_CHAR(v_property_id(ii));
      SQLValues := SQLValues || ', :x' || TO_CHAR(ii);
    END LOOP;

    SQLInsert := SQLInsert || ')';
    SQLValues := SQLValues || ')';

nDebug := 7004105;

    FOR ii IN 1..iterator.COUNT LOOP

      IF(LENGTH(iterator(ii).node_value) > MAXIMUM_INDEX_LENGTH OR
         LENGTH(iterator(ii).node_obj) > MAXIMUM_INDEX_LENGTH)THEN

        --Bug #3416994. This structure is internally generated, so we give the 'internal error' message.
        RAISE CZ_R_TYPE_NO_PROPERTY;
      END IF;

      bind_node_id(ii) := iterator(ii).node_id;
      bind_node_id_ex(ii) := iterator(ii).node_id_ex;
      bind_node_value(ii) := iterator(ii).node_value;
      bind_node_obj(ii) := iterator(ii).node_obj;
      bind_node_type(ii) := iterator(ii).node_type;

      IF(v_property_id.COUNT > 0)THEN

        --This is only valid if there are properties.

        IF(iterator(ii).node_id IS NULL)THEN RAISE CZ_R_TYPE_NO_PROPERTY; END IF;

        nodeId := glPsNodeId(glIndexByPsNodeId(iterator(ii).node_id));
        itemId := glItemId(glIndexByPsNodeId(iterator(ii).node_id));
      END IF;

      --Get the property values and insert the data.

      FOR jj IN 1..v_property_id.COUNT LOOP

        propertyId := v_property_id(jj);
        hash_propval_key := TO_CHAR(nodeId) || '-' || TO_CHAR(itemId) || '-' ||
                            TO_CHAR(propertyId) || '-' || TO_CHAR(v_flag(propertyId));

        IF(NOT table_hash_propval.EXISTS(hash_propval_key))THEN

          IF(v_flag(propertyId) = 0)THEN

            --User property.

            propertyVal := GET_PROPERTY_VALUE(nodeId, propertyId, itemId, localNumber);

            --Bug #4554100.

            IF(localNumber IS NULL)THEN

               errorMessage := v_prop_name(jj);
               auxIndex := glIndexByPsNodeId(iterator(ii).node_id);
               IF(glParentId(auxIndex) IS NULL)THEN nParam := auxIndex; ELSE
               nParam := glIndexByPsNodeId(glParentId(auxIndex)); END IF;
               RAISE CZ_R_OPTION_NO_PROPERTY;
            END IF;
          ELSE

            --System property.

            propertyVal := STATIC_SYSPROP_VALUE(nodeId, propertyId, v_flag(v_property_id(jj)));
          END IF;

          IF(LENGTH(propertyVal) > MAXIMUM_INDEX_LENGTH)THEN

            --Bug #3416994.

            errorMessage := v_prop_name(jj);
            auxIndex := glIndexByPsNodeId(iterator(ii).node_id);
            IF(glParentId(auxIndex) IS NULL)THEN nParam := auxIndex; ELSE
            nParam := glIndexByPsNodeId(glParentId(auxIndex)); END IF;
            RAISE CZ_R_LONG_PROPERTY_VALUE;
          END IF;

          bind_values(jj)(ii) := propertyVal;
          table_hash_propval(hash_propval_key) := propertyVal;
        ELSE
          bind_values(jj)(ii) := table_hash_propval(hash_propval_key);
        END IF;
      END LOOP;
    END LOOP;

nDebug := 7004106;

    v_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor, SQLInsert || SQLValues, DBMS_SQL.NATIVE);

    DBMS_SQL.BIND_ARRAY(v_cursor, ':y1', bind_node_type);
    DBMS_SQL.BIND_ARRAY(v_cursor, ':y2', bind_node_id);
    DBMS_SQL.BIND_ARRAY(v_cursor, ':y3', bind_node_value);
    DBMS_SQL.BIND_ARRAY(v_cursor, ':y4', bind_node_obj);
    DBMS_SQL.BIND_ARRAY(v_cursor, ':y5', bind_node_id_ex);

    FOR ii IN 1..v_property_id.COUNT LOOP
      DBMS_SQL.BIND_ARRAY(v_cursor, ':x' || TO_CHAR(ii), bind_values(ii));
    END LOOP;

    localNumber := DBMS_SQL.EXECUTE(v_cursor);
    DBMS_SQL.CLOSE_CURSOR(v_cursor);

nDebug := 7004107;

    EXECUTE IMMEDIATE 'ANALYZE TABLE ' || tableName || ' COMPUTE STATISTICS';

    --The table is created and populated, add its name to the hash for re-use if it is eligible.

    IF(temp_table_hash_key(forallLevel) IS NOT NULL)THEN temp_table_hash(temp_table_hash_key(forallLevel)) := tableName; END IF;
    END IF;
  END LOOP;

  --Generate the WHERE clause and run the query with bind variables. For every row returned,
  --generate the expression and return the object.
  --To do this, add GENERATE_ARGUMENT to the GENERATE_EXPRESSION.

nDebug := 7004108;

  IF(whereIndex <> 0)THEN

    SQLWhere := ' WHERE ' || EXAMINE_WHERE_CLAUSE(v_ChildrenIndex(v_tExprId(whereIndex)));
  END IF;

  v_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor, SQLSelect || SQLFrom || SQLWhere, DBMS_SQL.NATIVE);

  FOR i IN 1..bindValue.COUNT LOOP
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':x' || TO_CHAR(i), bindValue(i));
  END LOOP;

  FOR i IN 1..iteratorIndex.COUNT LOOP

    DBMS_SQL.DEFINE_COLUMN(v_cursor, 5 * (i - 1) + 1, localNumber);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 5 * (i - 1) + 2, localNumber);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 5 * (i - 1) + 3, localString, 2000);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 5 * (i - 1) + 4, localString, 2000);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 5 * (i - 1) + 5, localNumber);
  END LOOP;

nDebug := 7004109;

  localNumber := DBMS_SQL.EXECUTE(v_cursor);

  --For every returned row, store the values in the parameter scope, from where GENERATE_EXPRESSION
  --will be retrieving it when generating an argument.

  FOR i IN 1..iteratorIndex.COUNT LOOP

    parameterName(v_stack_start + i - 1) := v_tExprArgumentName(iteratorIndex(i));
  END LOOP;

  WHILE(DBMS_SQL.FETCH_ROWS(v_cursor) > 0)LOOP

    FOR i IN 1..iteratorIndex.COUNT LOOP

      DBMS_SQL.COLUMN_VALUE(v_cursor, 5 * (i - 1) + 1, parameterScope(v_stack_start + i - 1).node_type);
      DBMS_SQL.COLUMN_VALUE(v_cursor, 5 * (i - 1) + 2, parameterScope(v_stack_start + i - 1).node_id);
      DBMS_SQL.COLUMN_VALUE(v_cursor, 5 * (i - 1) + 3, parameterScope(v_stack_start + i - 1).node_value);
      DBMS_SQL.COLUMN_VALUE(v_cursor, 5 * (i - 1) + 4, parameterScope(v_stack_start + i - 1).node_obj);
      DBMS_SQL.COLUMN_VALUE(v_cursor, 5 * (i - 1) + 5, parameterScope(v_stack_start + i - 1).node_id_ex);
    END LOOP;

    IF(expressionIndex <> 0 AND v_ChildrenIndex.EXISTS(v_tExprId(expressionIndex)))THEN

      --Bug #5497235. This is a FORALL with an expression, need to generate the expression.

      generateCollect := 1;

      v_express := GENERATE_EXPRESSION(expressionIndex, ListType);
      generateCollect := 0;

      nCount := v_return.COUNT + 1;

      FOR i IN 1..v_express.COUNT LOOP

        IF(v_tExprType(j) = EXPR_FORALL_DISTINCT)THEN

          --For COLLECT DISTINCT we need to leave only distinct values in the results.

          v_value_exists := 0;

          FOR ii IN 1..nCount - 1 LOOP
            IF(v_return(ii).node_value = v_express(i))THEN v_value_exists := 1; EXIT; END IF;
          END LOOP;
        END IF;

        IF(v_value_exists = 0)THEN

          v_return(nCount).node_obj := v_express(i);
          v_return(nCount).node_value := v_express(i);
          v_return(nCount).node_id := NULL;
          v_return(nCount).node_type := DATA_TYPE_VARIANT;
          nCount := nCount + 1;
        END IF;
      END LOOP;

    ELSE

      --Bug #5497235. This is a COLLECT because there is no expression or the expression is just an argument.
      --In this case we need a direct copy of the parameter scope.

      nCount := v_return.COUNT + 1;

      /* Changing this for loop from 1..parameterscope.count to the below as part of the fix for the bug : 6355526*/

      FOR i IN v_stack_start..v_stack_end LOOP


        v_return(nCount).node_id := parameterScope(i).node_id;
        v_return(nCount).node_type := parameterScope(i).node_type;
        v_return(nCount).node_value := parameterScope(i).node_value;
        v_return(nCount).node_obj := parameterScope(i).node_obj;
        v_return(nCount).node_id_ex := parameterScope(i).node_id_ex;
        nCount := nCount + 1;
      END LOOP;
    END IF;
  END LOOP;

  parameterScope.DELETE(v_stack_start, v_stack_end);
  parameterName.DELETE(v_stack_start, v_stack_end);

nDebug := 7004110;

  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  IF(v_tExprParentId(j) IS NOT NULL AND v_return.COUNT = 0)THEN

    --The FORALL or COLLECT did not yield any rows while it is not the root operator.
    --Need a new message to report this.

    RAISE CZ_R_COMPAT_NO_COMBINATIONS;
  END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
--This function is introduced to support the level of embedding.

FUNCTION GENERATE_FORALL(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tIteratorArray IS
  v_return  tIteratorArray;
BEGIN
  forallLevel := forallLevel + 1;
  v_return := GENERATE_FORALL_(j, ListType);
  forallLevel := forallLevel - 1;
 RETURN v_return;
EXCEPTION
  WHEN OTHERS THEN
    forallLevel := forallLevel - 1;
    RAISE;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_COMPATIBLE_(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS

  iteratorIndex    tIntegerArray;
  iterator         tIteratorArray;
  whereIndex       PLS_INTEGER := 0;
  featureIndex     PLS_INTEGER;
  nChild           NUMBER; -- jonatara:bug7041718
  nCounter         NUMBER; -- jonatara:bug7041718
  v_property_id    tIntegerArray;
  v_data_type      tIntegerArray;
  v_prop_name      tStringArray;
  v_return         tStringArray;
  SQLCreate        VARCHAR2(8000);
  SQLInsert        VARCHAR2(8000);
  SQLValues        VARCHAR2(8000);
  SQLSelect        VARCHAR2(8000);
  SQLFrom          VARCHAR2(8000);
  SQLWhere         VARCHAR2(8000) := NULL;
  tableName        VARCHAR2(4000);
  tableAlias       VARCHAR2(4000);
  nodeId           NUMBER; -- jonatara:bug7041718
  itemId           PLS_INTEGER;
  propertyId       PLS_INTEGER;
  c_values         refCursor;
  v_cursor         NUMBER;
  propertyVal      VARCHAR2(4000);
  localNumber      NUMBER;
  localString      VARCHAR2(4000);
  bindValue        tStringArray;
  typeCheck        NUMBER;
  v_tOptionId      DBMS_SQL.NUMBER_TABLE;
  v_tFeatureId     tExplNodeId;
  v_BackIndex      tIntegerArray;
  v_tExplId        tExplNodeId;
  rowThreshold     PLS_INTEGER := 0;
  v_OptionExists   tIntegerArray_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008
  v_OptionsChain   tIntegerArray;
  v_FeatureIndex   tIntegerArray;
  v_ItemIndex      tIntegerArray;
  chainIndex       PLS_INTEGER := 1;
  currentIndex     PLS_INTEGER;
  itemIndex        PLS_INTEGER;
  itemCount        PLS_INTEGER := 1;
  v_RowLines       tStringArray;
  v_ItemLines      tStringArray;
  ExcludesRequired PLS_INTEGER;
  v_flag           tIntegerArray;

  bind_node_id     DBMS_SQL.NUMBER_TABLE;

  TYPE bind_value_table IS TABLE OF DBMS_SQL.VARCHAR2_TABLE INDEX BY BINARY_INTEGER;
  bind_values      bind_value_table;
  arg_table_name   temp_table_hash_type;

  h_OptionExplId   table_of_tNumberArray_idx_vc2;-- jonatara:bug7041718
  hash_propval_key VARCHAR2(4000);
---------------------------------------------------------------------------------------
PROCEDURE EXPLORE_WHERE(j IN PLS_INTEGER, v_argument IN VARCHAR2) IS
  nChild      PLS_INTEGER;
  nCount      PLS_INTEGER;
  propertyId  PLS_INTEGER;
  dataType    PLS_INTEGER;
  propType    PLS_INTEGER;
  propName    cz_properties.name%TYPE;
BEGIN

nDebug := 7005020;

  nChild := v_ChildrenIndex(v_tExprId(j));

  WHILE(v_tExprParentId(nChild) = v_tExprId(j))LOOP

    nCount := v_property_id.COUNT + 1;

    IF(v_ChildrenIndex.EXISTS(v_tExprId(nChild)))THEN
      IF(v_tExprType(nChild) = EXPR_ARGUMENT AND v_tExprArgumentName(nChild) = v_argument)THEN

        propertyId := EXTRACT_PROPERTY_INFO(nChild, propName, dataType, propType);
	nDebug := 7005021;
        IF(NOT v_flag.EXISTS(propertyId))THEN

          v_property_id(nCount) := propertyId;
          v_data_type(nCount) := dataType;
          v_prop_name(nCount) := propName;
          v_flag(propertyId) := propType;
        END IF;
      ELSE

        EXPLORE_WHERE(nChild, v_argument);
      END IF;
    END IF;
    nChild := nChild + 1;
  END LOOP;

nDebug := 7005029;
END;
---------------------------------------------------------------------------------------
--This function finds every reference to iterators in the FORALL WHERE clause, replaces
--arguments with 'G_<argument_name>.value' string and reference nodes with
--'G_<argument_name>.i_<property_id>' string. It returns the generated SQL
--WHERE clause of the SELECT statement.
--All the literal values are collected in an array for later binding.

FUNCTION EXAMINE_WHERE_CLAUSE(j IN PLS_INTEGER) RETURN VARCHAR2 IS
  argChild         PLS_INTEGER;
  propType         PLS_INTEGER;
  jChild           PLS_INTEGER;
  propName         cz_properties.name%TYPE;
  LocalType        PLS_INTEGER := DATA_TYPE_VOID;
  v_extern         tStringArray;
  v_quotes         VARCHAR2(2);
BEGIN

nDebug := 7005030;

  IF(v_tExprType(j) = EXPR_ARGUMENT)THEN
    IF(NOT v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

      --Add <table_name>.value to the WHERE clause being generated.

      RETURN arg_table_name(v_tExprArgumentName(j)) || '.node_value';
    ELSE

      --Add <table_name>.i_<property_id> to the WHERE clause being generated.
      RETURN arg_table_name(v_tExprArgumentName(j)) || '.i_' ||
             TO_CHAR(EXTRACT_PROPERTY_INFO(j, propName, jChild, propType));
    END IF;
  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_NODE AND v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

    --Nodes can participate in the WHERE clause only with a property applied.
    --Bug #4648386.

    v_extern(1) := EXTRACT_PROPERTY_INFO(j, propName, jChild, propType);

    nDebug := 7005032;

    IF(jChild IN (DATATYPE_TRANSLATABLE_PROP, DATA_TYPE_TEXT))THEN v_quotes := ''''; END IF;

    IF(propType = 0)THEN

      RETURN v_quotes || PROPERTY_VALUE(v_ChildrenIndex(v_tExprId(j)), glIndexByPsNodeId(v_tExprPsNodeId(j)), LocalType) || v_quotes;
    ELSE

      RETURN v_quotes || STATIC_SYSPROP_VALUE(v_tExprPsNodeId(j), v_tExprPropertyId(j), propType) || v_quotes;
    END IF;
  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_LITERAL)THEN

    bindValue(bindValue.COUNT + 1) := v_tExprDataValue(j);
    RETURN ':x' || TO_CHAR(bindValue.COUNT);

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_OPERATOR)THEN

    jChild := v_ChildrenIndex(v_tExprId(j));

    IF(v_tExprSubtype(j) = OPERATOR_TOTEXT)THEN

        --Added for the bug #5620750. Just need to ignore the ToText operator to preserve the
        --default type conversion.

        RETURN EXAMINE_WHERE_CLAUSE(jChild);
    END IF;

    IF(v_tExprParentId.EXISTS(jChild + 1) AND v_tExprParentId(jChild + 1)= v_tExprId(j))THEN

      IF(v_tExprSubtype(j) IN (OPERATOR_EQUALS,
                               OPERATOR_NOTEQUALS,
                               OPERATOR_EQUALS_INT,
                               OPERATOR_NOTEQUALS_INT,
                               OPERATOR_GT,
                               OPERATOR_LT,
                               OPERATOR_GE,
                               OPERATOR_LE,
                               OPERATOR_AND,
                               OPERATOR_OR))THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || OperatorLiterals(v_tExprSubtype(j)) ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_CONCAT)THEN

        RETURN EXAMINE_WHERE_CLAUSE(jChild) || ' || ' || EXAMINE_WHERE_CLAUSE(jChild + 1);

      ELSIF(v_tExprSubtype(j) = OPERATOR_BEGINSWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_ENDSWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_CONTAINS)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_LIKE)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_MATCHES)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTBEGINWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTENDWITH)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_DOESNOTCONTAIN)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ''%'' || ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ' || ''%'')';

      ELSIF(v_tExprSubtype(j) = OPERATOR_NOTLIKE)THEN

        RETURN '(' || EXAMINE_WHERE_CLAUSE(jChild) || ' NOT LIKE ' ||
               EXAMINE_WHERE_CLAUSE(jChild + 1) || ')';

      ELSE

        RAISE CZ_E_UKNOWN_OPER_IN_COMPAT;
      END IF;

    ELSIF(v_tExprSubtype(j) = OPERATOR_NOT)THEN

      RETURN '(NOT ' || EXAMINE_WHERE_CLAUSE(jChild) || ')';

    ELSE

      RAISE CZ_E_WRONG_OPER_IN_COMPAT;
    END IF;
  ELSE

    RAISE CZ_R_WRONG_COMPAT_EXPRESSION;
  END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE GET_ITEM_INDEX(OptionId IN NUMBER, ColumnIndex IN PLS_INTEGER) IS  --kdande; Bug 6881902; 11-Mar-2008
BEGIN

 IF(NOT v_OptionExists.EXISTS(OptionId))THEN
   v_OptionExists(OptionId) := chainIndex;
 ELSE
   currentIndex := v_OptionExists(OptionId);
   LOOP

    IF(v_FeatureIndex(currentIndex) = ColumnIndex)THEN
      itemIndex := v_ItemIndex(currentIndex);
      RETURN;
    END IF;

    EXIT WHEN v_OptionsChain(currentIndex) IS NULL;
    currentIndex := v_OptionsChain(currentIndex);
   END LOOP;

   v_OptionsChain(currentIndex) := chainIndex;
 END IF;

  --Bug #4546828. Use the hashed explosion id for each option.

  v_ItemLines(itemCount) := GENERATE_NAME_EXPL(h_OptionExplId(ColumnIndex)(OptionId), OptionId) || ' ' || TO_CHAR(ColumnIndex - 1);

  v_OptionsChain(chainIndex) := NULL;
  v_FeatureIndex(chainIndex) := ColumnIndex;
  v_ItemIndex(chainIndex) := itemCount;
  itemIndex := itemCount;
  itemCount := itemCount + 1;
  chainIndex := chainIndex + 1;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_STANDARD_PBC IS
BEGIN
  v_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor, SQLSelect || SQLFrom || SQLWhere, DBMS_SQL.NATIVE);

  FOR i IN 1..bindValue.COUNT LOOP
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':x' || TO_CHAR(i), bindValue(i));
  END LOOP;

nDebug := 7005109;

  localNumber := DBMS_SQL.EXECUTE(v_cursor);

  LOOP

    FOR i IN 1..iteratorIndex.COUNT LOOP
      DBMS_SQL.DEFINE_ARRAY(v_cursor, i, v_tOptionId, DBMS_SQL_MAX_BUFFER_SIZE, 1);
    END LOOP;

    localNumber := DBMS_SQL.FETCH_ROWS(v_cursor);

    FOR i IN 1..v_tFeatureId.COUNT LOOP

      DBMS_SQL.COLUMN_VALUE(v_cursor, i, v_tOptionId);

      FOR n IN 1..localNumber LOOP

        GET_ITEM_INDEX(v_tOptionId(n), i);

        --Fix for the bug #2256166: changed n to rowThreshold + n in the EXISTS operator.

        IF(v_RowLines.EXISTS(rowThreshold + n))THEN
          v_RowLines(rowThreshold + n) := v_RowLines(rowThreshold + n) || ' ' || TO_CHAR(itemIndex - 1);
        ELSE
          v_RowLines(rowThreshold + n) := ' ' || TO_CHAR(itemIndex - 1);
        END IF;
      END LOOP;
    END LOOP;
    EXIT WHEN localNumber <> DBMS_SQL_MAX_BUFFER_SIZE;
    rowThreshold := rowThreshold + DBMS_SQL_MAX_BUFFER_SIZE;
  END LOOP;

nDebug := 7005110;

  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  --If there's no valid combinations, report the rule and ignore it.

  IF(v_RowLines.COUNT = 0)THEN
    RAISE CZ_R_COMPAT_NO_COMBINATIONS;
  END IF;

  --Generate the combo structure

  vLogicLine := 'OBJECT P_R' || TO_CHAR(nRuleId) || '_' || TO_CHAR(v_tExprId(j)) || NewLine ||
                'COMBO P_R' || TO_CHAR(nRuleId) || '_' || TO_CHAR(v_tExprId(j)) || ' ' ||
                TO_CHAR(v_ItemLines.COUNT) || ' ' || TO_CHAR(v_RowLines.COUNT) || ' ' ||
                TO_CHAR(v_tFeatureId.COUNT) || ' ... ' || TO_CHAR(nReasonId) || NewLine;
  PACK;

  FOR i IN 1..v_ItemLines.COUNT LOOP

    vLogicLine := 'CI ' || TO_CHAR(i - 1) || ' ' || v_ItemLines(i) || NewLine;
    PACK;
  END LOOP;

  FOR i IN 1..v_tFeatureId.COUNT LOOP

    IF(GenerateGatedCombo = 0)THEN

      --Use intermediate variable instead of using NVL because this is faster

      localNumber := glIndexByPsNodeId(v_tFeatureId(i));
      localString := TO_CHAR(glMaximum(localNumber));

      --If it's a BOM item, we use maximum_selected instead of maximum

      IF(glPsNodeType(localNumber) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN
        localString := TO_CHAR(glMaximumSel(localNumber));
      END IF;

      IF(localString IS NULL)THEN localString := '-1'; END IF;
      vLogicLine := ' O';
    ELSE

      --Generate gated combinations: maximum is always -1, the 'G' argument is followed
      --by the feature name.

      localString := '-1';
      vLogicLine := ' G ' || GENERATE_NAME(v_BackIndex(i), v_tFeatureId(i));
    END IF;

    vLogicLine := 'CC ' || TO_CHAR(i - 1) || ' 0 ' || localString || vLogicLine || NewLine;
    PACK;
  END LOOP;

  FOR i IN 1..v_RowLines.COUNT LOOP

    vLogicLine := 'CR ' || TO_CHAR(i - 1) || v_RowLines(i) || NewLine;
    PACK;
  END LOOP;

  vLogicLine := 'COMBO_END' || NewLine;
  PACK;

  --Generate the exclude relations if necessary.
  --The code is re-written as part of the fix for the bug #4546828 to use the new hash table.

  FOR i IN 1..v_tFeatureId.COUNT LOOP

    --We will use this array in the local context now

    v_OptionExists.DELETE;

    FOR n IN 1..v_ItemLines.COUNT LOOP

     itemIndex := INSTR(v_ItemLines(n), ' ', -1) + 1;

     IF(TO_NUMBER(SUBSTR(v_ItemLines(n), itemIndex)) = i - 1)THEN

       currentIndex := INSTR(v_ItemLines(n), '_', -1) + 1;
       v_OptionExists(TO_NUMBER(SUBSTR(v_ItemLines(n), currentIndex, itemIndex - currentIndex - 1))) := 1;
     END IF;
    END LOOP;

    ExcludesRequired := 0;
    nChild := h_OptionExplId(i).FIRST;
    nCounter := nChild;

    WHILE(nChild IS NOT NULL) LOOP
      IF(NOT v_OptionExists.EXISTS(glPersistentId(nChild)))THEN
         ExcludesRequired := 1;
         EXIT;
      END IF;
      nChild := h_OptionExplId(i).NEXT(nChild);
    END LOOP;

    IF(ExcludesRequired = 1)THEN

     nChild := nCounter;

     vLogicLine := 'GS E ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N ';
     PACK;

     WHILE(nChild IS NOT NULL) LOOP
       IF(NOT v_OptionExists.EXISTS(glPersistentId(nChild)))THEN
         vLogicLine := GENERATE_NAME_EXPL(h_OptionExplId(i)(nChild), nChild) || ' ';
         PACK;
       END IF;
       nChild := h_OptionExplId(i).NEXT(nChild);
     END LOOP;

     vLogicLine := NewLine || 'GR L ';
     PACK;

     FOR n IN 1..v_tFeatureId.COUNT LOOP
       IF(n <> i)THEN
         vLogicLine := GENERATE_NAME(v_BackIndex(n), v_tFeatureId(n)) || ' ';
         PACK;
       END IF;
     END LOOP;

     vLogicLine := NewLine;
     PACK;
    END IF; --Excludes required
  END LOOP;
END GENERATE_STANDARD_PBC;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_OPTIMIZED_PBC IS

  TYPE tVarcharTable IS TABLE OF VARCHAR2(32000) INDEX BY VARCHAR2(32000);

  v_options              SYSTEM.cz_lce_compat_tab_type := SYSTEM.cz_lce_compat_tab_type();
  a_min                  PLS_INTEGER;
  b_min                  PLS_INTEGER;
  a_object_name          VARCHAR2(4000);
  b_object_name          VARCHAR2(4000);
  v_option_a             DBMS_SQL.NUMBER_TABLE;
  v_option_b             DBMS_SQL.NUMBER_TABLE;
  current_option         NUMBER;
  v_bitpos_a             tIntegerArray_idx_vc2; --jonatara:bug7041718
  v_bitpos_b             tIntegerArray_idx_vc2;
  v_bitinv_a             tIntegerArray;
  v_bitinv_b             tIntegerArray;
  v_mask                 VARCHAR2(32000);
  v_group                VARCHAR2(32000);
  v_rel                  VARCHAR2(1);
  v_group_by_set_mask_a  tVarcharTable;
  v_group_by_set_mask_b  tVarcharTable;
/*-------------------------------------------------------------------------------------
  CREATE OR REPLACE TYPE cz_lce_compat_rec_type IS OBJECT (option_a NUMBER, option_b NUMBER);
  CREATE OR REPLACE TYPE cz_lce_compat_tab_type IS TABLE OF cz_lce_compat_rec_type;
---------------------------------------------------------------------------------------*/
  FUNCTION get_feature_minimum(p_feature_id IN NUMBER) RETURN PLS_INTEGER IS
    v_idx  NUMBER; --kdande; Bug 6881902; 11-Mar-2008
    v_min  NUMBER; --kdande; Bug 6881902; 11-Mar-2008
  BEGIN
      v_idx := glIndexByPsNodeId(p_feature_id);
      v_min := glMinimum(v_idx);

      IF(glPsNodeType(v_idx) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN
        v_min := glMinimumSel(v_idx);
      END IF;
    if(v_min IS NULL OR v_min < 1)THEN RETURN 0; END IF;
   RETURN 1;
  END;
---------------------------------------------------------------------------------------
PROCEDURE init_set_mask(p_size IN PLS_INTEGER) IS
BEGIN
  v_mask := '0';
  v_mask := RPAD(v_mask, p_size, '0');
END;
---------------------------------------------------------------------------------------
PROCEDURE set_mask(p_bitpos IN PLS_INTEGER) IS
BEGIN
  v_mask := SUBSTR(v_mask, 1, p_bitpos - 1) || '1' || SUBSTR(v_mask, p_bitpos + 1);
END;
---------------------------------------------------------------------------------------
PROCEDURE init_group_mask_a(p_key IN VARCHAR2) IS
BEGIN
  v_group_by_set_mask_a(p_key) := '0';
  v_group_by_set_mask_a(p_key) := RPAD(v_group_by_set_mask_a(p_key), v_bitpos_a.COUNT, '0');
END;
---------------------------------------------------------------------------------------
PROCEDURE set_group_mask_a(p_key IN VARCHAR2, p_bitpos IN PLS_INTEGER) IS
BEGIN
  v_group_by_set_mask_a(p_key) := SUBSTR(v_group_by_set_mask_a(p_key), 1, p_bitpos - 1)
                        || '1' || SUBSTR(v_group_by_set_mask_a(p_key), p_bitpos + 1);
END;
---------------------------------------------------------------------------------------
PROCEDURE init_group_mask_b(p_key IN VARCHAR2) IS
BEGIN
  v_group_by_set_mask_b(p_key) := '0';
  v_group_by_set_mask_b(p_key) := RPAD(v_group_by_set_mask_b(p_key), v_bitpos_b.COUNT, '0');
END;
---------------------------------------------------------------------------------------
PROCEDURE set_group_mask_b(p_key IN VARCHAR2, p_bitpos IN PLS_INTEGER) IS
BEGIN
  v_group_by_set_mask_b(p_key) := SUBSTR(v_group_by_set_mask_b(p_key), 1, p_bitpos - 1)
                        || '1' || SUBSTR(v_group_by_set_mask_b(p_key), p_bitpos + 1);
END;
---------------------------------------------------------------------------------------
FUNCTION in_mask(p_bitpos IN PLS_INTEGER) RETURN BOOLEAN IS
BEGIN
  RETURN (SUBSTR(v_mask, p_bitpos, 1) = '1');
END;
---------------------------------------------------------------------------------------
FUNCTION in_group(p_bitpos IN PLS_INTEGER) RETURN BOOLEAN IS
BEGIN
  RETURN (SUBSTR(v_group, p_bitpos, 1) = '1');
END;
---------------------------------------------------------------------------------------
BEGIN
nDebug := 8000000;
  v_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(v_cursor, SQLSelect || SQLFrom || SQLWhere, DBMS_SQL.NATIVE);

  FOR i IN 1..bindValue.COUNT LOOP
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':x' || TO_CHAR(i), bindValue(i));
  END LOOP;

  localNumber := DBMS_SQL.EXECUTE(v_cursor);
nDebug := 8000001;
  LOOP

    DBMS_SQL.DEFINE_ARRAY(v_cursor, 1, v_option_a, DBMS_SQL_MAX_BUFFER_SIZE, 1);
    DBMS_SQL.DEFINE_ARRAY(v_cursor, 2, v_option_b, DBMS_SQL_MAX_BUFFER_SIZE, 1);

    localNumber := DBMS_SQL.FETCH_ROWS(v_cursor);

    DBMS_SQL.COLUMN_VALUE(v_cursor, 1, v_option_a);
    DBMS_SQL.COLUMN_VALUE(v_cursor, 2, v_option_b);
nDebug := 8000002;
    FOR i IN 1..localNumber LOOP
      v_options.EXTEND();
      v_options(rowThreshold + i) := SYSTEM.cz_lce_compat_rec_type(v_option_a(i), v_option_b(i));
nDebug := 8000003;
      --These arrays store 'bit positions' for every a or b option. Later they will be used in construction
      --of the 'bit masks' for compatibility groups and sets.
      --The 'inv' arrays allow to quickly get an option_id by its bit position.

      IF(NOT v_bitpos_a.EXISTS(v_option_a(i)))THEN

         v_bitpos_a(v_option_a(i)) := v_bitpos_a.COUNT + 1;
         v_bitinv_a(v_bitpos_a(v_option_a(i))) := v_option_a(i);
      END IF;
      IF(NOT v_bitpos_b.EXISTS(v_option_b(i)))THEN

         v_bitpos_b(v_option_b(i)) := v_bitpos_b.COUNT + 1;
         v_bitinv_b(v_bitpos_b(v_option_b(i))) := v_option_b(i);
      END IF;
    END LOOP;

    v_option_a.DELETE;
    v_option_b.DELETE;

    EXIT WHEN localNumber <> DBMS_SQL_MAX_BUFFER_SIZE;
    rowThreshold := rowThreshold + DBMS_SQL_MAX_BUFFER_SIZE;
  END LOOP;
nDebug := 8000005;
  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  --If there's no valid combinations, report the rule and ignore it.

  IF(v_options.COUNT = 0)THEN
    RAISE CZ_R_COMPAT_NO_COMBINATIONS;
  END IF;

  IF (v_options.COUNT = (featOptionsCount(v_tFeatureId(1)) * featOptionsCount(v_tFeatureId(2)))) THEN

     --This is a two-column pbc rule, and the number of valid combinations is equal to the
     --number of possible combinations. The rule can be ignored.

     RETURN;
  END IF;

  a_min := get_feature_minimum(v_tFeatureId(1));
  b_min := get_feature_minimum(v_tFeatureId(2));

  --Generate the main relations.

  IF(a_min = 0)THEN

    --We need a temporary object to represent Not(A).

    nLocalDefaults := nLocalDefaults + 1;
    a_object_name := t_prefix || TO_CHAR(nLocalDefaults);

    vLogicLine := 'OBJECT ' || a_object_name || NewLine ||
                  'GS N ... ' || TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ANYOF) || GENERATE_NAME(v_BackIndex(1), v_tFeatureId(1)) || NewLine ||
                  'GR' || OperatorLetters(OPERATOR_ANYOF) || a_object_name || NewLine;
    PACK;
    a_object_name := a_object_name || ' ';
  END IF;

  IF(b_min = 0)THEN

    --We need a temporary object to represent Not(B).

    nLocalDefaults := nLocalDefaults + 1;
    b_object_name := t_prefix || TO_CHAR(nLocalDefaults);

    vLogicLine := 'OBJECT ' || b_object_name || NewLine ||
                  'GS N ... ' || TO_CHAR(nReasonId) || NewLine ||
                  'GL' || OperatorLetters(OPERATOR_ANYOF) || GENERATE_NAME(v_BackIndex(2), v_tFeatureId(2)) || NewLine ||
                  'GR' || OperatorLetters(OPERATOR_ANYOF) || b_object_name || NewLine;
    PACK;
    b_object_name := b_object_name || ' ';
  END IF;

  current_option := -1;
nDebug := 8000010;
  FOR a IN (SELECT option_a, option_b FROM TABLE(v_options) ORDER BY option_a) LOOP

    IF(a.option_a <> current_option)THEN

      IF(current_option <> -1)THEN

        --We just moved to the next option. current_option is still the previous option for
        --which the generating of the compatible set mask is completed, and the actual mask
        --is still in v_mask.
        --Here either add the options to an existing compatibility group mask, or create a
        --new compatibility group mask.

        IF(NOT v_group_by_set_mask_a.EXISTS(v_mask))THEN init_group_mask_a(v_mask); END IF;
        set_group_mask_a(v_mask, v_bitpos_a(current_option));
      END IF;

      current_option := a.option_a;
      init_set_mask(v_bitpos_b.COUNT);
    END IF;

    set_mask(v_bitpos_b(a.option_b));
  END LOOP;

  --Need to repeat that for the last option.

  IF(NOT v_group_by_set_mask_a.EXISTS(v_mask))THEN init_group_mask_a(v_mask); END IF;
  set_group_mask_a(v_mask, v_bitpos_a(current_option));

  current_option := -1;

  FOR b IN (SELECT option_a, option_b FROM TABLE(v_options) ORDER BY option_b) LOOP

    IF(b.option_b <> current_option)THEN

      IF(current_option <> -1)THEN

        IF(NOT v_group_by_set_mask_b.EXISTS(v_mask))THEN init_group_mask_b(v_mask); END IF;
        set_group_mask_b(v_mask, v_bitpos_b(current_option));
      END IF;

      current_option := b.option_b;
      init_set_mask(v_bitpos_a.COUNT);
    END IF;

    set_mask(v_bitpos_a(b.option_a));
  END LOOP;

  --Need to repeat that for the last option.
nDebug := 8000015;
  IF(NOT v_group_by_set_mask_b.EXISTS(v_mask))THEN init_group_mask_b(v_mask); END IF;
  set_group_mask_b(v_mask, v_bitpos_b(current_option));

  --The tables of compatibility group masks hashed by compatibility set masks have been built
  --for both sides. Now we can use them to generate the relations.

  v_mask := v_group_by_set_mask_a.FIRST;

  WHILE(v_mask IS NOT NULL)LOOP

    v_group := v_group_by_set_mask_a(v_mask);
    v_rel := 'I';

    IF(a_min = 1 AND b_min = 1 AND
       v_group_by_set_mask_b.EXISTS(v_group) AND v_group_by_set_mask_b(v_group) = v_mask)THEN

      --This is A Implies B, B Implies A. A Requires relation will be generated between v_group and
      --v_mask and v_group_by_set_mask_b(v_group) will be deleted so that it will not be processed
      --by the cycle on the other side.

      v_rel := 'R';
      v_group_by_set_mask_b.DELETE(v_group);
    END IF;

    --Generate an Implies or Requires relation between AnyTrue(v_group) and AnyTrue(v_mask)

    vLogicLine := 'GS ' || v_rel || ' ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N '; PACK;

    FOR i IN 1..v_bitpos_a.COUNT LOOP
      IF(in_group(i))THEN
        vLogicLine := GENERATE_NAME(v_BackIndex(1), v_bitinv_a(i)) || ' '; PACK;
      END IF;
    END LOOP;

    vLogicLine := NewLine || 'GR N ' || b_object_name; PACK;
nDebug := 8000020;
    FOR i IN 1..v_bitpos_b.COUNT LOOP
      IF(in_mask(i))THEN
        vLogicLine := GENERATE_NAME(v_BackIndex(2), v_bitinv_b(i)) || ' '; PACK;
      END IF;
    END LOOP;

    vLogicLine := NewLine;
    PACK;
    v_mask := v_group_by_set_mask_a.NEXT(v_mask);
  END LOOP;

  v_mask := v_group_by_set_mask_b.FIRST;

  WHILE(v_mask IS NOT NULL)LOOP

    v_group := v_group_by_set_mask_b(v_mask);
    v_rel := 'I';

    IF(a_min = 1 AND b_min = 1 AND
       v_group_by_set_mask_a.EXISTS(v_group) AND v_group_by_set_mask_a(v_group) = v_mask)THEN

      --This is B Implies A, A Implies B. A Requires relation will be generated between v_group and
      --v_mask. We don't need to delete anything from the other side.

      v_rel := 'R';
    END IF;

    --Generate an Implies or Requires relation between AnyTrue(v_group) and AnyTrue(v_mask)

    vLogicLine := 'GS ' || v_rel || ' ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N '; PACK;
nDebug := 8000025;
    FOR i IN 1..v_bitpos_b.COUNT LOOP
      IF(in_group(i))THEN
        vLogicLine := GENERATE_NAME(v_BackIndex(2), v_bitinv_b(i)) || ' '; PACK;
      END IF;
    END LOOP;

    vLogicLine := NewLine || 'GR N ' || a_object_name; PACK;

    FOR i IN 1..v_bitpos_a.COUNT LOOP
      IF(in_mask(i))THEN
        vLogicLine := GENERATE_NAME(v_BackIndex(1), v_bitinv_a(i)) || ' '; PACK;
      END IF;
    END LOOP;

    vLogicLine := NewLine;
    PACK;
    v_mask := v_group_by_set_mask_b.NEXT(v_mask);
  END LOOP;

  -- The following block can be optimized by splitting into two (for a and b), and
  -- 1) using featOptionsCount table and compare it to v_bitpos_a(b).COUNT to find out if excludes
  --    are required instead of cycling through the feature options;
  -- 2) using v_bitpos_a(b) instead of v_OptionExists thus avoiding populating this table.

  v_OptionExists.DELETE;

  --Hash all the options of both features that are compatible. If an option is not in the hash,
  --exclude relation will be generated later.
nDebug := 8000030;
  FOR i IN 1..v_options.COUNT LOOP
    v_OptionExists(v_options(i).option_a) := 1;
    v_OptionExists(v_options(i).option_b) := 1;
  END LOOP;

  --Generate the exclude relations if necessary.
  --The code is re-written as part of the fix for the bug #4546828 to use the new hash table.

  FOR i IN 1..v_tFeatureId.COUNT LOOP

    ExcludesRequired := 0;
    nChild := h_OptionExplId(i).FIRST;
    nCounter := nChild;

    WHILE(nChild IS NOT NULL) LOOP
      IF(NOT v_OptionExists.EXISTS(nChild))THEN
         ExcludesRequired := 1;
         EXIT;
      END IF;
      nChild := h_OptionExplId(i).NEXT(nChild);
    END LOOP;

    IF(ExcludesRequired = 1)THEN

     nChild := nCounter;
nDebug := 8000040;
     vLogicLine := 'GS E ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N ';
     PACK;

     WHILE(nChild IS NOT NULL) LOOP
       IF(NOT v_OptionExists.EXISTS(nChild))THEN
         vLogicLine := GENERATE_NAME_EXPL(h_OptionExplId(i)(nChild), nChild) || ' ';
         PACK;
       END IF;
       nChild := h_OptionExplId(i).NEXT(nChild);
     END LOOP;

     vLogicLine := NewLine || 'GR L ';
     PACK;

     FOR n IN 1..v_tFeatureId.COUNT LOOP
       IF(n <> i)THEN
         vLogicLine := GENERATE_NAME(v_BackIndex(n), v_tFeatureId(n)) || ' ';
         PACK;
       END IF;
     END LOOP;

     vLogicLine := NewLine;
     PACK;
    END IF; --Excludes required
  END LOOP;
END GENERATE_OPTIMIZED_PBC;
---------------------------------------------------------------------------------------
BEGIN

  --High-level property-based compatibility rule validation section
  --Make sure the rule has at least 2 participant features

  IF(participantCount < 2)THEN
    RAISE CZ_R_COMPAT_SINGLE_FEATURE;
  END IF;

nDebug := 7005100;

  nChild := v_ChildrenIndex(v_tExprId(j));
  nCounter := 1;

  WHILE(v_tExprParentId(nChild) = v_tExprId(j)) LOOP
    IF(v_tExprType(nChild) = EXPR_ITERATOR)THEN

      iteratorIndex(nCounter) := nChild;
      featureIndex := v_ChildrenIndex(v_tExprId(nChild));

      v_tFeatureId(nCounter) := v_tExprPsNodeId(featureIndex);
      v_tExplId(nCounter) := v_tExplNodeId(featureIndex);
      v_BackIndex(nCounter) := featureIndex;

      nCounter := nCounter + 1;

    ELSIF(v_tExprType(nChild) = EXPR_WHERE)THEN

      whereIndex := nChild;
    END IF;

    nChild := nChild + 1;
  END LOOP;

nDebug := 7005101;

  FOR i IN 1..iteratorIndex.COUNT LOOP

    bind_node_id.DELETE;
    bind_values.DELETE;

    v_property_id.DELETE;
    v_data_type.DELETE;
    v_prop_name.DELETE;
    v_flag.DELETE;

    temp_cmpt_hash_key(compatLevel) := NULL;
    tableAlias := 'C' || TO_CHAR(i);

    iterator.DELETE;
    iterator := GENERATE_ITERATOR(iteratorIndex(i), ListType);

    IF(whereIndex <> 0)THEN
      EXPLORE_WHERE(whereIndex, v_tExprArgumentName(iteratorIndex(i)));
    END IF;

    IF(temp_cmpt_hash_key(compatLevel) IS NOT NULL)THEN
      FOR ii IN 1..v_property_id.COUNT LOOP
        temp_cmpt_hash_key(compatLevel) := temp_cmpt_hash_key(compatLevel) || '-' || TO_CHAR(v_property_id(ii));
      END LOOP;
    END IF;

nDebug := 7005102;

    IF(temp_cmpt_hash_key(compatLevel) IS NOT NULL AND temp_cmpt_table_hash.EXISTS(temp_cmpt_hash_key(compatLevel)))THEN

      tableName := temp_cmpt_table_hash(temp_cmpt_hash_key(compatLevel));
      arg_table_name(v_tExprArgumentName(iteratorIndex(i))) := tableAlias;

      IF(SQLSelect IS NULL)THEN SQLSelect := 'SELECT '; ELSE SQLSelect := SQLSelect || ', '; END IF;
      SQLSelect := SQLSelect || tableAlias || '.node_id';
      IF(SQLFrom IS NULL)THEN SQLFrom := ' FROM '; ELSE SQLFrom := SQLFrom || ', '; END IF;
      SQLFrom := SQLFrom || tableName || ' ' || tableAlias;

      FOR ii IN 1..iterator.COUNT LOOP
        h_OptionExplId(i)(iterator(ii).node_id) := iterator(ii).node_id_ex;
      END LOOP;
    ELSE

    tableName := 'G_' || TO_CHAR(table_name_generator);
    table_name_generator := table_name_generator + 1;
    arg_table_name(v_tExprArgumentName(iteratorIndex(i))) := tableAlias;

    IF(SQLSelect IS NULL)THEN SQLSelect := 'SELECT '; ELSE SQLSelect := SQLSelect || ', '; END IF;
    SQLSelect := SQLSelect || tableAlias || '.node_id';
    IF(SQLFrom IS NULL)THEN SQLFrom := ' FROM '; ELSE SQLFrom := SQLFrom || ', '; END IF;
    SQLFrom := SQLFrom || tableName || ' ' || tableAlias;

    SQLCreate := 'CREATE GLOBAL TEMPORARY TABLE ' || tableName || '(node_id NUMBER ';

    FOR ii IN 1..v_property_id.COUNT LOOP

      SQLCreate := SQLCreate || ', i_' || TO_CHAR(v_property_id(ii));

      IF(v_data_type(ii) IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

        SQLCreate := SQLCreate || ' NUMBER';
      ELSE

        SQLCreate := SQLCreate || ' VARCHAR2(' || TO_CHAR(MAXIMUM_INDEX_LENGTH) || ')';
      END IF;
    END LOOP;

    SQLCreate := SQLCreate || ') ON COMMIT PRESERVE ROWS';

nDebug := 7005103;

    BEGIN
      EXECUTE IMMEDIATE SQLCreate;
    EXCEPTION
      WHEN OTHERS THEN

        --If the table already exists, truncate it, drop and try to create again.

        IF(SQLCODE = ORACLE_OBJECT_ALREADY_EXISTS)THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || tableName;
          EXECUTE IMMEDIATE 'DROP TABLE ' || tableName;
          EXECUTE IMMEDIATE SQLCreate;
        ELSE
          RAISE;
        END IF;
    END;

    --The table is created, add its name to the delete list.

    temp_tables(temp_tables.COUNT + 1) := tableName;

nDebug := 7005104;

    SQLInsert := 'INSERT INTO ' || tableName || '(node_id';
    SQLValues := ' VALUES (:y1';

    FOR ii IN 1..v_property_id.COUNT LOOP

      BEGIN

        EXECUTE IMMEDIATE 'CREATE INDEX ' || tableName || '_I' || TO_CHAR(ii) || ' ON ' || tableName ||
                          '(i_' || v_property_id(ii) || ')';
      EXCEPTION
        WHEN OTHERS THEN
          IF(SQLCODE <> ORACLE_OBJECT_ALREADY_EXISTS)THEN RAISE; END IF;
      END;

      SQLInsert := SQLInsert || ', i_' || TO_CHAR(v_property_id(ii));
      SQLValues := SQLValues || ', :x' || TO_CHAR(ii);
    END LOOP;

    SQLInsert := SQLInsert || ')';
    SQLValues := SQLValues || ')';

nDebug := 7005105;

    FOR ii IN 1..iterator.COUNT LOOP

      bind_node_id(ii) := iterator(ii).node_id;

      IF(v_property_id.COUNT > 0)THEN

        --This is only valid if there are properties.

        IF(iterator(ii).node_id IS NULL)THEN RAISE CZ_R_TYPE_NO_PROPERTY; END IF;

        nodeId := glPsNodeId(glIndexByPsNodeId(iterator(ii).node_id));
        itemId := glItemId(glIndexByPsNodeId(iterator(ii).node_id));
      END IF;

      --Get the property values and insert the data.

nDebug := 7005106;

      FOR jj IN 1..v_property_id.COUNT LOOP

        propertyId := v_property_id(jj);
        hash_propval_key := TO_CHAR(nodeId) || '-' || TO_CHAR(itemId) || '-' ||
                            TO_CHAR(propertyId) || '-' || TO_CHAR(v_flag(propertyId));

        IF(NOT table_hash_propval.EXISTS(hash_propval_key))THEN

          IF(v_flag(propertyId) = 0)THEN

            --User property.

            propertyVal := NULL;
            localNumber := NULL;
            propertyVal := GET_PROPERTY_VALUE(nodeId, propertyId, itemId, localNumber);
          ELSE

            --System property.

            localNumber := 1;
            propertyVal := STATIC_SYSPROP_VALUE(nodeId, propertyId, v_flag(v_property_id(jj)));
          END IF;

          --Bug #3829438. Second and third columns of the cursor are not null, so localNumber can be NULL
          --only if no rows are fetched.

          IF(localNumber IS NOT NULL)THEN
            IF(v_data_type(jj) IN (DATATYPE_INTEGER, DATATYPE_FLOAT))THEN

              --If the property has numeric type, but the data is corrupted and the value
              --cannot be actually converted to a number, the generated SQL statement may
              --produce incomprehensive syntax errors, like 'too many columns'. To avoid
              --this verify the value.

              BEGIN
                typeCheck := TO_NUMBER(propertyVal);
              EXCEPTION
                WHEN OTHERS THEN
                  errorMessage := v_prop_name(jj);
                  localString := propertyVal;
                  RAISE CZ_R_INCORRECT_DATA_TYPE;
              END;
            ELSIF(LENGTH(propertyVal) > MAXIMUM_INDEX_LENGTH)THEN

               errorMessage := v_prop_name(jj);
               nParam := glIndexByPsNodeId(v_tFeatureId(i));
               auxIndex := glIndexByPsNodeId(iterator(ii).node_id);
               RAISE CZ_R_LONG_PROPERTY_VALUE;
            END IF;
          ELSE
            errorMessage := v_prop_name(jj);
            nParam := glIndexByPsNodeId(v_tFeatureId(i));
            auxIndex := glIndexByPsNodeId(iterator(ii).node_id);
            RAISE CZ_R_OPTION_NO_PROPERTY;
          END IF;

          bind_values(jj)(ii) := propertyVal;
          table_hash_propval(hash_propval_key) := propertyVal;
        ELSE
          bind_values(jj)(ii) := table_hash_propval(hash_propval_key);
        END IF;
      END LOOP;

      --Bug #4546828.
      --In a BOM model, options can really be references to other BOM models, therefore each option
      --can have its own explosion id, which should be used to generate correct logic name.
      --Hash the explosion id(s) here in a two-dimensional table (iterator, option_id).
      --Here we are supposed to hash all eligible options of the parent (the eligibility determined
      --by EXPAND_NODE inside the GENERATE_ITERATOR). For example, if a BOM model has BOM standard
      --items and a non-BOM feature, only the bom items are eligible. Therefore, this table will be
      --used later when generating exclusions.

      h_OptionExplId(i)(nodeId) := iterator(ii).node_id_ex;
    END LOOP;

nDebug := 7005107;

    v_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor, SQLInsert || SQLValues, DBMS_SQL.NATIVE);

    DBMS_SQL.BIND_ARRAY(v_cursor, ':y1', bind_node_id);

    FOR ii IN 1..v_property_id.COUNT LOOP
      DBMS_SQL.BIND_ARRAY(v_cursor, ':x' || TO_CHAR(ii), bind_values(ii));
    END LOOP;

    localNumber := DBMS_SQL.EXECUTE(v_cursor);
    DBMS_SQL.CLOSE_CURSOR(v_cursor);

    EXECUTE IMMEDIATE 'ANALYZE TABLE ' || tableName || ' COMPUTE STATISTICS';

    --The table is created and populated, add its name to the hash for re-use if it is eligible.

    IF(temp_cmpt_hash_key(compatLevel) IS NOT NULL)THEN temp_cmpt_table_hash(temp_cmpt_hash_key(compatLevel)) := tableName; END IF;
    END IF;
  END LOOP;

  --Generate the WHERE clause and run the query with bind variables. For every row returned,
  --generate the expression and return the object.
  --To do this, add GENERATE_ARGUMENT to the GENERATE_EXPRESSION.

nDebug := 7005108;

  IF(whereIndex <> 0)THEN
    SQLWhere := ' WHERE ' || EXAMINE_WHERE_CLAUSE(v_ChildrenIndex(v_tExprId(whereIndex)));
  END IF;

  IF(v_tFeatureId.COUNT = 2)THEN
    GENERATE_OPTIMIZED_PBC;
  ELSE

    GENERATE_STANDARD_PBC;
  END IF;

 RETURN v_return;
END;
---------------------------------------------------------------------------------------
--This function is introduced to support the level of embedding.

FUNCTION GENERATE_COMPATIBLE(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
  v_return  tStringArray;
BEGIN
  compatLevel := compatLevel + 1;
  v_return := GENERATE_COMPATIBLE_(j, ListType);
  compatLevel := compatLevel - 1;
 RETURN v_return;
EXCEPTION
  WHEN OTHERS THEN
    compatLevel := compatLevel - 1;
    RAISE;
END;
---------------------------------------------------------------------------------------
FUNCTION GENERATE_EXPRESSION(j IN PLS_INTEGER, ListType OUT NOCOPY PLS_INTEGER) RETURN tStringArray IS
 v_return  tStringArray;
 v_result  tIteratorArray;
BEGIN

  ListType := DATATYPE_GENERIC;

  IF(v_tExprType(j) = EXPR_NODE_TYPE_NODE)THEN

    IF(v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

      RETURN GENERATE_REFNODE(j, ListType);
    ELSE

      RETURN GENERATE_NODE(j);
    END IF;

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_FEATPROP)THEN

    RETURN GENERATE_PROPERTY(j);

  ELSIF(v_tExprType(j) = EXPR_PROP)THEN

    v_return(1) := PROPERTY_VALUE(j, glIndexByPsNodeId(v_tExprPsNodeId(j - 1)), ListType);

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_OPERATOR)THEN

    IF(v_tExprSubtype(j) IN (OPERATOR_ADD,
                             OPERATOR_SUB,
                             OPERATOR_MULT,
                             OPERATOR_DIV,
                             OPERATOR_ADD_INT,
                             OPERATOR_SUB_INT,
                             OPERATOR_MULT_INT))THEN
      RETURN GENERATE_ARITHMETIC(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_COS,
                                OPERATOR_ACOS,
                                OPERATOR_COSH,
                                OPERATOR_SIN,
                                OPERATOR_ASIN,
                                OPERATOR_SINH,
                                OPERATOR_TAN,
                                OPERATOR_ATAN,
                                OPERATOR_TANH,
                                OPERATOR_LOG,
                                OPERATOR_LOG10,
                                OPERATOR_EXP,
                                OPERATOR_ABS,
                                OPERATOR_SQRT))THEN
      RETURN GENERATE_MATH_UNARY(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_MATHDIV,
                                OPERATOR_POW,
                                OPERATOR_POW_INT,
                                OPERATOR_ATAN2,
                                OPERATOR_MOD))THEN
      RETURN GENERATE_MATH_BINARY(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_ROUNDTONEAREST,
                                OPERATOR_ROUNDUPTONEAREST,
                                OPERATOR_ROUNDDOWNTONEAREST))THEN
      RETURN GENERATE_MATH_ROUND(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_CEILING,
                                OPERATOR_FLOOR,
                                OPERATOR_ROUND,
                                OPERATOR_TRUNCATE))THEN
      RETURN GENERATE_ROUND(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_AND,
                                OPERATOR_OR))THEN
      RETURN GENERATE_ANDOR(j, ListType);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_ANYOF,
                                OPERATOR_ALLOF))THEN
      RETURN GENERATE_ANYALLOF(j, ListType);

    ELSIF(v_tExprSubtype(j) = OPERATOR_NOT)THEN
      RETURN GENERATE_NOT(j);

    ELSIF(v_tExprSubtype(j) = OPERATOR_NOTTRUE)THEN
      RETURN GENERATE_NOTTRUE(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_EQUALS,
                                OPERATOR_NOTEQUALS,
                                OPERATOR_GT,
                                OPERATOR_LT,
                                OPERATOR_GE,
                                OPERATOR_LE,
                                OPERATOR_EQUALS_INT,
                                OPERATOR_NOTEQUALS_INT,
                                OPERATOR_GT_INT,
                                OPERATOR_LT_INT,
                                OPERATOR_GE_INT,
                                OPERATOR_LE_INT,
                                OPERATOR_BEGINSWITH,
                                OPERATOR_ENDSWITH,
                                OPERATOR_CONTAINS,
                                OPERATOR_LIKE,
                                OPERATOR_MATCHES,
                                OPERATOR_DOESNOTBEGINWITH,
                                OPERATOR_DOESNOTENDWITH,
                                OPERATOR_DOESNOTCONTAIN,
                                OPERATOR_NOTLIKE))THEN
      RETURN GENERATE_COMPARE(j);

    ELSIF(v_tExprSubtype(j) = OPERATOR_CONCAT)THEN
      RETURN GENERATE_CONCAT(j, ListType);

    ELSIF(v_tExprSubtype(j) = OPERATOR_TOTEXT)THEN

      --Bug 5620750 - recognize and handle the new ToText operator when used outside of PBC
      --context.

      RETURN GENERATE_TOTEXT(j, ListType);

    ELSIF(v_tExprSubtype(j) = OPERATOR_OPTIONSOF)THEN
      RETURN GENERATE_OF(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_MIN,
                                OPERATOR_MAX))THEN
      RETURN GENERATE_MINMAX(j);

    ELSIF(v_tExprSubtype(j) IN (OPERATOR_VAL))THEN
      RETURN GENERATE_VAL(j);

    ELSIF(v_tExprSubtype(j) IN (RULE_OPERATOR_REQUIRES,
                                RULE_OPERATOR_IMPLIES,
                                RULE_OPERATOR_EXCLUDES,
                                RULE_OPERATOR_NEGATES,
                                RULE_OPERATOR_DEFAULTS))THEN
      RETURN GENERATE_LOGIC_TREE(j);

    ELSIF(v_tExprSubtype(j) IN (RULE_OPERATOR_CONTRIBUTES,
                                RULE_OPERATOR_CONSUMES))THEN
      RETURN GENERATE_NUMERIC_TREE(j);

    ELSE

      --This is not a built-in operator (primitive template), so generate it as a template application.
      --Right now there is no reason to report it as unknown.

      RETURN GENERATE_TEMPLATE_APPLICATION (j, ListType);

      --nParam := v_tExprSubtype(j);
      --RAISE CZ_E_UNKNOWN_OPERATOR_TYPE;
    END IF;

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_LITERAL)THEN

    RETURN GENERATE_LITERAL(j);

  ELSIF(v_tExprType(j) = EXPR_NODE_TYPE_CONSTANT)THEN

    RETURN GENERATE_CONSTANT(j);

  ELSIF(v_tExprType(j) IN (EXPR_FORALL, EXPR_FORALL_DISTINCT))THEN

    v_result := GENERATE_FORALL(j, ListType);

    FOR i IN 1..v_result.COUNT LOOP
         v_return(i) := v_result(i).node_obj;
	 IF(v_return(i) IS NULL AND v_result(i).node_id IS NOT NULL AND v_result(i).node_id_ex IS NOT NULL)THEN
		v_return(i) := GENERATE_NAME_EXPL(v_result(i).node_id_ex, v_result(i).node_id);
         END IF;
    END LOOP;

  ELSIF(v_tExprType(j) = EXPR_COMPATIBLE)THEN

    RETURN GENERATE_COMPATIBLE(j, ListType);

  ELSIF(v_tExprType(j) = EXPR_ARGUMENT)THEN

    IF(v_ChildrenIndex.EXISTS(v_tExprId(j)))THEN

      RETURN GENERATE_REFNODE(j, ListType);
    ELSE

      ListType := DATA_TYPE_VOID;
      RETURN GENERATE_ARGUMENT(j, ListType);
    END IF;

  ELSE

    RAISE CZ_E_UNKNOWN_EXPR_TYPE;
  END IF;
 RETURN v_return;
END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_COMPATIBILITY_TABLE IS
  v_tOptionId       tOptionId;
  v_OptionExists    tIntegerArray_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008
  v_RowLines        tStringArray;
  v_ItemLines       tStringArray;
  itemIndex         PLS_INTEGER;
  itemCount         PLS_INTEGER := 1;
  nChild            PLS_INTEGER;
  nCounter          PLS_INTEGER;
  ExcludesRequired  PLS_INTEGER;
  PrimaryCount      PLS_INTEGER;
  localString       VARCHAR2(25);
  localNumber       PLS_INTEGER;
BEGIN

nDebug := 5000001;

  FOR i IN 1..v_tExprPsNodeId.COUNT LOOP

    v_tOptionId.DELETE;
    v_OptionExists.DELETE;

nDebug := 5000002;

    SELECT secondary_opt_id BULK COLLECT INTO v_tOptionId
    FROM cz_des_chart_cells
    WHERE deleted_flag = FLAG_NOT_DELETED
      AND rule_id = nRuleId
      AND secondary_feature_id = v_tExprPsNodeId(i)
      AND secondary_feat_expl_id = v_tExplNodeId(i);

    IF(v_tOptionId.COUNT = 0)THEN
      RAISE CZ_R_EMPTY_COMPAT_RULE;
    ELSIF(i = 1)THEN
      PrimaryCount := v_tOptionId.COUNT;
    ELSE
      IF(v_tOptionId.COUNT <> PrimaryCount)THEN
        RAISE CZ_R_WRONG_COMPAT_TABLE;
      END IF;
    END IF;

nDebug := 5000003;

    FOR n IN 1..v_tOptionId.COUNT LOOP

      --Make sure the option exists

      IF(NOT glIndexByPsNodeId.EXISTS(v_tOptionId(n)))THEN
        RAISE CZ_R_INCORRECT_NODE_ID;
      END IF;

      IF(NOT v_OptionExists.EXISTS(v_tOptionId(n)))THEN

nDebug := 5000004;

       v_ItemLines(itemCount) := GENERATE_NAME(i, v_tOptionId(n)) || ' ' || TO_CHAR(i - 1);
       v_OptionExists(v_tOptionId(n)) := itemCount;
       itemCount := itemCount + 1;

      END IF;

nDebug := 5000005;

      itemIndex := v_OptionExists(v_tOptionId(n));

      IF(v_RowLines.EXISTS(n))THEN
        v_RowLines(n) := v_RowLines(n) || ' ' || TO_CHAR(itemIndex - 1);
      ELSE
        v_RowLines(n) := ' ' || TO_CHAR(itemIndex - 1);
      END IF;

    END LOOP;

nDebug := 5000006;

    nChild := glIndexByPsNodeId(v_tExprPsNodeId(i)) + 1;
    nCounter := nChild;
    ExcludesRequired := 0;

nDebug := 5000007;

    WHILE(glParentId.EXISTS(nChild) AND glParentId(nChild) = v_tExprPsNodeId(i))LOOP
     IF(NOT v_OptionExists.EXISTS(glPsNodeId(nChild)))THEN
       ExcludesRequired := 1;
       EXIT;
     END IF;
     nChild := nChild + 1;
    END LOOP;

nDebug := 5000008;

    IF(ExcludesRequired = 1)THEN

     nChild := nCounter;

     vLogicLine := 'GS E ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N ';
     PACK;

     WHILE(glParentId.EXISTS(nChild) AND glParentId(nChild) = v_tExprPsNodeId(i))LOOP
      IF(NOT v_OptionExists.EXISTS(glPsNodeId(nChild)))THEN
        vLogicLine := GENERATE_NAME(i, glPsNodeId(nChild)) || ' ';
        PACK;
      END IF;
      nChild := nChild + 1;
     END LOOP;

nDebug := 5000009;

     vLogicLine := NewLine || 'GR L ';
     PACK;

     FOR n IN 1..v_tExprPsNodeId.COUNT LOOP
       IF(n <> i)THEN
         vLogicLine := GENERATE_NAME(n, v_tExprPsNodeId(n)) || ' ';
         PACK;
       END IF;
     END LOOP;

nDebug := 5000010;

     vLogicLine := NewLine;
     PACK;
    END IF; --Excludes required
  END LOOP;

nDebug := 5000011;

  vLogicLine := 'OBJECT P_R' || TO_CHAR(nRuleId) || NewLine ||
                'COMBO P_R' || TO_CHAR(nRuleId) || ' ' || TO_CHAR(v_ItemLines.COUNT) || ' ' ||
                TO_CHAR(v_RowLines.COUNT) || ' ' || TO_CHAR(v_tExprPsNodeId.COUNT) || ' ... ' ||
                TO_CHAR(nReasonId) || NewLine;
  PACK;

nDebug := 5000012;

  FOR i IN 1..v_ItemLines.COUNT LOOP

    vLogicLine := 'CI ' || TO_CHAR(i - 1) || ' ' || v_ItemLines(i) || NewLine;
    PACK;

  END LOOP;

nDebug := 5000013;

  FOR i IN 1..v_tExprPsNodeId.COUNT LOOP

    IF(GenerateGatedCombo = 0)THEN

      --Use intermediate variable instead of using NVL because this is faster

      localNumber := glIndexByPsNodeId(v_tExprPsNodeId(i));
      localString := TO_CHAR(glMaximum(localNumber));

      --If it's a BOM item, we use maximum_selected instead of maximum

      IF(glPsNodeType(localNumber) IN (PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTIONCLASS,PS_NODE_TYPE_BOM_STANDARD))THEN
       localString := TO_CHAR(glMaximumSel(localNumber));
      END IF;

      IF(localString IS NULL)THEN localString := '-1'; END IF;
      vLogicLine := ' O';
    ELSE

      --Generate gated combinations: maximum is always -1, the 'G' argument is followed
      --by the feature name.

      localString := '-1';
      vLogicLine := ' G ' || GENERATE_NAME(i, v_tExprPsNodeId(i));
    END IF;

    vLogicLine := 'CC ' || TO_CHAR(i - 1) || ' 0 ' || localString || vLogicLine || NewLine;
    PACK;

  END LOOP;

nDebug := 5000014;

  FOR i IN 1..v_RowLines.COUNT LOOP

    vLogicLine := 'CR ' || TO_CHAR(i - 1) || v_RowLines(i) || NewLine;
    PACK;

  END LOOP;

nDebug := 5000015;

  vLogicLine := 'COMBO_END' || NewLine;
  PACK;

END;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_DESIGNCHART_RULE IS
  vGridColumns      tPsNodeId;
  vBackIndex        tIntegerArray;
  nIndex            PLS_INTEGER;
---------------------------------------------------------------------------------------
PROCEDURE GENERATE_COMPAT_TEMPLATE(inSuffix IN PLS_INTEGER) IS
  v_tOptionId         tOptionId;
  v_tPrimaryOptId     tOptionId;
  v_tPrimaryId        tOptionId;
  v_OptionExists      tIntegerArray_idx_vc2; --kdande; Bug 6881902; 11-Mar-2008
  v_OptionsUsed       tIntegerArray;
  v_StartOptionsUsed  tIntegerArray;
  v_EndOptionsUsed    tIntegerArray;
  v_ExcludesRequired  tIntegerArray;
  v_RowLinesIndex     tIntegerArray;
  v_RowLines          tStringArray;
  v_tailRowLines      tStringArray;
  v_ItemLines         tStringArray;
  itemIndex           PLS_INTEGER;
  itemCount           PLS_INTEGER := 1;
  startCount          PLS_INTEGER;
  nChild              PLS_INTEGER;
  localString         VARCHAR2(25);
  localNumber         PLS_INTEGER;
---------------------------------------------------------------------------------------
FUNCTION OPTION_EXISTS(nIndex IN PLS_INTEGER) RETURN PLS_INTEGER IS
BEGIN
  FOR j IN v_StartOptionsUsed(nIndex)..v_EndOptionsUsed(nIndex) LOOP
   IF(v_OptionsUsed(j) = glPsNodeId(nChild))THEN RETURN 1; END IF;
  END LOOP;
 RETURN 0;
END;
---------------------------------------------------------------------------------------
--This procedure implements a version of QuickSort algorythm which sorts not the array
--itself, but the array of pointers instead

PROCEDURE SORT_ARRAY_INDEX(indexStart IN PLS_INTEGER, indexEnd IN PLS_INTEGER) IS
  localStart  PLS_INTEGER;
  localEnd    PLS_INTEGER;
  localSwap   PLS_INTEGER;
  RowLine     VARCHAR2(4000);
BEGIN

  IF(indexStart >= indexEnd)THEN RETURN; END IF;

  localStart := indexStart;
  localEnd := indexEnd;
  RowLine := v_tailRowLines(v_RowLinesIndex((localStart + localEnd) / 2));

  WHILE(localStart < localEnd)LOOP

    WHILE(localStart < localEnd AND v_tailRowLines(v_RowLinesIndex(localStart)) < RowLine) LOOP
      localStart := localStart + 1;
    END LOOP;

    WHILE(localStart < localEnd AND v_tailRowLines(v_RowLinesIndex(localEnd)) > RowLine) LOOP
      localEnd := localEnd - 1;
    END LOOP;

    IF(localStart < localEnd)THEN
      localSwap := v_RowLinesIndex(localStart);
      v_RowLinesIndex(localStart) := v_RowLinesIndex(localEnd);
      v_RowLinesIndex(localEnd) := localSwap;
    END IF;

    localStart := localStart + 1;
    localEnd := localEnd - 1;

  END LOOP;

  IF(localEnd < localStart)THEN
    localSwap := localEnd;
    localEnd := localStart;
    localStart := localSwap;
  END IF;

  SORT_ARRAY_INDEX(indexStart, localStart);
  IF(localStart = indexStart)THEN localStart := localStart + 1; END IF;
  SORT_ARRAY_INDEX(localStart, indexEnd);
END;
---------------------------------------------------------------------------------------
BEGIN

nDebug := 5000200;

  FOR i IN 1..vGridColumns.COUNT LOOP --Validation and initial data for features

nDebug := 5000201;

    IF(i = 1)THEN

      --Read the list of participating options of the primary feature. Make a copy of the list
      --for the rule verification purposes (bug #2257421).

       SELECT primary_opt_id, primary_opt_id BULK COLLECT INTO v_tOptionId, v_tPrimaryOptId
       FROM cz_des_chart_cells
       WHERE rule_id = nRuleId
         AND secondary_feature_id = vGridColumns(2)
         AND secondary_feat_expl_id = v_tExplNodeId(vBackIndex(2))
         AND deleted_flag = FLAG_NOT_DELETED
       ORDER BY 1, 2;

       IF(v_tOptionId.COUNT = 0)THEN

       --The previous query returned no rows. That means that there're no selections made for
       --any of the primary feature options. It's OK if we are processing an optional table,
       --but for the defining table we raise an exception.

         IF(inSuffix = 0)THEN --we are processing the defining table
           RAISE CZ_R_NO_DEFINING_SELECTION;
         END IF;

       --This is an optional table with no selections - don't generate the COMBO, just generate
       --an EXCLUDE relation and exit the procedure.

         vLogicLine := 'GS E ... ' || TO_CHAR(nReasonId) || NewLine ||
                       'GL N ' || GENERATE_NAME(vBackIndex(1), vGridColumns(1)) || NewLine ||
                       'GR L ' || GENERATE_NAME(vBackIndex(2), vGridColumns(2)) || NewLine;
         PACK;
         RETURN;

       END IF;

    ELSE

nDebug := 5000202;

      v_tOptionId.DELETE;
      v_tPrimaryId.DELETE;
      v_OptionExists.DELETE;

      --Read the list of participating options of defining or optional feature.

      SELECT secondary_opt_id, primary_opt_id BULK COLLECT INTO v_tOptionId, v_tPrimaryId
      FROM cz_des_chart_cells
      WHERE rule_id = nRuleId
        AND secondary_feature_id = vGridColumns(i)
        AND secondary_feat_expl_id = v_tExplNodeId(vBackIndex(i))
        AND deleted_flag = FLAG_NOT_DELETED
      ORDER BY primary_opt_id;

      FOR n IN 1..v_tOptionId.COUNT LOOP

        IF(NOT glIndexByPsNodeId.EXISTS(v_tPrimaryId(n)))THEN

          BEGIN
            SELECT name INTO errorMessage FROM cz_ps_nodes
             WHERE ps_node_id = v_tPrimaryId(n);
          EXCEPTION
            WHEN OTHERS THEN
              errorMessage := 'Unknown';
          END;

          RAISE CZ_R_DELETED_OPTION;
        END IF;

        --Bug #2257421. The list of corresponding primary options which participate in the rule should be
        --equal for all defining features.
        --v_tPrimaryOptId - the ordered list of primary options checked for the first defining feature.
        --v_tPrimaryId - the ordered list of primary options checked for the current feature.

        IF((NOT v_tPrimaryOptId.EXISTS(n)) OR (v_tPrimaryOptId(n) > v_tPrimaryId(n)))THEN

           --Too many selections made.

           auxCount := glIndexByPsNodeId(vGridColumns(1));
           auxIndex := glIndexByPsNodeId(v_tPrimaryId(n));
           RAISE CZ_R_INCOMPLETE_DES_CHART;

        ELSIF(v_tPrimaryOptId(n) < v_tPrimaryId(n))THEN

           --Too few selections made.

           auxCount := glIndexByPsNodeId(vGridColumns(1));
           auxIndex := glIndexByPsNodeId(v_tPrimaryOptId(n));
           RAISE CZ_R_INCOMPLETE_DES_CHART;
        END IF;
      END LOOP;

      IF(v_tPrimaryOptId.EXISTS(v_tOptionId.COUNT + 1))THEN

           --Too few selections made.

           auxCount := glIndexByPsNodeId(vGridColumns(1));
           auxIndex := glIndexByPsNodeId(v_tPrimaryOptId(v_tOptionId.COUNT + 1));
           RAISE CZ_R_INCOMPLETE_DES_CHART;
      END IF;
    END IF;

    startCount := itemCount;

    FOR n IN 1..v_tOptionId.COUNT LOOP

      --Make sure the option exists.

      IF(NOT glIndexByPsNodeId.EXISTS(v_tOptionId(n)))THEN

        BEGIN
          SELECT name INTO errorMessage FROM cz_ps_nodes
           WHERE ps_node_id = v_tOptionId(n);
        EXCEPTION
          WHEN OTHERS THEN
            errorMessage := 'Unknown';
        END;

        RAISE CZ_R_DELETED_OPTION;
      END IF;

      IF(NOT v_OptionExists.EXISTS(v_tOptionId(n)))THEN

nDebug := 5000203;

       v_ItemLines(itemCount) := GENERATE_NAME(vBackIndex(i), v_tOptionId(n)) || ' ' || TO_CHAR(i - 1);
       v_OptionsUsed(itemCount) := v_tOptionId(n);
       v_OptionExists(v_tOptionId(n)) := itemCount;
       itemCount := itemCount + 1;

      END IF;

nDebug := 5000204;

      itemIndex := v_OptionExists(v_tOptionId(n));
      v_RowLinesIndex(n) := n;

      IF(v_RowLines.EXISTS(n))THEN
        v_RowLines(n) := v_RowLines(n) || ' ' || TO_CHAR(itemIndex - 1);
      ELSE
        v_RowLines(n) := ' ' || TO_CHAR(itemIndex - 1);
      END IF;

    END LOOP;

    v_ExcludesRequired(i) := 0;

nDebug := 5000205;

    IF(featOptionsCount(vGridColumns(i)) <> itemCount - startCount)THEN

      v_StartOptionsUsed(i) := startCount;
      v_EndOptionsUsed(i) := itemCount - 1;
      v_ExcludesRequired(i) := 1;

    END IF;
  END LOOP; --Validation and initial data for features

  --Design chart rule specific validation - uniqueness of every column in the chart table.
  --At the current step this requirement is equivalent to the requirement of no duplicate
  --elements in v_RowLines table. We use the modified QuickSort algorythm to sort out the
  --table and then check for duplicate values in one pass.

  IF(inSuffix = 0)THEN --This is the defining table

   --We need a substring of the row starting with the 4th character

   FOR i IN 1..v_RowLines.COUNT LOOP
    v_tailRowLines(i) := SUBSTR(v_RowLines(i),4);
   END LOOP;

   SORT_ARRAY_INDEX(1, v_tailRowLines.COUNT);
   FOR i IN 2..v_tailRowLines.COUNT LOOP
    IF(v_tailRowLines(v_RowLinesIndex(i)) = v_tailRowLines(v_RowLinesIndex(i - 1)))THEN

      --Duplicate combination of defining options for a primary option
      RAISE CZ_R_DUPLICATE_COMBINATION;

    END IF;
   END LOOP;
  END IF; --This is the defining table

nDebug := 5000206;

  FOR i IN 1..vGridColumns.COUNT LOOP

nDebug := 5000207;

    IF(v_ExcludesRequired(i) = 1)THEN

     nChild := glIndexByPsNodeId(vGridColumns(i)) + 1;

     vLogicLine := 'GS E ... ' || TO_CHAR(nReasonId) || NewLine || 'GL N ';
     PACK;

nDebug := 5000208;

     WHILE(glParentId.EXISTS(nChild) AND glParentId(nChild) = vGridColumns(i))LOOP
      IF(OPTION_EXISTS(i) = 0)THEN
        vLogicLine := GENERATE_NAME(vBackIndex(i), glPsNodeId(nChild)) || ' ';
        PACK;
      END IF;
      nChild := nChild + 1;
     END LOOP;

     vLogicLine := NewLine || 'GR L ';
     PACK;

nDebug := 5000209;

     FOR n IN 1..vGridColumns.COUNT LOOP
       IF(n <> i)THEN
         vLogicLine := GENERATE_NAME(vBackIndex(n), vGridColumns(n)) || ' ';
         PACK;
       END IF;
     END LOOP;

     vLogicLine := NewLine;
     PACK;
    END IF; --Excludes required
  END LOOP;

nDebug := 5000210;

  vLogicLine := 'OBJECT P_R' || TO_CHAR(nRuleId) || '_' || TO_CHAR(inSuffix) || NewLine ||
                'COMBO P_R' || TO_CHAR(nRuleId) || '_' || TO_CHAR(inSuffix) || ' ' || TO_CHAR(v_ItemLines.COUNT) || ' ' ||
                TO_CHAR(v_RowLines.COUNT) || ' ' || TO_CHAR(vGridColumns.COUNT) || ' ... ' ||
                TO_CHAR(nReasonId) || NewLine;
  PACK;

nDebug := 5000211;

  FOR i IN 1..v_ItemLines.COUNT LOOP

    vLogicLine := 'CI ' || TO_CHAR(i - 1) || ' ' || v_ItemLines(i) || NewLine;
    PACK;

  END LOOP;

nDebug := 5000212;

  FOR i IN 1..vGridColumns.COUNT LOOP

    IF(GenerateGatedCombo = 0)THEN

      IF(inSuffix = 0 OR i = 1)THEN

        --This is the defining table or the primary feature in an optional table.
        --In this case we currently use actual feature's maximum value for the column
        --(or maximum_selected for BOM).

        --Use intermediate variable instead of using NVL because this is faster

        localNumber := glIndexByPsNodeId(vGridColumns(i));
        localString := TO_CHAR(glMaximum(localNumber));

        --If it's a BOM item, we use maximum_selected instead of maximum

        IF(glPsNodeType(localNumber) IN (PS_NODE_TYPE_BOM_MODEL,PS_NODE_TYPE_BOM_OPTIONCLASS,PS_NODE_TYPE_BOM_STANDARD))THEN
         localString := TO_CHAR(glMaximumSel(localNumber));
        END IF;

        IF(localString IS NULL)THEN localString := '-1'; END IF;

      ELSE
        --For optional features in optional tables we always use '-1' for columns' maximum value.

        localString := '-1';
      END IF;

      vLogicLine := ' O';
    ELSE

      --Generate gated combinations: maximum is always -1, the 'G' argument is followed
      --by the feature name.

      localString := '-1';
      vLogicLine := ' G ' || GENERATE_NAME(vBackIndex(i), vGridColumns(i));
    END IF;

    vLogicLine := 'CC ' || TO_CHAR(i - 1) || ' 0 ' || localString || vLogicLine || NewLine;
    PACK;

  END LOOP;

nDebug := 5000213;

  FOR i IN 1..v_RowLines.COUNT LOOP

    vLogicLine := 'CR ' || TO_CHAR(i - 1) || v_RowLines(i) || NewLine;
    PACK;

  END LOOP;

nDebug := 5000214;

  vLogicLine := 'COMBO_END' || NewLine;
  PACK;
END;
---------------------------------------------------------------------------------------
BEGIN

  --Generate the defining table

  nIndex := 2;

  FOR i IN expressionStart..expressionEnd LOOP

    IF(v_tFeatureType(i) = FEATURE_TYPE_DEFINING)THEN
      vGridColumns(nIndex) := v_tExprPsNodeId(i);
      vBackIndex(nIndex) := i;
      nIndex := nIndex + 1;
    ELSIF(v_tFeatureType(i) = FEATURE_TYPE_PRIMARY)THEN
      vGridColumns(1) := v_tExprPsNodeId(i);
      vBackIndex(1) := i;
    END IF;

  END LOOP;

  IF(vGridColumns.COUNT = 0)THEN
    RAISE CZ_R_NO_PRIMARY_FEATURE;
  ELSIF(vGridColumns.COUNT > 1)THEN
    GENERATE_COMPAT_TEMPLATE(0);
    vGridColumns.DELETE(2, vGridColumns.COUNT);
    vBackIndex.DELETE(2, vBackIndex.COUNT);
  END IF;

  --Generate all the optional tables

  nIndex := 1;

  FOR i IN expressionStart..expressionEnd LOOP

    IF(v_tFeatureType(i) = FEATURE_TYPE_OPTIONAL)THEN
      vGridColumns(2) := v_tExprPsNodeId(i);
      vBackIndex(2) := i;
      GENERATE_COMPAT_TEMPLATE(nIndex);
      nIndex := nIndex + 1;
    END IF;

  END LOOP;
END;
---------------------------------------------------------------------------------------
BEGIN --GENERATE_RULES

nDebug := 0;

  IF(t_RuleId.COUNT = 0)THEN

    --This should be done only once during the generation session. The data is static and common
    --to all models.

    SELECT rule_id, signature_id, name BULK COLLECT INTO t_RuleId, t_SignatureId, t_RuleName
      FROM cz_rules
     WHERE devl_project_id = 0
       AND seeded_flag = FLAG_SEEDED
       AND deleted_flag = FLAG_NOT_DELETED
       AND disabled_flag = FLAG_NOT_DISABLED;

    --Make the table of names hashed by rule_id.

    FOR i IN 1..t_RuleId.COUNT LOOP

      h_SeededName(t_RuleId(i)) := UPPER(t_RuleName(i));
      h_ReportName(t_RuleId(i)) := t_RuleName(i);
      h_SignatureId(t_RuleId(i)) := t_SignatureId(i);
    END LOOP;
  END IF;

nDebug := 1;

  --Make a quick and simple verification of all functional companions defined in this
  --project. All other rule related instances that do not reside in cz_rules can also
  --be processed in this section.
  --Added as a fix for the bug #2200481.

  --Restoring this block in 11.5.10+, bug #3989382.

  FOR c_func IN (SELECT component_id, model_ref_expl_id, program_string, name, rule_folder_id
                   FROM cz_func_comp_specs
                  WHERE devl_project_id = inComponentId
                    AND deleted_flag = FLAG_NOT_DELETED) LOOP

    IF(c_func.component_id IS NULL)THEN

      --'Incomplete data: No base component specified for functional companion ''%COMPANION'' in model ''%MODELNAME''.'
      REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_FC_BASE_COMPONENT', 'COMPANION', COMPANION_NAME(c_func.name, c_func.rule_folder_id), 'MODELNAME', glName(glIndexByPsNodeId(inComponentId))), 1);

    ELSIF(c_func.program_string IS NULL)THEN

      --'Incomplete data: No program string specified for functional companion ''%COMPANION'' in model ''%MODELNAME''.'
      REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_FC_PROGRAM_STRING', 'COMPANION', COMPANION_NAME(c_func.name, c_func.rule_folder_id), 'MODELNAME', glName(glIndexByPsNodeId(inComponentId))), 1);

    ELSIF(NOT glIndexByPsNodeId.EXISTS(c_func.component_id))THEN

      --'Internal data error. Incorrect product structure data for functional companion ''%COMPANION'' in model ''%MODELNAME''.'
      REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_COMPONENT', 'COMPANION', COMPANION_NAME(c_func.name, c_func.rule_folder_id), 'MODELNAME', glName(glIndexByPsNodeId(inComponentId))), 1);

    ELSIF(c_func.model_ref_expl_id IS NULL OR (NOT v_IndexByNodeId.EXISTS(c_func.model_ref_expl_id)))THEN

      --'Internal data error. Incorrect explosion data for functional companion ''%COMPANION'' in model ''%MODELNAME''.'
      REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_EXPLOSION', 'COMPANION', COMPANION_NAME(c_func.name, c_func.rule_folder_id), 'MODELNAME', glName(glIndexByPsNodeId(inComponentId))), 1);
    END IF;
  END LOOP;

  --Calculate downpathes for all explosion nodes here

nDebug := 1000007;

  FOR i IN 1..v_NodeId.COUNT LOOP

nDebug := 1000002;

   --Unconditionally create rule files for all the non-virtual components of the
   --model primary structure and all first-level reference nodes and put the INC
   --relation there.

    IF(v_tVirtualFlag(i) = FLAG_NON_VIRTUAL AND v_tNodeDepth(i) > 0 AND
       (v_tChildModelExpl(i) IS NULL OR
        (v_tNodeType(i) = PS_NODE_TYPE_REFERENCE AND
         v_tChildModelExpl(v_IndexByNodeId(v_tParentId(i))) IS NULL)
       ))THEN

nDebug := 1000003;

     nHeaderId := next_lce_header_id;

     BEGIN

nDebug := 1000004;

      --Insert the rule net logic header record into the table.

      INSERT INTO cz_lce_headers
       (lce_header_id, gen_version, gen_header, component_id, net_type,
        devl_project_id, model_ref_expl_id, nbr_required_expls, deleted_flag)
      VALUES
       (nHeaderId, VersionString, GenHeader, v_tPsNodeId(i), LOGIC_NET_TYPE_MANDATORY,
        thisProjectId, v_NodeId(i), 1, FLAG_PENDING);

      INSERT INTO cz_lce_load_specs
       (attachment_expl_id, lce_header_id, required_expl_id, attachment_comp_id,
        model_id, net_type, deleted_flag)
      VALUES
       (v_NodeId(i), nHeaderId, v_NodeId(i), v_tPsNodeId(i), thisProjectId,
        LOGIC_NET_TYPE_MANDATORY, FLAG_PENDING);

      EXCEPTION
        WHEN OTHERS THEN
          errorMessage := SQLERRM;
          RAISE CZ_R_UNABLE_TO_CREATE_HEADER;
      END;

nDebug := 1000005;

      NewHeaders(counterNewHeaders) := nHeaderId;
      NewHeadersComponents(counterNewHeaders) := v_tPsNodeId(i);
      NewHeadersExplosions(counterNewHeaders) := v_NodeId(i);
      counterNewHeaders := counterNewHeaders + 1;

nDebug := 1000006;

      --Use intermediate variable instead of using NVL because this is faster

      IF(v_tReferringId(i) IS NOT NULL)THEN
       localString := TO_CHAR(glPersistentId(v_tReferringId(i)));
      ELSE
       localString := TO_CHAR(glPersistentId(v_tPsNodeId(i)));
      END IF;

      vLogicLine := 'CONTROL NOSPEC' || NewLine || 'VERSION 3 3' || NewLine || NewLine ||
                    'REM -- Rules file for component: ' || TO_CHAR(v_tPsNodeId(i)) ||
                    ', explosion node: ' || TO_CHAR(v_NodeId(i)) || NewLine || NewLine ||
                    'EFF , , ' || NewLine || NewLine ||
                    'INC 1 ' || PATH_DELIMITER || 'parent' || PATH_DELIMITER || 'P_' ||
                    localString || '_ACTUALCOUNT round' || NewLine;

      INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES (nHeaderId, 1, vLogicLine);

      v_tIsHeaderGenerated(v_NodeId(i)) := nHeaderId;
      v_tSequenceNbr(nHeaderId) := 2;
      v_tLogicNetType(nHeaderId) := LOGIC_NET_TYPE_MANDATORY;

      --This variable is not supposed to be used as an accumulator for logic text. Instead,  it
      --is used as a buffer every time to store a piece of text to be accumulated in vLogicText
      --(see PACK procedure). Therefore, it should be safe to null it out here even if it's not
      --necessary.

      vLogicLine := NULL;
    END IF;

nDebug := 1000008;

    --Here we will construct model level downpaths, which do not depend on a particular rule,
    --but only on explosion id within the model's explosion tree. When a particular rule is
    --assigned, downpaths of its participants may be prepended with segments including all A
    --type nodes from assignee to assignable. This corrected downpaths are always used when
    --generating names of the rule's participants.

    nAux := v_NodeId(i);
    auxIndex := v_tNodeDepth(i) + 1;

    IF(NOT v_NodeDownPath.EXISTS(nAux))THEN

nDebug := 1000009;

      v_NodeDownPath(nAux) := ''; --start building the downpath
      v_NodeIndexPath.DELETE; --reset the table

      --These all are index values in v_NodeIndexPath.

      ConnectorIndex := 0;
      InstantiableIndex := auxIndex;
      OptionalIndex := auxIndex;
      TrackableIndex := auxIndex;
      nCounter := 1;
      auxCount := 0;

      --Go all the way up from the explosion id and find the deepest D node and the
      --shallowest connector, and also the deepest optional node.
      --We are interested in the shallowest reference to a trackable model as well.
      --It will be used only if the root model is marked as a network container. If
      --there is no such reference above the explosion node the root node is used.

      WHILE(nAux IS NOT NULL) LOOP

        localCount := v_IndexByNodeId(nAux);

        --Detect infinite loops which may be caused by data corruption.

        auxCount := auxCount + 1;
        IF(auxCount > LOOP_DETECTED_LOOPS_NUMBER)THEN

          errorMessage := glName(glIndexByPsNodeId(inProjectId));
          RAISE CZ_G_INVALID_MODEL_EXPLOSION;
        END IF;

        --The next IF statement has been added as a fix for the bug #2802049. In case of circular
        --connectors it is possible that the explosion table of the second level-referenced model
        --contains pointers to ps node structure of the parent model that hasn't been read yet.
        --As in this case we do not need to generate downpaths, we can just ignore such pointers.

        IF(NOT glIndexByPsNodeId.EXISTS(NVL(v_tReferringId(localCount), v_tPsNodeId(localCount))))THEN

          auxCount := -1;
          EXIT;
        END IF;

        IF(v_TypeByExplId(nAux) = EXPL_NODE_TYPE_CONNECTOR)THEN

          ConnectorIndex := nCounter;
        ELSIF(v_TypeByExplId(nAux) = EXPL_NODE_TYPE_OPTIONAL AND OptionalIndex = auxIndex)THEN

          OptionalIndex := nCounter;
        ELSIF(v_TypeByExplId(nAux) = EXPL_NODE_TYPE_INSTANTIABLE)THEN

          IF(InstantiableIndex = auxIndex)THEN InstantiableIndex := nCounter; END IF;

          IF(v_tNodeType(localCount) = PS_NODE_TYPE_REFERENCE AND
             glIbTrackable(v_tPsNodeId(localCount)) = FLAG_IB_TRACKABLE)THEN

             TrackableIndex := nCounter;
          END IF;
        END IF;

       v_NodeIndexPath(nCounter) := localCount;
       nCounter := nCounter + 1;

       nAux := v_tParentId(localCount);
      END LOOP;

      IF(auxCount = -1)THEN

        --This is the 'circular connectors' case, we don't need any downpath.
        NULL;

      ELSIF(InstantiableIndex < ConnectorIndex)THEN

        --There are D nodes under connectors on the path - this explosion cannot participate
        --in any rule because it would be impossible to assign such a rule. No downpath.
        --For reporting purposes store the cz_ps_nodes indexes of the instantiable component
        --and the connector, corresponding exception/message is CZ_R_UNASSIGNABLE_RULE.

        v_ProhibitInRules(v_NodeId(i)) := glIndexByPsNodeId(v_tPsNodeId(v_NodeIndexPath(InstantiableIndex)));
        v_ProhibitConnector(v_NodeId(i)) := glIndexByPsNodeId(v_tReferringId(v_NodeIndexPath(ConnectorIndex)));

      ELSIF(OptionalIndex < ConnectorIndex)THEN

        --There are A nodes under connectors on the path - this explosion cannot participate
        --in any rule - bug #2217450. No downpath.
        --For reporting purposes store the cz_ps_nodes indexes of the optional component
        --and the connector, corresponding exception/message is CZ_R_OPTIONAL_INSIDE.

        v_ProhibitOptional(v_NodeId(i)) := glIndexByPsNodeId(v_tPsNodeId(v_NodeIndexPath(OptionalIndex)));
        v_ProhibitConnector(v_NodeId(i)) := glIndexByPsNodeId(v_tReferringId(v_NodeIndexPath(ConnectorIndex)));

      ELSE

nDebug := 1000010;

        AssignableIndex := InstantiableIndex;

        --Find the deepest A node between the deepest D node and the shallowest connector.
        --This node is the assignable for the explosion id (can be the D node itself).

        FOR n IN ConnectorIndex + 1..InstantiableIndex LOOP
          IF(v_tExplNodeType(v_NodeIndexPath(n)) = EXPL_NODE_TYPE_OPTIONAL)THEN

            AssignableIndex := n;
            EXIT;
          END IF;
        END LOOP;

        v_NodeLogicLevel(v_NodeId(i)) := v_tNodeDepth(v_NodeIndexPath(AssignableIndex));

        --Store the main index of the assignable of the explosion node.

        v_NodeAssignable(v_NodeId(i)) := v_NodeIndexPath(AssignableIndex);

        --Store the main index of the deepest instantiable component above the explosion
        --node (may be the node itself if it is instantiable, or the root node if there
        --is no instantiable components on the way up from the explosion node).

        v_NodeInstantiable(v_NodeId(i)) := v_NodeIndexPath(InstantiableIndex);

        --Store the main index of the shallowest reference to a trackable model.

        v_NodeTrackable(v_NodeId(i)) := v_NodeIndexPath(TrackableIndex);

nDebug := 1000011;

        --Finally, construct the downpath from the assignable to the explosion id.

        FOR n IN 1..AssignableIndex - 1 LOOP
          IF(v_tExplNodeType(v_NodeIndexPath(n)) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_MANDATORY))THEN

           --This is a mandatory reference or optional component, add N_<persistent_node_id>
           --to the path.

           v_NodeDownPath(v_NodeId(i)) := PATH_DELIMITER || 'N_' ||
             TO_CHAR(glPersistentId(NVL(v_tReferringId(v_NodeIndexPath(n)), v_tPsNodeId(v_NodeIndexPath(n))))) ||
             v_NodeDownPath(v_NodeId(i));

          ELSIF(v_tExplNodeType(v_NodeIndexPath(n)) = EXPL_NODE_TYPE_CONNECTOR)THEN

           --This is a connector, add C_<model_ref_expl_id> to the path.

           v_NodeDownPath(v_NodeId(i)) := PATH_DELIMITER || 'C_' ||
             TO_CHAR(v_NodeId(v_NodeIndexPath(n))) || v_NodeDownPath(v_NodeId(i));

           --We will stop here, we do not want anything above the deepest connector to be reflected
           --in the path. Set a flag for this explosion because we do not want to prepend downpaths
           --for these explosions after the rule is assigned either. Actually, not just a flag, but
           --store the connector itself (main index) which may be useful for reporting purposes.

           v_IsConnectorNet(v_NodeId(i)) := v_NodeIndexPath(n);
           EXIT;
          END IF;
        END LOOP;
      END IF;
    END IF;
  END LOOP;

nDebug := 2;

  OPEN c_rules;
  LOOP
  BEGIN

    --To generate effectivity information for the first rule. Uses the fact that
    --effective mask can not be null.

    vUsageMask := NULL;

    FETCH c_rules INTO
     nRuleId, nRuleType, nAntecedentId, nConsequentId, vRuleName, nReasonId, nRuleOperator,
     nRuleFolderId, nComponentId, nModelRefExplId, dEffFrom, dEffUntil, vUsageMask,
     nRuleEffSetId, nUnsatisfiedId, nUnsatisfiedSource, nPresentationFlag, vClassName;
    EXIT WHEN c_rules%NOTFOUND;

   --Do nothing for those rules.

  --Fix for the bug6502787
    IF(nRuleEffSetId IS NOT NULL)THEN
          IF(gvIndexBySetId.EXISTS(nRuleEffSetId))THEN

       nDebug := 111111;
              dEffFrom := gvEffFrom(gvIndexBySetId(nRuleEffSetId));
              dEffUntil := gvEffUntil(gvIndexBySetId(nRuleEffSetId));
          ELSE
         --This is a fatal error - data corruption
               RAISE CZ_R_WRONG_EFFECTIVITY_SET;
          END IF;
    END IF;

   IF(nRuleType NOT IN (RULE_TYPE_FUNC_COMP, RULE_TYPE_RULE_FOLDER, RULE_TYPE_BINDING_RULE,
                        RULE_TYPE_RULE_SYS_PROP, RULE_TYPE_JAVA_SYS_PROP,
                        RULE_TYPE_CAPTION_RULE, RULE_TYPE_DISPLAY_CONDITION))THEN

    v_tExplNodeId.DELETE;
    v_tExprType.DELETE;
    v_tExprSubtype.DELETE;
    v_tExprId.DELETE;
    v_tExprParentId.DELETE;
    v_tExprTemplateId.DELETE;
    v_tExpressId.DELETE;
    v_tExprPsNodeId.DELETE;
    v_tRealPsNodeId.DELETE;
    v_tExprDataValue.DELETE;
    v_tExprPropertyId.DELETE;
    v_tConsequentFlag.DELETE;
    v_tExprParamIndex.DELETE;
    v_tExprArgumentName.DELETE;
    v_tExprDataType.DELETE;
    v_tExprDataNumValue.DELETE;
    v_tExprArgSignature.DELETE;
    v_tExprParSignature.DELETE;
    v_tArgumentIndex.DELETE;
    v_tDataType.DELETE;
    v_tArgumentName.DELETE;
    v_InstByLevel.DELETE;
    v_Assignable.DELETE;
    v_Participant.DELETE;
    v_DistinctIndex.DELETE;
    v_ParticipantIndex.DELETE;
    v_RuleConnectorNet.DELETE;
    v_LevelCount.DELETE;
    v_LevelIndex.DELETE;
    v_LevelType.DELETE;
    v_MarkLoadCondition.DELETE;
    v_LoadConditionId.DELETE;
    v_ChildrenIndex.DELETE;
    v_NodeUpPath.DELETE;
    v_IndexByExprNodeId.DELETE;
    v_NumberOfChildren.DELETE;
    v_ExplByPsNodeId.DELETE;
    v_RelativeNodePath.DELETE;
    parameterScope.DELETE;
    parameterName.DELETE;

    jAntecedentRoot  := NULL;
    jConsequentRoot  := NULL;
    sUnsatisfiedId   := NULL;
    RuleTemplateType := RULE_TYPE_UNKNOWN;
    numericLHS       := 0;
    generateCompare  := 0;
    t_prefix         := 'T' || TO_CHAR(nRuleId) || '_';

    --We need to reset the assigned down paths for every rule. Bug #3431166.

    FOR i IN 1..v_NodeId.COUNT LOOP

      --Make a copy that will be used as a rule-specific downpath which may have to be prepended
      --after the rule is assigned. It is this copy that will be used for name generation.

      v_AssignedDownPath(v_NodeId(i)) := v_NodeDownPath(v_NodeId(i));
    END LOOP;

    --Bug #3180819.

    IF(nPresentationFlag IS NULL)THEN nPresentationFlag := FLAG_FREEFORM_RULE; END IF;

nDebug := 3;

    --Get the rule participants, differently for different types of rules

    IF(nRuleType = RULE_TYPE_JAVA_METHOD)THEN

      --This is a CX. Call the CX validation procedure and continue with rules.

      localRunId := thisRunId;
      cz_developer_utils_pvt.verify_special_rule(nRuleId, vRuleName, localRunId);
      RAISE CZ_LCE_CONTINUE;

    ELSIF(nRuleType IN (RULE_TYPE_TEMPLATE, RULE_TYPE_EXPRESSION))THEN

      --Set the unsatisfied message id string.

      IF(nUnsatisfiedSource <> UNSATISFIED_TYPE_NONE)THEN

        sUnsatisfiedId := TO_CHAR(nUnsatisfiedId);
        IF(sUnsatisfiedId IS NOT NULL)THEN sUnsatisfiedId := sUnsatisfiedId || ' '; END IF;
      END IF;

      SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, template_id,
             express_id, expr_subtype, ps_node_id, data_value, property_id, consequent_flag,
             param_index, argument_name, data_type, data_num_value, param_signature_id,
             relative_node_path
      BULK COLLECT INTO v_tExplNodeId, v_tExprType, v_tExprId, v_tExprParentId, v_tExprTemplateId,
                        v_tExpressId, v_tExprSubtype, v_tExprPsNodeId, v_tExprDataValue,
                        v_tExprPropertyId, v_tConsequentFlag, v_tExprParamIndex, v_tExprArgumentName,
                        v_tExprDataType, v_tExprDataNumValue, v_tExprParSignature,
                        v_RelativeNodePath
       FROM cz_expression_nodes
      WHERE rule_id = nRuleId
        AND expr_type <> EXPR_NODE_TYPE_PUNCT
        AND deleted_flag = FLAG_NOT_DELETED
      ORDER BY expr_parent_id, seq_nbr;

     --Determine the size of the expression for all eventual purposes.

     expressionSize := v_tExprType.COUNT;

     IF(expressionSize = 0)THEN
       RAISE CZ_R_NO_PARTICIPANTS;
     END IF;

     expressionStart := 1;
     expressionEnd := expressionSize;

     FOR i IN expressionStart..expressionEnd LOOP

       IF(v_tExprDataNumValue(i) IS NOT NULL)THEN v_tExprDataValue(i) := TO_CHAR(v_tExprDataNumValue(i)); END IF;

       --Bug #3800352. Resolve the codes by names and emulate regular node types.

       IF(v_tExprType(i) IN (EXPR_PROPERTYBYNAME, EXPR_OPERATORBYNAME, EXPR_JAVAPROPERTYBYNAME))THEN

         FOR n IN 1..t_RuleId.COUNT LOOP

           IF(t_RuleName(n) = v_tExprArgumentName(i))THEN v_tExprTemplateId(i) := t_RuleId(n); EXIT; END IF;
         END LOOP;

         IF(v_tExprType(i) = EXPR_PROPERTYBYNAME)THEN

           v_tExprType(i) := EXPR_SYS_PROP;
         ELSIF(v_tExprType(i) = EXPR_OPERATORBYNAME)THEN

           v_tExprType(i) := EXPR_OPERATOR;
         ELSIF(v_tExprType(i) = EXPR_JAVAPROPERTYBYNAME)THEN

           v_tExprType(i) := EXPR_JAVA_PROPERTY;
         END IF;
       END IF;

       --Populate the expression node subtype from template_id for all expression nodes for backward
       --compatibility.

       v_tExprSubtype(i) := v_tExprTemplateId(i);

       --Use the code lookup to fix irregularities in new codes. May become unnecessary when real
       --metadata lookup is implemented.

       IF(CodeByCodeLookup.EXISTS(v_tExprTemplateId(i)))THEN

         v_tExprSubtype(i) := CodeByCodeLookup(v_tExprTemplateId(i));
         v_tExprTemplateId(i) := v_tExprSubtype(i);
       END IF;

       IF(v_tExprParentId(i) IS NOT NULL)THEN

         IF(v_NumberOfChildren.EXISTS(v_tExprParentId(i)))THEN
           v_NumberOfChildren(v_tExprParentId(i)) := v_NumberOfChildren(v_tExprParentId(i)) + 1;
         ELSE
           v_NumberOfChildren(v_tExprParentId(i)) := 1;
         END IF;

         IF(NOT v_ChildrenIndex.EXISTS(v_tExprParentId(i)))THEN
           v_ChildrenIndex(v_tExprParentId(i)) := i;
         END IF;
       END IF;

       --If this rule is against max of some component, mark this component as having such a rule.
       --Later we will generate INC for this component's actual max.

       IF(v_tExprType(i) = EXPR_SYS_PROP AND h_SeededName.EXISTS(v_tExprSubtype(i)) AND
          h_SeededName(v_tExprSubtype(i)) = RULE_SYS_PROP_MAXINSTANCE AND
          v_tConsequentFlag(i) = FLAG_IS_CONSEQUENT)THEN

          v_MaxRuleExists(v_tExplNodeId(i)) := 1;
       END IF;

       --Add the indexing option.

       v_IndexByExprNodeId(v_tExprId(i)) := i;
     END LOOP;

    ELSIF(nRuleType = RULE_TYPE_COMPAT_TABLE)THEN

     --Read all the features

     SELECT model_ref_expl_id, feature_id, EXPR_NODE_TYPE_NODE
     BULK COLLECT INTO v_tExplNodeId, v_tExprPsNodeId, v_tExprType
     FROM cz_des_chart_features
     WHERE rule_id = nRuleId
       AND deleted_flag = FLAG_NOT_DELETED;

nDebug := 32;

     --Determine the size of the expression for all eventual purposes.

     expressionSize := v_tExprType.COUNT;

     IF(expressionSize < 2)THEN
       RAISE CZ_R_NO_PARTICIPANTS;
     END IF;

     expressionStart := 1;
     expressionEnd := expressionSize;

    ELSIF(nRuleType = RULE_TYPE_DESIGNCHART_RULE)THEN

     --Read all the features

     SELECT model_ref_expl_id, feature_id, feature_type, EXPR_NODE_TYPE_NODE
     BULK COLLECT INTO v_tExplNodeId, v_tExprPsNodeId, v_tFeatureType, v_tExprType
     FROM cz_des_chart_features
     WHERE rule_id = nRuleId
       AND deleted_flag = FLAG_NOT_DELETED;

nDebug := 34;

     --Determine the size of the expression for all eventual purposes.

     expressionSize := v_tExprType.COUNT;

     IF(expressionSize < 2)THEN
       RAISE CZ_R_NO_PARTICIPANTS;
     END IF;

     expressionStart := 1;
     expressionEnd := expressionSize;

    ELSE

     --Unknown rule type. Do nothing for those rules, just go to the next rule.

     RAISE CZ_LCE_CONTINUE;
    END IF;

    --General rule data validation section - all rule types----------------------------Start

    FOR i IN expressionStart..expressionEnd LOOP

      IF(v_tExprPsNodeId(i) IS NOT NULL)THEN
        IF(NOT glIndexByPsNodeId.EXISTS(v_tExprPsNodeId(i)))THEN

nDebug := 35;

     --Every participating node must actually exist in the product structure.

          RAISE CZ_R_WRONG_EXPRESSION_NODE;

        ELSIF(glPsNodeType(glIndexByPsNodeId(v_tExprPsNodeId(i))) = PS_NODE_TYPE_FEATURE AND
              glFeatureType(glIndexByPsNodeId(v_tExprPsNodeId(i))) = PS_NODE_FEATURE_TYPE_STRING)THEN

     --A text feature cannot participate in any kind of rules.

          localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(i)));
          RAISE CZ_R_INCORRECT_FEATURE_TYPE;

        ELSIF(glPsNodeType(glIndexByPsNodeId(v_tExprPsNodeId(i))) = PS_NODE_TYPE_CONNECTOR)THEN

     --A connector cannot participate in any kind of rules.

          RAISE CZ_R_CONNECTOR_RULE;
        END IF;

        IF(v_tExplNodeId(i) IS NULL)THEN

nDebug := 36;

    --Every not null ps_node_id should have a not null assosiated model_ref_expl_id (data corruption).

          RAISE CZ_G_INVALID_RULE_EXPLOSION;

        ELSIF(NOT v_IndexByNodeId.EXISTS(v_tExplNodeId(i)))THEN

nDebug := 37;

    --All the participants' model_ref_expl_id must be in the current model's explosion table (data corruption).

          RAISE CZ_G_INVALID_RULE_EXPLOSION;

        END IF;
      END IF;

nDebug := 38;

      IF(v_tExprType(i) IN (EXPR_NODE_TYPE_NODE, EXPR_PSNODEBYNAME))THEN
       IF(v_tExprPsNodeId(i) IS NULL)THEN

nDebug := 381;

      --Every node type node must have assosiated ps_node_id.

        RAISE CZ_R_INCORRECT_NODE_ID;
       END IF;
      ELSIF(v_tExprType(i) = EXPR_NODE_TYPE_LITERAL)THEN
       IF(v_tExprDataValue(i) IS NULL)THEN

nDebug := 382;

      --Every literal must have not null value.

        RAISE CZ_R_LITERAL_NO_VALUE;
       END IF;
      ELSIF(v_tExprType(i) = EXPR_NODE_TYPE_FEATPROP)THEN
       IF(v_tExprPsNodeId(i) IS NULL)THEN

nDebug := 383;

      --Every feature property node must have assosiated ps_node_id.

        RAISE CZ_R_INCORRECT_NODE_ID;
       ELSIF(v_tExprPropertyId(i) IS NULL)THEN

nDebug := 384;

      --Every feature property node must have assosiated property_id.

        RAISE CZ_R_FEATURE_NO_PROPERTY;
       END IF;
      END IF;

      --Bug #4760372.

      IF(v_tExprType(i) = EXPR_PSNODEBYNAME)THEN

        --This will resolve the path if possible, populate ps_node_id and model_ref_expl_id with
        --resolved values and change the type of the expression node.

        RESOLVE_NODE(SPLIT_PATH(v_RelativeNodePath(i)), v_tExprPsNodeId(i), v_tExplNodeId(i), v_tExprPsNodeId(i), v_tExplNodeId(i));
        v_tExprType(i) := EXPR_NODE_TYPE_NODE;
      END IF;
    END LOOP;
    --General rule data validation section-----------------------------------------------End

nDebug := 41;

    nCounter := 0;
    distinctCount := 0;
    participantCount := 0;
    MaxDepthValue := 0;
    MaxDepthIndex := thisRootExplIndex;

    FOR i IN expressionStart..expressionEnd LOOP
     IF(v_tExprPsNodeId(i) IS NOT NULL)THEN

      participantCount := participantCount + 1;
      auxIndex := glIndexByPsNodeId(v_tExprPsNodeId(i));

      --Soft fix the explosion nodes whenever necessary:

      --When a rule has a reference node as a participant,Developer would put the explosion id
      --of the reference node itself instead of the explosion id of its parent. This should be
      --fixed in some cases (see below).
      --If a participant is a component, then it's the component's MIN,MAX or COUNT and actual
      --participant should be it's parent. However,it can also be features of the component or
      --some other (new) operator. That's why we make sure that the parent of the component is
      --the operator DOT and, in addition, the component is non-virtual.

      --Later remark:
      --A reference, as well as a component, should be fixed only when they are in combination
      --with system property. So, it's not enough to check that the parent operator is DOT, we
      --also have to make sure that the another operand is EXPR_SYS_PROP with MIN,MAX or COUNT
      --subtype.

      IF(glPsNodeType(auxIndex) = PS_NODE_TYPE_REFERENCE OR
         (glPsNodeType(auxIndex) = PS_NODE_TYPE_COMPONENT AND glVirtualFlag(auxIndex) = FLAG_NON_VIRTUAL))THEN

         IF((v_ChildrenIndex.EXISTS(v_tExprId(i)) AND v_tExprType(v_ChildrenIndex(v_tExprId(i))) = EXPR_SYS_PROP AND
             h_SeededName.EXISTS(v_tExprSubtype(v_ChildrenIndex(v_tExprId(i)))) AND
             h_SeededName(v_tExprSubtype(v_ChildrenIndex(v_tExprId(i)))) IN (RULE_SYS_PROP_MININSTANCE, RULE_SYS_PROP_MAXINSTANCE, RULE_SYS_PROP_INSTANCECOUNT))
         )THEN

           --SYS_PROP_COUNT has been removed from the above condition as a part of the fix for the
           --bug #2317427 - we do not want to fix explosion if it is a reference to a BOM ATO. For
           --such a reference SYS_PROP_COUNT means #Quantity.

           --If this is a reference to a trackable model in a network container model, then this
           --rule is against its #Min or #Max, not #Quantity, and so it should be prohibited.
           --This exception does not just ignore the rule, it stops the generation.

           IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL AND glIbTrackable(v_tExprPsNodeId(i)) = FLAG_IB_TRACKABLE)THEN

             nParam := auxIndex;
             RAISE CZ_R_AGAINST_TRACKABLE;
           END IF;

           v_tExplNodeId(i) := v_tParentId(v_IndexByNodeId(v_tExplNodeId(i)));

         ELSIF(glPsNodeType(auxIndex) = PS_NODE_TYPE_REFERENCE)THEN

           --If we are here, than this is a reference to a BOM model, because it should be prohibited
           --for a reference to a component to participate with anything other than it's MIN or MAX.
           --We will fix the corresponding PS_NODE_ID value to be not the reference node's PS_NODE_ID
           --but the PS_NODE_ID of the referenced BOM model. This is necessary to generate the correct
           --object name.
           --In some cases we still need to use the real reference's ps_node_id.

           v_tRealPsNodeId(i) := v_tExprPsNodeId(i);
           v_tExprPsNodeId(i) := glReferenceId(v_tExprPsNodeId(i));
         END IF;
      END IF;

nDebug := 42;

      --Select a participant and get its explosion id.

      nAux := v_tExplNodeId(i);

      IF(NOT v_Participant.EXISTS(nAux))THEN

nDebug := 43;

        IF(v_ProhibitInRules.EXISTS(nAux))THEN

          --This explosion node has D nodes under connectors on the way up in the explosion table.
          --It will be impossible to assign this rule, so just stop here.

          localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(i)));
          auxIndex := v_ProhibitInRules(nAux);
          auxCount := v_ProhibitConnector(nAux);
          RAISE CZ_R_UNASSIGNABLE_RULE;

        ELSIF(v_ProhibitOptional.EXISTS(nAux))THEN

          --This explosion node has A nodes under connectors on the way up in the explosion table.
          --Stop here - bug #2217450.

          localString := glName(glIndexByPsNodeId(v_tExprPsNodeId(i)));
          auxIndex := v_ProhibitOptional(nAux);
          auxCount := v_ProhibitConnector(nAux);
          RAISE CZ_R_OPTIONAL_INSIDE;
        END IF;

        --Add to the list of indexes of distinct participants' explosions.

        v_Participant(nAux) := 1;
        distinctCount := distinctCount + 1;
        v_ParticipantIndex(distinctCount) := v_IndexByNodeId(nAux);

        --The node is not prohibited from participating in rules, so both assignable exists and
        --corresponding deepest instantiable node is defined.

        auxIndex := v_NodeInstantiable(nAux);
        auxCount := v_NodeAssignable(nAux);

        --We mark the potential assignables to reflect the fact that the associated participant
        --belongs to a connector net. We need a separate table because this information is rule
        --specific while v_IsConnectorNet stores the explosion-specific information. A node can
        --be assignable for a connector's net participant in one rule but not in another.

        IF(v_IsConnectorNet.EXISTS(nAux))THEN

          v_RuleConnectorNet(auxIndex) := 1;
          v_RuleConnectorNet(auxCount) := 1;
        END IF;

        --Select and store all the distinct assignables for all the current rule's participants.
        --Main indexes are stored in v_DistinctIndex. Also find the deepest D node among all of
        --participants here. MaxDepthValue is initialized to the root (0), so that if there are
        --no D nodes, the root node will act as one.

nDebug := 44;

        IF(NOT v_Assignable.EXISTS(auxIndex))THEN

          v_Assignable(auxIndex) := 1;
          nCounter := nCounter + 1;
          v_DistinctIndex(nCounter) := auxIndex;

          IF(v_tNodeDepth(auxIndex) > MaxDepthValue)THEN

             MaxDepthValue := v_tNodeDepth(auxIndex);
             MaxDepthIndex := auxIndex;
          END IF;
        END IF;

        IF(NOT v_Assignable.EXISTS(auxCount))THEN

          v_Assignable(auxCount) := 1;
          nCounter := nCounter + 1;
          v_DistinctIndex(nCounter) := auxCount;
        END IF;
      END IF; --This is a distinct participant.

      v_ExplByPsNodeId(v_tExprPsNodeId(i)) := v_tExplNodeId(i);

     END IF; --This is a participant.
    END LOOP;

nDebug := 45;

    --Now populate the <index in memory>(NODE_DEPTH) table for assignables of any type which
    --are above the deepest D component. They should form a chain, without duplicates on the
    --same level. Here we verify that there are no two components on the same level. This is
    --necessary but not sufficient for the rule to be valid.

    FOR i IN 1..v_DistinctIndex.COUNT LOOP

      auxIndex := v_DistinctIndex(i);

      IF(v_tNodeDepth(auxIndex) <= MaxDepthValue)THEN
        IF(v_InstByLevel.EXISTS(v_tNodeDepth(auxIndex)))THEN

          --There is already a node on this level. Two or more non-virtual components on the
          --same level are prohibited.

          auxCount := glIndexByPsNodeId(v_tPsNodeId(auxIndex));
          auxIndex := glIndexByPsNodeId(v_tPsNodeId(v_InstByLevel(v_tNodeDepth(auxIndex))));
          RAISE CZ_R_CONFLICTING_NODES;
        ELSE

          --This level is now occupied by a node with memory index auxIndex.

          v_InstByLevel(v_tNodeDepth(auxIndex)) := auxIndex;
        END IF;
      END IF;
    END LOOP;

nDebug := 46;

    --Now we make sure that if we move up from the deepest D assignable, we will step over
    --all other assignable which are above this D, so they all form a chain.
    --We start with the deepest D component and move up to its parent and so on thus going
    --through every level in the hierarchy. On every level, if an assignable exists there,
    --we make sure that this node is what we expect - the parent we just moved up to.

    nCounter := 0;
    auxIndex := MaxDepthIndex;

    LOOP
      IF(v_InstByLevel.EXISTS(v_tNodeDepth(auxIndex)))THEN
         IF(v_InstByLevel(v_tNodeDepth(auxIndex)) <> auxIndex)THEN

           --Incorrect node on the level. The rule goes across non-virual boundaries.

           auxCount := glIndexByPsNodeId(v_tPsNodeId(v_InstByLevel(v_tNodeDepth(auxIndex))));
           auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
           RAISE CZ_R_INCORRECT_NODE_LEVEL;
         END IF;
         nCounter := nCounter + 1;
      END IF;

      EXIT WHEN nCounter = v_InstByLevel.COUNT OR v_tParentId(auxIndex) IS NULL;
      auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
    END LOOP;

nDebug := 47;

    --We verified that on the way up from the deepest D node we pass ONLY through eligible
    --assignables. Now lets see if we passed through ALL of them.

    IF(nCounter <> v_InstByLevel.COUNT)THEN

      --Not all the assignables have been passed on the way up. The rule goes across
      --non-virual boundaries.

      RAISE CZ_R_INVALID_RULE;
    END IF;

    --So, there exists the deepest type D assignable (it can be the root node) and we verified
    --that above it there is no non-virtual boundaries crossing. However, if there are A type
    --assignables beneath that D node, we want to assign the rule to the least common ancestor.
    --Or there may be not assignables but just regular A nodes between assignables and D.

    --First of all, let us see if there are connector's nets attached to the deepest component
    --among the rule participants, because if there are, then the rule will be assigned to the
    --deepst D already found and there's no need to work with A type components. Example:

    --  M
    --  |_D
    --    |_A0
    --    | |_A
    --    | | |_F2
    --    | |_A
    --    |   |_F3
    --    |
    --    |_Connector->M1-F4

    --For both rules relating either (F2, F3) or (F2, F3, F4), D is the deepest D node. However,
    --the first rule should be assigned to A0 while the second rule should be assigned to D.
    --Reference bug #2188507.

    --We also identify possible connector's nets attached to a node above the deepest D node.
    --Such explosions will have assignables above the deepest D and so may have passed all the
    --tests above, but a rule may still cross non-virual boundaries. Example:

    --  M
    --  |_D
    --  | |_A
    --  |   |_F2
    --  |
    --  |___Connector->M1-F4

    --F4 has M as its assignable, and although M and D form a good chain, an (F2, F4) rule is
    --prohibited.
    --Reference bug #2190399.

    --This block can be optimized to use v_RuleConnectorNet table which was introduced later.

    auxCount := 0;

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      nAux := v_NodeId(v_ParticipantIndex(i));

      IF(v_IsConnectorNet.EXISTS(nAux))THEN
        IF(v_tNodeDepth(v_NodeAssignable(nAux)) < MaxDepthValue)THEN

          --This is a connector's net attached to a node above the deepest D assignable, report
          --the rule.

          auxCount := glIndexByPsNodeId(v_tReferringId(v_IsConnectorNet(nAux)));
          auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
          RAISE CZ_R_CONNECTOR_ASIDE;
        ELSIF(v_NodeAssignable(nAux) = MaxDepthIndex)THEN

          --This is a connector's net attached to the D, so the rule will be assigned to the D.

          auxCount := 1;

          --Just one attached net is enough, but we cannot exit here because we need to examine
          --all other participants on account of connector's nets attached above the D node
          --(the previous IF does that).
        END IF;
      END IF;
    END LOOP;

    IF(auxCount = 0)THEN

      --We know that the rule can be assigned somewhere under the deepest D node. It can be
      --one of the A type nodes under the deepest D, assignable or not. We start from every
      --assignable A node underneath the deepest D and go up all the way to the D. If we do
      --not end up on the deepest D, the rule crosses non-virtual boundaries and is invalid.

      --On the way up we collect the following information:

      --  for every level the number of distinct components of any type on this level
      --  (v_LevelCount);
      --  index of the first of such components (v_LevelIndex);
      --  type of the first of such components (v_LevelType);

nDebug := 48;

      nCounter := MaxDepthValue;

      FOR i IN 1..v_DistinctIndex.COUNT LOOP

        auxIndex := v_DistinctIndex(i);
        nAux := v_tNodeDepth(auxIndex);

        IF(v_tExplNodeType(auxIndex) = EXPL_NODE_TYPE_OPTIONAL AND nAux > MaxDepthValue)THEN

           IF(nCounter < nAux)THEN nCounter := nAux; END IF;

           FOR n IN REVERSE MaxDepthValue + 1..nAux LOOP

             IF(NOT v_LevelCount.EXISTS(nAux))THEN

               v_LevelCount(nAux) := 1;
               v_LevelIndex(nAux) := auxIndex;
               v_LevelType(nAux) := v_tExplNodeType(auxIndex);
             END IF;

             IF(auxIndex <> v_LevelIndex(nAux))THEN

               v_LevelCount(nAux) := v_LevelCount(nAux) + 1;
             END IF;

             auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
             nAux := nAux - 1;
           END LOOP;

           IF(auxIndex <> MaxDepthIndex)THEN

             --The way up from the A node doesn't pass through the D node on level MaxDepthValue.
             --Crossing of non-virtual boundaries detected.

             auxCount := glIndexByPsNodeId(v_tPsNodeId(v_DistinctIndex(i)));
             auxIndex := glIndexByPsNodeId(v_tPsNodeId(MaxDepthIndex));
             RAISE CZ_R_OPTIONAL_ASIDE;
           END IF;
        END IF;
      END LOOP;

nDebug := 49;

      --We want to find the deepest A component we can assign the rule to. So we move from the
      --top down shifting MaxDepthIndex with every A component we find. When we hit a fork, we
      --stop.

      FOR i IN MaxDepthValue + 1..nCounter LOOP

        IF(v_LevelCount(i) = 1 AND v_LevelType(i) = EXPL_NODE_TYPE_OPTIONAL)THEN

          MaxDepthIndex := v_LevelIndex(i);
        END IF;

        --We stop when we hit a fork or when we see that there is a connector net attached to
        --the optional component which is another kind of fork. Example:

        --  A1
        --  |_A2
        --    |_A3
        --    | |_A4
        --    |
        --    |_Connector->participant

        --We don't want to go below A2.

        IF(v_LevelCount(i) > 1 OR v_RuleConnectorNet.EXISTS(v_LevelIndex(i))) THEN

          EXIT;
        END IF;
      END LOOP;
    END IF;  --We finished processing the tree of A nodes beneath the deepest D node which
             --may have resulted in assigning the rule to an A node under the deepest D.

    --If this rule is defined in a network container model, it can't have participants across
    --instantiable references to trackable models. We have already calculated indexes of such
    --references for every explosion. The requirement above means that, if one of the indexes
    --belongs to a non-trackable model, then all the indexes should belong to a non-trackable
    --model.

    IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

      localCount := 0;

      FOR i IN 1..v_ParticipantIndex.COUNT LOOP

        IF(glIbTrackable(v_tPsNodeId(v_NodeTrackable(v_NodeId(v_ParticipantIndex(i))))) = FLAG_NOT_IB_TRACKABLE)
        THEN localCount := localCount + 1; END IF;
      END LOOP;

      IF(localCount > 0 AND localCount < v_ParticipantIndex.COUNT)THEN

        RAISE CZ_R_ACROSS_TRACKABLE;
      END IF;
    END IF;

nDebug := 490;

    --The rule is assigned to this component (identified by model_ref_expl_id). This variable
    --is used mostly for identification of rule logic files, but also in rule generation code.

    MaxDepthId := v_NodeId(MaxDepthIndex);
    MaxDepthValue := v_tNodeDepth(MaxDepthIndex);

nDebug := 50;

    --We need to prepend downpaths for all the distinct participating explosions. If the
    --assignable of an explosion id is deeper than the rule's assignee, we are going to
    --prepend the downpath with all optional (type A) components or mandatory references
    --on the way down from the assignee to the assignable. We do not need to change the
    --node's logic level.
    --We do not prepend downpaths for explosions corresponding to connectors.

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      nAux := v_NodeId(v_ParticipantIndex(i));

      IF(NOT v_IsConnectorNet.EXISTS(nAux))THEN

        auxIndex := v_NodeAssignable(nAux);

        WHILE(v_tNodeDepth(auxIndex) > MaxDepthValue)LOOP
          IF(v_tExplNodeType(auxIndex) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_MANDATORY))THEN

            v_AssignedDownPath(nAux) := PATH_DELIMITER || 'N_' ||
                TO_CHAR(glPersistentId(NVL(v_tReferringId(auxIndex), v_tPsNodeId(auxIndex)))) ||
                                        v_AssignedDownPath(nAux);
          END IF;

          auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
        END LOOP;
      END IF;
    END LOOP;

nDebug := 51;

    --Now we can go ahead and collect the load conditions for this rule. Those would be all
    --type A (optional) and C (connector) descendants of the rule assignee. To collect them
    --we need to go up from each (distinct) rule participant's explosion id (index).
    --There may also be no load conditions at all and then this is the 'standard' rule file
    --identified by explosion id of the assignee as a load condition (NET_TYPE = 2).

    FOR i IN 1..v_ParticipantIndex.COUNT LOOP

      auxIndex := v_ParticipantIndex(i);

      WHILE(v_tNodeDepth(auxIndex) > MaxDepthValue AND v_tParentId(auxIndex) IS NOT NULL) LOOP

        IF(v_tExplNodeType(auxIndex) IN (EXPL_NODE_TYPE_OPTIONAL, EXPL_NODE_TYPE_CONNECTOR))THEN

          --It is enough to just mark the index as a load condition.

          v_MarkLoadCondition(auxIndex) := 1;
        END IF;

        auxIndex := v_IndexByNodeId(v_tParentId(auxIndex));
      END LOOP;
    END LOOP;

nDebug := 52;

    nHeaderId := NEVER_EXISTS_ID;

    IF(v_MarkLoadCondition.COUNT = 0)THEN

      --This is going to be a mandatory (standard) rule file.

      logicNetType := LOGIC_NET_TYPE_MANDATORY;
      v_LoadConditionId(1) := MaxDepthId;
      IF(v_tIsHeaderGenerated.EXISTS(MaxDepthId))THEN

        nHeaderId := v_tIsHeaderGenerated(MaxDepthId);
      END IF;
    ELSE

      --There are load conditions, so this is going to be a network logic file.

      logicNetType := LOGIC_NET_TYPE_NETWORK;

nDebug := 53;

      --Generate the load condition string. Note that with the algorithm used condition nodes
      --are ordered, otherwise it would make no sense.
      --There is currently no check for not to exceed the length of the localString.

      localString := NULL;
      nCounter := 0;

      FOR i IN 1..v_NodeId.COUNT LOOP
        IF(v_MarkLoadCondition.EXISTS(i))THEN

          nCounter := nCounter + 1;
          v_LoadConditionId(nCounter) := v_NodeId(i);
          localString := localString || ':' || TO_CHAR(v_NodeId(i));
        END IF;
      END LOOP;

nDebug := 54;

      nCounter := 0;

      FOR i IN 1..v_LoadConditions.COUNT LOOP
        IF(localString = v_LoadConditions(i))THEN

          --Load condition found, fetch the corresponding header and exit the loop.

          nHeaderId := v_LoadHeaders(i);
          nCounter := 1;
          EXIT;
        END IF;
      END LOOP;

      IF(nCounter = 0)THEN

        --A new load condition, add it to the table. Corresponding header will be
        --generated and added later.

        v_LoadConditions(v_LoadConditions.COUNT + 1) := localString;
      END IF;
    END IF;

    nCounter := v_LoadConditionId.COUNT;

nDebug := 7;

    --Generate a new logic header if necessary.

    IF(nHeaderId = NEVER_EXISTS_ID)THEN

      nHeaderId := next_lce_header_id;

      BEGIN

        --Insert the rule net logic header record into the table.

        INSERT INTO cz_lce_headers
         (lce_header_id, gen_version, gen_header, component_id, net_type,
          devl_project_id, model_ref_expl_id, nbr_required_expls, deleted_flag)
        VALUES
         (nHeaderId, VersionString, GenHeader, v_tPsNodeId(v_IndexByNodeId(MaxDepthId)),
          logicNetType, thisProjectId, MaxDepthId, nCounter, FLAG_PENDING);

        FOR i IN 1..nCounter LOOP

          nAux := v_LoadConditionId(i);

          --The following statement populates the new ALIAS_NAME column introduced as a fix
          --for the bug #2214414. The column is populated with C_<model_ref_expl_id> for
          --connector conditions and with NULL for other conditions (optional components).

          INSERT INTO cz_lce_load_specs
           (attachment_expl_id, lce_header_id, required_expl_id, attachment_comp_id,
            model_id, net_type, deleted_flag, alias_name)
          VALUES
           (MaxDepthId, nHeaderId, nAux, v_tPsNodeId(v_IndexByNodeId(MaxDepthId)),
            thisProjectId, logicNetType, FLAG_PENDING,
            DECODE(v_tExplNodeType(v_IndexByNodeId(nAux)), EXPL_NODE_TYPE_CONNECTOR, 'C_' || nAux, NULL));
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          errorMessage := SQLERRM;
          RAISE CZ_R_UNABLE_TO_CREATE_HEADER;
      END;

      NewHeaders(counterNewHeaders) := nHeaderId;
      NewHeadersComponents(counterNewHeaders) := v_tPsNodeId(v_IndexByNodeId(MaxDepthId));
      NewHeadersExplosions(counterNewHeaders) := MaxDepthId;
      counterNewHeaders := counterNewHeaders + 1;

      IF(logicNetType = LOGIC_NET_TYPE_MANDATORY)THEN

        v_tIsHeaderGenerated(MaxDepthId) := nHeaderId;
      ELSE

        v_LoadHeaders(v_LoadHeaders.COUNT + 1) := nHeaderId;
      END IF;

      v_tSequenceNbr(nHeaderId) := 1;
      v_tLogicNetType(nHeaderId) := logicNetType;
      nNewLogicFileFlag := 1;
    END IF;

    nRuleAssignedLevel := v_tNodeDepth(v_IndexByNodeId(MaxDepthId));

    --If the logic file has changed then we need to flush off the buffer

    IF(nHeaderId <> nPreviousHeaderId)THEN

     IF(vLogicText IS NOT NULL)THEN
       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nPreviousHeaderId, v_tSequenceNbr(nPreviousHeaderId), vLogicText);
       vLogicText := NULL;
       v_tSequenceNbr(nPreviousHeaderId) := v_tSequenceNbr(nPreviousHeaderId) + 1;
     END IF;

    END IF;

    nPreviousHeaderId := nHeaderId;

    IF(nNewLogicFileFlag = 1)THEN

      --This is a new logic file, put the header lines in

      vLogicLine := 'CONTROL NOSPEC' || NewLine || 'VERSION 3 3' || NewLine || NewLine ||
                    'REM -- Rules file for component: ' || TO_CHAR(v_tPsNodeId(v_IndexByNodeId(MaxDepthId))) ||
                    ', explosion node: ' || TO_CHAR(MaxDepthId) || NewLine || NewLine;
      PACK;
      nNewLogicFileFlag := 0;

    END IF;

nDebug := 8;

   --Prepare the effective date interval.
   --First get the effective date interval either from an effectivity set or
   --from the local values.

   IF(nRuleEffSetId IS NOT NULL)THEN
    IF(gvIndexBySetId.EXISTS(nRuleEffSetId))THEN

nDebug := 8000100;

     CurrentEffFrom := gvEffFrom(gvIndexBySetId(nRuleEffSetId));
     CurrentEffUntil := gvEffUntil(gvIndexBySetId(nRuleEffSetId));

  --Fix for the bug6502787
     dEffFrom := CurrentEffFrom;
     dEffUntil:= CurrentEffUntil;
    ELSE
      --This is a fatal error - data corruption
      RAISE CZ_R_WRONG_EFFECTIVITY_SET;
    END IF;
   ELSE
     CurrentEffFrom := dEffFrom;
     CurrentEffUntil := dEffUntil;
   END IF;

nDebug := 8000101;

   --Make sure effective dates are not null. Usage mask is not null anyway.

   IF(CurrentEffFrom IS NULL)THEN CurrentEffFrom := EpochBeginDate; END IF;
   IF(CurrentEffUntil IS NULL)THEN CurrentEffUntil := EpochEndDate; END IF;

   dEffFrom := CurrentEffFrom;
   dEffUntil := CurrentEffUntil;

   IF((NOT PrevRuleEffFrom.EXISTS(nHeaderId)) OR
      (CurrentEffFrom <> PrevRuleEffFrom(nHeaderId)) OR (CurrentEffUntil <> PrevRuleEffUntil(nHeaderId)) OR
      (vUsageMask <> PrevRuleUsageMask(nHeaderId)))THEN

        vLogicLine := LTRIM(vUsageMask, '0');
        IF(vLogicLine IS NOT NULL) THEN
          vLogicLine := EffUsagePrefix || vLogicLine;
        END IF;

        IF(CurrentEffFrom = EpochBeginDate)THEN
          CurrentFromDate := NULL;
        ELSE
          CurrentFromDate := TO_CHAR(CurrentEffFrom, EffDateFormat);
        END IF;

        IF(CurrentEffUntil = EpochEndDate)THEN
          CurrentUntilDate := NULL;
        ELSE
          CurrentUntilDate := TO_CHAR(CurrentEffUntil, EffDateFormat);
        END IF;

        vLogicLine := 'EFF ' || CurrentFromDate || ', ' || CurrentUntilDate || ', ' || vLogicLine || NewLine;
        PACK;

        PrevRuleEffFrom(nHeaderId) := CurrentEffFrom;
        PrevRuleEffUntil(nHeaderId) := CurrentEffUntil;
        PrevRuleUsageMask(nHeaderId) := vUsageMask;
   END IF;

nDebug := 8000102;

   --Expression generation

   IF(nRuleType IN (RULE_TYPE_TEMPLATE, RULE_TYPE_EXPRESSION))THEN

    FOR i IN expressionStart..expressionEnd LOOP
      IF(v_tExprParentId(i) IS NULL)THEN

        --Because of the ordering by expr_parent_id, all the expression tree roots will be at the end
        --after all their children. As soon as we hit the first of them we can start generating.
        --The construction of children lookup arrays has been moved directly after reading the
        --expression tree.

        --Bugs #5160714, #5184017. Reset optimization and other parameters per rule. It is not enough
        --to do it once after for each rule record because rule text may consist of several rules.
        --These parameter are not used for other rule types.

        optimizeChain      := OPTIMIZATION_UNKNOWN;
        optimizeContribute := OPTIMIZATION_UNKNOWN;
        jAntecedentRoot  := NULL;
        jConsequentRoot  := NULL;
        RuleTemplateType := RULE_TYPE_UNKNOWN;
        numericLHS       := 0;
        generateCompare  := 0;

        returnStringArray := GENERATE_EXPRESSION(i, returnListType);
      END IF;
    END LOOP;
   ELSIF(nRuleType = RULE_TYPE_COMPAT_TABLE)THEN

     GENERATE_COMPATIBILITY_TABLE;
   ELSIF(nRuleType = RULE_TYPE_DESIGNCHART_RULE)THEN

     GENERATE_DESIGNCHART_RULE;
   END IF; --End expression and rule generation
   END IF; --Not a rule folder or functional companion

  --This block handles the exceptions during a rule generation. Every such exception
  --will stop generation only for the particular rule if not re-raised here.

  EXCEPTION
     WHEN CZ_R_UNKNOWN_RULE_TYPE THEN
--'Unknown rule type, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_UNKNOWN_RULE_TYPE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_RULE THEN
--'Rule ''%RULENAME'' cannot be generated because it relates an incorrect combination of components. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_UNASSIGNABLE_RULE THEN
--'Rule ''%RULENAME'' cannot be generated because the node ''%NODENAME'' is a descendant of the multiply
-- instantiable component ''%COMPONENT'' inside the connected model ''%CONNECTOR'', and therefore cannot
-- participate in rules. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_UNASSIGNABLE_RULE', 'NODENAME', localString, 'COMPONENT', glName(auxIndex), 'CONNECTOR', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_OPTIONAL_INSIDE THEN
--'Rule ''%RULENAME'' cannot be generated because the node ''%NODENAME'' is a descendant of the optional
-- component ''%COMPONENT'' inside the connected model ''%CONNECTOR'', and therefore cannot  participate
-- in rules. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_OPTIONAL_INSIDE', 'NODENAME', localString, 'COMPONENT', glName(auxIndex), 'CONNECTOR', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_OPTIONAL_ASIDE THEN
--'Rule ''%RULENAME'' cannot be generated because it relates the multiply instantiable component ''%COMPONENT1''
-- with the optional component ''%COMPONENT2''. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_OPTIONAL_ASIDE', 'COMPONENT1', glName(auxIndex), 'COMPONENT2', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_CONNECTOR_ASIDE THEN
--'Rule ''%RULENAME'' cannot be generated because it relates the multiply instantiable component ''%COMPONENT''
-- with the connected model ''%CONNECTOR''. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_CONNECTOR_ASIDE', 'COMPONENT', glName(auxIndex), 'CONNECTOR', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_CONFLICTING_NODES THEN
--'Logic cannot be generated for Rule ''%RULENAME''. This is because the rule participants are descendants of
-- Components ''%COMPONENT1'' and ''%COMPONENT2'' that can be instantiated multiple times. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_CONFLICTING_NODES', 'COMPONENT1', glName(auxIndex), 'COMPONENT2', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_NODE_LEVEL THEN
--'Rule ''%RULENAME'' cannot be generated because it relates the multiply instantiable component ''%COMPONENT1'' with the component ''%COMPONENT2''.
-- Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_NODE_LEVEL', 'COMPONENT1', glName(auxIndex), 'COMPONENT2', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_ACROSS_TRACKABLE THEN
--'Logic cannot be generated for rule ''%RULENAME'' because it relates a trackable instantiable Model with
-- non-trackable items inside the Container Model ''%PROJECTNAME''. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_ACROSS_TRACKABLE', 'PROJECTNAME', rootProjectName, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_CONNECTOR_RULE THEN
--'Rule ''%RULENAME'' in the Model ''%MODELNAME'' is invalid. Connectors cannot participate in rules.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_CONNECTOR_RULE', 'MODELNAME', thisProjectName, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_LOGIC_RULE THEN
--'Invalid logic rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_LOGIC_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCOMPLETE_LOGIC_RULE THEN
--'Incomplete logic rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCOMPLETE_LOGIC_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_LOGIC_RULE_WRONG_FEAT THEN
--'Incorrect feature type in logic rule, feature ''%FEATNAME'', rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_LOGIC_RULE_WRONG_FEAT', 'FEATNAME', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_NUMERIC_RULE_WRONG_FEAT THEN
--'Incorrect feature type in numeric rule, feature ''%FEATNAME'', rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_NUMERIC_RULE_WRONG_FEAT', 'FEATNAME', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_FEATURE_TYPE THEN
--'Text features are not allowed to participate in rules, feature ''%FEATNAME'', rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_FEATURE_TYPE', 'FEATNAME', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_NUMERIC_RULE THEN
--'Invalid numeric rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_NUMERIC_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_NUMERIC_RHS THEN
--'The node ''%NODENAME'' in the Model ''%MODELNAME'' is a(n) ''%NODETYPE''. This type of node cannot be
-- a participant on the B side of a Numeric rule. Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_NUMERIC_RHS', 'NODENAME', localString, 'MODELNAME', thisProjectName, 'NODETYPE', errorMessage, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCOMPATIBLE_SYSPROP THEN
--'The Property ''%PROPERTYNAME'' is invalid for the node ''%NODENAME''. Rule ''%RULENAME'' in Model ''%MODELNAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCOMPATIBLE_SYSPROP', 'PROPERTYNAME', localString, 'NODENAME', glName(auxIndex), 'MODELNAME', thisProjectName, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_COMPARISON_RULE THEN
--'Invalid comparison rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_COMPARISON_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_NUMERIC_PART THEN
--'Invalid numeric part, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_NUMERIC_PART', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCOMPLETE_NUMERIC_RULE THEN
--'Incomplete numeric rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCOMPLETE_NUMERIC_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_NUMRULE_NODE THEN
--'Invalid numeric rule node, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_NUMRULE_NODE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INVALID_NUM_SIMPLE_EXPR THEN
--'The left-hand side expression must have a root rounding operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INVALID_NUM_SIMPLE_EXPR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_UNKNOWN_EXPR_TYPE THEN
--'Unknown expression type, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_UNKNOWN_EXPR_TYPE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_ARITHMETIC_OPER THEN
--'Incorrect arithmetic operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_ARITHMETIC_OPER', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_COMPARISON_OPER THEN
--'Incorrect comparison operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_COMPARISON_OPER', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_ROUND_OPERATOR THEN
--'Incorrect ROUND operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_ROUND_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_ANDOR_OPERATOR THEN
--'Incorrect AND/OR operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_ANDOR_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_NOT_OPERATOR THEN
--'Incorrect NOT operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_NOT_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_NOTTRUE_OPERATOR THEN
--'Incorrect NOTTRUE operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_NOTTRUE_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_VAL_EXPRESSION THEN
--'Incorrect VAL expression, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_VAL_EXPRESSION', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_VAL_EXPRESS_TYPE THEN
--'Incorrect VAL expression type, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_VAL_EXPRESS_TYPE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_MINMAX_OPERATOR THEN
--'Incorrect MIN/MAX operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_MINMAX_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_OF_OPERATOR THEN
--'Incorrect OF operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_OF_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_DOT_OPERATOR THEN
--'Incorrect DOT operator, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_DOT_OPERATOR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_DOT_TYPE_MISMATCH THEN
--'DOT type mismatch, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_DOT_TYPE_MISMATCH', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_BAD_PROPERTY_TYPE THEN
--'Bad property type, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_BAD_PROPERTY_TYPE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_NO_SUCH_PROPERTY THEN
--'No such property, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_NO_SUCH_PROPERTY', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_NULL_PROPERTY_VALUE THEN
--'Null property value, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_NULL_PROPERTY_VALUE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_INCORRECT_PROPERTY THEN
--'Unable to identify property value, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_INCORRECT_PROPERTY', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_UNKNOWN_OPERATOR_TYPE THEN
--'Unknown operator type, type %OPERTYPE, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_UNKNOWN_OPERATOR_TYPE', 'OPERTYPE', TO_CHAR(nParam), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_INVALID_OPERAND_TYPE THEN
--'Invalid operand type, operator ''%OPERNAME'', rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_INVALID_OPERAND_TYPE', 'OPERNAME', LTRIM(RTRIM(OperatorLiterals(v_tExprSubtype(nParam)))), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_MATH_PARAMETERS THEN
--'Incorrect number of parameters to mathematical function %FUNCTION, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_MATH_PARAMETERS', 'RULENAME', RULE_NAME, 'FUNCTION', LTRIM(RTRIM(OperatorLiterals(nParam)))), 1);
       PACK;
     WHEN CZ_E_INCORRECT_POWER THEN
--'Exponent value of a POW function could not be resolved to a constant integer, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_INCORRECT_POWER', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_UNABLE_TO_CREATE_TABLE THEN
--'Unable to create a temporary table for property-based compatibility rule, rule ''%RULENAME'' ignored, error: %ERRORTEXT'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_UNABLE_TO_CREATE_TABLE', 'RULENAME', RULE_NAME, 'ERRORTEXT', errorMessage), 1);
       PACK;
     WHEN CZ_R_WRONG_COMPAT_EXPRESSION THEN
--'Incorrect compatibility expression, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_WRONG_COMPAT_EXPRESSION', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_WRONG_OPER_IN_COMPAT THEN
--'Incorrect operator in compatibility rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_WRONG_OPER_IN_COMPAT', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_UKNOWN_OPER_IN_COMPAT THEN
--'Unknown operator in compatibility rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_UKNOWN_OPER_IN_COMPAT', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_COMPAT_NO_COMBINATIONS THEN
--'No valid combinations, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_COMPAT_NO_COMBINATIONS', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_WRONG_EXPRESSION_NODE THEN
--'Incorrect node in expression, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_WRONG_EXPRESSION_NODE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_NO_DEFINING_SELECTION THEN
--'No selection made between primary and defining feature in design chart rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_NO_DEFINING_SELECTION', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_NO_PRIMARY_FEATURE THEN
--'No primary feature in design chart rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_NO_PRIMARY_FEATURE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_DELETED_OPTION THEN
--'The Model structure has changed and the Design Chart rule ''%RULENAME'' now contains deleted node ''%NODENAME''.
-- The rule will be ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_DELETED_OPTION', 'RULENAME', RULE_NAME, 'NODENAME', errorMessage), 1);
       PACK;
     WHEN CZ_R_WRONG_DESIGNCHART_RULE THEN
--'No one-to-one correspondence between options of primary and defining feature in design chart rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_WRONG_DESIGNCHART_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_DUPLICATE_COMBINATION THEN
--'Not unique combination of defining feature options for a primary option in design chart rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_DUPLICATE_COMBINATION', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCOMPLETE_DES_CHART THEN
--'Incorrect number of compatibility selections made for the option ''%OPTIONNAME'' of the Primary Feature ''%FEATURENAME''
-- in Design Chart ''%RULENAME''. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCOMPLETE_DES_CHART', 'OPTIONNAME', glName(auxIndex), 'FEATURENAME', glName(auxCount), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_EMPTY_COMPAT_RULE THEN
--'Empty compatibility rule, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_EMPTY_COMPAT_RULE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_COMPAT_SINGLE_FEATURE THEN
--'Compatibility rule must have at least two participating features, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_COMPAT_SINGLE_FEATURE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_COMPAT_RULE_NO_PROPERTY THEN
--'Incomplete compatibility rule, no property defined for feature ''%FEATNAME'', rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_COMPAT_RULE_NO_PROPERTY', 'FEATNAME', glName(glIndexByPsNodeId(v_tExprPsNodeId(nParam))), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_OPTION_NO_PROPERTY THEN
--'Property value for ''%PROPERTYNAME'' is not defined for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in model ''%MODELNAME''. Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_OPTION_NO_PROPERTY', 'PROPERTYNAME', errorMessage, 'ITEMNAME', glName(auxIndex), 'PARENTNAME', glName(nParam), 'MODELNAME', glName(glIndexByPsNodeId(inProjectId)),'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_LONG_PROPERTY_VALUE THEN
--'Value of the Property ''%PROPERTYNAME'' is too long for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in model ''%MODELNAME''. Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_LONG_PROPERTY_VALUE', 'PROPERTYNAME', errorMessage, 'ITEMNAME', glName(auxIndex), 'PARENTNAME', glName(nParam), 'MODELNAME', glName(glIndexByPsNodeId(inProjectId)),'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_DATA_TYPE THEN
--'Incorrect data: integer or decimal property ''%PROPERTYNAME'' has a text value of ''%VALUE''. Rule ''%RULENAME'' in model ''%MODELNAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_DATA_TYPE', 'PROPERTYNAME', errorMessage, 'VALUE', localString, 'MODELNAME', glName(glIndexByPsNodeId(inProjectId)), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_NUMERICLHS THEN
--'''%PROPERTYNAME'' is invalid in the Numeric rule ''%RULENAME'' in Model ''%MODELNAME''. Text and Boolean Properties
-- cannot be participants on the left-hand side of a Numeric rule. Rule ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_NUMERICLHS', 'PROPERTYNAME', errorMessage, 'MODELNAME', glName(glIndexByPsNodeId(inProjectId)), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_PROPERTY_NOT_ALLOWED THEN
--'The expression contained a Text property which is only allowed in a comparison expression. A Text property is not
-- allowed in the context of your expression. Rule ''%RULENAME'' in Model ''%MODELNAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_PROPERTY_NOT_ALLOWED', 'MODELNAME', glName(glIndexByPsNodeId(inProjectId)), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_VIRTUAL_COMPONENT THEN
--'The system property ''%PROPERTYNAME'' is not allowed because ''%NODENAME'' is required. Refer to Oracle Configurator
-- Developer documentation for details. Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_VIRTUAL_COMPONENT', 'PROPERTYNAME', localString, 'NODENAME', glName(nParam), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_WRONG_COMPAT_TABLE THEN
--'Incorrect explicit compatibility table, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_WRONG_COMPAT_TABLE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_NO_PARTICIPANTS THEN
--'Incomplete rule - no participants, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_NO_PARTICIPANTS', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_NO_COMPONENT_ID THEN
--'No ps_node_id defined for none of the rule participants, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_NO_COMPONENT_ID', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_RULE_WRONG_EXPRESSION THEN
--'Invalid expression specified, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_RULE_WRONG_EXPRESSION', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_WRONG_EFFECTIVITY_SET THEN
--'Invalid effectivity set assosiated with rule ''%RULENAME'', rule ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_WRONG_EFFECTIVITY_SET', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_LITERAL_NO_VALUE THEN
--'No literal value specified in rule ''%RULENAME'', rule ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_LITERAL_NO_VALUE', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_NODE_ID THEN
--'Incomplete or invalid data in rule ''%RULENAME'', rule ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_NODE_ID', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_FEATURE_NO_PROPERTY THEN
--'Invalid property or no property specified in rule ''%RULENAME'', rule ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_FEATURE_NO_PROPERTY', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_INCORRECT_REFERENCE THEN
--'The reference %PATH is invalid. At least one node does not exist in the Model or is not effective when the rule is effective.
-- Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_INCORRECT_REFERENCE', 'PATH', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_AMBIGUOUS_REFERENCE THEN
--'Unable to resolve Model node reference %PATH because it is ambiguous. Rule ''%RULENAME'' ignored.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_AMBIGUOUS_REFERENCE', 'PATH', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_NO_EXPECTED_CHILDREN THEN
--'Node ''%NODENAME'' has no children, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_NO_EXPECTED_CHILDREN', 'NODENAME', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_E_NO_OPTIONAL_CHILDREN THEN
--'All children of the BOM node ''%NODENAME'' are required when parent is selected, no optional children, rule ''%RULENAME'' ignored'
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_NO_OPTIONAL_CHILDREN', 'NODENAME', localString, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_TRACKABLE_ANCESTOR THEN
--'BOM item ''%ITEMNAME'' cannot participate in the Numeric rule ''%RULENAME'' because it contains other trackable BOM items.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_TRACKABLE_ANCESTOR', 'ITEMNAME', glName(nParam), 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_AGAINST_TRACKABLE THEN
--'Numeric rule ''%RULENAME'' is invalid. In a Container Model, a Numeric rule cannot contribute to or consume
-- from how many instances of a trackable Model are allowed at runtime.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_R_AGAINST_TRACKABLE', 'RULENAME', RULE_NAME), 1);
       PACK;
--'Only nontranslatable System Properties are allowed in the WHERE clause of a COMPATIBLE or FORALL operator.
-- The System Property ''%PROPERTYNAME'' can be translated, therefore it is invalid in this context. Rule ''%RULENAME''
-- in the Model ''%MODELNAME'' will be ignored.'
     WHEN CZ_E_DESCRIPTION_IN_WHERE THEN
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_DESCRIPTION_IN_WHERE', 'PROPERTYNAME', errorMessage,'MODELNAME', thisProjectName, 'RULENAME', RULE_NAME), 1);
       PACK;
--'Only static System Properties are allowed in the WHERE clause of a COMPATIBLE or FORALL operator. The value of the
-- System Property ''%PROPERTYNAME'' can change at runtime, therefore it is invalid in this context. Rule ''%RULENAME''
-- in the Model ''%MODELNAME'' will be ignored.'
     WHEN CZ_E_PROPERTY_NOT_STATIC THEN
       REPORT(CZ_UTILS.GET_TEXT('CZ_E_PROPERTY_NOT_STATIC', 'PROPERTYNAME', errorMessage,'MODELNAME', thisProjectName, 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_R_TEMPLATE_UNKNOWN OR CZ_R_EMPTY_PARAMETER_SCOPE OR CZ_R_PARAMETER_NOT_FOUND OR
          CZ_R_TYPE_NO_PROPERTY OR CZ_R_NO_SIGNATURE_ID THEN
--'Unable to generate rule ''%RULENAME'', internal data error.'
       REPORT(CZ_UTILS.GET_TEXT('CZ_G_INTERNAL_RULE_ERROR', 'RULENAME', RULE_NAME), 1);
       PACK;
     WHEN CZ_G_INVALID_RULE_EXPLOSION THEN
--This is fatal: model_ref_expl_id of one of the participants references an explosion table
--other than the current model table
       errorMessage := RULE_NAME;
       IF(StopOnFatalRuleError = 1)THEN
         IF(c_rules%ISOPEN)THEN CLOSE c_rules; END IF;
         RAISE;
       ELSE
--'Unable to generate rule ''%RULENAME'', internal data error.'
         REPORT(CZ_UTILS.GET_TEXT('CZ_G_INTERNAL_RULE_ERROR', 'RULENAME', errorMessage), 1);
         PACK;
       END IF;
     WHEN CZ_R_UNABLE_TO_CREATE_HEADER THEN

         --This is supposed to be a definitely fatal error, so raise the exception.

         IF(c_rules%ISOPEN)THEN CLOSE c_rules; END IF;
         RAISE;
     WHEN CZ_LCE_CONTINUE THEN
--This exception is used to immediately move to the next loop, not an error.
       NULL;
     WHEN OTHERS THEN
       IF(nDebug >= 40 AND nDebug <= 54)THEN
         errorMessage := RULE_NAME;
       ELSIF(SUBSTR(TO_CHAR(nDebug), 1, 1) = '8')THEN
         errorMessage := TO_CHAR(nRuleId);
       END IF;

       --When the first data corruption-type error for a rule is encountered, logic gen stops.
       --However, it may be convenient for debugging purposes to be able to report all of such
       --rules. So, check the db setting here.

       IF(StopOnFatalRuleError = 1)THEN
         IF(c_rules%ISOPEN)THEN CLOSE c_rules; END IF;
         RAISE;
       ELSE
--'Unable to generate rule ''%RULENAME'', internal error %ERRORTEXT'
         REPORT(CZ_UTILS.GET_TEXT('CZ_G_GENERAL_RULE_ERROR', 'RULENAME', RULE_NAME, 'ERRORTEXT', SQLERRM), 1);
         PACK;
       END IF;
  END;
  END LOOP;
  CLOSE c_rules;

  --Now generate the INC relations into the root rule file for the non-virtual components
  --that have rules against their max.

  IF(v_MaxRuleExists.COUNT > 0)THEN
    IF(v_tIsHeaderGenerated.EXISTS(thisComponentExplId))THEN

      --Use this header to generate the rule into

      nHeaderId := v_tIsHeaderGenerated(thisComponentExplId);

    ELSE

      nHeaderId := next_lce_header_id;

      BEGIN

        --Insert the rule net logic header record into the table

        INSERT INTO cz_lce_headers
         (lce_header_id, gen_version, gen_header, component_id, net_type,
          devl_project_id, model_ref_expl_id, nbr_required_expls, deleted_flag)
        VALUES
         (nHeaderId, VersionString, GenHeader, inComponentId, LOGIC_NET_TYPE_MANDATORY,
          thisProjectId, thisComponentExplId, 1, FLAG_PENDING);

        INSERT INTO cz_lce_load_specs
         (attachment_expl_id, lce_header_id, required_expl_id, attachment_comp_id,
          model_id, net_type, deleted_flag)
        VALUES
         (thisComponentExplId, nHeaderId, thisComponentExplId, inComponentId,
          thisProjectId, LOGIC_NET_TYPE_MANDATORY, FLAG_PENDING);

      EXCEPTION
        WHEN OTHERS THEN
          errorMessage := SQLERRM;
          RAISE CZ_R_UNABLE_TO_CREATE_HEADER;
      END;

      NewHeaders(counterNewHeaders) := nHeaderId;
      NewHeadersComponents(counterNewHeaders) := inComponentId;
      NewHeadersExplosions(counterNewHeaders) := thisComponentExplId;
      counterNewHeaders := counterNewHeaders + 1;

      v_tIsHeaderGenerated(thisComponentExplId) := nHeaderId;
      v_tSequenceNbr(nHeaderId) := 1;
      v_tLogicNetType(nHeaderId) := LOGIC_NET_TYPE_MANDATORY;
      nNewLogicFileFlag := 1;

    END IF;

    --If the logic file has changed then we need to flush off the buffer

    IF(nHeaderId <> nPreviousHeaderId)THEN

     IF(vLogicText IS NOT NULL)THEN
       INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
        (nPreviousHeaderId, v_tSequenceNbr(nPreviousHeaderId), vLogicText);
       vLogicText := NULL;
       v_tSequenceNbr(nPreviousHeaderId) := v_tSequenceNbr(nPreviousHeaderId) + 1;
     END IF;

    END IF;

    IF(nNewLogicFileFlag = 1)THEN

      --This is a new logic file, put the header lines in

      vLogicLine := 'CONTROL NOSPEC' || NewLine || 'VERSION 3 3' || NewLine || NewLine ||
                    'REM -- Rules file for component: ' || TO_CHAR(inComponentId) ||
                    ', explosion node: ' || TO_CHAR(thisComponentExplId) || NewLine || NewLine ||
                    'EFF , , ' || NewLine || NewLine;
      PACK;
    END IF;

    FOR i IN 1..v_NodeId.COUNT LOOP
     IF(v_MaxRuleExists.EXISTS(v_NodeId(i)) AND v_tVirtualFlag(i) = FLAG_NON_VIRTUAL AND
        v_tNodeDepth(i) > 0)THEN

       --Use intermediate variable instead of using NVL because this is faster

       IF(v_tReferringId(i) IS NOT NULL)THEN
        localString := TO_CHAR(glPersistentId(v_tReferringId(i)));
       ELSE
        localString := TO_CHAR(glPersistentId(v_tPsNodeId(i)));
       END IF;

       vLogicLine := 'INC 1 P_' || localString || '_MAX round' || NewLine;
       PACK;

     END IF;
    END LOOP;

  END IF;

nDebug := 9;

  --Flush off the buffer after rules generation

  IF(vLogicText IS NOT NULL)THEN
    INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
     (nHeaderId, v_tSequenceNbr(nHeaderId), vLogicText);
    vLogicText := NULL;
    v_tSequenceNbr(nHeaderId) := v_tSequenceNbr(nHeaderId) + 1;
  END IF;

  FOR i IN 1..temp_tables.COUNT LOOP
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || temp_tables(i);
      EXECUTE IMMEDIATE 'DROP TABLE ' || temp_tables(i);
    EXCEPTION
      WHEN OTHERS THEN
        IF(SQLCODE <> ORACLE_OBJECT_IN_USE)THEN RAISE; END IF;
    END;
  END LOOP;

  IF(TwoPhaseCommit = 0)THEN COMMIT; END IF;

EXCEPTION
  WHEN OTHERS THEN
    FOR i IN 1..temp_tables.COUNT LOOP
      BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || temp_tables(i);
        EXECUTE IMMEDIATE 'DROP TABLE ' || temp_tables(i);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    RAISE;
END; --GENERATE_RULES
---------------------------------------------------------------------------------------
BEGIN --GENERATE_COMPONENT_TREE - Product Structure Generation

  --Generate next lce_header_id for this LCE file. This is the structure net for a model or
  --non-virtual component.

nDebug := 1110000;

  IF(inParentLogicHeaderId IS NULL)THEN

    --If this is the root model, read and store its name and type for later use.

    BEGIN

      SELECT name, model_type INTO thisProjectName, thisProjectType
        FROM cz_devl_projects
       WHERE devl_project_id = inComponentId;
    EXCEPTION
      WHEN OTHERS THEN
        nParam := inComponentId;
        RAISE CZ_S_NO_SUCH_PROJECT;
    END;

    IF(inComponentId = inDevlProjectId)THEN

      --Store the name and type of the root project for which the logic generation was
      --originally started.

      rootProjectName := thisProjectName;
      rootProjectType := thisProjectType;
    ELSIF(thisProjectType = MODEL_TYPE_CONTAINER_MODEL AND rootProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

      --Container cannot be referenced or connected to.

      errorMessage := thisProjectName;
      RAISE CZ_S_CONTAINER_REFERENCE;
    END IF;
  END IF;

  IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN

    --Read the explosions table here. It will be extensively used in rule generation. For the
    --structure generation, there is really no need in this table, except that now we want to
    --put reasonable values into CZ_LCE_HEADERS.MODEL_REF_EXPL_ID even for structure files as
    --this column is being made not nullable in 18.

    IF(inParentLogicHeaderId IS NULL)THEN

      --If this is the root model, read the table and populate project's id and explosion id
      --variables, and hash tables.

      SELECT model_ref_expl_id, parent_expl_node_id, node_depth,
             ps_node_type, virtual_flag, component_id, referring_node_id,
             child_model_expl_id, expl_node_type
      BULK COLLECT INTO v_NodeId, v_tParentId, v_tNodeDepth,
                        v_tNodeType, v_tVirtualFlag, v_tPsNodeId, v_tReferringId,
                        v_tChildModelExpl, v_tExplNodeType
      FROM cz_model_ref_expls
      WHERE model_id = inComponentId AND deleted_flag = FLAG_NOT_DELETED;

      FOR i IN 1..v_NodeId.COUNT LOOP

nDebug := 1110010;

        IF(v_tVirtualFlag(i) = FLAG_NON_VIRTUAL AND v_tExplNodeType(i) = EXPL_NODE_TYPE_MANDATORY)THEN

          --This is introduced as a remedy to a well-known type of data corruption occured during
          --the development process. May be removed later on when the data become stable.

          errorMessage := thisProjectName;
          RAISE CZ_G_INVALID_EXPLOSION_TYPE;
        END IF;

nDebug := 1110001;

        --Add another indexing option - by model_ref_expl_id

        v_IndexByNodeId(v_NodeId(i)) := i;

        --Store the explosion id and the index of the root node - the project node itself.

        IF(v_tNodeDepth(i) = 0)THEN
          thisComponentExplId := v_NodeId(i);
          thisRootExplIndex := i;
        END IF;

        --Create the EXPL_NODE_TYPE(MODEL_REF_EXPL_ID) hash table. Other explosion columns
        --are currently indexed through v_IndexByNodeId. Using direct hash may provide for
        --some performance improvement.

        v_TypeByExplId(v_NodeId(i)) := v_tExplNodeType(i);

        --Build the MODEL_REF_EXPL_ID(COMPONENT_ID) hash table for all the components
        --inside this project (not inside referenced projects). All such components
        --have CHILD_MODEL_EXPL_ID null. We need this table to populate MODEL_REF_EXPL_ID
        --in CZ_LCE_HEADERS records for structure file of this component.

        IF(v_tChildModelExpl(i) IS NULL)THEN
          v_NodeIdByComponent(v_tPsNodeId(i)) := v_NodeId(i);
        END IF;
      END LOOP;
    ELSE

nDebug := 1110002;

      --This is a non-virtual component inside this project, so the value in the
      --hash table exists.
      --We do not have to populate thisRootExplIndex, because it is used only in
      --rule generation and this will not be called for a non-root component.
      --Have to populate the other two variables though as they are used here in
      --the structure generation.

      thisComponentExplId := v_NodeIdByComponent(inComponentId);
    END IF;

    thisProjectId := inProjectId;

    --Generate next lce_header_id for this LCE file. This is the structure net for a model or
    --non-virtual component.

    nStructureHeaderId := next_lce_header_id;

    BEGIN

     --Insert the structure logic header record into the table.

     INSERT INTO cz_lce_headers
      (lce_header_id, gen_version, gen_header, component_id, net_type,
       devl_project_id, model_ref_expl_id, nbr_required_expls, deleted_flag)
     VALUES
      (nStructureHeaderId, VersionString, GenHeader, inComponentId, LOGIC_NET_TYPE_STRUCTURE,
       thisProjectId, thisComponentExplId, 1, FLAG_PENDING);

     --Insert the structure load conditions record for this component.

     INSERT INTO cz_lce_load_specs
      (attachment_expl_id, lce_header_id, required_expl_id, attachment_comp_id,
       model_id, net_type, deleted_flag)
     VALUES
      (thisComponentExplId, nStructureHeaderId, thisComponentExplId, inComponentId,
       thisProjectId, LOGIC_NET_TYPE_STRUCTURE, FLAG_PENDING);

    EXCEPTION
      WHEN OTHERS THEN
        errorMessage := SQLERRM;
        RAISE CZ_S_UNABLE_TO_CREATE_HEADER;
    END;

    NewHeaders(counterNewHeaders) := nStructureHeaderId;
    NewHeadersComponents(counterNewHeaders) := inComponentId;
    NewHeadersExplosions(counterNewHeaders) := thisComponentExplId;
    counterNewHeaders := counterNewHeaders + 1;

  ELSIF(IsLogicGenerated(inComponentId) = 0)THEN

    --The flag may be set by two reasons: the model was considered up-to-date or the model has already been
    --processed in this session. Only in the first case a header should exist in the database and we need
    --to load it into memory. In the second case it should be in the memory and may not exist in the database.
    --Bug #3150226.

nDebug := 1110003;

    SELECT head.lce_header_id, max(text.seq_nbr) INTO nStructureHeaderId, nSequenceNbr
      FROM cz_lce_headers head, cz_lce_texts text
     WHERE head.deleted_flag = FLAG_NOT_DELETED
       AND head.net_type = LOGIC_NET_TYPE_STRUCTURE
       AND head.component_id = inComponentId
       AND head.lce_header_id = text.lce_header_id
     GROUP BY head.lce_header_id;

    vSeqNbrByHeader(nStructureHeaderId) := nSequenceNbr + 1;
  END IF;

nDebug := 1110004;

  vLogicText := 'CONTROL NOSPEC' || NewLine || 'VERSION 3 3' || NewLine ||
                'SETDEFAULTDELTA F' || NewLine || 'EFF , , ' || NewLine || NewLine ||
                'REM -- Structure file for component: ' || TO_CHAR(inComponentId) || NewLine || NewLine ||
                'OBJECT _ALWAYS_TRUE' || NewLine || 'MINMAX 1 1 _ALWAYS_TRUE' || NewLine ||
                'OBJECT _ALWAYS_FALSE' || NewLine ||
                'GS N' || NewLine || 'GL L _ALWAYS_TRUE' || NewLine || 'GR L _ALWAYS_FALSE' || NewLine;

nDebug := 1110005;

  --This SELECT statement reads the whole 'virtual' tree under a non-virtual component which also
  --includes the non-virtual component itself. Non-virtual components underneath are included in
  --order to recurse, and this function will be called for every non-virtual component underneath.
  --The resulting order provided by this statement is used later when generating list of options
  --for an option feature.

  SELECT ps_node_id, parent_id, item_id, minimum, maximum, name, intl_text_id, minimum_selected,
         maximum_selected, ps_node_type, initial_value, virtual_flag, feature_type, bom_required_flag,
         reference_id, persistent_node_id, effective_from, effective_until, effective_usage_mask,
         effectivity_set_id, decimal_qty_flag, ib_trackable, accumulator_flag, initial_num_value,
         instantiable_flag, shippable_item_flag, inventory_transactable_flag, assemble_to_order_flag,
         serializable_item_flag
  BULK COLLECT INTO
         ntPsNodeId, ntParentId, ntItemId, ntMinimum, ntMaximum, ntName, ntDescriptionId, ntMinimumSel,
         ntMaximumSel, ntPsNodeType, ntInitialValue, ntVirtualFlag, ntFeatureType, ntBomRequired,
         ntReferenceId, ntPersistentId, dtEffFrom, dtEffUntil, vtUsageMask,
         ntEffSetId, ntDecimalQty, ntIbTrackable, ntAccumulator, ntInitialNumValue,
         ntInstantiableFlag, ntShippableFlag, ntTransactableFlag, ntAtoFlag, ntSerializableFlag
  FROM cz_ps_nodes
  WHERE deleted_flag = FLAG_NOT_DELETED
  START WITH ps_node_id = inComponentId
  CONNECT BY PRIOR ps_node_id = parent_id
      AND (PRIOR virtual_flag IS NULL OR PRIOR virtual_flag = FLAG_VIRTUAL OR
           PRIOR ps_node_id = inComponentId);

nDebug := 1110006;

  --Make sure there is some data returned

  IF(ntPsNodeId.LAST IS NOT NULL)THEN

nDebug := 1110007;

  --Having this dummy boundary node eliminates the necessity of potentially time
  --consuming boundary checks during the option feature options' list generation

  ntParentId(ntPsNodeId.LAST + 1) := NEVER_EXISTS_ID;

  --Prepare to start the main cycle

  i := ntPsNodeId.FIRST;

  WHILE(i <= ntPsNodeId.LAST) LOOP --Start the main structure generating cycle
   BEGIN

    CurrentlyPacking := PACKING_GENERIC;

   --Populate the 'global' arrays - required for rules generation

nDebug := 1110010;

    IF(NOT glIndexByPsNodeId.EXISTS(ntPsNodeId(i)))THEN

     IF(ntInitialNumValue(i) IS NOT NULL)THEN ntInitialValue(i) := TO_CHAR(ntInitialNumValue(i)); END IF;

     glPsNodeId(globalCount) := ntPsNodeId(i);
     glItemId(globalCount) := ntItemId(i);
     glPsNodeType(globalCount) := ntPsNodeType(i);
     glParentId(globalCount) := ntParentId(i);
     glFeatureType(globalCount) := ntFeatureType(i);
     glName(globalCount) := ntName(i);
     glBomRequired(globalCount) := ntBomRequired(i);
     glMinimum(globalCount) := ntMinimum(i);
     glMaximum(globalCount) := ntMaximum(i);
     glMinimumSel(globalCount) := ntMinimumSel(i);
     glMaximumSel(globalCount) := ntMaximumSel(i);
     glVirtualFlag(globalCount) := ntVirtualFlag(i);
     glInitialValue(globalCount) := ntInitialValue(i);

   --Indexing by ps_node_id, will be used in expressions generation to get back to
   --the structure.

     glIndexByPsNodeId(ntPsNodeId(i)) := globalCount;

   --These global arrays will be indexed differently because we only need to get
   --persistent_node_id or reference_id by ps_node_id. Probably, good indexing
   --option for some of the other global arrays, too.

     glPersistentId(ntPsNodeId(i)) := ntPersistentId(i);
     glReferenceId(ntPsNodeId(i)) := ntReferenceId(i);
     glDecimalQty(ntPsNodeId(i)) := ntDecimalQty(i);
     glIbTrackable(ntPsNodeId(i)) := ntIbTrackable(i);
     glAccumulator(ntPsNodeId(i)) := ntAccumulator(i);
     glInstantiableFlag(ntPsNodeId(i)) := ntInstantiableFlag(i);

   --Children of any node start right after the node. But then, the children list may
   --not be dense, because children may have their own children. So in order to find
   --all the children of a node we need to search the whole structure after the node.
   --Here we store the last child's index so that we need to search not the whole
   --structure up to the end but up to this last child's index.

nDebug := 1110011;

     IF(ntParentId(i) IS NOT NULL)THEN
      glLastChildIndex(ntParentId(i)) := globalCount;

      --This array is used in design chart rules generation and contains the number of children
      --of a node. We actually use it only for features and BOM option classes.

      IF(NOT featOptionsCount.EXISTS(ntParentId(i)))THEN featOptionsCount(ntParentId(i)) := 0; END IF;
      featOptionsCount(ntParentId(i)) := featOptionsCount(ntParentId(i)) + 1;
     END IF;

     IF(ntPsNodeType(i) = PS_NODE_TYPE_BOM_STANDARD AND ntIbTrackable(i) = FLAG_IB_TRACKABLE AND
        thisProjectType IN (MODEL_TYPE_PTO_MODEL, MODEL_TYPE_ATO_MODEL) AND
        glPsNodeType(glIndexByPsNodeId(ntParentId(i))) = PS_NODE_TYPE_BOM_MODEL AND
        glIbTrackable(ntParentId(i)) = FLAG_NOT_IB_TRACKABLE) THEN

       --A trackable BOM Standard item cannot be a direct child of a non-trackable
       --ATO/PTO Model if this model is references from any Network Container model.
       --Re: bug #3644036.

       IF(NOT h_containerReferred.EXISTS(ntParentId(i)))THEN

         BEGIN

           EXECUTE IMMEDIATE containerReferred INTO h_containerReferred(ntParentId(i)) USING ntParentId(i);

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             h_containerReferred(ntParentId(i)) := 0;
         END;
       END IF;

       IF(h_containerReferred(ntParentId(i)) = 1)THEN

         errorMessage := thisProjectName;
         nParam := glIndexByPsNodeId(ntPsNodeId(i));
         RAISE CZ_S_TRACKABLE_STANDARD;
       END IF;
     END IF;

   --Prepare the actual effective date interval for populating global effectivity dates.
   --First get the nominal effective date interval either from an effectivity set or
   --from the local values.

     IF(ntEffSetId(i) IS NOT NULL)THEN
      IF(gvIndexBySetId.EXISTS(ntEffSetId(i)))THEN
       CurrentEffFrom := gvEffFrom(gvIndexBySetId(ntEffSetId(i)));
       CurrentEffUntil := gvEffUntil(gvIndexBySetId(ntEffSetId(i)));
      ELSE
        --This is a fatal error - data corruption.
        --'Invalid effectivity set associated with node ''%NODENAME'''
        errorMessage := CZ_UTILS.GET_TEXT('CZ_S_WRONG_EFFECTIVITY_SET', 'NODENAME', ntName(i));
        RAISE CZ_S_WRONG_EFFECTIVITY_SET;
      END IF;
     ELSE
       CurrentEffFrom := dtEffFrom(i);
       CurrentEffUntil := dtEffUntil(i);
     END IF;
     CurrentUsageMask := vtUsageMask(i);

   --Make sure effective dates are not null, so that actual effective date interval
   --will have no null bounds too. Usage mask is not null anyway.

     IF(CurrentEffFrom IS NULL)THEN CurrentEffFrom := EpochBeginDate; END IF;
     IF(CurrentEffUntil IS NULL)THEN CurrentEffUntil := EpochEndDate; END IF;

   --If this is not a model or a root component, adjust the effectivity dates by
   --intersecting with parent's actual effectivity dates, which have already been
   --calculated because of the hierarchichal order of the query.
   --Actual effective date interval is the intersection of parent's actual effective
   --date interval with child's nominal effective date interval. Again, no nulls.

     IF(ntParentId(i) IS NOT NULL)THEN

       localCount := glIndexByPsNodeId(ntParentId(i));
       IF(glEffFrom(localCount) > CurrentEffFrom)THEN CurrentEffFrom := glEffFrom(localCount); END IF;
       IF(glEffUntil(localCount) < CurrentEffUntil)THEN CurrentEffUntil := glEffUntil(localcount); END IF;

       --Adjust usage mask here. CurrentUsageMask is now OR-ed with glUsageMask(localCount)
       CurrentUsageMask := RAWTOHEX(UTL_RAW.BIT_OR(HEXTORAW(LPAD(CurrentUsageMask,16,'0')),HEXTORAW(glUsageMask(localCount))));

     END IF;

   --From now on the local variables (dtEff) or effectivity set, if defined, will contain
   --the nominal effective date interval while the global variables (glEff) will contain
   --the actual (intersected with parent) effective date interval.
   --The same is true for the usage mask nominal/actual values.

     glEffFrom(globalCount) := CurrentEffFrom;
     glEffUntil(globalCount) := CurrentEffUntil;
     glUsageMask(globalCount) := CurrentUsageMask;

     glHeaderByPsNodeId(ntPsNodeId(i)) := nStructureHeaderId;
     globalCount := globalCount + 1;

    ELSE

     localCount := glIndexByPsNodeId(ntPsNodeId(i));
     CurrentEffFrom := glEffFrom(localCount);
     CurrentEffUntil := glEffUntil(localCount);
     CurrentUsageMask := glUsageMask(localCount);

    END IF;

nDebug := 1110012;

    IF(isLogicGenerated.EXISTS(inComponentId))THEN

      --We need to call the procedure for any non-virtual component (bug #2065239) and for any
      --component and reference.

      IF(ntPsNodeType(i) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

        --Check for circularity.

        localCount := 0;

        FOR n IN 1..globalLevel LOOP
         IF(globalStack(n) = ntReferenceId(i))THEN

           --Circularity detected.

           localCount := 1;
           EXIT;
         END IF;
        END LOOP;

        IF(localCount = 0)THEN

          globalLevel := globalLevel + 1;
          globalStack(globalLevel) := ntReferenceId(i);
          globalRef(globalLevel) := ntPsNodeId(i);

          IF(ntPsNodeType(i) = PS_NODE_TYPE_REFERENCE)THEN

            localMinString := TO_CHAR(ntMinimum(i));
            IF(localMinString IS NULL)THEN localMinString := '0'; END IF;
            localMaxString := TO_CHAR(ntMaximum(i));
            IF(localMaxString IS NULL)THEN localMaxString := '-1'; END IF;

            --Store the information on the instantiability of the reference on the stack.

            IF(localMinString = '1' AND localMaxString = '1')THEN
              globalInstance(globalLevel) := 0;
            ELSE
              globalInstance(globalLevel) := 1;
            END IF;
          ELSE
            --This is a connector and instantiability is not defined, but we need a value on
            --the stack.

            globalInstance(globalLevel) := 0;
          END IF;

          GENERATE_COMPONENT_TREE(ntReferenceId(i), ntReferenceId(i), NULL);
          globalLevel := globalLevel - 1;

          --Bug #5003285. Need to move the propagation of trackable flag into this branch which
          --executes even if child model is up-to-date.

          IF(ntPsNodeType(i) = PS_NODE_TYPE_REFERENCE AND rootProjectType = MODEL_TYPE_CONTAINER_MODEL AND

            --All the following verifications are to be made only if the referenced model is
            --a BOM Model - bug #2509208.

            glPsNodeType(glIndexByPsNodeId(ntReferenceId(i))) IN
              (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

            --If the referenced model is trackable it may be a trackable leaf. However, if its
            --trackableAncestor flag exists, it has trackable children. In any case we need to
            --mark all of its ancestors and make sure their quantities are not greater than 1,
            --because the root is a container model here.

            IF(glIbTrackable(ntReferenceId(i)) = FLAG_IB_TRACKABLE OR
               trackableAncestor.EXISTS(ntReferenceId(i)))THEN

               trackableAncestor(ntPsNodeId(i)) := 1;
               PROPAGATE_TRACKABLE_ANCESTOR;
            END IF;
          END IF;
        END IF;

      ELSIF(ntVirtualFlag(i) = FLAG_NON_VIRTUAL AND
            ntPsNodeType(i) IN (PS_NODE_TYPE_COMPONENT, PS_NODE_TYPE_PRODUCT) AND
            ntPsNodeId(i) <> inComponentId)THEN

        --We emulate the component as a model with generated logic because we do not want to
        --generate anything but still want to follow everything underneath this component.

        IsLogicGenerated(ntPsNodeId(i)) := 1;

        --We can pass logic header as NULL because it will never be actually used.

        GENERATE_COMPONENT_TREE(ntPsNodeId(i), inProjectId, 0);
      END IF;

      --Bug #5003285. Need to move the propagation of trackable flag into this branch which
      --executes even if child model is up-to-date.

      IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL AND
         ntPsNodeType(i) IN (PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD) AND
         glIbTrackable(ntPsNodeId(i)) = FLAG_IB_TRACKABLE)THEN

         PROPAGATE_TRACKABLE_ANCESTOR;

         --If the item is tangible, we should prohibit not only its ancestors but also itself
         --from being on the RHS of numeric rules - TSO with Equipment.

         IF(ntShippableFlag(i) = '1')THEN trackableAncestor(ntPsNodeId(i)) := 2; END IF;
      END IF;

    --If no logic already exists, generate the structure.

    ELSE

    GENERATE_EFFECTIVITY_LOGIC(CurrentEffFrom, CurrentEffUntil, CurrentUsageMask);

    IF(ntPsNodeType(i) = PS_NODE_TYPE_OPTION)THEN

      --We are in a feature's options. The important assumption here is that a feature
      --can have only options as it's children,so feature's children list is dense and
      --all the feature's children should be processed, and this list starts here.
      --In other words, we assume that as soon as we encountered the first option of a
      --feature, we will be dealing only with options of this feature until we process
      --all of them.

      /*--The restriction is removed (bug #1746927)-----------------------------------
        --First make sure that there aren't too many options.
      IF(optionCounter > MAX_NUMBER_OF_OPTIONS)THEN
        --This will be fatal and terminate the logic generation
        --'Option feature has more than maximum allowed number of options, feature ''%FEATNAME'''
        errorMessage := CZ_UTILS.GET_TEXT('CZ_S_TOO_MANY_OPTIONS', 'FEATNAME', ntName(i));
        RAISE CZ_S_TOO_MANY_OPTIONS;
      END IF;
      ------------------------------------------------------------------------------*/

      optionCounter := optionCounter + 1;

      --Generate the option: OBJECT P_<OptID> R
      vLogicLine := 'OBJECT P_' || TO_CHAR(ntPersistentId(i)) || ' R' || NewLine;

      --If this is the last option, we will generate the feature right here

      IF(ntParentId(i + 1) <> ntParentId(i))THEN

        --Done with options, ready to generate the feature, put in the stored
        --effectivity information.

        PACK;
        GENERATE_EFFECTIVITY_LOGIC(FeatureEffFrom, FeatureEffUntil, FeatureUsageMask);

        --This is the feature index

        j := i - optionCounter;

        --Generate the feature itself. Local variables here are inherited from the feature
        --generation section.
        --But before that adjust the minimum number of selected children to the actual number
        --of options - bug #2233795.

        IF(ntMinimum(j) IS NOT NULL AND ntMinimum(j) > optionCounter)THEN

          localMinString := TO_CHAR(optionCounter);
        END IF;

        vLogicLine := 'SGN P_' || TO_CHAR(ntPersistentId(j)) || ' R ' || localMinString || ' ' ||
        localMaxString || ' _';

nDebug := 1110028;

        --Generate the list of options for the feature

        WHILE(j < i)LOOP

         j := j + 1;

         --This call is necessary here for wrapping

         PACK;
         vLogicLine := ' P_' || TO_CHAR(ntPersistentId(j));

nDebug := 1110029;

        END LOOP;

        --We must put [new line] after the list of options

        vLogicLine := vLogicLine || NewLine;
        j := i - optionCounter;

        PACK;
        GENERATE_ACCUMULATOR(j);
        generatingFeature := 0;

        --Minimum number of selected options greater than the actual number of options.
        --The feature is already generated and now will be reported.

        IF(ntMinimum(j) IS NOT NULL AND ntMinimum(j) > optionCounter)THEN

         RAISE CZ_S_ILLEGAL_OPTION_FEATURE;
        END IF;

      END IF;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_TOTAL OR
       ntPsNodeType(i) = PS_NODE_TYPE_RESOURCE)THEN

nDebug := 1110014;

    --This is a total or resource: TOTAL P_<Tot/ResID> R [tot/res initial value]

     vLogicLine := 'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || ' R ' ||
                   ntInitialValue(i) || NewLine;
    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_FEATURE)THEN

nDebug := 1110015;

    --This is a feature, so consider different subtypes

     IF(ntFeatureType(i) IS NULL OR ntFeatureType(i) = PS_NODE_FEATURE_TYPE_INTEGER)THEN

nDebug := 1110016;

     --This is an integer feature: real integer or count

      IF(ntMinimum(i) IS NULL OR ntMinimum(i) < 0)THEN

nDebug := 1110017;

      --This is a real integer feature: TOTAL P_<FeatID> R [initial_value]

       vLogicLine := 'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || ' R ' ||
                     ntInitialValue(i) || NewLine;
      ELSE

nDebug := 1110018;

      --This is a count feature: OBJECT P_<FeatID> R [initial_value]

/* This is rolled back as a fix for the bug #1994924.

       --If initial value is not specified and minimum value is greater than 0, we
       --define the initial value to be equal to the minimum value. Bug #1834581.

       IF(ntInitialValue(i) IS NULL)THEN
         ntInitialValue(i) := ntMinimum(i);
       END IF;
*/
       vLogicLine := 'OBJECT P_' || TO_CHAR(ntPersistentId(i)) || ' R ' ||
                     ntInitialValue(i) || NewLine;
      END IF;
     ELSIF(ntFeatureType(i) = PS_NODE_FEATURE_TYPE_FLOAT)THEN

nDebug := 1110019;

     --This is a decimal feature: TOTAL P_<FeatID> R [initial_value]

/* This is rolled back as a fix for the bug #1994924.

      --If initial value is not specified and minimum value is specified and is greater than 0,
      --we define the initial value to be equal to the minimum value. Bug #1834581.

      IF(ntInitialValue(i) IS NULL AND ntMinimum(i) > 0)THEN
        ntInitialValue(i) := ntMinimum(i);
      END IF;
*/
      vLogicLine := 'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || ' R ' ||
                    ntInitialValue(i) || NewLine;
     ELSIF(ntFeatureType(i) = PS_NODE_FEATURE_TYPE_BOOLEAN)THEN

nDebug := 1110020;

     --This is a boolean feature

      vLogicLine := 'OBJECT P_' || TO_CHAR(ntPersistentId(i)) || ' R' || NewLine;
      IF(ntInitialValue(i) IS NOT NULL)THEN
       IF(ntInitialValue(i) = '1')THEN

nDebug := 1110021;

       --Initial value is 'True', create a default rule from an always true object
       --toward this one

        vLogicLine := vLogicLine || 'OBJECT D_' || TO_CHAR(ntPersistentId(i)) || '_IV' || NewLine ||
          'WITH _default = _ALWAYS_TRUE' || NewLine ||
          'GS R ... ' || TO_CHAR(ntDescriptionId(i)) || NewLine ||
          'GL N D_' || TO_CHAR(ntPersistentId(i)) || '_IV' || NewLine ||
          'GR N P_' || TO_CHAR(ntPersistentId(i)) || NewLine;

--        vLogicLine := vLogicLine || 'WITH _default = _ALWAYS_TRUE' || NewLine;

       ELSIF(ntInitialValue(i) = '0')THEN

nDebug := 1110022;

       --Initial value is 'False', create a temporary object and an additional
       --'negates' relation

        vLogicLine := vLogicLine || 'OBJECT D_' || TO_CHAR(ntPersistentId(i)) || '_IV' || NewLine ||
          'WITH _default = _ALWAYS_TRUE' || NewLine ||
          'GS N ... ' || TO_CHAR(ntDescriptionId(i)) || NewLine ||
          'GL N D_' || TO_CHAR(ntPersistentId(i)) || '_IV' || NewLine ||
          'GR N P_' || TO_CHAR(ntPersistentId(i)) || NewLine;

       ELSE

        RAISE CZ_S_BAD_BOOLEAN_FEAT_VALUE;

       END IF;
      END IF;

     ELSIF(ntFeatureType(i) = PS_NODE_FEATURE_TYPE_STRING)THEN

nDebug := 1110023;

       NULL;

/* Do not need to generate anything for text features.

     --This is a text feature

      vLogicLine := 'TEXT P_' || TO_CHAR(ntPersistentId(i)) || ' R "' ||
                  ntInitialValue(i) || '"' || NewLine;
*/
     ELSIF(ntFeatureType(i) = PS_NODE_FEATURE_TYPE_OPTION)THEN

      --Set the options counter

      optionCounter := 0;

      --Prepare Min, Max values for later use
      --Use intermediate variable instead of using NVL because this is faster
      --This values will be used also when generating the last option of the feature

      localMinString := TO_CHAR(ntMinimum(i));
      IF(localMinString IS NULL)THEN localMinString := '0'; END IF;
      localMaxString := TO_CHAR(ntMaximum(i));
      IF(localMaxString IS NULL)THEN localMaxString := '-1'; END IF;

      --Save feature's effective intervals and usage mask for feature generating type

      FeatureEffFrom := CurrentEffFrom;
      FeatureEffUntil := CurrentEffUntil;
      FeatureUsageMask := CurrentUsageMask;

nDebug := 1110024;

      --Check if there are any children, report if not

      IF(ntParentId(i + 1) <> ntPsNodeId(i))THEN

        --No options, still want to generate the feature even with empty options list

        vLogicLine := 'SGN P_' || TO_CHAR(ntPersistentId(i)) || ' R ' || localMinString || ' ' ||
        localMaxString || ' _' || NewLine;

        --No children, report the feature
        RAISE CZ_S_FEATURE_NO_CHILDREN;
      END IF;

      --Now proceed with the cycle. As options of the feature directly follows it in memory,
      --we will be generating them right away. After the last option, the feature itself will
      --be generated (see options generating code).

      generatingFeature := 1;

nDebug := 1110027;

     ELSE

       --'Unknown feature type, feature ''%FEATNAME'''
       errorMessage := CZ_UTILS.GET_TEXT('CZ_S_UNKNOWN_FEATURE_TYPE', 'FEATNAME', ntName(i));
       RAISE CZ_S_UNKNOWN_FEATURE_TYPE;
     END IF;
    ELSIF(ntPsNodeType(i) IN (PS_NODE_TYPE_COMPONENT, PS_NODE_TYPE_PRODUCT) AND
          ntVirtualFlag(i) = FLAG_NON_VIRTUAL)THEN

nDebug := 1110030;

     --We don't want to go into an infinite cycle - don't call the procedure for the current
     --root component

     IF(ntPsNodeId(i) <> inComponentId)THEN

      --This is another non-virtual component. Call this function for it - recursion
      --Use intermediate variable instead of using NVL because this is faster

      localMinString := TO_CHAR(ntMinimum(i));
      IF(localMinString IS NULL)THEN localMinString := '0'; END IF;
      localMaxString := TO_CHAR(ntMaximum(i));
      IF(localMaxString IS NULL)THEN localMaxString := '-1'; END IF;

      vLogicLine := 'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_MIN R ' || localMinString || NewLine ||
                    'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_MAX R ' || localMaxString || NewLine ||
                    'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_ACTUALCOUNT R 0' || NewLine;

      GENERATE_COMPONENT_TREE(ntPsNodeId(i), inProjectId, nStructureHeaderId);
     END IF;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_REFERENCE)THEN

nDebug := 1110031;

     --Check for circularity.

     localCount := 0;
     trackableContext := 0;
     instantiableContext := 0;

     FOR n IN 1..globalLevel LOOP

      IF(globalStack(n) = ntReferenceId(i))THEN

        --Circularity detected.

        localCount := 1;
        EXIT;
      END IF;

      IF(glIbTrackable(globalStack(n)) = FLAG_IB_TRACKABLE)THEN

        trackableContext := globalStack(n);
      END IF;

      IF(globalInstance(n) = 1)THEN

        instantiableContext := globalStack(n);
      END IF;
     END LOOP;

     localMinString := TO_CHAR(ntMinimum(i));
     IF(localMinString IS NULL)THEN localMinString := '0'; END IF;
     localMaxString := TO_CHAR(ntMaximum(i));
     IF(localMaxString IS NULL)THEN localMaxString := '-1'; END IF;

     IF(ntVirtualFlag(i) = FLAG_NON_VIRTUAL)THEN

       vLogicLine := 'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_MIN R ' || localMinString || NewLine ||
                     'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_MAX R ' || localMaxString || NewLine ||
                     'TOTAL P_' || TO_CHAR(ntPersistentId(i)) || '_ACTUALCOUNT R 0' || NewLine;
     END IF;

     IF(localCount = 0)THEN

       --Follow the reference, doesn't affect the current LCE file.
       --Use intermediate variable instead of using NVL because this is faster.
       --Maintain the stack of references - needed to be able to detect dead-loops.

       globalLevel := globalLevel + 1;
       globalStack(globalLevel) := ntReferenceId(i);
       globalRef(globalLevel) := ntPsNodeId(i);

       --Store the information on the instantiability of the reference on the stack.

       IF(localMinString = '1' AND localMaxString = '1')THEN
         globalInstance(globalLevel) := 0;
       ELSE
         globalInstance(globalLevel) := 1;
       END IF;

       GENERATE_COMPONENT_TREE(ntReferenceId(i), ntReferenceId(i), NULL);
       globalLevel := globalLevel - 1;

       IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL AND

          --All the following verifications are to be made only if the referenced model is
          --a BOM Model - bug #2509208.

          glPsNodeType(glIndexByPsNodeId(ntReferenceId(i))) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

         errorMessage := glName(glIndexByPsNodeId(ntReferenceId(i)));

         --If this is a network container model, every reference to a trackable model should
         --have exactly minimum = 0 and maximum = -1. This validation must be made after the
         --referenced model is processed so that its IB_TRACKABLE flag has become available.
         --IB_TRACKABLE flag for the instantiably referenced model should not be null.

         IF(glIbTrackable(ntReferenceId(i)) IS NULL)THEN

           RAISE CZ_S_NO_TRACKABLE_FLAG;

         ELSIF(trackableContext = 0 AND glIbTrackable(ntReferenceId(i)) = FLAG_IB_TRACKABLE)THEN

           --This is a trackable instance model, make additional verifications.

           IF(instanceModel.EXISTS(ntReferenceId(i)) AND
              (globalLevel > 1 OR instanceModel(ntReferenceId(i)) > 1))THEN

             --Multiple occurrences of a trackable instance model. We allow them only if all
             --of them are immediate children of the container model, because they may have
             --different effectivity ranges.

             nParam := glIndexByPsNodeId(globalStack(globalLevel - 1));
             RAISE CZ_S_MULTIPLE_TRACKABLE;

           ELSIF(instantiableContext > 0)THEN

             --One of the ancestors of the trackable instance model is multiply instantiable.

             nParam := glIndexByPsNodeId(instantiableContext);
             RAISE CZ_S_MULTIPLE_INSTANCES;

           ELSIF(localMinString <> '0' OR localMaxString <> '-1')THEN

             --Incorrect instance numbers for a reference to a trackable instance model.

             RAISE CZ_S_INCORRECT_CONTAINER;

           ELSE

             instanceModel(ntReferenceId(i)) := globalLevel;
           END IF;
         END IF;

         --If the referenced model is trackable it may be a trackable leaf. However, if its
         --trackableAncestor flag exists, it has trackable children. In any case we need to
         --mark all of its ancestors and make sure their quantities are not greater than 1,
         --because the root is a container model here.

         IF(glIbTrackable(ntReferenceId(i)) = FLAG_IB_TRACKABLE OR
            trackableAncestor.EXISTS(ntReferenceId(i)))THEN

           trackableAncestor(ntPsNodeId(i)) := 1;
           PROPAGATE_TRACKABLE_ANCESTOR;
         END IF;
       END IF;
     END IF;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_CONNECTOR)THEN

     --Go and generate the connection target. At least we need to have its structure in
     --memory, but there is also a versioning problem.
     --Check for circularity.

     localCount := 0;
     trackableContext := 0;

     FOR n IN 1..globalLevel LOOP
      IF(globalStack(n) = ntReferenceId(i))THEN

        --Circularity detected.

        localCount := 1;
        EXIT;
      END IF;

      IF(glIbTrackable(globalStack(n)) = FLAG_IB_TRACKABLE)THEN

        trackableContext := globalStack(n);
      END IF;
     END LOOP;

     IF(localCount = 0)THEN

       globalLevel := globalLevel + 1;
       globalStack(globalLevel) := ntReferenceId(i);
       globalRef(globalLevel) := ntPsNodeId(i);

       --This is a connector and instantiability is not defined, but we need a value on
       --the stack.

       globalInstance(globalLevel) := 0;

       GENERATE_COMPONENT_TREE(ntReferenceId(i), ntReferenceId(i), NULL);
       globalLevel := globalLevel - 1;

       IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

         --Definition: trackable instance model is a trackable model that has no trackable
         --ancestors. In a container model no connectors to trackable instance models are
         --allowed. In other words, any connector to a trackable model in a container model
         --should be inside a trackable child of the container model.

         IF(glIbTrackable(ntReferenceId(i)) = FLAG_IB_TRACKABLE AND trackableContext = 0)THEN

           errorMessage := thisProjectName;
           nParam := glIndexByPsNodeId(ntReferenceId(i));
           RAISE CZ_S_CONNECTOR_TRACKABLE;
         END IF;

         --Inside a trackable model no connector to a non-trackable model is allowed on any
         --level in a container model.

         IF((glIbTrackable(ntReferenceId(i)) IS NULL OR glIbTrackable(ntReferenceId(i)) <> FLAG_IB_TRACKABLE) AND
            trackableContext > 0)THEN

           errorMessage := glName(glIndexByPsNodeId(ntReferenceId(i)));
           nParam := glIndexByPsNodeId(trackableContext);
           RAISE CZ_S_CONNECT_NONTRACKABLE;
         END IF;
       END IF;
     END IF;

    ELSIF(ntPsNodeType(i) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

nDebug := 1110032;

    --Run the TSO with Equipment validations before generating logic.

    IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL OR
       thisProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

      errorMessage := thisProjectName;
      thisName := ntName(i);
      parentName := '';
      IF(ntParentId(i) IS NOT NULL)THEN parentName := glName(glIndexByPsNodeId(ntParentId(i))); END IF;

      IF(ntShippableFlag(i) IS NULL OR ntTransactableFlag(i) IS NULL OR
         ntAtoFlag(i) IS NULL OR ntSerializableFlag(i) IS NULL) THEN

       --'The BOM Model ''%MODELNAME'' is out of date. Please refresh the Model by running the Refresh a Single
       -- Configuration Model concurrent program and then regenerate the Active Model.'

       RAISE CZ_LCE_MODEL_OUTOFDATE;
      END IF; --The new flags are null, need to refresh.

      IF((ntPsNodeType(i) IN (PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_MODEL)) AND
         (ntShippableFlag(i) = '1' OR ntTransactableFlag(i) = '1'))THEN

       --'Incorrect BOM Model or Option Class ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
       -- Only BOM Standard Items can be shippable and inventory transactable.'

       RAISE CZ_LCE_INCORRECT_BOM;
      END IF; --Flags are set for a non-Standard item node.

      IF(ntPsNodeType(i) = PS_NODE_TYPE_BOM_STANDARD)THEN
        IF(ntShippableFlag(i) <> ntTransactableFlag(i))THEN

          --'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
          -- All shippable items should be inventory transactable and vice versa.'

          RAISE CZ_LCE_INCORRECT_ITEM;
        END IF; -- ntShippableFlag <> ntTransactableFlag.

        IF(ntShippableFlag(i) = '1' AND ((ntAtoFlag(i) <> '0') OR (NVL(ntIbTrackable(i), '0') <> '1')))THEN

       --'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
       -- All shippable items should be trackable non-ATO standard items with maximum quantity 1.'

          RAISE CZ_LCE_INCORRECT_TANGIBLE;
        END IF; --ntShippableFlag = '1'.

        IF(ntShippableFlag(i) = '1' AND ntSerializableFlag(i) = '0')THEN

          --'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
          -- All shippable items should be serializable trackable non-ATO standard items.'

          RAISE CZ_LCE_INCORRECT_SHIPPABLE;
        END IF; --ntShippableFlag = '1' AND ntSerializableFlag = '0';
      END IF; --Standard Item.
    END IF; --MACD Container.

nDebug := 1110033;

     --Generate header.

     vLogicLine := 'BOM P_' || TO_CHAR(ntPersistentId(i)) || ' R ';

     --BOM modifier.

     IF(ntPsNodeType(i) = PS_NODE_TYPE_BOM_STANDARD)THEN
       vLogicLine := vLogicLine || 'S';
     ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_BOM_OPTIONCLASS)THEN
       vLogicLine := vLogicLine || 'O';
     ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_BOM_MODEL)THEN
       vLogicLine := vLogicLine || 'M';

       --This is a BOM model, it can be only the root model, so that thisProjectType and
       --thisProjectName are currently referring to it.

       IF(ntIbTrackable(i) = FLAG_IB_TRACKABLE AND thisProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

         --A network container model should not be trackable.

         errorMessage := thisProjectName;
         RAISE CZ_S_TRACKABLE_CONTAINER;
       END IF;
     ELSE

       --'Unknown BOM node type, node ''%NODENAME'''
       errorMessage := CZ_UTILS.GET_TEXT('CZ_S_UNKNOWN_BOM_NODE_TYPE', 'NODENAME', ntName(i));
       RAISE CZ_S_UNKNOWN_BOM_NODE_TYPE;
     END IF;

     IF(ntPsNodeType(i) IN (PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD) AND
        glIbTrackable(ntPsNodeId(i)) = FLAG_IB_TRACKABLE)THEN

       --Trackable Standard Items/Option Classes are not allowed as immediate children of a
       --network container model.

       IF(thisProjectType = MODEL_TYPE_CONTAINER_MODEL AND
          glPsNodeType(glIndexByPsNodeId(ntParentId(i))) = PS_NODE_TYPE_BOM_MODEL)THEN

         errorMessage := thisProjectName;
         nParam := glIndexByPsNodeId(ntPsNodeId(i));
         RAISE CZ_S_TRACKABLE_CHILDREN;
       END IF;

       --As this is a trackable Standard Item or Option Class we need to mark all of its
       --ancestors and make sure their quantities are not greater than 1, if the root is
       --a container model.

       IF(rootProjectType = MODEL_TYPE_CONTAINER_MODEL)THEN

         PROPAGATE_TRACKABLE_ANCESTOR;

         --If the item is tangible, we should prohibit not only its ancestors but also itself
         --from being on the RHS of numeric rules - TSO with Equipment.

         IF(ntShippableFlag(i) = '1')THEN trackableAncestor(ntPsNodeId(i)) := 2; END IF;
       END IF;
     END IF;

     --Add the decimal quantity modifier if necessary

     IF(ntDecimalQty(i) = FLAG_DECIMAL_QTY)THEN
      vLogicLine := vLogicLine || 'D';
     END IF;

nDebug := 1110034;

     --BOM required flag + minimum which is always 0

     IF(ntBomRequired(i) = FLAG_BOM_REQUIRED)THEN
      vLogicLine := vLogicLine || ' RC 0 ';
     ELSE
      vLogicLine := vLogicLine || ' NRC 0 ';
     END IF;

nDebug := 1110035;

     --Maximum selected

     IF(ntMaximumSel(i) IS NOT NULL)THEN
      vLogicLine := vLogicLine || TO_CHAR(ntMaximumSel(i)) || ' ';
     ELSE
      vLogicLine := vLogicLine || '-1 ';
     END IF;

nDebug := 1110036;

     --Parent 'logic' name if any

     IF(ntParentId(i) IS NOT NULL AND
        glPsNodeType(glIndexByPsNodeId(ntParentId(i))) IN (PS_NODE_TYPE_BOM_MODEL, PS_NODE_TYPE_BOM_OPTIONCLASS, PS_NODE_TYPE_BOM_STANDARD))THEN

      --Fix for the bug #1745394. If a BOM parent is of decimal quantity and it's child is of
      --integer quantity, fatal error will be raised.

      IF(glDecimalQty(ntParentId(i)) = FLAG_DECIMAL_QTY AND ntDecimalQty(i) = FLAG_INTEGER_QTY)THEN

       --'Node ''%CHILDNAME'' must allow decimal quantity since its parent ''%PARENTNAME'' allows decimal quantity'
       errorMessage := CZ_UTILS.GET_TEXT('CZ_S_INCONSISTENT_QUANTITY', 'CHILDNAME', ntName(i),
                                                                       'PARENTNAME', glName(glIndexByPsNodeId(ntParentId(i))));
        RAISE CZ_S_INCONSISTENT_QUANTITY;
      END IF;

      vLogicLine := vLogicLine || 'P_' || TO_CHAR(glPersistentId(ntParentId(i))) || ' ';
     END IF;

nDebug := 1110037;

     --Default quantity. If initial_value is not null and can't be converted to
     --a number the VALUE_ERROR exception will be raised. We catch this one and
     --re-raise our own exception for better reporting.

     BEGIN
      IF(ntInitialValue(i) IS NOT NULL AND TO_NUMBER(ntInitialValue(i)) > 0)THEN
       vLogicLine := vLogicLine || ntInitialValue(i) || ' ... ' || ntDescriptionId(i) || NewLine;
      ELSE
       vLogicLine := vLogicLine || '0' || ' ... ' || ntDescriptionId(i) || NewLine;
      END IF;
     EXCEPTION
       WHEN VALUE_ERROR THEN
         RAISE CZ_S_WRONG_INITIAL_VALUE;
     END;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_FEATUREGROUP)THEN

     NULL;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_COMPONENT)THEN

     NULL;

    ELSIF(ntPsNodeType(i) = PS_NODE_TYPE_PRODUCT)THEN

     NULL;

    ELSE

     --'Unknown node type, node ''%NODENAME'''
     errorMessage := CZ_UTILS.GET_TEXT('CZ_S_UNKNOWN_NODE_TYPE', 'NODENAME', ntName(i));
     RAISE CZ_S_UNKNOWN_NODE_TYPE;
    END IF;
    END IF; --End of the IF block of 'if logic does not already exist' inside the main loop

  --This exception handler may be used to catch the 'logic item'-level exceptions
  --that shouldn't stop the process. If an exception is re-raised here it becomes
  --a fatal exception (warning vs. errors).

   EXCEPTION
     WHEN CZ_S_BAD_BOOLEAN_FEAT_VALUE THEN
--'Bad boolean feature value, feature ''%FEATNAME'''
       REPORT(CZ_UTILS.GET_TEXT('CZ_S_BAD_BOOLEAN_FEAT_VALUE', 'FEATNAME', ntName(i)), 1);
     WHEN CZ_S_FEATURE_NO_CHILDREN THEN
--'Option feature has no children, feature ''%FEATNAME'''
       REPORT(CZ_UTILS.GET_TEXT('CZ_S_FEATURE_NO_CHILDREN', 'FEATNAME', ntName(i)), 1);
     WHEN CZ_S_ILLEGAL_OPTION_FEATURE THEN
--'Feature ''%FEATNAME'' has no options or fewer options than its minimum count, feature ''%FEATNAME'''
       REPORT(CZ_UTILS.GET_TEXT('CZ_S_ILLEGAL_OPTION_FEATURE', 'FEATNAME', ntName(j)), 1);
     WHEN CZ_S_WRONG_INITIAL_VALUE THEN
--'Initial value of BOM node is not null and can not be converted to number, node ''%NODENAME'''
       REPORT(CZ_UTILS.GET_TEXT('CZ_S_WRONG_INITIAL_VALUE', 'NODENAME', ntName(i)), 1);

  --Fatal exceptions section. Exceptions are re-raised to be reported at the higher level.

     WHEN CZ_S_DEADLOOP_DETECTED THEN --Currently never thrown.
--As per bug #3593513, when thrown should probably be moved to the place where thrown. Otherwise going up from
--the recursion overwites the message substituting incorrect names.

--'An infinite loop detected: models ''%MODELNAME'' and ''%CHILDNAME'' reference each other'
       errorMessage := CZ_UTILS.GET_TEXT('CZ_S_DEADLOOP_DETECTED', 'MODELNAME', glName(glIndexByPsNodeId(globalStack(globalLevel))),
                                                                   'CHILDNAME', glName(glIndexByPsNodeId(globalStack(nParam))));
       RAISE;
   END;

   --This procedure implements wrapping. A call to it is included in options list generation
   --for an option feature above

   PACK;

nDebug := 1110040;

   IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN

     --generatingFeature is set to 1 when we step over an option feature with actual options. It will
     --be unset when we finally generate the feature after all of its options. But while generating
     --the options we want to call this procedure for every of them. This is why we check the type
     --and if it is an option, call the procedure even though the flag is set.

     IF(generatingFeature = 0 OR ntPsNodeType(i) = PS_NODE_TYPE_OPTION)THEN GENERATE_ACCUMULATOR(i); END IF;
   END IF;

   --Increase the main cycle counter

   i := i + 1;

  END LOOP; --End of the main structure generation cycle

nDebug := 1110038;

  ELSE --IF 'there is some data returned'

    --The project is empty, stop here.

    errorMessage := thisProjectName;
    RAISE CZ_S_NO_DATA_IN_PROJECT;

  END IF; --Ends the ELSE block of IF 'there is some data returned'

  IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN

   --Flush the buffer

   IF(vLogicText IS NOT NULL)THEN
    INSERT INTO cz_lce_texts (lce_header_id, seq_nbr, lce_text) VALUES
     (nStructureHeaderId, nSequenceNbr, vLogicText);
    vLogicText := NULL;
   END IF;

   --Remember the next sequence number for this logic file. Will be used in
   --numeric rules generation for accumulators.

   vSeqNbrByHeader(nStructureHeaderId) := nSequenceNbr + 1;

   IF(TwoPhaseCommit = 0)THEN COMMIT; END IF;
  END IF;

nDebug := 1110039;

  --If a model, generate rules and set the logic generated flag.

  IF(inParentLogicHeaderId IS NULL)THEN

    --Generate model's rules and expressions if necessary

    IF(NOT IsLogicGenerated.EXISTS(inComponentId))THEN
      GENERATE_RULES;
      IsLogicGenerated(inComponentId) := 1;
    END IF;
  END IF;
END; --GENERATE_COMPONENT_TREE
---------------------------------------------------------------------------------------
PROCEDURE COMMIT_HEADERS IS
  localOldHeaders  tIntegerArray;
  nCount           PLS_INTEGER := 1;
  localComponent   NUMBER := NULL; --kdande; Bug 6881902; 11-Mar-2008
BEGIN

   FOR i IN 1..NewHeaders.COUNT LOOP
    IF(((NOT IsLogicGenerated.EXISTS(NewHeadersComponents(i))) OR IsLogicGenerated(NewHeadersComponents(i)) = 1) AND
       (localComponent IS NULL OR NewHeadersComponents(i) <> localComponent))THEN

      localOldHeaders.DELETE;

      SELECT lce_header_id BULK COLLECT INTO localOldHeaders FROM cz_lce_headers
       WHERE deleted_flag = FLAG_NOT_DELETED
         AND devl_project_id = NewHeadersComponents(i);

      FOR j IN 1..localOldHeaders.COUNT LOOP
        OldHeaders(nCount) := localOldHeaders(j);
        nCount := nCount + 1;
      END LOOP;

      localComponent := NewHeadersComponents(i);
    END IF;
   END LOOP;

   FORALL i IN 1..OldHeaders.COUNT
    UPDATE cz_lce_headers SET deleted_flag = FLAG_DELETED
     WHERE lce_header_id = OldHeaders(i);

   FORALL i IN 1..OldHeaders.COUNT
    UPDATE cz_lce_load_specs SET deleted_flag = FLAG_DELETED
     WHERE lce_header_id = OldHeaders(i);

   FORALL i IN 1..NewHeaders.COUNT
    UPDATE cz_lce_headers SET deleted_flag = FLAG_NOT_DELETED
     WHERE lce_header_id = NewHeaders(i);

   FORALL i IN 1..NewHeaders.COUNT
    UPDATE cz_lce_load_specs SET deleted_flag = FLAG_NOT_DELETED
     WHERE lce_header_id = NewHeaders(i);

   cz_security_pvt.unlock_model(1.0, FND_API.G_TRUE, l_locked_models, l_lock_status, l_msg_count, l_msg_data);

   IF(l_lock_status <> FND_API.G_RET_STS_SUCCESS)THEN
     FOR jmessage IN 1..l_msg_count LOOP
       REPORT(fnd_msg_pub.get(jmessage, FND_API.G_FALSE), 0);
     END LOOP;
   END IF;

   IF(TwoPhaseCommit = 0)THEN COMMIT; END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE ROLLBACK_HEADERS IS
BEGIN

   FORALL i IN 1..NewHeaders.COUNT
    UPDATE cz_lce_headers SET deleted_flag = FLAG_DELETED
     WHERE lce_header_id = NewHeaders(i);

   FORALL i IN 1..NewHeaders.COUNT
    UPDATE cz_lce_load_specs SET deleted_flag = FLAG_DELETED
     WHERE lce_header_id = NewHeaders(i);

   IF(OldHeaders.COUNT > 0)THEN

     FORALL i IN 1..OldHeaders.COUNT
      UPDATE cz_lce_headers SET deleted_flag = FLAG_NOT_DELETED
       WHERE lce_header_id = OldHeaders(i);

     FORALL i IN 1..OldHeaders.COUNT
      UPDATE cz_lce_load_specs SET deleted_flag = FLAG_NOT_DELETED
       WHERE lce_header_id = OldHeaders(i);
   END IF;

   cz_security_pvt.unlock_model(1.0, FND_API.G_TRUE, l_locked_models, l_lock_status, l_msg_count, l_msg_data);

   IF(l_lock_status <> FND_API.G_RET_STS_SUCCESS)THEN
     FOR jmessage IN 1..l_msg_count LOOP
       REPORT(fnd_msg_pub.get(jmessage, FND_API.G_FALSE), 0);
     END LOOP;
   END IF;

   IF(TwoPhaseCommit = 0)THEN COMMIT; END IF;

EXCEPTION
  WHEN OTHERS THEN
--'Fatal error. Logic header maintainance not completed. Unable to rollback changes because of %ERRORTEXT'
    REPORT(CZ_UTILS.GET_TEXT('CZ_G_UNABLE_TO_ROLLBACK', 'ERRORTEXT', SQLERRM), 0);
END;
---------------------------------------------------------------------------------------
FUNCTION CHECK_DATES(inModelId IN NUMBER, inLogicUpdate IN DATE, inHeaderCreated IN DATE)
RETURN PLS_INTEGER IS

  c_model             refCursor;
  childFlag           PLS_INTEGER;
  thisFlag            PLS_INTEGER := GENERATION_NOT_REQUIRED;
  childModelId        cz_devl_projects.devl_project_id%TYPE;
  childLogicUpdate    cz_devl_projects.last_logic_update%TYPE;
  childHeaderCreated  cz_lce_headers.creation_date%TYPE;

BEGIN

  IF(NOT modelChecked.EXISTS(inModelId))THEN

    modelChecked(inModelId) := 1;

    OPEN c_model FOR logicSQL USING inModelId;
    LOOP
      FETCH c_model INTO childModelId, childLogicUpdate, childHeaderCreated;
      EXIT WHEN c_model%NOTFOUND;

      childFlag := CHECK_DATES(childModelId, childLogicUpdate, childHeaderCreated);

      IF(thisFlag = GENERATION_NOT_REQUIRED AND
         (childFlag = GENERATION_REQUIRED OR inHeaderCreated < childLogicUpdate))THEN
        thisFlag := GENERATION_REQUIRED;
      END IF;
    END LOOP;
    CLOSE c_model;
  END IF;

  IF(thisFlag = GENERATION_NOT_REQUIRED AND inHeaderCreated < inLogicUpdate)THEN
    thisFlag := GENERATION_REQUIRED;
  END IF;

  IF(thisFlag = GENERATION_NOT_REQUIRED)THEN
    IsLogicGenerated(inModelId) := 0;
  END IF;
 RETURN thisFlag;
END;
---------------------------------------------------------------------------------------
BEGIN --GENERATE_LOGIC_

    --Bug #4587682. Save current nls numeric characters and set the standard characters.

    SELECT value INTO StoreNlsCharacters FROM NLS_SESSION_PARAMETERS
     WHERE UPPER(parameter) = 'NLS_NUMERIC_CHARACTERS';

    SET_NLS_CHARACTERS(NlsNumericCharacters);

BEGIN

  --Database settings processing section

  BEGIN

    --Get the commit block size - the number of records inserted into cz_lce_texts
    --after which the transaction is commited, if commit is not disabled at all by
    --TwoPhaseCommit parameter set to 1.

    SELECT TO_NUMBER(value) INTO CommitBlockSize
      FROM cz_db_settings
     WHERE LOWER(setting_id) = COMMIT_BLOCK_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

    IF(CommitBlockSize <= 0) THEN CommitBlockSize := DEFAULT_COMMIT_BLOCK_SIZE; END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CommitBlockSize := DEFAULT_COMMIT_BLOCK_SIZE;
  END;

/*  Making the optimizations unconditional, cz_db_settings ignored.
  BEGIN

    --Get the NotTrue optimization flag, no optimization by default.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                0) --default value
      INTO OptimizeNotTrue
      FROM cz_db_settings
     WHERE LOWER(setting_id) = OPTIMIZE_NOTTRUE_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      OptimizeNotTrue := 0;
  END;

  BEGIN

    --Get the AllOf/AnyOf optimization flag, no optimization by default.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                0) --default value
      INTO OptimizeAllAnyOf
      FROM cz_db_settings
     WHERE LOWER(setting_id) = OPTIMIZE_ALLANYOF_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      OptimizeAllAnyOf := 0;
  END;

  BEGIN

    --Get the Change Children Order flag, no change by default.
    --Currently will change children order when generating AllOf/AnyOf.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                0) --default value
      INTO ChangeChildrenOrder
      FROM cz_db_settings
     WHERE LOWER(setting_id) = CHILDREN_ORDER_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      ChangeChildrenOrder := 0;
  END;
*/

  --Enable all three optimizations here ignoring cz_db_settings.

  OptimizeNotTrue := 1;
  OptimizeAllAnyOf := 1;
  ChangeChildrenOrder := 1;

  BEGIN

    --See if we want to generate gated combinations, yes by default.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                1) --default value
      INTO GenerateGatedCombo
      FROM cz_db_settings
     WHERE LOWER(setting_id) = GATED_COMBO_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      GenerateGatedCombo := 1;
  END;

  BEGIN

    --See if we want to stop when a fatal rule error is encountered, yes by default.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                1) --default value
      INTO StopOnFatalRuleError
      FROM cz_db_settings
     WHERE LOWER(setting_id) = STOP_ON_ERROR_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      StopOnFatalRuleError := 1;
  END;

  BEGIN

    --See if we want to generate logic only for updated models, yes by default.

    SELECT DECODE(LOWER(value), '1', 1, 'on',  1, 'y', 1, 'yes', 1,'true',  1, 'enable',  1,
                                '0', 0, 'off', 0, 'n', 0, 'no',  0,'false', 0, 'disable', 0,
                                1) --default value
      INTO GenerateUpdatedOnly
      FROM cz_db_settings
     WHERE LOWER(setting_id) = UPDATED_ONLY_SETTING_ID
       AND LOWER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      GenerateUpdatedOnly := 1;
  END;

  --Get the logic generation run id. If a valid value has been passed as a parameter, use it,
  --else generate a new value.

  IF(thisRunId IS NULL OR thisRunId = 0)THEN
    SELECT cz_xfr_run_infos_s.NEXTVAL INTO thisRunId FROM DUAL;
  END IF;

  --Read the cz_effectivity_sets table into memory and create hash tables for
  --effectivity dates

  SELECT effectivity_set_id, effective_from, effective_until
  BULK COLLECT INTO gvSetId, gvEffFrom, gvEffUntil
    FROM cz_effectivity_sets
   WHERE deleted_flag = FLAG_NOT_DELETED;

  --Add the indexing option

  IF(gvSetId.LAST IS NOT NULL)THEN
   FOR i IN gvSetId.FIRST..gvSetId.LAST LOOP
    gvIndexBySetId(gvSetId(i)) := i;
   END LOOP;
  END IF;

  --This block is introduced to implement locking.

  BEGIN

    l_locked_models.DELETE;
    cz_security_pvt.lock_model(1.0, inDevlProjectId, FND_API.G_TRUE, FND_API.G_TRUE, l_locked_models, l_lock_status, l_msg_count, l_msg_data);

    IF(l_lock_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FAILED_TO_LOCK_MODEL;
    END IF;

    --To disable this functionality, comment out the following IF block. Previously, we
    --could not correctly handle accumulators and NOTTRUE operator, for which we needed
    --to modify a child structure file even if it was up-to-date.

    --Pre-populate the list of models that don't need to be regenerated because logic exists
    --and satisfies the 'up-to-date' criterion. Part of the fix for the bug #1941626.
    --For debugging purposes it may be convenient to be able to regenerate logic without any
    --dependency on the dates - the old way. A db setting is provided for that.

    IF(GenerateUpdatedOnly = 1)THEN

      --Have to always generate logic for the root model because the trigger updating
      --last_logic_update column is commented out on cz_expression_nodes, and this is
      --the only table Developer updates for some rule changes.
      --This is why we do not care about the return value and pass the margin reverse
      --dates.

      nParam := CHECK_DATES(inDevlProjectId, EpochEndDate, EpochBeginDate);
    END IF;

    globalLevel := globalLevel + 1;
    globalStack(globalLevel) := inDevlProjectId;
    globalRef(globalLevel) := inDevlProjectId;
    globalInstance(globalLevel) := 0;

    --Start off the recursion

    GENERATE_COMPONENT_TREE(inDevlProjectId, inDevlProjectId, NULL);

    --LCE header maintainance

    COMMIT_HEADERS;

  EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN

       FOR jmessage IN 1..l_msg_count LOOP
         REPORT(fnd_msg_pub.get(jmessage, FND_API.G_FALSE), 0);
       END LOOP;

       ROLLBACK_HEADERS;
    WHEN OTHERS THEN
      RAISE;
  END;

--Handle here the exceptions that should terminate the logic tree generation process.

EXCEPTION
  WHEN CZ_S_UNABLE_TO_CREATE_HEADER THEN
--'Unable to create logic header because of %ERRORTEXT'
    REPORT(CZ_UTILS.GET_TEXT('CZ_G_UNABLE_TO_CREATE_HEADER', 'ERRORTEXT', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_R_UNABLE_TO_CREATE_HEADER THEN
--'Unable to create logic header because of %ERRORTEXT'
    REPORT(CZ_UTILS.GET_TEXT('CZ_G_UNABLE_TO_CREATE_HEADER', 'ERRORTEXT', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_DEADLOOP_DETECTED THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_UNKNOWN_FEATURE_TYPE THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_UNKNOWN_NODE_TYPE THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_UNKNOWN_BOM_NODE_TYPE THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_TOO_MANY_OPTIONS THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_WRONG_EFFECTIVITY_SET THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_INCONSISTENT_QUANTITY THEN
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_INCORRECT_QUANTITY THEN
--'BOM item ''%ITEMNAME'' cannot have default quantity greater than 1 because it contains other trackable BOM items.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_INCORRECT_QUANTITY', 'ITEMNAME', glName(nParam)), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_TRACKABLE_CHILDREN THEN
--'Invalid Model structure: ''%CHILDNAME'' is a direct child of ''%MODELNAME''. A trackable BOM item cannot be a direct child of a Container Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_TRACKABLE_CHILDREN', 'CHILDNAME', glName(nParam), 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_TRACKABLE_STANDARD THEN
--'Invalid Model structure: ''%CHILDNAME'' is a direct child of ''%MODELNAME''. A trackable Standard Item cannot be
-- a direct child of a non-trackable ATO or PTO BOM Model that is referenced by a Container Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_TRACKABLE_STANDARD', 'CHILDNAME', glName(nParam), 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_MULTIPLE_TRACKABLE THEN
--'Invalid Model structure: Multiple references exist to the trackable instance ''%CHILDNAME''.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_MULTIPLE_TRACKABLE', 'CHILDNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_MULTIPLE_INSTANCES THEN
--'Invalid Model structure: The non-trackable Model ''%MODELNAME'' cannot have multiple instances because it is not a descendent of a trackable Model and it
-- contains the trackable Model ''%CHILDNAME''. Please set both the Instances Minimum and Maximum fields for ''%MODELNAME'' to 1.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_MULTIPLE_INSTANCES', 'CHILDNAME', errorMessage, 'MODELNAME', glName(nParam)), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_CONNECT_NONTRACKABLE THEN
--'Invalid Connector: Connector to non-trackable Model ''%CHILDNAME'' from the trackable Model ''%MODELNAME''. A Connector from a non-trackable Model
-- to a trackable Model is not allowed in a Container Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_CONNECT_NONTRACKABLE', 'CHILDNAME', errorMessage, 'MODELNAME', glName(nParam)), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_CONTAINER_REFERENCE THEN
--'Invalid Reference: Model ''%MODELNAME'' references the Model ''%CHILDNAME''. A Container Model cannot reference another Container Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_CONTAINER_REFERENCE', 'CHILDNAME', errorMessage, 'MODELNAME', rootProjectName), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_CONNECTOR_TRACKABLE THEN
--'The Connector from ''%MODELNAME'' to the trackable Model ''%CHILDNAME'' is not allowed because no ancestor of ''%MODELNAME'' is trackable.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_CONNECTOR_TRACKABLE', 'CHILDNAME', glName(nParam), 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_INCORRECT_CONTAINER THEN
--'The Reference to trackable Model ''%CHILDNAME'' in the Container Model ''%MODELNAME'' has an invalid number
-- of Instances specified. Please set Minimum Instances to 0 and Maximum Instances to Null for this node,
-- then regenerate the Active Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_INCORRECT_CONTAINER', 'CHILDNAME', errorMessage, 'MODELNAME', rootProjectName), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_NO_TRACKABLE_FLAG THEN
--'Trackable status is undefined for the Model ''%CHILDNAME'' in the Container Model ''%MODELNAME''.
-- Please refresh the Model by running the Refresh a Single Configuration Model concurrent program
-- and then regenerate the Active Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_NO_TRACKABLE_FLAG', 'CHILDNAME', errorMessage, 'MODELNAME', rootProjectName), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_NO_DATA_IN_PROJECT THEN
--'Project ''%PROJECTNAME'' contains no data, no logic generated'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_NO_DATA_IN_PROJECT', 'PROJECTNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_NO_SUCH_PROJECT THEN
--'Project does not exist for the specified ID: %PROJECTID. No logic generated.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_NO_SUCH_PROJECT', 'PROJECTID', nParam), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_S_TRACKABLE_CONTAINER THEN
--'Error in Model ''%PROJECTNAME'': A trackable Model cannot be a Container Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_S_TRACKABLE_CONTAINER', 'PROJECTNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_LCE_MODEL_OUTOFDATE THEN
--'The BOM Model ''%MODELNAME'' is out of date. Please refresh the Model by running the Refresh a Single
-- Configuration Model concurrent program and then regenerate the Active Model.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_MODEL_OUTOFDATE', 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_LCE_INCORRECT_BOM THEN
--'Incorrect BOM Model or Option Class ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
-- Only BOM Standard Items can be shippable and inventory transactable.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_BOM', 'NODENAME', thisName, 'PARENTNAME', parentName, 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_LCE_INCORRECT_ITEM THEN
--'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
-- All shippable items should be inventory transactable and vice versa.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_ITEM', 'NODENAME', thisName, 'PARENTNAME', parentName, 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_LCE_INCORRECT_TANGIBLE THEN
--'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
-- All shippable items should be trackable non-ATO standard items with maximum quantity 1.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_TANGIBLE', 'NODENAME', thisName, 'PARENTNAME', parentName, 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_LCE_INCORRECT_SHIPPABLE THEN
--'Incorrect BOM Standard Item ''%NODENAME'' with parent ''%PARENTNAME'' in BOM Model ''%MODELNAME''.
-- All shippable items should be serializable trackable non-ATO standard items.'
    REPORT(CZ_UTILS.GET_TEXT('CZ_LCE_INCORRECT_SHIPPABLE', 'NODENAME', thisName, 'PARENTNAME', parentName, 'MODELNAME', errorMessage), 0);
    ROLLBACK_HEADERS;
  WHEN CZ_G_INVALID_RULE_EXPLOSION THEN
--'Internal data error. Unable to continue because of invalid data in rule ''%RULENAME''. Disable or delete the rule to generate logic.'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_INVALID_RULE_EXPLOSION', 'RULENAME', errorMessage);
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_G_INVALID_MODEL_EXPLOSION THEN
--'Internal data error. Unable to continue because of invalid data in model ''%MODELNAME'' - loop detected.'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_INVALID_MODEL_EXPLOSION', 'MODELNAME', errorMessage);
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN CZ_G_INVALID_EXPLOSION_TYPE THEN
--'Internal data error. Unable to continue because of invalid data in the model ''%MODELNAME'' - incorrect explosion type.'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_INVALID_EXPLOSION_TYPE', 'MODELNAME', errorMessage);
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
  WHEN OTHERS THEN
    IF(nDebug = 1 OR (nDebug >= 1000001 AND nDebug <= 1000011))THEN
--'Unable to continue because of %ERRORTEXT. Reference explosions table may not be populated properly for model ''%MODELNAME'''
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_ERROR_IN_EXPLOSION', 'ERRORTEXT', SQLERRM, 'MODELNAME', glName(glIndexByPsNodeId(inDevlProjectId)));
    ELSIF(nDebug >= 40 AND nDebug <= 54)THEN
--'Internal data error. Unable to continue because of invalid data in rule ''%RULENAME''. Disable or delete the rule to generate logic.'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_INVALID_RULE_EXPLOSION', 'RULENAME', errorMessage);
    ELSIF(SUBSTR(TO_CHAR(nDebug), 1, 1) = '8')THEN
--'Unable to continue because of %ERRORTEXT: (nRuleId)'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_GENERAL_ERROR', 'ERRORTEXT', SQLERRM || ': (' || errorMessage || ')');
    ELSE
--'Unable to continue because of %ERRORTEXT'
     errorMessage := CZ_UTILS.GET_TEXT('CZ_G_GENERAL_ERROR', 'ERRORTEXT', SQLERRM);
    END IF;
    REPORT(errorMessage, 0);
    ROLLBACK_HEADERS;
END;

 --Bug #4587682. Restore the session's nls numeric characters.

 SET_NLS_CHARACTERS(StoreNlsCharacters);

EXCEPTION
  WHEN OTHERS THEN
    SET_NLS_CHARACTERS(StoreNlsCharacters);
    RAISE;
END; --GENERATE_MODEL_TREE
---------------------------------------------------------------------------------------
--An additional entry point for those callers who cannot handle defaulted parameters---

PROCEDURE GENERATE_LOGIC(inDevlProjectId IN NUMBER,
                         thisRunId       IN OUT NOCOPY NUMBER)
IS

  l_config_engine_type   cz_devl_projects.config_engine_type%TYPE;
  l_fusion_debug         VARCHAR2(240);

BEGIN

  BEGIN

    SELECT config_engine_type INTO l_config_engine_type
      FROM cz_devl_projects
     WHERE deleted_flag = FLAG_NOT_DELETED
       AND devl_project_id = inDevlProjectId;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_config_engine_type := 'L';
  END;

  IF ( l_config_engine_type = 'F') THEN

    l_fusion_debug := NVL ( fnd_profile.value_wnps ('CZ_DEV_FCE_DEBUG_LOGIC'), 'N');

    IF ( l_fusion_debug = 'N' ) THEN

      cz_fce_compile.compile_logic ( inDevlProjectId,  thisRunId );

    ELSE

      cz_fce_compile.debug_logic ( inDevlProjectId,  thisRunId );

    END IF;

  ELSE

    GENERATE_LOGIC_(inDevlProjectId, thisRunId, 0);

  END IF;
END;
---------------------------------------------------------------------------------------
--This entry makes the logic generation work remotely in a distributed transaction,even
--if the model contains property-based compatibility rules - bug #2028790.
--DDL used in the property-based compatibility rules makes implicit commits and commits
--are not allowed in a distributed transaction when the remote procedure has parameters
--of type OUT.

PROCEDURE GENERATE_LOGIC__(inDevlProjectId IN NUMBER,
                           thisRunId       IN NUMBER)
IS
  outRunId  NUMBER := thisRunId;
BEGIN
  GENERATE_LOGIC_(inDevlProjectId, outRunId, 1);
END;
---------------------------------------------------------------------------------------
BEGIN

  OperatorLiterals(OPERATOR_ADD)                := ' + ';
  OperatorLiterals(OPERATOR_SUB)                := ' - ';
  OperatorLiterals(OPERATOR_MULT)               := ' * ';
  OperatorLiterals(OPERATOR_DIV)                := ' / ';
  OperatorLiterals(OPERATOR_EQUALS)             := ' = ';
  OperatorLiterals(OPERATOR_NOTEQUALS)          := ' != ';
  OperatorLiterals(OPERATOR_GT)                 := ' > ';
  OperatorLiterals(OPERATOR_LT)                 := ' < ';
  OperatorLiterals(OPERATOR_GE)                 := ' >= ';
  OperatorLiterals(OPERATOR_LE)                 := ' <= ';
  OperatorLiterals(OPERATOR_ADD_INT)            := ' + ';
  OperatorLiterals(OPERATOR_SUB_INT)            := ' - ';
  OperatorLiterals(OPERATOR_MULT_INT)           := ' * ';
  OperatorLiterals(OPERATOR_EQUALS_INT)         := ' = ';
  OperatorLiterals(OPERATOR_NOTEQUALS_INT)      := ' != ';
  OperatorLiterals(OPERATOR_GT_INT)             := ' > ';
  OperatorLiterals(OPERATOR_LT_INT)             := ' < ';
  OperatorLiterals(OPERATOR_GE_INT)             := ' >= ';
  OperatorLiterals(OPERATOR_LE_INT)             := ' <= ';
  OperatorLiterals(OPERATOR_POW_INT)            := ' POW ';
  OperatorLiterals(OPERATOR_ROUND)              := ' ROUND ';
  OperatorLiterals(OPERATOR_CEILING)            := ' CEILING ';
  OperatorLiterals(OPERATOR_FLOOR)              := ' FLOOR ';
  OperatorLiterals(OPERATOR_TRUNCATE)           := ' TRUNCATE ';
  OperatorLiterals(OPERATOR_MIN)                := ' MIN ';
  OperatorLiterals(OPERATOR_MAX)                := ' MAX ';
  OperatorLiterals(OPERATOR_AND)                := ' AND ';
  OperatorLiterals(OPERATOR_OR)                 := ' OR ';
  OperatorLiterals(OPERATOR_NOT)                := ' NOT ';
  OperatorLiterals(OPERATOR_NOTTRUE)            := ' NOTTRUE ';
  OperatorLiterals(OPERATOR_COS)                := ' COS ';
  OperatorLiterals(OPERATOR_ACOS)               := ' ACOS ';
  OperatorLiterals(OPERATOR_COSH)               := ' COSH ';
  OperatorLiterals(OPERATOR_SIN)                := ' SIN ';
  OperatorLiterals(OPERATOR_ASIN)               := ' ASIN ';
  OperatorLiterals(OPERATOR_SINH)               := ' SINH ';
  OperatorLiterals(OPERATOR_TAN)                := ' TAN ';
  OperatorLiterals(OPERATOR_ATAN)               := ' ATAN ';
  OperatorLiterals(OPERATOR_TANH)               := ' TANH ';
  OperatorLiterals(OPERATOR_LOG)                := ' LOG ';
  OperatorLiterals(OPERATOR_LOG10)              := ' LOG10 ';
  OperatorLiterals(OPERATOR_EXP)                := ' EXP ';
  OperatorLiterals(OPERATOR_ABS)                := ' ABS ';
  OperatorLiterals(OPERATOR_SQRT)               := ' SQRT ';
  OperatorLiterals(OPERATOR_MATHDIV)            := ' DIV ';
  OperatorLiterals(OPERATOR_POW)                := ' POW ';
  OperatorLiterals(OPERATOR_ATAN2)              := ' ATAN2 ';
  OperatorLiterals(OPERATOR_MOD)                := ' MOD ';
  OperatorLiterals(OPERATOR_ROUNDTONEAREST)     := ' ROUND ';
  OperatorLiterals(OPERATOR_ROUNDUPTONEAREST)   := ' CEILING ';
  OperatorLiterals(OPERATOR_ROUNDDOWNTONEAREST) := ' FLOOR ';
  OperatorLiterals(OPERATOR_ALLOF)              := ' All True ';
  OperatorLiterals(OPERATOR_ANYOF)              := ' Any True ';
  OperatorLiterals(OPERATOR_NONE)               := ' ';

  OperatorLetters(OPERATOR_AND)                 := ' L ';
  OperatorLetters(OPERATOR_OR)                  := ' N ';
  OperatorLetters(OPERATOR_ALLOF)               := ' L ';
  OperatorLetters(OPERATOR_ANYOF)               := ' N ';
  OperatorLetters(RULE_OPERATOR_REQUIRES)       := ' R ';
  OperatorLetters(RULE_OPERATOR_IMPLIES)        := ' I ';
  OperatorLetters(RULE_OPERATOR_EXCLUDES)       := ' E ';
  OperatorLetters(RULE_OPERATOR_NEGATES)        := ' N ';

  CodeByCodeLookup(TEMPLATE_ANYTRUE)            := OPERATOR_ANYOF;
  CodeByCodeLookup(TEMPLATE_ALLTRUE)            := OPERATOR_ALLOF;
END;

/
