--------------------------------------------------------
--  DDL for Package Body PO_UOM_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UOM_S" as
/* $Header: RCVTXU1B.pls 120.3.12010000.9 2012/07/05 09:42:45 liayang ship $*/

-- <INVCONV R12>
g_chktype_TRACKING_QTY_IND_S CONSTANT
   MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND%TYPE
   := 'PS';

/*==============================  PO_UOM_S  ================================*/

   --BUG 5080295: unit_of_measure is a VARCHAR2(25). so we need size
   --25+25+2+38 = 90
   TYPE uom_conversion_table_type IS TABLE OF NUMBER INDEX BY VARCHAR2(90);

   g_uom_conversion_table uom_conversion_table_type;

/*===========================================================================

 FUNCTION NAME :  val_unit_of_measure()

===========================================================================*/
FUNCTION  val_unit_of_measure(X_unit_of_measure IN VARCHAR2) return BOOLEAN IS

  X_progress 	      varchar2(3)  := NULL;
  X_unit_of_measure_v varchar2(25) := NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Unit of Measure is active */

  SELECT  unit_of_measure
  INTO    X_unit_of_measure_v
  FROM    mtl_units_of_measure
  WHERE   sysdate < nvl(disable_date, sysdate + 1)
  AND     unit_of_measure = X_unit_of_measure;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_unit_of_measure',X_progress,sqlcode);
    raise;

END val_unit_of_measure;

/*===========================================================================

  PROCEDURE NAME:	uom_convert()

===========================================================================*/

PROCEDURE uom_convert(	from_quantity	in	number,
			from_uom	in	varchar2,
			item_id		in	number,
			to_uom		in	varchar2,
			to_quantity	out	NOCOPY number)
IS

   uom_rate	number := 0;
   x_progress 	VARCHAR2(3) := NULL;

BEGIN

   /*
   ** debug
   ** Call the stored function po_uom_convert to get the rate for now.
   ** Once Inventory has defined their procedure, change this call to the
   ** Inventory procedure
   */

   x_progress := 5;

   uom_rate := po_uom_convert(from_uom, to_uom, item_id);

   /*
    * BUG: 972611   (Base 11.0 bug 972454)
    * The variable to_quantity was rounded to 6 digits in bug 491623
    * for 107. This change was not carried over to 11.
    */

   to_quantity := round(from_quantity * uom_rate,9) ; /* Bug 7348590 */
/*changed precision to 9 as OM accepts precision value upto 9 only. and it satisfies the need of changing precision from 6 to 15 also bug 8393676*/

EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('uom_convert', x_progress, sqlcode);
   RAISE;

END uom_convert;


/*===========================================================================

  PROCEDURE NAME:	val_uom_conversion()

===========================================================================*/

PROCEDURE val_uom_conversion IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   null;

EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('val_uom_conversion', x_progress, sqlcode);
   RAISE;

END val_uom_conversion;

