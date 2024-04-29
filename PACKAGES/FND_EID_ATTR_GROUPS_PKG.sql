--------------------------------------------------------
--  DDL for Package FND_EID_ATTR_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_ATTR_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: fndeidattrgrpss.pls 120.0.12010000.1 2012/07/06 06:26:55 rnagaraj noship $ */

procedure DELETE_ROW(
    X_EID_INSTANCE_ID in NUMBER,
    X_EID_INSTANCE_GROUP IN VARCHAR2,
    X_EID_INSTANCE_ATTRIBUTE IN VARCHAR2
    );

procedure LOAD_ROW (
        X_EID_INSTANCE_ID                    IN VARCHAR2,
        X_EID_INSTANCE_GROUP                 IN VARCHAR2,
        X_EID_INSTANCE_ATTRIBUTE             IN VARCHAR2,
        X_EID_INSTANCE_GROUP_ATTR_SEQ        IN VARCHAR2,
        X_EID_INST_GROUP_ATTR_USER_SEQ       IN VARCHAR2,
        X_GROUP_ATTRIBUTE_SOURCE             IN VARCHAR2,
        X_EID_RELEASE_VERSION                IN VARCHAR2,
        X_OBSOLETED_FLAG                     IN VARCHAR2,
        X_OBSOLETED_EID_REL_VER              IN VARCHAR2,
        X_LAST_UPDATE_DATE                   IN VARCHAR2,
        X_APPLICATION_SHORT_NAME             IN VARCHAR2,
        X_OWNER                              IN VARCHAR2
	);

end FND_EID_ATTR_GROUPS_PKG;

/
