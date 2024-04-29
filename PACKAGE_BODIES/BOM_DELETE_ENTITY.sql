--------------------------------------------------------
--  DDL for Package Body BOM_DELETE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DELETE_ENTITY" AS
/* $Header: BOMDELMB.pls 120.2.12000000.2 2007/02/23 12:10:19 earumuga ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--      BOMDELMB.pls
--
--  DESCRIPTION
--      This package contains Procedures used to insert delete groups
--      and Sub Entities Data into Bom_delete_groups and Bom_delete_sub
--      entities Tables Respectively.
--
--  PARAMETERS
--           Group Id         Delete Group Sequence Id
--           Delete Type      Type of the Delete Group
--                            (Item,bill,routing,component,operation)
--
--  NOTES
--
--  HISTORY
--  15-SEP-2000 Janaki B        Initial Creation
--
****************************************************************************/
FUNCTION Get_delorg_type(group_id in NUMBER)
RETURN NUMBER
IS
   CURSOR delorg_type is
   select delete_org_type
   FROM bom_delete_groups
   where delete_group_sequence_id = group_id;
BEGIN
       FOR c_delorg_type IN delorg_type LOOP
             RETURN c_delorg_type.delete_org_type;
       END LOOP;
       RETURN NULL;
END Get_delorg_type;

FUNCTION Get_delete_type(group_id in NUMBER)
RETURN NUMBER
IS
   CURSOR del_type is
   select delete_type
   FROM bom_delete_groups
   where delete_group_sequence_id = group_id;
BEGIN
       FOR c_del_type IN del_type LOOP
             RETURN c_del_type.delete_type;
       END LOOP;
       RETURN NULL;
END Get_delete_type;


FUNCTION Get_delorg_hrchy(group_id in NUMBER)
RETURN VARCHAR2
IS
   CURSOR delorg_hrchy is
   select organization_hierarchy
   FROM bom_delete_groups
   where delete_group_sequence_id = group_id;
BEGIN
       FOR c_delorg_hrchy IN delorg_hrchy LOOP
             RETURN c_delorg_hrchy.organization_hierarchy;
       END LOOP;
       RETURN NULL;
END Get_delorg_hrchy;

FUNCTION Get_common_flag(group_id in NUMBER)
RETURN NUMBER
IS
   CURSOR common_flag is
   select delete_common_bill_flag
   FROM bom_delete_groups
   where delete_group_sequence_id = group_id;
BEGIN
       FOR c_common_flag IN common_flag LOOP
             RETURN c_common_flag.delete_common_bill_flag;
       END LOOP;
       RETURN NULL;
END Get_common_flag;

FUNCTION Get_delorg_id(group_id in NUMBER)
RETURN NUMBER
IS
   CURSOR orgid is
   select organization_id
   FROM bom_delete_groups
   where delete_group_sequence_id = group_id;
BEGIN
       FOR c_orgid IN orgid LOOP
             RETURN c_orgid.organization_id;
       END LOOP;
       RETURN NULL;
END Get_delorg_id;

FUNCTION Get_delorg_name(org_id in number)
RETURN varchar2
IS
   -- bug:5003575 Replaced ORG_ORGANIZATION_DEFINITIONS view by ORG_ACCESS_VIEW
   -- to improve performance
   CURSOR orgname is
    SELECT  oav.ORGANIZATION_NAME
    FROM    ORG_ACCESS_VIEW oav
    WHERE
        oav.RESPONSIBILITY_ID   = FND_PROFILE.Value('RESP_ID')
    AND oav.RESP_APPLICATION_ID = FND_PROFILE.Value('RESP_APPL_ID')
    AND oav.ORGANIZATION_ID     = org_id;
BEGIN
       FOR c_orgname IN orgname LOOP
             RETURN c_orgname.organization_name;
       END LOOP;
       RETURN NULL;
END Get_delorg_name;

PROCEDURE get_delorg_list(org_type         in      number,
                          org_hrchy        in      varchar2,
                          current_org_id   in      number,
                          current_org_name in      varchar2,
                          org_list         in out nocopy /* file.sql.39 change */     inv_orghierarchy_pvt.orgid_tbl_type)
