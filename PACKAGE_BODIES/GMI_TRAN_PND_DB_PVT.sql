--------------------------------------------------------
--  DDL for Package Body GMI_TRAN_PND_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_TRAN_PND_DB_PVT" AS
/*  $Header: GMIVPNDB.pls 115.12 2004/04/16 05:29:31 mkalyani ship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVPNDB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_TRAN_PND                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     24-AUG-2001  NC Added line_detail_id.BUG#1675561                    |
 |     Piyush K. Mishra 6-Jun-2002 Bug#2385934                             |
 |     Commented the line that updates the creation_date in the procedure  |
 |     update_ic_tran_pnd as the creation date should not change during    |
 |     updation.                                                           |
 |     30-OCT-2002  J.DiIorio Bug#2643440 11.5.1J - added nocopy and       |
 |                  changed out to in out.                                 |
 |     15_AUG-2003  J.DiIorio Bug#3090255 11.5.10L                         |
 |                  Added field intorder_posted_ind.                       |
 |     2-APR-2004   V.Anitha  BUG#3526733                                  |
 |                  Added code to insert reverse_id into IC_TRAN_PND table |
 |     14-APR-2004  V.Anita   BUG#3526733                                  |
 |                  Modified the value passed to the reverse_id from       |
 |                  p_tran_row.tran_id to p_tran_row.reverse_id when       |
 |                  inserting into IC_TRAN_PND table.                      |
 +=========================================================================+
  API Name  : GMI_TRAN_PND_DB_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_TRAN_PND transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

  Body end of comments
*/
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_TRAN_PND_DB_PVT';
/*  Api start of comments */


FUNCTION INSERT_IC_TRAN_PND
(
  p_tran_row         IN   IC_TRAN_PND%ROWTYPE,
  x_tran_row         IN OUT NOCOPY IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN
IS
err_num     NUMBER;
err_msg     VARCHAR2(100);
l_trans_id  NUMBER;

CURSOR C ( v_trans_id IN NUMBER) IS
SELECT trans_id FROM IC_TRAN_PND
WHERE trans_id = v_trans_id;


BEGIN

  SELECT gem5_trans_id_s.nextval
  INTO   l_trans_id FROM dual;

  INSERT INTO IC_TRAN_PND
  (
    trans_id
  , item_id
  , line_id
  , co_code
  , orgn_code
  , whse_code
  , lot_id
  , location
  , doc_id
  , doc_type
  , doc_line
  , line_type
  , reason_code
  , creation_date
  , trans_date
  , trans_qty
  , trans_qty2
  , qc_grade
  , lot_status
  , trans_stat
  , trans_um
  , trans_um2
  , op_code
  , gl_posted_ind
  , completed_ind
  , delete_mark
  , event_id
  , staged_ind
  , text_code
  , last_update_date
  , created_by
  , last_updated_by
  , line_detail_id
  , intorder_posted_ind
  , reverse_id  --BUG#3526733
  )
  VALUES
  ( l_trans_id
  , p_tran_row.item_id
  , p_tran_row.line_id
  , p_tran_row.co_code
  , p_tran_row.orgn_code
  , p_tran_row.whse_code
  , p_tran_row.lot_id
  , p_tran_row.location
  , p_tran_row.doc_id
  , p_tran_row.doc_type
  , p_tran_row.doc_line
  , p_tran_row.line_type
  , p_tran_row.reason_code
  , p_tran_row.creation_date
  , p_tran_row.trans_date
  , p_tran_row.trans_qty
  , p_tran_row.trans_qty2
  , p_tran_row.qc_grade
  , p_tran_row.lot_status
  , p_tran_row.trans_stat
  , p_tran_row.trans_um
  , p_tran_row.trans_um2
  , p_tran_row.op_code
  , p_tran_row.gl_posted_ind
  , p_tran_row.completed_ind
  , p_tran_row.delete_mark
  , p_tran_row.event_id
  , p_tran_row.staged_ind
  , p_tran_row.text_code
  , p_tran_row.last_update_date
  , p_tran_row.created_by
  , p_tran_row.last_updated_by
  , p_tran_row.line_detail_id
  , p_tran_row.intorder_posted_ind
  , p_tran_row.reverse_id  --BUG#3526733
 );

 OPEN C(l_trans_id);
 FETCH C into l_trans_id;

  IF (C%NOTFOUND) THEN
	CLOSE C;
	RAISE NO_DATA_FOUND;
  END IF;

 CLOSE C;

x_tran_row := p_tran_row;
x_tran_row.trans_id := l_trans_id;
  RETURN TRUE;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
	  RETURN FALSE;

    WHEN OTHERS THEN

       FND_MESSAGE.Set_Name('GMI','GMI_SQL_ERROR');
	  FND_MESSAGE.Set_Token('SQL_CODE', err_num);
	  FND_MESSAGE.Set_Token('SQL_ERRM', sqlerrm);
	  FND_MSG_PUB.Add;


    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_tran_pnd'
                            );
    RETURN FALSE;

