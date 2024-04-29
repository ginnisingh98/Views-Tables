--------------------------------------------------------
--  DDL for Package Body OPI_DBI_REP_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_REP_UOM_PKG" AS
/* $Header: OPIDUMCNB.pls 120.0 2005/05/24 17:20:21 appldev noship $ */


/*------------------------------------
| Function to convert from one        |
| UOM to another UOM                  |
|____________________________________*/

FUNCTION  uom_convert (
        p_item_id               number,
        p_precision             number,
        p_from_quantity         number,
        p_from_code             varchar2,
        p_to_code               varchar2) RETURN number PARALLEL_ENABLE IS


    /* Declarations */
    l_from_class        varchar2(100);
    l_to_class          varchar2(100);
    l_from_base_code    varchar2(3);
    l_to_base_code      varchar2(3);
    l_from_intra_rate   number;
    l_to_intra_rate     number;
    l_inter_rate        number;
    l_to_quantity       number;
    l_eff_precision     number;
    l_eff_from_quantity number;
    l_eff_item_id       number;
    l_reverse_flag      number;


    cursor get_uom_class(p_code IN varchar2) is
        SELECT  uom_class
        FROM    mtl_units_of_measure
        WHERE   uom_code = p_code
        AND     rownum < 2;


    cursor base_uom_code(p_class IN varchar2) is
        SELECT  uom_code
        FROM    mtl_units_of_measure
                WHERE   uom_class = p_class
        AND     base_uom_flag = 'Y'
        AND     rownum < 2;

    cursor inter_conversions is
        SELECT  decode(from_base_uom_code, l_from_base_code, 1, 2) flag,
                conv_rate
        FROM    opi_dbi_uom_class_std_conv
        WHERE   (from_base_uom_code = l_from_base_code
                AND to_base_uom_code = l_to_base_code)
        OR      (from_base_uom_code = l_to_base_code
                AND to_base_uom_code = l_from_base_code);

    inter_rec inter_conversions%rowtype;

BEGIN

    l_to_quantity := -99999;
    l_eff_item_id := nvl(p_item_id, 0);


    open get_uom_class(p_from_code);  /* get from UOM class */
        fetch get_uom_class into l_from_class;

        if get_uom_class%notfound then
            return (-99995);
        end if;
    close get_uom_class;

    open get_uom_class(p_to_code);  /* get to UOM class */
        fetch get_uom_class into l_to_class;

        if get_uom_class%notfound then
            return (-99995);
        end if;
    close get_uom_class;

    open base_uom_code(l_from_class);  /* get from base UOM */
        fetch base_uom_code into l_from_base_code;

        if base_uom_code%notfound then
            return (-99995);
        end if;
    close base_uom_code;

    open base_uom_code(l_to_class);  /* get to base UOM */
        fetch base_uom_code into l_to_base_code;

        if base_uom_code%notfound then
            return (-99995);
        end if;
    close base_uom_code;

    if ( l_from_class = l_to_class) then /* intraclass */

        l_to_quantity := inv_convert.inv_um_convert(l_eff_item_id, p_precision,
                   p_from_quantity, p_from_code, p_to_code, null, null);
    else /* interclass */
        if (l_eff_item_id <> 0) then
             l_to_quantity := inv_convert.inv_um_convert(l_eff_item_id, p_precision,
                    p_from_quantity, p_from_code, p_to_code, null, null);
        end if;

        if (l_to_quantity = -99999) then

            /*  standard interclass case or item specific interclass undefined
            1. use inv_conv api to get rate between from_uom and from_base_uom.
            2. use opi_dbi_uom_class_std_conv table to get rate between from_base_uom and to_base_uom.
            3. use inv_conv api to get rate between to_base_uom and to_uom.             */

            l_from_intra_rate := inv_convert.inv_um_convert(l_eff_item_id, p_precision, 1,
                       p_from_code, l_from_base_code, null, null);
            if ( l_from_intra_rate = -99999 ) then
                RETURN (-99998);
            end if;


            open inter_conversions;
                fetch inter_conversions into inter_rec;

                if inter_conversions%notfound then
                    return (-99997);
                end if;

                l_reverse_flag := inter_rec.flag;

                if (l_reverse_flag = 1) then
                    l_inter_rate := inter_rec.conv_rate;
                else
                    l_inter_rate := 1/inter_rec.conv_rate;
                end if;

            close inter_conversions;

            l_to_intra_rate := inv_convert.inv_um_convert(l_eff_item_id, p_precision, 1,
                     l_to_base_code, p_to_code, null, null);

            if ( l_to_intra_rate = -99999 ) then
                RETURN (-99996);
            end if;

            l_eff_precision := nvl(p_precision, 5);
            l_eff_from_quantity := nvl(p_from_quantity, 1);
            l_to_quantity := round(l_eff_from_quantity * l_from_intra_rate *
                       l_inter_rate * l_to_intra_rate, l_eff_precision);
        end if;
    end if;

    RETURN l_to_quantity;

    EXCEPTION
        when others then
            return (-100000);

