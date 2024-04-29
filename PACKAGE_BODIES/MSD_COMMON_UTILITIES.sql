--------------------------------------------------------
--  DDL for Package Body MSD_COMMON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COMMON_UTILITIES" AS
/* $Header: msdcmutb.pls 120.4 2006/05/25 04:56:36 amitku noship $ */


/* Public Procedures */

procedure get_inst_info(
      p_instance_id   IN  NUMBER,
                        p_dblink        IN OUT NOCOPY   VARCHAR2,
      p_icode         IN OUT NOCOPY   VARCHAR2,
      p_apps_ver      IN OUT NOCOPY   NUMBER,
      p_dgmt          IN OUT NOCOPY   NUMBER,
      p_instance_type IN OUT NOCOPY  VARCHAR2,
      p_retcode       IN OUT NOCOPY  NUMBER) IS
Begin

  SELECT decode( m2a_dblink,
                      null, '',
                      '@'||m2a_dblink),
              instance_code,
              apps_ver,
              gmt_difference/24.0,
              instance_type
         INTO p_dblink,
              p_icode,
              p_apps_ver,
              p_dgmt,
              p_instance_type
         FROM MSC_APPS_INSTANCES
         WHERE instance_id= p_instance_id;

  p_retcode := 1 ;

        Exception
           when others then
                p_dblink := null ;
    p_icode := null ;
    p_apps_ver := null ;
    p_dgmt := null ;
    p_instance_type := null ;
    p_retcode := -1 ;

End get_inst_info ;

procedure get_db_link(
                        p_instance_id    IN  NUMBER,
                        p_dblink         IN OUT NOCOPY  VARCHAR2,
      p_retcode        IN OUT NOCOPY  NUMBER) IS
Begin

        SELECT decode( m2a_dblink,
                      null, '',
                      '@'||m2a_dblink)
         INTO p_dblink
         FROM MSC_APPS_INSTANCES
         WHERE instance_id= p_instance_id;


        -- zia: changed retcode to 0, since 1 means warning
        --p_retcode := 1 ;
        p_retcode := 0;

  Exception
     when others then
    p_dblink := null ;
                p_retcode := -1 ;


End get_db_link ;

function get_item_key(
      p_instance_id   IN  NUMBER,
      p_sr_key    IN  VARCHAR2,
      p_val       IN  VARCHAR2,
      p_level_id  IN  NUMBER
         ) return number Is
l_ret NUMBER;
  l_def_level_id number:=28;
BEGIN
if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;

function get_org_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key    IN  VARCHAR2,
                        p_val       IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number Is
  l_ret NUMBER;
  l_def_level_id number:=29;
BEGIN
 if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;


