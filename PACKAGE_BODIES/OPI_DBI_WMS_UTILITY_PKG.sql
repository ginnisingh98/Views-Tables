--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_UTILITY_PKG" AS
/*$Header: OPIDEWUTILB.pls 120.0 2005/05/24 17:13:00 appldev noship $ */

/**************************************************
 * Common Procedures
 *
 * File scope functions (not in spec)
 **************************************************/

-- Print out error message in a consistent manner
FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2;

-- Report item level conversion rate error details
PROCEDURE report_item_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER);

-- Report Locator level conversion rate error details
PROCEDURE report_locator_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER);


/**************************************************
 * Common Procedures
 *
 * File scope functions (not in spec)
 **************************************************/
/*  err_mesg

    Return a C_ERRBUF_SIZE character long, properly formatted error
    message with the package name, procedure name and message.

    Parameters:
    p_mesg - Actual message to be printed
    p_proc_name - name of procedure that should be printed in the message
     (optional)
    p_stmt_id - step in procedure at which error occurred
     (optional)

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Defined function.
*/

FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2
IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'err_mesg';
    l_stmt_id NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300);

BEGIN

    -- initialization block
    l_stmt_id := 0;

    -- initialization block
    l_formatted_message := NULL;

    l_stmt_id := 10;
    l_formatted_message := substr ((C_PKG_NAME || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || p_mesg),
                                   1, C_ERRBUF_SIZE);

    commit;

    return l_formatted_message;

EXCEPTION

    WHEN OTHERS THEN
        -- the exception happened in the exception reporting function !!
        -- return with ERROR.
        l_formatted_message := substr ((C_PKG_NAME || '.' || l_proc_name ||
                                       ' #' ||
                                        to_char (l_stmt_id) || ': ' ||
                                       SQLERRM),
                                       1, C_ERRBUF_SIZE);

        l_formatted_message := 'Error in error reporting.';
        return l_formatted_message;

END err_mesg;


/**************************************************
 * Public Procedures
 **************************************************/

/*  report_item_setup_missing

    Reports the items in WMS organizations which are missing
    weight and/or volume setup.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/20/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_item_setup_missing (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'report_item_setup_missing';
    l_stmt_id NUMBER;
    l_local_retcode NUMBER;

    -- Header message
    l_item_missing_header VARCHAR2 (10000);

    -- Fix Message
    l_item_missing_fix VARCHAR2 (10000);

    -- Number of rows missing
    l_num_rows_missing NUMBER := 0;

    -- 4 columns: Org, Item, Volume Missing, Weight Missing.
    -- Each has a header and some width.
    l_org_col_width NUMBER;
    l_item_col_width NUMBER;
    l_vol_col_width NUMBER;
    l_wt_col_width NUMBER;
    l_org_col_header VARCHAR2 (80);
    l_item_col_header VARCHAR2 (80);
    l_vol_col_header VARCHAR2 (80);
    l_wt_col_header VARCHAR2 (80);

    -- Markers to mark missing setups.
    l_wt_missing_marker VARCHAR2 (80);
    l_wt_ok_marker VARCHAR2 (80);
    l_vol_missing_marker VARCHAR2 (80);
    l_vol_ok_marker VARCHAR2 (80);

    -- Line by line print
    l_line_print VARCHAR2 (1000);

    -- Message for too many missing rows
    l_too_many_rows_msg VARCHAR2 (1000);

    -- General record for missing setups
    TYPE opi_dbi_item_setup_missing_rec is RECORD (
                org VARCHAR2(300),
                item VARCHAR2(240),
                wt_missing_flag NUMBER,
                vol_missing_flag NUMBER);
    l_items_setup_missing_rec opi_dbi_item_setup_missing_rec;


    -- Cursor to count how many rows are missing
    CURSOR item_setup_missing_count_csr IS
    SELECT
        count (*)
      FROM  mtl_parameters mp,
            eni_oltp_item_star items
      WHERE mp.organization_id = items.organization_id
        AND mp.wms_enabled_flag = 'Y'
        AND mp.process_enabled_flag <> 'Y'
        AND (   items.weight_uom_code IS NULL
             OR items.volume_uom_code IS NULL
             OR items.unit_weight IS NULL
             OR items.unit_volume IS NULL);


    -- Cursor to list all the items with missing unit weight and/or
    -- volume.
    TYPE item_setup_missing_cursor IS REF CURSOR;
    item_setup_missing_csr item_setup_missing_cursor;

    l_item_setup_missing_sql CONSTANT VARCHAR2 (4000) :=
    'SELECT
        (orgs.name || '' ('' || mp.organization_code || '')'') org,
        items.value item,
        CASE
            WHEN items.weight_uom_code IS NULL OR
                 items.unit_weight IS NULL THEN
                1 /*C_WT_MISSING*/
            ELSE
                0 /*C_NOTHING_MISSING*/
            END wt_missing_flag,
        CASE
            WHEN items.volume_uom_code IS NULL OR
                 items.unit_volume IS NULL THEN
                2 /*C_VOL_MISSING*/
            ELSE
                3 /*C_NOTHING_MISSING*/
            END vol_missing_flag
      FROM  mtl_parameters mp,
            eni_oltp_item_star items,
            hr_all_organization_units_vl orgs
      WHERE mp.organization_id = orgs.organization_id
        AND mp.organization_id = items.organization_id
        AND mp.wms_enabled_flag = ''Y''
        AND mp.process_enabled_flag <> ''Y''
        AND (   items.weight_uom_code IS NULL
             OR items.volume_uom_code IS NULL
             OR items.unit_weight IS NULL
             OR items.unit_volume IS NULL)
      ORDER BY
        (orgs.name || '' ('' || mp.organization_code || '')''),
        items.value';


