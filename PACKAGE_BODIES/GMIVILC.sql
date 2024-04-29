--------------------------------------------------------
--  DDL for Package Body GMIVILC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVILC" AS
/* $Header: GMIVILCB.pls 115.15 2003/10/10 18:07:30 jdiiorio ship $ */
/* +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVILCB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVILC                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains private code for Item/Lot/Sublot Uom conversion |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Validate_Lot_Conversion                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 | 02-May-2001 A. Mundhe   Bug 1741321 - Added code to validate primary and |
 |                         secondary UOM.                                   |
 |                                                                          |
 | 03-Jul-2002 A. Mundhe   Bug 2446245 - Modified the code such that        |
 |                         typefactor rev is not recalculated unnecessarily |
 |                         causing decimal precision issues.                |
 | 15-Apr-2003 J. DiIorio  Bug 2880585 - Added conversion check to not allow|
 |                         conversion if any transactions exist.            |
 | 10-Oct-2003 J. DiIorio  Bug 3161462 - Altered cur_get_lotid to check also|
 |                         on sublot value.                                 |
 +==========================================================================+
*/
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMIVILC';

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Validate_Lot_Conversion                                               |
 |                                                                          |
 | TYPE                                                                     |
 |     Private                                                              |
 |                                                                          |
 | USAGE                                                                    |
 |    Validate an item conversion record and set up the row for insertion   |
 |    into the database                                                     |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN NUMBER           - API Version                  |
 |    p_init_msg_list    IN VARCHAR2         - Msg List initialization Ind  |
 |    p_commit           IN VARCHAR2         - Commit Indicator             |
 |    p_validation_level IN VARCHAR2         - Validation Level indicator   |
 |    x_return_status    OUT VARCHAR2        - return Status                |
 |    x_msg_count        OUT NUMBER          - Number of Messages returned  |
 |    x_msg_data         OUT VARCHAR2        - Messages in encoded format   |
 |    p_item_cnv_rec     IN item_cnv_rec_typ - Item Conversion details      |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 | 02-May-2001 A. Mundhe	Bug 1741321 - Added code to validate primary and |
 |                         secondary UOM.                                   |
 |                                                                          |
 | 03-Jul-2002 A. Mundhe   Bug 2446245 - Modified the code such that        |
 |                         typefactor rev is not recalculated unnecessarily |
 |                         causing decimal precision issues.                |
 | 11-Nov-2002 J. DiIorio  Bug 2643440 - 11.5.1J - added nocopy.            |
 +==========================================================================+
*/
PROCEDURE Validate_Lot_Conversion
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER :=FND_API.G_VALID_LEVEL_FULL
, p_item_cnv_rec     IN  GMIGAPI.conv_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, x_ic_item_cnv_row  OUT NOCOPY ic_item_cnv%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_name    CONSTANT VARCHAR2 (30) :='Validate Conversion';
l_factor               NUMBER;
l_type_factorrev       NUMBER;
l_from_type            sy_uoms_mst.um_code%TYPE;
l_from_std             sy_uoms_mst.um_code%TYPE;
l_to_type              sy_uoms_mst.um_code%TYPE;
l_to_std               sy_uoms_mst.um_code%TYPE;
l_item_type            sy_uoms_mst.um_code%TYPE;
l_item_std             sy_uoms_mst.um_code%TYPE;
l_rec_from_um          sy_uoms_mst.um_code%TYPE;
l_rec_to_um            sy_uoms_mst.um_code%TYPE;

l_um_type              sy_uoms_mst.um_type%TYPE;
l_from_um              sy_uoms_mst.um_code%TYPE;
l_to_um                sy_uoms_mst.um_code%TYPE;
l_from_std_um          sy_uoms_mst.um_code%TYPE;
l_to_std_um            sy_uoms_mst.um_code%TYPE;
l_count                NUMBER;


/*  Bug#2880585 - New cursors for insert checks */


X_count                NUMBER;
x_lot_id               NUMBER;

CURSOR Cur_get_lotid IS
  SELECT lot_id
  FROM  ic_lots_mst
  WHERE item_id = p_ic_item_mst_row.item_id and
        lot_no = p_item_cnv_rec.lot_no and
        sublot_no = p_item_cnv_rec.sublot_no;

CURSOR Cur_trans_cmp IS
  SELECT count(*)
  FROM  ic_tran_cmp
  WHERE item_id = p_ic_item_mst_row.item_id and
        lot_id = x_lot_id;

CURSOR Cur_trans_pnd IS
  SELECT count(*)
  FROM   ic_tran_pnd
  WHERE  item_id = p_ic_item_mst_row.item_id and
         lot_id = x_lot_id;

