--------------------------------------------------------
--  DDL for Package SOA_REMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SOA_REMOVE" AUTHID CURRENT_USER as
 /* $Header: SOAREMS.pls 120.0.12010000.1 2009/04/17 05:49:28 snalagan noship $ */

 G_NO_ERROR      pls_integer := 0;          -- success without any error.
 G_WARNING       pls_integer := 1;          -- generic warning.



procedure remove_class_derived_entry(
                                    p_base_class_id in pls_integer,
                                    p_err_code OUT NOCOPY pls_integer,
                                    p_err_message OUT NOCOPY varchar2
	                            );

 procedure remove_derived_function_entry(
                                        p_derived_class_id in pls_integer,
                                        p_err_code OUT NOCOPY pls_integer,
                                        p_err_message OUT NOCOPY varchar2
                                        ) ;


procedure remove_function_lang_entries(
                                      p_derived_function_id in pls_integer,
                                      p_derived_class_id in pls_integer,
                                      p_err_code OUT NOCOPY pls_integer,
                                      p_err_message OUT NOCOPY varchar2
                                      );

procedure remove_class_lang_entry(
                                  p_derived_class_id in pls_integer,
                                  p_err_code OUT NOCOPY pls_integer,
                                  p_err_message OUT NOCOPY varchar2
                                  );

program_exit exception;
ignore_rec exception;
end SOA_REMOVE;

/
