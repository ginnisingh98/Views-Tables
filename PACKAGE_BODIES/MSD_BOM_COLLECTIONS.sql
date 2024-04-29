--------------------------------------------------------
--  DDL for Package Body MSD_BOM_COLLECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_BOM_COLLECTIONS" AS
/* $Header: msdbmclb.pls 120.2 2006/03/02 00:51:32 brampall noship $ */
/* Declare Private Procedures */

/* Bom Item Types */
C_MODEL          Constant NUMBER := 1;
C_OPTION_CLASS   Constant NUMBER := 2;
C_PLANNING       Constant NUMBER := 3;
C_STANDARD       Constant NUMBER := 4;
C_PRODUCT_FAMILY Constant NUMBER := 5;

/* ATO Forecast Control Options */
C_CONSUME        Constant NUMBER := 1;
C_CONSUME_DERIVE Constant NUMBER := 2;
C_NONE           Constant NUMBER := 3;

/* MRP Planning Codes */
C_NO_PLANNING    Constant NUMBER := 6;

/* Initialized Variables */
C_INIT_VARCHAR2  Constant VARCHAR2(255) := 'init';
C_INIT_DATE      Constant DATE          := sysdate;
C_INIT_NUMBER    Constant NUMBER        := 0;

/* Switch for Debugging */
C_DEBUG          Constant BOOLEAN       := FALSE;

/* Temp Variables */
tmp1 varchar2(100);
tmp2 number;
tmp3 number;

/* Determines Bom Type for a given Item
 * Given the following :
 *
 * (1) Instance, (2) Source Org Pk, (3) Source Inventory Item Id
 *
 * Returns: 1 - Model
 *          2 - Option Class
 *          3 - Standard
 *          4 - Planning
 *          5 - Product Family
 *
 */

Procedure get_bom_item_type(
  p_answer               in out nocopy number,
  P_instance             in     varchar2,
  p_sr_org_pk            in     varchar2,
  p_sr_inventory_item_pk in     varchar2);


/* Determines all Assemblies using this Item
 *
 * Given the following :
 *
 * (1) Instance, (2) Source Org Pk, (3) Source Inventory Item Id
 *
 * Returns: Assemblies appended to p_parents.
 *
 */
procedure get_all_parents (
  p_parents              in out nocopy parents,
  p_instance             in     varchar2,
  p_sr_org_pk            in     varchar2,
  p_asmb_ascp_pk         in     varchar2,
  p_planning_factor      in     number,
  p_quantity_per         in     number);

procedure debug_line ( p_msg in varchar2);

/* Option Class Parents Stack*/
oc_parents          parents;

/* Model Parents Stack*/
mo_parents          parents;

/* Public Procedures */

procedure collect_bom_data (
  errbuf                 in out nocopy varchar2,
  retcode                in out nocopy varchar2,
  p_instance_id          in     number) IS

p_bom_item_type number := 0;
p_first_parent  parent_type;
x_sr_level_pk   varchar2(255);
i number := 0;

/* Create the Collections for looping */
L_INSTANCE     		          varchar2List;
L_ORG_SR_PKS         	     varchar2List;
L_ASSEMBLY_ASCP_PKS        numberList;
L_COMPONENT_SR_PKS 		      varchar2List;
L_EFFECTIVE_DATES		        dateList;
L_DISABLE_DATES      	     dateList;
L_QUANTITY_PER       	     numberList;
L_PLANNING_FACTOR    	     numberList;
L_BILL_SEQUENCE_ID   	     numberList;
L_OPTIONAL_FLAG              numberList;

/* Create the Collections needed for Bulk Insert */
C_INSTANCE     		          varchar2List := varchar2List(C_INIT_VARCHAR2);
C_ORG_PKS			               varchar2List := varchar2List(C_INIT_VARCHAR2);
C_ORG_SR_PKS         	     varchar2List := varchar2List(C_INIT_VARCHAR2);
C_ASSEMBLY_PKS       	     varchar2List := varchar2List(C_INIT_VARCHAR2);
C_ASSEMBLY_SR_PKS    	     varchar2List := varchar2List(C_INIT_VARCHAR2);
C_COMPONENT_PKS  		        varchar2List := varchar2List(C_INIT_VARCHAR2);
C_COMPONENT_SR_PKS 	 	     varchar2List := varchar2List(C_INIT_VARCHAR2);
C_EFFECTIVE_DATES		        dateList     := dateList(C_INIT_DATE);
C_DISABLE_DATES      	     dateList     := dateList(C_INIT_DATE);
C_QUANTITY_PER       	     numberList   := numberList(C_INIT_NUMBER);
C_PLANNING_FACTOR    	     numberList   := numberList(C_INIT_NUMBER);
C_OPTIONAL_FLAG              numberList   := numberList(C_INIT_NUMBER);

