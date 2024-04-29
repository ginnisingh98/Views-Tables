--------------------------------------------------------
--  DDL for Package Body GML_PO_RECV2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_PO_RECV2_PKG" AS
/* $Header: GMLRCMVB.pls 115.12 2002/12/04 19:08:35 gmangari ship $ */

  c_language_code VARCHAR2(4):= 'ENG';

/*========================================================================
|                                                                        |
| PROCEDURE NAME  get_oracle_id                                          |
|                                                                        |
| DESCRIPTION      Procedure to get the po header id, line id, location  |
|                  id, and release id from the mapping table.            |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 11/12/97        Kenny Jiang  get po_release_id added                   |
|                                                                        |
=========================================================================*/

PROCEDURE get_oracle_id
(  v_po_id             IN  po_ordr_hdr.po_id%TYPE,
   v_line_id           IN  po_ordr_dtl.line_id%TYPE,
   v_po_header_id      OUT NOCOPY cpg_oragems_mapping.po_header_id%TYPE,
   v_po_line_id        OUT  NOCOPY cpg_oragems_mapping.po_line_id%TYPE,
   v_line_location_id  OUT NOCOPY cpg_oragems_mapping.po_line_location_id%TYPE,
   v_po_release_id     OUT NOCOPY cpg_oragems_mapping.po_release_id%TYPE)
IS
  CURSOR  id_cur IS
  SELECT  po_header_id,
          po_line_id,
          po_line_location_id,
          po_release_id
  FROM    cpg_oragems_mapping
  WHERE   po_id   = v_po_id
  AND     line_id = v_line_id;

  err_num NUMBER;
  err_msg VARCHAR2(100);
  complete_message VARCHAR2(2000);

BEGIN

  OPEN  id_cur;
  FETCH id_cur INTO v_po_header_id,     v_po_line_id,
                    v_line_location_id, v_po_release_id;
  IF id_cur%NOTFOUND THEN
    CLOSE id_cur;
    FND_MESSAGE.set_name('GML', 'PO_ID_ERROR');
    complete_message := FND_MESSAGE.GET;
    raise_application_error(-20000, complete_message);
  END IF;
  CLOSE id_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END get_oracle_id;


/*========================================================================
|                                                                        |
| PROCEDURE NAME  update_header_status                                   |
|                                                                        |
| DESCRIPTION  Procedure to update header status.                        |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

PROCEDURE  update_header_status
( v_po_header_id     IN NUMBER,
  v_org_id           IN NUMBER,
  v_last_updated_by  IN NUMBER,
  v_last_update_date IN DATE  )
IS
  CURSOR  line_cur IS
  SELECT  closed_code
  FROM    po_lines_all
  WHERE   po_header_id = v_po_header_id
  AND     org_id = v_org_id;

  CURSOR  po_cur IS
  SELECT  closed_code
  FROM    po_headers_all
  WHERE   po_header_id  = v_po_header_id
  AND     org_id = v_org_id;

  v_closed_code   po_lines_all.closed_code%TYPE;
  v_new_status    po_headers_all.closed_code%TYPE;
  v_old_status    po_headers_all.closed_code%TYPE;
  v_all_lines_closed   BOOLEAN :=TRUE;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN

  OPEN  line_cur;
  FETCH line_cur INTO v_closed_code;

  WHILE   line_cur%FOUND
  LOOP

    /* closed_code can be OPEN, CLOSED or NULL in po_lines_all */

    IF  v_closed_code IS NULL OR  v_closed_code = 'OPEN' THEN
        v_all_lines_closed :=FALSE;
    END IF;

    FETCH  line_cur INTO  v_closed_code;

  END LOOP;

  IF  v_all_lines_closed = TRUE THEN
      v_new_status := 'CLOSED';
  ELSE
      v_new_status := 'OPEN';
  END IF;

  OPEN  po_cur;
  FETCH po_cur INTO v_old_status;
  CLOSE po_cur;

  IF v_old_status IS NULL OR
     v_new_status <> v_old_status THEN
  BEGIN
    UPDATE  po_headers_all
    SET     closed_code = v_new_status,
            last_update_date= v_last_update_date,
            last_updated_by = v_last_updated_by
    WHERE   po_header_id = v_po_header_id  AND
            org_id = v_org_id;
  END;
  END IF;

  CLOSE    line_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END  update_header_status;


/*========================================================================
|                                                                        |
| PROCEDURE NAME  update_line_status                                     |
|                                                                        |
| DESCRIPTION  Procedure to update_line_status.                          |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
|                                                                        |
=========================================================================*/

