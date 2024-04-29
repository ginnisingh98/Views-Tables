--------------------------------------------------------
--  DDL for Package Body JAI_OM_RG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_RG_PKG" AS
/* $Header: jai_om_rg.plb 120.20.12010000.11 2010/04/28 12:25:30 vkaranam ship $ */


/*----------------------------------------------------------------------------------------
Filename:

Change History:

Date         Remarks
---------    -------------------------------------------------------------
08-Jun-2005  File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
             as required for CASE COMPLAINCE.

13-Jun-2005  Ramananda for bug#4428980. File Version: 116.3
             Removal of SQL LITERALs is done

06-Jul-2005  Ramananda for bug#4477004. File Version: 116.4
             GL Sources and GL Categories got changed. Refer bug for the details

14-Jul-2005  rchandan for bug#4487676. File Version 117.2
             Sequence JAI_CMN_RG_23AC_I_TXNS_S is replaced by JAI_CMN_RG_23AC_I_TRXS_S

28/07/2005   Changes in JA_IN_ACCOUNTING_ENTRIES Procedure
             Ramananda for Bug#4516577, Version 120.2

                 Problem
                 -------
                 ISO Accounting Entries from Trading to Excise bonded inventory are not generated in case of following Scenarios
                 1. Trading organization to Trading Organization (only  Source organizations with the 'Excise in RG23D' setup).
                 2. Trading organization to Manufacturing Organization (Source Organization with the 'Excise in RG23D' setup).

                 Fix
                 ---
                 1. In the procedure - ja_in_accounting_entries, made the following changes
                   a. Modified the IF condition -
                      "IF NVL(p_non_iso_credit_account_id,0) >0 AND NVL(p_non_iso_debit_account_id,0) >0 AND
                        NOT
                        (
                         (
                         NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y'
                         )
                         AND
                        (
                         NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'
                        )
                      )"
                     TO
                      "IF NVL(p_non_iso_credit_account_id,0) >0 AND NVL(p_non_iso_debit_account_id,0) >0 AND
                          NOT
                              (
                                    NVL(lv_source_trading,'N') = 'Y'
                                AND ( NVL(lv_dest_trading,'N') =  'Y' OR NVL(lv_dest_manufacturing,'N') =  'Y')
                                AND NVL(ln_src_excise_in_rg23d,'N') = 'Y'

                              )"

                   b. Replaced the IF condition
                      "IF  NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y' THEN
                        IF NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'"
                      By
                      "IF NVL(lv_source_trading,'N') = 'Y'
                         AND ( NVL(lv_dest_trading,'N') =  'Y' OR NVL(lv_dest_manufacturing,'N') =  'Y')
                         AND NVL(ln_src_excise_in_rg23d,'N') = 'Y'"

                2. In the Procedure Ja_In_Rg23d_Entry, Changed the IF Condition -
                   IF  v_order_source_id = 10 AND
                      (
                        (
                           NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y'
                        )
                        AND
                        (
                          NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'
                        )
                      )
                   TO
                   IF  v_order_source_id = 10 AND
                     (
                       NVL(lv_source_trading,'N') = 'Y'
                      AND ( NVL(lv_dest_trading,'N') =  'Y' OR NVL(lv_dest_manufacturing,'N') =  'Y')
                       AND NVL(ln_src_excise_in_rg23d,'N') = 'Y'
                      )

                 3. In the Procedure ja_in_register_txn_entry, in the cursor - c_get_om_cess_amount,
                    Added the NVL for column sum(jsptl.func_tax_amount) in the Select

                 (Functional) Dependency Due to This Bug
                 --------------------------
                 jai_rcv_rcv_rtv.plb (120.3)
                 jai_rcv_trx_prc.plb (120.2)


19-aUG-2005    Bug4562791. Added by Lakshmi Gopalsami Version 120.3
               Added gl_accounting_date as a package variable.
              Passing this variable insted of NULL for gl accounting date.

            Dependencies(Functional nd Technical)
            ------------
            jai_om_rg.pls  120.2
            jai_om_wsh.plb 120.3

02-DEC-2005 Bug 4765347, Added by aiyer for Version 120.4
            Added few more fnd_file statements.

            Dependencies Due to this issue :-
             Yes, please refer the future dependencies section.



30-OCT-2006   SACSETHI for bug 5228046, File version 120.9
              Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
              This bug has datamodel and spec changes.

26-FEB-2007   SSAWANT , File version 120.11
	      Forward porting the change in 11.5 bug 4714518 to R12 bug no 4724137

27.  16/04/2007	  bduvarag for the Bug#5989740, file version 120.12
		  Forward porting the changes done in 11i bug#5907436

28.  04/06/2007  sacsethi for bug 6109941  , File version 120.13

		 1. Cursor c_get_ar_cess_rate  is removed for bug 5228046 forward porting bug
		 2. in procedure ja_in_pla_entry , sh_cess_amoumnt was missing

29  17/06/2007   ssumaith - bug# 6131804 - bond register is not gettnig hit in INR for foreign currency trxs.
                 Code changes are done in this package for handling the cess amount.

30. 28/06/2007   CSahoo -  BUG#6155839, File Version 120.16
								 replaced RG Register Data Entry by jai_constants.je_category_rg_entry
31. 02/07/2007   vkaranam -  BUG#6159579, File Version 120.17
		 1.In Procedure ja_in_cess_entries while calling ja_in_om_cess_register_entries p_delivery_detail_id parameter is not passed.

32. 05/07/2007   kunkumar for Bug#5745729 file version 120.18
                 Modified the cursors in the procedure ja_in_om_cess_register_entries so as to be in sync with the latest
		 version in R11i.Also there are changes to the body of the procedure.


33. 04/12/2007   ssumaith - bug# 6650203 - file version 120.8.12000000.4

                 Issue :

                   When the excise invoice number is having characters in it,the bond register transaction is failing as
                   the excise invoice number was being inserted into the picking_header_id field in the  JAI_OM_OE_BOND_TRXS table.
                   the picking header id field was of type number and hence a character insert is causing an invalid number error.

                   Fix :

                   Made the following changes
                     a) in the jai_om_rg_pkg, when the insert into the JAI_OM_OE_BOND_TRXS table happens through the ja_in_register_txn_entry procedure , insert of excise invoice number into picking header id has been removed.
                        Instead the picking_line_id is stamped with the delivery_id / customer_trx_line_id in case of OM / AR respectively.

34. 14-May-2008   Changes by nprashar for bug # 6710747.
                 Issue:INTER-ORGANIZATION TRANSFER WITH EXCISE TAXES FAILS
		   Reason:
		p_header_id parameter is used to insert the excise_invoice_id value of ja_in_rg23_part_i table.
		if excise_invoice_no  generated contains characters then while calling ja_in_rg23_part_i procedure ,the calling prg
		errors out.
		Fix:
		Changed the ja_in_rg23_part_i entry procedure p_header_id parameter to varchar2 type.

35  23-Jun-2008	Changed by JMEENA for bug#7172215
			1. Added condition IF NVL(ln_Cess_amount,0) > 0 before calling  ja_in_cess_acctg_entries in the procedure ja_in_cess_register_entries.
			2. Added log messages before RAISE_APPLICATION_ERROR to print in the log file.

36. 01-Aug-2008 Changed by JMEENA for bug#7277543
			Added log messages to print in log file for missing accounts setup informations.
37 13-oct-2008  bug#7479016
                Forward ported the changes done in 5597403
		File Version : 120.8.12000000.8/120.24

38  01-Jun-2009   Bug 8537295 File version 120.8.12000000.9 / 120.25
                  Issue - Accounting entries for cess / sh cess taxes are not rounded for Internal Sales Orders
		  Fix - Changed the value of v_precision variable in JA_IN_CESS_ENTRIES procedure from the
		        currency setup value to zero.

39.  31-mar-2010 vkaranam for bug#9539924
                 Issue:
                 Cess/Shcess amounts in RG register are not rounded to nearest rupee for Manual AR invoice.
                 Fix:
                 Changes are done in ja_in_Ar_cess_Register_entries procedure.
                 added round to func_tax_amount in c_tax_type_rec cursor.

26  05-Apr-2010 Bug 9550254
 	            The opening balance for the RG23 Part I and RG I has been derived from the previous
                financial year closing balance, if no entries found for the current year.
27-apr-2010 bug#9466919
                 issue :quantity in rg registers are not in sync with the inventory.
                 fix:
                 added the rounding precision of 5 to the quantity fields while inserting.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                        Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
jai_om_rg_pkg.plb
----------------------------------------------------------------------------------------------------------------------------------------------------
120.4                 4765347                           JAIITMCL.fmb                                  120.9    Aiyer     02-DEC-2005
                                                        jai_om_wsh.plb                                120.5    Aiyer     02-DEC-2005
---------------------------------------------------------------------------------------------------------------------------------------------------- */

-- start additions by ssumaith - bug#3817625





/***************************** START JA_IN_CESS_ENTRIES *******************************************************************/

Procedure JA_IN_CESS_ENTRIES
(
p_organization_id     number             ,
p_location_id         number             ,
p_delivery_detail_id  number             ,
p_intransit_inv_acct  number             ,
p_intercompany_rcvbl  number             ,
p_intercompany_paybl  number             ,
p_fob_point           number             ,
p_currency_code       varchar2           ,
p_source_name         varchar2           ,
p_category_name       varchar2           ,
p_created_by          Number             ,
P_REF_10              varchar2           ,
P_REF_23              varchar2           ,
P_REF_24              varchar2           ,
P_REF_25              varchar2           ,
P_REF_26              varchar2
)
IS

 -- A/c Entries for CESS needs to be passed as follows:

 -- Dr  Intransit Material Value
 -- Cr  CESS Payable Paid
 -- It will be called from ja_in_pla_entry and ja_in_rg23_part_ii_entry because only they have the
 -- amount impact for excise registers

 --If the FOB point is set to SHIPMENT, the following entry also needs to be passed :

 --  Intercompany Receivable       Cess amt
 --  Intercompany Payables                   cess amt

cursor c_delivery_cur(cp_delivery_Detail_id number) is
select delivery_id , org_id
from   JAI_OM_WSH_LINES_ALL
where  delivery_detail_id = cp_delivery_Detail_id;

cursor c_cess_amount(cp_delivery_id number) is
select sum(a.tax_amount)
from   JAI_OM_WSH_LINE_TAXES a, JAI_CMN_TAXES_ALL b
where  delivery_detail_id in
(select delivery_detail_id
 from   JAI_OM_WSH_LINES_ALL
 where  delivery_id = cp_delivery_id
)
 and    a.tax_id = b.tax_id
 and    upper(b.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS);


 /*Bug 5989740 bduvarag start*/
 cursor c_sh_cess_amount(cp_delivery_id number) is
select sum(a.tax_amount)
from   JAI_OM_WSH_LINE_TAXES a, JAI_CMN_TAXES_ALL b
where  delivery_detail_id in
(select delivery_detail_id
 from   JAI_OM_WSH_LINES_ALL
 where  delivery_id = cp_delivery_id
)
 and    a.tax_id = b.tax_id
 and    upper(b.tax_type) in (JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS,JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS);

/*Bug 5989740 bduvarag end*/
cursor c_fetch_cess_account(cp_organization_id number , cp_location_id number) is
select cess_paid_payable_account_id
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = cp_organization_id
and    location_id = cp_location_id;
/*Bug 5989740 bduvarag start*/
cursor c_fetch_sh_cess_account(cp_organization_id number , cp_location_id number) is
select sh_cess_paid_payable_acct_id
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = cp_organization_id
and    location_id = cp_location_id;
/*Bug 5989740 bduvarag end*/

/* Bug 5243532. Added by Lakshmi Gopalsami
   Removed the cursors c_get_sob_currency and currency
   c_currency_precision and implemented the same using caching logic.
*/
l_func_curr_det jai_plsql_cache_pkg.func_curr_details;


v_precision            fnd_currencies.precision%type;
v_currency_code        GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE      ;
v_delivery_id          JAI_OM_WSH_LINES_ALL.delivery_id%type;
v_cess_amount          number;
v_sh_cess_amount          number;/*Bug 5989740 bduvarag*/
v_cess_paid_payable    JAI_CMN_INVENTORY_ORGS.cess_paid_payable_account_id%type;
v_org_id               JAI_OM_WSH_LINES_ALL.org_id%type;
ln_sh_Cess_paid_payable  JAI_CMN_INVENTORY_ORGS.cess_paid_payable_account_id%type;/*Bug 5989740 bduvarag*/
lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_cess_entries';

/*
 The procedure assumes that it will be called from the ja_in_accounting_entries procedure only when
it is an ISO order ie the comparison is to be done in ja_in_accounting _entries_procedure
on p_source_name = 'Register India', p_category_name= 'Register India' and order_type_id = 10
So no further check is done here for the same.
*/
begin

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' start of   JA_IN_CESS_ENTRIES with p_delivery_detail_id = ' || p_delivery_detail_id);

   v_Delivery_id :=0;
   open  c_delivery_cur(p_delivery_detail_id);
   fetch c_delivery_cur into v_Delivery_id, v_org_id;
   close c_delivery_cur;

   Fnd_File.PUT_LINE(Fnd_File.LOG,  'v_Delivery_id =, Org id =  ' || v_Delivery_id || ' : ' || v_org_id);

   if v_delivery_id > 0 then

     open  c_cess_amount(v_Delivery_id);
     fetch c_cess_amount into v_cess_amount;
     close c_cess_amount;
/*Bug 5989740 bduvarag*/
     open  c_sh_cess_amount(v_Delivery_id);
     fetch c_sh_cess_amount into v_sh_cess_amount;
     close c_sh_cess_amount;

     open  c_fetch_cess_account( p_organization_id , p_location_id);
     fetch c_fetch_cess_account into v_cess_paid_payable;
     close c_fetch_cess_account ;
/*Bug 5989740 bduvarag*/
     open  c_fetch_sh_cess_account( p_organization_id , p_location_id);
     fetch c_fetch_sh_cess_account into ln_sh_Cess_paid_payable;
     close c_fetch_sh_cess_account ;

     /* Bug 5243532. Added by Lakshmi Gopalsami
        Removed the reference to cursors c_get_sob_currency
	and implemented using caching logic.
      */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_org_id );
     v_currency_code  := l_func_curr_det.currency_code;
     --v_precision      := l_func_curr_det.precision;
     v_precision := 0;   /*bug 8537295 - for excise invoice, amount should be rounded to nearest rupee*/

     Fnd_File.PUT_LINE(Fnd_File.LOG,  'v_currency_code =, v_precision =  , v_cess_paid_payable =' || v_currency_code || ' : ' || v_precision || ' : ' || v_cess_paid_payable );

     if v_precision is null then
        v_precision :=0;
     end if;

     v_cess_amount := round(v_cess_amount,v_precision);
     v_sh_cess_amount := round(v_sh_cess_amount,v_precision);/*Bug 5989740 bduvarag*/

     Fnd_File.PUT_LINE(Fnd_File.LOG,  'v_cess_amount = ' || v_cess_amount);

     if v_cess_amount > 0 then

       -- Dr  Intransit Material Value
             Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling gl_interface for CESS ');

            jai_cmn_gl_pkg.create_gl_entry
           (p_organization_id,
            p_currency_code,
            0,--Credit
            v_cess_amount, --Debit
            p_intransit_inv_acct,
            p_source_name,
            p_category_name,
            p_created_by,
      /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
            gl_accounting_date ,
            NULL,
            NULL,
            NULL,
            P_REF_10,
            P_REF_23,
            P_REF_24,
            P_REF_25,
            P_REF_26);

       -- Cr  CESS Payable Paid

            jai_cmn_gl_pkg.create_gl_entry
           (p_organization_id,
            p_currency_code,
            v_cess_amount,--Credit
            0,  --Debit
            v_cess_paid_payable,
            p_source_name,
            p_category_name,
            p_created_by,
            /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
            gl_accounting_date ,
            NULL,
            NULL,
            NULL,
            P_REF_10,
            P_REF_23,
            P_REF_24,
            P_REF_25,
            P_REF_26);

            if p_fob_point =1 then -- fobpoint =(shipment)


                -- Dr  Intercompany Receivable
                Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling gl_interface for CESS ');

                jai_cmn_gl_pkg.create_gl_entry
               (p_organization_id,
                p_currency_code,
                0,--Credit
                v_cess_amount, --Debit
                p_intercompany_rcvbl ,
                p_source_name,
                p_category_name,
                p_created_by,
                /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
                gl_accounting_date ,
                NULL,
                NULL,
                NULL,
                P_REF_10,
                P_REF_23,
                P_REF_24,
                P_REF_25,
                P_REF_26
                );

               -- Cr  Intercompany Payables

               jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id,
               p_currency_code,
               v_cess_amount,--Credit
               0,  --Debit
               p_intercompany_paybl,
               p_source_name,
               p_category_name,
               p_created_by,
               /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
               gl_accounting_date ,
               NULL,
               NULL,
               NULL,
               P_REF_10,
               P_REF_23,
               P_REF_24,
               P_REF_25,
               P_REF_26
               );

            end if;
     end if;
     /*Bug 5989740 bduvarag start*/
 if v_sh_cess_amount > 0 then
            jai_cmn_gl_pkg.create_gl_entry
           (p_organization_id,
            p_currency_code,
            0,--Credit
            v_sh_cess_amount, --Debit
            p_intransit_inv_acct,
            p_source_name,
            p_category_name,
            p_created_by,
            gl_accounting_date,
            NULL,
            NULL,
            NULL,
            P_REF_10,
            P_REF_23,
            P_REF_24,
            P_REF_25,
            P_REF_26);

       -- Cr  CESS Payable Paid

            jai_cmn_gl_pkg.create_gl_entry
           (p_organization_id,
            p_currency_code,
            v_sh_cess_amount,--Credit
            0,  --Debit
            ln_sh_Cess_paid_payable ,
            p_source_name,
            p_category_name,
            p_created_by,
            gl_accounting_date,
            NULL,
            NULL,
            NULL,
            P_REF_10,
            P_REF_23,
            P_REF_24,
            P_REF_25,
            P_REF_26);

            if p_fob_point =1 then -- fobpoint =(shipment)


                -- Dr  Intercompany Receivable
                Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling gl_interface for CESS ');

                jai_cmn_gl_pkg.create_gl_entry
               (p_organization_id,
                p_currency_code,
                0,--Credit
                v_sh_cess_amount, --Debit
                p_intercompany_rcvbl ,
                p_source_name,
                p_category_name,
                p_created_by,
                gl_accounting_date,
                NULL,
                NULL,
                NULL,
                P_REF_10,
                P_REF_23,
                P_REF_24,
                P_REF_25,
                P_REF_26
                );

               -- Cr  Intercompany Payables

               jai_cmn_gl_pkg.create_gl_entry
              (p_organization_id,
               p_currency_code,
               v_sh_cess_amount,--Credit
               0,  --Debit
               p_intercompany_paybl,
               p_source_name,
               p_category_name,
               p_created_by,
               gl_accounting_date,
               NULL,
               NULL,
               NULL,
               P_REF_10,
               P_REF_23,
               P_REF_24,
               P_REF_25,
               P_REF_26
               );

            end if;
     end if;
/*Bug 5989740 bduvarag*/
end if;

 Fnd_File.PUT_LINE(Fnd_File.LOG,  ' End of JA_IN_CESS_ENTRIES');

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
end;

-- end additions by ssumaith - bug#3817625
/***************************** END JA_IN_CESS_ENTRIES *******************************************************************/

/*************************************START JA_IN_CESS_ACCTG_ENTRIES************************************************ */

procedure ja_in_cess_acctg_entries(
                                   p_trx_hdr_id          number                                 ,
                                   p_inv_orgn_id         number                                 ,
                                   p_cess_amount         number                                 ,
                                   p_debit_account       gl_interface.code_combination_id%type  ,
                                   p_credit_account      gl_interface.code_combination_id%type  ,
                                   p_je_source_name      gl_interface.user_je_source_name%type  ,
                                   p_je_Category_name    gl_interface.user_je_category_name%type,
                                   p_currency_code       gl_interface.currency_Code%type        ,
                                   P_REFERENCE_10        varchar2                               ,
                                   P_REFERENCE_23        varchar2                               ,
                                   P_REFERENCE_24        varchar2                               ,
                                   P_REFERENCE_25        varchar2                               ,
                                   P_REFERENCE_26        varchar2
                                  ) is
/**********************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To calculate cess amount in case of an AR transaction.
CALLED FROM      : jai_om_rg_pkg.ja_in_rg23_part_ii_entry , jai_om_rg_pkg.pla_emtry , jai_om_rg_pkg.ja_in23d_entry

**********************************************************************/
lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_cess_acctg_entries';
begin

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' Before calling gl_interface for credit entry for CESS' );


    if p_debit_account is null or p_credit_account is null  then
	   Fnd_File.PUT_LINE(Fnd_File.LOG,  'Cess Accounts have not been setup in Organization Additional Information Screen - Cannot Process' ); --Added for bug#7172215
       raise_application_error(-20107,'Cess Accounts have not been setup in Organization Additional Information Screen - Cannot Process');
    end if;

    jai_cmn_gl_pkg.create_gl_entry(
                                   P_ORGANIZATION_ID              => p_inv_orgn_id       ,
                                   P_CURRENCY_CODE                => p_currency_code     ,
                                   P_CREDIT_AMOUNT                => p_cess_amount       ,
                                   P_DEBIT_AMOUNT                 => NULL                ,
                                   P_CC_ID                        => p_credit_account    ,
                                   P_JE_SOURCE_NAME               => p_je_source_name    ,
                                   P_JE_CATEGORY_NAME             => p_je_Category_name  ,
                                   P_CREATED_BY                   => fnd_global.user_id  ,
           /*  Bug 4562791. Added by Lakshmi Gopalsami
           Changed NULL to gl_accounting_date */
           P_ACCOUNTING_dATE              => gl_accounting_date  ,
                                   P_REFERENCE_10                 => p_reference_10      ,
                                   P_REFERENCE_23                 => p_reference_23      ,
                                   P_REFERENCE_24                 => p_reference_24      ,
                                   P_REFERENCE_25                 => p_reference_25      ,
                                   P_REFERENCE_26                 => p_reference_26
                                 );

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' Before calling gl_interface for debit entry for CESS' );
    jai_cmn_gl_pkg.create_gl_entry(
                                   P_ORGANIZATION_ID              => p_inv_orgn_id       ,
                                   P_CURRENCY_CODE                => p_currency_code     ,
                                   P_CREDIT_AMOUNT                => NULL                ,
                                   P_DEBIT_AMOUNT                 => p_cess_amount       ,
                                   P_CC_ID                        => p_debit_account     ,
                                   P_JE_SOURCE_NAME               => p_je_source_name    ,
                                   P_JE_CATEGORY_NAME             => p_je_Category_name  ,
                                   P_CREATED_BY                   => fnd_global.user_id  ,
           /*  Bug 4562791. Added by Lakshmi Gopalsami
           Changed NULL to gl_accounting_date */
           P_ACCOUNTING_dATE              => gl_accounting_date  ,
                                   P_REFERENCE_10                 => p_reference_10      ,
                                   P_REFERENCE_23                 => p_reference_23      ,
                                   P_REFERENCE_24                 => p_reference_24      ,
                                   P_REFERENCE_25                 => p_reference_25      ,
                                   P_REFERENCE_26                 => p_reference_26
                                 );

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
end;


/********************************************************************************************************************** */

/************************************START JA_IN_OM_CESS_REGISTER_ENTRIES***********************************************/
procedure ja_in_om_cess_register_entries(p_delivery_id        JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE   ,
                                         p_source_type        JAI_CMN_RG_OTHERS.SOURCE_TYPE%TYPE            ,
                                         p_source_name        JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE        ,
                                         p_source_id          JAI_CMN_RG_OTHERS.SOURCE_REGISTER_ID%TYPE     ,
                                         p_register_type      VARCHAR2                                  ,
					 p_cess_amount OUT NOCOPY NUMBER                                ,
                                         p_delivery_detail_id  JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE  DEFAULT NULL, -- added, Bug 4724137
					 p_cess_type          VARCHAR2/*Bug 5989740 bduvarag*/
                                        )
