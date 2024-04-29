--------------------------------------------------------
--  DDL for Package Body ITA_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_NOTIFICATION_PKG" as
/* $Header: itapnotb.pls 120.13 2006/08/11 20:42:24 cpetriuc noship $ */




function GET_ORG_CONNECTIONS_STRING return VARCHAR2 is
begin return
'
(
select ORGANIZATION_ID_PARENT, ORGANIZATION_ID_CHILD
from PER_ORG_STRUCTURE_ELEMENTS
where ORG_STRUCTURE_VERSION_ID =
(
select ORG_STRUCTURE_VERSION_ID
from PER_ORG_STRUCTURE_VERSIONS
where
DATE_TO is null and
ORGANIZATION_STRUCTURE_ID =
(
select ORGANIZATION_STRUCTURE_ID
from PER_ORGANIZATION_STRUCTURES
where NAME = FND_PROFILE.VALUE(''AMW_ORG_SECURITY_HIERARCHY'')
)
)
)
';
/*
The profile value above might not be set, so the inner-most query could return no rows.
*/
end GET_ORG_CONNECTIONS_STRING;




function GET_AUDIT_UNITS_STRING(p_org_id NUMBER) return VARCHAR2 is
begin return
'
(
select distinct ORGANIZATION_ID
from AMW_AUDIT_UNITS_V
where
ORGANIZATION_ID = ' || to_char(p_org_id) || '
)
';
/*
ORGANIZATION_ID in
(
select ORGANIZATION_ID_PARENT from ' || GET_ORG_CONNECTIONS_STRING() || '
union
select ORGANIZATION_ID_CHILD from ' || GET_ORG_CONNECTIONS_STRING() || '
start with ORGANIZATION_ID_PARENT = ' || to_char(p_org_id) || '
connect by ORGANIZATION_ID_PARENT = prior ORGANIZATION_ID_CHILD
)
*/
end GET_AUDIT_UNITS_STRING;




function GET_HIERARCHY_ENTITIES_STRING(p_org_type_code VARCHAR2, p_org_id NUMBER, p_control_id NUMBER) return VARCHAR2 is
begin
if p_org_id is null or (p_org_type_code <> 'OPERATING_UNIT' and p_org_type_code <> 'INV')
then return
'
select distinct OBJECT_TYPE, PK1, PK2, PK3, PK4
from AMW_CONTROL_ASSOCIATIONS
where
CONTROL_ID = ' || to_char(p_control_id) || ' and
APPROVAL_DATE is not null and
DELETION_APPROVAL_DATE is null and
(OBJECT_TYPE = ''RISK_ORG'' or OBJECT_TYPE = ''RISK'' or OBJECT_TYPE = ''ENTITY_CONTROL'')
';
else return
'
select distinct OBJECT_TYPE, PK1, PK2, PK3, PK4
from AMW_CONTROL_ASSOCIATIONS
where
CONTROL_ID = ' || to_char(p_control_id) || ' and
APPROVAL_DATE is not null and
DELETION_APPROVAL_DATE is null and
(
(
OBJECT_TYPE = ''RISK_ORG'' and
PK1 = ' || to_char(p_org_id) || '
)
or
(
OBJECT_TYPE = ''RISK'' and
PK1 in
(
select distinct PROCESS_ID
from AMW_PROCESS_ORGANIZATION
where ORGANIZATION_ID = ' || to_char(p_org_id) || '
)
)
or
(
OBJECT_TYPE = ''ENTITY_CONTROL'' and
PK1 = ' || to_char(p_org_id) || '
)
)
';
/*
(
(
OBJECT_TYPE = ''RISK_ORG'' and
PK1 in ' || GET_AUDIT_UNITS_STRING(p_org_id) || '
)
or
(
OBJECT_TYPE = ''RISK'' and
PK1 in
(
select distinct PROCESS_ID
from AMW_PROCESS_ORGANIZATION
where ORGANIZATION_ID in ' || GET_AUDIT_UNITS_STRING(p_org_id) || '
)
)
or
(
OBJECT_TYPE = ''ENTITY_CONTROL'' and
PK1 in ' || GET_AUDIT_UNITS_STRING(p_org_id) || '
)
)
*/
end if;
end GET_HIERARCHY_ENTITIES_STRING;




