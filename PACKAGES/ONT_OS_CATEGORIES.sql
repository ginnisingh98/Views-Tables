--------------------------------------------------------
--  DDL for Package ONT_OS_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OS_CATEGORIES" AUTHID CURRENT_USER AS
 /* $Header: ontcatis.pls 120.1 2006/03/29 16:54:22 spooruli noship $ */

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
                  p_level              IN NUMBER   DEFAULT 8);

END ont_os_categories;

/
