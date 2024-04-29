--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_CONSTRAINT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_CONSTRAINT_DATA" as
/* $Header: amwcstlb.pls 120.9 2007/10/12 11:09:29 ptulasi ship $ */

-- ===============================================================
-- Package name
--          AMW_LOAD_CONSTRAINT_DATA
-- Purpose
--
-- History
-- 		  	10/01/2004    tsho     Creates
--                      03/25/2004    tsho     add validation between diff rows
-- ===============================================================

-- if error is found during the process, set this global value to TRUE
v_error_found       				BOOLEAN DEFAULT FALSE;
v_err_msg              				VARCHAR2 (2000);

-- function security for import
v_import_func              CONSTANT VARCHAR2(30) := 'AMW_SOD_IMPORT';


-- ===============================================================
-- Procedure name
--          insert_constraint_entries
-- Purpose
-- 		  	insert Incompatible Functions/Responsiblities to AMW_CONSTRAINT_ENTRIES
-- History
--          09.13.2005 tsho: consider group_code, object_type of constraint entries
-- ===============================================================
procedure insert_constraint_entries(
  p_constraint_rev_id IN NUMBER,
  p_object_id	   	  IN NUMBER,
  p_app_id             IN NUMBER,
  p_user_id           IN NUMBER,
  x_return_status	  OUT NOCOPY  VARCHAR2,
  p_group_code        IN VARCHAR2 := NULL, -- 09.13.2005 tsho added
  p_object_type       IN VARCHAR2 := NULL -- 09.13.2005 tsho added
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'insert_constraint_entries';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		:= 1.0;

  -- Added by QLIU. Temporary fix for Application_ID
  l_application_id NUMBER := null;

  CURSOR c_cp_appl_id (c_conc_program_id NUMBER) IS
      select application_id from fnd_concurrent_programs
      where concurrent_program_id = c_conc_program_id;

  CURSOR c_resp_appl_id (c_resp_id NUMBER) IS
      select application_id from fnd_responsibility
      where responsibility_id = c_resp_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Added by DLIAO. fix for duplicate function/cp/resp. issue.
  l_application_id := p_app_id;

  -- Added by QLIU. Temporary fix for Application_ID
  -- Modified by DLIAO. fix for duplicate function/cp/resp. issue.
  IF ( p_object_type = 'CP' AND l_application_id IS NULL ) THEN
      OPEN c_cp_appl_id (p_object_id);
      FETCH c_cp_appl_id INTO l_application_id;
      CLOSE c_cp_appl_id;
  END IF;

   --Modified by DLIAO. fix for duplicate function/cp/resp. issue.
  IF ( p_object_type = 'RESP' AND l_application_id IS NULL ) THEN
      OPEN c_resp_appl_id (p_object_id);
      FETCH c_resp_appl_id INTO l_application_id;
      CLOSE c_resp_appl_id;
  END IF;

  insert into AMW_CONSTRAINT_ENTRIES (
    CONSTRAINT_REV_ID,
    FUNCTION_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    GROUP_CODE, -- 09.13.2005 tsho added
    OBJECT_TYPE, -- 09.13.2005 tsho added
    APPLICATION_ID -- 04.21.2006 qliu added
  ) values (
    p_constraint_rev_id,
    p_object_id,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    p_user_id,
    null,
    p_group_code, -- 09.13.2005 tsho added
    p_object_type, -- 09.13.2005 tsho added
    l_application_id  -- 04.21.2006 qliu added
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END insert_constraint_entries;




-- ===============================================================
-- Procedure name
--          delete_constraint_entries
-- Purpose
-- 		  	delete Incompatible Functions/Responsiblities from AMW_CONSTRAINT_ENTRIES
--          for specified constraint_rev_id
-- ===============================================================
procedure delete_constraint_entries(
  p_constraint_rev_id IN NUMBER,
  x_return_status	 OUT NOCOPY  VARCHAR2
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'delete_constraint_entries';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		:= 1.0;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from amw_constraint_entries
  where constraint_rev_id = p_constraint_rev_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
  WHEN no_data_found THEN
    fnd_file.put_line (fnd_file.LOG, 'No data found for AMW_LOAD_CONSTRAINT_DATA.delete_constraint_entries: constraint_rev_id = '||p_constraint_rev_id);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END delete_constraint_entries;



-- ===============================================================
-- Procedure name
--          delete_constraint_waivers
-- Purpose
-- 		  	delete Waivers from AMW_CONSTRAINT_WAIVERS
--          for specified constraint_rev_id
-- ===============================================================
procedure delete_constraint_waivers(
  p_constraint_rev_id IN NUMBER,
  x_return_status	 OUT NOCOPY  VARCHAR2
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'delete_constraint_waivers';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		:= 1.0;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from amw_constraint_waivers
  where constraint_rev_id = p_constraint_rev_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
  WHEN no_data_found THEN
    fnd_file.put_line (fnd_file.LOG, 'No data found for AMW_LOAD_CONSTRAINT_DATA.delete_constraint_waivers: constraint_rev_id = '||p_constraint_rev_id);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END delete_constraint_waivers;


-- ===============================================================
-- Private Procedure name
--          update_violations
-- Purpose
--          update violations' status in AMW_VIOLATIONS
--          for specified constraint_rev_id
-- Params
--          p_constraint_rev_id := specified constraint_rev_id
--          p_violation_status := new violation status
-- Notes
--          this is to update the status_code in AMW_VIOLATIONS
--          if p_violation_status = null, then use default 'NA' (Not Applicable)
-- ===============================================================
PROCEDURE update_violations (
  x_return_status       OUT NOCOPY VARCHAR2,
  p_constraint_rev_id           IN NUMBER,
  p_violation_status            IN VARCHAR2
)
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_violations';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

-- store the violation status (status_code), default is 'NA' (Not Applicable)
l_violation_status  VARCHAR2(30) := 'NA';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- decide violation status, if no passed-in p_violation_status, use default
  IF (p_violation_status is not NULL) THEN
    l_violation_status := p_violation_status;
  END IF;

  UPDATE amw_violations
     SET status_code = l_violation_status
   WHERE constraint_rev_id = p_constraint_rev_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
  WHEN no_data_found THEN
    fnd_file.put_line (fnd_file.LOG, 'No data found for AMW_LOAD_CONSTRAINT_DATA.update_violations: constraint_rev_id = '||p_constraint_rev_id);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));

END update_violations;



-- ===============================================================
-- Function name
--          Has_Import_Privilege
-- Purpose
-- 		  	check the user access privilege see if s/he can import data
-- ===============================================================
FUNCTION Has_Import_Privilege
RETURN Boolean
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'Has_Import_Privilege';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  CURSOR c_func_exists IS
  SELECT 'Y'
    FROM fnd_responsibility r, fnd_compiled_menu_functions m, fnd_form_functions f
   WHERE r.responsibility_id = fnd_global.resp_id
	 AND r.application_id=fnd_global.resp_appl_id
     AND r.menu_id = m.menu_id
     AND m.function_id = f.function_id
     AND f.function_name = v_import_func;

  CURSOR c_func_excluded IS
  SELECT 'Y'
    FROM fnd_resp_functions rf, fnd_form_functions f
   WHERE rf.application_id = fnd_global.resp_appl_id
	 AND rf.responsibility_id = fnd_global.resp_appl_id
	 AND rf.rule_type = 'F'
	 AND rf.action_id = f.function_id
	 AND f.function_name = v_import_func;

  l_func_exists VARCHAR2(1);
  l_func_excluded VARCHAR2(1);

BEGIN
  OPEN c_func_exists;
  FETCH c_func_exists INTO l_func_exists;
    IF c_func_exists%NOTFOUND THEN
	    CLOSE c_func_exists;
		return FALSE;
    END IF;
  CLOSE c_func_exists;

  OPEN c_func_excluded;
  FETCH c_func_excluded INTO l_func_excluded;
  CLOSE c_func_excluded;

  IF l_func_excluded is not null THEN
    return FALSE;
  END IF;

  return TRUE;
END Has_Import_Privilege;


-- ===============================================================
-- Function name
--          Get_Party_Id
-- Purpose
--          get the party_id by specified user_id
-- Params
--          p_user_id   := specified user_id
-- ===============================================================
Function Get_Party_Id (
    p_user_id   IN  NUMBER
)
Return  NUMBER
IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Get_Party_Id';
L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

l_party_id NUMBER                                 := NULL;

-- find all employees having corresponding user_id in g_amw_user
-- 12.12.2003 tsho: use static sql for AMW for the time being
-- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
TYPE userCurTyp IS REF CURSOR;
c_user_dynamic_sql userCurTyp;
l_user_dynamic_sql   VARCHAR2(200)  :=
        'SELECT person_party_id '
      ||'  FROM '||G_AMW_USER ||' u '
      ||' WHERE u.user_id = :1 ';

BEGIN
    --FND_FILE.put_line(fnd_file.log,'inside api '||L_API_NAME);
    -- 12.12.2003 tsho: use static sql for AMW for the time being
    -- 04.30.2004 tsho: enable dynamic sql in AMW.C with 5.10
    OPEN c_user_dynamic_sql FOR l_user_dynamic_sql USING
        p_user_id;
    FETCH c_user_dynamic_sql INTO l_party_id;
    CLOSE c_user_dynamic_sql;
    /*
    SELECT person_party_id
      INTO l_party_id
      FROM FND_USER u
     WHERE u.user_id = p_user_id;
    */

    RETURN l_party_id;

END Get_Party_Id;


-- ===============================================================
-- Procedure name
--          update_interface_with_error
-- Purpose
-- 		  	update interface table with error mesg
-- ===============================================================
PROCEDURE update_interface_with_error (
  p_err_msg        IN   VARCHAR2,
  p_table_name     IN   VARCHAR2,
  p_interface_id   IN   NUMBER
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_interface_with_error';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;
  l_interface_status   amw_ap_interface.interface_status%TYPE;

BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process

      -- 08:23:2006 psomanat : Fix for Constraint mass upload issue
      -- we should allways insert then valid constraint for performance
      -- So Commenting the v_error_found
      -- v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_constraint_interface
          WHERE cst_interface_id = p_interface_id;
      EXCEPTION
         WHEN OTHERS THEN
            v_err_msg :=
                   'interface_id: = '
                || p_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;

      BEGIN
         UPDATE amw_constraint_interface
            SET interface_status =
                       l_interface_status
                    || p_err_msg
                    || '**'
                    ,error_flag = 'Y'
          WHERE cst_interface_id = p_interface_id;
         fnd_file.put_line (fnd_file.LOG, SUBSTR (l_interface_status, 1, 200));
         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            v_err_msg :=
                   'Error during package processing  '
                || ' interface_id: = '
                || p_interface_id
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;

      COMMIT;
END update_interface_with_error;


-- =============================================================================
-- Procedure name
--          insert_constraint
-- Purpose
-- 		  	insert new constraint into AMW_CONSTRAINTS_B/_TL
-- History
--          09.13.2005 tsho: consider classification, objective of constraint
--          19.04.2006 PSOMANAT: Default Objective_code = 'DT'
--                Default Classification to the seeded Constraint Classification
-- =============================================================================
PROCEDURE insert_constraint(
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_CONSTRAINT_REV_ID   OUT NOCOPY  NUMBER,
  p_START_DATE                  IN  DATE,
  p_END_DATE                    IN  DATE,
  p_ENTERED_BY_ID               IN  NUMBER,
  p_TYPE_CODE                   IN  VARCHAR2,
  p_RISK_ID                     IN  NUMBER,
  p_APPROVAL_STATUS             IN  VARCHAR2,
  p_CONSTRAINT_NAME             IN  VARCHAR2,
  p_CONSTRAINT_DESCRIPTION      IN  VARCHAR2,
  p_user_id                     IN  NUMBER,
  p_classification              IN  VARCHAR2 := NULL, -- 09.13.2005 tsho added
  p_objective_code              IN  VARCHAR2 := 'DT'  -- 09.13.2005 tsho added
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'insert_constraint';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		:= 1.0;

  l_row_id                   AMW_CONSTRAINTS_VL.row_id%type;
  l_constraint_rev_id		 NUMBER;
  l_classification           VARCHAR2(30):=p_classification;

  -- get constraint_rev_id from AMW_CONSTRAINT_REV_S
  CURSOR c_constraint_rev_id IS
  SELECT AMW_CONSTRAINT_REV_S.NEXTVAL
  FROM dual;

BEGIN
  -- get constraint_rev_id from AMW_CONSTRAINT_REV_S
  OPEN c_constraint_rev_id;
  FETCH c_constraint_rev_id INTO l_constraint_rev_id;
  CLOSE c_constraint_rev_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_CONSTRAINT_REV_ID := NULL;
  IF l_classification IS NULL THEN
    BEGIN
        SELECT work_type_id
        INTO   l_classification
        FROM   amw_work_types_b
        WHERE  work_type_code = 'AMW_UNDEF'
        AND    object_id = (SELECT object_id
                            FROM   fnd_objects
                            WHERE  obj_name = 'AMW_CONSTRAINT');
   EXCEPTION
     WHEN no_data_found THEN
       l_classification := NULL;
     WHEN too_many_rows THEN
       l_classification := NULL;
   END;
  END IF;

  AMW_CONSTRAINTS_PKG.INSERT_ROW(
            X_ROWID                 => l_row_id,
            X_CONSTRAINT_ID         => l_constraint_rev_id,
            X_CONSTRAINT_REV_ID     => l_constraint_rev_id,
            X_START_DATE            => p_start_date,
            X_END_DATE              => p_end_date,
            X_ENTERED_BY_ID         => p_entered_by_id,
            X_TYPE_CODE             => p_type_code,
            X_RISK_ID               => p_risk_id,
            X_LAST_UPDATED_BY       => p_user_id,
            X_LAST_UPDATE_DATE      => sysdate,
            X_CREATED_BY            => p_user_id,
            X_CREATION_DATE         => sysdate,
            X_LAST_UPDATE_LOGIN     => p_user_id,
            X_SECURITY_GROUP_ID     => NULL,
            X_OBJECT_VERSION_NUMBER => 1,
            X_ATTRIBUTE_CATEGORY    => NULL,
            X_ATTRIBUTE1            => NULL,
            X_ATTRIBUTE2            => NULL,
            X_ATTRIBUTE3            => NULL,
            X_ATTRIBUTE4            => NULL,
            X_ATTRIBUTE5            => NULL,
            X_ATTRIBUTE6            => NULL,
            X_ATTRIBUTE7            => NULL,
            X_ATTRIBUTE8            => NULL,
            X_ATTRIBUTE9            => NULL,
            X_ATTRIBUTE10           => NULL,
            X_ATTRIBUTE11           => NULL,
            X_ATTRIBUTE12           => NULL,
            X_ATTRIBUTE13           => NULL,
            X_ATTRIBUTE14           => NULL,
            X_ATTRIBUTE15           => NULL,
            X_CONSTRAINT_NAME       => p_constraint_name,
            X_CONSTRAINT_DESCRIPTION => p_constraint_description,
            X_APPROVAL_STATUS       => p_approval_status,
            X_CLASSIFICATION        => l_classification, -- 09.13.2005 tsho added
            X_OBJECTIVE_CODE        => p_objective_code -- 09.13.2005 tsho added
            );

  x_CONSTRAINT_REV_ID := l_constraint_rev_id;
  --fnd_file.put_line(fnd_file.LOG,'Done with AMW_CONSTRAINTS_PKG.INSERT_ROW');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END insert_constraint;



-- ===============================================================
-- Procedure name
--          update_constraint
-- Purpose
-- 		  	update existing constraint in AMW_CONSTRAINTS_B/_TL
-- History
--          09.13.2005 tsho: consider classification, objective of constraint
-- ===============================================================
PROCEDURE update_constraint(
  x_return_status		OUT NOCOPY	VARCHAR2,
  p_CONSTRAINT_REV_ID           IN  NUMBER,
  p_START_DATE                  IN  DATE,
  p_END_DATE                    IN  DATE,
  p_ENTERED_BY_ID               IN  NUMBER,
  p_TYPE_CODE                   IN  VARCHAR2,
  p_RISK_ID                     IN  NUMBER,
  p_APPROVAL_STATUS             IN  VARCHAR2,
  p_CONSTRAINT_NAME             IN  VARCHAR2,
  p_CONSTRAINT_DESCRIPTION      IN  VARCHAR2,
  p_user_id                     IN  NUMBER,
  p_classification              IN  VARCHAR2 := NULL, -- 09.13.2005 tsho added
  p_objective_code              IN  VARCHAR2 := NULL  -- 09.13.2005 tsho added
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_constraint';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  l_constraint_rev_id		 NUMBER;
  l_classification           VARCHAR2(30):=p_classification;
  l_objective_code           VARCHAR2(30):=p_objective_code;
  -- get constraint_rev_id from AMW_CONSTRAINT_REV_S
  CURSOR c_constraint_rev_id IS
  SELECT AMW_CONSTRAINT_REV_S.NEXTVAL
  FROM dual;

  CURSOR c_classification(c_cst_rev_id number) IS
  SELECT classification
  FROM   amw_constraints_b
  WHERE  constraint_rev_id=c_cst_rev_id;

  CURSOR c_objective_code(c_cst_rev_id number) IS
  SELECT objective_code
  FROM   amw_constraints_b
  WHERE  constraint_rev_id=c_cst_rev_id;
BEGIN
  -- get constraint_rev_id from AMW_CONSTRAINT_REV_S
  OPEN c_constraint_rev_id;
  FETCH c_constraint_rev_id INTO l_constraint_rev_id;
  CLOSE c_constraint_rev_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_classification IS NULL THEN
    OPEN c_classification(p_CONSTRAINT_REV_ID);
    FETCH c_classification INTO l_classification;
    CLOSE c_classification;
  END IF;

  IF l_objective_code IS NULL THEN
    OPEN c_objective_code(p_CONSTRAINT_REV_ID);
    FETCH c_objective_code INTO l_objective_code;
    CLOSE c_objective_code;
  END IF;

  AMW_CONSTRAINTS_PKG.UPDATE_ROW(
            X_CONSTRAINT_ID         => p_constraint_rev_id,
            X_CONSTRAINT_REV_ID     => p_constraint_rev_id,
            X_START_DATE            => p_start_date,
            X_END_DATE              => p_end_date,
            X_ENTERED_BY_ID         => p_entered_by_id,
            X_TYPE_CODE             => p_type_code,
            X_RISK_ID               => p_risk_id,
            X_LAST_UPDATED_BY       => p_user_id,
            X_LAST_UPDATE_DATE      => sysdate,
            X_LAST_UPDATE_LOGIN     => p_user_id,
            X_SECURITY_GROUP_ID     => NULL,
            X_OBJECT_VERSION_NUMBER => 1,
            X_ATTRIBUTE_CATEGORY    => NULL,
            X_ATTRIBUTE1            => NULL,
            X_ATTRIBUTE2            => NULL,
            X_ATTRIBUTE3            => NULL,
            X_ATTRIBUTE4            => NULL,
            X_ATTRIBUTE5            => NULL,
            X_ATTRIBUTE6            => NULL,
            X_ATTRIBUTE7            => NULL,
            X_ATTRIBUTE8            => NULL,
            X_ATTRIBUTE9            => NULL,
            X_ATTRIBUTE10           => NULL,
            X_ATTRIBUTE11           => NULL,
            X_ATTRIBUTE12           => NULL,
            X_ATTRIBUTE13           => NULL,
            X_ATTRIBUTE14           => NULL,
            X_ATTRIBUTE15           => NULL,
            X_CONSTRAINT_NAME       => p_constraint_name,
            X_CONSTRAINT_DESCRIPTION => p_constraint_description,
            X_APPROVAL_STATUS       => p_approval_status,
            X_CLASSIFICATION        => l_classification, -- 09.13.2005 tsho added
            X_OBJECTIVE_CODE        => l_objective_code -- 09.13.2005 tsho added
            );

  --fnd_file.put_line(fnd_file.LOG,'Done with AMW_CONSTRAINTS_PKG.UPDATE_ROW');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	v_err_msg :='Error working in procedure: '
             || L_API_NAME
             || '  '
	         || SUBSTR (SQLERRM, 1, 100);
    fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END update_constraint;


-- ===============================================================
-- Procedure name
--          create_constraints
-- Purpose
-- 		  	import constraints
--          from interface table to AMW_CONSTRAINTS_B and AMW_CONSTRAINTS_TL
-- Notes
--          this procedure is called in Concurrent Executable
-- History
--          09.13.2005 tsho: consider group_code, object_type of constraint entries
-- ===============================================================
PROCEDURE create_constraints (
    ERRBUF      OUT NOCOPY    VARCHAR2,
    RETCODE     OUT NOCOPY    VARCHAR2,
    p_batch_id       IN       NUMBER,
    p_user_id        IN       NUMBER
)
IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_constraints';
  L_API_VERSION_NUMBER        CONSTANT NUMBER		  := 1.0;

  -- 08:23:2006 psomanat : Fix for Constraint mass upload issue
  -- Commenting the check on p_user_id as the interface table records may be
  -- created by different user and the mass upload concurrent program may be
  -- run by a different user.This should effect the webadi
  -- get distinct constraints from interface table
  CURSOR constraints_cur IS
  SELECT intf.cst_name,
    	 intf.cst_description,
		 intf.cst_approval_status_code,
		 intf.cst_start_date,
         intf.cst_end_date,
         intf.risk_name,
         intf.entered_by_id,
         intf.cst_type_code,
		 intf.cst_interface_id,
         intf.cst_entries_function_id,
         intf.cst_entries_resp_id,
         intf.cst_entries_group_code, -- 09.13.2005 tsho added
         intf.cst_violat_obj_type -- 09.13.2005 tsho added
    FROM amw_constraint_interface intf
   WHERE intf.cst_interface_id = (
            SELECT min(ci.cst_interface_id)
              FROM amw_constraint_interface ci
             WHERE ci.cst_name = intf.cst_name
               --AND created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
               AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
               AND process_flag IS NULL
               AND error_flag IS NULL
         );

  -- check if the constraint already existed
  CURSOR c_constraint_exists (l_cst_name IN VARCHAR2) IS
  SELECT b.constraint_id, b.constraint_rev_id, b.approval_status
    FROM amw_constraints_b b, amw_constraints_tl tl
   WHERE tl.name = l_cst_name
	 AND tl.language = USERENV('LANG')
     AND tl.constraint_id = b.constraint_id;

  -- 08:23:2006 psomanat : Fix for Constraint mass upload issue
  -- Commenting the check on p_user_id as the interface table records may be
  -- created by different user and the mass upload concurrent program may be
  -- run by a different user.This should effect the webadi
  --  get constraint entries for specific constriant
  CURSOR c_constraint_entries (l_cst_name IN VARCHAR2) IS
  SELECT cst_name,
	 cst_interface_id,
         cst_entries_function_id,
         cst_entries_resp_id,
         cst_entries_group_code, -- 09.13.2005 tsho added
         cst_violat_obj_type, -- 09.13.2005 tsho added
         cst_entries_appl_id -- 03.23.2007 dliao added
    FROM amw_constraint_interface
   WHERE cst_name = l_cst_name
     --AND created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
     AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
     AND process_flag IS NULL
     AND error_flag IS NULL;

  -- 08:23:2006 psomanat : Fix for Constraint mass upload issue
  -- Commenting the check on p_user_id as the interface table records may be
  -- created by different user and the mass upload concurrent program may be
  -- run by a different user.This should effect the webadi
  -- 03.25.2005 tsho: bug 4243661, check constraint data between rows
  CURSOR c_invalid_constraints IS
  SELECT intf.cst_name,
		 intf.cst_start_date,
         intf.cst_end_date,
         intf.cst_type_code,
		 intf.cst_interface_id,
         intf.cst_entries_function_id,
         intf.cst_entries_resp_id,
         intf.cst_entries_group_code, -- 09.13.2005 tsho added
         intf.cst_violat_obj_type -- 09.13.2005 tsho added
    FROM amw_constraint_interface intf
   WHERE
     --intf.created_by = DECODE (p_user_id, NULL, intf.created_by, p_user_id)
     intf.batch_id = DECODE (p_batch_id, NULL, intf.batch_id, p_batch_id)
     AND intf.process_flag IS NULL
     AND intf.error_flag IS NULL;

  /*02.27.2006 psomanat: added below cursor to raise errors for all invalid rows*/

  -- ptulasi : 10/11/2007
  -- bug : 6494262 : Modified the below code to upload function constraint of type all
  -- with out any error.
  cursor c_check_inv_func is
  select intf.cst_interface_id, intf.cst_type_code
	from amw_constraint_interface intf
   where intf.batch_id=p_batch_id
	 and exists(select ci.cst_name
                  from (select cst_name,count(distinct cst_entries_function_id) as ct_cst_entries_function_id,
                  count(distinct cst_entries_group_code) as ct_cst_entries_group_code
                          from amw_constraint_interface
                         where batch_id=p_batch_id
                           and (cst_type_code='SET' or cst_type_code='ME')
                         group by cst_name) ci
                 where ((cst_type_code='ME' and ci.ct_cst_entries_function_id=1) or
                 (cst_type_code='SET' and (ci.ct_cst_entries_group_code=1 or ci.ct_cst_entries_function_id<2) ))
                   and intf.cst_name=ci.cst_name
                );

  /*02.27.2006 psomanat: added below cursor to raise errors for all invalid rows*/
  -- ptulasi : 10/11/2007
  -- bug : 6494262 : Modified the below code to upload Responsibility constraint of type all
  -- with out any error.
  cursor c_check_inv_resp is
  select intf.cst_interface_id, intf.cst_type_code
    from amw_constraint_interface intf
   where intf.batch_id=p_batch_id
	 and exists ( select ci.cst_name
                    from (select cst_name,count(distinct cst_entries_resp_id) as ct_cst_entries_resp_id,
                    count(distinct cst_entries_group_code) as ct_cst_entries_group_code
                            from amw_constraint_interface
                           where batch_id=p_batch_id
                             and (cst_type_code='RESPSET' or cst_type_code='RESPME')
                           group by cst_name) ci
                   where ((cst_type_code='RESPME' and ci.ct_cst_entries_resp_id=1) or
                 (cst_type_code='RESPSET' and (ci.ct_cst_entries_group_code=1 or ci.ct_cst_entries_resp_id<2) ))
                   and intf.cst_name=ci.cst_name
                 );


  /*02.27.2006 psomanat: added below cursor to raise errors for duplicate constraint*/
  cursor c_chk_dup_csts is
  select intf.cst_interface_id
  from   amw_constraint_interface intf
  where  intf.batch_id=p_batch_id
  and    exists (select ci.cst_name
		                   from (select cst_name,count(cst_name) as count_diff_const
						           from (select distinct cst_name,cst_type_code,cst_start_date,cst_end_date
                                           from amw_constraint_interface
                                          where batch_id=p_batch_id)
                                  group by cst_name) ci
						  where ci.count_diff_const>1
                          and intf.cst_name=ci.cst_name);


  /*04.21.2006 qliu: added below to raise errors for ambiguous IDs*/
  cursor c_chk_ambiguous_cp is
  select intf.cst_interface_id
    from amw_constraint_interface intf
   where intf.batch_id=p_batch_id
     and intf.cst_violat_obj_type='CP'
     and (select count(1) from fnd_concurrent_programs cp
     	   where cp.concurrent_program_id = intf.cst_entries_function_id)>1;

  cursor c_chk_ambiguous_resp is
  select intf.cst_interface_id
    from amw_constraint_interface intf
   where intf.batch_id=p_batch_id
     and (select count(1) from fnd_responsibility resp
     	   where resp.responsibility_id = intf.cst_entries_resp_id
           and resp.START_DATE <= SYSDATE
           and (resp.END_DATE >= SYSDATE OR resp.END_DATE IS NULL)
            )>1;
  e_invalid_entered_by_id    EXCEPTION;
  e_no_import_access         EXCEPTION;
  E_INCONSIST_CST_UPL        EXCEPTION;
  E_INV_CST_ENTRIES_UPL      EXCEPTION;
  E_AMBIGUOUS_CP_UPL	     EXCEPTION;
  E_AMBIGUOUS_RESP_UPL	     EXCEPTION;

  l_amw_delt_constraint_intf VARCHAR2(2);
  l_entered_by_id            NUMBER;
  l_constraint_id		     NUMBER;
  l_constraint_rev_id	     NUMBER;
  l_approval_status          VARCHAR2(30);
  l_interface_id             NUMBER;
  l_process_flag		   	 VARCHAR2(1);
  l_interface_id_count       NUMBER;

  x_return_status            VARCHAR2(30);

BEGIN
  --fnd_file.put_line (fnd_file.LOG, 'resp id: '||fnd_global.RESP_ID);
  --fnd_file.put_line (fnd_file.LOG, 'resp appl id: '||fnd_global.RESP_APPL_ID);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- use party_id as entered_by_id in AMW_CONSTRAINTS_B
  l_entered_by_id := Get_Party_Id(p_user_id);
  IF (l_entered_by_id is NULL) THEN
    RAISE e_invalid_entered_by_id;
  END IF;

  -- check access privilege
  IF not Has_Import_Privilege THEN
    RAISE e_no_import_access;
  END IF;

  -- get profile info for deleting records from interface table
  l_amw_delt_constraint_intf := NVL(fnd_profile.VALUE ('AMW_DELT_CST_INTF'), 'N');

  l_interface_id := NULL;
  l_interface_id_count := NULL;

   FOR c_inv_func_rec IN c_check_inv_func LOOP
      begin
         l_interface_id := c_inv_func_rec.cst_interface_id;
	     IF(l_interface_id IS NOT NULL) THEN
            RAISE E_INV_CST_ENTRIES_UPL;
	     END IF;
     exception
	    -- found there is not sufficient constraint entries for the same constraint name
        WHEN E_INV_CST_ENTRIES_UPL THEN
	       BEGIN
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSUFFICIENT CST ENTRIES UPLOAD FOUND');

              -- ptulasi : 10/11/2007
              -- bug : 6494262 : Modified the below code to display different messages for set type
              -- and me type constraint
	          IF c_inv_func_rec.cst_type_code = 'ME' THEN
       	          v_err_msg := AMW_UTILITY_PVT.get_message_text('AMW_CONSTRAINT_UPL_NUM_ERROR');
	          ELSE
   	              v_err_msg := AMW_UTILITY_PVT.get_message_text('AMW_CST_FUNCSET_NUM_ERROR');
              END IF;
			  FND_FILE.PUT_LINE(FND_FILE.LOG, 'c_check_inv_func*** '||v_err_msg||' for interface_id: '||L_INTERFACE_ID);
	          update_interface_with_error(
	             p_ERR_MSG    	=> v_err_msg
	            ,p_table_name 	=> 'AMW_CONSTRAINTS_B'
	            ,P_INTERFACE_ID => L_INTERFACE_ID);
           EXCEPTION
	          WHEN OTHERS THEN
 		         fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INCONSIST_CST_UPL: '||sqlerrm);
	       END;
	   	WHEN NO_DATA_FOUND THEN
           NULL;
	 end;
   end loop;

   FOR c_inv_resp_rec IN c_check_inv_resp LOOP
      begin
         l_interface_id := c_inv_resp_rec.cst_interface_id;
	     IF(l_interface_id IS NOT NULL) THEN
            RAISE E_INV_CST_ENTRIES_UPL;
	     END IF;
     exception
	    -- found there is not sufficient constraint entries for the same constraint name
        WHEN E_INV_CST_ENTRIES_UPL THEN
	       BEGIN
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'INSUFFICIENT CST ENTRIES UPLOAD FOUND');
              -- ptulasi : 10/11/2007
              -- bug : 6494262 : Modified the below code to display different messages for respset
              -- type and respme type constraint
	          IF c_inv_resp_rec.cst_type_code = 'RESPME' THEN
       	          v_err_msg := AMW_UTILITY_PVT.get_message_text('AMW_CONSTRAINT_UPL_NUM_ERROR');
	          ELSE
   	              v_err_msg := AMW_UTILITY_PVT.get_message_text('AMW_CST_RESPSET_NUM_ERROR');
              END IF;
			  FND_FILE.PUT_LINE(FND_FILE.LOG, 'c_check_inv_resp*** '||v_err_msg||' for interface_id: '||L_INTERFACE_ID);
	          update_interface_with_error(
	             p_ERR_MSG    	=> v_err_msg
	            ,p_table_name 	=> 'AMW_CONSTRAINTS_B'
	            ,P_INTERFACE_ID => L_INTERFACE_ID);
           EXCEPTION
	          WHEN OTHERS THEN
 		         fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INCONSIST_CST_UPL: '||sqlerrm);
	       END;
	   	WHEN NO_DATA_FOUND THEN
           NULL;
	 end;
   end loop;

   -- check if there's any different constraint definition, startDate, endDate between diff rows
   -- for the same constraint name
   FOR c_dup_csts_rec IN c_chk_dup_csts LOOP
      begin
         l_interface_id := c_dup_csts_rec.cst_interface_id;
	     IF(l_interface_id IS NOT NULL) THEN
            RAISE E_INCONSIST_CST_UPL;
	     END IF;
     exception
	    -- found there is not sufficient constraint entries for the same constraint name
        WHEN E_INCONSIST_CST_UPL THEN
	       BEGIN
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'INCONSISTENT CST UPLOAD FOUND' );
	          v_err_msg := AMW_UTILITY_PVT.get_message_text('AMW_CONSTRAINT_UPL_INCONSIST');
			  FND_FILE.PUT_LINE(FND_FILE.LOG, 'c_chk_dup_csts*** '||v_err_msg||' for interface_id: '||L_INTERFACE_ID);
	          update_interface_with_error(
	             p_ERR_MSG    	=> v_err_msg
	            ,p_table_name 	=> 'AMW_CONSTRAINTS_B'
	            ,P_INTERFACE_ID => L_INTERFACE_ID);
           EXCEPTION
	          WHEN OTHERS THEN
 		         fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INCONSIST_CST_UPL: '||sqlerrm);
 	          END;
	   	WHEN NO_DATA_FOUND THEN
           NULL;
	 end;
   end loop;

   /*04.21.2006 qliu: added below to raise errors for ambiguous CP and Resp IDs*/
   FOR c_cp_rec IN c_chk_ambiguous_cp LOOP
      begin
         l_interface_id := c_cp_rec.cst_interface_id;
	     IF(l_interface_id IS NOT NULL) THEN
            RAISE E_AMBIGUOUS_CP_UPL;
	     END IF;
     exception
        WHEN E_AMBIGUOUS_CP_UPL THEN
	       BEGIN
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'FOUND NON-UNIQUE CONC. PROGRAM ID' );
	          v_err_msg := 'Concurrent Program ID is not unique. Please create this constraint from Self-Service UI.';
	          FND_FILE.PUT_LINE(FND_FILE.LOG, '*** '||v_err_msg||' for interface_id: '||L_INTERFACE_ID);
	          update_interface_with_error(
	             p_ERR_MSG    	=> v_err_msg
	            ,p_table_name 	=> 'AMW_CONSTRAINTS_B'
	            ,P_INTERFACE_ID => L_INTERFACE_ID);
           EXCEPTION
	          WHEN OTHERS THEN
 		         fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INCONSIST_CST_UPL: '||sqlerrm);
 	          END;
	   	WHEN NO_DATA_FOUND THEN
           NULL;
	 end;
   end loop;

   FOR c_resp_rec IN c_chk_ambiguous_resp LOOP
      begin
         l_interface_id := c_resp_rec.cst_interface_id;
	     IF(l_interface_id IS NOT NULL) THEN
            RAISE E_AMBIGUOUS_RESP_UPL;
	     END IF;
     exception
	    -- found there is not sufficient constraint entries for the same constraint name
        WHEN E_AMBIGUOUS_RESP_UPL THEN
	       BEGIN
	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'FOUND NON-UNIQUE RESPONSIBILITY ID' );
	          v_err_msg := 'Responsibility ID is not unique. Please create this constraint from Self-Service UI.';
	          FND_FILE.PUT_LINE(FND_FILE.LOG, '*** '||v_err_msg||' for interface_id: '||L_INTERFACE_ID);
	          update_interface_with_error(
	             p_ERR_MSG    	=> v_err_msg
	            ,p_table_name 	=> 'AMW_CONSTRAINTS_B'
	            ,P_INTERFACE_ID => L_INTERFACE_ID);
           EXCEPTION
	          WHEN OTHERS THEN
 		         fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INCONSIST_CST_UPL: '||sqlerrm);
 	          END;
	   	WHEN NO_DATA_FOUND THEN
           NULL;
	 end;
   end loop;

   /*
    Should not upload the constraint, if any constraint entry is invalid.
    So set the error flag and the status.
   */
   UPDATE amw_constraint_interface
   SET  error_flag = 'Y',
        interface_status = 'Please correct all the invalid incompatible'
                            ||' Functions/Responsibilities defined for this'
                            ||' Constraint'
   WHERE error_flag IS NULL
   AND   batch_id = p_batch_id
   AND  (process_flag IS NULL OR process_flag = 'N')
   AND   CST_NAME IN ( SELECT DISTINCT CST_NAME
                                     FROM  amw_constraint_interface
                                     WHERE error_flag = 'Y'
                                     AND   batch_id = p_batch_id
                                     AND  (process_flag IS NULL OR process_flag = 'N') );

 /*03.27.2006 psomanat: added check for error --- process further
    only if no error in validation above*/

  -- 08:23:2006 psomanat : Fix for Constraint mass upload issue
  -- we should allways insert the valid constraint for performance
  -- So Commenting the if condition
  --IF(NOT v_error_found) THEN

  -- loop processing each record
  FOR constraint_rec IN constraints_cur
  LOOP
    l_interface_id := constraint_rec.cst_interface_id;
    l_constraint_id := NULL;
    l_constraint_rev_id := NULL;

    --fnd_file.put_line(fnd_file.LOG,'processing interface_id = '||l_interface_id);

    -- check if the constraint already existed
    OPEN c_constraint_exists(constraint_rec.cst_name);
    FETCH c_constraint_exists INTO l_constraint_id, l_constraint_rev_id, l_approval_status;
	CLOSE c_constraint_exists;

    IF (l_constraint_id is NULL) THEN
      -- create new constraint
      --fnd_file.put_line(fnd_file.LOG,'%%%%%%%%%%%% Before AMW_LOAD_CONSTRIANT_DATA.insert_constraint %%%%%%%%%%%%');
      --fnd_file.put_line(fnd_file.LOG,'constraint_rec.cst_name: '||constraint_rec.cst_name);
      insert_constraint(
        x_return_status		          => x_return_status,
        x_CONSTRAINT_REV_ID           => l_constraint_rev_id,
        p_START_DATE                  => constraint_rec.cst_start_date,
        p_END_DATE                    => constraint_rec.cst_end_date,
        p_ENTERED_BY_ID               => l_entered_by_id,
        p_TYPE_CODE                   => constraint_rec.cst_type_code,
        p_RISK_ID                     => constraint_rec.risk_name,
        p_APPROVAL_STATUS             => constraint_rec.cst_approval_status_code,
        p_CONSTRAINT_NAME             => constraint_rec.cst_name,
        p_CONSTRAINT_DESCRIPTION      => constraint_rec.cst_description,
        p_user_id                     => p_user_id
      );
	  --fnd_file.put_line(fnd_file.LOG,'%%%%%%%%%%%% After AMW_LOAD_CONSTRIANT_DATA.insert_constraint %%%%%%%%%%%%');

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  	    v_err_msg :='Error working in procedure: '
                 || L_API_NAME
                 || '  '
	             || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
        update_interface_with_error (v_err_msg
                                    ,'AMW_CONSTRAINTS'
                                    ,l_interface_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- create new constraint entries for the newly created constraint
      -- 09.13.2005 tsho: consider group_code, object_type of constraint entries
      IF (substr(constraint_rec.cst_type_code,1,4) = 'RESP') THEN
        IF (constraint_rec.cst_type_code = 'RESPSET') THEN
          -- constraint type is Responsibility Set (RESPSET)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_resp_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => constraint_entries_rec.cst_entries_group_code,
              p_object_type       => 'RESP' -- 21:04:2006 psomanat : temporary fix for Object_type  column = null
            );                              -- for responsibility constraint created via webadi

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	    v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, RESPSET constraint type
        ELSE
          -- constraint type is Responsibility (RESPALL, RESPME)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_resp_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => '1',   -- 21:04:2006 psomanat : group code set to 1 in self service
              p_object_type       => 'RESP' -- 21:04:2006 psomanat : temporary fix for Object_type  column = null
            );                              -- for responsibility constraint created via webadi

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	    v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, RESPALL, RESPME constraint type
        END IF; -- end of if: constraint_rec.cst_type_code = 'RESPSET'

      ELSE
        IF (constraint_rec.cst_type_code = 'SET') THEN
          -- constraint type is Function (SET)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_function_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => constraint_entries_rec.cst_entries_group_code,
              p_object_type       => constraint_entries_rec.cst_violat_obj_type
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	      v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, Function Constraint (SET) type
        ELSE
          -- constraint type is Function (ALL, ME)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	    => constraint_entries_rec.cst_entries_function_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	    => x_return_status,
              p_group_code        => '1',   -- 21:04:2006 psomanat : group code set to 1 in self service
              p_object_type       => constraint_entries_rec.cst_violat_obj_type
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	      v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, Function Constraint (ALL, ME) type

        END IF; -- end of if: constraint_rec.cst_type_code = 'SET'

      END IF; -- end of if: substr(constraint_rec.cst_type_code,1,4) = 'RESP'

    ELSE
      -- update existing constraint with specified constraint_rev_id
      --fnd_file.put_line(fnd_file.LOG,'%%%%%%%%%%%% Before AMW_LOAD_CONSTRIANT_DATA.update_constraint %%%%%%%%%%%%');
      --fnd_file.put_line(fnd_file.LOG,'constraint_rec.cst_name: '||constraint_rec.cst_name);
      update_constraint(
        x_return_status		=> x_return_status,
        p_CONSTRAINT_REV_ID   => l_constraint_rev_id,
        p_START_DATE          => constraint_rec.cst_start_date,
        p_END_DATE            => constraint_rec.cst_end_date,
        p_ENTERED_BY_ID       => l_entered_by_id,
        p_TYPE_CODE           => constraint_rec.cst_type_code,
        p_RISK_ID             => constraint_rec.risk_name,
        p_APPROVAL_STATUS     => constraint_rec.cst_approval_status_code,
        p_CONSTRAINT_NAME     => constraint_rec.cst_name,
        p_CONSTRAINT_DESCRIPTION => constraint_rec.cst_description,
        p_user_id             => p_user_id
      );
	  --fnd_file.put_line(fnd_file.LOG,'%%%%%%%%%%%% After AMW_LOAD_CONSTRIANT_DATA.update_constraint %%%%%%%%%%%%');

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   	    v_err_msg :='Error working in procedure: '
                 || L_API_NAME
                 || '  '
                 || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
        update_interface_with_error (v_err_msg
                                    ,'AMW_CONSTRAINTS'
                                    ,l_interface_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- update violations's status for specified constraint_rev_d
      update_violations (
        x_return_status         => x_return_status,
        p_constraint_rev_id     => l_constraint_rev_id,
        p_violation_status      => 'NA'
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   	    v_err_msg :='Error working in procedure: '
                 || L_API_NAME
                 || '  '
                 || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
        update_interface_with_error (v_err_msg
                                    ,'AMW_VIOLATIONS'
                                    ,l_interface_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- delete existing constraint waivers for specified constraint_rev_d
      delete_constraint_waivers(
        p_constraint_rev_id  => l_constraint_rev_id,
        x_return_status	     => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   	    v_err_msg :='Error working in procedure: '
                 || L_API_NAME
                 || '  '
                 || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
        update_interface_with_error (v_err_msg
                                    ,'AMW_CONSTRAINT_WAIVERS'
                                    ,l_interface_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- delete existing constraint entries for specified constraint_rev_d
      delete_constraint_entries(
        p_constraint_rev_id  => l_constraint_rev_id,
        x_return_status	     => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   	    v_err_msg :='Error working in procedure: '
                 || L_API_NAME
                 || '  '
                 || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
        update_interface_with_error (v_err_msg
                                    ,'AMW_CONSTRAINT_ENTRIES'
                                    ,l_interface_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- insert constraint entries for the specified constraint_rev_id
      -- 09.13.2005 tsho: consider group_code, object_type of constraint entries
      IF (substr(constraint_rec.cst_type_code,1,4) = 'RESP') THEN
        IF (constraint_rec.cst_type_code = 'RESPSET') THEN
          -- constraint type is Responsibility Set (RESPSET)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_resp_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => constraint_entries_rec.cst_entries_group_code,
              p_object_type       => 'RESP' -- 21:04:2006 psomanat : temporary fix for Object_type  column = null
            );                              -- for responsibility constraint created via webadi

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	    v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, RESPSET constraint type
        ELSE
          -- constraint type is Responsibility (RESPALL, RESPME)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_resp_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => '1',   -- 21:04:2006 psomanat : group code set to 1 in self service
              p_object_type       => 'RESP' -- 21:04:2006 psomanat : temporary fix for Object_type  column = null
            );                              -- for responsibility constraint created via webadi

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	    v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, RESPALL, RESPME constraint type
        END IF; -- end of if: constraint_rec.cst_type_code = 'RESPSET'

      ELSE
        IF (constraint_rec.cst_type_code = 'SET') THEN
          -- constraint type is Function (SET)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	  => constraint_entries_rec.cst_entries_function_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	  => x_return_status,
              p_group_code        => constraint_entries_rec.cst_entries_group_code,
              p_object_type       => constraint_entries_rec.cst_violat_obj_type
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	      v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, Function Constraint (SET) type
        ELSE
          -- constraint type is Function (ALL, ME)
          FOR constraint_entries_rec IN c_constraint_entries(constraint_rec.cst_name)
          LOOP
            insert_constraint_entries(
              p_constraint_rev_id => l_constraint_rev_id,
              p_object_id	   	    => constraint_entries_rec.cst_entries_function_id,
              p_app_id                    => constraint_entries_rec.cst_entries_appl_id,
              p_user_id           => p_user_id,
              x_return_status	    => x_return_status,
              p_group_code        => '1',   -- 21:04:2006 psomanat : group code set to 1 in self service
              p_object_type       => constraint_entries_rec.cst_violat_obj_type
            );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	      v_err_msg :='Error working in procedure: '
                       || L_API_NAME
                       || '  '
	                   || SUBSTR (SQLERRM, 1, 100);
              fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
              update_interface_with_error (v_err_msg
                                          ,'AMW_CONSTRAINT_ENTRIES'
		                                  ,constraint_entries_rec.cst_interface_id);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- end of for: constraint_entries_rec, Function Constraint (ALL, ME) type

        END IF; -- end of if: constraint_rec.cst_type_code = 'SET'

      END IF; -- end of if: substr(constraint_rec.cst_type_code,1,4) = 'RESP'

    END IF;-- end of if: l_constraint_id is NULL

  END LOOP; -- end of for: constraints_cur
  --END IF; -- 03.27.2006 psomanat: end check for validation error

  -- 08.23.2006 psomanat : Fix for constraint mass upload
  -- we should allways insert the valid constraint for performance
  /*
  IF v_error_found THEN
    ROLLBACK;
    l_process_flag := NULL;
  ELSE
    l_process_flag := 'Y';
  END IF;
  */
  l_process_flag := 'Y';

  -- check option value to delete records from interface table or not
  IF UPPER (l_amw_delt_constraint_intf) <> 'Y' THEN
    -- don't delete records from interface table
    BEGIN
      UPDATE amw_constraint_interface
         SET process_flag = l_process_flag,
            last_update_date = SYSDATE,
             last_updated_by = p_user_id
       WHERE batch_id = p_batch_id
       AND error_flag IS NULL;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.LOG,'err in update process flag: '||SUBSTR (SQLERRM, 1, 200));
    END;
  ELSE

    -- delete records from interface table if no error found
     IF NOT v_error_found THEN
      BEGIN
        DELETE FROM amw_constraint_interface
              WHERE batch_id = p_batch_id
              AND error_flag IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line (fnd_file.LOG,'err in delete interface records: '||SUBSTR (SQLERRM, 1, 200));
      END;
    END IF;
  END IF; -- end of if: l_amw_delt_constraint_intf

EXCEPTION
  -- invalid entered_by_id
  WHEN e_invalid_entered_by_id THEN
    BEGIN
      v_err_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_UNKNOWN_EMPLOYEE');
      fnd_file.put_line (fnd_file.LOG, 'Invalid entered_by_id.');
      UPDATE amw_constraint_interface
         SET error_flag = 'Y',
             interface_status = v_err_msg
       WHERE batch_id = p_batch_id;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling e_invalid_entered_by_id: '||sqlerrm);
    END;

  -- no import privilege
  WHEN e_no_import_access THEN
    BEGIN
      v_err_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_NO_IMPORT_ACCESS');
      fnd_file.put_line (fnd_file.LOG, 'no import privilege');
      UPDATE amw_ap_interface
         SET error_flag = 'Y',
             interface_status = v_err_msg
       WHERE batch_id = p_batch_id;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling e_no_import_access: '||sqlerrm);
    END;

  -- other exceptions
  WHEN others THEN
    rollback;
    fnd_file.put_line (fnd_file.LOG, 'unexpected exception in create_constraints: '||sqlerrm);
END create_constraints;
-- ----------------------------------------------------------------------
END AMW_LOAD_CONSTRAINT_DATA;

/
