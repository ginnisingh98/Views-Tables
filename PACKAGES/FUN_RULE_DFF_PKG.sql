--------------------------------------------------------
--  DDL for Package FUN_RULE_DFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_DFF_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULDFFTBS.pls 120.1 2006/02/22 10:51:34 ammishra noship $ */

PROCEDURE Process_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
);

PROCEDURE Insert_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
);

PROCEDURE Update_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_RULE_OBJECT_ID		            IN     NUMBER
);

PROCEDURE Lock_Row (
    X_TABLE_NAME                            IN     VARCHAR2,
    X_RULE_DETAIL_ID		            IN     NUMBER,
    X_ATTRIBUTE_CATEGORY	            IN     VARCHAR2,
    X_ATTRIBUTE1			    IN     VARCHAR2,
    X_ATTRIBUTE2			    IN     VARCHAR2,
    X_ATTRIBUTE3			    IN     VARCHAR2,
    X_ATTRIBUTE4			    IN     VARCHAR2,
    X_ATTRIBUTE5			    IN     VARCHAR2,
    X_ATTRIBUTE6			    IN     VARCHAR2,
    X_ATTRIBUTE7			    IN     VARCHAR2,
    X_ATTRIBUTE8			    IN     VARCHAR2,
    X_ATTRIBUTE9			    IN     VARCHAR2,
    X_ATTRIBUTE10			    IN     VARCHAR2,
    X_ATTRIBUTE11			    IN     VARCHAR2,
    X_ATTRIBUTE12			    IN     VARCHAR2,
    X_ATTRIBUTE13			    IN     VARCHAR2,
    X_ATTRIBUTE14			    IN     VARCHAR2,
    X_ATTRIBUTE15			    IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_RULE_OBJECT_ID		            IN     NUMBER
);

PROCEDURE Select_Row (
    X_TABLE_NAME                            IN             VARCHAR2,
    X_RULE_DETAIL_ID			    IN  OUT NOCOPY NUMBER,
    X_ATTRIBUTE_CATEGORY	            OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE1			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE2			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE3			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE4			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE5			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE6			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE7			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE8			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE9			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE10			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE11			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE12			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE13			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE14			    OUT NOCOPY     VARCHAR2,
    X_ATTRIBUTE15			    OUT NOCOPY     VARCHAR2,
    X_RULE_OBJECT_ID		            OUT NOCOPY     NUMBER
);

PROCEDURE Delete_Row (
    X_TABLE_NAME                             IN     VARCHAR2,
    X_RULE_DETAIL_ID	  		     IN     NUMBER,
    X_RULE_OBJECT_ID		            IN     NUMBER
);

END FUN_RULE_DFF_PKG;

 

/
