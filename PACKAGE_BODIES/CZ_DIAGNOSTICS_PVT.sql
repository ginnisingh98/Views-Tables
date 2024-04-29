--------------------------------------------------------
--  DDL for Package Body CZ_DIAGNOSTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_DIAGNOSTICS_PVT" AS
/*	$Header: czdiagb.pls 120.3 2007/11/26 08:20:51 kdande ship $		*/
---------------------------------------------------------------------------------------
--This procedure traverses product structure and explosion in parallel, and reports the
--first encountered problem. It does not continue after the first problems because most
--errors in explosion will induce other errors, which would go away after the first one
--is corrected.
--
--p_debug_flag      if 1, writes the detailed message log to cz_db_logs, otherwise just
--                  returns one error message in the output parameter x_msg_data.
--
--p_fix_extra_flag  in case when extra records are found the procedure can be requested
--                  to automatically delete them with this parameter set to 1.
--
--p_mark_fixed_char if deleting explosions, deleted_flag will be set to this character.
--
--x_return_status   FND_API.G_RET_STS_ERROR / FND_API.G_RET_STS_SUCCESS

PROCEDURE verify_structure(p_api_version     IN NUMBER,
                           p_devl_project_id IN NUMBER,
                           p_debug_flag      IN PLS_INTEGER,
                           p_fix_extra_flag  IN PLS_INTEGER,
                           p_mark_fixed_char IN VARCHAR2,
                           x_run_id          IN OUT NOCOPY NUMBER,
                           x_return_status   IN OUT NOCOPY VARCHAR2,
                           x_msg_count       IN OUT NOCOPY NUMBER,
                           x_msg_data        IN OUT NOCOPY VARCHAR2)
IS

  TYPE tIntegerArray   IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
  TYPE tStringArray    IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  TYPE tNumberArray    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tDateArray      IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  TYPE typePsNodeId    IS TABLE OF cz_ps_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePsNodeType  IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeParentId    IS TABLE OF cz_ps_nodes.parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeVirtualFlag IS TABLE OF cz_ps_nodes.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeName        IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeReferenceId IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY VARCHAR2(15);

  TYPE tExplNodeId     IS TABLE OF cz_model_ref_expls.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;

  rootProjectName      cz_devl_projects.name%TYPE;
  rootProjectType      cz_devl_projects.model_type%TYPE;
  rootExplId           cz_model_ref_expls.model_ref_expl_id%TYPE;

  IsLogicGenerated     tIntegerArray;

  glPsNodeId           typePsNodeId;
  glReferenceId        typeReferenceId;
  glPsNodeType         typePsNodeType;
  glIndexByPsNodeId    tIntegerArray;
  glParentId           typeParentId;
  glName               typeName;
  glVirtualFlag        typeVirtualFlag;

  v_NodeIdByComponent  tExplNodeId;

  globalCount          PLS_INTEGER := 1;
 --Just to support debugging
  nDebug               PLS_INTEGER := 7777777;
 --Auxiliery parameters for reporting
  errorMessage         VARCHAR2(4000);
  g_message_id         PLS_INTEGER := 1;

--Referencing level indicator and model stack
  globalLevel          INTEGER := 0;
  globalStack          tIntegerArray;

  PS_NODE_TYPE_PRODUCT         CONSTANT PLS_INTEGER := 258;
  PS_NODE_TYPE_COMPONENT       CONSTANT PLS_INTEGER := 259;
  PS_NODE_TYPE_REFERENCE       CONSTANT PLS_INTEGER := 263;
  PS_NODE_TYPE_CONNECTOR       CONSTANT PLS_INTEGER := 264;

  CZ_CHK_UNKNOWN_NODE_TYPE     EXCEPTION;
  CZ_CHK_EMPTY_PROJECT         EXCEPTION;
  CZ_CHK_MISSING_ROOT_RECORD   EXCEPTION;
  CZ_CHK_DOUBLE_ROOT_RECORD    EXCEPTION;
  CZ_CHK_MISSING_EXPL_RECORD   EXCEPTION;
  CZ_CHK_EXTRA_EXPL_RECORD     EXCEPTION;
  CZ_CHK_INCORRECT_PARAM       EXCEPTION;
