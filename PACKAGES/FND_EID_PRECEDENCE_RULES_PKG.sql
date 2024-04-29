--------------------------------------------------------
--  DDL for Package FND_EID_PRECEDENCE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_PRECEDENCE_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: fndeidpreruls.pls 120.0.12010000.1 2012/07/06 06:20:07 rnagaraj noship $ */

PROCEDURE load_row (
      X_EID_INSTANCE_ID IN VARCHAR2,
      X_EID_INSTANCE_PRECEDENCE_RULE   IN VARCHAR2,
      X_TRIGGER_INSTANCE_ATTRIBUTE     IN VARCHAR2,
      X_TARGET_INSTANCE_ATTRIBUTE      IN VARCHAR2,
      X_TRIGGER_ATTR_VALUE             IN VARCHAR2,
      X_LEAF_TRIGGER_FLAG              IN VARCHAR2,
      X_EID_RELEASE_VERSION            IN VARCHAR2,
      X_OBSOLETED_FLAG                 IN VARCHAR2,
      X_OBSOLETED_EID_REL_VER          IN VARCHAR2,
      X_LAST_UPDATE_DATE               IN VARCHAR2,
      X_APPLICATION_SHORT_NAME         IN VARCHAR2,
      X_OWNER                          IN VARCHAR2
     );

end FND_EID_PRECEDENCE_RULES_PKG;

/
