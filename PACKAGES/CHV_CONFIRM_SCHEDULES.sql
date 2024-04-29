--------------------------------------------------------
--  DDL for Package CHV_CONFIRM_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_CONFIRM_SCHEDULES" AUTHID CURRENT_USER as
/* $Header: CHVPRCSS.pls 115.1 2002/11/25 19:52:55 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:  CHV_CONFIRM_SCHEDULES
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to confirm schedules

  CLIENT/SERVER: Server

  OWNER:         Sri Rumalla

  NOTE:

  FUNCTION/PROCEDURE
		 confirm_schedule_item()
		 confirm_schedule_header()

============================================================================*/

/*===========================================================================
  FUNCTION NAME       :  confirm_schedule_item

  DESCRIPTION         :  Confirm_schedules is a procedure that will confirm
                         the schedule by updating schedule status.

  PARAMETERS          :  p_schedule_id             in NUMBER,
                         p_schedule_item_id        in NUMBER,
			 p_vendor_id               in NUMBER,
			 p_vendor_site_id          in NUMBER,
			 p_organization_id         in NUMBER,
			 p_item_id                 in NUMBER,
                         RETURN BOOLEAN

  DESIGN REFERENCES   :

  ALGORITHM           :

  NOTES               :

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            14-MAY-1995     SXLIU
==========================================================================*/
FUNCTION confirm_schedule_item(p_schedule_id             in NUMBER,
                               p_schedule_item_id        in NUMBER,
	  		       p_vendor_id               in NUMBER,
			       p_vendor_site_id          in NUMBER,
			       p_organization_id         in NUMBER,
			       p_item_id                 in NUMBER)
                              return boolean ;

/*===========================================================================
  PROCEDURE NAME      :  confirm_schedule_header

  DESCRIPTION         :  Confirm_schedule_header is a procedure that will confirm
                         the schedule by updating schedule status, calling
                         API to calculate high authorizations, communicating
                         the schedule based on the communication method.

  PARAMETERS          :  p_schedule_id             in NUMBER,
                         p_schedule_type           in VARCHAR2,
                         p_communication_code      in VARCHAR2 default null,
                         p_confirm_source          in VARCHAR2,
                         p_confirmed               in out VARCHAR2

  DESIGN REFERENCES   :

  ALGORITHM           :

  NOTES               :

  OPEN ISSUES         :

  CLOSED ISSUES       :

  CHANGE HISTORY      :  Created            14-MAY-1995     SXLIU
==========================================================================*/
PROCEDURE confirm_schedule_header(p_schedule_id             in NUMBER,
                                  p_schedule_type           in VARCHAR2,
                                  p_communication_code      in VARCHAR2 default null,
                                  p_confirm_source          in VARCHAR2,
                                  p_confirmed               in out NOCOPY VARCHAR2);
END CHV_CONFIRM_SCHEDULES;

 

/