IS
CURSOR orgs is
SELECT MP.organization_id
FROM   MTL_PARAMETERS MP
WHERE  MP.master_organization_id = (select m.master_organization_id
                                    from mtl_parameters m
                                    where m.organization_id = current_org_id)
       and
       exists ( select 'x'
                   from org_access_view
                   where responsibility_id =
                           to_number(FND_PROFILE.value('RESP_ID')) and
                   resp_application_id =
                           to_number(FND_PROFILE.value('RESP_APPL_ID'))
                  );
l_org_id               mtl_parameters.organization_id%type;
l_index                NUMBER := 0;
BEGIN
    l_index := nvl(org_list.LAST,0);
    If (org_type = 1) then
       l_index := l_index+1;
       org_list(l_index) := current_org_id;
    elsif (org_type = 2) then
       inv_orghierarchy_pvt.org_hierarchy_list(org_hrchy,
                                               current_org_id,
                                               org_list);
    elsif (org_type = 3) then
       FOR c_orgs in orgs LOOP
         l_index := l_index+1;
         org_list(l_index) := c_orgs.organization_id;
       END LOOP;
    end if;
END get_delorg_list;

FUNCTION Get_bill_seq(assembly_id    in NUMBER,
                      org_id         in NUMBER,
                      alternate_bom  in VARCHAR2)
RETURN NUMBER
IS
   CURSOR billseq is
   select bill_sequence_id
   FROM bom_bill_of_materials
   where assembly_item_id = assembly_id and
         organization_id =  org_id and
         nvl(alternate_bom_designator,'none') = nvl(alternate_bom,'none');
BEGIN
       FOR c_billseq IN billseq LOOP
             RETURN c_billseq.bill_sequence_id;
       END LOOP;
       RETURN NULL;
END Get_bill_seq;

FUNCTION Get_rtg_seq(assembly_id    in NUMBER,
                      org_id         in NUMBER,
                     alternate_desg  in VARCHAR2)
RETURN NUMBER
IS
   CURSOR rtgseq is
   select routing_sequence_id
   FROM bom_operational_routings
   where assembly_item_id = assembly_id and
         organization_id =  org_id and
         nvl(alternate_routing_designator,'none') = nvl(alternate_desg,'none');
BEGIN
       FOR c_rtgseq IN rtgseq LOOP
             RETURN c_rtgseq.routing_sequence_id;
       END LOOP;
       RETURN NULL;
END Get_rtg_seq;


FUNCTION Get_comp_seq(bill_seq    in NUMBER,
                      component_id in NUMBER,
                      oper_seq_num    in NUMBER,
                      effective_date  in DATE)
RETURN NUMBER
IS
   CURSOR compseq is
   select component_sequence_id
   FROM bom_inventory_components
   where bill_sequence_id = bill_seq and
           component_item_id = component_id and
          operation_seq_num = oper_seq_num and
          effectivity_date = effective_date ;
BEGIN
       FOR c_compseq IN compseq LOOP
             RETURN c_compseq.component_sequence_id;
       END LOOP;
       RETURN NULL;
END Get_comp_seq;


FUNCTION Get_oper_seq(rtg_seq         in NUMBER,
                      oper_seq_num    in NUMBER,
                      effective_date  in DATE,
                      dept_code       in VARCHAR2,
                      org_id          in NUMBER)
RETURN NUMBER
IS
   CURSOR operseq is
   select operation_sequence_id
   FROM bom_operation_sequences
   where routing_sequence_id = rtg_seq and
           operation_seq_num = oper_seq_num and
--         effectivity_date = effective_date and  -- Changed for bug 2647027
           trunc(effectivity_date) = trunc(effective_date) and -- Changed back for bug 3738241
           department_id = (select department_id
                            from bom_departments
                            where department_code = dept_code and
                                  organization_id = org_id);
BEGIN
       FOR c_operseq IN operseq LOOP
             RETURN c_operseq.operation_sequence_id;
       END LOOP;
       RETURN NULL;
END Get_oper_seq;

FUNCTION Get_dept_code(
                      dept_code       in VARCHAR2,
                      org_id          in NUMBER)
RETURN VARCHAR2
IS
   CURSOR dept is
   select department_code
   FROM bom_departments
   where department_code = dept_code and
         organization_id  = org_id;
BEGIN
       FOR c_dept IN dept LOOP
             RETURN c_dept.department_code;
       END LOOP;
       RETURN NULL;
END Get_dept_code;


FUNCTION Get_item_descr(assembly_id    in NUMBER,
                        org_id         in NUMBER)
