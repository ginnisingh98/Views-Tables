--------------------------------------------------------
--  DDL for Package Body GMI_VALIDATE_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_VALIDATE_ALLOCATION_PVT" AS
/*  $Header: GMIVALVB.pls 115.8 2002/11/06 21:59:53 hwahdani ship $  */

/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_VALIDATE_ALLOCATION_PVT';


/*  Proc start of comments
 +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Validate_Input_Parameters                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Used to ensure that mandatory input parameters have been supplied    |
 |                                                                         |
 | PARAMETERS                                                              |
 |  p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec      |
 |  x_ic_item_mst_rec    OUT ic_item_mst%ROWTYPE                           |
 |  x_ic_whse_mst_rec    OUT ic_whse_mst%ROWTYPE                           |
 |  x_allocation_rec     OUT GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec      |
 |  x_return_status      OUT VARCHAR2                                      |
 |  x_msg_count          OUT NUMBER                                        |
 |  x_msg_data           OUT VARCHAR2                                      |
 |                                                                         |
 | HISTORY                                                                 |
 |    15-DEC-1999      K.Y.Hunt      Created                               |
 +=========================================================================+
  Proc end of comments
*/
PROCEDURE VALIDATE_INPUT_PARMS
( p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, x_ic_item_mst_rec    OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_whse_mst_rec    OUT NOCOPY ic_whse_mst%ROWTYPE
, x_allocation_rec     OUT NOCOPY GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name           CONSTANT VARCHAR2 (30) := 'VALIDATE_INPUT_PARMS';
l_user_id            FND_USER.USER_ID%TYPE;
l_msg_count          NUMBER  :=0;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1);

CURSOR ic_item_mst_c1 IS
SELECT *
FROM
  ic_item_mst
WHERE
    item_no     = p_allocation_rec.item_no;


CURSOR ic_whse_mst_c1 IS
SELECT *
FROM
  ic_whse_mst
WHERE
    whse_code   = p_allocation_rec.whse_code and delete_mark=0;
