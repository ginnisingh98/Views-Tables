--------------------------------------------------------
--  DDL for Package JTF_TAE_SQL_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_SQL_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtsls.pls 120.0 2005/06/02 18:23:05 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_SQL_LIB_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This is to store the commonly used (hand-tuned) SQL
--      used by the TAE Generation Program
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      08/04/02    JDOCHERT  Created
--
--    End of Comments
--

--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------
G_Debug                       BOOLEAN  := FALSE;
g_ProgramStatus               NUMBER   := 0;

/* jdochert: 07/31/02 */
G_NEWLINE        VARCHAR2(30) := FND_GLOBAL.Local_Chr(10);

G_INDENT         VARCHAR2(30) := '            ';

G_INDENT1        VARCHAR2(30) := '   ';
G_INDENT2        VARCHAR2(30) := '      ';
G_INDENT3        VARCHAR2(30) := '         ';
G_INDENT4        VARCHAR2(30) := '            ';
G_INDENT5        VARCHAR2(30) := '               ';

--
-- Function to return Static Inline view SQL
--
--FUNCTION append_inlineview(p_input_string IN VARCHAR2)
--RETURN VARCHAR2;

/*********************************************************
** Gets the Static pre-built, hand-tuned Index
** Creation Statement for certain Qualifier Combinations
**********************************************************/
PROCEDURE get_qual_comb_index (
      p_rel_prod                  IN   NUMBER,
      p_reverse_flag              IN   VARCHAR2,
      p_source_id                 IN   NUMBER,
      p_trans_object_type_id      IN   NUMBER,
      p_table_name                IN   VARCHAR2,
      -- arpatel: 09/09/03 added run mode flag
      p_run_mode                  IN   VARCHAR2 := 'TAP',
      x_statement                 OUT NOCOPY  VARCHAR2,
      alter_statement             OUT NOCOPY  VARCHAR2);

/*************************************************
** Gets the Static pre-built, hand-tuned SQL
** for certain Qualifier Combinations
**************************************************/
PROCEDURE get_qual_comb_sql (
      p_rel_prod                  IN   NUMBER,
      p_source_id                 IN   NUMBER,
      p_trans_object_type_id      IN   NUMBER,
      p_table_name                IN   VARCHAR2,
      /* ARPATEL 03/11/2004 BUG#3489240 */
      p_match_table_name          IN   VARCHAR2 := NULL,
      -- dblee: 08/26/03 added new mode flag
      p_new_mode_fetch            IN   CHAR := 'N',
      x_sql                       OUT NOCOPY  VARCHAR2);


END JTF_TAE_SQL_LIB_PVT;


 

/
