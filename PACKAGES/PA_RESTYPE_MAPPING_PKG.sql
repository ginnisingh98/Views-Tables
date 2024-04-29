--------------------------------------------------------
--  DDL for Package PA_RESTYPE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESTYPE_MAPPING_PKG" AUTHID CURRENT_USER AS
/* $Header: PARSUPGS.pls 120.1 2005/08/19 17:00:51 mwasowic noship $ */
-- Procedure    : insert_row
-- Purpose      : To insert data into pa_restype_map_to_resformat table
 PROCEDURE insert_row(
 PX_rowid  IN OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.creation_date%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.created_by%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.last_update_login%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.last_updated_by%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.last_update_date%type);



-- updates record into PA_RESTYPE_MAP_TO_RESFORMAT table
-- Procedure    : update_row
-- Purpose      : To update data of pa_restype_map_to_resformat table

 PROCEDURE update_row(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.CREATION_DATE%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.CREATED_BY%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.LAST_UPDATE_LOGIN%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.LAST_UPDATED_BY%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.LAST_UPDATE_DATE%type);

-- Procedure    : delete_row
-- Purpose      : To delete data from pa_restype_map_to_resformat table
 PROCEDURE delete_row(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type);


-- Procedure    : lock_row
-- Purpose      : To lock data from pa_restype_map_to_resformat table
 PROCEDURE lock_row(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type);

-- Procedure    : load_row
-- Purpose      : To load data into pa_restype_map_to_resformat table from .ldt file
 PROCEDURE load_row(
 P_GROUP_RES_TYPE_CODE IN pa_restype_map_to_resformat.group_res_type_code%type,
 P_RES_TYPE_CODE      IN pa_restype_map_to_resformat.res_type_code%type,
 P_RES_FORMAT_ID     IN pa_restype_map_to_resformat.res_format_id%type,
 P_RESOURCE_CLASS_ID IN pa_restype_map_to_resformat.resource_class_id%type,
 P_LABOR_FLAG       IN pa_restype_map_to_resformat.labor_flag%type,
 P_CREATION_DATE IN pa_restype_map_to_resformat.CREATION_DATE%type,
 P_CREATED_BY   IN pa_restype_map_to_resformat.CREATED_BY%type,
 P_LAST_UPDATE_LOGIN IN pa_restype_map_to_resformat.LAST_UPDATE_LOGIN%type,
 P_LAST_UPDATED_BY  IN pa_restype_map_to_resformat.LAST_UPDATED_BY%type,
 P_LAST_UPDATE_DATE IN pa_restype_map_to_resformat.LAST_UPDATE_DATE%type,
 P_OWNER            IN varchar2);


END PA_RESTYPE_MAPPING_PKG;

 

/
