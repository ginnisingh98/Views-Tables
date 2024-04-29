--------------------------------------------------------
--  DDL for Package Body PA_RESTYPE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESTYPE_MAPPING_PKG" AS
/* $Header: PARSUPGB.pls 120.0 2005/05/31 15:55:52 appldev noship $ */

--Procedure : Insert_row
--Purpose   : Purpose of this procedure is to insert data into pa_restype_map_to_resformat table.
--Parameters: All Parameters passed to his procedure are IN parameters.

PROCEDURE INSERT_ROW(
 PX_ROWID               IN OUT NOCOPY ROWID,
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.creation_date%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.created_by%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.last_update_login%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.last_updated_by%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.last_update_date%type
) IS



BEGIN


  INSERT INTO PA_RESTYPE_MAP_TO_RESFORMAT(
 GROUP_RES_TYPE_CODE,
 RES_TYPE_CODE      ,
 RES_FORMAT_ID     ,
 RESOURCE_CLASS_ID,
 LABOR_FLAG      ,
 CREATION_DATE ,
 CREATED_BY   ,
 LAST_UPDATE_LOGIN,
 LAST_UPDATED_BY ,
 LAST_UPDATE_DATE
  ) VALUES (
 P_GROUP_RES_TYPE_CODE,
 P_RES_TYPE_CODE     ,
 P_RES_FORMAT_ID    ,
 P_RESOURCE_CLASS_ID,
 P_LABOR_FLAG      ,
 P_CREATION_DATE ,
 P_CREATED_BY  ,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATED_BY ,
 P_LAST_UPDATE_DATE
  );
END INSERT_ROW;

--Procedure : Update_row
--Purpose   : Purpose of this procedure is to update data of pa_restype_map_to_resformat table.
--Parameters: All Parameters passed to his procedure are IN parameters.

PROCEDURE UPDATE_ROW(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.creation_date%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.created_by%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.last_update_login%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.last_updated_by%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.last_update_date%type
) IS
BEGIN

  UPDATE pa_restype_map_to_resformat
 set GROUP_RES_TYPE_CODE= P_GROUP_RES_TYPE_CODE,
 RES_TYPE_CODE =     P_RES_TYPE_CODE,
 RES_FORMAT_ID  =   P_RES_FORMAT_ID,
 RESOURCE_CLASS_ID= P_RESOURCE_CLASS_ID,
 LABOR_FLAG     = P_LABOR_FLAG,
 CREATION_DATE = P_CREATION_DATE,
 CREATED_BY   = P_CREATED_BY,
 LAST_UPDATE_LOGIN= P_LAST_UPDATE_LOGIN,
 LAST_UPDATED_BY = P_LAST_UPDATED_BY,
 LAST_UPDATE_DATE= P_LAST_UPDATE_DATE
 where group_res_type_code = p_group_res_type_code and
       res_type_code = p_res_type_code and
       res_format_id = p_res_format_id
       and labor_flag = p_labor_flag;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

END UPDATE_ROW;

--Procedure : Delete_row
--Purpose   : Purpose of this procedure is to delet data from pa_restype_map_to_resformat table.
--Parameters: All Parameters passed to this procedure are IN parameters.

PROCEDURE DELETE_ROW(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type)
IS

begin
 delete from pa_restype_map_to_resformat
 where GROUP_RES_TYPE_CODE = P_GROUP_RES_TYPE_CODE
 and   RES_TYPE_CODE =  P_RES_TYPE_CODE
 and   RES_FORMAT_ID = P_RES_FORMAT_ID;

 if (SQL%NOTFOUND) then
   raise no_data_found;
 end if;

end delete_row;

--Procedure : Lock_row
--Purpose   : Purpose of this procedure is to lock data from pa_restype_map_to_resformat table.
--Parameters: All Parameters passed to this procedure are IN parameters.

PROCEDURE LOCK_ROW(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type)
IS

   cursor lock_row_csr is
   select GROUP_RES_TYPE_CODE,RES_TYPE_CODE,RES_FORMAT_ID
   from  pa_restype_map_to_resformat
   for update of GROUP_RES_TYPE_CODE,RES_TYPE_CODE,RES_FORMAT_ID NOWAIT;

   recinfo lock_row_csr%rowtype;
begin

   open lock_row_csr;
   fetch lock_row_csr into recinfo;
   close lock_row_csr;

   return;
END LOCK_ROW;

--Procedure : Load_row
--Purpose   : Purpose of this procedure is to load data into pa_restype_map_to_resformat table.
--Parameters: All Parameters passed to this procedure are IN parameters.
PROCEDURE LOAD_ROW(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.creation_date%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.created_by%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.last_update_login%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.last_updated_by%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.last_update_date%type,
 P_OWNER            IN VARCHAR2
) IS

 PX_ROWID ROWID;

BEGIN

 PA_RESTYPE_MAPPING_PKG.UPDATE_ROW(
 P_GROUP_RES_TYPE_CODE => P_GROUP_RES_TYPE_CODE,
 P_RES_TYPE_CODE       => P_RES_TYPE_CODE,
 P_RES_FORMAT_ID      =>  P_RES_FORMAT_ID,
 P_RESOURCE_CLASS_ID => P_RESOURCE_CLASS_ID,
 P_LABOR_FLAG       => P_LABOR_FLAG,
 P_CREATION_DATE  => P_CREATION_DATE,
 P_CREATED_BY    => P_CREATED_BY,
 P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATED_BY  => P_LAST_UPDATED_BY,
 P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE);


  EXCEPTION
     WHEN no_data_found then
 PA_RESTYPE_MAPPING_PKG.INSERT_ROW(
 PX_ROWID               => PX_ROWID,
 P_GROUP_RES_TYPE_CODE => P_GROUP_RES_TYPE_CODE,
 P_RES_TYPE_CODE       => P_RES_TYPE_CODE,
 P_RES_FORMAT_ID      =>  P_RES_FORMAT_ID,
 P_RESOURCE_CLASS_ID => P_RESOURCE_CLASS_ID,
 P_LABOR_FLAG       => P_LABOR_FLAG,
 P_CREATION_DATE  => P_CREATION_DATE,
 P_CREATED_BY    => P_CREATED_BY,
 P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATED_BY  => P_LAST_UPDATED_BY,
 P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE);

END LOAD_ROW;


END PA_RESTYPE_MAPPING_PKG;

/
