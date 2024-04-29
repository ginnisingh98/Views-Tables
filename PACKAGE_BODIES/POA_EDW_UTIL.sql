--------------------------------------------------------
--  DDL for Package Body POA_EDW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_UTIL" AS
  /* $Header: poautilb.pls 120.0 2005/06/01 16:27:46 appldev noship $ */

-- ========================================================================
--  convert_uom
--
--  Cloned from inv_convert.inv_um_conversion
-- ========================================================================
PROCEDURE convert_uom (
      		from_uom_code         	VARCHAR2,
      		to_uom_code           	VARCHAR2,
      		item_id           	NUMBER,
      		uom_rate    	OUT NOCOPY 	NUMBER)
IS

    /*
    ** declare variables that are referenced in the cursor definitions
    */

    from_class              varchar2(10);
    to_class                varchar2(10);


    cursor standard_conversions is
        select  t.conversion_rate      std_to_rate,
                t.uom_class            std_to_class,
                f.conversion_rate      std_from_rate,
                f.uom_class            std_from_class
        from  mtl_uom_conversions t,
              mtl_uom_conversions f
        where t.inventory_item_id in (item_id, 0)
        and   t.uom_code = to_uom_code
        and   nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        and   f.inventory_item_id in (item_id, 0)
        and   f.uom_code = from_uom_code
        and   nvl(f.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        order by t.inventory_item_id desc,
                 f.inventory_item_id desc;

    std_rec standard_conversions%rowtype;


    cursor interclass_conversions is
        select decode(to_uom_class, to_class, 1, 2) to_flag,
               decode(from_uom_class, from_class, 1, to_class, 2, 0) from_flag,
               conversion_rate rate
        from   mtl_uom_class_conversions
        where  inventory_item_id = item_id
        and    to_uom_class in (from_class, to_class)
        and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate);

    class_rec interclass_conversions%rowtype;


    invalid_conversion      exception;

    type conv_tab is table of number
         index by binary_integer;

    type class_tab is table of varchar2(10)
         index by binary_integer;

    interclass_rate_tab     conv_tab;
    from_class_flag_tab     conv_tab;
    to_class_flag_tab       conv_tab;
    from_rate_tab           conv_tab;
    to_rate_tab             conv_tab;
    from_class_tab          class_tab;
    to_class_tab            class_tab;

    std_index               number;
    class_index             number;

    from_rate               number := 1;
    to_rate                 number := 1;
    interclass_rate         number := 1;
    to_class_rate           number := 1;
    from_class_rate         number := 1;
    msgbuf                  varchar2(200);

