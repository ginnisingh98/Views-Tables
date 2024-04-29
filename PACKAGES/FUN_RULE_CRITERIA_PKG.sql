--------------------------------------------------------
--  DDL for Package FUN_RULE_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_CRITERIA_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRCTTBS.pls 120.0 2005/06/20 04:30:01 ammishra noship $ */

PROCEDURE Insert_Row (
    X_ROWID                                 IN OUT NOCOPY VARCHAR2,
    X_CRITERIA_ID                           IN     NUMBER,
    X_RULE_DETAIL_ID                        IN     NUMBER,
    X_CRITERIA_PARAM_ID		            IN     NUMBER,
    X_CONDITION				    IN     VARCHAR2,
    X_PARAM_VALUE			    IN     VARCHAR2,
    X_CASE_SENSITIVE_FLAG		    IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
);

PROCEDURE Update_Row (
    X_CRITERIA_ID                           IN     NUMBER,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_CRITERIA_PARAM_ID		            IN     NUMBER,
    X_CONDITION				    IN     VARCHAR2,
    X_PARAM_VALUE			    IN     VARCHAR2,
    X_CASE_SENSITIVE_FLAG		    IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
);

PROCEDURE Lock_Row (
    X_CRITERIA_ID                           IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER
);

PROCEDURE Select_Row (
    X_CRITERIA_ID         	            IN  OUT NOCOPY   NUMBER,
    X_RULE_DETAIL_ID			    IN  OUT NOCOPY   NUMBER,
    X_CRITERIA_PARAM_ID		            OUT NOCOPY     NUMBER,
    X_CONDITION                             OUT NOCOPY     VARCHAR2,
    X_PARAM_VALUE			    OUT NOCOPY     VARCHAR2,
    X_CASE_SENSITIVE_FLAG		    OUT NOCOPY     VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY     VARCHAR2
);

PROCEDURE Delete_Row (
    X_CRITERIA_ID                           IN     NUMBER
);

END FUN_RULE_CRITERIA_PKG;

 

/
