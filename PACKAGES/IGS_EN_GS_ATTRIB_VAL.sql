--------------------------------------------------------
--  DDL for Package IGS_EN_GS_ATTRIB_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GS_ATTRIB_VAL" AUTHID CURRENT_USER AS
/* $Header: IGSEN90S.pls 115.1 2002/11/29 00:13:00 nsidana noship $ */

-- Procedure to store the values in Attribute Values table.
PROCEDURE Set_Value(
  p_obj_type_id      IN  NUMBER,
  p_obj_id           IN  NUMBER,
  p_attrib_id        IN  NUMBER,
  p_version          IN  NUMBER,
  p_value            IN  VARCHAR2,
  x_return_code      OUT NOCOPY VARCHAR2
);

-- Function to return the values from Attribute Values table.
FUNCTION Get_Value (
  p_obj_type_id      IN  NUMBER,
  p_obj_id           IN  NUMBER,
  p_attrib_id        IN  NUMBER,
  p_version          IN  NUMBER
 )RETURN VARCHAR2 ;

PRAGMA RESTRICT_REFERENCES(Get_Value,RNPS,WNPS,WNDS);

END IGS_EN_GS_ATTRIB_VAL;

 

/
