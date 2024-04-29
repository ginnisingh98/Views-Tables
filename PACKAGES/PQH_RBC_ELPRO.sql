--------------------------------------------------------
--  DDL for Package PQH_RBC_ELPRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_ELPRO" AUTHID CURRENT_USER as
/* $Header: pqrbcelp.pkh 120.0 2005/10/06 14:52 srajakum noship $ */


procedure create_elpro(p_name              in varchar2,
                       p_description       in varchar2,
                       p_business_group_id in number,
                       p_effective_date    in date,
                       p_elig_prfl_id      out nocopy number);

procedure create_criteria (p_criteria_code              in varchar2,
                           p_char_value1       in varchar2 default null,
                           p_char_value2       in varchar2 default null,
                           p_char_value3       in varchar2 default null,
                           p_char_value4       in varchar2 default null,
                           p_number_value1     in number default null,
                           p_number_value2     in number default null,
                           p_number_value3     in number default null,
                           p_number_value4     in number default null,
                           p_date_value1       in date default null,
                           p_date_value2       in date default null,
                           p_date_value3       in date default null,
                           p_date_value4       in date default null,
                           p_business_group_id in number default null,
                           p_effective_date    in date,
                           p_elig_prfl_id      in number
                           );

end pqh_rbc_elpro;

 

/
