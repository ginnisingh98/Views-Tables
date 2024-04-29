--------------------------------------------------------
--  DDL for Package Body GMD_QC_MIGV12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_MIGV12" AS
/* $Header: gmdmv12b.pls 120.0 2005/06/30 11:33:28 jdiiorio noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmg12b.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIGV12                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains migration validation procedures/functions       |
 |    for Quality for 12 migration.                                         |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/

/*===========================================================================
--  FUNCTION:
--    get_profile_value
--
--  DESCRIPTION:
--    This function returns the System level profile value for a given profile.
--    Null is returned if the profile value is not found.
--
--  PARAMETERS:
--    p_profile_name        IN  VARCHAR2       - Profile Name
--
--    return                OUT VARCHAR2       - Profile Value
--
--=========================================================================== */


FUNCTION GET_PROFILE_VALUE
( p_profile_name     IN  VARCHAR2) RETURN VARCHAR2 IS


CURSOR get_profile IS
SELECT profile_option_value
FROM   fnd_profile_options A, fnd_profile_option_values B
WHERE  a.profile_option_id = b.profile_option_id
AND    a.profile_option_name = p_profile_name
AND    level_id = 10001;


l_profile_value     fnd_profile_option_values.profile_option_value%TYPE;

BEGIN

OPEN get_profile;
FETCH get_profile INTO l_profile_value;
IF (get_profile%NOTFOUND) THEN
   l_profile_value := NULL;
END IF;
CLOSE get_profile;

RETURN l_profile_value;

END GET_PROFILE_VALUE;


/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_validation
--
--  DESCRIPTION:
--    This does a pre_migration validation on the Quality Tables.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--=========================================================================== */

PROCEDURE GMD_QC_MIGRATE_VALIDATION
( p_migration_run_id IN  NUMBER
, x_exception_count  OUT NOCOPY NUMBER)

IS

l_lab_profile       fnd_profile_option_values.profile_option_value%TYPE;

/*=====================================
   Cursor to get default Stability
   Study Org from setup tables.
  =====================================*/

CURSOR get_ss_org IS
SELECT default_stability_study_org
FROM   gmd_migrate_parms;

l_def_ss_org          gmd_migrate_parms.default_stability_study_org%TYPE;

BEGIN

x_exception_count := 0;

/*==============================================
   Get Default Lab Type Profile Value
  ==============================================*/

l_lab_profile :=  GMD_QC_MIGV12.GET_PROFILE_VALUE('GEMMS_DEFAULT_LAB_TYPE');


IF (l_lab_profile IS NULL) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEFAULT_LAB_NULL',
	       p_context         => 'Quality Validation',
	       p_app_short_name  => 'GMD');
   x_exception_count := x_exception_count + 1;
END IF;

EXCEPTION

WHEN OTHERS THEN

   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id => p_migration_run_id,
       p_log_level => FND_LOG.LEVEL_UNEXPECTED,
       p_message_token => 'GMA_MIGRATION_DB_ERROR',
       p_context         => 'Quality Validation',
       p_db_error        => SQLERRM,
       p_app_short_name  => 'GMA');

   x_exception_count := x_exception_count + 1;

END GMD_QC_MIGRATE_VALIDATION;

END;

/
