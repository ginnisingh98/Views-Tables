--------------------------------------------------------
--  DDL for Package CN_UPG_PMT_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UPG_PMT_REASONS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnvupnos.pls 120.3 2006/06/13 23:40:26 sbadami noship $

   PROCEDURE Notes_Mgr(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number);

   PROCEDURE Notes_Worker(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number);

END CN_UPG_PMT_REASONS_PKG;
 

/
