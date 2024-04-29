--------------------------------------------------------
--  DDL for Package TRR_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."TRR_ENGINE_PKG" AUTHID CURRENT_USER as
/*$Header: pytrreng.pkh 115.3 2002/06/14 10:15:47 pkm ship    $*/
/*===========================================================================*
 |               Copyright (c) 1997 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/
-- DESCRIPTION
--    This script creates the federal tax remittance report SRS definitions
--
-------------------------------------------------------------------------------
--                     Change History
--
-- Vers  Date        Author        Reason
-- 10.0  11/05/98    tbattoo       Created.
-- 110.2 01/05/99    ahanda        Changed the datatype for p_state parameter
--                                 from NUMBER to VARCHAR2.
--
-------------------------------------------------------------------------------
--
  type gre_info is record
  (
   gre_size number,
   gre_id   number,
   gre_name varchar2(60)
  );

  type gre_info_list is table of gre_info index by binary_integer;

  procedure federal_trr(errbuf   OUT     VARCHAR2,
                      retcode    OUT     NUMBER,
                      p_business_group   number,
                      p_start_date       varchar2,
                      p_end_date         varchar2,
                      p_gre              number,
                      p_federal          varchar2,
                      p_state            varchar2,
                      p_dimension        varchar2);
  procedure state_trr;
--
  procedure local_trr(errbuf 	out	varchar2
                     ,retcode	out	number
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
end TRR_ENGINE_PKG;

 

/
