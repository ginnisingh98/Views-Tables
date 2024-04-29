--------------------------------------------------------
--  DDL for Package CSTPDPPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPDPPC" AUTHID CURRENT_USER AS
/* $Header: CSTDPPCS.pls 115.6 2002/11/08 03:16:03 awwang ship $ */
/*-----------------------------------------------------------
type cst_ae_lib_param_type is record (
i_name          varchar2(50),
i_num_value     number,
i_vchar_value   varchar2(500),
i_char_value    char(500),
i_date_value    date,
i_datatype	number,
i_inout		number
);

type cst_ae_lib_par_tbl_type is table of cst_ae_lib_param_type;
-----------------------------------------------------*/

PROCEDURE set_phase_status (
        i_cost_group_id         IN              NUMBER,
        i_period_id             IN              NUMBER,
        i_status                IN              NUMBER,
        i_user_id               IN              NUMBER,
        i_login_id              IN              NUMBER,
        i_prog_appl_id          IN              NUMBER,
        i_prog_id               IN              NUMBER,
	i_request_id		IN		NUMBER
);

procedure dyn_proc_call (
i_proc_name     in      varchar2,
i_acct_lib_id	in	number,
i_legal_entity  in      number,
i_cost_type     in      number,
i_cost_group    in      number,
i_period_id     in      number,
i_mode		in	number,
o_err_num       out NOCOPY     number,
o_err_code      out NOCOPY     varchar2,
o_err_msg       out NOCOPY     varchar2
);
/*------------------------------------------------------
procedure run_dyn_proc ( (
i_num_params    in      number,
i_proc_name     in      varchar2,
io_parameters    in out  cst_ae_lib_par_tbl_type,
o_err	out	number
);
--------------------------------------------------------*/


PROCEDURE dist_processor_main (
	errbuf     OUT NOCOPY	varchar2,
	retcode    OUT NOCOPY	number,
	i_legal_entity	IN	number,
	i_cost_type_id	IN	number,
	i_cost_group_id	IN	number,
	i_period_id	IN	number,
	i_mode		IN	number DEFAULT 0
);


END CSTPDPPC;

 

/
