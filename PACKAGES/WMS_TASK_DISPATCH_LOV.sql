--------------------------------------------------------
--  DDL for Package WMS_TASK_DISPATCH_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_DISPATCH_LOV" AUTHID CURRENT_USER AS
/* $Header: WMSTSKLS.pls 120.2 2005/12/14 06:24:41 nsrivast noship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_TASKS_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_user_Id restrict LOV to a given user
--       p_lpn_id This will be passed only for patchset I
--
--      Output parameters:
--       x_tasks      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org, item and
--                 user input text
--
--  HISTORY
--


PROCEDURE get_item_lov
  (x_Items OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_Concatenated_Segments IN VARCHAR2,
   p_where_clause IN VARCHAR2,
   p_lpn_id  IN NUMBER DEFAULT NULL
   );


PROCEDURE get_tasks_lov
  (x_tasks           OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_User_Id         IN NUMBER,
   p_concat_segments IN VARCHAR2,
   p_page_type       IN VARCHAR2 DEFAULT NULL
   );


PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
			  p_reason_type     IN NUMBER,
			  p_concat_segments IN VARCHAR2);

-- Procedure overloaded for Transaction Reason Security build.
-- 4505091, nsrivast
PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
			  p_reason_type     IN NUMBER,
			  p_concat_segments IN VARCHAR2,
			  p_txn_type_id     IN NUMBER );

-- Overloaded procedure for the reason LOV in the discrepancy page for APL
PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
			  p_reason_type     IN NUMBER,
			  p_reason_contexts IN VARCHAR2,
			  p_concat_segments IN VARCHAR2);

-- Procedure overloaded for Transaction Reason Security build.
-- 4505091, nsrivast
PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
			  p_reason_type     IN NUMBER,
			  p_reason_contexts IN VARCHAR2,
			  p_concat_segments IN VARCHAR2,
			  p_txn_type_id     IN VARCHAR2 );


PROCEDURE GET_LPN_ITEMS_LOV(x_items         OUT NOCOPY t_genref,
			  p_lpn_id          IN NUMBER,
			  p_concat_segments IN VARCHAR2);


PROCEDURE get_container_items_lov
  (x_container_items OUT NOCOPY t_genref,
   p_org_id          IN NUMBER,
   p_concat_segments IN VARCHAR2);

PROCEDURE validate_container_items
  (p_organization_id    IN NUMBER,
   p_concat_segments    IN VARCHAR2,
   x_is_valid_container OUT NOCOPY VARCHAR2,
   x_container_item_id  OUT NOCOPY NUMBER);


--      Name: GET_EQP_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_concat_segment user input
--      Output parameters:
--       x_eqps      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org and
--                 user input text
--
--
--

PROCEDURE get_eqp_lov
  (x_eqps            OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_concat_segments IN VARCHAR2);

--      Name: GET_DEVICE_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_concat_segment user input
--      Output parameters:
--       x_devices      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org and
--                 user input text
--
--
--

PROCEDURE get_device_lov
  (x_devices         OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_concat_segments IN VARCHAR2);

--      Name: GET_CURRENT_DEVICE_LOV
--
--      Input parameters:
--       p_employee_id   which restricts LOV SQL to current employee
--       p_concat_segment user input
--      Output parameters:
--       x_devices      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given user and
--                 user input text
--
--

PROCEDURE get_current_device_lov
  (x_devices         OUT NOCOPY t_genref,
   p_Employee_Id     IN NUMBER,
   p_concat_segments IN VARCHAR2);


FUNCTION get_locator(p_wms_task_type IN NUMBER,
		     p_locator_id IN NUMBER,
		     p_transfer_to_location_id IN NUMBER,
		     p_transaction_type_id IN NUMBER,
		     p_organization_id     IN NUMBER)
  RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(get_locator,WNDS);



END WMS_Task_Dispatch_LOV;

 

/
