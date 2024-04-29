--------------------------------------------------------
--  DDL for Package Body FA_DELETION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DELETION_PVT" as
/* $Header: FAVDELB.pls 120.4.12010000.5 2009/07/19 11:39:23 glchen ship $   */

FUNCTION do_validation
   (px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type ) RETURN BOOLEAN IS

   l_count         NUMBER;

   l_calling_fn    varchar2(35) := 'fa_deletion_pvt.do_validation';
   del_err         EXCEPTION;

BEGIN

   -- currently only restriction are the following:
   --   1) that assets can be deleted only in period of addition (unless skipping validation)
   --   2) asset is not a parent asset
   --   3) no add-to-asset lines exists in interface
   --   3) that asset has never been assigned to a group
   --   4) that group asset has never had any members
   --   5) must not be attached to a lease
   --
   -- the first several only matter if the book is still active - otherwise
   -- corruption from missing foreign keys doesn't matter

   if (fa_cache_pkg.fazcbc_record.date_ineffective is null) then

      if (px_asset_hdr_rec.period_of_addition <> 'Y') then
         fa_srvr_msg.add_message
            (calling_fn => l_calling_fn,
             name       => 'FA_ADD_CANT_DELETE'
             ,p_log_level_rec => p_log_level_rec);
         raise del_err;
      end if;

      --5738269
      select count(1)
      into l_count
      from fa_additions_b
      where parent_asset_id = px_asset_hdr_rec.asset_id;

      IF (l_count > 0) THEN
         fa_srvr_msg.add_message
            (calling_fn => l_calling_fn,
             name       => 'FA_ADD_CANT_DELETE_PARENT'
             ,p_log_level_rec => p_log_level_rec);
         raise del_err;
      END IF;
      --reset
      l_count :=0;

      if (p_asset_type_rec.asset_type = 'GROUP') then

         select count(*)
           into l_count
           from fa_books
          where book_type_code = px_asset_hdr_rec.book_type_code
            and group_asset_id = px_asset_hdr_rec.asset_id;

         if (l_count > 0) then
            fa_srvr_msg.add_message
                (calling_fn => l_calling_fn,
                 name       => '***FA_DELETE_GORUP_ASSET***'
                ,p_log_level_rec => p_log_level_rec);
            raise del_err;
         end if;

      else

         select count(*)
           into l_count
           from fa_books
          where asset_id       = px_asset_hdr_rec.asset_id
            and book_type_code = px_asset_hdr_rec.book_type_code
            and group_asset_id is not null;

         if (l_count > 0) then
            fa_srvr_msg.add_message
                (calling_fn => l_calling_fn,
                 name       => '***FA_DELETE_GORUP_MEMBER***'
                ,p_log_level_rec => p_log_level_rec);
            raise del_err;
         end if;

         select count(*)
           into l_count
           from fa_asset_invoices
          where asset_id = px_asset_hdr_rec.asset_id
            and feeder_system_name = 'ORACLE PROJECTS';

        if l_count > 0 then
            fa_srvr_msg.add_message
                (calling_fn => l_calling_fn,
                 name       => 'FA_ADD_CANT_DELETE_PROJECT'
                 ,p_log_level_rec => p_log_level_rec);
            raise del_err;
        end if;

      end if;

   end if; -- book effective

   if (fa_cache_pkg.fazcat_record.category_type = 'LEASE' and
       p_asset_desc_rec.lease_id is not null) then

      SELECT count(*)
        INTO l_count
        FROM FA_ADDITIONS_B
       WHERE LEASE_ID = p_asset_desc_rec.lease_id
         AND ASSET_CATEGORY_ID =
             ANY (SELECT CATEGORY_ID
                    FROM FA_CATEGORIES
                   WHERE CATEGORY_TYPE = 'LEASEHOLD IMPROVEMENT');

      if l_count > 0 then
          -- can't delete asset
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_ADD_DELETE_LHOLD'
              ,p_log_level_rec => p_log_level_rec);
         raise del_err;
      end if;

   end if;

   -- SLA Note; we need to check both standard trxs and dists
   -- hense the two executions

   if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then

      select count(*)
        into l_count
        from fa_transaction_headers   th,
             xla_transaction_entities en,
             xla_events               ev,
             fa_book_controls         bc
       where bc.book_type_code              = px_asset_hdr_rec.book_type_code
         and th.book_type_code              = bc.distribution_source_book
         and th.asset_id                    = px_asset_hdr_rec.asset_id
         and en.application_id              = 140
         and en.ledger_id                   = bc.set_of_books_id
         and en.entity_code                 = 'TRANSACTIONS'
         and nvl(en.source_id_int_1, (-99)) = th.transaction_header_id
         and en.valuation_method            = px_asset_hdr_rec.book_type_code
         and ev.application_id              = 140
         and ev.entity_id                   = en.entity_id
         and ev.event_status_code           = 'P';

      if (l_count > 0) then

          -- can't delete asset
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_ADD_CANT_DELETE');
         raise del_err;

      end if;

   end if;

      select count(*)
        into l_count
        from fa_transaction_headers   th,
             xla_transaction_entities en,
             xla_events               ev,
             fa_book_controls         bc
       where bc.book_type_code              = px_asset_hdr_rec.book_type_code
         and th.book_type_code              = px_asset_hdr_rec.book_type_code
         and th.asset_id                    = px_asset_hdr_rec.asset_id
         and en.application_id              = 140
         and en.ledger_id                   = bc.set_of_books_id
         and en.entity_code                 = 'TRANSACTIONS'
         and nvl(en.source_id_int_1, (-99)) = th.transaction_header_id
         and en.valuation_method            = px_asset_hdr_rec.book_type_code
         and ev.application_id              = 140
         and ev.entity_id                   = en.entity_id
         and ev.event_status_code           = 'P';

      if (l_count > 0) then

          -- can't delete asset
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_ADD_CANT_DELETE');
         raise del_err;

      end if;

      select count(*)
        into l_count
        from xla_transaction_entities en,
             xla_events               ev,
             fa_book_controls         bc
       where bc.distribution_source_book    = px_asset_hdr_rec.book_type_code
         and en.application_id              = 140
         and en.ledger_id                   = bc.set_of_books_id
         and en.entity_code                 = 'DEPRECIATION'
         and nvl(en.source_id_int_1, (-99)) = px_asset_hdr_rec.asset_id
         and nvl(en.source_id_char_1, ' ')  = bc.book_type_code
         and ev.application_id              = 140
         and ev.entity_id                   = en.entity_id
         and ev.event_status_code           = 'P';

      if (l_count > 0) then

          -- can't delete asset
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_ADD_CANT_DELETE');
         raise del_err;

      end if;

      -- BUG# 8554742
      -- removing staus check as we need to prevent deletion
      -- of any asset involved in inter-asset transaction
      select count(*)
        into l_count
        from fa_transaction_headers   th,
             xla_transaction_entities en,
             xla_events               ev,
             fa_book_controls         bc
       where bc.distribution_source_book    = px_asset_hdr_rec.book_type_code
         and th.book_type_code              = bc.book_type_code
         and th.asset_id                    = px_asset_hdr_rec.asset_id
         and en.application_id              = 140
         and en.ledger_id                   = bc.set_of_books_id
         and en.entity_code                 = 'INTER_ASSET_TRANSACTIONS'
         and nvl(en.source_id_int_1, (-99)) = th.trx_reference_id
         and en.valuation_method            = px_asset_hdr_rec.book_type_code
         and ev.application_id              = 140
         and ev.entity_id                   = en.entity_id;

      if (l_count > 0) then

          -- can't delete asset
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_ADD_CANT_DELETE');
         raise del_err;

      end if;

   return true;

EXCEPTION

   WHEN DEL_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn
            ,p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
            ,p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_validation;

-----------------------------------------------------------------------------

END FA_DELETION_PVT;

/
