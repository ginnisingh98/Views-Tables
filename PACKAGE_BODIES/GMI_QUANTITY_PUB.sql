--------------------------------------------------------
--  DDL for Package Body GMI_QUANTITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_QUANTITY_PUB" AS
--$Header: GMIPQTYB.pls 115.9 2002/11/04 20:48:04 jdiiorio gmigapib.pls $
-- Body start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| FILE NAME                                                                |
--|    GMIPQTYB.pls                                                          |
--|                                                                          |
--| PACKAGE NAME                                                             |
--|    GMI_QUANTITY_PUB                                                      |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This package conatains all APIs related to the Inventory Quantity     |
--|    Engine                                                                |
--|                                                                          |
--| CONTENTS                                                                 |
--|    Inventory_Posting                                                     |
--|                                                                          |
--| HISTORY                                                                  |
--|    25-FEB-1999  M.Godfrey    Upgrade to R11                              |
--|    20/AUG/1999  H.Verdding Bug 951828 Change GMS package Calls to GMA    |
--|    02/JAN/2000  Liz Enstone Bug 1159923 Change message names from SY_ to |
--|                 IC_                                                      |
--|    28-OCT-2002  J.DiIorio    Bug#2643440 - 11.5.1J - added nocopy        |
--|                                                                          |
--+==========================================================================+
-- Body end of comments
-- Global variables
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_QUANTITY_PUB';
-- Api start of comments
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Inventory_Posting                                                     |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Updates an inventory quantity posting. This may be one of             |
--|     - Create Inventory                                                   |
--|     - Adjust Inventory                                                   |
--|     - Move Inventory                                                     |
--|     - Change Lot Status                                                  |
--|     - Change QC Grade                                                    |
--|                                                                          |
--| DESCRIPTION                                                              |
--|    This procedure validates and updates inventory posting                |
--|                                                                          |
--| PARAMETERS                                                               |
--|    p_api_version      IN  NUMBER        - Api Version                    |
--|    p_init_msg_list    IN  VARCHAR2      - Message Initialization Ind.    |
--|    p_commit           IN  VARCHAR2      - Commit Indicator               |
--|    p_validation_level IN  VARCHAR2      - Validation Level Indicator     |
--|    p_trans_rec        IN  trans_rec_typ - Item Master details            |
--|    x_return_status    OUT NOCOPY VARCHAR2 - Return Status                |
--|    x_msg_count        OUT NOCOPY NUMBER   - Number of messages           |
--|    x_msg_data         OUT NOCOPY VARCHAR2 - Messages in encoded format   |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
PROCEDURE Inventory_Posting
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_trans_rec        IN  trans_rec_typ
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_api_name        CONSTANT VARCHAR2 (30) := 'Inventory_Posting';
l_api_version     CONSTANT NUMBER        := 2.0;
l_item_id                  ic_item_mst.item_id%TYPE;
l_lot_id                   ic_lots_mst.lot_id%TYPE DEFAULT 0;
l_old_qc_grade             qc_grad_mst.qc_grade%TYPE;
l_old_lot_status           ic_lots_sts.lot_status%TYPE;
l_journal_id               ic_jrnl_mst.journal_id%TYPE;
l_doc_id                   ic_adjs_jnl.doc_id%TYPE;
l_line_id                  ic_tran_cmp.line_id%TYPE;
l_trans_rec                trans_rec_typ;
l_loop_ctr                 NUMBER(2);
l_num_rows                 NUMBER(2);
l_msg_count                NUMBER  :=0;
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1);
l_ic_jrnl_mst_rec          ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_rec          ic_adjs_jnl%ROWTYPE;
l_lot_rec                  GMI_LOTS_PUB.lot_rec_typ;
l_cmp_tran_rec             GMI_CMP_TRAN_PVT.cmp_tran_typ;
l_user_name                fnd_user.user_name%TYPE DEFAULT 'OPM';
l_user_id                  fnd_user.user_id%TYPE;

BEGIN

-- Standard Start OF API savepoint
  SAVEPOINT Inventory_Posting;
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

-- Populate WHO columns
  l_user_name :=p_trans_rec.user_name;
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

-- Move transaction record to local
  l_trans_rec    := p_trans_rec;

