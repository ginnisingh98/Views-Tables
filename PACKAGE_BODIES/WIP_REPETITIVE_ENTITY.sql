--------------------------------------------------------
--  DDL for Package Body WIP_REPETITIVE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REPETITIVE_ENTITY" as
/* $Header: wiprentb.pls 115.9 2002/11/29 15:27:32 rmahidha ship $ */


procedure check_discrete(p_org_id		NUMBER,
			p_entity_name		VARCHAR2) is

temp	VARCHAR2(1);

cursor chck_discrete is
select 'x'
from WIP_ENTITIES
where organization_id = p_org_id
and wip_entity_name = p_entity_name
and entity_type <> WIP_CONSTANTS.REPETITIVE;

begin
	open chck_discrete;
	fetch chck_discrete into temp;
	close chck_discrete;
	if (temp = 'x') then
		fnd_message.set_name('WIP', 'WIP_DUP_NAME_DISC_REP');
		app_exception.raise_exception;
	end if;
end check_discrete;

procedure insert_entity (p_entity_id	IN OUT NOCOPY NUMBER,
			p_org_id		NUMBER,
			p_entity_name		VARCHAR2,
			p_description		VARCHAR2,
			p_primary_id		NUMBER,
			p_user_id		NUMBER,
			p_login_id		NUMBER) is


cursor check_entity is
select wip_entity_id
from WIP_REPETITIVE_ITEMS
where organization_id = p_org_id
and primary_item_id = p_primary_id;

CURSOR C4 IS SELECT MTL_GEN_OBJECT_ID_S.nextval FROM DUAL;

X_Gen_Object_Id NUMBER;

begin

	open check_entity;
	fetch check_entity into p_entity_id;

	if check_entity%NOTFOUND then
		-- create new entry in wip_entities
		select wip_entities_s.nextval
		into p_entity_id
		from dual;

    OPEN C4;
    FETCH C4 INTO X_Gen_Object_Id;
    if (C4%NOTFOUND) then
	  	CLOSE C4;
		  Raise NO_DATA_FOUND;
  	end if;
	  CLOSE C4;

		insert into wip_entities
			(wip_entity_id, organization_id,
			last_update_date, last_updated_by,
			creation_date, created_by, last_update_login,
			wip_entity_name, entity_type, description,
			primary_item_id, gen_object_id)
     		values
			(p_entity_id, p_org_id,
			SYSDATE, p_user_id, SYSDATE, p_user_id, p_login_id,
			substr(p_entity_name, 1, 240),
			WIP_CONSTANTS.REPETITIVE,
			p_description, p_primary_id, X_Gen_Object_Id);
	end if;
	close check_entity;
end insert_entity;

procedure validate_primary_line (p_entity_id		NUMBER,
				p_line_id		NUMBER,
				p_org_id		NUMBER) is

temp NUMBER;
cursor C is
select count(primary_line_flag)
from WIP_REPETITIVE_ITEMS
where wip_entity_id = nvl(p_entity_id, -1)
and organization_id = p_org_id
and primary_line_flag = 1
and line_id <> p_line_id;

begin
	temp := 0;
	open C;
	fetch C into temp;
	close C;
	if (temp <> 0) then
		fnd_message.set_name('WIP', 'WIP_ONE_LEADTIME_LINE');
		app_exception.raise_exception;
	end if;

end validate_primary_line;

procedure insert_rep_item(p_rowid			IN OUT NOCOPY VARCHAR2,
                     p_wip_entity_id			NUMBER,
                     p_line_Id				NUMBER,
                     p_organization_id			NUMBER,
                     p_primary_item_id			NUMBER,
                     p_alternate_bom_designator		VARCHAR2,
                     p_alternate_routing_designator	VARCHAR2,
                     p_class_code			VARCHAR2,
                     p_wip_supply_type			NUMBER,
                     p_completion_subinventory		VARCHAR2,
                     p_completion_locator_id		NUMBER,
                     p_load_distribution_priority	NUMBER,
                     p_primary_line_flag		NUMBER,
                     p_production_line_rate		NUMBER,
		     p_overcompletion_toleran_type	NUMBER,
		     p_overcompletion_toleran_value	NUMBER,
                     p_attribute_category		VARCHAR2,
                     p_attribute1			VARCHAR2,
                     p_attribute2			VARCHAR2,
                     p_attribute3			VARCHAR2,
                     p_attribute4			VARCHAR2,
                     p_attribute5			VARCHAR2,
                     p_attribute6			VARCHAR2,
                     p_attribute7			VARCHAR2,
                     p_attribute8			VARCHAR2,
                     p_attribute9			VARCHAR2,
                     p_attribute10			VARCHAR2,
                     p_attribute11			VARCHAR2,
                     p_attribute12			VARCHAR2,
                     p_attribute13			VARCHAR2,
                     p_attribute14			VARCHAR2,
                     p_attribute15			VARCHAR2,
		     p_user_id				NUMBER,
		     p_login_id				NUMBER) is
   CURSOR C IS
     SELECT rowid
     FROM   WIP_REPETITIVE_ITEMS
     WHERE  WIP_ENTITY_ID = p_wip_entity_id
     AND    organization_id = p_organization_id
     AND    line_id = p_line_id;


