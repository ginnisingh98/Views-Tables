--------------------------------------------------------
--  DDL for Package Body AME_APPROVAL_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVAL_GROUP_PKG" as
/* $Header: ameogrou.pkb 120.1 2006/08/04 16:03:47 pvelugul noship $ */
  /* forward declarations */
  /*
    getNestedMembers returns the membership of an approval group, including nested
    groups, down to the first dynamic group in each nesting recursion.  When a
    dynamic group is encountered, its query string is copied into queryStringOut.
    If the target group itself is dynamic, its query string is copied into
    queryStringOut.  If effectiveDateIn is not null, setGroupMembers uses the
    ame_approval_group_items entries with that effective date.  (This enables a bug
    fix in amem0015.sql.)
  */
  procedure getNestedMembers(groupIdIn in integer,
                             effectiveDateIn in date default null,
                             parameterNamesOut out nocopy  ame_util.stringList,
                             parametersOut out nocopy ame_util.stringList,
                             orderNumbersOut out nocopy ame_util.idList,
                             queryStringsOut out nocopy ame_util.longestStringList);
  /*
    updateDependentGroups updates ame_approval_group_members for the group with
    group ID groupIdIn, and all groups depending on it (explicitly or implicitly).
    If deleteGroupIn is true, updateDependentGroups also removes (end-dates) the
    group with ID groupIdIn from dependent group's item lists.
  */
  procedure updateDependentGroups(groupIdIn in integer,
                                  deleteGroupIn in boolean default false);
  /* functions and procedures */
  function isSeeded(approvalGroupIdIn in integer) return boolean as
    createdByValue integer;
