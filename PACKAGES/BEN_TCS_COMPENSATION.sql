--------------------------------------------------------
--  DDL for Package BEN_TCS_COMPENSATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TCS_COMPENSATION" AUTHID CURRENT_USER as
/* $Header: betcscmp.pkh 120.2 2006/04/12 04:49 srangasa noship $ */

TYPE period_rec IS
   RECORD  ( start_date date,
             end_date date,
             value varchar2(2000),
             currency_cd varchar2(30),
             uom  varchar2(30),
             creator_type varchar2(2000),
             output_key number,
             actual_uom varchar2(30)
           );

TYPE period_table IS TABLE OF period_rec
   INDEX BY BINARY_INTEGER;

procedure get_value_for_item(p_source_cd     in  varchar2,
                             p_source_key    in  varchar2,
                             p_perd_st_dt    in date,
                             p_perd_en_dt    in date,
                             p_person_id     in number,
                             p_assignment_id in number,
                             p_effective_date in date,
                             p_comp_typ_cd    in varchar2,
                             p_currency_cd    in varchar2,
                             p_uom           in varchar2,
                             p_result        out nocopy period_table,
                             p_status        out nocopy varchar2);
end BEN_TCS_COMPENSATION;

 

/
