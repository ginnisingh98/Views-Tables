--------------------------------------------------------
--  DDL for Package Body IGI_IAC_YTD_PRE_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_YTD_PRE_PROCESS_PKG" AS
-- $Header: igiiapyb.pls 120.7.12000000.1 2007/08/01 16:16:22 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiapyb.IGI_IAC_YTD_PRE_PROCESS_PKG.';

--===========================FND_LOG.END=======================================

   PROCEDURE POPULATE_IAC_FA_DEPRN_DATA ( errbuf      OUT NOCOPY   VARCHAR2
                          		, retcode     OUT NOCOPY   NUMBER
                          		, p_book_type_code IN    VARCHAR2
                          		, p_calling_mode   IN    VARCHAR2 ) IS

    cursor c_get_dist_ytd(cp_book_type_code varchar2,
                            cp_asset_id number,
                            cp_distribution_id number) is
    select sum(nvl(fdd.deprn_amount,0)-nvl(fdd.deprn_adjustment_amount,0)) deprn_YTD
    from fa_deprn_detail fdd
    where fdd.distribution_id = cp_distribution_id
    and fdd.book_type_code like cp_book_type_code
    and fdd.asset_id = cp_asset_id
    and fdd.period_counter in (select period_counter from fa_deprn_periods
                                where book_type_code = cp_book_type_code
                                and fiscal_year = (select decode(period_num,1,fiscal_year-1,fiscal_year)
                                                    from fa_deprn_periods
                                                    where period_close_date is NULL
                                                    and book_type_code = cp_book_type_code))
    group by fdd.asset_id,fdd.distribution_id;

    CURSOR c_get_all_iac_assets IS
    SELECT DISTINCT asset_id
    FROM igi_iac_transaction_headers
    WHERE book_type_code = p_book_type_code;

    cursor c_get_dist_deprn(cp_asset_id number,cp_distribution_id number) is
    select (nvl(deprn_amount,0) - nvl(deprn_adjustment_amount,0)) deprn_amount,
            deprn_reserve,
            period_counter
    from fa_deprn_detail
    where book_type_code = p_book_type_code
    and asset_id = cp_asset_id
    and distribution_id = cp_distribution_id
    and period_counter = (select max(period_counter)
                            from fa_deprn_summary
                            where book_type_code = p_book_type_code
                            and asset_id = cp_asset_id);

    CURSOR c_get_dists(cp_asset_id number, cp_adjustment_id number) IS
    SELECT *
    FROM igi_iac_det_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_adjustment_id;

    CURSOR c_get_dist_info(cp_asset_id number,cp_adjustment_id number,cp_distribution_id number) IS
    SELECT period_counter
    FROM igi_iac_det_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_adjustment_id
    AND distribution_id = cp_distribution_id;

    CURSOR c_get_iac_fa_deprn_rec IS
    SELECT 'X'
    FROM igi_iac_fa_deprn
    WHERE book_type_code = p_book_type_code
    AND rownum = 1;

    cursor c_check_igi_fa_deprn (cp_asset_id number,
                                cp_distribution_id number,
                                cp_adjustment_id number,
                                cp_period_counter number) is
    Select *
    From igi_iac_fa_deprn
    Where book_type_code = p_book_type_code
    and asset_id = cp_asset_id
    and distribution_id = cp_distribution_id
    and adjustment_id = cp_adjustment_id
    and period_counter = cp_period_counter;

    -- bug 3421734, start 1
    CURSOR c_fully_reserved(cp_asset_id fa_books.asset_id%TYPE,
                            cp_book_type_code  fa_books.book_type_code%TYPE)
    IS
    SELECT nvl(period_counter_fully_reserved, 0)
    FROM   fa_books
    WHERE  asset_id = cp_asset_id
    AND    book_type_code = cp_book_type_code
    AND    transaction_header_id_out IS NULL
    AND    date_ineffective IS NULL;

    l_fully_reserved_pc      fa_books.period_counter_fully_reserved%TYPE;
    -- bug 3421734 end 1

    l_Transaction_Type_Code     igi_iac_transaction_headers.transaction_type_code%TYPE;
    l_Transaction_Id            NUMBER;
    l_Mass_Reference_ID         NUMBER;
    l_Adjustment_Id             NUMBER;
    l_Prev_Adjustment_Id        NUMBER;
    l_Adjustment_Status         igi_iac_transaction_headers.adjustment_status%TYPE;
    l_rowid                     VARCHAR2(300);
    lv_mesg                     VARCHAR2(2000);
    l_debug_mode                VARCHAR2(1) := 'N';
    l_deprn_amount              NUMBER;
    l_deprn_ytd                 NUMBER;
    l_deprn_reserve             NUMBER;
    l_deprn_period_counter      NUMBER;
    l_prev_adj_period           NUMBER;
    l_dummy_char                VARCHAR2(1);
    l_check_igi_fa_deprn        c_check_igi_fa_deprn%rowtype;

    l_path 			 VARCHAR2(100) := g_path||'POPULATE_IAC_FA_DEPRN_DATA';

   BEGIN
        SAVEPOINT iac_pre_process;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'************************************');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Start of processing for book :'||p_book_type_code);
        fnd_file.put_line(fnd_file.log, 'Start of processing for book :'||p_book_type_code);
        IF NOT igi_gen.is_req_installed('IAC') THEN
       		fnd_message.set_name('IGI','IGI_GEN_PROD_NOT_INSTALLED');
       		lv_mesg := fnd_message.get;
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,lv_mesg);
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
       		retcode := 2;
            fnd_file.put_line(FND_FILE.log, lv_mesg);
       		errbuf  := lv_mesg;
       		RETURN;
    	END IF;

        IF NOT igi_iac_common_utils.is_iac_book(p_book_type_code) THEN
       		fnd_message.set_name('IGI','IGI_IAC_NOT_IAC_BOOK');
       		lv_mesg := fnd_message.get;
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,lv_mesg);
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
       		retcode := 2;
       		errbuf  := lv_mesg;
       		RETURN;
    	END IF;

        IF p_calling_mode <> 'SRS' THEN

            OPEN c_get_iac_fa_deprn_rec;
            FETCH c_get_iac_fa_deprn_rec INTO l_dummy_char;
            IF c_get_iac_fa_deprn_rec%FOUND THEN
                CLOSE c_get_iac_fa_deprn_rec;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' This process is not required for this book as the required data is already present.');
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' ********** ');
                lv_mesg := ' This process is not required for this book as the required data is already present.';
                retcode := 2;
                errbuf  := lv_mesg;
                RETURN;
            ELSE
                CLOSE c_get_iac_fa_deprn_rec;
            END IF;
        END IF;

        fnd_file.put_line(fnd_file.log, 'Processing assets');

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Processing the assets');
        FOR l_asset IN c_get_all_iac_assets LOOP
            fnd_file.put_line(fnd_file.log, 'Asset_id ' || l_asset.asset_id );

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Asset_id :'||l_asset.asset_id);
            l_Transaction_Type_Code     := NULL;
            l_Transaction_Id            := NULL;
            l_Mass_Reference_ID         := NULL;
            l_Adjustment_Id             := NULL;
            l_Prev_Adjustment_Id        := NULL;
            l_Adjustment_Status         := NULL;

            IF NOT igi_iac_common_utils.Get_Latest_Transaction (
		        X_book_type_code            => p_book_type_code
		        , X_asset_id                => l_asset.asset_id
		        , X_Transaction_Type_Code   => l_transaction_type_code
		        , X_Transaction_Id          => l_transaction_id
		        , X_Mass_Reference_ID       => l_mass_reference_id
		        , X_Adjustment_Id           => l_adjustment_id
		        , X_Prev_Adjustment_Id      => l_prev_adjustment_id
		        , X_Adjustment_Status       => l_adjustment_status) THEN

       		    retcode := 2;
       		    errbuf  := 'Error in Fetching the Latest Transaction for the asset';
       		    RETURN;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Latest Adjustment :'||l_adjustment_id);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Previous Adjustment :'||l_prev_adjustment_id);

            OPEN c_fully_reserved(l_asset.asset_id, p_book_type_code);
            FETCH c_fully_reserved INTO l_fully_reserved_pc;
            CLOSE c_fully_reserved;

            FOR l_dist IN c_get_dists(l_asset.asset_id,l_adjustment_id) LOOP
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Distribution Id :'||l_dist.distribution_id);
                fnd_file.put_line(fnd_file.log, 'distribution_id: ' || l_dist.distribution_id );

                l_deprn_ytd := 0;
                OPEN c_get_dist_ytd(p_book_type_code,l_asset.asset_id,l_dist.distribution_id);
                FETCH c_get_dist_ytd INTO l_deprn_ytd;
                IF c_get_dist_ytd%NOTFOUND THEN
                    l_deprn_ytd := 0;
                END IF;
                CLOSE c_get_dist_ytd;

                OPEN c_get_dist_deprn(l_asset.asset_id,l_dist.distribution_id);
                FETCH c_get_dist_deprn INTO l_deprn_amount,l_deprn_reserve,l_deprn_period_counter;
                IF c_get_dist_deprn%NOTFOUND THEN
                    l_deprn_amount := 0;
                    l_deprn_reserve := 0;
                END IF;
                CLOSE c_get_dist_deprn;

                IF l_fully_reserved_pc IS NOT NULL THEN
                    l_deprn_amount := 0;
                END IF;

                IF p_calling_mode <> 'SRS' THEN
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Inserting record for latest adjustment');
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_adjustment_id     =>'|| l_adjustment_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_asset_id          =>'|| l_asset.asset_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_distribution_id   =>'|| l_dist.distribution_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_book_type_code    =>'|| p_book_type_code);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_period_counter    =>'|| l_dist.period_counter);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_period      =>'|| l_deprn_amount);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_ytd         =>'|| l_deprn_ytd);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_reserve     =>'|| l_deprn_reserve);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_active_flag       =>'|| l_dist.active_flag);

                    l_rowid := NULL;
                    IGI_IAC_FA_DEPRN_PKG.insert_row (
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => l_adjustment_id,
                    x_asset_id                 => l_asset.asset_id,
                    x_distribution_id          => l_dist.distribution_id,
                    x_book_type_code           => p_book_type_code,
                    x_period_counter           => l_dist.period_counter,
                    x_deprn_period             => l_deprn_amount,
                    x_deprn_ytd                => l_deprn_ytd,
                    x_deprn_reserve            => l_deprn_reserve,
                    x_active_flag              => l_dist.active_flag,
                    x_mode                     => 'R' );
                ELSE
                    OPEN c_check_igi_fa_deprn(l_asset.asset_id,l_dist.distribution_id,l_adjustment_id,l_dist.period_counter);
                    FETCH c_check_igi_fa_deprn INTO l_check_igi_fa_deprn;
                    IF c_check_igi_fa_deprn%NOTFOUND THEN

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Inserting record for latest adjustment');
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_adjustment_id     =>'|| l_adjustment_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_asset_id          =>'|| l_asset.asset_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_distribution_id   =>'|| l_dist.distribution_id);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_book_type_code    =>'|| p_book_type_code);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_period_counter    =>'|| l_dist.period_counter);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_period      =>'|| l_deprn_amount);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_ytd         =>'|| l_deprn_ytd);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_reserve     =>'|| l_deprn_reserve);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_active_flag       =>'|| l_dist.active_flag);

                    l_rowid := NULL;
                    IGI_IAC_FA_DEPRN_PKG.insert_row (
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => l_adjustment_id,
                    x_asset_id                 => l_asset.asset_id,
                    x_distribution_id          => l_dist.distribution_id,
                    x_book_type_code           => p_book_type_code,
                    x_period_counter           => l_dist.period_counter,
                    x_deprn_period             => l_deprn_amount,
                    x_deprn_ytd                => l_deprn_ytd,
                    x_deprn_reserve            => l_deprn_reserve,
                    x_active_flag              => l_dist.active_flag,
                    x_mode                     => 'R' );
                    END IF;
                    CLOSE c_check_igi_fa_deprn;
                END IF;

                IF (nvl(l_adjustment_id,0) <> nvl(l_prev_adjustment_id,0)) AND l_prev_adjustment_id IS NOT NULL THEN

                    OPEN c_get_dist_info(l_asset.asset_id,l_prev_adjustment_id,l_dist.distribution_id);
                    FETCH c_get_dist_info INTO l_prev_adj_period;
                    CLOSE c_get_dist_info;

                    IF p_calling_mode <> 'SRS' THEN
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Inserting record for previous adjustment');
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_adjustment_id     =>'|| l_adjustment_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_asset_id          =>'|| l_asset.asset_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_distribution_id   =>'|| l_dist.distribution_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_book_type_code    =>'|| p_book_type_code);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_period_counter    =>'|| l_dist.period_counter);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_period      =>'|| l_deprn_amount);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_ytd         =>'|| l_deprn_ytd);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_reserve     =>'|| l_deprn_reserve);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_active_flag       =>'|| l_dist.active_flag);

                        l_rowid := NULL;
                        IGI_IAC_FA_DEPRN_PKG.insert_row (
                        x_rowid                    => l_rowid,
                        x_adjustment_id            => l_prev_adjustment_id,
                        x_asset_id                 => l_asset.asset_id,
                        x_distribution_id          => l_dist.distribution_id,
                        x_book_type_code           => p_book_type_code,
                        x_period_counter           => l_prev_adj_period,
                        x_deprn_period             => l_deprn_amount,
                        x_deprn_ytd                => l_deprn_ytd,
                        x_deprn_reserve            => l_deprn_reserve,
                        x_active_flag              => l_dist.active_flag,
                        x_mode                     => 'R' );
                    ELSE
                        OPEN c_check_igi_fa_deprn(l_asset.asset_id,l_dist.distribution_id,l_prev_adjustment_id,l_prev_adj_period);
                        FETCH c_check_igi_fa_deprn INTO l_check_igi_fa_deprn;
                        IF c_check_igi_fa_deprn%NOTFOUND THEN

                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'        Inserting record for previous adjustment');
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_adjustment_id     =>'|| l_adjustment_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_asset_id          =>'|| l_asset.asset_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_distribution_id   =>'|| l_dist.distribution_id);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_book_type_code    =>'|| p_book_type_code);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_period_counter    =>'|| l_dist.period_counter);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_period      =>'|| l_deprn_amount);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_ytd         =>'|| l_deprn_ytd);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_deprn_reserve     =>'|| l_deprn_reserve);
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'            x_active_flag       =>'|| l_dist.active_flag);

                        l_rowid := NULL;
                        IGI_IAC_FA_DEPRN_PKG.insert_row (
                            x_rowid                    => l_rowid,
                            x_adjustment_id            => l_prev_adjustment_id,
                            x_asset_id                 => l_asset.asset_id,
                            x_distribution_id          => l_dist.distribution_id,
                            x_book_type_code           => p_book_type_code,
                            x_period_counter           => l_prev_adj_period,
                            x_deprn_period             => l_deprn_amount,
                            x_deprn_ytd                => l_deprn_ytd,
                            x_deprn_reserve            => l_deprn_reserve,
                            x_active_flag              => l_dist.active_flag,
                            x_mode                     => 'R' );
                        END IF;
                        CLOSE c_check_igi_fa_deprn;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End of Processing');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*************************');
        IF p_calling_mode = 'SRS' THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Called in SRS mode');
            IF l_debug_mode = 'Y' THEN
                ROLLBACK TO iac_pre_process;
            ELSE
                COMMIT;
            END IF;
        ELSE
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	Called in Non SRS mode');
            null;
        END IF;
	    errbuf := null;
	    retcode := 0;

    EXCEPTION WHEN OTHERS THEN
        IF p_calling_mode = 'SRS' THEN
		    ROLLBACK TO iac_pre_process;
        END IF;
	   	    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
		    errbuf := SQLERRM;
		    retcode := 2;

    END POPULATE_IAC_FA_DEPRN_DATA;

END IGI_IAC_YTD_PRE_PROCESS_PKG;

/
