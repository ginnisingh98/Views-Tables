--------------------------------------------------------
--  DDL for Package Body AMW_DELETE_OBJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_DELETE_OBJECT_PVT" as
/* $Header: amwvobjb.pls 120.1.12000000.2 2007/03/09 10:00:37 psomanat ship $ */

-- ===============================================================
-- Package name
--          AMW_DELETE_OBJECT_PVT
-- Purpose
-- 		  	for handling object delete actions
--
-- History
-- 		  	12/06/2004    tsho     Creates
-- ===============================================================


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AMW_DELETE_OBJECT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) 	:= 'amwvobjb.pls';


-- Risk query check list
t_risk_dynamic_sql_list G_VARRAY_TABLE := G_VARRAY_TABLE(
  G_VARCHAR_VARRAY('select risk_id from amw_risk_associations where risk_id = :1','Y')
 ,G_VARCHAR_VARRAY('select object_type from amw_control_associations where ( object_type = ''RISK'' and pk2 =:1 ) or (object_type = ''RISK_ORG'' and pk3 =:1) ','Y')
);


-- Control query check list
t_ctrl_dynamic_sql_list G_VARRAY_TABLE := G_VARRAY_TABLE(
  G_VARCHAR_VARRAY('select control_id from amw_control_associations where control_id = :1','Y')
 ,G_VARCHAR_VARRAY('select object_type from amw_ap_associations where ( object_type = ''CTRL'' and pk1 =:1 ) or (object_type = ''CTRL_ORG'' and pk3 =:1) ','Y')
);


-- Audit Procedure query check list
t_ap_dynamic_sql_list G_VARRAY_TABLE := G_VARRAY_TABLE(
  G_VARCHAR_VARRAY(  'SELECT control_id '
                   ||' FROM amw_control_associations WHERE control_id IN ( '
                   ||'      SELECT pk1 '
                   ||'      FROM amw_ap_associations '
                   ||'      WHERE audit_procedure_id = :1 '
                   ||'      AND object_type = ''CTRL'' '
                   ||'      UNION '
                   ||'      SELECT pk2 '
                   ||'      FROM amw_ap_associations '
                   ||'      WHERE object_type =''ENTITY_AP'' '
                   ||'      AND  audit_procedure_id = :1 '
                   ||'      AND deletion_date IS NULL '
                   ||'      UNION '
                   ||'      SELECT pk3 '
                   ||'      FROM amw_ap_associations '
                   ||'      WHERE object_type =''PROJECT'' '
                   ||'      AND  audit_procedure_id = :1 '
                   ||'      AND deletion_date IS NULL '
                   ||'      UNION '
                   ||'      SELECT pk3 '
                   ||'      FROM amw_ap_associations '
                   ||'      WHERE object_type in (''CTRL_ORG'',''CTRL_FINCERT'',''BUSIPROC_CERTIFICATION'') '
                   ||'      AND  audit_procedure_id = :1 ) ','Y')
);



-- ===============================================================
-- Procedure name
--          Delete_Objects
-- Purpose
-- 		  	Delete specified Objs if it's allowed (ie, if it's not in use by others)
-- Params
--          p_object_type_and_id1      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id2      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id3      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id4      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
-- Notes
--          format for Risk: RISK#113
--          format for Control: CTRL#113
--          format for Audit Procedure: AP#113
-- ===============================================================
PROCEDURE Delete_Objects(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_object_type_and_id1         IN   VARCHAR2 := NULL,
    p_object_type_and_id2         IN   VARCHAR2 := NULL,
    p_object_type_and_id3         IN   VARCHAR2 := NULL,
    p_object_type_and_id4         IN   VARCHAR2 := NULL
)
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Objects';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_object_type1   VARCHAR2(30);
l_object_id1     NUMBER;

l_object_type2   VARCHAR2(30);
l_object_id2     NUMBER;

l_object_type3   VARCHAR2(30);
l_object_id3     NUMBER;

