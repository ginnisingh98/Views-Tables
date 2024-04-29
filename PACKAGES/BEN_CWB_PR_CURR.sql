--------------------------------------------------------
--  DDL for Package BEN_CWB_PR_CURR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PR_CURR" AUTHID CURRENT_USER AS
/* $Header: bencwbcp.pkh 115.1 2002/12/23 12:43:56 lakrish noship $ */
--
--

 Procedure getcurrencycode (
                            user_id in number
                           ,business_grp_id in number
                           ,profile_name    in varchar2
                           ,retcode         out nocopy varchar2
                           ,defined         out nocopy varchar2
                           );

--
--

 Procedure setprofile     (
                            user_id in number
                           ,currency in varchar2
                           ,profile_name in varchar2
                         );
--
--


END  ben_cwb_pr_curr;

 

/
