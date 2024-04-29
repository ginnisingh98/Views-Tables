--------------------------------------------------------
--  DDL for Package WSH_REPORT_PRINTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_REPORT_PRINTERS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHRPRNS.pls 120.1.12010000.1 2008/07/29 06:18:14 appldev ship $ */

   PROCEDURE Get_Printer (
	p_concurrent_program_id 	     IN 	NUMBER,
	p_organization_id			IN   NUMBER 	default NULL,
	p_equipment_type_id 		IN 	NUMBER 	default NULL,
	p_equipment_instance 		IN 	VARCHAR2 	default NULL,
	p_label_id			     IN	NUMBER    default NULL,
	p_user_id 	     		IN 	NUMBER 	default NULL,
	p_zone 	          	     IN 	VARCHAR2 	default NULL,
	p_department_id 	     	IN 	NUMBER 	default NULL,
	p_responsibility_id 		IN 	NUMBER 	default NULL,
	p_application_id 		     IN 	NUMBER 	default NULL,
	p_site_id 	          	IN 	NUMBER 	default NULL,
        p_format_id                     IN      NUMBER  default NULL,
	x_printer			     	OUT NOCOPY   VARCHAR2,
	x_api_status       			OUT NOCOPY   VARCHAR2,
	x_error_message    			OUT NOCOPY   VARCHAR2
   );

   TYPE LevelTyp IS RECORD (
	priority_seq            BINARY_INTEGER,
	level_type_id           BINARY_INTEGER,
	level_value_id          VARCHAR2(10));

   TYPE LevelTabTyp IS TABLE OF LevelTyp INDEX BY BINARY_INTEGER;

   level_table 	LevelTabTyp;


END WSH_REPORT_PRINTERS_PVT;

/