l_object_type4   VARCHAR2(30);
l_object_id4     NUMBER;

l_dummy_type_and_id VARCHAR(80);

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);

    IF p_object_type_and_id1 IS NOT NULL THEN
        FND_FILE.put_line(fnd_file.log, '******* p_object_type_and_id1 = '||p_object_type_and_id1||' *******');
        l_dummy_type_and_id := trim(p_object_type_and_id1);
        l_object_type1 := substr(l_dummy_type_and_id, 1, instr(l_dummy_type_and_id, '#')-1);
        l_object_id1 := to_number(substr(l_dummy_type_and_id, instr(l_dummy_type_and_id, '#')+1));
        Delete_Object(p_object_type => l_object_type1, p_object_id => l_object_id1);
    END IF;

    IF p_object_type_and_id2 IS NOT NULL THEN
        FND_FILE.put_line(fnd_file.log, '******* p_object_type_and_id2 = '||p_object_type_and_id2||' *******');
        l_dummy_type_and_id := trim(p_object_type_and_id2);
        l_object_type2 := substr(l_dummy_type_and_id, 1, instr(l_dummy_type_and_id, '#')-1);
        l_object_id2 := to_number(substr(l_dummy_type_and_id, instr(l_dummy_type_and_id, '#')+1));
        Delete_Object(p_object_type => l_object_type2, p_object_id => l_object_id2);
    END IF;

    IF p_object_type_and_id3 IS NOT NULL THEN
        FND_FILE.put_line(fnd_file.log, '******* p_object_type_and_id3 = '||p_object_type_and_id3||' *******');
        l_dummy_type_and_id := trim(p_object_type_and_id3);
        l_object_type3 := substr(l_dummy_type_and_id, 1, instr(l_dummy_type_and_id, '#')-1);
        l_object_id3 := to_number(substr(l_dummy_type_and_id, instr(l_dummy_type_and_id, '#')+1));
        Delete_Object(p_object_type => l_object_type3, p_object_id => l_object_id3);
    END IF;

    IF p_object_type_and_id4 IS NOT NULL THEN
        FND_FILE.put_line(fnd_file.log, '******* p_object_type_and_id4 = '||p_object_type_and_id4||' *******');
        l_dummy_type_and_id := trim(p_object_type_and_id4);
        l_object_type4 := substr(l_dummy_type_and_id, 1, instr(l_dummy_type_and_id, '#')-1);
        l_object_id4 := to_number(substr(l_dummy_type_and_id, instr(l_dummy_type_and_id, '#')+1));
        Delete_Object(p_object_type => l_object_type4, p_object_id => l_object_id4);
    END IF;


End Delete_Objects;



-- ===============================================================
-- Procedure name
--          Delete_Object
-- Purpose
-- 		  	Delete specified Obj if it's allowed (ie, if it's not in use by others)
-- Params
--          p_object_type      := the obj needs to be checked,
--          p_object_id        := the id of specified obj
-- ===============================================================
PROCEDURE Delete_Object(
    p_object_type                IN   VARCHAR2,
    p_object_id                  IN   NUMBER
)
IS
  l_Is_Object_In_Use VARCHAR2(1);

