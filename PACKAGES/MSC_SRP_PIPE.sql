--------------------------------------------------------
--  DDL for Package MSC_SRP_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SRP_PIPE" AUTHID CURRENT_USER AS
-- $Header: MSCRPLNS.pls 120.2 2007/09/04 21:35:56 hulu noship $

Procedure get_replan_progress(p_request_id in number,
			      p_outPipe in varchar2,
                              p_inPipe in varchar2,
			      p_error_code out nocopy number,
			      p_stage_code out nocopy number,
			      p_pcnt   out nocopy number);

Function load_pipe( p_pipeName in varchar2,
                    p_msg      in varchar2) return number;

Function read_pipe(p_pipeName in varchar2) return varchar2;

Function check_cp_status(p_request_id in number,
                         p_status out NOCOPY number) return number;

END;



/
