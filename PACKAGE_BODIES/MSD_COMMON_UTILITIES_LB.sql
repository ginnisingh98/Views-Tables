--------------------------------------------------------
--  DDL for Package Body MSD_COMMON_UTILITIES_LB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COMMON_UTILITIES_LB" AS
/* $Header: msdculbb.pls 120.0 2005/05/25 19:56:47 appldev noship $ */


/* Public Functions */
/* This function returns the  level_pk for a level value*/

function get_level_pk( p_level_id IN NUMBER, p_sr_level_pk IN VARCHAR2 ) return number Is

CURSOR c_level_pk
IS
select level_pk
from
msd_level_values_lb
where
level_id = p_level_id
and sr_level_pk = p_sr_level_pk ;

x_level_pk number ;

Begin

   OPEN c_level_pk ;
   FETCH c_level_pk  INTO x_level_pk;
   CLOSE c_level_pk ;


  if x_level_pk is null then
  select msd_level_values_s.nextval into x_level_pk
  from   sys.dual ;
  end if ;

  return x_level_pk;

  exception
  when others then
  fnd_file.put_line(fnd_file.log,SQLERRM);
  return null ;


end get_level_pk ;

/* This function returns the demad_plan_id for a given supply plan*/

FUNCTION get_demand_plan_id( p_plan_id IN NUMBER) return NUMBER
IS
CURSOR c_demand_plan_id
is
select demand_plan_id
from
msd_demand_plans
where
liab_plan_id = p_plan_id ;

x_demand_plan_id  NUMBER ;

Begin
   OPEN c_demand_plan_id  ;
   FETCH c_demand_plan_id   INTO x_demand_plan_id;
   CLOSE c_demand_plan_id  ;

   return x_demand_plan_id ;
END get_demand_plan_id ;


/* This  function returns the  supply_plan_id for a given demand plan id */

FUNCTION get_supply_plan_id( p_demand_plan_id IN NUMBER) return NUMBER
IS
CURSOR c_supply_plan_id
is
select liab_plan_id
from
msd_demand_plans
where
demand_plan_id = p_demand_plan_id ;

x_supply_plan_id  NUMBER ;

Begin
   OPEN c_supply_plan_id  ;
   FETCH c_supply_plan_id    INTO x_supply_plan_id;
   CLOSE c_supply_plan_id  ;

   return x_supply_plan_id ;
END get_supply_plan_id ;




/* This function returns the item category name for the given item */





FUNCTION get_item_cat_name( p_inventory_item_id IN NUMBER, p_category_set_id IN NUMBER ) RETURN VARCHAR2
IS

CURSOR c_category_name
IS
select  mic.category_name
from msc_item_categories mic ,
MSC_TRADING_PARTNERS mtp
where
mtp.partner_type = 3
and mtp.sr_tp_id = mtp.master_organization
and mtp.sr_tp_id = mic.organization_id
and mic.inventory_item_id = p_inventory_item_id
and mic.category_set_id = p_category_set_id
and mic.sr_instance_id = mtp.sr_instance_id
order by mic.category_name ;

x_category_name VARCHAR2(100) ;

BEGIN
   OPEN c_category_name   ;
   FETCH c_category_name  INTO x_category_name ;
   CLOSE c_category_name   ;

   IF x_category_name is null then return MSD_SR_UTIL.get_null_desc ;
   end if ;

   return  x_category_name ;

END  get_item_cat_name ;



/* This function returns the item category description for the given item */


FUNCTION get_item_cat_desc( p_inventory_item_id IN NUMBER, p_category_set_id IN NUMBER ) RETURN VARCHAR2
IS

CURSOR c_category_desc
IS
select  mic.description
from msc_item_categories mic ,
MSC_TRADING_PARTNERS mtp
where
mtp.partner_type = 3
and mtp.sr_tp_id = mtp.master_organization
and mtp.sr_tp_id = mic.organization_id
and mic.inventory_item_id = p_inventory_item_id
and mic.category_set_id = p_category_set_id
and mic.sr_instance_id = mtp.sr_instance_id
order by mic.category_name ;

