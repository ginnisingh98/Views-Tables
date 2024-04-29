--------------------------------------------------------
--  DDL for Package Body INV_CONVERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONVERT" AS
/* $Header: INVUMCNB.pls 120.2.12010000.7 2010/04/01 06:11:07 ksaripal ship $ */
   -- Bug #  3144743
   -- Put away Performance  Issue

      g_u_uom_rate          number;
      g_u_from_unit         varchar2(10);
      g_u_to_unit           varchar2(10);
      g_u_item_id           varchar2(10);

      g_v_uom_rate          number;
      g_v_from_unit         varchar2(10);
      g_v_to_unit           varchar2(10);
      g_v_item_id           varchar2(10);

      g_w_uom_rate          number;
      g_w_from_unit         varchar2(10);
      g_w_to_unit           varchar2(10);
      g_w_item_id           varchar2(10);

      g_pkg_name CONSTANT VARCHAR2(30) := 'INV_CONVERT';
      g_pkg_version CONSTANT VARCHAR2(100) := '$Header: INVUMCNB.pls 120.2.12010000.7 2010/04/01 06:11:07 ksaripal ship $';

   PROCEDURE inv_um_conversion (
      from_unit         varchar2,
      to_unit           varchar2,
      item_id           number,
      uom_rate    out nocopy	number )
    IS

BEGIN

    inv_um_conversion (
                     from_unit,
                     to_unit,
                     item_id,
                     NULL,
                     NULL,
                     uom_rate);


END inv_um_conversion;


   PROCEDURE inv_um_conversion (
      from_unit         varchar2,
      to_unit           varchar2,
      item_id           number,
      lot_number        varchar2,
      organization_id   number,
      uom_rate    out nocopy 	number )
    IS

	/*
	** declare variables that are referenced in the cursor definitions
	*/

    from_class              varchar2(10);
    to_class                varchar2(10);

   /*===============================================
      Joe DiIorio 09/2004 INVCONV
      Added variable to use lot_number in cursor
      lot_interclass_conversions.
     ===============================================*/
    p_lot_number           MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
    p_organization_id      NUMBER;

    -- Bug 2899727. Since there is no join between t and f,
    -- leads to a cartesian product.
    -- So, splitting the cursor into two different sqls.

    /***
    cursor standard_conversions is
        select  t.conversion_rate      std_to_rate,
                t.uom_class            std_to_class,
                f.conversion_rate      std_from_rate,
                f.uom_class            std_from_class
        from  mtl_uom_conversions t,
              mtl_uom_conversions f
        where t.inventory_item_id in (item_id, 0)
        and   t.uom_code = to_unit
        and   nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        and   f.inventory_item_id in (item_id, 0)
        and   f.uom_code = from_unit
        and   nvl(f.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        order by t.inventory_item_id desc,
                 f.inventory_item_id desc;

      std_rec standard_conversions%rowtype;

      *****/

      cursor from_standard_conversions is
	 select  conversion_rate      std_from_rate,
	         uom_class            std_from_class
	   from  mtl_uom_conversions
	   where inventory_item_id in (item_id, 0)
	   and   uom_code = from_unit
	   and   nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate)
	   order by inventory_item_id desc;

    from_std_rec from_standard_conversions%rowtype;

    cursor to_standard_conversions is
       select  conversion_rate      std_to_rate,
	       uom_class            std_to_class
	 from  mtl_uom_conversions
	 where inventory_item_id in (item_id, 0)
	 and   uom_code = to_unit
	 and   nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate)
	 order by inventory_item_id desc;

    to_std_rec to_standard_conversions%rowtype;


    cursor interclass_conversions is
        select decode(to_uom_class, to_class, 1, 2) to_flag,
               decode(from_uom_class, from_class, 1, to_class, 2, 0) from_flag,
               conversion_rate rate
        from   mtl_uom_class_conversions
        where  inventory_item_id = item_id
        and    to_uom_class in (from_class, to_class)
        and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate);

    class_rec interclass_conversions%rowtype;


   /*===============================================
      Joe DiIorio 09/2004 INVCONV
      Cursor added for lot specific interclass./
     ===============================================*/

    /* Fix for #7434784. Lot conversion should look into lot_conversion table and
       also standard interclass conversion.

       e.g. User will define conversion between primary and secondary UOM for a specfic lot
       However conversion between transaction uom and primary/secondary uom will exists only in
       interclass conversion table.
    */


    cursor lot_interclass_conversions is
        select decode(to_uom_class, to_class, 1, 2) to_flag,
               decode(from_uom_class, from_class, 1, to_class, 2, 0) from_flag,
               conversion_rate rate
        from  (
               select from_uom_class, to_uom_class , conversion_rate
               from   mtl_lot_uom_class_conversions
               where  inventory_item_id = item_id
               and    organization_id = p_organization_id
               and    lot_number = p_lot_number
               and    to_uom_class in (from_class, to_class)
               and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate)
               union all
               (
               select from_uom_class, to_uom_class , conversion_rate
               from   mtl_uom_class_conversions mucc
               where  inventory_item_id = item_id
               and    to_uom_class in (from_class, to_class)
               and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate)
               and    not exists  (
                      select 1
                      from   mtl_lot_uom_class_conversions mluc
                      where  inventory_item_id = item_id
                      and    organization_id = p_organization_id
                      and    lot_number = p_lot_number
                      and    to_uom_class in (from_class, to_class)
                      and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate)
                      and    mluc.from_uom_class = mucc.from_uom_class
                      and    mluc.to_uom_class = mucc.to_uom_class
                      )
                )
               ) ;
   /*===============================================
      Added record type for the above  cursor.
     ===============================================*/
    lot_class_rec      lot_interclass_conversions%rowtype;

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

