--------------------------------------------------------
--  DDL for Package Body PAY_DK_TAX_CARD_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_TAX_CARD_REQUEST_PKG" as
/* $Header: pydktcrq.pkb 120.0 2005/05/29 04:21:26 appldev noship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_DK_TAX_CARD_REQUEST_PKG.';

-----------------------------------------------------------------------------
--RANGE CODE
-----------------------------------------------------------------------------

PROCEDURE range_cursor(p_payroll_action_id     IN  NUMBER,
                       p_sqlstr OUT NOCOPY VARCHAR2)
IS
BEGIN

p_sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';

END range_cursor;

-----------------------------------------------------------------------------
--ASSIGNMENT ACTION CODE
-----------------------------------------------------------------------------

PROCEDURE assignment_action_code(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER)
IS
BEGIN
null;

END assignment_action_code;


 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
 FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1);
   l_proc VARCHAR2(60);
 BEGIN
   l_delimiter :=' ';
   l_proc := g_package||' get parameter ';

   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   end if;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   RETURN l_parameter;
 END get_parameter;

END PAY_DK_TAX_CARD_REQUEST_PKG;

/
