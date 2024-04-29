--------------------------------------------------------
--  DDL for Package PN_PAY_GROUP_BYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_PAY_GROUP_BYS_PKG" AUTHID CURRENT_USER AS
  --$Header: PNGRPBYS.pls 115.1 2004/02/12 08:33:24 kkhegde noship $

-- insert row

PROCEDURE insert_row(
 x_GROUP_BY_ID          IN OUT NOCOPY NUMBER
,x_GROUPING_RULE_ID     IN            NUMBER
,x_GROUP_BY_LOOKUP_CODE IN            VARCHAR2
,x_LAST_UPDATE_DATE     IN            DATE
,x_LAST_UPDATED_BY      IN            NUMBER
,x_CREATION_DATE        IN            DATE
,x_CREATED_BY           IN            NUMBER
,x_LAST_UPDATE_LOGIN    IN            NUMBER
,x_ATTRIBUTE_CATEGORY   IN            VARCHAR2
,x_ATTRIBUTE1           IN            VARCHAR2
,x_ATTRIBUTE2           IN            VARCHAR2
,x_ATTRIBUTE3           IN            VARCHAR2
,x_ATTRIBUTE4           IN            VARCHAR2
,x_ATTRIBUTE5           IN            VARCHAR2
,x_ATTRIBUTE6           IN            VARCHAR2
,x_ATTRIBUTE7           IN            VARCHAR2
,x_ATTRIBUTE8           IN            VARCHAR2
,x_ATTRIBUTE9           IN            VARCHAR2
,x_ATTRIBUTE10          IN            VARCHAR2
,x_ATTRIBUTE11          IN            VARCHAR2
,x_ATTRIBUTE12          IN            VARCHAR2
,x_ATTRIBUTE13          IN            VARCHAR2
,x_ATTRIBUTE14          IN            VARCHAR2
,x_ATTRIBUTE15          IN            VARCHAR2);

-- update row

PROCEDURE update_row(
 x_GROUP_BY_ID          IN            NUMBER
,x_GROUPING_RULE_ID     IN            NUMBER
,x_GROUP_BY_LOOKUP_CODE IN            VARCHAR2
,x_LAST_UPDATE_DATE     IN            DATE
,x_LAST_UPDATED_BY      IN            NUMBER
,x_LAST_UPDATE_LOGIN    IN            NUMBER
,x_ATTRIBUTE_CATEGORY   IN            VARCHAR2
,x_ATTRIBUTE1           IN            VARCHAR2
,x_ATTRIBUTE2           IN            VARCHAR2
,x_ATTRIBUTE3           IN            VARCHAR2
,x_ATTRIBUTE4           IN            VARCHAR2
,x_ATTRIBUTE5           IN            VARCHAR2
,x_ATTRIBUTE6           IN            VARCHAR2
,x_ATTRIBUTE7           IN            VARCHAR2
,x_ATTRIBUTE8           IN            VARCHAR2
,x_ATTRIBUTE9           IN            VARCHAR2
,x_ATTRIBUTE10          IN            VARCHAR2
,x_ATTRIBUTE11          IN            VARCHAR2
,x_ATTRIBUTE12          IN            VARCHAR2
,x_ATTRIBUTE13          IN            VARCHAR2
,x_ATTRIBUTE14          IN            VARCHAR2
,x_ATTRIBUTE15          IN            VARCHAR2);

-- lock row

PROCEDURE lock_row(
 x_GROUP_BY_ID          IN            NUMBER
,x_GROUPING_RULE_ID     IN            NUMBER
,x_GROUP_BY_LOOKUP_CODE IN            VARCHAR2
,x_ATTRIBUTE_CATEGORY   IN            VARCHAR2
,x_ATTRIBUTE1           IN            VARCHAR2
,x_ATTRIBUTE2           IN            VARCHAR2
,x_ATTRIBUTE3           IN            VARCHAR2
,x_ATTRIBUTE4           IN            VARCHAR2
,x_ATTRIBUTE5           IN            VARCHAR2
,x_ATTRIBUTE6           IN            VARCHAR2
,x_ATTRIBUTE7           IN            VARCHAR2
,x_ATTRIBUTE8           IN            VARCHAR2
,x_ATTRIBUTE9           IN            VARCHAR2
,x_ATTRIBUTE10          IN            VARCHAR2
,x_ATTRIBUTE11          IN            VARCHAR2
,x_ATTRIBUTE12          IN            VARCHAR2
,x_ATTRIBUTE13          IN            VARCHAR2
,x_ATTRIBUTE14          IN            VARCHAR2
,x_ATTRIBUTE15          IN            VARCHAR2);

-- delete row

PROCEDURE delete_row(
 x_GROUP_BY_ID          IN            NUMBER);

END PN_PAY_GROUP_BYS_PKG;

 

/
