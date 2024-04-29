--------------------------------------------------------
--  DDL for Package FA_XADJ_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XADJ_ITF_PKG" AUTHID CURRENT_USER as
/* $Header: faxadjis.pls 120.2.12010000.4 2009/07/19 12:55:46 glchen ship $   */


PROCEDURE faxadji(
                p_batch_id           IN     VARCHAR2,
                p_old_flag           IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
		x_worker_jobs           OUT  NOCOPY NUMBER,
                x_return_status         OUT NOCOPY number);

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2);

PROCEDURE Load_Workers(
                p_batch_id           IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status      OUT NOCOPY NUMBER);

END FA_XADJ_ITF_PKG;

/
