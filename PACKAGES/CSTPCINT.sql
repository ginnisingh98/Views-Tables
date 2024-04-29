--------------------------------------------------------
--  DDL for Package CSTPCINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPCINT" AUTHID CURRENT_USER AS
/* $Header: CSTPCINS.pls 115.5 2002/11/09 00:40:17 awwang ship $ */

FUNCTION copy_to_dest(
        i_group_id		IN NUMBER,
	i_from_org_id		IN NUMBER,
	i_to_org_id		IN NUMBER,
	i_from_cost_type	IN NUMBER,
	i_to_cost_type		IN NUMBER,
        i_summary_option	IN NUMBER,
        i_mtl_subelement        IN NUMBER,
        i_moh_subelement        IN NUMBER,
        i_res_subelement        IN NUMBER,
        i_osp_subelement        IN NUMBER,
        i_ovh_subelement        IN NUMBER,
        i_conv_type             IN VARCHAR2,
        i_exact_copy_flag       IN VARCHAR2,
        i_user_id		IN NUMBER,
	i_request_id		IN NUMBER,
	i_prog_applid		IN NUMBER,
	i_prog_id		IN NUMBER,
	i_rowcount		OUT NOCOPY NUMBER,
        error_msg		OUT NOCOPY VARCHAR2
) RETURN INTEGER;

END CSTPCINT;

 

/