RETURN VARCHAR2
IS
   CURSOR descr is
   select description
   FROM mtl_system_items
   where inventory_item_id = assembly_id and
         organization_id =  org_id;
BEGIN
       FOR c_descr IN descr LOOP
             RETURN c_descr.description;
       END LOOP;
       RETURN NULL;
END Get_item_descr;

FUNCTION Get_concat_segs(assembly_id    in NUMBER,
                         org_id         in NUMBER)
RETURN VARCHAR2
IS
   CURSOR concat is
   select concatenated_segments
   FROM mtl_system_items_vl
   where inventory_item_id = assembly_id and
         organization_id =  org_id;
BEGIN
       FOR c_concat IN concat LOOP
             RETURN c_concat.concatenated_segments;
       END LOOP;
       RETURN NULL;
END Get_concat_segs;


FUNCTION get_item_id(assembly_id    in NUMBER,
                     current_org    in NUMBER)
RETURN NUMBER
IS
CURSOR item IS
SELECT inventory_item_id
FROM mtl_system_items
where inventory_item_id = assembly_id and
      organization_id  = current_org;

BEGIN
      FOR c_item in item LOOP
          RETURN c_item.inventory_item_id;
      END LOOP;
      RETURN NULL;
END get_item_id;

PROCEDURE process_delete_entities(delete_type     in    NUMBER,
			  	  group_id        in    NUMBER,
 				  original_org    in    NUMBER,
                                  org_list        in    inv_orghierarchy_pvt.orgid_tbl_type)
IS
l_index            number := 0;
current_org        number;
temp               varchar2(1);
common_bill        bom_bill_of_materials.common_bill_sequence_id%type;
bill_seq_id        bom_bill_of_materials.bill_sequence_id%type;
current_bill_seq   bom_bill_of_materials.bill_sequence_id%type;
del_ent_type       bom_delete_entities.delete_entity_type%type;
inv_item_id        bom_delete_entities.inventory_item_id%type;
alt_desg           bom_delete_entities.alternate_designator%type;
item_concat_seg    bom_delete_entities.item_concat_segments%type;
last_upd_by        bom_delete_entities.last_updated_by%type;
crtd_by            bom_delete_entities.created_by%type;
current_del_seq    bom_delete_entities.delete_entity_sequence_id%type;

CURSOR bom_entities IS
SELECT bill_sequence_id,delete_entity_type,
       inventory_item_id,alternate_designator,
       item_concat_segments,last_updated_by,
       created_by,delete_entity_sequence_id
  FROM bom_delete_entities
 WHERE delete_group_sequence_id = group_id
   AND organization_id = original_org;

CURSOR common_bills IS
SELECT common_bill_sequence_id,assembly_item_id,
       alternate_bom_designator,bill_sequence_id
FROM   bom_bill_of_materials
WHERE  common_bill_sequence_id in (
                              select BOM2.bill_sequence_id
                              from bom_bill_of_materials BOM2
                              where BOM2.assembly_item_id = inv_item_id) and
       bill_sequence_id <> common_bill_sequence_id and
       organization_id = current_org;

