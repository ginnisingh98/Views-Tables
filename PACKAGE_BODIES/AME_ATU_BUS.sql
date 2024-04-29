--------------------------------------------------------
--  DDL for Package Body AME_ATU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATU_BUS" as
/* $Header: amaturhi.pkb 120.6 2006/02/15 04:04 prasashe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_atu_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< inputToCanonStaticCurUsage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to convert the input attribute usage to canonical
--
-- Pre Conditions:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function inputToCanonStaticCurUsage(p_attribute_id in integer,
                                    p_application_id in integer,
                                    p_query_string varchar2) return varchar2 as
    l_proc                  varchar2(72) := g_package||'inputToCanonStaticCurUsage';
    amount ame_util.attributeValueType;
    conversionType ame_util.attributeValueType;
    convTypeException exception;
    curCodeException exception;
    currencyCode ame_util.attributeValueType;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      /*
        The ame_util.parseStaticCurAttValue procedure parses the usage, if it is parse-able;
        but it doesn't validate the individual values, or convert the amount to canonical format.
      */
      ame_util.parseStaticCurAttValue(applicationIdIn => p_application_id,
                                      attributeIdIn => p_attribute_id,
                                      attributeValueIn => p_query_string,
                                      amountOut => amount,
                                      localErrorIn => true,
                                      currencyOut => currencyCode,
                                      conversionTypeOut => conversionType);
      /* ame_util.inputNumStringToCanonNumString validates and formats the amount. */
      amount := ame_util.inputNumStringToCanonNumString(inputNumberStringIn => amount,
                                                        currencyCodeIn => currencyCode);
      if not ame_util.isCurrencyCodeValid(currencyCodeIn => currencyCode) then
        fnd_message.set_name('PER', 'AME_400151_ATT_STA_CURR_INV');
        fnd_message.raise_error;
      end if;
      if not ame_util.isConversionTypeValid(conversionTypeIn => conversionType) then
        fnd_message.set_name('PER', 'AME_400150_ATT_STA_CONV_INV');
        fnd_message.raise_error;
      end if;
      return(amount || ',' || currencyCode || ',' || conversionType);
      exception
        when app_exception.application_exception  then
          if hr_multi_message.exception_add
             (p_associated_column1 => 'QUERY_STRING') then
            hr_utility.set_location(' Leaving:'|| l_proc, 50);
            raise;
          end if;
          hr_utility.set_location(' Leaving:'|| l_proc, 60);
          return(null);
  end inputToCanonStaticCurUsage;
-- ---------------------------------------------------------------------
-- |---------------------------< isNumber >----------------------------|
-- ---------------------------------------------------------------------
function isNumber
  (p_string varchar2) return Boolean Is

  l_num               number;
  l_number_exception  exception;
  PRAGMA EXCEPTION_INIT (l_number_exception, -6502);

  begin
  --
    l_num := to_number(p_string);
    return (true);
  exception
    when l_number_exception then
      return (false);
    when others then
      return (false);
 end isNumber;
--
--
-- ---------------------------------------------------------------------
-- |---------------------------< chk_ame_date_format >----------------------------|
-- ---------------------------------------------------------------------
function chk_ame_date_format
  (p_string varchar2) return Boolean Is
  l_date               date;
  begin
    begin
      l_date := to_date(p_string,'YYYY:MM:DD:HH24:MI:SS');
      if instrb(upper(p_string),'JAN',1,1) <> 0 or
         instrb(upper(p_string),'FEB',1,1) <> 0 or
         instrb(upper(p_string),'MAR',1,1) <> 0 or
         instrb(upper(p_string),'APR',1,1) <> 0 or
         instrb(upper(p_string),'MAY',1,1) <> 0 or
         instrb(upper(p_string),'JUN',1,1) <> 0 or
         instrb(upper(p_string),'JUL',1,1) <> 0 or
         instrb(upper(p_string),'AUG',1,1) <> 0 or
         instrb(upper(p_string),'SEP',1,1) <> 0 or
         instrb(upper(p_string),'OCT',1,1) <> 0 or
         instrb(upper(p_string),'NOV',1,1) <> 0 or
         instrb(upper(p_string),'DEC',1,1) <> 0 then
        return (false);
      else
        return (true);
      end if;
    exception
      when others then
        return(false);
    end;
 end chk_ame_date_format;
--
--

