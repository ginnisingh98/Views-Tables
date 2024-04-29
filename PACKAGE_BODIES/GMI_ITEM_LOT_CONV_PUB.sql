--------------------------------------------------------
--  DDL for Package Body GMI_ITEM_LOT_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ITEM_LOT_CONV_PUB" AS
-- $Header: GMIPILCB.pls 115.6 2002/11/04 20:14:17 jdiiorio gmigapib.pls $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIPILCB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_ITEM_LOT_CONV_PUB                                                 |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package defines all APIs related to Item/Lot/Sublot Uom          |
--|    conversion                                                            |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Create_Item_Lot_Uom_Conv                                              |
--|                                                                          |
--| HISTORY                                                                  |
--|    25-FEB-1999  M.Godfrey    Upgrade to R11                              |
--|    20/AUG/99    Bug 951828 Change GMS package Calls to GMA               |
--|                 H.Verdding  				             |
--|    25-OCT-2002  J. DiIorio   Bug#2643440 - nocopy added.                 |
--|                                                                          |
--+==========================================================================+
-- Body end of comments
-- Global variables
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_ITEM_LOT_CONV_PUB';

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Item_Lot_Uom_Conv                                              |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create an Item/Lot/Sublot UoM conversion                              |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This procedure creates an Item/Lot/Sublot UoM conversion              |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_api_version      IN NUMBER           - API Version                  |
--|    p_init_msg_list    IN VARCHAR2         - Msg List initialization Ind  |
--|    p_commit           IN VARCHAR2         - Commit Indicator             |
--|    p_validation_level IN VARCHAR2         - Validation Level indicator   |
--|    x_return_status    OUT NOCOPY VARCHAR2  - return Status                |
--|    x_msg_count        OUT NOCOPY NUMBER    - Number of Messages returned  |
--|    x_msg_data         OUT NOCOPY VARCHAR2  - Messages in encoded format   |
--|    p_item_cnv_rec     IN item_cnv_rec_typ - Item Conversion details      |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
-- Api end of comments
PROCEDURE Create_Item_Lot_Uom_Conv
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 :=FND_API.G_FALSE
, p_commit           IN  VARCHAR2 :=FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 :=FND_API.G_VALID_LEVEL_FULL
, p_item_cnv_rec     IN  item_cnv_rec_typ
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_name    CONSTANT VARCHAR2 (30) :='Create_Item_Lot_Uom_Conv';
l_api_version CONSTANT NUMBER        :=2.0;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(1);
l_error_code           NUMBER;
l_factor               NUMBER;
l_type_factorrev       NUMBER;
l_ic_item_cnv_rec      ic_item_cnv%ROWTYPE;
l_ic_item_mst_rec      ic_item_mst%ROWTYPE;
l_ic_lots_mst_rec      ic_lots_mst%ROWTYPE;
l_item_cnv_rec         item_cnv_rec_typ;
l_ic_item_cpg_rec      ic_item_cpg%ROWTYPE;
l_ic_lots_cpg_rec      ic_lots_cpg%ROWTYPE;
l_sy_uoms_mst_rec_um1  sy_uoms_mst%ROWTYPE;
l_sy_uoms_typ_rec_um1  sy_uoms_typ%ROWTYPE;
l_sy_uoms_mst_rec_from sy_uoms_mst%ROWTYPE;
l_sy_uoms_typ_rec_from sy_uoms_typ%ROWTYPE;
l_sy_uoms_mst_rec_to   sy_uoms_mst%ROWTYPE;
l_sy_uoms_typ_rec_to   sy_uoms_typ%ROWTYPE;
l_um_type              sy_uoms_mst.um_type%TYPE;
l_from_um              sy_uoms_mst.um_code%TYPE;
l_to_um                sy_uoms_mst.um_code%TYPE;
l_from_std_um          sy_uoms_mst.um_code%TYPE;
l_to_std_um            sy_uoms_mst.um_code%TYPE;
l_user_name            fnd_user.user_name%TYPE;
l_user_id              fnd_user.user_id%TYPE;

BEGIN

-- Standard Start OF API savepoint
  SAVEPOINT Create_Item_Lot_Uom_Conv;
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_CALL (  l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
				     )
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_int_msg_list is set TRUE.
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;
-- Initialize API return status to sucess
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

-- Populate WHO columns
  l_user_name :=p_item_cnv_rec.user_name;
  GMA_GLOBAL_GRP.Get_who( p_user_name  => l_user_name
                        , x_user_id    => l_user_id
                        );

  IF l_user_id = 0
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_USER_NAME');
    FND_MESSAGE.SET_TOKEN('USER_NAME',l_user_name);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Ensure Upper-case columns are converted

  l_item_cnv_rec          :=p_item_cnv_rec;
  l_item_cnv_rec.to_uom   :=l_item_cnv_rec.to_uom;
  l_item_cnv_rec.from_uom :=l_item_cnv_rec.from_uom;