BEGIN
     if (delete_type in (2,6,7)) then           -- Bill,Bill/Rtg,Item/Bill/Rtg
      FOR c_bom_entities in bom_entities
      LOOP                         ---   ENTITIES LOOP
         current_bill_seq := c_bom_entities.bill_sequence_id;
         del_ent_type     := c_bom_entities.delete_entity_type;
	 inv_item_id      := c_bom_entities.inventory_item_id;
	 alt_desg         := c_bom_entities.alternate_designator;
	 item_concat_seg  := c_bom_entities.item_concat_segments;
         last_upd_by      := c_bom_entities.last_updated_by;
         crtd_by          := c_bom_entities.created_by;
         current_del_seq  := c_bom_entities.delete_entity_sequence_id;
         l_index := org_list.FIRST;
         while (l_index <= org_list.LAST)
         LOOP                             ---   ORG LIST LOOP
             current_org := org_list(l_index);
             /* current_org above means org being processed in the loop */
             IF (current_bill_seq is not NULL) then       -- BILLS
               begin
                select common_bill_sequence_id
                into common_bill
                from bom_bill_of_materials
                where bill_sequence_id = current_bill_seq;
                IF (current_bill_seq <> common_bill) then
                 exit;
                END IF;
               exception
                when others then
                 exit;
               end;
               FOR c_common_bills in common_bills
               LOOP                           --- COMMON LOOP
               begin
                select 'x'
                into temp
                from bom_delete_entities
                where bill_sequence_id = c_common_bills.bill_sequence_id and
                      delete_group_sequence_id = group_id and
                      organization_id = current_org;
               exception
                 when no_data_found then
                    insert into bom_delete_entities
                    (DELETE_ENTITY_SEQUENCE_ID,
		     DELETE_GROUP_SEQUENCE_ID,
                     DELETE_ENTITY_TYPE,
		     BILL_SEQUENCE_ID,
                     ROUTING_SEQUENCE_ID,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     ALTERNATE_DESIGNATOR,
                     ITEM_DESCRIPTION,
                     ITEM_CONCAT_SEGMENTS,
                     DELETE_STATUS_TYPE,
                     DELETE_DATE,
                     PRIOR_PROCESS_FLAG,
                     PRIOR_COMMIT_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE)
                     select bom_delete_entities_s.nextval,
    		            group_id,
			    del_ent_type,
		            get_bill_seq(c_common_bills.assembly_item_id,
                                         current_org,
                                      c_common_bills.alternate_bom_designator),
                            null,
                            inv_item_id,
                            current_org,
                            alt_desg,
                            get_item_descr(c_common_bills.assembly_item_id,
                                           current_org),
			    get_concat_segs(c_common_bills.assembly_item_id,
                                          current_org),
                            1,
			    null,
                            1,
			    1,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null
                      from bom_bill_of_materials
                      where organization_id = current_org and
                            common_bill_sequence_id = current_bill_seq and
                            bill_sequence_id <> current_bill_seq and
                            common_organization_id = original_org and
                            common_assembly_item_id = inv_item_id;
 	              update bom_delete_entities
         	      set delete_status_type = 5
                      where delete_group_sequence_id = group_id and
                            delete_entity_sequence_id = current_del_seq and
                            delete_status_type <> 4;
                 when others then
                    null;
                 end;
               END LOOP;                 --- COMMON LOOP
             END IF;                     --- BILLS
          l_index := org_list.NEXT(l_index);
          END LOOP;                      --- ORG LIST LOOP
      END LOOP;                          --- ENTITIES LOOP
    end if;           -- Bill,Bill/Rtg,Item/Bill/Rtg
END process_delete_entities;

PROCEDURE modify_original_bills( group_id          in   NUMBER,
                                 common_flag       in   NUMBER)
IS
BEGIN
    if (common_flag = 1) then
      begin
        delete from bom_delete_entities
        where delete_group_sequence_id = group_id and
              delete_status_type = 5;
      exception
        when others then
          null;
      end;
    elsif (common_flag = 2) then
      begin
        update bom_delete_entities
        set delete_status_type = 1
        where delete_group_sequence_id = group_id and
              delete_status_type = 5;
      exception
        when others then
          null;
      end;
    end if;
END modify_original_bills;

PROCEDURE process_original_sub_entities(
                             delete_type     in    NUMBER,
                             group_id        in    NUMBER,
                             original_org    in    NUMBER,
                             common_flag     in    NUMBER,
                             org_list        in    inv_orghierarchy_pvt.orgid_tbl_type)
IS
l_index            number := 0;
current_org        number;
temp               varchar2(1);
common_bill        bom_bill_of_materials.common_bill_sequence_id%type;
bill_seq_id        bom_bill_of_materials.bill_sequence_id%type;
current_bill_seq   bom_bill_of_materials.bill_sequence_id%type;
current_rtg_seq    bom_delete_entities.routing_sequence_id%type;
del_status         bom_delete_entities.delete_status_type%type;
del_ent_type       bom_delete_entities.delete_entity_type%type;
inv_item_id        bom_delete_entities.inventory_item_id%type;
alt_desg           bom_delete_entities.alternate_designator%type;
item_concat_seg    bom_delete_entities.item_concat_segments%type;
last_upd_by        bom_delete_entities.last_updated_by%type;
crtd_by            bom_delete_entities.created_by%type;
current_del_seq    bom_delete_entities.delete_entity_sequence_id%type;
new_del_seq        bom_delete_entities.delete_entity_sequence_id%type;
new_comp_seq       bom_delete_sub_entities.component_sequence_id%type := NULL;
new_operation_seq  bom_delete_sub_entities.operation_sequence_id%type;
new_bill_seq       bom_bill_of_materials.bill_sequence_id%type;
new_rtg_seq        bom_operational_routings.routing_sequence_id%type;
new_item_id        bom_delete_entities.inventory_item_id%type;
component_id       bom_inventory_components.component_item_id%type;
oper_seq_num       bom_inventory_components.operation_seq_num%type;
effective_date     bom_inventory_components.effectivity_date%type;

