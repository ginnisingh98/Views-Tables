--------------------------------------------------------
--  DDL for Package FA_MASSCHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSCHG_PKG" AUTHID CURRENT_USER as
/* $Header: FAMACHS.pls 120.2.12010000.2 2009/07/19 14:47:06 glchen ship $   */

PROCEDURE do_mass_change (
                p_mass_change_id     IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number);

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2);


END FA_MASSCHG_PKG;

/