function get_level_value_pk(
                        p_instance_id   IN  NUMBER,
                        p_sr_key   	IN  VARCHAR2,
                        p_val      	IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number IS
  l_ret NUMBER;

  cursor sr_lvl_pk_c1 (p_instance_id IN NUMBER, p_sr_key IN VARCHAR2, p_level_id IN NUMBER) IS
  select level_pk
  from msd_level_values
  where instance = p_instance_id
  and sr_level_pk = p_sr_key
  and level_id = p_level_id;

  cursor lvl_val_c1 (p_instance_id IN NUMBER, p_val IN VARCHAR2, p_level_id IN NUMBER) IS
  select level_pk
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = p_level_id;

BEGIN
  if p_level_id is null or (p_val is NULL and p_sr_key is null) then
     l_ret := null;

  elsif p_sr_key is not null then

      open sr_lvl_pk_c1(p_instance_id, p_sr_key, p_level_id);
      fetch sr_lvl_pk_c1 into l_ret;
      close sr_lvl_pk_c1;

  else

      open lvl_val_c1(p_instance_id, p_val, p_level_id);
      fetch lvl_val_c1 into l_ret;
      close lvl_val_c1;

  end if;

 return l_ret;

 EXCEPTION when others then return NULL;
END;

function get_loc_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key    IN  VARCHAR2,
                        p_val       IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number Is
l_ret NUMBER;
  l_def_level_id number:=30;
BEGIN
 if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  SELECT level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;


function get_cus_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key    IN  VARCHAR2,
                        p_val       IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number Is
l_ret NUMBER;
  l_def_level_id number:=30;
BEGIN
 if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;


function get_salesrep_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key    IN  VARCHAR2,
                        p_val       IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number Is
l_ret NUMBER;
  l_def_level_id number:=32;
BEGIN
 if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;


function get_sc_key(
                        p_instance_id   IN  NUMBER,
                        p_sr_key      IN  VARCHAR2,
                        p_val       IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     )  return number Is
l_ret NUMBER;
  l_def_level_id number:=33;
BEGIN
 if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;



function get_dcs_key(
      p_instance_id   IN  NUMBER,
      p_sr_key    IN  VARCHAR2,
      p_val       IN  VARCHAR2,
      p_level_id  IN  NUMBER
         ) return number Is
l_ret NUMBER;
  l_def_level_id number:=40;
BEGIN
if p_val is NULL then
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select level_pk
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;
END;


function get_level_pk return number Is
x_temp number ;
Begin

  select msd_level_values_s.nextval into x_temp
  from   sys.dual ;

  return x_temp;


    exception

  when others then
    null ;

end get_level_pk ;

function get_level_name( p_level_id     IN NUMBER ) return varchar2
is
l_level_name varchar2(30);
begin

 if p_level_id is NULL then

  l_level_name := null ;

 else

  select level_name
  into l_level_name
  from msd_levels
  where level_id = p_level_id
    and plan_type is null;

 end if;

 return l_level_name;

EXCEPTION when others then return NULL;

END get_level_name;

FUNCTION get_supplier_calendar(
                             p_plan_id in number,
                             p_sr_instance_id in number,
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_supplier_id in number,
                             p_supplier_site_id in number,
                             p_using_organization_id in number
                           ) return varchar2 is

cursor c1 (p_plan_id in number, p_sr_instance_id IN NUMBER, p_organization_id IN number, p_inventory_item_id IN NUMBER,
           p_supplier_id in number, p_supplier_site_id in number, p_using_organization_id in number) IS
    select DELIVERY_CALENDAR_CODE
    from msc_item_suppliers
    where plan_id = p_plan_id
    and sr_instance_id = p_sr_instance_id
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and supplier_id = p_supplier_id
    and supplier_site_id = p_supplier_site_id
    and using_organization_id = p_using_organization_id;

cursor c2 (p_sr_instance_id IN NUMBER, p_organization_id IN number) IS
     select calendar_code
     from msc_trading_partners
     where partner_type = 3
     and sr_tp_id = p_organization_id
     and sr_instance_id = p_sr_instance_id;

    l_ret   varchar2(30) := null;
Begin

    open c1 (p_plan_id, p_sr_instance_id, p_organization_id, p_inventory_item_id,
             p_supplier_id, p_supplier_site_id, p_using_organization_id);
    fetch c1 into l_ret;
    close c1;

    if l_ret is null then
       open c2 (p_sr_instance_id, p_organization_id);
       fetch c2 into l_ret;
       close c2;
    end if;

    return l_ret;
    EXCEPTION when others then return NULL;

End get_supplier_calendar;

FUNCTION get_safety_stock_enddate(
                             p_plan_id in number,
                             p_sr_instance_id in number,
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_period_start_date in date
                           ) return date is

cursor c1 (p_plan_id in number, p_sr_instance_id IN NUMBER, p_organization_id IN number,
           p_inventory_item_id IN NUMBER, p_period_start_date IN DATE) IS
    select min(period_start_date) -1 period_end_date
    from msc_safety_stocks
    where plan_id = p_plan_id
    and sr_instance_id = p_sr_instance_id
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and period_start_date > p_period_start_date;

cursor c2 (p_plan_id in number) IS
     select CURR_CUTOFF_DATE
     from msc_plans
     where plan_id = p_plan_id;

    l_ret   date := null;
Begin

    open c1 (p_plan_id, p_sr_instance_id, p_organization_id, p_inventory_item_id, p_period_start_date);
    fetch c1 into l_ret;
    close c1;

    if l_ret is null then
       open c2 (p_plan_id);
       fetch c2 into l_ret;
       close c2;
    end if;

    return l_ret;
    EXCEPTION when others then return NULL;

End get_safety_stock_enddate;

function get_sr_level_pk return number is
  v_ret number;
  v_count number := 1;

begin

  -- loop until unique key is generated
  while (v_count > 0) loop
    select MSD_SR_LEVEL_PK_S.nextval
    into v_ret
    from sys.dual;

    select count(*)
    into v_count
    from msd_level_values
    where sr_level_pk = to_char(v_ret);
  end loop;

  return v_ret;

  EXCEPTION
    when others then
      return null;

end get_sr_level_pk;

--This function is added to derive unique SR_LEVEL_PK for the Level
--Values during Legacy Loads.
function get_sr_level_pk (p_instance_id in NUMBER,
                          p_instance_code in VARCHAR2)
return number is
  v_next number;
  v_count1 number := 1;
  v_count2 number := 1;
begin

  -- loop until unique key is generated from staging and fact table
  while ( v_count1 > 0 OR v_count2 > 0) loop

    select MSD_SR_LEVEL_PK_S.nextval
    into v_next
    from sys.dual;

    select count(*)
    into v_count1
    from msd_st_level_values
    where sr_instance_code = p_instance_code
    and process_flag       = G_IN_PROCESS
    and sr_level_pk        = to_char(v_next);

    select count(*)
    into v_count2
    from msd_level_values
    where instance = to_char(p_instance_id)
    and sr_level_pk = to_char(v_next);

  end loop;

  return v_next;

  EXCEPTION
    when others then
       msc_st_util.log_message(SQLERRM);
       return null;

end get_sr_level_pk;

/* OPM Procedure added for OPM DP integration
   This takes level_id as input and gets the dimension code of the owning dimension
*/
procedure get_dimension_code(
                        p_level_id              IN  NUMBER,
                        p_dimension_code        IN OUT NOCOPY   VARCHAR2,
                        p_retcode               IN OUT NOCOPY  NUMBER)  IS
Begin

        SELECT
              dimension_code
         INTO
              p_dimension_code
         FROM MSD_LEVELS
         WHERE level_id = p_level_id
           AND plan_type is null;

        p_retcode := 1 ;

        Exception
           when others then
                p_dimension_code  := null ;
                p_retcode := -1 ;

End get_dimension_code ;

function get_level_value(p_level_pk in number) return varchar2 is

  cursor c1 is
  select level_value
  from msd_level_values
  where level_pk = p_level_pk;

  l_value varchar2(255);

Begin
  open c1;
  fetch c1 into l_value;
  close c1;

  return l_value;
End;



/***************************************************************************

Procedure:    msd_uom_conversion

****************************************************************************/
PROCEDURE msd_uom_conversion (from_unit         varchar2,
                              to_unit           varchar2,
                              item_id           number,
                              uom_rate    OUT NOCOPY    number ) IS

from_class              varchar2(10);
to_class                varchar2(10);

CURSOR standard_conversions IS
select  t.conversion_rate      std_to_rate,
        t.uom_class            std_to_class,
        f.conversion_rate      std_from_rate,
        f.uom_class            std_from_class
from  msc_uom_conversions t,
      msc_uom_conversions f
where t.inventory_item_id in (item_id, 0) and
      t.uom_code = to_unit and
      nvl(t.disable_date, trunc(sysdate) + 1) > trunc(sysdate) and
      f.inventory_item_id in (item_id, 0) and
      f.uom_code = from_unit and
      nvl(f.disable_date, trunc(sysdate) + 1) > trunc(sysdate)
order by t.inventory_item_id desc, f.inventory_item_id desc;


std_rec standard_conversions%rowtype;


CURSOR interclass_conversions(p_from_class VARCHAR2, p_to_class VARCHAR2) IS
select decode(from_uom_class, p_from_class, 1, 2) from_flag,
       decode(to_uom_class, p_to_class, 1, 2) to_flag,
       conversion_rate rate
from   msc_uom_class_conversions
where  inventory_item_id = item_id and
       nvl(disable_date, trunc(sysdate) + 1) > trunc(sysdate) and
       ( (from_uom_class = p_from_class and to_uom_class = p_to_class) or
         (from_uom_class = p_to_class   and to_uom_class = p_from_class) );

class_rec interclass_conversions%rowtype;

invalid_conversion      exception;

type conv_tab is table of number index by binary_integer;
type class_tab is table of varchar2(10) index by binary_integer;

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
msgbuf                  varchar2(500);

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

    /* If from and to units are the same, conversion rate is 1.
       Go immediately to the end of the procedure to exit.*/

    if (from_unit = to_unit) then
      uom_rate := 1;
  goto  procedure_end;
    end if;


    /* Get item specific or standard conversions */
    open standard_conversions;
    std_index := 0;
    loop

        std_index := std_index + 1;

        fetch standard_conversions into std_rec;
        exit when standard_conversions%notfound;

        from_rate_tab(std_index) := std_rec.std_from_rate;
        from_class_tab(std_index) := std_rec.std_from_class;
        to_rate_tab(std_index) := std_rec.std_to_rate;
        to_class_tab(std_index) := std_rec.std_to_class;

    end loop;

    close standard_conversions;

    if (std_index = 0) then    /* No conversions defined  */
       msgbuf := msgbuf||'Invalid standard conversion : ';
       msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
       msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
       raise invalid_conversion;

    else
        /* Conversions are ordered.
           Item specific conversions will be returned first. */

        from_class := from_class_tab(1);
        to_class := to_class_tab(1);
        from_rate := from_rate_tab(1);
        to_rate := to_rate_tab(1);

    end if;


    /* Load interclass conversion tables */
    if (from_class <> to_class) then
        class_index := 0;
        open interclass_conversions (from_class, to_class);
        loop

            fetch interclass_conversions into class_rec;
            exit when interclass_conversions%notfound;

            class_index := class_index + 1;

            to_class_flag_tab(class_index) := class_rec.to_flag;
            from_class_flag_tab(class_index) := class_rec.from_flag;
            interclass_rate_tab(class_index) := class_rec.rate;

        end loop;
        close interclass_conversions;

        /* No interclass conversion is defined */
        if (class_index = 0 ) then
            msgbuf := msgbuf||'Invalid Interclass conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
            raise invalid_conversion;
        else
            if ( to_class_flag_tab(1) = 1 and from_class_flag_tab(1) = 1 ) then
               to_class_rate := interclass_rate_tab(1);
               from_class_rate := 1;
            else
               from_class_rate := interclass_rate_tab(1);
               to_class_rate := 1;
            end if;
            interclass_rate := from_class_rate/to_class_rate;
        end if;
    end if;  /* End of from_class <> to_class */

    /*
    ** conversion rates are defaulted to '1' at the start of the procedure
    ** so seperate calculations are not required for standard/interclass
    ** conversions
    */

    if (to_rate <> 0 ) then
       uom_rate := (from_rate * interclass_rate) / to_rate;
    else
       uom_rate := 1;
    end if;


    /* Put a label and a null statement over here so that you can
       the goto statements can branch here */
<<procedure_end>>

    null;

exception

    when others then
         uom_rate := 1;

END msd_uom_conversion;


/*******************************************************************

Function : uom_conv

*********************************************************************/

function uom_conv (uom_code varchar2,
      item_id  number default null)   return number as

     base_uom                varchar2(3);
     conv_rate                number:=1;
     l_master_org            number;
     l_master_uom                varchar2(3);

begin

      select to_number(parameter_value)
      into l_master_org
      from msd_setup_parameters
      where parameter_name = 'MSD_MASTER_ORG';

     select NVL(uom_code,'Ea')
     into   l_master_uom
     from msc_system_items
     where inventory_item_id = item_id
     and   organization_id = l_master_org;

/* Convert to Master org primary uom */

    msd_uom_conversion(uom_code,l_master_uom,item_id,conv_rate);

    return conv_rate;


  exception

       when others then

          return 1;

 end uom_conv;


/*******************************************************************

Function : msd_uom_convert

*********************************************************************/
FUNCTION  msd_uom_convert (p_item_id           number,
                           p_precision         number,
                           p_from_unit         varchar2,
                           p_to_unit           varchar2) RETURN number is

l_uom_rate  number;
l_msgbuf          varchar2(200);
l_eff_precision number;

l_from_unit  varchar2(10);
l_to_unit  varchar2(10);

BEGIN


        IF (p_from_unit is not null and p_to_unit is not null) THEN
     msd_uom_conversion(p_from_unit, p_to_unit,p_item_id, l_uom_rate);

           if ( l_uom_rate = -99999 ) then
             return 1;
     end if;

           if (p_precision IS NULL) then
             return l_uom_rate;
     else
       return round(l_uom_rate, p_precision);
           end if;

        ELSE  /* if either p_from_unit or p_to_unit is null */
           RETURN 1;
        END IF;


EXCEPTION

    when others then
       return 1;
END msd_uom_convert;


/*******************************************************************

Function : get_parent_level_pk

*********************************************************************/

FUNCTION  get_parent_level_pk (
                                p_instance_id varchar2,
                                p_level_id number,
                                p_parent_level_id number,
                                p_sr_level_pk varchar2
                               ) return number is

CURSOR c_parent_level_pk IS
select sr_parent_level_pk
from msd_level_associations
where
instance = p_instance_id and
level_id = p_level_id and
parent_level_id = p_parent_level_id and
sr_level_pk = p_sr_level_pk;


l_parent_level_pk       varchar2(240) := NULL;

BEGIN


   OPEN c_parent_level_pk;
   FETCH c_parent_level_pk INTO l_parent_level_pk;
   CLOSE c_parent_level_pk;

   IF (l_parent_level_pk is NULL) then
      return NULL;
   END IF;

   /*  return parent_level_pk only if it contains numeric values only */
   IF ( ltrim(l_parent_level_pk,'.0123456789') is NULL ) THEN
      return to_number(l_parent_level_pk);
   ELSE
      return NULL;
   END IF;

EXCEPTION

    when others then
       return (NULL);
END get_parent_level_pk;

/*******************************************************************

Function : get_child_level_pk

*********************************************************************/

FUNCTION  get_child_level_pk (
                                p_instance_id varchar2,
                                p_level_id number,
                                p_parent_level_id number,
                                p_sr_level_pk varchar2
                               ) return number is

CURSOR c_child_level_pk IS
select sr_level_pk
from msd_level_associations
where
instance = p_instance_id and
level_id = p_level_id and
parent_level_id = p_parent_level_id and
sr_parent_level_pk = p_sr_level_pk and
rownum < 2;


l_child_level_pk       varchar2(240) := NULL;

BEGIN


   OPEN c_child_level_pk;
   FETCH c_child_level_pk INTO l_child_level_pk;
   CLOSE c_child_level_pk;

   IF (l_child_level_pk is NULL) then
      return NULL;
   END IF;

   /*  return child_level_pk only if it contains numeric values only */
   IF ( ltrim(l_child_level_pk,'.0123456789') is NULL ) THEN
      return to_number(l_child_level_pk);
   ELSE
      return NULL;
   END IF;

EXCEPTION

    when others then
       return (NULL);
END get_child_level_pk;


/*******************************************************************

Function : is_global_scenario

Determines whether scenario is passed to ascp as global forecast
or not. Possible return values are :

(1) Y : Global Forecast. Data is published at All Organizations.

(2) N : Local Forecast : Data is published at Organization level.

(3) Null : Data published with Org specific BOM and not Org output level.
           not compatible with ASCP.

Ouput Level *** Org ** All Org ** Other Level ++ No Org Level

Org Spec    *** N   **  Null   **   Null      **   Null

Global      *** Y   **  Y      **    Y        **    Y

No Bom      *** N   **  Y      **    Y        **    Y


*********************************************************************/

FUNCTION is_global_scenario (
                                p_demand_plan_id number,
                                p_scenario_id number,
                                p_use_org_specific_bom_flag varchar2
                               ) return varchar2 is

CURSOR get_org_out_level
IS
select mol.level_id
from msd_dp_scenario_output_levels mol
where
    mol.demand_plan_id = p_demand_plan_id
and mol.scenario_id = p_scenario_id
and mol.level_id = 7;


x_org_level_id varchar2(30);

BEGIN

-- Check output level for scenario
-- Will be null if none defined.

open get_org_out_level;
fetch get_org_out_level into x_org_level_id;
close get_org_out_level;

-- The forecast is only local if global bom is not used
-- and output level is organization.

if ( ((p_use_org_specific_bom_flag = 'Y') or (p_use_org_specific_bom_flag is null))
      and (x_org_level_id = 7)) then
  return 'N';
elsif (p_use_org_specific_bom_flag = 'Y') and (nvl(x_org_level_id, 0) <> 7) then
  return null;
else
  -- if (global bom) or (no bom used and not published at org)
  return 'Y';
end if;

EXCEPTION

    when others then
       return null;
END is_global_scenario;



/*******************************************************************

Function : IS_VALID_PF_EXIST

*********************************************************************/


FUNCTION IS_VALID_PF_EXIST ( p_instance  in  VARCHAR2,
                             p_inventory_item_id in  NUMBER) RETURN NUMBER IS

CURSOR c_count IS
SELECT
1
FROM
msd_level_associations
WHERE
instance = p_instance
and level_id = 1         -- item
and sr_level_pk = p_inventory_item_id
and parent_level_id = 3   -- product family
and sr_parent_level_pk <> '-777';   -- others

l_count NUMBER := 0;

BEGIN

   OPEN c_count;
   FETCH c_count INTO l_count;
   IF c_count%ISOPEN THEN
      CLOSE c_count;
   END IF;

   /*Yes*/
   IF l_count > 0 THEN
      return 1;
   ELSE  /* NO */
      return 2;
   END IF;

EXCEPTION
    when others then
        return NULL;

END IS_VALID_PF_EXIST;



/*******************************************************************

Function : get_end_date

*********************************************************************/

Function get_end_date(
    p_date             in date,
    p_calendar_type    in number,
    p_calendar_code    in varchar2,
    p_bucket_type      in number) return date is

/*
   For BUCKET_TYPE
   -------------------
   9 ----------> DAY
   1 ----------> WEEK
   2 ----------> MONTH
*/
cursor c1 is
select /*+ CACHE */  decode(p_bucket_type, 9, day, 1, week_end_date, month_end_date) from msd_time
where
   calendar_type = p_calendar_type and
   calendar_code = p_calendar_code and
   p_date = day;

l_ret date := NULL;

Begin
   open c1;
   fetch c1 into l_ret;
   close c1;

   return  l_ret;

End get_end_date;


/*******************************************************************
Function : get_lvl_pk_from_tp_id

This function returns level PK for a customer from
PartnerID(tp_id).

*********************************************************************/
Function get_lvl_pk_from_tp_id(
     p_tp_id   in  number,
     p_sr_instance_id    in number) return number is

cursor c_lvl_pk is
select mlv.level_pk
from msc_tp_id_lid mtp, msd_level_values mlv
where
   mtp.tp_id = p_tp_id
   and mtp.sr_instance_id = p_sr_instance_id
   and mtp.partner_type = 2
   and mtp.sr_company_id = -1
   and mtp.sr_instance_id = mlv.instance
   and mtp.sr_tp_id = mlv.sr_level_pk
   and mlv.level_id = 15
   and rownum < 2;

l_lvl_pk   number;

BEGIN

   OPEN c_lvl_pk;
   FETCH c_lvl_pk INTO l_lvl_pk;
   CLOSE c_lvl_pk;

   return l_lvl_pk;

EXCEPTION
    when others then
        return NULL;

END get_lvl_pk_from_tp_id;

/*******************************************************************
Function : get_translated_date

This function is used for time aggregation by DPE when downloading
data from DPS.
*********************************************************************/

  FUNCTION get_translated_date (p_sql in varchar2, p_date in date) return date is

  ldt date;

  Begin
    execute immediate p_sql into ldt using p_date;
    return ldt;
  end get_translated_date;

/*******************************************************************
Function : get_iHelp_URL_prefix

This function is used to build the iHelp URL in DPE by appending the
help topic to the prefix
*********************************************************************/

  function get_iHelp_URL_prefix return varchar2 is

  begin
    return fnd_profile.value('HELP_WEB_AGENT') || '&lang=' || userenv('lang') || '&root=' || fnd_profile.value('HELP_TREE_ROOT') || '&path=' || userenv('lang') || '/MSD/@';
  end get_iHelp_URL_prefix;

/*******************************************************************
Procedure : detach_all_aws

This procedure is used to detach all attached workspaces before
releasing a connection back into the connection pool
*********************************************************************/

  procedure detach_all_aws is
    aw_command varchar2(4000);
  begin
    -- construct dml command
    aw_command := 'shw nafill(filterlines(aw(list) if value eq ''EXPRESS'' then na else joinchars(''aw detach noq '' value '';'')) '' '')';
    aw_command := dbms_lob.substr(dbms_aw_interp(aw_command));
    -- execute detach commands
    dbms_aw_interp_silent(aw_command);
    execute immediate 'begin dbms_aw.shutdown;end;';
  end detach_all_aws;


/*******************************************************************
Fucntion : Get_Conc_Request_Status

This function returns the phase of the concurrent request
*********************************************************************/

function Get_Conc_Request_Status(conc_request_id NUMBER)
return varchar2 is

l_del_req_id NUMBER := conc_request_id;
l_phase VARCHAR2(100);
l_status VARCHAR2(100);
l_dev_status VARCHAR2(100);
l_dev_phase VARCHAR2(100);
l_message VARCHAR2(100);
l_ret_val boolean;

Begin
l_ret_val := fnd_concurrent.get_request_status(l_del_req_id,'','',l_phase,l_status,l_dev_phase,l_dev_status,l_message);
if l_ret_val = TRUE then
  return(l_dev_phase);
else
  return('COMPLETE');
end if;
End Get_Conc_Request_Status;

/* wrappers for dbms_aw package */
FUNCTION DBMS_AW_INTERP(cmd varchar2) RETURN CLOB IS
  v_ret clob;
begin
  execute immediate 'select dbms_aw.interp(:1) from dual' into v_ret using cmd;
  return v_ret;
end DBMS_AW_INTERP;

FUNCTION DBMS_AW_INTERPCLOB(cmd clob) RETURN CLOB IS
  v_ret clob;
begin
  execute immediate 'select dbms_aw.interpclob(:1) from dual' into v_ret using cmd;
  return v_ret;
end DBMS_AW_INTERPCLOB;

PROCEDURE DBMS_AW_INTERP_SILENT(cmd varchar2) IS
begin
  execute immediate 'begin dbms_aw.interp_silent(:1);end;' using cmd;
end DBMS_AW_INTERP_SILENT;

PROCEDURE DBMS_AW_EXECUTE(cmd varchar2) IS
begin
  execute immediate 'begin dbms_aw.execute(:1);end;' using cmd;
end DBMS_AW_EXECUTE;

FUNCTION GET_BUCKET_END_DATE (P_EFFECTIVE_DATE IN DATE,
                              P_OFFSET IN NUMBER,
			      P_TIME_LEVEL_ID IN NUMBER,
			      P_CALENDAR_CODE IN VARCHAR2) RETURN DATE IS

cursor c1 is
select distinct decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date)
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date) = day
and P_EFFECTIVE_DATE between
decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) and day
and P_OFFSET = 1;