BEGIN

    -- Initialization Block
    l_stmt_id := 0;
    l_local_retcode := C_SUCCESS;

    -- Column widths for each column.
    l_stmt_id := 10;
    l_org_col_width := C_ORG_COL_WIDTH;
    l_item_col_width := C_ITEM_COL_WIDTH;
    l_vol_col_width := C_VOL_MISSING_COL_WIDTH;
    l_wt_col_width := C_WT_MISSING_COL_WIDTH;
    l_wt_missing_marker := NULL;
    l_wt_ok_marker := NULL;
    l_vol_missing_marker := NULL;
    l_vol_ok_marker := NULL;
    l_line_print := NULL;

    -- Column Headers
    l_stmt_id := 20;
    l_org_col_header := FND_MESSAGE.get_string ('OPI', 'OPI_DBI_ORG_COL_HDR');
    l_org_col_header := substr (l_org_col_header, 1, l_org_col_width);

    l_item_col_header := FND_MESSAGE.get_string (
                                'OPI', 'OPI_DBI_ITEM_COL_HDR');
    l_item_col_header := substr (l_item_col_header, 1, l_item_col_width);

    l_vol_col_header := FND_MESSAGE.get_string (
                                'OPI', 'OPI_DBI_VOL_SETUP_COL_HDR');
    l_vol_col_header := substr (l_vol_col_header, 1, l_vol_col_width);

    l_wt_col_header := FND_MESSAGE.get_string (
                                'OPI', 'OPI_DBI_WT_SETUP_COL_HDR');
    l_wt_col_header := substr (l_wt_col_header, 1, l_wt_col_width);

    --First count how many items are missing setups
    l_stmt_id := 25;
    OPEN item_setup_missing_count_csr;
    FETCH item_setup_missing_count_csr INTO l_num_rows_missing;
    CLOSE item_setup_missing_count_csr;

    IF (l_num_rows_missing > 0) THEN

        -- Item setup missing header message
        l_stmt_id := 30;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
        l_item_missing_header := FND_MESSAGE.get_string (
                                    'OPI','OPI_DBI_ITEM_WT_VOL_MISSING');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_item_missing_header);

        -- Item setup missing fix message. Print it.
        l_stmt_id := 40;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
        l_item_missing_fix := FND_MESSAGE.get_string (
                                    'OPI','OPI_DBI_ITEM_WT_VOL_FIX');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_item_missing_fix);

        -- If not too many rows, print out the details
        IF (l_num_rows_missing <= C_NUM_ROWS_TO_REPORT) THEN

            l_stmt_id := 50;
            -- Print out the headers padded out with the right number
            -- of spaces.
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad (l_org_col_header,
                                     l_org_col_width + C_COL_SPACING) ||
                               rpad (l_item_col_header,
                                     l_item_col_width + C_COL_SPACING) ||
                               rpad (l_vol_col_header,
                                     l_vol_col_width + C_COL_SPACING) ||
                               rpad (l_wt_col_header,
                                     l_wt_col_width + C_COL_SPACING) );

            -- Underline the header with dashes
            l_stmt_id := 60;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_item_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_vol_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_wt_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );

            -- Markers for missing weight and volume
            l_stmt_id := 70;
            l_wt_missing_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_UNDEF_STR'),
                        1, l_wt_col_width);
            l_wt_ok_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_OK_STR'),
                        1, l_vol_col_width);
            l_vol_missing_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_UNDEF_STR'),
                        1, l_wt_col_width);
            l_vol_ok_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_OK_STR'),
                        1, l_vol_col_width);

            -- Report every missing setup.
            l_stmt_id := 80;
            OPEN item_setup_missing_csr FOR l_item_setup_missing_sql;
            FETCH item_setup_missing_csr INTO l_items_setup_missing_rec;
            WHILE item_setup_missing_csr%FOUND
            LOOP

                -- Every line will have an org/item.
                l_stmt_id := 90;
                l_line_print :=
                    rpad (substr (l_items_setup_missing_rec.org, 1,
                                  l_org_col_width),
                          l_org_col_width + C_COL_SPACING) ||
                    rpad (substr (l_items_setup_missing_rec.item, 1,
                                  l_item_col_width),
                          l_item_col_width + C_COL_SPACING);

                -- Figure out if the volume is missing
                l_stmt_id := 100;
                IF (l_items_setup_missing_rec.vol_missing_flag = C_VOL_MISSING)
                THEN
                    l_line_print :=
                        l_line_print || rpad (l_vol_missing_marker,
                                              l_vol_col_width + C_COL_SPACING);
                ELSE
                    l_line_print :=
                        l_line_print || rpad (l_vol_ok_marker,
                                              l_vol_col_width + C_COL_SPACING);
                END IF;

                -- Figure out if the weight is missing
                l_stmt_id := 110;
                IF (l_items_setup_missing_rec.wt_missing_flag = C_WT_MISSING)
                THEN
                    l_line_print :=
                        l_line_print || rpad (l_wt_missing_marker,
                                              l_wt_col_width + C_COL_SPACING);
                ELSE
                    l_line_print :=
                        l_line_print || rpad (l_wt_ok_marker,
                                              l_wt_col_width + C_COL_SPACING);
                END IF;

                -- Print this missing rate line.
                l_stmt_id := 120;
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_line_print);

                -- Fetch the next line
                FETCH item_setup_missing_csr INTO l_items_setup_missing_rec;

            END LOOP;

            CLOSE item_setup_missing_csr;

        ELSIF (l_num_rows_missing > C_NUM_ROWS_TO_REPORT) THEN

            l_too_many_rows_msg := FND_MESSAGE.get_string (
                                'OPI', 'OPI_DBI_WT_VOL_SETUP_TOOMANY');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_too_many_rows_msg);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_item_setup_missing_sql);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);


        END IF;

    END IF;  -- l_num_rows_missing > 0


    IF (l_num_rows_missing > 0) THEN
        l_local_retcode := C_WARNING;
    END IF;

    errbuf := '';
    retcode := l_local_retcode;

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        errbuf := SQLERRM;
        retcode := C_ERROR;
        return;

END report_item_setup_missing;

