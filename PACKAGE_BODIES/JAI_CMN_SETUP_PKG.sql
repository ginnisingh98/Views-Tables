--------------------------------------------------------
--  DDL for Package Body JAI_CMN_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_SETUP_PKG" AS
/* $Header: jai_cmn_setup.plb 120.5.12010000.11 2010/04/16 12:33:52 nprashar ship $ */

PROCEDURE generate_excise_invoice_no
(
  P_ORGANIZATION_ID Number,
  P_LOCATION_ID     Number,
  P_CALLED_FROM     VARCHAR2,
  P_ORDER_INVOICE_TYPE_ID NUMBER,
  P_FIN_YEAR        Number,
  P_EXCISE_INV_NO OUT NOCOPY Varchar2,
  P_Errbuf OUT NOCOPY Varchar2
)
As

v_register_code         JAI_OM_OE_BOND_REG_HDRS.register_code%type;
v_register_meaning      ja_lookups.meaning%type;
v_order_type            ra_batch_sources_all.name%type; --Ramananda bug#4171671
v_invoice_type          ra_batch_sources_all.name%type;
v_start_number          Number;
v_prefix                JAI_CMN_RG_EXC_INV_NOS.prefix%type;
v_jump_by               Number;
v_end_number            Number;
v_ec_code           Varchar2(50);
v_master_org_flag     char(1);
v_master_organization_id  Number;
v_ec_code_gen           Char(1);
v_location_id               Number;
v_excise_inv_no             Varchar2(100);
v_gp1                       Number;
v_gp2                       Number;
v_trans_type_up             Varchar2(20);

v_act_organization_id       Number; -- these variables hold the value of organization id
v_act_location_id           Number; -- location id which will be used for excise invoice generation

/*added by vkaranam for bug #6030615*/
--start
cursor c_org_type (cp_organization_id in number , cp_location_id in number ) IS
 select manufacturing , trading
 from   jai_cmn_inventory_orgs
 where  organization_id = cp_organization_id
 and    location_id     = cp_location_id;

 r_org_type   c_org_type%rowtype;
 --end


Cursor c_Get_order_type is
select name
from   oe_transaction_types_tl
where  transaction_type_id = p_order_invoice_type_id;

Cursor c_get_invoice_type is
Select name
from   ra_batch_sources_all
where  batch_source_id = p_order_invoice_type_id;

Cursor c_get_register(p_orgn_id number,p_locn_id number,p_order_flag varchar2) is
select a.register_code
from   JAI_OM_OE_BOND_REG_HDRS a , JAI_OM_OE_BOND_REG_DTLS b
where  a.organization_id = p_orgn_id
and    a.location_id = p_locn_id
and    a.register_id = b.register_id
and    b.order_flag  = p_order_flag
and    b.order_type_id = p_order_invoice_type_id;


Cursor c_register_meaning_cur(v_lookup_code JAI_OM_OE_BOND_REG_HDRS.register_code%type, cp_lookup_type ja_lookups.lookup_type%type) is
SELECT meaning
FROM   ja_lookups
WHERE  lookup_type = cp_lookup_type --'JAI_REGISTER_TYPE'   /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
AND    lookup_code = v_lookup_code;

Cursor c_def_excise_cur(p_orgn_id Number , p_loc_id number) is
Select start_number , prefix , jump_by , end_number
From   JAI_CMN_RG_EXC_INV_NOS
where  organization_id    = p_orgn_id
and    location_id        = p_loc_id
and    fin_year           = p_fin_year
and    order_invoice_type = v_order_type
and    register_code      = v_register_meaning
for update;

CURSOR c_Tr_ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
SELECT A.Organization_Id, A.Location_Id
FROM   JAI_CMN_INVENTORY_ORGS A
WHERE  A.Tr_Ec_Code IN
(
 SELECT B.Tr_Ec_Code
 FROM   JAI_CMN_INVENTORY_ORGS B
 WHERE  B.Organization_Id = p_organization_id
 AND    B.Location_Id     = p_location_id
);

/* Removed below condition as EXCISE_INVNO_AT_EC_CODE flag is not for trading organization, JMEENA for bug#7719911
--AND  nvl(EXCISE_INVNO_AT_EC_CODE, 'N') = 'Y'  --Added by nprashar for bug # 7319628;
*/
CURSOR c_ec_code_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER) IS
SELECT A.Organization_Id, A.Location_Id
FROM   JAI_CMN_INVENTORY_ORGS A
WHERE  A.Ec_Code IN
(
 SELECT B.Ec_Code
 FROM   JAI_CMN_INVENTORY_ORGS B
 WHERE  B.Organization_Id = p_organization_id
 AND    B.Location_Id     = p_location_id
)
 AND  nvl(EXCISE_INVNO_AT_EC_CODE, 'N') = 'Y' /*Added by nprashar for bug # 7319628*/;


Cursor c_excise_cur(p_orgn_id Number , p_loc_id number) is
Select nvl(gp1,0) , nvl(gp2,0)
From   JAI_CMN_RG_EXC_INV_NOS
where  organization_id    = p_orgn_id
and    location_id        = p_loc_id
and    fin_year           = p_fin_year
AND    order_invoice_type IS NULL
AND    register_code      IS NULL;


Cursor c_master_org is
Select ec_code , master_org_flag , master_organization_id, EXCISE_INVNO_AT_EC_CODE
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = p_organization_id
and    location_id = p_location_id;


Cursor c_mstr_org(p_orgn_id Number, p_ec_code Varchar2) is
select organization_id , EXCISE_INVNO_AT_EC_CODE , location_id
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = p_orgn_id
and    ec_code = p_ec_code
and    master_org_flag = 'Y';

--JMEENA for bug#7719911 FP of bug#7505975
Cursor c_master_trade_org is
Select tr_ec_code , master_org_flag , master_organization_id
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = p_organization_id
and    location_id = p_location_id;


Cursor c_trade_org(p_orgn_id Number, p_ec_code Varchar2) is
select organization_id  , location_id
from   JAI_CMN_INVENTORY_ORGS
where  organization_id = p_orgn_id
and    tr_ec_code = p_ec_code
and    master_org_flag = 'Y';

r_master_trade_org   c_master_trade_org%rowtype;

--end for bug#7719911 FP of bug#7505975

BEGIN

