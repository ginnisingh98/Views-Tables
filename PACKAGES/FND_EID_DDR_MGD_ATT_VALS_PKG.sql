--------------------------------------------------------
--  DDL for Package FND_EID_DDR_MGD_ATT_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_DDR_MGD_ATT_VALS_PKG" AUTHID CURRENT_USER AS
/* $Header: fndeidhiers.pls 120.0.12010000.2 2012/07/09 23:47:51 rnagaraj noship $ */

PROCEDURE load_mgd_att_row (
       X_UPLOAD_MODE                   IN VARCHAR2,
       X_EID_INST_MGD_ATT_VAL_ID       IN VARCHAR2,
       X_EID_INSTANCE_ID               IN VARCHAR2,
       X_EID_INSTANCE_MGD_ATTRIBUTE    IN VARCHAR2,
       X_EID_INSTANCE_DIM_SPEC         IN VARCHAR2,
       X_EID_INSTANCE_DIMVAL_DISPNAME  IN VARCHAR2,
       X_EID_INSTANCE_DIM_PARENT_SPEC  IN VARCHAR2,
       X_EID_INSTANCE_DIM_VAL_SYNONYM  IN VARCHAR2,
       X_ADDITIONAL_SYNONYMS_FLAG      IN VARCHAR2,
       X_LAST_UPDATE_DATE              IN VARCHAR2,
       X_APPLICATION_SHORT_NAME        IN VARCHAR2,
       X_OWNER                         IN VARCHAR2);

PROCEDURE load_syns_row (
      X_EID_INST_MGD_ATT_VAL_ID   IN VARCHAR2,
      X_ADDITIONAL_SYNONYM        IN VARCHAR2,
      X_SYNONYM_SOURCE            IN VARCHAR2,
      X_LAST_UPDATE_DATE          IN VARCHAR2,
      X_APPLICATION_SHORT_NAME    IN VARCHAR2,
      X_OWNER                     IN VARCHAR2);

end FND_EID_DDR_MGD_ATT_VALS_PKG;

/