procedure SEND_NOTIFICATION_TO_ALL(p_change_id NUMBER) is

type DUMMY_TYPE is REF CURSOR;
m_parameter_code VARCHAR2(111);
m_parameter_name VARCHAR2(240);
m_setup_group_code VARCHAR2(81);
m_setup_group_name VARCHAR2(240);
m_application VARCHAR2(240);
m_pk1_value VARCHAR2(3000);
m_org_type_code VARCHAR2(30);
m_org_type VARCHAR2(240);
m_org_type_test VARCHAR2(240);
m_org_name VARCHAR2(3000);
m_org_id NUMBER;
m_rec_value VARCHAR2(3000);
m_prior_value VARCHAR2(3000);
m_current_value VARCHAR2(3000);
m_updated_by VARCHAR2(100);
m_updated_on DATE;
m_is_audit_unit NUMBER;
m_query VARCHAR2(10000);
m_entities_cursor DUMMY_TYPE;
m_object_type VARCHAR2(30);
m_pk1 NUMBER;
m_pk2 NUMBER;
m_pk3 NUMBER;
m_pk4 NUMBER;
m_return_status VARCHAR2(10);


cursor GET_CONTROLS(p_parameter_code VARCHAR2) is
select distinct CONTROL_ID, NAME, SOURCE
from AMW_CONTROLS_ALL_VL
where
SOURCE = p_parameter_code or
SOURCE in
(
select PARAMETER_CODE
from ITA_PARAMETER_HIERARCHY
start with OVERRIDE_PARAMETER_CODE = p_parameter_code
connect by prior PARAMETER_CODE = OVERRIDE_PARAMETER_CODE
);

cursor GET_OWNER_RISK_ORG(p_org_id NUMBER, p_process_id NUMBER) is
select distinct to_number(replace(grants.GRANTEE_KEY, 'HZ_PARTY:', '')) owner_id
from
FND_GRANTS grants,
FND_OBJECTS objects,
FND_MENUS menus
where
objects.OBJ_NAME = 'AMW_PROCESS_ORGANIZATION' and
grants.OBJECT_ID = objects.OBJECT_ID and
grants.GRANTEE_TYPE = 'USER' and
grants.INSTANCE_TYPE = 'INSTANCE' and
grants.INSTANCE_PK1_VALUE = to_char(p_org_id) and
grants.INSTANCE_PK2_VALUE = to_char(p_process_id) and
grants.GRANTEE_KEY like 'HZ_PARTY%' and
nvl(grants.END_DATE, SYSDATE + 1) >= trunc(sysdate) and
grants.MENU_ID = menus.MENU_ID and
menus.MENU_NAME = 'AMW_ORG_PROC_OWNER_ROLE';

cursor GET_OWNER_RISK(p_process_id NUMBER) is
select distinct to_number(replace(grants.GRANTEE_KEY, 'HZ_PARTY:', '')) owner_id
from
FND_GRANTS grants,
FND_OBJECTS objects,
FND_MENUS menus
where
objects.OBJ_NAME = 'AMW_PROCESS_APPR_ETTY' and
grants.OBJECT_ID = objects.OBJECT_ID and
grants.GRANTEE_TYPE = 'USER' and
grants.INSTANCE_TYPE = 'INSTANCE' and
grants.INSTANCE_PK1_VALUE = to_char(p_process_id) and
grants.GRANTEE_KEY like 'HZ_PARTY%' and
nvl(grants.END_DATE, SYSDATE + 1) >= trunc(sysdate) and
grants.MENU_ID = menus.MENU_ID and
menus.MENU_NAME = 'AMW_RL_PROC_OWNER_ROLE';