/*  report_locator_setup_missing

    Reports the locators in WMS organizations which are missing
    weight and/or volume setup.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/20/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_locator_setup_missing (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'report_locator_setup_missing';
    l_stmt_id NUMBER;
    l_local_retcode NUMBER;

    -- Header message
    l_loc_missing_header VARCHAR2 (10000);

    -- Fix Message
    l_loc_missing_fix VARCHAR2 (10000);

    -- 5 columns: Org, Subinventory, Locator, Volume Missing, Weight Missing.
    -- Each has a header and some width.
    l_org_col_width NUMBER;
    l_sub_col_width NUMBER;
    l_loc_col_width NUMBER;
    l_vol_col_width NUMBER;
    l_wt_col_width NUMBER;
    l_org_col_header VARCHAR2 (80);
    l_sub_col_header VARCHAR2 (80);
    l_loc_col_header VARCHAR2 (80);
    l_vol_col_header VARCHAR2 (80);
    l_wt_col_header VARCHAR2 (80);

    -- Markers to mark missing setups.
    l_wt_missing_marker VARCHAR2 (80);
    l_wt_ok_marker VARCHAR2 (80);
    l_vol_missing_marker VARCHAR2 (80);
    l_vol_ok_marker VARCHAR2 (80);

    -- Line by line print
    l_line_print VARCHAR2 (1000);

    -- Number of rows missing
    l_num_rows_missing NUMBER := 0;

    -- Message for too many missing rows
    l_too_many_rows_msg VARCHAR2 (1000);

    -- General record for missing setups
    TYPE opi_dbi_loc_setup_missing_rec is RECORD (
                org VARCHAR2(300),
                sub VARCHAR2(240),
                loc VARCHAR2(400),
                wt_missing_flag NUMBER,
                vol_missing_flag NUMBER);
    locator_setup_missing_rec opi_dbi_loc_setup_missing_rec;

    -- Count of how many locators are actually missing setups.
    -- Cursor to list all the locators with missing weight and/or
    -- volume capacity.

    CURSOR loc_setup_missing_count_csr IS
    SELECT
        count (*)
      FROM  mtl_parameters mp,
            mtl_item_locations mil
      WHERE mp.organization_id = mil.organization_id
        AND mp.wms_enabled_flag = 'Y'
        AND mp.process_enabled_flag <> 'Y'
        AND (   mil.max_weight IS NULL
             OR mil.max_cubic_area IS NULL
             OR mil.location_weight_uom_code IS NULL
             OR mil.volume_uom_code IS NULL);

    -- Cursor to list all the locators with missing weight and/or
    -- volume capacity.
    TYPE locator_setup_missing_cursor IS REF CURSOR;
    locator_setup_missing_csr locator_setup_missing_cursor;

    -- Missing setup SQL
    l_locator_setup_missing_sql CONSTANT VARCHAR2 (4000) :=
    'SELECT
        (orgs.name || '' ('' || mp.organization_code || '')'') org,
        mil.subinventory_code sub,
        INV_PROJECT.get_locator (mil.inventory_location_id,
                                 mil.organization_id) loc,
        CASE
            WHEN mil.max_weight IS NULL OR
                 mil.location_weight_uom_code IS NULL THEN
                1 /*C_WT_MISSING*/
            ELSE
                0 /*C_NOTHING_MISSING*/
            END wt_missing_flag,
        CASE
            WHEN mil.max_cubic_area IS NULL OR
                 mil.volume_uom_code IS NULL THEN
                2 /*C_VOL_MISSING*/
            ELSE
                0 /*C_NOTHING_MISSING*/
            END vol_missing_flag
      FROM  mtl_parameters mp,
            mtl_item_locations mil,
            hr_all_organization_units_vl orgs
      WHERE mp.organization_id = orgs.organization_id
        AND mp.organization_id = mil.organization_id
        AND mp.wms_enabled_flag = ''Y''
        AND mp.process_enabled_flag <> ''Y''
        AND (   mil.max_weight IS NULL
             OR mil.max_cubic_area IS NULL
             OR mil.location_weight_uom_code IS NULL
             OR mil.volume_uom_code IS NULL)
      ORDER BY
        (orgs.name || '' ('' || mp.organization_code || '')''),
        mil.subinventory_code,
        INV_PROJECT.get_locator (mil.inventory_location_id,
                                 mil.organization_id)';

BEGIN

    -- Initialization Block
    l_stmt_id := 0;
    l_local_retcode := C_SUCCESS;
    l_wt_missing_marker := NULL;
    l_wt_ok_marker := NULL;
    l_vol_missing_marker := NULL;
    l_vol_ok_marker := NULL;
    l_line_print := NULL;

    -- Column widths for each column.
    l_stmt_id := 10;
    l_org_col_width := C_ORG_COL_WIDTH;
    l_sub_col_width := C_SUB_COL_WIDTH;
    l_loc_col_width := C_LOCATOR_COL_WIDTH;
    l_vol_col_width := C_VOL_MISSING_COL_WIDTH;
    l_wt_col_width := C_WT_MISSING_COL_WIDTH;

    -- Column Headers
    l_stmt_id := 20;
    l_org_col_header := substr ('Organization', 1, l_org_col_width);

    l_sub_col_header := FND_MESSAGE.get_string ('OPI', 'OPI_DBI_SUB_COL_HDR');
    l_sub_col_header := substr (l_sub_col_header, 1, l_sub_col_width);

    l_loc_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_LOCATOR_COL_HDR');
    l_loc_col_header := substr (l_loc_col_header, 1, l_loc_col_width);

    l_vol_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_VOL_SETUP_COL_HDR');
    l_vol_col_header := substr (l_vol_col_header, 1, l_vol_col_width);

    l_wt_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_WT_SETUP_COL_HDR');
    l_wt_col_header := substr (l_wt_col_header, 1, l_wt_col_width);

    -- Check how many rows need to be fixed.
    OPEN loc_setup_missing_count_csr;
    FETCH loc_setup_missing_count_csr INTO l_num_rows_missing;
    CLOSE loc_setup_missing_count_csr;

    -- Only print out stuff if there is something missing
    IF (l_num_rows_missing > 0) THEN

        -- Locator setup missing header message
        l_stmt_id := 30;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);

        l_loc_missing_header := FND_MESSAGE.get_string (
                                    'OPI', 'OPI_DBI_LOC_WT_VOL_MISSING');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_loc_missing_header);
        -- Locator setup missing fix message. Print it.
        l_stmt_id := 40;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
        l_loc_missing_fix := FND_MESSAGE.get_string (
                                    'OPI', 'OPI_DBI_LOC_WT_VOL_FIX');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_loc_missing_fix);

        -- Only print out details if not too long. Else print out SQL
        IF (l_num_rows_missing <= C_NUM_ROWS_TO_REPORT) THEN


            -- Print out the headers padded out with the right number of spaces
            l_stmt_id := 50;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad (l_org_col_header,
                                     l_org_col_width + C_COL_SPACING) ||
                               rpad (l_sub_col_header,
                                     l_sub_col_width + C_COL_SPACING) ||
                               rpad (l_loc_col_header,
                                     l_loc_col_width + C_COL_SPACING) ||
                               rpad (l_vol_col_header,
                                     l_vol_col_width + C_COL_SPACING) ||
                               rpad (l_wt_col_header,
                                     l_wt_col_width + C_COL_SPACING) );

            -- Underline the header with dashes
            l_stmt_id := 60;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_sub_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_loc_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_vol_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_wt_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );

            -- Markers for missing weight and volume
            l_stmt_id := 70;
            l_wt_missing_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_UNDEF_STR'),
                        1, l_wt_col_width);
            l_wt_ok_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_OK_STR'),
                        1, l_vol_col_width);
            l_vol_missing_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_UNDEF_STR'),
                        1, l_wt_col_width);
            l_vol_ok_marker :=
                substr (FND_MESSAGE.get_string ('OPI', 'OPI_DBI_OK_STR'),
                        1, l_vol_col_width);

            -- Report for every missing setup.
            l_stmt_id := 80;
            OPEN locator_setup_missing_csr FOR l_locator_setup_missing_sql;
            FETCH locator_setup_missing_csr INTO locator_setup_missing_rec;
            WHILE locator_setup_missing_csr%FOUND
            LOOP

                -- Every line will have an org/sub/loc.
                l_stmt_id := 90;
                l_line_print :=
                    rpad (substr (locator_setup_missing_rec.org, 1,
                                  l_org_col_width),
                          l_org_col_width + C_COL_SPACING) ||
                    rpad (substr (locator_setup_missing_rec.sub, 1,
                                  l_sub_col_width),
                          l_sub_col_width + C_COL_SPACING) ||
                    rpad (substr (locator_setup_missing_rec.loc, 1,
                                  l_loc_col_width),
                          l_loc_col_width + C_COL_SPACING);

                -- Figure out if the volume is missing
                l_stmt_id := 100;
                IF (locator_setup_missing_rec.vol_missing_flag = C_VOL_MISSING)
                THEN
                    l_line_print :=
                        l_line_print || rpad (l_vol_missing_marker,
                                              l_vol_col_width + C_COL_SPACING);
                ELSE
                    l_line_print :=
                        l_line_print || rpad (l_vol_ok_marker,
                                              l_vol_col_width + C_COL_SPACING);
                END IF;

                -- Figure out if the weight is missing
                l_stmt_id := 110;
                IF (locator_setup_missing_rec.wt_missing_flag = C_WT_MISSING)
                THEN
                    l_line_print :=
                        l_line_print || rpad (l_wt_missing_marker,
                                              l_wt_col_width + C_COL_SPACING);
                ELSE
                    l_line_print :=
                        l_line_print || rpad (l_wt_ok_marker,
                                              l_wt_col_width + C_COL_SPACING);
                END IF;

                -- Print this missing rate line.
                l_stmt_id := 120;
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_line_print);

                -- Get the next row.
                FETCH locator_setup_missing_csr INTO locator_setup_missing_rec;

            END LOOP;

            CLOSE locator_setup_missing_csr;

        ELSIF (l_num_rows_missing > C_NUM_ROWS_TO_REPORT) THEN
            l_too_many_rows_msg := FND_MESSAGE.get_string (
                                'OPI', 'OPI_DBI_WT_VOL_SETUP_TOOMANY');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_too_many_rows_msg);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_locator_setup_missing_sql);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
        END IF;

    END IF;  -- l_num_rows_to_report > 0

    IF (l_num_rows_missing > 0) THEN
        -- Must issue warning since we found something.
        l_stmt_id := 130;
        l_local_retcode := C_WARNING;
    END IF;


    errbuf := '';
    retcode := l_local_retcode;

    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        errbuf := SQLERRM;
        retcode := C_ERROR;
        return;

