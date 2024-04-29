--------------------------------------------------------
--  DDL for Package BSC_TAB_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_TAB_TPLATE" AUTHID CURRENT_USER AS
/* $Header: BSCUTABS.pls 115.4 2003/01/14 23:54:49 meastmon ship $ */


/*===========================================================================+
|
|   Name:          Create_Tab_Template
|
|   Description:   To create a tab system layout.
|                  The following are the insertion order of tables:
|
|			1.  MNAV_SYSTEMS
|			2.  MNAV_INTERMEDIATE_GROUPS
|			3.  MNAV_INTERMEDIATE_GROUPS_L
|			4.  MATRIX
|			5.  MATRIX_INFO
|			6.  MATRIX_LANGUAGE
|			7.  MIND_ANALYSIS
|			8.  MIND_CALCULATIONS
|			9.  MIND_FIELDS
|			40. MIND_DATA
|			11. MIND_DATA_SERIE
|			12. MIND_DRILLS_CONFIG
|			13. MIND_DRILLS
|			14. MIND_DRILLS_LANGUAGE
|			15. MIND_OPTIONS
|			16. MIND_PERIODS
|			17. MIND_PERIODS_LANGUAGE
|			18. MIND_TABLES_NEW
|			19. MNAV_INDICATORS_BY_SYSTEM
|
+============================================================================*/

Function Create_Tab_Template Return Boolean;



END BSC_TAB_TPLATE;

 

/