cursor GET_OWNER_ORG(p_org_id NUMBER) is
select distinct to_number(replace(grants.GRANTEE_KEY, 'HZ_PARTY:', '')) owner_id
from
FND_GRANTS grants,
FND_OBJECTS objects,
FND_MENUS menus
where
objects.OBJ_NAME = 'AMW_ORGANIZATION' and
grants.OBJECT_ID = objects.OBJECT_ID and
grants.GRANTEE_TYPE = 'USER' and
grants.INSTANCE_TYPE = 'INSTANCE' and
grants.INSTANCE_PK1_VALUE = to_char(p_org_id) and
grants.GRANTEE_KEY like 'HZ_PARTY%' and
nvl(grants.END_DATE, SYSDATE + 1) >= trunc(sysdate) and
grants.MENU_ID = menus.MENU_ID and
menus.MENU_NAME = 'AMW_ORG_MANAGER_ROLE';


begin

select
change.PARAMETER_CODE,
(
select PARAMETER_NAME
from ITA_SETUP_PARAMETERS_VL
where PARAMETER_CODE = change.PARAMETER_CODE
),
change.SETUP_GROUP_CODE,
change.PK1_VALUE,
decode(change.SETUP_GROUP_CODE, 'FND.FND_PROFILE_OPTION_VALUES', nvl(change.PK6_VALUE, ' '), nvl(change.PK1_VALUE, ' ')),
change.PK2_VALUE,
change.RECOMMENDED_VALUE,
change.PRIOR_VALUE,
change.CURRENT_VALUE,
change.CHANGE_AUTHOR,
change.CHANGE_DATE
into
m_parameter_code,
m_parameter_name,
m_setup_group_code,
m_pk1_value,
m_org_name,
m_org_id,
m_rec_value,
m_prior_value,
m_current_value,
m_updated_by,
m_updated_on
from ITA_SETUP_CHANGE_HISTORY change
where
change.INSTANCE_CODE = 'CURRENT' and
change.CHANGE_ID = p_change_id;

select
setup_gp.SETUP_GROUP_NAME,
(
select APPLICATION_NAME
from FND_APPLICATION_VL
where APPLICATION_ID = setup_gp.TABLE_APP_ID
),
setup_gp.HIERARCHY_LEVEL,
decode(setup_gp.SETUP_GROUP_CODE, 'FND.FND_PROFILE_OPTION_VALUES',
(
select MEANING
from FND_LOOKUP_VALUES
where
LANGUAGE = USERENV('LANG') and
VIEW_APPLICATION_ID = 438 and
LOOKUP_TYPE = 'ITA_PROFILE_LEVEL_ID' and
LOOKUP_CODE = m_pk1_value
),
(
select HIERARCHY_LEVEL_NAME
from ITA_SETUP_HIERARCHY_VL
where HIERARCHY_LEVEL_CODE = setup_gp.HIERARCHY_LEVEL
)
)
into
m_setup_group_name,
m_application,
m_org_type_code,
m_org_type
from ITA_SETUP_GROUPS_VL setup_gp
where
setup_gp.SETUP_GROUP_CODE = m_setup_group_code;


-- Ignore changes that did not occur within the context of an auditable unit.
m_is_audit_unit := 0;

begin
select 1 into m_is_audit_unit
from HR_ORGANIZATION_INFORMATION org_info
where
org_info.ORGANIZATION_ID = m_org_id and
org_info.ORG_INFORMATION_CONTEXT = 'CLASS' and
org_info.ORG_INFORMATION1 = 'AMW_AUDIT_UNIT';
exception
when NO_DATA_FOUND then null;
end;

if m_is_audit_unit = 0 and (m_org_type_code = 'OPERATING_UNIT' or m_org_type_code = 'INV') then
return;
end if;


-- Also, ignore profile option changes at levels other than Site.
select MEANING into m_org_type_test
from FND_LOOKUP_VALUES
where
LANGUAGE = USERENV('LANG') and
VIEW_APPLICATION_ID = 438 and
LOOKUP_TYPE = 'ITA_PROFILE_LEVEL_ID' and
LOOKUP_CODE = '10001';

if m_org_type_code = 'PROFILE_OPTION' and m_org_type <> m_org_type_test then
return;
end if;