END report_locator_setup_missing;

/*  report_item_conv_rate_err

    Report item level conversion rate errors.

    Providing this function the signature of retcode, errbuf since
    it may need to be a standalone conc prog.
*/
PROCEDURE report_item_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'report_item_conv_rate_err';
    l_stmt_id NUMBER;

    -- Cursor to get missing volume conversion rates
    CURSOR missing_vol_conv_csr IS
    SELECT
        (orgs.name || ' (' || mp.organization_code || ')') org,
        items.value item,
        errors.volume_uom_code
      FROM
        (SELECT
            organization_id,
            inventory_item_id || '-' || organization_id item_org_id,
            unit_volume_uom_code volume_uom_code
          FROM  opi_dbi_wms_stor_item_conv_stg
          WHERE volume_conv_rate < 0
        UNION
        SELECT
            organization_id,
            item_org_id,
            volume_uom_code
          FROM  opi_dbi_wms_curr_utz_item_f
          WHERE utilized_volume/volume_qty < 0
            AND aggregation_level_flag = C_ITEM_AGGR_LEVEL
        ) errors,
        eni_oltp_item_star items,
        hr_all_organization_units_vl orgs,
        mtl_parameters mp
      WHERE errors.organization_id = orgs.organization_id
        AND errors.organization_id = items.organization_id
        AND errors.item_org_id = items.id
        AND errors.organization_id = mp.organization_id
      ORDER BY
        (orgs.name || ' (' || mp.organization_code || ')'),
        items.value;

    -- Cursor to get missing weight conversion rates
    CURSOR missing_wt_conv_csr IS
    SELECT
        (orgs.name || ' (' || mp.organization_code || ')') org,
        items.value item,
        errors.weight_uom_code
      FROM
        (SELECT
            organization_id,
            inventory_item_id || '-' || organization_id item_org_id,
            unit_weight_uom_code weight_uom_code
          FROM  opi_dbi_wms_stor_item_conv_stg
          WHERE weight_conv_rate < 0
        UNION
        SELECT
            organization_id,
            item_org_id,
            weight_uom_code
          FROM  opi_dbi_wms_curr_utz_item_f
          WHERE stored_weight/weight_qty < 0
            AND aggregation_level_flag = C_ITEM_AGGR_LEVEL
        ) errors,
        eni_oltp_item_star items,
        hr_all_organization_units_vl orgs,
        mtl_parameters mp
      WHERE errors.organization_id = orgs.organization_id
        AND errors.organization_id = items.organization_id
        AND errors.item_org_id = items.id
        AND errors.organization_id = mp.organization_id
      ORDER BY
        (orgs.name || ' (' || mp.organization_code || ')'),
        items.value;

    -- Cursor to get the reporting UOM.
    CURSOR get_rep_uom_csr (p_measure_code IN VARCHAR2)
    IS
    SELECT rep_uom_code
      FROM  opi_dbi_rep_uoms
      WHERE measure_code = p_measure_code;

    -- place holder for UOM.
    l_uom VARCHAR2 (3);

    -- Boolean to track the header has been printed.
    l_header_printed BOOLEAN;

    -- Header/table display parameters.
    l_org_col_width NUMBER;
    l_item_col_width NUMBER;
    l_vol_col_width NUMBER;
    l_wt_col_width NUMBER;
    l_org_col_header VARCHAR2 (80);
    l_item_col_header VARCHAR2 (80);
    l_vol_col_header VARCHAR2 (80);
    l_wt_col_header VARCHAR2 (80);

