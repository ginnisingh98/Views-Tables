--------------------------------------------------------
--  DDL for Package WF_WS_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_WS_GEN" AUTHID CURRENT_USER as
/* $Header: WFWSGENS.pls 120.3 2006/03/09 10:40:32 kjayapra noship $ */

G_NO_ERROR      pls_integer := 0;          -- success without any error.
G_WARNING       pls_integer := 1;          -- generic warning.

procedure wf_ws_create
	(
	p_module_name in varchar,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;


procedure create_derived_entry
	(
	p_interface_irep_name IN varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure create_derived_entry
	(
	p_base_class_id in pls_integer,
        x_derived_class_id OUT NOCOPY pls_integer,
	x_irep_name OUT NOCOPY varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure create_derived_entry
	(
	p_base_class_id in pls_integer,
	p_base_function_id in pls_integer,
	l_derived_class_id out NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure get_root_element
        (
        p_map_code in varchar2,
        p_root_element OUT NOCOPY varchar2,
        p_err_code OUT NOCOPY pls_integer,
        p_err_message OUT NOCOPY varchar2
        );

program_exit    exception;
ignore_rec      exception;

end WF_WS_GEN;

 

/
