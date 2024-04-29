--------------------------------------------------------
--  DDL for Package Body PAY_ORG_PAYMENT_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ORG_PAYMENT_METHODS_PKG" AS
/* $Header: pyopm01t.pkb 120.6 2006/08/31 12:42:53 pgongada noship $ */
g_dummy number(1);
g_business_group_id number(15);
g_validation_start_date date;
g_validation_end_date date;
-----------------------------------------------------------------------------
--
-- Standard Insert procedure
--
procedure insert_row(
        p_row_id                           in out nocopy varchar2,
        p_org_payment_method_id            in out nocopy number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_org_payment_method_name          varchar2,
        p_base_opm_name                    varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_asset_code_combination_id        number,
        p_set_of_books_id                  number,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_gl_set_of_books_id               number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number,
        p_default_gl_account               varchar2,
        p_bank_account_id                  number,
        p_pay_gl_account_id_out            out nocopy number ) is
--
cursor c1 is
        select  pay_org_payment_methods_s.nextval
        from    sys.dual;
cursor c2 is
        select  rowid
        from    pay_org_payment_methods_f
        where   org_payment_method_id   = P_ORG_PAYMENT_METHOD_ID
        and     effective_start_date    = P_EFFECTIVE_START_DATE
        and     effective_end_date      = P_EFFECTIVE_END_DATE;
--
begin
   open c1;
   fetch c1 into P_ORG_PAYMENT_METHOD_ID;
   close c1;
--
   begin
     insert into pay_org_payment_methods_f (
        org_payment_method_id   ,
        effective_start_date    ,
        effective_end_date      ,
        business_group_id       ,
        external_account_id     ,
        currency_code           ,
        payment_type_id         ,
        defined_balance_id      ,
        org_payment_method_name ,
        comment_id              ,
        attribute_category      ,
        attribute1              ,
        attribute2              ,
        attribute3              ,
        attribute4              ,
        attribute5              ,
        attribute6              ,
        attribute7              ,
        attribute8              ,
        attribute9              ,
        attribute10       ,
        attribute11       ,
        attribute12       ,
        attribute13       ,
        attribute14       ,
        attribute15       ,
        attribute16       ,
        attribute17       ,
        attribute18       ,
        attribute19       ,
        attribute20       ,
        pmeth_information_category ,
        pmeth_information1 ,
        pmeth_information2 ,
        pmeth_information3 ,
        pmeth_information4 ,
        pmeth_information5 ,
        pmeth_information6 ,
        pmeth_information7 ,
        pmeth_information8 ,
        pmeth_information9 ,
        pmeth_information10,
        pmeth_information11,
        pmeth_information12,
        pmeth_information13,
        pmeth_information14,
        pmeth_information15,
        pmeth_information16,
        pmeth_information17,
        pmeth_information18,
        pmeth_information19,
        pmeth_information20,
        transfer_to_gl_flag,
        cost_payment,
        cost_cleared_payment,
        cost_cleared_void_payment,
        exclude_manual_payment )
values (
        p_org_payment_method_id   ,
        p_effective_start_date    ,
        p_effective_end_date      ,
        p_business_group_id       ,
        p_external_account_id     ,
        p_currency_code           ,
        p_payment_type_id         ,
        p_defined_balance_id      ,
        p_base_opm_name           ,
        p_comment_id              ,
        p_attribute_category      ,
        p_attribute1              ,
        p_attribute2              ,
        p_attribute3              ,
        p_attribute4              ,
        p_attribute5              ,
        p_attribute6              ,
        p_attribute7              ,
        p_attribute8              ,
        p_attribute9              ,
        p_attribute10       ,
        p_attribute11       ,
        p_attribute12       ,
        p_attribute13       ,
        p_attribute14       ,
        p_attribute15       ,
        p_attribute16       ,
        p_attribute17       ,
        p_attribute18       ,
        p_attribute19       ,
        p_attribute20       ,
        p_pmeth_information_category ,
        p_pmeth_information1 ,
        p_pmeth_information2 ,
        p_pmeth_information3 ,
        p_pmeth_information4 ,
        p_pmeth_information5 ,
        p_pmeth_information6 ,
        p_pmeth_information7 ,
        p_pmeth_information8 ,
        p_pmeth_information9 ,
        p_pmeth_information10,
        p_pmeth_information11,
        p_pmeth_information12,
        p_pmeth_information13,
        p_pmeth_information14,
        p_pmeth_information15,
        p_pmeth_information16,
        p_pmeth_information17,
        p_pmeth_information18,
        p_pmeth_information19,
        p_pmeth_information20,
        p_transfer_to_gl_flag,
        p_cost_payment,
        p_cost_cleared_payment,
        p_cost_cleared_void_payment,
        p_exclude_manual_payment );
--
-- **************************************************************************
--  insert into MLS table (TL)
--
     insert into PAY_ORG_PAYMENT_METHODS_F_TL (
       ORG_PAYMENT_METHOD_ID,
       ORG_PAYMENT_METHOD_NAME,
       LAST_UPDATE_DATE,
       CREATION_DATE,
       LANGUAGE,
       SOURCE_LANG
     ) select
       P_ORG_PAYMENT_METHOD_ID,
       P_ORG_PAYMENT_METHOD_NAME,
       sysdate,
       sysdate,
       L.LANGUAGE_CODE,
       userenv('LANG')
     from FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and not exists
       (select NULL
       from PAY_ORG_PAYMENT_METHODS_F_TL T
       where T.ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);

