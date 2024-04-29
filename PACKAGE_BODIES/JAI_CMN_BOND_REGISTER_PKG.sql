--------------------------------------------------------
--  DDL for Package Body JAI_CMN_BOND_REGISTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_BOND_REGISTER_PKG" 
/* $Header: jai_cmn_bond_reg.plb 120.1 2005/07/20 12:57:03 avallabh ship $ */
as

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_bond_reg -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.
*/

Procedure get_register_id
(
p_organization_id   in  number,
p_location_id       in  number,
p_order_invoice_id      in  Number,
p_order_invoice_type    in  varchar2,
p_register_id  out NOCOPY number,
p_register_code out NOCOPY varchar2
)
is
cursor c_get_register  is
select  hdr.register_id ,
        bond_number ,hdr.register_code
from    JAI_OM_OE_BOND_REG_HDRS  hdr,
        JAI_OM_OE_BOND_REG_DTLS   dtl
where   hdr.register_id = dtl.register_id
and     hdr.organization_id = p_organization_id
and     hdr.location_id = p_location_id
and     dtl.order_flag  = p_order_invoice_type
and     dtl.order_type_id = p_order_invoice_id;

v_register_id       Number;
v_bond_id           Number;
v_bond_number       JAI_OM_OE_BOND_REG_HDRS.bond_number%type;
v_reg_code          JAI_OM_OE_BOND_REG_HDRS.register_code%type;

lv_object_name VARCHAR2(61); -- := '<Package_name>.<procedure_name>'; /* Added by Ramananda for bug#4407165 */

begin

lv_object_name := 'jai_cmn_bond_register_pkg.get_register_id'; /* Added by Ramananda for bug#4407165 */

open   c_get_register;
fetch  c_get_register into v_register_id ,  v_bond_number,v_reg_code;
close  c_get_register;

p_register_id      := v_register_id;
p_register_code    := v_reg_code;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    p_register_id   := null;
    p_register_code := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

End get_register_id;

Procedure get_register_details
(
p_register_id                      in  number,
p_register_balance OUT NOCOPY number,
p_register_expiry_date OUT NOCOPY date,
p_lou_flag OUT NOCOPY varchar2
)
is
cursor  c_get_register_details  is
select  hdr.register_id ,
        hdr.bond_expiry_date, hdr.lou_flag , register_code
from    JAI_OM_OE_BOND_REG_HDRS  hdr
where   hdr.register_id = p_register_id;

Cursor   c_get_bond_register_balance is
Select   register_balance
from     JAI_OM_OE_BOND_TRXS
where    register_id = p_register_id
and      transaction_id =
(select  max(transaction_id)
  from   JAI_OM_OE_BOND_TRXS
  where register_id = p_register_id
);

Cursor   c_get_other_register_balance is
Select   RG23D_REGISTER_BALANCE
from     JAI_OM_OE_BOND_TRXS
where    register_id = p_register_id
and      transaction_id =
(select  max(transaction_id)
  from   JAI_OM_OE_BOND_TRXS
  where register_id = p_register_id
);

v_register_id            Number;
v_register_balance       Number;
v_expiry_date            Date;
v_lou_flag               Varchar2(1);
v_register_code          JAI_OM_OE_BOND_REG_HDRS.register_code%type;
lv_object_name           VARCHAR2(61); -- := '<Package_name>.<procedure_name>'; /* Added by Ramananda for bug#4407165 */

begin

lv_object_name := 'jai_cmn_bond_register_pkg.get_register_details'; /* Added by Ramananda for bug#4407165 */

open   c_get_register_details ;
fetch  c_get_register_details  into v_register_id,v_expiry_date,v_lou_flag , v_register_code ;
close  c_get_register_details ;

if     NVL(UPPER(v_register_code),'N') = 'BOND_REG' then
       open   c_get_bond_register_balance;
       fetch  c_get_bond_register_balance into v_register_balance;
       close  c_get_bond_register_balance;
elsif  NVL(UPPER(v_register_code),'N') = '23D_EXPORT_WITHOUT_EXCISE' then
       open   c_get_other_register_balance;
       fetch  c_get_other_register_balance into v_register_balance;
       close  c_get_other_register_balance;
end if;

p_register_balance            := v_register_balance;
p_register_expiry_date        := v_expiry_date;
p_lou_flag                    := v_lou_flag;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;


End get_register_details;

end jai_cmn_bond_register_pkg;

/