begin

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


    if (from_unit = to_unit) then

	uom_rate := 1;
	goto  procedure_end;

    end if;

    /*=======================================
      Joe DiIorio 09/2004 INVCONV
      Copy input variables.
      =====================================*/
    p_lot_number := lot_number;
    p_organization_id := organization_id;

    /*
    ** Get item specific or standard conversions
    */

    open from_standard_conversions;

    std_index := 0;

    loop

        fetch from_standard_conversions into from_std_rec;
        exit when from_standard_conversions%notfound;

        std_index := std_index + 1;

        from_rate_tab(std_index) := from_std_rec.std_from_rate;
        from_class_tab(std_index) := from_std_rec.std_from_class;

    end loop;

    close from_standard_conversions;

     if (std_index = 0) then

        /*
        ** No conversions defined
        */

            msgbuf := msgbuf||'Invalid standard conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
            raise invalid_conversion;

    else

        /*
        ** Conversions are ordered. Item specific conversions will be
        ** returned first.
        */

        from_class := from_class_tab(1);
        from_rate := from_rate_tab(1);

    end if;

    open to_standard_conversions;

    std_index := 0;

    loop

        fetch to_standard_conversions into to_std_rec;
        exit when to_standard_conversions%notfound;

        std_index := std_index + 1;

        to_rate_tab(std_index) := to_std_rec.std_to_rate;
        to_class_tab(std_index) := to_std_rec.std_to_class;

    end loop;

    close to_standard_conversions;

    if (std_index = 0) then

        /*
        ** No conversions defined
        */

            msgbuf := msgbuf||'Invalid standard conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
            raise invalid_conversion;

    else

        /*
        ** Conversions are ordered. Item specific conversions will be
        ** returned first.
        */

        to_class := to_class_tab(1);
        to_rate := to_rate_tab(1);

    end if;

    /******

    -- BUG 2899727. Commenting this portion of the code. The check is
    -- being done after both the cursons above.

    --if (std_index = 0) then

    --    /*
    --    ** No conversions defined
    --    */

    --       msgbuf := msgbuf||'Invalid standard conversion : ';
    --       msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
    --       msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
    --       raise invalid_conversion;

    --else

    --   /*
    --   ** Conversions are ordered. Item specific conversions will be
    --  ** returned first.
    --   */

    --   from_class := from_class_tab(1);
    --  to_class := to_class_tab(1);
    --   from_rate := from_rate_tab(1);
    --   to_rate := to_rate_tab(1);

    -- end if;
    -- End bug 2899727.

    if (from_class <> to_class) then
      -- Bug 5447516 If item_id is 0 raise an error as intercalss conversions can be
      -- defined only at item level.
      if item_id = 0 then
        raise invalid_conversion;
      end if;
        class_index := 0;

        /*=======================================
           Joe DiIorio 09/2004 INVCONV
           If there is a lot number try and get
           the lot specific conversion first.
          =====================================*/

        IF (lot_number is NOT NULL AND organization_id IS NOT NULL) THEN
            open lot_interclass_conversions;
            LOOP
              FETCH lot_interclass_conversions INTO lot_class_rec;
              EXIT WHEN lot_interclass_conversions%NOTFOUND;
              class_index := class_index + 1;
              to_class_flag_tab(class_index) := lot_class_rec.to_flag;
              from_class_flag_tab(class_index) := lot_class_rec.from_flag;
              interclass_rate_tab(class_index) := lot_class_rec.rate;
            END LOOP;
            close lot_interclass_conversions;

        END IF;


        /*
        ** Load interclass conversion tables
        ** If two rows are returned, it implies that there is no direct
        ** conversion between them.
        ** If one row is returned, then it may imply that there is a direct
        ** conversion between them or one class is not defined in the
        ** class conversion table.
        */

        /*  check interclass first      */

        IF (class_index = 0) THEN
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

        END IF;



        if (class_index = 2) then

            if (to_class_flag_tab(1) = 1) then

                to_class_rate := interclass_rate_tab(1);
                from_class_rate := interclass_rate_tab(2);

            else

                to_class_rate := interclass_rate_tab(2);
                from_class_rate := interclass_rate_tab(1);

            end if;

--Bug 2907403
            interclass_rate := from_class_rate/to_class_rate;

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
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
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
  --     raise_application_error(-20001, sqlerrm||'---'||msgbuf);
         uom_rate := -99999;
END inv_um_conversion;


    FUNCTION  inv_um_convert (
      item_id           	number,
      precision			number,
      from_quantity     	number,
      from_unit         	varchar2,
      to_unit           	varchar2,
      from_name			varchar2,
      to_name			varchar2) RETURN number IS


uom_rate                        NUMBER;
BEGIN
    uom_rate := inv_um_convert (
                     item_id,
                     NULL,
                     NULL,
                     precision,
                     from_quantity,
                     from_unit,
                     to_unit,
                     from_name,
                     to_name);

    RETURN uom_rate;

EXCEPTION

    when others then
       return (-99999);
END inv_um_convert;


   /*=======================================
      Joe DiIorio 09/2004 INVCONV
      Created overloaded version to accept
      lot number.
     =====================================*/

    FUNCTION  inv_um_convert (
      item_id           	number,
      lot_number        	varchar2,
      organization_id          	number,
      precision			number,
      from_quantity     	number,
      from_unit         	varchar2,
      to_unit           	varchar2,
      from_name			varchar2,
      to_name			varchar2) RETURN number IS


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

	if ( from_unit IS NULL and to_unit IS NULL ) then
          SELECT uom_code INTO fm_unt FROM mtl_units_of_measure
          WHERE  unit_of_measure = from_name;

	  SELECT uom_code INTO to_unt FROM mtl_units_of_measure
          WHERE  unit_of_measure = to_name;
        else
          fm_unt := from_unit;
	  to_unt := to_unit;
	end if;

      /*=====================================
         Joe DiIorio 09/2004 INVCONV
         Added lot_number to parameter list.
        =====================================*/

	inv_um_conversion(fm_unt, to_unt, item_id, lot_number, organization_id, uom_rate);
        if ( uom_rate = -99999 ) then
          return(-99999);
	end if;
	if ( from_quantity IS NOT NULL ) then
	  uom_rate := from_quantity * uom_rate;
	end if;


	/** Default precision for inventory was 6 decimals
	  Changed the default precision to 5 since INV supports a standard
	  precision of 5 decimal places.
	*/
        if (precision IS NULL) then
          eff_precision := 5 ;
	else
	  eff_precision := precision ;
        end if;
	uom_rate := round(uom_rate, eff_precision);

	RETURN uom_rate;

