--------------------------------------------------------
--  DDL for Package Body GML_MLT_CNTR_RCPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_MLT_CNTR_RCPT" AS
/* $Header: GMLMTCRB.pls 115.3 2004/06/18 17:08:01 pupakare noship $*/

 /*+========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMLMTCRB.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GML_MLT_CNTR_RCPT                                                     |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package procedure is use to create new lots depending on the     |
 |    parameters passed and returns the new lots in the plsql table back to |
 |    RCVGMLCR.pld which then populates the LOT ENTRY screen with all the   |
 |    lots.
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_Lots                                                           |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Preetam Bamb 07/28/2003                                     |
 |                                                                          |
 +==========================================================================+
  Body end of comments*/


 /*==========================================================================+
 | FUNCTION NAME                                                            |
 |    check_if_lot_exists                                                   |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Check if the lot/sublot suggested by the auto lot routine already     |
 |    exists in the database. If yes then return 1 else return 0            |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    NUMBER - 1 - Lot already exists for that item in the database.        |
 |             0 - Lot does not exist in the database.                      |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  - Preetam Bamb 7/28/2003 Bug# 3033780 11.5.1L and ahead       |
 +==========================================================================+
  Api end of comments*/

FUNCTION check_if_lot_exists(p_f_item_id                IN   NUMBER,
                             p_f_lot_no                 IN   VARCHAR2,
                             p_f_sublot_no              IN   VARCHAR2)
   RETURN NUMBER IS

  CURSOR GET_LOT_MASTER IS
    SELECT lot_id
    FROM ic_lots_mst
    WHERE item_id = p_f_item_id AND
          lot_no = p_f_lot_no AND
          sublot_no = p_f_sublot_no;

  CURSOR GET_LOT_MASTER2 IS
    SELECT lot_id
    FROM ic_lots_mst
    WHERE item_id = p_f_item_id AND
          lot_no = p_f_lot_no;

w_lot_id        number := 0;

BEGIN
   IF (p_f_sublot_no IS NULL) THEN
      OPEN GET_LOT_MASTER2;
      FETCH GET_LOT_MASTER2 INTO w_lot_id;
      IF GET_LOT_MASTER2%NOTFOUND THEN
         CLOSE GET_LOT_MASTER2;
         RETURN 0;
      ELSE
         CLOSE GET_LOT_MASTER2;
         RETURN 1;
      END IF;
   ELSE
      OPEN GET_LOT_MASTER;
      FETCH GET_LOT_MASTER INTO w_lot_id;
      IF GET_LOT_MASTER%NOTFOUND THEN
         CLOSE GET_LOT_MASTER;
         RETURN 0;
      ELSE
         CLOSE GET_LOT_MASTER;
         RETURN 1;
      END IF;
   END IF;


END check_if_lot_exists;

 /*==========================================================================+
 | FUNCTION NAME                                                           |
 |    Create_lots                                                           |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |    Create lots and lot specific conversion                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |                                                                          |
 |                                                                          |
 | RETURNS                                                                  |
 |    VARCHAR2 - 'S' All records processed successfully                     |
 |               'E' 1 or more records errored                              |
 |               'U' 1 or more record unexpected error                      |
 |    PLSQL table of Lots.                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |   Created  - Preetam Bamb 7/28/2003 Bug# 3033780 11.5.1L and ahead       |
 +==========================================================================+
  Api end of comments*/

FUNCTION  Create_Lots
( p_item_id          IN NUMBER
, p_lot_no           IN VARCHAR2
, p_no_of_lots       IN NUMBER
, p_no_of_sublots    IN NUMBER
, p_expire_date      IN DATE
, p_lot_spec_conv    IN VARCHAR2
, p_primary_uom      IN VARCHAR2
, p_primary_qty      IN VARCHAR2
, p_secondary_uom    IN VARCHAR2
, p_secondary_qty    IN VARCHAR2
, p_shipvend_id	     IN NUMBER
, p_vendor_lot_no    IN VARCHAR2
, x_lot_table        IN OUT NOCOPY lot_table
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
) RETURN VARCHAR2

IS

/*
  Local variables
*/

