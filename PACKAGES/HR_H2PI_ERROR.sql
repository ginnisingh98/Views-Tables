--------------------------------------------------------
--  DDL for Package HR_H2PI_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_ERROR" AUTHID CURRENT_USER AS
/* $Header: hrh2pier.pkh 115.2 2002/03/07 15:33:06 pkm ship     $ */

  PROCEDURE data_error(p_from_id       number,
                       p_table_name    varchar2,
                       p_message_level varchar2,
                       p_message_name  varchar2 default null,
                       p_message_text  varchar2 default null,
                       p_api_module_id number default null);

  FUNCTION check_for_errors return boolean;

  PROCEDURE generate_error_report;

END hr_h2pi_error;

 

/
