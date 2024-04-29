--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_WORK_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_WORK_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: iextswis.pls 120.0.12010000.2 2008/08/06 09:03:52 schekuri ship $ */
PROCEDURE Insert_Row(
          X_ROWID                 IN OUT NOCOPY VARCHAR2
         ,x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_CREATION_DATE IN   DATE
         ,x_CREATED_BY    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
         ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
	 ,x_escalated_yn in CHAR
         );


PROCEDURE Update_Row(

         x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
         ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
	 ,x_escalated_yn in CHAR
         );

/*PROCEDURE Lock_Row(
         x_WORK_ITEM_ID   IN  NUMBER
         ,x_STRATEGY_ID    IN NUMBER
         ,x_work_item_template_id IN NUMBER
         ,x_RESOURCE_ID    IN NUMBER
         ,x_STATUS_CODE    IN VARCHAR2
         ,x_execute_start   IN DATE
         ,x_execute_end     IN DATE
         ,x_LAST_UPDATE_LOGIN    IN NUMBER
         ,x_CREATION_DATE IN   DATE
         ,x_CREATED_BY    IN NUMBER
         ,x_LAST_UPDATE_DATE    DATE
        ,x_last_updated_by  IN NUMBER
         ,x_OBJECT_VERSION_NUMBER    IN NUMBER
         ,X_REQUEST_ID              in  NUMBER
         ,X_PROGRAM_APPLICATION_ID  in  NUMBER
         ,X_PROGRAM_ID              in  NUMBER
         ,X_PROGRAM_UPDATE_DATE     in  DATE
         ,x_schedule_start          in  DATE
         ,x_schedule_end            in  DATE
         ,x_strategy_temp_id        in NUMBER
         ,x_work_item_order         in NUMBER
         );

*/
procedure LOCK_ROW (
  x_WORK_ITEM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

PROCEDURE Delete_Row(
    x_WORK_ITEM_ID  IN NUMBER);

End IEX_STRATEGY_WORK_ITEMS_PKG;

/