BEGIN

    /*
    ** Conversion between between two UOMS.
    **
    ** 1. The conversion always starts from the conversion defined, if exists,
    **    for an specified item.
    ** 2. If the conversion id not defined for that specific item, then the
    **    standard conversion, which is defined for all items, is used.
    ** 3. When the conversion involves two different classes, then
    **    interclass conversion is activated.
    */


    /*
    ** If from and to units are the same, conversion rate is 1.
    ** Go immediately to the end of the procedure to exit.
    */

    if (from_uom_code = to_uom_code) then

	uom_rate := 1;
	goto  procedure_end;

    end if;

    /*
    ** Get item specific or standard conversions
    */

    open standard_conversions;

    std_index := 0;

    loop

        fetch standard_conversions into std_rec;
        exit when standard_conversions%notfound;

        std_index := std_index + 1;

        from_rate_tab(std_index) := std_rec.std_from_rate;
        from_class_tab(std_index) := std_rec.std_from_class;
        to_rate_tab(std_index) := std_rec.std_to_rate;
        to_class_tab(std_index) := std_rec.std_to_class;

    end loop;

    close standard_conversions;

    /*
    **
    */

    if (std_index = 0) then

        /*
        ** No conversions defined
        */

        msgbuf := msgbuf||'Invalid standard conversion : ';
        msgbuf := msgbuf||'From UOM code: '||from_uom_code||' ';
        msgbuf := msgbuf||'To UOM code: '||to_uom_code||' ';
        raise invalid_conversion;

    else

        /*
        ** Conversions are ordered. Item specific conversions will be
        ** returned first.
        */

        from_class := from_class_tab(1);
        to_class := to_class_tab(1);
        from_rate := from_rate_tab(1);
        to_rate := to_rate_tab(1);

    end if;

    if (from_class <> to_class) then

        /*
        ** Load interclass conversion tables
        ** If two rows are returned, it implies that there is no direct
        ** conversion between them.
        ** If one row is returned, then it may imply that there is a direct
        ** conversion between them or one class is not defined in the
        ** class conversion table.
        */

        class_index := 0;

        open interclass_conversions;

        loop

            fetch interclass_conversions into class_rec;
            exit when interclass_conversions%notfound;

            class_index := class_index + 1;

            to_class_flag_tab(class_index) := class_rec.to_flag;
            from_class_flag_tab(class_index) := class_rec.from_flag;
            interclass_rate_tab(class_index) := class_rec.rate;

        end loop;

        close interclass_conversions;

        if (class_index = 2) then

            if (to_class_flag_tab(1) = 1) then

                to_class_rate := interclass_rate_tab(1);
                from_class_rate := interclass_rate_tab(2);

            else

                to_class_rate := interclass_rate_tab(2);
                from_class_rate := interclass_rate_tab(1);

            end if;

        elsif ((class_index = 1) and
                 (to_class_flag_tab(1) = from_class_flag_tab(1) )) then

            if (to_class_flag_tab(1) = 1) then

                to_class_rate := interclass_rate_tab(1);
                from_class_rate := 1;

            else

                to_class_rate := 1;
                from_class_rate := interclass_rate_tab(1);

            end if;

            interclass_rate := from_class_rate/to_class_rate;

        else

            /*
            ** No interclass conversion is defined
            */

            msgbuf := msgbuf||'Invalid Interclass conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_uom_code||' ';
            msgbuf := msgbuf||'To UOM code: '||to_uom_code||' ';
            raise invalid_conversion;

        end if;

    end if;

    /*
    ** conversion rates are defaulted to '1' at the start of the procedure
    ** so seperate calculations are not required for standard/interclass
    ** conversions
    */

    uom_rate := (from_rate * interclass_rate) / to_rate;

    /*
    ** Put a label and a null statement over here so that you can
    ** the goto statements can branch here.
    */

    <<procedure_end>>

    null;

exception
    when others then
         uom_rate := -99999;

END convert_uom;


-- ========================================================================
--  get_uom_rate
--
--  Cloned from inv_convert.inv_um_convert
-- ========================================================================
FUNCTION get_uom_rate(
      		item_id           	NUMBER,
      		precision		NUMBER,
      		from_quantity     	NUMBER,
      		from_uom_code         	VARCHAR2,
      		to_uom_code           	VARCHAR2,
      		from_uom_name		VARCHAR2,
      		to_uom_name		VARCHAR2)
    RETURN NUMBER
IS

	/*
	** declare variables that are passed to inv_uom_conversion
	*/

	uom_rate	number;
	msgbuf          varchar2(200);
	from_qty_num    number;
	fm_unt		varchar2(3);
	to_unt		varchar2(3);
	eff_precision	number;

BEGIN

	/* Call the inv_uom_conversion procedure to calculate the uom_rate
	** and return. If from_quantity is not null, the function
	** assumes that to_quantity is the desired result, and this is
	** what is returned. Precision is defaulted to 2 decimals, unless
	** a different value is provided by caller of function.
	** This function previously calculated the conversion rate in the
 	** body of the function itself. This was replaced by the present
	** procedure call because of a PL/SQL bug which caused memory leaks
	** while using tables in functions. Refer to bug 191321 for details.
	*/

	if ( from_uom_code IS NULL and to_uom_code IS NULL ) then
          SELECT uom_code
	  INTO   fm_unt
	  FROM   mtl_units_of_measure
          WHERE  unit_of_measure = from_uom_name;

	  SELECT uom_code
	  INTO   to_unt
	  FROM   mtl_units_of_measure
          WHERE  unit_of_measure = to_uom_name;
        else
          fm_unt := from_uom_code;
	  to_unt := to_uom_code;
	end if;

	convert_uom(fm_unt, to_unt, item_id, uom_rate);

        if ( uom_rate = -99999 ) then
          return(-99999);
	end if;

	if ( from_quantity IS NOT NULL ) then
	  uom_rate := from_quantity * uom_rate;
	end if;

	/*
	** Default precision for inventory is 6 decimals
	*/
        if (precision IS NULL) then
          eff_precision := 6 ;
	else
	  eff_precision := precision ;
        end if;

	uom_rate := round(uom_rate, eff_precision);

	RETURN uom_rate;

EXCEPTION
    when others then
       return (-99999);

END get_uom_rate;

END poa_edw_util;

/
