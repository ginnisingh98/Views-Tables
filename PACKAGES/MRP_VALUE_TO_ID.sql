--------------------------------------------------------
--  DDL for Package MRP_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: MRPSVIDS.pls 115.1 99/07/16 12:38:21 porting ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Value_To_Id functions.

--  START GEN value_to_id

--  Generator will append new prototypes before end generate comment.
FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
) RETURN NUMBER;

--  Completion_Locator

FUNCTION Completion_Locator
(   p_completion_locator            IN  VARCHAR2
) RETURN NUMBER;

--  Line

FUNCTION Line
(   p_line                          IN  VARCHAR2
) RETURN NUMBER;

--  Organization

FUNCTION Organization
(   p_organization                  IN  VARCHAR2
) RETURN NUMBER;

--  Primary_Item

FUNCTION Primary_Item
(   p_primary_item                  IN  VARCHAR2
) RETURN NUMBER;

--  Project

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER;

--  Schedule_Group

FUNCTION Schedule_Group
(   p_schedule_group                IN  VARCHAR2
) RETURN NUMBER;

--  Task

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER;

--  Wip_Entity

FUNCTION Wip_Entity
(   p_wip_entity                    IN  VARCHAR2
) RETURN NUMBER;
--  END GEN value_to_id

END MRP_Value_To_Id;

 

/
