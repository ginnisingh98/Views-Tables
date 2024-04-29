--------------------------------------------------------
--  DDL for Package HZ_HIERARCHY_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_HIERARCHY_NODES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHHINTS.pls 115.2 2003/02/01 03:18:34 srangara noship $ */

PROCEDURE Insert_Row (
    X_ROWID                      OUT NOCOPY     ROWID,
    X_HIERARCHY_TYPE             IN      VARCHAR2,
    X_PARENT_ID                  IN      NUMBER,
    X_PARENT_TABLE_NAME          IN      VARCHAR2,
    X_PARENT_OBJECT_TYPE         IN      VARCHAR2,
    X_CHILD_ID                   IN      NUMBER,
    X_CHILD_TABLE_NAME           IN      VARCHAR2,
    X_CHILD_OBJECT_TYPE          IN      VARCHAR2,
    X_LEVEL_NUMBER               IN      NUMBER,
    X_TOP_PARENT_FLAG            IN      VARCHAR2,
    X_LEAF_CHILD_FLAG            IN      VARCHAR2,
    X_EFFECTIVE_START_DATE       IN      DATE,
    X_EFFECTIVE_END_DATE         IN      DATE,
    X_STATUS                     IN      VARCHAR2,
    X_RELATIONSHIP_ID            IN      NUMBER,
    X_ACTUAL_CONTENT_SOURCE      IN      VARCHAR2
);

PROCEDURE Update_Row (
    X_Rowid                      IN OUT NOCOPY  VARCHAR2,
    X_HIERARCHY_TYPE             IN      VARCHAR2,
    X_PARENT_ID                  IN      NUMBER,
    X_PARENT_TABLE_NAME          IN      VARCHAR2,
    X_PARENT_OBJECT_TYPE         IN      VARCHAR2,
    X_CHILD_ID                   IN      NUMBER,
    X_CHILD_TABLE_NAME           IN      VARCHAR2,
    X_CHILD_OBJECT_TYPE          IN      VARCHAR2,
    X_LEVEL_NUMBER               IN      NUMBER,
    X_TOP_PARENT_FLAG            IN      VARCHAR2,
    X_LEAF_CHILD_FLAG            IN      VARCHAR2,
    X_EFFECTIVE_START_DATE       IN      DATE,
    X_EFFECTIVE_END_DATE         IN      DATE,
    X_STATUS                     IN      VARCHAR2,
    X_RELATIONSHIP_ID            IN      NUMBER,
    X_ACTUAL_CONTENT_SOURCE      IN      VARCHAR2
);

PROCEDURE Select_Row (
    X_HIERARCHY_TYPE             IN      VARCHAR2,
    X_PARENT_ID                  IN      NUMBER,
    X_PARENT_TABLE_NAME          IN      VARCHAR2,
    X_PARENT_OBJECT_TYPE         IN      VARCHAR2,
    X_CHILD_ID                   IN      NUMBER,
    X_CHILD_TABLE_NAME           IN      VARCHAR2,
    X_CHILD_OBJECT_TYPE          IN      VARCHAR2,
    X_EFFECTIVE_START_DATE       IN      DATE,
    X_EFFECTIVE_END_DATE         IN      DATE,
    X_LEVEL_NUMBER               OUT NOCOPY     NUMBER,
    X_TOP_PARENT_FLAG            OUT NOCOPY     VARCHAR2,
    X_LEAF_CHILD_FLAG            OUT NOCOPY     VARCHAR2,
    X_STATUS                     OUT NOCOPY     VARCHAR2,
    X_RELATIONSHIP_ID            OUT NOCOPY     NUMBER
);

END HZ_HIERARCHY_NODES_PKG;

 

/
