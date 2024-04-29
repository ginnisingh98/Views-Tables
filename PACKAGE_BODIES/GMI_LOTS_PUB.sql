--------------------------------------------------------
--  DDL for Package Body GMI_LOTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOTS_PUB" AS
--$Header: GMIPLOTB.pls 115.11 2002/10/30 20:25:20 jdiiorio gmigapib.pls $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIPLOTB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_LOTS_PUB                                                          |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package contains all APIs related to the Business Object Lot/    |
--|    Sub-Lot                                                               |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Create_Lot                                                            |
--|    Validate_Lot                                                          |
--|                                                                          |
--| HISTORY                                                                  |
--|    17-FEB-1999  M.Godfrey     Upgrade to R11                             |
--|    20/AUG/1999  H.Verdding Bug 951828 Change GMS package Calls to GMA    |
--|    02/JAN/2000  Liz Enstone Bug1159923 Change message name from SY_ to IC|
--|    21/DEC/2001  K. RajaSekhar Reddy BUG#2158123                          |
--|                 Modified the code to set the dates correctly in          |
--|                 GMI_LOTS_PUB.Create procedure                            |
--|    29-OCT-2002  J.DiIorio     Bug#2643440 11.5.1J - added nocopy.        |
--|                               Removed fnd_miss from date comparisons.    |
--+==========================================================================+
-- Body end of comments

-- Global variables
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMI_LOTS_PUB';
IC$DEFAULT_LOT          VARCHAR2(255);

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Lot                                                            |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create a new Inventory Lot                                            |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This procedure creates a new inventory Lot                            |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_api_version      IN  NUMBER       - Api Version                     |
--|    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
--|    p_commit           IN  VARCHAR2     - Commit Indicator                |
--|    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
--|    p_lot_rec          IN  lot_rec_typ  - Lot Master details              |
--|    x_return_status    OUT VARCHAR2     - Return Status                   |
--|    x_msg_count        OUT NUMBER       - Number of messages              |
--|    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|               H.Verdding Changed User Name Validation To Use p_lot_rec   |
--|                          Instead Of l_lot_rec                            |
--| 17-AUG-99     H.Verdding B959447                                         |
--|                          Part 1 - Moved Uppercase column Conversion      |
--|                          To start of file                                |
--|                          Part 3/4 - Changed Get Shipvend_id logic        |
--| 21-DEC-01     K. RajaSekhar Reddy BUG#2158123                            |
--|                          Modified the code to create the Retest Date,    |
--|                          Expire Date and Expaction Dates correctly.      |
--+==========================================================================+
PROCEDURE Create_Lot
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  lot_rec_typ
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_name        CONSTANT VARCHAR2 (30) := 'Create_Lot';
l_api_version     CONSTANT NUMBER        := 2.0;
l_lot_id                   ic_lots_mst.lot_id%TYPE;
l_shipvend_id              ic_lots_mst.shipvend_id%TYPE;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1);
l_user_name                fnd_user.user_name%TYPE;
l_user_id                  fnd_user.user_id%TYPE;
l_ic_item_mst_rec          ic_item_mst%ROWTYPE;
l_ic_lots_mst_rec          ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_rec          ic_lots_cpg%ROWTYPE;
l_lot_rec                  lot_rec_typ;
l_po_vend_mst_rec          po_vend_mst%ROWTYPE;
l_ic_item_cpg_rec          ic_item_cpg%ROWTYPE;

BEGIN

-- Standard Start OF API savepoint
  SAVEPOINT Create_Lot;
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

-- Ensure Upper-case columns are converted
-- H.Verdding B959447 - Part1
  l_lot_rec                := p_lot_rec;
  l_lot_rec.item_no        := UPPER(l_lot_rec.item_no);
  l_lot_rec.lot_no         := UPPER(l_lot_rec.lot_no);
  l_lot_rec.sublot_no      := UPPER(l_lot_rec.sublot_no);
  l_lot_rec.qc_grade       := UPPER(l_lot_rec.qc_grade);
  l_lot_rec.expaction_code := UPPER(l_lot_rec.expaction_code);
  l_lot_rec.user_name      := UPPER(l_lot_rec.user_name);

