--------------------------------------------------------
--  DDL for Package HRSUMREP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRSUMREP" AUTHID CURRENT_USER as
/* $Header: hrsumrep.pkh 115.9 2004/06/21 07:39:06 jheer noship $ */
--
procedure delete_process_data(p_process_run_id in number);
--
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_parameters hr_summary_util.prmTabType
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2
                     ,p_retcode   out NOCOPY number);
--
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2);
--
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_parameters hr_summary_util.prmTabType
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2);
--
procedure write_error (p_error in varchar2);
--
procedure write_stmt_log (p_stmt in varchar2);
--
TYPE ituRecType IS RECORD
   (item_type_usage_id number
   ,item_type_id number
   ,datatype varchar2(1)
   ,count_clause1  varchar2(240)
   ,count_clause2 varchar2(240)
   ,where_clause varchar2(4000)
   ,it_name varchar2(240)
   ,itu_name varchar2(240)
   ,first_parameter number
   ,number_of_parameters number);
TYPE ituTabType is TABLE of ituRecType INDEX BY BINARY_INTEGER;
--
TYPE ktyRecType IS RECORD
   (key_type varchar2(240)
   ,key_type_id number
   ,key_other boolean
   ,key_function varchar2(2000));
TYPE ktyTabType IS TABLE of ktyRecType INDEX BY BINARY_INTEGER;
--
nullituTab ituTabType;
nullktyTab ktyTabType;
--
ituTab ituTabType;
ktyTab ktyTabType;
--

procedure process_run_form(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug  varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2);


end hrsumrep;

 

/
