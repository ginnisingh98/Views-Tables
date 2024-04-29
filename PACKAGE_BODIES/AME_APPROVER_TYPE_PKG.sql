--------------------------------------------------------
--  DDL for Package Body AME_APPROVER_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVER_TYPE_PKG" as
/* $Header: ameoatyp.pkb 120.4.12010000.3 2009/08/03 14:15:19 prasashe ship $ */
  function getApproverDescription(nameIn in varchar2) return varchar2 as
    descriptionOut ame_util.longestStringType;
    validityOut boolean;
    begin
      /*
        getApproverDescAndValidity checks for invalid approvers and produces
        a description string even for these, prepending to an invalid approver's
        description a label identifying the approver as invalid.If the approver is valid,
        the wf_roles display name is returned.
      */
      getApproverDescAndValidity(nameIn => nameIn,
                                 descriptionOut => descriptionOut,
                                 validityOut => validityOut);
      return(descriptionOut);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApproverDescription;

  function getApproverDescription2(origSystemIn       in varchar2
                                  ,origSystemIdIn     in integer
                                  ,raiseNoDataFoundIn in varchar2 default 'true')
  return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    name wf_roles.display_name%type;
    begin
      name := getWfRolesName(origSystemIn       => origSystemIn
                            ,origSystemIdIn     => origSystemIdIn
                            ,raiseNoDataFoundIn => raiseNoDataFoundIn);
      if(name is not null) then
        return getApproverDisplayName(nameIn => name);
      else
        select display_name
          into name
          from wf_local_roles
         where ((orig_system = origSystemIn and
                 orig_system_id = origSystemIdIn) or
                (origSystemIn = ame_util.fndUserOrigSystem and
                 orig_system = ame_util.perOrigSystem and
                 orig_system_id = (select employee_id
                                     from fnd_user
                                    where user_id = origSystemIdIn)))
           and status = 'ACTIVE'
           and (orig_system not in (ame_util.fndUserOrigSystem,ame_util.perOrigSystem)
                or exists
                (select null
                   from fnd_user u
                  where u.user_name = wf_local_roles.name))
           and not exists (
                select null from wf_local_roles wf2
                 where wf_local_roles.orig_system = wf2.orig_system
                   and wf_local_roles.orig_system_id = wf2.orig_system_id
                   and wf_local_roles.start_date > wf2.start_date)
           and rownum < 2;
      end if;
      return('Invalid Approver: ' || name);
    exception
      when no_data_found then
        if(raiseNoDataFoundIn = 'true') then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn  => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => origSystemIdIn,
                                              tokenNameTwoIn  => 'ORIG_SYSTEM',
                                              tokenValueTwoIn => origSystemIn
                                               );
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDescription2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        end if;
        return(null);
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                  routineNameIn => 'getApproverDescription2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return(null);
    end getApproverDescription2;
  function getApproverDisplayName(nameIn in varchar2) return varchar2 as
    displayName wf_roles.display_name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select display_name
        into displayName
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      return(displayName);
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDisplayName',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                   attributeCodeIn => 'AME_INVALID_COLON') || nameIn);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDisplayName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                   attributeCodeIn => 'AME_INVALID_COLON') || nameIn);
    end getApproverDisplayName;
  function getApproverDisplayName2(origSystemIn in varchar2,
                                   origSystemIdIn in integer) return varchar2 as
    displayName wf_roles.display_name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      /*
        If an fnd_user entry has a non-null employee_id (person ID) value, it gets
        converted to the PER originating system in wf_roles; otherwise, it gets
        converted to the FND_USR originating system.  As just one of these will
        happen, we can match both originating systems in a single-row query.
        The order-by-name clause and rownum < 2 condition are necessary because we
        have encountered data problems where there are several entries for a given
        orig_system and orig_system_id pair.
      */
      select display_name
        into displayName
        from wf_roles
        where
          ((orig_system = origSystemIn and
            orig_system_id = origSystemIdIn) or
           (origSystemIn = ame_util.fndUserOrigSystem and
            orig_system = ame_util.perOrigSystem and
            orig_system_id = (select employee_id
                                from fnd_user
                                where
                                  user_id = origSystemIdIn and
                                  sysdate between
                                    start_date and
                                    nvl(end_date, sysdate)))) and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
           (orig_system not in (ame_util.fndUserOrigSystem,ame_util.perOrigSystem)
            or exists (select null
                     from fnd_user u
                    where u.user_name = wf_roles.name
                      and trunc(sysdate) between u.start_date
                      and nvl(u.end_date,trunc(sysdate)))) and
           not exists (
                select null from wf_roles wf2
                 where wf_roles.orig_system = wf2.orig_system
                   and wf_roles.orig_system_id = wf2.orig_system_id
                   and wf_roles.start_date > wf2.start_date
                      ) and
          rownum < 2;
      return(displayName);
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn  => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => origSystemIdIn,
                                              tokenNameTwoIn  => 'ORIG_SYSTEM',
                                              tokenValueTwoIn => origSystemIn
                                               );
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDisplayName2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDisplayName2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverDisplayName2;
    /*
      This procedure returns the display name, origsystemid and origsystem for the given role name.
      If the name is valid wf_roles name, validityOut is returned as true.If the name is not found,
      validityOut is returned as false and the display name, origsystemid and origsystem are returned
      from the wf_local_roles.
    */
    procedure getApproverDetails(nameIn                in varchar2
                                 ,validityOut          out NOCOPY varchar2
                                 ,displayNameOut       out NOCOPY varchar2
                                 ,origSystemIdOut      out NOCOPY integer
                                 ,origSystemOut        out NOCOPY varchar2 ) as
    begin
      validityOut := 'INVALID';
      select
        display_name,
        orig_system,
        orig_system_id
        into
          displayNameOut,
          origSystemOut,
          origSystemIdOut
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
            sysdate < expiration_date) and
          rownum < 2;
        validityOut := 'VALID';
      exception
        when no_data_found then
          begin
            /*
              When the approver is not valid in WF_ROLES, try to get the approver info
              from WF_LOCAL_ROLES.  (It may still be there, even though the approver is
              invalid.)  If not found in WF_LOCAL_ROLES, return nameIn in descriptionOut.
              See bug 3286313.
            */
            select
              display_name,
              orig_system,
              orig_system_id
              into
                displayNameOut,
                origSystemOut,
                origSystemIdOut
              from wf_local_roles
              where
                name = nameIn and
                rownum < 2;
	    validityOut := 'INACTIVE';
            exception
              when no_data_found then
                displayNameOut := nameIn;
                origSystemOut  := 'PER';
          end;
    end getApproverDetails;
  /*
    This function returns the displayname for the given wf_roles name.If the name is not valid,then
    it returns the string 'Inactive: <old display name>'.If the display name is not available, then it
    returns the string 'Invalid: <role_name>'.
  */
  function getApproverDisplayName3(nameIn in varchar2) return varchar2 as
    validityOut       varchar2(100);
    displayNameOut    ame_util.longestStringType;
    origSystemIdOut   integer;
    origSystemOut     wf_roles.orig_system%type;
    begin
      getApproverDetails(nameIn           => nameIn
                        ,validityOut      => validityOut
                        ,displayNameOut   => displayNameOut
                        ,origSystemIdOut  => origSystemIdOut
                        ,origSystemOut    => origSystemOut );
      if(validityOut = 'VALID') then
        return displayNameOut;
      else
        return(ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                 attributeCodeIn => 'AME_INVALID_COLON') || getOrigSystemDisplayName(origSystemIn => origSystemOut) || ':' || displayNameOut);
      end if;
    end getApproverDisplayName3;
  /*
    This function returns the displayname for the given wf_roles name.If the name is not valid,then
    it returns the string 'Invalid : <origSystem display name> : <old display name>'
  */
  function getApproverDisplayName4(nameIn in varchar2) return varchar2 as
    validityOut       varchar2(100);
    displayNameOut    ame_util.longestStringType;
    origSystemIdOut   integer;
    origSystemOut     wf_roles.orig_system%type;
    begin
      getApproverDetails(nameIn           => nameIn
                        ,validityOut      => validityOut
                        ,displayNameOut   => displayNameOut
                        ,origSystemIdOut  => origSystemIdOut
                        ,origSystemOut    => origSystemOut );
      if(validityOut = 'VALID') then
        return displayNameOut;
      elsif(validityOut = 'INVALID') then
        return(ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                 attributeCodeIn => 'AME_INVALID_COLON') || displayNameOut);
      else
        return ame_util.getMessage(applicationShortNameIn => 'PER',
				   messageNameIn          => 'AME_400790_INACTIVE_APPROVER',
				   tokenNameOneIn         => 'NAME',
				   tokenValueOneIn        => displayNameOut);

      end if;
    end getApproverDisplayName4;
  function getApproverOrigSystem(nameIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    origSystem wf_roles.orig_system%type;
    begin
      select orig_system
        into origSystem
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      return(origSystem);
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystem',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverOrigSystem;
  function getApproverOrigSystem2(nameIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    origSystem wf_roles.orig_system%type;
    begin
      select orig_system
        into origSystem
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      return(origSystem);
      exception
        when no_data_found then
          begin
              /*
                When the approver is not valid in WF_ROLES, try to get the approver info
                from WF_LOCAL_ROLES.  (It may still be there, even though the approver is
                invalid.)  If not found in WF_LOCAL_ROLES, return nameIn in descriptionOut.
                See bug 3286313.
              */
              select
                orig_system
                into
                  origSystem
                from wf_local_roles
                where
                  name = nameIn and
                  rownum < 2;
              return(origSystem);
              exception
                when no_data_found then
                  origSystem := 'PER';
                  return(origSystem);
          end;
    end getApproverOrigSystem2;
  function getApproverOrigSystem3(nameIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    origSystem wf_roles.orig_system%type;
    begin
      select orig_system
        into origSystem
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      return(origSystem);
      exception
        when no_data_found then
          begin
              /*
                When the approver is not valid in WF_ROLES, try to get the approver info
                from WF_LOCAL_ROLES.  (It may still be there, even though the approver is
                invalid.)  If not found in WF_LOCAL_ROLES, return nameIn in descriptionOut.
                See bug 3286313.
              */
              select
                orig_system
                into
                  origSystem
                from wf_local_roles
                where
                  name = nameIn and
                  rownum < 2;
              return(origSystem);
              exception
                when no_data_found then
                  origSystem := null;
                  return(origSystem);
          end;
    end getApproverOrigSystem3;
  function getApproverOrigSystemId(nameIn in varchar2) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    origSystemId wf_roles.orig_system_id%type;
    begin
      select orig_system_id
        into origSystemId
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      return(origSystemId);
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                tokenNameOneIn  => 'NAME',
                                tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystemId',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystemId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverOrigSystemId;
  function getApproverTypeId(origSystemIn in varchar2) return integer as
    approverTypeId ame_approver_types.approver_type_id%type;
    begin
      select approver_type_id
        into approverTypeId
        from ame_approver_types
        where
          orig_system = origSystemIn and
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) and
          rownum < 2;
      return(approverTypeId);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverTypeId;
  function getApproverTypeOrigSystem(approverTypeIdIn in integer) return varchar2 as
    origSystem ame_approver_types.orig_system%type;
    begin
      select orig_system
        into origSystem
        from ame_approver_types
        where
          approver_type_id = approverTypeIdIn and
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) and
          rownum < 2;
      return(origSystem);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverTypeOrigSystem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverTypeOrigSystem;
  function getApproverTypeDisplayName(approverTypeIdIn in integer) return varchar2 as
    origSystem ame_approver_types.orig_system%type;
    begin
      select orig_system
        into origSystem
        from ame_approver_types
        where
          approver_type_id = approverTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) and
          rownum < 2;
      return(ame_approver_type_pkg.getOrigSystemDisplayName(origSystemIn => origSystem));
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverTypeDisplayName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApproverTypeDisplayName;
  function getOrigSystemDisplayName(origSystemIn in varchar2) return varchar2 as
    origDisplayName fnd_lookups.meaning%type;
    begin
      select meaning
        into origDisplayName
        from fnd_lookups
        where
          lookup_type = ame_util.origSystemLookupType and
          lookup_code = origSystemIn and
          sysdate between
            start_date_active and
            nvl(end_date_active, sysdate) and
          rownum < 2;
      return(origDisplayName);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getOrigSystemDisplayName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getOrigSystemDisplayName;
  function getQueryProcedure(approverTypeIdIn in integer) return varchar2 as
    queryProcedure ame_approver_types.query_procedure%type;
    begin
      select query_procedure
      into queryProcedure
      from ame_approver_types
      where
        approver_type_id = approverTypeIdIn and
        sysdate between
          start_date and
          nvl(end_date - ame_util.oneSecond, sysdate) and
        rownum < 2;
      return(queryProcedure);
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getQueryProcedure',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getQueryProcedure;
  function getWfRolesName(origSystemIn in varchar2,
                          origSystemIdIn in integer,
                          raiseNoDataFoundIn in varchar2 default 'true') return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    name wf_roles.name%type;
    begin
      /*
        If an fnd_user entry has a non-null employee_id (person ID) value, it gets
        converted to the PER originating system in wf_roles; otherwise, it gets
        converted to the FND_USR originating system.  As just one of these will
        happen, we can match both originating systems in a single-row query.
        The order-by-name clause and rownum < 2 condition are necessary because we
        have encountered data problems where there are several entries for a given
        orig_system and orig_system_id pair.
      */
      select name
        into name
        from wf_roles
        where
          ((orig_system = origSystemIn and
            orig_system_id = origSystemIdIn) or
           (origSystemIn = ame_util.fndUserOrigSystem and
            orig_system = ame_util.perOrigSystem and
            orig_system_id = (select employee_id
                                from fnd_user
                                where
                                  user_id = origSystemIdIn and
                                  sysdate between
                                    start_date and
                                    nvl(end_date, sysdate)))) and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
           (orig_system not in (ame_util.fndUserOrigSystem,ame_util.perOrigSystem)
            or exists (select null
                     from fnd_user u
                    where u.user_name = wf_roles.name
                      and trunc(sysdate) between u.start_date
                      and nvl(u.end_date,trunc(sysdate)))) and
           not exists (
                select null from wf_roles wf2
                 where wf_roles.orig_system = wf2.orig_system
                   and wf_roles.orig_system_id = wf2.orig_system_id
                   and wf_roles.start_date > wf2.start_date
                      ) and
          rownum < 2;
      return(name);
      exception
        when no_data_found then
          if(raiseNoDataFoundIn = 'true') then
            errorCode := -20001;
            errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn  => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => origSystemIdIn,
                                              tokenNameTwoIn  => 'ORIG_SYSTEM',
                                              tokenValueTwoIn => origSystemIn
                                               );
            ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                      routineNameIn => 'getWfRolesName',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
          end if;
          return(null);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getWfRolesName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getWfRolesName;
  function allowsAllApproverTypes(actionTypeIdIn in integer) return boolean as
    rowCount integer;
    begin
      select count(*)
        into rowCount
        from ame_approver_type_usages
        where
          action_type_id = actionTypeIdIn and
          approver_type_id = ame_util.anyApproverType and
          sysdate between
            start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if(rowCount > 0) then
        return(true);
      end if;
      return false;
      exception
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'allowsAllApproverTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end allowsAllApproverTypes;
  function isASubordinate(approverIn in ame_util.approverRecord2,
                          possibleSubordApproverIn in ame_util.approverRecord2) return boolean is
    errorCode integer;
    errorMessage ame_util.longestStringType;
    noSurrogateException exception;
    origSystemId integer;
    positionStructureId integer;
    superiorId integer;
    superiorFound boolean;
    begin
        if(approverIn.orig_system <> possibleSubordApproverIn.orig_system) then
          return false;
        end if;
        if(approverIn.orig_system = ame_util.perOrigSystem) then
          superiorFound := false;
          origSystemId := possibleSubordApproverIn.orig_system_id;
          loop
            select supervisor_id
            into superiorId
            from per_all_assignments_f
            where
              per_all_assignments_f.person_id = origSystemId and
              per_all_assignments_f.primary_flag = 'Y' and
              per_all_assignments_f.assignment_type in ('E','C') and
              per_all_assignments_f.assignment_status_type_id not in
                (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN') and
              trunc(sysdate) between
                per_all_assignments_f.effective_start_date and
                per_all_assignments_f.effective_end_date;
            if(superiorId is null) then
              exit;
            elsif(superiorId = approverIn.orig_system_id) then
              superiorFound := true;
              exit;
            end if;
            origSystemId := superiorId;
          end loop;
          return(superiorFound);
        elsif(approverIn.orig_system = ame_util.fndUserOrigSystem) then
          /* No hierarchy defined here, so always return false. */
          return(false);
        elsif(approverIn.orig_system = ame_util.posOrigSystem) then
          superiorFound := false;
          origSystemId := possibleSubordApproverIn.orig_system_id;
          positionStructureId :=
             ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.nonDefPosStructureAttr);
          loop
            select str.parent_position_id
              into superiorId
              from per_pos_structure_elements str,
                   per_pos_structure_versions psv
             where
                   str.subordinate_position_id  = origSystemId and
                   str.pos_structure_version_id = psv.pos_structure_version_id and
                   trunc(sysdate) between  psv.date_from and nvl( psv.date_to , sysdate) and
                   psv.position_structure_id    =
                     (select position_structure_id
                        from per_position_structures
                       where
                            ((positionStructureId is not null and
                              position_structure_id = positionStructureId) or
                             (positionStructureId is null and
                              business_group_id = str.business_group_id and
                              primary_position_flag = 'Y')));
            if(superiorId is null) then
              exit;
            elsif(superiorId = approverIn.orig_system_id) then
              superiorFound := true;
              exit;
            end if;
            origSystemId := superiorId;
          end loop;
          return(superiorFound);
        elsif(approverIn.orig_system = ame_util.fndRespOrigSystem) then
          /* To be coded later.  For now just return false. */
          return(false);
        else
          return(false);
        end if;
      exception
        when no_data_found then
          return false;
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'isASubordinate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end isASubordinate;
  function validateApprover(nameIn in varchar2) return boolean as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    rowCount integer;
    begin
      select count(*)
        into rowCount
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
          sysdate < expiration_date);
      if(rowCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'validateApprover',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(false);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'validateApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end validateApprover;
  procedure fndUsrApproverQuery(criteria1In in varchar2 default null,
                                criteria2In in varchar2 default null,
                                criteria3In in varchar2 default null,
                                criteria4In in varchar2 default null,
                                criteria5In in varchar2 default null,
                                excludeListCountIn in integer,
                                approverNamesOut out nocopy varchar2,
                                approverDescriptionsOut out nocopy varchar2) as
    cursor fndUsrCursor(userNameIn in varchar2,
                        emailAddressIn in varchar2,
                        truncatedSysdateIn in date,
                        rowsToExcludeIn in integer) is
      select
        /* The compiler forces passing arguments by position in the following function calls. */
        getWfRolesName(ame_util.fndUserOrigSystem, user_id) approver_name,
        getApproverDescription(getWfRolesName(ame_util.fndUserOrigSystem, user_id)) approver_description
        from
          fnd_user,
          wf_roles
        where
          wf_roles.orig_system_id = fnd_user.user_id and
          wf_roles.orig_system = ame_util.fndUserOrigSystem and
          wf_roles.status = 'ACTIVE' and
          wf_roles.name = fnd_user.user_name and
          (userNameIn is null or
           upper(fnd_user.user_name) like upper(replace(userNameIn, '''', '''''')) || '%') and
          (emailAddressIn is null or
           upper(fnd_user.email_address) like upper(replace(emailAddressIn, '''', '''''')) || '%') and
          truncatedSysdateIn between
            fnd_user.start_date and
            nvl(fnd_user.end_date, truncatedSysdateIn) and
            rownum < 52 + rowsToExcludeIn /* This prevents oversized fetches. */
            order by fnd_user.user_name;
      /* local variables */
    approverNames ame_util.longStringList;
    approverDescriptions ame_util.longStringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    truncatedSysdate date;
    /* procedure body */
    begin
      /*
        Fetch the cursor into approverNames and approverDescriptions.  Note that
        the cursors will only fetch at most 51 + excludeIdListIn.count rows, preventing
        oversized fetches.
      */
      truncatedSysdate := trunc(sysdate);
      open fndUsrCursor(userNameIn => criteria1In,
                        emailAddressIn => criteria2In,
                        truncatedSysdateIn => truncatedSysdate,
                        rowsToExcludeIn => excludeListCountIn);
      fetch fndUsrCursor bulk collect
        into
          approverNames,
          approverDescriptions;
      close fndUsrCursor;
      /* Check for too many results. */
      if(approverNames.count - excludeListCountIn > 50) then
        raise ame_util.tooManyApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /* Check for zero approvers. */
      if(approverNames.count = 0) then
        raise ame_util.zeroApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /*
        Return the results.  (ame_util.serializeApprovers procedure will raise
        ame_util.tooManyApproversException if it can't serialize both input lists.)
      */
      ame_util.serializeApprovers(approverNamesIn => approverNames,
                                  approverDescriptionsIn => approverDescriptions,
                                  maxOutputLengthIn => ame_util.longestStringTypeLength,
                                  approverNamesOut => approverNamesOut,
                                  approverDescriptionsOut => approverDescriptionsOut);
      exception
        when ame_util.tooManyApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400111_UIN_MANY_ROWS');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndUsrApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.zeroApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400110_UIN_NO_CURR_EMP');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndUsrApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndUsrApproverQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise;
    end fndUsrApproverQuery;
  procedure fndRespApproverQuery(criteria1In in varchar2 default null,
                             criteria2In in varchar2 default null,
                             criteria3In in varchar2 default null,
                             criteria4In in varchar2 default null,
                             criteria5In in varchar2 default null,
                             excludeListCountIn in integer,
                             approverNamesOut out nocopy varchar2,
                             approverDescriptionsOut out nocopy varchar2) as
    cursor respCursor(applicationNameIn    in varchar2,
                      responsibilityNameIn in varchar2,
                      truncatedSysdateIn   in date,
                      rowsToExcludeIn      in integer) is
      select
        getWfRolesName(ame_util.fndRespOrigSystem||resp.application_id, resp.responsibility_id) approver_name,
        getApproverDescription(getWfRolesName(ame_util.fndRespOrigSystem || resp.application_id,
                                              resp.responsibility_id)) approver_description
        from
          fnd_application_vl apps,
          fnd_responsibility_vl resp
        where
          (applicationNameIn is null or
           upper(apps.application_name) like upper(replace(applicationNameIn, '''', '''''')) || '%') and
          (responsibilityNameIn is null or
           upper(resp.responsibility_name) like upper(replace(responsibilityNameIn, '''', '''''')) || '%') and
          resp.application_id = apps.application_id and
          truncatedSysdateIn between
            resp.start_date and
            nvl(resp.end_date,truncatedSysdateIn) and
          rownum < 52 + rowsToExcludeIn /* This prevents oversized fetches. */
        order by apps.application_name;
      /* local variables */
    approverNames ame_util.longStringList;
    approverDescriptions ame_util.longStringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    truncatedSysdate date;
    /* procedure body */
    begin
      /*
        Fetch the cursor into approverNames and approverDescriptions.  Note that
        the cursors will only fetch at most 51 + excludeIdListIn.count rows, preventing
        oversized fetches.
      */
      truncatedSysdate := trunc(sysdate);
      open respCursor(applicationNameIn    => criteria1In,
                      responsibilityNameIn => criteria2In,
                      truncatedSysdateIn   => truncatedSysdate,
                      rowsToExcludeIn      => excludeListCountIn);
      fetch respCursor bulk collect
        into
          approverNames,
          approverDescriptions;
      close respCursor;
      /* Check for too many results. */
      if(approverNames.count - excludeListCountIn > 50) then
        raise ame_util.tooManyApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /* Check for zero approvers. */
      if(approverNames.count = 0) then
        raise ame_util.zeroApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /*
        Return the results.  (ame_util.serializeApprovers procedure will raise
        ame_util.tooManyApproversException if it can't serialize both input lists.)
      */
      ame_util.serializeApprovers(approverNamesIn => approverNames,
                                  approverDescriptionsIn => approverDescriptions,
                                  maxOutputLengthIn => ame_util.longestStringTypeLength,
                                  approverNamesOut => approverNamesOut,
                                  approverDescriptionsOut => approverDescriptionsOut);
      exception
        when ame_util.tooManyApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400111_UIN_MANY_ROWS');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndRespApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.zeroApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400110_UIN_NO_CURR_EMP');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndRespApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'fndRespApproverQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise;
    end fndRespApproverQuery;
  procedure getApproverDescAndValidity(nameIn in varchar2,
                                       descriptionOut out nocopy varchar2,
                                       validityOut out nocopy boolean) as
    origSystem wf_roles.orig_system%type;
    begin
      /*
        This function needs to return the same data for all approver types.  Do NOT modify this
        function to return extra data for specific approver types.  This function should return
        a string that will fit in an ame_util.longStringType.
      */
      validityOut := false;
      begin
        select
          display_name,
          orig_system
          into
            descriptionOut,
            origSystem
          from wf_roles
          where
            name = nameIn and
            status = 'ACTIVE' and
            (expiration_date is null or
             sysdate < expiration_date) and
            rownum < 2;
        validityOut := true;
        exception
          when no_data_found then
            begin
              /*
                When the approver is not valid in WF_ROLES, try to get the approver info
                from WF_LOCAL_ROLES.  (It may still be there, even though the approver is
                invalid.)  If not found in WF_LOCAL_ROLES, return nameIn in descriptionOut.
                See bug 3286313.
              */
              select
                display_name,
                orig_system
                into
                  descriptionOut,
                  origSystem
                from wf_local_roles
                where
                  name = nameIn and
                  rownum < 2;
              exception
                when no_data_found then
                  descriptionOut := nameIn;
            end;
      end;
      /*
        The following if statement reflects a kludge in the originating-system display-name
        data in fnd_lookups for FND responsibilities.  The kludge is permanent, so we have
        to accommodate it here.
      */
      if origSystem is not null then
       if(origSystem like ame_util.fndRespOrigSystem || '%') then
         origSystem := ame_util.fndRespOrigSystem;
       end if;
       descriptionOut :=
           ame_approver_type_pkg.getOrigSystemDisplayName(origSystemIn => origSystem)
           ||':  '
           ||descriptionOut;
      end if;
      if(not validityOut) then
        descriptionOut := ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                            attributeCodeIn => 'AME_INVALID_COLON') || descriptionOut;
      end if;
      exception
        when others then
          descriptionOut := ame_util.getLabel(attributeApplicationIdIn => ame_util.perFndAppId,
                                            attributeCodeIn => 'AME_INVALID_COLON') || nameIn;
          validityOut := false;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverDescAndValidity',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getApproverDescAndValidity;
  procedure getApproverOrigSystemAndId(nameIn in varchar2,
                                       origSystemOut out nocopy varchar2,
                                       origSystemIdOut out nocopy integer) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select
        orig_system,
        orig_system_id
        into
          origSystemOut,
          origSystemIdOut
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      exception
        when no_data_found then
          origSystemOut := null;
          origSystemIdOut := null;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystemAndId',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverOrigSystemAndId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          origSystemOut := null;
          origSystemIdOut := null;
          raise;
    end getApproverOrigSystemAndId;
  procedure getApprovalTypes(approverTypeIdIn in integer,
                             actionTypeNamesOut out nocopy ame_util.stringList) as
    cursor getApprovalTypeCursor is
      select name
        from
          ame_action_types,
          ame_approver_type_usages
        where
          ame_action_types.action_type_id = ame_approver_type_usages.action_type_id and
          approver_type_id = approverTypeIdIn and
          sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_approver_type_usages.start_date and
          nvl(ame_approver_type_usages.end_date - ame_util.oneSecond, sysdate);
    cursor getApprovalTypeCursor2 is
      select name
        from
          ame_action_types,
          ame_approver_type_usages
        where
          ame_action_types.action_type_id = ame_approver_type_usages.action_type_id and
          approver_type_id = ame_util.anyApproverType and
          sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_approver_type_usages.start_date and
          nvl(ame_approver_type_usages.end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    begin
       tempIndex := 1;
       for getApprovalTypeRec in getApprovalTypeCursor loop
         actionTypeNamesOut(tempIndex) := getApprovalTypeRec.name;
         tempIndex := tempIndex + 1;
       end loop;
       for getApprovalTypeRec in getApprovalTypeCursor2 loop
         actionTypeNamesOut(tempIndex) := getApprovalTypeRec.name;
         tempIndex := tempIndex + 1;
       end loop;
       exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApprovalTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          actionTypeNamesOut := ame_util.emptyStringList;
          raise;
    end getApprovalTypes;
  procedure getApproverTypeQueryData(approverTypeIdIn in integer,
                                     queryVariableLabelsOut out nocopy ame_util.longStringList,
                                     variableLovQueriesOut out nocopy ame_util.longStringList) as
    queryVariableLabels ame_util.longStringList;
    variableLovQueries ame_util.longStringList;
    begin
      /* select queryVariableLabels and variableLovQueries into plsql tables */
      select
        query_variable_1_label,
        query_variable_2_label,
        query_variable_3_label,
        query_variable_4_label,
        query_variable_5_label,
        variable_1_lov_query,
        variable_2_lov_query,
        variable_3_lov_query,
        variable_4_lov_query,
        variable_5_lov_query
      into
        queryVariableLabels(1),
        queryVariableLabels(2),
        queryVariableLabels(3),
        queryVariableLabels(4),
        queryVariableLabels(5),
        variableLovQueries(1),
        variableLovQueries(2),
        variableLovQueries(3),
        variableLovQueries(4),
        variableLovQueries(5)
      from ame_approver_types
      where
        approver_type_id = approverTypeIdIn and
        sysdate between
          start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
      /* loop through the label, assigning the output arguments: */
      for i in 1 .. queryVariableLabels.count loop
        if(queryVariableLabels(i) is null) then
          exit;
        end if;
        queryVariableLabelsOut(i) := queryVariableLabels(i);
        variableLovQueriesOut(i) := variableLovQueries(i);
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getApproverTypeQueryData',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          queryVariableLabelsOut := ame_util.emptyLongStringList;
          variableLovQueriesOut := ame_util.emptyLongStringList;
          raise;
    end getApproverTypeQueryData;
  procedure getAvailableApproverTypes(applicationIdIn in integer default null,
                                      topLabelIn in varchar2 default null,
                                      topValueIn in varchar2 default null,
                                      approverTypeIdsOut out nocopy ame_util.stringList,
                                      approverTypeNamesOut out nocopy ame_util.stringList) as
    cursor getApproverTypeDataCursor is
      select
        approver_type_id,
        ame_approver_type_pkg.getOrigSystemDisplayName(orig_system) approver_type_name
        from ame_approver_types
        where sysdate between
          start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    cursor getApproverTypeDataCursor2 is
      select
        approver_type_id,
        ame_approver_type_pkg.getOrigSystemDisplayName(orig_system) approver_type_name
        from ame_approver_types
        where
          orig_system in (ame_util.perOrigSystem, ame_util.fndUserOrigSystem) and
          sysdate between
          start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    configVarValue ame_util.stringType;
    begin
      /* check configuration variable value for allowAllApproverTypes */
      configVarValue := ame_util.getConfigVar(applicationIdIn => applicationIdIn,
                                              variableNameIn =>  ame_util.allowAllApproverTypesConfigVar);
      tempIndex := 1;
      if(configVarValue = ame_util.yes) then
        /* loop through getApproverTypeDataCursor  assigning the output arguments */
        for getApproverTypeDataRec in getApproverTypeDataCursor loop
          if(tempIndex = 1 and topLabelIn is not null) then
            approverTypeIdsOut(1) := topValueIn;
            approverTypeNamesOut(1) := topLabelIn;
            tempIndex := tempIndex + 1;
          end if;
          approverTypeIdsOut(tempIndex) := to_char(getApproverTypeDataRec.approver_type_id);
          approverTypeNamesOut(tempIndex) := getApprovertypeDataRec.approver_type_name;
          tempIndex := tempIndex + 1;
        end loop;
      else
        for getApproverTypeDataRec in getApproverTypeDataCursor2 loop
          if(tempIndex = 1 and topLabelIn is not null) then
            approverTypeIdsOut(1) := topValueIn;
            approverTypeNamesOut(1) := topLabelIn;
            tempIndex := tempIndex + 1;
          end if;
          approverTypeIdsOut(tempIndex) := to_char(getApproverTypeDataRec.approver_type_id);
          approverTypeNamesOut(tempIndex) := getApprovertypeDataRec.approver_type_name;
          tempIndex := tempIndex + 1;
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getAvailableApproverTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverTypeIdsOut := ame_util.emptyStringList;
          approverTypeNamesOut := ame_util.emptyStringList;
          raise;
    end getAvailableApproverTypes;
  procedure getAvailableApproverTypes2(actionTypeIdIn in integer,
                                       approverTypeIdsOut out nocopy ame_util.stringList,
                                       approverTypeNamesOut out nocopy ame_util.stringList) as
    cursor unusedApproverTypeCursor is
      select
        approver_type_id,
        ame_approver_type_pkg.getOrigSystemDisplayName(orig_system) approver_type_name
      from ame_approver_types
      where sysdate between
        start_date and
        nvl(end_date - ame_util.oneSecond, sysdate)
      minus
      select
        ame_approver_types.approver_type_id,
        ame_approver_type_pkg.getOrigSystemDisplayName(orig_system) approver_type_name
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
        order by approver_type_name;
    tempIndex integer;
    begin
      approverTypeIdsOut(1) := ame_util.anyApproverType;
      approverTypeNamesOut(1) := ame_util.getLabel(ame_util.perFndAppId,'AME_ANY_APPROVER_TYPE');
      tempIndex := 2;
      for unusedApproverTypeRec in unusedApproverTypeCursor loop
        /* The explicit conversion below lets nocopy work. */
        approverTypeIdsOut(tempIndex) := to_char(unusedApproverTypeRec.approver_type_id);
        approverTypeNamesOut(tempIndex) := unusedApproverTypeRec.approver_type_name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getAvailableApproverTypes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverTypeIdsOut := ame_util.emptyStringList;
          approverTypeNamesOut := ame_util.emptyStringList;
          raise;
    end getAvailableApproverTypes2;
  procedure getAvailableApproverTypes3(actionTypeIdIn in integer,
                                       approverTypeIdsOut out nocopy ame_util.idList) as
    cursor availableApproverTypesCursor(actionTypeIdIn in integer) is
        select approver_type_id
          from ame_approver_type_usages
          where
            action_type_id = actionTypeIdIn and
            approver_type_id <> ame_util.anyApproverType and
            sysdate between
              start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    begin
      tempIndex := 1;
      for availableApproverTypesRec in availableApproverTypesCursor(actionTypeIdIn => actionTypeIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        approverTypeIdsOut(tempIndex) := availableApproverTypesRec.approver_type_id;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getAvailableApproverTypes3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverTypeIdsOut := ame_util.emptyIdList;
          raise;
    end getAvailableApproverTypes3;
  procedure getOrigSystemIdAndDisplayName(nameIn in varchar2,
                                          origSystemOut out nocopy varchar2,
                                          origSystemIdOut out nocopy integer,
                                          displayNameOut out nocopy varchar2) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      select
        orig_system,
        orig_system_id,
        display_name
        into
          origSystemOut,
          origSystemIdOut,
          displayNameOut
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          rownum < 2;
      exception
        when no_data_found then
          origSystemOut := null;
          origSystemIdOut := null;
          displayNameOut := null;
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400405_APPR_TYPE_NDF',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => nameIn);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getOrigSystemIdAndDisplayName',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          origSystemOut := null;
          origSystemIdOut := null;
          displayNameOut := null;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getOrigSystemIdAndDisplayName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getOrigSystemIdAndDisplayName;
  /*
    ame_api2 calls getSuperior.  See ER 3267685 for a discussion of how
    this procedure will likely be revised after the 11.5.10 release.
  */
  procedure getSuperior(approverIn in ame_util.approverRecord2,
                        superiorOut out nocopy ame_util.approverRecord2) is
    approverName wf_roles.display_name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    positionStructureId integer;
    noSurrogateException exception;
    begin
      begin
        if(approverIn.orig_system = ame_util.perOrigSystem) then
          superiorOut.orig_system := ame_util.perOrigSystem;
          select
            per_all_assignments_f.supervisor_id,
            wf_roles.name,
            wf_roles.display_name
            into
              superiorOut.orig_system_id,
              superiorOut.name,
              superiorOut.display_name
            from
              wf_roles,
              per_all_assignments_f
            where
              wf_roles.orig_system = ame_util.perOrigSystem and
              wf_roles.orig_system_id = per_all_assignments_f.supervisor_id and
              wf_roles.status = 'ACTIVE' and
              (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
              exists (select null
                        from fnd_user u
                       where u.user_name = wf_roles.name
                         and trunc(sysdate) between u.start_date
                         and nvl(u.end_date,trunc(sysdate))) and
              not exists (
                    select null from wf_roles wf2
                     where wf_roles.orig_system = wf2.orig_system
                       and wf_roles.orig_system_id = wf2.orig_system_id
                       and wf_roles.start_date > wf2.start_date
                         ) and
              per_all_assignments_f.person_id =approverIn.orig_system_id  and
              per_all_assignments_f.primary_flag = 'Y' and
              per_all_assignments_f.assignment_type in ('E','C') and
              per_all_assignments_f.assignment_status_type_id not in
                (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN') and
              trunc(sysdate) between
                per_all_assignments_f.effective_start_date and
                per_all_assignments_f.effective_end_date and
              rownum < 2;
          if(superiorOut.orig_system_id is null) then
            raise noSurrogateException;
          end if;
        elsif(approverIn.orig_system = ame_util.fndUserOrigSystem) then
          superiorOut.orig_system := ame_util.fndUserOrigSystem;
          select
            per_all_assignments_f.supervisor_id,
            wf_roles.name,
            wf_roles.display_name
            into
              superiorOut.orig_system_id,
              superiorOut.name,
              superiorOut.display_name
            from
              wf_roles,
              per_all_assignments_f
            where
              wf_roles.orig_system = ame_util.perOrigSystem and
              wf_roles.orig_system_id = per_all_assignments_f.supervisor_id and
              wf_roles.status = 'ACTIVE' and
              (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
              exists (select null
                        from fnd_user u
                       where u.user_name = wf_roles.name
                         and trunc(sysdate) between u.start_date
                         and nvl(u.end_date,trunc(sysdate))) and
              per_all_assignments_f.person_id =
                (select employee_id
                   from fnd_user
                   where
                     user_id = approverIn.orig_system_id and
                     rownum < 2) and
              per_all_assignments_f.primary_flag = 'Y' and
              per_all_assignments_f.assignment_type in ('E','C') and
              per_all_assignments_f.assignment_status_type_id not in
                (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN') and
              trunc(sysdate) between
                per_all_assignments_f.effective_start_date and
                per_all_assignments_f.effective_end_date and
              rownum < 2
            order by wf_roles.name; /* Select the first matching wf_roles entry. */
          if(superiorOut.orig_system_id is null) then
            raise noSurrogateException;
          end if;
        elsif(approverIn.orig_system = ame_util.posOrigSystem) then
          superiorOut.orig_system := ame_util.posOrigSystem;
          positionStructureId := ame_engine.getHeaderAttValue2(attributeNameIn =>ame_util.nonDefPosStructureAttr);
          if (positionStructureId is null) then
            select
              str.parent_position_id,
              wf_roles.name,
              wf_roles.display_name
              into
              superiorOut.orig_system_id,
              superiorOut.name,
              superiorOut.display_name
              from
                per_pos_structure_elements str,
                per_pos_structure_versions psv,
                per_position_structures    pst,
                wf_roles
              where
                str.subordinate_position_id  = approverIn.orig_system_id and
                str.business_group_id        =
                  nvl(hr_general.get_business_group_id,str.business_group_id) and
                str.pos_structure_version_id = psv.pos_structure_version_id and
                pst.position_structure_id    = psv.position_structure_id and
                pst.primary_position_flag    = 'Y' and
                wf_roles.orig_system         = ame_util.posOrigSystem and
                wf_roles.orig_system_id      = str.parent_position_id and
                wf_roles.status              = 'ACTIVE' and
                (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
                trunc(sysdate) between
                  psv.date_from and nvl( psv.date_to , trunc(sysdate)) and
                rownum < 2
              order by wf_roles.name;
          else
            select
              str.parent_position_id,
              wf_roles.name,
              wf_roles.display_name
              into
                superiorOut.orig_system_id,
                superiorOut.name,
                superiorOut.display_name
              from
                per_pos_structure_elements str,
                per_pos_structure_versions psv,
                per_position_structures    pst,
                wf_roles
              where
                str.subordinate_position_id  = approverIn.orig_system_id and
                str.pos_structure_version_id = psv.pos_structure_version_id and
                pst.position_structure_id    = positionStructureId and
                pst.position_structure_id    = psv.position_structure_id and
                wf_roles.orig_system    = ame_util.posOrigSystem and
                wf_roles.orig_system_id = str.parent_position_id and
                wf_roles.status         = 'ACTIVE' and
                (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
                trunc(sysdate) between
                  psv.date_from and nvl( psv.date_to , trunc(sysdate)) and
                rownum < 2
              order by wf_roles.name;
          end if;
        elsif(approverIn.orig_system = ame_util.fndRespOrigSystem) then
          null;
        else
          raise noSurrogateException;
        end if;
        exception
          when no_data_found then
            raise noSurrogateException;
          when others then
            raise;
      end;
      exception
        when noSurrogateException then
          approverName := getApproverDisplayName2(origSystemIn => approverIn.orig_system,
                                                  origSystemIdIn => approverIn.orig_system_id);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400436_APPR_NO_APPR_EXTS',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => approverName);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getSuperior',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getSuperior',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getSuperior;
  /*
    The engine calls getSurrogate, so it needs to be as efficient as possible.
    See ER 3267685 for a discussion of how this procedure will likely be revised
    after the 11.5.10 release.
  */
  procedure getSurrogate(origSystemIn in varchar2,
                         origSystemIdIn in integer,
                         origSystemIdOut out nocopy integer,
                         wfRolesNameOut out nocopy varchar2,
                         displayNameOut out nocopy varchar2) as
    approverName wf_roles.display_name%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    positionStructureId integer;
    noSurrogateException exception;
    begin
      begin
        if(origSystemIn = ame_util.perOrigSystem) then
          select
            per_all_assignments_f.supervisor_id,
            wf_roles.name,
            wf_roles.display_name
            into
              origSystemIdOut,
              wfRolesNameOut,
              displayNameOut
            from
              wf_roles,
              per_all_assignments_f
            where
              wf_roles.orig_system = ame_util.perOrigSystem and
              wf_roles.orig_system_id = per_all_assignments_f.supervisor_id and
              wf_roles.status = 'ACTIVE' and
              (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
              exists (select null
                        from fnd_user u
                       where u.user_name = wf_roles.name
                         and trunc(sysdate) between u.start_date
                         and nvl(u.end_date,trunc(sysdate))) and
              not exists (
                    select null from wf_roles wf2
                     where wf_roles.orig_system = wf2.orig_system
                       and wf_roles.orig_system_id = wf2.orig_system_id
                       and wf_roles.start_date > wf2.start_date
                         ) and
              per_all_assignments_f.person_id = origSystemIdIn and
              per_all_assignments_f.primary_flag = 'Y' and
              per_all_assignments_f.assignment_type in ('E','C') and
              per_all_assignments_f.assignment_status_type_id not in
                (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN') and
              trunc(sysdate) between
                per_all_assignments_f.effective_start_date and
                per_all_assignments_f.effective_end_date and
              rownum < 2;
          if(origSystemIdOut is null) then
            raise noSurrogateException;
          end if;
        elsif(origSystemIn = ame_util.fndUserOrigSystem) then
          select
            per_all_assignments_f.supervisor_id,
            wf_roles.name,
            wf_roles.display_name
            into
              origSystemIdOut,
              wfRolesNameOut,
              displayNameOut
            from
              wf_roles,
              per_all_assignments_f
            where
              wf_roles.orig_system = ame_util.perOrigSystem and
              wf_roles.orig_system_id = per_all_assignments_f.supervisor_id and
              wf_roles.status = 'ACTIVE' and
              exists (select null
                        from fnd_user u
                       where u.user_name = wf_roles.name
                         and trunc(sysdate) between u.start_date
                         and nvl(u.end_date,trunc(sysdate))) and
              (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
              per_all_assignments_f.person_id =
                (select employee_id
                   from fnd_user
                   where
                     user_id = origSystemIdIn and
                     rownum < 2) and
              per_all_assignments_f.primary_flag = 'Y' and
              per_all_assignments_f.assignment_type in ('E','C') and
              per_all_assignments_f.assignment_status_type_id not in
                (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN') and
              trunc(sysdate) between
                per_all_assignments_f.effective_start_date and
                per_all_assignments_f.effective_end_date and
              rownum < 2
            order by wf_roles.name; /* Select the first matching wf_roles entry. */
          if(origSystemIdOut is null) then
            raise noSurrogateException;
          end if;
        elsif(origSystemIn = ame_util.posOrigSystem) then
          positionStructureId := ame_engine.getHeaderAttValue2(attributeNameIn =>ame_util.nonDefPosStructureAttr);
          if (positionStructureId is null) then
            select
              str.parent_position_id,
              wf_roles.name,
              wf_roles.display_name
              into
                origSystemIdOut,
                wfRolesNameOut,
                displayNameOut
              from
                per_pos_structure_elements str,
                per_pos_structure_versions psv,
                per_position_structures    pst,
                wf_roles
              where
                str.subordinate_position_id  = origSystemIdIn and
                str.business_group_id        =
                  nvl(hr_general.get_business_group_id,str.business_group_id) and
                str.pos_structure_version_id = psv.pos_structure_version_id and
                pst.position_structure_id    = psv.position_structure_id and
                pst.primary_position_flag    = 'Y' and
                wf_roles.orig_system         = ame_util.posOrigSystem and
                wf_roles.orig_system_id      = str.parent_position_id and
                wf_roles.status              = 'ACTIVE' and
                (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
                trunc(sysdate) between
                  psv.date_from and nvl( psv.date_to , trunc(sysdate)) and
                rownum < 2
              order by wf_roles.name;
          else
            select
              str.parent_position_id,
              wf_roles.name,
              wf_roles.display_name
              into
                origSystemIdOut,
                wfRolesNameOut,
                displayNameOut
              from
                per_pos_structure_elements str,
                per_pos_structure_versions psv,
                per_position_structures    pst,
                wf_roles
              where
                str.subordinate_position_id  = origSystemIdIn and
                str.pos_structure_version_id = psv.pos_structure_version_id and
                pst.position_structure_id    = positionStructureId and
                pst.position_structure_id    = psv.position_structure_id and
                wf_roles.orig_system    = ame_util.posOrigSystem and
                wf_roles.orig_system_id = str.parent_position_id and
                wf_roles.status         = 'ACTIVE' and
                (wf_roles.expiration_date is null or sysdate < wf_roles.expiration_date) and
                trunc(sysdate) between
                  psv.date_from and nvl( psv.date_to , trunc(sysdate)) and
                rownum < 2
              order by wf_roles.name;
          end if;
        elsif(origSystemIn = ame_util.fndRespOrigSystem) then
          null;
        else
          raise noSurrogateException;
        end if;
        exception
          when no_data_found then
            raise noSurrogateException;
          when others then
            raise;
      end;
      exception
        when noSurrogateException then
          approverName := getApproverDisplayName2(origSystemIn => origSystemIn,
                                                  origSystemIdIn => origSystemIdIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400436_APPR_NO_APPR_EXTS',
                                              tokenNameOneIn  => 'NAME',
                                              tokenValueOneIn => approverName);
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getSurrogate',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getSurrogate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getSurrogate;
  procedure getWfRolesNameAndDisplayName(origSystemIn in varchar2,
                                         origSystemIdIn in integer,
                                         nameOut out nocopy ame_util.longStringType,
                                         displayNameOut out nocopy ame_util.longStringType) as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      /*
        This procedure should select the input approver's wf_roles.display_name, NOT the
        display name of the input approver's orig_system.
      */
      /*
        If an fnd_user entry has a non-null employee_id (person ID) value, it gets
        converted to the PER originating system in wf_roles; otherwise, it gets
        converted to the FND_USR originating system.  As just one of these will
        happen, we can match both originating systems in a single-row query.
        The order-by-name clause and rownum < 2 condition are necessary because we
        have encountered data problems where there are several entries for a given
        orig_system and orig_system_id pair.
      */
      select
        name,
        display_name
        into
          nameOut,
          displayNameOut
        from wf_roles
        where
          ((orig_system = origSystemIn and
            orig_system_id = origSystemIdIn) or
           (origSystemIn = ame_util.fndUserOrigSystem and
            orig_system = ame_util.perOrigSystem and
            orig_system_id = (select employee_id
                                from fnd_user
                                where
                                  user_id = origSystemIdIn and
                                  sysdate between
                                    start_date and
                                    nvl(end_date, sysdate)))) and
          status = 'ACTIVE' and
          (expiration_date is null or
           sysdate < expiration_date) and
          (orig_system not in (ame_util.fndUserOrigSystem,ame_util.perOrigSystem)
            or exists (select null
                    from fnd_user u
                   where u.user_name = wf_roles.name
                     and trunc(sysdate) between u.start_date
                     and nvl(u.end_date,trunc(sysdate)))) and
          not exists (
                select null from wf_roles wf2
                 where wf_roles.orig_system = wf2.orig_system
                   and wf_roles.orig_system_id = wf2.orig_system_id
                   and wf_roles.start_date > wf2.start_date
                     ) and
          rownum < 2;
      exception
        when no_data_found then
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn   => 'AME_400415_APPROVER_NOT_FOUND',
                                              tokenNameOneIn  => 'ORIG_SYSTEM_ID',
                                              tokenValueOneIn => origSystemIdIn,
                                              tokenNameTwoIn  => 'ORIG_SYSTEM',
                                              tokenValueTwoIn => origSystemIn
                                               );
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getWfRolesNameAndDisplayName',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          nameOut := null;
          displayNameOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'getWfRolesNameAndDisplayName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          nameOut := null;
          displayNameOut := null;
          raise;
    end getWfRolesNameAndDisplayName;
  procedure newApproverTypeUsage(actionTypeIdIn in integer,
                                 approverTypeIdIn in integer,
                                 processingDateIn in date) as
    currentUserId integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      insert into ame_approver_type_usages(approver_type_id,
                                           action_type_id,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(approverTypeIdIn,
                 actionTypeIdIn,
                 currentUserId,
                 processingDateIn,
                 currentUserId,
                 processingDateIn,
                 currentUserId,
                 processingDateIn,
                 null);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'newApproverTypeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end newApproverTypeUsage;
  procedure newApproverTypeUsages(actionTypeIdIn in integer,
                                  approverTypeIdsIn in ame_util.idList,
                                  finalizeIn in boolean default false,
                                  processingDateIn in date default null) as
    processingDate date;
    begin
      if(processingDateIn is null) then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      for i in 1 .. approverTypeIdsIn.count loop
        newApproverTypeUsage(actionTypeIdIn => actionTypeIdIn,
                             approverTypeIdIn => approverTypeIdsIn(i),
                             processingDateIn => processingDate);
      end loop;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'newApproverTypeUsages',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end newApproverTypeUsages;
  procedure perApproverQuery(criteria1In in varchar2 default null,
                             criteria2In in varchar2 default null,
                             criteria3In in varchar2 default null,
                             criteria4In in varchar2 default null,
                             criteria5In in varchar2 default null,
                             excludeListCountIn in integer,
                             approverNamesOut out nocopy varchar2,
                             approverDescriptionsOut out nocopy varchar2) as
    cursor personCursor(firstNameIn in varchar2,
                        lastNameIn in varchar2,
                        emailAddressIn in varchar2,
                        truncatedSysdateIn in date,
                        rowsToExcludeIn in integer) is
      select
        /* The compiler forces passing arguments by position in the following function calls. */
         getWfRolesName(ame_util.perOrigSystem, pap.person_id) approver_name
        ,getApproverDescription(getWfRolesName(ame_util.perOrigSystem, pap.person_id)) approver_description
        from
          per_all_people_f pap
         ,hr_all_organization_units haou
         ,wf_roles wfr
         ,per_all_assignments_f pas
        where pap.person_id = pas.person_id
         and pas.primary_flag    = 'Y'
         and pas.assignment_type in ('E','C')
         and pas.assignment_status_type_id not in
                  (select assignment_status_type_id
                   from per_assignment_status_types
                   where per_system_status = 'TERM_ASSIGN')
          and wfr.orig_system_id = pap.person_id
          and wfr.orig_system    = ame_util.perOrigSystem
          and wfr.status         = 'ACTIVE'
          and exists (select null
                        from fnd_user u
                       where u.user_name = wfr.name
                         and truncatedSysdateIn between u.start_date
                         and nvl(u.end_date,truncatedSysdateIn))
          and (firstNameIn is null or upper(pap.first_name) like upper(replace(firstNameIn, '''', '''''')) || '%')
          and (lastNameIn is null or upper(pap.last_name) like upper(replace(lastNameIn, '''', '''''')) || '%')
          and (emailAddressIn is null or upper(pap.email_address) like upper(replace(emailAddressIn, '''', '''''')) || '%')
          and pap.business_group_id = haou.organization_id
          and truncatedSysdateIn between pap.effective_start_date and nvl(pap.effective_end_date, truncatedSysdateIn)
          and truncatedSysdateIn between haou.date_from and nvl(haou.date_to, truncatedSysdateIn)
          and truncatedSysdateIn between pas.effective_start_date and pas.effective_end_date
          and rownum < 52 + rowsToExcludeIn /* This prevents oversized fetches. */
        order by last_name;
      /* local variables */
    approverNames ame_util.longStringList;
    approverDescriptions ame_util.longStringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    truncatedSysdate date;
    /* procedure body */
    begin
      /*
        Fetch the cursor into approverNames and approverDescriptions.  Note that
        the cursors will only fetch at most 51 + excludeIdListIn.count rows, preventing
        oversized fetches.
      */
      truncatedSysdate := trunc(sysdate);
      open personCursor(firstNameIn => criteria1In,
                        lastNameIn => criteria2In,
                        emailAddressIn => criteria3In,
                        truncatedSysdateIn => truncatedSysdate,
                        rowsToExcludeIn => excludeListCountIn);
      fetch personCursor bulk collect
        into
          approverNames,
          approverDescriptions;
      close personCursor;
      /* Check for too many results. */
      if(approverNames.count - excludeListCountIn > 50) then
        raise ame_util.tooManyApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /* Check for zero approvers. */
      if(approverNames.count = 0) then
        raise ame_util.zeroApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /*
        Return the results.  (ame_util.serializeApprovers procedure will raise
        ame_util.tooManyApproversException if it can't serialize both input lists.)
      */
      ame_util.serializeApprovers(approverNamesIn => approverNames,
                                  approverDescriptionsIn => approverDescriptions,
                                  maxOutputLengthIn => ame_util.longestStringTypeLength,
                                  approverNamesOut => approverNamesOut,
                                  approverDescriptionsOut => approverDescriptionsOut);
      exception
        when ame_util.tooManyApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400111_UIN_MANY_ROWS');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'perApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.zeroApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400110_UIN_NO_CURR_EMP');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'perApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'perApproverQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise;
    end perApproverQuery;
  procedure posApproverQuery(criteria1In in varchar2 default null,
                             criteria2In in varchar2 default null,
                             criteria3In in varchar2 default null,
                             criteria4In in varchar2 default null,
                             criteria5In in varchar2 default null,
                             excludeListCountIn in integer,
                             approverNamesOut out nocopy varchar2,
                             approverDescriptionsOut out nocopy varchar2) as
    cursor positionCursor(positionNameIn      in varchar2,
                          businessGroupNameIn in varchar2,
                          truncatedSysdateIn  in date,
                          rowsToExcludeIn     in integer) is
      select
        getWfRolesName(ame_util.posOrigSystem, per_positions.position_id) approver_name,
        getApproverDescription(getWfRolesName(ame_util.posOrigSystem, orig_system_id)) approver_description
        from
          per_positions,
          hr_organization_units,
          wf_roles
        where
          wf_roles.orig_system_id = per_positions.position_id and
          wf_roles.orig_system    = ame_util.posOrigSystem and
          wf_roles.status         = 'ACTIVE' and
          (positionNameIn is null or upper(per_positions.name) like upper(replace(positionNameIn, '''', '''''')) || '%') and
          (businessGroupNameIn is null or upper(hr_organization_units.name) like upper(replace(businessGroupNameIn, '''', '''''')) || '%') and
          per_positions.business_group_id = hr_organization_units.organization_id and
          truncatedSysdateIn between
            per_positions.date_effective and
            nvl(per_positions.date_end, truncatedSysdateIn) and
          truncatedSysdateIn between
            hr_organization_units.date_from and
            nvl(hr_organization_units.date_to, truncatedSysdateIn) and
          rownum < 52 + rowsToExcludeIn /* This prevents oversized fetches. */
          order by per_positions.name;
      /* local variables */
    approverNames ame_util.longStringList;
    approverDescriptions ame_util.longStringList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    truncatedSysdate date;
    /* procedure body */
    begin
      /*
        Fetch the cursor into approverNames and approverDescriptions.  Note that
        the cursors will only fetch at most 51 + excludeIdListIn.count rows, preventing
        oversized fetches.
      */
      truncatedSysdate := trunc(sysdate);
      open positionCursor(positionNameIn      => criteria1In,
                          businessGroupNameIn => criteria2In,
                          truncatedSysdateIn  => truncatedSysdate,
                          rowsToExcludeIn     => excludeListCountIn);
      fetch positionCursor bulk collect
        into
          approverNames,
          approverDescriptions;
      close positionCursor;
      /* Check for too many results. */
      if(approverNames.count - excludeListCountIn > 50) then
        raise ame_util.tooManyApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /* Check for zero approvers. */
      if(approverNames.count = 0) then
        raise ame_util.zeroApproversException;
        approverNamesOut := null;
        approverDescriptionsOut := null;
        return;
      end if;
      /*
        Return the results.  (ame_util.serializeApprovers procedure will raise
        ame_util.tooManyApproversException if it can't serialize both input lists.)
      */
      ame_util.serializeApprovers(approverNamesIn => approverNames,
                                  approverDescriptionsIn => approverDescriptions,
                                  maxOutputLengthIn => ame_util.longestStringTypeLength,
                                  approverNamesOut => approverNamesOut,
                                  approverDescriptionsOut => approverDescriptionsOut);
      exception
        when ame_util.tooManyApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400111_UIN_MANY_ROWS');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'posApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.zeroApproversException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400110_UIN_NO_CURR_EMP');
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'posApproverQuery',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'posApproverQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := null;
          approverDescriptionsOut := null;
          raise;
    end posApproverQuery;
  procedure processApproverQuery(selectClauseIn in varchar2,
                                 approverNamesOut out nocopy ame_util.longStringList,
                                 approverDisplayNamesOut out nocopy ame_util.longStringList) as
    tempApproverDisplayName ame_util.longStringType;
    tempApproverName ame_util.longStringType;
    tempIndex integer;
    variableCur ame_util.queryCursor;
    begin
      /* call the ame_util.getQuery routine and assign to variableCur */
      variableCur := ame_util.getQuery(selectClauseIn => selectClauseIn);
      tempIndex := 1;
      /* loop through the dynamic cursor fetching into the local variables
         variableName and variableDisplayName */
      loop
        fetch variableCur
          into tempApproverName,
               tempApproverDisplayName;
          exit when variableCur%notfound;
          /* assign variableName, variableDisplayName to the output arguments
             approverNamesOut, approverDisplayNamesOut */
          approverNamesOut(tempIndex) := tempApproverName;
          approverDisplayNamesOut(tempIndex) := tempApproverDisplayName;
          tempIndex := tempIndex + 1;
      end loop;
      close variableCur;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'processApproverQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := ame_util.emptyLongStringList;
          approverDisplayNamesOut := ame_util.emptyLongStringList;
          raise;
    end processApproverQuery;
  procedure processApproverQuery2(selectClauseIn in varchar2,
                                  approverNamesOut out nocopy ame_util.longStringList) as
    tempApproverDisplayName ame_util.longStringType;
    tempApproverName ame_util.longStringType;
    tempIndex integer;
    variableCur ame_util.queryCursor;
    begin
      /* call the ame_util.getQuery routine and assign to variableCur */
      variableCur := ame_util.getQuery(selectClauseIn => selectClauseIn); -- may not be right, need to check on this);
      tempIndex := 1;
      /* loop through the dynamic cursor fetching into the local variables
         variableName and variableDisplayName */
      loop
        fetch variableCur
          into tempApproverName;
          exit when variableCur%notfound;
          /* assign variableName, variableDisplayName to the output arguments
             approverNamesOut, approverDisplayNamesOut */
          approverNamesOut(tempIndex) := tempApproverName;
          tempIndex := tempIndex + 1;
      end loop;
      close variableCur;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'processApproverQuery2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          approverNamesOut := ame_util.emptyLongStringList;
          raise;
    end processApproverQuery2;
  procedure removeApproverTypeUsage(actionTypeIdIn in integer,
                                    approverTypeIdIn in integer,
                                    processingDateIn in date default null) as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    processingDate date;
    begin
      currentUserId := ame_util.getCurrentUserId;
      update ame_approver_type_usages
        set
          last_updated_by = currentUserId,
          last_update_date = processingDateIn,
          last_update_login = currentUserId,
          end_date = processingDateIn
        where
          action_type_id = actionTypeIdIn and
          approver_type_id = approverTypeIdIn and
          processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn) ;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'removeApproverTypeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end removeApproverTypeUsage;
  procedure removeApproverTypeUsages(actionTypeIdIn in integer,
                                     approverTypeIdsIn in ame_util.idList default ame_util.emptyIdList,
                                     finalizeIn in boolean default false,
                                     processingDateIn in date default null) as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    processingDate date;
    begin
      processingDate := sysdate;
      /* loop through approverTypeIdsIn and update/end date
         ame_approver_type_usages */
      for i in 1..approverTypeIdsIn.count loop
        removeApproverTypeUsage(actionTypeIdIn => actionTypeIdIn,
                                approverTypeIdIn => approverTypeIdsIn(i),
                                processingDateIn => processingDate);
      end loop;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_approver_type_pkg',
                                    routineNameIn => 'removeApproverTypeUsages',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn =>  sqlerrm);
          raise;
    end removeApproverTypeUsages;
end ame_approver_type_pkg;

/
