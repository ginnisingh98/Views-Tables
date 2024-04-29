--------------------------------------------------------
--  DDL for Package XLA_MO_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MO_REPORTING_API" AUTHID CURRENT_USER AS
/*  $Header: XLAMORPS.pls 120.3 2003/07/01 17:38:40 iargyrio ship $ */


PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2 DEFAULT '3000'
   , p_reporting_entity_id    IN NUMBER
   , p_pred_type              IN VARCHAR2 DEFAULT 'AUTO'
  );
/*
FUNCTION Get_Predicate
  (  p_alias                  IN VARCHAR2 DEFAULT NULL
   , p_hint                   IN VARCHAR2 DEFAULT NULL
  )
RETURN VARCHAR2;
*/
FUNCTION Get_Predicate
  (  p_alias                  IN VARCHAR2 DEFAULT NULL
   , p_hint                   IN VARCHAR2 DEFAULT NULL
   , p_variable_override      IN VARCHAR2 DEFAULT ' :p_reporting_entity_id '
  )
RETURN VARCHAR2;

FUNCTION Get_Reporting_Entity_Name
RETURN VARCHAR2;

FUNCTION Get_Reporting_Level_Name
RETURN VARCHAR2;

PROCEDURE Validate_Reporting_Entity
  (  p_reporting_level           IN VARCHAR2
   , p_reporting_entity_id       IN NUMBER
  );

PROCEDURE Validate_Reporting_Level
  (  p_reporting_level          IN VARCHAR2 );

--
-- Do not use this procedure unless you have performance issues.
-- See bug 3025408 for details.
--
PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2 DEFAULT '3000'
   , p_reporting_entity_id    IN NUMBER
   , p_pred_type              IN VARCHAR2 DEFAULT 'AUTO'
   , p_use_nvl                IN VARCHAR2
  );

END XLA_MO_REPORTING_API;

 

/
