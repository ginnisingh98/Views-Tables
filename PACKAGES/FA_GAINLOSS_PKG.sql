--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_PKG" AUTHID CURRENT_USER as
/* $Header: FAGMNS.pls 120.4.12010000.2 2009/07/19 14:45:50 glchen ship $   */

PROCEDURE Do_Calc_GainLoss(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_retirement_id IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY NUMBER,
                x_failure_count         OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY NUMBER);

PROCEDURE Do_Calc_GainLoss_Asset(
                p_retirement_id      IN     NUMBER,
                x_return_status      OUT NOCOPY    NUMBER,
                p_log_level_rec       IN     fa_api_types.log_level_rec_type
default null);

END FA_GAINLOSS_PKG;

/
