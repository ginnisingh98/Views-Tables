--------------------------------------------------------
--  DDL for Package Body GMI_TRAN_CMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_TRAN_CMP_PVT" AS
/* $Header: GMIVCMPB.pls 115.15 2003/09/09 18:04:47 jdiiorio ship $ */
/* 24-AUG-01 NC Added line_detail_id in INSERT and FETCH BUG#1675561*/
/* 29-OCT-02 Joe DiIorio Bug#2643440 11.5.1J - added nocopy.        */
/* 15-AUG-03 Joe DiIorio Bug#3090255 11.5.10L         */
/* Added field intorder_posted_ind.                   */
/*  Body end of comments */
/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_TRAN_CMP_PVT';
/*  Api start of comments */


FUNCTION INSERT_IC_TRAN_CMP
(
  p_tran_row         IN   IC_TRAN_CMP%ROWTYPE,
  x_tran_row         OUT  NOCOPY IC_TRAN_CMP%ROWTYPE
)
RETURN BOOLEAN
IS
err_num NUMBER;
err_msg VARCHAR2(100);
l_trans_id  NUMBER;
BEGIN

  SELECT gem5_trans_id_s.nextval
  INTO   l_trans_id FROM dual;

  INSERT INTO IC_TRAN_CMP
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
  , event_id
  , text_code
  , last_update_date
  , created_by
  , last_updated_by
  , line_detail_id
  , intorder_posted_ind
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
  , p_tran_row.event_id
  , p_tran_row.text_code
  , p_tran_row.last_update_date
  , p_tran_row.created_by
  , p_tran_row.last_updated_by
  , p_tran_row.line_detail_id
  , p_tran_row.intorder_posted_ind
 );

/*  dbms_output.put_line(' INSERT IC_TRAN_CMP SUCCESSFUL'); */
x_tran_row := p_tran_row;
x_tran_row.trans_id := l_trans_id;
  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN

    err_num :=SQLCODE;
    err_msg :=SUBSTR(SQLERRM,1 ,100);

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'insert_ic_tran_cmp'
                            );
    RETURN FALSE;

END INSERT_IC_TRAN_CMP;

FUNCTION FETCH_IC_TRAN_CMP
(
  p_tran_rec             IN  GMI_TRANS_ENGINE_PUB.ictran_rec
 ,x_tran_fetch_rec  	 OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
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
  , x_tran_fetch_rec.text_code
  , x_tran_fetch_rec.user_id
  , x_tran_fetch_rec.line_detail_id
  , x_tran_fetch_rec.intorder_posted_ind
FROM IC_TRAN_CMP
WHERE
    doc_type     = p_tran_rec.doc_type
AND doc_id       = p_tran_rec.doc_id
AND line_id      = p_tran_rec.line_id
AND item_id      = p_tran_rec.item_id
AND lot_id       = p_tran_rec.lot_id
AND location     = p_tran_rec.location ;

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
  , x_tran_fetch_rec.text_code
  , x_tran_fetch_rec.user_id
  , x_tran_fetch_rec.line_detail_id
  , x_tran_fetch_rec.intorder_posted_ind
FROM IC_TRAN_CMP
WHERE
    trans_id     = p_tran_rec.trans_id;

END IF;

/* dbms_output.put_line(' FETCH IC_TRAN_CMP SUCCESSFUL'); */
  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN

    err_num :=SQLCODE;
    err_msg :=SUBSTR(SQLERRM,1 ,100);

    FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                             , 'fetch_ic_tran_pnd'
                            );
    RETURN FALSE;

END FETCH_IC_TRAN_CMP;


END GMI_TRAN_CMP_PVT;

/
