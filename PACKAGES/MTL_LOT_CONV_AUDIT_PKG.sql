--------------------------------------------------------
--  DDL for Package MTL_LOT_CONV_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_LOT_CONV_AUDIT_PKG" AUTHID CURRENT_USER as
/* $Header: INVHLCAS.pls 120.0 2005/05/25 05:27:52 appldev noship $ */

PROCEDURE INSERT_ROW(
  X_CONV_AUDIT_ID           IN OUT NOCOPY NUMBER,
  X_CONVERSION_ID           IN NUMBER,
  X_CONVERSION_DATE         IN DATE,
  X_UPDATE_TYPE_INDICATOR   IN NUMBER,
  X_BATCH_ID                IN NUMBER,
  X_REASON_ID               IN NUMBER,
  X_OLD_CONVERSION_RATE     IN NUMBER,
  X_NEW_CONVERSION_RATE     IN NUMBER,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_CREATED_BY              IN NUMBER,
  X_CREATION_DATE           IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_ROW(
  X_CONV_AUDIT_ID           IN NUMBER,
  X_CONVERSION_ID           IN NUMBER,
  X_CONVERSION_DATE         IN DATE,
  X_UPDATE_TYPE_INDICATOR   IN NUMBER,
  X_BATCH_ID                IN NUMBER,
  X_REASON_ID               IN NUMBER,
  X_OLD_CONVERSION_RATE     IN NUMBER,
  X_NEW_CONVERSION_RATE     IN NUMBER,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2);



END MTL_LOT_CONV_AUDIT_PKG;

 

/