CURSOR bom_entities IS
SELECT bill_sequence_id,delete_entity_type,delete_status_type,
       inventory_item_id,alternate_designator,routing_sequence_id,
       item_concat_segments,last_updated_by,
       created_by,delete_entity_sequence_id
FROM   bom_delete_entities
WHERE
       delete_group_sequence_id = group_id
   AND organization_id = original_org
   AND request_id = FND_GLOBAL.CONC_REQUEST_ID;

CURSOR sub_entity IS
SELECT OPERATION_SEQ_NUM,EFFECTIVITY_DATE,
       COMPONENT_ITEM_ID,COMPONENT_CONCAT_SEGMENTS,
       ITEM_NUM,DISABLE_DATE,OPERATION_DEPARTMENT_CODE
FROM   BOM_DELETE_SUB_ENTITIES
where  DELETE_ENTITY_SEQUENCE_ID = current_del_seq;

CURSOR compseq is
select component_sequence_id
FROM bom_inventory_components
where bill_sequence_id = new_bill_seq and
      component_item_id = component_id and
      operation_seq_num = oper_seq_num and
      trunc(effectivity_date) = trunc(effective_date) ;
BEGIN
      if (common_flag = 2) then           -- Delete original and common bills
/*
 Process all Orgs except for original Bill Org as it is already in
 Delete entities Table
*/

       FOR c_bom_entities in bom_entities
       LOOP                         ---   ENTITIES LOOP
         current_bill_seq := c_bom_entities.bill_sequence_id;
         current_rtg_seq := c_bom_entities.routing_sequence_id;
         del_ent_type     := c_bom_entities.delete_entity_type;
         del_status       := c_bom_entities.delete_status_type;
         inv_item_id      := c_bom_entities.inventory_item_id;
         alt_desg         := c_bom_entities.alternate_designator;
	 item_concat_seg  := c_bom_entities.item_concat_segments;
         last_upd_by      := c_bom_entities.last_updated_by;
         crtd_by          := c_bom_entities.created_by;
         current_del_seq  := c_bom_entities.delete_entity_sequence_id;
             if (current_bill_seq is not null) then
              begin
                select common_bill_sequence_id
                into common_bill
                from bom_bill_of_materials
                where bill_sequence_id = current_bill_seq;
              exception
                when no_data_found then
                null;
              end;
             end if;
         if ((del_status = 4) and
             (current_bill_seq is not null) and
            (current_bill_seq <> common_bill)) then
            null;
         else
          l_index := org_list.FIRST;
          while (l_index <= org_list.LAST)
          LOOP                             ---   ORG LIST LOOP
             current_org := org_list(l_index);
             if (current_org <> original_org) then
/* If Org in Loop is Other than Org passed in Concurrent Request */

              new_bill_seq := get_bill_seq(inv_item_id,
                                         current_org,
                                         alt_desg);

              new_rtg_seq := get_rtg_seq(inv_item_id,
                                        current_org,
                                        alt_desg);

              new_item_id := get_item_id(inv_item_id,
                                         current_org);
--modifications by vhymavat for bug 2441107
--spiltting the logic to deal seperately for each delete type

              if (((delete_type = 2)or (delete_type = 6) or (delete_type = 7) or
                    (delete_type = 4))
                     and (new_bill_seq is not NULL)
                     and (current_bill_seq is not null))    --added by arudresh for bug 3735729