/**********************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To calculate cess amount in case of an OM transaction.
CALLED FROM      : jai_om_rg_pkg.ja_in_rg23_part_ii_entry , jai_om_rg_pkg.pla_emtry , jai_om_rg_pkg.ja_in23d_entry

**********************************************************************/
is /* Added the having clause to the following cursor -  ssumaith bug#4185392
     This was done because if there is no cess amount, there is no need to call the insert row procedure
  */
  CURSOR  c_tax_type_rec IS
  SELECT  jtc.tax_type , round(sum(jsptl.func_tax_amount),0)  tax_amount  --rchandan for bug#4388950
  FROM    JAI_OM_WSH_LINE_TAXES jsptl ,
          JAI_CMN_TAXES_ALL           jtc
  WHERE   jtc.tax_id  =  jsptl.tax_id
  --Modified for bug5747126
   AND     delivery_detail_id = p_delivery_detail_id
   AND ((     upper(jtc.tax_type) IN (jai_constants.tax_type_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS) and p_cess_type = 'EXC') --Date 12/03/2007 by SACSETHI for bug#5907436
     OR
     (     upper(jtc.tax_type) IN (jai_constants.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_sh_EXC_EDU_CESS) and p_cess_type = 'SH') )
   GROUP   BY jtc.tax_type
   HAVING  SUM(jsptl.func_tax_amount) <> 0;
  -- added, Harshita for Bug 4714518
  /*AND
  (
   ( delivery_detail_id = p_delivery_detail_id AND p_source_type = 3)
              OR
   ( delivery_detail_id IN
      (SELECT delivery_detail_id
       FROM   ja_in_so_picking_lines   jspl
       WHERE  jspl.delivery_id = p_delivery_id
      )
      AND p_source_type <> 3
    )
   )*/
  -- ended, Harshita for Bug 4714518

  -- foll cursor added by ssumaith - bug# 5747126 - one off
  CURSOR  c_tax_type_for_delivery_rec  IS
  SELECT  jtc.tax_type , round(sum(jsptl.func_tax_amount),0)  tax_amount
  FROM    JAI_OM_WSH_LINE_TAXES jsptl ,
          JAI_OM_WSH_LINES_ALL     jspl  ,
          JAI_CMN_TAXES_ALL            jtc ,
          JAI_INV_ITM_SETUPS     jmsi /* Added by Ramananda for bug#5912620*/
  WHERE   jtc.tax_id       =  jsptl.tax_id
  AND     jspl.delivery_id = p_delivery_id
  AND     jspl.delivery_detail_id  = jsptl.delivery_detail_id
   AND ((     upper(jtc.tax_type) IN (jai_constants.tax_type_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS) and p_cess_type = 'EXC') --Date 12/03/2007 by SACSETHI for bug#5907436
     OR
     (     upper(jtc.tax_type) IN (jai_constants.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_sh_EXC_EDU_CESS) and p_cess_type = 'SH') )
     /* Added for bug#5912620, Starts */
     AND jmsi.inventory_item_id = jspl.inventory_item_id
     AND jmsi.organization_id   = jspl.organization_id
     AND jmsi.excise_flag       = 'Y'
     /* Added for bug#5912620, Endseft */
  GROUP   BY jtc.tax_type
  HAVING  SUM(jsptl.func_tax_amount) <> 0;

  -- ends additions by ssumaith - bug# 5747126 - one off

  lv_process_flag VARCHAR2(2);
  lv_process_msg  VARCHAR2(1000);
  ln_Cess_amount  NUMBER := 0;

  BEGIN

  IF p_source_type = 3 THEN /* For RG23D */ /* if condition added by ssumaith - bug# 5747126 */

    FOR tax_type_rec IN c_tax_type_rec
    LOOP
        ln_Cess_amount := ln_Cess_amount + nvl(tax_type_rec.tax_amount,0);

        Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling   jai_Rg_others_pkg.insert_row');

      jai_cmn_rg_others_pkg.insert_row(
                                      P_SOURCE_TYPE   => p_source_type          ,
                                      P_SOURCE_NAME   => p_source_name          ,
                                      P_SOURCE_ID     => p_source_id            ,
                                      P_TAX_TYPE      => tax_type_rec.tax_type  ,
                                      DEBIT_AMT       => tax_type_rec.tax_amount,
                                      CREDIT_AMT      => NULL                   ,
                                      P_PROCESS_FLAG  => lv_process_flag        ,
                                      P_PROCESS_MSG   => lv_process_msg
                                    );

     Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling   jai_Rg_others_pkg.insert_row with P_PROCESS_FLAG => ' || lv_process_flag);
     Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling   jai_Rg_others_pkg.insert_row with P_PROCESS_MSG => ' || lv_process_msg);
     IF  lv_process_flag <> jai_constants.successful THEN
	 Fnd_File.PUT_LINE(Fnd_File.LOG,  'Error Encountered is ' ||lv_process_msg); --Added for bug#7172215
        raise_application_error(-20110,'Error Encountered is ' || lv_process_msg);
     END IF;

    END LOOP;

    p_cess_amount := ln_Cess_amount;

  ELSIF p_source_type in (1,2) THEN /* PLA and RG23Part II */

     /* elsif condition and the code till end if below added by ssumaith - bug# 5747126 */

      ln_Cess_amount := 0;

      FOR tax_type_rec IN c_tax_type_for_delivery_rec
      LOOP
          ln_Cess_amount := ln_Cess_amount + nvl(tax_type_rec.tax_amount,0);

          Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling   jai_Rg_others_pkg.insert_row');

          jai_cmn_rg_others_pkg.insert_row(
                                        P_SOURCE_TYPE   => p_source_type          ,
                                        P_SOURCE_NAME   => p_source_name          ,
                                        P_SOURCE_ID     => p_source_id            ,
                                        P_TAX_TYPE      => tax_type_rec.tax_type  ,
                                        DEBIT_AMT       => tax_type_rec.tax_amount,
                                        CREDIT_AMT      => NULL                   ,
                                        P_PROCESS_FLAG  => lv_process_flag        ,
                                        P_PROCESS_MSG   => lv_process_msg
                                      );

       Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling   jai_Rg_others_pkg.insert_row with P_PROCESS_FLAG => ' || lv_process_flag);
       Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling   jai_Rg_others_pkg.insert_row with P_PROCESS_MSG => ' || lv_process_msg);
       IF  lv_process_flag <> jai_constants.successful THEN
	   Fnd_File.PUT_LINE(Fnd_File.LOG,  'Error Encountered is ' ||lv_process_msg); --Added for bug#7172215
          raise_application_error(-20110,'Error Encountered is ' || lv_process_msg);
       END IF;

      END LOOP;

      p_cess_amount := ln_Cess_amount;

  END IF;

  END ja_in_om_cess_register_entries;

/**********************************************************************************************************************/
PROCEDURE ja_in_ar_cess_register_entries(p_customer_trx_id  JAI_AR_TRXS.CUSTOMER_TRX_ID%TYPE      ,
                                         p_source_type      JAI_CMN_RG_OTHERS.SOURCE_TYPE%TYPE                  ,
                                         p_source_name      JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE              ,
                                         p_source_id        JAI_CMN_RG_OTHERS.SOURCE_REGISTER_ID%TYPE           ,
                                         p_register_type    VARCHAR2    ,
                                         p_cess_amount OUT NOCOPY NUMBER                                ,
                                         p_delivery_detail_id JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE  DEFAULT NULL, -- added for Bug 4724137
					 p_cess_type        VARCHAR2/*Bug 5989740 bduvarag*/
                                        )

/**********************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To calculate cess amount in case of an AR transaction.
CALLED FROM      : jai_om_rg_pkg.ja_in_rg23_part_ii_entry , jai_om_rg_pkg.pla_emtry , jai_om_rg_pkg.ja_in23d_entry
====================================================================================
Change History
====================================================================================
1. 23-Aug-2005  Aiyer - Bug# 4541303 (Forward porting for the 11.5 bug 4538315) 120.4
                  For a manual AR invoice with more than one line, the cess amount was being hit for the whole of the
                  invoice amount for each of the lines.

                  Code changes are done in the package jai_om_rg_pkg as well this trigger.

                  Code changes done in the package include calculating the cess amount for the current customer trx line id.

                  Code changes done in the trigger include sending the customer trx line id when pla is hit . This is inline
                  with the way JAI_CMN_RG_23AC_II_TRXS works.

                  Dependency Due to this bug:-
                    jai_jai_t.sql (120.1)
2  15-jul-2009 vkaranam for bug#8679064,file version 120.8.12000000.10
                Issue:
		MANUAL AR invoice is not passing Cess,sh cess entries for RG23 part II.
		Fix:
		While calling the procedure ja_in_ar_cess_register_entries ,p_customer_trx_id value is been passed
		as p_transasction_hdr_id i.e customer_trx_line_id for AR.7/15/20097/15/2009

**********************************************************************/

is
   /* Added the having clause to the following cursor -  ssumaith bug#4185392
       This was done because if there is no cess amount, there is no need to call the insert row procedure
   */
  CURSOR  c_tax_type_rec IS
  SELECT  jtc.tax_type , round(sum(jrctl.func_tax_amount),0)  tax_amount  --added round for bug#9539924
  FROM    JAI_AR_TRX_TAX_LINES jrctl ,
          JAI_CMN_TAXES_ALL             jtc
  WHERE   jtc.tax_id  =  jrctl.tax_id
  AND     link_to_cust_trx_line_id = p_customer_trx_id -- added, aiyer for Bug 4541303 /*Bug 5989740 bduvarag*/
   AND ((     upper(jtc.tax_type) IN (jai_constants.tax_type_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_EXC_EDU_CESS) and p_cess_type = 'EXC')
     OR
     (     upper(jtc.tax_type) IN (jai_constants.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.TAX_TYPE_sh_EXC_EDU_CESS) and p_cess_type = 'SH') )


  GROUP   BY jtc.tax_type
  HAVING  SUM(jrctl.func_tax_amount) <> 0;

  lv_process_flag varchar2(2);
  lv_process_msg  varchar2(1000);
  ln_Cess_amount  number := 0;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_ar_cess_register_entries';

begin

    For tax_type_rec in c_tax_type_rec
    Loop

        ln_Cess_amount := ln_Cess_amount + nvl(tax_type_rec.tax_amount,0);
        jai_cmn_rg_others_pkg.insert_row(
                                      P_SOURCE_TYPE   => p_source_type          ,
                                      P_SOURCE_NAME   => p_source_name          ,
                                      P_SOURCE_ID     => p_source_id            ,
                                      P_TAX_TYPE      => tax_type_rec.tax_type  ,
                                      DEBIT_AMT       => tax_type_rec.tax_amount,
                                      CREDIT_AMT      => NULL                   ,
                                      P_PROCESS_FLAG  => lv_process_flag        ,
                                      P_PROCESS_MSG   => lv_process_msg
                                    );
    End Loop;
     p_cess_amount := ln_Cess_amount;
EXCEPTION
  WHEN OTHERS THEN
  p_cess_amount:=null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
end ja_in_ar_cess_register_entries;

/**********************************************************************************************************************/
procedure ja_in_cess_register_entries(
                                       p_register_id            JAI_CMN_RG_23AC_II_TRXS.register_id%type                ,
                                       p_register_type          varchar2                                           ,
                                       p_inv_orgn_id            JAI_CMN_INVENTORY_ORGS.organization_id%type   ,
                                       p_je_source_name         gl_interface.USER_JE_SOURCE_NAME%type              ,
                                       p_je_category_name       gl_interface.USER_JE_CATEGORY_NAME%type            ,
                                       p_source_type            JAI_CMN_RG_OTHERS.source_type%type                     ,
                                       p_currency_code          gl_interface.currency_code%type                    ,
                                       p_transaction_hdr_id     Number                                             ,
                                       p_debit_account          Number                                             ,
                                       p_Credit_account         Number                                             ,
                                       p_cess_amount OUT NOCOPY number                                         ,
				       p_cess_type              varchar2                                           , /*Bug 5989740 bduvarag*/
                                       P_REFERENCE_10           varchar2 default Null                              ,
                                       P_REFERENCE_23           varchar2 default Null                              ,
                                       P_REFERENCE_24           varchar2 default Null                              ,
                                       P_REFERENCE_25           varchar2 default Null                              ,
                                       P_REFERENCE_26           varchar2 default Null
                                     )

/**********************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To paass register and accounting entries for education cess
CALLED FROM      : jai_om_rg_pkg.ja_in_rg23_part_ii_entry , jai_om_rg_pkg.pla_emtry , jai_om_rg_pkg.ja_in23d_entry

**********************************************************************/
 IS
cursor  c_delivery_details  is
select  delivery_id , organization_id
from    JAI_OM_WSH_LINES_ALL
where   delivery_detail_id  = p_transaction_hdr_id;

cursor  c_customer_trx_details is
select  customer_trx_id
from    JAI_AR_TRX_LINES
where   customer_trx_line_id = p_transaction_hdr_id;

ln_delivery_id      JAI_OM_WSH_LINES_ALL.delivery_id%type;
ln_customer_trx_id  JAI_AR_TRX_LINES.customer_trx_id%type;
ln_Cess_amount      number;
ln_inv_orgn_id      number;
ln_header_id        number;
lv_source_name      varchar2(20);
lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_cess_register_entries';

begin

    open   c_delivery_details;
    fetch  c_delivery_details into ln_delivery_id  , ln_inv_orgn_id;
    close  c_delivery_details;

    ln_inv_orgn_id := p_inv_orgn_id;

    /*

    if called from Excise Invoice Generation program the values for the parameters are as follows:

       p_source_name            := 'Register India'                    ;
       p_category_name          := 'Register India'                  ;
       p_transaction_hdr_id     := It has the delivery detail id

       Based on the delivery detail id , pick up the delivery id, organization id and get the taxes from JAI_OM_WSH_LINE_TAXES

    If called from AR invoice completion the values for the parameters are as follows.

       p_source_name             :=  'Receivables India'
       p_category_name           :=  'RG Register Data Entry'
       p_transaction_hdr_id      :=  customer_trx_line_id from JAI_AR_TRX_LINES table

       Based on the customer_trx_line_id , pick up the customer_trx_id , organization id and get the taxes from JAI_AR_TRX_TAX_LINES

    */
    if p_source_type = 2 then
       ln_customer_trx_id := p_transaction_hdr_id;
       lv_source_name := 'PLA';
    elsif  p_source_type = 1 then

       /*
        In the case of RG23 Part II , the customer trx line id was being passed .
        In case of PLA customer trx id was being passed from manual ar invoice completion trigger
       */
       open   c_customer_trx_details;
       fetch  c_customer_trx_details into ln_customer_trx_id;
       close  c_customer_trx_details;

       if p_Register_type = 'A' then
          lv_source_name := 'RG23A_P2';
       elsif p_Register_type = 'C' then
          lv_source_name := 'RG23C_P2';
       end if;
    elsif  p_source_type = 3 then
       /* for RG23D */
       ln_customer_trx_id := p_transaction_hdr_id;/*Bug 5989740 bduvarag*/
       lv_source_name := 'RG23D';
    end if;

    if  p_je_source_name = 'Register India'  and p_je_category_name = 'Register India' then
        /*
         Do all things needed to populate records into the register table , picking up taxes from the JAI_OM_WSH_LINE_TAXES table
        */
        ln_header_id := ln_delivery_id;
        ja_in_om_cess_register_entries(p_delivery_id         => ln_delivery_id      ,
                                       p_source_type         => p_source_type       ,
                                       p_source_name         => lv_source_name      ,
                                       p_source_id           => p_register_id       ,
                                       p_register_type       => p_register_type     ,
                                       p_cess_amount         => ln_Cess_amount ,
                                       p_delivery_detail_id  => p_transaction_hdr_id,/*added by vkaranam for bug #6159579*/
				       p_cess_type           => p_cess_type /*Bug 5989740 bduvarag*/
                                      );


    elsif  p_je_source_name = 'Receivables India'  and p_je_category_name =  jai_constants.je_category_rg_entry then    --replaced RG Register Data Entry, csahoo for bug#6155839
        /*
         Do all things needed to populate records into the register table , picking up taxes from the ja_in_customer_trx_tax_lines table
        */
        ln_header_id := ln_customer_trx_id;

        ja_in_ar_cess_register_entries(p_customer_trx_id     => p_transaction_hdr_id ,-- ln_customer_trx_id passed p_transaction_hdr_id for bug#8679064  ,
                                       p_source_type         => p_source_type       ,
                                       p_source_name         => lv_source_name      ,
                                       p_source_id           => p_register_id       ,
                                       p_register_type       => p_register_type     ,
                                       p_cess_amount         => ln_Cess_amount,
				       p_delivery_detail_id  => NULL,
				       p_cess_type           => p_cess_type/*Bug 5989740 bduvarag*/
                                      );
    end if;

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' Before calling ja_in_cess_acctg_entries' );
    /*
    -- MXYZ No Cess A/c in trading scenario
    */
    if  p_source_type  <> 3 then
		IF NVL(ln_Cess_amount,0) <> 0 THEN --Added for bug#7172215. accounting entries should happen only if amount non  zero
      ja_in_cess_acctg_entries(
                               ln_header_id      ,
                               ln_inv_orgn_id    ,
                               ln_Cess_amount    ,
                               p_debit_account   ,
                               p_credit_account  ,
                               p_je_source_name  ,
                               p_je_Category_name,
                               p_currency_code   ,
                               P_REFERENCE_10    ,
                               P_REFERENCE_23    ,
                               P_REFERENCE_24    ,
                               P_REFERENCE_25    ,
                               P_REFERENCE_26
                              );
    End If;
      Fnd_File.PUT_LINE(Fnd_File.LOG,  ' after calling ja_in_cess_acctg_entries' );
    end if;

   p_cess_amount := ln_Cess_amount;

EXCEPTION
  WHEN OTHERS THEN
  p_cess_amount := null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
end;

/**********************************************************************************************************************/


/************************************** JA_IN_ACCOUNTING_ENTRIES **************************************************
Sl No.    Date    Author and Details
1.      11/07/2002  This PROCEDURE  IS created BY Aparajita On 03/08/2002 FOR bug # 2496388 .

            This was done TO implement the internal sales ORDER accounting entries.
            Procedures ja_in_pla_entry AND ja_in_rg23_part_II_entry
            are calling this PROCEDURE FOR creating accounting entries.
            Logic :
            For non internal sales order :
              Debit and Credit accounts as already found out in the respective procedures and
              passed onto this procedure

            FOR internal sales order :
              - Debit  Inter_org Receivable Account
              - Credit  Excise Paid/Payable Account

              if transfer type is in-transit then
                - Debit Intransit Account
              - Credit Inter_org Payable Account
              end if;

2.      01/04/2003  Aparajita for bug#2848921
            As per the logic above, for internal sales order the first two accounting entries are not
            required. But as per this bug, for ISO these two accounting entries should also get passed.

            The intransit_inv_account was picked from mtl_interorg_parameters through cursor
            c_get_iso_accounts for the combination of from and to organization. As per the requirement
            now, it should be picked  from mtl_parameters for the receiving organization. Added cursor
            c_get_intransit_inv_account.

            Added the check of fob_point along with in transit type.

3.        07/04/2003    Aparajita for bug#2893284
            Removed the cursor c_get_intransit_inv_account as the requiremnts are that it should be
            picked up from mtl_interorg_parameters, so using cursor c_get_iso_accounts.

            Removed the cursor c_get_intransit_type, as it was redundant and used c_get_iso_accounts.

4.       13/05/2003     Nagaraj.s for Bug#2912007
            --Changed by Nagaraj.s for Bug2912007.
                --The Following is the New Accounting Entries as Required in case of ISO.
                --***************************************************************************************************
                --For Intransit Transfers(v_intransit_type=2)
                --If FOB Point =1(Shipment)
                    Accounting Entries are : 1. Dr Inter Org Receivable, Cr Excise Paid Payable
                                       2. Dr Intransit Inventory Account, Cr Inter Org Payable Account

                 --If FOB Point =2(Receipt)
                    Accounting Entries are : 1. Dr Intransit Inventory Account, Cr Excise Paid Payable Account
                --***************************************************************************************************
                --For Direct Transfers(v_intransit_type=1)
                  Accounting Entries are : 1. Dr Inter Org Receivable, Cr Excise Paid Payable Account

5.     20/08/2004     ssumaith - bug#3817625 file version 115.1

                  Created an internal procedure JA_IN_CESS_ENTRIES

                  -- A/c Entries for CESS needs to be passed as follows:
                  -- Dr  Intransit Material Value
                  -- Cr  CESS Payable Paid
                  -- It  will be called from ja_in_pla_entry and ja_in_rg23_part_ii_entry because only they have the
                  -- amount impact for excise registers

                  --If the FOB point is set to SHIPMENT, the following entry also needs to be passed :

                       --  Intercompany Receivable       Cess amt
                       --  Intercompany Payables                   cess amt

6. 11/01/2005    ssumaith - bug# 4136981

                 Coded for accounting entries impact in excise cess and cvd cess when called from manual AR invoice
                 completion and excise invoice generation program.
                 Internal procedures have been created which are called from ja_in_rg23_part_ii_entry , ja_in_pla_entry
                 and Ja_In_Rg23d_Entry procedures

                  This fix does not introduce dependency on this object , but this patch cannot be sent alone to the CT
                  because it relies on the alter done and the new tables created as part of the education cess enhancement
                  bug# 4146708 creates the objects

                  All future code changes on this object should have reference to bug#4146708 as dependency



************************************* JA_IN_ACCOUNTING_ENTRIES **************************************************/
PROCEDURE  ja_in_accounting_entries
(
p_org_id                     NUMBER,
p_location_id                NUMBER,
p_currency_code              VARCHAR2,
p_excise_amount              NUMBER,
p_source_name                VARCHAR2,
p_category_name              VARCHAR2,
p_created_by                 NUMBER,
p_delivery_detail_id         NUMBER,
p_non_iso_credit_account_id  NUMBER,
p_non_iso_debit_account_id   NUMBER,
P_REF_10                     VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
P_REF_23                     VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
P_REF_24                     VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
P_REF_25                     VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
P_REF_26                     VARCHAR2 DEFAULT NULL  -- added by sriram - bug # 2769440
)
IS
  v_order_header_id                  WSH_DELIVERY_DETAILS.SOURCE_HEADER_ID%TYPE;
  v_order_line_id                    WSH_DELIVERY_DETAILS.SOURCE_LINE_ID%TYPE;
  v_order_source_id                  OE_ORDER_HEADERS_ALL.ORDER_SOURCE_ID%TYPE;
  v_intransit_type                   MTL_SHIPPING_NETWORK_VIEW.INTRANSIT_TYPE%TYPE;
  v_fob_point                        MTL_SHIPPING_NETWORK_VIEW.FOB_POINT%TYPE;
  v_interorg_receivables_account     MTL_INTERORG_PARAMETERS.INTERORG_RECEIVABLES_ACCOUNT%TYPE;
  v_interorg_payables_account        MTL_INTERORG_PARAMETERS.INTERORG_PAYABLES_ACCOUNT%TYPE;
  v_intransit_inv_account            MTL_INTERORG_PARAMETERS.INTRANSIT_INV_ACCOUNT%TYPE;
  v_from_organization_id             WSH_DELIVERY_DETAILS.ORGANIZATION_ID%TYPE;
  v_to_organization_id               WSH_DELIVERY_DETAILS.ORGANIZATION_ID%TYPE;
  v_excise_rcvble_account            JAI_CMN_INVENTORY_ORGS.EXCISE_RCVBLE_ACCOUNT%TYPE;
  v_requisition_header_id            PO_REQUISITION_LINES_ALL.REQUISITION_HEADER_ID%TYPE;
  v_requisition_line_id              PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
  ln_src_excise_23d_account          JAI_CMN_INVENTORY_ORGS.EXCISE_23D_ACCOUNT%TYPE;
  ln_dest_excise_23d_account         JAI_CMN_INVENTORY_ORGS.EXCISE_23D_ACCOUNT%TYPE;
  ln_dest_excise_rcvble_account      JAI_CMN_INVENTORY_ORGS.EXCISE_RCVBLE_ACCOUNT%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_accounting_entries';


  -- get the delivery details
  CURSOR c_get_delivery_details IS
  SELECT source_header_id, source_line_id
  FROM   wsh_delivery_details
  WHERE  delivery_detail_id = p_delivery_detail_id;

  -- cursor to get order source id, when 10 this means that it is an internal sales order(iso)
  -- this also gets other details to link to requisition side and the from org id.
  CURSOR c_get_order_details(p_header_id NUMBER, p_line_id  NUMBER) IS
  SELECT ship_from_org_id,  order_source_id, source_document_id, source_document_line_id
  FROM   oe_order_lines_all
  WHERE  header_id = p_header_id
  AND    line_id = p_line_id;

  -- get the to organization id from the requisition details
  CURSOR c_get_to_organization(p_requisition_header_id  NUMBER, p_requisition_line_id  NUMBER) IS
  SELECT destination_organization_id , deliver_to_location_id /* deliver_to_location_id added by ssumaith - to handle trading to trading ISO */
  FROM   po_requisition_lines_all
  WHERE  requisition_header_id = p_requisition_header_id
  AND    requisition_line_id =  p_requisition_line_id;


  CURSOR c_get_iso_accounts(p_from_org_id NUMBER, p_to_org_id NUMBER) IS
  SELECT intransit_type, fob_point, interorg_receivables_account, interorg_payables_account, intransit_inv_account
  FROM   mtl_interorg_parameters
  WHERE  from_organization_id = p_from_org_id
  AND    to_organization_id =  p_to_org_id;

  CURSOR debit_account_cur( cp_organization_id JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE,
                            cp_location_id     JAI_CMN_INVENTORY_ORGS.LOCATION_ID%TYPE
                          )  IS
  SELECT excise_rcvble_account ,
                         excise_23d_account,
                         excise_in_rg23d,
                         Trading,
                         Manufacturing
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = cp_organization_id
  AND    location_id     = cp_location_id;


  CURSOR c_delivery_cur (cp_delivery_detail_id JAI_OM_WSH_LINES_ALL.DELIVERY_DETAIL_ID%TYPE) IS
  SELECT delivery_id
  FROM   JAI_OM_WSH_LINES_ALL
  WHERE  delivery_detail_id = cp_delivery_detail_id;

  CURSOR c_cess_amount(cp_delivery_id number) is
  SELECT sum(a.tax_amount)
  FROM   JAI_OM_WSH_LINE_TAXES a, JAI_CMN_TAXES_ALL b
  WHERE  delivery_detail_id in
  (SELECt delivery_detail_id
   FROM   JAI_OM_WSH_LINES_ALL
   WHERE  delivery_id = cp_delivery_id
  )
   AND    a.tax_id = b.tax_id
   AND    upper(b.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS);



  ln_to_location_id                          PO_REQUISITION_LINES_ALL.DELIVER_TO_LOCATION_ID%TYPE;
  lv_dest_intransit_type                     MTL_INTERORG_PARAMETERS.INTRANSIT_TYPE%TYPE;
  ln_dest_fob_point                          MTL_INTERORG_PARAMETERS.FOB_POINT%TYPE;
  ln_dest_interorg_rcvbles_acc               MTL_INTERORG_PARAMETERS.INTERORG_RECEIVABLES_ACCOUNT%TYPE;
  ln_dest_interorg_payables_acc              MTL_INTERORG_PARAMETERS.INTERORG_PAYABLES_ACCOUNT%TYPE;
  ln_dest_intransit_inv_account              MTL_INTERORG_PARAMETERS.INTRANSIT_INV_ACCOUNT%TYPE;
  ln_src_excise_in_rg23d                     JAI_CMN_INVENTORY_ORGS.EXCISE_IN_RG23D%TYPE;
  ln_dest_excise_in_rg23d                    JAI_CMN_INVENTORY_ORGS.EXCISE_IN_RG23D%TYPE;
  lv_source_trading                          JAI_CMN_INVENTORY_ORGS.TRADING%TYPE;
  lv_source_manufacturing                    JAI_CMN_INVENTORY_ORGS.MANUFACTURING%TYPE;
  lv_dest_trading                            JAI_CMN_INVENTORY_ORGS.TRADING%TYPE;
  lv_dest_manufacturing                      JAI_CMN_INVENTORY_ORGS.MANUFACTURING%TYPE;
  ln_debit_acc                               GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE;
  ln_credit_acc                              GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE;
  ln_cess_amount                             JAI_CMN_RG_OTHERS.DEBIT%TYPE;
  ln_delivery_id                             JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE;

