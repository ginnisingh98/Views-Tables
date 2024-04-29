--------------------------------------------------------
--  DDL for Package Body GMIVLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVLOT" AS
/* $Header: GMIVLOTB.pls 115.29 2004/07/07 14:56:15 jgogna ship $ */
/*  Global variables */
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMIVLOT';


/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Validate_Lot                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |    Performs all validation functions associated with creation of a new   |
 |    inventory lot                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This procedure validates all data associated with creation of a new   |
 |    inventory lot                                                         |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_lot_rec          IN  GMIGAPI.lot_rec_typ  - Lot Master details      |
 |    p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE                            |
 |    p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE                            |
 |    x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE                     |
 |    x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE                     |
 |    x_return_status    OUT NOCOPY VARCHAR2     - Return Status            |
 |    x_msg_count        OUT NOCOPY NUMBER       - Number of messages       |
 |    x_msg_data         OUT NOCOPY VARCHAR2  - Messages in encoded format  |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via 'out' parameters                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |    14-May-2000  P.J.Schofield B1294915                                   |
 |                 Major reworking for performance reasons.                 |
 |                                                                          |
 |                                                                          |
 |    03-May-2001  A. Mundhe Bug 1762786 - Assign vendor_lot_no so that it  |
 |                           is updated in ic_lots_mst.                     |
 |   									    |
 |    25-Oct-2001  A. Mundhe Bug 1886611 - Assign vendor_lot_no without     |
 |                           validating shipvendor_id.                      |
 |    21-DEC-2001  K. RajaSekhar Reddy BUG#2158123                          |
 |                          Modified the code to create the Retest Date,    |
 |                          Expire Date and Expaction Dates correctly.      |
 |   Jalaj Srivastava 08/20/02 Bug 2520129                                  |
 |      The lot rec typ record is changed in GMIGAPI to not default lot     |
 |      created date to sysdate to make it referencable from forms. Forms   |
 |      has a limitation of not acceptinf default values of sysdate for     |
 |      record objects.  We will default the lot created date here          |
 |      from now on.                                                        |
 |      Assigned proper value to x_ic_lots_mst_row.lot_created in the       |
 |      beginning and used that instead of p_lot_rec.lot_created to check   |
 |      the validation for other dates.                                     |
 |    16-Sep-2002  A. Cataldo Bug 2458413 - Properly initialize expaction   |
 |                 date for non grd cntl items (lot crt API) and setup deflt|
 |                 dates for default trans in lots_mst (item create API).   |
 |    04-Nov-2002  A.Cataldo Bug # 2343411                                  |
 |                 Based on a new profile option, allow the user to control |
 |                 what the lot description will be defaulted to when       |
 |                 creating lots either via screen or APIs.                 |
 |    22-FEB-2003  Jalaj Srivastava Bug 2811747                             |
 |                 error status wold be set as soon as error condition is   |
 |                 encountered. messages could be already written in        |
 |                 global message table by calling programs so the check for|
 |                 looking whether something is there in the message table  |
 |                 to set error status is not good.                         |
 |    27-AUG-2003  James Bernard Bug 3115930 Modified code so that user can |
 |                 create expired lots.                                     |
 |    25-NOV-2003  RajaSekhar Reddy BUG#3259379                             |
 |                 Modified code to set the default effective max date      |
 |                 for retest, expire and expaction dates if item is a      |
 |                 non grade controlled item and Retest Interval, Shelf Life|
 |                 or Expiration Interval are equal to zero.                |
 |    04-DEC-2003  Sastry BUG#3270249                                       |
 |                 Modified code to set the correct timestamp for           |
 |                 lot_created, creation_date and last_update_date          |
 |                 for a new lot created while receving.                    |
 |    17-MAY-2004  Archana Mundhe Bug 3621870                               |
 |                 Assign max date to retest,expire and expaction date for  |
 |                 non grade ctl items.                                     |
 |     6-JUL-2004  3739308 - changed above interval check to <> 0. Jatinder |
  +==========================================================================+
