--------------------------------------------------------
--  DDL for Package GL_SCHEDULER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SCHEDULER_PKG" AUTHID CURRENT_USER AS
/* $Header: gluschis.pls 120.2 2005/05/05 01:43:24 kvora ship $ */

FUNCTION create_schedule( sched_name       IN VARCHAR2,
	                  calendar_name    IN VARCHAR2,
                          period_type_name IN VARCHAR2,
                          run_day          IN NUMBER,
                          run_time         IN VARCHAR2,
	                  create_flag      IN BOOLEAN )
RETURN NUMBER;

FUNCTION cleanup_schedule( sched_name  	   IN VARCHAR2 )
RETURN NUMBER;

FUNCTION update_schedules( x_period_set_name IN VARCHAR2 )
RETURN NUMBER;

END gl_scheduler_pkg;


 

/