--Change History :
/*************************************************************************************************************
File Name : ja_in_excise_invoice_no_gen_p.sql

 Slno  Date               Description

  1    26/075/2005 Ramananda for bug#4514367. File Version 120.2
                RTV Invoice number should be generated based on additional info setup.
                 The following should be the RTV behaviour:

                 1. When Excise Invoice sequence setup for RTV is specifically done, then RTV
                    Excise Invoice sequence is picked up from this setup.
                 2. When no specific setup for RTV Excise Invoice sequence is made, Excise
                    Invoice should be generated from the Domestic series.
                 3.If this setup is also missing then it should pick from GP1 respectively.

                 Its observed that Invoice is picked based on additional info setup for RTV else from
                 GP1 of ja_in_excise_invoice_no.It was not considering the Domestic Series.

                 Fix:
                 ----
                 Code for considering Domestic series when RTV setup is present has been added.Actually
                 Manual RG23 uses domestic series. So the same code is used if RTV setup is absent and
                 Domestic is present.

2  24/04/2007   Vijay Shankar for Bug# 6012570 (5876390), Version:120.4 (115.10)
                       FP: Modified the code to generate excise invoice number for Projects Billing.

3.  28-Jan-2009  JMEENA for bug#7719911
				1) Removed the condition of EXCISE_INVNO_AT_EC_CODE flag from cursor c_tr_ec_code_cur as this should not be checked for trading organizations.
				2) Added if condition to update table JAI_CMN_RG_EXC_INV_NOS for the records where EXCISE_INVNO_AT_EC_CODE = 'N'
					for the manufacturing organizations because such records will not be fetched by cursor c_ec_code_cur so invoice number
					will not be updated to next number for that organization.
				3) FP of bug#7505975
					Issue: Excise Invoice Number for a Trading organization with Master-- Child setup
						 is not using its Master Organization Excise sequence defined.
					Fix: Changes are done to ensure that Trading Org with master- child relation ship will use the
						 master org excise sequence.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

--------------------------------------------------------------------------------------------------------------
Version       Bug         Dependencies
---------------------------------------------------------------------------------------------------------------
616.1         3071342     IN60104D1
619.1         3439480     No dependencies introduced - IN60105D2

*************************************************************************************************************/
fnd_file.put_line(fnd_file.log,'Starting Excise Invoice Generation Prg');--bug#7719911
--start for bug#7719911 FP of 7505975, JMEENA
OPEN c_org_type (p_organization_id , p_location_id);
fetch c_org_type into r_org_type;
CLOSe c_org_type;
 fnd_file.put_line(fnd_file.log,'Manufacturing Organization --> '||r_org_type.manufacturing
                                || '  Trading Organization  -->'||r_org_type.trading);--7507579
if nvl(r_org_type.manufacturing,'N')='Y' --bug#7719911
then

-- code to get the organization id location id of the master org
Open  c_master_org;
Fetch c_master_org into v_ec_code , v_master_org_flag,v_master_organization_id,v_ec_code_gen;
Close c_master_org;

if upper(v_master_org_flag) = 'Y' then

  -- the transacting organization is the master org
  v_act_organization_id := p_organization_id;
  v_act_location_id     := p_location_id;
  fnd_File.PUT_LINE(Fnd_File.LOG,'  Inside Master Org Flag = Y');
  fnd_File.PUT_LINE(Fnd_File.LOG,'  Organziation Id :  '|| v_act_organization_id);
  fnd_File.PUT_LINE(Fnd_File.LOG,'  Location Id:  '|| v_act_location_id);

else

   -- this is not the master org. get the master org for this org

  if v_master_organization_id is not null then
    -- we have the master organization id for the transacting organization.
    -- need to get the location id of the master org organization id , where the master org flag is 'Y'

    Open  c_mstr_org(v_master_organization_id,v_ec_code);
    fetch c_mstr_org into v_master_organization_id,v_ec_code_gen,v_location_id;
    close c_mstr_org;

    if NVL(v_ec_code_gen,'N') = 'Y' then

      -- use the master org setup to generate the excise invo no
      -- which means use the v_master_organization_id  v_location_id fields as retreived previously.
      v_act_organization_id := v_master_organization_id;
      v_act_location_id     := v_location_id;

      fnd_File.PUT_LINE(Fnd_File.LOG,'  Inside ECCode gen = Y');
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Organziation Id :  '|| v_act_organization_id);
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Location Id:  '|| v_act_location_id);

    else

      -- need to use the transacting organizations organization id and location id
      -- for generating excise invoice number.
      v_act_organization_id := p_organization_id;
      v_act_location_id     := p_location_id;

      fnd_File.PUT_LINE(Fnd_File.LOG,'  Else of ECCode gen');
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Organziation Id :  '|| v_act_organization_id);
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Location Id:  '|| v_act_location_id);

    end if;

    -- now we have got the organization id,location id of the master org of this transacting org
    -- and also whether excise invoice generation should be based at master org level .

  ELSE
     /* Bug 5365346. Added by Lakshmi Gopalsami
      * Assigned the value of p_organization_id and p_location_id.
      * This is required for generating Excise invoice number Else
      * the value is coming as NULL.
      */
      v_act_organization_id := p_organization_id;
      v_act_location_id     := p_location_id;
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Else of Master organization id is not null ');
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Organziation Id :  '|| v_act_organization_id);
      fnd_File.PUT_LINE(Fnd_File.LOG,'  Location Id:  '|| v_act_location_id);

  end if;  -- v_master_organization_id is not null then


end if; -- upper(v_master_org_flag) = 'Y'

--start for bug#7719911 FP of 7505975
elsif  nvl(r_org_type.trading,'N')='Y'   then
         Open  c_master_trade_org;
        Fetch c_master_trade_org into r_master_trade_org ;
        Close c_master_trade_org;
       fnd_file.put_line(fnd_file.log,'Master org flag --> '||r_master_trade_org.master_org_flag   ||
                                 ' Master Organization   -->'||nvl(r_master_trade_org.master_organization_id,p_organization_id)||
                                 ' Ec Code --> '||r_master_trade_org.tr_ec_code
                                 );--7507579
        if upper(r_master_trade_org.master_org_flag) = 'Y' then

          -- the transacting organization is the master org
          v_act_organization_id := p_organization_id;
          v_act_location_id     := p_location_id;

        else

         if r_master_trade_org.master_organization_id is not null then
            -- we have the master organization id for the transacting organization.
            -- need to get the location id of the master org organization id , where the master org flag is 'Y'

            Open  c_trade_org(r_master_trade_org.master_organization_id,r_master_trade_org.tr_ec_code);
            fetch c_trade_org into v_master_organization_id,v_location_id;
            close c_trade_org;


              v_act_organization_id := v_master_organization_id;
              v_act_location_id     := v_location_id;
         else
             v_act_organization_id := p_organization_id;
              v_act_location_id     := p_location_id;

         end if;
       end if;

 end if;
--end bug#7719911 FP of 7505975

fnd_file.put_line(fnd_file.log,'Organization used for Excise Invoice Sequence '||  v_act_organization_id);--7719911
-- when the control comes here , we should have the organization id , location id , fin year , register type
-- and order invoice type , so that excise invoice number logic can be simple

IF P_CALLED_FROM = 'O' then -- if it is called from OM

  Open  c_get_register(v_act_organization_id,v_act_location_id,'Y');
  Fetch c_get_register into v_register_code;
  close c_get_register;

  Open  c_Get_order_type;
  Fetch c_Get_order_type into v_order_type;
  Close c_Get_order_type;

ELSIF P_CALLED_FROM = 'I' then  -- if it is called from AR

  Open  c_get_invoice_type;
  Fetch c_get_invoice_type into v_order_type;
  close c_get_invoice_type;

  Open  c_get_register(v_act_organization_id,v_act_location_id,'N');
  Fetch c_get_register into v_register_code;
  close c_get_register;

End if;

if  v_register_code is not null then

  Open  c_register_meaning_cur(v_register_code, 'JAI_REGISTER_TYPE');
  Fetch c_register_meaning_cur into v_register_meaning;
  Close c_register_meaning_cur;

elsif P_CALLED_FROM = 'P' then
  -- in the case of RTV transactions , the value 'RTV' is hard coded in the JAI_CMN_RG_EXC_INV_NOS
  -- when preferences are setup for a RTV transaction.
  v_register_code := 'RTV';
  v_order_type := 'RTV';
  v_register_meaning := 'RTV';


End if;

--  the following update was written to lock all the records that will
--  get updated after excise invoice generation has occured and  this is used to prevent a deadlock.

