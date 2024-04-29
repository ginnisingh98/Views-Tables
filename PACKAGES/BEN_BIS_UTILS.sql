--------------------------------------------------------
--  DDL for Package BEN_BIS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BIS_UTILS" AUTHID CURRENT_USER as
/* $Header: benbisut.pkh 120.0 2005/05/28 03:43:43 appldev noship $ */
/* ===========================================================================
 * Name:
 *   Batch_utils
 * Purpose:
 *   This package is provide all batch utility and data structure to simply
 *   batch process.
 * History:
 *   Date        Who       Version  What?
 *   ----------- --------- -------  -----------------------------------------
 *   25-Sep-2003 vsethi     115.0    Created.
 *   13-May-2004 hmani      115.1    Added three functions
 *                                   get_group_pl_name, get_group_opt_name
 *                                   get_group_oipl_name
 * ===========================================================================
*/
--
-- Global variables declaration.
--

--
-- ============================================================================
--                          <<Function: get_pl_name>>
-- ============================================================================
--
Function get_pl_name(p_pl_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;

--
-- ============================================================================
--                          <<Function: get_group_pl_name>>
-- ============================================================================
--
Function get_group_pl_name(p_pl_id              in number
                    ,p_effective_date     in date
                    ) return varchar2 ;

--
-- ============================================================================
--                          <<Function: get_pgm_name>>
-- ============================================================================
--
Function get_pgm_name(p_pgm_id            in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;

--
-- ============================================================================
--                          <<Function: get_opt_name>>
-- ============================================================================
--
Function get_opt_name(p_opt_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_group_opt_name>>
-- ============================================================================
--
Function get_group_opt_name(p_opt_id              in number
                           ,p_effective_date     in date
                    ) return varchar2 ;

--
-- ============================================================================
--                          <<Function: get_plip_name>>
-- ============================================================================
--
Function get_plip_name(p_plip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_ptip_name>>
-- ============================================================================
--
Function get_ptip_name(p_ptip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_oipl_name>>
-- ============================================================================
--
Function get_oipl_name(p_oipl_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_group_oipl_name>>
-- ============================================================================
--
Function get_group_oipl_name(p_oipl_id              in number
                            ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_oiplip_name>>
-- ============================================================================
--
Function get_oiplip_name(p_oiplip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_cmbn_plip_name>>
-- ============================================================================
--
Function get_cmbn_plip_name(p_cmbn_plip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_cmbn_ptip_name>>
-- ============================================================================
--
Function get_cmbn_ptip_name(p_cmbn_ptip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
-- ============================================================================
--                          <<Function: get_cmbn_ptip_opt_name>>
-- ============================================================================
--
Function get_cmbn_ptip_opt_name(p_cmbn_ptip_opt_id   in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2 ;
--
end ben_bis_utils;

 

/
