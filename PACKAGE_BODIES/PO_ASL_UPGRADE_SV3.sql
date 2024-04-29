--------------------------------------------------------
--  DDL for Package Body PO_ASL_UPGRADE_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_UPGRADE_SV3" AS
/* $Header: POXA3LUB.pls 115.2 2002/11/27 02:08:51 sbull ship $*/

/*===========================================================================

  PROCEDURE NAME:       get_split_multiplier

===========================================================================*/

PROCEDURE get_split_multiplier(
	x_autosource_rule_id	IN	NUMBER,
	x_split_multiplier	IN OUT NOCOPY  NUMBER,
	x_add_percent		IN OUT NOCOPY  VARCHAR2
) IS
	x_total_allocation	NUMBER;
	x_progress		VARCHAR2(30) := '';
BEGIN

    -- Determine total allocation percentage for this autosource rule.
    -- If total allocation percent is not 0 or 100, we need to scale up
    -- the percentages to sum up to 100.

    BEGIN

    x_progress := '010';
    SELECT  nvl(sum(split), 0)
    INTO    x_total_allocation
    FROM    PO_AUTOSOURCE_VENDORS
    WHERE   autosource_rule_id = x_autosource_rule_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    x_total_allocation := 0;
    END;

    IF x_total_allocation NOT IN (0, 100) THEN
	x_split_multiplier := 100/x_total_allocation;

	-- If still do not add up to 100% after scaling, we
	-- need to add an extra percent to the split for the
	-- top ranked vendor.

	x_progress := '020';
	SELECT  sum(round(split*(100/x_total_allocation)))
	INTO	x_total_allocation
	FROM	po_autosource_vendors
	WHERE   autosource_rule_id = x_autosource_rule_id;

	IF x_total_allocation < 100 THEN
	    x_add_percent := 'Y';
	ELSE
	    x_add_percent := 'N';
	END IF;

    ELSE
	x_split_multiplier := 1;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	fnd_file.put_line(fnd_file.log, '** Exception in get_split_multiplier');
	fnd_file.put_line(fnd_file.log, 'x_progress = '||x_progress);
	PO_MESSAGE_S.SQL_ERROR('GET_SPLIT_MULTIPLIER', x_progress, sqlcode);
END;

END PO_ASL_UPGRADE_SV3;

/