BEGIN

  -- get the details of the delivery, the oreder header id
  OPEN   c_get_delivery_details;
  FETCH  c_get_delivery_details INTO v_order_header_id, v_order_line_id  ;
  CLOSE  c_get_delivery_details;

  OPEN   c_delivery_cur (p_delivery_detail_id);
  FETCH  c_delivery_cur INTO ln_delivery_id;
  CLOSE  c_delivery_cur ;

  OPEN  c_cess_amount( ln_delivery_id );
  FETCH c_cess_amount INTO ln_cess_amount;
  CLOSE c_cess_amount;

  -- get the source of the order, 10 means internal order.
  OPEN  c_get_order_details(v_order_header_id, v_order_line_id);
  FETCH c_get_order_details INTO
        v_from_organization_id, v_order_source_id, v_requisition_header_id, v_requisition_line_id;
  CLOSE c_get_order_details;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' in the gl_interface procedure with values as follows' );
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_order_header_id='||v_order_header_id||', v_order_line_id='|| v_order_line_id );
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_from_organization_id='||v_from_organization_id||', v_order_source_id='||v_order_source_id||', v_requisition_header_id='||v_requisition_header_id||', v_requisition_line_id='||v_requisition_line_id);

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' p_non_iso_credit_account_id ='||p_non_iso_credit_account_id|| 'and  p_non_iso_debit_account_id ='||p_non_iso_debit_account_id);


    -- IF NVL(v_order_source_id, 0) <> 10 THEN, commented by Aparajita for bug # 2848921

       -- not an internal order

  OPEN  debit_account_cur(v_from_organization_id , p_location_id);
  FETCH debit_account_cur INTO v_excise_rcvble_account , ln_src_excise_23d_account, ln_src_excise_in_rg23d, lv_source_trading, lv_source_manufacturing;
  CLOSE debit_account_cur;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_to_organization_id =  ' || v_to_organization_id );
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_intransit_type, v_fob_point ' || v_intransit_type || ' , '  || v_fob_point);
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_excise_rcvble_account , v_intransit_inv_account ' || v_excise_rcvble_account || ', '  || v_intransit_inv_account );

  OPEN  debit_account_cur(v_to_organization_id , ln_to_location_id );
  FETCH debit_account_cur INTO ln_dest_excise_rcvble_account , ln_dest_excise_23d_account , ln_dest_excise_in_rg23d ,lv_dest_trading, lv_dest_manufacturing;
  CLOSE debit_account_cur;
 --Added for bug#7277543
 IF p_non_iso_credit_account_id IS NULL OR p_non_iso_debit_account_id IS NULL THEN
	Fnd_File.PUT_LINE(Fnd_File.LOG,  'Excise Payable Accounts (RG23A/C/PLA) have not been setup in Organization Additional Information Screen - Cannot Process for Accounting');
 END IF;
 --End bug#7277543
  IF NVL(p_non_iso_credit_account_id,0) >0 AND NVL(p_non_iso_debit_account_id,0) >0 AND
      NOT      /*  The NOT part of the if condition added by ssumaith - bug# 4171469 */
          (
            /*(
               NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y'
            )
            AND
            (
              NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'
            )*/
              --commented the above and added the below by Ramananda for Bug #4516577
              (NVL(lv_source_trading,'N') = 'Y'
              AND
              ( NVL(lv_dest_trading,'N') =  'Y') OR (NVL(lv_dest_manufacturing,'N') =  'Y')
              AND
              NVL(ln_src_excise_in_rg23d,'N') = 'Y')

          )
  THEN

    -- v_excise_amount := NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0);
     Fnd_File.PUT_LINE(Fnd_File.LOG,  ' before calling gl interface -1 ');
    jai_cmn_gl_pkg.create_gl_entry
    (
    p_org_id,
    p_currency_code,
    p_excise_amount,
    0,
    p_non_iso_credit_account_id,
    p_source_name,
    p_category_name,
    p_created_by,
    /*  Bug 4562791. Added by Lakshmi Gopalsami
        Changed NULL to gl_accounting_date */
    gl_accounting_date  ,
    NULL, -- added by sriram - bug # 2769440
    NULL, -- added by sriram - bug # 2769440
    NULL, -- added by sriram - bug # 2769440
    P_REF_10,-- added by sriram - bug # 2769440
    P_REF_23,-- added by sriram - bug # 2769440
    P_REF_24,-- added by sriram - bug # 2769440
    P_REF_25,-- added by sriram - bug # 2769440
    P_REF_26);-- added by sriram - bug # 2769440

    jai_cmn_gl_pkg.create_gl_entry
    (
    p_org_id,
    p_currency_code,
    0,
    p_excise_amount,
    p_non_iso_debit_account_id,
    p_source_name,
    p_category_name,
    p_created_by,
    /*  Bug 4562791. Added by Lakshmi Gopalsami
        Changed NULL to gl_accounting_date */
    gl_accounting_date  ,
    NULL,-- added by sriram - bug # 2769440
    NULL,-- added by sriram - bug # 2769440
    NULL,-- added by sriram - bug # 2769440
    P_REF_10,-- added by sriram - bug # 2769440
    P_REF_23,-- added by sriram - bug # 2769440
    P_REF_24,-- added by sriram - bug # 2769440
    P_REF_25,-- added by sriram - bug # 2769440
    P_REF_26);-- added by sriram - bug # 2769440

  END IF;


  IF NVL(v_order_source_id, 0) = 10 THEN  -- added by Aparajita for bug#2848921.

      -- order is internal, fetch the extra informations.

    -- get the destination organization
    OPEN  c_get_to_organization(v_requisition_header_id, v_requisition_line_id);
    FETCH c_get_to_organization INTO v_to_organization_id , ln_to_location_id ;
    CLOSE c_get_to_organization;

    OPEN  c_get_iso_accounts(v_from_organization_id, v_to_organization_id);
    FETCH c_get_iso_accounts
    INTO  v_intransit_type, v_fob_point, v_interorg_receivables_account,
          v_interorg_payables_account, v_intransit_inv_account;
    CLOSE c_get_iso_accounts;

     /*
     getting the accounts of the destination organization.

     OPEN  c_get_iso_accounts(v_to_organization_id, v_from_organization_id);
     FETCH c_get_iso_accounts
     INTO  lv_dest_intransit_type, ln_dest_fob_point, ln_dest_interorg_rcvbles_acc,
              ln_dest_interorg_payables_acc, ln_dest_intransit_inv_account;
     CLOSE c_get_iso_accounts;
    */


            -- check if type is intransit
            /*
            --Changed by Nagaraj.s for Bug2912007.
            --The Following is the New Accounting Entries as Required in case of ISO.
            --***************************************************************************************************
            --For Intransit Transfers(v_intransit_type=2)
               --If FOB Point =1(Shipment)
                  Accounting Entries are : 1. Dr Inter Org Receivable, Cr Excise Paid Payable
                                           2. Dr Intransit Inventory Account, Cr Inter Org Payable Account

               --If FOB Point =2(Receipt)
                  Accounting Entries are : 1. Dr Intransit Inventory Account, Cr Excise Paid Payable Account
            --***************************************************************************************************
            --For Direct Transfers(v_intransit_type=1)
              Accounting Entries are : 1. Dr Inter Org Receivable, Cr Excise Paid Payable Account
           */


        IF v_intransit_type = 2  THEN
          -- fob point check added by Aparajita for bug#2848921, fob point 1 is shipment
          -- credit excise paid, payable account , debit inter org receiavable account.

          IF v_fob_point IN (1,2) THEN

                /*
                start additions by ssumaith for bug# 4171469 on shipment side in case of trading to trading ISO scenario.
                 Get the details of the destination organiztion such as rg23d account , excise in rg23d
                */

                /*IF  NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y' THEN
                   IF NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'  THEN*/
                --commented the above and added the below by Ramananda for Bug #4516577
                IF NVL(lv_source_trading,'N') = 'Y'
                   AND
                   ( NVL(lv_dest_trading,'N') =  'Y' OR NVL(lv_dest_manufacturing,'N') =  'Y')
                   AND
                   NVL(ln_src_excise_in_rg23d,'N') = 'Y' THEN
                      /*
                         write code to pass specific a/c entries for ttading to trading iso
                         IF AN ISO TRANSACTIONS HAPPENS BETWEEN TWO TRADING ORGANIZATIONS, THEN THE FOLLOWING A/c Entries
                         need to be passed provided both the source and destination organizations have the 'Excise in rg23D ' field
                         set to 'Y' for the org + location combination.

                         FOB Point => SHIPMENT
                             Debit   Inventory Intransit A/c of Receiving org for the excise + cess amount
                             Credit  Excise A/c of Source organization - Excise + Cess amount

                         FOB Point => RECEIPT

                             Debit  Inventory Intransit A/c of Source Org - Excise + Cess amt
                             Credit Excise A/c of Source Org - Excise and Cess amt.
                      */

                      ln_debit_acc  :=  v_intransit_inv_account;
                      ln_credit_acc := ln_src_excise_23d_account;


                      jai_cmn_gl_pkg.create_gl_entry
                     (
                      p_org_id,
                      p_currency_code,
                      p_excise_amount + nvl(ln_cess_amount,0), --Credit
                      0, --Debit
                      ln_credit_acc,
                      p_source_name,
                      p_category_name,
                      p_created_by,
          /*  Bug 4562791. Added by Lakshmi Gopalsami
              Changed NULL to gl_accounting_date */
          gl_accounting_date  ,
                      NULL,
                      NULL,
                      NULL,
                      P_REF_10,
                      P_REF_23,
                      P_REF_24,
                      P_REF_25,
                      P_REF_26);



                      jai_cmn_gl_pkg.create_gl_entry
                      (p_org_id,
                       p_currency_code,
                       0,--Credit
                       p_excise_amount + nvl(ln_cess_amount,0), --Debit
                       ln_debit_acc,
                       p_source_name,
                       p_category_name,
                       p_created_by,
          /*  Bug 4562791. Added by Lakshmi Gopalsami
              Changed NULL to gl_accounting_date */
             gl_accounting_date  ,
                       NULL,
                       NULL,
                       NULL,
                       P_REF_10,
                       P_REF_23,
                       P_REF_24,
                       P_REF_25,
                       P_REF_26
                      );
                      GOTO end_of_procedure;
                   --END IF;
                   --commented the above by Ramananda for Bug #4516577
                END IF;

               /*
                ends here additions by ssumaith - bug# 4171469
               */
 --Added for bug#7277543
 IF v_excise_rcvble_account IS NULL OR v_intransit_inv_account IS NULL THEN
	Fnd_File.PUT_LINE(Fnd_File.LOG,  'Excise Receivable account or Intransit Invoice Account  have not been setup in Organization Additional Information Screen - Cannot Process for Accounting');
 END IF;
 --End bug#7277543
            IF NVL(v_excise_rcvble_account,0) >0 AND NVL(v_intransit_inv_account,0) >0 THEN

                 --CREDIT Excise Paid Payable Account
               Fnd_File.PUT_LINE(Fnd_File.LOG,  ' before calling gl interface - 2 ');
               jai_cmn_gl_pkg.create_gl_entry
               (
               p_org_id,
               p_currency_code,
               p_excise_amount, --Credit
               0, --Debit
               v_excise_rcvble_account,
               p_source_name,
               p_category_name,
               p_created_by,
         /*  Bug 4562791. Added by Lakshmi Gopalsami
             Changed NULL to gl_accounting_date */
         gl_accounting_date  ,
               NULL,-- added by sriram - bug # 2769440
               NULL,-- added by sriram - bug # 2769440
               NULL,-- added by sriram - bug # 2769440
               P_REF_10,-- added by sriram - bug # 2769440
               P_REF_23,-- added by sriram - bug # 2769440
               P_REF_24,-- added by sriram - bug # 2769440
               P_REF_25,-- added by sriram - bug # 2769440
               P_REF_26);-- added by sriram - bug # 2769440


               --DEBIT InTransit Inventory Account
               jai_cmn_gl_pkg.create_gl_entry
               (p_org_id,
                p_currency_code,
                0,--Credit
                p_excise_amount, --Debit
                v_intransit_inv_account,
                p_source_name,
                p_category_name,
                p_created_by,
    /*  Bug 4562791. Added by Lakshmi Gopalsami
        Changed NULL to gl_accounting_date */
    gl_accounting_date  ,
                NULL,-- added by sriram - bug # 2769440
                NULL,-- added by sriram - bug # 2769440
                NULL,-- added by sriram - bug # 2769440
                P_REF_10,-- added by sriram - bug # 2769440
                P_REF_23,-- added by sriram - bug # 2769440
                P_REF_24,-- added by sriram - bug # 2769440
                P_REF_25,-- added by sriram - bug # 2769440
                P_REF_26);-- added by sriram - bug # 2769440

            END IF; --End if For Account Checks

          END IF; --End if For v_fob_point in 1,2

          IF v_fob_point=1 THEN
  --Added for bug#7277543
 IF v_interorg_payables_account IS NULL OR v_interorg_receivables_account IS NULL THEN
	Fnd_File.PUT_LINE(Fnd_File.LOG,  ' Interorg Payables Account or Interorg Receivables Account have not been setup in Organization Additional Information Screen - Cannot Process for Accounting');
 END IF;
 --End bug#7277543

             IF NVL(v_interorg_payables_account, 0) >0 AND NVL(v_interorg_receivables_account,0) >0 THEN

                -- DEBIT Inter Org Receivables Account
                Fnd_File.PUT_LINE(Fnd_File.LOG,  ' before calling gl interface - 3 ');

                jai_cmn_gl_pkg.create_gl_entry
                ( p_org_id,
                  p_currency_code,
                  0, --Credit
                  p_excise_amount, --Debit
                  v_interorg_receivables_account,
                  p_source_name,
                  p_category_name,
                  p_created_by,
      /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
      gl_accounting_date  ,
                  NULL,-- added by sriram - bug # 2769440
                  NULL,-- added by sriram - bug # 2769440
                  NULL,-- added by sriram - bug # 2769440
                  P_REF_10,-- added by sriram - bug # 2769440
                  P_REF_23,-- added by sriram - bug # 2769440
                  P_REF_24,-- added by sriram - bug # 2769440
                  P_REF_25,-- added by sriram - bug # 2769440
                  P_REF_26);-- added by sriram - bug # 2769440

                  -- CREDIT Inter Org Payables Account
                 jai_cmn_gl_pkg.create_gl_entry
                 (
                  p_org_id,
                  p_currency_code,
                  p_excise_amount, --Credit
                  0, --Debit
                  v_interorg_payables_account,
                  p_source_name,
                  p_category_name,
                  p_created_by,
      /*  Bug 4562791. Added by Lakshmi Gopalsami
          Changed NULL to gl_accounting_date */
      gl_accounting_date  ,
                  NULL,-- added by sriram - bug # 2769440
                  NULL,-- added by sriram - bug # 2769440
                  NULL,-- added by sriram - bug # 2769440
                  P_REF_10,-- added by sriram - bug # 2769440
                  P_REF_23,-- added by sriram - bug # 2769440
                  P_REF_24,-- added by sriram - bug # 2769440
                  P_REF_25,-- added by sriram - bug # 2769440
                  P_REF_26);-- added by sriram - bug # 2769440

              END IF; --End if For Account Checks

          END IF; --End if For v_fob_point

        /*
        as discussed with support (yadunath - commenting out the code for v_intransit_type = 1 - bug#4171469
        ELSIF v_intransit_type = 1 THEN

           IF NVL(v_excise_rcvble_account, 0) >0 AND NVL(v_interorg_receivables_account,0) >0 THEN

               --CREDIT Excise Paid Payable Account
               Fnd_File.PUT_LINE(Fnd_File.LOG,  ' before calling gl interface - 4 ');

               jai_cmn_gl_pkg.create_gl_entry
              (
               p_org_id,
               p_currency_code,
               p_excise_amount, --Credit
               0, --Debit
               v_excise_rcvble_account,
               p_source_name,
               p_category_name,
               p_created_by,
               NULL,-- added by sriram - bug # 2769440
               NULL,-- added by sriram - bug # 2769440
               NULL,-- added by sriram - bug # 2769440
               NULL,-- added by sriram - bug # 2769440
               P_REF_10,-- added by sriram - bug # 2769440
               P_REF_23,-- added by sriram - bug # 2769440
               P_REF_24,-- added by sriram - bug # 2769440
               P_REF_25,-- added by sriram - bug # 2769440
               P_REF_26);-- added by sriram - bug # 2769440

               -- DEBIT Inter Org Receivables Account
               jai_cmn_gl_pkg.create_gl_entry
               (
                p_org_id,
                p_currency_code,
                0, --Credit
                p_excise_amount, --Debit
                v_interorg_receivables_account,
                p_source_name,
                p_category_name,
                p_created_by,
                NULL,-- added by sriram - bug # 2769440
                NULL,-- added by sriram - bug # 2769440
                NULL,-- added by sriram - bug # 2769440
                NULL,-- added by sriram - bug # 2769440
                P_REF_10,-- added by sriram - bug # 2769440
                P_REF_23,-- added by sriram - bug # 2769440
                P_REF_24,-- added by sriram - bug # 2769440
                P_REF_25,-- added by sriram - bug # 2769440
                P_REF_26);-- added by sriram - bug # 2769440

           END IF; --End if for Account Checks. */
        -- type is transit, extra accounting entries

        -- start additions by ssumaith - bug#3817625
        Fnd_File.PUT_LINE(Fnd_File.LOG,  ' before calling JA_IN_CESS_ENTRIES');

        JA_IN_CESS_ENTRIES
        (
          p_organization_id      =>  p_org_id                        ,
          p_location_id          =>  p_location_id                   ,
          p_delivery_detail_id   =>  p_delivery_detail_id            ,
          p_intransit_inv_acct   =>  v_intransit_inv_account         ,
          p_intercompany_rcvbl   =>  v_interorg_receivables_account  ,
          p_intercompany_paybl   =>  v_interorg_payables_account     ,
          p_fob_point            =>  v_fob_point                     ,
          p_currency_code        =>  p_currency_code                 ,
          p_source_name          =>  p_source_name                   ,
          p_category_name        =>  p_category_name                 ,
          p_created_by           =>  p_created_by                    ,
          P_REF_10               =>  P_REF_10                        ,
          P_REF_23               =>  P_REF_23                        ,
          P_REF_24               =>  P_REF_24                        ,
          P_REF_25               =>  P_REF_25                        ,
          P_REF_26               =>  P_REF_26
        );
	  END IF;/*Bug 5989740 bduvarag*/
        Fnd_File.PUT_LINE(Fnd_File.LOG,  ' after calling JA_IN_CESS_ENTRIES');
        -- start additions by ssumaith - bug#3817625
  END IF; -- internal order.

  <<end_of_procedure>>
  null;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END ja_in_accounting_entries;

/************************************** END JA_IN_ACCOUNTING_ENTRIES **************************************************/


/***************************** JA_IN_RG_I_ENTRY *******************************************************************/

PROCEDURE ja_in_rg_I_entry(
                                p_fin_year                   NUMBER      ,
                                p_org_id                     NUMBER      ,
                                p_location_id                NUMBER      ,
                                p_inventory_item_id          NUMBER      ,
                                p_transaction_id             NUMBER      ,
                                p_transaction_date           DATE        ,
                                p_transaction_type           VARCHAR2    ,
                                p_header_id                  NUMBER      ,
                                p_excise_quantity            NUMBER      ,
                                p_excise_amount              NUMBER      ,
                                p_uom_code                   VARCHAR2    ,
                                p_excise_invoice_no          VARCHAR2    ,
                                p_excise_invoice_date        DATE        ,
                                p_payment_register           VARCHAR2    ,
                                p_basic_ed                   NUMBER      ,
                                p_additional_ed              NUMBER      ,
                                p_other_ed                   NUMBER      ,
                                p_excise_duty_rate           NUMBER      ,
                                p_customer_id                NUMBER      ,
                                p_customer_site_id           NUMBER      ,
                                p_register_code              VARCHAR2    ,
                                p_creation_date              DATE        ,
                                p_created_by                 NUMBER      ,
                                p_last_update_date           DATE        ,
                                p_last_updated_by            NUMBER      ,
                                p_last_update_login          NUMBER      ,
                                p_assessable_value           NUMBER      ,
                                p_cess_amt                   JAI_CMN_RG_I_TRXS.CESS_AMT%TYPE  DEFAULT NULL  ,
				p_sh_cess_amt                JAI_CMN_RG_I_TRXS.SH_CESS_AMT%TYPE  DEFAULT NULL  , /*Bug 5989740 bduvarag*/
                                p_source                     JAI_CMN_RG_I_TRXS.SOURCE%TYPE    DEFAULT NULL     /*Parameters p_cess_amt and p_source added by aiyer for the bug 4566054 */
                           ) IS

  --parameter for assessable value added
  v_serial_no                   NUMBER  := 0;
  v_previous_serial_no          NUMBER  := 0;
  v_range_no                    VARCHAR2(50);
  v_division_no                 VARCHAR2(50);
  v_manufactured_qty            NUMBER  := 0;
  v_manufactured_packed_qty     NUMBER  := 0;
  v_manufactured_loose_qty      NUMBER  := 0;
  v_other_purpose_n_pay_ed_qty  NUMBER  := 0;
  v_other_purpose_n_pay_ed_val  NUMBER  := 0;
  v_for_export_pay_ed_qty       NUMBER  := 0;
  v_for_export_pay_ed_val       NUMBER  := 0;
  v_for_export_n_pay_ed_qty     NUMBER  := 0;
  v_for_export_n_pay_ed_val     NUMBER  := 0;
  v_home_use_pay_ed_qty         NUMBER  := 0;
  v_home_use_pay_ed_val         NUMBER  := 0;
  v_other_purpose               VARCHAR2(25);
  v_primary_uom_code            VARCHAR2(20);
  v_balance_packed              NUMBER  := 0;
  v_balance_loose               NUMBER  := 0;
  v_packed_loose_qty            NUMBER  := 0;
  v_left_balance                NUMBER  := 0;
  v_issue_type                  VARCHAR2(10);
  v_excise_duty_amount          NUMBER; --  := p_excise_amount; --Ramananda for File.Sql.35
  v_basic_ed                    NUMBER; --  := p_basic_ed;      --Ramananda for File.Sql.35
  v_additional_ed               NUMBER; --  := p_additional_ed; --Ramananda for File.Sql.35
  v_other_ed                    NUMBER; --  := p_other_ed;      --Ramananda for File.Sql.35
  v_conversion_rate             NUMBER    := 1;
  v_assessable_value            NUMBER; -- := p_assessable_value;
  -- Commente and Added by Brathod, For Bug# 4299606 (DFF Elimination)
  -- V_ITEM_CLASS_ISSUE          MTL_SYSTEM_ITEMS.ATTRIBUTE3%TYPE;   ---- 20-APR-01  Vijay Jagdish
  V_ITEM_CLASS_ISSUE             JAI_INV_ITM_SETUPS.ITEM_CLASS%TYPE;

  -- Start, Vijay Shankar for Bug# 3408210
  v_to_other_fact_n_pay_ed_qty  NUMBER;
  v_to_other_fact_n_pay_ed_val  NUMBER;

  CURSOR c_exc_exempt_dtls(p_delivery_detail_id IN NUMBER) IS
    SELECT excise_exempt_type
    FROM JAI_OM_WSH_LINES_ALL
    WHERE delivery_detail_id = p_delivery_detail_id;
  v_exc_exempt_dtls_rec c_exc_exempt_dtls%ROWTYPE;
  -- End, Vijay Shankar for Bug# 3408210

  CURSOR primary_uom_cur IS
    SELECT primary_uom_code
    FROM mtl_system_items
    WHERE inventory_item_id = p_inventory_item_id AND
    organization_id = p_org_id;

  CURSOR serial_no_cur IS
    SELECT NVL(MAX(slno),0), (NVL(MAX(slno),0) + 1)
    FROM JAI_CMN_RG_I_TRXS
    WHERE organization_id = p_org_id AND
    location_id = p_location_id AND
    inventory_item_id = p_inventory_item_id AND
    fin_year = p_fin_year;

  CURSOR packed_loose_qty_cur(p_previous_serial_no IN NUMBER) IS
    SELECT NVL(balance_packed,0), NVL(balance_loose,0)
    FROM JAI_CMN_RG_I_TRXS
    WHERE organization_id = p_org_id AND
    location_id = p_location_id AND
    inventory_item_id = p_inventory_item_id AND
    fin_year = p_fin_year AND
    slno = p_previous_serial_no;

  CURSOR range_division_cur IS
    SELECT excise_duty_range,excise_duty_division
    FROM JAI_CMN_CUS_ADDRESSES
    WHERE customer_id = p_customer_id
    AND address_id = (SELECT cust_acct_site_id -- address_id
                      FROM hz_cust_site_uses_all A -- Removed ra_site_uses_all for Bug# 4434287
                      WHERE  A.site_use_id = p_customer_site_id);

  /***added by Jagdish and vijay on  */
  CURSOR rg_manufactured_loose_cur IS
    SELECT item_class -- Commented attribute3 by Brathod, For Bug# 4299606 (DFF Elimination)
    FROM JAI_INV_ITM_SETUPS  -- Commneted mtl_system_items by Brathod for Bug# 4299606 (DFF Elimination)
    WHERE inventory_item_id=p_inventory_item_id
    AND organization_id = p_org_id;

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_rg_I_entry';

  /*bug 9122545*/
  CURSOR c_org_addl_rg_flag (cp_organization_id jai_cmn_inventory_orgs.organization_id%type,
                              cp_location_id jai_cmn_inventory_orgs.location_id%type)
  IS
  SELECT nvl(allow_negative_rg_flag,'N')
  FROM jai_cmn_inventory_orgs
  WHERE organization_id = cp_organization_id
  AND location_id = cp_location_id;

  lv_allow_negative_rg_flag jai_cmn_inventory_orgs.allow_negative_rg_flag%type;
  /*end bug 9122545*/

