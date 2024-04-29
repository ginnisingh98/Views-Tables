--------------------------------------------------------
--  DDL for Package PA_RESOURCE_UTILS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_UTILS1" AUTHID CURRENT_USER AS
--$Header: PARCSUS1.pls 120.1 2005/08/19 16:49:43 mwasowic noship $

PROCEDURE Return_Material_Class_Id(
			x_material_class_id OUT NOCOPY PA_PLAN_RES_DEFAULTS.item_master_id%TYPE, --File.Sql.39 bug 4440895
                        x_return_status OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                        x_msg_data      OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                        x_msg_count     OUT NOCOPY Number --File.Sql.39 bug 4440895
                );
END PA_RESOURCE_UTILS1;

 

/
