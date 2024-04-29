--------------------------------------------------------
--  DDL for Package GMI_TRANS_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_TRANS_ENGINE_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPTXNS.pls 115.15 2004/04/16 05:26:56 mkalyani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIPTXNS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions For creation of            |
 |     inventory Transcations For IC_TRAN_PND                              |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     26_May-2000  Support for ic_tran_cmp added                          |
 |     15-Jul-2001  Support for adding completed txns to ic_tran_pnd added |
 |     25-AUG-2001  NC added line_detail_id in the ictran_rec record def.  |
 |		    BUG#1675561
 |     29-Oct-2002  J. DiIorio Bug#2643440 11.5.1J - added nocopy.         |
 |     14-Aug-2003  J. DiIorio Bug#3090255 11.5.10L                        |
 |                  Added field intorder_posted_ind.                       |
 |     14-APR-2004  V.Anitha   BUG#3526733                                 |
 |                  Added reverse_id column to the Record ictran_rec.      |
 +=========================================================================+
  API Name  : GMI_TRANS_ENGINE_PUB
  Type      : Public
  Function  : This package contains public procedures used to create
              inventory transactions.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

/*  Create Record definition For Transaction
  API specific parameters to be presented in SQL RECORD format
*/
/*  A record type Definition Of A Transaction */

TYPE ictran_rec is RECORD
( trans_id          IC_TRAN_PND.TRANS_ID%TYPE
, item_id           IC_ITEM_MST.ITEM_ID%TYPE
, line_id           IC_TRAN_PND.LINE_ID%TYPE
, co_code           IC_TRAN_PND.CO_CODE%TYPE
, orgn_code         IC_TRAN_PND.ORGN_CODE%TYPE
, whse_code         IC_TRAN_PND.WHSE_CODE%TYPE
, lot_id            IC_LOTS_MST.ITEM_ID%TYPE
, location          IC_LOCT_MST.LOCATION%TYPE
, doc_id            IC_TRAN_PND.DOC_ID%TYPE
, doc_type          SY_DOCS_MST.DOC_TYPE%TYPE
, doc_line          IC_TRAN_PND.DOC_LINE%TYPE
, line_type         IC_TRAN_PND.LINE_TYPE%TYPE
, reason_code       SY_REAS_CDS.REASON_CODE%TYPE
, trans_date        IC_TRAN_PND.TRANS_DATE%TYPE
, trans_qty         IC_TRAN_PND.TRANS_QTY%TYPE
, trans_qty2        IC_TRAN_PND.TRANS_QTY%TYPE
, qc_grade          QC_GRAD_MST.QC_GRADE%TYPE
, lot_no            IC_LOTS_MST.LOT_NO%TYPE
, sublot_no         IC_LOTS_MST.SUBLOT_NO%TYPE
, lot_status        IC_LOTS_STS.LOT_STATUS%TYPE
, trans_stat        IC_TRAN_PND.TRANS_STAT%TYPE
, trans_um          IC_TRAN_PND.TRANS_UM%TYPE
, trans_um2         IC_TRAN_PND.TRANS_UM2%TYPE
, staged_ind        IC_TRAN_PND.staged_ind%TYPE
, event_id          IC_TRAN_PND.event_id%TYPE
, text_code         IC_TRAN_PND.TEXT_CODE%TYPE
, user_id           FND_USER.USER_ID%TYPE
, create_lot_index  NUMBER
, non_inv           NUMBER
, line_detail_id    NUMBER
, intorder_posted_ind IC_TRAN_PND.INTORDER_POSTED_IND%TYPE
, reverse_id        IC_TRAN_PND.REVERSE_ID%TYPE   --BUG#3526733
);

/*   Define Procedures And Functions :   */


PROCEDURE CREATE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
/* , x_tran_rec         OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec_out  */
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);


PROCEDURE CREATE_COMPLETED_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_CMP%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_table_name         IN  VARCHAR2        DEFAULT 'IC_TRAN_CMP'
);


PROCEDURE DELETE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
/* , x_tran_rec           OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec_out  */
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
/* , x_tran_rec           OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec_out  */
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);


/* - For This Version Put Completed In Same File
*/

PROCEDURE UPDATE_PENDING_TO_COMPLETED
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
/* , x_tran_rec           OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec_out  */
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);


FUNCTION  check_missing
(
 p_tran_rec             IN GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN;

END GMI_TRANS_ENGINE_PUB;

 

/
