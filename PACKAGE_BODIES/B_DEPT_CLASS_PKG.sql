--------------------------------------------------------
--  DDL for Package Body B_DEPT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."B_DEPT_CLASS_PKG" as
/* $Header: bompbdcb.pls 115.1 99/07/16 05:47:22 porting ship $ */

PROCEDURE Check_Unique(X_Org_Id NUMBER,
		       X_Department_Class_Code VARCHAR2) IS
  dummy number;
BEGIN
  select 1 into dummy from dual where not exists
    (select 1
     from   bom_department_classes
     where  department_class_code = x_department_class_code
     and    organization_id = x_org_id);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     fnd_message.set_name ('BOM','BOM_ALREADY_EXISTS');
     fnd_message.set_token ('ENTITY1', 'Department class code');
     fnd_message.set_token ('ENTITY2', x_department_class_code);
     APP_EXCEPTION.RAISE_EXCEPTION;

END Check_Unique;

PROCEDURE Check_References(X_Org_Id NUMBER,
		           X_Department_Class_Code VARCHAR2) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from dual where not exists
    (select 1
     from   bom_departments
     where  organization_id = x_org_id
     and    department_class_code = x_department_class_code);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name ('BOM', 'BOM_DEPT_CLASS_IN_USE');
    fnd_message.set_token ('ENTITY', x_department_class_code, TRUE);
    app_exception.raise_exception;

END Check_References;

END B_DEPT_CLASS_PKG;

/
