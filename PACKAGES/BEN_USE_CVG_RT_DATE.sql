--------------------------------------------------------
--  DDL for Package BEN_USE_CVG_RT_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_USE_CVG_RT_DATE" AUTHID CURRENT_USER as
/* $Header: benuscrd.pkh 120.0.12010000.2 2008/09/30 06:19:10 krupani ship $ */
--
procedure get_csd_rsd_Status( p_pgm_id         in number default null
                   ,p_ptip_id        in number default null
                   ,p_plip_id        in number default null
                   ,p_pl_id          in number default null
                   ,p_effective_date in date   default null
                   ,p_status         out nocopy varchar2
                    ) ;
--
procedure fonm_clear_down_cache;
--
procedure get_fonm (p_fonm               out nocopy varchar2 ,
                    p_fonm_cvg_strt_dt   out nocopy  date ,
                    p_fonm_rt_strt_dt    out nocopy  date
                   ) ;



procedure set_fonm (p_fonm               in varchar2 ,
                    p_fonm_cvg_strt_dt   in date default null ,
                    p_fonm_rt_strt_dt    in date default null
                   ) ;

procedure clear_fonm_globals;

end  ben_use_cvg_rt_date;

/
