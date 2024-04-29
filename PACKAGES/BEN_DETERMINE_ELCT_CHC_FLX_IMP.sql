--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ELCT_CHC_FLX_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ELCT_CHC_FLX_IMP" AUTHID CURRENT_USER as
/* $Header: benflxii.pkh 120.0 2005/05/28 09:01:35 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA	  	           |
|			        All rights reserved.			           |
+==============================================================================+
Name:
    Determine Electable Choices for Flex Credits and Imputed Income.

Purpose:
    Determine Electable Choices for Flex Credits and Imputed Income.  Flex Credits
    are at the pgm, plip, and ptip levels.  Imputed income is at the plan level.
    Called from benmngle.pkb once per person.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        7 May 97        Ty Hayden  110.0      Created.
       29 Oct 98        lmcdonal   115.2      Added per-in-ler-id,
                                              enrt-perd-strt-dt, lf_evt-ocrd-dt,
                                              and BG.
        09 Mar 99        G Perry    115.3      IS to AS.
        15 Mar 02        ikasire    115.4     Bug 2200139 added a new parameter
                                              p_called_from for Override process.
        15-Nov-04        kmahendr   115.5     Added parameter p_mode

*/
--------------------------------------------------------------------------------
--

   PROCEDURE main
  (p_person_id         IN number,
   p_effective_date    IN date,
   p_enrt_perd_strt_dt in date,
   p_per_in_ler_id     in number,
   p_lf_evt_ocrd_dt    in date,
   p_business_group_id in number,
   p_called_from       in varchar2 default 'B' ,--B for Benmngle, O for Override
   p_mode              in varchar2 default null
) ;

end ben_determine_elct_chc_flx_imp;

 

/
