--------------------------------------------------------
--  DDL for Package Body GMIVDBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVDBL" AS
/* $Header: GMIVDBLB.pls 115.22 2004/02/25 15:43:40 mkalyani ship $ */
/*  +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVDBLB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | This package body contains routines which are privately                 |
 | accessible from the inventory API processing layers. No other use,      |
 | either public or private is supported.                                  |
 |                                                                         |
 | API NAME                                                                |
 |     GMIVDBL Inventory API Database Layer                                |
 |                                                                         |
 | TYPE                                                                    |
 |     Private                                                             |
 |                                                                         |
 | HISTORY                                                                 |
 |   12-May-2000   P.J.Schofield, OPM Development, Oracle UK               |
 |                 Created for Inventory API Release 3.0                   |
 |                                                                         |
 |   30-May-2001   Joe DiIorio  11.5.1G BUG#1806025                        |
 |                 uncommented exit and commit statements.                 |
 |                                                                         |
 |   13-Jun-2001   A. Mundhe  Bug 1764383 - Added code to all the functions|
 |                            to return sqlerrm in case of unexpected      |
 |                            database errors.                             |
 |   7-Sep-2001    Jalaj Srivastava Bug 1977956
 |                 All the select functions should not log messages for
 |                 No data found exception. This error is expected
 |   21/Feb/2002   P Lowe Bug 2233859 - Field ont_pricing_qty_source	   |
 |                        added - (validation (default is 0))in            |
 |			  item_rec_typ record for the       	           |
 |  			  Pricing by Quantity 2 project.                   |
 |   07/24/02      Jalaj Srivastava BUg 2483656                            |
 |                 Modified ic_jrnl_mst insert to not insert journal no    |
 |                 if it already exists                                    |
 |   17-Nov-2002   Joe DiIorio  Bug 1977956 11.5.1J - added nocopy.        |
 |   15-Apr-2003   Joe DiIorio  Bug 2880585 11.5.1K - added conversion_id  |
 |                 to insert of ic_item_cnv. Added insert of               |
 |                 gmi_item_conv_audit.                                    |
 |   24-Jun-2003   Joe DiIorio  Bug 3022564 11.5.10K - Changed sequennce   |
 |                 retrieval for gmi_item_conv_audit to                    |
 |                 gmi_conv_audit_id_s. Was incorrectly calling            |
 |                 gmi_conv_audit_detail_id_s.                             |
 |   11-Sep-2003   Teresa Wong B2378017 - Modified code to support new     |
 |                 classes.  1) Moved the call to gmi_item_categories from |
 |                 ic_item_mst_insert to GMIGAPIB.Create_Item.  2) Added   |
 |                 p_item_rec parameter to gmi_item_categories.  3) Added  |
 |                 code to get category set information and to call        |
 |                 gmi_item_categories_insert.                             |
 |   24-Feb-2004   Anoop Baddam B3151733 - Added a new procedure           |
 |                 mtl_item_categories_insert that inserts data into       |
 |                 mtl_item_categories table. This procedure is called from|
 |                 GMI_ITEM_CATEGORIES_INSERT procedure.                          |
 +=========================================================================+
*/
  /*  All of the following routines take a rowtype record appropriate to */
  /*  the table being accessed and return rowtype records, also appropriate to */
  /*  the table being accessed. In the 'select' variants only the key fields */
  /*  for the desired row need be filled in. The row, if located will be  */
  /*  returned in the record passed back to the caller. In the 'insert' */
  /*  variants the row inserted, if the insertion succeeds, will be returned */
  /*  with the id columns (doc_id, journal_id, line_id, item_id etc.) filled  */
  /*  in. Any id column values which were passed in will be used 'as is'. */

  /*  All routines will update 'return_status' and 'error_text' in line */
  /*  with the return value from the database. */

  FUNCTION ic_item_mst_insert
    (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE, x_ic_item_mst_row IN OUT NOCOPY ic_item_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN

    /*  Copy input record to output record */

    x_ic_item_mst_row := p_ic_item_mst_row;

    /*  Fill in any missing surrogates;  */
    IF x_ic_item_mst_row.item_id IS NULL
    THEN
      SELECT gem5_item_id_s.nextval INTO x_ic_item_mst_row.item_id FROM dual;
    END IF;

    IF x_ic_item_mst_row.whse_item_id IS NULL
    THEN
      x_ic_item_mst_row.whse_item_id := x_ic_item_mst_row.item_id;
    END IF;



    INSERT INTO ic_item_mst
    ( item_id
    , item_no
    , item_desc1
    , item_desc2
    , alt_itema
    , alt_itemb
    , item_um
    , dualum_ind
    , item_um2
    , deviation_lo
    , deviation_hi
    , level_code
    , lot_ctl
    , lot_indivisible
    , sublot_ctl
    , loct_ctl
    , noninv_ind
    , match_type
    , inactive_ind
    , inv_type
    , shelf_life
    , retest_interval
    , item_abccode
    , gl_class
    , inv_class
    , sales_class
    , ship_class
    , frt_class
    , price_class
    , storage_class
    , purch_class
    , tax_class
    , customs_class
    , alloc_class
    , planning_class
    , itemcost_class
    , cost_mthd_code
    , upc_code
    , grade_ctl
    , status_ctl
    , qc_grade
    , lot_status
    , bulk_id
    , pkg_id
    , qcitem_id
    , qchold_res_code
    , expaction_code
    , fill_qty
    , fill_um
    , expaction_interval
    , phantom_type
    , whse_item_id
    , experimental_ind
    , exported_date
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , trans_cnt
    , delete_mark
    , text_code
    , seq_dpnd_class
    , commodity_code
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute16
    , attribute17
    , attribute18
    , attribute19
    , attribute20
    , attribute21
    , attribute22
    , attribute23
    , attribute24
    , attribute25
    , attribute26
    , attribute27
    , attribute28
    , attribute29
    , attribute30
    , attribute_category
    , ont_pricing_qty_source -- P Lowe Bug 2233859
    )
    VALUES
    ( x_ic_item_mst_row.item_id
    , x_ic_item_mst_row.item_no
    , x_ic_item_mst_row.item_desc1
    , x_ic_item_mst_row.item_desc2
    , x_ic_item_mst_row.alt_itema
    , x_ic_item_mst_row.alt_itemb
    , x_ic_item_mst_row.item_um
    , x_ic_item_mst_row.dualum_ind
    , x_ic_item_mst_row.item_um2
    , x_ic_item_mst_row.deviation_lo
    , x_ic_item_mst_row.deviation_hi
    , x_ic_item_mst_row.level_code
    , x_ic_item_mst_row.lot_ctl
    , x_ic_item_mst_row.lot_indivisible
    , x_ic_item_mst_row.sublot_ctl
    , x_ic_item_mst_row.loct_ctl
    , x_ic_item_mst_row.noninv_ind
    , x_ic_item_mst_row.match_type
    , x_ic_item_mst_row.inactive_ind
    , x_ic_item_mst_row.inv_type
    , x_ic_item_mst_row.shelf_life
    , x_ic_item_mst_row.retest_interval
    , x_ic_item_mst_row.item_abccode
    , x_ic_item_mst_row.gl_class
    , x_ic_item_mst_row.inv_class
    , x_ic_item_mst_row.sales_class
    , x_ic_item_mst_row.ship_class
    , x_ic_item_mst_row.frt_class
    , x_ic_item_mst_row.price_class
    , x_ic_item_mst_row.storage_class
    , x_ic_item_mst_row.purch_class
    , x_ic_item_mst_row.tax_class
    , x_ic_item_mst_row.customs_class
    , x_ic_item_mst_row.alloc_class
    , x_ic_item_mst_row.planning_class
    , x_ic_item_mst_row.itemcost_class
    , x_ic_item_mst_row.cost_mthd_code
    , x_ic_item_mst_row.upc_code
    , x_ic_item_mst_row.grade_ctl
    , x_ic_item_mst_row.status_ctl
    , x_ic_item_mst_row.qc_grade
    , x_ic_item_mst_row.lot_status
    , x_ic_item_mst_row.bulk_id
    , x_ic_item_mst_row.pkg_id
    , x_ic_item_mst_row.qcitem_id
    , x_ic_item_mst_row.qchold_res_code
    , x_ic_item_mst_row.expaction_code
    , x_ic_item_mst_row.fill_qty
    , x_ic_item_mst_row.fill_um
    , x_ic_item_mst_row.expaction_interval
    , x_ic_item_mst_row.phantom_type
    , x_ic_item_mst_row.whse_item_id
    , x_ic_item_mst_row.experimental_ind
    , x_ic_item_mst_row.exported_date
    , x_ic_item_mst_row.created_by
    , x_ic_item_mst_row.creation_date
    , x_ic_item_mst_row.last_updated_by
    , x_ic_item_mst_row.last_update_date
    , x_ic_item_mst_row.last_update_login
    , x_ic_item_mst_row.trans_cnt
    , x_ic_item_mst_row.delete_mark
    , x_ic_item_mst_row.text_code
    , x_ic_item_mst_row.seq_dpnd_class
    , x_ic_item_mst_row.commodity_code
    , x_ic_item_mst_row.attribute1
    , x_ic_item_mst_row.attribute2
    , x_ic_item_mst_row.attribute3
    , x_ic_item_mst_row.attribute4
    , x_ic_item_mst_row.attribute5
    , x_ic_item_mst_row.attribute6
    , x_ic_item_mst_row.attribute7
    , x_ic_item_mst_row.attribute8
    , x_ic_item_mst_row.attribute9
    , x_ic_item_mst_row.attribute10
    , x_ic_item_mst_row.attribute11
    , x_ic_item_mst_row.attribute12
    , x_ic_item_mst_row.attribute13
    , x_ic_item_mst_row.attribute14
    , x_ic_item_mst_row.attribute15
    , x_ic_item_mst_row.attribute16
    , x_ic_item_mst_row.attribute17
    , x_ic_item_mst_row.attribute18
    , x_ic_item_mst_row.attribute19
    , x_ic_item_mst_row.attribute20
    , x_ic_item_mst_row.attribute21
    , x_ic_item_mst_row.attribute22
    , x_ic_item_mst_row.attribute23
    , x_ic_item_mst_row.attribute24
    , x_ic_item_mst_row.attribute25
    , x_ic_item_mst_row.attribute26
    , x_ic_item_mst_row.attribute27
    , x_ic_item_mst_row.attribute28
    , x_ic_item_mst_row.attribute29
    , x_ic_item_mst_row.attribute30
    , x_ic_item_mst_row.attribute_category
    , x_ic_item_mst_row.ont_pricing_qty_source   -- P Lowe Bug 2233859
    );

    GMIGUTL.DB_ERRNUM := NULL;

-- TKW 9/11/2003 B2378017 Moved gmi_item_categories to Create_Item procedure.
--Jalaj Srivastava Bug 1735676
--Item Categories convergence
    -- gmi_item_categories(x_ic_item_mst_row);

    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;

  END ic_item_mst_insert;


  --BEGIN BUG#3151733 Anoop.
  PROCEDURE mtl_item_categories_insert(p_ic_item_mst_row  IN ic_item_mst%ROWTYPE,
                                       l_category_set_id  IN NUMBER,l_category_id  IN NUMBER)
  IS
  CURSOR c_inventory_org IS
    SELECT  organization_id
    FROM    gmi_item_organizations
    UNION
    SELECT  distinct p.master_organization_id
    FROM    mtl_parameters p,
            gmi_item_organizations g
    WHERE   p.organization_id = g.organization_id;

  CURSOR   get_inventory_item_id(C_item_no VARCHAR2) IS
    SELECT inventory_item_id
    FROM   mtl_system_items
    WHERE  segment1 = C_item_no and
    ROWNUM = 1;

  CURSOR get_mult_item_cat_assign_flag IS
    SELECT mult_item_cat_assign_flag
    FROM mtl_category_sets
    WHERE category_set_id = l_category_set_id;

  l_inventory_item_id NUMBER;
  l_mult_item_cat_assign_flag mtl_category_sets.mult_item_cat_assign_flag%TYPE;
  BEGIN
        OPEN   get_inventory_item_id(p_ic_item_mst_row.ITEM_NO);
        FETCH  get_inventory_item_id into l_inventory_item_id;
        CLOSE  get_inventory_item_id;

        OPEN   get_mult_item_cat_assign_flag;
        FETCH  get_mult_item_cat_assign_flag into l_mult_item_cat_assign_flag;
        CLOSE  get_mult_item_cat_assign_flag;

        FOR Cur_get_organizations_rec IN c_inventory_org
        LOOP

        IF (l_mult_item_cat_assign_flag = 'N') THEN
          UPDATE mtl_item_categories
          SET category_id = l_category_id
          WHERE inventory_item_id = l_inventory_item_id
          AND organization_id = Cur_get_organizations_rec.organization_id
          AND category_set_id = l_category_set_id;
        END IF;

        IF ( (SQL%ROWCOUNT = 0) OR
             (l_mult_item_cat_assign_flag = 'Y')) THEN
          INSERT INTO mtl_item_categories(
                                            INVENTORY_ITEM_ID,
                                            ORGANIZATION_ID,
                                            CATEGORY_SET_ID,
                                            CATEGORY_ID,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            REQUEST_ID,
                                            PROGRAM_APPLICATION_ID,
                                            PROGRAM_ID,
                                            PROGRAM_UPDATE_DATE,
                                            WH_UPDATE_DATE
                                           )
                                     VALUES(
                                            l_inventory_item_id,
                                            Cur_get_organizations_rec.organization_id,
                                            l_category_set_id,
                                            l_category_id,
                                            p_ic_item_mst_row.last_update_date,
                                            p_ic_item_mst_row.last_updated_by,
                                            p_ic_item_mst_row.creation_date,
                                            p_ic_item_mst_row.created_by,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL
                                            );
        END IF;

        END LOOP;
  EXCEPTION
    WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;

  END mtl_item_categories_insert;
  --END BUG#3151733 Anoop.

  -- TKW 9/11/2003 B2378017 Changed signature of proc below.
  PROCEDURE GMI_ITEM_CATEGORIES (p_item_rec IN GMIGAPI.item_rec_typ, p_ic_item_mst_row  IN ic_item_mst%ROWTYPE)
  IS
  Cursor get_category_set_id(Vopm_class gmi_category_sets.opm_class%TYPE) IS
    SELECT gmi.category_set_id,mtl.structure_id
    FROM   gmi_category_sets gmi,
           mtl_category_sets mtl
    WHERE  gmi.opm_class       = Vopm_class
    AND    mtl.category_set_id = gmi.category_set_id;

  l_category_set_id NUMBER;
  l_category_id NUMBER;
  l_structure_id    NUMBER;

  BEGIN

    IF (p_ic_item_mst_row.alloc_class IS NOT NULL) THEN

        OPEN get_category_set_id('ALLOC_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.alloc_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set alloc_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    IF (p_ic_item_mst_row.itemcost_class IS NOT NULL) THEN

        OPEN get_category_set_id('COST_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.itemcost_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set cost_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    IF (p_ic_item_mst_row.customs_class IS NOT NULL) THEN

        OPEN get_category_set_id('CUSTOMS_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.customs_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set customs_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.frt_class IS NOT NULL) THEN

        OPEN get_category_set_id('FRT_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.frt_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set frt_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.gl_class IS NOT NULL) THEN

        OPEN get_category_set_id('GL_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.gl_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set gl_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    IF (p_ic_item_mst_row.inv_class IS NOT NULL) THEN

        OPEN get_category_set_id('INV_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.inv_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set inv_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    IF (p_ic_item_mst_row.price_class IS NOT NULL) THEN

        OPEN get_category_set_id('PRICE_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.price_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set price_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    IF (p_ic_item_mst_row.purch_class IS NOT NULL) THEN

        OPEN get_category_set_id('PURCH_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.purch_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set purch_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.sales_class IS NOT NULL) THEN

        OPEN get_category_set_id('SALES_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.sales_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set sales_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.ship_class IS NOT NULL) THEN

        OPEN get_category_set_id('SHIP_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.ship_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set ship_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.storage_class IS NOT NULL) THEN

        OPEN get_category_set_id('STORAGE_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.storage_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set storage_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.tax_class IS NOT NULL) THEN

        OPEN get_category_set_id('TAX_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.tax_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set tax_class = null
        WHERE  item_id = p_ic_item_mst_row.item_id;

        INSERT INTO IC_TAXN_ASC(
                                 ictax_class,
                                 tax_category_id,
                                 item_id,
                                 trans_cnt,
                                 text_code,
                                 delete_mark,
                                 creation_date,
                                 created_by,
                                 last_update_date,
                                 last_updated_by,
                                 last_update_login)
                        VALUES(
                                 p_ic_item_mst_row.tax_class,
                                 l_category_id,
                                 p_ic_item_mst_row.item_id,
                                 0,
                                 NULL,
                                 0,
                         p_ic_item_mst_row.creation_date,
                         p_ic_item_mst_row.created_by,
                         p_ic_item_mst_row.last_update_date,
                         p_ic_item_mst_row.last_updated_by,
                         p_ic_item_mst_row.last_update_login);

    END IF;


    IF (p_ic_item_mst_row.planning_class IS NOT NULL) THEN

        OPEN get_category_set_id('PLANNING_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.planning_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set planning_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;


    IF (p_ic_item_mst_row.seq_dpnd_class IS NOT NULL) THEN

        OPEN get_category_set_id('SEQ_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_ic_item_mst_row.seq_dpnd_class,
                                   l_structure_id,
                                   l_category_id);

        UPDATE ic_item_mst set seq_category_id = l_category_id
        WHERE  item_id = p_ic_item_mst_row.item_id;

    END IF;

    -- TKW 9/11/2003 B2378017 Added four new classes.
    IF (p_item_rec.gl_business_class IS NOT NULL) THEN

        OPEN get_category_set_id('GL_BUSINESS_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_item_rec.gl_business_class,
                                   l_structure_id,
                                   l_category_id);

    END IF;


    IF (p_item_rec.gl_prod_line IS NOT NULL) THEN

        OPEN get_category_set_id('GL_PRODUCT_LINE');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_item_rec.gl_prod_line,
                                   l_structure_id,
                                   l_category_id);

    END IF;


    IF (p_item_rec.sub_standard_class IS NOT NULL) THEN

        OPEN get_category_set_id('SUB_STANDARD_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_item_rec.sub_standard_class,
                                   l_structure_id,
                                   l_category_id);

    END IF;


    IF (p_item_rec.tech_class IS NOT NULL) THEN

        OPEN get_category_set_id('TECH_CLASS');
        FETCH get_category_set_id into l_category_set_id,l_structure_id;
        CLOSE get_category_set_id;

        gmi_item_categories_insert(p_ic_item_mst_row,
                                   l_category_set_id,
                                   p_item_rec.tech_class,
                                   l_structure_id,
                                   l_category_id);

    END IF;

  END GMI_ITEM_CATEGORIES;

  PROCEDURE GMI_ITEM_CATEGORIES_INSERT (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE,
                                        p_category_set_id NUMBER,
                                        p_category_concat_segs mtl_categories_v.category_concat_segs%TYPE,
                                        p_structure_id NUMBER,
                                        p_category_id  IN OUT NOCOPY NUMBER)
  IS
  Cursor get_category_id(Vcategory_concat_segs mtl_categories_v.category_concat_segs%TYPE,
                         Vstructure_id NUMBER) IS
    SELECT category_id
    FROM   mtl_categories_v
    WHERE  category_concat_segs = Vcategory_concat_segs
    AND    structure_id         = Vstructure_id;

  BEGIN
    OPEN   get_category_id(p_category_concat_segs,p_structure_id);
    FETCH  get_category_id INTO p_category_id;
    CLOSE  get_category_id;

    INSERT INTO gmi_item_categories(
                                    item_id,
                                    category_set_id,
                                    category_id,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login
                                   )
                     VALUES       (
                                   p_ic_item_mst_row.item_id,
                                   p_category_set_id,
                                   p_category_id,
                                   p_ic_item_mst_row.created_by,
                                   p_ic_item_mst_row.creation_date,
                                   p_ic_item_mst_row.last_updated_by,
                                   p_ic_item_mst_row.last_update_date,
                                   p_ic_item_mst_row.last_update_login
                                  );
    --BUG#3151733 Anoop.
    mtl_item_categories_insert(p_ic_item_mst_row,p_category_set_id,p_category_id);
  END GMI_ITEM_CATEGORIES_INSERT;


  FUNCTION ic_item_mst_select
    (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE, x_ic_item_mst_row IN OUT NOCOPY ic_item_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN

    IF p_ic_item_mst_row.item_no IS NOT NULL
	THEN
	  SELECT * INTO x_ic_item_mst_row FROM ic_item_mst
	  WHERE item_no=p_ic_item_mst_row.item_no;
	ELSE
	  SELECT * INTO x_ic_item_mst_row FROM ic_item_mst
	  WHERE item_id=p_ic_item_mst_row.item_id;
    END IF;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

	  GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;

  END ic_item_mst_select;

  FUNCTION ic_lots_mst_insert
    (p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE, x_ic_lots_mst_row IN OUT NOCOPY ic_lots_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN

    /*  Copy input to output assuming success */

    x_ic_lots_mst_row := p_ic_lots_mst_row;

    IF x_ic_lots_mst_row.lot_id IS NULL
	THEN
	  SELECT gem5_lot_id_s.nextval INTO x_ic_lots_mst_row.lot_id FROM dual;
	END IF;

    INSERT INTO ic_lots_mst
    ( item_id
    , lot_no
    , sublot_no
    , lot_id
    , lot_desc
    , qc_grade
    , expaction_code
    , expaction_date
    , lot_created
    , expire_date
    , retest_date
    , strength
    , inactive_ind
    , origination_type
    , shipvend_id
    , vendor_lot_no
    , creation_date
    , last_update_date
    , created_by
    , last_updated_by
    , trans_cnt
    , delete_mark
    , text_code
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute16
    , attribute17
    , attribute18
    , attribute19
    , attribute20
    , attribute21
    , attribute22
    , attribute23
    , attribute24
    , attribute25
    , attribute26
    , attribute27
    , attribute28
    , attribute29
    , attribute30
    , attribute_category
    )
    VALUES
    ( x_ic_lots_mst_row.item_id
    , x_ic_lots_mst_row.lot_no
    , x_ic_lots_mst_row.sublot_no
    , x_ic_lots_mst_row.lot_id
    , x_ic_lots_mst_row.lot_desc
    , x_ic_lots_mst_row.qc_grade
    , x_ic_lots_mst_row.expaction_code
    , x_ic_lots_mst_row.expaction_date
    , x_ic_lots_mst_row.lot_created
    , x_ic_lots_mst_row.expire_date
    , x_ic_lots_mst_row.retest_date
    , x_ic_lots_mst_row.strength
    , x_ic_lots_mst_row.inactive_ind
    , x_ic_lots_mst_row.origination_type
    , x_ic_lots_mst_row.shipvend_id
    , x_ic_lots_mst_row.vendor_lot_no
    , x_ic_lots_mst_row.creation_date
    , x_ic_lots_mst_row.last_update_date
    , x_ic_lots_mst_row.created_by
    , x_ic_lots_mst_row.last_updated_by
    , x_ic_lots_mst_row.trans_cnt
    , x_ic_lots_mst_row.delete_mark
    , x_ic_lots_mst_row.text_code
    , x_ic_lots_mst_row.attribute1
    , x_ic_lots_mst_row.attribute2
    , x_ic_lots_mst_row.attribute3
    , x_ic_lots_mst_row.attribute4
    , x_ic_lots_mst_row.attribute5
    , x_ic_lots_mst_row.attribute6
    , x_ic_lots_mst_row.attribute7
    , x_ic_lots_mst_row.attribute8
    , x_ic_lots_mst_row.attribute9
    , x_ic_lots_mst_row.attribute10
    , x_ic_lots_mst_row.attribute11
    , x_ic_lots_mst_row.attribute12
    , x_ic_lots_mst_row.attribute13
    , x_ic_lots_mst_row.attribute14
    , x_ic_lots_mst_row.attribute15
    , x_ic_lots_mst_row.attribute16
    , x_ic_lots_mst_row.attribute17
    , x_ic_lots_mst_row.attribute18
    , x_ic_lots_mst_row.attribute19
    , x_ic_lots_mst_row.attribute20
    , x_ic_lots_mst_row.attribute21
    , x_ic_lots_mst_row.attribute22
    , x_ic_lots_mst_row.attribute23
    , x_ic_lots_mst_row.attribute24
    , x_ic_lots_mst_row.attribute25
    , x_ic_lots_mst_row.attribute26
    , x_ic_lots_mst_row.attribute27
    , x_ic_lots_mst_row.attribute28
    , x_ic_lots_mst_row.attribute29
    , x_ic_lots_mst_row.attribute30
    , x_ic_lots_mst_row.attribute_category
    );

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
      -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_lots_mst_insert;

  FUNCTION ic_lots_mst_select
    (p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE, x_ic_lots_mst_row IN OUT NOCOPY ic_lots_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_ic_lots_mst_row FROM ic_lots_mst
	WHERE item_id = p_ic_lots_mst_row.item_id AND
	      lot_no = p_ic_lots_mst_row.lot_no AND
              NVL(sublot_no,' ')=NVL(p_ic_lots_mst_row.sublot_no,' ');
    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_lots_mst_select;

  FUNCTION ic_item_cpg_insert
    (p_ic_item_cpg_row  IN ic_item_cpg%ROWTYPE, x_ic_item_cpg_row IN OUT NOCOPY ic_item_cpg%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    /*  Copy input to output */

    x_ic_item_cpg_row := p_ic_item_cpg_row;

    INSERT INTO ic_item_cpg
    ( item_id
    , ic_matr_days
    , ic_hold_days
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    )
    VALUES
    ( x_ic_item_cpg_row.item_id
    , x_ic_item_cpg_row.ic_matr_days
    , x_ic_item_cpg_row.ic_hold_days
    , x_ic_item_cpg_row.created_by
    , x_ic_item_cpg_row.creation_date
    , x_ic_item_cpg_row.last_updated_by
    , x_ic_item_cpg_row.last_update_date
    , x_ic_item_cpg_row.last_update_login
    );

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_item_cpg_insert;

  FUNCTION ic_item_cpg_select
    (p_ic_item_cpg_row  IN ic_item_cpg%ROWTYPE, x_ic_item_cpg_row IN OUT NOCOPY ic_item_cpg%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_ic_item_cpg_row FROM ic_item_cpg
	WHERE item_id = p_ic_item_cpg_row.item_id;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	  -- Bug 1764383
     -- Added code to return sqlerrm in case of unexpected database errors.
     FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_item_cpg_select;

  FUNCTION ic_lots_cpg_insert
    (p_ic_lots_cpg_row  IN ic_lots_cpg%ROWTYPE, x_ic_lots_cpg_row IN OUT NOCOPY ic_lots_cpg%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    /*  Copy input to output */

    x_ic_lots_cpg_row := p_ic_lots_cpg_row;

    INSERT INTO ic_lots_cpg
    ( item_id
    , lot_id
    , ic_matr_date
    , ic_hold_date
    , created_by
    , creation_date
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    VALUES
    ( x_ic_lots_cpg_row.item_id
    , x_ic_lots_cpg_row.lot_id
    , x_ic_lots_cpg_row.ic_matr_date
    , x_ic_lots_cpg_row.ic_hold_date
    , x_ic_lots_cpg_row.created_by
    , x_ic_lots_cpg_row.creation_date
    , x_ic_lots_cpg_row.last_update_date
    , x_ic_lots_cpg_row.last_updated_by
    , x_ic_lots_cpg_row.last_update_login
    );

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_lots_cpg_insert;

  FUNCTION ic_lots_cpg_select
    (p_ic_lots_cpg_row  IN ic_lots_cpg%ROWTYPE, x_ic_lots_cpg_row IN OUT NOCOPY ic_lots_cpg%ROWTYPE)
  RETURN BOOLEAN
  IS BEGIN

    SELECT * INTO x_ic_lots_cpg_row FROM ic_lots_cpg
	WHERE item_id = p_ic_lots_cpg_row.item_id AND
	      lot_id = p_ic_lots_cpg_row.lot_id;
    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_lots_cpg_select;

  FUNCTION ic_lots_sts_select
    (p_ic_lots_sts_row  IN ic_lots_sts%ROWTYPE, x_ic_lots_sts_row IN OUT NOCOPY ic_lots_sts%ROWTYPE)
  RETURN BOOLEAN
  IS BEGIN

    SELECT * INTO x_ic_lots_sts_row FROM ic_lots_sts
	WHERE lot_status= p_ic_lots_sts_row.lot_status;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_lots_sts_select;

  FUNCTION ic_jrnl_mst_insert
    (p_ic_jrnl_mst_row  IN ic_jrnl_mst%ROWTYPE, x_ic_jrnl_mst_row IN OUT NOCOPY ic_jrnl_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    /*  Copy input to output */
  --Jalaj Srivastava Bug 2483656
  --If journal no exists, no need to insert it
  IF ( NOT ic_jrnl_mst_select
          (p_ic_jrnl_mst_row => p_ic_jrnl_mst_row,
	   x_ic_jrnl_mst_row => x_ic_jrnl_mst_row
          )
     ) THEN
    x_ic_jrnl_mst_row := p_ic_jrnl_mst_row;

    IF x_ic_jrnl_mst_row.journal_id IS NULL
	THEN
	  SELECT gem5_journal_id_s.nextval INTO x_ic_jrnl_mst_row.journal_id FROM DUAL;
    END IF;

    INSERT INTO ic_jrnl_mst
    ( journal_id
    , journal_no
    , journal_comment
    , posting_id
    , print_cnt
    , posted_ind
    , orgn_code
    , creation_date
    , last_update_date
    , created_by
    , last_updated_by
    , delete_mark
    , text_code
    , in_use
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute16
    , attribute17
    , attribute18
    , attribute19
    , attribute20
    , attribute21
    , attribute22
    , attribute23
    , attribute24
    , attribute25
    , attribute26
    , attribute27
    , attribute28
    , attribute29
    , attribute30
    , attribute_category
    )
    VALUES
    ( x_ic_jrnl_mst_row.journal_id
    , x_ic_jrnl_mst_row.journal_no
    , x_ic_jrnl_mst_row.journal_comment
    , x_ic_jrnl_mst_row.posting_id
    , x_ic_jrnl_mst_row.print_cnt
    , x_ic_jrnl_mst_row.posted_ind
    , x_ic_jrnl_mst_row.orgn_code
    , x_ic_jrnl_mst_row.creation_date
    , x_ic_jrnl_mst_row.last_update_date
    , x_ic_jrnl_mst_row.created_by
    , x_ic_jrnl_mst_row.last_updated_by
    , x_ic_jrnl_mst_row.delete_mark
    , x_ic_jrnl_mst_row.text_code
    , x_ic_jrnl_mst_row.in_use
    , x_ic_jrnl_mst_row.attribute1
    , x_ic_jrnl_mst_row.attribute2
    , x_ic_jrnl_mst_row.attribute3
    , x_ic_jrnl_mst_row.attribute4
    , x_ic_jrnl_mst_row.attribute5
    , x_ic_jrnl_mst_row.attribute6
    , x_ic_jrnl_mst_row.attribute7
    , x_ic_jrnl_mst_row.attribute8
    , x_ic_jrnl_mst_row.attribute9
    , x_ic_jrnl_mst_row.attribute10
    , x_ic_jrnl_mst_row.attribute11
    , x_ic_jrnl_mst_row.attribute12
    , x_ic_jrnl_mst_row.attribute13
    , x_ic_jrnl_mst_row.attribute14
    , x_ic_jrnl_mst_row.attribute15
    , x_ic_jrnl_mst_row.attribute16
    , x_ic_jrnl_mst_row.attribute17
    , x_ic_jrnl_mst_row.attribute18
    , x_ic_jrnl_mst_row.attribute19
    , x_ic_jrnl_mst_row.attribute20
    , x_ic_jrnl_mst_row.attribute21
    , x_ic_jrnl_mst_row.attribute22
    , x_ic_jrnl_mst_row.attribute23
    , x_ic_jrnl_mst_row.attribute24
    , x_ic_jrnl_mst_row.attribute25
    , x_ic_jrnl_mst_row.attribute26
    , x_ic_jrnl_mst_row.attribute27
    , x_ic_jrnl_mst_row.attribute28
    , x_ic_jrnl_mst_row.attribute29
    , x_ic_jrnl_mst_row.attribute30
    , x_ic_jrnl_mst_row.attribute_category
    );
  END IF;
    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_jrnl_mst_insert;

  FUNCTION ic_jrnl_mst_select
    (p_ic_jrnl_mst_row  IN ic_jrnl_mst%ROWTYPE, x_ic_jrnl_mst_row IN OUT NOCOPY ic_jrnl_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN

    IF p_ic_jrnl_mst_row.journal_no IS NOT NULL AND
	   p_ic_jrnl_mst_row.orgn_code IS NOT NULL
	THEN
	  SELECT * INTO x_ic_jrnl_mst_row FROM ic_jrnl_mst
	  WHERE orgn_code = p_ic_jrnl_mst_row.orgn_code AND
	        journal_no = p_ic_jrnl_mst_row.journal_no;
    ELSE
	  SELECT * INTO x_ic_jrnl_mst_row FROM ic_jrnl_mst
	  WHERE journal_id = p_ic_jrnl_mst_row.journal_id;
    END IF;
    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_jrnl_mst_select;

  FUNCTION ic_adjs_jnl_insert
    (p_ic_adjs_jnl_row  IN ic_adjs_jnl%ROWTYPE, x_ic_adjs_jnl_row IN OUT NOCOPY ic_adjs_jnl%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    /*  Copy input to output */

    x_ic_adjs_jnl_row := p_ic_adjs_jnl_row;

    IF x_ic_adjs_jnl_row.doc_id IS NULL
	THEN
	  SELECT gem5_doc_id_s.nextval INTO x_ic_adjs_jnl_row.doc_id FROM dual;
	END IF;

    IF x_ic_adjs_jnl_row.line_id IS NULL
	THEN
	  SELECT gem5_line_id_s.nextval INTO x_ic_adjs_jnl_row.line_id FROM dual;
	END IF;

    INSERT INTO ic_adjs_jnl
    ( trans_type
    , trans_flag
    , doc_id
    , doc_line
    , journal_id
    , completed_ind
    , whse_code
    , reason_code
    , doc_date
    , item_id
    , item_um
    , item_um2
    , lot_id
    , location
    , qty
    , qty2
    , qc_grade
    , lot_status
    , line_type
    , line_id
    , co_code
    , orgn_code
    , no_inv
    , no_trans
    , creation_date
    , created_by
    , last_update_date
    , trans_cnt
    , last_updated_by
    , acctg_unit_id
    , acct_id
    )
    VALUES
    ( x_ic_adjs_jnl_row.trans_type
    , x_ic_adjs_jnl_row.trans_flag
    , x_ic_adjs_jnl_row.doc_id
    , x_ic_adjs_jnl_row.doc_line
    , x_ic_adjs_jnl_row.journal_id
    , x_ic_adjs_jnl_row.completed_ind
    , x_ic_adjs_jnl_row.whse_code
    , x_ic_adjs_jnl_row.reason_code
    , x_ic_adjs_jnl_row.doc_date
    , x_ic_adjs_jnl_row.item_id
    , x_ic_adjs_jnl_row.item_um
    , x_ic_adjs_jnl_row.item_um2
    , x_ic_adjs_jnl_row.lot_id
    , x_ic_adjs_jnl_row.location
    , x_ic_adjs_jnl_row.qty
    , x_ic_adjs_jnl_row.qty2
    , x_ic_adjs_jnl_row.qc_grade
    , x_ic_adjs_jnl_row.lot_status
    , x_ic_adjs_jnl_row.line_type
    , x_ic_adjs_jnl_row.line_id
    , x_ic_adjs_jnl_row.co_code
    , x_ic_adjs_jnl_row.orgn_code
    , x_ic_adjs_jnl_row.no_inv
    , x_ic_adjs_jnl_row.no_trans
    , x_ic_adjs_jnl_row.creation_date
    , x_ic_adjs_jnl_row.created_by
    , x_ic_adjs_jnl_row.last_update_date
    , x_ic_adjs_jnl_row.trans_cnt
    , x_ic_adjs_jnl_row.last_updated_by
    , x_ic_adjs_jnl_row.acctg_unit_id
    , x_ic_adjs_jnl_row.acct_id
    );

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_adjs_jnl_insert;

  FUNCTION sy_reas_cds_select
    (p_sy_reas_cds_row  IN sy_reas_cds%ROWTYPE, x_sy_reas_cds_row IN OUT NOCOPY sy_reas_cds%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_sy_reas_cds_row FROM sy_reas_cds
	WHERE reason_code = p_sy_reas_cds_row.reason_code;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END sy_reas_cds_select;





  FUNCTION ic_item_cnv_insert
    (p_ic_item_cnv_row  IN ic_item_cnv%ROWTYPE, x_ic_item_cnv_row IN OUT NOCOPY ic_item_cnv%ROWTYPE)
  RETURN BOOLEAN


  IS
x_conv_audit_id         GMI_ITEM_CONV_AUDIT.CONV_AUDIT_ID%TYPE;
x_reason_code           SY_REAS_CDS.REASON_CODE%TYPE := null;
x_type_factor           IC_ITEM_CNV.TYPE_FACTOR%TYPE := null;
x_event_spec_disp_id    IC_ITEM_CNV.EVENT_SPEC_DISP_ID%TYPE := null;

  BEGIN

    x_ic_item_cnv_row := p_ic_item_cnv_row;

    IF (x_ic_item_cnv_row.conversion_id IS NULL) THEN
       select gmi_conversion_id_s.nextval into
           x_ic_item_cnv_row.conversion_id from dual;
    END IF;
    INSERT INTO ic_item_cnv
    ( item_id
    , lot_id
    , um_type
    , type_factor
    , creation_date
    , last_update_date
    , created_by
    , last_updated_by
    , trans_cnt
    , delete_mark
    , text_code
    , type_factorrev
    , last_update_login
    , conversion_id
    )
    VALUES
    ( p_ic_item_cnv_row.item_id
    , p_ic_item_cnv_row.lot_id
    , p_ic_item_cnv_row.um_type
    , p_ic_item_cnv_row.type_factor
    , p_ic_item_cnv_row.creation_date
    , p_ic_item_cnv_row.last_update_date
    , p_ic_item_cnv_row.created_by
    , p_ic_item_cnv_row.last_updated_by
    , p_ic_item_cnv_row.trans_cnt
    , p_ic_item_cnv_row.delete_mark
    , p_ic_item_cnv_row.text_code
    , p_ic_item_cnv_row.type_factorrev
    , p_ic_item_cnv_row.last_update_login
    , p_ic_item_cnv_row.conversion_id
    );

/*   15-Apr-2003   Joe DiIorio  Bug 2880585 11.5.1K - */

/*   24-June-2003  Joe DiIorio  Bug 3022564 11.5.10K - */
    select gmi_conv_audit_id_s.nextval into
           x_conv_audit_id from dual;

    INSERT INTO gmi_item_conv_audit
    ( conv_audit_id
    , conversion_id
    , conversion_date
    , reason_code
    , old_type_factor
    , new_type_factor
    , event_spec_disp_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_login
    , last_update_date
    )
    VALUES
    ( x_conv_audit_id
    , p_ic_item_cnv_row.conversion_id
    , p_ic_item_cnv_row.creation_date
    , x_reason_code
    , x_type_factor
    , p_ic_item_cnv_row.type_factor
    , x_event_spec_disp_id
    , p_ic_item_cnv_row.created_by
    , p_ic_item_cnv_row.creation_date
    , p_ic_item_cnv_row.last_updated_by
    , p_ic_item_cnv_row.last_update_login
    , p_ic_item_cnv_row.last_update_date
    );


    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_item_cnv_insert;

  FUNCTION sy_uoms_mst_select
    (p_sy_uoms_mst_row  IN sy_uoms_mst%ROWTYPE, x_sy_uoms_mst_row IN OUT NOCOPY sy_uoms_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_sy_uoms_mst_row FROM sy_uoms_mst
	WHERE um_code = p_sy_uoms_mst_row.um_code AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END sy_uoms_mst_select;

  FUNCTION sy_uoms_typ_select
    (p_sy_uoms_typ_row  IN sy_uoms_typ%ROWTYPE, x_sy_uoms_typ_row IN OUT NOCOPY sy_uoms_typ%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_sy_uoms_typ_row FROM sy_uoms_typ
	WHERE um_type = p_sy_uoms_typ_row.um_type AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END sy_uoms_typ_select;






  FUNCTION ic_whse_mst_select
    (p_ic_whse_mst_row  IN ic_whse_mst%ROWTYPE, x_ic_whse_mst_row IN OUT NOCOPY ic_whse_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_ic_whse_mst_row FROM ic_whse_mst
	WHERE whse_code = p_ic_whse_mst_row.whse_code AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_whse_mst_select;

  FUNCTION ic_loct_inv_select
    (p_ic_loct_inv_row  IN ic_loct_inv%ROWTYPE, x_ic_loct_inv_row IN OUT NOCOPY ic_loct_inv%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_ic_loct_inv_row FROM ic_loct_inv
	WHERE whse_code = NVL(p_ic_loct_inv_row.whse_code, whse_code) AND
            item_id = p_ic_loct_inv_row.item_id AND
            lot_id = p_ic_loct_inv_row.lot_id AND
            location = NVL(p_ic_loct_inv_row.location, location) AND
            ROWNUM = 1
            AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND
        THEN
        x_ic_loct_inv_row.loct_onhand:= NULL;
        GMIGUTL.DB_ERRNUM := SQLCODE;
        GMIGUTL.DB_ERRMSG:= SQLERRM;
        RETURN FALSE;

      WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_loct_inv_select;

  FUNCTION qc_grad_mst_select
    (p_qc_grad_mst_row  IN qc_grad_mst%ROWTYPE, x_qc_grad_mst_row IN OUT NOCOPY qc_grad_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_qc_grad_mst_row FROM qc_grad_mst
	WHERE qc_grade = p_qc_grad_mst_row.qc_grade AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END qc_grad_mst_select;

  FUNCTION qc_actn_mst_select
    (p_qc_actn_mst_row  IN qc_actn_mst%ROWTYPE, x_qc_actn_mst_row IN OUT NOCOPY qc_actn_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_qc_actn_mst_row FROM qc_actn_mst
	WHERE action_code = p_qc_actn_mst_row.action_code AND delete_mark=0;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

      WHEN OTHERS THEN
      -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END qc_actn_mst_select;

  FUNCTION po_vend_mst_select
    (p_po_vend_mst_row  IN po_vend_mst%ROWTYPE, x_po_vend_mst_row IN OUT NOCOPY po_vend_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_po_vend_mst_row FROM po_vend_mst
	WHERE vendor_no=p_po_vend_mst_row.vendor_no AND delete_mark=0 AND
        rownum=1;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
	   -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END po_vend_mst_select;
/*

  FUNCTION ic_xfer_mst_select
    (p_ic_xfer_mst_row  IN ic_xfer_mst%ROWTYPE, x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT * INTO x_ic_xfer_mst_row FROM ic_xfer_mst
	WHERE orgn_code = p_ic_xfer_mst_row.orgn_code AND
              transfer_no = p_ic_xfer_mst_row.transfer_no;

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --Jalaj Srivastava Bug 1977956
         --Do not add error using fnd_msg_pub.add
         --This is a expected error.

          GMIGUTL.DB_ERRNUM := SQLCODE;
          GMIGUTL.DB_ERRMSG:= SQLERRM;
          RETURN FALSE;

    WHEN OTHERS THEN
      -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;
  END ic_xfer_mst_select;


  FUNCTION ic_xfer_mst_insert
    (  p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE
     , x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN
  IS
  BEGIN
    x_ic_xfer_mst_row := p_ic_xfer_mst_row;
    IF x_ic_xfer_mst_row.transfer_id IS NULL
    THEN
      SELECT gem5_transfer_id.nextval INTO x_ic_xfer_mst_row.transfer_id
      FROM dual;
    END IF;

    INSERT INTO ic_xfer_mst
				(transfer_id,
				 transfer_no,
				 orgn_code,
				 transfer_status,
				 item_id,
				 lot_id,
				 lot_status,
				 release_reason_code,
				 receive_reason_code,
				 cancel_reason_code,
				 from_warehouse,
				 from_location,
				 to_warehouse,
				 to_location,
				 release_quantity1,
				 release_quantity2,
                                 release_uom1,
				 release_uom2,
				 receive_quantity1,
				 receive_quantity2,
				 scheduled_release_date,
				 actual_release_date,
				 scheduled_receive_date,
				 actual_receive_date,
				 cancel_date,
				 delete_mark,
				 received_by,
				 released_by,
				 canceled_by,
				 text_code,
				 comments,
				 attribute_category ,
				 attribute1 ,
				 attribute2 ,
				 attribute3 ,
				 attribute4 ,
				 attribute5 ,
				 attribute6 ,
				 attribute7 ,
				 attribute8 ,
				 attribute9 ,
				 attribute10 ,
				 attribute11 ,
				 attribute12 ,
				 attribute13 ,
				 attribute14 ,
				 attribute15 ,
				 attribute16 ,
				 attribute17 ,
				 attribute18 ,
				 attribute19 ,
				 attribute20 ,
				 attribute21 ,
				 attribute22 ,
				 attribute23 ,
				 attribute24 ,
				 attribute25 ,
				 attribute26 ,
				 attribute27 ,
				 attribute28 ,
				 attribute29 ,
				 attribute30 ,
				 created_by ,
				 creation_date ,
				 last_updated_by ,
				 last_update_date ,
				 last_update_login)
    VALUES
				(x_ic_xfer_mst_row.transfer_id	,
				 x_ic_xfer_mst_row.transfer_no ,
				 x_ic_xfer_mst_row.orgn_code ,
				 x_ic_xfer_mst_row.transfer_status ,
				 x_ic_xfer_mst_row.item_id ,
				 x_ic_xfer_mst_row.lot_id ,
				 x_ic_xfer_mst_row.lot_status ,
				 x_ic_xfer_mst_row.release_reason_code ,
                                 x_ic_xfer_mst_row.receive_reason_code ,
				 x_ic_xfer_mst_row.cancel_reason_code ,
				 x_ic_xfer_mst_row.from_warehouse ,
				 x_ic_xfer_mst_row.from_location ,
				 x_ic_xfer_mst_row.to_warehouse ,
				 x_ic_xfer_mst_row.to_location ,
				 x_ic_xfer_mst_row.release_quantity1 ,
				 x_ic_xfer_mst_row.release_quantity2 ,
				 x_ic_xfer_mst_row.release_uom1,
				 x_ic_xfer_mst_row.release_uom2,
				 x_ic_xfer_mst_row.receive_quantity1,
				 x_ic_xfer_mst_row.receive_quantity2,
				 x_ic_xfer_mst_row.scheduled_release_date ,
				 x_ic_xfer_mst_row.actual_release_date ,
				 x_ic_xfer_mst_row.scheduled_receive_date ,
				 x_ic_xfer_mst_row.actual_receive_date ,
				 x_ic_xfer_mst_row.cancel_date	,					         x_ic_xfer_mst_row.delete_mark ,
				 x_ic_xfer_mst_row.received_by ,
				 x_ic_xfer_mst_row.released_by ,
				 x_ic_xfer_mst_row.canceled_by ,
				 x_ic_xfer_mst_row.text_code ,
				 x_ic_xfer_mst_row.comments ,
				 x_ic_xfer_mst_row.attribute_category ,
				 x_ic_xfer_mst_row.attribute1 ,
				 x_ic_xfer_mst_row.attribute2 ,
				 x_ic_xfer_mst_row.attribute3 ,
				 x_ic_xfer_mst_row.attribute4 ,
				 x_ic_xfer_mst_row.attribute5 ,
				 x_ic_xfer_mst_row.attribute6 ,
				 x_ic_xfer_mst_row.attribute7 ,
				 x_ic_xfer_mst_row.attribute8 ,
				 x_ic_xfer_mst_row.attribute9 ,
				 x_ic_xfer_mst_row.attribute10 ,
				 x_ic_xfer_mst_row.attribute11 ,
				 x_ic_xfer_mst_row.attribute12 ,
				 x_ic_xfer_mst_row.attribute13 ,
				 x_ic_xfer_mst_row.attribute14 ,
				 x_ic_xfer_mst_row.attribute15 ,
				 x_ic_xfer_mst_row.attribute16 ,
				 x_ic_xfer_mst_row.attribute17 ,
				 x_ic_xfer_mst_row.attribute18 ,
				 x_ic_xfer_mst_row.attribute19 ,
				 x_ic_xfer_mst_row.attribute20 ,
				 x_ic_xfer_mst_row.attribute21 ,
				 x_ic_xfer_mst_row.attribute22 ,
				 x_ic_xfer_mst_row.attribute23 ,
				 x_ic_xfer_mst_row.attribute24 ,
				 x_ic_xfer_mst_row.attribute25 ,
				 x_ic_xfer_mst_row.attribute26 ,
				 x_ic_xfer_mst_row.attribute27 ,
				 x_ic_xfer_mst_row.attribute28 ,
				 x_ic_xfer_mst_row.attribute29 ,
				 x_ic_xfer_mst_row.attribute30 ,
				 x_ic_xfer_mst_row.created_by ,
				 x_ic_xfer_mst_row.creation_date ,
				 x_ic_xfer_mst_row.last_updated_by ,
				 x_ic_xfer_mst_row.last_update_date ,
				 x_ic_xfer_mst_row.last_update_login);

    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
    WHEN OTHERS THEN
      -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;

  END ic_xfer_mst_insert;


  FUNCTION ic_xfer_mst_update
    (  p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE
     , x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE
    )
  RETURN BOOLEAN
  IS
  BEGIN

    UPDATE ic_xfer_mst
    SET
       transfer_status    = x_ic_xfer_mst_row.transfer_status,
       item_id    	= x_ic_xfer_mst_row.item_id,
       lot_id    	= x_ic_xfer_mst_row.lot_id,
       lot_status    	= x_ic_xfer_mst_row.lot_status,
       release_reason_code  	= x_ic_xfer_mst_row.release_reason_code,
       receive_reason_code  	= x_ic_xfer_mst_row.receive_reason_code,
       cancel_reason_code    = x_ic_xfer_mst_row.cancel_reason_code,
       from_warehouse    = x_ic_xfer_mst_row.from_warehouse,
       from_location    = x_ic_xfer_mst_row.from_location,
       to_warehouse    = x_ic_xfer_mst_row.to_warehouse,
       to_location    = x_ic_xfer_mst_row.to_location,
       release_quantity1    = x_ic_xfer_mst_row.release_quantity1,
       release_quantity2    = x_ic_xfer_mst_row.release_quantity2,
       release_uom1    = x_ic_xfer_mst_row.release_uom1,
       release_uom2    = x_ic_xfer_mst_row.release_uom2,
       receive_quantity1    = x_ic_xfer_mst_row.receive_quantity1,
       receive_quantity2    = x_ic_xfer_mst_row.receive_quantity2,
       scheduled_release_date  	= x_ic_xfer_mst_row.scheduled_release_date,
       actual_release_date  	= x_ic_xfer_mst_row.actual_release_date,
       scheduled_receive_date 	= x_ic_xfer_mst_row.scheduled_receive_date,
       actual_receive_date  	= x_ic_xfer_mst_row.actual_receive_date,
       cancel_date	   = x_ic_xfer_mst_row.cancel_date,
       delete_mark    = x_ic_xfer_mst_row.delete_mark,
       received_by    = x_ic_xfer_mst_row.received_by,
       released_by    = x_ic_xfer_mst_row.released_by,
       canceled_by    = x_ic_xfer_mst_row.canceled_by,
       text_code    	= x_ic_xfer_mst_row.text_code,
       comments    	= x_ic_xfer_mst_row.comments,
       attribute_category    = x_ic_xfer_mst_row.attribute_category,
       attribute1    	= x_ic_xfer_mst_row.attribute1,
       attribute2    	= x_ic_xfer_mst_row.attribute2,
       attribute3    	= x_ic_xfer_mst_row.attribute3,
       attribute4    	= x_ic_xfer_mst_row.attribute4,
       attribute5    	= x_ic_xfer_mst_row.attribute5,
       attribute6    	= x_ic_xfer_mst_row.attribute6,
       attribute7    	= x_ic_xfer_mst_row.attribute7,
       attribute8    	= x_ic_xfer_mst_row.attribute8,
       attribute9    	= x_ic_xfer_mst_row.attribute9,
       attribute10    = x_ic_xfer_mst_row.attribute10,
       attribute11    = x_ic_xfer_mst_row.attribute11,
       attribute12    = x_ic_xfer_mst_row.attribute12,
       attribute13    = x_ic_xfer_mst_row.attribute13,
       attribute14    = x_ic_xfer_mst_row.attribute14,
       attribute15    = x_ic_xfer_mst_row.attribute15,
       attribute16    = x_ic_xfer_mst_row.attribute16,
       attribute17    = x_ic_xfer_mst_row.attribute17,
       attribute18    = x_ic_xfer_mst_row.attribute18,
       attribute19    = x_ic_xfer_mst_row.attribute19,
       attribute20    = x_ic_xfer_mst_row.attribute20,
       attribute21    = x_ic_xfer_mst_row.attribute21,
       attribute22    = x_ic_xfer_mst_row.attribute22,
       attribute23    = x_ic_xfer_mst_row.attribute23,
       attribute24    = x_ic_xfer_mst_row.attribute24,
       attribute25    = x_ic_xfer_mst_row.attribute25,
       attribute26    = x_ic_xfer_mst_row.attribute26,
       attribute27    = x_ic_xfer_mst_row.attribute27,
       attribute28    = x_ic_xfer_mst_row.attribute28,
       attribute29    = x_ic_xfer_mst_row.attribute29,
       attribute30    = x_ic_xfer_mst_row.attribute30,
       created_by    	= x_ic_xfer_mst_row.created_by,
       creation_date   = x_ic_xfer_mst_row.creation_date,
       last_updated_by    = x_ic_xfer_mst_row.last_updated_by,
       last_update_date    = x_ic_xfer_mst_row.last_update_date,
       last_update_login    = x_ic_xfer_mst_row.last_update_login
    WHERE
       transfer_no= p_ic_xfer_mst_row.transfer_no AND
        orgn_code = p_ic_xfer_mst_row.orgn_code;
    GMIGUTL.DB_ERRNUM := NULL;
    RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
		 -- Bug 1764383
      -- Added code to return sqlerrm in case of unexpected database errors.
      FND_MESSAGE.SET_NAME('GMI', 'GMI_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;

	  GMIGUTL.DB_ERRNUM := SQLCODE;
	  GMIGUTL.DB_ERRMSG:= SQLERRM;
	  RETURN FALSE;

  END ic_xfer_mst_update;
*/
END GMIVDBL;

/
