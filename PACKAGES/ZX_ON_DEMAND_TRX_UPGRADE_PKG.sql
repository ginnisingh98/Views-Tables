--------------------------------------------------------
--  DDL for Package ZX_ON_DEMAND_TRX_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ON_DEMAND_TRX_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmigtrxdemdpkgs.pls 120.2.12010000.2 2009/08/11 14:55:59 tsen ship $ */

   PROCEDURE ZX_TRX_UPDATE_MGR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number,
                  p_application_id in fnd_application.application_id%type,
                  p_ledger_id      in xla_upgrade_dates.ledger_id%type,
                  p_period_name    in varchar2);

   PROCEDURE ZX_TRX_UPDATE_WKR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number,
                  p_application_id in fnd_application.application_id%type,
p_script_name in varchar2);

END;

/
