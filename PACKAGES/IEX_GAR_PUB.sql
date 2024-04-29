--------------------------------------------------------
--  DDL for Package IEX_GAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_GAR_PUB" AUTHID CURRENT_USER as
/* $Header: iextptws.pls 120.1.12010000.2 2009/07/31 09:40:41 pnaveenk ship $ */

/*-------------------------------------------------------------------------*
 |     HISTORY
 |       11/11/2003 SESUNDAR Fixed bug#3194696
 |       11/13/2003 MMUSUVAT Enh3100827, opp status param
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/
  g_debug_flag              VARCHAR2(1);

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/
PROCEDURE Generate_Access_Records(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_transaction_type IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    p_actual_workers  IN  VARCHAR2,
    p_prev_request_id IN  NUMBER,
    p_seq_num         IN  NUMBER,
    p_assign_level     IN VARCHAR2);  -- changed for bug 8708291 pnaveenk multi level strategy


END IEX_GAR_PUB;

/
