--------------------------------------------------------
--  DDL for Package PA_STRUCT_UPGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STRUCT_UPGR_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPRUPGS.pls 120.0 2005/05/30 19:05:05 appldev noship $ */

-- Bug No. 4049574
G_PROJECT_ID NUMBER;

-- Global variable to store max wbs level
G_MAX_WBS_LEVEL   NUMBER := 1;

TYPE INDEX_TABLE IS TABLE OF VARCHAR2(255)
INDEX BY BINARY_INTEGER;

G_WBS_NUM_TBL  INDEX_TABLE;

FUNCTION GET_WBS_NUMBER
(p_wbs_level IN NUMBER, p_project_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;

--maansari
TYPE display_sequence_table IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
G_DISP_SEQ_TBL  display_sequence_table;

FUNCTION GET_DISP_SEQUENCE
(p_display_sequence IN NUMBER)
RETURN NUMBER;

--maansari

PROCEDURE CLEAR_GLOBALS;

END PA_STRUCT_UPGR_PUB;

 

/
