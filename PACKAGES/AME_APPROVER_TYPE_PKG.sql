--------------------------------------------------------
--  DDL for Package AME_APPROVER_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_TYPE_PKG" AUTHID CURRENT_USER as
  /* $Header: ameoatyp.pkh 120.1.12010000.2 2009/08/03 14:14:05 prasashe ship $ */
  function getApproverDescription(nameIn in varchar2) return varchar2;
  function getApproverDescription2
             (origSystemIn       in varchar2
             ,origSystemIdIn     in integer
             ,raiseNoDataFoundIn in varchar2 default 'true') return varchar2;
  function getApproverDisplayName(nameIn in varchar2) return varchar2;
  function getApproverDisplayName2(origSystemIn in varchar2,
                                   origSystemIdIn in integer) return varchar2;
  function getApproverDisplayName3(nameIn in varchar2) return varchar2;
  function getApproverDisplayName4(nameIn in varchar2) return varchar2;
  function getApproverOrigSystem(nameIn in varchar2) return varchar2;
  function getApproverOrigSystem2(nameIn in varchar2) return varchar2;
  function getApproverOrigSystem3(nameIn in varchar2) return varchar2;
  function getApproverOrigSystemId(nameIn in varchar2) return varchar2;
  function getApproverTypeId(origSystemIn in varchar2) return integer;
  function getApproverTypeOrigSystem(approverTypeIdIn in integer) return varchar2;
  function getApproverTypeDisplayName(approverTypeIdIn in integer) return varchar2;
  function getOrigSystemDisplayName(origSystemIn in varchar2) return varchar2;
  function getQueryProcedure(approverTypeIdIn in integer) return varchar2;
  function getWfRolesName
             (origSystemIn in varchar2
             ,origSystemIdIn in integer
             ,raiseNoDataFoundIn in varchar2 default 'true') return varchar2;
  function allowsAllApproverTypes(actionTypeIdIn in integer) return boolean;
  function isASubordinate(approverIn in ame_util.approverRecord2,
                          possibleSubordApproverIn in ame_util.approverRecord2) return boolean;
  function validateApprover(nameIn in varchar2) return boolean;
  procedure fndUsrApproverQuery(criteria1In in varchar2 default null,
                                criteria2In in varchar2 default null,
                                criteria3In in varchar2 default null,
                                criteria4In in varchar2 default null,
                                criteria5In in varchar2 default null,
                                excludeListCountIn in integer,
                                approverNamesOut out nocopy varchar2,
                                approverDescriptionsOut out nocopy varchar2);
  procedure fndRespApproverQuery(criteria1In in varchar2 default null,
                                 criteria2In in varchar2 default null,
                                 criteria3In in varchar2 default null,
                                 criteria4In in varchar2 default null,
                                 criteria5In in varchar2 default null,
                                 excludeListCountIn in integer,
                                 approverNamesOut out nocopy varchar2,
                                 approverDescriptionsOut out nocopy varchar2);
  procedure getApproverDescAndValidity(nameIn         in  varchar2,
                                       descriptionOut out nocopy varchar2,
                                       validityOut    out nocopy boolean);
  procedure getApproverOrigSystemAndId(nameIn in varchar2,
                                       origSystemOut out nocopy varchar2,
                                       origSystemIdOut out nocopy integer);
  procedure getApprovalTypes(approverTypeIdIn in integer,
                             actionTypeNamesOut out nocopy ame_util.stringList);
  procedure getApproverTypeQueryData(approverTypeIdIn in integer,
                                     queryVariableLabelsOut out nocopy ame_util.longStringList,
                                     variableLovQueriesOut out nocopy ame_util.longStringList);
  procedure getAvailableApproverTypes(applicationIdIn in integer default null,
                                      topLabelIn in varchar2 default null,
                                      topValueIn in varchar2 default null,
                                      approverTypeIdsOut out nocopy ame_util.stringList,
                                      approverTypeNamesOut out nocopy ame_util.stringList);
  procedure getAvailableApproverTypes2(actionTypeIdIn in integer,
                                       approverTypeIdsOut out nocopy ame_util.stringList,
                                       approverTypeNamesOut out nocopy ame_util.stringList);
  procedure getAvailableApproverTypes3(actionTypeIdIn in integer,
                                       approverTypeIdsOut out nocopy ame_util.idList);
  procedure getOrigSystemIdAndDisplayName(nameIn in varchar2,
                                          origSystemOut out nocopy varchar2,
                                          origSystemIdOut out nocopy integer,
                                          displayNameOut out nocopy varchar2);
  procedure getSuperior(approverIn in ame_util.approverRecord2,
                        superiorOut out nocopy ame_util.approverRecord2);
  procedure getSurrogate(origSystemIn in varchar2,
                         origSystemIdIn in integer,
                         origSystemIdOut out nocopy integer,
                         wfRolesNameOut out nocopy varchar2,
                         displayNameOut out nocopy varchar2);
  procedure getWfRolesNameAndDisplayName(origSystemIn in varchar2,
                                         origSystemIdIn in integer,
                                         nameOut out nocopy ame_util.longStringType,
                                         displayNameOut out nocopy ame_util.longStringType);
  procedure perApproverQuery(criteria1In in varchar2 default null,
                             criteria2In in varchar2 default null,
                             criteria3In in varchar2 default null,
                             criteria4In in varchar2 default null,
                             criteria5In in varchar2 default null,
                             excludeListCountIn in integer,
                             approverNamesOut out nocopy varchar2,
                             approverDescriptionsOut out nocopy varchar2);
  procedure posApproverQuery(criteria1In in varchar2 default null,
                             criteria2In in varchar2 default null,
                             criteria3In in varchar2 default null,
                             criteria4In in varchar2 default null,
                             criteria5In in varchar2 default null,
                             excludeListCountIn in integer,
                             approverNamesOut out nocopy varchar2,
                             approverDescriptionsOut out nocopy varchar2);
  procedure processApproverQuery(selectClauseIn in varchar2,
                                 approverNamesOut out nocopy ame_util.longStringList,
                                 approverDisplayNamesOut out nocopy ame_util.longStringList);
  procedure processApproverQuery2(selectClauseIn in varchar2,
                                  approverNamesOut out nocopy ame_util.longStringList);
  procedure newApproverTypeUsage(actionTypeIdIn in integer,
                                 approverTypeIdIn in integer,
                                 processingDateIn in date);
  procedure newApproverTypeUsages(actionTypeIdIn in integer,
                                  approverTypeIdsIn in ame_util.idList,
                                  finalizeIn in boolean default false,
                                  processingDateIn in date default null);
  procedure removeApproverTypeUsage(actionTypeIdIn in integer,
                                    approverTypeIdIn in integer,
                                    processingDateIn in date default null);
  procedure removeApproverTypeUsages(actionTypeIdIn in integer,
                                     approverTypeIdsIn in ame_util.idList default ame_util.emptyIdList,
                                     finalizeIn in boolean default false,
                                     processingDateIn in date default null);
end ame_approver_type_pkg;

/
