--------------------------------------------------------
--  DDL for Package JTF_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_OBJECTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvobms.pls 115.2 2002/05/08 17:23:41 pkm ship     $ */
--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : GET_OBJECT_INSTANCE_NAME
--  Description : Will determine the Name of the Object Instance based
--                on the objects definition in JTF_OBJECTS. This function
--                is used in the JTF_OBJECT_MAPPINGS_V.
--  Parameters  :
--      name                 direction  type        required?
--      ----                 ---------  ----        ---------
--      p_ObjectCode         IN         VARCHAR2   required
--      p_ObjectID           IN         VARCHAR2   required
--      RETURN                          VARCHAR2
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
FUNCTION GET_OBJECT_INSTANCE_NAME
( p_ObjectCode IN VARCHAR2
, p_ObjectID   IN VARCHAR2
)RETURN VARCHAR2;

END JTF_OBJECTS_PVT;

 

/
