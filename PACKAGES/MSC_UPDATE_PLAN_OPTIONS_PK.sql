--------------------------------------------------------
--  DDL for Package MSC_UPDATE_PLAN_OPTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_UPDATE_PLAN_OPTIONS_PK" AUTHID CURRENT_USER AS
/* $Header: MSCPUPLS.pls 120.0 2005/05/25 19:56:42 appldev noship $ */

	PROCEDURE 	msc_update_options (
									arg_plan_id IN NUMBER,
									arg_user_id IN NUMBER);

	PROCEDURE   msc_set_completion_time (
						arg_plan_id IN NUMBER,
						arg_user_id IN NUMBER);

	SYS_NO				CONSTANT INTEGER := 2;
	VERSION             CONSTANT CHAR(80) :=
			'$Header: MSCPUPLS.pls 120.0 2005/05/25 19:56:42 appldev noship $';

END msc_update_plan_options_pk;
 

/
