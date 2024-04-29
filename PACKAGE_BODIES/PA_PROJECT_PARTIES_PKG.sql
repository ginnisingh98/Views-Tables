--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_PARTIES_PKG" as
/* $Header: PARPPTBB.pls 120.1 2005/08/19 16:58:25 mwasowic noship $ */


procedure INSERT_ROW (
  X_PROJECT_PARTY_ID in out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_RESOURCE_TYPE_ID in NUMBER,
  X_RESOURCE_SOURCE_ID in NUMBER,
  X_PROJECT_ROLE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SCHEDULED_FLAG in varchar2,
  X_GRANT_ID in raw,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select project_party_id from PA_PROJECT_PARTIES
    where PROJECT_PARTY_ID = X_PROJECT_PARTY_ID ;
  x_party c%rowtype;

begin
  select pa_project_parties_s.nextval into x_project_party_id
from dual;

  insert into PA_PROJECT_PARTIES (
    PROJECT_PARTY_ID,
    OBJECT_ID,
    OBJECT_TYPE,
    PROJECT_ID,
    RESOURCE_ID,
    RESOURCE_TYPE_ID,
    RESOURCE_SOURCE_ID,
    PROJECT_ROLE_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SCHEDULED_FLAG,
    record_version_number,
    grant_id,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_PROJECT_PARTY_ID,
    X_OBJECT_ID,
    X_OBJECT_TYPE,
    X_PROJECT_ID,
    X_RESOURCE_ID,
    X_RESOURCE_TYPE_ID,
    X_RESOURCE_SOURCE_ID,
    X_PROJECT_ROLE_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_SCHEDULED_FLAG,
    1,
    x_grant_id,
    sysdate,
    X_CREATED_BY,
    sysdate,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  from dual;

  open c;
  fetch c into X_PARTY;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION when others then
    rollback;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PKG',
                            p_procedure_name => 'INSERT_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
end INSERT_ROW;


procedure LOCK_ROW (
  X_PROJECT_PARTY_ID in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_RESOURCE_TYPE_ID in NUMBER,
  X_RESOURCE_SOURCE_ID in NUMBER,
  X_PROJECT_ROLE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_SCHEDULED_FLAG in VARCHAR2,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c1 is select
      OBJECT_ID,
      OBJECT_TYPE,
      PROJECT_ID,
      RESOURCE_ID,
      RESOURCE_TYPE_ID,
      RESOURCE_SOURCE_ID,
      PROJECT_ROLE_ID,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      SCHEDULED_FLAG,
      PROJECT_PARTY_ID
    from PA_PROJECT_PARTIES
    where PROJECT_PARTY_ID = X_PROJECT_PARTY_ID
    for update of PROJECT_PARTY_ID nowait;
begin
  for tlinfo in c1 loop
      if ((tlinfo.PROJECT_PARTY_ID = X_PROJECT_PARTY_ID)
          AND (tlinfo.OBJECT_ID = X_OBJECT_ID)
          AND (tlinfo.OBJECT_TYPE = X_OBJECT_TYPE)
          AND (nvl(tlinfo.PROJECT_ID,-99) = nvl(X_PROJECT_ID,-99))
          AND ((tlinfo.RESOURCE_ID = X_RESOURCE_ID)
               OR ((tlinfo.RESOURCE_ID is null) AND (X_RESOURCE_ID is null)))
          AND (tlinfo.RESOURCE_TYPE_ID = X_RESOURCE_TYPE_ID)
          AND (tlinfo.RESOURCE_SOURCE_ID = X_RESOURCE_SOURCE_ID)
          AND (tlinfo.PROJECT_ROLE_ID = X_PROJECT_ROLE_ID)
          AND (tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
          AND (nvl(tlinfo.SCHEDULED_FLAG,'X') = nvl(X_SCHEDULED_FLAG,'X'))
          AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_PROJECT_PARTY_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_RESOURCE_SOURCE_ID in NUMBER,
  X_RESOURCE_TYPE_ID in NUMBER,
  X_PROJECT_ROLE_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SCHEDULED_FLAG in varchar2,
  X_GRANT_ID in raw,
  x_record_version_number in number,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_RETURN_STATUS Out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) is
begin
  x_return_status := 'S';
  if pa_install.is_prm_licensed() <> 'Y' then
  update PA_PROJECT_PARTIES set
    RESOURCE_SOURCE_ID = X_RESOURCE_SOURCE_ID,
    RESOURCE_TYPE_ID = X_RESOURCE_TYPE_ID,
    PROJECT_ROLE_ID = X_PROJECT_ROLE_ID,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SCHEDULED_FLAG = X_SCHEDULED_FLAG,
    GRANT_ID = nvl(X_GRANT_ID,GRANT_ID),
    record_version_number = record_version_number + 1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROJECT_PARTY_ID = X_PROJECT_PARTY_ID
    and record_version_number = nvl(x_record_version_number,record_version_number);
  else
   update PA_PROJECT_PARTIES set
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SCHEDULED_FLAG = X_SCHEDULED_FLAG,
    GRANT_ID = nvl(X_GRANT_ID,GRANT_ID),
    record_version_number = record_version_number + 1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROJECT_PARTY_ID = X_PROJECT_PARTY_ID
    and record_version_number = nvl(x_record_version_number,record_version_number);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

Exception
  when no_data_found then
--       fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
--       fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PKG');
--       fnd_message.set_token('PROCEDURE_NAME','UPDATE_ROW');
--       fnd_msg_pub.add;
       x_return_status := 'N';
  --     raise;
  when others then
    rollback;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PKG',
                            p_procedure_name => 'UPDATE_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_PROJECT_ID in NUMBER,
  X_PROJECT_PARTY_ID in NUMBER,
  X_record_version_number in NUMBER
) is
begin
  if x_project_party_id is null then
    delete from pa_project_parties
     where project_id = x_project_id;
  else
    delete from PA_PROJECT_PARTIES
     where PROJECT_PARTY_ID = X_PROJECT_PARTY_ID
       and record_version_number = nvl(x_record_version_number,record_version_number);
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

Exception
  when no_data_found then
       fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
       --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PKG');
       --fnd_message.set_token('PROCEDURE_NAME','DELETE_ROW');
       fnd_msg_pub.add;
  when others then
    rollback;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PKG',
                            p_procedure_name => 'DELETE_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
end DELETE_ROW;


end PA_PROJECT_PARTIES_PKG;

/