cursor c2(p_date date,p_offset number) is
select bucket_date from
(select distinct decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date) bucket_date
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date) = day
and day >= p_date
order by bucket_date)
where rownum <= p_offset;

cursor c3(p_date date,p_offset number) is
select bucket_date from
(select distinct decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date) bucket_date
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date) = day
and day <= p_date
order by bucket_date desc)
where rownum <= abs(p_offset);


l_return_date DATE := P_EFFECTIVE_DATE;

BEGIN

  if p_offset = 1 then

  open c1;
  fetch c1 into l_return_date;
  close c1;

  elsif p_offset > 1 then

    for i in c2(p_effective_date,p_offset) loop
      l_return_date := i.bucket_date;
    end loop;

  elsif p_offset < 0 then

    for i in c3(p_effective_date,p_offset) loop
      l_return_date := i.bucket_date;
    end loop;

  end if;


return l_return_date;

exception
  when others then
    l_return_date := P_EFFECTIVE_DATE;
    return l_return_date;

END GET_BUCKET_END_DATE;


FUNCTION GET_BUCKET_START_DATE (P_EFFECTIVE_DATE IN DATE,
                              P_OFFSET IN NUMBER,
			      P_TIME_LEVEL_ID IN NUMBER,
			      P_CALENDAR_CODE IN VARCHAR2) RETURN DATE IS

