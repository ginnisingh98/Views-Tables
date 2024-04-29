--------------------------------------------------------
--  DDL for Package Body FA_MC_BOOK_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_BOOK_CONTROLS_PKG" as
/* $Header: faxmcbcb.pls 120.5.12010000.3 2009/07/19 10:04:04 glchen ship $   */

--*********************** Global constants ******************************--

g_log_level_rec          fa_api_types.log_level_rec_type;

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_MC_BOOK_CONTROLS_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'MC Book Controls API';
G_API_VERSION   CONSTANT   number       := 1.0;


TYPE num_tbl  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

--*********************** Private functions ******************************--

FUNCTION insert_record
          (p_src_ledger_id  IN NUMBER,
           p_alc_ledger_id  IN NUMBER,
           p_src_currency   IN VARCHAR2,
           p_alc_currency   IN VARCHAR2,
           p_book_type_code IN VARCHAR2) RETURN BOOLEAN;

--*********************** Public procedures ******************************--

-----------------------------------------------------------------------------
--
-- Currency Based Insert
-- Called from ledger when adding an ALC
--
-----------------------------------------------------------------------------


PROCEDURE add_new_currency
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_src_ledger_id            IN     NUMBER,
    p_alc_ledger_id            IN     NUMBER,
    p_src_currency             IN     VARCHAR2,
    p_alc_currency             IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   ) IS

   l_book_type_code          v30_tbl;

   l_calling_fn              VARCHAR2(35) := 'fa_mc_bc_pkg.add_new_currency';
   error_found               EXCEPTION;

   cursor c_book_controls is
   select book_type_code
     from fa_book_controls
    where set_of_books_id = p_src_ledger_id;

