--------------------------------------------------------
--  DDL for Package WMS_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ASSIGNMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPPAS.pls 120.0 2005/05/24 18:12:48 appldev noship $ */
-- File        : WMSVPPAS.pls
-- Content     : WMS_Assignment_PVT package specification
-- Description : Private API functions and procedures needed for
--               wms strategy assignment implementation.
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created
--               11/10/99 bitang moved to wms
-- Local copies of fnd globals to prevent pragma violations of api functions
g_miss_num  constant number      := fnd_api.g_miss_num;
g_miss_char constant varchar2(1) := fnd_api.g_miss_char;
g_miss_date constant date        := fnd_api.g_miss_date;
--
-- API name    : GetObjectValueName
-- Type        : Private
-- Function    : Returns the current name of the business object instance a
--               wms strategy is assigned to.
--               ( Needed for forms base views of strategy assignment forms )
-- Input Parameters:
--   p_object_type_code:  1 - system defined ; 2 - user defined
--   p_object_id       :  object identifier
--   p_pk1_value       :  primary key value 1
--   p_pk2_value       :  primary key value 2
--   p_pk3_value       :  primary key value 3
--   p_pk4_value       :  primary key value 4
--   p_pk5_value       :  primary key value 5
--
-- Notes       : Since it is not possible to use dynamic SQL within package
--               functions without violating the WNPS pragma, cursors are
--               hard coded instead of getting the actual SQL statement from
--               WMS_OBJECTS_B table ( analogous to LOV for insert in setup
--               form ) to be able to use function together with 'where' and
--               'order by' clauses in regular SQL.
-- Important:
--               EACH AND EVERY BUSINESS OBJECT IN WMS_OBJECTS_B ENABLED
--               TO TIE STRATEGIES TO IT MUST BE REPRESENTED WITHIN THIS
--               FUNCTION APROPRIATELY IN ORDER TO BE ABLE TO RE-QUERY SET UP
--               STRATEGY ASSIGNMENTS !
-- More:         The parama is no longer needed for Oracle 8i
FUNCTION GetObjectValueName
  ( p_object_type_code   IN NUMBER   DEFAULT g_miss_num
   ,p_object_id          IN NUMBER   DEFAULT g_miss_num
   ,p_pk1_value          IN VARCHAR2 DEFAULT g_miss_char
   ,p_pk2_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk3_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk4_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk5_value          IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;
--pragma definition is no longer needed
--pragma restrict_references(GetObjectValueName, WNDS, WNPS);
END wms_assignment_pvt;

 

/
