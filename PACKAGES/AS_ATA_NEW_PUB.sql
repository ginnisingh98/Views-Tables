--------------------------------------------------------
--  DDL for Package AS_ATA_NEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ATA_NEW_PUB" AUTHID CURRENT_USER as
/* $Header: asxnatas.pls 120.1 2005/08/21 08:48 subabu noship $ */

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
PROCEDURE Assign_Territory_Accesses(
    ERRBUF		   out NOCOPY VARCHAR2,
    RETCODE		   out NOCOPY VARCHAR2,
    P_account_type	   IN  VARCHAR2,
    P_acc_addl_where	   IN  VARCHAR2,
    P_lead_status	   IN  VARCHAR2,
    P_lead_addl_where	   IN  VARCHAR2,
    P_opp_status	   IN  VARCHAR2,
    P_opp_addl_where	   IN  VARCHAR2,
    P_qt_excl_order	   IN  VARCHAR2,
    P_qt_excl_exp_qt	   IN  VARCHAR2,
    P_qt_addl_where	   IN  VARCHAR2,
    P_pr_addl_where	   IN  VARCHAR2,
    P_perc_analyzed        IN  NUMBER,
    P_debug                IN  VARCHAR2,
    P_trace                IN  VARCHAR2
);
END AS_ATA_NEW_PUB;

 

/
