--------------------------------------------------------
--  DDL for Package JAI_RGM_LKPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RGM_LKPS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rgm_lkps_th.pls 120.3 2006/01/20 16:05:00 avallabh ship $ */

PROCEDURE Load_Row(  x_regime_code                 VARCHAR2,
                     x_attribute_type_code         VARCHAR2,
                     x_attribute_code              VARCHAR2,
                     x_attribute_value             VARCHAR2,
                     x_display_value               VARCHAR2,
                     x_default_record              VARCHAR2,
                     x_owner                       VARCHAR2,
                     x_last_update_date            VARCHAR2,
                     x_force_edits                 VARCHAR2 ) ;

 PROCEDURE Insert_Row(
                     X_Rowid            IN OUT NOCOPY rowid,
                     X_regime_code          VARCHAR2,
                     x_attribute_type_code  VARCHAR2,
                     x_attribute_code       VARCHAR2,
                     x_attribute_value      VARCHAR2,
                     x_display_value        VARCHAR2,
                     x_default_record       VARCHAR2,
                     x_creation_date        DATE ,
                     X_Last_Update_Date     DATE,
                     X_Last_Updated_By      NUMBER,
                     X_Created_by           NUMBER,
                     X_Last_Update_Login    NUMBER) ;


PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY rowid,
                     X_regime_code             VARCHAR2,
                     x_attribute_type_code     VARCHAR2,
                     x_attribute_code          VARCHAR2,
                     x_attribute_value         VARCHAR2,
                     x_display_value           VARCHAR2,
                     x_default_record          VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER) ;

END  jai_rgm_lkps_pkg ;
 

/
