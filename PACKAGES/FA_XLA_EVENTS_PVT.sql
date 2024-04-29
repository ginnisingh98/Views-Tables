--------------------------------------------------------
--  DDL for Package FA_XLA_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_EVENTS_PVT" AUTHID CURRENT_USER as
/* $Header: faevents.pls 120.4.12010000.7 2009/07/22 11:45:41 gigupta ship $   */

TYPE number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;

C_EVENT_PROCESSED          CONSTANT  VARCHAR2(1)  := XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED;   -- The status will never be be used by product team.
C_EVENT_UNPROCESSED        CONSTANT  VARCHAR2(1)  := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;   -- event status:unprocessed
C_EVENT_INCOMPLETE         CONSTANT  VARCHAR2(1)  := XLA_EVENTS_PUB_PKG.C_EVENT_INCOMPLETE;   -- event status:incomplete
C_EVENT_NOACTION           CONSTANT  VARCHAR2(1)  := XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION;   -- event status:noaction

FUNCTION create_transaction_event
           (p_asset_hdr_rec          IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_type_rec         IN FA_API_TYPES.asset_type_rec_type,
            px_trans_rec             IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            p_event_status           IN VARCHAR2 DEFAULT NULL,
            p_calling_fn             IN VARCHAR2   ,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION create_dual_transaction_event
           (p_asset_hdr_rec_src      IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_hdr_rec_dest     IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_type_rec_src     IN FA_API_TYPES.asset_type_rec_type,
            p_asset_type_rec_dest    IN FA_API_TYPES.asset_type_rec_type,
            px_trans_rec_src         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            px_trans_rec_dest        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            p_event_status           IN VARCHAR2 DEFAULT NULL,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

PROCEDURE create_deprn_event
           (p_asset_id          IN     number,
            p_book_type_code    IN     varchar2,
            p_period_counter    IN     number,
            p_period_close_date IN     date,
            p_deprn_run_id      IN     number,
            p_ledger_id         IN     number,
            x_event_id             OUT NOCOPY number,
            p_calling_fn        IN     VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
            );

PROCEDURE create_bulk_deprn_event
           (p_asset_id_tbl      IN     number_tbl_type,
            p_book_type_code    IN     varchar2,
            p_period_counter    IN     number,
            p_period_close_date IN     date,
            p_deprn_run_id      IN     number,
            p_entity_type_code  IN     varchar2,
            x_event_id_tbl         OUT NOCOPY number_tbl_type,
            p_calling_fn        IN     VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
            );

PROCEDURE create_bulk_deferred_event
           (p_asset_id_tbl        IN     number_tbl_type,
            p_corp_book           IN     varchar2,
            p_tax_book            IN     varchar2,
            p_corp_period_counter IN     number,
            p_tax_period_counter  IN     number,
            p_period_close_date   IN     date,
            p_entity_type_code    IN     varchar2,
            x_event_id_tbl           OUT NOCOPY number_tbl_type,
            p_calling_fn          IN     VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
            );


FUNCTION update_transaction_event
           (p_ledger_id              IN NUMBER,
            p_transaction_header_id  IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_event_type_code        IN VARCHAR2,
            p_event_date             IN DATE,
            p_event_status_code      IN VARCHAR2,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION update_inter_transaction_event
           (p_ledger_id              IN NUMBER,
            p_trx_reference_id       IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_event_type_code        IN VARCHAR2,
            p_event_date             IN DATE,
            p_event_status_code      IN VARCHAR2,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION delete_transaction_event
           (p_ledger_id              IN NUMBER,
            p_transaction_header_id  IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_asset_type             IN VARCHAR2 default null,   --bug 8630242
            p_calling_fn             IN VARCHAR2   ,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION delete_deprn_event
           (p_event_id               IN NUMBER,
            p_ledger_id              IN NUMBER,
            p_asset_id               IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_period_counter         IN NUMBER,
            p_deprn_run_id           IN NUMBER,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION get_event_type
           (p_event_id              IN NUMBER,
            x_event_type_code       OUT NOCOPY VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

FUNCTION get_trx_event_status
           (p_set_of_books_id       IN number
           ,p_transaction_header_id IN number
           ,p_event_id              IN number
           ,p_book_type_code        IN varchar2
           ,x_event_status          OUT NOCOPY varchar2
           ,p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean;

end FA_XLA_EVENTS_PVT;

/
