--------------------------------------------------------
--  DDL for Package FA_MASSTFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSTFR_PKG" AUTHID CURRENT_USER as
/* $Header: FAMTFRS.pls 120.1.12010000.2 2009/07/19 14:39:49 glchen ship $   */

PROCEDURE do_mass_transfer (
                p_mass_transfer_id     IN     NUMBER,
                p_parent_request_id    IN     NUMBER,
                p_total_requests       IN     NUMBER,
                p_request_number       IN     NUMBER,
                px_max_asset_id        IN OUT NOCOPY NUMBER,
                x_success_count           OUT NOCOPY number,
                x_failure_count           OUT NOCOPY number,
                x_return_status           OUT NOCOPY number);

END FA_MASSTFR_PKG;

/
