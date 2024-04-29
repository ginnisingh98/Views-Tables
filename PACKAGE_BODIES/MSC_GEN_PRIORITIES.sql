--------------------------------------------------------
--  DDL for Package Body MSC_GEN_PRIORITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GEN_PRIORITIES" AS
/* $Header: MSCPRIRB.pls 120.3 2007/01/17 19:34:28 hulu ship $  */

 Procedure gen_priorities(
                     p_rule_set_id in number) is

  CURSOR dmd_type_c IS
 select d_type.priority  type_pri,
        nvl(d_class.priority,d_type.priority)  class_pri,
        d_type.demand_type,
        nvl(d_class.demand_class, d_type.demand_class) demand_class
   from msc_drp_pri_rules_specified d_type,
        msc_drp_pri_rules_specified d_class
   where d_type.rule_set_id = p_rule_set_id
     and d_type.rule_type =1 -- demand type
     and d_type.rule_set_id = d_class.rule_set_id (+)
     and d_class.rule_type(+) =2 -- demand class
     and not exists (select 1
               from  msc_drp_pri_rules_specified
               where rule_type = 3 -- demand type-demand class
               and   rule_set_id = d_type.rule_set_id
               and   demand_type = d_type.demand_type
               and   demand_class = d_class.demand_class)
 union select  d_type.priority  type_pri,
        d_type.priority  class_pri,
        d_type.demand_type,
        d_type.demand_class
   from msc_drp_pri_rules_specified d_type
   where d_type.rule_set_id = p_rule_set_id
     and d_type.rule_type =3
 union select d_type.priority type_pri,
              999 class_pri,
              d_type.demand_type, '-1'
  from msc_drp_pri_rules_specified d_type
   where d_type.rule_set_id = p_rule_set_id
     and d_type.rule_type =1
     and exists (select 1
               from  msc_drp_pri_rules_specified
               where rule_type = 2
               and   rule_set_id = d_type.rule_set_id)
     and not exists (select 1
               from  msc_drp_pri_rules_specified
               where rule_type = 2
               and   rule_set_id = d_type.rule_set_id
               and   demand_class = '-1')
     and not exists (select 1
               from  msc_drp_pri_rules_specified
               where rule_type = 3 -- demand type-demand class
               and   rule_set_id = d_type.rule_set_id
               and   demand_type = d_type.demand_type
               and   demand_class = '-1')
union select d_class.priority  type_pri, --5762540,
        d_class.priority class_pri,      -- when FC, SO, OverConsumed is not
        d_type.demand_type,              -- defined in demand_type,
        d_class.demand_class demand_class  -- but in demand_type/demand_class
   from msc_drp_pri_rules_specified d_type,
        msc_drp_pri_rules_specified d_class
   where d_type.rule_set_id = p_rule_set_id
     and d_type.rule_type =3 -- demand type-demand class
     and d_type.rule_set_id = d_class.rule_set_id
     and d_class.rule_type =2 -- demand class
     and d_type.demand_class <> d_class.demand_class
     and not exists (select 1
                 from  msc_drp_pri_rules_specified
               where rule_type = 1 -- demand type
               and   rule_set_id = d_type.rule_set_id
               and   demand_type = d_type.demand_type)
  order by type_pri, class_pri;

 l_user_id number := fnd_global.user_id;
 v_priority number :=0;
 v_dmd_type_rec dmd_type_c%ROWTYPE;
 v_prev_type_pri number := 0;
 v_prev_class_pri number := 0;
begin

   delete msc_drp_pri_rules_calc
   where rule_set_id = p_rule_set_id;

   Open dmd_type_c;
   LOOP
    Fetch dmd_type_c Into v_dmd_type_rec;
    EXIT when dmd_type_c%NOTFOUND;
          if v_dmd_type_rec.type_pri <> v_prev_type_pri or
             v_dmd_type_rec.class_pri <> v_prev_class_pri then
             v_priority := v_priority+1;
          end if;
--dbms_output.put_line('v_priority='||v_priority||','||v_dmd_type_rec.demand_class||','||v_dmd_type_rec.demand_type);
          insert into msc_drp_pri_rules_calc
          (
          rule_set_id,
          demand_type,
          demand_class,
          priority,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login
          )
          values(
          p_rule_set_id,
          v_dmd_type_rec.demand_type,
          v_dmd_type_rec.demand_class,
          v_priority,
          sysdate,
          l_user_id,
          sysdate,
          l_user_id,
          l_user_id
          );
          v_prev_type_pri := v_dmd_type_rec.type_pri;
          v_prev_class_pri := v_dmd_type_rec.class_pri;

    END LOOP;
    CLOSE dmd_type_c;

    -- add safety stock,
    for a in 4..6 loop
       v_priority := v_priority +1;
       insert into msc_drp_pri_rules_calc
       (
       rule_set_id,
       demand_type,
       demand_class,
       priority,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login
       )
       values(
       p_rule_set_id,
       a,
       '-1',
       v_priority,
       sysdate,
       l_user_id,
       sysdate,
       l_user_id,
       l_user_id
       );

    end loop;
end gen_priorities;

FUNCTION all_defined(p_rule_set_id in number) return boolean IS

  p_rule_type number;
  p_demand_type number;
  cursor defined_types_c is
   select demand_type, demand_class
     from msc_drp_pri_rules_specified
    where rule_set_id = p_rule_set_id
      and rule_type = p_rule_type
      and demand_type = nvl(p_demand_type, demand_type)
    order by demand_type, demand_class;

    v_dmd_type number;
    v_dmd_class varchar2(100);
    v_cum varchar2(10);
BEGIN
/* rule type
         1 Demand Type
         2 Demand Class
         3 Demand Type - Demand Class

   demand type
         1 Sales Orders
         2 Over-Consumed Sales Orders
         3 Forecast
*/

/* return true if
   a. rule_type =1 and all three demand type defined, or
   b. rule_type = 3 and all other demand class defined
*/

    p_rule_type := 1;  -- Demand Type
    OPEN defined_types_c;
    LOOP
       FETCH defined_types_c INTO v_dmd_type, v_dmd_class;
       EXIT WHEN defined_types_c%NOTFOUND;
          v_cum := v_cum||v_dmd_type;
    END LOOP;
    CLOSE defined_types_c;
    FOR a in 1..3 LOOP
       IF instr(v_cum, a) <= 0 then
          -- no dmd type rule defined for dmd type a
          -- for dmd type - class rule type, need to have all other dmd class
          p_rule_type := 3;  -- Demand Type -  Demand Class
          p_demand_type := a;
          OPEN defined_types_c;
          LOOP
            FETCH defined_types_c INTO v_dmd_type, v_dmd_class;
            EXIT WHEN defined_types_c%NOTFOUND;
              if v_dmd_class = '-1' then -- all other
                 v_cum := v_cum ||a;
                 exit;
              end if;
          END LOOP;
          CLOSE defined_types_c;
       END IF; -- IF instr(v_cum, a) <= 0 then
    END LOOP; -- FOR a in 1..3 LOOP

    if v_cum is null then
       -- only rule_type 2 is defined
       return false;
    end if;

    FOR a in 1..3 LOOP
       IF instr(v_cum, a) <= 0 then
          -- still no demand type defined
          return false;
       END IF;
    END LOOP;

    -- v_cum has all three dmd types
    return true;

END all_defined;

end msc_gen_priorities;

/
