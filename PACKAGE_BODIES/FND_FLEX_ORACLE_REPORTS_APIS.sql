--------------------------------------------------------
--  DDL for Package Body FND_FLEX_ORACLE_REPORTS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_ORACLE_REPORTS_APIS" AS
/* $Header: AFFFORAB.pls 120.1.12010000.1 2008/07/25 14:14:12 appldev ship $ */

g_newline VARCHAR2(100);

----------------------------------------------------------------------
PROCEDURE flexsql(p_appl_short_name IN VARCHAR2,
                  p_code            IN VARCHAR2,
                  p_mode            IN VARCHAR2,
                  p_num             IN NUMBER DEFAULT 101,
                  p_multinum        IN VARCHAR2 DEFAULT 'N',
                  p_display         IN VARCHAR2 DEFAULT 'ALL',
                  p_showdepseg      IN VARCHAR2 DEFAULT 'Y',
                  p_tablealias      IN VARCHAR2 DEFAULT NULL,
                  p_operator        IN VARCHAR2 DEFAULT NULL,
                  p_operand1        IN VARCHAR2 DEFAULT NULL,
                  p_operand2        IN VARCHAR2 DEFAULT NULL,
                  x_output          OUT nocopy VARCHAR2)
  IS
BEGIN
   x_output := 'This API has not been implemented yet...';
END flexsql;

----------------------------------------------------------------------
PROCEDURE flexidval(p_appl_short_name   IN VARCHAR2,
                    p_code              IN VARCHAR2,
                    p_data              IN VARCHAR2,
                    p_num               IN NUMBER DEFAULT 101,
                    p_multinum          IN VARCHAR2 DEFAULT 'N',
                    p_display           IN VARCHAR2 DEFAULT 'ALL',
                    p_idisplay          IN VARCHAR2 DEFAULT 'ALL',
                    p_showdepseg        IN VARCHAR2 DEFAULT 'Y',
                    p_dinsert           IN VARCHAR2 DEFAULT 'N',
                    p_output_array_size IN BINARY_INTEGER,
                    px_output_array     IN OUT nocopy flexidval_output_arr_type)
  IS
BEGIN
   FOR i IN 1..p_output_array_size LOOP
      px_output_array(i).value := 'This API has not been implemented yet...';
   END LOOP;
END flexidval;

----------------------------------------------------------------------
-- PROCEDURE : sample_package
--
-- PL/SQL examples of public APIs in this package.
--
----------------------------------------------------------------------
PROCEDURE sample_package
  IS
     l_p_flexdata VARCHAR2(32000);
     l_p_where    VARCHAR2(32000);
     l_p_operand1 VARCHAR2(32000);
BEGIN
   --
   -- Before Report Trigger actions
   --

   --
   -- Get the SELECT portion of my query for SQLGL/GL#/101 KFF
   --
   fnd_flex_oracle_reports_apis.flexsql
     (p_appl_short_name => 'SQLGL',
      p_code            => 'GL#',
      p_mode            => fnd_flex_oracle_reports_apis.mode_select,
      p_num             => 101,
      x_output          => l_p_flexdata);

   --
   -- Get the WHERE portion of my query for SQLGL/GL#/101 KFF
   --
   fnd_flex_oracle_reports_apis.flexsql
     (p_appl_short_name => 'SQLGL',
      p_code            => 'GL#',
      p_mode            => fnd_flex_oracle_reports_apis.mode_where,
      p_num             => 101,
      p_display         => 'GL_BALANCING',
      p_operator        => fnd_flex_oracle_reports_apis.operator_equal,
      p_operand1        => l_p_operand1,
      x_output          => l_p_where);


   --
   -- To be continued...
   --

END sample_package;

BEGIN
   g_newline := fnd_global.newline();
END fnd_flex_oracle_reports_apis;

/
