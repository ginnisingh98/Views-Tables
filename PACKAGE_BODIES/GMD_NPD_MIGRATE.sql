--------------------------------------------------------
--  DDL for Package Body GMD_NPD_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_NPD_MIGRATE" AS
/* $Header: GMDPDMGB.pls 120.6 2006/12/04 19:12:59 txdaniel noship $ */

FUNCTION Get_Profile_Value(P_Profile_Name IN VARCHAR2) RETURN VARCHAR2;

/*====================================================================
--  FUNCTION:
--    Get_Profile_Value
--
--  DESCRIPTION:
--    This is an internal function used to retrieve the site level
--    value of the the profile.
--
--  PARAMETERS:
--    p_profile_name    - Profile name to retrieve the value.
--
--  SYNOPSIS:
--    Get_Profile_Value(p_profile_name => 'GMD_FORMULA_VERSION_CONTROL');
--
--  HISTORY
--====================================================================*/

FUNCTION Get_Profile_Value(P_Profile_Name IN VARCHAR2) RETURN VARCHAR2 IS

  /*  ------------- LOCAL VARIABLES ------------------- */
  l_profile_value VARCHAR2(2000);

  /*  ------------------ CURSORS ---------------------- */
  -- Get Site level profile values
  CURSOR Cur_get_profile_value IS
    SELECT PROFILE_OPTION_VALUE
    FROM   Fnd_Profile_Options a, Fnd_Profile_Option_Values b
    WHERE  a.Profile_Option_Id = b.Profile_Option_Id
    AND    a.Profile_Option_Name = P_Profile_Name
    AND    level_id = 10001;

BEGIN

  OPEN Cur_get_profile_value;
  FETCH Cur_get_profile_value INTO l_profile_value;
  CLOSE Cur_get_profile_value;

  RETURN(l_profile_value);

END Get_Profile_Value;



/*====================================================================
--  PROCEDURE:
--    Migrate_Plant_Lab_Ind
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the plant and lab
--    indicators to product development parameters.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Plant_Lab_Ind(p_migartion_id    => l_migration_id,
--			    P_commit	      => 'T',
--                          x_failure_count   => l_failure_count );
--
--  HISTORY
--    Added migrated_ind = 1 condition to fetch only those orgranizations
--    which are migrated.
--====================================================================*/
PROCEDURE Migrate_Plant_Lab_Ind (P_migration_run_id	IN NUMBER,
                                 P_commit		IN VARCHAR2,
                                 x_failure_count	OUT NOCOPY NUMBER) IS

  /*  ------------- LOCAL VARIABLES ------------------- */
  l_parameter_id		NUMBER(15);
  l_rowid			VARCHAR2(80);
  l_exists 			NUMBER(1);
  l_migrate_count		NUMBER(5) DEFAULT 0;
  l_lab_ind			NUMBER := 0;
  l_plant_ind			NUMBER := 0;

  /*  ------------------ CURSORS ---------------------- */
  CURSOR Cur_get_plant_lab_ind IS
    SELECT orgn_code, plant_ind, organization_id, created_by,
           Last_updated_by, creation_date, last_update_date,
           Last_update_login
    FROM   sy_orgn_mst
    WHERE  plant_ind > 0
    AND    delete_mark = 0
    AND    migrated_ind = 1;

  CURSOR Cur_check_existence (V_organization_id NUMBER) IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   gmd_parameters_hdr
                   WHERE  organization_id = V_organization_id);

  CURSOR Cur_get_new_parameter_id IS
    SELECT GMD_Parameter_Id_S.nextval
    FROM dual;

  /*  --------EXCEPTIONS ------------- */
  ORG_NOT_MIGRATED      EXCEPTION;

