--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_TAX_DEFAULT_HIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_TAX_DEFAULT_HIER" AUTHID CURRENT_USER AS
/* $Header: zxtaxhiermigs.pls 120.2.12010000.2 2008/11/12 12:51:46 spasala ship $ */

PROCEDURE migrate_default_hierarchy;
PROCEDURE create_condition_groups(p_name IN VARCHAR2 DEFAULT NULL);
PROCEDURE create_rules(p_tax IN VARCHAR2 DEFAULT NULL);
PROCEDURE create_process_results(p_tax_id      IN NUMBER   DEFAULT NULL,
                                 p_sync_module IN VARCHAR2 DEFAULT NULL
                                );

END Zx_Migrate_Tax_Default_Hier;

/
