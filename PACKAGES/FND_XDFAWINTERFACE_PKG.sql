--------------------------------------------------------
--  DDL for Package FND_XDFAWINTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_XDFAWINTERFACE_PKG" AUTHID CURRENT_USER as
/* $Header: fndpawis.pls 120.0 2006/05/25 11:53:24 bhthiaga noship $ */




procedure UPLOAD_AW_DEF_INTERFACE(
    X_OBJECT_NAME in VARCHAR2,
    X_OBJECT_TYPE in VARCHAR2,
    X_OBJECT_OWNER in VARCHAR2,
    X_OBJECT_DEFINITION in CLOB,
    X_AW_NAME in VARCHAR2,
    X_LAST_UPDATE_DATE IN VARCHAR2,
    X_CUSTOM_MODE IN VARCHAR2,
    X_LAST_UPDATED_BY  in VARCHAR2
);

end Fnd_XdfAWInterface_Pkg;

 

/
