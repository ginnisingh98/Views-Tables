--------------------------------------------------------
--  DDL for Package Body AME_CONDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONDITION_PKG" as
/* $Header: ameocond.pkb 120.4 2006/12/26 13:19:15 avarri noship $ */
  function getAttributeId(conditionIdIn in integer) return integer as
    attributeId integer;
    begin
      select attribute_id
        into attributeId
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
      return(attributeId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeId;
  function getAttributeName(conditionIdIn in integer) return varchar2 as
    attributeName ame_attributes.name%type;
    begin
      select ame_attributes.name
        into attributeName
        from
          ame_attributes,
          ame_conditions
        where
          ame_conditions.condition_id = conditionIdIn and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
      return(attributeName);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributeName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeName;
  function getAttributeType(conditionIdIn in integer) return varchar2 as
    attributeType ame_attributes.attribute_type%type;
    begin
      select attribute_type
        into attributeType
        from
          ame_attributes,
          ame_conditions
        where
          ame_conditions.condition_id = conditionIdIn and
          ame_attributes.attribute_id = ame_conditions.attribute_id and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
      return(attributeType);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributeType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeType;
  function getConditionType(conditionIdIn in integer) return varchar2 as
    conditionType ame_conditions.condition_type%type;
    begin
      select condition_type
        into conditionType
        from
          ame_conditions
        where
          ame_conditions.condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
      return(conditionType);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getConditionType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getConditionType;
function getConditionKey(conditionIdIn in integer,
                         processingDateIn in date default null) return varchar2 as
    conditionKey ame_conditions.condition_key%type;
    begin
      if processingDateIn is null then
        select condition_key
          into conditionKey
          from ame_conditions
          where
               condition_id = conditionIdIn and
            ((sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate)) or
             (sysdate < start_date and
               start_date < nvl(end_date,start_date +ame_util.oneSecond)));
      else
        select condition_key
          into conditionKey
          from ame_conditions
          where
               condition_id = conditionIdIn and
            (processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn)) ;
      end if;
      return(conditionKey);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                    routineNamein => 'getConditionKey',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getConditionKey;
  function conditionKeyExists(conditionKeyIn in varchar2) return boolean as
    conditionCount integer;
    begin
      select count(*)
      into conditionCount
      from ame_conditions
      where upper(condition_key) = upper(conditionKeyIn) and
        rownum < 2;
      if conditionCount > 0 then
        return(true);
      else
        return(false);
      end if;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                  routineNamein => 'conditionKeyExists',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(condition Key ' ||
                                                         conditionKeyIn ||
                                                        ') ' ||
                                                         sqlerrm);
        raise;
        return(true);
    end conditionKeyExists;
  function getNextConditionKey return varchar2 as
    cursor get_dbid_cursor is
      select to_char(db.dbid)
      from   v$database db, v$instance instance
      where  upper(db.name) = upper(instance.instance_name);
      databaseId varchar2(50);
      newConditionKey ame_conditions.condition_key%type;
      newConditionKey1 ame_conditions.condition_key%type;
      conditionKeyId number;
      seededKeyPrefix varchar2(4);
    begin
      open get_dbid_cursor;
      fetch get_dbid_cursor
      into databaseId;
      if get_dbid_cursor%notfound then
        -- This case will never happen, since every instance must be linked to a DB
        databaseId := NULL;
      end if;
      close get_dbid_cursor;
      if (ame_util.getHighestResponsibility = ame_util.developerResponsibility) then
         seededKeyPrefix := ame_util.seededKeyPrefix;
      else
         seededKeyPrefix := null;
      end if;
      loop
        select ame_condition_keys_s.nextval into conditionKeyId from dual;
        newConditionKey := databaseId||':'||conditionKeyId;
        if seededKeyPrefix is not null then
          newConditionKey1 := seededKeyPrefix||'-' || newConditionKey;
        else
          newConditionKey1 := newConditionKey;
        end if;
        if not conditionKeyExists(newConditionKey1) then
          exit;
        end if;
      end loop;
      return(newConditionKey);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                  routineNamein => 'getNextConditionKey',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(condition Key ' ||
                                                        newConditionKey ||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getNextConditionKey;
  function getDescription(conditionIdIn in integer) return varchar2 as
    cursor stringValueCursor(conditionIdIn in integer) is
      select string_value
        from ame_string_values
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by string_value;
    description varchar2(500);
    approverDescription ame_util.longStringType;
    approverName ame_conditions.parameter_two%type;
    approverType ame_conditions.parameter_one%type;
    approverTypeId ame_attributes.approver_type_id%type;
    attributeId ame_attributes.attribute_id%type;
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    conditionType ame_conditions.condition_type%type;
    includeLowerLimit ame_conditions.include_lower_limit%type;
    includeUpperLimit ame_conditions.include_upper_limit%type;
    lastName per_all_people_f.last_name%type;
    lineItem ame_attributes.line_item%type;
    lineItemLabel varchar2(15);
    origSystem wf_roles.orig_system%type;
    parameterOne ame_conditions.parameter_one%type;
    parameterOneDateString varchar2(500);
    parameterOneNumberString varchar2(500);
    parameterTwo ame_conditions.parameter_two%type;
    parameterTwoDateString varchar2(500);
    parameterTwoNumberString varchar2(500);
    parameterThree ame_conditions.parameter_three%type;
    tempIndex integer;
    tempValue ame_string_values.string_value%type;
    wfRolesName wf_roles.name%type;
    begin
      conditionType := getConditionType(conditionIdIn => conditionIdIn);
      if(conditionType = ame_util.listModConditionType) then
        approverType :=
          ame_condition_pkg.getParameterOne(conditionIdIn => conditionIdIn);
        approverName :=
          ame_condition_pkg.getParameterTwo(conditionIdIn => conditionIdIn);
        approverDescription :=
          ame_approver_type_pkg.getApproverDescription(nameIn => approverName);
        if(approverType = ame_util.finalApprover) then
          return(ame_util.getLabel(ame_util.perFndAppId,'AME_FINAL_APPROVER_IS') ||' '|| approverDescription);
        else
          return(ame_util.getLabel(ame_util.perFndAppId,'AME_ANY_APPROVER_IS') ||' '|| approverDescription);
        end if;
      end if;
      attributeId := getAttributeId(conditionIdIn => conditionIdIn);
      approverTypeId := ame_attribute_pkg.getApproverTypeId(attributeIdIn => attributeId);
      lineItem := ame_attribute_pkg.getLineItem(attributeIdIn => attributeId);
      if lineItem = ame_util.booleanTrue then
        lineItemLabel := ame_util.getLabel(ame_util.perFndAppId,'AME_LINE_ITEM_COLON');
      end if;
      attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeId);
      attributeType := getAttributeType(conditionIdIn => conditionIdIn);
      if(attributeType = ame_util.booleanAttributeType) then
        select parameter_one
         into parameterOne
         from ame_conditions
         where
           condition_id = conditionIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
       description := lineItemLabel||attributeName || ame_util.getLabel(ame_util.perFndAppId,'AME_IS') || ' ' ||parameterOne;
      elsif(attributeType = ame_util.stringAttributeType) then
       description := lineItemLabel||attributeName || ame_util.getLabel(ame_util.perFndAppId,'AME_IN') ||' {';
       tempIndex := 1;
       for tempStringValue in stringValueCursor(conditionIdIn => conditionIdIn) loop
         tempValue := tempStringValue.string_value;
         if(tempIndex = 4) then
           description := description || ', . . .';
           exit;
         end if;
         if(tempIndex > 1) then
           description := description || ', ';
         end if;
         description := description || substrb(tempValue,1,50);
         tempIndex := tempIndex + 1;
       end loop;
       description := description || '}';
      elsif (attributeType = ame_util.numberAttributeType or
            attributeType = ame_util.dateAttributeType) then
       select
         condition_type,
         parameter_one,
         parameter_two,
         include_lower_limit,
         include_upper_limit
       into
         conditionType,
         parameterOne,
         parameterTwo,
         includeLowerLimit,
         includeUpperLimit
       from
         ame_conditions
       where
         condition_id = conditionIdIn and
         sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
       /* Check if attribute within the condition is associated with an
          approver type. */
       if(approverTypeId is not null) then
         origSystem :=
           ame_approver_type_pkg.getApproverTypeOrigSystem(approverTypeIdIn => approverTypeId);
         wfRolesName :=
             ame_approver_type_pkg.getWfRolesName(origSystemIn => origSystem,
                                                  origSystemIdIn => to_number(parameterTwo),
                                                  raiseNoDataFoundIn => 'false');
         if wfRolesName is null then
           description := attributeName || ' = ' || 'Invalid :' || origSystem || ':' || parameterTwo;
         else
           approverDescription :=
             ame_approver_type_pkg.getApproverDescription(nameIn => wfRolesName);
           if(origSystem = ame_util.perOrigSystem) then
             if(attributeName = ame_util.firstStartingPointAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_FIRST_START_POINT_COLON');
             elsif(attributeName = ame_util.jobLevelStartingPointAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_JOBLVL_NON_DEF_START_POINT');
             elsif(attributeName = ame_util.secondStartingPointAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_SECOND_START_POINT_COLON');
             elsif(attributeName = ame_util.topSupPersonIdAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_TOP_SUPERVISOR_COLON');
             elsif(attributeName = ame_util.transactionRequestorAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_TRANSACTION_REQUESTOR');
             elsif(attributeName = ame_util.supStartingPointAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_SPRV_NON_DEF_START_POINT');
             end if;
             description := attributeName || ' ' || approverDescription;
           elsif(origSystem = ame_util.fndUserOrigSystem) then
            if(attributeName = ame_util.transactionReqUserAttribute) then
               attributeName := ame_util.getLabel(ame_util.perFndAppId,'AME_TRANSACTION_REQUESTOR');
             end if;
             description := attributeName || ' ' || approverDescription;
           elsif(origSystem = ame_util.posOrigSystem) then
             if(attributeName = ame_util.topPositionIdAttribute) then
               attributeName := 'Top position id: '; -- pa boilerplate
             end if;
             description := attributeName || ' ' || approverDescription;
           end if;
         end if;
       else
         if(parameterOne = parameterTwo and
           includeLowerLimit = ame_util.booleanTrue and
           includeUpperLimit = ame_util.booleanTrue) then
           if attributeType = ame_util.dateAttributeType then
             parameterOneDateString := fnd_date.date_to_displayDate(dateVal => ame_util.versionStringToDate(stringDateIn => parameterOne));
             description := lineItemLabel||attributeName|| ' = ' || parameterOneDateString;
           else
             parameterOneNumberString := ame_util.canonNumStringToDisplayString(canonicalNumberStringIn => parameterOne);
             description := lineItemLabel||attributeName|| ' = ' || parameterOneNumberString;
           end if;
         else
           if attributeType = ame_util.dateAttributeType then
             parameterOneDateString := fnd_date.date_to_displayDate(dateVal => ame_util.versionStringToDate(stringDateIn => parameterOne));
             description := lineItemLabel||parameterOneDateString;
           else
             parameterOneNumberString := ame_util.canonNumStringToDisplayString(canonicalNumberStringIn => parameterOne);
             description := lineItemLabel||parameterOneNumberString;
           end if;
          if parameterOne is not null then
           if(includeLowerLimit = ame_util.booleanTrue) then
             description := description || ' <= ';
           else
             description := description || ' < ';
           end if;
          end if;
           description := description || attributeName;
           if parameterTwo is not null then
             if(includeUpperLimit = ame_util.booleanTrue) then
               description := description || ' <= ';
             else
               description := description || ' < ';
             end if;
             if attributeType = ame_util.dateAttributeType then
               parameterTwoDateString := fnd_date.date_to_displayDate(dateVal => ame_util.versionStringToDate(stringDateIn => parameterTwo));
               description := description || parameterTwoDateString;
             else
               parameterTwoNumberString := ame_util.canonNumStringToDisplayString(canonicalNumberStringIn => parameterTwo);
               description := description || parameterTwoNumberString;
             end if;
           end if;
         end if;
       end if;
     else -- currency attribute
       select
         condition_type,
         parameter_one,
         parameter_two,
         parameter_three,
         include_lower_limit,
         include_upper_limit
       into
         conditionType,
         parameterOne,
         parameterTwo,
         parameterThree,
         includeLowerLimit,
         includeUpperLimit
       from
         ame_conditions
       where
         condition_id = conditionIdIn and
         sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
       if(parameterOne = parameterTwo and
          includeLowerLimit = ame_util.booleanTrue and
          includeUpperLimit = ame_util.booleanTrue) then
            description := lineItemLabel||attributeName || ' = ' || parameterOne || ' ' || parameterThree;
       else
         description := lineItemLabel||parameterOne;
        if parameterOne is not null then
         if(includeLowerLimit = ame_util.booleanTrue) then
           description := description||' ' ||parameterThree|| ' <= ';
         else
           description := description||' ' ||parameterThree|| ' < ';
         end if;
        end if;
         description := description || attributeName;
         if parameterTwo is not null then
           if(includeUpperLimit = ame_util.booleanTrue) then
             description := description || ' <= ';
           else
             description := description || ' < ';
           end if;
           description := description || parameterTwo || ' ' || parameterThree;
         end if;
       end if;
     end if;
     if(lengthb(description) > 100) then
       description := substrb(description, 1, 93) || ' . . .}';
     end if;
     return(description);
     exception
       when others then
         rollback;
         ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                   routineNameIn => 'getDescription',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
         raise;
         return(null);
    end getDescription;
  function getIncludeLowerLimit(conditionIdIn in integer) return varchar as
    includeLowerLimit ame_conditions.include_lower_limit%type;
    begin
      select include_lower_limit
        into includeLowerLimit
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(includeLowerLimit);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getIncludeLowerLimit',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getIncludeLowerLimit;
  function getIncludeUpperLimit(conditionIdIn in integer) return varchar as
    includeUpperLimit ame_conditions.include_upper_limit%type;
    begin
      select include_upper_limit
        into includeUpperLimit
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(includeUpperLimit);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getIncludeUpperLimit',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getIncludeUpperLimit;
  function isStringAttributeType(conditionIdIn in integer) return boolean as
    attributeType ame_attributes.attribute_type%type;
    begin
      select attribute_type
        into attributeType
        from
          ame_attributes,
          ame_conditions
        where
          ame_conditions.condition_id = conditionIdIn and
          ame_attributes.attribute_id = ame_conditions.attribute_id and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) ;
      if attributeType = ame_util.stringAttributeType then
        return(true);
      end if;
      return(false);
      exception
        when no_data_found then
          rollback;
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'isStringAttributeType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
    end isStringAttributeType;
  function getParameterOne(conditionIdIn in integer) return varchar as
    parameterOne ame_conditions.parameter_one%type;
    begin
      select parameter_one
        into parameterOne
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameterOne);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getParameterOne',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getParameterOne;
  function getParameterTwo(conditionIdIn in integer) return varchar as
    parameterTwo ame_conditions.parameter_two%type;
    begin
      select parameter_two
        into parameterTwo
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameterTwo);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getParameterTwo',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getParameterTwo;
  function getParameterThree(conditionIdIn in integer) return varchar as
    parameterThree ame_conditions.parameter_three%type;
    begin
      select parameter_three
        into parameterThree
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameterThree);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getParameterThree',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getParameterThree;
  function getStartDate(conditionIdIn in integer) return date as
    startDate date;
    begin
      select start_date
        into startDate
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(startDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getStartDate;
  function getType(conditionIdIn in integer) return varchar2 as
    conditionType ame_conditions.condition_type%type;
    begin
      select condition_type
        into conditionType
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(conditionType);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getType;
  function getVersionStartDate(conditionIdin integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getVersionStartDate;
  function isConditionUsage(ruleIdIn in integer,
                            conditionIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from
          ame_condition_usages
        where
          condition_id = conditionIdIn and
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < start_date and
            start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'isConditionUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isConditionUsage;
  function isInUseByOtherApps(conditionIdIn in integer,
                              applicationIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from
          ame_rule_usages,
          ame_condition_usages
        where
          ame_rule_usages.rule_id = ame_condition_usages.rule_id and
          ame_rule_usages.item_id <> applicationIdIn and
          ame_condition_usages.condition_id = conditionIdIn and
          ((sysdate between ame_rule_usages.start_date and
            nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_rule_usages.start_date and
            ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
              ame_rule_usages.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
              ame_condition_usages.start_date + ame_util.oneSecond))) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'isInUseByOtherApps',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isInUseByOtherApps;
  function isInUse(conditionIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_condition_usages
        where
          condition_id = conditionIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < start_date and
            start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'isInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isInUse;
   function lineItemIsInUse(applicationIdIn in integer,
                            conditionTypeIn in varchar2) return boolean as
    lineItemCount integer;
    begin
      select count(*)
        into lineItemCount
        from
              ame_attribute_usages,
              ame_attributes,
              ame_conditions
        where
              ame_attributes.attribute_id = ame_conditions.attribute_id and
              ame_conditions.condition_type = conditionTypeIn and
              ame_attributes.line_item = ame_util.booleanTrue and
              ame_attribute_usages.attribute_id = ame_attributes.attribute_id and
              ame_attribute_usages.application_id = applicationIdIn and
              ((sysdate between ame_attribute_usages.start_date and
            nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_attribute_usages.start_date and
            ame_attribute_usages.start_date < nvl(ame_attribute_usages.end_date,
                 ame_attribute_usages.start_date + ame_util.oneSecond)))  and
              sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
              sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) ;
      if(lineItemCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'lineItemIsInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end lineItemIsInUse;
  function new(typeIn in varchar2,
               attributeIdIn in integer,
               conditionKeyIn in varchar2,
               attributeTypeIn in varchar2 default null,
               parameterOneIn in varchar2 default null,
               parameterTwoIn in varchar2 default null,
               parameterThreeIn in varchar2 default null,
               includeLowerLimitIn in varchar2 default null,
               includeUpperLimitIn in varchar2 default null,
               stringValueListIn in ame_util.longestStringList default ame_util.emptyLongestStringList,
               newStartDateIn in date default null,
               conditionIdIn in integer default null,
               commitIn in boolean default true,
               processingDateIn in date default null) return integer as
    cursor conditionCursor(attributeIdIn in integer) is
      select condition_id
        from ame_conditions
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
    attributeType ame_attributes.attribute_type%type;
    conditionCount integer;
    conditionExistsException exception;
    conditionId integer;
    condKeyLengthException exception;
    createdBy integer;
    currencyNumberException exception;
    currencyNumberException1 exception;
    currentUserId integer;
    dateException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidConditionException exception;
    parameterOneLengthException exception;
    parameterTwoLengthException exception;
    parameterThreeLengthException exception;
    lowerlimitLengthException exception;
    stringCount integer;
    stringValueList ame_util.longestStringList;
    tempCount integer;
    tempCount2 integer;
    tempIndex integer;
    tempStringValueList ame_util.longestStringList;
    upperLimit integer;
    upperlimitLengthException exception;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(typeIn = ame_util.listModConditionType) then
        attributeType := null;
      elsif(attributeTypeIn is null) then
        attributeType := ame_attribute_pkg.getType(attributeIdIn => attributeIdIn);
      else
        attributeType := attributeTypeIn;
      end if;
      if(lengthb(conditionKeyIn) > 100) then
        raise condKeyLengthException;
      end if;
      if(attributeType = ame_util.dateAttributeType) then
        if ame_util.versionStringToDate(stringDateIn => parameterOneIn)
           > ame_util.versionStringToDate(stringDateIn => parameterTwoIn) then
          raise dateException;
        end if;
      elsif(attributeType = ame_util.currencyAttributeType or
            attributeType = ame_util.numberAttributeType) then
        if(ame_attribute_pkg.getApproverTypeId(attributeIdIn => attributeIdIn)) is null then
          if(to_number(parameterOneIn) > to_number(parameterTwoIn)) then
             raise currencyNumberException;
          end if;
          if(to_number(parameterOneIn) = to_number(parameterTwoIn) and
            (includeLowerLimitIn = ame_util.booleanFalse or
             includeUpperLimitIn = ame_util.booleanFalse)) then
            raise currencyNumberException1;
          end if;
        end if;
      end if;
      if(attributeType = ame_util.stringAttributeType) then
        stringValueList := stringValueListIn; /* necessary for in/out parameter below */
        stringCount := stringValueList.count;
        for i in 1 .. stringCount loop
          if(instrb(stringValueList(i), ',') > 0) then
            raise invalidConditionException;
          end if;
        end loop;
        ame_util.sortLongestStringListInPlace(longestStringListInOut => stringValueList);
        for tempCondition in conditionCursor(attributeIdIn => attributeIdIn) loop
          getStringValueList(conditionIdIn => tempCondition.condition_id,
                             stringValueListOut => tempStringValueList);
          if(ame_util.longestStringListsMatch(longestStringList1InOut => stringValueList,
                                              longestStringList2InOut => tempStringValueList)) then
            raise conditionExistsException;
          end if;
        end loop;
      else
        select count(*)
          into tempCount
          from ame_conditions
          where
            condition_type = typeIn and
            attribute_id = attributeIdIn and
            ((parameterOneIn is null and parameter_one is null) or
             upper(parameter_one) = upper(parameterOneIn)) and
            ((parameterTwoIn is null and parameter_two is null) or
             upper(parameter_two) = upper(parameterTwoIn)) and
            ((parameterThreeIn is null and parameter_three is null) or
             upper(parameter_three) = upper(parameterThreeIn)) and
            ((include_lower_limit is null and includeLowerLimitIn is null) or
             upper(include_lower_limit) = upper(includeLowerLimitIn)) and
            ((include_upper_limit is null and includeUpperLimitIn is null) or
             upper(include_upper_limit) = upper(includeUpperLimitIn)) and
            processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          if tempCount > 0 then
            raise conditionExistsException;
          end if;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_conditions',
                                    columnNameIn => 'parameter_one',
                                    argumentIn => parameterOneIn)) then
        raise parameterOneLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_conditions',
                                    columnNameIn => 'parameter_two',
                                    argumentIn => parameterTwoIn)) then
        raise parameterTwoLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_conditions',
                                    columnNameIn => 'parameter_three',
                                    argumentIn => parameterThreeIn)) then
        raise parameterThreeLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_conditions',
                                    columnNameIn => 'include_lower_limit',
                                    argumentIn => includeLowerLimitIn)) then
        raise lowerlimitLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_conditions',
                                    columnNameIn => 'include_upper_limit',
                                    argumentIn => includeUpperLimitIn)) then
        raise upperlimitLengthException;
      end if;
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(conditionIdIn is null) then
        createdBy := currentUserId;
        if (ame_util.getHighestResponsibility = ame_util.developerResponsibility) then
          /* Use negative condition IDs for developer-seeded conditions. */
          select count(*)
            into conditionCount
            from ame_conditions
            where
              processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          if conditionCount = 0 then
            conditionId := -1;
          else
            select min(condition_id) - 1
              into conditionId
              from ame_conditions
              where
                processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate);
            if(conditionId > -1) then
              conditionId := -1;
            end if;
          end if;
        else
          select ame_conditions_s.nextval into conditionId from dual;
        end if;
      else
        conditionId := conditionIdIn;
        select count(*)
          into tempCount2
          from ame_conditions
            where
              condition_id = conditionId and
              created_by = ame_util.seededDataCreatedById;
        if(tempCount2 > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      insert into ame_conditions(condition_id,
                                 condition_key,
                                 condition_type,
                                 attribute_id,
                                 parameter_one,
                                 parameter_two,
                                 parameter_three,
                                 include_lower_limit,
                                 include_upper_limit,
                                 created_by,
                                 creation_date,
                                 last_updated_by,
                                 last_update_date,
                                 last_update_login,
                                 start_date,
                                 end_date)
        values(conditionId,
               conditionKeyIn,
               typeIn,
               attributeIdIn,
               parameterOneIn,
               parameterTwoIn,
               parameterThreeIn,
               includeLowerLimitIn,
               includeUpperLimitIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               nvl(newStartDateIn, processingDate),
               null);
      if(attributeType = ame_util.stringAttributeType) then
        upperLimit := stringValueList.count;
        for i in 1..upperLimit loop
          insert into ame_string_values(condition_id,
                                        string_value,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        start_date,
                                        end_date)
            values(conditionId,
                   stringValueList(i),
                   createdBy,
                   processingDate,
                   currentUserId,
                   processingDate,
                   currentUserId,
                   nvl(newStartDateIn, processingDate),
                   null);
        end loop;
      end if;
      if(commitIn) then
        commit;
      end if;
      return(conditionId);
      exception
      when condKeyLengthException then
        rollback;
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn   => 'AME_400362_COND_KEY_LONG',
          tokenNameOneIn  => 'COLUMN_LENGTH',
          tokenValueOneIn => 100);
        ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
        when invalidConditionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400182_CON_STR_VAL_COMMA');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when conditionExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400183_CON_ALRDY_EXISTS');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterOneLengthException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400184_CON_LWR_LMT_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_conditions',
                                                       columnNameIn => 'parameter_one'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterTwoLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400185_CON_UPP_LMT_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_conditions',
                                                       columnNameIn => 'parameter_two'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterThreeLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400185_CON_UPP_LMT_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_conditions',
                                                   columnNameIn => 'parameter_three'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when lowerlimitLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400184_CON_LWR_LMT_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_conditions',
                                                       columnNameIn => 'include_lower_limit'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when upperlimitLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400185_CON_UPP_LMT_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_conditions',
                                                       columnNameIn => 'include_upper_limit'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when dateException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400186_CON_START_LESS_END');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when currencyNumberException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400187_CON_LWR_LESS_UPP');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when currencyNumberException1 then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400188_CON_LMT_VAL_YES');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end new;
  function newConditionUsage(ruleIdIn in integer,
                             conditionIdIn in integer,
                             processingDateIn in date default null) return boolean as
    createdBy integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    processingDate date;
    tempCount integer;
    usageExistsException exception;
    useCount integer;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      select count(*)
        into useCount
        from ame_condition_usages
        where
          condition_id = conditionIdIn and
          rule_id = ruleIdIn and
          ((sysdate between start_date and
          nvl(end_date - ame_util.oneSecond, sysdate)) or
       (sysdate < start_date and
          start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
      if(useCount > 0) then
        raise usageExistsException;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
       into tempCount
       from ame_condition_usages
         where
           condition_id = conditionIdIn and
           rule_id = ruleIdIn and
           created_by = ame_util.seededDataCreatedById;
      if(tempCount > 0) then
        createdBy := ame_util.seededDataCreatedById;
      else
        createdBy := currentUserId;
      end if;
      insert into ame_condition_usages(rule_id,
                                       condition_id,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       start_date,
                                       end_date)
        values(ruleIdIn,
               conditionIdIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               null);
      commit;
      return(true);
      exception
        when usageExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400189_CON_RULE_USES');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'newConditionUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'newConditionUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                      conditionIdIn||
                                                      ') ' ||
                                                      sqlerrm);
          raise;
          return(true);
    end newConditionUsage;
  function newStringValue(conditionIdIn in integer,
                          valueIn in varchar2,
                          processingDateIn in date default null) return boolean as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    stringValueLengthException exception;
    useCount integer;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      select count(*)
        into useCount
        from ame_string_values
        where
          condition_id = conditionIdIn and
          /* string values are case sensitive */
          string_value = valueIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(useCount > 0) then
        return(false);
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_string_values',
                                    columnNameIn => 'string_value',
                                    argumentIn => valueIn)) then
        raise stringValueLengthException;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      insert into ame_string_values(condition_id,
                                    string_value,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    start_date,
                                    end_date)
        values(conditionIdIn,
               valueIn,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               null);
      commit;
      exception
        when stringValueLengthException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400190_CON_STR_VAL_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn =>  ame_util.getColumnLength(tableNameIn => 'ame_string_values',
                                                        columnNameIn => 'string_value'));
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'newStringValue',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'newStringValue',
                                    exceptionNumberIn => sqlcode,
                                     exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
    end newStringValue;
  procedure change(conditionIdIn in integer,
                   stringValuesIn in ame_util.longestStringList default ame_util.emptyLongestStringList,
                   typeIn in varchar2 default null,
                   attributeIdIn in integer default null,
                   parameterOneIn in varchar2 default null,
                   parameterTwoIn in varchar2 default null,
                   parameterThreeIn in varchar2 default null,
                   includeLowerLimitIn in varchar2 default null,
                   includeUpperLimitIn in varchar2 default null,
                   versionStartDateIn in date,
                   processingDateIn in date default null) as
    cursor conditionCursor(typeIn in varchar2,
                           attributeIdIn in integer,
                           parameterOneIn in varchar2,
                           parameterTwoIn in varchar2,
                           parameterThreeIn in varchar2,
                           includeLowerLimitIn in varchar2,
                           includeUpperLimitIn in varchar2) is
      select condition_id
        from ame_conditions
        where
          attribute_id = attributeIdIn and
          condition_type = typeIn and
          ((parameter_one is null and parameterOneIn is null) or
           (parameter_one = parameterOneIn)) and
          ((parameter_two is null and parameterTwoIn is null) or
           (parameter_two = parameterTwoIn)) and
          ((parameter_three is null and parameterThreeIn is null) or
           (parameter_three = parameterThreeIn)) and
          ((include_lower_limit is null and includeLowerLimitIn is null) or
           (include_lower_limit = includeLowerLimitIn)) and
          ((include_upper_limit is null and includeUpperLimitIn is null) or
           (include_upper_limit = includeUpperLimitIn)) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
    cursor startDateCursor is
      select start_date
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    attributeId integer;
    attributeType ame_attributes.attribute_type%type;
    conditionId integer;
    conditionsExistsException exception;
    conditionKey ame_conditions.condition_key%type;
    conditionType ame_conditions.condition_type%type;
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newStartDate date;
    objectVersionNoDataException exception;
    startDate date;
    stringValueList ame_util.longestStringList;
    tempCount integer;
    tempIndex integer;
    tempStringValue ame_string_values.string_value%type;
    tempStringValueList ame_util.longestStringList;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(typeIn is null) then
          conditionType := getConditionType(conditionIdIn => conditionIdIn);
        else
          conditionType := typeIn;
        end if;
        conditionKey := getConditionKey(conditionIdIn => conditionIdIn);
        select count(*)
          into tempCount
          from ame_conditions
          where
            condition_type = typeIn and
            attribute_id = attributeIdIn and
            ((parameter_one is null and parameterOneIn is null) or
             (parameter_one = parameterOneIn)) and
            ((parameter_two is null and parameterTwoIn is null) or
             (parameter_two = parameterTwoIn)) and
            ((parameter_three is null and parameterThreeIn is null) or
             (parameter_three = parameterThreeIn)) and
            ((include_lower_limit is null and includeLowerLimitIn is null) or
             (include_lower_limit = includeLowerLimitIn)) and
            ((include_upper_limit is null and includeUpperLimitIn is null) or
             (include_upper_limit = includeUpperLimitIn)) and
             sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        if(tempCount > 0) then
          if(conditionType = ame_util.listModConditionType) then
            raise conditionsExistsException;
          else
            attributeType := getAttributeType(conditionIdIn => conditionIdIn);
            if(attributeType = ame_util.stringAttributeType) then
              stringValueList := stringValuesIn;
              ame_util.sortLongestStringListInPlace(longestStringListInOut => stringValueList);
              for tempCondition in conditionCursor(typeIn => typeIn,
                                                   attributeIdIn => attributeIdIn,
                                                   parameterOneIn => parameterOneIn,
                                                   parameterTwoIn => parameterTwoIn,
                                                   parameterThreeIn => parameterThreeIn,
                                                   includeLowerLimitIn => includeLowerLimitIn,
                                                   includeUpperLimitIn => includeUpperLimitIn) loop
                 getStringValueList(conditionIdIn => tempCondition.condition_id,
                                    stringValueListOut => tempStringValueList);
                 if(ame_util.longestStringListsMatch(longestStringList1InOut => stringValueList,
                                                     longestStringList2InOut => tempStringValueList)) then
                   raise conditionsExistsException;
                 end if;
               end loop;
            else
              raise conditionsExistsException;
            end if;
          end if;
        end if;
        if(attributeIdIn is null) then
          attributeId := getAttributeId(conditionIdIn => conditionIdIn);
        else
          attributeId := attributeIdIn;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        if versionStartDateIn = startDate then
          endDate := processingDate ;
          newStartDate := processingDate;
          update ame_conditions
            set
              last_updated_by = currentUserId,
              last_update_date = endDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              condition_id = conditionIdIn and
              sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
          if conditionType <> ame_util.listModConditionType then
            if(attributeType = ame_util.stringAttributeType) then
              delete from ame_string_values where condition_id = conditionIdIn;
            end if;
          end if;
          /* (The new function does a commit.) */
          conditionId := new(typeIn => conditionType,
                             attributeIdIn => attributeId,
                             conditionKeyIn => conditionKey,
                             attributeTypeIn => attributeType,
                             parameterOneIn => parameterOneIn,
                             parameterTwoIn => parameterTwoIn,
                             parameterThreeIn => parameterThreeIn,
                             includeLowerLimitIn => includeLowerLimitIn,
                             includeUpperLimitIn => includeUpperLimitIn,
                             stringValueListIn => stringValuesIn,
                             newStartDateIn => newStartDate,
                             conditionIdIn => conditionIdIn);
        else
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
      close startDateCursor;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when conditionsExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400191_CON_EXISTS_NEW');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end change;
  procedure getAllProperties(conditionIdIn in integer,
                             conditionTypeOut out nocopy varchar2,
                             conditionKeyOut out nocopy varchar2,
                             attributeIdOut out nocopy integer,
                             parameterOneOut out nocopy varchar2,
                             parameterTwoOut out nocopy varchar2,
                             parameterThreeOut out nocopy varchar2,
                             includeLowerLimitOut out nocopy varchar2,
                             includeUpperLimitOut out nocopy varchar2) as
    begin
      select
        condition_type,
        condition_key,
        attribute_id,
        parameter_one,
        parameter_two,
        parameter_three,
        include_lower_limit,
        include_upper_limit
        into
          conditionTypeOut,
          conditionKeyOut,
          attributeIdOut,
          parameterOneOut,
          parameterTwoOut,
          parameterThreeOut,
          includeLowerLimitOut,
          includeUpperLimitOut
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAllProperties',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          conditionTypeOut := null;
          conditionKeyOut := null;
          attributeIdOut := null;
          parameterOneOut := null;
          parameterTwoOut := null;
          parameterThreeOut := null;
          includeLowerLimitOut := null;
          includeUpperLimitOut := null;
          raise;
    end getAllProperties;
  procedure getAuthPreConditions(applicationIdIn in integer,
                                 itemClassIdIn in integer,
                                 conditionIdsOut out nocopy ame_util.stringList,
                                 conditionTypesOut out nocopy ame_util.stringList,
                                 attributeIdsOut out nocopy ame_util.stringList,
                                 attributeNamesOut out nocopy ame_util.stringList,
                                 attributeTypesOut out nocopy ame_util.stringList,
                                 conditionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor conditionCursor(applicationIdIn in integer,
                           itemClassIdIn in integer) is
      select
        ame_conditions.condition_id id,
        ame_conditions.condition_type,
        ame_attributes.attribute_id,
        ame_attributes.name,
        ame_attributes.attribute_type
        from ame_conditions,
             ame_attributes,
             ame_attribute_usages,
             ame_item_class_usages
        where
          ame_attribute_usages.application_id = ame_item_class_usages.application_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_class_usages.item_class_id = itemClassIdIn and
          ame_conditions.attribute_id = ame_attribute_usages.attribute_id and
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attributes.item_class_id = itemClassIdIn and
          ame_conditions.condition_type in (ame_util.ordinaryConditionType,ame_util.exceptionConditionType) and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_conditions.condition_type,
                 ame_attributes.attribute_type,
                 ame_attributes.name;
    tempOutputIndex integer;
    conditionId integer;
    conditionType ame_conditions.condition_type%type;
    attributeId integer;
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    begin
      tempOutputIndex := 1;
      open conditionCursor(applicationIdIn => applicationIdIn,
                           itemClassIdIn => itemClassIdIn);
      loop
        fetch conditionCursor into conditionId,
                                   conditionType,
                                   attributeId,
                                   attributeName,
                                   attributeType;
        exit when conditionCursor%notfound;
        /* The explicit conversions below lets nocopy work. */
        conditionIdsOut(tempOutputIndex) := to_char(conditionId);
        conditionTypesOut(tempOutputIndex) := conditionType;
        attributeIdsOut(tempOutputIndex) := to_char(attributeId);
        attributeNamesOut(tempOutputIndex) := attributeName;
        attributeTypesOut(tempOutputIndex) := attributeType;
        conditionDescriptionsOut(tempOutputIndex) := ame_condition_pkg.getDescription(conditionId);
        tempOutputIndex := tempOutputIndex + 1;
      end loop;
      close conditionCursor;
    exception
      when others then
        if conditionCursor%isopen then
          close conditionCursor;
        end if;
        ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                  routineNameIn => 'getAuthPreConditions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        conditionIdsOut := ame_util.emptyStringList;
        conditionTypesOut := ame_util.emptyStringList;
        attributeIdsOut := ame_util.emptyStringList;
        attributeNamesOut := ame_util.emptyStringList;
        attributeTypesOut := ame_util.emptyStringList;
        conditionDescriptionsOut := ame_util.emptyLongStringList;
        raise;
    end getAuthPreConditions;
  procedure getAttributesConditions(attributeIdsIn in ame_util.idList,
                                    conditionTypeIn in varchar2,
                                    lineItemIn in varchar2 default ame_util.booleanFalse,
                                    conditionIdsOut out nocopy ame_util.stringList,
                                    conditionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor conditionCursor(attributeIdIn in integer,
                           conditionTypeIn in varchar2,
                           lineItemIn in varchar2) is
      select
        condition_id id,
        ame_condition_pkg.getDescription(condition_id) description
        from ame_conditions,
             ame_attributes
        where
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          nvl(ame_attributes.line_item, ame_util.booleanFalse) = lineItemIn and
          ame_attributes.attribute_id = attributeIdIn and
          condition_type = conditionTypeIn and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate)
        order by description;
    tempOutputIndex integer;
    upperLimit integer;
    begin
      upperLimit := attributeIdsIn.count;
      tempOutputIndex := 1;
      for tempInputIndex in 1..upperLimit loop /* ignore first value */
        for tempCondition in conditionCursor(attributeIdIn => attributeIdsIn(tempInputIndex),
                                             conditionTypeIn => conditionTypeIn,
                                             lineItemIn => lineItemIn) loop
          /* The explicit conversion below lets nocopy work. */
          conditionIdsOut(tempOutputIndex) := to_char(tempCondition.id);
          conditionDescriptionsOut(tempOutputIndex) := tempCondition.description;
          tempOutputIndex := tempOutputIndex + 1;
        end loop;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributesConditions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          conditionDescriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getAttributesConditions;
  procedure getAttributesConditions1(attributeIdsIn in ame_util.idList,
                                     conditionTypeIn in varchar2,
                                     itemClassIdIn in integer,
                                     ruleIdIn in integer,
                                     conditionIdsOut out nocopy ame_util.stringList,
                                     conditionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor conditionCursor(attributeIdIn in integer,
                           conditionTypeIn in varchar2,
                           itemClassIdIn in integer) is
      select
        ame_conditions.condition_id id,
        ame_condition_pkg.getDescription(ame_conditions.condition_id) description
        from ame_conditions,
             ame_attributes
        where
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_attributes.attribute_id = attributeIdIn and
          condition_type = conditionTypeIn and
          ame_attributes.item_class_id = itemClassIdIn and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate)
        order by description;
    tempOutputIndex integer;
    upperLimit integer;
    begin
      upperLimit := attributeIdsIn.count;
      tempOutputIndex := 1;
      for tempInputIndex in 1..upperLimit loop /* ignore first value */
        for tempCondition in conditionCursor(attributeIdIn => attributeIdsIn(tempInputIndex),
                                             conditionTypeIn => conditionTypeIn,
                                             itemClassIdIn => itemClassIdIn) loop
          /* The explicit conversion below lets nocopy work. */
          if not isConditionUsage(ruleIdIn => ruleIdIn,
                                  conditionIdIn => tempCondition.Id) then
            conditionIdsOut(tempOutputIndex) := to_char(tempCondition.id);
            conditionDescriptionsOut(tempOutputIndex) := tempCondition.description;
            tempOutputIndex := tempOutputIndex + 1;
          end if;
        end loop;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributesConditions1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          conditionDescriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getAttributesConditions1;
  procedure getAttributesConditions2(attributeIdsIn in ame_util.idList,
                                     conditionTypeIn in varchar2,
                                     itemClassIdIn in integer,
                                     lineItemIn in varchar2 default ame_util.booleanFalse,
                                     conditionIdsOut out nocopy ame_util.stringList,
                                     conditionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor conditionCursor(attributeIdIn in integer,
                           conditionTypeIn in varchar2,
                           lineItemIn in varchar2,
                           itemClassIdIn in integer) is
      select
        condition_id id,
        ame_condition_pkg.getDescription(condition_id) description
        from ame_conditions,
             ame_attributes
        where
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          nvl(ame_attributes.line_item, ame_util.booleanFalse) = lineItemIn and
          ame_attributes.attribute_id = attributeIdIn and
          ame_attributes.item_class_id = itemClassIdIn and
          condition_type = conditionTypeIn and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate)
        order by description;
    tempOutputIndex integer;
    upperLimit integer;
    begin
      upperLimit := attributeIdsIn.count;
      tempOutputIndex := 1;
      for tempInputIndex in 1..upperLimit loop /* ignore first value */
        for tempCondition in conditionCursor(attributeIdIn => attributeIdsIn(tempInputIndex),
                                             conditionTypeIn => conditionTypeIn,
                                             lineItemIn => lineItemIn,
                                             itemClassIdIn => itemClassIdIn) loop
          /* The explicit conversion below lets nocopy work. */
          conditionIdsOut(tempOutputIndex) := to_char(tempCondition.id);
          conditionDescriptionsOut(tempOutputIndex) := tempCondition.description;
          tempOutputIndex := tempOutputIndex + 1;
        end loop;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getAttributesConditions2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          conditionDescriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getAttributesConditions2;
  procedure getApplicationsUsingCondition(conditionIdIn in integer,
                                          applicationIdIn in integer,
                                          applicationNamesOut out nocopy ame_util.stringList) as
    upperLimit integer;
    cursor getApplicationsCursor(conditionIdIn in integer,
                                 applicationIdIn in integer) is
      select distinct ame_calling_apps.application_name
        from
          ame_rules,
          ame_rule_usages,
          ame_calling_apps,
          ame_condition_usages
        where
          ame_rules.rule_id = ame_rule_usages.rule_id and
          ame_rules.rule_id = ame_condition_usages.rule_id and
          ame_rule_usages.item_id = ame_calling_apps.application_id and
          ame_rule_usages.item_id <> applicationIdIn and
          ame_condition_usages.condition_id = conditionIdIn and
          ((sysdate between ame_rules.start_date and
              nvl(ame_rules.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_rules.start_date and
              ame_rules.start_date < nvl(ame_rules.end_date,
                               ame_rules.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_rule_usages.start_date and
                 nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < ame_rule_usages.start_date and
                 ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                     ame_rule_usages.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
              ame_condition_usages.start_date + ame_util.oneSecond))) and
          sysdate between ame_calling_apps.start_date and
               nvl(ame_calling_apps.end_date - ame_util.oneSecond, sysdate)
          order by ame_calling_apps.application_name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for getApplicationsRec in getApplicationsCursor(conditionIdIn => conditionIdIn,
                                                      applicationIdIn => applicationIdIn) loop
        applicationNamesOut(tempIndex) := getApplicationsRec.application_name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getApplicationsUsingCondition',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          applicationNamesOut := ame_util.emptyStringList;
          raise;
    end getApplicationsUsingCondition;
  procedure getDescriptions(conditionIdsIn in ame_util.idList,
                            descriptionsOut out nocopy ame_util.longStringList) as
    upperLimit integer;
    begin
      upperLimit := conditionIdsIn.count;
      for tempIndex in 1..upperLimit loop
        descriptionsOut(tempIndex) := getDescription(conditionIdIn => conditionIdsIn(tempIndex));
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getDescriptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          descriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getDescriptions;
  procedure getDetailUrls(applicationIdIn in integer,
                          conditionIdsIn in ame_util.idList,
                          detailUrlsOut out nocopy ame_util.longStringList) as
    conditionIdCount integer;
    begin
      conditionIdCount := conditionIdsIn.count;
      for i in 1..conditionIdCount loop
        if ame_condition_pkg.getConditionType(conditionIdIn => conditionIdsIn(i)) = ame_util.listModConditionType then
          detailUrlsOut(i) := null;
        else
          if ame_condition_pkg.getAttributeType(conditionIdIn => conditionIdsIn(i)) = ame_util.stringAttributeType then
            detailUrlsOut(i) := (ame_util.getPlsqlDadPath ||
                                 'ame_conditions_ui.getDetails?conditionIdIn=' ||
                                 conditionIdsIn(i) ||
                                 '&applicationIdIn=' ||
                                 applicationIdIn);
          else
            detailUrlsOut(i) := null;
          end if;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                    routineNamein => 'getDetailUrls',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          detailUrlsOut := ame_util.emptyLongStringList;
          raise;
    end getDetailUrls;
  procedure getLMConditions(conditionIdOut out nocopy ame_util.idList,
                            parameterOneOut out nocopy ame_util.stringList,
                            parameterTwoOut out nocopy ame_util.stringList) as
    cursor lMConditionCursor is
      select
        condition_id,
        parameter_one,
        parameter_two
        from ame_conditions
        where
          condition_type = ame_util.listModConditionType and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempLMCondition in lMConditionCursor loop
        conditionIdOut(tempIndex) := tempLMCondition.condition_id;
        parameterOneOut(tempIndex) := tempLMCondition.parameter_one;
        parameterTwoOut(tempIndex) := tempLMCondition.parameter_two;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getLMConditions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdOut := ame_util.emptyIdList;
          parameterOneOut := ame_util.emptyStringList;
          parameterTwoOut := ame_util.emptyStringList;
          raise;
    end getLMConditions;
  procedure getLMDescriptions(conditionIdsOut out nocopy ame_util.stringList,
                              descriptionsOut out nocopy ame_util.longStringList) as
    cursor LMConditionCursor is
    select
      condition_id,
      parameter_one,
      parameter_two
      from
        ame_conditions
      where
        condition_type = ame_util.listModConditionType and
        sysdate between start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    approverDesc   ame_util.longStringType;
    approverValid  boolean;
    begin
      tempIndex := 1;
      for LMConditionRec in LMConditionCursor loop
        ame_approver_type_pkg.getApproverDescAndValidity(
                                     nameIn         => lMConditionRec.parameter_two,
                                     descriptionOut => approverDesc,
                                     validityOut    => approverValid);
        if(approverValid) then
          conditionIdsOut(tempIndex) := to_char(LMConditionRec.condition_id);
          if(LMConditionRec.parameter_one = ame_util.anyApprover) then
            descriptionsOut(tempIndex) :=  (ame_util.getLabel(ame_util.perFndAppId,'AME_ANY_APPROVER_IS') || ' ' || approverDesc);
          else
            descriptionsOut(tempIndex) := (ame_util.getLabel(ame_util.perFndAppId,'AME_FINAL_APPROVER_IS') || ' ' || approverDesc);
          end if;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getLMDescriptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          descriptionsOut := ame_util.emptyLongStringList;
          raise;
      end getLMDescriptions;
  procedure getLMDescriptions2(conditionIdsOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.longStringList) as
    cursor LMConditionCursor is
      select
        ame_conditions.condition_id condition_id,
        ame_conditions.parameter_one parameter_one,
        ame_conditions.parameter_two parameter_two
        from
          ame_conditions
        where
          ame_conditions.condition_type = ame_util.listModConditionType and
          sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
    isApproverValid  boolean;
    tempDescription ame_util.longStringType;
    tempIndex integer;
    begin
      tempIndex := 1;
      for LMConditionRec in LMConditionCursor loop
        ame_approver_type_pkg.getApproverDescAndValidity(
                                     nameIn         => lMConditionRec.parameter_two,
                                     descriptionOut => tempDescription,
                                     validityOut    => isApproverValid);
        if(isApproverValid and
            ame_approver_type_pkg.getApproverOrigSystem(nameIn => LMConditionRec.parameter_two)
          = ame_util.perOrigSystem) then
          conditionIdsOut(tempIndex) := to_char(LMConditionRec.condition_id);
          if(LMConditionRec.parameter_one = ame_util.anyApprover) then
              descriptionsOut(tempIndex) :=  (ame_util.getLabel(ame_util.perFndAppId,'AME_ANY_APPROVER_IS') || ' ' || tempDescription);
          else
              descriptionsOut(tempIndex) := (ame_util.getLabel(ame_util.perFndAppId,'AME_FINAL_APPROVER_IS') || ' ' || tempDescription);
          end if;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getLMDescriptions2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          descriptionsOut := ame_util.emptyLongStringList;
          raise;
  end getLMDescriptions2;
  procedure getLMDescriptions3(lmApproverTypeIn in varchar2,
                               conditionIdsOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.longStringList) as
    cursor LMConditionCursor(lmApproverTypeIn in varchar2) is
      select
        ame_conditions.condition_id condition_id,
        ame_conditions.parameter_two parameter_two
        from
          ame_conditions
        where
          ame_conditions.condition_type = ame_util.listModConditionType and
          ame_conditions.parameter_one = lmApproverTypeIn and
          sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
    isApproverValid  boolean;
    tempDescription ame_util.longStringType;
    tempIndex integer;
    begin
      tempIndex := 1;
      for LMConditionRec in LMConditionCursor(lmApproverTypeIn => lmApproverTypeIn) loop
        ame_approver_type_pkg.getApproverDescAndValidity(
                                     nameIn         => lMConditionRec.parameter_two,
                                     descriptionOut => tempDescription,
                                     validityOut    => isApproverValid);
        if(isApproverValid and
            ame_approver_type_pkg.getApproverOrigSystem(nameIn => LMConditionRec.parameter_two)
          = ame_util.perOrigSystem) then
          conditionIdsOut(tempIndex) := to_char(LMConditionRec.condition_id);
          if(lmApproverTypeIn = ame_util.finalApprover) then
            descriptionsOut(tempIndex) := (ame_util.getLabel(ame_util.perFndAppId,'AME_FINAL_APPROVER_IS') || ' ' || tempDescription);
          else
            descriptionsOut(tempIndex) := (ame_util.getLabel(ame_util.perFndAppId,'AME_ANY_APPROVER_IS') || ' ' || tempDescription);
          end if;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getLMDescriptions3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          conditionIdsOut := ame_util.emptyStringList;
          descriptionsOut := ame_util.emptyLongStringList;
          raise;
  end getLMDescriptions3;
  procedure getStringValueList(conditionIdIn in integer,
                               stringValueListOut out nocopy ame_util.longestStringList) as
    cursor stringValueCursor(conditionIdIn in integer) is
      select string_value
        from ame_string_values
        where condition_id = conditionIdIn and
              sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by string_value asc;
    attributeTypeException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    tempIndex integer;
    begin
      if(getAttributeType(conditionIdIn => conditionIdIn) <> ame_util.stringAttributeType) then
        raise attributeTypeException;
      end if;
      tempIndex := 1;
      for tempStringValue in stringValueCursor(conditionIdIn) loop
        stringValueListOut(tempIndex) := tempStringValue.string_value;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when attributeTypeException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400192_CON_STR_VAL_NOT_DEF');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getStringValueList',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          stringValueListOut := ame_util.emptyLongestStringList;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'getStringValueList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          stringValueListOut := ame_util.emptyLongestStringList;
          raise;
    end getStringValueList;
  procedure remove(conditionIdIn in integer,
                   versionStartDateIn in date,
                   processingDateIn in date default null) as
    cursor startDateCursor is
    select start_date
      from ame_conditions
      where
        condition_id = conditionIdIn and
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
       for update;
    attributeType ame_attributes.attribute_type%type;
    conditionType ame_conditions.condition_type%type;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    objectVersionNoDataException exception;
    startDate date;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(isInUse(conditionIdIn)) then
          raise inUseException;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        conditionType := ame_condition_pkg.getType(conditionIdIn => conditionIdIn);
        if versionStartDateIn = startDate then
          if conditionType <> ame_util.listModConditionType then
            attributeType := ame_condition_pkg.getAttributeType(conditionIdIn => conditionIdIn);
            if(attributeType = ame_util.stringAttributeType) then
              update ame_string_values
                set
                  last_updated_by = currentUserId,
                  last_update_date = processingDate,
                  last_update_login = currentUserId,
                  end_date = processingDate
                where
                  condition_id = conditionIdIn and
                  processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
            end if;
          end if;
          update ame_conditions
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              condition_id = conditionIdIn and
                  processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          commit;
        else
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
      close startDateCursor;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'remove',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'remove',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          when inUseException then
            rollback;
            errorCode := -20001;
            errorMessage :=
              ame_util.getMessage(applicationShortNameIn => 'PER',
              messageNameIn => 'AME_400193_CON_IN USE');
            ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                      routineNameIn => 'remove',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
          when others then
            rollback;
            if(startDateCursor%isOpen) then
              close startDateCursor;
            end if;
            ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                      routineNameIn => 'remove',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
            raise;
      end remove;
  procedure removeConditionUsage(ruleIdIn in integer,
                                 conditionIdIn in integer,
                                 newConditionIdIn in integer default null,
                                 finalizeIn in boolean default true,
                                 processingDateIn in date default null) as
    actionIdList ame_util.idList;
    conditionIdList ame_util.idList;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    processingDate date;
    ruleType ame_rules.rule_type%type;
    tempIndex integer;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      update ame_condition_usages
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          condition_id = conditionIdIn and
          rule_id = ruleIdIn and
          ((processingDate between start_date and
            nvl(end_date - ame_util.oneSecond, processingDate)) or
         (processingDate < start_date and
            start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
      if(newConditionIdIn is not null) then
        /* The list modification condition has been changed.  Check to see if
           changing the condition resulted in a rule duplication. */
        ame_rule_pkg.getConditionIds(ruleIdIn => ruleIdIn,
                                     conditionIdListOut => conditionIdList);
        tempIndex := (conditionIdList.count + 1);
        conditionIdList(tempIndex) := newConditionIdIn;
        ame_rule_pkg.getActionIds(ruleIdIn => ruleIdIn,
                                  actionIdListOut => actionIdList);
        ruleType := ame_rule_pkg.getType(ruleIdIn => ruleIdIn);
        if(ame_rule_pkg.ruleExists(typeIn => ruleType,
                                   conditionIdListIn => conditionIdList,
                                   actionIdListIn => actionIdList)) then
          raise inUseException;
        end if;
      end if;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when inUseException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400212_RUL_PROP_EXISTS');
          ame_util.runtimeException(packageNamein => 'ame_condition_pkg',
                                    routineNamein => 'removeConditionUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'removeConditionUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeConditionUsage;
  procedure removeStringValue(conditionIdIn  in integer,
                              versionStartDateIn in date,
                              stringValueListIn in ame_util.longestStringList,
                              processingDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_conditions
        where
          condition_id = conditionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    attributeId ame_conditions.attribute_id%type;
    conditionId ame_conditions.condition_id%type;
    conditionKey ame_conditions.condition_key%type;
    conditionType ame_conditions.condition_type%type;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    includeLowerLimit ame_conditions.include_lower_limit%type;
    includeUpperLimit ame_conditions.include_upper_limit%type;
    objectVersionNoDataException exception;
    parameterOne ame_conditions.parameter_one%type;
    parameterTwo ame_conditions.parameter_two%type;
    parameterThree ame_conditions.parameter_three%type;
    startDate date;
    stringCount integer;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        if versionStartDateIn = startDate then
          stringCount := stringValueListIn.count;
          for i in 1..stringCount loop
            update ame_string_values
              set
                last_updated_by = currentUserId,
                last_update_date = processingDate,
                last_update_login = currentUserId,
                end_date = processingDate
              where
                condition_id = conditionIdIn and
                string_value = stringValueListIn(i) and
                processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          end loop;
          conditionType := ame_condition_pkg.getType(conditionIdIn => conditionIdIn);
          conditionKey  := ame_condition_pkg.getConditionKey(conditionIdIn => conditionIdIn);
          attributeId := ame_condition_pkg.getAttributeId(conditionIdIn => conditionIdIn);
          parameterOne := ame_condition_pkg.getParameterOne(conditionIdIn => conditionIdIn);
          parameterTwo := ame_condition_pkg.getParameterTwo(conditionIdIn => conditionIdIn);
          parameterThree := ame_condition_pkg.getParameterThree(conditionIdIn => conditionIdIn);
          includeLowerLimit := ame_condition_pkg.getIncludeLowerLimit(conditionIdIn => conditionIdIn);
          includeUpperLimit := ame_condition_pkg.getIncludeUpperLimit(conditionIdIn => conditionIdIn);
          update ame_conditions
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              condition_id = conditionIdIn and
              processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          conditionId := new(conditionIdIn => conditionIdIn,
                             typeIn => conditionType,
                             attributeIdIn => attributeId,
                             conditionKeyIn => conditionKey,
                             parameterOneIn => parameterOne,
                             parameterTwoIn => parameterTwo,
                             parameterThreeIn => parameterThree,
                             includeLowerLimitIn => includeLowerLimit,
                             includeUpperLimitIn => includeUpperLimit);
        else
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
      close startDateCursor;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'removeStringValue',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'removeStringValue',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_condition_pkg',
                                    routineNameIn => 'removeStringValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(condition ID ' ||
                                                        conditionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeStringValue;
end ame_condition_pkg;

/
