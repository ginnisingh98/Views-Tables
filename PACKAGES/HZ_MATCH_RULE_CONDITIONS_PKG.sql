--------------------------------------------------------
--  DDL for Package HZ_MATCH_RULE_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MATCH_RULE_CONDITIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHMSCTS.pls 120.0 2005/05/25 21:09:16 achung noship $ */

PROCEDURE Insert_Row (
    X_MATCH_RULE_SET_CONDITION_ID           IN OUT NOCOPY NUMBER,
    X_MATCH_RULE_SET_ID                     IN     NUMBER,
    X_CONDITION_MATCH_RULE_ID               IN     NUMBER,
    X_ATTRIBUTE_ID                          IN     NUMBER,
    X_OPERATION                             IN     VARCHAR2,
    X_VALUE                                 IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_BETWEEN_CONDITION_BIN_OP              IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_MATCH_RULE_SET_CONDITION_ID           IN	      NUMBER,
    X_MATCH_RULE_SET_ID                     IN     NUMBER,
    X_CONDITION_MATCH_RULE_ID               IN     NUMBER,
    X_ATTRIBUTE_ID                          IN     NUMBER,
    X_OPERATION                             IN     VARCHAR2,
    X_VALUE                                 IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_BETWEEN_CONDITION_BIN_OP              IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE LOCK_ROW (
  X_MATCH_RULE_SET_CONDITION_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER       IN NUMBER
);


PROCEDURE DELETE_ROW (
  X_MATCH_RULE_SET_CONDITION_ID in NUMBER
);

END HZ_MATCH_RULE_CONDITIONS_PKG;


 

/