END uom_convert;



/*------------------------------------
| Function that returns the reporting |
| UOM code for a particular measure   |
| type                                |
|____________________________________*/

FUNCTION  get_reporting_uom(p_measure_code varchar2) RETURN varchar2 PARALLEL_ENABLE IS

    l_reporting_uom varchar2(3);


    cursor get_rep_uom(p_measure IN varchar2) is
        SELECT  rep_uom_code
        FROM    opi_dbi_rep_uoms
        WHERE   measure_code = p_measure;
BEGIN

    open get_rep_uom(p_measure_code);

    fetch get_rep_uom into l_reporting_uom;

    if get_rep_uom%notfound then
        l_reporting_uom := null;
    end if;

    close get_rep_uom;

    RETURN l_reporting_uom;

END get_reporting_uom;


/*------------------------------------
| Functions that return the reporting |
| UOM name for a particular measure   |
| type                                |
|____________________________________*/

/* Get weight Reporting UOM */

FUNCTION get_w RETURN varchar2 PARALLEL_ENABLE IS

    l_reporting_uom varchar2(30);


    cursor get_rep_uom is
        SELECT  uoms.unit_of_measure_tl
        FROM    opi_dbi_rep_uoms        rep_uoms,
                mtl_units_of_measure_vl uoms
        WHERE   rep_uoms.measure_code = 'WT'
        AND     rep_uoms.rep_uom_code = uoms.uom_code;
BEGIN

    open get_rep_uom;

    fetch get_rep_uom into l_reporting_uom;

    if get_rep_uom%notfound then
        l_reporting_uom := NULL;
    end if;

    close get_rep_uom;

    RETURN l_reporting_uom;

END get_w;


/* Get volume Reporting UOM */

FUNCTION get_v RETURN varchar2 PARALLEL_ENABLE IS

    l_reporting_uom varchar2(30);


    cursor get_rep_uom is
        SELECT  uoms.unit_of_measure_tl
        FROM    opi_dbi_rep_uoms        rep_uoms,
                mtl_units_of_measure_vl uoms
        WHERE   rep_uoms.measure_code = 'VOL'
          AND   rep_uoms.rep_uom_code = uoms.uom_code;
BEGIN

    open get_rep_uom;

    fetch get_rep_uom into l_reporting_uom;

    if get_rep_uom%notfound then
        l_reporting_uom := NULL;
    end if;

    close get_rep_uom;

    RETURN l_reporting_uom;

END get_v;

/* Get distance Reporting UOM */

FUNCTION get_d RETURN varchar2 PARALLEL_ENABLE IS

    l_reporting_uom varchar2(30);


    cursor get_rep_uom is
        SELECT  uoms.unit_of_measure_tl
        FROM    opi_dbi_rep_uoms        rep_uoms,
                mtl_units_of_measure_vl uoms
        WHERE   rep_uoms.measure_code = 'DIS'
          AND   rep_uoms.rep_uom_code = uoms.uom_code;
BEGIN

    open get_rep_uom;

    fetch get_rep_uom into l_reporting_uom;

    if get_rep_uom%notfound then
        l_reporting_uom := NULL;
    end if;

    close get_rep_uom;

    RETURN l_reporting_uom;

END get_d;

/*------------------------------------
| Procedure to print header of        |
| error message                       |
|____________________________________*/

PROCEDURE err_msg_header IS

    l_label1    varchar2(30);
    l_label2    varchar2(30);
    l_label3    varchar2(30);
    l_label4    varchar2(30);
    l_label5    varchar2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      fnd_message.get_string('OPI', 'OPI_DBI_MISSING_UOM'));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, NEWLINE);

    l_label1 := fnd_message.get_string('OPI', 'OPI_DBI_COL_FROM_UOM');
    l_label2 := fnd_message.get_string('OPI', 'OPI_DBI_COL_FROM_UOM_CLASS');
    l_label3 := fnd_message.get_string('OPI', 'OPI_DBI_COL_TO_UOM');
    l_label4 := fnd_message.get_string('OPI', 'OPI_DBI_COL_TO_UOM_CLASS');

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       rpad(l_label1, COL_WIDTH) ||
                       rpad(l_label2, COL_WIDTH) ||
                       rpad(l_label3, COL_WIDTH) ||
                       rpad(l_label4, COL_WIDTH) );

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) );

END err_msg_header;


/*------------------------------------
| Procedure to print footer of        |
| error message                       |
|____________________________________*/

PROCEDURE err_msg_footer IS

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, NEWLINE);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      rpad ('=+', LINE_WIDTH, '=+'));

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, NEWLINE);

    return;

END err_msg_footer;


