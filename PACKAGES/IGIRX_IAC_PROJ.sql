--------------------------------------------------------
--  DDL for Package IGIRX_IAC_PROJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRX_IAC_PROJ" AUTHID CURRENT_USER AS
--  $Header: igiiaxps.pls 120.8 2007/08/01 10:45:56 npandya ship $


   PROCEDURE proj(p_projection_id  NUMBER,
                  p_request_id     NUMBER,
                  retcode  out nocopy number,
		  errbuf   out nocopy varchar2);

END igirx_iac_proj;

/
