--------------------------------------------------------
--  DDL for Package JAI_RGM_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RGM_DEFS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rgm_defs_th.pls 120.3 2006/01/20 16:16:24 avallabh ship $ */

PROCEDURE Load_Row(  x_regime_code                VARCHAR2,
                     x_description                VARCHAR2,
                     x_owner                      VARCHAR2,
                     x_last_update_date           VARCHAR2,
                     x_force_edits                VARCHAR2 )  ;

 PROCEDURE Insert_Row(
                     X_Rowid              IN OUT NOCOPY ROWID,
                     X_regime_code            VARCHAR2,
                     x_description            VARCHAR2,
                     X_last_update_date       DATE,
                     X_last_updated_by        NUMBER,
                     X_creation_date          DATE ,
                     X_created_by             NUMBER,
                     X_last_update_login      NUMBER) ;


PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY ROWID,
                     X_regime_code             VARCHAR2,
                     x_description             VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER) ;

END  jai_rgm_defs_pkg  ;
 

/