procedure po_uom_conversion ( from_unit         in      varchar2,
			      to_unit 	        in      varchar2,
			      item_id           in      number,
			      uom_rate    	out NOCOPY 	number ) IS
	/*
	** declare variables that are referenced in the cursor definitions
	*/

    from_class              varchar2(10);
    to_class                varchar2(10);

    x_progress varchar2(3) := NULL;

    cursor standard_conversions is
        select  t.conversion_rate      std_to_rate,
                t.uom_class            std_to_class,
                f.conversion_rate      std_from_rate,
                f.uom_class            std_from_class
        from  mtl_uom_conversions t,
              mtl_uom_conversions f
        where t.inventory_item_id in (item_id, 0)
        and   t.unit_of_measure = to_unit
        and   nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        and   f.inventory_item_id in (item_id, 0)
        and   f.unit_of_measure = from_unit
        and   nvl(f.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        order by t.inventory_item_id desc,
                 f.inventory_item_id desc;

    std_rec standard_conversions%rowtype;

    /* Bug# 1834317 - Added the condition where  inventory_item_id in
       (item_id, 0) */

    /* the above fix caused bug : 2076110
       we should handle inter-class conv. for inventory and one-time items separately */

    cursor interclass_conversions(inv_item_flag varchar2) is
        select decode(to_uom_class, to_class, 1, 2) to_flag,
               decode(from_uom_class, from_class, 1, to_class, 2, 0) from_flag,
               conversion_rate rate
        from   mtl_uom_class_conversions
        where  ((inv_item_flag = 'Y' and inventory_item_id = item_id)
		  or
	     	(inv_item_flag = 'N' and inventory_item_id = 0))
        and    to_uom_class in (from_class, to_class)
        and    nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate);

    class_rec interclass_conversions%rowtype;


    invalid_conversion      exception;
    invalid_interclass_conversion exception; -- Bug 10202212

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
    inv_item_flag	    varchar2(1);

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
    x_progress := '010';

    if (from_unit = to_unit) then

	uom_rate := 1;
	return;

    end if;

    /* Bug 12915619 remove this cache since two RTP can run with same db session in online mode
     * IF g_uom_conversion_table.EXISTS(from_unit || '-' || to_unit || '-' ||to_char(nvl(item_id,0))) THEN
     *   uom_rate := g_uom_conversion_table(from_unit || '-' || to_unit || '-' ||to_char(nvl(item_id,0)));
     *   RETURN;
     * END IF;
    */

    /*
    ** Get item specific or standard conversions
    */
    x_progress := '020';

    open standard_conversions;

    std_index := 0;

    loop

        x_progress := '030';

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
    x_progress := '040';

    if (std_index = 0) then

        /*
        ** No conversions defined
        */

            msgbuf := msgbuf||'Invalid standard conversion : ';
            msgbuf := msgbuf||'From unit: '||from_unit||' ';
            msgbuf := msgbuf||'To unit: '||to_unit||' ';
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

    x_progress := '050';

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

	if (item_id is null or item_id = 0) then
		inv_item_flag := 'N';
	else
		inv_item_flag := 'Y';
	end if;

        open interclass_conversions(inv_item_flag);

        loop

            x_progress := '060';

            fetch interclass_conversions into class_rec;
            exit when interclass_conversions%notfound;

            class_index := class_index + 1;

            to_class_flag_tab(class_index) := class_rec.to_flag;
            from_class_flag_tab(class_index) := class_rec.from_flag;
            interclass_rate_tab(class_index) := class_rec.rate;

        end loop;

        close interclass_conversions;

        x_progress := '070';

        if (class_index = 2) then

  	   /* Start Bug 3654053 : We should error out for Expense Items if the UOM
	     Interclass Conversions are not defined between the two UOMs. Added the
	     following if condition. If the inv_item_flag = N then we raise an
	     exception.
	   */

            if inv_item_flag = 'Y' then

                 if (to_class_flag_tab(1) = 1) then

                     to_class_rate := interclass_rate_tab(1);
                     from_class_rate := interclass_rate_tab(2);

                  else

                      to_class_rate := interclass_rate_tab(2);
                      from_class_rate := interclass_rate_tab(1);

                  end if;

         /* Bug 3385209 start
         ** Added the following statement to calculate the interclass_rate between the
         ** Source Doc UOM and the Transaction UOM when there is no direct conversion
         ** defined between them.*/

                  interclass_rate := from_class_rate/to_class_rate;

         /* Bug 3385209 End */

	    else

              /*
              ** No interclass conversion is defined for Expense Items
              */

                msgbuf := msgbuf||'Invalid Interclass conversion : ';
                msgbuf := msgbuf||'From unit: '||from_unit||' ';
                msgbuf := msgbuf||'To unit: '||to_unit||' ';
                raise invalid_interclass_conversion;    -- Bug 10202212


            end if;

          /* End Bug# 3654053 */

        elsif ((class_index = 1) and
                 (to_class_flag_tab(1) = from_class_flag_tab(1) )) then


            if (to_class_flag_tab(1) = 1) then

                to_class_rate := interclass_rate_tab(1);
                from_class_rate := 1;

            else

                to_class_rate := 1;
                from_class_rate := interclass_rate_tab(1);

            end if;

            x_progress := '080';

            interclass_rate := from_class_rate/to_class_rate;

        else

            /*
            ** No interclass conversion is defined
            */

            msgbuf := msgbuf||'Invalid Interclass conversion : ';
            msgbuf := msgbuf||'From unit: '||from_unit||' ';
            msgbuf := msgbuf||'To unit: '||to_unit||' ';
            raise invalid_interclass_conversion;  -- Bug 10202212



        end if;


    end if;


    /*
    ** conversion rates are defaulted to '1' at the start of the procedure
    ** so seperate calculations are not required for standard/interclass
    ** conversions
    */
    x_progress := '090';

    uom_rate := (from_rate * interclass_rate) / to_rate;

    /* Bug 12915619 remove this cache since two RTP can run with same db session in online mode
     * g_uom_conversion_table(from_unit || '-' || to_unit || '-' ||to_char(nvl(item_id,0)))  := uom_rate;
     */

    /*
    ** Put a label and a null statement over here so that you can
    ** the goto statements can branch here.
    */

    <<procedure_end>>

    null;