BEGIN

  /*Initialize API return status to sucess
  =======================================*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Move input rec to local variable
  ==================================*/
  x_allocation_rec := p_allocation_rec;

  /*Check user
  ===========*/
  l_user_id := p_allocation_rec.user_id;

  /*Either ID or NAME must be supplied.  If both are blank then error.
  ===================================================================*/
  IF NOT GMI_VALIDATE_ALLOCATION_PVT.Validate_who(p_allocation_rec.user_id
                                                 ,p_allocation_rec.user_name)
  THEN
    oe_debug_pub.add('OPM ALLOCATION - Validation fail on user',1);
    FND_MESSAGE.SET_NAME('GML','GML_USER_ID_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*If USER_ID not supplied, retrieve it
  =====================================*/
  /* NC - 11/13/01 user_id 0 is a valid one( for sysadmin) . Removing the OR condition. */
  IF (p_allocation_rec.user_id IS NULL )
  THEN
    GMA_GLOBAL_GRP.Get_who( p_user_name  => p_allocation_rec.user_name
                          , x_user_id    => l_user_id
                          );

    --IF l_user_id = 0   /* 0 user_id is a valid value */

    IF l_user_id is NULL
    THEN
      FND_MESSAGE.SET_NAME('GMI','SY_API_INVALID_USER_NAME');
      FND_MESSAGE.SET_TOKEN('USER_NAME',p_allocation_rec.user_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_user_id := p_allocation_rec.user_id;
  END IF;

  x_allocation_rec.user_id := l_user_id;

  /* Check doc_id
  ==============*/
/* dbms_output.put_line('Now do doc_id'); */
  IF (p_allocation_rec.doc_id IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - Validation fail on doc id',1);
    FND_MESSAGE.SET_NAME('GML','GML_DOC_ID_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Check line_id
  ===============*/
/* dbms_output.put_line('Now check line_id'); */
  IF (p_allocation_rec.line_id IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - Validation fail on line id',1);
    FND_MESSAGE.SET_NAME('GML','GML_LINE_ID_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Check item_no
  ===============*/
  IF (p_allocation_rec.item_no = ' ' OR p_allocation_rec.item_no IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - Validation fail on item',1);
    FND_MESSAGE.SET_NAME('GML','SO_E_ITM_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Retrieve item attributes
  ==========================*/
  OPEN ic_item_mst_c1;
  FETCH ic_item_mst_c1 INTO x_ic_item_mst_rec;
  IF (ic_item_mst_c1%NOTFOUND)
  THEN
    CLOSE ic_item_mst_c1;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    CLOSE ic_item_mst_c1;
  END IF;

  /*If errors found, then raise exception
  ======================================*/
  IF (x_ic_item_mst_rec.item_id = 0) OR
        (x_ic_item_mst_rec.delete_mark = 1)
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_ic_item_mst_rec.noninv_ind = 1)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - noninv item',1);
    FND_MESSAGE.SET_NAME('GMI','IC_API_NONINV_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_ic_item_mst_rec.inactive_ind = 1)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - inactive item',1);
    FND_MESSAGE.SET_NAME('GMI','IC_API_INACTIVE_ITEM_NO');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_ic_item_mst_rec.alloc_class IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing allocation class',1);
    FND_MESSAGE.SET_NAME('GML','GML_API_MISSING_ALLOC_CLASS');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  /* Check whse_code
  =================*/
  IF (p_allocation_rec.whse_code = ' ' OR p_allocation_rec.whse_code IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing whse code',1);
    FND_MESSAGE.SET_NAME('GML','SO_E_WHSE_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*Retrieve warehouse attributes
  ==============================*/
  OPEN ic_whse_mst_c1;
  FETCH ic_whse_mst_c1 INTO x_ic_whse_mst_rec;
  IF (ic_whse_mst_c1%NOTFOUND)
  THEN
    CLOSE ic_whse_mst_c1;
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_CODE');
    FND_MESSAGE.SET_TOKEN('WHSE_CODE', p_allocation_rec.whse_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE ic_whse_mst_c1;
  END IF;

/*  Check co_code    */
  IF (p_allocation_rec.co_code = ' ' OR p_allocation_rec.co_code IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing CO CODE',1);
    FND_MESSAGE.SET_NAME('GML','GML_CO_CODE_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  not needed for bug 2245351 Check cust_no */
  /*IF (p_allocation_rec.cust_no = ' ' OR p_allocation_rec.cust_no IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing CUST NO',1);
    FND_MESSAGE.SET_NAME('GML','SO_E_CUST_NO_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;                                                                       */

/*  Check order_qty   */
  IF (p_allocation_rec.order_qty1 <= 0 OR p_allocation_rec.order_qty1 IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing order qty',1);
    FND_MESSAGE.SET_NAME('GML','PO_NONZERO_VAL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check order_qty2 */
  IF x_ic_item_mst_rec.dualum_ind in (1,2,3) AND
     (p_allocation_rec.order_qty2 <= 0 OR p_allocation_rec.order_qty2 IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing order qty2',1);
    FND_MESSAGE.SET_NAME('GML','GML_ORDER_QTY2_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check order_um1 */
  IF (p_allocation_rec.order_um1 = ' ' OR p_allocation_rec.order_um1 IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing order UM',1);
    FND_MESSAGE.SET_NAME('GML','SO_E_UOM1_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check order_um2   */
  IF x_ic_item_mst_rec.dualum_ind in (1,2,3) AND
     (p_allocation_rec.order_um2 = ' '  OR p_allocation_rec.order_um2 IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing order UM2',1);
    FND_MESSAGE.SET_NAME('GML','GML_ORDER_UM2_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_allocation_rec.item_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

/*  Check Trans_date   */
  IF (p_allocation_rec.trans_date IS NULL)
  THEN
    oe_debug_pub.add('KYH ALLOCATION - missing trans date',1);
    FND_MESSAGE.SET_NAME('GML','SO_E_DATE_REQUIRED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


/*  Validation OK */
  RETURN;

/*  Exception Handling */

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
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );
      FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                                 , p_data  =>  x_msg_data
                                );

END Validate_Input_Parms;

/*  Func start of comments
 +==========================================================================+
 |  FUNCTION NAME                                                           |
 |       Validate_who                                                       |
 |  USAGE                                                                   |
 |       Ensure that a user identifier has been supplied.                   |
 |       This can be either the user_name OR user_id.                       |
 |  DESCRIPTION                                                             |
 |       This function validates that one of the 2 parameters has a         |
 |       value.                                                             |
 |                                                                          |
 |  PARAMETERS                                                              |
 |       p_user_id    IN User Identifier                                    |
 |       p_user_name  IN User Name                                          |
 |  RETURNS                                                                 |
 |       TRUE  - If one or both parameters supplied                         |
 |       FALSE - If both parameters are empty                               |
 |                                                                          |
 |  HISTORY                                                                 |
 |       04/JAN/2000   Karen Hunt                                           |
 |                                                                          |
 +==========================================================================+
  Func end of comments
*/
FUNCTION Validate_who
( p_user_id     IN FND_USER.USER_ID%TYPE
, p_user_name   IN FND_USER.USER_NAME%TYPE
)
RETURN BOOLEAN
IS
BEGIN

/* dbms_output.put_line('This is validate who'); */
  IF (p_user_id IS NULL) AND
     (p_user_name = ' ' OR p_user_name IS NULL)
  THEN
/*    dbms_output.put_line('Return FALSE'); */
     RETURN FALSE;
  ELSE
/*    dbms_output.put_line('Return TRUE'); */
     RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Validate_who;

END GMI_VALIDATE_ALLOCATION_PVT;

/