CURSOR C1 Is
SELECT DISTINCT
       mb.sr_instance_id,
       mb.organization_id,
       mbc.using_assembly_id,
       ascp_comp.sr_inventory_item_id,
       mbc.effectivity_date,
       mbc.disable_date,
       decode(mbc.usage_quantity/decode(mbc.usage_quantity,
                                        null,1,
                                        0,1,
                                        abs(mbc.usage_quantity)),
              1, (mbc.usage_quantity * mbc.Component_Yield_Factor),
             (mbc.usage_quantity /  mbc.Component_Yield_Factor))*msd_common_utilities.uom_conv(ascp_comp.uom_code,ascp_comp.inventory_item_id) usage_quantity,
       mbc.planning_factor,
       mb.bill_sequence_id,
       mbc.optional_component
  FROM msc_bom_components mbc,
       msc_boms mb,
       msc_system_items assemble,
       msc_system_items ascp_comp
 WHERE mbc.plan_id = -1
   AND mb.plan_id = mbc.plan_id
   AND ascp_comp.plan_id = mbc.plan_id
   AND mb.organization_id = mbc.organization_id
   AND mb.alternate_bom_designator is null
   AND mb.bill_sequence_id = mbc.bill_sequence_id
   AND assemble.sr_instance_id = mbc.sr_instance_id
   AND assemble.plan_id = mbc.plan_id
   AND assemble.inventory_item_id = mbc.using_assembly_id
   AND assemble.organization_id = mbc.organization_id
   AND (assemble.mrp_planning_code <> 6 or -- Exclude non plan ATO, but include PTO
                    (assemble.mrp_planning_code = 6 and assemble.pick_components_flag = 'Y'))
   AND assemble.ato_forecast_control <> 3
   AND (assemble.bom_item_type <> 4 or -- exclude Standard bom, but include Kit
                    (assemble.bom_item_type = 4 and assemble.pick_components_flag = 'Y'))
   AND mbc.inventory_item_id = ascp_comp.inventory_item_id
   AND mbc.organization_id = ascp_comp.organization_id
   AND mbc.sr_instance_id = ascp_comp.sr_instance_id
   AND ascp_comp.ato_forecast_control = C_CONSUME_DERIVE
   AND ascp_comp.bom_item_type in (C_MODEL,C_STANDARD)
   AND ( ascp_comp.mrp_planning_code <> C_NO_PLANNING or
         (ascp_comp.mrp_planning_code = C_NO_PLANNING and ascp_comp.pick_components_flag = 'Y'))
   AND mbc.sr_instance_id = mb.sr_instance_id;  -- Support PTO as component


cursor c2(p_instance in number,
          p_org_id   in number,
          p_item_id  in number) is
select sr_inventory_item_id
  from msc_system_items
 where sr_instance_id = p_instance
   and plan_id = -1
   and organization_id = p_org_id
   and inventory_item_id = p_item_id;


compLastIndex number;
numInsert number := 1;
numMo number := 1;
icount number:= 0;

BEGIN

retcode := '0';

if (C_DEBUG) then
  debug_line('Checking Profile Option.');
end if;

if (fnd_profile.value('MSD_PLANNING_PERCENTAGE') <> 3) then
  if (C_DEBUG) then
    debug_line('This program only runs for Planning Percentage option 3.');
  end if;
  return;
end if;

  if (C_DEBUG) then
    debug_line('Deleting Old Bom Data.');
  end if;

Delete from msd_bom_components
where instance = p_instance_id;

  if (C_DEBUG) then
    debug_line('Selecting Valid Components from Msc');
  end if;

Open c1;
FETCH c1 bulk collect into
L_INSTANCE,
L_ORG_SR_PKS,
L_ASSEMBLY_ASCP_PKS,
L_COMPONENT_SR_PKS,
L_EFFECTIVE_DATES,
L_DISABLE_DATES,
L_QUANTITY_PER,
L_PLANNING_FACTOR,
L_BILL_SEQUENCE_ID,
L_OPTIONAL_FLAG;


