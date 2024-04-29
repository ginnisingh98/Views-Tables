--------------------------------------------------------
--  DDL for Package AME_APPROVAL_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVAL_GROUP_PKG" AUTHID CURRENT_USER as
/* $Header: ameogrou.pkh 120.1 2006/08/04 15:34:26 pvelugul noship $ */
  function getApprovalGroupItemMaxOrdNum(approvalGroupIdIn in integer) return integer;
  function getApprovalGroupMaxOrderNumber(applicationIdIn in integer) return integer;
  function getApprovalGroupOrderNumber(applicationIdIn in integer,
                                       approvalGroupIdIn in integer) return integer;
  function getChildVersionStartDate(approvalGroupIdIn integer,
                                    applicationIdIn in integer) return varchar2;
  function getDescription(approvalGroupIdIn in integer) return varchar2;
  function getId(nameIn in varchar2) return integer;
  function getItemApprovalGroupId(approvalGroupItemIdIn in integer) return integer;
  function getItemId(approvalGroupIdIn in integer,
                     parameterIn in varchar2,
                     parameterNameIn in varchar2) return integer;
  function getItemParameter(approvalGroupItemIdIn in integer) return varchar2;
  function getItemParameterName(approvalGroupItemIdIn in integer) return varchar2;
  function getName(approvalGroupIdIn in integer,
                   effectiveDateIn in date default sysdate) return varchar2;
  function getParentVersionStartDate(approvalGroupIdIn integer) return varchar2;
  function getOrderNumberCount(approvalGroupIdIn in integer,
                               newGroupMemberIn in boolean) return integer;
  function getQueryString(approvalGroupIdIn in integer,
                         effectiveDateIn in date default sysdate) return varchar2;
  function getIsStatic(approvalGroupIdIn in integer) return varchar2;
  function getItemOrderNumber(approvalGroupItemIdIn in integer) return integer;
  function getVotingRegime(approvalGroupIdIn in integer,
                           applicationIdIn in integer) return varchar2;
  function groupIsInGroup(groupIdIn in integer,
                          possiblyNestedGroupIdIn in integer) return boolean;

  function hasGroupChanged2(approvalGroupIdIn in integer,
                           nameIn in varchar2 default null,
                           descriptionIn in varchar2 default null,
                           isStaticIn in varchar2 default null,
                           queryStringIn in varchar2 default null) return boolean;

  function hasGroupChanged(approvalGroupIdIn in integer,
                           nameIn in varchar2 default null,
                           descriptionIn in varchar2 default null,
                           isStaticIn in varchar2 default null,
                           queryStringIn in varchar2 default null,
                           orderNumberIn in integer,
                           orderNumberUniqueIn in varchar2,
                           votingRegimeIn in varchar2,
                           applicationIdIn in integer) return boolean;
  function isInUse(approvalGroupIdIn in integer) return boolean;
  function isSeeded(approvalGroupIdIn in integer) return boolean;

  function isStatic(approvalGroupIdIn in integer,
                    effectiveDateIn in date default sysdate) return boolean;
  function itemOrderNumberUnique(approvalGroupIdIn in integer,
                                 orderNumberIn in integer) return boolean;
  function new(nameIn in varchar2,
               descriptionIn in varchar2,
               isStaticIn in varchar2 default null,
               queryStringIn in varchar2 default null,
               newStartDateIn in date default null,
               approvalGroupIdIn in integer default null,
               finalizeIn in boolean default false,
               updateActionIn in boolean default false) return integer;
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
                                parentVersionStartDateIn in date) return integer;
  function orderNumberUnique(applicationIdIn in integer,
                             orderNumberIn in integer) return boolean;
  procedure change(approvalGroupIdIn in integer,
                   nameIn in varchar2 default null,
                   descriptionIn in varchar2 default null,
                   isStaticIn in varchar2 default null,
                   queryStringIn in varchar2 default null,
                   updateActionIn in boolean,
                   newVersionStartDateIn in date,
                   finalizeIn in boolean default false);
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
                                 finalizeIn in boolean default false);
  procedure changeGroupConfig(applicationIdIn in integer,
                              approvalGroupIdIn in integer,
                              orderNumberUniqueIn in varchar2,
                              orderNumberIn in integer,
                              votingRegimeIn in varchar2,
                              newVersionStartDateIn in date,
                              finalizeIn in boolean default false);
  procedure changeApprovalGroupItem(approvalGroupIdIn in integer,
                                    itemIdIn in integer,
                                    parameterIn in varchar2 default null,
                                    parameterNameIn in varchar2,
                                    newOrderNumberIn in integer,
                                    orderNumberUniqueIn in varchar2 default null,
                                    parentVersionStartDateIn in date);
  procedure decrementGroupItemOrderNumbers(approvalGroupIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false);
  procedure decrementGroupOrderNumbers(applicationIdIn in integer,
                                       orderNumberIn in integer,
                                       finalizeIn in boolean default false);
  procedure getAllowedNestedGroups(groupIdIn in integer,
                                   allowedNestedGroupIdsOut out nocopy ame_util.stringList,
                                   allowedNestedGroupNamesOut out nocopy ame_util.stringList);
  procedure getApprovalGroupItemList(approvalGroupIdIn in integer,
                                     itemListOut out nocopy ame_util.idList,
                                     orderListOut out nocopy ame_util.idList,
                                     descriptionListOut out nocopy ame_util.longStringList,
                                     invalidMembersOut out nocopy boolean);
  procedure getApprovalGroupList(groupListOut out nocopy ame_util.idList);
  procedure getApprovalGroupList2(applicationIdIn in integer,
                                  groupListOut out nocopy ame_util.idList);
  /*
    getGroupMembers returns the person and user IDs of approvers already in a group,
    and the approver type of each ID.  This list includes members of nested groups.
    Only static members of groups using their static lists are included.
  */
  procedure getGroupMembers(approvalGroupIdIn in integer,
                            memberIdsOut out nocopy ame_util.longStringList,
                            memberTypesOut out nocopy ame_util.stringList);
  procedure getInvalidApprGroupItemList(approvalGroupIdIn  in integer,
                                        itemListOut out nocopy ame_util.idList);
                                     /*
  procedure getOrderNumbers(approvalGroupIdIn in integer,
                            orderNumbersOut out nocopy ame_util.stringList);
  */
  /* Only ame_engine.getRuntimeGroupMembers should call ame_approval_group_pkg.getRuntimeGroupMembers. */

  procedure incrementGroupItemOrderNumbers(approvalGroupIdIn in integer,
                                           approvalGroupItemIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false);
  procedure incrementGroupOrderNumbers(applicationIdIn in integer,
                                       approvalGroupIdIn in integer,
                                       orderNumberIn in integer,
                                       finalizeIn in boolean default false);
  procedure newApprovalGroupConfig(approvalGroupIdIn in integer,
                                   applicationIdIn in integer default null,
                                   orderNumberIn in integer default null,
                                   orderNumberUniqueIn in varchar2 default ame_util.yes,
                                   votingRegimeIn in varchar2 default ame_util.serializedVoting,
                                   finalizeIn in boolean default false);
  procedure remove(approvalGroupIdIn in integer,
                   parentVersionStartDateIn in date);
  procedure removeApprovalGroupItem(approvalGroupIdIn in integer,
                                    approvalGroupItemsIn in ame_util.idList,
                                    parentVersionStartDateIn in date);
  /*
    setGroupMembers2 updates ame_approval_group_members for the group with ID groupIdIn.
    If endDateIn is not null, setGroupMembers2 uses the ame_approval_group_items entries
    with end_date = endDateIn.  (This enables a bug fix in amem0015.sql.)
    If the raiseError parameter is true, then this procedure raises an error
    when ever a member is not active in wf_roles.
  */
  procedure setGroupMembers2(groupIdIn in integer,
                             effectiveDateIn in date default sysdate,
                             raiseError in boolean);
  procedure setGroupMembers(groupIdIn in integer,
                            effectiveDateIn in date default sysdate);
end ame_approval_group_pkg;

 

/
