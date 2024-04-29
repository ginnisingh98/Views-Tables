--------------------------------------------------------
--  DDL for Package IBC_DEBUG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_DEBUG_PVT" AUTHID CURRENT_USER AS
  /* $Header: ibcdbugs.pls 115.2 2003/08/14 18:35:09 enunez ship $ */

  -- --------------------------------------------------------------------
  -- FUNCTION: Debug_Enabled
  -- DESCRIPTION: Returns TRUE if debug is enabled for current user
  --              based upon profile values, FALSE otherwise.
  -- --------------------------------------------------------------------
  FUNCTION Debug_Enabled
  RETURN BOOLEAN;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Start_Process
  -- DESCRIPTION: Marks the begin point of a procedure/function,
  --              This is used to keep a stack of calls.
  --              This procedure should be called at the begining of a
  --              procedure or function.
  -- --------------------------------------------------------------------
  PROCEDURE Start_Process(p_proc_type IN VARCHAR2,
                          p_proc_name IN VARCHAR2,
                          p_parms     IN VARCHAR2 := NULL);

  -- --------------------------------------------------------------------
  -- FUNCTION: Make_List
  -- DESCRIPTION: Makes a list of values (enclosed in [] and separated
  --              commas) from a JTF table being passed.
  --              Useful when debugging the content of JTF tables being
  --              passed as parameters.
  --              Returns the list.
  -- --------------------------------------------------------------------
  FUNCTION Make_List(p_values IN JTF_NUMBER_TABLE)
  RETURN VARCHAR2;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_100)
  RETURN VARCHAR2;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_300)
  RETURN VARCHAR2;

  -- Overloaded
  FUNCTION Make_List(p_values IN JTF_VARCHAR2_TABLE_4000)
  RETURN VARCHAR2;

  -- Overloaded
  FUNCTION Make_List_VC32767(p_values IN JTF_VARCHAR2_TABLE_32767)
  RETURN VARCHAR2;

  -- --------------------------------------------------------------------
  -- FUNCTION: Make_Parameter_List
  -- DESCRIPTION: Creates a parameter list (with tags for each parameter)
  --              Useful when calling Start_PRocess for "parms" parameter
  -- --------------------------------------------------------------------
  FUNCTION Make_Parameter_List(p_tag IN VARCHAR2,
                               p_parms IN JTF_VARCHAR2_TABLE_4000)
  RETURN VARCHAR2;

  -- Overloaded
  FUNCTION Make_Parameter_List(p_tag IN VARCHAR2,
                               p_parms IN JTF_VARCHAR2_TABLE_32767)
  RETURN VARCHAR2;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Debug_Message
  -- DESCRIPTION: Outputs p_message in case debug is enabled.
  -- --------------------------------------------------------------------
  PROCEDURE Debug_Message(p_message IN VARCHAR2);

  -- --------------------------------------------------------------------
  -- PROCEDURE: End_Process
  -- DESCRIPTION: Signals the end of a process (PROCEDURE or FUNCTION)
  --              This procedure should be called at the end of a
  --              procedure or function.
  -- --------------------------------------------------------------------
  PROCEDURE End_Process(p_output_list IN VARCHAR2 := NULL);

  -- --------------------------------------------------------------------
  -- PROCEDURE: Terminate_Stack
  -- DESCRIPTION: Flushes all Processes in the stack
  --              Useful when catching exceptions, and finishing the
  --              debugging.
  -- --------------------------------------------------------------------
  PROCEDURE Terminate_Stack;

END IBC_DEBUG_PVT;

 

/