PROCEDURE  update_line_status
( v_po_header_id      IN NUMBER,
 v_po_line_id         IN NUMBER,
 v_org_id             IN NUMBER,
 v_last_updated_by    IN NUMBER,
 v_last_update_date   IN DATE  )
IS

  CURSOR  line_location_cur IS
  SELECT  closed_code
  FROM    po_line_locations_all
  WHERE   po_header_id = v_po_header_id
  AND     po_line_id = v_po_line_id
  AND     org_id = v_org_id;

  CURSOR  line_cur IS
  SELECT  closed_code
  FROM    po_lines_all
  WHERE   po_header_id = v_po_header_id
  AND     po_line_id = v_po_line_id
  AND     org_id = v_org_id;

  v_closed_code   po_line_locations_all.closed_code%TYPE;
  v_new_status    po_lines_all.closed_code%TYPE;
  v_old_status    po_lines_all.closed_code%TYPE;
  v_all_locations_closed   BOOLEAN :=TRUE;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN
  OPEN  line_location_cur;
  FETCH line_location_cur INTO v_closed_code;

  WHILE  line_location_cur%FOUND
  LOOP
    IF  v_closed_code IS NULL OR  v_closed_code NOT IN ('CLOSED',
        'FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE') THEN
      v_all_locations_closed :=FALSE;
    END IF;

    FETCH  line_location_cur INTO v_closed_code;
  END LOOP;

  IF  v_all_locations_closed = TRUE THEN
      v_new_status := 'CLOSED';
  ELSE
      v_new_status := 'OPEN';
  END IF;

  OPEN  line_cur;
  FETCH line_cur INTO v_old_status;
  CLOSE line_cur;

  IF v_old_status IS NULL OR v_new_status <> v_old_status THEN
    UPDATE  po_lines_all
    SET     closed_code = v_new_status,
            last_update_date= v_last_update_date,
            last_updated_by = v_last_updated_by
    WHERE   po_header_id = v_po_header_id  AND
            po_line_id = v_po_line_id    AND
            org_id = v_org_id;

    update_header_status(v_po_header_id,
                         v_org_id,
                         v_last_updated_by,
                         v_last_update_date );

  END IF;

  CLOSE    line_location_cur;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END  update_line_status;


/*========================================================================

 PROCEDURE NAME  update_release_status

 DESCRIPTION  Procedure to update the status in po_releases_all

 MODIFICATION HISTORY

 11/12/97        Kenny Jiang  created

========================================================================*/

PROCEDURE  update_release_status
( v_po_header_id     IN NUMBER,
  v_po_release_id    IN NUMBER,
  v_org_id           IN NUMBER,
  v_last_updated_by  IN NUMBER,
  v_last_update_date IN DATE  )
IS

  CURSOR  line_location_cur IS
  SELECT  closed_code
  FROM    po_line_locations_all
  WHERE   po_header_id  = v_po_header_id
  AND     po_release_id = v_po_release_id
  AND     org_id = v_org_id;

  CURSOR  status_cur IS
  SELECT  closed_code
  FROM    po_releases_all
  WHERE   po_header_id  = v_po_header_id
  AND     po_release_id = v_po_release_id
  AND     org_id        = v_org_id;

  v_closed_code   po_line_locations_all.closed_code%TYPE;
  v_new_status    po_lines_all.closed_code%TYPE;
  v_old_status    po_lines_all.closed_code%TYPE;
  v_all_locations_closed   BOOLEAN :=TRUE;

  err_num NUMBER;
  err_msg VARCHAR2(100);

BEGIN
  OPEN  line_location_cur;
  FETCH line_location_cur INTO v_closed_code;

  WHILE   line_location_cur%FOUND
  LOOP
    IF  v_closed_code IS NULL OR v_closed_code NOT IN ('CLOSED',
        'FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE') THEN
      v_all_locations_closed :=FALSE;
    END IF;

    FETCH  line_location_cur INTO v_closed_code;
  END LOOP;
  CLOSE    line_location_cur;

  IF  v_all_locations_closed = TRUE THEN
      v_new_status := 'CLOSED';
  ELSE
      v_new_status := 'OPEN';
  END IF;

  OPEN  status_cur;
  FETCH status_cur  INTO v_old_status;
  CLOSE status_cur;

  IF v_old_status IS NULL  OR  v_new_status <> v_old_status THEN
    UPDATE  po_releases_all
    SET     closed_code = v_new_status,
            last_update_date= v_last_update_date,
            last_updated_by = v_last_updated_by
    WHERE   po_header_id  = v_po_header_id
    AND     po_release_id = v_po_release_id
    AND     org_id = v_org_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END  update_release_status;


