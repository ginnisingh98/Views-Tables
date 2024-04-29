--------------------------------------------------------
--  DDL for Package Body INV_PROJECTLOCATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PROJECTLOCATOR_PUB" AS
/* $Header: INVPJMAB.pls 120.0 2005/05/25 06:05:46 appldev noship $ */

/*
** This function is retained only for backward compatibility
** reasons.  The actual implementation has been migrated to
** PJM_PROJECT_LOCATOR under the PJM source tree.
*/
FUNCTION Check_Project_References(arg_organization_id IN NUMBER,
			  arg_locator_id IN NUMBER,
			  arg_validation_mode IN VARCHAR2,
			  arg_required_flag IN VARCHAR2,
			  arg_project_id IN NUMBER DEFAULT NULL,
			  arg_task_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN IS
l_return_code boolean;
BEGIN
    l_return_code := PJM_Project_Locator.Check_Project_References(
                          arg_organization_id,
			  arg_locator_id,
			  arg_validation_mode,
			  arg_required_flag,
			  arg_project_id,
			  arg_task_id,
                          NULL);
    return (l_return_code);

END Check_Project_References;

FUNCTION GET_PHYSICAL_LOCATION(
                               P_ORGANIZATION_ID IN NUMBER,
                               P_LOCATOR_ID      IN NUMBER
                              ) RETURN BOOLEAN IS
BEGIN

   RETURN PJM_PROJECT_LOCATOR.GET_PHYSICAL_LOCATION(
                              X_ORGANIZATION_ID => P_ORGANIZATION_ID,
                              X_LOCATOR_ID      => P_LOCATOR_ID
                                                   );

END GET_PHYSICAL_LOCATION;

FUNCTION GET_PROJECT_NUMBER(P_PROJECT_ID IN NUMBER) RETURN VARCHAR2 IS

BEGIN

   RETURN PJM_PROJECT.ALL_PROJ_IDTONUM(P_PROJECT_ID);

END GET_PROJECT_NUMBER;

FUNCTION GET_TASK_NUMBER(P_TASK_ID IN NUMBER) RETURN VARCHAR2 IS

BEGIN

   RETURN PJM_PROJECT.ALL_TASK_IDTONUM(P_TASK_ID);

END GET_TASK_NUMBER;

END INV_ProjectLocator_PUB;

/
