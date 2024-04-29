--------------------------------------------------------
--  DDL for Package MRP_FORECAST_INTERFACE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FORECAST_INTERFACE_PK" AUTHID CURRENT_USER AS
    /* $Header: MRPFAPIS.pls 115.10 2002/11/26 01:33:08 ichoudhu ship $ */

	TYPE rec_forecast_designator IS
		RECORD (  organization_id NUMBER, forecast_designator VARCHAR2(10),
				inventory_item_id NUMBER DEFAULT NULL);
	TYPE t_forecast_designator IS
		TABLE of rec_forecast_designator INDEX BY BINARY_INTEGER;

        TYPE quantity_per_day_rec_type IS RECORD
		( work_date DATE,
		  quantity  NUMBER);

        TYPE quantity_per_day_tbl_type IS TABLE OF quantity_per_day_rec_type
		INDEX BY BINARY_INTEGER;

/* 1336039 - SVAIDYAN: Add attribute_category to the pl/sql table for
   forecast interface. */

	TYPE rec_forecast_interface IS
		RECORD
				(INVENTORY_ITEM_ID               NUMBER,
				 FORECAST_DESIGNATOR             VARCHAR2(10),
				 ORGANIZATION_ID                 NUMBER,
				 FORECAST_DATE                   DATE,
				 LAST_UPDATE_DATE                DATE,
				 LAST_UPDATED_BY                 NUMBER,
				 CREATION_DATE                   DATE,
				 CREATED_BY                      NUMBER,
				 LAST_UPDATE_LOGIN               NUMBER,
				 QUANTITY                        NUMBER,
				 PROCESS_STATUS                  NUMBER,
				 CONFIDENCE_PERCENTAGE           NUMBER,
				 COMMENTS                        VARCHAR2(240),
				 ERROR_MESSAGE                   VARCHAR2(240),
				 REQUEST_ID                      NUMBER,
				 PROGRAM_APPLICATION_ID          NUMBER,
				 PROGRAM_ID                      NUMBER,
				 PROGRAM_UPDATE_DATE             DATE,
				 WORKDAY_CONTROL                 NUMBER,
				 BUCKET_TYPE                     NUMBER,
				 FORECAST_END_DATE               DATE,
				 TRANSACTION_ID                  NUMBER,
				 SOURCE_CODE                     VARCHAR2(10),
				 SOURCE_LINE_ID                  NUMBER,
				 ATTRIBUTE1                      VARCHAR2(150),
				 ATTRIBUTE2                      VARCHAR2(150),
				 ATTRIBUTE3                      VARCHAR2(150),
				 ATTRIBUTE4                      VARCHAR2(150),
				 ATTRIBUTE5                      VARCHAR2(150),
				 ATTRIBUTE6                      VARCHAR2(150),
				 ATTRIBUTE7                      VARCHAR2(150),
				 ATTRIBUTE8                      VARCHAR2(150),
				 ATTRIBUTE9                      VARCHAR2(150),
				 ATTRIBUTE10                     VARCHAR2(150),
				 ATTRIBUTE11                     VARCHAR2(150),
				 ATTRIBUTE12                     VARCHAR2(150),
				 ATTRIBUTE13                     VARCHAR2(150),
				 ATTRIBUTE14                     VARCHAR2(150),
				 ATTRIBUTE15                     VARCHAR2(150),
				 PROJECT_ID                      NUMBER,
				 TASK_ID                         NUMBER,
				 LINE_ID                         NUMBER,
                                 ACTION                          VARCHAR2(1),
                                 ATTRIBUTE_CATEGORY              VARCHAR2(30));
	TYPE t_forecast_interface IS
		TABLE of rec_forecast_interface INDEX BY BINARY_INTEGER;

    FUNCTION mrp_forecast_interface(
                forecast_interface 		IN OUT NOCOPY      t_forecast_interface,
                forecast_designator   	IN OUT NOCOPY  	t_forecast_designator)
		RETURN BOOLEAN;
    FUNCTION mrp_forecast_interface(
                forecast_interface 		IN OUT NOCOPY      t_forecast_interface)
		RETURN BOOLEAN;
    FUNCTION mrp_forecast_interface(
                forecast_designator   	IN OUT NOCOPY  	t_forecast_designator)
		RETURN BOOLEAN;

    PROCEDURE quantity_per_day(x_return_status OUT NOCOPY VARCHAR2,
        	x_msg_count OUT NOCOPY NUMBER,
        	x_msg_data OUT NOCOPY VARCHAR2,
		p_organization_id IN NUMBER,
		p_workday_control IN NUMBER,
		p_start_date IN DATE,
		p_end_date IN DATE,
		p_quantity IN NUMBER,
		x_workday_count OUT NOCOPY NUMBER,
		x_quantity_per_day OUT NOCOPY QUANTITY_PER_DAY_TBL_TYPE);

END MRP_FORECAST_INTERFACE_PK;

 

/
