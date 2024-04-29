--------------------------------------------------------
--  DDL for Package Body XTR_SETTLEMENT_SUMMARY_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_SETTLEMENT_SUMMARY_P" AS
/* $Header: xtrsetlb.pls 120.0.12010000.2 2008/08/06 10:44:29 srsampat ship $  */
--Package that inserts and updates rows in the xtr_settlement_summary table.

/* table handler for Xtr_Settlement_Summary */

/**********************************************************************************/
/* This procedure serves for two purposes:                                        */
/* (1) when user authorizes a settlement, then corresponding record is entered in */
/* (2) For two or more settlements are netted, a new records  with netted amount  */
/*     is created in Xtr_Settlement_Summary                                       */
/**********************************************************************************/



Procedure INS_SETTLEMENT_SUMMARY(p_settlement_number IN Number,
                                 p_company IN VARCHAR2,
                                 p_currency IN VARCHAR2,
                                 p_settlement_amount IN Number,
                                 p_settlement_date IN Date,
                                 p_company_acct_no IN Varchar2,
                                 p_cparty_acct_no IN Varchar2,
                                 p_net_ID IN Number,
                                 p_status IN Varchar2,
                                 p_created_by IN Number,
                                 p_creation_date IN Date,
                                 p_external_source IN Varchar2,
                                 p_cparty_code IN Varchar2,       -- bug 3832387
                                 p_settlement_ID OUT  NOCOPY Number )

     Is
        v_settlement_ID Number;
        v_exists char(1);

Begin
        Begin
            Select 'Y', settlement_summary_id
            Into v_exists, v_settlement_id
            From Xtr_Settlement_Summary
            Where settlement_number = p_settlement_number;
        Exception
            When no_data_found then
            v_exists := 'N';
        End;
        If v_exists = 'N' then
           Select Xtr_Settlement_Summary_S.Nextval
           Into v_settlement_ID
           From Dual;

           Insert into Xtr_Settlement_Summary(Settlement_Summary_Id, Settlement_Number, Company, Currency,
           Settlement_Amount, Settlement_Date, Company_Acct_No, Cparty_Acct_No, Net_ID, Status,
           Created_By, Creation_Date, Last_Updated_By, Last_Update_Date, Last_Update_Login, cparty_code,
           external_source)
           Values(v_settlement_ID, p_settlement_number, p_company, p_currency, p_settlement_amount,
           p_settlement_date, p_company_acct_no, p_cparty_acct_no, p_net_ID, p_status,
           p_created_by, p_creation_date, p_created_by,
p_creation_date,null,p_cparty_code,p_external_source);  -- bug 3832387

           p_settlement_ID := v_settlement_ID;
        Else
           Update Xtr_Settlement_Summary
           set settlement_date = p_settlement_date,
            cparty_code = p_cparty_code                  -- bug 3832387
           Where settlement_number = p_settlement_number;

           p_settlement_ID := v_settlement_ID;
        End if;
     End INS_Settlement_Summary;

/******************************************************************************/
/* This procedure handles the situation that 2 or more settlements are netted,*/
/* the corresponding entries in Xtr_Settlement_Summary are set UNAVAILABLE for*/
/*  CE Reconciliation (status set to 'I' for original entries)                */
/******************************************************************************/
Procedure UPD_SETTLEMENT_SUMMARY(p_flag IN Char, p_netoff_number in number, p_settlement_ID IN Number)
     Is
        Cursor C1 is
        Select settlement_number, deal_number, transaction_number
        From Xtr_Deal_Date_Amounts
        Where netoff_number = p_netoff_number;

     Begin
              For C1_Rec in C1
              Loop
                 Update Xtr_Settlement_Summary  -- bug 3076732
                 Set status = 'I',
                 net_ID = p_settlement_ID
                 Where (settlement_number = C1_Rec.SETTLEMENT_number) or
		       (settlement_summary_id in (select net_id
				from XTR_SETTLEMENT_SUMMARY
				where settlement_number = C1_REC.settlement_number));

              End Loop;

     End UPD_Settlement_Summary;

/******************************************************************************/
/* This procedure handles the situation when a netted group is created,       */
/* and a new netted transaction is added. In this case, the new added entries */
/* in Xtr_Settlement_Summary is set UNAVAILABLE for CE Reconciliation (status */
/*  set to 'I' for original entries). Also update the existing netted         */
/*  trnasaction with new netted amount.                                       */
/******************************************************************************/
Procedure UPD_Settlement_Summary(p_flag IN Char, p_netoff_number IN Number, p_settlement_ID IN Number, p_amount IN Number)
     Is
        Cursor C1 is
        Select settlement_number, deal_number, transaction_number
        From Xtr_Deal_Date_Amounts
        Where netoff_number = p_netoff_number;
 Begin

    For C1_Rec in C1 Loop
	Delete from XTR_SETTLEMENT_SUMMARY
	where settlement_summary_id in (select net_id
				from XTR_SETTLEMENT_SUMMARY
				where settlement_number = C1_rec.SETTLEMENT_NUMBER)
        and settlement_summary_id <> p_settlement_id;

         Update Xtr_Settlement_Summary
         Set status = 'I',
         net_ID = p_settlement_ID
         Where settlement_number = C1_Rec.SETTLEMENT_number;

    End Loop;

    Update Xtr_Settlement_Summary
    Set settlement_amount =  nvl(p_amount, 0)
    Where Settlement_Summary_ID = p_settlement_ID;