-- Populate WHO columns
  GMA_GLOBAL_GRP.Get_who( p_user_name  => p_lot_rec.user_name
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


-- Get item details

  GMI_GLOBAL_GRP.Get_Item (  p_item_no     => l_lot_rec.item_no
                           , x_ic_item_mst => l_ic_item_mst_rec
                           , x_ic_item_cpg => l_ic_item_cpg_rec
                          );

  IF (l_ic_item_mst_rec.item_id < 0)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_ic_item_mst_rec.item_id = 0) OR
	(l_ic_item_mst_rec.delete_mark = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_lot_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.noninv_ind = 1) AND
	(p_lot_rec.lot_no <> 'NEWITEM')
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_NONINV_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_lot_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_ic_item_mst_rec.inactive_ind = 1) AND
	(p_lot_rec.lot_no <> 'NEWITEM')
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_lot_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Set up defaults for hold and maturity days
  IF l_ic_item_cpg_rec.ic_hold_days IS NULL
  THEN
    l_ic_item_cpg_rec.ic_hold_days  :=0;
  END IF;

  IF l_ic_item_cpg_rec.ic_matr_days IS NULL
  THEN
    l_ic_item_cpg_rec.ic_matr_days  :=0;
  END IF;


-- If creating default lot (i.e. being call from create_item API) then
-- bypass defaults and validation.

  IF (p_lot_rec.lot_no = 'NEWITEM')
  THEN
    l_lot_rec.lot_no := IC$DEFAULT_LOT;
    l_lot_id  := 0;
  ELSE
    -- Set up default values for required where fields have been left blank
    -- QC Grade
    IF (l_lot_rec.qc_grade = ' ' OR
	l_lot_rec.qc_grade IS NULL) AND
       (l_ic_item_mst_rec.grade_ctl = 1)
    THEN
      l_lot_rec.qc_grade :=l_ic_item_mst_rec.qc_grade;
    END IF;

    --Expaction Code
    IF (l_lot_rec.expaction_code = ' ' OR l_lot_rec.expaction_code IS NULL)
    THEN
      l_lot_rec.expaction_code := l_ic_item_mst_rec.expaction_code;
    END IF;

    -- Expire Date
    IF (l_lot_rec.expire_date IS NULL)
    THEN
      --BEGIN BUG#2158123 12/21/2001 RajaSekhar
      IF (l_ic_item_mst_rec.grade_ctl = 1)
      THEN
        l_lot_rec.expire_date := l_lot_rec.lot_created +
                                  NVL(l_ic_item_mst_rec.shelf_life,0);
      --END BUG#2158123
      ELSE
        l_lot_rec.expire_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
      END IF;
    END IF;

    --Expaction Date
    IF (l_lot_rec.expaction_date IS NULL) OR (l_lot_rec.expaction_code IS NULL)
    THEN
      --BEGIN BUG#2158123 12/21/2001 RajaSekhar
      IF (l_ic_item_mst_rec.grade_ctl = 1)
      THEN
        l_lot_rec.expaction_date := l_lot_rec.expire_date +
                                    NVL(l_ic_item_mst_rec.expaction_interval,0);
      --END BUG#2158123
      ELSE
        l_lot_rec.expaction_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
      END IF;
    END IF;

    --Retest Date
    IF (l_lot_rec.retest_date IS NULL)
    THEN
      --BEGIN BUG#2158123 12/21/2001 RajaSekhar
      IF (l_ic_item_mst_rec.grade_ctl = 1)
      THEN
        l_lot_rec.retest_date := l_lot_rec.lot_created +
                                 NVL(l_ic_item_mst_rec.retest_interval,0);
      --END BUG#2158123
      ELSE
        l_lot_rec.retest_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
      END IF;
    END IF;

    -- Ic_Matr_Date
    IF (l_lot_rec.ic_matr_date IS NULL)
    THEN
      l_lot_rec.ic_matr_date := l_lot_rec.lot_created +
                                l_ic_item_cpg_rec.ic_matr_days;
    END IF;

    -- Ic_Hold_Date
    IF (l_lot_rec.ic_hold_date IS NULL)
    THEN
      l_lot_rec.ic_hold_date := l_lot_rec.lot_created +
                                l_ic_item_cpg_rec.ic_hold_days;
    END IF;

    -- Perform Validation

    GMI_LOTS_PUB.Validate_Lot (  p_api_version   => 2.0
                            , p_init_msg_list => FND_API.G_FALSE
                            , p_validation_level =>FND_API.G_VALID_LEVEL_FULL
                            , p_lot_rec       => l_lot_rec
                            , p_item_rec      => l_ic_item_mst_rec
                            , x_return_status => l_return_status
                            , x_msg_count     => l_msg_count
                            , x_msg_data      => l_msg_data
                            );

    -- If errors were found then raise exception
    x_return_status  := l_return_status;
    IF (l_return_status = FND_API.G_RET_STS_ERROR)
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If no errors were found then proceed with the lot create

    -- First get the surrogate key (lot_id) for the lot
    SELECT gem5_lot_id_s.nextval INTO l_lot_id FROM dual;
    IF (l_lot_id <= 0)
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
      FND_MESSAGE.SET_TOKEN('SKEY','lot_id');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- End of default lot condition
  END IF;

  -- Get shipvend_id
  -- H.Verdding B959447- Changed Logic for getting shipvend_id
  IF (p_lot_rec.shipvendor_no <> ' ' OR p_lot_rec.shipvendor_no IS NOT NULL)
   THEN
     l_shipvend_id :=GMI_VALID_GRP.Validate_shipvendor_no(p_lot_rec.shipvendor_no);
   ELSE
     l_shipvend_id :=NULL;
  END IF;

  -- Set up PL/SQL record and insert lot into ic_lots_mst

  l_ic_lots_mst_rec.item_id          := l_ic_item_mst_rec.item_id;
  l_ic_lots_mst_rec.lot_no           := l_lot_rec.lot_no;
  l_ic_lots_mst_rec.sublot_no        := l_lot_rec.sublot_no;
  l_ic_lots_mst_rec.lot_id           := l_lot_id;
  l_ic_lots_mst_rec.lot_desc         := l_lot_rec.lot_desc;
  l_ic_lots_mst_rec.qc_grade         := l_lot_rec.qc_grade;
  l_ic_lots_mst_rec.expaction_code   := l_lot_rec.expaction_code;
  l_ic_lots_mst_rec.expaction_date   := l_lot_rec.expaction_date;
  l_ic_lots_mst_rec.lot_created      := l_lot_rec.lot_created;
  l_ic_lots_mst_rec.expire_date      := l_lot_rec.expire_date;
  l_ic_lots_mst_rec.retest_date      := l_lot_rec.retest_date;
  l_ic_lots_mst_rec.strength         := l_lot_rec.strength;
  l_ic_lots_mst_rec.inactive_ind     := l_lot_rec.inactive_ind;
  l_ic_lots_mst_rec.origination_type := l_lot_rec.origination_type;
  l_ic_lots_mst_rec.vendor_lot_no    := l_lot_rec.vendor_lot_no;
  l_ic_lots_mst_rec.shipvend_id      := l_shipvend_id;
  l_ic_lots_mst_rec.creation_date    := SYSDATE;
  l_ic_lots_mst_rec.last_update_date := SYSDATE;
  l_ic_lots_mst_rec.created_by       := l_user_id;
  l_ic_lots_mst_rec.last_updated_by  := l_user_id;
  l_ic_lots_mst_rec.last_update_login  :=TO_NUMBER(FND_PROFILE.Value(
				       'LOGIN_ID'));
  l_ic_lots_mst_rec.trans_cnt        := 1;
  l_ic_lots_mst_rec.delete_mark      := 0;
  l_ic_lots_mst_rec.text_code        := NULL;
  l_ic_lots_mst_rec.attribute1       := UPPER(l_lot_rec.attribute1);
  l_ic_lots_mst_rec.attribute2       := UPPER(l_lot_rec.attribute2);
  l_ic_lots_mst_rec.attribute3       := UPPER(l_lot_rec.attribute3);
  l_ic_lots_mst_rec.attribute4       := UPPER(l_lot_rec.attribute4);
  l_ic_lots_mst_rec.attribute5       := UPPER(l_lot_rec.attribute5);
  l_ic_lots_mst_rec.attribute6       := UPPER(l_lot_rec.attribute6);
  l_ic_lots_mst_rec.attribute7       := UPPER(l_lot_rec.attribute7);
  l_ic_lots_mst_rec.attribute8       := UPPER(l_lot_rec.attribute8);
  l_ic_lots_mst_rec.attribute9       := UPPER(l_lot_rec.attribute9);
  l_ic_lots_mst_rec.attribute10      := UPPER(l_lot_rec.attribute10);
  l_ic_lots_mst_rec.attribute11      := UPPER(l_lot_rec.attribute11);
  l_ic_lots_mst_rec.attribute12      := UPPER(l_lot_rec.attribute12);
  l_ic_lots_mst_rec.attribute13      := UPPER(l_lot_rec.attribute13);
  l_ic_lots_mst_rec.attribute14      := UPPER(l_lot_rec.attribute14);
  l_ic_lots_mst_rec.attribute15      := UPPER(l_lot_rec.attribute15);
  l_ic_lots_mst_rec.attribute16      := UPPER(l_lot_rec.attribute16);
  l_ic_lots_mst_rec.attribute17      := UPPER(l_lot_rec.attribute17);
  l_ic_lots_mst_rec.attribute18      := UPPER(l_lot_rec.attribute18);
  l_ic_lots_mst_rec.attribute19      := UPPER(l_lot_rec.attribute19);
  l_ic_lots_mst_rec.attribute20      := UPPER(l_lot_rec.attribute20);
  l_ic_lots_mst_rec.attribute21      := UPPER(l_lot_rec.attribute21);
  l_ic_lots_mst_rec.attribute22      := UPPER(l_lot_rec.attribute22);
  l_ic_lots_mst_rec.attribute23      := UPPER(l_lot_rec.attribute23);
  l_ic_lots_mst_rec.attribute24      := UPPER(l_lot_rec.attribute24);
  l_ic_lots_mst_rec.attribute25      := UPPER(l_lot_rec.attribute25);
  l_ic_lots_mst_rec.attribute26      := UPPER(l_lot_rec.attribute26);
  l_ic_lots_mst_rec.attribute27      := UPPER(l_lot_rec.attribute27);
  l_ic_lots_mst_rec.attribute28      := UPPER(l_lot_rec.attribute28);
  l_ic_lots_mst_rec.attribute29      := UPPER(l_lot_rec.attribute29);
  l_ic_lots_mst_rec.attribute30      := UPPER(l_lot_rec.attribute30);
  l_ic_lots_mst_rec.attribute_category  := UPPER(l_lot_rec.attribute_category);


  IF NOT GMI_LOTS_PVT.insert_ic_lots_mst(l_ic_lots_mst_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Set up PL/SQL record and insert lot into ic_lots_cpg

  l_ic_lots_cpg_rec.item_id       := l_ic_item_mst_rec.item_id;
  l_ic_lots_cpg_rec.lot_id        := l_lot_id;
  l_ic_lots_cpg_rec.ic_matr_date  := l_lot_rec.ic_matr_date;
  l_ic_lots_cpg_rec.ic_hold_date  := l_lot_rec.ic_hold_date;
  l_ic_lots_cpg_rec.created_by    := l_user_id;
  l_ic_lots_cpg_rec.creation_date := SYSDATE;
  l_ic_lots_cpg_rec.last_update_date := SYSDATE;
  l_ic_lots_cpg_rec.last_updated_by  := l_user_id;
  l_ic_lots_cpg_rec.last_update_login  :=TO_NUMBER(FND_PROFILE.Value(
				       'LOGIN_ID'));

  IF NOT GMI_LOTS_PVT.insert_ic_lots_cpg(l_ic_lots_cpg_rec)
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
  FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_CREATED');
  FND_MESSAGE.SET_TOKEN('ITEM_NO', l_lot_rec.item_no);
  FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_rec.lot_no);
  FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_lot_rec.sublot_no);
  FND_MSG_PUB.Add;
  -- Standard Call to get message count and if count is 1,
  -- get message info.

  FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                             , p_data  => x_msg_data
                            );

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Lot;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                               , p_data  => x_msg_data
                              );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Lot;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                               , p_data  => x_msg_data
                              );

   WHEN OTHERS THEN
    ROLLBACK TO Create_Lot;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--       IF   FND_MSG_PUB.check_msg_level
