--------------------------------------------------------
--  DDL for Package Body FA_TRX_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRX_APPROVAL_PKG" AS
/* $Header: FATRXAPB.pls 120.5.12010000.3 2009/07/19 11:48:09 glchen ship $ */



FUNCTION faxcat    (X_book 		    VARCHAR2,
			X_asset_id 	    NUMBER,
			X_trx_type 	    VARCHAR2,
			X_trx_date 	    DATE,
			X_init_message_flag VARCHAR2 DEFAULT 'NO', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
    RETURN BOOLEAN IS
    	h_result BOOLEAN;
    	X_result BOOLEAN;
    BEGIN


    	IF (X_init_message_flag = 'YES') THEN
  	    -- initialize Message and Debug stacks
   	    FA_SRVR_MSG.Init_Server_Message;
   	    FA_DEBUG_PKG.Initialize;
    	END if;


        h_result  := TRUE;

        IF NOT  faxcti(X_book=>X_book,
			X_asset_id=>X_asset_id,
			X_trx_type=>X_trx_type,
			X_trx_date=>X_trx_date,
                        X_result=>h_result,
                        p_log_level_rec => p_log_level_rec )  THEN
                FA_SRVR_MSG.add_message
                    (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcat',  p_log_level_rec => p_log_level_rec);
                RETURN (h_result);     /*FALSE */
        END IF;

	IF (p_log_level_rec.statement_level)  THEN
            FA_DEBUG_PKG.ADD ('FA:faxcat. After returning from faxcti','h_result=',h_result, p_log_level_rec => p_log_level_rec);
        END IF;


        IF (NOT FA_CHK_BOOKSTS_PKG.faxcbs(X_book=>X_book,
				X_submit=>FALSE,
				X_start=>FALSE,
				X_asset_id=>X_asset_id ,
                		X_trx_type=>X_trx_type ,
				X_txn_status=>h_result, p_log_level_rec => p_log_level_rec)) THEN
                FA_SRVR_MSG.add_message
                    (CALLING_FN=>'FA_TRX_APPROVAL_PKG.faxcat',  p_log_level_rec => p_log_level_rec);
                RETURN (h_result);   /*FALSE*/
        END IF;

        RETURN (h_result);     /*TRUE*/

    EXCEPTION
        WHEN OTHERS THEN
            FA_SRVR_MSG.Add_SQL_Error
                (CALLING_FN=>'FA_TRX_APPROVAL_PKG.faxcat',  p_log_level_rec => p_log_level_rec);
            h_result := FALSE;
            RETURN (h_result);    /*FALSE*/
--dbms_output.put_line('end of func1');

    END faxcat;


/*=========================================================================
|
| This function checks transaction integrity. It checks whether there any
| transactions entered for this asset on a date after this transaction date.
| Also checks whether there are retirements pending for the asset.
|
|   Modifies:      X_result = TRUE (boolean) if transaction is allowed
|
|   Returns:       TRUE(boolean) if no error
+==========================================================================*/


    FUNCTION faxcti (X_book VARCHAR2,
			X_asset_id NUMBER,
			X_trx_type VARCHAR2,
			X_trx_date DATE,
			X_result IN OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)   RETURN BOOLEAN IS
        h_count    NUMBER := 0;
        h_count_mrc NUMBER := 0;
        h_mrc_book_count NUMBER := 0;
        h_ah_units NUMBER := 0;
        h_dh_units NUMBER := 0;

        l_corp_book varchar2(30);
        error_found exception;

    BEGIN
	--X_result would be always TRUE at this stage.
	IF (p_log_level_rec.statement_level)THEN
            FA_DEBUG_PKG.ADD ('FA:faxcti','X_result in faxcti in the beginning  = ',X_result, p_log_level_rec => p_log_level_rec);
        END IF;

        -- added for BUG# 1338191 for approving UNDO RETIREMENT trx's
        -- added enabled_clause for reporting books due to BUG# 1486157

        SELECT count(*)
          INTO h_mrc_book_count
          FROM fa_mc_book_controls
         WHERE book_type_code = X_book
           AND enabled_flag = 'Y';

        --IF (X_result) THEN
            SELECT COUNT(*) INTO h_count
            FROM fa_retirements faret
            WHERE faret.asset_id = X_asset_id
            AND   faret.book_type_code = X_book
            AND   UPPER(faret.status) in ('PENDING', 'REINSTATE');

            IF (p_log_level_rec.statement_level)THEN
                FA_DEBUG_PKG.ADD ('FA:faxcti','h_count in faxcti = ',h_count, p_log_level_rec => p_log_level_rec);
            END IF;

            SELECT COUNT(*) INTO h_count_mrc
            FROM fa_retirements ret,
                 fa_mc_retirements mc_ret,
                 fa_mc_book_controls mc_bks
            WHERE ret.asset_id          = X_asset_id
            AND   ret.book_type_code    = X_book
            AND   mc_bks.book_type_code = X_book
            AND   mc_bks.enabled_flag   = 'Y'
            AND   ret.retirement_id     = mc_ret.retirement_id
            AND   UPPER(mc_ret.status) in ('PENDING', 'REINSTATE')
            AND   mc_ret.set_of_books_id = mc_bks.set_of_books_id;

            IF (p_log_level_rec.statement_level)THEN
                FA_DEBUG_PKG.ADD ('FA:faxcti','h_count_mrc in faxcti = ',h_count_mrc, p_log_level_rec => p_log_level_rec);
            END IF;

            /* changed the following for BUG# 1338191
               UNDO RETIRE can not check for PENDING retirements or else
               the transaction would never be allowed.  However, we must
               check the primary and reporting to verify that gain/loss
               has not been run on the reporting books.  --bridgway 06/23/00
            */
            IF ((X_trx_type = 'UNDO RETIRE') or
                (X_trx_type = 'DELETE REINSTATEMENT')) then
               /*  correcting BUG# 1340968 to not use "!="  */
               IF (h_mrc_book_count <> 0) THEN
                  IF (h_count <> (h_count_mrc/h_mrc_book_count))  THEN
                     FA_SRVR_MSG.add_message
                     (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcti',
                     NAME         =>  'FA_SHARED_PENDING_RETIREMENT',  p_log_level_rec => p_log_level_rec);
                     X_result := FALSE;
                     RETURN (X_result);    /*FALSE*/
                  ELSE
                     X_result := TRUE;
                  END IF;
                ELSE
                  X_result := TRUE;
                END IF;
             ELSE
                IF (h_count + h_count_mrc > 0)  THEN
                   FA_SRVR_MSG.add_message
                   (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcti',
                   NAME        =>  'FA_SHARED_PENDING_RETIREMENT',  p_log_level_rec => p_log_level_rec);
                   X_result := FALSE;
                   RETURN (X_result);    /*FALSE*/
                ELSE
                    X_result := TRUE;
                END IF;
             END IF;
        --END IF;


            -- BUG# 5444344
            -- for tax, need to check corp retirements to due to
            -- partial unit impacts

            if (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then

               l_corp_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

               SELECT COUNT(*) INTO h_count
               FROM fa_retirements faret
               WHERE faret.asset_id = X_asset_id
               AND   faret.book_type_code = l_corp_book
               AND   UPPER(faret.status) in ('PENDING');

               IF (p_log_level_rec.statement_level)THEN
                   FA_DEBUG_PKG.ADD ('FA:faxcti','h_count in faxcti = ',h_count
                                           ,p_log_level_rec => p_log_level_rec);
               END IF;

               SELECT COUNT(*) INTO h_count_mrc
               FROM fa_retirements ret,
                    fa_mc_retirements mc_ret,
                    fa_mc_book_controls mc_bks
               WHERE ret.asset_id          = X_asset_id
               AND   ret.book_type_code    = l_corp_book
               AND   mc_bks.book_type_code = l_corp_book
               AND   mc_bks.enabled_flag   = 'Y'
               AND   ret.retirement_id     = mc_ret.retirement_id
               AND   UPPER(mc_ret.status) in ('PENDING')
               AND   mc_ret.set_of_books_id = mc_bks.set_of_books_id;

               IF (p_log_level_rec.statement_level)THEN
                   FA_DEBUG_PKG.ADD ('FA:faxcti','h_count_mrc in faxcti = ',h_count_mrc
                                        ,p_log_level_rec => p_log_level_rec);
               END IF;

               IF ((X_trx_type = 'UNDO RETIRE') or
                   (X_trx_type = 'DELETE REINSTATEMENT')) then
                  /*  correcting BUG# 1340968 to not use "!="  */
                  IF (h_mrc_book_count <> 0) THEN
                     IF (h_count <> (h_count_mrc/h_mrc_book_count))  THEN
                        FA_SRVR_MSG.add_message
                        (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcti',
                         NAME         =>  'FA_SHARED_PENDING_RETIREMENT'
                         ,p_log_level_rec => p_log_level_rec);
                        X_result := FALSE;
                        RETURN (X_result);    /*FALSE*/
                     ELSE
                        X_result := TRUE;
                     END IF;
                  ELSE
                     X_result := TRUE;
                  END IF;
               ELSE
                  IF (h_count + h_count_mrc > 0)  THEN
                      FA_SRVR_MSG.add_message
                      (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcti',
                      NAME        =>  'FA_SHARED_PENDING_RETIREMENT'
                      ,p_log_level_rec => p_log_level_rec);
                      X_result := FALSE;
                      RETURN (X_result);    /*FALSE*/
                  ELSE
                    X_result := TRUE;
                  END IF;
               END IF;
            END IF;  -- tax class

        --IF (X_result) THEN		/* X_result  */
            IF UPPER(X_trx_type)  IN('TRANSFER', 'CIP TRANSFER', 'RECLASS',
                'CIP RECLASS') THEN
                SELECT units
		INTO h_ah_units
		FROM fa_asset_history
                WHERE asset_id = X_asset_id
                AND date_ineffective IS NULL;

	        IF (p_log_level_rec.statement_level)THEN
                   FA_DEBUG_PKG.ADD ('FA:faxcat','h_ah_units in faxcti',h_ah_units, p_log_level_rec => p_log_level_rec);
                END IF;

            	SELECT SUM(units_assigned)
		INTO h_dh_units
		FROM fa_distribution_history
            	WHERE asset_id = X_asset_id
            	AND date_ineffective IS NULL;

  	        IF (p_log_level_rec.statement_level)THEN
                   FA_DEBUG_PKG.ADD ('FA:faxcat','h_dh_units in facti',h_dh_units, p_log_level_rec => p_log_level_rec);
                END IF;

            	IF (h_ah_units <> h_dh_units) THEN
                    FA_SRVR_MSG.add_message
                    (CALLING_FN  =>  'FA_TRX_APPROVAL_PKG.faxcti',
                    NAME        =>  'FA_SHARED_UNITS_UNBAL',  p_log_level_rec => p_log_level_rec);
                    X_result := FALSE;
                    RETURN (X_result);   /*FALSE*/
                ELSE
                    X_result := TRUE;
		END IF;
            END IF;
        --END IF;		/* X_result */

        /* mwoodwar 02/22/00.  CRL stub call. */
        if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
          if not fa_cua_trx_approval_ext_pkg.facuas1(x_trx_type,
                                                     x_book,
                                                     x_asset_id, p_log_level_rec => p_log_level_rec) then
            x_result:= FALSE;
          end if;
        end if;

        --bug6933756
        FA_TRACK_MEMBER_PVT.p_track_member_table.delete;
        -- bug 7231274
        FA_TRACK_MEMBER_PVT.p_track_mem_index_table.delete;

        RETURN (X_result);	/*TRUE*/

    EXCEPTION
        WHEN OTHERS THEN
            FA_SRVR_MSG.Add_SQL_Error
                (CALLING_FN  => 'FA_TRX_APPROVAL_PKG.faxcti',  p_log_level_rec => p_log_level_rec);
            X_result := FALSE;
            RETURN (X_result);  /*FALSE*/


    END faxcti;


END FA_TRX_APPROVAL_PKG;

/
