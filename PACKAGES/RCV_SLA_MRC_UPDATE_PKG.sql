--------------------------------------------------------
--  DDL for Package RCV_SLA_MRC_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SLA_MRC_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVPUMCS.pls 120.2 2006/04/23 23:59 bigoyal noship $ */

-------------------------------------------------------------------------------------
--  API name   : Update_Receiving_MRC_Subledger
--  Type       : Private
--  Function   : To update Receiving MRC Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_upg_batch_id     in number(15),
--                     X_je_category_name in varchar2(30)
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from CST_SLA_UPDATE_PKG.Update_RCV_Subledger
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Receiving_MRC_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_upg_batch_id      in number,
               X_je_category_name  in varchar2 default 'Receiving');

END RCV_SLA_MRC_UPDATE_PKG;

 

/
