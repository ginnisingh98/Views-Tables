--------------------------------------------------------
--  DDL for Package WIP_FLOW_COMPLETION_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOW_COMPLETION_FILTER" AUTHID CURRENT_USER AS
/* $Header: wipfwocs.pls 115.7 2002/11/28 19:41:34 rmahidha ship $  */

TYPE ret_sch_rec is RECORD (
  wip_entity_id NUMBER,
  completion_subinventory VARCHAR2(10),
  completion_locator_id NUMBER,
  quantity NUMBER );

TYPE ret_sch_t IS TABLE OF ret_sch_rec index by binary_integer;

PROCEDURE retrieve_schedules (i_where IN VARCHAR2, i_default_sub IN VARCHAR2,
                              i_default_loc IN NUMBER,
			      i_org_locator_control IN NUMBER,
			      i_qty_retrieve IN NUMBER,
			      i_num_records IN NUMBER,
                              o_result OUT NOCOPY ret_sch_t,
			      o_restrict_error OUT NOCOPY BOOLEAN,
			      o_lot_serial_error OUT NOCOPY BOOLEAN,
                              o_error_num OUT NOCOPY NUMBER,
			      o_error_msg OUT NOCOPY VARCHAR2);

FUNCTION loc_control(org_control      IN    number,
                     sub_control      IN    number,
                     item_control     IN    number default NULL,
                     restrict_flag    IN    Number default NULL)
                     return number;

END wip_flow_completion_filter;

 

/
