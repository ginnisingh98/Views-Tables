--------------------------------------------------------
--  DDL for Package MSD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_VALIDATE" AUTHID CURRENT_USER as
/* $Header: msdvales.pls 115.12 2002/11/07 00:40:30 pinamati ship $ */

/* Added for performance reasons - removing default, adding no copy */
procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2);

procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2,
                         p_detail in varchar2);


/* Added for performance reasons - removing default, adding no copy */
procedure run_validation_all(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_application_code varchar2,
                         p_function in varchar2,
                         p_plan_id in number,
                         p_instance_id in number,
                         p_report_type in varchar2);

procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2,
                         p_detail in varchar2,
                         p_application_code varchar2,
                         p_token1 in number,
                         p_token2 in number,
                         p_token3 in number);

procedure run_validation_all(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_application_code varchar2,
                         p_function in varchar2,
                         p_plan_id in number,
                         p_instance_id in number,
                         p_report_type in varchar2,
                         p_token1 in number,
                         p_token2 in number,
                         p_token3 in number);

Null_dblink varchar2(3) := ' ';
function get_td_tag(string varchar2) return varchar2;

function get_translated_string(string varchar2) return varchar2;

function get_translated_string(string varchar2,
                               appcode varchar2) return varchar2;

function get_translated_string(string varchar2,
                               appcode varchar2,
                               p_token1 varchar2,
                               p_token1_value varchar2) return varchar2;

function get_translated_string(string varchar2,
                               appcode varchar2,
                               p_token1 varchar2,
                               p_token1_value varchar2,
                               p_token2 varchar2,
                               p_token2_value varchar2) return varchar2;

function get_translated_string(string varchar2,
                               appcode varchar2,
                               p_token1 varchar2,
                               p_token1_value varchar2,
                               p_token2 varchar2,
                               p_token2_value varchar2,
                               p_token3 varchar2,
                               p_token3_value varchar2) return varchar2;

function is_valid_sr_pk(p_sr_pk varchar2, p_level_id number, p_instance varchar2) return varchar2;


end;

 

/
