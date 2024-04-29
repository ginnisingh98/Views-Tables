--------------------------------------------------------
--  DDL for Package Body FA_BEGIN_MASS_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_BEGIN_MASS_TRX_PKG" AS
/* $Header: FAXBMTB.pls 120.5.12010000.2 2009/07/19 14:20:15 glchen ship $ */

--
-- FUNCTION faxbmt
--

FUNCTION faxbmt (X_book         IN      VARCHAR2,
                 X_request_id   IN      NUMBER,
		 X_result	IN OUT NOCOPY BOOLEAN
                 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)      RETURN BOOLEAN IS
    h_trx_type		 varchar2(20);
    h_conc_program_id 	 number(15);
BEGIN

    if (X_request_id IS NOT NULL and X_request_id <> 0) then
	SELECT RE.CONCURRENT_PROGRAM_ID
        INTO h_conc_program_id
        FROM FND_CONCURRENT_REQUESTS RE
        WHERE RE.REQUEST_ID = X_request_id
        AND   RE.PROGRAM_APPLICATION_ID in (140, 8731);
        -- AND   RE.PROGRAM_APPLICATION_ID  = 140;  -- commented for bug2250373

/*  BUG# 1468964
    changed to incorporate all mass programs calls
    only depreciation should use "other".  All
    other programs should verify that periods are
    in sync between primary and reporting books
      -- bridgway 10/18/00
*/

	SELECT DECODE(PR.CONCURRENT_PROGRAM_NAME,
                       'FAMTFR',  'TRANSFER',
                       'FAMAPT',  'RECLASS',
		       'FAMRCL',  'RECLASS',
                       'FARET',   'GAINLOSS',
                       'FAMRET',  'MASSRET',
                       'FAMRST',  'MASSRST',
                       'FADRB',   'RB_DEP',
                       'FADRB2',  'RB_DEP',
                       'FAJERB',  'RB_CJE',
                       'FAMCP',   'COPY',
                       'FAIMCP',  'COPY',
                       'FATAXUP', 'TAXUP',
                       'FAUSTR',  'TAXUP',
                       'FAACUP',  'TAXUP',
                       'FATMTA',  'TAXUP',
                       'FAMACH',  'MASSCHG',
                       'FAVRVL',  'REVAL',
                       'FACXTRET','TRANSFER', -- bug# 2153455
                       'FACTFR',  'TRANSFER', -- bug# 2153455
                       'FACHRMR', 'TRANSFER', -- bug# 2153455
                       'OTHER')
        INTO  h_trx_type
        FROM  FND_CONCURRENT_PROGRAMS PR
        WHERE PR.CONCURRENT_PROGRAM_ID = h_conc_program_id
        AND PR.APPLICATION_ID in ( 140, 8731 );
        -- AND   PR.APPLICATION_ID  = 140;  -- commented for bug2250373
    else
	-- assume TRANSFER (most restrictive)
	h_trx_type := 'TRANSFER';
    end if;

    /*
     * Call faxcbs() to check the book status with submit_flag == FALSE
     * and start_flag == TRUE because we are not submitting depreciation
     * but are starting a mass process
     */
    if not FA_CHK_BOOKSTS_PKG.faxcbs(X_book, FALSE, TRUE,
				     0, h_trx_type, X_result, p_log_level_rec => p_log_level_rec) then
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_BEGIN_MASS_TRX_PKG.faxbmt',  p_log_level_rec => p_log_level_rec);
	X_result := FALSE;
	return (FALSE);
    end if;

    /* All checks completed, update book_controls with mass request id */

    /*
     * Ensure this is the only request running against the book by
     * updating the request ID in fa_book_controls to the request_id
     * of the running request
     */

    UPDATE  fa_book_controls
    SET     mass_request_id = X_request_id
    WHERE   book_type_code = X_book;

    return (TRUE);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	FA_SRVR_MSG.Add_Message(
		CALLING_FN => 'FA_BEGIN_MASS_TRX_PKG.faxbmt',
                NAME => 'CONC_MISSING_REQUEST',
                TOKEN1 => 'ROUTINE', VALUE1 => 'FA_TRXAPP',
                TOKEN2 => 'REQUEST', VALUE2 => X_request_id,  p_log_level_rec => p_log_level_rec);
	X_result := FALSE;
	return (FALSE);
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_SQL_Error
                (CALLING_FN=>'FA_BEGIN_MASS_TRX_PKG.faxbmt',  p_log_level_rec => p_log_level_rec);
	X_result := FALSE;
	return (FALSE);
END faxbmt;


--
-- FUNCTION faxemt
--
FUNCTION faxemt (X_book         IN      VARCHAR2,
                 X_request_id   IN      NUMBER
                 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)      RETURN BOOLEAN IS
BEGIN

    UPDATE  fa_book_controls
    SET     mass_request_id = NULL
    WHERE   book_type_code = X_book
    AND     mass_request_id = X_request_id;

    commit work;

    return (TRUE);
EXCEPTION
    WHEN OTHERS THEN
	rollback work;
	FA_SRVR_MSG.Add_SQL_Error
                (CALLING_FN=>'FA_BEGIN_MASS_TRX_PKG.faxemt',  p_log_level_rec => p_log_level_rec);
	return (FALSE);
END faxemt;


END FA_BEGIN_MASS_TRX_PKG;

/