cursor c1 is
select distinct decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date)
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) = day
and P_EFFECTIVE_DATE between day and
decode(P_TIME_LEVEL_ID,
1,week_end_date,
2,month_end_date,
3,month_end_date,
4,quarter_end_date,
5,year_end_date,
6,month_end_date,
7,quarter_end_date,
8,year_end_date,
10,week_end_date,
11,month_end_date,
12,quarter_end_date,
13,year_end_date)
and P_OFFSET = 1;

cursor c2(p_date date,p_offset number) is
select bucket_date from
(select distinct decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) bucket_date
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) = day
and day >= p_date
order by bucket_date)
where rownum <= p_offset;

cursor c3(p_date date,p_offset number) is
select bucket_date from
(select distinct decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) bucket_date
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) = day
and day <= p_date
order by bucket_date desc)
where rownum <= abs(p_offset);


l_return_date DATE := P_EFFECTIVE_DATE;

BEGIN

  if p_offset = 1 then

  open c1;
  fetch c1 into l_return_date;
  close c1;

  elsif p_offset > 1 then

    for i in c2(p_effective_date,p_offset-1) loop
      l_return_date := i.bucket_date;
    end loop;

  elsif p_offset < 0 then

    for i in c3(p_effective_date,p_offset-1) loop
      l_return_date := i.bucket_date;
    end loop;

  end if;


