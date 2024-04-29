--------------------------------------------------------
--  DDL for Package BEN_EFC_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: beefcfnc.pkh 115.8 2002/12/31 23:58:32 mmudigon noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      18-Dec-00	mhoyes     Created.
  115.1      31-Jan-01	mhoyes     Added more functions.
  115.2      06-Apr-01	mhoyes     Enhanced for Patchset D.
  115.3      12-Jul-01	mhoyes     Enhanced for Patchset E.
  115.5      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.6      26-Sep-01	mhoyes     Enhanced for Patchset G.
  115.7      26-Sep-01	mhoyes     Enhanced for Patchset G.
  115.8      31-Dec-02	mmudigon   NOCOPY
  -----------------------------------------------------------------------------
*/
--
type g_attach_df_counts is record
  (epa_count         pls_integer
  ,abr_count         pls_integer
  ,apr_count         pls_integer
  ,ccm_count         pls_integer
  ,noattdf_count     pls_integer
  );
--
g_epe_count        pls_integer;
g_enb_count        pls_integer;
g_epeenbnull_count pls_integer;
g_noepedets_count  pls_integer;
g_noenbdets_count  pls_integer;
--
procedure setup_workers
  (p_component_name    in     varchar2
  ,p_sub_step          in     varchar2
  ,p_table_name        in     varchar2
  ,p_worker_id         in     number
  ,p_total_workers     in     number
  --
  ,p_business_group_id in     number default null
  --
  ,p_chunk                out nocopy varchar2
  ,p_status               out nocopy varchar2
  ,p_action_id            out nocopy number
  ,p_pk1                  out nocopy number
  ,p_efc_worker_id        out nocopy number
  );
--
procedure maintain_chunks
  (p_row_count     in out nocopy number
  ,p_pk1           in     number
  ,p_chunk_size    in     number
  ,p_efc_worker_id in     number
  );
--
procedure conv_check
  (p_table_name      in     varchar2
  ,p_efctable_name   in     varchar2
  ,p_tabwhere_clause in     varchar2 default null
  --
  ,p_bgp_id          in     number   default null
  ,p_action_id       in     number   default null
  --
  ,p_table_sql       in     varchar2 default null
  ,p_efctable_sql    in     varchar2 default null
  --
  ,p_tabrow_count      out nocopy number
  ,p_conv_count        out nocopy number
  ,p_unconv_count      out nocopy number
  );
--
procedure EPEorENB_InitCounts;
--
procedure EPEorENB_GetEPEDets
  (p_elig_per_elctbl_chc_id in     number default null
  ,p_enrt_bnft_id           in     number default null
  --
  ,p_currepe_row               out nocopy ben_epe_cache.g_pilepe_inst_row
  );
--
procedure CompObject_ChkAttachDF
  (p_coent_scode  in     varchar2
  ,p_compobj_id   in     number default null
  --
  ,p_counts          out nocopy g_attach_df_counts
  );
--
procedure BGP_WriteEFCAction
  (p_bgp_id        in     number
  --
  ,p_efc_action_id    out nocopy number
  );
--
procedure BGP_SetupEFCAction
  (p_bgp_id        in     number
  --
  ,p_efc_action_id    out nocopy number
  );
--
/*
CURSOR gc_currefcact
  (c_bgp_id in number
  )
IS
  select act.efc_action_id,
         act.business_group_id
  from hr_efc_actions act
  where act.business_group_id = c_bgp_id
  and   act.efc_action_status = 'P'
  and   act.efc_action_type = 'C'
  and   act.efc_action_id =
    (select max(act1.efc_action_id)
     from   hr_efc_actions act1
     where  act1.business_group_id = c_bgp_id
     and    act1.efc_action_status = 'P'
     and    act1.efc_action_type   = 'C'
    );
--
procedure BGP_GetEFCActDetails
  (p_bgp_id      in     number
  --
  ,p_efcact_dets    out nocopy gc_currefcact%rowtype
  );
*/
--
function CurrCode_IsNCU
  (p_curr_code   in     varchar2
  )
return boolean;
--
function UOM_IsCurrency
  (p_uom   in     varchar2
  )
return boolean;
--
procedure CompObject_GetParUom
  (p_pgm_id      in     number
  ,p_ptip_id     in     number
  ,p_pl_id       in     number
  ,p_plip_id     in     number
  ,p_oipl_id     in     number
  ,p_oiplip_id   in     number
  ,p_eff_date    in     date
  --
  ,p_paruom         out nocopy varchar2
  ,p_faterr_code    out nocopy varchar2
  ,p_faterr_type    out nocopy varchar2
  );
--
END ben_efc_functions;

 

/