Fnd_File.PUT_LINE(Fnd_File.LOG,'Before update time is ' || to_char(sysdate,'dd-mon-yyyy hh:mi:ss'));

update  JAI_CMN_RG_EXC_INV_NOS
set   last_update_date = last_update_date
where   fin_year           = p_fin_year
AND     order_invoice_type IS NULL
AND     register_code      IS NULL
and     (organization_id, location_id)
      in
    (SELECT A.Organization_Id, A.Location_Id
     FROM   JAI_CMN_INVENTORY_ORGS A
     WHERE  A.Ec_Code IN
       (
         SELECT B.Ec_Code
         FROM   JAI_CMN_INVENTORY_ORGS B
         WHERE  B.Organization_Id = v_act_organization_id
         AND    B.Location_Id     = v_act_location_id
       )
      );

Fnd_File.PUT_LINE(Fnd_File.LOG,'After update time is ' || to_char(sysdate,'dd-mon-yyyy hh:mi:ss'));

-- using the following cursor we get gp1 and gp2 values which can be used
Open  c_excise_cur(v_act_organization_id, v_act_location_id);
fetch c_excise_cur into v_gp1,v_gp2;
close c_excise_cur;


-- using the following cursor , we get start number and other values
-- to be used when register type and order type exist.
Open  c_def_excise_cur(v_act_organization_id,v_act_location_id);
Fetch c_def_excise_cur into v_start_number , v_prefix , v_jump_by , v_end_number;
close c_def_excise_cur;


if v_start_number is not null then

  if v_end_number is not null then

      if ((v_start_number + nvl(v_jump_by,1)) > v_end_number ) then

          RAISE_APPLICATION_ERROR(-20107,
          'Excise Invoice Numbers have been exhausted ... Reset them and perform the transaction');
        end if;

  end if;

  -- excise invoice number can be generated.

   if v_prefix is not null then
    v_excise_inv_no := v_prefix || '/' || nvl(v_start_number,0);
   else
    v_excise_inv_no := nvl(v_start_number,0);
   end if;

   v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,1);

else
  -- need to generate for Domestic or Excise based on the register type
  /*
  Changed by aiyer for the bug #3071342.  As the excise invoice generation should not be done in case Domestic
  Without Excise fpr trading and manufacturing organizations and hence removing the check of v_register_code i
  'DOM_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE' from the if statement below
    */
   -- Start of bug 3071342

   /* Start, cbabu for Project Billing. Bug# 6012570 (5876390) */
   if p_called_from = jai_pa_billing_pkg.gv_source_projects then

       v_excise_inv_no := NVL(v_gp1,0);
       v_gp1           := NVL(v_gp1,0) + 1;
   /* End, cbabu for Project Billing. Bug# 6012570 (5876390) */

   elsif (    (v_register_code in ('DOMESTIC_EXCISE' , '23D_DOMESTIC_EXCISE') )
          OR (P_CALLED_FROM = 'MANUAL_RG1:DOMESTIC')
          OR (P_CALLED_FROM = 'MANUAL_PLA:DOMESTIC')
          OR (P_CALLED_FROM = 'MANUAL_RG23:DOMESTIC')
          OR (p_called_from = 'INTERORG_XFER') /*added by vkaranam for bug #6030615*/
        ) then
    -- End of bug 3071342
    --  Condition of P_CALLED_FROM = 'MANUAL_RG1:DOMESTIC' added by bug#3290999
    -- condition of (P_CALLED_FROM = 'MANUAL_PLA:DOMESTIC') added by sriram - bug# 3439480
    -- (P_CALLED_FROM = 'MANUAL_RG23:DOMESTIC') added by sriram - bug# 3439480
    v_order_type := 'DOMESTIC';
    v_register_meaning := 'DOMESTIC';
    v_trans_type_up := 'DOM';

    Open  c_def_excise_cur(v_act_organization_id,v_act_location_id);
    Fetch c_def_excise_cur into v_start_number , v_prefix , v_jump_by , v_end_number;
    close c_def_excise_cur;

    if v_start_number is not null then

      if v_end_number is not null then
        if ((v_start_number + nvl(v_jump_by,1)) > v_end_number ) then
          RAISE_APPLICATION_ERROR(-20107,
          'Excise Invoice Numbers have been exhausted ... Reset them and perform the transaction');
        end if;
      end if;

      if v_prefix is not null then
        v_excise_inv_no := v_prefix || '/' || nvl(v_start_number,0);
      else
        v_excise_inv_no := nvl(v_start_number,0);
      end if;

      v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,1);
    else
      -- need to use gp1 here
      v_excise_inv_no := NVL(v_gp1  ,0);
      v_gp1 := NVL(v_gp1,0) + 1;

    end if;

  -- Vijay Shankar for bug#3393133
  -- elsif  ( (v_register_code in ('EXPORT_EXCISE','23D_EXPORT_ EXCISE') ) OR (P_CALLED_FROM = 'MANUAL_RG1:EXPORT') ) then
  elsif  (   (v_register_code in ('EXPORT_EXCISE','23D_EXPORT_ EXCISE', 'BOND_REG') )
          OR (P_CALLED_FROM = 'MANUAL_RG1:EXPORT')
          OR (P_CALLED_FROM = 'MANUAL_PLA:EXPORT')
          OR (P_CALLED_FROM = 'MANUAL_RG23:EXPORT')
          OR (p_called_from = 'INTERORG_XFER') /*added by vkaranam for bug #6030615*/
         ) then
    -- condition of P_CALLED_FROM = 'MANUAL_RG1:EXPORT' added for bug#3290999
        -- condition of (P_CALLED_FROM = 'MANUAL_PLA:EXPORT') added for bug# 3439480
        -- condition of (P_CALLED_FROM = 'MANUAL_RG23:EXPORT') added for bug# 3439480
    v_order_type := 'EXPORT';
    v_register_meaning := 'EXPORT';
    v_trans_type_up := 'EXP';

    Open  c_def_excise_cur(v_act_organization_id,v_act_location_id);
    Fetch c_def_excise_cur into v_start_number , v_prefix , v_jump_by , v_end_number;
    close c_def_excise_cur;

    if v_start_number is not null then
      if v_end_number is not null then
        if ((v_start_number + nvl(v_jump_by,1)) > v_end_number ) then
          RAISE_APPLICATION_ERROR(-20107,
          'Excise Invoice Numbers have been exhausted ... Reset them and perform the transaction');
        end if;
      end if;

      if v_prefix is not null then
        v_excise_inv_no := v_prefix || '/' || nvl(v_start_number,0);
      else
        v_excise_inv_no := nvl(v_start_number,0);
      end if;

      v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,1);

    else
      -- need to use gp2 here
      v_excise_inv_no := NVL(v_gp2,0);
      v_gp2 := NVL(v_gp2,0) + 1;

    end if;

  elsif v_register_code in ('RTV') or P_CALLED_FROM = 'MANUAL_RG23:RTV' then
          -- condition of 'MANUAL_RG23:RTV' in if clause above added by sriram - bug#3439480
    v_order_type := 'RTV';
    v_register_meaning := 'RTV';
    v_trans_type_up := 'RTV';

    Open  c_def_excise_cur(v_act_organization_id,v_act_location_id);
    Fetch c_def_excise_cur into v_start_number , v_prefix , v_jump_by , v_end_number;
    close c_def_excise_cur;


    if v_start_number is not null then
      if v_end_number is not null then
        if ((v_start_number + nvl(v_jump_by,1)) > v_end_number ) then
          RAISE_APPLICATION_ERROR(-20107,
          'Excise Invoice Numbers have been exhausted ... Reset them and perform the transaction');
        end if;
      end if;

      if v_prefix is not null then
        v_excise_inv_no := v_prefix || '/' || nvl(v_start_number,0);
      else
        v_excise_inv_no := nvl(v_start_number,0);
      end if;

      v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,1);
      -- added by ssumaith - bug# 3522521
      /* elsif P_CALLED_FROM = 'MANUAL_RG23:RTV' then */
    elsif v_start_number is null then --Ramananda for bug#4514367

        v_order_type := 'DOMESTIC';
        v_register_meaning := 'DOMESTIC';
        v_trans_type_up := 'DOM';

        Open  c_def_excise_cur(v_act_organization_id,v_act_location_id);
        Fetch c_def_excise_cur into v_start_number , v_prefix , v_jump_by , v_end_number;
        close c_def_excise_cur;

        if v_start_number is not null then

          if v_end_number is not null then

            if ((v_start_number + nvl(v_jump_by,1)) > v_end_number ) then
            RAISE_APPLICATION_ERROR(-20107,
            'Excise Invoice Numbers have been exhausted ... Reset them and perform the transaction');
          end if;
        end if;
        if v_prefix is not null then
            v_excise_inv_no := v_prefix || '/' || nvl(v_start_number,0);
        else
            v_excise_inv_no := nvl(v_start_number,0);
        end if;
        v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,1);

    else
        v_excise_inv_no := NVL(v_gp1,0);
        v_gp1 := NVL(v_gp1,0) + 1;
    end if;
    else
      v_excise_inv_no := NVL(v_gp1,0);
      v_gp1 := NVL(v_gp1,0) + 1;
    end if;
        -- ends here additions by ssumaith - bug# 3522521
  else
    -- else of register code neither domestic nor excise
    -- ideally flow of code should not occur here.
    v_excise_inv_no := NVL(v_gp2,0);
    v_gp2 := NVL(v_gp2,0) + 1;
  end if; -- end if of v_register_code in ()

