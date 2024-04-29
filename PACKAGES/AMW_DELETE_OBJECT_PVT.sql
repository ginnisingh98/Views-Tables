--------------------------------------------------------
--  DDL for Package AMW_DELETE_OBJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_DELETE_OBJECT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvobjs.pls 120.0.12000000.2 2007/03/09 10:03:08 psomanat ship $ */

-- ===============================================================
-- Package name
--          AMW_DELETE_OBJECT_PVT
-- Purpose
-- 		  	for handling object actions
--
-- History
-- 		  	12/06/2004    tsho     Creates
-- ===============================================================

TYPE G_NUMBER_TABLE IS TABLE OF NUMBER;

TYPE G_VARCHAR_VARRAY IS VARRAY(2) OF VARCHAR2(1000);
TYPE G_VARRAY_TABLE IS TABLE OF G_VARCHAR_VARRAY;


-- ===============================================================
-- Procedure name
--          Delete_Objects
-- Purpose
-- 		  	Delete specified Objs if it's allowed (ie, if it's not in use by others)
-- Params
--          p_object_type_and_id1      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id2      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id3      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
--          p_object_type_and_id4      := the obj needs to be checked (format: OBJECT_TYPE#OBJECT_ID)
-- Notes
--          format for Risk: RISK#113
--          format for Control: CTRL#113
--          format for Audit Procedure: AP#113
-- ===============================================================
PROCEDURE Delete_Objects(
    errbuf                       OUT  NOCOPY VARCHAR2,
    retcode                      OUT  NOCOPY VARCHAR2,
    p_object_type_and_id1         IN   VARCHAR2 := NULL,
    p_object_type_and_id2         IN   VARCHAR2 := NULL,
    p_object_type_and_id3         IN   VARCHAR2 := NULL,
    p_object_type_and_id4         IN   VARCHAR2 := NULL
);


-- ===============================================================
-- Procedure name
--          Delete_Object
-- Purpose
-- 		  	Delete specified Obj if it's allowed (ie, if it's not in use by others)
-- Params
--          p_object_type      := the obj needs to be checked,
--          p_object_id        := the id of specified obj
-- ===============================================================
PROCEDURE Delete_Object(
    p_object_type                IN   VARCHAR2,
    p_object_id                  IN   NUMBER
);


-- ===============================================================
-- Procedure name
--          Delete_Risk
-- Purpose
-- 		  	Delete specified risk
-- Params
--          p_risk_id
-- ===============================================================
PROCEDURE Delete_Risk(
    p_risk_id                  IN   NUMBER
);

-- ===============================================================
-- Procedure name
--          Delete_Ctrl
-- Purpose
-- 		  	Delete specified control
-- Params
--          p_ctrl_id
-- ===============================================================
PROCEDURE Delete_Ctrl(
    p_ctrl_id                  IN   NUMBER
);


-- ===============================================================
-- Procedure name
--          Delete_Ap
-- Purpose
-- 		  	Delete specified audit procedure
-- Params
--          p_ap_id
-- ===============================================================
PROCEDURE Delete_Ap(
    p_ap_id                  IN   NUMBER
);




-- ===============================================================
-- Function name
--          Is_Record_Exist
-- Purpose
-- 		  	check if any records found for pass-in query
--          return BOOLEAN TRUE if at least one record is found;
--          return BOOLEAN FALSE otherwise.
-- Params
--          p_dynamic_sql      := the sql needs to be checked,
--                                can have variables defined(ie. :1 :2 ...etc)
--          p_bind_value       := default is Null.
--                               this param is required if variables are defined in p_dynamic_sql param.
--
-- ===============================================================
FUNCTION Is_Record_Exist(
    p_dynamic_sql      IN         G_VARCHAR_VARRAY,
    p_bind_value       IN         NUMBER := NULL
)
RETURN BOOLEAN;


-- ===============================================================
-- Function name
--          Is_Object_In_Use
-- Purpose
-- 		  	check if any records found for pass-in query check list
--          return 'Y' if at least one record is found;
--          return 'N' otherwise.
-- Params
--          p_dynamic_sql      := the sql needs to be checked,
--                                can have variables defined(only allow :1 )
--          p_bind_value       := default is Null.
--                               this param is required if variables are defined in p_dynamic_sql param.
-- Notes
--          can only bind same value to the variables (:1) defined in  p_dynamic_sql
-- ===============================================================
FUNCTION Is_Object_In_Use(
    p_dynamic_sql_list IN         G_VARRAY_TABLE,
    p_bind_value       IN         NUMBER := NULL
)
RETURN VARCHAR;


-- ----------------------------------------------------------------------
END AMW_DELETE_OBJECT_PVT;

 

/
