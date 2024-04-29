--------------------------------------------------------
--  DDL for Package Body PA_PJI_MENU_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PJI_MENU_UTIL" as
/* $Header: PAPJIMSB.pls 120.0 2005/05/30 09:06:04 appldev noship $ */


----------------------------------------------------------------------------
--Procedure     ENABLE_CONCCURRENT_PROGRAMS
--
--Description   This API adds DBI concurrent programs to PA request groups
--              to enable PA customers to use Utilization using PJI data model
--              This is a PRIVATE procedure local to this package only
--Created by    virangan
--Creation Date 18-JUN-2003
----------------------------------------------------------------------------
PROCEDURE enable_concurrent_programs IS
    l_reqgrp_name VARCHAR2(30);
BEGIN

    ------------------------
    --Identify Request group
    ------------------------
	IF fnd_program.request_group_exists ( 'All Projects Programs', 'PA') THEN
	    l_reqgrp_name := 'All Projects Programs';
	ELSIF fnd_program.request_group_exists ( 'All PRM Programs', 'PA') THEN
	    l_reqgrp_name := 'All PRM Programs';
        ELSE
	    return;
	END IF;

	-------------------------------------------
        --Check if program exists in request group
         -------------------------------------------
	IF fnd_program.program_in_group('FII_TIME_C', 'FII', l_reqgrp_name, 'PA') THEN
	    --Exit if program is already in request group
		--ensures that we add program only once
	    return;
	ELSE
	    ---------------------------------------------------------
	    --Add programs to Request group All program required for
	    --PJI implementation of Util. consolidation are added
            ---------------------------------------------------------
		fnd_program.add_to_group('FII_TIME_C', 'FII', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PERSLM', 'PER', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('HRISUPCR', 'HRI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('HRIORGCR', 'HRI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_FM_SUMMARIZE_UPDATE', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_RM_SUMMARIZE_UPDATE', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_FM_SUMMARIZE_REFRESH', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_RM_SUMMARIZE_REFRESH', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_MV_REFRESH', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_SUM_CLEANALL', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_SECURITY_REPORT', 'PJI', l_reqgrp_name, 'PA');
		fnd_program.add_to_group('PJI_SETUP_REPORT', 'PJI', l_reqgrp_name, 'PA');

        COMMIT;

	END IF;

EXCEPTION
    WHEN OTHERS THEN
	    null;
END enable_concurrent_programs;

------------------------------------------------------------------------------
--Procedure     ENABLE_MENUS
--
--Description   This API corrects the Utiization menus based on whether
--              PJI is installed or not (Utilization Consoilidation patch
--              is applied or not)
--              Note: PJI installed => Utilization Consolidation patch applied
--                    PJI licensed  => PJI is implemented
--Created by    virangan
--Creation Date 29-MAY-2003
-------------------------------------------------------------------------------
PROCEDURE ENABLE_MENUS
  IS
  BEGIN

      -----------------------------------------------------------------------
      --This API enables the correct Utilization menus based on whether PJI
      --is installed or not. The logic is to delete exclusion rules for PJI
      --functions and add exclusion rules for PA functions if PJI is instaled
      --i.e. Utilization Consolidation patch is applied. If not do the opposite
      --i.e delete PA function exlusion rules and PJI function exclusion.
      --The table below summarizes the complete list of functions
      -----------------------------------------------------------------------
      -- Responsibility	  PJI Functions	           PA Functions
      -----------------------------------------------------------------------
      -- PA_PRM_PROJ_SU   PA_ORG_UTIL_DIS          PA_ORG_UTILIZATION
      --                  PA_RES_UTIL_DIS          PA_RES_MGR_UTILIZATION
      --                  PA_MGR_UTIL_DIS          PA_PRM_MY_UTIL
      --                  PJI_SETUP
      --
      -- PA_PRM_RES_MGR   PA_ORG_UTIL_DIS          PA_ORG_UTILIZATION
      --                  PA_RES_UTIL_DIS          PA_RES_MGR_UTILIZATION
      --                  PA_MGR_UTIL_DIS
      --
      -- PA_PRM_ORG_MGR   PA_ORG_UTIL_DIS          PA_ORG_UTILIZATION
      --                  PA_RES_UTIL_DIS          PA_RES_MGR_UTILIZATION
      --                  PA_MGR_UTIL_DIS          PA_PRM_MY_UTIL
      --                                           PA_PRM_UTL_AUTH
      --
      -- PA_PRM_TEAM_MEM  PJI_PRM_MY_UTIL          PA_PRM_MY_UTIL
      -----------------------------------------------------------------------

      IF PA_INSTALL.is_pji_installed = 'Y' THEN

          --Enable all PJI Utilization menu entries by deleting PJI function
          --exclusion rules

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN


              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_SETUP') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_SETUP',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS',
                          DELETE_FLAG        => 'Y');
          END IF;

        --Commented out for FP.L but is required for FP.K
        /*  IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_PRM_MY_UTIL',
                          DELETE_FLAG        => 'Y');
          END IF;*/

          --Disable all PA Utilization menu entries by adding PA function
          --exclusion rules

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION');

          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'M',
                          RULE_NAME          => 'PA_PRM_UTL_AUTH') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'M',
                          RULE_NAME          => 'PA_PRM_UTL_AUTH');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL');
          END IF;

          -------------------------------------------------------------
          --Enable All concurrent programs required for PJI Utilization
          --under PA responsibility
          -------------------------------------------------------------
          enable_concurrent_programs;

      ELSE   --Enable all PA Utilization menu entries

          --Enable all PA Utilization menu entries by deleting PA function
          --exclusion rules
          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION',
                          DELETE_FLAG        => 'Y');

          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION',
                          DELETE_FLAG        => 'Y');
          END IF;


          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_MGR_UTILIZATION',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTILIZATION',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'M',
                          RULE_NAME          => 'PA_PRM_UTL_AUTH') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'M',
                          RULE_NAME          => 'PA_PRM_UTL_AUTH',
                          DELETE_FLAG        => 'Y');
          END IF;

          IF FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_PRM_MY_UTIL',
                          DELETE_FLAG        => 'Y');
          END IF;

          --Disable all PJI Utilization menu entries by adding PJI function
          --exclusion rules
          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN


              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_SETUP') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_PROJ_SU',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_SETUP');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_RES_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_ORG_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_RES_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_ORG_MGR',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PA_MGR_UTIL_DIS');
          END IF;

          IF NOT FND_FUNCTION_SECURITY.SECURITY_RULE_EXISTS (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_PRM_MY_UTIL') THEN

              FND_FUNCTION_SECURITY.SECURITY_RULE (
                          RESPONSIBILITY_KEY => 'PA_PRM_TEAM_MEM',
                          RULE_TYPE          => 'F',
                          RULE_NAME          => 'PJI_PRM_MY_UTIL');
          END IF;

      END IF;

  END ENABLE_MENUS;



end PA_PJI_MENU_UTIL;

/
