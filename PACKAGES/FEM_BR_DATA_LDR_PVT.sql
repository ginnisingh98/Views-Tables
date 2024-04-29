--------------------------------------------------------
--  DDL for Package FEM_BR_DATA_LDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_DATA_LDR_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMDATALDRS.pls 120.0 2006/05/17 22:31:29 ugoswami noship $ */

PROCEDURE DeleteObjectDefinition (
  p_obj_def_id 		IN 	    NUMBER

  );

PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE

);

PROCEDURE CopyObjectDetails (
  p_copy_type_code      IN          VARCHAR2
  ,p_source_obj_id      IN          NUMBER
  ,p_target_obj_id      IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
);

FUNCTION FindDefinition (
  p_object_definition_id IN 	    NUMBER
)RETURN VARCHAR2;

FUNCTION GetLoaderType (
  p_object_id IN 	    NUMBER
)RETURN VARCHAR2;


END FEM_BR_DATA_LDR_PVT;

 

/
