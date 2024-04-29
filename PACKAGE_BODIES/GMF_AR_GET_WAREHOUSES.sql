--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_WAREHOUSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_WAREHOUSES" as
/* $Header: gmfwarhb.pls 115.1 99/10/27 12:04:39 porting ship   $ */
          cursor cur_ar_get_warehouses(warehouse_id   number,
                                       warehouse_code varchar2) is
             select OOD.ORGANIZATION_ID,        OOD.ORGANIZATION_CODE,
                    OOD.ORGANIZATION_NAME,      OOD.USER_DEFINITION_ENABLE_DATE,
                    OOD.DISABLE_DATE,           OOD.SET_OF_BOOKS_ID,
                    OOD.CHART_OF_ACCOUNTS_ID,   OOD.INVENTORY_ENABLED_FLAG,
                    HOU.INTERNAL_EXTERNAL_FLAG, HOU.INTERNAL_ADDRESS_LINE,
                    HOU.TYPE,                   MPA.MASTER_ORGANIZATION_ID,
                    MPA.ATTRIBUTE_CATEGORY,     MPA.ATTRIBUTE1,
                    MPA.ATTRIBUTE2,             MPA.ATTRIBUTE3,
                    MPA.ATTRIBUTE4,             MPA.ATTRIBUTE5,
                    MPA.ATTRIBUTE6,             MPA.ATTRIBUTE7,
                    MPA.ATTRIBUTE8,             MPA.ATTRIBUTE9,
                    MPA.ATTRIBUTE10,            MPA.ATTRIBUTE11,
                    MPA.ATTRIBUTE12,            MPA.ATTRIBUTE13,
                    MPA.ATTRIBUTE14,            MPA.ATTRIBUTE15,
                    MPA.CREATED_BY,             MPA.CREATION_DATE,
                    MPA.LAST_UPDATE_DATE,       MPA.LAST_UPDATED_BY
             from   ORG_ORGANIZATION_DEFINITIONS OOD,
                    HR_ORGANIZATION_UNITS HOU,
                    MTL_PARAMETERS MPA
             where  OOD.organization_id =
                    nvl(warehouse_id, OOD.organization_id)
               and  lower(OOD.organization_code) like
                    lower(nvl(warehouse_code, OOD.organization_code));
    procedure AR_GET_WAREHOUSES (warehouse_id       in out number,
                                 warehouse_code     in out varchar2,
                                 name               out    varchar2,
                                 date_from          out    date,
                                 date_to            out    date,
                                 sob_id             out    number,
                                 coa_id             out    number,
                                 inv_enabled_flg    out    varchar2,
                                 int_ext_flag       out    varchar2,
                                 int_addr_line      out    varchar2,
                                 type               out    varchar2,
                                 master_orgid       out    number,
                                 attr_category      out    varchar2,
                                 att1               out    varchar2,
                                 att2               out    varchar2,
                                 att3               out    varchar2,
                                 att4               out    varchar2,
                                 att5               out    varchar2,
                                 att6               out    varchar2,
                                 att7               out    varchar2,
                                 att8               out    varchar2,
                                 att9               out    varchar2,
                                 att10              out    varchar2,
                                 att11              out    varchar2,
                                 att12              out    varchar2,
                                 att13              out    varchar2,
                                 att14              out    varchar2,
                                 att15              out    varchar2,
                                 created_by         out    number,
                                 creation_date      out    date,
                                 last_update_date   out    date,
                                 last_updated_by    out    number,
                                 row_to_fetch       in out number,
                                 error_status       out    number) is
/*   createdby   number;*/
/*   modifiedby  number;*/
    begin
         if NOT cur_ar_get_warehouses%ISOPEN then
            open cur_ar_get_warehouses(warehouse_id, warehouse_code);
         end if;
         fetch cur_ar_get_warehouses
         into  warehouse_id,        warehouse_code,    name,
               date_from,           date_to,           sob_id,
               coa_id,              inv_enabled_flg,   int_ext_flag,
               int_addr_line,       type,              master_orgid,
               attr_category,       att1,              att2,
               att3,                att4,              att5,
               att6,                att7,              att8,
               att9,                att10,             att11,
               att12,               att13,             att14,
               att15,               created_by,         creation_date,
               last_update_date,    last_updated_by;
        if cur_ar_get_warehouses%NOTFOUND then
           error_status := 100;
           close cur_ar_get_warehouses;
/*        else
           created_by := pkg_fnd_get_users.fnd_get_users(createdby);
           last_updated_by := pkg_fnd_get_users.fnd_get_users(modifiedby); */
        end if;
        if row_to_fetch = 1 and cur_ar_get_warehouses%ISOPEN then
           close cur_ar_get_warehouses;
        end if;
      exception
          when others then
               error_status := SQLCODE;
  end AR_GET_WAREHOUSES;
END GMF_AR_GET_WAREHOUSES;

/
