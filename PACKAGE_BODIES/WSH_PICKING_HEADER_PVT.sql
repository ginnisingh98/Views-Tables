--------------------------------------------------------
--  DDL for Package Body WSH_PICKING_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICKING_HEADER_PVT" AS
/* $Header: WSHPKHVB.pls 115.2 99/07/16 08:19:29 porting ship $ */

  PROCEDURE consolidate_pld (picking_header_id 	IN  NUMBER,
			     ret_status 	OUT NUMBER,
			     msg		OUT VARCHAR2)
  IS
    ph_id NUMBER;
    CURSOR c1 (ph_id NUMBER ) IS
      SELECT pl.picking_line_id
      FROM so_picking_lines pl, so_picking_headers ph
      WHERE pl.picking_header_id = ph.picking_header_id
      AND   ph.picking_header_id = ph_id
      AND   ph.status_code = 'PENDING';
    pl_id NUMBER;
    CURSOR c2 (pl_id NUMBER ) IS
      select
        count(picking_line_detail_id),
        min(picking_line_detail_id),
        sum(requested_quantity)
      from so_picking_line_details
      where picking_line_id = pl_id
      and NVL(shipped_quantity, 0) = 0
      and NVL(released_flag, 'Y') = 'Y'
      group by
      warehouse_id,
      subinventory,
      inventory_location_id,
      revision,
      lot_number,
      CUSTOMER_REQUESTED_LOT_FLAG,
      CONTEXT,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      schedule_date,
      schedule_level,
      schedule_status_code,
      demand_id,
      demand_class_code,
      AUTOSCHEDULED_FLAG,
      delivery,
      update_flag,
      detail_type_code;
    keep_pld_id    NUMBER;
    pld_count      NUMBER;
    sum_requested  NUMBER;
    dummy          NUMBER;
    sql_statement  NUMBER;
    err_msg	 VARCHAR2(255);
    CURSOR c3( pl_id  NUMBER ) IS
      SELECT picking_line_detail_id
      FROM so_picking_line_details
      WHERE picking_line_id = pl_id
      FOR UPDATE OF picking_line_detail_id NOWAIT;
  BEGIN
    SAVEPOINT before_consolidate;

    ph_id := picking_header_id;

    sql_statement := 0;
    OPEN c1(ph_id);

    LOOP

      sql_statement := 10;
      FETCH c1 INTO pl_id;

      EXIT WHEN c1%NOTFOUND;

      sql_statement := 20;
      OPEN c3(pl_id);

      sql_statement := 25;
      FETCH c3 INTO dummy;

      IF c3%NOTFOUND THEN
        CLOSE c3;
      ELSE

        sql_statement := 30;
        OPEN c2(pl_id);
        LOOP

          sql_statement := 40;
          FETCH c2 INTO pld_count, keep_pld_id, sum_requested;

          EXIT WHEN c2%NOTFOUND;

          IF ( pld_count > 1 ) THEN
            sql_statement := 50;
            DELETE FROM so_picking_line_details
            WHERE picking_line_id = pl_id
            AND   shipped_quantity = 0
            AND   NVL(released_flag, 'Y') = 'Y'
            AND   picking_line_detail_id <> keep_pld_id
            AND (nvl(warehouse_id, -99999),
                 nvl(subinventory, -99999),
                 nvl(inventory_location_id, -99999),
                 nvl(revision, -99999),
                 nvl(lot_number, -99999),
                 nvl(CUSTOMER_REQUESTED_LOT_FLAG, -99999),
                 nvl(CONTEXT, -99999),
                 nvl(ATTRIBUTE1, -99999),
                 nvl(ATTRIBUTE2, -99999),
                 nvl(ATTRIBUTE3, -99999),
                 nvl(ATTRIBUTE4, -99999),
                 nvl(ATTRIBUTE5, -99999),
                 nvl(ATTRIBUTE6, -99999),
                 nvl(ATTRIBUTE7, -99999),
                 nvl(ATTRIBUTE8, -99999),
                 nvl(ATTRIBUTE9, -99999),
                 nvl(ATTRIBUTE10, -99999),
                 nvl(ATTRIBUTE11, -99999),
                 nvl(ATTRIBUTE12, -99999),
                 nvl(ATTRIBUTE13, -99999),
                 nvl(ATTRIBUTE14, -99999),
                 nvl(ATTRIBUTE15,	 -99999),
                 nvl(schedule_date, sysdate),
                 nvl(schedule_level, -99999),
                 nvl(schedule_status_code, -99999),
                 nvl(demand_id, -99999),
                 nvl(demand_class_code, -99999),
                 nvl(AUTOSCHEDULED_FLAG, -99999),
                 nvl(delivery, -99999),
                 nvl(update_flag, -99999),
                 nvl(detail_type_code, -99999)) =
                (SELECT nvl(warehouse_id, -99999),
                        nvl(subinventory, -99999),
                        nvl(inventory_location_id, -99999),
                        nvl(revision, -99999),
                        nvl(lot_number, -99999),
                        nvl(CUSTOMER_REQUESTED_LOT_FLAG, -99999),
                        nvl(CONTEXT, -99999),
                        nvl(ATTRIBUTE1, -99999),
                        nvl(ATTRIBUTE2, -99999),
                        nvl(ATTRIBUTE3, -99999),
                        nvl(ATTRIBUTE4, -99999),
                        nvl(ATTRIBUTE5, -99999),
                        nvl(ATTRIBUTE6, -99999),
                        nvl(ATTRIBUTE7, -99999),
                        nvl(ATTRIBUTE8, -99999),
                        nvl(ATTRIBUTE9, -99999),
                        nvl(ATTRIBUTE10, -99999),
                        nvl(ATTRIBUTE11, -99999),
                        nvl(ATTRIBUTE12, -99999),
                        nvl(ATTRIBUTE13, -99999),
                        nvl(ATTRIBUTE14, -99999),
                        nvl(ATTRIBUTE15,	 -99999),
                        nvl(schedule_date, sysdate),
                        nvl(schedule_level, -99999),
                        nvl(schedule_status_code, -99999),
                        nvl(demand_id, -99999),
                        nvl(demand_class_code, -99999),
                        nvl(AUTOSCHEDULED_FLAG, -99999),
                        nvl(delivery, -99999),
                        nvl(update_flag, -99999),
                        nvl(detail_type_code, -99999)
                 FROM so_picking_line_details
                 WHERE picking_line_detail_id = keep_pld_id);

            sql_statement := 60;
            UPDATE so_picking_line_details
            SET requested_quantity = sum_requested,
  	      serial_number = NULL
            WHERE picking_line_detail_id = keep_pld_id;
          END IF;
        END LOOP;
        IF c2%ISOPEN THEN
          CLOSE c2;
        END IF;

        IF c3%ISOPEN THEN
          CLOSE c3;
        END IF;

      END IF;
    END LOOP;
    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    err_msg := 'Calling wsh_picking_headers.consolidate_pld Successfully.';
    msg := err_msg;
    ret_status := 1;
    RETURN;

  EXCEPTION
    WHEN OTHERS THEN
    err_msg := 'Error at Statement ' || TO_CHAR(sql_statement);
    err_msg := err_msg || ' with ' || SUBSTR(SQLERRM,1,170);
    ROLLBACK TO before_consolidate;
    msg := err_msg;
    ret_status := 0;
    RETURN;
  END consolidate_pld;


END WSH_PICKING_HEADER_PVT;

/
