--------------------------------------------------------
--  DDL for Package JAI_PA_SETUP_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_SETUP_CTX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_pa_setup_ctx.pls 120.0.12000000.1 2007/10/24 18:20:41 rallamse noship $ */

/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */


PROCEDURE Load_Row(   x_context_id    NUMBER      ,
              x_context   VARCHAR2    ,
        x_attribute1_usage  VARCHAR2    ,
        x_attribute2_usage  VARCHAR2    ,
        x_attribute3_usage  VARCHAR2    ,
        x_attribute4_usage  VARCHAR2    ,
        x_attribute5_usage  VARCHAR2    ,
        x_setup_value1_usage  VARCHAR2    ,
        x_setup_value2_usage  VARCHAR2    ,
        x_setup_value3_usage  VARCHAR2    ,
        x_setup_value4_usage  VARCHAR2    ,
        x_setup_value5_usage  VARCHAR2    ,
                          x_owner               VARCHAR2    ,
                          x_last_update_date    VARCHAR2    ,
                          x_force_edits         VARCHAR2    )  ;



 PROCEDURE Insert_Row(
                        X_Rowid     IN OUT NOCOPY ROWID,
      x_context_id    NUMBER       ,
      x_context   VARCHAR2,
      x_attribute1_usage  VARCHAR2,
      x_attribute2_usage  VARCHAR2,
      x_attribute3_usage  VARCHAR2,
      x_attribute4_usage  VARCHAR2,
      x_attribute5_usage  VARCHAR2,
      x_setup_value1_usage  VARCHAR2,
      x_setup_value2_usage  VARCHAR2,
      x_setup_value3_usage  VARCHAR2,
      x_setup_value4_usage  VARCHAR2,
      x_setup_value5_usage  VARCHAR2,
                        X_last_update_date      DATE,
                        X_last_updated_by       NUMBER,
                        X_creation_date         DATE ,
                        X_created_by            NUMBER,
                        X_last_update_login     NUMBER) ;



PROCEDURE Update_Row( X_Rowid                   IN OUT NOCOPY ROWID,
      x_context_id    NUMBER       ,
      x_context   VARCHAR2,
      x_attribute1_usage  VARCHAR2,
      x_attribute2_usage  VARCHAR2,
      x_attribute3_usage  VARCHAR2,
      x_attribute4_usage  VARCHAR2,
      x_attribute5_usage  VARCHAR2,
      x_setup_value1_usage  VARCHAR2,
      x_setup_value2_usage  VARCHAR2,
      x_setup_value3_usage  VARCHAR2,
      x_setup_value4_usage  VARCHAR2,
      x_setup_value5_usage  VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER) ;
END  jai_pa_setup_ctx_pkg  ;
 

/