--           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--       THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , l_api_name
                            );
--       END IF;
    FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count
                               , p_data  => x_msg_data
                              );
END Create_Lot;

-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Validate_Lot                                                          |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Performs all validation functions associated with creation of a new   |
--|    inventory lot                                                         |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This procedure validates all data associated with creation of a new   |
--|    inventory lot                                                         |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_api_version      IN  NUMBER       - Api Version                     |
--|    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
--|    p_commit           IN  VARCHAR2     - Commit Indicator                |
--|    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
--|    p_lot_rec          IN  lot_rec_typ  - Lot Master details              |
--|    p_item_rec         IN  item_rec_typ - Item Master details             |
--|    x_return_status    OUT VARCHAR2     - Return Status                   |
--|    x_msg_count        OUT NUMBER       - Number of messages              |
--|    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
PROCEDURE Validate_Lot
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  lot_rec_typ
, p_item_rec         IN  ic_item_mst%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_name       CONSTANT VARCHAR2 (30) := 'Validate_Lot';
l_api_version    CONSTANT NUMBER        := 2.0;
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_return_status           VARCHAR2(1);
l_item_no                 ic_item_mst.item_no%TYPE;
l_lot_no                  ic_lots_mst.lot_no%TYPE;
l_sublot_no               ic_lots_mst.sublot_no%TYPE;
l_qc_grade                ic_lots_mst.qc_grade%TYPE;
l_expaction_code          ic_lots_mst.expaction_code%TYPE;
l_user_name               fnd_user.user_name%TYPE;

