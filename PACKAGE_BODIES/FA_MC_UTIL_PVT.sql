--------------------------------------------------------
--  DDL for Package Body FA_MC_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UTIL_PVT" as
/* $Header: FAVMCUB.pls 120.10.12010000.2 2009/07/19 11:26:37 glchen ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION get_existing_rate
   (p_set_of_books_id        IN      number,
    p_transaction_header_id  IN      number,
    px_rate                  IN OUT NOCOPY number,
    px_avg_exchange_rate        OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_reporting_currency_code varchar2(15);

   l_exchange_rate           number;
   l_avg_exchange_rate       number;
   l_complete                varchar2(1);
   l_result_code             varchar2(15);

   calc_err                  EXCEPTION;

BEGIN

   l_reporting_currency_code := gl_mc_currency_pkg.get_currency_code (
                                    p_set_of_books_id          => p_set_of_books_id);

   -- get the exchange rate from the corporate transaction
   MC_FA_UTILITIES_PKG.get_rate
         (p_set_of_books_id        => p_set_of_books_id,
          p_transaction_header_id  => p_transaction_header_id,
          p_currency_code          => l_reporting_currency_code,
          p_exchange_rate          => l_exchange_rate,
          p_avg_exchange_rate      => l_avg_exchange_rate,
          p_complete               => l_complete,
          p_result_code            => l_result_code, p_log_level_rec => p_log_level_rec);

   if (l_result_code <> 'FOUND') then
       raise calc_err;
   end if;

   px_rate              := l_exchange_rate;
   px_avg_exchange_rate := l_avg_exchange_rate;

   return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_mc_util_pvt.get_existing_rate',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_mc_util_pvt.get_existing_rate',  p_log_level_rec => p_log_level_rec);
      return false;

END get_existing_rate;

----------------------------------------------------------------------------------------

FUNCTION get_trx_rate
   (p_prim_set_of_books_id       IN     number,
    p_reporting_set_of_books_id  IN     number,
    px_exchange_date             IN OUT NOCOPY date,
    p_book_type_code             IN     varchar2,
    px_rate                      IN OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_exchange_date           date;
   l_primary_currency_code   varchar2(15);
   l_conversion_type         gl_daily_conversion_types.conversion_type%TYPE;
   l_result_code             varchar2(15);
   l_exchange_rate           number;
   l_denominator_rate        number;
   l_numerator_rate          number;

   l_reporting_currency_code varchar2(15);
   l_fixed_rate              boolean;
   l_relation                varchar2(15);
   l_trans_date              date;

   calc_err   EXCEPTION;

BEGIN

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('get_trx',
                     'getting',
                     'currency code - primary', p_log_level_rec => p_log_level_rec);
            end if;


   l_primary_currency_code := gl_mc_currency_pkg.get_currency_code (
                                    p_set_of_books_id          => p_prim_set_of_books_id);


            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('get_trx',
                     'getting',
                     'currency code - reporting', p_log_level_rec => p_log_level_rec);
            end if;

   l_reporting_currency_code := gl_mc_currency_pkg.get_currency_code (
                                    p_set_of_books_id          => p_reporting_set_of_books_id);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('get_trx',
                     'getting',
                     'exchange_rate', p_log_level_rec => p_log_level_rec);
            end if;


   l_trans_date := px_exchange_date;

   gl_mc_currency_pkg.get_rate(
         p_primary_set_of_books_id   => p_prim_set_of_books_id,
         p_reporting_set_of_books_id => p_reporting_set_of_books_id,
         p_trans_date                => l_trans_date,
         p_trans_currency_code       => l_primary_currency_code,
         p_trans_conversion_type     => l_conversion_type,
         p_trans_conversion_date     => px_exchange_date,
         p_trans_conversion_rate     => l_exchange_rate,
         p_application_id            => 140,
         p_org_id                    => NULL,
         p_fa_book_type_code         => p_book_type_code,
         p_je_source_name            => NULL,
         p_je_category_name          => NULL,
         p_result_code               => l_result_code,
         p_denominator_rate          => l_denominator_rate,
         p_numerator_rate            => l_numerator_rate);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('get_trx',
                     'getting',
                     'relation', p_log_level_rec => p_log_level_rec);
            end if;


    gl_currency_api.get_relation(
         x_from_currency             => l_primary_currency_code,
         x_to_currency               => l_reporting_currency_code,
         x_effective_date            => px_exchange_date,
         x_fixed_rate                => l_fixed_rate,
         x_relationship              => l_relation);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('get_trx',
                     'done getting',
                     'relation', p_log_level_rec => p_log_level_rec);
            end if;


    if l_fixed_rate then
       px_rate := l_numerator_rate / l_denominator_rate;
    else
       px_rate := l_exchange_rate;
    end if;

    return true;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_mc_util_pvt.get_trx_rate',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_mc_util_pvt.get_trx_rate',  p_log_level_rec => p_log_level_rec);
      return false;

END get_trx_rate;

-----------------------------------------------------------------------------

FUNCTION get_latest_rate
   (p_asset_id                   IN     number,
    p_book_type_code             IN     varchar2,
    p_set_of_books_id            IN     number,
    px_rate                         OUT NOCOPY number,
    px_avg_exchange_rate            OUT NOCOPY number
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

BEGIN

   select br1.exchange_rate,
          br1.avg_exchange_rate
     into px_rate,
          px_avg_exchange_rate
     from fa_mc_books_rates br1
    where br1.asset_id              = p_asset_id
      and br1.book_type_code        = p_book_type_code
      and br1.set_of_books_id       = p_set_of_books_id
      and br1.transaction_header_id =
          (select max(br2.transaction_header_id)
             from fa_mc_books_rates br2
            where br2.asset_id        = p_asset_id
              and br2.book_type_code  = p_book_type_code
              and br2.set_of_books_id = p_set_of_books_id);

   return true;

EXCEPTION

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_mc_util_pvt.get_latest_rate',  p_log_level_rec => p_log_level_rec);
      return false;

END get_latest_rate;

-----------------------------------------------------------------------------

FUNCTION get_invoice_rate
   (p_inv_rec                    IN     FA_API_TYPES.inv_rec_type,
    p_book_type_code             IN     varchar2,
    p_set_of_books_id            IN     number,
    px_exchange_date             IN OUT NOCOPY date,
    px_inv_rate_rec              IN OUT NOCOPY FA_API_TYPES.inv_rate_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN boolean IS

   -- new variables for merging mrc trigger logic
   l_exchange_date              DATE;
   l_inv_exchange_date          DATE;
   l_mc_inv_exchange_date       DATE;
   l_exchange_rate              NUMBER;
   l_inv_exchange_rate          NUMBER;
   l_mc_inv_exchange_rate       NUMBER;
   l_current_asset_cost         NUMBER;
   l_result_code                VARCHAR2(15);
   l_inv_currency_code          fnd_currencies.currency_code%TYPE;
   l_mc_inv_currency_code       fnd_currencies.currency_code%TYPE;
   l_exchange_rate_type         gl_daily_conversion_types.conversion_type%TYPE;
   l_inv_exchange_rate_type     gl_daily_conversion_types.conversion_type%TYPE;
   l_mc_inv_exchange_rate_type  gl_daily_conversion_types.conversion_type%TYPE;
   l_denominator_rate           NUMBER;
   l_numerator_rate             NUMBER;
   l_line_base_amount           NUMBER;
   l_mc_line_base_amount        NUMBER;
   l_prj_fixed_assets_cost	NUMBER;

   l_currency_code              fnd_currencies.currency_code%TYPE;
   l_primary_currency_code      fnd_currencies.currency_code%TYPE;
   l_primary_sob_id             NUMBER;


   l_trans_date                 date;

   l_calling_fn                 varchar2(35) := 'fa_mc_util_pvt.get_invoice_rate';

   -- exceptions
   error_found                  exception;

BEGIN

   l_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
   l_result_code := 'NOT_FOUND';

   -- first check if this is a split line and if so,
   -- attempt to get the rate from the parent.  if it
   -- doesn't exist, we'll just enter the main logic below

   if (p_inv_rec.split_merged_code = 'SC') then

      BEGIN
         l_result_code := 'FOUND';

         select exchange_rate
           into l_exchange_rate
           from fa_mc_mass_rates
          where mass_addition_id = p_inv_rec.split_parent_mass_additions_id
            and set_of_books_id  = p_set_of_books_id;

      EXCEPTION
         when NO_DATA_FOUND then
              -- this can happen when a reporting book is
              -- associated to a FA book but not in AP
              l_result_code := 'NOT_FOUND';
         when OTHERS then
              fa_srvr_msg.add_sql_error(
                 calling_fn => l_calling_fn,
                 p_log_level_rec          => p_log_level_rec);
              raise error_found;
      END;

   end if;

   -- if rate not found from split logic above

   if (l_result_code = 'NOT_FOUND') then

      BEGIN

         -- get the currency codes first
         if (p_inv_rec.feeder_system_name = 'ORACLE PAYABLES' or
             p_inv_rec.feeder_system_name = 'ORACLE PROJECTS') then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                     'getting',
                     'currency code - reporting', p_log_level_rec => p_log_level_rec);
            end if;

            l_currency_code         := gl_mc_currency_pkg.get_currency_code (
                                           p_set_of_books_id          => p_set_of_books_id);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                     'getting',
                     'currency code - primary', p_log_level_rec => p_log_level_rec);
            end if;

            l_primary_currency_code := gl_mc_currency_pkg.get_currency_code (
                                           p_set_of_books_id          => l_primary_sob_id);

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                  'feeder system name',
                  p_inv_rec.feeder_system_name, p_log_level_rec => p_log_level_rec);
         end if;

         if (p_inv_rec.feeder_system_name = 'ORACLE PAYABLES' and
             G_release = 11) then

            BEGIN
               l_result_code := 'FOUND';
               -- l_mc_inv_currency_code is the transaction currency
               -- of the invoice in AP
               -- l_mc_inv_exchange_rate is the exchange rate used to
               -- convert from transaction currency to reporting currency
               -- l_result_code will be set to NOT_FOUND if no match
               -- for invoice is found in ap_mc_invoice_dists
               -- which means that reporting book is not set up as
               -- conversion option for AP for the primary book in GL

               BEGIN
                  select a.invoice_currency_code,
                         nvl(b.exchange_rate, 1),
                         nvl(b.exchange_date, a.invoice_date),
                         b.exchange_rate_type,
                         nvl(b.base_amount,   b.amount)
                    into l_mc_inv_currency_code,
                         l_mc_inv_exchange_rate,
                         l_mc_inv_exchange_date,
                         l_mc_inv_exchange_rate_type,
                         l_mc_line_base_amount
                    from ap_invoices_all a,
                         ap_mc_invoice_dists b
                   where a.invoice_id               = p_inv_rec.invoice_id
                     and a.invoice_id               = b.invoice_id
                     and b.distribution_line_number = p_inv_rec.ap_distribution_line_number
                     and b.set_of_books_id          = p_set_of_books_id;

               EXCEPTION
                  when NO_DATA_FOUND then
                       -- this can happen when a reporting book is
                       -- associated to a FA book but not in AP
                       l_result_code := 'NOT_FOUND';

                  when OTHERS then
                       fa_srvr_msg.add_message(
                          calling_fn => l_calling_fn,
                          name       => 'FA_MRC_SLT_MC_RECS',
                          token1     => 'TABLE',
                          value1     => 'ap_mc_invoice_dists',
                          token2     => 'TRIGGER',
                          value2     => 'fa_mc_mass_additions_aiud', p_log_level_rec => p_log_level_rec);
                       raise error_found;
               END;

               BEGIN

                  -- l_inv_exchange_rate is the exchange rate from
                  -- transaction currency in AP to functional currency
                  -- in AP when transaction is in a foreign currency

                  select a.invoice_currency_code,
                         nvl(b.exchange_rate, 1),
                         nvl(b.exchange_date, a.invoice_date),
                         b.exchange_rate_type,
                         nvl(b.base_amount, b.amount)
                    into l_inv_currency_code,
                         l_inv_exchange_rate,
                         l_inv_exchange_date,
                         l_inv_exchange_rate_type,
                         l_line_base_amount
                    from ap_invoices_all a,
                         ap_invoice_distributions_all b
                   where a.invoice_id               = p_inv_rec.invoice_id
                     and a.invoice_id               = b.invoice_id
                     and b.distribution_line_number = p_inv_rec.ap_distribution_line_number;

               EXCEPTION
                  when OTHERS then
                       fa_srvr_msg.add_message(
                          calling_fn => l_calling_fn,
                          name       => 'FA_MRC_SLT_INV_INFO',
                          token1     => 'TRIGGER',
                          value1     => 'fa_mc_mass_additions_aiud',
                          token2     => 'INVOICE_ID',
                          value2     => to_char(p_inv_rec.invoice_id),
                          token3     => 'DISTRIBUTION_LINE_NUMBER',
                          value3     => to_char(p_inv_rec.ap_distribution_line_number),
                          p_log_level_rec => p_log_level_rec);
                       raise error_found;
               END;

               if (l_result_code = 'FOUND') then
                  -- found invoice in ap_mc_invoice_dists for this reporting book

                  if (l_line_base_amount = 0) then
                     l_exchange_rate := 1;
                  else
                     l_exchange_rate := (l_mc_line_base_amount/
                                         l_line_base_amount);
                  end if;
               else
                  -- invoice not found in ap_mc_invoice_dists table for reporting book
                  if (l_inv_currency_code <> l_currency_code) then

                     l_exchange_date      := l_inv_exchange_date;
                     l_exchange_rate      := l_inv_exchange_rate;
                     l_exchange_rate_type := l_inv_exchange_rate_type;

                     gl_mc_currency_pkg.get_rate(
                        l_primary_sob_id, -- v_rsob.primary_set_of_books_id,
                        p_set_of_books_id, -- v_rsob.set_of_books_id
                        l_inv_exchange_date,
                        l_inv_currency_code,
                        l_exchange_rate_type,
                        l_exchange_date,
                        l_exchange_rate,
                        140,
                        null,
                        p_book_type_code,
                        null,
                        null,
                        l_result_code,
                        l_denominator_rate,
                        l_numerator_rate);

                     -- bug 2095221 not inverting when get_rate have been called.
                     -- bug 2533988 reverting change for 2095221

                     l_exchange_rate := l_exchange_rate /
                                        l_inv_exchange_rate;
                  else
                     l_exchange_rate := 1 / l_inv_exchange_rate;
                  end if;
               end if; -- end of if l_result_code = FOUND
            END;

         elsif (p_inv_rec.feeder_system_name = 'ORACLE PROJECTS') then

            l_result_code := 'FOUND';
-- bug 4583014
--            if (p_inv_rec.merged_code = 'MP' OR
--                l_primary_currency_code = l_currency_code) then
--               l_exchange_rate := 1;

            if ((p_inv_rec.merged_code = 'MP'
			and p_inv_rec.fixed_assets_cost = 0) OR
                	l_primary_currency_code = l_currency_code) then
               l_exchange_rate := 1;
-- end bug
            else
               BEGIN
                  select current_asset_cost
                    into l_current_asset_cost
                    from pa_mc_prj_ast_lines_all
                   where project_asset_line_id = p_inv_rec.project_asset_line_id
                     and set_of_books_id       = p_set_of_books_id;

-- bug 4583014 changing if
--                  if (p_inv_rec.fixed_assets_cost = 0) then

                  if (p_inv_rec.fixed_assets_cost = 0 or nvl(l_current_asset_cost,0)  = 0 ) then
                      l_exchange_rate := 1;
                  else

		      if p_inv_rec.split_code = 'SC' then
                         -- BUG# 3892604
                         -- get value from PA when not found
			 select current_asset_cost
			 into l_prj_fixed_assets_cost
			 from pa_project_asset_lines_all
                         where project_asset_line_id = p_inv_rec.project_asset_line_id;
		      else
			 l_prj_fixed_assets_cost := p_inv_rec.fixed_assets_cost;
		      end if;

                      l_exchange_rate := l_current_asset_cost /
					      NVL(l_prj_fixed_assets_cost,1);

                   end if;

               EXCEPTION
                  when NO_DATA_FOUND then
                       l_result_code := 'NOT_FOUND';
                  when OTHERS then
                       fa_srvr_msg.add_message(
                          calling_fn => l_calling_fn,
                          name       => 'FA_MRC_SLT_MC_RECS',
                          token1     => 'TABLE',
                          value1     => 'pa_mc_prj_ast_lines_all',
                          token2     => 'TRIGGER',
                          value2     => 'fa_mc_mass_additions_aiud', p_log_level_rec => p_log_level_rec);
                       raise error_found;
               END;

               if (l_result_code = 'NOT_FOUND') then

                  -- NOTE: the old mrc trigger used sysdate here,
                  -- but as this will be called at post not insert
                  -- this is not consistent.  need to investigate
                  -- using another date in the table
                  --  ( i.e. creation_date/create_batch_date/invoice_date/last_update_date/dpis )

                  l_exchange_date      := SYSDATE;
                  l_exchange_rate      := NULL;
                  l_exchange_rate_type := NULL;
                  l_trans_date         := l_exchange_date;

                  gl_mc_currency_pkg.get_rate(
                     l_primary_sob_id,       -- v_rsob.primary_set_of_books_id,
                     p_set_of_books_id,      -- v_rsob.set_of_books_id,
                     l_trans_date,           -- change / verify
                     l_primary_currency_code,
                     l_exchange_rate_type,
                     l_exchange_date,
                     l_exchange_rate,
                     140,
                     null,
                     p_book_type_code,
                     null,
                     null,
                     l_result_code,
                     l_denominator_rate,
                     l_numerator_rate);
               end if;
            end if; -- end if mp / currency code

         else
            -- if the rate is not provided for non-ap and non-pa lines,
            -- derive and load it...  this is needed for quick/detail adds
            -- and source line additions as well as for flexibility

            -- also the R12 logic for all lines

if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add('X','p sob', l_primary_sob_id, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add('X','r sob', p_set_of_books_id, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add('X','p date', px_exchange_date, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add('X','p book', p_book_type_code, p_log_level_rec => p_log_level_rec);

end if;

            if not get_trx_rate
                      (p_prim_set_of_books_id       => l_primary_sob_id,
                       p_reporting_set_of_books_id  => p_set_of_books_id,
                       px_exchange_date             => px_exchange_date,
                       p_book_type_code             => p_book_type_code,
                       px_rate                      => l_exchange_rate,
                       p_log_level_rec              => p_log_level_rec) then
               raise error_found;
            end if;

         end if; -- 11i/ap/pa/other
      END;       -- BEGIN block for invoices
   end if;       -- if found (for split)

   -- assign the exchange rate back to the record
   px_inv_rate_rec.exchange_rate := l_exchange_rate;

   return true;

EXCEPTION

   when error_found then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;


END get_invoice_rate;

END FA_MC_UTIL_PVT;

/
