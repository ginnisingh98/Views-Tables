--------------------------------------------------------
--  DDL for Package Body ECE_ERROR_HANDLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_ERROR_HANDLING_PVT" AS
-- $Header: ECERRHLB.pls 115.3 99/08/23 15:40:03 porting ship $

   PROCEDURE Print_Parse_Error (
      p_err_pos        IN   NUMBER,
      p_string         IN   VARCHAR2) IS

      l_start_pos           NUMBER;
      l_new_length          NUMBER := 100;
      l_new_err_pos         NUMBER;
      l_pad                 NUMBER := 50;

   BEGIN
      ec_debug.push ('ECE_ERROR_HANDLING_PVT.Print_Parse_Error');
      if (p_err_pos > l_pad) then
         l_start_pos := p_err_pos - l_pad;
      else
         l_start_pos := 0;
      end if;

      l_new_err_pos := p_err_pos - l_start_pos + 1;

      ec_debug.pl (0,'EC', 'ECE_PARSING_ERROR', 'ERROR_POSITION', l_new_err_pos );
      ec_debug.pl (0,substrb(p_string, l_start_pos, l_new_length));
      ec_debug.pl (0,'EC', 'ECE_ERROR_CODE', 'ERROR_CODE', SQLCODE);
      ec_debug.pl (0,'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
      ec_debug.pop ('ECE_ERROR_HANDLING_PVT.Print_Parse_Error');
   END Print_Parse_Error;

END ECE_ERROR_HANDLING_PVT;


/
