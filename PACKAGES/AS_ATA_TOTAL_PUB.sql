--------------------------------------------------------
--  DDL for Package AS_ATA_TOTAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ATA_TOTAL_PUB" AUTHID CURRENT_USER as
/* $Header: asxtatas.pls 120.4 2005/08/21 21:05:57 appldev ship $ */

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
PROCEDURE Assign_Account_Terr_Accesses(
    ERRBUF             out NOCOPY VARCHAR2,
    RETCODE            out NOCOPY VARCHAR2,
    P_submit_acc_tap  IN  VARCHAR2,
    P_account_type     IN  VARCHAR2,
    P_addl_where       IN  VARCHAR2,
    P_perc_analyzed    IN  NUMBER,
    P_debug            IN  VARCHAR2,
    P_trace            IN  VARCHAR2
);

PROCEDURE Assign_Lead_Terr_Accesses(
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY VARCHAR2,
    P_submit_lead_tap  IN  VARCHAR2,
    P_lead_status       IN  VARCHAR2,
    P_addl_where        IN  VARCHAR2,
    P_perc_analyzed     IN  NUMBER,
    P_debug             IN  VARCHAR2,
    P_trace             IN  VARCHAR2
);

PROCEDURE Assign_Oppty_Terr_Accesses(
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY VARCHAR2,
    P_submit_Oppty_tap IN  VARCHAR2,
    P_oppty_status      IN  VARCHAR2,
    P_addl_where        IN  VARCHAR2,
    P_perc_analyzed     IN  NUMBER,
    P_debug             IN  VARCHAR2,
    P_trace             IN  VARCHAR2
);

PROCEDURE Assign_Quote_Terr_Accesses(
    ERRBUF			OUT NOCOPY VARCHAR2,
    RETCODE			OUT NOCOPY VARCHAR2,
    P_submit_Quote_tap		IN  VARCHAR2,
    P_exclude_ord_quote		IN  VARCHAR2,
    P_exclude_exp_quote		IN  VARCHAR2,
    P_addl_where		IN  VARCHAR2,
    P_perc_analyzed             IN  NUMBER,
    P_debug			IN  VARCHAR2,
    P_trace			IN  VARCHAR2
);
PROCEDURE Assign_Proposal_Terr_Accesses(
    ERRBUF             out NOCOPY VARCHAR2,
    RETCODE            out NOCOPY VARCHAR2,
    P_submit_prp_tap  IN  VARCHAR2,
    P_addl_where       IN  VARCHAR2,
    P_perc_analyzed    IN  NUMBER,
    P_debug            IN  VARCHAR2,
    P_trace            IN  VARCHAR2
);

PROCEDURE DELETE_CHANGED_ENTITY(
    p_entity           IN VARCHAR2,
    x_errbuf             OUT NOCOPY VARCHAR2,
    x_retcode	       OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2);

END AS_ATA_TOTAL_PUB;

 

/