BEGIN

-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_CALL (  l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                     )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_int_msg_list is set TRUE.
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;
-- Initialize API return status to sucess
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--

-- Ensure Upper-case columns are converted

  l_item_no        := UPPER(p_lot_rec.item_no);
  l_lot_no         := UPPER(p_lot_rec.lot_no);
  l_sublot_no      := UPPER(p_lot_rec.sublot_no);
  l_qc_grade       := UPPER(p_lot_rec.qc_grade);
  l_expaction_code := UPPER(p_lot_rec.expaction_code);
  l_user_name      := UPPER(p_lot_rec.user_name);

--Check to see if item is lot Controlled
  IF (p_item_rec.lot_ctl <> 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_NOT_LOT_CTL');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Check that lot number has been supplied and is not same value
-- as IC$DEFAULT_LOT
  IF (l_lot_no = ' ' OR l_lot_no = IC$DEFAULT_LOT OR l_lot_no IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Check to see if item is Sublot Controlled

  IF (p_item_rec.sublot_ctl <> 1   AND
      l_sublot_no           <> ' ' AND
      l_sublot_no           IS NOT NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_SUBLOT_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Check that lot number and sublot number do not exist for item number
  IF GMI_VALID_GRP.Validate_lot_no (  l_item_no
  	                            , l_lot_no
                                    , l_sublot_no
                                 )
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_ALREADY_EXISTS');
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Check to see if item is Grade Controlled
  IF (p_item_rec.grade_ctl <> 1   AND
      p_lot_rec.qc_grade   <> ' ' AND
      p_lot_rec.qc_grade   IS NOT NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_QC_GRADE_NOT_REQD');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate QC Grade
  IF NOT GMI_VALID_GRP.Validate_qc_grade (  p_lot_rec.qc_grade
                                          , p_item_rec.grade_ctl
                                         )
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_QC_GRADE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Expaction Code
  IF (NOT GMI_VALID_GRP.Validate_expaction_code(  p_lot_rec.expaction_code
                                                , p_item_rec.grade_ctl
                                               ) AND
     p_lot_rec.expaction_code <> ' ')
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INV_LOT_EXPACTION_CODE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Expire Date
  IF (TRUNC(p_lot_rec.expire_date, 'DD') < TRUNC(p_lot_rec.lot_created, 'DD'))
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_EXPIRE_DATE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Retest Date
  IF (TRUNC(p_lot_rec.retest_date, 'DD') < TRUNC(p_lot_rec.lot_created, 'DD'))
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_RETEST_DATE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Expaction Date
  IF (TRUNC(p_lot_rec.expaction_date,'DD') < TRUNC(p_lot_rec.lot_created,'DD'))
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_EXPACTION_DATE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Strength
  IF NOT GMI_VALID_GRP.Validate_strength(p_lot_rec.strength)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_STRENGTH');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Inactive Indicator
  IF NOT GMI_VALID_GRP.Validate_inactive_ind(p_lot_rec.inactive_ind)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_INACTIVE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Origination Type
--HAM IF NOT GMI_VALID_GRP.Validate_origination_type(p_lot_rec.origination_type)
IF GMI_VALID_GRP.Validate_origination_type(p_lot_rec.origination_type)
  THEN
    NULL;
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_ORIG_TYPE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Shipvendor Number
  IF (p_lot_rec.shipvendor_no = ' ' OR p_lot_rec.shipvendor_no IS NULL)
  THEN
    NULL;
  ELSIF
    GMI_VALID_GRP.Validate_shipvendor_no(p_lot_rec.shipvendor_no) = 0 THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INV_LOT_SHIPVENDOR_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
    FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
    FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Maturity date (CPG)
  IF (p_lot_rec.ic_matr_date < p_lot_rec.lot_created)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_MATR_DATE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

--Validate Hold release date (CPG)
  IF (p_lot_rec.ic_hold_date < p_lot_rec.lot_created)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_HOLD_DATE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET
      (  p_count    =>  x_msg_count,
            p_data    =>      x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET
      (  p_count    =>  x_msg_count,
            p_data    =>      x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Add_Exc_Msg
          ( G_PKG_NAME ,
            l_api_name
          );
      FND_MSG_PUB.Count_AND_GET
      (  p_count    =>  x_msg_count,
            p_data    =>      x_msg_data
      );
END Validate_Lot;

END GMI_LOTS_PUB;

/
