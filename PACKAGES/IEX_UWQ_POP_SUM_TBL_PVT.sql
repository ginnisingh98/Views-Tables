--------------------------------------------------------
--  DDL for Package IEX_UWQ_POP_SUM_TBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_UWQ_POP_SUM_TBL_PVT" AUTHID CURRENT_USER as
/* $Header: iexvuwps.pls 120.0.12010000.7 2010/04/30 15:38:44 barathsr ship $ */


/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

PROCEDURE populate_uwq_sum_concur(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
		  --Begin Bug 8707932 27-Jul-2009 barathsr
		    p_ou_lvl_enb        in varchar2 default null,
		    p_org_id            in number,
                    p_truncate_table    in varchar2 default 'N');
		 --End Bug 8707932 27-Jul-2009 barathsr

PROCEDURE Insert_Summary(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
		     --Begin Bug 8707932 27-Jul-2009 barathsr
		    p_org_id in number,
		    p_level in varchar2,
		     --End Bug 8707932 27-Jul-2009 barathsr
		    P_MODE              IN  VARCHAR2 DEFAULT 'CP');
PROCEDURE refresh_summary_incr(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP');


--Begin Bug 9596144 28-Apr-2010 barathsr
Procedure update_trx_bal_summ_concur( x_errbuf            OUT nocopy VARCHAR2,
                                      x_retcode           OUT nocopy VARCHAR2);

--End Bug 9596144 28-Apr-2010 barathsr

procedure calculate_net_balance(p_fmode varchar2, p_from_date date,p_org_id number); --Added for Bug 8823567 22-Oct-2009 barathsr
locked_by_another_session   EXCEPTION ;
PRAGMA EXCEPTION_INIT(locked_by_another_session,-54) ;
deadlock_detected EXCEPTION;
PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
-- Start for the bug#7562130 by PNAVEENK
g_score_value number;
g_score_id number;
g_score_name varchar2(100);
g_object_type varchar2(100);
g_object_id number;
function cal_score(p_object_id number, p_object_type varchar2, p_select_column varchar2) return varchar2;
-- end for the bug#7562130
END;

/
