--------------------------------------------------------
--  DDL for Package Body GMO_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_UTILITIES" AS
/* $Header: GMOUTILB.pls 120.2 2005/11/09 02:34 bchopra noship $ */

PROCEDURE GET_WHO_COLUMNS
(
         x_creation_date     out nocopy date,
         x_created_by        out nocopy number,
         x_last_update_date  out nocopy date,
         x_last_updated_by   out nocopy number,
         x_last_update_login out nocopy number
)
IS
BEGIN
  x_creation_date := sysdate;
  x_created_by := fnd_global.user_id();
  x_last_update_date := sysdate;
  x_last_updated_by := fnd_global.user_id();
  x_last_update_login := fnd_global.login_id();
END GET_WHO_COLUMNS;



--This function would return the user display name for the user
function GET_USER_DISPLAY_NAME (P_USER_NAME IN VARCHAR2) RETURN VARCHAR2

IS

l_displayname varchar2(400);
l_emailaddress varchar2(400);
l_notification_preference varchar2(30);
l_language varchar2(30);
l_teritory varchar2(30);

begin
	wf_directory.getroleinfo(
		ROLE => P_USER_NAME,
		DISPLAY_NAME => l_displayname,
		EMAIL_ADDRESS => l_emailaddress,
		NOTIFICATION_PREFERENCE => l_notification_preference,
		LANGUAGE => l_language,
		TERRITORY => l_teritory
	);

	return l_displayname;

END GET_USER_DISPLAY_NAME;


--This function would return the user display name for the user
function GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER) RETURN VARCHAR2

IS

cursor c_get_user_name is select user_name from fnd_user where user_id = P_USER_ID;
l_username varchar2(400);

begin
	open c_get_user_name;
	fetch c_get_user_name into l_username;
	close c_get_user_name;



	return GET_USER_DISPLAY_NAME(l_username);

END GET_USER_DISPLAY_NAME;

PROCEDURE GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER, P_USER_DISPLAY_NAME OUT nocopy VARCHAR2) as

BEGIN

P_USER_DISPLAY_NAME:=get_user_display_name(P_USER_ID);

END GET_USER_DISPLAY_NAME;

PROCEDURE GET_MFG_LOOKUP(P_LOOKUP_TYPE IN VARCHAR2,
                      P_LOOKUP_CODE IN VARCHAR2,
                      P_MEANING     OUT NOCOPY VARCHAR2) IS

CURSOR GET_LKUP_MEANING IS SELECT MEANING FROM MFG_LOOKUPS WHERE LOOKUP_TYPE = P_LOOKUP_TYPE AND LOOKUP_CODE = P_LOOKUP_CODE;

BEGIN
  OPEN GET_LKUP_MEANING;
  FETCH GET_LKUP_MEANING INTO P_MEANING;
  CLOSE GET_LKUP_MEANING;

END GET_MFG_LOOKUP;

function GET_LOOKUP_MEANING (P_LOOKUP_TYPE IN VARCHAR2, P_LOOKUP_CODE IN VARCHAR2) RETURN VARCHAR2
IS

CURSOR GET_LKUP_MEANING IS SELECT MEANING FROM FND_LOOKUPS WHERE LOOKUP_TYPE = P_LOOKUP_TYPE AND LOOKUP_CODE = P_LOOKUP_CODE;
l_meaning varchar2(300);

BEGIN
  OPEN GET_LKUP_MEANING;
  FETCH GET_LKUP_MEANING INTO l_MEANING;
  CLOSE GET_LKUP_MEANING;
  return l_meaning;

END GET_LOOKUP_MEANING;

PROCEDURE GET_LOOKUP
(
        P_LOOKUP_TYPE IN VARCHAR2,
        P_LOOKUP_CODE IN VARCHAR2,
        X_MEANING     OUT NOCOPY VARCHAR2
) IS
begin
 x_meaning := GET_LOOKUP_MEANING(P_LOOKUP_TYPE, P_LOOKUP_CODE);

end;

procedure get_organization (P_BATCH_ID IN NUMBER,
                            X_ORG_ID OUT NOCOPY NUMBER,
                            X_ORG_CODE OUT NOCOPY VARCHAR2,
                            X_ORG_NAME OUT NOCOPY VARCHAR2) IS


cursor get_org_details is
 select organization_id
  from  gme_batch_header
  where batch_id = p_batch_id;

begin

	open get_org_details;
	fetch get_org_details into X_org_id;
	close get_org_details;
         get_organization(P_ORG_ID => X_org_id,
                          X_ORG_CODE => X_ORG_CODE,
                          X_ORG_NAME => X_ORG_NAME);

end get_organization;

procedure get_organization (P_ORG_ID IN NUMBER,
                            X_ORG_CODE OUT NOCOPY VARCHAR2,
                            X_ORG_NAME OUT NOCOPY VARCHAR2) IS
l_org_code varchar2(3);
l_org_name varchar2(240);
cursor get_org_details IS
SELECT oav.organization_code,
       oav.organization_name
  FROM org_access_view oav
 WHERE oav.organization_id = P_ORG_ID
   AND  oav.responsibility_id = fnd_global.resp_id
   and oav.resp_application_id = fnd_global.resp_appl_id;

BEGIN
    OPEN get_org_details;
     FETCH get_org_details into X_ORG_CODE, X_ORG_NAME;
    CLOSE get_org_details;
END get_organization;

END GMO_UTILITIES;

/