end if; -- end if of v_start_number is not null for order + register type combination.

/*added the following if condition by vkaranam for bug#6030615*/
IF v_excise_inv_no = '0' or v_excise_inv_no IS NULL THEN
   raise_application_error(-20199,'Unable to generate Excise Invoice Number ! Please check the Setup');
ELSE
   P_EXCISE_INV_NO := v_excise_inv_no;

END IF;


-- need to write updates here to update the excise invoice table so that the values of columns are incremented.

if v_excise_inv_no is not null then

  if v_start_number is not null then

    -- we have not used gp1 , gp2 hence should not update those columns.
    -- instead should update the column start number instead.

    IF v_trans_type_up IN ('DOM','EXP') THEN
      UPDATE JAI_CMN_RG_EXC_INV_NOS
      SET start_number = v_start_number,
      last_update_date = sysdate
      WHERE organization_id = v_act_organization_id
      AND location_id     = v_act_location_id
      AND fin_year        = p_fin_year
      AND order_invoice_type = v_order_type
      AND register_code  =v_register_meaning
      AND transaction_type = v_trans_type_up;

    ELSIF NVL(v_ec_code_gen,'N') = 'N' Then /*Added by nprashar for bug 7344638*/
      UPDATE JAI_CMN_RG_EXC_INV_NOS
      SET start_number = v_start_number,
      last_update_date = sysdate
      WHERE organization_id = v_act_organization_id
      AND location_id     = v_act_location_id
      AND fin_year        = p_fin_year
      AND order_invoice_type = v_order_type
      AND register_code  =v_register_meaning;
END IF; /*Ends here*/

    /* Changed by aiyer for the bug #3071342
    As the excise invoice generation should not be done in case Domestic Without Excise fpr trading and manufacturing organizations and hence removing the check of v_register_code in
    'DOM_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE' from the if statement below */

    -- Start of bug 3071342

    IF v_register_code IN ('23D_DOMESTIC_EXCISE') THEN

      -- End of bug 3071342
      FOR master_org_rec IN c_tr_ec_code_cur(v_act_organization_id, v_act_location_id) LOOP

        UPDATE JAI_CMN_RG_EXC_INV_NOS
        SET start_number = v_start_number
        WHERE organization_id = master_org_rec.organization_id
        AND location_id     = master_org_rec.location_id
        AND fin_year        = p_fin_year
        AND order_invoice_type = v_order_type
        AND register_code    = v_register_meaning;

      END LOOP;

    ELSE
	IF NVL(v_ec_code_gen,'N') = 'N' Then --Added by JMEENA for bug#7719911
		UPDATE JAI_CMN_RG_EXC_INV_NOS
        	SET start_number = v_start_number
        	WHERE organization_id = v_act_organization_id
        	AND location_id     = v_act_location_id
        	AND fin_year        = p_fin_year
        	AND order_invoice_type = v_order_type
        	AND register_code    = v_register_meaning;
	ELSE
      FOR master_org_rec IN c_ec_code_cur(v_act_organization_id, v_act_location_id) LOOP
        	UPDATE JAI_CMN_RG_EXC_INV_NOS
        	SET start_number = v_start_number
        	WHERE organization_id = master_org_rec.organization_id
        	AND location_id     = master_org_rec.location_id
        	AND fin_year        = p_fin_year
        	AND order_invoice_type = v_order_type
        	AND register_code    = v_register_meaning;
      END LOOP;
	END IF; -- v_ec_code_gen condition bug#7719911
    END IF;

  ELSE  -- v_start_number is not null

    /* Changed by aiyer for the bug #3071342
    As the excise invoice generation should not be done in case Domestic Without Excise fpr trading and manufacturing
    organizations and hence removing the check of v_register_code in 'DOM_WITHOUT_EXCISE','23D_DOM_WITHOUT_EXCISE' from
    the if statement below */

   /*added by vkaranam for bug #6030615*/
   OPEN c_org_type (v_Act_organization_id , v_Act_location_id);
   fetch c_org_type into r_org_type;
   CLOSe c_org_type;

   -- Start of bug 3071342
    IF v_register_code IN ('23D_DOMESTIC_EXCISE')   OR (p_Called_from = 'INTERORG_XFER' AND r_org_type.trading = 'Y'  )/* vkaranam for bug #6030615*/THEN
      -- End of bug 3071342
      FOR master_org_rec IN c_tr_ec_code_cur(v_act_organization_id, v_act_location_id) LOOP
        UPDATE JAI_CMN_RG_EXC_INV_NOS
        SET gp1 = v_gp1,
        gp2 = v_gp2
        WHERE organization_id = master_org_rec.organization_id
        AND location_id     = master_org_rec.location_id
        AND fin_year        = p_fin_year
        AND order_invoice_type IS NULL
        AND register_code IS NULL;
      END LOOP;

    ELSE
	IF NVL(v_ec_code_gen,'N') = 'N' Then --Added by JMEENA for bug#7719911
		UPDATE JAI_CMN_RG_EXC_INV_NOS
        	SET gp1 = v_gp1,
        	gp2 = v_gp2
        	WHERE organization_id =v_act_organization_id
        	AND location_id     = v_act_location_id
        	AND fin_year        = p_fin_year
        	AND order_invoice_type IS NULL
        	AND register_code IS NULL;
	ELSE
      FOR master_org_rec IN c_ec_code_cur(v_act_organization_id, v_act_location_id) LOOP
        UPDATE JAI_CMN_RG_EXC_INV_NOS
        SET gp1 = v_gp1,
        gp2 = v_gp2
        WHERE organization_id = master_org_rec.organization_id
        AND location_id     = master_org_rec.location_id
        AND fin_year        = p_fin_year
        AND order_invoice_type IS NULL
        AND register_code IS NULL;
      END LOOP;