x_category_desc  VARCHAR2(100) ;

BEGIN
   OPEN c_category_desc   ;
   FETCH c_category_desc  INTO x_category_desc ;
   CLOSE c_category_desc   ;

   IF x_category_desc  is null then return MSD_SR_UTIL.get_null_desc ;
   end if ;

   return  x_category_desc ;

END  get_item_cat_desc  ;

/* This function returns the supply_plan_start_date */

FUNCTION get_supply_plan_start_date( p_plan_id IN NUMBER) return DATE
IS
CURSOR c_plan_start_date
is
select start_date
from msc_plans
where
plan_id = p_plan_id ;

x_plan_start_date DATE ;

Begin
   OPEN  c_plan_start_date  ;
   FETCH  c_plan_start_date   INTO x_plan_start_date;
   CLOSE c_plan_start_date  ;

   IF x_plan_start_date IS NULL AND p_plan_id = -1 THEN return SYSDATE ;
   END IF ;
   return x_plan_start_date ;
END get_supply_plan_start_date ;



/* This function returns the supply_plan_end_date */

FUNCTION get_supply_plan_end_date( p_plan_id IN NUMBER) return DATE
IS
CURSOR c_plan_end_date
is
select cutoff_date
from msc_plans
where
plan_id = p_plan_id ;

x_plan_end_date DATE ;

Begin
   OPEN  c_plan_end_date  ;
   FETCH  c_plan_end_date   INTO x_plan_end_date;
   CLOSE c_plan_end_date  ;

   return x_plan_end_date ;
END get_supply_plan_end_date ;

/* This function returns the supply_plan name  */

FUNCTION get_supply_plan_name( p_plan_id IN NUMBER) return VARCHAR2
IS
CURSOR c_plan_name
is
select compile_designator
from msc_plans
where
plan_id = p_plan_id ;

x_plan_name VARCHAR2( 100) ;

Begin
   OPEN  c_plan_name  ;
   FETCH c_plan_name   INTO x_plan_name;
   CLOSE c_plan_name  ;



   IF p_plan_id = -1 THEN RETURN FND_MESSAGE.get_string('MSC', 'MSC_COLLAB_LIAB') ;
   /* This needs to be made translatable */
   END IF ;
   return x_plan_name;
END get_supply_plan_name ;

/* This function returns end date for CP Plan */

FUNCTION get_cp_end_date  return DATE
    IS
  CURSOR c_input_params IS
        SELECT
        distinct
        mdpar.parameter_type ,
        mcd.planning_server_view_name ,
        mcd.description
        FROM   msd_dp_parameters mdpar ,
               msd_cs_definitions mcd,
               msd_demand_plans mdp,
	       msd_cs_defn_dim_dtls mcddd
        where mdpar.demand_plan_id =mdp.demand_plan_id
        and mdp.demand_plan_name = 'LIABILTY_PLAN'
        and mdp.template_flag = 'Y'
        and mdpar.parameter_type =mcd.name
	and mcd.cs_definition_id = mcddd.cs_definition_id
	and mcddd.dimension_code = 'TIM'
	and nvl( mcd.planning_server_view_name, 'NA')  <> 'NA'
	and nvl(mcd.liability_user_flag , 'N') <> 'Y' ;




  TYPE c_stream_typ IS REF CURSOR;
  c_stream         c_stream_typ;  -- declare cursor variabl

  x_max_date DATE ;
  x_cp_liab_end_date DATE  ;
  v_sql_stmt VARCHAR2(200) ;
  x_collab_liab VARCHAR2(200) ;


  BEGIN
  select sysdate into x_cp_liab_end_date from dual ;

   for x_input_param_rec  in c_input_params

   loop

   x_collab_liab := FND_MESSAGE.get_string('MSC', 'MSC_COLLAB_LIAB') ;

   v_sql_stmt := 'select max(end_date) from  '|| x_input_param_rec.planning_server_view_name|| '  where cs_name  = '||''''||x_collab_liab||''''  ;

   fnd_file.put_line(fnd_file.log ,  v_sql_stmt );

    OPEN  c_stream FOR  v_sql_stmt;
    FETCH c_stream  INTO x_max_date;
    CLOSE c_stream;


   IF x_max_date > x_cp_liab_end_date THEN   x_cp_liab_end_date := x_max_date ;

   END IF ;


   end loop ;

   RETURN x_cp_liab_end_date  ;

   END get_cp_end_date ;

