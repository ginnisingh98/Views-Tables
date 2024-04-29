--------------------------------------------------------
--  DDL for Package MRP_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ID_TO_VALUE" AUTHID CURRENT_USER AS
/* $Header: MRPSIDVS.pls 115.1 99/07/16 12:37:47 porting ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.

FUNCTION Completion_Locator
(   p_completion_locator_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Primary_Item
(   p_primary_item_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Schedule_Group
(   p_schedule_group_id             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Wip_Entity
(   p_wip_entity_id                 IN  NUMBER
) RETURN VARCHAR2;
--  END GEN Id_To_Value

END MRP_Id_To_Value;

 

/
