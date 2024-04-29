--------------------------------------------------------
--  DDL for Package Body ECX_ERROR_HANDLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_ERROR_HANDLING_PVT" AS
-- $Header: ECXERRHB.pls 120.2 2006/05/24 16:26:13 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

   PROCEDURE Print_Parse_Error (
      p_err_pos        IN   PLS_INTEGER,
      p_string         IN   VARCHAR2) IS

      i_method_name   varchar2(2000) := 'ecx_error_handling_pvt.print_parse_error';

      l_start_pos           PLS_INTEGER;
      l_new_length          PLS_INTEGER := 100;
      l_new_err_pos         PLS_INTEGER;
      l_pad                 PLS_INTEGER := 50;

   BEGIN
      if (l_procedureEnabled) then
          ecx_debug.push(i_method_name);
      end if;
      if (p_err_pos > l_pad) then
         l_start_pos := p_err_pos - l_pad;
      else
         l_start_pos := 0;
      end if;

      l_new_err_pos := p_err_pos - l_start_pos + 1;


      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'ECX', 'ECX_PARSING_ERROR', i_method_name,
                     'ERROR_POSITION', l_new_err_pos );
         ecx_debug.log (l_statement,substrb(p_string, l_start_pos, l_new_length),i_method_name);
         ecx_debug.log (l_statement,'ECX', 'ECX_ERROR_CODE', i_method_name,'ERROR_CODE', SQLCODE);
         ecx_debug.log (l_statement,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;

      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
   END Print_Parse_Error;

END ECX_ERROR_HANDLING_PVT;


/
