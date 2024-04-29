--------------------------------------------------------
--  DDL for Package GHR_MASS_AWARDS_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MASS_AWARDS_ELIG" AUTHID CURRENT_USER as
/* $Header: ghmawelg.pkh 120.0 2005/05/29 03:16:58 appldev noship $ */

Procedure get_eligible_employees
(p_mass_award_id  in    number  ,
 p_action_type    in    varchar2, -- PREVIEW, FINAL
 p_errbuf         out nocopy  varchar2,
 p_retcode        out   nocopy varchar2,
 p_status         in out nocopy  varchar2,
  p_maxcheck       out nocopy number
 );


Procedure derive_rel_operator
(p_in_rel_operator     in  varchar2,
 p_out_rel_operator    out nocopy varchar2,
 p_prefix              out nocopy varchar2,
 p_suffix              out nocopy varchar2
 );

end ghr_mass_awards_elig ;

 

/