l_status             VARCHAR2(1);
l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_count              NUMBER  ;
l_loop_cnt           NUMBER  ;
l_no_of_lots         NUMBER  := p_no_of_lots;
l_no_of_sublots      NUMBER  := p_no_of_sublots;
l_dummy_cnt          NUMBER  :=0;
l_dummy_cnt1         NUMBER  :=0;
l_record_count       NUMBER  :=0;
l_data               VARCHAR2(2000);

lot_rec              GMIGAPI.lot_rec_typ;

l_lot_no	     VARCHAR2(32) := NULL;
l_sublot_no	     VARCHAR2(32) := NULL;
l_item_no	     VARCHAR2(100);
l_qc_grade	     VARCHAR2(100);

l_ic_lots_mst_row    ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_row    ic_lots_cpg%ROWTYPE;

l_api_version        NUMBER := GMIGUTL.api_version;
l_dummy_lot          VARCHAR2(32);

e_auto_lot_create    EXCEPTION;
e_create_lot	     EXCEPTION;
e_lot_conv_err       EXCEPTION;
l_shipvendor_no	     VARCHAR2(32);
x_found	             NUMBER := 1;

Cursor Cr_item Is
Select 	item_no, qc_grade
From 	ic_item_mst
Where   item_id = p_item_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get item attributes required to create lots.
   Open Cr_item;
   Fetch Cr_item Into l_item_no,l_qc_grade;
   If Cr_item%NOTFOUND Then
      Close Cr_item;
      FND_MESSAGE.SET_NAME('GML','GML_OPM_ITEM_NOT_EXIST');
      FND_MSG_PUB.ADD;
      x_msg_count := 1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN FND_API.G_RET_STS_UNEXP_ERROR;
   End If;
   If Cr_item%ISOPEN Then
      Close Cr_item;
   End If;

   IF (p_shipvend_id) IS NOT NULL THEN
      SELECT vendor_no INTO l_shipvendor_no
      FROM   po_vend_mst
       where  vendor_id = p_shipvend_id;
       IF (SQL%NOTFOUND) THEN
         l_shipvendor_no := NULL;
       END IF;
   END IF;

   --If lot number specified then create sublots for that lot depending on the p_no_of_sublots
   --parameter.
   IF p_lot_no IS NOT NULL THEN

      l_no_of_sublots := p_no_of_sublots;


      IF nvl(l_no_of_sublots,0) > 0 THEN

         l_dummy_cnt := 0;

         --Loop p_no_of_sublots times to get sublots for the specified lot.
         WHILE l_no_of_sublots <> 0
         LOOP

            l_dummy_cnt := l_dummy_cnt + 1;
            l_no_of_sublots := l_no_of_sublots -1;

            -- Check if this combination of Lot/Sublot already exists in the database
            --x_found := 1;    -- 1 means combination in ic_lots_mst exists
            --WHILE (x_found = 1)
            ---LOOP
               gmi_autolot.generate_lot_number(
		              p_item_id      => p_item_id,
		              p_in_lot_no    => p_lot_no,
		              p_orgn_code    => NULL,
		              p_doc_id       => NULL,
		              p_line_id      => NULL,
		              p_doc_type     => 'PORC',
		              p_out_lot_no   => l_lot_no,
		              p_sublot_no    => l_sublot_no,
		              p_return_status => l_return_status );

	       IF l_return_status < 0 THEN
	          RAISE e_auto_lot_create;
	       END IF; --l_return_status < 0

	       -- If not then exit else get the next combination.
	       --x_found := check_if_lot_exists(p_item_id, l_lot_no, l_sublot_no);
               --IF (x_found = 0) THEN
               --   EXIT;
               --END IF;
	    --END LOOP;

	    --Populate the lot record.
	    lot_rec.item_no         := l_item_no;
            lot_rec.lot_no          := l_lot_no;
            lot_rec.sublot_no       := l_sublot_no;
            lot_rec.lot_desc        := NULL;
            lot_rec.qc_grade        := l_qc_grade;
            lot_rec.lot_created     := SYSDATE;

            IF p_expire_date  IS NOT NULL
            THEN
               lot_rec.expire_date  := p_expire_date;
            END IF;

            lot_rec.inactive_ind    := 0; --0 for active.
            lot_rec.origination_type:= 3; --3 for receiving.
            lot_rec.shipvendor_no   := l_shipvendor_no;
            lot_rec.vendor_lot_no   := p_vendor_lot_no;
            lot_rec.ic_matr_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
            lot_rec.ic_hold_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
            lot_rec.user_name       := FND_GLOBAl.USER_NAME;

            IF (GMIGUTL.SETUP(lot_rec.user_name)) THEN
	       GMIPAPI.Create_Lot
	          ( p_api_version    => 3
	          , p_init_msg_list  => FND_API.G_TRUE
	          , p_commit         => FND_API.G_FALSE
	          , p_validation_level => FND_API.G_VALID_LEVEL_FULL
	          , p_lot_rec        =>lot_rec
	          , x_ic_lots_mst_row => l_ic_lots_mst_row
	          , x_ic_lots_cpg_row => l_ic_lots_cpg_row
	          , x_return_status  => l_status
	          , x_msg_count      => l_count
	          , x_msg_data       => l_data
	          );

	       IF (l_status = 'S') THEN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
               ELSE
                  x_return_status := l_status;
                  x_msg_count := l_count;
                  x_msg_data := l_data;
                  RAISE e_create_lot;
               END IF;

            END IF;

            IF p_lot_spec_conv = 'Y' THEN
               PO_GML_DB_COMMON.CREATE_LOT_SPECIFIC_CONVERSION(
					l_item_no,
					l_ic_lots_mst_row.lot_no,
					l_ic_lots_mst_row.sublot_no,
					p_primary_uom,
					p_secondary_uom,
					p_secondary_qty/nvl(p_primary_qty,1),
					l_status,l_data);
               IF l_status IN ('E','U') THEN
                  x_return_status := l_status;
		  x_msg_count := 1;
	          --x_msg_data := l_data;
	          FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
                  FND_MESSAGE.SET_TOKEN('ERROR', l_data);
                  FND_MSG_PUB.ADD;
	          raise e_lot_conv_err;
               END IF;
            END IF;/* IF p_lot_spec_conv = 'Y' */

            x_lot_table(l_dummy_cnt).lot_id := l_ic_lots_mst_row.lot_id;
            x_lot_table(l_dummy_cnt).lot_no := l_ic_lots_mst_row.lot_no;
            x_lot_table(l_dummy_cnt).sublot_no := l_ic_lots_mst_row.sublot_no;
            x_lot_table(l_dummy_cnt).expire_date := l_ic_lots_mst_row.expire_date;

	 END LOOP;
      END IF; /*IF nvl(l_no_of_sublots,0) > 0 */

   ELSIF p_lot_no IS NULL AND p_no_of_lots IS NOT NULL THEN

      l_no_of_lots := p_no_of_lots;
      l_dummy_cnt  := 0;

      WHILE l_no_of_lots <> 0
      LOOP

         l_dummy_cnt := l_dummy_cnt + 1;

         l_no_of_lots    :=l_no_of_lots  -1;

         --x_found := 1;    -- 1 means ic_lots_mst exists
         --WHILE (x_found = 1)
         --LOOP
            gmi_autolot.generate_lot_number(
		              p_item_id      => p_item_id,
		              p_in_lot_no    => NULL,
		              p_orgn_code    => NULL,
		              p_doc_id       => NULL,
		              p_line_id      => NULL,
		              p_doc_type     => 'PORC',
		              p_out_lot_no   => l_lot_no,
		              p_sublot_no    => l_sublot_no,
		              p_return_status => l_return_status );
            IF l_return_status < 0 THEN
	       RAISE e_auto_lot_create;
	    END IF; --l_return_status < 0

	   -- x_found := check_if_lot_exists(p_item_id, l_lot_no, NULL);
           -- IF (x_found = 0) THEN
           --    EXIT;
           -- END IF;
	 --END LOOP;


         lot_rec.item_no         := l_item_no;
         lot_rec.lot_no          := l_lot_no;
         lot_rec.sublot_no       := l_sublot_no;
         lot_rec.lot_desc        := NULL;
         lot_rec.qc_grade        := l_qc_grade;
         lot_rec.lot_created     := SYSDATE;

         IF p_expire_date  IS NOT NULL
         THEN
            lot_rec.expire_date   :=  p_expire_date;
         END IF;

         lot_rec.inactive_ind    := 0;
         lot_rec.origination_type:= 3;
         lot_rec.shipvendor_no   := l_shipvendor_no;
         lot_rec.vendor_lot_no   := p_vendor_lot_no;
         lot_rec.ic_matr_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
         lot_rec.ic_hold_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
         lot_rec.user_name       := FND_GLOBAl.USER_NAME;

         IF nvl(p_no_of_sublots,0) = 0 THEN
            IF (GMIGUTL.SETUP(lot_rec.user_name)) THEN
	       GMIPAPI.Create_Lot
	          ( p_api_version    => 3
	          , p_init_msg_list  => FND_API.G_TRUE
	          , p_commit         => FND_API.G_FALSE
	          , p_validation_level => FND_API.G_VALID_LEVEL_FULL
	          , p_lot_rec        =>lot_rec
	          , x_ic_lots_mst_row => l_ic_lots_mst_row
	          , x_ic_lots_cpg_row => l_ic_lots_cpg_row
	          , x_return_status  => l_status
	          , x_msg_count      => l_count
	          , x_msg_data       => l_data
	          );
               IF (l_status = 'S') THEN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
               ELSE
                  x_return_status := l_status;
                  x_msg_count := l_count;
                  x_msg_data := l_data;
                  RAISE e_create_lot;
               END IF;
            END IF;

            IF p_lot_spec_conv = 'Y' THEN



               PO_GML_DB_COMMON.CREATE_LOT_SPECIFIC_CONVERSION(
								l_item_no,
								l_ic_lots_mst_row.lot_no,
								l_ic_lots_mst_row.sublot_no,
								p_primary_uom,
								p_secondary_uom,
								p_secondary_qty/nvl(p_primary_qty,1),
								l_status,l_data);

		 IF l_status IN ('E','U') THEN

		     x_return_status := l_status;
		     x_msg_count := 1;
		     --x_msg_data := l_data;
		     FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
                     FND_MESSAGE.SET_TOKEN('ERROR', l_data);
                     FND_MSG_PUB.ADD;
		     raise e_lot_conv_err;
		 END IF;
            END IF;/* IF p_lot_spec_conv = 'Y' */

         END IF;

         x_lot_table(l_dummy_cnt).lot_id := l_ic_lots_mst_row.lot_id;
         x_lot_table(l_dummy_cnt).lot_no := l_ic_lots_mst_row.lot_no;
         x_lot_table(l_dummy_cnt).sublot_no := l_ic_lots_mst_row.sublot_no;
         x_lot_table(l_dummy_cnt).expire_date := l_ic_lots_mst_row.expire_date;

         IF nvl(p_no_of_sublots,0) <> 0 THEN

            l_no_of_sublots := p_no_of_sublots;
            l_dummy_cnt1 := l_dummy_cnt;

            WHILE l_no_of_sublots <> 0
            LOOP

               l_no_of_sublots :=l_no_of_sublots - 1;
               l_dummy_lot := l_lot_no;

               --x_found := 1;    -- 1 means ic_lots_mst exists
               --WHILE (x_found = 1)
               --LOOP
                  gmi_autolot.generate_lot_number(
		              p_item_id      => p_item_id,
		              p_in_lot_no    => l_dummy_lot,
		              p_orgn_code    => NULL,
		              p_doc_id       => NULL,
		              p_line_id      => NULL,
		              p_doc_type     => 'PORC',
		              p_out_lot_no   => l_lot_no,
		              p_sublot_no    => l_sublot_no,
		              p_return_status => l_return_status );
                  IF l_return_status < 0 THEN
	             RAISE e_auto_lot_create;
	          END IF; --l_return_status < 0

	         -- x_found := check_if_lot_exists(p_item_id, l_lot_no, l_sublot_no);
                 -- IF (x_found = 0) THEN
                 --    EXIT;
                 -- END IF;
	       --END LOOP;


               lot_rec.item_no         := l_item_no;
               lot_rec.lot_no          := l_lot_no;
               lot_rec.sublot_no       := l_sublot_no;
               lot_rec.lot_desc        := NULL;
               lot_rec.qc_grade        := l_qc_grade;
               lot_rec.lot_created     := SYSDATE;

               IF p_expire_date  IS NOT NULL
               THEN
                  lot_rec.expire_date   :=  p_expire_date;
               END IF;

               lot_rec.inactive_ind    :=0;
               lot_rec.origination_type:=3;
               lot_rec.shipvendor_no   := l_shipvendor_no;
               lot_rec.vendor_lot_no   := p_vendor_lot_no;
               lot_rec.ic_matr_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
               lot_rec.ic_hold_date    := NULL; -- Bug 3698036 - changed to NULL from GMA_GLOBAL_GRP.SY$MAX_DATE.
               lot_rec.user_name       :=FND_GLOBAl.USER_NAME;

               IF (GMIGUTL.SETUP(lot_rec.user_name)) THEN
	          GMIPAPI.Create_Lot
	             ( p_api_version    => 3
	             , p_init_msg_list  => FND_API.G_TRUE
	             , p_commit         => FND_API.G_FALSE
	             , p_validation_level => FND_API.G_VALID_LEVEL_FULL
	             , p_lot_rec         =>lot_rec
	             , x_ic_lots_mst_row => l_ic_lots_mst_row
	             , x_ic_lots_cpg_row => l_ic_lots_cpg_row
	             , x_return_status   => l_status
	             , x_msg_count       => l_count
	             , x_msg_data        => l_data
	             );
	          IF (l_status = 'S') THEN
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                  ELSE
                     x_return_status := l_status;
                     x_msg_count := l_count;
                     x_msg_data := l_data;
                     RAISE e_create_lot;
                  END IF;

               END IF;

               x_lot_table(l_dummy_cnt1).lot_id := l_ic_lots_mst_row.lot_id;
               x_lot_table(l_dummy_cnt1).lot_no := l_ic_lots_mst_row.lot_no;
               x_lot_table(l_dummy_cnt1).sublot_no := l_ic_lots_mst_row.sublot_no;
               x_lot_table(l_dummy_cnt1).expire_date := l_ic_lots_mst_row.expire_date;

               IF p_lot_spec_conv = 'Y' THEN

                  PO_GML_DB_COMMON.CREATE_LOT_SPECIFIC_CONVERSION(
								l_item_no,
								l_ic_lots_mst_row.lot_no,
								l_ic_lots_mst_row.sublot_no,
								p_primary_uom,
								p_secondary_uom,
								p_secondary_qty/nvl(p_primary_qty,1),
								l_status,
								l_data);
		  IF l_status IN ('E','U') THEN
		     x_return_status := l_status;
		     x_msg_count := 1;
		     --x_msg_data := l_data;
		     FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
                     FND_MESSAGE.SET_TOKEN('ERROR', l_data);
                     FND_MSG_PUB.ADD;
		     raise e_lot_conv_err;
		  END IF;
               END IF;/* IF p_lot_spec_conv = 'Y' */

               l_dummy_cnt1 := l_dummy_cnt1 + 1;

            END LOOP;/*While l_no_of_sublots <> 0*/

            l_dummy_cnt := l_dummy_cnt1 -1 ;

         END IF;/*IF nvl(p_no_of_sublots,0) <> 0*/

      END LOOP;/*While l_no_of_lots <> 0*/
   END IF;/*p_lot_no IS NOT NULL */



RETURN l_return_status;

EXCEPTION
WHEN e_auto_lot_create THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   RETURN x_return_status;
WHEN e_create_lot THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   RETURN x_return_status;
WHEN e_lot_conv_err THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   RETURN x_return_status;
WHEN OTHERS THEN
   /*  dbms_output.put_line('Other Error');  */
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
   FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
   FND_MSG_PUB.ADD;
   RETURN x_return_status;
END Create_Lots;


--Start of comments
--+========================================================================+
--| API Name    : GMIGAPI_qty_format                                           |
--| TYPE        : Group                                                    |
--| Notes       : This function returns the format of GMAGAPI which        |
--|               is used by the receiving library RCVGMLCR.pld to         |
--|               call the status immediate api to change status of a lot  |
--|                                                                        |
--| HISTORY                                                                |
--|    P Bamb     11-AUG-2003     Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION Gmigapi_Qty_Format RETURN GMIGAPI.qty_rec_typ IS
l_temp   GMIGAPI.qty_rec_typ;

BEGIN
     return  l_temp;
END Gmigapi_Qty_Format;

END GML_MLT_CNTR_RCPT;

/