BEGIN

    -- Initialization block
    l_stmt_id := 0;
    l_uom := NULL;
    l_header_printed := FALSE;

    -- Column widths
    l_stmt_id := 10;
    l_org_col_width := C_ORG_COL_WIDTH;
    l_item_col_width := C_ITEM_COL_WIDTH;
    l_vol_col_width := C_VOL_UOM_COL_WIDTH;
    l_wt_col_width := C_WT_UOM_COL_WIDTH;

    -- Column Headers
    l_stmt_id := 20;
    l_org_col_header := substr ('Organization', 1, l_org_col_width);

    l_item_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_ITEM_COL_HDR');
    l_item_col_header := substr (l_item_col_header, 1, l_item_col_width);

    l_vol_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_ITEM_VOL_UOM_COL_HDR');
    l_vol_col_header := substr (l_vol_col_header, 1, l_vol_col_width);

    l_wt_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_ITEM_WT_UOM_COL_HDR');
    l_wt_col_header := substr (l_wt_col_header, 1, l_wt_col_width);

    -- Get the volume UOM code
    l_stmt_id := 10;
    OPEN get_rep_uom_csr ('VOL');
    FETCH get_rep_uom_csr INTO l_uom;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        l_uom := NULL;
    END IF;
    CLOSE get_rep_uom_csr;

    -- Report on the volume errors only if the volume reporting UOM
    -- has been defined.
    l_stmt_id := 20;
    IF (l_uom IS NOT NULL) THEN

        -- No header printed yet
        l_header_printed := FALSE;

        -- Print all missing rates;
        l_stmt_id := 30;
        FOR missing_vol_conv_rec IN missing_vol_conv_csr
        LOOP

            -- If something was found, then print the header messsage.
            l_stmt_id := 40;
            IF (l_header_printed = FALSE) THEN

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Locator volume missing header
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI',
                                            'OPI_DBI_ITEM_VOL_CONV_ERR_HDR'));

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Volume reporting UOM.
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI', 'OPI_DBI_REP_UOM_VOL') ||
                    ' ' || l_uom);


                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Table header row
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                   rpad (l_org_col_header,
                                         l_org_col_width + C_COL_SPACING) ||
                                   rpad (l_item_col_header,
                                         l_item_col_width + C_COL_SPACING) ||
                                   rpad (l_vol_col_header,
                                         l_vol_col_width + C_COL_SPACING));

                -- Table header underline
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_item_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_vol_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );


                l_header_printed := TRUE;

            END IF;


            -- Output every row.
            l_stmt_id := 50;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                rpad (substr (missing_vol_conv_rec.org, 1,
                              l_org_col_width),
                      l_org_col_width + C_COL_SPACING) ||
                rpad (substr (missing_vol_conv_rec.item, 1,
                              l_item_col_width),
                  l_item_col_width + C_COL_SPACING) ||
                rpad (substr (missing_vol_conv_rec.volume_uom_code, 1,
                              l_vol_col_width),
                      l_vol_col_width + C_COL_SPACING));

        END LOOP;

        -- Footer for this section
        l_stmt_id := 60;
        IF (l_header_printed = TRUE) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            OPI_DBI_REP_UOM_PKG.err_msg_footer;
        END IF;

    END IF;

    -- Get the volume UOM code
    l_stmt_id := 100;
    OPEN get_rep_uom_csr ('WT');
    FETCH get_rep_uom_csr INTO l_uom;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        l_uom := NULL;
    END IF;
    CLOSE get_rep_uom_csr;

    -- Report on the volume errors only if the volume reporting UOM
    -- has been defined.
    l_stmt_id := 120;
    IF (l_uom IS NOT NULL) THEN

        -- No header printed yet
        l_header_printed := FALSE;

        -- Print all missing rates;
        l_stmt_id := 130;
        FOR missing_wt_conv_rec IN missing_wt_conv_csr
        LOOP

            -- If something was found, then print the header messsage.
            l_stmt_id := 140;
            IF (l_header_printed = FALSE) THEN


                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Locator volume missing header
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI',
                                            'OPI_DBI_ITEM_WT_CONV_ERR_HDR'));

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Volume reporting UOM.
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI', 'OPI_DBI_REP_UOM_WT') ||
                    ' ' || l_uom);

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Table header row
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                   rpad (l_org_col_header,
                                         l_org_col_width + C_COL_SPACING) ||
                                   rpad (l_item_col_header,
                                         l_item_col_width + C_COL_SPACING) ||
                                   rpad (l_vol_col_header,
                                         l_vol_col_width + C_COL_SPACING));

                -- Table header underline
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_item_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_vol_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );


                l_header_printed := TRUE;

            END IF;


            -- Output every row.
            l_stmt_id := 150;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                rpad (substr (missing_wt_conv_rec.org, 1,
                              l_org_col_width),
                      l_org_col_width + C_COL_SPACING) ||
                rpad (substr (missing_wt_conv_rec.item, 1,
                              l_item_col_width),
                  l_item_col_width + C_COL_SPACING) ||
                rpad (substr (missing_wt_conv_rec.weight_uom_code, 1,
                              l_vol_col_width),
                      l_vol_col_width + C_COL_SPACING));

        END LOOP;

        -- Footer for this section
        l_stmt_id := 160;
        IF (l_header_printed = TRUE) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            OPI_DBI_REP_UOM_PKG.err_msg_footer;
        END IF;

    END IF;



    errbuf := '';
    retcode := C_SUCCESS;
    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        errbuf := SQLERRM;
        retcode := C_ERROR;
        RAISE ITEM_CONV_RATES_DET_ERR;
        return;

END report_item_conv_rate_err;


/*  report_locator_conv_rate_err

    Report locator level conversion rate errors.

    Providing this function the signature of retcode, errbuf since
    it may need to be a standalone conc prog.
*/
PROCEDURE report_locator_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER)
IS

    l_proc_name CONSTANT VARCHAR2 (40) := 'report_locator_conv_rate_err';
    l_stmt_id NUMBER;

    -- Report all missing volumes at the locator level.
    CURSOR missing_vol_conv_csr IS
    SELECT
        (orgs.name || ' (' || mp.organization_code || ')') org,
        stg.subinventory_code sub,
        INV_PROJECT.get_locator (stg.locator_id, stg.organization_id)
            loc,
        stg.volume_uom_code
      FROM  opi_dbi_wms_curr_utz_sub_stg stg,
            mtl_parameters mp,
            hr_all_organization_units_vl orgs
      WHERE mp.organization_id = orgs.organization_id
        AND mp.wms_enabled_flag = 'Y'
        AND mp.process_enabled_flag <> 'Y'
        AND mp.organization_id = stg.organization_id
        AND stg.volume_capacity_rep < 0
      ORDER BY
        (orgs.name || ' (' || mp.organization_code || ')'),
        stg.subinventory_code,
        INV_PROJECT.get_locator (stg.locator_id, stg.organization_id);

    -- Report all missing weights at the locator level.
    CURSOR missing_wt_conv_csr IS
    SELECT
        (orgs.name || ' (' || mp.organization_code || ')') org,
        stg.subinventory_code sub,
        INV_PROJECT.get_locator (stg.locator_id, stg.organization_id)
            loc,
        stg.weight_uom_code
      FROM  opi_dbi_wms_curr_utz_sub_stg stg,
            mtl_parameters mp,
            hr_all_organization_units_vl orgs
      WHERE mp.organization_id = orgs.organization_id
        AND mp.wms_enabled_flag = 'Y'
        AND mp.process_enabled_flag <> 'Y'
        AND mp.organization_id = stg.organization_id
        AND stg.weight_capacity_rep < 0
      ORDER BY
        (orgs.name || ' (' || mp.organization_code || ')'),
        stg.subinventory_code,
        INV_PROJECT.get_locator (stg.locator_id, stg.organization_id);

    -- Cursor to get the reporting UOM.
    CURSOR get_rep_uom_csr (p_measure_code IN VARCHAR2)
    IS
    SELECT rep_uom_code
      FROM  opi_dbi_rep_uoms
      WHERE measure_code = p_measure_code;

    -- place holder for UOM.
    l_uom VARCHAR2 (3);

    -- Boolean to track the header has been printed.
    l_header_printed BOOLEAN;

    -- Header/table display parameters.
    l_org_col_width NUMBER;
    l_sub_col_width NUMBER;
    l_loc_col_width NUMBER;
    l_vol_col_width NUMBER;
    l_wt_col_width NUMBER;
    l_org_col_header VARCHAR2 (80);
    l_sub_col_header VARCHAR2 (80);
    l_loc_col_header VARCHAR2 (80);
    l_vol_col_header VARCHAR2 (80);
    l_wt_col_header VARCHAR2 (80);

