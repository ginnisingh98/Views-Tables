--------------------------------------------------------
--  DDL for Package FLM_COPY_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_COPY_ROUTING" AUTHID CURRENT_USER AS
/* $Header: FLMCPYRS.pls 120.0.12010000.1 2008/07/29 04:13:54 appldev ship $  */

Procedure copy_routings(
	 errbuf		OUT	NOCOPY	varchar2
	,retcode	OUT 	NOCOPY	number
	,p_mode			number
        ,p_organization_id      number
        ,p_line_id_to           number
        ,p_alternate_code_to    varchar2
	,p_copy_bom		varchar2
	,p_line_id_from		number
	,p_alternate_code_from	varchar2
	,p_product_family_id	number
        ,p_assembly_name_from   varchar2
        ,p_assembly_name_to     varchar2
        ,p_tpct_from            number
        ,p_tpct_to              number
        ,p_lineop_code          varchar2
        ,p_process_code         varchar2
	);

END flm_copy_routing;

/
