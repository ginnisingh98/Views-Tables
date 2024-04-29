--------------------------------------------------------
--  DDL for Package Body PA_STRUCT_UPGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STRUCT_UPGR_PUB" AS
/* $Header: PAPRUPGB.pls 120.0 2005/05/29 19:58:26 appldev noship $ */

-- Assumptions:
-- This function is called in the display sequence order
-- CLEAR_GLOBALS is called before calling this function for a new project. This assumption no longer valid due to fix of Bug No. 4049574.

-- Bug No. 4049574. Added additional parameter p_project_id.
FUNCTION GET_WBS_NUMBER
(p_wbs_level IN NUMBER, p_project_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
  l_prev_wbs_num VARCHAR2(255);
  l_new_wbs_num  VARCHAR2(255);
  l_pivot        NUMBER;
  l_str1         VARCHAR2(255);
  l_str2         VARCHAR2(10);
BEGIN
  -- Bug No. 4049574
  if p_project_id IS NOT NULL then
    if nvl(G_PROJECT_ID, -111) <> p_project_id then
      G_PROJECT_ID := p_project_id;
      PA_STRUCT_UPGR_PUB.CLEAR_GLOBALS;
    end if;
   end if;
  -- End Bug No. 4049574

  if g_wbs_num_tbl.exists(p_wbs_level) then
    -- Peer to an existing task at this wbs level
    l_prev_wbs_num := g_wbs_num_tbl(p_wbs_level);
    l_pivot := instr(l_prev_wbs_num, '.', -1);

    if l_pivot = 0 then
      -- This is a top level task
      l_new_wbs_num := to_char(to_number(l_prev_wbs_num) + 1);
    else
      l_str1 := substr(l_prev_wbs_num, 1, l_pivot);
      l_str2 := substr(l_prev_wbs_num, l_pivot + 1);

      -- Increment the wbs number by 1
      l_str2 := to_char(to_number(l_str2) + 1);
      l_new_wbs_num := l_str1 || l_str2;
    end if;
  else
    -- First task at this wbs level (for this top task hierarchy)
    if p_wbs_level = 1 then
      l_new_wbs_num := '1';
    else
      l_prev_wbs_num := g_wbs_num_tbl(p_wbs_level - 1);
      l_new_wbs_num := l_prev_wbs_num || '.1';
    end if;
  end if;

  -- Store the newly calculated wbs_number in the global table
  g_wbs_num_tbl(p_wbs_level) := l_new_wbs_num;

  -- Need to clear the stored wbs num of child level if
  -- parent wbs num is updated
  if p_wbs_level < g_max_wbs_level then
    if g_wbs_num_tbl.exists(p_wbs_level + 1) then
      g_wbs_num_tbl.delete(p_wbs_level + 1);
    end if;
  end if;

  -- Update g_max_wbs_level
  if p_wbs_level > g_max_wbs_level then
    g_max_wbs_level := p_wbs_level;
  end if;

  return l_new_wbs_num;

EXCEPTION
WHEN OTHERS THEN
  return NULL;

END GET_WBS_NUMBER;


PROCEDURE CLEAR_GLOBALS
IS
BEGIN

  g_max_wbs_level := 1;
  g_wbs_num_tbl.delete;

  --maansari
  G_DISP_SEQ_TBL.delete;
  --maansari

END CLEAR_GLOBALS;

-- Assumptions:
-- This function is called in the display sequence order.
-- CLEAR_GLOBALS is called before calling this function for new set of tasks
--Usage
--This function is used in publish_structure api to use in bulk insert
FUNCTION GET_DISP_SEQUENCE
(p_display_sequence IN NUMBER)
RETURN NUMBER IS
  l_new_index   NUMBER := 0;
  l_disp_seq    NUMBER;
BEGIN

  if not g_disp_seq_tbl.exists(1)
  then
      If p_display_sequence > 1 or p_display_sequence = 1
      then
         l_disp_seq := 1;
      end if;
  else
      l_new_index := g_disp_seq_tbl.count;
      IF p_display_sequence - g_disp_seq_tbl(g_disp_seq_tbl.count) > 1
      THEN
         l_disp_seq := p_display_sequence - ( p_display_sequence - 1 - l_new_index );
      ELSIF p_display_sequence - g_disp_seq_tbl(g_disp_seq_tbl.count) = 1
      THEN
         l_disp_seq := p_display_sequence;
      END IF;
  end if;
  g_disp_seq_tbl(l_new_index+1) := l_disp_seq;
  return l_disp_seq;

END GET_DISP_SEQUENCE;



END PA_STRUCT_UPGR_PUB;

/