/*------------------------------------------------------------------------------------------
   FILENAME: jai_om_rg_pkg.sql
   CHANGE HISTORY:
------------------------------------------------------------------------------------------
1.  2002/07/03   Nagaraj.s - For Enh#2415656.
                        The changes were done only in ja_in_pla_entry procedure.
                        2 cursors c_order_type_id and c_register_code is added.
                        and cursors pla_balance_cur,balance_cur are also changed
                          It is checked that if the Export Oriented Flag is true, then the balances
                          are populated into each component balances and if the
                          Export Oriented Unit is False, then the same coding is in place.

2.  2002/08/03      Aparajita  FOR bug # 2496388. Version#615.1
                      Accounting entries are different for internal sales order, did the changes
              in procedure ja_in_accounting_entries and modified the procedure rg23_part_ii and PLA
              to call the new procedure for accounting entries.

3.  2003/03/16       Sriram - Bug # 2796717. Version#615.2
                         Added CT3 also for the comparison on excise exempted types , because this was
                         causing the excise paid payable account to be hit instead of Cenvat Reversal account
                         for excise exempted transactions.

4.  2003/04/01      Aparajita - bug#2848921. Version#615.3
            Modified procedure ja_in_accounting_entries for iso accounting entries.
            Refer to the pocedure ja_in_accounting_entries for more details.

5.  2003/04/07      Aparajita - bug#2893284. Version#615.4
            Modified procedure ja_in_accounting_entries for iso accounting entries.
            Refer to the pocedure ja_in_accounting_entries for more details.

6.  2003/05/13      Nagaraj.s - Bug2912007 Version : 615.5
              Modified procedure ja_in_accounting_entries for iso accounting entries.
            Refer to the pocedure ja_in_accounting_entries for more details.

7.  2003/07/31      ssumaith    Bug # 2769440 - Version 616.1
                                             Added new parameters in call to the jai_cmn_gl_pkg.create_gl_entry
                                             procedure call . The parameters are added so that the values such as
                                             delivery id and other info can be displayed from the front end.

8.  2003/08/23      ssumaith   Bug # 3021588 - Version 616.2

           For Multiple Bond Register Enhancement,

           Instead of using the cursors for fetching the register associated with the order / invoice type , a call has been made to the procedures
           of the jai_cmn_bond_register_pkg package. There enhancement has created dependency because of the
           introduction of 3 new columns in the JAI_OM_OE_BOND_REG_HDRS table and also call to the new package jai_cmn_bond_register_pkg.

           New Validations for checking the bond expiry date and to check the balance based on the call to the jai_cmn_bond_register_pkg has been added

           Provision for letter of undertaking has been incorporated. In the case of the letter of undetaking , its also a type of bond register
           but without validation for the balances.
           This has been done by checking if the LOU_FLAG is 'Y' in the JAI_OM_OE_BOND_REG_HDRS table for the
           associated register id , if yes , then validation is only based on bond expiry date .

                       This fix has introduced huge dependency . All future changes in this object should have this bug as a prereq

9.  09/02/2004     Vijay Shankar for Bug# 3408210, File Version: 618.1
           JA_IN_RG_I_ENTRY procedure:- CT3 Excise Exempted Issue transaction is hitting RG1 with Home Use fields, which is wrong and code is modified
           to hit To_other_factory_n_pay_ed_qty field with quantity. transactions is identified as CT3 by fetching data from
           JAI_OM_WSH_LINES_ALL through a cursor c_exc_exempt_dtls. Insert into JAI_CMN_RG_I_TRXS is modified to populate specified columns
           in case of CT3 transaction. following fields are added in the procedure
            v_to_other_fact_n_pay_ed_qty NUMBER;
            v_to_other_fact_n_pay_ed_val NUMBER;
            v_exc_exempt_dtls_rec c_exc_exempt_dtls%ROWTYPE;

10.       13/04/2004     Aiyer for Bug#3556320  File Version 619.1
                        Issue:-
                          Quantity is populated into wrong column (column 5) for CT2 excise exemption type of transactions
              with register as Domestic_Excise in the India RG1 register report.

            Fix:-
               Modified this procedure such that in case of CT2 excise exemption and DOMESTIC_EXCISE
               register_code the fields to_other_fact_n_pay_ed_qty and to_other_fact_n_pay_ed_val
               should be populated instead of home_use_pay_ed_qty and home_use_pay_ed_val.
               and issue_type should be 'OF' instead of 'HU'

11  04/05/2004     Vijay Shankar for Bug# 3604540, File Version: 619.2
           JA_IN_RG_I_ENTRY procedure:- Order Management transactions are hitting For_home_use_pay_ed_qty and manufactured_loose_qty columns, which should
           actually hit only the first field. This is rectified by commenting the code that populates manufactured_loose_qty column

12  28/05/2004     Vijay Shankar for Bug# 3657742, File Version: 115.1
          modified Ja_In_Rg23d_Entry procedure to consider item previous year balances for opening balance calculation of
          a new transaction (happening in a new financial year). two cursor c_max_register_id and c_rg23d_rec are added
          for the purpose. also code added to make serial number as 1 if it is a first transaction of financial year or
          new item transaction

13. 25/01/2005    ssumaith - bug#4136981  File version 115.2

          Code changes done for Education cess. In case of Manual AR invoice completion and Excise invoice generation,
          Accounting entries and register entries to be hit for education cess

          This fix does not introduce dependency on this object , but this patch cannot be sent alone to the CT
          because it relies on the alter done and the new tables created as part of the education cess enhancement
          bug# 4146708 creates the objects

14. 16/02/2005    ssumaith - bug# 4185392 - File Version 115.4

          Even when cess amount is zero , still call to insert row for cess record was being done.
          This was not necessary , hence call to the procedure JAI_CMN_RG_OTHERS_pkg.insert_row was done only
          if the cess amount is a non zero value.

          Changes are made in the following places

          1. procedure ja_in_om_cess_register_entries - code change done is to add a having condition to get only those taxes where cess amount <> 0
          2. procedure ja_in_ar_cess_register_entries - same as above.

          Dependency due to this bug:-
           None


15. 16/03/2005   ssumaith - For VAT -bug#4245053 -  File Version - 115.5

          For Excise Exempted transactions , cenvat reversal account is being used to hit the cess reversal entries also.
          This is in line with the discussion with product management and support , that cenvat reversal account needs
          to be used for cess as well .

16   26/04/2005   Brathod for Bug# 4299606 File Version 116.1
                  Issue:-
                    Item DFF Elimination
                  Fix:-
                    Changed the code that references attributeN (where N=1,2,3,4,5,15) of
                    mtl_system_items to corrosponding columns in JAI_INV_ITM_SETUPS

                  Dependency :-
                    IN60106 + 4239736  (Service Tax) + 4245089  (VAT)

17. 23-Aug-2005 Aiyer - Bug 4566054 (Forward porting for the 11.5 bug 4346220 ),Version 120.4
                  Issue :-
                   Rg does not show correct cess value in case of Shipment transactions.

                  Fix:-
                  Two fields cess_amt and source have been added in JAI_CMN_RG_I_TRXS table.
                  The cess amt and source would be populated from jai_jar_t_aru_t1 (Source -> 'AR' ) and
                  as 'WSH' from jai_om_wsh.plb procedure Shipment.
                  Corresponding changes have been done in the form JAINIRGI.fmb and JAFRMRG1.rdf .
                  For shipment and Ar receivable transaction currently the transaction_id is 33 and in some cases where the jai_cmn_rg_i_trxs.ref_doc_id
                  exactly matches the jai_om_wsh_lines_all.delivery_detail_id and jai_ar_trxs.customer_trx_id the tracking of the source
                  becomes very difficult hence to have a clear demarcation between WSh and AR sources hence the source field has been added.

                  Added 2 new parametes p_cess_amt and p_source to jai_om_rg_pkg.ja_in_rg_i_entry package.
                  This has been populated from this and jai_om_wsh_pkg.process_delivery procedure.

                  A migration script has been provided to migrate the value for cess and source.

                  Dependency due to this bug:-
                  1. Datamodel change in table JAI_CMN_RG_I_TRXS, added the cess_amt and source fields
                  2. Added two new parameters in jai_om_rg_pkg.ja_in_rg_i_entry procedure to insert data into JAI_CMN_RG_I_TRXS table
                  3. Modified the trigger jai_jar_t_aru_t1
                  4. Procedure jai_om_wsh_pkg.process_delivery
                  5. Report JAICMNRG1.rdf
                  6. Created a migration script to populate cess_amt and source for Shipment and Receivable transactions.
                  Both functional and technical dependencies exists

 18.	15-Feb-2007 CSahoo Bug#5390583, File Version - 120.12
 									Forward Porting of 11i Bug 5357400
 									Issue : Excise amount not hitting bond register in functional currency.
									Fix   : Excise and cess amounts would hit bond register in functional currency.
													Changes are done in three objects.

													1. Package jai_om_rg_pkg.  - Added a parameter to the ja_in_register_txn_entry called p_currency_rate
														 It holds the currency conversion rate which would be multiplied by the transaction amts to
														 get the functional amounts.

													2. Package jai_jar_t.plb - In the call to the ja_in_register_txn_entry procedure
														 added the parameter called p_currency_code.

													3. Package - jai_ract_trg_pkg - When a change is done in the invoice currency code from the front end
														 the change is being reflected in the JAI_AR_TRXS table.

									Future Dependency due to this Bug
									------------------------
									 YES - A new parameter is added to the procedure  - ja_in_register_txn_entry in the package jai_om_rg_pkg.
									       It has a technical dependency on jai_om_rg_pkg and Package jai_jar_t.plb.
       									 It has functional dependency on jai_ract_trg.plb


19.    09/10/2007    ssumaith - bug#6487667 - File version - 120.19
                     When a sales order trx is done that hits bond register , if only excise tax is present and cess , she_cess is not present,
		     the register balance was becoming 0. It was because of an incorrect handling of null values.
		     Added nvls to the variables ln_cess_amount and ln_sh_cess_amount in the ja_in_register_txn_entry procedure.

20.    27-Nov-2009   Bug 9122545 File version 120.8.12000000.14 / 120.20.12010000.8 / 120.30
                     Description - Checked the setup option to allow negative quantity in RG register before raising the
                       error "Enough RG1 balance is not available to Issue the Goods".


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version   Current Bug    Dependent           Files                                          Version  Author   Date         Remarks
Of File                          On Bug/Patchset    Dependent On
jai_om_rg_pkg.sql
------------------------------------------------------------------------------------------------------------------------------------------------
616.2              3021588       IN60104D1 +                                                                 ssumaith  22/08/2003   Bond Register Enhancement
                                 2801751   +
                                 2769440

115.2              4136981       4146708                                                                     ssumaith  27/01/2005   Education Cess Enhancement

115.9              4299606       IN60106                                                                     brathod   26/04/2005   Item DFF Elimination
                                  + 4239736  (Service Tax)
                                  + 4245089  (VAT)

12.0              4566054                         jai_om_rg.pls                                      120.3   Aiyer     24-Aug-2005
                                                  jai_om_rg.plb                                      120.4
                                                  jai_om_wsh.plb (jai_om_wsh_pkg.process_delivery)   120.4
                                                  JAINIRGI.fmb                                       120.2
                                                  jain14.odf                                         120.3
                                                  jain14reg.ldt                                      120.3
                                                  New migration script to port data into new tables  120.0
                                                  JAICMNRG1.rdf                                      120.3
                                                  jai_jai_t.sql (trigger jai_jar_t_aru_t1)           120.1

--------------------------------------------------------------------------------------------------------------*/
BEGIN


  v_excise_duty_amount          := p_excise_amount; --Ramananda for File.Sql.35
  v_basic_ed                    := p_basic_ed;      --Ramananda for File.Sql.35
  v_additional_ed               := p_additional_ed; --Ramananda for File.Sql.35
  v_other_ed                    := p_other_ed;      --Ramananda for File.Sql.35
  v_assessable_value            := p_assessable_value; --Ramananda for File.Sql.35

  OPEN  primary_uom_cur;
  FETCH  primary_uom_cur INTO v_primary_uom_code;
  CLOSE  primary_uom_cur;

    Inv_Convert.inv_um_conversion(p_uom_code, v_primary_uom_code, p_inventory_item_id,v_conversion_rate);

  IF NVL(v_conversion_rate, 0) <= 0 THEN
    Inv_Convert.inv_um_conversion(p_uom_code, v_primary_uom_code, 0, v_conversion_rate);
    IF NVL(v_conversion_rate, 0) <= 0  THEN
      v_conversion_rate := 0;
    END IF;
  END IF;

  OPEN  RANGE_DIVISION_CUR;
    FETCH  RANGE_DIVISION_CUR INTO v_range_no,v_division_no;
    CLOSE  RANGE_DIVISION_CUR;

    IF p_register_code IN ('DOMESTIC_EXCISE') THEN

    -- Vijay Shankar for Bug# 3408210
    -- following Cursor and if condition are introduced by Vijay Shankar for Bug# 3408210 to resolve the
    -- excise exemption case
    OPEN c_exc_exempt_dtls(p_header_id);
    FETCH c_exc_exempt_dtls INTO v_exc_exempt_dtls_rec;
    CLOSE c_exc_exempt_dtls;
    -- Start of bug #3556320
    /******
     Code added by aiyer for the bug 3556320
     Changed the if condition to add 'CT2' excise_exempt_type.
     The functional requirement is that in case of CT2 excise exemption and DOMESTIC_EXCISE
     register_code the fields to_other_fact_n_pay_ed_qty and to_other_fact_n_pay_ed_val
     should be populated instead of home_use_pay_ed_qty and home_use_pay_ed_val.
     and issue_type should be 'OF' instead of 'HU'
    ******/
    IF v_exc_exempt_dtls_rec.excise_exempt_type IN ('CT3','CT2') THEN
    -- End of bug #3556320
      v_issue_type := 'OF';
      v_to_other_fact_n_pay_ed_qty := p_excise_quantity * v_conversion_rate;
      v_to_other_fact_n_pay_ed_val := round(NVL(v_assessable_value, 0) * NVL(v_to_other_fact_n_pay_ed_qty, 0),2); --added round for bug#7479016
    ELSE
      v_issue_type := 'HU';
      v_home_use_pay_ed_qty := p_excise_quantity * v_conversion_rate;
      v_home_use_pay_ed_val :=round(NVL(v_assessable_value, 0) * NVL(v_home_use_pay_ed_qty, 0),2); --added round for bug#7479016
    END IF;

  ELSIF p_register_code IN ('EXPORT_EXCISE') THEN
    v_issue_type := 'EWE';
    v_for_export_pay_ed_qty := p_excise_quantity * v_conversion_rate;
    v_for_export_pay_ed_val := round(NVL(v_assessable_value, 0) * NVL(v_for_export_pay_ed_qty, 0),2); --added round for bug#7479016
  ELSIF p_register_code IN ('BOND_REG') THEN
    v_issue_type := 'ENE';
    v_for_export_n_pay_ed_qty := p_excise_quantity * v_conversion_rate;
    v_for_export_n_pay_ed_val :=  round(NVL(v_assessable_value, 0) * NVL(v_for_export_n_pay_ed_qty, 0),2); --added round for bug#7479016
  ELSIF p_register_code IN ('DOM_WITHOUT_EXCISE') THEN
    v_issue_type := 'OPNE';
    v_other_purpose_n_pay_ed_qty := p_excise_quantity * v_conversion_rate;
    v_other_purpose_n_pay_ed_val := round(NVL(v_assessable_value, 0) * NVL(v_other_purpose_n_pay_ed_qty, 0),2); --added round for bug#7479016
    v_other_purpose := 'Domestic Without Excise';
  END IF;

  IF p_register_code NOT IN ('EXPORT_EXCISE','DOMESTIC_EXCISE') THEN
    v_excise_duty_amount := '';
  END IF;

  /*Bug 9550254 - Start*/
  /*
  OPEN serial_no_cur;
  FETCH serial_no_cur  INTO v_previous_serial_no, v_serial_no;
  CLOSE serial_no_cur;

  OPEN  packed_loose_qty_cur(v_previous_serial_no);
  FETCH  packed_loose_qty_cur INTO v_balance_packed, v_balance_loose;
  CLOSE  packed_loose_qty_cur;
  */
  /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
  v_balance_loose := ja_in_rgi_balance(p_org_id,p_location_id,p_inventory_item_id,p_fin_year,
                                       v_previous_serial_no,v_balance_packed);

  IF NVL(v_previous_serial_no,0) = 0 then
     v_serial_no := 1;
  ELSE
     v_serial_no := v_previous_serial_no + 1;
  END IF;
  /*Bug 9550254 - End*/

  v_packed_loose_qty := v_conversion_rate * NVL(p_excise_quantity,0);

  IF (v_balance_packed + v_balance_loose) >= v_packed_loose_qty THEN
    IF v_balance_loose >= v_packed_loose_qty THEN
      v_balance_loose := v_balance_loose - v_packed_loose_qty;
    ELSE
      v_balance_packed := v_balance_packed - (v_packed_loose_qty - v_balance_loose);
      v_balance_loose  := 0;
    END IF;
  ELSE

  /*bug 9122545*/
    OPEN  c_org_addl_rg_flag(p_org_id, p_location_id );
    FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag;
    CLOSE c_org_addl_rg_flag ;

    IF lv_allow_negative_rg_flag = 'Y'
    THEN
      IF v_balance_loose >= v_packed_loose_qty THEN
        v_balance_loose := v_balance_loose - v_packed_loose_qty;
      ELSE
        v_balance_packed := v_balance_packed - (v_packed_loose_qty - v_balance_loose);
        v_balance_loose  := 0;
      END IF;
    ELSIF lv_allow_negative_rg_flag = 'N'
    THEN
      RAISE_APPLICATION_ERROR(-20199, 'Enough RG1 balance is not available to Issue the Goods');
      v_left_balance := v_balance_loose + v_balance_packed;
      v_balance_loose  := 0;
      v_balance_packed := 0;
      v_packed_loose_qty := v_packed_loose_qty - v_left_balance;
      v_balance_loose := v_balance_loose - v_packed_loose_qty;
    END IF;
  /*end bug 9122545*/
  END IF;
  -----------------------------------------------------------------------------

  /* Vijay Shankar for Bug# 3604540
  OPEN rg_manufactured_loose_cur;
  FETCH rg_manufactured_loose_cur INTO V_ITEM_CLASS_ISSUE;
  CLOSE rg_manufactured_loose_cur ;

  IF p_transaction_id = 33 THEN
    IF  v_item_class_issue = 'FGIN' THEN
      v_manufactured_loose_qty := v_packed_loose_qty ;
    END IF;
    END IF;
    */

    INSERT INTO JAI_CMN_RG_I_TRXS(
                                  Register_ID                               ,
                                  Fin_Year                                  ,
                                  SLNO                                      ,
                                  Organization_id                           ,
                                  Location_id                               ,
                                  Inventory_Item_id                         ,
                                  TRANSACTION_SOURCE_NUM                    ,
                                  Transaction_Type                          ,
                                  Transaction_date                          ,
                                  REF_DOC_NO                                ,
                                  manufactured_qty                          ,
                                  manufactured_packed_qty                   ,
                                  manufactured_loose_qty                    ,
                                  other_purpose_n_pay_ed_qty                ,
                                  other_purpose_n_pay_ed_val                ,
                                  for_export_pay_ed_qty                     ,
                                  for_export_pay_ed_val                     ,
                                  for_export_n_pay_ed_qty                   ,
                                  for_export_n_pay_ed_val                   ,
                                  for_home_use_pay_ed_qty                   ,
                                  for_home_use_pay_ed_val                   ,
                                  primary_uom_code                          ,
                                  transaction_uom_code                      ,
                                  balance_packed                            ,
                                  balance_loose                             ,
                                  issue_type                                ,
                                  payment_register                          ,
                                  excise_invoice_number                     ,
                                  excise_invoice_date                       ,
                                  excise_duty_amount                        ,
                                  basic_ed                                  ,
                                  additional_ed                             ,
                                  other_ed                                  ,
                                  excise_duty_rate                          ,
                                  customer_id                               ,
                                  customer_site_id                          ,
                                  range_no                                  ,
                                  division_no                               ,
                                  creation_date                             ,
                                  created_by                                ,
                                  last_update_login                         ,
                                  last_update_date                          ,
                                  last_updated_by                           ,
                                  other_purpose                             ,
                                  to_other_factory_n_pay_ed_qty             ,
                                  to_other_factory_n_pay_ed_val             , -- Vijay Shankar for Bug# 3408210
                                  cess_amt                                  , /* The columns cess_amt and source have been added by aiyer for the bug 4566054*/
				  sh_cess_amt                                             , /*Bug 5989740 bduvarag*/
                                  source

                         ) VALUES (
                                  jai_cmn_rg_i_trxs_s.nextval               ,
                                  p_fin_year                                ,
                                  v_serial_no                               ,
                                  p_org_id                                  ,
                                  p_location_id                             ,
                                  p_inventory_item_id                       ,
                                  p_transaction_id                          ,
                                  p_transaction_type                        ,
                                  TRUNC(p_transaction_date)                 ,
                                  p_header_id                               ,
                                  round(v_manufactured_qty,5)                        ,
                                  round(v_manufactured_packed_qty ,5)                ,
                                  round(v_manufactured_loose_qty ,5)                 ,
                                  round(v_other_purpose_n_pay_ed_qty  ,5)            ,
                                  v_other_purpose_n_pay_ed_val              ,
                                  round(v_for_export_pay_ed_qty ,5)                  ,
                                  v_for_export_pay_ed_val                   ,
                                  round(v_for_export_n_pay_ed_qty  ,5)               ,
                                  v_for_export_n_pay_ed_val                 ,
                                  round(v_home_use_pay_ed_qty  ,5)                   ,
                                  v_home_use_pay_ed_val                     ,
                                  v_primary_uom_code                        ,
                                  p_uom_code                                ,
                                  round(v_balance_packed  ,5)                        ,
                                  round(v_balance_loose  ,5)                         ,
                                  v_issue_type                              ,
                                  p_payment_register                        ,
                                  p_excise_invoice_no                       ,
                                  p_excise_invoice_date                     ,
                                  v_excise_duty_amount                      ,
                                  v_basic_ed                                ,
                                  v_additional_ed                           ,
                                  v_other_ed                                ,
                                  p_excise_duty_rate                        ,
                                  p_customer_id                             ,
                                  p_customer_site_id                        ,
                                  v_range_no                                ,
                                  v_division_no                             ,
                                  p_creation_date                           ,
                                  p_created_by                              ,
                                  p_last_update_login                       ,
                                  p_last_update_date                        ,
                                  p_last_updated_by                         ,
                                  v_other_purpose                           ,
                                  round(v_to_other_fact_n_pay_ed_qty ,5)             ,
                                  round(v_to_other_fact_n_pay_ed_val   ,5)           , -- Vijay Shankar for Bug# 3408210
                                  p_cess_amt                                , /* The columns cess_amt and source have been added by aiyer for the bug 4566054*/
				  p_sh_cess_amt			    ,/*Bug 5989740 bduvarag*/
                                  p_source
                                );
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END ja_in_rg_I_entry;
/***************************** JA_IN_RG_I_ENTRY *******************************************************************/



