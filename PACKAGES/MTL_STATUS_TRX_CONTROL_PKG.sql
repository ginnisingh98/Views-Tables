--------------------------------------------------------
--  DDL for Package MTL_STATUS_TRX_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_STATUS_TRX_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: INVMSTCS.pls 120.1 2005/06/11 11:34:36 appldev  $ */

PROCEDURE INSERT_ROW (
   x_ROWID                      IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,p_STATUS_ID              	IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
  ,p_CREATION_DATE              IN      DATE
  ,p_CREATED_BY                 IN      NUMBER
  ,p_LAST_UPDATED_BY            IN      NUMBER
  ,p_LAST_UPDATE_DATE           IN      DATE
  ,p_LAST_UPDATE_LOGIN          IN      NUMBER
  ,p_PROGRAM_APPLICATION_ID     IN      NUMBER
  ,p_PROGRAM_ID                 IN      NUMBER
);

PROCEDURE LOCK_ROW (
   p_STATUS_ID                  IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
);

PROCEDURE UPDATE_ROW (
   p_STATUS_ID                  IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
  ,p_LAST_UPDATED_BY            IN      NUMBER
  ,p_LAST_UPDATE_DATE           IN      DATE
  ,p_LAST_UPDATE_LOGIN          IN      NUMBER
  ,p_PROGRAM_APPLICATION_ID     IN      NUMBER
  ,p_PROGRAM_ID                 IN      NUMBER
);


PROCEDURE INSERT_EXTRA_ROWS(
    p_STATUS_ID                  IN      NUMBER);
END MTL_STATUS_TRX_CONTROL_PKG;

 

/
