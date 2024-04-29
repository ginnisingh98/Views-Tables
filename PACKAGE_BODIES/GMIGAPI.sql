--------------------------------------------------------
--  DDL for Package Body GMIGAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIGAPI" AS
/* $Header: GMIGAPIB.pls 115.23 2004/03/15 20:07:41 jsrivast ship $ */

/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIGAPI';

/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Item                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create a new Item.                                                    |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This procedure creates a new item using the raw data supplied         |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
 |    p_commit           IN  VARCHAR2     - Commit Indicator                |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_item_rec         IN  item_rec_typ - Item details                    |
 |    x_ic_item_mst_row  OUT ic_item_mst%ROWTYPE - The ic_item_mst row      |
 |    x_ic_item_cpg_row  OUT ic_item_cpg%ROWTYPE - The ic_item_cpg row      |
 |    x_return_status    OUT VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NUMBER       - Number of messages              |
 |    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 | 13-May-00     P.J.Schofield Major restructuring for performance reasons  |
 |               B1294915.                                                  |
 | 18-Oct-02     A. Cataldo - Bug 2513463 - Need to handle problems with    |
 |               ic_item_mst_insert and Create_Lot if they occur            |
 +==========================================================================+
*/

PROCEDURE Create_Item
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_item_rec         IN  GMIGAPI.item_rec_typ
, x_ic_item_mst_row  OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row  OUT NOCOPY ic_item_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name         VARCHAR2(30) := 'G_Create_Item';
  l_lot_rec          GMIGAPI.lot_rec_typ;
  l_return_status    NUMBER;
  l_ic_lots_mst_row  ic_lots_mst%ROWTYPE;
  l_ic_lots_cpg_row  ic_lots_cpg%ROWTYPE;