BEGIN

    -- Initialization block
    l_stmt_id := 0;
    l_uom := NULL;
    l_header_printed := FALSE;

    -- Column widths
    l_stmt_id := 10;
    l_org_col_width := C_ORG_COL_WIDTH;
    l_sub_col_width := C_SUB_COL_WIDTH;
    l_loc_col_width := C_LOCATOR_COL_WIDTH;
    l_vol_col_width := C_VOL_UOM_COL_WIDTH;
    l_wt_col_width := C_WT_UOM_COL_WIDTH;


    -- Column Headers
    l_stmt_id := 20;
    l_org_col_header := substr ('Organization', 1, l_org_col_width);

    l_sub_col_header := FND_MESSAGE.get_string ('OPI', 'OPI_DBI_SUB_COL_HDR');
    l_sub_col_header := substr (l_sub_col_header, 1, l_sub_col_width);

    l_loc_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_LOCATOR_COL_HDR');
    l_loc_col_header := substr (l_loc_col_header, 1, l_loc_col_width);

    l_vol_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_LOC_VOL_UOM_COL_HDR');
    l_vol_col_header := substr (l_vol_col_header, 1, l_vol_col_width);

    l_wt_col_header := FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_LOC_WT_UOM_COL_HDR');
    l_wt_col_header := substr (l_wt_col_header, 1, l_wt_col_width);

    -- Get the volume UOM code
    l_stmt_id := 10;
    OPEN get_rep_uom_csr ('VOL');
    FETCH get_rep_uom_csr INTO l_uom;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        l_uom := NULL;
    END IF;
    CLOSE get_rep_uom_csr;

    -- Report on the volume errors only if the volume reporting UOM
    -- has been defined.
    l_stmt_id := 20;
    IF (l_uom IS NOT NULL) THEN

        -- No header printed yet
        l_header_printed := FALSE;

        -- Print all missing rates;
        l_stmt_id := 30;
        FOR missing_vol_conv_rec IN missing_vol_conv_csr
        LOOP

            -- If something was found, then print the header messsage.
            l_stmt_id := 40;
            IF (l_header_printed = FALSE) THEN

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Volume reporting UOM.
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI', 'OPI_DBI_REP_UOM_VOL') ||
                    ' ' || l_uom);

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Locator volume missing header
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI',
                                            'OPI_DBI_LOC_VOL_CONV_ERR_HDR'));

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Volume reporting UOM.
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI', 'OPI_DBI_REP_UOM_VOL') ||
                    ' ' || l_uom);

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Table header row
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                   rpad (l_org_col_header,
                                         l_org_col_width + C_COL_SPACING) ||
                                   rpad (l_sub_col_header,
                                         l_sub_col_width + C_COL_SPACING) ||
                                   rpad (l_loc_col_header,
                                         l_loc_col_width + C_COL_SPACING) ||
                                   rpad (l_vol_col_header,
                                         l_vol_col_width + C_COL_SPACING));

                -- Table header underline
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_sub_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_loc_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_vol_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );


                l_header_printed := TRUE;

            END IF;


            -- Output every row.
            l_stmt_id := 50;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                rpad (substr (missing_vol_conv_rec.org, 1,
                              l_org_col_width),
                      l_org_col_width + C_COL_SPACING) ||
                rpad (substr (missing_vol_conv_rec.sub, 1,
                              l_sub_col_width),
                  l_sub_col_width + C_COL_SPACING) ||
                rpad (substr (missing_vol_conv_rec.loc, 1,
                              l_loc_col_width),
                      l_loc_col_width + C_COL_SPACING) ||
                rpad (substr (missing_vol_conv_rec.volume_uom_code, 1,
                              l_vol_col_width),
                      l_vol_col_width + C_COL_SPACING));

        END LOOP;

        -- Footer for this section
        l_stmt_id := 60;
        IF (l_header_printed = TRUE) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            OPI_DBI_REP_UOM_PKG.err_msg_footer;
        END IF;

    END IF;

    -- Get the volume UOM code
    l_stmt_id := 90;
    OPEN get_rep_uom_csr ('WT');
    FETCH get_rep_uom_csr INTO l_uom;
    IF (get_rep_uom_csr%NOTFOUND) THEN
        l_uom := NULL;
    END IF;
    CLOSE get_rep_uom_csr;

    -- Report on the weight errors only if the weight reporting UOM
    -- has been defined.
    l_stmt_id := 100;
    IF (l_uom IS NOT NULL) THEN

        -- No header printed yet
        l_header_printed := FALSE;

        -- Print all missing rates;
        l_stmt_id := 110;
        FOR missing_wt_conv_rec IN missing_wt_conv_csr
        LOOP

            -- If something was found, then print the header messsage.
            l_stmt_id := 120;
            IF (l_header_printed = FALSE) THEN

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Locator weight missing header
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI',
                                            'OPI_DBI_LOC_WT_CONV_ERR_HDR'));

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Weight reporting UOM.
                FND_FILE.PUT_LINE (
                    FND_FILE.OUTPUT,
                    FND_MESSAGE.get_string ('OPI', 'OPI_DBI_REP_UOM_WT') ||
                    ' ' || l_uom);

                -- Blank line.
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
                -- Table header row
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                                   rpad (l_org_col_header,
                                         l_org_col_width + C_COL_SPACING) ||
                                   rpad (l_sub_col_header,
                                         l_sub_col_width + C_COL_SPACING) ||
                                   rpad (l_loc_col_header,
                                         l_loc_col_width + C_COL_SPACING) ||
                                   rpad (l_wt_col_header,
                                         l_wt_col_width + C_COL_SPACING));

                -- Table header underline
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                               rpad ('-', l_org_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_sub_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_loc_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) ||
                               rpad ('-', l_wt_col_width, '-') ||
                               rpad (' ', C_COL_SPACING) );

                l_header_printed := TRUE;

            END IF;

            -- Output every row.
            l_stmt_id := 130;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                rpad (substr (missing_wt_conv_rec.org, 1,
                              l_org_col_width),
                      l_org_col_width + C_COL_SPACING) ||
                rpad (substr (missing_wt_conv_rec.sub, 1,
                              l_sub_col_width),
                  l_sub_col_width + C_COL_SPACING) ||
                rpad (substr (missing_wt_conv_rec.loc, 1,
                              l_loc_col_width),
                      l_loc_col_width + C_COL_SPACING) ||
                rpad (substr (missing_wt_conv_rec.weight_uom_code, 1,
                              l_wt_col_width),
                      l_wt_col_width + C_COL_SPACING));

        END LOOP;

        -- Footer for this section
        l_stmt_id := 140;
        IF (l_header_printed = TRUE) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, C_BLANK_LINE);
            OPI_DBI_REP_UOM_PKG.err_msg_footer;
        END IF;

    END IF;

    errbuf := '';
    retcode := C_SUCCESS;
    return;

