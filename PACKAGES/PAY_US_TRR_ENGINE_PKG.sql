--------------------------------------------------------
--  DDL for Package PAY_US_TRR_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TRR_ENGINE_PKG" AUTHID CURRENT_USER as
/*$Header: pyusteng.pkh 115.4 2003/08/26 16:48:45 meshah noship $*/
/*===========================================================================*
 |               Copyright (c) 1997 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/
/*
REM DESCRIPTION
REM    This script creates the federal tax remittance report SRS definitions
REM
REM
REM                     Change History
REM
REM Vers  Date        Author        Reason
REM 115.0 14-JUN-2002 meshah        created. copy for pytrreng.pkh ver 115.3
REM 115.1 08-JAN-2002 meshah        made nocopy changes.
REM 115.2 10-JAN-2002 meshah        incorrect comments
REM 115.4 26-AUG-2003 meshah        increased the GRE Name length to 240.
*/
--
  type gre_info is record
  (
   gre_size number,
   gre_id   number,
   gre_name varchar2(240)
  );

  type gre_info_list is table of gre_info index by binary_integer;

  procedure federal_trr(errbuf   OUT nocopy    VARCHAR2,
                      retcode    OUT nocopy    NUMBER,
                      p_business_group   number,
                      p_start_date       varchar2,
                      p_end_date         varchar2,
                      p_gre              number,
                      p_federal          varchar2,
                      p_state            varchar2,
                      p_dimension        varchar2);
  procedure state_trr;
--
  procedure local_trr(errbuf 	out nocopy varchar2
                     ,retcode	out nocopy number
                     ,p_business_group	number
                     ,p_start_date    	varchar2
                     ,p_end_date	varchar2
		     ,p_gre		number
                     ,p_state		varchar2
                     ,p_locality_type	varchar2
                     ,p_is_city		varchar2
                     ,p_city		varchar2
                     ,p_is_county	varchar2
                     ,p_county         	varchar2
                     ,p_is_school	varchar2
                     ,p_school          varchar2
                     ,p_sort_option_1   varchar2
                     ,p_sort_option_2   varchar2
                     ,p_sort_option_3   varchar2
	             ,p_dimension       varchar2);
end PAY_US_TRR_ENGINE_PKG;

 

/