BEGIN

  /*  Standard call to check for call compatibility. */

  IF NOT FND_API.Compatible_API_CALL
    (GMIGUTL.api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Initialize message list if p_int_msg_list is set TRUE.  */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  GMIVITM.Validate_Item
                        (  p_api_version      => p_api_version
                         , p_validation_level => p_validation_level
                         , p_item_rec         => p_item_rec
       			 , x_ic_item_mst_row  => x_ic_item_mst_row
                         , x_ic_item_cpg_row  => x_ic_item_cpg_row
                         , x_return_status    => x_return_status
                         , x_msg_count        => x_msg_count
                         , x_msg_data         => x_msg_data
                        );

  SAVEPOINT Create_Item;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    /*  If no errors were found then proceed with the database inserts */
    IF GMIVDBL.ic_item_mst_insert(x_ic_item_mst_row, x_ic_item_mst_row)
    THEN
	-- TKW 9/11/2003 B2378017
 	-- Moved call to gmi_item_categories from ic_item_mst_insert to here.
	-- It is now called with new signature.
	GMIVDBL.gmi_item_categories(p_item_rec, x_ic_item_mst_row);

      -- Jatinder - B3158806 - removed the check for the CPG install and
      -- added check for lot_ctl instead
      IF x_ic_item_mst_row.lot_ctl = 1
      THEN
        /*  ic_item_mst created OK. Copy the allocated item_id. */
        x_ic_item_cpg_row.item_id := x_ic_item_mst_row.item_id;
        IF GMIVDBL.ic_item_cpg_insert(x_ic_item_cpg_row, x_ic_item_cpg_row)
        THEN
          NULL;
        ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      /*  Item Master row(s) created ok, so now we must create */
      /*  the Lot Master row(s). Set up the input lot record */
      /*  and call the gmigapi.create_lot procedure with the validation level */
      /*  set to NONE. This will bypass the validation in the procedure, but */
      /*  still set up the row(s) ready for insertion into the database. */

      l_lot_rec.lot_no := GMIGUTL.IC$DEFAULT_LOT;

      Create_Lot (  p_api_version     => p_api_version
                    , p_init_msg_list   => FND_API.G_FALSE
                    , p_commit          => FND_API.G_FALSE
                    , p_validation_level=> FND_API.G_VALID_LEVEL_NONE
                    , p_lot_rec         => l_lot_rec
                    , p_ic_item_mst_row => x_ic_item_mst_row
                    , p_ic_item_cpg_row => x_ic_item_cpg_row
                    , x_ic_lots_mst_row => l_ic_lots_mst_row
                    , x_ic_lots_cpg_row => l_ic_lots_cpg_row
                    , x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                   );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_CREATED');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_lot_rec.item_no);
        FND_MSG_PUB.Add;

        IF FND_API.to_boolean(p_commit)
        THEN
          COMMIT;
        END IF;
      ELSE /* Bug 2513463 - Handle possbile errors with Create_Lot */
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
    ELSE  /* Bug 2513463 - Handle possbile errors with ic_item_insert */
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
        (p_count => x_msg_count, p_data => x_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    ROLLBACK TO Create_Item;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK TO Create_Item;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data => x_msg_data);
END Create_Item;


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Lot                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Group                                                                 |
 |                                                                          |
 | USAGE                                                                    |
 |    Create a new Inventory Lot.                                           |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This procedure creates a new inventory Lot using the raw data and     |
 |    datbase rows passed in.                                               |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
 |    p_commit           IN  VARCHAR2     - Commit Indicator                |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_lot_rec          IN  lot_rec_typ  - Lot Master details              |
 |    x_return_status    OUT VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NUMBER       - Number of messages              |
 |    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 | RETURNS                                                                  |
 |    None                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 | 13-May-00     P.J.Schofield Major restructuring for performance reasons  |
 |               B1294915.                                                  |
 +==========================================================================+
*/

PROCEDURE Create_Lot
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  lot_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name         VARCHAR2(30) := 'G_Create_Lot';
BEGIN

  /*  Standard call to check for call compatibility. */

  IF NOT FND_API.Compatible_API_CALL
    (GMIGUTL.api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Initialize message list if p_int_msg_list is set TRUE.  */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  GMIVLOT.Validate_Lot
                        (  p_api_version      => p_api_version
                         , p_validation_level => p_validation_level
                         , p_lot_rec          => p_lot_rec
                         , p_ic_item_mst_row  => p_ic_item_mst_row
			 , p_ic_item_cpg_row  => p_ic_item_cpg_row
			 , x_ic_lots_mst_row  => x_ic_lots_mst_row
                         , x_ic_lots_cpg_row  => x_ic_lots_cpg_row
                         , x_return_status    => x_return_status
                         , x_msg_count        => x_msg_count
                         , x_msg_data         => x_msg_data
                        );

  SAVEPOINT Create_Lot;
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    /*  If no errors were found then proceed with the database inserts */

    IF GMIVDBL.ic_lots_mst_insert(x_ic_lots_mst_row, x_ic_lots_mst_row)
    THEN
      -- Jatinder - B3158806 - Removed SY$CPG_INSTALL check
      x_ic_lots_cpg_row.lot_id := x_ic_lots_mst_row.lot_id;
      IF GMIVDBL.ic_lots_cpg_insert(x_ic_lots_cpg_row, x_ic_lots_cpg_row)
      THEN
        NULL;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FND_MESSAGE.SET_NAME('GMI','IC_API_LOT_CREATED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_lot_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', p_lot_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_lot_rec.sublot_no);
      FND_MSG_PUB.Add;

      IF FND_API.to_boolean(p_commit)
      THEN
        COMMIT WORK;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
  --Jalaj Srivastava Bug 2485879
  --Added else for assigning return status
  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  FND_MSG_PUB.Count_AND_GET
        (p_count => x_msg_count, p_data => x_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    ROLLBACK TO Create_Lot;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK TO Create_Lot;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data => x_msg_data);
END Create_Lot;



/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Create_Item_lot_Conv                                                  |
 |                                                                          |
 | TYPE                                                                     |
 |    Group                                                                 |
 |                                                                          |
 | USAGE                                                                    |
 |    Create a new Item/Lot/Sublot conversion using the data and database   |
 |    rows supplied                                                         |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
 |    p_commit           IN  VARCHAR2     - Commit Indicator                |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_conv_rec         IN  GMIGAPI.lot_rec_typ  - Conversion details      |
 |    x_ic_item_cnv_row  OUT ic_item_cnv%ROWTYPE                            |
 |    x_return_status    OUT VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NUMBER       - Number of messages              |
 |    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 | 13-May-00     P.J.Schofield Major restructuring for performance reasons  |
 |               B1294915.                                                  |
 |																									 |
 | 17-Apr-2001	A. Mundhe	Bug 1741321- Added code so that uom type is      |
 |                         displayed in the success message.                |
 |																									 |
 | 02-May-2001 A. Mundhe   Bug 1741321- Display message if conversion       |
 |                         already exists.                                  |
 +==========================================================================+
*/
PROCEDURE Create_Item_Lot_Conv
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_conv_rec         IN  GMIGAPI.conv_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, x_ic_item_cnv_row  OUT NOCOPY ic_item_cnv%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name         VARCHAR2(30) := 'G_Create_Conv';
BEGIN

  /*  Standard call to check for call compatibility. */

  IF NOT FND_API.Compatible_API_CALL
    (GMIGUTL.api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Initialize message list if p_int_msg_list is set TRUE.  */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  GMIVILC.Validate_Lot_Conversion
                        (  p_api_version      => p_api_version
                         , p_validation_level => p_validation_level
                         , p_item_cnv_rec    => p_conv_rec
                         , p_ic_item_mst_row  => p_ic_item_mst_row
                         , p_ic_lots_mst_row  => p_ic_lots_mst_row
                         , x_ic_item_cnv_row  => x_ic_item_cnv_row
                         , x_return_status    => x_return_status
                         , x_msg_count        => x_msg_count
                         , x_msg_data         => x_msg_data
                        );

  SAVEPOINT Create_Conv;
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    /*  If no errors were found then proceed with the database insert */
    /* Bug 1741321 */
    /* Set token for uom type to be displayed in the success message */
    IF GMIVDBL.ic_item_cnv_insert(x_ic_item_cnv_row, x_ic_item_cnv_row)
    THEN

      FND_MESSAGE.SET_NAME('GMI','IC_API_ILC_CREATED');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', p_conv_rec.item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', p_conv_rec.lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_conv_rec.sublot_no);
      FND_MESSAGE.SET_TOKEN('UM_TYPE', x_ic_item_cnv_row.um_type);
      FND_MSG_PUB.Add;

      IF FND_API.to_boolean(p_commit)
      THEN
        COMMIT WORK;
      END IF;
    /* Bug 1741321 */
    /* Display message if conversion already exists. */
	 ELSE
      IF GMIGUTL.DB_ERRNUM = -1
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_CNV_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', p_conv_rec.item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', p_conv_rec.lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', p_conv_rec.sublot_no);
        FND_MESSAGE.SET_TOKEN('UM_TYPE', x_ic_item_cnv_row.um_type);
        FND_MSG_PUB.Add;
    ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
  END IF;

  FND_MSG_PUB.Count_AND_GET
        (p_count => x_msg_count, p_data => x_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    ROLLBACK TO Create_Conv;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK TO Create_Conv;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data => x_msg_data);
END Create_Item_lot_Conv;


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Inventory_posting                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |    Group                                                                 |
 |                                                                          |
 | USAGE                                                                    |
 |    Sets up and posts and inventory journal from raw data and database    |
 |    rows supplied.                                                        |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_init_msg_list    IN  VARCHAR2     - Message Initialization Ind.     |
 |    p_commit           IN  VARCHAR2     - Commit Indicator                |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_qty_rec          IN  GMIGAPI.qty_rec_typ  - Quantity details        |
 |    p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE                            |
 |    p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE                            |
 |    p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE                            |
 |    p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE                            |
 |    x_ic_jrnl_mst_row  OUT ic_jrnl_mst%ROWTYPE                            |
 |    x_ic_adjs_jnl_row1 OUT ic_adjs_jnl%ROWTYPE                            |
 |    x_ic_adjs_jnl_row2 OUT ic_adjs_jnl%ROWTYPE                            |
 |    x_return_status    OUT VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NUMBER       - Number of messages              |
 |    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ OUT parameters                                                 |
 |                                                                          |
 | HISTORY                                                                  |
 | 13-May-00     P.J.Schofield Major restructuring for performance reasons  |
 |               B1294915.                                                  |
 |																									 |
 | 16/Mar/2001    A. Mundhe   Bug 1655794 - Generate the output log file    |
 |                            with proper messages upon sucessful run of    |
 |                            the API.							    					 |
 |																									 |
 | 11/NOV/2001		A. Mundhe	Bug 2033879 - Added code so that inventory    |
 |                            summary is updated correctly for status       |
 |                            immediate.                                    |
 | 01/Nov/2001    Ajay Kumar  Bug 1834743 - For manual document ordering,   |
 |                            insert the journal number which is passed     |
 |                            from the flat file.                           |
 |                                                                          |
 | 14-Mar-2002 Ajay Kumar     BUG#1834743 - Added code to validate the      |
 |                            journal number entered, when manual document  |
 |                            ordering is done.                             |
 | 07/24/02    Jalaj Srivastava Bug 2483656                                 |
 |                         Modified inventory_posting to let users create   |
 |                         journals through APIs.                           |
 |                         Backed out fix for bug 2033879 as the correct    |
 |                         place for the fix would be GMIVTXN package
 |                         'coz the call to APIs from the form does not     |
 |                         go through this procedure.
 | 10-Mar-04   Jalaj Srivastava Bug 3282770                                 |
 |             Move allocations while doing   |
 |             a move immediate if all the criterion are satisfied.         |
 +==========================================================================+
 */

PROCEDURE Inventory_Posting
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_qty_rec          IN  GMIGAPI.qty_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE
, x_ic_jrnl_mst_row  OUT NOCOPY ic_jrnl_mst%ROWTYPE
, x_ic_adjs_jnl_row1 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_ic_adjs_jnl_row2 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_ic_lots_mst_row  ic_lots_mst%ROWTYPE;
  l_ic_lots_cpg_row  ic_lots_cpg%ROWTYPE;
  l_lot_rec          GMIGAPI.lot_rec_typ;
  l_tran_row1        ic_tran_cmp%ROWTYPE;
  l_tran_row2        ic_tran_cmp%ROWTYPE;
  l_tran_rec         GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_qty_rec          GMIGAPI.qty_rec_typ;
  l_api_name         VARCHAR2(30) := 'G_Inventory_Post';
  l_return_status    NUMBER;
  l_trans_qty		   NUMBER;
  l_trans_qty2		   NUMBER;
  x_move_allocations VARCHAR2(1);

  -- BEGIN BUG#1834743 V. Ajay Kumar
  l_assign_type      NUMBER;
  CURSOR Check_Assignment_Type IS
    SELECT assignment_type
    FROM   sy_docs_seq
    WHERE  orgn_code = p_qty_rec.orgn_code
    AND    doc_type = 'JRNL';
  -- END BUG#1834743

  -- BEGIN BUG#1834743 V. Ajay Kumar
  --Cursor added to fetch the number of records for a journal no.
  l_record_count NUMBER;
  CURSOR Check_Record_Count IS
  SELECT count(*)
  FROM   ic_jrnl_mst
  WHERE  journal_no = l_qty_rec.journal_no
  AND    orgn_code = l_qty_rec.orgn_code;
  --END BUG#1834743

  Cursor check_journal_no IS
    SELECT count(1)
    FROM   ic_jrnl_mst j, ic_adjs_jnl a
    where  j.journal_no  = l_qty_rec.journal_no
    AND    j.orgn_code   = l_qty_rec.orgn_code
    AND    j.delete_mark = 0
    AND    j.posted_ind  = 0
    AND    a.orgn_code   = j.orgn_code
    AND    a.journal_id  = j.journal_id
    AND    a.trans_type  = x_ic_adjs_jnl_row1.trans_type;

  CURSOR get_doc_line IS
    SELECT nvl(max(doc_line),0) + 1
    FROM ic_adjs_jnl
    WHERE orgn_code  = x_ic_adjs_jnl_row1.orgn_code AND
          journal_id = x_ic_adjs_jnl_row1.journal_id;


BEGIN

  /*  Standard call to check for call compatibility. */

  IF NOT FND_API.Compatible_API_CALL
    (GMIGUTL.api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Initialize message list if p_int_msg_list is set TRUE.  */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;
  --Jalaj Srivastava Bug 2483656
  l_qty_rec := p_qty_rec;
  GMIVQTY.Validate_Inventory_Posting
                        (  p_api_version      => p_api_version
                         , p_validation_level => p_validation_level
                         , p_qty_rec          => p_qty_rec
                         , p_ic_item_mst_row  => p_ic_item_mst_row
                         , p_ic_item_cpg_row  => p_ic_item_cpg_row
			 , p_ic_lots_mst_row  => p_ic_lots_mst_row
                         , p_ic_lots_cpg_row  => p_ic_lots_cpg_row
                         , x_ic_jrnl_mst_row  => x_ic_jrnl_mst_row
                         , x_ic_adjs_jnl_row1 => x_ic_adjs_jnl_row1
                         , x_ic_adjs_jnl_row2 => x_ic_adjs_jnl_row2
                         , x_return_status    => x_return_status
                         , x_msg_count        => x_msg_count
                         , x_msg_data         => x_msg_data
                        );

  SAVEPOINT Create_Posting;
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    /*  If this is a 'CREI' transaction and the item is lot controlled */
    /*  then we must create the lot first as we'll need the ID in what  */
    /*  follows. */

    IF x_ic_adjs_jnl_row1.trans_type IN ('CREI','CRER')
    THEN
      IF p_ic_item_mst_row.lot_ctl = 0
      THEN
        l_ic_lots_mst_row.lot_id := 0;
        l_ic_lots_mst_row.lot_no := GMIGUTL.IC$DEFAULT_LOT;
        x_ic_adjs_jnl_row1.lot_id := l_ic_lots_mst_row.lot_id;
      ELSE
        l_lot_rec.lot_no := p_qty_rec.lot_no;
        IF p_ic_item_mst_row.sublot_ctl = 1
        THEN
          l_lot_rec.sublot_no := p_qty_rec.sublot_no;
        END IF;

        /*  Make sure we aren't trying to create a lot which exists already. */

        GMIGUTL.get_lot
                   (  p_ic_item_mst_row.item_id
                   ,  p_qty_rec.lot_no
                   ,  p_qty_rec.sublot_no
                   ,  l_ic_lots_mst_row
                   ,  l_ic_lots_cpg_row
                   );

        IF l_ic_lots_mst_row.lot_id IS NULL
        THEN
          Create_Lot (  p_api_version     => p_api_version
                      , p_init_msg_list   => FND_API.G_FALSE
                      , p_commit          => FND_API.G_FALSE
                      , p_validation_level=> FND_API.G_VALID_LEVEL_FULL
                      , p_lot_rec         => l_lot_rec
                      , p_ic_item_mst_row => p_ic_item_mst_row
                      , p_ic_item_cpg_row => p_ic_item_cpg_row
                      , x_ic_lots_mst_row => l_ic_lots_mst_row
                      , x_ic_lots_cpg_row => l_ic_lots_cpg_row
                      , x_return_status   => x_return_status
                      , x_msg_count       => x_msg_count
                      , x_msg_data        => x_msg_data
                     );
        END IF;

        IF x_return_status = FND_API.G_RET_STS_SUCCESS
        THEN
          x_ic_adjs_jnl_row1.lot_id := l_ic_lots_mst_row.lot_id;
        ELSE
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    ELSE
      IF p_ic_item_mst_row.lot_ctl = 0
      THEN
        l_ic_lots_mst_row.lot_id := 0;
        l_ic_lots_mst_row.lot_no := GMIGUTL.IC$DEFAULT_LOT;
        x_ic_adjs_jnl_row1.lot_id := l_ic_lots_mst_row.lot_id;
      END IF;
    END IF;

    /* *********************************************************************
       Jalaj Srivastava Bug 3282770
       If it is a move immediate, check if moving allocations is
       required/permitted. It is applicable only for lot controlled items.
       ********************************************************************* */
     --{
     IF (     (p_ic_item_mst_row.lot_ctl  = 1)
          AND (    (p_ic_item_mst_row.status_ctl = 0)
                OR (fnd_profile.value('IC$MOVEDIFFSTAT') IN (0,2))
              )
          AND (x_ic_adjs_jnl_row1.trans_type = 'TRNI')
          AND (fnd_profile.value('IC$MOVEALLOC') = 1)
        ) THEN

            GMIALLOC.CHECK_ALLOC_QTY
              ( p_api_version          => 1.0
               ,p_init_msg_list        => fnd_api.g_false
               ,p_commit               => fnd_api.g_false
               ,p_validation_level     => fnd_api.g_valid_level_full
               ,x_return_status        => x_return_status
               ,x_msg_count            => x_msg_count
               ,x_msg_data             => x_msg_data
               ,pfrom_whse_code        => x_ic_adjs_jnl_row1.whse_code
               ,pfrom_location         => nvl(x_ic_adjs_jnl_row1.location,fnd_profile.value('IC$DEFAULT_LOCT'))
               ,plot_id                => x_ic_adjs_jnl_row1.lot_id
               ,pitem_id               => x_ic_adjs_jnl_row1.item_id
               ,pmove_qty              => x_ic_adjs_jnl_row2.qty
               ,pto_whse_code          => x_ic_adjs_jnl_row2.whse_code
               ,x_move_allocations     => x_move_allocations
              );

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
     END IF;--}


    /*  If manual document sequencing is in force we need a journal
        number. If it's automatic we will generate one. If we're
        given one and the sequencing is automatic, use the one we've
        generated. */
    -- BEGIN BUG#1834743 V. Ajay Kumar
    -- Check for document ordering and assign the journal number.
	 OPEN Check_Assignment_Type;
    FETCH Check_Assignment_Type into l_assign_type;
	 CLOSE Check_Assignment_Type;

--Jalaj Srivastava Bug 2483656
    IF (l_assign_type = 2) THEN
       IF (p_qty_rec.trans_type <= 5) THEN
          x_ic_jrnl_mst_row.journal_no :=GMA_GLOBAL_GRP.Get_doc_no ( 'JRNL', p_qty_rec.orgn_code);
       ELSIF (p_qty_rec.trans_type >= 6) THEN
         IF (p_qty_rec.journal_no IS NULL) THEN
           x_ic_jrnl_mst_row.journal_no :=GMA_GLOBAL_GRP.Get_doc_no ( 'JRNL' , p_qty_rec.orgn_code);
         ELSE
	   IF (      (upper(p_qty_rec.journal_no) = 'PREVIOUS')
                 AND (p_qty_rec.orgn_code = prev_orgn_code)
              ) THEN
                 l_qty_rec.journal_no := prev_journal_no;
           END IF;
           OPEN check_journal_no;
	   FETCH check_journal_no INTO l_record_count;
	   CLOSE check_journal_no;
	   IF (l_record_count = 0) THEN
	     FND_MESSAGE.SET_NAME ('GMI', 'IC_API_INVALID_JOURNAL_NO');
	     FND_MESSAGE.SET_TOKEN('JOURNAL_NO',p_qty_rec.journal_no);
	     FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
	   ELSE
	     x_ic_jrnl_mst_row.journal_no := l_qty_rec.journal_no;
           END IF;
         END IF;
       END IF;
    ELSE
         OPEN Check_Record_Count;
         FETCH Check_Record_Count INTO l_record_count;
         CLOSE Check_Record_Count;

         --Validation of the journal number takes place here.
         --If there are no records retreived, then a journal is created sucessfully,
         --else an error message is displayed.

	   IF l_record_count = 0 THEN
	     x_ic_jrnl_mst_row.journal_no := l_qty_rec.journal_no;
           ELSIF (p_qty_rec.trans_type <= 5) THEN
	     FND_MESSAGE.SET_NAME ('GMI', 'GMI_JOURNALNOEXISTS');
	     FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
           ELSIF (p_qty_rec.trans_type >=6) THEN
             OPEN check_journal_no;
	     FETCH check_journal_no INTO l_record_count;
	     CLOSE check_journal_no;
	     IF (l_record_count = 0) THEN
	       FND_MESSAGE.SET_NAME ('GMI', 'IC_API_INVALID_JOURNAL_NO');
	       FND_MESSAGE.SET_TOKEN('JOURNAL_NO',l_qty_rec.journal_no);
	       FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
             ELSE
	       x_ic_jrnl_mst_row.journal_no := l_qty_rec.journal_no;
             END IF;
	   END IF;
    END IF;
    IF (upper(l_qty_rec.journal_no) = 'PREVIOUS') THEN
      FND_MESSAGE.SET_NAME ('GMI', 'IC_API_INVALID_JOURNAL_NO');
      FND_MESSAGE.SET_TOKEN('JOURNAL_NO',l_qty_rec.journal_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (NVL(x_ic_jrnl_mst_row.journal_no, ' ') = ' ') THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_UNABLE_TO_GET_DOC_NO');
      FND_MESSAGE.SET_TOKEN('DOC_TYPE','JRNL');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE',p_qty_rec.orgn_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
IF GMIVDBL.ic_jrnl_mst_insert(x_ic_jrnl_mst_row, x_ic_jrnl_mst_row) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_ic_adjs_jnl_row1.journal_id := x_ic_jrnl_mst_row.journal_id;
      --Jalaj Srivastava Bug 2483656
      IF (      (l_assign_type = 2)
	   AND  (p_qty_rec.trans_type >=6)
	 ) THEN
	    prev_orgn_code  := p_qty_rec.orgn_code;
	    prev_journal_no := x_ic_jrnl_mst_row.journal_no;
      ELSE
	   prev_orgn_code  := NULL;
	   prev_journal_no := NULL;
      END IF;
      OPEN  get_doc_line;
      FETCH get_doc_line INTO x_ic_adjs_jnl_row1.doc_line;
      CLOSE get_doc_line;

  IF GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row1,x_ic_adjs_jnl_row1) THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF (substr(x_ic_adjs_jnl_row1.trans_type,4,1) = 'I') THEN
        GMIVQTY.construct_txn_rec
          (x_ic_adjs_jnl_row1, l_tran_rec);
        GMI_TRANS_ENGINE_PUB.create_completed_transaction
          ( p_api_version      => 1.0
          , p_init_msg_list    => FND_API.G_FALSE
          , p_commit           => FND_API.G_FALSE
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL
          , p_tran_rec         => l_tran_rec
          , x_tran_row         => l_tran_row1
          , x_return_status    => x_return_status
          , x_msg_count        => x_msg_count
          , x_msg_data         => x_msg_data
          );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF; --IF (substr(x_ic_adjs_jnl_row1.trans_type,4,1) = 'I')

     IF substr(x_ic_adjs_jnl_row1.trans_type,1,3) IN ('TRN','STS','GRD') THEN
        x_ic_adjs_jnl_row2.doc_id := x_ic_adjs_jnl_row1.doc_id;
        x_ic_adjs_jnl_row2.journal_id := x_ic_adjs_jnl_row1.journal_id;
        x_ic_adjs_jnl_row2.doc_line := x_ic_adjs_jnl_row1.doc_line + 1;
        IF GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row2, x_ic_adjs_jnl_row2) THEN
	  x_return_status := FND_API.G_RET_STS_SUCCESS;
          IF (substr(x_ic_adjs_jnl_row1.trans_type,4,1) = 'I') THEN
              GMIVQTY.construct_txn_rec
                (x_ic_adjs_jnl_row2, l_tran_rec);
              GMI_TRANS_ENGINE_PUB.create_completed_transaction
              ( p_api_version      => 1.0
              , p_init_msg_list    => FND_API.G_FALSE
              , p_commit           => FND_API.G_FALSE
              , p_validation_level => FND_API.G_VALID_LEVEL_FULL
              , p_tran_rec         => l_tran_rec
              , x_tran_row         => l_tran_row2
              , x_return_status    => x_return_status
              , x_msg_count        => x_msg_count
              , x_msg_data         => x_msg_data
              );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            /* *********************************************************************
               Jalaj Srivastava Bug 3282770
               If it is a move immediate and moving allocations is
               required/permitted then lets do it.
               ********************************************************************* */
            --{
            IF (x_move_allocations = 'Y') THEN
              GMIALLOC.UPDATE_PENDING_ALLOCATIONS
                   ( p_api_version          => 1.0
                    ,p_init_msg_list        => fnd_api.g_false
                    ,p_commit               => fnd_api.g_false
                    ,p_validation_level     => fnd_api.g_valid_level_full
                    ,x_return_status        => x_return_status
                    ,x_msg_count            => x_msg_count
                    ,x_msg_data             => x_msg_data
                    ,pdoc_id                => l_tran_rec.doc_id
                    ,pto_whse_code          => x_ic_adjs_jnl_row2.whse_code
                    ,pto_location           => nvl(x_ic_adjs_jnl_row2.location,fnd_profile.value('IC$DEFAULT_LOCT'))
                   );


              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

            END IF;--}

          END IF; --(substr(x_ic_adjs_jnl_row1.trans_type,4,1) = 'I')
	ELSE --GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row2, x_ic_adjs_jnl_row2)
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF; --GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row2, x_ic_adjs_jnl_row2)
     END IF; --substr(x_ic_adjs_jnl_row1.trans_type,1,3) IN ('TRN','STS','GRD')
  ELSE --GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row1,x_ic_adjs_jnl_row1)
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF; --GMIVDBL.ic_adjs_jnl_insert(x_ic_adjs_jnl_row1,x_ic_adjs_jnl_row1)
ELSE --GMIVDBL.ic_jrnl_mst_insert(x_ic_jrnl_mst_row, x_ic_jrnl_mst_row)
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END IF;
END IF;

  		/* Bug 1655794 - Generate the output log file with proper messages */
  		/* upon sucessful run of the API. */
     IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      	IF(x_ic_adjs_jnl_row1.trans_type = 'CREI') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_CRE_TRAN_POSTED');
	ELSIF(x_ic_adjs_jnl_row1.trans_type = 'ADJI') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_ADJ_TRAN_POSTED');
	ELSIF(x_ic_adjs_jnl_row1.trans_type = 'TRNI') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_TRN_TRAN_POSTED');
	ELSIF(x_ic_adjs_jnl_row1.trans_type = 'STSI') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_STS_TRAN_POSTED');
        ELSIF(x_ic_adjs_jnl_row1.trans_type = 'GRDI') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_GRD_TRAN_POSTED');
        ELSIF (x_ic_adjs_jnl_row1.trans_type = 'CRER') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_CRER_TRAN_CREATED');
        ELSIF(x_ic_adjs_jnl_row1.trans_type = 'ADJR') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_ADJR_TRAN_CREATED');
        ELSIF(x_ic_adjs_jnl_row1.trans_type = 'TRNR') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_TRNR_TRAN_CREATED');
        ELSIF(x_ic_adjs_jnl_row1.trans_type = 'STSR') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_STSR_TRAN_CREATED');
        ELSIF(x_ic_adjs_jnl_row1.trans_type = 'GRDR') THEN
      		FND_MESSAGE.SET_NAME('GMI','IC_API_GRDR_TRAN_CREATED');
	END IF;
        IF (x_ic_adjs_jnl_row1.trans_type IN ('CRER','ADJR')) THEN
	   FND_MESSAGE.SET_TOKEN('DOC_LINE', x_ic_adjs_jnl_row1.doc_line);
        ELSIF (x_ic_adjs_jnl_row1.trans_type IN ('GRDR','TRNR','STSR')) THEN
	   FND_MESSAGE.SET_TOKEN('DOC_LINE_FROM', x_ic_adjs_jnl_row1.doc_line);
	   FND_MESSAGE.SET_TOKEN('DOC_LINE_TO', x_ic_adjs_jnl_row2.doc_line);
        END IF;
	FND_MESSAGE.SET_TOKEN('JOURNAL_NO', x_ic_jrnl_mst_row.journal_no);
	FND_MESSAGE.SET_TOKEN('ORGN_CODE', x_ic_adjs_jnl_row1.orgn_code);
	FND_MESSAGE.SET_TOKEN('ITEM_NO', p_ic_item_mst_row.item_no);
      	FND_MESSAGE.SET_TOKEN('LOT_NO',p_ic_lots_mst_row.lot_no);
      	FND_MESSAGE.SET_TOKEN('SUBLOT_NO',p_ic_lots_mst_row.sublot_no);
	FND_MSG_PUB.Add;

	/* **************************************************************
	   Jalaj Srivastava Bug 3282770
	   Post message to log to indicate that the allocations have been
	   moved.
	   *************************************************************** */
        IF (x_ic_adjs_jnl_row1.trans_type = 'TRNI' and x_move_allocations = 'Y') THEN
          FND_MESSAGE.SET_NAME('GMI','GMI_ALLOCATIONS_MOVED');
        END IF;
	FND_MSG_PUB.Add;

      	IF FND_API.to_boolean(p_commit) THEN
       	   COMMIT WORK;
      	END IF;
     ELSE
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END IF; --(x_return_status = FND_API.G_RET_STS_SUCCESS)
     FND_MSG_PUB.Count_AND_GET
        (p_count => x_msg_count, p_data => x_msg_data);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        ROLLBACK TO Create_Posting;
     END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Posting;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
   WHEN OTHERS THEN
    ROLLBACK TO Create_Posting;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data => x_msg_data);
END Inventory_Posting;



PROCEDURE Inventory_Transfer
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2
, p_commit           IN  VARCHAR2
, p_validation_level IN  NUMBER
, p_xfer_rec         IN  GMIGAPI.xfer_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE
, p_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
, x_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name         VARCHAR2(30) := 'Inventory Transfer';
  l_return_status    NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data => x_msg_data);
END Inventory_Transfer;

END GMIGAPI;

/
