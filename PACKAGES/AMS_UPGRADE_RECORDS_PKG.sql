--------------------------------------------------------
--  DDL for Package AMS_UPGRADE_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_UPGRADE_RECORDS_PKG" AUTHID CURRENT_USER AS
-- $Header: amsvupds.pls 120.0 2006/06/29 06:16:55 batoleti noship $

   PROCEDURE AMS_UPG_METRIC_HST_RECS_MGR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number);

   PROCEDURE AMS_UPG_METRIC_HST_RECS_WKR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  l_batch_size  in number,
                  l_Worker_Id   in number,
                  l_Num_Workers in number);

END AMS_UPGRADE_RECORDS_PKG;

 

/
