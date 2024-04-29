--------------------------------------------------------
--  DDL for Package Body FA_MC_UPG_CONVERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MC_UPG_CONVERT_PKG" AS
/* $Header: faxmcucb.pls 120.3.12010000.2 2009/07/19 10:09:49 glchen ship $  */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE main_convert(
                        errbuf                  OUT NOCOPY     VARCHAR2,
                        retcode                 OUT NOCOPY     NUMBER,
                        p_book_type_code        IN      VARCHAR2,
                        p_reporting_book        IN      VARCHAR2,
			p_fixed_conversion	IN	VARCHAR2) IS

	p_msg_count	NUMBER := 0;
	p_msg_data	VARCHAR2(512);

BEGIN
        fa_rx_conc_mesg_pkg.log('Converting Assets from ');
        fa_rx_conc_mesg_pkg.log('Primary Book: ' || p_book_type_code || ' TO');
        fa_rx_conc_mesg_pkg.log('Reporting Book: ' || p_reporting_book);


	-- Initialize server message stack
	FA_SRVR_MSG.Init_Server_Message;
	FA_DEBUG_PKG.Initialize;
	-- FA_DEBUG_PKG.Set_Debug_Flag;

	-- call routine to convert assets to reporting book
	fa_mc_upg1_pkg.convert_reporting_book(
				p_book_type_code,
				p_reporting_book,
				p_fixed_conversion);

        fa_srvr_msg.add_message(
                calling_fn => 'fa_mc_upg_select_pkg.main_convert',
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'FAMRCUPG2');

        -- Dump Debug messages when run in debug mode to log file
        IF (g_print_debug) THEN
            fa_mc_upg1_pkg.Write_DebugMsg_Log(
                                        p_msg_count);
        END IF;

	-- write messages to log file
        FND_MSG_PUB.Count_And_Get(
                p_count                => p_msg_count,
                p_data                 => p_msg_data);

        fa_mc_upg1_pkg.Write_ErrMsg_Log(p_msg_count);

	-- return success to concurrent manager
	retcode := 0;

EXCEPTION
	WHEN OTHERS THEN
                fa_srvr_msg.add_message(
                        calling_fn => 'fa_mc_upg_select_pkg.main_convert',
                        name       => 'FA_SHARED_END_WITH_ERROR',
                        token1     => 'PROGRAM',
                        value1     => 'FAMRCUPG2');

                IF (g_print_debug) THEN
                   fa_mc_upg1_pkg.Write_DebugMsg_Log(
                                        p_msg_count);
		END IF;

                FND_MSG_PUB.Count_And_Get(
                        p_count                => p_msg_count,
                        p_data                 => p_msg_data);

                fa_mc_upg1_pkg.Write_ErrMsg_Log(
                                        p_msg_count);

		-- return failure to concurrent manager
		retcode := 2;

END main_convert;

END FA_MC_UPG_CONVERT_PKG;

/
