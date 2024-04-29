--------------------------------------------------------
--  DDL for Package CST_SLA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_SLA_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTPUPGS.pls 120.2.12010000.2 2009/07/23 12:34:00 smsasidh ship $ */

------------------------------------------------------------------------------------
--  API name   : CST_Upgrade_Wrapper
--  Type       : Public
--  Function   : Wrapper to support XLA Concurrent mode Upgrade
--
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Num_Workers    in  number default 16,
--                     X_ledger_id      in  number default null,
--                     X_Application_Id in  number default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Version    : Initial version       1.0
--  Notes      : Wrapper to support XLA Concurrent mode Upgrade
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE CST_Upgrade_Wrapper (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  number default null,
               X_Application_Id in  number default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_MGR
--  Type       : Public
--  Function   : Manager process to launch three managers that "Upgrade Inventory Sub
--               Ledger to SLA data model", "Upgrade WIP Sub Ledger to SLA data
--               model", and "Upgrade Receiving Sub Ledger to SLA data model"
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Costing Subledgers to SLA"
--                    manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER DEFAULT 1.0,
               X_init_msg_list  IN  VARCHAR2 DEFAULT 'T',
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Argument4      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_INV_MGR
--  Type       : Public
--  Function   : Manager process to update Inventory Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Inventory Sub Ledger to SLA"
--                    manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_INV_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_WIP_MGR
--  Type       : Public
--  Function   : Manager process to update WIP Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade WIP Sub Ledger to SLA"
--                    manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_WIP_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_RCV_MGR
--  Type       : Public
--  Function   : Manager process to update Receiving Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Receiving Sub Ledger to SLA"
--                    manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_RCV_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_INV_WKR
--  Type       : Private
--  Function   : Worker process to update Inventory Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Inventory Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_INV_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstmtaupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_INV_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_WIP_WKR
--  Type       : Private
--  Function   : Worker process to update WIP Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade WIP Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_WIP_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstwtaupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_WIP_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_RCV_WKR
--  Type       : Private
--  Function   : Worker process to update RCV Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Receiving Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_RCV_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstrrsupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_RCV_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null);

-------------------------------------------------------------------------------------
--  API name   : Update_Inventory_Subledger
--  Type       : Private
--  Function   : To update Inventory Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_INV_WKR.
--
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Inventory_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number);

-------------------------------------------------------------------------------------
--  API name   : Update_WIP_Subledger
--  Type       : Private
--  Function   : To update WIP Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_WIP_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_WIP_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number);

-------------------------------------------------------------------------------------
--  API name   : Update_RCV_Subledger
--  Type       : Private
--  Function   : To update Receiving Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_RCV_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_Receiving_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number);


END;

/