BEGIN

  X_failure_count := 0;

  GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_PARAMETERS',
       p_context         => 'PROFILES',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');

  /* Fetch the migrated organization record for updating the indicators */
  FOR l_rec IN Cur_get_plant_lab_ind LOOP
    BEGIN
      /* Check the id column to determine if the org has migrated */
      IF l_rec.organization_id IS NULL THEN
        RAISE ORG_NOT_MIGRATED;
      END IF;
      /* Lets check if the org record already exists */
      OPEN Cur_check_existence (l_rec.organization_id);
      FETCH Cur_check_existence INTO l_exists;
      IF Cur_check_existence%NOTFOUND THEN

	OPEN Cur_get_new_parameter_id;
	FETCH Cur_get_new_parameter_id INTO l_Parameter_Id;
	CLOSE Cur_get_new_parameter_id;

        /*Bug5695948- Reset the plant or lab indicator */
        l_plant_ind := 0;
        l_lab_ind := 0;

	/* Get Plant and Lab Indicator values */
	IF l_rec.plant_ind = 1 THEN
		l_plant_ind  := 1;
        ELSIF  l_rec.plant_ind = 2 THEN
		l_lab_ind  := 1;
        END IF;

        /* Lets create the parameter record for the organization */
        GMD_PARAMETERS_HDR_PKG.Insert_Row
          (X_rowid		=> l_rowid,
           X_Parameter_Id	=> l_Parameter_Id,
           X_organization_id	=> l_rec.organization_id,
           X_Lab_Ind		=> l_lab_ind,
           X_plant_Ind		=> l_plant_ind,
           X_creation_date	=> l_rec.creation_date,
           X_created_by		=> l_rec.created_by,
           X_last_update_date	=> l_rec.last_update_date,
           X_last_updated_by	=> l_rec.last_updated_by,
           X_last_update_login	=> l_rec.last_update_login);

        /* Lets save the changes now based on the commit parameter*/
        IF p_commit = 'Y' THEN
          COMMIT;
        END IF;
        L_migrate_count := L_migrate_count + 1;
      END IF;
      CLOSE Cur_check_existence;
    EXCEPTION
      WHEN Org_Not_Migrated THEN
        X_failure_count := X_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMD_ORG_NOT_MIGRATED',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => l_rec.orgn_code,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMD');

      WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMD');
    END;
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
   COMMIT;
  END IF;

  GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GMD_PARAMETERS',
       p_context         => 'PROFILES',
       p_param1          => l_migrate_count,
       p_param2          => X_failure_count,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');

EXCEPTION
  WHEN OTHERS THEN
    x_failure_count := x_failure_count + 1;

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => l_migrate_count,
          p_param2          => x_failure_count,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMD');

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => l_migrate_count,
          p_param2          => x_failure_count,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMD');

END Migrate_Plant_Lab_Ind;

/*====================================================================
--  PROCEDURE:
--    Migrate_Profiles
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the profile values as
--    product development parameters.
--
--    The following parameters are migrated from Site Level (pre-convergence)
--    to Global Orgn. level (post-convergence)
--
--    Formula Parameters
--    GMD: Formula Version Control
--    GMD: Byproduct Active
--    GMD: Allow Zero Ingredient Qty
--    GMD: Mass UOM Type
--    GMD: Volume UOM Type
--    GMD: Yield Type
--
--    Operation Parameter(s)
--    GMD: Operation Version Control
--
--    Routing Parameters
--    GMD: Routing Version Control
--    GMD: Enforce Step Dependency
--    GMD: Default Step Release Type
--
--    Recipe Parameters
--    GMD: Recipe Version Control
--    GMD: Process Instruction Paragraph
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Profiles(p_migartion_id    => l_migration_id,
--                     p_commit          => 'T',
--                     x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

PROCEDURE Migrate_Profiles (P_migration_run_id	IN NUMBER,
                            P_commit		IN VARCHAR2,
                            X_failure_count	OUT NOCOPY NUMBER) IS

  /*  ------------- LOCAL VARIABLES ------------------- */
  l_parameter_id		NUMBER(15)	;
  l_rowid			VARCHAR2(80)	;
  l_profile_value		VARCHAR2(80)	;
  l_exists			NUMBER(5)	;
  l_new				NUMBER(5) DEFAULT 0;
  l_parameter_line_id		NUMBER;
  l_migrate_count		NUMBER;

  /*  ------------------ CURSORS ---------------------- */
  CURSOR Cur_get_parameter_id IS
    SELECT parameter_id
    FROM   gmd_parameters_hdr
    WHERE  organization_id IS NULL;

  CURSOR Cur_check_parameter_exists (V_parameter_id NUMBER,
                                     V_parameter VARCHAR2) IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   gmd_parameters_dtl
                   WHERE  parameter_id = V_parameter_id
                   AND    parameter_name = V_parameter);

  CURSOR Cur_get_new_parameter_id IS
	SELECT GMD_Parameter_Id_S.nextval
	FROM dual;

  CURSOR Cur_get_new_parameter_line_id IS
	SELECT GMD_Parameter_Line_Id_S.nextval
	FROM dual;

