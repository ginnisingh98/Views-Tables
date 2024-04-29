--------------------------------------------------------
--  DDL for Package Body OKE_K_ACCESS_RULES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_ACCESS_RULES_PKG2" as
/* $Header: OKEKAR2B.pls 115.10 2003/12/03 19:20:15 alaw ship $ */

--
--  Name          : Compile_Rules
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function compiles access rules for the
--                  given contract role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : None
--
--  Returns       : BOOLEAN
--

FUNCTION Compile_Rules
( X_Role_ID      IN        VARCHAR2
) RETURN BOOLEAN IS

  L_user_id  number;
  L_login_id number;
  L_def_access_level  varchar2(30);
  L_stage    number := 0;

BEGIN

  L_user_id  := FND_GLOBAL.user_id;
  L_login_id := FND_GLOBAL.conc_login_id;

  SAVEPOINT Before_Compilation;
  --
  -- Step 0
  -- Delete previous compiled information and get
  -- default access level from role
  --
  DELETE FROM oke_compiled_access_rules
  WHERE  role_id = X_Role_ID;

  SELECT default_access_level
  INTO   L_def_access_level
  FROM   pa_project_role_types
  WHERE  project_role_id = X_Role_ID;

  --
  -- Step 1
  -- Access Rules by attributes
  --
  L_stage := 1;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_code
  ,      attribute_group_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      access_rule_id
  ,      form_item_flag)
  SELECT kar.role_id
  ,      kar.secured_object_name
  ,      oap.attribute_code
  ,      oa.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      DECODE( oa.securable_flag ,
                 'Y' , kar.access_level ,
                 'E' , DECODE( kar.access_level ,
                               'NONE' , 'VIEW' ,
                                        kar.access_level
                             ) ,
                       'EDIT'
               )
  ,      kar.access_rule_id
  ,      oap.form_item_flag
  FROM   oke_k_access_rules kar
  ,      oke_object_attributes_b oa
  ,      oke_object_attributes_b oap
  WHERE  kar.role_id = X_Role_ID
  AND    kar.attribute_code is not null
  AND    oa.database_object_name = kar.secured_object_name
  AND    oa.attribute_code = kar.attribute_code
  AND    oap.database_object_name = oa.database_object_name
  AND    oa.attribute_code = nvl( oap.parent_attribute_code
                                , oap.attribute_code )
  ;

  --
  -- Step 2
  -- Access Rules by attribute groups
  --
  L_stage := 2;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_code
  ,      attribute_group_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      access_rule_id
  ,      form_item_flag)
  SELECT kar.role_id
  ,      kar.secured_object_name
  ,      oap.attribute_code
  ,      oa.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      DECODE( oa.securable_flag ,
                 'Y' , kar.access_level ,
                       DECODE( kar.access_level ,
                               'NONE' , 'VIEW' ,
                                        kar.access_level
                             )
               )
  ,      kar.access_rule_id
  ,      oap.form_item_flag
  FROM   oke_k_access_rules kar
  ,      oke_object_attributes_b oa
  ,      oke_object_attributes_b oap
  WHERE  kar.role_id = X_Role_ID
  AND    kar.attribute_code is null
  AND    oa.database_object_name = kar.secured_object_name
  AND    oa.attribute_group_code = kar.attribute_group_code
  AND    oap.database_object_name = oa.database_object_name
  AND    oa.attribute_code = nvl( oap.parent_attribute_code
                                , oap.attribute_code )
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = kar.role_id
    AND    secured_object_name = kar.secured_object_name
    AND    attribute_code = oap.attribute_code
  )
  ;

  --
  -- Step 3
  -- Access Rules by object
  --
  L_stage := 3;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      access_rule_id
  ,      form_item_flag)
  SELECT X_role_id
  ,      oa.database_object_name
  ,      oap.attribute_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      DECODE( oa.securable_flag ,
                 'Y' , kar.access_level ,
                       DECODE( kar.access_level ,
                               'NONE' , 'VIEW' ,
                                        kar.access_level
                             )
               )
  ,      kar.access_rule_id
  ,      oap.form_item_flag
  FROM   oke_k_access_rules kar
  ,      oke_object_attributes_b oa
  ,      oke_object_attributes_b oap
  WHERE  kar.role_id = X_Role_ID
  AND    kar.secured_object_name = oa.database_object_name
  AND    kar.attribute_group_code IS NULL
  AND    kar.attribute_code IS NULL
  AND    oap.database_object_name = oa.database_object_name
  AND    oa.attribute_code = nvl( oap.parent_attribute_code
                                , oap.attribute_code )
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = kar.role_id
    AND    secured_object_name = oap.database_object_name
    AND    attribute_code = oap.attribute_code
  );

  --
  -- Step 4
  -- Default Access Levels
  --
  L_stage := 4;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      form_item_flag)
  SELECT X_Role_ID
  ,      oap.database_object_name
  ,      oap.attribute_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      L_def_access_level
  ,      oap.form_item_flag
  FROM   oke_object_attributes_b oa
  ,      oke_object_attributes_b oap
  WHERE  oa.database_object_name in ( 'OKE_K_HEADERS'
                                    , 'OKE_K_LINES'
                                    , 'OKE_K_DELIVERABLES' )
  AND    oap.database_object_name = oa.database_object_name
  AND    oa.attribute_code = nvl( oap.parent_attribute_code
                                , oap.attribute_code )
  AND NOT EXISTS (
    SELECT null
    FROM   oke_k_access_rules
    WHERE  role_id = X_Role_ID
    AND    secured_object_name = oap.database_object_name
    AND    attribute_group_code IS NULL
    AND    attribute_code IS NULL
  )
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = X_Role_ID
    AND    secured_object_name = oap.database_object_name
    AND    attribute_code = oap.attribute_code
  );

  --
  -- Step 5
  -- User Attribute Access by attribute groups
  --
  L_stage := 5;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_group_type
  ,      attribute_group_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      access_rule_id)
  SELECT kar.role_id
  ,      kar.secured_object_name
  ,      kar.attribute_group_type
  ,      kar.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      kar.access_level
  ,      kar.access_rule_id
  FROM   oke_k_access_rules kar
  WHERE  kar.role_id = X_Role_ID
  AND    kar.attribute_group_type = 'USER';

  --
  -- Step 6
  -- User Attribute Access by object
  --
  L_stage := 6;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_group_type
  ,      attribute_group_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level
  ,      access_rule_id)
  SELECT X_role_id
  ,      kar.secured_object_name
  ,      ag.attribute_group_type
  ,      ag.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      kar.access_level
  ,      kar.access_rule_id
  FROM   oke_k_access_rules kar
  ,      oke_attribute_groups_v ag
  WHERE  kar.role_id = X_Role_ID
  AND    kar.attribute_group_code IS NULL
  AND    kar.attribute_code IS NULL
  ANd    ag.attribute_group_type = 'USER'
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = kar.role_id
    AND    secured_object_name = kar.secured_object_name
    AND    attribute_group_code = ag.attribute_group_code
    AND    attribute_group_type = ag.attribute_group_type
  )
  ;

  --
  -- Step 7
  -- Default User Attribute Access
  --
  L_stage := 7;

  INSERT INTO oke_compiled_access_rules
  (      role_id
  ,      secured_object_name
  ,      attribute_group_type
  ,      attribute_group_code
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      access_level)
  SELECT X_Role_ID
  ,      'OKE_K_HEADERS'
  ,      ag.attribute_group_type
  ,      ag.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      L_def_access_level
  FROM   oke_attribute_groups_v ag
  WHERE  ag.attribute_group_type = 'USER'
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = X_Role_ID
    AND    secured_object_name  = 'OKE_K_HEADERS'
    AND    attribute_group_type = 'USER'
    AND    attribute_group_code = ag.attribute_group_code )
  UNION ALL
  SELECT X_Role_ID
  ,      'OKE_K_LINES'
  ,      ag.attribute_group_type
  ,      ag.attribute_group_code
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      L_def_access_level
  FROM   oke_attribute_groups_v ag
  WHERE  ag.attribute_group_type = 'USER'
  AND NOT EXISTS (
    SELECT null
    FROM   oke_compiled_access_rules
    WHERE  role_id = X_Role_ID
    AND    secured_object_name  = 'OKE_K_LINES'
    AND    attribute_group_type = 'USER'
    AND    attribute_group_code = ag.attribute_group_code )
  ;

  --
  -- Step 8
  -- Delete Compiled Role Functions
  --
  L_stage := 8;

  DELETE FROM oke_role_functions
  WHERE role_id = X_Role_ID;

  --
  -- Step 9
  -- Populate Role Functions
  --
  L_stage := 9;

  INSERT INTO oke_role_functions
  (      role_id
  ,      function_id
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login)
  SELECT DISTINCT X_Role_ID
  ,      f.function_id
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  FROM   fnd_form_functions f
  ,    ( SELECT function_id
         FROM fnd_menu_entries
         START WITH menu_id = (
            SELECT menu_id FROM pa_project_role_types
            WHERE project_role_id = X_Role_ID )
         CONNECT BY menu_id = PRIOR sub_menu_id ) me
  WHERE me.function_id = f.function_id;

  RETURN( TRUE );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT Before_Compilation;
    FND_MESSAGE.SET_NAME('OKE', 'OKE_SEC_COMPILE_RULE_FAILED');
    FND_MESSAGE.SET_TOKEN('STAGE', L_stage);
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
    RETURN( FALSE );

