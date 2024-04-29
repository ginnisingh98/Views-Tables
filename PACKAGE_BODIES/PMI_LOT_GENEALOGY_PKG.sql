--------------------------------------------------------
--  DDL for Package Body PMI_LOT_GENEALOGY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_LOT_GENEALOGY_PKG" AS
    /* $Header: PMILTGEB.pls 115.10 2002/12/05 17:01:03 skarimis ship $ */

/*
	Package: pmi_lot_genealogy
	Source Code File: PMILGENB.pls

	Maintenance Log:

	Date		Author		Description
	------------	-------------	--------------------------
	08-Jan-2000	P. Dong		Consolidated individual procedures into this pkg.
	30-Jan-2000	P. Dong		Changed name of source code file and package
	30-Jan-2000	P. Dong		Added DISTINCT to gen_cursor
	30-Jan-2000	P. Dong		Removed Circular Ref check from add_doc_genealogy
	30-Jan-2000	P. Dong		Added Net Change functionality
	13-Jun-2000	P. Dong		removed date dependency in doc_genealogy cursor. Doc
                                        genealogies should be removed or added for entire doc.
                                        Date param removed from add and remove _current_genealogy
	13-Jun-2000	P. Dong		Put getting and setting of last_refresh_date into indiv
                                        code units, in anticipation of change of access meth.
	08-Feb-2002	P. Dong		Add call to fnd_stats.gather_table_stats
*/
  transaction_duration CONSTANT NUMBER := 1/24/60; -- in minutes
  datetime_format CONSTANT VARCHAR2(32) := 'DD-MON-YYYY HH24:MI:SS';

  CURSOR doc_genealogy(cp_doc_id NUMBER) IS
  SELECT
      gen1.product_item_id, gen1.product_lot_id,
      gen2.ingred_item_id, gen2.ingred_lot_id
  FROM
      pmi_lot_genealogy gen1, pmi_lot_genealogy gen2,
      (
        SELECT
          product.item_id product_item_id, product.lot_id product_lot_id,
          ingred.item_id ingred_item_id,   ingred.lot_id ingred_lot_id
        FROM
          ic_tran_pnd product, ic_tran_pnd ingred
        WHERE
            product.doc_type = 'PROD'
        AND product.doc_id = cp_doc_id
        AND product.line_type in (1,2)
        AND product.completed_ind = 1
        AND product.lot_id <> 0
        AND ingred.doc_type = 'PROD'
        AND ingred.doc_id = cp_doc_id
        AND ingred.completed_ind = 1
        AND ingred.line_type = -1
        AND ingred.lot_id <> 0
        AND ingred.lot_id <> product.lot_id
        GROUP BY
          product.item_id, product.lot_id,
          ingred.item_id,  ingred.lot_id
        HAVING
          SUM(ingred.trans_qty) <> 0
        OR  SUM(product.trans_qty) <> 0
      ) bom
  WHERE
      gen1.ingred_lot_id = bom.product_lot_id
  AND gen2.product_lot_id = bom.ingred_lot_id;


FUNCTION get_last_refresh_date
RETURN DATE
IS
  lv_date DATE;
BEGIN
    BEGIN
        lv_date := TO_DATE(fnd_profile.value('PMI$LOTGEN_REFRESH_DATE'), datetime_format);
    EXCEPTION
        WHEN OTHERS THEN
            SELECT MIN(trans_date) into lv_date
            FROM ic_tran_vw1
            WHERE doc_type = 'PROD'
            AND completed_ind = 1
            AND lot_id <> 0;
    END;                                                                                                              RETURN lv_date;
END;


FUNCTION get_current_refresh_date
RETURN DATE
IS
    lv_date DATE;
BEGIN
    lv_date := SYSDATE - transaction_duration;
    RETURN lv_date;
END;


PROCEDURE set_last_refresh_date /* Requires a commit after being called */
(
    pp_last_refresh_date DATE
)
IS
l_err BOOLEAN;
BEGIN
    l_err := fnd_profile.save('PMI$LOTGEN_REFRESH_DATE', TO_CHAR(pp_last_refresh_date, datetime_format), 'SITE');
    /* Commit must follow calls to this procedure */
END;


PROCEDURE add_current_genealogy
(
	pv_doc_id NUMBER
)
IS
/*

In some circumstance, the current_lot_gen cursor will return same product_lot_id
.ingred_lot_id pair in multiple rows.  This occurs where the same item may be fo
und as an ingredient in more than one branch (or conversely, as a product in mor
e than one where-used branch).  It is necessary to bump the association_count fo
r each such dup, since a subsequent removal may be at a point that affects only
one of the duplicate pairs.  Therefore, it is necessary to NOT distinct the foll
owing select.  Each instance of a given pair should be recorded in the associati
on_count.

*/