End UPD_Settlement_Summary;

/******************************************************************************/
/* This procedure handles the situation when user undo partial netted         */
/* settlement, the unnetted transaction in Xtr_Settlement_Summary is made     */
/* AVAILABLE for CE Reconciliation( status back to 'A'). The original netted  */
/* transaction need to be updated with the new netted amount                  */
/******************************************************************************/
Procedure UPD_Settlement_Summary(p_settlement_number IN Number, p_amount IN Number)
     Is
          v_net_ID Xtr_Settlement_Summary.net_ID%Type;
          v_no_of_netted_recs number;
     Begin
          Select net_ID
          Into v_net_ID
          From Xtr_Settlement_Summary
          Where settlement_number = p_settlement_number;

          Update Xtr_Settlement_Summary
          Set status = 'A',
          net_ID = null
          Where settlement_number = p_settlement_number;

          Select count(*)
          Into v_no_of_netted_recs
          From Xtr_Settlement_Summary
          Where net_ID = v_net_ID;

          If v_no_of_netted_recs <> 0 then
             Update Xtr_Settlement_Summary
             Set settlement_amount = nvl(settlement_amount, 0) - nvl(p_amount,0)
             Where settlement_summary_ID = v_net_ID;

          Else
             Delete From Xtr_Settlement_Summary
             Where settlement_Summary_ID = v_net_ID;
          End if;

     End UPD_Settlement_Summary;

/******************************************************************************/
/* This procedure handles the situation when user want to unnet settlements   */
/* totally (i.e., change radio button back to 'None', the netted transaction  */
/* in Xtr_Settlement_Summary should be deleted. Also update the status to 'A' */
/* for original entries.                                                      */
/******************************************************************************/

Procedure DEL_SETTLEMENT_SUMMARY(p_settle_date IN Date,
                                 p_currency IN Varchar2,
                                 p_acct_no IN Varchar2,
                                 p_cpacct_no IN Varchar2,
                                 p_company_code IN Varchar2,
                                 p_flag IN Char,
                                 p_return OUT  NOCOPY Char)
     Is
       v_net_ID Number;
       v_first_record Char(1) ;
       v_del_resultant Char(1);
       v_upd_single Char(1);

       Cursor C2 is
       Select settlement_number
       From Xtr_Deal_Date_Amounts
       where ACTUAL_SETTLEMENT_DATE = p_settle_DATE
       and CASHFLOW_AMOUNT <> 0
       and CURRENCY = p_CURRENCY
       and ACCOUNT_NO = p_ACCT_NO
       and nvl(BENEFICIARY_ACCOUNT_NO,CPARTY_ACCOUNT_NO) = nvl(p_CPACCT_NO,NULL)
       and COMPANY_CODE = p_COMPANY_CODE
       and SETTLEMENT_ACTIONED is NULL
       and RECONCILED_PASS_CODE is NULL
       and RECONCILED_REFERENCE is NULL
       and NETOFF_NUMBER is NULL   -- jhung
       and AMOUNT_TYPE <> 'FXOBUY'
       and AMOUNT_TYPE <> 'FXOSELL'
/********* code below modified by Ilavenil for 2344133 ********/
       and (nvl(EXP_SETTLE_REQD, 'Y') = 'Y' or DEAL_TYPE <> 'EXP')
/*********/
       and nvl(MULTIPLE_SETTLEMENTS, 'N') = 'N'
       and DEAL_SUBTYPE <> 'INDIC'
       and DEAL_TYPE  <> 'CA';

 Begin
    p_return := 'Y';
    v_first_record  := 'Y';
    v_del_resultant := 'N';
    v_upd_single := 'N';

   For C2_Rec in C2  Loop
                 -- If v_first_record = 'Y' then  -- jhung
       Select net_ID
       Into v_net_ID
       From Xtr_Settlement_Summary
       Where Settlement_Number = C2_Rec.Settlement_Number;

       Delete from Xtr_Settlement_Summary
       Where Settlement_Summary_ID = v_net_ID;
       If SQL%FOUND then
/* resultant record has been deleted */
          v_del_resultant := 'Y';
       End if;

       v_first_record := 'N';

       Update Xtr_Settlement_Summary
       Set Status = 'A',
       Net_ID = null
       Where Settlement_Number = C2_Rec.Settlement_Number;
       If SQL%FOUND then
