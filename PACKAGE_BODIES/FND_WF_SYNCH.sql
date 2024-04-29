--------------------------------------------------------
--  DDL for Package Body FND_WF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WF_SYNCH" as
/* $Header: AFWFSYNB.pls 120.1 2005/07/02 04:22:44 appldev noship $ */




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


--
-- This procedure is known to be called by LOAD_RAW, UpdateUser and
-- LoadUser procedures in FND_USER_PKG to synchronize workflow
-- directory services table wf_local_roles. This should be called
-- AFTER the update to fnd_user table, so we just requery to get
-- all the values we need for workflow synchronization.
procedure synchFndUser(userName in varchar2,
   old_employeeId in number -- employee_id before the update.
       -- this is important since we need to determine if there
       -- would be a change in orig_system and orig_system_id
)
AS
l_userId number;
l_description varchar2(240);
l_emailAddress varchar2(240);
l_fax varchar2(80);
l_startDate date;
l_endDate date;
l_employeeId number;
begin

null;

end synchFndUser;


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
  old_employeeId in number)
AS
  l_language varchar2(240);
  l_territory varchar2(240);
  l_fullName varchar2(360);
  l_emailAddress varchar2(2000);
  l_notificationPreference varchar2(240);
  l_status varchar2(30);
  l_origSystem varchar2(30);
  l_origSystemId number;
  l_endDate date := NULL;

  l_roleOrigSystemId number;
  l_roleOrigSystem varchar2(30);
  l_roleName varchar2(100);

/*cursor c_userrole(c_userName in varchar2, c_origSystem in varchar2, c_personId in number) is
   select role_name, role_orig_system, role_orig_system_id
  from wf_local_user_roles
  where user_name = c_userName
  and user_orig_system =c_origSystem
  and user_orig_system_id = c_personId;*/
begin

null;

exception
when no_data_found then
raise;
when others then
raise;
end propagateUserUpdate;


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
  endDate in date)
 as
  l_language varchar2(240);
  l_territory varchar2(240);
  l_fullName varchar2(360);
  l_emailAddress varchar2(2000);
  l_notificationPreference varchar2(240);
  l_status varchar2(30);
  l_origSystem varchar2(30);
  l_origSystemId number := -999;
  l_endDate date := NULL;


begin

null;

exception
when no_data_found then
raise;
when others then
raise;
end propagateUserInsert;


-- notify workflow of event (UPDATE of end_date in FND_USER)
-- to synchronize with workflow directory services table wf_local_users
-- known source: FND_USER_PKG.disableUser
-- NOTE: This procedure should be called when ONLY the end_date is updated.
-- Otherwise, propagateUserUpdate should be called instead.
procedure propagateUserDisable
( old_userName in varchar2)
 as
begin

null;

end propagateUserDisable;


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
endDate in date)
AS
  l_userOrigSystem varchar2(30);
  l_userOrigSystemId number;
  l_userName varchar2(100);
  l_employeeId number;
begin

null;

exception
when no_data_found then
raise;
when others then
raise;
end propagateUserRespInsert;

-- notify workflow of event (UPDATE of RESPONSIBILITY_ID, RESPONSIBILITY_APPLICATION_ID, START_DATE, END_DATE to FND_USER_RESP_GROUPS)
-- to synchronize with workflow directory services table wf_local_user_roles
-- known source: FND form
procedure propagateUserRespUpdate(
userId in number,
responsibilityId in number,
respApplId in number, -- RESPONSIBILITY_APPLICATION_ID
startDate in date,
endDate in date
)
AS
  l_userOrigSystem varchar2(30);
  l_userOrigSystemId number;
  l_userName varchar2(100);
  l_employeeId number;
begin

null;

exception
when no_data_found then
raise;
when others then
raise;
end propagateUserRespUpdate;




-- notify workflow of event (DELETE from FND_USER_RESP_GROUPS)
-- to synchronize with workflow directory services table wf_local_user_roles
-- known source:in the fnd_user_pkg.DelResp
procedure propagateUserRespDelete(
userId in number,
responsibilityId in number,
respApplId in number -- RESPONSIBILITY_APPLICATION_ID
)
AS
  l_userOrigSystem varchar2(30);
  l_userOrigSystemId number;
  l_userName varchar2(100);
  l_employeeId number;
begin

null;

exception
when no_data_found then
raise;
when others then
raise;
end propagateUserRespDelete;


-- notify workflow of event (INSERT to FND_RESPONSIBILITY)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.INSERT_ROW
procedure propagateRespInsert(
applicationId in number,
responsibilityId in number,
responsibilityName in varchar2,
description in varchar2,
start_date in date,
end_date in date)
AS
  l_language varchar2(30);
  l_territory varchar2(30);
begin

null;


exception
when no_data_found then
raise;
when others then
raise;
end propagateRespInsert;


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
end_date in date)
AS
  l_languageCode varchar2(4);
  l_language varchar2(30);
  l_territory varchar2(30);
begin

null;


exception
when no_data_found then
raise;
when others then
raise;
end propagateRespUpdate;


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
responsibilityId in number)
AS
  l_languageCode varchar2(4);
  l_language varchar2(30);
  l_territory varchar2(30);
  l_responsibilityName varchar2(100);
  l_description varchar2(240);
begin

null;


exception
when no_data_found then
raise;
when others then
raise;
end propagateRespUpdate;


-- notify workflow of event (DELETE from FND_RESPONSIBILITY)
-- to synchronize with workflow directory services table wf_local_roles
-- known source: in fnd_responsibility_pkg.DELETE_ROW
procedure propagateRespDelete(
applicationId in number,
responsibilityId in number)
AS
begin

null;
end propagateRespDelete;

end FND_WF_SYNCH;

/