CURSOR Cur_journal IS
    SELECT count(1)
    FROM   ic_jrnl_mst m, ic_adjs_jnl a
    WHERE  m.journal_id = a.journal_id
    AND  a.item_id = p_ic_item_mst_row.item_id
    AND  a.lot_id = x_lot_id;


BEGIN

/*  Initialize API return status to sucess */
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

/*  Ensure Upper-case columns are converted */



  l_rec_to_um :=p_item_cnv_rec.to_uom;
  l_rec_from_um :=p_item_cnv_rec.from_uom;

  IF p_ic_item_mst_row.item_id = 0 OR
	 p_ic_item_mst_row.delete_mark = 1
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_cnv_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_ic_item_mst_row.inactive_ind = 1
  AND   GMIGUTL.IC$API_ALLOW_INACTIVE = 0
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_cnv_rec.item_no);
    FND_MSG_PUB.Add;
    x_return_status  :=FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF
     p_ic_lots_mst_row.delete_mark = 1 OR
     p_ic_lots_mst_row.inactive_ind = 1 AND GMIGUTL.IC$API_ALLOW_INACTIVE = 0
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    -- Bug 1741321
    -- Validate Primary Unit of Measure

    IF NOT GMA_VALID_GRP.Validate_um(l_rec_from_um)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_cnv_rec.item_no);
      FND_MESSAGE.SET_TOKEN('UOM',l_rec_from_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- Bug 1741321
  -- Validate Secondary Unit of Measure

  IF NOT GMA_VALID_GRP.Validate_um(l_rec_to_um)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('UOM',l_rec_to_um);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check that conversion factor is positive value */
  -- Bug 2446245
  -- Initialize type_factor and type_factorrev.
  l_factor := p_item_cnv_rec.type_factor;
  l_type_factorrev := 1 / p_item_cnv_rec.type_factor;

  IF (l_factor <= 0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_TYPE_FACTOR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Get UOM details of the from Unit of Measure. If this retrieval fails */
/*  we'll get an exception as there's no point in continuing. */

  SELECT from_type.um_type, from_type.std_um,
           to_type.um_type,   to_type.std_um,
         item_type.um_type, item_type.std_um
  INTO   l_from_type, l_from_std, l_to_type, l_to_std,
         l_item_type, l_item_std
  FROM
  		 sy_uoms_typ from_type,
  		 sy_uoms_mst from_std,
  		 sy_uoms_typ to_type,
  		 sy_uoms_mst to_std,
		 sy_uoms_typ item_type,
		 sy_uoms_mst item_std
  WHERE
         from_type.um_type=from_std.um_type AND
		 from_std.um_code=l_rec_from_um AND
		 from_type.delete_mark=0 AND
		 from_std.delete_mark=0 AND
         item_type.um_type=item_std.um_type AND
		 item_std.um_code=p_ic_item_mst_row.item_um AND
		 item_type.delete_mark=0 AND
		 item_std.delete_mark=0 AND
         to_type.um_type=to_std.um_type AND
		 to_std.um_code=l_rec_to_um AND
		 to_type.delete_mark=0 AND
		 to_std.delete_mark=0;

/*  Check that the from UoM type differs from the to UoM type. If not then */
/*  error and exit */
  IF l_from_type = l_to_type
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_ITEM_UOM_MISMATCH');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check that the unit of measure type of the from_uom or the to_uom */
/*  is the same as the unit of measure type of the item primary uom. */
/*  Adjust conversion factor as appropriate. */

  IF (l_item_std = l_from_std)
  THEN
    l_factor      := 1 / l_factor;
    l_type_factorrev := p_item_cnv_rec.type_factor;
    l_um_type     := l_to_type;
    l_from_um     := l_rec_from_um;
    l_from_std_um := l_from_std;
    l_to_um       := l_rec_to_um;
    l_to_std_um   := l_to_std;
  ELSIF (l_item_std = l_to_std)
  THEN
    /*  we must use reciprocal, and swap 'to' and 'from' */
    /*  Bug 2446245                                      */
    /* Calculate type_factorrev only as type_factor is already initialized. */
    l_factor      := p_item_cnv_rec.type_factor;
    l_type_factorrev := 1 / p_item_cnv_rec.type_factor;
    l_um_type     := l_from_type;
    l_from_um     := l_rec_to_um;
    l_to_um       := l_rec_from_um;
    l_to_std_um   := l_from_std;
    l_from_std_um := l_to_std;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_ITEM_UOM_MISMATCH');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*   Now we have all the data required to calculate the conversion  */
/*  factor from the standard unit of measure of the unit of measure */
/*  type of the item primary unit of measure to the standard unit */
/*  of measure of the unit of measure type of the from_uom. */

/*  First convert from from_uom to std_um for item_um uom type */
/*  if required */

  IF (l_from_um <> l_from_std_um)
  THEN

    l_factor := GMICUOM.uom_conversion(pitem_id     => p_ic_item_mst_row.item_id
                                       ,plot_id     => p_ic_lots_mst_row.lot_id
                                       ,pcur_qty    => l_factor
                                       ,pcur_uom    => l_from_um
                                       ,pnew_uom    => l_from_std_um
                                       ,patomic     => 0
                                      );
     IF (l_factor < 0)
     THEN
       FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_LOT_UOM_FAILED');
       FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
       FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
       FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
       FND_MESSAGE.SET_TOKEN('UM1', l_from_um);
       FND_MESSAGE.SET_TOKEN('UM2', l_from_std_um);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_type_factorrev := 1 / l_factor;

   END IF;

/*  Next convert from to_uom to std_um for to_uom uom type */
/*  if required */

  IF (l_rec_to_um <> l_to_std_um)
  THEN

    l_factor := GMICUOM.uom_conversion(pitem_id     => p_ic_item_mst_row.item_id
                                       ,plot_id     => p_ic_lots_mst_row.lot_id
                                       ,pcur_qty    => l_factor
                                       ,pcur_uom    => l_to_std_um
                                       ,pnew_uom    => l_to_um
                                       ,patomic     => 0
                                      );
    IF (l_factor < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_LOT_UOM_FAILED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('UM1', l_to_um);
      FND_MESSAGE.SET_TOKEN('UM2', l_to_std_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_type_factorrev := 1 / l_factor;

  END IF;

/*  Bug 2446245 - Commented and moved this line up in the code. */
/*  This line of code was causing the decimal precision issue by */
/*  unnecessarily recalculating the factor.
/*  l_type_factorrev := 1 / l_factor; */


/*  Bug 2880585 - Check for transaction activity before         */
/*  creating a new conversion.                                  */

 IF (p_ic_lots_mst_row.lot_id > 0) THEN
     OPEN Cur_get_lotid;
     FETCH Cur_get_lotid INTO X_lot_id;
     CLOSE Cur_get_lotid;
     OPEN Cur_trans_cmp;
     FETCH Cur_trans_cmp INTO X_count;
     CLOSE Cur_trans_cmp;
     IF (X_count = 0) THEN
        OPEN Cur_trans_pnd;
        FETCH Cur_trans_pnd INTO X_count;
        CLOSE Cur_trans_pnd;
        IF (X_count = 0) THEN
           OPEN Cur_journal;
           FETCH Cur_journal INTO X_count;
           CLOSE Cur_journal;
        END IF;
     END IF;
     IF (X_count > 0) THEN
          FND_MESSAGE.SET_NAME('GMI','GMI_LOTCONV_TRANSACTIONS_EXIST');
          FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
          FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
          FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
          FND_MESSAGE.SET_TOKEN('UM1', l_to_um);
          FND_MESSAGE.SET_TOKEN('UM2', l_to_std_um);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
 END IF;


/*  Set up PL/SQL record for insertion into IC_ITEM_CNV */

  x_ic_item_cnv_row.item_id          := p_ic_item_mst_row.item_id;
  x_ic_item_cnv_row.lot_id           := p_ic_lots_mst_row.lot_id;
  x_ic_item_cnv_row.um_type          := l_um_type;
  x_ic_item_cnv_row.type_factor      := l_factor;
  x_ic_item_cnv_row.last_update_date := SYSDATE;
  x_ic_item_cnv_row.last_updated_by  := GMIGUTL.DEFAULT_USER_ID;
  x_ic_item_cnv_row.trans_cnt        := 1;
  x_ic_item_cnv_row.delete_mark      := 0;
  x_ic_item_cnv_row.text_code        := NULL;
  x_ic_item_cnv_row.creation_date    := SYSDATE;
  x_ic_item_cnv_row.created_by       := GMIGUTL.DEFAULT_USER_ID;
  x_ic_item_cnv_row.type_factorrev   := l_type_factorrev;
  x_ic_item_cnv_row.last_update_login := GMIGUTL.DEFAULT_LOGIN;


  FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                             , p_data  => x_msg_data
                            );

  EXCEPTION

    WHEN NO_DATA_FOUND
	THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM');
      FND_MESSAGE.SET_TOKEN('UOM', p_item_cnv_rec.from_uom);
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_item_cnv_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', p_item_cnv_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_item_cnv_rec.sublot_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME
                               , l_api_name
                              );
     FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                , p_data  => x_msg_data
                               );
END Validate_Lot_Conversion;

END GMIVILC;

/