if m_org_type_code = 'OPERATING_UNIT' or m_org_type_code = 'INV' then
for owner in GET_OWNER_ORG(m_org_id) loop
SEND_NOTIFICATION_TO_OWNER(
0, '', '', owner.OWNER_ID, m_return_status,
m_setup_group_name, m_application, m_org_type, m_org_name, m_parameter_name,
m_rec_value, m_prior_value, m_current_value, m_updated_on, m_updated_by);
end loop;
end if;


for control in GET_CONTROLS(m_parameter_code) loop
m_query := GET_HIERARCHY_ENTITIES_STRING(m_org_type_code, m_org_id, control.CONTROL_ID);
open m_entities_cursor for m_query;

loop
fetch m_entities_cursor into m_object_type, m_pk1, m_pk2, m_pk3, m_pk4;
exit when m_entities_cursor%NOTFOUND;

if m_object_type = 'RISK_ORG' then
for owner in GET_OWNER_RISK_ORG(m_pk1, m_pk2) loop
SEND_NOTIFICATION_TO_OWNER(
control.CONTROL_ID, control.NAME, control.SOURCE, owner.OWNER_ID, m_return_status,
m_setup_group_name, m_application, m_org_type, m_org_name, m_parameter_name,
m_rec_value, m_prior_value, m_current_value, m_updated_on, m_updated_by);
end loop;
for owner in GET_OWNER_ORG(m_pk1) loop
SEND_NOTIFICATION_TO_OWNER(
control.CONTROL_ID, control.NAME, control.SOURCE, owner.OWNER_ID, m_return_status,
m_setup_group_name, m_application, m_org_type, m_org_name, m_parameter_name,
m_rec_value, m_prior_value, m_current_value, m_updated_on, m_updated_by);
end loop;
end if;

if m_object_type = 'RISK' then
for owner in GET_OWNER_RISK(m_pk1) loop
SEND_NOTIFICATION_TO_OWNER(
control.CONTROL_ID, control.NAME, control.SOURCE, owner.OWNER_ID, m_return_status,
m_setup_group_name, m_application, m_org_type, m_org_name, m_parameter_name,
m_rec_value, m_prior_value, m_current_value, m_updated_on, m_updated_by);
end loop;
end if;

if m_object_type = 'ENTITY_CONTROL' then
for owner in GET_OWNER_ORG(m_pk1) loop
SEND_NOTIFICATION_TO_OWNER(
control.CONTROL_ID, control.NAME, control.SOURCE, owner.OWNER_ID, m_return_status,
m_setup_group_name, m_application, m_org_type, m_org_name, m_parameter_name,
m_rec_value, m_prior_value, m_current_value, m_updated_on, m_updated_by);
end loop;
end if;

end loop;

end loop;


commit;
end SEND_NOTIFICATION_TO_ALL;




procedure SEND_NOTIFICATION_TO_OWNER(
p_control_id IN NUMBER,
p_control_name IN VARCHAR2,
p_source IN VARCHAR2,
p_process_owner_id IN NUMBER,
p_return_status OUT NOCOPY VARCHAR2,
p_setup_group IN VARCHAR2,
p_application IN VARCHAR2,
p_org_type IN VARCHAR2,
p_org IN VARCHAR2,
p_setup_parameter IN VARCHAR2,
p_rec_value IN VARCHAR2,
p_prior_value IN VARCHAR2,
p_current_value IN VARCHAR2,
p_updated_on IN DATE,
p_updated_by IN VARCHAR2) is

m_message_subject VARCHAR2(1000);
m_message_body VARCHAR2(30000);
m_notification_id NUMBER;
m_return_status VARCHAR2(10);
m_process_owner_emp_id NUMBER;
m_role_name VARCHAR2(100);
m_role_display_name VARCHAR2(240);


cursor GET_WF_ROLES(p_orig_system_id NUMBER) is
select NAME, substrb(DISPLAY_NAME, 1, 360) display_name
from WF_ROLES
where
ORIG_SYSTEM = 'PER' and
ORIG_SYSTEM_ID = p_orig_system_id
order by STATUS, START_DATE;