-- Block modified for Bug 10202212 to display appropriate error message to user.

exception
  WHEN invalid_interclass_conversion THEN
    PO_MESSAGE_S.APP_ERROR('PO_SUB_UOM_CLASS_CONVERSION');
   WHEN invalid_conversion THEN
--Bug 14061304: set tokens
      PO_MESSAGE_S.APP_ERROR('PO_UOM_CONVERSION_FAIL',
                             'PREV_UOM', from_unit, 'CURR_UOM', to_unit);
--Bug 14061304: End
   WHEN OTHERS THEN
      po_message_s.sql_error('po_uom_conversion', x_progress, sqlcode);
   RAISE;

-- Bug 10202212 ends

end po_uom_conversion;

function po_uom_convert ( from_unit  in varchar2,to_unit in varchar2,
item_id  in number ) return number is

	/*
	** declare variables that are passed to po_uom_conversion
	*/

	uom_rate	number;
	msgbuf          varchar2(200);
        x_progress VARCHAR2(3) := NULL;

begin

	/* Call the po_uom_conversion procedure to calculate the uom_rate
	** and return.
	** This function previously calculated the conversion rate in the
 	** body of the function itself. This was replaced by the present
	** procedure call because of a PL/SQL bug which caused memory leaks
	** while using tables in functions. Refer to bug 191321 for details.
	*/

	/* Bug 5218352: Call po_uom_conversion only if from and to UOMs are
	**              different.
	*/

	IF from_unit <> to_unit THEN
	  po_uom_s.po_uom_conversion(from_unit, to_unit, item_id, uom_rate);
	ELSE
	  uom_rate := 1;
	END IF;

	return uom_rate;

exception

   WHEN OTHERS THEN
      po_message_s.sql_error('po_uom_convert', x_progress, sqlcode);
   RAISE;

end po_uom_convert;

/*
**  Function GET_PRIMARY_UOM
**
**  function returns the primary UOM based on item_id/organization
**  for both pre-defined and one-time items
*/

function get_primary_uom ( item_id  in number,   org_id  in number,
current_unit_of_measure  in  varchar2 )  return varchar2 is

    primary_unit        varchar2(25);
    msgbuf              varchar2(200);
    x_progress VARCHAR2(3) := NULL;

begin

    msgbuf := '';
    primary_unit := '';


    if (item_id is null) then

        /*
        ** for a one-time item, the primary uom is the
        ** base uom for the item's current uom class
        */

        begin

            select buom.unit_of_measure
            into primary_unit
            from mtl_units_of_measure cuom,
                 mtl_units_of_measure buom
            where cuom.unit_of_measure = current_unit_of_measure
            and   cuom.uom_class = buom.uom_class
            and   buom.base_uom_flag = 'Y';

        exception

            when others then
                msgbuf := msgbuf||'Statement: 001: ';
                msgbuf := msgbuf||'Current unit: ';
                msgbuf := msgbuf||current_unit_of_measure||' ';
                raise;

        end;

    else

        /*
        ** for pre-defined items, get the primary uom
        ** from mtl_system_items
        */

        begin

            select msi.primary_unit_of_measure
            into primary_unit
            from mtl_system_items msi
            where msi.inventory_item_id = item_id
            and   msi.organization_id = org_id;

        exception

            when others then
                msgbuf := msgbuf||'Statement: 002: ';
                msgbuf := msgbuf||'Item ID: '||item_id||' ';
                msgbuf := msgbuf||'Organization ID: '||org_id||' ';
                raise;

        end;

    end if;

    return primary_unit;