-- Bug 4266827. If no rows exist then do not continue.

if c1%ROWCOUNT = 0 then
  close c1;
  return;
end if;

Close c1;

debug_line('Begin looping through all components.');

For j in L_COMPONENT_SR_PKS.first..L_COMPONENT_SR_PKS.last loop

 mo_parents.delete;

 if (C_DEBUG) then
   debug_line('Row: ' || icount);
   debug_line('  Instance: ' || icount);
   debug_line('  Organization Sr Pk: ' || L_ORG_SR_PKS(j));
   debug_line('  Assembly        Pk: ' || L_ASSEMBLY_ASCP_PKS(j));
   debug_line('  Component     SrPk: ' || L_COMPONENT_SR_PKS(j));
   debug_line('  Effective     Date: ' || L_EFFECTIVE_DATES(j));
   debug_line('  Bill Sequence   Id: ' || L_BILL_SEQUENCE_ID(j));
   debug_line('  Optional Flag     : ' || L_OPTIONAL_FLAG(j));
 end if;

 if (icount = 700) then
--   exit;
   null;
 end if;

 icount := icount + 1;

 get_bom_item_type(
  p_answer => p_bom_item_type,
  p_instance => L_INSTANCE(j),
  p_sr_org_pk => L_ORG_SR_PKS(j),
  p_sr_inventory_item_pk => L_ASSEMBLY_ASCP_PKS(j));

  oc_parents(1).item_id := 0;
  oc_parents(1).planning_factor := 0;
  oc_parents(1).quantity_per := 0;

  mo_parents(1).item_id := 0;
  mo_parents(1).planning_factor := 0;
  mo_parents(1).quantity_per := 0;

  if (p_bom_item_type = C_OPTION_CLASS) then

      get_all_parents(
        p_parents  => oc_parents,
        P_instance => L_INSTANCE(j),
        p_sr_org_pk => L_ORG_SR_PKS(j),
        p_asmb_ascp_pk => L_ASSEMBLY_ASCP_PKS(j),
        p_planning_factor => L_PLANNING_FACTOR(j),
        p_quantity_per => L_QUANTITY_PER(j)
      );

      while oc_parents.count > 0 loop
        p_bom_item_type := 0;

        compLastIndex := oc_parents.last;

        if compLastIndex is null then
          if (C_DEBUG) then
            debug_line('compLastIndex is null in method bom_collections');
          end if;
        end if;

        get_bom_item_type(
          p_answer => p_bom_item_type,
          p_instance => L_INSTANCE(j),
          p_sr_org_pk => L_ORG_SR_PKS(j),
          p_sr_inventory_item_pk => oc_parents(compLastIndex).item_id);

        if (p_bom_item_type = C_OPTION_CLASS) then

          tmp1 := oc_parents(compLastIndex).item_id;
          tmp2 := oc_parents(compLastIndex).planning_factor;
          tmp3 := oc_parents(compLastIndex).quantity_per;

          oc_parents.delete(compLastIndex);

          get_all_parents(
            p_parents => oc_parents,
            p_instance => L_INSTANCE(j),
            p_sr_org_pk => L_ORG_SR_PKS(j),
            p_asmb_ascp_pk => tmp1,
            p_planning_factor => tmp2,
            p_quantity_per => tmp3
          );

         elsif (p_bom_item_type = C_MODEL) then
           mo_parents(numMo).item_id := oc_parents(compLastIndex).item_id;
           mo_parents(numMo).planning_factor := oc_parents(compLastIndex).planning_factor;
           mo_parents(numMo).quantity_per := oc_parents(compLastIndex).quantity_per;
           numMo := numMo + 1;
           oc_parents.delete(compLastIndex);
         else
           oc_parents.delete(compLastIndex);
         end if;

      end loop;

      i := mo_parents.FIRST;  -- get subscript of first element
      WHILE i IS NOT NULL LOOP

       if (numInsert > C_INSTANCE.LAST) then
         C_INSTANCE.extend;
         C_ORG_SR_PKS.extend;
         C_ASSEMBLY_SR_PKS.extend;
         C_COMPONENT_SR_PKS.extend;
         C_EFFECTIVE_DATES.extend;
         C_DISABLE_DATES.extend;
         C_QUANTITY_PER.extend;
         C_PLANNING_FACTOR.extend;
         C_OPTIONAL_FLAG.extend;
       end if;


       open c2(L_INSTANCE(j),  to_number(L_ORG_SR_PKS(j)), mo_parents(i).item_id);
       fetch c2 into x_sr_level_pk;
       close c2;

       if (x_sr_level_pk is not null and mo_parents(i).quantity_per <> 0 and mo_parents(i).planning_factor <> 0) then
         if (numInsert > C_INSTANCE.LAST) then
          C_INSTANCE.extend;
          C_ORG_SR_PKS.extend;
          C_ASSEMBLY_SR_PKS.extend;
          C_COMPONENT_SR_PKS.extend;
          C_EFFECTIVE_DATES.extend;
          C_DISABLE_DATES.extend;
          C_QUANTITY_PER.extend;
          C_PLANNING_FACTOR.extend;
          C_OPTIONAL_FLAG.extend;
        end if;

         C_INSTANCE(numInsert) := L_INSTANCE(j);
         C_ORG_SR_PKS(numInsert)	:= L_ORG_SR_PKS(j);
         C_ASSEMBLY_SR_PKS(numInsert) := x_sr_level_pk;
         C_COMPONENT_SR_PKS(numInsert) := L_COMPONENT_SR_PKS(j);
         C_EFFECTIVE_DATES(numInsert)	:= L_EFFECTIVE_DATES(j);
         C_DISABLE_DATES(numInsert) := L_DISABLE_DATES(j);
         C_QUANTITY_PER(numInsert) := mo_parents(i).quantity_per;
         C_PLANNING_FACTOR(numInsert) := mo_parents(i).planning_factor;
         C_OPTIONAL_FLAG(numInsert) := L_OPTIONAL_FLAG(j);

         numInsert := numInsert + 1;
       end if;

       i := mo_parents.NEXT(i);  -- get subscript of next element

      END LOOP;



  elsif (p_bom_item_type = C_MODEL or
         p_bom_item_type = C_STANDARD ) then  /* To bring PTO Kit */

    open c2(L_INSTANCE(j),  to_number(L_ORG_SR_PKS(j)), L_ASSEMBLY_ASCP_PKS(j));
    fetch c2 into x_sr_level_pk;
    close c2;

    if (x_sr_level_pk is not null) then
      if (numInsert > C_INSTANCE.LAST) then
        C_INSTANCE.extend;
        C_ORG_SR_PKS.extend;
        C_ASSEMBLY_SR_PKS.extend;
        C_COMPONENT_SR_PKS.extend;
        C_EFFECTIVE_DATES.extend;
        C_DISABLE_DATES.extend;
        C_QUANTITY_PER.extend;
        C_PLANNING_FACTOR.extend;
        C_OPTIONAL_FLAG.extend;
      end if;

      C_INSTANCE(numInsert) := L_INSTANCE(j);
      C_ORG_SR_PKS(numInsert)	:= L_ORG_SR_PKS(j);
      C_ASSEMBLY_SR_PKS(numInsert) := x_sr_level_pk;
      C_COMPONENT_SR_PKS(numInsert) := L_COMPONENT_SR_PKS(j);
      C_EFFECTIVE_DATES(numInsert)	:= L_EFFECTIVE_DATES(j);
      C_DISABLE_DATES(numInsert) := L_DISABLE_DATES(j);
      C_QUANTITY_PER(numInsert) := L_QUANTITY_PER(j);
      C_PLANNING_FACTOR(numInsert) := L_PLANNING_FACTOR(j);
      C_OPTIONAL_FLAG(numInsert) := L_OPTIONAL_FLAG(j);

      numInsert := numInsert + 1;
    end if;
  end if;

