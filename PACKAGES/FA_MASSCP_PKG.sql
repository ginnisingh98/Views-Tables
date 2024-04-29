--------------------------------------------------------
--  DDL for Package FA_MASSCP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSCP_PKG" AUTHID CURRENT_USER as
/* $Header: FAMCPS.pls 120.7.12010000.2 2009/07/19 14:35:00 glchen ship $   */

procedure do_mass_copy(
                p_book_type_code    IN     VARCHAR2,
                p_period_name       IN     VARCHAR2,
                p_period_counter    IN     NUMBER,
                p_mode              IN     NUMBER,
                p_loop_count        IN     NUMBER,
                p_parent_request_id IN     NUMBER,
                p_total_requests    IN     NUMBER,
                p_request_number    IN     NUMBER,
                x_success_count        OUT NOCOPY number,
                x_warning_count        OUT NOCOPY number,
                x_failure_count        OUT NOCOPY number,
                x_return_status        OUT NOCOPY number);

procedure mcp_addition
               (p_corp_thid         IN      NUMBER,
                p_asset_id          IN      NUMBER,
                p_asset_number      IN      VARCHAR2,
                p_tax_book          IN      VARCHAR2,
                p_asset_type        IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2);

procedure mcp_adjustment
               (p_corp_thid         IN      NUMBER,
                p_asset_id          IN      NUMBER,
                p_asset_number      IN      VARCHAR2,
                p_tax_book          IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2);

procedure mcp_retirement
               (p_corp_thid         IN      NUMBER,
                p_asset_id          IN      NUMBER,
                p_asset_number      IN      VARCHAR2,
                p_tax_book          IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE write_message
               (p_asset_number       in     varchar2,
                p_thid               in     number,
                p_message            in     varchar2,
                p_token              in     varchar2,
                p_value              in     varchar2,
                p_mode               in     varchar2);

PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_period_name        IN     VARCHAR2,
                p_period_counter     IN     NUMBER,
                p_mode               IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER);

END FA_MASSCP_PKG;

/
