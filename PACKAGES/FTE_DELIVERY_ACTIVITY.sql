--------------------------------------------------------
--  DDL for Package FTE_DELIVERY_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DELIVERY_ACTIVITY" AUTHID CURRENT_USER AS
/* $Header: FTEDLACS.pls 120.0 2005/05/26 17:36:29 appldev noship $ */

--===================
-- TYPES
--===================
-- Rel 12 HBHAGAVA
TYPE delivery_leg_activity_rec IS RECORD (
  ACTIVITY_ID             NUMBER,
  DELIVERY_LEG_ID         NUMBER,
  ACTIVITY_DATE           DATE  ,
  ACTIVITY_TYPE           VARCHAR2(30),
  CREATION_DATE           DATE        ,
  CREATED_BY              NUMBER      ,
  LAST_UPDATE_DATE        DATE        ,
  LAST_UPDATED_BY         NUMBER      ,
  LAST_UPDATE_LOGIN       NUMBER,
  PROGRAM_APPLICATION_ID  NUMBER,
  PROGRAM_ID              NUMBER,
  PROGRAM_UPDATE_DATE     DATE,
  REQUEST_ID              NUMBER,
  ATTRIBUTE_CATEGORY      VARCHAR2(240),
  ATTRIBUTE1              VARCHAR2(240),
  ATTRIBUTE2              VARCHAR2(240),
  ATTRIBUTE3              VARCHAR2(240),
  ATTRIBUTE4              VARCHAR2(240),
  ATTRIBUTE5              VARCHAR2(240),
  ATTRIBUTE6              VARCHAR2(240),
  ATTRIBUTE7              VARCHAR2(240),
  ATTRIBUTE8              VARCHAR2(240),
  ATTRIBUTE9              VARCHAR2(240),
  ATTRIBUTE10             VARCHAR2(240),
  ATTRIBUTE11             VARCHAR2(240),
  ATTRIBUTE12             VARCHAR2(240),
  ATTRIBUTE13             VARCHAR2(240),
  ATTRIBUTE14             VARCHAR2(240),
  ATTRIBUTE15             VARCHAR2(240),
  ACTION_BY               NUMBER,
  ACTION_BY_NAME          VARCHAR2(255),
  REMARKS                 VARCHAR2(2000),
  RESULT_STATUS           VARCHAR2(30),
  INITIAL_STATUS          VARCHAR2(30),
  TRIP_ID                 NUMBER,
  CARRIER_ID              NUMBER,
  MODE_OF_TRANSPORT       VARCHAR2(30),
  SERVICE_LEVEL           VARCHAR2(30),
  RANK_ID                 NUMBER,
  RANK_VERSION            NUMBER,
  WF_ITEM_KEY             VARCHAR2(240)
	);


--===================
-- PROCEDURES
--===================

PROCEDURE ADD_HISTORY(

                p_delivery_id           IN NUMBER,
                p_delivery_leg_id       IN NUMBER,
                p_trip_id               IN NUMBER,
                p_activity_date         IN DATE,
                p_activity_type         IN VARCHAR2,
                p_request_id            IN NUMBER,
                p_action_by             IN NUMBER,
                p_action_by_name        IN VARCHAR2,
                p_remarks               IN VARCHAR2,
                p_result_status         IN VARCHAR2,
                p_initial_status        IN VARCHAR2,
		p_carrier_id		IN NUMBER,
		p_mode_of_transport     IN VARCHAR2,
		p_service_level         IN VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_error_msg             OUT NOCOPY VARCHAR2,
		x_error_tkn         	OUT NOCOPY VARCHAR2);

PROCEDURE ADD_HISTORY(

                p_trip_id               IN NUMBER,
                p_activity_date         IN DATE,
                p_activity_type         IN VARCHAR2,
                p_request_id            IN NUMBER,
                p_action_by             IN NUMBER,
                p_action_by_name        IN VARCHAR2,
                p_remarks               IN VARCHAR2,
                p_result_status         IN VARCHAR2,
                p_initial_status        IN VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_error_msg             OUT NOCOPY VARCHAR2,
		x_error_tkn         	OUT NOCOPY VARCHAR2);

PROCEDURE ADD_HISTORY(
		p_init_msg_list           IN     VARCHAR2,
		p_trip_id		  IN	 NUMBER,
		p_delivery_leg_activity_rec IN delivery_leg_activity_rec,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2);


END FTE_DELIVERY_ACTIVITY;

 

/