END INSERT_IC_TRAN_PND;

FUNCTION FETCH_IC_TRAN_PND
(
  p_tran_rec             IN  GMI_TRANS_ENGINE_PUB.ictran_rec
 ,x_tran_fetch_rec  	 IN OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);

BEGIN

IF ( ( p_tran_rec.trans_id =FND_API.G_MISS_NUM  ) OR
     ( p_tran_rec.trans_id is NULL ) ) THEN

   /*  Select by item_id, doc_type, line_id,lot_id , location */

SELECT
    trans_id
  , item_id
  , line_id
  , co_code
  , orgn_code
  , whse_code
  , lot_id
  , location
  , doc_id
  , doc_type
  , doc_line
  , line_type
  , reason_code
  , trans_date
  , trans_qty
  , trans_qty2
  , qc_grade
  , lot_status
  , trans_stat
  , trans_um
  , trans_um2
  , event_id
  , staged_ind
  , text_code
  , op_code
  , line_detail_id
  , intorder_posted_ind
INTO
    x_tran_fetch_rec.trans_id
  , x_tran_fetch_rec.item_id
  , x_tran_fetch_rec.line_id
  , x_tran_fetch_rec.co_code
  , x_tran_fetch_rec.orgn_code
  , x_tran_fetch_rec.whse_code
  , x_tran_fetch_rec.lot_id
  , x_tran_fetch_rec.location
  , x_tran_fetch_rec.doc_id
  , x_tran_fetch_rec.doc_type
  , x_tran_fetch_rec.doc_line
  , x_tran_fetch_rec.line_type
  , x_tran_fetch_rec.reason_code
  , x_tran_fetch_rec.trans_date
  , x_tran_fetch_rec.trans_qty
  , x_tran_fetch_rec.trans_qty2
  , x_tran_fetch_rec.qc_grade
  , x_tran_fetch_rec.lot_status
  , x_tran_fetch_rec.trans_stat
  , x_tran_fetch_rec.trans_um
  , x_tran_fetch_rec.trans_um2
  , x_tran_fetch_rec.event_id
  , x_tran_fetch_rec.staged_ind
  , x_tran_fetch_rec.text_code
  , x_tran_fetch_rec.user_id
  , x_tran_fetch_rec.line_detail_id
  , x_tran_fetch_rec.intorder_posted_ind
FROM IC_TRAN_PND
WHERE
    doc_type     = p_tran_rec.doc_type
AND doc_id       = p_tran_rec.doc_id
AND line_id      = p_tran_rec.line_id
AND item_id      = p_tran_rec.item_id
AND lot_id       = p_tran_rec.lot_id
AND location     = p_tran_rec.location
AND completed_ind= 0
AND delete_mark  = 0
FOR UPDATE NOWAIT;

ELSE

SELECT
    trans_id
  , item_id
  , line_id
  , co_code
  , orgn_code
  , whse_code
  , lot_id
  , location
  , doc_id
  , doc_type
  , doc_line
  , line_type
  , reason_code
  , trans_date
  , trans_qty
  , trans_qty2
  , qc_grade
  , lot_status
  , trans_stat
  , trans_um
  , trans_um2
  , event_id
  , staged_ind
  , text_code
  , op_code
  , line_detail_id
  , intorder_posted_ind
