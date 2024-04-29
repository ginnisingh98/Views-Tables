--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_REGISTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_REGISTERS_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzvrgs.pls 120.1 2006/06/23 12:24:53 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.1         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/
  procedure insert_row
            ( x_record                            jg_zz_vat_registers_vl%rowtype
            , x_vat_register_id in  out nocopy    jg_zz_vat_registers_b.vat_register_id%type
            , x_row_id          out     nocopy    rowid
            );

  procedure lock_row
            ( x_record                            jg_zz_vat_registers_vl%rowtype
            );
  procedure update_row
            ( x_record                            jg_zz_vat_registers_vl%rowtype
            );
  procedure delete_row
            ( x_vat_register_id  jg_zz_vat_registers_b.vat_register_id%type
            );

  procedure add_language;

  procedure LOAD_ROW (
    x_VAT_REGISTER_ID              in  NUMBER,
    x_VAT_REPORTING_ENTITY_ID      in  NUMBER,
    x_REGISTER_TYPE                in  VARCHAR2,
    x_REGISTER_NAME                in  VARCHAR2,
    x_EFFECTIVE_FROM_DATE          in  DATE,
    x_EFFECTIVE_TO_DATE            in  DATE,
    x_OWNER                        in  VARCHAR2
  );

  procedure TRANSLATE_ROW (
    X_VAT_REGISTER_ID   in NUMBER,
    X_REGISTER_NAME     in VARCHAR2,
    X_OWNER             in VARCHAR2
  );

end jg_zz_vat_registers_pkg;

 

/