EXCEPTION

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        errbuf := SQLERRM;
        retcode := C_ERROR;
        RAISE LOC_CONV_RATES_DET_ERR;
        return;

END report_locator_conv_rate_err;


/*  report_item_loc_conv_rate_err

    Report the item level and locator level information for missing
    conversion rates found by the ETLs for the Warehouse Storage Utilized
    and Current Capacity Utilization reports.

    This function is meant to be publicly accessed by a standalone
    concurrent program that the user can optionally run to debug
    their item/locator setups.

    History:
    Date        Author              Action
    01/10/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_item_loc_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY NUMBER)
IS
    l_proc_name CONSTANT VARCHAR2 (40) := 'report_item_loc_conv_rate_err';

    l_stmt_id NUMBER;

BEGIN

    -- Initialization block
    l_stmt_id := 0;


    -- print out the title
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       FND_MESSAGE.get_string (
                            'OPI', 'OPI_DBI_ITEM_LOC_CONV_ERR_HDR'));

    -- Report the item level details.
    -- Volume and weight should be reported in two different sections.
    l_stmt_id := 10;
    report_item_conv_rate_err (errbuf, retcode);
    l_stmt_id := 20;

    -- Report the locator level details.
    -- Volume and weight should be reported in two different sections.
    l_stmt_id := 30;
    report_locator_conv_rate_err (errbuf, retcode);
    l_stmt_id := 40;

    errbuf := '';
    retcode := C_SUCCESS;

    return;

EXCEPTION

    WHEN ITEM_CONV_RATES_DET_ERR THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (
            err_mesg (ITEM_CONV_RATES_DET_ERR_MESG,
                      l_proc_name, l_stmt_id));

        errbuf := C_ITEM_LOC_CONV_RATE_ERR;
        retcode := C_ERROR;
        return;

    WHEN LOC_CONV_RATES_DET_ERR THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (
            err_mesg (LOC_CONV_RATES_DET_ERR_MESG,
                      l_proc_name, l_stmt_id));

        errbuf := C_ITEM_LOC_CONV_RATE_ERR;
        retcode := C_ERROR;
        return;

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                     l_stmt_id));
        errbuf := SQLERRM;
        retcode := C_ERROR;
        return;

END report_item_loc_conv_rate_err;

/*  set_wdth_cu1_date

    Get the CU1 date based on the data in the WMS_DISPATCHED_TASKS_HISTORY
    table. The CU1 date is the first one with transaction_temp_id not set
    as null.

    If no such date is found, then set the sysdate to be the CU1 date.

    In general since this API can be called simultaneously by multiple
    ETLs, it will merge the CU1 date into the OPI_DBI_CONC_PROG_RUN_LOG
    with type = 'WDTH_CU1_DATE'.

    Parameters:
    p_overwrite - if true, then function always picks the date from WDTH.
                  if false, then does nothing if a record already exists
                  in the OPI_DBI_CONC_PROG_RUN_LOG.

    History:
    Date        Author              Action
    01/10/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE set_wdth_cu1_date (p_overwrite BOOLEAN)
IS

    -- Date from WDTH
    l_wdth_cu1_date DATE;

    -- Check if CU1 date already exists
    l_cu1_date_exists BOOLEAN;

    -- Existing CU1 date
    l_existing_cu1_date DATE;

    -- Cursor to get existing CU1 date.
    CURSOR existing_cu1_date_csr IS
    SELECT last_run_date
      FROM  opi_dbi_conc_prog_run_log
      WHERE ETL_TYPE = C_WDTH_CU1_DATE_TYPE;

    -- Cursor to get the CU1 date from WDTH
    CURSOR wdth_cu1_date_csr IS
    SELECT /*+ parallel (wdth) */
        nvl (min (wdth.creation_date), sysdate)
      FROM  wms_dispatched_tasks_history wdth
      WHERE transaction_temp_id IS NOT NULL;

    -- Audit columns
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_program_id                NUMBER;
    l_program_login_id          NUMBER;
    l_program_application_id    NUMBER;
    l_request_id                NUMBER;


BEGIN

    -- No CU1 existing date so far.
    l_cu1_date_exists := FALSE;

    -- If not forced to overwrite, check if a record already exists.
    IF (p_overwrite = FALSE) THEN

        OPEN existing_cu1_date_csr;
        FETCH existing_cu1_date_csr INTO l_existing_cu1_date;
        IF (existing_cu1_date_csr%FOUND) THEN
            l_cu1_date_exists := TRUE;
        END IF;

        CLOSE existing_cu1_date_csr;

    END IF;

    -- Set the WDTH date if forced to overwrite or if no
    -- record exists.
    IF (p_overwrite = TRUE OR l_cu1_date_exists = FALSE) THEN

        -- Get the CU1 date. Will default to sysdate.
        OPEN wdth_cu1_date_csr;
        FETCH wdth_cu1_date_csr INTO l_wdth_cu1_date;
        CLOSE wdth_cu1_date_csr;

        -- Audit column information
        l_user_id := nvl(fnd_global.user_id, -1);
        l_login_id := nvl(fnd_global.login_id, -1);
        l_program_id := nvl (fnd_global.conc_program_id, -1);
        l_program_login_id := nvl (fnd_global.conc_login_id, -1);
        l_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
        l_request_id := nvl (fnd_global.conc_request_id, -1);


        -- Merge the date into the log
        MERGE INTO opi_dbi_conc_prog_run_log base
        USING
            (SELECT
                C_WDTH_CU1_DATE_TYPE etl_type,
                l_wdth_cu1_date last_run_date,
                sysdate creation_date,
                sysdate last_update_date,
                l_user_id created_by,
                l_user_id last_updated_by,
                l_login_id last_update_login,
                l_program_application_id program_application_id,
                l_program_id program_id,
                l_program_login_id program_login_id,
                l_request_id request_id
              FROM  dual) new
        ON (base.etl_type = new.etl_type)
        WHEN MATCHED THEN UPDATE
        SET
            base.last_run_date = new.last_run_date,
            base.last_update_date = new.last_update_date,
            base.last_updated_by = new.last_updated_by,
            base.last_update_login = new.last_update_login,
            base.program_id = new.program_id,
            base.program_login_id = new.program_login_id,
            base.program_application_id = new.program_application_id,
            base.request_id = new.request_id
        WHEN NOT MATCHED THEN
        INSERT (
            base.etl_type,
            base.last_run_date,
            base.creation_date,
            base.last_update_date,
            base.created_by,
            base.last_updated_by,
            base.last_update_login,
            base.program_id,
            base.program_login_id,
            base.program_application_id,
            base.request_id
        )
        VALUES (
            new.etl_type,
            new.last_run_date,
            new.creation_date,
            new.last_update_date,
            new.created_by,
            new.last_updated_by,
            new.last_update_login,
            new.program_id,
            new.program_login_id,
            new.program_application_id,
            new.request_id);


        -- Commit date
        commit;

    END IF;