/* The clause (current_bill_seq is not null) is added as the same alt_desg is
 * used to identify both bills and routings. This will avoid the case when
 * bill as well as routing of the same alternate got deleted even if only one
 * was specified.*/
		then
               begin
                select 'x'
                into temp
                from bom_delete_entities
                where bill_sequence_id= new_bill_seq and
                      inventory_item_id = new_item_id and
                      delete_group_sequence_id = group_id and
                      organization_id = current_org;
               exception
                 when no_data_found then
                    select bom_delete_entities_s.nextval
                    into new_del_seq
                    from dual;
                    insert into bom_delete_entities
                    (DELETE_ENTITY_SEQUENCE_ID,
		     DELETE_GROUP_SEQUENCE_ID,
                     DELETE_ENTITY_TYPE,
		     BILL_SEQUENCE_ID,
                     ROUTING_SEQUENCE_ID,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     ALTERNATE_DESIGNATOR,
                     ITEM_DESCRIPTION,
                     ITEM_CONCAT_SEGMENTS,
                     DELETE_STATUS_TYPE,
                     DELETE_DATE,
                     PRIOR_PROCESS_FLAG,
                     PRIOR_COMMIT_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE)
                    values( new_del_seq,
    		            group_id,
			    decode(delete_type,4,4,2),
		            new_bill_seq,
                                   null,
                            inv_item_id,
                            current_org,
                            alt_desg,
                            get_item_descr(new_item_id,
                                           current_org),
			    get_concat_segs(new_item_id,
                                            current_org),
                            decode(delete_type,4,null,
                                               5,null,1),
			    null,
                            1,
			    1,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null);
                 when others then
                    null;
               end;
	      end if;			-- Delete Type 2,4,6,7

              if (((delete_type = 3)or (delete_type = 6) or (delete_type = 7) or
                    (delete_type = 5))
                     and (new_rtg_seq is not NULL)
                     and (current_rtg_seq is not null))  --added by arudresh,bug 3735729
		then
               begin
                select 'x'
                into temp
                from bom_delete_entities
                where routing_sequence_id= new_rtg_seq and
                      inventory_item_id = new_item_id and
                      delete_group_sequence_id = group_id and
                      organization_id = current_org;
               exception
                 when no_data_found then
                    select bom_delete_entities_s.nextval
                    into new_del_seq
                    from dual;
                    insert into bom_delete_entities
                    (DELETE_ENTITY_SEQUENCE_ID,
		     DELETE_GROUP_SEQUENCE_ID,
                     DELETE_ENTITY_TYPE,
		     BILL_SEQUENCE_ID,
                     ROUTING_SEQUENCE_ID,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     ALTERNATE_DESIGNATOR,
                     ITEM_DESCRIPTION,
                     ITEM_CONCAT_SEGMENTS,
                     DELETE_STATUS_TYPE,
                     DELETE_DATE,
                     PRIOR_PROCESS_FLAG,
                     PRIOR_COMMIT_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE)
                    values( new_del_seq,
    		            group_id,
			    decode(delete_type,5,5,3),
                            null,
                            new_rtg_seq,
                            inv_item_id,
                            current_org,
                            alt_desg,
                            get_item_descr(new_item_id,
                                           current_org),
			    get_concat_segs(new_item_id,
                                            current_org),
                            decode(delete_type,4,null,
                                               5,null,1),
			    null,
                            1,
			    1,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null);
                 when others then
                    null;
               end;
              end if;                      --- Delete Type 3,5,6,7

              if (((delete_type = 1)or (delete_type=7))
			and (new_item_id is not NULL))
		then
               begin
                select 'x'
                into temp
                from bom_delete_entities
                where inventory_item_id = new_item_id and
                      delete_group_sequence_id = group_id and
		      delete_entity_type = 1 and
                      organization_id = current_org;
               exception
                 when no_data_found then
                    select bom_delete_entities_s.nextval
                    into new_del_seq
                    from dual;
                    insert into bom_delete_entities
                    (DELETE_ENTITY_SEQUENCE_ID,
		     DELETE_GROUP_SEQUENCE_ID,
                     DELETE_ENTITY_TYPE,
		     BILL_SEQUENCE_ID,
                     ROUTING_SEQUENCE_ID,
                     INVENTORY_ITEM_ID,
                     ORGANIZATION_ID,
                     ALTERNATE_DESIGNATOR,
                     ITEM_DESCRIPTION,
                     ITEM_CONCAT_SEGMENTS,
                     DELETE_STATUS_TYPE,
                     DELETE_DATE,
                     PRIOR_PROCESS_FLAG,
                     PRIOR_COMMIT_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE)
                    values( new_del_seq,
    		            group_id,
			    1,
		            null,
                            null,
                            inv_item_id,
                            current_org,
                            alt_desg,
                            get_item_descr(new_item_id,
                                           current_org),
			    get_concat_segs(new_item_id,
                                            current_org),
                            decode(delete_type,4,null,
                                               5,null,1),
			    null,
                            1,
			    1,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null);
                 when others then
                    null;
		end;
	     end if;		--		 Delete Type 1,7


             IF delete_type in (4,5) then
               FOR c_sub_entity in sub_entity
               LOOP                          --- SUB ENTITY LOOP
                   component_id   :=  c_sub_entity.component_item_id;
                   oper_seq_num   :=  c_sub_entity.operation_seq_num;
                   effective_date :=  c_sub_entity.effectivity_date;