--  ---------------------------------------------------------------------------
--  |----------------------< chk_attribute_item_class >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_attribute_item_class
    (p_application_id   in number,
     p_attribute_id   in number
     ) is
     l_item_class_id  integer;
     l_exists varchar2(1);
     l_proc              varchar2(72)  :=  g_package||'chk_attribute_item_class';
   cursor c_sel1 is
     select null
        from  ame_item_class_usages
           where application_id = p_application_id and item_class_id =
            ( select item_class_id from ame_attributes
               where attribute_id = p_attribute_id and sysdate between start_date
                 and nvl(end_date - ame_util.oneSecond,sysdate))
                   and sysdate between start_date and nvl(end_date - ame_util.oneSecond,sysdate);
begin
open c_sel1;
fetch c_sel1 into l_exists;
   if c_sel1%notfound then
    close c_sel1;
     fnd_message.set_name('PER','AME_400521_ATT_NO_IC_USG_EXIST');
     fnd_message.raise_error;
  end if;
  close c_sel1;

exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'APPLICATION_ID') then
        hr_utility.set_location(' Leaving:'|| l_proc, 50);
        raise;
      end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_attribute_item_class;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_attribute_approver_type >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_attribute_approver_type
    (p_application_id   in number,
     p_attribute_id   in number
     ) is
     l_proc              varchar2(72)  :=  g_package||'chk_attribute_approver_type';
     l_item_class_id  integer;
     l_approver_type_id integer;
     l_exists varchar2(1);
     l_variable_value varchar2(200);
     l_orig_system varchar2(48);
     begin

     select approver_type_id
     into l_approver_type_id
        from ame_attributes
          where attribute_id = p_attribute_id and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate) ;

    if l_approver_type_id is not null then
    begin
      select variable_value
            into l_variable_Value
            from ame_config_vars
            where
              variable_name = 'allowAllApproverTypes' and
              application_id = p_application_id and
              sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);

      --If no transaction-type-specific config var exists, revert to the application-wide value. */

       exception
        when no_data_found then
               select variable_value
                 into l_variable_Value
                 from ame_config_vars
                where
                  variable_name = 'allowAllApproverTypes' and
                  application_id = 0 and
                  sysdate between start_date and
                     nvl(end_date - ame_util.oneSecond, sysdate) ;
       end ;
  if l_variable_Value = 'no' then
      select orig_system into l_orig_system from ame_approver_types
        where approver_type_id = l_approver_type_id and
                    sysdate between start_date and
                     nvl(end_date - ame_util.oneSecond, sysdate) ;
      if l_orig_system = 'POS' then
        fnd_message.set_name('PER','AME_400522_ATT_NO_APPR_TYP_USG');
        fnd_message.raise_error;
      end if;
   end if;
end if;

exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'APPLICATION_ID') then
        hr_utility.set_location(' Leaving:'|| l_proc, 50);
        raise;
      end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);

end chk_attribute_approver_type;
--
--

--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_value_set_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_value_set_id
    (p_value_set_id in number)is
     l_count number;
     l_proc              varchar2(72)  :=  g_package||'chk_value_set_id';
begin
      if p_value_set_id is not null then
         select count(*) into l_count
           from fnd_flex_value_sets
            where flex_value_set_id = p_value_set_id and
             instr(flex_value_set_name,'$') = 0 ;
            if l_count = 0 then
              fnd_message.set_name('PER','AME_400553_VAL_SET_ID_NOT_EX');
              fnd_message.raise_error;
            end if;
         end if;

 exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'VALUE_SET_ID') then
        hr_utility.set_location(' Leaving:'|| l_proc, 50);
        raise;
      end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_value_set_id;

--

--

