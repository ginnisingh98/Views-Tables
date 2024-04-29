--------------------------------------------------------
--  DDL for Package Body GMP_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_ITEMS_PKG" as
/* $Header: GMPWITMB.pls 115.3 2004/04/20 06:50:40 sowsubra ship $ */
/* The Following Procedure Retrieves Items for a Specific Plant */
/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    get_items                                                            |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| USAGE                                                                   |
REM|                                                                         |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    The following Procedure Extracts Items for a Plant                   |
REM|                                                                         |
REM| INPUT PARAMETERS                                                        |
REM|    apps_link VARCHAR2                                                   |
REM|    plant_code VARCHAR2                                                  |
REM|                                                                         |
REM| OUTPUT PARAMETERS                                                       |
REM|    Standard OUT Parameters ( errbuf and retcode )                       |
REM|                                                                         |
REM| INPUT/OUTPUT PARAMETERS                                                 |
REM|    None                                                                 |
REM|                                                                         |
REM| HISTORY                                                                 |
REM|                                                                         |
REM+=========================================================================+
*/
PROCEDURE get_items
(
  errbuf          OUT NOCOPY VARCHAR2,
  retcode         OUT NOCOPY VARCHAR2,
  p_plant_code    IN  VARCHAR2
)
IS
  TYPE ref_cursor_typ IS REF CURSOR;
  c_item_cursor           ref_cursor_typ;
  v_cp_enabled            BOOLEAN ;
  retrieval_cursor        VARCHAR2(4096);
  insert_statement        VARCHAR2(4096);

  TYPE gmp_item_aps_typ  IS RECORD (
    item_no               VARCHAR2(32),
    item_id               NUMBER(10),
    item_um               VARCHAR2(4),
    uom_code              VARCHAR2(3),
    lot_control           NUMBER(5),
    item_desc1            VARCHAR2(70),
    aps_item_id           NUMBER,
    organization_id       NUMBER,
    whse_code             VARCHAR2(4),
    replen_ind            NUMBER(5),
    consum_ind            NUMBER(5),
    plant_code            VARCHAR2(4),
    creation_date         DATE,
    created_by            NUMBER(15),
    last_update_date      DATE,
    last_updated_by       NUMBER(15),
    last_update_login     NUMBER(15));

  gmp_item_aps_rec        gmp_item_aps_typ;

  i                       NUMBER ;
  v_item_count            NUMBER ;

BEGIN

  v_cp_enabled := FALSE ;
  i            := 0;
  v_item_count := 0;

  retrieval_cursor := 'DELETE FROM gmp_item_wps '
                   || ' WHERE plant_code = :p_plant_code ';
                       EXECUTE IMMEDIATE retrieval_cursor USING p_plant_code;
                       COMMIT;

  retrieval_cursor :=
                'SELECT iim.item_no, iim.item_id, iim.item_um, mum.uom_code, '
	        || '    iim.lot_ctl, iim.item_desc1, msi.inventory_item_id, '
                || '    iwm.mtl_organization_id, '
		|| '    pwe.whse_code, decode(sum(pwe.replen_ind), 0, 0, 1), '
                || '    decode(sum(pwe.consum_ind), 0, 0, 1), '
		|| '    pwe.plant_code, iim.creation_date, iim.created_by, '
                || '    iim.last_update_date, '
		|| '    iim.last_updated_by, NULL '
                || 'FROM   ic_item_mst iim,'
		|| '       sy_uoms_mst sou,'
		|| '       ps_whse_eff pwe,'
		|| '       ic_whse_mst iwm,'
		|| '       mtl_system_items  msi,'
		|| '       mtl_units_of_measure mum '
		|| 'WHERE '
		|| '       iim.delete_mark = 0 AND '
		|| '       iim.inactive_ind = 0 AND '
       		|| '       iim.noninv_ind = 0 AND ' /* B3542453 - sowsubra - Added to pull in only inventoried items
                                                       and hence avoid passing the non-inventory items to the WPS*/
		|| '       iim.item_no = msi.segment1 AND '
		|| '       iwm.mtl_organization_id = msi.organization_id AND '
                || '       pwe.plant_code = :p_plant_code AND '
		|| '       pwe.whse_code = iwm.whse_code AND '
		|| '       sou.unit_of_measure = mum.unit_of_measure AND '
                || '       sou.delete_mark = 0 AND '
		|| '       iim.item_um = sou.um_code AND '
		|| '       iim.experimental_ind = 0 AND '
		|| '       ( '
		|| '         pwe.whse_item_id IS NULL OR '
		|| '         pwe.whse_item_id = iim.whse_item_id OR '
		|| '         ( '
		|| '           pwe.whse_item_id = iim.item_id AND '
		|| '           iim.item_id <> iim.whse_item_id '
		|| '         ) '
		|| '       ) '
		|| 'GROUP BY '
		|| '       iim.item_id, iim.item_no, '
                || '       iim.item_desc1, iim.item_um, '
                || '       iim.lot_ctl, pwe.whse_code, '
		|| '       pwe.plant_code, mum.uom_code, '
                || '       msi.inventory_item_id, '
                || '       iwm.mtl_organization_id, '
		|| '       iim.creation_date, iim.created_by, '
                || '       iim.last_update_date, '
                || '       iim.last_updated_by ';

  OPEN c_item_cursor FOR retrieval_cursor USING p_plant_code;

  insert_statement :=
                  'INSERT INTO gmp_item_wps '
			   || '( '
			   || '  item_no, item_id, item_um, uom_code,'
                           || '  lot_control, item_desc1, '
			   || '  aps_item_id, organization_id, whse_code, '
                           || '  replen_ind, consum_ind, '
			   || '  plant_code, creation_date, created_by, '
                           || '  last_update_date, '
			   || '  last_updated_by, last_update_login '
			   || ') '
			   || 'VALUES '
			   || '(:p1,:p2,:p3,:p4,:p5,:p6,:p7,:p8,:p9,:p10, '
                           || ' :p11,:p12,:p13,:p14,:p15,:p16,:p17)';
  FETCH c_item_cursor
  INTO  gmp_item_aps_rec;

  WHILE c_item_cursor%FOUND
  LOOP
    EXECUTE IMMEDIATE insert_statement USING
         gmp_item_aps_rec.item_no,
	 gmp_item_aps_rec.item_id,
	 gmp_item_aps_rec.item_um,
	 gmp_item_aps_rec.uom_code,
	 gmp_item_aps_rec.lot_control,
	 gmp_item_aps_rec.item_desc1,
	 gmp_item_aps_rec.aps_item_id,
	 gmp_item_aps_rec.organization_id,
	 gmp_item_aps_rec.whse_code,
         gmp_item_aps_rec.replen_ind,
	 gmp_item_aps_rec.consum_ind,
	 gmp_item_aps_rec.plant_code,
	 SYSDATE,
	 gmp_item_aps_rec.created_by,
         SYSDATE,
	 gmp_item_aps_rec.last_updated_by,
	 0;

    i := i + 1;

    IF i = 500 then
      COMMIT;
      i := 0;
    END IF;

    FETCH c_item_cursor INTO gmp_item_aps_rec;

  END LOOP;

  COMMIT;

  CLOSE c_item_cursor;

  SELECT count(*)
  INTO   v_item_count
  FROM   gmp_item_wps;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'The Number of Items Loaded Successfully are '||v_item_count);

  EXCEPTION
    WHEN OTHERS THEN
	  errbuf := sqlerrm;
          retcode := '2';

END get_items;

END gmp_items_pkg; /* Package for Items Extraction */

/