BEGIN
  l_Is_Object_In_Use := 'Y';

  IF (p_object_type IS NOT NULL) THEN
    IF (p_object_type = 'RISK') THEN
      l_Is_Object_In_Use := Is_Object_In_Use(p_dynamic_sql_list => t_risk_dynamic_sql_list,
                                             p_bind_value       => p_object_id);
      IF (l_Is_Object_In_Use = 'N') THEN
        -- object is not in use, can delete it
        Delete_Risk(p_risk_id => p_object_id);
      ELSE
        FND_FILE.put_line(fnd_file.log, 'Cannot Delete Risk : risk_id = '||p_object_id);
      END IF;

    ELSIF (p_object_type = 'CTRL') THEN
      l_Is_Object_In_Use := Is_Object_In_Use(p_dynamic_sql_list => t_ctrl_dynamic_sql_list,
                                             p_bind_value       => p_object_id);
      IF (l_Is_Object_In_Use = 'N') THEN
        -- object is not in use, can delete it
        Delete_Ctrl(p_ctrl_id => p_object_id);
      ELSE
        FND_FILE.put_line(fnd_file.log, 'Cannot Delete Control : control_id = '||p_object_id);
      END IF;

    ELSIF (p_object_type = 'AP') THEN
      l_Is_Object_In_Use := Is_Object_In_Use(p_dynamic_sql_list => t_ap_dynamic_sql_list,
                                             p_bind_value       => p_object_id);
      IF (l_Is_Object_In_Use = 'N') THEN
        -- object is not in use, can delete it
        Delete_Ap(p_ap_id => p_object_id);
      ELSE
        FND_FILE.put_line(fnd_file.log, 'Cannot Delete Audit Procedure : audit_procedure_id = '||p_object_id);
      END IF;

    END IF;
  END IF; -- end of if: p_object_type IS NOT NULL

END Delete_Object;



-- ===============================================================
-- Procedure name
--          Delete_Risk
-- Purpose
-- 		  	Delete specified risk
-- Params
--          p_risk_id
-- ===============================================================
PROCEDURE Delete_Risk(
    p_risk_id                  IN   NUMBER
)
IS
-- find the list of risk_rev_id by specified risk_id
l_risk_rev_id_list G_NUMBER_TABLE;

BEGIN
  IF (p_risk_id IS NOT NULL) THEN
    SELECT risk_rev_id
    BULK COLLECT INTO l_risk_rev_id_list
    FROM AMW_RISKS_B
    WHERE risk_id = p_risk_id;

    -- Risk Type Association
    FORALL i IN l_risk_rev_id_list.FIRST .. l_risk_rev_id_list.LAST
      DELETE FROM AMW_RISK_TYPE WHERE risk_rev_id = l_risk_rev_id_list(i);

    -- Extensible Attr
    DELETE FROM AMW_RISK_EXT_B WHERE risk_id = p_risk_id;
    DELETE FROM AMW_RISK_EXT_TL WHERE risk_id = p_risk_id;

    -- Attachment
    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments('AMW_RISKS',
                                                   p_risk_id,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   'N',
                                                   null);

    -- Risk
    FORALL i IN l_risk_rev_id_list.FIRST .. l_risk_rev_id_list.LAST
      DELETE FROM AMW_RISKS_TL WHERE risk_rev_id = l_risk_rev_id_list(i);

    DELETE FROM AMW_RISKS_B WHERE risk_id = p_risk_id;

    FND_FILE.put_line(fnd_file.log, 'Delete Risk : risk_id = '||p_risk_id);

    IF (sql%notfound) then
      RAISE no_data_found;
    END IF;

  END IF;

EXCEPTION
  WHEN no_data_found THEN
    NULL;
  WHEN others THEN
    NULL;
END Delete_Risk;


-- ===============================================================
-- Procedure name
--          Delete_Ctrl
-- Purpose
-- 		  	Delete specified control
-- Params
--          p_ctrl_id
-- ===============================================================
PROCEDURE Delete_Ctrl(
    p_ctrl_id                  IN   NUMBER
)
IS
-- find the list of control_rev_id by specified control_id
l_ctrl_rev_id_list G_NUMBER_TABLE;

