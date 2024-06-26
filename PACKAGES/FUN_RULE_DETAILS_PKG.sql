--------------------------------------------------------
--  DDL for Package FUN_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_DETAILS_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULRDTTBS.pls 120.0 2005/06/20 04:30:04 ammishra noship $ */

PROCEDURE Insert_Row (
    X_ROWID                                 IN OUT NOCOPY VARCHAR2,
    X_RULE_DETAIL_ID 			    IN     NUMBER,
    X_RULE_OBJECT_ID                        IN     NUMBER,
    X_RULE_NAME				    IN     VARCHAR2,
    X_SEQ				    IN     NUMBER,
    X_OPERATOR				    IN     VARCHAR2,
    X_ENABLED_FLAG			    IN     VARCHAR2,
    X_RESULT_APPLICATION_ID		    IN     NUMBER,
    X_RESULT_VALUE			    IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
);

PROCEDURE Update_Row (
    X_RULE_DETAIL_ID 			    IN     NUMBER,
    X_RULE_OBJECT_ID                        IN     NUMBER,
    X_RULE_NAME				    IN     VARCHAR2,
    X_SEQ				    IN     NUMBER,
    X_OPERATOR				    IN     VARCHAR2,
    X_ENABLED_FLAG			    IN     VARCHAR2,
    X_RESULT_APPLICATION_ID		    IN     NUMBER,
    X_RESULT_VALUE			    IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2
);

PROCEDURE Lock_Row (
    X_RULE_DETAIL_ID 			    IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER
);

PROCEDURE Select_Row (
    X_RULE_NAME		    		    IN  OUT NOCOPY   VARCHAR2,
    X_RULE_DETAIL_ID                        IN  OUT NOCOPY     NUMBER,
    X_RULE_OBJECT_ID		            IN  OUT NOCOPY     NUMBER,
    X_SEQ		    	            OUT NOCOPY     NUMBER,
    X_OPERATOR			            OUT NOCOPY     VARCHAR2,
    X_ENABLED_FLAG			    OUT NOCOPY     VARCHAR2,
    X_RESULT_APPLICATION_ID		    OUT NOCOPY     NUMBER,
    X_RESULT_VALUE			    OUT NOCOPY     VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY     VARCHAR2
);

PROCEDURE Delete_Row (
    X_RULE_DETAIL_ID                        IN NUMBER
);

END FUN_RULE_DETAILS_PKG;

 

/