-- Get the item details ensuring that the item is active and not deleted

  GMI_GLOBAL_GRP.Get_Item (  p_item_no      => l_item_cnv_rec.item_no
                           , x_ic_item_mst  => l_ic_item_mst_rec
                           , x_ic_item_cpg  => l_ic_item_cpg_rec
                          );

  IF (l_ic_item_mst_rec.item_id < 0)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_ic_item_mst_rec.item_id = 0) OR
	(l_ic_item_mst_rec.delete_mark = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_cnv_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.noninv_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_NONINV_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_cnv_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.inactive_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_cnv_rec.item_no);
    FND_MSG_PUB.Add;
--    x_return_status  :=FND_API.G_RET_STS_ERROR;
--    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- If blank or null lot_no then get default lot

  IF (l_item_cnv_rec.lot_no = ' ' OR l_item_cnv_rec.lot_no IS NULL)
  THEN
    l_item_cnv_rec.lot_no :=FND_PROFILE.Value_Specific
			    ( name    => 'IC$DEFAULT_LOT'
			    , user_id => l_user_id
			    );
    IF (l_item_cnv_rec.lot_no IS NULL)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
      FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$DEFAULT_LOT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


-- Get the lot details ensuring that the lot is not deleted.
-- This may be the default lot for the item.


  GMI_GLOBAL_GRP.Get_Lot (  p_item_id      => l_ic_item_mst_rec.item_id
                          , p_lot_no       => l_item_cnv_rec.lot_no
                          , p_sublot_no    => l_item_cnv_rec.sublot_no
                          , x_ic_lots_mst  => l_ic_lots_mst_rec
                          , x_ic_lots_cpg  => l_ic_lots_cpg_rec
                         );

  IF (l_ic_lots_mst_rec.lot_id = -1) OR
     (l_ic_lots_mst_rec.delete_mark = 1) OR
     (l_ic_lots_mst_rec.inactive_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Get UOM details of the from Unit of Measure


  GMI_GLOBAL_GRP.Get_Um (  p_um_code      => l_item_cnv_rec.from_uom
                         , x_sy_uoms_mst  => l_sy_uoms_mst_rec_from
                         , x_sy_uoms_typ  => l_sy_uoms_typ_rec_from
                         , x_error_code   => l_error_code
                        );

   IF (l_error_code = -1)
   THEN
     FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM');
     FND_MESSAGE.SET_TOKEN('UOM', l_item_cnv_rec.from_uom);
     FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
     FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
     FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_error_code = -2)
   THEN
     FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM_TYPE');
     FND_MESSAGE.SET_TOKEN('UOM', l_item_cnv_rec.from_uom);
     FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
     FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
     FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

-- Get UOM details of the to Unit of Measure

  GMI_GLOBAL_GRP.Get_Um (  p_um_code      => l_item_cnv_rec.to_uom
                         , x_sy_uoms_mst  => l_sy_uoms_mst_rec_to
                         , x_sy_uoms_typ  => l_sy_uoms_typ_rec_to
                         , x_error_code   => l_error_code
                        );

  IF (l_error_code = -1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM');
    FND_MESSAGE.SET_TOKEN('UOM', l_item_cnv_rec.to_uom);
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_error_code = -2)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM_TYPE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('UOM', l_item_cnv_rec.to_uom);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Check that the from UoM type differs from the to UoM type. If not then
-- error and exit
  IF l_sy_uoms_typ_rec_from.um_type = l_sy_uoms_typ_rec_to.um_type
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_ITEM_UOM_MISMATCH');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Get UOM details of the item primary Unit of Measure
-- This should not produce any errors but we'll check for them anyway.

  GMI_GLOBAL_GRP.Get_Um (  p_um_code      => l_ic_item_mst_rec.item_um
                         , x_sy_uoms_mst  => l_sy_uoms_mst_rec_um1
                         , x_sy_uoms_typ  => l_sy_uoms_typ_rec_um1
                         , x_error_code   => l_error_code
                        );

  IF (l_error_code = -1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('UOM', l_ic_item_mst_rec.item_um);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_error_code = -2)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_UOM_TYPE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('UOM', l_ic_item_mst_rec.item_um);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Check that the unit of measure type of the from_uom or the to_uom
