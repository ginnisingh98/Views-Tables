--------------------------------------------------------
--  DDL for Package Body MTL_LOT_UOM_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LOT_UOM_CONV_PKG" as
/* $Header: INVHLUCB.pls 120.0 2005/05/25 05:39:20 appldev noship $ */


PROCEDURE INSERT_ROW(
  X_CONVERSION_ID           IN OUT NOCOPY NUMBER,
  X_LOT_NUMBER              IN VARCHAR2,
  X_ORGANIZATION_ID         IN NUMBER,
  X_INVENTORY_ITEM_ID       IN NUMBER,
  X_FROM_UNIT_OF_MEASURE    IN VARCHAR2,
  X_FROM_UOM_CODE           IN VARCHAR2,
  X_FROM_UOM_CLASS          IN VARCHAR2,
  X_TO_UNIT_OF_MEASURE      IN VARCHAR2,
  X_TO_UOM_CODE             IN VARCHAR2,
  X_TO_UOM_CLASS            IN VARCHAR2,
  X_CONVERSION_RATE         IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_CREATED_BY              IN NUMBER,
  X_CREATION_DATE           IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2)

IS


CURSOR GET_CONV_SEQ
IS
SELECT MTL_CONVERSION_ID_S.NEXTVAL
FROM FND_DUAL;

l_conv_seq              NUMBER;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (X_CONVERSION_ID IS NULL) THEN
     OPEN GET_CONV_SEQ;
     FETCH GET_CONV_SEQ INTO l_conv_seq;
     X_CONVERSION_ID := l_conv_seq;
     CLOSE GET_CONV_SEQ;
  END IF;


  INSERT INTO MTL_LOT_UOM_CLASS_CONVERSIONS(
      CONVERSION_ID,
      LOT_NUMBER,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      FROM_UNIT_OF_MEASURE,
      FROM_UOM_CODE,
      FROM_UOM_CLASS,
      TO_UNIT_OF_MEASURE,
      TO_UOM_CODE,
      TO_UOM_CLASS,
      CONVERSION_RATE,
      DISABLE_DATE,
      EVENT_SPEC_DISP_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
      )
  VALUES(
      X_CONVERSION_ID,
      X_LOT_NUMBER,
      X_ORGANIZATION_ID,
      X_INVENTORY_ITEM_ID,
      X_FROM_UNIT_OF_MEASURE,
      X_FROM_UOM_CODE,
      X_FROM_UOM_CLASS,
      X_TO_UNIT_OF_MEASURE,
      X_TO_UOM_CODE,
      X_TO_UOM_CLASS,
      X_CONVERSION_RATE,
      X_DISABLE_DATE,
      X_EVENT_SPEC_DISP_ID,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      X_REQUEST_ID,
      X_PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID,
      X_PROGRAM_UPDATE_DATE
  );


    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION


  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);


END INSERT_ROW;


PROCEDURE UPDATE_ROW(
  X_CONVERSION_ID           IN NUMBER,
  X_LOT_NUMBER              IN VARCHAR2,
  X_ORGANIZATION_ID         IN NUMBER,
  X_INVENTORY_ITEM_ID       IN NUMBER,
  X_FROM_UNIT_OF_MEASURE    IN VARCHAR2,
  X_FROM_UOM_CODE           IN VARCHAR2,
  X_FROM_UOM_CLASS          IN VARCHAR2,
  X_TO_UNIT_OF_MEASURE      IN VARCHAR2,
  X_TO_UOM_CODE             IN VARCHAR2,
  X_TO_UOM_CLASS            IN VARCHAR2,
  X_CONVERSION_RATE         IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_EVENT_SPEC_DISP_ID      IN NUMBER,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2)

IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  UPDATE MTL_LOT_UOM_CLASS_CONVERSIONS SET
      LOT_NUMBER = X_LOT_NUMBER,
      ORGANIZATION_ID = X_ORGANIZATION_ID,
      INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
      FROM_UNIT_OF_MEASURE = X_FROM_UNIT_OF_MEASURE,
      FROM_UOM_CODE = X_FROM_UOM_CODE,
      FROM_UOM_CLASS = X_FROM_UOM_CLASS,
      TO_UNIT_OF_MEASURE = X_TO_UNIT_OF_MEASURE,
      TO_UOM_CODE = X_TO_UOM_CODE,
      TO_UOM_CLASS = X_TO_UOM_CLASS,
      CONVERSION_RATE = X_CONVERSION_RATE,
      DISABLE_DATE = X_DISABLE_DATE,
      EVENT_SPEC_DISP_ID = X_EVENT_SPEC_DISP_ID,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
    WHERE CONVERSION_ID = X_CONVERSION_ID;

    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (SQLCODE IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('GMI','GMI_LOTC_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
      FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM(SQLCODE));
      FND_MSG_PUB.Add;
    END IF;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

END UPDATE_ROW;



PROCEDURE DELETE_ROW(
  X_CONVERSION_ID           IN NUMBER,
  X_DISABLE_DATE            IN DATE,
  X_LAST_UPDATED_BY         IN NUMBER,
  X_LAST_UPDATE_DATE        IN DATE,
  X_LAST_UPDATE_LOGIN       IN NUMBER,
  X_REQUEST_ID              IN NUMBER,
  X_PROGRAM_APPLICATION_ID  IN NUMBER,
  X_PROGRAM_ID              IN NUMBER,
  X_PROGRAM_UPDATE_DATE     IN DATE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2)

IS

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    UPDATE MTL_LOT_UOM_CLASS_CONVERSIONS SET
      DISABLE_DATE = X_DISABLE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
    WHERE CONVERSION_ID = X_CONVERSION_ID;

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

END DELETE_ROW;



  PROCEDURE lock_row(
    x_conversion_id                NUMBER
  , x_lot_number                   VARCHAR2
  , x_organization_id              NUMBER
  , x_inventory_item_id            NUMBER
  , x_from_unit_of_measure         VARCHAR2
  , x_from_uom_code                VARCHAR2
  , x_from_uom_class               VARCHAR2
  , x_to_unit_of_measure           VARCHAR2
  , x_to_uom_code                  VARCHAR2
  , x_to_uom_class                 VARCHAR2
  , x_conversion_rate              NUMBER
  , x_disable_date                 DATE
  , x_event_spec_disp_id           NUMBER


  )
IS
    CURSOR c IS
      SELECT        *
      FROM mtl_lot_uom_class_conversions
      WHERE conversion_id = x_conversion_id
      AND   organization_id = x_organization_id
      FOR UPDATE OF organization_id NOWAIT;

    recinfo        c%ROWTYPE;
    record_changed EXCEPTION;

  BEGIN
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

    CLOSE c;


    IF (   (recinfo.organization_id = x_organization_id)
           AND(recinfo.conversion_id = x_conversion_id)
           AND(recinfo.inventory_item_id = x_inventory_item_id)
           AND((recinfo.lot_number = x_lot_number)
               OR((recinfo.lot_number IS NULL)
                  AND(x_lot_number IS NULL)))
           AND ((recinfo.from_unit_of_measure = x_from_unit_of_measure)
               OR ((recinfo.from_unit_of_measure IS NULL)
                  AND (x_from_unit_of_measure IS NULL)))
           AND ((recinfo.from_uom_code = x_from_uom_code)
               OR ((recinfo.from_uom_code IS NULL)
                  AND (x_from_uom_code IS  NULL)))
           AND((recinfo.from_uom_class = x_from_uom_class)
               OR((recinfo.from_uom_class IS NULL)
                  AND(x_from_uom_class IS NULL)))
           AND((recinfo.to_unit_of_measure = x_to_unit_of_measure)
               OR((recinfo.to_unit_of_measure IS NULL)
                  AND(x_to_unit_of_measure IS NULL)))
           AND((recinfo.to_uom_code = x_to_uom_code)
               OR((recinfo.to_uom_code IS NULL)
                  AND(x_to_uom_code IS NULL)))
           AND((recinfo.to_uom_class = x_to_uom_class)
               OR((recinfo.to_uom_class IS NULL)
                  AND(x_to_uom_class IS NULL)))
           AND(recinfo.conversion_rate = x_conversion_rate)
           AND((recinfo.disable_date = x_disable_date)
               OR((recinfo.disable_date IS NULL)
                  AND(x_disable_date IS NULL)))
           AND((recinfo.event_spec_disp_id = x_event_spec_disp_id)
               OR((recinfo.event_spec_disp_id IS NULL)
                  AND(x_event_spec_disp_id IS NULL)))
          ) THEN
         RETURN;
      ELSE
         RAISE record_changed;
    END IF;

  EXCEPTION
    WHEN record_changed THEN
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
  END lock_row;



END MTL_LOT_UOM_CONV_PKG;

/