END IF; -- v_ec_code_gen condition bug#7719911
    END IF;

  END IF; -- v_start_number is not null

END IF; -- if v_excise_inv_no is not null

Exception
   When Others then
        p_errbuf := sqlerrm;
END generate_excise_invoice_no ;


/* OPM OF is obsolete with R12 Bug#4487676
PROCEDURE gen_opm_excise_invoice_no
(P_Ordid IN NUMBER ,
P_ORGN_CODE IN VARCHAR2 ,
V_ITEM_CLASS IN VARCHAR2 ,
P_BOL_ID IN NUMBER ,
P_BOLLINE_NO IN NUMBER,
P_EXCISE_INV_NUM IN OUT NOCOPY VARCHAR2
)
IS

--
-- #############################################################################################
--  #
--  # NAME
--  #  EXCISE_NUM_GENERATION
--  #
--  # SNOPSIS
--  #  Procedure EXCISE_NUM_GENERATION
--  #
--  # DESCRIPTION
--  #  Procedure EXCISE_NUM_GENERATION to Generate Excise Invoice Nos
--  #  CREATED BY A.RAINA ON 04/03/2000
--  #
--
-- #########################################################################################*/

/* Added by Ramananda for bug#4407165
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_setup_pkg.gen_opm_excise_invoice_no';

  Cursor C_Order_Type_code IS
  Select Order_Type_code
    from op_ordr_typ a , op_ordr_hdr b
   Where UPPER(a.order_type) = UPPER(b.order_type)
    and  b.order_id = P_Ordid ;

-- start commted by Uday on 23-0CT-2001
/*  Cursor register_code_cur ( s_orgn_code  IN Varchar2 ) Is
  SELECT a.register_code
    FROM JAI_OM_OE_BOND_REG_HDRS a, JAI_OM_OE_BOND_REG_DTLS b,sy_orgn_mst c
   WHERE a.organization_id = c.organization_id
     AND UPPER(c.orgn_code)       = UPPER(s_orgn_code)  ------org_changed
     AND a.register_id     = b.register_id
     AND b.order_flag      = 'Y'
     AND b.order_type_id   = (select order_type From Op_Ordr_Hdr where Order_id =
                                 (select order_id From JAI_OPM_SO_PICK_LINES
                                   where bol_id = P_BOL_ID
                                    and bolline_no = P_BOLLINE_NO ));
-- ended

-- start modified above code on 23-oct-2001 by Uday.
  Cursor register_code_cur ( s_orgn_code  IN Varchar2 ) Is
  SELECT a.register_code
    FROM JAI_OM_OE_BOND_REG_HDRS a, JAI_OM_OE_BOND_REG_DTLS b,org_organization_definitions c
   WHERE a.organization_id = c.organization_id
     AND UPPER(c.organization_code)       = UPPER(s_orgn_code)  ------org_changed
     AND a.register_id     = b.register_id
     AND b.order_flag      = 'Y'
     AND b.order_type_id   = (select order_type From Op_Ordr_Hdr where Order_id =
                                 (select order_id From JAI_OPM_SO_PICK_LINES
                                   where bol_id = P_BOL_ID
                                    and bolline_no = P_BOLLINE_NO ));
-- ended

  CURSOR Register_Code_Meaning_Cur(p_register_code IN VARCHAR2, cp_register_type ja_lookups.lookup_type%type ) IS
  Select meaning
    From ja_lookups
   Where UPPER(lookup_code) LIKE  UPPER(p_register_code)
     And UPPER(lookup_type) = cp_register_type ; --UPPER('JAI_REGISTER_TYPE');    /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980


  CURSOR excise_invoice_cur(p_fin_year number , s_orgn_code IN Varchar2 ) IS
  SELECT NVL(MAX(DOM_NUMBER),0),NVL(MAX(EXP_NUMBER),0)
    FROM JAI_OPM_EXCISE_INV_NOS
   WHERE UPPER(orgn_code) = UPPER(s_orgn_code) ---org_changed
     AND fin_year  = p_fin_year
     AND order_invoice_type IS Null
     AND register_code IS Null;

-- start commented by Uday on 23-OCT-2001
/*  CURSOR fin_year_cur ( s_orgn_code IN Varchar2 ) IS
  SELECT MAX(a.fin_year)
    FROM JAI_CMN_FIN_YEARS a ,sy_orgn_mst b
   WHERE a.organization_id = b.organization_id
     and UPPER(b.orgn_code) =  UPPER(s_orgn_code) -----org_changed
     and a.fin_active_flag = 'Y';
-- end

-- start modified by Uday on 23-OCT-2001
   CURSOR fin_year_cur(s_orgn_code varchar2) IS
     SELECT MAX(a.fin_year)
     FROM   JAI_CMN_FIN_YEARS a ,org_organization_definitions b
     WHERE  a.organization_id = b.organization_id
     and upper(b.organization_code) = upper(s_orgn_code)
     and a.fin_active_flag = 'Y';
-- end


  Cursor Def_Excise_Invoice_Cur(p_fin_year IN NUMBER,
                                p_batch_name IN VARCHAR2, p_register_code IN VARCHAR2, s_orgn_code IN Varchar2 ) IS
  Select start_number, end_number, jump_by, prefix
    From JAI_OPM_EXCISE_INV_NOS
   Where UPPER(orgn_code)    = UPPER(s_orgn_code) ---org_changed
     And fin_year                      = p_fin_year
     And UPPER(order_invoice_type) = UPPER(p_batch_name)
     And UPPER(register_code)      = UPPER(p_register_code);

     --And UPPER(nvl(order_invoice_type,'###')) = UPPER(p_batch_name)
     --And UPPER(nvl(register_code,'###'))      = UPPER(NVL(p_register_code,'***'));


  v_Order_Type_code       Varchar2(10);
  v_fin_year              Number(4);
  v_gp_1          Number;
  v_gp_2                  Number;
  v_rg23a_invoice_no    Number;
  v_rg23c_invoice_no    Number;
  v_other_invoice_no    Number;
  v_excise_inv_no         Varchar2(200);
  v_register_code         Varchar2(30);
  v_start_number          Number;
  v_end_number            Number;
  v_jump_by               Number;
  v_order_invoice_type    Varchar2(50);
  v_prefix      Varchar2(50);
  v_meaning     Varchar2(80);
  v_creation_date     CONSTANT  Date   := SYSDATE; --Added CONSTANT Ramananda for File.Sql.35
  v_created_by      Number ;
  v_last_update_date      CONSTANT  Date   := SYSDATE; --Added CONSTANT Ramananda for File.Sql.35
  v_last_updated_by       Number := 1774 ;
  v_last_update_login     Number := 233965 ;
  v_exc_invoice_num       Varchar2(100);

--Added for OPM India Localization on 30-05-00 by A.Raina
--This part of the code is added for taking care the excise invoice no generation in case the
-- "From warehouse" is of another organization other than in which order is made then in that case
--Excise Invoice Number should be generated.

  Cursor C_From_Whse Is
  SELECT FROM_WHSE
    FROM OP_ORDR_HDR
   WHERE ORDER_ID = P_Ordid ;

  Cursor C_loc_id ( v_From_Whse IN Varchar2 ) Is
  SELECT LOCATION_ID
    FROM HR_LOCATIONS
   WHERE UPPER(LOCATION_CODE) = UPPER(v_From_Whse) ;

  Cursor C_From_Org_Id ( v_loc_id IN Number ) Is
  SELECT ORGANIZATION_ID
    FROM JAI_CMN_INVENTORY_ORGS
   WHERE LOCATION_ID = v_loc_id ;

/* Vijay Shankar for Bug# 3151103
  Cursor C_From_Org_code ( v_From_org_id In Number ) Is
  SELECT SUBSTR(ORGANIZATION_CODE,1,4)
    FROM ORG_ORGANIZATION_DEFINITIONS
   WHERE ORGANIZATION_ID = v_From_org_id ;


  Cursor C_From_Org_code ( v_From_whse_code In VARCHAR2 ) Is
  SELECT B.ORGANIZATION_CODE
  FROM ORG_ORGANIZATION_DEFINITIONS B,IC_WHSE_MST C
  WHERE B.ORGANIZATION_CODE = C.ORGN_CODE
  AND C.WHSE_CODE = v_From_whse_code;

v_From_whse      Varchar2(10);
v_From_loc_id    Number;
v_From_org_id    Number;
v_From_Org_cod   Varchar2(10) := Null ;
v_orgn_code      Varchar2(10) := Null ;


BEGIN

/*-------------------------------------------------------------------------------------------------------------------------
Change History for File ja_in_excise_num_generation_prc.sql

  Trigger to populate the RG23 Part I table upon issue or return of goods in Gemms

S.No   DD/MM/YY    Author and Details of Changes
-------------------------------------------------------------------------------------------------------------------------
1     22/09/2003   Vijay Shankar for Bug# 3151103, File Version : 712.1
                    When a Sales order transaction is done through child warehouse of a Process Organization, then excise invoice is
                    not getting generated. Fixed the issue by modifying c_from_org_code cursor to fetch parent organization of the
                    warehouse from where the excise invoice has to be generated. This is because localization setup is done for
                    the parent organization, not the warehouse.

--------------------------------------------------------------------------------------------------------------------------

    OPEN C_Order_Type_code ;
   FETCH C_Order_Type_code INTO v_order_invoice_type ;
   CLOSE C_Order_Type_code ;

--Added for OPM India Localization on 30-05-00 by A.Raina
--This part of the code is added for taking care the excise invoice no generation in case the
-- "From warehouse" is of another organization other than in which order is made then in that case
--Excise Invoice Number should be generated.

    OPEN C_From_Whse ;
   FETCH C_From_Whse INTO v_From_whse ;
   CLOSE C_From_Whse ;

  /* Vijay Shankar for Bug# 3151103
  OPEN C_loc_id ( v_From_whse ) ;
   FETCH C_loc_id INTO v_From_loc_id ;
   CLOSE C_loc_id ;


    OPEN C_From_Org_Id (v_From_loc_id);
   FETCH C_From_Org_Id INTO v_From_org_id ;
   CLOSE C_From_Org_Id ;


    -- OPEN C_From_Org_code (v_From_org_id);
    OPEN C_From_Org_code (v_From_whse);
   FETCH C_From_Org_code INTO v_From_Org_cod ;
   CLOSE C_From_Org_code ;

   v_orgn_code := UPPER(v_From_Org_cod) ;

--end addition.

    OPEN register_code_cur ( v_orgn_code ) ;
   FETCH register_code_cur INTO v_register_code;
   CLOSE register_code_cur;

    OPEN fin_year_cur ( v_orgn_code );
   FETCH fin_year_cur into v_fin_year;
   CLOSE fin_year_cur;


    OPEN register_code_meaning_cur(v_register_code, UPPER('JAI_REGISTER_TYPE'));
   FETCH register_code_meaning_cur INTO v_meaning;
   CLOSE register_code_meaning_cur;

IF v_item_class IN ('CGEX','CGIN') THEN

     OPEN   Def_Excise_Invoice_Cur( v_fin_year, v_order_invoice_type, v_meaning ,v_orgn_code);
     FETCH  Def_Excise_Invoice_Cur INTO v_start_number, v_end_number, v_jump_by, v_prefix;
     CLOSE  Def_Excise_Invoice_Cur;

            IF v_start_number IS NOT NULL THEN
             IF v_register_code IS NOT NULL THEN
                IF NVL(v_start_number,0) >= NVL(v_end_number,0) AND v_end_number IS NOT NULL THEN
                  RAISE_APPLICATION_ERROR(-20120, 'Excise Invoice Number has been exhausted. ' || ' Increase End Number or enter fresh Start Number and End Number.');
                END IF;
                v_rg23c_invoice_no := nvl(v_start_number,0);
            v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,0);
                IF v_prefix IS NOT NULL THEN
                  v_excise_inv_no := v_prefix||'/'||to_char(v_rg23c_invoice_no);

                ELSE
                  v_excise_inv_no := to_char(v_rg23c_invoice_no);

                END IF;
              END IF;
            ELSE
            OPEN  excise_invoice_cur(v_fin_year,v_orgn_code );
        FETCH  excise_invoice_cur INTO v_gp_1, v_gp_2;
    CLOSE  excise_invoice_cur;
              IF v_register_code IS NOT NULL THEN
-- added 'Bond_Reg' by K V UDAY KUMAR on 23-oct-00 in the below statement

                -- the following if modified by Vijay Shankar for Bug# 3151103
                -- IF UPPER(v_register_code) IN ('DOMESTIC_EXCISE','EXPORT_EXCISE',
                --      '23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE','BOND_REG') THEN
                IF UPPER(v_register_code) IN ('DOMESTIC_EXCISE','23D_DOMESTIC_EXCISE') THEN
                  v_rg23c_invoice_no := nvl(v_gp_1,0);

                  v_gp_1 := nvl(v_gp_1,0) + 1;

            -- this else modified after consulting support.
            -- ELSE
            ELSIF UPPER(v_register_code) IN ('EXPORT_EXCISE', '23D_EXPORT_EXCISE', 'BOND_REG') THEN
                  v_rg23c_invoice_no := nvl(v_gp_2,0);

                  v_gp_2 := nvl(v_gp_2,0) + 1;

        END IF;
                  v_excise_inv_no := v_rg23c_invoice_no;

              END IF;
            END IF;
          ELSIF UPPER(v_item_class) IN ('RMIN','RMEX') THEN
           OPEN   Def_Excise_Invoice_Cur( v_fin_year, v_order_invoice_type, v_meaning ,v_orgn_code);
           FETCH  Def_Excise_Invoice_Cur INTO v_start_number, v_end_number, v_jump_by, v_prefix;
    CLOSE  Def_Excise_Invoice_Cur;
           IF v_start_number IS NOT NULL THEN
             IF v_register_code IS NOT NULL THEN
                IF NVL(v_start_number,0) >= NVL(v_end_number,0) AND v_end_number IS NOT NULL THEN
                  RAISE_APPLICATION_ERROR(-20120, 'Excise Invoice Number has been exhausted. ' || ' Increase End Number or enter fresh Start Number and End Number.');
                END IF;
                v_rg23a_invoice_no := nvl(v_start_number,0);

                v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,0);

                IF v_prefix IS NOT NULL THEN
                  v_excise_inv_no := v_prefix||'/'||to_char(v_rg23a_invoice_no);


                ELSE
                  v_excise_inv_no := to_char(v_rg23a_invoice_no);

                END IF;
              END IF;
            ELSE
              OPEN   excise_invoice_cur(v_fin_year,v_orgn_code);
              FETCH  excise_invoice_cur INTO v_gp_1, v_gp_2;
              CLOSE  excise_invoice_cur;
              IF v_register_code IS NOT NULL THEN
                IF UPPER(v_register_code) IN
-- following is modified by Vijay Shankar for Bug# 3151103
-- ('DOMESTIC_EXCISE','EXPORT_EXCISE','23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE','BOND_REG') THEN
('DOMESTIC_EXCISE','23D_DOMESTIC_EXCISE') THEN

  v_rg23a_invoice_no := nvl(v_gp_1,0);

                  v_gp_1 := nvl(v_gp_1,0) + 1;

            -- ELSE
            ELSIF UPPER(v_register_code) IN ('EXPORT_EXCISE', '23D_EXPORT_EXCISE','BOND_REG') THEN
                  v_rg23a_invoice_no := nvl(v_gp_2,0);

                  v_gp_2 := nvl(v_gp_2,0) + 1;
                END IF;
                  v_excise_inv_no := v_rg23a_invoice_no;
              END IF;
            END IF;
          ELSIF UPPER(v_item_class) IN ('FGIN','FGEX','CCIN','CCEX') THEN
           OPEN   Def_Excise_Invoice_Cur( v_fin_year, v_order_invoice_type, v_meaning, v_orgn_code );
           FETCH  Def_Excise_Invoice_Cur INTO v_start_number, v_end_number, v_jump_by, v_prefix;
           CLOSE  Def_Excise_Invoice_Cur;
           IF v_start_number IS NOT NULL THEN
             IF v_register_code IS NOT NULL THEN
                IF NVL(v_start_number,0) >= NVL(v_end_number,0) AND v_end_number IS NOT NULL THEN
                  RAISE_APPLICATION_ERROR(-20120, 'Excise Invoice Number has been exhausted. ' || ' Increase End Number or enter fresh Start Number and End Number.');
                END IF;
                v_other_invoice_no := nvl(v_start_number,0);
        v_start_number := nvl(v_start_number,0) + nvl(v_jump_by,0);

                IF v_prefix IS NOT NULL THEN
                  v_excise_inv_no := v_prefix||'/'||to_char(v_other_invoice_no);

                ELSE
                  v_excise_inv_no := to_char(v_other_invoice_no);

                END IF;
              END IF;
            ELSE
              OPEN   excise_invoice_cur(v_fin_year, v_orgn_code);
              FETCH  excise_invoice_cur INTO v_gp_1, v_gp_2;
              CLOSE  excise_invoice_cur;
              IF v_register_code IS NOT NULL THEN
                IF  UPPER(v_register_code) IN
-- added 'Bond_Reg' by K V UDAY KUMAR on 23-oct-00 in the below statement
-- below condition modified by Vijay Shankar for Bug# 3151103
-- ('DOMESTIC_EXCISE','EXPORT_EXCISE','23D_DOMESTIC_EXCISE','23D_EXPORT_EXCISE','BOND_REG') THEN
('DOMESTIC_EXCISE','23D_DOMESTIC_EXCISE') THEN
                  v_other_invoice_no := nvl(v_gp_1,0);

                  v_gp_1 := nvl(v_gp_1,0) + 1;
            -- ELSE
            ELSIF UPPER(v_register_code) IN ('EXPORT_EXCISE', '23D_EXPORT_EXCISE','BOND_REG') THEN
                  v_other_invoice_no := nvl(v_gp_2,0);
                  v_gp_2 := nvl(v_gp_2,0) + 1;
                END IF;
                  v_excise_inv_no := v_other_invoice_no;
              END IF;
            END IF;
          END IF;
          IF v_excise_inv_no is Not Null THEN
            IF v_start_number IS NOT NULL THEN
              UPDATE JAI_OPM_EXCISE_INV_NOS
           SET start_number       = v_start_number,
                     last_update_date   = v_last_update_date,
                     last_updated_by    = v_last_updated_by,
                     last_update_login  = v_last_update_login
               WHERE UPPER(orgn_code)   =  UPPER(V_orgn_code)
                 AND fin_year           = v_fin_year
                 AND UPPER(order_invoice_type) = UPPER(v_order_invoice_type)
                 AND UPPER(register_code)      = UPPER(v_meaning);
            ELSE
              UPDATE JAI_OPM_EXCISE_INV_NOS
          SET  dom_number = v_gp_1,
                     exp_number = v_gp_2,
                     last_update_date = v_last_update_date,
                     last_updated_by  = v_last_updated_by,
                     last_update_login = v_last_update_login
              WHERE  UPPER(orgn_code) = UPPER(v_orgn_code) ----org_changed
              AND    fin_year        = v_fin_year
              AND    order_invoice_type IS Null
              AND    register_code IS Null;

    END IF;
/*
SELECT SUBSTR(v_excise_inv_no, instr(v_excise_inv_no, '/', 1, 1) + 1)
into   v_excise_inv_no
from   dual;

             UPDATE JAI_OPM_SO_PICK_LINES
          SET excise_invoice_no = v_excise_inv_no
        WHERE UPPER(orgn_code) = UPPER(v_orgn_code) ---org_changed
            AND bol_id = p_bol_id
                AND bolline_no = P_BOLLINE_NO ;
          END IF;
        p_excise_inv_num := v_excise_inv_no ;


   /* Added by Ramananda for bug#4407165
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

End  gen_opm_excise_invoice_no ;
*/