begin
      select created_by
        into createdByValue
        from ame_approval_groups
        where
	approval_group_id = approvalGroupIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(createdByValue = 1) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'isSeeded',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(Approval Group ' ||
                                                        approvalGroupIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isSeeded;

  function getApprovalGroupItemMaxOrdNum(approvalGroupIdIn in integer) return integer as
    orderNumber integer;
    begin
      select nvl(max(order_number), 0)
        into orderNumber
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupItemMaxOrdNum',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApprovalGroupItemMaxOrdNum;
  function getApprovalGroupMaxOrderNumber(applicationIdIn in integer) return integer as
    orderNumber integer;
    begin
      select nvl(max(order_number), 0)
        into orderNumber
        from ame_approval_group_config
        where
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupMaxOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApprovalGroupMaxOrderNumber;
  function getApprovalGroupOrderNumber(applicationIdIn in integer,
                                       approvalGroupIdIn in integer) return integer as
    orderNumber integer;
    begin
      select order_number
        into orderNumber
        from ame_approval_group_config
        where
          approval_group_id = approvalGroupIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400356_APPR_GROUP_ID_ERR',
                                     tokenNameOneIn => 'GROUPID',
                                     tokenValueOneIn => to_char(approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getApprovalGroupOrderNumber;
  function getDescription(approvalGroupIdIn in integer) return varchar2 as
    description ame_approval_groups.description%type;
    begin
      select description
        into description
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     ||' '|| sqlerrm);
          raise;
          return(null);
    end getDescription;
  function getId(nameIn in varchar2) return integer as
    approvalGroupId integer;
    begin
      select approval_group_id
        into approvalGroupId
        from ame_approval_groups
        where
          upper(name) = upper(nameIn) and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(approvalGroupId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => nameIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getId;
  function getItemApprovalGroupId(approvalGroupItemIdIn in integer) return integer as
    approvalGroupId integer;
    begin
      select approval_group_id
        into approvalGroupId
        from ame_approval_group_items
        where
          approval_group_item_id = approvalGroupItemIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(approvalGroupId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getItemApprovalGroupId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400355_APPR_GRPITEMID_ERR',
                                     tokenNameOneIn => 'GROUPITEMID',
                                     tokenValueOneIn => approvalGroupItemIdIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getItemApprovalGroupId;
  function getItemId(approvalGroupIdIn in integer,
                     parameterIn in varchar2,
                     parameterNameIn in varchar2) return integer as
    itemId integer;
    begin
      select approval_group_item_id
        into itemId
        from ame_approval_group_items
        where
          upper(parameter) = upper(parameterIn) and
          (upper(parameter_name) = upper(parameterNameIn)) and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(itemId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getItemId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getItemId;
  function getItemParameter(approvalGroupItemIdIn in integer) return varchar2 as
    parameter ame_approval_group_items.parameter%type;
    begin
      select parameter
        into parameter
        from ame_approval_group_items
        where
          approval_group_item_id = approvalGroupItemIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(parameter);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getItemParameter',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400355_APPR_GRPITEMID_ERR',
                                     tokenNameOneIn => 'GROUPITEMID',
                                     tokenValueOneIn => approvalGroupItemIdIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getItemParameter;
  function getItemParameterName(approvalGroupItemIdIn in integer) return varchar2 as
    parameterName ame_approval_group_items.parameter_name%type;
    begin
      select parameter_name
        into parameterName
        from ame_approval_group_items
        where
          approval_group_item_id = approvalGroupItemIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(parameterName);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getItemParameterName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400355_APPR_GRPITEMID_ERR',
                                     tokenNameOneIn => 'GROUPITEMID',
                                     tokenValueOneIn => approvalGroupItemIdIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getItemParameterName;
  function getName(approvalGroupIdIn in integer,
                  effectiveDateIn in date default sysdate) return varchar2 as
    name ame_approval_groups.name%type;
    begin
      if(approvalGroupIdIn = ame_util.nullInsertionGroupOrChainId) then
        return('''no approval group'' and ''no chain of authority''');
      end if;
      select name
        into name
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          nvl(effectiveDateIn, sysdate) between start_date and
                    nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(name);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400356_APPR_GROUP_ID_ERR',
                                     tokenNameOneIn => 'GROUPID',
                                     tokenValueOneIn => to_char(approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getName;
  function getQueryString(approvalGroupIdIn in integer,
                         effectiveDateIn in date default sysdate) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    queryString ame_approval_groups.query_string%type;
    begin
      select query_string
        into queryString
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          nvl(effectiveDateIn, sysdate) between start_date and
                  nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(queryString);
      exception
        when no_data_found then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
              messageNameIn   => 'AME_400194_APG_NO_USAGE',
              tokenNameOneIn  => 'APPROVAL_GROUP',
              tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn,
                                         effectiveDateIn => effectiveDateIn));
            ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                      routineNameIn => 'getQueryString',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
            return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getQueryString',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn,
                                                               effectiveDateIn => effectiveDateIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
  end getQueryString;
  function getIsStatic(approvalGroupIdIn in integer) return varchar2 as
    isStatic ame_approval_groups.is_static%type;
    begin
      select is_static
        into isStatic
        from ame_approval_groups
        where approval_group_id = approvalGroupIdIn and
        sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(isStatic);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getIsStatic',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
  end getIsStatic;
  function getChildVersionStartDate(approvalGroupIdIn integer,
                                    applicationIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_approval_group_config
        where
          approval_group_id = approvalGroupIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getChildVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
  end getChildVersionStartDate;
  function getParentVersionStartDate(approvalGroupIdIn integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getParentVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
  end getParentVersionStartDate;
  function getItemOrderNumber(approvalGroupItemIdIn in integer) return integer as
    orderNumber     ame_approval_group_items.order_number%type;
    begin
      select order_number
        into orderNumber
        from ame_approval_group_items
        where
           approval_group_item_id = approvalGroupItemIdIn and
           sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getItemOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400355_APPR_GRPITEMID_ERR',
                                     tokenNameOneIn => 'GROUPITEMID',
                                     tokenValueOneIn => approvalGroupItemIdIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getItemOrderNumber;
  function getOrderNumberCount(approvalGroupIdIn in integer,
                               newGroupMemberIn in boolean) return integer as
    orderCount integer;
    begin
      select count(*)
        into orderCount
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      /* If new group member, need to include an additional order number
         within the select list. */
      if(newGroupMemberIn) then
        return(orderCount + 1);
      end if;
      /* The user is editing the order number, so just return the orderCount. */
      return(orderCount);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getOrderNumberCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end getOrderNumberCount;
  function getVotingRegime(approvalGroupIdIn in integer,
                           applicationIdIn in integer) return varchar2 as
    votingRegime ame_approval_group_config.voting_regime%type;
    begin
      select voting_regime
        into votingRegime
        from ame_approval_group_config
        where
           approval_group_id = approvalGroupIdIn and
           application_id = applicationIdIn and
           sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(votingRegime);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getVotingRegime',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getVotingRegime;
  function groupIsInGroup(groupIdIn in integer,
                          possiblyNestedGroupIdIn in integer) return boolean as
    cursor groupMemberCursor(approvalGroupIdIn in integer) is
      select
        parameter,
        parameter_name
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
    tempGroupId integer;
    begin
      for tempGroup in groupMemberCursor(approvalGroupIdIn => groupIdIn) loop
        if(tempGroup.parameter_name = ame_util.approverOamGroupId) then
          tempGroupId := to_number(tempGroup.parameter);
          if(tempGroupId = possiblyNestedGroupIdIn) then
            return(true);
          elsif(groupIsInGroup(groupIdIn => tempGroupId,
                               possiblyNestedGroupIdIn => possiblyNestedGroupIdIn)) then
            return(true);
          end if;
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'groupIsInGroup',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(true);
    end groupIsInGroup;

function hasGroupChanged2(approvalGroupIdIn in integer,
                            nameIn            in varchar2 default null,
                            descriptionIn     in varchar2 default null,
                            isStaticIn        in varchar2 default null,
                            queryStringIn     in varchar2 default null) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_approval_groups
       where ame_approval_groups.approval_group_id = approvalGroupIdIn
         and (nameIn is null or upper(name) = upper(nameIn))
         and (descriptionIn is null or upper(description) = upper(descriptionIn))
         and is_static = isStaticIn
         and (queryStringIn is null or upper(query_string) = upper(queryStringIn))
         and sysdate between ame_approval_groups.start_date
         and nvl(ame_approval_groups.end_date - ame_util.oneSecond, sysdate);
      if(tempCount = 0) then
        return(true);
      else
        return(false);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'hasGroupChanged2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
end hasGroupChanged2;

  function hasGroupChanged(approvalGroupIdIn in integer,
                           nameIn in varchar2 default null,
                           descriptionIn in varchar2 default null,
                           isStaticIn in varchar2 default null,
                           queryStringIn in varchar2 default null,
                           orderNumberIn in integer,
                           orderNumberUniqueIn in varchar2,
                           votingRegimeIn in varchar2,
                           applicationIdIn in integer) return boolean as
    groupHasBeenUpdated boolean;
    oldOrderNumberUnique boolean;
    tempCount integer;
    begin
      oldOrderNumberUnique := orderNumberUnique(applicationIdIn => applicationIdIn,
                                                orderNumberIn => orderNumberIn);

      /* If the old order number is not unique, orderNumberUniqueIn = ame_util.yes,
         then group has been updated. */
      if(not oldOrderNumberUnique and orderNumberUniqueIn = ame_util.yes) then
        groupHasBeenUpdated := true;
      else
        groupHasBeenUpdated := false;
      end if;
      select count(*)
        into tempCount
        from
          ame_approval_groups,
          ame_approval_group_config
        where
          ame_approval_groups.approval_group_id = ame_approval_group_config.approval_group_id and
          ame_approval_groups.approval_group_id = approvalGroupIdIn and
          ame_approval_group_config.application_id = applicationIdIn and
          ame_approval_group_config.voting_regime = votingRegimeIn and
          ame_approval_group_config.order_number = orderNumberIn and
          (nameIn is null or upper(name) = upper(nameIn)) and
          (descriptionIn is null or upper(description) = upper(descriptionIn)) and
          is_static = isStaticIn and
          (queryStringIn is null or upper(query_string) = upper(queryStringIn)) and
           sysdate between ame_approval_groups.start_date and
             nvl(ame_approval_groups.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_approval_group_config.start_date and
             nvl(ame_approval_group_config.end_date - ame_util.oneSecond, sysdate);
      if(tempCount = 0 or groupHasBeenUpdated) then
        return(true);
      else
        return(false);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'hasGroupChanged',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end hasGroupChanged;
  function isInUse(approvalGroupIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from
          ame_actions,
          ame_action_types,
          ame_action_usages
        where
          ame_actions.parameter = to_char(approvalGroupIdIn) and
          ame_action_usages.action_id = ame_actions.action_id and
          ame_actions.action_type_id = ame_action_types.action_type_id and
          ame_action_types.name in (ame_util.preApprovalTypeName,
                                    ame_util.postApprovalTypeName,
                                    ame_util.groupChainApprovalTypeName) and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          ((sysdate between ame_action_usages.start_date and
                nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
             (sysdate < ame_action_usages.start_date and
                ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                              ame_action_usages.start_date + ame_util.oneSecond)));
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'isInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(true);
    end isInUse;
  function isStatic(approvalGroupIdIn in integer,
                    effectiveDateIn in date default sysdate) return boolean as
    isStatic ame_approval_groups.is_static%type;
    begin
      select is_static
        into isStatic
        from ame_approval_groups
        where approval_group_id = approvalGroupIdIn and
        nvl(effectiveDateIn, sysdate) between start_date and
                      nvl(end_date - ame_util.oneSecond, sysdate);
      if(isStatic = ame_util.booleanTrue) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'isStatic',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn,
                                                                effectiveDateIn => effectiveDateIn))
                                     || ' ' || sqlerrm);
          raise;
          return(false);
    end isStatic;
  function itemOrderNumberUnique(approvalGroupIdIn in integer,
                                 orderNumberIn in integer) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          order_number = orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if(tempCount > 1) then
        return(false);
      else
        return(true);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'itemOrderNumberUnique',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
  end itemOrderNumberUnique;
  function new(nameIn in varchar2,
               descriptionIn in varchar2,
               isStaticIn in varchar2 default null,
               queryStringIn in varchar2 default null,
               newStartDateIn in date default null,
               approvalGroupIdIn in integer default null,
               finalizeIn in boolean default false,
               updateActionIn in boolean default false) return integer as
    approvalGroupId integer;
    actionId ame_actions.action_id%type;
    actionTypeId ame_action_types.action_type_id%type;
    actionDescription ame_actions.description%type;
    createdBy integer;
    currentUserId integer;
    descriptionLengthException exception;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    nameLengthException exception;
    nullNameDescException exception;
    parentVersionStartDate date;
    processingDate date;
    tempCount integer;
    begin
      if(nameIn is null or descriptionIn is null) then
        raise nullNameDescException;
      end if;
      processingDate := sysdate;
      begin
        select approval_group_id
          into approvalGroupId
          from ame_approval_groups
          where
            (approvalGroupIdIn is null or approval_group_id <> approvalGroupIdIn) and
            upper(name) = upper(nameIn) and
            sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if approvalGroupId is not null then
        raise_application_error(-20001,
        ame_util.getMessage(applicationShortNameIn => 'PER',
        messageNameIn => 'AME_400195_APG_ALRDY_EXISTS'));
      end if;
      exception
          when no_data_found then null;
      end;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_approval_groups',
                                    columnNameIn => 'name',
                                    argumentIn => nameIn)) then
        raise nameLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_approval_groups',
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
      if(approvalGroupIdIn is null) then
        createdBy := currentUserId;
        select ame_approval_groups_s.nextval into approvalGroupId from dual;
      else
        approvalGroupId := approvalGroupIdIn;
        select count(*)
         into tempCount
         from ame_approval_groups
           where
             approval_group_id = approvalGroupIdIn and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      /* keeps this end date associated with the endDate from proc change */
      endDate := nvl(newStartDateIn, sysdate) ;
      /* insert into ame_actions proper values for the approval group */
      if(approvalGroupIdIn is null or updateActionIn) then
        for i in 1..3 loop
          if i = 1 then
            actionTypeId := ame_action_pkg.getPreApprovalActionTypeId;
            actionDescription := ame_util.getLabel(ame_util.perFndAppId,'AME_REQ_PRE_APPROVAL') || ' ' ||nameIn;
            parentVersionStartDate :=
              ame_util.versionStringToDate(stringDateIn => ame_action_pkg.getParentVersionStartDate(actionTypeIdIn => actionTypeId));
          elsif i = 2 then
            actionTypeId := ame_action_pkg.getPostApprovalActionTypeId;
            actionDescription := ame_util.getLabel(ame_util.perFndAppId,'AME_REQ_POST_APPROVAL') || ' ' ||nameIn;
            parentVersionStartDate :=
              ame_util.versionStringToDate(stringDateIn => ame_action_pkg.getParentVersionStartDate(actionTypeIdIn => actionTypeId));
          else
            actionTypeId := ame_action_pkg.getGroupChainActionTypeId;
            actionDescription := ame_util.getLabel(ame_util.perFndAppId,'AME_REQ_APPROVAL') || ' ' ||nameIn;
            parentVersionStartDate :=
              ame_util.versionStringToDate(stringDateIn => ame_action_pkg.getParentVersionStartDate(actionTypeIdIn => actionTypeId));
          end if;
          if(updateActionIn) then
            select action_id into actionId
              from ame_actions
                where
                  parameter = to_char(approvalGroupId) and
                  action_type_id = actionTypeId and
                  sysdate between start_date and
                    nvl(end_date - ame_util.oneSecond, sysdate)
              for update of end_date;
            update ame_actions
              set
                 last_updated_by = currentUserId,
                 last_update_date = processingDate,
                 last_update_login = currentUserId,
                 end_date = processingDate
                where
                  parameter = to_char(approvalGroupId) and
                      action_type_id = actionTypeId and
                  processingDate between start_date and
                      nvl(end_date - ame_util.oneSecond, processingDate) ;
            actionId := ame_action_pkg.newAction(actionTypeIdIn => actionTypeId,
                                                 descriptionIn => actionDescription,
                                                 updateParentObjectIn => true,
                                                 parameterIn => approvalGroupId,
                                                 newStartDateIn => processingDate,
                                                 finalizeIn => true,
                                                 parentVersionStartDateIn => parentVersionStartDate,
                                                 actionIdIn => actionId);
          else
            actionId := ame_action_pkg.newAction(actionTypeIdIn => actionTypeId,
                                                 descriptionIn => actionDescription,
                                                 updateParentObjectIn => true,
                                                 parameterIn => approvalGroupId,
                                                 newStartDateIn => processingDate,
                                                 parentVersionStartDateIn => parentVersionStartDate,
                                                 finalizeIn => true);
          end if;
        end loop;
      end if;
      insert into ame_approval_groups(approval_group_id,
                                      name,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      start_date,
                                      end_date,
                                      description,
                                      query_string,
                                      is_static)
        values(approvalGroupId,
               nameIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               nvl(newStartDateIn, processingDate),
               null,
               descriptionIn,
               queryStringIn,
               isStaticIn);
      updateDependentGroups(groupIdIn => approvalGroupId);
      if(finalizeIn) then
        commit;
      end if;
      return(approvalGroupId);
      exception
        when nameLengthException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400196_APG_NAME_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_approval_groups',
                                                       columnNameIn => 'name'));
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when descriptionLengthException then
          rollback;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400197_APG_DESC_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_approval_groups',
                                                       columnNameIn => 'description'));
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when nullNameDescException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400198_APG_NAME_DESC_ENT');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'new',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => nameIn)
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end new;
  function newApprovalGroupItem(approvalGroupIdIn in integer,
                                parameterIn in varchar2,
                                parameterNameIn in varchar2,
                                approvalGroupItemIdIn in integer default null,
                                newOrderNumberIn in integer default null,
                                orderNumberUniqueIn in varchar2 default null,
                                oldOrderNumberIn in integer default null,
                                finalizeIn in boolean default false,
                                newStartDateIn in date default null,
                                newEndDateIn in date default null,
                                parentVersionStartDateIn in date) return integer as
    cursor startDateCursor is
      select start_date
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    approvalGroupItemId integer;
    badNestedGroupException exception;
    badOrderNumberException exception;
    createdBy integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    groupExistsException exception;
    maxOrderNumber integer;
    newOrderNumber integer;
    objectVersionNoDataException exception;
    oldOrderNumberUnique ame_util.stringType;
    orderNumberException exception;
    parameter ame_approval_group_items.parameter%type;
    parameterLengthException exception;
    parameterName ame_approval_group_items.parameter_name%type;
    parameterNameLengthException exception;
    startDate date;
    tempCount integer;
    tempCount2 integer;
    updateOnlyGIModified boolean;
    processingDate date;
    begin
      processingDate := sysdate;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        /* error checking */
        select count(*)
          into tempCount
          from ame_approval_group_items
          where
            (approvalGroupItemIdIn is null or approval_group_item_id <> approvalGroupItemIdIn) and
            approval_group_id = approvalGroupIdIn and
            upper(parameter) = upper(parameterIn) and
            (upper(parameter_name) = upper(parameterNameIn)) and
            sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
        if(tempCount > 0) then
          raise groupExistsException;
        end if;
        if(ame_util.isArgumentTooLong(tableNameIn => 'ame_approval_group_items',
                                      columnNameIn => 'parameter',
                                      argumentIn => parameterIn)) then
          raise parameterLengthException;
        end if;
        if(ame_util.isArgumentTooLong(tableNameIn => 'ame_approval_group_items',
                                      columnNameIn => 'parameter_name',
                                      argumentIn => parameterNameIn)) then
          raise parameterNameLengthException;
        end if;
        /* actual work */
        currentUserId := ame_util.getCurrentUserId;
        if parentVersionStartDateIn = startDate then
          if(approvalGroupItemIdIn is null) then
            createdBy := currentUserId;
            select ame_approval_group_items_s.nextval into approvalGroupItemId from dual;
          else
            approvalGroupItemId := approvalGroupItemIdIn;
            select count(*)
              into tempCount2
              from ame_approval_group_items
                where
                  approval_group_item_id = approvalGroupItemId and
                  created_by = ame_util.seededDataCreatedById;
            if(tempCount2 > 0) then
              createdBy := ame_util.seededDataCreatedById;
            else
              createdBy := currentUserId;
            end if;
          end if;
          if(ame_approval_group_pkg.itemOrderNumberUnique(orderNumberIn => oldOrderNumberIn,
                                                          approvalGroupIdIn => approvalGroupIdIn)) then
            oldOrderNumberUnique := ame_util.yes;
          else
            oldOrderNumberUnique := ame_util.no;
          end if;
          updateOnlyGIModified := false;
          if(oldOrderNumberIn is not null) then
           /* Item order number is getting changed. */
            if(oldOrderNumberIn = newOrderNumberIn) then
              if(orderNumberUniqueIn = oldOrderNumberUnique) then
                updateOnlyGIModified := true; /* Order number not modified. */
              elsif(orderNumberUniqueIn = ame_util.yes) then
                /* Need to increment the order numbers to keep them in sequence. */
                incrementGroupItemOrderNumbers(approvalGroupIdIn => approvalGroupIdIn,
                                               approvalGroupItemIdIn => approvalGroupItemIdIn,
                                               orderNumberIn => newOrderNumberIn);
              else /* The order number is not unique. */
                raise orderNumberException;
              end if;
            else
              update ame_approval_group_items
                set
                  last_updated_by = currentUserId,
                  last_update_date = newEndDateIn,
                  last_update_login = currentUserId,
                  end_date = newEndDateIn
                where
                  approval_group_item_id = approvalGroupItemIdIn and
                  sysdate between start_date and
                    nvl(end_date - ame_util.oneSecond, sysdate);
              if(oldOrderNumberUnique = ame_util.yes) then
                decrementGroupItemOrderNumbers(approvalGroupIdIn => approvalGroupIdIn,
                                               orderNumberIn => oldOrderNumberIn);
                if(newOrderNumberIn > oldOrderNumberIn)then
                  newOrderNumber := (newOrderNumberIn - 1);
                else
                  newOrderNumber := newOrderNumberIn;
                end if;
              else
                newOrderNumber := newOrderNumberIn;
              end if;
              if(orderNumberUniqueIn = ame_util.yes) then
                incrementGroupItemOrderNumbers(approvalGroupIdIn => approvalGroupIdIn,
                                               approvalGroupItemIdIn => approvalGroupItemIdIn,
                                               orderNumberIn => newOrderNumber);
              end if;
              /*
              Check whether the group identified by approvalGroupIdIn G is nested in
              the group identified by parameterIn P.  If so, we would have a loop in
              the groups:  P contains G, and G would contain P, which would then
              contain G, . . .  Also check whether P is already in G.
              */
              if(parameterNameIn = ame_util.approverOamGroupId and
                (approvalGroupIdIn = to_number(parameterIn) or
                groupIsInGroup(groupIdIn => to_number(parameterIn),
                               possiblyNestedGroupIdIn => approvalGroupIdIn) or
                groupIsInGroup(groupIdIn => approvalGroupIdIn,
                               possiblyNestedGroupIdIn => to_number(parameterIn)))) then
                raise badNestedGroupException;
              end if;
              insert into ame_approval_group_items(approval_group_item_id,
                                                   approval_group_id,
                                                   parameter_name,
                                                   parameter,
                                                   order_number,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login,
                                                   start_date,
                                                   end_date)
                values(approvalGroupItemId,
                       approvalGroupIdIn,
                       parameterNameIn,
                       parameterIn,
                       newOrderNumber,
                       createdBy,
                       newStartDateIn,
                       currentUserId,
                       newStartDateIn,
                       currentUserId,
                       newStartDateIn,
                       null);
            end if;
          else
            updateOnlyGIModified := true;
          end if;
          if(updateOnlyGIModified) then
            if(approvalGroupItemIdIn is not null) then
              update ame_approval_group_items
                set
                  last_updated_by = currentUserId,
                  last_update_date = newEndDateIn,
                  last_update_login = currentUserId,
                  end_date = newEndDateIn
                where
                  approval_group_item_id = approvalGroupItemIdIn and
                  sysdate between start_date and
                    nvl(end_date - ame_util.oneSecond, sysdate);
            end if;
            /*
            Check whether the group identified by approvalGroupIdIn G is nested in
            the group identified by parameterIn P.  If so, we would have a loop in
            the groups:  P contains G, and G would contain P, which would then
            contain G, . . .  Also check whether P is already in G.
            */
            if(parameterNameIn = ame_util.approverOamGroupId and
              (approvalGroupIdIn = to_number(parameterIn) or
              groupIsInGroup(groupIdIn => to_number(parameterIn),
                             possiblyNestedGroupIdIn => approvalGroupIdIn) or
              groupIsInGroup(groupIdIn => approvalGroupIdIn,
                             possiblyNestedGroupIdIn => to_number(parameterIn)))) then
              raise badNestedGroupException;
            end if;
						insert into ame_approval_group_items(approval_group_item_id,
                                                 approval_group_id,
                                                 parameter_name,
                                                 parameter,
                                                 order_number,
                                                 created_by,
                                                 creation_date,
                                                 last_updated_by,
                                                 last_update_date,
                                                 last_update_login,
                                                 start_date,
                                                 end_date)
              values(approvalGroupItemId,
                     approvalGroupIdIn,
                     parameterNameIn,
                     parameterIn,
                     newOrderNumberIn,
                     createdBy,
                     nvl(newStartDateIn, processingDate),
                     currentUserId,
                     nvl(newStartDateIn, processingDate),
                     currentUserId,
                     nvl(newStartDateIn, processingDate),
                     null);
          end if;
          maxOrderNumber :=
            ame_approval_group_pkg.getApprovalGroupItemMaxOrdNum(approvalGroupIdIn => approvalGroupIdIn);
          if(oldOrderNumberIn is null) then
					  if(orderNumberUniqueIn = ame_util.yes) then
              if(newOrderNumberIn <> (maxOrderNumber + 1)) then
                incrementGroupItemOrderNumbers(approvalGroupItemIdIn => approvalGroupItemId,
                                               approvalGroupIdIn => approvalGroupIdIn,
                                               orderNumberIn => newOrderNumberIn);
              end if;
            end if;
          end if;
					close startDateCursor;
          updateDependentGroups(groupIdIn => approvalGroupIdIn);
          if(finalizeIn) then
            commit;
          end if;
          return(approvalGroupItemId);
        else
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when badNestedGroupException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400199_APG_NEST_CONTAINS');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when groupExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400200_APG_MEMBER_EXISTS');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400201_APG_PAR_MEM_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_approval_group_items',
                                                   columnNameIn => 'parameter'));
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when badOrderNumberException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400202_APG_ORD_NAME_ARG');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn =>  errorCode,
                                    exceptionStringIn =>  errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when parameterNameLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
         messageNameIn   => 'AME_400203_APG_PAR_GRP_LONG',
         tokenNameOneIn  => 'COLUMN_LENGTH',
         tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_approval_group_items',
                                                   columnNameIn => 'parameter_name'));
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when orderNumberException then
          rollback;
          errorCode := -20001;
          errorMessage := 'To make an approval group item''s order number non-unique, ' ||
                          'you must give another approval group item the same order ' ||
                          'number, or give this approval group item the same order ' ||
                          'number as another.'; -- pa message
          /*
          ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400373_ACT DYNAMIC_DESC3');
          */
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
          return(null);
    end newApprovalGroupItem;
  function orderNumberUnique(applicationIdIn in integer,
                             orderNumberIn in integer) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_approval_group_config
        where
          application_id = applicationIdIn and
          order_number = orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if(tempCount > 1) then
        return(false);
      else
        return(true);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'orderNumberUnique',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
  end orderNumberUnique;
  procedure change(approvalGroupIdIn in integer,
                   nameIn in varchar2 default null,
                   descriptionIn in varchar2 default null,
                   isStaticIn in varchar2 default null,
                   queryStringIn in varchar2 default null,
                   updateActionIn in boolean,
                   newVersionStartDateIn in date,
                   finalizeIn in boolean default false) as
    approvalGroupId integer;
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newStartDate date;
    objectVersionNoDataException exception;
    begin
        currentUserId := ame_util.getCurrentUserId;
        endDate := newVersionStartDateIn - ame_util.oneSecond;
        newStartDate := newVersionStartDateIn;
        update ame_approval_groups
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            approval_group_id = approvalGroupIdIn and
            sysdate between start_date and
                       nvl(end_date - ame_util.oneSecond, sysdate) ;
        approvalGroupId := new(nameIn => nameIn,
                               descriptionIn => descriptionIn,
                               isStaticIn => isStaticIn,
                               queryStringIn => queryStringIn,
                               newStartDateIn => newStartDate,
                               approvalGroupIdIn => approvalGroupIdIn,
                               updateActionIn => updateActionIn,
                               finalizeIn => false);
      /* The new function calls updateDependentGroups, so we don't have to do it here. */
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
    end change;
  procedure changeGroupAndConfig(approvalGroupIdIn in integer,
                                 nameIn in varchar2 default null,
                                 descriptionIn in varchar2 default null,
                                 isStaticIn in varchar2 default null,
                                 queryStringIn in varchar2 default null,
                                 newVersionStartDateIn in date,
                                 parentVersionStartDateIn in date,
                                 childVersionStartDateIn in date,
                                 orderNumberUniqueIn in varchar2,
                                 orderNumberIn in integer,
                                 votingRegimeIn in varchar2,
                                 applicationIdIn in integer,
                                 finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_approval_group_config
        where
          approval_group_id = approvalGroupIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    currentUserId integer;
    description ame_approval_groups.description%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    name ame_approval_groups.name%type;
    objectVersionNoDataException exception;
    startDate date;
    startDate2 date;
    tempCount integer;
    updateAction boolean;
    begin
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
          if(childVersionStartDateIn <> startDate2) then
            close startDateCursor2;
            raise ame_util.objectVersionException;
          end if;
          /* Get current values as necessary for update. */
          if(nameIn is null) then
            name := getName(approvalGroupIdIn => approvalGroupIdIn);
          else
            name := nameIn;
          end if;
          if(descriptionIn is null) then
            description := getDescription(approvalGroupIdIn => approvalGroupIdIn);
          else
            description := descriptionIn;
          end if;
          /* Check to see if name or description has changed.  If so, need to
           update the ame_actions table. */
          if(nameIn <> getName(approvalGroupIdIn => approvalGroupIdIn)) then
            updateAction := true;
          else
            updateAction := false;
          end if;

          -- If only config data is changed for a seeded group update config table only.Otherwise update both.
          if(hasGroupChanged2(approvalGroupIdIn => approvalGroupIdIn,
                       nameIn            => name,
                       descriptionIn     => description,
                       isStaticIn        => isStaticIn,
                       queryStringIn     => queryStringIn) OR (not ame_approval_group_pkg.isSeeded(approvalGroupIdIn => approvalGroupIdIn))) then


            ame_approval_group_pkg.change(approvalGroupIdIn => approvalGroupIdIn,
                                        nameIn => name,
                                        descriptionIn => description,
                                        isStaticIn => isStaticIn,
                                        queryStringIn => queryStringIn,
                                        newVersionStartDateIn => newVersionStartDateIn,
                                        updateActionIn => updateAction,
                                        finalizeIn => false);
          end if;

          ame_approval_group_pkg.changeGroupConfig(approvalGroupIdIn => approvalGroupIdIn,
                                                   orderNumberUniqueIn => orderNumberUniqueIn,
                                                   orderNumberIn => orderNumberIn,
                                                   votingRegimeIn => votingRegimeIn,
                                                   applicationIdIn => applicationIdIn,
                                                   newVersionStartDateIn => newVersionStartDateIn,
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
        ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                  routineNameIn => 'changeGroupAndConfig',
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
        ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                  routineNameIn => 'changeGroupAndConfig',
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'changeGroupAndConfig',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(approval group ID ' ||
                                                        approvalGroupIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeGroupAndConfig;
  procedure changeGroupConfig(applicationIdIn in integer,
                              approvalGroupIdIn in integer,
                              orderNumberUniqueIn in varchar2,
                              orderNumberIn in integer,
                              votingRegimeIn in varchar2,
                              newVersionStartDateIn in date,
                              finalizeIn in boolean default false) as
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newOrderNumber integer;
    newStartDate date;
    oldOrderNumber integer;
    oldOrderNumberUnique ame_util.stringType;
    orderNumberException exception;
    updateOnlyAGModified boolean;
    begin
      oldOrderNumber := getApprovalGroupOrderNumber(applicationIdIn => applicationIdIn,
                                                    approvalGroupIdIn => approvalGroupIdIn);
      if(ame_approval_group_pkg.orderNumberUnique(applicationIdIn => applicationIdIn,
                                                  orderNumberIn => oldOrderNumber)) then
        oldOrderNumberUnique := ame_util.yes;
      else
        oldOrderNumberUnique := ame_util.no;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      endDate := newVersionStartDateIn;
      newStartDate := newVersionStartDateIn;
      updateOnlyAGModified := false;
      /* Check if order number was modified */
      if(oldOrderNumber = orderNumberIn) then
        if(orderNumberUniqueIn = oldOrderNumberUnique) then
          updateOnlyAGModified := true;
        elsif(orderNumberUniqueIn = ame_util.yes) then
          /* Need to adjust the order numbers to keep them in sequence. */
          incrementGroupOrderNumbers(applicationIdIn => applicationIdIn,
                                     approvalGroupIdIn => approvalGroupIdIn,
                                     orderNumberIn => orderNumberIn);

        else /* The order number is not unique. */
          raise orderNumberException;
        end if;
      else
        update ame_approval_group_config
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            approval_group_id = approvalGroupIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        if(oldOrderNumberUnique = ame_util.yes) then
          decrementGroupOrderNumbers(applicationIdIn => applicationIdIn,
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
          incrementGroupOrderNumbers(applicationIdIn => applicationIdIn,
                                     approvalGroupIdIn => approvalGroupIdIn,
                                     orderNumberIn => newOrderNumber);
        end if;
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationIdIn,
                 approvalGroupIdIn,
                 votingRegimeIn,
                 newOrderNumber,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 null);
      end if;
      if(updateOnlyAGModified) then
        update ame_approval_group_config
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            approval_group_id = approvalGroupIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationIdIn,
                 approvalGroupIdIn,
                 votingRegimeIn,
                 orderNumberIn,
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
          errorMessage := 'To make an approval group item''s order number non-unique, ' ||
                          'you must give another approval group item the same order ' ||
                          'number, or give this approval group item the same order ' ||
                          'number as another.'; -- pa message
          /*
          ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400373_ACT DYNAMIC_DESC3');
          */
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'changeGroupConfig',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'changeGroupConfig',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                    messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                    tokenNameOneIn => 'NAME',
                                    tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                   || ' ' || sqlerrm);
          raise;
    end changeGroupConfig;
  procedure changeApprovalGroupItem(approvalGroupIdIn in integer,
                                    itemIdIn in integer,
                                    parameterIn in varchar2 default null,
                                    parameterNameIn in varchar2,
                                    newOrderNumberIn in integer,
                                    orderNumberUniqueIn in varchar2 default null,
                                    parentVersionStartDateIn in date) as
    cursor startDateCursor is
      select start_date
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    approvalGroupId integer;
    approvalGroupItemId integer;
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    groupDescription ame_approval_groups.description%type;
    groupIsStatic ame_approval_groups.is_static%type;
    groupName ame_approval_groups.name%type;
    groupQueryString ame_approval_groups.query_string%type;
    newStartDate date;
    objectVersionNoDataException exception;
    oldOrderNumber integer;
    parameter ame_approval_group_items.parameter%type;
    parameterName ame_approval_group_items.parameter_name%type;
    startDate date;
    processingDate date;
    tempCount integer;
    begin
      processingDate := sysdate;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(parameterIn is null) then
          parameter := getItemParameter(approvalGroupItemIdIn => itemIdIn);
        else
          parameter := parameterIn;
        end if;
        if(parameterNameIn is null) then
          parameterName := getItemParameterName(approvalGroupItemIdIn => itemIdIn);
        else
          parameterName := parameterNameIn;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        if(parentVersionStartDateIn = startDate) then
          oldOrderNumber := getItemOrderNumber(approvalGroupItemIdIn => itemIdIn);
          endDate := processingDate;
          newStartDate := processingDate;
          approvalGroupItemId := newApprovalGroupItem(approvalGroupIdIn => approvalGroupIdIn,
                                                      parameterIn => parameter,
                                                      parameterNameIn => parameterName,
                                                      approvalGroupItemIdIn => itemIdIn,
                                                      newOrderNumberIn => newOrderNumberIn,
                                                      oldOrderNumberIn => oldOrderNumber,
                                                      orderNumberUniqueIn => orderNumberUniqueIn,
                                                      newStartDateIn => newStartDate,
                                                      newEndDateIn => endDate,
                                                      finalizeIn => false,
                                                      parentVersionStartDateIn => parentVersionStartDateIn);
          groupName := getName(approvalGroupIdIn => approvalGroupIdIn);
          groupDescription := getDescription(approvalGroupIdIn => approvalGroupIdIn);
          groupIsStatic := getIsStatic(approvalGroupIdIn => approvalGroupIdIn);
          groupQueryString := getQueryString(approvalGroupIdIn => approvalGroupIdIn);
          update ame_approval_groups
            set
              last_updated_by = currentUserId,
              last_update_date = endDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              approval_group_id = approvalGroupIdIn and
              sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate) ;
          approvalGroupId := new(nameIn => groupName,
                                 descriptionIn => groupDescription,
                                 isStaticIn => groupIsStatic,
                                 queryStringIn => groupQueryString,
                                 newStartDateIn => newStartDate,
                                 approvalGroupIdIn => approvalGroupIdIn,
                                 finalizeIn => true);
          /* function new does a commit */
        else
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
      close startDateCursor;
      exception
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'changeApprovalGroupItem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'changeApprovalGroupItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
    end changeApprovalGroupItem;
  procedure decrementGroupItemOrderNumbers(approvalGroupIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false) as
    cursor orderNumberCursor is
      select approval_group_item_id, order_number
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          order_number > orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by order_number;
    approvalGroupItemIds ame_util.idList;
    currentUserId integer;
    parameter ame_approval_group_items.parameter%type;
    parameterName ame_approval_group_items.parameter%type;
    processingDate date;
    orderNumbers ame_util.idList;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      open orderNumberCursor;
        fetch orderNumberCursor bulk collect
        into approvalGroupItemIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. approvalGroupItemIds.count loop
        parameter :=
          getItemParameter(approvalGroupItemIdIn => approvalGroupItemIds(i));
        parameterName :=
          getItemParameterName(approvalGroupItemIdIn => approvalGroupItemIds(i));
				update ame_approval_group_items
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            approval_group_item_id = approvalGroupItemIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_approval_group_items(approval_group_item_id,
                                             approval_group_id,
                                             parameter_name,
                                             parameter,
                                             order_number,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_date,
                                             last_update_login,
                                             start_date,
                                             end_date)
          values(approvalGroupItemIds(i),
                 approvalGroupIdIn,
                 parameterName,
                 parameter,
                 (orderNumbers(i) - 1),
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'decrementGroupItemOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end decrementGroupItemOrderNumbers;
  procedure decrementGroupOrderNumbers(applicationIdIn in integer,
                                       orderNumberIn in integer,
                                       finalizeIn in boolean default false) as
    cursor orderNumberCursor is
      select approval_group_id, order_number
        from ame_approval_group_config
        where
          application_id = applicationIdIn and
          order_number > orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by order_number;
    approvalGroupIds ame_util.idList;
    currentUserId integer;
    orderNumbers ame_util.idList;
    processingDate date;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      open orderNumberCursor;
        fetch orderNumberCursor bulk collect
        into approvalGroupIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. approvalGroupIds.count loop
        votingRegime := getVotingRegime(approvalGroupIdIn => approvalGroupIds(i),
                                        applicationIdIn => applicationIdIn);
        update ame_approval_group_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            approval_group_id = approvalGroupIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationIdIn,
                 approvalGroupIds(i),
                 votingRegime,
                 (orderNumbers(i) - 1),
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'decrementGroupOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end decrementGroupOrderNumbers;
  procedure getAllowedNestedGroups(groupIdIn in integer,
                                   allowedNestedGroupIdsOut out nocopy ame_util.stringList,
                                   allowedNestedGroupNamesOut out nocopy ame_util.stringList) as
    cursor groupCursor is
      select
        approval_group_id,
        name
        from ame_approval_groups
        where
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate) ;
    tempIndex integer;
    begin
      tempIndex := 0; /* pre-increment */
      for tempGroup in groupCursor loop
        /*
          Check whether the group identified by groupIdIn G is nested in
          the group identified by tempGroup P.  If so, we would have a loop in
          the groups:  P contains G, and G would contain P, which would then
          contain G, . . .  Also check whether P is already in G.
        */
        if(groupIdIn <> tempGroup.approval_group_id and
           not groupIsInGroup(groupIdIn => tempGroup.approval_group_id,
                              possiblyNestedGroupIdIn => groupIdIn) and
           not groupIsInGroup(groupIdIn => groupIdIn,
                              possiblyNestedGroupIdIn => tempGroup.approval_group_id)) then
          tempIndex := tempIndex + 1;
          allowedNestedGroupIdsOut(tempIndex) := to_char(tempGroup.approval_group_id);
          allowedNestedGroupNamesOut(tempIndex) := tempGroup.name;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getAllowedNestedGroups',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn))
                                     || ' ' || sqlerrm);
          allowedNestedGroupIdsOut := ame_util.emptyStringList;
          allowedNestedGroupNamesOut := ame_util.emptyStringList;
          raise;
    end getAllowedNestedGroups;
  procedure getApprovalGroupItemList(approvalGroupIdIn  in integer,
                                     itemListOut        out nocopy ame_util.idList,
                                     orderListOut       out nocopy ame_util.idList,
                                     descriptionListOut out nocopy ame_util.longStringList,
                                     invalidMembersOut  out nocopy boolean) as
    cursor itemCursor(approvalGroupIdIn in integer) is
      select approval_group_item_id
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
           order by order_number;
    tempindex integer;
    tempDescription ame_approval_groups.description%type;
    tempFirstName per_all_people_f.first_name%type;
    tempItemId integer;
    tempLastName per_all_people_f.last_name%type;
    tempName ame_approval_groups.name%type;
    tempParameter ame_approval_group_items.parameter%type;
    tempParameterName ame_approval_group_items.parameter_name%type;
    tempUserName fnd_user.user_name%type;
    tempRowNumber integer;
    approverDesc   ame_util.longStringType;
    approverValid  boolean;
    begin
      tempIndex := 1;
      invalidMembersOut := false;
      for tempItem in itemCursor(approvalGroupIdIn) loop
        tempItemId := tempItem.approval_group_item_id;
        tempParameterName := ame_approval_group_pkg.getItemParameterName(approvalGroupItemIdIn => tempItemId);
        tempParameter := ame_approval_group_pkg.getItemParameter(approvalGroupItemIdIn => tempItemId);
        itemListOut(tempIndex) := tempItemId;
        orderListOut(tempIndex) := getItemOrderNumber(approvalGroupItemIdIn => tempItemId);
        if tempParameterName = ame_util.approverOamGroupId then
          descriptionListOut(tempIndex) :=
            orderListOut(tempIndex) ||
            '.  ' ||
            getName(approvalGroupIdIn => to_number(tempParameter));
        else
          ame_approver_type_pkg.getApproverDescAndValidity(
                                     nameIn         => tempParameter,
                                     descriptionOut => approverDesc,
                                     validityOut    => approverValid);
          if(not approverValid) then
            invalidMembersOut := true;
          end if;
          descriptionListOut(tempIndex) := orderListOut(tempIndex) || '.  ' || approverDesc;
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupItemList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          itemListOut := ame_util.emptyIdList;
          orderListOut := ame_util.emptyIdList;
          descriptionListOut := ame_util.emptyLongStringList;
          raise;
    end getApprovalGroupItemList;
  procedure getApprovalGroupList(groupListOut out nocopy ame_util.idList) as
    cursor groupCursor is
      select approval_group_id
        from ame_approval_groups
        where
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempGroup in groupCursor loop
        groupListOut(tempIndex) := tempGroup.approval_group_id;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          groupListOut := ame_util.emptyIdList;
          raise;
    end getApprovalGroupList;
  procedure getApprovalGroupList2(applicationIdIn in integer,
                                  groupListOut out nocopy ame_util.idList) as
    cursor groupCursor is
      select ame_approval_groups.approval_group_id
        from ame_approval_groups,
             ame_approval_group_config
        where
          ame_approval_groups.approval_group_id = ame_approval_group_config.approval_group_id and
          ame_approval_group_config.application_id = applicationIdIn and
          sysdate between ame_approval_groups.start_date and
                         nvl(ame_approval_groups.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_approval_group_config.start_date and
                         nvl(ame_approval_group_config.end_date - ame_util.oneSecond, sysdate)
        order by ame_approval_group_config.order_number;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempGroup in groupCursor loop
        groupListOut(tempIndex) := tempGroup.approval_group_id;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getApprovalGroupList2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          groupListOut := ame_util.emptyIdList;
          raise;
    end getApprovalGroupList2;
  procedure getGroupMembers(approvalGroupIdIn in integer,
                            memberIdsOut out nocopy ame_util.longStringList,
                            memberTypesOut out nocopy ame_util.stringList) as
    cursor groupMemberCursor(approvalGroupIdIn in integer) is
      select
        parameter,
        parameter_name
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
        order by order_number;
    isStatic ame_approval_groups.is_static%type;
    queryString ame_util.longestStringType;
    recursionParameterNames ame_util.stringList;
    recursionParameters ame_util.longStringList;
    recursionUpperLimit integer;
    tempIndex integer;
    begin
      select
        is_static,
        query_string
        into
          isStatic,
          queryString
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(isStatic = ame_util.booleanTrue) then /* Use the static membership list. */
        tempIndex := 0; /* pre-increment */
        for tempMember in groupMemberCursor(approvalGroupIdIn => approvalGroupIdIn) loop
          if(tempMember.parameter_name = ame_util.approverOamGroupId) then
            /* recursion */
            getGroupMembers(approvalGroupIdIn => to_number(tempMember.parameter),
                            memberTypesOut => recursionParameterNames,
                            memberIdsOut => recursionParameters);
            recursionUpperLimit := recursionParameterNames.count;
            for j in 1 .. recursionUpperLimit loop
              tempIndex := tempIndex + 1;
              memberTypesOut(tempIndex) := recursionParameterNames(j);
              memberIdsOut(tempIndex) := recursionParameters(j);
            end loop;
          else
            tempIndex := tempIndex + 1;
            memberTypesOut(tempIndex) := tempMember.parameter_name;
            memberIdsOut(tempIndex) := tempMember.parameter;
          end if;
        end loop;
      else /* The group uses its dynamic list. */
        memberTypesOut.delete;
        memberIdsOut.delete;
        return;
      end if;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                  routineNameIn => 'getGroupMembers',
                                  exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
        memberIdsOut := ame_util.emptyLongStringList;
        memberTypesOut := ame_util.emptyStringList;
        raise;
    end getGroupMembers;
  procedure getInvalidApprGroupItemList(approvalGroupIdIn  in integer,
                                        itemListOut out nocopy ame_util.idList) as
    cursor itemCursor(approvalGroupIdIn in integer) is
      select approval_group_item_id, parameter
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          parameter_name <> ame_util.approverOamGroupId and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
           order by order_number;
    tempIndex integer;
    tempItemId integer;
    tempParameter ame_approval_group_items.parameter%type;
    begin
      tempIndex := 1;
      for tempItem in itemCursor(approvalGroupIdIn) loop
        tempItemId := tempItem.approval_group_item_id;
        tempParameter := tempItem.parameter;
        if(not ame_approver_type_pkg.validateApprover(nameIn => tempParameter)) then
          itemListOut(tempIndex) := tempItemId;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getInvalidApprGroupItemList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          itemListOut := ame_util.emptyIdList;
          raise;
    end getInvalidApprGroupItemList;
  procedure getNestedMembers(groupIdIn in integer,
                             effectiveDateIn in date default null,
                             parameterNamesOut out nocopy ame_util.stringList,
                             parametersOut out nocopy ame_util.stringList,
                             orderNumbersOut out nocopy ame_util.idList,
                             queryStringsOut out nocopy ame_util.longestStringList) as
    cursor groupMemberCursor(approvalGroupIdIn in integer,
                             effectiveDateIn in date) is
      select
        parameter,
        parameter_name,
        order_number
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          effectiveDateIn between start_date and nvl(end_date - ame_util.oneSecond, sysdate)
        order by order_number;
    outputIndex integer;
    recursionParameterNames ame_util.stringList;
    recursionParameters ame_util.stringList;
    recursionOrderNumbers ame_util.idList;
    recursionQueries ame_util.longestStringList;
    upperLimit integer;
    begin
      /* If the target group is dynamic, just return its query string. */
      if(not isStatic(approvalGroupIdIn => groupIdIn,
                      effectiveDateIn => effectiveDateIn)) then
        parameterNamesOut(1) := ame_util.approverOamGroupId;
        parametersOut(1) := to_char(groupIdIn);
        orderNumbersOut(1) := 1;
        queryStringsOut(1) := getQueryString(approvalGroupIdIn => groupIdIn,
                                            effectiveDateIn => effectiveDateIn);
        return;
      end if;
      outputIndex := 0; /* pre-increment */
      /* The target group is static, so loop through its members. */
      for tempMember in groupMemberCursor(approvalGroupIdIn => groupIdIn,
                                          effectiveDateIn => effectiveDateIn) loop
        if(tempMember.parameter_name = ame_util.approverOamGroupId) then
          if(isStatic(approvalGroupIdIn => to_number(tempMember.parameter),
                      effectiveDateIn => effectiveDateIn)) then
            recursionParameterNames.delete;
            recursionParameters.delete;
            recursionOrderNumbers.delete;
            recursionQueries.delete;
            getNestedMembers(groupIdIn => to_number(tempMember.parameter),
                             effectiveDateIn => effectiveDateIn,
                             parameterNamesOut => recursionParameterNames,
                             parametersOut => recursionParameters,
                             orderNumbersOut => recursionOrderNumbers,
                             queryStringsOut => recursionQueries);
            upperLimit := recursionParameters.count;
            for i in 1 .. upperLimit loop
              outputIndex := outputIndex + 1;
              parameterNamesOut(outputIndex) := recursionParameterNames(i);
              parametersOut(outputIndex) := recursionParameters(i);
              orderNumbersOut(outputIndex) := recursionOrderNumbers(i);
              queryStringsOut(outputIndex) := recursionQueries(i);
            end loop;
          else
            outputIndex := outputIndex + 1;
            parameterNamesOut(outputIndex) := ame_util.approverOamGroupId;
            parametersOut(outputIndex) := tempMember.parameter;
            orderNumbersOut(outputIndex) := outputIndex;
            queryStringsOut(outputIndex) := getQueryString(approvalGroupIdIn => to_number(tempMember.parameter),
                                                          effectiveDateIn => effectiveDateIn);
          end if;
        else
          outputIndex := outputIndex + 1;
          parameterNamesOut(outputIndex) := tempMember.parameter_name;
          parametersOut(outputIndex) := tempMember.parameter;
          orderNumbersOut(outputIndex) := tempMember.order_number;
          queryStringsOut(outputIndex) := null;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getNestedMembers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn,
                                                               effectiveDateIn => effectiveDateIn))
                                     || ' ' || sqlerrm);
          parameterNamesOut := ame_util.emptyStringList;
          parametersOut := ame_util.emptyStringList;
          orderNumbersOut := ame_util.emptyIdList;
          queryStringsOut := ame_util.emptyLongestStringList;
          raise;
    end getNestedMembers;
    /*
  procedure getOrderNumbers(approvalGroupIdIn in integer,
                            orderNumbersOut out nocopy ame_util.stringList) as
    cursor getOrderNumbersCursor(approvalGroupIdIn in integer) is
      select order_number
        from ame_approval_group_items
        where approval_group_id = approvalGroupIdIn and
              sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
        order by order_number;
    tempIndex integer;
      begin
        tempIndex := 1;
        for getOrderNumberRec in getOrderNumbersCursor(approvalGroupIdIn => approvalGroupIdIn) loop
          orderNumbersOut(tempIndex) := to_char(getOrderNumberRec.order_number);
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'getOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          orderNumbersOut := ame_util.emptyStringList;
          raise;
    end getOrderNumbers;
    */
  procedure incrementGroupItemOrderNumbers(approvalGroupIdIn in integer,
                                           approvalGroupItemIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false) as
    cursor orderNumberCursor(approvalGroupIdIn in integer,
                             approvalGroupItemIdIn in integer,
                             orderNumberIn in integer) is
      select approval_group_Item_id, order_number
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          approval_group_item_id <> approvalGroupItemIdIn and
          order_number >= orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by order_number;
    approvalGroupItemIds ame_util.idList;
    currentUserId integer;
    orderNumbers ame_util.idList;
    parameter ame_approval_group_items.parameter%type;
    parameterName ame_approval_group_items.parameter_name%type;
    processingDate date;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      open orderNumberCursor(approvalGroupIdIn => approvalGroupIdIn,
                             approvalGroupItemIdIn => approvalGroupItemIdIn,
                             orderNumberIn => orderNumberIn);
        fetch orderNumberCursor bulk collect
        into approvalGroupItemIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. approvalGroupItemIds.count loop
        parameter := getItemParameter(approvalGroupItemIdIn => approvalGroupItemIds(i));
        parameterName := getItemParameterName(approvalGroupItemIdIn => approvalGroupItemIds(i));
        update ame_approval_group_items
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            approval_group_item_id = approvalGroupItemIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_approval_group_items(approval_group_item_id,
                                             approval_group_id,
                                             parameter_name,
                                             parameter,
                                             order_number,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_date,
                                             last_update_login,
                                             start_date,
                                             end_date)
          values(approvalGroupItemIds(i),
                 approvalGroupIdIn,
                 parameterName,
                 parameter,
                 (orderNumbers(i) + 1),
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'incrementGroupItemOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end incrementGroupItemOrderNumbers;
  procedure incrementGroupOrderNumbers(applicationIdIn in integer,
                                       approvalGroupIdIn in integer,
                                       orderNumberIn in integer,
                                       finalizeIn in boolean default false) as
    cursor orderNumberCursor is
      select approval_group_id, order_number
        from ame_approval_group_config
        where
          application_id = applicationIdIn and
          approval_group_id <> approvalGroupIdIn and
          order_number >= orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by order_number;
    approvalGroupIds ame_util.idList;
    currentUserId integer;
    orderNumbers ame_util.idList;
    processingDate date;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      open orderNumberCursor;
        fetch orderNumberCursor bulk collect
        into approvalGroupIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. approvalGroupIds.count loop
        votingRegime := getVotingRegime(approvalGroupIdIn => approvalGroupIds(i),
                                        applicationIdIn => applicationIdIn);
        update ame_approval_group_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            approval_group_id = approvalGroupIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationIdIn,
                 approvalGroupIds(i),
                 votingRegime,
                 (orderNumbers(i) + 1),
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'incrementGroupOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end incrementGroupOrderNumbers;
  procedure newApprovalGroupConfig(approvalGroupIdIn in integer,
                                   applicationIdIn in integer default null,
                                   orderNumberIn in integer default null,
                                   orderNumberUniqueIn in varchar2 default ame_util.yes,
                                   votingRegimeIn in varchar2 default ame_util.serializedVoting,
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
    currentUserId integer;
    maxOrderNumber integer;
    orderNumber ame_approval_group_config.order_number%type;
    processingDate date;
    tempCount integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      processingDate := sysdate;
      maxOrderNumber :=
        ame_approval_group_pkg.getApprovalGroupMaxOrderNumber(applicationIdIn => applicationIdIn);
      open applicationIdCursor;
      fetch applicationIdCursor bulk collect
        into
          applicationIds;
      close applicationIdCursor;
      for i in 1 .. applicationIds.count loop
        if(applicationIds(i) = applicationIdIn) then
          applicationId := applicationIds(i);
          orderNumber := orderNumberIn;
        else
          applicationId := applicationIds(i);
          select count(*)
            into tempCount
            from ame_approval_group_config
            where
              application_id = applicationIds(i) and
              sysdate between start_date and
                nvl(end_date - ame_util.oneSecond, sysdate);
          if(tempCount = 0) then
            orderNumber := 1;
          else
            select (nvl(max(order_number), 0) + 1)
              into orderNumber
              from ame_approval_group_config
              where
                application_id = applicationIds(i) and
                sysdate between start_date and
                  nvl(end_date - ame_util.oneSecond, sysdate);
          end if;
        end if;
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationId,
                 approvalGroupIdIn,
                 votingRegimeIn,
                 orderNumber,
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
          incrementGroupOrderNumbers(applicationIdIn => applicationIdIn,
                                     approvalGroupIdIn => approvalGroupIdIn,
                                     orderNumberIn => orderNumberIn);
        end if;
      end if;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'newApprovalGroupConfig',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
    end newApprovalGroupConfig;
  procedure remove(approvalGroupIdIn in integer,
                   parentVersionStartDateIn in date) as
    cursor startDateCursor is
      select start_date
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
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
      processingDate :=  sysdate;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(isInUse(approvalGroupIdIn => approvalGroupIdIn)) then
          raise inUseException;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        if parentVersionStartDateIn = startDate then
          open applicationIdCursor;
            fetch applicationIdCursor bulk collect
              into applicationIds;
          close applicationIdCursor;
          for i in 1 .. applicationIds.count loop
            select order_number
              into orderNumber
              from ame_approval_group_config
              where
                application_id = applicationIds(i) and
                approval_group_id = approvalGroupIdIn and
                sysdate between start_date and
                  nvl(end_date - ame_util.oneSecond, sysdate);
            if(orderNumberUnique(applicationIdIn => applicationIds(i),
                                 orderNumberIn => orderNumber)) then
              /* subtract 1 from the order number for those above the one being deleted */
              decrementGroupOrderNumbers(applicationIdIn => applicationIds(i),
                                         orderNumberIn => orderNumber,
                                         finalizeIn => false);
            end if;
          end loop;
          /* End-date approval group itself.*/
          update ame_approval_groups
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              approval_group_id = approvalGroupIdIn and
              processingDate between start_date and
              nvl(end_date - ame_util.oneSecond, processingDate) ;
          /* End-date approval-group items. */
          update ame_approval_group_items
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              approval_group_id = approvalGroupIdIn and
              processingDate between start_date and
                         nvl(end_date - ame_util.oneSecond, processingDate);
          /* End-date the approval group configs */
          update ame_approval_group_config
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              approval_group_id = approvalGroupIdIn and
              processingDate between start_date and
                nvl(end_date - ame_util.oneSecond, processingDate) ;
          /* End-date any related actions. */
          update ame_actions
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              parameter = to_char(approvalGroupIdIn) and
              processingDate between start_date and
                         nvl(end_date - ame_util.oneSecond, processingDate) ;
          /*
          Remove the group from any groups containing it, and
          update those groups in ame_approval_group_members.
          */
          updateDependentGroups(groupIdIn => approvalGroupIdIn,
                                deleteGroupIn => true);
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
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
            messageNameIn => 'AME_400205_APG_IN_USE');
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
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
          ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                    routineNameIn => 'remove',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
          raise;
    end remove;
  procedure removeApprovalGroupItem(approvalGroupIdIn    in integer,
                                    approvalGroupItemsIn in ame_util.idList,
                                    parentVersionStartDateIn   in date) as
   cursor startDateCursor is
      select start_date
        from ame_approval_groups
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
   cursor orderCursor(approvalGroupIdIn  in integer) is
     select order_number, approval_group_item_id
        from ame_approval_group_items
        where approval_group_id = approvalGroupIdIn and
        sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate)
        for update of order_number
        order by order_number;
   approvalGroupId ame_approval_groups.approval_group_id%type;
   approvalGroupItemCount integer;
   approvalGroupItemList ame_util.idList;
   currentUserId integer;
   errorCode integer;
   errorMessage ame_util.longestStringType;
   groupDescription ame_approval_groups.description%type;
   groupName ame_approval_groups.name%type;
   isStatic ame_approval_groups.is_static%type;
   itemOrderNumber integer;
   objectVersionNoDataException exception;
   queryString ame_approval_groups.query_string%type;
   startDate date;
   tempIndex integer;
   processingDate date;
   begin
     processingDate := sysdate;
     open startDateCursor;
       fetch startDateCursor into startDate;
       if startDateCursor%notfound then
         raise objectVersionNoDataException;
       end if;
       currentUserId := ame_util.getCurrentUserId;
       if parentVersionStartDateIn = startDate then
         approvalGroupItemCount := approvalGroupItemsIn.count;
         tempIndex := 0;
         /* Reindex to set approval group item order numbers in descending order.  This will
				    prevent unnecessary reordering in the decrementGroupItemOrderNumbers routine below. */
         for i in 1 .. approvalGroupItemCount loop
           approvalGroupItemList(i) := approvalGroupItemsIn(approvalGroupItemCount - tempIndex);
           tempIndex := (tempIndex + 1);
         end loop;
         for i in 1 .. approvalGroupItemCount loop
           itemOrderNumber :=
             getItemOrderNumber(approvalGroupItemIdIn => approvalGroupItemList(i));
					 if(itemOrderNumberUnique(approvalGroupIdIn => approvalGroupIdIn,
                                    orderNumberIn => itemOrderNumber)) then
              /* subtract 1 from the order number for those above the one being deleted */
             decrementGroupItemOrderNumbers(approvalGroupIdIn => approvalGroupIdIn,
                                            orderNumberIn => itemOrderNumber,
                                            finalizeIn => false);
           end if;
           update ame_approval_group_items
             set
               last_updated_by = currentUserId,
               last_update_date = processingDate,
               last_update_login = currentUserId,
               end_date = processingDate
             where
               approval_group_item_id = approvalGroupItemList(i) and
               processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate);
         end loop;
				 groupName := getName(approvalGroupIdIn => approvalGroupIdIn);
         groupDescription := getDescription(approvalGroupIdIn => approvalGroupIdIn);
         isStatic := getIsStatic(approvalGroupIdIn => approvalGroupIdIn);
         queryString := getQueryString(approvalGroupIdIn => approvalGroupIdIn);
         update ame_approval_groups
           set
             last_updated_by = currentUserId,
             last_update_date = processingDate,
             last_update_login = currentUserId,
             end_date = processingDate
           where
             approval_group_id = approvalGroupIdIn and
             processingDate between start_date and
                         nvl(end_date - ame_util.oneSecond, processingDate);
         approvalGroupId := new(nameIn => groupName,
                                descriptionIn => groupDescription,
                                isStaticIn => isStatic,
                                queryStringIn => queryString,
                                approvalGroupIdIn => approvalGroupIdIn);
         close startDateCursor;
         /* new calls updateDependentGroups, so don't do it here. */
         commit;
       else
         close startDateCursor;
         raise ame_util.objectVersionException;
     end if;
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
         ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                   routineNameIn => 'removeApprovalGroupItem',
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
         ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                   routineNameIn => 'removeApprovalGroupItem',
                                   exceptionNumberIn => errorCode,
                                   exceptionStringIn => errorMessage);
         raise_application_error(errorCode,
                                 errorMessage);
       when others then
         rollback;
         if(startDateCursor%isOpen) then
           close startDateCursor;
         end if;
         ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                   routineNameIn => 'removeApprovalGroupItem',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => approvalGroupIdIn))
                                     || ' ' || sqlerrm);
         raise;
  end removeApprovalGroupItem;