/* Returns the plan owning org */

FUNCTION get_plan_owning_org( p_plan_id IN NUMBER) return NUMBER
IS
CURSOR c_plan_owning_org
is
select md.organization_id
from
msc_designators md,
msc_plans mp
where
md.designator = mp.compile_designator
and mp.plan_id = p_plan_id ;

x_organization_id NUMBER ;
Begin
    IF p_plan_id = -1 THEN RETURN -1  ;
      END IF ;
   OPEN  c_plan_owning_org  ;
   FETCH c_plan_owning_org   INTO x_organization_id;
   CLOSE c_plan_owning_org  ;

   return x_organization_id ;




END get_plan_owning_org ;

/* Returns the plan owing instance of the supply plan */

FUNCTION get_plan_owning_instance( p_plan_id IN NUMBER) return NUMBER
IS
CURSOR c_plan_owning_instance
is
select md.sr_instance_id
from
msc_designators md ,
msc_plans mp
where
md.designator = mp.compile_designator
and mp.plan_id = p_plan_id ;

x_sr_instance_id NUMBER ;
Begin
    IF p_plan_id = -1 THEN RETURN -1  ;
    END IF ;
   OPEN  c_plan_owning_instance  ;
   FETCH c_plan_owning_instance   INTO x_sr_instance_id ;
   CLOSE c_plan_owning_instance  ;

   return x_sr_instance_id ;



END get_plan_owning_instance ;


/* This api is called by DPE to update the details of  the previous liability */

procedure  liability_post_process( p_demand_plan_id IN NUMBER ,
                                 p_scenario_name IN VARCHAR2 ,
                                 p_senario_rev_num IN NUMBER)


IS
CURSOR c_demand_plan
IS
select
mdp.demand_plan_id ,
mdp.plan_start_date ,
mds.scenario_id
from
msd_demand_plans mdp ,
msd_dp_scenarios  mds
where mdp.demand_plan_id = p_demand_plan_id
and mdp.demand_plan_id = mds.demand_plan_id
and mds.SCENARIO_DESIGNATOR = 'TOTAL_LIABILITY'
and mdp.plan_type = 'LIABILITY';


BEGIN

     for x_demand_plan_rec  in c_demand_plan
     LOOP

     /*
      UPDATE msd_demand_plans SET liability_revision_num =  p_senario_rev_num ,
       prev_liab_pub_plan_start_date =  x_demand_plan_rec.plan_start_date
      WHERE demand_plan_id =  p_demand_plan_id ;
      */

      UPDATE MSD_DP_SCENARIO_REVISIONS SET  plan_start_date = x_demand_plan_rec.plan_start_date
      WHERE demand_plan_id = p_demand_plan_id and revision = p_senario_rev_num
      and scenario_id = x_demand_plan_rec.scenario_id   ;
     /*
      fnd_file.put_line(fnd_file.log , 'LIABILITY POST PROCESS' );
      fnd_file.put_line(fnd_file.log ,  p_scenario_name );
      fnd_file.put_line(fnd_file.log , p_senario_rev_num );
     */
     END LOOP ;

     --RETURN 1 ;

    commit ;


END ;


/* Updates supply plan dates in msd demand Plans */