FUNCTION get_po_assessable_value(
  p_vendor_id IN NUMBER,
  p_vendor_site_id IN NUMBER,
  p_inv_item_id IN NUMBER,
  p_line_uom IN VARCHAR2
) RETURN NUMBER IS

  v_line_uom_class  VARCHAR2(45);
  v_tax_uom_class   VARCHAR2(45);
  uom_rate      NUMBER;
  v_price_list_id   NUMBER;
  v_assessable_val  NUMBER;

  CURSOR Fetch_Price_List_Id_Cur IS
    SELECT Price_List_Id
    FROM JAI_CMN_VENDOR_SITES
    WHERE Vendor_Id = p_vendor_id
    AND Vendor_Site_Id = NVL( p_vendor_site_id, 0 );

  CURSOR Fetch_Price_List1_Id_Cur IS
    SELECT Price_List_Id
    FROM JAI_CMN_VENDOR_SITES
    WHERE vendor_Id = p_vendor_id
    AND Vendor_Site_Id = 0;

  CURSOR Fetch_Assessable_Val_Cur(cp_item  qp_List_Lines_v.product_attribute_context%type) IS
    SELECT operand
    FROM qp_List_Lines_v
    WHERE List_header_id = v_price_list_id
    AND product_attribute_context = cp_item --'ITEM'      -- cbabu for Bug# 3083335
    AND product_Id = p_inv_item_id
    AND product_uom_code = p_line_uom
    AND NVL( Start_Date_Active, SYSDATE - 1 ) <= SYSDATE
    AND NVL( End_Date_Active, SYSDATE + 1 ) >= SYSDATE;

