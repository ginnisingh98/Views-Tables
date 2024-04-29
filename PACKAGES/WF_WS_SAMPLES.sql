--------------------------------------------------------
--  DDL for Package WF_WS_SAMPLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_WS_SAMPLES" AUTHID CURRENT_USER AS
-- $Header: wfwssmpls.pls 120.0 2005/10/13 12:40:51 jdang noship $


function generate
	(
	  p_event_name		in	varchar2,
	  p_event_key		in 	varchar2,
	  p_parameter_list      in 	wf_parameter_list_t
        ) return CLOB;


end wf_ws_samples;

 

/
