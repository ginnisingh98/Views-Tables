--------------------------------------------------------
--  DDL for Package Body PO_OPTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_OPTIONS_SV" AS
/* $Header: POXSTDPB.pls 115.3 2002/11/25 22:38:26 sbull ship $*/
PROCEDURE get_startup_values (
			po_install_status  	IN OUT NOCOPY  VARCHAR2,
			oe_install_status	IN OUT NOCOPY  VARCHAR2,
			inv_install_status	IN OUT	NOCOPY VARCHAR2,
			coa			IN OUT NOCOPY  NUMBER,
			inventory_org_id	IN OUT NOCOPY  NUMBER,
			currency_code		IN OUT NOCOPY  VARCHAR2,
			per_pos_grant_exists	IN OUT NOCOPY  VARCHAR2,
			doc_types_grant_exists	IN OUT NOCOPY  VARCHAR2,
			order_types_grant_exists 	IN OUT NOCOPY VARCHAR2,
			order_sources_grant_exists	IN OUT NOCOPY VARCHAR2,
			line_types_grant_exists		IN OUT NOCOPY VARCHAR2,
			psp_has_data			IN OUT NOCOPY BOOLEAN)
IS
	po_id		NUMBER := 0;
	oe_id		NUMBER := 0;
	inv_id		NUMBER := 0;
	data_exists	NUMBER := 0;
	dummy_str	VARCHAR2(50);
        industry	VARCHAR2(255) := NULL;
        get_rv		BOOLEAN;
        x_progress      VARCHAR2(3)  :=  NULL;
	no_install_status	EXCEPTION;
BEGIN

    -- determine the application_id for PO, OE, and INV.  This
    -- information is used to determine the installation status of
    -- these applications.

    x_progress := '010';
    SELECT     application_id
    INTO       po_id
    FROM       FND_APPLICATION
    WHERE      application_short_name = 'PO';

    x_progress := '020';
    SELECT     application_id
    INTO       oe_id
    FROM       FND_APPLICATION
    WHERE      application_short_name = 'OE';

    x_progress := '030';
    SELECT     application_id
    INTO       inv_id
    FROM       FND_APPLICATION
    WHERE      application_short_name = 'INV';

    --  determine the installation status of PO, INV, and OE.

    x_progress := '040';
    get_rv := FND_INSTALLATION.get(po_id, po_id, po_install_status, industry);
    IF get_rv = FALSE THEN
	raise no_install_status;
    END IF;

    x_progress := '050';
    if oe_install.get_active_product() in ('OE', 'ONT') then
		oe_install_status := 'I';
    else
		oe_install_status := 'N';
    end if;

  /*
    get_rv := FND_INSTALLATION.get(oe_id, oe_id, oe_install_status, industry);
    IF get_rv = FALSE THEN
	raise no_install_status;
    END IF;
 */

    x_progress := '060';
    get_rv := FND_INSTALLATION.get(inv_id, inv_id, inv_install_status,
	industry);
    IF get_rv = FALSE THEN
	raise no_install_status;
    END IF;

    -- determine chart of accounts id, inventory organization
    -- id, and currency code.

    x_progress := '080';
    SELECT 	sob.chart_of_accounts_id,
		fsp.inventory_organization_id,
		sob.currency_code
    INTO	coa,
		inventory_org_id,
		currency_code
    FROM	gl_sets_of_books sob,
		financials_system_parameters fsp
    WHERE 	sob.set_of_books_id = fsp.set_of_books_id;

    -- Determine whether current user has permissions to access the
    -- line_type, security_position_name, order_source_id_dsp,
    -- order_type_id_dsp fields.

    x_progress := '100';
--
-- BUG fix for Bug# 474893
-- to display missing Order type on screen
-- The following lines of code are replaced by a function security mechanism
-- in form POXSTDPO.fmb,in  Built in Package PO_OPTIONS3
-- We do not need to select from tables.A parameter DISPLAY_CHECK is either
-- set to 'Y' or 'N' when POXSTDPO.fmb form is invoked from the menu,
-- depending on the responsibility of person who has signed on. These lines
-- have therefore been commented out.

--#474893
/*
    BEGIN

    SELECT 	table_name
    INTO  	dummy_str
    FROM	all_tables alt
    WHERE	alt.table_name = 'PER_POSITION_STRUCTURES';

    per_pos_grant_exists := 'Y';

    EXCEPTION
    WHEN no_data_found THEN
	per_pos_grant_exists := 'N';
    WHEN others THEN
	raise;
    END;

    x_progress := '110';
    BEGIN

    SELECT 	table_name
    INTO 	dummy_str
    FROM	all_tables alt
    WHERE	alt.table_name = 'PO_DOCUMENT_TYPES';

    doc_types_grant_exists := 'Y';

    EXCEPTION
    WHEN no_data_found THEN
	doc_types_grant_exists := 'N';
    WHEN others THEN
	raise;
    END;
*/

    x_progress := '120';

--#474893
/*
    BEGIN

    SELECT 	table_name
    INTO 	dummy_str
    FROM	all_tables alt
    WHERE	alt.table_name = 'SO_ORDER_TYPES_ALL';

    order_types_grant_exists := 'Y';

    EXCEPTION
    WHEN no_data_found THEN
	order_types_grant_exists := 'N';
    WHEN others THEN
	raise;
    END;

    x_progress := '130';
    BEGIN

    SELECT 	table_name
    INTO 	dummy_str
    FROM	all_tables alt
    WHERE	alt.table_name = 'SO_ORDER_SOURCES';

    order_sources_grant_exists := 'Y';

    EXCEPTION
    WHEN no_data_found THEN
        order_sources_grant_exists := 'N';
    WHEN others THEN
	raise;
    END;

    x_progress := '140';
    BEGIN

    SELECT 	table_name
    INTO 	dummy_str
    FROM	all_tables alt
    WHERE	alt.table_name = 'PO_LINE_TYPES';

    line_types_grant_exists := 'Y';

    EXCEPTION
    WHEN no_data_found THEN
        line_types_grant_exists := 'N';
    WHEN others THEN
	raise;
    END;
*/

    x_progress := '160';

    SELECT 	count(*)
    INTO 	data_exists
    FROM 	po_system_parameters;

    IF (data_exists > 0) THEN
	psp_has_data := TRUE;
    ELSE
	psp_has_data := FALSE;
    END IF;

EXCEPTION
    WHEN no_install_status THEN
	RAISE;
    WHEN OTHERS THEN
	RAISE;
END;

END;

/