BEGIN
  IF (p_ctrl_id IS NOT NULL) THEN
    SELECT control_rev_id
    BULK COLLECT INTO l_ctrl_rev_id_list
    FROM AMW_CONTROLS_B
    WHERE control_id = p_ctrl_id;

    -- Control Objective
    FORALL i IN l_ctrl_rev_id_list.FIRST .. l_ctrl_rev_id_list.LAST
      DELETE FROM AMW_CONTROL_OBJECTIVES WHERE control_rev_id = l_ctrl_rev_id_list(i);

    -- Control Assertion
    FORALL i IN l_ctrl_rev_id_list.FIRST .. l_ctrl_rev_id_list.LAST
      DELETE FROM AMW_CONTROL_ASSERTIONS WHERE control_rev_id = l_ctrl_rev_id_list(i);

    -- Control Purpose
    FORALL i IN l_ctrl_rev_id_list.FIRST .. l_ctrl_rev_id_list.LAST
      DELETE FROM AMW_CONTROL_PURPOSES WHERE control_rev_id = l_ctrl_rev_id_list(i);

    -- Control Component
    FORALL i IN l_ctrl_rev_id_list.FIRST .. l_ctrl_rev_id_list.LAST
      DELETE FROM AMW_ASSESSMENT_COMPONENTS WHERE OBJECT_TYPE='CONTROL' AND OBJECT_ID = l_ctrl_rev_id_list(i);

    -- Extensible Attr
    DELETE FROM AMW_CTRL_EXT_B WHERE control_id = p_ctrl_id;
    DELETE FROM AMW_CTRL_EXT_TL WHERE control_id = p_ctrl_id;

    -- Attachment
    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments('AMW_CONTROLS',
                                                   p_ctrl_id,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   'N',
                                                   null);
    -- Control
    FORALL i IN l_ctrl_rev_id_list.FIRST .. l_ctrl_rev_id_list.LAST
      DELETE FROM AMW_CONTROLS_TL WHERE control_rev_id = l_ctrl_rev_id_list(i);

    DELETE FROM AMW_CONTROLS_B WHERE control_id = p_ctrl_id;

    FND_FILE.put_line(fnd_file.log, 'Delete Control : control_id = '||p_ctrl_id);

    IF (sql%notfound) then
      RAISE no_data_found;
    END IF;

  END IF;

EXCEPTION
  WHEN no_data_found THEN
    NULL;
  WHEN others THEN
    NULL;
END Delete_Ctrl;


-- ===============================================================
-- Procedure name
--          Delete_Ap
-- Purpose
-- 		  	Delete specified audit procedure
-- Params
--          p_ap_id
-- ===============================================================
PROCEDURE Delete_Ap(
    p_ap_id                  IN   NUMBER
)
IS
-- find the list of audit_procedure_rev_id by specified audit_procedure_id
l_ap_rev_id_list G_NUMBER_TABLE;

BEGIN
  IF (p_ap_id IS NOT NULL) THEN
    SELECT audit_procedure_rev_id
    BULK COLLECT INTO l_ap_rev_id_list
    FROM AMW_AUDIT_PROCEDURES_B
    WHERE audit_procedure_id = p_ap_id;

    -- Step
    DELETE FROM AMW_AP_STEPS_TL WHERE ap_step_id in (SELECT ap_step_id FROM amw_ap_steps_b WHERE audit_procedure_id = p_ap_id);
    DELETE FROM AMW_AP_STEPS_B WHERE audit_procedure_id = p_ap_id;

    -- Task
    DELETE FROM AMW_AP_TASKS WHERE audit_procedure_id = p_ap_id;

    -- Extensible Attr
    DELETE FROM AMW_AP_EXT_B WHERE audit_procedure_id = p_ap_id;
    DELETE FROM AMW_AP_EXT_TL WHERE audit_procedure_id = p_ap_id;

    -- Attachment
    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments('AMW_AUDIT_PRCD',
                                                   p_ap_id,
                                                   null,
                                                   null,
                                                   null,
                                                   null,
                                                   'N',
                                                   null);

    -- Audit Procedure
    FORALL i IN l_ap_rev_id_list.FIRST .. l_ap_rev_id_list.LAST
      DELETE FROM AMW_AUDIT_PROCEDURES_TL WHERE audit_procedure_rev_id = l_ap_rev_id_list(i);

    DELETE FROM AMW_AUDIT_PROCEDURES_B WHERE audit_procedure_id = p_ap_id;
    DELETE FROM AMW_AP_ASSOCIATIONS WHERE audit_procedure_id = p_ap_id;

    FND_FILE.put_line(fnd_file.log, 'Delete Audit Procedure : audit_procedure_id = '||p_ap_id);


    IF (sql%notfound) then
      RAISE no_data_found;
    END IF;

  END IF;