---------------------------------------------------------------------------------------
--Reporting procedure

PROCEDURE REPORT(inMessage IN VARCHAR2) IS
BEGIN

  IF(p_debug_flag = 1)THEN

    INSERT INTO cz_db_logs (run_id, logtime, message, caller, message_id)
    VALUES (x_run_id, SYSDATE, inMessage, 'CZ_DIAGNOSTICS_PVT.VERIFY_STRUCTURE', g_message_id);

    g_message_id := g_message_id + 1;

    COMMIT;
  END IF;
END;
---------------------------------------------------------------------------------------
PROCEDURE RETURN_ERROR(inMessage IN VARCHAR2) IS
BEGIN
  x_msg_data := inMessage;
  x_msg_count := 1;
  x_return_status := FND_API.G_RET_STS_ERROR;
  REPORT(inMessage);
END;
---------------------------------------------------------------------------------------
PROCEDURE verify_substructure(inComponentId         IN NUMBER,
                              inProjectId           IN NUMBER,
                              inExplId              IN NUMBER)
IS

 TYPE tNodeDepth      IS TABLE OF cz_model_ref_expls.node_depth%TYPE INDEX BY BINARY_INTEGER;
 TYPE tNodeType       IS TABLE OF cz_model_ref_expls.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE tVirtualFlag    IS TABLE OF cz_model_ref_expls.virtual_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tParentId       IS TABLE OF cz_model_ref_expls.parent_expl_node_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tPsNodeId       IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tChildModelExpl IS TABLE OF cz_model_ref_expls.child_model_expl_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE tExplNodeType   IS TABLE OF cz_model_ref_expls.expl_node_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE typeReferenceId IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
 ntPsNodeId           typePsNodeId;
 ntPsNodeType         typePsNodeType;
 ntParentId           typeParentId;
 ntVirtualFlag        typeVirtualFlag;
 ntName               typeName;
 ntReferenceId        typeReferenceId;

 v_tNodeDepth         tNodeDepth;
 v_tNodeType          tNodeType;
 v_tVirtualFlag       tVirtualFlag;
 v_tParentId          tParentId;
 v_tComponentId       tPsNodeId;
 v_tReferringId       tPsNodeId;
 v_tChildModelExpl    tChildModelExpl;
 v_tExplNodeType      tExplNodeType;
 v_tExplNodeId        tExplNodeId;

 h_tNodeDepth         tNodeDepth;
 h_tNodeType          tNodeType;
 h_tVirtualFlag       tVirtualFlag;
 h_tParentId          tParentId;
 h_tComponentId       tPsNodeId;
 h_tReferringId       tPsNodeId;
 h_tChildModelExpl    tChildModelExpl;
 h_tExplNodeType      tExplNodeType;

 v_IndexByNodeId      tIntegerArray;
 v_TypeByExplId       tExplNodeType;

 thisComponentExplId  cz_model_ref_expls.model_ref_expl_id%TYPE;
 thisProjectId        cz_devl_projects.devl_project_id%TYPE;
 thisProjectName      cz_devl_projects.name%TYPE;
 thisProjectType      cz_devl_projects.model_type%TYPE;
 thisRootExplIndex    PLS_INTEGER;

 i                    PLS_INTEGER;
 j                    PLS_INTEGER;
 localCount           PLS_INTEGER;
---------------------------------------------------------------------------------------
BEGIN --verify_substructure

REPORT('Entering component_id = ' || inComponentId || ', devl_project_id = ' || inProjectId || ', expl_id = ' || inExplId);

   --IF(inComponentId = inProjectId)THEN