--
--
-- *******************************************************************************
--
   end;

  -- cash management integration: update asset_code_combination_id in
  -- ap_bank_branches_all for the bank account associated with
  -- this payment method.  only do this if cash management integration
  -- is active, i.e. both payroll and cash management are installed.

  if pay_ce_support_pkg.pay_and_ce_licensed then

     --   Bug No. 4644827
     --   for r11.5 the same functionality is done through database trigger. Code
     --   is for R12
          if p_bank_account_id is not null AND p_external_account_id IS NOT NULL then
             pay_maintain_bank_acct.update_payroll_bank_acct(
            	      p_bank_account_id     => p_bank_account_id,
                      p_external_account_id => p_external_account_id,
		      p_org_payment_method_id => P_ORG_PAYMENT_METHOD_ID);
          end if;
     --
     pay_maintain_bank_acct.update_asset_ccid(
                   p_assest_ccid              =>p_asset_code_combination_id,
                   p_set_of_books_id          =>p_set_of_books_id,
                   p_external_account_id      =>p_external_account_id
                   );
  end if;

  -- Costing of Payment changes

   PAY_PAYMENT_GL_ACCOUNTS_PKG.INSERT_ROW
          ( P_PAY_GL_ACCOUNT_ID => p_pay_gl_account_id_out,
            P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE,
            P_EFFECTIVE_END_DATE => P_EFFECTIVE_END_DATE,
            P_SET_OF_BOOKS_ID => P_GL_SET_OF_BOOKS_ID,
            P_GL_CASH_AC_ID => P_GL_CASH_AC_ID,
            P_GL_CASH_CLEARING_AC_ID => P_GL_CASH_CLEARING_AC_ID,
            P_GL_CONTROL_AC_ID => P_GL_CONTROL_AC_ID,
            P_GL_ERROR_AC_ID => P_GL_ERROR_AC_ID,
            P_EXTERNAL_ACCOUNT_ID => P_EXTERNAL_ACCOUNT_ID,
            P_ORG_PAYMENT_METHOD_ID => P_ORG_PAYMENT_METHOD_ID,
            P_DEFAULT_GL_ACCOUNT    => P_DEFAULT_GL_ACCOUNT
          );

--
   open c2;
   fetch c2 into P_ROW_ID;
   close c2;
--
end insert_row;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_validation_start_date IN DATE,
                                  p_validation_end_date IN DATE) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_validation_start_date := p_validation_start_date;
   g_validation_end_date := p_validation_end_date;
END set_translation_globals;
-----------------------------------------------------------------------------
procedure validate_translation(org_payment_method_id IN NUMBER,
                               language IN VARCHAR2,
                               org_payment_method_name IN VARCHAR2) IS
