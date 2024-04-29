--------------------------------------------------------
--  DDL for Package MRP_GRAPH_LINE_CAPACITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GRAPH_LINE_CAPACITY" AUTHID CURRENT_USER AS
/* $Header: MRPGLCPS.pls 115.4 99/07/16 12:21:18 porting ship $ */


-- Define constants
NUM_OF_COLUMNS		CONSTANT INTEGER := 36;

-- Define types
TYPE mrp_capacity IS RECORD
	(department_id	NUMBER,
	 resource_id	NUMBER,
         line_id   	NUMBER,
         bucket_number  NUMBER,
	 bucket_date	DATE,
	 bucket_qty	NUMBER);

TYPE bucket_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE bucket_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

-- Define procedures
PROCEDURE Load_Capacity_Records(p_plan_id IN NUMBER,
				p_line_id IN NUMBER,
				p_org_id IN NUMBER,
				p_start_date IN DATE);

END MRP_GRAPH_LINE_CAPACITY;

 

/