/*
                new_comp_seq  := get_comp_seq(new_bill_seq,
                                       c_sub_entity.component_item_id,
                                       c_sub_entity.operation_seq_num,
                                       c_sub_entity.effectivity_date);
*/
                new_operation_seq := get_oper_seq( new_rtg_seq,
                                       c_sub_entity.operation_seq_num,
                                       c_sub_entity.effectivity_date,
                                       c_sub_entity.operation_department_code,
                                       current_org
                                       );
              if ((delete_type=5) and new_operation_seq is not NULL) then
               begin
                select 'x'
                into temp
                from bom_delete_sub_entities
                where delete_entity_sequence_id = new_del_seq and
                      ((component_sequence_id = new_comp_seq) or
                      (operation_sequence_id = new_operation_seq));
               exception
                 when no_data_found then
                    insert into bom_delete_sub_entities
                    (DELETE_ENTITY_SEQUENCE_ID,
                     COMPONENT_SEQUENCE_ID,
                     OPERATION_SEQUENCE_ID,
                     OPERATION_SEQ_NUM,
                     EFFECTIVITY_DATE,
                     COMPONENT_ITEM_ID,
                     COMPONENT_CONCAT_SEGMENTS,
                     ITEM_NUM,
                     DISABLE_DATE,
                     DESCRIPTION,
                     OPERATION_DEPARTMENT_CODE,
                     DELETE_STATUS_TYPE,
                     DELETE_DATE,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
		     PROGRAM_UPDATE_DATE,
                     FROM_END_ITEM_UNIT_NUMBER,
                     TO_END_ITEM_UNIT_NUMBER)
                    values(
                            new_del_seq,
                            decode(delete_type,4,new_comp_seq,5,null),
                            decode(delete_type,5,new_operation_seq,4,null),
 			    c_sub_entity.operation_seq_num,
                            c_sub_entity.effectivity_date,
                            c_sub_entity.component_item_id,
                            get_concat_segs(c_sub_entity.component_item_id,
                                            current_org),
                            c_sub_entity.item_num,
			    c_sub_entity.disable_date,
			    get_item_descr(c_sub_entity.component_item_id,
                                           current_org),
		           get_dept_code(c_sub_entity.operation_department_code,
                                          current_org),
			    1,
                            null,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null,
                            null,
                            null);
                 when others then
                   null;
                 end;
                END IF;                           -- Delete Type  5
               IF delete_type = 4 then
                  FOR c_compseq in compseq
                  LOOP
                     new_comp_seq := c_compseq.component_sequence_id;
                     if  new_comp_seq is not NULL then
                      begin
                       select 'x'
                       into temp
                       from bom_delete_sub_entities
                       where delete_entity_sequence_id = new_del_seq and
                             ((component_sequence_id = new_comp_seq) or
                             (operation_sequence_id = new_operation_seq));
                      exception
                        when no_data_found then
                           insert into bom_delete_sub_entities
                           (DELETE_ENTITY_SEQUENCE_ID,
                            COMPONENT_SEQUENCE_ID,
                            OPERATION_SEQUENCE_ID,
                            OPERATION_SEQ_NUM,
                            EFFECTIVITY_DATE,
                            COMPONENT_ITEM_ID,
                            COMPONENT_CONCAT_SEGMENTS,
                            ITEM_NUM,
                            DISABLE_DATE,
                            DESCRIPTION,
                            OPERATION_DEPARTMENT_CODE,
                            DELETE_STATUS_TYPE,
                            DELETE_DATE,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            REQUEST_ID,
                            PROGRAM_APPLICATION_ID,
                            PROGRAM_ID,
             	            PROGRAM_UPDATE_DATE,
                            FROM_END_ITEM_UNIT_NUMBER,
                            TO_END_ITEM_UNIT_NUMBER)
                           values(
                            new_del_seq,
                            decode(delete_type,4,new_comp_seq,5,null),
                            decode(delete_type,5,new_operation_seq,4,null),
 			    c_sub_entity.operation_seq_num,
                            c_sub_entity.effectivity_date,
                            c_sub_entity.component_item_id,
                            get_concat_segs(c_sub_entity.component_item_id,
                                            current_org),
                            c_sub_entity.item_num,
			    c_sub_entity.disable_date,
			    get_item_descr(c_sub_entity.component_item_id,
                                           current_org),
		           get_dept_code(c_sub_entity.operation_department_code,
                                          current_org),
			    1,
                            null,
                            sysdate,
                            last_upd_by,
                            sysdate,
                            crtd_by,
                            null,
			    null,
                            null,
                            null,
                            null,
                            null,
                            null);
                 when others then
                   null;
                 end;
                END IF;                           -- Delete Type 4 or 5
               END LOOP;
              END IF;
             END LOOP;                           --- SUB ENTITY LOOP
            END IF;                     -- Delete Type 4 or 5
           end if;                     -- Current org <> original org
           l_index := org_list.NEXT(l_index);
         END LOOP;                       -- ORG LIST LOOP
        end if;
       END LOOP;                       -- ENTITIES LOOP
      end if;