BEGIN

   SAVEPOINT create_mc_bc;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   if not fa_util_pub.get_log_level_rec
          (x_log_level_rec   => g_log_level_rec) then
      raise error_found;
   end if;


   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(
          l_calling_fn,
          'after initializing message stacks',
          '',
          p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(
          l_calling_fn,
          'p_src_ledger_id',
          p_src_ledger_id,
          p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(
          l_calling_fn,
          'p_alc_ledger_id',
          p_alc_ledger_id,
          p_log_level_rec => g_log_level_rec);
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise error_found;
   end if;

   open c_book_controls;
   fetch c_book_controls bulk collect
     into l_book_type_code;
   close c_book_controls;


   for i in 1..l_book_type_code.count loop

      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(
             l_calling_fn,
             'processing book_type_code',
             l_book_type_code(i),
             p_log_level_rec => g_log_level_rec);
      end if;

      if not insert_record
              (p_src_ledger_id    => p_src_ledger_id,
               p_alc_ledger_id    => p_alc_ledger_id,
               p_src_currency     => p_src_currency,
               p_alc_currency     => p_alc_currency,
               p_book_type_code   => l_book_type_code(i)) then
         raise error_found;
      end if;

   end loop;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when error_found then
      ROLLBACK TO create_mc_bc;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO create_mc_bc;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END add_new_currency;

-----------------------------------------------------------------------------
--
-- Book Based Insert
-- Called from book controls related apis to process alternate currencies
--
-----------------------------------------------------------------------------

PROCEDURE add_new_book
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_book_type_code           IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   ) IS

   -- LPOON: Change to use ALC ledger record list instead ID list in order to
   --        get their currencies at the same time
   l_alc_ledger_list         GL_MC_INFO.r_sob_list := GL_MC_INFO.r_sob_list();
   l_src_ledger_id           NUMBER;
   l_src_currency            VARCHAR2(15);

   l_calling_fn              VARCHAR2(35) := 'fa_mc_bc_pkg.add_new_book';
   error_found               EXCEPTION;

BEGIN

   SAVEPOINT create_mc_bc;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(
          l_calling_fn,
          'processing book_type_code',
          p_book_type_code);
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise error_found;
   end if;

   -- get the src ledger id from book controls
   select lg.ledger_id,
          lg.currency_code
     into l_src_ledger_id,
          l_src_currency
     from fa_book_controls bc,
          gl_ledgers lg
    where bc.book_type_code = p_book_type_code
      and lg.ledger_id      = bc.set_of_books_id;

   -- loop through each alternate ledger currency
   -- and create the needed mc info

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(
          l_calling_fn,
          'calling GL_MC_INFO.GET_ALC_LEDGER_ID for src ledger',
          l_src_ledger_id,
          p_log_level_rec => g_log_level_rec);
   end if;

   -- LPOON: Changed to call another API to get ALC ledger list instead of ID list
   --        and then loop through that list
   GL_MC_INFO.GET_ALC_ASSOCIATED_LEDGERS
     (n_ledger_id             => l_src_ledger_id,
      n_appl_id               => 140,
      n_include_source_ledger => 'N',
      n_ledger_list           => l_alc_ledger_list);

   for i in 1..l_alc_ledger_list.count loop

      if g_log_level_rec.statement_level then
         fa_debug_pkg.add
             (l_calling_fn,
              'processing alc currency',
              l_alc_ledger_list(i).r_sob_id,
              p_log_level_rec => g_log_level_rec);
      end if;

      -- BUG# 4673321 / 4673659
      -- skip if it's the original null record for initialization
      if (l_alc_ledger_list(i).r_sob_id is not null) then

         if not insert_record
                (p_src_ledger_id    => l_src_ledger_id,
                 p_alc_ledger_id    => l_alc_ledger_list(i).r_sob_id,
                 p_src_currency     => l_src_currency,
                 p_alc_currency     => l_alc_ledger_list(i).r_sob_curr,
                 p_book_type_code   => p_book_type_code) then
            raise error_found;
         end if;

      end if;

   end loop;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when error_found then
      ROLLBACK TO create_mc_bc;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO create_mc_bc;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END add_new_book;

-----------------------------------------------------------------------------
--
-- Main Insert - called from either the rate based or book based calls
--
-----------------------------------------------------------------------------


FUNCTION insert_record
          (p_src_ledger_id       IN NUMBER,
           p_alc_ledger_id       IN NUMBER,
           p_src_currency        IN VARCHAR2,
           p_alc_currency        IN VARCHAR2,
           p_book_type_code      IN VARCHAR2) RETURN BOOLEAN IS

   -- LPOON: Remove the local variables for source and ALC ledger currencies
   -- as they're passed as parameters instead of getting them by APIs

   l_retired_status           varchar2(1) := 'C';
   l_source_retired_status    varchar2(1) := 'C';
   l_mrc_converted_flag       varchar2(1);
   l_nbv_amount_threshold     number;
   l_mass_id                  number;
   l_last_deprn_run_date      date;
   l_last_period_counter      number;
   l_current_fiscal_year      number;

   -- LPOON: A new variable to check if the record exists
   l_exist_flag               VARCHAR2(1) := 'N';

   l_calling_fn               VARCHAR2(35) := 'fa_mc_bc_pkg.insert_record';
   error_found                EXCEPTION;

BEGIN

   -- we need to do this in order to insure no
   -- mass process could be adding assets to
   -- what would be seen as an empty book

   -- lock the book while this process is occurring
   -- need to verify there is no pending deprn run first
   -- and then that there are active mass request id's

   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'locking',
         'book controls record',
         p_log_level_rec => g_log_level_rec);
   end if;

   BEGIN
      select mass_request_id
        into l_mass_id
        from fa_book_controls
       where book_type_code   = p_book_type_code
         and deprn_status     = 'C';
   EXCEPTION
      WHEN OTHERS THEN
         fa_srvr_msg.add_message
            (calling_fn => l_calling_fn,
             name       => 'FA_TRXAPP_DEPRN_IS_RUNNING',
             token1     => 'BOOK',
             value1     => p_book_type_code);
         raise error_found;
   END;

   BEGIN
      select mass_request_id
        into l_mass_id
        from fa_book_controls
       where book_type_code   = p_book_type_code
         and mass_request_id is null
         for update of mass_request_id
             NOWAIT;
   EXCEPTION
      WHEN OTHERS THEN
         fa_srvr_msg.add_message
            (calling_fn => l_calling_fn,
             name       => 'FA_TRXAPP_LOCK_FAILED',
             token1     => 'BOOK',
             value1     => p_book_type_code);
         raise error_found;
   END;

   -- check if assets exists
   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'checking',
         'if assets exist',
         p_log_level_rec => g_log_level_rec);
   end if;

   BEGIN
      select 'N'
        into l_mrc_converted_flag
        from dual
       where exists
             (select book_type_code
                from fa_books
               where book_type_code = p_book_type_code);
   EXCEPTION
      WHEN OTHERS THEN
            l_mrc_converted_flag := 'Y';

   END;

   -- calculate nbv_threshold
   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'calculating',
         'nbv amount threshold',
         p_log_level_rec => g_log_level_rec);
   end if;

   select power(10,(1-precision))
     into l_nbv_amount_threshold
     from fnd_currencies a
    where currency_code = p_alc_currency;

   -- remaining values
   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'fetching',
         'remaining values from fa_book_controls',
         p_log_level_rec => g_log_level_rec);
   end if;

   select last_deprn_run_date,
          last_period_counter,
          current_fiscal_year
     into l_last_deprn_run_date,
          l_last_period_counter,
          l_current_fiscal_year
     from fa_book_controls
    where book_type_code = p_book_type_code;

   -- insert mc book controls record
   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'checking',
         'existing mc book controls record',
         p_log_level_rec => g_log_level_rec);
   end if;

   -- LPOON: Check if MC book control record exists

   BEGIN
     SELECT 'Y'
       INTO l_exist_flag
       FROM FA_MC_BOOK_CONTROLS
      WHERE set_of_books_id = p_alc_ledger_id
        AND book_type_code = p_book_type_code;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_exist_flag := 'N';
   END;

   -- LPOON: If it doesn't exist, insert one; Otherwise, update the columns that
   --        can be changed i.e. CURRENCY_CODE and NBV_AMOUNT_THRESHOLD
   if (l_exist_flag = 'N') then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add
           (l_calling_fn,
            'inserting',
            'mc book controls record',
            p_log_level_rec => g_log_level_rec);
      end if;

     -- Insert new records
     INSERT INTO FA_MC_BOOK_CONTROLS
        (SET_OF_BOOKS_ID                 ,
         BOOK_TYPE_CODE                  ,
         CURRENCY_CODE                   ,
         DEPRN_STATUS                    ,
         DEPRN_REQUEST_ID                ,
         LAST_PERIOD_COUNTER             ,
         LAST_DEPRN_RUN_DATE             ,
         CURRENT_FISCAL_YEAR             ,
         RETIRED_STATUS                  ,
         RETIRED_REQUEST_ID              ,
         PRIMARY_SET_OF_BOOKS_ID         ,
         PRIMARY_CURRENCY_CODE           ,
         SOURCE_RETIRED_STATUS           ,
         SOURCE_RETIRED_REQUEST_ID       ,
         MRC_CONVERTED_FLAG              ,
         ENABLED_FLAG                    ,
         NBV_AMOUNT_THRESHOLD            ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         CONVERSION_STATUS               ,
         MASS_REQUEST_ID
       ) values (
         p_alc_ledger_id                 ,
         p_book_type_code                ,
         p_alc_currency                  ,
         'C'                             ,
         NULL                            ,
         l_last_period_counter           ,
         l_last_deprn_run_date           ,
         l_current_fiscal_year           ,
         l_retired_status                ,
         0                               ,
         p_src_ledger_id                 ,
         p_src_currency                  ,
         l_source_retired_status         ,
         0                               ,
         l_mrc_converted_flag            ,
         'Y'                             ,
         l_nbv_amount_threshold          ,
         fnd_global.user_id              ,
         sysdate                         ,
         fnd_global.login_id             ,
         NULL                            ,
         NULL
        );

      -- insert the mc deprn periods rows
      if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add
           (l_calling_fn,
            'inserting',
            'mc deprn periods records',
            p_log_level_rec => g_log_level_rec);
      end if;

      INSERT INTO FA_MC_DEPRN_PERIODS(
           SET_OF_BOOKS_ID,
           BOOK_TYPE_CODE,
           PERIOD_NAME,
           PERIOD_COUNTER,
           FISCAL_YEAR,
           PERIOD_NUM,
           PERIOD_OPEN_DATE,
           PERIOD_CLOSE_DATE,
           DEPRECIATION_BATCH_ID,
           RETIREMENT_BATCH_ID,
           RECLASS_BATCH_ID,
           TRANSFER_BATCH_ID,
           ADDITION_BATCH_ID,
           ADJUSTMENT_BATCH_ID,
           DEFERRED_DEPRN_BATCH_ID,
           CALENDAR_PERIOD_OPEN_DATE,
           CALENDAR_PERIOD_CLOSE_DATE,
           CIP_ADDITION_BATCH_ID,
           CIP_ADJUSTMENT_BATCH_ID,
           CIP_RECLASS_BATCH_ID,
           CIP_RETIREMENT_BATCH_ID,
           CIP_REVAL_BATCH_ID,
           CIP_TRANSFER_BATCH_ID,
           REVAL_BATCH_ID,
           DEPRN_ADJUSTMENT_BATCH_ID)
       SELECT p_alc_ledger_id,
              p_book_type_code,
              PERIOD_NAME,
              PERIOD_COUNTER,
              FISCAL_YEAR,
              PERIOD_NUM,
              PERIOD_OPEN_DATE,
              PERIOD_CLOSE_DATE,
              DEPRECIATION_BATCH_ID,
              RETIREMENT_BATCH_ID,
              RECLASS_BATCH_ID,
              TRANSFER_BATCH_ID,
              ADDITION_BATCH_ID,
              ADJUSTMENT_BATCH_ID,
              DEFERRED_DEPRN_BATCH_ID,
              CALENDAR_PERIOD_OPEN_DATE,
              CALENDAR_PERIOD_CLOSE_DATE,
              CIP_ADDITION_BATCH_ID,
              CIP_ADJUSTMENT_BATCH_ID,
              CIP_RECLASS_BATCH_ID,
              CIP_RETIREMENT_BATCH_ID,
              CIP_REVAL_BATCH_ID,
              CIP_TRANSFER_BATCH_ID,
              REVAL_BATCH_ID,
              DEPRN_ADJUSTMENT_BATCH_ID
         FROM FA_DEPRN_PERIODS
        WHERE BOOK_TYPE_CODE = p_book_type_code;

   ELSE

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add
           (l_calling_fn,
            'updating',
            'mc book controls record',
            p_log_level_rec => g_log_level_rec);
      end if;

      -- Update existing records for columns which can be changed only
      UPDATE FA_MC_BOOK_CONTROLS
         SET CURRENCY_CODE        = p_alc_currency,
             NBV_AMOUNT_THRESHOLD = l_nbv_amount_threshold
       WHERE set_of_books_id      = p_alc_ledger_id
         AND book_type_code       = p_book_type_code;

   END IF; -- IF (l_exist_flag = 'N')

   -- update the mrc anabled flag on primary table
   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'updating',
         'fa_book_controls.mc_source_flag',
         p_log_level_rec => g_log_level_rec);
   end if;

   update fa_book_controls
      set mc_source_flag = 'Y'
   where book_type_code  = p_book_type_code;

   if (g_log_level_rec.statement_level) then
     fa_debug_pkg.add
        (l_calling_fn,
         'returning',
         'true',
         p_log_level_rec => g_log_level_rec);
   end if;


   return true;

