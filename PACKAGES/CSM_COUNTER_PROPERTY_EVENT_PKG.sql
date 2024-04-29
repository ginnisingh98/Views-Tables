--------------------------------------------------------
--  DDL for Package CSM_COUNTER_PROPERTY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_COUNTER_PROPERTY_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmecpts.pls 120.0 2006/07/24 12:53:11 trajasek noship $ */

--
-- Purpose: USed to downlaod Counter properties for each counter
-- MODIFICATION HISTORY
-- Person      Date    Comments
-----------------------------------------------------------

 PROCEDURE COUNTER_PROPERTY_INS( p_counter_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

 PROCEDURE COUNTER_PROPERTY_UPD( p_counter_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

 PROCEDURE COUNTER_PROPERTY_DEL( p_counter_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2);

END CSM_COUNTER_PROPERTY_EVENT_PKG; -- Package spec of CSM_COUNTER_PROPERTY_EVENT_PKG

 

/