/*

This procedure fails if a payment method translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated payment method names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_org_payment_method_name IN VARCHAR2,
                     p_org_payment_method_id IN NUMBER)  IS
       SELECT  1
         FROM  pay_org_payment_methods_f_tl ptt,
               pay_org_payment_methods_f ptm
         WHERE upper(ptt.org_payment_method_name)=upper(p_org_payment_method_name)
         AND   ptt.org_payment_method_id = ptm.org_payment_method_id
         AND   ptt.language = p_language
         AND   (ptm.org_payment_method_id <> p_org_payment_method_id OR p_org_payment_method_id IS NULL)
         AND   (ptm.business_group_id = g_business_group_id OR g_business_group_id IS NULL)
         AND   ((g_validation_start_date between ptm.effective_start_date and
                ptm.effective_end_date) or
                (g_validation_end_date between ptm.effective_start_date and
                ptm.effective_end_date) or
                (g_validation_start_date IS NULL or g_validation_end_date IS NULL) or
                ((g_validation_start_date < ptm.effective_start_date) and
                 (g_validation_end_date > ptm.effective_end_date)));
    l_package_name VARCHAR2(80) := 'PAY_ORG_PAYMENT_METHODS_PKG.VALIDATE_TRANSLATION';

BEGIN
   hr_utility.set_location (l_package_name,10);
       OPEN c_translation(language, org_payment_method_name,org_payment_method_id);
        hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
        hr_utility.set_location (l_package_name,60);
          CLOSE c_translation;
       ELSE
        hr_utility.set_location (l_package_name,70);
          CLOSE c_translation;
          fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
          fnd_message.raise_error;
       END IF;
        hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
-----------------------------------------------------------------------------
--
-- Standard delete procedure
--
procedure delete_row(p_org_payment_method_id  NUMBER,
                     p_row_id  varchar2,
                     p_dt_delete_mode varchar2,
                     p_effective_date date,
                     p_org_effective_start_date date,
                     p_org_effective_end_date date
                     ) is
--
begin

        PAY_PAYMENT_GL_ACCOUNTS_PKG.DELETE_ROW
           (p_org_payment_method_id => p_org_payment_method_id
           ,p_effective_date      => p_effective_date
           ,p_datetrack_mode      => p_dt_delete_mode
           ,p_org_eff_start_date  => p_org_effective_start_date
           ,p_org_eff_end_date    => p_org_effective_end_date
           );

        delete  from pay_org_payment_methods_f o
        where   o.rowid = chartorowid(P_ROW_ID);
--
-- ********************************************************************************
--
-- delete from MLS table (TL)
--
        delete from PAY_ORG_PAYMENT_METHODS_F_TL
        where ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
          and not exists
              (select null
                 from pay_org_payment_methods_f o
                where o.ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
                  and o.rowid <> chartorowid(P_ROW_ID));
--
        if sql%notfound then -- trap system errors during deletion
          hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token ('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.DELETE_TL_ROW');
        end if;
--
-- ********************************************************************************
--
end delete_row;
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
        p_row_id                           varchar2,
        p_org_payment_method_id            number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_base_opm_name                    varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_pay_gl_account_id                number,
        p_set_of_books_id                  number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number ) is
--
cursor OPM_CUR is
        select  *
        from    pay_org_payment_methods_f o
        where   o.rowid = chartorowid(P_ROW_ID)
        FOR     UPDATE OF ORG_PAYMENT_METHOD_ID NOWAIT;

cursor PGA_CUR is
       select *
       from     pay_payment_gl_accounts_f pga
       where    pga.pay_gl_account_id = p_pay_gl_account_id
       and      p_effective_start_date between pga.effective_start_date and
                pga.effective_end_date;
--
-- ***************************************************************************
--
OPM_REC OPM_CUR%rowtype;
PGA_REC PGA_CUR%rowtype;
--
begin
--
-- 115.4: ARUNDELL: Removed explicit lock of _TL table, the MLS strategy requires
-- that the base table is locked before update of the _TL table can take place,
-- which implies it is not necessary to lock both tables.
--
   open OPM_CUR;
--
   fetch OPM_CUR into OPM_REC;
--
   if (OPM_CUR%NOTFOUND) then
     close OPM_CUR;
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_org_payment_methods_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   close OPM_CUR;
--
--
   if p_pay_gl_account_id is not null then
     open PGA_CUR;
     fetch PGA_CUR into PGA_REC;

     if (PGA_CUR%NOTFOUND) then
       close PGA_CUR;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','pay_org_payment_methods_pkg.lock_row');
       hr_utility.set_message_token('STEP','2');
       hr_utility.raise_error;
     end if;

     close PGA_CUR;

   else
     pga_rec.set_of_books_id := p_set_of_books_id ;
     pga_rec.gl_cash_ac_id := p_gl_cash_ac_id ;
     pga_rec.gl_cash_clearing_ac_id := p_gl_cash_clearing_ac_id ;
     pga_rec.gl_control_ac_id := p_gl_control_ac_id ;
     pga_rec.gl_error_ac_id := p_gl_error_ac_id ;

   end if;

--
-- ***************************************************************************
--
OPM_REC.currency_code := rtrim(OPM_REC.currency_code);
OPM_REC.org_payment_method_name := rtrim(OPM_REC.org_payment_method_name);
OPM_REC.attribute_category := rtrim(OPM_REC.attribute_category);
OPM_REC.attribute1 := rtrim(OPM_REC.attribute1);
OPM_REC.attribute2 := rtrim(OPM_REC.attribute2);
OPM_REC.attribute3 := rtrim(OPM_REC.attribute3);
OPM_REC.attribute4 := rtrim(OPM_REC.attribute4);
OPM_REC.attribute5 := rtrim(OPM_REC.attribute5);
OPM_REC.attribute6 := rtrim(OPM_REC.attribute6);
OPM_REC.attribute7 := rtrim(OPM_REC.attribute7);
OPM_REC.attribute8 := rtrim(OPM_REC.attribute8);
OPM_REC.attribute9 := rtrim(OPM_REC.attribute9);
OPM_REC.attribute10 := rtrim(OPM_REC.attribute10);
OPM_REC.attribute11 := rtrim(OPM_REC.attribute11);
OPM_REC.attribute12 := rtrim(OPM_REC.attribute12);
OPM_REC.attribute13 := rtrim(OPM_REC.attribute13);
OPM_REC.attribute14 := rtrim(OPM_REC.attribute14);
OPM_REC.attribute15 := rtrim(OPM_REC.attribute15);
OPM_REC.attribute16 := rtrim(OPM_REC.attribute16);
OPM_REC.attribute17 := rtrim(OPM_REC.attribute17);
OPM_REC.attribute18 := rtrim(OPM_REC.attribute18);
OPM_REC.attribute19 := rtrim(OPM_REC.attribute19);
OPM_REC.attribute20 := rtrim(OPM_REC.attribute20);
OPM_REC.pmeth_information_category := rtrim(OPM_REC.pmeth_information_category);
OPM_REC.pmeth_information1 := rtrim(OPM_REC.pmeth_information1);
OPM_REC.pmeth_information2 := rtrim(OPM_REC.pmeth_information2);
OPM_REC.pmeth_information3 := rtrim(OPM_REC.pmeth_information3);
OPM_REC.pmeth_information4 := rtrim(OPM_REC.pmeth_information4);
OPM_REC.pmeth_information5 := rtrim(OPM_REC.pmeth_information5);
OPM_REC.pmeth_information6 := rtrim(OPM_REC.pmeth_information6);
OPM_REC.pmeth_information7 := rtrim(OPM_REC.pmeth_information7);
OPM_REC.pmeth_information8 := rtrim(OPM_REC.pmeth_information8);
OPM_REC.pmeth_information9 := rtrim(OPM_REC.pmeth_information9);
OPM_REC.pmeth_information10 := rtrim(OPM_REC.pmeth_information10);
OPM_REC.pmeth_information11 := rtrim(OPM_REC.pmeth_information11);
OPM_REC.pmeth_information12 := rtrim(OPM_REC.pmeth_information12);
OPM_REC.pmeth_information13 := rtrim(OPM_REC.pmeth_information13);
OPM_REC.pmeth_information14 := rtrim(OPM_REC.pmeth_information14);
OPM_REC.pmeth_information15 := rtrim(OPM_REC.pmeth_information15);
OPM_REC.pmeth_information16 := rtrim(OPM_REC.pmeth_information16);
OPM_REC.pmeth_information17 := rtrim(OPM_REC.pmeth_information17);
OPM_REC.pmeth_information18 := rtrim(OPM_REC.pmeth_information18);
OPM_REC.pmeth_information19 := rtrim(OPM_REC.pmeth_information19);
OPM_REC.pmeth_information20 := rtrim(OPM_REC.pmeth_information20);
OPM_REC.transfer_to_gl_flag := rtrim(OPM_REC.transfer_to_gl_flag);
OPM_REC.cost_payment := rtrim(OPM_REC.cost_payment);
OPM_REC.cost_cleared_payment := rtrim(OPM_REC.cost_cleared_payment);
OPM_REC.cost_cleared_void_payment := rtrim(OPM_REC.cost_cleared_void_payment);
OPM_REC.exclude_manual_payment := rtrim(OPM_REC.exclude_manual_payment);
--
if (((opm_rec.org_payment_method_id = p_org_payment_method_id )
or   (opm_rec.org_payment_method_id is null
and  (p_org_payment_method_id is null)))
and ((opm_rec.effective_start_date = p_effective_start_date  )
or   (opm_rec.effective_start_date is null
and  (p_effective_start_date is null)))
and ((opm_rec.effective_end_date = p_effective_end_date  )
or   (opm_rec.effective_end_date is null
and  (p_effective_end_date is null)))
and ((opm_rec.business_group_id = p_business_group_id    )
or   (opm_rec.business_group_id is null
and  (p_business_group_id is null)))
and ((opm_rec.external_account_id = p_external_account_id)
or   (opm_rec.external_account_id is null
and  (p_external_account_id is null)))
and ((opm_rec.currency_code = p_currency_code            )
or   (opm_rec.currency_code is null
and  (p_currency_code is null)))
and ((opm_rec.payment_type_id = p_payment_type_id        )
or   (opm_rec.payment_type_id is null
and  (p_payment_type_id is null)))
and ((opm_rec.defined_balance_id = p_defined_balance_id  )
or   (opm_rec.defined_balance_id is null
and  (p_defined_balance_id is null)))
and ((opm_rec.org_payment_method_name = p_base_opm_name  )
or   (opm_rec.org_payment_method_name is null
and  (p_base_opm_name is null)))
and ((opm_rec.comment_id = p_comment_id                  )
or   (opm_rec.comment_id is null
and  (p_comment_id is null)))
and ((opm_rec.attribute_category = p_attribute_category  )
or   (opm_rec.attribute_category is null
and  (p_attribute_category is null)))
and ((opm_rec.attribute1 = p_attribute1                  )
or   (opm_rec.attribute1 is null
and  (p_attribute1 is null)))
and ((opm_rec.attribute2 = p_attribute2                  )
or   (opm_rec.attribute2 is null
and  (p_attribute2 is null)))
and ((opm_rec.attribute3 = p_attribute3                  )
or   (opm_rec.attribute3 is null
and  (p_attribute3 is null)))
and ((opm_rec.attribute4 = p_attribute4                  )
or   (opm_rec.attribute4 is null
and  (p_attribute4 is null)))
and ((opm_rec.attribute5 = p_attribute5                  )
or   (opm_rec.attribute5 is null
and  (p_attribute5 is null)))
and ((opm_rec.attribute6 = p_attribute6                  )
or   (opm_rec.attribute6 is null
and  (p_attribute6 is null)))
and ((opm_rec.attribute7 = p_attribute7                  )
or   (opm_rec.attribute7 is null
and  (p_attribute7 is null)))
and ((opm_rec.attribute8 = p_attribute8                  )
or   (opm_rec.attribute8 is null
and  (p_attribute8 is null)))
and ((opm_rec.attribute9 = p_attribute9                  )
or   (opm_rec.attribute9 is null
and  (p_attribute9 is null)))
and ((opm_rec.attribute10 = p_attribute10                )
or   (opm_rec.attribute10 is null
and  (p_attribute10 is null)))
and ((opm_rec.attribute11 = p_attribute11                )
or   (opm_rec.attribute11 is null
and  (p_attribute11 is null)))
and ((opm_rec.attribute12 = p_attribute12                )
or   (opm_rec.attribute12 is null
and  (p_attribute12 is null)))
and ((opm_rec.attribute13 = p_attribute13                )
or   (opm_rec.attribute13 is null
and  (p_attribute13 is null)))
and ((opm_rec.attribute14 = p_attribute14                )
or   (opm_rec.attribute14 is null
and  (p_attribute14 is null)))
and ((opm_rec.attribute15 = p_attribute15                )
or   (opm_rec.attribute15 is null
and  (p_attribute15 is null)))
and ((opm_rec.attribute16 = p_attribute16                )
or   (opm_rec.attribute16 is null
and  (p_attribute16 is null)))
and ((opm_rec.attribute17 = p_attribute17                )
or   (opm_rec.attribute17 is null
and  (p_attribute17 is null)))
and ((opm_rec.attribute18 = p_attribute18                )
or   (opm_rec.attribute18 is null
and  (p_attribute18 is null)))
and ((opm_rec.attribute19 = p_attribute19                )
or   (opm_rec.attribute19 is null
and  (p_attribute19 is null)))
and ((opm_rec.attribute20 = p_attribute20                )
or   (opm_rec.attribute20 is null
and  (p_attribute20 is null)))
and ((opm_rec.pmeth_information_category = p_pmeth_information_category )
or   (opm_rec.pmeth_information_category is null
and  (p_pmeth_information_category is null)))
and ((opm_rec.pmeth_information1 = p_pmeth_information1  )
or   (opm_rec.pmeth_information1 is null
and  (p_pmeth_information1 is null)))
and ((opm_rec.pmeth_information2 = p_pmeth_information2  )
or   (opm_rec.pmeth_information2 is null
and  (p_pmeth_information2 is null)))
and ((opm_rec.pmeth_information3 = p_pmeth_information3  )
or   (opm_rec.pmeth_information3 is null
and  (p_pmeth_information3 is null)))
and ((opm_rec.pmeth_information4 = p_pmeth_information4  )
or   (opm_rec.pmeth_information4 is null
and  (p_pmeth_information4 is null)))
and ((opm_rec.pmeth_information5 = p_pmeth_information5  )
or   (opm_rec.pmeth_information5 is null
and  (p_pmeth_information5 is null)))
and ((opm_rec.pmeth_information6 = p_pmeth_information6  )
or   (opm_rec.pmeth_information6 is null
and  (p_pmeth_information6 is null)))
and ((opm_rec.pmeth_information7 = p_pmeth_information7  )
or   (opm_rec.pmeth_information7 is null
and  (p_pmeth_information7 is null)))
and ((opm_rec.pmeth_information8 = p_pmeth_information8  )
or   (opm_rec.pmeth_information8 is null
and  (p_pmeth_information8 is null)))
and ((opm_rec.pmeth_information9 = p_pmeth_information9  )
or   (opm_rec.pmeth_information9 is null
and  (p_pmeth_information9 is null)))
and ((opm_rec.pmeth_information10 = p_pmeth_information10)
or   (opm_rec.pmeth_information10 is null
and  (p_pmeth_information10 is null)))
and ((opm_rec.pmeth_information11 = p_pmeth_information11)
or   (opm_rec.pmeth_information11 is null
and  (p_pmeth_information11 is null)))
and ((opm_rec.pmeth_information12 = p_pmeth_information12)
or   (opm_rec.pmeth_information12 is null
and  (p_pmeth_information12 is null)))
and ((opm_rec.pmeth_information13 = p_pmeth_information13)
or   (opm_rec.pmeth_information13 is null
and  (p_pmeth_information13 is null)))
and ((opm_rec.pmeth_information14 = p_pmeth_information14)
or   (opm_rec.pmeth_information14 is null
and  (p_pmeth_information14 is null)))
and ((opm_rec.pmeth_information15 = p_pmeth_information15)
or   (opm_rec.pmeth_information15 is null
and  (p_pmeth_information15 is null)))
and ((opm_rec.pmeth_information16 = p_pmeth_information16)
or   (opm_rec.pmeth_information16 is null
and  (p_pmeth_information16 is null)))
and ((opm_rec.pmeth_information17 = p_pmeth_information17)
or   (opm_rec.pmeth_information17 is null
and  (p_pmeth_information17 is null)))
and ((opm_rec.pmeth_information18 = p_pmeth_information18)
or   (opm_rec.pmeth_information18 is null
and  (p_pmeth_information18 is null)))
and ((opm_rec.pmeth_information19 = p_pmeth_information19)
or   (opm_rec.pmeth_information19 is null
and  (p_pmeth_information19 is null)))
and ((opm_rec.pmeth_information20 = p_pmeth_information20)
or   (opm_rec.pmeth_information20 is null
and  (p_pmeth_information20 is null)))
and ((opm_rec.transfer_to_gl_flag = p_transfer_to_gl_flag)
or   (opm_rec.transfer_to_gl_flag is null
and  (p_transfer_to_gl_flag is null)))
and ((opm_rec.cost_payment = p_cost_payment)
or   (opm_rec.cost_payment is null
and  (p_cost_payment is null)))
and ((opm_rec.cost_cleared_payment = p_cost_cleared_payment)
or   (opm_rec.cost_cleared_payment is null
and  (p_cost_cleared_payment is null)))
and ((opm_rec.cost_cleared_void_payment = p_cost_cleared_void_payment)
or   (opm_rec.cost_cleared_void_payment is null
and  (p_cost_cleared_void_payment is null)))
and ((opm_rec.exclude_manual_payment = p_exclude_manual_payment)
or   (opm_rec.exclude_manual_payment is null
and  (p_exclude_manual_payment is null))) )
then
                return;  -- Row successfully locked, no clashes
end if;
--
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
--
end lock_row;
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
procedure update_row(
        p_row_id                           varchar2,
        p_org_payment_method_id            number,
        p_effective_start_date             date,
        p_effective_end_date               date,
        p_business_group_id                number,
        p_external_account_id              number,
        p_currency_code                    varchar2,
        p_payment_type_id                  number,
        p_defined_balance_id               number,
        p_org_payment_method_name          varchar2,
        p_comment_id                       number,
        p_attribute_category               varchar2,
        p_attribute1                       varchar2,
        p_attribute2                       varchar2,
        p_attribute3                       varchar2,
        p_attribute4                       varchar2,
        p_attribute5                       varchar2,
        p_attribute6                       varchar2,
        p_attribute7                       varchar2,
        p_attribute8                       varchar2,
        p_attribute9                       varchar2,
        p_attribute10                      varchar2,
        p_attribute11                      varchar2,
        p_attribute12                      varchar2,
        p_attribute13                      varchar2,
        p_attribute14                      varchar2,
        p_attribute15                      varchar2,
        p_attribute16                      varchar2,
        p_attribute17                      varchar2,
        p_attribute18                      varchar2,
        p_attribute19                      varchar2,
        p_attribute20                      varchar2,
        p_pmeth_information_category       varchar2,
        p_pmeth_information1               varchar2,
        p_pmeth_information2               varchar2,
        p_pmeth_information3               varchar2,
        p_pmeth_information4               varchar2,
        p_pmeth_information5               varchar2,
        p_pmeth_information6               varchar2,
        p_pmeth_information7               varchar2,
        p_pmeth_information8               varchar2,
        p_pmeth_information9               varchar2,
        p_pmeth_information10              varchar2,
        p_pmeth_information11              varchar2,
        p_pmeth_information12              varchar2,
        p_pmeth_information13              varchar2,
        p_pmeth_information14              varchar2,
        p_pmeth_information15              varchar2,
        p_pmeth_information16              varchar2,
        p_pmeth_information17              varchar2,
        p_pmeth_information18              varchar2,
        p_pmeth_information19              varchar2,
        p_pmeth_information20              varchar2,
        p_asset_code_combination_id        number,
        p_set_of_books_id                  number,
        p_dt_update_mode                   varchar2,
        p_base_opm_name                    varchar2,
        p_transfer_to_gl_flag              varchar2,
        p_cost_payment                     varchar2,
        p_cost_cleared_payment             varchar2,
        p_cost_cleared_void_payment        varchar2,
        p_exclude_manual_payment           varchar2,
        p_gl_set_of_books_id               number,
        p_gl_cash_ac_id                    number,
        p_gl_cash_clearing_ac_id           number,
        p_gl_control_ac_id                 number,
        p_gl_error_ac_id                   number,
        p_default_gl_account               varchar2,
        p_bank_account_id                  number,
        p_pay_gl_account_id_out            out nocopy number
        ) is
--
begin

-- check whether this should be a DT update or not
-- if null then just update the TL table
-- acedward 16/05/2000

 if p_dt_update_mode is not null then

   update pay_org_payment_methods_f o
   set  o.org_payment_method_id = P_ORG_PAYMENT_METHOD_ID,
        o.effective_start_date = P_EFFECTIVE_START_DATE,
        o.effective_end_date = P_EFFECTIVE_END_DATE,
        o.business_group_id = P_BUSINESS_GROUP_ID,
        o.external_account_id = P_EXTERNAL_ACCOUNT_ID,
        o.currency_code = P_CURRENCY_CODE,
        o.payment_type_id = P_PAYMENT_TYPE_ID,
        o.defined_balance_id = P_DEFINED_BALANCE_ID,
        o.comment_id = P_COMMENT_ID,
        o.attribute_category = P_ATTRIBUTE_CATEGORY,
        o.attribute1 = P_ATTRIBUTE1,
        o.attribute2 = P_ATTRIBUTE2,
        o.attribute3 = P_ATTRIBUTE3,
        o.attribute4 = P_ATTRIBUTE4,
        o.attribute5 = P_ATTRIBUTE5,
        o.attribute6 = P_ATTRIBUTE6,
        o.attribute7 = P_ATTRIBUTE7,
        o.attribute8 = P_ATTRIBUTE8,
        o.attribute9 = P_ATTRIBUTE9,
        o.attribute10 = P_ATTRIBUTE10,
        o.attribute11 = P_ATTRIBUTE11,
        o.attribute12 = P_ATTRIBUTE12,
        o.attribute13 = P_ATTRIBUTE13,
        o.attribute14 = P_ATTRIBUTE14,
        o.attribute15 = P_ATTRIBUTE15,
        o.attribute16 = P_ATTRIBUTE16,
        o.attribute17 = P_ATTRIBUTE17,
        o.attribute18 = P_ATTRIBUTE18,
        o.attribute19 = P_ATTRIBUTE19,
        o.attribute20 = P_ATTRIBUTE20,
        o.pmeth_information_category = P_PMETH_INFORMATION_CATEGORY,
        o.pmeth_information1 = P_PMETH_INFORMATION1,
        o.pmeth_information2 = P_PMETH_INFORMATION2,
        o.pmeth_information3 = P_PMETH_INFORMATION3,
        o.pmeth_information4 = P_PMETH_INFORMATION4,
        o.pmeth_information5 = P_PMETH_INFORMATION5,
        o.pmeth_information6 = P_PMETH_INFORMATION6,
        o.pmeth_information7 = P_PMETH_INFORMATION7,
        o.pmeth_information8 = P_PMETH_INFORMATION8,
        o.pmeth_information9 = P_PMETH_INFORMATION9,
        o.pmeth_information10 = P_PMETH_INFORMATION10,
        o.pmeth_information11 = P_PMETH_INFORMATION11,
        o.pmeth_information12 = P_PMETH_INFORMATION12,
        o.pmeth_information13 = P_PMETH_INFORMATION13,
        o.pmeth_information14 = P_PMETH_INFORMATION14,
        o.pmeth_information15 = P_PMETH_INFORMATION15,
        o.pmeth_information16 = P_PMETH_INFORMATION16,
        o.pmeth_information17 = P_PMETH_INFORMATION17,
        o.pmeth_information18 = P_PMETH_INFORMATION18,
        o.pmeth_information19 = P_PMETH_INFORMATION19,
        o.pmeth_information20 = P_PMETH_INFORMATION20,
        o.ORG_PAYMENT_METHOD_NAME = p_base_opm_name,
        o.transfer_to_gl_flag = p_transfer_to_gl_flag ,
        o.cost_payment = p_cost_payment ,
        o.cost_cleared_payment = p_cost_cleared_payment ,
        o.cost_cleared_void_payment = p_cost_cleared_void_payment ,
        o.exclude_manual_payment = p_exclude_manual_payment
   where o.rowid = chartorowid(P_ROW_ID);
--
-- ****************************************************************************************
--
--  update MLS table (TL)
--
  update PAY_ORG_PAYMENT_METHODS_F_TL set
    ORG_PAYMENT_METHOD_NAME = P_ORG_PAYMENT_METHOD_NAME,
    LAST_UPDATE_DATE = sysdate,
    SOURCE_LANG = userenv('LANG')
  where ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
--
  if (sql%notfound) then  -- trap system errors during update
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.UPDATE_TL_ROW');
  end if;
--
-- ***************************************************************************************

  -- cash management integration: update asset_code_combination_id in
  -- ap_bank_branches_all for the bank account associated with
  -- this payment method.  only do this if cash management integration
  -- is active, i.e. both payroll and cash management are installed.

  if pay_ce_support_pkg.pay_and_ce_licensed then

     --   Bug No. 4644827
     --   for r11.5 the same functionality is done through database trigger. Code
     --   is for R12
          if p_external_account_id is not null then
             pay_maintain_bank_acct.update_payroll_bank_acct(
        	      p_bank_account_id     => p_bank_account_id,
                      p_external_account_id => p_external_account_id,
		      p_org_payment_method_id => P_ORG_PAYMENT_METHOD_ID);
          end if;
     --

     --Bug No. 4644827
     pay_maintain_bank_acct.update_asset_ccid(
                   p_assest_ccid              =>p_asset_code_combination_id,
                   p_set_of_books_id          =>p_set_of_books_id,
                   p_external_account_id      =>p_external_account_id
                   );

  end if;

  -- Costing of Payment changes

  PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW
   ( P_EFFECTIVE_START_DATE => p_effective_start_date,
     P_EFFECTIVE_END_DATE   => p_effective_end_date,
     P_SET_OF_BOOKS_ID      => p_gl_set_of_books_id,
     P_GL_CASH_AC_ID        => p_gl_cash_ac_id,
     P_GL_CASH_CLEARING_AC_ID => p_gl_cash_clearing_ac_id,
     P_GL_CONTROL_AC_ID       => p_gl_control_ac_id,
     P_GL_ERROR_AC_ID         => p_gl_error_ac_id,
     P_EXTERNAL_ACCOUNT_ID    => p_external_account_id,
     P_ORG_PAYMENT_METHOD_ID  => p_org_payment_method_id,
     P_DT_UPDATE_MODE         => p_dt_update_mode,
     P_DEFAULT_GL_ACCOUNT     => p_default_gl_account,
     P_PAY_GL_ACCOUNT_ID_OUT  => p_pay_gl_account_id_out
   );

 else
 -- do a non DT update
 --  update MLS table (TL)
 --
  update PAY_ORG_PAYMENT_METHODS_F_TL set
    ORG_PAYMENT_METHOD_NAME = P_ORG_PAYMENT_METHOD_NAME,
    LAST_UPDATE_DATE = sysdate,
    SOURCE_LANG = userenv('LANG')
  where ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
 --
  if (sql%notfound) then        -- trap system errors during update
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.UPDAT
E_TL_ROW');
  end if;
 --

 end if;
 --

--
end update_row;
--
------------------------------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_ORG_PAYMENT_METHODS_F_TL T
  where not exists
    (select NULL
    from PAY_ORG_PAYMENT_METHODS_F B
    where B.ORG_PAYMENT_METHOD_ID = T.ORG_PAYMENT_METHOD_ID
    );

  update PAY_ORG_PAYMENT_METHODS_F_TL T set (
      ORG_PAYMENT_METHOD_NAME
    ) = (select
      B.ORG_PAYMENT_METHOD_NAME
    from PAY_ORG_PAYMENT_METHODS_F_TL B
    where B.ORG_PAYMENT_METHOD_ID = T.ORG_PAYMENT_METHOD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORG_PAYMENT_METHOD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ORG_PAYMENT_METHOD_ID,
      SUBT.LANGUAGE
    from PAY_ORG_PAYMENT_METHODS_F_TL SUBB, PAY_ORG_PAYMENT_METHODS_F_TL SUBT
    where SUBB.ORG_PAYMENT_METHOD_ID = SUBT.ORG_PAYMENT_METHOD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ORG_PAYMENT_METHOD_NAME <> SUBT.ORG_PAYMENT_METHOD_NAME
  ));

  insert into PAY_ORG_PAYMENT_METHODS_F_TL (
    ORG_PAYMENT_METHOD_ID,
    ORG_PAYMENT_METHOD_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_PAYMENT_METHOD_ID,
    B.ORG_PAYMENT_METHOD_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_ORG_PAYMENT_METHODS_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_ORG_PAYMENT_METHODS_F_TL T
    where T.ORG_PAYMENT_METHOD_ID = B.ORG_PAYMENT_METHOD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
-------------------------------------------------------------------------
procedure check_end_date(p_end_date varchar2,
                         p_opm_id number)is
l_dummy varchar2(10);
begin
--
--first check if there are any ppm's based on the opm with an end date
-- greater than the opm's end date.
--
  select null
  into l_dummy
  from pay_personal_payment_methods_f
  where org_payment_method_id = p_opm_id
  and   effective_end_date > fnd_date.canonical_to_date(p_end_date);
  if (SQL%FOUND) then
   hr_utility.set_message(801, 'HR_6235_PAYM_EXISTING_PPMS');
   hr_utility.raise_error;
  end if;
-- now check if there are any opmu's using this opm with an end date
--greater than the new end_date
  select null
  into l_dummy
  from pay_org_pay_method_usages_f
  where org_payment_method_id = p_opm_id
  and   effective_end_date > fnd_date.canonical_to_date(p_end_date);
  if (SQL%FOUND) then
   hr_utility.set_message(801, 'HR_6236_PAYM_USED_AS_DEFAULT');
   hr_utility.raise_error;
  end if;
  exception
  when no_data_found then
    null;
  when others then
    null;
end check_end_date;

function chk_dflt_prpy_ppm(opm_id varchar2,
                           val_start_date varchar2) return boolean is
begin
  return(hr_payments.check_default(opm_id,val_start_date)
     AND hr_payments.check_prepay(to_number(opm_id),val_start_date)
     AND hr_payments.check_ppm(opm_id,val_start_date));
end chk_dflt_prpy_ppm;
-----------------------------------------------------------------------------
procedure unique_chk(O_ORG_PAYMENT_METHOD_NAME in VARCHAR2, O_EFFECTIVE_START_DATE in date,
                     O_EFFECTIVE_END_DATE in date)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM pay_org_payment_methods_f
  WHERE ORG_PAYMENT_METHOD_NAME = O_ORG_PAYMENT_METHOD_NAME
    and EFFECTIVE_START_DATE = O_EFFECTIVE_START_DATE
    and EFFECTIVE_END_DATE = O_EFFECTIVE_END_DATE
    and O_ORG_PAYMENT_METHOD_NAME is not NULL
    and O_EFFECTIVE_START_DATE is not NULL
    and O_EFFECTIVE_END_DATE is not NULL
    and BUSINESS_GROUP_ID is NULL;
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
end unique_chk;
--------------------------------------------------------------------------------
function payee_type(p_payee_type varchar2,
                    p_payee_id   number,
                    p_effective_date date) return varchar2 is
--
  CURSOR c_person IS
     SELECT per.full_name
     FROM   per_all_people_f per
     WHERE  per.person_id = p_payee_id
     AND    p_effective_date BETWEEN per.effective_start_date
                                 AND per.effective_end_date;
  CURSOR c_org IS
     SELECT org.name
     FROM   hr_all_organization_units org
     WHERE  org.organization_id = p_payee_id;
--
  l_payee_name per_people_f.full_name%TYPE;
begin
   IF p_payee_type = 'P' THEN
     OPEN c_person;
     FETCH c_person INTO l_payee_name;
     CLOSE c_person;
   ELSIF p_payee_type = 'O' THEN
     OPEN c_org;
     FETCH c_org INTO l_payee_name;
     CLOSE c_org;
   ELSE
     l_payee_name := NULL;
   END IF;
   RETURN l_payee_name;
exception
   WHEN no_data_found THEN
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.PAYEE_TYPE');
      hr_utility.set_message_token('STEP','2');
      hr_utility.raise_error;
end payee_type;
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_O_ORG_PAYMENT_METHOD_NAME in varchar2,
   X_O_EFFECTIVE_START_DATE in date,
   X_O_EFFECTIVE_END_DATE in date,
   X_ORG_PAYMENT_METHOD_NAME in varchar2,
   X_OWNER in varchar2 ) is
begin
  -- unique_chk(X_O_ORG_PAYMENT_METHOD_NAME,X_O_EFFECTIVE_START_DATE,X_O_EFFECTIVE_END_DATE);
  --
  UPDATE pay_org_payment_methods_f_tl
    SET  ORG_PAYMENT_METHOD_NAME = nvl(X_ORG_PAYMENT_METHOD_NAME,ORG_PAYMENT_METHOD_NAME),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND ORG_PAYMENT_METHOD_ID in
        (select ORG_PAYMENT_METHOD_ID
           from pay_org_payment_methods_f
          WHERE ORG_PAYMENT_METHOD_NAME = X_O_ORG_PAYMENT_METHOD_NAME
            and EFFECTIVE_START_DATE = X_O_EFFECTIVE_START_DATE
            and EFFECTIVE_END_DATE = X_O_EFFECTIVE_END_DATE
            and X_O_ORG_PAYMENT_METHOD_NAME is not NULL
            and X_O_EFFECTIVE_START_DATE is not NULL
            and X_O_EFFECTIVE_END_DATE is not NULL
            and BUSINESS_GROUP_ID is NULL);
  --
  if (sql%notfound) then  -- trap system errors during update
  --   hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  --   hr_utility.set_message_token ('PROCEDURE','PAY_ORG_PAYMENT_METHODS_PKG.TRANSLATE_ROW');
  --   hr_utility.set_message_token('STEP','1');
  --   hr_utility.raise_error;
  null;
  end if;
end TRANSLATE_ROW;
--------------------------------------------------------------------------------
procedure lock_aba_row(
        p_external_account_id   in  number,
        p_set_of_books_id       in  number,
        p_asset_code_combination_id in  number ) is
--
begin
--
  if p_external_account_id is not null then

  --Bug No. 4644827
  pay_maintain_bank_acct.lock_row(
          p_external_account_id   => p_external_account_id
          );

 end if;
--
end lock_aba_row;
--------------------------------------------------------------------------------
END pay_org_payment_methods_pkg;

/