/*========================================================================
|                                                                        |
| PROCEDURE NAME  update_line_locations.                                 |
|                                                                        |
| DESCRIPTION  Procedure to update line locations.                       |
|                                                                        |
| MODIFICATION HISTORY                                                   |
|                                                                        |
| 10/22/97        Kenny Jiang  created                                   |
| 23-NOV-99  NC - modified all references to cpg_receiving_interface table
|                 which nolonger exists. 				 |
| 16-DOC-99  NC - Added FND_GLOBAL.APPS_INITIALIZE .                     |
| 03-MAR-00  HW - BUG#:1222247 - changed status code                     |
=========================================================================*/

PROCEDURE update_line_locations
( v_po_header_id      IN cpg_oragems_mapping.po_header_id%TYPE,
  v_po_line_id        IN cpg_oragems_mapping.po_line_id%TYPE,
  v_line_location_id  IN cpg_oragems_mapping.po_line_location_id%TYPE,
  v_po_release_id     IN cpg_oragems_mapping.po_release_id%TYPE,
  v_org_id            IN gl_plcy_mst.org_id%TYPE,
  v_po_status         IN po_ordr_dtl.po_status%TYPE,
  v_received_qty      IN po_recv_dtl.recv_qty1%TYPE,
  v_returned_qty      IN po_rtrn_dtl.return_qty1%TYPE,
  v_created_by        IN po_recv_dtl.created_by%TYPE,
  v_timestamp         IN cpg_oragems_mapping.time_stamp%TYPE)
IS
  v_closed_code      po_line_locations_all.closed_code%TYPE;
  v_last_updated_by  po_line_locations_all.last_updated_by%TYPE;
  v_closed_reason    po_line_locations_all.closed_reason%TYPE;
  v_closed_date      po_line_locations_all.closed_date%TYPE;
  v_closed_by        po_line_locations_all.closed_by%TYPE;
  v_close_status     po_line_locations_all.closed_code%TYPE;
  v_source_shipment_id     po_line_locations_all.source_shipment_id%TYPE;
  v_canceled         VARCHAR2(1);

  /* NC 12/16/99 */
  v_user_id          NUMBER;
  v_resp_id          NUMBER;
  v_resp_appl_id     NUMBER;


  CURSOR  canceled_cur IS
  SELECT  cancel_flag
  FROM    po_line_locations_all
  WHERE   line_location_id = v_line_location_id;

  CURSOR  close_status_cur IS
  SELECT  closed_code
  FROM    po_line_locations_all
  WHERE   line_location_id = v_line_location_id;

  CURSOR po_cur IS
  SELECT segment1
  FROM   po_headers_all
  WHERE  po_header_id = v_po_header_id;

  CURSOR line_cur IS
  SELECT line_num
  FROM   po_lines_all
  WHERE  po_line_id = v_po_line_id;

  CURSOR shipment_cur IS
  SELECT shipment_num
  FROM   po_line_locations_all
  WHERE  line_location_id = v_line_location_id;

  CURSOR user_id_cur IS
  SELECT user_id
  FROM   fnd_user
  WHERE  user_name = v_created_by;

  /* NC 12/16/99 */
  CURSOR resp_id_cur IS
  SELECT responsibility_id
  FROM   fnd_user_resp_groups
  WHERE  user_id = v_user_id
  AND    responsibility_application_id
         = v_resp_appl_id;

  err_num NUMBER;
  err_msg VARCHAR2(100);
  v_complete_msg VARCHAR2(2000);
  v_po_no VARCHAR2(20);
  v_line_no NUMBER;
  v_shipment_no NUMBER;

BEGIN

/* T. Ricci 12/24/98 not needed now that created_by is the user_id*/
/*  OPEN  user_id_cur;*/
/*  FETCH user_id_cur INTO v_last_updated_by;*/
/*  CLOSE user_id_cur; */

  v_last_updated_by := v_created_by;

  /* When closed_code is updated in po_line_locations_all, a trigger on
     that table tries to fire a concurrent program. For some reason
     the FND_GLOBAL user_id and resp_id had wrong values becoz of which
     the concurrenct request was not getting fired( returning "CONC-Unable to
     get oracle name") error. Hence added the following APPS_INITIALIZE call.
     -- NC  12/16/99  */

  v_user_id := v_created_by;
  v_resp_appl_id := FND_GLOBAL.resp_appl_id;

  OPEN  resp_id_cur;
  FETCH resp_id_cur INTO v_resp_id;
  CLOSE resp_id_cur;

  FND_GLOBAL.APPS_INITIALIZE(v_user_id,v_resp_id,v_resp_appl_id);


  IF  v_po_status = 20 THEN
