--------------------------------------------------------
--  DDL for Package Body UMX_USER_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_USER_SEARCH_PVT" AS
/* $Header: UMXUSRSB.pls 120.3 2006/03/22 12:10:26 cmehta noship $ */

  FUNCTION getStatusCode(p_user_id IN varchar2,
                         p_start_date IN date,
                         p_end_date IN date ) RETURN VARCHAR2 IS

    l_lookup_code varchar2(30) := 'UNASSIGNED';
    cursor get_pwd is select ENCRYPTED_USER_PASSWORD from fnd_user
    where user_id =  p_user_id;
    l_encrypted_user_password FND_USER.ENCRYPTED_USER_PASSWORD%TYPE;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getStatusCode.begin',
                     'userId: ' || p_user_id ||
                     ' | startDate: ' || p_start_date ||
                     ' | endDate: ' || p_end_date);
    end if;

    open get_pwd;
    fetch get_pwd into l_encrypted_user_password;
    close get_pwd;

    if ( p_user_id is null ) then
      l_lookup_code := 'UNASSIGNED';
    elsif ( to_char( p_start_date, 'MM/DD/YYYY HH24:MI' ) = to_char( FND_API.G_MISS_DATE, 'MM/DD/YYYY HH24:MI' )
          and to_char( p_end_date, 'MM/DD/YYYY HH24:MI' ) = to_char( FND_API.G_MISS_DATE, 'MM/DD/YYYY HH24:MI' ) ) then
      l_lookup_code := 'PENDING';
    elsif l_encrypted_user_password = 'INVALID' then
         l_lookup_code := 'LOCKED';
    elsif (p_start_date is not null and p_start_date <= sysdate) and
          (p_end_date is null or p_end_date > sysdate ) then
      l_lookup_code := 'ACTIVE';
    else
      l_lookup_code := 'INACTIVE';
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getStatusCode.end',
                     'lookupCode: ' || l_lookup_code);
    end if;

    return l_lookup_code;

  END  getStatusCode;

  FUNCTION canResetPassword(userName IN varchar2 default null,
                            funcName in varchar2,
                            object_name varchar2,
                            obj_pk_val varchar2 ) RETURN  varchar2 IS
    "Return Value" BOOLEAN;
    l_return_value_str varchar2 (5);
  BEGIN
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.canResetPassword.begin',
                     'userName: ' || userName ||
                     ' | funcName: ' || funcName ||
                     ' | objectName: ' || object_name ||
                     ' | objPkVal: ' || obj_pk_val);
    end if;

    "Return Value" := fnd_function.test_instance (funcName,
                                                  object_name,
                                                  obj_pk_val,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  userName);

    if ("Return Value") then
      l_return_value_str := 'TRUE';
    else
      l_return_value_str := 'FALSE';
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                      'fnd.plsql.UMXUSRSB.canResetPassword.end',
                      'returnValue: ' || l_return_value_str);
    end if;

    -- Output the results
    return l_return_value_str;
  END;

  FUNCTION getAccountStatus(p_user_id IN varchar2,
                            p_start_date IN date,
                            p_end_date IN date ) RETURN  varchar2 IS
    l_status varchar2(30) := 'UNKNOWN';
    l_lookup_code varchar2 (100);

    cursor get_lookup_meaning (lookup_code in varchar2) is
      select meaning
      from   fnd_lookup_values_vl
      where  lookup_type = 'UMX_USER_ACC_DET_STATUS'
      and    lookup_code = l_lookup_code;

  BEGIN

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getAccountStatus.begin',
                     'userId: ' || p_user_id ||
                     ' | startDate: ' || p_start_date ||
                     ' | endDate: ' || p_end_date);
    end if;

    l_lookup_code := getStatusCode (p_user_id    => p_user_id,
                                    p_start_date => p_start_date,
                                    p_end_date   => p_end_date);

    open get_lookup_meaning (l_lookup_code);
    fetch get_lookup_meaning into l_status;
    close get_lookup_meaning;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getAccountStatus.end',
                     'status: ' || l_status);
    end if;

    if ( l_status is not null ) then
      return l_status;
    end if;
  END;

  FUNCTION getAccountStatusCode(p_user_id IN varchar2,
                                p_start_date IN date,
                                p_end_date IN date ) RETURN  varchar2 IS

  begin
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getAccountStatusCode.begin',
                     'userId: ' || p_user_id ||
                     ' | startDate: ' || p_start_date ||
                     ' | endDate: ' || p_end_date);
    end if;

    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXUSRSB.getAccountStatusCode.end', '');
    end if;

    return getStatusCode(p_user_id => p_user_id,
                         p_start_date => p_start_date,
                         p_end_date =>p_end_date);

  end getAccountStatusCode;

END UMX_USER_SEARCH_PVT;

/
