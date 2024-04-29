--------------------------------------------------------
--  DDL for Package CSM_CTR_PROP_READ_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CTR_PROP_READ_EVENT_PKG" 
/* $Header: csmecprs.pls 120.1 2006/07/25 11:22:05 trajasek noship $ */
AUTHID CURRENT_USER AS
--
-- Purpose: USed to downlaod Counter property readings for each counter property
-- MODIFICATION HISTORY
-- Person      Date    Comments
-----------------------------------------------------------

 PROCEDURE CTR_PROPERTY_READ_INS( p_counter_value_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

 PROCEDURE CTR_PROPERTY_READ_UPD( p_counter_value_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

 PROCEDURE CTR_PROPERTY_READ_DEL( p_counter_value_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

 PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);


END CSM_CTR_PROP_READ_EVENT_PKG; -- Package spec of CSM_CTR_PROP_READ_EVENT_PKG

 

/
