--------------------------------------------------------
--  DDL for Package AD_PATCH_ANALYSIS_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PATCH_ANALYSIS_ENGINE" 
/* $Header: adpaengs.pls 120.2 2007/03/28 08:13:46 vlim ship $ */
AUTHID CURRENT_USER AS

  TYPE typeHashVarchar IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);

  ----------------------------------------------------------------------------
  -- Procedure to print out the usage of this package.
  ----------------------------------------------------------------------------
  PROCEDURE usage;

  ----------------------------------------------------------------------------
  -- Procedure to initialize the global variables.
  ----------------------------------------------------------------------------
  PROCEDURE initialize;

  ----------------------------------------------------------------------------
  -- Function to print messages on console
  ----------------------------------------------------------------------------
  PROCEDURE debugPrint
  ( p_message       IN   VARCHAR2
  );

  ----------------------------------------------------------------------------
  -- Get the value from desired hash
  ----------------------------------------------------------------------------
  FUNCTION getValueFromHash
  ( p_key           IN   VARCHAR2,
    p_hash          IN   typeHashVarchar
  )
  RETURN VARCHAR2;

  ----------------------------------------------------------------------------
  -- Function to compare the the 2 inputs codelevels.
  ----------------------------------------------------------------------------
   FUNCTION compareLevel
   ( p_level_1       IN   VARCHAR2 DEFAULT '',
     p_level_2       IN   VARCHAR2 DEFAULT ''
   )
   RETURN NUMBER;

  ----------------------------------------------------------------------------
  -- Function to validate and add the pre-reqs.
  ----------------------------------------------------------------------------
  PROCEDURE addPrereq
  ( p_te_abbr	        IN      VARCHAR2 ,
    p_te_level          IN      VARCHAR2 ,
    p_hashRequires      IN OUT  NOCOPY typeHashVarchar
  );

  ----------------------------------------------------------------------------
  -- Function to get the status of the user input patch and baseline.
  ----------------------------------------------------------------------------
  FUNCTION getPatchStatus
  ( p_bug_number        IN    NUMBER,
    p_baseline          IN    VARCHAR2,
    p_release           IN    VARCHAR2,
    p_err_message       OUT   NOCOPY VARCHAR2
  )
  RETURN VARCHAR2;

  ----------------------------------------------------------------------------
  -- Function to get the status of the user input patch and baseline.
  ----------------------------------------------------------------------------
  FUNCTION getPatchStatus
  ( p_bug_number        IN    NUMBER,
    p_baseline          IN    VARCHAR2,
    p_release           IN    VARCHAR2,
    p_err_message       OUT   NOCOPY  VARCHAR2,
    p_analysis_run_id   IN    NUMBER ,
    p_user_id           IN    NUMBER ,
    p_overwrite         IN    BOOLEAN   DEFAULT   FALSE
  )
  RETURN VARCHAR2;

END ad_patch_analysis_engine;

/