/*------------------------------------
| Procedure to print missing UOMS.    |
|                                     |
|____________________________________*/

PROCEDURE err_msg_missing_uoms(p_from_uom_code varchar2, p_to_uom_code varchar2) IS

    l_from_uom      varchar2(25);
    l_to_uom        varchar2(25);
    l_from_class    varchar2(10);
    l_to_class      varchar2(10);

    cursor uom_info(p_code IN varchar2) is
        SELECT  unit_of_measure_tl, uom_class
        FROM    mtl_units_of_measure_vl
        WHERE   uom_code = p_code
        AND     rownum < 2;

    uom_info_rec    uom_info%rowtype;

    invalid_from_uom    EXCEPTION;
    invalid_to_uom      EXCEPTION;
BEGIN

    open uom_info(p_from_uom_code);

        fetch uom_info into uom_info_rec;

        if uom_info%notfound then
            raise invalid_from_uom;
        end if;

        l_from_uom := uom_info_rec.unit_of_measure_tl;
        l_from_class := uom_info_rec.uom_class;

    close uom_info;

    open uom_info(p_to_uom_code);

        fetch uom_info into uom_info_rec;

        if uom_info%notfound then
            raise invalid_to_uom;
        end if;

        l_to_uom := uom_info_rec.unit_of_measure_tl;
        l_to_class := uom_info_rec.uom_class;

    close uom_info;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      rpad(l_from_uom, COL_WIDTH)   ||
                      rpad(l_from_class, COL_WIDTH) ||
                      rpad(l_to_uom, COL_WIDTH)     ||
                      rpad(l_to_class, COL_WIDTH));

EXCEPTION
    when invalid_from_uom then
        BIS_COLLECTION_UTILITIES.PUT_LINE (fnd_message.get_string('OPI', 'OPI_DBI_INVALID_UOM_CODE')
                      || ' ' || p_from_uom_code);
    when invalid_to_uom then
        BIS_COLLECTION_UTILITIES.PUT_LINE (fnd_message.get_string('OPI', 'OPI_DBI_INVALID_UOM_CODE')
                      || ' ' || p_to_uom_code);
    when others then
        BIS_COLLECTION_UTILITIES.PUT_LINE (fnd_message.get_string('OPI', 'OPI_DBI_UOM_ERR_REPORTING_ERR'));

END err_msg_missing_uoms;


/*----------------------------------------
| Procedure to print error message header |
| for specific types of cases.            |
|                                         |
|    Parameters:                          |
|    1. p_measure_code:                   |
|        WT = Weight                      |
|        VOL = Volume                     |
|        DIST = Distance                  |
|    2. p_entity_type:                    |
|        ITEM = item conversions          |
|        LOC = locator conversions        |
|________________________________________*/

PROCEDURE err_msg_header_spec (p_measure_code IN VARCHAR2,
                               p_entity_type IN VARCHAR2)
IS

    l_label1    varchar2(30);
    l_label2    varchar2(30);
    l_label3    varchar2(30);
    l_label4    varchar2(30);

BEGIN

    CASE
    WHEN (p_measure_code = 'WT' AND p_entity_type = 'ITEM') THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
            fnd_message.get_string('OPI', 'OPI_DBI_MISSING_ITEM_WT_UOM'));
    WHEN (p_measure_code = 'VOL' AND p_entity_type = 'ITEM') THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
            fnd_message.get_string('OPI', 'OPI_DBI_MISSING_ITEM_VOL_UOM'));
    WHEN (p_measure_code = 'WT' AND p_entity_type = 'LOC') THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
            fnd_message.get_string('OPI', 'OPI_DBI_MISSING_LOC_WT_UOM'));
    WHEN (p_measure_code = 'VOL' AND p_entity_type = 'LOC') THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
            fnd_message.get_string('OPI', 'OPI_DBI_MISSING_LOC_VOL_UOM'));
    ELSE
        -- Default to the basic message
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                          fnd_message.get_string('OPI',
                                                 'OPI_DBI_MISSING_UOM'));
    END CASE;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, NEWLINE);

    l_label1 := fnd_message.get_string('OPI', 'OPI_DBI_COL_FROM_UOM');
    l_label2 := fnd_message.get_string('OPI', 'OPI_DBI_COL_FROM_UOM_CLASS');
    l_label3 := fnd_message.get_string('OPI', 'OPI_DBI_COL_TO_UOM');
    l_label4 := fnd_message.get_string('OPI', 'OPI_DBI_COL_TO_UOM_CLASS');

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       rpad(l_label1, COL_WIDTH) ||
                       rpad(l_label2, COL_WIDTH) ||
                       rpad(l_label3, COL_WIDTH) ||
                       rpad(l_label4, COL_WIDTH) );

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) ||
                       rpad(LINE, COL_WIDTH) );

END err_msg_header_spec;



END opi_dbi_rep_uom_pkg;

/
