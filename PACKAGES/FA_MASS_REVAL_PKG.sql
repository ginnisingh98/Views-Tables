--------------------------------------------------------
--  DDL for Package FA_MASS_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_REVAL_PKG" AUTHID CURRENT_USER as
/* $Header: FAMRVLS.pls 120.2.12010000.2 2009/07/19 14:38:54 glchen ship $   */

PROCEDURE do_mass_reval (
                p_mass_reval_id      IN     NUMBER,
                p_mode               IN     VARCHAR2,
                p_loop_count         IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number);

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2,
               p_mode            in varchar2);

PROCEDURE write_preview_messages;

FUNCTION get_mass_reval_info (p_mass_reval_id number) RETURN BOOLEAN;

PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_mass_reval_id      IN     NUMBER,
                p_mode               IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER);

END FA_MASS_REVAL_PKG;

/