*/
PROCEDURE Validate_Lot
( p_api_version      IN  NUMBER
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  GMIGAPI.lot_rec_typ
, p_ic_item_mst_row     IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row     IN  ic_item_cpg%ROWTYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name       CONSTANT VARCHAR2 (30) := 'Validate_Lot';
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
  --BUG#3115930 James
  --Initialized the variables.
  l_item_no                 ic_item_mst.item_no%TYPE  := p_ic_item_mst_row.item_no;
  l_lot_no                  ic_lots_mst.lot_no%TYPE   := p_lot_rec.lot_no;
  l_sublot_no               ic_lots_mst.sublot_no%TYPE:= p_lot_rec.sublot_no;
  l_qc_grade                ic_lots_mst.qc_grade%TYPE;
  l_expaction_code          ic_lots_mst.expaction_code%TYPE;
  l_user_name               fnd_user.user_name%TYPE;
  l_lot_rec                 GMIGAPI.lot_rec_typ;
  l_qc_grad_mst_row         qc_grad_mst%ROWTYPE;
  l_qc_actn_mst_row         qc_actn_mst%ROWTYPE;
  l_po_vend_mst_row         po_vend_mst%ROWTYPE;
  l_def_lot_desc            NUMBER;                      /* Bug 2343411 */

BEGIN
  /*  Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_CALL (  GMIGUTL.API_VERSION
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                     )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Assume things are going to work out...... */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  Initialise output records. Other values will be setup below */
  /*  First set up the audit columns on both rows */

  /*  Default creation/update dates if not passed in */
  /* **************************************************
     Jalaj Srivastava 08/20/02 Bug 2520129
     The lot rec typ record is changed in GMIGAPI
     to not default lot created date to sysdate to
     make it referencable from forms. Forms has a
     limitation of not acceptinf default values
     of sysdate for record objects.
     We will default the lot created date here
     from now on.
     ************************************************** */
  -- BEGIN BUG#3270249 Sastry
  -- Modified code so that the timestamp for lot_created, creation_date and
  -- last_update_date date is correct for a new lot created while receving.
  -- Jatinder Gogna - 3470841 - Do not default NULL lot_created date to sysdate
  IF (TRUNC(p_lot_rec.lot_created) = TRUNC(SYSDATE))
  THEN
    x_ic_lots_mst_row.lot_created      := SYSDATE;
  ELSE
    x_ic_lots_mst_row.lot_created      := p_lot_rec.lot_created;
  END IF;
  x_ic_lots_mst_row.creation_date      := SYSDATE;
  x_ic_lots_mst_row.last_update_date   := SYSDATE;
  --END BUG#3270249

  x_ic_lots_mst_row.created_by := GMIGUTL.DEFAULT_USER_ID;
  x_ic_lots_mst_row.last_updated_by := GMIGUTL.DEFAULT_USER_ID;
  x_ic_lots_mst_row.last_update_login:= GMIGUTL.DEFAULT_LOGIN;

  -- Jatinder B3158806 - Removed check for SY$CPG_INSTALL
  /*  Set up values for ic_lots_cpg. */
  x_ic_lots_cpg_row.item_id       := p_ic_item_mst_row.item_id;
  x_ic_lots_cpg_row.lot_id        := NULL;
  x_ic_lots_cpg_row.created_by := GMIGUTL.DEFAULT_USER_ID;
  x_ic_lots_cpg_row.last_updated_by := GMIGUTL.DEFAULT_USER_ID;
  x_ic_lots_cpg_row.creation_date:= x_ic_lots_mst_row.creation_date;
  x_ic_lots_cpg_row.last_update_date := x_ic_lots_mst_row.last_update_date;
  x_ic_lots_cpg_row.last_update_login:= GMIGUTL.DEFAULT_LOGIN;

  /* Bug 2343411 - User defined lot description  */
  /* Based on the value of the profile option, populate the lot_desc */

  /* First, lets get the value of the profile option */
  l_def_lot_desc :=  GMIGUTL.IC$DEFAULT_LOT_DESC;

  /* Only set up the default lot desc if the user does not pass one in */
  IF p_lot_rec.lot_desc IS NULL
  THEN
    -- If it is set to zero then nothing goes into the lot description
    IF (l_def_lot_desc = 0)
    THEN
       x_ic_lots_mst_row.lot_desc := NULL;
    -- If it is set to one then item_no goes into the lot description
    ELSIF (l_def_lot_desc = 1)
    THEN
       x_ic_lots_mst_row.lot_desc := p_ic_item_mst_row.item_no;
    -- If it is set to three then item_no from whse_item goes into the descr
    ELSIF (l_def_lot_desc = 3)
    THEN
       SELECT item_no
         INTO x_ic_lots_mst_row.lot_desc
         FROM   ic_item_mst
         WHERE  item_id = (SELECT whse_item_id
                            FROM ic_item_mst
                            WHERE item_id = p_ic_item_mst_row.item_id);
    -- If it is set to 2 (or anything else) then use item_desc for lot desc
    ELSE
       x_ic_lots_mst_row.lot_desc := SUBSTRB(p_ic_item_mst_row.item_desc1,1,40);
    END IF;
  ELSE   /* The user has input a lot desc so use it  */
  x_ic_lots_mst_row.lot_desc         := p_lot_rec.lot_desc;
  END IF;
  /*  Set up the values on ic_lots_mst. */

  -- Bug 1886611
  -- Assign vendor_lot_no so that it is updated in ic_lots_mst.
  x_ic_lots_mst_row.vendor_lot_no := p_lot_rec.vendor_lot_no;

  x_ic_lots_mst_row.item_id          := p_ic_item_mst_row.item_id;
  x_ic_lots_mst_row.lot_id           := NULL;
  -- x_ic_lots_mst_row.lot_desc      := p_lot_rec.lot_desc;  /* Bug 2343411 */
  x_ic_lots_mst_row.expaction_date   := p_lot_rec.expaction_date;
  x_ic_lots_mst_row.expire_date      := p_lot_rec.expire_date;
  x_ic_lots_mst_row.retest_date      := p_lot_rec.retest_date;
  x_ic_lots_mst_row.strength         := p_lot_rec.strength;
  x_ic_lots_mst_row.inactive_ind     := p_lot_rec.inactive_ind;
  x_ic_lots_mst_row.origination_type := p_lot_rec.origination_type;
  x_ic_lots_mst_row.trans_cnt        := 1;
  x_ic_lots_mst_row.delete_mark      := 0;
  x_ic_lots_mst_row.text_code        := NULL;
  x_ic_lots_mst_row.attribute1       := UPPER(p_lot_rec.attribute1);
  x_ic_lots_mst_row.attribute2       := UPPER(p_lot_rec.attribute2);
  x_ic_lots_mst_row.attribute3       := UPPER(p_lot_rec.attribute3);
  x_ic_lots_mst_row.attribute4       := UPPER(p_lot_rec.attribute4);
  x_ic_lots_mst_row.attribute5       := UPPER(p_lot_rec.attribute5);
  x_ic_lots_mst_row.attribute6       := UPPER(p_lot_rec.attribute6);
  x_ic_lots_mst_row.attribute7       := UPPER(p_lot_rec.attribute7);
  x_ic_lots_mst_row.attribute8       := UPPER(p_lot_rec.attribute8);
  x_ic_lots_mst_row.attribute9       := UPPER(p_lot_rec.attribute9);
  x_ic_lots_mst_row.attribute10      := UPPER(p_lot_rec.attribute10);
  x_ic_lots_mst_row.attribute11      := UPPER(p_lot_rec.attribute11);
  x_ic_lots_mst_row.attribute12      := UPPER(p_lot_rec.attribute12);
  x_ic_lots_mst_row.attribute13      := UPPER(p_lot_rec.attribute13);
  x_ic_lots_mst_row.attribute14      := UPPER(p_lot_rec.attribute14);
  x_ic_lots_mst_row.attribute15      := UPPER(p_lot_rec.attribute15);
  x_ic_lots_mst_row.attribute16      := UPPER(p_lot_rec.attribute16);
  x_ic_lots_mst_row.attribute17      := UPPER(p_lot_rec.attribute17);
  x_ic_lots_mst_row.attribute18      := UPPER(p_lot_rec.attribute18);
  x_ic_lots_mst_row.attribute19      := UPPER(p_lot_rec.attribute19);
  x_ic_lots_mst_row.attribute20      := UPPER(p_lot_rec.attribute20);
  x_ic_lots_mst_row.attribute21      := UPPER(p_lot_rec.attribute21);
  x_ic_lots_mst_row.attribute22      := UPPER(p_lot_rec.attribute22);
  x_ic_lots_mst_row.attribute23      := UPPER(p_lot_rec.attribute23);
  x_ic_lots_mst_row.attribute24      := UPPER(p_lot_rec.attribute24);
  x_ic_lots_mst_row.attribute25      := UPPER(p_lot_rec.attribute25);
  x_ic_lots_mst_row.attribute26      := UPPER(p_lot_rec.attribute26);
  x_ic_lots_mst_row.attribute27      := UPPER(p_lot_rec.attribute27);
  x_ic_lots_mst_row.attribute28      := UPPER(p_lot_rec.attribute28);
  x_ic_lots_mst_row.attribute29      := UPPER(p_lot_rec.attribute29);
  x_ic_lots_mst_row.attribute30      := UPPER(p_lot_rec.attribute30);
  x_ic_lots_mst_row.attribute_category  := UPPER(p_lot_rec.attribute_category);

  IF  p_validation_level =  FND_API.G_VALID_LEVEL_NONE
  AND p_lot_rec.lot_no = GMIGUTL.IC$DEFAULT_LOT
  THEN
    /*  We are creating the default lot for a new item. */
    x_ic_lots_mst_row.lot_no           := GMIGUTL.IC$DEFAULT_LOT;
    x_ic_lots_mst_row.lot_id           := 0;
    x_ic_lots_mst_row.qc_grade         := UPPER(p_ic_item_mst_row.qc_grade);
    x_ic_lots_mst_row.lot_created      := p_ic_item_mst_row.creation_date;
    -- Bug 2458413 - Need to set up default dates to avoid having them
    -- being set to the FND_API.G_MISS_DATE
    x_ic_lots_mst_row.expire_date      := GMA_GLOBAL_GRP.SY$MAX_DATE;
    x_ic_lots_mst_row.retest_date      := GMA_GLOBAL_GRP.SY$MAX_DATE;
    x_ic_lots_mst_row.expaction_date   := GMA_GLOBAL_GRP.SY$MAX_DATE;

    -- Jatinder Gogna-B3158806- A row is always inserted into ic_lots_cpg
    x_ic_lots_cpg_row.lot_id           := 0;
    x_ic_lots_cpg_row.ic_matr_date     := NULL;
    x_ic_lots_cpg_row.ic_hold_date     := NULL;
  ELSE
    /*  Carry out fundamental validation. These errors will prevent any */
    /*  further validation. */
    IF p_ic_item_mst_row.item_id = 0 OR
	 p_ic_item_mst_row.delete_mark = 1
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_ic_item_mst_row.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF p_ic_item_mst_row.inactive_ind = 1 AND
          GMIGUTL.IC$API_ALLOW_INACTIVE = 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_ic_item_mst_row.item_no);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*  If we're still alive carry on with validation */

    /*  Check to see if item is lot Controlled */
    IF p_ic_item_mst_row.lot_ctl = 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_ITEM_NOT_LOT_CTL');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /*  Check that lot number has been supplied  */
    IF NVL(p_lot_rec.lot_no,' ') <> ' '
    THEN
       /*  J. DiIorio 01/19/2001 BUG#1570046  */
	x_ic_lots_mst_row.lot_no := UPPER(p_lot_rec.lot_no);
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /*  If item is not sublot controlled, flatten the sublot number, otherwise */
    /*  use what we are given. */

    IF p_ic_item_mst_row.sublot_ctl = 0
    THEN
	x_ic_lots_mst_row.sublot_no:= NULL;
    ELSE
        /*  J. DiIorio 01/19/2001 BUG#1570046  */
	x_ic_lots_mst_row.sublot_no:= UPPER(p_lot_rec.sublot_no);
    END IF;

    /*  If item is not QC graded, default qc_grade to null, regardless */
    /*  of what was passed in. If the item is QC graded but no value was */
    /*  given, default the value from the item. If a value was passed in */
    /*  ensure it is a valid grade. */

    IF p_ic_item_mst_row.grade_ctl = 0
    THEN
      x_ic_lots_mst_row.qc_grade := NULL;
    ELSE
    /* Validate QC Grade */
      IF NVL(p_lot_rec.qc_grade, p_ic_item_mst_row.qc_grade) = p_ic_item_mst_row.qc_grade
      THEN
        x_ic_lots_mst_row.qc_grade := p_ic_item_mst_row.qc_grade;
      ELSE
        IF GMIGUTL.v_qc_grade(UPPER(p_lot_rec.qc_grade),l_qc_grad_mst_row)
        THEN
	    x_ic_lots_mst_row.qc_grade := l_qc_grad_mst_row.qc_grade;
	ELSE
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_QC_GRADE');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
          FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
          FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
    END IF;

    /*  Validate expiry action code */
    IF p_lot_rec.expaction_code IS NULL
    THEN
      x_ic_lots_mst_row.expaction_code := p_ic_item_mst_row.expaction_code;
    ELSE
      IF GMIGUTL.v_expaction_code
        (UPPER(p_lot_rec.expaction_code), l_qc_actn_mst_row)
	THEN
	  x_ic_lots_mst_row.expaction_code:=l_qc_actn_mst_row.action_code;
	ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INV_LOT_EXPACTION_CODE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
    END IF;

    /* Validate Expiry Date */
    IF NVL(p_lot_rec.expire_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
    THEN
        -- Bug 3621870
        -- Check if its a grade controlled item.
        -- Assign max date to expire date for non grade ctl items.
	-- Jatinder Gogna - 3470841 - Compute only if lot_created is specified.
        IF p_ic_item_mst_row.grade_ctl = 1 OR
           (p_ic_item_mst_row.grade_ctl = 0 AND p_ic_item_mst_row.shelf_life <> 0)THEN
	   IF p_lot_rec.lot_created is not NULL THEN
	  	x_ic_lots_mst_row.expire_date :=
	        x_ic_lots_mst_row.lot_created + NVL(p_ic_item_mst_row.shelf_life,0);
	   END IF;
        ELSE
 	 x_ic_lots_mst_row.expire_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
        END IF;
    ELSE
      -- BEGIN BUG#3115930 James Bernard
      -- Modified code so that user is now allowed to create expired lots.
      -- However a message is logged.
      x_ic_lots_mst_row.expire_date := p_lot_rec.expire_date;
      IF TRUNC(p_lot_rec.expire_date) < TRUNC(x_ic_lots_mst_row.lot_created) THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_PAST_EXPIRE_DATE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
        FND_MSG_PUB.Add;
	   END IF;
 	    -- END BUG#3115930
    END IF;


    /* Validate Retest Date */

    IF NVL(p_lot_rec.retest_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
    THEN
        -- Bug 3621870
        -- Check if its a grade controlled item.
        -- Assign max date to retest date for non grade ctl items.
	-- Jatinder Gogna - 3470841 - Compute only if lot_created is specified.
        IF p_ic_item_mst_row.grade_ctl = 1 OR
           (p_ic_item_mst_row.grade_ctl = 0 AND p_ic_item_mst_row.retest_interval <> 0) THEN
	   IF p_lot_rec.lot_created is not NULL THEN
	       x_ic_lots_mst_row.retest_date :=
	       x_ic_lots_mst_row.lot_created + NVL(p_ic_item_mst_row.retest_interval,0);
	   END IF;
        ELSE
         x_ic_lots_mst_row.retest_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
        END IF;
     ELSE
      IF TRUNC(p_lot_rec.retest_date) >= TRUNC(x_ic_lots_mst_row.lot_created)
      THEN
	    x_ic_lots_mst_row.retest_date := p_lot_rec.retest_date;
	ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_RETEST_DATE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    /* Validate Expiry Action Date */

    IF NVL(p_lot_rec.expaction_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
    THEN
        -- Bug 3621870
        -- Check if its a grade controlled item.
        -- Assign max date to expaction date for non grade ctl items.
	-- Jatinder Gogna - 3470841 - Compute only if lot_created is specified.
	IF p_ic_item_mst_row.grade_ctl = 1 OR
           (p_ic_item_mst_row.grade_ctl = 0 AND p_ic_item_mst_row.expaction_interval <> 0) THEN
 	   IF p_lot_rec.lot_created is not NULL THEN
	      x_ic_lots_mst_row.expaction_date :=
	      x_ic_lots_mst_row.expire_date + NVL(p_ic_item_mst_row.expaction_interval,0);
	    END IF;
        ELSE
	  x_ic_lots_mst_row.expaction_date := GMA_GLOBAL_GRP.SY$MAX_DATE;
        END IF;
    ELSE
      -- BEGIN BUG#3115930 James Bernard
      -- Modified code so that user is now allowed to create expired lots.
      -- However a message is logged.
      x_ic_lots_mst_row.expaction_date := p_lot_rec.expaction_date;
      IF TRUNC(p_lot_rec.expaction_date) < TRUNC(x_ic_lots_mst_row.lot_created) THEN
	     FND_MESSAGE.SET_NAME('GMI','IC_API_PAST_EXPACTION_DATE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
        FND_MSG_PUB.Add;
      END IF;
      -- END BUG#3115930
    END IF;

    /* Validate Strength */
    IF p_lot_rec.strength BETWEEN 0 AND 100
    THEN
	x_ic_lots_mst_row.strength := p_lot_rec.strength;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_STRENGTH');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /* Validate Inactive Indicator */
    IF p_lot_rec.inactive_ind IN (0,1)
    THEN
	x_ic_lots_mst_row.inactive_ind := p_lot_rec.inactive_ind;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_INACTIVE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /* Validate Origination Type */

    IF p_lot_rec.origination_type IN (0,1,2,3)
    THEN
      x_ic_lots_mst_row.origination_type := p_lot_rec.origination_type;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_ORIG_TYPE');
      FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
      FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
      FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    /* Validate Shipvendor Number */
    IF NVL(p_lot_rec.shipvendor_no, ' ') = ' '
	 THEN
	 	x_ic_lots_mst_row.shipvend_id := NULL;
    ELSE
      IF GMIGUTL.v_ship_vendor(p_lot_rec.shipvendor_no,l_po_vend_mst_row)
      THEN
	  		x_ic_lots_mst_row.shipvend_id:= l_po_vend_mst_row.vendor_id;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INV_LOT_SHIPVENDOR_NO');
        FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_no);
        FND_MESSAGE.SET_TOKEN('LOT_NO', l_lot_no);
        FND_MESSAGE.SET_TOKEN('SUBLOT_NO', l_sublot_no);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;


    /* Jatinder - B3158806- Moved this out of CPG block as this is a standard
       OPM field now. */
    /* Validate Hold release date (CPG) */
    IF NVL(p_lot_rec.ic_hold_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
    THEN
        /* Jalaj Srivastava Bug 3158806
           hold release date would be populated by the first yielding transaction
           for non CPG installs */
	IF p_ic_item_cpg_row.ic_hold_days is not NULL and GMIGUTL.SY$CPG_INSTALL <> 0 THEN
		x_ic_lots_cpg_row.ic_hold_date :=
			x_ic_lots_mst_row.lot_created +
			p_ic_item_cpg_row.ic_hold_days;
	END IF;
    ELSE
      IF (p_lot_rec.ic_hold_date < x_ic_lots_mst_row.lot_created)
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_HOLD_DATE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      /* Jalaj Srivastava Bug 3158806
         Assign hold release date when passed by the user*/
      x_ic_lots_cpg_row.ic_hold_date := p_lot_rec.ic_hold_date;
    END IF;

    IF GMIGUTL.SY$CPG_INSTALL <> 0
    THEN
      /* Validate Maturity date (CPG) */
      IF NVL(p_lot_rec.ic_matr_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE
      THEN
        x_ic_lots_cpg_row.ic_matr_date :=
          x_ic_lots_mst_row.creation_date + NVL(p_ic_item_cpg_row.ic_matr_days, 0);
      ELSE
        IF (p_lot_rec.ic_matr_date < x_ic_lots_mst_row.lot_created)
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_MATR_DATE');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',l_item_no);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;
  END IF;

  FND_MSG_PUB.Count_AND_GET
    (p_count => x_msg_count, p_data => x_msg_data);

  --Jalaj Srivastava Bug 2811747
  --commented out below.
  --this is not needed
  --it raises a error for debug/informative messages in the global message table
  --from calling procedures.
  --we would instead set the error status individually for error cases.
  /* ***********************************************************************
  IF x_msg_count > 0
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  ************************************************************************** */

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

END GMIVLOT;

/
