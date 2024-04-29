--------------------------------------------------------
--  DDL for Package Body FA_CHK_BOOKSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CHK_BOOKSTS_PKG" as
/* $Header: FAXCKBKB.pls 120.20.12010000.5 2009/12/01 09:27:22 pmadas ship $ */

g_release                  number  := fa_cache_pkg.fazarel_release;

--
-- FUNCTION faxcbsx
--


FUNCTION faxcbsx(X_book              IN VARCHAR2,
                 X_init_message_flag    VARCHAR2 DEFAULT 'NO',
                 X_close_period      in NUMBER DEFAULT 1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_txn_status  BOOLEAN := FALSE;   -- TRUE if txn allowed, FALSE otherwise

BEGIN

   if (X_init_message_flag = 'YES') then
      fa_srvr_msg.init_server_message;
      fa_debug_pkg.initialize;
   end if;

   if (X_book is NULL) then
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcbsx',
                              name       => 'FA_SHARED_ARGUMENTS',
                              token1     => 'PROGRAM',
                              value1     => 'CHECK_BOOK_STATUS', p_log_level_rec => p_log_level_rec);
      h_txn_status := FALSE;

   -- faxcbs will check status of any processes running on this book

   elsif (NOT faxcbs(X_book         => X_book,
                     X_submit       => TRUE,
                     X_start        => FALSE,
                     X_asset_id     => 0,
                     X_trx_type     => 'OTHER',
                     X_txn_status   => h_txn_status,
                     X_close_period => X_close_period,
                     p_log_level_rec => p_log_level_rec)) then

      fa_srvr_msg.add_message(calling_fn =>'FA_CHK_BOOKSTS_PKG.faxcbsx',
                              name       => 'FA_SHARED_END_WITH_ERROR',
                              token1     => 'PROGRAM',value1=>'CHECK_BOOK_STATUS', p_log_level_rec => p_log_level_rec);
      h_txn_status := FALSE;

   end if;

   -- h_txn_status, at this point, have value of TRUE if txn is approved
   -- and FALSE if txn is not approved

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcbsx','txn status',h_txn_status, p_log_level_rec => p_log_level_rec);
   end if;

   return(h_txn_status);

EXCEPTION
   when others then

   fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcbsx', p_log_level_rec => p_log_level_rec);
   return (FALSE);

END faxcbsx;

--
-- FUNCTION faxcrb
--
-- This function has been added to handle MRC enabled books.
-- This function will check if the book on which a transaction is being
-- performed is a primary book with reporting books associated to it(MRC).
-- It will check to see if the reporting books depreciation status is complete
-- and whether the primary and reporting book periods are in synch.
-- When depreciation is submitted, this function will check to see if
-- depreciation has already been run for the reporting books and will return
-- false if this is not the case. When depreciation is submitted for a
-- reporting book, we will check to see if depreciation has already been run
-- for the period in which the Primary books is and will return false if
-- this is the case.

-- BUG# 1470923
--  removed the tax cursor and surrounding logic. instead, have
--  added a call to faxcrb from faxptb so it is called for each tax book
--  as it looped through

-- BUG# 1920416
--  modified to simulate the full logic of transaction approval including
--  mass requests, close period option for deprn, etc.