FUNCTION liability_plan_update( p_demand_plan_id IN NUMBER )
RETURN NUMBER
IS
CURSOR c_demand_plan
IS
select
mds.scenario_id
from
msd_demand_plans mdp ,
msd_dp_scenarios  mds
where mdp.demand_plan_id = p_demand_plan_id
and mdp.demand_plan_id = mds.demand_plan_id
and mds.SCENARIO_DESIGNATOR = 'TOTAL_LIABILITY' /*  This will be translatable */
and mdp.plan_type = 'LIABILITY';



CURSOR c_liability_rev_num(  p_scenario_id IN NUMBER)
is
select
max(revision),
plan_start_date
from
MSD_DP_SCENARIO_REVISIONS
where
demand_plan_id = p_demand_plan_id
and scenario_id = p_scenario_id
group by
plan_start_date
;

x_plan_start_date DATE ;
x_rev_num NUMBER ;
x_scenario_id  NUMBER ;



BEGIN


     OPEN c_demand_plan ;
     FETCH c_demand_plan INTO x_scenario_id  ;
     CLOSE c_demand_plan ;

     OPEN c_liability_rev_num( x_scenario_id) ;
     FETCH c_liability_rev_num into x_rev_num , x_plan_start_date  ;
     CLOSE c_liability_rev_num ;

      UPDATE msd_demand_plans SET previous_plan_start_date =  x_plan_start_date , LIABILITY_REVISION_NUM = x_rev_num
      WHERE  demand_plan_id = p_demand_plan_id ;




     /*

     for x_demand_plan_rec  in c_demand_plan
     LOOP

      x_plan_start_date :=  get_supply_plan_start_date( x_demand_plan_rec.LIAB_PLAN_ID ) ;
      IF x_plan_start_date   > x_demand_plan_rec.plan_start_date  THEN
          UPDATE msd_demand_plans SET previous_plan_start_date = x_demand_plan_rec.prev_liab_pub_plan_start_date
          WHERE  demand_plan_id = p_demand_plan_id ;
        END IF ;

       IF x_plan_start_date   = x_demand_plan_rec.prev_liab_pub_plan_start_date  THEN

          OPEN c_liability_rev_num(  x_demand_plan_rec.previous_plan_start_date ,x_demand_plan_rec.scenario_id) ;
          FETCH c_liability_rev_num into x_rev_num ;
          CLOSE c_liability_rev_num ;


          UPDATE msd_demand_plans SET prev_liab_pub_plan_start_date = x_demand_plan_rec.previous_plan_start_date
          WHERE  demand_plan_id = p_demand_plan_id ;

         END IF ;


     END LOOP ;
     */

     RETURN 1 ;

 END liability_plan_update ;

 /* Return default mfg CAL */

FUNCTION get_default_mfg_cal ( p_org_id IN NUMBER , p_instance_id IN  NUMBER) RETURN VARCHAR2

IS
CURSOR c_calendar
IS
select calendar_code from
msc_trading_partners
where partner_type = 3
and sr_instance_id = p_instance_id
and sr_tp_id = p_org_id ;

x_cal_code VARCHAR2(200) ;


BEGIN

    OPEN c_calendar ;
    FETCH c_calendar into x_cal_code ;
    CLOSE c_calendar ;

    return x_cal_code ;

 END ;


FUNCTION get_default_uom  RETURN VARCHAR2

IS
CURSOR c_uom
IS
select
uom_code
 from msc_uom_conversions
 where upper(uom_code) = 'EA' and rownum = 1 ;

x_uom  VARCHAR2(200) ;


BEGIN

    x_uom :=  FND_PROFILE.Value('MSC_LIABILITY_BASE_UOM')  ;

  IF x_uom is NULL THEN
    OPEN c_uom;
    FETCH c_uom  into x_uom  ;
    CLOSE c_uom ;
  END IF ;

  return x_uom  ;

END ;


/*

  This function returns the URL to launch the specific liability plan for certain user responsibility.

  There are two arguments:

    p_plan_id: ASCP Plan ID or -1 for CP Plan

    p_function_id MSD_DP_ADMIN_SSA, MSD_DP_MGR_SSA or MSD_DP_PLANNER_SSA for different responsibilties

*/