END Compile_Rules;


--
--  Name          : Copy_Rules
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function copies access rules from the
--                  source role to the target role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : None
--
--  Returns       : BOOLEAN
--

FUNCTION Copy_Rules
( X_Source_Role_ID          IN        VARCHAR2
, X_Target_Role_ID          IN        VARCHAR2
, X_Copy_Option             IN        VARCHAR2
) RETURN BOOLEAN IS

  L_user_id  number;
  L_login_id number;
  L_stage    number := 0;

BEGIN

  IF ( X_Copy_Option = 'REPLICATE' ) THEN

    L_stage := 1;

    DELETE FROM oke_k_access_rules
    WHERE role_id = X_Target_Role_ID;

  END IF;

  L_user_id  := FND_GLOBAL.user_id;
  L_login_id := FND_GLOBAL.conc_login_id;

  IF ( X_Copy_Option = 'MERGE' ) THEN

    L_stage := 2;

    UPDATE oke_k_access_rules kar
    SET    last_update_date = sysdate
    ,      last_updated_by  = L_user_id
    ,      access_level     = (
      SELECT access_level
      FROM   oke_k_access_rules
      WHERE  role_id = X_Source_Role_ID
      AND    secured_object_name = kar.secured_object_name
      AND    nvl( attribute_group_code , '*NULL Attribute Group*' ) =
             nvl( kar.attribute_group_code , '*NULL Attribute Group*' )
      AND    nvl( attribute_code , '*NULL Attribute*' ) =
             nvl( kar.attribute_code , '*NULL Attribute*' )
    )
    WHERE role_id = X_Target_Role_ID
    AND EXISTS (
      SELECT NULL
      FROM   oke_k_access_rules
      WHERE  role_id = X_Source_Role_ID
      AND    secured_object_name = kar.secured_object_name
      AND    nvl( attribute_group_code , '*NULL Attribute Group*' ) =
             nvl( kar.attribute_group_code , '*NULL Attribute Group*' )
      AND    nvl( attribute_code , '*NULL Attribute*' ) =
             nvl( kar.attribute_code , '*NULL Attribute*' )
    );

  END IF;

  L_stage := 3;

  INSERT INTO oke_k_access_rules
  (      access_rule_id
  ,      creation_date
  ,      created_by
  ,      last_update_date
  ,      last_updated_by
  ,      last_update_login
  ,      role_id
  ,      secured_object_name
  ,      attribute_group_code
  ,      attribute_code
  ,      access_level )
  SELECT oke_k_access_rules_s.nextval
  ,      sysdate
  ,      L_user_id
  ,      sysdate
  ,      L_user_id
  ,      L_login_id
  ,      X_Target_Role_ID
  ,      kar.secured_object_name
  ,      kar.attribute_group_code
  ,      kar.attribute_code
  ,      kar.access_level
  FROM   oke_k_access_rules kar
  WHERE role_id = X_Source_Role_ID
  AND NOT EXISTS (
    SELECT NULL
    FROM   oke_k_access_rules
    WHERE  role_id = X_Target_Role_ID
    AND    secured_object_name = kar.secured_object_name
    AND    nvl( attribute_group_code , '*NULL Attribute Group*' ) =
           nvl( kar.attribute_group_code , '*NULL Attribute Group*' )
    AND    nvl( attribute_code , '*NULL Attribute*' ) =
           nvl( kar.attribute_code , '*NULL Attribute*' )
  );

  RETURN( TRUE );

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('OKE', 'OKE_SEC_COPY_RULE_FAILED');
    FND_MESSAGE.SET_TOKEN('STAGE', L_stage);
    FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
    RETURN( FALSE );