/* BUG#:1222247 - make status Closed for Receiving  */
/*   v_closed_code   := 'CLOSED'; */
    v_closed_code   := 'CLOSED FOR RECEIVING';
    v_closed_reason := 'Ordered Quantity Fully Received';
    v_closed_date   := v_timestamp;
    v_closed_by     := v_last_updated_by;

  /* Each individual shipment line could be closed by GEMMS when fully received*/
  /* or closed by Oracle inadvertently.*/
  /* Note: In comparison, closure of a line could not be simply traced to */
  /* a single reason or user if the line has multiple shipment lines.*/
  ELSE          /* v_po_status = 0*/
    v_closed_code   := 'OPEN';
    v_closed_reason := NULL;
    v_closed_date   := NULL;
    v_closed_by     := NULL;
  END IF;

  UPDATE  po_line_locations_all
  SET     last_update_date = v_timestamp,
          last_updated_by  = v_last_updated_by,
          quantity_received = v_received_qty,
          quantity_rejected = v_returned_qty
  WHERE   po_header_id  = v_po_header_id
  AND     po_line_id   = v_po_line_id
  AND     line_location_id  = v_line_location_id
/* Added the OR org_id is null to allow for mult org*/
  AND     (org_id  = v_org_id OR org_id is null);

  /* IF it is a Blanket or a Planned PO, Update Recd qty for the Parent Line*/

  SELECT source_shipment_id
  INTO   v_source_shipment_id
  FROM   po_line_locations_all
  WHERE  line_location_id = v_line_location_id;

  UPDATE  po_line_locations_all
  SET     last_update_date  = v_timestamp,
          last_updated_by   = v_last_updated_by,
          quantity_received = (select sum(quantity_received)
                               from   po_line_locations_all
                               where  source_shipment_id = v_source_shipment_id),
          quantity_rejected = (select sum(quantity_rejected)
                               from   po_line_locations_all
                               where  source_shipment_id = v_source_shipment_id)
  WHERE   po_header_id      = v_po_header_id
  AND     po_line_id        = v_po_line_id
  AND     line_location_id  = (select source_shipment_id
                               from   po_line_locations_all
                               where  line_location_id = v_line_location_id)
  AND     org_id            = v_org_id;

  OPEN  canceled_cur;
  FETCH canceled_cur INTO v_canceled;
  CLOSE canceled_cur;
  OPEN  close_status_cur;
  FETCH close_status_cur INTO v_close_status;
  CLOSE close_status_cur;

  IF  (v_canceled= 'Y') OR (v_close_status= 'FINALLY CLOSED') THEN

    OPEN  shipment_cur;
    FETCH shipment_cur INTO v_shipment_no;
    CLOSE shipment_cur;

    OPEN  line_cur;
    FETCH line_cur INTO v_line_no;
    CLOSE line_cur;

    OPEN  po_cur;
    FETCH po_cur INTO v_po_no;
    CLOSE po_cur;


    FND_MESSAGE.set_name('GML', 'PO_RCV_LINE_CLOSE');
    FND_MESSAGE.set_token('v_po_no',v_po_no);
    v_complete_msg := FND_MESSAGE.GET;

  ELSE
/* BUG#:1222247 */
/* Commented following 3 lines.Prevent updating unnecessary fields */

    UPDATE  po_line_locations_all
    SET     closed_code   = v_closed_code
/*          closed_reason = v_closed_reason, */
/*          closed_date  = v_closed_date, */
/*          closed_by  = v_closed_by */
    WHERE   po_header_id  = v_po_header_id
    AND     po_line_id   = v_po_line_id
    AND     line_location_id  = v_line_location_id
    AND     org_id  = v_org_id;
  END IF;

  /* Update the PO Line for all types of PO's*/

/* BUG#:1222247 */
/* Do not call the following procedure thus the bug will prevent unnecessary */
/* updates of fields in po_lines and po_headers */

/*
  update_line_status(v_po_header_id,
                     v_po_line_id,
                     v_org_id,
                     v_last_updated_by,
                     v_timestamp);
*/

/*BUG#:1222247 leave status code in po_releases_all unchanged -- */
/* commented the call to update_release_status */

/* IF v_po_release_id IS NOT NULL THEN   -- it's a Planned/Blanket PO shipment */
/*  update_release_status(v_po_header_id,  */
/*                        v_po_release_id, */
/*                        v_org_id, */
/*                        v_last_updated_by, */
/*                        v_timestamp); */
/* END IF; */

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTRB(SQLERRM, 1, 100);
    RAISE_APPLICATION_ERROR(-20000, err_msg);

END update_line_locations;

END GML_PO_RECV2_PKG;

/