REPORT('Reading explosions...');

     --If this is a new model, read its explosion table.

     SELECT model_ref_expl_id, component_id, ps_node_type, virtual_flag, referring_node_id,
            child_model_expl_id, expl_node_type, node_depth
       BULK COLLECT INTO v_tExplNodeId, v_tComponentId, v_tNodeType, v_tVirtualFlag, v_tReferringId,
            v_tChildModelExpl, v_tExplNodeType, v_tNodeDepth
       FROM cz_model_ref_expls
      WHERE deleted_flag = '0'
        AND model_id = inProjectId
        AND parent_expl_node_id = inExplId;

     FOR i IN 1..v_tExplNodeId.COUNT LOOP

REPORT('-> model_ref_expl_id = ' || v_tExplNodeId(i));

       h_tNodeDepth(v_tExplNodeId(i)) := v_tNodeDepth(i);
       h_tNodeType(v_tExplNodeId(i)) := v_tNodeType(i);
       h_tVirtualFlag(v_tExplNodeId(i)) := v_tVirtualFlag(i);
       h_tComponentId(v_tExplNodeId(i)) := v_tComponentId(i);
       h_tReferringId(v_tExplNodeId(i)) := v_tReferringId(i);
       h_tChildModelExpl(v_tExplNodeId(i)) := v_tChildModelExpl(i);
       h_tExplNodeType(v_tExplNodeId(i)) := v_tExplNodeType(i);
     END LOOP;
   --END IF;

nDebug := 1110005;

  --This SELECT statement reads the whole 'virtual' tree under a non-virtual component which also
  --includes the non-virtual component itself. Non-virtual components underneath are included in
  --order to recurse, and this function will be called for every non-virtual component underneath.

  ntPsNodeId.DELETE;
  ntParentId.DELETE;
  ntName.DELETE;
  ntPsNodeType.DELETE;
  ntVirtualFlag.DELETE;
  ntReferenceId.DELETE;

  SELECT ps_node_id, parent_id, name, ps_node_type, virtual_flag, reference_id
    BULK COLLECT INTO ntPsNodeId, ntParentId, ntName, ntPsNodeType, ntVirtualFlag, ntReferenceId
    FROM cz_ps_nodes
   WHERE deleted_flag = '0'
   START WITH ps_node_id = inComponentId
   CONNECT BY
    (PRIOR virtual_flag IS NULL OR PRIOR virtual_flag = '1' OR
     PRIOR ps_node_id = inComponentId)
       AND PRIOR ps_node_id = parent_id;

nDebug := 1110006;

  --Make sure there is some data returned

  IF(ntPsNodeId.LAST IS NOT NULL)THEN

nDebug := 1110007;

  --Having this dummy boundary node eliminates the necessity of potentially time
  --consuming boundary checks.

  ntParentId(ntPsNodeId.LAST + 1) := -99999;

  --Prepare to start the main cycle

  i := ntPsNodeId.FIRST;

  WHILE(i <= ntPsNodeId.LAST) LOOP --Start the main structure verification cycle

   BEGIN

   --Populate the 'global' arrays, not used in this version.

nDebug := 1110010;

    IF(NOT glIndexByPsNodeId.EXISTS(ntPsNodeId(i)))THEN

     glPsNodeId(globalCount) := ntPsNodeId(i);
     glPsNodeType(globalCount) := ntPsNodeType(i);
     glParentId(globalCount) := ntParentId(i);
     glName(globalCount) := ntName(i);
     glVirtualFlag(globalCount) := ntVirtualFlag(i);

   --Add an indexing option.

     glIndexByPsNodeId(ntPsNodeId(i)) := globalCount;

   --These global arrays will be indexed differently because we only need to get
   --persistent_node_id or reference_id by ps_node_id. Probably, good indexing
   --option for some of the other global arrays, too.

     glReferenceId(ntPsNodeId(i)) := ntReferenceId(i);

   --Children of any node start right after the node. But then, the children list may
   --not be dense, because children may have their own children. So in order to find
   --all the children of a node we need to search the whole structure after the node.
   --Here we store the last child's index so that we need to search not the whole
   --structure up to the end but up to this last child's index.

nDebug := 1110011;

     globalCount := globalCount + 1;
    END IF;

