--------------------------------------------------------
--  DDL for Package FND_MO_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MO_REPORTING_API" AUTHID CURRENT_USER AS
/*  $Header: FNDMORPS.pls 120.4 2005/07/02 03:11:45 appldev noship $ */


PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2
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


END FND_MO_REPORTING_API;

 

/