----------------------------------------------------------------------------
--  |----------------------< chk_attr_type_value_set_id_comb >--------------------------|
--  ---------------------------------------------------------------------------
--
--
procedure chk_attr_type_val_set_id_comb
    (p_attribute_id   in number,
     p_value_set_id in number
     ) is
    l_attribute_type    ame_attributes.attribute_type%type;
    l_format_type       varchar2(1);
    l_proc              varchar2(72)  :=  g_package||'chk_attr_type_value_set_id_comb';
   begin
    select attribute_type
       into l_attribute_type
     from ame_attributes
       where attribute_id = p_attribute_id
         and sysdate between start_date and
           nvl(end_date - ame_util.oneSecond, sysdate) ;
    if (l_attribute_type = ame_util.booleanAttributeType)
      or (l_attribute_type = ame_util.dateAttributeType) then
      if p_value_set_id is not null then
        fnd_message.set_name('PER','AME_400554_VAL_SET_ID_NULL');
              fnd_message.raise_error;
      end if;
  elsif p_value_set_id is not null then
   select format_type into l_format_type
     from fnd_flex_value_sets
       where flex_value_set_id = p_value_set_id and
          instr(flex_value_set_name,'$') = 0 ;

     if ((l_attribute_type = ame_util.currencyAttributeType)
         or (l_attribute_type = ame_util.numberAttributeType)) and
           l_format_type <> 'N' then
          fnd_message.set_name('PER','AME_400555_INV_VAL_SET_FORMAT');
          fnd_message.raise_error;
     elsif (l_attribute_type = ame_util.stringAttributeType) and
        l_format_type <> 'C' then
          fnd_message.set_name('PER','AME_400555_INV_VAL_SET_FORMAT');
          fnd_message.raise_error;
      end if;
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'ATTRIBUTE_ID') then
        hr_utility.set_location(' Leaving:'|| l_proc, 50);
        raise;
      end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
 end chk_attr_type_val_set_id_comb;
--
--



