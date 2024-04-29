--------------------------------------------------------
--  DDL for Package BEN_EXT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_PURGE" AUTHID CURRENT_USER as
/* $Header: benxpurg.pkh 120.0 2005/05/28 09:46:30 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Write Process.
Purpose:
    This process  clean the result and detail table
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        30 Aug 03        tjesumic  115.0      Created.
        18 sep 98        tjesumic  115.1      log purge added
*/
-----------------------------------------------------------------------------------
--
Procedure MAIN
          (errbuf              out nocopy varchar2,   --needed by concurrent manager.
           retcode             out nocopy number,     --needed by concurrent manager.
           p_validate          in varchar2 ,
           p_ext_dfn_id        in number  default null ,
           p_ext_rslt_date     in  varchar2,
           p_business_group_id in number  ,
           p_benefit_action_id in number default null,
           p_ext_rslt_id       in number default null );



Procedure chg_log_purge
          (errbuf              out nocopy varchar2,   --needed by concurrent manager.
           retcode             out nocopy number,     --needed by concurrent manager.
           p_validate          in varchar2 ,
           p_person_id        in number     default null,
           p_effective_date   in  varchar2  default null,
           p_actual_date      in  varchar2  default null,
           p_business_group_id in number  ,
           p_benefit_action_id in number default null
           );

--


END; -- Package spec

 

/