function get_liability_url(p_plan_id IN NUMBER ,

                           p_function_id IN VARCHAR2)

RETURN VARCHAR2



IS



CURSOR c_plan_url (p_demand_plan_id IN NUMBER)

IS

select

fnd_profile.value('APPS_SERVLET_AGENT') ||

'/oowa/aw92/'||

'dbapps.xwdevkit/xwd_init?apps.' ||

nvl(fnd_profile.value('MSD_CODE_AW'),'ODPCODE') ||

'/dp.init.shell?' ||

'/IDF=' || p_function_id ||

'/PLAN_TYPE=LIABILITY' ||

'/ID=' || p_demand_plan_id ||

'/SHR=MSD' || p_demand_plan_id ||

'/UID=' || fnd_global.user_id ||

'/RID=' || fnd_global.resp_id ||

'/RAID=' || fnd_global.resp_appl_id

from dual ;



x_demand_plan_id NUMBER ;

/* This varchar2 was changed from 200 to 400 to take care of CP issue */
x_plan_url VARCHAR2(400) ;




BEGIN



     x_demand_plan_id := msd_common_utilities_lb.get_demand_plan_id(p_plan_id) ;



     OPEN c_plan_url (x_demand_plan_id) ;

     FETCH c_plan_url  INTO x_plan_url ;

     CLOSE c_plan_url ;



     RETURN x_plan_url ;



END get_liability_url ;

/* This function populates MSC_ASL_AUTH_DETAILS with start date and end date */

procedure liability_preprocessor(p_plan_id IN NUMBER )

IS

CURSOR c_sup_item_org is
select
SUPPLIER_ID,
SUPPLIER_SITE_ID ,
ORGANIZATION_ID ,
SR_INSTANCE_ID,
INVENTORY_ITEM_ID,
AUTHORIZATION_CODE,
cutoff_days,
INCLUDE_LIABILITY_AGREEMENT,
ASL_LIABILITY_AGREEMENT_BASIS
from
msc_asl_auth_details
where
plan_id = -1
/* and INCLUDE_LIABILITY_AGREEMENT = 1   This filter will remove any disabled agreement */
order
by
SR_INSTANCE_ID,
SUPPLIER_ID,
SUPPLIER_SITE_ID,
ORGANIZATION_ID,
INVENTORY_ITEM_ID,
TRANSACTION_ID ;

x_start_days  NUMBER ;
x_end_days NUMBER ;
x_prv_end_days NUMBER ;
x_supplier_id NUMBER ;
x_organization_id NUMBER ;
x_inventory_item_id NUMBER ;
x_sr_instance_id   NUMBER ;
x_prv_supplier_id NUMBER ;
x_prv_organization_id NUMBER ;
x_prv_inventory_item_id NUMBER ;
x_prv_sr_instance_id   NUMBER ;

BEGIN

x_prv_end_days := 0  ;
x_end_days := 0 ;

UPDATE   msc_item_suppliers
set  INCLUDE_LIABILITY_AGREEMENT = NULL ,
ASL_LIABILITY_AGREEMENT_BASIS =NULL
where
plan_id = p_plan_id ;
--and plan_id <> -1 ;

commit ;


FOR x_sup_item_org  in c_sup_item_org

LOOP

IF  (nvl(x_prv_supplier_id, x_sup_item_org.supplier_id )   <> x_sup_item_org.supplier_id) or
   ( nvl( x_prv_organization_id , x_organization_id )  <>  x_sup_item_org.organization_id ) or
   (nvl(x_prv_sr_instance_id  ,x_sr_instance_id) <> x_sup_item_org.sr_instance_id )or
   ( nvl( x_prv_inventory_item_id , x_inventory_item_id ) <> x_sup_item_org.inventory_item_id)

 THEN

 x_prv_end_days  := 0 ;
 x_end_days := 0 ;
 end if ;


 UPDATE msc_asl_auth_details
 set start_days = x_end_days  ,
       end_days =  x_end_days + cutoff_days
  where
 PLAN_ID  = -1 and