procedure setGroupMembers2(groupIdIn in integer,
                           effectiveDateIn in date default sysdate,
                           raiseError in boolean) as
    memberIndex integer;
    orderNumbers ame_util.idList;
    origSystem ame_util.stringType;
    origSystemId integer;
    parameterNames ame_util.stringList;
    parameters ame_util.stringList;
    queryStrings ame_util.longestStringList;
    tempCount integer;
    upperLimit integer;
    begin
      /* Clear the old nonrecursive membership list. */
      delete from ame_approval_group_members
        where approval_group_id = groupIdIn;
      /* Rebuid the nonrecursive membership list. */
      getNestedMembers(groupIdIn => groupIdIn,
                       effectiveDateIn => effectiveDateIn,
                       parameterNamesOut => parameterNames,
                       parametersOut => parameters,
                       orderNumbersOut => orderNumbers,
                       queryStringsOut => queryStrings);
      upperLimit := parameters.count;
      /* Only insert members that aren't already there. */
      memberIndex := 0;
      for i in 1 .. upperLimit loop
        select count(*)
          into tempCount
          from ame_approval_group_members
          where
            approval_group_id = groupIdIn and
            parameter_name = parameterNames(i) and
            parameter = parameters(i);
        if(tempCount = 0) then
          memberIndex := memberIndex + 1;
          if parameterNames(i) = ame_util.approverWfRolesName then
            begin
              ame_approver_type_pkg.getApproverOrigSystemAndId(nameIn => parameters(i),
                                                               origSystemOut => origSystem,
                                                               origSystemIdOut => origSystemId);
            exception
            when others then
              if not raiseError then
                origSystem := null;
                origSystemId := null;
              else
                rollback;
                ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                          routineNameIn => 'setGroupMembers2',
                                          exceptionNumberIn => sqlcode,
                                          exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                            messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                            tokenNameOneIn => 'NAME',
                                            tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn,
                                                               effectiveDateIn => effectiveDateIn))
                                            || ' ' || sqlerrm);
                raise;
              end if;
            end;
          else
            origSystem := null;
            origSystemId := null;
          end if;
          insert into ame_approval_group_members(
            approval_group_id,
            parameter_name,
            parameter,
            orig_system,
            orig_system_id,
            query_string,
            order_number)
            values(
              groupIdIn,
              parameterNames(i),
              parameters(i),
              origSystem,
              origSystemId,
              queryStrings(i),
              orderNumbers(i));
        end if;
      end loop;
      exception
       when others then
         rollback;
         ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                   routineNameIn => 'setGroupMembers2',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn,
                                                        effectiveDateIn => effectiveDateIn))
                                     || ' ' || sqlerrm);
         raise;
    end setGroupMembers2;
  procedure setGroupMembers(groupIdIn in integer,
                            effectiveDateIn in date default sysdate) as
    begin
      setGroupMembers2(groupIdIn => groupIdIn,
                       effectiveDateIn => effectiveDateIn,
                       raiseError => true
                       );
    end setGroupMembers;
  procedure updateDependentGroups(groupIdIn in integer,
                                  deleteGroupIn in boolean default false) as
    cursor dependentGroupCursor(groupIdIn in integer) is
      select distinct approval_group_id
      from ame_approval_group_items
      where
        parameter_name = ame_util.approverOamGroupId and
        parameter = to_char(groupIdIn) and
        sysdate between start_date and
                         nvl(end_date - ame_util.oneSecond, sysdate) ;
    groupsToUpdate ame_util.idList;
    currentGroup integer;
    upperLimit integer;
    processingDate date;
    begin
      /*
        The following loop treats groupsToUpdate as a first-in, first-out queue.
        We enter the loop with the group identified by groupIdIn as the first
        (and so far only) group in the queue.  The loop updates the next group
        in the queue and adds all of the groups that contain it to the end of
        the queue.  In this fashion all of a given group's dependents are updated
        before any of their dependents are updated, etc.
      */
      processingDate := sysdate;
      groupsToUpdate(1) := groupIdIn;
      currentGroup := 1;
      upperLimit := 1;
      loop
        if(deleteGroupIn and currentGroup > 1) then
          /*
            Delete the target group (groupIdIn) from the item list of the current group.
            (Don't do it for currentGroup = 1 because the group is never a member of itself.)
            The call to setGroupMembers below updates ame_approval_group_members for dependent
            groups.
          */
          update ame_approval_group_items
            set end_date = processingDate
            where
              approval_group_id = groupsToUpdate(currentGroup) and
              parameter_name = ame_util.approverOamGroupId and
              parameter = to_char(groupIdIn) and
              processingDate between start_date and
                       nvl(end_date - ame_util.oneSecond, processingDate) ;
        end if;
        if(currentGroup > 1 or
           not deleteGroupIn) then
          setGroupMembers(groupIdIn => groupsToUpdate(currentGroup));
        end if;
        for tempGroup in dependentGroupCursor(groupIdIn => groupsToUpdate(currentGroup)) loop
          upperLimit := upperLimit + 1;
          groupsToUpdate(upperLimit) := tempGroup.approval_group_id;
        end loop;
        currentGroup := currentGroup + 1;
        if(currentGroup > upperLimit) then
          exit;
        end if;
      end loop;
      exception
       when others then
         rollback;
         ame_util.runtimeException(packageNameIn => 'ame_approval_group_pkg',
                                   routineNameIn => 'updateDependentGroups',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => ame_util.getMessage(applicationShortNameIn => 'PER',
                                     messageNameIn => 'AME_400354_APPR_GRP_NAME_ERR',
                                     tokenNameOneIn => 'NAME',
                                     tokenValueOneIn => getName(approvalGroupIdIn => groupIdIn))
                                     || ' ' || sqlerrm);
         raise;
    end updateDependentGroups;
end ame_approval_group_pkg;

/