EXCEPTION
   WHEN ERROR_FOUND THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
      return FALSE;

END insert_record;

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--
-- Currency Based Update
-- Called from ledger when disabling an ALC
--
-----------------------------------------------------------------------------

PROCEDURE disable_currency
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,

    p_src_ledger_id            IN     NUMBER,
    p_alc_ledger_id            IN     NUMBER,
    p_src_currency             IN     VARCHAR2,
    p_alc_currency             IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
   ) IS

   l_calling_fn              VARCHAR2(35) := 'fa_mc_bc_pkg.disable_currency';
   error_found               EXCEPTION;

BEGIN

   SAVEPOINT update_mc_bc;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   if not fa_util_pub.get_log_level_rec
          (x_log_level_rec   => g_log_level_rec) then
      raise error_found;
   end if;


   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(
          l_calling_fn,
          'after initializing message stacks',
          '',
          p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(
          l_calling_fn,
          'p_src_ledger_id',
          p_src_ledger_id,
          p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(
          l_calling_fn,
          'p_alc_ledger_id',
          p_alc_ledger_id,
          p_log_level_rec => g_log_level_rec);
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise error_found;
   end if;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(
          l_calling_fn,
          'updating the books',
          '',
          p_log_level_rec => g_log_level_rec);
   end if;


   Update fa_mc_book_controls
      set enabled_flag            = 'N',
          last_update_date        = sysdate,
          last_updated_by         = fnd_global.user_id,
          last_update_login       = fnd_global.login_id
    where set_of_books_id         = p_alc_ledger_id
      and primary_set_of_books_id = p_src_ledger_id
      and enabled_flag            = 'Y';

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when error_found then
      ROLLBACK TO update_mc_bc;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO update_mc_bc;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn);

      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END disable_currency;

----------------------------------------------------------------------------


END FA_MC_BOOK_CONTROLS_PKG;

/