END process_original_sub_entities;

/* ------------------------ Insert_common_bill_details ------------------------
   NAME
    insert_common_bills
    Entities Table
 DESCRIPTION
    Insert the common bill details in Bom_delete_entities

 MODIFIES
    BOM_DELETE_ENTITIES Table
 ---------------------------------------------------------------------------*/


PROCEDURE insert_common_bills(group_id      IN NUMBER,
			      delete_type   IN NUMBER)
IS
   delete_org_type        bom_delete_groups.delete_org_type%type;
   delete_org_hrchy       bom_delete_groups.organization_hierarchy%type;
   delete_common_flag     bom_delete_groups.delete_common_bill_flag%type;
   current_org_id         bom_delete_groups.organization_id%type;
   current_org_name       org_access_view.organization_name%type;
   del_org_list           inv_orghierarchy_pvt.orgid_tbl_type;
BEGIN
   delete_org_type    :=  get_delorg_type(group_id);
   delete_org_hrchy   :=  get_delorg_hrchy(group_id);
   delete_common_flag :=  get_common_flag(group_id);
   current_org_id     :=  get_delorg_id(group_id);
   current_org_name   :=  get_delorg_name(current_org_id);

   get_delorg_list(delete_org_type,
                   delete_org_hrchy,
                   current_org_id,
                   current_org_name,
                   del_org_list);

   process_delete_entities(delete_type,
                           group_id,
                           current_org_id,
                           del_org_list);

END insert_common_bills;

/* ------------------------ Insert_original_bills ------------------------
   NAME
    insert_original_bills in Delete Entities Table
     and Component,Operation Info in Sub Entities Table
 DESCRIPTION
    Insert the original bill details in Bom_delete_entities
    Insert Component and Operation Info in Delete Sub Entities Table

 MODIFIES
    BOM_DELETE_ENTITIES Table
    BOM_DELETE_SUB_ENTITIES Table
 ---------------------------------------------------------------------------*/
PROCEDURE insert_original_bills(group_id      IN NUMBER,
                                delete_type   IN NUMBER)
IS
   delete_org_type        bom_delete_groups.delete_org_type%type;
   delete_org_hrchy       bom_delete_groups.organization_hierarchy%type;
   delete_common_flag     bom_delete_groups.delete_common_bill_flag%type;
   current_org_id         bom_delete_groups.organization_id%type;
   current_org_name       org_access_view.organization_name%type;
   del_org_list           inv_orghierarchy_pvt.orgid_tbl_type;

BEGIN
   delete_org_type    :=  get_delorg_type(group_id);
   delete_org_hrchy   :=  get_delorg_hrchy(group_id);
   delete_common_flag :=  get_common_flag(group_id);
   current_org_id     :=  get_delorg_id(group_id);
   current_org_name   :=  get_delorg_name(current_org_id);

   modify_original_bills(group_id,
                        delete_common_flag);

   get_delorg_list(delete_org_type,
                   delete_org_hrchy,
                   current_org_id,
                   current_org_name,
                   del_org_list);

   process_original_sub_entities(delete_type,
                                group_id,
                                current_org_id,
                                delete_common_flag,
                                del_org_list);

END insert_original_bills;

END bom_delete_entity;

/
