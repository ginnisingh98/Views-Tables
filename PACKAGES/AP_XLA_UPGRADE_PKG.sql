--------------------------------------------------------
--  DDL for Package AP_XLA_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_XLA_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: apxlaups.pls 120.2.12010000.3 2009/08/16 06:45:23 njakkula ship $ */


PROCEDURE AP_XLA_UPGRADE_ONDEMAND
               (Errbuf            IN OUT NOCOPY VARCHAR2,
                Retcode           IN OUT NOCOPY VARCHAR2,
                P_Batch_Size      IN            VARCHAR2,
                P_Num_Workers     IN            NUMBER);


PROCEDURE AP_XLA_UPGRADE_SUBWORKER
               (Errbuf                  IN OUT NOCOPY VARCHAR2,
                Retcode                 IN OUT NOCOPY VARCHAR2,
                P_batch_size            IN            VARCHAR2,
                P_Worker_Id             IN            NUMBER,
                P_Num_Workers           IN            NUMBER,
                P_Inv_Script_Name       IN            VARCHAR2,
                P_Pay_Script_Name       IN            VARCHAR2);

--Start 8725986: Modified the parameters to rowid type
PROCEDURE Create_Invoice_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2);

PROCEDURE Create_Prepay_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2);

PROCEDURE Create_Payment_Dist_Links
                (p_start_rowid           rowid,
                 p_end_rowid             rowid,
                 p_calling_sequence   VARCHAR2);
--End 8725986: Modified the parameters to rowid type

PROCEDURE Create_Trial_Balance
                (p_ledger_id                 NUMBER,
                 p_mode                      VARCHAR2,
                 p_return_status  OUT NOCOPY VARCHAR2,
                 p_msg_count      OUT NOCOPY NUMBER,
                 p_msg_data       OUT NOCOPY VARCHAR2,
                 p_calling_sequence          VARCHAR2);


END AP_XLA_UPGRADE_PKG;

/
