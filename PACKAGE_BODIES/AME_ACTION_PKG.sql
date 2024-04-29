--------------------------------------------------------
--  DDL for Package Body AME_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_PKG" as
/* $Header: ameoacti.pkb 120.1.12010000.2 2009/02/26 13:20:34 prasashe ship $ */
  function actionTypeIsInUse(actionTypeIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_actions
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'actionTypeIsInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end actionTypeIsInUse;
  function getActionTypeDescQuery(actionTypeIdIn in integer) return varchar2 as
    descriptionQuery ame_action_types.description_query%type;
    begin
      select description_query
        into descriptionQuery
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(descriptionQuery);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeDescQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeDescQuery;
  function getActionTypeDynamicDesc(actionTypeIdIn in integer) return varchar2 as
    dynamicDescription ame_action_types.dynamic_description%type;
    begin
      select dynamic_description
        into dynamicDescription
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(dynamicDescription);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeDynamicDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeDynamicDesc;
  function getActionTypeIdById(actionIdIn in integer) return integer as
    actionTypeId integer;
    begin
      select action_type_id
        into actionTypeId
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(actionTypeId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeIdById',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeIdById;
  function getActionTypeIdByName(actionTypeNameIn in varchar2) return integer as
    actionTypeId integer;
    begin
      select action_type_id
        into actionTypeId
        from ame_action_types
        where
          upper(name) = upper(actionTypeNameIn) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(actionTypeId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeIdByName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action name ' ||
                                                        actionTypeNameIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeIdByName;
  function getActionTypeDescription(actionTypeIdIn in integer) return varchar2 as
    description ame_action_types.description%type;
    begin
      select description
        into description
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeDescription;
  function getActionTypeMaxOrderNumber(applicationIdIn in integer,
                                             ruleTypeIn in integer) return integer as
    orderNumber integer;
    begin
      select max(ame_action_type_config.order_number)
        into orderNumber
        from ame_action_type_config,
             ame_action_type_usages,
             ame_action_types
        where
          ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_type_config.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_type_usages.rule_type = ruleTypeIn and
          ame_action_type_config.application_id = applicationIdIn and
          sysdate between ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate);
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeMaxOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getActionTypeMaxOrderNumber;
  function getActionTypeName(actionTypeIdIn in integer) return varchar2 as
    name ame_action_types_vl.user_action_type_name%type;
    begin
      if(actionTypeIdIn = ame_util.nullInsertionActionTypeId) then
        return('no action type');
      end if;
      select user_action_type_name
        into name
        from ame_action_types_vl
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(name);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeName;
  function getActionTypeNameByActionId(actionIdIn in integer) return varchar2 as
    name ame_action_types.name%type;
    begin
      select ame_action_types.name
        into name
        from ame_actions,
             ame_action_types
        where
          ame_actions.action_type_id = ame_action_types.action_type_id and
          action_id = actionIdIn and
          sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
                 nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate);
      return(name);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeNameByActionId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeNameByActionId;
  function getActionTypeProcedureName(actionTypeIdIn in integer) return varchar2 as
    procedureName ame_action_types.procedure_name%type;
    begin
      select procedure_name
        into procedureName
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(procedureName);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeProcedureName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeProcedureName;
  function getActionTypeOrderNumber(applicationIdIn in integer,
                                    actionTypeIdIn in integer) return integer as
    orderNumber integer;
    begin
      select order_number
        into orderNumber
        from ame_action_type_config
        where
          action_type_id = actionTypeIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeOrderNumber;
  function getActionTypeCreatedBy(actionTypeIdIn in integer) return integer as
    createdBy integer;
    begin
      select created_by
        into createdBy
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(createdBy);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeCreatedBy',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getActionTypeCreatedBy;
  function getAllowedRuleType(actionTypeIdIn in integer) return integer as
    ruleType integer;
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_action_type_usages
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if(tempCount > 1) then
        /* authority and exception rule types are mapped to the action type */
        /* return chain of authority */
        return(ame_util.authorityRuleType);
      else
        select rule_type
          into ruleType
          from ame_action_type_usages
          where
            action_type_id = actionTypeIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        return(ruleType);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getAllowedRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAllowedRuleType;
  function getAllowedRuleTypeLabel(ruleTypeIn in integer) return varchar2 as
    begin
      if(ruleTypeIn = ame_util.preListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_PRE_APPROVAL'));
      elsif(ruleTypeIn in(ame_util.authorityRuleType,
                       ame_util.exceptionRuleType)) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_CHAIN_OF_AUTHORITY'));
      elsif(ruleTypeIn = ame_util.listModRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_MODIFICATION2'));
      elsif(ruleTypeIn = ame_util.substitutionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_SUBSTITUTION'));
      elsif(ruleTypeIn = ame_util.postListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_POST_APPROVAL'));
      elsif(ruleTypeIn = ame_util.productionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_PRODUCTION'));
      elsif(ruleTypeIn = ame_util.combinationRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_COMBINATION'));
      else
        return(null);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getAllowedRuleTypeLabel',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
  end getAllowedRuleTypeLabel;
  function getChainOrderingMode(actionTypeIdIn in integer,
                                applicationIdIn in integer) return varchar2 as
    chainOrderingMode ame_util.charType;
    begin
      select chain_ordering_mode
        into chainOrderingMode
        from ame_action_type_config
        where
          action_type_id = actionTypeIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(chainOrderingMode);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getChainOrderingMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getChainOrderingMode;
  function getChildVersionStartDate(actionIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getChildVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
  end getChildVersionStartDate;
  function getChildVersionStartDate2(actionTypeIdIn in integer,
                                     applicationIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_action_type_config
        where
          action_type_id = actionTypeIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getChildVersionStartDate2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
  end getChildVersionStartDate2;
  /*
  getDescription returns a description of the form
  <<actionTypeName:  actionDescription>>, where actionDescription is
  the action's static or dynamic description.  The maximum length of the
  string returned by getDescription is 500 bytes.
*/
  function getDescription(actionIdIn in integer) return varchar2 as
    actionTypeName ame_action_types.name%type;
    approverName   ame_actions.parameter%type;
    description    ame_actions.description%type;
    approverDesc   ame_util.longStringType;
    approverValid  boolean;
    begin
      if(getActionTypeDynamicDesc(actionTypeIdIn =>
         getActionTypeIdById(actionIdIn => actionIdIn)) = ame_util.booleanTrue ) then
        return getDynamicActionDesc(actionIdIn => actionIdIn );
      end if;
      select description
        into description
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      /* Verify approver is a valid approver. */
      if(getActionTypeName(actionTypeIdIn =>
        (getActionTypeIdById(actionIdIn => actionIdIn)))) =
          ame_util.substitutionTypeName then
        approverName := getParameter(actionIdIn => actionIdIn);
        ame_approver_type_pkg.getApproverDescAndValidity(
                                nameIn         => approverName,
                                descriptionOut => approverDesc,
                                validityOut    => approverValid);
        if(not approverValid) then
          return(approverDesc);
        end if;
      end if;
      actionTypeName := getActionTypeNameByActionId(actionIdIn => actionIdIn);
      return(actionTypeName|| ': '|| description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getDescription;
  function getDescription2(actionIdIn in integer) return varchar2 as
    approverName   ame_actions.parameter%type;
    description    ame_actions.description%type;
    approverDesc   ame_util.longStringType;
    approverValid  boolean;
    begin
      if(getActionTypeDynamicDesc(actionTypeIdIn =>
         getActionTypeIdById(actionIdIn => actionIdIn)) = ame_util.booleanTrue ) then
        return getDynamicActionDesc(actionIdIn => actionIdIn );
      end if;
      select description
        into description
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      /* Verify approver is a valid approver. */
      if(getActionTypeName(actionTypeIdIn =>
        (getActionTypeIdById(actionIdIn => actionIdIn)))) =
          ame_util.substitutionTypeName then
        approverName := getParameter(actionIdIn => actionIdIn);
        ame_approver_type_pkg.getApproverDescAndValidity(
                                nameIn         => approverName,
                                descriptionOut => approverDesc,
                                validityOut    => approverValid);
        if(not approverValid) then
          return(approverDesc);
        end if;
      end if;
      return(description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getDescription2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getDescription2;
  function getDynamicActionDesc(actionIdIn in integer) return varchar2 as
    actionDescription ame_util.stringType;
    actionTypeName ame_action_types.name%type;
    descriptionQuery ame_action_types.description_query%type;
    parameterOne ame_actions.parameter%type;
    parameterTwo ame_actions.parameter_two%type;
    tempIndex integer;
    begin
      select description_query,
             parameter,
             parameter_two
        into descriptionQuery,
             parameterOne,
             parameterTwo
        from ame_actions,
             ame_action_types
        where
          ame_actions.action_type_id = ame_action_types.action_type_id and
          action_id = actionIdIn and
          sysdate between ame_action_types.start_date and
               nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
      if(instrb(descriptionQuery, ame_util.actionParameterOne) > 0) then
        if(instrb(descriptionQuery, ame_util.actionParameterTwo) > 0) then /* both parameters */
          execute immediate descriptionQuery
            into actionDescription using
            in parameterOne,
            in parameterTwo;
        else /* just parameter_one */
          execute immediate descriptionQuery into
            actionDescription using
            in parameterOne;
        end if;
      else
        if(instrb(descriptionQuery, ame_util.actionParameterTwo) > 0) then /* just paramter_two */
          execute immediate descriptionQuery into
            actionDescription using
            in parameterTwo;
        else /* neither */
          execute immediate descriptionQuery into
            actionDescription;
        end if;
      end if;
      actionTypeName := getActionTypeNameByActionId(actionIdIn => actionIdIn);
      return(actionTypeName || ': '|| actionDescription);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getDynamicActionDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getDynamicActionDesc;
  function getGroupChainActionTypeId return integer as
    actionTypeId ame_action_types.action_type_id%type;
      begin
        select action_type_id
          into actionTypeId
          from ame_action_types
          where name = ame_util.groupChainApprovalTypeName and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        return actionTypeId;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getGroupChainActionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getGroupChainActionTypeId;
  function getId(actionTypeIdIn in integer,
                 parameterIn in varchar2 default null) return integer as
    actionId integer;
    begin
      select action_id
        into actionId
        from ame_actions
        where
          action_type_id = actionTypeIdIn and
          ((parameterIn is null and parameter is null) or parameter = parameterIn) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(actionId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getId;
  function getParameter(actionIdIn in integer) return varchar2 as
    parameter ame_actions.parameter%type;
    begin
      select parameter
        into parameter
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameter);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getParameter',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getParameter;
  function getParameter2(actionIdIn in integer) return varchar2 as
    parameterTwo ame_actions.parameter_two%type;
    begin
      select parameter_two
        into parameterTwo
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameterTwo);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getParameter2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getParameter2;
  function getParentVersionStartDate(actionTypeIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getParentVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getParentVersionStartDate;
  function getPreApprovalActionTypeId return integer as
    actionTypeId ame_action_types.action_type_id%type;
      begin
        select action_type_id
          into actionTypeId
          from ame_action_types
          where name = ame_util.preApprovalTypeName and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        return actionTypeId;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getPreApprovalActionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getPreApprovalActionTypeId;
  function getPostApprovalActionTypeId return integer as
    actionTypeId ame_action_types.action_type_id%type;
      begin
        select action_type_id
          into actionTypeId
          from ame_action_types
          where name = ame_util.postApprovalTypeName and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        return actionTypeId;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getPostApprovalActionTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getPostApprovalActionTypeId;
  function getVotingRegime(actionTypeIdIn in integer,
                           applicationIdIn in integer) return varchar2 as
    votingRegime ame_approval_group_config.voting_regime%type;
    begin
      select voting_regime
        into votingRegime
        from ame_action_type_config
        where
           action_type_id = actionTypeIdIn and
           application_id = applicationIdIn and
           sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(votingRegime);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getVotingRegime',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getVotingRegime;
  function isInUse(actionIdIn in integer) return boolean as
    useCount integer;
    begin
      /*
        The following select checks that the rule is current, but
        not that the action is current.  This is intentional.  The
        assumption is that the rest of the application will never
        discover a historical action and try to check whether it
        is in use.  It now does check the start date
        of rules to capture future rule start dates.
      */
      select count(*)
        into useCount
        from ame_rules,
             ame_action_usages
        where
          ame_rules.rule_id = ame_action_usages.rule_id and
          ame_action_usages.action_id = actionIdIn and
          ((sysdate between ame_rules.start_date and
            nvl(ame_rules.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_rules.start_date and
            ame_rules.start_date < nvl(ame_rules.end_date,ame_rules.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_action_usages.start_date and
            nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_action_usages.start_date and
            ame_action_usages.start_date < nvl(ame_action_usages.end_date,ame_action_usages.start_date + ame_util.oneSecond)));
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'isInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isInUse;
  function isListCreationRuleType(actionTypeIdIn in integer) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_action_type_usages
        where
          action_type_id = actionTypeIdIn and
          rule_type = ame_util.authorityRuleType and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'isListCreationRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isListCreationRuleType;
  function isSeeded(actionTypeIdIn in integer) return boolean as
    createdByValue integer;
    attributeId integer;
    begin
                        select created_by
        into createdByValue
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(createdByValue = 1) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'isSeeded',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isSeeded;
  function new(nameIn in varchar2,
               procedureNameIn in varchar2,
               dynamicDescriptionIn in varchar2,
               descriptionIn in varchar2 default null,
               descriptionQueryIn in varchar2 default null,
               actionTypeIdIn in integer default null,
               finalizeIn in boolean default false,
               newStartDateIn in date default null,
               processingDateIn in date default null) return integer as
    actionTypeId integer;
    createdBy integer;
    currentUserId integer;
    descriptionLengthException exception;
    descriptionQueryException exception;
    descriptionQueryLgthException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidDesQueryException exception;
    invalidDesQueryException2 exception;
    nameLengthException exception;
    nullDescriptionQueryException exception;
    nullException exception;
    procedureNameLengthException exception;
    processingDate date;
    tempCount integer;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(nameIn is null or
         procedureNameIn is null) then
        raise nullException;
      end if;
      begin
        select action_type_id
          into actionTypeId
          from ame_action_types
          where
            (actionTypeIdIn is null or action_type_id <> actionTypeIdIn) and
            upper(name) = upper(nameIn) and
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
          if actionTypeId is not null then
          raise_application_error(-20001,
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400139_ACT_APT_ALD_EXISTS'));
          end if;
        exception
          when no_data_found then null;
      end;
      if(dynamicDescriptionIn = ame_util.booleanTrue) then
        if(descriptionQueryIn is null) then
          raise nullDescriptionQueryException;
        end if;
        if(instrb(descriptionQueryIn, ';', 1, 1) > 0) or
          (instrb(descriptionQueryIn, '--', 1, 1) > 0) or
          (instrb(descriptionQueryIn, '/*', 1, 1) > 0) or
          (instrb(descriptionQueryIn, '*/', 1, 1) > 0) then
          raise descriptionQueryException;
        end if;
        /* Verify that the description query includes at least one of the bind variables */
        if(instrb(descriptionQueryIn, ame_util.actionParameterOne, 1, 1) = 0) then
          if(instrb(descriptionQueryIn, ame_util.actionParameterTwo, 1, 1) = 0) then
            raise invalidDesQueryException;
          end if;
        end if;
        if(instrb(descriptionQueryIn, ':', 1, 1) > 0) then
          if(instrb(descriptionQueryIn, ame_util.actionParameterOne, 1, 1) = 0) then
            if(instrb(descriptionQueryIn, ame_util.actionParameterTwo, 1, 1) = 0) then
              raise invalidDesQueryException2;
            end if;
          end if;
        end if;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_action_types',
                                    columnNameIn => 'name',
                                    argumentIn => nameIn)) then
        raise nameLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_action_types',
                                    columnNameIn => 'procedure_name',
                                    argumentIn => procedureNameIn)) then
        raise procedureNameLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_action_types',
                                    columnNameIn => 'description',
                                    argumentIn => descriptionIn)) then
        raise descriptionLengthException;
      end if;
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(actionTypeIdIn is null) then
        createdBy := currentUserId;
        select ame_action_types_s.nextval into actionTypeId from dual;
      else
        actionTypeId := actionTypeIdIn;
        select count(*)
         into tempCount
         from ame_action_types
           where
             action_type_id = actionTypeId and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      insert into ame_action_types(action_type_id,
                                   name,
                                   procedure_name,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   end_date,
                                   description,
                                   dynamic_description,
                                   description_query)
        values(actionTypeId,
               nameIn,
               procedureNameIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               nvl(newStartDateIn, processingDate),
               null,
               descriptionIn,
               dynamicDescriptionIn,
               descriptionQueryIn);
      if(finalizeIn) then
        commit;
      end if;
      return(actionTypeId);
      exception
        when invalidDesQueryException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400370_ACT_DYNAMIC_DESC');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when invalidDesQueryException2 then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400371_ACT_INV_BIND_VAR');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when nameLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                  messageNameIn   => 'AME_400140_ACT_APT_NAME_LONG',
                  tokenNameOneIn  => 'COLUMN_LENGTH',
                  tokenValueOneIn =>
                  ame_util.getColumnLength(tableNameIn => 'ame_action_types',
                                          columnNameIn => 'name'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when procedureNameLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                  messageNameIn   => 'AME_400141_ACT_APT_PRC_NAM_LNG',
                  tokenNameOneIn  => 'COLUMN_LENGTH',
                  tokenValueOneIn =>
                  ame_util.getColumnLength(tableNameIn => 'ame_action_types',
                                          columnNameIn => 'procedure_name'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when descriptionLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn   => 'AME_400142_ACT_APT_DESC_LONG',
                              tokenNameOneIn  => 'COLUMN_LENGTH',
                              tokenValueOneIn =>
                                ame_util.getColumnLength(tableNameIn => 'ame_action_types',
                                                         columnNameIn => 'description'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when nullException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400144_ACT_VALUE_APT_ENT');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when descriptionQueryException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400372_ACT DYNAMIC_DESC2');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullDescriptionQueryException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400373_ACT DYNAMIC_DESC3');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when descriptionQueryLgthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                  messageNameIn   => 'AME_400142_ACT_APT_DESC_LONG',
                  tokenNameOneIn  => 'COLUMN_LENGTH',
                  tokenValueOneIn =>
                  ame_util.getColumnLength(tableNameIn => 'ame_action_types',
                                          columnNameIn => 'description_query'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end new;
  function newAction(actionTypeIdIn in integer,
                     updateParentObjectIn in boolean,
                     descriptionIn in varchar2 default null,
                     parameterIn in varchar2 default null,
                     parameterTwoIn in varchar2 default null,
                     newStartDateIn in date default null,
                     finalizeIn in boolean default false,
                     parentVersionStartDateIn in date default null,
                     actionIdIn in integer default null,
                     processingDateIn in date default null) return integer as
    cursor startDateCursor is
      select start_date
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    actionCount integer;
    actionId integer;
    actionTypeId integer;
    actionTypeDescription ame_action_types.description%type;
    actionTypeDescQuery ame_action_types.description_query%type;
    actionTypeDynamicDesc ame_action_types.dynamic_description%type;
    actionTypeName ame_action_types.name%type;
    actionTypeProcedureName ame_action_types.procedure_name%type;
    attributeId ame_attributes.attribute_id%type;
    createdBy integer;
    currentUserId integer;
    descriptionLengthException exception;
    duplicateActionException exception;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidAttNameException exception;
    invalidParameter exception;
    nullDescriptionException exception;
    objectVersionNoDataException exception;
    parameterLengthException exception;
    startDate date;
    processingDate date;
    tempCount integer;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into startDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> startDate) then
            close startDateCursor;
            raise ame_util.objectVersionException;
          end if;
      end if;
      if parameterIn like '%;%' then
        raise invalidParameter;
      end if;
      if(descriptionIn is null) and
        (getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn) = ame_util.booleanFalse) then
        raise nullDescriptionException;
      end if;
      select count(*)
        into actionCount
        from ame_actions
        where
          (actionIdIn is null or action_id <> actionIdIn) and
          ((parameterIn is null and parameter is null) or parameter = parameterIn) and
          ((parameterTwoIn is null and parameter_two is null) or parameter_two = parameterTwoIn) and
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate);
      if(actionCount > 0) then
        raise duplicateActionException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_actions',
                                    columnNameIn => 'description',
                                    argumentIn => descriptionIn)) then
        raise descriptionLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_actions',
                                    columnNameIn => 'parameter',
                                    argumentIn => parameterIn)) then
        raise parameterLengthException;
      end if;
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(actionIdIn is null) then
        createdBy := currentUserId;
        select ame_actions_s.nextval into actionId from dual;
      else
        actionId := actionIdIn;
        select count(*)
         into tempCount
         from ame_actions
           where
             action_id = actionId and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      startDate := processingDate;
      insert into ame_actions(action_id,
                              action_type_id,
                              parameter,
                              created_by,
                              creation_date,
                              last_updated_by,
                              last_update_date,
                              last_update_login,
                              start_date,
                              end_date,
                              description,
                              parameter_two)
        values(actionId,
               actionTypeIdIn,
               parameterIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               nvl(newStartDateIn, startDate),
               null,
               descriptionIn,
               parameterTwoIn);
      actionTypeName := ame_action_pkg.getActionTypeName(actionTypeIdIn => actionTypeIdIn);
      if(updateParentObjectIn) then
        endDate := startDate ;
        actionTypeDescription := getActionTypeDescription(actionTypeIdIn => actionTypeIdIn);
        actionTypeProcedureName := getActionTypeProcedureName(actionTypeIdIn => actionTypeIdIn);
        actionTypeDynamicDesc := getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn);
        actionTypeDescQuery := getActionTypeDescQuery(actionTypeIdIn => actionTypeIdIn);
        update ame_action_types
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            action_type_id = actionTypeIdIn and
            processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate);
          actionTypeId := new(nameIn => actionTypeName,
                              procedureNameIn => actionTypeProcedureName,
                              descriptionIn => actionTypeDescription,
                              actionTypeIdIn => actionTypeIdIn,
                              dynamicDescriptionIn => actionTypeDynamicDesc,
                              descriptionQueryIn => actionTypeDescQuery,
                              finalizeIn => false,
                              newStartDateIn => nvl(newStartDateIn, startDate),
                              processingDateIn => processingDate);
      end if;
      if(finalizeIn) then
        commit;
      end if;
      return(actionId);
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
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
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullDescriptionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                           messageNameIn => 'AME_400137_ACT_EMPTY_DESC');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when duplicateActionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                           messageNameIn => 'AME_400293_ACT_APR_ALD_EXISTS');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidParameter then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400135_ACT_NO_PAR_SEMI');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when descriptionLengthException then
          rollback;
          errorCode := -20001;
          errorMessage:= ame_util.getMessage(applicationShortNameIn => 'PER',
           messageNameIn   => 'AME_400136_ACT_APP_DES_LNG',
           tokenNameOneIn  => 'COLUMN_LENGTH',
           tokenValueOneIn =>
                        ame_util.getColumnLength(tableNameIn => 'ame_actions',
                                              columnNameIn => 'description'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=  ame_util.getMessage(applicationShortNameIn => 'PER',
                     messageNameIn   => 'AME_400138_ACT_APPR_TOO_LONG',
                     tokenNameOneIn  => 'COLUMN_LENGTH',
                     tokenValueOneIn =>
                         ame_util.getColumnLength(tableNameIn => 'ame_actions',
                                               columnNameIn => 'parameter'));
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when invalidAttNameException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400323_INV_ATTRIB_ENT_PAR');
            ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                      routineNameIn => 'newAction',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
            return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newAction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end newAction;
  function orderNumberUnique(applicationIdIn in integer,
                                                                                                                 orderNumberIn in integer,
                                                                                                                 actionTypeIdIn in integer) return boolean as
    ruleType integer;
                tempCount integer;
                begin
                  ruleType := getAllowedRuleType(actionTypeIdIn => actionTypeIdIn);
      select count(*)
        into tempCount
        from ame_action_type_config,
             ame_action_type_usages
        where
          ame_action_type_config.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_type_config.application_id = applicationIdIn and
          ame_action_type_config.order_number = orderNumberIn and
          ame_action_type_usages.rule_type = ruleType and
          sysdate between ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate);
      if(tempCount > 1) then
        return(false);
      else
        return(true);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'orderNumberUnique',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
  end orderNumberUnique;
  function requiredAttOnApprovalTypeList(actionTypeIdIn in integer,
                                         attributeIdIn in integer) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_mandatory_attributes
        where
          action_type_id = actionTypeIdIn and
          attribute_id = attributeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return true;
      end if;
      return false;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'requiredAttOnApprovalTypeList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end requiredAttOnApprovalTypeList;
  procedure change(actionTypeIdIn in integer,
                   ruleTypeIn in varchar2,
                   processingDateIn in date,
                   descriptionQueryIn in varchar2 default null,
                   nameIn in varchar2 default null,
                   procedureNameIn in varchar2 default null,
                   descriptionIn in varchar2 default null,
                   deleteListIn in ame_util.stringList default ame_util.emptyStringList,
                   finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_action_types
        where action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    actionIdList ame_util.idList;
    actionTypeId integer;
    actionTypeSeeded boolean;
    approverTypeIdList ame_util.idList;
    attributeId integer;
    childVersionStartDates ame_util.dateList;
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    deleteCount integer;
    description ame_action_types.description%type;
    dynamicDescription ame_action_types.dynamic_description%type;
    name ame_action_types.name%type;
    newStartDate date;
    nullException exception;
    objectVersionNoDataException exception;
    procedureName ame_action_types.procedure_name%type;
    seededException exception;
    startDate date;
    tempIndex integer;
    tempIndex2 integer;
    begin
      actionTypeSeeded := isSeeded(actionTypeIdIn => actionTypeIdIn);
      currentUserId := ame_util.getCurrentUserId;
      if(not actionTypeSeeded) then
        removeActionTypeUsages(actionTypeIdIn => actionTypeIdIn,
                               finalizeIn => false,
                               processingDateIn => processingDateIn);
        newActionTypeUsage(actionTypeIdIn => actionTypeIdIn,
                           ruleTypeIn => ruleTypeIn,
                           finalizeIn => false,
                           processingDateIn => processingDateIn);
      end if;
      dynamicDescription := getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn);
      /* make sure the end_date and start_date values do not overlap */
      endDate := processingDateIn;
      newStartDate := processingDateIn;
      update ame_action_types
        set
          last_updated_by = currentUserId,
          last_update_date = endDate,
          last_update_login = currentUserId,
          end_date = endDate
        where
          action_type_id = actionTypeIdIn and
          processingDateIn between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDateIn) ;
      actionTypeId := new(nameIn => nameIn,
                          procedureNameIn => procedureNameIn,
                          descriptionIn => descriptionIn,
                          actionTypeIdIn => actionTypeIdIn,
                          dynamicDescriptionIn => dynamicDescription,
                          descriptionQueryIn => descriptionQueryIn,
                          finalizeIn => false,
                          newStartDateIn => newStartDate,
                          processingDateIn => processingDateIn);
      deleteCount := deleteListIn.count;
      tempIndex := 1;
      tempIndex2 := 1;
      if(deleteCount > 0) then
        for i in 1..deleteCount loop
          if(deleteListIn(i)) like 'req%' then
            attributeId := substrb(deleteListIn(i),4,(lengthb(deleteListIn(i))));
            ame_attribute_pkg.removeMandatoryAttributes(attributeIdIn => attributeId,
                                                        actionTypeIdIn => actionTypeIdIn,
                                                        finalizeIn => false);
          elsif(deleteListIn(i)) like 'appr%' then
            approverTypeIdList(tempIndex2) :=
              to_number(substrb(deleteListIn(i),5,(lengthb(deleteListIn(i)))));
            tempIndex2 := tempIndex2 + 1;
          else
            actionIdList(tempIndex) := deleteListIn(i);
            childVersionStartDates(tempIndex) :=
              ame_util.versionStringToDate(stringDateIn =>
                ame_action_pkg.getChildVersionStartDate(actionIdIn => deleteListIn(i)));
            tempIndex := tempIndex + 1;
          end if;
        end loop;
        -- Check if any approver types were selected for deletion.
        if(approverTypeIdList.count > 0) then
          ame_approver_type_pkg.removeApproverTypeUsages(actionTypeIdIn => actionTypeIdIn,
                                                         approverTypeIdsIn => approverTypeIdList,
                                                         finalizeIn => false,
                                                         processingDateIn => processingDateIn);
        end if;
        if actionIdList.count > 0 then
          removeAction(actionTypeIdIn => actionTypeIdIn,
                       actionIdIn => actionIdList,
                       childVersionStartDatesIn => childVersionStartDates,
                       finalizeIn => false,
                       processingDateIn => processingDateIn);
        end if;
      end if;
      if(finalizeIn) then
        close startDateCursor;
        commit;
      end if;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
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
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
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
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end change;
  procedure changeAction(actionIdIn in integer,
                         actionTypeIdIn in integer default null,
                         descriptionIn in varchar2 default null,
                         parameterIn in varchar2 default null,
                         parameterTwoIn in varchar2 default null,
                         finalizeIn in boolean default false,
                         childVersionStartDateIn in date,
                         parentVersionStartDateIn in date,
                         processingDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_action_types
        where action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_actions
        where action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    actionId ame_actions.action_id%type;
    actionTypeId ame_action_types.action_type_id%type;
    currentUserId integer;
    description ame_actions.description%type;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newActionTypeId ame_action_types.action_type_id%type;
    newStartDate date;
    nullDescriptionException exception;
    objectVersionNoDataException exception;
    startDate date;
    startDate2 date;
    tempCount integer;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(descriptionIn is null) and
        (getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn) = ame_util.booleanFalse) then
        raise nullDescriptionException;
      end if;
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into startDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> startDate) then
            close startDateCursor;
            raise ame_util.objectVersionException;
          end if;
          open startDateCursor2;
            fetch startDateCursor2 into startDate2;
            if startDateCursor2%notfound then
              raise objectVersionNoDataException;
            end if;
            if(childVersionStartDateIn <> startDate2) then
              close startDateCursor2;
              raise ame_util.objectVersionException;
            end if;
      end if;
      select count(*)
        into tempCount
        from ame_actions
        where
          action_id = actionIdIn and
          action_type_id = actionTypeIdIn and
          (descriptionIn is null or description = descriptionIn) and
          /* parameterIn is null means "set parameter to null,"
             because parameter defaults to null */
          ((parameterIn is null and parameter is null) or upper(parameter) = upper(parameterIn)) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return;
      end if;
      if(actionTypeIdIn is null) then
        actionTypeId := getActionTypeIdById(actionIdIn);
      else
        actionTypeId := actionTypeIdIn;
      end if;
      /*
      Always update to parameterIn, even if it's null.
      */
      currentUserId := ame_util.getCurrentUserId;
      /* make sure the end_date and start_date values do not overlap */
      endDate := sysdate ;
      newStartDate := sysdate;
      update ame_actions
        set
          last_updated_by = currentUserId,
          last_update_date = endDate,
          last_update_login = currentUserId,
          end_date = endDate
        where
           action_id = actionIdIn and
           processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
        actionId := newAction(actionTypeIdIn => actionTypeId,
                              descriptionIn => descriptionIn,
                              updateParentObjectIn => true,
                              finalizeIn => false,
                              parameterIn => parameterIn,
                              parameterTwoIn => parameterTwoIn,
                              newStartDateIn => newStartDate,
                              actionIdIn => actionIdIn,
                              processingDateIn => processingDate);
      if(finalizeIn) then
        close StartDateCursor2;
        close StartDateCursor;
        commit;
      end if;
      exception
        when nullDescriptionException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                           messageNameIn => 'AME_400137_ACT_EMPTY_DESC');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeAction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action ID ' ||
                                                        actionIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeAction;
  procedure changeActionTypeAndConfig(actionTypeIdIn in integer,
                                      ruleTypeIn in varchar2,
                                      orderNumberIn in integer,
                                      orderNumberUniqueIn in varchar2,
                                      childVersionStartDate2In in date,
                                      parentVersionStartDateIn in date,
                                      applicationIdIn in integer,
                                      descriptionQueryIn in varchar2 default null,
                                      chainOrderIngModeIn in varchar2 default null,
                                      votingRegimeIn in varchar2 default null,
                                      nameIn in varchar2 default null,
                                      procedureNameIn in varchar2 default null,
                                      descriptionIn in varchar2 default null,
                                      deleteListIn in ame_util.stringList default ame_util.emptyStringList,
                                      finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_action_types
        where action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_action_type_config
        where
          action_type_id = actionTypeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    currentUserId integer;
    description ame_approval_groups.description%type;
    dynamicDescription ame_action_types.dynamic_description%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    nullDescriptionQueryException exception;
    nullException exception;
    objectVersionNoDataException exception;
    processingDate date;
    startDate date;
    startDate2 date;
    begin
        processingDate := sysdate;
      /* Try to get a lock on the record. */
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(parentVersionStartDateIn <> startDate) then
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
        open startDateCursor2;
          fetch startDateCursor2 into startDate2;
          if startDateCursor2%notfound then
            raise objectVersionNoDataException;
          end if;
          if(childVersionStartDate2In <> startDate2) then
            close startDateCursor2;
            raise ame_util.objectVersionException;
          end if;
          if(nameIn is null or
            procedureNameIn is null or
            descriptionIn is null) then
            raise nullException;
          end if;
          dynamicDescription := getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn);
          if(dynamicDescription = ame_util.booleanTrue) then
            if(descriptionQueryIn is null) then
              raise nullDescriptionQueryException;
            end if;
          end if;
          ame_action_pkg.change(actionTypeIdIn => actionTypeIdIn,
                                nameIn => nameIn,
                                procedureNameIn => procedureNameIn,
                                descriptionIn => descriptionIn,
                                descriptionQueryIn => descriptionQueryIn,
                                ruleTypeIn => ruleTypeIn,
                                deleteListIn => deleteListIn,
                                processingDateIn => processingDate,
                                finalizeIn => false);
          ame_action_pkg.changeActionTypeConfig(actionTypeIdIn => actionTypeIdIn,
                                                orderNumberIn => orderNumberIn,
                                                orderNumberUniqueIn => orderNumberUniqueIn,
                                                chainOrderingModeIn => chainOrderingModeIn,
                                                votingRegimeIn => votingRegimeIn,
                                                applicationIdIn => applicationIdIn,
                                                processingDateIn => processingDate,
                                                finalizeIn => false);
        close startDateCursor2;
      close startDateCursor;
      if(finalizeIn) then
        commit;
      end if;
      exception
      when ame_util.objectVersionException then
        rollback;
        if(startDateCursor%isOpen) then
          close startDateCursor;
        end if;
        if(startDateCursor2%isOpen) then
          close startDateCursor2;
        end if;
        errorCode := -20001;
        errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
        ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                  routineNameIn => 'changeActionTypeAndConfig',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
      when objectVersionNoDataException then
        rollback;
        if(startDateCursor%isOpen) then
          close startDateCursor;
        end if;
        if(startDateCursor2%isOpen) then
          close startDateCursor2;
        end if;
        errorCode := -20001;
        errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
        ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                  routineNameIn => 'changeActionTypeAndConfig',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        when nullException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400144_ACT_VALUE_APT_ENT');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeActionTypeAndConfig',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullDescriptionQueryException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400373_ACT DYNAMIC_DESC3');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeActionTypeAndConfig',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeActionTypeAndConfig',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeActionTypeAndConfig;
  procedure changeActionTypeConfig(applicationIdIn in integer,
                                   actionTypeIdIn in integer,
                                   orderNumberIn in integer,
                                   orderNumberUniqueIn in varchar2,
                                   processingDateIn in date,
                                   votingRegimeIn in varchar2 default null,
                                   chainOrderingModeIn in varchar2 default null,
                                   finalizeIn in boolean default false) as
                currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newOrderNumber integer;
    newStartDate date;
    oldOrderNumber integer;
    orderNumberException exception;
    oldOrderNumberUnique ame_util.stringType;
    updateOnlyATModified boolean;
    begin
      oldOrderNumber := getActionTypeOrderNumber(applicationIdIn => applicationIdIn,
                                                 actionTypeIdIn => actionTypeIdIn);
                        if(ame_action_pkg.orderNumberUnique(applicationIdIn => applicationIdIn,
                                          orderNumberIn => oldOrderNumber,
                                          actionTypeIdIn => actionTypeIdIn)) then
        oldOrderNumberUnique := ame_util.yes;
      else
                          oldOrderNumberUnique := ame_util.no;
      end if;
                        endDate := processingDateIn;
      newStartDate := processingDateIn;
      currentUserId := ame_util.getCurrentUserId;
      updateOnlyATModified := false;
      /* Check if order number was modified */
                        if(oldOrderNumber = orderNumberIn) then
                          if(orderNumberUniqueIn = oldOrderNumberUnique) then
                            updateOnlyATModified := true; /* Order number not modified. */
        elsif(orderNumberUniqueIn = ame_util.yes) then
                            /* Need to increment the order numbers to keep them in sequence. */
          incrementActionTypeOrdNumbers(applicationIdIn => applicationIdIn,
                                        actionTypeIdIn => actionTypeIdIn,
                                        orderNumberIn => orderNumberIn);

        else /* The order number is not unique. */
                                  raise orderNumberException;
                                end if;
      else
        update ame_action_type_config
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            action_type_id = actionTypeIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
                                if(oldOrderNumberUnique = ame_util.yes) then
          decrementActionTypeOrdNumbers(applicationIdIn => applicationIdIn,
                                        actionTypeIdIn => actionTypeIdIn,
                                        orderNumberIn => oldOrderNumber);
                                  if(orderNumberIn > oldOrderNumber)then
            newOrderNumber := (orderNumberIn - 1);
          else
            newOrderNumber := orderNumberIn;
          end if;
        else
          newOrderNumber := orderNumberIn;
                          end if;
                                if(orderNumberUniqueIn = ame_util.yes) then
                            incrementActionTypeOrdNumbers(applicationIdIn => applicationIdIn,
                                                          actionTypeIdIn => actionTypeIdIn,
                                                          orderNumberIn => newOrderNumber);
        end if;
        insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationIdIn,
                 actionTypeIdIn,
                 votingRegimeIn,
                 newOrderNumber,
                 chainOrderingModeIn,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 null);
                        end if;
                        if(updateOnlyATModified) then
                          update ame_action_type_config
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            action_type_id = actionTypeIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationIdIn,
                 actionTypeIdIn,
                 votingRegimeIn,
                 orderNumberIn,
                 chainOrderingModeIn,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 null);
                        end if;
                        if(finalizeIn) then
        commit;
      end if;
      exception
        when orderNumberException then
          rollback;
          errorCode := -20001;
          errorMessage :=
                                          ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400463_ORD_NUM_UNIQUE');
                                        ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeActionTypeConfig',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'changeActionTypeConfig',
                                   exceptionNumberIn => sqlcode,
                                    exceptionStringIn =>  '(action type ID ' ||
                                                          actionTypeIdIn||
                                                          ') ' ||
                                                          sqlerrm);
          raise;
    end changeActionTypeConfig;
  procedure decrementActionTypeOrdNumbers(applicationIdIn in integer,
                                          actionTypeIdIn in integer,
                                          orderNumberIn in integer,
                                          finalizeIn in boolean default false) as
    cursor orderNumberCursor(applicationIdIn in integer,
                                         orderNumberIn in integer,
                                         ruleTypeIn in integer) is
      select ame_action_type_config.action_type_id,
                               ame_action_type_config.order_number
        from ame_action_type_config,
             ame_action_type_usages
        where
          ame_action_type_config.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_type_config.application_id = applicationIdIn and
          ame_action_type_config.order_number > orderNumberIn and
          ame_action_type_usages.rule_type = ruleTypeIn and
          sysdate between ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
          order by order_number;
                actionTypeIds ame_util.idList;
                chainOrderingMode ame_util.charType;
                currentUserId integer;
    orderNumbers ame_util.idList;
    processingDate date;
    ruleType integer;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
                        processingDate := sysdate;
                        ruleType := getAllowedRuleType(actionTypeIdIn => actionTypeIdIn);
      open orderNumberCursor(applicationIdIn => applicationIdIn,
                                               orderNumberIn => orderNumberIn,
                                                                                                                 ruleTypeIn => ruleType);
        fetch orderNumberCursor bulk collect
        into actionTypeIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. actionTypeIds.count loop
        votingRegime := getVotingRegime(actionTypeIdIn => actionTypeIds(i),
                                                                applicationIdIn => applicationIdIn);
        chainOrderingMode := getChainOrderingMode(actionTypeIdIn => actionTypeIds(i),
                                                  applicationIdIn => applicationIdIn);
                                update ame_action_type_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            action_type_id = actionTypeIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationIdIn,
                 actionTypeIds(i),
                 votingRegime,
                 (orderNumbers(i) - 1),
                 chainOrderingMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
                        if(finalizeIn) then
        commit;
      end if;
      exception
       when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_action_pkg',
                                    routineNameIn     => 'decrementActionTypeOrdNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end decrementActionTypeOrdNumbers;
  procedure getActions(actionTypeIdIn in integer,
                       actionsOut out nocopy ame_util.idStringTable) as
    cursor actionCursor(actionTypeIdIn in integer) is
      select
        action_id,
        description,
        parameter
        from ame_actions
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by description;
      tempIndex integer;
            begin
        tempIndex := 1;
        /* If substitute action, need to check if approver is valid. */
        if(getActionTypeName(actionTypeIdIn) = ame_util.substitutionTypeName) then
          for tempAction in actionCursor(actionTypeIdIn => actionTypeIdIn) loop
            if(ame_approver_type_pkg.validateApprover(nameIn => tempAction.parameter)) then
              actionsOut(tempIndex).id := tempAction.action_id;
              actionsOut(tempIndex).string := tempAction.description;
              tempIndex := tempIndex + 1;
            end if;
          end loop;
        else
          for tempAction in actionCursor(actionTypeIdIn => actionTypeIdIn) loop
            actionsOut(tempIndex).id := tempAction.action_id;
            actionsOut(tempIndex).string := tempAction.description;
            tempIndex := tempIndex + 1;
          end loop;
        end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_action_pkg',
                                    routineNameIn     => 'getActions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          actionsOut := ame_util.emptyIdStringTable;
          raise;
    end getActions;
  procedure getActions2(actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor actionCursor(actionTypeIdIn in integer) is
      select
        action_id,
        parameter
        from ame_actions
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        order by description;
    tempIndex integer;
    begin
      tempIndex := 1;
      /* If substitute action, need to check if approver is valid. */
      if(getActionTypeName(actionTypeIdIn) = ame_util.substitutionTypeName) then
        for tempAction in actionCursor(actionTypeIdIn => actionTypeIdIn) loop
          if(ame_approver_type_pkg.validateApprover(nameIn => tempAction.parameter)) then
            actionIdsOut(tempIndex) := tempAction.action_id;
            actionDescriptionsOut(tempIndex) := getDescription(actionIdIn => tempAction.action_id);
            tempIndex := tempIndex + 1;
          end if;
        end loop;
      else
        for tempAction in actionCursor(actionTypeIdIn => actionTypeIdIn) loop
          actionIdsOut(tempIndex) := tempAction.action_id;
          actionDescriptionsOut(tempIndex) := getDescription(actionIdIn => tempAction.action_id);
          tempIndex := tempIndex + 1;
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActions2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          actionIdsOut := ame_util.emptyStringList;
          actionDescriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getActions2;
  procedure getActions3(actionTypeIdIn in integer,
                        dynamicDescriptionIn in varchar2,
                        actionTypeNamesOut out nocopy ame_util.stringList,
                        actionIdsOut out nocopy ame_util.idList,
                        actionParametersOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList,
                        actionCreatedByOut out nocopy ame_util.idList) as
    cursor actionCursor(actionTypeIdIn in integer) is
      select
        ame_action_types.name,
        ame_action_types.description_query,
        ame_actions.action_id,
        ame_actions.description,
        ame_actions.parameter,
        ame_actions.parameter_two,
        ame_actions.created_by
        from ame_action_types,
             ame_actions
        where
          ame_action_types.action_type_id = ame_actions.action_type_id and
          ame_action_types.action_type_id = actionTypeIdIn and
          sysdate between ame_action_types.start_date and
               nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate)
        order by ame_actions.created_by, ame_actions.description;
    parameterOne ame_actions.parameter%type;
    parameterTwo ame_actions.parameter_two%type;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAction in actionCursor(actionTypeIdIn => actionTypeIdIn) loop
        actionTypeNamesOut(tempIndex) := tempAction.name;
        actionIdsOut(tempIndex) := tempAction.action_id;
        actionParametersOut(tempIndex) := tempAction.parameter;
        actionCreatedByOut(tempIndex) := tempAction.created_by;
        if(dynamicDescriptionIn = ame_util.booleanFalse) then
          actionDescriptionsOut(tempIndex) := tempAction.description;
        else
          begin
            if(instrb(tempAction.description_query, ame_util.actionParameterOne) > 0) then
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* both parameters */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter,
                  in tempAction.parameter_two;
              else /* just parameter_one */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter;
              end if;
            else
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* just paramter_two */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter_two;
              else /* neither */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex);
              end if;
            end if;
            exception when others then
              actionDescriptionsOut(tempIndex) := 'Invalid description';
          end;
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActions3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          actionTypeNamesOut := ame_util.emptyStringList;
          actionIdsOut := ame_util.emptyIdList;
          actionParametersOut := ame_util.emptyStringList;
          actionDescriptionsOut := ame_util.emptyStringList;
          actionCreatedByOut := ame_util.emptyIdList;
          raise;
    end getActions3;
  procedure getActions4(actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionsCursor is
      select ame_actions.action_id,
             ame_actions.parameter,
             ame_actions.parameter_two,
             ame_actions.description,
             ame_action_types.dynamic_description,
             ame_action_types.description_query
        from ame_actions,
             ame_action_types
        where
          ame_actions.action_type_id = ame_action_types.action_type_id and
          ame_actions.action_type_id = actionTypeIdIn and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate)
        order by ame_actions.created_by, ame_actions.description;
    actionId integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAction in actionsCursor loop
        actionIdsOut(tempIndex) := tempAction.action_id;
        if(tempAction.dynamic_description = ame_util.booleanTrue) then
          begin
            if(instrb(tempAction.description_query, ame_util.actionParameterOne) > 0) then
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* both parameters */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter,
                  in tempAction.parameter_two;
              else /* just parameter_one */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter;
              end if;
            else
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* just paramter_two */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter_two;
              else /* neither */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex);
              end if;
            end if;
            exception when others then
            actionDescriptionsOut(tempIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_INVALID_DESCRIPTION');
          end;
        else
          actionDescriptionsOut(tempIndex) := tempAction.description;
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_action_pkg',
                                    routineNameIn     => 'getActions4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionIdsOut := ame_util.emptyStringList;
          actionDescriptionsOut := ame_util.emptyStringList;
          raise;
    end getActions4;
  procedure getActionTypes(actionTypesOut out nocopy ame_util.idStringTable) as
      cursor actionTypeCursor is
              select
          action_type_id,
          name
                from ame_action_types
                where
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
         order by name;
      tempIndex integer;
            begin
        tempIndex := 1;
        for tempActionType in actionTypeCursor loop
          actionTypesOut(tempIndex).id := tempActionType.action_type_id;
          actionTypesOut(tempIndex).string := tempActionType.name;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypesOut := ame_util.emptyIdStringTable;
          raise;
    end getActionTypes;
  procedure getActionTypes2(actionTypeIdsOut out nocopy ame_util.stringList,
                            actionTypeNamesOut out nocopy ame_util.stringList) as
      cursor actionTypeCursor is
              select
          action_type_id,
          name
                from ame_action_types
                where
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
         order by name;
      tempIndex integer;
            begin
        tempIndex := 1;
        for tempActionType in actionTypeCursor loop
          actionTypeIdsOut(tempIndex) := tempActionType.action_type_id;
          actionTypeNamesOut(tempIndex) := tempActionType.name;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypeIdsOut := ame_util.emptyStringList;
          actionTypeNamesOut := ame_util.emptyStringList;
          raise;
    end getActionTypes2;
  procedure getActionTypes3(applicationIdIn in integer,
                            actionTypeIdsOut out nocopy ame_util.stringList,
                            actionTypeNamesOut out nocopy ame_util.stringList,
                            actionTypeDescriptionsOut out nocopy ame_util.stringList,
                            ruleTypesOut out nocopy ame_util.idList) as
    cursor actionTypeCursor is
      select ame_action_types.action_type_id,
             ame_action_types.name,
             ame_action_types.description,
             ame_action_type_usages.rule_type,
             ame_action_type_config.order_number
        from ame_action_types,
             ame_action_type_usages,
             ame_action_type_config
        where
          ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_types.action_type_id = ame_action_type_config.action_type_id and
          ame_action_type_config.application_id = applicationIdIn and
          ame_action_type_usages.rule_type <> ame_util.exceptionRuleType and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate)
         order by ame_action_type_usages.rule_type,
                  ame_action_type_config.order_number,
                  ame_action_types.name;
    tempIndex integer;
    begin
      tempIndex := 1;
        for tempActionType in actionTypeCursor loop
          actionTypeIdsOut(tempIndex) := tempActionType.action_type_id;
          actionTypeNamesOut(tempIndex) := tempActionType.name;
          actionTypeDescriptionsOut(tempIndex) := tempActionType.description;
          ruleTypesOut(tempIndex) := tempActionType.rule_type;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypes3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypeIdsOut := ame_util.emptyStringList;
          actionTypeNamesOut := ame_util.emptyStringList;
          actionTypeDescriptionsOut := ame_util.emptyStringList;
          ruleTypesOut := ame_util.emptyIdList;
          raise;
    end getActionTypes3;
  procedure getActionTypeDescriptions(actionTypeIdsOut out nocopy ame_util.stringList,
                                      actionTypeDescriptionsOut out nocopy ame_util.stringList) as
      cursor actionTypeCursor is
              select
          action_type_id,
          description
                from ame_action_types
                where
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
         order by description;
      tempIndex integer;
            begin
        tempIndex := 1;
        for tempActionType in actionTypeCursor loop
          actionTypeIdsOut(tempIndex) := tempActionType.action_type_id;
          actionTypeDescriptionsOut(tempIndex) := tempActionType.description;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeDescriptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypeIdsOut := ame_util.emptyStringList;
          actionTypeDescriptionsOut := ame_util.emptyStringList;
          raise;
    end getActionTypeDescriptions;
  procedure getActionTypeUsages(actionTypeIdIn in integer,
                                ruleTypesOut out nocopy ame_util.stringList) as
    cursor getRuleTypesCur(actionTypeIdIn in integer) is
      select rule_type
        from ame_action_type_usages
        where action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by rule_type;
    tempIndex integer;
      begin
        tempIndex := 1;
        for getRuleTypesRec in getRuleTypesCur(actionTypeIdIn) loop
          ruleTypesOut(tempIndex) := getRuleTypesRec.rule_type;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeUsages',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          ruleTypesOut := ame_util.emptyStringList;
          raise;
      end getActionTypeUsages;
  procedure getActionTypeUsages2(actionTypeIdsOut out nocopy ame_util.idList,
                                 ruleTypesOut out nocopy ame_util.idList) as
    cursor getRuleTypesCur is
      select action_type_id,
             rule_type
        from ame_action_type_usages
        where
          /* There are two rows in ame_action_type_usages for list creation rules
             and list exception rules.  Only grab on row, so here we're
             eliminating the exception rule. */
          rule_type <> ame_util.exceptionRuleType and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        order by rule_type, action_type_id;
      begin
        open getRuleTypesCur;
        fetch getRuleTypesCur bulk collect
          into actionTypeIdsOut,
               ruleTypesOut;
      close getRuleTypesCur;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getActionTypeUsages2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypeIdsOut := ame_util.emptyIdList;
          ruleTypesOut := ame_util.emptyidList;
          raise;
      end getActionTypeUsages2;
  procedure getAllowedApproverTypes(actionTypeIdIn in integer,
                                    allowedApproverTypeIdsOut out nocopy ame_util.stringList,
                                    allowedApproverTypeNamesOut out nocopy ame_util.stringList) as
  cursor getApproverTypesCursor(actionTypeIdIn in integer) is
    select
      ame_approver_type_usages.approver_type_id,
      ame_approver_type_pkg.getOrigSystemDisplayName(orig_system) approver_name
      from ame_approver_types,
           ame_approver_type_usages
      where
        ame_approver_types.approver_type_id = ame_approver_type_usages.approver_type_id and
        ame_approver_type_usages.action_type_id = actionTypeIdIn and
        sysdate between
          ame_approver_types.start_date and
          nvl(ame_approver_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between
          ame_approver_type_usages.start_date and
          nvl(ame_approver_type_usages.end_date - ame_util.oneSecond, sysdate)
        order by approver_name;
  begin
    open getApproverTypesCursor(actionTypeIdIn => actionTypeIdIn);
      fetch getApproverTypesCursor bulk collect
        into allowedApproverTypeIdsOut,
             allowedApproverTypeNamesOut;
    close getApproverTypesCursor;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                  routineNameIn => 'getAllowedApproverTypes',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(action type ID ' ||
                                                      actionTypeIdIn||
                                                      ') ' ||
                                                      sqlerrm);
        allowedApproverTypeIdsOut := ame_util.emptyStringList;
        allowedApproverTypeNamesOut := ame_util.emptyStringList;
        raise;
  end getAllowedApproverTypes;
  procedure getAllowedRuleTypeLabels(allowedRuleTypesOut out nocopy ame_util.stringList,
                                     allowedRuleTypeLabelsOut out nocopy ame_util.stringList) as
    begin
      allowedRuleTypesOut(1) := ame_util.preListGroupRuleType;
      allowedRuleTypesOut(2) := ame_util.authorityRuleType; -- or ame_util.exceptionRuleType
      allowedRuleTypesOut(3) := ame_util.listModRuleType;
      allowedRuleTypesOut(4) := ame_util.substitutionRuleType;
      allowedRuleTypesOut(5) := ame_util.postListGroupRuleType;
      allowedRuleTypesOut(6) := ame_util.productionRuleType;
      allowedRuleTypeLabelsOut(1) := ame_util.getLabel(ame_util.perFndAppId,'AME_PRE_APPROVAL');
      allowedRuleTypeLabelsOut(2) := ame_util.getLabel(ame_util.perFndAppId,'AME_CHAIN_OF_AUTHORITY');
      allowedRuleTypeLabelsOut(3) := ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_MODIFICATION2');
      allowedRuleTypeLabelsOut(4) := ame_util.getLabel(ame_util.perFndAppId,'AME_SUBSTITUTION');
      allowedRuleTypeLabelsOut(5) := ame_util.getLabel(ame_util.perFndAppId,'AME_POST_APPROVAL');
      allowedRuleTypeLabelsOut(6) := ame_util.getLabel(ame_util.perFndAppId,'AME_PRODUCTION');
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'getAllowedRuleTypeLabels',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          allowedRuleTypesOut := ame_util.emptyStringList;
          allowedRuleTypeLabelsOut := ame_util.emptyStringList;
          raise;
  end getAllowedRuleTypeLabels;
  procedure getAvailableActionTypes(applicationIdIn in integer,
                                    ruleTypeIn in integer,
                                    actionTypeIdsOut out nocopy ame_util.stringList,
                                    actionTypeDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionTypeCursor(ruleTypeIn in varchar2,
                            allowAllApproverTypesIn in varchar2,
                            allowProductionsIn in varchar2) is
      select
        ame_action_types.action_type_id action_type_id,
        ame_action_types.description description
        from
          ame_action_types,
          ame_action_type_usages
        where
          ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
          ((allowProductionsIn = ame_util.yes and ame_action_type_usages.rule_type = ame_util.productionRuleType) or
           ame_action_type_usages.rule_type = ruleTypeIn) and
          (allowAllApproverTypesIn = ame_util.yes or
             ame_action_types.action_type_id in (
               select distinct action_type_id
                 from ame_approver_type_usages
                 where
                   (approver_type_id = ame_util.anyApproverType or
                    approver_type_id in
                      (select approver_type_id
                         from ame_approver_types
                         where
                           orig_system in (ame_util.perOrigSystem, ame_util.fndUserOrigSystem) and
                           sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate))) and
                   sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate))) and
          sysdate between
            ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate
            between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
        order by upper(description);
    actionTypeIds ame_util.stringList;
    actionTypeIds2 ame_util.stringList;
    actionTypeDescriptions ame_util.stringList;
    actionTypeDescriptions2 ame_util.stringList;
                allowAllApproverTypes ame_util.stringType;
    allowProductions ame_util.stringType;
    lineItemActionTypeId integer;
    lineItemClassCount integer;
    ruleType integer;
    tempIndex integer;
    begin
      if(ruleTypeIn = ame_util.exceptionRuleType) then
        ruleType := ame_util.authorityRuleType;
      else
        ruleType := ruleTypeIn;
      end if;
      select count(*)
        into lineItemClassCount
        from ame_item_classes, ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name = ame_util.lineItemItemClassName and
          sysdate between
            ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate
            between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate);
      allowProductions := ame_util.getConfigVar(variableNameIn => ame_util.productionConfigVar,
                                                applicationIdIn => applicationIdIn);
      /*
        Transform the configuration-variable value into one of the pseudo-boolean values used by
        configuration variables, for ease of use in the cursor.
      */
      if(allowProductions = ame_util.perApproverProductions or
         allowProductions = ame_util.allProductions) then
        allowProductions := ame_util.yes;
      else
        allowProductions := ame_util.no;
      end if;
      allowAllApproverTypes := ame_util.getConfigVar(variableNameIn => ame_util.allowAllApproverTypesConfigVar,
                                                     applicationIdIn => applicationIdIn);
      open actionTypeCursor(ruleTypeIn => ruleType,
                            allowAllApproverTypesIn => allowAllApproverTypes,
                            allowProductionsIn => allowProductions);
      if(lineItemClassCount > 0) then
                          fetch actionTypeCursor bulk collect
          into
            actionTypeIdsOut,
            actionTypeDescriptionsOut;
        close actionTypeCursor;
      else
        lineItemActionTypeId :=
                                  getActionTypeIdByName(actionTypeNameIn => ame_util.lineItemJobLevelTypeName);
        fetch actionTypecursor bulk collect
          into
            actionTypeIds,
            actionTypeDescriptions;
        close actionTypeCursor;
        for i in 1 .. actionTypeIds.count loop
          if(actionTypeIds(i) <> lineItemActionTypeId) then
            actionTypeIds2(i) := actionTypeIds(i);
            actionTypeDescriptions2(i) := actionTypeDescriptions(i);
          end if;
        end loop;
        ame_util.compactStringList(stringListInOut => actionTypeIds2);
        ame_util.compactStringList(stringListInOut => actionTypeDescriptions2);
                          actionTypeIdsOut := actionTypeIds2;
                          actionTypeDescriptionsOut := actionTypeDescriptions2;
                        end if;
                        exception
          when others then
            rollback;
            ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                      routineNameIn => 'getAvailableActionTypes',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => sqlerrm);
            actionTypeIdsOut := ame_util.emptyStringList;
            actionTypeDescriptionsOut := ame_util.emptyStringList;
            raise;
    end getAvailableActionTypes;
  procedure getAvailCombActionTypes(applicationIdIn in integer,
                                    subOrListModActsForCombRuleIn in varchar2,
                                    actionTypeIdsOut out nocopy ame_util.stringList,
                                    actionTypeDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionTypeCursor(allowAllApproverTypesIn in varchar2,
                            allowProductionsIn in varchar2,
                            subOrListModActsForCombRuleIn in varchar2) is
      select
        ame_action_types.action_type_id action_type_id,
        ame_action_types.description description
        from
          ame_action_types,
          ame_action_type_usages
        where
          ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
          ((allowProductionsIn = ame_util.yes and
            ame_action_type_usages.rule_type = ame_util.productionRuleType) or
           (subOrListModActsForCombRuleIn = ame_util.no and
            ame_action_type_usages.rule_type in
              (ame_util.authorityRuleType,
               ame_util.preListGroupRuleType,
               ame_util.postListGroupRuleType)) or
           (subOrListModActsForCombRuleIn = ame_util.yes and
            ame_action_type_usages.rule_type in
              (ame_util.listModRuleType,
               ame_util.substitutionRuleType))) and
          (allowAllApproverTypesIn = ame_util.yes or
             ame_action_types.action_type_id in (
               select distinct action_type_id
                 from ame_approver_type_usages
                 where
                   (approver_type_id = ame_util.anyApproverType or
                    approver_type_id in
                      (select approver_type_id
                         from ame_approver_types
                         where
                           orig_system in (ame_util.perOrigSystem, ame_util.fndUserOrigSystem) and
                           sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate))) and
                   sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate))) and
          sysdate between
            ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate
            between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
        order by upper(description);
    actionTypeIds ame_util.stringList;
    actionTypeIds2 ame_util.stringList;
    actionTypeDescriptions ame_util.stringList;
    actionTypeDescriptions2 ame_util.stringList;
    allowProductions ame_util.stringType;
    allowAllApprovertypes ame_util.stringType;
    lineItemActionTypeId integer;
    lineItemClassCount integer;
    begin
      select count(*)
        into lineItemClassCount
        from ame_item_classes, ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name = ame_util.lineItemItemClassName and
          sysdate between
            ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate
            between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate);
      allowProductions := ame_util.getConfigVar(variableNameIn => ame_util.productionConfigVar,
                                                applicationIdIn => applicationIdIn);
      /*
        Transform the configuration-variable value into one of the pseudo-boolean values used by
        configuration variables, for ease of use in the cursor.
      */
      if(allowProductions = ame_util.perApproverProductions or
         allowProductions = ame_util.allProductions) then
        allowProductions := ame_util.yes;
      else
        allowProductions := ame_util.no;
      end if;
      allowAllApproverTypes := ame_util.getConfigVar(variableNameIn => ame_util.allowAllApproverTypesConfigVar,
                                                     applicationIdIn => applicationIdIn);
      open actionTypeCursor(allowAllApproverTypesIn => allowAllApproverTypes,
                            allowProductionsIn => allowProductions,
                            subOrListModActsForCombRuleIn => subOrListModActsForCombRuleIn);
      --
      if(lineItemClassCount > 0) then
                          fetch actionTypeCursor bulk collect
          into
            actionTypeIdsOut,
            actionTypeDescriptionsOut;
        close actionTypeCursor;
      else
        lineItemActionTypeId :=
                                  getActionTypeIdByName(actionTypeNameIn => ame_util.lineItemJobLevelTypeName);
        fetch actionTypecursor bulk collect
          into
            actionTypeIds,
            actionTypeDescriptions;
        close actionTypeCursor;
        for i in 1 .. actionTypeIds.count loop
          if(actionTypeIds(i) <> lineItemActionTypeId) then
            actionTypeIds2(i) := actionTypeIds(i);
            actionTypeDescriptions2(i) := actionTypeDescriptions(i);
          end if;
        end loop;
        ame_util.compactStringList(stringListInOut => actionTypeIds2);
        ame_util.compactStringList(stringListInOut => actionTypeDescriptions2);
                          actionTypeIdsOut := actionTypeIds2;
                          actionTypeDescriptionsOut := actionTypeDescriptions2;
                        end if;
      exception
          when others then
            rollback;
            ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                      routineNameIn => 'getAvailCombActionTypes',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => sqlerrm);
            actionTypeIdsOut := ame_util.emptyStringList;
            actionTypeDescriptionsOut := ame_util.emptyStringList;
            raise;
    end getAvailCombActionTypes;
  procedure incrementActionTypeOrdNumbers(applicationIdIn in integer,
                                          actionTypeIdIn in integer,
                                          orderNumberIn in integer,
                                          finalizeIn in boolean default false) as
    cursor orderNumberCursor(applicationIdIn in integer,
                                         actionTypeIdIn in integer,
                                                                                                                 orderNumberIn in integer,
                                                                                                                 ruleTypeIn in integer) is
      select ame_action_type_config.action_type_id,
                               ame_action_type_config.order_number
        from ame_action_type_config,
             ame_action_type_usages
        where
          ame_action_type_config.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_type_config.application_id = applicationIdIn and
          ame_action_type_config.action_type_id <> actionTypeIdIn and
          ame_action_type_config.order_number >= orderNumberIn and
          ame_action_type_usages.rule_type = ruleTypeIn and
          sysdate between ame_action_type_config.start_date and
            nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
          order by order_number;
                actionTypeIds ame_util.idList;
                chainOrderingMode ame_util.charType;
                currentUserId integer;
    orderNumbers ame_util.idList;
    processingDate date;
    ruleType integer;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
                        processingDate := sysdate;
                        ruleType := getAllowedRuleType(actionTypeIdIn => actionTypeIdIn);
      open orderNumberCursor(applicationIdIn => applicationIdIn,
                                               actionTypeIdIn => actionTypeIdIn,
                                                                                                                 orderNumberIn => orderNumberIn,
                                                                                                                 ruleTypeIn => ruleType);
        fetch orderNumberCursor bulk collect
        into actionTypeIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. actionTypeIds.count loop
        votingRegime := getVotingRegime(actionTypeIdIn => actionTypeIds(i),
                                                                applicationIdIn => applicationIdIn);
        chainOrderingMode := getChainOrderingMode(actionTypeIdIn => actionTypeIds(i),
                                                  applicationIdIn => applicationIdIn);
                                update ame_action_type_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            action_type_id = actionTypeIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationIdIn,
                 actionTypeIds(i),
                 votingRegime,
                 (orderNumbers(i) + 1),
                 chainOrderingMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
                        if(finalizeIn) then
        commit;
      end if;
      exception
       when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'incrementActionTypeOrdNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end incrementActionTypeOrdNumbers;
  procedure newActionTypeConfig(applicationIdIn in integer,
                                      actionTypeIdIn in integer,
                                ruleTypeIn in integer,
                                orderNumberUniqueIn in varchar2,
                                orderNumberIn in integer,
                                chainOrderingModeIn in varchar2,
                                votingRegimeIn in varchar2,
                                finalizeIn in boolean default false) as
    cursor applicationIdCursor is
      select application_id
        from ame_calling_apps
        where
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_id;
    applicationId integer;
                applicationIds ame_util.idList;
    chainOrderingMode ame_util.charType;
    currentUserId integer;
    maxOrderNumber integer;
    orderNumber ame_action_type_config.order_number%type;
    processingDate date;
    tempCount integer;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      maxOrderNumber :=
                          ame_action_pkg.getActionTypeMaxOrderNumber(applicationIdIn => applicationIdIn,
                                                                           ruleTypeIn => ruleTypeIn);
      open applicationIdCursor;
      fetch applicationIdCursor bulk collect
        into
          applicationIds;
      close applicationIdCursor;
      for i in 1 .. applicationIds.count loop
        if(applicationIds(i) = applicationIdIn) then
          applicationId := applicationIds(i);
                                        orderNumber := orderNumberIn;
          votingRegime := votingRegimeIn;
          chainOrderingMode := chainOrderingModeIn;
        else
          applicationId := applicationIds(i);
                                  votingRegime := ame_util.serializedVoting;
                                  chainOrderingMode := ame_util.serialChainsMode;
          select count(*)
            into tempCount
            from ame_action_type_config
            where
              application_id = applicationIds(i) and
              sysdate between start_date and
                nvl(end_date - ame_util.oneSecond, sysdate);
          if(tempCount = 0) then
            orderNumber := 1;
          else
            select (nvl(max(order_number), 0) + 1)
              into orderNumber
              from ame_action_type_config,
                   ame_action_type_usages
              where
                ame_action_type_config.action_type_id = ame_action_type_usages.action_type_id and
                ame_action_type_config.application_id = applicationIds(i) and
                ame_action_type_usages.rule_type = ruleTypeIn and
                sysdate between ame_action_type_config.start_date and
                  nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
                sysdate between ame_action_type_usages.start_date and
                  nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate);
          end if;
        end if;
                                insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationId,
                 actionTypeIdIn,
                 votingRegime,
                 orderNumber,
                 chainOrderingMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
      if(orderNumberUniqueIn = ame_util.yes) then
        if(orderNumberIn <> (maxOrderNumber + 1)) then
          incrementActionTypeOrdNumbers(applicationIdIn => applicationIdIn,
                                        actionTypeIdIn => actionTypeIdIn,
                                        orderNumberIn => orderNumberIn);
        end if;
                        end if;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'newActionTypeConfig',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
    end newActionTypeConfig;
  procedure newActionTypeUsage(actionTypeIdIn in integer,
                               ruleTypeIn in integer,
                               finalizeIn in boolean default false,
                               processingDateIn in date default null) as
    createdBy integer;
    currentUserId integer;
    processingDate date;
    tempCount integer;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
        into tempCount
        from ame_action_type_usages
          where
            action_type_id = actionTypeIdIn and
            created_by = ame_util.seededDataCreatedById;
       if(tempCount > 0) then
         createdBy := ame_util.seededDataCreatedById;
       else
         createdBy := currentUserId;
       end if;
      if(ruleTypeIn = ame_util.exceptionRuleType) then
        /* chain of authority so insert two rows,
           one for list-creation and one for list-exception */
        for i in 1 .. 2 loop
          insert into ame_action_type_usages
                                  (action_type_id,
                                   rule_type,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   end_date)
           values  (actionTypeIdIn,
                    i,
                    createdBy,
                    processingDate,
                    currentUserId,
                    processingDate,
                    currentUserId,
                    processingDate,
                    null);
        end loop;
      else
        insert into ame_action_type_usages
                                  (action_type_id,
                                   rule_type,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   end_date)
           values(actionTypeIdIn,
                  ruleTypeIn,
                  createdBy,
                  processingDate,
                  currentUserId,
                  processingDate,
                  currentUserId,
                  processingDate,
                  null);
      end if;
      if(finalizeIn) then
        commit;
      end if;
      exception
          when others then
            rollback;
            ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                      routineNameIn => 'newActionTypeUsage',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
            raise;
      end newActionTypeUsage;
  procedure remove(actionTypeIdIn in integer,
                   finalizeIn in boolean default false,
                   parentVersionStartDateIn in date,
                   processingDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_action_types
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor applicationIdCursor is
      select application_id
        from ame_calling_apps
        where
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        order by application_id;
                applicationIds ame_util.idList;
                currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    objectVersionNoDataException exception;
    orderNumber integer;
    startDate date;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into startDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> startDate) then
            close startDateCursor;
            raise ame_util.objectVersionException;
          end if;
      end if;
      if(actionTypeIsInUse(actionTypeIdIn)) then
        raise inUseException;
      end if;
      open applicationIdCursor;
        fetch applicationIdCursor bulk collect
          into applicationIds;
      close applicationIdCursor;
                        for i in 1 .. applicationIds.count loop
        select order_number
          into orderNumber
          from ame_action_type_config
          where
            application_id = applicationIds(i) and
            action_type_id = actionTypeIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        if(orderNumberUnique(applicationIdIn => applicationIds(i),
                             orderNumberIn => orderNumber,
                                                                                                                 actionTypeIdIn => actionTypeIdIn)) then
          /* subtract 1 from the order number for those above the one being deleted */
          decrementActionTypeOrdNumbers(applicationIdIn => applicationIds(i),
                                        actionTypeIdIn => actionTypeIdIn,
                                        orderNumberIn => orderNumber,
                                        finalizeIn => false);
        end if;
      end loop;
      currentUserId := ame_util.getCurrentUserId;
      update ame_action_types
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          action_type_id = actionTypeIdIn and
          processingDate between start_date and
            nvl(end_date - ame_util.oneSecond, processingDate);
      update ame_action_type_config
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              action_type_id = actionTypeIdIn and
              processingDate between start_date and
                nvl(end_date - ame_util.oneSecond, processingDate);
      update ame_approver_type_usages
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              action_type_id = actionTypeIdIn and
              processingDate between start_date and
                nvl(end_date - ame_util.oneSecond, processingDate);
                        update ame_mandatory_attributes
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          action_type_id = actionTypeIdIn and
          processingDate between start_date and
            nvl(end_date - ame_util.oneSecond, processingDate);
        removeActionTypeUsages(actionTypeIdIn => actionTypeIdIn,
                               finalizeIn => false);
      if(finalizeIn) then
        close startDateCursor;
        commit;
      end if;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
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
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'remove',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when inUseException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400148_ACT_REM_APPR_ASSOC');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
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
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'remove',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end remove;
  procedure removeAction(actionTypeIdIn in integer,
                         actionIdIn in ame_util.idList default ame_util.emptyIdList,
                         childVersionStartDatesIn in ame_util.dateList,
                         finalizeIn in boolean default false,
                         processingDateIn in date default null) as
    cursor startDateCursor2(actionIdIn in integer) is
      select start_date
        from ame_actions
        where
          action_id = actionIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    actionTypeDescription ame_action_types.description%type;
    actionTypeDescQuery ame_action_types.description_query%type;
    actionTypeDynamicDesc ame_action_types.dynamic_description%type;
    actionTypeId ame_action_types.action_type_id%type;
    actionTypeName ame_action_types.name%type;
    actionTypeProcedureName ame_action_types.procedure_name%type;
    currentUserId integer;
    deleteCount integer;
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
      currentUserId := ame_util.getCurrentUserId;
      deleteCount := actionIdIn.count;
      for i in 1..deleteCount loop
        open startDateCursor2(actionIdIn(i));
          fetch startDateCursor2 into startDate;
          if startDateCursor2%notfound then
            raise objectVersionNoDataException;
          end if;
          if(childVersionStartDatesIn(i) = startDate) then
            if(isInUse(actionIdIn(i))) then
              raise inUseException;
            end if;
            update ame_actions
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              action_id = actionIdIn(i) and
              processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
          else
            close startDateCursor2;
            raise ame_util.objectVersionException;
          end if;
          close startDateCursor2;
        end loop;
      actionTypeName := getActionTypeName(actionTypeIdIn => actionTypeIdIn);
      actionTypeProcedureName := getActionTypeProcedureName(actionTypeIdIn => actionTypeIdIn);
      actionTypeDescription := getActionTypeDescription(actionTypeIdIn => actionTypeIdIn);
      actionTypeDescQuery := getActionTypeDescQuery(actionTypeIdIn => actionTypeIdIn);
      actionTypeDynamicDesc := getActionTypeDynamicDesc(actionTypeIdIn => actionTypeIdIn);
      update ame_action_types
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          action_type_id = actionTypeIdIn and
          processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
      actionTypeId := new(nameIn => actionTypeName,
                          procedureNameIn => actionTypeProcedureName,
                          descriptionIn => actionTypeDescription,
                          actionTypeIdIn => actionTypeIdIn,
                          descriptionQueryIn => actionTypeDescQuery,
                          dynamicDescriptionIn => actionTypeDynamicDesc,
                          finalizeIn => false,
                          processingDateIn => processingDate);
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'removeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'removeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when inUseException then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                          messageNameIn => 'AME_400147_ACT_APR_IN_USE');
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'removeAction',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'removeAction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeAction;
  procedure removeActionTypeUsage(actionTypeIdIn in integer,
                                  ruleTypeIn in integer,
                                  finalizeIn in boolean default false,
                                  processingDateIn in date default null) as
    currentUserId integer;
    processingDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      update ame_action_type_usages
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          action_type_id = actionTypeIdIn and
          rule_type = ruleTypeIn and
          processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                    routineNameIn => 'removeActionTypeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeActionTypeUsage;
  procedure removeActionTypeUsages(actionTypeIdIn in integer,
                                   finalizeIn in boolean default false,
                                   processingDateIn in date default null) as
    cursor getRuleTypesCur(actionTypeIdIn in integer) is
      select rule_type
        from ame_action_type_usages
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by 1;
     processingDate date;
    begin
      processingDate := sysdate;
      for getRuleTypesRec in getRuleTypesCur(actionTypeIdIn) loop
        removeActionTypeUsage(actionTypeIdIn => actionTypeIdIn,
                              ruleTypeIn => getRuleTypesRec.rule_type,
                              finalizeIn => finalizeIn,
                              processingDateIn => processingDate);
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_action_pkg',
                                  routineNameIn => 'removeActionTypeUsages',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end removeActionTypeUsages;
end AME_action_pkg;

/
