--------------------------------------------------------
--  DDL for Package PJI_EV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_EV_UTIL" AUTHID CURRENT_USER AS
-- $Header: PJIPREVS.pls 120.1 2005/09/16 15:23:51 appldev noship $

PROCEDURE populate_percent_complete
	(p_start_date           IN VARCHAR2,
	 p_end_date             IN VARCHAR2,
	 p_calendar_id          IN NUMBER,
	 p_slice_name           IN VARCHAR2,
	 p_project_id           IN VARCHAR2,
	 p_proj_element_id      IN VARCHAR2,
	 p_structure_version_id	IN	NUMBER,
	p_include_sub_tasks_flag	IN VARCHAR2 ,
	p_calendar_type	IN VARCHAR2,
	p_prg_flag IN VARCHAR2,
	 x_msg_count            IN OUT NOCOPY NUMBER,
	 x_return_status        OUT NOCOPY VARCHAR2,
	 x_err_msg_data         OUT NOCOPY VARCHAR2) ;


END Pji_Ev_Util;

 

/