/***************************** JA_IN_RG23_PART_I_ENTRY ****************************************************************/
   PROCEDURE ja_in_rg23_part_I_entry(p_register_type VARCHAR2,p_fin_year NUMBER, p_org_id NUMBER, p_location_id NUMBER,
    p_inventory_item_id NUMBER,p_transaction_id NUMBER, p_transaction_date DATE, p_transaction_type VARCHAR2,
      p_excise_quantity NUMBER, p_uom_code VARCHAR2, p_excise_invoice_id VARCHAR2,
    p_excise_invoice_date DATE, p_basic_ed NUMBER, p_additional_ed NUMBER,
    p_other_ed NUMBER, p_customer_id NUMBER, p_customer_site_id NUMBER,
      p_header_id VARCHAR2,/*Changes by nprashar for bug # 6710747NUMBER,*/ p_sales_invoice_date DATE, p_register_code  VARCHAR2,
      p_creation_date DATE, p_created_by NUMBER,p_last_update_date DATE,
      p_last_updated_by NUMBER, p_last_update_login NUMBER
      ) IS
   v_opening_quantity           NUMBER  := 0;
   v_closing_quantity           NUMBER  := 0;
   v_basic_ed                   NUMBER; --  := p_basic_ed;        --Ramananda for File.Sql.35
   v_additional_ed              NUMBER; --  := p_additional_ed;   --Ramananda for File.Sql.35
   v_other_ed                   NUMBER; --  := p_other_ed;        --Ramananda for File.Sql.35
   v_conversion_rate            NUMBER  := 0;
   v_previous_serial_no         NUMBER  := 0;
   v_serial_no                  NUMBER  := 0;
   v_goods_issue_id             VARCHAR2(20);
   v_primary_uom_code           VARCHAR2(20);
   v_range_no                   VARCHAR2(50);
   v_division_no                VARCHAR2(50);
   v_excise_quantity            NUMBER; --  := p_excise_quantity;  --Ramananda for File.Sql.35

   CURSOR primary_uom_cur IS
  SELECT primary_uom_code
    FROM mtl_system_items
   WHERE inventory_item_id = p_inventory_item_id AND
   organization_id = p_org_id;
   CURSOR serial_no_cur IS
     SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
       FROM JAI_CMN_RG_23AC_I_TRXS
      WHERE organization_id = p_org_id AND
      location_id = p_location_id AND
      inventory_item_id = p_inventory_item_id AND
      fin_year = p_fin_year AND
      register_type = p_register_type;
   CURSOR opening_balance_qty_cur(p_previous_serial_no IN NUMBER) IS
     SELECT NVL(opening_balance_qty,0), NVL(closing_balance_qty,0)
       FROM JAI_CMN_RG_23AC_I_TRXS
      WHERE slno = p_previous_serial_no AND
      organization_id = p_org_id AND
      location_id = p_location_id AND
      register_type = p_register_type AND
      fin_year = p_fin_year AND
      inventory_item_id = p_inventory_item_id;
   CURSOR range_division_cur IS
     SELECT excise_duty_range,excise_duty_division
       FROM JAI_CMN_CUS_ADDRESSES
      WHERE customer_id = p_customer_id
        AND    address_id = (SELECT cust_acct_site_id -- address_id
                             FROM hz_cust_site_uses_all A -- Removed ra_site_uses_all for BUg# 4434287
                            WHERE  A.site_use_id = p_customer_site_id);
   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_rg23_part_I_entry';
   BEGIN

   v_basic_ed         := p_basic_ed;        --Ramananda for File.Sql.35
   v_additional_ed    := p_additional_ed;   --Ramananda for File.Sql.35
   v_other_ed         := p_other_ed;        --Ramananda for File.Sql.35
   v_excise_quantity  := p_excise_quantity; --Ramananda for File.Sql.35

     OPEN  primary_uom_cur;
     FETCH  primary_uom_cur INTO v_primary_uom_code;
     CLOSE  primary_uom_cur;
     OPEN  RANGE_DIVISION_CUR;
     FETCH  RANGE_DIVISION_CUR INTO v_range_no,v_division_no;
     CLOSE  RANGE_DIVISION_CUR;
     Inv_Convert.inv_um_conversion(p_uom_code, v_primary_uom_code, p_inventory_item_id,v_conversion_rate);
     IF NVL(v_conversion_rate, 0) <= 0 THEN
   Inv_Convert.inv_um_conversion(p_uom_code, v_primary_uom_code, 0, v_conversion_rate);
   IF NVL(v_conversion_rate, 0) <= 0  THEN
     v_conversion_rate := 0;
     END IF;
     END IF;
     v_excise_quantity := NVL(v_excise_quantity,0) * v_conversion_rate;
     /*Bug 9550254 - Start*/
     /*
     OPEN  serial_no_cur;
     FETCH  serial_no_cur  INTO v_previous_serial_no, v_serial_no;
     CLOSE  serial_no_cur;
     */
 	 v_opening_quantity := ja_in_rg23i_balance(p_org_id,p_location_id,p_inventory_item_id,p_fin_year,p_register_type,v_previous_serial_no);
     /*Bug 9550254 - End*/
     IF NVL(v_previous_serial_no,0) = 0 THEN
       v_previous_serial_no := 0;
       v_serial_no := 1;
       -- v_opening_quantity := 0; /*Commented for Bug 9550254*/
       v_closing_quantity := v_opening_quantity - v_excise_quantity;
     ELSE
       v_serial_no := v_previous_serial_no + 1;  /*Added for Bug 9550254*/
        OPEN  opening_balance_qty_cur(v_previous_serial_no);
       FETCH  opening_balance_qty_cur INTO v_opening_quantity, v_closing_quantity;
       CLOSE  opening_balance_qty_cur;
       IF NVL(v_closing_quantity,0) = 0
       THEN
         v_opening_quantity := 0;
         v_closing_quantity := NVL(v_opening_quantity,0) - NVL(v_excise_quantity,0);
       ELSE
         v_opening_quantity := v_closing_quantity;
         v_closing_quantity := NVL(v_opening_quantity,0) - NVL(v_excise_quantity,0);
       END IF;
     END IF;
     IF p_register_code NOT IN ('EXPORT_EXCISE','DOMESTIC_EXCISE') THEN
       v_basic_ed := '';
       v_additional_ed := '';
       v_other_ed  := '';
     END IF;
     INSERT INTO JAI_CMN_RG_23AC_I_TRXS (register_id, fin_year, slno, inventory_item_id, organization_id,
            location_id, TRANSACTION_SOURCE_NUM, transaction_type, transaction_date,
            customer_id, customer_site_id, range_no, division_no,
            SALES_INVOICE_NO, sales_invoice_quantity, sales_invoice_date,
            EXCISE_INVOICE_NO, excise_invoice_date, register_type,
            transaction_uom_code, primary_uom_code, basic_ed, additional_ed,
            other_ed, opening_balance_qty, closing_balance_qty,
            creation_date,created_by,last_update_login,
            last_update_date,last_updated_by)
           VALUES(JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, p_fin_year, v_serial_no, p_inventory_item_id, p_org_id,/*rchandan for bug#4487676*/
            p_location_id, p_transaction_id, p_transaction_type, TRUNC(p_transaction_date),
            p_customer_id,p_customer_site_id,v_range_no,v_division_no,
            p_excise_invoice_id, round(v_excise_quantity,5), p_excise_invoice_date,
            p_header_id, p_sales_invoice_date, p_register_type,
            p_uom_code, v_primary_uom_code, v_basic_ed, v_additional_ed,
            v_other_ed,round( v_opening_quantity,5), round(v_closing_quantity,5),
            p_creation_date, p_created_by, p_last_update_login,
            p_last_update_date, p_last_updated_by );
   EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
   END ja_in_rg23_part_I_entry;
/***************************** JA_IN_RG23_PART_I_ENTRY ****************************************************************/


/***************************** JA_IN_RG23_PART_II_ENTRY ****************************************************************/
-- This procedure has been modified by by Aparajita on 03/08/2002 for calling the accounting entries procedure.
-- Bug # 2496388

   PROCEDURE ja_in_rg23_part_II_entry(p_register_code       VARCHAR2  , p_register_type       VARCHAR2,
                                      p_fin_year            NUMBER    , p_org_id              NUMBER  ,
                                      p_location_id         NUMBER    , p_inventory_item_id   NUMBER  ,
                                      p_transaction_id      NUMBER    , p_transaction_date    DATE    ,
                                      p_part_i_register_id  NUMBER    , p_excise_invoice_no   VARCHAR2,
                                      p_excise_invoice_date DATE      , p_dr_basic_ed         NUMBER  ,
                                      p_dr_additional_ed    NUMBER    , p_dr_other_ed         NUMBER  ,
                                      p_customer_id         NUMBER    , p_customer_site_id    NUMBER  ,
                                      p_source_name         VARCHAR2  , p_category_name       VARCHAR2,
                                      p_creation_date       DATE      , p_created_by          NUMBER  ,
                                      p_last_update_date    DATE      , p_last_updated_by     NUMBER  ,
                                      p_last_update_login   NUMBER    , p_picking_line_id     NUMBER DEFAULT NULL,
                                      p_excise_exempt_type  VARCHAR2 DEFAULT NULL,
                                      p_remarks             VARCHAR2 DEFAULT NULL ,
                                      P_REF_10              VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                                      P_REF_23              VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                                      P_REF_24              VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                                      P_REF_25              VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                                      P_REF_26              VARCHAR2 DEFAULT NULL  -- added by sriram - bug # 2769440
                                     ) IS

  v_opening_balance       NUMBER := 0;
  v_closing_balance       NUMBER := 0;
  v_account_id            NUMBER := 0;
  v_sh_cess_account_id    Number := 0;/*Bug 5989740 bduvarag*/
  v_cess_account_id       Number := 0;
  v_previous_serial_no    NUMBER := 0;
  v_serial_no             NUMBER := 0;
  v_rg_balance            NUMBER := 0;
  v_range_no              VARCHAR2(50);
  v_division_no           VARCHAR2(50);
  v_debit_account_id      NUMBER := NULL;
  v_sh_cess_debit_account_id number := NULL;/*Bug 5989740 bduvarag*/
  v_cess_debit_account_id number := NULL; /* added by ssumaith for CESS Solution*/
  v_currency_code         VARCHAR2(10) := 0;
  v_excise_amount         NUMBER := 0;
  v_ssi_unit_flag         VARCHAR2(1);
  ln_cess_amount          number;
  ln_sh_cess_amount          number;/*Bug 5989740 bduvarag*/

  CURSOR balance_cur(p_previous_serial_no IN NUMBER) IS
   SELECT NVL(opening_balance,0),NVL(closing_balance,0)
     FROM JAI_CMN_RG_23AC_II_TRXS
    WHERE organization_id = p_org_id AND
          location_id = p_location_id AND
          slno  = p_previous_serial_no AND
          register_type = p_register_type AND
          fin_year = p_fin_year;

  CURSOR rg23a_part_ii_balance_cur IS
   SELECT NVL(rg23a_balance,0)
     FROM JAI_CMN_RG_BALANCES
    WHERE organization_id = p_org_id AND
          location_id = p_location_id;

  CURSOR rg23c_part_ii_balance_cur IS
   SELECT NVL(rg23c_balance,0)
     FROM JAI_CMN_RG_BALANCES
    WHERE organization_id = p_org_id AND
          location_id = p_location_id;

  CURSOR serial_no_cur IS
     SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
       FROM JAI_CMN_RG_23AC_II_TRXS
      WHERE organization_id = p_org_id  AND
            location_id = p_location_id AND
            fin_year = p_fin_year       AND
            register_type = p_register_type;

  CURSOR range_division_cur IS
     SELECT excise_duty_range, excise_duty_division
       FROM JAI_CMN_CUS_ADDRESSES
      WHERE customer_id = p_customer_id
        AND address_id = (SELECT cust_acct_site_id  -- address_id
                          FROM   hz_cust_site_uses_all A  -- Removed ra_site_uses_all for Bug# 4434287
                          WHERE  A.site_use_id = p_customer_site_id);
  CURSOR rm_account_cur IS
  SELECT modvat_rm_account_id , excise_edu_cess_rm_account ,SH_CESS_RM_ACCOUNT/*Bug 5989740 bduvarag*/
    FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_org_id AND location_id = p_location_id;

  CURSOR cg_account_cur  IS
  SELECT modvat_cg_account_id ,  excise_edu_cess_cg_account ,SH_CESS_CG_ACCOUNT_ID/*Bug 5989740 bduvarag*/
    FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_org_id AND location_id = p_location_id;

  CURSOR debit_account_cur  IS
  SELECT EXCISE_RCVBLE_ACCOUNT  ,  CESS_PAID_PAYABLE_ACCOUNT_ID  ,  /*  CESS_PAID_PAYABLE_ACCOUNT_ID    added by ssumaith */
	  SH_CESS_PAID_PAYABLE_ACCT_ID/*Bug 5989740 bduvarag*/
    FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_org_id AND location_id = p_location_id;

  CURSOR mod_debit_acc_org IS
     SELECT MODVAT_REVERSE_ACCOUNT_ID
     FROM   JAI_CMN_INVENTORY_ORGS
     WHERE  organization_id = p_org_id
     AND    location_id = p_location_id;

  /* Bug 4931887. Added by Lakshmi Gopalsami
     Removed the references to currency_cur
     and implemented the same using the global cursor
     get_curr_code which is defined in package specification
  */


  CURSOR ssi_unit_flag_cur IS
  SELECT ssi_unit_flag
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_org_id AND
   location_id     = p_location_id;

  ln_register_id     number;

  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_rg23_part_II_entry';

  BEGIN


  OPEN   RANGE_DIVISION_CUR;
  FETCH  RANGE_DIVISION_CUR INTO v_range_no,v_division_no;
  CLOSE  RANGE_DIVISION_CUR;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' in rg pkg p_excise_exempt_type is ' || p_excise_exempt_type);

  IF p_excise_exempt_type IN ('CT2', 'EXCISE_EXEMPT_CERT','CT2_OTH', 'EXCISE_EXEMPT_CERT_OTH' ,'CT3') THEN

    -- CT3 added by sriram into the list. Bug # 2796717. 16/mar/2003
    OPEN  mod_debit_acc_org;
    FETCH mod_debit_acc_org INTO v_debit_account_id;
    CLOSE mod_debit_acc_org;
    /*
    || Bug# 4245053
    || Following line of code added by ssumaith . During VAT testing it came up , excise exempted transaction was
    || not hitting the rg register , it was showing an error that cess accounts are not defined.
    || Discussed with product management and functional team , and used their input that cenvat reversal account can be used
    */
    v_cess_debit_account_id := v_debit_account_id;
     v_sh_cess_debit_account_id := v_debit_account_id;/*Bug 5989740 bduvarag*/
  ELSE
      OPEN  debit_account_cur;
      FETCH debit_account_cur INTO v_debit_account_id , v_cess_debit_account_id,v_sh_cess_debit_account_id ; /*Bug 5989740 bduvarag*/
      CLOSE debit_account_cur;
  END IF;


  IF v_debit_account_id IS NULL THEN
      OPEN  debit_account_cur;
      FETCH  debit_account_cur INTO v_debit_account_id, v_cess_debit_account_id,v_sh_cess_debit_account_id /*Bug 5989740 bduvarag*/;
      CLOSE  debit_account_cur;
  END IF;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' debit account id is ' ||  v_debit_account_id);
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' Cess debit account id is ' ||  v_cess_debit_account_id);
  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' SH Cess debit account id is ' ||  v_sh_cess_debit_account_id);
 --Added for bug#7277543
 IF v_debit_account_id IS NULL OR v_cess_debit_account_id IS NULL OR v_sh_cess_debit_account_id IS NULL THEN
	Fnd_File.PUT_LINE(Fnd_File.LOG,  'Debit or Cess Debit or SH Cess Debit Accounts have not been setup in Organization Additional Information Screen ' );
 END IF;
 --End bug#7277543
  /* Bug 4931887. Added by Lakshmi Gopalsami
     Re-used the cursor get_curr_code for fixing perf. issue reported.
  */
  OPEN  get_curr_code(p_org_id, p_location_id);
  FETCH  get_curr_code INTO v_currency_code;
  CLOSE  get_curr_code;

  OPEN  ssi_unit_flag_cur;
  FETCH  ssi_unit_flag_cur INTO v_ssi_unit_flag;
  CLOSE  ssi_unit_flag_cur;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' p_register_type is ' || p_register_type);
  IF p_register_type = 'A' THEN
     OPEN  rm_account_cur;
     FETCH  rm_account_cur INTO v_account_id , v_cess_account_id,v_sh_cess_account_id; /*Bug 5989740 bduvarag*/
     CLOSE  rm_account_cur;
  ELSIF p_register_type = 'C' THEN
     OPEN  cg_account_cur;
     FETCH  cg_account_cur INTO v_account_id ,v_cess_account_id,v_sh_cess_account_id; /*Bug 5989740 bduvarag*/
     CLOSE  cg_account_cur;
  END IF;

  OPEN  serial_no_cur;
  FETCH  serial_no_cur  INTO v_previous_serial_no, v_serial_no;
  CLOSE  serial_no_cur;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_previous_serial_no is ' || v_previous_serial_no);
  IF NVL(v_previous_serial_no,0) = 0 THEN
    v_previous_serial_no := 0;
    v_serial_no := 1;
  END IF;

  Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_previous_serial_no is ' || v_previous_serial_no);
  IF NVL(v_previous_serial_no,0) > 0 THEN

    OPEN  balance_cur(v_previous_serial_no);
    FETCH  balance_cur INTO v_opening_balance, v_closing_balance;
    CLOSE  balance_cur;

    v_opening_balance := v_closing_balance;
    v_closing_balance := v_closing_balance - (NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0));

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' opening and closing balances : ' || v_opening_balance || ' and ' || v_closing_balance);
  IF NVL(v_closing_balance,0) < 0 THEN
      IF NVL(v_ssi_unit_flag,'N') = 'N' THEN
	  Fnd_File.PUT_LINE(Fnd_File.LOG,  'Cannot Debit more than the RG23 PART II Opening Balance ---'|| TO_CHAR(v_opening_balance)); --Added for bug#7172215
      RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the RG23 PART II Opening Balance ---'|| TO_CHAR(v_opening_balance));
      END IF;
    END IF;

  ELSE

    IF p_register_type = 'A' THEN

      OPEN  rg23a_part_ii_balance_cur;
      FETCH  rg23a_part_ii_balance_cur INTO v_rg_balance;
      CLOSE  rg23a_part_ii_balance_cur;

    ELSE
      OPEN  rg23c_part_ii_balance_cur;
      FETCH  rg23c_part_ii_balance_cur INTO v_rg_balance;
      CLOSE  rg23c_part_ii_balance_cur;
    END IF;

    v_opening_balance := NVL(v_rg_balance,0);
    v_closing_balance := NVL(v_rg_balance,0) - (NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0));

    IF v_closing_balance < 0 THEN
      IF NVL(v_ssi_unit_flag,'N') = 'N' THEN
		Fnd_File.PUT_LINE(Fnd_File.LOG,  'Cannot Debit more than the RG23 PART II Opening Balance ---'|| TO_CHAR(v_rg_balance)); --Added for bug#7172215
        RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the RG23 PART II Opening Balance '|| TO_CHAR(v_rg_balance));
      END IF;
    END IF;

  END IF;
  Fnd_File.PUT_LINE(Fnd_File.LOG,  'before insert into JAI_CMN_RG_23AC_II_TRXS');

  select  JAI_CMN_RG_23AC_II_TRXS_S.NEXTVAL
  into    ln_register_id
  from    dual;

  INSERT INTO JAI_CMN_RG_23AC_II_TRXS (register_id,
                                  fin_year,
                                  slno,
                                  inventory_item_id,
                                  organization_id,
                                  location_id,
                                  TRANSACTION_SOURCE_NUM,
                                  transaction_date,
                                  customer_id,
                                  customer_site_id,
                                  range_no,
                                  division_no,
                                  excise_invoice_no,
                                  excise_invoice_date,
                                  register_type,
                                  dr_basic_ed,
                                  dr_additional_ed,
                                  dr_other_ed,
                                  opening_balance,
                                  closing_balance,
                                  charge_account_id,
                                  register_id_part_i,
                                  creation_date,
                                  created_by,
                                  last_update_login,
                                  last_update_date,
                                  last_updated_by,
                                  remarks
                                 )
                          VALUES(
                                 ln_register_id,
                                 p_fin_year,
                                 v_serial_no,
                                 p_inventory_item_id,
                                 p_org_id,
                                 p_location_id,
                                 p_transaction_id,
                                 p_transaction_date,
                                 p_customer_id,
                                 p_customer_site_id,
                                 v_range_no,
                                 v_division_no,
                                 p_excise_invoice_no,
                                 p_excise_invoice_date,
                                 p_register_type,
                                 p_dr_basic_ed,
                                 p_dr_additional_ed,
                                 p_dr_other_ed,
                                 v_opening_balance,
                                 v_closing_balance,
                                 v_debit_account_id,
                                 p_part_i_register_id,
                                 p_creation_date,
                                 p_created_by,
                                 p_last_update_login,
                                 p_last_update_date,
                                 p_last_updated_by,
                                 p_remarks
                                );

 Fnd_File.PUT_LINE(Fnd_File.LOG,  'after insert into JAI_CMN_RG_23AC_II_TRXS');
  -- Code has been modified here by Aparajita on 08/03/2002 for bug # 2496388

  IF p_register_code <>'BOND_REG' THEN

    v_excise_amount := NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0);
    Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling  ja_in_accounting entries procedure');
    ja_in_accounting_entries
    (
    p_org_id,
    p_location_id,
    v_currency_code,
    v_excise_amount,
    p_source_name  ,
    p_category_name,
    p_created_by   ,
    p_picking_line_id,
    v_account_id,
    v_debit_account_id,
    P_REF_10,
    P_REF_23,
    P_REF_24,
    P_REF_25,
    P_REF_26
    );
    Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling  ja_in_accounting entries procedure');


    ja_in_cess_register_entries(p_register_id            => ln_register_id      ,
                                p_register_type          => p_register_type     ,
                                p_inv_orgn_id            => p_org_id            ,
                                p_je_source_name         => p_source_name       ,
                                p_je_category_name       => p_category_name     ,
                                p_source_type            => 1                   ,
                                p_currency_code          => v_currency_code     ,
                                p_transaction_hdr_id     => p_picking_line_id   , /* delivery detail id in case of om , trx line id in case of ar*/
                                p_debit_account          => v_cess_debit_account_id  ,
                                p_Credit_account         => v_cess_account_id   ,
                                p_cess_amount            => ln_cess_amount      ,
				p_cess_type              => 'EXC'               , /*Bug 5989740 bduvarag*/
                                P_REFERENCE_10           => P_REF_10            ,
                                P_REFERENCE_23           => P_REF_23            ,
                                P_REFERENCE_24           => P_REF_24            ,
                                P_REFERENCE_25           => P_REF_25            ,
                                P_REFERENCE_26           => P_REF_26
                               );



    ja_in_cess_register_entries(p_register_id            => ln_register_id      ,
                                p_register_type          => p_register_type     ,
                                p_inv_orgn_id            => p_org_id            ,
                                p_je_source_name         => p_source_name       ,
                                p_je_category_name       => p_category_name     ,
                                p_source_type            => 1                   ,
                                p_currency_code          => v_currency_code     ,
                                p_transaction_hdr_id     => p_picking_line_id   , /* delivery detail id in case of om , trx line id in case of ar*/
                                p_debit_account          => v_sh_cess_debit_account_id  ,
                                p_Credit_account         => v_sh_cess_account_id   ,
                                p_cess_amount            => ln_sh_cess_amount      ,
				p_cess_type              => 'SH'                , /*Bug 5989740 bduvarag*/
                                P_REFERENCE_10           => P_REF_10            ,
                                P_REFERENCE_23           => P_REF_23            ,
                                P_REFERENCE_24           => P_REF_24            ,
                                P_REFERENCE_25           => P_REF_25            ,
                                P_REFERENCE_26           => P_REF_26
                               );

    update JAI_CMN_RG_23AC_II_TRXS
    set    other_tax_debit = ln_cess_amount + ln_sh_cess_amount/*Bug 5989740 bduvarag*/
    where  register_id     = ln_register_id;

  END IF;

  IF p_register_type = 'A' THEN

      UPDATE  JAI_CMN_RG_BALANCES
      SET     rg23a_balance = rg23a_balance - v_excise_amount
      WHERE   organization_id = p_org_id AND
      location_id = p_location_id;

  ELSIF p_register_type = 'C' THEN

      UPDATE  JAI_CMN_RG_BALANCES
      SET  rg23c_balance = rg23c_balance - v_excise_amount
      WHERE  organization_id = p_org_id AND
      location_id = p_location_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END ja_in_rg23_part_II_entry;

