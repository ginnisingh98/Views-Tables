--------------------------------------------------------
--  DDL for Package Body WSMPVCPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPVCPD" AS
/* $Header: WSMVCPDB.pls 115.8 2003/12/17 19:00:14 sthangad ship $ */

/*===========================================================================

  PROCEDURE NAME:   val_co_product_related

===========================================================================*/

PROCEDURE val_co_product_related (x_bill_sequence_id    IN     NUMBER,
                                  x_result              IN OUT NOCOPY VARCHAR2,
                                  x_error_code          IN OUT NOCOPY NUMBER,
                                  x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';

-- commented out by abedajna on 10/12/00 for perf. tuning

/*
**  SELECT 'Y'
**  INTO   x_result
**  FROM   sys.dual
**  WHERE EXISTS (SELECT 1
**                FROM   wsm_co_products bcp
**                WHERE  bcp.bill_sequence_id = x_bill_sequence_id
**                AND    sysdate >= bcp.effectivity_date
**                AND    (sysdate <= bcp.disable_date
**                        OR bcp.disable_date is NULL));
**  x_error_code := 0;
**
**
** EXCEPTION
**
** WHEN NO_DATA_FOUND THEN
**    x_result := 'N';
**    x_error_code := 0;
**
** WHEN OTHERS THEN
**    x_error_code := sqlcode;
**    x_error_msg  := 'WSMPVCPD.val_co_product_related(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
*/
-- modification begin for perf. tuning.. abedajna 10/12/00

  SELECT 'Y'
  INTO   x_result
       FROM   wsm_co_products bcp
       WHERE  bcp.bill_sequence_id = x_bill_sequence_id
       AND    sysdate >= bcp.effectivity_date
       AND    (sysdate <= bcp.disable_date
       		OR bcp.disable_date is NULL);

  x_error_code := 0;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
    x_result := 'N';
    x_error_code := 0;

 WHEN TOO_MANY_ROWS THEN
 	x_result := 'Y';
        x_error_code := 0;

 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_co_product_related(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);

-- modification end for perf. tuning.. abedajna 10/12/00


END val_co_product_related;


/* ==========================================================================

  PROCEDURE NAME:   val_co_product

=========================================================================== */

PROCEDURE val_co_product(x_rowid               IN     VARCHAR2,
                         x_co_product_group_id IN     NUMBER,
                         x_co_product_id       IN     NUMBER,
                         x_error_code          IN OUT NOCOPY NUMBER,
                         x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress          VARCHAR2(3) := NULL;
e_val_co_product    EXCEPTION;
e_bom_inequality    EXCEPTION;
x_dummy             NUMBER      := NULL;
x1_dummy             NUMBER;  --abedajna

BEGIN

  x_progress := '010';

/*   Verify that the required arguments are being passed in. */

  IF ((x_co_product_group_id is NULL) OR (x_co_product_id is NULL))  THEN
    raise e_val_co_product;

  END IF;

  x_progress := '020';


  SELECT 1
  INTO   x_dummy
  FROM   sys.dual
  WHERE  NOT EXISTS (SELECT  1
                     FROM    wsm_co_products bcp
                     WHERE   bcp.co_product_group_id = x_co_product_group_id
                     AND     bcp.co_product_id       = x_co_product_id
                     AND     ((rowid <> X_Rowid) OR (X_Rowid IS NULL)));


  x_progress := '030';

  x_dummy := NULL;

  BEGIN

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**    SELECT 1
**    INTO x_dummy
**    FROM sys.dual
**    WHERE NOT EXISTS (SELECT 1
**                      FROM   wsm_co_prod_comp_substitutes bcs
**                      WHERE  bcs.co_product_group_id = x_co_product_group_id
**                      AND    bcs.substitute_component_id = x_co_product_id);
**
**  EXCEPTION
**    WHEN NO_DATA_FOUND THEN
**      raise e_bom_inequality;
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

    x1_dummy := 0;

    SELECT 1
    INTO x1_dummy
      FROM   wsm_co_prod_comp_substitutes bcs
      WHERE  bcs.co_product_group_id = x_co_product_group_id
      AND    bcs.substitute_component_id = x_co_product_id;

    IF x1_dummy <> 0 THEN
    	raise e_bom_inequality;
    END IF;


  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      raise e_bom_inequality;

    WHEN NO_DATA_FOUND THEN
       NULL;


-- modification end for perf. tuning.. abedajna 10/12/00

  END;

  x_error_code := 0;

EXCEPTION
 WHEN e_bom_inequality THEN
    x_error_code := 3;
    x_error_msg  := 'Co Product Item may not be same as component''s substitute item.';
 WHEN e_val_co_product THEN
    x_error_code := 1;
    x_error_msg  := 'Insufficient arguments to WSMPVCPD.val_co_product';
 WHEN NO_DATA_FOUND THEN
    /* DEBUG: Replace with message from message dictionary. */
    x_error_msg  := 'This is a duplicate co-product';
    x_error_code := 2;
  WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_co_product(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);


END val_co_product;

/* ==========================================================================

  PROCEDURE NAME:   val_substitute_coproduct

=========================================================================== */

PROCEDURE val_substitute_coproduct(x_substitute_co_product_id   IN     NUMBER,
                                   x_co_product_group_id        IN     NUMBER,
                                   x_co_product_id              IN     NUMBER,
                                   x_error_code                 IN OUT NOCOPY NUMBER,
                                   x_error_msg                  IN OUT NOCOPY VARCHAR2)
IS

x_progress          VARCHAR2(3) := NULL;
e_invalid_substitute EXCEPTION;
e_same_substitute    EXCEPTION;

x_dummy             NUMBER      := NULL;

BEGIN

  x_progress := '010';

  IF (x_co_product_id = x_substitute_co_product_id) THEN
    raise e_same_substitute;

  END IF;

  BEGIN

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**    SELECT 1
**    INTO x_dummy
**    FROM sys.dual
**    WHERE EXISTS (SELECT 1
**                  FROM   wsm_co_products bcp
**                  WHERE  bcp.co_product_group_id = x_co_product_group_id
**                  AND    bcp.co_product_id       = x_substitute_co_product_id);
**
**  EXCEPTION
**    WHEN NO_DATA_FOUND THEN
**      raise e_invalid_substitute;
*/
-- modification begin for perf. tuning.. abedajna 10/12/00

    SELECT 1
    INTO x_dummy
    FROM   wsm_co_products bcp
    WHERE  bcp.co_product_group_id = x_co_product_group_id
    AND    bcp.co_product_id       = x_substitute_co_product_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise e_invalid_substitute;

    WHEN TOO_MANY_ROWS THEN
	x_dummy := 1;


-- modification end for perf. tuning.. abedajna 10/12/00


  END;

  x_error_code := 0;

EXCEPTION
 WHEN e_same_substitute THEN
    x_error_code := 2;
    x_error_msg  := 'Co-Product Substitute Item cannot be the same as the Co-Product Item.';
 WHEN e_invalid_substitute THEN
    x_error_code := 1;
    x_error_msg  := 'Co-Product Substitute Item does not exist in the Co-Product relationship.';
 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_substitute_coproduct(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END val_substitute_coproduct;


/*===========================================================================

  PROCEDURE NAME:   val_pre_commit

===========================================================================*/

PROCEDURE val_pre_commit(x_co_product_group_id     IN     NUMBER,
                         x_error_code              IN OUT NOCOPY NUMBER,
                         x_error_msg               IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
e_proc_exception         EXCEPTION;

BEGIN

  x_progress := '010';

/*
   Do not continue if the co_product_group_id
   has not been provided.
*/

  IF (x_co_product_group_id is NULL) THEN
    x_error_code := 0;
    return;

  END IF;

  WSMPVCPD.val_primary_flag(x_co_product_group_id,
                                       x_error_code,
                                       x_error_msg);

  IF (x_error_code = 2) THEN
    return;

  ELSIF (x_error_code <> 0) THEN
    raise e_proc_exception;

  END IF;


  WSMPVCPD.val_split_total (x_co_product_group_id,
                                      x_error_code,
                                      x_error_msg);

  IF (x_error_code = 2) THEN
    return;

  ELSIF (x_error_code <> 0) THEN
    raise e_proc_exception;

  END IF;

  x_error_code := 0;

EXCEPTION
 WHEN e_proc_exception  THEN
    x_error_msg := x_error_msg || ' - ' || 'WSMPVCPD.val_pre_commit('||x_progress||')';

 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_pre_commit(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END val_pre_commit;


/*===========================================================================

  PROCEDURE NAME:   val_primary_flag

===========================================================================*/

PROCEDURE val_primary_flag(x_co_product_group_id IN     NUMBER,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress          VARCHAR2(3) := NULL;
e_val_primary_flag  EXCEPTION;
x_dummy             NUMBER      := NULL;

BEGIN

  x_progress := '010';

/* Verify that the required arguments are being passed in. */
  IF (x_co_product_group_id is NULL) THEN
    raise e_val_primary_flag;

  END IF;

  x_progress := '020';

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**  SELECT 1
**  INTO   x_dummy
**  FROM   sys.dual
**  WHERE  EXISTS (SELECT  1
**                 FROM    wsm_co_products bcp
**                 WHERE   bcp.co_product_group_id = x_co_product_group_id
**                 AND     bcp.primary_flag = 'Y'
**                 AND     bcp.co_product_id is not NULL);
**
**  x_error_code := 0;
**
**EXCEPTION
** WHEN e_val_primary_flag THEN
**    x_error_code := 1;
**    x_error_msg  := 'Insufficient arguments to WSMPVCPD.val_primary_flag';
** WHEN NO_DATA_FOUND THEN */
    /* DEBUG: Replace with message from message dictionary. */
/*    x_error_msg  := 'You must choose one of the co-products to be a primary co-product';
**    x_error_code := 2;
** WHEN OTHERS THEN
**    x_error_code := sqlcode;
**    x_error_msg  := 'WSMPVCPD.val_primary_flag(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

  SELECT 1
  INTO   x_dummy
       FROM    wsm_co_products bcp
       WHERE   bcp.co_product_group_id = x_co_product_group_id
       AND     bcp.primary_flag = 'Y'
       AND     bcp.co_product_id is not NULL;

  x_error_code := 0;

EXCEPTION

 WHEN TOO_MANY_ROWS THEN
    x_dummy := 1;
    x_error_code := 0;

 WHEN e_val_primary_flag THEN
    x_error_code := 1;
    x_error_msg  := 'Insufficient arguments to WSMPVCPD.val_primary_flag';

 WHEN NO_DATA_FOUND THEN
    /* DEBUG: Replace with message from message dictionary. */
    x_error_msg  := 'You must choose one of the co-products to be a primary co-product';
    x_error_code := 2;
 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_primary_flag(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);


-- modification end for perf. tuning.. abedajna 10/12/00


END val_primary_flag;

/* ===========================================================================

  PROCEDURE NAME:   val_split_total

=========================================================================== */

PROCEDURE val_split_total(x_co_product_group_id IN     NUMBER,
                          x_error_code          IN OUT NOCOPY NUMBER,
                          x_error_msg           IN OUT NOCOPY VARCHAR2)
IS

x_progress            VARCHAR2(3) := NULL;
e_val_split_total     EXCEPTION;
e_invalid_split_total EXCEPTION;
x_split_total         NUMBER      := NULL;

CURSOR c_total is select distinct effectivity_date
		  from WSM_COPRODUCT_SPLIT_PERC
		  where co_product_group_id=x_co_product_group_id;

BEGIN

  x_progress := '010';

/*  Verify that the required arguments are being passed in. */

  IF (x_co_product_group_id is NULL) THEN
    raise e_val_split_total;
  END IF;

  x_progress := '020';

  /* ST : coproducts time phased split enhancement begin */
  /*SELECT sum (nvl(bcp.split,0))
  INTO   x_split_total
  FROM   wsm_co_products bcp
  WHERE  bcp.co_product_group_id = x_co_product_group_id
  AND    bcp.co_product_id is not NULL; */

  /* Look into split percentages table to validate */
  FOR e_rec IN c_total LOOP

    SELECT sum (nvl(bcp.split,0))
    INTO   x_split_total
    FROM   wsm_coproduct_split_perc bcp
    WHERE  bcp.co_product_group_id = x_co_product_group_id
    AND    effectivity_date = e_rec.effectivity_date;

    IF (x_split_total <> 100) THEN
       raise e_invalid_split_total;
    END IF;

  END LOOP;

  /* ST : coproducts time phased split enhancement end */

  x_error_code := 0;

EXCEPTION
 WHEN e_val_split_total THEN
    x_error_code := 1;
    x_error_msg  := 'Insufficient arguments to WSMPVCPD.val_primary_flag';
 WHEN e_invalid_split_total THEN
    x_error_code := 2;
    x_error_msg  := 'The split percentage of the co-product lines should add up to 100.';
 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_primary_flag(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END val_split_total;

/* ===========================================================================

  PROCEDURE NAME:       val_add_to_bill

=========================================================================== */

PROCEDURE val_add_to_bill ( x_co_product_group_id        IN     NUMBER,
                            x_org_id                     IN     NUMBER,
                            x_co_product_id              IN     NUMBER,
                            x_comm_bill_sequence_id      IN     NUMBER,
                            x_curr_bill_sequence_id      IN     NUMBER,
                            x_effectivity_date           IN     DATE,
                            x_disable_date               IN     DATE,
                            x_alternate_designator       IN     VARCHAR2,
                            x_error_code                 IN OUT NOCOPY NUMBER,
                            x_error_msg                  IN OUT NOCOPY VARCHAR2) IS

CURSOR C (x_bill_seq_id NUMBER) IS
         SELECT  1
         FROM    sys.dual
         WHERE   EXISTS (SELECT 1
                         FROM   bom_inventory_components bic
                         WHERE  bic.bill_sequence_id = x_bill_seq_id
                         AND    ((x_disable_date is NULL)
                                   OR (x_disable_date > bic.effectivity_date))
                         AND    ((x_effectivity_date < bic.disable_date)
                                   OR (bic.disable_date IS NULL))
			);

x_active_link   NUMBER  := NULL;
x_dummy         NUMBER  := NULL;
x_progress      VARCHAR2(3) := NULL;

e_val_exception     EXCEPTION;
e_proc_exception    EXCEPTION;

BEGIN


  IF (x_comm_bill_sequence_id <> x_curr_bill_sequence_id) THEN   /* Common bill */
    x_progress := '020';

    SELECT count(1)
    INTO   x_active_link
    FROM   wsm_co_products bcp
    WHERE  bcp.bill_sequence_id = x_comm_bill_sequence_id
    AND    (    bcp.disable_date is NULL
             OR bcp.disable_date > sysdate)
    AND    bcp.co_product_group_id <> x_co_product_group_id;

    IF (x_active_link is NOT NULL) THEN
       raise e_val_exception;

    ELSE  /* OK to update the common link */

/*      -- Lock corresponding bill prior to update. */

      WSMPPCPD.lock_bill (x_curr_bill_sequence_id,
                                    x_error_code,
                                    x_error_msg);

      IF (x_error_code > 0) THEN
        return;

      ELSIF (x_error_code < 0) THEN
        raise e_proc_exception;

      END IF;

      UPDATE bom_bill_of_materials
      SET   common_assembly_item_id = NULL,
      common_organization_id  = NULL,
      common_bill_sequence_id = NULL
      WHERE bill_sequence_id = x_curr_bill_sequence_id;

    END IF;

  ELSE  /* Not a common bill */
     x_progress := '040';

/*   -- Verify that there aren't any overlapping
     -- components. */

     OPEN C (x_curr_bill_sequence_id);
     FETCH C INTO x_dummy;
     IF (C%NOTFOUND) THEN
       NULL;

     ELSE
       raise e_val_exception;

     END IF;
     CLOSE C;

  END IF;

  x_error_code := 0;

EXCEPTION
  WHEN e_proc_exception  THEN
    x_error_msg := x_error_msg || ' - ' || 'WSMPVCPD.val_add_to_bill('||x_progress||')';

 WHEN e_val_exception THEN
    x_error_code := 3;
    IF (x_alternate_designator is NOT NULL) THEN
      x_error_msg  :=  'Please provide another alternate designator. Cannot add co-product to this alternate bill.';
    ELSE
      x_error_msg  := x_progress || 'This co-product may not be used as a primary co-product. Please use another co-product as the primary co-product.';
    END IF;

 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_add_to_bill(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);
END val_add_to_bill;

/* ===========================================================================

  PROCEDURE NAME:   val_component_overlap

=========================================================================== */

PROCEDURE val_component_overlap  (x_org_id        IN     NUMBER,
                                  x_component_id  IN     NUMBER,
                                  x_effectivity_date IN  DATE,
                                  x_disable_date     IN  DATE,
                                  x_rowid            IN  VARCHAR2,
                                  x_error_code    IN OUT NOCOPY NUMBER,
                                  x_error_msg     IN OUT NOCOPY VARCHAR2)
IS

x_progress               VARCHAR2(3) := NULL;
x_dummy                  NUMBER      := NULL;
ex_dupl_comp		 EXCEPTION;  -- abedajna

BEGIN

  x_progress := '010';

  x_dummy := 0;

  SELECT 1
  INTO   x_dummy
  FROM   wsm_co_products bcp
  WHERE  bcp.organization_id = x_org_id
  AND    bcp.component_id    = x_component_id
  AND    (x_disable_date is NULL
         OR (x_disable_date > bcp.effectivity_date))
  AND    ((x_effectivity_date < bcp.disable_date)
         OR bcp.disable_date is NULL)
  AND    ((bcp.rowid <> X_rowid) OR (X_rowid is NULL))
  AND    bcp.co_product_id is NULL;

  IF x_dummy <> 0 THEN
  	RAISE ex_dupl_comp;
  END IF;

  x_error_code := 0;

EXCEPTION

 WHEN NO_DATA_FOUND THEN
 	NULL;

 WHEN ex_dupl_comp THEN
    /* DEBUG: Replace with message from message dictionary. */
    x_error_msg  := 'This is a duplicate component. It failed the effectivity check';
    x_error_code := 1;

 WHEN TOO_MANY_ROWS THEN
    /* DEBUG: Replace with message from message dictionary. */
    x_error_msg  := 'This is a duplicate component. It failed the effectivity check';
    x_error_code := 1;

 WHEN OTHERS THEN
    x_error_code := sqlcode;
    x_error_msg  := 'WSMPVCPD.val_component_overlap(' || x_progress || ')' || ' - ' || substr(sqlerrm, 1, 200);


-- modification end for perf. tuning.. abedajna 10/12/00



END val_component_overlap;

END WSMPVCPD;

/
