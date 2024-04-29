--------------------------------------------------------
--  DDL for Package WMS_TASK_DISPATCH_DEVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_DISPATCH_DEVICE" AUTHID CURRENT_USER AS
/* $Header: WMSTKDVS.pls 120.4 2005/10/09 03:40:07 simran noship $ */


PROCEDURE insert_device
  (p_Employee_Id     IN NUMBER,
   p_device_id       IN NUMBER,
   p_org_id          IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2);



PROCEDURE cleanup_device_and_tasks(
   p_Employee_Id     IN NUMBER,
   p_org_id          IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2,
   x_msg_count       OUT  NOCOPY NUMBER,
   x_msg_data        OUT  NOCOPY VARCHAR2,
   p_retain_dispatched_tasks IN VARCHAR2 default 'N');


/*
   This is the overloaded procedure
   It takes one additional parameter p_device_id
     The call to sync_device
     Deleting From Wms_device_assignment_temp &
     Deleting or Updating WDT
   will be only for that particular device
*/
PROCEDURE cleanup_device_and_tasks(
   p_Employee_Id     IN NUMBER,
   p_org_id          IN NUMBER,
   p_device_id       IN NUMBER,
   x_return_status   OUT  NOCOPY VARCHAR2,
   x_msg_count       OUT  NOCOPY NUMBER,
   x_msg_data        OUT  NOCOPY VARCHAR2,
   p_retain_dispatched_tasks IN VARCHAR2 default 'N');


PROCEDURE get_device_info(p_organization_id IN NUMBER,
			  p_device_name IN VARCHAR2,
			  x_return_status OUT NOCOPY VARCHAR2,
			  x_device_id OUT NOCOPY NUMBER,
			  x_device_type OUT NOCOPY VARCHAR2,
			  x_device_desc OUT NOCOPY VARCHAR2,
			  x_subinventory OUT NOCOPY VARCHAR2,
           p_emp_id IN NUMBER,
           x_signed_onto_wrk_stn OUT NOCOPY VARCHAR2);


FUNCTION get_eligible_device(
                p_organization_id  IN NUMBER
		, p_subinventory     IN VARCHAR2
		, p_locator_id       IN NUMBER

) return NUMBER;



END WMS_Task_Dispatch_Device;

 

/