exception

   WHEN OTHERS THEN
      po_message_s.sql_error('get_primary_uom', x_progress, sqlcode);
   RAISE;

end get_primary_uom;

/*========================================================================

  FUNCTION  :   po_uom_convert_p() -dreddy

   Created a function po_uom_convert_p which is pure function to be used in
   the where and select clauses of a SQL stmt.bug 1365577
   ******************************************************
   So, any change in the po_uom_convertion proc in rvpo02
   should be implemented in this new function.
   ******************************************************
========================================================================*/
function po_uom_convert_p ( from_unit  varchar2, to_unit
 	varchar2, item_id number ) return number as

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
        and   t.unit_of_measure = to_unit
        and   nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
        and   f.inventory_item_id in (item_id, 0)
        and   f.unit_of_measure = from_unit
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

    uom_rate               number := 1;
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
            msgbuf := msgbuf||'From unit: '||from_unit||' ';
            msgbuf := msgbuf||'To unit: '||to_unit||' ';
            return -999 ;

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
            msgbuf := msgbuf||'From unit: '||from_unit||' ';
            msgbuf := msgbuf||'To unit: '||to_unit||' ';
            return -999 ;


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

    return ROUND(NVL(uom_rate, 1), 5) ;

end po_uom_convert_p;


/*===========================================================================
  PROCEDURE NAME:  get_secondary_uom()

  DESCRIPTION:
        This function returns the primary UOM based on item_id/organization
        for both pre-defined and one-time items

  USAGE:
	uom := po_uom_s.get_secondary_uom ( item_id  number,   org_id   number,
                                        current_sec_unit_of_measure   varchar2 )

  PARAMETERS:
	item_id		IN  number   - item id (null for one time items)
        org_id          IN  number   - org id
        current_sec_unit_of_measure IN VARCHAR2 - currently defined uom on trx.

  RETURNS:

	secondary_uom - VARCHAR2 - Secondary UOM for given item and org

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	09-SEP-05	Preetam Bamb	Created
===========================================================================*/
procedure get_secondary_uom (p_item_id  in number,
                             p_org_id   in number,
                             x_secondary_uom_code out NOCOPY varchar2,
                             x_secondary_unit_of_measure out NOCOPY varchar2) is

    msgbuf                varchar2(200);
    x_progress            varchar2(3)  := NULL;
    l_tracking_quantity_ind mtl_system_items.tracking_quantity_ind%TYPE:= NULL;

begin
    msgbuf := '';
    x_progress := '001';

    if (p_item_id is not null) then
        begin
            select msi.tracking_quantity_ind,msi.secondary_uom_code, muom.unit_of_measure
            into   l_tracking_quantity_ind, x_secondary_uom_code,x_secondary_unit_of_measure
            from mtl_system_items msi, mtl_units_of_measure muom
            where msi.inventory_item_id = p_item_id
            and   msi.organization_id = p_org_id
            and   msi.secondary_uom_code = muom.uom_code(+);

            x_progress := '002';
            if l_tracking_quantity_ind <> g_chktype_TRACKING_QTY_IND_S then
               x_secondary_uom_code := NULL;
               x_secondary_unit_of_measure := NULL;
            end if;

            exception when NO_DATA_FOUND then
               x_secondary_uom_code := NULL;
               x_secondary_unit_of_measure := NULL;
        end;
    else
       x_secondary_uom_code := NULL;
       x_secondary_unit_of_measure := NULL;
    end if;

    x_progress := '003';