BEGIN

  X_failure_count := 0;
  l_migrate_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_PARAMETERS',
       p_context         => 'PROFILES',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');


    /* Check if the header record exists */
    OPEN Cur_get_parameter_id;
    FETCH Cur_get_parameter_id INTO l_parameter_id;
    IF Cur_get_parameter_id%NOTFOUND THEN
      /* Fetch the surrogate key value for parameter header */
	OPEN Cur_get_new_parameter_id;
	FETCH Cur_get_new_parameter_id INTO l_Parameter_Id;
	CLOSE Cur_get_new_parameter_id;

      L_new := 1;

	/*Insert a row into the header table for Global organization */
	GMD_PARAMETERS_HDR_PKG.Insert_Row (	X_rowid			=> l_rowid,
						X_Parameter_Id		=> l_parameter_id,
						X_organization_id	=> NULL,
						X_Lab_Ind		=> 0,
						X_plant_Ind		=> 0,
						X_creation_date		=> SYSDATE,
						X_created_by		=> 0,
						X_last_update_date	=> SYSDATE,
						X_last_updated_by	=> 0,
						X_last_update_login	=> NULL);
    END IF;
    CLOSE Cur_get_parameter_id;


  /* Logging the start of the migration*/
  GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_STARTED',
       p_table_name      => 'GMD_PARAMETERS',
       p_context         => 'PROFILES',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');

  -- L_parameter_id := GMD_Parameter_Id_S.nextval; ???


/* Migration of Formula Parameters */

  /* Check if the formula version control profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_FORMULA_VERSION_CONTROL');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the formula version control profile value */
  l_profile_value := NULL;
  l_profile_value :=
      Get_Profile_Value('GMD_FORMULA_VERSION_CONTROL');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_Parameter_line_Id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'GMD_FORMULA_VERSION_CONTROL',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);

   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* Check if the By Product Active profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'FM$BYPROD_ACTIVE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the By Product Active profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('FM$BYPROD_ACTIVE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_Parameter_line_Id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'GMD_BYPRODUCT_ACTIVE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;



/* Check if the Allow Zero Ingredient Qty profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_ZERO_INGREDIENT_QTY');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Allow Zero Ingredient Qty profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('FM$ALLOW_ZERO_INGR_QTY');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'GMD_ZERO_INGREDIENT_QTY',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;


/* Check if the Mass UOM profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_MASS_UM_TYPE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    l_exists := 0;
  ELSE
    l_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Mass UOM profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('LM$UOM_MASS_TYPE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'GMD_MASS_UM_TYPE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* Check if the Volume UOM profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_VOLUME_UM_TYPE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Volume UOM profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('LM$UOM_VOLUME_TYPE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'GMD_VOLUME_UM_TYPE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* Check if the Yield Type profile value exists*/
