--------------------------------------------------------
--  DDL for Package Body ONT_OS_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OS_CATEGORIES" AS
 /* $Header: ontcatib.pls 120.1 2006/03/29 16:54:00 spooruli noship $ */

/* Wrapper for printing report line */
PROCEDURE PRINT_LINE
	(line_text	IN	VARCHAR2) IS
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN
	FND_FILE.PUT_LINE ( FND_FILE.OUTPUT,line_text);
	--DBMS_OUTPUT.PUT_LINE ( line_text);

END;

--------------------------------------------------------------------------------
-- Parameters p_structure_name and p_level is currently defaulted for Oracle IT,
-- it will be used in future to flatten any hiearical value  set like GL#Product
-- to create Categories in applications. This program can be run in test mode to
-- see what categories it will create when parameter p_mode is passed other then
-- 2.
--------------------------------------------------------------------------------

PROCEDURE catinsert( errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY NUMBER,

                  p_valueset_name      IN VARCHAR2 DEFAULT 'GL#Product',
                  p_top_level_value    IN VARCHAR2 DEFAULT '0Y53',
                  p_mode               IN NUMBER   DEFAULT 2,
                  p_structure_name     IN VARCHAR2 DEFAULT 'Product Reporting Hierarchy',
                  p_level              IN NUMBER   DEFAULT 8) IS

BEGIN
null;
END catinsert;
END  ont_os_categories;

/