end loop;


if (C_INSTANCE(1) = C_INIT_VARCHAR2) then
  if (C_DEBUG) then
    debug_line('There is no data to insert.');
  end if;
else
-- INSERT THE DATA
-- start with index 2, index 1 contains the initial characters
FORALL k in 2..C_INSTANCE.last
  INSERT INTO msd_bom_components (
    instance,
    sr_organization_pk,
    sr_assembly_pk,
    sr_component_pk,
    effectivity_date,
    disable_date,
    quantity_per,
    planning_factor,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    optional_flag)
  VALUES (
    C_INSTANCE(k),
    C_ORG_SR_PKS(k),
    C_ASSEMBLY_SR_PKS(k),
    C_COMPONENT_SR_PKS(k),
    C_EFFECTIVE_DATES(k),
    C_DISABLE_DATES(k),
    C_QUANTITY_PER(k),
    C_PLANNING_FACTOR(k),
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.user_id,
    C_OPTIONAL_FLAG(k) );

  if (C_DEBUG) then
    debug_line('The number of rows inserted is : ' || numInsert);
  end if;
end if;

Exception
when others then
  if (C_DEBUG) then
    debug_line(sqlerrm);
  end if;
  retcode :='-1';
END collect_bom_data;


Procedure get_bom_item_type(
  p_answer in out nocopy number,
  P_instance in varchar2,
  p_sr_org_pk in varchar2,
  p_sr_inventory_item_pk in varchar2) is

