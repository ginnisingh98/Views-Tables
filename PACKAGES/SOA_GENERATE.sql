--------------------------------------------------------
--  DDL for Package SOA_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SOA_GENERATE" AUTHID CURRENT_USER as
/* $Header: SOAGENRS.pls 120.0 2008/01/14 19:11:29 abhverma noship $ */

G_NO_ERROR      pls_integer := 0;          -- success without any error.
G_WARNING       pls_integer := 1;          -- generic warning.


procedure create_class_derived_entry
	(
	p_base_class_id in pls_integer,
	p_entry_type in varchar2,
        x_derived_class_id OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure create_function_derived_entry
	(
	p_base_class_id in pls_integer,
	p_base_function_id in pls_integer,
	p_entry_type in varchar2,
	l_derived_class_id out NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure create_object_derived_entry
	(
	p_base_object_id in pls_integer,
	p_entry_type in varchar2,
	x_derived_class_id OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);
procedure create_obj_func_derived_entry
	(
	p_base_object_id in pls_integer,
	p_base_function_id in pls_integer,
	p_entry_type in varchar2,
	l_derived_class_id OUT NOCOPY pls_integer,
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

procedure create_obj_function_base_entry
	(
	p_base_object_id in pls_integer,
	p_function_name in varchar2,
	l_function_id OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

program_exit    exception;
ignore_rec      exception;

end SOA_GENERATE;

/
