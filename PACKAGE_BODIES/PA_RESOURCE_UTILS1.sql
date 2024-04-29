--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_UTILS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_UTILS1" as
--$Header: PARCSUB1.pls 120.2 2005/08/24 02:40:34 avaithia noship $

/*==============================================================================
This api Returns the item master id for the material class item
=============================================================================*/


PROCEDURE Return_Material_Class_Id(
                        x_material_class_id     OUT NOCOPY PA_PLAN_RES_DEFAULTS.item_master_id%TYPE, --File.Sql.39 bug 4440895
                        x_return_status         OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                        x_msg_data              OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                        x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                )
IS
BEGIN

x_return_status:='S';
x_msg_data:=null;
x_msg_count:=null;

select item_master_id into x_material_class_id
from PA_PLAN_RES_DEFAULTS
where resource_class_id=3;


EXCEPTION
WHEN OTHERS THEN
x_return_status:='U'; -- 4537865 : Changed from E to U
x_msg_data:=SUBSTRB(sqlerrm,1,240); -- 4537865 : Changed from sqlerrm to SUBSTRB(sqlerrm,1,240)
x_msg_count:=1;
 -- 4537865 : Add Exception msg to stack and RAISE
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_RESOURCE_UTILS1'
                    , p_procedure_name  => 'Return_Material_Class_Id'
		   , p_error_text      => x_msg_data);
RAISE;
END Return_Material_Class_Id;

END PA_RESOURCE_UTILS1;

/