exception

   WHEN OTHERS THEN
      po_message_s.sql_error('get_secondary_uom', x_progress, sqlcode);
      RAISE;

end;
/*===========================================================================
  PROCEDURE NAME:  get_unit_of_measure()

  DESCRIPTION:
        This function returns the unit of measure for the passed uom code

  USAGE:
        uom := po_uom_s.get_unit_of_measure(
                             p_uom_code in varchar2,
                             x_unit_of_measure out NOCOPY varchar2);

  PARAMETERS:
        x_uom_code IN VARCHAR2 - items secondary uom code.
        x_unit_of_measure OUT VARCHAR2 - items secondary unit of meas

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
        09-SEP-05       Preetam Bamb    Created
===========================================================================*/
procedure get_unit_of_measure(
                             p_uom_code in varchar2,
                             x_unit_of_measure out NOCOPY varchar2)
IS
    x_progress            varchar2(3)  := NULL;
BEGIN

    x_progress := '001';

    if p_uom_code is NOT NULL THEN
     begin
       select unit_of_measure
       into   x_unit_of_measure
       from   mtl_units_of_measure
       where  uom_code = p_uom_code;

       x_progress := '002';
       exception when no_data_found then
          x_unit_of_measure := NULL;
     end;
    end if;

    x_progress := '003';
exception

   WHEN OTHERS THEN
      po_message_s.sql_error('get_secondary_uom', x_progress, sqlcode);
      RAISE;
