--------------------------------------------------------
--  DDL for Package Body FLM_KANBAN_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_KANBAN_SUMMARY_PKG" as
/* $Header: FLMKBNSB.pls 115.4 2002/11/27 11:04:08 nrajpal noship $ */

PROCEDURE Insert_Row(X_rowid                  IN OUT NOCOPY VARCHAR2,
		     X_summary_id	      IN OUT NOCOPY NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER) IS

   CURSOR C1 IS SELECT rowid FROM FLM_KANBAN_SUMMARY
             WHERE summary_id = X_summary_id;
   CURSOR C2 IS SELECT flm_kanban_summary_s.nextval FROM sys.dual;

BEGIN
   if (X_summary_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_summary_id;
     CLOSE C2;
   end if;
   INSERT INTO FLM_KANBAN_SUMMARY(
	   SUMMARY_ID
	  ,ORGANIZATION_ID
	  ,SUMMARY_TYPE
	  ,SUMMARY_CODE
	  ,KANBAN_PLAN_ID
	  ,CREATED_BY
	  ,CREATION_DATE
	  ,LAST_UPDATED_BY
	  ,LAST_UPDATE_DATE
	  ,LAST_UPDATE_LOGIN
	  ,NODE_TYPE
	  ,SOURCE_ORGANIZATION_ID
	  ,SUPPLIER_ID
	  ,SUPPLIER_SITE_ID
	  ,SUBINVENTORY_NAME
	  ,LOCATOR_ID
	  ,WIP_LINE_ID
	  ,X_COORDINATE
	  ,Y_COORDINATE
         ) VALUES (
	   X_SUMMARY_ID
	  ,X_ORGANIZATION_ID
	  ,X_SUMMARY_TYPE
	  ,X_SUMMARY_CODE
	  ,X_KANBAN_PLAN_ID
	  ,FND_GLOBAL.USER_ID
	  ,SYSDATE
	  ,FND_GLOBAL.USER_ID
	  ,SYSDATE
	  ,FND_GLOBAL.LOGIN_ID
	  ,X_NODE_TYPE
	  ,X_SOURCE_ORGANIZATION_ID
	  ,X_SUPPLIER_ID
	  ,X_SUPPLIER_SITE_ID
	  ,X_SUBINVENTORY_NAME
	  ,X_LOCATOR_ID
	  ,X_WIP_LINE_ID
	  ,X_X
	  ,X_Y
	 );

  OPEN C1;
  FETCH C1 INTO X_rowid;
  if (C1%NOTFOUND) then
    CLOSE C1;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C1;
END Insert_Row;


PROCEDURE Lock_Row(  X_rowid                                VARCHAR2,
		     X_summary_id			    NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER) IS

  CURSOR C IS
      SELECT *
      FROM FLM_KANBAN_SUMMARY
      WHERE rowid = X_rowid
      FOR UPDATE of summary_id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.summary_id = X_summary_id)
           OR (    (Recinfo.summary_id IS NULL)
               AND (X_summary_id IS NULL)))
      AND (   (Recinfo.organization_id = X_organization_id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_organization_id IS NULL)))
      AND (   (Recinfo.summary_type = X_summary_type)
           OR (    (Recinfo.summary_type IS NULL)
               AND (X_summary_type IS NULL)))
      AND (   (Recinfo.summary_code = X_summary_code)
           OR (    (Recinfo.summary_code IS NULL)
               AND (X_summary_code IS NULL)))
      AND (   (Recinfo.kanban_plan_id = X_kanban_plan_id)
           OR (    (Recinfo.kanban_plan_id IS NULL)
               AND (X_kanban_plan_id IS NULL)))
      AND (   (Recinfo.node_type = X_node_type)
           OR (    (Recinfo.node_type IS NULL)
               AND (X_node_type IS NULL)))
      AND (   (Recinfo.source_organization_id = X_source_organization_id)
           OR (    (Recinfo.source_organization_id IS NULL)
               AND (X_source_organization_id IS NULL)))
      AND (   (Recinfo.supplier_id = X_supplier_id)
           OR (    (Recinfo.supplier_id IS NULL)
               AND (X_supplier_id IS NULL)))
      AND (   (Recinfo.supplier_site_id = X_supplier_site_id)
           OR (    (Recinfo.supplier_site_id IS NULL)
               AND (X_supplier_site_id IS NULL)))
      AND (   (Recinfo.subinventory_name = X_subinventory_name)
           OR (    (Recinfo.subinventory_name IS NULL)
               AND (X_subinventory_name IS NULL)))
      AND (   (Recinfo.locator_id = X_locator_id)
           OR (    (Recinfo.locator_id IS NULL)
               AND (X_locator_id IS NULL)))
      AND (   (Recinfo.wip_line_id = X_wip_line_id)
           OR (    (Recinfo.wip_line_id IS NULL)
               AND (X_wip_line_id IS NULL)))
      AND (   (Recinfo.x_coordinate = X_x)
           OR (    (Recinfo.x_coordinate IS NULL)
               AND (X_x IS NULL)))
      AND (   (Recinfo.y_coordinate = X_y)
           OR (    (Recinfo.y_coordinate IS NULL)
               AND (X_y IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;



PROCEDURE Update_Row(X_rowid                                VARCHAR2,
		     X_summary_id			    NUMBER,
                     X_organization_id      	     	    NUMBER,
                     X_summary_type                         NUMBER,
                     X_summary_code                         VARCHAR2,
                     X_kanban_plan_id			    NUMBER,
                     X_node_type			    NUMBER,
                     X_source_organization_id               NUMBER,
                     X_supplier_id                          NUMBER,
                     X_supplier_site_id                     NUMBER,
                     X_subinventory_name                    VARCHAR2,
                     X_locator_id                           NUMBER,
                     X_wip_line_id                          NUMBER,
                     X_x		                    NUMBER,
                     X_y                                    NUMBER) IS

BEGIN
  UPDATE FLM_KANBAN_SUMMARY
  SET
    summary_id			=    X_summary_id,
    organization_id		=    X_organization_id,
    summary_type		=    X_summary_type,
    summary_code		=    X_summary_code,
    kanban_plan_id		=    X_kanban_plan_id,
    LAST_UPDATED_BY         	=    FND_GLOBAL.USER_ID,
    LAST_UPDATE_DATE           	=    SYSDATE,
    LAST_UPDATE_LOGIN		=    FND_GLOBAL.LOGIN_ID,
    node_type			=    X_node_type,
    source_organization_id	=    X_source_organization_id,
    supplier_id			=    X_supplier_id,
    supplier_site_id		=    X_supplier_site_id,
    subinventory_name		=    X_subinventory_name,
    locator_id			=    X_locator_id,
    wip_line_id			=    X_wip_line_id,
    x_coordinate		=    X_x,
    y_coordinate		=    X_y
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_rowid VARCHAR2) IS

BEGIN
  DELETE FROM FLM_KANBAN_SUMMARY
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
END Delete_Row;


END FLM_KANBAN_SUMMARY_PKG;

/
