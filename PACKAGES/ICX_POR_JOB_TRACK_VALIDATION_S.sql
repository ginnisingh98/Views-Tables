--------------------------------------------------------
--  DDL for Package ICX_POR_JOB_TRACK_VALIDATION_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_JOB_TRACK_VALIDATION_S" AUTHID CURRENT_USER as
/* $Header: ICXJVALS.pls 115.0 2000/05/02 17:44:05 pkm ship       $ */

procedure update_job_status(p_jobno in number,
                            p_new_status in varchar2,
                            p_loaded_items in number,
                            p_failed_items in number);

procedure complete_job(p_jobno in number);

procedure fail_job(p_jobno in number,
                   p_error_message in varchar2);

function validate_item_price(p_jobno in out number,
                             p_action in varchar2,
                             p_row_type in varchar2,
                             p_supplier_id in number,
                             p_supplier in varchar2,
                             p_supplier_part_num in varchar2,
                             p_description in varchar2,
                             p_unspsc in varchar2,
                             p_lead_time in number,
                             p_availability in varchar2,
                             p_item_type in varchar2,
                             p_buyer in varchar2,
                             p_uom in varchar2,
                             p_price in number,
                             p_currency_code in varchar2,
                             p_line_number in number,
                             p_job_supplier_name in varchar2,
                             p_business_group_id in number,
                             p_supplier_site in varchar2) return varchar2;

procedure InsertError(p_jobno in out number,
                      p_descriptor_key in varchar2,
                      p_message_name in varchar2,
                      p_line_number in number);

procedure get_next_job(p_jobno out number,
                       p_exchange_file_name out varchar2,
                       p_supplier_id out number,
                       p_supplier_name out varchar2,
                       p_host_ip_address in varchar2,
                       p_exchange_operator out varchar2);

function create_job(p_supplier_id in number,
                    p_supplier_file in varchar2,
                    p_exchange_file in varchar2,
                    p_host_ip_address in varchar2,
                    p_exchange_operator in varchar2) return number;

end icx_por_job_track_validation_s;

 

/
