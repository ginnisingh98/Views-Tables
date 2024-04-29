--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BURDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BURDEN" as
/* $Header: PAXCCEBB.pls 120.1 2005/08/17 13:09:53 vgade noship $ */
  procedure Override_Rate_Rev_Id(
                           p_transaction_type      IN varchar2 DEFAULT 'ACTUAL',
                           p_tran_item_id          IN  number DEFAULT NULL,
                           p_tran_type             IN  Varchar2 DEFAULT NULL,
                           p_task_id         	   IN  number DEFAULT NULL,
                           p_schedule_type         IN  Varchar2 DEFAULT NULL,
                           p_exp_item_date         IN  Date DEFAULT NULL,
                           x_sch_fixed_date        OUT NOCOPY Date,
                           x_rate_sch_rev_id 	   OUT NOCOPY number,
                           x_status                OUT NOCOPY number ) is
   begin
           -- Add your logic to override rate_sch_rev_id
           /* Comments for bug fix 2563364 start */
           -- When this procedure is called from the transaction import process,
           -- p_tran_item_id has the value txn_interface_id from pa_transaction_interface_all
           -- table. In this case, p_tran_type will have the value 'TRANSACTION_IMPORT'.
           -- When this procedure is called by any other process,
           -- p_tran_item_id has the value expenditure_item_id and p_tran_type
           -- has the value 'PA'.
           /* Comments for bug fix 2563363 end */
           -- valid values for p_schedule_types are
           --    C  - Costing Schedule
           --    R  - Revenue Schedule
           --    I  - Invoice Schedule
           --
           -- This procedure will return rate_sch_rev_id and status
           -- All parameter names start with p_ will be input variables
           -- All parameter names start with x_ will be output variables
           --
           -- Note : rate_sch_rev_id and sch_fixed_date should be passed
           --        together (i.e. both variables has to NOT NULL or both has
           --        to be NULL)
           --
           -- Do not add 'commit' or 'rollback' in your code, since Oracle
           -- Project Accounting controls the transaction for you.
           --
           -- After the logic assign appropriate values for out variables
           --
           x_sch_fixed_date  := NULL;
           x_rate_sch_rev_id := NULL;
           x_status          := NULL;

   exception
	when others then
        -- Add your exception handler here.
        -- To raise an application error, assign a positive number to x_status.
        -- To raise an ORACLE error, assign SQLCODE to x_status.
        --
           x_sch_fixed_date  := NULL;
           x_rate_sch_rev_id := NULL;
           x_status          := NULL;

   end Override_Rate_Rev_Id;

end PA_CLIENT_EXTN_BURDEN ;

/
