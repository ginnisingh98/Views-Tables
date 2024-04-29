--------------------------------------------------------
--  DDL for Package FA_MASSPSLTFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSPSLTFR_PKG" AUTHID CURRENT_USER AS
/* $Header: FAMPSLTFRS.pls 120.3.12010000.2 2009/07/19 14:36:58 glchen ship $   */

PROCEDURE do_mass_sl_transfer (
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_parent_request_id             IN     NUMBER,
     p_total_requests                IN     NUMBER,
     p_request_number                IN     NUMBER,
     p_calling_interface             IN     VARCHAR2,
     px_max_mass_ext_transfer_id     IN OUT NOCOPY NUMBER,
     x_success_count                    OUT NOCOPY NUMBER,
     x_failure_count                    OUT NOCOPY NUMBER,
     x_return_status                    OUT NOCOPY NUMBER);

PROCEDURE allocate_workers (
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_total_requests                IN     NUMBER,
     x_return_status                    OUT NOCOPY NUMBER);

PROCEDURE Purge(
               ERRBUF   OUT NOCOPY  VARCHAR2,
               RETCODE  OUT NOCOPY  VARCHAR2);

END FA_MASSPSLTFR_PKG;

/
