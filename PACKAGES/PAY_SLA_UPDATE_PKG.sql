--------------------------------------------------------
--  DDL for Package PAY_SLA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SLA_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: payxlaupg.pkh 120.0.12010000.1 2008/11/20 10:14:29 priupadh noship $ */

-------------------------------------------------------------------------------------
--  Name       : Update_Proc_MGR
--  Function   : This is the Manager Process called by Conc Program
--               Upgrade Historical Payroll Data to SLA.
-------------------------------------------------------------------------------------
PROCEDURE Update_Proc_PAY_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               P_LEDGER_ID      IN  VARCHAR2,
               P_START_PERIOD   IN  VARCHAR2,
               P_END_PERIOD     IN  VARCHAR2,
               P_DEBUG_FLAG     IN  VARCHAR2,
               X_batch_size     in  number default 1,
               X_Num_Workers    in  number default 5,
               X_Argument4      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null);

----------------------------------------------------------------------------------------
--  Name       : Update_Proc_PAY_WKR
--  Function   : Worker process to update Payroll Sub Ledger to SLA data model.
--               This is called by Manager Procewss Update_Proc_PAY_MGR

----------------------------------------------------------------------------------------
PROCEDURE Update_Proc_PAY_WKR (
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

----------------------------------------------------------------------------------------
--  Name       : GET_SEQUENCE_VALUE
--  Function   : TO get the sequence values for XLA Sequences .
----------------------------------------------------------------------------------------
FUNCTION GET_SEQUENCE_VALUE(p_row_number in number,p_tab_name varchar2)
RETURN number ;

----------------------------------------------------------------------------------------
--  Name       : GET_FULL_NAME
--  Function   : TO get the Full Name from Assignment_Action_Id
----------------------------------------------------------------------------------------

FUNCTION get_full_name(p_assignment_act_id in pay_assignment_actions.assignment_action_id%type,
                       p_eff_date in date)
RETURN varchar2;

-------------------------------------------------------------------------------------
--  Name       : Update_Payroll_Subledger
--  Type       : Private
--  Function   : To update Payroll Sub Ledger to SLA data model from Start ID
--               to End ID for Ledger (P_LEDGER_ID).
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_start_id     in  number
--                     X_end_id       in  number
--                     P_LEDGER_ID    in varchar2
--                     P_MGR_REQ_ID in varchar2
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The Procedure is called from Update_Proc_PAY_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_PAYROLL_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_start_id   in number,
               X_end_id     in number,
               P_LEDGER_ID  in varchar2,
               P_MGR_REQ_ID in varchar2,
               P_DEBUG_FLAG    in varchar2);


END;

/
