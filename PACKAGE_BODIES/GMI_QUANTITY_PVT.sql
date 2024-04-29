--------------------------------------------------------
--  DDL for Package Body GMI_QUANTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_QUANTITY_PVT" AS
--$Header: GMIVQTYB.pls 115.9 2000/02/03 04:23:58 pkm ship      $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIVQTYB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_QUANTITY_PVT                                                      |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Validate_Inventory_Posting                                            |
--|    Insert_Ic_Jrnl_Mst                                                    |
--|    Insert_Ic_Adjs_Mst                                                    |
--|    Check_unposted_jnl_lot_status                                         |
--|    Check_unposted_jnl_qc_grade                                           |
--|                                                                          |
--| HISTORY                                                                  |
--|    25-FEB-1999  M.Godfrey      Upgrade to R11                            |
--|    20/AUG/1999  H.Verdding Bug 951828 Change GMS package Calls to GMA    |
--|    27/OCT/1999  H.Verdding Bug 1042739 added l_trans_rec.orgn_code To    |
--|                 GMA_VALID_GRP.Validate_doc_no                            |
--|                                                                          |
--|    02/JAN/2000  Liz Enstone Bug 1159223 Change message names from SY_    |
--                  to IC_
--+==========================================================================+
-- Body end of comments

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMI_QUANTITY_PVT';
IC$DEFAULT_LOT           VARCHAR2(255);
IC$DEFAULT_LOCT          VARCHAR2(255);
IC$ALLOWNEGINV           VARCHAR2(255);
IC$MOVEDIFFSTAT          VARCHAR2(255);

--+=========================================================================+
--| PROCEDURE NAME                                                          |
--|    Validate_Inventory_Posting                                           |
--|                                                                         |
--| TYPE                                                                    |
--|    Public                                                               |
--|                                                                         |
--| USAGE                                                                   |
--|    Perform validation functions for inventory quantities posting        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure performs all the validation functions concerned with  |
--|    inventory quantity postings.                                         |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_trans_rec      Record datatype containing all inventory posting    |
--|                     data                                                |
--|    x_item_id        Surrogate key of the item                           |
--|    x_lot_id         Surrogate key of the lot                            |
--|    x_old_lot_status Original lot status of item/lot/location            |
--|    x_old_qc_grade   Original QC grade of item/lot                       |
--|    x_trans_rec      Record datatype containing all inventory posting    |
--|                     data                                                |
--|    x_return_status  'S'-success, 'E'-error, 'U'-unexpected error        |
--|    x_msg_count      Count of messages in message list                   |
--|    x_msg_data       Message data                                        |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--|    16-AUG-1999      H.Verdding    Added Fix For B965832 Part 2          |
--|                                   Prevent Transactions Against          |
--|				      Default Lot.                          |
--|    17-AUG-1999      H.Verdding    Added Fix For B959444                 |
--|                                   Amended Deviation Logic               |
--+=========================================================================+
PROCEDURE Validate_Inventory_Posting
( p_trans_rec       IN  GMI_QUANTITY_PUB.trans_rec_typ
, x_item_id         OUT ic_item_mst.item_id%TYPE
, x_lot_id          OUT ic_lots_mst.lot_id%TYPE
, x_old_lot_status  OUT ic_lots_sts.lot_status%TYPE
, x_old_qc_grade    OUT qc_grad_mst.qc_grade%TYPE
, x_return_status   OUT VARCHAR2
, x_msg_count       OUT NUMBER
, x_msg_data        OUT VARCHAR2
, x_trans_rec       OUT GMI_QUANTITY_PUB.trans_rec_typ
)
IS
l_trans_rec             GMI_QUANTITY_PUB.trans_rec_typ;
l_ic_item_mst_rec       ic_item_mst%ROWTYPE;
l_ic_item_cpg_rec       ic_item_cpg%ROWTYPE;
l_ic_lots_mst_rec       ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_rec       ic_lots_cpg%ROWTYPE;
l_ic_whse_mst_rec       ic_whse_mst%ROWTYPE;
l_ic_loct_inv_rec_from  ic_loct_inv%ROWTYPE;
l_ic_loct_inv_rec_to    ic_loct_inv%ROWTYPE;
l_sy_reas_cds_rec       sy_reas_cds%ROWTYPE;
l_lot_rec               GMI_LOTS_PUB.lot_rec_typ;
l_item_id               ic_item_mst.item_id%TYPE;
l_lot_id                ic_lots_mst.lot_id%TYPE;
l_qty2                  NUMBER;
l_lot_onhand            NUMBER  :=0;
l_trans_type            NUMBER(2);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_return_val            NUMBER;
l_neg_qty               NUMBER  :=0;
l_user_name             fnd_user.user_name%TYPE;
l_user_id               fnd_user.user_id%TYPE;

BEGIN

  l_user_name  := p_trans_rec.user_name;