/***************************** JA_IN_RG23_PART_II_ENTRY ****************************************************************/



/***************************** JA_IN_PLA_ENTRY ****************************************************************/
-- This procedure has been modified by Aparajita on 03/08/2002 for bug # 2496388 for calling the accounting entry procedure.
  PROCEDURE ja_in_pla_entry(p_org_id NUMBER,
                            p_location_id NUMBER,
                            p_inventory_item_id NUMBER,
                            p_fin_year NUMBER,
                            p_transaction_id NUMBER,
                            p_header_id  NUMBER,
                            p_ref_document_date DATE,
                            p_excise_invoice_no VARCHAR2,
                            p_excise_invoice_date DATE,
                            p_dr_basic_ed NUMBER,
                            p_dr_additional_ed NUMBER,
                            p_dr_other_ed NUMBER,
                            p_customer_id NUMBER,
                            p_customer_site_id NUMBER,
                            p_source_name VARCHAR2,
                            p_category_name VARCHAR2,
                            p_creation_date DATE,
                            p_created_by NUMBER,
                            p_last_update_date DATE,
                            p_last_updated_by NUMBER,
                            p_last_update_login NUMBER ,
                            P_REF_10 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                            P_REF_23 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                            P_REF_24 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                            P_REF_25 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
                            P_REF_26 VARCHAR2 DEFAULT NULL  -- added by sriram - bug # 2769440
                          ) IS
    v_opening_balance     NUMBER := 0;
    v_closing_balance     NUMBER := 0;
    v_rg_balance          NUMBER := 0;
    v_range_no            VARCHAR2(50);
    v_division_no         VARCHAR2(50);
    v_account_id          NUMBER;
    v_previous_serial_no  NUMBER := 0;
    v_serial_no           NUMBER := 0;
    v_debit_account_id    NUMBER := 0;
    v_debit_cess_account  NUMBER := 0;
    v_debit_sh_cess_account  NUMBER := 0;/*Bug 5989740 bduvarag*/
    ln_cess_amount        NUMBER := 0;
    ln_sh_cess_amount     NUMBER := 0;/*Bug 5989740 bduvarag*/
    v_currency_code       VARCHAR2(10) := 0;
    v_excise_amount       NUMBER := 0;
    v_ssi_unit_flag       VARCHAR2(1);

    --Variables Added by Nagaraj.s for Enhancement
    v_register_code                JAI_OM_OE_BOND_REG_HDRS.register_code%TYPE;
    v_basic_opening_balance        NUMBER;
    v_basic_closing_balance        NUMBER;
    v_additional_opening_balance   NUMBER;
    v_additional_closing_balance   NUMBER;
    v_other_opening_balance        NUMBER;
    v_other_closing_balance        NUMBER;
    v_export_oriented_unit         JAI_CMN_INVENTORY_ORGS.export_oriented_unit%TYPE;
    v_rg_basic_balance             NUMBER;
    v_rg_additional_balance        NUMBER;
    v_rg_other_balance             NUMBER;
    v_order_type_id                JAI_OM_WSH_LINES_ALL.order_type_id%TYPE;
    --Variable declaration ends here.

    v_asst_register_id Number; -- variable added by sriram - bug # 3021588

    --Changed by Nagaraj.s for Enh2415656.........
    CURSOR balance_cur(p_previous_serial_no IN NUMBER) IS
     SELECT NVL(opening_balance,0),NVL(closing_balance,0),
     NVL(basic_opening_balance,0) ,NVL(basic_closing_balance,0),
     NVL(additional_opening_balance,0) ,NVL(additional_closing_balance,0),
     NVL(other_opening_balance,0), NVL(other_closing_balance,0)
     FROM JAI_CMN_RG_PLA_TRXS
     WHERE organization_id = p_org_id AND
     location_id = p_location_id AND
     slno = p_previous_serial_no AND
     fin_year = p_fin_year;

    --Changed by Nagaraj.s for Enh#2415656..........
    CURSOR pla_balance_cur IS
     SELECT NVL(pla_balance,0),NVL(basic_pla_balance,0),
     NVL(additional_pla_balance,0), NVL(other_pla_balance,0)
     FROM JAI_CMN_RG_BALANCES
     WHERE organization_id = p_org_id AND
     location_id  = p_location_id;

    CURSOR range_division_cur IS
     SELECT excise_duty_range, excise_duty_division
     FROM JAI_CMN_CUS_ADDRESSES
     WHERE customer_id = p_customer_id
     AND    address_id = (SELECT cust_acct_site_id -- address_id
                          FROM   hz_cust_site_uses_all A -- Removed ra_site_uses_all  for Bug# 4434287
                          WHERE  A.site_use_id = p_customer_site_id);

    CURSOR serial_no_cur IS
     SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
     FROM JAI_CMN_RG_PLA_TRXS
     WHERE organization_id = p_org_id AND
   location_id  = p_location_id AND
   fin_year = p_fin_year;

     --Changed by Nagaraj.s for Enh2415656...
    CURSOR pla_account_cur IS
     SELECT MODVAT_PLA_ACCOUNT_ID,NVL(export_oriented_unit,'N')
     FROM JAI_CMN_INVENTORY_ORGS
     WHERE organization_id = p_org_id
     AND location_id = p_location_id;

    CURSOR debit_account_cur  IS
     SELECT EXCISE_RCVBLE_ACCOUNT , CESS_PAID_PAYABLE_ACCOUNT_ID, /* CESS_PAID_PAYABLE_ACCOUNT_ID added by ssumaith */
	     SH_CESS_PAID_PAYABLE_ACCT_ID/*Bug 5989740 bduvarag*/
     FROM JAI_CMN_INVENTORY_ORGS
     WHERE organization_id = p_org_id AND location_id = p_location_id;

  /* Bug 4931887. Added by Lakshmi Gopalsami
     Removed the references to currency_cur
     and implemented the same using the global cursor
     get_curr_code which is defined in package specification
  */

    CURSOR ssi_unit_flag_cur IS
     SELECT NVL(ssi_unit_flag, 'N')
     FROM   JAI_CMN_INVENTORY_ORGS
     WHERE  organization_id = p_org_id AND
   location_id     = p_location_id;

   --Cursors Added by Nagaraj.s for ENH2415656..
   CURSOR c_order_type_id IS
    SELECT order_type_id
    FROM JAI_OM_WSH_LINES_ALL
    WHERE Organization_id=p_org_id AND
    location_id = p_location_id AND
    delivery_detail_id = p_header_id;

   CURSOR c_register_code IS
    SELECT A.register_code
    FROM JAI_OM_OE_BOND_REG_HDRS A, JAI_OM_OE_BOND_REG_DTLS b
    WHERE A.organization_id = p_org_id
    AND A.location_id = p_location_id
    AND A.register_id = b.register_id
    AND b.order_flag   = 'Y'
    AND b.order_type_id = v_order_type_id ;

   /*
   ||Added By aiyer for the bug 4765347
   */
   CURSOR cur_get_pla_reg_id
   IS
   SELECT
          jai_cmn_rg_pla_trxs_s1.nextval
   FROM
          dual;

   ln_register_id JAI_CMN_RG_PLA_TRXS.REGISTER_ID%TYPE;

   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_pla_entry';

  BEGIN
    fnd_file.put_line(fnd_file.log,  '1 Start of procedure jai_om_rg_pkg.ja_in_pla_entry');
    OPEN  RANGE_DIVISION_CUR;
    FETCH  RANGE_DIVISION_CUR INTO v_range_no,v_division_no;
    CLOSE  RANGE_DIVISION_CUR;

    OPEN  pla_account_cur;
    FETCH  pla_account_cur INTO v_account_id,v_export_oriented_unit;
    CLOSE  pla_account_cur;

    OPEN  debit_account_cur;
    FETCH  debit_account_cur INTO v_debit_account_id , v_debit_cess_account,v_debit_sh_cess_account;
    CLOSE  debit_account_cur;

    /* Bug 4931887. Added by Lakshmi Gopalsami
       Re-used the cursor get_curr_code for fixing perf. issue reported.
    */
    OPEN  get_curr_code(p_org_id, p_location_id);
     FETCH  get_curr_code INTO v_currency_code;
    CLOSE  get_curr_code;

    OPEN  serial_no_cur;
    FETCH  serial_no_cur  INTO v_previous_serial_no, v_serial_no;
    CLOSE  serial_no_cur;

    OPEN  ssi_unit_flag_cur;
    FETCH  ssi_unit_flag_cur INTO v_ssi_unit_flag;
    CLOSE  ssi_unit_flag_cur;

  --Nagaraj.s
   OPEN c_order_type_id;
   FETCH c_order_type_id INTO v_order_type_id;
   CLOSE c_order_type_id;

   --sriram - bug # 3021588 and using the following procedure call instead.
    Fnd_File.PUT_LINE(Fnd_File.LOG,  '2 before call to jai_cmn_bond_register_pkg.get_register_id ');

   jai_cmn_bond_register_pkg.get_register_id (p_org_id ,
                                        p_location_id,
                                        v_order_type_id, -- order type id
                                        'Y', -- order invoice type
                                        v_asst_register_id, -- out parameter to get the register id
                                        v_register_code);

    Fnd_File.PUT_LINE(Fnd_File.LOG,  '3 after call from jai_cmn_bond_register_pkg.get_register_id ');
   IF NVL(v_previous_serial_no,0) = 0 THEN
     v_previous_serial_no := 0;
     v_serial_no := 1;
   END IF;

    Fnd_File.PUT_LINE(Fnd_File.LOG,  '4 p_org_id -> '  ||p_org_id
                          ||' ,p_location_id -> '      ||p_location_id
                          ||' ,v_order_type_id -> '    ||v_order_type_id
                          ||' ,v_asst_register_id -> ' ||v_asst_register_id
                          ||' ,v_register_code -> '    ||v_register_code
                          );
   IF NVL(v_previous_serial_no,0) > 0 THEN

     OPEN  balance_cur(v_previous_serial_no);
     FETCH  balance_cur INTO v_opening_balance, v_closing_balance,v_basic_opening_balance,
     v_basic_closing_balance, v_additional_opening_balance, v_additional_closing_balance,
     v_other_opening_balance, v_other_closing_balance;
     CLOSE  balance_cur;


     --Changed by Nagaraj.s for Enh#2415656..........
       v_opening_balance := v_closing_balance;
       v_closing_balance := v_closing_balance - (NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0));
       v_basic_opening_balance := v_basic_closing_balance;
       v_basic_closing_balance := v_basic_closing_balance - NVL(p_dr_basic_ed,0);
       v_additional_opening_balance := v_additional_closing_balance;
       v_additional_closing_balance := v_additional_closing_balance - NVL(p_dr_additional_ed,0);
       v_other_opening_balance      := v_other_closing_balance;
       v_other_closing_balance      := v_other_closing_balance - NVL(p_dr_other_ed,0);
     --Ends here....
       Fnd_File.PUT_LINE(Fnd_File.LOG,  '5 ');
     -- Check for Export Excise and EOU.............
       IF v_register_code ='EXPORT_EXCISE' AND v_export_oriented_unit='Y' THEN
         Fnd_File.PUT_LINE(Fnd_File.LOG,  '6 ');
        IF NVL(v_basic_closing_balance,0)   < 0 THEN
		 Fnd_File.PUT_LINE(Fnd_File.LOG,  'Cannot Debit more than the Basic PLA Opening Balance '|| TO_CHAR(ROUND(v_basic_opening_balance))); --Added for bug#7172215
         RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Basic PLA Opening Balance '|| TO_CHAR(ROUND(v_basic_opening_balance)));
        END IF;
        IF NVL(v_additional_closing_balance,0)   < 0 THEN
		Fnd_File.PUT_LINE(Fnd_File.LOG,   'Cannot Debit more than the Additional PLA Opening Balance '|| TO_CHAR(ROUND(v_additional_opening_balance))); --Added for bug#7172215
           RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Additional PLA Opening Balance '|| TO_CHAR(ROUND(v_additional_opening_balance)));
        END IF;

		IF NVL(v_other_closing_balance,0)   < 0 THEN
		Fnd_File.PUT_LINE(Fnd_File.LOG,   'Cannot Debit more than the Other PLA Opening Balance '|| TO_CHAR(ROUND(v_other_opening_balance))); --Added for bug#7172215
           RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Other PLA Opening Balance '|| TO_CHAR(ROUND(v_other_opening_balance)));
        END IF;

       ELSE
        IF NVL(v_closing_balance,0) < 0 THEN
         IF NVL(v_ssi_unit_flag,'N') = 'N' THEN
     	Fnd_File.PUT_LINE(Fnd_File.LOG,   'Cannot Debit more than the PLA Opening Balance '|| TO_CHAR(ROUND(v_opening_balance))); --Added for bug#7172215
        RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the PLA Opening Balance '|| TO_CHAR(ROUND(v_opening_balance)));
         END IF;
        END IF;
       END IF;
       Fnd_File.PUT_LINE(Fnd_File.LOG,  '7 ');
   ELSE
     Fnd_File.PUT_LINE(Fnd_File.LOG,  '8 ');
   --Changed by Nagaraj.s for Enh2415656....
     OPEN   pla_balance_cur;
     FETCH  pla_balance_cur INTO v_rg_balance,v_rg_basic_balance,v_rg_additional_balance,v_rg_other_balance;
     CLOSE  pla_balance_cur;

     fnd_file.put_line(fnd_file.log,  '9  v_rg_balance '
           ||' ,v_rg_basic_balance      -> '||v_rg_basic_balance
           ||' ,v_rg_additional_balance -> '||v_rg_additional_balance
           ||' ,v_rg_other_balance -> '     ||v_rg_other_balance);

     v_opening_balance := NVL(v_rg_balance,0);
     v_closing_balance := NVL(v_rg_balance,0) - (NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0));
     v_basic_opening_balance := NVL(v_rg_basic_balance,0);
     v_basic_closing_balance := NVL(v_rg_basic_balance,0) - NVL(p_dr_basic_ed,0);
     v_additional_opening_balance := NVL(v_rg_additional_balance,0);
     v_additional_closing_balance := NVL(v_rg_additional_balance,0) - NVL(p_dr_additional_ed,0);
     v_other_opening_balance := NVL(v_rg_other_balance,0);
     v_other_closing_balance := NVL(v_rg_other_balance,0) - NVL(p_dr_other_ed,0);
     IF v_register_code ='EXPORT_EXCISE' AND v_export_oriented_unit='Y' THEN
       fnd_file.put_line(fnd_file.log,  '10 ');
       IF NVL(v_basic_closing_balance,0)   < 0 THEN
	     Fnd_File.PUT_LINE(Fnd_File.LOG,  'Cannot Debit more than the Basic PLA Opening Balance '|| TO_CHAR(ROUND(v_basic_opening_balance))); --Added for bug#7172215
         RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Basic PLA Opening Balance '|| TO_CHAR(ROUND(v_basic_opening_balance)));
       END IF;

       IF NVL(v_additional_closing_balance,0)   < 0 THEN
	   	 Fnd_File.PUT_LINE(Fnd_File.LOG, 'Cannot Debit more than the Additional PLA Opening Balance '|| TO_CHAR(ROUND(v_additional_opening_balance))); --Added for bug#7172215
         RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Additional PLA Opening Balance '|| TO_CHAR(ROUND(v_additional_opening_balance)));
       END IF;

       IF NVL(v_other_closing_balance,0)   < 0 THEN
	     Fnd_File.PUT_LINE(Fnd_File.LOG, 'Cannot Debit more than the Other PLA Opening Balance '|| TO_CHAR(ROUND(v_other_opening_balance))); --Added for bug#7172215
         RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the Other PLA Opening Balance '|| TO_CHAR(ROUND(v_other_opening_balance)));
       END IF;
       fnd_file.put_line(fnd_file.log,  '11 ');
     ELSE
       fnd_file.put_line(fnd_file.log,  '12 ');
       IF v_closing_balance < 0 THEN
         IF NVL(v_ssi_unit_flag,'N') = 'N' THEN
		   Fnd_File.PUT_LINE(Fnd_File.LOG, 'Cannot Debit more than the PLA Opening Balance '|| TO_CHAR(ROUND(v_rg_balance))); --Added for bug#7172215
           RAISE_APPLICATION_ERROR(-20120, 'Cannot Debit more than the PLA Opening Balance '|| TO_CHAR(ROUND(v_rg_balance)));
         END IF;
       END IF;
     END IF;
   fnd_file.put_line(fnd_file.log,  '13 ');
   END IF;

   fnd_file.put_line(fnd_file.log,  '14 ');

   OPEN  cur_get_pla_reg_id ;
   FETCH cur_get_pla_reg_id INTO ln_register_id     ;
   CLOSE cur_get_pla_reg_id ;

   IF v_register_code ='EXPORT_EXCISE' AND v_export_oriented_unit='Y' THEN

     fnd_file.put_line(fnd_file.log,  '15 before insert into update into JAI_CMN_RG_PLA_TRXS , slno ' || v_serial_no
                                        ||'  ,register_id                 ->' ||  ln_register_id
                                        ||'  ,organization_id             ->' ||  p_org_id
                                        ||'  ,location_id                 ->' ||  p_location_id
                                        ||'  ,inventory_item_id           ->' ||  p_inventory_item_id
                                        ||'  ,fin_year                    ->' ||  p_fin_year
                                        ||'  ,TRANSACTION_SOURCE_NUM      ->' ||  p_transaction_id
                                        ||'  ,transaction_date            ->' ||  p_ref_document_date
                                        ||'  ,ref_document_id             ->' ||  p_header_id
                                        ||'  ,ref_document_date           ->' ||  p_ref_document_date
                                        ||'  ,DR_INVOICE_NO               ->' ||  p_excise_invoice_no
                                        ||'  ,dr_invoice_date             ->' ||  p_excise_invoice_date
                                        ||'  ,dr_basic_ed                 ->' ||  p_dr_basic_ed
                                        ||'  ,dr_additional_ed            ->' ||  p_dr_additional_ed
                                        ||'  ,dr_other_ed                 ->' ||  p_dr_other_ed
                                        ||'  ,vendor_cust_flag            ->' ||  'C'
                                        ||'  ,vendor_id                   ->' ||  p_customer_id
                                        ||'  ,vendor_site_id              ->' ||  p_customer_site_id
                                        ||'  ,range_no                    ->' ||  v_range_no
                                        ||'  ,division_no                 ->' ||  v_division_no
                                        ||'  ,opening_balance             ->' ||  v_opening_balance
                                        ||'  ,closing_balance             ->' ||  v_closing_balance
                                        ||'  ,charge_account_id           ->' ||  v_debit_account_id
                                        ||'  ,creation_date               ->' ||  p_creation_date
                                        ||'  ,created_by                  ->' ||  p_created_by
                                        ||'  ,last_update_login           ->' ||  p_last_update_login
                                        ||'  ,last_update_date            ->' ||  p_last_update_date
                                        ||'  ,last_updated_by             ->' ||  p_last_updated_by
                                        ||'  ,basic_opening_balance       ->' ||  v_basic_opening_balance
                                        ||'  ,basic_closing_balance       ->' ||  v_basic_closing_balance
                                        ||'  ,additional_opening_balance  ->' ||  v_additional_opening_balance
                                        ||'  ,additional_closing_balance  ->' ||  v_additional_closing_balance
                                        ||'  ,other_opening_balance       ->' ||  v_other_opening_balance
                                        ||'  ,other_closing_balance       ->' ||  v_other_closing_balance
                         );


     /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

    INSERT INTO JAI_CMN_RG_PLA_TRXS(register_id,
                         slno,
                         organization_id,
                         location_id,
                         inventory_item_id,
                         fin_year,
                         TRANSACTION_SOURCE_NUM,
                         transaction_date,
                         ref_document_id,
                         ref_document_date,
                         DR_INVOICE_NO,
                         dr_invoice_date,
                         dr_basic_ed,
                         dr_additional_ed,
                         dr_other_ed,
                         vendor_cust_flag,
                         vendor_id,
                         vendor_site_id,
                         range_no,
                         division_no,
                         opening_balance,
                         closing_balance,
                         charge_account_id,
                         creation_date,
                         created_by,
                         last_update_login,
                         last_update_date,
                         last_updated_by,
                         basic_opening_balance,
                         basic_closing_balance,
                         additional_opening_balance,
                         additional_closing_balance,
                         other_opening_balance,
                         other_closing_balance)
    VALUES
                       (
                        ln_register_id ,
                        v_serial_no,
                        p_org_id,
                        p_location_id,
                        p_inventory_item_id,
                        p_fin_year,
                        p_transaction_id,
                        p_ref_document_date,
                        p_header_id ,
                        p_ref_document_date,
                        p_excise_invoice_no,
                        p_excise_invoice_date,
                        p_dr_basic_ed,
                        p_dr_additional_ed,
                        p_dr_other_ed,
                        'C',
                        p_customer_id,
                        p_customer_site_id ,
                        v_range_no,
                        v_division_no,
                        v_opening_balance,
                        v_closing_balance,
                        v_debit_account_id,
                        p_creation_date,
                        p_created_by,
                        p_last_update_login,
                        p_last_update_date,
                        p_last_updated_by,
                        v_basic_opening_balance,
                        v_basic_closing_balance,
                        v_additional_opening_balance,
                        v_additional_closing_balance,
                        v_other_opening_balance,
                        v_other_closing_balance
                        ) returning register_id into ln_register_id;

     fnd_file.put_line(fnd_file.log,  '16 after insert into JAI_CMN_RG_PLA_TRXS');

     v_excise_amount := NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0);

     UPDATE  JAI_CMN_RG_BALANCES
      SET    pla_balance            = pla_balance - v_excise_amount,
             basic_pla_balance      = basic_pla_balance - p_dr_basic_ed,
             additional_pla_balance = NVL(additional_pla_balance,0) - NVL(p_dr_additional_ed,0),
             other_pla_balance      = NVL(other_pla_balance,0) - NVL(p_dr_other_ed,0)
      WHERE  organization_id        = p_org_id
      AND    location_id            = p_location_id;
     fnd_file.put_line(fnd_file.log,  '17 after update into JAI_CMN_RG_BALANCES');
   ELSE
     fnd_file.put_line(fnd_file.log,  '18 before insert into update into JAI_CMN_RG_PLA_TRXS , slno ' || v_serial_no
                                      ||'  , register_id             ->' ||  ln_register_id
                                      ||'  , organization_id         ->' || p_org_id
                                      ||'  , location_id             ->' || p_location_id
                                      ||'  , inventory_item_id       ->' || p_inventory_item_id
                                      ||'  , fin_year                ->' || p_fin_year
                                      ||'  , transaction_source_num  ->' || p_transaction_id
                                      ||'  , transaction_date        ->' || p_ref_document_date
                                      ||'  , ref_document_id         ->' || p_header_id
                                      ||'  , ref_document_date       ->' || p_ref_document_date
                                      ||'  , DR_INVOICE_NO           ->' || p_excise_invoice_no
                                      ||'  , dr_invoice_date         ->' || p_excise_invoice_date
                                      ||'  , dr_basic_ed             ->' || p_dr_basic_ed
                                      ||'  , dr_additional_ed        ->' || p_dr_additional_ed
                                      ||'  , dr_other_ed             ->' || p_dr_other_ed
                                      ||'  , vendor_cust_flag        ->' || 'C'
                                      ||'  , vendor_id               ->' || p_customer_id
                                      ||'  , vendor_site_id          ->' || p_customer_site_id
                                      ||'  , range_no                ->' || v_range_no
                                      ||'  , division_no             ->' || v_division_no
                                      ||'  , opening_balance         ->' || v_opening_balance
                                      ||'  , closing_balance         ->' || v_closing_balance
                                      ||'  , charge_account_id       ->' || v_debit_account_id
                                      ||'  , creation_date           ->' || p_creation_date
                                      ||'  , created_by              ->' || p_created_by
                                      ||'  , last_update_login       ->' || p_last_update_login
                                      ||'  , last_update_date        ->' || p_last_update_date
                                      ||'  , last_updated_by         ->' || p_last_updated_by
                       );

   /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    INSERT INTO JAI_CMN_RG_PLA_TRXS(
                          register_id,
                          slno,
                          organization_id,
                          location_id,
                          inventory_item_id,
                          fin_year,
                          TRANSACTION_SOURCE_NUM,
                          transaction_date,
                          ref_document_id,
                          ref_document_date,
                          DR_INVOICE_NO,
                          dr_invoice_date,
                          dr_basic_ed,
                          dr_additional_ed,
                          dr_other_ed,
                          vendor_cust_flag,
                          vendor_id,
                          vendor_site_id,
                          range_no,
                          division_no,
                          opening_balance,
                          closing_balance,
                          charge_account_id,
                          creation_date,
                          created_by,
                          last_update_login,
                          last_update_date,
                          last_updated_by
                         )
                  VALUES(
                         ln_register_id,
                         v_serial_no,
                         p_org_id,
                         p_location_id,
                         p_inventory_item_id,
                         p_fin_year,
                         p_transaction_id,
                         p_ref_document_date,
                         p_header_id ,
                         p_ref_document_date,
                         p_excise_invoice_no ,
                         p_excise_invoice_date,
                         p_dr_basic_ed,
                         p_dr_additional_ed,
                         p_dr_other_ed,
                         'C',
                         p_customer_id,
                         p_customer_site_id ,
                         v_range_no,
                         v_division_no,
                         v_opening_balance,
                         v_closing_balance,
                         v_debit_account_id,
                         p_creation_date,
                         p_created_by,
                         p_last_update_login,
                         p_last_update_date,
                         p_last_updated_by
                        ) returning register_id into ln_register_id;

     fnd_file.put_line(fnd_file.log,  '19 after insert into JAI_CMN_RG_PLA_TRXS');

     v_excise_amount := NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0);

     UPDATE  JAI_CMN_RG_BALANCES
     SET     pla_balance = pla_balance - v_excise_amount
     WHERE   organization_id = p_org_id
     AND     location_id = p_location_id;

     fnd_file.put_line(fnd_file.log,  '20 after update of JAI_CMN_RG_BALANCES');

  END IF;


  fnd_file.put_line(fnd_file.log,  '21 before call to ja_in_accounting_entries procedure ');

  ja_in_accounting_entries
  (
  p_org_id,
  p_location_id,
  v_currency_code,
  v_excise_amount,
  p_source_name  ,
  p_category_name,
  p_created_by   ,
  p_header_id,
  v_account_id,
  v_debit_account_id,
  P_REF_10,
  P_REF_23,
  P_REF_24,
  P_REF_25,
  P_REF_26
  );

  Fnd_File.PUT_LINE(Fnd_File.LOG,  'before calling  ja_in_cess_register_entries procedure');
  ja_in_cess_register_entries(
                               p_register_id          => ln_register_id      ,
                               p_register_type        => 'PLA'               ,
                               p_inv_orgn_id          => p_org_id            ,
                               p_je_source_name       => p_source_name       ,
                               p_je_category_name     => p_category_name     ,
                               p_source_type          => 2                   ,
                               p_currency_code        => v_currency_code     ,
                               p_transaction_hdr_id   => p_header_id         ,
                               p_debit_account        => v_debit_cess_account,
                               p_Credit_account       => v_account_id        ,
                               p_cess_amount          => ln_cess_amount      ,
               		       p_cess_type            => 'EXC'               ,
                               P_REFERENCE_10         => P_REF_10            ,
                               P_REFERENCE_23         => P_REF_23            ,
                               P_REFERENCE_24         => P_REF_24            ,
                               P_REFERENCE_25         => P_REF_25            ,
                               P_REFERENCE_26         => P_REF_26
                              );
