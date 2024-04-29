--------------------------------------------------------
--  DDL for Package Body FA_SORP_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SORP_UTIL_PVT" as
/* $Header: FAVSPUTB.pls 120.2.12010000.1 2009/07/21 12:37:48 glchen noship $   */

-- Determine if debug is enabled


/* This function must be used only when the cache information is not available.
   Whenever possible, please check whether SORP is enabled using sorp_enabled_flag
   available in cache */
/*#
 * Thus function accepts a Book Type Code and returns True if SORP
 * is enabled for that book. False otherwise.
 * @param p_book_type_code The book for which SORP enabled check must be performed
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Is SORP Enabled
 * @rep:compatibility S
*/
FUNCTION IS_SORP_ENABLED(p_book_type_code FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE,
p_log_level_rec       IN     fa_api_types.log_level_rec_type default null)
RETURN BOOLEAN
IS
    l_sorp_enabled_flag VARCHAR2(1);
    l_calling_fn varchar2(35) := 'FA_SORP_UTIL_PVT.IS_SORP_ENABLED';
BEGIN
    IF (p_log_level_rec.statement_level) then
        fa_debug_pkg.add
               (l_calling_fn,
                'Book Type Code Passed is ',
                p_book_type_code, p_log_level_rec => p_log_level_rec);
    End If;

    SELECT SORP_ENABLED_FLAG
    INTO l_sorp_enabled_flag
    FROM FA_BOOK_CONTROLS
    WHERE BOOK_TYPE_CODE = p_book_type_code;

    IF (p_log_level_rec.statement_level) then
        fa_debug_pkg.add
               (l_calling_fn,
                'SORP Enabled Flag is ',
                l_sorp_enabled_flag, p_log_level_rec => p_log_level_rec);
    End If;

    IF l_sorp_enabled_flag = 'Y' Then
        RETURN TRUE;
    Else
        RETURN FALSE;
    End If;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error
            (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        RETURN FALSE;
END IS_SORP_ENABLED;


/*#
 * Thus function is used to create neutralizing accounting entries for SORP
 * compliance. This is an overloaded function which is called from several locations
 * like revaluation, depreciation, impairments, transfers, etc. This overloaded
 * function is a simplified version of the main create_sorp_neutral_acct function.
 * @param p_amount The amount for which neutralizing entrie needs to be created
 * @param p_reversal 'Y' indicates that a reversal entrie needs to be created
 * @param p_adj Adjustment record needs to be populated with information like book, etc
 * @param p_created_by standard who column information
 * @param p_creation_date standard who column information
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname create_sorp_neutral_acct
 * @rep:compatibility S
*/
FUNCTION create_sorp_neutral_acct (
    p_amount                IN NUMBER,
    p_reversal              IN VARCHAR2,
    p_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS
    pos_err EXCEPTION;
    l_calling_fn        varchar2(60) := 'create_sorp_neutral_acct (overloaded)';
    l_mode              varchar2(20) := 'neutralizing';
BEGIN

    if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,'Entering overloaded function', 'true', p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_amount', p_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_reversal', p_reversal, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_adj.book_type_code', p_adj.book_type_code, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_created_by', p_created_by, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_creation_date', p_creation_date, p_log_level_rec => p_log_level_rec);
    end if;

    if not create_sorp_neutral_acct(
        p_amount => p_amount,
        p_reversal => p_reversal,
        p_adj => p_adj,
        p_created_by => p_created_by,
        p_creation_date => p_creation_date,
        p_last_update_date => NULL,
        p_last_updated_by => NULL,
        p_last_update_login => NULL,
        p_who_mode => 'CREATE',
        p_log_level_rec => p_log_level_rec) then
        fa_debug_pkg.add(l_calling_fn,'create_sorp_neutral_acct', 'failed', p_log_level_rec => p_log_level_rec);
        return false;
    end if;

    return true;
EXCEPTION
    WHEN OTHERS THEN
        fa_debug_pkg.add(l_calling_fn,'unexpected error', l_mode, p_log_level_rec => p_log_level_rec);
        return false;
END create_sorp_neutral_acct;


/*#
 * Thus function is used to create neutralizing accounting entries for SORP
 * compliance. This is a generic function which is called from several locations
 * like revaluation, depreciation, impairments, transfers, etc
 * @param p_amount The amount for which neutralizing entrie needs to be created
 * @param p_reversal 'Y' indicates that a reversal entrie needs to be created
 * @param p_adj Adjustment record needs to be populated with information like book, etc
 * @param p_created_by standard who column information
 * @param p_creation_date standard who column information
 * @param p_last_update_date standard who column information
 * @param p_last_updated_by standard who column information
 * @param p_last_update_login standard who column information
 * @param p_who_mode Indicates what kind of data need to be inserted into the who
 *        columns of fa_adjusments. In FA, some pieces of code insert the
 *        created by information and other places the updated by information for the
 *        who columns of FA_ADJUSTMENTS. Thus this column has been added to make
 *        this function generic and insert the appropriate data as required depending
 *        on where it is called from
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname create_sorp_neutral_acct
 * @rep:compatibility S
*/
FUNCTION create_sorp_neutral_acct (
    p_amount                IN NUMBER,
    p_reversal              IN VARCHAR2,
    p_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE,
    p_last_update_date      IN DATE,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_who_mode              IN VARCHAR2
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN BOOLEAN IS
    pos_err EXCEPTION;
    l_calling_fn        varchar2(60) := 'create_sorp_neutral_acct';
    l_mode              varchar2(20) := 'neutralizing';
    l_leveling_flag     boolean;
BEGIN

    if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,'p_amount', p_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_reversal', p_reversal, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_adj.book_type_code', p_adj.book_type_code, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_created_by', p_created_by, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_creation_date', p_creation_date, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_last_update_date', p_last_update_date, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_last_updated_by', p_last_updated_by, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_last_update_login', p_last_update_login, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_who_mode', p_who_mode, p_log_level_rec => p_log_level_rec);
	fa_debug_pkg.add(l_calling_fn,'p_adj.leveling_flag',p_adj.leveling_flag, p_log_level_rec => p_log_level_rec);
    end if;

    l_leveling_flag := p_adj.leveling_flag;
    p_adj.leveling_flag := FALSE;

    if (p_amount <> 0) then
        --******************************************************
        --       Capital Adjustment
        --******************************************************
        p_adj.adjustment_amount := p_amount;
        p_adj.adjustment_type   := 'CAPITAL ADJ';
        p_adj.account_type      := 'CAPITAL_ADJ_ACCT';
        p_adj.account           := fa_cache_pkg.fazccb_record.capital_adj_acct;
        if p_reversal = 'Y' then
            p_adj.debit_credit_flag := 'CR';
        else
            p_adj.debit_credit_flag := 'DR';
        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Impairment
                                          Neutralizing Entry - Capital Adjustment', p_log_level_rec => p_log_level_rec);
        end if;

        if p_who_mode = 'CREATE' then
            if not FA_INS_ADJUST_PKG.faxinaj (p_adj,
                                              p_creation_date,
                                              p_created_by, p_log_level_rec => p_log_level_rec) then
                raise pos_err;
            end if;
        else
            if not FA_INS_ADJUST_PKG.faxinaj (p_adj,
                                              p_last_update_date,
                                              p_last_updated_by,
                                              p_last_update_login
                                              , p_log_level_rec => p_log_level_rec) then
                raise pos_err;
            end if;
        end if;

        --******************************************************
        --       General Fund
        --******************************************************
        p_adj.adjustment_amount := p_amount;
        p_adj.adjustment_type   := 'GENERAL FUND';
        p_adj.account_type      := 'GENERAL_FUND_ACCT';
        p_adj.account           := fa_cache_pkg.fazccb_record.general_fund_acct;
        if p_reversal = 'Y' then
            p_adj.debit_credit_flag := 'DR';
        else
            p_adj.debit_credit_flag := 'CR';
        end if;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Impairment
                                          Neutralizing Entry - General Fund Balance', p_log_level_rec => p_log_level_rec);
        end if;

        if p_who_mode = 'CREATE' then
            if not FA_INS_ADJUST_PKG.faxinaj (p_adj,
                                              p_creation_date,
                                              p_created_by, p_log_level_rec => p_log_level_rec) then
                raise pos_err;
            end if;
        else
            if not FA_INS_ADJUST_PKG.faxinaj (p_adj,
                                              p_last_update_date,
                                              p_last_updated_by,
                                              p_last_update_login
                                              , p_log_level_rec => p_log_level_rec) then
                raise pos_err;
            end if;
        end if;
    end if;  --End If (p_amount <> 0)

    if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,'create_sorp_neutral_acct completed', 'Success', p_log_level_rec => p_log_level_rec);
    end if;

    p_adj.leveling_flag := l_leveling_flag;

    return true;

EXCEPTION
   WHEN pos_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'exception at create_sorp_neutral_acct', 'pos_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'exception at create_sorp_neutral_acct', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END create_sorp_neutral_acct;

END FA_SORP_UTIL_PVT;

/
