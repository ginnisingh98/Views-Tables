--------------------------------------------------------
--  DDL for Package Body GMF_OPM_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_OPM_ITEM" AS
/* $Header: gmfopmib.pls 120.1 2005/10/06 11:15:10 jsrivast noship $ */
	FUNCTION CHECK_OPM_ITEM    (p_item_no	in 	mtl_system_items.segment1%TYPE)
		RETURN NUMBER IS

		v_result	NUMBER;
	BEGIN
		v_result := 0;
		SELECT count(*) into v_result
		FROM ic_item_mst
		WHERE item_no = p_item_no;

		IF v_result > 0 THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END CHECK_OPM_ITEM;
END GMF_OPM_ITEM;

/