EXCEPTION

    when others then
  --     raise_application_error(-20001, sqlerrm||'---'||msgbuf);
       return (-99999);
END inv_um_convert;


  FUNCTION  inv_um_convert_new (
      item_id           	number,
      precision			number,
      from_quantity     	number,
      from_unit         	varchar2,
      to_unit           	varchar2,
      from_name			varchar2,
      to_name			varchar2,
      capacity_type             varchar2) RETURN number IS

uom_rate                        NUMBER;

BEGIN
    uom_rate := inv_um_convert_new (
                     item_id,
                     NULL,
                     NULL,
                     precision,
                     from_quantity,
                     from_unit,
                     to_unit,
                     from_name,
                     to_name,
                     capacity_type);

    RETURN uom_rate;

EXCEPTION

    when others then
  --     raise_application_error(-20001, sqlerrm||'---'||msgbuf);
       return (-99999);
END inv_um_convert_new;


  FUNCTION  inv_um_convert_new (
      item_id           	number,
      lot_number        	varchar2,
      organization_id         	number,
      precision			number,
      from_quantity     	number,
      from_unit         	varchar2,
      to_unit           	varchar2,
      from_name			varchar2,
      to_name			varchar2,
      capacity_type             varchar2) RETURN number IS


	/*
	** declare variables that are passed to inv_uom_conversion
	*/

	uom_rate	number;
	msgbuf          varchar2(200);
	from_qty_num    number;
	fm_unt		varchar2(3);
	to_unt		varchar2(3);
	eff_precision	number;
        l_capacity      VARCHAR2(1); -- 'W' , 'V' ,'U'

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

	if ( from_unit IS NULL and to_unit IS NULL ) then
          SELECT uom_code INTO fm_unt FROM mtl_units_of_measure
          WHERE  unit_of_measure = from_name;

	  SELECT uom_code INTO to_unt FROM mtl_units_of_measure
          WHERE  unit_of_measure = to_name;
        else
          fm_unt := from_unit;
	  to_unt := to_unit;
	end if;

         -- bug 3144743
         -- cache the following values from_uom, to_uom and the uom_rate
         -- for better performance
         l_capacity := capacity_type;

         if l_capacity = 'U' then
            if     (nvl(g_u_from_unit, 'XYZ')  = fm_unt )
               and (nvl(g_u_to_unit, 'XYZ')   = to_unit)
               and (nvl(g_u_item_id ,-99999) = item_id)
               and (nvl(g_u_uom_rate, -99999) <> -99999)  then

               uom_rate := g_u_uom_rate;
             else
	       inv_um_conversion(fm_unt, to_unt, item_id, lot_number, organization_id, uom_rate);
	       g_u_from_unit  := fm_unt;
	       g_u_to_unit    := to_unit;
               g_u_uom_rate   := uom_rate;
               g_u_item_id := item_id;
	     end if;
        elsif  l_capacity = 'V' then
            if     (nvl(g_v_from_unit, 'XYZ')  = fm_unt )
               and (nvl(g_v_to_unit, 'XYZ')   = to_unit)
               and (nvl(g_v_item_id ,-99999) = item_id)
               and (nvl(g_v_uom_rate, -99999) <> -99999)  then

               uom_rate := g_v_uom_rate;
             else
               inv_um_conversion(fm_unt, to_unt, item_id, lot_number, organization_id, uom_rate);
               g_v_from_unit  := fm_unt;
               g_v_to_unit    := to_unit;
               g_v_uom_rate   := uom_rate;
               g_v_item_id := item_id;
             end if;
        elsif  l_capacity = 'W' then
            if     (nvl(g_w_from_unit, 'XYZ')  = fm_unt )
               and (nvl(g_w_to_unit, 'XYZ')   = to_unit)
               and (nvl(g_w_item_id ,-99999) = item_id)
               and (nvl(g_w_uom_rate, -99999) <> -99999)  then

               uom_rate := g_w_uom_rate;
             else
               inv_um_conversion(fm_unt, to_unt, item_id, lot_number, organization_id, uom_rate);
               g_w_from_unit  := fm_unt;
               g_w_to_unit    := to_unit;
               g_w_uom_rate   := uom_rate;
               g_w_item_id    := item_id;
             end if;
        end if;

        if ( uom_rate = -99999 ) then
          return(-99999);
	end if;
	if ( from_quantity IS NOT NULL ) then
	  uom_rate := from_quantity * uom_rate;
	end if;


	/** Default precision for inventory was 6 decimals
	  Changed the default precision to 5 since INV supports a standard
	  precision of 5 decimal places.
	*/
        if (precision IS NULL) then
          eff_precision := 5 ;
	else
	  eff_precision := precision ;
        end if;
	uom_rate := round(uom_rate, eff_precision);

	RETURN uom_rate;

EXCEPTION

    when others then
  --     raise_application_error(-20001, sqlerrm||'---'||msgbuf);
       return (-99999);
END inv_um_convert_new;


