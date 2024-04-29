--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_RTNODE_BIND_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_RTNODE_BIND_VAL_PKG" as
/* $Header: IEURTNBB.pls 120.0 2005/06/02 15:56:20 appldev noship $ */
procedure INSERT_ROW (
  P_RESOURCE_ID in NUMBER,
  P_NODE_ID in NUMBER,
  P_SEL_RT_NODE_ID in NUMBER,
  P_BIND_VAR_NAME in VARCHAR2,
  P_BIND_VAR_VALUE in VARCHAR2,
  P_BIND_VAR_DATA_TYPE in VARCHAR2


) is
   l_not_valid_flag VARCHAR2(1);
begin
       l_not_valid_flag := 'N';
       INSERT INTO IEU_UWQ_RTNODE_BIND_VALS
         (RTNODE_BIND_VAR_ID,
         SEL_RT_NODE_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER,
         RESOURCE_ID,
         NODE_ID,
         BIND_VAR_NAME,
         BIND_VAR_VALUE,
         BIND_VAR_DATATYPE,
         NOT_VALID_FLAG)
       VALUES
       ( IEU_UWQ_RTNODE_BIND_VALS_S1.NEXTVAL,
         P_SEL_RT_NODE_ID ,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         1,
         P_RESOURCE_ID ,
         P_NODE_ID ,
         P_BIND_VAR_NAME ,
         P_BIND_VAR_VALUE,
         P_BIND_VAR_DATA_TYPE,
         l_not_valid_flag);
end INSERT_ROW;

procedure UPDATE_ROW (
  P_RESOURCE_ID in NUMBER,
  P_NODE_ID in NUMBER,
  P_SEL_RT_NODE_ID in NUMBER,
  P_BIND_VAR_NAME in VARCHAR2,
  P_BIND_VAR_VALUE in VARCHAR2,
  P_BIND_VAR_DATA_TYPE in VARCHAR2

) is
begin
     UPDATE IEU_UWQ_RTNODE_BIND_VALS
     SET
       CREATED_BY            =  FND_GLOBAL.USER_ID,
       CREATION_DATE         =  SYSDATE,
       LAST_UPDATED_BY       =  FND_GLOBAL.USER_ID,
       LAST_UPDATE_DATE      =  SYSDATE,
       LAST_UPDATE_LOGIN     =  FND_GLOBAL.LOGIN_ID,
       BIND_VAR_VALUE        =  P_BIND_VAR_VALUE,
       BIND_VAR_DATATYPE     =  P_BIND_VAR_DATA_TYPE,
       NOT_VALID_FLAG        =  'N',
       SEL_RT_NODE_ID        = P_SEL_RT_NODE_ID,
       OBJECT_VERSION_NUMBER =  OBJECT_VERSION_NUMBER + 1
     WHERE RESOURCE_ID     = P_RESOURCE_ID
     AND   NODE_ID         = P_NODE_ID
     AND   BIND_VAR_NAME   = P_BIND_VAR_NAME;

     if (sql%notfound) then
       raise no_data_found;
     end if;
end UPDATE_ROW;

PROCEDURE LOAD_ROW (
  P_RESOURCE_ID in NUMBER,
  P_NODE_ID in NUMBER,
  P_SEL_RT_NODE_ID in NUMBER,
  P_BIND_VAR_NAME in VARCHAR2,
  P_BIND_VAR_VALUE in VARCHAR2,
  P_BIND_VAR_DATA_TYPE in VARCHAR2

) is

 begin

  IEU_UWQ_RTNODE_BIND_VAL_PKG.UPDATE_ROW (
  P_RESOURCE_ID ,
  P_NODE_ID ,
  P_SEL_RT_NODE_ID ,
  P_BIND_VAR_NAME ,
  P_BIND_VAR_VALUE ,
  P_BIND_VAR_DATA_TYPE  );

     if (sql%notfound) then
        raise no_data_found;
     end if;
   Exception
     when no_data_found then
  IEU_UWQ_RTNODE_BIND_VAL_PKG.INSERT_ROW (
  P_RESOURCE_ID ,
  P_NODE_ID ,
  P_SEL_RT_NODE_ID ,
  P_BIND_VAR_NAME ,
  P_BIND_VAR_VALUE ,
  P_BIND_VAR_DATA_TYPE ) ;
END LOAD_ROW;

procedure DELETE_ROW (
  P_RESOURCE_ID in NUMBER,
  P_NODE_ID in NUMBER,
  P_SEL_RT_NODE_ID in NUMBER,
  P_BIND_VAR_NAME in VARCHAR2
) is
begin
  delete from IEU_UWQ_RTNODE_BIND_VALS
  where RESOURCE_ID = P_RESOURCE_ID
  and NODE_ID = P_NODE_ID
  and BIND_VAR_NAME = P_BIND_VAR_NAME
  and SEL_RT_NODE_ID = P_SEL_RT_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IEU_UWQ_RTNODE_BIND_VAL_PKG;

/