return l_return_date;

exception
  when others then
    l_return_date := P_EFFECTIVE_DATE;
    return l_return_date;

END GET_BUCKET_START_DATE;


FUNCTION GET_AGE_IN_BUCKETS(P_START_DATE IN DATE,
                            P_END_DATE IN DATE,
			    P_TIME_LEVEL_ID IN NUMBER,
                            P_CALENDAR_CODE IN VARCHAR2) RETURN NUMBER IS

l_age NUMBER := 0;

cursor c1 is
select count(distinct decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date))
from msd_time
where calendar_type = decode(P_TIME_LEVEL_ID,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4)
and calendar_code = P_CALENDAR_CODE
and decode(P_TIME_LEVEL_ID,
1,week_start_date,
2,month_start_date,
3,month_start_date,
4,quarter_start_date,
5,year_start_date,
6,month_start_date,
7,quarter_start_date,
8,year_start_date,
10,week_start_date,
11,month_start_date,
12,quarter_start_date,
13,year_start_date) = day
and day between P_START_DATE and P_END_DATE;


BEGIN

  open c1;
  fetch c1 into l_age;
  close c1;

return l_age;

exception
  when others then
    l_age := 0;
    return l_age;

END GET_AGE_IN_BUCKETS;

FUNCTION GET_SR_LEVEL_PK(P_INSTANCE_ID IN NUMBER, P_LEVEL_ID IN NUMBER, P_LEVEL_PK IN NUMBER, P_LEVEL_VALUE OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

cursor c1 is
select sr_level_pk, level_value
from msd_level_values
where instance = P_INSTANCE_ID
and level_id = P_LEVEL_ID
and level_pk = P_LEVEL_PK;

l_level_value VARCHAR2(200);
l_sr_level_pk VARCHAR2(200);

BEGIN

  open c1;
  fetch c1 into l_sr_level_pk,l_level_value;
  close c1;

  return l_sr_level_pk;

END GET_SR_LEVEL_PK;

function get_dp_enabled_flag (
                        p_instance_id   IN  NUMBER,
                        p_sr_key        IN  VARCHAR2,
                        p_val           IN  VARCHAR2,
                        p_level_id      IN  NUMBER
                     ) return number IS

l_ret NUMBER;
  l_def_level_id number:=28;
BEGIN
if p_val is NULL then
  select dp_enabled_flag
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and p_sr_key = sr_level_pk
  and level_id = nvl(p_level_id, l_def_level_id);
 else
  select dp_enabled_flag
  into l_ret
  from msd_level_values
  where instance = p_instance_id
  and level_value = p_val
  and level_id = nvl(p_level_id, l_def_level_id);
 end if;
 return l_ret;
EXCEPTION when others then return NULL;

END get_dp_enabled_flag;


procedure dp_log(plan_id number, msg varchar2, msg_type varchar2) IS
  script varchar2(4000);
begin
  script := 'aw attach odpcode ro;call dp.log('''||msg||''' '''||msg_type||''' NA NA '''||plan_id||''')';

  dbms_aw_interp_silent(script);

  exception
    when others then
      null;
end dp_log;

/*Bug#4249928 */
Function get_system_attribute1_desc(p_lookup_code in varchar2)
return varchar2
is
	l_system_attribute1 varchar2(240);
begin
	select 	meaning into l_system_attribute1
	from 	fnd_lookup_values_vl
	where
		LOOKUP_TYPE='MSD_LEVEL_VALUE_DESC' and
		LOOKUP_CODE= p_lookup_code;
return 	l_system_attribute1;
end get_system_attribute1_desc;

Function EFFEC_AUTH( P_period_start_date date
                                     ,p_period_end_date date
                                     ,p_supplier_id number
                                     ,p_sr_instance_id number
                                     ,p_organization_id number
                                     ,p_inventory_item_id number
                                     ,p_supplier_site_id number
                                     ,p_demand_plan_id number)
return number
is
	l_auth_percent number;
begin
      select sum(mad.PERCENTAGE_PURCHASE_PRICE)/((p_period_end_date - p_period_start_date +1 )*100) into l_auth_percent
      from MSC_ASL_AUTH_DETAILS mad,
           msd_time mt,
           msd_demand_plans mdp
      where       p_supplier_id = mad.supplier_id and
                  p_sr_instance_id = mad.sr_instance_id and
                  p_organization_id = mad.organization_id and
                  p_inventory_item_id = mad.inventory_item_id and
                  p_supplier_site_id = mad.supplier_site_id and
                  mdp.demand_plan_id = p_demand_plan_id and
                  mt.day between trunc(mdp.plan_start_date+mad.start_days) and trunc(mdp.plan_START_date+mad.end_days) and
                  mt.calendar_code='GREGORIAN'and
                  mt.calendar_type=1 and
                  mt.day between p_period_start_date and p_period_end_date ;
      return l_auth_percent;
end;


END MSD_COMMON_UTILITIES ;

/
