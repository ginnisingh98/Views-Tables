--------------------------------------------------------
--  DDL for Package Body FA_XLA_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_EVENTS_PVT" as
/* $Header: faeventb.pls 120.15.12010000.14 2009/07/22 11:48:16 gigupta ship $   */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

FUNCTION create_transaction_event
           (p_asset_hdr_rec          IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_type_rec         IN FA_API_TYPES.asset_type_rec_type,
            px_trans_rec             IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            p_event_status           IN VARCHAR2 DEFAULT NULL,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean IS

   l_trx_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;

   l_event_type_code  varchar2(30) ;
   l_event_date       date         := px_trans_rec.transaction_date_entered;
   l_event_status     varchar2(30) ;
   l_valuation_method varchar2(30) := p_asset_hdr_rec.book_type_code;

   l_calling_fn       varchar2(80) := 'fa_xla_events_pvt.create_trx_event';

   invalid_calling_fn      exception;
   invalid_event_status    exception;

BEGIN

   if (p_asset_type_rec.asset_type = 'EXPENSED') then
      return true;
   end if;

   l_trx_source_info.application_id        := 140;
   l_trx_source_info.legal_entity_id       := NULL;
   l_trx_source_info.ledger_id             := p_asset_hdr_rec.set_of_books_id;
   l_trx_source_info.transaction_number    := to_char(px_trans_rec.transaction_header_id);
   l_trx_source_info.source_id_int_1       := px_trans_rec.transaction_header_id;
   l_trx_source_info.source_id_char_1      := p_asset_hdr_rec.book_type_code;

   -- conditionally set the entity and type codes
   -- based on calling interface and other factors

   l_trx_source_info.entity_type_code      := 'TRANSACTIONS';

   if (p_calling_fn = 'fa_addition_pvt.insert_asset') then
      l_event_type_code                       := 'ADDITIONS';
   elsif (p_calling_fn = 'fa_cip_pvt.do_cap_rev') then
       if (p_asset_type_rec.asset_type = 'CIP') then
          l_event_type_code                       := 'REVERSE_CAPITALIZATION';
       else
          l_event_type_code                       := 'CAPITALIZATION';
       end if;
   elsif (p_calling_fn = 'fa_adjustment_pvt.do_adjustment') then
      l_event_type_code                       := 'ADJUSTMENTS';
   elsif (p_calling_fn = 'fa_unplanned_pvt.do_unplanned') then
      l_event_type_code                       := 'UNPLANNED_DEPRECIATION';
   elsif (p_calling_fn = 'FA_RETIREMENT_PUB.do_all_books_retirement') then
      l_event_type_code                       := 'RETIREMENTS';
   elsif (p_calling_fn = 'FA_RETIREMENT_PUB.do_sub_regular_reinstatement') then
      l_event_type_code                       := 'REINSTATEMENTS';
   elsif (p_calling_fn = 'FA_DISTRIBUTION_PVT.do_distribution') then
      if (px_trans_rec.transaction_type_code = 'RECLASS') then
         l_event_type_code                       := 'CATEGORY_RECLASS';
      elsif (px_trans_rec.transaction_type_code = 'UNIT ADJUSTMENT') then
         l_event_type_code                       := 'UNIT_ADJUSTMENTS';
      else -- all tax book transactions and TRANSFER and TRANSFER OUT
         l_event_type_code                       := 'TRANSFERS';
      end if;
   elsif (p_calling_fn = 'fa_reval_pvt.do_reval') then
      l_event_type_code                       := 'REVALUATION';
   elsif (p_calling_fn = 'FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj') then
      l_event_type_code                       := 'DEPRECIATION_ADJUSTMENTS';
   elsif (p_calling_fn = 'fa_ret_adj_pub.do_all_books') then
      l_event_type_code                       := 'RETIREMENT_ADJUSTMENTS';
   elsif (p_calling_fn = 'FA_GAINLOSS_UND_PKG.fagtax') then
      l_event_type_code                       := 'TRANSFERS';
   elsif (p_calling_fn = 'FA_TERMINAL_GAIN_LOSS_PVT.fadtgl') then
      l_event_type_code                       := 'TERMINAL_GAIN_LOSS';
   else
      raise invalid_calling_fn;
   end if;


   -- we are breaking by asset type so append CIP if needed
   if (p_asset_type_rec.asset_type = 'CIP' and
       p_calling_fn <> 'fa_cip_pvt.do_cap_rev') then
       l_event_type_code                  := 'CIP_' || l_event_type_code;
   end if;

   -- set the status correctly
   -- only retirements / reinstatements should use incomplete
   if (p_event_status is null or
       p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;
   elsif (p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_INCOMPLETE) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_INCOMPLETE;
   elsif (p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION;
   else
      -- invalid type
      raise invalid_event_status;
   end if;

   l_event_date := greatest(l_event_date,
                            fa_cache_pkg.fazcdp_record.calendar_period_open_date);


   if (g_print_debug) then
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.application_id ', l_trx_source_info.application_id, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.legal_entity_id ',   l_trx_source_info.legal_entity_id
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.ledger_id ',         l_trx_source_info.ledger_id
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.transaction_number', l_trx_source_info.transaction_number
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.source_id_int_1',    l_trx_source_info.source_id_int_1
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_trx_source_info.entity_type_code',   l_trx_source_info.entity_type_code
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_event_type_code',                    l_event_type_code
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_event_date',                         l_event_date
                ,p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_valuation_method',                   l_valuation_method
                ,p_log_level_rec => p_log_level_rec);

   end if;

   -- Call XLA API
   px_trans_rec.event_id :=
     XLA_EVENTS_PUB_PKG.create_event
          (p_event_source_info   => l_trx_source_info,
           p_event_type_code     => l_event_type_code,
           p_event_date          => l_event_date,
           p_event_status_code   => l_event_status,
           p_event_number        => NULL,
           p_reference_info      => NULL,
           p_valuation_method    => l_valuation_method,
           p_security_context    => l_security_context);

   return true;

EXCEPTION
  WHEN INVALID_CALLING_FN THEN
       fa_srvr_msg.add_message
          (name       => '***FA_INVALID_CALLING_FN***',
           calling_fn => l_calling_fn
           ,p_log_level_rec => p_log_level_rec);
       return FALSE;

  WHEN INVALID_EVENT_STATUS THEN
       fa_srvr_msg.add_message
          (name       => '***FA_EVENT_STATUS***',
           calling_fn => l_calling_fn
           ,p_log_level_rec => p_log_level_rec);
       return FALSE;

  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return FALSE;

END create_transaction_event;


-- this routine is used for events crossing multiple transactions
-- specifically invoice transfer, group reserve transfers

FUNCTION create_dual_transaction_event
           (p_asset_hdr_rec_src      IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_hdr_rec_dest     IN FA_API_TYPES.asset_hdr_rec_type,
            p_asset_type_rec_src     IN FA_API_TYPES.asset_type_rec_type,
            p_asset_type_rec_dest    IN FA_API_TYPES.asset_type_rec_type,
            px_trans_rec_src         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            px_trans_rec_dest        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            p_event_status           IN VARCHAR2 DEFAULT NULL,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean is

   l_trx_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;

   l_event_type_code  varchar2(30) ;
   l_event_date       date         := px_trans_rec_src.transaction_date_entered;
   l_event_status     varchar2(30) ;
   l_valuation_method varchar2(30) := p_asset_hdr_rec_src.book_type_code;

   l_calling_fn       varchar2(80) := 'fa_xla_events_pvt.create_dual_trx_event';

   invalid_calling_fn      exception;
   invalid_event_status    exception;

BEGIN

   if (p_asset_type_rec_src.asset_type = 'EXPENSED') then
      return true;
   end if;

   l_trx_source_info.application_id        := 140;
   l_trx_source_info.legal_entity_id       := NULL;
   l_trx_source_info.ledger_id             := p_asset_hdr_rec_src.set_of_books_id;
   l_trx_source_info.transaction_number    := NULL; --to_char(px_trans_rec_src.transaction_header_id);
   l_trx_source_info.source_id_int_1       := px_trans_rec_src.trx_reference_id;
   l_trx_source_info.source_id_char_1      := p_asset_hdr_rec_src.book_type_code;

   -- conditionally set the entity and type codes
   -- based on calling interface and other factors

   l_trx_source_info.entity_type_code      := 'INTER_ASSET_TRANSACTIONS';

   if (p_calling_fn = 'fa_inv_xfr_pub.do_transfer') then
      if (p_asset_type_rec_src.asset_type  = 'CAPITALIZED' or
          p_asset_type_rec_dest.asset_type = 'CAPITALIZED') then
         l_event_type_code                       := 'SOURCE_LINE_TRANSFERS';
      else
         l_event_type_code                       := 'CIP_SOURCE_LINE_TRANSFERS';
      end if;
   elsif (p_calling_fn = 'fa_rsv_transfer_pub.do_all_books') then
      l_event_type_code                       := 'RESERVE_TRANSFERS';
   else
      raise invalid_calling_fn;
   end if;


   -- set the status correctly
   -- only retirements / reinstatements should use incomplete
   if (p_event_status is null or
       p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;
   elsif (p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_INCOMPLETE) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_INCOMPLETE;
   elsif (p_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION) then
      l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_NOACTION;
   else
      -- invalid type
      raise invalid_event_status;
   end if;

   l_event_date := greatest(l_event_date,
                            fa_cache_pkg.fazcdp_record.calendar_period_open_date);

   -- Call XLA API
   px_trans_rec_src.event_id :=
     XLA_EVENTS_PUB_PKG.create_event
          (p_event_source_info   => l_trx_source_info,
           p_event_type_code     => l_event_type_code,
           p_event_date          => l_event_date,
           p_event_status_code   => l_event_status,
           p_event_number        => NULL,
           p_reference_info      => NULL,
           p_valuation_method    => l_valuation_method,
           p_security_context    => l_security_context);

   px_trans_rec_dest.event_id := px_trans_rec_src.event_id;

   return true;

EXCEPTION
  WHEN INVALID_CALLING_FN THEN
       fa_srvr_msg.add_message
          (name       => '***FA_INVALID_CALLING_FN***',
           calling_fn => l_calling_fn
           ,p_log_level_rec => p_log_level_rec);
       return FALSE;

  WHEN INVALID_EVENT_STATUS THEN
       fa_srvr_msg.add_message
          (name       => '***FA_EVENT_STATUS***',
           calling_fn => l_calling_fn
           ,p_log_level_rec => p_log_level_rec);
       return FALSE;

  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return FALSE;



END create_dual_transaction_event;

PROCEDURE create_deprn_event
           (p_asset_id          IN     number,
            p_book_type_code    IN     varchar2,
            p_period_counter    IN     number,
            p_period_close_date IN     date,
            p_deprn_run_id      IN     number,
            p_ledger_id         IN     number,
            x_event_id             OUT NOCOPY number,
            p_calling_fn        IN     VARCHAR2,
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_deprn_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context   XLA_EVENTS_PUB_PKG.t_security;

   l_event_type_code  varchar2(30) ;
   l_event_date       date         := p_period_close_date;
   l_event_status     varchar2(30) ;
   l_valuation_method varchar2(30) := p_book_type_code;

   l_calling_fn       varchar2(80) := 'fa_xla_events_pvt.create_deprn_event';

BEGIN

   l_deprn_source_info.application_id        := 140;
   l_deprn_source_info.ledger_id             := p_ledger_id;
   l_deprn_source_info.source_id_int_1       := p_asset_id;
   l_deprn_source_info.source_id_char_1      := p_book_type_code;
   l_deprn_source_info.source_id_int_2       := p_period_counter;
   l_deprn_source_info.source_id_int_3       := p_deprn_run_id;

   -- conditionally set the entity and type codes
   -- based on calling interface and other factors

   l_deprn_source_info.entity_type_code      := 'DEPRECIATION';

   l_event_status := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;

   -- Call XLA API
   x_event_id :=
     XLA_EVENTS_PUB_PKG.create_event
          (p_event_source_info   => l_deprn_source_info,
           p_event_type_code     => 'ROLLBACK_DEPRECIATION',
           p_event_date          => l_event_date,
           p_event_status_code   => l_event_status,
           p_event_number        => NULL,
           p_reference_info      => NULL,
           p_valuation_method    => l_valuation_method,
           p_security_context    => l_security_context);

EXCEPTION
  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       raise;

END create_deprn_event;

--
-- This routine is internally called from both the depreciation and
-- deferred stubs for event handling.  the calling program will insure
-- that all arrays passed in pertain to the same set of assets, book
-- and period and also that all assets belong to the same legal entity
-- since the bulk event creation api requires this to be passed
-- as a single parameter and not in the event array.
--

PROCEDURE create_bulk_deprn_event
           (p_asset_id_tbl      IN     number_tbl_type,
            p_book_type_code    IN     varchar2,   -- tax for deferred
            p_period_counter    IN     number,
            p_period_close_date IN     date,
            p_deprn_run_id      IN     number,
            p_entity_type_code  IN     varchar2,
            x_event_id_tbl         OUT NOCOPY number_tbl_type,
            p_calling_fn        IN     VARCHAR2,
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_legal_entity_id              number;

   l_entity_event_info_tbl_in  xla_events_pub_pkg.t_array_entity_event_info_s;
   l_entity_event_info_tbl_out xla_events_pub_pkg.t_array_entity_event_info_s;

   l_calling_fn                varchar2(80) := 'fa_xla_events_pvt.create_bulk_deprn_event';

   l_dummy_number              number_tbl_type;

BEGIN

   for i in 1..p_asset_id_tbl.count loop
      l_dummy_number (i) := i;
   end loop;

   -- load the array as required by SLA:
   -- verify event number and transaction number relevance here
   -- since neither table uses a transaction sequence
   forall i in 1..p_asset_id_tbl.count
   insert into xla_events_int_gt
     (APPLICATION_ID       ,
      LEDGER_ID            ,
      LEGAL_ENTITY_ID      ,
      ENTITY_CODE          ,
      event_type_code      ,
      event_date           ,
      event_number         ,
      event_status_code    ,
      transaction_number   ,
      source_id_int_1      ,
      source_id_char_1     ,
      source_id_int_2      ,
      source_id_int_3      ,
      valuation_method
     )
     values
     (140                  ,
      fa_cache_pkg.fazcbc_record.set_of_books_id,
      l_legal_entity_id    ,
      p_entity_type_code   ,
      'DEPRECIATION'       ,
      p_period_close_date  ,
      l_dummy_number(i)    ,
      XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
      l_dummy_number(i)    ,
      p_asset_id_tbl(i)    ,
      p_book_type_code     ,
      p_period_counter     ,
      p_deprn_run_id       ,
      p_book_type_code
     );

   XLA_EVENTS_PUB_PKG.create_bulk_events
                                   (p_source_application_id   => 140,
                                    p_application_id          => 140,
                                    p_legal_entity_id         => l_legal_entity_id,
                                    p_ledger_id               => fa_cache_pkg.fazcbc_record.set_of_books_id,
                                    p_entity_type_code        => p_entity_type_code
                                    );

   select event_id bulk collect
     into x_event_id_tbl
     from xla_events_int_gt
    order by event_number;

EXCEPTION
  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       raise;

END create_bulk_deprn_event;

--
-- This routine is internally called from the deferred stub
-- for event handling.  the calling program will insure
-- that all arrays passed in pertain to the same set of assets, book
-- and period and also that all assets belong to the same legal entity
-- since the bulk event creation api requires this to be passed
-- as a single parameter and not in the event array.
--

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
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_dummy_number              number_tbl_type;
   l_legal_entity_id           number;

   l_entity_event_info_tbl_in  xla_events_pub_pkg.t_array_entity_event_info_s;
   l_entity_event_info_tbl_out xla_events_pub_pkg.t_array_entity_event_info_s;

   l_calling_fn                varchar2(80) := 'fa_xla_events_pvt.create_bulk_deferred_event';

BEGIN

   for i in 1..p_asset_id_tbl.count loop
      l_dummy_number (i) := i;
   end loop;

   -- load the array as required by SLA:
   -- verify event number and transaction number relevance here
   -- since neither table uses a transaction sequence
   forall i in 1..p_asset_id_tbl.count
   insert into xla_events_int_gt
     (APPLICATION_ID       ,
      LEDGER_ID            ,
      LEGAL_ENTITY_ID      ,
      ENTITY_CODE          ,
      event_type_code      ,
      event_date           ,
      event_number         ,
      event_status_code    ,
      transaction_number   ,
      source_id_int_1      ,
      source_id_char_1     ,
      source_id_char_2     ,
      source_id_int_2      ,
      valuation_method
     )
     values
     (140                  ,
      fa_cache_pkg.fazcbc_record.set_of_books_id,
      l_legal_entity_id    ,
      p_entity_type_code   ,
      'DEFERRED_DEPRECIATION'       ,
      p_period_close_date  ,
      l_dummy_number(i)    ,
      XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
      l_dummy_number(i)    ,
      p_asset_id_tbl(i)    ,
      p_corp_book          ,
      p_tax_book           ,
      p_corp_period_counter,
      p_corp_book
     );

   XLA_EVENTS_PUB_PKG.create_bulk_events
                                   (p_source_application_id   => 140,
                                    p_application_id          => 140,
                                    p_legal_entity_id         => l_legal_entity_id,
                                    p_ledger_id               => fa_cache_pkg.fazcbc_record.set_of_books_id,
                                    p_entity_type_code        => p_entity_type_code
                                    );

   select event_id bulk collect
     into x_event_id_tbl
     from xla_events_int_gt
    order by event_number;


EXCEPTION
  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       raise;

END create_bulk_deferred_event;


-- update events
-- this is only called from gain/loss when processing the retirement
-- OPEN do we need to update the transaction date for unprocessed retirements?

/*

PROCEDURE update_event_status
   (p_event_source_info            IN  xla_events_pub_pkg.t_event_source_info
   ,p_event_class_code             IN  VARCHAR2   DEFAULT NULL
   ,p_event_type_code              IN  VARCHAR2   DEFAULT NULL
   ,p_event_date                   IN  DATE       DEFAULT NULL
   ,p_event_status_code            IN  VARCHAR2
   ,p_valuation_method             IN  VARCHAR2
   ,p_security_context             IN  xla_events_pub_pkg.t_security

   ,p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

*/

FUNCTION update_transaction_event
           (p_ledger_id              IN NUMBER,
            p_transaction_header_id  IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_event_type_code        IN VARCHAR2,
            p_event_date             IN DATE,
            p_event_status_code      IN VARCHAR2,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean IS

   l_trx_source_info   XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context  XLA_EVENTS_PUB_PKG.t_security;
   l_event_type        varchar2(30);
   l_event_id          number;
   l_event_date        date;

   l_calling_fn        varchar2(80) := 'fa_xla_events_pvt.update_transaction_event';

begin

   l_trx_source_info.application_id        := 140;
   l_trx_source_info.ledger_id             := p_ledger_id;
   l_trx_source_info.source_id_int_1       := p_transaction_header_id;
   l_trx_source_info.source_id_char_1      := p_book_type_code;
   l_trx_source_info.entity_type_code      := 'TRANSACTIONS';

   select event_id
     into l_event_id
     from fa_transaction_headers
    where transaction_header_id = p_transaction_header_id;

   l_event_date := greatest(p_event_date,
                            fa_cache_pkg.fazcdp_record.calendar_period_open_date);

   XLA_EVENTS_PUB_PKG.update_event
     (p_event_source_info            => l_trx_source_info,
      p_event_id                     => l_event_id,
      p_event_type_code              => p_event_type_code,
      p_event_date                   => l_event_date,
      p_event_status_code            => p_event_status_code,
      p_valuation_method             => p_book_type_code,
      p_security_context             => l_security_context);

  return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;

end update_transaction_event;

FUNCTION update_inter_transaction_event
           (p_ledger_id              IN NUMBER,
            p_trx_reference_id       IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_event_type_code        IN VARCHAR2,
            p_event_date             IN DATE,
            p_event_status_code      IN VARCHAR2,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean is

   l_trx_source_info   XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context  XLA_EVENTS_PUB_PKG.t_security;
   l_event_type        varchar2(30);
   l_event_id          number;

   l_calling_fn        varchar2(80) := 'fa_xla_events_pvt.update_inter_transaction_event';

begin

   l_trx_source_info.application_id        := 140;
   l_trx_source_info.ledger_id             := p_ledger_id;
   l_trx_source_info.source_id_int_1       := p_trx_reference_id;
   l_trx_source_info.source_id_char_1      := p_book_type_code;
   l_trx_source_info.entity_type_code      := 'INTER_ASSET_TRANSACTIONS';

   select event_id
     into l_event_id
     from fa_trx_references
    where trx_reference_id = p_trx_reference_id;

   XLA_EVENTS_PUB_PKG.update_event
     (p_event_source_info            => l_trx_source_info,
      p_event_id                     => l_event_id,
      p_event_type_code              => p_event_type_code,
      p_event_date                   => p_event_date,
      p_event_status_code            => p_event_status_code,
      p_valuation_method             => p_book_type_code,
      p_security_context             => l_security_context);

  return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;

end update_inter_transaction_event;

-- delete events (unrocessed additions/retirements/reinstatements/unprocessed deprn *only*)
-- this shoudl only be called from single transaction events
--  (specifically, when undoing retirement/reinstatements)

FUNCTION delete_transaction_event
           (p_ledger_id              IN NUMBER,
            p_transaction_header_id  IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_asset_type             IN VARCHAR2,   --bug 8630242
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec          IN FA_API_TYPES.log_level_rec_type default null) return boolean IS

   l_event_id         NUMBER;
   l_trx_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context XLA_EVENTS_PUB_PKG.t_security;
   l_result           integer;

   l_calling_fn       varchar2(80) := 'fa_xla_events_pvt.delete_transaction_event';

BEGIN

   l_trx_source_info.application_id        := 140;
   l_trx_source_info.ledger_id             := p_ledger_id;
   l_trx_source_info.source_id_int_1       := p_transaction_header_id;
   l_trx_source_info.source_id_char_1      := p_book_type_code;
   l_trx_source_info.entity_type_code      := 'TRANSACTIONS';

   select event_id
     into l_event_id
     from fa_transaction_headers
    where transaction_header_id = p_transaction_header_id;

   --bug 8630242 added if condition.
   If (nvl(p_asset_type,'XX') <> 'EXPENSED') then
      XLA_EVENTS_PUB_PKG.delete_event
         (p_event_source_info            => l_trx_source_info,
          p_event_id                     => l_event_id,
          p_valuation_method             => p_book_type_code,
          p_security_context             => l_security_context);
   End if;

   --6702657
   BEGIN
      l_result := XLA_EVENTS_PUB_PKG.delete_entity
                       (p_source_info       => l_trx_source_info,
                        p_valuation_method  => p_book_type_code,
                        p_security_context  => l_security_context);

   EXCEPTION
      WHEN OTHERS THEN
        l_result := 1;
        fa_debug_pkg.add(l_calling_fn, 'Unable to delete entity for trx event',
                      l_event_id, p_log_level_rec => p_log_level_rec);
   END; --annonymous

   return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;

END delete_transaction_event;

FUNCTION delete_deprn_event
           (p_event_id               IN NUMBER,
            p_ledger_id              IN NUMBER,
            p_asset_id               IN NUMBER,
            p_book_type_code         IN VARCHAR2,
            p_period_counter         IN NUMBER,
            p_deprn_run_id           IN NUMBER,
            p_calling_fn             IN VARCHAR2,
            p_log_level_rec          IN FA_API_TYPES.log_level_rec_type default null) return boolean IS

   l_event_id           NUMBER;
   l_deprn_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context   XLA_EVENTS_PUB_PKG.t_security;
   l_result             integer;

   l_calling_fn         varchar2(80) := 'fa_xla_events_pvt.delete_deprn_event';

BEGIN

   l_deprn_source_info.application_id        := 140;
   l_deprn_source_info.ledger_id             := p_ledger_id;
   l_deprn_source_info.source_id_int_1       := p_asset_id;
   l_deprn_source_info.source_id_char_1      := p_book_type_code;
   l_deprn_source_info.source_id_int_2       := p_period_counter;
   l_deprn_source_info.source_id_int_3       := p_deprn_run_id;
   l_deprn_source_info.entity_type_code      := 'DEPRECIATION';

   XLA_EVENTS_PUB_PKG.delete_event
      (p_event_source_info            => l_deprn_source_info,
       p_event_id                     => p_event_id,
       p_valuation_method             => p_book_type_code,
       p_security_context             => l_security_context);

   --6702657
   BEGIN
      l_result := XLA_EVENTS_PUB_PKG.delete_entity
                       (p_source_info       => l_deprn_source_info,
                        p_valuation_method  => p_book_type_code,
                        p_security_context  => l_security_context);

   EXCEPTION
      WHEN OTHERS THEN
        l_result := 1;
        fa_debug_pkg.add(l_calling_fn, 'Unable to delete entity for event',
                  p_event_id, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'l_result', l_result, p_log_level_rec => p_log_level_rec);
   END; --annonymous

   return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;

END delete_deprn_event;

FUNCTION get_event_type
           (p_event_id              IN NUMBER,
            x_event_type_code       OUT NOCOPY VARCHAR2,
            p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean IS

   l_calling_fn         varchar2(80) := 'fa_xla_events_pvt.get_event_type';

BEGIN

   select event_type_code
     into x_event_type_code
     from xla_events
    where application_id = 140
      and event_id       = p_event_id;

   return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;

END;


FUNCTION get_trx_event_status
           (p_set_of_books_id       IN number
           ,p_transaction_header_id IN number
           ,p_event_id              IN number
           ,p_book_type_code        IN varchar2
           ,x_event_status          OUT NOCOPY varchar2
           ,p_log_level_rec in fa_api_types.log_level_rec_type default null
           ) return boolean IS

   l_source_info              XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context         XLA_EVENTS_PUB_PKG.t_security;

   l_calling_fn    varchar2(80) := 'fa_xla_events_pvt.get_trx_event_status';

BEGIN

   l_source_info.application_id        := 140;
   l_source_info.ledger_id             := p_set_of_books_id;
   l_source_info.source_id_int_1       := p_transaction_header_id;
   l_source_info.source_id_char_1      := p_book_type_code;
   l_source_info.entity_type_code      := 'TRANSACTIONS';

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'calling get event status for event ', p_event_id
                      ,p_log_level_rec => p_log_level_rec);
   end if;

   -- check the event status
   x_event_status := XLA_EVENTS_PUB_PKG.get_event_status
                        (p_event_source_info            => l_source_info,
                         p_event_id                     => p_event_id,
                         p_valuation_method             => p_book_type_code,
                         p_security_context             => l_security_context);

   return true;

EXCEPTION
   WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
              ,p_log_level_rec => p_log_level_rec);
       return false;


END;

end FA_XLA_EVENTS_PVT;

/