-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
------------------------------------------------------------------------------------------
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_cmn_setup_pkg.get_po_assessable_value';

-- add for record down the release version by Xiao on 24-Jul-2009
    lv_release_name VARCHAR2(30);
    lv_other_release_info VARCHAR2(30);
    lb_result BOOLEAN := FALSE ;

    -- Get category_set_name
    CURSOR category_set_name_cur
    IS
    SELECT
      category_set_name
    FROM
      mtl_default_category_sets_fk_v
    WHERE functional_area_desc = 'Order Entry';

    lv_category_set_name  VARCHAR2(30);

    -- Get the Excise Assessable Value based on the Excise price list Id, Inventory_item_id, uom code.
    CURSOR vend_ass_value_category_cur
     ( pn_inventory_item_id NUMBER
     , pv_uom_code          VARCHAR2
     )
     IS
     SELECT
       b.operand          list_price
     FROM
       qp_list_lines         b
     , qp_pricing_attributes c
     WHERE b.list_header_id        = v_price_list_id
       AND c.list_line_id          = b.list_line_id
       AND c.product_uom_code      = pv_uom_code
       AND NVL( start_date_active, SYSDATE- 1 ) <= SYSDATE
       AND NVL( end_date_active, SYSDATE +1 )>= SYSDATE
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = to_char(d.category_id)
                  );