END Copy_Rules;


--
--  Name          : Compile
--  Pre-reqs      : Invoke from Concurrent Manager
--  Function      : This PL/SQL concurrent program compiles
--                  access rules for all contract roles or
--                  a specific role.
--
--  Parameters    :
--  IN            : X_ROLE_ID            NUMBER
--  OUT           : ERRBUF               VARCHAR2
--                  RETCODE              NUMBER
--
--  Returns       : None
--

PROCEDURE Compile
( ERRBUF                    OUT NOCOPY       VARCHAR2
, RETCODE                   OUT NOCOPY       NUMBER
, X_Role_ID                 IN        NUMBER
) IS

L_Error_Buf    VARCHAR2(4000);
RequestID      NUMBER;
Compile_Error  EXCEPTION;

CURSOR c IS
  SELECT PRT.Project_Role_ID   Role_ID
  ,      PRT.Meaning           Role_Name
  FROM   PA_Project_Role_Types PRT
  ,      PA_Role_Controls      RC
  WHERE  RC.Project_Role_ID    = PRT.Project_Role_ID
  AND    RC.Role_Control_Code  = 'ALLOW_AS_CONTRACT_MEMBER'
  AND    PRT.Freeze_Rules_Flag = 'Y'
  AND    PRT.Project_Role_ID   = nvl(X_Role_ID , PRT.Project_Role_ID)
  ORDER BY Role_Name;

BEGIN

  RETCODE := 0;

  FOR crec IN c LOOP

    FND_MESSAGE.SET_NAME('OKE' , 'OKE_SEC_COMPILING_RULES');
    FND_MESSAGE.SET_TOKEN('ROLE' , crec.Role_Name);
    FND_FILE.PUT_LINE(FND_FILE.LOG , FND_MESSAGE.GET);

    IF NOT ( Compile_Rules( crec.Role_ID ) ) THEN
      RAISE Compile_Error;
    END IF;

  END LOOP;

  RequestID := FND_REQUEST.Submit_Request
                   ( APPLICATION => 'OKE'
                   , PROGRAM     => 'OKEGNKSV'
                   );

EXCEPTION
WHEN Compile_Error THEN
  L_Error_Buf := FND_MESSAGE.GET;
  FND_FILE.PUT_LINE(FND_FILE.LOG , L_Error_Buf);
  ERRBUF := L_Error_Buf;
  RETCODE := 2;

WHEN OTHERS THEN
  ERRBUF := L_Error_Buf;
  RETCODE := 2;

END Compile;

end OKE_K_ACCESS_RULES_PKG2;

/