/* individual records contributing the resultant figure are updated as AVAILABLE */
           v_upd_single := 'Y';
       End if;

       End Loop;

      If v_del_resultant = 'N' and v_upd_single = 'N' then
/* reconciled grouped settlement cannot be unnetted.  user has to unreconcile first and then proceed */
         p_return := 'N';
         -- DISP_ERR('XTR_CANNOT_UNNET_RECONCILED');
         --           Raise Form_Trigger_Failure;
      End if;

End DEL_Settlement_Summary ;

/******************************************************************************/
/* This procedure handles the situation when user unauthorize the Settlements,*/
/* the corresponding entry in Xtr_Settlement_Summary has to be removed.       */
/* Before removing we are to check whether the settlement  was involved in    */
/* netting.  If so, then resultant record needs to be modified accordingly    */
/******************************************************************************/
Procedure DEL_SETTLEMENT_SUMMARY(p_settlement_number IN Number,
                                 p_settlement_amount IN Number) is
        v_net_ID Xtr_Settlement_Summary.Net_ID%Type;
        v_no_of_netted_recs number;
 Begin
        Begin
          Select net_ID
          Into v_net_ID
          From Xtr_Settlement_Summary
          Where settlement_number = p_settlement_number;
        Exception
          When no_data_found then
          null;
        End;

/* if the un-authorized settlement is involved in netting, then */
        If v_net_Id is not null then
/* remove the un-authorized settlement, update resultant record for the amount */

           Delete From Xtr_Settlement_Summary
           Where settlement_number = p_settlement_number;

           Select count(*)
           Into v_no_of_netted_Recs
           From Xtr_Settlement_Summary
           Where net_ID = v_net_ID;

           If v_no_of_netted_recs <> 0 then
              Update Xtr_Settlement_summary
              Set settlement_amount = nvl(settlement_amount, 0) - nvl(p_settlement_amount, 0)
              Where settlement_summary_ID = v_net_ID;

           Else
              Delete From Xtr_Settlement_Summary
              Where settlement_summary_ID = v_net_ID;
           End if;
        Else
/* if un-authorized settlement is not involved in netting, then */
           Delete from Xtr_Settlement_Summary
           Where Settlement_Number = p_settlement_number;
           If SQL%NOTFOUND then
              null;
           End if;

        End if;
    End DEL_Settlement_Summary;

Procedure Include_Settlement_Group(p_settlement_number IN Number,
                                   p_netoff_number IN Number,
                                   p_company IN Varchar2,
                                   p_currency IN Varchar2,
                                   p_settlement_amount IN Number,
                                   p_settlement_date IN Date,
                                   p_company_acct_no IN Varchar2,
                                   p_cparty_acct_no IN Varchar2,
                                   p_created_by IN Number,
                                   p_creation_date IN Date,
                                   p_cparty_code IN Varchar2) -- bug 3832387
    Is
         v_exists Char(1);
         v_settlement_number number;
         v_net_ID number;
         v_settlement_ID Number;
    Begin
/* say for example user included a particular settlement and a particular group.  then user changes mind and
   wants to exclude the settlement from the group.  again the user changes mind and wants to include
   the settlement under the same group */
         Begin
           Select 'Y'
           Into v_exists
           From Xtr_Settlement_Summary
           Where settlement_number = p_settlement_number;
         Exception
           when no_data_found then
           v_exists := 'N';
         End;

         Select settlement_number
         Into v_settlement_number
         From Xtr_Deal_Date_Amounts
         Where netoff_number = p_netoff_number
         And rownum < 2;

         Select net_ID
         Into v_net_ID
         From Xtr_Settlement_Summary
         Where settlement_number = v_settlement_number;

         If v_exists = 'Y' then
             Update Xtr_Settlement_Summary
             Set status = 'I',
                 net_ID = v_net_ID
             Where settlement_number = p_settlement_number;
         Else
             Select Xtr_Settlement_Summary_S.Nextval
             Into v_settlement_ID
             From Dual;

             Insert into Xtr_Settlement_Summary(Settlement_Summary_Id, Settlement_Number, Company, Currency,
             Settlement_Amount, Settlement_Date, Company_Acct_No, Cparty_Acct_No, Net_ID, Status,
             Created_By, Creation_Date, Last_Updated_By, Last_Update_Date, Last_Update_Login, cparty_code)
             Values(v_settlement_ID, p_settlement_number, p_company, p_currency, p_settlement_amount,
             p_settlement_date, p_company_acct_no, p_cparty_acct_no, v_net_ID, 'I',
             p_created_by, p_creation_date, p_created_by, p_creation_date,null,p_cparty_code); -- bug 3832387
         End if;

         Update Xtr_Settlement_Summary
         Set settlement_amount = nvl(settlement_amount, 0) + nvl(p_settlement_amount, 0)
         Where settlement_summary_ID = v_net_ID;

    End Include_Settlement_Group;


END XTR_SETTLEMENT_SUMMARY_P;

/