-- Populate WHO columns
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

  -- Get required system constants
  IC$DEFAULT_LOT  := FND_PROFILE.Value_Specific( name    => 'IC$DEFAULT_LOT'
                                               , user_id => l_user_id
                                               );
  IF (IC$DEFAULT_LOT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$DEFAULT_LOT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IC$DEFAULT_LOCT  := FND_PROFILE.Value_Specific( name    => 'IC$DEFAULT_LOCT'
                                                , user_id => l_user_id
                                                );
  IF (IC$DEFAULT_LOCT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$DEFAULT_LOCT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IC$ALLOWNEGINV  := FND_PROFILE.Value_Specific( name    => 'IC$ALLOWNEGINV'
                                               , user_id => l_user_id
                                               );
  IF (IC$ALLOWNEGINV IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$ALLOWNEGINV');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IC$MOVEDIFFSTAT  := FND_PROFILE.Value_Specific( name    => 'IC$MOVEDIFFSTAT'
                                               , user_id => l_user_id
                                               );
  IF (IC$MOVEDIFFSTAT IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_CONSTANT');
    FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','IC$MOVEDIFFSTAT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Store transaction locally
  l_trans_rec     := p_trans_rec;
  l_trans_type    := p_trans_rec.trans_type;

  -- Validate transaction type in the range 1 - 5
  IF NOT GMA_VALID_GRP.NumRangeCheck(1,5,l_trans_type)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_TRANS_TYPE');
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE',l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check for inappropriate fields being passed for transaction type
  -- From Warehouse
  IF (l_trans_rec.from_whse_code <> ' ' AND
      l_trans_rec.from_whse_code IS NOT NULL) AND
     (l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_FROM_WHSE_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- To Warehouse
  IF (l_trans_rec.to_whse_code <> ' ' AND
      l_trans_rec.to_whse_code IS NOT NULL) AND
     (l_trans_type <> 3)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_TO_WHSE_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- From Location
  IF (l_trans_rec.from_location <> ' ' AND
      l_trans_rec.from_location IS NOT NULL) AND
     (l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOCATION_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- To Location
  IF (l_trans_rec.to_location <> ' ' AND
     l_trans_rec.to_location IS NOT NULL AND
     l_trans_type <> 3)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOCATION_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Primary UOM
  IF (l_trans_rec.item_um <> ' ' AND
      l_trans_rec.item_um IS NOT NULL) AND
     (l_trans_type = 4 OR
      l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Secondary UOM
  IF (l_trans_rec.item_um2 <> ' ' AND
      l_trans_rec.item_um2 IS NOT NULL) AND
     (l_trans_type = 4 OR
      l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UOM2_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Primary qty
  IF (l_trans_rec.trans_qty <> 0 AND
      l_trans_rec.trans_qty IS NOT NULL) AND
     (l_trans_type = 4 OR
      l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_QTY_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Secondary qty
  IF (l_trans_rec.trans_qty2 <> 0 AND
      l_trans_rec.trans_qty2 IS NOT NULL) AND
     (l_trans_type = 4 OR
      l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_QTY2_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- QC Grade
  IF (l_trans_rec.qc_grade <> ' ' AND
      l_trans_rec.qc_grade IS NOT NULL) AND
     (l_trans_type <> 5) AND (l_trans_type <>1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_QC_GRADE_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Lot Status
  IF (l_trans_rec.lot_status <> ' ' AND
      l_trans_rec.lot_status IS NOT NULL) AND
     (l_trans_type <> 4)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_STATUS_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate Journal number
  -- Added orgn_code to function call
  -- H.Verdding Bug 1042739
  IF NOT GMA_VALID_GRP.Validate_doc_no('JRNL',l_trans_rec.journal_no
                                             ,l_trans_rec.orgn_code)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_JOURNAL_NO');
    FND_MESSAGE.SET_TOKEN('JOURNAL_NO',l_trans_rec.journal_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF (l_trans_rec.journal_no = ' ' OR
        l_trans_rec.journal_no IS NULL)
    THEN
      l_trans_rec.journal_no :=GMA_GLOBAL_GRP.Get_doc_no
			       ( 'JRNL'
                               , l_trans_rec.orgn_code
                               );
      IF (l_trans_rec.journal_no = ' ')
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_DOC_NO');
        FND_MESSAGE.SET_TOKEN('DOC_TYPE','JRNL');
        FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_trans_rec.orgn_code);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

  -- Validate Reason Code
  GMA_GLOBAL_GRP.Get_Reason_Code
		 ( p_reason_code    => l_trans_rec.reason_code
                 , x_sy_reas_cds    => l_sy_reas_cds_rec
		 );
  IF (l_sy_reas_cds_rec.reason_code = ' ')
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_REASON_CODE');
    FND_MESSAGE.SET_TOKEN('REASON_CODE',l_trans_rec.reason_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the item details
  GMI_GLOBAL_GRP.Get_Item (  p_item_no      => l_trans_rec.item_no
                           , x_ic_item_mst  => l_ic_item_mst_rec
                           , x_ic_item_cpg  => l_ic_item_cpg_rec
                         );
  -- If errors were found then raise exception
  IF (l_ic_item_mst_rec.item_id < 0)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_ic_item_mst_rec.item_id = 0) OR
	(l_ic_item_mst_rec.delete_mark = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.noninv_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_NONINV_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.inactive_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check that transaction type is applicable to item
  -- QC grade change
  IF (l_ic_item_mst_rec.grade_ctl = 0 AND l_trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INV_TRANS_TYPE_FOR_ITEM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Lot status change
  IF (l_ic_item_mst_rec.status_ctl = 0 AND l_trans_type = 4)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INV_TRANS_TYPE_FOR_ITEM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_TYPE', l_trans_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Default unit of measure fields for status and QC grade change
  IF (l_trans_type > 3)
  THEN
    l_trans_rec.item_um   := l_ic_item_mst_rec.item_um;
    l_trans_rec.item_um2  := l_ic_item_mst_rec.item_um2;
  END IF;

  -- Store item_id for return to calling API
  x_item_id    :=l_ic_item_mst_rec.item_id;
  l_item_id    :=l_ic_item_mst_rec.item_id;

  -- Store the default lot_status of the item. This will be
  -- used as the 'Old' lot_status for QC grade transactions
  -- In this situation 'Old' and 'New' lot_status is not
  -- applicable.
  x_old_lot_status  :=l_ic_item_mst_rec.lot_status;

  -- If not change lot status then store lot_status
  IF (l_trans_type <> 4)
  THEN
    l_trans_rec.lot_status  :=l_ic_item_mst_rec.lot_status;
  END IF;

  -- Check lot parameters
  IF (l_ic_item_mst_rec.lot_ctl = 0)
  THEN
    IF (l_trans_rec.lot_no <>' ' AND
        l_trans_rec.lot_no IS NOT NULL)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    IF (l_trans_rec.lot_no = ' ' OR
        l_trans_rec.lot_no IS NULL)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

    -- Check sub-lot parameters
  IF (l_trans_rec.sublot_no IS NULL)
  THEN
    l_trans_rec.sublot_no := NULL;
  END IF;

  IF (l_ic_item_mst_rec.sublot_ctl = 0)
  THEN
    IF (l_trans_rec.sublot_no <>' ')
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_SUBLOT_NOT_REQD');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Get existing lot details. If item not lot controlled then
  -- get the default lot.

  IF (l_ic_item_mst_rec.sublot_ctl = 0)
  THEN
    l_trans_rec.sublot_no  :=NULL;
  END IF;

  IF (l_ic_item_mst_rec.lot_ctl = 0)
  THEN
    l_trans_rec.lot_no    :=IC$DEFAULT_LOT;
  ELSE
-- Do not Allow Transactions against DEFAULT LOT
-- H.Verdding B965832 Part 2
    IF (l_ic_item_mst_rec.lot_ctl = 1 AND
        l_trans_rec.lot_no='DEFAULTLOT')
     THEN
      FND_MESSAGE.SET_NAME('GMI','IC_DEFAULTLOTERR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  GMI_GLOBAL_GRP.Get_Lot (  p_item_id      => l_ic_item_mst_rec.item_id
                          , p_lot_no       => l_trans_rec.lot_no
                          , p_sublot_no    => l_trans_rec.sublot_no
                          , x_ic_lots_mst  => l_ic_lots_mst_rec
                          , x_ic_lots_cpg  => l_ic_lots_cpg_rec
                         );
-- Check for deleted or inactive lot
  IF (l_ic_lots_mst_rec.delete_mark = 1) OR
     (l_ic_lots_mst_rec.inactive_ind = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_lots_mst_rec.lot_id = -2)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If the was lot not found and not creating inventory then error
  IF (l_trans_type <> 1)
  THEN
    IF (l_ic_lots_mst_rec.lot_id = -1)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
  -- If the lot was not found when creating inventory then create it
    IF (l_ic_lots_mst_rec.lot_id = -1)
    THEN
  -- Set up PL/SQL record and create the lot
      l_lot_rec.item_no    :=l_trans_rec.item_no;
      l_lot_rec.lot_no     :=l_trans_rec.lot_no;
      l_lot_rec.sublot_no  :=l_trans_rec.sublot_no;
      l_lot_rec.user_name  :=l_trans_rec.user_name;
      l_lot_rec.qc_grade   :=l_trans_rec.qc_grade;
      GMI_LOTS_PUB.Create_Lot (  p_api_version     => 2.0
                               , x_return_status   => l_return_status
                               , x_msg_count       => l_msg_count
                               , x_msg_data        => l_msg_data
                               , p_lot_rec         => l_lot_rec
                              );
  -- If errors were found then raise exception
      IF (l_return_status = FND_API.G_RET_STS_ERROR)
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  -- Initialize message list to remove 'Lot created' message
      FND_MSG_PUB.Initialize;

  -- Get lot details for lot created
      GMI_GLOBAL_GRP.Get_Lot (  p_item_id      => l_ic_item_mst_rec.item_id
                              , p_lot_no       => l_trans_rec.lot_no
                              , p_sublot_no    => l_trans_rec.sublot_no
                              , x_ic_lots_mst  => l_ic_lots_mst_rec
                              , x_ic_lots_cpg  => l_ic_lots_cpg_rec
                              );
    END IF;
  END IF;

  -- Store the lot_id and original QC grade locally
  x_lot_id       := l_ic_lots_mst_rec.lot_id;
  l_lot_id       := l_ic_lots_mst_rec.lot_id;
  x_old_qc_grade := l_ic_lots_mst_rec.qc_grade;

  -- If QC grade change then check new QC grade differs from existing
  -- If not QC grade change then store lot QC grade as new QC grade
  IF (l_trans_type = 5)
  THEN
    IF (l_trans_rec.qc_grade = l_ic_lots_mst_rec.qc_grade)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_SAME_QC_GRADE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_trans_rec.qc_grade :=l_ic_lots_mst_rec.qc_grade;
  END IF;

  -- Validate 'from' warehouse code (not applicable for change QC Grade)
  IF (l_trans_type <> 5)
  THEN
    GMI_GLOBAL_GRP.Get_Warehouse (  p_whse_code   => l_trans_rec.from_whse_code
                                  , x_ic_whse_mst => l_ic_whse_mst_rec
                                 );
    IF (l_ic_whse_mst_rec.whse_code = ' ') OR
       (l_ic_whse_mst_rec.delete_mark = 1)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_CODE');
      FND_MESSAGE.SET_TOKEN('WHSE_CODE', l_trans_rec.from_whse_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
  -- Check location parameters
      IF NOT GMI_VALID_GRP.Validate_Location
		     (  p_item_loct_ctl  => l_ic_item_mst_rec.loct_ctl
                      , p_whse_loct_ctl  => l_ic_whse_mst_rec.loct_ctl
                      , p_whse_code      => l_trans_rec.from_whse_code
                      , p_location       => l_trans_rec.from_location
                      )
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_trans_rec.item_no);
        FND_MESSAGE.SET_TOKEN('WHSE_CODE', l_trans_rec.from_whse_code);
        FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.from_location);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_trans_rec.from_location = ' ' OR
             l_trans_rec.from_location IS NULL)
      THEN
        l_trans_rec.from_location := IC$DEFAULT_LOCT;
      END IF;
    END IF;
  ELSE
  -- For QC Grade changes 'from' warehouse and location are not relevant
     l_trans_rec.from_whse_code := NULL;
     l_trans_rec.from_location  := NULL;
  END IF;

  -- If move inventory transaction then validate 'to' warehouse code
  IF (l_trans_type = 3)
  THEN
    GMI_GLOBAL_GRP.Get_Warehouse (  p_whse_code   =>l_trans_rec.to_whse_code
                                  , x_ic_whse_mst => l_ic_whse_mst_rec
			         );
    IF (l_ic_whse_mst_rec.whse_code = ' ') OR
       (l_ic_whse_mst_rec.delete_mark = 1)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_CODE');
      FND_MESSAGE.SET_TOKEN('WHSE_CODE', l_trans_rec.to_whse_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
  -- Check location parameters
      IF NOT GMI_VALID_GRP.Validate_Location
                     (  p_item_loct_ctl => l_ic_item_mst_rec.loct_ctl
                      , p_whse_loct_ctl => l_ic_whse_mst_rec.loct_ctl
                      , p_whse_code     => l_trans_rec.to_whse_code
                      , p_location      => l_trans_rec.to_location
                     )
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCATION');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_trans_rec.item_no);
        FND_MESSAGE.SET_TOKEN('WHSE_CODE', l_trans_rec.to_whse_code);
        FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.to_location);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        IF (l_trans_rec.to_location = ' '  OR
            l_trans_rec.to_location IS NULL)
        THEN
          l_trans_rec.to_location := IC$DEFAULT_LOCT;
        END IF;
      END IF;
    END IF;
    -- Check that from warehouse/location differs from to warehouse/location
    IF (l_trans_rec.from_whse_code = l_trans_rec.to_whse_code) AND
       (l_trans_rec.from_location  = l_trans_rec.to_location)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_SAME_WHSE_LOC');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  -- For Change lot status 'to' warehouse and location are the same as 'from'
  ELSIF (l_trans_type = 4)
  THEN
    l_trans_rec.to_whse_code := l_trans_rec.from_whse_code;
    l_trans_rec.to_location  := l_trans_rec.from_location;
  ELSE
  -- For Create, adjust or QC Grade changes 'to' warehouse and location
  -- are not relevant
    l_trans_rec.to_whse_code := NULL;
    l_trans_rec.to_location  := NULL;
  END IF;

  -- If adjusting, moving or changing lot status, check that inventory
  -- exists at from warehouse / location
--LIZ Put this call outside the trans_type condition
--  IF (l_trans_type <> 5)
--  THEN
    GMI_GLOBAL_GRP.Get_loct_inv (  p_item_id     =>l_item_id
                                 , p_whse_code   =>l_trans_rec.from_whse_code
                                 , p_lot_id      =>l_lot_id
                                 , p_location    =>l_trans_rec.from_location
                                 , x_ic_loct_inv =>l_ic_loct_inv_rec_from
			        );
  -- If inventory create then should be no stock at location.
  -- If inventory adjust then may or may not be stock at location
  IF (l_trans_type <> 5)
    THEN
    IF (l_trans_type = 1 OR l_trans_type = 2) AND
       (l_ic_loct_inv_rec_from.item_id = 0)
    THEN
      l_ic_loct_inv_rec_from.loct_onhand  :=0;
      l_ic_loct_inv_rec_from.loct_onhand2 :=0;
      l_trans_rec.lot_status              :=l_ic_item_mst_rec.lot_status;
    ELSIF (l_trans_type = 1)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_LOCT_ONHAND_EXISTS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_trans_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_ic_loct_inv_rec_from.item_id = 0) OR
         (l_ic_loct_inv_rec_from.loct_onhand = 0 AND l_trans_type =4)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NO_LOCT_ONHAND');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_trans_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_trans_type = 2)
    THEN
      l_trans_rec.lot_status :=l_ic_loct_inv_rec_from.lot_status;
  -- If adjust inventory then this will also be new lot status
    ELSIF (l_trans_type = 4) AND
	 (l_trans_rec.lot_status = l_ic_loct_inv_rec_from.lot_status)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_SAME_LOT_STATUS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
  -- Store original lot status
      x_old_lot_status  :=l_ic_loct_inv_rec_from.lot_status;
    END IF;
  -- If changing QC grade then check lot has inventory
  ELSIF (l_trans_type = 5)
  THEN
    GMI_GLOBAL_GRP.Get_lot_inv (  p_item_id     =>l_item_id
                                , p_lot_id      =>l_lot_id
                                , x_lot_onhand  =>l_lot_onhand
			       );
      x_old_lot_status  :=l_ic_loct_inv_rec_from.lot_status;
    IF (l_lot_onhand = 0 OR l_lot_onhand IS NULL)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NO_LOT_ONHAND');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Check for zero quantity
  IF (l_trans_type < 4)
  THEN
    IF (l_trans_rec.trans_qty =0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_ZERO_QTY');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_trans_rec.trans_qty2 <> 0 AND
        l_trans_rec.trans_qty2 IS NOT NULL) AND
       (l_ic_item_mst_rec.dualum_ind = 0 OR
	l_ic_item_mst_rec.dualum_ind =1)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_QTY2');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Check Primary UoM
  IF NOT GMA_VALID_GRP.Validate_um(l_trans_rec.item_um)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('UOM',l_trans_rec.item_um);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Handle Quantities
  -- If primary Uom differs from item primary UoM then convert
  -- transaction quantity
  IF (l_trans_rec.item_um <> l_ic_item_mst_rec.item_um) OR
     (l_trans_rec.item_um IS NULL)
  THEN
    -- If quantity to convert is negative then make positive for conversion
    IF l_trans_rec.trans_qty < 0
    THEN
      l_neg_qty  := 1;
      l_trans_rec.trans_qty  := 0 - l_trans_rec.trans_qty;
    END IF;
    l_trans_rec.trans_qty :=GMICUOM.uom_conversion
                          ( pitem_id    =>l_item_id
                          , plot_id     =>l_lot_id
                          , pcur_qty    =>l_trans_rec.trans_qty
                          , pcur_uom    =>l_trans_rec.item_um
                          , pnew_uom    =>l_ic_item_mst_rec.item_um
                          , patomic     =>0
                          );
    -- Negative quantity indicates UoM conversion failure
    IF (l_trans_rec.trans_qty < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('FROM_UOM',l_trans_rec.item_um);
      FND_MESSAGE.SET_TOKEN('TO_UOM',l_ic_item_mst_rec.item_um);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_trans_rec.item_um  :=l_ic_item_mst_rec.item_um;
      -- Reverse quantity sign if reversed above
      IF l_neg_qty = 1
      THEN
        l_neg_qty  := 0;
        l_trans_rec.trans_qty  := 0 - l_trans_rec.trans_qty;
      END IF;
    END IF;
  END IF;

  -- If dual unit of measure then convert to item secondary unit of measure
  IF (l_ic_item_mst_rec.dualum_ind > 0)
  THEN
    -- If quantity to convert is negative then make positive for conversion
    IF l_trans_rec.trans_qty < 0
    THEN
      l_neg_qty  := 1;
      l_trans_rec.trans_qty  := 0 - l_trans_rec.trans_qty;
    END IF;
    l_qty2 :=GMICUOM.uom_conversion
           ( pitem_id    =>l_item_id
           , plot_id     =>l_lot_id
           , pcur_qty    =>l_trans_rec.trans_qty
           , pcur_uom    =>l_ic_item_mst_rec.item_um
           , pnew_uom    =>l_ic_item_mst_rec.item_um2
           , patomic     =>0
           );
    -- Negative quantity indicates UoM conversion failure
    IF (l_qty2 < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('FROM_UOM',l_ic_item_mst_rec.item_um);
      FND_MESSAGE.SET_TOKEN('TO_UOM',l_ic_item_mst_rec.item_um2);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Reverse quantity sign if reversed above
    IF l_neg_qty = 1
    THEN
      l_neg_qty  := 0;
      l_trans_rec.trans_qty  := 0 - l_trans_rec.trans_qty;
      l_qty2                 := 0 - l_qty2;
    END IF;
    -- If fixed conversion then converted value is secondary qty
    IF (l_ic_item_mst_rec.dualum_ind = 1) OR
       (l_ic_item_mst_rec.dualum_ind =2 AND l_trans_rec.trans_qty2 = 0)
    THEN
      l_trans_rec.trans_qty2  :=l_qty2;
      l_trans_rec.item_um2    :=l_ic_item_mst_rec.item_um2;
    ELSE
    -- If secondary Uom differs from item secondary UoM then convert
    -- transaction quantity
      IF (l_trans_rec.item_um2 <> l_ic_item_mst_rec.item_um2)
      THEN
        -- If quantity to convert is negative then make positive for conversion
        IF l_trans_rec.trans_qty < 0
        THEN
          l_neg_qty  := 1;
          l_trans_rec.trans_qty2  := 0 - l_trans_rec.trans_qty2;
        END IF;
        l_trans_rec.trans_qty2 :=GMICUOM.uom_conversion
                               ( pitem_id    =>l_item_id
                               , plot_id     =>l_lot_id
                               , pcur_qty    =>l_trans_rec.trans_qty2
                               , pcur_uom    =>l_trans_rec.item_um2
                               , pnew_uom    =>l_ic_item_mst_rec.item_um2
                               , patomic     =>0
                               );
        -- Negative quantity indicates UoM conversion failure
        IF (l_trans_rec.trans_qty2 < 0)
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_UOM_CONVERSION_ERROR');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
          FND_MESSAGE.SET_TOKEN('FROM_UOM',l_trans_rec.item_um2);
          FND_MESSAGE.SET_TOKEN('TO_UOM',l_ic_item_mst_rec.item_um2);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_trans_rec.item_um2  :=l_ic_item_mst_rec.item_um2;
          -- Reverse quantity sign if reversed above
          IF l_neg_qty = 1
          THEN
            l_neg_qty  := 0;
            l_trans_rec.trans_qty2  := 0 - l_trans_rec.trans_qty2;
          END IF;
        END IF;
      END IF;
      -- Check deviation
      -- H.Verdding B959444 Amended Deviation Logic
      IF (ABS(l_trans_rec.trans_qty2) >
	  ABS(l_qty2) * (1 + l_ic_item_mst_rec.deviation_hi)) OR
         (ABS(l_trans_rec.trans_qty2) <
	  ABS(l_qty2) * (1 - l_ic_item_mst_rec.deviation_lo))
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_QTY_TOLERANCE_ERROR');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
          FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
          FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  ELSE
--LE fix
  l_trans_rec.item_um2 := NULL;
  END IF;

  -- Check quantity is correctly signed
  IF (l_trans_type = 3 AND l_trans_rec.trans_qty <= 0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_QTY_NOT_NEG');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check location inventory for becoming negative
  IF (IC$ALLOWNEGINV = '0')
  THEN
    IF ((l_trans_type = 1 OR l_trans_type = 2) AND
       (l_ic_loct_inv_rec_from.loct_onhand +
        l_trans_rec.trans_qty) < 0) OR
       (l_trans_type = 3 AND (l_ic_loct_inv_rec_from.loct_onhand -
        l_trans_rec.trans_qty) < 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_NEG_QTY_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_trans_rec.from_whse_code);
      FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.from_location);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Check reason type allows quantity
  IF (l_trans_type < 4)
  THEN
    IF ((l_sy_reas_cds_rec.reason_type = 1) AND
        (l_trans_rec.trans_qty < 0))
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_DEC_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ((l_sy_reas_cds_rec.reason_type = 2) AND
	(l_trans_rec.trans_qty > 0))
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INC_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Check move quantity if item is lot-indivisble
  IF (l_ic_item_mst_rec.lot_indivisible = 1) AND
     (l_trans_type = 3) AND
     (l_ic_loct_inv_rec_from.loct_onhand <> l_trans_rec.trans_qty)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_INDIVISIBLE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
    FND_MESSAGE.SET_TOKEN('WHSE_CODE',l_trans_rec.from_whse_code);
    FND_MESSAGE.SET_TOKEN('LOCATION',l_trans_rec.from_location);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If moving inventory, check inventory at to warehouse /location
  IF (l_trans_type = 3)
  THEN
    GMI_GLOBAL_GRP.Get_loct_inv
                   (  p_item_id     =>l_item_id
                    , p_whse_code   =>l_trans_rec.to_whse_code
                    , p_lot_id      =>l_lot_id
                    , p_location    =>l_trans_rec.to_location
                    , x_ic_loct_inv =>l_ic_loct_inv_rec_to
		       );
  -- If location inventory not found then insert row into IC_LOCT_INV
    IF (l_ic_loct_inv_rec_to.item_id = 0)
    THEN
      l_trans_rec.lot_status := l_ic_loct_inv_rec_from.lot_status;
  -- If location inventory found then check lot_status if status
  -- controlled item
    ELSE
      IF (l_ic_item_mst_rec.status_ctl = 1)
      THEN
        IF (l_ic_loct_inv_rec_from.lot_status <>
            l_ic_loct_inv_rec_to.lot_status)
	THEN
          IF (l_ic_loct_inv_rec_to.loct_onhand = 0 AND
              IC$MOVEDIFFSTAT = '2')
          THEN
            l_trans_rec.lot_status := l_ic_loct_inv_rec_from.lot_status;
          ELSIF (IC$MOVEDIFFSTAT = '1')
	  THEN
            l_trans_rec.lot_status := l_ic_loct_inv_rec_to.lot_status;
          ELSE
            FND_MESSAGE.SET_NAME('GMI','IC_API_MOVE_STATUS_ERR');
            FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
            FND_MESSAGE.SET_TOKEN('LOT_NO',l_trans_rec.lot_no);
            FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_trans_rec.sublot_no);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          l_trans_rec.lot_status := l_ic_loct_inv_rec_from.lot_status;
        END IF;
      END IF;
    END IF;
  END IF;

  -- Validate lot status for change lot status transaction
  IF (l_trans_type = 4)
  THEN
    IF NOT GMI_VALID_GRP.Validate_lot_status (  l_trans_rec.lot_status
                                        , l_ic_item_mst_rec.status_ctl
				       )
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_STATUS');
      FND_MESSAGE.SET_TOKEN('LOT_STATUS',l_trans_rec.lot_status);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Check for unposted journals with different lot status
    IF Check_unposted_jnl_lot_status
       ( p_item_id          => l_item_id
       , p_lot_id           => l_lot_id
       , p_whse_code        => l_trans_rec.from_whse_code
       , p_location         => l_trans_rec.from_location
       , p_lot_status       => l_trans_rec.lot_status
       )
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNPOSTED_JNL_LOT_STATUS');
      FND_MESSAGE.SET_TOKEN('LOT_STATUS',l_trans_rec.lot_status);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

    -- Validate QC grade for change QC grade transaction
  IF (l_trans_type = 5) OR (l_trans_type = 1)
  THEN
    IF NOT GMI_VALID_GRP.Validate_qc_grade (  l_trans_rec.qc_grade
                                      , l_ic_item_mst_rec.grade_ctl
				     )
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_QC_GRADE');
      FND_MESSAGE.SET_TOKEN('QC_GRADE',l_trans_rec.qc_grade);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Check for unposted journals with different QC grade
    IF Check_unposted_jnl_qc_grade
       ( p_item_id          => l_item_id
       , p_lot_id           => l_lot_id
       , p_qc_grade         => l_trans_rec.qc_grade
       )
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNPOSTED_JNL_QC_GRADE');
      FND_MESSAGE.SET_TOKEN('QC_GRADE',l_trans_rec.qc_grade);
      FND_MESSAGE.SET_TOKEN('ITEM_NO',l_trans_rec.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- Validate Company Code
  IF NOT GMA_VALID_GRP.Validate_co_code(l_trans_rec.co_code)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_CO_CODE');
    FND_MESSAGE.SET_TOKEN('CO_CODE',l_trans_rec.co_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate Organisation Code belongs to Company Code
  IF NOT GMA_VALID_GRP.Validate_orgn_for_company (  l_trans_rec.orgn_code
                                                  , l_trans_rec.co_code
						 )
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ORGN_CODE');
    FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_trans_rec.orgn_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate Transaction Date For Transactions
  -- That are not type 5 - GRADE CHANGE
  IF l_trans_rec.trans_type <> 5 THEN
    l_return_val := GMICCAL.trans_date_validate (  l_trans_rec.trans_date
                                               , l_trans_rec.orgn_code
                                               , l_trans_rec.from_whse_code
                                                 );
  END IF;
  IF (l_return_val <> 0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_CANNOT_POST_CLOSED');
    FND_MESSAGE.SET_TOKEN('ITEM_NO' , l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_DATE', l_trans_rec.trans_date);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF TRUNC(l_trans_rec.trans_date, 'DD') >
	TRUNC(SYSDATE, 'DD')
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_CANNOT_POST_FUTURE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO' , l_trans_rec.item_no);
    FND_MESSAGE.SET_TOKEN('TRANS_DATE', l_trans_rec.trans_date);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If no errors then move local trans_rec to output parameter
  x_trans_rec    :=l_trans_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--          IF   FND_MSG_PUB.check_msg_level
--               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--          THEN

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'Validate_Inventory_posting'
                              );
--         END IF;
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );

END Validate_Inventory_Posting;

--+=========================================================================+
--| FUNCTION NAME                                                           |
--|    Insert_Ic_Jrnl_Mst                                                   |
--|                                                                         |
--| TYPE                                                                    |
--|    PRIVATE                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to insert inventory journal header                              |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to insert a row into IC_JRNL_MST              |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_ic_jrnl_mst_rec   Record datatype containing row to be inserted    |
--|                                                                         |
--| RETURNS                                                                 |
--|    Boolean                                                              |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
FUNCTION Insert_Ic_Jrnl_Mst
( p_ic_jrnl_mst_rec  IN ic_jrnl_mst%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO ic_jrnl_mst
  ( journal_id
  , journal_no
  , journal_comment
  , posting_id
  , print_cnt
  , posted_ind
  , orgn_code
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , delete_mark
  , text_code
  , in_use
  )
  VALUES
  ( p_ic_jrnl_mst_rec.journal_id
  , p_ic_jrnl_mst_rec.journal_no
  , p_ic_jrnl_mst_rec.journal_comment
  , p_ic_jrnl_mst_rec.posting_id
  , p_ic_jrnl_mst_rec.print_cnt
  , p_ic_jrnl_mst_rec.posted_ind
  , p_ic_jrnl_mst_rec.orgn_code
  , p_ic_jrnl_mst_rec.creation_date
  , p_ic_jrnl_mst_rec.last_update_date
  , p_ic_jrnl_mst_rec.created_by
  , p_ic_jrnl_mst_rec.last_updated_by
  , p_ic_jrnl_mst_rec.delete_mark
  , p_ic_jrnl_mst_rec.text_code
  , p_ic_jrnl_mst_rec.in_use
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--       IF  FND_MSG_PUB.check_msg_level
--           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--       THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Insert_IC_JRNL_MST'
                            );
--       END IF;
    RETURN FALSE;

END Insert_Ic_Jrnl_Mst;

--+=========================================================================+
--| FUNCTION NAME                                                           |
--|    Insert_Ic_Adjs_Jnl                                                   |
--|                                                                         |
--| TYPE                                                                    |
--|    PRIVATE                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to insert inventory journal detail                              |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure is used to insert a row into IC_ADJS_JNL              |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_ic_adjs_jnl_rec   Record datatype containing row to be inserted    |
--|                                                                         |
--| RETURNS                                                                 |
--|    Boolean                                                              |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
FUNCTION Insert_Ic_Adjs_Jnl
(  p_ic_adjs_jnl_rec  IN ic_adjs_jnl%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO ic_adjs_jnl
  ( trans_type
  , trans_flag
  , doc_id
  , doc_line
  , journal_id
  , completed_ind
  , whse_code
  , reason_code
  , doc_date
  , item_id
  , item_um
  , item_um2
  , lot_id
  , location
  , qty
  , qty2
  , qc_grade
  , lot_status
  , line_type
  , line_id
  , co_code
  , orgn_code
  , no_inv
  , no_trans
  , creation_date
  , created_by
  , last_update_date
  , trans_cnt
  , last_updated_by
  )
  VALUES
  ( p_ic_adjs_jnl_rec.trans_type
  , p_ic_adjs_jnl_rec.trans_flag
  , p_ic_adjs_jnl_rec.doc_id
  , p_ic_adjs_jnl_rec.doc_line
  , p_ic_adjs_jnl_rec.journal_id
  , p_ic_adjs_jnl_rec.completed_ind
  , p_ic_adjs_jnl_rec.whse_code
  , p_ic_adjs_jnl_rec.reason_code
  , p_ic_adjs_jnl_rec.doc_date
  , p_ic_adjs_jnl_rec.item_id
  , p_ic_adjs_jnl_rec.item_um
  , p_ic_adjs_jnl_rec.item_um2
  , p_ic_adjs_jnl_rec.lot_id
  , p_ic_adjs_jnl_rec.location
  , p_ic_adjs_jnl_rec.qty
  , p_ic_adjs_jnl_rec.qty2
  , p_ic_adjs_jnl_rec.qc_grade
  , p_ic_adjs_jnl_rec.lot_status
  , p_ic_adjs_jnl_rec.line_type
  , p_ic_adjs_jnl_rec.line_id
  , p_ic_adjs_jnl_rec.co_code
  , p_ic_adjs_jnl_rec.orgn_code
  , p_ic_adjs_jnl_rec.no_inv
  , p_ic_adjs_jnl_rec.no_trans
  , p_ic_adjs_jnl_rec.creation_date
  , p_ic_adjs_jnl_rec.created_by
  , p_ic_adjs_jnl_rec.last_update_date
  , p_ic_adjs_jnl_rec.trans_cnt
  , p_ic_adjs_jnl_rec.last_updated_by
  );

  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
--       IF  FND_MSG_PUB.check_msg_level
--           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--       THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'Insert_IC_ADJS_JNL'
                            );
--       END IF;
    RETURN FALSE;

END Insert_Ic_Adjs_Jnl;

--+=========================================================================+
--| FUNCTION NAME                                                           |
--|    Check_unposted_jnl_lot_status                                        |
--|                                                                         |
--| TYPE                                                                    |
--|    PRIVATE                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to ascertain if any unposted journals exist for item / lot /    |
--|    sublot / whse_code / location with a different lot status            |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure checks for unposted journals for item / lot / sublot  |
--|    / whse_code / location with differnet lot status                     |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id           Surrogate key of item                            |
--|    p_lot_id            Surrogate key of lot                             |
--|    p_whse_code         Warehouse code                                   |
--|    p_location          Location                                         |
--|    p_lot_status        Lot status to be checked for                     |
--|                                                                         |
--| RETURNS                                                                 |
--|    BOOLEAN                                                              |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
FUNCTION Check_unposted_jnl_lot_status
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_whse_code    IN ic_whse_mst.whse_code%TYPE
, p_location     IN ic_loct_mst.location%TYPE
, p_lot_status   IN ic_lots_sts.lot_status%TYPE
)
RETURN BOOLEAN
IS

CURSOR ic_journal IS
SELECT
  count(*)
FROM
  ic_adjs_jnl a, ic_jrnl_mst j
WHERE
  a.item_id    = p_item_id AND
  a.lot_id     = p_lot_id AND
  a.whse_code  = p_whse_code AND
  a.location   = p_location AND
  a.journal_id = j.journal_id AND
  j.posted_ind = 0 AND
  j.delete_mark = 0 AND
  p_lot_status <> a.lot_status;

l_rows_found    NUMBER;

BEGIN

  OPEN ic_journal;

  FETCH ic_journal INTO l_rows_found;

  IF (ic_journal%NOTFOUND)
  THEN
    l_rows_found  :=0;
  END IF;

  CLOSE ic_journal;

  IF l_rows_found > 0
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END Check_unposted_jnl_lot_status;

--+=========================================================================+
--| FUNCTION NAME                                                           |
--|    Check_unposted_jnl_qc_grade                                          |
--|                                                                         |
--| TYPE                                                                    |
--|    PRIVATE                                                              |
--|                                                                         |
--| USAGE                                                                   |
--|    Used to ascertain if any unposted journals exist for item / lot /    |
--|    sublot / whse_code / location with a different QC grade              |
--|                                                                         |
--| DESCRIPTION                                                             |
--|    This procedure checks for unposted journals for item / lot / sublot  |
--|    / whse_code / location with differnet QC grade                       |
--|                                                                         |
--| PARAMETERS                                                              |
--|    p_item_id           Surrogate key of item                            |
--|    p_lot_id            Surrogate key of lot                             |
--|    p_qc_grade          QC grade to be checked for                       |
--|                                                                         |
--| RETURNS                                                                 |
--|    BOOLEAN                                                              |
--|                                                                         |
--| HISTORY                                                                 |
--|    01-OCT-1998      M.Godfrey     Created                               |
--+=========================================================================+
FUNCTION Check_unposted_jnl_qc_grade
( p_item_id      IN ic_item_mst.item_id%TYPE
, p_lot_id       IN ic_lots_mst.lot_id%TYPE
, p_qc_grade     IN qc_grad_mst.qc_grade%TYPE
)
RETURN BOOLEAN
IS

CURSOR ic_journal IS
SELECT
  count(*)
FROM
  ic_adjs_jnl a, ic_jrnl_mst j
WHERE
  a.item_id    = p_item_id AND
  a.lot_id     = p_lot_id AND
  a.journal_id = j.journal_id AND
  j.posted_ind = 0 AND
  j.delete_mark = 0 AND
  p_qc_grade   <> a.qc_grade;

l_rows_found    NUMBER;

BEGIN

  OPEN ic_journal;

  FETCH ic_journal INTO l_rows_found;

  IF (ic_journal%NOTFOUND)
  THEN
    l_rows_found  :=0;
  END IF;

  CLOSE ic_journal;

  IF l_rows_found > 0
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END Check_unposted_jnl_qc_grade;

END GMI_QUANTITY_PVT;

/
