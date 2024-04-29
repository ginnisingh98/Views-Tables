--------------------------------------------------------
--  DDL for Package CN_UPG_PMT_TRXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UPG_PMT_TRXNS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnvuptrxs.pls 120.4 2006/07/28 14:43:29 fmburu noship $

   PROCEDURE CommLines_Upgrade_Mgr (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number) ;

   PROCEDURE Update_Commlines_WRK (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number) ;

   PROCEDURE PmtTrxns_Upgrade_Mgr (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number) ;

   PROCEDURE Update_Pmt_Trxns_WRK (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number) ;

END CN_UPG_PMT_TRXNS_PKG;
 

/