CURSOR C1 IS
SELECT bom_item_type
  FROM msc_system_items
 WHERE sr_instance_id = p_instance
   AND organization_id = p_sr_org_pk
   AND inventory_item_id = p_sr_inventory_item_pk
   AND plan_id = -1;

Begin
Open c1;
Fetch c1 into p_answer;

If c1%NOTFOUND then
  p_answer := 0;
end if;
Close c1;

End get_bom_item_type;

/* Finds all assemblies using a component. This procedure is called when
 * a component is selected and its parent is an option class. When this
 * occurs, the option class's nearest model needs to be found. Therefore,
 * the components grandparents which are the assemblies parents are
 * placed in a stack for further inspection.
 *
 * Model A
 *   |
 *   |--- Option Class A
 *   |            |
 *   |            |--- Option Class A'
 *   |                            |
 *   |                            |--- Component A
 *   |
 * Model B
 *   |
 *   |--- Option Class A
 *   |            |
 *   |            |--- Option Class A'
 *   |                            |
 *   |                            |--- Component A
 * Model C
 *   |
 *   |--- Option Class A'
 *                |
 *                |--- Component A
 *
 *
 * In this case, Component A needs to find Model A, B, C. Option Class A' is an
 * option class, but is used in several places.  The procedure will search
 * the components using Depth First Search (DFS) and append possible parents
 * to the argument parameter.
 *
 *
 * Parameters : 1. p_parents - vector containing all of the assemblies.
 *              2. p_instance - source location
 *              3. p_sr_org_pk - Organization source primary key.
 *              4. p_asmb_ascp_pk - The assembly whose parents we are looking for.
 *              5. p_planning_factor - Planning factor from this assembly
 */

Procedure get_all_parents(
  P_parents         in out nocopy parents,
  P_instance        in     varchar2,
  p_sr_org_pk       in     varchar2,
  p_asmb_ascp_pk    in     varchar2,
  p_planning_factor in     number,
  p_quantity_per    in     number) is

endPos number := p_parents.last;

cursor c1 is
select using_assembly_id,
       planning_factor,
       decode(mbc.usage_quantity/decode(mbc.usage_quantity,
                                        null,1,
                                        0,1,
                                        abs(mbc.usage_quantity)),
              1, (mbc.usage_quantity * mbc.Component_Yield_Factor),
             (mbc.usage_quantity /  mbc.Component_Yield_Factor))*msd_sr_util.uom_conv(msi.uom_code,msi.sr_inventory_item_id) usage_quantity
  from msc_bom_components mbc,
       msc_system_items msi
 where mbc.plan_id = -1
   and msi.plan_id = -1
   and msi.organization_id = mbc.organization_id
   and msi.sr_instance_id = p_instance
   and mbc.organization_id = p_sr_org_pk
   and mbc.sr_instance_id = p_instance
   and mbc.inventory_item_id = msi.inventory_item_id
   and msi.inventory_item_id = p_asmb_ascp_pk
   and (mbc.optional_component = 1 or msi.ato_forecast_control in (C_CONSUME ,C_CONSUME_DERIVE));

Begin

for c_token in c1 loop

  endPos := endPos + 1;

  if endPos is null then
    if (C_DEBUG) then
      debug_line('endPos is null in method get_all_parent');
    end if;
  end if;
  p_parents(endPos).item_id :=  c_token.using_assembly_id;
  p_parents(endPos).planning_factor :=  (p_planning_factor * c_token.planning_factor) / 100;
  p_parents(endPos).quantity_per :=  p_quantity_per * c_token.usage_quantity;


end loop;
end get_all_parents;

procedure debug_line ( p_msg in varchar2) is
begin
--    dbms_output.put_line(p_msg);
    fnd_file.put_line(fnd_file.log, p_msg);
end debug_line;

END MSD_BOM_COLLECTIONS;

/
