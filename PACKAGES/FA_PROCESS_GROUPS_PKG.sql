--------------------------------------------------------
--  DDL for Package FA_PROCESS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_PROCESS_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAPGADJS.pls 120.0.12010000.3 2009/10/06 10:33:22 bmaddine ship $ */

   PROCEDURE do_pending_groups(
		errbuf                  OUT NOCOPY VARCHAR2,
		retcode                 OUT NOCOPY NUMBER,
		p_book			IN  VARCHAR2,
		p_source_group_asset_id	IN  NUMBER DEFAULT NULL,
		p_dest_group_asset_id	IN  NUMBER DEFAULT NULL,
		p_trx_number		IN  NUMBER DEFAULT NULL);

   --Bug 8941132: do_group_reclass is now public function
   FUNCTION do_group_reclass(
                p_trx_ref_rec           IN  FA_API_TYPES.trx_ref_rec_type,
                p_mrc_sob_type_code     IN  VARCHAR2,
                p_set_of_books_id       IN  NUMBER,
                p_log_level_rec         IN  FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_PROCESS_GROUPS_PKG;

/