--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_attribute_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the attribute_id is a foreign key to ame_attributes.attribute_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_attribute_id
  (p_attribute_id   in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_attribute_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_attributes
      where
        attribute_id = p_attribute_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    fnd_message.set_name('PER','AME_400473_INV_ATTRIBUTE_ID');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_attribute_id;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_application_id     >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the application_id is a foreign key to ame_calling_apps.application_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_id
  (p_application_id   in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_application_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_calling_apps
      where
        application_id = p_application_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    fnd_message.set_name('PER','AME_400474_INV_APPLICATION_ID');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'APPLICATION_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_application_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_primary_key      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the combination of attribute_id and application_id is unique.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_effective_date
--   p_application_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_primary_key
  (p_attribute_id   in number,
   p_effective_date        in date,
   p_application_id in ame_attribute_usages.application_id%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_primary_key';
  tempCount integer;
  cursor c_sel1 is
    select count(*)
      from ame_attribute_usages
      where
        attribute_id = p_attribute_id and
        application_id = p_application_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'application_id'
    ,p_argument_value => p_application_id
    );
  open c_sel1;
  fetch c_sel1 into tempCount;
  if c_sel1%found and
     tempCount > 0 then
    close c_sel1;
    fnd_message.set_name('PER','AME_400031_ATT_EXISTS_HD');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'APPLICATION_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_primary_key;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_is_static      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the is_static  field has a value of either ame_util.booleanTrue
--   or ame_util.booleanFalse
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_is_static
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_is_static
  ( p_is_static in ame_attribute_usages.is_static%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_is_static';
begin
  if NOT (p_is_static = ame_util.booleanTrue or
          (p_is_static = ame_util.booleanFalse )) then
    fnd_message.set_name('PER','AME_400475_INV_USAGE_TYPE');
    fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'IS_STATIC') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_is_static;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_qry_string_is_static_comb        >---------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the Query string is valid for the value of is_static specified.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_is_static
--   p_query_string
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_qry_string_is_static_comb
  ( p_is_static    in ame_attribute_usages.is_static%type,
    p_query_string in ame_attribute_usages.query_string%type ) is

  l_proc                       varchar2(72)  :=  g_package||'chk_qry_string_is_static_comb';
  queryString                  ame_attribute_usages.query_string%type;
  queryString1                 ame_attribute_usages.query_string%type;
  tempInt                      integer;
  transIdPlaceholderPosition   integer;
  transIdPlaceholderPosition2  integer;
  upperTransIdPlaceholder      varchar2(100);
begin
  if (p_is_static = ame_util.booleanTrue ) then  /* static usage */
    -- Check that the query string does not contain any transaction id placeholder
    queryString := ame_util.removeReturns(stringIn => p_query_string,
                                          replaceWithSpaces => false);
    if(instrb(upper(p_query_string), upper(ame_util.transactionIdPlaceholder))) > 0 then
      fnd_message.set_name('PER','AME_400159_ATT_STAT_NOT_PLC');
      fnd_message.raise_error;
    end if;
  else /* dynamic usage (actual query string) */
    if(p_query_string is null) then
      fnd_message.set_name('PER','AME_400671_DYN_ATT_EMP_USAGE');
      fnd_message.raise_error;
    end if;
    if(instrb(p_query_string, ';', 1, 1) > 0) or
       (instrb(p_query_string, '--', 1, 1) > 0) or
       (instrb(p_query_string, '/*', 1, 1) > 0) or
       (instrb(p_query_string, '*/', 1, 1) > 0) then
      fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
      fnd_message.raise_error;
    end if;
    tempInt := 1;
    queryString := upper(p_query_string);
    upperTransIdPlaceholder := upper(ame_util.transactionIdPlaceholder);
    loop
      transIdPlaceholderPosition :=
          instrb(queryString, upperTransIdPlaceholder, 1, tempInt);
      if(transIdPlaceholderPosition = 0) then
        exit;
      end if;
      transIdPlaceholderPosition2 :=
          instrb(p_query_string, ame_util.transactionIdPlaceholder, 1, tempInt);
      if(transIdPlaceholderPosition <> transIdPlaceholderPosition2) then
        fnd_message.set_name('PER','AME_400414_DYNAMIC_ATTR_USAGES');
        fnd_message.raise_error;
      end if;
      tempInt := tempInt + 1;
    end loop;
    if(ame_util.isArgumentTooLong(tableNameIn => 'ame_attribute_usages',
                                  columnNameIn => 'query_string',
                                  argumentIn => p_query_string)) then
        fnd_message.set_name('PER','AME_400163_ATT_USAGE_LONG');
        fnd_message.raise_error;
    end if;
    /* The following utility handles the error. So nothing needs to be done here */
    ame_util.checkForSqlInjection(queryStringIn => queryString);
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'QUERY_STRING_IS_STATIC') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_qry_string_is_static_comb;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_qry_str_static_attr_comb  >--------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates the Query string for the attribute type and the value of is_static.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_application_id
--   p_is_static
--   p_query_string
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_qry_str_static_attr_comb
  ( p_attribute_id   in ame_attribute_usages.attribute_id%type,
    p_application_id in ame_attribute_usages.application_id%type,
    p_is_static      in ame_attribute_usages.is_static%type,
    p_query_string   in ame_attribute_usages.query_string%type,
    p_effective_date in date ) is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_qry_str_static_attr_comb';
  charMonths          ame_util.stringList;
  comma1Location      integer;
  comma2Location      integer;
  queryString         ame_attribute_usages.query_string%type;
  queryString1        ame_attribute_usages.query_string%type;
  l_tmpQueryString    ame_attribute_usages.query_string%type;
  l_amount            ame_attribute_usages.query_string%type;
  l_currencyCode      ame_attribute_usages.query_string%type;
  l_conversionType    ame_attribute_usages.query_string%type;
  l_tmpAmount         ame_attribute_usages.query_string%type;
  l_attribute_type    ame_attributes.attribute_type%type;
  l_attribute_name    ame_attributes.name%type;
  numMonths           ame_util.stringList;
  substitutionString  ame_util.stringType;
  transIdPlaceholderPosition   integer;
  transIdPlaceholderPosition2  integer;
  l_comma1Location             integer;
  l_comma2Location             integer;
  l_rgeflg                       varchar2(30);
  upperTransIdPlaceholder      varchar2(100);
  l_attr_name         varchar2(50);
  l_columns           number;
  l_valid             varchar2(1000);
  l_object            varchar2(20);
begin
  -- get attribute type
  select name,attribute_type
    into l_attribute_name,l_attribute_type
    from ame_attributes
    where attribute_id = p_attribute_id
      and p_effective_date between start_date and
          nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  if (p_is_static = ame_util.booleanTrue ) then  /* static usage */
    /* Check that the format of the static usage is correct. */
    if(l_attribute_type = ame_util.currencyAttributeType) then
      if p_query_string is not null then
        l_comma1Location := instrb(p_query_string, ',', -1, 2);
        l_comma2Location := instrb(p_query_string, ',', -1, 1);
          if(l_comma1Location = 0 or
             l_comma2Location = 0 or
             l_comma1Location < 2 or
             l_comma2Location < 4) then
               fnd_message.set_name('PER', 'AME_400670_BAD_STAT_CURR_USG');
               fnd_message.set_token('ATTRIBUTE',l_attribute_name);
               fnd_message.raise_error;
           end if;
         l_amount := substrb(p_query_string, 1, l_comma1Location - 1);
         l_currencyCode := substrb(p_query_string, l_comma1Location + 1, l_comma2Location - l_comma1Location - 1);
         l_conversionType := substrb(p_query_string, l_comma2Location + 1, lengthb(p_query_string) - l_comma2Location);
           if not ame_util.isCurrencyCodeValid(currencyCodeIn => l_currencyCode) then
             fnd_message.set_name('PER', 'AME_400151_ATT_STA_CURR_INV');
             fnd_message.raise_error;
           end if;
         l_tmpAmount := replace(l_amount,',','.');
         hr_chkfmt.checkformat(value     => l_tmpAmount,
                                 format    => 'M',
                                 output    => l_amount,
                                 minimum   => null,
                                 maximum   => null,
                                 nullok    => 'Y',
                                 rgeflg    => l_rgeflg,
                                 curcode   => l_currencyCode);
         if not ame_util.isConversionTypeValid(conversionTypeIn => l_conversionType) then
           fnd_message.set_name('PER', 'AME_400150_ATT_STA_CONV_INV');
           fnd_message.raise_error;
         end if;
       else
             fnd_message.set_name('PER', 'AME_400670_BAD_STAT_CURR_USG');
             fnd_message.set_token('ATTRIBUTE',l_attribute_name);
             fnd_message.raise_error;
       end if;
    elsif(l_attribute_type = ame_util.numberAttributeType) then
      if p_query_string is not null and not isNumber(p_query_string) then
        fnd_message.set_name('PER','AME_400516_ATT_STAT_USG_NUM');
        fnd_message.raise_error;
      elsif p_query_string is not null then
        l_tmpQueryString := replace(p_query_string,',','.');
        hr_chkfmt.checkformat(value     => l_tmpQueryString,
                              format    => 'N',
                              output    => queryString,
                              minimum   => null,
                              maximum   => null,
                              nullok    => 'Y',
                              rgeflg    => l_rgeflg,
                              curcode   => null);
      end if;
    elsif(l_attribute_type = ame_util.stringAttributeType) then
      if(instrb(p_query_string, '''') > 0) or length(p_query_string) > ame_util.stringTypeLength then
        fnd_message.set_name('PER','AME_400166_ATT_STAT_USG_STRING');
        fnd_message.raise_error;
      end if;
      begin
        select name
          into l_attr_name
          from ame_attributes
         where attribute_id = p_attribute_id
           and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
        if l_attr_name = 'REJECTION_RESPONSE' and p_query_string is not null then
          if p_query_string not in ('STOP_ALL_ITEMS'
                                   ,'CONTINUE_ALL_OTHER_ITEMS'
                                   ,'CONTINUE_OTHER_SUBORDINATE_ITEMS') then
            fnd_message.set_name('PER','AME_400785_REJ_RESP_USG_INV');
            fnd_message.raise_error;
          end if;
        end if;
      exception
        when no_data_found then
          null;
      end;
    elsif(l_attribute_type = ame_util.booleanAttributeType) then
      if trim(p_query_string)  IN ('true','false') then
        querystring :=lower(trim( p_query_string));
      else
        fnd_message.set_name('PER','AME_400167_ATT_STAT_USG_BOOL');
        fnd_message.raise_error;
      end if;
    elsif(l_attribute_type = ame_util.dateAttributeType) then
      /* check to make sure the user entered the date in the correct format */
      begin
        if(p_query_string is not null) then
         if instrb(p_query_string, ':', 1, 5) = 0 or
            not chk_ame_date_format(p_query_string) then
                fnd_message.set_name('PER','AME_400168_ATT_STAT_USG_DATE');
                fnd_message.raise_error;
          end if;
        end if;
      exception
        when app_exception.application_exception then
          if hr_multi_message.exception_add
            (p_associated_column1 => 'chk_qry_str_static_attr_comb') then
             hr_utility.set_location(' Leaving:'|| l_proc, 50);
             raise;
          end if;
          hr_utility.set_location(' Leaving:'|| l_proc, 60);
      end;
    end if;
  else /* dynamic usage (actual query string) */
    l_columns := 1;
    if(l_attribute_type = ame_util.currencyAttributeType) then
       l_columns := 3;
       comma1Location := instrb(queryString, ',', -1, 2);
       comma2Location := instrb(queryString, ',', -1, 1);
      if(comma1Location = 0 or
         comma2Location = 0 or
         comma1Location < 2 or
         comma2Location < 4) then
        fnd_message.set_name('PER','AME_400515_QUERY_INVALID');
        fnd_message.raise_error;
      end if;
    end if;
   begin
        select ame_util2.specialObject
          into l_object
          from ame_attributes
          where attribute_id = p_attribute_id
            and name in (ame_util.jobLevelStartingPointAttribute
                        ,ame_util.nonDefStartingPointPosAttr
                        ,ame_util.nonDefPosStructureAttr
                        ,ame_util.supStartingPointAttribute
                        ,ame_util.firstStartingPointAttribute
                        ,ame_util.secondStartingPointAttribute
                        )
            and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
    exception
      when no_data_found then
        l_object := ame_util2.attributeObject;
    end;
    l_valid := ame_utility_pkg.validate_query(p_query_string  => p_query_string
                                             ,p_columns       => l_columns
                                             ,p_object        => l_object
                                             );
    if l_valid <> 'Y' then
      fnd_message.set_name('PER','AME_400817_INV_ATTR_QRY');
      fnd_message.set_token('ATTR_NAME', l_attribute_name);
      fnd_message.raise_error;
    end if;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'chk_qry_str_static_attr_comb') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_qry_str_static_attr_comb;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_use_count      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the use_count field has a value of '0' on insert.
--
-- Prerequisites:
--   None--
-- In Parameters:
--   p_use_count
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_use_count
  ( p_use_count in ame_attribute_usages.use_count%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_use_count';
begin
  if p_use_count <> 0 then
    fnd_message.set_name('PER','AME_400039_ATT_TTYPE_USES');
    --  Create a new error message to indicate that the value of use_count is invalid
    fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'USE_COUNT') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_use_count;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_user_editable      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the user_editable  field has a value of either ame_util.booleanTrue
--   or ame_util.booleanFalse
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_user_editable
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_user_editable
  ( p_user_editable in ame_attribute_usages.user_editable%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_user_editable';
begin
  if NOT (p_user_editable = ame_util.booleanTrue or
          (p_user_editable = ame_util.booleanFalse )) then
    fnd_message.set_name('PER','AME_400476_INV_USER_EDITABLE');
    fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'USER_EDITABLE') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_user_editable;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in ame_atu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_atu_shd.api_updating
      (p_attribute_id =>  p_rec.attribute_id
 ,p_application_id =>  p_rec.application_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if (ame_atu_shd.g_old_rec.user_editable <> p_rec.user_editable) then
     fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
     fnd_message.set_token('FIELD_NAME ', 'USER_EDITABLE');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;
  if (ame_atu_shd.g_old_rec.user_editable = ame_util.booleanFalse) then
    if (ame_atu_shd.g_old_rec.is_static <> p_rec.is_static) then
      fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
      fnd_message.set_token('FIELD_NAME ', 'IS_STATIC');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '5');
      fnd_message.raise_error;
    end if;
    if (ame_atu_shd.g_old_rec.query_string <> p_rec.query_string) then
      fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
      fnd_message.set_token('FIELD_NAME ', 'QUERY_STRING');
      fnd_message.set_token('PROCEDURE ', l_proc);
      fnd_message.set_token('STEP ', '5');
      fnd_message.raise_error;
    end if;
  end if;
  --
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {sTARt Of Comments}
--
-- Description:
--   check that 1. No condition based on this attribute exist
--              2. Attribute is not an existing Mandatory attribute
--              3. USER_EDITABLE is not ame_util.booleanFalse
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_application_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
  (p_attribute_id   in number,
   p_application_id in integer,
   p_object_version_number in number,
   p_effective_date        in date) is

  l_proc       varchar2(72)  :=  g_package||'chk_delete';
  tempCount    integer;
  l_use_count  number ;
  l_exists     varchar2(1);
  l_seededDb   varchar2(1);

  cursor c_sel1 is
    select use_count
      from ame_attribute_usages
     where
       attribute_id   = p_attribute_id and
       application_id = p_application_id and
       sysdate between start_date and
          nvl(end_date-(ame_util.oneSecond),sysdate);

  cursor c_sel2 is
    select null
      from ame_mandatory_attributes
      where
        attribute_id = p_attribute_id and
        action_type_id = -1 and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;

--  cursor c_sel3 is
--    select null
--      from ame_attribute_usages
--      where ame_utility_pkg.check_seeddb = 'N'
--        and ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById
--        and attribute_id = p_attribute_id
--        and application_id = p_application_id
--        and p_effective_date between start_date
--             and nvl(end_date - (1/86400), sysdate);
begin
  l_use_count := 0;
  if (instr(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_TRANS_TYPE_API'||fnd_global.local_chr(10)) <> 0) then
    return;
 end if;
  if (ame_atu_shd.g_old_rec.user_editable = ame_util.booleanFalse) then
     fnd_message.set_name('PER', 'AME_400477_CANNOT_DEL_SEEDED');
     fnd_message.raise_error;
  end if;

  open c_sel1;
  fetch  c_sel1 into l_use_count;
  close c_sel1;

  if l_use_count > 0 then
    fnd_message.set_name('PER','AME_400171_ATT_IS_IN_USE');
    fnd_message.raise_error;
  else
    open c_sel2;
    fetch  c_sel2 into l_exists;
    l_seededDb := ame_utility_pkg.check_seeddb;
    if c_sel2%found and l_seededDb = 'N' then
      close c_sel2;
      fnd_message.set_name('PER','AME_400170_ATT_MAND_CANT_DEL');
      fnd_message.raise_error;
    end if;
    close c_sel2;
  end if;

--  open c_sel3;
--  fetch c_sel3 into l_use_count;
--  if c_sel3%found then
--    close c_sel3;
--    fnd_message.set_name('PER', 'AME_400477_CANNOT_DEL_SEEDED');
--    fnd_message.set_token('OBJECT', 'ATTRIBUTE USAGE');
--    fnd_message.raise_error;
-- end if;
--  close c_sel3;

exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_attribute_id                  in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  /*hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );*/
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_attribute_id                     in number
  ,p_application_id                   in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    /*hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );*/
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'attribute_id'
      ,p_argument_value => p_attribute_id
      );
    --
    --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ame_atu_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  chk_attribute_id (p_attribute_id   => p_rec.attribute_id,
                    p_effective_date => p_effective_date);

  chk_application_id(p_application_id   => p_rec.application_id,
                     p_effective_date => p_effective_date);

  chk_primary_key(p_attribute_id   => p_rec.attribute_id,
                  p_effective_date => p_effective_date,
                  p_application_id => p_rec.application_id);

  chk_is_static (p_is_static => p_rec.is_static);

  chk_attribute_item_class(p_application_id  => p_rec.application_id,
                           p_attribute_id    => p_rec.attribute_id);

  chk_attribute_approver_type(p_application_id  => p_rec.application_id,
                           p_attribute_id    => p_rec.attribute_id);

  chk_value_set_id(p_value_set_id    => p_rec.value_set_id);

  chk_attr_type_val_set_id_comb(p_attribute_id    => p_rec.attribute_id,
                                  p_value_set_id    => p_rec.value_set_id);

  chk_qry_string_is_static_comb(p_is_static => p_rec.is_static,
                                p_query_string => p_rec.query_string);

  chk_qry_str_static_attr_comb(p_attribute_id => p_rec.attribute_id,
                               p_application_id => p_rec.application_id,
                               p_is_static => p_rec.is_static,
                               p_query_string => p_rec.query_string,
                               p_effective_date => p_effective_date);
  chk_user_editable (p_user_editable => p_rec.user_editable);

  chk_use_count (p_use_count => p_rec.use_count);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_atu_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_attribute_id                   => p_rec.attribute_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );

  chk_is_static (p_is_static => p_rec.is_static);

  chk_value_set_id(p_value_set_id    => p_rec.value_set_id);

  chk_attr_type_val_set_id_comb(p_attribute_id    => p_rec.attribute_id,
                                  p_value_set_id    => p_rec.value_set_id);

  chk_qry_string_is_static_comb(p_is_static => p_rec.is_static,
                                p_query_string => p_rec.query_string);

  chk_qry_str_static_attr_comb(p_attribute_id => p_rec.attribute_id,
                               p_application_id => p_rec.application_id,
                               p_is_static => p_rec.is_static,
                               p_query_string => p_rec.query_string,
                               p_effective_date => p_effective_date);


  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_atu_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_attribute_id =>  p_rec.attribute_id
    ,p_application_id =>  p_rec.application_id
    );
  chk_delete
  (p_attribute_id          => p_rec.attribute_id,
   p_application_id        => p_rec.application_id,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_atu_bus;

/
