--------------------------------------------------------
--  DDL for Package Body PAY_PL_PERSONAL_PAY_METHOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_PERSONAL_PAY_METHOD" as
/* $Header: pyplppmp.pkb 120.2.12010000.2 2009/12/18 10:44:16 bkeshary ship $ */

g_package   VARCHAR2(30);

PROCEDURE CREATE_PL_PERSONAL_PAY_METHOD
(p_segment1 varchar2
,p_segment2 varchar2
,p_segment3 varchar2
,p_segment12 varchar2
) is
p_var number;
begin
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Payroll', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_PL_PERSONAL_PAY_METHOD');
   return;
END IF;
p_var:=hr_pl_utility.validate_bank_id(p_segment2);

if p_var=0 then
fnd_message.set_name('PAY','HR_PL_INVALID_BANK_ID');
fnd_message.raise_error;
end if;

IF p_segment3 is NOT NULL THEN  -- 9226630
 p_var:=hr_pl_utility.validate_account_no(p_segment1,p_segment2,p_segment3);
 if p_var=0 then
  fnd_message.set_name('PAY','HR_PL_INVALID_ACC_NO');
  fnd_message.raise_error;
 end if;
end if;

/* 9226630 */
IF p_segment12 is NOT NULL THEN  -- 9226630
  p_var:=hr_pl_utility.validate_iban_acc(p_segment12);
  hr_utility.set_location('p_var      :'|| p_var,1);
  --hr_utility.trace_off;
  if p_var=1 then
  hr_utility.set_location('p_var      :'|| p_var,2);
  fnd_message.set_name('PAY','HR_PL_INVALID_IBAN_NO');
  fnd_message.raise_error;
  end if;
end if;

/* end 9226630 */

end CREATE_PL_PERSONAL_PAY_METHOD;

PROCEDURE UPDATE_PL_PERSONAL_PAY_METHOD
(p_segment1 varchar2
,p_segment2 varchar2
,p_segment3 varchar2
,p_segment12 varchar2
,p_personal_payment_method_id number
) is
p_var number;
l_seg1 varchar2(20);
l_seg2 varchar2(20);
l_seg3 varchar2(20);
l_seg12 varchar2(30);  --9226630
l_var1 varchar2(20);
l_var2 varchar2(20);
l_var3 varchar2(20);
l_var12 varchar2(30); -- 9226630

cursor p_cur1 is select segment1,segment2,segment3,segment12  from pay_external_accounts where external_account_id =
(select external_Account_id from pay_personal_payment_methods_f where personal_payment_method_id = p_personal_payment_method_id );

begin

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Payroll', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_PL_PERSONAL_PAY_METHOD');
   return;
END IF;

   l_var1:=p_segment1;
   l_var2:=p_segment2;
   l_var3:=p_segment3;
   l_var12:=p_segment12; --9226630

   if p_segment2 <> hr_api.g_varchar2 then
      p_var:=hr_pl_utility.validate_bank_id(p_segment2);
   end if;

   if p_var=0 then
     fnd_message.set_name('PAY','HR_PL_INVALID_BANK_ID');
     fnd_message.raise_error;
   end if;

open p_cur1;
fetch p_cur1 into l_seg1,l_seg2,l_seg3,l_seg12; --9226630


if p_segment1 = hr_api.g_varchar2 then
 l_var1 := l_seg1;
end if;

if p_segment2 = hr_api.g_varchar2 then
 l_var2 := l_seg2;
end if;

if p_segment3 = hr_api.g_varchar2 then
 l_var3 := l_seg3;
end if;

/* added by 9226630 */
if p_segment12 = hr_api.g_varchar2 then
  l_var12 := l_seg12;
  hr_utility.set_location('l_var12       :'|| l_var12,2);
end if;
/* end */

if l_var3 is NOT NULL then  --9226630
  p_var:=hr_pl_utility.validate_account_no(l_var1,l_var2,l_var3);
 if p_var=0 then
  fnd_message.set_name('PAY','HR_PL_INVALID_ACC_NO');
  fnd_message.raise_error;
 end if;
end if;

/* 9226630 */
if l_var12 is NOT NULL then
  p_var:=hr_pl_utility.validate_iban_acc(l_var12);

  if p_var=1 then
  fnd_message.set_name('PAY','HR_PL_INVALID_IBAN_NO');
  fnd_message.raise_error;
  end if;
 end if;

/* end 9226630 */

close p_cur1;
end UPDATE_PL_PERSONAL_PAY_METHOD;
end PAY_PL_PERSONAL_PAY_METHOD;

/
