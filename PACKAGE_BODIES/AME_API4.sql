--------------------------------------------------------
--  DDL for Package Body AME_API4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API4" as
/* $Header: ameeapi4.pkb 120.0 2005/07/26 05:56 mbocutt noship $ */
  procedure getGroupMembers(applicationIdIn       in number,
                            transactionTypeIn     in varchar2,
                            transactionIdIn       in varchar2,
                            groupIdIn             in number,
                            memberOrderNumbersOut out nocopy ame_util.idList,
                            memberPersonIdsOut    out nocopy ame_util.idList,
                            memberUserIdsOut      out nocopy ame_util.idList) as
    errorCode           integer;
    errorMessage        ame_util.longestStringType;
    memberNames         ame_util.longStringList;
    memberDisplayNames  ame_util.longStringList;
    memberOrigSystemIds ame_util.idList;
    memberOrigSystems   ame_util.stringList;
    tempOrigSystem      ame_util.stringType;
    wrongOrigSystem exception;
    begin
        ame_api3.getGroupMembers4(applicationIdIn        => applicationIdIn,
                                  transactionTypeIn      => transactionTypeIn,
                                  transactionIdIn        => transactionIdIn,
                                  groupIdIn              => groupIdIn,
                                  memberNamesOut         => memberNames,
                                  memberOrderNumbersOut  => memberOrderNumbersOut,
                                  memberDisplayNamesOut  => memberDisplayNames,
                                  memberOrigSystemIdsOut => memberOrigSystemIds,
                                  memberOrigSystemsOut   => memberOrigSystems);
       for i in 1 .. memberNames.count loop
         if memberOrigSystems(i) = ame_util.perOrigSystem then
           memberPersonIdsOut(i) := memberOrigSystemIds(i);
           memberUserIdsOut(i) := null;
         elsif memberOrigSystems(i) = ame_util.fndUserOrigSystem then
           memberPersonIdsOut(i) := null;
           memberUserIdsOut(i) := memberOrigSystemIds(i);
         else
           tempOrigSystem := memberOrigSystems(i);
           raise wrongOrigSystem;
         end if;
       end loop;
    exception
      when wrongOrigSystem then
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => tempOrigSystem);
        ame_util.runtimeException(packageNameIn => 'ame_api4',
                            routineNameIn => 'getGroupMembers',
                            exceptionNumberIn => errorCode,
                            exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                  errorMessage);
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api4',
                                  routineNameIn => 'getGroupMembers',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end getGroupMembers;
end ame_api4;

/