END set_wdth_cu1_date;


/*  set_wms_pts_gsd

    Set the WMS pick to ship rack start date as the max of the
    WDTH CU1 date and GSD with a type of 'WMS_PTS_GSD'. If the GSD is
    NULL, then set the pick to ship start date as NULL.

    As a side effect, populates/updates the WDTH CU1 date as needed.

    Also, we don't want to modify this date unless it is different,
    because otherwise MVs that depend on this might not fast refresh.

    Parameters:
    p_overwrite - if true, then function force updates the WDTH CU1 date.
                  if false, then WDTH CU1 date is not modified (if
                  it already exists).

    History:
    Date        Author              Action
    02/18/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE set_wms_pts_gsd (p_overwrite BOOLEAN)
IS

    -- WDTH CU1 date
    CURSOR wdth_cu1_date_csr IS
    SELECT
        last_run_date
      FROM opi_dbi_conc_prog_run_log
      WHERE etl_type = C_WDTH_CU1_DATE_TYPE;

    -- PTS ship date
    CURSOR wms_pts_gsd_csr IS
    SELECT
        last_run_date
      FROM opi_dbi_conc_prog_run_log
      WHERE etl_type = C_WMS_PTS_DATE_TYPE;


    -- Pick to Ship start date
    l_pts_start_date DATE;
    l_old_pts_start_date DATE;

    -- GSD
    l_gsd DATE;

    -- Audit columns
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_program_id                NUMBER;
    l_program_login_id          NUMBER;
    l_program_application_id    NUMBER;
    l_request_id                NUMBER;

BEGIN

    -- First set the WDTH CU1 date as requested
    set_wdth_cu1_date (p_overwrite);

    -- get the GSD
    l_gsd := bis_common_parameters.get_global_start_date;

    -- Pick to ship start date is max of GSD and WDTH CU1 date.
    OPEN wdth_cu1_date_csr;
    FETCH wdth_cu1_date_csr INTO l_pts_start_date;

    IF (l_gsd IS NULL) THEN
        l_pts_start_date := NULL;
    ELSIF (wdth_cu1_date_csr%NOTFOUND OR
           l_pts_start_date IS NULL OR
           l_pts_start_date < l_gsd) THEN
        l_pts_start_date := l_gsd;
    END IF;

    CLOSE wdth_cu1_date_csr;

    -- Get the existing PTS start date.
    OPEN wms_pts_gsd_csr;
    FETCH wms_pts_gsd_csr INTO l_old_pts_start_date;
    CLOSE wms_pts_gsd_csr;

    -- Merge the start date into the log table if it has not changed.
    IF (nvl (l_old_pts_start_date, to_date ('01-01-1951', 'DD-MM-YYYY')) <>
        nvl (l_pts_start_date, to_date ('01-01-1951', 'DD-MM-YYYY')) ) THEN

        -- Audit column information
        l_user_id := nvl(fnd_global.user_id, -1);
        l_login_id := nvl(fnd_global.login_id, -1);
        l_program_id := nvl (fnd_global.conc_program_id, -1);
        l_program_login_id := nvl (fnd_global.conc_login_id, -1);
        l_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
        l_request_id := nvl (fnd_global.conc_request_id, -1);

        -- Merge the date into the log
        MERGE INTO opi_dbi_conc_prog_run_log base
        USING
            (SELECT
                C_WMS_PTS_DATE_TYPE etl_type,
                l_pts_start_date last_run_date,
                sysdate creation_date,
                sysdate last_update_date,
                l_user_id created_by,
                l_user_id last_updated_by,
                l_login_id last_update_login,
                l_program_application_id program_application_id,
                l_program_id program_id,
                l_program_login_id program_login_id,
                l_request_id request_id
              FROM  dual) new
        ON (base.etl_type = new.etl_type)
        WHEN MATCHED THEN UPDATE
        SET
            base.last_run_date = new.last_run_date,
            base.last_update_date = new.last_update_date,
            base.last_updated_by = new.last_updated_by,
            base.last_update_login = new.last_update_login,
            base.program_id = new.program_id,
            base.program_login_id = new.program_login_id,
            base.program_application_id = new.program_application_id,
            base.request_id = new.request_id
        WHEN NOT MATCHED THEN
        INSERT (
            base.etl_type,
            base.last_run_date,
            base.creation_date,
            base.last_update_date,
            base.created_by,
            base.last_updated_by,
            base.last_update_login,
            base.program_id,
            base.program_login_id,
            base.program_application_id,
            base.request_id
        )
        VALUES (
            new.etl_type,
            new.last_run_date,
            new.creation_date,
            new.last_update_date,
            new.created_by,
            new.last_updated_by,
            new.last_update_login,
            new.program_id,
            new.program_login_id,
            new.program_application_id,
            new.request_id);

        -- Commit date
        commit;

    END IF;

    return;

END set_wms_pts_gsd;

  function get_uom_rate (p_inventory_item_id varchar2,
                         p_primary_uom_code varchar2,
                         p_txn_uom_code varchar2) return number
  is
    l_ret number;
  begin
    l_ret := inv_convert.inv_um_convert(
               p_inventory_item_id, 5, 1,
               p_txn_uom_code,
               p_primary_uom_code,
               null, null
             );
    if (l_ret < 0) then
      if (not g_missing_uom) then
        bis_collection_utilities.writemissinguomheader;
        g_missing_uom := true;
      end if;
      bis_collection_utilities.writemissinguom(
        nvl(p_txn_uom_code,' '),
        nvl(p_primary_uom_code,' '),
        p_inventory_item_id
      );
    end if;
    return l_ret;
  end get_uom_rate;

END opi_dbi_wms_utility_pkg;

/