IF l_new = 1 THEN
  l_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'FM_YIELD_TYPE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    l_exists := 0;
  ELSE
    l_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Yield Type profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('FM_YIELD_TYPE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'FM_YIELD_TYPE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;


/* Check if the Default Release Type profile value exists*/
IF l_new = 1 THEN
  l_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'FM$DEFAULT_RELEASE_TYPE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    l_exists := 0;
  ELSE
    l_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Default Release Type profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('FM$DEFAULT_RELEASE_TYPE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 1,
	X_parameter_name	=> 'FM$DEFAULT_RELEASE_TYPE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* END - Migration of Formula Parameters */


/* Migration of Recipe Parameters */

/* Check if the Recipe Version Control profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_RECIPE_VERSION_CONTROL');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    l_exists := 0;
  ELSE
    l_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Recipe Version Control profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_RECIPE_VERSION_CONTROL');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 4,
	X_parameter_name	=> 'GMD_RECIPE_VERSION_CONTROL',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* Check if the Process Instruction Paragraph profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_PROC_INSTR_PARAGRAPH');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Process Instruction Paragraph profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_PROC_INSTR_PARAGRAPH');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 4,
	X_parameter_name	=> 'GMD_PROC_INSTR_PARAGRAPH',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* END - Migration of Recipe Parameters */


/* Migration of Operation Parameters */

/* Check if the Operation Version Control profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_OPERATION_VERSION_CONTROL');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Operation Version Control profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_OPERATION_VERSION_CONTROL');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 2,
	X_parameter_name	=> 'GMD_OPERATION_VERSION_CONTROL',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* END - Migration of Operation Parameters */


/* Migration of Routing Parameters */

/* Check if the Routing Version Control profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_ROUTING_VERSION_CONTROL');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Routing Version Control profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_ROUTING_VERSION_CONTROL');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 3,
	X_parameter_name	=> 'GMD_ROUTING_VERSION_CONTROL',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* Check if the Enforce Step Dependency profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_ENFORCE_STEP_DEPENDENCY');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Enforce Step Dependency profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_ENFORCE_STEP_DEPENDENCY');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 3,
	X_parameter_name	=> 'GMD_ENFORCE_STEP_DEPENDENCY',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;


/* Check if the Default Step Release type profile value exists*/
IF l_new = 1 THEN
  L_exists := 0;
ELSE
  OPEN Cur_check_parameter_exists (l_parameter_id,
                                   'GMD_DEFAULT_STEP_RELEASE_TYPE');
  FETCH Cur_check_parameter_exists INTO l_exists;
  IF Cur_check_parameter_exists%NOTFOUND THEN
    L_exists := 0;
  ELSE
    L_exists := 1;
  END IF;
  CLOSE Cur_check_parameter_exists;
END IF;

IF l_exists = 0 THEN
  /* Fetch the Default Step Release type profile value */
  l_profile_value := NULL;
  l_profile_value :=  Get_Profile_Value('GMD_DEFAULT_STEP_RELEASE_TYPE');
  IF l_profile_value IS NOT NULL THEN

    OPEN Cur_get_new_parameter_line_id;
    FETCH Cur_get_new_parameter_line_id INTO l_Parameter_line_Id;
    CLOSE Cur_get_new_parameter_line_id;

    GMD_Parameters_Dtl_Pkg.Insert_Row
    (	X_rowid			=> l_rowid,
	X_parameter_line_id	=> l_parameter_line_id,
	X_parameter_id		=> l_parameter_id,
	X_parm_Type		=> 3,
	X_parameter_name	=> 'STEPRELEASE_TYPE',
	X_parameter_value	=> l_profile_value,
	X_creation_date		=> SYSDATE,
	X_created_by		=> 0,
	X_last_update_date	=> SYSDATE,
	X_last_updated_by	=> 0,
	X_last_update_login	=> NULL);
   l_migrate_count := l_migrate_count + 1;
  END IF;
END IF;

/* END - Migration of Routing Parameters */

/* Lets save the changes now based on the commit parameter*/
IF (p_commit = FND_API.G_TRUE) THEN
   COMMIT;
END IF;

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GMD_PARAMETERS',
       p_context         => 'PROFILES',
       p_param1          => l_migrate_count,
       p_param2          => 0,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');


EXCEPTION
  WHEN OTHERS THEN
    x_failure_count := x_failure_count + 1;

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => l_migrate_count,
          p_param2          => x_failure_count,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMD');

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'GMD_PARAMETERS',
          p_context         => 'PROFILES',
          p_param1          => l_migrate_count,
          p_param2          => x_failure_count,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMD');

END Migrate_Profiles;

/*====================================================================
--  PROCEDURE:
--    Migrate_Recipe_Types
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the recipe types.
--
--    Recipes migrated to the Master Inventory Organization would default to 'General' recipes,
--    while recipes migrated to all other inventory orgs would default to 'Site' recipes.
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    Migrate_Recipe_Types(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

PROCEDURE Migrate_Recipe_Types (P_migration_run_id	IN NUMBER,
				P_commit		IN VARCHAR2,
				X_failure_count		OUT NOCOPY NUMBER) IS

  /*  ------------------ CURSORS ---------------------- */

  CURSOR Cur_get_recipe IS
    SELECT chld.recipe_id, mst.recipe_id master_recipe_id
    FROM   gmd_recipes_b chld,
           (SELECT recipe_id, owner_organization_id, recipe_no, formula_id, routing_id
            FROM   gmd_recipes_b
            WHERE  recipe_type = 0 ) mst,
           Mtl_parameters org
    WHERE  org.master_organization_id = mst.owner_organization_id
    AND    chld.owner_organization_id = org.organization_id
    AND    mst.recipe_no = chld.recipe_no
    AND    mst.formula_id = chld.formula_id
    AND    NVL(mst.routing_id, -1) = NVL(chld.routing_id, -1)
    AND    chld.master_recipe_id IS NULL;

BEGIN

  X_failure_count := 0;

  /* Logging the start of the migration*/
  GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_STARTED',
       p_table_name      => 'GMD_RECIPES_B',
       p_context         => 'GMD_RECIPE_TYPE',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');


  /* Running the Migration */

      /* Select all the master organizations and update them to "General" recipe type */
      UPDATE gmd_recipes_b
         SET recipe_type = 0
       WHERE recipe_type IS NULL
	 AND owner_organization_id IN ( SELECT DISTINCT owner_organization_id
					  FROM gmd_recipes_b r
					 WHERE EXISTS (SELECT 1
					                 FROM mtl_parameters o
						        WHERE o.master_organization_id = r.owner_organization_id));

      /* Now lets update the rest of the recipe types as "Site" */
      UPDATE gmd_recipes_b
      SET recipe_type = 1
      WHERE recipe_type IS NULL;

      /* Now lets update the master recipe id for the recipes */
      FOR l_recipe_rec IN Cur_get_recipe LOOP
        UPDATE gmd_recipes_b
        SET master_recipe_id = l_recipe_rec.master_recipe_id
        WHERE recipe_id = l_recipe_rec.recipe_id;
      END LOOP;


    IF (p_commit = FND_API.G_TRUE) THEN
	COMMIT;
    END IF;


  GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => P_migration_run_id,
                        p_log_level       => FND_LOG.LEVEL_EVENT,
                        p_message_token   => 'GMA_MIGRATION_COMPLETED',
                        p_table_name      => 'GMD_RECIPES_B',
			p_context         => 'GMD_RECIPE_TYPE',
                        p_param1          => NULL,
                        p_param2          => NULL,
                        p_param3          => NULL,
                        p_param4          => NULL,
                        p_param5          => NULL,
                        p_db_error        => NULL,
                        p_app_short_name  => 'GMD');

  GMA_MIGRATION.gma_migration_end (l_run_id => P_migration_run_id);

EXCEPTION
  WHEN OTHERS THEN
    x_failure_count := x_failure_count + 1;

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GMD_RECIPES_B',
          p_context         => 'GMD_RECIPE_TYPE',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMD');

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'GMD_RECIPES_B',
          p_context         => 'GMD_RECIPE_TYPE',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMD');

END  Migrate_Recipe_Types;

/*====================================================================
--  PROCEDURE:
--    update_lab_simulator
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to update the lab_organization_id.
--
--    lab_organization_id column in lm_sprd_fls will be updated wih the profile
--    value gmd$default_lab_type organization_id.
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    update_lab_simulator(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--====================================================================*/

  PROCEDURE update_lab_simulator (P_migration_run_id	IN  NUMBER,
				  P_commit		IN  VARCHAR2,
				  X_failure_count	OUT NOCOPY NUMBER) IS
    CURSOR Cur_get_orgn (V_orgn_code VARCHAR2) IS
      SELECT organization_id
      FROM   sy_orgn_mst_b
      WHERE  orgn_code = V_orgn_code
      AND    migrated_ind = 1;

    l_profile_value		VARCHAR2(80);
    l_organization_id		NUMBER;

  /*  --------EXCEPTIONS ------------- */
    ORGN_MISSING      EXCEPTION;
  BEGIN
    X_failure_count := 0;

    /* Logging the start of the migration*/
    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_STARTED',
       p_table_name      => 'LM_SPRD_FLS',
       p_context         => 'SIMULATOR_LAB_TYPE',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMD');

    --Now update the lab_organization_id wih the organization_id value fetched
    --from the gemms_default_lab_type profile.
    l_profile_value :=  FND_PROFILE.VALUE('GEMMS_DEFAULT_LAB_TYPE');
    IF l_profile_value IS NOT NULL THEN
      OPEN Cur_get_orgn(l_profile_value);
      FETCH Cur_get_orgn INTO l_organization_id;
      CLOSE Cur_get_orgn;
      IF (l_organization_id IS NULL) THEN
        RAISE ORGN_MISSING;
      END IF;
      UPDATE lm_sprd_fls
      SET    lab_organization_id = l_organization_id
      WHERE  lab_organization_id IS NULL;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => P_migration_run_id,
                        p_log_level       => FND_LOG.LEVEL_EVENT,
                        p_message_token   => 'GMA_MIGRATION_COMPLETED',
                        p_table_name      => 'LM_SPRD_FLS',
			p_context         => 'SIMULATOR_LAB_TYPE',
                        p_param1          => NULL,
                        p_param2          => NULL,
                        p_param3          => NULL,
                        p_param4          => NULL,
                        p_param5          => NULL,
                        p_db_error        => NULL,
                        p_app_short_name  => 'GMD');

    GMA_MIGRATION.gma_migration_end (l_run_id => P_migration_run_id);

EXCEPTION
  WHEN ORGN_MISSING THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_ORGN_MISSING_ERROR',
          p_table_name      => 'LM_SPRD_FLS',
          p_context         => 'SIMULATOR_LAB_TYPE',
	  p_token1          => 'ORGANIZATION',
          p_param1          => l_profile_value,
          p_app_short_name  => 'GMA');

  WHEN OTHERS THEN
    x_failure_count := x_failure_count + 1;

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'LM_SPRD_FLS',
          p_context         => 'SIMULATOR_LAB_TYPE',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMD');

    GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'LM_SPRD_FLS',
          p_context         => 'SIMULATOR_LAB_TYPE',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMD');
  END update_lab_simulator;


END GMD_NPD_MIGRATE;


/
