--------------------------------------------------------
--  DDL for Package FEM_BR_DIM_LDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_DIM_LDR_PVT" AUTHID CURRENT_USER AS
   /* $Header: FEMDIMLDRS.pls 120.0 2006/05/18 01:40:01 ugoswami noship $ */

  PROCEDURE DeleteObjectDefinition(
    p_obj_def_id          IN          NUMBER
  );


  PROCEDURE CopyObjectDefinition(
     p_source_obj_def_id   IN          NUMBER
    ,p_target_obj_def_id   IN          NUMBER
    ,p_created_by          IN          NUMBER
    ,p_creation_Date       IN          DATE
  );

  FUNCTION DefinitionDetailsExist(
      p_obj_def_id       IN         NUMBER

  )

  RETURN VARCHAR2;

END FEM_BR_DIM_LDR_PVT;


 

/