-- is the same as the unit of measure type of the item primary uom.
-- Adjust conversion factor as appropriate.

  IF (l_sy_uoms_typ_rec_um1.std_um = l_sy_uoms_typ_rec_from.std_um)
  THEN
    l_factor      := 1 / l_item_cnv_rec.type_factor;
    l_um_type     := l_sy_uoms_mst_rec_to.um_type;
    l_from_um     := l_item_cnv_rec.from_uom;
    l_from_std_um := l_sy_uoms_typ_rec_from.std_um;
    l_to_um       := l_item_cnv_rec.to_uom;
    l_to_std_um   := l_sy_uoms_typ_rec_to.std_um;
  ELSIF (l_sy_uoms_typ_rec_um1.std_um = l_sy_uoms_typ_rec_to.std_um)
  THEN
    l_factor      := l_item_cnv_rec.type_factor;
    l_um_type     := l_sy_uoms_mst_rec_from.um_type;
    l_from_um     := l_item_cnv_rec.to_uom;
    l_from_std_um := l_sy_uoms_typ_rec_to.std_um;
    l_to_um       := l_item_cnv_rec.from_uom;
    l_to_std_um   := l_sy_uoms_typ_rec_from.std_um;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_ITEM_UOM_MISMATCH');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Check that item/lot conversion does not already exist

  IF GMI_VALID_GRP.Validate_item_cnv (  l_item_cnv_rec.item_no
                                      , l_item_cnv_rec.lot_no
                                      , l_item_cnv_rec.sublot_no
                                      , l_um_type
                                     )
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_CNV_ALREADY_EXISTS');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('UM_TYPE', l_um_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Check that conversion factor is positive value

  IF (l_factor <= 0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_TYPE_FACTOR');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Now we have all the data required to calculate the conversion
-- factor from the standard unit of measure of the unit of measure
-- type of the item primary unit of measure to the standard unit
-- of measure of the unit of measure type of the from_uom.

-- First convert from from_uom to std_um for item_um uom type
-- if required

  IF (l_from_um <> l_sy_uoms_typ_rec_from.std_um)
  THEN
    l_factor := GMICUOM.uom_conversion(pitem_id     => l_ic_item_mst_rec.item_id
                                       ,plot_id     => l_ic_lots_mst_rec.lot_id
                                       ,pcur_qty    => l_factor
                                       ,pcur_uom    => l_from_um
                                       ,pnew_uom    => l_from_std_um
                                       ,patomic     => 0
                                      );
     IF (l_factor < 0)
     THEN
       FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_LOT_UOM_FAILED');
       FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
       FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
       FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
       FND_MESSAGE.SET_TOKEN('UM1', l_from_um);
       FND_MESSAGE.SET_TOKEN('UM2', l_sy_uoms_typ_rec_from.std_um);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

-- Next convert from to_uom to std_um for to_uom uom type
-- if required

  IF (l_item_cnv_rec.to_uom <> l_sy_uoms_typ_rec_to.std_um)
  THEN
    l_factor := GMICUOM.uom_conversion(pitem_id     => l_ic_item_mst_rec.item_id
                                       ,plot_id     => l_ic_lots_mst_rec.lot_id
                                       ,pcur_qty    => l_factor
                                       ,pcur_uom    => l_to_std_um
                                       ,pnew_uom    => l_to_um
                                       ,patomic     => 0
                                      );
    IF (l_factor < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_LOT_UOM_FAILED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('UM1', l_to_um);
      FND_MESSAGE.SET_TOKEN('UM2', l_sy_uoms_typ_rec_to.std_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

-- Now calculate the inverse value of the conversion factor

  l_type_factorrev := 1 / l_factor;

-- Set up PL/SQL record and insert item/lot conversion into IC_ITEM_CNV

  l_ic_item_cnv_rec.item_id          := l_ic_item_mst_rec.item_id;
  l_ic_item_cnv_rec.lot_id           := l_ic_lots_mst_rec.lot_id;
  l_ic_item_cnv_rec.um_type          := l_um_type;
  l_ic_item_cnv_rec.type_factor      := l_factor;
  l_ic_item_cnv_rec.last_update_date := SYSDATE;
  l_ic_item_cnv_rec.last_updated_by  := l_user_id;
  l_ic_item_cnv_rec.trans_cnt        := 1;
  l_ic_item_cnv_rec.delete_mark      := 0;
  l_ic_item_cnv_rec.text_code        := NULL;
  l_ic_item_cnv_rec.creation_date    := SYSDATE;
  l_ic_item_cnv_rec.created_by       := l_user_id;
  l_ic_item_cnv_rec.type_factorrev   := l_type_factorrev;
  l_ic_item_cnv_rec.last_update_login :=TO_NUMBER(FND_PROFILE.Value(
					'LOGIN_ID'));


  IF NOT GMI_ITEM_LOT_CONV_PVT.insert_IC_ITEM_CNV(l_ic_item_cnv_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- END of API Body

-- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;
-- Success message
  FND_MESSAGE.SET_NAME('GMI','IC_API_ILC_CREATED');
  FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_cnv_rec.item_no);
  FND_MESSAGE.SET_TOKEN('LOT_NO', l_item_cnv_rec.lot_no);
  FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_item_cnv_rec.sublot_no);
  FND_MESSAGE.SET_TOKEN('UM_TYPE', l_um_type);
  FND_MSG_PUB.Add;
-- Standard Call to get message count and if count is 1,
-- get message info.
  FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                             , p_data  => x_msg_data
                            );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Item_Lot_Uom_Conv;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Item_Lot_Uom_Conv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO Create_Item_Lot_Uom_Conv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF FND_MSG_PUB.check_msg_level
--           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--    THEN

      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME
                               , l_api_name
                              );
--   END IF;
     FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                                , p_data  => x_msg_data
                               );
END Create_Item_Lot_Uom_Conv;

-- END of API Body
END GMI_ITEM_LOT_CONV_PUB;

/
