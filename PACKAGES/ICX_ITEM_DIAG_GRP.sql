--------------------------------------------------------
--  DDL for Package ICX_ITEM_DIAG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ITEM_DIAG_GRP" AUTHID CURRENT_USER AS
/* $Header: ICX_ITEM_DIAG_GRP.pls 120.0.12010000.2 2012/02/16 12:17:09 rojain noship $*/
TYPE VARCHAR_TABLE IS TABLE OF DBMS_SQL.VARCHAR2_TABLE INDEX BY binary_integer;
g_pkg_name CONSTANT VARCHAR2(30):='ICX_ITEM_DIAG_GRP';

PROCEDURE START_THIS
  (
    errbuff OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    org_id      VARCHAR2,
    action_code VARCHAR2,
 --   source_type VARCHAR2,
    source_ids  VARCHAR2 default null,
		auto_map_category VARCHAR2 default null);

END ICX_ITEM_DIAG_GRP;


/