--------------------------------------------------------------------------------------------
--- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

BEGIN
/*-------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for File - ja_in_fetch_assessable_value_f.sql
S.No    dd/mm/yyyy    Author and Details
---------------------------------------------------------------------------------------------------------------------------
1       05/08/2003    Vijay Shankar for Bug# 3083335, Version: 616.1
                        Fetch_Assessable_Val_Cur is failing when assessable price list is not attached to the supplier site or
                        supplier null site and the Client has some data where in QP_LIST_LINES_V.product_id clolumn has non numeric
                        data. This is fixed by placing an additional condition in the where clause of the cursor to filter
                        only product_attribute_context is 'ITEM'.

2.      08/30/2004    Ssumaith - bug# 3814739 - File version 115.1

                       A invalid number exception was occuring in cases where the cursor Fetch_Assessable_Val_Cur was opened
                       and no price list id was fetched because the setup of additional information is not done.
                       Code added to return code when so that the error is not encountered.

3       24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.4
                      Projects Billing Enh.
                      forward ported from R11i to R12
4.      10/06/2009    Add code by Xiao Lv for Advance Pricing.

5.      28/07/2009    Xiao Lv for IL Advanced Pricing.
                      Add if condition control for specific release version, code as:
                      IF lv_release_name NOT LIKE '12.0%' THEN
                         Advanced Pricing code;
                      END IF;
6.     30/07/2009    Jia for bug#8739679
                     Add Item-UOM validation logic for null site level
---------------------------------------------------------------------------------------- */



--------------------------------------------------------------------------------------------------------------------------*/

  -- Add by Xiao to get release version on 24-Jul-2009
  lb_result := fnd_release.get_release(lv_release_name, lv_other_release_info);

  -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
  -----------------------------------------------------------------------------

  -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
  IF lv_release_name NOT LIKE '12.0%' THEN

  -- Get category_set_name
  OPEN category_set_name_cur;
  FETCH category_set_name_cur INTO lv_category_set_name;
  CLOSE category_set_name_cur;

  -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
  -- in the transaction. If yes, give an exception error message to stop transaction.
  Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_vendor_id
                                                 , pn_party_site_id     => p_vendor_site_id
                                                 , pn_inventory_item_id => p_inv_item_id
                                                 , pd_ordered_date      => SYSDATE
                                                 , pv_party_type        => 'V'
                                                 , pn_pricing_list_id  => NULL
                                                 );

  END IF; -- lv_release_name NOT LIKE '12.0%'
  ---------------------------------------------------------------------------------
  -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end
  OPEN  Fetch_Price_List_Id_Cur;
  FETCH Fetch_Price_List_Id_Cur INTO v_price_list_id;
  CLOSE Fetch_Price_List_Id_Cur;

  -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
  ---------------------------------------------------------------------------------
  IF v_price_list_id IS NOT NULL
  THEN
    OPEN Fetch_Assessable_Val_Cur('ITEM'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    FETCH Fetch_Assessable_Val_Cur INTO v_assessable_val;
    CLOSE Fetch_Assessable_Val_Cur;

    -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
    IF lv_release_name NOT LIKE '12.0%' THEN
       IF v_assessable_val IS NULL
       THEN
          -- Get Excise assessable value of item category base on inventory_item_id and line_uom.
          OPEN vend_ass_value_category_cur(p_inv_item_id, p_line_uom);
          FETCH vend_ass_value_category_cur INTO v_assessable_val;
          CLOSE vend_ass_value_category_cur;
       END IF;
     END IF; --lv_release_name NOT LIKE '12.0%'
  END IF; --  v_price_list_id IS NOT NULL
  ---------------------------------------------------------------------------------
  -- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

  --IF v_price_list_id IS NULL THEN  -- Removed by Xiao for Advanced Pricing on 10-Jun-2009
  IF v_assessable_val IS NULL
  THEN
    OPEN  Fetch_Price_List1_Id_Cur;
    FETCH Fetch_Price_List1_Id_Cur INTO v_price_list_id;
    CLOSE Fetch_Price_List1_Id_Cur;
  END IF;

  -- ssumaith - bug# 3814739
  IF V_PRICE_LIST_ID IS NULL THEN
     RETURN(NULL);
  END IF;
  -- ssumaith - bug# 3814739

  -- Added by Jia for Bug#8739679 on 30-Jul-2009, Begin
  ---------------------------------------------------------------------------------
  IF lv_release_name NOT LIKE '12.0%'
  THEN
    Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_vendor_id
                                                   , pn_party_site_id     => 0
                                                   , pn_inventory_item_id => p_inv_item_id
                                                   , pd_ordered_date      => SYSDATE
                                                   , pv_party_type        => 'V'
                                                   , pn_pricing_list_id  => NULL
                                                   );
  END IF;
  ---------------------------------------------------------------------------------
  -- Added by Jia for Bug#8739679 on 30-Jul-2009, End


  OPEN Fetch_Assessable_Val_Cur('ITEM'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
  FETCH Fetch_Assessable_Val_Cur INTO v_assessable_val;
  CLOSE Fetch_Assessable_Val_Cur;
  -- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
  ------------------------------------------------------------------------------------------

  -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
  IF lv_release_name NOT LIKE '12.0%' THEN
     IF v_assessable_val IS NULL
     THEN
        -- Get Excise assessable value of item category base on inventory_item_id and line_uom.
        OPEN vend_ass_value_category_cur(p_inv_item_id, p_line_uom);
        FETCH vend_ass_value_category_cur INTO v_assessable_val;
        CLOSE vend_ass_value_category_cur;
     END IF;
   END IF ;  --lv_release_name NOT LIKE '12.0%'
  --------------------------------------------------------------------------------------------
  --- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

  RETURN( v_assessable_val );

-- Added by Xiao for Advanced Pricing on 10-Jun-2009, begin
------------------------------------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||SQLERRM);
    app_exception.raise_exception;
--------------------------------------------------------------------------------------------
--- Added by Xiao for Advanced Pricing on 10-Jun-2009, end

END get_po_assessable_value;

END jai_cmn_setup_pkg ;

/