nDebug := 1110012;

  --We need to call the procedure for any non-virtual component (bug #2065239) and for any
  --component and reference.

    IF(ntPsNodeType(i) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

REPORT('Found reference/connector, ps_node_id = ' || ntPsNodeId(i));

      --Check for circularity.

      localCount := 0;

      FOR n IN 1..globalLevel LOOP
        IF(globalStack(n) = ntReferenceId(i))THEN

          --Circularity detected.

          localCount := 1;
          EXIT;
        END IF;
      END LOOP;

  --Find the corresponding explosion record v_tExplNodeId(j). Use FIRST and NEXT, as the table
  --may become sparse.

REPORT('Looking for explosion...');

      j := v_tExplNodeId.FIRST;

      WHILE(j IS NOT NULL)LOOP

REPORT('-> checking expl_id = ' || v_tExplNodeId(j));

        IF(v_tComponentId(j) = ntReferenceId(i) AND
           v_tReferringId(j) = ntPsNodeId(i) AND
           v_tNodeType(j) = ntPsNodeType(i) AND
           v_tVirtualflag(j) = ntVirtualFlag(i))THEN

REPORT('Match found!');
          EXIT;
        END IF;

        j := v_tExplNodeId.NEXT(j);
      END LOOP;

      IF(localCount = 0)THEN
        IF(j IS NULL)THEN

          REPORT('Global stack:');
          FOR n IN 1..globalLevel LOOP
            REPORT('model_id = ' || globalStack(n));
          END LOOP;
          REPORT('ps_node_id = ' || ntPsNodeId(i) || ', component_id = ' || inComponentId || ', devl_project_id = ' || inProjectId);

          errorMessage := 'model_id = ' || inProjectId || ': missing explosion record for ps_node_id = ' || ntPsNodeId(i) ||
                          ', component_id = ' || inComponentId;
          RAISE CZ_CHK_MISSING_EXPL_RECORD;
        END IF;

        globalLevel := globalLevel + 1;
        globalStack(globalLevel) := ntReferenceId(i);

        verify_substructure(ntReferenceId(i), inProjectId, v_tExplNodeId(j));

        --Now follow the reference again but this time switching context to the child model.

        IF(v_tNodeDepth(j) = 1 AND (NOT isLogicGenerated.EXISTS(ntReferenceId(i))))THEN

          verify_substructure(ntReferenceId(i), ntReferenceId(i), v_tChildModelExpl(j));
        END IF;

        globalLevel := globalLevel - 1;
      END IF;

      --Delete the explosion record from the memory table.

      IF(j IS NOT NULL)THEN v_tExplNodeId.DELETE(j); END IF;

    ELSIF(ntVirtualFlag(i) = '0' AND ntPsNodeType(i) IN (PS_NODE_TYPE_COMPONENT, PS_NODE_TYPE_PRODUCT) AND
          ntPsNodeId(i) <> inComponentId)THEN

REPORT('Found non-virtual component, ps_node_id = ' || ntPsNodeId(i));

  --Find the corresponding explosion record v_tExplNodeId(j). Use FIRST and NEXT, as the table
  --may become sparse.

REPORT('Looking for explosion...');

        j := v_tExplNodeId.FIRST;

        WHILE(j IS NOT NULL)LOOP

REPORT('-> checking expl_id = ' || v_tExplNodeId(j));

          IF(v_tComponentId(j) = ntPsNodeId(i) AND
             v_tNodeType(j) = ntPsNodeType(i) AND
             v_tVirtualflag(j) = ntVirtualFlag(i))THEN

REPORT('Match found!');
            EXIT;
          END IF;

          j := v_tExplNodeId.NEXT(j);
        END LOOP;

        IF(j IS NULL)THEN

          REPORT('Global stack:');
          FOR n IN 1..globalLevel LOOP
            REPORT('model_id = ' || globalStack(n));
          END LOOP;
          REPORT('ps_node_id = ' || ntPsNodeId(i) || ', component_id = ' || inComponentId || ', devl_project_id = ' || inProjectId);

          errorMessage := 'model_id = ' || inProjectId || ': missing explosion record for ps_node_id = ' || ntPsNodeId(i) ||
                          ', component_id = ' || inComponentId;
          RAISE CZ_CHK_MISSING_EXPL_RECORD;
        END IF;

       verify_substructure(ntPsNodeId(i), inProjectId, v_tExplNodeId(j));

  --Delete the explosion record from the memory table.

        v_tExplNodeId.DELETE(j);
    END IF;
   END;

   --Increase the main cycle counter

   i := i + 1;

  END LOOP; --end of the main structure verification cycle

  IF(v_tExplNodeId.COUNT > 0)THEN

    --There are still explosion records that haven't been matched with any of the
    --structure records.

    REPORT('Global stack:');
    FOR n IN 1..globalLevel LOOP
       REPORT('model_id = ' || globalStack(n));
    END LOOP;

    j := v_tExplNodeId.FIRST;

    WHILE(j IS NOT NULL)LOOP

      REPORT('extra explosion: ' || v_tExplNodeId(j));

      IF(p_fix_extra_flag = 1)THEN

        UPDATE cz_model_ref_expls SET deleted_flag = p_mark_fixed_char WHERE model_ref_expl_id = v_tExplNodeId(j);
      END IF;

      j := v_tExplNodeId.NEXT(j);
    END LOOP;

    errorMessage := 'model_id = ' || inProjectId || ', component_id = ' || inComponentId || ': extra explosion records';
    RAISE CZ_CHK_EXTRA_EXPL_RECORD;
  END IF;

nDebug := 1110038;

  IF(inComponentId = inProjectId)THEN IsLogicGenerated(inComponentId) := 1; END IF;

  ELSIF(inComponentId = inProjectId)THEN --IF 'there is some data returned'

    --The project is empty, stop here.

    errorMessage := 'model_id = ' || inProjectId || ' contains no data.';
    RAISE CZ_CHK_EMPTY_PROJECT;

  END IF; --end of the ELSE block of IF 'there is some data returned'.

REPORT('Exiting component_id = ' || inComponentId || ', devl_project_id = ' || inProjectId || ', expl_id = ' || inExplId);

END; --verify_substructure
---------------------------------------------------------------------------------------
BEGIN --verify_structure

  IF(p_fix_extra_flag = 1 AND p_mark_fixed_char IS NULL)THEN

     errorMessage := 'p_mark_fixed_flag parameter must be specified for p_fix_extra_flag = 1';
     RAISE CZ_CHK_INCORRECT_PARAM;
  END IF;

  IF(p_fix_extra_flag = 1 AND LENGTH(p_mark_fixed_char) > 1)THEN

     errorMessage := 'p_mark_fixed_flag parameter must be one character.';
     RAISE CZ_CHK_INCORRECT_PARAM;
  END IF;

  --Get the run id. If a valid value has been passed as a parameter, use it,
  --else generate a new value.

  IF(x_run_id IS NULL OR x_run_id = 0)THEN
    SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  END IF;

  globalLevel := globalLevel + 1;
  globalStack(globalLevel) := p_devl_project_id;

  --Start off the recursion

  BEGIN

    SELECT model_ref_expl_id INTO rootExplId
      FROM cz_model_ref_expls
     WHERE deleted_flag = '0'
       AND model_id = p_devl_project_id
       AND parent_expl_node_id IS NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      errorMessage := 'Missing root explosion record for model_id = ' || p_devl_project_id;
      RAISE CZ_CHK_MISSING_ROOT_RECORD;
    WHEN TOO_MANY_ROWS THEN
      errorMessage := 'Multiple root explosion records for model_id = ' || p_devl_project_id;
      RAISE CZ_CHK_DOUBLE_ROOT_RECORD;
  END;

  verify_substructure(p_devl_project_id, p_devl_project_id, rootExplId);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

EXCEPTION
  WHEN CZ_CHK_MISSING_ROOT_RECORD THEN
    RETURN_ERROR(errorMessage);
  WHEN CZ_CHK_DOUBLE_ROOT_RECORD THEN
    RETURN_ERROR(errorMessage);
  WHEN CZ_CHK_MISSING_EXPL_RECORD THEN
    RETURN_ERROR(errorMessage);
  WHEN CZ_CHK_EXTRA_EXPL_RECORD THEN
    RETURN_ERROR(errorMessage);
  WHEN CZ_CHK_EMPTY_PROJECT THEN
    RETURN_ERROR(errorMessage);
  WHEN CZ_CHK_INCORRECT_PARAM THEN
    RETURN_ERROR(errorMessage);
  WHEN OTHERS THEN
    RETURN_ERROR('(' || nDebug || '): Root model_id = ' || p_devl_project_id || ', unexpected error occurred:' || SQLERRM);
END verify_structure;
---------------------------------------------------------------------------------------
--The default API - can provide simple or detailed output, does not fix anything.

PROCEDURE verify_structure(p_api_version     IN NUMBER,
                           p_devl_project_id IN NUMBER,
                           p_debug_flag      IN PLS_INTEGER,
                           x_run_id          IN OUT NOCOPY NUMBER,
                           x_return_status   IN OUT NOCOPY VARCHAR2,
                           x_msg_count       IN OUT NOCOPY NUMBER,
                           x_msg_data        IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  verify_structure(p_api_version, p_devl_project_id, p_debug_flag, 0, NULL,
                   x_run_id, x_return_status, x_msg_count, x_msg_data);
END verify_structure; --(standard API)
---------------------------------------------------------------------------------------
--Example if use:
--   SELECT cz_diagnostics_pvt.fast_verify(623160) FROM DUAL;

FUNCTION fast_verify(p_devl_project_id IN NUMBER) RETURN VARCHAR2
IS

  l_run_id         NUMBER;
  l_return_status  VARCHAR2(3);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
BEGIN
  verify_structure(1.0, p_devl_project_id, 0, 0, NULL,
                   l_run_id, l_return_status, l_msg_count, l_msg_data);
  RETURN l_msg_data;
END fast_verify;
---------------------------------------------------------------------------------------
--Example if use:
--   SET SERVEROUTPUT ON
--   BEGIN DBMS_OUTPUT.PUT_LINE(cz_diagnostics_pvt.fast_debug(623160)); END;
--   /
--   SELECT message FROM cz_db_logs WHERE run_id = <value> ORDER BY message_id;

FUNCTION fast_debug(p_devl_project_id IN NUMBER) RETURN NUMBER
IS

  l_run_id         NUMBER;
  l_return_status  VARCHAR2(3);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
BEGIN
  verify_structure(1.0, p_devl_project_id, 1, 0, NULL,
                   l_run_id, l_return_status, l_msg_count, l_msg_data);
  RETURN l_run_id;
END fast_debug;
---------------------------------------------------------------------------------------
--This procedure can be used to automatically fix the explosions - it runs until the
--return status is successful. However, currently it can only delete extra explosion
--records, and has not been thoroughly tested. It is relatively safe, when the extra
--records is the only type of problem.
--
--It will mark the records it deletes with the character in p_mark_fixed_char, which
--must be specified. It is best if this character is not present in the deleted_flag
--before the run - this makes it easy to rollback the changes.
--
--Because the procedure may run many times, the debug output is disabled.
--
--Example of use: EXECUTE cz_diagnostics_pvt.fast_fix_extra(623160, '7');

PROCEDURE fast_fix_extra(p_devl_project_id IN NUMBER, p_mark_fixed_char IN VARCHAR2)
IS

  l_run_id         NUMBER;
  l_return_status  VARCHAR2(3) := FND_API.G_RET_STS_ERROR;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
BEGIN

  WHILE(l_return_status = FND_API.G_RET_STS_ERROR)LOOP

    l_return_status := NULL;
    verify_structure(1.0, p_devl_project_id, 0, 1, p_mark_fixed_char,
                     l_run_id, l_return_status, l_msg_count, l_msg_data);
  END LOOP;
END fast_fix_extra;
---------------------------------------------------------------------------------------
END CZ_DIAGNOSTICS_PVT;

/
