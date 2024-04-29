--------------------------------------------------------
--  DDL for Package FA_ASSET_TRACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_TRACE_PKG" AUTHID CURRENT_USER AS
/* $Header: faxtrcs.pls 120.4.12010000.3 2009/07/19 13:00:25 glchen ship $ */

g_use_utl_file   VARCHAR2(1) DEFAULT 'N';
g_sla_only       VARCHAR2(1) DEFAULT 'N';

TYPE t_col_tbl IS TABLE OF VARCHAR2(100)
         INDEX BY BINARY_INTEGER;

PROCEDURE do_trace (errbuf           OUT NOCOPY  VARCHAR2,
                    retcode          OUT NOCOPY  NUMBER,
                    p_book           IN    	 VARCHAR2,
                    p_asset_number   IN    	 VARCHAR2,
                    p_log_level_rec  IN FA_API_TYPES.log_level_rec_type default null);

PROCEDURE get_dist_info (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);
--

END FA_ASSET_TRACE_PKG;

/
