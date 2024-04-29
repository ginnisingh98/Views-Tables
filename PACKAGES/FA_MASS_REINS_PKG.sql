--------------------------------------------------------
--  DDL for Package FA_MASS_REINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_REINS_PKG" AUTHID CURRENT_USER as
/* $Header: faxmrss.pls 120.2.12010000.2 2009/07/19 09:57:56 glchen ship $ */

PROCEDURE Mass_Reinstate(
                p_mass_retirement_id IN     NUMBER,
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

END FA_MASS_REINS_PKG;

/