BEGIN

  FOR gen_rec IN doc_genealogy(pv_doc_id)
  LOOP

    BEGIN
      INSERT INTO pmi_lot_genealogy (
	product_item_id,
	product_lot_id,
	ingred_item_id,
	ingred_lot_id,
	association_count)
      VALUES (
	gen_rec.product_item_id,
	gen_rec.product_lot_id,
	gen_rec.ingred_item_id,
	gen_rec.ingred_lot_id,
	1);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
	  UPDATE pmi_lot_genealogy
	  SET association_count = association_count + 1
	  WHERE product_lot_id = gen_rec.product_lot_id
	    AND ingred_lot_id = gen_rec.ingred_lot_id;
    END;

  END LOOP;

END add_current_genealogy;

PROCEDURE remove_prior_genealogy
(
	pv_doc_id NUMBER
)
IS
/*

The challenge here is to first remove the doc genealogy that reflected the state
 of pmi_lot_bom_v at the time of the last refresh of pmi_lot_genealogy.

The reason this is complicated is that pmi_lot_bom_v only contains net bom
relationships.  If transactions canceled each other out, the lot-to-lot relationship
does not appear.  Example: a typo may caused a lot to be mistakenly allocated,
and the subsequent correction will result in a SUM(trans_qty) = 0.  Following the
 correction, the lots should no longer be considered to be associated with each
other.

A lot relationship may have been present at the last refresh, but at the current
 one, it is not present (because of a correction that occured betwene the last
refresh and the current one).  So removing of the lot relationships must take
place in the context in which the last refresh occured.  This requires a version of
 pmi_lot_bom_v which joins to a table containing the last_refresh_date. The last
_refresh_date should first be fixed,and then used to limit the transactions that
 are selected as "current".  This should eliminates the possibility that the
granularity of sysdate will not be sufficient to be be sure of which transactions
are included in what refresh.

*/

BEGIN

  FOR gen_rec IN doc_genealogy(pv_doc_id)
  LOOP
    DELETE FROM pmi_lot_genealogy
    WHERE product_lot_id = gen_rec.product_lot_id
    AND ingred_lot_id = gen_rec.ingred_lot_id
    AND association_count = 1;

    IF SQL%ROWCOUNT <> 1
    THEN
      UPDATE pmi_lot_genealogy
      SET association_count = association_count - 1
      WHERE product_lot_id = gen_rec.product_lot_id
      AND ingred_lot_id = gen_rec.ingred_lot_id;
    END IF;
  END LOOP;

END remove_prior_genealogy;




PROCEDURE add_lot_self_genealogy(pp_last_refresh_date DATE, pp_current_refresh_date DATE)
IS
    CURSOR new_lots IS
    SELECT item_id, lot_id
    FROM ic_lots_mst
    WHERE lot_id <> 0
    AND creation_date BETWEEN NVL(pp_last_refresh_date, creation_date) AND pp_current_refresh_date;
BEGIN
    FOR nl IN new_lots
    LOOP
        BEGIN
            INSERT INTO pmi_lot_genealogy
            (product_item_id, product_lot_id, ingred_item_id, ingred_lot_id, association_count)
		VALUES (nl.item_id, nl.lot_id, nl.item_id, nl.lot_id, 1);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- no need to insert
        END;
    END LOOP;
END add_lot_self_genealogy;


PROCEDURE refresh_lot_genealogy (errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2)
IS
    /*
      Select the doc_id's of all batches that have had at least one transaction
      update between the last refresh date and the current refresh date.
    */
    CURSOR updated_docs(cp_last_refresh_date DATE, cp_current_refresh_date DATE)
    IS
    SELECT DISTINCT doc_id
    FROM ic_tran_pnd t
    WHERE t.last_update_date BETWEEN NVL(cp_last_refresh_date, t.last_update_date)
                             AND cp_current_refresh_date
    AND t.doc_type = 'PROD'
    AND t.completed_ind = 1
    AND t.lot_id <> 0;
    l_table_owner VARCHAR2(40);
    lv_last_refresh_date DATE;
    lv_current_refresh_date DATE;
BEGIN
    lv_last_refresh_date := get_last_refresh_date;
    lv_current_refresh_date := get_current_refresh_date;

    add_lot_self_genealogy(lv_last_refresh_date, lv_current_refresh_date);

    FOR doc IN updated_docs(lv_last_refresh_date, lv_current_refresh_date)
    LOOP
	remove_prior_genealogy(doc.doc_id);
	add_current_genealogy(doc.doc_id);
    END LOOP;
        SELECT TABLE_OWNER INTO l_table_owner
        FROM USER_SYNONYMS
        WHERE SYNONYM_NAME = 'PMI_LOT_GENEALOGY';
        FND_STATS.GATHER_TABLE_STATS(l_table_owner, 'PMI_LOT_GENEALOGY');

    set_last_refresh_date(lv_current_refresh_date);

    COMMIT;

    EXCEPTION
	WHEN OTHERS THEN
		errbuf := SUBSTR(SQLERRM,1,100);
		retcode := '2';

END refresh_lot_genealogy;


END pmi_lot_genealogy_pkg;

/