begin

  INSERT INTO WIP_REPETITIVE_ITEMS (
          Wip_Entity_id,
          Line_Id,
          Organization_Id,
          Creation_Date,
          Created_By,
	  Last_Update_Date,
	  Last_Updated_By,
	  Last_Update_Login,
          Primary_Item_Id,
          Alternate_Bom_Designator,
          Alternate_Routing_Designator,
          Class_Code,
          Wip_Supply_Type,
          Completion_Subinventory,
          Completion_Locator_Id,
          Load_Distribution_Priority,
          Primary_Line_Flag,
          Production_Line_Rate,
	  Overcompletion_Tolerance_Type,
	  Overcompletion_Tolerance_Value,
          Attribute_Category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
	  attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15
         ) VALUES (  p_wip_Entity_Id,
                     p_line_Id,
                     p_organization_Id,
		     SYSDATE,
	 	     p_user_id,
                     SYSDATE,
                     p_user_id,
		     p_login_id,
                     p_primary_item_Id,
                     p_alternate_bom_designator,
                     p_alternate_routing_designator,
                     p_class_code,
                     p_wip_supply_type,
                     p_completion_subinventory,
                     p_completion_locator_id,
                     p_load_distribution_priority,
                     p_primary_line_flag,
                     p_production_line_rate,
		     p_overcompletion_toleran_type,
		     p_overcompletion_toleran_value,
                     p_attribute_category,
                     p_attribute1,
                     p_attribute2,
                     p_attribute3,
                     p_attribute4,
                     p_attribute5,
                     p_attribute6,
                     p_attribute7,
                     p_attribute8,
                     p_attribute9,
                     p_attribute10,
                     p_attribute11,
                     p_attribute12,
                     p_attribute13,
                     p_attribute14,
                     p_attribute15);
  OPEN C;
  FETCH C INTO p_rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

end insert_rep_item;


procedure create_entity(p_rowid                   IN OUT NOCOPY VARCHAR2,
                 p_wip_entity_id                  IN OUT NOCOPY NUMBER,
		 p_wip_entity_name		  VARCHAR2,
		 p_description			  VARCHAR2,
                 p_line_Id                        NUMBER,
                 p_organization_id                NUMBER,
                 p_primary_item_id                NUMBER,
                 p_alternate_bom_designator       VARCHAR2,
                 p_alternate_routing_designator   VARCHAR2,
                 p_class_code                     VARCHAR2,
                 p_wip_supply_type                NUMBER,
                 p_completion_subinventory        VARCHAR2,
                 p_completion_locator_id          NUMBER,
                 p_load_distribution_priority     NUMBER,
                 p_primary_line_flag              NUMBER,
                 p_production_line_rate           NUMBER,
		 p_overcompletion_toleran_type	  NUMBER,
		 p_overcompletion_toleran_value	  NUMBER,
                 p_attribute_category             VARCHAR2,
                 p_attribute1                     VARCHAR2,
                 p_attribute2                     VARCHAR2,
                 p_attribute3                     VARCHAR2,
                 p_attribute4                     VARCHAR2,
                 p_attribute5                     VARCHAR2,
                 p_attribute6                     VARCHAR2,
                 p_attribute7                     VARCHAR2,
                 p_attribute8                     VARCHAR2,
                 p_attribute9                     VARCHAR2,
                 p_attribute10                    VARCHAR2,
                 p_attribute11                    VARCHAR2,
                 p_attribute12                    VARCHAR2,
                 p_attribute13                    VARCHAR2,
                 p_attribute14                    VARCHAR2,
                 p_attribute15                    VARCHAR2) is

x_user_id       NUMBER;
x_login_id      NUMBER;
err_msg 	VARCHAR(200);

begin
	x_user_id := fnd_global.user_id;
	x_login_id := fnd_global.login_id;

--- check discrete
	check_discrete(p_organization_id, p_wip_entity_name);

-- check if wip_entity exists, if not insert in wip_entities
	insert_entity(p_wip_entity_id, p_organization_id,
			p_wip_entity_name, p_description,
			p_primary_item_id, x_user_id, x_login_id);

-- validate primary line, now that we are assured of a wip_entity_id
 	if (p_primary_line_flag = 1) then
   		validate_primary_line(p_wip_entity_id, p_line_id,
				p_organization_id);
	end if;

-- insert into wip_rep_items
	insert_rep_item(p_rowid,
                     p_wip_entity_id,
                     p_line_id,
                     p_organization_id,
                     p_primary_item_id,
                     p_alternate_bom_designator,
                     p_alternate_routing_designator,
                     p_class_code,
                     p_wip_supply_type,
                     p_completion_subinventory,
                     p_completion_locator_id,
                     p_load_distribution_priority,
                     p_primary_line_flag,
                     p_production_line_rate,
		     p_overcompletion_toleran_type,
		     p_overcompletion_toleran_value,
                     p_attribute_category,
                     p_attribute1,
                     p_attribute2,
                     p_attribute3,
                     p_attribute4,
                     p_attribute5,
                     p_attribute6,
                     p_attribute7,
                     p_attribute8,
                     p_attribute9,
                     p_attribute10,
                     p_attribute11,
                     p_attribute12,
                     p_attribute13,
                     p_attribute14,
                     p_attribute15,
                     x_user_id,
                     x_login_id);

