--------------------------------------------------------
--  DDL for Package Body UMX_REG_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_REG_REQUESTS_PKG" as
/* $Header: UMXRGRQB.pls 115.5 2004/01/09 07:44:06 kching noship $ */
  procedure INSERT_ROW (
      X_REG_REQUEST_ID          in out NOCOPY NUMBER,
      X_REG_SERVICE_TYPE        in VARCHAR2,
      X_STATUS_CODE             in VARCHAR2,
      X_REQUESTED_BY_USER_ID    in NUMBER   DEFAULT NULL,
      X_REQUESTED_FOR_USER_ID   in NUMBER   DEFAULT NULL,
      X_REQUESTED_FOR_PARTY_ID  in NUMBER   DEFAULT NULL,
      X_REQUESTED_USERNAME      in VARCHAR2 DEFAULT NULL,
      X_REQUESTED_START_DATE    in DATE     DEFAULT NULL,
      X_REQUESTED_END_DATE      in DATE     DEFAULT NULL,
      X_WF_ROLE_NAME            in VARCHAR2 DEFAULT NULL,
      X_REG_SERVICE_CODE        in VARCHAR2 DEFAULT NULL,
      X_AME_APPLICATION_ID      in NUMBER   DEFAULT NULL,
      X_AME_TRANSACTION_TYPE_ID in VARCHAR2 DEFAULT NULL,
      X_JUSTIFICATION           in VARCHAR2 DEFAULT NULL) IS

   cursor C is select ROWID from UMX_REG_REQUESTS
      where REG_REQUEST_ID = X_REG_REQUEST_ID;

  BEGIN

    if (X_REG_REQUEST_ID is null) then
      select UMX_REG_REQUESTS_S.nextval into X_REG_REQUEST_ID from dual;
    end if;

    -- do we need to raise a no data found exception??

    insert into UMX_REG_REQUESTS (
        REG_REQUEST_ID,
        REG_SERVICE_TYPE,
        STATUS_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        SECURITY_GROUP_ID,
        REQUESTED_START_DATE,
        REQUESTED_END_DATE,
        REQUESTED_BY_USER_ID,
        REQUESTED_FOR_USER_ID,
        REQUESTED_FOR_PARTY_ID,
        REQUESTED_USERNAME,
        WF_ROLE_NAME,
        REG_SERVICE_CODE,
        AME_APPLICATION_ID,
        AME_TRANSACTION_TYPE_ID,
        JUSTIFICATION
    ) values (
      X_REG_REQUEST_ID,
      x_reg_service_type,
      x_status_code,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      0,
      x_requested_start_date,
      x_requested_end_date,
      fnd_global.user_id,
      x_requested_for_user_id,
      x_requested_for_party_id,
      x_requested_username,
      x_wf_role_name,
      x_reg_service_code,
      x_ame_application_id,
      x_ame_transaction_type_id,
      x_justification
    ) returning REG_REQUEST_ID INTO x_reg_request_id;

    open c;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;

  End INSERT_ROW;

  procedure UPDATE_ROW (
      X_REG_REQUEST_ID          in NUMBER,
      X_STATUS_CODE             in VARCHAR2 DEFAULT NULL,
      X_REQUESTED_BY_USER_ID    in NUMBER   DEFAULT NULL,
      X_REQUESTED_FOR_USER_ID   in NUMBER   DEFAULT NULL,
      X_REQUESTED_FOR_PARTY_ID  in NUMBER   DEFAULT NULL,
      X_REQUESTED_USERNAME      in VARCHAR2 DEFAULT NULL,
      X_REQUESTED_START_DATE    in DATE     DEFAULT NULL,
      X_REQUESTED_END_DATE      in DATE     DEFAULT NULL,
      X_WF_ROLE_NAME            in VARCHAR2 DEFAULT NULL,
      X_REG_SERVICE_CODE        in VARCHAR2 DEFAULT NULL,
      X_AME_APPLICATION_ID      in NUMBER   DEFAULT NULL,
      X_AME_TRANSACTION_TYPE_ID in VARCHAR2 DEFAULT NULL,
      X_JUSTIFICATION           in VARCHAR2 DEFAULT NULL) IS
  BEGIN

    UPDATE UMX_REG_REQUESTS SET
           STATUS_CODE             = decode (X_STATUS_CODE, NULL, STATUS_CODE, fnd_api.g_miss_char, NULL, X_STATUS_CODE),
           LAST_UPDATED_BY         = fnd_global.user_id,
           LAST_UPDATE_DATE        = sysdate,
           REQUESTED_BY_USER_ID    = decode (X_REQUESTED_BY_USER_ID, NULL, REQUESTED_BY_USER_ID, fnd_api.g_miss_num, NULL, X_REQUESTED_BY_USER_ID),
           REQUESTED_FOR_USER_ID   = decode (X_REQUESTED_FOR_USER_ID, NULL, REQUESTED_FOR_USER_ID, fnd_api.g_miss_num, NULL, X_REQUESTED_FOR_USER_ID),
           REQUESTED_FOR_PARTY_ID  = decode (X_REQUESTED_FOR_PARTY_ID, NULL, REQUESTED_FOR_PARTY_ID, fnd_api.g_miss_num, NULL, X_REQUESTED_FOR_PARTY_ID),
           REQUESTED_USERNAME      = decode (X_REQUESTED_USERNAME, NULL, REQUESTED_USERNAME, fnd_api.g_miss_char, NULL, X_REQUESTED_USERNAME),
           REQUESTED_START_DATE    = decode (X_REQUESTED_START_DATE, NULL, REQUESTED_START_DATE, fnd_api.g_miss_date, NULL, X_REQUESTED_START_DATE),
           REQUESTED_END_DATE      = decode (X_REQUESTED_END_DATE, NULL, REQUESTED_END_DATE, fnd_api.g_miss_date, NULL, X_REQUESTED_END_DATE),
           WF_ROLE_NAME            = decode (X_WF_ROLE_NAME, NULL, WF_ROLE_NAME, fnd_api.g_miss_char, NULL, X_WF_ROLE_NAME),
           REG_SERVICE_CODE        = decode (X_REG_SERVICE_CODE, NULL, REG_SERVICE_CODE, fnd_api.g_miss_char, NULL, X_REG_SERVICE_CODE),
           AME_APPLICATION_ID      = decode (X_AME_APPLICATION_ID, NULL, AME_APPLICATION_ID, fnd_api.g_miss_num, NULL, X_AME_APPLICATION_ID),
           AME_TRANSACTION_TYPE_ID = decode (X_AME_TRANSACTION_TYPE_ID, NULL, AME_TRANSACTION_TYPE_ID, fnd_api.g_miss_char, NULL, X_AME_TRANSACTION_TYPE_ID),
           JUSTIFICATION           = decode (X_JUSTIFICATION, NULL, JUSTIFICATION, fnd_api.g_miss_char, NULL, X_JUSTIFICATION)
    WHERE  REG_REQUEST_ID = X_REG_REQUEST_ID;
    if (sql%notfound) then
      raise no_data_found;
    end if;
  END UPDATE_ROW;

  procedure DELETE_ROW (X_REG_REQUEST_ID in NUMBER)IS
  BEGIN

    DELETE FROM UMX_REG_REQUESTS
    WHERE REG_REQUEST_ID = X_REG_REQUEST_ID;
    if (sql%notfound) then
      raise no_data_found;
    end if;

  END DELETE_ROW;

end UMX_REG_REQUESTS_PKG;

/