INTO
    x_tran_fetch_rec.trans_id
  , x_tran_fetch_rec.item_id
  , x_tran_fetch_rec.line_id
  , x_tran_fetch_rec.co_code
  , x_tran_fetch_rec.orgn_code
  , x_tran_fetch_rec.whse_code
  , x_tran_fetch_rec.lot_id
  , x_tran_fetch_rec.location
  , x_tran_fetch_rec.doc_id
  , x_tran_fetch_rec.doc_type
  , x_tran_fetch_rec.doc_line
  , x_tran_fetch_rec.line_type
  , x_tran_fetch_rec.reason_code
  , x_tran_fetch_rec.trans_date
  , x_tran_fetch_rec.trans_qty
  , x_tran_fetch_rec.trans_qty2
  , x_tran_fetch_rec.qc_grade
  , x_tran_fetch_rec.lot_status
  , x_tran_fetch_rec.trans_stat
  , x_tran_fetch_rec.trans_um
  , x_tran_fetch_rec.trans_um2
  , x_tran_fetch_rec.event_id
  , x_tran_fetch_rec.staged_ind
  , x_tran_fetch_rec.text_code
  , x_tran_fetch_rec.user_id
  , x_tran_fetch_rec.line_detail_id
  , x_tran_fetch_rec.intorder_posted_ind
FROM IC_TRAN_PND
WHERE
    trans_id     = p_tran_rec.trans_id
AND delete_mark  =0
FOR UPDATE NOWAIT;

END IF;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
 ELSE
     RETURN TRUE;
 END IF;


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

    RETURN FALSE;

    WHEN OTHERS THEN


    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'fetch_ic_tran_pnd'
                            );
    RETURN FALSE;

END FETCH_IC_TRAN_PND;

FUNCTION DELETE_IC_TRAN_PND
(
  p_tran_row         IN  IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);

BEGIN

UPDATE IC_TRAN_PND
SET    delete_mark         = 1,
       event_id            = p_tran_row.event_id,
       last_update_date    = p_tran_row.last_update_date,
       last_updated_by     = p_tran_row.last_updated_by
WHERE  trans_id            = p_tran_row.trans_id;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
 ELSE
     RETURN TRUE;
 END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

    WHEN OTHERS THEN


    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'delete_ic_tran_pnd'
                            );
    RETURN FALSE;

END DELETE_IC_TRAN_PND;

FUNCTION UPDATE_IC_TRAN_PND
(
  p_tran_row         IN  IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);

BEGIN

  UPDATE IC_TRAN_PND
  SET
  item_id     		= p_tran_row.item_id,
  line_id     		= p_tran_row.line_id,
  co_code     		= p_tran_row.co_code,
  orgn_code   		= p_tran_row.orgn_code,
  whse_code   		= p_tran_row.whse_code,
  lot_id      		= p_tran_row.lot_id,
  location    		= p_tran_row.location,
  doc_id      		= p_tran_row.doc_id,
  doc_type    		= p_tran_row.doc_type,
  doc_line    		= p_tran_row.doc_line,
  line_type   		= p_tran_row.line_type,
  reason_code 		= p_tran_row.reason_code,
  --Begin Bug#2385934 Piyush K. Mishra.
  --Commented the creation_date as updation of creation_date should not be done.
  --creation_date         = p_tran_row.creation_date,
  --End Bug#2385934
  trans_date            = p_tran_row.trans_date,
  trans_qty             = p_tran_row.trans_qty,
  trans_qty2            = p_tran_row.trans_qty2,
  qc_grade              = p_tran_row.qc_grade,
  lot_status            = p_tran_row.lot_status,
  trans_stat            = p_tran_row.trans_stat,
  trans_um              = p_tran_row.trans_um,
  trans_um2             = p_tran_row.trans_um2,
  gl_posted_ind         = p_tran_row.gl_posted_ind,
  completed_ind         = p_tran_row.completed_ind,
  delete_mark           = p_tran_row.delete_mark,
  event_id              = p_tran_row.event_id,
  staged_ind            = p_tran_row.staged_ind,
  text_code             = p_tran_row.text_code,
  last_update_date      = p_tran_row.last_update_date,
  last_updated_by       = p_tran_row.last_updated_by,
  op_code               = p_tran_row.op_code,
  line_detail_id        = p_tran_row.line_detail_id,
  intorder_posted_ind   = p_tran_row.intorder_posted_ind
  WHERE trans_id = p_tran_row.trans_id;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
 ELSE
     RETURN TRUE;
 END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

    WHEN OTHERS THEN

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'UPDATE_ic_tran_pnd'
                            );
    RETURN FALSE;

END UPDATE_IC_TRAN_PND;

END GMI_TRAN_PND_DB_PVT;

/
