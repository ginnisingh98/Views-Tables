--------------------------------------------------------
--  DDL for Package Body GMF_MEMO_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_MEMO_INTERFACE" AS
/* $Header: gmfarmob.pls 115.10 2002/11/11 00:29:34 rseshadr ship $ */
  last_trx_id           ra_customer_trx_all.customer_trx_id%TYPE;
  process_errors        BOOLEAN;
  PROCEDURE update_state (p_customer_trx_id IN NUMBER) IS
    max_id	NUMBER;
  BEGIN
    SELECT MAX(ams.customer_trx_id)
    INTO   max_id
    FROM   gl_memo_sta ams
    WHERE  ams.updated_flag = 'Y';
    /* initialize the table if there are no updated values in it. */

    IF max_id IS NULL THEN
      INSERT INTO gl_memo_sta (customer_trx_id, updated_flag)
      VALUES (p_customer_trx_id, 'Y');
      RETURN;
    END IF;
    /* dbms_output.put_line('max='||to_char(max_id)||' p='||to_char(p_customer_trx_id)); */
    IF (p_customer_trx_id > max_id) THEN
      UPDATE gl_memo_sta ams
      SET    ams.customer_trx_id = p_customer_trx_id
      WHERE  ams.updated_flag = 'Y';
    END IF;
  END update_state;
  PROCEDURE get_next_trx_line (
        t_init_flag             IN OUT  NOCOPY NUMBER,
        t_customer_trx_id       OUT     NOCOPY NUMBER,
        t_trx_type              OUT     NOCOPY VARCHAR2,
        error_status            OUT     NOCOPY NUMBER
  ) IS
    t_customer_trx_id1  ra_customer_trx_all.customer_trx_id%type;
    t_trx_type1         ra_cust_trx_types_all.type%type;
    t_interface_date    DATE; /* Bug 2403594 */
  BEGIN
    error_status := 0;
    IF t_init_flag <> 0
    THEN
      process_errors := TRUE;
      t_init_flag := 0;
      last_trx_id := -1;

	/* Bug 2403594. Insert customer_trx_ids of new memos */

	SELECT	nvl(MAX(interface_date),TO_DATE(2440589,'J'))
	INTO	t_interface_date
	FROM	gl_memo_sta;

	INSERT INTO gl_memo_sta
	(customer_trx_id, updated_flag, interface_date)
	(
		SELECT
			distinct rct.customer_trx_id,'N', NULL
		FROM 	ra_customer_trx_all rct,
			ra_cust_trx_types_all rctt
		WHERE
			rct.cust_trx_type_id = rctt.cust_trx_type_id
		AND	rctt.TYPE IN ('CM', 'DM')
		AND	UPPER(rct.complete_flag) = 'Y'
		AND	rct.last_update_date >= trunc(t_interface_date)
		AND	UPPER(rctt.attribute10) = 'YES'
		AND	NOT EXISTS (
				SELECT 1
				FROM gl_memo_sta s
				WHERE s.customer_trx_id = rct.customer_trx_id)
	);

	COMMIT;

    END IF;

    BEGIN
        /* get lines with status 'N'.
		Modified sql script to order rows in sub-query
		and to select first row from the returned set  */

	SELECT	customer_trx_id, type
        INTO	t_customer_trx_id1, t_trx_type1
        FROM   (
		SELECT rct.customer_trx_id,
			rctt.type
		FROM	ra_customer_trx_all rct,
			ra_cust_trx_types_all rctt,
			gl_memo_sta ams
		WHERE  rct.customer_trx_id = ams.customer_trx_id
		AND    rct.customer_trx_id > last_trx_id
		AND    rct.cust_trx_type_id = rctt.cust_trx_type_id
		AND    rctt.type IN ('CM', 'DM')
		/* B1043050 changed upper to lower and 'N' to 'n' */
		AND    LOWER(ams.updated_flag) = 'n'
		ORDER  BY 1
		)
	WHERE    ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
		process_errors := FALSE;
		t_init_flag := last_trx_id;
		error_status := 100;
		RETURN;
      END;

	last_trx_id := t_customer_trx_id1;

	/* Bug 2403594. Mark transactions */

	UPDATE	gl_memo_sta ams
	SET	updated_flag = 'Y',
		interface_date = sysdate
	WHERE	customer_trx_id	= t_customer_trx_id1;

        /* set the values of the OUT variables.*/
	t_customer_trx_id       :=  t_customer_trx_id1;
	t_trx_type              :=  t_trx_type1;
  EXCEPTION
    WHEN OTHERS
    THEN
      error_status :=  SQLCODE;
  END get_next_trx_line;
  PROCEDURE insert_error (
        t_customer_trx_id       IN      NUMBER,
        error_status            OUT     NOCOPY NUMBER
    ) IS
  BEGIN
	/* Bug 2403594 */
	UPDATE	gl_memo_sta ams
	SET	updated_flag = 'N', interface_date = NULL
	WHERE	customer_trx_id	= t_customer_trx_id;
  EXCEPTION
    WHEN OTHERS THEN
      error_status := SQLCODE;
  END insert_error;
  PROCEDURE validate_flexfields (
	t_customer_trx_id	IN	NUMBER,
	t_rctl_attribute7 	IN 	VARCHAR2,
	t_rctl_attribute8	IN	VARCHAR2,
	t_rctl_attribute9	IN	VARCHAR2,
	t_rctl_attribute10	IN	VARCHAR2,
	t_inventory_item_id 	IN 	NUMBER,
	t_rctl_attribute1	IN	VARCHAR2,
	t_rctl_attribute5	IN	VARCHAR2,
	t_rctl_attribute15	IN	VARCHAR2
    ) IS
    CURSOR tran_type_cur(t_customer_trx_id  IN NUMBER) IS
    SELECT NVL(rctt.attribute10, ' ')
    FROM   ra_cust_trx_types_all	rctt,
	   ra_customer_trx_all	rct
    WHERE  rct.customer_trx_id	= t_customer_trx_id
    AND    rct.cust_trx_type_id	= rctt.cust_trx_type_id;
    t_rctt_attribute10	ra_cust_trx_types_all.attribute10%type;

    CURSOR get_item_no(t_item_id in NUMBER) IS
    SELECT msi.segment1
    FROM   mtl_system_items msi
    WHERE  msi.inventory_item_id=t_inventory_item_id;

    t_item_no           mtl_system_items.segment1%TYPE;

    CURSOR get_item_ind(i_item_no VARCHAR2) IS
    SELECT dualum_ind, lot_ctl
    FROM	ic_item_mst
    WHERE 	item_no = i_item_no;

    t_dualum_ind 	ic_item_mst.dualum_ind%TYPE;
    t_lot_ctl 	ic_item_mst.lot_ctl%TYPE;

    affect_inv		EXCEPTION;
    exp_wrong_item	EXCEPTION;
    no_lot_data		EXCEPTION;
    no_qty_data		EXCEPTION;
    PRAGMA EXCEPTION_INIT(affect_inv,-20101);
  BEGIN
    IF NOT tran_type_cur%ISOPEN
    THEN
      OPEN tran_type_cur(t_customer_trx_id);
    END IF;
    FETCH  tran_type_cur
    INTO   t_rctt_attribute10;
    CLOSE tran_type_cur;

    /* B1043050 changed upper to lower and 'YES' to 'yes' */
    IF LOWER(t_rctt_attribute10) = 'yes'
    THEN
		/* Check for all required values in the descriptive flexfield */
		IF (    t_rctl_attribute7  IS NULL OR
	 		t_rctl_attribute8  IS NULL OR
	 		t_rctl_attribute9  IS NULL OR
	 		t_rctl_attribute10 IS NULL)
    		THEN
			RAISE affect_inv;
    		END IF;

		/* Validate the item in descriptive flexfield */
     		IF NOT get_item_no%ISOPEN
     		THEN
			OPEN get_item_no(t_inventory_item_id);
     		END IF;
     		FETCH get_item_no
     		INTO  t_item_no;

     		CLOSE get_item_no;

     		IF (t_item_no<>t_rctl_attribute7)
     		THEN
       		RAISE exp_wrong_item;
	        END IF;

		/* Bug 1399377
		REM Get dual uom indicator and lot control indicator */
		IF NOT get_item_ind%ISOPEN
		THEN
			OPEN get_item_ind(t_item_no);
		END IF;
		FETCH get_item_ind
		INTO t_dualum_ind, t_lot_ctl;

		CLOSE get_item_ind;

		/* Verify Lot/Sublot data if item is lot controlled. */
		IF (t_lot_ctl = 1 AND t_rctl_attribute1 is NULL) THEN
			RAISE no_lot_data;
		END IF;

		/* Verify secondary uom qty data if item is dual type 3. */
		IF (t_dualum_ind = 3 AND t_rctl_attribute15 is NULL) THEN
			RAISE no_qty_data;
		END IF;

    END IF;
  EXCEPTION
	WHEN exp_wrong_item THEN
	fnd_message.set_name('GMF','GL_WRONG_ITEM');
	app_exception.raise_exception;
	WHEN affect_inv THEN
	fnd_message.set_name('GMF','GL_INVENTORY_AFFECT');
	app_exception.raise_exception;
	WHEN no_lot_data THEN
	fnd_message.set_name('GMF','GL_NO_LOT_DATA');
	app_exception.raise_exception;
	WHEN no_qty_data THEN
	fnd_message.set_name('GMF','GL_NO_QTY_DATA');
	app_exception.raise_exception;
	WHEN OTHERS THEN
      /* REM RAISE_APPLICATION_ERROR(-20101, 'Transaction affects inventory'); */
         fnd_message.set_name('GMF','GL_TRIGGER_EXCEPTION');
	/* REM B1033070 Changed substrb to substr, Get first 512 chars and not bytes.
         REM fnd_message.set_token('TRIGGER_NAME',substrb('GMF_MEMO_INTERFACE'||SQLERRM,1,512)); */
         fnd_message.set_token('TRIGGER_NAME',substr('GMF_MEMO_INTERFACE'||SQLERRM,1,512));
         app_exception.raise_exception;
  END validate_flexfields;
END GMF_MEMO_INTERFACE;

/