-- Ensure Upper-case columns are converted
  l_trans_rec.item_no        := UPPER(l_trans_rec.item_no);
  l_trans_rec.item_um        := l_trans_rec.item_um;
  l_trans_rec.item_um2       := l_trans_rec.item_um2;
  l_trans_rec.from_whse_code := UPPER(l_trans_rec.from_whse_code);
  l_trans_rec.to_whse_code   := UPPER(l_trans_rec.to_whse_code);
  l_trans_rec.lot_no         := UPPER(l_trans_rec.lot_no);
  l_trans_rec.sublot_no      := UPPER(l_trans_rec.sublot_no);
  l_trans_rec.from_location  := UPPER(l_trans_rec.from_location);
  l_trans_rec.to_location    := UPPER(l_trans_rec.to_location);
  l_trans_rec.qc_grade       := UPPER(l_trans_rec.qc_grade);
  l_trans_rec.lot_status     := UPPER(l_trans_rec.lot_status);
  l_trans_rec.co_code        := UPPER(l_trans_rec.co_code);
  l_trans_rec.orgn_code      := UPPER(l_trans_rec.orgn_code);
  l_trans_rec.reason_code    := UPPER(l_trans_rec.reason_code);

-- Perform validation of transaction

  GMI_QUANTITY_PVT.Validate_Inventory_posting
		   (  p_trans_rec      => l_trans_rec
                    , x_item_id        => l_item_id
                    , x_lot_id         => l_lot_id
                    , x_old_lot_status => l_old_lot_status
                    , x_old_qc_grade   => l_old_qc_grade
                    , x_return_status  => l_return_status
                    , x_msg_count      => l_msg_count
                    , x_msg_data       => l_msg_data
                    , x_trans_rec      => l_trans_rec
                   );

