--------------------------------------------------------
--  DDL for Package Body MTL_LOT_CONV_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LOT_CONV_AUDIT_PKG" as
/* $Header: INVHLCAB.pls 120.0 2005/05/25 06:27:38 appldev noship $ */


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
  x_msg_data                OUT NOCOPY VARCHAR2)

IS


CURSOR GET_AUDIT_SEQ
IS
SELECT MTL_CONV_AUDIT_ID_S.NEXTVAL
FROM FND_DUAL;

l_audit_seq              NUMBER;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (X_CONV_AUDIT_ID IS NULL) THEN
     OPEN GET_AUDIT_SEQ;
     FETCH GET_AUDIT_SEQ INTO l_audit_seq;
     X_CONV_AUDIT_ID := l_audit_seq;
     CLOSE GET_AUDIT_SEQ;
  END IF;

  INSERT INTO MTL_LOT_CONV_AUDIT (
    CONV_AUDIT_ID,
    CONVERSION_ID,
    CONVERSION_DATE,
    UPDATE_TYPE_INDICATOR,
    BATCH_ID,
    REASON_ID,
    OLD_CONVERSION_RATE,
    NEW_CONVERSION_RATE,
    EVENT_SPEC_DISP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
    )
  VALUES (
    X_CONV_AUDIT_ID,
    X_CONVERSION_ID,
    X_CONVERSION_DATE,
    X_UPDATE_TYPE_INDICATOR,
    X_BATCH_ID,
    X_REASON_ID,
    X_OLD_CONVERSION_RATE,
    X_NEW_CONVERSION_RATE,
    X_EVENT_SPEC_DISP_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  );

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END INSERT_ROW;


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
  x_msg_data                OUT NOCOPY VARCHAR2)

IS

BEGIN


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  UPDATE MTL_LOT_CONV_AUDIT SET
    CONVERSION_ID = X_CONVERSION_ID,
    CONVERSION_DATE = X_CONVERSION_DATE,
    UPDATE_TYPE_INDICATOR = X_UPDATE_TYPE_INDICATOR,
    BATCH_ID = X_BATCH_ID,
    REASON_ID = X_REASON_ID,
    OLD_CONVERSION_RATE = X_OLD_CONVERSION_RATE,
    NEW_CONVERSION_RATE = X_NEW_CONVERSION_RATE,
    EVENT_SPEC_DISP_ID = X_EVENT_SPEC_DISP_ID,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    WHERE CONV_AUDIT_ID = X_CONV_AUDIT_ID;

    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION


  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('INV','INV_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END UPDATE_ROW;


END MTL_LOT_CONV_AUDIT_PKG;

/