/*Bug 5989740 bduvarag*/


  ja_in_cess_register_entries(
                               p_register_id          => ln_register_id      ,
                               p_register_type        => 'PLA'               ,
                               p_inv_orgn_id          => p_org_id            ,
                               p_je_source_name       => p_source_name       ,
                               p_je_category_name     => p_category_name     ,
                               p_source_type          => 2                   ,
                               p_currency_code        => v_currency_code     ,
                               p_transaction_hdr_id   => p_header_id         ,
                               p_debit_account        => v_debit_sh_cess_account,
                               p_Credit_account       => v_account_id        ,
                               p_cess_amount          => ln_sh_cess_amount      ,
         		       p_cess_type            => 'SH'               ,
                               P_REFERENCE_10         => P_REF_10            ,
                               P_REFERENCE_23         => P_REF_23            ,
                               P_REFERENCE_24         => P_REF_24            ,
                               P_REFERENCE_25         => P_REF_25            ,
                               P_REFERENCE_26         => P_REF_26
                              );
  Fnd_File.PUT_LINE(Fnd_File.LOG,  'after calling  ja_in_cess_register_entries procedure');


  update JAI_CMN_RG_PLA_TRXS
  set    other_tax_debit = ln_cess_amount  + ln_sh_cess_amount -- Date 04/06/2007 by Sacsethi for bug 6109941
  where  register_id = ln_register_id;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
      app_exception.raise_exception;
  END ja_in_pla_entry;

/***************************** JA_IN_PLA_ENTRY ****************************************************************/


/***************************** Ja_In_Rg23d_Entry ****************************************************************/
PROCEDURE Ja_In_Rg23d_Entry(
  p_register_id NUMBER,p_org_id NUMBER,p_location_id NUMBER, p_fin_year NUMBER,
  p_transaction_type VARCHAR2,p_inventory_item_id NUMBER, p_reference_line_id NUMBER,
  p_primary_uom_code VARCHAR2,p_transaction_uom_code VARCHAR2, p_customer_id NUMBER,
  p_bill_to_site_id NUMBER,p_ship_to_site_id NUMBER,p_quantity_issued NUMBER, p_register_code VARCHAR2,
  p_rate_per_unit NUMBER,p_excise_duty_rate NUMBER, p_duty_amount NUMBER, p_transaction_id NUMBER,
  p_source_name VARCHAR2, p_category_name VARCHAR2, p_receipt_id NUMBER, p_oth_receipt_id NUMBER,
  p_creation_date DATE,p_created_by NUMBER,p_last_update_date DATE,p_last_update_login NUMBER,
  p_last_updated_by NUMBER,p_dr_basic_ed NUMBER,p_dr_additional_ed NUMBER,p_dr_other_ed NUMBER,
  p_comm_invoice_no VARCHAR2,p_comm_invoice_date DATE,
  P_REF_10 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
  P_REF_23 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
  P_REF_24 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
  P_REF_25 VARCHAR2 DEFAULT NULL ,-- added by sriram - bug # 2769440
  P_REF_26 VARCHAR2 DEFAULT NULL,  -- added by sriram - bug # 2769440
  p_dr_cvd_amt NUMBER DEFAULT NULL, --Added by nprashar for bug # 5735284 added for bug#6199766
  p_dr_additional_cvd_amt NUMBER DEFAULT NULL --Added by nprashar for bug # 5735284 added for bug#6199766
) IS

  v_opening_balance NUMBER;
  v_closing_balance NUMBER;
  v_currency_code VARCHAR2(10);
  v_srno NUMBER;
  v_srno1 NUMBER;
  v_rg23d_account NUMBER;
  v_duty_amount NUMBER;
  v_excise_amount NUMBER;
  v_debit_account_id NUMBER;
  ln_cess_debit_account_id number;
  ln_sh_cess_debit_account_id number;/*Bug 5989740 bduvarag*/

  CURSOR balance_cur(p_previous_serial_no IN NUMBER) IS
    SELECT NVL(ROUND(opening_balance_qty,0),0),NVL(ROUND(closing_balance_qty,0),0)
    FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_org_id AND
    location_id = p_location_id AND
    slno  = p_previous_serial_no AND
    fin_year = p_fin_year
    AND  inventory_item_id = p_inventory_item_id;

  CURSOR serial_no_cur IS
    SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
    FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_org_id AND
    location_id = p_location_id AND
    fin_year = p_fin_year
    AND inventory_item_id = p_inventory_item_id;

  -- Start, Vijay Shankar for Bug# 3657742
  v_max_register_id NUMBER;
  CURSOR c_max_register_id( p_orgn_id IN NUMBER, p_loc_id IN NUMBER,
      p_inv_item_id IN NUMBER) IS
    SELECT max(register_id)
    FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_orgn_id
    AND location_id = p_loc_id
    AND inventory_item_id = p_inv_item_id;

  CURSOR c_rg23d_rec( p_register_id IN NUMBER) IS
    SELECT fin_year, slno, opening_balance_qty, closing_balance_qty
    FROM JAI_CMN_RG_23D_TRXS
    WHERE register_id = p_register_id;
  v_rg23d_rec   c_rg23d_rec%ROWTYPE;
  -- End, Vijay Shankar for Bug# 3657742
  /*
  CURSOR rg23d_Account IS
    SELECT EXCISE_23D_ACCOUNT
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = p_org_id AND location_id = p_location_id;

  CURSOR debit_account_cur  IS
    SELECT EXCISE_RCVBLE_ACCOUNT , CESS_PAID_PAYABLE_ACCOUNT_ID
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = p_org_id AND location_id = p_location_id;
  */
  /* Bug 4931887. Added by Lakshmi Gopalsami
     Removed the references to currency_cur
     and implemented the same using the global cursor
     get_curr_code which is defined in package specification
  */

    /*
     start ssumaith - bug#
    */
  -- get the delivery details
   CURSOR c_get_delivery_details IS
   SELECT source_header_id, source_line_id
   FROM   wsh_delivery_details
   WHERE  delivery_detail_id = p_reference_line_id;

   -- cursor to get order source id, when 10 this means that it is an internal sales order(iso)
   -- this also gets other details to link to requisition side and the from org id.
   CURSOR c_get_order_details(p_header_id NUMBER, p_line_id  NUMBER) IS
   SELECT ship_from_org_id,  order_source_id, source_document_id, source_document_line_id
   FROM   oe_order_lines_all
   WHERE  header_id = p_header_id
   AND    line_id = p_line_id;

   -- get the to organization id from the requisition details
   CURSOR c_get_to_organization(p_requisition_header_id  NUMBER, p_requisition_line_id  NUMBER) IS
   SELECT destination_organization_id , deliver_to_location_id /* deliver_to_location_id added by ssumaith - to handle trading to trading ISO */
   FROM   po_requisition_lines_all
   WHERE  requisition_header_id = p_requisition_header_id
   AND    requisition_line_id =  p_requisition_line_id;


   CURSOR c_get_iso_accounts(p_from_org_id NUMBER, p_to_org_id NUMBER) IS
   SELECT intransit_type, fob_point, interorg_receivables_account, interorg_payables_account, intransit_inv_account
   FROM   mtl_interorg_parameters
   WHERE  from_organization_id = p_from_org_id
   AND    to_organization_id =  p_to_org_id;

   CURSOR debit_account_cur( cp_organization_id JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE,
                             cp_location_id     JAI_CMN_INVENTORY_ORGS.LOCATION_ID%TYPE
                           )  IS
   SELECT excise_rcvble_account , excise_23d_account   ,excise_in_rg23d    , Trading, manufacturing
   FROM   JAI_CMN_INVENTORY_ORGS
   WHERE  organization_id = cp_organization_id
   AND    location_id     = cp_location_id;


   CURSOR c_cess_amount  IS
   SELECT sum(a.tax_amount)
   FROM   JAI_OM_WSH_LINE_TAXES a, JAI_CMN_TAXES_ALL b
   WHERE  delivery_detail_id = p_reference_line_id
   AND    a.tax_id = b.tax_id
   AND    upper(b.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS);
/*Bug 5989740 bduvarag*/
      CURSOR c_sh_cess_amount  IS
   SELECT sum(a.tax_amount)
   FROM   JAI_OM_WSH_LINE_TAXES a, JAI_CMN_TAXES_ALL b
   WHERE  delivery_detail_id = p_reference_line_id
   AND    a.tax_id = b.tax_id
   AND    upper(b.tax_type) in (JAI_CONSTANTS.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.tax_type_sh_exc_edu_cess);



   /*
    The following variables defined for cess trading to trading
   */
     ln_to_location_id                          PO_REQUISITION_LINES_ALL.DELIVER_TO_LOCATION_ID%TYPE;
     lv_dest_intransit_type                     MTL_INTERORG_PARAMETERS.INTRANSIT_TYPE%TYPE;
     ln_dest_fob_point                          MTL_INTERORG_PARAMETERS.FOB_POINT%TYPE;
     ln_dest_interorg_rcvbles_acc               MTL_INTERORG_PARAMETERS.INTERORG_RECEIVABLES_ACCOUNT%TYPE;
     ln_dest_interorg_payables_acc              MTL_INTERORG_PARAMETERS.INTERORG_PAYABLES_ACCOUNT%TYPE;
     ln_dest_intransit_inv_account              MTL_INTERORG_PARAMETERS.INTRANSIT_INV_ACCOUNT%TYPE;
     ln_src_excise_in_rg23d                     JAI_CMN_INVENTORY_ORGS.EXCISE_IN_RG23D%TYPE;
     ln_dest_excise_in_rg23d                    JAI_CMN_INVENTORY_ORGS.EXCISE_IN_RG23D%TYPE;
     lv_source_trading                          JAI_CMN_INVENTORY_ORGS.TRADING%TYPE;
     lv_dest_trading                            JAI_CMN_INVENTORY_ORGS.TRADING%TYPE;
     lv_source_manufacturing                    JAI_CMN_INVENTORY_ORGS.MANUFACTURING%TYPE;
     lv_dest_manufacturing                      JAI_CMN_INVENTORY_ORGS.MANUFACTURING%TYPE;
     ln_debit_acc                               GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE;
     ln_credit_acc                              GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE;
     ln_cess_amount                             JAI_CMN_RG_OTHERS.DEBIT%TYPE;
     ln_sh_cess_amount                          JAI_CMN_RG_OTHERS.DEBIT%TYPE;/*Bug 5989740 bduvarag*/
     ln_delivery_id                             JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE;
     v_order_header_id                          WSH_DELIVERY_DETAILS.SOURCE_HEADER_ID%TYPE;
     v_order_line_id                            WSH_DELIVERY_DETAILS.SOURCE_LINE_ID%TYPE;
     v_order_source_id                          OE_ORDER_HEADERS_ALL.ORDER_SOURCE_ID%TYPE;
     v_intransit_type                           MTL_SHIPPING_NETWORK_VIEW.INTRANSIT_TYPE%TYPE;
     v_fob_point                                MTL_SHIPPING_NETWORK_VIEW.FOB_POINT%TYPE;
     v_interorg_receivables_account             MTL_INTERORG_PARAMETERS.INTERORG_RECEIVABLES_ACCOUNT%TYPE;
     v_interorg_payables_account                MTL_INTERORG_PARAMETERS.INTERORG_PAYABLES_ACCOUNT%TYPE;
     v_intransit_inv_account                    MTL_INTERORG_PARAMETERS.INTRANSIT_INV_ACCOUNT%TYPE;
     v_from_organization_id                     WSH_DELIVERY_DETAILS.ORGANIZATION_ID%TYPE;
     v_to_organization_id                       WSH_DELIVERY_DETAILS.ORGANIZATION_ID%TYPE;
     v_excise_rcvble_account                    JAI_CMN_INVENTORY_ORGS.EXCISE_RCVBLE_ACCOUNT%TYPE;
     v_requisition_header_id                    PO_REQUISITION_LINES_ALL.REQUISITION_HEADER_ID%TYPE;
     v_requisition_line_id                      PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
     ln_src_excise_23d_account                  JAI_CMN_INVENTORY_ORGS.EXCISE_23D_ACCOUNT%TYPE;
     ln_dest_excise_23d_account                 JAI_CMN_INVENTORY_ORGS.EXCISE_23D_ACCOUNT%TYPE;
     ln_dest_excise_rcvble_account              JAI_CMN_INVENTORY_ORGS.EXCISE_RCVBLE_ACCOUNT%TYPE;

     lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_rg23d_entry';




BEGIN

  /* Bug 4931887. Added by Lakshmi Gopalsami
     Re-used the cursor get_curr_code for fixing perf. issue reported.
  */
  OPEN  get_curr_code(p_org_id, p_location_id);
  FETCH  get_curr_code INTO v_currency_code;
  CLOSE  get_curr_code;

 /* OPEN rg23d_account;
  FETCH rg23d_account INTO v_rg23d_account;
  CLOSE rg23d_account;

  OPEN debit_account_cur;
  FETCH debit_account_cur   INTO v_debit_account_id , ln_cess_debit_account_id;
  CLOSE debit_account_cur;
*/

    /* Start, Vijay Shankar for Bug# 3657742 */
    OPEN c_max_register_id(p_org_id, p_location_id, p_inventory_item_id);
    FETCH c_max_register_id into v_max_register_id;
    CLOSE c_max_register_id;

  IF v_max_register_id IS NULL THEN
    v_srno1 := 1;
    v_opening_balance := 0;
    v_closing_balance := 0;
  ELSE
    OPEN c_rg23d_rec(v_max_register_id);
    FETCH c_rg23d_rec into v_rg23d_rec;
    CLOSE c_rg23d_rec;

    IF v_rg23d_rec.fin_year <> p_fin_year THEN
      v_srno1 := 1;
    ELSE
      v_srno1 := v_rg23d_rec.slno + 1;
    END IF;

    v_opening_balance := v_rg23d_rec.opening_balance_qty;
    v_closing_balance := v_rg23d_rec.closing_balance_qty;
  END IF;
    /* End, Vijay Shankar for Bug# 3657742 */

    /* Vijay Shankar for Bug# 3657742
  OPEN serial_no_cur;
  FETCH serial_no_cur INTO v_srno,v_srno1;
  CLOSE serial_no_cur;

  OPEN  balance_cur(v_srno);
  FETCH  balance_cur INTO v_opening_balance, v_closing_balance;
  CLOSE  balance_cur;
  */

  INSERT INTO JAI_CMN_RG_23D_TRXS (
    register_id, organization_id, location_id, slno, fin_year,
    transaction_type, inventory_item_id, reference_line_id, primary_uom_code,
    transaction_uom_code, customer_id, bill_to_site_id, ship_to_site_id,
    quantity_issued, register_code, charge_account_id, rate_per_unit, excise_duty_rate,duty_amount, TRANSACTION_SOURCE_NUM,
    basic_ed, additional_ed, other_ed ,cvd, additional_cvd,  opening_balance_qty, closing_balance_qty,  /*Added CVD columns by  nprashar for bug # 5735284*/
    RECEIPT_REF, OTH_RECEIPT_ID_REF,
    creation_date, created_by,last_update_login,
    last_update_date,last_updated_by,comm_invoice_no,comm_invoice_date
  ) VALUES (
    p_register_id, p_org_id, p_location_id, v_srno1, p_fin_year,
    p_transaction_type, p_inventory_item_id, p_reference_line_id, p_primary_uom_code,
    p_transaction_uom_code, p_customer_id, p_bill_to_site_id, p_ship_to_site_id,
    p_quantity_issued, p_register_code, v_rg23d_account, p_rate_per_unit, p_excise_duty_rate,p_duty_amount, 33,
    p_dr_basic_ed, p_dr_additional_ed, p_dr_other_ed, p_dr_cvd_amt,p_dr_additional_cvd_amt,  /*Added by nprashar for bug # 5735284*/
   NVL(v_closing_balance,0), NVL(v_closing_balance,0) - NVL(p_quantity_issued,0),
    p_receipt_id, p_oth_receipt_id,
    p_creation_date, p_created_by, p_last_update_login,
    p_last_update_date, p_last_updated_by,p_comm_invoice_no,p_comm_invoice_date
  );

  v_excise_amount := NVL(p_dr_basic_ed,0) + NVL(p_dr_additional_ed,0) + NVL(p_dr_other_ed,0);

 /* Commented the code after discussing with Yadunath Bug#4171469
    IF NVL(v_rg23d_account,0)>0 AND NVL(v_debit_account_id,0) >0 THEN
    jai_cmn_gl_pkg.create_gl_entry(
      p_org_id,
      v_currency_code,
      v_excise_amount,
      0,
      v_rg23d_account,
      p_source_name,
      p_category_name,
      p_created_by,
      NULL,
      NULL,
      NULL,
      NULL,
      P_REF_10,
      P_REF_23,
      P_REF_24,
      P_REF_25,
      P_REF_26
    );

    jai_cmn_gl_pkg.create_gl_entry(
      p_org_id,
      v_currency_code,
      0,
      v_excise_amount,
      v_debit_account_id,
      p_source_name,
      p_category_name,
      p_created_by,
      NULL,
      NULL,
      NULL,
      NULL,
      P_REF_10,
      P_REF_23,
      P_REF_24,
      P_REF_25,
      P_REF_26
    );
  END IF;

  */
  /* RG23D */
  ja_in_cess_register_entries(
                                 p_register_id          => p_register_id           ,
                                 p_register_type        => 'RG23D'                 ,
                                 p_inv_orgn_id          => p_org_id                ,
                                 p_je_source_name       => p_source_name           ,
                                 p_je_category_name     => p_category_name         ,
                                 p_source_type          => 3                       ,
                                 p_currency_code        => v_currency_code         ,
                                 p_transaction_hdr_id   => p_reference_line_id     ,
                                 p_debit_account        => ln_cess_debit_account_id,
                                 p_Credit_account       => v_rg23d_account         ,
                                 p_cess_amount          => ln_cess_amount          ,
           		         p_cess_type            => 'EXC'               , /*Bug 5989740 bduvarag*/
                                 P_REFERENCE_10         => P_REF_10                ,
                                 P_REFERENCE_23         => P_REF_23                ,
                                 P_REFERENCE_24         => P_REF_24                ,
                                 P_REFERENCE_25         => P_REF_25                ,
                                 P_REFERENCE_26         => P_REF_26
                              );

  ja_in_cess_register_entries(
                                 p_register_id          => p_register_id           ,
                                 p_register_type        => 'RG23D'                 ,
                                 p_inv_orgn_id          => p_org_id                ,
                                 p_je_source_name       => p_source_name           ,
                                 p_je_category_name     => p_category_name         ,
                                 p_source_type          => 3                       ,
                                 p_currency_code        => v_currency_code         ,
                                 p_transaction_hdr_id   => p_reference_line_id     ,
                                 p_debit_account        => ln_sh_cess_debit_account_id,
                                 p_Credit_account       => v_rg23d_account         ,
                                 p_cess_amount          => ln_sh_cess_amount          ,
          		         p_cess_type            => 'SH'                     , /*Bug 5989740 bduvarag*/
                                 P_REFERENCE_10         => P_REF_10                ,
                                 P_REFERENCE_23         => P_REF_23                ,
                                 P_REFERENCE_24         => P_REF_24                ,
                                 P_REFERENCE_25         => P_REF_25                ,
                                 P_REFERENCE_26         => P_REF_26
                              );
  update JAI_CMN_RG_23D_TRXS
  set    other_tax_debit = ln_cess_amount + ln_sh_cess_amount/*Bug 5989740 bduvarag*/
  where  register_id = p_register_id;


  /*
  start ssumaith - bug#
  */

    OPEN   c_get_delivery_details;
    FETCH  c_get_delivery_details INTO v_order_header_id, v_order_line_id  ;
    CLOSE  c_get_delivery_details;

    OPEN  c_get_order_details(v_order_header_id, v_order_line_id);
    FETCH c_get_order_details INTO
              v_from_organization_id, v_order_source_id, v_requisition_header_id, v_requisition_line_id;
    CLOSE c_get_order_details;

    OPEN  c_get_to_organization(v_requisition_header_id, v_requisition_line_id);
    FETCH c_get_to_organization INTO v_to_organization_id , ln_to_location_id ;
    CLOSE c_get_to_organization;

    OPEN  c_get_iso_accounts(v_from_organization_id, v_to_organization_id);
    FETCH c_get_iso_accounts
    INTO  v_intransit_type, v_fob_point, v_interorg_receivables_account,
          v_interorg_payables_account, v_intransit_inv_account;
    CLOSE c_get_iso_accounts;

    OPEN  c_cess_amount;
    FETCH c_cess_amount INTO ln_cess_amount;
    CLOSE c_cess_amount;