end create_entity;

procedure delete_entity(p_wip_entity_id	IN OUT NOCOPY NUMBER,
		    p_org_id		NUMBER,
		    p_rowid		VARCHAR2) is

temp NUMBER;
cursor check_last_entity is
select count(wip_entity_id)
from WIP_REPETITIVE_ITEMS
where organization_id = p_org_id
and wip_entity_id = p_wip_entity_id;

begin
	-- delete from wip_repetitive_items
  	delete from WIP_REPETITIVE_ITEMS
  	where  rowid = p_rowid;

  	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
  	end if;

	-- delete from wip_entities if last record
	open check_last_entity;
	fetch check_last_entity into temp;
	close check_last_entity;

	if (temp = 0) then
		delete from WIP_ENTITIES
		where organization_id = p_org_id
		and wip_entity_id = p_wip_entity_id;
	end if;
end delete_entity;

procedure update_entity(p_rowid                          VARCHAR2,
                 	p_wip_entity_id                  NUMBER,
                 	p_line_Id                        NUMBER,
                	p_organization_id                NUMBER,
	                p_primary_item_id                NUMBER,
       		        p_alternate_bom_designator       VARCHAR2,
                 	p_alternate_routing_designator   VARCHAR2,
                 	p_class_code                     VARCHAR2,
                 	p_wip_supply_type                NUMBER,
                 	p_completion_subinventory        VARCHAR2,
                 	p_completion_locator_id          NUMBER,
                 	p_load_distribution_priority     NUMBER,
                 	p_primary_line_flag              NUMBER,
                 	p_production_line_rate           NUMBER,
		 	p_overcompletion_toleran_type	  NUMBER,
		 	p_overcompletion_toleran_value	  NUMBER,
                 	p_attribute_category             VARCHAR2,
                 	p_attribute1                     VARCHAR2,
                 	p_attribute2                     VARCHAR2,
                 	p_attribute3                     VARCHAR2,
                 	p_attribute4                     VARCHAR2,
                 	p_attribute5                     VARCHAR2,
                 	p_attribute6                     VARCHAR2,
                 	p_attribute7                     VARCHAR2,
                 	p_attribute8                     VARCHAR2,
                 	p_attribute9                     VARCHAR2,
                 	p_attribute10                    VARCHAR2,
                 	p_attribute11                    VARCHAR2,
                 	p_attribute12                    VARCHAR2,
                 	p_attribute13                    VARCHAR2,
                 	p_attribute14                    VARCHAR2,
                 	p_attribute15                    VARCHAR2) is

x_userid NUMBER;
x_loginid NUMBER;
begin

  x_userid := FND_GLOBAL.USER_ID;
  x_loginid := FND_GLOBAL.LOGIN_ID;

-- validate primary line
  if (p_primary_line_flag = 1) then
   	validate_primary_line(p_wip_entity_id, p_line_id,
				p_organization_id);
  end if;

  UPDATE WIP_REPETITIVE_ITEMS
  SET
	  organization_id 		=	p_organization_id,
          last_update_date 		=	SYSDATE,
          last_updated_by		=	x_userid,
          last_update_login		=	x_loginid,
          primary_item_id		=	p_primary_item_id,
          alternate_bom_designator	=	p_alternate_bom_designator,
          alternate_routing_designator  =	p_alternate_routing_designator,
          class_code			= 	p_class_code,
          wip_supply_type		=	p_wip_supply_type,
          completion_subinventory	=	p_completion_subinventory,
          completion_locator_id		=	p_completion_locator_id,
          load_distribution_priority	=	p_load_distribution_priority,
          primary_line_flag		=	p_primary_line_flag,
          production_line_rate		=	p_production_line_rate,
	  overcompletion_tolerance_type =	p_overcompletion_toleran_type,
	  overcompletion_tolerance_value=	p_overcompletion_toleran_value,
	  attribute_category		=    	p_attribute_category,
    	  attribute1  			=    	p_attribute1,
    	  attribute2 			=    	p_attribute2,
    	  attribute3 			=    	p_attribute3,
    	  attribute4 			=    	p_attribute4,
    	  attribute5			=    	p_attribute5,
    	  attribute6  			=    	p_attribute6,
    	  attribute7 			=    	p_attribute7,
    	  attribute8 			=    	p_attribute8,
    	  attribute9 			=    	p_attribute9,
    	  attribute10 			=    	p_attribute10,
    	  attribute11			=    	p_attribute11,
    	  attribute12 			=    	p_attribute12,
    	  attribute13			=    	p_attribute13,
    	  attribute14 			=    	p_attribute14,
    	  attribute15			=   	p_attribute15
	WHERE rowid = p_rowid;

  if (SQL%NOTFOUND) then
	Raise NO_DATA_FOUND;
  end if;

end update_entity;
END WIP_REPETITIVE_ENTITY;

/
