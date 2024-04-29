--------------------------------------------------------
--  DDL for Package CAC_CAL_PRIVS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_CAL_PRIVS_PVT" AUTHID CURRENT_USER AS
/* $Header: caccpvs.pls 120.0 2005/08/10 20:44:28 akaran noship $ */

  PROCEDURE CREATE_GRANTS
  ( p_grantee_user_name      IN  VARCHAR2
  , p_grantee_start_date     IN  DATE
  , p_grantee_end_date       IN  DATE
  , p_appointment_access     IN  VARCHAR2
  , p_task_access            IN  VARCHAR2
  , p_booking_access         IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
  );


  PROCEDURE UPDATE_GRANTS
  ( p_grantee_user_name      IN  VARCHAR2
  , p_grantee_start_date     IN  DATE
  , p_grantee_end_date       IN  DATE
  , p_appointment_access     IN  VARCHAR2
  , p_task_access            IN  VARCHAR2
  , p_booking_access         IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
  );


END CAC_CAL_PRIVS_PVT;

 

/
