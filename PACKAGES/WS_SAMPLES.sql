--------------------------------------------------------
--  DDL for Package WS_SAMPLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WS_SAMPLES" AUTHID CURRENT_USER AS
-- $Header: wssmpls.pls 115.0 2003/10/16 21:53:30 jjxie noship $


function generate
	(
	  p_event_name		in	varchar2,
	  p_event_key		in 	varchar2,
	  p_parameter_list      in 	wf_parameter_list_t
        ) return CLOB;


end ws_samples;

 

/