EXCEPTION
  WHEN no_data_found THEN
    NULL;
  WHEN others THEN
    NULL;
END Delete_Ap;


-- ===============================================================
-- Function name
--          Is_Record_Exist
-- Purpose
-- 		  	check if any records found for pass-in query
--          return BOOLEAN TRUE if at least one record is found;
--          return BOOLEAN FALSE otherwise.
-- Params
--          p_dynamic_sql      := the sql needs to be checked,
--                                can have variables defined(ie. :1  ...etc)
--          p_bind_value       := default is Null.
--                               this param is required if variables are defined in p_dynamic_sql param.
-- Notes
--          can only bind same value to the variables (:1) defined in  p_dynamic_sql
-- ===============================================================
FUNCTION Is_Record_Exist(
    p_dynamic_sql      IN         G_VARCHAR_VARRAY,
    p_bind_value       IN         NUMBER := NULL
)
RETURN BOOLEAN
IS
  l_Is_Exist BOOLEAN;

  cursor_name INTEGER;
  rows_processed INTEGER;

BEGIN
  l_Is_Exist := TRUE;

  IF (p_dynamic_sql IS NOT NULL) THEN
      IF ((p_dynamic_sql(1) IS NOT NULL) AND (p_dynamic_sql(2) IS NOT NULL)) THEN
        BEGIN
          cursor_name := dbms_sql.open_cursor;
          dbms_sql.parse(cursor_name, p_dynamic_sql(1), dbms_sql.NATIVE);

          IF (p_dynamic_sql(2) = 'Y') THEN
            dbms_sql.bind_variable(cursor_name, ':1', p_bind_value);
          END IF; -- end of if: p_dynamic_sql(2) = 'Y'

          rows_processed := dbms_sql.execute_and_fetch(cursor_name);
          dbms_sql.close_cursor(cursor_name);
          IF (rows_processed = 0) THEN
            -- no rows found, thus it's not in use
            l_Is_Exist := FALSE;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            dbms_sql.close_cursor(cursor_name);
        END;

      END IF; -- end of if: p_dynamic_sql(1) IS NOT NULL

  END IF; -- end of if: p_dynamic_sql IS NOT NULL

  RETURN l_Is_Exist;

END Is_Record_Exist;


-- ===============================================================
-- Function name
--          Is_Object_In_Use
-- Purpose
-- 		  	check if any records found for pass-in query check list
--          return 'Y' if at least one record is found;
--          return 'N' otherwise.
-- Params
--          p_dynamic_sql_list := the sql list needs to be checked,
--          p_bind_value       := default is Null.
-- ===============================================================
FUNCTION Is_Object_In_Use(
    p_dynamic_sql_list IN         G_VARRAY_TABLE,
    p_bind_value       IN         NUMBER := NULL
)
RETURN VARCHAR
IS

l_Is_Object_In_Use VARCHAR2(1);

BEGIN
  l_Is_Object_In_Use := 'N';

  FOR i in p_dynamic_sql_list.FIRST .. p_dynamic_sql_list.LAST
  LOOP

    IF (Is_Record_Exist(p_dynamic_sql_list(i), p_bind_value) = TRUE) THEN
      FND_FILE.put_line(fnd_file.log, 'object is in use : '||p_dynamic_sql_list(i)(1));
      l_Is_Object_In_Use := 'Y';
      EXIT;
    END IF;
  END LOOP;

  RETURN l_Is_Object_In_Use;

EXCEPTION
  WHEN others THEN
    NULL;
END Is_Object_In_Use;


-- ----------------------------------------------------------------------

END AMW_DELETE_OBJECT_PVT;

/