-- If no errors were found then proceed with posting the
-- transaction.

  IF (l_return_status = FND_API.G_RET_STS_ERROR)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF
    l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Get the surrogate key (journal_id) for the journal
  SELECT gem5_journal_id_s.nextval INTO l_journal_id FROM dual;
  IF (l_journal_id <=0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
    FND_MESSAGE.SET_TOKEN('SKEY','journal_id');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Set up PL/SQL record and insert item into ic_jrnl_mst
  l_ic_jrnl_mst_rec.journal_id         := l_journal_id;
  l_ic_jrnl_mst_rec.journal_no         := l_trans_rec.journal_no;
  l_ic_jrnl_mst_rec.journal_comment    := NULL;
  l_ic_jrnl_mst_rec.posting_id         := 0;
  l_ic_jrnl_mst_rec.print_cnt          := 0;
  l_ic_jrnl_mst_rec.posted_ind         := 1;
  l_ic_jrnl_mst_rec.orgn_code          := l_trans_rec.orgn_code;
  l_ic_jrnl_mst_rec.creation_date      := SYSDATE;
  l_ic_jrnl_mst_rec.last_update_date   := SYSDATE;
  l_ic_jrnl_mst_rec.created_by         := l_user_id;
  l_ic_jrnl_mst_rec.last_updated_by    := l_user_id;
  l_ic_jrnl_mst_rec.last_update_login  := TO_NUMBER(FND_PROFILE.Value(
                                        'LOGIN_ID'));
  l_ic_jrnl_mst_rec.delete_mark        := 0;
  l_ic_jrnl_mst_rec.text_code          := NULL;
  l_ic_jrnl_mst_rec.in_use             := 0;
  l_ic_jrnl_mst_rec.program_application_id :=NULL;
  l_ic_jrnl_mst_rec.program_id         := NULL;
  l_ic_jrnl_mst_rec.program_update_date  := SYSDATE;
  l_ic_jrnl_mst_rec.request_id         := NULL;
  l_ic_jrnl_mst_rec.last_update_login  := l_user_id;

  IF NOT GMI_QUANTITY_PVT.insert_ic_jrnl_mst(l_ic_jrnl_mst_rec)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Write transactions to ic_adjs_jnl
-- First get the surrogate key (doc_id) for the transaction.
  SELECT gem5_doc_id_s.nextval INTO l_doc_id FROM dual;
  IF (l_doc_id <=0)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
    FND_MESSAGE.SET_TOKEN('SKEY','doc_id');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- If create or Adjust transaction then insert 1 row to
-- ic_adjs_jnl. If Move, Change lot status or Change
-- QC Grade then need to insert 2 rows into ic_adjs_jnl.

  IF (l_trans_rec.trans_type <= 2)
  THEN
    l_num_rows := 1;
  ELSE
    l_num_rows := 2;
  END IF;

  FOR l_loop_ctr IN 1..l_num_rows LOOP

    -- Set up PL/SQL record and insert row into ic_adjs_jnl
    -- Get the surrogate key (line_id) for the line except for
    -- 'New' QC grade and lot status changes where the line_id
    -- is duplicated.

    IF (l_loop_ctr = 1 OR l_trans_rec.trans_type = 3)
    THEN
      SELECT gem5_line_id_s.nextval INTO l_line_id FROM dual;
      IF (l_line_id <=0)
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_SURROGATE');
        FND_MESSAGE.SET_TOKEN('SKEY','line_id');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF (l_trans_rec.trans_type = 1)
    THEN
      l_ic_adjs_jnl_rec.trans_type    :='CREI';
    ELSIF (l_trans_rec.trans_type = 2)
    THEN
      l_ic_adjs_jnl_rec.trans_type    :='ADJI';
    ELSIF (l_trans_rec.trans_type = 3)
    THEN
      l_ic_adjs_jnl_rec.trans_type    :='TRNI';
    ELSIF (l_trans_rec.trans_type = 4)
    THEN
      l_ic_adjs_jnl_rec.trans_type    :='STSI';
    ELSIF (l_trans_rec.trans_type = 5)
    THEN
      l_ic_adjs_jnl_rec.trans_type    :='GRDI';
    END IF;

    l_ic_adjs_jnl_rec.trans_flag    := 0;
    l_ic_adjs_jnl_rec.doc_id        := l_doc_id;
    l_ic_adjs_jnl_rec.doc_line      := l_loop_ctr;
    l_ic_adjs_jnl_rec.journal_id    := l_journal_id;
    l_ic_adjs_jnl_rec.completed_ind := 1;
    l_ic_adjs_jnl_rec.reason_code   := l_trans_rec.reason_code;
    l_ic_adjs_jnl_rec.doc_date      := l_trans_rec.trans_date;
    l_ic_adjs_jnl_rec.item_id       := l_item_id;
    l_ic_adjs_jnl_rec.item_um       := l_trans_rec.item_um;
    l_ic_adjs_jnl_rec.item_um2      := l_trans_rec.item_um2;
    l_ic_adjs_jnl_rec.lot_id        := l_lot_id;


    -- For Move , QC Grade and lot Status change set values according
    -- to 'Old' and 'New' transaction.
    IF (l_loop_ctr = 1)
    THEN
      l_ic_adjs_jnl_rec.whse_code  := l_trans_rec.from_whse_code;
      l_ic_adjs_jnl_rec.location   := l_trans_rec.from_location;
      l_ic_adjs_jnl_rec.qc_grade   := l_old_qc_grade;
      l_ic_adjs_jnl_rec.lot_status := l_old_lot_status;
      IF (l_trans_rec.trans_type < 3)
      THEN
        l_ic_adjs_jnl_rec.qty       := l_trans_rec.trans_qty;
        l_ic_adjs_jnl_rec.qty2      := l_trans_rec.trans_qty2;
        l_ic_adjs_jnl_rec.line_type := 0;
-- 02/06/99 Add this here, to get the correct lot status for
-- Create and Adjust
        l_ic_adjs_jnl_rec.lot_status  := l_trans_rec.lot_status;
      ELSE
        l_ic_adjs_jnl_rec.qty       := 0 - l_trans_rec.trans_qty;
        l_ic_adjs_jnl_rec.qty2      := 0 - l_trans_rec.trans_qty2;
        l_ic_adjs_jnl_rec.line_type := -1;
      END IF;
    ELSE
      l_ic_adjs_jnl_rec.whse_code   := l_trans_rec.to_whse_code;
      l_ic_adjs_jnl_rec.location    := l_trans_rec.to_location;
      l_ic_adjs_jnl_rec.qty         := l_trans_rec.trans_qty;
      l_ic_adjs_jnl_rec.qty2        := l_trans_rec.trans_qty2;
      l_ic_adjs_jnl_rec.qc_grade    := l_trans_rec.qc_grade;
      l_ic_adjs_jnl_rec.lot_status  := l_trans_rec.lot_status;
      l_ic_adjs_jnl_rec.line_type   := 1;
    END IF;

    l_ic_adjs_jnl_rec.line_id       := l_line_id;
    l_ic_adjs_jnl_rec.co_code       := l_trans_rec.co_code;
    l_ic_adjs_jnl_rec.orgn_code     := l_trans_rec.orgn_code;
    l_ic_adjs_jnl_rec.no_inv        := 0;
    l_ic_adjs_jnl_rec.no_trans      := 0;
    l_ic_adjs_jnl_rec.creation_date := SYSDATE;
    l_ic_adjs_jnl_rec.created_by    := l_user_id;
    l_ic_adjs_jnl_rec.last_update_date := SYSDATE;
    l_ic_adjs_jnl_rec.trans_cnt     := 0;
    l_ic_adjs_jnl_rec.last_updated_by  := l_user_id;
    l_ic_adjs_jnl_rec.program_application_id :=NULL;
    l_ic_adjs_jnl_rec.program_id    := NULL;
    l_ic_adjs_jnl_rec.program_update_date := SYSDATE;
    l_ic_adjs_jnl_rec.request_id    := NULL;
    l_ic_adjs_jnl_rec.last_update_login :=l_user_id;


    IF NOT GMI_QUANTITY_PVT.insert_ic_adjs_jnl(l_ic_adjs_jnl_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Now polpulate the completed transaction PL/SQL record
    -- and call the completed transaction processor.
    --
    l_cmp_tran_rec.item_id       := l_item_id;
    l_cmp_tran_rec.line_id       := l_line_id;
    l_cmp_tran_rec.trans_id      := 0;
    l_cmp_tran_rec.co_code       := l_trans_rec.co_code;
    l_cmp_tran_rec.orgn_code     := l_trans_rec.orgn_code;
    l_cmp_tran_rec.whse_code     := l_ic_adjs_jnl_rec.whse_code;
    l_cmp_tran_rec.lot_id        := l_lot_id;
    l_cmp_tran_rec.location      := l_ic_adjs_jnl_rec.location;
    l_cmp_tran_rec.doc_id        := l_doc_id;
    l_cmp_tran_rec.doc_type      := l_ic_adjs_jnl_rec.trans_type;
    l_cmp_tran_rec.doc_line      := l_ic_adjs_jnl_rec.doc_line;
    l_cmp_tran_rec.line_type     := l_ic_adjs_jnl_rec.line_type;
    l_cmp_tran_rec.reason_code   := l_ic_adjs_jnl_rec.reason_code;
    l_cmp_tran_rec.creation_date := SYSDATE;
    l_cmp_tran_rec.trans_date    := l_ic_adjs_jnl_rec.doc_date;
    l_cmp_tran_rec.trans_qty     := l_ic_adjs_jnl_rec.qty;
    l_cmp_tran_rec.trans_qty2    := l_ic_adjs_jnl_rec.qty2;
    l_cmp_tran_rec.qc_grade      := l_ic_adjs_jnl_rec.qc_grade;
    l_cmp_tran_rec.lot_status    := l_ic_adjs_jnl_rec.lot_status;
    l_cmp_tran_rec.trans_stat    := NULL;
    l_cmp_tran_rec.trans_um      := l_trans_rec.item_um;
    l_cmp_tran_rec.trans_um2     := l_trans_rec.item_um2;
    l_cmp_tran_rec.user_id       := l_user_id;
    l_cmp_tran_rec.gl_posted_ind := 0;
    l_cmp_tran_rec.event_id      := 0;
    l_cmp_tran_rec.text_code     := NULL;

    IF NOT GMI_CMP_TRAN_PVT.Update_quantity_transaction(l_cmp_tran_rec)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

-- END of API Body

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;
  -- Success message
  IF (l_trans_rec.trans_type = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_CRE_TRAN_POSTED');
  ELSIF (l_trans_rec.trans_type = 2)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_ADJ_TRAN_POSTED');
  ELSIF (l_trans_rec.trans_type = 3)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_TRN_TRAN_POSTED');
  ELSIF (l_trans_rec.trans_type = 4)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_STS_TRAN_POSTED');
  ELSIF (l_trans_rec.trans_type = 5)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_GRD_TRAN_POSTED');
  END IF;

  FND_MESSAGE.SET_TOKEN('ITEM_NO',p_trans_rec.item_no);
  FND_MESSAGE.SET_TOKEN('LOT_NO',p_trans_rec.lot_no);
  FND_MESSAGE.SET_TOKEN('SUBLOT_NO',p_trans_rec.sublot_no);
  FND_MSG_PUB.Add;
  -- Standard Call to get message count and if count is 1,
  -- get message info.

  FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
 			     , p_count => x_msg_count
                             , p_data  => x_msg_data
                            );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Inventory_Posting;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Inventory_Posting;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      ROLLBACK TO Inventory_Posting;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--IF  FND_MSG_PUB.check_msg_level
--    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--THEN

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
--      END IF;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END Inventory_Posting;

END GMI_QUANTITY_PUB;

/
