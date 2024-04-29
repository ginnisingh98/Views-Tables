--------------------------------------------------------
--  DDL for Package FND_WF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WF_SYNCH" AUTHID CURRENT_USER as
/* $Header: AFWFSYNS.pls 120.1 2005/07/02 04:22:48 appldev noship $ */




--    The purpose of this package is to synchronize
--    FND_USER or FND_RESPONSIBILITY or FND_USER_RESP_GROUPS
--    table with wf tables WF_LOCAL_USERS, WF_LOCAL_ROLES,
--    WF_LOCAL_USER_ROLES by propagating the changes there.

--    WARNING!!! Procedures in this package are ONLY meant to be
--      called from either table handlers FND_USER_PKG,
--      FND_RESPONSIBILITY_PKG or from the FND forms interface.
--      The procedures here trust that the input parameters have
--      already been validated by the calling procedures, and won't
--      do any more validation. You risk putting corrupt data
--      in workflow directory services tables if you call these procedures
--      outside of the above mentioned places.




-- notify workflow of event (UPDATE of a row in FND_USER)
-- to synchronize with workflow directory services table wf_local_users
-- known source:
-- NOTE: we need the old_employeeId before the update because need to
-- do some clean-up in the workflow directory tables when fnd_user is
-- linked to a different person, newly linked
-- to a person, or unlinked from a person based on the employee_id
procedure propagateUserUpdate
( userId in number,
  userName in varchar2,
  employeeId in number,
  description in varchar2,
  emailAddress in varchar2,
  fax in varchar2,
  startDate in date,
  endDate in date,
  old_employeeId in number);


-- notify workflow of event (INSERT to FND_USER)
-- to synchronize with workflow directory services table wf_local_users
-- known source:
procedure propagateUserInsert
( userId in number,
  userName in varchar2,
  employeeId in number,
  description in varchar2,
  emailAddress in varchar2,
  fax in varchar2,
  startDate in date,
  endDate in date);


-- notify workflow of event (UPDATE of end_date in FND_USER)
-- to synchronize with workflow directory services table wf_local_users
-- known source: FND_USER_PKG.disableUser
-- NOTE: This procedure should be called when ONLY the end_date is updated.
-- Otherwise, propagateUserUpdate should be called instead.
procedure propagateUserDisable
( old_userName in varchar2);


-- notify workflow of event (INSERT or UPDATE to FND_USER_RESP_GROUPS)
-- to synchronize with workflow directory services table wf_local_user_roles
-- known source:in the fnd_user_pkg.AddResp
-- this covers both the insert and update case;
-- wf_dir_trigger.insertUserRole will first tries to update and if
-- no row found, will do an insert
procedure propagateUserRespInsert(
userId in number,
responsibilityId in number,
respApplId in number, -- RESPONSIBILITY_APPLICATION_ID
startDate in date,
endDate in date);

procedure propagateUserRespUpdate(
userId in number,
responsibilityId in number,
respApplId in number, -- RESPONSIBILITY_APPLICATION_ID
startDate in date,
endDate in date);


-- notify workflow of event (DELETE from FND_USER_RESP_GROUPS)
-- to synchronize with workflow directory services table wf_local_user_roles
-- known source:in the fnd_user_pkg.DelResp
procedure propagateUserRespDelete(
userId in number,
responsibilityId in number,
respApplId in number -- RESPONSIBILITY_APPLICATION_ID
);


-- notify workflow of event (INSERT to FND_RESPONSIBILITY)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.INSERT_ROW
procedure propagateRespInsert(
applicationId in number,
responsibilityId in number,
responsibilityName in varchar2,
description in varchar2,
start_date in date,
end_date in date);

-- notify workflow of event (UPDATE to FND_RESPONSIBILITY/FND_RESPONSIBILITY_TL)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.UPDATE_ROW
-- NOTE that change will only be propagated to wf table when userenv('LANG')
-- is same as base language. This is because wf local tables are not TL'd,
-- so we can only keep one row based on the base language.
procedure propagateRespUpdate(
applicationId in number,
responsibilityId in number,
responsibilityName in varchar2,
description in varchar2,
start_date in date,
end_date in date);


-- notify workflow of event (UPDATE to FND_RESPONSIBILITY/FND_RESPONSIBILITY_TL)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.TRANSLATE_ROW
-- NOTE that change will only be propagated to wf table when userenv('LANG')
-- is same as base language. This is because wf local tables are not TL'd,
-- so we can only keep one row based on the base language.
-- need this special version of propagetRespUpdate because
-- fnd_responsibility_pkg.TRANSLATE_ROW keeps the old value of
-- responsibility_name and description column if new value is null,
-- therefore, we cannot just update based on the passed in value, but
-- need to requery to get back actual value after the update
procedure propagateRespUpdate(
applicationId in number,
responsibilityId in number);


-- notify workflow of event (DELETE from FND_RESPONSIBILITY)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.DELETE_ROW
procedure propagateRespDelete(
applicationId in number,
responsibilityId in number);


--
-- This procedure is to be called by LOAD_RAW, UpdateUser and
-- LoadUser procedures in FND_USER_PKG to synchronize workflow
-- directory services table wf_local_roles. This should be called
-- AFTER the update to fnd_user table, so we just requery to get
-- all the values we need for workflow synchronization.
procedure synchFndUser(userName in varchar2,
   old_employeeId in number -- employee_id before the update.
       -- this is important since we need to determine if there
       -- would be a change in orig_system and orig_system_id
);

end FND_WF_SYNCH;

 

/
