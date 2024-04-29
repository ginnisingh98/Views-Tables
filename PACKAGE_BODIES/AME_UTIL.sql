--------------------------------------------------------
--  DDL for Package Body AME_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_UTIL" as
/* $Header: ameoutil.pkb 120.4.12010000.3 2008/08/05 05:15:31 ubhat ship $ */
  /* forward declarations */
  procedure autonomousLog(logIdIn number,
                          packageNameIn in varchar2,
                          routineNameIn in varchar2,
                          exceptionNumberIn in integer,
                          exceptionStringIn in varchar2,
                          transactionIdIn in varchar2 default null,
                          applicationIdIn in integer default null);
  procedure nonautonomousLog(logIdIn number,
                             packageNameIn in varchar2,
                             routineNameIn in varchar2,
                             exceptionNumberIn in integer,
                             exceptionStringIn in varchar2,
                             transactionIdIn in varchar2 default null,
                             applicationIdIn in integer default null);
  /* routine definitions */
  function canonNumStringToDisplayString(canonicalNumberStringIn in varchar2,
                                         currencyCodeIn in varchar2 default null) return varchar2 as
    begin
      if(currencyCodeIn is null) then
        /* It would be nice to be able to format this string with the right decimal character. */
        return(canonicalNumberStringIn);
      else
        return(hr_chkfmt.changeformat(input => canonicalNumberStringIn,
                                      format => 'M',
                                      curcode => currencyCodeIn));
      end if;
      exception
        when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'canonNumStringToDisplayString',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
       raise;
       return(null);
    end canonNumStringToDisplayString;
  function convertCurrency(fromCurrencyCodeIn in varchar2,
                           toCurrencyCodeIn in varchar2,
                           conversionTypeIn in varchar2,
                           amountIn in number,
                           dateIn in date default sysdate,
                           applicationIdIn in integer default null) return number as
    amount number;
    denominator number;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    numerator number;
    rate number;
    begin
      amount := amountIn;
      denominator := null;
      numerator := null;
      rate := null;
      gl_currency_api.convert_closest_amount(x_from_currency => fromCurrencyCodeIn,
                                             x_to_currency => toCurrencyCodeIn,
                                             x_conversion_date => trunc(dateIn),
                                             x_conversion_type => conversionTypeIn,
                                             x_user_rate => null,
                                             x_amount => amountIn,
                                             x_max_roll_days => getConfigVar(variableNameIn => curConvWindowConfigVar,
                                                                             applicationIdIn => applicationIdIn),
                                             x_converted_amount => amount,
                                             x_denominator => denominator,
                                             x_numerator => numerator,
                                             x_rate => rate);
      return(amount);
      exception
        when gl_currency_api.INVALID_CURRENCY then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn    => 'AME_400217_UTL_CURR_INVALID',
            tokenNameOneIn   => 'FROM_CURRENCY_CODE',
            tokenValueOneIn  => fromCurrencyCodeIn,
            tokenNameTwoIn   => 'TO_CURRENCY_CODE',
            tokenValueTwoIn  => toCurrencyCodeIn,
            tokenNameThreeIn  => 'CONVERSION_TYPE',
            tokenValueThreeIn =>  conversionTypeIn,
            tokenNameFourIn  =>  'DATE_IN',
            tokenValueFourIn  => dateIn);
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertCurrency',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when gl_currency_api.NO_RATE then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400294_UTL_NO_RAT_EXISTS',
            tokenNameOneIn    => 'FROM_CURRENCY_CODE',
            tokenValueOneIn   => fromCurrencyCodeIn,
            tokenNameTwoIn    => 'TO_CURRENCY_CODE',
            tokenValueTwoIn   => toCurrencyCodeIn,
            tokenNameThreeIn  => 'CONVERSION_TYPE',
            tokenValueThreeIn =>  conversionTypeIn,
            tokenNameFourIn   => 'DATE_IN',
            tokenValueFourIn   => dateIn);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when gl_currency_api.NO_DERIVE_TYPE then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400295_UTL_NO_DERIVE_TYPE',
            tokenNameOneIn    => 'FROM_CURRENCY_CODE',
            tokenValueOneIn   => fromCurrencyCodeIn,
            tokenNameTwoIn    => 'TO_CURRENCY_CODE',
            tokenValueTwoIn   => toCurrencyCodeIn,
            tokenNameThreeIn  => 'CONVERSION_TYPE',
            tokenValueThreeIn =>  conversionTypeIn,
            tokenNameFourIn   => 'DATE_IN',
            tokenValueFourIn   => dateIn);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400218_UTL_NOT_CONV_CURR',
            tokenNameOneIn    => 'FROM_CURRENCY_CODE',
            tokenValueOneIn   => fromCurrencyCodeIn,
            tokenNameTwoIn    => 'TO_CURRENCY_CODE',
            tokenValueTwoIn   => toCurrencyCodeIn,
            tokenNameThreeIn  => 'CONVERSION_TYPE',
            tokenValueThreeIn =>  conversionTypeIn,
            tokenNameFourIn   => 'DATE_IN',
            tokenValueFourIn   => dateIn,
            tokenNameFiveIn    => 'SQLERRM',
            tokenValueFiveIn   => sqlerrm);
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertCurrency',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
         return(null);
    end convertCurrency;
  function dateStringsToString(yearIn in varchar2,
                               monthIn in varchar2,
                               dayIn in varchar2) return varchar2 as
    begin
      if(yearIn is null or
         monthIn is null or
         dayIn is null) then
        return(null);
      end if;
      return(versionDateToString(dateIn => to_date(yearIn || ':' || monthIn || ':' || dayIn, 'YYYY:MM:DD')));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'dateStringsToString',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
       raise;
       return(null);
    end dateStringsToString;
  function fieldDelimiter return varchar2 as
    begin
      /* 11 is a vertical tab in the ASCII character set. */
  -- This function will replace getAdminPersonIdIn and getAdminUserIdIn
  --
      return(fnd_global.local_chr(ascii_chr => 11));
    end fieldDelimiter;
  function filterHtmlUponInput(stringIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidStringException exception;
    string ame_util.longStringType;
    begin
      if(upper(stringIn) like '%<SCRIPT>%') then
        raise invalidStringException;
      end if;
      string := wf_notification.substituteSpecialChars(stringIn);
      return(string);
      exception
        when invalidStringException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400456_NO_SCRIPT_TAG');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'filterHtmlUponInput',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'filterHtmlUponInput',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end filterHtmlUponInput;
  function filterHtmlUponRendering(stringIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidStringException exception;
    string ame_util.longStringType;
    begin
      if(upper(string) like '%<SCRIPT>%') then
        raise invalidStringException;
      end if;
      return(stringIn);
      exception
        when invalidStringException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400456_NO_SCRIPT_TAG');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'filterHtmlUponRendering',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'filterHtmlUponRendering',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end filterHtmlUponRendering;
  function escapeSpaceChars(stringIn in varchar2) return varchar2 as
    begin
      return(replace(stringIn, ' ', '&nbsp;'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'escapeSpaceChars',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end escapeSpaceChars;
  function getAdminName(applicationIdIn in integer default null) return varchar2 is
    badAdminApproverException exception;
    commaLocation integer;
    adminName ame_config_vars.variable_value%type;
    configVarLength integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select variable_value
        into adminName
        from ame_config_vars
       where variable_name = ame_util.adminApproverConfigVar and
         application_id = applicationIdIn and
         sysdate between start_date and
           nvl(end_date - ame_util.oneSecond, sysdate) ;
      -- If no transaction-type-specific config var exists, revert to the
      -- application-wide value.
       return(adminName);
    exception
      when no_data_found then
        select variable_value
          into adminName
          from ame_config_vars
         where variable_name = ame_util.adminApproverConfigVar and
           (application_id is null or application_id = 0) and
           sysdate between start_date and
           nvl(end_date - ame_util.oneSecond, sysdate) ;
       return(adminName);
      when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getAdminName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
     end getAdminName;
  function getCarriageReturn return varchar2 as
    begin
      return(fnd_global.local_chr(13)); /* ASCII character 13 is a carriage return. */
      exception
        when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'getCarriageReturn',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getCarriageReturn;
  function getContactAdminString(applicationIdIn in integer default null) return varchar2 as
    adminString varchar2(4000);
    adminName varchar2(4000);
    badContactApproverException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      adminName := getAdminName(applicationIdIn => applicationIdIn);
      if(adminName is null) then
        raise badContactApproverException;
      end if; -- pa message
      adminString :=  ame_approver_type_pkg.getApproverDescription(nameIn => adminName);
      return('If the problem persists, please contact ' || adminString || '.  ');
    exception
       when badContactApproverException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400220_UTL_NO_ADMIN_APR');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getContactAdminString',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
       when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'getContactAdminString',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end getContactAdminString;
/*
AME_STRIPING
  function getCurrentStripeSetId(applicationIdIn in integer) return integer as
    stripeSetCookie owa_cookie.cookie;
    begin
      stripeSetCookie := owa_cookie.get(getStripeSetCookieName(applicationIdIn => applicationIdIn));
      return(stripeSetCookie.vals(1));
      exception
        when no_data_found then
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getCurrentStripeSetId',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getCurrentStripeSetId;
*/
  function getCurrentUserId return integer is
    userId fnd_user.user_id%type;
    begin
      userId := fnd_global.user_id;
      return(userId);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'getCurrentUserId',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end getCurrentUserId;
  function getColumnLength(tableNameIn        in varchar2,
                           columnNameIn       in varchar2,
                           fndApplicationIdIn in integer default 800) return integer as
    columnLength integer;
    begin
      select width
        into columnLength
        from fnd_columns
        where
          table_id =
            (select table_id
             from fnd_tables
             where
               table_name     = upper(tableNameIn)  and
               application_id = fndApplicationIdIn) and
          application_id = fndApplicationIdIn and
          column_name    = upper(columnNameIn);
      return(columnLength);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getColumnLength',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getColumnLength;
  function getConfigDesc(variableNameIn in varchar2) return varchar2 as
     description ame_config_vars.description%type;
        begin
            select description
                into description
                from ame_config_vars
                where
                   variable_name = variableNameIn and
                   (application_id is null or application_id = 0) and
                   sysdate between start_date and
                       nvl(end_date - ame_util.oneSecond, sysdate) ;
            return(description);
            exception
              when others then
                runtimeException(packageNameIn => 'ame_util',
                                 routineNameIn => 'getConfigDesc',
                                 exceptionNumberIn => sqlcode,
                                 exceptionStringIn => sqlerrm);
                raise;
                return(null);
        end getConfigDesc;
  function getConfigVar(variableNameIn in varchar2,
                        applicationIdIn in integer default null) return varchar2 as
    variableValue ame_config_vars.variable_value%type;
    begin
      if(applicationIdIn is null) then
        select variable_value
          into variableValue
          from ame_config_vars
          where
            variable_name = variableNameIn and
            (application_id is null or application_id = 0) and
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      else
        begin
          select variable_value
            into variableValue
            from ame_config_vars
            where
              variable_name = variableNameIn and
              application_id = applicationIdIn and
              sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
          exception
            /* If no transaction-type-specific config var exists, revert to the application-wide value. */
            when no_data_found then
              select variable_value
                into variableValue
                from ame_config_vars
                where
                  variable_name = variableNameIn and
                  (application_id is null or application_id = 0) and
                  sysdate between start_date and
                     nvl(end_date - ame_util.oneSecond, sysdate) ;
        end;
      end if;
      return(variableValue);
      exception
        when others then
          /*
          Bug 2219719:  Do not call runtimeException here; it could result in infinite looping,
          because runtimeException now calls getConfig var.
          */
          raise;
          return(null);
    end getConfigVar;
  function getCurrencyName(currencyCodeIn in varchar2) return varchar2 as
    returnValue fnd_currencies_active_v.name%type;
    begin
      select name
        into returnValue
        from fnd_currencies_active_v
        where currency_code = currencyCodeIn;
      return(currencyCodeIn || ' (' || returnValue || ')');
      exception
        when others then
                runtimeException(packageNameIn => 'ame_util',
                                 routineNameIn => 'getCurrencyName',
                                 exceptionNumberIn => sqlcode,
                                 exceptionStringIn => sqlerrm);
                raise;
                return(currencyCodeIn);
    end getCurrencyName;
  function getBusGroupName(busGroupIdIn in integer) return varchar2 as
    tempName per_business_groups.name%type;
    begin
      if(busGroupIdIn is null) then
        return(null);
      end if;
      select name
        into tempName
        from per_business_groups
        where
          business_group_id = busGroupIdIn and
          sysdate >= date_from and
          (date_to is null or sysdate < date_to);
      return(tempName);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getBusGroupName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getBusGroupName;
  function getDayString(dateIn in date) return varchar2 as
    begin
      return(to_char(dateIn, 'DD'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getDayString',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getDayString;
  function getHighestResponsibility return integer as
    cursor getResponsibilityCur(userId in varchar2) is
      select  a.responsibility_key
        from  FND_SECURITY_GROUPS_VL fsg,
              fnd_responsibility_vl a,
              FND_USER_RESP_GROUPS b
        where b.user_id = userId and
              b.start_date <= sysdate and
              (b.end_date is null or b.end_date > sysdate) and
              b.RESPONSIBILITY_id = a.responsibility_id and
              b.RESPONSIBILITY_application_id = a.application_id and
              a.version in ('W','4') and
              a.start_date <= sysdate and
              (a.end_date is null or a.end_date > sysdate) and
              b.SECURITY_GROUP_ID = fsg.SECURITY_GROUP_ID
        order by a.responsibility_key;
    highestResponsibility integer;
    userId fnd_user.user_id%type;
    begin
      userId := fnd_global.user_id;
      highestResponsibility := ame_util.noResponsibility;
      for getResponsibilityRec in getResponsibilityCur(userId => userId) loop
        if(getResponsibilityRec.responsibility_key = ame_util.devRespKey) then
          return(ame_util.developerResponsibility);
        elsif(getResponsibilityRec.responsibility_key = ame_util.appAdminRespKey and
              highestResponsibility < ame_util.appAdminResponsibility) then
          highestResponsibility := ame_util.appAdminResponsibility;
        elsif(getResponsibilityRec.responsibility_key = ame_util.genBusUserRespKey and
              highestResponsibility < ame_util.genBusResponsibility) then
          highestResponsibility := ame_util.genBusResponsibility;
        elsif(getResponsibilityRec.responsibility_key = ame_util.limBusUserRespKey and
              highestResponsibility < ame_util.limBusResponsibility) then
          highestResponsibility := ame_util.limBusResponsibility;
        elsif(getResponsibilityRec.responsibility_key = ame_util.readOnlyUserRespKey and
              highestResponsibility < ame_util.readOnlyResponsibility) then
          highestResponsibility := ame_util.readOnlyResponsibility;
        end if;
      end loop;
      return(highestResponsibility);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getHighestResponsibility',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        raise;
        return(ame_util.noResponsibility);
    end getHighestResponsibility;
  function getLabel(attributeApplicationIdIn in number,
                    attributeCodeIn    in varchar2,
                    returnColonAndSpaces in boolean default false) return varchar2 as
    attributeLabelOut varchar2(80);
    begin
      select attribute_label_long
        into attributeLabelOut
        from ak_attributes_vl
       where attribute_code = attributeCodeIn
       and attribute_application_id = attributeApplicationIdIn;
      if(returnColonAndSpaces) then
        return(attributeLabelOut || ': ');
      else
        return(attributeLabelOut);
      end if;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getLabel',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end getLabel;
  function getLineFeed return varchar2 as
    begin
      return(fnd_global.local_chr(10)); /* ASCII character 10 is a line feed. */
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getLineFeed',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getLineFeed;
  function getLongBoilerplate(applicationShortNameIn in varchar2,
                              messageNameIn          in varchar2,
                              tokenNameOneIn        in varchar2 default null,
                              tokenValueOneIn       in varchar2 default null,
                              tokenNameTwoIn        in varchar2 default null,
                              tokenValueTwoIn       in varchar2 default null,
                              tokenNameThreeIn      in varchar2 default null,
                              tokenValueThreeIn     in varchar2 default null,
                              tokenNameFourIn       in varchar2 default null,
                              tokenValueFourIn      in varchar2 default null,
                              tokenNameFiveIn       in varchar2 default null,
                              tokenValueFiveIn      in varchar2 default null,
                              tokenNameSixIn        in varchar2 default null,
                              tokenValueSixIn       in varchar2 default null,
                              tokenNameSevenIn      in varchar2 default null,
                              tokenValueSevenIn     in varchar2 default null,
                              tokenNameEightIn      in varchar2 default null,
                              tokenValueEightIn     in varchar2 default null,
                              tokenNameNineIn       in varchar2 default null,
                              tokenValueNineIn      in varchar2 default null,
                              tokenNameTenIn        in varchar2 default null,
                              tokenValueTenIn       in varchar2 default null) return varchar2 as
    boilerplateLabel ame_util.longBoilerplateType;
    begin
      /* The ame_util.longBoilerplateType is defined as a varchar2(300). */
      boilerplateLabel :=
        substrb(ame_util.getMessage(applicationShortNameIn => applicationShortNameIn,
                            messageNameIn => messageNameIn,
                            tokenNameOneIn => tokenNameOneIn,
                            tokenValueOneIn => tokenValueOneIn,
                            tokenNameTwoIn => tokenNameTwoIn,
                            tokenValueTwoIn => tokenValueTwoIn,
                            tokenNameThreeIn => tokenNameThreeIn,
                            tokenValueThreeIn => tokenValueThreeIn,
                            tokenNameFourIn => tokenNameFourIn,
                            tokenValueFourIn => tokenValueFourIn,
                            tokenNameFiveIn => tokenNameFiveIn,
                            tokenValueFiveIn => tokenValueFiveIn,
                            tokenNameSixIn => tokenNameSixIn,
                            tokenValueSixIn => tokenValueSixIn,
                            tokenNameSevenIn => tokenNameSevenIn,
                            tokenValueSevenIn => tokenValueSevenIn,
                            tokenNameEightIn => tokenNameEightIn,
                            tokenValueEightIn => tokenValueEightIn,
                            tokenNameNineIn => tokenNameNineIn,
                            tokenValueNineIn => tokenValueNineIn,
                            tokenNameTenIn => tokenNameTenIn,
                            tokenValueTenIn => tokenValueTenIn), 1, 300);
      return(boilerplateLabel);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getLongBoilerplate',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getLongBoilerplate;
  function getMessage(applicationShortNameIn in varchar2,
                      messageNameIn          in varchar2,
                      tokenNameOneIn        in varchar2 default null,
                      tokenValueOneIn       in varchar2 default null,
                      tokenNameTwoIn        in varchar2 default null,
                      tokenValueTwoIn       in varchar2 default null,
                      tokenNameThreeIn      in varchar2 default null,
                      tokenValueThreeIn     in varchar2 default null,
                      tokenNameFourIn       in varchar2 default null,
                      tokenValueFourIn      in varchar2 default null,
                      tokenNameFiveIn       in varchar2 default null,
                      tokenValueFiveIn      in varchar2 default null,
                      tokenNameSixIn        in varchar2 default null,
                      tokenValueSixIn       in varchar2 default null,
                      tokenNameSevenIn      in varchar2 default null,
                      tokenValueSevenIn     in varchar2 default null,
                      tokenNameEightIn      in varchar2 default null,
                      tokenValueEightIn     in varchar2 default null,
                      tokenNameNineIn       in varchar2 default null,
                      tokenValueNineIn      in varchar2 default null,
                      tokenNameTenIn        in varchar2 default null,
                      tokenValueTenIn       in varchar2 default null) return varchar2 as
    begin
      fnd_message.set_name(applicationShortNameIn, messageNameIn);
      if (tokenNameOneIn is not null) then
        fnd_message.set_token(tokenNameOneIn, tokenValueOneIn);
      end if;
      if (tokenNameTwoIn is not null) then
        fnd_message.set_token(tokenNameTwoIn, tokenValueTwoIn);
      end if;
      if (tokenNameThreeIn is not null) then
        fnd_message.set_token(tokenNameThreeIn, tokenValueThreeIn);
      end if;
      if (tokenNameFourIn is not null) then
        fnd_message.set_token(tokenNameFourIn, tokenValueFourIn);
      end if;
      if (tokenNameFiveIn is not null) then
        fnd_message.set_token(tokenNameFiveIn, tokenValueFiveIn);
      end if;
      if (tokenNameSixIn is not null) then
        fnd_message.set_token(tokenNameSixIn, tokenValueSixIn);
      end if;
      if (tokenNameSevenIn is not null) then
        fnd_message.set_token(tokenNameSevenIn, tokenValueSevenIn);
      end if;
      if (tokenNameEightIn is not null) then
        fnd_message.set_token(tokenNameEightIn, tokenValueEightIn);
      end if;
      if (tokenNameNineIn is not null) then
        fnd_message.set_token(tokenNameNineIn, tokenValueNineIn);
      end if;
      if (tokenNameTenIn is not null) then
        fnd_message.set_token(tokenNameTenIn, tokenValueTenIn);
      end if;
      return(fnd_message.get);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getMessage',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getMessage;
  function getMonthString(dateIn in date) return varchar2 as
    begin
      return(to_char(dateIn, 'MM'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getMonthString',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getMonthString;
  function getOrgName(orgIdIn in integer) return varchar2 as
    tempName hr_organization_units.name%type;
    begin
      if(orgIdIn is null) then
        return(null);
      end if;
      select name
        into tempName
        from hr_organization_units
        where
          organization_id = orgIdIn and
          trunc(sysdate) >= date_from and
          (date_to is null or trunc(sysdate) < date_to);
      return(tempName);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getOrgName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getOrgName;
  function getPlsqlDadPath return varchar2 as
    begin
      return(owa_util.get_owa_service_path);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getPlsqlDadPath',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getPlsqlDadPath;
  function getQuery(selectClauseIn in varchar2) return ame_util.queryCursor as
    queryCursor ame_util.queryCursor;
    sqlStatement varchar2(4000);
    begin
      sqlStatement := selectClauseIn;
      open queryCursor for sqlStatement;
      return queryCursor;
      exception
        when others then
          rollback;
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getQuery',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(queryCursor);
    end getQuery;
  function getServerName return varchar2 as
    begin
      return('http://' || owa_util.get_cgi_env(param_name => 'SERVER_NAME'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getServerName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getServerName;
  function getSetOfBooksName(setOfBooksIdIn in integer) return varchar2 as
    tempName gl_sets_of_books.name%type;
    begin
      if(setOfBooksIdIn is null) then
        return(null);
      end if;
      select name
        into tempName
        from gl_sets_of_books
        where set_of_books_id = setOfBooksIdIn;
      return(tempName);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getSetOfBooksName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getSetOfBooksName;
/*
AME_STRIPING
    hostName v$instance.host_name%type;
    instanceName v$instance.instance_name%type;
    begin
      select
        host_name,
        instance_name
        into
          hostName,
          instanceName
        from v$instance;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getStripeSetCookieName',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getStripeSetCookieName;
*/
  function getTransTypeCookie return integer as
  applicationId integer;
  highestResponsibility integer;
  returnStatus ame_util.longestStringType;
  securedAttributeList icx_sec.g_num_tbl_type;
  transTypeCookie owa_cookie.cookie;
  userId integer;
  begin
    userId := ame_util.getCurrentUserId;
    transTypeCookie := owa_cookie.get(ame_util.transactionTypeCookie || ':' || userId);
    if(transTypeCookie.vals.count > 0) then
      highestResponsibility := getHighestResponsibility;
      applicationId := to_number(transTypeCookie.vals(1));
      if(highestResponsibility = ame_util.limBusResponsibility) then
        icx_sec.getsecureattributevalues(p_attri_code => ame_util.attributeCode,
                                         p_return_status => returnStatus,
                                         p_num_tbl => securedAttributeList);
        for i in 1..securedAttributeList.count loop
          if(securedAttributeList(i) = applicationId) then
            return(transTypeCookie.vals(1));
          end if;
        end loop;
      else
        return(to_number(transTypeCookie.vals(1)));
      end if;
    end if;
    return(null);
    exception
      when no_data_found then
        return(null);
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'getTransTypeCookie',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
  end getTransTypeCookie;
  function getYearString(dateIn in date) return varchar2 as
    begin
      return(to_char(dateIn, 'YYYY'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getYearString',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getYearString;
  function getServerPort return varchar2 as
    begin
      return(':' || owa_util.get_cgi_env(param_name => 'SERVER_PORT'));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getServerPort',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getServerPort;
  function hasOrderClause(queryStringIn in varchar2) return boolean as
    begin
      if instrb(upper(queryStringIn), 'ORDER') = 0 then
        return(false);
      end if;
      return(true);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'hasOrderClause',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end hasOrderClause;
  function idListsMatch(idList1InOut in out nocopy idList,
                        idList2InOut in out nocopy idList,
                        sortList1In in boolean default false,
                        sortList2In in boolean default true) return boolean as
    listLength1 integer;
    listLength2 integer;
    tempIndex integer;
    begin
      listLength1 := idList1InOut.count;
      listLength2 := idList2InOut.count;
      if(listLength1 <> listLength2) then
        return(false);
      end if;
      if(sortList1In) then
        sortIdListInPlace(idListInOut => idList1InOut);
      end if;
      if(sortList2In) then
        sortIdListInPlace(idListInOut => idList2InOut);
      end if;
      for tempIndex in 1 .. listLength1 loop
        if(idList1InOut(tempIndex) <> idList2InOut(tempIndex)) then
          return(false);
        end if;
      end loop;
      return(true);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'idListsMatch',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end idListsMatch;
  function inputNumStringToCanonNumString(inputNumberStringIn in varchar2,
                                          currencyCodeIn in varchar2 default null) return varchar2 as
    format varchar2(1);
    inputString varchar2(50);
    returnValue varchar2(240); /* this length specified by HR documentation */
    rgeflg varchar2(1);
    begin
      if(currencyCodeIn is null) then
        format := 'N';
      else
        format := 'M';
      end if;
      inputString := replace(inputNumberStringIn,
                             ',',
                             '.');
      /*
        In hr_chkfmt.checkformat, <<value>> is an in/out argument that on output is end-user friendly,
        and <<output>> is a number-string in canonical format (I checked the source code).  <<nullok>>
        must be either 'Y' or 'N' (the package does not offer constants for these values).
      */
      hr_chkfmt.checkformat(value => inputString,
                            format => format,
                            output => returnValue,
                            minimum => null,
                            maximum => null,
                            nullok => 'Y',
                            rgeflg => rgeflg,
                            curcode => currencyCodeIn);
      return(returnValue);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'inputNumStringToCanonNumString',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end inputNumStringToCanonNumString;
  function isAnEvenNumber(numberIn in integer) return boolean as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    notAnIntException exception;
    begin
      if(not isAnInteger(stringIn => to_char(numberIn))) then
        raise notAnIntException;
      end if;
      return(mod(numberIn, 2) = 0);
      exception
        when notAnIntException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400457_INPUT_NOT_INTEGER');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isAnEvenNumber',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(false);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isAnEvenNumber',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isAnEvenNumber;
  function isAnInteger(stringIn in varchar2) return boolean as
    begin
      return(isANumber(stringIn => stringIn,
                       allowDecimalsIn => false));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'isAnInteger',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isAnInteger;
  function isANegativeInteger(stringIn in varchar2) return boolean as
    begin
      if(isANumber(stringIn => stringIn,
                   allowDecimalsIn => false,
                   allowNegativesIn => true) and
         to_number(stringIn) < 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'isANegativeInteger',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isANegativeInteger;
  function isANonNegativeInteger(stringIn in varchar2) return boolean as
    begin
      return(isANumber(stringIn => stringIn,
                       allowDecimalsIn => false,
                       allowNegativesIn => false));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'isANonNegativeInteger',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isANonNegativeInteger;
  function isANumber(stringIn in varchar2,
                     allowDecimalsIn in boolean default true,
                     allowNegativesIn in boolean default true) return boolean as
    firstOccurrence1 integer;
    firstOccurrence2 integer;
    nonNumberChars ame_util.stringType;
    begin
      nonNumberChars := stringIn;
      if(allowDecimalsIn) then
         firstOccurrence1 := instrb(nonNumberChars, '.', 1, 1);
         if(firstOccurrence1 > 0 and
            firstOccurrence1 <> instrb(nonNumberChars, '.', -1, 1)) then
            /* There are at least two periods in the string; return false. */
            return(false);
         end if;
         firstOccurrence2 := instrb(nonNumberChars, ',', 1, 1);
         if(firstOccurrence2 > 0 and
            firstOccurrence2 <> instrb(nonNumberChars, ',', -1, 1)) then
            /* There are at least two commas in the string; return false. */
            return(false);
         end if;
         if(firstOccurrence1 > 0 and
            firstOccurrence2 > 0) then
            /* Both a period and a comma appear in the string; return false. */
            return(false);
         end if;
         /*
          Now we're sure at most one period or at most comma appears in the string.
          Get rid of it, if it's there.
         */
         nonNumberChars := replace(replace(nonNumberChars, ',', ''), '.', '');
      end if;
      if(allowNegativesIn) then
         firstOccurrence1 := instrb(nonNumberChars, '-', 1, 1);
         if(firstOccurrence1 > 1) then
           /* There is a hyphen after the initial position; return false. */
           return(false);
         end if;
         /* Now either the first hyphen is in the first position, or there is no hyphen. */
         if(firstOccurrence1 = 1) then
           if(instrb(nonNumberChars, '-', -1, 1) <> 1) then
             /* There is a second hyphen in the string; return false. */
             return(false);
           else
             /*
              Now we're sure there is at most one hyphen in the string, and that
              it's in position 1.  Get rid of it.
             */
             nonNumberChars := substrb(nonNumberChars, 2);
           end if;
         end if;
      end if;
      /* Now get rid of the digits. */
      for i in 0 .. 9 loop
        nonNumberChars := replace(nonNumberChars, i, '');
      end loop;
      if(nonNumberChars is null) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'isANumber',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isANumber;
  function isArgumentTooLong(tableNameIn in varchar2,
                             columnNameIn in varchar2,
                             argumentIn in varchar2) return boolean as
    argumentLength integer;
    begin
      argumentLength := lengthb(argumentIn);
      if(ame_util.getColumnLength(tableNameIn, columnNameIn) < argumentLength) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isArgumentTooLong',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end isArgumentTooLong;
  function isConversionTypeValid(conversionTypeIn in varchar2) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from gl_daily_conversion_types
        where conversion_type = conversionTypeIn;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isConversionTypeValid',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isConversionTypeValid;
  function isCurrencyCodeValid(currencyCodeIn in varchar2) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from fnd_currencies_active_v
        where currency_code = currencyCodeIn;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isCurrencyCodeValid',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isCurrencyCodeValid;
  function isDateInRange(currentDateIn in date default sysdate,
                        startDateIn in date,
                        endDateIn in date) return boolean is
    begin
      if((startDateIn is null and endDateIn is null) or
         (startDateIn is null and sysdate <= endDateIn) or
         (startDateIn <= sysdate and endDateIn is null) or
         (sysdate between startDateIn and endDateIn)) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'isDateInRange',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end isDateInRange;
  function longStringListsMatch(longStringList1InOut in out nocopy longStringList,
                                longStringList2InOut in out nocopy longStringList,
                                sortList1In in boolean default false,
                                sortList2In in boolean default true) return boolean as
    listLength1 integer;
    listLength2 integer;
    tempIndex integer;
    begin
      listLength1 := longStringList1InOut.count;
      listLength2 := longStringList2InOut.count;
      if(listLength1 <> listLength2) then
        return(false);
      end if;
      if(sortList1In) then
        sortLongStringListInPlace(longStringListInOut => longStringList1InOut);
      end if;
      if(sortList2In) then
        sortLongStringListInPlace(longStringListInOut => longStringList2InOut);
      end if;
      for tempIndex in 1 .. listLength1 loop
        if(longStringList1InOut(tempIndex) <> longStringList2InOut(tempIndex)) then
          return(false);
        end if;
      end loop;
      return(true);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'longStringListsMatch',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end longStringListsMatch;
  function longestStringListsMatch(longestStringList1InOut in out nocopy longestStringList,
                                   longestStringList2InOut in out nocopy longestStringList,
                                   sortList1In in boolean default false,
                                   sortList2In in boolean default true) return boolean as
    listLength1 integer;
    listLength2 integer;
    tempIndex integer;
    begin
      listLength1 := longestStringList1InOut.count;
      listLength2 := longestStringList2InOut.count;
      if(listLength1 <> listLength2) then
        return(false);
      end if;
      if(sortList1In) then
        sortLongestStringListInPlace(longestStringListInOut => longestStringList1InOut);
      end if;
      if(sortList2In) then
        sortLongestStringListInPlace(longestStringListInOut => longestStringList2InOut);
      end if;
      for tempIndex in 1 .. listLength1 loop
        if(longestStringList1InOut(tempIndex) <> longestStringList2InOut(tempIndex)) then
          return(false);
        end if;
      end loop;
      return(true);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'longestStringListsMatch',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end longestStringListsMatch;
  function matchCharacter(stringIn in varchar2,
                          locationIn in integer,
                          characterIn in varchar2) return boolean as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    locationException exception;
    charLengthException exception;
    begin
      if(locationIn < 1 or
         locationIn > lengthb(stringIn)) then
        raise locationException;
      end if;
      if(lengthb(characterIn) <> 1) then
        raise charLengthException;
      end if;
      if(substrb(stringIn, locationIn, 1) = characterIn) then
        return(true);
      end if;
      return(false);
      exception
        when locationException then
          errorCode := -20001; -- pa message
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn     => 'AME_400458_MUST_BE_INTEGER',
                                tokenNameOneIn    => 'LOCATION',
                                tokenValueOneIn   => locationIn,
                                tokenNameTwoIn    => 'STRING',
                                tokenValueTwoIn   => stringIn);
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'matchCharacter',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when charLengthException then
          errorCode := -20001;
          errorMessage := 'characterIn must be a single character.  ';
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'matchCharacter',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'matchCharacter',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end matchCharacter;
  function personIdToUserId(personIdIn in integer) return integer as
    tempUserId fnd_user.user_id%type;
    begin
      select user_id
        into tempUserId
        from fnd_user
        where employee_id = personIdIn;
      return tempUserId;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'personIdToUserId',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end personIdToUserId;
  function recordDelimiter return varchar2 as
    begin
      /* 12 is a form feed in the ASCII character set. */
      return(fnd_global.local_chr(ascii_chr => 12));
    end recordDelimiter;
  function removeReturns(stringIn in varchar2,
                         replaceWithSpaces in boolean default false) return varchar2 as
    replacementCharacter varchar2(1);
    begin
      if(replaceWithSpaces) then
        replacementCharacter := ' ';
      else
        replacementCharacter := null;
      end if;
      return(replace(replace(stringIn,
                             getLineFeed,
                             replacementCharacter),
                     getCarriageReturn,
                     replacementCharacter));
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'removeReturns',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end removeReturns;
  function removeScriptTags(stringIn in varchar2 default null) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inputString ame_util.longestStringType;
    inputStringLength integer;
    loopCounter integer;
    loopException exception;
    tagStartLocation integer;
    tagEndLocation integer;
    upperInputString ame_util.longestStringType;
    begin
      if(stringIn is null) then
        return(null);
      end if;
      inputString := stringIn;
      loopCounter := 0; /* pre-increment */
      /* Find and remove all occurrences of HTML script tagging. */
      loop
        loopCounter := loopCounter + 1;
        if(loopCounter > 100) then
          raise loopException;
        end if;
        /* Look for the script keyword. */
        upperInputString := upper(inputString);
        tagStartLocation := instrb(upperInputString, 'SCRIPT', 1, 1);
        if(tagStartLocation = 0) then
          exit;
        end if;
        /* The script keyword was found.  Look for slashes and tag brackets. */
        inputStringLength := lengthb(inputString);
        tagEndLocation := tagStartLocation + 6;
        /* Look for a slash. */
        if(tagStartLocation > 1 and
           matchCharacter(stringIn => inputString,
                          locationIn => tagStartLocation - 1,
                          characterIn => '/')) then
          tagStartLocation := tagStartLocation - 1;
        end if;
        /* Look for an open bracket. */
        if(tagStartLocation > 1 and
           matchCharacter(stringIn => inputString,
                          locationIn => tagStartLocation - 1,
                          characterIn => '<')) then
          tagStartLocation := tagStartLocation - 1;
        end if;
        /* Look for a close bracket. */
        if(tagEndLocation <= inputStringLength and
           matchCharacter(stringIn => inputString,
                          locationIn => tagEndLocation,
                          characterIn => '>')) then
          tagEndLocation := tagEndLocation + 1;
        end if;
        inputString := substrb(inputString, 1, tagStartLocation - 1) || substrb(inputString, tagEndLocation);
      end loop;
      return(inputString);
      exception
        when loopException then
          errorCode := -20001;
          errorMessage := -- pa message
            'This function''s main loop iterated 100 times, which indicates an internal error.  ' ||
            'Please contact Oracle technical support.  ';
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'removeScriptTags',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'removeScriptTags',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end removeScriptTags;
  /*
    All of the serialization functions need to be very efficient.  If you modify this
    code, please don't "roll up" the loops by having them call subroutines that are
    not absolutely necessary, and whose only purposes would be elegance and readability.
  */
  function stringListsMatch(stringList1InOut in out nocopy stringList,
                            stringList2InOut in out nocopy stringList,
                            sortList1In in boolean default false,
                            sortList2In in boolean default true) return boolean as
    listLength1 integer;
    listLength2 integer;
    tempIndex integer;
    begin
      listLength1 := stringList1InOut.count;
      listLength2 := stringList2InOut.count;
      if(listLength1 <> listLength2) then
        return(false);
      end if;
      if(sortList1In) then
        sortStringListInPlace(stringListInOut => stringList1InOut);
      end if;
      if(sortList2In) then
        sortStringListInPlace(stringListInOut => stringList2InOut);
      end if;
      for tempIndex in 1 .. listLength1 loop
        if(stringList1InOut(tempIndex) <> stringList2InOut(tempIndex)) then
          return(false);
        end if;
      end loop;
      return(true);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'stringListsMatch',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end stringListsMatch;
  function userIdToPersonId(userIdIn in integer) return integer as
    tempPersonId fnd_user.employee_id%type;
    begin
      select employee_id
        into tempPersonId
        from fnd_user
        where user_id = userIdIn;
      return tempPersonId;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'userIdToPersonId',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end userIdToPersonId;

  procedure getAttributeId(attributeNameIn in varchar2
                          ,attributeIdOut out nocopy number
                          ,transactionIdIn in varchar2
                          ,applicationIdIn in number) as
    tempAttributeId number;
    tempLogId  number;
  begin
    select attribute_id
      into tempAttributeId
     from ame_attributes
     where name = upper(attributeNameIn)
      and sysdate between start_date and
                   nvl(end_date - ame_util.oneSecond, sysdate) ;
     attributeIdOut := tempAttributeId;
  exception
    when others then
       attributeIdOut := null;
       select ame_exceptions_log_s.nextval into tempLogId from dual;
       autonomousLog(logIdIn => tempLogId,
                     packageNameIn => 'ame_util',
                     routineNameIn => 'getAttributeId',
                     exceptionNumberIn => sqlcode,
                     exceptionStringIn => sqlerrm,
                     transactionIdIn => transactionIdIn,
                     applicationIdIn => applicationIdIn );
  end getAttributeId;

  procedure getQueryString(attributeIdIn  in varchar2
                           ,queryStringOut out nocopy ame_attribute_usages.query_string%type
                           ,transactionIdIn in varchar2
                          ,applicationIdIn in number) as
    temQueryString ame_attribute_usages.query_string%type;
    tempLogId  number;
  begin
         select query_string
           into temQueryString
           from ame_attribute_usages
           where
             attribute_id = attributeIdIn and
             application_id = applicationIdIn and
              sysdate between start_date and
                    nvl(end_date - ame_util.oneSecond, sysdate) ;
     queryStringOut := temQueryString;
  exception
    when others then
       queryStringOut := null;
       select ame_exceptions_log_s.nextval into tempLogId from dual;
       autonomousLog(logIdIn => tempLogId,
                     packageNameIn => 'ame_util',
                     routineNameIn => 'getQueryString',
                     exceptionNumberIn => sqlcode,
                     exceptionStringIn => sqlerrm,
                     transactionIdIn => transactionIdIn,
                     applicationIdIn => applicationIdIn );
  end getQueryString;

  procedure checkSaticUsage(attributeIdIn  in varchar2
                           ,isSaticUsage out nocopy varchar2
                           ,transactionIdIn in varchar2
                           ,applicationIdIn in number) as
    tempIsSatic varchar2(2);
    tempLogId  number;
  begin
    select is_static
      into tempIsSatic
      from ame_attribute_usages
      where attribute_id = attributeIdIn and
            application_id = applicationIdIn and
             sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate) ;
     isSaticUsage := tempIsSatic;
  exception
    when others then
       isSaticUsage := null;
       select ame_exceptions_log_s.nextval into tempLogId from dual;
       autonomousLog(logIdIn => tempLogId,
                     packageNameIn => 'ame_util',
                     routineNameIn => 'checkSaticUsage',
                     exceptionNumberIn => sqlcode,
                     exceptionStringIn => sqlerrm,
                     transactionIdIn => transactionIdIn,
                     applicationIdIn => applicationIdIn );
  end checkSaticUsage;
  function useWorkflow(transactionIdIn in varchar2 default null,
                       applicationIdIn in integer) return boolean as
    attributeId integer;
    attributeUsage ame_attribute_usages.query_string%type;
    attributeValue ame_util.attributeValueType;
    badUsageException exception;
    dynamicCursor integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    ignoreMe integer;
    tempIsstaticUsage varchar2(2);
    tempLogId number;
    begin
      /*
        If we don't know which transaction type we're dealing with, we can't interact
        with its Workflow exception stack.
      */
      if(applicationIdIn is null) then
        return false;
      end if;
      /*
        In the absence of a positive attribute value to the contrary, assume conservatively
        that we should not interact with the transaction type's Workflow exception stack.
      */
      attributeValue := ame_util.booleanAttributeFalse;
      /* Get the usage, either to read it if it's static or to execute it if it's dynamic. */
      /*methods getattributId, getqueryRting and checkSaticUsage are local method used to avoid
      infinite loop due to exception(bug 6837659). When exception occur in this methods they log the
      details but do not raise the error. This message will appear along with the original exception passed
      into run time exception*/
      getAttributeId(attributeNameIn => ame_util.useWorkflowAttribute
                        ,attributeIdOut => attributeId
                        ,transactionIdIn => transactionIdIn
                        ,applicationIdIn => applicationIdIn );
      if attributeId is null then
        return false;
      end if;
      getQueryString(attributeIdIn    => attributeId
                     ,queryStringOut  => attributeUsage
                     ,transactionIdIn => transactionIdIn
                     ,applicationIdIn => applicationIdIn );
      if attributeUsage is null then
        return false;
      end if;
      checkSaticUsage(attributeIdIn => attributeId
                         ,isSaticUsage => tempIsstaticUsage
                         ,transactionIdIn => transactionIdIn
                         ,applicationIdIn => applicationIdIn );
      if tempIsstaticUsage is null then
        return false;
      end if;
      /* Check/execute the usage. */
      if( tempIsstaticUsage = ame_util.booleanTrue) then
        attributeValue := attributeUsage;
      elsif(transactionIdIn is not null) then
        dynamicCursor := dbms_sql.open_cursor;
        dbms_sql.parse(dynamicCursor,
                       ame_util.removeReturns(stringIn => attributeUsage,
                                              replaceWithSpaces => true),
                       dbms_sql.native);
        dbms_sql.define_column(dynamicCursor,
                               1,
                               attributeValue,
                               ame_util.attributeValueTypeLength);
        if(instrb(attributeUsage, ame_util.transactionIdPlaceholder) > 0) then
          dbms_sql.bind_variable(dynamicCursor,
                                 ame_util.transactionIdPlaceholder,
                                 transactionIdIn);
        end if;
        ignoreMe := dbms_sql.execute(dynamicCursor);
        if(dbms_sql.fetch_rows(dynamicCursor) > 0) then
          /*
            Don't raise an exception if the fetch returns no rows, because we can't log the
            exception (see below); just silently use the default attributeValue value.
          */
          dbms_sql.column_value(dynamicCursor,
                                1,
                                attributeValue);
        end if;
        dbms_sql.close_cursor(dynamicCursor);
      end if;
      if(attributeValue = ame_util.booleanAttributeTrue) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          /*
            Don't call runtimeException here; it could result in infinite looping,
            because runtimeException calls useWorkflow.  (See bug 2219719.)
          */
          raise;
          return(false);
    end useWorkflow;
  function validateUser(responsibilityIn in integer,
                        applicationIdIn in integer default null) return integer as
    securedAttributeList icx_sec.g_num_tbl_type;
    highestResponsibility integer;
    responsibilityCount integer;
    responsibilityList icx_sec.g_responsibility_list;
    returnStatus varchar2(4000);
    securedAttributeCount integer;
    tempIndex integer;
    tempSecuredAttribute ak_web_user_sec_attr_values.number_value%type;
    userId fnd_user.user_id%type;
    begin
      if not icx_sec.validatesession then
        return(ame_util.noResponsibility);
      end if;
      highestResponsibility := getHighestResponsibility;
      /* If applicationIdIn is not null, and the user is a limited business user, check secure attribute. */
      if(applicationIdIn is not null and
         highestResponsibility = ame_util.limBusResponsibility) then
           tempSecuredAttribute := applicationIdIn;
           icx_sec.getsecureattributevalues(p_attri_code => ame_util.attributeCode,
                                            p_return_status => returnStatus,
                                            p_num_tbl => securedAttributeList);
           securedAttributeCount := securedAttributeList.count;
           for i in 1..securedAttributeCount loop
             if i = 1 then
               tempIndex := securedAttributeList.first;
               if(securedAttributeList(tempIndex) = tempSecuredAttribute) then
                 return(highestResponsibility);
               end if;
             else
               tempIndex := securedAttributeList.next(tempIndex);
               if(securedAttributeList(tempIndex) = tempSecuredAttribute) then
                 return(highestResponsibility);
               end if;
             end if;
           end loop;
           highestResponsibility := ame_util.noResponsibility;
      end if;
      if highestResponsibility >= responsibilityIn then
        return(highestResponsibility);
      end if;
      return(ame_util.noResponsibility);
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'validateUser',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
        raise;
        return(ame_util.noResponsibility);
    end validateUser;
  function versionDateToDisplayDate(stringDateIn in varchar2) return varchar2 as
    begin
      return(fnd_date.date_to_displayDate(dateVal => versionStringToDate(stringDateIn => stringDateIn)));
      exception
        when no_data_found then
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'versionDateToDisplayDate',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end versionDateToDisplayDate;
  function versionDateToString(dateIn in date) return varchar2 as
    begin
      return(to_char(dateIn, ame_util.versionDateFormatModel));
      exception
        when no_data_found then
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'versionDateToString',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end versionDateToString;
  function versionStringToDate(stringDateIn in varchar2) return date as
    begin
      return(to_date(stringDateIn, ame_util.versionDateFormatModel));
      exception
        when no_data_found then
          return(null);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'versionStringToDate',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end versionStringToDate;
  procedure appendRuleIdToSource(ruleIdIn in integer,
                                 sourceInOut in out nocopy varchar2) as
    ruleId varchar2(50);
    ruleIds ame_util.idList;
    sourceDescription ame_util.longStringType;
    sourceLength integer;
    begin
      if(sourceInOut is null) then
        sourceInOut := to_char(ruleIdIn);
        return;
      end if;
      /* Now we can assume sourceInOut starts out nonempty. */
      sourceLength := lengthb(sourceInOut);
      ruleId := to_char(ruleIdIn);
      if(sourceLength + 1 + lengthb(ruleId) < 500) then
        parseSourceValue(sourceValueIn => sourceInOut,
                         sourceDescriptionOut => sourceDescription,
                         ruleIdListOut => ruleIds);
        for i in 1 .. ruleIds.count loop
          if(ruleIdIn = ruleIds(i)) then /* Don't duplicate rule IDs in a source field. */
            return;
          end if;
        end loop;
        sourceInOut := sourceInOut || fieldDelimiter || ruleId;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'appendRuleIdToSource',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end appendRuleIdToSource;
  --
  -- This procedure will translate the approver record from type
  -- ame_util.approverRecord to ame_util.approverRecord2
  --
  procedure apprRecordToApprRecord2(approverRecordIn in ame_util.approverRecord,
                                    itemIdIn in varchar2 default null,
                                    approverRecord2Out out nocopy ame_util.approverRecord2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempOrigSystem   wf_roles.orig_system%type;
    tempOrigSystemId wf_roles.orig_system_id%type;
    wfName           wf_roles.name%type;
    wfDisplayName    wf_roles.display_name%type;
    begin
      if approverRecordIn.person_id is null then
        tempOrigSystem := ame_util.fndUserOrigSystem;
        tempOrigSystemId := approverRecordIn.user_id;
      else
        tempOrigSystem := ame_util.perOrigSystem;
        tempOrigSystemId := approverRecordIn.person_id;
      end if;
      if tempOrigSystem = ame_util.perOrigSystem then
        select name, display_name
          into wfName, wfDisplayName
          from wf_roles wf
           where orig_system = tempOrigSystem
             and orig_system_id = tempOrigSystemId
             and status = 'ACTIVE'
             and (expiration_date is null or sysdate < expiration_date)
             and exists (select null
                           from fnd_user u
                          where u.user_name = wf.name
                            and trunc(sysdate) between u.start_date
                            and nvl(u.end_date,trunc(sysdate)))
             and not exists (
                  select null from wf_roles wf2
                   where wf.orig_system = wf2.orig_system
                     and wf.orig_system_id = wf2.orig_system_id
                     and wf.start_date > wf2.start_date
                            )
             and rownum < 2;
      elsif tempOrigSystem = ame_util.fndUserOrigSystem then
        select name
              ,display_name
              ,orig_system
              ,orig_system_id
          into wfName
              ,wfDisplayName
              ,tempOrigSystem
              ,tempOrigSystemId
          from wf_roles wf
         where wf.orig_system    in('FND_USR','PER')
           and wf.name in (select u.user_name
                             from fnd_user u
                            where u.user_id = tempOrigSystemId
                              and trunc(sysdate) between u.start_date
                              and nvl(u.end_date,trunc(sysdate)))
           and wf.status      = 'ACTIVE'
           and (wf.expiration_date is null or sysdate < wf.expiration_date)
           -- need not check for proxy user in this case
           and rownum < 2;
      end if;
      approverRecord2Out.orig_system    := tempOrigSystem;
      approverRecord2Out.orig_system_id := tempOrigSystemId;
      approverRecord2Out.name := wfName;
      approverRecord2Out.display_name := wfDisplayName;
      approverRecord2Out.item_class := ame_util.headerItemClassName;
      approverRecord2Out.item_id := itemIdIn;
      approverRecord2Out.approver_category := ame_util.approvalApproverCategory ;
      approverRecord2Out.api_insertion := approverRecordIn.api_insertion;
      approverRecord2Out.authority := approverRecordIn.authority;
      approverRecord2Out.approval_status := approverRecordIn.approval_status;
      approverRecord2Out.action_type_id := approverRecordIn.approval_type_id;
      approverRecord2Out.group_or_chain_id := approverRecordIn.group_or_chain_id;
      approverRecord2Out.occurrence := approverRecordIn.occurrence;
      approverRecord2Out.source := approverRecordIn.source;
      /* initialize all order numbers to 1 */
      approverRecord2Out.item_class_order_number := 1;
      approverRecord2Out.item_order_number := 1;
      approverRecord2Out.sub_list_order_number := 1;
      approverRecord2Out.action_type_order_number := 1;
      approverRecord2Out.group_or_chain_order_number := 1;
      approverRecord2Out.member_order_number := 1;
      approverRecord2Out.approver_order_number := 1;
    exception
      when no_data_found then
        errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn =>'PER',
          messageNameIn => 'AME_400249_API_APR_REC_NULL');
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecordToApprRecord2',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
         approverRecord2Out.name := null ;
         raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecordToApprRecord2',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         approverRecord2Out := ame_util.emptyApproverRecord2;
         raise;
    end apprRecordToApprRecord2;
--
-- This procedure will translate the approver record from the new Type i.e.
-- ame_util.approverRecord2 to ame_util.approverRecord
--
  procedure apprRecord2ToApprRecord(approverRecord2In in ame_util.approverRecord2,
                                    approverRecordOut out nocopy ame_util.approverRecord) is
      errorCode integer;
      errorMessage ame_util.longestStringType;
      firstName per_all_people_f.first_name%type;
      lastName per_all_people_f.last_name%type;
      tempOrigSystem ame_util.stringType;
      tempOrigSystemId integer;
      userName fnd_user.user_name%type;
      wrongCategory exception;
      wrongItemClass exception;
      wrongOrigSystem exception;
    begin
      if approverRecord2In.item_class <> ame_util.headerItemClassName then
        raise wrongItemClass;
      end if;
      if approverRecord2In.approver_category <> ame_util.approvalApproverCategory then
        raise wrongCategory;
      end if;
      if approverRecord2In.orig_system is null  or
         approverRecord2In.orig_system_id is null  then
        ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn => approverRecord2In.name,
                                                   origSystemOut => tempOrigSystem,
                                                   origSystemIdOut => tempOrigSystemId);
      else
        tempOrigSystem := approverRecord2In.orig_system;
        tempOrigSystemId := approverRecord2In.orig_system_id;
      end if;
      if tempOrigSystem = ame_util.perOrigSystem then
        approverRecordOut.user_id := null;
        approverRecordOut.person_id := tempOrigSystemId;
        select pap.first_name
              ,pap.last_name
          into firstName
              ,lastName
          from  per_all_people_f      pap
               ,per_all_assignments_f pas
         where pap.person_id =  approverRecordOut.person_id
           and pap.person_id = pas.person_id
           and pas.primary_flag = 'Y'
           and pas.assignment_type in ('E','C')
           and pas.assignment_status_type_id not in
                    (select assignment_status_type_id
                     from per_assignment_status_types
                     where per_system_status = 'TERM_ASSIGN')
           and trunc(sysdate) between pas.effective_start_date and pas.effective_end_date
           and (
                  trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
               or (pap.effective_start_date <= trunc(sysdate) and pap.effective_end_date is null)
               );
        approverRecordOut.first_name := firstName;
        approverRecordOut.last_name := lastName;
      elsif tempOrigSystem = ame_util.fndUserOrigSystem then
        approverRecordOut.user_id := tempOrigSystemId;
        approverRecordOut.person_id := null;
        select user_name
          into userName
          from fnd_user
          where user_id = approverRecordOut.user_id and
           (sysdate between start_date and end_date or
              (start_date <= sysdate and end_date is null));
        approverRecordOut.first_name := userName;
        approverRecordOut.last_name := null;
      else
        raise wrongOrigSystem;
      end if;
      approverRecordOut.api_insertion := approverRecord2In.api_insertion;
      approverRecordOut.authority := approverRecord2In.authority;
      approverRecordOut.approval_status := approverRecord2In.approval_status;
      approverRecordOut.approval_type_id := approverRecord2In.action_type_id;
      approverRecordOut.group_or_chain_id := approverRecord2In.group_or_chain_id;
      approverRecordOut.occurrence := approverRecord2In.occurrence;
      approverRecordOut.source := approverRecord2In.source;
    exception
      when wrongOrigSystem then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecord2ToApprRecord',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when wrongCategory then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400416_APPR_FYI',
                                              tokenNameOneIn => 'NAME',
                                              tokenValueOneIn =>approverRecord2In.name );
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecord2ToApprRecord',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
         raise_application_error(errorCode,
                                  errorMessage);
      when wrongItemClass then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                            messageNameIn => 'AME_400417_APPR_NOT_HEADER_IC');
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecord2ToApprRecord',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprRecord2ToApprRecord',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         raise;
    end apprRecord2ToApprRecord;
--
-- This procedure will translate the approver table from type
-- ame_util.approverTable to ame_util.approverTable2
--
  procedure apprTableToApprTable2(approversTableIn in ame_util.approversTable,
                                  itemIdIn in varchar2 default null,
                                  approversTable2Out out nocopy ame_util.approversTable2) is
    ct integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    wfName wf_roles.name%type;
    wfDisplayName wf_roles.display_name%type;
    tempOrigSystem wf_roles.orig_system%type;
    tempOrigSystemId wf_roles.orig_system_id%type;
    begin
        for ct in 1..approversTableIn.count loop
          if approversTableIn(ct).person_id is null then
            tempOrigSystem   := ame_util.fndUserOrigSystem;
            tempOrigSystemId := approversTableIn(ct).user_id;
          else
            tempOrigSystem   := ame_util.perOrigSystem;
            tempOrigSystemId := approversTableIn(ct).person_id;
          end if;
          approversTable2Out(ct).approver_category := ame_util.approvalApproverCategory ;
          approversTable2Out(ct).item_class := ame_util.headerItemClassName ;
          approversTable2Out(ct).item_id := itemIdIn ;
          approversTable2Out(ct).api_insertion := approversTableIn(ct).api_insertion;
          approversTable2Out(ct).authority := approversTableIn(ct).authority;
          approversTable2Out(ct).approval_status := approversTableIn(ct).approval_status;
          approversTable2Out(ct).action_type_id := approversTableIn(ct).approval_type_id;
          approversTable2Out(ct).group_or_chain_id := approversTableIn(ct).group_or_chain_id;
          approversTable2Out(ct).occurrence := approversTableIn(ct).occurrence;
          approversTable2Out(ct).source := approversTableIn(ct).source;
          if tempOrigSystem = ame_util.perOrigSystem then
            select name, display_name
              into wfName, wfDisplayName
              from wf_roles wf
               where orig_system = tempOrigSystem
                 and orig_system_id = tempOrigSystemId
                 and status = 'ACTIVE'
                 and (expiration_date is null or sysdate < expiration_date)
                 and exists (select null
                               from fnd_user u
                              where u.user_name = wf.name
                                and trunc(sysdate) between u.start_date
                                and nvl(u.end_date,trunc(sysdate)))
                 and not exists (
                      select null from wf_roles wf2
                       where wf.orig_system = wf2.orig_system
                         and wf.orig_system_id = wf2.orig_system_id
                         and wf.start_date > wf2.start_date
                                )
                 and rownum < 2;
          elsif tempOrigSystem = ame_util.fndUserOrigSystem then
            select name
                  ,display_name
                  ,orig_system
                  ,orig_system_id
              into wfName
                  ,wfDisplayName
                  ,tempOrigSystem
                  ,tempOrigSystemId
              from wf_roles wf
             where wf.orig_system    in('FND_USR','PER')
               and wf.name in (select u.user_name
                                 from fnd_user u
                                where u.user_id = tempOrigSystemId
                                  and trunc(sysdate) between u.start_date
                                  and nvl(u.end_date,trunc(sysdate)))
               and wf.status      = 'ACTIVE'
               and (wf.expiration_date is null or sysdate < wf.expiration_date)
               -- need not check for proxy user in this case
               and rownum < 2;
          end if;
          approversTable2Out(ct).orig_system    := tempOrigSystem;
          approversTable2Out(ct).orig_system_id := tempOrigSystemId;
          approversTable2Out(ct).name := wfName;
          approversTable2Out(ct).display_name := wfDisplayName;
          /* initialize all order numbers to 1 and approver_order_number to serial number */
          approversTable2Out(ct).item_class_order_number := 1;
          approversTable2Out(ct).item_order_number := 1;
          approversTable2Out(ct).sub_list_order_number := 1;
          approversTable2Out(ct).action_type_order_number := 1;
          approversTable2Out(ct).group_or_chain_order_number := 1;
          approversTable2Out(ct).member_order_number := 1;
          approversTable2Out(ct).approver_order_number := ct;
        end loop;
    exception
      when no_data_found then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                            messageNameIn => 'AME_400249_API_APR_REC_NULL');
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprTableToApprTable2',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        approversTable2Out.delete;
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprTableToApprTable2',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         approversTable2Out.delete;
         raise;
    end apprTableToApprTable2;
  --
  -- This procedure will translate the approver table from the new Type i.e.
  -- ame_util.approverTable2 to ame_util.approverTable
  --
  procedure apprTable2ToApprTable(approversTable2In in ame_util.approversTable2,
                                  approversTableOut out nocopy ame_util.approversTable) is
      ct integer;
      errorCode integer;
      errorMessage ame_util.longestStringType;
      errorWfName ame_util.stringType;
      firstName per_all_people_f.first_name%type;
      lastName per_all_people_f.last_name%type;
      tempOrigSystem ame_util.stringType;
      tempOrigSystemId integer;
      userName fnd_user.user_name%type;
      wrongCategory exception;
      wrongItemClass exception;
      wrongOrigSystem exception;
    begin
      for ct in 1..approversTable2In.count loop
        if approversTable2In(ct).approver_category<>ame_util.approvalApproverCategory then
          errorWfName := approversTable2In(ct).name;
          raise wrongCategory;
        end if;
      if approversTable2In(ct).item_class <> ame_util.headerItemClassName then
        raise wrongItemClass;
      end if;
        if approversTable2In(ct).orig_system is null  or
           approversTable2In(ct).orig_system_id is null  then
          ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn => approversTable2In(ct).name,
                                                   origSystemOut => tempOrigSystem,
                                                   origSystemIdOut => tempOrigSystemId);
        else
          tempOrigSystem := approversTable2In(ct).orig_system;
          tempOrigSystemId := approversTable2In(ct).orig_system_id;
        end if;
        if tempOrigSystem = ame_util.perOrigSystem then
          approversTableOut(ct).user_id := null;
          approversTableOut(ct).person_id := tempOrigSystemId;
          select pap.first_name
                ,pap.last_name
            into firstName
                ,lastName
            from per_all_people_f     pap
                ,per_all_assignments_f pas
           where pap.person_id =  approversTableOut(ct).person_id
             and pap.person_id = pas.person_id
             and pas.primary_flag    = 'Y'
             and pas.assignment_type in ('E','C')
             and pas.assignment_status_type_id not in
                      (select assignment_status_type_id
                       from per_assignment_status_types
                       where per_system_status = 'TERM_ASSIGN')
             and trunc(sysdate) between pas.effective_start_date and pas.effective_end_date
             and (
                    trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
                 or (pap.effective_start_date <= trunc(sysdate) and pap.effective_end_date is null)
                 );
          approversTableOut(ct).first_name := firstName;
          approversTableOut(ct).last_name := lastName;
        elsif tempOrigSystem = ame_util.fndUserOrigSystem then
          approversTableOut(ct).user_id := tempOrigSystemId;
          approversTableOut(ct).person_id := null;
          select user_name
            into userName
            from fnd_user
            where user_id = approversTableOut(ct).user_id and
                 (sysdate between start_date and end_date or
                  (start_date <= sysdate and end_date is null));
          approversTableOut(ct).first_name := userName;
          approversTableOut(ct).last_name := null;
        else
          raise wrongOrigSystem;
        end if;
        approversTableOut(ct).api_insertion := approversTable2In(ct).api_insertion;
        approversTableOut(ct).authority := approversTable2In(ct).authority;
        approversTableOut(ct).approval_status := approversTable2In(ct).approval_status;
        approversTableOut(ct).approval_type_id := approversTable2In(ct).action_type_id;
        approversTableOut(ct).group_or_chain_id := approversTable2In(ct).group_or_chain_id;
        approversTableOut(ct).occurrence := approversTable2In(ct).occurrence;
        approversTableOut(ct).source := approversTable2In(ct).source;
      end loop;
    exception
      when wrongOrigSystem then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprTable2ToApprTable',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
          approversTableOut.delete;
          raise_application_error(errorCode,
                                  errorMessage);
      when wrongCategory then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400416_APPR_FYI',
                                              tokenNameOneIn => 'NAME',
                                              tokenValueOneIn =>errorWfName );
          ame_util.runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'apprTable2ToApprTable',
                             exceptionNumberIn => errorCode,
                             exceptionStringIn => errorMessage);
           approversTableOut.delete;
           raise_application_error(errorCode,
                                  errorMessage);
      when wrongItemClass then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                            messageNameIn => 'AME_400417_APPR_NOT_HEADER_IC');
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'apprTable2ToApprTable',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        approversTableOut.delete;
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
            ame_util.runtimeException(packageNameIn => 'ame_util',
                             routineNameIn => 'apprTable2ToApprTable',
                             exceptionNumberIn => sqlcode,
                             exceptionStringIn => sqlerrm);
           approversTableOut.delete;
    end apprTable2ToApprTable;
  procedure autonomousLog(logIdIn number,
                          packageNameIn in varchar2,
                          routineNameIn in varchar2,
                          exceptionNumberIn in integer,
                          exceptionStringIn in varchar2,
                          transactionIdIn in varchar2 default null,
                          applicationIdIn in integer default null) as
    pragma autonomous_transaction;
    begin
        insert into ame_exceptions_log(
          log_id,
          package_name,
          routine_name,
          transaction_id,
          application_id,
          exception_number,
          exception_string) values(
            logIdIn,
            substrb(packageNameIn, 1, 50),
            substrb(routineNameIn, 1, 50),
            transactionIdIn,
            applicationIdIn,
            exceptionNumberIn,
            substrb(to_char(sysdate, 'YYYY:MM:DD:HH24:MI:SS')||exceptionStringIn, 1, 4000));
        commit;
      exception
        when others then
          rollback;
          raise;
    end autonomousLog;
  procedure checkForSqlInjection(queryStringIn in varchar2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidStringException exception;
    keyword ame_util.stringType;
    keywordFoundException exception;
    keywords ame_util.stringList;
    lowerQueryString ame_util.longestStringType;
    tempLowerQueryString ame_util.longestStringType;
    tempConnectPos number ;
    begin
      if(upper(queryStringIn) like '%<SCRIPT>%') then
        raise invalidStringException;
      end if;
      lowerQueryString := removeReturns(stringIn => lower(queryStringIn),
                                        replaceWithSpaces => true);
      /* keywords lists all prohibited keywords, in lower case. */
      keywords(1) := 'delete';
      keywords(2) := 'insert';
      keywords(3) := 'update';
      keywords(4) := 'truncate';
      keywords(5) := 'drop';
      keywords(6) := 'grant';
      keywords(7) := 'execute';
      keywords(8) := 'set';
      keywords(9) := 'lock';
      keywords(10) := 'create';
      keywords(11) := 'alter';
      keywords(12) := 'commit';
      keywords(13) := 'connect';
      keywords(14) := 'rollback';
      keywords(15) := 'dbms_sql';
      keywords(16) := 'dbms_output';
      keywords(17) := 'htp';
      keywords(18) := 'htf';
      keywords(19) := 'owa_util';
      keywords(20) := 'owa_cookie';
      tempConnectPos := 0;
      for i in 1 .. keywords.count loop
        if lowerQueryString like 'connect '  or
          instrb(lowerQueryString, 'connect ') > 0 then
            tempLowerQueryString := lowerQueryString;
            tempLowerQueryString := replace(tempLowerQueryString,'	',' ');
            tempConnectPos := instrb(tempLowerQueryString,'connect ',1);
              while tempConnectPos > 0 loop
                tempLowerQueryString := trim(substr(tempLowerQueryString,tempConnectPos +7));
                if substrb(tempLowerQueryString,1,3) <> 'by ' then
                  keyword := 'connect';
                  raise keywordFoundException;
                end if;
                tempConnectPos := instrb(tempLowerQueryString,'connect ',1);
              end loop;
        elsif(lowerQueryString like (keywords(i) || ' ') or
              instrb(lowerQueryString, (keywords(i) || ' ')) > 0) then
          keyword := keywords(i);
          raise keywordFoundException;
        end if;
      end loop;
      exception
        when invalidStringException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400456_NO_SCRIPT_TAG');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'checkForSqlInjection',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when keywordFoundException then
          errorCode := -20001;
          errorMessage := -- pa message
            'The following prohibited keyword occurs in the query you submitted:  ' ||
            keyword ||
            '.  ';
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'checkForSqlInjection',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'checkForSqlInjection',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end checkForSqlInjection;
  procedure compactIdList(idListInOut in out nocopy idList) as
    tempNextIndex integer;
    upperLimit integer;
    begin
      /* First, if the list is of size n, copy the list down into its first n slots. */
      upperLimit := idListInOut.count;
      if(upperLimit = 0) then
        return;
      end if;
      tempNextIndex := idListInOut.first;
      idListInOut(1) := idListInOut(tempNextIndex);
      if(upperLimit > 1) then
        for i in 2 .. upperLimit loop
          tempNextIndex := idListInOut.next(tempNextIndex);
          idListInOut(i) := idListInOut(tempNextIndex);
        end loop;
      end if;
      /* Second, delete all slots beyond the nth slot. */
      loop
        tempNextIndex := idListInOut.next(upperLimit);
        if(tempNextIndex is null) then
          exit;
        end if;
        idListInOut.delete(tempNextIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'compactIdList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end compactIdList;
  procedure compactLongestStringList(longestStringListInOut in out nocopy ame_util.longestStringList) as
    tempNextIndex integer;
    upperLimit integer;
    begin
      /* First, if the list is of size n, copy the list down into its first n slots. */
      upperLimit := longestStringListInOut.count;
      if(upperLimit = 0) then
        return;
      end if;
      tempNextIndex := longestStringListInOut.first;
      longestStringListInOut(1) := longestStringListInOut(tempNextIndex);
      if(upperLimit > 1) then
        for i in 2 .. upperLimit loop
          tempNextIndex := longestStringListInOut.next(tempNextIndex);
          longestStringListInOut(i) := longestStringListInOut(tempNextIndex);
        end loop;
      end if;
      /* Second, delete all slots beyond the nth slot. */
      loop
        tempNextIndex := longestStringListInOut.next(upperLimit);
        if(tempNextIndex is null) then
          exit;
        end if;
        longestStringListInOut.delete(tempNextIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'compactLongestStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm );
          raise;
    end compactLongestStringList;
  procedure compactLongStringList(longStringListInOut in out nocopy ame_util.longStringList) as
    tempNextIndex integer;
    upperLimit integer;
    begin
      /* First, if the list is of size n, copy the list down into its first n slots. */
      upperLimit := longStringListInOut.count;
      if(upperLimit = 0) then
        return;
      end if;
      tempNextIndex := longStringListInOut.first;
      longStringListInOut(1) := longStringListInOut(tempNextIndex);
      if(upperLimit > 1) then
        for i in 2 .. upperLimit loop
          tempNextIndex := longStringListInOut.next(tempNextIndex);
          longStringListInOut(i) := longStringListInOut(tempNextIndex);
        end loop;
      end if;
      /* Second, delete all slots beyond the nth slot. */
      loop
        tempNextIndex := longStringListInOut.next(upperLimit);
        if(tempNextIndex is null) then
          exit;
        end if;
        longStringListInOut.delete(tempNextIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'compactLongStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm );
          raise;
    end compactLongStringList;
  procedure compactStringList(stringListInOut in out nocopy ame_util.stringList) as
    tempNextIndex integer;
    upperLimit integer;
    begin
      /* First, if the list is of size n, copy the list down into its first n slots. */
      upperLimit := stringListInOut.count;
      if(upperLimit = 0) then
        return;
      end if;
      tempNextIndex := stringListInOut.first;
      stringListInOut(1) := stringListInOut(tempNextIndex);
      if(upperLimit > 1) then
        for i in 2 .. upperLimit loop
          tempNextIndex := stringListInOut.next(tempNextIndex);
          stringListInOut(i) := stringListInOut(tempNextIndex);
        end loop;
      end if;
      /* Second, delete all slots beyond the nth slot. */
      loop
        tempNextIndex := stringListInOut.next(upperLimit);
        if(tempNextIndex is null) then
          exit;
        end if;
        stringListInOut.delete(tempNextIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'compactStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm );
          raise;
    end compactStringList;
  procedure convertApproversTableToValues(approversTableIn in ame_util.approversTable,
                                          personIdValuesOut out nocopy ame_util.idList,
                                          userIdValuesOut out nocopy ame_util.idList,
                                          apiInsertionValuesOut out nocopy ame_util.charList,
                                          authorityValuesOut out nocopy ame_util.charList,
                                          approvalTypeIdValuesOut out nocopy ame_util.idList,
                                          groupOrChainIdValuesOut out nocopy ame_util.idList,
                                          occurrenceValuesOut out nocopy ame_util.idList,
                                          sourceValuesOut out nocopy ame_util.longStringList,
                                          statusValuesOut out nocopy ame_util.stringList) as
    upperLimit integer;
    begin
      upperLimit := approversTableIn.count;
      for i in 1 .. upperLimit loop
        personIdValuesOut(i) := approversTableIn(i).person_id;
        userIdValuesOut(i) := approversTableIn(i).user_id;
        apiInsertionValuesOut(i) := approversTableIn(i).api_insertion;
        authorityValuesOut(i) := approversTableIn(i).authority;
        approvalTypeIdValuesOut(i) := approversTableIn(i).approval_type_id;
        groupOrChainIdValuesOut(i) := approversTableIn(i).group_or_chain_id;
        occurrenceValuesOut(i) := approversTableIn(i).occurrence;
        sourceValuesOut(i) := approversTableIn(i).source;
        statusValuesOut(i) := approversTableIn(i).approval_status;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertApproverTableToValues',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          apiInsertionValuesOut.delete;
          authorityValuesOut.delete;
          personIdValuesOut.delete;
          statusValuesOut.delete;
          userIdValuesOut.delete;
          approvalTypeIdValuesOut.delete;
          groupOrChainIdValuesOut.delete;
          occurrenceValuesOut.delete;
          sourceValuesOut.delete;
          raise;
    end convertApproversTableToValues;
  procedure convertApproversTable2ToValues(approversTableIn in ame_util.approversTable2,
                                           namesOut out nocopy ame_util.longStringList,
                                           itemClassesOut out nocopy ame_util.stringList,
                                           itemIdsOut out nocopy ame_util.stringList,
                                           apiInsertionsOut out nocopy ame_util.charList,
                                           authoritiesOut out nocopy ame_util.charList,
                                           actionTypeIdsOut out nocopy ame_util.idList,
                                           groupOrChainIdsOut out nocopy ame_util.idList,
                                           occurrencesOut out nocopy ame_util.idList,
                                           approverCategoriesOut out nocopy ame_util.charList,
                                           statusesOut out nocopy ame_util.stringList) as
    begin
      for i in 1 .. approversTableIn.count loop
        namesOut(i) := approversTableIn(i).name;
        itemClassesOut(i) := approversTableIn(i).item_class;
        itemIdsOut(i) := approversTableIn(i).item_id;
        apiInsertionsOut(i) := approversTableIn(i).api_insertion;
        authoritiesOut(i) := approversTableIn(i).authority;
        actionTypeIdsOut(i) := approversTableIn(i).action_type_id;
        groupOrChainIdsOut(i) := approversTableIn(i).group_or_chain_id;
        occurrencesOut(i) := approversTableIn(i).occurrence;
        approverCategoriesOut(i) := approversTableIn(i).approver_category;
        statusesOut(i) := approversTableIn(i).approval_status;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertApproversTable2ToValues',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end convertApproversTable2ToValues;
  procedure convertValuesToApproversTable(personIdValuesIn in ame_util.idList,
                                          userIdValuesIn in ame_util.idList,
                                          apiInsertionValuesIn in ame_util.charList,
                                          authorityValuesIn in ame_util.charList,
                                          approvalTypeIdValuesIn in ame_util.idList,
                                          groupOrChainIdValuesIn in ame_util.idList,
                                          occurrenceValuesIn in ame_util.idList,
                                          sourceValuesIn in ame_util.longStringList,
                                          statusValuesIn in ame_util.stringList,
                                          approversTableOut out nocopy ame_util.approversTable) as
    badCountException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    upperLimit integer;
    begin
      upperLimit := personIdValuesIn.count;
      if(upperLimit <> userIdValuesIn.count or
         upperLimit <> apiInsertionValuesIn.count or
         upperLimit <> authorityValuesIn.count or
         upperLimit <> approvalTypeIdValuesIn.count or
         upperLimit <> groupOrChainIdValuesIn.count or
         upperLimit <> occurrenceValuesIn.count or
         upperLimit <> sourceValuesIn.count or
         upperLimit <> statusValuesIn.count) then
        raise badCountException;
      end if;
      for i in 1 .. upperLimit loop
        approversTableOut(i).person_id := personIdValuesIn(i);
        approversTableOut(i).user_id := userIdValuesIn(i);
        approversTableOut(i).api_insertion := apiInsertionValuesIn(i);
        approversTableOut(i).authority := authorityValuesIn(i);
        approversTableOut(i).approval_type_id := approvalTypeIdValuesIn(i);
        approversTableOut(i).group_or_chain_id := groupOrChainIdValuesIn(i);
        approversTableOut(i).occurrence := occurrenceValuesIn(i);
        approversTableOut(i).source := sourceValuesIn(i);
        approversTableOut(i).approval_status := statusValuesIn(i);
        approversTableOut(i).first_name := null;
        approversTableOut(i).last_name := null;
      end loop;
      exception
        when badCountException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400222_UTL_TAB_DIFF_SIZE');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertValuesToApproversTable',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertValuesToApproversTable',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          approversTableOut.delete;
          raise;
    end convertValuesToApproversTable;
  procedure convertValuesToApproversTable2(nameValuesIn in ame_util.longStringList,
                                          approverCategoryValuesIn in ame_util.charList,
                                          apiInsertionValuesIn in ame_util.charList,
                                          authorityValuesIn in ame_util.charList,
                                          approvalTypeIdValuesIn in ame_util.idList,
                                          groupOrChainIdValuesIn in ame_util.idList,
                                          occurrenceValuesIn in ame_util.idList,
                                          sourceValuesIn in ame_util.longStringList,
                                          statusValuesIn in ame_util.stringList,
                                          approversTableOut out nocopy ame_util.approversTable2) as
    badCountException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    upperLimit integer;
    begin
      upperLimit := nameValuesIn.count;
      if(upperLimit <> approverCategoryValuesIn.count or
         upperLimit <> apiInsertionValuesIn.count or
         upperLimit <> authorityValuesIn.count or
         upperLimit <> approvalTypeIdValuesIn.count or
         upperLimit <> groupOrChainIdValuesIn.count or
         upperLimit <> occurrenceValuesIn.count or
         upperLimit <> sourceValuesIn.count or
         upperLimit <> statusValuesIn.count) then
        raise badCountException;
      end if;
      for i in 1 .. upperLimit loop
        approversTableOut(i).name := nameValuesIn(i);
        approversTableOut(i).approver_category := approverCategoryValuesIn(i);
        approversTableOut(i).api_insertion := apiInsertionValuesIn(i);
        approversTableOut(i).authority := authorityValuesIn(i);
        approversTableOut(i).action_type_id := approvalTypeIdValuesIn(i);
        approversTableOut(i).group_or_chain_id := groupOrChainIdValuesIn(i);
        approversTableOut(i).occurrence := occurrenceValuesIn(i);
        approversTableOut(i).source := sourceValuesIn(i);
        approversTableOut(i).approval_status := statusValuesIn(i);
        approversTableOut(i).orig_system := null;
        approversTableOut(i).orig_system_id := null;
        approversTableOut(i).display_name := null;
      end loop;
      exception
        when badCountException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400222_UTL_TAB_DIFF_SIZE');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertValuesToApproversTable',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'convertValuesToApproversTable',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          approversTableOut.delete;
          raise;
    end convertValuesToApproversTable2;
  procedure copyApproverRecord2(approverRecord2In in approverRecord2,
                                approverRecord2Out out nocopy approverRecord2) as
    begin
      approverRecord2Out.name := approverRecord2In.name;
      approverRecord2Out.orig_system := approverRecord2In.orig_system;
      approverRecord2Out.orig_system_id := approverRecord2In.orig_system_id;
      approverRecord2Out.display_name := approverRecord2In.display_name;
      approverRecord2Out.approver_category := approverRecord2In.approver_category;
      approverRecord2Out.api_insertion := approverRecord2In.api_insertion;
      approverRecord2Out.authority := approverRecord2In.authority;
      approverRecord2Out.approval_status := approverRecord2In.approval_status;
      approverRecord2Out.action_type_id := approverRecord2In.action_type_id;
      approverRecord2Out.group_or_chain_id := approverRecord2In.group_or_chain_id;
      approverRecord2Out.occurrence := approverRecord2In.occurrence;
      approverRecord2Out.source := approverRecord2In.source;
      approverRecord2Out.item_class := approverRecord2In.item_class;
      approverRecord2Out.item_id := approverRecord2In.item_id;
      approverRecord2Out.item_class_order_number := approverRecord2In.item_class_order_number;
      approverRecord2Out.item_order_number := approverRecord2In.item_order_number;
      approverRecord2Out.sub_list_order_number := approverRecord2In.sub_list_order_number;
      approverRecord2Out.action_type_order_number := approverRecord2In.action_type_order_number;
      approverRecord2Out.group_or_chain_order_number := approverRecord2In.group_or_chain_order_number;
      approverRecord2Out.member_order_number := approverRecord2In.member_order_number;
      approverRecord2Out.approver_order_number := approverRecord2In.approver_order_number;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyApproverRecord2',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end copyApproverRecord2;
  procedure copyApproversTable2(approversTable2In in approversTable2,
                                approversTable2Out out nocopy approversTable2) as
      tempIndex integer;
    begin
      tempIndex := approversTable2In.first;
      while (tempIndex is not null) loop
        approversTable2Out(tempIndex).name := approversTable2In(tempIndex).name;
        approversTable2Out(tempIndex).orig_system := approversTable2In(tempIndex).orig_system;
        approversTable2Out(tempIndex).orig_system_id := approversTable2In(tempIndex).orig_system_id;
        approversTable2Out(tempIndex).display_name := approversTable2In(tempIndex).display_name;
        approversTable2Out(tempIndex).approver_category := approversTable2In(tempIndex).approver_category;
        approversTable2Out(tempIndex).api_insertion := approversTable2In(tempIndex).api_insertion;
        approversTable2Out(tempIndex).authority := approversTable2In(tempIndex).authority;
        approversTable2Out(tempIndex).approval_status := approversTable2In(tempIndex).approval_status;
        approversTable2Out(tempIndex).action_type_id := approversTable2In(tempIndex).action_type_id;
        approversTable2Out(tempIndex).group_or_chain_id := approversTable2In(tempIndex).group_or_chain_id;
        approversTable2Out(tempIndex).occurrence := approversTable2In(tempIndex).occurrence;
        approversTable2Out(tempIndex).source := approversTable2In(tempIndex).source;
        approversTable2Out(tempIndex).item_class := approversTable2In(tempIndex).item_class;
        approversTable2Out(tempIndex).item_id := approversTable2In(tempIndex).item_id;
        approversTable2Out(tempIndex).item_class_order_number := approversTable2In(tempIndex).item_class_order_number;
        approversTable2Out(tempIndex).item_order_number := approversTable2In(tempIndex).item_order_number;
        approversTable2Out(tempIndex).sub_list_order_number := approversTable2In(tempIndex).sub_list_order_number;
        approversTable2Out(tempIndex).action_type_order_number := approversTable2In(tempIndex).action_type_order_number;
        approversTable2Out(tempIndex).group_or_chain_order_number := approversTable2In(tempIndex).group_or_chain_order_number;
        approversTable2Out(tempIndex).member_order_number := approversTable2In(tempIndex).member_order_number;
        approversTable2Out(tempIndex).approver_order_number := approversTable2In(tempIndex).approver_order_number;
        tempIndex := approversTable2In.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyApproversTable2',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          approversTable2Out.delete;
          raise;
    end copyApproversTable2;
  procedure copyCharList(charListIn in charList,
                         charListOut out nocopy charList) as
    tempIndex integer;
    begin
      tempIndex := charListIn.first;
      while (tempIndex is not null) loop
        charListOut(tempIndex) := charListIn(tempIndex);
        tempIndex := charListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyCharList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          charListOut.delete;
          raise;
    end copyCharList;
  procedure copyIdList(idListIn in idList,
                       idListOut out nocopy idList) as
    tempIndex integer;
    begin
      tempIndex := idListIn.first;
      while (tempIndex is not null) loop
        idListOut(tempIndex) := idListIn(tempIndex);
        tempIndex := idListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyIdList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          idListOut.delete;
          raise;
    end copyIdList;
  procedure copyLongStringList(longStringListIn in longStringList,
                               longStringListOut out nocopy longStringList) as
    tempIndex integer;
    begin
      tempIndex := longStringListIn.first;
      while (tempIndex is not null) loop
        longStringListOut(tempIndex) := longStringListIn(tempIndex);
        tempIndex := longStringListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyLongStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          longStringListOut.delete;
          raise;
    end copyLongStringList;
  procedure copyStringList(stringListIn in stringList,
                           stringListOut out nocopy stringList) as
    tempIndex integer;
    begin
      tempIndex := stringListIn.first;
      while (tempIndex is not null) loop
        stringListOut(tempIndex) := stringListIn(tempIndex);
        tempIndex := stringListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'copyStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          stringListOut.delete;
          raise;
    end copyStringList;
  procedure deserializeLongStringList(longStringListIn in varchar2,
                                      longStringListOut out nocopy longStringList) as
    currentRecordEnd integer;
    currentRecordStart integer;
    inputLength integer;
    tempIndex integer;
    recordDelimiter varchar2(1);
    begin
      recordDelimiter := ame_util.recordDelimiter;
      tempIndex := 0;
      currentRecordEnd := 0;
      inputLength := lengthb(longStringListIn);
      loop
        /* Find the next record or exit. */
        if(currentRecordEnd = inputLength) then
          exit;
        end if;
        currentRecordStart := currentRecordEnd + 1;
        currentRecordEnd := instrb(longStringListIn, recordDelimiter, currentRecordStart, 1);
        tempIndex := tempIndex + 1;
        longStringListOut(tempIndex) :=
          substrb(longStringListIn, currentRecordStart, currentRecordEnd - currentRecordStart);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'deserializeLongStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          longStringListOut := emptyLongStringList;
          raise;
    end deserializeLongStringList;
  procedure getAllowedAppIds(applicationIdsOut out nocopy ame_util.stringList,
                             applicationNamesOut out nocopy ame_util.stringList) as
    cursor callingAppCursor is
      select
        application_id,
        application_name
      from ame_calling_apps
      where
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_name;
    cursor securedAttributesCursor(userId in integer) is
      select
        ak_web_user_sec_attr_values.number_value,
        ame_calling_apps.application_name
      from ak_web_user_sec_attr_values,
           ame_calling_apps
        where ak_web_user_sec_attr_values.number_value = ame_calling_apps.application_id and
          web_user_id = userId and
          sysdate between ame_calling_apps.start_date and
                 nvl(ame_calling_apps.end_date - ame_util.oneSecond, sysdate)
      order by application_name;
    tempIndex integer;
    badRespException exception;
    noRespoTransException exception;
    noTransactionTypeException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    highestResponsibility integer;
    securedAttributeList icx_sec.g_num_tbl_type;
    responsibilityCount integer;
    responsibilityList icx_sec.g_responsibility_list;
    userId fnd_user.user_id%type;
    begin
      highestResponsibility := getHighestResponsibility;
      userId := fnd_global.user_id;
      tempIndex := 1;
      if highestResponsibility = ame_util.noResponsibility then
        applicationIdsOut := ame_util.emptyStringList;
        applicationNamesOut := ame_util.emptyStringList;
      elsif highestResponsibility = ame_util.limBusResponsibility then
          for securedAttributes in securedAttributesCursor(userId => userId)  loop
          /* The explicit conversion below lets nocopy work. */
          applicationIdsOut(tempIndex) := to_char(securedAttributes.number_value);
          applicationNamesOut(tempIndex) := securedAttributes.application_name;
          tempIndex := tempIndex + 1;
        end loop;
        if tempIndex = 1 then
          raise noRespoTransException;
        end if;
      elsif
        (highestResponsibility = ame_util.genBusResponsibility or
         highestResponsibility = ame_util.appAdminResponsibility or
         highestResponsibility = ame_util.developerResponsibility) then
          for tempApp in callingAppCursor loop
           /* The explicit conversion below lets nocopy work. */
           applicationIdsOut(tempIndex) := to_char(tempApp.application_id);
           applicationNamesOut(tempIndex) := tempApp.application_name;
           tempIndex := tempIndex + 1;
          end loop;
        if tempIndex = 1 then
          raise noTransactionTypeException;
        end if;
      else
        raise badRespException;
      end if;
      exception
        when noRespoTransException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400133_UIN_NO_APPL_ACC');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getAllowedAppIds',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when noTransactionTypeException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400321_UIN_NO_TRANS_TYPE');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getAllowedAppIds',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badRespException then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400223_UTL_UNREC_ERROR');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getAllowedAppIds',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getAllowedAppIds',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          applicationIdsOut := emptyStringList;
          applicationNamesOut := emptyStringList;
          raise;
    end getAllowedAppIds;
  procedure getApplicationList(applicationListOut out nocopy idStringTable) as
    cursor callingAppCursor is
      select
        application_id,
        application_name
      from ame_calling_apps
      where
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_name;
      tempIndex integer;
    begin
      tempIndex := 1;
      for tempApp in callingAppCursor loop
        applicationListOut(tempIndex).id := tempApp.application_id;
        applicationListOut(tempIndex).string := tempApp.application_name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getApplicationList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          applicationListOut := emptyIdStringTable;
          raise;
    end getApplicationList;
  procedure getApplicationList2(applicationIdListOut out nocopy stringList,
                                applicationNameListOut out nocopy stringList) as
    cursor callingAppCursor is
      select
        application_id,
        application_name
      from ame_calling_apps
      where
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_name;
      tempIndex integer;
    begin
      tempIndex := 1;
      for tempApp in callingAppCursor loop
        /* The explicit conversion below lets nocopy work. */
        applicationIdListOut(tempIndex) := to_char(tempApp.application_id);
        applicationNameListOut(tempIndex) := tempApp.application_name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getApplicationList2',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          applicationIdListOut := emptyStringList;
          applicationNameListOut := emptyStringList;
          raise;
    end getApplicationList2;
  procedure getApplicationList3(applicationIdIn in integer,
                                applicationIdListOut out nocopy stringList,
                                applicationNameListOut out nocopy stringList) as
    cursor callingAppCursor(applicationIdIn in integer) is
      select
        application_id,
        application_name
      from ame_calling_apps
      where
       application_id <> applicationIdIn and
       sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_name;
      tempIndex integer;
    begin
      tempIndex := 1;
      for tempApp in callingAppCursor(applicationIdIn => applicationIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        applicationIdListOut(tempIndex) := to_char(tempApp.application_id);
        applicationNameListOut(tempIndex) := tempApp.application_name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getApplicationList3',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          applicationIdListOut := emptyStringList;
          applicationNameListOut := emptyStringList;
          raise;
    end getApplicationList3;
  procedure getConversionTypes(conversionTypesOut out nocopy ame_util.stringList) as
    cursor conversionTypeCursor is
      select distinct conversion_type
        from gl_daily_conversion_types;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempType in conversionTypeCursor loop
        conversionTypesOut(tempIndex) := tempType.conversion_type;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getConversionTypes',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          conversionTypesOut := emptyStringList;
          raise;
    end getConversionTypes;
  procedure getCurrencyCodes(currencyCodesOut out nocopy ame_util.stringList) as
    cursor codeCursor is
      select currency_code
        from fnd_currencies_active_v;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempCurrencyCode in codeCursor loop
        currencyCodesOut(tempIndex) := tempCurrencyCode.currency_code;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getCurrencyCodes',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          currencyCodesOut := emptyStringList;
          raise;
    end getCurrencyCodes;
  procedure getCurrencies(currencyCodesOut out nocopy ame_util.stringList,
                          currencyNamesOut out nocopy ame_util.stringList) as
    cursor currencyCursor is
      select
        name,
        currency_code
        from
          fnd_currencies_active_v
        order by currency_code;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempCurrency in currencyCursor loop
        currencyCodesOut(tempIndex) := tempCurrency.currency_code;
        currencyNamesOut(tempIndex) :=
          tempCurrency.currency_code ||
          ' (' || tempCurrency.name || ')';
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getCurrencies',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          currencyCodesOut := emptyStringList;
          currencyCodesOut := ame_util.emptyStringList;
          currencyNamesOut := ame_util.emptyStringList;
          raise;
    end getCurrencies;
  procedure getFndApplicationId(applicationIdIn in integer,
                                fndApplicationIdOut out nocopy integer,
                                transactionTypeIdOut out nocopy varchar2) as
    begin
      select
        fnd_application_id,
        transaction_type_id
        into
          fndApplicationIdOut,
          transactionTypeIdOut
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          /* Don't use tempEffectiveRuleDate here. */
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getFndApplicationId',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          fndApplicationIdOut := null;
          transactionTypeIdOut := null;
          raise;
    end getFndApplicationId;
  procedure getWorkflowAttributeValues(applicationIdIn in integer,
                                       transactionIdIn in varchar2,
                                       workflowItemKeyOut out nocopy varchar2,
                                       workflowItemTypeOut out nocopy varchar2) as
    attributeName ame_attributes.name%type;
    dynamicQuery varchar2(4000);
    errorCode integer;
    errorMessage longestStringType;
    workflowItemKeyAttId integer;
    workflowItemTypeAttId integer;
    begin
      /* Fetch the Workflow item key. */
      attributeName := workflowItemKeyAttribute;
      workflowItemKeyAttId := ame_attribute_pkg.getIdByName(attributeNameIn => ame_util.workflowItemKeyAttribute);
      dynamicQuery := ame_attribute_pkg.getQueryString(attributeIdIn => workflowItemKeyAttId,
                                                       applicationIdIn => applicationIdIn);
      if(ame_attribute_pkg.getStaticUsage(attributeIdIn => workflowItemKeyAttId,
                                          applicationIdIn => applicationIdIn) = ame_util.booleanTrue) then
        workflowItemKeyOut := dynamicQuery;
      else
        if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder) = 0) then /* The bind variable is not present. */
          execute immediate dynamicQuery into workflowItemKeyOut;
        else /* The bind variable is present. */
          execute immediate dynamicQuery into workflowItemKeyOut using in transactionIdIn;
        end if;
      end if;
      /* Fetch the Workflow item type. */
      attributeName := workflowItemTypeAttribute;
      workflowItemTypeAttId := ame_attribute_pkg.getIdByName(attributeNameIn => ame_util.workflowItemTypeAttribute);
      dynamicQuery := ame_attribute_pkg.getQueryString(attributeIdIn => workflowItemTypeAttId,
                                                       applicationIdIn => applicationIdIn);
      if(ame_attribute_pkg.getStaticUsage(attributeIdIn => workflowItemTypeAttId,
                                          applicationIdIn => applicationIdIn) = ame_util.booleanTrue) then
        workflowItemTypeOut := dynamicQuery;
      else
        if(instrb(dynamicQuery, ame_util.transactionIdPlaceholder) = 0) then /* The bind variable is not present. */
          execute immediate dynamicQuery into workflowItemTypeOut;
        else /* The bind variable is present. */
          execute immediate dynamicQuery into workflowItemTypeOut using in transactionIdIn;
        end if;
      end if;
      exception
        when others then
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400224_UTL_INV_ATT_QRY_STG',
            tokenNameOneIn    => 'ATTRIBUTE',
            tokenValueOneIn   => attributeName,
            tokenNameTwoIn    => 'SQLCODE',
            tokenValueTwoIn   => sqlcode,
            tokenNameThreeIn  => 'SQLERRM',
            tokenValueThreeIn => sqlerrm);
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'getWorkflowAttributeValues',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          workflowItemKeyOut := null;
          workflowItemTypeOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
    end getWorkflowAttributeValues;
  procedure identArrToIdList(identArrIn in owa_util.ident_arr,
                             startIndexIn in integer default 2,
                             idListOut out nocopy idList) as
    identArrLimit integer;
      begin
          identArrLimit := identArrIn.last;
          for tempIndex in startIndexIn .. identArrLimit loop
              idListOut(tempIndex - startIndexIn + 1) := to_number(identArrIn(tempIndex));
          end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'identArrToIdList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
      end identArrToIdList;
  procedure identArrToLongestStringList(identArrIn in owa_util.ident_arr,
                                        startIndexIn in integer default 2,
                                        longestStringListOut out nocopy longestStringList) as
    identArrLimit integer;
      begin
          identArrLimit := identArrIn.last;
          for tempIndex in startIndexIn .. identArrLimit loop
              longestStringListOut(tempIndex - startIndexIn + 1) := identArrIn(tempIndex);
          end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'identArrToLongestStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
      end identArrToLongestStringList;
  procedure identArrToStringList(identArrIn in owa_util.ident_arr,
                                 startIndexIn in integer default 2,
                                 stringListOut out nocopy stringList) as
    identArrLimit integer;
      begin
          identArrLimit := identArrIn.last;
          for tempIndex in startIndexIn .. identArrLimit loop
              stringListOut(tempIndex - startIndexIn + 1) := identArrIn(tempIndex);
          end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'identArrToStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
      end identArrToStringList;
  procedure idListToStringList(idListIn in idList,
                               stringListOut out nocopy stringList) as
    tempIndex integer;
    tempIndex2 integer;
    begin
      tempIndex := idListIn.first;
      tempIndex2 := 0;
      loop
        if(tempIndex is null) then
          exit;
        end if;
        tempIndex2 := tempIndex2 + 1;
        stringListOut(tempIndex2) := to_char(idListIn(tempIndex));
        tempIndex := idListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'idListToStringList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end idListToStringList;
   procedure insTable2ToInsTable(insertionsTable2In in ame_util.insertionsTable2,
                                 insertionsTableOut out nocopy ame_util.insertionsTable) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
       tempInteger1 integer;
       tempInteger2 integer;
       tempIndex integer;
       insertionTargetActionId ame_util.StringType;
       insertionTargetApprover ame_util.longStringType;
       insertionTargetGrpChainId ame_util.longStringType;
       insertionTargetItemClass ame_util.StringType;
       insertionTargetItemId ame_util.StringType;
       insertionTargetOccurrence ame_util.StringType;
       tempOrigSystem ame_util.stringType;
       apprName ame_util.longStringType;
       unchgParam ame_util.longStringType;
       wrongOrigSystem exception;
       wrongItemClass exception;
     begin
       for i in 1..insertionsTable2In.count loop
         if insertionsTable2In(i).item_class <> ame_util.headerItemClassName then
           raise wrongItemClass;
         end if;
         insertionsTableOut(i).order_type := insertionsTable2In(i).order_type ;
         insertionsTableOut(i).api_insertion := insertionsTable2In(i).api_insertion ;
         insertionsTableOut(i).authority := insertionsTable2In(i).authority ;
         insertionsTableOut(i).description := insertionsTable2In(i).description ;
         if (insertionsTableOut(i).order_type = ame_util.absoluteOrder) then
           /* The parameter is unchanged */
           insertionsTableOut(i).parameter := insertionsTable2In(i).parameter ;
         elsif (insertionsTableOut(i).order_type in (ame_util.afterApprover,ame_util.beforeApprover)) then
           /* The in parameter has the format :
                   approvers(positionIn - 1).name || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_class || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).action_type_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).group_or_chain_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).occurrence;
              the out parameter has the format :
                   {ame_util.approverUserId,ame_util.approverPersonId} || ':' ||
                   {approverList(positionIn - 1).user_id, approverList(positionIn - 1).person_id}
                   ':' || approverList(positionIn - 1).approval_type_id || ':' ||
                   approverList(positionIn - 1).group_or_chain_id || ':' ||
                   approverList(positionIn - 1).occurrence; */
           tempInteger1 := instrb(insertionsTable2In(i).parameter,ame_util.fieldDelimiter,  1);
           insertionTargetApprover := substrb(insertionsTable2In(i).parameter, 1, tempInteger1 - 1);
           tempInteger1 := tempInteger1 + 1;
           tempInteger2 := instrb(insertionsTable2In(i).parameter, ame_util.fieldDelimiter, tempInteger1);
           insertionTargetItemClass := substrb(insertionsTable2In(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTable2In(i).parameter, ame_util.fieldDelimiter, tempInteger1);
           insertionTargetItemId := substrb(insertionsTable2In(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTable2In(i).parameter, ame_util.fieldDelimiter, tempInteger1);
           insertionTargetActionId := substrb(insertionsTable2In(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTable2In(i).parameter, ame_util.fieldDelimiter, tempInteger1);
           insertionTargetGrpChainId := substrb(insertionsTable2In(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTable2In(i).parameter, ame_util.fieldDelimiter, tempInteger1);
           insertionTargetOccurrence := substrb(insertionsTable2In(i).parameter, tempInteger1);
           ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn => insertionTargetApprover,
                                                            origSystemOut => tempOrigSystem,
                                                            origSystemIdOut => tempIndex);
           if tempOrigSystem = ame_util.perOrigSystem then
             tempOrigSystem := ame_util.approverPersonId ;
           elsif tempOrigSystem = ame_util.fndUserOrigSystem then
             tempOrigSystem := ame_util.approverUserId;
           else
             raise wrongOrigSystem;
           end if;
           insertionsTableOut(i).parameter := tempOrigSystem || ':' ||  tempIndex || ':' ||
                         insertionTargetActionId || ':' || insertionTargetGrpChainId || ':' ||
                         insertionTargetOccurrence ;
         elsif (insertionsTableOut(i).order_type = ame_util.firstPreApprover) then
           /* the out parameter has the format :
                           ame_util.firstPreApprover
           */
           insertionsTableOut(i).parameter := ame_util.firstPreApprover;
         elsif (insertionsTableOut(i).order_type = ame_util.lastPreApprover) then
           /* the out parameter has the format :
                           ame_util.lastPreApprover
           */
           insertionsTableOut(i).parameter := ame_util.lastPreApprover;
         elsif (insertionsTableOut(i).order_type = ame_util.firstPostApprover) then
           /* the out parameter has the format :
                           ame_util.firstPostApprover
           */
           insertionsTableOut(i).parameter := ame_util.firstPostApprover;
         elsif (insertionsTableOut(i).order_type = ame_util.lastPostApprover) then
           /* the out parameter has the format :
                           ame_util.lastPostApprover
           */
           insertionsTableOut(i).parameter := ame_util.lastPostApprover;
         elsif (insertionsTableOut(i).order_type = ame_util.firstAuthority) then
           /* the out parameter has the format :
                           ame_util.firstAuthority
           */
           insertionsTableOut(i).parameter := ame_util.firstAuthority;
         end if;
       end loop;
    exception
      when wrongOrigSystem then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'insTable2ToInsTable',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when wrongItemClass then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                            messageNameIn => 'AME_400417_APPR_NOT_HEADER_IC');
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'insTable2ToInsTable',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'insTable2ToInsTable',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         raise;
     end insTable2ToInsTable;
   procedure insTableToInsTable2(insertionsTableIn in ame_util.insertionsTable,
                                 transactionIdIn in varchar2,
                                 insertionsTable2Out out nocopy ame_util.insertionsTable2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
       tempInteger1 integer;
       tempInteger2 integer;
       tempIndex integer;
       insertionTargetActionId ame_util.StringType;
       insertionTargetApprover ame_util.longStringType;
       insertionTargetGrpChainId ame_util.longStringType;
       insertionTargetItemClass ame_util.StringType;
       insertionTargetItemId ame_util.StringType;
       insertionTargetOccurrence ame_util.StringType;
       tempOrigSystem ame_util.stringType;
       apprName ame_util.longStringType;
       wrongOrigSystem exception;
     begin
       for i in 1..insertionsTableIn.count loop
         insertionsTable2Out(i).item_class := ame_util.headerItemClassName ;
         insertionsTable2Out(i).item_id := transactionIdIn ;
         insertionsTable2Out(i).order_type := insertionsTableIn(i).order_type ;
         insertionsTable2Out(i).api_insertion := insertionsTableIn(i).api_insertion ;
         insertionsTable2Out(i).authority := insertionsTableIn(i).authority ;
         insertionsTable2Out(i).description := insertionsTableIn(i).description ;
         insertionsTable2Out(i).action_type_id := ame_util.nullInsertionActionTypeId ;
         insertionsTable2Out(i).group_or_chain_id := ame_util.nullInsertionGroupOrChainId ;
         if (insertionsTable2Out(i).order_type = ame_util.absoluteOrder) then
           /* The parameter is unchanged */
           insertionsTable2Out(i).parameter := insertionsTableIn(i).parameter ;
         elsif (insertionsTable2Out(i).order_type in (ame_util.afterApprover,ame_util.beforeApprover)) then
           /* The in parameter has the format :
                   {ame_util.approverUserId,ame_util.approverPersonId} || ':' ||
                   {approverList(positionIn - 1).user_id, approverList(positionIn - 1).person_id}
                   ':' || approverList(positionIn - 1).approval_type_id || ':' ||
                   approverList(positionIn - 1).group_or_chain_id || ':' ||
                   approverList(positionIn - 1).occurrence;
              the out parameter has the format :
                   approvers(positionIn - 1).name || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_class || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).action_type_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).group_or_chain_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).occurrence;
           */
           tempInteger1 := instrb(insertionsTableIn(i).parameter, ':', 1, 1);
           insertionTargetApprover := substrb(insertionsTableIn(i).parameter, 1, tempInteger1 - 1);
           tempInteger1 := tempInteger1 + 1;
           tempInteger2 := instrb(insertionsTableIn(i).parameter, ':', tempInteger1, 1);
           tempIndex := to_number(substrb(insertionsTableIn(i).parameter, tempInteger1, tempInteger2 - tempInteger1));
           if insertionTargetApprover = ame_util.approverPersonId then
             tempOrigSystem := ame_util.perOrigSystem;
           elsif insertionTargetApprover = ame_util.approverUserId then
             tempOrigSystem := ame_util.fndUserOrigSystem;
           else
             raise wrongOrigSystem;
           end if;
           apprName:= ame_approver_type_pkg.getWfRolesName(origSystemIn => tempOrigSystem,
                                                           origSystemIdIn=>tempIndex);
           insertionTargetItemClass := ame_util.headerItemClassName;
           insertionTargetItemId := transactionIdIn;
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTableIn(i).parameter, ':', tempInteger1, 1);
           insertionTargetActionId := substrb(insertionsTableIn(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTableIn(i).parameter, ':', tempInteger1, 1);
           insertionTargetGrpChainId := substrb(insertionsTableIn(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(insertionsTableIn(i).parameter, ':', tempInteger1, 1);
           insertionTargetOccurrence := substrb(insertionsTableIn(i).parameter, tempInteger1, tempInteger2 - tempInteger1);
           insertionsTable2Out(i).parameter := apprName || ame_util.fieldDelimiter || insertionTargetItemClass||
                           ame_util.fieldDelimiter ||insertionTargetItemId||
                           ame_util.fieldDelimiter ||insertionTargetActionId ||
                           ame_util.fieldDelimiter || insertionTargetGrpChainId ||
                           ame_util.fieldDelimiter||insertionTargetOccurrence;
           insertionsTable2Out(i).action_type_id := insertionTargetActionId;
           insertionsTable2Out(i).group_or_chain_id := insertionTargetGrpChainId;
         elsif (insertionsTable2Out(i).order_type = ame_util.firstPreApprover) then
           /* the in parameter has the format :
                           ame_util.firstPreApprover
              the out format is:
                           ame_util.firstPreApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionsTable2Out(i).parameter := ame_util.firstPreApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionsTable2Out(i).order_type = ame_util.lastPreApprover) then
           /* the in parameter has the format :
                           ame_util.lastPreApprover
              the out format is:
                           ame_util.lastPreApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionsTable2Out(i).parameter := ame_util.lastPreApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionsTable2Out(i).order_type = ame_util.firstPostApprover) then
           /* the in parameter has the format :
                           ame_util.firstPostApprover
              the out format is:
                           ame_util.firstPostApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionsTable2Out(i).parameter := ame_util.firstPostApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionsTable2Out(i).order_type = ame_util.lastPostApprover) then
           /* the in parameter has the format :
                           ame_util.lastPostApprover
              the out format is:
                           ame_util.lastPostApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionsTable2Out(i).parameter := ame_util.lastPostApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionsTable2Out(i).order_type = ame_util.firstAuthority) then
           /* the in parameter has the format :
                           ame_util.firstAuthority
              the out format is:
                           ame_util.firstAuthority ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionsTable2Out(i).parameter := ame_util.firstAuthority ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         end if;
       end loop;
    exception
      when wrongOrigSystem then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'insTableToInsTable2',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'insTableToInsTable2',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         raise;
     end insTableToInsTable2;
  procedure makeEven(numberInOut in out nocopy integer) as
    begin
      if(not isAnEvenNumber(numberIn => numberInOut)) then
        numberInOut := numberInOut + 1;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'makeEven',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end makeEven;
  procedure makeOdd(numberInOut in out nocopy integer) as
    begin
      if(isAnEvenNumber(numberIn => numberInOut)) then
        numberInOut := numberInOut + 1;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'makeOdd',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end makeOdd;
  procedure nonautonomousLog(logIdIn number,
                             packageNameIn in varchar2,
                             routineNameIn in varchar2,
                             exceptionNumberIn in integer,
                             exceptionStringIn in varchar2,
                             transactionIdIn in varchar2 default null,
                             applicationIdIn in integer default null) as
    begin
        insert into ame_exceptions_log(
          log_id,
          package_name,
          routine_name,
          transaction_id,
          application_id,
          exception_number,
          exception_string) values(
            logIdIn,
            substrb(packageNameIn, 1, 50),
            substrb(routineNameIn, 1, 50),
            transactionIdIn,
            applicationIdIn,
            exceptionNumberIn,
            substrb(to_char(sysdate, 'YYYY:MM:DD:HH24:MI:SS')||exceptionStringIn, 1, 4000));
        commit;
      exception
        when others then
          rollback;
          raise;
    end nonautonomousLog;
   procedure ordRecordToInsRecord2(orderRecordIn in ame_util.orderRecord,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord,
                                 insertionRecord2Out out nocopy ame_util.insertionRecord2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
       tempInteger1 integer;
       tempInteger2 integer;
       tempIndex integer;
       insertionTargetActionId ame_util.StringType;
       insertionTargetApprover ame_util.longStringType;
       insertionTargetGrpChainId ame_util.longStringType;
       insertionTargetItemClass ame_util.StringType;
       insertionTargetItemId ame_util.StringType;
       insertionTargetOccurrence ame_util.StringType;
       tempOrigSystem ame_util.stringType;
       apprName ame_util.longStringType;
       wrongOrigSystem exception;
     begin
         insertionRecord2Out.item_class := ame_util.headerItemClassName ;
         insertionRecord2Out.item_id := transactionIdIn ;
         insertionRecord2Out.order_type := orderRecordIn.order_type ;
         insertionRecord2Out.api_insertion := approverIn.api_insertion ;
         insertionRecord2Out.authority := approverIn.authority ;
         insertionRecord2Out.description := orderRecordIn.description ;
         insertionRecord2Out.action_type_id := ame_util.nullInsertionActionTypeId ;
         insertionRecord2Out.group_or_chain_id := ame_util.nullInsertionGroupOrChainId ;
         if (insertionRecord2Out.order_type = ame_util.absoluteOrder) then
           /* The parameter is unchanged */
           insertionRecord2Out.parameter := orderRecordIn.parameter ;
         elsif (insertionRecord2Out.order_type in (ame_util.afterApprover,ame_util.beforeApprover)) then
           /* The in parameter has the format :
                   {ame_util.approverUserId,ame_util.approverPersonId} || ':' ||
                   {approverList(positionIn - 1).user_id, approverList(positionIn - 1).person_id}
                   ':' || approverList(positionIn - 1).approval_type_id || ':' ||
                   approverList(positionIn - 1).group_or_chain_id || ':' ||
                   approverList(positionIn - 1).occurrence;
              the out parameter has the format :
                   approvers(positionIn - 1).name || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_class || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).item_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).action_type_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).group_or_chain_id || ame_util.fieldDelimiter ||
                   approvers(positionIn - 1).occurrence;
           */
           tempInteger1 := instrb(orderRecordIn.parameter, ':', 1, 1);
           insertionTargetApprover := substrb(orderRecordIn.parameter, 1, tempInteger1 - 1);
           tempInteger1 := tempInteger1 + 1;
           tempInteger2 := instrb(orderRecordIn.parameter, ':', tempInteger1, 1);
           tempIndex := to_number(substrb(orderRecordIn.parameter, tempInteger1, tempInteger2 - tempInteger1));
           if insertionTargetApprover = ame_util.approverPersonId then
             tempOrigSystem := ame_util.perOrigSystem;
           elsif insertionTargetApprover = ame_util.approverUserId then
             tempOrigSystem := ame_util.fndUserOrigSystem;
           else
             raise wrongOrigSystem;
           end if;
           apprName:= ame_approver_type_pkg.getWfRolesName(origSystemIn => tempOrigSystem,
                                                           origSystemIdIn=>tempIndex);
           insertionTargetItemClass := ame_util.headerItemClassName;
           insertionTargetItemId := transactionIdIn;
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(orderRecordIn.parameter, ':', tempInteger1, 1);
           insertionTargetActionId := substrb(orderRecordIn.parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           tempInteger2 := instrb(orderRecordIn.parameter, ':', tempInteger1, 1);
           insertionTargetGrpChainId := substrb(orderRecordIn.parameter, tempInteger1, tempInteger2 - tempInteger1);
           tempInteger1 := tempInteger2 + 1;
           insertionTargetOccurrence := substrb(orderRecordIn.parameter, tempInteger1);
           insertionRecord2Out.parameter := apprName || ame_util.fieldDelimiter || insertionTargetItemClass||
                           ame_util.fieldDelimiter ||insertionTargetItemId||
                           ame_util.fieldDelimiter ||insertionTargetActionId ||
                           ame_util.fieldDelimiter || insertionTargetGrpChainId ||
                           ame_util.fieldDelimiter||insertionTargetOccurrence;
           insertionRecord2Out.action_type_id := insertionTargetActionId;
           insertionRecord2Out.group_or_chain_id := insertionTargetGrpChainId;
         elsif (insertionRecord2Out.order_type = ame_util.firstPreApprover) then
           /* the in parameter has the format :
                           ame_util.firstPreApprover
              the out format is:
                           ame_util.firstPreApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionRecord2Out.parameter := ame_util.firstPreApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionRecord2Out.order_type = ame_util.lastPreApprover) then
           /* the in parameter has the format :
                           ame_util.lastPreApprover
              the out format is:
                           ame_util.lastPreApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionRecord2Out.parameter := ame_util.lastPreApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionRecord2Out.order_type = ame_util.firstPostApprover) then
           /* the in parameter has the format :
                           ame_util.firstPostApprover
              the out format is:
                           ame_util.firstPostApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionRecord2Out.parameter := ame_util.firstPostApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionRecord2Out.order_type = ame_util.lastPostApprover) then
           /* the in parameter has the format :
                           ame_util.lastPostApprover
              the out format is:
                           ame_util.lastPostApprover ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionRecord2Out.parameter := ame_util.lastPostApprover ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         elsif (insertionRecord2Out.order_type = ame_util.firstAuthority) then
           /* the in parameter has the format :
                           ame_util.firstAuthority
              the out format is:
                           ame_util.firstAuthority ||
                           ame_util.fieldDelimiter ||
                           ame_util.headerItemClassName ||
                           ame_util.fieldDelimiter ||
                           transactionIdIn;
           */
           insertionRecord2Out.parameter := ame_util.firstAuthority ||
                                               ame_util.fieldDelimiter ||
                                               ame_util.headerItemClassName ||
                                               ame_util.fieldDelimiter ||
                                               transactionIdIn;
         end if;
    exception
      when wrongOrigSystem then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
        ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'ordRecordToInsRecord2',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                            routineNameIn => 'ordRecordToInsRecord2',
                            exceptionNumberIn => sqlcode,
                            exceptionStringIn => sqlerrm);
         raise;
     end ordRecordToInsRecord2;
  procedure parseSourceValue(sourceValueIn in varchar2,
                             sourceDescriptionOut out nocopy varchar2,
                             ruleIdListOut out nocopy ame_util.idList) as
    ruleIdIndex integer;
    sourceValueInLength integer;
    tempFieldDelimiterLocation integer;
    tempLength integer;
    tempRuleIdLocation integer;
    sourceSubstring ame_util.stringType;
    begin
      sourceValueInLength := lengthb(sourceValueIn);
      /* Handle the null case first (even though the null case should not typically arise). */
      if(sourceValueInLength is null or sourceValueInLength = 0) then
        return;
      end if;
      /* Now handle the non-null case. */
      tempFieldDelimiterLocation := instrb(sourceValueIn, fieldDelimiter, 1, 1);
      if(tempFieldDelimiterLocation = 0) then
        tempLength := sourceValueInLength;
      else
        tempLength := tempFieldDelimiterLocation - 1;
      end if;
      sourceSubstring := substrb(sourceValueIn, 1, tempLength);
      if(sourceSubstring in (approveAndForwardInsertion,
                             forwardInsertion,
                             specialForwardInsertion)) then
        sourceDescriptionOut := forwardeeSource;
      elsif(sourceSubstring = surrogateInsertion) then
        sourceDescriptionOut := surrogateSource;
      elsif(sourceSubstring = otherInsertion) then
        sourceDescriptionOut := inserteeSource;
      elsif(sourceSubstring = apiSuppression) then
        sourceDescriptionOut := suppressionSource;
      else /* rule-ID list */
        sourceDescriptionOut := ruleGeneratedSource;
        /* Parse sourceValueIn as a rule-ID list. */
        tempRuleIdLocation := 1;
        ruleIdIndex := 1; /* post-increment */
        loop
          tempFieldDelimiterLocation := instrb(sourceValueIn, fieldDelimiter, tempRuleIdLocation);
          if(tempFieldDelimiterLocation = 0) then
            tempFieldDelimiterLocation := sourceValueInLength + 1;
          end if;
          ruleIdListOut(ruleIdIndex) := to_number(substrb(sourceValueIn,
                                                          tempRuleIdLocation,
                                                          tempFieldDelimiterLocation - tempRuleIdLocation));
          if(tempFieldDelimiterLocation > sourceValueInLength) then
            exit;
          end if;
          ruleIdIndex := ruleIdIndex + 1;
          tempRuleIdLocation := tempFieldDelimiterLocation + 1;
        end loop;
      end if;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_util',
                                    routineNameIn => 'parseSourceValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end parseSourceValue;
    procedure parseStaticCurAttValue(applicationIdIn in integer,
                                     attributeIdIn in integer,
                                     attributeValueIn in varchar2,
                                     localErrorIn in boolean,
                                     amountOut out nocopy varchar2,
                                     currencyOut out nocopy varchar2,
                                     conversionTypeOut out nocopy varchar2) as
    attributeName ame_attributes.name%type;
    badStaticCurUsageException exception;
    comma1Location integer;
    comma2Location integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    transactionType ame_calling_apps.application_name%type;
    begin
      /*
        Static currency usages must be null or look like this:  '5000.00,USD,Corporate'
        or '666,66,USD,Daily'.  The amount can be formatted per the currency's requirements;
        this procedure looks for the last two commas in the string, and assumes that they
        are the parse points.
      */
      if(attributeValueIn is null) then
        amountOut := null;
        currencyOut := null;
        conversionTypeOut := null;
        return;
      end if;
      comma1Location := instrb(attributeValueIn, ',', -1, 2);
      comma2Location := instrb(attributeValueIn, ',', -1, 1);
      if(comma1Location = 0 or
         comma2Location = 0 or
         comma1Location < 2 or
         comma2Location < 4) then
        attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeIdIn);
        raise badStaticCurUsageException;
      end if;
      amountOut := substrb(attributeValueIn, 1, comma1Location - 1);
      currencyOut := substrb(attributeValueIn, comma1Location + 1, comma2Location - comma1Location - 1);
      conversionTypeOut := substrb(attributeValueIn, comma2Location + 1, lengthb(attributeValueIn) - comma2Location);
      exception
        when badStaticCurUsageException then
          transactionType := ame_admin_pkg.getApplicationName(applicationIdIn => applicationIdIn);
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn     => 'AME_400127_ENG_BAD_ST_USG',
            tokenNameOneIn    => 'TRANSACTION_TYPE',
            tokenValueOneIn   => transactionType,
            tokenNameTwoIn    => 'ATTRIBUTE',
            tokenValueTwoIn   => attributeName);
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'parseStaticCurAttValue',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'parseStaticCurAttValue',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end parseStaticCurAttValue;
  procedure purgeOldTempData as
    cursor transactionTypeCursor is
      select application_id
      from ame_calling_apps
      where
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
    cursor attributeUsageCursor (applicationIdIn integer) is
      select attribute_id
      from ame_attribute_usages
      where
        application_id = applicationIdIn and
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
    applicationId  integer;
    attributeId    integer;
    lastDateToSave date;
    errbuf varchar2(4000);
    retcode number;
    transactionId ame_temp_transactions.transaction_id%type;
    begin
      for tempTransType in transactionTypeCursor loop
        applicationId := tempTransType.application_id;
          -- Make a call the ame_trans_data_purge.purgeTransdata
          --
          ame_trans_data_purge.purgeTransData(errbuf              => errbuf,
                           retcode             => retcode,
                           applicationIdIn => applicationId,
                           purgeTypeIn => 'A');
      end loop;
    end purgeOldTempData;
  procedure purgeOldTempData2(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2) as
    begin
      purgeOldTempData;
      retcode := 0;
      errbuf := null;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'purgeOldTempData2',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          retcode := 2;
          errbuf := sqlerrm;
          raise;
    end purgeOldTempData2;
  procedure purgeOldTransLocks(errbuf out nocopy varchar2,
                               retcode out nocopy varchar2) as
    begin
      delete from ame_temp_trans_locks
        where row_timestamp < sysdate - 1/24;
      commit;
      retcode := 0;
      errbuf := null;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'purgeOldTransLocks',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          retcode := 2;
          errbuf := sqlerrm;
          raise;
    end purgeOldTransLocks;
  procedure runtimeException(packageNameIn in varchar2,
                             routineNameIn in varchar2,
                             exceptionNumberIn in integer,
                             exceptionStringIn in varchar2) as
    applicationId integer;
    distributedEnvironment ame_config_vars.variable_value%type;
    localError boolean;
    logId integer;
    transactionId ame_temp_transactions.transaction_id%type;
    useWorkflow boolean;
    begin
      begin
        /*
          This block avoids infinite looping.  See bug 2219719.
        */
        applicationId := ame_engine.getAmeApplicationId;
        transactionId := ame_engine.getTransactionId;
        localError := ame_engine.isLocalTransaction;
        exception
          when others then
            applicationId := null;
            transactionId := null;
            localError := true;
      end;
      distributedEnvironment := getConfigVar(variableNameIn => ame_util.distEnvConfigVar);
      useWorkflow := ame_util.useWorkflow(transactionIdIn => transactionId,
                                          applicationIdIn => applicationId);
      select ame_exceptions_log_s.nextval into logId from dual;
      /*
        Log the following exceptions locally:
        1.  Local (pseudo-runtime, test) transactions (from the test tab).
        2.  Transactions not using Workflow.
        3.  Transactions not in a distributed environment.
      */
      if(localError or
         distributedEnvironment <> ame_util.yes or
         not useWorkflow) then
        if(distributedEnvironment = ame_util.yes) then
          /* commit, but not in an autonomous transaction */
          nonautonomousLog(logIdIn => logId,
                           packageNameIn => packageNameIn,
                           routineNameIn => routineNameIn,
                           exceptionNumberIn => exceptionNumberIn,
                           exceptionStringIn => exceptionStringIn,
                           transactionIdIn => transactionId,
                           applicationIdIn => applicationId);
        else
          /* commit in an autonomous transaction */
          autonomousLog(logIdIn => logId,
                        packageNameIn => packageNameIn,
                        routineNameIn => routineNameIn,
                        exceptionNumberIn => exceptionNumberIn,
                        exceptionStringIn => exceptionStringIn,
                        transactionIdIn => transactionId,
                        applicationIdIn => applicationId);
        end if;
      end if;
      /* Log genuine runtime exceptions in Workflow when using Workflow. */
      if(not localError and
         useWorkflow) then
        /*
          The wf_item_activity_statuses_v.error_name and error_message columns store the exception.
          The query against that view is per item type, which should be the
          ame_calling_aps.transaction_type_id, and per item key, which should be the transaction ID
          in the OAM schema and code.  So all we need is the package name, routine name, and log ID,
          which will let us order the call stack in our admin UI.  The call to wf_core.context
          puts the package name in upper case to make the query against wf_item_activity_statuses_v
          easier (comparing 'AME%' without having to uppercase anything in the query).
        */
        wf_core.context(pkg_name => upper(packageNameIn),
                        proc_name => routineNameIn,
                        arg1 => logId);
      end if;
      exception
        when others then
          if(localError) then
            rollback;
          end if;
          raise;
    end runtimeException;
  procedure serializeApprovers(approverNamesIn in ame_util.longStringList,
                               approverDescriptionsIn in ame_util.longStringList,
                               maxOutputLengthIn in integer,
                               approverNamesOut out nocopy varchar2,
                               approverDescriptionsOut out nocopy varchar2) as
    errorCode             varchar2(10);
    errorMessage          ame_util.longestStringType;
    upperLimit integer;
    recordDelimiter varchar2(1);
    begin
      recordDelimiter := ame_util.recordDelimiter;
      upperLimit := approverNamesIn.count;
      if(upperLimit = 0) then
        raise ame_util.zeroApproversException;
      end if;
      approverNamesOut := '';
      approverDescriptionsOut := '';
      for i in 1 .. upperLimit loop
        approverNamesOut := approverNamesOut || approverNamesIn(i) || recordDelimiter;
        approverDescriptionsOut:=
          approverDescriptionsOut || approverDescriptionsIn(i) || recordDelimiter;
      end loop;
      if((length(approverNamesOut) > maxOutputLengthIn) or
        (length(approverDescriptionsOut) > maxOutputLengthIn)) then
        raise ame_util.tooManyApproversException;
      end if;
      exception
        when ame_util.tooManyApproversException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400111_UIN_MANY_ROWS');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'serializeApprovers',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode, errorMessage);
        when ame_util.zeroApproversException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400110_UIN_NO_CURR_EMP');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'serializeApprovers',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode, errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'serializeApprovers',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise;
    end serializeApprovers;
  procedure setConfigVar(variableNameIn  in varchar2,
                         variableValueIn in varchar2,
                         applicationIdIn in integer default null) as
   currentUserId         integer;
   description           ame_config_vars.description%type;
   errorCode             varchar2(10);
   errorMessage          ame_util.longestStringType;
   found                 varchar2(1);
   invalidDayException   exception;
   nullVariableValue     exception;
   variableNameTooLong   exception;
   variableValueTooLong  exception;
   begin
     if(variableNameIn = 'purgeFrequency' or
       variableNameIn = 'currencyConversionWindow') then
       if(instrb(variableValueIn, ',') <> 0 or
         instrb(variableValueIn, '.') <> 0 or
         (variableValueIn <= 0)) then
         raise invalidDayException;
       end if;
     end if;
     if(variableValueIn is null) then
       raise nullVariableValue;
     end if;
     select description
       into description
       from ame_config_vars
       where variable_name = variableNameIn and
             (application_id is null or application_id = 0) and
             end_date is null;
     currentUserId := ame_util.getCurrentUserId;
      if (ame_util.isArgumentTooLong(tableNameIn  => 'ame_config_vars',
                                    columnNameIn => 'variable_name',
                                    argumentIn   => variableNameIn)) then
         raise variableNameTooLong;
      end if;
      if (ame_util.isArgumentTooLong(tableNameIn  => 'ame_config_vars',
                                   columnNameIn => 'variable_value',
                                   argumentIn   => variableValueIn)) then
         raise variableValueTooLong;
      end if;
      update ame_config_vars
        set
          last_updated_by = currentUserId,
          last_update_date = sysdate,
          last_update_login = currentUserId,
          end_date = sysdate
        where variable_name = variableNameIn and
          ((applicationIdIn is null and (application_id is null or application_id = 0)) or
           application_id = applicationIdIn) and
           sysdate between start_date and
                     nvl(end_date - (ame_util.oneSecond), sysdate);
      insert into ame_config_vars(variable_name,
                                  variable_value,
                                  description,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  start_date,
                                  application_id)
        values(variableNameIn,
               variableValueIn,
               description,
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               applicationIdIn);
      commit;
      exception
        when invalidDayException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400225_UTL_CFGVAR_POS_INT');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setConfigVar',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when nullVariableValue then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400409_MUST_ENT_CFGVAR_VAL');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setConfigVar',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when variableNameTooLong then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400296_UTL_VAN_LONG');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setConfigVar',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when variableValueTooLong then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400226_UTL_VAR_LONG');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setConfigVar',
                           exceptionNumberIn => errorCode,
                           exceptionStringIn => errorMessage);
          raise_application_error(errorCode, errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setConfigVar',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end setConfigVar;
/*
AME_STRIPING
  procedure setCurrentStripeSetId(applicationIdIn in integer,
                                  stripeSetIdIn in integer) as
    begin
       owa_util.mime_header('text/html',
                            false);
       owa_cookie.send(name => ame_util.getStripeSetCookieName(applicationIdIn => applicationIdIn),
                       value => to_char(stripeSetIdIn),
                       expires => sysdate + 365);
       owa_util.http_header_close;
       exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setCurrentStripeSetId',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end setCurrentStripeSetId;
*/
  procedure setTransTypeCookie(applicationIdIn in integer) as
    userId integer;
    begin
       userId := ame_util.getCurrentUserId;
       owa_util.mime_header('text/html',
                            false);
       owa_cookie.send(name => ame_util.transactionTypeCookie || ':' || userId,
                       value => applicationIdIn,
                       expires => sysdate + (10 * 365),
                       path => ame_util.getPlsqlDadPath,
                       domain => substrb(ame_util.getServerName, 8));
       owa_util.http_header_close;
       exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'setTransTypeCookie',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end setTransTypeCookie;
  procedure sortIdListInPlace(idListInOut in out nocopy idList) as
    tempId integer;
    upperLimit integer;
    begin
      for i in 2 .. idListInOut.count loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(idListInOut(i) < idListInOut(j)) then
            tempId := idListInOut(i);
            idListInOut(i) := idListInOut(j);
            idListInOut(j) := tempId;
          end if;
        end loop;
      end loop;
    exception
      when others then
        runtimeException(packageNameIn => 'ame_util',
                         routineNameIn => 'sortIdListInPlace',
                         exceptionNumberIn => sqlcode,
                         exceptionStringIn => sqlerrm);
          raise;
    end sortIdListInPlace;
  procedure sortLongStringListInPlace(longStringListInOut in out nocopy longStringList) as
    tempLongStringType ame_util.longStringType;
    upperLimit integer;
    begin
      for i in 2 .. longStringListInOut.count loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(longStringListInOut(i) < longStringListInOut(j)) then
            tempLongStringType := longStringListInOut(i);
            longStringListInOut(i) := longStringListInOut(j);
            longStringListInOut(j) := tempLongStringType;
          end if;
        end loop;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'sortLongStringListInPlace',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end sortLongStringListInPlace;
  procedure sortLongestStringListInPlace(longestStringListInOut in out nocopy longestStringList) as
    tempLongestStringType ame_util.longestStringType;
    upperLimit integer;
    begin
      for i in 2 .. longestStringListInOut.count loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(longestStringListInOut(i) < longestStringListInOut(j)) then
            tempLongestStringType := longestStringListInOut(i);
            longestStringListInOut(i) := longestStringListInOut(j);
            longestStringListInOut(j) := tempLongestStringType;
          end if;
        end loop;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'sortLongestStringListInPlace',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end sortLongestStringListInPlace;
  procedure sortStringListInPlace(stringListInOut in out nocopy stringList) as
    tempStringType integer;
    upperLimit integer;
    begin
      for i in 2 .. stringListInOut.count loop
        upperLimit := i - 1;
        for j in 1 .. upperLimit loop
          if(stringListInOut(i) < stringListInOut(j)) then
            tempStringType := stringListInOut(i);
            stringListInOut(i) := stringListInOut(j);
            stringListInOut(j) := tempStringType;
          end if;
        end loop;
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'sortStringListInPlace',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end sortStringListInPlace;
  procedure stringListToIdList(stringListIn in stringList,
                               idListOut out nocopy idList) as
    tempIndex integer;
    tempIndex2 integer;
    begin
      tempIndex := stringListIn.first;
      tempIndex2 := 0;
      loop
        if(tempIndex is null) then
          exit;
        end if;
        tempIndex2 := tempIndex2 + 1;
        idListOut(tempIndex2) := to_number(stringListIn(tempIndex));
        tempIndex := stringListIn.next(tempIndex);
      end loop;
      exception
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'stringListToIdList',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end stringListToIdList;
  procedure substituteStrings(stringIn in varchar2,
                              targetStringsIn in ame_util.stringList,
                              substitutionStringsIn in ame_util.stringList,
                              stringOut out nocopy varchar2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    listMismatchException exception;
    upperLimit integer;
    begin
      upperLimit := targetStringsIn.count;
      if(upperLimit <> substitutionStringsIn.count) then
        raise listMismatchException;
      end if;
      stringOut := stringIn;
      for i in 1 .. upperLimit loop
        stringOut := replace(stringOut, targetStringsIn(i), substitutionStringsIn(i));
      end loop;
      exception
        when listMismatchException then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400227_UTL_INP_STG_SIZE');
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'substituteStrings',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          runtimeException(packageNameIn => 'ame_util',
                           routineNameIn => 'substituteStrings',
                           exceptionNumberIn => sqlcode,
                           exceptionStringIn => sqlerrm);
          raise;
    end substituteStrings;
end ame_util;

/
