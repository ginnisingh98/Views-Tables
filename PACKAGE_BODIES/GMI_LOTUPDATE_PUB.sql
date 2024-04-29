--------------------------------------------------------
--  DDL for Package Body GMI_LOTUPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOTUPDATE_PUB" AS
/* $Header: GMIPLALB.pls 120.0 2005/05/25 15:44:37 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPLALB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIPLALB                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the public APIs for updating the descriptive    |
 |    columns in lot master                                                 |
 |                                                                          |
 | Contents                                                                 |
 |    update_lot_dff                                                        |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 2/5/04                                     |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIVDX';

PROCEDURE update_lot_dff
( p_api_version                 IN               NUMBER
, p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level            IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status               OUT NOCOPY       VARCHAR2
, x_msg_count                   OUT NOCOPY       NUMBER
, x_msg_data                    OUT NOCOPY       VARCHAR2
, p_lot_rec                     IN               ic_lots_mst%ROWTYPE
) IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'update_lot_dff' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_count                       NUMBER;
BEGIN
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  /* Transactions are not allowed for the default lots */
  IF (p_lot_rec.lot_id = 0) THEN
	FND_MESSAGE.SET_NAME ( 'GMI', 'IC_DEFAULTLOTERR');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Validate Item */
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM ic_item_mst_b
  WHERE item_id = p_lot_rec.item_id;
  IF l_count = 0 THEN
	FND_MESSAGE.SET_NAME ( 'GMI', 'IC_ITEMERR');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  UPDATE ic_lots_mst
  SET
	attribute1 = p_lot_rec.attribute1,
	attribute2 = p_lot_rec.attribute2,
	attribute3 = p_lot_rec.attribute3,
	attribute4 = p_lot_rec.attribute4,
	attribute5 = p_lot_rec.attribute5,
	attribute6 = p_lot_rec.attribute6,
	attribute7 = p_lot_rec.attribute7,
	attribute8 = p_lot_rec.attribute8,
	attribute9 = p_lot_rec.attribute9,
	attribute10 = p_lot_rec.attribute10,
	attribute11 = p_lot_rec.attribute11,
	attribute12 = p_lot_rec.attribute12,
	attribute13 = p_lot_rec.attribute13,
	attribute14 = p_lot_rec.attribute14,
	attribute15 = p_lot_rec.attribute15,
	attribute16 = p_lot_rec.attribute16,
	attribute17 = p_lot_rec.attribute17,
	attribute18 = p_lot_rec.attribute18,
	attribute19 = p_lot_rec.attribute19,
	attribute20 = p_lot_rec.attribute20,
	attribute22 = p_lot_rec.attribute22,
	attribute21 = p_lot_rec.attribute21,
	attribute23 = p_lot_rec.attribute23,
	attribute24 = p_lot_rec.attribute24,
	attribute25 = p_lot_rec.attribute25,
	attribute26 = p_lot_rec.attribute26,
	attribute27 = p_lot_rec.attribute27,
	attribute28 = p_lot_rec.attribute28,
	attribute29 = p_lot_rec.attribute29,
	attribute30 = p_lot_rec.attribute30
  WHERE
	item_id =  p_lot_rec.item_id and
	lot_id = p_lot_rec.lot_id;
  IF SQL%NOTFOUND THEN
	FND_MESSAGE.SET_NAME ( 'GMI', 'IC_NO_REC_GIVEN_PARAM');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
END;


/*
+==========================================================================+
 | PROCEDURE NAME                                                            |
 |    Update_Lot                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |     This is a public API for updating the descriptive  columns as well    |
 |      as expire date in lot master  				|
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Supriya Malluru - 21-Jan-2005                                     |
 |							|
 +==========================================================================+
*/
PROCEDURE update_lot
( p_api_version                 IN               NUMBER
, p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level            IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status               OUT NOCOPY       VARCHAR2
, x_msg_count                   OUT NOCOPY       NUMBER
, x_msg_data                    OUT NOCOPY       VARCHAR2
, p_lot_rec                     IN              ic_lots_mst%ROWTYPE
) IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'update_lot' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;
  l_count                       NUMBER;

CURSOR cur_old_lot IS SELECT *
 FROM ic_lots_mst a
 WHERE  a.item_id = p_lot_rec.item_id
 AND a.lot_id = p_lot_rec.lot_id;


l_old_rec cur_old_lot%ROWTYPE;

BEGIN
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

OPEN cur_old_lot;
FETCH cur_old_lot INTO l_old_rec;
CLOSE cur_old_lot;

  /* Transactions are not allowed for the default lots */
  IF (l_old_rec.lot_id = 0) THEN
	FND_MESSAGE.SET_NAME ( 'GMI', 'IC_DEFAULTLOTERR');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Validate Item */
  l_count := 0;
  SELECT count(*)
  INTO l_count
  FROM ic_item_mst_b
  WHERE item_id = l_old_rec.item_id;
 IF l_count = 0 THEN
 FND_MESSAGE.SET_NAME ( 'GMI', 'IC_ITEMERR');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

/* Validate EXPIRE Date */
IF (NVL(p_lot_rec.expire_date, SYSDATE ) <> NVL(l_old_rec.expire_date, SYSDATE)) THEN
	IF p_lot_rec.expire_date IS NOT NULL AND p_lot_rec.expire_date < NVL(p_lot_rec.lot_created, l_old_rec.lot_created) THEN
	         FND_MESSAGE.SET_NAME('GMI','IC_PAST_EXPIRE_DATE');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
         END IF;
END IF;

  UPDATE ic_lots_mst
  SET

	expire_date = p_lot_rec.expire_date,
	attribute1 = p_lot_rec.attribute1,
	attribute2 = p_lot_rec.attribute2,
	attribute3 = p_lot_rec.attribute3,
	attribute4 = p_lot_rec.attribute4,
	attribute5 = p_lot_rec.attribute5,
	attribute6 = p_lot_rec.attribute6,
	attribute7 = p_lot_rec.attribute7,
	attribute8 = p_lot_rec.attribute8,
	attribute9 = p_lot_rec.attribute9,
	attribute10 = p_lot_rec.attribute10,
	attribute11 = p_lot_rec.attribute11,
	attribute12 = p_lot_rec.attribute12,
	attribute13 = p_lot_rec.attribute13,
	attribute14 = p_lot_rec.attribute14,
	attribute15 = p_lot_rec.attribute15,
	attribute16 = p_lot_rec.attribute16,
	attribute17 = p_lot_rec.attribute17,
	attribute18 = p_lot_rec.attribute18,
	attribute19 = p_lot_rec.attribute19,
	attribute20 = p_lot_rec.attribute20,
	attribute22 = p_lot_rec.attribute22,
	attribute21 = p_lot_rec.attribute21,
	attribute23 = p_lot_rec.attribute23,
	attribute24 = p_lot_rec.attribute24,
	attribute25 = p_lot_rec.attribute25,
	attribute26 = p_lot_rec.attribute26,
	attribute27 = p_lot_rec.attribute27,
	attribute28 = p_lot_rec.attribute28,
	attribute29 = p_lot_rec.attribute29,
	attribute30 = p_lot_rec.attribute30
  WHERE
	item_id = l_old_rec.item_id
  AND 	lot_id = l_old_rec.lot_id;


  IF SQL%NOTFOUND THEN
	FND_MESSAGE.SET_NAME ( 'GMI', 'IC_NO_REC_GIVEN_PARAM');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
END;

END GMI_LotUpdate_PUB;

/
