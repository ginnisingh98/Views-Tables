--------------------------------------------------------
--  DDL for Package FA_POST_ADJ_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_POST_ADJ_ITF_PKG" AUTHID CURRENT_USER as
/* $Header: fapadjis.pls 120.1.12010000.1 2009/07/21 12:38:04 glchen noship $   */


PROCEDURE fapadji(
                p_book_type_code     IN     VARCHAR2,
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

END FA_POST_ADJ_ITF_PKG;

/
