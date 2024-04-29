--------------------------------------------------------
--  DDL for Package FLM_CREATE_PRODUCT_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_CREATE_PRODUCT_SYNCH" AUTHID CURRENT_USER AS
/* $Header: FLMCPSYS.pls 115.5 2002/11/29 17:37:20 sjagan ship $ */

PROCEDURE create_schedules(
	errbuf			out	NOCOPY	varchar2,
	retcode			out 	NOCOPY	number,
	arg_org_id		in	number,
	arg_min_line_code	in	varchar2,
	arg_max_line_code	in	varchar2,
	arg_start_date		in	varchar2,
	arg_end_date		in	varchar2,
	arg_commit		in	varchar2 DEFAULT NULL);

FUNCTION feeder_line_comp_date (p_org_id NUMBER,
                                p_assembly_line_id NUMBER,
                                p_assembly_item_id NUMBER,
                                p_assembly_start_date DATE,
                                p_assembly_comp_date DATE,
                                p_line_op_seq_id NUMBER,
                                p_qty NUMBER,
                                p_fast_feeder_line NUMBER) return DATE;

END FLM_CREATE_PRODUCT_SYNCH;

 

/