FUNCTION faxcrb (X_book         IN   VARCHAR2,
                 X_trx_type     IN   VARCHAR2,
                 X_asset_id     IN   NUMBER,
                 X_close_period IN   NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

         return BOOLEAN is

   h_mc_source_flag         varchar2(3);
   h_last_period_counter    NUMBER(15);
   h_approve                BOOLEAN := TRUE;
   h_book                   VARCHAR2(30);
   h_count                  NUMBER(15) := 0;
   h_mrc_sob_type_code      VARCHAR2(1);
   h_set_of_books_id        NUMBER(15);
   conversion_exception     exception;
   efc_conversion_exception exception;


   -- used for any
   CURSOR check_efc_conversion_status IS
          select count(*)
            from fa_mc_conversion_history
           where efc_status in ('I', 'U', 'E')
             and book_type_code = h_book;

   -- used for primary
   -- Bug 4748124 spooyath
   -- Added an nvl to conversion_status to catch
   -- the case when conversion_status is null
   CURSOR check_conversion_status IS
          select count(*)
            from fa_mc_book_controls
           where book_type_code = h_book
             and nvl(conversion_status,' ') in ('S', 'R', 'E',' ')
             and mrc_converted_flag = 'N'
             and enabled_flag = 'Y';

   CURSOR check_reporting_deprn_open IS
          select count(1)
            from fa_mc_book_controls mcbk
           where mcbk.book_type_code = h_book
             and (mcbk.deprn_status <> 'C' OR
                  ((mcbk.last_period_counter <> h_last_period_counter + 1) AND
                   (mcbk.last_period_counter <> h_last_period_counter)))
             and enabled_flag = 'Y';

   CURSOR check_reporting_deprn_close IS
          select count(1)
            from fa_mc_book_controls mcbk
           where mcbk.book_type_code = h_book
             and (mcbk.deprn_status <> 'C' OR
                  (mcbk.last_period_counter <> h_last_period_counter + 1))
             and enabled_flag = 'Y';

   CURSOR check_reporting_mass IS
          select count(1)
            from fa_mc_book_controls mcbk
           where mcbk.book_type_code = h_book
             and (mcbk.deprn_status <> 'C'  OR
                  (mcbk.last_period_counter <> h_last_period_counter) OR
                   (mcbk.mass_request_id is not null))
             and enabled_flag = 'Y';

   -- just like faxcds, asset transactions should not necessarily be prevented
   -- in cases where deprn_status is E as we'll check whether they were
   -- processed in faxcdr.

   CURSOR check_reporting_single IS
          select count(1)
            from fa_mc_book_controls mcbk
           where mcbk.book_type_code = h_book
             and (mcbk.deprn_status not in ('C', 'E')  OR
                  (mcbk.last_period_counter <> h_last_period_counter) OR
                  (mcbk.mass_request_id is not null))
             and enabled_flag = 'Y';


   -- used when called from a reporting book
   CURSOR check_primary_sync IS
          select count(1)
            from fa_book_controls_bas bc
           where bc.book_type_code = X_book
             and (bc.last_period_counter <> h_last_period_counter or
                  bc.mass_request_id is not null);

BEGIN

   h_mc_source_flag       := FA_CACHE_PKG.fazcbc_record.mc_source_flag;
   h_last_period_counter  := FA_CACHE_PKG.fazcbc_record.last_period_counter;
   h_set_of_books_id      := FA_CACHE_PKG.fazcbc_record.set_of_books_id;

   if not fa_cache_pkg.fazcsob
            (X_set_of_books_id   => h_set_of_books_id,
             X_mrc_sob_type_code => h_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_sql_error
           (calling_fn => 'fa_chk_booksts_pkg.faxcrb', p_log_level_rec => p_log_level_rec);
      return(FALSE);
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcrb',
                        'sob_id',h_set_of_books_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcrb',
                        'reporting_type',h_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcrb',
                        'last period counter',h_last_period_counter, p_log_level_rec => p_log_level_rec);
   end if;

   -- check to see if the efc conversion is in process
   open check_efc_conversion_status;
   fetch check_efc_conversion_status into h_count;
   close check_efc_conversion_status;

   if (h_count > 0) then
      RAISE efc_conversion_exception;
   end if;

   h_book := X_book;

   if (h_mrc_sob_type_code = 'P' and h_mc_source_flag = 'Y') then

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcrb','checking for ','Primary', p_log_level_rec => p_log_level_rec);
      end if;

      -- check to see if mrc upgrade is in process for a reporting
      -- book associated to this primary book
      open check_conversion_status;
      fetch check_conversion_status into h_count;
      close check_conversion_status;

      if (h_count > 0) then
          RAISE conversion_exception;
      end if;

      if (X_trx_type = 'OTHER') then
         -- txn type of OTHER is used when submitting depreciation from
         -- FAXDPRUN, branch depending on close period flag
         if (X_close_period = 1) then
            open check_reporting_deprn_close;
            fetch check_reporting_deprn_close into h_count;
            if (h_count > 0) then
                h_approve := FALSE;
                FA_SRVR_MSG.add_message
                      (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
                       NAME        =>  'FA_MRC_REP_BOOK_DEP_NOT_RUN', p_log_level_rec => p_log_level_rec);
            end if;
            close check_reporting_deprn_close;
         else
            open check_reporting_deprn_open;
            fetch check_reporting_deprn_open into h_count;
            if (h_count > 0) then
               h_approve := FALSE;
               FA_SRVR_MSG.add_message
                     (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
                      NAME        =>  'FA_MRC_REP_BOOK_DEP_NOT_RUN', p_log_level_rec => p_log_level_rec);
            end if;
            close check_reporting_deprn_open;
         end if;
      elsif (X_trx_type = 'RB_DEP' or
         X_trx_type = 'RB_CJE' or
         X_trx_type = 'GAINLOSS') then
         -- no need to check the reporting book here as they do not
         -- impact the reporting books due to one-step, etc and no
         -- other mass process on reporting would be relevant.
         null;
      elsif (X_asset_ID = 0) then -- for any mass transaction
         open check_reporting_mass;
         fetch check_reporting_mass into h_count;
         if (h_count > 0) then
            FA_SRVR_MSG.add_message
                  (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
                   NAME        =>  'FA_MRC_PRI_REP_PERIOD_DIFF', p_log_level_rec => p_log_level_rec);
            h_approve := FALSE;
         end if;
         close check_reporting_mass;
      else -- for any asset transaction
         open check_reporting_single;
         fetch check_reporting_single into h_count;
         if (h_count > 0) then
            FA_SRVR_MSG.add_message
                  (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
                   NAME        =>  'FA_MRC_PRI_REP_PERIOD_DIFF', p_log_level_rec => p_log_level_rec);
            h_approve := FALSE;
         end if;
         close check_reporting_single;
      end if;

   -- else submitting mass process on reporting book (dep, gl, rbdep)
   -- prevent if depreciation for prior period has not run for Primary
   -- or if a mass request is locking the primary book

   elsif (h_mrc_sob_type_code = 'R' and X_trx_type <> 'RB_DEP') then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcrb','checking','reporting', p_log_level_rec => p_log_level_rec);
      end if;

      open check_primary_sync;
      fetch check_primary_sync into h_count;
      if (h_count > 0) then
         FA_SRVR_MSG.add_message
               (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
                NAME        =>  'FA_MRC_RUN_DEP_CORP_FIRST', p_log_level_rec => p_log_level_rec);
         h_approve := FALSE;
      end if;
      close check_primary_sync;
   end if;   --h_mc_source_flag

   RETURN(h_approve);

EXCEPTION
   WHEN conversion_exception THEN
        FA_SRVR_MSG.add_message
              (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
               NAME        =>  'FA_MRC_CONV_PROCESS', p_log_level_rec => p_log_level_rec);
        return(FALSE);

   WHEN efc_conversion_exception THEN
        FA_SRVR_MSG.add_message
              (CALLING_FN  =>  'FA_CHK_BOOKSTS_PKG.faxcrb',
               NAME        =>  'FA_EFC_CONV_PROCESS', p_log_level_rec => p_log_level_rec);
        return(FALSE);

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_chk_booksts_pkg.faxcrb', p_log_level_rec => p_log_level_rec);
        return(FALSE);

END faxcrb;


--
-- FUNCTION faxcbs
--

FUNCTION faxcbs (X_book          IN     VARCHAR2,
                 X_submit        IN     BOOLEAN,
                 X_start         IN     BOOLEAN,
                 X_asset_id      IN     NUMBER,
                 X_trx_type      IN     VARCHAR2,
                 X_txn_status    IN OUT NOCOPY BOOLEAN,
                 X_close_period  IN     NUMBER DEFAULT 1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is


   h_class_str              VARCHAR2(15);
   h_allow_cip_assets_flag  VARCHAR2(3);
   h_tmp                    BOOLEAN;

   ERROR_FOUND  EXCEPTION;

BEGIN

   -- Note: X_txn_status is a boolean variable which is an argument
   -- to several functions  and gets updated to TRUE if no error occured or
   -- no process is running on the book, etc.
   --
   -- It gets set to FALSE if non-complete process is running on the book,
   -- fail to obtain lock for the book, or unknown error occurs, etc

   if (NOT FA_CACHE_PKG.fazcbc(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
       raise ERROR_FOUND;
   end if;

   h_class_str := fa_cache_pkg.fazcbc_record.book_class;
   h_allow_cip_assets_flag := fa_cache_pkg.fazcbc_record.allow_cip_assets_flag;

   -- set savepoint, so that we can rollback when error occurs

    if (NOT faxsav(X_action     => 'S',
                   X_txn_status => X_txn_status,
                   p_log_level_rec => p_log_level_rec)) then
       raise ERROR_FOUND;
    end if;

   -- lock the book row before checking for txn approval

   if (NOT faxlck(X_book       => X_book,
                  X_txn_status => X_txn_status,
                  X_asset_id   => X_asset_id,
                  X_trx_type   => X_trx_type,
                  p_log_level_rec => p_log_level_rec)) then
      raise ERROR_FOUND;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcbs','txn_status after faxlck',X_txn_status, p_log_level_rec => p_log_level_rec);
   end if;

   -- X_txn_status is TRUE if nothing failed so far and check any
   -- processes on this book

    if (X_txn_status) then
       if (NOT faxcps(X_book         => X_book,
                      X_submit       => X_submit,
                      X_start        => X_start,
                      X_asset_id     => X_asset_id,
                      X_trx_type     => X_trx_type,
                      X_txn_status   => X_txn_status,
                      X_close_period => X_Close_Period,
                      p_log_level_rec => p_log_level_rec)) then
           raise ERROR_FOUND;
       end if;
    end if;

   -- faxcps above returns X_txn_status false when process is in running, inactive,
   -- or pending status

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcbs','txn status after faxcps',
                         X_txn_status, p_log_level_rec => p_log_level_rec);
   end if;
   if (X_txn_status) then

      if (h_class_str = 'CORPORATE') then

         if (NOT X_submit) then

            -- not submitting depreciation, check linked tax books if
            -- reclass or transfer. Original code has been merged with
            -- CIP-TAX code below for easier maintenance

            -- cip-in-trx's have been removed since the trigger
            -- solution has been replaced with a full api which
            -- insures transaction approval is called for each book

            if (X_trx_type = 'TRANSFER' OR
                X_trx_type = 'RECLASS'  OR
                X_trx_type = 'TRANSFER OUT' OR
                X_trx_type = 'UNIT ADJUSTMENT' OR
                X_trx_type = 'PARTIAL UNIT RETIREMENT') then

               if (NOT faxptb(X_book       => X_book,
                              X_start      => X_start,
                              X_asset_id   => X_asset_id,
                              X_trx_type   => X_trx_type,
                              X_txn_status => X_txn_status,
                              p_log_level_rec => p_log_level_rec)) then
                       raise ERROR_FOUND;
               end if;
            end if;
         end if;

      elsif (h_class_str = 'TAX') then

         -- check for incompatable processes on CORP book
         --
         -- BUG# 1936983 - do not check for rollback deprn
         -- since no conflicting corp transaction would have
         -- been allowed if deprn had been run withut closing
         -- period.  Eventually we may need to enhance the
         -- faxgcb function to accomidate other transactions
         -- against mrc but currently this is the only one.

         -- Fix for Bug #2381635.  Added RB_CJE
         if (X_trx_type not in ('RB_DEP', 'RB_CJE')) then

            if (NOT faxgcb(X_book       => X_book,
                           X_txn_status => X_txn_status,
                           p_log_level_rec => p_log_level_rec)) then
               raise ERROR_FOUND;
            end if;
         end if;

      else
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS.faxcbs',
                                 name       => 'FA_TRXAPP_WRONG_BOOK_CLASS',
                                 token1     =>'CLASS',value1=>h_class_str, p_log_level_rec => p_log_level_rec);

         h_tmp := faxsav(X_action           => 'R',
                         X_txn_status       => X_txn_status,
                         p_log_level_rec => p_log_level_rec); -- rollback the lock
      end if;
   end if;

   -- put the main book back on cache
   if (NOT FA_CACHE_PKG.fazcbc(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
       raise ERROR_FOUND;
   end if;

   -- check book status is complete and clear savepoint indicator for next txns,
   -- but keep rows locked

   if (NOT faxsav(X_action     => 'C',
                  X_txn_status => X_txn_status,
                  p_log_level_rec => p_log_level_rec)) then
      raise ERROR_FOUND;
   end if;

   return(TRUE);

EXCEPTION
   WHEN ERROR_FOUND THEN
        fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS.faxcbs', p_log_level_rec => p_log_level_rec);

        h_tmp := faxsav(X_action     => 'R',
                        X_txn_status => X_txn_status,
                        p_log_level_rec => p_log_level_rec);
        -- rollback the lock, if any
        return (FALSE);

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS.faxcbs', p_log_level_rec => p_log_level_rec);
        h_tmp := faxsav(X_action     => 'R',
                        X_txn_status => X_txn_status,
                        p_log_level_rec => p_log_level_rec);
        -- rollback the lock, if any

        return(FALSE);
END faxcbs;

--
-- FUNTION faxcps
--

FUNCTION faxcps (X_book         IN     VARCHAR2,
                 X_submit       IN     BOOLEAN,
                 X_start        IN     BOOLEAN,
                 X_asset_id     IN     NUMBER,
                 X_trx_type     IN     VARCHAR2,
                 X_txn_status   IN OUT NOCOPY BOOLEAN,
                 X_close_period IN     NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_conc_request_id  NUMBER := fnd_global.conc_request_id;
   h_request_id       NUMBER := 0;  -- set to non-zero if there is non-complete running process
   h_ca_request_id    NUMBER := 0;  -- set to non-zero if there is non-complete running create accounting process
   h_tmp              BOOLEAN;

   h_deprn_stat       varchar2(1);
   h_deprn_req_id     number;
   h_mass_req_id      number;
   h_last_period_ctr  number;
   h_sob_id           number;
   h_mc_source_flag   varchar2(1);
   h_allow_cip_assets varchar2(3);

BEGIN

   -- BUG# 1910467
   --
   -- We are reanabling the caching features in fazcbc which
   -- will impact multiple places.  Do to potential changes in values
   -- like last_period_counter, we need to insure the data in the cache
   -- is not stale.  Thus, we will do a direct select here and compare
   -- the values.  If the data has changed, we will clear and reset
   -- the cache accordingly.
   --
   -- caches have already been called from faxcbs or faxptb
   -- also adding the new deprn period cache to this as well
   --
   --   -- bridgway 08/01/01

   if not fa_cache_pkg.fazcdp
           (x_book_type_code => x_book, p_log_level_rec => p_log_level_rec) then
      return false;
   end if;

   -- BUG# 2247404 / BUG# 2230178
   -- do the following only when called standalone for an individual trx
   -- or for a mass transaction at main entry from that process
   --
   -- do not do it for each transaction called from a mass process
   -- this will allow mass transactions like FAMAPT after a deprn run
   -- on a line by line basis

   if (((nvl(fnd_global.conc_request_id, -1) >= 0)  and
        (X_asset_id = 0)) or
       ((nvl(fnd_global.conc_request_id, -1) < 0) and
        (X_asset_id <> 0))) then

      select deprn_status,
             deprn_request_id,
             last_period_counter,
             mass_request_id,
             set_of_books_id,
             mc_source_flag,
             allow_cip_assets_flag
        into h_deprn_stat,
             h_deprn_req_id,
             h_last_period_ctr,
             h_mass_req_id,
             h_sob_id,
             h_mc_source_flag,
             h_allow_cip_assets
        from fa_book_controls
       where book_type_code = X_book;

      if (nvl(h_last_period_ctr, -99) <>
              nvl(FA_CACHE_PKG.fazcbc_record.last_period_counter, -99) OR
          nvl(h_deprn_stat, 'X') <>
               nvl(FA_CACHE_PKG.fazcbc_record.deprn_status, 'X') OR
          nvl(h_deprn_req_id, -99) <>
               nvl(FA_CACHE_PKG.fazcbc_record.deprn_request_id, -99) OR
          nvl(h_mass_req_id, -99) <>
               nvl(FA_CACHE_PKG.fazcbc_record.mass_request_id, -99) OR
          nvl(h_sob_id, -99) <>
               nvl(FA_CACHE_PKG.fazcbc_record.set_of_books_id, -99) OR
          nvl(h_mc_source_flag, 'X') <>
               nvl(FA_CACHE_PKG.fazcbc_record.mc_source_flag, 'X') OR
          nvl(h_allow_cip_assets, 'X') <>
               nvl(FA_CACHE_PKG.fazcbc_record.allow_cip_assets_flag, 'X'))  then

          -- clear the book from the cache (member and array)
          if (NOT FA_CACHE_PKG.fazcbc_clr(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
              fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxcps', p_log_level_rec => p_log_level_rec);
              return(FALSE);
          end if;

          -- now recall it
          if (NOT FA_CACHE_PKG.fazcbc(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
             fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxcps', p_log_level_rec => p_log_level_rec);
             return(FALSE);
          end if;
      end if;

      if (FA_CACHE_PKG.fazcbc_record.last_period_counter + 1 <>
          FA_CACHE_PKG.fazcdp_record.period_counter ) then

          -- clear the book from the cache (member and array)
          if (NOT FA_CACHE_PKG.fazcdp_clr(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
              fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxcps', p_log_level_rec => p_log_level_rec);
              return(FALSE);
          end if;

          -- now recall it
          if (NOT FA_CACHE_PKG.fazcdp(X_book_type_code => X_book, p_log_level_rec => p_log_level_rec)) then
             fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxcps', p_log_level_rec => p_log_level_rec);
             return(FALSE);
          end if;
      end if;

      if (NOT faxcrb(X_book         => X_book,
                  X_trx_type     => X_trx_type,
                  X_asset_id     => X_asset_id,
                  X_close_period => X_close_period,
                  p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps', p_log_level_rec => p_log_level_rec);
         return(FALSE);
      end if;
   end if;

   -- check if depreciation is running or errored
   if (NOT faxcds(X_book       => X_book,
                  X_submit     => X_submit,
                  X_asset_id   => X_asset_id,
                  X_trx_type   => X_trx_type,
                  X_txn_status => X_txn_status,
                  p_log_level_rec => p_log_level_rec)) then
       fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps', p_log_level_rec => p_log_level_rec);
       return(FALSE);
   end if;

   -- if trx_approval failed due to deprn running, return
   if (NOT X_txn_status) then
       return (TRUE);
   end if;

   -- check the status of mass request id, if any, in book_control
   if(NOT faxcms(X_book       => X_book,
                 X_request_id => h_request_id,
                 p_log_level_rec => p_log_level_rec)) then
       fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps', p_log_level_rec => p_log_level_rec);
       return(FALSE);
   end if;

   -- check if create accounting is running for cip reversals
   -- deprn is done within faxcdr seperately
   if x_trx_type in ('REVERSE') then

      if(NOT faxcca(X_book       => X_book,
                    X_request_id => h_ca_request_id,
	   	 p_log_level_rec => p_log_level_rec)) then
          fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps',
                                  p_log_level_rec  => p_log_level_rec);
          return(FALSE);
      end if;
   else
      h_ca_request_id := 0;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcps','book',X_book, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcps','mass_request_id',
                        h_request_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcps','create_accounting_request_id', h_ca_request_id, p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcps','conc_request_id',
                        h_conc_request_id, p_log_level_rec => p_log_level_rec);
   end if;

   if (h_request_id <> 0) then
      -- req_id is in status of running,inactive,or pending
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps',
                              name       => 'FA_TRXAPP_WAIT_REQUEST',
                              token1     => 'REQUEST_ID',
                              value1     => h_request_id,
                              token2     => 'BOOK',
                              value2     => X_book, p_log_level_rec => p_log_level_rec);
      h_tmp := faxsav(X_action           => 'R',
                      X_txn_status       => X_txn_status,
                      p_log_level_rec => p_log_level_rec);
      --rollback the lock, if any
   elsif (h_ca_request_id <> 0) then
      -- req_id is in status of running,inactive,or pending
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps',
                              name       => 'FA_TRXAPP_WAIT_REQUEST',
                              token1     => 'REQUEST_ID',
                              value1     => h_ca_request_id,
                              token2     => 'BOOK',
                              value2     => X_book,
			      p_log_level_rec => p_log_level_rec);
      h_tmp := faxsav(X_action           => 'R',
                      X_txn_status       => X_txn_status,
		      p_log_level_rec => p_log_level_rec);
      --rollback the lock, if any
   end if;

   if (X_start and (h_request_id <> 0 or h_ca_request_id <> 0)) then
      --  for now faxwcr will always return TRUE
      if (NOT faxwcr(X_request_id => h_request_id,
                     p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps', p_log_level_rec => p_log_level_rec);
         return(FALSE);
      end if;
   end if;

   return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn=>'FA_CHK_BOOKSTS_PKG.faxcps', p_log_level_rec => p_log_level_rec);
        return(FALSE);

END faxcps;


--
--  FUNCTION faxwcr
--

FUNCTION faxwcr(X_request_id    IN  NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

BEGIN

   -- funtion is currently disabled, will return TRUE immediately
   return(TRUE);

   -- The following is not converted and thus remains as C code

   /*
    * if (X_request_id <> 0) then
    *    select to_char(nvl(actual_completion_date,
    *                       sysdate + least(greatest
    *                                 (sysdate - actual_start_date,5/1440),1/24)),
    *                   'DD/MM/YYYY HH24:MI:SS')
    *      into h_restart
    *      from fnd_concurrenct_requests
    *     where request_id = X_request_id
    * end if;
    */

   -- Remaining code is  in faxchk.lpc file

END faxwcr;

--
-- FUNCTION faxcds
--

FUNCTION faxcds(X_book        IN     VARCHAR2,
                X_submit      IN     BOOLEAN,
                X_asset_id    IN     NUMBER,
                X_trx_type    IN     VARCHAR2,
                X_txn_status  IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_deprn_stat       varchar2(1);
   h_deprn_req_id     number;
   h_req_id_sav       number;
   h_last_period_ctr  number;
   h_curr_period_ctr  number;
   h_tmp              boolean;
   h_error            boolean := FALSE;
   h_count            number := 0;
   h_adj_count        number := 0;

   h_phase            varchar2(30);
   h_status           varchar2(30);
   h_dev_phase        varchar2(30);
   h_dev_status       varchar2(30);
   h_message          varchar2(240);

BEGIN

   h_deprn_stat      := FA_CACHE_PKG.fazcbc_record.deprn_status;
   h_deprn_req_id    := FA_CACHE_PKG.fazcbc_record.deprn_request_id;
   h_last_period_ctr := FA_CACHE_PKG.fazcbc_record.last_period_counter;

   if (h_deprn_stat = 'C') then   -- status is completed, txn approved

      -- BUG# 1924172
      -- need to account for deprn running without closing period
      -- for both mass and asset level transactions. faxcdr will
      -- account for either mass or asset level transactions based
      -- on asset_id passed below.   -- bridgway

      -- if submitting depreciation, deleteing an asset or rolling back
      -- depreciation, ok to go ahead

      if (X_submit or
          X_trx_type = 'RB_DEP' or
          X_trx_type = 'RB_CJE' or
          X_trx_type = 'DELETE') then
         return(TRUE);
      end if;

      if (NOT faxcdr(X_book     => X_book,
                     X_asset_id => X_asset_id,
                     p_log_level_rec => p_log_level_rec)) then

          h_tmp := faxsav(X_action => 'R',
                          X_txn_status => X_txn_status,
                          p_log_level_rec => p_log_level_rec);  -- not approved
      end if;
      return(TRUE);

   elsif (h_deprn_stat = 'S' or h_deprn_stat = 'R') then
      -- stat is submitted or running
      if (fnd_concurrent.get_request_status
               (h_deprn_req_id,NULL,NULL,h_phase,
                h_status,h_dev_phase,h_dev_status,h_message)) then
         if (h_dev_phase = 'PENDING' OR
             h_dev_phase = 'INACTIVE' OR
             h_dev_phase = 'RUNNING') then

             fa_srvr_msg.add_message(calling_fn =>'fa_chk_booksts_pkg.faxcds',
                                     name       => 'FA_TRXAPP_DEPRN_IS_RUNNING',
                                     token1     =>'BOOK',
                                     value1     =>X_book, p_log_level_rec => p_log_level_rec);

             h_tmp := faxsav(X_action     => 'R',
                             X_txn_status => X_txn_status,
                             p_log_level_rec => p_log_level_rec);
             -- rollback the lock,set X_txn_status FALSE

         -- BUG# 1788850
         -- this was previously breaking only on the dev_phase check
         -- which is incorrect.  It must only do this for "S' not "R"
         -- as the request could have core dumped or been cancelled
         --
         -- bridgway  05/17/01

         elsif ((h_dev_phase  = 'COMPLETE') and
                (h_deprn_stat = 'S') and
                (not X_submit) and
                (X_trx_type   <> 'RB_CJE')) then
            if (NOT faxcdr(X_book     => X_book,
                           X_asset_id => X_asset_id,
                           p_log_level_rec => p_log_level_rec)) then

                h_tmp := faxsav(X_action => 'R',
                                X_txn_status => X_txn_status,
                                p_log_level_rec => p_log_level_rec);
                -- not approved
            end if;
            return (TRUE);
         else
            -- Deprn stat is R, but request failed. e.g core dumped,
            -- treat it as error
            h_error := TRUE;
         end if;

      else
         fa_srvr_msg.add_message(calling_fn => 'fa_chk_booksts_pkg.faxcds',
                                 name => 'FA_CONCURRENT_GET_STATUS', p_log_level_rec => p_log_level_rec);
         h_error := true; -- BUG# 7669210: continue into error logic
      end if;
   end if;

   if (h_deprn_stat = 'E' or h_error = TRUE) then
      -- if submitting depreciation or deleteing an asset ok to go ahead
      if (X_submit or
          X_trx_type = 'DELETE' or
          X_trx_type = 'RB_CJE') then
         return(TRUE);
      end if;

      if (X_asset_id = 0) then  -- this is mass process request

         -- This is a request for a mass process, no approval
         -- because the last depreciation run failed.

         fa_srvr_msg.add_message(calling_fn => 'fa_chk_booksts_pkg.faxcds',
                                 name       => 'FA_TRXAPP_DEPRN_FAILED',
                                 token1     => 'BOOK',
                                 value1     => X_book, p_log_level_rec => p_log_level_rec);
         h_tmp := faxsav(X_action     => 'R',
                         X_txn_status => X_txn_status,
                         p_log_level_rec => p_log_level_rec);  -- not approved
         return(TRUE);
      end if;

      -- calling faxcdr so asset level transactions can be approved if
      -- they have not been depreciated yet.
      if (NOT faxcdr(X_book     => X_book,
                     X_asset_id => X_asset_id,
                     p_log_level_rec => p_log_level_rec)) then
         h_tmp := faxsav(X_action     => 'R',
                         X_txn_status => X_txn_status,
                         p_log_level_rec => p_log_level_rec);  -- not approved
      end if;
      return(TRUE);

   else  -- unknown status
      fa_srvr_msg.add_message(calling_fn => 'fa_chk_booksts_pkg.faxcds',
                              name       => 'FA_TRXAPP_UNKNOWN_STATUS',
                              token1     => 'STATUS',
                              value1     => h_deprn_stat, p_log_level_rec => p_log_level_rec);
      h_tmp := faxsav(X_action     => 'R',
                      X_txn_status => X_txn_status,
                      p_log_level_rec => p_log_level_rec);  -- not approved
      return (TRUE);
   end if;

EXCEPTION
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcds',  p_log_level_rec => p_log_level_rec);
        return(FALSE);
END faxcds;


--
-- FUNCTION faxcms
--

FUNCTION faxcms(X_book         IN    VARCHAR2,
                X_request_id   OUT NOCOPY   NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_conc_req_id     NUMBER;
   h_parent_req_id   NUMBER;
   h_mass_req_id     NUMBER;
   h_phase           VARCHAR2(200) := NULL;
   h_status          VARCHAR2(200) := NULL;
   h_dev_phase       VARCHAR2(200) := NULL;
   h_dev_status      VARCHAR2(200) := NULL;
   h_message         VARCHAR2(2000):= NULL;
   h_count           number;
  cursor c_parent_request(p_request_id  NUMBER) is
  select parent_request_id
    from fnd_concurrent_requests
   where request_id = p_request_id;

BEGIN

   X_request_id  := 0;
   h_mass_req_id := fa_cache_pkg.fazcbc_record.mass_request_id;
   h_conc_req_id := fnd_global.conc_request_id;

   if (h_mass_req_id IS NOT NULL) then

      if (h_mass_req_id <> h_conc_req_id) then
         -- account for the potential that this is a child
         -- request by looking up parent_request_id
         open c_parent_request (h_conc_req_id);
         fetch c_parent_request into h_parent_req_id;

         if (c_parent_request%FOUND) then
            h_conc_req_id := nvl(h_parent_req_id, h_conc_req_id);
         end if;
         close c_parent_request;

         if (h_mass_req_id <> h_conc_req_id) then
            -- check for status of this mass request id
            -- get the parent request if applicable

            if (h_conc_req_id = 0 and
                h_mass_req_id = 0) then
               -- this is a mass request from pro*c command line
               -- so allow the transaction. faxbmt will not allow
               -- another program to run in such a case, so we
               -- can be sure it's the same request.  For pl/sql
               -- programs, it would be -1 from sql*plus
               X_request_id := 0;

            elsif (fnd_concurrent.get_request_status
                 (h_mass_req_id,NULL,NULL,h_phase,h_status,
                  h_dev_phase, h_dev_status, h_message)) then

               if (h_dev_phase = 'PENDING' OR
                   h_dev_phase = 'INACTIVE' OR
                   h_dev_phase = 'RUNNING') then
                  X_request_id := h_mass_req_id;
               else  -- completed request
                  -- BUG# 5114320
                  -- even if request was cancelled/terminated,
                  -- make sure the db processes no longer exist
                  select count(*)
                    into h_count
                    from v$session a
                   where a.audsid  in
                         (select ORACLE_SESSION_ID
                            from fnd_concurrent_requests
                           where request_id        = h_mass_req_id
                              or parent_request_id = h_mass_req_id);

                  if (h_count = 0) then
                     X_request_id := 0;
                  else
                     X_request_id := h_mass_req_id;
                  end if;
               end if;
            else
               fa_srvr_msg.add_message(calling_fn => 'fa_chk_booksts_pkg.faxcms',
                                       name       => 'FA_CONCURRENT_GET_STATUS', p_log_level_rec => p_log_level_rec);
               -- return(FALSE); -- BUG# 7669210: do not error now
            end if;
         else -- same request based on parent
            X_request_id := 0;
         end if;
      else -- same request based on conc_req
         X_request_id := 0;
      end if;
   else -- no request is locking book
      X_request_id := 0;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcms','mass_request_id',
                         h_mass_req_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcms','status',h_dev_phase, p_log_level_rec => p_log_level_rec);
   end if;

   return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_chk_booksts_pkg.faxcms', p_log_level_rec => p_log_level_rec);
        return(FALSE);

END faxcms;

FUNCTION faxcca(X_book         IN    VARCHAR2,
                X_request_id   OUT NOCOPY   NUMBER,
		p_log_level_rec IN  FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_ca_req_id     NUMBER;
   h_phase           VARCHAR2(200) := NULL;
   h_status          VARCHAR2(200) := NULL;
   h_dev_phase       VARCHAR2(200) := NULL;
   h_dev_status      VARCHAR2(200) := NULL;
   h_message         VARCHAR2(2000):= NULL;
   h_count           number;

BEGIN

   X_request_id  := 0;
   h_ca_req_id   := fa_cache_pkg.fazcbc_record.create_accounting_request_id;

   if (h_ca_req_id IS NOT NULL) then

      -- check for status of this mass request id
      -- get the parent request if applicable

      if (fnd_concurrent.get_request_status
          (h_ca_req_id,NULL,NULL,h_phase,h_status,
           h_dev_phase, h_dev_status, h_message)) then

         if (h_dev_phase = 'PENDING' OR
            h_dev_phase = 'INACTIVE' OR
            h_dev_phase = 'RUNNING') then
            X_request_id := h_ca_req_id;
         else  -- completed request
            -- BUG# 5114320
            -- even if request was cancelled/terminated,
            -- make sure the db processes no longer exist
            select count(*)
              into h_count
              from v$session a
             where a.audsid  in
                   (select ORACLE_SESSION_ID
                      from fnd_concurrent_requests
                     where request_id        = h_ca_req_id
                        or parent_request_id = h_ca_req_id);

            if (h_count = 0) then
               X_request_id := 0;
            else
               X_request_id := h_ca_req_id;
            end if;
         end if;
      else
         fa_srvr_msg.add_message(calling_fn => 'fa_chk_booksts_pkg.faxcms',
                                 name       => 'FA_CONCURRENT_GET_STATUS');
         -- BUG# 7669210: do not treat as error anylonger
         X_request_id := 0;
         return(TRUE);
      end if;
   else -- no request is locking book
      X_request_id := 0;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcca','create_accounting_request_id', h_ca_req_id, p_log_level_rec);
       fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcca','status',h_dev_phase, p_log_level_rec);
   end if;

   return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_chk_booksts_pkg.faxcca',
p_log_level_rec => p_log_level_rec);
        return(FALSE);

END faxcca;

--
-- FUNCTION  faxptb
--

FUNCTION faxptb(X_book           IN     VARCHAR2,
                X_start          IN     BOOLEAN,
                X_asset_id       IN     NUMBER,
                X_trx_type       IN     VARCHAR2,
                X_txn_status     IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN is

   h_tax_book      VARCHAR2(30);
   h_retval        BOOLEAN := TRUE;
   h_cursor        varchar2(6);

   cursor tax_cursor is
          select bc.book_type_code
          from fa_book_controls bc
          where bc.distribution_source_book = X_book
          and bc.book_class = 'TAX'
          and bc.date_ineffective is null;

BEGIN

   open tax_cursor;

   while (X_txn_status) loop
      fetch tax_cursor into h_tax_book;
      exit when tax_cursor%NOTFOUND;

      --call the cache to put the current tax book info in the record
      if (NOT FA_CACHE_PKG.fazcbc(X_book => h_tax_book, p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxptb', p_log_level_rec => p_log_level_rec);
         return(FALSE);
      end if;

      if (NOT faxlck(X_book       => h_tax_book,
                     X_txn_status => X_txn_status,
                     X_asset_id   => X_asset_id,
                     X_trx_type   => X_trx_type,
                     p_log_level_rec => p_log_level_rec)) then   -- lock the tax book
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS.PKG.faxptb', p_log_level_rec => p_log_level_rec);
         h_retval := FALSE;
         exit;
      end if;


      if (NOT faxcps(X_book         => h_tax_book,
                     X_submit       => FALSE,
                     X_start        => X_start,
                     X_asset_id     => X_asset_id,
                     X_trx_type     => X_trx_type,
                     X_txn_status   => X_txn_status,
                     X_close_period => 0,
                     p_log_level_rec => p_log_level_rec)) then
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxptb', p_log_level_rec => p_log_level_rec);
         h_retval := FALSE;
         exit;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxptb','book',h_tax_book, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxptb','txn_status',X_txn_status, p_log_level_rec => p_log_level_rec);
      end if;
   end loop;

   close tax_cursor;
   return(h_retval);

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxptb', p_log_level_rec => p_log_level_rec);
        close tax_cursor;
        return(FALSE);

END faxptb;

--
-- FUNCTION faxgcb
--

FUNCTION faxgcb(X_book         IN     VARCHAR2,
                X_txn_status   IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_corp_book        VARCHAR2(30);
   h_request_id       NUMBER := 0;
   h_conc_program_id  NUMBER;
   h_conflict         NUMBER;
   h_tmp              BOOLEAN;

BEGIN

   h_corp_book := FA_CACHE_PKG.fazcbc_record.distribution_source_book;

   -- call the cache to put the corp book info in the record
   if (NOT FA_CACHE_PKG.fazcbc(X_book => h_corp_book, p_log_level_rec => p_log_level_rec)) then
      fa_srvr_msg.add_sql_error(calling_fn=>'fa_chk_booksts_pkg.faxgcb', p_log_level_rec => p_log_level_rec);
      return(FALSE);
   end if;

   if (NOT faxcms(X_book => h_corp_book,
                  X_request_id => h_request_id,
                  p_log_level_rec => p_log_level_rec)) then
      fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxgcb', p_log_level_rec => p_log_level_rec);
      return(FALSE);
   end if;

   if (h_request_id <> 0) then

      -- process is ruuning,inactive,pending status

      select re.concurrent_program_id
        into h_conc_program_id
        from fnd_concurrent_requests re
       where re.request_id = h_request_id
         and re.program_application_id = 140;

      select decode(pr.concurrent_program_name,
                    'FAMTFR',1,
                    'FAMAPT',1,
                    'GAINLOSS', 1,
                    'FAMRCL', 1,
                    'FAPPT', 1,
                    0)
        into h_conflict
        from fnd_concurrent_programs pr
       where pr.concurrent_program_id = h_conc_program_id
         and pr.application_id = 140;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxgcb','book',h_corp_book, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxgcb','mass_request_id',
                          h_request_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxgcb','conflict',h_conflict, p_log_level_rec => p_log_level_rec);
      end if;

      if (h_conflict <> 0) then  -- curr program either FAMTFR or FAMAPT
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS.PKG.faxgcb',
                                 name       => 'FA_TRXAPP_WAIT_REQUEST',
                                 token1     => 'REQUEST_ID',
                                 value1     => h_request_id,
                                 token2     => 'BOOK',
                                 value2     => X_book, p_log_level_rec => p_log_level_rec);
         h_tmp := faxsav(X_action     => 'R',
                         X_txn_status => X_txn_status,
                         p_log_level_rec => p_log_level_rec);
         -- rollback the lock, if any
      else
        X_txn_status := TRUE;
      end if;
   end if;

   return (TRUE);

EXCEPTION
   WHEN NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxgcb',
                                name       => 'CONC_MISSING_REQUEST',
                                token1     => 'ROUTINE',value1=>'FA_TRXAPP',
                                token2     => 'REQUEST',value2=>h_request_id, p_log_level_rec => p_log_level_rec);
        return(FALSE);

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn=>'FA_CHK_BOOKSTS_PKG.faxgcb', p_log_level_rec => p_log_level_rec);
        return(FALSE);
END faxgcb;

--
-- FUNCTION faxlck
--

FUNCTION faxlck(X_book        IN     VARCHAR2,
                X_txn_status  IN OUT NOCOPY BOOLEAN,
                X_asset_id    IN     NUMBER,
                X_trx_type    IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

   h_mass_id    NUMBER;
   h_tmp        BOOLEAN;
   h_trx_id_out NUMBER;

   h_count             number;
   h_adj_req_status    VARCHAR2(4);
   lock_error          exception;


   -- CURSOR defined for fix to bug 1067205
   -- snarayan
   CURSOR lock_asset IS
          SELECT transaction_header_id_out,
                 adjustment_required_status
            FROM fa_books
           WHERE book_type_code = X_book
             AND asset_id       = X_asset_id
             AND transaction_header_id_out is null
             FOR UPDATE OF
                 transaction_header_id_out
          NOWAIT;

   CURSOR lock_asset_mass IS
          SELECT transaction_header_id_out,
                 adjustment_required_status
            FROM fa_books
           WHERE book_type_code = X_book
             AND asset_id       = X_asset_id
             AND transaction_header_id_out is null
             FOR UPDATE OF
                 transaction_header_id_out;

BEGIN

   if (X_book is NULL) then  /* Null book_type_code will rollback to savepoint */

      if (NOT faxsav(X_action => 'R',
                     X_txn_status => X_txn_status,
                     p_log_level_rec => p_log_level_rec)) then
          fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck', p_log_level_rec => p_log_level_rec);
          return(FALSE);
      end if;

   -- ******************************************************************
   -- Lock Book Controls row only if a Mass Request is submitted.
   -- For individual asset transaction only lock the active FA_BOOKS row
   -- For ADDITION not necessary to lock row. ADDITION should be allowed
   -- as long as depreciation or no mass request is running on the book
   -- Fix for Bug 1067205 - snarayan
   -- ******************************************************************
   elsif (X_trx_type NOT IN ('ADDITION',
                             'CIP ADDITION',
                             'TRANSFER IN')) then

      if (X_asset_id <> 0) then

         if (X_trx_type = 'GROUP ADDITION') then
             -- if it is group addition need to lock if group
             -- is in period of addition and backdated transaction
             -- results in catchup
             select count(*)
               into h_count
               from fa_asset_history
              where asset_id = X_asset_id
                and date_ineffective is null;

             if (h_count = 0) then
                return TRUE;
             end if;
         end if;

         -- BUG# 3315327
         -- conditionally use NOWAIT for non-mass requests
         -- wait when it is a mass request to see if we avoid
         -- block contention here
         if (nvl(fnd_global.conc_request_id, -1) > 1)  then
            OPEN lock_asset_mass;
            FETCH lock_asset_mass into h_trx_id_out, h_adj_req_status;
            CLOSE lock_asset_mass;
         else
            OPEN lock_asset;
            FETCH lock_asset into h_trx_id_out, h_adj_req_status;
            CLOSE lock_asset;
         end if;

         if h_adj_req_status = 'GADJ' then
            raise lock_error;
         end if;
      else
         select mass_request_id
           into h_mass_id
           from fa_book_controls
          where book_type_code = X_book
            for update of mass_request_id
         NOWAIT;
      end if;
   end if;

   return(TRUE);

EXCEPTION
   WHEN LOCK_ERROR THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck', p_log_level_rec => p_log_level_rec);
        h_tmp := faxsav(X_action => 'R',
                        X_txn_status => X_txn_status,
                        p_log_level_rec => p_log_level_rec);
        if (X_asset_id <> 0) then
           fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck',
                                   name       => 'FA_TRXAPP_ASSET_LOCK_FAILED',
                                   token1     => 'ASSET_ID',
                                   value1     => X_asset_id,
                                   token2     => 'BOOK',
                                   value2     => X_book, p_log_level_rec => p_log_level_rec);
        else
           fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck',
                                   name       => 'FA_TRXAPP_LOCK_FAILED',
                                   token1     => 'BOOK',
                                   value1     => X_book, p_log_level_rec => p_log_level_rec);
        end if;

        return(FALSE);


   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck', p_log_level_rec => p_log_level_rec);
        h_tmp := faxsav(X_action => 'R',
                        X_txn_status => X_txn_status,
                        p_log_level_rec => p_log_level_rec);
        if (X_asset_id <> 0) then
           fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck',
                                   name       => 'FA_TRXAPP_ASSET_LOCK_FAILED',
                                   token1     => 'ASSET_ID',
                                   value1     => X_asset_id,
                                   token2     => 'BOOK',
                                   value2     => X_book, p_log_level_rec => p_log_level_rec);
        else
           fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxlck',
                                   name       => 'FA_TRXAPP_LOCK_FAILED',
                                   token1     => 'BOOK',
                                   value1     => X_book, p_log_level_rec => p_log_level_rec);
        end if;

        return(FALSE);

END faxlck;

--
--  Function
--

FUNCTION faxsav(X_action         IN  VARCHAR2,
                X_txn_status     IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

BEGIN

   if (X_action = 'S') then
      -- sets a savepoint to roll back when anything fails
      if (NOT savepoint_set) then
         SAVEPOINT lock_row;
         savepoint_set := TRUE;
         X_txn_status  := TRUE;
      end if;

   elsif (X_action = 'R') then  -- rollback locks, error occured
      if (savepoint_set) then
         ROLLBACK TO SAVEPOINT lock_row;
         savepoint_set := FALSE;
      end if;
      X_txn_status := FALSE;    -- txn not approved

   elsif (X_action = 'C') then  -- txn approved, clear savepoint for next call
      savepoint_set := FALSE;   -- make row stay locked

   else
      if (savepoint_set) then
         ROLLBACK TO SAVEPOINT lock_row;
         savepoint_set := FALSE;
      end if;
      X_txn_status := FALSE;
      return(FALSE);

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxsav','action',X_action, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxsav','savepoint',savepoint_set, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxsav','txn_status',X_txn_status, p_log_level_rec => p_log_level_rec);
   end if;
   return (TRUE);

EXCEPTION
   WHEN OTHERS THEN
        if (savepoint_set) then
           ROLLBACK TO SAVEPOINT lock_row;
           savepoint_set := FALSE;
        end if;
        X_txn_status := FALSE;
        return(FALSE);

END faxsav;


FUNCTION faxcdr(X_book          IN      VARCHAR2,
                X_asset_id      IN      NUMBER  DEFAULT 0, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN IS

   deprn_run           VARCHAR2(1);
   h_count             NUMBER;
   h_mc_source_flag    VARCHAR2(3);
   h_set_of_books_id   NUMBER;
   h_mrc_sob_type_code VARCHAR2(3);
   h_ca_request_id     NUMBER;

   -- variables for api calls
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(4000);
   l_return_status             VARCHAR2(1);
   l_deprn_run                 boolean := false;
   l_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;

   CURSOR check_deprn_run IS
          SELECT nvl(deprn_run, 'N')
            FROM fa_deprn_periods dp,
                 fa_book_controls bc
           WHERE bc.book_type_code = X_book
             AND dp.book_type_code = bc.book_type_code
             AND dp.period_close_date is null;

BEGIN

   -- need to call cache here because of the mass forms call
   -- faxcdr directly.

   if (NOT FA_CACHE_PKG.fazcbc(X_book => X_book, p_log_level_rec => p_log_level_rec)) then
      fa_srvr_msg.add_sql_error
            (calling_fn => 'fa_chk_booksts_pkg.faxcdr', p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   h_mc_source_flag       := FA_CACHE_PKG.fazcbc_record.mc_source_flag;
   h_set_of_books_id      := FA_CACHE_PKG.fazcbc_record.set_of_books_id;

   if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_sql_error
            (calling_fn => 'fa_chk_booksts_pkg.faxcdr', p_log_level_rec => p_log_level_rec);
      return(FALSE);
   end if;

   if (X_asset_id = 0 and
       G_release <> 11) then

      -- SLA: allow mass programs even when deprn has been run
      -- we will rollback the processed deprn automatically

      null;

   elsif (X_asset_id = 0 and
          G_release = 11) then
      OPEN check_deprn_run;
      FETCH check_deprn_run INTO deprn_run;
      CLOSE check_deprn_run;

      if (deprn_run = 'Y') then
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                 name       => 'FA_DEPRN_ROLLBACK_BOOK',
                                 token1     => 'BOOK',
                                 value1     => X_book, p_log_level_rec => p_log_level_rec);
         return(FALSE);
      end if;

      if (h_mc_source_flag = 'Y' and h_mrc_sob_type_code = 'P') then
         SELECT count(*)
           INTO h_count
           FROM fa_mc_deprn_periods dp,
                fa_mc_book_controls bc
          WHERE bc.book_type_code = X_book
            AND bc.book_type_code = dp.book_type_code
            AND bc.set_of_books_id = dp.set_of_books_id
            AND bc.enabled_flag = 'Y'
            AND dp.period_close_date is null
            AND dp.deprn_run = 'Y';

         if (h_count <> 0) then
            fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                    name       => 'FA_DEPRN_ROLLBACK_BOOK',
                                    token1     => 'BOOK',
                                    value1     => X_book, p_log_level_rec => p_log_level_rec);
            return(FALSE);
         end if;
      end if;
   elsif (G_release = 11) then
      SELECT count(*)
        INTO h_count
        FROM fa_deprn_summary ds,
             fa_book_controls bc
       WHERE bc.book_type_code = X_book
         AND ds.book_type_code = bc.book_type_code
         AND ds.period_counter = bc.last_period_counter + 1
         AND ds.asset_id = X_asset_id
         AND ds.deprn_source_code in ('DEPRN','TRACK');


      if (h_count <> 0) then
          fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                  name       => 'FA_DEPRN_ROLLBACK_ASSET',
                                  token1     => 'BOOK',
                                  value1     => X_book, p_log_level_rec => p_log_level_rec);
          return(FALSE);
      end if;

      if (h_mc_source_flag = 'Y' and h_mrc_sob_type_code = 'P') then
         SELECT count(*)
           INTO h_count
           FROM fa_mc_deprn_summary ds,
                fa_book_controls bc
          WHERE bc.book_type_code = X_book
            AND ds.book_type_code = bc.book_type_code
            AND ds.period_counter = bc.last_period_counter + 1
            AND ds.asset_id = X_asset_id
            AND ds.deprn_source_code in ('DEPRN','TRACK');

         if (h_count <> 0) then
            fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                    name       => 'FA_DEPRN_ROLLBACK_ASSET',
                                    token1     => 'BOOK',
                                    value1     => X_book, p_log_level_rec => p_log_level_rec);
            return(FALSE);
         end if;
      end if;

      -- Bug 2059859 / 2115351
      -- We need to check if the Capitalization/CIP is
      -- done in the same period .
      SELECT count(*)
        INTO h_count
        FROM fa_adjustments adj,
             fa_book_controls bc,
             fa_deprn_summary ds
       WHERE bc.book_type_code  = X_book
         AND adj.book_type_code = X_book
         AND adj.period_counter_created = bc.last_period_counter + 1
         AND adj.asset_id = X_asset_id
         AND adj.source_type_code in ('ADDITION', 'CIP ADDITION')
         AND adj.adjustment_type in ('COST', 'CIP COST')
         AND ds.book_type_code = X_book
         AND ds.asset_id = X_asset_id
         AND ds.deprn_source_code = 'BOOKS'
         AND ds.period_counter = bc.last_period_counter;


      if (h_count <> 0) then
         fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                 name       => 'FA_DEPRN_ROLLBACK_ASSET',
                                 token1     => 'BOOK',
                                 value1     => X_book, p_log_level_rec => p_log_level_rec);
         return(FALSE);
      end if;

      if (h_mc_source_flag = 'Y' and h_mrc_sob_type_code = 'P') then

         SELECT count(*)
           INTO h_count
           FROM fa_mc_adjustments adj,
                fa_mc_book_controls bc,
                fa_mc_deprn_summary ds
          WHERE bc.book_type_code  = X_book
            AND bc.enabled_flag = 'Y'
            AND adj.set_of_books_id = adj.set_of_books_id
            AND adj.book_type_code = X_book
            AND adj.period_counter_created = bc.last_period_counter + 1
            AND adj.asset_id = X_asset_id
            AND adj.source_type_code in ('ADDITION', 'CIP ADDITION')
            AND adj.adjustment_type in ('COST', 'CIP COST')
            AND ds.set_of_books_id = bc.set_of_books_id
            AND ds.book_type_code = X_book
            AND ds.asset_id = X_asset_id
            AND ds.deprn_source_code = 'BOOKS'
            AND ds.period_counter = bc.last_period_counter;

          if (h_count <> 0) then
             fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcdr',
                                     name       => 'FA_DEPRN_ROLLBACK_ASSET',
                                     token1     => 'BOOK',
                                     value1     => X_book, p_log_level_rec => p_log_level_rec);
             return(FALSE);
          end if;

       end if;
   else -- release <> 11
      SELECT count(*)
        INTO h_count
        FROM fa_deprn_summary ds,
             fa_book_controls bc
       WHERE bc.book_type_code = X_book
         AND ds.book_type_code = bc.book_type_code
         AND ds.period_counter = bc.last_period_counter + 1
         AND ds.asset_id = X_asset_id
         AND ds.deprn_source_code in ('DEPRN','TRACK');

      if (h_count <> 0) then
         l_deprn_run := true;

      else

         -- Fix for Bug #6528245.  Still need check member assets for group.
         select count(*)
         into   h_count
         from   dual
         where  exists
         (select 'x'
          FROM fa_deprn_summary ds,
               fa_book_controls bc,
               fa_books bks,
               fa_books bks2,
               fa_additions_b ad
         WHERE bc.book_type_code = X_Book
           AND ds.book_type_code = bc.book_type_code
           AND ds.period_counter = bc.last_period_counter + 1
           AND ds.asset_id = bks.asset_id
           AND ds.deprn_source_code in ('DEPRN','TRACK')
           AND bks.group_asset_id = X_Asset_ID
           AND bks.book_type_code = bc.book_type_code
           AND bks.transaction_header_id_out is null
           AND ad.asset_id = X_Asset_ID
           AND ad.asset_type = 'GROUP'
           AND bks2.asset_id = ad.asset_id
           AND bks2.book_type_code = bc.book_type_code
           AND bks2.transaction_header_id_out is null
           AND bks2.tracking_method = 'CALCULATE'
         );

         if (h_count <> 0) then
            l_deprn_run := true;
         end if;

      end if;

      if (h_mc_source_flag = 'Y' and h_mrc_sob_type_code = 'P') then
         SELECT count(*)
           INTO h_count
           FROM fa_mc_deprn_summary ds,
                fa_book_controls bc
          WHERE bc.book_type_code = X_book
            AND ds.book_type_code = bc.book_type_code
            AND ds.period_counter = bc.last_period_counter + 1
            AND ds.asset_id = X_asset_id
            AND ds.deprn_source_code in ('DEPRN','TRACK');

         if (h_count <> 0) then
            l_deprn_run := true;
         end if;
      end if;

      -- SLA: removing period of addition validation
      -- adding call to the rollback api so we can automatixally
      -- reverse deprn and continue with trx unless error occurs
      if (l_deprn_run) then

         l_asset_hdr_rec.asset_id       := X_asset_id;
         l_asset_hdr_rec.book_type_code := X_book;

         -- BUG# 5444002
         -- only allow automated rollback if create accounting is not currently running

         if(NOT faxcca(X_book       => X_book,
                       X_request_id => h_ca_request_id,
	      	 p_log_level_rec => p_log_level_rec)) then
              fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps',
                                      p_log_level_rec  => p_log_level_rec);
              return(FALSE);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcdr','book',X_book, p_log_level_rec);
            fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcdr','create_accounting_request_id',
                             h_ca_request_id, p_log_level_rec);
         end if;

         if (h_ca_request_id <> 0) then
            -- req_id is in status of running,inactive,or pending
            fa_srvr_msg.add_message(calling_fn => 'FA_CHK_BOOKSTS_PKG.faxcps',
                                    name       => 'FA_TRXAPP_WAIT_REQUEST',
                                    token1     => 'REQUEST_ID',
                                    value1     => h_ca_request_id,
                                    token2     => 'BOOK',
                                    value2     => X_book,
  			      p_log_level_rec => p_log_level_rec);
            return(FALSE);

         else

            FA_DEPRN_ROLLBACK_PUB.do_rollback
               (p_api_version             => 1.0,
                p_init_msg_list           => FND_API.G_FALSE,
                p_commit                  => FND_API.G_FALSE,
                p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                x_return_status           => l_return_status,
                x_msg_count               => l_msg_count,
                x_msg_data                => l_msg_data,
                p_calling_fn              => 'FA_CHK_BOOKSTS_PKG.faxcdr', -- BUG# 8247224
                px_asset_hdr_rec          => l_asset_hdr_rec);

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                return false;
            else
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('FA_CHK_BOOKSTS_PKG.faxcdr',
                                     'successfully rolled back deprn','',p_log_level_rec);
                end if;
            end if;
         end if;
      end if;


   end if;  -- end if asset_id = 0

   return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_chk_booksts_pkg.faxcdr', p_log_level_rec => p_log_level_rec);
        return(FALSE);
END faxcdr;

-- Bug 9032587: Wrapper procedure to call function faxcdr.
PROCEDURE faxcdr_proc(
                X_book          IN      VARCHAR2,
                X_asset_id      IN      NUMBER DEFAULT 0,
                X_return_value  OUT     nocopy integer)
AS
h_ret_value     boolean;
p_log_level_rec FA_API_TYPES.log_level_rec_type;
ERROR_FOUND     exception;

begin
  X_return_value := 0;

  if (not p_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  p_log_level_rec
      )) then
         raise error_found;
      end if;
  end if;

  h_ret_value := FA_CHK_BOOKSTS_PKG.faxcdr(
                    X_book,
                    X_asset_id,
                    p_log_level_rec);

  if (h_ret_value) then
     X_return_value := 1;    /* True  */
  else
     X_return_value := 0;    /* False  */
  end if;

  return;

EXCEPTION

   WHEN ERROR_FOUND THEN
        raise;

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_chk_booksts_pkg.faxcdr_proc', p_log_level_rec => p_log_level_rec);
        X_return_value := 0;
        return;
END faxcdr_proc;
-- End Bug 9032587

END FA_CHK_BOOKSTS_PKG;

/