begin

FND_MESSAGE.SET_NAME('ITA', 'ITA_OWNER_NOTIFICATION_SUBJECT');
FND_MESSAGE.SET_TOKEN('SETUP_GROUP', p_setup_group, TRUE);
FND_MESSAGE.SET_TOKEN('SETUP_PARAMETER', p_setup_parameter, TRUE);
FND_MSG_PUB.ADD;
m_message_subject := FND_MSG_PUB.GET(
p_msg_index => FND_MSG_PUB.G_LAST,
p_encoded => FND_API.G_FALSE);

FND_MESSAGE.SET_NAME('ITA', 'ITA_OWNER_NOTIFICATION_BODY');
FND_MESSAGE.SET_TOKEN('CONTROL', p_control_name, TRUE);
FND_MESSAGE.SET_TOKEN('SETUP_GROUP', p_setup_group, TRUE);
FND_MESSAGE.SET_TOKEN('APPLICATION', p_application, TRUE);
FND_MESSAGE.SET_TOKEN('ORG_TYPE', p_org_type, TRUE);
FND_MESSAGE.SET_TOKEN('ORG', p_org, TRUE);
FND_MESSAGE.SET_TOKEN('SETUP_PARAMETER', p_setup_parameter, TRUE);
FND_MESSAGE.SET_TOKEN('REC_VALUE', p_rec_value, TRUE);
FND_MESSAGE.SET_TOKEN('PRIOR_VALUE', p_prior_value, TRUE);
FND_MESSAGE.SET_TOKEN('CURRENT_VALUE', p_current_value, TRUE);
FND_MESSAGE.SET_TOKEN('UPDATED_ON', to_char(p_updated_on), TRUE);
FND_MESSAGE.SET_TOKEN('UPDATED_BY', p_updated_by, TRUE);
FND_MSG_PUB.ADD;
m_message_body := FND_MSG_PUB.GET(
p_msg_index => FND_MSG_PUB.G_LAST,
p_encoded => FND_API.G_FALSE);

m_return_status := FND_API.G_RET_STS_SUCCESS;

select EMPLOYEE_ID into m_process_owner_emp_id
from AMW_EMPLOYEES_CURRENT_V
where PARTY_ID = p_process_owner_id;

/*
WF_DIRECTORY.GetRoleName(
p_orig_system => 'PER',
p_orig_system_id => m_process_owner_emp_id,
p_name => m_role_name,
p_display_name => m_role_display_name);
*/
for role in GET_WF_ROLES(m_process_owner_emp_id) loop
m_role_name := role.NAME;
m_role_display_name := role.DISPLAY_NAME;

if m_role_name is null then
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MESSAGE.SET_NAME('AMW','AMW_APPR_INVALID_ROLE');
FND_MSG_PUB.ADD;
return;
end if;

m_notification_id := WF_NOTIFICATION.Send(
role => m_role_name,
msg_type => 'AMWGUTIL',
msg_name => 'ITA_MESG');

WF_NOTIFICATION.SetAttrText(m_notification_id, 'GEN_MSG_SUBJECT', m_message_subject);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'GEN_MSG_BODY', m_message_body);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'GEN_MSG_SEND_TO', m_role_name);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'SETUP_GROUP', p_setup_group);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'APPLICATION', p_application);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'ORG_TYPE', p_org_type);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'ORG', p_org);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'SETUP_PARAMETER', p_setup_parameter);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'REC_VALUE', p_rec_value);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'PRIOR_VALUE', p_prior_value);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'CURRENT_VALUE', p_current_value);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'UPDATED_ON', p_updated_on);
WF_NOTIFICATION.SetAttrText(m_notification_id, 'UPDATED_BY', p_updated_by);

WF_NOTIFICATION.Denormalize_Notification(m_notification_id);

end loop;

p_return_status := m_return_status;


end SEND_NOTIFICATION_TO_OWNER;




end ITA_NOTIFICATION_PKG;

/
