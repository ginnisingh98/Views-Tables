--------------------------------------------------------
--  DDL for Package FF_FFXWSDFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FFXWSDFF_PKG" AUTHID CURRENT_USER as
/* $Header: ffxwsdff.pkh 115.0 99/07/16 02:04:20 porting ship $ */

--------------------------------------------------------
-- I : Row Handlers for FF_FUNCTIONS                  --
--------------------------------------------------------

procedure insert_function(x_rowid       in out varchar2,
                          x_function_id in out number,
                          x_class              varchar2,
                          x_name               varchar2,
                          x_alias_name         varchar2,
                          x_business_group_id  number,
                          x_created_by         number,
                          x_creation_date      date,
                          x_data_type          varchar2,
                          x_definition         varchar2,
                          x_last_updated_by    number,
                          x_last_update_date   date,
                          x_last_update_login  number,
                          x_legislation_code   varchar2,
                          x_description        varchar2
                         );

procedure lock_function(x_rowid              varchar2,
                        x_function_id        number,
                        x_class              varchar2,
                        x_name               varchar2,
                        x_alias_name         varchar2,
                        x_business_group_id  number,
                        x_created_by         number,
                        x_creation_date      date,
                        x_data_type          varchar2,
                        x_definition         varchar2,
                        x_last_updated_by    number,
                        x_last_update_date   date,
                        x_last_update_login  number,
                        x_legislation_code   varchar2,
                        x_description        varchar2
                       );

procedure update_function(x_rowid              varchar2,
                          x_function_id        number,
                          x_class              varchar2,
                          x_name               varchar2,
                          x_alias_name         varchar2,
                          x_business_group_id  number,
                          x_created_by         number,
                          x_creation_date      date,
                          x_data_type          varchar2,
                          x_definition         varchar2,
                          x_last_updated_by    number,
                          x_last_update_date   date,
                          x_last_update_login  number,
                          x_legislation_code   varchar2,
                          x_description        varchar2
                         );

procedure delete_function(x_rowid       varchar2,
                          x_function_id number);


-------------------------------------------------------------
-- II : Row Handlers for FF_FUNCTION_CONTEXT_USAGES        --
-------------------------------------------------------------

procedure insert_context_usage(x_rowid       in out varchar2,
                               x_function_id        number,
                               x_sequence_number    number,
                               x_context_id         number
                              );

procedure lock_context_usage(x_rowid              varchar2,
                             x_function_id        number,
                             x_sequence_number    number,
                             x_context_id         number
                            );

procedure update_context_usage(x_rowid              varchar2,
                               x_function_id        number,
                               x_sequence_number    number,
                               x_context_id         number
                              );

procedure delete_context_usage(x_rowid varchar2);


-----------------------------------------------------------
-- III : Row Handlers for FF_FUNCTION_PARAMETERS         --
-----------------------------------------------------------

procedure insert_parameter(x_rowid         in out varchar2,
                           x_function_id          number,
                           x_sequence_number      number,
                           x_class                varchar2,
                           x_continuing_parameter varchar2,
                           x_data_type            varchar2,
                           x_name                 varchar2,
                           x_optional             varchar2
                          );

procedure lock_parameter(x_rowid                varchar2,
                         x_function_id          number,
                         x_sequence_number      number,
                         x_class                varchar2,
                         x_continuing_parameter varchar2,
                         x_data_type            varchar2,
                         x_name                 varchar2,
                         x_optional             varchar2
                        );

procedure update_parameter(x_rowid                varchar2,
                           x_function_id          number,
                           x_sequence_number      number,
                           x_class                varchar2,
                           x_continuing_parameter varchar2,
                           x_data_type            varchar2,
                           x_name                 varchar2,
                           x_optional             varchar2
                          );

procedure delete_parameter(x_rowid varchar2);


---------------------------------------------------------------------
-- IV : Other functions and procedures needed for FFXWSDFF         --
---------------------------------------------------------------------

---------------------------------------------------------------------
-- next_parameter_sequence
--
-- Returns the next available parameter sequence number
-- to maintain a sequence of parameters within a particular function.
---------------------------------------------------------------------

function next_parameter_sequence(p_function_id number) return number;


---------------------------------------------------------------------
-- next_context_usage_sequence
--
-- Returns the next available context usage sequence number
-- to maintain a sequence of contexts within a particular function.
---------------------------------------------------------------------

function next_context_usage_sequence(p_function_id number) return number;


---------------------------------------------------------------------
-- check_alias_name
--
-- Ensures that the alias name is different to the function name
-- within the FUNCTION block.
---------------------------------------------------------------------

procedure check_alias_name(p_function_name varchar2,
                           p_alias_name    varchar2);


---------------------------------------------------------------------
-- set_parameter_properties
--
-- Sets the correct OPTIONAL and CONTINUING_PARAMETER properties for
-- a parameter class of 'out' or 'in out'.
---------------------------------------------------------------------

procedure set_parameter_properties(p_class                       varchar2,
                                   p_optional             in out varchar2,
                                   p_continuing_parameter in out varchar2);

end ff_ffxwsdff_pkg;


 

/