/*Bug 5989740 bduvarag*/
    OPEN  c_sh_cess_amount;
    FETCH c_sh_cess_amount INTO ln_sh_cess_amount;
    CLOSE c_sh_cess_amount;

    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' in the gl_interface procedure with values as follows' );
    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_order_header_id, v_order_line_id' || v_order_header_id ||  v_order_line_id );
    Fnd_File.PUT_LINE(Fnd_File.LOG,  ' v_from_organization_id, v_order_source_id, v_requisition_header_id, v_requisition_line_id '
        || v_from_organization_id ||' , ' || v_order_source_id ||' , ' || v_requisition_header_id ||' , ' || v_requisition_line_id );

    OPEN  debit_account_cur(v_from_organization_id , p_location_id);
    FETCH debit_account_cur INTO v_excise_rcvble_account , ln_src_excise_23d_account, ln_src_excise_in_rg23d, lv_source_trading, lv_source_manufacturing ;
    CLOSE debit_account_cur;


    OPEN  debit_account_cur(v_to_organization_id , ln_to_location_id );
    FETCH debit_account_cur INTO ln_dest_excise_rcvble_account , ln_dest_excise_23d_account , ln_dest_excise_in_rg23d ,lv_dest_trading, lv_dest_manufacturing;
    CLOSE debit_account_cur;

     IF  v_order_source_id = 10 AND  /* INTERNAL SOURCE ORDER */
        (
          /*(
             NVL(lv_source_trading,'N') = 'Y' and NVL(lv_dest_trading,'N') =  'Y'
          )
          AND
          (
            NVL(ln_dest_excise_in_rg23d,'N') = 'Y' and NVL(ln_src_excise_in_rg23d,'N') = 'Y'
          )*/
          --commented the above and added the below by Ramananda for Bug#4516577
          NVL(lv_source_trading,'N') = 'Y'
          AND
          ( NVL(lv_dest_trading,'N') =  'Y' OR NVL(lv_dest_manufacturing,'N') =  'Y' )
          AND
          NVL(ln_src_excise_in_rg23d,'N') = 'Y'

        )
     THEN

          IF v_intransit_type = 2  THEN
                   -- fob point check added by Aparajita for bug#2848921, fob point 1 is shipment
                   -- credit excise paid, payable account , debit inter org receiavable account.

                   IF v_fob_point IN (1,2) THEN

                         /*
                         start additions by ssumaith for bug# 4171469 on shipment side in case of trading to trading ISO scenario.
                          Get the details of the destination organiztion such as rg23d account , excise in rg23d
                         */

                               /*
                                  write code to pass specific a/c entries for ttading to trading iso
                                  IF AN ISO TRANSACTIONS HAPPENS BETWEEN TWO TRADING ORGANIZATIONS, THEN THE FOLLOWING A/c Entries
                                  need to be passed provided both the source and destination organizations have the 'Excise in rg23D ' field
                                  set to 'Y' for the org + location combination.

                                  FOB Point => SHIPMENT
                                      Debit   Inventory Intransit A/c of Receiving org for the excise + cess amount
                                      Credit  Excise A/c of Source organization - Excise + Cess amount

                                  FOB Point => RECEIPT

                                      Debit  Inventory Intransit A/c of Source Org - Excise + Cess amt
                                      Credit Excise A/c of Source Org - Excise and Cess amt.
                               */

                               ln_debit_acc  :=  v_intransit_inv_account;
                               ln_credit_acc := ln_src_excise_23d_account;


                               jai_cmn_gl_pkg.create_gl_entry
                              (
                               p_org_id,
                               v_currency_code,
                               p_duty_amount + nvl(ln_cess_amount,0)+  nvl(ln_sh_cess_amount,0) , --Credit /*Bug 5989740 bduvarag*/
                               0, --Debit
                               ln_credit_acc,
                               p_source_name,
                               p_category_name,
                               p_created_by,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               P_REF_10,
                               P_REF_23,
                               P_REF_24,
                               P_REF_25,
                               P_REF_26);



                               jai_cmn_gl_pkg.create_gl_entry
                               (p_org_id,
                                v_currency_code,
                                0,--Credit
                                p_duty_amount + nvl(ln_cess_amount,0)+  nvl(ln_sh_cess_amount,0), --Debit /*Bug 5989740 bduvarag*/
                                ln_debit_acc,
                                p_source_name,
                                p_category_name,
                                p_created_by,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                P_REF_10,
                                P_REF_23,
                                P_REF_24,
                                P_REF_25,
                                P_REF_26
                               );


                        /*
                         ends here additions by ssumaith - bug# 4171469
                        */

          END IF;
       END IF;


     END IF;

  /*
  end ssumaith - bug#
  */

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;

END Ja_In_Rg23d_Entry;

/***************************** Ja_In_Rg23d_Entry ****************************************************************/


/***************************** JA_IN_REGISTER_TXN_ENTRY ******************************************************/
  PROCEDURE ja_in_register_txn_entry(p_org_id NUMBER,
                                     p_location_id NUMBER,
                                     p_excise_invoice_no VARCHAR2,
                                     p_transaction_name VARCHAR2,
                                     p_order_flag  VARCHAR2,
                                     p_header_id  NUMBER, /* Earlier was passing order header id */
                                     p_transaction_amount  NUMBER,
                                     p_register_code  VARCHAR2,
                                     p_creation_date DATE,
                                     p_created_by NUMBER,
                                     p_last_update_date DATE,
                                     p_last_updated_by NUMBER,
                                     p_last_update_login NUMBER ,
                                     p_order_invoice_type_id  IN NUMBER,
                                     p_currency_rate  IN NUMBER DEFAULT 1  /* added by CSahoo - bug#5390583  */
                                    )IS
  v_register_id       NUMBER;
  v_register_balance    NUMBER := 0;
  v_rg23d_register_balance  NUMBER := 0;
  v_charge_amount     NUMBER := 0;
  v_rg23d_transaction_amount  NUMBER := 0;
  v_reg_transaction_amount    NUMBER := 0;
  CURSOR  register_balance_cur IS
  SELECT  register_balance
    FROM  JAI_OM_OE_BOND_TRXS
   WHERE  transaction_id = (SELECT MAX(transaction_id) FROM JAI_OM_OE_BOND_TRXS
         WHERE  register_id = (SELECT register_id FROM JAI_OM_OE_BOND_REG_HDRS
         WHERE  organization_id = p_org_id AND location_id = p_location_id
           AND  register_code = p_register_code));
  CURSOR  register_balance_cur1 IS
  SELECT  rg23d_register_balance
    FROM  JAI_OM_OE_BOND_TRXS
   WHERE  transaction_id = (SELECT MAX(transaction_id) FROM JAI_OM_OE_BOND_TRXS
         WHERE  register_id = (SELECT register_id FROM JAI_OM_OE_BOND_REG_HDRS
         WHERE  organization_id = p_org_id AND location_id = p_location_id
           AND  register_code = p_register_code));
  CURSOR  register_id_cur IS
  SELECT  register_ID
    FROM  JAI_OM_OE_BOND_REG_HDRS
   WHERE  organization_id =  p_org_id
     AND  location_id =   p_location_id
     AND    register_code = p_register_code;


cursor   c_get_order_type(cp_header_id number) is
select   order_type_id
from     oe_order_headers_all
where    header_id = cp_header_id;

cursor   c_get_invoice_type(cp_order_header_id number) is
select   batch_source_id
from     ra_customer_trx_all
where    customer_trx_id = cp_order_header_id;

cursor   c_order_header_cur is
select   order_header_id
from     JAI_OM_WSH_LINES_ALL
where    delivery_id = p_header_id;

cursor   c_invoice_header_cur(cp_header_id number) is
select   customer_trx_id
from     JAI_AR_TRX_LINES
where    customer_trx_line_id = cp_header_id;

/*
following two cursors added by ssumaith - bug# 4136981
*/
cursor   c_get_om_cess_amount(cp_delivery_id number) is
 select   SUM(NVL(jsptl.func_tax_amount,0))  tax_amount  --NVL(sum(jsptl.func_tax_amount),0)  tax_amount  -- added , Ramananda NVL condition for bug #4516577
  from    JAI_OM_WSH_LINE_TAXES jsptl ,
          JAI_CMN_TAXES_ALL            jtc
  where   jtc.tax_id  =  jsptl.tax_id
  and     delivery_detail_id in
  (select delivery_detail_id
   from   JAI_OM_WSH_LINES_ALL
   where  delivery_id = cp_delivery_id
  )
  and   upper(jtc.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS);
  /*Bug 5989740 bduvarag*/
 cursor   c_get_om_sh_cess_amount(cp_delivery_id number) is
 select   NVL(sum(jsptl.func_tax_amount),0)  tax_amount
  from    JAI_OM_WSH_LINE_TAXES jsptl ,
          JAI_CMN_TAXES_ALL            jtc
  where   jtc.tax_id  =  jsptl.tax_id
  and     delivery_detail_id in
  (select delivery_detail_id
   from   JAI_OM_WSH_LINES_ALL
   where  delivery_id = cp_delivery_id
  )
  and   upper(jtc.tax_type) in (JAI_CONSTANTS.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.tax_type_sh_exc_edu_cess);


cursor  c_get_ar_cess_amount(cp_customer_trx_id number) is
  select  nvl(sum(jrctl.func_tax_amount),0)  tax_amount
  from    JAI_AR_TRX_TAX_LINES jrctl ,
          JAI_CMN_TAXES_ALL             jtc
  where   jtc.tax_id  =  jrctl.tax_id
  and     link_to_cust_trx_line_id in
  (select customer_trx_line_id
   from   JAI_AR_TRX_LINES
   where  customer_trx_id = cp_customer_trx_id
  )
  and upper(jtc.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS) ;
 /*Bug 5989740 bduvarag*/
 cursor  c_get_ar_sh_cess_amount(cp_customer_trx_id number) is
  select  nvl(sum(jrctl.func_tax_amount),0)  tax_amount
  from    JAI_AR_TRX_TAX_LINES jrctl ,
          JAI_CMN_TAXES_ALL             jtc
  where   jtc.tax_id  =  jrctl.tax_id
  and     link_to_cust_trx_line_id in
  (select customer_trx_line_id
   from   JAI_AR_TRX_LINES
   where  customer_trx_id = cp_customer_trx_id
  )
  and upper(jtc.tax_type) in (JAI_CONSTANTS.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.tax_type_sh_exc_edu_cess) ;

  cursor  c_ar_cess_ctr(cp_customer_trx_id number) is
    select  count(1)
    from    JAI_AR_TRX_TAX_LINES jrctl ,
            JAI_CMN_TAXES_ALL             jtc
    where   jtc.tax_id  =  jrctl.tax_id
    and     link_to_cust_trx_line_id in
    (select customer_trx_line_id
     from   JAI_AR_TRX_LINES
     where  customer_trx_id = cp_customer_trx_id
    )
    and upper(jtc.tax_type) in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS) ;
 /*Bug 5989740 bduvarag*/
   cursor  c_ar_sh_cess_ctr(cp_customer_trx_id number) is
    select  count(1)
    from    JAI_AR_TRX_TAX_LINES jrctl ,
            JAI_CMN_TAXES_ALL             jtc
    where   jtc.tax_id  =  jrctl.tax_id
    and     link_to_cust_trx_line_id in
    (select customer_trx_line_id
     from   JAI_AR_TRX_LINES
     where  customer_trx_id = cp_customer_trx_id
    )
    and upper(jtc.tax_type) in (JAI_CONSTANTS.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.tax_type_sh_exc_edu_cess) ;

 v_reg_expiry_date     JAI_OM_OE_BOND_REG_HDRS.BOND_EXPIRY_DATE%type;
v_lou_flag            JAI_OM_OE_BOND_REG_HDRS.LOU_FLAG%TYPE;
v_asst_register_id    JAI_OM_OE_BOND_REG_HDRS.register_id%type;
v_order_type_id       JAI_OM_OE_BOND_REG_DTLS.order_type_id%type;
v_register_code       JAI_OM_OE_BOND_REG_HDRS.register_code%type;
ln_header_id          number;
ln_cess_amount        number;
ln_Cess_Ctr           number;

ln_sh_cess_amount        number;/*Bug 5989740 bduvarag*/
ln_sh_Cess_Ctr           number;/*Bug 5989740 bduvarag*/

ln_customer_Trx_id    number;

lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_rg_pkg.ja_in_register_txn_entry';

  BEGIN

  if p_order_flag = 'Y' then

     open   c_order_header_cur;
     fetch  c_order_header_cur into ln_header_id;
     close  c_order_header_cur;

     open  c_get_order_type(ln_header_id);
     fetch c_get_order_type into v_order_type_id;
     close c_get_order_type;

     open  c_get_om_cess_amount(p_header_id);
     fetch c_get_om_cess_amount into ln_cess_amount;
     close c_get_om_cess_amount;
/*Bug 5989740 bduvarag*/
         open  c_get_om_sh_cess_amount(p_header_id);
     fetch c_get_om_sh_cess_amount into ln_sh_cess_amount;
     close c_get_om_sh_cess_amount;

  elsif p_order_flag = 'N' then
      v_order_type_id := p_order_invoice_type_id;

     open  c_invoice_header_cur(p_header_id);
     fetch c_invoice_header_cur into ln_customer_Trx_id;
     close c_invoice_header_cur;

     open  c_get_ar_cess_amount(ln_customer_Trx_id);
     fetch c_get_ar_cess_amount into ln_cess_amount;
     close c_get_ar_cess_amount;

     open  c_ar_cess_ctr(ln_customer_Trx_id);
     fetch c_ar_cess_ctr into ln_Cess_Ctr;
     close c_ar_cess_ctr;
     /*Bug 5989740 bduvarag start*/
      open  c_get_ar_sh_cess_amount(ln_customer_Trx_id);
     fetch c_get_ar_sh_cess_amount into ln_sh_cess_amount;
     close c_get_ar_sh_cess_amount;

     open  c_ar_sh_cess_ctr(ln_customer_Trx_id);
     fetch c_ar_sh_cess_ctr into ln_sh_Cess_Ctr;
     close c_ar_sh_cess_ctr;
/*Bug 5989740 bduvarag end*/
     ln_header_id := ln_customer_Trx_id;

     if ln_cess_amount = 0 then

        if ln_Cess_Ctr > 0 then

          for line_rec in
          (
            select customer_trx_line_id
            from   JAI_AR_TRX_LINES
            where  customer_trx_line_id = p_header_id
          )
          Loop
             for cess_rec in
             (
               select      jrctl.link_to_cust_trx_line_id,
                           jrctl.customer_trx_line_id,
                           jrctl.tax_rate,
                           jrctl.precedence_1,
                           jrctl.precedence_2,
                           jrctl.precedence_3,
                           jrctl.precedence_4,
                           jrctl.precedence_5  ,
                           jrctl.precedence_6,   -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                           jrctl.precedence_7,
                           jrctl.precedence_8,
                           jrctl.precedence_9,
                           jrctl.precedence_10
               from        JAI_AR_TRX_TAX_LINES jrctl ,
                           JAI_CMN_TAXES_ALL jtc
               where       link_to_cust_trx_line_id = line_rec.customer_trx_line_id
               and         jtc.tax_id           = jrctl.tax_id
               and         jtc.tax_type in (jai_constants.TAX_TYPE_CVD_EDU_CESS,jai_constants.TAX_TYPE_EXC_EDU_CESS)
             )
             Loop
                 for cess_amt_rec in
                 (
                   select
                          decode(tax_amount, 0,
                                                (base_tax_amount * ( tax_rate / 100) )
                                              , tax_amount
                                 ) cess_amt
                   from   JAI_AR_TRX_TAX_LINES
                   where  link_to_cust_trx_line_id = line_rec.customer_trx_line_id
                   and    tax_line_no in
                                        (cess_rec.precedence_1,
                                         cess_rec.precedence_2,
                                         cess_rec.precedence_3,
                                         cess_rec.precedence_4,
                                         cess_rec.precedence_5  ,
					 cess_rec.precedence_6,    -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                                         cess_rec.precedence_7,
                                         cess_rec.precedence_8,
                                         cess_rec.precedence_9,
                                         cess_rec.precedence_10
                                        )
                  )
                  Loop
                     ln_cess_amount := nvl(ln_cess_amount,0) +  ( nvl(cess_amt_rec.cess_amt,0) * (cess_rec.tax_rate/100 ));
                  End loop;
             End loop;
          end loop;
         ln_cess_amount := ln_cess_amount * p_currency_rate; /* ssumaith - bug#6131804 */
        end if;

     end if;
 /*Bug 5989740 bduvarag start*/
       if ln_sh_cess_amount = 0 then

        if ln_sh_Cess_Ctr > 0 then

          for line_rec in
          (
            select customer_trx_line_id
            from   JAI_AR_TRX_LINES
            where  customer_trx_line_id = p_header_id
          )
          Loop
             for cess_rec in
             (
               select      jrctl.link_to_cust_trx_line_id,
                           jrctl.customer_trx_line_id,
                           jrctl.tax_rate,
                           jrctl.precedence_1,
                           jrctl.precedence_2,
                           jrctl.precedence_3,
                           jrctl.precedence_4,
                           jrctl.precedence_5,
                           jrctl.precedence_6,
                           jrctl.precedence_7,
                           jrctl.precedence_8,
                           jrctl.precedence_9,
                           jrctl.precedence_10
               from        JAI_AR_TRX_TAX_LINES jrctl ,
                           JAI_CMN_TAXES_ALL jtc
               where       link_to_cust_trx_line_id = line_rec.customer_trx_line_id
               and         jtc.tax_id           = jrctl.tax_id
               and         jtc.tax_type in (JAI_CONSTANTS.tax_type_sh_cvd_edu_cess,JAI_CONSTANTS.tax_type_sh_exc_edu_cess)
             )
             Loop
                 for cess_amt_rec in
                 (
                   select
                          decode(tax_amount, 0,
                                                (base_tax_amount * ( tax_rate / 100) )
                                              , tax_amount
                                 ) sh_cess_amt
                   from   JAI_AR_TRX_TAX_LINES
                   where  link_to_cust_trx_line_id = line_rec.customer_trx_line_id
                   and    tax_line_no in
                    (cess_rec.precedence_1,
                     cess_rec.precedence_2,
                     cess_rec.precedence_3,
                     cess_rec.precedence_4,
                     cess_rec.precedence_5,
                     cess_rec.precedence_6,
                     cess_rec.precedence_7,
                     cess_rec.precedence_8,
                     cess_rec.precedence_9,
                     cess_rec.precedence_10
                    )
                 )
                  Loop
                     ln_sh_cess_amount := nvl(ln_sh_cess_amount,0) +  ( nvl(cess_amt_rec.sh_cess_amt,0) * (cess_rec.tax_rate/100 ));
                  End loop;
             End loop;
          end loop;
          ln_sh_cess_amount := ln_sh_cess_amount * p_currency_rate;
        end if;
     end if;
/*Bug 5989740 bduvarag end*/
  end if;

  jai_cmn_bond_register_pkg.GET_REGISTER_ID (p_org_id ,
                                       p_location_id,
                                       v_order_type_id, -- order type id
                                       p_order_flag, -- order invoice type
                                       v_asst_register_id, -- out parameter to get the register id
                                       v_register_code);

 /*
 call to get the register balance and expiry details
 */
 jai_cmn_bond_register_pkg.GET_REGISTER_DETAILS(v_asst_register_id,
                                          v_register_balance,
                                          v_reg_expiry_date,
                                          v_lou_flag);




  v_register_id := v_asst_register_id;


  /* NVLS to ln_cess_amount and ln_sh_cess_amount variables added by ssumaith - bug# 6487667*/
  IF v_register_code = 'BOND_REG'
  THEN
     v_charge_amount := v_register_balance;
     v_reg_transaction_amount := p_transaction_amount + NVL(ln_cess_amount,0) + NVL(ln_sh_cess_amount,0) ;/*Bug 5989740 bduvarag*/
  ELSIF v_register_code = '23D_EXPORT_WITHOUT_EXCISE'
  THEN
     v_charge_amount := v_rg23d_register_balance;
     v_rg23d_transaction_amount := p_transaction_amount + NVL(ln_cess_amount,0) + NVL(ln_sh_cess_amount,0);/*Bug 5989740 bduvarag*/
  END IF;




  --IF v_charge_amount >= p_transaction_amount THEN
  if  ((nvl(v_lou_flag,'N') = 'Y') or ( v_register_balance >= p_transaction_amount) )  then
    if NVL(v_reg_expiry_date,sysdate) >= p_creation_date then
      INSERT INTO JAI_OM_OE_BOND_TRXS(transaction_id,
                                     register_id ,
                                     transaction_name,
                                     order_flag,
                                     order_header_id,
                                     transaction_amount,
                                     edu_cess_amount   , /* added by ssumaith - bug# 4136981*/
				     SH_CESS_AMOUNT ,/*Bug 5989740 bduvarag*/
                                     register_balance,
                                     rg23d_register_balance,
                                     -- picking_header_id, -- bug#6650203
                                     picking_line_id, -- ssumaith bug#6650203
                                     creation_date,
                                     created_by,
                                     last_update_login,
                                     last_update_date,
                                     last_updated_by
                                    )
                             VALUES (
                                     JAI_OM_OE_BOND_TRXS_S.NEXTVAL,
                                     v_register_id,
                                     p_transaction_name,
                                     p_order_flag,
                                     ln_header_id ,
                                     p_transaction_amount,
                                     round(NVL(ln_cess_amount,0),2),
				     round(NVL(ln_sh_cess_amount,0),2)  ,/*Bug 5989740 bduvarag*/
                                     /* added by ssumaith - bug# 4136981*/
                       /* added round(2) based on support feedback for cess CSahoo - bug# 5390583 */
                                     NVL(v_register_balance - v_reg_transaction_amount,0),
                                     NVL(v_rg23d_register_balance - v_rg23d_transaction_amount, 0),
                                     -- p_excise_invoice_no, -- bug#6650203
                                     p_header_id, -- ssumaith - bug#6650203
                                     p_creation_date,
                                     p_created_by,
                                     p_last_update_login,
                                     p_last_update_date,
                                     p_last_updated_by );
   else
     Fnd_File.PUT_LINE(Fnd_File.LOG, ' Validity Period of the Bond Register has expired' ); --Added for bug#7172215
     RAISE_APPLICATION_ERROR(-20121,' Validity Period of the Bond Register has expired' );
   end if;
  ELSE
    Fnd_File.PUT_LINE(Fnd_File.LOG, 'Bonded Amount -> ' || TO_CHAR(v_charge_amount) || 'cannot be less than the transaction_amount -> ' || TO_CHAR(p_transaction_amount));  --Added for bug#7172215
    RAISE_APPLICATION_ERROR(-20120, 'Bonded Amount -> ' || TO_CHAR(v_charge_amount)
            || 'cannot be less than the transaction_amount -> '
            || TO_CHAR(p_transaction_amount));
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END ja_in_register_txn_entry;
/***************************** JA_IN_REGISTER_TXN_ENTRY *************************************************************/

/*Bug 9550254 - Start*/

/***************************** JA_IN_RGI_BALANCE *************************************************************/
 Function ja_in_rgi_balance(
                 p_organization_id in number,
                 p_location_id in number,
                 p_inventory_item_id in number,
                 p_curr_finyear in number,
                 p_slno out NOCOPY number,
                 p_balance_packed out NOCOPY number) return number
 is
 Cursor c_yearslno is
           select fin_year,max(slno)
           from JAI_CMN_RG_I_TRXS
           where   organization_id = p_organization_id
           and location_id = p_location_id
           and inventory_item_id = p_inventory_item_id
           group by fin_year
           order by fin_year desc;

 Cursor c_fetchbalance(cp_balyear number,cp_slno number) is
           select NVL(balance_packed,0), NVL(balance_loose,0)
           from JAI_CMN_RG_I_TRXS
           where   organization_id = p_organization_id
           and location_id = p_location_id
           and inventory_item_id = p_inventory_item_id
           and fin_year = cp_balyear
           and slno = cp_slno;

 v_curr_Finyear  number;
 v_Bal_Finyear   number;
 v_slno          number;
 v_balance_loose number;

 begin

   open c_yearslno;
   fetch c_yearslno into v_Bal_Finyear, v_slno;
   close c_yearslno;

   If p_curr_finyear = v_Bal_Finyear then
      p_slno :=  v_slno;
   else
      p_slno := NULL;
   END IF;

   open c_fetchbalance(v_Bal_Finyear,v_slno);
   fetch c_fetchbalance into p_balance_packed,v_balance_loose;
   close c_fetchbalance;

   p_balance_packed := nvl(p_balance_packed,0);
   return(nvl(v_balance_loose,0));

 end ja_in_rgi_balance;
/***************************** JA_IN_RGI_BALANCE *************************************************************/

/***************************** ja_in_rg23i_balance *************************************************************/
 FUNCTION ja_in_rg23i_balance(
                 p_organization_id in number,
                 p_location_id in number,
                 p_inventory_item_id in number,
                 p_curr_finyear in number,
                 p_register_type in varchar2,
                 p_slno out NOCOPY number) return number
 is
 Cursor c_yearslno is
           select fin_year,max(slno) from JAI_CMN_RG_23AC_I_TRXS
           where   organization_id = p_organization_id
           and location_id = p_location_id
           and inventory_item_id = p_inventory_item_id
           and register_type = p_register_type
           group by fin_year
           order by fin_year desc;

 Cursor c_fetchbalance(cp_balyear number,cp_slno number) is
           select NVL(closing_balance_qty, 0) closing_balance_qty
           from JAI_CMN_RG_23AC_I_TRXS
           where   organization_id = p_organization_id
           and location_id = p_location_id
           and inventory_item_id = p_inventory_item_id
           and register_type = p_register_type
           and fin_year = cp_balyear
           and slno = cp_slno;

 v_curr_Finyear  number;
 v_Bal_Finyear   number;
 v_slno          number;
 v_balance       number;

 begin

   open c_yearslno;
   fetch c_yearslno into v_Bal_Finyear, v_slno;
   close c_yearslno;

   If p_curr_finyear = v_Bal_Finyear then
      p_slno :=  v_slno;
   else
      p_slno := NULL;
   END IF;

   open c_fetchbalance(v_Bal_Finyear,v_slno);
   fetch c_fetchbalance into v_balance;
   close c_fetchbalance;

   return(nvl(v_balance,0));

 end ja_in_rg23i_balance;

/***************************** ja_in_rg23i_balance *************************************************************/

/*Bug 9550254 - End*/

END jai_om_rg_pkg;

/