FUNCTION validate_item_uom (p_uom_code IN VARCHAR2,
			    p_item_id  IN NUMBER,
			    p_organization_id IN NUMBER)
  return BOOLEAN IS


     l_primary_uom_code varchar(3) := null;
     l_allowed_units     number := null;

     l_uom_code         varchar2(3) := null;
     l_uom_class        varchar2(10) := null;

     Cursor c_msi is
	select PRIMARY_UOM_CODE, ALLOWED_UNITS_LOOKUP_CODE
	  from mtl_system_items msi,
	  MTL_UNITS_OF_MEASURE MTLUOM2
	  where msi.ORGANIZATION_ID = p_organization_id AND
	  msi.INVENTORY_ITEM_ID = p_item_id  AND
	  MTLUOM2.uom_code = msi.PRIMARY_UOM_CODE AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE);


     cursor c_std_cvr_sameClass is
	select MTLUOM2.uom_code, MTLUCV.uom_class
	  from  MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLUCV.inventory_item_id=0 AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  MTLUCV.uom_class = (select MTLPRI1.uom_class
			      from MTL_UNITS_OF_MEASURE MTLPRI1
			      where MTLPRI1.uom_code = l_primary_uom_code AND
			      NVL(MTLPRI1.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
			      );

     cursor c_item_cvr_sameClass is
	select MTLUOM2.uom_code, MTLUCV.uom_class
	  from  MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLUCV.inventory_item_id = p_item_id AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE);


     cursor c_complex is

	select MTLUOM2.uom_code, MTLUOM2.uom_class
	  from   MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  l_allowed_units in (1,3) AND MTLUCV.inventory_item_id = p_item_id
	  UNION ALL
	  select MTLUOM2.uom_code, MTLUOM2.uom_class
	  from   MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  l_allowed_units in (1,3) AND MTLUCV.inventory_item_id=0 AND
	  MTLUCV.uom_class = (select MTLPRI1.uom_class
			      from MTL_UNITS_OF_MEASURE MTLPRI1
			      where MTLPRI1.uom_code = l_primary_uom_code
			      )
	  UNION ALL
	  select MTLUOM2.uom_code, MTLUOM2.uom_class
	  from   MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  l_allowed_units in (1,3) AND MTLUCV.inventory_item_id=0 AND
	  exists(
		 select 'UOM_CLASS conversion exists for the class of UOM supplied'
		 from MTL_UOM_CLASS_CONVERSIONS MTLUCC1
		 where
		 MTLUCC1.to_uom_class = MTLUCV.uom_class AND
		 MTLUCC1.inventory_item_id = p_item_id AND
		 NVL(MTLUCC1.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
		 )
	  UNION ALL
	  select MTLUOM2.uom_code, MTLUOM2.uom_class
	  from   MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  l_allowed_units in (2,3) AND MTLUCV.inventory_item_id=0 AND
	  exists(
		 select 'UOM_CLASS conversion exists for the class of UOM supplied'
		 from MTL_UOM_CLASS_CONVERSIONS MTLUCC
		 where
		 MTLUCC.to_uom_class = MTLUCV.uom_class AND
		 MTLUCC.INVENTORY_ITEM_ID = p_item_id  AND
              NVL(MTLUCC.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
		 )
	  UNION ALL
	  select MTLUOM2.uom_code, MTLUOM2.uom_class
	  from   MTL_UNITS_OF_MEASURE MTLUOM2,
	  MTL_UOM_CONVERSIONS  MTLUCV,
	  MTL_UOM_CLASSES      MTLCLS
	  where
	  MTLUOM2.uom_code = p_uom_code  AND
	  MTLUCV.uom_code  = MTLUOM2.uom_code AND
	  MTLCLS.uom_class = MTLUOM2.uom_class AND
	  NVL(MTLCLS.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUOM2.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  NVL(MTLUCV.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) AND
	  l_allowed_units in (2,3) AND MTLUCV.inventory_item_id=0 AND
	  MTLUCV.uom_class = (select MTLPRI.uom_class
			      from MTL_UNITS_OF_MEASURE MTLPRI
			      where MTLPRI.uom_code = l_primary_uom_code
			      );



BEGIN

   IF (p_uom_code IS NULL
       OR p_item_id IS NULL
       OR p_organization_id IS NULL) THEN

      return(FALSE);
   END IF;

   /* To improve performance, we will check for the most common cases first:
   - The UOM_CODE supplied is the same as the PRIMARY_UOM_CODE of the item.
     - The UOM_CODE supplied is in the same UOM_CLASS as the PRIMARY_UOM_CODE
     and there is a conversion entry for it.
     Then, if we still dont get a hit, we will test for the more complex cases,
     like interclass conversions.

     Get the primary_uom_code for the item. Also, get the allowed conversions
     (standard, item only, or both) in case, we need it later.
     */
     open c_msi;
   fetch c_msi into l_primary_uom_code, l_allowed_units;

   IF c_msi%ISOPEN THEN
      close c_msi;
   END IF;

   /* If the uom_code supplied is same as item primary_uom_code then
      uom_code is valid. Return success.
   */
     IF p_uom_code = l_primary_uom_code THEN

	return(TRUE);
     END IF;

  /* If only standard conversion is allowed, then check for UOM_CODE in
     the same UOM_CLASS as the PRIMARY_UOM_CODE as the item
  */
  open c_std_cvr_sameClass;
  fetch c_std_cvr_sameClass into l_uom_code, l_uom_class;
  IF c_std_cvr_sameClass%FOUND THEN

     IF c_std_cvr_sameClass%ISOPEN THEN
        close c_std_cvr_sameClass;
     END IF;
     return(TRUE);
  END IF;

  /* If only item conversion is allowed, then check for UOM_CODE in
     the same UOM_CLASS as the PRIMARY_UOM_CODE as the item
  */
  open c_item_cvr_sameClass;
  fetch c_item_cvr_sameClass into l_uom_code, l_uom_class;
  IF c_item_cvr_sameClass%FOUND THEN

     IF c_item_cvr_sameClass%ISOPEN THEN
        close c_item_cvr_sameClass;
     END IF;

     return(TRUE);
  END IF;

  /* If UOM_CODE supplied is not in same class as item PRIMARY_UOM_CODE,
     then check more complex case i.e. inter-class.
     This sql takes care of all cases.
  */
  open c_complex;
  fetch c_complex into l_uom_code, l_uom_class;
  IF c_complex%FOUND THEN

     IF c_complex%ISOPEN THEN
        close c_complex;
     END IF;

     return(TRUE);
  END IF;

  /* If we are here, then we did not find a match for the UOM_CODE supplied.
     Therefore, UOM_CODE is not valid. return failure.
  */
  return (FALSE);

EXCEPTION

WHEN OTHERS THEN
 IF c_msi%ISOPEN THEN
    close c_msi;
  END IF;

 IF c_item_cvr_sameClass%ISOPEN THEN
    close c_item_cvr_sameClass;
 END IF;

 IF c_complex%ISOPEN THEN
    close c_complex;
 END IF;

 IF c_std_cvr_sameClass%ISOPEN THEN
    close c_std_cvr_sameClass;
 END IF;

 RAISE;

END validate_item_uom;



PROCEDURE print_debug( p_message VARCHAR2, p_procname VARCHAR2 := NULL, p_level NUMBER := 9) IS
BEGIN
  --dbms_output.put_line(p_message);
  inv_log_util.trace(
    p_message => p_message
  , p_module  => g_pkg_name||'.'||p_procname
  , p_level   => p_level);
END print_debug;

PROCEDURE pick_uom_convert(
      p_org_id                  NUMBER,
      p_item_id                 NUMBER,
      p_sub_code                VARCHAR2,
      p_loc_id                  NUMBER,
      p_alloc_uom               VARCHAR2,
      p_alloc_qty               NUMBER,
      x_pick_uom       OUT NOCOPY     VARCHAR2,
      x_pick_qty       OUT NOCOPY     NUMBER,
      x_uom_string     OUT NOCOPY     VARCHAR2,
      x_return_status  OUT NOCOPY     VARCHAR2,
      x_msg_data       OUT NOCOPY     VARCHAR2,
      x_msg_count      OUT NOCOPY     NUMBER) IS

      l_loc_uom VARCHAR2(3):= null;
      l_uom_string VARCHAR2(20) := null;
      l_api_name    CONSTANT VARCHAR2(30) := 'PICK_UOM_CONVERT';
      l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  begin

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;


    IF ( l_debug = 1 ) THEN
      print_debug(l_api_name || ' Entered ' || g_pkg_version, 1);
      print_debug('p_org_id   => '|| p_org_id||' p_item_id=>'||p_item_id||' p_sub_code=>'||p_sub_code||' p_loc_id=>'||p_loc_id ,4);
      print_debug('p_alloc_uom => '||p_alloc_uom||' p_alloc_qty=>'||p_alloc_qty , 4);
    END IF;

    if (p_loc_id IS NOT NULL) THEN
       begin
           SELECT pick_uom_code, inv_ui_item_lovs.get_conversion_rate(pick_uom_code, p_org_Id, p_item_Id)
           INTO   l_loc_uom, l_uom_string
           FROM   mtl_item_locations
           WHERE  organization_id = p_org_id
           AND    subinventory_code = p_sub_code
           AND    inventory_location_id = p_loc_id;
       exception
           WHEN OTHERS THEN
             IF (l_debug = 1) THEN
               print_debug(l_api_name ||' Error In deriving Locator Level Pick UOM', 1);
               IF ( SQLCODE IS NOT NULL ) THEN
                  print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
               END IF;
             END IF;
             x_pick_uom := p_alloc_uom;
             x_pick_qty := p_alloc_qty;
             x_return_status := 'E1'; --error in getting loc pick uom
             return;
       end;
    end if;

    if (l_loc_uom IS NULL) THEN
       begin
           SELECT pick_uom_code, inv_ui_item_lovs.get_conversion_rate(pick_uom_code,
                                   p_org_Id,
                                   p_item_Id)
           INTO   l_loc_uom, l_uom_string
           FROM   MTL_SECONDARY_INVENTORIES
           WHERE  secondary_inventory_name = p_sub_code
           AND    organization_id = p_org_id;
       exception
           WHEN OTHERS THEN
             IF (l_debug = 1) THEN
               print_debug(l_api_name ||' Error In deriving SubInventory Level Pick UOM', 1);
               IF ( SQLCODE IS NOT NULL ) THEN
                  print_debug('SQL error: ' || SQLERRM(SQLCODE), 1);
               END IF;
             END IF;
             x_pick_uom := p_alloc_uom;
             x_pick_qty := p_alloc_qty;
             x_return_status := 'E2'; --error in getting sub pick uom
             return;
       end;
    end if;
    if (l_loc_uom IS NULL) THEN
           x_pick_uom := p_alloc_uom;
           x_pick_qty := p_alloc_qty;
           x_return_status := 'W1'; --no loc level or sub level pick uom defined
           return;
    else
       --call the uom convert routine
           x_pick_qty := inv_um_convert(p_item_id,
                                       null,
                                       p_alloc_qty,
                                       p_alloc_uom,
                                       l_loc_uom,
                                       null,
                                       null);
        --return value of x_out_qty should be integer, if not return the in_qty and in_uom value
           if (trunc(x_pick_qty) = x_pick_qty AND x_pick_qty > 0) THEN
                   x_pick_uom := l_loc_uom;
                   x_uom_string := l_uom_string;
                   x_return_status := 'S'; --success
           else
                   x_pick_uom := p_alloc_uom;
                   x_pick_qty := p_alloc_qty;
                   x_return_status := 'W2'; --could not convert the value in integer
           end if;
           return;
    end if;
 end pick_uom_convert;

-- Functions checks if quantities entered for dual uom
-- items are within deviation range.

FUNCTION within_deviation(p_organization_id IN number,
p_inventory_item_id   IN number,
p_lot_number          IN varchar2,
p_precision           IN number,
p_quantity            IN number,
p_uom_code1           IN varchar2,
p_quantity2           IN number,
p_uom_code2           IN varchar2,
p_unit_of_measure1    IN varchar2,
p_unit_of_measure2    IN varchar2)

RETURN NUMBER IS

DEV_LOW_ERROR         EXCEPTION;
DEV_HIGH_ERROR        EXCEPTION;
INVALID_ITEM          EXCEPTION;
INCORRECT_FIXED_VALUE EXCEPTION;
INVALID_UOM_CONV      EXCEPTION;

l_converted_qty           NUMBER;
l_high_boundary           NUMBER;
l_low_boundary            NUMBER;


/*========================================
   Cursor to retrieve uom code.
  ========================================*/

CURSOR c_get_uom_code (p_unit VARCHAR2) IS
SELECT uom_code
FROM   mtl_units_of_measure
WHERE  unit_of_measure = p_unit;

l_uom_code1          MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
l_uom_code2          MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
x_precision          NUMBER;
l_debug              PLS_INTEGER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_procname           VARCHAR2 (20) := 'within_deviation';
BEGIN

 FND_MSG_PUB.INITIALIZE;

 if (l_debug = 1) then
    print_debug('p_organization_id  : '||p_organization_id  , l_procname);
    print_debug('p_inventory_item_id: '||p_inventory_item_id, l_procname);
    print_debug('p_lot_number       : '||p_lot_number       , l_procname);
    print_debug('p_precision        : '||p_precision        , l_procname);
    print_debug('p_quantity         : '||p_quantity         , l_procname);
    print_debug('p_uom_code1        : '||p_uom_code1        , l_procname);
    print_debug('p_quantity2        : '||p_quantity2        , l_procname);
    print_debug('p_uom_code2        : '||p_uom_code2        , l_procname);
    print_debug('p_unit_of_measure1 : '||p_unit_of_measure1 , l_procname);
    print_debug('p_unit_of_measure2 : '||p_unit_of_measure2 , l_procname);
 end if;


/*=============================================
   Must have a precision value.
  ===========================================*/
x_precision := nvl(p_precision,5);

/*=============================================
  Get Item Info.  Used Cache if available.
  ===========================================*/


IF NOT (INV_CACHE.set_item_rec(p_organization_id, p_inventory_item_id)) THEN
   RAISE INVALID_ITEM;
END IF;

/*=============================================
  Determine if the Deviation Check is Required.
  =============================================*/

IF (INV_CACHE.item_rec.tracking_quantity_ind = 'PS' or
    INV_CACHE.item_rec.ont_pricing_qty_source = 'S') THEN
   /*===================================================
      Get uom codes when units_of_measure are sent in.
     ===================================================*/
   IF (p_unit_of_measure1 IS NOT NULL) THEN
       OPEN c_get_uom_code (p_unit_of_measure1);
       FETCH c_get_uom_code INTO l_uom_code1;
       CLOSE c_get_uom_code;
       OPEN c_get_uom_code (p_unit_of_measure2);
       FETCH c_get_uom_code INTO l_uom_code2;
       CLOSE c_get_uom_code;
   ELSE
       l_uom_code1 := p_uom_code1;
       l_uom_code2 := p_uom_code2;
   END IF;


   /*===============================
        Convert qty 1 to qty2.
     ===============================*/
   l_converted_qty := inv_um_convert(p_inventory_item_id, p_lot_number,
                      p_organization_id, x_precision, p_quantity,
                      l_uom_code1, l_uom_code2, NULL, NULL);
   if (l_debug = 1) then
      print_debug('l_converted_sec_qty     : '||l_converted_qty , l_procname);
   end if;

   IF (l_converted_qty = -99999) THEN
      RAISE INVALID_UOM_CONV;
   END IF;

   if (l_debug = 1) then
      print_debug('secondary_default_ind   : '||INV_CACHE.item_rec.secondary_default_ind , l_procname);
   end if;

   /*====================================
      If the secondary default is fixed
      make sure the quantities match.
     ====================================*/
     --Fixed for bug#7562694
     --Condition for fixed conversion has been modified.
     --Due to rounding to 5 places even for fixed conversion as well
     --there could be deviation of at most 0.00001 qty.
     --if the diff is more than 0.00001 then raise error.

   IF (INV_CACHE.item_rec.secondary_default_ind = 'F' AND
        (abs(l_converted_qty - p_quantity2) >0.00001)     ) THEN
      RAISE INCORRECT_FIXED_VALUE;
   END IF;

   /*=================================
      Compute upper/lower boundaries.
     =================================*/

   if (l_debug = 1) then
      print_debug('dual_uom_deviation_high : '||INV_CACHE.item_rec.dual_uom_deviation_high ||'%', l_procname);
      print_debug('dual_uom_deviation_low  : '||INV_CACHE.item_rec.dual_uom_deviation_low  ||'%', l_procname);
   end if;

   l_high_boundary :=
l_converted_qty * (1 + (INV_CACHE.item_rec.dual_uom_deviation_high/100));
   l_low_boundary  :=
l_converted_qty * (1 - (INV_CACHE.item_rec.dual_uom_deviation_low/100));

   if (l_debug = 1) then
      print_debug('Is '||p_quantity2 ||' between '|| l_low_boundary ||' and '||l_high_boundary ||'?', l_procname);
   end if;

   /*=============================================================
      Check if qty2  is within boundaries allowing for precision.
     =============================================================*/

   IF ((l_low_boundary - p_quantity2) > power(10,-(x_precision-1)) ) THEN
      RAISE DEV_LOW_ERROR;
   END IF;
   IF ((p_quantity2 - l_high_boundary) > power(10,-(x_precision-1)) ) THEN
      RAISE DEV_HIGH_ERROR;
   END IF;

END IF;

RETURN G_TRUE;



EXCEPTION
    WHEN INVALID_ITEM THEN
       FND_MESSAGE.SET_NAME('INV','INV_INVALID_ITEM');
       FND_MSG_PUB.ADD;
       RETURN G_FALSE;
    WHEN INCORRECT_FIXED_VALUE THEN
       FND_MESSAGE.SET_NAME('INV','INV_INCORRECT_FIXED_VALUE');
       FND_MSG_PUB.ADD;
       RETURN G_FALSE;
    WHEN INVALID_UOM_CONV THEN
       FND_MESSAGE.SET_NAME('INV','INV_INVALID_UOM_CONV');
       FND_MESSAGE.SET_TOKEN ('VALUE1',l_uom_code1);
       FND_MESSAGE.SET_TOKEN ('VALUE2',l_uom_code2);
       FND_MSG_PUB.ADD;
       RETURN G_FALSE;
    WHEN DEV_LOW_ERROR THEN
       FND_MESSAGE.SET_NAME('INV','INV_DEVIATION_LO_ERR');
       FND_MSG_PUB.ADD;
       RETURN G_FALSE;
    WHEN DEV_HIGH_ERROR THEN
       FND_MESSAGE.SET_NAME('INV','INV_DEVIATION_HI_ERR');
       FND_MSG_PUB.ADD;
       RETURN G_FALSE;
    WHEN OTHERS THEN
       RETURN G_FALSE;


END within_deviation;

--Added for bug 6761510 for caching of uom conversion
FUNCTION inv_um_convert(p_item_id       IN NUMBER,
                        p_from_uom_code IN VARCHAR2,
                        p_to_uom_code   IN VARCHAR2) RETURN NUMBER
   IS

      l_conversion_rate NUMBER;
      l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_api_name    CONSTANT VARCHAR2(30) := 'inv_um_convert';

   BEGIN
      IF (p_from_uom_code = p_to_uom_code) THEN
         -- No conversion necessary
         l_conversion_rate := 1;
      ELSE
         -- Check if the conversion rate for the item/from UOM/to UOM combination is cached
         IF (g_item_uom_conversion_tb.EXISTS(p_item_id) AND
            g_item_uom_conversion_tb(p_item_id).EXISTS(p_from_uom_code) AND
            g_item_uom_conversion_tb(p_item_id)(p_from_uom_code).EXISTS(p_to_uom_code)) THEN
            -- Conversion rate is cached so just use the value
            l_conversion_rate := g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code);
         ELSE
            -- Conversion rate is not cached so query and store the value
            inv_convert.inv_um_conversion(from_unit => p_from_uom_code,
                                          to_unit   => p_to_uom_code,
                                          item_id   => p_item_id,
                                          uom_rate  => l_conversion_rate);
            IF (l_conversion_rate > 0) THEN
               -- Store the conversion rate and also the reverse conversion.
               -- Do this only if the conversion rate returned is valid, i.e. not negative.
               -- {{
               -- Test having an exception when retrieving the UOM conversion rate. }}
               g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code) := l_conversion_rate;
               g_item_uom_conversion_tb(p_item_id)(p_to_uom_code)(p_from_uom_code) := 1 /l_conversion_rate;
            END IF;
         END IF;
      END IF;

      -- Return the conversion rate retrieved
      RETURN l_conversion_rate;

   EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
         print_debug(l_api_name || 'Exception in inv_um_convert ' || sqlcode || ', ' || sqlerrm, 1);
      END IF;
      -- If an exception occurs, return a negative value.
      -- The calling program should interpret this as an exception in retrieving
      -- the UOM conversion rate.
      RETURN -999;
END inv_um_convert;


--  ==========================================================================
--    PROCEDURE  : create_uom_conversion
--    PARAMETERS : -
--    COMMENT    : Creates the conversion between two uom's using uom_rate
--                  to_uom_code = uom_rate * from_uom_code
--                  x_return_status values
--                      S : Successful conversion creation
--                      W : Conversion exists prior
--                      E : Error in creation conversion
--                      U : Unexpected error occured
--    BUG NUMBER : 9335882
--  ==========================================================================

PROCEDURE create_uom_conversion ( p_from_uom_code VARCHAR2 ,
                                  p_to_uom_code VARCHAR2 ,
                                  p_item_id NUMBER ,
                                  p_uom_rate NUMBER ,
                                  x_return_status    OUT NOCOPY  VARCHAR2
                                ) IS

l_from_class VARCHAR2(10);
l_to_class VARCHAR2(10);
l_from_unit_of_measure VARCHAR2(25);
l_to_unit_of_measure VARCHAR2(25);
l_from_base_uom_flag VARCHAR2(1);
l_to_base_uom_flag VARCHAR2(1);

l_temp_uom VARCHAR2(3);
l_temp_item_id NUMBER;
l_conversion_exists VARCHAR2(1);
l_primary_uom_code VARCHAR2(3);

l_invalid_uom_exc EXCEPTION ;
l_uom_fromto_exc EXCEPTION ;
l_invalid_item_exc EXCEPTION ;
l_conversion_exists_exc EXCEPTION ;
l_ret_conv_exists_warning CONSTANT VARCHAR2(1) := 'W' ;

BEGIN

    IF (p_from_uom_code = NULL) OR (p_to_uom_code = NULL) THEN
        print_debug(' UOM_code is null ' || g_pkg_version, 1);
        RAISE l_invalid_uom_exc ;
    ELSIF p_from_uom_code = p_to_uom_code THEN
        print_debug(' from and to uom codes equal ' || g_pkg_version, 1);
        RAISE l_uom_fromto_exc ;
    END IF ;

    BEGIN
        SELECT unit_of_measure , uom_class , base_uom_flag
        INTO l_from_unit_of_measure , l_from_class , l_from_base_uom_flag
        FROM MTL_UNITS_OF_MEASURE_VL
        WHERE uom_code = p_from_uom_code
        AND nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate);
    EXCEPTION
        WHEN no_data_found THEN
            print_debug(p_from_uom_code || ' doesnot exist ' || g_pkg_version, 1);
            RAISE l_invalid_uom_exc ;
    END ;

    BEGIN
        SELECT unit_of_measure , uom_class , base_uom_flag
        INTO l_to_unit_of_measure ,l_to_class , l_to_base_uom_flag
        FROM MTL_UNITS_OF_MEASURE_VL
        WHERE uom_code = p_to_uom_code
        AND nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate);
    EXCEPTION
        WHEN no_data_found THEN
            print_debug(p_to_uom_code || ' doesnot exist ' || g_pkg_version, 1);
            RAISE l_invalid_uom_exc ;
    END ;


    IF l_from_base_uom_flag <> 'Y' THEN
        print_debug(p_to_uom_code || ' doesnot exist ' || g_pkg_version, 1);
        RAISE l_invalid_uom_exc ;
    END IF;

    IF l_from_class = l_to_class THEN
        IF p_item_id <> 0 THEN
            BEGIN
                SELECT DISTINCT inventory_item_id
                INTO l_temp_item_id
                FROM mtl_system_items_vl
                WHERE inventory_item_id = p_item_id
                AND inventory_item_id IN (SELECT DISTINCT I.inventory_item_id  FROM mtl_system_items_vl I
                                          WHERE I.enabled_flag = 'Y'
                                          AND (SYSDATE BETWEEN NVL(TRUNC(I.start_date_active),SYSDATE )
                                               AND NVL(TRUNC(I.end_date_active),SYSDATE))
                                          AND ( EXISTS (SELECT A.unit_of_measure FROM mtl_units_of_measure A
                                                        WHERE (A.uom_class IN (SELECT to_uom_class FROM mtl_uom_class_conversions B
                                                                             WHERE B.inventory_item_id = I.inventory_item_id)
                                                             OR A.uom_class = (SELECT Z.uom_class FROM mtl_units_of_measure Z
                                                                               WHERE Z.uom_code = I.primary_uom_code))
                                                        AND A.base_uom_flag <> 'Y'
                                                        AND NVL(A.disable_date, SYSDATE+1) > SYSDATE
                                                        AND A.uom_class = NVL(l_to_class, A.uom_class))));
            EXCEPTION
                WHEN No_Data_Found THEN
                  print_debug(p_item_id || ' item not valid for intra class conversion ' || g_pkg_version, 1);
                  RAISE l_invalid_item_exc;
            END ;

            BEGIN
                SELECT DISTINCT x.uom_code
                INTO l_temp_uom
                FROM mtl_units_of_measure x
                WHERE x.uom_code = p_to_uom_code
                AND x.uom_code IN (SELECT DISTINCT a.uom_code FROM mtl_units_of_measure a
                                    WHERE (a.uom_class in (select to_uom_class
                                                         from mtl_uom_class_conversions b
                                                         where b.inventory_item_id = p_item_id)
                                            or a.uom_class =(select DISTINCT z.uom_class
                                                             from mtl_units_of_measure z , mtl_system_items_vl m
                                                             where m.inventory_item_id = p_item_id
                                                             AND z.uom_code = m.primary_uom_code
                                                             ))
                                    and a.base_uom_flag <> 'Y'
                                    and nvl(a.disable_date,sysdate+1) > SYSDATE);
            EXCEPTION
                WHEN No_Data_Found THEN
                    print_debug(p_to_uom_code || ' UOM not valid for intra class conversion ' || g_pkg_version, 1);
                    RAISE l_invalid_uom_exc;
            END  ;


            BEGIN
                SELECT 'Y'
                INTO l_conversion_exists
                FROM mtl_uom_conversions
                WHERE inventory_item_id = p_item_id
                AND uom_code = p_to_uom_code ;
            EXCEPTION
                WHEN no_data_found THEN
                    print_debug(' Creating Intra-class conversion ' || g_pkg_version, 1);
                    l_conversion_exists := 'N' ;
            END ;

        ELSE
            BEGIN
                SELECT 'Y'
                INTO l_conversion_exists
                FROM mtl_uom_conversions
                WHERE inventory_item_id = 0
                AND uom_code = p_to_uom_code ;
            EXCEPTION
                WHEN no_data_found THEN
                    print_debug(' Creating Standard conversion ' || g_pkg_version, 1);
                    l_conversion_exists := 'N' ;
            END ;

        END IF ;

        IF l_conversion_exists = 'N' THEN
            INSERT INTO mtl_uom_conversions
                    (inventory_item_id,
                     unit_of_measure,
                     uom_code,
                     uom_class,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     conversion_rate,
                     default_conversion_flag)
            VALUES (p_item_id,
                    l_to_unit_of_measure,
                    p_to_uom_code,
                    l_to_class,
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    -1,
                    p_uom_rate,
            'N');
        ELSE
            print_debug(' Conversion already exists' || g_pkg_version, 1);
            RAISE l_conversion_exists_exc;
        END IF ;

    ELSE
        IF p_item_id = 0 THEN
            print_debug(' Inter-class conversion cannot be created if item_id =0' || g_pkg_version, 1);
            RAISE l_invalid_item_exc ;
        ELSE
            IF l_to_base_uom_flag <> 'Y' THEN
                print_debug(' inter class conversion cannot be done for non base units ' || g_pkg_version, 1);
                RAISE l_invalid_uom_exc ;
            END IF ;

            BEGIN
                SELECT DISTINCT inventory_item_id , primary_uom_code INTO l_temp_item_id , l_primary_uom_code
                FROM mtl_system_items_vl
                WHERE inventory_item_id = p_item_id
                AND inventory_item_id IN (SELECT DISTINCT I.inventory_item_id FROM mtl_system_items_vl I
                                            WHERE I.enabled_flag = 'Y'
                                            AND (SYSDATE BETWEEN NVL(TRUNC(I.start_date_active),SYSDATE )
                                                    AND NVL(TRUNC(I.end_date_active),SYSDATE))
                                            AND ( EXISTS (SELECT A.unit_of_measure FROM mtl_units_of_measure A
                                                            WHERE (A.uom_class <> (SELECT R.uom_class FROM mtl_units_of_measure R
                                                                                WHERE R.uom_code = I.primary_uom_code))
                                                            AND A.base_uom_flag = 'Y'
                                                            AND NVL(A.disable_date, SYSDATE+1) > SYSDATE
                                                            AND A.uom_class = NVL(l_to_class,A.uom_class))));
            EXCEPTION
                WHEN No_Data_Found THEN
                    print_debug(p_item_id || ' item not valid for inter class conversion ' || g_pkg_version, 1);
                    RAISE l_invalid_item_exc ;
            END ;

            BEGIN
                SELECT 'Y'
                INTO l_conversion_exists
                FROM mtl_uom_class_conversions
                WHERE inventory_item_id = p_item_id
                AND to_uom_code = p_to_uom_code ;
            EXCEPTION
                WHEN no_data_found THEN
                    print_debug(' Creating Inter-class conversion ' || g_pkg_version, 1);
                    l_conversion_exists := 'N' ;
            END ;

            IF l_conversion_exists = 'N' THEN
                INSERT INTO mtl_uom_class_conversions
                           (inventory_item_id,
                            from_unit_of_measure,
                            from_uom_code,
                            from_uom_class,
                            to_unit_of_measure,
                            to_uom_code,
                            to_uom_class,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            conversion_rate)
                VALUES     (p_item_id,
                            l_from_unit_of_measure,
                            p_from_uom_code,
                            l_from_class,
                            l_to_unit_of_measure,
                            p_to_uom_code,
                            l_to_class,
                            sysdate,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id,
                            -1,
                            p_uom_rate);
            ELSE
                print_debug(' inter class conversion already exists' || g_pkg_version, 1);
                RAISE l_conversion_exists_exc;
            END IF ;

        END IF ;
    END IF ;

    print_debug(' successfully returned from the package create_uom_conversion ' || g_pkg_version, 1);
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
    WHEN  l_invalid_uom_exc THEN
        fnd_message.set_name('INV', 'INV_UOM_NOTFOUND');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN l_conversion_exists_exc THEN
        x_return_status := l_ret_conv_exists_warning;
    WHEN l_invalid_item_exc THEN
        fnd_message.set_name('INV', 'INV_INVALID_ITEM');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN l_uom_fromto_exc THEN
        fnd_message.set_name('INV', 'INV_LOTC_UOM_FROMTO_ERROR');
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END create_uom_conversion;


END inv_convert;

/