SUPPLIER_ID  = x_sup_item_org.SUPPLIER_ID and
SUPPLIER_SITE_ID = x_sup_item_org.SUPPLIER_SITE_ID and
ORGANIZATION_ID  = x_sup_item_org.ORGANIZATION_ID and
SR_INSTANCE_ID = x_sup_item_org.SR_INSTANCE_ID and
INVENTORY_ITEM_ID = x_sup_item_org.INVENTORY_ITEM_ID and
AUTHORIZATION_CODE  = x_sup_item_org.AUTHORIZATION_CODE ;

 x_end_days  := x_sup_item_org.cutoff_days +  x_prv_end_days  ;

x_prv_supplier_id := x_sup_item_org.supplier_id ;
x_prv_organization_id :=  x_sup_item_org. organization_id ;
x_prv_sr_instance_id  :=   x_sup_item_org.sr_instance_id ;
x_prv_inventory_item_id :=   x_sup_item_org.inventory_item_id ;
 x_prv_end_days  := x_end_days ;




UPDATE   msc_item_suppliers
set  INCLUDE_LIABILITY_AGREEMENT = x_sup_item_org. INCLUDE_LIABILITY_AGREEMENT ,
ASL_LIABILITY_AGREEMENT_BASIS = x_sup_item_org.ASL_LIABILITY_AGREEMENT_BASIS
where
SUPPLIER_ID  = x_sup_item_org.SUPPLIER_ID and
SUPPLIER_SITE_ID = x_sup_item_org.SUPPLIER_SITE_ID and
ORGANIZATION_ID  = x_sup_item_org.ORGANIZATION_ID and
SR_INSTANCE_ID = x_sup_item_org.SR_INSTANCE_ID and
INVENTORY_ITEM_ID = x_sup_item_org.INVENTORY_ITEM_ID and
plan_id = p_plan_id  ;
--and plan_id <> -1 ;

commit ;

END LOOP ;

commit ;

END liability_preprocessor ;

function get_base_uom(p_item_id in number, p_dp_plan_id in number) return varchar2 IS

x_base_uom varchar2(30);
cursor c1 is
  select msi2.uom_code
    from msc_system_items msi,
         msc_system_items msi2,
         msc_trading_partners mtp
   where msi2.organization_id = mtp.master_organization
     and msi.organization_id = mtp.sr_tp_id
     and msi.sr_instance_id = mtp.sr_instance_id
     and msi.inventory_item_id = msi2.inventory_item_id
     and msi2.plan_id = -1
     and msi.inventory_item_id = p_item_id
     and msi.plan_id = p_dp_plan_id
     order by msi.sr_instance_id, msi.organization_id desc;



BEGIN


 open c1;
  fetch c1 into x_base_uom;
 close c1;

 return x_base_uom;



EXCEPTION when others then return NULL;



END get_base_uom;

/* This function is used by ASCP UI to decide  whether a liability plan exists for an ASCP Plan*/
/* This function return 1 if the plan exists else return 2 */
 function liability_plan_exists(p_plan_id IN NUMBER ) return boolean   IS
 x_status  NUMBER ;
 cursor c_status
 is
 select 1 from msd_demand_plans
                                  where liab_plan_id = p_plan_id
                                  and nvl( DP_BUILD_ERROR_FLAG, 'NO')  = 'NO'
                                  and plan_type = 'LIABILITY' ;
 BEGIN
 open  c_status ;
 fetch c_status into x_status  ;
 close c_status ;
 if x_status = 1 then return TRUE ;
 end if ;
 return FALSE  ;
 EXCEPTION when others then return NULL;
 END liability_plan_exists ;






END MSD_COMMON_UTILITIES_LB ;

/
