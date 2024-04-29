--------------------------------------------------------
--  DDL for Package AML_CATEGORY_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_CATEGORY_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: amlcates.pls 120.0.12010000.1 2008/10/23 06:52:18 sariff noship $ */

procedure MIGRATE_LEAD_LINES (
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_trace_mode       IN  VARCHAR2);

end AML_CATEGORY_MIGRATION;

/
