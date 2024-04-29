--------------------------------------------------------
--  DDL for Package Body FA_MC_UPG_SELECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UPG_SELECT_PKG" AS
/* $Header: faxmcusb.pls 120.3.12010000.2 2009/07/19 10:12:27 glchen ship $  */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE main_select(
                        errbuf                  OUT NOCOPY     VARCHAR2,
                        retcode                 OUT NOCOPY     NUMBER,
			p_book_type_code 	IN	VARCHAR2,
			p_reporting_book	IN	VARCHAR2) IS

	X_start_pc		NUMBER;
	X_end_pc		NUMBER;
	X_conv_date		DATE;
	X_conv_type		VARCHAR2(30);
	X_accounting_date	DATE;
	l_rbook			VARCHAR2(30);
	l_fcurrency		VARCHAR2(15);
	l_tcurrency     	VARCHAR2(15);
	l_rsob_id		NUMBER;
	l_psob_id		NUMBER;
	l_denominator		NUMBER;
	l_numerator		NUMBER;
	l_rate			NUMBER;
	l_relation		VARCHAR2(30);
	l_fixed_rate		VARCHAR2(1);
	X_total_assets		NUMBER;
	p_msg_count		NUMBER := 0;
	p_msg_data		VARCHAR2(512);


BEGIN
	fa_rx_conc_mesg_pkg.log('Selecting Assets For Conversion from ');
	fa_rx_conc_mesg_pkg.log('Primary Book: ' || p_book_type_code || ' TO');
	fa_rx_conc_mesg_pkg.log('Reporting Book: ' || p_reporting_book);
	fa_rx_conc_mesg_pkg.log('-------------------------------------------');

	FA_SRVR_MSG.Init_Server_Message;
	FA_DEBUG_PKG.initialize;
	-- FA_DEBUG_PKG.Set_Debug_Flag;

  	fa_mc_upg1_pkg.validate_setup(
				p_book_type_code,
				p_reporting_book,
				l_fcurrency,
				l_tcurrency,
				l_rsob_id,
				l_psob_id);

	fa_mc_upg1_pkg.get_conversion_info(
				p_book_type_code,
				l_psob_id,
				l_rsob_id,
				X_start_pc,
				X_end_pc,
				X_conv_date,
				X_conv_type,
				X_accounting_date);

	fa_mc_upg1_pkg.get_rate_info(
                        	l_fcurrency,
                        	l_tcurrency,
                        	X_conv_date,
                        	X_conv_type,
                        	l_denominator,
                        	l_numerator,
                        	l_rate,
                        	l_relation,
				l_fixed_rate);

        fa_mc_upg1_pkg.set_conversion_status(
				p_book_type_code,
                                l_rsob_id,
				X_start_pc,
                                X_end_pc,
				NULL,
				'S');

	fa_mc_upg1_pkg.get_candidate_assets(
				p_book_type_code,
				l_rsob_id,
				X_start_pc,
				X_end_pc,
				l_rate,
				l_fixed_rate,
				X_total_assets);

        fa_srvr_msg.add_message(
                calling_fn => 'fa_mc_upg_select_pkg.main_select',
                name       => 'FA_SHARED_NUMBER_PROCESSED',
                token1     => 'NUMBER',
                value1     => to_char(X_total_assets));

        fa_srvr_msg.add_message(
		calling_fn => 'fa_mc_upg_select_pkg.main_select',
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'FAMRCUPG1');

        -- Dump debug messages when run in debug mode
        IF (g_print_debug) THEN
            fa_mc_upg1_pkg.Write_DebugMsg_Log(
                                        p_msg_count);
        END IF;


	-- write messages on message stack to log file
        FND_MSG_PUB.Count_And_Get(
                p_count                => p_msg_count,
                p_data                 => p_msg_data);

        fa_mc_upg1_pkg.Write_ErrMsg_Log(p_msg_count);

	-- pass success to concurrent manager
	retcode := 0;

EXCEPTION
	WHEN OTHERS THEN

		fa_srvr_msg.add_message(
			calling_fn => 'fa_mc_upg_select_pkg.main_select',
			name 	   => 'FA_SHARED_END_WITH_ERROR',
			token1	   => 'PROGRAM',
			value1     => 'FAMRCUPG1');

                IF (g_print_debug) THEN
                   fa_mc_upg1_pkg.Write_DebugMsg_Log(
                                        p_msg_count);
                END IF;

      		FND_MSG_PUB.Count_And_Get(
         		p_count                => p_msg_count,
         		p_data                 => p_msg_data);

		fa_mc_upg1_pkg.Write_ErrMsg_Log(
					p_msg_count);

		-- pass error to concurrent manager
		retcode := 2;

END main_select;

END FA_MC_UPG_SELECT_PKG;

/