END;

  /*========================================================================

  FUNCTION  :   rti_trx_qty_to_soc_qty()

   Created a function rti_trx_qty_to_soc_qty which is pure function to be used in
   the where and select clauses of rvtvq.lpc the lot specific UOM convertion for rti
   source_doc_quantity   for bug 14106596

========================================================================*/

  FUNCTION RTI_TRX_QTY_TO_SOC_QTY(P_INTERFACE_TRANSACTION_ID IN NUMBER,
                                  P_TO_ORG_ID                IN NUMBER,
                                  P_ITEM_ID                  IN NUMBER,
                                  P_FROM_QTY                 IN NUMBER,
                                  P_FROM_UOM                 IN VARCHAR2,
                                  P_TO_UOM                   IN VARCHAR2)
  /*this fuction is used to caculate the source_doc_quantity for rti*/
   RETURN NUMBER IS

    L_TOT_QTY     NUMBER := 0;
    L_TOT_QTY1    NUMBER := 0;
    L_SRC_DOC_QTY NUMBER := 0;
    -- Local variables here
    L_QTY  NUMBER := 0;
    L_QTY1 NUMBER := 0;

    L_MTLT_COUNT NUMBER := 0;
    L_MTLI_COUNT NUMBER := 0;
    L_RATE       NUMBER := 1;
    L_RATE1      NUMBER := 1;

    CURSOR LOT_NUM_CUR(P_INTERFACE_TRANSACTION_ID NUMBER) IS
      SELECT TRANSACTION_QUANTITY, LOT_NUMBER
        FROM MTL_TRANSACTION_LOTS_TEMP
       WHERE PRODUCT_TRANSACTION_ID = P_INTERFACE_TRANSACTION_ID;

    CURSOR LOT_NUM_INT_CUR(P_INTERFACE_TRANSACTION_ID NUMBER) IS
      SELECT TRANSACTION_QUANTITY, LOT_NUMBER
        FROM MTL_TRANSACTION_LOTS_INTERFACE
       WHERE PRODUCT_TRANSACTION_ID = P_INTERFACE_TRANSACTION_ID;

  BEGIN


    BEGIN

      SELECT COUNT(1)
        INTO L_MTLT_COUNT
        FROM MTL_LOT_UOM_CLASS_CONVERSIONS MLUC,
             MTL_TRANSACTION_LOTS_TEMP     MTLT -- Used for form action
       WHERE MTLT.LOT_NUMBER = MLUC.LOT_NUMBER
         AND MLUC.ORGANIZATION_ID = P_TO_ORG_ID
         AND MLUC.INVENTORY_ITEM_ID = P_ITEM_ID
         AND MLUC.FROM_UNIT_OF_MEASURE = P_FROM_UOM
         AND MLUC.TO_UNIT_OF_MEASURE = P_TO_UOM
         AND MTLT.PRODUCT_TRANSACTION_ID = P_INTERFACE_TRANSACTION_ID
 ;

    EXCEPTION
      WHEN OTHERS THEN

        L_MTLT_COUNT := 0;

    END;

    BEGIN
      SELECT COUNT(1)
        INTO L_MTLI_COUNT
        FROM MTL_LOT_UOM_CLASS_CONVERSIONS  MLUC,
             MTL_TRANSACTION_LOTS_INTERFACE MTLI -- Used for ROI&LOT action
       WHERE MTLI.LOT_NUMBER = MLUC.LOT_NUMBER
         AND MLUC.ORGANIZATION_ID = P_TO_ORG_ID
         AND MLUC.INVENTORY_ITEM_ID = P_ITEM_ID
         AND MLUC.FROM_UNIT_OF_MEASURE = P_FROM_UOM
         AND MLUC.TO_UNIT_OF_MEASURE = P_TO_UOM
         AND MTLI.PRODUCT_TRANSACTION_ID = P_INTERFACE_TRANSACTION_ID;

    EXCEPTION
      WHEN OTHERS THEN

        L_MTLI_COUNT := 0;

    END;

    /* for the Form*/
    IF L_MTLT_COUNT > 0 THEN

      FOR LOT_NUM_REC IN LOT_NUM_CUR(P_INTERFACE_TRANSACTION_ID) LOOP

        L_QTY := INV_CONVERT.INV_UM_CONVERT(ITEM_ID         => P_ITEM_ID,
                                            LOT_NUMBER      => LOT_NUM_REC.LOT_NUMBER,
                                            ORGANIZATION_ID => P_TO_ORG_ID,
                                            PRECISION       => 15,
                                            FROM_QUANTITY   => LOT_NUM_REC.TRANSACTION_QUANTITY,
                                            FROM_UNIT       => NULL,
                                            TO_UNIT         => NULL,
                                            FROM_NAME       => P_FROM_UOM,
                                            TO_NAME         => P_TO_UOM);

        L_TOT_QTY := L_QTY + L_TOT_QTY;

      END LOOP;




    END IF;

    /* for the ROI*/

    IF L_MTLI_COUNT > 0 THEN

      FOR LOT_NUM_INT_REC IN LOT_NUM_INT_CUR(P_INTERFACE_TRANSACTION_ID) LOOP

        L_QTY1 := INV_CONVERT.INV_UM_CONVERT(ITEM_ID         => P_ITEM_ID,
                                             LOT_NUMBER      => LOT_NUM_INT_REC.LOT_NUMBER,
                                             ORGANIZATION_ID => P_TO_ORG_ID,
                                             PRECISION       => 15,
                                             FROM_QUANTITY   => LOT_NUM_INT_REC.TRANSACTION_QUANTITY,
                                             FROM_UNIT       => NULL,
                                             TO_UNIT         => NULL,
                                             FROM_NAME       => P_FROM_UOM,
                                             TO_NAME         => P_TO_UOM);

        L_TOT_QTY1 := L_QTY1 + L_TOT_QTY1;

      END LOOP;



    END IF;


    L_SRC_DOC_QTY := NVL(L_TOT_QTY, 0) + NVL(L_TOT_QTY1, 0);


    IF (L_MTLT_COUNT = 0 AND L_MTLI_COUNT =0 ) THEN

      L_RATE    := PO_UOM_S.PO_UOM_CONVERT(P_FROM_UOM, P_TO_UOM, P_ITEM_ID);
      L_TOT_QTY := ROUND(P_FROM_QTY * L_RATE, 15);
      RETURN L_TOT_QTY;
    ELSE
      RETURN L_SRC_DOC_QTY;
    END IF;

  END;



END PO_UOM_S;

/
